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
local setfenv = setfenv;
local loadstring = loadstring;
local setmetatable = setmetatable;
local getmetatable = getmetatable;
local pcall = pcall;
local tostring = tostring;
local newproxy = newproxy;
local select = select;

local IsFrameHandle = IsFrameHandle;
local IsWritableRestrictedTable = IsWritableRestrictedTable;

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

-- Max number of cached closures before cache dump, if this value proves
-- problematic we may wish to make it tunable.
local CLOSURE_CACHE_MAX = 1000;

-- factory = CreateClosureFactory(env, signature)
--
-- env -- The desired environment table for the closures
-- signature -- The function signature for the closures
--
-- Returns a 'factory table' which is keyed by function bodies, and
-- has restricted closure values. It's weak-keyed and uses an __index
-- metamethod that automatically creates necessary closures on demand.
local function CreateClosureFactory(env, signature)
    local newCache, oldCache = {}, {};
    local newCount = 0;

    local function metaIndex(t, k)
        if (type(k) == "string") then
            local closure = oldCache[k];
            if (not closure) then
                local newClosure, err = BuildRestrictedClosure(k, env, signature);
                if (newClosure) then
                    closure = newClosure;
                else
                    -- Put the error into a closure to avoid constantly
                    -- re-parsing it
                    err = tostring(err or "Closure creation failed");
                    closure = function() error(err) end;
                end
            end
            if (issecure()) then
                newCount = newCount + 1;
                if (newCount > CLOSURE_CACHE_MAX) then
                    -- The cache is full, rotate it
                    for ok in pairs(t) do
                        t[ok] = nil;
                    end
                    oldCache = newCache;
                    newCache = {};
                    newCount = 0;
                end

                newCache[k] = closure;
                t[k] = closure;
            end
            return closure;
        end
        error("Invalid closure body type (" .. type(k) .. ")");
        return nil;
    end

    local ret = {};
    setmetatable(ret, { __index = metaIndex });
    return ret;
end

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
    newtable = rtable.newtable;
    pairs = rtable.pairs;
    ipairs = rtable.ipairs;
    next = rtable.next;
    unpack = rtable.unpack;

    -- Table methods
    wipe = rtable.wipe;
    tinsert = rtable.insert;
    tremove = rtable.remove;

    -- Synthetic restricted-table-aware 'type'
    type = rtable.type;

    -- Restricted table aware gsub
    rtgsub = rtable.rtgsub;
};

-- A helper function to recursively copy and protect scopes
local function PopulateGlobalFunctions(src, dest)
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

local LOCAL_Table_Namespace = {
    table = {
        maxn = rtable.maxn;
        insert = rtable.insert;
        remove = rtable.remove;
        sort = rtable.sort;
        concat = rtable.concat;
        wipe = rtable.wipe;
        new = rtable.newtable;
    }
};

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
    if (not IsWritableRestrictedTable(workingEnv)) then
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

