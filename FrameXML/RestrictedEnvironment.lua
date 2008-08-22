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

local LOCAL_PrintHandler =
    function(...)
        DEFAULT_CHAT_FRAME:AddMessage(strjoin(" ", ...));
    end

function setprinthandler(func)
    if (type(func) ~= "function") then
        error("Invalid print handler");
        LOCAL_PrintHandler = func;
    end
end

function getprinthandler() return LOCAL_PrintHandler; end

local pcall = pcall;
local securecall = securecall;
local geterrorhandler = geterrorhandler;

local function print_inner(...)
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
    "IsModifierKeyDown",
    "GetMouseButtonClicked", "GetActionBarPage", "GetBonusBarOffset",
    "IsMounted", "IsSwimming", "IsFlying", "IsFlyableArea",
    "IsIndoors", "IsOutdoors",
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
