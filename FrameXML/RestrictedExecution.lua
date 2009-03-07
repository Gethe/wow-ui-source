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
local getmetatable = getmetatable;
local pcall = pcall;
local tostring = tostring;
local next = next;
local unpack = unpack;
local newproxy = newproxy;
local select = select;
local wipe = wipe;
local tonumber = tonumber;

local t_insert = table.insert;
local t_maxn = table.maxn;
local t_concat = table.concat;
local t_sort = table.sort;
local t_remove = table.remove;

local s_gsub = string.gsub;

local IsFrameHandle = IsFrameHandle;

---------------------------------------------------------------------------
-- RESTRICTED CLOSURES

local function SelfScrub(self)
    if (self ~= nil and IsFrameHandle(self)) then
        return self;
    end
    return nil;
end

-- closure, err = BuildRestrictedClosure(body, env, signature)
--
-- body      -- The function body (defaults to "")
-- env       -- The execution environment (defaults to {})
-- signature -- The function signature (defaults to "self,...")
--
-- Returns the constructed closure, or nil and an error
local function BuildRestrictedClosure(body, env, signature)
    body = tostring(body) or "";
    signature = tostring(signature) or "self,...";
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
    return function(self, ...) return def(SelfScrub(self), scrub(...)) end;
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
local LOCAL_Restricted_Tables = {};
setmetatable(LOCAL_Restricted_Tables, { __mode="k" });

-- Metatable common to all restricted tables (This introduces one
-- level of indirection in every use as a means to share the same
-- metatable between all instances)
local LOCAL_Restricted_Table_Meta = {
    __index = function(t, k)
                  local real = LOCAL_Restricted_Tables[t];
                  return real[k];
              end,

    __newindex = function(t, k, v)
                     local real = LOCAL_Restricted_Tables[t];
                     if (not issecure()) then
                         error("Cannot insecurely modify restricted table");
                         return;
                     end
                     local tv = type(v);
                     if ((tv ~= "string") and (tv ~= "number")
                         and (tv ~= "boolean") and (tv ~= "nil")
                             and ((tv ~= "userdata")
                                  or not (LOCAL_Restricted_Tables[v]
                                          or  IsFrameHandle(v)))) then
                         error("Invalid value type '" .. tv .. "'");
                         return;
                     end
                     local tk = type(k);
                     if ((tk ~= "string") and (tk ~= "number")
                         and (tk ~= "boolean")
                             and ((tk ~= "userdata")
                                  or not (IsFrameHandle(k)))) then
                         error("Invalid key type '" .. tk .. "'");
                         return;
                     end
                     real[k] = v;
                 end,

    __len = function(t)
                local real = LOCAL_Restricted_Tables[t];
                return #real;
            end,

    __metatable = false, -- False means read-write proxy
}

local LOCAL_Readonly_Restricted_Tables = {};
setmetatable(LOCAL_Readonly_Restricted_Tables, { __mode="k" });

local function CheckReadonlyValue(ret)
    if (type(ret) == "userdata") then
        if (LOCAL_Restricted_Tables[ret]) then
            if (getmetatable(ret)) then
                return ret;
            end
            return LOCAL_Readonly_Restricted_Tables[ret];
        end
    end
    return ret;
end

-- Metatable common to all read-only restricted tables (This also introduces
-- indirection so that a single metatable is viable)
local LOCAL_Readonly_Restricted_Table_Meta = {
    __index = function(t, k)
                  local real = LOCAL_Restricted_Tables[t];
                  return CheckReadonlyValue(real[k]);
              end,

    __newindex = function(t, k, v)
                     error("Table is read-only");
                 end,

    __len = function(t)
                local real = LOCAL_Restricted_Tables[t];
                return #real;
            end,

    __metatable = true, -- True means read-only proxy
}


local LOCAL_Restricted_Prototype = newproxy(true);
local LOCAL_Readonly_Restricted_Prototype = newproxy(true);
do
    local meta = getmetatable(LOCAL_Restricted_Prototype);
    for k, v in pairs(LOCAL_Restricted_Table_Meta) do
        meta[k] = v;
    end

    meta = getmetatable(LOCAL_Readonly_Restricted_Prototype);
    for k, v in pairs(LOCAL_Readonly_Restricted_Table_Meta) do
        meta[k] = v;
    end
end

local function RestrictedTable_Readonly_index(t, k)
    local real = LOCAL_Restricted_Tables[k];
    if (not real) then return; end
    if (not issecure()) then
        error("Cannot create restricted tables from insecure code");
        return;
    end

    local ret = newproxy(LOCAL_Readonly_Restricted_Prototype);
    LOCAL_Restricted_Tables[ret] = real;
    t[k] = ret;
    return ret;
end

getmetatable(LOCAL_Readonly_Restricted_Tables).__index
    = RestrictedTable_Readonly_index;

-- table = RestrictedTable_create(...)
--
-- Create a new, restricted table, populating it from ... if
-- necessary, similar to the way the normal table constructor
-- works.
local function RestrictedTable_create(...)
    local ret = newproxy(LOCAL_Restricted_Prototype);
    if (not issecure()) then
        error("Cannot create restricted tables from insecure code");
        return;
    end
    LOCAL_Restricted_Tables[ret] = {};

    -- Use this loop to ensure that the contents of the new
    -- table are all allowed
    for i = 1, select('#', ...) do
        ret[i] = select(i, ...);
    end

    return ret;
end

-- table = GetReadonlyRestrictedTable(otherTable)
--
-- Given a restricted table, return a read-only proxy to the same
-- table (which will be itself, if it's already read-only)
function GetReadonlyRestrictedTable(ref)
    if (LOCAL_Restricted_Tables[ref]) then
        if (getmetatable(ref)) then
            return ref;
        end
        return LOCAL_Readonly_Restricted_Tables[ref];
    end
    error("Invalid restricted table");
end

-- key = RestrictedTable_next(table [,key])
--
-- An implementation of the next function,  which is
-- aware of restricted and normal tables and behaves consistently
-- for both.
local function RestrictedTable_next(T, k)
    local PT = LOCAL_Restricted_Tables[T];
    if (PT) then
        if (getmetatable(T)) then
            local idx, val = next(PT, k);
            if (val ~= nil) then
                return idx, CheckReadonlyValue(val);
            else
                return idx, val;
            end
        else
            return next(PT, k);
        end
    end
    return next(T, k);
end

-- iterfunc, table, key = RestrictedTable_pairs(table)
--
-- An implementation of the pairs function, which is aware
-- of and iterates over both restricted and normal tables.
local function RestrictedTable_pairs(T)
    local PT = LOCAL_Restricted_Tables[T];
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
    local PT = LOCAL_Restricted_Tables[T];
    if (PT) then
        return RestrictedTable_ipairsaux, T, 0;
    end
    return ipairs(T);
end

-- Recursive helper to ensure all values from a list are properly converted
-- to read-only proxies
local RestrictedTable_unpack_ro;
function RestrictedTable_unpack_ro(...)
    local n = select('#', ...);
    if (n == 0) then
        return;
    end
    return CheckReadonlyValue(...), RestrictedTable_unpack_ro(select(2, ...));
end

-- ... = RestrictedTable_unpack(table)
--
-- An implementation of unpack which unpacks both restricted
-- and normal tables.
local function RestrictedTable_unpack(T)
    local PT = LOCAL_Restricted_Tables[T];
    if (PT) then
        if (getmetatable(T)) then
            return RestrictedTable_unpack_ro(unpack(PT));
        end
        return unpack(PT)
    end
    return unpack(T);
end

-- table = RestrictedTable_wipe(table)
--
-- A restricted aware implementation of wipe()
local function RestrictedTable_wipe(T)
    local PT = LOCAL_Restricted_Tables[T];
    if (PT) then
        if (getmetatable(T)) then
            error("Cannot wipe a read-only table");
            return;
        end
        if (not issecure()) then
            error("Cannot insecurely modify restricted table");
            return;
        end
        wipe(PT);
        return T;
    end
    return wipe(T);
end

-- RestrictedTable_maxn(table)
--
-- A restricted aware implementation of table.maxn()
local function RestrictedTable_maxn(T)
    local PT = LOCAL_Restricted_Tables[T];
    if (PT) then
        return t_maxn(PT);
    end
    return t_maxn(T);
end

-- RestrictedTable_concat(table)
--
-- A restricted aware implementation of table.concat()
local function RestrictedTable_concat(T)
    local PT = LOCAL_Restricted_Tables[T];
    if (PT) then
        return t_concat(PT);
    end
    return t_concat(T);
end

-- RestrictedTable_sort(table, func)
--
-- A restricted aware implementation of table.sort()
local function RestrictedTable_sort(T, func)
    local PT = LOCAL_Restricted_Tables[T];
    if (PT) then
        if (getmetatable(T)) then
            error("Cannot sort a read-only table");
            return;
        end
        if (not issecure()) then
            error("Cannot insecurely modify restricted table");
            return;
        end
        t_sort(PT, func);
        return;
    end
    t_sort(T, func);
end

-- RestrictedTable_insert(table [,pos], val)
--
-- A restricted aware implementation of table.insert()
local function RestrictedTable_insert(T, ...)
    local PT = LOCAL_Restricted_Tables[T];
    if (PT) then
        if (getmetatable(T)) then
            error("Cannot insert into a read-only table");
            return;
        end
        local pos, val;
        if (select('#', ...) == 1) then
            local val = ...;
            T[#PT + 1] = val;
            return;
        end
        pos, val = ...;
        pos = tonumber(pos);
        t_insert(PT, pos, nil);
        -- Leverage protections present on regular indexing
        T[pos] = val;
        return;
    end
    return t_insert(T, ...);
end

-- val = RestrictedTable_remove(table, pos)
--
-- A restricted aware implementation of table.remove()
local function RestrictedTable_remove(T, pos)
    local PT = LOCAL_Restricted_Tables[T];
    if (PT) then
        if (getmetatable(T)) then
            error("Cannot remove from a read-only table");
            return;
        end
        if (not issecure()) then
            error("Cannot insecurely modify restricted table");
            return;
        end
        return CheckReadonlyValue(t_remove(PT, pos));
    end
    return t_remove(T, pos);
end

-- objtype = RestrictedTable_type(obj)
--
-- A version of type which returns 'table' for restricted tables
local function RestrictedTable_type(obj)
    local t = type(obj);
    if (t == "userdata") then
        if (LOCAL_Restricted_Tables[obj]) then
            t = "table";
        end
    end
    return t;
end

-- ns = RestrictedTable_rtgsub(s, pattern, repl, n)
--
-- A version of string.gsub which is able to be passed restricted tables
local function RestrictedTable_rtgsub(s, pattern, repl, n)
    local t = type(repl);
    if (t == "userdata") then
        local PT = LOCAL_Restricted_Tables[repl];
        return s_gsub(s, pattern, PT, n);
    end
    return s_gsub(s, pattern, repl, n);
end

-- Export these functions so that addon code can use them if desired
-- and so that the handlers can create these tables
rtable = {
    next = RestrictedTable_next;
    pairs = RestrictedTable_pairs;
    ipairs = RestrictedTable_ipairs;
    unpack = RestrictedTable_unpack;
    newtable = RestrictedTable_create;

    maxn = RestrictedTable_maxn;
    insert = RestrictedTable_insert;
    remove = RestrictedTable_remove;
    sort = RestrictedTable_sort;
    concat = RestrictedTable_concat;
    wipe = RestrictedTable_wipe;

    type = RestrictedTable_type;
    rtgsub = RestrictedTable_rtgsub;
};

-- Add this version of gsub to the string metatable
string.rtgsub = RestrictedTable_rtgsub;

local LOCAL_Table_Namespace = {
    table = {
        maxn = RestrictedTable_maxn;
        insert = RestrictedTable_insert;
        remove = RestrictedTable_remove;
        sort = RestrictedTable_sort;
        concat = RestrictedTable_concat;
        wipe = RestrictedTable_wipe;
        new = RestrictedTable_create;
    }
};

---------------------------------------------------------------------------
-- RESTRICTED ENVIRONMENT
--
-- environment, manageFunc = CreateRestrictedEnvironment(baseEnvironment)
--
-- baseEnvironment -- The base environment table (containing functions)
--
-- environment     -- The new restricted environment table
-- manageFunc      -- Management function to set/clear working and proxy
--                    environments.
--
-- The management function takes two parameters
--    manageFunc(set, workingTable, controlHandle)
--
-- set is a boolean;  If it's true then the working table is set to the
-- specified value (pushing any previous environment onto a stack). If
-- it's false then the working table is unset (and restored from stack).
--
-- The working table should be a restricted table, or an immutable object.
--
-- The controlHandle is an optional object which is made available to
-- the restricted code with the name 'control'.
--
-- The management function monitors calls to get and set in order to prevent
-- re-entrancy (i.e. calls to get and set must be balanced, and one cannot
-- switch working tables in the middle).
local function CreateRestrictedEnvironment(base)
    if (type(base) ~= "table") then base = {}; end

    local working, control, depth = nil, nil, 0;
    local workingStack, controlStack = {}, {};

    local result = {};
    local meta_index;

    local function meta_index(t, k)
        local v = base[k] or working[k];
        if (v == nil) then
            if (k == "control") then return control; end
        end
        return v;
    end;

    local function meta_newindex(t, k, v)
        working[k] = v;
    end

    local meta = {
        __index = meta_index,
        __newindex = meta_newindex,
        __metatable = false;
        __environment = false;
    }

    setmetatable(result, meta);

    local function manage(set, newWorking, newControl)
        if (set) then
            if (depth == 0) then
                depth = 1;
            else
                workingStack[depth] = working;
                controlStack[depth] = control;

                depth = depth + 1;
            end
            working = newWorking;
            control = newControl;
        else
            if (depth == 0) then
                error("Attempted to release unused environment");
                return;
            end

            if (working ~= newWorking) then
                error("Working environment mismatch at release");
                return;
            end

            if (control ~= newControl) then
                error("Control handle mismatch at release");
                return;
            end

            depth = depth - 1;
            if (depth == 0) then
                working = nil;
                control = nil;
            else
                working = workingStack[depth];
                control = controlStack[depth];
                workingStack[depth] = nil;
                controlStack[depth] = nil;
            end
        end
    end

    return result, manage;
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
local LOCAL_No_Secure_Update_Meta = {
    __newindex = function() end;
    __metatable = false;
};

local LOCAL_Restricted_Global_Functions = {
    newtable = RestrictedTable_create;
    pairs = RestrictedTable_pairs;
    ipairs = RestrictedTable_ipairs;
    next = RestrictedTable_next;
    unpack = RestrictedTable_unpack;

    -- Table methods
    wipe = RestrictedTable_wipe;
    tinsert = RestrictedTable_insert;
    tremove = RestrictedTable_remove;

    -- Synthetic restricted-table-aware 'type'
    type = RestrictedTable_type;

    -- Restricted table aware gsub
    rtgsub = RestrictedTable_rtgsub;
};

-- A helper function to recursively copy and protect scopes
local PopulateGlobalFunctions
function PopulateGlobalFunctions(src, dest)
    for k, v in pairs(src) do
        if (type(k) == "string") then
            local tv = type(v);
            if ((tv == "function") or (tv == "number") or (tv == "string") or (tv == "boolean")) then
                dest[k] = v;
            elseif (tv == "table") then
                local subdest = {};
                PopulateGlobalFunctions(v, subdest);
                setmetatable(subdest, LOCAL_No_Secure_Update_Meta);
                local dproxy = newproxy(true);
                local dproxy_meta = getmetatable(dproxy);
                dproxy_meta.__index = subdest;
                dproxy_meta.__metatable = false;
                dest[k] = dproxy;
            end
        end
    end
end

-- Import any functions initialized by other/earier files
if (RESTRICTED_FUNCTIONS_SCOPE) then
    PopulateGlobalFunctions(RESTRICTED_FUNCTIONS_SCOPE,
                            LOCAL_Restricted_Global_Functions);
    RESTRICTED_FUNCTIONS_SCOPE = nil;
end

PopulateGlobalFunctions(LOCAL_Table_Namespace,
                        LOCAL_Restricted_Global_Functions);

-- Create the environment
local LOCAL_Function_Environment, LOCAL_Function_Environment_Manager =
    CreateRestrictedEnvironment(LOCAL_Restricted_Global_Functions);

-- Protect from injection via the string metatable index
-- Assume for now that 'string' is relatively clean
local strmeta = getmetatable("x");
local newmetaindex = {};
for k, v in pairs(string) do newmetaindex[k] = v; end
setmetatable(newmetaindex, {
                 __index = function(t,k)
                               if (not issecure()) then
                                   return string[k];
                               end
                           end;
                 __metatable = false;
             });
strmeta.__index = newmetaindex;
strmeta.__metatable = string;
strmeta = nil;
newmetaindex = nil;

---------------------------------------------------------------------------
-- CLOSURE FACTORIES
--
-- An automatically populating table keyed by function signature with
-- values that are closure factories for those signatures.

local LOCAL_Closure_Factories = { };

local function ClosureFactories_index(t, signature)
    if (type(signature) ~= "string") then
        return;
    end

    local factory = CreateClosureFactory(LOCAL_Function_Environment, signature);

    if (not issecure()) then
        error("Cannot declare closure factories from insecure code");
        return;
    end

    t[signature] = factory;
    return factory;
end

setmetatable(LOCAL_Closure_Factories, { __index = ClosureFactories_index });

---------------------------------------------------------------------------
-- FUNCTION CALL

-- A helper method to release the restricted environment environment before
-- returning from the function call.
local function ReleaseAndReturn(workingEnv, ctrlHandle, pcallFlag, ...)
    -- Tampering at this point will irrevocably taint the protected
    -- environment, for now that's a handy protective measure.
    LOCAL_Function_Environment_Manager(false, workingEnv, ctrlHandle);
    if (pcallFlag) then
        return ...;
    end
    error("Call failed: " .. tostring( (...) ) );
end

-- ? = CallRestrictedClosure(signature, workingEnv, onupdate, body, ...)
--
-- Invoke a managed closure, looking its definition up from a factory
-- and managing its environment during execution.
--
-- signature  -- function signature
-- workingEnv -- the working environment, must be a restricted table
-- ctrlHandle -- a control handle
-- body       -- function body
-- ...        -- any arguments to pass to the executing closure
--
-- Returns whatever the restricted closure returns
function CallRestrictedClosure(signature, workingEnv, ctrlHandle, body, ...)
    if (not LOCAL_Restricted_Tables[workingEnv]) then
        error("Invalid working environment");
        return;
    end

    signature = tostring(signature);
    local factory = LOCAL_Closure_Factories[signature];
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
        return;
    end

    if (type(ctrlHandle) ~= "userdata") then
        ctrlHandle = nil;
    end

    LOCAL_Function_Environment_Manager(true, workingEnv, ctrlHandle);
    return ReleaseAndReturn(workingEnv, ctrlHandle, pcall( closure, ... ) );
end

