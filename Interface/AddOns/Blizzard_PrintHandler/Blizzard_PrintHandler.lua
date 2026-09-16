local type = type;
local error = error;
local geterrorhandler = geterrorhandler;
local forceinsecure = forceinsecure;
local securecall = securecall;
local tostring = tostring;
local next = next;
local unpack = unpack;
local pairs = pairs;
local ipairs = ipairs;
local select = select;
local wipe = wipe;
local pcall = pcall;
local strjoin = string.join;
local PrintToDebugWindow = PrintToDebugWindow;

---------------------------------------------------------------------------
-- Somewhat extensible print infrastructure for debugging, modelled around
-- error handler code.
--
-- setprinthandler(func) -- Sets the active print handler
-- func = getprinthandler() -- Gets the current print handler
-- print(...) -- Passes its arguments to the current print handler
--
-- The default print handler simply string.join's its arguments with a " "
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

local tostringall = tostringall;

local LOCAL_PrintHandler =
    function(...)
		local printMsg = string.join(" ", tostringall(...));
		if DEFAULT_CHAT_FRAME then
			DEFAULT_CHAT_FRAME:AddMessage(printMsg);
		end
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

function print(...) -- luacheck: ignore 121 (setting read-only global variable 'print')
    securecall(pcall, print_inner, ...);
end
