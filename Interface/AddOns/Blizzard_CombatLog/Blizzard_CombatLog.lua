--[[
--	Blizzard Combat Log
--	 by Alexander Yoshi
--
--	This is a prototype combat log designed to serve the
--	majority of needs for WoW players. The new and improved
--	combat log event formatting should allow for the community
--	to develop even better combat logs in the future.
--
--	Thanks to:
--		Chris Heald & Xinhuan - Code Optimization Support
--
--]]

-- Version
-- Constant -- Incrementing this number will erase saved filter settings!!
COMBATLOG_FILTER_VERSION = 4.3;
-- Saved Variable
Blizzard_CombatLog_Filter_Version = 0;

-- Define the log
COMBATLOG = ChatFrame2;

-- BUFF / DEBUFF
AURA_TYPE_BUFF = "BUFF";
AURA_TYPE_DEBUFF = "DEBUFF"

-- Message Limit
COMBATLOG_LIMIT_PER_FRAME = 1;
COMBATLOG_HIGHLIGHT_MULTIPLIER = 1.5;

-- Default Colors
COMBATLOG_DEFAULT_COLORS = {
	-- Unit names
	unitColoring = {
		[COMBATLOG_FILTER_MINE] 		= {a=1.0,r=0.70,g=0.70,b=0.70}; --{a=1.0,r=0.14,g=1.00,b=0.15};
		[COMBATLOG_FILTER_MY_PET] 		= {a=1.0,r=0.70,g=0.70,b=0.70}; --{a=1.0,r=0.14,g=0.80,b=0.15};
		[COMBATLOG_FILTER_FRIENDLY_UNITS] 	= {a=1.0,r=0.34,g=0.64,b=1.00};
		[COMBATLOG_FILTER_HOSTILE_UNITS] 	= {a=1.0,r=0.75,g=0.05,b=0.05};
		[COMBATLOG_FILTER_HOSTILE_PLAYERS] 	= {a=1.0,r=0.75,g=0.05,b=0.05};
		[COMBATLOG_FILTER_NEUTRAL_UNITS] 	= {a=1.0,r=0.75,g=0.05,b=0.05}; -- {a=1.0,r=0.80,g=0.80,b=0.14};
		[COMBATLOG_FILTER_UNKNOWN_UNITS] 	= {a=1.0,r=0.75,g=0.75,b=0.75};
	};
	-- School coloring
	schoolColoring = {
		[Enum.Damageclass.MaskNone]	= {a=1.0,r=1.00,g=1.00,b=1.00};
		[Enum.Damageclass.MaskPhysical]	= {a=1.0,r=1.00,g=1.00,b=0.00};
		[Enum.Damageclass.MaskHoly] 	= {a=1.0,r=1.00,g=0.90,b=0.50};
		[Enum.Damageclass.MaskFire] 	= {a=1.0,r=1.00,g=0.50,b=0.00};
		[Enum.Damageclass.MaskNature] 	= {a=1.0,r=0.30,g=1.00,b=0.30};
		[Enum.Damageclass.MaskFrost] 	= {a=1.0,r=0.50,g=1.00,b=1.00};
		[Enum.Damageclass.MaskShadow] 	= {a=1.0,r=0.50,g=0.50,b=1.00};
		[Enum.Damageclass.MaskArcane] 	= {a=1.0,r=1.00,g=0.50,b=1.00};
	};
	-- Defaults
	defaults = {
		spell = {a=1.0,r=1.00,g=1.00,b=1.00};
		damage = {a=1.0,r=1.00,g=1.00,b=0.00};
	};
	-- Line coloring
	eventColoring = {
	};

	-- Highlighted events
	highlightedEvents = {
		["PARTY_KILL"] = true;
	};
};
COMBATLOG_DEFAULT_SETTINGS = {
	-- Settings
	fullText = false;
	textMode = TEXT_MODE_A;
	timestamp = false;
	timestampFormat = TEXT_MODE_A_TIMESTAMP;
	unitColoring = false;
	sourceColoring = true;
	destColoring = true;
	lineColoring = true;
	lineHighlighting = true;
	abilityColoring = false;
	abilityActorColoring = false;
	abilitySchoolColoring = false;
	abilityHighlighting = true;
	actionColoring = false;
	actionActorColoring = false;
	actionHighlighting = false;
	amountColoring = false;
	amountActorColoring = false;
	amountSchoolColoring = false;
	amountHighlighting = true;
	schoolNameColoring = false;
	schoolNameActorColoring = false;
	schoolNameHighlighting = true;
	noMeleeSwingColoring = false;
	missColoring = true;
	braces = false;
	unitBraces = true;
	sourceBraces = true;
	destBraces = true;
	spellBraces = false;
	itemBraces = true;
	showHistory = true;
	lineColorPriority = 1; -- 1 = source->dest->event, 2 = dest->source->event, 3 = event->source->dest
	unitIcons = true;
	hideBuffs = true;
	hideDebuffs = true;
	--unitTokens = true;
};

--
-- Combat Log Icons
--
COMBATLOG_ICON_RAIDTARGET1			= "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1.blp:0|t";
COMBATLOG_ICON_RAIDTARGET2			= "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2.blp:0|t";
COMBATLOG_ICON_RAIDTARGET3			= "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3.blp:0|t";
COMBATLOG_ICON_RAIDTARGET4			= "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4.blp:0|t";
COMBATLOG_ICON_RAIDTARGET5			= "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5.blp:0|t";
COMBATLOG_ICON_RAIDTARGET6			= "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6.blp:0|t";
COMBATLOG_ICON_RAIDTARGET7			= "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7.blp:0|t";
COMBATLOG_ICON_RAIDTARGET8			= "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8.blp:0|t";

--
-- Default Event List
--
COMBATLOG_EVENT_LIST = {
	["ENVIRONMENTAL_DAMAGE"] = true,
	["SWING_DAMAGE"] = true,
	["SWING_MISSED"] = true,
	["RANGE_DAMAGE"] = true,
	["RANGE_MISSED"] = true,
	["SPELL_CAST_START"] = false,
	["SPELL_CAST_SUCCESS"] = false,
	["SPELL_CAST_FAILED"] = false,
	["SPELL_MISSED"] = true,
	["SPELL_DAMAGE"] = true,
	["SPELL_HEAL"] = true,
	["SPELL_ENERGIZE"] = true,
	["SPELL_DRAIN"] = true,
	["SPELL_LEECH"] = true,
	["SPELL_SUMMON"] = true,
	["SPELL_RESURRECT"] = true,
	["SPELL_CREATE"] = true,
	["SPELL_INSTAKILL"] = true,
	["SPELL_INTERRUPT"] = true,
	["SPELL_EXTRA_ATTACKS"] = true,
	["SPELL_DURABILITY_DAMAGE"] = false,
	["SPELL_DURABILITY_DAMAGE_ALL"] = false,
	["SPELL_AURA_APPLIED"] = false,
	["SPELL_AURA_APPLIED_DOSE"] = false,
	["SPELL_AURA_REMOVED"] = false,
	["SPELL_AURA_REMOVED_DOSE"] = false,
	["SPELL_AURA_BROKEN"] = false,
	["SPELL_AURA_BROKEN_SPELL"] = false,
	["SPELL_AURA_REFRESH"] = false,
	["SPELL_DISPEL"] = true,
	["SPELL_STOLEN"] = true,
	["ENCHANT_APPLIED"] = true,
	["ENCHANT_REMOVED"] = true,
	["SPELL_PERIODIC_MISSED"] = true,
	["SPELL_PERIODIC_DAMAGE"] = true,
	["SPELL_PERIODIC_HEAL"] = true,
	["SPELL_PERIODIC_ENERGIZE"] = true,
	["SPELL_PERIODIC_DRAIN"] = true,
	["SPELL_PERIODIC_LEECH"] = true,
	["SPELL_DISPEL_FAILED"] = true,
	["DAMAGE_SHIELD"] = false,
	["DAMAGE_SHIELD_MISSED"] = false,
	["DAMAGE_SPLIT"] = false,
	["PARTY_KILL"] = true,
	["UNIT_DIED"] = true,
	["UNIT_DESTROYED"] = true,
	["SPELL_BUILDING_DAMAGE"] = true,
	["SPELL_BUILDING_HEAL"] = true,
	["UNIT_DISSIPATES"] = true,
	["SPELL_EMPOWER_START"] = true,
	["SPELL_EMPOWER_END"] = true,
	["SPELL_EMPOWER_INTERRUPT"] = true,
};

COMBATLOG_FLAG_LIST = {
	[COMBATLOG_FILTER_MINE] = true,
	[COMBATLOG_FILTER_MY_PET] = true,
	[COMBATLOG_FILTER_FRIENDLY_UNITS] = true,
	[COMBATLOG_FILTER_HOSTILE_UNITS] = true,
	[COMBATLOG_FILTER_HOSTILE_PLAYERS] = true,
	[COMBATLOG_FILTER_NEUTRAL_UNITS] = true,
	[COMBATLOG_FILTER_UNKNOWN_UNITS] = true,
};

EVENT_TEMPLATE_FORMATS = {
	["SPELL_AURA_BROKEN_SPELL"] = TEXT_MODE_A_STRING_3,
	["SPELL_CAST_START"] = TEXT_MODE_A_STRING_2,
	["SPELL_CAST_SUCCESS"] = TEXT_MODE_A_STRING_2,
	["SPELL_EMPOWER_START"] = TEXT_MODE_A_STRING_2,
	["SPELL_EMPOWER_END"] = TEXT_MODE_A_STRING_2
};

--
-- 	Creates an empty filter
--
function Blizzard_CombatLog_InitializeFilters( settings )
	settings.filters =
	{
		[1] = {
			eventList = {};
		};
	};
end

--
--	Generates a new event list from the COMBATLOG_EVENT_LIST global
--
--	I wish there was a better way built in to do this.
--
--	Returns:
--		An array, indexed by the events, with a value of true
--
function Blizzard_CombatLog_GenerateFullEventList ( )
	local eventList = {}
	for event, v in pairs ( COMBATLOG_EVENT_LIST ) do
		eventList[event] = true;
	end
	return eventList;
end

function Blizzard_CombatLog_GenerateFullFlagList(flag)
	local flagList = {};
	for k, v in pairs(COMBATLOG_FLAG_LIST) do
		flagList[k] = flag;
	end
	return flagList;
end

--
-- Default CombatLog Filter
-- This table is used to create new CombatLog filters
--
DEFAULT_COMBATLOG_FILTER_TEMPLATE = {
	-- Descriptive Information
	hasQuickButton = true;
	quickButtonDisplay = {
		solo = true;
		party = true;
		raid = true;
	};

	-- Default Color and Formatting Options
	settings = CopyTable(COMBATLOG_DEFAULT_SETTINGS);

	-- Coloring
	colors = CopyTable(COMBATLOG_DEFAULT_COLORS);

	-- The actual client filters
	filters = {
		[1] = {
			eventList = Blizzard_CombatLog_GenerateFullEventList();
			sourceFlags = {
				[COMBATLOG_FILTER_MINE] = true,
				[COMBATLOG_FILTER_MY_PET] = true;
			};
			destFlags = nil;
		};
		[2] = {
			eventList = Blizzard_CombatLog_GenerateFullEventList();
			sourceFlags = nil;
			destFlags = {
				[COMBATLOG_FILTER_MINE] = true,
				[COMBATLOG_FILTER_MY_PET] = true;
			};
		};
	};
};


local CombatLogUpdateFrame = CreateFrame("Frame", "CombatLogUpdateFrame", UIParent);
local _G = getfenv(0);
local bit_bor = _G.bit.bor;
local bit_band = _G.bit.band;
local tinsert = _G.tinsert;
local tremove = _G.tremove;
local math_floor = _G.math.floor;
local format = _G.format;
local gsub = _G.gsub;
local strsub = _G.strsub;

-- Make all the constants upvalues. This prevents the global environment lookup + table lookup each time we use one (and they're used a lot)
local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE;
local COMBATLOG_OBJECT_AFFILIATION_PARTY = COMBATLOG_OBJECT_AFFILIATION_PARTY;
local COMBATLOG_OBJECT_AFFILIATION_RAID = COMBATLOG_OBJECT_AFFILIATION_RAID;
local COMBATLOG_OBJECT_AFFILIATION_OUTSIDER = COMBATLOG_OBJECT_AFFILIATION_OUTSIDER;
local COMBATLOG_OBJECT_AFFILIATION_MASK = COMBATLOG_OBJECT_AFFILIATION_MASK;
local COMBATLOG_OBJECT_REACTION_FRIENDLY = COMBATLOG_OBJECT_REACTION_FRIENDLY;
local COMBATLOG_OBJECT_REACTION_NEUTRAL = COMBATLOG_OBJECT_REACTION_NEUTRAL;
local COMBATLOG_OBJECT_REACTION_HOSTILE = COMBATLOG_OBJECT_REACTION_HOSTILE;
local COMBATLOG_OBJECT_REACTION_MASK = COMBATLOG_OBJECT_REACTION_MASK;
local COMBATLOG_OBJECT_CONTROL_PLAYER = COMBATLOG_OBJECT_CONTROL_PLAYER;
local COMBATLOG_OBJECT_CONTROL_NPC = COMBATLOG_OBJECT_CONTROL_NPC;
local COMBATLOG_OBJECT_CONTROL_MASK = COMBATLOG_OBJECT_CONTROL_MASK;
local COMBATLOG_OBJECT_TYPE_PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER;
local COMBATLOG_OBJECT_TYPE_NPC = COMBATLOG_OBJECT_TYPE_NPC;
local COMBATLOG_OBJECT_TYPE_PET = COMBATLOG_OBJECT_TYPE_PET;
local COMBATLOG_OBJECT_TYPE_GUARDIAN = COMBATLOG_OBJECT_TYPE_GUARDIAN;
local COMBATLOG_OBJECT_TYPE_OBJECT = COMBATLOG_OBJECT_TYPE_OBJECT;
local COMBATLOG_OBJECT_TYPE_MASK = COMBATLOG_OBJECT_TYPE_MASK;
local COMBATLOG_OBJECT_TARGET = COMBATLOG_OBJECT_TARGET;
local COMBATLOG_OBJECT_FOCUS = COMBATLOG_OBJECT_FOCUS;
local COMBATLOG_OBJECT_MAINTANK = COMBATLOG_OBJECT_MAINTANK;
local COMBATLOG_OBJECT_MAINASSIST = COMBATLOG_OBJECT_MAINASSIST;
local COMBATLOG_OBJECT_RAIDTARGET1 = COMBATLOG_OBJECT_RAIDTARGET1;
local COMBATLOG_OBJECT_RAIDTARGET2 = COMBATLOG_OBJECT_RAIDTARGET2;
local COMBATLOG_OBJECT_RAIDTARGET3 = COMBATLOG_OBJECT_RAIDTARGET3;
local COMBATLOG_OBJECT_RAIDTARGET4 = COMBATLOG_OBJECT_RAIDTARGET4;
local COMBATLOG_OBJECT_RAIDTARGET5 = COMBATLOG_OBJECT_RAIDTARGET5;
local COMBATLOG_OBJECT_RAIDTARGET6 = COMBATLOG_OBJECT_RAIDTARGET6;
local COMBATLOG_OBJECT_RAIDTARGET7 = COMBATLOG_OBJECT_RAIDTARGET7;
local COMBATLOG_OBJECT_RAIDTARGET8 = COMBATLOG_OBJECT_RAIDTARGET8;
local COMBATLOG_OBJECT_NONE = COMBATLOG_OBJECT_NONE;
local COMBATLOG_OBJECT_SPECIAL_MASK = COMBATLOG_OBJECT_SPECIAL_MASK;
local COMBATLOG_FILTER_ME = COMBATLOG_FILTER_ME;
local COMBATLOG_FILTER_MINE = COMBATLOG_FILTER_MINE;
local COMBATLOG_FILTER_MY_PET = COMBATLOG_FILTER_MY_PET;
local COMBATLOG_FILTER_FRIENDLY_UNITS = COMBATLOG_FILTER_FRIENDLY_UNITS;
local COMBATLOG_FILTER_HOSTILE_UNITS = COMBATLOG_FILTER_HOSTILE_UNITS;
local COMBATLOG_FILTER_HOSTILE_PLAYERS = COMBATLOG_FILTER_HOSTILE_PLAYERS;
local COMBATLOG_FILTER_NEUTRAL_UNITS = COMBATLOG_FILTER_NEUTRAL_UNITS;
local COMBATLOG_FILTER_UNKNOWN_UNITS = COMBATLOG_FILTER_UNKNOWN_UNITS;
local COMBATLOG_FILTER_EVERYTHING = COMBATLOG_FILTER_EVERYTHING;
local COMBATLOG = COMBATLOG;
local AURA_TYPE_BUFF = AURA_TYPE_BUFF;
local AURA_TYPE_DEBUFF = AURA_TYPE_DEBUFF;
local COMBATLOG_LIMIT_PER_FRAME = COMBATLOG_LIMIT_PER_FRAME;
local COMBATLOG_HIGHLIGHT_MULTIPLIER = COMBATLOG_HIGHLIGHT_MULTIPLIER;
local COMBATLOG_DEFAULT_COLORS = COMBATLOG_DEFAULT_COLORS;
local COMBATLOG_DEFAULT_SETTINGS = COMBATLOG_DEFAULT_SETTINGS;
local COMBATLOG_ICON_RAIDTARGET1 = COMBATLOG_ICON_RAIDTARGET1;
local COMBATLOG_ICON_RAIDTARGET2 = COMBATLOG_ICON_RAIDTARGET2;
local COMBATLOG_ICON_RAIDTARGET3 = COMBATLOG_ICON_RAIDTARGET3;
local COMBATLOG_ICON_RAIDTARGET4 = COMBATLOG_ICON_RAIDTARGET4;
local COMBATLOG_ICON_RAIDTARGET5 = COMBATLOG_ICON_RAIDTARGET5;
local COMBATLOG_ICON_RAIDTARGET6 = COMBATLOG_ICON_RAIDTARGET6;
local COMBATLOG_ICON_RAIDTARGET7 = COMBATLOG_ICON_RAIDTARGET7;
local COMBATLOG_ICON_RAIDTARGET8 = COMBATLOG_ICON_RAIDTARGET8;
local COMBATLOG_EVENT_LIST = COMBATLOG_EVENT_LIST;

local CombatLog_OnEvent		-- for later
local CombatLog_Object_IsA = CombatLog_Object_IsA


-- Create a dummy CombatLogQuickButtonFrame for line 803 of FloatingChatFrame.lua. It causes inappropriate show/hide behavior. Instead, we'll use our own frame display handling.
-- If there are more than 2 combat log frames, then the CombatLogQuickButtonFrame gets tied to the last frame tab's visibility status. Yuck! Let's just instead tie it to the combat log's tab.

local CombatLogQuickButtonFrame, CombatLogQuickButtonFrameProgressBar, CombatLogQuickButtonFrameTexture
_G.CombatLogQuickButtonFrame = CreateFrame("Frame", "CombatLogQuickButtonFrame", UIParent)

local Blizzard_CombatLog_Update_QuickButtons
local Blizzard_CombatLog_PreviousSettings


--
-- Persistant Variables
--
--
-- Default Filters
--
Blizzard_CombatLog_Filter_Defaults = {
	-- All of the filters
	filters = {
		[1] = {
			-- Descriptive Information
			name = QUICKBUTTON_NAME_MY_ACTIONS;
			hasQuickButton = true;
			quickButtonName = QUICKBUTTON_NAME_MY_ACTIONS;
			quickButtonDisplay = {
				solo = true;
				party = true;
				raid = true;
			};
			tooltip = QUICKBUTTON_NAME_MY_ACTIONS_TOOLTIP;

			-- Default Color and Formatting Options
			settings = CopyTable(COMBATLOG_DEFAULT_SETTINGS);

			-- Coloring
			colors = CopyTable(COMBATLOG_DEFAULT_COLORS);

			-- The actual client filters
			filters = {
				[1] = {
					eventList = {
					      ["ENVIRONMENTAL_DAMAGE"] = false,
					      ["SWING_DAMAGE"] = true,
					      ["SWING_MISSED"] = false,
					      ["RANGE_DAMAGE"] = true,
					      ["RANGE_MISSED"] = false,
					      --["SPELL_CAST_START"] = true,
					      --["SPELL_CAST_SUCCESS"] = true,
					      --["SPELL_CAST_FAILED"] = true,
					      ["SPELL_MISSED"] = false,
					      ["SPELL_DAMAGE"] = true,
					      ["SPELL_HEAL"] = true,
					      ["SPELL_ENERGIZE"] = false,
					      ["SPELL_DRAIN"] = false,
					      ["SPELL_LEECH"] = false,
					      ["SPELL_INSTAKILL"] = false,
					      ["SPELL_INTERRUPT"] = false,
					      ["SPELL_EXTRA_ATTACKS"] = false,
					      --["SPELL_DURABILITY_DAMAGE"] = true,
					      --["SPELL_DURABILITY_DAMAGE_ALL"] = true,
					      ["SPELL_AURA_APPLIED"] = false,
					      ["SPELL_AURA_APPLIED_DOSE"] = false,
					      ["SPELL_AURA_REMOVED"] = false,
					      ["SPELL_AURA_REMOVED_DOSE"] = false,
					      ["SPELL_AURA_BROKEN"] = false,
						  ["SPELL_AURA_BROKEN_SPELL"] = false,
						  ["SPELL_AURA_REFRESH"] = false,
					      ["SPELL_DISPEL"] = false,
					      ["SPELL_STOLEN"] = false,
					      ["ENCHANT_APPLIED"] = false,
					      ["ENCHANT_REMOVED"] = false,
					      ["SPELL_PERIODIC_MISSED"] = false,
					      ["SPELL_PERIODIC_DAMAGE"] = true,
					      ["SPELL_PERIODIC_HEAL"] = true,
					      ["SPELL_PERIODIC_ENERGIZE"] = false,
					      ["SPELL_PERIODIC_DRAIN"] = false,
					      ["SPELL_PERIODIC_LEECH"] = false,
					      ["SPELL_DISPEL_FAILED"] = false,
					      --["DAMAGE_SHIELD"] = true,
					      --["DAMAGE_SHIELD_MISSED"] = true,
					      ["DAMAGE_SPLIT"] = true,
					      ["PARTY_KILL"] = true,
					      ["UNIT_DIED"] = false,
					      ["UNIT_DESTROYED"] = true,
					      ["UNIT_DISSIPATES"] = true,
					      ["SPELL_EMPOWER_START"] = false,
					      ["SPELL_EMPOWER_END"] = false,
					      ["SPELL_EMPOWER_INTERRUPT"] = false,
					};
					sourceFlags = {
						[COMBATLOG_FILTER_MINE] = true
					};
					destFlags = nil;
				};
				[2] = {
					eventList = {
					      --["ENVIRONMENTAL_DAMAGE"] = true,
					      ["SWING_DAMAGE"] = true,
					      ["SWING_MISSED"] = true,
					      ["RANGE_DAMAGE"] = true,
					      ["RANGE_MISSED"] = true,
					      --["SPELL_CAST_START"] = true,
					      --["SPELL_CAST_SUCCESS"] = true,
					      --["SPELL_CAST_FAILED"] = true,
					      ["SPELL_MISSED"] = true,
					      ["SPELL_DAMAGE"] = true,
					      ["SPELL_HEAL"] = true,
					      ["SPELL_ENERGIZE"] = true,
					      ["SPELL_DRAIN"] = true,
					      ["SPELL_LEECH"] = true,
					      ["SPELL_INSTAKILL"] = true,
					      ["SPELL_INTERRUPT"] = true,
					      ["SPELL_EXTRA_ATTACKS"] = true,
					      --["SPELL_DURABILITY_DAMAGE"] = true,
					      --["SPELL_DURABILITY_DAMAGE_ALL"] = true,
					      --["SPELL_AURA_APPLIED"] = true,
					      --["SPELL_AURA_APPLIED_DOSE"] = true,
					      --["SPELL_AURA_REMOVED"] = true,
					      --["SPELL_AURA_REMOVED_DOSE"] = true,
					      ["SPELL_DISPEL"] = true,
					      ["SPELL_STOLEN"] = true,
					      ["ENCHANT_APPLIED"] = true,
					      ["ENCHANT_REMOVED"] = true,
					      --["SPELL_PERIODIC_MISSED"] = true,
					      --["SPELL_PERIODIC_DAMAGE"] = true,
					      --["SPELL_PERIODIC_HEAL"] = true,
					      --["SPELL_PERIODIC_ENERGIZE"] = true,
					      --["SPELL_PERIODIC_DRAIN"] = true,
					      --["SPELL_PERIODIC_LEECH"] = true,
					      ["SPELL_DISPEL_FAILED"] = true,
					      --["DAMAGE_SHIELD"] = true,
					      --["DAMAGE_SHIELD_MISSED"] = true,
					      ["DAMAGE_SPLIT"] = true,
					      ["PARTY_KILL"] = true,
					      ["UNIT_DIED"] = true,
					      ["UNIT_DESTROYED"] = true,
					      ["UNIT_DISSIPATES"] = true
					};
					sourceFlags = nil;
					destFlags =  {
						[COMBATLOG_FILTER_MINE] = false,
						[COMBATLOG_FILTER_MY_PET] = false;
					};
				};
			};
		};
		[2] = {
			-- Descriptive Information
			name = QUICKBUTTON_NAME_ME;
			hasQuickButton = true;
			quickButtonName = QUICKBUTTON_NAME_ME;
			quickButtonDisplay = {
				solo = true;
				party = true;
				raid = true;
			};
			tooltip = QUICKBUTTON_NAME_ME_TOOLTIP;

			-- Settings
			settings = CopyTable(COMBATLOG_DEFAULT_SETTINGS);

			-- Coloring
			colors = CopyTable(COMBATLOG_DEFAULT_COLORS);

			-- The actual client filters
			filters = {
				[1] = {
					eventList = {
					      ["ENVIRONMENTAL_DAMAGE"] = true,
					      ["SWING_DAMAGE"] = true,
					      ["RANGE_DAMAGE"] = true,
					      ["SPELL_DAMAGE"] = true,
					      ["SPELL_HEAL"] = true,
					      ["SPELL_PERIODIC_DAMAGE"] = true,
					      ["SPELL_PERIODIC_HEAL"] = true,
					      ["DAMAGE_SPLIT"] = true,
					      ["UNIT_DIED"] = true,
					      ["UNIT_DESTROYED"] = true,
					      ["UNIT_DISSIPATES"] = true
					};
					sourceFlags = Blizzard_CombatLog_GenerateFullFlagList(false);
					destFlags = nil;
				};
				[2] = {
					eventList = Blizzard_CombatLog_GenerateFullEventList();
					sourceFlags = nil;
					destFlags =  {
						[COMBATLOG_FILTER_MINE] = true,
						[COMBATLOG_FILTER_MY_PET] = false;
					};
				};
			};
		};
	};

	-- Current Filter
	currentFilter = 1;
};

Blizzard_CombatLog_Filters = Blizzard_CombatLog_Filter_Defaults;

-- Combat Log Filter Resetting Code
--
-- args:
-- 	config - the configuration array we are about to apply
--
function Blizzard_CombatLog_ApplyFilters(config)
	if ( not config ) then
		return;
	end
	CombatLogResetFilter()

	-- Loop over all associated filters
	local eventList;
	for k,v in pairs(config.filters) do
		local eList
		-- Only use the first filter's eventList because for some reason each filter that the player can see actually
		-- has two filters, one for source flags and one for dest flags (??), even though only the eventList for the source
		-- flags is updated properly
		eventList = config.filters[1].eventList;
		if ( eventList ) then
			for k2,v2 in pairs(eventList) do
				if ( v2 == true ) then
				-- The true comparison is because check boxes whose parent is unchecked will be non-false but not "true"
					eList = eList and (eList .. "," .. k2) or k2
				end
			end
		end

		local sourceFlags, destFlags;
		if ( v.sourceFlags ) then
			sourceFlags = 0;
			for k2, v2 in pairs(v.sourceFlags) do
				-- Support for GUIDs
				if ( type (k2) == "string" ) then
					sourceFlags = k2;
					break;
				end
				-- Otherwise OR bits
				if ( v2 ) then
					sourceFlags = bit_bor(sourceFlags, k2);
				end
			end
		end
		if ( v.destFlags ) then
			destFlags = 0;
			for k2, v2 in pairs(v.destFlags) do
				-- Support for GUIDs
				if ( type (k2) == "string" ) then
					destFlags = k2;
					break;
				end
				-- Otherwise OR bits
				if ( v2 ) then
					destFlags = bit_bor(destFlags, k2);
				end
			end
		end
		if ( type(sourceFlags) == "string" and destFlags == 0 ) then
			destFlags = nil;
		end
		if ( type(destFlags) == "string" and sourceFlags == 0 ) then
			sourceFlags = nil;
		end

		-- This is a HACK!!!  Need filters to be able to accept empty or zero sourceFlags or destFlags
		if ( sourceFlags == 0 or destFlags == 0 ) then
			CombatLogAddFilter("", COMBATLOG_FILTER_MINE, nil);
		else
			CombatLogAddFilter(eList, sourceFlags, destFlags);
		end
	end
end

--
-- Combat Log Repopulation Code
--

-- Message Limit

COMBATLOG_MESSAGE_LIMIT = 300;

--
-- Repopulate the combat log with message history
--
function Blizzard_CombatLog_Refilter()
	local count = CombatLogGetNumEntries();

	COMBATLOG:SetMaxLines(COMBATLOG_MESSAGE_LIMIT);

	-- count should be between 1 and COMBATLOG_MESSAGE_LIMIT
	count = max(1, min(count, COMBATLOG_MESSAGE_LIMIT));

	CombatLogSetCurrentEntry(0);

	-- Clear the combat log
	COMBATLOG:Clear();

	-- Moved setting the max value here, since we don't really need to reset the max every frame, do we?
	-- We can't add events while refiltering (:AddFilter short circuits) so this should be safe optimization.
	CombatLogQuickButtonFrameProgressBar:SetMinMaxValues(0, count);
	CombatLogQuickButtonFrameProgressBar:SetValue(0);
	CombatLogQuickButtonFrameProgressBar:Show();

	-- Enable the distributed frame
	CombatLogUpdateFrame.refiltering = true;
	CombatLogUpdateFrame:SetScript("OnUpdate", Blizzard_CombatLog_RefilterUpdate)

	Blizzard_CombatLog_RefilterUpdate()
end

--
-- This is a single frame "step" in the refiltering process
--
function Blizzard_CombatLog_RefilterUpdate()
	local valid = CombatLogGetCurrentEntry(); -- CombatLogAdvanceEntry(0);

	-- Clear the combat log
	local total = 0;
	while (valid and total < COMBATLOG_LIMIT_PER_FRAME) do
		local show = CombatLogShowCurrentEntry();
		if (show) then
			-- Log to the window
			local text, r, g, b, a = CombatLog_OnEvent(Blizzard_CombatLog_CurrentSettings, CombatLogGetCurrentEntry());
			-- NOTE: be sure to pass in nil for the color id or the color id may override the r, g, b values for this message
			if ( text ) then
				COMBATLOG:BackFillMessage(text, r, g, b);
			end
		end

		-- count can be
		--  positive to advance from oldest to newest
		--  negative to advance from newest to oldest
		valid = CombatLogAdvanceEntry(-1)
		total = total + 1;
	end

	-- Show filtering progress bar
	CombatLogQuickButtonFrameProgressBar:SetValue(CombatLogQuickButtonFrameProgressBar:GetValue() + total);

	if ( not valid or (CombatLogQuickButtonFrameProgressBar:GetValue() >= COMBATLOG_MESSAGE_LIMIT) ) then
		CombatLogUpdateFrame.refiltering = false
		CombatLogUpdateFrame:SetScript("OnUpdate", nil)
		CombatLogQuickButtonFrameProgressBar:Hide();
	end
end

--
-- Checks for an event over all filters
--
function Blizzard_CombatLog_HasEvent ( settings, ... )
	-- If this actually happens, we have data corruption issues.
	if ( not settings.filters ) then
		settings.filters = {}
	end
	for _, filter in pairs (settings.filters) do
		if ( filter.eventList ) then
			for i = 1, select("#", ...) do
				local event = select(i, ...)
				if ( filter.eventList[event] == true ) then
					return true
				end
			end
		end
	end
end

--
-- Checks for an event over all filters
--
function Blizzard_CombatLog_EnableEvent ( settings, ... )
	-- If this actually happens, we have data corruption issues.
	if ( not settings.filters ) then
		settings.filters = Blizzard_CombatLog_InitializeFilters( settings );
	end
	for _, filter in pairs (settings.filters) do
		if ( not filter.eventList ) then
			filter.eventList = {};
		end

		for i = 1, select("#", ...) do
			filter.eventList[select(i, ...)] = true;
		end
	end
end

--
-- Checks for an event over all filters
--
function Blizzard_CombatLog_DisableEvent ( settings, ... )
	-- If this actually happens, we have data corruption issues.
	if ( not settings.filters ) then
		settings.filters = {}
	end
	for _, filter in pairs (settings.filters) do
		if ( filter.eventList ) then
			for i = 1, select("#", ...) do
				filter.eventList[select(i, ...)] = false;
			end
		end
	end
end

--
-- Creates the action menu popup
--
do
	local eventType
	local actionMenu = {
		[1] = {
			text = "string.format(BLIZZARD_COMBAT_LOG_MENU_SPELL_HIDE, eventType)",
			func = function () Blizzard_CombatLog_SpellMenuClick ("HIDE",  nil, nil, eventType); end;
		},
	};
	function Blizzard_CombatLog_CreateActionMenu(eventType_arg)
		-- Update upvalues
		eventType = eventType_arg
		actionMenu[1].text = string.format(BLIZZARD_COMBAT_LOG_MENU_SPELL_HIDE, eventType_arg);
		return actionMenu
	end
end

--
-- Creates the spell menu popup
--
do
	local spellName, spellId, eventType
	local spellMenu = {
		[1] = {
			text = "string.format(BLIZZARD_COMBAT_LOG_MENU_SPELL_LINK, spellName)",
			func = function () Blizzard_CombatLog_SpellMenuClick ("LINK", spellName, spellId, eventType); end;
		},
	};
	local spellMenu2 = {
		[2] = {
			text = "string.format(BLIZZARD_COMBAT_LOG_MENU_SPELL_HIDE, eventType)",
			func = function () Blizzard_CombatLog_SpellMenuClick ("HIDE", spellName, spellId, eventType); end;
		},
		[3] = {
			text = "------------------";
			disabled = true;
		},
	};
	function Blizzard_CombatLog_CreateSpellMenu(spellName_arg, spellId_arg, eventType_arg)
		-- Update upvalues
		spellName, spellId, eventType = spellName_arg, spellId_arg, eventType_arg;
		-- Update menu text and filters
		spellMenu[1].text = string.format(BLIZZARD_COMBAT_LOG_MENU_SPELL_LINK, spellName);
		if ( eventType ) then
			spellMenu2[2].text = string.format(BLIZZARD_COMBAT_LOG_MENU_SPELL_HIDE, eventType);
			-- Copy the table references over
			spellMenu[2] = spellMenu2[2];
			if ( DEBUG ) then
				spellMenu[3] = spellMenu2[3];
				-- These 2 calls update the menus in their respective do-end blocks
				spellMenu[4] = Blizzard_CombatLog_FormattingMenu(Blizzard_CombatLog_Filters.currentFilter);
				spellMenu[5] = Blizzard_CombatLog_MessageTypesMenu(Blizzard_CombatLog_Filters.currentFilter);
			end
		else
			-- Remove the table references, they are still stored in their various closures
			spellMenu[2] = nil;
			spellMenu[3] = nil;
			spellMenu[4] = nil;
			spellMenu[5] = nil;
		end
		return spellMenu;
	end
end

--
-- Temporary Menu
--
do
	-- This big table currently only has one upvalue: Blizzard_CombatLog_CurrentSettings
	local messageTypesMenu = {
		text = "Message Types";
		hasArrow = true;
		menuList = {
			[1] = {
				text = "Melee";
				hasArrow = true;
				checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SWING_DAMAGE", "SWING_MISSED"); end;
				keepShownOnClick = true;
				func = function ( self, arg1, arg2, checked )
					Blizzard_CombatLog_MenuHelper ( checked, "SWING_DAMAGE", "SWING_MISSED" );
				end;
				menuList = {
					[1] = {
						text = "Damage";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SWING_DAMAGE");end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SWING_DAMAGE" );
						end;
					};
					[2] = {
						text = "Failure";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SWING_MISSED"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SWING_MISSED" );
						end;
					};
				};
			};
			[2] = {
				text = "Ranged";
				hasArrow = true;
				checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "RANGE_DAMAGE", "RANGE_MISSED"); end;
				keepShownOnClick = true;
				func = function ( self, arg1, arg2, checked )
					Blizzard_CombatLog_MenuHelper ( checked, "RANGED_DAMAGE", "RANGED_MISSED" );
				end;
				menuList = {
					[1] = {
						text = "Damage";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "RANGE_DAMAGE"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "RANGE_DAMAGE" );
						end;
					};
					[2] = {
						text = "Failure";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "RANGE_MISSED"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "RANGE_MISSED" );
						end;
					};
				};
			};
			[3] = {
				text = "Spells";
				hasArrow = true;
				checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_DAMAGE", "SPELL_MISSED", "SPELL_HEAL", "SPELL_ENERGIZE", "SPELL_DRAIN", "SPELL_LEECH", "SPELL_INTERRUPT", "SPELL_EXTRA_ATTACKS",  "SPELL_CAST_START", "SPELL_CAST_SUCCESS", "SPELL_CAST_FAILED", "SPELL_INSTAKILL", "SPELL_DURABILITY_DAMAGE" ); end;
				keepShownOnClick = true;
				func = function ( self, arg1, arg2, checked )
					Blizzard_CombatLog_MenuHelper ( checked, "SPELL_DAMAGE", "SPELL_MISSED", "SPELL_HEAL", "SPELL_ENERGIZE", "SPELL_DRAIN", "SPELL_LEECH", "SPELL_INTERRUPT", "SPELL_EXTRA_ATTACKS",  "SPELL_CAST_START", "SPELL_CAST_SUCCESS", "SPELL_CAST_FAILED", "SPELL_INSTAKILL", "SPELL_DURABILITY_DAMAGE" );
				end;
				menuList = {
					[1] = {
						text = "Damage";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_DAMAGE"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_DAMAGE" );
						end;
					};
					[2] = {
						text = "Failure";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_MISSED"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_MISSED" );
						end;
					};
					[3] = {
						text = "Heals";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_HEAL"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_HEAL" );
						end;
					};
					[4] = {
						text = "Power Gains";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_ENERGIZE"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_ENERGIZE" );
						end;
					};
					[4] = {
						text = "Drains";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_DRAIN", "SPELL_LEECH"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_DRAIN", "SPELL_LEECH" );
						end;
					};
					[5] = {
						text = "Interrupts";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_INTERRUPT"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_INTERRUPT" );
						end;
					};
					[6] = {
						text = "Extra Attacks";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_EXTRA_ATTACKS"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_EXTRA_ATTACKS" );
						end;
					};
					[7] = {
						text = "Casting";
						hasArrow = true;
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_CAST_START", "SPELL_CAST_SUCCESS", "SPELL_CAST_FAILED"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_CAST_START", "SPELL_CAST_SUCCESS", "SPELL_CAST_FAILED");
						end;
						menuList = {
							[1] = {
								text = "Start";
								checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_CAST_START"); end;
								keepShownOnClick = true;
								func = function ( self, arg1, arg2, checked )
									Blizzard_CombatLog_MenuHelper ( checked, "SPELL_CAST_START" );
								end;
							};
							[2] = {
								text = "Success";
								checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_CAST_SUCCESS"); end;
								keepShownOnClick = true;
								func = function ( self, arg1, arg2, checked )
									Blizzard_CombatLog_MenuHelper ( checked, "SPELL_CAST_SUCCESS" );
								end;
							};
							[3] = {
								text = "Failed";
								checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_CAST_FAILED"); end;
								keepShownOnClick = true;
								func = function ( self, arg1, arg2, checked )
									Blizzard_CombatLog_MenuHelper ( checked, "SPELL_CAST_FAILED" );
								end;
							};
						};
					};
					[8] = {
						text = "Special";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_INSTAKILL", "SPELL_DURABILITY_DAMAGE"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_INSTAKILL", "SPELL_DURABILITY_DAMAGE" );
						end;
					};
				};
			};
			[4] = {
				text = "Auras";
				hasArrow = true;
				checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_AURA_APPLIED", "SPELL_AURA_BROKEN", "SPELL_AURA_REFRESH", "SPELL_AURA_BROKEN_SPELL", "SPELL_AURA_APPLIED_DOSE", "SPELL_AURA_REMOVED", "SPELL_AURA_REMOVED_DOSE", "SPELL_DISPEL", "SPELL_STOLEN",  "ENCHANT_APPLIED",  "ENCHANT_REMOVED" ); end;
				keepShownOnClick = true;
				func = function ( self, arg1, arg2, checked )
					Blizzard_CombatLog_MenuHelper ( checked, "SPELL_AURA_APPLIED", "SPELL_AURA_BROKEN", "SPELL_AURA_REFRESH", "SPELL_AURA_BROKEN_SPELL", "SPELL_AURA_APPLIED_DOSE", "SPELL_AURA_REMOVED", "SPELL_AURA_REMOVED_DOSE", "SPELL_DISPEL", "SPELL_STOLEN",  "ENCHANT_APPLIED", "ENCHANT_REMOVED" );
				end;
				menuList = {
					[1] = {
						text = "Applied";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_AURA_APPLIED", "SPELL_AURA_BROKEN", "SPELL_AURA_REFRESH", "SPELL_AURA_BROKEN_SPELL", "SPELL_AURA_APPLIED_DOSE"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_AURA_APPLIED", "SPELL_AURA_BROKEN", "SPELL_AURA_REFRESH", "SPELL_AURA_BROKEN_SPELL", "SPELL_AURA_APPLIED_DOSE",  "ENCHANT_APPLIED" );
						end;
					};
					[2] = {
						text = "Removed";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_AURA_REMOVED", "SPELL_AURA_REMOVED_DOSE",  "ENCHANT_REMOVED" ); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_AURA_REMOVED", "SPELL_AURA_REMOVED_DOSE" );
						end;
					};
					[3] = {
						text = "Dispelled";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_DISPEL"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_DISPEL" );
						end;
					};
					[4] = {
						text = "Stolen";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_STOLEN"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_STOLEN" );
						end;
					};
				};
			};
			[5] = {
				text = "Periodics";
				hasArrow = true;
				checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_PERIODIC_DAMAGE", "SPELL_PERIODIC_MISSED", "SPELL_PERIODIC_DRAIN", "SPELL_PERIODIC_ENERGIZE", "SPELL_PERIODIC_HEAL", "SPELL_PERIODIC_LEECH" ); end;
				keepShownOnClick = true;
				func = function ( self, arg1, arg2, checked )
					Blizzard_CombatLog_MenuHelper ( checked, "SPELL_PERIODIC_DAMAGE", "SPELL_PERIODIC_MISSED", "SPELL_PERIODIC_DRAIN", "SPELL_PERIODIC_ENERGIZE", "SPELL_PERIODIC_HEAL", "SPELL_PERIODIC_LEECH" );
				end;
				menuList = {
					[1] = {
						text = "Damage";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_PERIODIC_DAMAGE"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_PERIODIC_DAMAGE" );
						end;
					};
					[2] = {
						text = "Failure";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_PERIODIC_MISSED" ); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_PERIODIC_MISSED" );
						end;
					};
					[3] = {
						text = "Heals";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_PERIODIC_HEAL"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_PERIODIC_HEAL" );
						end;
					};
					[4] = {
						text = "Other";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_PERIODIC_DRAIN", "SPELL_PERIODIC_ENERGIZE", "SPELL_PERIODIC_LEECH"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_PERIODIC_DRAIN", "SPELL_PERIODIC_ENERGIZE", "SPELL_PERIODIC_LEECH" );
						end;
					};
				};
			};
			[6] = {
				text = "Other";
				hasArrow = true;
				checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "PARTY_KILL", "UNIT_DIED", "UNIT_DESTROYED", "UNIT_DISSIPATES", "DAMAGE_SPLIT", "ENVIRONMENTAL_DAMAGE" ); end;
				keepShownOnClick = true;
				func = function ( self, arg1, arg2, checked )
					Blizzard_CombatLog_MenuHelper ( checked, "PARTY_KILL", "UNIT_DIED", "UNIT_DESTROYED", "UNIT_DISSIPATES", "DAMAGE_SPLIT", "ENVIRONMENTAL_DAMAGE"  );
				end;
				menuList = {
					[1] = {
						text = "Kills";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "PARTY_KILL"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "PARTY_KILL" );
						end;
					};
					[2] = {
						text = "Deaths";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "UNIT_DIED", "UNIT_DESTROYED", "UNIT_DISSIPATES"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "UNIT_DIED", "UNIT_DESTROYED", "UNIT_DISSIPATES" );
						end;
					};
					[3] = {
						text = "Damage Split";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "DAMAGE_SPLIT"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "DAMAGE_SPLIT" );
						end;
					};
					[4] = {
						text = "Environmental Damage";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "ENVIRONMENTAL_DAMAGE"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "ENVIRONMENTAL_DAMAGE" );
						end;
					};
				};
			};
		};
	};
	-- functions I see do pass in arguments, update upvalues as necessary.
	function Blizzard_CombatLog_MessageTypesMenu()
		return messageTypesMenu;
	end
end

--
-- Temporary Menu
--
do
	local filterId
	local filter
	local currentFilter
	local formattingMenu = {
		text = "Formatting";
		hasArrow = true;
		menuList = {
			{
				text = "Full Text";
				checked = function() return filter.fullText; end;
				func = function(self, arg1, arg2, checked)
					filter.fullText = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Timestamp";
				checked = function() return filter.timestamp; end;
				func = function(self, arg1, arg2, checked)
					filter.timestamp = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Unit Name Coloring";
				checked = function() return filter.unitColoring; end;
				func = function(self, arg1, arg2, checked)
					filter.unitColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Line Coloring";
				checked = function() return  filter.lineColoring; end;
				func = function(self, arg1, arg2, checked)
					filter.lineColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Line Highlighting";
				checked = function() return  filter.lineHighlighting; end;
				func = function(self, arg1, arg2, checked)
					filter.lineHighlighting = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Ability Coloring";
				checked = function() return filter.abilityColoring; end;
				func = function(self, arg1, arg2, checked)
					filter.abilityColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Ability-by-School Coloring";
				checked = function() return filter.abilitySchoolColoring; end;
				--disabled = not filter.abilityColoring;
				func = function(self, arg1, arg2, checked)
					filter.abilitySchoolColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Ability-by-Actor Coloring";
				checked = function() return filter.abilityActorColoring; end;
				func = function(self, arg1, arg2, checked)
					filter.abilityActorColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Ability Highlighting";
				checked = function() return filter.abilityHighlighting; end;
				func = function(self, arg1, arg2, checked)
					filter.abilityHighlighting = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Action Coloring";
				checked = function() return filter.actionColoring; end;
				func = function(self, arg1, arg2, checked)
					filter.actionColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Action-by-School Coloring";
				checked = function() return filter.actionSchoolColoring; end;
				func = function(self, arg1, arg2, checked)
					filter.actionSchoolColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Action-by-Actor Coloring";
				checked = function() return filter.actionActorColoring; end;
				--disabled = not filter.abilityColoring;
				func = function(self, arg1, arg2, checked)
					filter.actionActorColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Action Highlighting";
				checked = function() return filter.actionHighlighting; end;
				--disabled = not filter.abilityColoring;
				func = function(self, arg1, arg2, checked)
					filter.actionHighlighting = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Damage Coloring";
				checked = function() return filter.amountColoring; end;
				func = function(self, arg1, arg2, checked)
					filter.amountColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Damage-by-School Coloring";
				checked = function() return filter.amountSchoolColoring; end;
				--disabled = not filter.amountColoring;
				func = function(self, arg1, arg2, checked)
					filter.amountSchoolColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Damage-by-Actor Coloring";
				checked = function() return filter.amountActorColoring; end;
				--disabled = not filter.amountColoring;
				func = function(self, arg1, arg2, checked)
					filter.amountActorColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Damage Highlighting";
				checked = function() return filter.amountHighlighting; end;
				func = function(self, arg1, arg2, checked)
					filter.amountHighlighting = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Color School Names";
				checked = function() return filter.schoolNameColoring; end;
				func = function(self, arg1, arg2, checked)
					filter.schoolNameColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "School Name Highlighting";
				checked = function() return filter.schoolNameHighlighting; end;
				func = function(self, arg1, arg2, checked)
					filter.schoolNameHighlighting = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "White Swing Rule";
				checked = function() return filter.noMeleeSwingColoring; end;
				func = function(self, arg1, arg2, checked)
					filter.noMeleeSwingColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Misses Colored Rule";
				checked = function() return filter.missColoring; end;
				func = function(self, arg1, arg2, checked)
					filter.missColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Braces";
				checked = function() return filter.braces; end;
				func = function(self, arg1, arg2, checked)
					filter.braces = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Refiltering";
				checked = function() return filter.showHistory; end;
				func = function(self, arg1, arg2, checked)
					filter.showHistory = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
				tooltipTitle = "Refiltering";
				tooltipText = "This clears the chat frame and refills it with the last 500 events.";
			},
		};
	};
	function Blizzard_CombatLog_FormattingMenu(filterId_arg)
		-- Update upvalues
		filterId = filterId_arg;
		filter = Blizzard_CombatLog_Filters.filters[filterId].settings;
		currentFilter = Blizzard_CombatLog_Filters.currentFilter;
		return formattingMenu;
	end
end

--
-- Menu Option Helper Function
--
function Blizzard_CombatLog_MenuHelper ( checked, ... )
	if ( not checked ) then
		Blizzard_CombatLog_DisableEvent (Blizzard_CombatLog_CurrentSettings, ...);
	else
		Blizzard_CombatLog_EnableEvent (Blizzard_CombatLog_CurrentSettings, ...);
	end
	Blizzard_CombatLog_ApplyFilters(Blizzard_CombatLog_CurrentSettings);
	if ( Blizzard_CombatLog_CurrentSettings.settings.showHistory ) then
		Blizzard_CombatLog_Refilter();
	end
end;

--
-- Blizzard_CombatLog_CreateTabMenu
--
-- 	Creates a context sensitive menu based on the current quick button
--
-- args:
-- 	settingsIndex - the filter settings to use
--
do
	local filterId
	local unitName, unitGUID, special
	local tabMenu = {
		[1] = {
			text = BLIZZARD_COMBAT_LOG_MENU_EVERYTHING;
			func = function () Blizzard_CombatLog_UnitMenuClick ("EVERYTHING", unitName, unitGUID, special); end;
		},
		[2] = {
			text = BLIZZARD_COMBAT_LOG_MENU_SAVE;
			func = function () Blizzard_CombatLog_UnitMenuClick ("SAVE", unitName, unitGUID, special); end;
		},
		[3] = {
			text = BLIZZARD_COMBAT_LOG_MENU_RESET;
			func = function () Blizzard_CombatLog_UnitMenuClick ("RESET", unitName, unitGUID, special); end;
		},
		[4] = {
			text = "--------- Temporary Adjustments ---------";
			disabled = true;
		},
	};
	function Blizzard_CombatLog_CreateTabMenu ( filterId_arg )
		-- Update upvalues
		filterId = filterId_arg

		-- Update menus
		tabMenu[2].disabled = (Blizzard_CombatLog_PreviousSettings == Blizzard_CombatLog_CurrentSettings)
		tabMenu[5] = Blizzard_CombatLog_FormattingMenu(filterId);
		tabMenu[6] = Blizzard_CombatLog_MessageTypesMenu(filterId);
		return tabMenu;
	end
end


--
-- Temporary Menu
--
do
	function Blizzard_CombatLog_CreateUnitMenu(unitName, unitGUID, special)
		local displayName = unitName;
		if ( (unitGUID == UnitGUID("player")) and (_G["COMBAT_LOG_UNIT_YOU_ENABLED"] == "1") ) then
			displayName = UNIT_YOU;
		end
		local unitMenu = {
			[1] = {
				text = string.format(BLIZZARD_COMBAT_LOG_MENU_BOTH, displayName); -- Dummy text
				func = function () Blizzard_CombatLog_UnitMenuClick ("BOTH", unitName, unitGUID, special); end;
			},
			[2] = {
				text = string.format(BLIZZARD_COMBAT_LOG_MENU_INCOMING, displayName);
				func = function () Blizzard_CombatLog_UnitMenuClick ("INCOMING", unitName, unitGUID, special); end;
			},
			[3] = {
				text = string.format(BLIZZARD_COMBAT_LOG_MENU_OUTGOING, displayName);
				func = function () Blizzard_CombatLog_UnitMenuClick ("OUTGOING", unitName, unitGUID, special); end;
			},
			[4] = {
				text = "------------------";
				disabled = true;
			},
			[5] = {
				text = BLIZZARD_COMBAT_LOG_MENU_EVERYTHING;
				func = function () Blizzard_CombatLog_UnitMenuClick ("EVERYTHING", unitName, unitGUID, special); end;
			},
			[6] = {
				text = BLIZZARD_COMBAT_LOG_MENU_SAVE;
				func = function () Blizzard_CombatLog_UnitMenuClick ("SAVE", unitName, unitGUID, special); end;
				disabled = not CanCreateFilters();
			},
			[7] = {
				text = BLIZZARD_COMBAT_LOG_MENU_RESET;
				func = function () Blizzard_CombatLog_UnitMenuClick ("RESET", unitName, unitGUID, special); end;
			},
		};
		--[[
		-- These 2 calls update the menus in their respective do-end blocks
		unitMenu[9] = Blizzard_CombatLog_FormattingMenu(Blizzard_CombatLog_Filters.currentFilter);
		unitMenu[10] = Blizzard_CombatLog_MessageTypesMenu(Blizzard_CombatLog_Filters.currentFilter);
		]]

		if ( unitGUID ~= UnitGUID("player") ) then
			table.insert(unitMenu, 4, {
				text = string.format(BLIZZARD_COMBAT_LOG_MENU_OUTGOING_ME, displayName);
				func = function () Blizzard_CombatLog_UnitMenuClick ("OUTGOING_ME", unitName, unitGUID, special); end;
			} );
		end
		return unitMenu
	end
end
-- Create additional filter dropdown list
do
	local menu = {};
	function Blizzard_CombatLog_CreateFilterMenu()
		local count = 1;
		for index, value in pairs(menu) do
			if ( not value ) then
				value = {};
			else
				for k, v in pairs(value) do
					value[k] = nil;
				end
			end
		end
		local selectedIndex = Blizzard_CombatLog_Filters.currentFilter;
		local checked;
		for index, value in ipairs(Blizzard_CombatLog_Filters.filters) do
			if ( not value.onQuickBar ) then
				if ( not menu[count] ) then
					menu[count] = {};
				end
				menu[count].text = value.name;
				menu[count].func = function () Blizzard_CombatLog_QuickButton_OnClick(index); end;
				if ( selectedIndex == index ) then
					checked = 1;
				else
					checked = nil;
				end
				menu[count].checked =  checked;
				count = count+1;
			end
		end
		return menu;
	end
end
--
-- Handle mini menu clicks
--
-- args:
-- 	event - "EVERYTHING" | "RESET" | "INCOMING" | "OUTGOING" | "BOTH"
-- 	unitName - string for the units name
-- 	unitGUID - unique global unit ID for the specific unit
-- 	special - bit code for special filters, such as raid targets
--
function Blizzard_CombatLog_UnitMenuClick(event, unitName, unitGUID, unitFlags)

--	ChatFrame1:AddMessage("Event: "..event.." N: "..tostring(unitName).." GUID: "..tostring(unitGUID).." Flags: "..tostring(unitFlags));
--
-- This code was for the context menus to support different formatting criteria
--
--	-- Apply the correct settings.
--	if ( Blizzard_CombatLog_Filters.contextMenu[event] ) then
--		Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_Filters.contextMenu[event]
--	end

	-- I'm not sure if we really want this feature for live
	if ( event == "REVERT" ) then
		local temp = Blizzard_CombatLog_CurrentSettings;
		Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_PreviousSettings;
		Blizzard_CombatLog_PreviousSettings = temp;
		temp = nil;

		-- Apply the old filters
		Blizzard_CombatLog_ApplyFilters(Blizzard_CombatLog_CurrentSettings);

	elseif ( event == "SAVE" ) then
		local dialog = StaticPopup_Show("COPY_COMBAT_FILTER");
		dialog.data = Blizzard_CombatLog_CurrentSettings;

		return;
	elseif ( event == "RESET" ) then
		Blizzard_CombatLog_PreviousSettings = Blizzard_CombatLog_CurrentSettings;
		Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_Filters.filters[Blizzard_CombatLog_Filters.currentFilter];
		Blizzard_CombatLog_ApplyFilters(Blizzard_CombatLog_CurrentSettings);
	else
		-- Copy the current settings
		Blizzard_CombatLog_PreviousSettings = Blizzard_CombatLog_CurrentSettings;
		Blizzard_CombatLog_CurrentSettings = {};

		for k,v in pairs( Blizzard_CombatLog_PreviousSettings ) do
			Blizzard_CombatLog_CurrentSettings[k] = v;
		end


		-- Erase the filter criteria
		Blizzard_CombatLog_CurrentSettings.filters = {};  -- We want to be careful not to destroy the active data, so the user can reset

		if ( event == "EVERYTHING" ) then
			-- Reset all filtering.
			CombatLogResetFilter()
			--Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_Filters.contextMenu[event];
			CombatLogAddFilter(nil, nil, nil)
			tinsert ( Blizzard_CombatLog_CurrentSettings.filters, {} );
		end
		if ( event == "INCOMING" or event == "BOTH" ) then
			if ( unitFlags ) then
				tinsert ( Blizzard_CombatLog_CurrentSettings.filters, { destFlags = { [unitFlags] = true; } } );
			else
				tinsert ( Blizzard_CombatLog_CurrentSettings.filters, { destFlags = { [unitGUID] = true; } } );
			end
		end
		if ( event == "OUTGOING" or event == "BOTH" ) then
			if ( unitFlags ) then
				tinsert ( Blizzard_CombatLog_CurrentSettings.filters, { sourceFlags = { [unitFlags] = true; } } );
			else
				tinsert ( Blizzard_CombatLog_CurrentSettings.filters, { sourceFlags = { [unitGUID] = true; } } );
			end
		end
		if ( event == "OUTGOING_ME" ) then
			if ( unitFlags ) then
				tinsert ( Blizzard_CombatLog_CurrentSettings.filters, { sourceFlags = { [unitFlags] = true; }; destFlags = { [COMBATLOG_FILTER_MINE] = true; } } );
			else
				tinsert ( Blizzard_CombatLog_CurrentSettings.filters, { sourceFlags = { [unitGUID] = true; }; destFlags = { [COMBATLOG_FILTER_MINE] = true; } } );
			end
		end

		-- If the context menu is not resetting, then we need to create an event list,
		-- So that right click removal works when the user right clicks
		--

		-- Fill the event list
		local fullEventList = Blizzard_CombatLog_GenerateFullEventList();

		-- Insert to the active data
		for k,v in pairs (Blizzard_CombatLog_CurrentSettings.filters) do
			v.eventList = fullEventList;
		end

		-- Apply the generated filters
		Blizzard_CombatLog_ApplyFilters(Blizzard_CombatLog_CurrentSettings);
		-- Let the system know that this filter is temporary and unhighlight any quick buttons
		Blizzard_CombatLog_CurrentSettings.isTemp = true;
		Blizzard_CombatLog_Update_QuickButtons()
	end

	-- Reset the combat log text box! (Grats!)
	Blizzard_CombatLog_Refilter();
end

--
-- Shows a simplified version of the menu if you right click on the quick button
--
-- This function isn't used anywhere yet. The QuickButtons doesn't have a event handler for right click yet.
function Blizzard_CombatLog_QuickButtonRightClick(event, filterId)

	-- I'm not sure if we really want this feature for live
	if ( event == "REVERT" ) then
		local temp = Blizzard_CombatLog_CurrentSettings;
		Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_PreviousSettings;
		Blizzard_CombatLog_PreviousSettings = temp;
		temp = nil;

		-- Apply the old filters
		Blizzard_CombatLog_ApplyFilters(Blizzard_CombatLog_CurrentSettings);

	elseif ( event == "RESET" ) then
		Blizzard_CombatLog_PreviousSettings = Blizzard_CombatLog_CurrentSettings;
		Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_Filters.filters[filterId];
		--CombatLogAddFilter(nil, nil, COMBATLOG_FILTER_MINE)
		--CombatLogAddFilter(nil, COMBATLOG_FILTER_MINE, nil)
	else
		-- Copy the current settings
		Blizzard_CombatLog_PreviousSettings = Blizzard_CombatLog_CurrentSettings;

		Blizzard_CombatLog_CurrentSettings = {};

		for k,v in pairs( Blizzard_CombatLog_Filters.filters[filterId] ) do
			Blizzard_CombatLog_CurrentSettings[k] = v;
		end

		-- Erase the filter criteria
		Blizzard_CombatLog_CurrentSettings.filters = {};  -- We want to be careful not to destroy the active data, so the user can reset

		if ( event == "EVERYTHING" ) then
			CombatLogAddFilter(nil, nil, nil)
			table.insert ( Blizzard_CombatLog_CurrentSettings.filters, {} );
		end

		-- If the context menu is not resetting, then we need to create an event list,
		-- So that right click removal works when the user right clicks
		--

		-- Fill the event list
		local fullEventList = Blizzard_CombatLog_GenerateFullEventList();

		-- Insert to the active data
		for k,v in pairs (Blizzard_CombatLog_CurrentSettings.filters) do
			v.eventList = fullEventList;
		end

		-- Apply the generated filters
		Blizzard_CombatLog_ApplyFilters(Blizzard_CombatLog_CurrentSettings);
	end

	-- Reset the combat log text box! (Grats!)
	Blizzard_CombatLog_Refilter();

end

--
-- Handle spell mini menu clicks
-- args:
-- 	action - "HIDE" | "LINK"
--	spellName - Spell or ability's name
--	spellId - Spell or ability's id (100, 520, 30000, etc)
--	event - the event type that generated this message
--
function Blizzard_CombatLog_SpellMenuClick(action, spellName, spellId, eventType)
	if ( action == "HIDE" ) then
		for k,v in pairs (Blizzard_CombatLog_CurrentSettings.filters) do
			if ( type (v.eventList) ~= "table" ) then
				v.eventList = Blizzard_CombatLog_GenerateFullEventList();
			end
			v.eventList[eventType] = false;
		end
	elseif ( action == "LINK" ) then
		local spellLink = GetSpellLink(spellId);

		if ( ChatEdit_GetActiveWindow() ) then
			ChatEdit_InsertLink(spellLink);
		else
			ChatFrame_OpenChat(spellLink);
		end
		return;
	end

	-- Apply the newly reconstituted filters
	Blizzard_CombatLog_ApplyFilters(Blizzard_CombatLog_CurrentSettings);

	-- Reset the combat log text box! (Grats!)
	Blizzard_CombatLog_Refilter();
end

--
-- Temporary Settings
--
Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_Filters.filters[1];
Blizzard_CombatLog_PreviousSettings = Blizzard_CombatLog_CurrentSettings;
local Blizzard_CombatLog_UnitTokens = {};

--[[
--	Converts 4 floats into FF code
--
--]]
local function CombatLog_Color_FloatToText(r,g,b,a)
	if ( type(r) == "table" ) then
		r, g, b, a = r.r, r.g, r.b, r.a;
	end
	a = min(1, a or 1) * 255
	r = min(1, r) * 255
	g = min(1, g) * 255
	b = min(1, b) * 255

	-- local fmt = "%.2x";
	return ("%.2x%.2x%.2x%.2x"):format(math_floor(a), math_floor(r), math_floor(g), math_floor(b))
end
_G.CombatLog_Color_FloatToText = CombatLog_Color_FloatToText


--
--	Gets the appropriate color for an event type
--

-- If this needs to return a new table per event (ie, the table gets modified), then just replace the "defaultColorArray" in the function with
-- a new table creation.
local defaultColorArray = {a=1.0,r=0.5,g=0.5,b=0.5}
local function CombatLog_Color_ColorArrayByEventType( event )
	return Blizzard_CombatLog_CurrentSettings.colors.eventColoring[event] or defaultColorArray
end
_G.CombatLog_Color_ColorArrayByEventType = CombatLog_Color_ColorArrayByEventType

--
--	Gets the appropriate color for a unit type
--

local function CombatLog_Color_ColorArrayByUnitType(unitFlags, settings)
	local array = nil;
	if ( not settings ) then
		settings = Blizzard_CombatLog_CurrentSettings;
	end
	for mask,colorArray in pairs( settings.colors.unitColoring ) do
		if ( CombatLog_Object_IsA (unitFlags, mask) )then
			array = colorArray;
			break;
		end
	end
	return array or defaultColorArray
end
_G.CombatLog_Color_ColorArrayByUnitType = CombatLog_Color_ColorArrayByUnitType

--
--	Gets the appropriate color for a  spell school
--
local function CombatLog_Color_ColorArrayBySchool(school, settings)
	if ( not settings ) then
		settings = Blizzard_CombatLog_CurrentSettings;
	end
	if ( not school ) then
		return settings.colors.schoolColoring.default;
	end

	return settings.colors.schoolColoring[school] or settings.colors.defaults.spell;
end
_G.CombatLog_Color_ColorArrayBySchool = CombatLog_Color_ColorArrayBySchool

--
--	Gets the appropriate color for a  spell school
--

local highlightColorTable = {}
local function CombatLog_Color_HighlightColorArray(colorArray)
	highlightColorTable.r = colorArray.r * COMBATLOG_HIGHLIGHT_MULTIPLIER;
	highlightColorTable.g = colorArray.g * COMBATLOG_HIGHLIGHT_MULTIPLIER;
	highlightColorTable.b = colorArray.b * COMBATLOG_HIGHLIGHT_MULTIPLIER;
	highlightColorTable.a = colorArray.a;

	return highlightColorTable
end
_G.CombatLog_Color_HighlightColorArray = CombatLog_Color_HighlightColorArray

--
-- Returns a string associated with a numeric power type
--

local powerTypeToStringLookup =
{
	[Enum.PowerType.Mana] = MANA,
	[Enum.PowerType.Rage] = RAGE,
	[Enum.PowerType.Focus] = FOCUS,
	[Enum.PowerType.Energy] = ENERGY,
	[Enum.PowerType.ComboPoints] = COMBO_POINTS,
	[Enum.PowerType.Runes] = RUNES,
	[Enum.PowerType.RunicPower] = RUNIC_POWER,
	[Enum.PowerType.SoulShards] = SOUL_SHARDS,
	[Enum.PowerType.LunarPower] = LUNAR_POWER,
	[Enum.PowerType.HolyPower] = HOLY_POWER,
	[Enum.PowerType.Maelstrom] = MAELSTROM_POWER,
	[Enum.PowerType.Chi] = CHI_POWER,
	[Enum.PowerType.Insanity] = INSANITY_POWER,
	[Enum.PowerType.ArcaneCharges] = ARCANE_CHARGES_POWER,
	[Enum.PowerType.Fury] = FURY,
	[Enum.PowerType.Pain] = PAIN,
	[Enum.PowerType.Essence] = POWER_TYPE_ESSENCE,
};

local alternatePowerEnumValue = Enum.PowerType.Alternate; -- Upvalue for marginally faster access.

local function CombatLog_String_PowerType(powerType, amount, alternatePowerType)
	-- Previous behavior was specifically returning an empty string in this case
	if ( not powerType ) then
		return "";
	end

	if ( powerType == alternatePowerEnumValue and alternatePowerType ) then
		local name, tooltip, cost = GetUnitPowerBarStringsByID(alternatePowerType);
		return cost; --cost could be nil if we didn't get the alternatePowerType for some reason (e.g. target out of AOI)
	end

	-- Previous behavior was returning nil if powerType didn't match one of the explicitly checked types
	return powerTypeToStringLookup[powerType];
end
_G.CombatLog_String_PowerType = CombatLog_String_PowerType

local function CombatLog_String_SchoolString(school)
	if ( not school or school == Enum.Damageclass.MaskNone ) then
		return STRING_SCHOOL_UNKNOWN;
	end

	local schoolString = C_Spell.GetSchoolString(school);
	return schoolString or STRING_SCHOOL_UNKNOWN
end
_G.CombatLog_String_SchoolString = CombatLog_String_SchoolString

local function CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overenergize )
	local resultStr;
	-- Result String formatting
	local useOverhealing = overhealing and overhealing > 0;
	local useOverkill = overkill and overkill > 0;
	local useOverEnergize = overenergize and overenergize > 0;
	local useAbsorbed = absorbed and absorbed > 0;
	if ( resisted or blocked or critical or glancing or crushing or useOverhealing or useOverkill or useAbsorbed or overenergize ) then
		resultStr = nil;

		if ( resisted ) then
			if ( resisted < 0 ) then	--Its really a vulnerability
				resultStr = format(TEXT_MODE_A_STRING_RESULT_VULNERABILITY, BreakUpLargeNumbers(-resisted));
			else
				resultStr = format(TEXT_MODE_A_STRING_RESULT_RESIST, BreakUpLargeNumbers(resisted));
			end
		end
		if ( blocked ) then
			if ( resultStr ) then
				resultStr = resultStr.." "..format(TEXT_MODE_A_STRING_RESULT_BLOCK, BreakUpLargeNumbers(blocked));
			else
				resultStr = format(TEXT_MODE_A_STRING_RESULT_BLOCK, BreakUpLargeNumbers(blocked));
			end
		end
		if ( useAbsorbed ) then
			if ( resultStr ) then
				resultStr = resultStr.." "..format(TEXT_MODE_A_STRING_RESULT_ABSORB, BreakUpLargeNumbers(absorbed));
			else
				resultStr = format(TEXT_MODE_A_STRING_RESULT_ABSORB, BreakUpLargeNumbers(absorbed));
			end
		end
		if ( glancing ) then
			if ( resultStr ) then
				resultStr = resultStr.." "..TEXT_MODE_A_STRING_RESULT_GLANCING;
			else
				resultStr = TEXT_MODE_A_STRING_RESULT_GLANCING;
			end
		end
		if ( crushing ) then
			if ( resultStr ) then
				resultStr = resultStr.." "..TEXT_MODE_A_STRING_RESULT_CRUSHING;
			else
				resultStr = TEXT_MODE_A_STRING_RESULT_CRUSHING;
			end
		end
		if ( useOverhealing ) then
			if ( resultStr ) then
				resultStr = resultStr.." "..format(TEXT_MODE_A_STRING_RESULT_OVERHEALING, BreakUpLargeNumbers(overhealing));
			else
				resultStr = format(TEXT_MODE_A_STRING_RESULT_OVERHEALING, BreakUpLargeNumbers(overhealing));
			end
		end
		if ( useOverkill ) then
			if ( resultStr ) then
				resultStr = resultStr.." "..format(TEXT_MODE_A_STRING_RESULT_OVERKILLING, BreakUpLargeNumbers(overkill));
			else
				resultStr = format(TEXT_MODE_A_STRING_RESULT_OVERKILLING, BreakUpLargeNumbers(overkill));
			end
		end
		if ( useOverEnergize ) then
			if ( resultStr ) then
				resultStr = resultStr.." "..format(TEXT_MODE_A_STRING_RESULT_OVERENERGIZE, BreakUpLargeNumbers(overenergize));
			else
				resultStr = format(TEXT_MODE_A_STRING_RESULT_OVERENERGIZE, BreakUpLargeNumbers(overenergize));
			end
		end
		if ( critical ) then
			local critString = TEXT_MODE_A_STRING_RESULT_CRITICAL;
			if ( spellId ) then
				critString = TEXT_MODE_A_STRING_RESULT_CRITICAL_SPELL;
			end
			if ( resultStr ) then
				resultStr = resultStr.." "..critString;
			else
				resultStr = critString;
			end
		end
	end

	return resultStr;
end
_G.CombatLog_String_DamageResultString = CombatLog_String_DamageResultString

--
-- Get the appropriate raid icon for a unit
--
local function CombatLog_String_GetIcon ( unitFlags, direction )

	-- Check for an appropriate icon for this unit
	local raidTarget = bit_band(unitFlags, COMBATLOG_OBJECT_RAIDTARGET_MASK);
	if ( raidTarget == 0 ) then
		return "";
	end

	local iconString = "";
	local icon = nil;
	local iconBit = 0;

	if ( raidTarget == COMBATLOG_OBJECT_RAIDTARGET1 ) then
		icon = COMBATLOG_ICON_RAIDTARGET1;
		iconBit = COMBATLOG_OBJECT_RAIDTARGET1;
	elseif ( raidTarget == COMBATLOG_OBJECT_RAIDTARGET2 ) then
		icon = COMBATLOG_ICON_RAIDTARGET2;
		iconBit = COMBATLOG_OBJECT_RAIDTARGET2;
	elseif ( raidTarget == COMBATLOG_OBJECT_RAIDTARGET3 ) then
		icon = COMBATLOG_ICON_RAIDTARGET3;
		iconBit = COMBATLOG_OBJECT_RAIDTARGET3;
	elseif ( raidTarget == COMBATLOG_OBJECT_RAIDTARGET4 ) then
		icon = COMBATLOG_ICON_RAIDTARGET4;
		iconBit = COMBATLOG_OBJECT_RAIDTARGET4;
	elseif ( raidTarget == COMBATLOG_OBJECT_RAIDTARGET5 ) then
		icon = COMBATLOG_ICON_RAIDTARGET5;
		iconBit = COMBATLOG_OBJECT_RAIDTARGET5;
	elseif ( raidTarget == COMBATLOG_OBJECT_RAIDTARGET6 ) then
		icon = COMBATLOG_ICON_RAIDTARGET6;
		iconBit = COMBATLOG_OBJECT_RAIDTARGET6;
	elseif ( raidTarget == COMBATLOG_OBJECT_RAIDTARGET7 ) then
		icon = COMBATLOG_ICON_RAIDTARGET7;
		iconBit = COMBATLOG_OBJECT_RAIDTARGET7;
	elseif ( raidTarget == COMBATLOG_OBJECT_RAIDTARGET8 ) then
		icon = COMBATLOG_ICON_RAIDTARGET8;
		iconBit = COMBATLOG_OBJECT_RAIDTARGET8;
	end

	-- Insert the Raid Icon if it exists
	if ( icon ) then
		--
		-- Insert a hyperlink for that icon

		if ( direction == "source" ) then
			iconString = format(TEXT_MODE_A_STRING_SOURCE_ICON, iconBit, icon);
		else
			iconString = format(TEXT_MODE_A_STRING_DEST_ICON, iconBit, icon);
		end
	end

	return iconString;
end
_G.CombatLog_String_GetIcon = CombatLog_String_GetIcon

--
--	Gets the appropriate color for a unit type
--
--
local function CombatLog_Color_ColorStringByUnitType(unitFlags)
	local colorArray = CombatLog_Color_ColorArrayByUnitType(unitFlags);

	return  CombatLog_Color_FloatToText(colorArray.r, colorArray.g, colorArray.b, colorArray.a )
end
_G.CombatLog_Color_ColorStringByUnitType = CombatLog_Color_ColorStringByUnitType


--[[
--	Gets the appropriate color for a school
--
--]]
local function CombatLog_Color_ColorStringBySchool(school)
	local colorArray = CombatLog_Color_ColorArrayBySchool(school);

	return  CombatLog_Color_FloatToText(colorArray.r, colorArray.g, colorArray.b, colorArray.a )
end
_G.CombatLog_Color_ColorStringBySchool = CombatLog_Color_ColorStringBySchool

--
--	Gets the appropriate color for an event type
--
--
local function CombatLog_Color_ColorStringByEventType(unitFlags)
	local colorArray = CombatLog_Color_ColorArrayByEventType(unitFlags);

	return  CombatLog_Color_FloatToText(colorArray.r, colorArray.g, colorArray.b, colorArray.a )
end
_G.CombatLog_Color_ColorStringByEventType = CombatLog_Color_ColorStringByEventType


--[[
--	Handles events and dumps them to the specified frame.
--]]

-- Add settings as an arg

local defaultCombatLogLineColor = { a = 1.00, r = 1.00, g = 1.00, b = 1.00 };

function CombatLog_OnEvent(filterSettings, timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
	-- [environmentalDamageType]
	-- [spellName, spellRank, spellSchool]
	-- [damage, school, [resisted, blocked, absorbed, crit, glancing, crushing]]

	-- Upvalue this, we're gonna use it a lot
	local settings = filterSettings.settings;

	local lineColor = defaultCombatLogLineColor;
	local sourceColor, destColor = nil, nil;

	local braceColor = "FFFFFFFF";
	local abilityColor = "FFFFFF00";

	-- Processing variables
	local textMode = settings.textMode;
	local timestampEnabled = settings.timestamp;
	local hideBuffs = settings.hideBuffs;
	local hideDebuffs = settings.hideDebuffs;
	local sourceEnabled = true;
	local falseSource = false;
	local destEnabled = true;
	local spellEnabled = true;
	local actionEnabled = true;
	local valueEnabled = true;
	local valueTypeEnabled = true;
	local resultEnabled = true;
	local powerTypeEnabled = true;
	local itemEnabled = false;
	local extraSpellEnabled = false;
	local valueIsItem = false;
	local schoolEnabled = true;
	local withPoints = false;
	local forceDestPossessive = false;

	-- Get the initial string
	local schoolString;
	local resultStr;

	local formatString = TEXT_MODE_A_STRING_1;
	if ( EVENT_TEMPLATE_FORMATS[event] ) then
		formatString = EVENT_TEMPLATE_FORMATS[event];
	end

	-- Replacements to do:
	-- * Src, Dest, Action, Spell, Amount, Result

	-- Spell standard order
	local spellId, spellName, spellSchool;
	local extraSpellId, extraSpellName, extraSpellSchool;

	-- For Melee/Ranged swings and enchants
	local nameIsNotSpell, extraNameIsNotSpell;

	-- Damage standard order
	local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, overhealing;
	-- Miss argument order
	local missType, isOffHand, amountMissed;
	-- Aura arguments
	local auraType; -- BUFF or DEBUFF
	-- Energize Arguments
	local overEnergize;

	-- Enchant arguments
	local itemId, itemName;

	-- Special Spell values
	local valueType = 1;  -- 1 = School, 2 = Power Type
	local extraAmount; -- Used for Drains and Leeches
	local powerType; -- Used for energizes, drains and leeches
	local alternatePowerType; -- Used for energizes, drains and leeches
	local environmentalType; -- Used for environmental damage
	local message; -- Used for server spell messages
	local originalEvent = event; -- Used for spell links
	local remainingPoints;	--Used for absorbs with the correct flag set (like Power Word: Shield)

	--Extra data for PARTY_KILL, SPELL_INSTAKILL and UNIT_DIED
	local unconsciousOnDeath = 0;

	-- Generic disabling stuff
	if ( not sourceName or CombatLog_Object_IsA(sourceFlags, COMBATLOG_OBJECT_NONE) ) then
		sourceEnabled = false;
	end
	if ( not destName or CombatLog_Object_IsA(destFlags, COMBATLOG_OBJECT_NONE) ) then
		destEnabled = false;
	end

	local subVal = strsub(event, 1, 5)

	-- Swings
	if ( subVal == "SWING" ) then
		spellName = ACTION_SWING;
		nameIsNotSpell = true;
	end

	-- Break out the arguments into variable
	if ( event == "SWING_DAMAGE" ) then
		-- Damage standard
		amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = ...;

		-- Parse the result string
		resultStr = CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

		if ( not resultStr ) then
			resultEnabled = false;
		end

		if ( overkill > 0 ) then
			amount = amount - overkill;
		end

	elseif ( event == "SWING_MISSED" ) then
		spellName = ACTION_SWING;

		-- Miss type
		missType, isOffHand, amountMissed, critical = ...;

		-- Result String
		if ( missType == "ABSORB" ) then
			resultStr = CombatLog_String_DamageResultString( resisted, blocked, amountMissed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );
		elseif( missType == "RESIST" or missType == "BLOCK" ) then
			resultStr = format(_G["TEXT_MODE_A_STRING_RESULT_"..missType], amountMissed);
		else
			resultStr = _G["ACTION_SWING_MISSED_"..missType];
		end

		-- Miss Type
		if ( settings.fullText and missType ) then
			event = format("%s_%s", event, missType);
		end

		-- Disable appropriate sections
		nameIsNotSpell = true;
		valueEnabled = false;
		resultEnabled = true;

	elseif ( subVal == "SPELL" ) then	-- Spell standard arguments
		spellId, spellName, spellSchool = ...;

		if ( event == "SPELL_DAMAGE" or event == "SPELL_BUILDING_DAMAGE") then
			-- Damage standard
			amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(4, ...);

			-- Parse the result string
			resultStr = CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

			if ( not resultStr ) then
				resultEnabled = false
			end

			if ( overkill > 0 ) then
				amount = amount - overkill;
			end
		elseif ( event == "SPELL_MISSED" ) then
			-- Miss type
			missType,  isOffHand, amountMissed, critical = select(4, ...);

			resultEnabled = true;
			-- Result String
			if ( missType == "ABSORB" ) then
				resultStr = CombatLog_String_DamageResultString( resisted, blocked, amountMissed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );
			elseif( missType == "RESIST" or missType == "BLOCK" ) then
				if ( amountMissed ~= 0 ) then
					resultStr = format(_G["TEXT_MODE_A_STRING_RESULT_"..missType], amountMissed);
				else
					resultEnabled = false;
				end
			else
				resultStr = _G["ACTION_SWING_MISSED_"..missType];
			end

			-- Miss Event
			if ( missType ) then
				event = format("%s_%s", event, missType);
			end

			-- Disable appropriate sections
			valueEnabled = false;
		elseif ( event == "SPELL_HEAL" or event == "SPELL_BUILDING_HEAL") then
			-- Did the heal crit?
			amount, overhealing, absorbed, critical = select(4, ...);

			-- Parse the result string
			resultStr = CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

			if ( not resultStr ) then
				resultEnabled = false
			end

			-- Temporary Spell School Hack
			school = spellSchool;

			-- Disable appropriate sections
			valueEnabled = true;
			valueTypeEnabled = true;

			amount = amount - overhealing;
		elseif ( event == "SPELL_ENERGIZE" ) then
			-- Set value type to be a power type
			valueType = 2;

			-- Did the heal crit?
			amount, overEnergize, powerType, alternatePowerType = select(4, ...);

			-- Parse the result string
			resultStr = CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

			if ( not resultStr ) then
				resultEnabled = false
			end

			-- Disable appropriate sections
			valueEnabled = true;
			valueTypeEnabled = true;
		elseif ( strsub(event, 1, 14) == "SPELL_PERIODIC" ) then

			if ( event == "SPELL_PERIODIC_MISSED" ) then
				-- Miss type
				missType, isOffHand, amountMissed, critical = select(4, ...);

				-- Result String
				if ( missType == "ABSORB" ) then
					resultStr = CombatLog_String_DamageResultString( resisted, blocked, amountMissed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );
				else
					resultStr = _G["ACTION_SPELL_PERIODIC_MISSED_"..missType];
				end

				-- Miss Event
				if ( settings.fullText and missType ) then
					event = format("%s_%s", event, missType);
				end

				-- Disable appropriate sections
				valueEnabled = false;
				resultEnabled = true;
			elseif ( event == "SPELL_PERIODIC_DAMAGE" ) then
				-- Damage standard
				amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(4, ...);

				-- Parse the result string
				resultStr = CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

				-- Disable appropriate sections
				if ( not resultStr ) then
					resultEnabled = false
				end

				if ( overkill > 0 ) then
					amount = amount - overkill;
				end
			elseif ( event == "SPELL_PERIODIC_HEAL" ) then
				-- Did the heal crit?
				amount, overhealing, absorbed, critical = select(4, ...);

				-- Parse the result string
				resultStr = CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

				if ( not resultStr ) then
					resultEnabled = false
				end

				-- Temporary Spell School Hack
				school = spellSchool;

				-- Disable appropriate sections
				valueEnabled = true;
				valueTypeEnabled = true;

				amount = amount - overhealing;
			elseif ( event == "SPELL_PERIODIC_DRAIN" ) then
				-- Special attacks
				amount, powerType, extraAmount, alternatePowerType = select(4, ...);

				-- Set value type to be a power type
				valueType = 2;

				-- Result String
				--resultStr = _G[textModeString .. "RESULT"];
				--resultStr = gsub(resultStr,"$resultString", _G["ACTION_"..event.."_RESULT"]);

				-- Disable appropriate sections
				if ( not resultStr ) then
					resultEnabled = false
				end
				valueEnabled = true;
				schoolEnabled = false;
			elseif ( event == "SPELL_PERIODIC_LEECH" ) then
				-- Special attacks
				amount, powerType, extraAmount, alternatePowerType = select(4, ...);

				-- Set value type to be a power type
				valueType = 2;

				-- Result String
				resultStr = format(_G["ACTION_SPELL_PERIODIC_LEECH_RESULT"], nil, nil, nil, nil, nil, nil, nil, CombatLog_String_PowerType(powerType, amount, alternatePowerType), nil, extraAmount) --"($extraAmount $powerType Gained)"

				-- Disable appropriate sections
				if ( not resultStr ) then
					resultEnabled = false
				end
				valueEnabled = true;
				schoolEnabled = false;
			elseif ( event == "SPELL_PERIODIC_ENERGIZE" ) then
				-- Set value type to be a power type
				valueType = 2;

				-- Did the heal crit?
				amount, overEnergize, powerType, alternatePowerType = select(4, ...);

				-- Parse the result string
				--resultStr = _G[textModeString .. "RESULT"];
				--resultStr = gsub(resultStr,"$resultString", _G["ACTION_"..event.."_RESULT"]);
				resultStr = CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

				if ( not resultStr ) then
					resultEnabled = false
				end

				-- Disable appropriate sections
				valueEnabled = true;
				valueTypeEnabled = true;
			end
		elseif ( event == "SPELL_CAST_START" ) then	-- Spellcast
			if ( not destName ) then
				destEnabled = false;
			end
			if ( not sourceName ) then
				sourceName = COMBATLOG_UNKNOWN_UNIT;
				sourceEnabled = true;
				falseSource = true;
			end

			-- Disable appropriate types
			resultEnabled = false;
			valueEnabled = false;
		elseif ( event == "SPELL_CAST_SUCCESS" ) then
			if ( not destName ) then
				destEnabled = false;
			end
			if ( not sourceName ) then
				sourceName = COMBATLOG_UNKNOWN_UNIT;
				sourceEnabled = true;
				falseSource = true;
			end

			-- Disable appropriate types
			resultEnabled = false;
			valueEnabled = false;
		elseif ( event == "SPELL_CAST_FAILED" ) then
			if ( not destName ) then
				destEnabled = false;
			end
			-- Miss reason
			missType = select(4, ...);

			-- Result String
			resultStr = format("(%s)", missType);
			--resultStr = gsub(_G[textModeString .. "RESULT"],"$resultString", missType);

			-- Disable appropriate sections
			valueEnabled = false;
			destEnabled = false;

			if ( not resultStr ) then
				resultEnabled = false;
			end
		elseif ( event == "SPELL_DRAIN" ) then		-- Special Spell effects
			-- Special attacks
			amount, powerType, extraAmount, alternatePowerType = select(4, ...);

			-- Set value type to be a power type
			valueType = 2;

			-- Disable appropriate sections
			if ( not resultStr ) then
				resultEnabled = false;
			end
			valueEnabled = true;
			schoolEnabled = false;
		elseif ( event == "SPELL_LEECH" ) then
			-- Special attacks
			amount, powerType, extraAmount, alternatePowerType = select(4, ...);

			-- Set value type to be a power type
			valueType = 2;

			-- Result String
			resultStr = format(_G["ACTION_SPELL_LEECH_RESULT"], nil, nil, nil, nil, nil, nil, nil, CombatLog_String_PowerType(powerType, amount, alternatePowerType), nil, extraAmount)

			-- Disable appropriate sections
			if ( not resultStr ) then
				resultEnabled = false;
			end
			valueEnabled = true;
			schoolEnabled = false;
		elseif ( event == "SPELL_INTERRUPT" ) then
			-- Spell interrupted
			extraSpellId, extraSpellName, extraSpellSchool = select(4, ...);

			-- Replace the value token with a spell token
			if ( extraSpellId ) then
				extraSpellEnabled = true;
			end

			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
			valueTypeEnabled = false;
			schoolEnabled = false;
		elseif ( event == "SPELL_EXTRA_ATTACKS" ) then
			-- Special attacks
			amount = select(4, ...);

			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = true;
			valueTypeEnabled = false;
			schoolEnabled = false;
		elseif ( event == "SPELL_SUMMON" ) then
			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
			schoolEnabled = false;
		elseif ( event == "SPELL_RESURRECT" ) then
			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
			schoolEnabled = false;
		elseif ( event == "SPELL_CREATE" ) then
			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
			schoolEnabled = false;
		elseif ( event == "SPELL_INSTAKILL" ) then
			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
			schoolEnabled = false;

			unconsciousOnDeath = select(5, ...);
		elseif ( event == "SPELL_DURABILITY_DAMAGE" ) then
			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
			schoolEnabled = false;
		elseif ( event == "SPELL_DURABILITY_DAMAGE_ALL" ) then
			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
			schoolEnabled = false;
		elseif ( event == "SPELL_DISPEL_FAILED" ) then
			-- Extra Spell standard
			extraSpellId, extraSpellName, extraSpellSchool = select(4, ...);

			-- Replace the value token with a spell token
			if ( extraSpellId ) then
				extraSpellEnabled = true;
			end

			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
		elseif ( event == "SPELL_DISPEL" or event == "SPELL_STOLEN" ) then
			-- Extra Spell standard, Aura standard
			extraSpellId, extraSpellName, extraSpellSchool, auraType = select(4, ...);

			-- Event Type
			event = format("%s_%s", event, auraType);

			-- Replace the value token with a spell token
			if ( extraSpellId ) then
				extraSpellEnabled = true;
				valueEnabled = true;
			else
				valueEnabled = false;
			end

			-- Disable appropriate sections
			resultEnabled = false;
		elseif ( event == "SPELL_AURA_BROKEN" or event == "SPELL_AURA_BROKEN_SPELL") then

			-- Extra Spell standard, Aura standard
			if(event == "SPELL_AURA_BROKEN") then
				auraType = select(4, ...);
			else
				extraSpellId, extraSpellName, extraSpellSchool, auraType = select(4, ...);
			end

			-- Abort if buff/debuff is not set to true
			if ( hideBuffs and auraType == AURA_TYPE_BUFF ) then
				return;
			elseif ( hideDebuffs and auraType == AURA_TYPE_DEBUFF ) then
				return;
			end

			-- Event Type
			event = format("%s_%s", event, auraType);

			-- Replace the value token with a spell token
			if ( extraSpellId ) then
				extraSpellEnabled = true;
				valueEnabled = true;
			else
				forceDestPossessive = true;
				valueEnabled = false;
			end

			resultEnabled = false;
		elseif ( event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED" or event == "SPELL_AURA_REFRESH") then		-- Aura Events
			-- Aura standard
			auraType, remainingPoints = select(4, ...);

			-- Abort if buff/debuff is not set to true
			if ( hideBuffs and auraType == AURA_TYPE_BUFF ) then
				return;
			elseif ( hideDebuffs and auraType == AURA_TYPE_DEBUFF ) then
				return;
			end

			formatString = TEXT_MODE_A_STRING_1;

			-- Event Type
			event = format("%s_%s", event, auraType);

			if ( remainingPoints and settings.fullText ) then
				withPoints = true;
			end

			resultEnabled = false;
			valueEnabled = false;
		elseif ( event == "SPELL_AURA_APPLIED_DOSE" or event == "SPELL_AURA_REMOVED_DOSE" ) then
			-- Aura standard
			auraType, amount = select(4, ...);

			-- Abort if buff/debuff is not set to true
			if ( hideBuffs and auraType == AURA_TYPE_BUFF ) then
				return;
			elseif ( hideDebuffs and auraType == AURA_TYPE_DEBUFF ) then
				return;
			end

			-- Event Type
			event = format("%s_%s", event, auraType);


			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = true;
			valueTypeEnabled = false;
		elseif ( event == "SPELL_EMPOWER_START" ) then
			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
			valueTypeEnabled = false;
		elseif ( event == "SPELL_EMPOWER_END" or event == "SPELL_EMPOWER_INTERRUPT" ) then
			amount = select(4, ...);
			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = true;
			valueTypeEnabled = false;
		end
	elseif ( subVal == "RANGE" ) then
		--spellName = ACTION_RANGED;
		--nameIsNotSpell = true;

		-- Shots are spells, technically
		spellId, spellName, spellSchool = ...;
		if ( event == "RANGE_DAMAGE" ) then
			-- Damage standard
			amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(4, ...);

			-- Parse the result string
			resultStr = CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize);

			if ( not resultStr ) then
				resultEnabled = false
			end

			-- Disable appropriate sections
			nameIsNotSpell = true;

			if ( overkill > 0 ) then
				amount = amount - overkill;
			end
		elseif ( event == "RANGE_MISSED" ) then
			spellName = ACTION_RANGED;

			-- Miss type
			missType, isOffHand, amountMissed, critical = select(4,...);

			-- Result String
			if ( missType == "ABSORB" ) then
				resultStr = CombatLog_String_DamageResultString( resisted, blocked, amountMissed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );
			elseif( missType == "RESIST" or missType == "BLOCK" ) then
				resultStr = format(_G["TEXT_MODE_A_STRING_RESULT_"..missType], amountMissed);

			else
				resultStr = _G["ACTION_RANGE_MISSED_"..missType];
			end

			-- Miss Type
			if ( settings.fullText and missType ) then
				event = format("%s_%s", event, missType);
			end

			-- Disable appropriate sections
			nameIsNotSpell = true;
			valueEnabled = false;
			resultEnabled = true;
		end
	elseif ( event == "DAMAGE_SHIELD" ) then	-- Damage Shields
		-- Spell standard, Damage standard
		spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...;

		-- Parse the result string
		resultStr = CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

		-- Disable appropriate sections
		if ( not resultStr ) then
			resultEnabled = false
		end

		if ( overkill > 0 ) then
			amount = amount - overkill;
		end
	elseif ( event == "DAMAGE_SHIELD_MISSED" ) then
		-- Spell standard, Miss type
		spellId, spellName, spellSchool, missType = ...;

		-- Result String
		resultStr = _G["ACTION_DAMAGE_SHIELD_MISSED_"..missType];

		-- Miss Event
		if ( settings.fullText and missType ) then
			event = format("%s_%s", event, missType);
		end

		-- Disable appropriate sections
		valueEnabled = false;
		if ( not resultStr ) then
			resultEnabled = false;
		end
	elseif ( event == "PARTY_KILL" ) then	-- Unique Events
		-- Disable appropriate sections
		resultEnabled = false;
		valueEnabled = false;
		spellEnabled = false;

		unconsciousOnDeath = select(5, ...);
	elseif ( event == "ENCHANT_APPLIED" ) then
		-- Get the enchant name, item id and item name
		spellName, itemId, itemName = ...;
		nameIsNotSpell = true;

		-- Disable appropriate sections
		valueIsItem = true;
		itemEnabled = true;
		resultEnabled = false;
	elseif ( event == "ENCHANT_REMOVED" ) then
		-- Get the enchant name, item id and item name
		spellName, itemId, itemName = ...;
		nameIsNotSpell = true;

		-- Disable appropriate sections
		valueIsItem = true;
		itemEnabled = true;
		resultEnabled = false;
		sourceEnabled = false;

	elseif ( event == "UNIT_DIED" or event == "UNIT_DESTROYED" or event == "UNIT_DISSIPATES" ) then
		local recapID;
		recapID, unconsciousOnDeath = ...;
		-- handle death recaps
		if ( destGUID == UnitGUID("player") ) then
			local lineColor = COMBATLOG_DEFAULT_COLORS.unitColoring[COMBATLOG_FILTER_MINE];
			return GetDeathRecapLink(recapID), lineColor.r, lineColor.g, lineColor.b;
		end

		-- Swap Source with Dest
		sourceName = destName;
		sourceGUID = destGUID;
		sourceFlags = destFlags;

		-- Disable appropriate sections
		resultEnabled = false;
		sourceEnabled = true;
		destEnabled = false;
		spellEnabled = false;
		valueEnabled = false;

	elseif ( event == "ENVIRONMENTAL_DAMAGE" ) then
		--Environmental Type, Damage standard
		environmentalType, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
		environmentalType = string.upper(environmentalType);

		-- Miss Event
		spellName = _G["ACTION_ENVIRONMENTAL_DAMAGE_"..environmentalType];
		spellSchool = school;
		nameIsNotSpell = true;

		-- Parse the result string
		resultStr = CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

		-- Environmental Event
		if ( settings.fullText and environmentalType ) then
			event = "ENVIRONMENTAL_DAMAGE_"..environmentalType;
		end

		if ( not resultStr ) then
			resultEnabled = false;
		end

		if ( overkill > 0 ) then
			amount = amount - overkill;
		end
	elseif ( event == "DAMAGE_SPLIT" ) then
		-- Spell Standard Arguments, Damage standard
		spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...;

		-- Parse the result string
		resultStr = CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

		if ( not resultStr ) then
			resultEnabled = false
		end

		if ( overkill > 0 ) then
			amount = amount - overkill;
		end
	end

	-- Throw away all of the assembled strings and just grab a premade one
	if ( settings.fullText ) then
		local formatStringEvent;
		if (withPoints) then
			formatStringEvent = format("ACTION_%s_WITH_POINTS_FULL_TEXT", event);
		else
			formatStringEvent = format("ACTION_%s_FULL_TEXT", event);
		end

		-- Get the base string
		if ( _G[formatStringEvent] ) then
			formatString = _G[formatStringEvent];
		end

		-- Set any special cases
		if ( not sourceEnabled ) then
			formatStringEvent = formatStringEvent.."_NO_SOURCE";
		end
		if ( not destEnabled ) then
			formatStringEvent = formatStringEvent.."_NO_DEST";
		end


		if (event=="DAMAGE_SPLIT" and resultStr) then
			if (amount == 0) then
				formatStringEvent = "ACTION_DAMAGE_SPLIT_ABSORBED_FULL_TEXT";
			else
				formatStringEvent = "ACTION_DAMAGE_SPLIT_RESULT_FULL_TEXT";
			end
		end

		-- Get the special cased string
		if ( _G[formatStringEvent] ) then
			formatString = _G[formatStringEvent];
		end

		sourceEnabled = true;
		destEnabled = true;
		spellEnabled = true;
		valueEnabled = true;
	end

	-- Actor name construction.
	--
	local sourceNameStr = "";
	local destNameStr = "";
	local sourceIcon = "";
	local destIcon = "";
	local spellNameStr = spellName;
	local extraSpellNameStr = extraSpellName;
	local itemNameStr = itemName;
	local actionEvent = "ACTION_"..event;

	--This is to get PARTY_KILL COMBAT_LOG_EVENTs on UnconsciousOnDeath units to display properly without new CombatLog events.
	if ( event == "PARTY_KILL" ) then
		if ( unconsciousOnDeath == 1 ) then
			actionEvent = "ACTION_PARTY_KILL_UNCONSCIOUS";

			if ( settings.fullText ) then
				formatString = _G["ACTION_PARTY_KILL_UNCONSCIOUS_FULL_TEXT"];
			end
		end
	end

	--This is to get SPELL_INSTAKILL COMBAT_LOG_EVENTs on UnconsciousOnDeath units to display properly without new CombatLog events.
	if ( event == "SPELL_INSTAKILL" ) then
		if ( unconsciousOnDeath == 1 ) then
			actionEvent = "ACTION_SPELL_INSTAKILL_UNCONSCIOUS";

			if ( settings.fullText ) then
				if ( not sourceEnabled ) then
					formatString = _G["ACTION_SPELL_INSTAKILL_UNCONSCIOUS_FULL_TEXT_NO_SOURCE"];
				else
					formatString = _G["ACTION_SPELL_INSTAKILL_UNCONSCIOUS_FULL_TEXT"];
				end
			end
		end
	end

	--This is to get the UNIT_DIED COMBAT_LOG_EVENTs for UnconsciousOnDeath units to display properly without new CombatLog events.
	if ( event == "UNIT_DIED" ) then
		if ( unconsciousOnDeath == 1 ) then
			actionEvent = "ACTION_UNIT_BECCOMES_UNCONSCIOUS";

			if ( settings.fullText ) then
				formatString = _G["ACTION_UNIT_BECOMES_UNCONSCIOUS_FULL_TEXT"];
			end
		end
	end

	local actionStr = _G[actionEvent];
	local timestampStr = timestamp;
	local powerTypeString = "";

	-- If this ever succeeds, the event string is missing.
	--
	if ( not actionStr ) then
		actionStr = event;
	end

	-- Initialize the strings now
	sourceNameStr, destNameStr = sourceName, destName;

	-- Special changes for localization when not in full text mode
	if ( not settings.fullText and COMBAT_LOG_UNIT_YOU_ENABLED == "1" ) then
		-- Replace your name with "You";
		if ( sourceName and CombatLog_Object_IsA(sourceFlags, COMBATLOG_FILTER_MINE) ) then
				sourceNameStr = UNIT_YOU_SOURCE;
		end
		if ( destName and CombatLog_Object_IsA(destFlags, COMBATLOG_FILTER_MINE) ) then
				destNameStr = UNIT_YOU_DEST;
		end
		-- Apply the possessive form to the source
		if ( sourceName and spellName and _G[actionEvent.."_POSSESSIVE"] == "1" ) then
			if ( sourceName and CombatLog_Object_IsA(sourceFlags, COMBATLOG_FILTER_MINE) ) then
				sourceNameStr = UNIT_YOU_SOURCE_POSSESSIVE;
			end
		end
		-- Apply the possessive form to the source
		if ( destName and ( extraSpellName or itemName ) ) then
			if ( destName and CombatLog_Object_IsA(destFlags, COMBATLOG_FILTER_MINE) ) then
				destNameStr = UNIT_YOU_DEST_POSSESSIVE;
			end
		end

	-- If its full text mode
	else
		-- Apply the possessive form to the source
		if ( sourceName and spellName and _G[actionEvent.."_POSSESSIVE"] == "1" ) then
			sourceNameStr = format(TEXT_MODE_A_STRING_POSSESSIVE, sourceNameStr);
		end

		-- Apply the possessive form to the dest if the dest has a spell
		if ( ( extraSpellName or forceDestPossessive  or itemName ) and destName ) then
			destNameStr = format(TEXT_MODE_A_STRING_POSSESSIVE, destNameStr);
		end
	end

	-- Unit Icons
	if ( settings.unitIcons ) then
		if ( sourceName ) then
			sourceIcon = CombatLog_String_GetIcon(sourceRaidFlags, "source");
		end
		if ( destName ) then
			destIcon = CombatLog_String_GetIcon(destRaidFlags, "dest");
		end
	end

	-- Get the source color
	if ( sourceName ) then
		sourceColor	= CombatLog_Color_ColorStringByUnitType( sourceFlags );
	end

	-- Get the dest color
	if ( destName ) then
		destColor	= CombatLog_Color_ColorStringByUnitType( destFlags );
	end

	-- Whole line coloring
	if ( settings.lineColoring ) then
		if ( settings.lineColorPriority == 3 or ( not sourceName and not destName) ) then
			lineColor = CombatLog_Color_ColorArrayByEventType( event, filterSettings );
		else
			if ( ( settings.lineColorPriority == 1 and sourceName ) or not destName ) then
				lineColor = CombatLog_Color_ColorArrayByUnitType( sourceFlags, filterSettings );
			elseif ( ( settings.lineColorPriority == 2 and destName ) ) then
				lineColor = CombatLog_Color_ColorArrayByUnitType( destFlags, filterSettings );
			else
				lineColor = CombatLog_Color_ColorArrayByUnitType( sourceFlags, filterSettings );
			end
		end
	end

	-- Power Type
	if ( powerType ) then
		powerTypeString =  CombatLog_String_PowerType(powerType, amount, alternatePowerType);
		if powerTypeString == BALANCE_NEGATIVE_ENERGY then
			amount = abs(amount);
		end
	end

	-- Only replace if there's an amount
	if ( amount ) then
		local amountColor;

		-- Color amount numbers
		if ( settings.amountColoring ) then
			-- To make white swings white
			if ( settings.noMeleeSwingColoring and school == Enum.Damageclass.MaskPhysical and not spellId )  then
				-- Do nothing
			elseif ( settings.amountActorColoring ) then
				if ( sourceName ) then
					amountColor = CombatLog_Color_ColorArrayByUnitType( sourceFlags, filterSettings );
				elseif ( destName ) then
					amountColor = CombatLog_Color_ColorArrayByUnitType( destFlags, filterSettings );
				end
			elseif ( settings.amountSchoolColoring ) then
				amountColor = CombatLog_Color_ColorArrayBySchool(school, filterSettings);
			else
				amountColor = filterSettings.colors.defaults.damage;
			end

		end
		-- Highlighting
		if ( settings.amountHighlighting ) then
			local colorArray;
			if ( not amountColor ) then
				colorArray = lineColor;
			else
				colorArray = amountColor;
			end
			amountColor  = CombatLog_Color_HighlightColorArray (colorArray);
		end

		amount = BreakUpLargeNumbers(amount);
		if ( amountColor ) then
			amountColor = CombatLog_Color_FloatToText(amountColor);
			amount = format("|c%s%s|r", amountColor, amount);
		end

		schoolString = CombatLog_String_SchoolString(school);
		local schoolNameColor = nil;
		-- Color school names
		if ( settings.schoolNameColoring ) then
			if ( settings.noMeleeSwingColoring and school == Enum.Damageclass.MaskPhysical and not spellId )  then
			elseif ( settings.schoolNameActorColoring ) then
					if ( sourceName ) then
						schoolNameColor = CombatLog_Color_ColorArrayByUnitType( sourceFlags, filterSettings );
					elseif ( destName ) then
						schoolNameColor = CombatLog_Color_ColorArrayByUnitType( destFlags, filterSettings );
					end
			else
				schoolNameColor = CombatLog_Color_ColorArrayBySchool( school, filterSettings );
			end
		end
		-- Highlighting
		if ( settings.schoolNameHighlighting ) then
			local colorArray;
			if ( not schoolNameColor ) then
				colorArray = lineColor;
			else
				colorArray = schoolNameColor;
			end
			schoolNameColor  = CombatLog_Color_HighlightColorArray (colorArray);
		end
		if ( schoolNameColor ) then
			schoolNameColor = CombatLog_Color_FloatToText(schoolNameColor);
			schoolString = format("|c%s%s|r", schoolNameColor, schoolString);
		end

	end

	-- Color source names
	if ( settings.unitColoring ) then
		if ( sourceName and settings.sourceColoring ) then
			sourceNameStr = format("|c%s%s|r", sourceColor, sourceNameStr);
		end
		if ( destName and settings.destColoring ) then
			destNameStr = format("|c%s%s|r", destColor, destNameStr);
		end
	end

	-- If there's an action (always)
	if ( actionStr ) then
		local actionColor = nil;
		-- Color ability names
		if ( settings.actionColoring ) then

			if ( settings.actionActorColoring ) then
				if ( sourceName ) then
					actionColor = CombatLog_Color_ColorArrayByUnitType( sourceFlags, filterSettings );
				elseif ( destName ) then
					actionColor = CombatLog_Color_ColorArrayByUnitType( destFlags, filterSettings );
				end
			elseif ( settings.actionSchoolColoring and spellSchool ) then
				actionColor = CombatLog_Color_ColorArrayBySchool( spellSchool, filterSettings );
			else
				actionColor = CombatLog_Color_ColorArrayByEventType(event);
			end
		-- Special option to only color "Miss" if there's no damage
		elseif ( settings.missColoring ) then

			if ( event ~= "SWING_DAMAGE" and
				event ~= "RANGE_DAMAGE" and
				event ~= "SPELL_DAMAGE" and
				event ~= "SPELL_PERIODIC_DAMAGE" ) then

				local actionColor = nil;

				if ( settings.actionActorColoring ) then
					actionColor = CombatLog_Color_ColorArrayByUnitType( sourceFlags, filterSettings );
				elseif ( settings.actionSchoolColoring ) then
					actionColor = CombatLog_Color_ColorArrayBySchool( spellSchool, filterSettings );
				else
					actionColor = CombatLog_Color_ColorArrayByEventType(event);
				end

			end
		end

		-- Highlighting
		if ( settings.actionHighlighting ) then
			local colorArray;
			if ( not actionColor ) then
				colorArray = lineColor;
			else
				colorArray = actionColor;
			end
			actionColor = CombatLog_Color_HighlightColorArray (colorArray);
		end

		if ( actionColor ) then
			actionColor = CombatLog_Color_FloatToText(actionColor);
			actionStr = format("|c%s%s|r", actionColor, actionStr);
		end

	end
	-- If there's a spell name
	if ( spellName ) then
		local abilityColor = nil;
		-- Color ability names
		if ( settings.abilityColoring ) then
			if ( settings.abilityActorColoring ) then
				abilityColor = CombatLog_Color_ColorArrayByUnitType( sourceFlags, filterSettings );
			elseif ( settings.abilitySchoolColoring ) then
				abilityColor = CombatLog_Color_ColorArrayBySchool( spellSchool, filterSettings );
			else
				if ( spellSchool ) then
					abilityColor = filterSettings.colors.defaults.spell;
				end
			end
		end

		-- Highlight this color
		if ( settings.abilityHighlighting ) then
			local colorArray;
			if ( not abilityColor ) then
				colorArray = lineColor;
			else
				colorArray = abilityColor;
			end
			abilityColor  = CombatLog_Color_HighlightColorArray (colorArray);
		end
		if ( abilityColor ) then
			abilityColor = CombatLog_Color_FloatToText(abilityColor);
			if ( itemId ) then
				spellNameStr = spellName;
			else
				spellNameStr = format("|c%s%s|r", abilityColor, spellName);
			end
		end
	end

	-- If there's a spell name
	if ( extraSpellName ) then
		local abilityColor = nil;
		-- Color ability names
		if ( settings.abilityColoring ) then

			if ( settings.abilitySchoolColoring ) then
				abilityColor = CombatLog_Color_ColorArrayBySchool( extraSpellSchool, filterSettings );
			else
				if ( extraSpellSchool ) then
					abilityColor = CombatLog_Color_ColorArrayBySchool( Enum.Damageclass.MaskHoly, filterSettings );
				else
					abilityColor = CombatLog_Color_ColorArrayBySchool( nil, filterSettings );
				end
			end
		end
		-- Highlight this color
		if ( settings.abilityHighlighting ) then
			local colorArray;
			if ( not abilityColor ) then
				colorArray = lineColor;
			else
				colorArray = abilityColor;
			end
			abilityColor  = CombatLog_Color_HighlightColorArray (colorArray);
		end
		if ( abilityColor ) then
			abilityColor = CombatLog_Color_FloatToText(abilityColor);
			extraSpellNameStr = format("|c%s%s|r", abilityColor, extraSpellName);
		end
	end

	-- Whole line highlighting
	if ( settings.lineHighlighting ) then
		if ( filterSettings.colors.highlightedEvents[event] ) then
			lineColor = CombatLog_Color_HighlightColorArray (lineColor);
		end
	end

	-- Build braces
	if ( settings.braces ) then
		-- Unit specific braces
		if ( settings.unitBraces ) then
			if ( sourceName and settings.sourceBraces ) then
				sourceNameStr = format(TEXT_MODE_A_STRING_BRACE_UNIT, braceColor, sourceNameStr, braceColor);
			end

			if ( destName and settings.destBraces ) then
				destNameStr = format(TEXT_MODE_A_STRING_BRACE_UNIT, braceColor, destNameStr, braceColor);
			end
		end

		-- Spell name braces
		if ( spellName and settings.spellBraces ) then
			if ( not itemId ) then
				spellNameStr = format(TEXT_MODE_A_STRING_BRACE_SPELL, braceColor, spellNameStr, braceColor);
			end
		end
		if ( extraSpellName and settings.spellBraces ) then
			extraSpellNameStr = format(TEXT_MODE_A_STRING_BRACE_SPELL, braceColor, extraSpellNameStr, braceColor);
		end

		-- Build item braces
		if ( itemName and settings.itemBraces ) then
			itemNameStr = format(TEXT_MODE_A_STRING_BRACE_ITEM, braceColor, itemNameStr, braceColor);
		end
	end

	local sourceString = "";
	local spellString = "";
	local actionString = "";
	local destString = "";
	local valueString = "";
	local resultString = "";
	local remainingPointsString = "";

	if ( sourceEnabled and sourceName and falseSource ) then
		sourceString = sourceName;
	elseif ( sourceEnabled and sourceName ) then
		sourceString = format(TEXT_MODE_A_STRING_SOURCE_UNIT, sourceIcon, sourceGUID, sourceName, sourceNameStr);
	end

	if ( spellName ) then
		if ( nameIsNotSpell ) then
			spellString = format(TEXT_MODE_A_STRING_ACTION, originalEvent, spellNameStr);
		else
			spellString = format(TEXT_MODE_A_STRING_SPELL, spellId, 0, originalEvent, spellNameStr, spellId);
		end
	end

	if ( actionString ) then
		actionString = format(TEXT_MODE_A_STRING_ACTION, originalEvent, actionStr);
	end

	if ( destEnabled and destName ) then
		destString = format(TEXT_MODE_A_STRING_DEST_UNIT, destIcon, destGUID, destName, destNameStr);
	end

	if ( valueEnabled ) then
		if ( extraSpellEnabled and extraSpellNameStr ) then
			if ( extraNameIsNotSpell ) then
				valueString = extraSpellNameStr;
			else
				valueString = format(TEXT_MODE_A_STRING_SPELL_EXTRA, extraSpellId, 0, originalEvent, extraSpellNameStr, spellId);
			end
		elseif ( valueIsItem and itemNameStr ) then
			valueString = format(TEXT_MODE_A_STRING_ITEM, itemId, itemNameStr);
		elseif ( amount ) then
			if ( valueTypeEnabled ) then
				if ( valueType == 1 and schoolString ) then
					valueString = format(TEXT_MODE_A_STRING_VALUE_SCHOOL, amount, schoolString);
				elseif ( valueType == 2 and powerTypeString ) then
					valueString = format(TEXT_MODE_A_STRING_VALUE_TYPE, amount, powerTypeString);
				end
			end
			if ( valueString == "" ) then
				valueString = amount;
			end
		end
	end

	if ( resultEnabled and resultStr ) then
		resultString = resultStr;
	end

	if ( not schoolString ) then
		schoolString = "";
	end
	if ( not powerTypeString ) then
		powerTypeString = "";
	end
	if ( not amount ) then
		amount = "";
	end

	if ( not extraAmount) then
		extraAmount = "";
	end

	if ( sourceString == "" and not hideCaster ) then
		sourceString = UNKNOWN;
	end

	if ( destEnabled and destString == "" ) then
		destString = UNKNOWN;
	end

	if ( remainingPoints ) then
		remainingPointsString = format(TEXT_MODE_A_STRING_REMAINING_POINTS, BreakUpLargeNumbers(remainingPoints));
	end

	local finalString = format(formatString, sourceString, spellString, actionString, destString, valueString, resultString, schoolString, powerTypeString, amount, extraAmount, remainingPointsString);

	finalString = gsub(finalString, " [ ]+", " " ); -- extra white spaces
	finalString = gsub(finalString, " ([.,])", "%1" ); -- spaces before periods or comma
	finalString = gsub(finalString, "^([ .,]+)", "" ); -- spaces, period or comma at the beginning of a line

	if ( timestampEnabled and timestamp ) then
		-- Replace the timestamp
		finalString = format(TEXT_MODE_A_STRING_TIMESTAMP, date(settings.timestampFormat, timestamp), finalString);
	end

	-- NOTE: be sure to pass back nil for the color id or the color id may override the r, g, b values for this message line
	return finalString, lineColor.r, lineColor.g, lineColor.b;
end
_G.CombatLog_OnEvent = CombatLog_OnEvent

-- Process the event and add it to the combat log
function CombatLog_AddEvent(...)
	if ( DEBUG ) then
		local info = ChatTypeInfo["COMBAT_MISC_INFO"];
		local timestamp, event, hideCaster, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags = ...
		local message = format("%s, %s, %s, 0x%x, %s, %s, 0x%x",
				       --date("%H:%M:%S", timestamp),
		                       event,
		                       srcGUID, srcName or "nil", srcFlags,
		                       dstGUID, dstName or "nil", dstFlags);

		for i = 9, select("#", ...) do
			message = message..", "..tostring(select(i, ...));
		end
		ChatFrame1:AddMessage(message, info.r, info.g, info.b);
	end
	-- Add the messages
	local text, r, g, b, a = CombatLog_OnEvent(Blizzard_CombatLog_CurrentSettings, ... );
	if ( text ) then
		COMBATLOG:AddMessage(text, r, g, b, a);
	end
end

--
-- Event handler for the combat log
--
COMBATLOG.customEventHandler = 
	function(self, event, ...)
		if ( event == "COMBAT_LOG_EVENT" ) then
			CombatLog_AddEvent(CombatLogGetCurrentEventInfo());
			return true;
		else
			return false;
		end
	end
;

--
-- XML Function Overrides Part 2
--

--
-- Attach the Combat Log Button Frame to the Combat Log
--

-- On Event
function Blizzard_CombatLog_QuickButtonFrame_OnEvent(self, event, ...)
	local arg1 = ...;
	if ( event == "ADDON_LOADED" ) then
		if ( arg1 == "Blizzard_CombatLog" ) then
			Blizzard_CombatLog_Filters = _G.Blizzard_CombatLog_Filters or Blizzard_CombatLog_Filters
			Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_Filters.filters[1];
			_G.Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_CurrentSettings;

			Blizzard_CombatLog_QuickButton_OnClick(	Blizzard_CombatLog_Filters.currentFilter );
			Blizzard_CombatLog_Refilter();
			for k,v in pairs (Blizzard_CombatLog_UnitTokens) do
				Blizzard_CombatLog_UnitTokens[k] = nil;
			end
			Blizzard_CombatLog_Update_QuickButtons();
			--Hide the quick button frame if chatframe1 is selected and the combat log is docked
			if ( COMBATLOG.isDocked and SELECTED_CHAT_FRAME == ChatFrame1 ) then
				self:Hide();
			end
		end
	end
end

local function Blizzard_CombatLog_AdjustCombatLogHeight()
	local quickButtonHeight = CombatLogQuickButtonFrame:GetHeight();

	if ( COMBATLOG.isDocked ) then
		local oldPoint, relativeTo, relativePoint, x, y;
		for i=1, COMBATLOG:GetNumPoints() do
			oldPoint, relativeTo, relativePoint, x, y = COMBATLOG:GetPoint(i);
			if ( oldPoint == "TOPLEFT" ) then
				break;
			end
		end
		COMBATLOG:SetPoint("TOPLEFT", relativeTo, relativePoint, x, -quickButtonHeight);
	end

	FloatingChatFrame_UpdateBackgroundAnchors(COMBATLOG);
	FCF_UpdateButtonSide(COMBATLOG);
end

-- On Load
function Blizzard_CombatLog_QuickButtonFrame_OnLoad(self)
	self:RegisterEvent("ADDON_LOADED");

	-- We're using the _Custom suffix to get around the show/hide bug in FloatingChatFrame.lua.
	-- Once the fading is removed from FloatingChatFrame.lua these can do back to the non-custom values, and the dummy frame creation should be removed.
	CombatLogQuickButtonFrame = _G.CombatLogQuickButtonFrame_Custom
	COMBATLOG.CombatLogQuickButtonFrame = CombatLogQuickButtonFrame;
	CombatLogQuickButtonFrameProgressBar = _G.CombatLogQuickButtonFrame_CustomProgressBar
	CombatLogQuickButtonFrameTexture = _G.CombatLogQuickButtonFrame_CustomTexture

	-- Parent it to the tab so that we just inherit the tab's alpha. No need to do special fading for it.
	CombatLogQuickButtonFrame:SetParent(_G[COMBATLOG:GetName() .. "Tab"]);
	CombatLogQuickButtonFrame:SetFrameStrata("MEDIUM");
	CombatLogQuickButtonFrame:ClearAllPoints();
	CombatLogQuickButtonFrame:SetPoint("BOTTOMLEFT", COMBATLOG, "TOPLEFT", 0, 3);

	if COMBATLOG.ScrollBar then
		CombatLogQuickButtonFrame:SetPoint("BOTTOMRIGHT", COMBATLOG, "TOPRIGHT", COMBATLOG.ScrollBar:GetWidth(), 3);
	else
		CombatLogQuickButtonFrame:SetPoint("BOTTOMRIGHT", COMBATLOG, "TOPRIGHT", 0, 3);
	end

	CombatLogQuickButtonFrameProgressBar:Hide();

	-- Hook the frame's hide/show events so we can hide/show the quick buttons as appropriate.
	local show, hide = COMBATLOG:GetScript("OnShow"), COMBATLOG:GetScript("OnHide")
	COMBATLOG:SetScript("OnShow", function(self)
		CombatLogQuickButtonFrame_Custom:Show()

		COMBATLOG:RegisterEvent("COMBAT_LOG_EVENT");

		Blizzard_CombatLog_QuickButton_OnClick(Blizzard_CombatLog_Filters.currentFilter);
		return show and show(self)
	end)
	COMBATLOG:SetScript("OnHide", function(self)
		CombatLogQuickButtonFrame_Custom:Hide()

		COMBATLOG:UnregisterEvent("COMBAT_LOG_EVENT");
		return hide and hide(self)
	end)
	if ( COMBATLOG:IsShown() ) then
		COMBATLOG:RegisterEvent("COMBAT_LOG_EVENT");
	end

	FCF_SetButtonSide(COMBATLOG, COMBATLOG.buttonSide, true);
	FCF_DockUpdate();
end

local oldFCF_DockUpdate = FCF_DockUpdate;
FCF_DockUpdate = function()
	oldFCF_DockUpdate();
	Blizzard_CombatLog_AdjustCombatLogHeight();
end

--
-- Combat Log Global Functions
--

--[[
--
--  Returns the correct {} code for the combat log bit
--
--  args:
-- 		bit - a bit exactly equal to a raid target icon.
--]]
local function Blizzard_CombatLog_BitToBraceCode(bit)
	if ( bit == COMBATLOG_OBJECT_RAIDTARGET1 ) then
		return "{"..strlower(RAID_TARGET_1).."}";
	elseif ( bit == COMBATLOG_OBJECT_RAIDTARGET2 ) then
		return "{"..strlower(RAID_TARGET_2).."}";
	elseif ( bit == COMBATLOG_OBJECT_RAIDTARGET3 ) then
		return "{"..strlower(RAID_TARGET_3).."}";
	elseif ( bit == COMBATLOG_OBJECT_RAIDTARGET4 ) then
		return "{"..strlower(RAID_TARGET_4).."}";
	elseif ( bit == COMBATLOG_OBJECT_RAIDTARGET5 ) then
		return "{"..strlower(RAID_TARGET_5).."}";
	elseif ( bit == COMBATLOG_OBJECT_RAIDTARGET6 ) then
		return "{"..strlower(RAID_TARGET_6).."}";
	elseif ( bit == COMBATLOG_OBJECT_RAIDTARGET7 ) then
		return "{"..strlower(RAID_TARGET_7).."}";
	elseif ( bit == COMBATLOG_OBJECT_RAIDTARGET8 ) then
		return "{"..strlower(RAID_TARGET_8).."}";
	end
	return "";
end

-- Override Hyperlink Handlers
-- The SetItemRef() function hook is to be moved out into the core FrameXML.
-- It is currently in the Constants.lua stub file to simulate being moved out to the core.
--
-- The reason is because Blizzard_CombatLog is a LoD addon and can be replaced by the user
-- If the functionality of these new unit/icon/spell/action links is not in the core FrameXML
-- file in ItemRef.lua, then every combat log addon that replaces Blizzard_CombatLog must
-- provide the same functionality.
-- Players may also get all sorts of errors on trying to click on these new linktypes before
-- Blizzard_CombatLog gets loaded.

-- Override Hyperlink Handlers
-- This entire function hook should/must be directly integrated into ItemRef.lua
-- The reason is because Blizzard_CombatLog is a LoD addon and can be replaced by the user
-- If the functionality of these new unit/icon/spell/action links is not in the core FrameXML
-- file in ItemRef.lua, then every combat log addon that replaces Blizzard_CombatLog must
-- provide the same functionality.
-- Players may also get all sorts of errors on trying to click on these new linktypes before
-- Blizzard_CombatLog gets loaded.
local oldSetItemRef = SetItemRef;
function SetItemRef(link, text, button, chatFrame)

	if ( strsub(link, 1, 4) == "unit") then
		local _, guid, name = strsplit(":", link);
        
		if ( IsModifiedClick("CHATLINK") ) then
			ChatEdit_InsertLink (name);
			return;
		elseif( button == "RightButton") then
			-- Show Popup Menu
			EasyMenu(Blizzard_CombatLog_CreateUnitMenu(name, guid), CombatLogDropDown, "cursor", nil, nil, "MENU");
			return;
		end
	elseif ( strsub(link, 1, 4) == "icon") then
		local _, bit, direction = strsplit(":", link);
		local texture = string.gsub(text,".*|h(.*)|h.*","%1");
		-- Show Popup Menu
		if( button == "RightButton") then
			-- need to fix this to be actual texture
			EasyMenu(Blizzard_CombatLog_CreateUnitMenu(Blizzard_CombatLog_BitToBraceCode(tonumber(bit)), nil, tonumber(bit)), CombatLogDropDown, "cursor", nil, nil, "MENU");
		elseif ( IsModifiedClick("CHATLINK") ) then
			ChatEdit_InsertLink (Blizzard_CombatLog_BitToBraceCode(tonumber(bit)));
		end
		return;
	elseif ( strsub(link, 1,5) == "spell" ) then
		local _, spellId, glyphId, event = strsplit(":", link);
		spellId = tonumber (spellId);
		glyphId = tonumber (glyphId) or 0;

		if ( IsModifiedClick("CHATLINK") ) then
			if ( spellId > 0 ) then
				local spellLink = GetSpellLink(spellId, glyphId);
				if ( ChatEdit_InsertLink(spellLink) ) then
					return;
				end
			else
				return;
			end
		-- Show Popup Menu
		elseif( button == "RightButton" and event ) then
			EasyMenu(Blizzard_CombatLog_CreateSpellMenu(text, spellId, event), CombatLogDropDown, "cursor", nil, nil, "MENU");
			return;
		end
	elseif ( strsub(link, 1,6) == "action" ) then
		local _, event = strsplit(":", link);

		-- Show Popup Menu
		if( button == "RightButton") then
			EasyMenu(Blizzard_CombatLog_CreateActionMenu(event), CombatLogDropDown, "cursor", nil, nil, "MENU");
		end
		return;
	elseif ( strsub(link, 1, 19) == "garrfollowerability") then
		if ( IsModifiedClick("CHATLINK") ) then
			local _, abilityID = strsplit(":", link);
			local link = C_Garrison.GetFollowerAbilityLink(abilityID);
			ChatEdit_InsertLink (link);
			return;
		end
	end
	oldSetItemRef(link, text, button, chatFrame);
end

function Blizzard_CombatLog_Update_QuickButtons()
	local baseName = "CombatLogQuickButtonFrame";
	local buttonName, button, textWidth;
	local buttonIndex = 1;
	-- subtract the width of the dropdown button
	local clogleft, clogright = COMBATLOG:GetRight(), COMBATLOG:GetLeft();
	local maxWidth;
	if ( clogleft and clogright ) then
		maxWidth = (COMBATLOG:GetRight()-COMBATLOG:GetLeft())-31;	--Hacky hacky because GetWidth goes crazy when it is docked
	else
		maxWidth = COMBATLOG:GetWidth() - 31;
	end

	local additionalFilterButton = CombatLogQuickButtonFrame_CustomAdditionalFilterButton;

	local totalWidth = 0;
	local padding = 13;
	local showMoreQuickButtons = true;
	local hasOffBar = false;
	for index, filter in ipairs(_G.Blizzard_CombatLog_Filters.filters) do
		buttonName = baseName.."Button"..buttonIndex;
		button = _G[buttonName];
		if ( ShowQuickButton(filter) and showMoreQuickButtons ) then
			if ( not button ) then
				button = CreateFrame("BUTTON", buttonName, CombatLogQuickButtonFrame, "CombatLogQuickButtonTemplate");
			end
			button:SetText(filter.name);
			textWidth = button:GetTextWidth();
			totalWidth = totalWidth + textWidth + padding;
			if ( totalWidth <= maxWidth ) then
				button:SetWidth(textWidth+padding);
				button:SetID(index);
				button:Show();
				button.tooltip = filter.tooltip;
				if ( buttonIndex > 1 ) then
					button:SetPoint("LEFT", _G[baseName.."Button"..buttonIndex-1], "RIGHT", 3, 0);
				else
					button:SetPoint("LEFT", CombatLogQuickButtonFrame, "LEFT", 3, 0);
				end
				if ( Blizzard_CombatLog_Filters.currentFilter == index and (Blizzard_CombatLog_CurrentSettings and not Blizzard_CombatLog_CurrentSettings.isTemp) ) then
					button:LockHighlight();
				else
					button:UnlockHighlight();
				end
				filter.onQuickBar = true;
			else
				-- Don't show anymore buttons if the maxwidth has been exceeded
				showMoreQuickButtons = false;
				hasOffBar = true;
				button:Hide();
				filter.onQuickBar = false;
			end
			buttonIndex = buttonIndex + 1;
		else
			filter.onQuickBar = false;
			if ( button ) then
				button:Hide();
			end
		end
	end

	-- Hide remaining buttons
	repeat
		button = _G[baseName.."Button"..buttonIndex];
		if ( button ) then
			button:Hide();
		end
		buttonIndex = buttonIndex+1;
	until not button;

	additionalFilterButton:SetShown(hasOffBar);
end
_G.Blizzard_CombatLog_Update_QuickButtons = Blizzard_CombatLog_Update_QuickButtons

function Blizzard_CombatLog_QuickButton_OnClick(id)
	Blizzard_CombatLog_Filters.currentFilter = id;
	Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_Filters.filters[Blizzard_CombatLog_Filters.currentFilter];
	Blizzard_CombatLog_ApplyFilters(Blizzard_CombatLog_CurrentSettings);
	if ( Blizzard_CombatLog_CurrentSettings.settings.showHistory ) then
		Blizzard_CombatLog_Refilter();
	end
	Blizzard_CombatLog_Update_QuickButtons();
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
end

function ShowQuickButton(filter)
	if ( filter.hasQuickButton ) then
		if ( IsInRaid() ) then
			return filter.quickButtonDisplay.raid;
		elseif ( IsInGroup() ) then
			return filter.quickButtonDisplay.party;
		else
			return filter.quickButtonDisplay.solo;
		end
	else
		return false;
	end;
end

function Blizzard_CombatLog_RefreshGlobalLinks()
	-- Have to do this because Blizzard_CombatLog_Filters is a reference to the _G.Blizzard_CombatLog_Filters
	Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_Filters.filters[Blizzard_CombatLog_Filters.currentFilter];
end
