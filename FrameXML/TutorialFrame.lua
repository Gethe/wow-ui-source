local MAX_TUTORIAL_VERTICAL_TILE = 30;
local MAX_TUTORIAL_IMAGES = 3;
local MAX_TUTORIAL_KEYS = 4;

local TUTORIALFRAME_TOP_HEIGHT = 80;
local TUTORIALFRAME_MIDDLE_HEIGHT = 10;
local TUTORIALFRAME_BOTTOM_HEIGHT = 30;
local TUTORIALFRAME_WIDTH = 364;

local TUTORIAL_LAST_ID = nil;

local ARROW_TYPES = {
	"ArrowUp", "ArrowDown", "ArrowLeft", "ArrowRight",
	"ArrowCurveUpRight", "ArrowCurveUpLeft", "ArrowCurveDownRight", "ArrowCurveDownLeft",
	"ArrowCurveRightDown", "ArrowCurveRightUp", "ArrowCurveLeftDown", "ArrowCurveLeftUp",
}

local ARROW_SIZES = {
	["ArrowUp"] = {x = 68, y = 89},
	["ArrowDown"] = {x = 68, y = 89},
	["ArrowLeft"] = {x = 89, y = 68},
	["ArrowRight"] = {x = 89, y = 68},
	["ArrowCurveUpRight"] = {x = 66, y = 81},
	["ArrowCurveUpLeft"] = {x = 66, y = 81},
	["ArrowCurveDownRight"] = {x = 66, y = 81},
	["ArrowCurveDownLeft"] = {x = 66, y = 81},
	["ArrowCurveRightDown"] = {x = 82, y = 66},
	["ArrowCurveRightUp"] = {x = 82, y = 66},
	["ArrowCurveLeftDown"] = {x = 82, y = 66},
	["ArrowCurveLeftUp"] = {x = 82, y = 66},
}

local MOUSE_SIZE = { x = 76, y = 101}

local TUTORIALFRAME_QUEUE = { };

local TUTORIAL_DATA = {
	[1] = "QuestGiver",
	[2] = "Movement",
	[3] = "LookAround",
	[4] = "QuestGiver",
	[5] = "Combat1",
	[6] = "Spells",
	[7] = "LootPig",
	[8] = "LootedItem",
	[9] = "OnUseItem",
	[10] = "Bags",
	[11] = "Food",
	[12] = "Drink",
	[13] = "Talents",
	[14] = "Trainer",
	[15] = "SpellBook",
	[16] = "Rep",
	[17] = "Reply",
	[18] = "Grouping",
	[19] = "Players",
	[20] = "Vendor",
	[21] = "QuestLog",
	[22] = "Friends",
	[24] = "Equip",
	[25] = "Death",
	[27] = "Fat",
	[28] = "Swim",
	[29] = "Breath",
	[30] = "Resting",
	[31] = "Hearthstones",
	[32] = "Pvp",
	[33] = "Jumping",
	[34] = "QuestComplete",
	[35] = "Travel",
	[36] = "DamagedItems",
	[37] = "BrokenItems",
	[38] = "Professions",
	[39] = "Groups",
	[40] = "Spellbook2",
	[41] = "LeetQuests",
	[42] = "Welcome",
	[43] = "QuestGray",
	[44] = "Ranged",
	[45] = "Ammo",
	[46] = "RaidGroups",
    [47] = "TotemBar",
	[48] = "Battleground1",
	[49] = "Battleground2",
	[50] = "Keyring",
	[51] = "LFG",
	[52] = "CosmeticPets",
	[53] = "Mounts",
	[54] = "ThreatWarnings",
	[55] = "Ding",
	[56] = "HealthManaBar",
    [57] = "EnemyHealth",
    [58] = "FullBags",
	[59] = "FreeingUpBags",
	[60] = "Hotbar",
};

local DISPLAY_DATA = {
	-- Do not remove "Base" it is the default
	["Base"] = {
		tileHeight = 7, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	["BaseTall"] = {
		tileHeight = 12, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},

	-- layers can be BACKGROUND, BORDER, ARTWORK, OVERLAY, HIGHLIGHT
	-- if you don't assign one it will default to ARTWORK
	["QuestGiver"] = {
		tileHeight = 21, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -100},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -180, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-QuestCursor", align = "TOP", xOff = 0, yOff = -110},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-QuestGiver", align = "TOP", xOff = -40, yOff = -50},
		mouseData = {image = "RightClick", align = "TOP", xOff = 80, yOff = -60},
	},
	
	["Movement"] = {
		tileHeight = 18, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -200, bottomRight_xOff = -29, bottomRight_yOff = 35},
		keyData1 = {command = "TURNLEFT", layer = "OVERLAY", align = "TOPLEFT", xOff = 105, yOff = -100},
		keyData2 = {command = "MOVEBACKWARD", layer = "OVERLAY", align = "TOPLEFT", xOff = 160, yOff = -100},
		keyData3 = {command = "TURNRIGHT", layer = "OVERLAY", align = "TOPLEFT", xOff = 215, yOff = -100},
		keyData4 = {command = "MOVEFORWARD", align = "TOPLEFT", xOff = 160, yOff = -60},
		ArrowUp = {layer = "BORDER", align = "TOPLEFT", xOff = 182, yOff = -40, scale = 0.5},
		ArrowDown = {layer = "ARTWORK", align = "TOPLEFT", xOff = 182, yOff = -150, scale = 0.5},
		ArrowRight = {layer = "ARTWORK", align = "TOPLEFT", xOff = 270, yOff = -120, scale = 0.5},
		ArrowLeft = {layer = "ARTWORK", align = "TOPLEFT", xOff = 83, yOff = -120, scale = 0.5},
	},
	
	["Moved"] = {
		tileHeight = 20, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -185, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-QuestCursor", align = "CENTER", xOff = 0, yOff = 10},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-QuestGiver", align = "CENTER", xOff = -40, yOff = 30},
		mouseData = {image = "RightClick", align = "CENTER", xOff = 80, yOff = 30},
	},
	
	["Ding"] = {
		tileHeight = 22, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		callOut	= {parent = "PlayerFrame", align = "TOPLEFT", xOff = 34, yOff = -6, width = 78, height = 78},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -215, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-LevelUp", align = "TOP", xOff = 10, yOff = -30},
	},
	
	["OnUseItem"] = {
		tileHeight = 21, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 70},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -200, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-OnUseItem", align = "TOP", xOff = -35, yOff = -70},
		mouseData = {image = "RightClick", align = "TOP", xOff = 110, yOff = -85},
	},
	
	["LootedItem"] = {
		tileHeight = 21, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 70},
		callOut	= {parent = "MainMenuBarBackpackButton", align = "TOPLEFT", xOff = -5, yOff = 5, width = 50, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -190, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-LootedItem", align = "TOP", xOff = 5, yOff = -55},
	},
	
	["LootPig"] = {
		tileHeight = 24, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 90},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -195, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-LootCorpse", align = "TOP", xOff = -60, yOff = -13},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-LootCursor", align = "TOP", xOff = 40, yOff = -90},
		mouseData = {image = "RightClick", align = "TOP", xOff = 110, yOff = -65},
	},

	["Spells"] = {
		tileHeight = 15, 
		anchorData = {align = "LEFT", xOff = 15, yOff = -200},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -120, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Spell01", align = "TOP", xOff = -60, yOff = -50},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Spell02", align = "TOP", xOff = 10, yOff = -50},
		imageData3 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Spell03", align = "TOP", xOff = 80, yOff = -50},
	},

	["Combat1"] = {
		tileHeight = 19, 
		anchorData = {align = "LEFT", xOff = 15, yOff = -150},
		callOut	= {parent = "MainMenuBar", align = "TOPLEFT", xOff = -5, yOff = -5, width = 525, height = 50},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -145, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-AttackCursor", align = "TOP", xOff = -60, yOff = -60},
		mouseData = {image = "LeftClick", align = "TOP", xOff = 50, yOff = -45},
	},

	["LookAround"] = {
		tileHeight = 18, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -175, bottomRight_xOff = -29, bottomRight_yOff = 35},
		mouseData = {layer = "OVERLAY", image = "RightClick", align = "TOP", xOff = 15, yOff = -55},
		ArrowUp = {align = "TOPLEFT", xOff = 182, yOff = -40, scale = 0.5},
		ArrowDown = {align = "TOPLEFT", xOff = 182, yOff = -125, scale = 0.5},
		ArrowRight = {align = "TOPLEFT", xOff = 210, yOff = -90, scale = 0.5},
		ArrowLeft = {align = "TOPLEFT", xOff = 140, yOff = -90, scale = 0.5},
--		ArrowCurveUpLeft = {layer = "OVERLAY", align = "TOPRIGHT", xOff = -215, yOff = -55, scale = 0.5},
--		ArrowCurveUpRight = {layer = "OVERLAY", align = "TOPRIGHT", xOff = -70, yOff = -55, scale = 0.5},
	},
	
	["Hotbar"] = {
		tileHeight = 14, 
		anchorData = {align = "LEFT", xOff = 15, yOff = -150},
		callOut	= {parent = "MainMenuBar", align = "TOPLEFT", xOff = -5, yOff = -5, width = 525, height = 50},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -120, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Spell01", align = "TOP", xOff = -60, yOff = -50},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Spell02", align = "TOP", xOff = 10, yOff = -50},
		imageData3 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Spell03", align = "TOP", xOff = 80, yOff = -50},
	},

	["SpellBook"] = {
		tileHeight = 28, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -130},
		callOut	= {parent = "SpellbookMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Spellbook", align = "TOP", xOff = 10, yOff = -50},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -225, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},	
	
	["Death"] = {
		tileHeight = 22, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 70},
		callOut	= {parent = "Minimap", align = "TOPLEFT", xOff = -8, yOff = 0, width = 151, height = 145},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -185, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-SpiritRez", align = "TOP", xOff = 10, yOff = -50},
	},	
	
	["Resting"] = {
		tileHeight = 11, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 150},
		callOut	= {parent = "PlayerFrame", align = "TOPLEFT", xOff = 32, yOff = -4, width = 85, height = 85},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},

	["Hearthstones"] = {
		tileHeight = 10, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -120, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Hearthstone", align = "TOP", xOff = 10, yOff = -50},
	},	

	["Pvp"] = {
		tileHeight = 10, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 150},
		callOut	= {parent = "PlayerFrame", align = "TOPLEFT", xOff = 34, yOff = -6, width = 78, height = 78},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},	
	
	["Jumping"] = {
		tileHeight = 7, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},	
	
	["QuestComplete"] = {
		tileHeight = 24, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 60},
		callOut	= {parent = "Minimap", align = "TOPLEFT", xOff = -8, yOff = 0, width = 151, height = 145},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -185, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-QuestCompleteCursor", align = "TOP", xOff = 0, yOff = -110},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-QuestComplete", align = "TOP", xOff = -40, yOff = -50},
		mouseData = {image = "RightClick", align = "TOP", xOff = 80, yOff = -60},
	},
	
	["Travel"] = {
		tileHeight = 25, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -195, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-FlightCursor", align = "TOP", xOff = 0, yOff = -110},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-FlightMaster", align = "TOP", xOff = -40, yOff = -50},
		mouseData = {image = "RightClick", align = "TOP", xOff = 80, yOff = -60},
	},	
	
	["DamagedItems"] = {
		tileHeight = 17, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -20},
		callOut	= {parent = "DurabilityFrame", align = "TOPLEFT", xOff = 0, yOff = 8, width = 58, height = 90},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -150, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-RepairCursor", align = "TOP", xOff = 0, yOff = -60},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-TheDude", align = "TOP", xOff = -40, yOff = -10},
		mouseData = {image = "RightClick", align = "TOP", xOff = 80, yOff = -40},
	},
	
	["BrokenItems"] = {
		tileHeight = 18, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -20},
		callOut	= {parent = "DurabilityFrame", align = "TOPLEFT", xOff = 0, yOff = 8, width = 58, height = 90},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -150, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-RepairCursor", align = "TOP", xOff = 0, yOff = -60},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-TheDude", align = "TOP", xOff = -40, yOff = -10},
		mouseData = {image = "RightClick", align = "TOP", xOff = 80, yOff = -40},
	},
	
--	["Professions"] = {
--		tileHeight = 11, 
--		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
--		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
--	},
	
	["Groups"] = {
		tileHeight = 11, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	["Spellbook2"] = {
		tileHeight = 28, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -130},
		callOut	= {parent = "SpellbookMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Spellbook", align = "TOP", xOff = 10, yOff = -50},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -225, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	["LeetQuests"] = {
		tileHeight = 21, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Elite", align = "TOP", xOff = 10, yOff = -50},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -160, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	["Welcome"] = {
		tileHeight = 22, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -180, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Logo", align = "TOP", xOff = 10, yOff = -50},
	},
	
	["RaidGroups"] = {
		tileHeight = 14, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},

	["TotemBar"] = {
		tileHeight = 12, 
		anchorData = {align = "LEFT", xOff = 15, yOff = -150},
		callOut	= {parent = "MultiCastActionBarFrame", align = "TOPLEFT", xOff = -5, yOff = 4, width = 45, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	["CosmeticPets"] = {
		tileHeight = 11, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -150},
		callOut	= {parent = "CharacterMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	["Mounts"] = {
		tileHeight = 13, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -150},
		callOut	= {parent = "CharacterMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	["ThreatWarnings"] = {
		tileHeight = 19, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -150, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Threat", align = "TOP", xOff = 10, yOff = -50},
	},
	
	["HealthManaBar"] = {
		tileHeight = 19, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 150},
		callOut	= {parent = "PlayerFrame", align = "TOPLEFT", xOff = 100, yOff = -33, width = 135, height = 40},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -125, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-DudeFull", align = "TOP", xOff = 10, yOff = -35},
	},
	
	["FullBags"] = {
		tileHeight = 22, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 70},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -185, bottomRight_xOff = -29, bottomRight_yOff = 35},
		callOut	= {parent = "MainMenuBarBackpackButton", align = "TOPLEFT", xOff = -5, yOff = 5, width = 50, height = 45},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-FullBackpack", align = "TOP", xOff = -22, yOff = -55},
    },
	
    ["EnemyHealth"] = {
        tileHeight = 13, 
        anchorData = {align = "LEFT", xOff = 15, yOff = 150},
        textBox = {topLeft_xOff = 33, topLeft_yOff = -125, bottomRight_xOff = -29, bottomRight_yOff = 35},
--      callOut  = {parent = "TargetFrame", align = "TOPLEFT", xOff = -5, yOff = -34, width = 140, height = 38},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-EnemyHealth", align = "TOP", xOff = 10, yOff = -35},
    },
	
	["FreeingUpBags"] = {
		tileHeight = 24, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 70},
		callOut	= {parent = "MainMenuBarBackpackButton", align = "TOPLEFT", xOff = -5, yOff = 5, width = 50, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -185, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-FullBackpack", align = "TOP", xOff = -70, yOff = -65},
		mouseData = {image = "RightClick", align = "TOP", xOff = 110, yOff = -65},
    },
	
	["Bags"] = {
		tileHeight = 13,
		anchorData = {align = "RIGHT", xOff = -25, yOff = 50},
		callOut	= {parent = "MainMenuBarBackpackButton", align = "TOPLEFT", xOff = -150, yOff = 5, width = 200, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -125, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Bag", align = "TOP", xOff = -60, yOff = -50},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Bag02", align = "TOP", xOff = 10, yOff = -50},
		imageData3 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Bag03", align = "TOP", xOff = 80, yOff = -50},
    },
	
	["Talents"] = {
		tileHeight = 9, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -150},
		callOut	= {parent = "TalentMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	["Rep"] = {
		tileHeight = 8, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -150},
		callOut	= {parent = "CharacterMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	["Reply"] = {
		tileHeight = 6, 
		anchorData = {align = "LEFT", xOff = 25, yOff = -50},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	["Players"] = {
        tileHeight = 11, 
        anchorData = {align = "LEFT", xOff = 50, yOff = 150},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -135, bottomRight_xOff = -29, bottomRight_yOff = 35},
--      callOut  = {parent = "TargetFrame", align = "TOPLEFT", xOff = -5, yOff = -5, width = 210, height = 80},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-DudeParty", align = "TOP", xOff = 0, yOff = -40},
    },
	
	["QuestLog"] = {
		tileHeight = 10, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -150},
		callOut	= {parent = "QuestLogMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	["Friends"] = {
		tileHeight = 10, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -150},
		callOut	= {parent = "SocialsMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	["Equip"] = {
		tileHeight = 25, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 70},
		callOut	= {parent = "CharacterMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-EquipItem", align = "TOP", xOff = 10, yOff = -15},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -225, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	["Battleground1"] = {
		tileHeight = 7, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 70},
		callOut	= {parent = "Minimap", align = "TOPLEFT", xOff = -8, yOff = 0, width = 151, height = 145},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},

	["Battleground2"] = {
		tileHeight = 7, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 70},
		callOut	= {parent = "Minimap", align = "TOPLEFT", xOff = -8, yOff = 0, width = 151, height = 145},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},	
	
	["Keyring"] = {
		tileHeight = 7, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -150},
		callOut	= {parent = "KeyRingButton", align = "TOPLEFT", xOff = -8, yOff = 7, width = 35, height = 52},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	["LFG"] = {
		tileHeight = 7, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -150},
		callOut	= {parent = "LFDMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	["Food"] = {
		tileHeight = 10, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -130, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Food01", align = "TOP", xOff = -60, yOff = -50},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Food02", align = "TOP", xOff = 10, yOff = -50},
		imageData3 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Food03", align = "TOP", xOff = 80, yOff = -50},
    },
	
	["Drink"] = {
		tileHeight = 13, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -120, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Drink01", align = "TOP", xOff = -60, yOff = -50},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Drink02", align = "TOP", xOff = 10, yOff = -50},
		imageData3 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Drink03", align = "TOP", xOff = 80, yOff = -50},
    },
	
	["QuestGray"] = {
		tileHeight = 18, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -195, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-QuestGray", align = "TOP", xOff = 30, yOff = -50},
	},
	
	["Ranged"] = {
		tileHeight = 20, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -125, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Shoot01", align = "TOP", xOff = -60, yOff = -50},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Shoot02", align = "TOP", xOff = 10, yOff = -50},
		imageData3 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Shoot03", align = "TOP", xOff = 80, yOff = -50},
    },
	
	["Trainer"] = {
		tileHeight = 17, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -145, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-TrainerCursor", align = "TOP", xOff = 0, yOff = -60},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-TheDude", align = "TOP", xOff = -40, yOff = -10},
		mouseData = {image = "RightClick", align = "TOP", xOff = 80, yOff = -40},
	},
	
	["Vendor"] = {
		tileHeight = 17, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 70},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -150, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-LootCursor", align = "TOP", xOff = 0, yOff = -60},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-TheDude", align = "TOP", xOff = -40, yOff = -10},
		mouseData = {image = "RightClick", align = "TOP", xOff = 80, yOff = -40},
	},
	
	["Professions"] = {
		tileHeight = 18, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -150, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-TrainerCursor", align = "TOP", xOff = 0, yOff = -60},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-TheDude", align = "TOP", xOff = -40, yOff = -10},
		mouseData = {image = "RightClick", align = "TOP", xOff = 80, yOff = -40},
	},
	
	["Breath"] = {
		tileHeight = 9, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -95, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-BreathBar", align = "TOP", xOff = 10, yOff = -40},
	},
	
	["Fat"] = {
		tileHeight = 9, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -95, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-FatigueBar", align = "TOP", xOff = 10, yOff = -40},
	},
	
	["Grouping"] = {
		tileHeight = 20, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -165, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-DudeParty", align = "TOP", xOff = -50, yOff = -63},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-GloveCursor", layer = "OVERLAY", align = "TOP", xOff = 40, yOff = -90},
		mouseData = {image = "RightClick", align = "TOP", xOff = 110, yOff = -65},
	},
	
	["Swim"] = {
		tileHeight = 14, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -135, bottomRight_xOff = -29, bottomRight_yOff = 35},
		mouseData = {image = "RightClick", align = "TOP", xOff = 10, yOff = -35},
	},
	
	["Ammo"] = {
		tileHeight = 14, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -135, bottomRight_xOff = -29, bottomRight_yOff = 35},
		mouseData = {image = "RightClick", align = "TOP", xOff = 10, yOff = -35},
	},
};

function TutorialFrame_OnLoad(self)
	self:RegisterEvent("TUTORIAL_TRIGGER");

	for i = 1, MAX_TUTORIAL_VERTICAL_TILE do
		local texture = self:CreateTexture("TutorialFrameLeft"..i, "BORDER");
		texture:SetTexture("Interface\\TutorialFrame\\UI-TUTORIAL-FRAME");
		texture:SetTexCoord(0.3066406, 0.3261719, 0.656250025, 0.675781275);
		texture:SetSize(11, 10);
		texture = self:CreateTexture("TutorialFrameRight"..i, "BORDER");
		texture:SetTexture("Interface\\TutorialFrame\\UI-TUTORIAL-FRAME");
		texture:SetTexCoord(0.3496094, 0.3613281, 0.656250025, 0.675781275);
		texture:SetSize(7, 10);
	end
	TutorialFrameLeft1:SetPoint("TOPLEFT", TutorialFrameTop, "BOTTOMLEFT", 6, 0);
	TutorialFrameRight1:SetPoint("TOPRIGHT", TutorialFrameTop, "BOTTOMRIGHT", -1, 0);
	
	for i = 1, MAX_TUTORIAL_IMAGES do
		local texture = self:CreateTexture("TutorialFrameImage"..i, "ARTWORK");
	end

	for i = 1, MAX_TUTORIAL_KEYS do
		local texture = self:CreateTexture("TutorialFrameKey"..i, "ARTWORK");
		texture:SetTexture("Interface\\TutorialFrame\\UI-TUTORIAL-FRAME");
		texture:SetTexCoord(0.1542969, 0.3007813, 0.8046875, 0.9433594);
		texture:SetSize(76, 72);
		local keyString = self:CreateFontString("TutorialFrameKeyString"..i, "ARTWORK", "GameFontNormalHugeBlack");
		keyString:SetPoint("CENTER", texture, "CENTER", 0, 10);
	end

	TutorialFrame_ClearTextures();
end

function TutorialFrame_OnShow(self)
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	TutorialFrame_CheckNextPrevButtons();
end

function TutorialFrame_OnHide(self)
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");
	
	if ( (getn(TUTORIALFRAME_QUEUE) <= 0) and (UnitLevel("player") > 5) ) then
		TutorialFrameAlertButton:Hide();
		UIParent_ManageFramePositions();
	end
end

function TutorialFrame_CheckNextPrevButtons()
	if ( GetPrevCompleatedTutorial(TutorialFrame.id) ) then
		TutorialFramePrevButton:Enable();
	else
		TutorialFramePrevButton:Disable();
	end
	if ( GetNextCompleatedTutorial(TutorialFrame.id) or (getn(TUTORIALFRAME_QUEUE) > 0) ) then
		TutorialFrameNextButton:Enable();
	else
		TutorialFrameNextButton:Disable();
	end
end

function TutorialFrame_Update(currentTutorial)
	FlagTutorial(currentTutorial);
	TutorialFrame.id = currentTutorial;

	local displayData = DISPLAY_DATA[ TUTORIAL_DATA[currentTutorial] ];
	if ( not displayData ) then
		displayData = DISPLAY_DATA["Base"];
	end
	
	-- setup the frame
	TutorialFrame_ClearTextures();
	local anchorData = displayData.anchorData;
	TutorialFrame:SetPoint( anchorData.align, UIParent, anchorData.align, anchorData.xOff, anchorData.yOff );

	local anchorParentLeft = TutorialFrameLeft1;
	local anchorParentRight = TutorialFrameRight1;
	for i = 2, displayData.tileHeight do
		local leftTexture = _G["TutorialFrameLeft"..i];
		local rightTexture = _G["TutorialFrameRight"..i];
		leftTexture:SetPoint("TOPLEFT", anchorParentLeft, "BOTTOMLEFT", 0, 0);
		rightTexture:SetPoint("TOPRIGHT", anchorParentRight, "BOTTOMRIGHT", 0, 0);
		leftTexture:Show();
		rightTexture:Show();
		anchorParentLeft = leftTexture;
		anchorParentRight = rightTexture;
	end
	TutorialFrameBottom:SetPoint("TOPLEFT", anchorParentLeft, "BOTTOMLEFT", 0, 0);
	TutorialFrameBottom:SetPoint("TOPRIGHT", anchorParentRight, "TOPRIGHT", 0, 0);

	local height = TUTORIALFRAME_TOP_HEIGHT + (displayData.tileHeight * TUTORIALFRAME_MIDDLE_HEIGHT) + TUTORIALFRAME_BOTTOM_HEIGHT;
	TutorialFrame:SetSize(TUTORIALFRAME_WIDTH, height);

	-- setup the text
	local title = _G["TUTORIAL_TITLE"..currentTutorial];
	local text = _G["TUTORIAL"..currentTutorial];
	if ( title and text) then
		TutorialFrameTitle:SetText(title);
		TutorialFrameText:SetText(text);
	end
	if ( displayData.textBox) then
		TutorialFrameTextScrollFrame:SetPoint("TOPLEFT", TutorialFrame, "TOPLEFT", displayData.textBox.topLeft_xOff, displayData.textBox.topLeft_yOff);
		TutorialFrameTextScrollFrame:SetPoint("BOTTOMRIGHT", TutorialFrame, "BOTTOMRIGHT", displayData.textBox.bottomRight_xOff, displayData.textBox.bottomRight_yOff);
	end

	-- setup the callout
	local callOut = displayData.callOut;
	if(callOut) then
		TutorialFrameCallOut:SetSize(callOut.width, callOut.height);
		TutorialFrameCallOut:SetPoint( callOut.align, callOut.parent, callOut.align, callOut.xOff, callOut.yOff );
		TutorialFrameCallOut:Show();
		TutorialFrameCallOutPulser:Play();
	end

	-- setup images
	for i = 1, MAX_TUTORIAL_IMAGES do
		local imageTexture = _G["TutorialFrameImage"..i];
		local imageData = displayData["imageData"..i];
		if(imageData and imageTexture) then
			imageTexture:SetTexture(imageData.file);
			imageTexture:SetPoint( imageData.align, TutorialFrame, imageData.align, imageData.xOff, imageData.yOff );
			if ( imageData.layer ) then
				imageTexture:SetDrawLayer(imageData.layer);
			end
			imageTexture:Show();
		elseif( imageTexture ) then
			imageTexture:ClearAllPoints();
			imageTexture:SetTexture("");
			imageTexture:Hide();
		end
	end

	-- setup mouse
	local mouseData = displayData.mouseData;
	if(mouseData) then
		local mouseTexture = _G["TutorialFrameMouse"..mouseData.image];
		mouseTexture:SetPoint( mouseData.align, TutorialFrame, mouseData.align, mouseData.xOff, mouseData.yOff );
		
		local scale = 1.0;
		if ( mouseData.scale ) then
			scale = mouseData.scale;
		end
		mouseTexture:SetWidth( MOUSE_SIZE.x * scale );
		mouseTexture:SetHeight( MOUSE_SIZE.y * scale );
		
		if ( mouseData.layer ) then
			mouseTexture:SetDrawLayer(mouseData.layer);
		end
		mouseTexture:Show();
	end

	-- setup keys
	for i = 1, MAX_TUTORIAL_KEYS do
		local keyTexture = _G["TutorialFrameKey"..i];
		local keyString = _G["TutorialFrameKeyString"..i];
		local keyData = displayData["keyData"..i];
		if(keyTexture and keyString and keyData) then
			keyTexture:SetPoint( keyData.align, TutorialFrame, keyData.align, keyData.xOff, keyData.yOff );
			keyString:SetText( GetBindingText(GetBindingKey(keyData.command), "KEY_") );
			if ( keyData.layer ) then
				keyTexture:SetDrawLayer(keyData.layer);
				keyString:SetDrawLayer(keyData.layer);
			end
			keyTexture:Show();
			keyString:Show();
		elseif ( keyTexture ) then
			keyTexture:ClearAllPoints();
			keyTexture:Hide();
			keyString:Hide();
		end
	end

	-- setup arrows
	for i = 1, getn(ARROW_TYPES) do
		arrowData = displayData[ ARROW_TYPES[i] ];
		arrowTexture = _G[ "TutorialFrame"..ARROW_TYPES[i] ];
		if ( arrowData and arrowTexture ) then
			arrowTexture:SetPoint( arrowData.align, TutorialFrame, arrowData.align, arrowData.xOff, arrowData.yOff );
			if ( arrowData.layer ) then
				arrowTexture:SetDrawLayer(arrowData.layer);
			end
			if ( arrowData.scale ) then
				arrowTexture:SetWidth( ARROW_SIZES[ARROW_TYPES[i]].x * arrowData.scale );
				arrowTexture:SetHeight( ARROW_SIZES[ARROW_TYPES[i]].y * arrowData.scale );
			end
			arrowTexture:Show();
		elseif ( arrowTexture ) then
			arrowTexture:ClearAllPoints();
			arrowTexture:Hide();
		end
	end
	
	-- show
	TutorialFrame:Show();
	TutorialFrame_CheckNextPrevButtons();
end

function TutorialFrame_ClearTextures()
	TutorialFrame:ClearAllPoints();
	TutorialFrameBottom:ClearAllPoints();
	TutorialFrameTextScrollFrame:ClearAllPoints();
	
	TutorialFrameCallOutPulser:Stop();
	TutorialFrameCallOut:ClearAllPoints();
	TutorialFrameCallOut:Hide();
	
	TutorialFrameMouseRightClick:ClearAllPoints();
	TutorialFrameMouseLeftClick:ClearAllPoints();
	TutorialFrameMouseBothClick:ClearAllPoints();
	TutorialFrameMouseWheel:ClearAllPoints();
	TutorialFrameMouseRightClick:Hide();
	TutorialFrameMouseLeftClick:Hide();
	TutorialFrameMouseBothClick:Hide();
	TutorialFrameMouseWheel:Hide();

	-- top & left1 & right1 never have thier anchors changed; or are independantly hidden
	for i = 2, MAX_TUTORIAL_VERTICAL_TILE do
		local leftTexture = _G["TutorialFrameLeft"..i];
		local rightTexture = _G["TutorialFrameRight"..i];
		leftTexture:ClearAllPoints();
		rightTexture:ClearAllPoints();
		leftTexture:Hide();
		rightTexture:Hide();
	end
end

function TutorialFrame_NewTutorial(tutorialID)
	-- check that we haven't already seen it
	if ( IsTutorialFlagged(tutorialID) ) then
		return;
	end
	for index, value in pairs(TUTORIALFRAME_QUEUE) do
		if( (value == tutorialID) ) then
			return;
		end
	end

	TUTORIAL_LAST_ID = tutorialID;
	local button = TutorialFrameAlertButton;
	tinsert(TUTORIALFRAME_QUEUE, tutorialID);
	if ( not TutorialFrame:IsShown() ) then
		button.id = tutorialID;
		button:Show();
		UIParent_ManageFramePositions();
		if ( not TutorialFrame:IsShown() and not InCombatLockdown() ) then
			TutorialFrame_AlertButton_OnClick(button);
		end
	elseif ( button:IsEnabled() == 0 ) then
		button.id = tutorialID;
	end
	TutorialFrame_CheckBadge();
	if ( getn(TUTORIALFRAME_QUEUE) > 0 ) then
		TutorialFrameNextButton:Enable();
	end
end

function TutorialFramePrevButton_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	local prevTutorial = GetPrevCompleatedTutorial(TutorialFrame.id);
	if ( prevTutorial ) then
		TutorialFrame_Update(prevTutorial);
	end
end

function TutorialFrameNextButton_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	local nextTutorial = GetNextCompleatedTutorial(TutorialFrame.id);
	if ( nextTutorial ) then
		TutorialFrame_Update(nextTutorial);
	elseif (getn(TUTORIALFRAME_QUEUE) > 0) then
		TutorialFrame_AlertButton_OnClick(TutorialFrameAlertButton);
	end
end

function TutorialFrame_AlertButton_OnClick(self)
	local tutorialID = TUTORIALFRAME_QUEUE[1];
	if ( tutorialID ) then
		tremove(TUTORIALFRAME_QUEUE, 1);
		TutorialFrame_Update(tutorialID);
	elseif ( TUTORIAL_LAST_ID ) then
		TutorialFrame_Update(TUTORIAL_LAST_ID);
	end
	TutorialFrame_CheckBadge();
end

function TutorialFrame_Hide()
	PlaySound("igMainMenuClose");
	HideUIPanel(TutorialFrame);
	if ( getn(TUTORIALFRAME_QUEUE) > 0 ) then
		TutorialFrame_AlertButton_OnClick( TutorialFrameAlertButton );
	end
end

function TutorialFrame_CheckBadge()
	TutorialFrameAlertButtonBadge:Hide();
	TutorialFrameAlertButtonBadgeText:Hide();
--[[ leaving this here in case the badge system make a return
	if( getn(TUTORIALFRAME_QUEUE) > 1 or (TutorialFrame:IsShown() and getn(TUTORIALFRAME_QUEUE) > 0) ) then
		TutorialFrameAlertButtonBadge:Show();
		local count = getn(TUTORIALFRAME_QUEUE);
		if ( not TutorialFrame:IsShown() ) then
			count = count - 1;
		end
		TutorialFrameAlertButtonBadgeText:SetText( count );
		TutorialFrameAlertButtonBadgeText:Show();
	else
		TutorialFrameAlertButtonBadge:Hide();
		TutorialFrameAlertButtonBadgeText:Hide();
	end
--]]
end

function TutorialFrame_ClearQueue()
	TUTORIALFRAME_QUEUE = { };
end
