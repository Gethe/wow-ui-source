-- RestrictedEnvironment.lua (Part of the new Secure Headers implementation)
--
-- This file defines the environment available to restricted code. The
-- 'base' API functions (everything that's safe to use from the core
-- WoW lua API), and functions which provide the same degree of game state
-- as macro conditionals.
--
-- Nevin Flanagan
-- Daniel Stephens
---------------------------------------------------------------------------

local _, addonTable = ...;  -- Used for passing RESTRICTED_FUNCTIONS_SCOPE.

local _G = GetGlobalEnvironment();

local tostring = tostring;
local GetFrameHandleFrame = _G.GetFrameHandleFrame;
local IsFrameHandle = _G.IsFrameHandle;
local RestrictedTable_copytable = _G.rtable.copytable;

-- The bare minimum functions that should exist in order to be
-- useful without being ridiculously restrictive.

local RESTRICTED_FUNCTIONS_SCOPE = {
    math = math;
    string = string;
    -- table is provided elsewhere, as direct tables are not allowed

    select = select;
    tonumber = tonumber;
    tostring = tostring;
	rawtype = type;  -- Added for test cases; almost certainly useless to addons.

    -- String methods
    format = format;
    gmatch = gmatch;
    gsub = gsub; -- Restricted table aware rtgsub is added later
    strbyte = strbyte;
    strchar = strchar;
    strcmputf8i = strcmputf8i;
    strconcat = strconcat;
    strfind = strfind;
    strjoin = strjoin;
    strlen = strlen;
    strlenutf8 = strlenutf8;
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
    "GetMouseButtonClicked",
    "IsMounted", "IsSwimming", "IsSubmerged", "IsFlying", "IsFlyableArea", "IsAdvancedFlyableArea", "IsDrivableArea",
    "IsIndoors", "IsOutdoors", "CanExitVehicle"
};

-- Copy the direct functions into the table
for _, name in ipairs( DIRECT_MACRO_CONDITIONAL_NAMES ) do
    RESTRICTED_FUNCTIONS_SCOPE[name] = _G[name];
end

-- The remaining functions in this file are bindings to either non-builtin
-- C APIs that don't return macro-conditional style booleans, or call outbound
-- to Lua functions in the global environment.
--
-- These functions should all be collected into the following 'ENV' table so
-- that they can be wrapped in closures that scrub inbound return values to
-- prevent table returns entering the restricted environment.

local ENV = {};

local function ScrubInboundValue(v)
	if type(v) == "table" then
		return RestrictedTable_copytable(v);
	else
		return scrub(v);
	end
end

local function ScrubInboundValues(...)
	return mapvalues(ScrubInboundValue, ...);
end

local function ScrubOutboundValue(v)
	if IsFrameHandle(v) then
		return v;
	else
		return scrub(v);
	end
end

local function ScrubOutboundValues(...)
	return mapvalues(ScrubOutboundValue, ...);
end

-- Note: Where possible, please don't do direct assignments like this and
-- instead write out proper functions that forward the call manually. Caching
-- function references directly like this makes it impossible to exercise
-- these in unit tests.

ENV.FindSpellBookSlotBySpellID = FindSpellBookSlotBySpellID;
ENV.GetActionBarPage = C_ActionBar.GetActionBarPage;
ENV.GetBindingKey = GetBindingKey;
ENV.GetBonusBarIndex = C_ActionBar.GetBonusBarIndex;
ENV.GetBonusBarOffset = C_ActionBar.GetBonusBarOffset;
ENV.GetMultiCastTotemSpells = GetMultiCastTotemSpells;
ENV.GetOverrideBarIndex = C_ActionBar.GetOverrideBarIndex;
ENV.GetTempShapeshiftBarIndex = C_ActionBar.GetTempShapeshiftBarIndex;
ENV.GetVehicleBarIndex = C_ActionBar.GetVehicleBarIndex;
ENV.HasAction = C_ActionBar.HasAction;
ENV.HasBonusActionBar = C_ActionBar.HasBonusActionBar;
ENV.HasExtraActionBar = C_ActionBar.HasExtraActionBar;
ENV.HasOverrideActionBar = C_ActionBar.HasOverrideActionBar;
ENV.HasTempShapeshiftActionBar = C_ActionBar.HasTempShapeshiftActionBar;
ENV.HasVehicleActionBar = C_ActionBar.HasVehicleActionBar;
ENV.IsHarmfulItem = C_Item.IsHarmfulItem;
ENV.IsHelpfulItem = C_Item.IsHelpfulItem;
ENV.IsPressHoldReleaseSpell = C_Spell.IsPressHoldReleaseSpell;
ENV.IsSpellHarmful = C_Spell.IsSpellHarmful;
ENV.IsSpellHelpful = C_Spell.IsSpellHelpful;
ENV.UnitTargetsVehicleInRaidUI = UnitTargetsVehicleInRaidUI;

local safeActionTypes = {["spell"] = true, ["companion"] = true, ["item"] = true, ["macro"] = true, ["flyout"] = true}
local function scrubActionInfo(actionType, id, subType, ...)
	if actionType == "spell" and subType == "assistedcombat" then
		return actionType, C_AssistedCombat.GetActionSpell(), subType, ...;
    elseif safeActionTypes[actionType] then
        return actionType, id, subType, ...;
    else
        return actionType;
    end
end

function ENV.GetActionInfo(...)
    return scrubActionInfo(GetActionInfo(...));
end

function ENV.IsGamePadEnabled()
	return C_GamePad.IsEnabled();
end

function ENV.GetGamePadState()
	return C_GamePad.GetDeviceMappedState();
end

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
    return ( IsInRaid() and "raid" )
        or ( IsInGroup() and "party" )
end

function ENV.UnitHasVehicleUI(unit)
    unit = tostring(unit);
    return UnitHasVehicleUI(unit) and
        (UnitCanAssist("player", unit:gsub("(%D+)(%d*)", "%1pet%2")) and true) or
        (UnitCanAssist("player", unit) and false);
end

-- The following functions are outbound calls to Lua functions defined in the
-- global environment.
--
-- Because functions in the global environment can be securely hooked by
-- addons, it is *required* that all outbound calls invoke either the scrub
-- or ScrubOutboundValues functions on all inputs from the restricted
-- environment.
--
-- One exception applies and that's for calls to GetFrameHandleFrame, which is
-- safe to call without scrubbing.

function ENV.print(...)
	_G.print(ScrubOutboundValues(...));
end

function ENV.RegisterStateDriver(frameHandle, ...)
    _G.RegisterStateDriver(GetFrameHandleFrame(frameHandle), scrub(...));
end

function ENV.UnregisterStateDriver(frameHandle, ...)
    _G.UnregisterStateDriver(GetFrameHandleFrame(frameHandle), scrub(...));
end

function ENV.RegisterAttributeDriver(frameHandle, ...)
    _G.RegisterAttributeDriver(GetFrameHandleFrame(frameHandle), scrub(...));
end

function ENV.UnregisterAttributeDriver(frameHandle, ...)
    _G.UnregisterAttributeDriver(GetFrameHandleFrame(frameHandle), scrub(...));
end

function ENV.RegisterUnitWatch(frameHandle, ...)
    _G.RegisterUnitWatch(GetFrameHandleFrame(frameHandle), scrub(...));
end

function ENV.UnregisterUnitWatch(frameHandle, ...)
    _G.UnregisterUnitWatch(GetFrameHandleFrame(frameHandle));
end

function ENV.UnitWatchRegistered(frameHandle, ...)
    return _G.UnitWatchRegistered(GetFrameHandleFrame(frameHandle));
end

-- All functions in the ENV table need copying to RESTRICTED_FUNCTIONS_SCOPE
-- with wrapping closures to scrub return values.

local function CreateInboundReturnScrubber(func)
	local function Wrapper(...)
		return ScrubInboundValues(func(...));
	end

	return Wrapper;
end

local function ImportOutboundFunctions(dst, src)
	for k, v in pairs(src) do
		if type(v) == "function" then
			dst[k] = CreateInboundReturnScrubber(v);
		elseif type(v) == "table" then
			ImportOutboundFunctions(dst[k] or {}, v);
		else
			dst[k] = v;
		end
	end
end

ImportOutboundFunctions(RESTRICTED_FUNCTIONS_SCOPE, ENV);

-- The RESTRICTED_FUNCTIONS_SCOPE table needs exporting via our local addon
-- table to make it available to other scripts in this addon.

addonTable.RESTRICTED_FUNCTIONS_SCOPE = RESTRICTED_FUNCTIONS_SCOPE;
