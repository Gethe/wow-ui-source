local _, addonTable = ...;

local TutorialData = {};
addonTable.TutorialData = TutorialData;

-- ------------------------------------------------------------------------------------------------------------
TutorialData.LevelAbilitiesTable = {
	WARRIOR = {
		1464,	-- Start with Slam
		100,	-- Charge, level 2
		23922,	-- Shield Slam, level 3
		1715,	-- Hamstring, level 4
		34428,	-- Victory Rush, level 5
		2565,	-- Shield Block, level 6
		6552,	-- Pummel, level 7
		nil,	-- 319157, Charge Rank 2, level 8
		1680,	-- Whirlwind, level 9
	};
	PALADIN = {
		35395,	-- Start with Crusader Strike
		53600,	-- Shield of the Righteous, level 2
		20271,	-- Judgment, level 3
		19750,	-- Flash of Light, level 4
		853,	-- Hammer of Justice, level 5
		190784,	-- Divine Steed, level 6
		85673,	-- Word of Glory, level 7
		633,	-- Lay on Hands, level 8
		26573,	-- Consecration, level 9
	};
	HUNTER = {
		56641,	-- Start with Steady Shot
		185358,	-- Arcane Shot, level 2
		195645,	-- Wing Clip, level 3
		1513,	-- Scare Beast, level 4
		186257,	-- Aspect of the Cheetah, level 5
		5384,	-- Feign Death, level 6
		257284,	-- Hunter's Mark, level 7
		781,	-- Disengage, level 8
		109304,	-- Exhilaration, level 9
	};
	ROGUE = {
		1752,	-- Start with Sinister Strike
		196819,	-- Eviscerate, level 2
		1784,	-- Stealth, level 3
		1833,	-- Cheap Shot, level 4
		2983,	-- Sprint, level 5
		1766,	-- Kick, level 6
		921,	-- Pick Pocket, level 7
		185311,	-- Crimson Vial, level 8
		1804,	-- Pick Lock, level 9
	};
	PRIEST = {
		585,	-- Start with Smite
		589,	-- Shadow Word: Pain, level 2
		2061,	-- Flash Heal, level 3
		17,		-- Power Word: Shield, level 4
		19236,	-- Desperate Prayer, level 5
		nil,	-- ???, level 6
		8122,	-- Psychic Scream, level 7
		8092,	-- Mind Blast, level 8
		nil,	-- ???, level 9
	};
	SHAMAN = {
		188196,	-- Start with Lightning Bolt
		73899,	-- Primal Strike, level 2
		188389,	-- Flame Shock, level 3
		8004,	-- Healing Surge, level 4
		2484,	-- Earthbind Totem, level 5
		nil,	-- 318044,	Lightning Bolt Rank 2, level 6
		318038,	-- Flametongue Weapon, level 7
		20608,	-- Reincarnation, level 8
		3599,	-- Searing Totem, level 9
	};
	MAGE = {
		116,	-- Start with Frostbolt
		319836,	-- Fire Blast, level 2
		122,	-- Frost Nova, level 3
		1953,	-- Blink, level 4
		190336,	-- Conjure Refreshment, level 5
		1449,	-- Arcane Explosion, level 6
		2139,	-- Counterspell, level 7
		1459,	-- Arcane Intellect, level 8
		130,	-- Slow Fall, level 9
	};
	WARLOCK = {
		686,	-- Start with Shadow Bolt
		172,	-- Corruption, level 2
		688,	-- Summon Imp, level 3
		317138,	-- Unending Resolve, level 4
		5782,	-- Fear, level 5
		703,	-- Curse of Weakness, level 6
		6201,	-- Create Healthstone, level 7
		755,	-- Health Funnel, level 8
		234153,	-- Drain Life, level 9
	};
	MONK = {
		100780,	-- Start with Tiger Palm
		100784,	-- Blackout Kick, level 2
		109132,	-- Roll, level 3
		116670,	-- Vivify, level 4
		117952,	-- Crackling Jade Lightning, level 5
		119381,	-- Leg Sweep, level 6
		101546,	-- Spinning Crane Kick, level 7
		322101,	-- Expel Harm, level 8
		115078,	-- Paralysis, level 9
	};
	DRUID = {
		5176,	-- Start with Wrath
		8921,	-- Moonfire, level 2
		8936,	-- Regrowth, level 3
		5221,	-- Shred, level 4
		339,	-- Entangling Roots, level 5
		1850,	-- Dash, level 6
		22812,	-- Barkskin, level 7
		33917,	-- Mangle, level 8
		nil,	-- 326646, Moonfire Rank 2, level 9
	};
}

-- ------------------------------------------------------------------------------------------------------------
TutorialData.SecondLevelAbilityTable =
{
	DRUID = {
		nil,	-- 
		nil,	-- 
		nil,	-- 
		768,	-- Cat Form, level 4
		nil,	-- 
		nil,	-- 
		nil,	-- 
		nil,	-- 
		5487,	-- Bear Form, level 9
	}
}

-- ------------------------------------------------------------------------------------------------------------
TutorialData.ClassData = {
	WARRIOR = {
		firstSpellID = 1464,				-- Slam
		initialString = NPEV2_WARRIOR_ABILITYINITIAL,
		reminderString = NPEV2_WARRIOR_ABILITYINITIALREPEAT,
		
		resourceBuilderSpellID = 100,		-- Charge
		resourceSpenderSpellID = 1464,		-- Slam
		resource = Enum.PowerType.Rage;
		resourceGateAmount = 20,
		warningBuilderString = NPEV2_ENHANCED_COMBAT_TACTICS_WARNING_WARRIOR;
		warningSpenderString = NPEV2_ENHANCED_COMBAT_TACTICS_WARNING;

		builderString = NPEV2_WARRIOR_BUILDER,
		spenderString = NPEV2_WARRIOR_SPENDER,
		backupUIElement = MainMenuBarArtFrame,
		classQuestSpellID = 163201,			-- Execute
	},
	PALADIN = {
		firstSpellID = 35395,				-- Crusader Strike
		initialString = NPEV2_PALADIN_ABILITYINITIAL,
		reminderString = NPEV2_PALADIN_ABILITYINITIALREPEAT,

		resourceBuilderSpellID = 35395,		-- Crusader Strike
		resourceSpenderSpellID = 53600,		-- Shield of the Righteous
		resource = Enum.PowerType.HolyPower;
		resourceGateAmount = 3,
		warningBuilderString = NPEV2_ENHANCED_COMBAT_TACTICS_WARNING;
		warningSpenderString = NPEV2_ENHANCED_COMBAT_TACTICS_WARNING;

		builderString = NPEV2_PALADIN_BUILDER,
		spenderString = NPEV2_PALADIN_SPENDER,
		backupUIElement = ClassNameplateBarPaladinFrame,
		classQuestSpellID = 642,			-- Divine Shield
	},
	HUNTER = {
		firstSpellID = 56641,				-- Steady Shot
		initialString = NPEV2_ABILITYINITIAL,
		reminderString = NPEV2_ABILITYINITIALREPEAT,

		resourceBuilderSpellID = 56641,		-- Steady Shot
		resourceSpenderSpellID = 185358,	-- Arcane Shot
		resource = Enum.PowerType.Focus;
		resourceGateAmount = 3,
		warningBuilderString = NPEV2_ENHANCED_COMBAT_TACTICS_WARNING;
		warningSpenderString = NPEV2_ENHANCED_COMBAT_TACTICS_WARNING;

		builderString = NPEV2_PALADIN_BUILDER,
		spenderString = NPEV2_PALADIN_SPENDER,
		backupUIElement = ClassNameplateBarPaladinFrame,
		classQuestSpellID = 187650,			-- Freezing Trap
	},
	ROGUE = {
		firstSpellID = 1752,				-- Sinister Strike
		initialString = NPEV2_ROGUE_ABILITYINITIAL,
		reminderString = NPEV2_ROGUE_ABILITYINITIALREPEAT,

		resourceBuilderSpellID = 1752,		-- Sinister Strike
		resourceSpenderSpellID = 196819,	-- Eviscerate
		resource = Enum.PowerType.ComboPoints;
		resourceGateAmount = 45,
		warningBuilderString = NPEV2_ENHANCED_COMBAT_TACTICS_WARNING;
		warningSpenderString = NPEV2_ENHANCED_COMBAT_TACTICS_WARNING;

		builderString = NPEV2_ROGUE_BUILDER,
		spenderString = NPEV2_ROGUE_SPENDER,
		backupUIElement = ClassNameplateBarRogueDruidFrame,
		classQuestSpellID = 315584,			-- Instant Poison
	},
	PRIEST = {
		firstSpellID = 585,					-- Smite
		initialString = NPEV2_CASTER_ABILITYINITIAL,
		remidnerString = NPEV2_CASTER_ABILITYINITIALREPEAT,

		resourceBuilderSpellID = 585,		-- Smite
		resourceSpenderSpellID = 589,		-- Shadow Word: Pain
		resource = Enum.PowerType.Mana;
		resourceGateAmount = 0,
		warningBuilderString = NPEV2_ENHANCED_COMBAT_TACTICS_WARNING;
		warningSpenderString = NPEV2_ENHANCED_COMBAT_TACTICS_WARNING;

		builderString = NPEV2_PRIEST_BUILDER,
		spenderString = NPEV2_PRIEST_SPENDER,
		backupUIElement = ClassNameplateManaBarFrame,
		classQuestSpellID = 2006,			-- Ressurection
	},
	SHAMAN = {
		firstSpellID = 188196,				-- Lightning Bolt
		initialString = NPEV2_CASTER_ABILITYINITIAL,
		reminderString = NPEV2_CASTER_ABILITYINITIALREPEAT,

		resourceBuilderSpellID = 188196,	-- Lightning Bolt
		resourceSpenderSpellID = 73899,		-- Primal Strike
		resource = Enum.PowerType.Mana;
		resourceGateAmount = 0,
		warningBuilderString = NPEV2_ENHANCED_COMBAT_TACTICS_WARNING;
		warningSpenderString = NPEV2_ENHANCED_COMBAT_TACTICS_WARNING;

		builderString = NPEV2_SHAMAN_BUILDER,
		spenderString = NPEV2_SHAMAN_SPENDER,
		backupUIElement = ClassNameplateManaBarFrame,
		classQuestSpellID = 2645,			-- Ghost Wolf
	},
	MAGE = {
		firstSpellID = 116,					-- Frostbolt
		initialString = NPEV2_CASTER_ABILITYINITIAL,
		reminderString = NPEV2_CASTER_ABILITYINITIALREPEAT,

		resourceBuilderSpellID = 116,		-- Frostbolt
		resourceSpenderSpellID = 319836,	-- Fire Blast
		resource = Enum.PowerType.Mana;
		resourceGateAmount = 4,
		warningBuilderString = NPEV2_ENHANCED_COMBAT_TACTICS_WARNING;
		warningSpenderString = NPEV2_ENHANCED_COMBAT_TACTICS_WARNING;

		builderString = NPEV2_MAGE_BUILDER,
		spenderString = NPEV2_MAGE_SPENDER,
		backupUIElement = ClassNameplateManaBarFrame,
		classQuestSpellID = 118,			-- Polymorph
	},
	WARLOCK = {
		firstSpellID = 686,					-- Shadow Bolt
		initialString = NPEV2_CASTER_ABILITYINITIAL,
		reminderString = NPEV2_CASTER_ABILITYINITIALREPEAT,

		resourceBuilderSpellID = 686,		-- Shadow Bolt
		resourceSpenderSpellID = 172,		-- Corruption
		alternateResourceSpenderSpellID = 146739,
		resource = Enum.PowerType.SoulShards;
		resourceGateAmount = 4,
		warningBuilderString = NPEV2_ENHANCED_COMBAT_TACTICS_WARNING;
		warningSpenderString = NPEV2_ENHANCED_COMBAT_TACTICS_WARNING;

		builderString = NPEV2_WARLOCK_BUILDER,
		spenderString = NPEV2_WARLOCK_SPENDER,
		backupUIElement = ClassNameplateManaBarFrame,
		classQuestSpellID = 697,			-- Summon Voidwalker
	},
	MONK = {
		firstSpellID = 100780,				-- Tiger Palm
		initialString = NPEV2_ABILITYINITIAL,
		reminderString = NPEV2_ABILITYINITIALREPEAT,

		resourceBuilderSpellID = 100780,	-- Tiger Palm
		resourceSpenderSpellID = 100784,	-- Blackout Kick
		resource = Enum.PowerType.Mana;
		resourceGateAmount = 5,
		warningBuilderString = NPEV2_ENHANCED_COMBAT_TACTICS_WARNING;
		warningSpenderString = NPEV2_ENHANCED_COMBAT_TACTICS_WARNING;

		builderString = NPEV2_MONK_BUILDER,
		spenderString = NPEV2_MONK_SPENDER,
		backupUIElement = ClassNameplateManaBarFrame,
		classQuestSpellID = 322109,			-- Touch of Death
	},
	DRUID = {
		firstSpellID = 5176,						-- Wrath
		initialString = NPEV2_CASTER_ABILITYINITIAL,
		reminderString = NPEV2_CASTER_ABILITYINITIALREPEAT,

		resourceBuilderSpellID = 5176,		-- Wrath
		resourceSpenderSpellID = 8921,		-- Moonfire
		alternateResourceSpenderSpellID = 164812,
		resource = Enum.PowerType.Mana;
		resourceGateAmount = 5,
		warningBuilderString = NPEV2_ENHANCED_COMBAT_TACTICS_WARNING;
		warningSpenderString = NPEV2_ENHANCED_COMBAT_TACTICS_WARNING;

		builderString = NPEV2_DRUID_BUILDER,
		spenderStringD = NPEV2_DRUID_SPENDER,
		backupUIElement = ClassNameplateManaBarFrame,
		classQuestSpellID = 783,			-- Travel Form
	},
};

-- ------------------------------------------------------------------------------------------------------------
TutorialData.Alliance = {
	StartingQuest = 56775;
	StartingQuestTutorialString = NPEV2_INTRO_MOVE_ALLIANCE;
	StartingQuestInteractString = NPEV2_INTRO_QUESTGIVER_INTERACT_ALLIANCE;
	StartingQuestGiverCreatureID = 156280;
	StartingQuestTargetDummyCreatureID = 160737;

	ShowMinimapQuest = 55122;
	
	UseMapQuest = 54952;

	FirstLootableCreatureID = {150228, 150229};

	ShowAllUIQuest = 58208;

	UseFoodQuest = 55174;
	FoodItem = 117;
	FoodSpellCast = 433;

	LookingForGroupQuest = 55992;
	
	GetMountQuest = 58909;

	SpecChoiceQuest = 59587;

	UseQuestItemData = {
		ScreenTutorialStringID = NPEV2_APPROACH_INJURED_CREWMEMBER;
		PointerTutorialStringID = NPE_USEQUESTITEM;
		ItemQuest = 54951;
		ItemTargets = {156612, 156610, 156609};
		TargetRange = 5;
		ItemSpell = 297415;
	};

	RemindUseQuestItemData = {
		ScreenTutorialStringID = NPEV2_APPROACH_WANDERING_BOAR;
		PointerTutorialStringID = NPE_USEQUESTITEM;
		ItemQuest = 56034;
		ItemTargets = {156716};
		TargetRange = 8;
		ItemSpell = 305716;
	};

	EnhancedCombatTacticsQuest = 59254;
	EnhancedCombatTacticsCreatureID = 164577;
	EnhancedCombatTacticsOverrideCreatureID = 164605;

	Mounts = {
		Human = {		-- black stallion
			mountItem = 2411,
			mountSpellID = 470;
			mountID = 9;
		},
		Draenei = {		-- brown elek
			mountItem = 28481,
			mountSpellID = 34406;
			mountID = 147;
		},
		Gnome = {		-- unpainted mechanostrider
			mountItem = 13322,
			mountSpellID = 17454;
			mountID = 58;
		},
		Dwarf = {		-- gray ram
			mountItem = 5864,
			mountSpellID = 6777;
			mountID = 21;
		},
		Worgen = {		-- mountain horse
			mountItem = 73838,
			mountSpellID = 103195;
			mountID = 435;
		},
		NightElf = {	-- striped nightsaber
			mountItem = 8629,
			mountSpellID = 10793;
			mountID = 34;
		},
		Pandaren = {	-- red dragon turtle
			mountItem = 87800,
			mountSpellID = 127290;
			mountID = 496;
		}
	};
}

-- ------------------------------------------------------------------------------------------------------------
TutorialData.Horde = {
	StartingQuest = 59926;
	StartingQuestTutorialString = NPEV2_INTRO_MOVE_HORDE;
	StartingQuestInteractString = NPEV2_INTRO_QUESTGIVER_INTERACT_HORDE;
	StartingQuestGiverCreatureID = 166573;
	StartingQuestTargetDummyCreatureID = 160737;

	ShowMinimapQuest = 55122;
	
	UseMapQuest = 59929;

	FirstLootableCreatureID = {150228, 150229};

	ShowAllUIQuest = 59928;

	UseFoodQuest = 55174;
	FoodItem = 117;
	FoodSpellCast = 433;

	LookingForGroupQuest = 55992;
	
	GetMountQuest = 58909;

	SpecChoiceQuest = 59587;

	UseQuestItemData = {
		ScreenTutorialStringID = NPEV2_APPROACH_INJURED_CREWMEMBER;
		PointerTutorialStringID = NPE_USEQUESTITEM;
		ItemQuest = 59930;
		ItemTargets = {166786, 166791, 166796};
		TargetRange = 5;
		ItemSpell = 297415;
	};

	RemindUseQuestItemData = {
		ScreenTutorialStringID = NPEV2_APPROACH_WANDERING_BOAR;
		PointerTutorialStringID = NPE_USEQUESTITEM;
		ItemQuest = 59941;
		ItemTargets = {156716};
		TargetRange = 8;
		ItemSpell = 305716;
	};

	EnhancedCombatTacticsQuest = 59933;
	EnhancedCombatTacticsCreatureID = 164577;
	EnhancedCombatTacticsOverrideCreatureID = 164605;

	Mounts = {
		Orc = {
			mountItem = 2411,
			mountSpellID = 9;
			mountID = 9;
		},
		Scourge = {
			mountItem = 28481,
			mountSpellID = 9;
			mountID = 9;
		},
		Tauren = {
			mountItem = 13322,
			mountSpellID = 9;
			mountID = 9;
		},
		Troll = {
			mountItem = 5864,
			mountSpellID = 9;
			mountID = 9;
		},
		BloodElf = {
			mountItem = 73838,
			mountSpellID = 9;
			mountID = 9;
		},
		Goblin = {
			mountItem = 8629,
			mountSpellID = 9;
			mountID = 9;
		},
		Pandaren = {
			mountItem = 87800,
			mountSpellID = 9;
			mountID = 9;
		}
	};
}
