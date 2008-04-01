--[[
--	Blizzard Combat Log
--	 by Alexander Yoshi
--
--	This is a prototype combat log designed to serve the
--	majority of needs for WoW players. The new and improved 
--	combat log event formatting should allow for the community 
--	to develop even better combat logs in the future.
--
--]]

-- Object type constants

-- Affiliation
COMBATLOG_OBJECT_AFFILIATION_MINE		= 0x00000001;
COMBATLOG_OBJECT_AFFILIATION_PARTY		= 0x00000002;
COMBATLOG_OBJECT_AFFILIATION_RAID		= 0x00000004;
COMBATLOG_OBJECT_AFFILIATION_OUTSIDER		= 0x00000008;
COMBATLOG_OBJECT_AFFILIATION_MASK		= 0x0000000F;
-- Reaction
COMBATLOG_OBJECT_REACTION_FRIENDLY		= 0x00000010;
COMBATLOG_OBJECT_REACTION_NEUTRAL		= 0x00000020;
COMBATLOG_OBJECT_REACTION_HOSTILE		= 0x00000040;
COMBATLOG_OBJECT_REACTION_MASK			= 0x000000F0;
-- Ownership
COMBATLOG_OBJECT_CONTROL_PLAYER			= 0x00000100;
COMBATLOG_OBJECT_CONTROL_NPC			= 0x00000200;
COMBATLOG_OBJECT_CONTROL_MASK			= 0x00000300;
-- Unit type
COMBATLOG_OBJECT_TYPE_PLAYER			= 0x00000400;
COMBATLOG_OBJECT_TYPE_NPC			= 0x00000800;
COMBATLOG_OBJECT_TYPE_PET			= 0x00001000;
COMBATLOG_OBJECT_TYPE_GUARDIAN			= 0x00002000;
COMBATLOG_OBJECT_TYPE_OBJECT			= 0x00004000;
COMBATLOG_OBJECT_TYPE_MASK			= 0x0000FC00;

-- Special cases (non-exclusive)
COMBATLOG_OBJECT_TARGET				= 0x00010000;
COMBATLOG_OBJECT_FOCUS				= 0x00020000;
COMBATLOG_OBJECT_MAINTANK			= 0x00040000;
COMBATLOG_OBJECT_MAINASSIST			= 0x00080000;
COMBATLOG_OBJECT_RAIDTARGET1			= 0x00100000;
COMBATLOG_OBJECT_RAIDTARGET2			= 0x00200000;
COMBATLOG_OBJECT_RAIDTARGET3			= 0x00400000;
COMBATLOG_OBJECT_RAIDTARGET4			= 0x00800000;
COMBATLOG_OBJECT_RAIDTARGET5			= 0x01000000;
COMBATLOG_OBJECT_RAIDTARGET6			= 0x02000000;
COMBATLOG_OBJECT_RAIDTARGET7			= 0x04000000;
COMBATLOG_OBJECT_RAIDTARGET8			= 0x08000000;
COMBATLOG_OBJECT_NONE				= 0x80000000;
COMBATLOG_OBJECT_SPECIAL_MASK			= 0xFFFF0000;

-- Object type constants
COMBATLOG_FILTER_ME			= bit.bor(
						COMBATLOG_OBJECT_AFFILIATION_MINE,
						COMBATLOG_OBJECT_REACTION_FRIENDLY,
						COMBATLOG_OBJECT_CONTROL_PLAYER,
						COMBATLOG_OBJECT_TYPE_PLAYER
						);
						
COMBATLOG_FILTER_MINE			= bit.bor(
						COMBATLOG_OBJECT_AFFILIATION_MINE,
						COMBATLOG_OBJECT_REACTION_FRIENDLY,
						COMBATLOG_OBJECT_CONTROL_PLAYER,
						COMBATLOG_OBJECT_TYPE_PLAYER,
						COMBATLOG_OBJECT_TYPE_OBJECT
						);

COMBATLOG_FILTER_MY_PET			= bit.bor(
						COMBATLOG_OBJECT_AFFILIATION_MINE,
						COMBATLOG_OBJECT_REACTION_FRIENDLY,
						COMBATLOG_OBJECT_CONTROL_PLAYER,
						COMBATLOG_OBJECT_TYPE_GUARDIAN,
						COMBATLOG_OBJECT_TYPE_PET
						);
COMBATLOG_FILTER_FRIENDLY_UNITS		= bit.bor(
						COMBATLOG_OBJECT_AFFILIATION_PARTY,
						COMBATLOG_OBJECT_AFFILIATION_RAID,
						COMBATLOG_OBJECT_AFFILIATION_OUTSIDER,
						COMBATLOG_OBJECT_REACTION_FRIENDLY,
						COMBATLOG_OBJECT_CONTROL_PLAYER,
						COMBATLOG_OBJECT_CONTROL_NPC,
						COMBATLOG_OBJECT_TYPE_PLAYER,
						COMBATLOG_OBJECT_TYPE_NPC,
						COMBATLOG_OBJECT_TYPE_PET,
						COMBATLOG_OBJECT_TYPE_GUARDIAN,
						COMBATLOG_OBJECT_TYPE_OBJECT
						);

COMBATLOG_FILTER_HOSTILE_UNITS		= bit.bor(
						COMBATLOG_OBJECT_AFFILIATION_PARTY,
						COMBATLOG_OBJECT_AFFILIATION_RAID,
						COMBATLOG_OBJECT_AFFILIATION_OUTSIDER,
						COMBATLOG_OBJECT_REACTION_NEUTRAL,
						COMBATLOG_OBJECT_REACTION_HOSTILE,
						COMBATLOG_OBJECT_CONTROL_PLAYER,
						COMBATLOG_OBJECT_CONTROL_NPC,
						COMBATLOG_OBJECT_TYPE_PLAYER,
						COMBATLOG_OBJECT_TYPE_NPC,
						COMBATLOG_OBJECT_TYPE_PET,
						COMBATLOG_OBJECT_TYPE_GUARDIAN,
						COMBATLOG_OBJECT_TYPE_OBJECT
						);

COMBATLOG_FILTER_NEUTRAL_UNITS		= bit.bor(
						COMBATLOG_OBJECT_AFFILIATION_PARTY,
						COMBATLOG_OBJECT_AFFILIATION_RAID,
						COMBATLOG_OBJECT_AFFILIATION_OUTSIDER,
						COMBATLOG_OBJECT_REACTION_NEUTRAL,
						COMBATLOG_OBJECT_CONTROL_PLAYER,
						COMBATLOG_OBJECT_CONTROL_NPC,
						COMBATLOG_OBJECT_TYPE_PLAYER,
						COMBATLOG_OBJECT_TYPE_NPC,
						COMBATLOG_OBJECT_TYPE_PET,
						COMBATLOG_OBJECT_TYPE_GUARDIAN,
						COMBATLOG_OBJECT_TYPE_OBJECT
						);

COMBATLOG_FILTER_EVERYTHING =	0xFFFFFFFF;

-- Define the log
COMBATLOG = ChatFrame2;

-- BUFF / DEBUFF
AURA_TYPE_BUFF = "BUFF";
AURA_TYPE_DEBUFF = "DEBUFF"

-- Power Types
SPELL_POWER_MANA = 0;
SPELL_POWER_RAGE = 1;
SPELL_POWER_FOCUS = 2;
SPELL_POWER_ENERGY = 3;
SPELL_POWER_HAPPINESS = 4;
SPELL_POWER_RUNES = 5;

-- Temporary
SCHOOL_MASK_NONE	= 0x00;
SCHOOL_MASK_PHYSICAL	= 0x01;
SCHOOL_MASK_HOLY	= 0x02;
SCHOOL_MASK_FIRE	= 0x04;
SCHOOL_MASK_NATURE	= 0x08;
SCHOOL_MASK_FROST	= 0x10;
SCHOOL_MASK_SHADOW	= 0x20;
SCHOOL_MASK_ARCANE	= 0x40;

-- Message Limit
COMBATLOG_MESSAGE_LIMIT = 300;
COMBATLOG_LIMIT_PER_FRAME = 5;
COMBATLOG_HIGHLIGHT_MULTIPLIER = 1.5;

-- Default Colors
COMBATLOG_DEFAULT_COLORS = {
	-- Unit names
	unitColoring = {
		[COMBATLOG_FILTER_MINE] 		= {a=1.0,r=0.70,g=0.70,b=0.70}; --{a=1.0,r=0.14,g=1.00,b=0.15};
		[COMBATLOG_FILTER_MY_PET] 		= {a=1.0,r=0.70,g=0.70,b=0.70}; --{a=1.0,r=0.14,g=0.80,b=0.15};
		[COMBATLOG_FILTER_FRIENDLY_UNITS] 	= {a=1.0,r=0.34,g=0.64,b=1.00};
		[COMBATLOG_FILTER_HOSTILE_UNITS] 	= {a=1.0,r=0.75,g=0.05,b=0.05};
		[COMBATLOG_FILTER_NEUTRAL_UNITS] 	= {a=1.0,r=0.75,g=0.05,b=0.05}; -- {a=1.0,r=0.80,g=0.80,b=0.14};
	};
	-- School coloring
	schoolColoring = {
		default			= {a=1.0,r=1.00,g=1.00,b=1.00};
		[SCHOOL_MASK_NONE]	= {a=1.0,r=1.00,g=1.00,b=1.00};
		[SCHOOL_MASK_PHYSICAL]	= {a=1.0,r=1.00,g=1.00,b=0.00};
		[SCHOOL_MASK_HOLY] 	= {a=1.0,r=1.00,g=0.90,b=0.50};
		[SCHOOL_MASK_FIRE] 	= {a=1.0,r=1.00,g=0.50,b=0.00};
		[SCHOOL_MASK_NATURE] 	= {a=1.0,r=0.30,g=1.00,b=0.30};
		[SCHOOL_MASK_FROST] 	= {a=1.0,r=0.50,g=1.00,b=1.00};
		[SCHOOL_MASK_SHADOW] 	= {a=1.0,r=0.50,g=0.50,b=1.00};
		[SCHOOL_MASK_ARCANE] 	= {a=1.0,r=1.00,g=0.50,b=1.00};
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
			actionHighlighting = true;
			amountColoring = false;
			amountActorColoring = false;
			amountSchoolColoring = false;
			amountHighlighting = true;
			schoolNameColoring = true;
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
			--unitTokens = true;
};

--
-- Combat Log Icons
--
COMBATLOG_ICON_RAIDTARGET1			= "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1.blp:$size|t";
COMBATLOG_ICON_RAIDTARGET2			= "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2.blp:$size|t";
COMBATLOG_ICON_RAIDTARGET3			= "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3.blp:$size|t";
COMBATLOG_ICON_RAIDTARGET4			= "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4.blp:$size|t";
COMBATLOG_ICON_RAIDTARGET5			= "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5.blp:$size|t";
COMBATLOG_ICON_RAIDTARGET6			= "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6.blp:$size|t";
COMBATLOG_ICON_RAIDTARGET7			= "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7.blp:$size|t";
COMBATLOG_ICON_RAIDTARGET8			= "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8.blp:$size|t";

-- 
-- Master Event List
--
COMBATLOG_EVENT_LIST = {
      "ENVIRONMENTAL_DAMAGE",
      "SWING_DAMAGE",
      "SWING_MISSED",
      "RANGE_DAMAGE",
      "RANGE_MISSED",
      "SPELL_CAST_START",
      "SPELL_CAST_SUCCESS",
      "SPELL_CAST_FAILED",
      "SPELL_MISSED",
      "SPELL_DAMAGE",
      "SPELL_HEAL",
      "SPELL_ENERGIZE",
      "SPELL_DRAIN",
      "SPELL_LEECH",
      "SPELL_INSTAKILL",
      "SPELL_INTERRUPT",
      "SPELL_EXTRA_ATTACKS",
      "SPELL_DURABILITY_DAMAGE",
      "SPELL_DURABILITY_DAMAGE_ALL",
      "SPELL_AURA_APPLIED",
      "SPELL_AURA_APPLIED_DOSE",
      "SPELL_AURA_REMOVED",
      "SPELL_AURA_REMOVED_DOSE",
      "SPELL_AURA_DISPELLED",
      "SPELL_AURA_STOLEN",
      "ENCHANT_APPLIED",
      "ENCHANT_REMOVED",
      "SPELL_PERIODIC_MISSED",
      "SPELL_PERIODIC_DAMAGE",
      "SPELL_PERIODIC_HEAL",
      "SPELL_PERIODIC_ENERGIZE",
      "SPELL_PERIODIC_DRAIN",
      "SPELL_PERIODIC_LEECH",
      "SPELL_DISPEL_FAILED",
      "DAMAGE_SHIELD",
      "DAMAGE_SHIELD_MISSED",
      "DAMAGE_SPLIT",
      "PARTY_KILL",
      "UNIT_DIED",
      "UNIT_DESTROYED"
};

-- 
-- Combat Log Filter Resetting Code
--
-- args:
-- 	config - the configuration array we are about to apply
-- 
function Blizzard_CombatLog_ApplyFilters(config)
	CombatLogResetFilter()

	-- Loop over all associated filters
	for k,v in pairs(config.filters) do
		local eList = nil;
		if ( v.eventList ) then
			eList = "";
			for k2,v2 in pairs(v.eventList) do 
				if ( v2 ) then
					eList = eList..k2..",";
				end
			end
		end
		CombatLogAddFilter(eList, v.sourceFlags, v.destFlags)
	end
end

--
-- Combat Log Repopulation Code
--

-- 
-- Repopulate the combat log with message history
--
function Blizzard_CombatLog_Refilter()
	local count = CombatLogGetNumEntries();
	local valid;
	
	-- index can be 
	--  positive starting from the oldest entries
	--  negative starting from the newest entries
	if ( count < COMBATLOG_MESSAGE_LIMIT ) then
		valid = CombatLogSetCurrentEntry(1); 
	else
		valid = CombatLogSetCurrentEntry(-COMBATLOG_MESSAGE_LIMIT); 
	end

	-- Clear the combat log
	COMBATLOG:Clear();
	CombatLogQuickButtonFrameProgressBar:SetMinMaxValues(0, COMBATLOG_MESSAGE_LIMIT);
	CombatLogQuickButtonFrameProgressBar:SetValue(0);
	CombatLogQuickButtonFrameProgressBar:Show();

	-- Enable the distributed frame
	CombatLogUpdateFrame.refiltering = true;
	Blizzard_CombatLog_RefilterUpdate()
end

--
-- This is a single frame "step" in the refiltering process
--
function Blizzard_CombatLog_RefilterUpdate()
	if ( not CombatLogUpdateFrame.refiltering ) then
		return;
	end
	local count = CombatLogGetNumEntries();
	local valid = CombatLogGetCurrentEntry(); -- CombatLogAdvanceEntry(0);
	
	local info = ChatTypeInfo["COMBAT_MISC_INFO"];
	local timestamp, event, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags;

	-- Clear the combat log
	local total = 0;
	while (valid and total < COMBATLOG_LIMIT_PER_FRAME) do 
		-- Log to the window
		local finalMessage, r, g, b = CombatLog_OnEvent(COMBATLOG, CombatLogGetCurrentEntry() );

		-- Debug line for hyperlinks
		-- finalMessage = string.gsub( finalMessage, "\124", "\124\124");

		if ( DEBUG == true ) then
			ChatFrame1:AddMessage(message, info.r, info.g, info.b);
		end

		-- Add the messages
		COMBATLOG:AddMessage( finalMessage, r, g, b, 1 )

		-- count can be 
		--  positive to advance from oldest to newest
		--  negative to advance from newest to oldest
		valid = CombatLogAdvanceEntry(1)
		total = total + 1;
	end

	-- Show filtering progress bar
	local barMax = count;
	if ( count > COMBATLOG_MESSAGE_LIMIT ) then
		barMax = COMBATLOG_MESSAGE_LIMIT;
	end
	
	CombatLogQuickButtonFrameProgressBar:SetMinMaxValues(0, barMax);
	CombatLogQuickButtonFrameProgressBar:SetValue(CombatLogQuickButtonFrameProgressBar:GetValue() + total);
	CombatLogQuickButtonFrameProgressBar:Show();

	if ( not valid ) then
		this.refiltering = false;
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
			for _,event in pairs ( {...} ) do 
				if ( filter.eventList[event] ) then
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

		for _, event in pairs ( {...} ) do 
			filter.eventList[event] = true;
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
			for _, event in pairs ( {...} ) do 
				filter.eventList[event] = false;
			end
		end
	end
end

-- 
-- Creates the action menu popup
--
function Blizzard_CombatLog_CreateActionMenu(eventType)
	local menu = {
		[1] = {
			text = string.format(BLIZZARD_COMBAT_LOG_MENU_SPELL_HIDE, eventType),
			func = function () Blizzard_CombatLog_SpellMenuClick ("HIDE",  nil, nil, eventType); end;
		},
	};
	return menu;
end

-- 
-- Creates the spell menu popup
--
function Blizzard_CombatLog_CreateSpellMenu(spellName, spellId, eventType)
	local menu = {
		[1] = {
			text = string.format(BLIZZARD_COMBAT_LOG_MENU_SPELL_LINK, spellName),
			func = function () Blizzard_CombatLog_SpellMenuClick ("LINK", spellName, spellId, eventType); end;
		},
	};
	if ( eventType ) then
		menu[2] = {
			text = string.format(BLIZZARD_COMBAT_LOG_MENU_SPELL_HIDE, eventType),
			func = function () Blizzard_CombatLog_SpellMenuClick ("HIDE", spellName, spellId, eventType); end;
		};
		menu[3] = 
		{
			text = "------------------";
			disabled = true;
		};
		menu[4] = Blizzard_CombatLog_FormattingMenu(Blizzard_CombatLog_Filters.currentFilter);
		menu[5] = Blizzard_CombatLog_MessageTypesMenu(Blizzard_CombatLog_Filters.currentFilter);
	end


	return menu;
end

--
-- Temporary Menu
--
function Blizzard_CombatLog_MessageTypesMenu()

	local messageTypes = {
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
					checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_AURA_APPLIED", "SPELL_AURA_APPLIED_DOSE", "SPELL_AURA_REMOVED", "SPELL_AURA_REMOVED_DOSE", "SPELL_AURA_DISPELLED", "SPELL_AURA_STOLEN",  "ENCHANT_APPLIED",  "ENCHANT_REMOVED" ); end;
					keepShownOnClick = true;
					func = function ( arg1, arg2, checked )
						Blizzard_CombatLog_MenuHelper ( checked, "SPELL_AURA_APPLIED", "SPELL_AURA_APPLIED_DOSE", "SPELL_AURA_REMOVED", "SPELL_AURA_REMOVED_DOSE", "SPELL_AURA_DISPELLED", "SPELL_AURA_STOLEN",  "ENCHANT_APPLIED", "ENCHANT_REMOVED" );
					end;
					menuList = {
						[1] = {
							text = "Applied";
							checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_AURA_APPLIED", "SPELL_AURA_APPLIED_DOSE"); end;
							keepShownOnClick = true;
							func = function ( arg1, arg2, checked )
								Blizzard_CombatLog_MenuHelper ( checked, "SPELL_AURA_APPLIED", "SPELL_AURA_APPLIED_DOSE",  "ENCHANT_APPLIED" );
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
							checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_AURA_DISPELLED"); end;
							keepShownOnClick = true;
							func = function ( arg1, arg2, checked )
								Blizzard_CombatLog_MenuHelper ( checked, "SPELL_AURA_DISPELLED" );
							end;
						};
						[4] = {
							text = "Stolen";
							checked = function() return Blizzard_CombatLog_HasEvent (Blizzard_CombatLog_CurrentSettings, "SPELL_AURA_STOLEN"); end;
							keepShownOnClick = true;
							func = function ( arg1, arg2, checked )
								Blizzard_CombatLog_MenuHelper ( checked, "SPELL_AURA_STOLEN" );
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
	return messageTypes;
end

--
-- Temporary Menu
--
function Blizzard_CombatLog_FormattingMenu(filterId)
	local formattingMenu = 
		{
			text = "Formatting";
			hasArrow = true;
			menuList = {
				{
					text = "Full Text";
					checked = function() return Blizzard_CombatLog_Filters.filters[filterId].settings.fullText; end;
					func = function(arg1, arg2, checked)
						Blizzard_CombatLog_Filters.filters[filterId].settings.fullText = checked;
						Blizzard_CombatLog_QuickButton_OnClick(Blizzard_CombatLog_Filters.currentFilter)
					end;
					keepShownOnClick = true;
				},
				{
					text = "Timestamp";
					checked = function() return Blizzard_CombatLog_Filters.filters[filterId].settings.timestamp; end;
					func = function(arg1, arg2, checked)
						Blizzard_CombatLog_Filters.filters[filterId].settings.timestamp = checked;
						Blizzard_CombatLog_QuickButton_OnClick(Blizzard_CombatLog_Filters.currentFilter)
					end;
					keepShownOnClick = true;
				},
				{
					text = "Unit Name Coloring";
					checked = function() return Blizzard_CombatLog_Filters.filters[filterId].settings.unitColoring; end;
					func = function(arg1, arg2, checked)
						Blizzard_CombatLog_Filters.filters[filterId].settings.unitColoring = checked;
						Blizzard_CombatLog_QuickButton_OnClick(Blizzard_CombatLog_Filters.currentFilter)
					end;
					keepShownOnClick = true;
				},
				{
					text = "Line Coloring";
					checked = function() return  Blizzard_CombatLog_Filters.filters[filterId].settings.lineColoring; end;
					func = function(arg1, arg2, checked)
						Blizzard_CombatLog_Filters.filters[filterId].settings.lineColoring = checked;
						Blizzard_CombatLog_QuickButton_OnClick(Blizzard_CombatLog_Filters.currentFilter)
					end;
					keepShownOnClick = true;
				},
				{
					text = "Line Highlighting";
					checked = function() return  Blizzard_CombatLog_Filters.filters[filterId].settings.lineHighlighting; end;
					func = function(arg1, arg2, checked)
						Blizzard_CombatLog_Filters.filters[filterId].settings.lineHighlighting = checked;
						Blizzard_CombatLog_QuickButton_OnClick(Blizzard_CombatLog_Filters.currentFilter)
					end;
					keepShownOnClick = true;
				},
				{
					text = "Ability Coloring";
					checked = function() return Blizzard_CombatLog_Filters.filters[filterId].settings.abilityColoring; end;
					func = function(arg1, arg2, checked)
						Blizzard_CombatLog_Filters.filters[filterId].settings.abilityColoring = checked;
						Blizzard_CombatLog_QuickButton_OnClick(Blizzard_CombatLog_Filters.currentFilter)
					end;
					keepShownOnClick = true;
				},
				{
					text = "Ability-by-School Coloring";
					checked = function() return Blizzard_CombatLog_Filters.filters[filterId].settings.abilitySchoolColoring; end;
					--disabled = not Blizzard_CombatLog_Filters.filters[filterId].settings.abilityColoring;
					func = function(arg1, arg2, checked)
						Blizzard_CombatLog_Filters.filters[filterId].settings.abilitySchoolColoring = checked;
						Blizzard_CombatLog_QuickButton_OnClick(Blizzard_CombatLog_Filters.currentFilter)
					end;
					keepShownOnClick = true;
				},
				{
					text = "Ability-by-Actor Coloring";
					checked = function() return Blizzard_CombatLog_Filters.filters[filterId].settings.abilityActorColoring; end;
					func = function(arg1, arg2, checked)
						Blizzard_CombatLog_Filters.filters[filterId].settings.abilityActorColoring = checked;
						Blizzard_CombatLog_QuickButton_OnClick(Blizzard_CombatLog_Filters.currentFilter)
					end;
					keepShownOnClick = true;
				},
				{
					text = "Ability Highlighting";
					checked = function() return Blizzard_CombatLog_Filters.filters[filterId].settings.abilityHighlighting; end;
					func = function(arg1, arg2, checked)
						Blizzard_CombatLog_Filters.filters[filterId].settings.abilityHighlighting = checked;
						Blizzard_CombatLog_QuickButton_OnClick(Blizzard_CombatLog_Filters.currentFilter)
					end;
					keepShownOnClick = true;
				},
				{
					text = "Action Coloring";
					checked = function() return Blizzard_CombatLog_Filters.filters[filterId].settings.actionColoring; end;
					func = function(arg1, arg2, checked)
						Blizzard_CombatLog_Filters.filters[filterId].settings.actionColoring = checked;
						Blizzard_CombatLog_QuickButton_OnClick(Blizzard_CombatLog_Filters.currentFilter)
					end;
					keepShownOnClick = true;
				},
				{
					text = "Action-by-School Coloring";
					checked = function() return Blizzard_CombatLog_Filters.filters[filterId].settings.actionSchoolColoring; end;
					func = function(arg1, arg2, checked)
						Blizzard_CombatLog_Filters.filters[filterId].settings.actionSchoolColoring = checked;
						Blizzard_CombatLog_QuickButton_OnClick(Blizzard_CombatLog_Filters.currentFilter)
					end;
					keepShownOnClick = true;
				},
				{
					text = "Action-by-Actor Coloring";
					checked = function() return Blizzard_CombatLog_Filters.filters[filterId].settings.actionActorColoring; end;
					--disabled = not Blizzard_CombatLog_Filters.filters[filterId].settings.abilityColoring;
					func = function(arg1, arg2, checked)
						Blizzard_CombatLog_Filters.filters[filterId].settings.actionActorColoring = checked;
						Blizzard_CombatLog_QuickButton_OnClick(Blizzard_CombatLog_Filters.currentFilter)
					end;
					keepShownOnClick = true;
				},
				{
					text = "Action Highlighting";
					checked = function() return Blizzard_CombatLog_Filters.filters[filterId].settings.actionHighlighting; end;
					--disabled = not Blizzard_CombatLog_Filters.filters[filterId].settings.abilityColoring;
					func = function(arg1, arg2, checked)
						Blizzard_CombatLog_Filters.filters[filterId].settings.actionHighlighting = checked;
						Blizzard_CombatLog_QuickButton_OnClick(Blizzard_CombatLog_Filters.currentFilter)
					end;
					keepShownOnClick = true;
				},
				{
					text = "Damage Coloring";
					checked = function() return Blizzard_CombatLog_Filters.filters[filterId].settings.amountColoring; end;
					func = function(arg1, arg2, checked)
						Blizzard_CombatLog_Filters.filters[filterId].settings.amountColoring = checked;
						Blizzard_CombatLog_QuickButton_OnClick(Blizzard_CombatLog_Filters.currentFilter)
					end;
					keepShownOnClick = true;
				},
				{
					text = "Damage-by-School Coloring";
					checked = function() return Blizzard_CombatLog_Filters.filters[filterId].settings.amountSchoolColoring; end;
					--disabled = not Blizzard_CombatLog_Filters.filters[filterId].settings.amountColoring;
					func = function(arg1, arg2, checked)
						Blizzard_CombatLog_Filters.filters[filterId].settings.amountSchoolColoring = checked;
						Blizzard_CombatLog_QuickButton_OnClick(Blizzard_CombatLog_Filters.currentFilter)
					end;
					keepShownOnClick = true;
				},
				{
					text = "Damage-by-Actor Coloring";
					checked = function() return Blizzard_CombatLog_Filters.filters[filterId].settings.amountActorColoring; end;
					--disabled = not Blizzard_CombatLog_Filters.filters[filterId].settings.amountColoring;
					func = function(arg1, arg2, checked)
						Blizzard_CombatLog_Filters.filters[filterId].settings.amountActorColoring = checked;
						Blizzard_CombatLog_QuickButton_OnClick(Blizzard_CombatLog_Filters.currentFilter)
					end;
					keepShownOnClick = true;
				},
				{
					text = "Damage Highlighting";
					checked = function() return Blizzard_CombatLog_Filters.filters[filterId].settings.amountHighlighting; end;
					func = function(arg1, arg2, checked)
						Blizzard_CombatLog_Filters.filters[filterId].settings.amountHighlighting = checked;
						Blizzard_CombatLog_QuickButton_OnClick(Blizzard_CombatLog_Filters.currentFilter)
					end;
					keepShownOnClick = true;
				},				
				{
					text = "Color School Names";
					checked = function() return Blizzard_CombatLog_Filters.filters[filterId].settings.schoolNameColoring; end;
					func = function(arg1, arg2, checked)
						Blizzard_CombatLog_Filters.filters[filterId].settings.schoolNameColoring = checked;
						Blizzard_CombatLog_QuickButton_OnClick(Blizzard_CombatLog_Filters.currentFilter)
					end;
					keepShownOnClick = true;
				},
				{
					text = "School Name Highlighting";
					checked = function() return Blizzard_CombatLog_Filters.filters[filterId].settings.schoolNameHighlighting; end;
					func = function(arg1, arg2, checked)
						Blizzard_CombatLog_Filters.filters[filterId].settings.schoolNameHighlighting = checked;
						Blizzard_CombatLog_QuickButton_OnClick(Blizzard_CombatLog_Filters.currentFilter)
					end;
					keepShownOnClick = true;
				},
				{
					text = "White Swing Rule";
					checked = function() return Blizzard_CombatLog_Filters.filters[filterId].settings.noMeleeSwingColoring; end;
					func = function(arg1, arg2, checked)
						Blizzard_CombatLog_Filters.filters[filterId].settings.noMeleeSwingColoring = checked;
						Blizzard_CombatLog_QuickButton_OnClick(Blizzard_CombatLog_Filters.currentFilter)
					end;
					keepShownOnClick = true;
				},
				{
					text = "Misses Colored Rule";
					checked = function() return Blizzard_CombatLog_Filters.filters[filterId].settings.missColoring; end;
					func = function(arg1, arg2, checked)
						Blizzard_CombatLog_Filters.filters[filterId].settings.missColoring = checked;
						Blizzard_CombatLog_QuickButton_OnClick(Blizzard_CombatLog_Filters.currentFilter)
					end;
					keepShownOnClick = true;
				},
				{
					text = "Braces";
					checked = function() return Blizzard_CombatLog_Filters.filters[filterId].settings.braces; end;
					func = function(arg1, arg2, checked)
						Blizzard_CombatLog_Filters.filters[filterId].settings.braces = checked;
						Blizzard_CombatLog_QuickButton_OnClick(Blizzard_CombatLog_Filters.currentFilter)
					end;
					keepShownOnClick = true;
				},
				{
					text = "Refiltering";
					checked = function() return Blizzard_CombatLog_Filters.filters[filterId].settings.showHistory; end;
					func = function(arg1, arg2, checked)
						Blizzard_CombatLog_Filters.filters[filterId].settings.showHistory = checked;
						Blizzard_CombatLog_QuickButton_OnClick(Blizzard_CombatLog_Filters.currentFilter)
					end;
					keepShownOnClick = true;
					tooltipTitle = "Refiltering";
					tooltipText = "This clears the chat frame and refills it with the last 500 events.";
				},
			};
		};
	return formattingMenu;
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
function Blizzard_CombatLog_CreateTabMenu ( filterId )
	local menu = {
		{
			text = BLIZZARD_COMBAT_LOG_MENU_EVERYTHING;
			func = function () Blizzard_CombatLog_UnitMenuClick ("EVERYTHING", unitName, unitGUID, special); end;
		},
		{
			text = BLIZZARD_COMBAT_LOG_MENU_REVERT;
			disabled = (Blizzard_CombatLog_PreviousSettings == Blizzard_CombatLog_CurrentSettings);
			func = function () Blizzard_CombatLog_UnitMenuClick ("REVERT", unitName, unitGUID, special); end;
		},
		{
			text = BLIZZARD_COMBAT_LOG_MENU_RESET;
			func = function () Blizzard_CombatLog_UnitMenuClick ("RESET", unitName, unitGUID, special); end;
		},
		{
			text = "--------- Temporary Adjustments ---------";
			disabled = true;
		},
	};

	menu[5] = Blizzard_CombatLog_FormattingMenu(filterId);
	menu[6] = Blizzard_CombatLog_MessageTypesMenu(filterId);
	return menu;
end


--
-- Temporary Menu
--
function Blizzard_CombatLog_CreateUnitMenu(unitName, unitGUID, special)
	local displayName = unitName;
	if ( unitName == UnitName("player") ) then
		displayName = UNIT_YOU;
	end

	local menu = {
		[1] = {
			text = string.format(BLIZZARD_COMBAT_LOG_MENU_BOTH, displayName),
			func = function () Blizzard_CombatLog_UnitMenuClick ("BOTH", unitName, unitGUID, special); end;
		},
		[2] = {
			text = string.format(BLIZZARD_COMBAT_LOG_MENU_INCOMING, displayName),
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
			text = BLIZZARD_COMBAT_LOG_MENU_REVERT;
			disabled = (Blizzard_CombatLog_PreviousSettings == Blizzard_CombatLog_CurrentSettings);
			func = function () Blizzard_CombatLog_UnitMenuClick ("REVERT", unitName, unitGUID, special); end;
		},
		[7] = {
			text = BLIZZARD_COMBAT_LOG_MENU_RESET;
			func = function () Blizzard_CombatLog_UnitMenuClick ("RESET", unitName, unitGUID, special); end;
		},
		[8] = {
			text = "--------- Temporary Adjustments ---------";
			disabled = true;
		},
	};

	menu[9] = Blizzard_CombatLog_FormattingMenu(Blizzard_CombatLog_Filters.currentFilter);
	menu[10] = Blizzard_CombatLog_MessageTypesMenu(Blizzard_CombatLog_Filters.currentFilter);

	return menu;
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
	-- Reset all filtering.
	CombatLogResetFilter()
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

	elseif ( event == "RESET" ) then
		Blizzard_CombatLog_PreviousSettings = Blizzard_CombatLog_CurrentSettings;
		Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_Filters.filters[Blizzard_CombatLog_Filters.currentFilter];
		--CombatLogAddFilter(nil, nil, COMBATLOG_FILTER_MINE)
		--CombatLogAddFilter(nil, COMBATLOG_FILTER_MINE, nil)
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
			--Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_Filters.contextMenu[event];
			CombatLogAddFilter(nil, nil, nil)	
			table.insert ( Blizzard_CombatLog_CurrentSettings.filters, {} );
		end
		if ( event == "INCOMING" or event == "BOTH" ) then
			if ( unitFlags ) then
				table.insert ( Blizzard_CombatLog_CurrentSettings.filters, { destFlags = unitFlags } );
			else
				table.insert ( Blizzard_CombatLog_CurrentSettings.filters, { destFlags = unitGUID } );
			end
		end
		if ( event == "OUTGOING" or event == "BOTH" ) then
			if ( unitFlags ) then
				table.insert ( Blizzard_CombatLog_CurrentSettings.filters, { sourceFlags = unitFlags } );
			else
				table.insert ( Blizzard_CombatLog_CurrentSettings.filters, { sourceFlags = unitGUID } );
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
	end

	-- Reset the combat log text box! (Grats!)
	Blizzard_CombatLog_Refilter();
end

--
-- Shows a simplified version of the menu if you right click on the quick button
--
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
	for k,event in pairs ( COMBATLOG_EVENT_LIST ) do
		eventList[event] = true;
	end

	return eventList;
end


-- 
-- Persistant Variables
-- 
Blizzard_CombatLog_Filters = {

	-- Special case filters for context menu
	contextMenu = {
		["BOTH"] = {
			-- Descriptive Information
			name = "Context Menu: Everything involving the unit?";
			hasQuickButton = false;
			quickButtonName = "Involving Unit";
			quickButtonDisplay = {
				solo = false;
				party = false;
				raid = false;
			};

			-- Settings			
			fullText = false;
			textMode = TEXT_MODE_A;
			timestamp = true;
			timestampFormat = TEXT_MODE_A_TIMESTAMP;
			unitColoring = true;
			sourceColoring = true;
			destColoring = true;
			lineColoring = false;
			abilityColoring = true;
			abilitySchoolColoring = true;
			abilityActorColoring = false;
			amountColoring = true;
			amountSchoolColoring = true;
			amountActorColoring = false;
			schoolNameColoring = true;
			noMeleeSwingColoring = false;
			braces = true;
			unitBraces = true;
			sourceBraces = true;
			destBraces = true;
			spellBraces = false;
			itemBraces = true;
			showHistory = true;
			hideBuffs = true;
			hideDebuffs = true;
			lineColorPriority = 1; -- 1 = source->dest->event, 2 = dest->source->event, 3 = event->source->dest
			unitIcons = true;
			--unitTokens = true;
		};
		["INCOMING"] = {
			-- Descriptive Information
			name = "Context Menu: What happened to it?";
			hasQuickButton = false;
			quickButtonName = "What happened to it?";
			quickButtonDisplay = {
				solo = false;
				party = false;
				raid = false;
			};

			-- Settings
			fullText = false;
			textMode = TEXT_MODE_A;
			timestamp = true;
			timestampFormat = TEXT_MODE_A_TIMESTAMP;
			unitColoring = true;
			sourceColoring = true;
			destColoring = true;
			lineColoring = false;
			abilityColoring = true;
			abilitySchoolColoring = true;
			abilityActorColoring = false;
			amountColoring = true;
			amountSchoolColoring = true;
			amountActorColoring = false;
			schoolNameColoring = true;
			noMeleeSwingColoring = false;
			braces = true;
			unitBraces = true;
			sourceBraces = true;
			destBraces = true;
			spellBraces = false;
			itemBraces = true;
			showHistory = true;
			hideBuffs = true;
			hideDebuffs = true;
			lineColorPriority = 1; -- 1 = source->dest->event, 2 = dest->source->event, 3 = event->source->dest
			unitIcons = true;
			--unitTokens = true;
		};
		["OUTGOING"] = {
			-- Descriptive Information
			name = "Context Menu: What did unit do?";
			hasQuickButton = false;
			quickButtonName = "What did it do?";
			quickButtonDisplay = {
				solo = false;
				party = false;
				raid = false;
			};

			-- Settings
			fullText = false;
			textMode = TEXT_MODE_A;
			timestamp = true;
			timestampFormat = TEXT_MODE_A_TIMESTAMP;
			unitColoring = true;
			sourceColoring = true;
			destColoring = true;
			lineColoring = false;
			abilityColoring = true;
			abilitySchoolColoring = true;
			abilityActorColoring = false;
			amountActorColoring = false;
			amountColoring = true;
			amountSchoolColoring = true;
			schoolNameColoring = true;
			noMeleeSwingColoring = false;
			braces = true;
			unitBraces = true;
			sourceBraces = true;
			destBraces = true;
			spellBraces = false;
			itemBraces = true;
			showHistory = true;
			hideBuffs = true;
			hideDebuffs = true;
			lineColorPriority = 1; -- 1 = source, 2 = caster			
			unitIcons = true;
			--unitTokens = true;
		};
		["EVERYTHING"] = {
			-- Descriptive Information
			name = "Context Menu: Show Everything";
			hasQuickButton = false;
			quickButtonName = "Everything";
			quickButtonDisplay = {
				solo = false;
				party = false;
				raid = false;
			};

			-- Settings
			fullText = false;
			textMode = TEXT_MODE_A;
			timestamp = true;
			timestampFormat = TEXT_MODE_A_TIMESTAMP;
			unitColoring = false;
			sourceColoring = true;
			destColoring = true;
			lineColoring = true;
			abilityColoring = false;
			abilitySchoolColoring = false;
			abilityActorColoring = false;
			amountActorColoring = false;
			amountColoring = false;
			amountSchoolColoring = false;
			schoolNameColoring = false;
			noMeleeSwingColoring = false;
			braces = true;
			unitBraces = true;
			sourceBraces = true;
			destBraces = true;
			spellBraces = false;
			itemBraces = true;
			showHistory = true;
			hideBuffs = true;
			hideDebuffs = true;
			lineColorPriority = 1; -- 1 = source->dest->event, 2 = dest->source->event, 3 = event->source->dest
			unitIcons = true;
			--unitTokens = true;
		};
	};
	-- All of the filters
	filters = {
		[1] = {
			-- Descriptive Information
			name = "Default";
			hasQuickButton = true;
			quickButtonName = "Default";
			quickButtonDisplay = {
				solo = true;
				party = true;
				raid = true;
			};

			-- Default Color and Formatting Options
			settings = COMBATLOG_DEFAULT_SETTINGS;

			-- Coloring
			colors = COMBATLOG_DEFAULT_COLORS;

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
					      ["SPELL_CAST_FAILED"] = true,
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
					      ["SPELL_AURA_DISPELLED"] = true,
					      ["SPELL_AURA_STOLEN"] = true,
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
					sourceFlags = bit.bor( COMBATLOG_FILTER_MINE, COMBATLOG_FILTER_MY_PET);
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
					      ["SPELL_AURA_DISPELLED"] = true,
					      ["SPELL_AURA_STOLEN"] = true,
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
					destFlags = bit.bor( COMBATLOG_FILTER_MINE, COMBATLOG_FILTER_MY_PET);
				};
			};
		};
		[2] = {
			-- Descriptive Information
			name = "Everything";
			hasQuickButton = true;
			quickButtonName = "Everything";
			quickButtonDisplay = {
				solo = true;
				party = true;
				raid = true;
			};

			-- Settings
			settings = {
				fullText = false;
				textMode = TEXT_MODE_A;
				timestamp = true;
				timestampFormat = TEXT_MODE_A_TIMESTAMP;
				unitColoring = false;
				sourceColoring = true;
				destColoring = true;
				lineColoring = true;
				abilityColoring = false;
				abilitySchoolColoring = false;
				abilityActorColoring = false;
				amountActorColoring = false;
				amountColoring = false;
				amountSchoolColoring = false;
				schoolNameColoring = false;
				noMeleeSwingColoring = false;
				braces = true;
				unitBraces = true;
				sourceBraces = true;
				destBraces = true;
				spellBraces = false;
				itemBraces = true;
				showHistory = true;
				lineColorPriority = 1; -- 1 = source->dest->event, 2 = dest->source->event, 3 = event->source->dest
				unitIcons = true;
				--unitTokens = true;
			};

			-- Coloring
			colors = COMBATLOG_DEFAULT_COLORS;

			-- The actual client filters
			filters = {
				[1] = {
					eventList = Blizzard_CombatLog_GenerateFullEventList();
					sourceFlags = nil;
					destFlags = nil;
				};
			};
		};
		[3] = {
			-- Descriptive Information
			name = "Me";
			hasQuickButton = true;
			quickButtonName = "Me";
			quickButtonDisplay = {
				solo = true;
				party = true;
				raid = true;
			};

			-- Settings
			settings = {
				fullText = false;
				textMode = TEXT_MODE_A;
				timestamp = true;
				timestampFormat = TEXT_MODE_A_TIMESTAMP;
				unitColoring = true;
				sourceColoring = true;
				destColoring = true;
				lineColoring = false;
				abilityColoring = true;
				abilitySchoolColoring = false;
				abilityActorColoring = false;
				amountActorColoring = false;
				amountColoring = true;
				amountSchoolColoring = true;
				schoolNameColoring = true;
				noMeleeSwingColoring = false;
				braces = true;
				unitBraces = true;
				sourceBraces = true;
				destBraces = true;
				spellBraces = false;
				itemBraces = true;
				showHistory = true;
				lineColorPriority = 1; -- 1 = source->dest->event, 2 = dest->source->event, 3 = event->source->dest
				unitIcons = true;
				--unitTokens = true;
			};

			-- Coloring
			colors = COMBATLOG_DEFAULT_COLORS;

			-- The actual client filters
			filters = {
				[1] = {
					eventList = Blizzard_CombatLog_GenerateFullEventList();
					sourceFlags = bit.bor( COMBATLOG_FILTER_MINE, COMBATLOG_FILTER_MY_PET);
					destFlags = nil;
				};
				[2] = {
					eventList = Blizzard_CombatLog_GenerateFullEventList();
					sourceFlags = nil;
					destFlags = bit.bor( COMBATLOG_FILTER_MINE, COMBATLOG_FILTER_MY_PET);
				};
			};
		};
		[4] = {
			-- Descriptive Information
			name = "Friends";
			hasQuickButton = true;
			quickButtonName = "Friends";
			quickButtonDisplay = {
				solo = true;
				party = true;
				raid = true;
			};

			-- Settings
			settings = {
				fullText = false;
				textMode = TEXT_MODE_A;
				timestamp = true;
				timestampFormat = TEXT_MODE_A_TIMESTAMP;
				unitColoring = false;
				sourceColoring = true;
				destColoring = true;
				lineColoring = true;
				abilityColoring = false;
				abilitySchoolColoring = false;
				abilityActorColoring = false;
				amountActorColoring = false;
				amountColoring = false;
				amountSchoolColoring = false;
				schoolNameColoring = false;
				noMeleeSwingColoring = false;
				braces = true;
				unitBraces = true;
				sourceBraces = true;
				destBraces = true;
				spellBraces = false;
				itemBraces = true;
				showHistory = true;
				lineColorPriority = 1; -- 1 = source->dest->event, 2 = dest->source->event, 3 = event->source->dest
				unitIcons = true;
				--unitTokens = true;
			};

			-- Coloring
			colors = COMBATLOG_DEFAULT_COLORS;

			-- The actual client filters
			filters = {
				[1] = {
					eventList = Blizzard_CombatLog_GenerateFullEventList();
					sourceFlags = COMBATLOG_FILTER_FRIENDLY_UNITS;
					destFlags = nil;
				};
				[2] = {
					eventList = Blizzard_CombatLog_GenerateFullEventList();
					sourceFlags = nil;
					destFlags = COMBATLOG_FILTER_FRIENDLY_UNITS;
				};
			};
		};
		[5] = {
			-- Descriptive Information
			name = "Original";
			hasQuickButton = true;
			quickButtonName = "Original";
			quickButtonDisplay = {
				solo = true;
				party = true;
				raid = true;
			};

			-- Settings
			settings = {
				fullText = true;
				textMode = TEXT_MODE_A;
				timestamp = false;
				timestampFormat = TEXT_MODE_A_TIMESTAMP;
				unitColoring = false;
				sourceColoring = true;
				destColoring = true;
				lineColoring = true;
				abilityColoring = false;
				abilitySchoolColoring = false;
				abilityActorColoring = false;
				amountActorColoring = false;
				amountColoring = false;
				amountSchoolColoring = false;
				schoolNameColoring = false;
				noMeleeSwingColoring = false;
				braces = false;
				unitBraces = false;
				sourceBraces = false;
				destBraces = true;
				spellBraces = false;
				itemBraces = true;
				showHistory = true;
				lineColorPriority = 1; -- 1 = source->dest->event, 2 = dest->source->event, 3 = event->source->dest
				unitIcons = true;
				--unitTokens = true;
			};

			-- Coloring
			colors = COMBATLOG_DEFAULT_COLORS;

			-- The actual client filters
			filters = {
				[1] = {
					eventList = Blizzard_CombatLog_GenerateFullEventList();
					sourceFlags = nil;
					destFlags = nil;
				};
				[2] = {
					eventList = Blizzard_CombatLog_GenerateFullEventList();
					sourceFlags = nil;
					destFlags = nil;
				};
			};
		};
	};

	-- Current Filter
	currentFilter = 1;
};

--
-- Temporary Settings
--
Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_Filters.filters[1];
Blizzard_CombatLog_PreviousSettings = Blizzard_CombatLog_CurrentSettings;
Blizzard_CombatLog_UnitTokens = {};

--[[
--	Converts 4 floats into FF code
--
--]]
function CombatLog_Color_FloatToText(r,g,b,a)
	if ( type (r) == "table" and r.r and r.g and r.b ) then
		r, g, b, a = r.r, r.g, r.b, r.a;
	end
	if ( not a ) then a = 1.0; end
		
	if ( r > 1 ) then r = 1.0; end;
	if ( g > 1 ) then g = 1.0; end;
	if ( b > 1 ) then b = 1.0; end;
	if ( a > 1 ) then a = 1.0; end;
	local newR, newG, newB, newA = math.floor(r * 255), math.floor(g * 255), math.floor(b * 255), math.floor(a * 255)
	local fmt = "%.2x";

	return string.format(fmt, newA )..string.format(fmt, newR )..string.format(fmt, newG )..string.format(fmt, newB );
end

--[[
--
--	Checks if the unit is any of types passed to the function
--
--	args:
--		unitFlags - the unit flags in question
--		
--]]
function CombatLog_Object_IsA(unitFlags,  ... )
	for k, flagType in pairs( {...} ) do 
		if (
			(
			bit.band( bit.band ( unitFlags, flagType ), COMBATLOG_OBJECT_AFFILIATION_MASK ) > 0 and
			bit.band( bit.band ( unitFlags, flagType ), COMBATLOG_OBJECT_REACTION_MASK ) > 0 and
			bit.band( bit.band ( unitFlags, flagType ), COMBATLOG_OBJECT_CONTROL_MASK ) > 0 and
			bit.band( bit.band ( unitFlags, flagType ), COMBATLOG_OBJECT_TYPE_MASK ) > 0
			)
			or
			bit.band( bit.band ( unitFlags, flagType ), COMBATLOG_OBJECT_SPECIAL_MASK ) > 0
		) then
			return true
		end
	end

	return false;
end

--[[
--
--	Checks if the unit is all of types passed to the function
--
--	args:
--		unitFlags - the unit flags in question
--		
--]]
function CombatLog_Object_IsAll(unitFlags, ...) 
	local compoundType = bit.bor( select( 1, ... ) );
	if ( bit.band( unitFlags, compoundType ) == compoundType ) then
		return true;
	end

	return false;
end

--
--	Gets the appropriate color for an event type
--
function CombatLog_Color_ColorArrayByEventType( event )
	local array = nil;

	for mask,colorArray in pairs( Blizzard_CombatLog_CurrentSettings.colors.eventColoring ) do
		if ( mask == event )then
			array = colorArray;
			break;
		end
	end
	
	if (not array) then
		return {a=1.0,r=0.5,g=0.5,b=0.5};
	end
	return array;
end

--
--	Gets the appropriate color for a unit type
--
function CombatLog_Color_ColorArrayByUnitType(unitFlags)
	local array = nil;

	for mask,colorArray in pairs( Blizzard_CombatLog_CurrentSettings.colors.unitColoring ) do
		if ( CombatLog_Object_IsA (unitFlags, mask) )then
			array = colorArray;
			break;
		end
	end
	
	if (not array) then
		return {a=1.0,r=0.5,g=0.5,b=0.5};
	end
	return array;
end

--
--	Gets the appropriate color for a  spell school
--
function CombatLog_Color_ColorArrayBySchool(school)
	if ( not school ) then
		return Blizzard_CombatLog_CurrentSettings.colors.schoolColoring.default;
	end

	-- Look for a color matching
	if ( Blizzard_CombatLog_CurrentSettings.colors.schoolColoring[school]  )then
		return Blizzard_CombatLog_CurrentSettings.colors.schoolColoring[school];
	end

	-- Fallback to grey for bugs and stuff
	return {a=1.0,r=0.5,g=0.5,b=0.5};
end

--
--	Gets the appropriate color for a  spell school
--
function CombatLog_Color_HighlightColorArray(colorArray)
	local r = colorArray.r * COMBATLOG_HIGHLIGHT_MULTIPLIER;
	local g = colorArray.g * COMBATLOG_HIGHLIGHT_MULTIPLIER;
	local b = colorArray.b * COMBATLOG_HIGHLIGHT_MULTIPLIER;
	local a = colorArray.a;

	return {a=a,r=r,g=g,b=b};
end

--
-- Returns a string associated with a numeric power type
--
function CombatLog_String_PowerType(powerType)
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

SCHOOL_STRINGS = {};
SCHOOL_STRINGS[1] = STRING_SCHOOL_PHYSICAL;
SCHOOL_STRINGS[2] = STRING_SCHOOL_HOLY;
SCHOOL_STRINGS[3] = STRING_SCHOOL_FIRE;
SCHOOL_STRINGS[4] = STRING_SCHOOL_NATURE;
SCHOOL_STRINGS[5] = STRING_SCHOOL_FROST;
SCHOOL_STRINGS[6] = STRING_SCHOOL_SHADOW;
SCHOOL_STRINGS[7] = STRING_SCHOOL_ARCANE;

function CombatLog_String_SchoolString(school)
	if ( not school or school == SCHOOL_MASK_NONE ) then
		return STRING_SCHOOL_UNKNOWN;
	end

	local schoolString;
	local mask = 1;
	for i = 1, 7 do
		if ( bit.band(school, mask) > 0 ) then
			if ( schoolString ) then
				schoolString = schoolString .. "+" .. SCHOOL_STRINGS[i];
			else
				schoolString = SCHOOL_STRINGS[i];
			end
		end
		mask = mask * 2;
	end
	return schoolString;
end

function CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, textMode, spellId )
	local resultStr;
	-- Result String formatting
	if ( resisted or blocked or absorbed or critical or glancing or crushing ) then
		resultStr = "";

		if ( resisted ) then
			resultStr = resultStr..getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT");
			resultStr = string.gsub(resultStr,"$resultString", getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT_FORMAT"));
			resultStr = string.gsub(resultStr,"$resultAmount", resisted);
			resultStr = string.gsub(resultStr,"$resultType", getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT_RESISTED"));
		end
		if ( blocked ) then
			resultStr = resultStr..getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT");
			resultStr = string.gsub(resultStr,"$resultString", getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT_FORMAT"));
			resultStr = string.gsub(resultStr,"$resultAmount", blocked);
			resultStr = string.gsub(resultStr,"$resultType", getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT_BLOCKED"));
		end
		if ( absorbed ) then
			resultStr = resultStr..getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT");
			resultStr = string.gsub(resultStr,"$resultString", getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT_FORMAT"));
			resultStr = string.gsub(resultStr,"$resultAmount", absorbed);
			resultStr = string.gsub(resultStr,"$resultType", getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT_ABSORBED"));
		end
		if ( glancing ) then
			resultStr = resultStr..getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT");
			resultStr = string.gsub(resultStr,"$resultString", getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT_GLANCING"));
		end
		if ( crushing ) then
			resultStr = resultStr..getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT");
			resultStr = string.gsub(resultStr,"$resultString", getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT_CRUSHING"));
		end
		if ( critical ) then
			resultStr = resultStr..getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT");
			if ( spellId ) then
				resultStr = string.gsub(resultStr,"$resultString", getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT_CRITICAL_SPELL"));
			else
				resultStr = string.gsub(resultStr,"$resultString", getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT_CRITICAL"));
			end
		end
	end

	return resultStr;
end

--
-- Get the appropriate raid icon for a unit
--
function CombatLog_String_GetIcon ( unitFlags, direction )
	local iconString = TEXT_MODE_A_STRING_TOKEN_ICON;
	local icon = nil;
	local iconBit = 0;

	-- Check for an appropriate icon for this unit
	if (  CombatLog_Object_IsA(unitFlags, COMBATLOG_OBJECT_RAIDTARGET1) ) then
		icon = COMBATLOG_ICON_RAIDTARGET1;
		iconBit = COMBATLOG_OBJECT_RAIDTARGET1;
	elseif (  CombatLog_Object_IsA(unitFlags, COMBATLOG_OBJECT_RAIDTARGET2) ) then
		icon = COMBATLOG_ICON_RAIDTARGET2;
		iconBit = COMBATLOG_OBJECT_RAIDTARGET2;
	elseif (  CombatLog_Object_IsA(unitFlags, COMBATLOG_OBJECT_RAIDTARGET3) ) then
		icon = COMBATLOG_ICON_RAIDTARGET3;
		iconBit = COMBATLOG_OBJECT_RAIDTARGET3;
	elseif (  CombatLog_Object_IsA(unitFlags, COMBATLOG_OBJECT_RAIDTARGET4) ) then
		icon = COMBATLOG_ICON_RAIDTARGET4;
		iconBit = COMBATLOG_OBJECT_RAIDTARGET4;
	elseif (  CombatLog_Object_IsA(unitFlags, COMBATLOG_OBJECT_RAIDTARGET5) ) then
		icon = COMBATLOG_ICON_RAIDTARGET5;
		iconBit = COMBATLOG_OBJECT_RAIDTARGET5;
	elseif (  CombatLog_Object_IsA(unitFlags, COMBATLOG_OBJECT_RAIDTARGET6) ) then
		icon = COMBATLOG_ICON_RAIDTARGET6;
		iconBit = COMBATLOG_OBJECT_RAIDTARGET6;
	elseif (  CombatLog_Object_IsA(unitFlags, COMBATLOG_OBJECT_RAIDTARGET7) ) then
		icon = COMBATLOG_ICON_RAIDTARGET7;
		iconBit = COMBATLOG_OBJECT_RAIDTARGET7;
	elseif (  CombatLog_Object_IsA(unitFlags, COMBATLOG_OBJECT_RAIDTARGET8) ) then
		icon = COMBATLOG_ICON_RAIDTARGET8;
		iconBit = COMBATLOG_OBJECT_RAIDTARGET8;
	end

	-- Create a possible bit field
	if ( iconBit > 0 ) then
		iconBit = iconBit;
	end

	-- Insert the Raid Icon if it exists
	if ( icon ) then
		--
		-- Insert a hyperlink for that icon

		if ( direction == "source" ) then
			iconString = string.gsub ( iconString, "$icon", TEXT_MODE_A_STRING_SOURCE_ICON);
		else 
			iconString = string.gsub ( iconString, "$icon", TEXT_MODE_A_STRING_DEST_ICON );
		end

		iconString = string.gsub ( iconString, "$iconTexture", icon);
		iconString = string.gsub ( iconString, "$iconBit", iconBit);

		-- ### Hacky. Revise later
		local name, fontSize, r, g, b, a, shown, locked = GetChatWindowInfo(COMBATLOG:GetID());
		if ( fontSize == 0 ) then
			fontSize = 14;
		end

		iconString = string.gsub ( iconString, "$size", fontSize );
	-- Otherwise remove the token
	else
		iconString = "";
	end

	return iconString;
end

--
--	Obtains the appropriate unit token for a GUID
--
function CombatLog_String_GetToken (unitGUID, unitName, unitFlags)
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
		newName = string.gsub ( newName, "$token", Blizzard_CombatLog_UnitTokens[unitGUID] );
		newName = string.gsub ( newName, "$unitName", unitName );
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

			newName = string.gsub ( newName, "$token", Blizzard_CombatLog_UnitTokens[unitGUID] );
			newName = string.gsub ( newName, "$unitName", unitName );
		end
	end
	]]

	-- Shortcut since the above block is commented out.
	newName = unitName;

	return newName;
end

--
--	Gets the appropriate color for a unit type
--
--
function CombatLog_Color_ColorStringByUnitType(unitFlags)
	local colorArray = CombatLog_Color_ColorArrayByUnitType(unitFlags);

	return  CombatLog_Color_FloatToText(colorArray.r, colorArray.g, colorArray.b, colorArray.a )
end


--[[
--	Gets the appropriate color for a school
--
--]]
function CombatLog_Color_ColorStringBySchool(school)
	local colorArray = CombatLog_Color_ColorArrayBySchool(school);

	return  CombatLog_Color_FloatToText(colorArray.r, colorArray.g, colorArray.b, colorArray.a )
end

--
--	Gets the appropriate color for an event type
--
--
function CombatLog_Color_ColorStringByEventType(unitFlags)
	local colorArray = CombatLog_Color_ColorArrayByEventType(unitFlags);

	return  CombatLog_Color_FloatToText(colorArray.r, colorArray.g, colorArray.b, colorArray.a )
end



--[[
--	Handles events and dumps them to the specified frame. 
--]]
function CombatLog_OnEvent(frame, timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, ...)
	-- [environmentalDamageType]
	-- [spellName, spellRank, spellSchool]
	-- [damage, school, [resisted, blocked, absorbed, crit, glancing, crushing]]

	local lineColor = { a = 1.00, r = 1.00, g = 1.00, b = 1.00 };
	local sourceColor, destColor = nil, nil;

	local braceColor = "FFFFFFFF";
	local abilityColor = "FFFFFF00";

	-- Processing variables
	local textMode = Blizzard_CombatLog_CurrentSettings.settings.textMode;
	local timestampEnabled = Blizzard_CombatLog_CurrentSettings.settings.timestamp;
	local hideBuffs = Blizzard_CombatLog_CurrentSettings.settings.hideBuffs;
	local hideDebuffs = Blizzard_CombatLog_CurrentSettings.settings.hideDebuffs;
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
	combatString = getglobal("TEXT_MODE_"..textMode.."_STRING_1");

	-- Support for multiple string orders
	if ( getglobal("ACTION_"..event.."_MASTER") ) then
		local newCombatString = getglobal("TEXT_MODE_"..textMode.."_STRING_"..getglobal("ACTION_"..event.."_MASTER") );
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

	-- Swings
	if ( strsub(event, 1, 5) == "SWING" ) then
		spellName = ACTION_SWING;
		nameIsNotSpell = true;
	end
	-- Break out the arguments into variable
	if ( event == "SWING_DAMAGE" ) then 
		-- Damage standard
		amount, school, resisted, blocked, absorbed, critical, glancing, crushing = select(1, ...);


		-- Parse the result string
		resultStr = CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, textMode, spellId );

		if ( not resultStr ) then
			resultEnabled = false
		end

	elseif ( event == "SWING_MISSED" ) then 
		spellName = ACTION_SWING;

		-- Damage standard
		missType = select(1, ...);

		-- Result String
		resultStr = getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT");
		resultStr = string.gsub(resultStr,"$resultString", getglobal("ACTION_"..event.."_"..missType));
		
		-- Miss Type
		if ( Blizzard_CombatLog_CurrentSettings.settings.fullText ) then
			event = event.."_"..missType;
		end

		-- Disable appropriate sections
		nameIsNotSpell = true;
		valueEnabled = false;
		resultEnabled = true;
	end
	-- Shots
	if ( strsub(event, 1, 5) == "RANGE" ) then
		--spellName = ACTION_RANGED;
		--nameIsNotSpell = true;

		-- Shots are spells, technically
		spellId, spellName, spellSchool = select(1, ...);
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
			resultStr = getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT");
			resultStr = string.gsub(resultStr,"$resultString", getglobal("ACTION_"..event.."_"..missType));
			
			-- Miss Type
			if ( Blizzard_CombatLog_CurrentSettings.settings.fullText ) then
				event = event.."_"..missType;
			end

			-- Disable appropriate sections
			valueEnabled = false;
			resultEnabled = true;
		end
	end
	-- Spell standard arguments
	if ( strsub(event, 1, 5) == "SPELL" ) then
		spellId, spellName, spellSchool = select(1, ...);

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
			resultStr = getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT");
			resultStr = string.gsub(resultStr,"$resultString", getglobal("ACTION_"..event.."_"..missType));

			-- Miss Event
			if ( Blizzard_CombatLog_CurrentSettings.settings.fullText ) then
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
				resultStr = getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT");
				resultStr = string.gsub(resultStr,"$resultString", getglobal("ACTION_"..event.."_"..missType));

				-- Miss Event
				if ( Blizzard_CombatLog_CurrentSettings.settings.fullText ) then
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
				--resultStr = getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT");
				--resultStr = string.gsub(resultStr,"$resultString", getglobal("ACTION_"..event.."_RESULT")); 

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
				resultStr = getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT");
				resultStr = string.gsub(resultStr,"$resultString", getglobal("ACTION_"..event.."_RESULT")); 

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
				--resultStr = getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT");
				--resultStr = string.gsub(resultStr,"$resultString", getglobal("ACTION_"..event.."_RESULT")); 

				if ( not resultStr ) then
					resultEnabled = false
				end

				-- Disable appropriate sections
				valueEnabled = true;
				valueTypeEnabled = true;				
			end
		end
		-- Special Spell effects
		if ( event == "SPELL_DRAIN" ) then
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
		end
		if ( event == "SPELL_LEECH" ) then
			-- Special attacks
			amount, powerType, extraAmount = select(4, ...);

			-- Set value type to be a power type
			valueType = 2;

			-- Result String
			resultStr = getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT");
			if ( resultStr ) then
				resultStr = string.gsub(resultStr,"$resultString", getglobal("ACTION_"..event.."_RESULT")); 
			end

			-- Disable appropriate sections
			if ( not resultStr ) then
				resultEnabled = false;
			end
			valueEnabled = true;
			schoolEnabled = false;
		end
		if ( event == "SPELL_INTERRUPT" ) then
			-- Spell interrupted
			extraSpellId, extraSpellName, extraSpellSchool = select(4, ...);

			-- Replace the value token with a spell token
			if ( extraSpellId ) then
				extraSpellEnabled = true;
				combatString = string.gsub(combatString, "$value", "$extraSpell");
			end

			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
			valueTypeEnabled = false;
			schoolEnabled = false;

		end
		if ( event == "SPELL_EXTRA_ATTACKS" ) then
			-- Special attacks
			amount = select(4, ...);

			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = true;
			valueTypeEnabled = false;
			schoolEnabled = false;
		end

		if ( event == "SPELL_INSTAKILL" ) then
			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
			schoolEnabled = false;
		end
		if ( event == "SPELL_DURABILITY_DAMAGE" ) then
			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
			schoolEnabled = false;
		end
		if ( event == "SPELL_DURABILITY_DAMAGE_ALL" ) then
			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
			schoolEnabled = false;
		end
		if ( event == "SPELL_DISPEL_FAILED" ) then
			-- Extra Spell standard
			extraSpellId, extraSpellName, extraSpellSchool = select(4, ...);
			
			-- Replace the value token with a spell token
			if ( extraSpellId ) then
				extraSpellEnabled = true;
				combatString = string.gsub(combatString, "$value", "$extraSpell");
			end

			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
		end		
		if ( event == "SPELL_AURA_DISPELLED" ) then
			-- Extra Spell standard
			extraSpellId, extraSpellName, extraSpellSchool = select(4, ...);
			
			-- Aura standard
			auraType = select(7, ...);

			-- Event Type
			event = event.."_"..auraType;

			-- Replace the value token with a spell token
			if ( extraSpellId ) then
				extraSpellEnabled = true;
				combatString = string.gsub(combatString, "$value", "$extraSpell");
			end

			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
		end
		if ( event == "SPELL_AURA_STOLEN" ) then
			-- Extra Spell standard
			extraSpellId, extraSpellName, extraSpellSchool = select(4, ...);
			
			-- Aura standard
			auraType = select(7, ...);

			-- Event Type
			event = event.."_"..auraType;

			-- Replace the value token with a spell token
			if ( extraSpellId ) then
				extraSpellEnabled = true;
				combatString = string.gsub(combatString, "$value", "$extraSpell");
			end

			-- Disable appropriate sections
			resultEnabled = false;
			valueEnabled = false;
		end	

		-- Aura Events
		if ( event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REMOVED" ) then	
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
		end
		if ( event == "SPELL_AURA_APPLIED_DOSE" or event == "SPELL_AURA_REMOVED_DOSE" ) then
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

		-- Spellcast
		if ( event == "SPELL_CAST_START" ) then
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
			resultStr = getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT");
			resultStr = string.gsub(resultStr,"$resultString", missType);

			-- Disable appropriate sections
			valueEnabled = false;
			destEnabled = false;

			if ( not resultStr ) then
				resultEnabled = false;
			end
		end
	end
	--
	-- Damage Shields
	--
	if ( event == "DAMAGE_SHIELD" ) then
		-- Spell standard
		spellId, spellName, spellSchool = select(1, ...);

		-- Damage standard
		amount, school, resisted, blocked, absorbed, critical, glancing, crushing = select(4, ...);

		-- Parse the result string
		resultStr = CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, textMode, spellId );

		-- Disable appropriate sections
		if ( not resultStr ) then
			resultEnabled = false
		end

	end
	if ( event == "DAMAGE_SHIELD_MISSED" ) then 
		-- Spell standard
		spellId, spellName, spellSchool = select(1, ...);

		-- Miss type
		missType = select(4, ...);
		
		-- Result String
		resultStr = getglobal("TEXT_MODE_"..textMode.."_STRING_RESULT");
		resultStr = string.gsub(resultStr,"$resultString", getglobal("ACTION_"..event.."_"..missType));

		-- Miss Event
		if ( Blizzard_CombatLog_CurrentSettings.settings.fullText ) then
			event = event.."_"..missType;
		end

		-- Disable appropriate sections
		valueEnabled = false;
		if ( not resultStr ) then
			resultEnabled = false;
		end
	end

	-- Unique Events
	if ( event == "PARTY_KILL" ) then
		-- Disable appropriate sections
		resultEnabled = false;
		valueEnabled = false;
		spellEnabled = false;
	end

	if ( event == "ENCHANT_APPLIED" ) then
		-- Get the enchant name
		spellName = select(1,...);
		nameIsNotSpell = true;

		-- Get the item id and item name
		itemId, itemName = select(2,...);
		
		-- Replace the value token with an item token
		combatString = string.gsub(combatString, "$value", "$item");

		-- Disable appropriate sections
		itemEnabled = true;
		resultEnabled = false;
	end

	if ( event == "ENCHANT_REMOVED" ) then
		-- Get the enchant name
		spellName = select(1,...);
		nameIsNotSpell = true;

		-- Get the item id and item name
		itemId, itemName = select(2,...);
		
		-- Replace the value token with an item token
		combatString = string.gsub(combatString, "$value", "$item");

		-- Disable appropriate sections
		itemEnabled = true;
		resultEnabled = false;
		sourceEnabled = false;
	end

	if ( event == "UNIT_DIED" or event == "UNIT_DESTROYED" ) then
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
	end

	if ( event == "ENVIRONMENTAL_DAMAGE" ) then
		--Environemental Type
		environmentalType = select(1,...)

		-- Damage standard
		amount, school, resisted, blocked, absorbed, critical, glancing, crushing = select(2, ...);

		-- Miss Event
		spellName = getglobal("ACTION_"..event.."_"..environmentalType);
		spellSchool = school;
		nameIsNotSpell = true;

		-- Parse the result string
		resultStr = CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, textMode, spellId );

		-- Environmental Event
		if ( Blizzard_CombatLog_CurrentSettings.settings.fullText ) then
			event = event.."_"..environmentalType;
		end

		if ( not resultStr ) then
			resultEnabled = false;
		end
	end
	if ( event == "DAMAGE_SPLIT" ) then
		-- Spell Standard Arguments
		spellId, spellName, spellSchool = select(1, ...);
		-- Damage standard
		amount, school, resisted, blocked, absorbed, critical, glancing, crushing = select(4, ...);

		-- Parse the result string
		resultStr = CombatLog_String_DamageResultString( resisted, blocked, absorbed, critical, glancing, crushing, textMode, spellId );

		if ( not resultStr ) then
			resultEnabled = false
		end
	end

	-- Throw away all of the assembled strings and just grab a premade one
	if ( Blizzard_CombatLog_CurrentSettings.settings.fullText ) then
		local combatStringEvent = "ACTION_"..event.."_FULL_TEXT";

		-- Get the base string
		if ( getglobal(combatStringEvent) ) then
			combatString = getglobal(combatStringEvent);
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
		if ( getglobal(combatStringEvent) ) then
			combatString = getglobal(combatStringEvent);
		end
		-- Reapply the timestamp
		if (Blizzard_CombatLog_CurrentSettings.settings.timestamp ) then
			combatString = getglobal("TEXT_MODE_"..textMode.."_STRING_TIMESTAMP").." "..combatString;
		end

		sourceEnabled = true;
		destEnabled = true;
		spellEnabled = true;
		valueEnabled = true;
	end

	-- Remove Timestamp
	if ( not timestampEnabled ) then 
		combatString = string.gsub(combatString,"$timestamp","");
	else
		combatString = string.gsub(combatString,"$timestamp",getglobal("TEXT_MODE_"..textMode.."_STRING_TIMESTAMP"));
	end

	-- Remove Source
	if ( not sourceEnabled ) then 
		combatString = string.gsub(combatString,"$source","");
	else
		combatString = string.gsub(combatString,"$source",getglobal("TEXT_MODE_"..textMode.."_STRING_SOURCE"));
		combatString = string.gsub(combatString,"$sourceString",getglobal("TEXT_MODE_"..textMode.."_STRING_SOURCE_UNIT"));
	end

	-- Remove Dest
	if ( not destEnabled ) then 
		combatString = string.gsub(combatString,"$dest","");
	else
		combatString = string.gsub(combatString,"$dest",getglobal("TEXT_MODE_"..textMode.."_STRING_DEST"));
		combatString = string.gsub(combatString,"$destString",getglobal("TEXT_MODE_"..textMode.."_STRING_DEST_UNIT"));
	end

	-- Remove Spell
	if ( not spellEnabled ) then
		combatString = string.gsub(combatString,"$spell","");
	else
		if ( nameIsNotSpell ) then
			combatString = string.gsub(combatString,"$spell", string.gsub(TEXT_MODE_A_STRING_ACTION, "$action", "$spellName"));
			--combatString = string.gsub(combatString,"$spell","$spellName");
		else
			combatString = string.gsub(combatString,"$spell",getglobal("TEXT_MODE_"..textMode.."_STRING_SPELL"));
--			combatString = string.gsub(combatString,"$spell",GetSpellLink(spellId));
		end
	end

	-- Remove Extra Spell
	if ( not extraSpellEnabled ) then
		combatString = string.gsub(combatString,"$extraSpell","");
	else
		if ( extraNameIsNotSpell ) then
			combatString = string.gsub(combatString,"$extraSpell","$extraSpellName");
		else
			combatString = string.gsub(combatString,"$extraSpell",getglobal("TEXT_MODE_"..textMode.."_STRING_SPELL_EXTRA"));
		end
	end

	-- Remove Action
	if ( not actionEnabled ) then 
		combatString = string.gsub(combatString,"$action","");
	else
		combatString = string.gsub(combatString,"$action",getglobal("TEXT_MODE_"..textMode.."_STRING_ACTION"));
	end

	-- Remove Value
	if ( not itemEnabled ) then 
		combatString = string.gsub(combatString,"$item","");
	else
		combatString = string.gsub(combatString,"$item",getglobal("TEXT_MODE_"..textMode.."_STRING_ITEM"));
	end

	-- Remove Value
	if ( not valueEnabled ) then 
		combatString = string.gsub(combatString,"$value","");
	else
		combatString = string.gsub(combatString,"$value",getglobal("TEXT_MODE_"..textMode.."_STRING_VALUE"));
	end

	-- Remove type
	if ( not valueTypeEnabled ) then 
		combatString = string.gsub(combatString,"$amountType","");
	else
		-- School Type
		if ( valueType == 1 ) then 
			combatString = string.gsub(combatString,"$amountType",getglobal("TEXT_MODE_"..textMode.."_STRING_VALUE_SCHOOL"));
		-- Power Type
		elseif ( valueType == 2 ) then
			combatString = string.gsub(combatString,"$amountType",getglobal("TEXT_MODE_"..textMode.."_STRING_VALUE_TYPE"));
		end
	end

	-- Remove Result
	if ( not resultEnabled ) then 
		combatString = string.gsub(combatString,"$result","");
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
	actionStr = getglobal("ACTION_"..actionStr);

	-- DEBUG!!!!!!
	-- If this ever succeeds, the event string is missing. 
	--
	if ( not actionStr ) then 
		actionStr = event;
	end

	-- Initialize the strings now
	sourceNameStr, destNameStr = sourceName, destName


	-- Special changes for localization when not in full text mode
	if ( not Blizzard_CombatLog_CurrentSettings.settings.fullText ) then
		-- Replace your name with "You";
		if ( sourceName and CombatLog_Object_IsA(sourceFlags, COMBATLOG_FILTER_MINE) ) then
			sourceNameStr = UNIT_YOU;
		end
		if ( destName and CombatLog_Object_IsA(destFlags, COMBATLOG_FILTER_MINE) ) then
			destNameStr = UNIT_YOU;
		end
		
		-- Apply the possessive form to the source
		if ( sourceName 
			and ( string.sub( event, 1, 10 ) ~= "SPELL_CAST" and event ~= "SPELL_EXTRA_ATTACKS" )
			and ( 
			    event == "SWING_DAMAGE" or 
			    event == "SWING_MISSED" or 
			    event == "RANGE_DAMAGE" or 
			    event == "RANGE_MISSED" or spellName ) 
			    ) then
			if ( sourceName and CombatLog_Object_IsA(sourceFlags, COMBATLOG_FILTER_MINE) ) then
				sourceNameStr = UNIT_YOU_SOURCE;
			end
		end
		-- Apply the possessive form to the source
		if ( destName and ( extraSpellName or itemName ) ) then
			if ( destName and CombatLog_Object_IsA(destFlags, COMBATLOG_FILTER_MINE) ) then
				destNameStr = UNIT_YOU_DEST;
			end
		end

	-- If its full text mode
	else
		
		-- Apply the possessive form to the source
		if ( sourceName 
			and ( string.sub( event, 1, 10 ) ~= "SPELL_CAST" and event ~= "SPELL_EXTRA_ATTACKS" )
			and ( 
			    event == "SWING_DAMAGE" or 
			    event == "SWING_MISSED" or 
			    event == "RANGE_DAMAGE" or 
			    event == "RANGE_MISSED" or spellName ) 
			    ) then
			sourceNameStr = string.gsub ( TEXT_MODE_A_STRING_POSSESSIVE, "$nameString", sourceNameStr );
			sourceNameStr = string.gsub ( sourceNameStr, "$possessive", TEXT_MODE_A_STRING_POSSESSIVE_STRING );
		end

		-- Apply the possessive form to the dest if the dest has a spell
		if ( extraSpellName and destName ) then
			destNameStr = string.gsub ( TEXT_MODE_A_STRING_POSSESSIVE, "$nameString", destNameStr );
			destNameStr = string.gsub ( destNameStr, "$possessive", TEXT_MODE_A_STRING_POSSESSIVE_STRING );
		end
	end

	-- Unit Tokens
	if ( Blizzard_CombatLog_CurrentSettings.settings.unitTokens ) then
		-- Apply the possessive form to the source
		if ( sourceName ) then
			sourceName = CombatLog_String_GetToken(sourceGUID, sourceName, sourceFlags);
		end
		if ( destName ) then
			destName = CombatLog_String_GetToken(destGUID, destName, destFlags);
		end
	end
	
	-- Unit Icons
	if ( Blizzard_CombatLog_CurrentSettings.settings.unitIcons ) then
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
	if ( Blizzard_CombatLog_CurrentSettings.settings.lineColoring ) then
		if ( lineColorPriority == 3 or ( not sourceName and not destName) ) then
			lineColor = CombatLog_Color_ColorArrayByEventType( event );
		else
			if ( ( lineColorPriority == 1 and sourceName ) or not destName ) then
				lineColor = CombatLog_Color_ColorArrayByUnitType( sourceFlags );
			elseif ( ( lineColorPriority == 2 and destName ) or not sourceName ) then
				lineColor = CombatLog_Color_ColorArrayByUnitType( destFlags );
			else
				lineColor = CombatLog_Color_ColorArrayByUnitType( sourceFlags );
			end
		end
	end

	-- Only replace if there's an amount
	if ( amount ) then
		local amountColor;

		-- Color amount numbers
		if ( Blizzard_CombatLog_CurrentSettings.settings.amountColoring ) then
			-- To make white swings white
			if ( Blizzard_CombatLog_CurrentSettings.settings.noMeleeSwingColoring and school == SCHOOL_MASK_PHYSICAL and not spellId )  then
				-- Do nothing
			elseif ( Blizzard_CombatLog_CurrentSettings.settings.amountActorColoring ) then
				if ( sourceName ) then
					amountColor = CombatLog_Color_ColorArrayByUnitType( sourceFlags );
				elseif ( destName ) then
					amountColor = CombatLog_Color_ColorArrayByUnitType( destFlags );
				end
			elseif ( Blizzard_CombatLog_CurrentSettings.settings.amountSchoolColoring ) then
				amountColor = CombatLog_Color_ColorArrayBySchool(school);
			else
				if ( school ) then 
					amountColor = CombatLog_Color_ColorArrayBySchool(SCHOOL_MASK_NONE);
				else
					amountColor = CombatLog_Color_ColorArrayBySchool(nil);					
				end
			end

		end
		-- Highlighting
		if ( Blizzard_CombatLog_CurrentSettings.settings.amountHighlighting ) then
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
		if ( Blizzard_CombatLog_CurrentSettings.settings.schoolNameColoring ) then
			if ( Blizzard_CombatLog_CurrentSettings.settings.noMeleeSwingColoring and school == 0 and not spellId )  then
			else
				if ( Blizzard_CombatLog_CurrentSettings.settings.schoolNameActorColoring ) then
					if ( sourceName ) then
						schoolNameColor = CombatLog_Color_ColorArrayByUnitType( sourceFlags );
					elseif ( destName ) then
						schoolNameColor = CombatLog_Color_ColorArrayByUnitType( destFlags );
					end
				elseif ( Blizzard_CombatLog_CurrentSettings.settings.schoolNameActorColoring ) then
					schoolNameColor = CombatLog_Color_ColorArrayBySchool(school);
				end
			end
		end
		-- Highlighting
		if ( Blizzard_CombatLog_CurrentSettings.settings.schoolNameHighlighting ) then
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
		combatString = string.gsub(combatString, "$result", resultStr);
	end

	-- Color source names
	if ( Blizzard_CombatLog_CurrentSettings.settings.unitColoring ) then 
		if ( sourceName and Blizzard_CombatLog_CurrentSettings.settings.sourceColoring ) then
			sourceNameStr = "|c"..sourceColor..sourceNameStr.."|r";
		end
		if ( destName and Blizzard_CombatLog_CurrentSettings.settings.destColoring ) then
			destNameStr = "|c"..destColor..destNameStr.."|r";
		end
	end

	-- If there's an action (always)
	if ( actionStr ) then
		local actionColor = nil;
		-- Color ability names
		if ( Blizzard_CombatLog_CurrentSettings.settings.actionColoring ) then

			if ( Blizzard_CombatLog_CurrentSettings.settings.actionActorColoring ) then
				if ( sourceName ) then
					actionColor = CombatLog_Color_ColorArrayByUnitType( sourceFlags );
				elseif ( destName ) then
					actionColor = CombatLog_Color_ColorArrayByUnitType( destFlags );
				end
			elseif ( Blizzard_CombatLog_CurrentSettings.settings.actionSchoolColoring and spellSchool ) then
				actionColor = CombatLog_Color_ColorArrayBySchool(spellSchool);
			else
				actionColor = CombatLog_Color_ColorArrayByEventType(event);
			end
		-- Special option to only color "Miss" if there's no damage
		elseif ( Blizzard_CombatLog_CurrentSettings.settings.missColoring ) then

			if ( event ~= "SWING_DAMAGE" and
				event ~= "RANGE_DAMAGE" and
				event ~= "SPELL_DAMAGE" and
				event ~= "SPELL_PERIODIC_DAMAGE" ) then

				local actionColor = nil;

				if ( Blizzard_CombatLog_CurrentSettings.settings.actionActorColoring ) then
					actionColor = CombatLog_Color_ColorArrayByUnitType( sourceFlags );
				elseif ( Blizzard_CombatLog_CurrentSettings.settings.actionSchoolColoring ) then
					actionColor = CombatLog_Color_ColorArrayBySchool(spellSchool);
				else
					actionColor = CombatLog_Color_ColorArrayByEventType(event);
				end

			end
		end

		-- Highlighting
		if ( Blizzard_CombatLog_CurrentSettings.settings.actionHighlighting ) then
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
		if ( Blizzard_CombatLog_CurrentSettings.settings.abilityColoring ) then
			if ( Blizzard_CombatLog_CurrentSettings.settings.abilityActorColoring ) then
				abilityColor = CombatLog_Color_ColorArrayByUnitType( sourceFlags );
			elseif ( Blizzard_CombatLog_CurrentSettings.settings.abilitySchoolColoring ) then
				abilityColor = CombatLog_Color_ColorArrayBySchool(spellSchool);
			end

			if ( not abilityColor ) then
				if ( spellSchool ) then 
					abilityColor = CombatLog_Color_ColorArrayBySchool(SCHOOL_MASK_PHYSICAL);
				else
					abilityColor = CombatLog_Color_ColorArrayBySchool(nil);					
				end
			end
		end

		-- Highlight this color
		if ( Blizzard_CombatLog_CurrentSettings.settings.abilityHighlighting ) then
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
		if ( Blizzard_CombatLog_CurrentSettings.settings.abilityColoring ) then

			if ( Blizzard_CombatLog_CurrentSettings.settings.abilitySchoolColoring ) then
				abilityColor = CombatLog_Color_ColorArrayBySchool(extraSpellSchool);
			else
				if ( extraSpellSchool ) then 
					abilityColor = CombatLog_Color_ColorArrayBySchool(SCHOOL_MASK_HOLY);
				else
					abilityColor = CombatLog_Color_ColorArrayBySchool(nil);					
				end
			end
		end
		-- Highlight this color
		if ( Blizzard_CombatLog_CurrentSettings.settings.abilityHighlighting ) then
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
	if ( Blizzard_CombatLog_CurrentSettings.settings.lineHighlighting ) then
		if ( Blizzard_CombatLog_CurrentSettings.colors.highlightedEvents[event] ) then
			lineColor = CombatLog_Color_HighlightColorArray (lineColor);
		end
	end

	-- Build braces
	if ( Blizzard_CombatLog_CurrentSettings.settings.braces ) then
		-- Unit specific braces
		if ( Blizzard_CombatLog_CurrentSettings.settings.unitBraces ) then
			if ( sourceName and Blizzard_CombatLog_CurrentSettings.settings.sourceBraces ) then
				sourceNameStr = string.gsub(getglobal("TEXT_MODE_"..textMode.."_STRING_BRACE_UNIT"), "$unitName", sourceNameStr);
				sourceNameStr = string.gsub(sourceNameStr, "$braceColor", braceColor);
			end
	
			if ( destName and Blizzard_CombatLog_CurrentSettings.settings.destBraces ) then
				destNameStr = string.gsub(getglobal("TEXT_MODE_"..textMode.."_STRING_BRACE_UNIT"), "$unitName", destNameStr);
				destNameStr = string.gsub(destNameStr, "$braceColor", braceColor);
			end
		end

		-- Spell name braces
		if ( spellName and Blizzard_CombatLog_CurrentSettings.settings.spellBraces ) then 
			spellNameStr = string.gsub(getglobal("TEXT_MODE_"..textMode.."_STRING_BRACE_SPELL"), "$spellName", spellNameStr);
			--spellNameStr = string.gsub(spellNameStr, "$braceColor", braceColor);
		end
		if ( extraSpellName and Blizzard_CombatLog_CurrentSettings.settings.spellBraces ) then 
			extraSpellNameStr = string.gsub(getglobal("TEXT_MODE_"..textMode.."_STRING_BRACE_SPELL"), "$spellName", extraSpellNameStr);
			extraSpellNameStr = string.gsub(spellNameStr, "$braceColor", braceColor);
		end

		-- Build item braces
		if ( itemName and Blizzard_CombatLog_CurrentSettings.settings.itemBraces ) then
			itemNameStr = string.gsub(getglobal("TEXT_MODE_"..textMode.."_STRING_BRACE_ITEM"), "$itemName", itemNameStr);
			itemNameStr = string.gsub(itemNameStr, "$braceColor", braceColor);
		end
	end

	-- Dest Icons
	if ( sourceIcon ) then
		combatString = string.gsub(combatString, "$sourceIcon", sourceIcon);
	end
	if ( destIcon ) then
		combatString = string.gsub(combatString, "$destIcon", destIcon);
	end


	-- Unit Names
	if ( sourceName ) then
		combatString = string.gsub(combatString, "$sourceNameString", sourceNameStr);
		combatString = string.gsub(combatString, "$sourceName", sourceName);
		combatString = string.gsub(combatString, "$sourceGUID", sourceGUID);
	end
	if ( destName ) then 
		combatString = string.gsub(combatString, "$destNameString", destNameStr);
		combatString = string.gsub(combatString, "$destName", destName);
		combatString = string.gsub(combatString, "$destGUID", destGUID);
	end

	if ( amount ) then
		-- Replace the amount
		combatString = string.gsub(combatString, "$amount", amount );
	end
	if ( extraAmount ) then
		-- Replace the extra amount
		combatString = string.gsub(combatString, "$extraAmount", extraAmount );
	end

	-- Spell Stuff
	if ( spellName ) then
		combatString = string.gsub(combatString, "$spellName", spellNameStr);
	end
	if ( spellId ) then
		combatString = string.gsub(combatString, "$spellId", spellId);
	end
	if ( extraSpellName ) then
		combatString = string.gsub(combatString, "$extraSpellName", extraSpellNameStr);
	end
	if ( extraSpellId ) then
		combatString = string.gsub(combatString, "$extraSpellId", extraSpellId);
	end

	if ( itemName ) then
		-- Replace the spell information
		combatString = string.gsub(combatString, "$itemName", itemNameStr);
	end
	if ( itemId ) then
		combatString = string.gsub(combatString, "$itemId", itemId);
	end

	if ( schoolString ) then
		-- Replace the school name
		combatString = string.gsub(combatString, "$school", schoolString );
	end

	if ( powerTypeString ) then
		-- Replace the power type name
		combatString = string.gsub(combatString, "$powerType", powerTypeString );
	end

	if ( actionStr ) then
		-- Replace the action
		combatString = string.gsub(combatString, "$action", actionStr);
	end

	if ( timestamp ) then
		-- Replace the timestamp
		combatString = string.gsub(combatString, "$time", date(Blizzard_CombatLog_CurrentSettings.settings.timestampFormat, timestamp));
	end

	-- Replace the event
	combatString = string.gsub(combatString, "$eventType", originalEvent);

	-- Clean up formatting
	combatString = string.gsub(combatString, " [ ]+", " " ); -- extra white spaces
	combatString = string.gsub(combatString, " ([.,])", "%1" ); -- spaces before periods or comma
	combatString = string.gsub(combatString, "^([ .,]+)", "" ); -- spaces, period or comma at the beginning of a line
	--combatString = string.gsub(combatString, "([%(])[ ]+", "%1" ); whitespace after Parenthesis 

	return combatString, lineColor.r, lineColor.g, lineColor.b, 1;
end


-- Process the event and add it to the combat log
function CombatLog_AddEvent(...)
	if ( CombatLogUpdateFrame.refiltering ) then
		return;
	end
	local info = ChatTypeInfo["COMBAT_MISC_INFO"];
	local timestamp, event, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags = select(1, ...);
	local message = format("%s, %s, %s, 0x%x, %s, %s, 0x%x",
			       --date("%H:%M:%S", timestamp), 
	                       event,
	                       srcGUID, srcName or "nil", srcFlags,
	                       dstGUID, dstName or "nil", dstFlags);
	
	for i = 9, select("#", ...) do
		message = message..", "..(select(i, ...) or "nil");
	end
	if ( DEBUG == true ) then
		ChatFrame1:AddMessage(message, info.r, info.g, info.b);
		return;
	end
	--COMBATLOG:AddMessage(message, info.r, info.g, info.b);
	local finalMessage, r, g, b = CombatLog_OnEvent(COMBATLOG, timestamp, event, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, select( 9, ... ) );

	-- Debug line for hyperlinks
	-- finalMessage = string.gsub( finalMessage, "\124", "\124\124");

	-- Add the messages
	COMBATLOG:AddMessage( finalMessage, r, g, b, 1 );
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

getglobal(COMBATLOG:GetName().."Tab"):SetScript("OnDragStart",
	function(self, event, ...)
		local chatFrame = getglobal("ChatFrame"..this:GetID());
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
			local chatTab = getglobal(chatFrame:GetName().."Tab");
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

--
-- XML Function Overrides Part 2
--

-- 
-- Attach the Combat Log Button Frame to the Combat Log
--

-- On Event
function Blizzard_CombatLog_QuickButtonFrame_OnEvent(event)
	if ( event == "VARIABLES_LOADED" ) then
		Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_Filters.filters[1];
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		for k,v in pairs (Blizzard_CombatLog_UnitTokens) do
			Blizzard_CombatLog_UnitTokens[k] = nil;
		end
	end
end

-- On Load
function Blizzard_CombatLog_QuickButtonFrame_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");

	CombatLogQuickButtonFrame:SetParent(COMBATLOG);
	CombatLogQuickButtonFrame:ClearAllPoints();
	CombatLogQuickButtonFrame:SetPoint("BOTTOMLEFT", COMBATLOG, "TOPLEFT");
	CombatLogQuickButtonFrame:SetPoint("BOTTOMRIGHT", COMBATLOG, "TOPRIGHT");
	--CombatLogQuickButtonFrameProgressBar:ClearAllPoints();
	--CombatLogQuickButtonFrameProgressBar:SetPoint("TOPLEFT", CombatLogQuickButtonFrame, "TOPLEFT");
	--CombatLogQuickButtonFrameProgressBar:SetPoint("TOPRIGHT", CombatLogQuickButtonFrame, "TOPRIGHT");
	CombatLogQuickButtonFrameProgressBar:Hide();

	local oldPoint,relativeTo,relativePoint,xOfs,yOfs;
	local hadTopLeft = false;
	for i=1,COMBATLOG:GetNumPoints() do
		point,relativeTo,relativePoint,xOfs,yOfs = COMBATLOG:GetPoint(i)

		--DEFAULT_CHAT_FRAME:AddMessage(point)
		--DEFAULT_CHAT_FRAME:AddMessage(relativeTo:GetName())
		--DEFAULT_CHAT_FRAME:AddMessage(relativePoint)
		--DEFAULT_CHAT_FRAME:AddMessage(xOfs)
		--DEFAULT_CHAT_FRAME:AddMessage(yOfs)
		if ( point == "TOPLEFT" ) then 
			hadTopLeft = true;
			break;
		end
	end

	local heightChange = CombatLogQuickButtonFrame:GetHeight()
	if ( not COMBATLOG.isDocked ) then 
		local chatTab = getglobal(COMBATLOG:GetName().."Tab");
		local x,y = chatTab:GetCenter();
		if ( x and y ) then
			x = x - (chatTab:GetWidth()/2);
			y = y - (chatTab:GetHeight()/2);
			COMBATLOG:ClearAllPoints();
			COMBATLOG:SetPoint("TOPLEFT", "UIParent", "BOTTOMLEFT", x, y-heightChange);
		end
		getglobal(COMBATLOG:GetName().."Background"):SetPoint("TOPLEFT", COMBATLOG, "TOPLEFT", -2, 3 + heightChange);
		getglobal(COMBATLOG:GetName().."Background"):SetPoint("TOPRIGHT", COMBATLOG, "TOPRIGHT", 2, 3 + heightChange);

	else
		--ChatFrame1:AddMessage(yOfs - heightChange);
		COMBATLOG:SetPoint("TOPLEFT", relativeTo, relativePoint, xOfs, yOfs - heightChange )
		getglobal(COMBATLOG:GetName().."Background"):SetPoint("TOPLEFT", COMBATLOG, "TOPLEFT", -2, 3 + heightChange);
		getglobal(COMBATLOG:GetName().."Background"):SetPoint("TOPRIGHT", COMBATLOG, "TOPRIGHT", 2, 3 + heightChange);
	end
end

local oldFCF_DockUpdate = FCF_DockUpdate;
FCF_DockUpdate = function()
	oldFCF_DockUpdate();
	Blizzard_CombatLog_QuickButtonFrame_OnLoad();
end

-- Override Hyperlink Handlers
local oldSetItemRef = SetItemRef;
function SetItemRef(link, text, button)
	local printable = gsub(link, "\124", "\124\124");

	if ( strsub(link, 1, 4) == "unit") then
		local _, guid, name = strsplit(":", link);

		-- Show Popup Menu
		if( button == "RightButton") then
			EasyMenu(Blizzard_CombatLog_CreateUnitMenu(name, guid), CombatLogDropDown, "cursor", nil, nil, "MENU");
			return;
		elseif ( button == "LeftButton" ) then
			if ( IsModifiedClick("CHATLINK") ) then
				ChatEdit_InsertLink (name);
				return;
			end
		end
	elseif ( strsub(link, 1, 4) == "icon") then
		local _, bit, direction = strsplit(":", link);

		-- Show Popup Menu
		if( button == "RightButton") then
			EasyMenu(Blizzard_CombatLog_CreateUnitMenu(text, nil, tonumber(bit)), CombatLogDropDown, "cursor", nil, nil, "MENU");
			return;
		elseif ( button == "LeftButton" ) then
			if ( IsModifiedClick("CHATLINK") ) then
				ChatEdit_InsertLink (name);
				return;
			else
				return;
			end
		end
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
		elseif( button == "RightButton") then
				EasyMenu(Blizzard_CombatLog_CreateSpellMenu(text, spellId, event), CombatLogDropDown, "cursor", nil, nil, "MENU");
			return;
		end
	elseif ( strsub(link, 1,6) == "action" ) then 
		local _, event = strsplit(":", link);

		if ( IsModifiedClick("CHATLINK") ) then
			return;
		else
			-- Show Popup Menu
			if( button == "RightButton") then
				EasyMenu(Blizzard_CombatLog_CreateActionMenu(event), CombatLogDropDown, "cursor", nil, nil, "MENU");
				return;
			end
			return;
		end
	end

	-- This is already being called in oldSetItemRef
	--if ( IsModifierKeyDown() or IsModifiedClick() ) then
	--	HandleModifiedItemClick(text);
	--end
	
	oldSetItemRef(link, text, button);
end


-- XML Handler Functions (Move these to the bottom of the file later)
function Blizzard_CombatLog_QuickButton_Clear_OnClick()
	CombatLogClearEntries();
end

-- 
function Blizzard_CombatLog_QuickButton_OnClick(id, button)
	if ( button == "RightButton" ) then
		EasyMenu(Blizzard_CombatLog_CreateTabMenu ( id ), CombatLogDropDown, "cursor", nil, nil, "MENU");
	else
		Blizzard_CombatLog_Filters.currentFilter = id;
		Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_Filters.filters[Blizzard_CombatLog_Filters.currentFilter];
		Blizzard_CombatLog_ApplyFilters(Blizzard_CombatLog_CurrentSettings);
		if ( Blizzard_CombatLog_CurrentSettings.settings.showHistory ) then
			Blizzard_CombatLog_Refilter();
		end
	end
end

