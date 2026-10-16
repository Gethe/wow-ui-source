local _, addonTable = ...;
local TutorialData = {};
addonTable.TutorialData = TutorialData;

local UNUSED_ID = 0;
local DISTANCE_TO_KILL_QUEST_CREATURE_BASE = 30;
local DISTANCE_TO_KILL_QUEST_CREATURE_DWARF = 20
local DISTANCE_TO_KILL_QUEST_CREATURE_NIGHTELF = 14;

local EARLY_HOSTILE_QUEST_CREATURES_DWARF = { 706, 946 }; -- Frostmane Troll Whelp, Frostmane Novice
local EARLY_HOSTILE_QUEST_ID_DWARF = { 182, 1599 }; -- A Troll Cave, Beginnings

local EARLY_HOSTILE_QUEST_CREATURES_ORC = { 3101 }; -- Vile Familiar
local EARLY_HOSTILE_QUEST_ID_ORC = { 792, 1485 }; -- Vile familiars, Vile Familiars (Warlock flavor)

TutorialData.TUTORIAL_LEVEL_LIMIT = 10;

TutorialData.MAX_SPELL_HELP_LEVEL = 10;
TutorialData.MAX_ITEM_HELP_LEVEL = 10;
TutorialData.MAX_UI_HIDE_LEVEL = 0;
TutorialData.MAX_QUEST_HELPER_LEVEL = 0;
TutorialData.MAX_QUEST_COMPLETE_LEVEL = 0;
TutorialData.MAX_XP_BAR_LEVEL = 999;
TutorialData.INTRO_LEVEL = 0;
TutorialData.ROGUE_STEALTH_LEVEL = 999;
TutorialData.DRUID_CAT_FORM_LEVEL = 999;
TutorialData.DRUID_BEAR_FORM_LEVEL = 999;
TutorialData.HUNTER_STABLE_MAX_LEVEL = 999;
TutorialData.LOW_HEALTH_PERCENTAGE = 0.5;
TutorialData.MAX_LOOT_CORPSE_LEVEL = 3;
TutorialData.MAX_CHANGE_EQUIPMENT_LEVEL = 3;
TutorialData.CHANGE_EQUIPMENT_LIMIT = 1
TutorialData.PICK_REWARD_LEVEL = 3;

TutorialData.AUTO_ATTACK_SPELL_ID = 6603; 

TutorialData.UI_Elements = {};
TutorialData.UI_Elements.BACKPACK =	{MainMenuBarBackpackButton};
TutorialData.UI_Elements.BAGS_BAR =	{BagsBar};
TutorialData.UI_Elements.MAIN_BAGS_BUTTON =	{MainMenuBarBackpackButton};
TutorialData.UI_Elements.PLAYERSPELLS_MICROBUTTON = {PlayerSpellsMicroButton};
TutorialData.UI_Elements.OTHER_MICROBUTTONS = {CharacterMicroButton, GuildMicroButton, ProfessionMicroButton, MainMenuMicroButton, AchievementMicroButton, CollectionsMicroButton, QuestLogMicroButton, LFDMicroButton, EJMicroButton, HousingMicroButton};
TutorialData.UI_Elements.STORE_MICROBUTTON = {StoreMicroButton};
TutorialData.UI_Elements.TARGET_FRAME = {TargetFrame};
TutorialData.UI_Elements.STATUS_TRACKING_BAR = {StatusTrackingBarManager};


-- ------------------------------------------------------------------------------------------------------------
function TutorialData:GetRacialData()
	return TutorialData[TutorialHelper:GetRace()];
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialData:GetFactionData()
	return TutorialData[TutorialHelper:GetFaction()];
end

TutorialData.LevelAbilitiesTable = {
	WARRIOR = {
		nil, nil, nil, nil, nil, nil, nil, nil, nil,
	};
	PALADIN = {
		nil, nil, nil, nil, nil, nil, nil, nil, nil,
	};
	HUNTER = {
		nil, nil, nil, nil, nil, nil, nil, nil, nil,
	};
	ROGUE = {
		nil, nil, nil, nil, nil, nil, nil, nil, nil,
	};
	PRIEST = {
		nil, nil, nil, nil, nil, nil, nil, nil, nil,
	};
	SHAMAN = {
		nil, nil, nil, nil, nil, nil, nil, nil, nil,
	};
	MAGE = {
		nil, nil, nil, nil, nil, nil, nil, nil, nil,
	};
	WARLOCK = {
		nil, nil, nil, nil, nil, nil, nil, nil, nil,
	};
	MONK = {
		nil, nil, nil, nil, nil, nil, nil, nil, nil,
	};
	DRUID = {
		nil, nil, nil, nil, nil, nil, nil, nil, nil,
	};
}

-- ------------------------------------------------------------------------------------------------------------
TutorialData.DruidAnimalFormSpells =
{
	CAT_FORM_SPELL_ID = UNUSED_ID;
	BEAR_FORM_SPELL_ID = UNUSED_ID;

	catSpells = {UNUSED_ID, UNUSED_ID, UNUSED_ID};
	bearSpells = {UNUSED_ID};
}

TutorialData.RogueStealthSpells = {UNUSED_ID, UNUSED_ID};

TutorialData.HunterTamePetSpells = {UNUSED_ID, UNUSED_ID};

TutorialData.NPEDungeonID = UNUSED_ID;

TutorialData.TabTargetingQuestID = UNUSED_ID;

-- ------------------------------------------------------------------------------------------------------------
TutorialData.ClassData = {
	WARRIOR = {
		firstSpellID = UNUSED_ID,
		initialString = UNUSED_ID,
		reminderString = UNUSED_ID,
		
		resourceBuilderSpellID = UNUSED_ID,
		resourceSpenderSpellID = UNUSED_ID,
		resource = Enum.PowerType.Rage;
		resourceGateAmount = 0,
		warningBuilderString = UNUSED_ID;
		warningSpenderString = UNUSED_ID;

		builderString = nil,
		spenderString = nil,
		classQuestSpellID = UNUSED_ID,
	},
	PALADIN = {
		firstSpellID = UNUSED_ID,
		initialString = UNUSED_ID,
		reminderString = UNUSED_ID,

		resourceBuilderSpellID = UNUSED_ID,
		resourceSpenderSpellID = UNUSED_ID,
		resource = Enum.PowerType.Mana;
		resourceGateAmount = 0,
		warningBuilderString = UNUSED_ID;
		warningSpenderString = UNUSED_ID;

		builderString = nil,
		spenderString = nil,
		classQuestSpellID = UNUSED_ID,
	},
	HUNTER = {
		firstSpellID = UNUSED_ID,
		initialString = UNUSED_ID,
		reminderString = UNUSED_ID,

		resourceBuilderSpellID = UNUSED_ID,
		resourceSpenderSpellID = UNUSED_ID,
		resource = Enum.PowerType.Mana;
		resourceGateAmount = 0,
		warningBuilderString = UNUSED_ID;
		warningSpenderString = UNUSED_ID;

		builderString = nil,
		spenderString = nil,
		classQuestSpellID = UNUSED_ID,
	},
	ROGUE = {
		firstSpellID = UNUSED_ID,
		initialString = UNUSED_ID,
		reminderString = UNUSED_ID,

		resourceBuilderSpellID = UNUSED_ID,
		resourceSpenderSpellID = UNUSED_ID,
		resource = Enum.PowerType.ComboPoints;
		resourceGateAmount = 0,
		warningBuilderString = UNUSED_ID;
		warningSpenderString = UNUSED_ID;

		builderString = nil,
		spenderString = nil,
		classQuestSpellID = UNUSED_ID,
	},
	PRIEST = {
		firstSpellID = UNUSED_ID,
		initialString = UNUSED_ID,
		reminderString = UNUSED_ID,

		resourceBuilderSpellID = UNUSED_ID,
		resourceSpenderSpellID = UNUSED_ID,
		resource = Enum.PowerType.Mana;
		resourceGateAmount = 0,
		warningBuilderString = UNUSED_ID;
		warningSpenderString = UNUSED_ID;

		builderString = nil,
		spenderString = nil,
		classQuestSpellID = UNUSED_ID,
	},
	SHAMAN = {
		firstSpellID = UNUSED_ID,
		initialString = UNUSED_ID,
		reminderString = UNUSED_ID,

		resourceBuilderSpellID = UNUSED_ID,
		resourceSpenderSpellID = UNUSED_ID,
		resource = Enum.PowerType.Mana;
		resourceGateAmount = 0,
		warningBuilderString = UNUSED_ID;
		warningSpenderString = UNUSED_ID;

		builderString = nil,
		spenderString = nil,
		classQuestSpellID = UNUSED_ID,
	},
	MAGE = {
		firstSpellID = UNUSED_ID,
		initialString = UNUSED_ID,
		reminderString = UNUSED_ID,

		resourceBuilderSpellID = UNUSED_ID,
		resourceSpenderSpellID = UNUSED_ID,
		resource = Enum.PowerType.Mana;
		resourceGateAmount = 0,
		warningBuilderString = UNUSED_ID;
		warningSpenderString = UNUSED_ID;

		builderString = nil,
		spenderString = nil,
		classQuestSpellID = UNUSED_ID,
	},
	WARLOCK = {
		firstSpellID = UNUSED_ID,
		initialString = UNUSED_ID,
		reminderString = UNUSED_ID,

		resourceBuilderSpellID = UNUSED_ID,
		resourceSpenderSpellID = UNUSED_ID,
		alternateResourceSpenderSpellID = UNUSED_ID,
		resource = Enum.PowerType.Mana;
		resourceGateAmount = 0,
		warningBuilderString = UNUSED_ID;
		warningSpenderString = UNUSED_ID;

		builderString = nil,
		spenderString = nil,
		classQuestSpellID = UNUSED_ID,
	},
	DRUID = {
		firstSpellID = UNUSED_ID,
		initialString = UNUSED_ID,
		reminderString = UNUSED_ID,

		resourceBuilderSpellID = UNUSED_ID,
		resourceSpenderSpellID = UNUSED_ID,
		alternateResourceSpenderSpellID = UNUSED_ID,
		resource = Enum.PowerType.Mana;
		resourceGateAmount = 0,
		warningBuilderString = UNUSED_ID;
		warningSpenderString = UNUSED_ID;

		builderString = nil,
		spenderString = nil,
		classQuestSpellID = UNUSED_ID,
	},
};

local function GetPlayerRace()
	local _, race = UnitRace("player")
	return race
end

TutorialData.StartingQuestByRace = {
	Human    = 783,    -- A Threat Within
	Dwarf    = 179,    -- Dwarven Outfitters
	Gnome    = 179,    -- Dwarven Outfitters
	NightElf = 456,    -- The Balance of Nature

	Scourge  = 363,    -- Rude Awakening
	Orc      = 4641,   -- Your place in the World
	Troll    = 4641,   -- Your place in the World
	Tauren   = 747,    -- The Hunt Begins

	Skyborne = 92460,  -- Coming of Age
};

function TutorialData:GetStartingQuestInternal()
	return self.StartingQuestByRace[GetPlayerRace()];
end

TutorialData.StartingQuestGiverCreatureByRace = {
	Human    = 823,    -- Deputy Willem
	Dwarf    = 658,    -- Sten Stoutarm
	Gnome    = 658,    -- Sten Stoutarm
	NightElf = 2079,   -- Conservator Ilthalaine

	Scourge  = 1568,   -- Undertaker Mordo
	Orc      = 10176,  -- Kaltunk
	Troll    = 10176,  -- Kaltunk
	Tauren   = 2980,   -- Grull Hawkwind

	Skyborne = 251362, -- Ailee Farheart
};

function TutorialData:GetStartingQuestGiverCreatureInternal()
	return self.StartingQuestGiverCreatureByRace[GetPlayerRace()];
end

TutorialData.StartingQuestInteractStringByRace = {
	Human    = NPEV2_INTRO_QUESTGIVER_INTERACT_HUMAN,    -- Deputy Willem
	Dwarf    = NPEV2_INTRO_QUESTGIVER_INTERACT_DWARF,    -- Sten Stoutarm
	Gnome    = NPEV2_INTRO_QUESTGIVER_INTERACT_DWARF,    -- Sten Stoutarm
	NightElf = NPEV2_INTRO_QUESTGIVER_INTERACT_NIGHTELF, -- Conservator Ilthalaine

	Scourge  = NPEV2_INTRO_QUESTGIVER_INTERACT_SCOURGE,  -- Undertaker Mordo
	Orc      = NPEV2_INTRO_QUESTGIVER_INTERACT_ORC,		 -- Kaltunk
	Troll    = NPEV2_INTRO_QUESTGIVER_INTERACT_ORC,		 -- Kaltunk
	Tauren   = NPEV2_INTRO_QUESTGIVER_INTERACT_TAUREN,   -- Grull Hawkwind

	Skyborne = NPEV2_INTRO_QUESTGIVER_INTERACT_SKYBORNE, -- Ailee Farheart
};

function TutorialData:GetStartingQuestInteractStringInternal()
	return self.StartingQuestInteractStringByRace[GetPlayerRace()];
end

TutorialData.EarlyKillQuestCreaturesByRace = {
	Human    = { 6, 299, 69 },		-- Kobold Vermin, Young Wolf, Timber Wolf
	Dwarf    = { 705 },				-- Ragged Young Wolf
	Gnome    = { 705 },				-- Ragged Young Wolf
	NightElf = { 2031, 1984 },		-- Young Nightsaber, Young Thistle Boar

	Scourge  = { 1501, 1502 },		-- Mindless Zombie, Wretched Zombie
	Orc      = { 3098 },			-- Mottled Boar
	Troll    = { 3098 },			-- Mottled Boar
	Tauren   = { 2955 },			-- Plainstrider

	Skyborne = { 250873, 251169 },  -- Juvenile Vuldren, Pesky Cirrusfly
};

function TutorialData:GetEarlyKillQuestCreaturesByRaceInternal()
	return self.EarlyKillQuestCreaturesByRace[GetPlayerRace()];
end

-- The first kill quest is sometimes the first quest, but not always. Sometimes a player might have 2 first kill quests at the same time.
TutorialData.EarlyKillQuestIDsByRace = {
	Human    = { 7, 33 },		  -- Kobold Camp Cleanup, Wolves Across the Border
	Dwarf    = { 179 },			  -- Dwarven Outfitters
	Gnome    = { 179 },			  -- Dwarven Outfitters
	NightElf = { 456 },			  -- The balance of nature

	Scourge  = { 364 },			  -- The mindless ones
	Orc      = { 788 },			  -- Cutting Teeth
	Troll    = { 788 },			  -- Cutting Teeth
	Tauren   = { 747 },			  -- The Hunt Begins

	Skyborne = { 92461, 92462 },  -- Harmony in balance, Infestation Investigation
};

function TutorialData:GetEarlyKillQuestIDsByRaceInternal()
	return self.EarlyKillQuestIDsByRace[GetPlayerRace()];
end


TutorialData.DistanceToKillQuestCreatureByRace = {
	Human    = DISTANCE_TO_KILL_QUEST_CREATURE_BASE,
	Dwarf    = DISTANCE_TO_KILL_QUEST_CREATURE_DWARF,
	Gnome    = DISTANCE_TO_KILL_QUEST_CREATURE_DWARF,
	NightElf = DISTANCE_TO_KILL_QUEST_CREATURE_NIGHTELF,

	Scourge  = DISTANCE_TO_KILL_QUEST_CREATURE_BASE,
	Orc      = DISTANCE_TO_KILL_QUEST_CREATURE_BASE,
	Troll    = DISTANCE_TO_KILL_QUEST_CREATURE_BASE,
	Tauren   = DISTANCE_TO_KILL_QUEST_CREATURE_BASE,

	Skyborne = DISTANCE_TO_KILL_QUEST_CREATURE_BASE,
};

function TutorialData:GetDistanceToKillQuestCreature()
	return self.DistanceToKillQuestCreatureByRace[GetPlayerRace()];
end

-- Hostile quest is the first quests where the mobs will attack you (red instead of yellow)
TutorialData.EarlyHostileQuestCreaturesByRace = {
	Human    = { 38, 80 },			-- Defias thug, Kobold Laborer
	Dwarf    = EARLY_HOSTILE_QUEST_CREATURES_DWARF,
	Gnome    = EARLY_HOSTILE_QUEST_CREATURES_DWARF,
	NightElf = { 1986 },			-- Webwood Spider

	Scourge  = { 1505 },			-- Night Web Spider
	Orc      = EARLY_HOSTILE_QUEST_CREATURES_ORC,
	Troll    = EARLY_HOSTILE_QUEST_CREATURES_ORC,
	Tauren   = { 2966, 2954 },		-- Battleboar, Bristleback Battleboar

	Skyborne = { 251143, 251160, 251404, 251402 },  -- Roiling Winds, Alaketh Convert, Cirrusfly Queen, Cirrusfly Soldier
};

function TutorialData:GetEarlyHostileQuestCreaturesByRaceInternal()
	return self.EarlyHostileQuestCreaturesByRace[GetPlayerRace()];
end

-- Hostile quest is the first quests where the mobs will attack you (red instead of yellow)
TutorialData.EarlyHostileQuestIDByRace = {
	Human    = { 18, 21, 1598 },	-- Brotherhood of Thieves, Skirmish at Echo Ridge, The Stolen Tome
	Dwarf    = EARLY_HOSTILE_QUEST_ID_DWARF,
	Gnome    = EARLY_HOSTILE_QUEST_ID_DWARF,
	NightElf = { 916, 4495, 3519 },	-- Webwood venom, A Good Friend, A Friend in Need

	Scourge  = { 380 },				-- Night Web’s Hollow, Night Web Spider
	Orc      = EARLY_HOSTILE_QUEST_ID_ORC,
	Troll    = EARLY_HOSTILE_QUEST_ID_ORC,
	Tauren   = { 780 },				-- The Battleboars

	Skyborne = { 92465, 92463 },	-- Agitators, The Cirrusfly Queen
};

function TutorialData:GetEarlyHostileQuestIDByRaceInternal()
	return self.EarlyHostileQuestIDByRace[GetPlayerRace()];
end

-- ------------------------------------------------------------------------------------------------------------
TutorialData.Alliance = {
	StartingQuestTargetDummyCreatureID = UNUSED_ID;

	StandYourGround = UNUSED_ID;
	BraceForImpact = UNUSED_ID;

	ShowMinimapQuest = UNUSED_ID;

	UseMapQuest = UNUSED_ID;

	FirstLootableCreatureID = {UNUSED_ID, UNUSED_ID};

	ShowAllUIQuest = UNUSED_ID;

	SelfHealSpellID = UNUSED_ID;

	MultipleQuestsTutorial = {UNUSED_ID, UNUSED_ID};

	HunterTameTutorialQuestID = UNUSED_ID;

	UseVendorQuest = UNUSED_ID;

	LookingForGroupQuest = UNUSED_ID;

	GetMountQuest = UNUSED_ID;

	SpecChoiceQuest = UNUSED_ID;

	AnUrgentMeeting = UNUSED_ID;

	LeavePartyPromptQuest = UNUSED_ID;

	UseQuestItemData = {
		ScreenTutorialStringID = UNUSED_ID;
		PointerTutorialStringID = UNUSED_ID;
		ItemQuest = UNUSED_ID;
		ItemTargets = {UNUSED_ID, UNUSED_ID, UNUSED_ID};
		TargetRange = 5;
		ItemSpell = UNUSED_ID;
	};

	RemindUseQuestItemData = {
		ScreenTutorialStringID = NPEV2_APPROACH_WANDERING_BOAR;
		PointerTutorialStringID = NPEV2_USEQUESTITEM;
		ItemQuest = UNUSED_ID;
		ItemTargets = {UNUSED_ID};
		TargetRange = 8;
		ItemSpell = UNUSED_ID;
	};

	EnhancedCombatTacticsQuest = UNUSED_ID;
	EnhancedCombatTacticsCreatureID = UNUSED_ID;
	EnhancedCombatTacticsOverrideCreatureID = UNUSED_ID;

	MountData = {
		mountItem = UNUSED_ID,
		mountSpellID = UNUSED_ID;
		mountID = UNUSED_ID;
	};

	ClassQuests = {
		WARRIOR =	UNUSED_ID,
		PALADIN =	UNUSED_ID,
		HUNTER =	UNUSED_ID,
		ROGUE =		UNUSED_ID,
		PRIEST =	UNUSED_ID,
		SHAMAN =	UNUSED_ID,
		MAGE =		UNUSED_ID,
		WARLOCK =	UNUSED_ID,
		DRUID =		UNUSED_ID,
	};

	SpecQuestTrackID = UNUSED_ID;
}

function TutorialData.Alliance:GetStartingQuest()
	return TutorialData:GetStartingQuestInternal();
end

function TutorialData.Alliance:GetStartingQuestGiverCreatureID()
	return TutorialData:GetStartingQuestGiverCreatureInternal();
end

function TutorialData.Alliance:GetStartingQuestInteractString()
	return TutorialData:GetStartingQuestInteractStringInternal();
end

function TutorialData.Alliance:GetEarlyKillQuestCreaturesByRace()
	return TutorialData:GetEarlyKillQuestCreaturesByRaceInternal();
end

function TutorialData.Alliance:GetEarlyKillQuestIDsByRace()
	return TutorialData:GetEarlyKillQuestIDsByRaceInternal();
end

function TutorialData.Alliance:GetEarlyHostileQuestCreaturesByRace()
	return TutorialData:GetEarlyHostileQuestCreaturesByRaceInternal();
end

function TutorialData.Alliance:GetEarlyHostileQuestIDByRace()
	return TutorialData:GetEarlyHostileQuestIDByRaceInternal();
end

-- ------------------------------------------------------------------------------------------------------------
TutorialData.Horde = {
	StartingQuestTargetDummyCreatureID = UNUSED_ID;

	StandYourGround = UNUSED_ID;
	BraceForImpact = UNUSED_ID;

	ShowMinimapQuest = UNUSED_ID;
	
	UseMapQuest = UNUSED_ID;

	FirstLootableCreatureID = {UNUSED_ID, UNUSED_ID};

	ShowAllUIQuest = UNUSED_ID;

	SelfHealSpellID = UNUSED_ID;

	MultipleQuestsTutorial = {UNUSED_ID, UNUSED_ID};

	HunterTameTutorialQuestID = UNUSED_ID;

	UseVendorQuest = UNUSED_ID;

	LookingForGroupQuest = UNUSED_ID;
	
	GetMountQuest = UNUSED_ID;

	SpecChoiceQuest = UNUSED_ID;

	AnUrgentMeeting = UNUSED_ID;

	LeavePartyPromptQuest = UNUSED_ID;

	UseQuestItemData = {
		ScreenTutorialStringID = UNUSED_ID;
		PointerTutorialStringID = UNUSED_ID;
		ItemQuest = UNUSED_ID;
		ItemTargets = {UNUSED_ID, UNUSED_ID, UNUSED_ID};
		TargetRange = 5;
		ItemSpell = UNUSED_ID;
	};

	RemindUseQuestItemData = {
		ScreenTutorialStringID = UNUSED_ID;
		PointerTutorialStringID = UNUSED_ID;
		ItemQuest = UNUSED_ID;
		ItemTargets = {UNUSED_ID};
		TargetRange = 8;
		ItemSpell = UNUSED_ID;
	};

	EnhancedCombatTacticsQuest = UNUSED_ID;
	EnhancedCombatTacticsCreatureID = UNUSED_ID;
	EnhancedCombatTacticsOverrideCreatureID = UNUSED_ID;

	MountData = {
		mountItem = UNUSED_ID,
		mountSpellID = UNUSED_ID;
		mountID = UNUSED_ID;
	};

	ClassQuests = {
		WARRIOR =	UNUSED_ID,
		PALADIN =	UNUSED_ID,
		HUNTER =	UNUSED_ID,
		ROGUE =		UNUSED_ID,
		PRIEST =	UNUSED_ID,
		SHAMAN =	UNUSED_ID,
		MAGE =		UNUSED_ID,
		WARLOCK =	UNUSED_ID,
		DRUID =		UNUSED_ID,
	};

	SpecQuestTrackID = UNUSED_ID;
}

function TutorialData.Horde:GetStartingQuest()
	return TutorialData:GetStartingQuestInternal();
end

function TutorialData.Horde:GetStartingQuestGiverCreatureID()
	return TutorialData:GetStartingQuestGiverCreatureInternal();
end

function TutorialData.Horde:GetStartingQuestInteractString()
	return TutorialData:GetStartingQuestInteractStringInternal();
end

function TutorialData.Horde:GetEarlyKillQuestCreaturesByRace()
	return TutorialData:GetEarlyKillQuestCreaturesByRaceInternal();
end

function TutorialData.Horde:GetEarlyKillQuestIDsByRace()
	return TutorialData:GetEarlyKillQuestIDsByRaceInternal();
end

function TutorialData.Horde:GetEarlyHostileQuestCreaturesByRace()
	return TutorialData:GetEarlyHostileQuestCreaturesByRaceInternal();
end

function TutorialData.Horde:GetEarlyHostileQuestIDByRace()
	return TutorialData:GetEarlyHostileQuestIDByRaceInternal();
end
