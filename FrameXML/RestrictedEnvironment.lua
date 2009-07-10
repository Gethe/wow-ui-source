-- RestrictedEnvironment.lua (Part of the new Secure Headers implementation)
--
-- This file defines the environment available to restricted code. The
-- 'base' API functions (everything that's safe to use from the core
-- WoW lua API), and functions which provide the same degree of game state
-- as macro conditionals.
--
-- Nevin Flanagan (alestane@comcast.net)
-- Daniel Stephens (iriel@vigilance-committee.org)
---------------------------------------------------------------------------

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

local select = select;
local tostring = tostring;
local type = type;

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

local geterrorhandler = geterrorhandler;
local forceinsecure = forceinsecure;
local pcall = pcall;
local securecall = securecall;

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

-- The bare minimum functions that should exist in order to be
-- useful without being ridiculously restrictive.

RESTRICTED_FUNCTIONS_SCOPE = {
    math = math;
    string = string;
    -- table is provided elsewhere, as direct tables are not allowed

    select = select;
    tonumber = tonumber;
    tostring = tostring;

    print = print;

    -- String methods
    format = format;
    gmatch = gmatch;
    gsub = gsub; -- Restricted table aware rtgsub is added later
    strbyte = strbyte;
    strchar = strchar;
    strconcat = strconcat;
    strfind = strfind;
    strjoin = strjoin;
    strlen = strlen;
    strlower = strlower;
    strmatch = strmatch;
    strrep = strrep;
    strrev = strrev;
    strsplit = strsplit;
    strsub = strsub;
    strtrim = strtrim;
    strupper = strupper;

    -- Math functions
    abs = abs;
    acos = acos;
    asin = asin;
    atan = atan;
    atan2 = atan2;
    ceil = ceil;
    cos = cos;
    deg = deg;
    exp = exp;
    floor = floor;
    frexp = frexp;
    ldexp = ldexp;
    log = log;
    log10 = log10;
    max = max;
    min = min;
    mod = mod;
    rad = rad;
    random = random;
    sin = sin;
    tan = tan;
};

-- Initialize directly available functions so they can be copied into the
-- table
local DIRECT_MACRO_CONDITIONAL_NAMES = {
    "SecureCmdOptionParse",
    "GetShapeshiftForm", "IsStealthed",
    "UnitExists", "UnitIsDead", "UnitIsGhost",
    "UnitPlayerOrPetInParty", "UnitPlayerOrPetInRaid",
    "IsRightAltKeyDown", "IsLeftAltKeyDown", "IsAltKeyDown",
    "IsRightControlKeyDown", "IsLeftControlKeyDown", "IsControlKeyDown",
    "IsLeftShiftKeyDown", "IsRightShiftKeyDown", "IsShiftKeyDown",
    "IsModifierKeyDown", "IsModifiedClick",
    "GetMouseButtonClicked", "GetActionBarPage", "GetBonusBarOffset",
    "IsMounted", "IsSwimming", "IsFlying", "IsFlyableArea",
    "IsIndoors", "IsOutdoors",
};

local OTHER_SAFE_FUNCTION_NAMES = {
    "GetBindingKey", "HasAction",
    "IsHarmfulSpell", "IsHarmfulItem", "IsHelpfulSpell", "IsHelpfulItem",
    "GetMultiCastTotemSpells"
};

-- Copy the direct functions into the table
for _, name in ipairs( DIRECT_MACRO_CONDITIONAL_NAMES ) do
    RESTRICTED_FUNCTIONS_SCOPE[name] = _G[name];
end

-- Copy the other safe functions into the table
for _, name in ipairs( OTHER_SAFE_FUNCTION_NAMES ) do
    RESTRICTED_FUNCTIONS_SCOPE[name] = _G[name];
end

-- Now create the remainder (ENV is just an alias for brevity)
local ENV = RESTRICTED_FUNCTIONS_SCOPE;

function ENV.PlayerCanAttack( unit )
    return UnitCanAttack( "player", unit )
end

function ENV.PlayerCanAssist( unit )
    return UnitCanAssist( "player", unit )
end

function ENV.PlayerIsChanneling()
    return (UnitChannelInfo( "player" ) ~= nil)
end

function ENV.PlayerPetSummary()
    return UnitCreatureFamily( "pet" ), (UnitName( "pet" ))
end

function ENV.PlayerInCombat()
    return UnitAffectingCombat( "player" ) or UnitAffectingCombat( "pet" )
end

function ENV.PlayerInGroup()
    return ( GetNumRaidMembers() > 0 and "raid" )
        or ( GetNumPartyMembers() > 0 and "party" )
end

function ENV.UnitHasVehicleUI(unit)
	unit = tostring(unit);
	return UnitHasVehicleUI(unit) and 
		(UnitCanAssist("player", unit:gsub("(%D+)(%d*)", "%1pet%2")) and true) or 
		(UnitCanAssist("player", unit) and false);
end

function ENV.RegisterStateDriver(frameHandle, ...)
	return RegisterStateDriver(GetFrameHandleFrame(frameHandle), ...)
end

local safeActionTypes = {["spell"] = true, ["companion"] = true, ["item"] = true, ["macro"] = true}
local function scrubActionInfo(actionType, ...)
	if ( safeActionTypes[actionType]) then
		return actionType, ...
	else
		return actionType
	end
end

function ENV.GetActionInfo(...)
	return scrubActionInfo(GetActionInfo(...));
end

ENV = nil;
