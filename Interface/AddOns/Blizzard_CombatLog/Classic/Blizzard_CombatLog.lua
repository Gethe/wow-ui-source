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
	["SPELL_DURABILITY_DAMAGE"] = true,
	["SPELL_DURABILITY_DAMAGE_ALL"] = true,
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
	["UNIT_LOYALTY"] = true,
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
	["SPELL_CAST_SUCCESS"] = TEXT_MODE_A_STRING_2
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
local COMBATLOG_OBJECT_AFFILIATION_MINE = Enum.CombatLogObject.AffiliationMine;
local COMBATLOG_OBJECT_AFFILIATION_PARTY = Enum.CombatLogObject.AffiliationParty;
local COMBATLOG_OBJECT_AFFILIATION_RAID = Enum.CombatLogObject.AffiliationRaid;
local COMBATLOG_OBJECT_AFFILIATION_OUTSIDER = Enum.CombatLogObject.AffiliationOutsider;
local COMBATLOG_OBJECT_REACTION_FRIENDLY = Enum.CombatLogObject.ReactionFriendly;
local COMBATLOG_OBJECT_REACTION_NEUTRAL = Enum.CombatLogObject.ReactionNeutral;
local COMBATLOG_OBJECT_REACTION_HOSTILE = Enum.CombatLogObject.ReactionHostile;
local COMBATLOG_OBJECT_CONTROL_PLAYER = Enum.CombatLogObject.ControlPlayer;
local COMBATLOG_OBJECT_CONTROL_NPC = Enum.CombatLogObject.ControlNpc;
local COMBATLOG_OBJECT_TYPE_PLAYER = Enum.CombatLogObject.TypePlayer;
local COMBATLOG_OBJECT_TYPE_NPC = Enum.CombatLogObject.TypeNpc;
local COMBATLOG_OBJECT_TYPE_PET = Enum.CombatLogObject.TypePet;
local COMBATLOG_OBJECT_TYPE_GUARDIAN = Enum.CombatLogObject.TypeGuardian;
local COMBATLOG_OBJECT_TYPE_OBJECT = Enum.CombatLogObject.TypeObject;
local COMBATLOG_OBJECT_TARGET = Enum.CombatLogObject.Target;
local COMBATLOG_OBJECT_FOCUS = Enum.CombatLogObject.Focus;
local COMBATLOG_OBJECT_MAINTANK = Enum.CombatLogObject.Maintank;
local COMBATLOG_OBJECT_MAINASSIST = Enum.CombatLogObject.Mainassist;
local COMBATLOG_OBJECT_NONE = Enum.CombatLogObject.None;
local COMBATLOG_OBJECT_RAIDTARGET1 = Enum.CombatLogObjectTarget.Raidtarget1;
local COMBATLOG_OBJECT_RAIDTARGET2 = Enum.CombatLogObjectTarget.Raidtarget2;
local COMBATLOG_OBJECT_RAIDTARGET3 = Enum.CombatLogObjectTarget.Raidtarget3;
local COMBATLOG_OBJECT_RAIDTARGET4 = Enum.CombatLogObjectTarget.Raidtarget4;
local COMBATLOG_OBJECT_RAIDTARGET5 = Enum.CombatLogObjectTarget.Raidtarget5;
local COMBATLOG_OBJECT_RAIDTARGET6 = Enum.CombatLogObjectTarget.Raidtarget6;
local COMBATLOG_OBJECT_RAIDTARGET7 = Enum.CombatLogObjectTarget.Raidtarget7;
local COMBATLOG_OBJECT_RAIDTARGET8 = Enum.CombatLogObjectTarget.Raidtarget8;
local COMBATLOG_OBJECT_AFFILIATION_MASK = Constants.CombatLogObjectMasks.COMBATLOG_OBJECT_AFFILIATION_MASK;
local COMBATLOG_OBJECT_CONTROL_MASK = Constants.CombatLogObjectMasks.COMBATLOG_OBJECT_CONTROL_MASK;
local COMBATLOG_OBJECT_REACTION_MASK = Constants.CombatLogObjectMasks.COMBATLOG_OBJECT_REACTION_MASK;
local COMBATLOG_OBJECT_SPECIAL_MASK = Constants.CombatLogObjectMasks.COMBATLOG_OBJECT_SPECIAL_MASK;
local COMBATLOG_OBJECT_TYPE_MASK = Constants.CombatLogObjectMasks.COMBATLOG_OBJECT_TYPE_MASK;
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
local SCHOOL_MASK_NONE = SCHOOL_MASK_NONE;
local SCHOOL_MASK_PHYSICAL = SCHOOL_MASK_PHYSICAL;
local SCHOOL_MASK_HOLY = SCHOOL_MASK_HOLY;
local SCHOOL_MASK_FIRE = SCHOOL_MASK_FIRE;
local SCHOOL_MASK_NATURE = SCHOOL_MASK_NATURE;
local SCHOOL_MASK_FROST = SCHOOL_MASK_FROST;
local SCHOOL_MASK_SHADOW = SCHOOL_MASK_SHADOW;
local SCHOOL_MASK_ARCANE = SCHOOL_MASK_ARCANE;
local COMBATLOG_LIMIT_PER_FRAME = COMBATLOG_LIMIT_PER_FRAME;
local COMBATLOG_DEFAULT_COLORS = COMBATLOG_DEFAULT_COLORS;
local COMBATLOG_DEFAULT_SETTINGS = COMBATLOG_DEFAULT_SETTINGS;
local COMBATLOG_EVENT_LIST = COMBATLOG_EVENT_LIST;

local CombatLog_OnEvent		-- for later


-- Create a dummy CombatLogQuickButtonFrame for line 803 of FloatingChatFrame.lua. It causes inappropriate show/hide behavior. Instead, we'll use our own frame display handling.
-- If there are more than 2 combat log frames, then the CombatLogQuickButtonFrame gets tied to the last frame tab's visibility status. Yuck! Let's just instead tie it to the combat log's tab.

local CombatLogQuickButtonFrame, CombatLogQuickButtonFrameProgressBar
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
					      ["SPELL_ENERGIZE"] = true,
					      ["SPELL_DRAIN"] = false,
					      ["SPELL_LEECH"] = false,
					      ["SPELL_INSTAKILL"] = false,
					      ["SPELL_INTERRUPT"] = false,
					      ["SPELL_EXTRA_ATTACKS"] = false,
					      ["SPELL_DURABILITY_DAMAGE"] = false,
					      ["SPELL_DURABILITY_DAMAGE_ALL"] = false,
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
					      ["SPELL_PERIODIC_ENERGIZE"] = true,
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
						  ["UNIT_LOYALTY"] = false
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
					      ["SPELL_DURABILITY_DAMAGE"] = true,
					      ["SPELL_DURABILITY_DAMAGE_ALL"] = true,
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
					      ["UNIT_DISSIPATES"] = true,
						  ["UNIT_LOYALTY"] = false
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
	C_CombatLog.ClearEventFilters()

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
			C_CombatLog.AddEventFilter("", COMBATLOG_FILTER_MINE, nil);
		else
			C_CombatLog.AddEventFilter(eList, sourceFlags, destFlags);
		end
	end
end

--
-- Combat Log Repopulation Code
--

--
-- Repopulate the combat log with message history
--
function Blizzard_CombatLog_Refilter()
	local count = C_CombatLog.GetEntryCount();
	local limit = C_CombatLog.GetMessageLimit();

	COMBATLOG:SetMaxLines(limit);

	-- count should be between 1 and limit
	count = max(1, min(count, limit));

	C_CombatLog.SeekToNewestEntry();

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
	local valid = C_CombatLog.GetCurrentEntryInfo();

	-- Clear the combat log
	local total = 0;
	while (valid and total < COMBATLOG_LIMIT_PER_FRAME) do
		-- Log to the window
		local text, r, g, b, a = CombatLog_OnEvent(Blizzard_CombatLog_CurrentSettings, C_CombatLog.GetCurrentEntryInfo());
		-- NOTE: be sure to pass in nil for the color id or the color id may override the r, g, b values for this message
		if ( text ) then
			COMBATLOG:BackFillMessage(text, r, g, b);
		end

		-- count can be
		--  positive to advance from oldest to newest
		--  negative to advance from newest to oldest
		valid = C_CombatLog.SeekToPreviousEntry()
		total = total + 1;
	end

	-- Show filtering progress bar
	CombatLogQuickButtonFrameProgressBar:SetValue(CombatLogQuickButtonFrameProgressBar:GetValue() + total);

	if ( not valid or (CombatLogQuickButtonFrameProgressBar:GetValue() >= C_CombatLog.GetMessageLimit()) ) then
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
			divider = true;
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
					[5] = {
						text = "Drains";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_DRAIN", "SPELL_LEECH"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_DRAIN", "SPELL_LEECH" );
						end;
					};
					[6] = {
						text = "Interrupts";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_INTERRUPT"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_INTERRUPT" );
						end;
					};
					[7] = {
						text = "Extra Attacks";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_EXTRA_ATTACKS"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "SPELL_EXTRA_ATTACKS" );
						end;
					};
					[8] = {
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
					[9] = {
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
					[5] = {
						text = "Loyalty";
						checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "UNIT_LOYALTY"); end;
						keepShownOnClick = true;
						func = function ( self, arg1, arg2, checked )
							Blizzard_CombatLog_MenuHelper ( checked, "UNIT_LOYALTY" );
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
				divider = true;
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
		StaticPopup_Show("COPY_COMBAT_FILTER", nil, nil, Blizzard_CombatLog_CurrentSettings);
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
			C_CombatLog.ClearEventFilters()
			--Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_Filters.contextMenu[event];
			C_CombatLog.AddEventFilter(nil, nil, nil)
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
		--C_CombatLog.AddEventFilter(nil, nil, COMBATLOG_FILTER_MINE)
		--C_CombatLog.AddEventFilter(nil, COMBATLOG_FILTER_MINE, nil)
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
			C_CombatLog.AddEventFilter(nil, nil, nil)
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
		if ( ChatFrameUtil.GetActiveWindow() ) then
			ChatFrameUtil.InsertLink(GetSpellLink(spellId));
		else
			ChatFrameUtil.OpenChat(GetSpellLink(spellId));
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
	local valueEnabled = true;
	local valueTypeEnabled = true;
	local resultEnabled = true;
	local powerTypeEnabled = true;
	local extraSpellEnabled = false;
	local valueIsItem = false;
	local withPoints = false;
	local forceDestPossessive = false;

	-- Get the initial string
	local schoolString;
	local resultStr = nil;

	local formatString = TEXT_MODE_A_STRING_1;
	if ( EVENT_TEMPLATE_FORMATS[event] ) then
		formatString = EVENT_TEMPLATE_FORMATS[event];
	end

	-- Replacements to do:
	-- * Src, Dest, Action, Spell, Amount, Result

	-- Spell standard order
	local spellId, spellName, spellSchool = nil, nil, nil;
	local extraSpellId, extraSpellName, extraSpellSchool = nil, nil, nil;

	-- For Melee/Ranged swings and enchants
	local nameIsNotSpell;
	local extraNameIsNotSpell = false;

	-- Damage standard order
	local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, overhealing = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil;
	-- Miss argument order
	local missType, isOffHand, amountMissed;
	-- Aura arguments
	local auraType; -- BUFF or DEBUFF
	-- Energize Arguments
	local overEnergize = nil;

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
	if ( not sourceName or C_CombatLog.DoesObjectMatchFilter(sourceFlags, COMBATLOG_OBJECT_NONE) ) then
		sourceEnabled = false;
	end
	if ( not destName or C_CombatLog.DoesObjectMatchFilter(destFlags, COMBATLOG_OBJECT_NONE) ) then
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
		resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

		if ( not resultStr ) then
			resultEnabled = false;
		end

		if ( overkill > 0 ) then
			amount = amount - overkill;
		end

	elseif ( event == "SWING_MISSED" ) then
		spellName = ACTION_SWING;

		-- Miss type
		missType, isOffHand, amountMissed = ...;

		-- Result String
		if( missType == "RESIST" or missType == "BLOCK" or missType == "ABSORB" ) then
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
			resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

			if ( not resultStr ) then
				resultEnabled = false
			end

			if ( overkill > 0 ) then
				amount = amount - overkill;
			end
		elseif ( event == "SPELL_MISSED" ) then
			-- Miss type
			missType,  isOffHand, amountMissed = select(4, ...);

			resultEnabled = true;
			-- Result String
			if( missType == "RESIST" or missType == "BLOCK" or missType == "ABSORB" ) then
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
			resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

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
			resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

			if ( not resultStr ) then
				resultEnabled = false
			end

			-- Disable appropriate sections
			valueEnabled = true;
			valueTypeEnabled = true;
		elseif ( strsub(event, 1, 14) == "SPELL_PERIODIC" ) then

			if ( event == "SPELL_PERIODIC_MISSED" ) then
				-- Miss type
				missType, isOffHand, amountMissed = select(4, ...);

				-- Result String
				if ( missType == "ABSORB" ) then
					resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, amountMissed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );
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
				resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

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
				resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

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
			elseif ( event == "SPELL_PERIODIC_LEECH" ) then
				-- Special attacks
				amount, powerType, extraAmount, alternatePowerType = select(4, ...);

				-- Set value type to be a power type
				valueType = 2;

				-- Result String
				resultStr = format(_G["ACTION_SPELL_PERIODIC_LEECH_RESULT"], nil, nil, nil, nil, nil, nil, nil, CombatLogUtil.GetPowerTypeString(powerType, amount, alternatePowerType), nil, extraAmount) --"($extraAmount $powerType Gained)"

				-- Disable appropriate sections
				if ( not resultStr ) then
					resultEnabled = false
				end
				valueEnabled = true;
			elseif ( event == "SPELL_PERIODIC_ENERGIZE" ) then
				-- Set value type to be a power type
				valueType = 2;

				-- Did the heal crit?
				amount, overEnergize, powerType, alternatePowerType = select(4, ...);

				-- Parse the result string
				--resultStr = _G[textModeString .. "RESULT"];
				--resultStr = gsub(resultStr,"$resultString", _G["ACTION_"..event.."_RESULT"]);
				resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

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
		elseif ( event == "SPELL_LEECH" ) then
			-- Special attacks
			amount, powerType, extraAmount, alternatePowerType = select(4, ...);

			-- Set value type to be a power type
			valueType = 2;

			-- Result String
			resultStr = format(_G["ACTION_SPELL_LEECH_RESULT"], nil, nil, nil, nil, nil, nil, nil, CombatLogUtil.GetPowerTypeString(powerType, amount, alternatePowerType), nil, extraAmount)

			-- Disable appropriate sections
			if ( not resultStr ) then
				resultEnabled = false;
			end
			valueEnabled = true;
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
		elseif ( event == "SPELL_EXTRA_ATTACKS" ) then
			-- Special attacks
			amount = select(4, ...);

			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = true;
			valueTypeEnabled = false;
		elseif ( event == "SPELL_SUMMON" ) then
			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
		elseif ( event == "SPELL_RESURRECT" ) then
			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
		elseif ( event == "SPELL_CREATE" ) then
			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
		elseif ( event == "SPELL_INSTAKILL" ) then
			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;

			unconsciousOnDeath = select(5, ...);
		elseif ( event == "SPELL_DURABILITY_DAMAGE" ) then
			itemId, itemName = select(4, ...);

			-- Disable appropriate sections
			valueIsItem = true;
			resultEnabled = false;
			valueEnabled = true;
		elseif ( event == "SPELL_DURABILITY_DAMAGE_ALL" ) then
			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
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
			resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize);

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
			missType, isOffHand, amountMissed = select(4,...);

			-- Result String
			if( missType == "RESIST" or missType == "BLOCK" or missType == "ABSORB" ) then
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
		resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

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

		unconsciousOnDeath = select(5, ...);
	elseif ( event == "ENCHANT_APPLIED" ) then
		-- Get the enchant name, item id and item name
		spellName, itemId, itemName = ...;
		nameIsNotSpell = true;

		-- Disable appropriate sections
		valueIsItem = true;
		resultEnabled = false;
		forceDestPossessive = true;
	elseif ( event == "ENCHANT_REMOVED" ) then
		-- Get the enchant name, item id and item name
		spellName, itemId, itemName = ...;
		nameIsNotSpell = true;

		-- Disable appropriate sections
		valueIsItem = true;
		resultEnabled = false;
		sourceEnabled = false;
		forceDestPossessive = true;
	elseif ( event == "UNIT_DIED" or event == "UNIT_DESTROYED" or event == "UNIT_DISSIPATES" ) then
		local recapID;
		recapID, unconsciousOnDeath = ...;
		-- handle death recaps
		if ( destGUID == UnitGUID("player") ) then
			lineColor = COMBATLOG_DEFAULT_COLORS.unitColoring[COMBATLOG_FILTER_MINE];
			return C_DeathRecap.GetRecapLink(recapID), lineColor.r, lineColor.g, lineColor.b;
		end

		-- Swap Source with Dest
		sourceName = destName;
		sourceGUID = destGUID;
		sourceFlags = destFlags;

		-- Disable appropriate sections
		resultEnabled = false;
		sourceEnabled = true;
		destEnabled = false;
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
		resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

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
		resultStr = CombatLogUtil.GenerateDamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellId, overkill, overEnergize );

		if ( not resultStr ) then
			resultEnabled = false
		end

		if ( overkill > 0 ) then
			amount = amount - overkill;
		end
	elseif ( event == "UNIT_LOYALTY" ) then
		local gained = ...
		if ( gained == 1 ) then
			resultStr = _G["PET_LOYALTY_GAIN"];
		else
			resultStr = _G["PET_LOYALTY_LOSS"];
		end
		formatString = "%6$s";
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
		if ( sourceName and C_CombatLog.DoesObjectMatchFilter(sourceFlags, COMBATLOG_FILTER_MINE) ) then
				sourceNameStr = UNIT_YOU_SOURCE;
		end
		if ( destName and C_CombatLog.DoesObjectMatchFilter(destFlags, COMBATLOG_FILTER_MINE) ) then
				destNameStr = UNIT_YOU_DEST;
		end
		-- Apply the possessive form to the source
		if ( sourceName and spellName and _G[actionEvent.."_POSSESSIVE"] == "1" ) then
			if ( sourceName and C_CombatLog.DoesObjectMatchFilter(sourceFlags, COMBATLOG_FILTER_MINE) ) then
				sourceNameStr = UNIT_YOU_SOURCE_POSSESSIVE;
			end
		end
		-- Apply the possessive form to the source
		if ( destName and ( extraSpellName or itemName ) ) then
			if ( destName and C_CombatLog.DoesObjectMatchFilter(destFlags, COMBATLOG_FILTER_MINE) ) then
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
		if ( ( extraSpellName or forceDestPossessive ) and destName ) then
			destNameStr = format(TEXT_MODE_A_STRING_POSSESSIVE, destNameStr);
		end
	end

	-- Unit Icons
	if ( settings.unitIcons ) then
		if ( sourceName ) then
			sourceIcon = CombatLogUtil.GetUnitIcon(sourceRaidFlags, "source");
		end
		if ( destName ) then
			destIcon = CombatLogUtil.GetUnitIcon(destRaidFlags, "dest");
		end
	end

	-- Get the source color
	if ( sourceName ) then
		sourceColor	= CombatLogUtil.GetColorByUnitType( sourceFlags, filterSettings );
	end

	-- Get the dest color
	if ( destName ) then
		destColor	= CombatLogUtil.GetColorByUnitType( destFlags, filterSettings );
	end

	-- Whole line coloring
	if ( settings.lineColoring ) then
		if ( settings.lineColorPriority == 3 or ( not sourceName and not destName) ) then
			lineColor = CombatLogUtil.GetColorByEventType( event, filterSettings );
		else
			if ( ( settings.lineColorPriority == 1 and sourceName ) or not destName ) then
				lineColor = CombatLogUtil.GetColorByUnitType( sourceFlags, filterSettings );
			elseif ( ( settings.lineColorPriority == 2 and destName ) ) then
				lineColor = CombatLogUtil.GetColorByUnitType( destFlags, filterSettings );
			else
				lineColor = CombatLogUtil.GetColorByUnitType( sourceFlags, filterSettings );
			end
		end
	end

	-- Power Type
	if ( powerType ) then
		powerTypeString =  CombatLogUtil.GetPowerTypeString(powerType, amount, alternatePowerType);
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
			if ( settings.noMeleeSwingColoring and school == SCHOOL_MASK_PHYSICAL and not spellId )  then
				-- Do nothing
			elseif ( settings.amountActorColoring ) then
				if ( sourceName ) then
					amountColor = CombatLogUtil.GetColorByUnitType( sourceFlags, filterSettings );
				elseif ( destName ) then
					amountColor = CombatLogUtil.GetColorByUnitType( destFlags, filterSettings );
				end
			elseif ( settings.amountSchoolColoring ) then
				amountColor = CombatLogUtil.GetColorBySchool(school, filterSettings);
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
			amountColor  = CombatLogUtil.HighlightColor (colorArray);
		end

		amount = BreakUpLargeNumbers(amount);
		if ( amountColor ) then
			amount = CombatLogUtil.WrapTextInColor(amount, amountColor);
		end

		schoolString = CombatLogUtil.GetSpellSchoolString(school);
		local schoolNameColor = nil;
		-- Color school names
		if ( settings.schoolNameColoring ) then
			if ( settings.noMeleeSwingColoring and school == SCHOOL_MASK_PHYSICAL and not spellId )  then
			elseif ( settings.schoolNameActorColoring ) then
					if ( sourceName ) then
						schoolNameColor = CombatLogUtil.GetColorByUnitType( sourceFlags, filterSettings );
					elseif ( destName ) then
						schoolNameColor = CombatLogUtil.GetColorByUnitType( destFlags, filterSettings );
					end
			else
				schoolNameColor = CombatLogUtil.GetColorBySchool( school, filterSettings );
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
			schoolNameColor  = CombatLogUtil.HighlightColor (colorArray);
		end
		if ( schoolNameColor ) then
			schoolString = CombatLogUtil.WrapTextInColor(schoolString, schoolNameColor);
		end

	end

	-- Color source names
	if ( settings.unitColoring ) then
		if ( sourceName and settings.sourceColoring ) then
			sourceNameStr = CombatLogUtil.WrapTextInColor(sourceNameStr, sourceColor);
		end
		if ( destName and settings.destColoring ) then
			destNameStr = CombatLogUtil.WrapTextInColor(destNameStr, destColor);
		end
	end

	-- If there's an action (always)
	if ( actionStr ) then
		local actionColor = nil;
		-- Color ability names
		if ( settings.actionColoring ) then

			if ( settings.actionActorColoring ) then
				if ( sourceName ) then
					actionColor = CombatLogUtil.GetColorByUnitType( sourceFlags, filterSettings );
				elseif ( destName ) then
					actionColor = CombatLogUtil.GetColorByUnitType( destFlags, filterSettings );
				end
			elseif ( settings.actionSchoolColoring and spellSchool ) then
				actionColor = CombatLogUtil.GetColorBySchool( spellSchool, filterSettings );
			else
				actionColor = CombatLogUtil.GetColorByEventType(event, filterSettings);
			end
		-- Special option to only color "Miss" if there's no damage
		elseif ( settings.missColoring ) then

			if ( event ~= "SWING_DAMAGE" and
				event ~= "RANGE_DAMAGE" and
				event ~= "SPELL_DAMAGE" and
				event ~= "SPELL_PERIODIC_DAMAGE" ) then

				if ( settings.actionActorColoring ) then
					actionColor = CombatLogUtil.GetColorByUnitType( sourceFlags, filterSettings );
				elseif ( settings.actionSchoolColoring ) then
					actionColor = CombatLogUtil.GetColorBySchool( spellSchool, filterSettings );
				else
					actionColor = CombatLogUtil.GetColorByEventType(event, filterSettings);
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
			actionColor = CombatLogUtil.HighlightColor (colorArray);
		end

		if ( actionColor ) then
			actionStr = CombatLogUtil.WrapTextInColor(actionStr, actionColor);
		end

	end
	-- If there's a spell name
	if ( spellName ) then
		local spellAbilityColor = nil;
		-- Color ability names
		if ( settings.abilityColoring ) then
			if ( settings.abilityActorColoring ) then
				spellAbilityColor = CombatLogUtil.GetColorByUnitType( sourceFlags, filterSettings );
			elseif ( settings.abilitySchoolColoring ) then
				spellAbilityColor = CombatLogUtil.GetColorBySchool( spellSchool, filterSettings );
			else
				if ( spellSchool ) then
					spellAbilityColor = filterSettings.colors.defaults.spell;
				end
			end
		end

		-- Highlight this color
		if ( settings.abilityHighlighting ) then
			local colorArray;
			if ( not spellAbilityColor ) then
				colorArray = lineColor;
			else
				colorArray = spellAbilityColor;
			end
			spellAbilityColor  = CombatLogUtil.HighlightColor (colorArray);
		end
		if ( spellAbilityColor ) then
			if ( itemId ) then
				spellNameStr = spellName;
			else
				spellNameStr = CombatLogUtil.WrapTextInColor(spellName, spellAbilityColor);
			end
		end
	end

	-- If there's a spell name
	if ( extraSpellName ) then
		local extraAbilityColor = nil;
		-- Color ability names
		if ( settings.abilityColoring ) then

			if ( settings.abilitySchoolColoring ) then
				extraAbilityColor = CombatLogUtil.GetColorBySchool( extraSpellSchool, filterSettings );
			else
				if ( extraSpellSchool ) then
					extraAbilityColor = CombatLogUtil.GetColorBySchool( SCHOOL_MASK_HOLY, filterSettings );
				else
					extraAbilityColor = CombatLogUtil.GetColorBySchool( nil, filterSettings );
				end
			end
		end
		-- Highlight this color
		if ( settings.abilityHighlighting ) then
			local colorArray;
			if ( not extraAbilityColor ) then
				colorArray = lineColor;
			else
				colorArray = extraAbilityColor;
			end
			extraAbilityColor  = CombatLogUtil.HighlightColor (colorArray);
		end
		if ( extraAbilityColor ) then
			extraSpellNameStr = CombatLogUtil.WrapTextInColor(extraSpellName, extraAbilityColor);
		end
	end

	-- Whole line highlighting
	if ( settings.lineHighlighting ) then
		if ( filterSettings.colors.highlightedEvents[event] ) then
			lineColor = CombatLogUtil.HighlightColor (lineColor);
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
-- Overrides for the combat log
--
-- Save the original event handler
local original_OnEvent = COMBATLOG:GetScript("OnEvent");

COMBATLOG:SetScript("OnEvent", function(self, event, ...)
		if ( event == "COMBAT_LOG_EVENT" ) then
			CombatLog_AddEvent(C_CombatLog.GetCurrentEventInfo());
		else
			original_OnEvent(self, event, ...);
		end
	end
);

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

	-- Parent it to the tab so that we just inherit the tab's alpha. No need to do special fading for it.
	CombatLogQuickButtonFrame:SetParent(_G[COMBATLOG:GetName() .. "Tab"]);
	CombatLogQuickButtonFrame:ClearAllPoints();
	CombatLogQuickButtonFrame:SetPoint("BOTTOMLEFT", COMBATLOG, "TOPLEFT");

	if COMBATLOG.ScrollBar then
		CombatLogQuickButtonFrame:SetPoint("BOTTOMRIGHT", COMBATLOG, "TOPRIGHT", COMBATLOG.ScrollBar:GetWidth(), 0);
	else
		CombatLogQuickButtonFrame:SetPoint("BOTTOMRIGHT", COMBATLOG, "TOPRIGHT");
	end

	CombatLogQuickButtonFrameProgressBar:Hide();

	-- Hook the frame's hide/show events so we can hide/show the quick buttons as appropriate.
	local show, hide = COMBATLOG:GetScript("OnShow"), COMBATLOG:GetScript("OnHide")
	COMBATLOG:RegisterEvent("COMBAT_LOG_EVENT");
	COMBATLOG:SetScript("OnShow", function(self)
		CombatLogQuickButtonFrame_Custom:Show()

		C_CombatLog.SetFilteredEventsEnabled(true);

		Blizzard_CombatLog_QuickButton_OnClick(Blizzard_CombatLog_Filters.currentFilter);
		return show and show(self)
	end)
	COMBATLOG:SetScript("OnHide", function(self)
		CombatLogQuickButtonFrame_Custom:Hide()

		C_CombatLog.SetFilteredEventsEnabled(false);
		return hide and hide(self)
	end)
	if ( COMBATLOG:IsShown() ) then
		C_CombatLog.SetFilteredEventsEnabled(true);
	end

	FCF_SetButtonSide(COMBATLOG, COMBATLOG.buttonSide, true);
	FloatingChatFrame_UpdateBackgroundAnchors(COMBATLOG);
end

local oldFCF_DockUpdate = FCF_DockUpdate;
FCF_DockUpdate = function()
	oldFCF_DockUpdate();
	Blizzard_CombatLog_AdjustCombatLogHeight();
end

--
-- Combat Log Global Functions
--

-- The format of the data describing context menu entries was originally written for the legacy menus
-- but is being funneled into the updated menu system to minimize any changes.
function CreateCombatLogContextMenu(region, tbls)
	MenuUtil.CreateContextMenu(region, function(owner, rootDescription)
		rootDescription:SetTag("MENU_COMBAT_LOG", tbls);

		for index, tbl in ipairs(tbls) do
			if tbl.divider then
				rootDescription:CreateDivider();
			else
				local button = rootDescription:CreateButton(tbl.text, tbl.func);

				-- We can invert 'disabled' here as none of it's uses were functions. If functions are added, 
				-- a function wrapper can be passed instead that inverts the return value of the added function.
				button:SetEnabled(not tbl.disabled);
			end
		end
	end);
end

LinkUtil.RegisterLinkHandler(LinkTypes.Unit, function(link, text, linkData, contextData)
	local guid, name = string.split(":", linkData.options);

	if ( IsModifiedClick("CHATLINK") ) then
		ChatFrameUtil.InsertLink (name);
		return;
	elseif( contextData.button == "RightButton") then
		-- Show Popup Menu
		CreateCombatLogContextMenu(contextData.frame, Blizzard_CombatLog_CreateUnitMenu(name, guid));
		return;
	end

	return LinkProcessorResponse.Unhandled;
end);

LinkUtil.RegisterLinkHandler(LinkTypes.RaidTargetIcon, function(link, text, linkData, contextData)
	local bit, direction = string.split(":", linkData.options);
	local texture = string.gsub(text,".*|h(.*)|h.*","%1");
	-- Show Popup Menu
	if( contextData.button == "RightButton") then
		-- need to fix this to be actual texture
		CreateCombatLogContextMenu(contextData.frame, Blizzard_CombatLog_CreateUnitMenu(CombatLogUtil.GetRaidTargetBraceCode(tonumber(bit)), nil, tonumber(bit)));
	elseif ( IsModifiedClick("CHATLINK") ) then
		ChatFrameUtil.InsertLink (CombatLogUtil.GetRaidTargetBraceCode(tonumber(bit)));
	end
end);

LinkUtil.RegisterLinkHandler(LinkTypes.Spell, function(link, text, linkData, contextData)
	local spellId, glyphId, event = string.split(":", linkData.options);
	spellId = tonumber (spellId);
	glyphId = tonumber (glyphId) or 0;

	if ( IsModifiedClick("CHATLINK") ) then
		if ( spellId > 0 ) then
			if ( ChatFrameUtil.InsertLink(GetSpellLink(spellId, glyphId)) ) then
				return;
			end
		else
			return;
		end
	-- Show Popup Menu
	elseif( contextData.button == "RightButton" and event ) then
		CreateCombatLogContextMenu(contextData.frame, Blizzard_CombatLog_CreateSpellMenu(text, spellId, event));
		return;
	end

	return LinkProcessorResponse.Unhandled;
end);

LinkUtil.RegisterLinkHandler(LinkTypes.Action, function(link, text, linkData, contextData)
	local event = string.split(":", linkData.options);

	-- Show Popup Menu
	if( contextData.button == "RightButton") then
		CreateCombatLogContextMenu(contextData.frame, Blizzard_CombatLog_CreateActionMenu(event));
	end
end);

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
