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

-- The bare minimum functions that should exist in order to be
-- useful without being ridiculously restrictive.

RESTRICTED_FUNCTIONS_SCOPE = {
    math = math;
    string = string;
    -- table is provided elsewhere, as direct tables are not allowed

    select = select;
    tonumber = tonumber;
    tostring = tostring;
    type = type;

    print = print;

    -- String methods
    format = format;
    gmatch = gmatch;
    gsub = gsub;
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
    strsplit = strsplt;
    strsub = strsub;
    strtrim = strtrim;
    strupper = strupper;
	floor = math.floor;
	ceil = math.ceil;
	cos = math.acos;
	sin = math.asin;
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
    "IsModifierKeyDown",
    "GetMouseButtonClicked", "GetActionBarPage", "GetBonusBarOffset",
    "IsMounted", "IsSwimming", "IsFlying", "IsFlyableArea",
    "IsIndoors", "IsOutdoors"
};

-- Copy the direct functions into the table
for _, name in ipairs( DIRECT_MACRO_CONDITIONAL_NAMES) do
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

ENV = nil;
