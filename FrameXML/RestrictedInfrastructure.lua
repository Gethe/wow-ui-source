-- RestrictedInfrastrucure.lua (Part of the Secure Handlers implementation)
--
-- This module provides core types to support the other Restricted modules:
--     A WoW-suitable implementation of print;
--     A structure for storing "handles" to frames that emulate those frames
--       inside the restricted environment;
--     A proxy type to represent tables inside restricted environments;
--     A function for examining and securely creating restricted environments,
--       to support executing snippets.
--
-- Daniel Stephens (iriel@vigilance-committee.org)
-- Nevin Flanagan (alestane@comcast.net)
---------------------------------------------------------------------------

local type = type;
local error = error;
local geterrorhandler = geterrorhandler;
local issecure = issecure;
local forceinsecure = forceinsecure;
local securecall = securecall;
local setmetatable = setmetatable;
local getmetatable = getmetatable;
local tostring = tostring;
local rawget = rawget;
local next = next;
local unpack = unpack;
local pairs = pairs;
local ipairs = ipairs;
local newproxy = newproxy;
local select = select;
local wipe = wipe;
local tonumber = tonumber;
local pcall = pcall;

local t_insert = table.insert;
local t_maxn = table.maxn;
local t_concat = table.concat;
local t_sort = table.sort;
local t_remove = table.remove;

local s_gsub = string.gsub;

local InCombatLockdown = InCombatLockdown;

---------------------------------------------------------------------------
-- Somewhat extensible print infrastructure for debugging, modelled around
-- error handler code.
--
-- setprinthandler(func) -- Sets the active print handler
-- func = getprinthandler() -- Gets the current print handler
-- print(...) -- Passes its arguments to the current print handler
--
-- The default print handler simply strjoin's its arguments with a " "
-- delimiter and adds it to DEFAULT_CHAT_FRAME

local LOCAL_ToStringAllTemp = {};
function tostringall(...)
    local n = select('#', ...);
    -- Simple versions for common argument counts
    if (n == 1) then
        return tostring(...);
    elseif (n == 2) then
        local a, b = ...;
        return tostring(a), tostring(b);
    elseif (n == 3) then
        local a, b, c = ...;
        return tostring(a), tostring(b), tostring(c);
    elseif (n == 0) then
        return;
    end

    local needfix;
    for i = 1, n do
        local v = select(i, ...);
        if (type(v) ~= "string") then
            needfix = i;
            break;
        end
    end
    if (not needfix) then return ...; end

    wipe(LOCAL_ToStringAllTemp);
    for i = 1, needfix - 1 do
        LOCAL_ToStringAllTemp[i] = select(i, ...);
    end
    for i = needfix, n do
        LOCAL_ToStringAllTemp[i] = tostring(select(i, ...));
    end
    return unpack(LOCAL_ToStringAllTemp);
end

local LOCAL_PrintHandler =
    function(...)
        DEFAULT_CHAT_FRAME:AddMessage(strjoin(" ", tostringall(...)));
    end

function setprinthandler(func)
    if (type(func) ~= "function") then
        error("Invalid print handler");
    else
        LOCAL_PrintHandler = func;
    end
end

function getprinthandler() return LOCAL_PrintHandler; end

local function print_inner(...)
    forceinsecure();
    local ok, err = pcall(LOCAL_PrintHandler, ...);
    if (not ok) then
        local func = geterrorhandler();
        func(err);
    end
end

function print(...)
    securecall(pcall, print_inner, ...);
end

---------------------------------------------------------------------------
-- FRAME HANDLES
--
-- Handle objects to access frames during restricted execution in order to
-- allow safe manipulation of frame properties. These handles can be passed
-- around safely without allowing their destinations or functions to be
-- tampered with.
--
-- HANDLES: These are lightweight userdata objects with a shared metatable
--          that stand in for frames. They're persistent once created (i.e.
--          a given frame always has the same handle). Internally these map
--          to a 'copied' frame object. Only explcitly protected frames can
--          be assigned handles.
--
-- METHODS: The handler methods are contained in a table which is then set
--          as the __index on the handlers. These are in two groups, there
--          are 'read' methods that may be blocked in some situations, and
--          there are 'write' methods which simply require that an execution
--          is active.
--
-- Method definitions can be found in RestrictedFrames.lua
--
-- LOCAL_FrameHandle_Protected_Frames -- handle keys, frame surrogate values
--                                       (explicitly protected)
-- LOCAL_FrameHandle_Other_Frames -- handle keys, frame surrogate values
--                                   (possibly protected)
-- LOCAL_FrameHandle_Lookup -- frame keys, handle values
--
-- The lookup table auto-populates via an __index metamethod

local LOCAL_FrameHandle_Protected_Frames = {};
local LOCAL_FrameHandle_Other_Frames = {};
local LOCAL_FrameHandle_Lookup = {};
setmetatable(LOCAL_FrameHandle_Protected_Frames, { __mode = "k" });
setmetatable(LOCAL_FrameHandle_Other_Frames, { __mode = "k" });

-- Setup metatable for prototype object
local LOCAL_FrameHandle_Prototype = newproxy(true);
-- HANDLE is the frame handle method namespace (populated later)
local HANDLE = {};
do
    local meta = getmetatable(LOCAL_FrameHandle_Prototype);
    meta.__index = HANDLE;
    meta.__metatable = false;
end

function IsFrameHandle(handle, protected)
    local surrogate = LOCAL_FrameHandle_Protected_Frames[handle];
    if ((surrogate == nil) and not protected) then
        surrogate = LOCAL_FrameHandle_Other_Frames[handle];
    end
    return (surrogate ~= nil);
end

function GetFrameHandleFrame(handle, protected, onlyProtected)
    local surrogate = LOCAL_FrameHandle_Protected_Frames[handle];
    local protectedSurrogate = true;
    if ((surrogate == nil)
        and (not protected or (not (onlyProtected or InCombatLockdown())))) then
        surrogate = LOCAL_FrameHandle_Other_Frames[handle];
        protectedSurrogate = false;
    end
    if (surrogate ~= nil) then
        return surrogate[1], protectedSurrogate;
    end
end

local function FrameHandleLookup_index(t, frame)
    -- Create a 'surrogate' frame object
    local surrogate = { [0] = frame[0], [1] = frame };
    setmetatable(surrogate, getmetatable(frame));
    -- Test whether the frame is explcitly protected
    local _, protected = surrogate:IsProtected();
    if (not issecure()) then
        return;
    end
    local handle = newproxy(LOCAL_FrameHandle_Prototype);
    LOCAL_FrameHandle_Lookup[frame] = handle;
    if (protected) then
        LOCAL_FrameHandle_Protected_Frames[handle] = surrogate;
    else
        LOCAL_FrameHandle_Other_Frames[handle] = surrogate;
    end
    return handle;
end
setmetatable(LOCAL_FrameHandle_Lookup, { __index = FrameHandleLookup_index; });

-- Gets the handle for a frame (if available)
function GetFrameHandle(frame, protected)
    local handle = LOCAL_FrameHandle_Lookup[frame];
    if (protected and (frame ~= nil)) then
        if (not LOCAL_FrameHandle_Protected_Frames[handle]) then
            return nil;
        end
    end
    return handle;
end

local handleNamespaceInitialized = false;

-- Single-shot function to populate the frame handle namespace
function InitFrameHandleNamespace(namespace)
    if (not handleNamespaceInitialized) then
        -- Prevent further calls
        handleNamespaceInitialized = true;

        for k, v in pairs(namespace) do
            if (type(k) == "string" and type(v) == "function"
                and issecure()) then
                HANDLE[k] = v;
            end
        end
    end
end

---------------------------------------------------------------------------
-- RESTRICTED TABLES
--
-- Provides fully proxied tables with restrictions on their contents.

-- Capture IsFrameHandle (declared earlier)
local IsFrameHandle = IsFrameHandle;

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

-- isWritableRef = IsWritableRestrictedTable(ref)
--
-- Given a restricted table, return true if it is writable
function IsWritableRestrictedTable(ref)
    if (LOCAL_Restricted_Tables[ref]) then
        return true;
    end
    return false;
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


---------------------------------------------------------------------------
-- WORKING ENVIRONMENTS
--
-- Working environments and control handles

local function ManagedEnvironmentsIndex(t, k)
    if (not issecure() or type(k) ~= "table") then
        error("Invalid access of managed environments table");
        return;
    end;

    local ownerHandle = GetFrameHandle(k, true);
    if (not ownerHandle) then
        error("Invalid access of managed environments table (bad frame)");
        return;
    end
    local _, explicitProtected = ownerHandle:IsProtected();
    if (not explicitProtected) then
        error("Invalid access of managed environments table (not protected)");
        return;
    end

    local e = RestrictedTable_create();
    e._G = e;
    e.owner = ownerHandle;
    t[k] = e;
    return e;
end

local LOCAL_Managed_Environments = {};
setmetatable(LOCAL_Managed_Environments,
             {
                 __index = ManagedEnvironmentsIndex,
                 __mode = "k",
             });

function GetManagedEnvironment(envKey, withCreate)
    if (withCreate) then
        return LOCAL_Managed_Environments[envKey];
    else
        return rawget(LOCAL_Managed_Environments, envKey);
    end
end

