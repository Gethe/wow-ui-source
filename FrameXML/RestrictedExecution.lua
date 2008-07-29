-- RestrictedExecution.lua (Part of the new Secure Headers implementation)
--
-- This contains the necessary (and sufficient) code to support
-- 'restricted execution' for code provided via attributes, intended
-- for use in the secure header implementations. It provides a fairly
-- isolated execution environment and is constructed to maintain local
-- control over the important elements of the execution environment.
--
-- Daniel Stephens (iriel@vigilance-committee.org)
-- Nevin Flanagan (alestane@comcast.net)
---------------------------------------------------------------------------

-- Localizes for functions that are frequently called or need to be
-- assuredly un-replaceable or unhookable.
local type = type;
local error = error;
local scrub = scrub;
local issecure = issecure;
local rawset = rawset;
local setfenv = setfenv;
local loadstring = loadstring;
local setmetatable = setmetatable;
local pcall = pcall;
local tostring = tostring;
local next = next;
local unpack = unpack;

---------------------------------------------------------------------------
-- RESTRICTED CLOSURES
--
-- closure, err = BuildRestrictedClosure(body, env, signature)
--
-- body      -- The function body (defaults to "")
-- env       -- The execution environment (defaults to {})
-- signature -- The function signature (defaults to "...")
--
-- Returns the constructed closure, or nil and an error
local function BuildRestrictedClosure(body, env, signature)
    body = tostring(body) or "";
    signature = tostring(signature) or "...";
    if (type(env) ~= "table") then
        env = {};
    end

    if (body:match("function")) then
        -- NOTE - This is overzealous but it keeps it simple
        return nil, "The function keyword is not permitted";
    end

    if (body:match("[{}]")) then
        -- NOTE - This is overzealous but it keeps it simple
        return nil, "Direct table creation is not permitted";
    end

    if (signature:match("function")) then
        -- NOTE - This is overzealous but it keeps it simple
        return nil, "The function keyword is not permitted";
    end

    if (not signature:match("^[a-zA-Z_0-9, ]*[.]*$")) then
        -- NOTE - This is overzealous but it keeps it simple
        return nil, "Signature contains invalid characters (" .. signature .. ")";
    end

    -- Include a \n before end to stop shenanigans with comments
    local def, err =
        loadstring("return function (" .. signature .. ") " .. body .. "\nend", body);
    if (def == nil) then
        return nil, err;
    end

    -- Use a completely empty environment here to be absolutely
    -- sure to avoid tampering during function definition.
    setfenv(def, {});
    def = def();
    -- Double check that the definition did infact return a function
    if (type(def) ~= "function") then
        return nil, "Invalid body";
    end
    -- Set the desired environment on the resulting closure.
    setfenv(def, env);

    -- And then return a 'safe' wrapped invocation for the closure.
    return function(...) return def(scrub(...)) end;
end

-- factory = CreateClosureFactory(env, signature)
--
-- env -- The desired environment table for the closures
-- signature -- The function signature for the closures
--
-- Returns a 'factory table' which is keyed by function bodies, and
-- has restricted closure values. It's weak-keyed and uses an __index
-- metamethod that automatically creates necessary closures on demand.
local function CreateClosureFactory(env, signature)
    local function metaIndex(t, k)
        if (type(k) == "string") then
            local closure, err = BuildRestrictedClosure(k, env, signature);
            if (not closure) then
                -- Put the error into a closure to avoid constantly
                -- re-parsing it
                err = tostring(err or "Closure creation failed");
                closure = function() error(err) end;
            end
            if (issecure()) then
                t[k] = closure;
            end
            return closure;
        end
        error("Invalid closure body type (" .. type(k) .. ")");
        return nil;
    end

    local ret = {};
    setmetatable(ret, { __index = metaIndex, __mode = "k" });
    return ret;
end

---------------------------------------------------------------------------
-- RESTRICTED TABLES
--
-- Provides fully proxied tables with restrictions on their contents.
--

-- Mapping table from restricted table 'proxy' to the 'real' storage
local RESTRICTED_TABLES = {};
setmetatable(RESTRICTED_TABLES, { __mode="k" });

-- Metatable common to all restricted tables (This introduces one
-- level of indirection in every use as a means to share the same
-- metatable between all instances)
local RESTRICTED_META = {
    __index = function(t, k)
                  local real = RESTRICTED_TABLES[t];
                  return real[k];
              end,

    __newindex = function(t, k, v)
                     local real = RESTRICTED_TABLES[t];
                     if (not issecure()) then
                         error("Cannot insecurely modify restricted table");
                         return;
                     end
                     local tv = type(v);
                     if ((tv ~= "string") and (tv ~= "number")
                         and (tv ~= "boolean") and (tv ~= "nil")
                             and ((tv ~= "table")
                                  or (not RESTRICTED_TABLES[v]))) then
                         error("Invalid value type '" .. tv .. "'");
                         return;
                     end
                     local tk = type(k);
                     if ((tk ~= "string") and (tk ~= "number")
                         and (tk ~= "boolean")) then
                         error("Invalid key type '" .. tk .. "'");
                         return;
                     end
                     real[k] = v;
                 end,

    __metatable = false,
}

-- table = RestrictedTable_create(...)
--
-- Create a new, restricted table, populating it from ... if
-- necessary, similar to the way the normal table constructor
-- works.
local function RestrictedTable_create(...)
    local ret = {};
    RESTRICTED_TABLES[ret] = {};
    setmetatable(ret, RESTRICTED_META);

    for i = 1, select('#', ...) do
        ret[i] = select(i, ...);
    end

    return ret;
end

-- key = RestrictedTable_next(table [,key])
--
-- An implementation of the next function,  which is
-- aware of restricted and normal tables and behaves consistently
-- for both.
local function RestrictedTable_next(T, k)
    local PT = RESTRICTED_TABLES[T];
    if (PT) then
        return next(PT, k);
    end
    return next(T, k);
end

-- iterfunc, table, key = RestrictedTable_pairs(table)
--
-- An implementation of the pairs function, which is aware
-- of and iterates over both restricted and normal tables.
local function RestrictedTable_pairs(T)
    local PT = RESTRICTED_TABLES[T];
    if (PT) then
        -- v
        return RestrictedTable_next, T, nil;
    end
    return pairs(T);
end

-- key, value = RestrictedTable_ipairsaux(table, prevkey)
--
-- Iterator function for internal use by restricted table ipairs
local function RestrictedTable_ipairsaux(T, i)
    i = i + 1;
    local v = T[i];
    if (v) then
        return i, v;
    end
end

-- iterfunc, table, key = RestrictedTable_ipairs(table)
--
-- An implementation of the ipairs function, which is aware
-- of and iterates over both restricted and normal tables.
local function RestrictedTable_ipairs(T)
    local PT = RESTRICTED_TABLES[T];
    if (PT) then
        return RestrictedTable_ipairsaux, T, 0;
    end
    return ipairs(T);
end

-- ... = RestrictedTable_unpack(table)
--
-- An implementation of unpack which unpacks both restricted
-- and normal tables.
local function RestrictedTable_unpack(T)
    local PT = RESTRICTED_TABLES[T];
    if (PT) then
        return unpack(PT)
    end
    return unpack(T);
end

-- size = RestrictedTable_tablesize(table)
--
-- An equivalent to #table that works for both restricted
-- and normal tables.
local function RestrictedTable_tablesize(T)
    if (type(T) ~= "table") then
        error("Input is not a table");
        return;
    end
    local PT = RESTRICTED_TABLES[T];
    if (PT) then
        return #PT;
    end
    return #T;
end

-- Export these functions so that addon code can use them if desired
-- and so that the handlers can create these tables
rtable = {
    next = RestrictedTable_next;
    pairs = RestrictedTable_pairs;
    ipairs = RestrictedTable_ipairs;
    unpack = RestrictedTable_unpack;
    tablesize = RestrictedTable_tablesize;
    newtable = RestrictedTable_create;
};

---------------------------------------------------------------------------
-- RESTRICTED ENVIRONMENT
--
-- environment, controlFunc = CreateRestrictedEnvironment(baseEnvironment)
--
-- baseEnvironment -- The base environment table (containing functions)
--
-- environment     -- The new restricted environment table
-- controlFunc     -- Control function to set/clear working and proxy
--                    environments.
--
-- The control function takes two or three parameters
--    controlFunc(set, workingTable [,proxyNamespace])
--
-- set is a boolean;  If it's true then the working table and proxy environment
-- are set to the specified values. If it's false then the working table and
-- proxy environment are reset.
--
-- The working table should be a restricted table, or an immutable object.
--
-- The control function monitors calls to get and set in order to prevent
-- re-entrancy (i.e. calls to get and set must be balanced, and one cannot
-- switch working tables in the middle).
local function CreateRestrictedEnvironment(base)
    if (type(base) ~= "table") then base = {}; end

    local working, proxyNamespace, depth = nil, nil, 0;

    local result = {};
    local meta_index;

    local function meta_index(t, k)
        return base[k]
            or (proxyNamespace ~= nil and proxyNamespace[k])
            or working[k];
    end;

    local function meta_newindex(t, k, v)
        working[k] = v;
    end

    local meta = {
        __index = meta_index,
        __newindex = meta_newindex,
        __metatable = false;
    }

    setmetatable(result, meta);

    local function control(set, newWorking, newProxyNamespace)
        if (set) then
            if (depth == 0) then
                depth = 1;
                working = newWorking;
                proxyNamespace = newProxyNamespace;
            else
                if (working ~= newWorking) then
                    error("Attempted to re-use environment with depth "
                          .. depth);
                    return;
                end
                if (ProxyNamespace ~= newProxyNamespace) then
                    error("Attempted to re-use environment with depth "
                          .. depth);
                    return;
                end
                depth = depth + 1;
            end
        else
            if (depth == 0) then
                error("Attempted to release unused environment");
                return;
            end

            if (working ~= newWorking) then
                error("Working environment mismatch at release");
                return;
            end

            if (proxyNamespace ~= newProxyNamespace) then
                error("Proxy namespace environment mismatch at release");
                return;
            end

            depth = depth - 1;
            if (depth == 0) then working = nil; end
        end
    end

    return result, control;
end


---------------------------------------------------------------------------
-- AVAILABLE FUNCTIONS
--
-- The current implementation has a single set of functions (aka a single
-- base environment), this initializes that environment by creating a master
-- base environment table, and then creating a restricted environment
-- around that. If the RESTRICTED_FUNCTIONS_SCOPE table exists when
-- this file is executed then its contents are added to the environment.
--
-- It is expected that any functions that are to be placed into this
-- environment have been carefully written to not return arbtirary tables,
-- functions, or userdata back to the caller.
--
-- One can use function(...) return scrub(realFunction(...)) end to wrap
-- those functions one doesn't trust.

-- A metatable to prevent tampering with the environment tables.
local NO_SECURE_UPDATE_META = {
    __newindex = function() end;
    __metatable = false;
};

local RESTRICTED_GLOBAL_FUNCTIONS = {
    newtable = RestrictedTable_create;
    pairs = RestrictedTable_pairs;
    ipairs = RestrictedTable_ipairs;
    next = RestrictedTable_next;
};

-- A helper function to recursively copy and protect scopes
local PopulateGlobalFunctions
function PopulateGlobalFunctions(src, dest)
    for k, v in pairs(src) do
        local tv = type(v);
        if (tv == "function") then
            dest[k] = v;
        elseif (tv == "table") then
            local subdest = {};
            PopulateGlobalFunctions(v, subdest);
            setmetatable(subdest, NO_SECURE_UPDATE_META);
            dest[k] = subdest;
		elseif (tv == "number") then
			dest[k] = v;
        end
    end
end

-- Import any functions initialized by other/earier files
if (RESTRICTED_FUNCTIONS_SCOPE) then
    PopulateGlobalFunctions(RESTRICTED_FUNCTIONS_SCOPE,
                            RESTRICTED_GLOBAL_FUNCTIONS);
    RESTRICTED_FUNCTIONS_SCOPE = nil;
end

-- Create the environment
local FUNCTION_ENVIRONMENT, FUNCTION_ENVIRONMENT_CONTROL =
    CreateRestrictedEnvironment(RESTRICTED_GLOBAL_FUNCTIONS);

---------------------------------------------------------------------------
-- CLOSURE FACTORIES
--
-- An automatically populating table keyed by function signature with
-- values that are closure factories for those signatures.

local CLOSURE_FACTORIES = { };

local function ClosureFactories_index(t, signature)
    if (type(signature) ~= "string") then
        return;
    end

    local factory = CreateClosureFactory(FUNCTION_ENVIRONMENT, signature);

    if (not issecure()) then
        error("Cannot declare closure factories from insecure code");
        return;
    end

    t[signature] = factory;
    return factory;
end

setmetatable(CLOSURE_FACTORIES, { __index = ClosureFactories_index });

---------------------------------------------------------------------------
-- FUNCTION CALL

-- A helper method to release the restricted environment environment before
-- returning from the function call.
local function ReleaseAndReturn(workingEnv, proxyNs, pcallFlag, ...)
    -- Tampering at this point will irrevocably taint the protected
    -- environment, for now that's a handy protective measure.
    FUNCTION_ENVIRONMENT_CONTROL(false, workingEnv, proxyNs);
    if (pcallFlag) then
        return ...;
    end
    error("Call failed: " .. tostring( (...) ) );
end

-- ? = CallRestrictedClosure(signature, workingEnv, proxyNs, body, ...)
--
-- Invoke a managed closure, looking its definition up from a factory
-- and managing its environment during execution.
--
-- signature  -- function signature
-- workingEnv -- the working environment, must be a restricted table
-- proxyNs    -- an 'object proxies' namespace table, which can be nil
-- body       -- function body
-- ...        -- any arguments to pass to the executing closure
--
-- Returns whatever the restricted closure returns
function CallRestrictedClosure(signature, workingEnv, proxyNs, body, ...)
    if (not RESTRICTED_TABLES[workingEnv]) then
        error("Invalid working environment");
        return;
    end

    signature = tostring(signature);
    local factory = CLOSURE_FACTORIES[signature];
    if (not factory) then
        error("Invalid signature '" .. signature .. "'");
        return;
    end

    local closure = factory[body];
    if (not closure) then
        -- Expect factory to have thrown an error
        return;
    end

    if (not issecure()) then
        error("Cannot call restricted closure from insecure code");
    end
    FUNCTION_ENVIRONMENT_CONTROL(true, workingEnv, proxyNs);
    return ReleaseAndReturn(workingEnv, proxyNs, pcall( closure, ... ) );
end
