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
COMBATLOG_FILTER_VERSION = 4.1;
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
		[SCHOOL_MASK_NONE]	= {a=1.0,r=1.00,g=1.00,b=1.00};
		[SCHOOL_MASK_PHYSICAL]	= {a=1.0,r=1.00,g=1.00,b=0.00};
		[SCHOOL_MASK_HOLY] 	= {a=1.0,r=1.00,g=0.90,b=0.50};
		[SCHOOL_MASK_FIRE] 	= {a=1.0,r=1.00,g=0.50,b=0.00};
		[SCHOOL_MASK_NATURE] 	= {a=1.0,r=0.30,g=1.00,b=0.30};
		[SCHOOL_MASK_FROST] 	= {a=1.0,r=0.50,g=1.00,b=1.00};
		[SCHOOL_MASK_SHADOW] 	= {a=1.0,r=0.50,g=0.50,b=1.00};
		[SCHOOL_MASK_ARCANE] 	= {a=1.0,r=1.00,g=0.50,b=1.00};
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
	fullText = true;
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
	hideBuffs = false;
	hideDebuffs = false;
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
	["UNIT_DESTROYED"] = true
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
		if ( flag ) then
			flagList[k] = true
		else
			flagList[k] = false;
		end
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


local CombatLogUpdateFrame = CreateFrame("Frame", "CombatLogUpdateFrame", UIParent)
local _G = getfenv(0)
local bit_bor = _G.bit.bor
local bit_band = _G.bit.band
local tinsert = _G.tinsert
local tremove = _G.tremove
local math_floor = _G.math.floor
local format = _G.format
local gsub = _G.gsub
local strsub = _G.strsub
local strreplace = _G.strreplace;
 
-- Make all the constants upvalues. This prevents the global environment lookup + table lookup each time we use one (and they're used a lot)
local COMBATLOG_OBJECT_AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE
local COMBATLOG_OBJECT_AFFILIATION_PARTY = COMBATLOG_OBJECT_AFFILIATION_PARTY
local COMBATLOG_OBJECT_AFFILIATION_RAID = COMBATLOG_OBJECT_AFFILIATION_RAID
local COMBATLOG_OBJECT_AFFILIATION_OUTSIDER = COMBATLOG_OBJECT_AFFILIATION_OUTSIDER
local COMBATLOG_OBJECT_AFFILIATION_MASK = COMBATLOG_OBJECT_AFFILIATION_MASK
local COMBATLOG_OBJECT_REACTION_FRIENDLY = COMBATLOG_OBJECT_REACTION_FRIENDLY
local COMBATLOG_OBJECT_REACTION_NEUTRAL = COMBATLOG_OBJECT_REACTION_NEUTRAL
local COMBATLOG_OBJECT_REACTION_HOSTILE = COMBATLOG_OBJECT_REACTION_HOSTILE
local COMBATLOG_OBJECT_REACTION_MASK = COMBATLOG_OBJECT_REACTION_MASK
local COMBATLOG_OBJECT_CONTROL_PLAYER = COMBATLOG_OBJECT_CONTROL_PLAYER
local COMBATLOG_OBJECT_CONTROL_NPC = COMBATLOG_OBJECT_CONTROL_NPC
local COMBATLOG_OBJECT_CONTROL_MASK = COMBATLOG_OBJECT_CONTROL_MASK
local COMBATLOG_OBJECT_TYPE_PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER
local COMBATLOG_OBJECT_TYPE_NPC = COMBATLOG_OBJECT_TYPE_NPC
local COMBATLOG_OBJECT_TYPE_PET = COMBATLOG_OBJECT_TYPE_PET
local COMBATLOG_OBJECT_TYPE_GUARDIAN = COMBATLOG_OBJECT_TYPE_GUARDIAN
local COMBATLOG_OBJECT_TYPE_OBJECT = COMBATLOG_OBJECT_TYPE_OBJECT
local COMBATLOG_OBJECT_TYPE_MASK = COMBATLOG_OBJECT_TYPE_MASK
local COMBATLOG_OBJECT_TARGET = COMBATLOG_OBJECT_TARGET
local COMBATLOG_OBJECT_FOCUS = COMBATLOG_OBJECT_FOCUS
local COMBATLOG_OBJECT_MAINTANK = COMBATLOG_OBJECT_MAINTANK
local COMBATLOG_OBJECT_MAINASSIST = COMBATLOG_OBJECT_MAINASSIST
local COMBATLOG_OBJECT_RAIDTARGET1 = COMBATLOG_OBJECT_RAIDTARGET1
local COMBATLOG_OBJECT_RAIDTARGET2 = COMBATLOG_OBJECT_RAIDTARGET2
local COMBATLOG_OBJECT_RAIDTARGET3 = COMBATLOG_OBJECT_RAIDTARGET3
local COMBATLOG_OBJECT_RAIDTARGET4 = COMBATLOG_OBJECT_RAIDTARGET4
local COMBATLOG_OBJECT_RAIDTARGET5 = COMBATLOG_OBJECT_RAIDTARGET5
local COMBATLOG_OBJECT_RAIDTARGET6 = COMBATLOG_OBJECT_RAIDTARGET6
local COMBATLOG_OBJECT_RAIDTARGET7 = COMBATLOG_OBJECT_RAIDTARGET7
local COMBATLOG_OBJECT_RAIDTARGET8 = COMBATLOG_OBJECT_RAIDTARGET8
local COMBATLOG_OBJECT_NONE = COMBATLOG_OBJECT_NONE
local COMBATLOG_OBJECT_SPECIAL_MASK = COMBATLOG_OBJECT_SPECIAL_MASK
local COMBATLOG_FILTER_ME = COMBATLOG_FILTER_ME
local COMBATLOG_FILTER_MINE = COMBATLOG_FILTER_MINE
local COMBATLOG_FILTER_MY_PET = COMBATLOG_FILTER_MY_PET
local COMBATLOG_FILTER_FRIENDLY_UNITS = COMBATLOG_FILTER_FRIENDLY_UNITS
local COMBATLOG_FILTER_HOSTILE_UNITS = COMBATLOG_FILTER_HOSTILE_UNITS
local COMBATLOG_FILTER_HOSTILE_PLAYERS = COMBATLOG_FILTER_HOSTILE_PLAYERS
local COMBATLOG_FILTER_NEUTRAL_UNITS = COMBATLOG_FILTER_NEUTRAL_UNITS
local COMBATLOG_FILTER_UNKNOWN_UNITS = COMBATLOG_FILTER_UNKNOWN_UNITS
local COMBATLOG_FILTER_EVERYTHING = COMBATLOG_FILTER_EVERYTHING
local COMBATLOG = COMBATLOG
local AURA_TYPE_BUFF = AURA_TYPE_BUFF
local AURA_TYPE_DEBUFF = AURA_TYPE_DEBUFF
local SPELL_POWER_MANA = SPELL_POWER_MANA
local SPELL_POWER_RAGE = SPELL_POWER_RAGE
local SPELL_POWER_FOCUS = SPELL_POWER_FOCUS
local SPELL_POWER_ENERGY = SPELL_POWER_ENERGY
local SPELL_POWER_HAPPINESS = SPELL_POWER_HAPPINESS
local SPELL_POWER_RUNES = SPELL_POWER_RUNES
local SCHOOL_MASK_NONE = SCHOOL_MASK_NONE
local SCHOOL_MASK_PHYSICAL = SCHOOL_MASK_PHYSICAL
local SCHOOL_MASK_HOLY = SCHOOL_MASK_HOLY
local SCHOOL_MASK_FIRE = SCHOOL_MASK_FIRE
local SCHOOL_MASK_NATURE = SCHOOL_MASK_NATURE
local SCHOOL_MASK_FROST = SCHOOL_MASK_FROST
local SCHOOL_MASK_SHADOW = SCHOOL_MASK_SHADOW
local SCHOOL_MASK_ARCANE = SCHOOL_MASK_ARCANE
local COMBATLOG_LIMIT_PER_FRAME = COMBATLOG_LIMIT_PER_FRAME
local COMBATLOG_HIGHLIGHT_MULTIPLIER = COMBATLOG_HIGHLIGHT_MULTIPLIER
local COMBATLOG_DEFAULT_COLORS = COMBATLOG_DEFAULT_COLORS
local COMBATLOG_DEFAULT_SETTINGS = COMBATLOG_DEFAULT_SETTINGS
local COMBATLOG_ICON_RAIDTARGET1 = COMBATLOG_ICON_RAIDTARGET1
local COMBATLOG_ICON_RAIDTARGET2 = COMBATLOG_ICON_RAIDTARGET2
local COMBATLOG_ICON_RAIDTARGET3 = COMBATLOG_ICON_RAIDTARGET3
local COMBATLOG_ICON_RAIDTARGET4 = COMBATLOG_ICON_RAIDTARGET4
local COMBATLOG_ICON_RAIDTARGET5 = COMBATLOG_ICON_RAIDTARGET5
local COMBATLOG_ICON_RAIDTARGET6 = COMBATLOG_ICON_RAIDTARGET6
local COMBATLOG_ICON_RAIDTARGET7 = COMBATLOG_ICON_RAIDTARGET7
local COMBATLOG_ICON_RAIDTARGET8 = COMBATLOG_ICON_RAIDTARGET8
local COMBATLOG_EVENT_LIST = COMBATLOG_EVENT_LIST

local CombatLog_OnEvent		-- for later
local CombatLog_Object_IsA = CombatLog_Object_IsA


-- Create a dummy CombatLogQuickButtonFrame for line 803 of FloatingChatFrame.lua. It causes inappropriate show/hide behavior. Instead, we'll use our own frame display handling.
-- If there are more than 2 combat log frames, then the CombatLogQuickButtonFrame gets tied to the last frame tab's visibility status. Yuck! Let's just instead tie it to the combat log's tab.

local CombatLogQuickButtonFrame, CombatLogQuickButtonFrameProgressBar, CombatLogQuickButtonFrameTexture
_G.CombatLogQuickButtonFrame = CreateFrame("Frame", "CombatLogQuickButtonFrame", UIParent)

-- For debugging, remove for final commit
local function debug(...)
	local a,b,c,d,e,f,g,h,i,j,k = ...
	if select("#", ...) == 1 then
		b, a = a, "%s"		
	end
	ChatFrame1:AddMessage(a:format(
		tostring(b),
		tostring(c),
		tostring(d),
		tostring(e),
		tostring(f),
		tostring(g),
		tostring(i),
		tostring(j),
		tostring(k)
	))
end

local Blizzard_CombatLog_Update_QuickButtons
local Blizzard_CombatLog_Filters
local Blizzard_CombatLog_CurrentSettings
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
			name = QUICKBUTTON_NAME_SELF;
			hasQuickButton = true;
			quickButtonName = QUICKBUTTON_NAME_SELF;
			quickButtonDisplay = {
				solo = true;
				party = true;
				raid = true;
			};
			tooltip = QUICKBUTTON_NAME_SELF_TOOLTIP;

			-- Default Color and Formatting Options
			settings = CopyTable(COMBATLOG_DEFAULT_SETTINGS);

			-- Coloring
			colors = CopyTable(COMBATLOG_DEFAULT_COLORS);

			-- The actual client filters
			filters = {
				[1] = {
					eventList = {
					      ["ENVIRONMENTAL_DAMAGE"] = true,
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
					      ["SPELL_AURA_APPLIED"] = true,
					      ["SPELL_AURA_APPLIED_DOSE"] = true,
					      ["SPELL_AURA_REMOVED"] = true,
					      ["SPELL_AURA_REMOVED_DOSE"] = true,
					      ["SPELL_AURA_BROKEN"] = true,
						  ["SPELL_AURA_BROKEN_SPELL"] = true,
						  ["SPELL_AURA_REFRESH"] = true,
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
					      --["DAMAGE_SHIELD"] = true,
					      --["DAMAGE_SHIELD_MISSED"] = true,
					      --["DAMAGE_SPLIT"] = true,
					      ["PARTY_KILL"] = true,
					      ["UNIT_DIED"] = true,
					      ["UNIT_DESTROYED"] = true
					};
					sourceFlags = {
						[COMBATLOG_FILTER_MINE] = true,
						[COMBATLOG_FILTER_MY_PET] = true;
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
					      --["DAMAGE_SPLIT"] = true,
					      ["PARTY_KILL"] = true,
					      ["UNIT_DIED"] = true,
					      ["UNIT_DESTROYED"] = true
					};
					sourceFlags = nil;
					destFlags = {
						[COMBATLOG_FILTER_MINE] = true,
						[COMBATLOG_FILTER_MY_PET] = true;
					};
				};
			};
		};
		[2] = {
			-- Descriptive Information
			name = QUICKBUTTON_NAME_EVERYTHING;
			hasQuickButton = true;
			quickButtonName = QUICKBUTTON_NAME_EVERYTHING;
			quickButtonDisplay = {
				solo = true;
				party = true;
				raid = true;
			};
			tooltip = QUICKBUTTON_NAME_EVERYTHING_TOOLTIP;

			-- Settings
			settings = CopyTable(COMBATLOG_DEFAULT_SETTINGS);

			-- Coloring
			colors = CopyTable(COMBATLOG_DEFAULT_COLORS);

			-- The actual client filters
			filters = {
				[1] = {
					eventList = Blizzard_CombatLog_GenerateFullEventList();
					sourceFlags = Blizzard_CombatLog_GenerateFullFlagList(true);
					destFlags = nil;
				};
				[2] = {
					eventList = Blizzard_CombatLog_GenerateFullEventList();
					sourceFlags = nil;
					destFlags = Blizzard_CombatLog_GenerateFullFlagList(true);
				};
			};
		};
		[3] = {
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
					eventList = Blizzard_CombatLog_GenerateFullEventList();
					sourceFlags = Blizzard_CombatLog_GenerateFullFlagList(false);
					destFlags = nil;
				};
				[2] = {
					eventList = Blizzard_CombatLog_GenerateFullEventList();
					sourceFlags = nil;
					destFlags =  {
						[COMBATLOG_FILTER_MINE] = true,
						[COMBATLOG_FILTER_MY_PET] = true;
					};
				};
			};
		};
		[4] = {
			-- Descriptive Information
			name = QUICKBUTTON_NAME_KILLS;
			hasQuickButton = false;
			quickButtonName = QUICKBUTTON_NAME_KILLS;
			quickButtonDisplay = {
				solo = true;
				party = true;
				raid = true;
			};
			tooltip = QUICKBUTTON_NAME_KILLS_TOOLTIP;

			-- Settings
			settings = CopyTable(COMBATLOG_DEFAULT_SETTINGS);

			-- Coloring
			colors = CopyTable(COMBATLOG_DEFAULT_COLORS);

			-- The actual client filters
			filters = {
				[1] = {
					eventList = {
						["PARTY_KILL"] = true,
						["UNIT_DIED"] = true,
						["UNIT_DESTROYED"] = true
					};
					sourceFlags = Blizzard_CombatLog_GenerateFullFlagList(true);
					destFlags = nil;
				};
				[2] = {
					eventList = {
						["PARTY_KILL"] = true,
						["UNIT_DIED"] = true,
						["UNIT_DESTROYED"] = true
					};
					sourceFlags = nil;
					destFlags = Blizzard_CombatLog_GenerateFullFlagList(true);
				};
			};
		};
	};

	-- Current Filter
	currentFilter = 1;
};

local Blizzard_CombatLog_Filters = Blizzard_CombatLog_Filter_Defaults;
_G.Blizzard_CombatLog_Filters = Blizzard_CombatLog_Filters

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
		-- Only use the first filter's eventList
		eventList = config.filters[1].eventList;
		if ( eventList ) then
			for k2,v2 in pairs(eventList) do 
				if ( v2 == true ) then
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
		-- Log to the window
		local text, r, g, b, a = CombatLog_OnEvent(Blizzard_CombatLog_CurrentSettings, CombatLogGetCurrentEntry());
		-- NOTE: be sure to pass in nil for the color id or the color id may override the r, g, b values for this message
		COMBATLOG:AddMessage( text, r, g, b, nil, true );

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
			spellMenu[3] = spellMenu2[3];
			-- These 2 calls update the menus in their respective do-end blocks
			spellMenu[4] = Blizzard_CombatLog_FormattingMenu(Blizzard_CombatLog_Filters.currentFilter);
			spellMenu[5] = Blizzard_CombatLog_MessageTypesMenu(Blizzard_CombatLog_Filters.currentFilter);
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
				func = function ( arg1, arg2, checked )
					Blizzard_CombatLog_MenuHelper ( checked, "SWING_DAMAGE", "SWING_MISSED" );
				end;
				menuList = {
					[1] = {
						text = "Damage";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SWING_DAMAGE");end;
						keepShownOnClick = true;
						func = function ( arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SWING_DAMAGE" );
						end;
					};
					[2] = {
						text = "Failure";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SWING_MISSED"); end;
						keepShownOnClick = true;
						func = function ( arg1, arg2, checked )
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
				func = function ( arg1, arg2, checked )
					Blizzard_CombatLog_MenuHelper ( checked, "RANGED_DAMAGE", "RANGED_MISSED" );
				end;
				menuList = {
					[1] = {
						text = "Damage";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "RANGE_DAMAGE"); end;
						keepShownOnClick = true;
						func = function ( arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "RANGE_DAMAGE" );
						end;
					};
					[2] = {
						text = "Failure";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "RANGE_MISSED"); end;
						keepShownOnClick = true;
						func = function ( arg1, arg2, checked )
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
				func = function ( arg1, arg2, checked )
					Blizzard_CombatLog_MenuHelper ( checked, "SPELL_DAMAGE", "SPELL_MISSED", "SPELL_HEAL", "SPELL_ENERGIZE", "SPELL_DRAIN", "SPELL_LEECH", "SPELL_INTERRUPT", "SPELL_EXTRA_ATTACKS",  "SPELL_CAST_START", "SPELL_CAST_SUCCESS", "SPELL_CAST_FAILED", "SPELL_INSTAKILL", "SPELL_DURABILITY_DAMAGE" );
				end;
				menuList = {
					[1] = {
						text = "Damage";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_DAMAGE"); end;
						keepShownOnClick = true;
						func = function ( arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_DAMAGE" );
						end;
					};
					[2] = {
						text = "Failure";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_MISSED"); end;
						keepShownOnClick = true;
						func = function ( arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_MISSED" );
						end;
					};
					[3] = {
						text = "Heals";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_HEAL"); end;
						keepShownOnClick = true;
						func = function ( arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_HEAL" );
						end;
					};
					[4] = {
						text = "Power Gains";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_ENERGIZE"); end;
						keepShownOnClick = true;
						func = function ( arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_ENERGIZE" );
						end;
					};
					[4] = {
						text = "Drains";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_DRAIN", "SPELL_LEECH"); end;
						keepShownOnClick = true;
						func = function ( arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_DRAIN", "SPELL_LEECH" );
						end;
					};
					[5] = {
						text = "Interrupts";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_INTERRUPT"); end;
						keepShownOnClick = true;
						func = function ( arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_INTERRUPT" );
						end;
					};
					[6] = {
						text = "Extra Attacks";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_EXTRA_ATTACKS"); end;
						keepShownOnClick = true;
						func = function ( arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_EXTRA_ATTACKS" );
						end;
					};
					[7] = {
						text = "Casting";
						hasArrow = true;
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_CAST_START", "SPELL_CAST_SUCCESS", "SPELL_CAST_FAILED"); end;
						keepShownOnClick = true;
						func = function ( arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_CAST_START", "SPELL_CAST_SUCCESS", "SPELL_CAST_FAILED");
						end;
						menuList = {
							[1] = {
								text = "Start";
								checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_CAST_START"); end;
								keepShownOnClick = true;
								func = function ( arg1, arg2, checked )
									Blizzard_CombatLog_MenuHelper ( checked, "SPELL_CAST_START" );
								end;
							};
							[2] = {
								text = "Success";
								checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_CAST_SUCCESS"); end;
								keepShownOnClick = true;
								func = function ( arg1, arg2, checked )
									Blizzard_CombatLog_MenuHelper ( checked, "SPELL_CAST_SUCCESS" );
								end;
							};
							[3] = {
								text = "Failed";
								checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_CAST_FAILED"); end;
								keepShownOnClick = true;
								func = function ( arg1, arg2, checked )
									Blizzard_CombatLog_MenuHelper ( checked, "SPELL_CAST_FAILED" );
								end;
							};
						};
					};
					[8] = {
						text = "Special";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_INSTAKILL", "SPELL_DURABILITY_DAMAGE"); end;
						keepShownOnClick = true;
						func = function ( arg1, arg2, checked )
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
				func = function ( arg1, arg2, checked )
					Blizzard_CombatLog_MenuHelper ( checked, "SPELL_AURA_APPLIED", "SPELL_AURA_BROKEN", "SPELL_AURA_REFRESH", "SPELL_AURA_BROKEN_SPELL", "SPELL_AURA_APPLIED_DOSE", "SPELL_AURA_REMOVED", "SPELL_AURA_REMOVED_DOSE", "SPELL_DISPEL", "SPELL_STOLEN",  "ENCHANT_APPLIED", "ENCHANT_REMOVED" );
				end;
				menuList = {
					[1] = {
						text = "Applied";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_AURA_APPLIED", "SPELL_AURA_BROKEN", "SPELL_AURA_REFRESH", "SPELL_AURA_BROKEN_SPELL", "SPELL_AURA_APPLIED_DOSE"); end;
						keepShownOnClick = true;
						func = function ( arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_AURA_APPLIED", "SPELL_AURA_BROKEN", "SPELL_AURA_REFRESH", "SPELL_AURA_BROKEN_SPELL", "SPELL_AURA_APPLIED_DOSE",  "ENCHANT_APPLIED" );
						end;
					};
					[2] = {
						text = "Removed";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_AURA_REMOVED", "SPELL_AURA_REMOVED_DOSE",  "ENCHANT_REMOVED" ); end;
						keepShownOnClick = true;
						func = function ( arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_AURA_REMOVED", "SPELL_AURA_REMOVED_DOSE" );
						end;
					};
					[3] = {
						text = "Dispelled";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_DISPEL"); end;
						keepShownOnClick = true;
						func = function ( arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_DISPEL" );
						end;
					};
					[4] = {
						text = "Stolen";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_STOLEN"); end;
						keepShownOnClick = true;
						func = function ( arg1, arg2, checked )
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
				func = function ( arg1, arg2, checked )
					Blizzard_CombatLog_MenuHelper ( checked, "SPELL_PERIODIC_DAMAGE", "SPELL_PERIODIC_MISSED", "SPELL_PERIODIC_DRAIN", "SPELL_PERIODIC_ENERGIZE", "SPELL_PERIODIC_HEAL", "SPELL_PERIODIC_LEECH" );
				end;
				menuList = {
					[1] = {
						text = "Damage";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_PERIODIC_DAMAGE"); end;
						keepShownOnClick = true;
						func = function ( arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_PERIODIC_DAMAGE" );
						end;
					};
					[2] = {
						text = "Failure";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_PERIODIC_MISSED" ); end;
						keepShownOnClick = true;
						func = function ( arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_PERIODIC_MISSED" );
						end;
					};
					[3] = {
						text = "Heals";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_PERIODIC_HEAL"); end;
						keepShownOnClick = true;
						func = function ( arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_PERIODIC_HEAL" );
						end;
					};
					[4] = {
						text = "Other";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_PERIODIC_DRAIN", "SPELL_PERIODIC_ENERGIZE", "SPELL_PERIODIC_LEECH"); end;
						keepShownOnClick = true;
						func = function ( arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_PERIODIC_DRAIN", "SPELL_PERIODIC_ENERGIZE", "SPELL_PERIODIC_LEECH" );
						end;
					};						
				};
			};
			[6] = {
				text = "Other";
				hasArrow = true;
				checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "PARTY_KILL", "UNIT_DIED", "UNIT_DESTROYED", "DAMAGE_SPLIT", "ENVIRONMENTAL_DAMAGE" ); end;
				keepShownOnClick = true;
				func = function ( arg1, arg2, checked )
					Blizzard_CombatLog_MenuHelper ( checked, "PARTY_KILL", "UNIT_DIED", "UNIT_DESTROYED", "DAMAGE_SPLIT", "ENVIRONMENTAL_DAMAGE"  );
				end;
				menuList = {
					[1] = {
						text = "Kills";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "PARTY_KILL"); end;
						keepShownOnClick = true;
						func = function ( arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "PARTY_KILL" );
						end;
					};
					[2] = {
						text = "Deaths";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "UNIT_DIED", "UNIT_DESTROYED"); end;
						keepShownOnClick = true;
						func = function ( arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "UNIT_DIED", "UNIT_DESTROYED" );
						end;
					};
					[3] = {
						text = "Damage Split";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "DAMAGE_SPLIT"); end;
						keepShownOnClick = true;
						func = function ( arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "DAMAGE_SPLIT" );
						end;
					};
					[4] = {
						text = "Environmental Damage";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "ENVIRONMENTAL_DAMAGE"); end;
						keepShownOnClick = true;
						func = function ( arg1, arg2, checked )
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
				func = function(arg1, arg2, checked)
					filter.fullText = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Timestamp";
				checked = function() return filter.timestamp; end;
				func = function(arg1, arg2, checked)
					filter.timestamp = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Unit Name Coloring";
				checked = function() return filter.unitColoring; end;
				func = function(arg1, arg2, checked)
					filter.unitColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Line Coloring";
				checked = function() return  filter.lineColoring; end;
				func = function(arg1, arg2, checked)
					filter.lineColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Line Highlighting";
				checked = function() return  filter.lineHighlighting; end;
				func = function(arg1, arg2, checked)
					filter.lineHighlighting = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Ability Coloring";
				checked = function() return filter.abilityColoring; end;
				func = function(arg1, arg2, checked)
					filter.abilityColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Ability-by-School Coloring";
				checked = function() return filter.abilitySchoolColoring; end;
				--disabled = not filter.abilityColoring;
				func = function(arg1, arg2, checked)
					filter.abilitySchoolColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Ability-by-Actor Coloring";
				checked = function() return filter.abilityActorColoring; end;
				func = function(arg1, arg2, checked)
					filter.abilityActorColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Ability Highlighting";
				checked = function() return filter.abilityHighlighting; end;
				func = function(arg1, arg2, checked)
					filter.abilityHighlighting = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Action Coloring";
				checked = function() return filter.actionColoring; end;
				func = function(arg1, arg2, checked)
					filter.actionColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Action-by-School Coloring";
				checked = function() return filter.actionSchoolColoring; end;
				func = function(arg1, arg2, checked)
					filter.actionSchoolColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Action-by-Actor Coloring";
				checked = function() return filter.actionActorColoring; end;
				--disabled = not filter.abilityColoring;
				func = function(arg1, arg2, checked)
					filter.actionActorColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Action Highlighting";
				checked = function() return filter.actionHighlighting; end;
				--disabled = not filter.abilityColoring;
				func = function(arg1, arg2, checked)
					filter.actionHighlighting = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Damage Coloring";
				checked = function() return filter.amountColoring; end;
				func = function(arg1, arg2, checked)
					filter.amountColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Damage-by-School Coloring";
				checked = function() return filter.amountSchoolColoring; end;
				--disabled = not filter.amountColoring;
				func = function(arg1, arg2, checked)
					filter.amountSchoolColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Damage-by-Actor Coloring";
				checked = function() return filter.amountActorColoring; end;
				--disabled = not filter.amountColoring;
				func = function(arg1, arg2, checked)
					filter.amountActorColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Damage Highlighting";
				checked = function() return filter.amountHighlighting; end;
				func = function(arg1, arg2, checked)
					filter.amountHighlighting = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},				
			{
				text = "Color School Names";
				checked = function() return filter.schoolNameColoring; end;
				func = function(arg1, arg2, checked)
					filter.schoolNameColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "School Name Highlighting";
				checked = function() return filter.schoolNameHighlighting; end;
				func = function(arg1, arg2, checked)
					filter.schoolNameHighlighting = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "White Swing Rule";
				checked = function() return filter.noMeleeSwingColoring; end;
				func = function(arg1, arg2, checked)
					filter.noMeleeSwingColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Misses Colored Rule";
				checked = function() return filter.missColoring; end;
				func = function(arg1, arg2, checked)
					filter.missColoring = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Braces";
				checked = function() return filter.braces; end;
				func = function(arg1, arg2, checked)
					filter.braces = checked;
					Blizzard_CombatLog_QuickButton_OnClick(currentFilter)
				end;
				keepShownOnClick = true;
			},
			{
				text = "Refiltering";
				checked = function() return filter.showHistory; end;
				func = function(arg1, arg2, checked)
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
		if ( (unitGUID == UnitGUID("player")) and (getglobal("COMBAT_LOG_UNIT_YOU_ENABLED") == "1") ) then
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
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatEdit_InsertLink(GetSpellLink(spellId));
		else
			ChatFrame_OpenChat(GetSpellLink(spellId));
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

	return settings.colors.schoolColoring[school] or defaultColorArray
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
local function CombatLog_String_PowerType(powerType)
	if ( not powerType ) then
		return "";
	elseif ( powerType == SPELL_POWER_MANA ) then
		return STRING_POWER_MANA;
	elseif ( powerType == SPELL_POWER_RAGE ) then
		return STRING_POWER_RAGE;
	elseif ( powerType == SPELL_POWER_ENERGY ) then
		return STRING_POWER_ENERGY;
	elseif ( powerType == SPELL_POWER_FOCUS ) then
		return STRING_POWER_FOCUS;
	elseif ( powerType == SPELL_POWER_HAPPINESS ) then
		return STRING_POWER_HAPPINESS;
	elseif ( powerType == SPELL_POWER_RUNES ) then
		return STRING_POWER_RUNES;
	end
end
_G.CombatLog_String_PowerType = CombatLog_String_PowerType

local SCHOOL_STRINGS = {
	STRING_SCHOOL_PHYSICAL,
	STRING_SCHOOL_HOLY,
	STRING_SCHOOL_FIRE,
	STRING_SCHOOL_NATURE,
	STRING_SCHOOL_FROST,
	STRING_SCHOOL_SHADOW,
	STRING_SCHOOL_ARCANE
}

local function CombatLog_String_SchoolString(school)
	if ( not school or school == SCHOOL_MASK_NONE ) then
		return STRING_SCHOOL_UNKNOWN;
	end

	local schoolString
	local mask = 1;
	for i = 1, 7 do
		if bit_band(school, mask) == mask then
			schoolString = schoolString and (schoolString .. "+" .. SCHOOL_STRINGS[i]) or SCHOOL_STRINGS[i]
		end
		mask = mask * 2;
	end
	return schoolString or STRING_SCHOOL_UNKNOWN
end
_G.CombatLog_String_SchoolString = CombatLog_String_SchoolString

local function CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, textMode, spellId )
	local resultStr;
	-- Result String formatting
	if ( resisted or blocked or absorbed or critical or glancing or crushing ) then
		resultStr = "";

		local tMode = "TEXT_MODE_"..textMode
		local result  = _G[tMode.."_STRING_RESULT"]
		local rFormat = _G[tMode.."_STRING_RESULT_FORMAT"]
		local subStr
		if resisted or blocked or absorbed then
			subStr = strreplace(result, "$resultString", rFormat)
		end
		if ( resisted ) then
			resultStr = strreplace(resultStr..subStr, "$resultAmount", resisted);
			resultStr = strreplace(resultStr, "$resultType", _G[tMode.."_STRING_RESULT_RESISTED"]);
		end
		if ( blocked ) then
			resultStr = strreplace(resultStr..subStr,"$resultAmount", blocked);
			resultStr = strreplace(resultStr,"$resultType", _G[tMode.."_STRING_RESULT_BLOCKED"]);
		end
		if ( absorbed ) then
			resultStr = strreplace(resultStr..subStr,"$resultAmount", absorbed);
			resultStr = strreplace(resultStr,"$resultType", _G[tMode.."_STRING_RESULT_ABSORBED"]);
		end
		if ( glancing ) then
			resultStr = strreplace(resultStr..result,"$resultString", _G[tMode.."_STRING_RESULT_GLANCING"]);
		end
		if ( crushing ) then
			resultStr = strreplace(resultStr..result,"$resultString", _G[tMode.."_STRING_RESULT_CRUSHING"]);
		end
		if ( critical ) then
			if ( spellId ) then
				resultStr = strreplace(resultStr..result,"$resultString", _G[tMode.."_STRING_RESULT_CRITICAL_SPELL"]);
			else
				resultStr = strreplace(resultStr..result,"$resultString", _G[tMode.."_STRING_RESULT_CRITICAL"]);
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

	local iconString = TEXT_MODE_A_STRING_TOKEN_ICON;
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
			iconString = strreplace ( iconString, "$icon", TEXT_MODE_A_STRING_SOURCE_ICON);
		else 
			iconString = strreplace ( iconString, "$icon", TEXT_MODE_A_STRING_DEST_ICON );
		end

		iconString = strreplace ( iconString, "$iconTexture", icon);
		iconString = strreplace ( iconString, "$iconBit", iconBit);

	-- Otherwise remove the token
	else
		iconString = "";
	end

	return iconString;
end
_G.CombatLog_String_GetIcon = CombatLog_String_GetIcon

--
--	Obtains the appropriate unit token for a GUID
--
local function CombatLog_String_GetToken (unitGUID, unitName, unitFlags)
	-- 
	-- Code to display Defias Pillager (A), Defias Pillager (B), etc
	--
	--[[
	local newName = TEXT_MODE_A_STRING_TOKEN_UNIT;
	-- Use the local cache if possible
	if ( Blizzard_CombatLog_UnitTokens[unitGUID] ) then 
		-- For unique creatures, hide the token
		if ( Blizzard_CombatLog_UnitTokens[unitGUID] == unitName ) then
			return unitName;
		end
		newName = strreplace ( newName, "$token", Blizzard_CombatLog_UnitTokens[unitGUID] );
		newName = strreplace ( newName, "$unitName", unitName );
	else
		if ( not Blizzard_CombatLog_UnitTokens[unitName] or Blizzard_CombatLog_UnitTokens[unitName] > 26*26) then
			Blizzard_CombatLog_UnitTokens[unitName] = 1;
			Blizzard_CombatLog_UnitTokens[unitGUID] = unitName;
			newName = unitName;
		else
			Blizzard_CombatLog_UnitTokens[unitName] = Blizzard_CombatLog_UnitTokens[unitName] + 1;
			if ( Blizzard_CombatLog_UnitTokens[unitName] > 26 ) then
				Blizzard_CombatLog_UnitTokens[unitGUID] = 
					string.char ( TEXT_MODE_A_STRING_TOKEN_BASE + math.floor(Blizzard_CombatLog_UnitTokens[unitName] / 26) )..
					string.char ( TEXT_MODE_A_STRING_TOKEN_BASE + math.fmod(Blizzard_CombatLog_UnitTokens[unitName], 26) );
			else
				Blizzard_CombatLog_UnitTokens[unitGUID] = string.char ( TEXT_MODE_A_STRING_TOKEN_BASE + math.fmod(Blizzard_CombatLog_UnitTokens[unitName], 26) );
			end

			newName = strreplace ( newName, "$token", Blizzard_CombatLog_UnitTokens[unitGUID] );
			newName = strreplace ( newName, "$unitName", unitName );
		end
	end
	]]

	-- Shortcut since the above block is commented out.
	
	-- newName = unitName;

	return unitName;
end
_G.CombatLog_String_GetToken = CombatLog_String_GetToken

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

function CombatLog_OnEvent(filterSettings, timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
	-- [environmentalDamageType]
	-- [spellName, spellRank, spellSchool]
	-- [damage, school, [resisted, blocked, absorbed, crit, glancing, crushing]]

	-- Upvalue this, we're gonna use it a lot
	local settings = filterSettings.settings
	
	local lineColor = defaultCombatLogLineColor
	local sourceColor, destColor = nil, nil;

	local braceColor = "FFFFFFFF";
	local abilityColor = "FFFFFF00";

	-- Processing variables
	local textMode = settings.textMode;
	local timestampEnabled = settings.timestamp;
	local hideBuffs = settings.hideBuffs;
	local hideDebuffs = settings.hideDebuffs;
	local sourceEnabled = true;
	local destEnabled = true;
	local spellEnabled = true;
	local actionEnabled = true;
	local valueEnabled = true;
	local valueTypeEnabled = true;
	local resultEnabled = true;
	local powerTypeEnabled = true;
	local itemEnabled = false;
	local extraSpellEnabled = false;

	-- Get the initial string
	local combatString = "Combat Error!";
	local schoolString;
	local resultStr;
	
	--- Get the general string order
	combatString = _G["TEXT_MODE_"..textMode.."_STRING_1"];

	-- Support for multiple string orders
	if ( _G["ACTION_"..event.."_MASTER"] ) then
		local newCombatString = _G["TEXT_MODE_"..textMode.."_STRING_".. _G["ACTION_"..event.."_MASTER"]];
		if ( newCombatString ) then
			combatString = newCombatString;
		end
	end

	-- Replacements to do: 
	-- * Src, Dest, Action, Spell, Amount, Result

	-- Spell standard order
	local spellId, spellName, spellSchool;
	local extraSpellId, extraSpellName, extraSpellSchool;

	-- For Melee/Ranged swings and enchants
	local nameIsNotSpell, extraNameIsNotSpell; 

	-- Damage standard order
	local amount, school, resisted, blocked, absorbed, critical, glancing, crushing;
	-- Miss argument order
	local missType;
	-- Aura arguments
	local auraType; -- BUFF or DEBUFF

	-- Enchant arguments
	local itemId, itemName;

	-- Special Spell values
	local valueType = 1;  -- 1 = School, 2 = Power Type
	local extraAmount; -- Used for Drains and Leeches
	local powerType; -- Used for energizes, drains and leeches
	local environmentalType; -- Used for environmental damage
	local message; -- Used for server spell messages
	local originalEvent = event; -- Used for spell links

	-- Generic disabling stuff
	if ( not sourceName or CombatLog_Object_IsA(sourceFlags, COMBATLOG_OBJECT_NONE) ) then
		sourceEnabled = false;
	end
	if ( not destName or CombatLog_Object_IsA(destFlags, COMBATLOG_OBJECT_NONE) ) then
		destEnabled = false;
	end

	local subVal = strsub(event, 1, 5)
	local textModeString = "TEXT_MODE_"..textMode.."_STRING_"
	
	-- Swings
	if ( subVal == "SWING" ) then
		spellName = ACTION_SWING;
		nameIsNotSpell = true;
	end
	
	-- Break out the arguments into variable
	if ( event == "SWING_DAMAGE" ) then 
		-- Damage standard
		amount, school, resisted, blocked, absorbed, critical, glancing, crushing = ...

		-- Parse the result string
		resultStr = CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, textMode, spellId );

		if ( not resultStr ) then
			resultEnabled = false
		end

	elseif ( event == "SWING_MISSED" ) then 
		spellName = ACTION_SWING;

		-- Damage standard
		missType = ...

		-- Result String
		resultStr = strreplace(_G[textModeString .. "RESULT"],"$resultString", _G["ACTION_"..event.."_"..missType]);
		
		-- Miss Type
		if ( settings.fullText ) then
			event = event.."_"..missType;
		end

		-- Disable appropriate sections
		nameIsNotSpell = true;
		valueEnabled = false;
		resultEnabled = true;
		
	elseif ( subVal == "SPELL" ) then	-- Spell standard arguments
		spellId, spellName, spellSchool = ...;

		if ( event == "SPELL_DAMAGE" ) then
			-- Damage standard
			amount, school, resisted, blocked, absorbed, critical, glancing, crushing = select(4, ...);

			-- Parse the result string
			resultStr = CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, textMode, spellId );

			if ( not resultStr ) then
				resultEnabled = false
			end
		elseif ( event == "SPELL_MISSED" ) then 
			-- Miss type
			missType = select(4, ...);

			-- Result String
			resultStr = strreplace(_G[textModeString .. "RESULT"],"$resultString", _G["ACTION_"..event.."_"..missType]);

			-- Miss Event
			if ( settings.fullText ) then
				event = event.."_"..missType;
			end

			-- Disable appropriate sections
			valueEnabled = false;
			resultEnabled = true;
		elseif ( event == "SPELL_HEAL" ) then 
			-- Did the heal crit?
			amount, critical = select(4, ...);
			
			-- Parse the result string
			resultStr = CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, textMode, spellId );

			if ( not resultStr ) then
				resultEnabled = false
			end

			-- Temporary Spell School Hack
			school = spellSchool;

			-- Disable appropriate sections
			valueEnabled = true;
			valueTypeEnabled = true;
		elseif ( event == "SPELL_ENERGIZE" ) then 
			-- Set value type to be a power type
			valueType = 2;

			-- Did the heal crit?
			amount, powerType = select(4, ...);
			
			-- Parse the result string
			resultStr = CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, textMode, spellId );

			if ( not resultStr ) then
				resultEnabled = false
			end

			-- Disable appropriate sections
			valueEnabled = true;
			valueTypeEnabled = true;
		elseif ( strsub(event, 1, 14) == "SPELL_PERIODIC" ) then
			
			if ( event == "SPELL_PERIODIC_MISSED" ) then
				-- Miss type
				missType = select(4, ...);
				
				-- Result String
				resultStr = strreplace(_G[textModeString .. "RESULT"],"$resultString", _G["ACTION_"..event.."_"..missType]);

				-- Miss Event
				if ( settings.fullText ) then
					event = event.."_"..missType;
				end

				-- Disable appropriate sections
				valueEnabled = false;
				resultEnabled = true;
			elseif ( event == "SPELL_PERIODIC_DAMAGE" ) then
				-- Damage standard
				amount, school, resisted, blocked, absorbed, critical, glancing, crushing = select(4, ...);

				-- Parse the result string
				resultStr = CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, textMode, spellId );

				-- Disable appropriate sections
				if ( not resultStr ) then
					resultEnabled = false
				end
			elseif ( event == "SPELL_PERIODIC_HEAL" ) then
				-- Did the heal crit?
				amount, critical = select(4, ...);
				
				-- Parse the result string
				resultStr = CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, textMode, spellId );

				if ( not resultStr ) then
					resultEnabled = false
				end

				-- Temporary Spell School Hack
				school = spellSchool;

				-- Disable appropriate sections
				valueEnabled = true;
				valueTypeEnabled = true;
			elseif ( event == "SPELL_PERIODIC_DRAIN" ) then
				-- Special attacks
				amount, powerType, extraAmount = select(4, ...);

				-- Set value type to be a power type
				valueType = 2;

				-- Result String
				--resultStr = getglobal(textModeString .. "RESULT");
				--resultStr = strreplace(resultStr,"$resultString", getglobal("ACTION_"..event.."_RESULT")); 

				-- Disable appropriate sections
				if ( not resultStr ) then
					resultEnabled = false
				end
				valueEnabled = true;
				schoolEnabled = false;
			elseif ( event == "SPELL_PERIODIC_LEECH" ) then
				-- Special attacks
				amount, powerType, extraAmount = select(4, ...);

				-- Set value type to be a power type
				valueType = 2;

				-- Result String
				resultStr = strreplace(_G[textModeString .. "RESULT"], "$resultString", _G["ACTION_"..event.."_RESULT"]); 

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
				amount, powerType = select(4, ...);
				
				-- Parse the result string
				--resultStr = getglobal(textModeString .. "RESULT");
				--resultStr = strreplace(resultStr,"$resultString", getglobal("ACTION_"..event.."_RESULT")); 

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
			-- Disable appropriate types
			resultEnabled = false;
			valueEnabled = false;
		elseif ( event == "SPELL_CAST_SUCCESS" ) then
			if ( not destName ) then
				destEnabled = false;
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
			resultStr = strreplace(_G[textModeString .. "RESULT"],"$resultString", missType);

			-- Disable appropriate sections
			valueEnabled = false;
			destEnabled = false;

			if ( not resultStr ) then
				resultEnabled = false;
			end
		elseif ( event == "SPELL_DRAIN" ) then		-- Special Spell effects
			-- Special attacks
			amount, powerType, extraAmount = select(4, ...);

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
			amount, powerType, extraAmount = select(4, ...);

			-- Set value type to be a power type
			valueType = 2;

			-- Result String
			resultStr = _G[textModeString .. "RESULT"];
			if ( resultStr ) then
				resultStr = strreplace(resultStr, "$resultString", _G["ACTION_"..event.."_RESULT"]); 
			end

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
				combatString = strreplace(combatString, "$value", "$extraSpell");
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
				combatString = strreplace(combatString, "$value", "$extraSpell");
			end

			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
		elseif ( event == "SPELL_DISPEL" or event == "SPELL_STOLEN" ) then
			-- Extra Spell standard, Aura standard
			extraSpellId, extraSpellName, extraSpellSchool, auraType = select(4, ...);

			-- Event Type
			event = event.."_"..auraType;

			-- Replace the value token with a spell token
			if ( extraSpellId ) then
				extraSpellEnabled = true;
				combatString = strreplace(combatString, "$value", "$extraSpell");
			end

			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
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
			event = event.."_"..auraType;

			-- Replace the value token with a spell token
			if ( extraSpellId ) then
				extraSpellEnabled = true;
				combatString = strreplace(combatString, "$value", "$extraSpell");
			end
			
			-- Support for multiple string orders
			if ( _G["ACTION_"..event.."_MASTER"] ) then
				local newCombatString = _G[textModeString .. _G["ACTION_"..event.."_MASTER"]];
				if ( newCombatString ) then
					combatString = newCombatString;
				end
			end

			-- Swap Source with Dest
			sourceName, destName = destName, sourceName;
			sourceGUID, destGUID = destGUID, sourceGUID;
			sourceFlags, destFlags = destFlags, sourceFlags;
			
			-- Disable appropriate sections
			if ( auraType == AURA_TYPE_BUFF ) then
				sourceEnabled = true;
				destEnabled = false;
			else
				sourceEnabled = false;
				destEnabled = true;
			end
			resultEnabled = false;
			valueEnabled = false;
		elseif ( event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED" or event == "SPELL_AURA_REFRESH") then		-- Aura Events
			-- Aura standard
			auraType = select(4, ...);

			-- Abort if buff/debuff is not set to true
			if ( hideBuffs and auraType == AURA_TYPE_BUFF ) then
				return;
			elseif ( hideDebuffs and auraType == AURA_TYPE_DEBUFF ) then
				return;
			end

			-- Event Type
			event = event.."_"..auraType;

			-- Support for multiple string orders
			if ( _G["ACTION_"..event.."_MASTER"] ) then
				local newCombatString = _G[textModeString .. _G["ACTION_"..event.."_MASTER"]];
				if ( newCombatString ) then
					combatString = newCombatString;
				end
			end

			-- Swap Source with Dest
			sourceName = destName;
			sourceGUID = destGUID;
			sourceFlags = destFlags;
			
			-- Disable appropriate sections
			if ( auraType == AURA_TYPE_BUFF ) then
				sourceEnabled = true;
				destEnabled = false;
			else
				sourceEnabled = false;
				destEnabled = true;
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
			event = event.."_"..auraType;

			-- Support for multiple string orders
			if ( _G["ACTION_"..event.."_MASTER"] ) then
				local newCombatString = _G[textModeString .. _G["ACTION_"..event.."_MASTER"]];
				if ( newCombatString ) then
					combatString = newCombatString;
				end
			end

			-- Swap Source with Dest
			sourceName = destName;
			sourceGUID = destGUID;
			sourceFlags = destFlags;

			-- Disable appropriate sections
			resultEnabled = false;
			sourceEnabled = false;
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
			amount, school, resisted, blocked, absorbed, critical, glancing, crushing = select(4, ...);

			-- Parse the result string
			resultStr = CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, textMode, spellId );

			if ( not resultStr ) then
				resultEnabled = false
			end

			-- Disable appropriate sections
			nameIsNotSpell = true;
		elseif ( event == "RANGE_MISSED" ) then 
			-- Damage standard
			missType = select(4, ...);

			-- Result String
			resultStr = strreplace(_G[textModeString .. "RESULT"],"$resultString", _G["ACTION_"..event.."_"..missType]);
			
			-- Miss Type
			if ( settings.fullText ) then
				event = event.."_"..missType;
			end

			-- Disable appropriate sections
			valueEnabled = false;
			resultEnabled = true;
		end
	elseif ( event == "DAMAGE_SHIELD" ) then	-- Damage Shields
		-- Spell standard, Damage standard
		spellId, spellName, spellSchool, amount, school, resisted, blocked, absorbed, critical, glancing, crushing = ...;

		-- Parse the result string
		resultStr = CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, textMode, spellId );

		-- Disable appropriate sections
		if ( not resultStr ) then
			resultEnabled = false
		end
	elseif ( event == "DAMAGE_SHIELD_MISSED" ) then
		-- Spell standard, Miss type
		spellId, spellName, spellSchool, missType = ...;

		-- Result String
		resultStr = strreplace(_G[textModeString .. "RESULT"],"$resultString", _G["ACTION_"..event.."_"..missType]);

		-- Miss Event
		if ( settings.fullText ) then
			event = event.."_"..missType;
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
	elseif ( event == "ENCHANT_APPLIED" ) then	
		-- Get the enchant name, item id and item name
		spellName, itemId, itemName = ...;
		nameIsNotSpell = true;

		-- Replace the value token with an item token
		combatString = strreplace(combatString, "$value", "$item");

		-- Disable appropriate sections
		itemEnabled = true;
		resultEnabled = false;
	elseif ( event == "ENCHANT_REMOVED" ) then
		-- Get the enchant name, item id and item name
		spellName, itemId, itemName = ...;
		nameIsNotSpell = true;

		-- Replace the value token with an item token
		combatString = strreplace(combatString, "$value", "$item");

		-- Disable appropriate sections
		itemEnabled = true;
		resultEnabled = false;
		sourceEnabled = false;
		
	elseif ( event == "UNIT_DIED" or event == "UNIT_DESTROYED" ) then
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
		--Environemental Type, Damage standard
		environmentalType, amount, school, resisted, blocked, absorbed, critical, glancing, crushing = ...

		-- Miss Event
		spellName = _G["ACTION_"..event.."_"..environmentalType];
		spellSchool = school;
		nameIsNotSpell = true;

		-- Parse the result string
		resultStr = CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, textMode, spellId );

		-- Environmental Event
		if ( settings.fullText ) then
			event = event.."_"..environmentalType;
		end

		if ( not resultStr ) then
			resultEnabled = false;
		end
	elseif ( event == "DAMAGE_SPLIT" ) then
		-- Spell Standard Arguments, Damage standard
		spellId, spellName, spellSchool, amount, school, resisted, blocked, absorbed, critical, glancing, crushing = ...;

		-- Parse the result string
		resultStr = CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, textMode, spellId );

		if ( not resultStr ) then
			resultEnabled = false
		end
	end

	-- Throw away all of the assembled strings and just grab a premade one
	if ( settings.fullText ) then
		local combatStringEvent = "ACTION_"..event.."_FULL_TEXT";

		-- Get the base string
		if ( _G[combatStringEvent] ) then
			combatString = _G[combatStringEvent];
		end

		-- Set any special cases
		if ( not sourceEnabled ) then
			combatStringEvent = combatStringEvent.."_NO_SOURCE";
			sourceEnabled = false;
		end
		if ( not destEnabled ) then
			combatStringEvent = combatStringEvent.."_NO_DEST";
			destEnabled = false;
		end

		-- Get the special cased string
		if ( _G[combatStringEvent] ) then
			combatString = _G[combatStringEvent];
		end
		-- Reapply the timestamp
		if (timestampEnabled) then
			combatString = _G[textModeString .. "TIMESTAMP"].." "..combatString;
		end

		sourceEnabled = true;
		destEnabled = true;
		spellEnabled = true;
		valueEnabled = true;
	end

	-- Remove Timestamp
	if ( not timestampEnabled ) then 
		combatString = strreplace(combatString,"$timestamp","");
	else
		combatString = strreplace(combatString,"$timestamp", _G[textModeString .. "TIMESTAMP"]);
	end

	-- Remove Source
	if ( not sourceEnabled ) then 
		combatString = strreplace(combatString,"$source","");
	else
		combatString = strreplace(combatString,"$source", _G[textModeString .. "SOURCE"]);
		combatString = strreplace(combatString,"$sourceString", _G[textModeString .. "SOURCE_UNIT"]);
	end

	-- Remove Dest
	if ( not destEnabled ) then 
		combatString = strreplace(combatString,"$dest","");
	else
		combatString = strreplace(combatString,"$dest", _G[textModeString .. "DEST"]);
		combatString = strreplace(combatString,"$destString", _G[textModeString .. "DEST_UNIT"]);
	end

	-- Remove Spell
	if ( not spellEnabled ) then
		combatString = strreplace(combatString,"$spell","");
	else
		if ( nameIsNotSpell ) then
			combatString = strreplace(combatString,"$spell", strreplace(TEXT_MODE_A_STRING_ACTION, "$action", "$spellName"));
			--combatString = strreplace(combatString,"$spell","$spellName");
		else
			combatString = strreplace(combatString,"$spell", _G[textModeString .. "SPELL"]);
--			combatString = strreplace(combatString,"$spell",GetSpellLink(spellId));
		end
	end

	-- Remove Extra Spell
	if ( not extraSpellEnabled ) then
		combatString = strreplace(combatString,"$extraSpell","");
	else
		if ( extraNameIsNotSpell ) then
			combatString = strreplace(combatString,"$extraSpell","$extraSpellName");
		else
			combatString = strreplace(combatString,"$extraSpell", _G[textModeString .. "SPELL_EXTRA"]);
		end
	end

	-- Remove Action
	if ( not actionEnabled ) then 
		combatString = strreplace(combatString,"$action","");
	else
		combatString = strreplace(combatString,"$action", _G[textModeString .. "ACTION"]);
	end

	-- Remove Value
	if ( not itemEnabled ) then 
		combatString = strreplace(combatString,"$item","");
	else
		combatString = strreplace(combatString,"$item", _G[textModeString .. "ITEM"]);
	end

	-- Remove Value
	if ( not valueEnabled ) then 
		combatString = strreplace(combatString,"$value","");
	else
		combatString = strreplace(combatString,"$value", _G[textModeString .. "VALUE"]);
	end

	-- Remove type
	if ( not valueTypeEnabled ) then 
		combatString = strreplace(combatString,"$amountType","");
	else
		-- School Type
		if ( valueType == 1 ) then 
			combatString = strreplace(combatString,"$amountType", _G[textModeString .. "VALUE_SCHOOL"]);
		-- Power Type
		elseif ( valueType == 2 ) then
			combatString = strreplace(combatString,"$amountType", _G[textModeString .. "VALUE_TYPE"]);
		end
	end

	-- Remove Result
	if ( not resultEnabled ) then 
		combatString = strreplace(combatString,"$result","");
	end

	-- Actor name construction.
	--
	local sourceNameStr, destNameStr;
	local sourceIcon, destIcon;
	local spellNameStr = spellName;
	local extraSpellNameStr = extraSpellName;
	local itemNameStr = itemName;
	local actionStr = event;
	local timestampStr = timestamp;

	-- Get the action string
	actionStr = _G["ACTION_"..actionStr];

	-- If this ever succeeds, the event string is missing. 
	--
	if ( not actionStr ) then 
		actionStr = event;
	end

	-- Initialize the strings now
	sourceNameStr, destNameStr = sourceName, destName

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
		if ( sourceName and spellName and _G["ACTION_"..event.."_POSSESSIVE"] == "1" ) then
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
		if ( sourceName and spellName and _G["ACTION_"..event.."_POSSESSIVE"] == "1" ) then
			sourceNameStr = strreplace ( TEXT_MODE_A_STRING_POSSESSIVE, "$nameString", sourceNameStr );
			sourceNameStr = strreplace ( sourceNameStr, "$possessive", TEXT_MODE_A_STRING_POSSESSIVE_STRING );
		end

		-- Apply the possessive form to the dest if the dest has a spell
		if ( ( extraSpellName or itemName ) and destName ) then
			destNameStr = strreplace ( TEXT_MODE_A_STRING_POSSESSIVE, "$nameString", destNameStr );
			destNameStr = strreplace ( destNameStr, "$possessive", TEXT_MODE_A_STRING_POSSESSIVE_STRING );
		end
	end

	-- Unit Tokens
	if ( settings.unitTokens ) then
		-- Apply the possessive form to the source
		if ( sourceName ) then
			sourceName = CombatLog_String_GetToken(sourceGUID, sourceName, sourceFlags);
		end
		if ( destName ) then
			destName = CombatLog_String_GetToken(destGUID, destName, destFlags);
		end
	end
	
	-- Unit Icons
	if ( settings.unitIcons ) then
		if ( sourceName ) then
			sourceIcon = CombatLog_String_GetIcon(sourceFlags, "source");
		end
		if ( destName ) then
			destIcon = CombatLog_String_GetIcon(destFlags, "dest");
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
			elseif ( ( settings.lineColorPriority == 2 and destName ) or not sourceName ) then
				lineColor = CombatLog_Color_ColorArrayByUnitType( destFlags, filterSettings );
			else
				lineColor = CombatLog_Color_ColorArrayByUnitType( sourceFlags, filterSettings );
			end
		end
	end

	-- Only replace if there's an amount
	if ( amount ) then
		local amountColor;

		-- Color amount numbers
		if ( settings.amountColoring ) then
			-- To make white swings white
			if ( settings.noMeleeSwingColoring and school == SCHOOL_MASK_PHYSICAL and not spellId )  then
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
		if ( amountColor ) then
			amountColor = CombatLog_Color_FloatToText(amountColor);
			amount = "|c"..amountColor..amount.."|r";
		end

		schoolString = CombatLog_String_SchoolString(school);
		local schoolNameColor = nil;
		-- Color school names
		if ( settings.schoolNameColoring ) then
			if ( settings.noMeleeSwingColoring and school == SCHOOL_MASK_PHYSICAL and not spellId )  then
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
			schoolString = "|c"..schoolNameColor..schoolString.."|r";
		end

	end

	-- Power Type
	if ( powerType ) then
		powerTypeString =  CombatLog_String_PowerType(powerType);
	end

	-- Compile the arguments into the combat string
	if ( resultStr ) then
		-- Replace the action
		combatString = strreplace(combatString, "$result", resultStr);
	end

	-- Color source names
	if ( settings.unitColoring ) then 
		if ( sourceName and settings.sourceColoring ) then
			sourceNameStr = "|c"..sourceColor..sourceNameStr.."|r";
		end
		if ( destName and settings.destColoring ) then
			destNameStr = "|c"..destColor..destNameStr.."|r";
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
			actionStr = "|c"..actionColor..actionStr.."|r";
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
			spellNameStr = "|c"..abilityColor..spellName.."|r";
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
					abilityColor = CombatLog_Color_ColorArrayBySchool( SCHOOL_MASK_HOLY, filterSettings );
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
			extraSpellNameStr = "|c"..abilityColor..extraSpellName.."|r";
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
				sourceNameStr = strreplace(_G[textModeString .. "BRACE_UNIT"], "$unitName", sourceNameStr);
				sourceNameStr = strreplace(sourceNameStr, "$braceColor", braceColor);
			end
	
			if ( destName and settings.destBraces ) then
				destNameStr = strreplace(_G[textModeString .. "BRACE_UNIT"], "$unitName", destNameStr);
				destNameStr = strreplace(destNameStr, "$braceColor", braceColor);
			end
		end

		-- Spell name braces
		if ( spellName and settings.spellBraces ) then 
			spellNameStr = strreplace(_G[textModeString .. "BRACE_SPELL"], "$spellName", spellNameStr);
			spellNameStr = strreplace(spellNameStr, "$braceColor", braceColor);
		end
		if ( extraSpellName and settings.spellBraces ) then 
			extraSpellNameStr = strreplace(_G[textModeString .. "BRACE_SPELL"], "$spellName", extraSpellNameStr);
			extraSpellNameStr = strreplace(extraSpellNameStr, "$braceColor", braceColor); 
		end

		-- Build item braces
		if ( itemName and settings.itemBraces ) then
			itemNameStr = strreplace(_G[textModeString .. "BRACE_ITEM"], "$itemName", itemNameStr);
			itemNameStr = strreplace(itemNameStr, "$braceColor", braceColor);
		end
	end

	-- Dest Icons
	if ( sourceIcon ) then
		combatString = strreplace(combatString, "$sourceIcon", sourceIcon);
	end
	if ( destIcon ) then
		combatString = strreplace(combatString, "$destIcon", destIcon);
	end


	-- Unit Names
	if ( sourceName ) then
		combatString = strreplace(combatString, "$sourceNameString", sourceNameStr);
		combatString = strreplace(combatString, "$sourceName", sourceName);
		combatString = strreplace(combatString, "$sourceGUID", sourceGUID);
	end
	if ( destName ) then 
		combatString = strreplace(combatString, "$destNameString", destNameStr);
		combatString = strreplace(combatString, "$destName", destName);
		combatString = strreplace(combatString, "$destGUID", destGUID);
	end

	if ( amount ) then
		-- Replace the amount
		combatString = strreplace(combatString, "$amount", amount );
	end
	if ( extraAmount ) then
		-- Replace the extra amount
		combatString = strreplace(combatString, "$extraAmount", extraAmount );
	end

	-- Spell Stuff
	if ( spellName ) then
		combatString = strreplace(combatString, "$spellName", spellNameStr);
	end
	if ( spellId ) then
		combatString = strreplace(combatString, "$spellId", spellId);
	end
	if ( extraSpellName ) then
		combatString = strreplace(combatString, "$extraSpellName", extraSpellNameStr);
	end
	if ( extraSpellId ) then
		combatString = strreplace(combatString, "$extraSpellId", extraSpellId);
	end

	if ( itemName ) then
		-- Replace the spell information
		combatString = strreplace(combatString, "$itemName", itemNameStr);
	end
	if ( itemId ) then
		combatString = strreplace(combatString, "$itemId", itemId);
	end

	if ( schoolString ) then
		-- Replace the school name
		combatString = strreplace(combatString, "$school", schoolString );
	end

	if ( powerTypeString ) then
		-- Replace the power type name
		combatString = strreplace(combatString, "$powerType", powerTypeString );
	end

	if ( actionStr ) then
		-- Replace the action
		combatString = strreplace(combatString, "$action", actionStr);
	end

	if ( timestamp ) then
		-- Replace the timestamp
		combatString = strreplace(combatString, "$time", date(settings.timestampFormat, timestamp));
	end

	-- Replace the event
	combatString = strreplace(combatString, "$eventType", originalEvent);

	-- Clean up formatting
	combatString = gsub(combatString, " [ ]+", " " ); -- extra white spaces
	combatString = gsub(combatString, " ([.,])", "%1" ); -- spaces before periods or comma
	combatString = gsub(combatString, "^([ .,]+)", "" ); -- spaces, period or comma at the beginning of a line
	--combatString = gsub(combatString, "([%(])[ ]+", "%1" ); whitespace after Parenthesis 

	-- Debug line for hyperlinks
	-- combatString = gsub( combatString, "\124", "\124\124");

	-- NOTE: be sure to pass back nil for the color id or the color id may override the r, g, b values for this message line
	return combatString, lineColor.r, lineColor.g, lineColor.b;
end
_G.CombatLog_OnEvent = CombatLog_OnEvent

-- Process the event and add it to the combat log
function CombatLog_AddEvent(...)
	if ( DEBUG == true ) then
		local info = ChatTypeInfo["COMBAT_MISC_INFO"];
		local timestamp, event, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags = ...
		local message = format("%s, %s, %s, 0x%x, %s, %s, 0x%x",
				       --date("%H:%M:%S", timestamp), 
		                       event,
		                       srcGUID, srcName or "nil", srcFlags,
		                       dstGUID, dstName or "nil", dstFlags);
		
		for i = 9, select("#", ...) do
			message = message..", "..(select(i, ...) or "nil");
		end
		ChatFrame1:AddMessage(message, info.r, info.g, info.b);
	end
	-- Add the messages
	COMBATLOG:AddMessage(CombatLog_OnEvent(Blizzard_CombatLog_CurrentSettings, ... ));
end

--
-- Overrides for the combat log
--
-- Save the original event handler
local original_OnEvent = COMBATLOG:GetScript("OnEvent");
COMBATLOG:SetScript("OnEvent",
	
function(self, event, ...)
		if ( event == "COMBAT_LOG_EVENT" ) then
			CombatLog_AddEvent(...);
			return;
		elseif ( event == "COMBAT_LOG_EVENT_UNFILTERED") then
			--[[
			local timestamp, event, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags = select(1, ...);
			local message = string.format("%s, %s, %s, 0x%x, %s, %s, 0x%x",
					       --date("%H:%M:%S", timestamp), 
					       event,
					       srcGUID, srcName or "nil", srcFlags,
					       dstGUID, dstName or "nil", dstFlags);
			
			for i = 9, select("#", ...) do
				message = message..", "..(select(i, ...) or "nil");
			end
			ChatFrame1:AddMessage(message);
			--COMBATLOG:AddMessage(message);
			]]
			return;
		else
			original_OnEvent(self, event, ...);
		end
	end
);
COMBATLOG:RegisterEvent("COMBAT_LOG_EVENT");
--COMBATLOG:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");

--[[
_G[COMBATLOG:GetName().."Tab"]:SetScript("OnDragStart",
	function(self, event, ...)
		local chatFrame = _G["ChatFrame"..this:GetID()];
		if ( chatFrame == DEFAULT_CHAT_FRAME ) then
			if (chatFrame.isLocked) then
				return;
			end
			chatFrame:StartMoving();
			MOVING_CHATFRAME = chatFrame;
			return;
		elseif ( chatFrame.isDocked ) then
			FCF_UnDockFrame(chatFrame);
			FCF_SetLocked(chatFrame, nil);
			local chatTab = _G[chatFrame:GetName().."Tab"];
			local x,y = chatTab:GetCenter();
			if ( x and y ) then
				x = x - (chatTab:GetWidth()/2);
				y = y - (chatTab:GetHeight()/2);
				chatTab:ClearAllPoints();
				chatFrame:ClearAllPoints();
				chatFrame:SetPoint("TOPLEFT", "UIParent", "BOTTOMLEFT", x, y - CombatLogQuickButtonFrame:GetHeight());
			end
			FCF_SetTabPosition(chatFrame, 0);
			chatFrame:StartMoving();
			MOVING_CHATFRAME = chatFrame;
		end
		SELECTED_CHAT_FRAME = chatFrame;
	end
);
]]--

--
-- XML Function Overrides Part 2
--

-- 
-- Attach the Combat Log Button Frame to the Combat Log
--

-- On Event
function Blizzard_CombatLog_QuickButtonFrame_OnEvent(event)
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
				this:Hide();
			end
		end
	end
end


-- BUG: Since we're futzing with the frame height, the combat log tab fades out on hover while other tabs remain faded in. This bug is in the stock version, as well.

local function Blizzard_CombatLog_AdjustCombatLogHeight()
	if ( SIMPLE_CHAT == "1" ) then
		return;
	end
	
	-- This prevents improper positioning of the frame due to the scale not yet being set.
	-- This whole method of resizing the frame and extending the background to preserve visual continuity really screws with repositioning after 
	-- a reload. I'm not sure it's going to work well in the long run.
	local uiScale = tonumber(GetCVar("uiScale"));
	--if UIParent:GetScale() ~= uiScale then return end
	
	local heightChange = CombatLogQuickButtonFrame:GetHeight()*uiScale;
	local yOffset = 3;
	local xOffset = 2;
	
	local oldPoint,relativeTo,relativePoint,xOfs,yOfs;
	for i=1, COMBATLOG:GetNumPoints() do
		point,relativeTo,relativePoint,xOfs,yOfs = COMBATLOG:GetPoint(i)
		if ( point == "TOPLEFT" ) then 
			break;
		end
	end	
	
	if ( COMBATLOG.isDocked ) then
		yOfs = 0;
		COMBATLOG:SetPoint("TOPLEFT", relativeTo, relativePoint, xOfs/uiScale, (yOfs - heightChange)/uiScale );
	end
	_G[COMBATLOG:GetName().."Background"]:SetPoint("TOPLEFT", COMBATLOG, "TOPLEFT", (xOffset * -1)/uiScale, (yOffset + heightChange)/uiScale);
	_G[COMBATLOG:GetName().."Background"]:SetPoint("TOPRIGHT", COMBATLOG, "TOPRIGHT", xOffset/uiScale, (yOffset + heightChange)/uiScale);
end

-- On Load
local hooksSet = false
function Blizzard_CombatLog_QuickButtonFrame_OnLoad()
	this:RegisterEvent("ADDON_LOADED");
	
	-- We're using the _Custom suffix to get around the show/hide bug in FloatingChatFrame.lua.
	-- Once the fading is removed from FloatingChatFrame.lua these can do back to the non-custom values, and the dummy frame creation should be removed.
	CombatLogQuickButtonFrame = _G.CombatLogQuickButtonFrame_Custom
	CombatLogQuickButtonFrameProgressBar = _G.CombatLogQuickButtonFrame_CustomProgressBar
	CombatLogQuickButtonFrameTexture = _G.CombatLogQuickButtonFrame_CustomTexture

	-- Parent it to the tab so that we just inherit the tab's alpha. No need to do special fading for it.
	CombatLogQuickButtonFrame:SetParent(COMBATLOG:GetName() .. "Tab");
	CombatLogQuickButtonFrame:ClearAllPoints();
	CombatLogQuickButtonFrame:SetPoint("BOTTOMLEFT", COMBATLOG, "TOPLEFT");
	CombatLogQuickButtonFrame:SetPoint("BOTTOMRIGHT", COMBATLOG, "TOPRIGHT");
	CombatLogQuickButtonFrameProgressBar:Hide();

	-- Hook the frame's hide/show events so we can hide/show the quick buttons as appropriate.
	local show, hide = COMBATLOG:GetScript("OnShow"), COMBATLOG:GetScript("OnHide")
	COMBATLOG:SetScript("OnShow", function()
		CombatLogQuickButtonFrame_Custom:Show()
		--Blizzard_CombatLog_AdjustCombatLogHeight()
		return show and show()
	end)

	COMBATLOG:SetScript("OnHide", function()
		CombatLogQuickButtonFrame_Custom:Hide()
		-- Blizzard_CombatLog_AdjustCombatLogHeight()
		return hide and hide()
	end)	
end

local oldFCF_DockUpdate = FCF_DockUpdate;
FCF_DockUpdate = function()
	oldFCF_DockUpdate();
	Blizzard_CombatLog_AdjustCombatLogHeight();
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
function SetItemRef(link, text, button)

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
			EasyMenu(Blizzard_CombatLog_CreateUnitMenu(CombatLog_BitToBraceCode(tonumber(bit)), nil, tonumber(bit)), CombatLogDropDown, "cursor", nil, nil, "MENU");
		elseif ( IsModifiedClick("CHATLINK") ) then
			ChatEdit_InsertLink (CombatLog_BitToBraceCode(tonumber(bit)));
		end
		return;
	elseif ( strsub(link, 1,5) == "spell" ) then 
		local _, spellId, event = strsplit(":", link);	
		spellId = tonumber (spellId);

		if ( IsModifiedClick("CHATLINK") ) then
			if ( spellId > 0 ) then
				if ( ChatEdit_InsertLink(GetSpellLink(spellId)) ) then
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
	elseif ( strsub(link, 1, 4) == "item") then
		if ( IsModifiedClick("CHATLINK") ) then
			local name, link = GetItemInfo(text);
			ChatEdit_InsertLink (link);
			return;
		end
	end
	oldSetItemRef(link, text, button);
end

function Blizzard_CombatLog_Update_QuickButtons()
	local baseName = "CombatLogQuickButtonFrame";
	local buttonName, button, textWidth;
	local buttonIndex = 1;
	-- subtract the width of the dropdown button
	local maxWidth = COMBATLOG:GetWidth()-31;
	local totalWidth = 0;
	local padding = 10;
	local showMoreQuickButtons = true;
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
		button = getglobal(baseName.."Button"..buttonIndex);
		if ( button ) then
			button:Hide();
		end
		buttonIndex = buttonIndex+1;
	until not button;
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
end

function ShowQuickButton(filter)
	if ( filter.hasQuickButton ) then
		if ( GetNumRaidMembers() > 0 ) then
			return filter.quickButtonDisplay.raid;
		elseif ( GetNumPartyMembers() > 0 ) then
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
	Blizzard_CombatLog_Filters = _G.Blizzard_CombatLog_Filters;
	Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_Filters.filters[Blizzard_CombatLog_Filters.currentFilter];
	_G.Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_CurrentSettings;
end

--
-- Backwards Compatibility
--
-- 	Generally, we do not attempt to fix combat log issues with backwards compatibility changes,
-- 	but this would be a pretty noxious fix if we didn't.
--
-- 	This code should be removed after 2.4.2.
--
function Blizzard_CombatLog_Filter_Compatibility ( currentVersion, update ) 
	if ( currentVersion == 4 ) then
		-- Fixes the coloring for most users
		local badKey = bit.bor(
						COMBATLOG_OBJECT_AFFILIATION_PARTY,
						COMBATLOG_OBJECT_AFFILIATION_RAID,
						COMBATLOG_OBJECT_AFFILIATION_OUTSIDER,
						COMBATLOG_OBJECT_REACTION_NEUTRAL,
						COMBATLOG_OBJECT_REACTION_HOSTILE,
						COMBATLOG_OBJECT_CONTROL_PLAYER,
						COMBATLOG_OBJECT_TYPE_PLAYER,
						COMBATLOG_OBJECT_TYPE_NPC,
						COMBATLOG_OBJECT_TYPE_PET,
						COMBATLOG_OBJECT_TYPE_GUARDIAN,
						COMBATLOG_OBJECT_TYPE_OBJECT
						);
		local badKey2 = bit.bor(
						COMBATLOG_OBJECT_AFFILIATION_PARTY,
						COMBATLOG_OBJECT_AFFILIATION_RAID,
						COMBATLOG_OBJECT_AFFILIATION_OUTSIDER,
						COMBATLOG_OBJECT_REACTION_NEUTRAL,
						COMBATLOG_OBJECT_REACTION_HOSTILE,
						COMBATLOG_OBJECT_CONTROL_NPC,
						COMBATLOG_OBJECT_TYPE_PLAYER,
						COMBATLOG_OBJECT_TYPE_NPC,
						COMBATLOG_OBJECT_TYPE_PET,
						COMBATLOG_OBJECT_TYPE_GUARDIAN,
						COMBATLOG_OBJECT_TYPE_OBJECT
						);
		for key, filter in pairs (Blizzard_CombatLog_Filters.filters) do
			if ( filter.colors.unitColoring[badKey] ) then
				filter.colors.unitColoring[COMBATLOG_FILTER_HOSTILE_PLAYERS] = filter.colors.unitColoring[badKey];
				filter.colors.unitColoring[badKey] = nil;
			else
				filter.colors.unitColoring[COMBATLOG_FILTER_HOSTILE_PLAYERS] = COMBATLOG_DEFAULT_COLORS.unitColoring[COMBATLOG_FILTER_HOSTILE_PLAYERS];
			end
			if ( filter.filters[1].sourceFlags ) then
				if ( filter.filters[1].sourceFlags[badKey] ) then
					filter.filters[1].sourceFlags[COMBATLOG_FILTER_HOSTILE_PLAYERS] = filter.filters[1].sourceFlags[badKey];
					filter.filters[1].sourceFlags[badKey] = nil;
				end
				if ( filter.filters[1].sourceFlags[badKey2] ) then
					filter.filters[1].sourceFlags[COMBATLOG_FILTER_HOSTILE_UNITS] = filter.filters[1].sourceFlags[badKey2];
					filter.filters[1].sourceFlags[badKey2] = nil;
				end
			end
			if ( filter.filters[2].destFlags ) then
				if ( filter.filters[2].destFlags[badKey] ) then
					filter.filters[2].destFlags  [COMBATLOG_FILTER_HOSTILE_PLAYERS] = filter.filters[2].destFlags[badKey];
					filter.filters[2].destFlags  [badKey] = nil;
				end
				if ( filter.filters[2].destFlags[badKey2] ) then
					filter.filters[2].destFlags  [COMBATLOG_FILTER_HOSTILE_UNITS] = filter.filters[2].destFlags[badKey2];
					filter.filters[2].destFlags  [badKey2] = nil;
				end
			end
			if ( filter.colors.unitColoring[badKey2] ) then
				filter.colors.unitColoring[COMBATLOG_FILTER_HOSTILE_UNITS] = filter.colors.unitColoring[badKey2];
				filter.colors.unitColoring[badKey2] = nil;
			else
				filter.colors.unitColoring[COMBATLOG_FILTER_HOSTILE_UNITS] = COMBATLOG_DEFAULT_COLORS.unitColoring[COMBATLOG_FILTER_HOSTILE_UNITS];
			end
		end
	end
end
