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

local tostring = tostring;
local GetFrameHandleFrame = GetFrameHandleFrame;

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
    "GetMultiCastTotemSpells", "FindSpellBookSlotBySpellID"
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
    return RegisterStateDriver(GetFrameHandleFrame(frameHandle), ...);
end

function ENV.UnregisterStateDriver(frameHandle, ...)
    return UnregisterStateDriver(GetFrameHandleFrame(frameHandle), ...);
end

function ENV.RegisterAttributeDriver(frameHandle, ...)
    return RegisterAttributeDriver(GetFrameHandleFrame(frameHandle), ...);
end

function ENV.UnregisterAttributeDriver(frameHandle, ...)
    return UnregisterAttributeDriver(GetFrameHandleFrame(frameHandle), ...);
end

function ENV.RegisterUnitWatch(frameHandle, ...)
    return RegisterUnitWatch(GetFrameHandleFrame(frameHandle), ...);
end

function ENV.UnregisterUnitWatch(frameHandle, ...)
    return UnregisterUnitWatch(GetFrameHandleFrame(frameHandle), ...);
end

function ENV.UnitWatchRegistered(frameHandle, ...)
    return UnitWatchRegistered(GetFrameHandleFrame(frameHandle), ...);
end

local safeActionTypes = {["spell"] = true, ["companion"] = true, ["item"] = true, ["macro"] = true, ["flyout"] = true}
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
