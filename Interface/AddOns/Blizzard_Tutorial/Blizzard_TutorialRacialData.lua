local _, addonTable = ...;

local TutorialData = {};
addonTable.TutorialData = TutorialData;

local SpecialCalloutRanges = {
	Short		= 7,
	Medium		= 12,
	Long		= 20,
	VeryLong	= 40,
}

-- class template
-- WARRIOR	= , --
-- PALADIN	= , --
-- HUNTER	= , --
-- ROGUE	= , --
-- PRIEST	= , --
-- SHAMAN	= , --
-- MAGE	= , --
-- WARLOCK	= , --
-- MONK	= , --
-- DRUID	= , --

TutorialData.StartingAbility = {
	WARRIOR	= 1464,		-- Slam
	PALADIN	= 35395,	-- Crusader Strike
	HUNTER	= 193455,	-- Cobra Shot
	ROGUE	= 1752,		-- Stab
	PRIEST	= 585,		-- Smite
	SHAMAN	= 188196,	-- Lightning Bolt
	MAGE	= 116,		-- Frostbolt
	WARLOCK	= 232670,	-- Shadow Bolt
	MONK	= 100780,	-- Tier Palm
	DRUID	= 190984,	-- Solar Wrath
}

TutorialData.Level3Ability = {
	WARRIOR	= 100,		-- Charge
	PALADIN	= 20271,	-- Judgement
	HUNTER	= 883,		-- Call Pet
	ROGUE	= 196819,	-- Eviscerate
	PRIEST	= 589,		-- Shadow Word: Pain
	SHAMAN	= 188389,	-- Flame Shock
	MAGE	= 108853,	-- Fire Blast
	WARLOCK	= 172,		-- Corruption
	MONK	= 100784,	-- Blackout Kick
	DRUID	= 8921,		-- Moonfire
}










-- ------------------------------------------------------------------------------------------------------------
TutorialData.Human = {
	-- First quest the player gets
	StartingQuest = { -- Beating Them Back!
		WARRIOR	= 28766,
		PALADIN	= 28762,
		HUNTER	= 28767,
		ROGUE	= 28764,
		PRIEST	= 28763,
		MAGE	= 28757,
		WARLOCK	= 28765,
		MONK	= 31139,
	};

	FirstKillQuestUnit = 49871; -- Blackrock Worg

	-- Training dummy quests, when you learn your second ability
	TrainingDummyID = 44548;
	TrainingQuest = {
		WARRIOR	= 26913, -- Charging into Battle
		PALADIN	= 26918, -- The Power of the Light
		HUNTER	= 26917, -- The Hunter's Path
		ROGUE	= 26915, -- The Deepest Cut
		PRIEST	= 26919, -- Learning the Word
		MAGE	= 26916, -- Mastering the Arcane
		WARLOCK	= 26914, -- Corruption
		MONK	= 31142, -- Palm of the Tiger
	};

	-- What quest complete to use the hearthstone to port back,
	-- usually the last quest in the starter area chain
	UseHearthstoneQuest = 26390; -- Ending the Invasion

	-- First quest that has you loot mobs for items
	LootQuest = {
		QuestID	= 26389, -- Blackrock Invasion
		UnitID	= 42937, -- Blackrock Invader
	};

	NPCInteractQuest = {
		{
			QuestID = { -- Fear no Evil
				HUNTER	= 28806,
				MAGE	= 28808,
				PALADIN	= 28809,
				PRIEST	= 28810,
				ROGUE	= 28811,
				WARLOCK	= 28812,
				WARRIOR	= 28813,
			},
			UnitID = 50047,
			Range = SpecialCalloutRanges.Short,
		},
	},

	-- Callout when you get near the target to use your quest item
	UseQuestItem = {
		{
			QuestID	= 26391, -- Extinguishing Hope
			UnitID	= 42940,
			SpellID	= 80199,
			Range	= SpecialCalloutRanges.Short,
		},
	};

	-- Quest bundles that the player should have all of at the same time
	MultiQuestPickup = {
		{
			-- They Sent Assassins
			{
				WARRIOR	= 28797,
				PALADIN	= 28793,
				HUNTER	= 28791,
				ROGUE	= 28795,
				PRIEST	= 28794,
				MAGE	= 28792,
				WARLOCK	= 28796,
			},
			-- Fear no Evil
			{
				WARRIOR	= 28813,
				PALADIN	= 28809,
				HUNTER	= 28806,
				ROGUE	= 28811,
				PRIEST	= 28810,
				MAGE	= 28808,
				WARLOCK	= 28812,
			},
		},
		{
			26389, -- Blackrock Invasion
			26391, -- Extinguishing Hope
		},
	};
}










-- ------------------------------------------------------------------------------------------------------------
TutorialData.Dwarf = {
	StartingQuest = 24469; -- Hold the Line!

	FirstKillQuestUnit = 37070; -- Rockjaw Invader

	TrainingDummyID = 44389;
	TrainingQuest = {
		WARRIOR	= 24531, -- Getting Battle-Ready
		PALADIN	= 24528, -- The Power of the Light
		HUNTER	= 24530, -- Oh, A Hunter's Life For Me
		ROGUE	= 24532, -- Evisceratin' the Enemy
		PRIEST	= 24533, -- Words of Power
		SHAMAN	= 24527, -- Your Path Begins Here
		MAGE	= 24526, -- Filling Up the Spellbook
		WARLOCK	= 26904, -- Corruption
		MONK	= 31151, -- Kick, Punch, It's All in the Mind
	};

	LootQuests = {
		{
			QuestID = 24486, -- Make Hay While the Sun Shines
			UnitID = 37105, -- Rockjaw Scavenger
		},
		{
		 	QuestID = 24475, -- All the Other Stuff
		 	UnitID = {
				708, -- Small Crag Boar
				704, -- Ragged Timber Wolf
				705, -- Ragged Young Wolf
			}
		},
	};

	LootFromObjectQuest = {
		{
			QuestID		= 24477, -- Dwarven Artifacts
			ObjectID	= 201608,
			Range		= SpecialCalloutRanges.Short,
		},
		{
			QuestID		= 24474, -- First Things First: We're Gonna Need Some Beer
			ObjectID	= { 201610, 201609, 201611 },
			Range		= SpecialCalloutRanges.Short,
		},
		{
			QuestID		= 24492, -- Pack Your Bags
			ObjectID	= { 201706, 201705, 201704 },
			Range		= SpecialCalloutRanges.Short,
		},
		{
			QuestID		= 3361, -- A Refugee's Quandry
			ObjectID	= { 148499, 178085, 178084 },
			Range		= SpecialCalloutRanges.Short,
		},
	},

	UseQuestItem = {
		{
			QuestID	= 24471, -- Aid for the Wounded
			UnitID	= 37080,
			SpellID	= 69855,
			Range	= SpecialCalloutRanges.Short,
		},
	};

	MultiQuestPickup = {
		{
			24470, -- Give'em What-For
			24471, -- Aid for the wounded
		},
		{
			24474, -- First Thing's First: We're gonna need some beer
			24477, -- Dwarven Artifacts
		},
		{
			182,   -- The Troll Menace
			24489, -- Trolling for information
			3361, -- A Refugee's Quandary
		}
	};

	UseHearthstoneQuest = {
		24475, -- All the Other Stuff
		24486, -- Make Hay While the Sun Shines
	};
}










-- ------------------------------------------------------------------------------------------------------------
TutorialData.NightElf = {
	StartingQuest = 28713; -- The Balance of Nature

	FirstKillQuestUnit = 2031; -- Young Nightsaber

	TrainingDummyID = 44614;
	TrainingQuest = {
		WARRIOR	= 26945, -- Learning New Techniques
		HUNTER	= 26947, -- A Woodsman's Training
		ROGUE	= 26946, -- A Rogue's Advantage
		PRIEST	= 26949, -- Learning the Word
		MAGE	= 26940, -- Frost Nova
		MONK	= 31169, -- The Art of the Monk
		DRUID	= 26948, -- Moonfire
	};

	LootQuest = {
		QuestID = 28714, -- Fel Moss Corruption
		UnitID = 1988, -- Grell
	};

	LootFromObjectQuest = {
		{
			QuestID		= 28715, -- Demonic Thieves
			ObjectID	= 195074,
			Range		= SpecialCalloutRanges.Short,
		},
		{
			QuestID		= 28724, -- Iverron's Antidote
			ObjectID	= 207346,
			Range		= SpecialCalloutRanges.Short,
		},
	},

	UseQuestItem = {
		{
			QuestID		= 28729, -- Teldrassil: Crown of Azeroth
			ObjectID	= 19549,
			SpellID		= 4976,
			Range		= SpecialCalloutRanges.Short,
		},
	};

	MultiQuestPickup = {
		{
			28715, -- Demonic Thieves
			28714, -- Fel Moss Corruption
		},
	};

	UseHearthstoneQuest = 28731; -- Teldrassil: Passing Awareness
	UseHearthstoneOnQuestStart = true;
}










-- ------------------------------------------------------------------------------------------------------------
TutorialData.Gnome = {
	StartingQuest = 27670; -- Pinned Down

	LootQuest = {
		QuestID = 26264, -- What's Left Behind
		UnitID = 42184, -- Toxic Sludge
	};

	TrainingDummyID = 44171;
	TrainingQuest = {
		WARRIOR	= 26204, -- The Arts of a Warrior
		ROGUE	= 26207, -- The Arts of a Rogue
		PRIEST	= 26200, -- The Arts of a Priest
		MAGE	= 26198, -- The Arts of a Mage
		WARLOCK	= 26201, -- The Arts of a Warlock
		MONK	= 31138, -- The Arts of a Monk
	};

	UseQuestObject = {
		{
			QuestID		= 27635, -- Decontamination
			UnitID		= 46185,
			Range		= SpecialCalloutRanges.Long,
		},
		{
			QuestID		= 26318, -- Finishing the Job
			ObjectID	= 204042,
			Range		= SpecialCalloutRanges.Short,
		},
	};

	UseQuestItem = {
		{
			QuestID	= 27671, -- See to the Survivors
			UnitID	= 46268,
			SpellID	= 86264,
			Range	= SpecialCalloutRanges.Long,
		},
		{
			QuestID	= 26333, -- No Tanks!
			UnitID	= 42224,
			SpellID	= 79751,
			Range	= SpecialCalloutRanges.Long,
		},
		{
			QuestID	= 26078, -- Extinguish the Fires
			UnitID	= 42046,
			SpellID	= 78369,
			Range	= SpecialCalloutRanges.Medium,
		},
	};

	MultiQuestPickup = {
		{
			26264, -- What's Left Behind
			26205, -- A Job for the Multi-Bot
		},
	};

	UseHearthstoneQuest = 26329; -- One More Thing
	UseHearthstoneOnQuestStart = true;
}










-- ------------------------------------------------------------------------------------------------------------
TutorialData.Draenei = {
	StartingQuest = 9279; -- You Survived

	FirstKillQuest = 9280; -- Replenishing the Healing Crystals
	FirstKillQuestUnit = 16520; -- Vale Moth

	LootQuest = {
		QuestID = 9293, -- What Must Be Done...
		UnitID = 16517, -- Mutated Root Lasher
	};

	TrainingDummyID = 44703;
	TrainingQuest = {
		WARRIOR	= 26958, -- Your First Lesson
		PALADIN	= 26966, -- The Light's Power
		HUNTER	= 26963, -- Steadying Your Shot
		PRIEST	= 26970, -- Learning the Word
		SHAMAN	= 26969, -- Primal Strike
		MAGE	= 26968, -- Frost Nova
		MONK	= 31173, -- The Tiger Palm
	};

	LootFromObjectQuest = {
		{
			QuestID		= 9799, -- Botanical Legwork
			ObjectID	= 182127, -- Corrupted Flower
			Range		= SpecialCalloutRanges.Short,
		},
		{
			QuestID		= 37445, -- Spare Parts
			ObjectID	= 181283,
			Range		= SpecialCalloutRanges.Short,
		},
	};

	UseQuestItem = {
		{
			QuestID	= 37444, -- Inoculation
			UnitID	= 16518,
			SpellID	= 29528,
			Range	= SpecialCalloutRanges.Medium,
		},
		{
			QuestID		= 9294, -- Healing the Lake
			ObjectID	= 181433,
			SpellID		= 28700,
			Range		= SpecialCalloutRanges.VeryLong,
		},
	};

	MultiQuestPickup = {
		{
			9799, -- Botanical Legwork
			9293, -- What Must Be Done...
		},
		{
			37444, -- Inoculation
			37445, -- Spare Parts
		},
	};

	UseHearthstoneQuest = 9311; -- Blood Elf Spy

	Custom_QuestAccept = {
		[9283] = true, -- Rescue the Survivors!
	};
}










-- ------------------------------------------------------------------------------------------------------------
TutorialData.Worgen = {
	StartingQuest = 14078; -- Lockdown!

	FirstKillQuest = 14093; -- All Hell Breaks Loose
	FirstKillQuestUnit = 34884; -- Rampaging Worgen

	TrainingDummyID = 35118; -- Bloodfang Worgen (not actually a training dummy!)
	TrainingQuest = {
		WARRIOR	= 14266, -- Charge
		HUNTER	= 14276, -- Steady Shot
		ROGUE	= 14272, -- Eviscerate
		PRIEST	= 14279, -- Learning the Word
		MAGE	= 14281, -- Frost Nova
		WARLOCK	= 14274, -- Corruption
		DRUID	= 14283, -- Moonfire
	};

	LootFromObjectQuest = {
		{
			QuestID		= 14094, -- Salvage the Supplies
			ObjectID	= 195306,
			Range		= SpecialCalloutRanges.Short,
		},
		{
			QuestID		= 14348, -- You Can't Take 'Em Alone
			ObjectID	= 196403, -- Black Gunpowder Keg
			Range		= SpecialCalloutRanges.Short,
		},
	};

	MultiQuestPickup = {
		{
			14157, -- Old Divisions
			24930, -- While You're at It
		},
		{
			14347, -- Hold the Line
			14348, -- You Can't Take 'em Alone
		},
		{
			14368, -- Save the Children!
			14382, -- Two By Sea
			14369, -- Unleash the Beast
		},
	};

	UseQuestObject = {
		{
			QuestID		= 14098, -- Evacuate the Merchant Square
			ObjectID	= 195327, -- Merchant Square Door
			Range		= SpecialCalloutRanges.Short,
		},
	};

	UseQuestItem = {
		{
			QuestID		= 14348, -- You Can't Take 'Em Alone
			UnitID		= 36231, -- Horrid Abomination
			SpellID		= 69094, -- Toss Keg
			Range		= SpecialCalloutRanges.Medium,
		},
		{
			QuestID		= 14386; -- Leader of the Pack
			UnitID		= 36312, -- Dark Ranger Thyala
			SpellID		= 68682, -- Call Attack Mastiffs
			Range		= SpecialCalloutRanges.Long,
		},
	};

	NPCInteractQuest = {
		{
			QuestID	= 14368; -- Save the Children!
			UnitID	= { 36289, 36288, 36287 }, -- James, Ashley, Cynthia
			Range	= SpecialCalloutRanges.Short,
		},
	},

	UseHearthstoneQuest = 14397; -- Evacuation
	UseHearthstoneOnQuestStart = true;
}










-- ------------------------------------------------------------------------------------------------------------
TutorialData.Pandaren = {
	StartingQuest = { -- The Lesson of the Iron Bough
		WARRIOR	= 30038,
		HUNTER	= 30034,
		ROGUE	= 30036,
		PRIEST	= 30035,
		SHAMAN	= 30037,
		MAGE	= 30033,
		MONK	= 30027,
	};

	FirstKillQuest = 29406; -- The Lesson of the Sandy Fist

	LootFromObjectQuest = {
		{
			QuestID		= { -- The Lesson of the Iron Bough
				WARRIOR	= 30038,
				HUNTER	= 30034,
				ROGUE	= 30036,
				PRIEST	= 30035,
				SHAMAN	= 30037,
				MAGE	= 30033,
				MONK	= 30027,
			},
			ObjectID	= { 210005, 210015, 210016, 210017, 210018, 210019, 210020, }, -- Monk, Mage, Hunter, Priest, Rogue, Shaman, Warrior (this isn't a class filter because a table means something else in this context... hackyish but it works)
			Mode		= NPE_RangeManager.Mode.Any,
			Range		= SpecialCalloutRanges.Short,
		},
		{
			QuestID		= 29418, -- Kindling the Fire
			ObjectID	= { 209326, 209327 }, -- Loose Dogwood Root
			Mode		= NPE_RangeManager.Mode.Any,
			Range		= SpecialCalloutRanges.Short,
		},
	};

	MultiQuestPickup = {
		{
			29419, -- The Missing Driver
			29424, -- Items of Utmost Importance
		},
		{
			29523; -- Fanning the Flames
			29418; -- Kindling the Fire
		}
	};

	UseQuestObject = {
		{
			QuestID		= 29408, -- The Lesson of the Burning Scroll
			ObjectID	= 210986, -- Edict of Temperance
			Range		= SpecialCalloutRanges.Short,
		},
	};

	LootQuests = {
		{
			QuestID	= 29424, -- Items of Utmost Importance
			UnitID	= 54130, -- Amberleaf Scamp
		},
		{
			QuestID	= 29523, -- Fanning the Flames
			UnitID	= 54631, -- Living Air
		},
	};

	UseQuestItem = {
		{
			QuestID		= 29523, -- Fanning the Flames
			ObjectID	= 210122,
			SpellID		= 80199,
			Range		= SpecialCalloutRanges.Short,
		},
		{
			QuestID		= 29422, -- Huo, the Spirit of Fire
			UnitID		= 57779, -- Huo
			SpellID		= 102522, -- Fan the Flames
			Range		= SpecialCalloutRanges.Medium,
		},
	};
}










-- ------------------------------------------------------------------------------------------------------------
TutorialData.Orc = {
	StartingQuest = 25152; -- Your Place in the World

	FirstKillQuest = 25126; -- Cutting Teeth
	FirstKillQuestUnit = 3098; -- Mottled Boar

	TrainingDummyID = 44820;
	TrainingQuest = {
		WARRIOR	= 25147, -- Charge
		HUNTER	= 25139, -- Steady Shot
		ROGUE	= 25141, -- Eviscerate
		SHAMAN	= 25143, -- Primal Strike
		MAGE	= 25149, -- Frost Nova
		WARLOCK	= 25145, -- Corruption
		MONK	= 31157, -- Tiger Palm
	};

	LootQuest = {
		QuestID	= 25127, -- Sting of the Scorpid
		UnitID	= 3124, -- Scorpid Worker
	};

	UseQuestItem = {
		{
			QuestID	= 37446, -- Lazy Peons
			UnitID	= 10556,
			SpellID	= 19938,
			Range	= SpecialCalloutRanges.Short,
		},
	};

	LootFromObjectQuest = {
		{
			QuestID		= 25136, -- Galgar's Cactus Apple Surprise
			ObjectID	= 171938,
			Range		= SpecialCalloutRanges.Short,
		},
		{
			QuestID		= 25135, -- Thazz'ril's Pick
			ObjectID	= 178087,
			Range		= SpecialCalloutRanges.Short,
		},
	};

	MultiQuestPickup = {
		{
			25136, -- Galgar's Cactus Apple Surprise
			25172, -- Invaders in Our Home
		},
		{
			25134, -- Lazy Peons
			25131, -- Vile Familiars
		},
		{
			25135, -- Thazz'ril's Pick
			25132, -- Burning Blade Medallion
		}
	};

	UseHearthstoneQuest = {
		25135, -- Thazz'ril's Pick
		25132, -- Burning Blade Medallion
	};
}










-- ------------------------------------------------------------------------------------------------------------
TutorialData.Scourge = {
	StartingQuest = 24959; -- Fresh out of the Grave

	FirstKillQuest = 26799; -- Those That Couldn't Be Saved
	FirstKillQuestUnit = 1501; -- Mindless Zombie

	TrainingDummyID = 44794;
	TrainingQuest = {
		WARRIOR	= 24969, -- Charging into Battle
		HUNTER	= 24964, -- The Thrill of the Hunt
		ROGUE	= 24967, -- Stab!
		PRIEST	= 24966, -- Of Light and Shadows
		MAGE	= 24965, -- Magic Training
		WARLOCK	= 24968, -- Dark Deeds
		MONK	= 31147, -- Tiger Palm
	};

	LootQuest = {
		QuestID = 26802, -- The Damned
		UnitID = { 1513, 1509 } -- Mangy Duskbat, Ragged Scavenger
	};

	LootFromObjectQuest = {
		{
			QuestID		= 28608, -- The Shadow Grave
			ObjectID	= { 207255, 207256 },
			Range		= SpecialCalloutRanges.Short,
		},
	};

	NPCInteractQuest = {
		{
			QuestID = 26800, -- Recruitment
			UnitID = 49340,
			Range = SpecialCalloutRanges.Short,
		},
	},

	MultiQuestPickup = {
		{
			26801, -- Scourge on our Perimeter
			26800, -- Recruitment
		},
		{
			24975, -- Fields of Grief
			24978, -- Reaping the Reapers
		}
	};

	InteractThenGossipQuest = {
		{
			QuestID = 24961, -- The Truth of the Grave
			UnitID	= 38910,
			Range	= SpecialCalloutRanges.Short,
		},
		{
			QuestID = 24960, -- The Wakening
			UnitID	= { 38895, 49230, 49231 },
			Range	= SpecialCalloutRanges.Short,
		},
	};

	UseHearthstoneQuest = 24971; -- Assault on the Rotbrain Encampment
}










-- ------------------------------------------------------------------------------------------------------------
TutorialData.Tauren = {
	StartingQuest = 14449; -- The First Step

	FirstKillQuest = 14452; -- Rite of Strength
	FirstKillQuestUnit = 36943; -- Bristleback Invader

	TrainingDummyID = 44848;
	TrainingQuest = {
		WARRIOR	= 27020, -- The First Lesson
		PALADIN	= 27023, -- The Way of the Sunwalkers
		HUNTER	= 27021, -- The Hunter's Path
		PRIEST	= 27066, -- Learning the Word
		SHAMAN	= 27027, -- Primal Strike
		MONK	= 31166, -- Tiger Palm
		DRUID	= 27067, -- Moonfire
	};

	LootQuest = {
		QuestID = 14456, -- Rite of Courage
		UnitID = 36708, -- Bristleback Gun Thief
	};

	UseQuestObject = {
		QuestID		= 24852, -- Our Tribe, Imprisoned
		ObjectID	= 202112,
		Range		= SpecialCalloutRanges.Short,
	};

	UseQuestItem = {
		{
			QuestID	= 14461, -- Feed of Evil
			UnitID	= { 36727, 37155, 37156 },
			SpellID	= 69228,
			Range	= SpecialCalloutRanges.Short,
		},
	};

	MultiQuestPickup = {
		{
			14455, -- Stop the Thorncallers
			14456, -- Rite of Courage
		},
		{
			14461, -- Feed of Evil
			14459, -- The Battleboars
		}
	};

	UseHearthstoneQuest = 14460; -- Rite of Honor
}










-- ------------------------------------------------------------------------------------------------------------
TutorialData.Troll = {
	StartingQuest = { -- The Rise of the Darkspear
		WARRIOR	= 24607,
		HUNTER	= 24776,
		ROGUE	= 24770,
		PRIEST	= 24782,
		MAGE	= 24750,
		SHAMAN	= 24758,
		WARLOCK	= 26272,
		MONK	= 31159,
		DRUID	= 24764,
	};

	FirstKillQuest = { -- The Basics: Hitting Things
		WARRIOR	= 24639,
		HUNTER	= 24777,
		ROGUE	= 24771,
		PRIEST	= 24783,
		MAGE	= 24751,
		SHAMAN	= 24759,
		WARLOCK	= 26273,
		MONK	= 31158,
		DRUID	= 24765,
	};
	FirstKillQuestUnit = 38038; -- Tiki Target

	TrainingDummyID = 38038;
	TrainingQuest = {
		WARRIOR	= 24640, -- The Arts of a Warrior
		HUNTER	= 24778, -- The Arts of a Hunter
		ROGUE	= 24772, -- The Arts of a Rogue
		PRIEST	= 24784, -- The Arts of a Priest
		SHAMAN	= 24760, -- The Arts of a Shaman
		MAGE	= 24752, -- The Arts of a Mage
		WARLOCK	= 26274, -- The Arts of a Warlock
		MONK	= 31162, -- The Arts of a Monk
		DRUID	= 24766, -- The Arts of a Druid
	};

	UseQuestItem = {
		{
			QuestID		= 24813, -- Territorial Fetish
			ObjectID	= 202113,
			SpellID		= 72070,
			Range		= SpecialCalloutRanges.Short,
		},
	};

	MultiQuestPickup = {
		{
			24625, -- Consort of the Sea Witch
			24624, -- Mercy for the Lost
			24623, -- Saving the Young
		},
		{
			24813, -- Territorial Fetish
			24812, -- No More Mercy
		},
	};

	InteractThenGossipQuest = {
		{
			QuestID = { -- Proving Pit
				WARRIOR	= 24642,
				HUNTER	= 24780,
				ROUGE	= 24774,
				PRIEST	= 24786,
				SHAMAN	= 24762,
				MAGE	= 24754,
				WARLOCK	= 26276,
				MONK	= 31161,
				DRUID	= 24768,
			},
			UnitID	= 39062,
			Range	= SpecialCalloutRanges.Short,
		},
	};

	UseHearthstoneQuest = 24814; -- An Ancient Enemy
}










-- ------------------------------------------------------------------------------------------------------------
TutorialData.BloodElf = {
	StartingQuest = 8325; -- Reclaiming Sunstrider Isle
	FirstKillQuestUnit = 15274; -- Mana Wyrm

	TrainingDummyID = 44937;
	TrainingQuest = {
		WARRIOR	= 27091, -- Charge!
		PALADIN	= 10069, -- Ways of the Light
		HUNTER	= 10070, -- Steady Shot
		ROGUE	= 10071, -- Evisceration
		PRIEST	= 10072, -- Learning the Word
		MAGE	= 10068, -- Frost Nova
		WARLOCK	= 10073, -- Corruption
		MONK	= 31171, -- Tiger Palm
	};

	UseQuestObject = {
		{
			QuestID		= 37442, -- The Shrine of Dath'Remar
			ObjectID	= 180516,
			Range		= SpecialCalloutRanges.Medium,
		},
	};

	LootQuest = {
		QuestID = 8326, -- Unfortunate Measures
		UnitID = 15366, -- Springpaw Cub
	};

	LootFromObjectQuest = {
		{
			QuestID		= 37443, -- Solanian's Belongings
			ObjectID	= { 180510, 180511, 180512 },
			Range		= SpecialCalloutRanges.Short,
		},
	};

	MultiQuestPickup = {
		{
			8468, -- Wanted: Thaelis the Hungerer
			8463, -- Unstable Mana Crystals
			8472, -- Major Malfunction
		},
	};

	UseHearthstoneQuest = 8335; -- Felendren the Banished

	Custom_QuestAccept = {
		[8346] = true, -- Rescue the Survivors!
	};
}










-- ------------------------------------------------------------------------------------------------------------
TutorialData.Goblin = {

	StartingQuest = 14138; -- Taking Care of Business

	FirstKillQuest = 14075; -- Trouble in the Mines
	FirstKillQuestUnit = 34865; -- Tunneling Worm

	TrainingDummyID = 48304;
	TrainingQuest = {
		WARRIOR = 14013, -- Charge
		HUNTER  = 14007, -- Steady Shot
		ROGUE	= 14010, -- Eviscerate
		PRIEST  = 14009, -- Learning the Word
		SHAMAN	= 14011, -- Steady Shot
		MAGE	= 14008, -- Frost Nova
		WARLOCK	= 14012, -- Corruption
	};

	NPCInteractQuest = {
		{
			QuestID = 14069; -- Good Help is Hard to Find
			UnitID = 34830, -- Defiant Troll
			Range = SpecialCalloutRanges.Short,
		},
	},

	LootFromObjectQuest = {
		{
			QuestID		= 24488, -- the Replacements
			ObjectID	= 201603,
			Range		= SpecialCalloutRanges.Short,
		},
	};

	MultiQuestPickup = {
		{
			14075, -- Trouble in the Mines
			14069, -- Good Help is Hard to Find
		},
		{
			24567, -- Report for Tryouts
			14070, -- Do it Yourself
			( UnitSex("player") == 2 and 26712 or 26711 ), -- Off to the Bank (M, F) Not the most elegant way to do this, but it works since it's a unique case
		},
	};

	InteractThenGossipQuest = {
		{
			QuestID = 14110; -- The New You
			UnitID	= { 35128, 35126, 35130 }, -- Szabo, Gappy Silvertooth, Missa Spekkies
			Range	= SpecialCalloutRanges.Short,
		},
	};

	UseQuestItem = {
		{
			QuestID	= 14071, -- Rolling with my Homies
			UnitID	= 34874, -- Megs Dreadshredder
			SpellID	= 66393, -- Rolling with my Homies: Summon Hot Rod
			Range	= SpecialCalloutRanges.Medium,
		},
		{
			QuestID	= 14124, -- Liberate the Kajamite
			ObjectID = 195488,
			SpellID	= 67682,
			Range	= SpecialCalloutRanges.Short,
		},
	};


	UseHearthstoneQuest = 14124; -- Liberate the Kajamite
}