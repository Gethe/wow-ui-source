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

-- Message Limit
COMBATLOG_LIMIT_PER_FRAME = 1;

COMBATLOG_DEFAULT_SETTINGS = {
	-- Settings
	fullText = false;
	-- textMode = TEXT_MODE_A;
	timestamp = false;
	-- timestampFormat = TEXT_MODE_A_TIMESTAMP;
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
	C_CombatLog.ApplyFilterSettings(Blizzard_CombatLog_CurrentSettings);
	if ( Blizzard_CombatLog_CurrentSettings.settings.showHistory ) then
		C_CombatLog.RefilterEntries();
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
		C_CombatLog.ApplyFilterSettings(Blizzard_CombatLog_CurrentSettings);

	elseif ( event == "SAVE" ) then
		StaticPopup_Show("COPY_COMBAT_FILTER", nil, nil, Blizzard_CombatLog_CurrentSettings);
		return;
	elseif ( event == "RESET" ) then
		Blizzard_CombatLog_PreviousSettings = Blizzard_CombatLog_CurrentSettings;
		Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_Filters.filters[Blizzard_CombatLog_Filters.currentFilter];
		C_CombatLog.ApplyFilterSettings(Blizzard_CombatLog_CurrentSettings);
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
			table.insert ( Blizzard_CombatLog_CurrentSettings.filters, {} );
		end
		if ( event == "INCOMING" or event == "BOTH" ) then
			if ( unitFlags ) then
				table.insert ( Blizzard_CombatLog_CurrentSettings.filters, { destFlags = { [unitFlags] = true; } } );
			else
				table.insert ( Blizzard_CombatLog_CurrentSettings.filters, { destFlags = { [unitGUID] = true; } } );
			end
		end
		if ( event == "OUTGOING" or event == "BOTH" ) then
			if ( unitFlags ) then
				table.insert ( Blizzard_CombatLog_CurrentSettings.filters, { sourceFlags = { [unitFlags] = true; } } );
			else
				table.insert ( Blizzard_CombatLog_CurrentSettings.filters, { sourceFlags = { [unitGUID] = true; } } );
			end
		end
		if ( event == "OUTGOING_ME" ) then
			if ( unitFlags ) then
				table.insert ( Blizzard_CombatLog_CurrentSettings.filters, { sourceFlags = { [unitFlags] = true; }; destFlags = { [COMBATLOG_FILTER_MINE] = true; } } );
			else
				table.insert ( Blizzard_CombatLog_CurrentSettings.filters, { sourceFlags = { [unitGUID] = true; }; destFlags = { [COMBATLOG_FILTER_MINE] = true; } } );
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
		C_CombatLog.ApplyFilterSettings(Blizzard_CombatLog_CurrentSettings);
		-- Let the system know that this filter is temporary and unhighlight any quick buttons
		Blizzard_CombatLog_CurrentSettings.isTemp = true;
		Blizzard_CombatLog_Update_QuickButtons()
	end

	-- Reset the combat log text box! (Grats!)
	C_CombatLog.RefilterEntries();
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
		C_CombatLog.ApplyFilterSettings(Blizzard_CombatLog_CurrentSettings);

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
		C_CombatLog.ApplyFilterSettings(Blizzard_CombatLog_CurrentSettings);
	end

	-- Reset the combat log text box! (Grats!)
	C_CombatLog.RefilterEntries();

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
		local spellLink = C_Spell.GetSpellLink(spellId);

		if ( ChatFrameUtil.GetActiveWindow() ) then
			ChatFrameUtil.InsertLink(spellLink);
		else
			ChatFrameUtil.OpenChat(spellLink);
		end
		return;
	end

	-- Apply the newly reconstituted filters
	C_CombatLog.ApplyFilterSettings(Blizzard_CombatLog_CurrentSettings);

	-- Reset the combat log text box! (Grats!)
	C_CombatLog.RefilterEntries();
end

--
-- Temporary Settings
--
Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_Filters.filters[1];
Blizzard_CombatLog_PreviousSettings = Blizzard_CombatLog_CurrentSettings;
local Blizzard_CombatLog_UnitTokens = {};

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
			C_CombatLog.RefilterEntries();
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
			local spellLink = C_Spell.GetSpellLink(spellId, glyphId);
			if ( ChatFrameUtil.InsertLink(spellLink) ) then
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
	C_CombatLog.ApplyFilterSettings(Blizzard_CombatLog_CurrentSettings);
	if ( Blizzard_CombatLog_CurrentSettings.settings.showHistory ) then
		C_CombatLog.RefilterEntries();
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

CombatLogDriverMixin = {};

function CombatLogDriverMixin:OnLoad()
	EventRegistry:RegisterCallback("OnCombatLogRefilterStarted", self.OnCombatLogRefilterStarted, self);
	EventRegistry:RegisterCallback("OnCombatLogRefilterUpdate", self.OnCombatLogRefilterUpdate, self);
	EventRegistry:RegisterCallback("OnCombatLogRefilterFinished", self.OnCombatLogRefilterFinished, self);
	self:RegisterEvent("COMBAT_LOG_MESSAGE");
	self:RegisterEvent("COMBAT_LOG_MESSAGE_LIMIT_CHANGED");
	self:RegisterEvent("COMBAT_LOG_ENTRIES_CLEARED");
end

function CombatLogDriverMixin:OnEvent(event, ...)
	if event == "COMBAT_LOG_MESSAGE" then
		local text, r, g, b, order = ...;
		self:OnCombatLogMessage(text, r, g, b, order);
	elseif event == "COMBAT_LOG_MESSAGE_LIMIT_CHANGED" then
		local messageLimit = ...;
		self:OnCombatLogMessageLimitChanged(messageLimit);
	elseif event == "COMBAT_LOG_ENTRIES_CLEARED" then
		self:OnCombatLogEntriesCleared();
	end
end

function CombatLogDriverMixin:OnCombatLogMessage(text, r, g, b, order)
	if order == Enum.CombatLogMessageOrder.Oldest then
		COMBATLOG:BackFillMessage(text, r, g, b);
	else
		COMBATLOG:AddMessage(text, r, g, b);
	end
end

function CombatLogDriverMixin:OnCombatLogRefilterStarted()
	COMBATLOG:Clear();
	CombatLogQuickButtonFrameProgressBar:SetMinMaxValues(0, 1);
	CombatLogQuickButtonFrameProgressBar:SetValue(0);
	CombatLogQuickButtonFrameProgressBar:Show();
end

function CombatLogDriverMixin:OnCombatLogRefilterUpdate(progress)
	CombatLogQuickButtonFrameProgressBar:SetValue(progress);
end

function CombatLogDriverMixin:OnCombatLogRefilterFinished()
	CombatLogQuickButtonFrameProgressBar:Hide();
end

function CombatLogDriverMixin:OnCombatLogMessageLimitChanged(messageLimit)
	COMBATLOG:SetMaxLines(messageLimit);
end

function CombatLogDriverMixin:OnCombatLogEntriesCleared()
	COMBATLOG:Clear();
end

local CombatLogDriverFrame = CreateFrame("Frame", "CombatLogDriverFrame");
FrameUtil.SpecializeFrameWithMixins(CombatLogDriverFrame, CombatLogDriverMixin);
