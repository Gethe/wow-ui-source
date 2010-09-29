local MAX_TUTORIAL_VERTICAL_TILE = 30;
local MAX_TUTORIAL_IMAGES = 3;
local MAX_TUTORIAL_KEYS = 4;

local TUTORIALFRAME_TOP_HEIGHT = 80;
local TUTORIALFRAME_MIDDLE_HEIGHT = 10;
local TUTORIALFRAME_BOTTOM_HEIGHT = 30;
local TUTORIALFRAME_WIDTH = 364;

local TUTORIAL_LAST_ID = nil;

local TUTORIAL_QUEST_ACCEPTED = false; -- used to trigger tutorials after closing the quest log, but after accepting a quest.

TUTORIAL_QUEST_TO_WATCH = nil;
TUTORIAL_DISTANCE_TO_QUEST_KILL_SQ = (50 * 50); -- the square distance to trigger the "near quest creature" tutorial.

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

local TUTORIAL_QUEST_ARRAY = {
	["HUMANHUNTER"] = {questID = 28767, displayNPC = 197, killCreature = 49871},
	["HUMANMAGE"] = {questID = 28757, displayNPC = 197, killCreature = 49871},
	["HUMANPALADIN"] = {questID = 28762, displayNPC = 197, killCreature = 49871},
	["HUMANPRIEST"] = {questID = 28763, displayNPC = 197, killCreature = 49871},
	["HUMANROGUE"] = {questID = 28764, displayNPC = 197, killCreature = 49871},
	["HUMANWARLOCK"] = {questID = 28765, displayNPC = 197, killCreature = 49871},
	["HUMANWARRIOR"] = {questID = 28766, displayNPC = 197, killCreature = 49871},
	["DWARF"] = {questID = 24469, displayNPC = 37081, killCreature = 37070},
	["NIGHTELF"] = {questID = 28713, displayNPC = 2079, killCreature = 2031},
	["GNOME"] = {questID = 27670, displayNPC = 45966, killCreature = 46363},
	["ORC"] = {questID = 25126, displayNPC = 3143, killCreature = 3098, showReminder = true},
	["SCOURGE"] = {questID = 26799, displayNPC = 1568, killCreature = 1501, showReminder = true},
	["TAUREN"] = {questID = 14452, displayNPC = 2980, killCreature = 36943, showReminder = true},
	["TROLLDRUID"] = {questID = 24765, displayNPC = 38243, killCreature = 38038, showReminder = true},
	["TROLLHUNTER"] = {questID = 24777, displayNPC = 38247, killCreature = 38038, showReminder = true},
	["TROLLMAGE"] = {questID = 24751, displayNPC = 38246, killCreature = 38038, showReminder = true},
	["TROLLPRIEST"] = {questID = 24783, displayNPC = 38245, killCreature = 38038, showReminder = true},
	["TROLLROGUE"] = {questID = 24771, displayNPC = 38244, killCreature = 38038, showReminder = true},
	["TROLLSHAMAN"] = {questID = 24759, displayNPC = 38242, killCreature = 38038, showReminder = true},
	["TROLLWARLOCK"] = {questID = 26273, displayNPC = 42618, killCreature = 38038, showReminder = true},
	["TROLLWARRIOR"] = {questID = 24639, displayNPC = 38037, killCreature = 38038, showReminder = true},

	["DRAENEI"] = nil,
	["BLOODELF"] = nil,
	["WORGEN"] = nil,
	["GOBLIN"] = nil,
};
CURRENT_TUTORIAL_QUEST_INFO = nil;


local DISPLAY_DATA = {
	-- layers can be BACKGROUND, BORDER, ARTWORK, OVERLAY, HIGHLIGHT
	-- if you don't assign one it will default to ARTWORK

	[1] = { --TUTORIAL_QUESTGIVERS
		tileHeight = 21, 
		anchorData = {align = "RIGHT", xOff = -50, yOff = 0},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -180, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-QuestCursor", align = "TOP", xOff = 0, yOff = -110},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-QuestGiver", align = "TOP", xOff = -40, yOff = -50},
		mouseData = {image = "RightClick", align = "TOP", xOff = 80, yOff = -60},
	},
	
	[2] = {	--TUTORIAL_MOVEMENT
		tileHeight = 0,
		background = {width = 350, height = 300, alpha = 0.4},
		anchorData = {align = "BOTTOM", xOff = -275, yOff = 275},
		textBox = {font = GameFontNormalLarge, topLeft_xOff = 20, topLeft_yOff = -230, bottomRight_xOff = 0, bottomRight_yOff = 0},
		keyData1 = {command = "TURNLEFT", layer = "OVERLAY", align = "BOTTOM", xOff = -55, yOff = 110, linkedTexture = "TutorialFrameArrowLeft"},
		keyData2 = {command = "MOVEBACKWARD", layer = "OVERLAY", align = "BOTTOM", xOff = 0, yOff = 110, linkedTexture = "TutorialFrameArrowDown"},
		keyData3 = {command = "TURNRIGHT", layer = "OVERLAY", align = "BOTTOM", xOff = 55, yOff = 110, linkedTexture = "TutorialFrameArrowRight"},
		keyData4 = {command = "MOVEFORWARD", align = "BOTTOM", xOff = 0, yOff = 150, linkedTexture = "TutorialFrameArrowUp"},
		ArrowUp = {layer = "BORDER", align = "BOTTOM", xOff = 0, yOff = 205, scale = 0.5},
		ArrowDown = {layer = "ARTWORK", align = "BOTTOM", xOff = 0, yOff = 80, scale = 0.5},
		ArrowRight = {layer = "ARTWORK", align = "BOTTOM", xOff = 100, yOff = 130, scale = 0.5},
		ArrowLeft = {layer = "ARTWORK", align = "BOTTOM", xOff = -100, yOff = 130, scale = 0.5},
	},
	
	[3] = {	--TUTORIAL_CAMERA
		tileHeight = 0, 
		anchorData = {align = "TOP", xOff = 0, yOff = 30},
		textBox = {topLeft_xOff = 400, topLeft_yOff = -175, bottomRight_xOff = 624, bottomRight_yOff = 35},
		mouseData = {layer = "OVERLAY", image = "RightClick", align = "TOP", xOff = 0, yOff = -55},
		ArrowRight = {align = "TOP", xOff = 40, yOff = -90, scale = 0.5, command="RightButton"},
		ArrowLeft = {align = "TOP", xOff = -40, yOff = -90, scale = 0.5},
	},
	
	[4] = {	--TUTORIAL_NEAR_QUEST_KILL
		raceRequired = true;
 		tileHeight = 24, 
		anchorData = {align = "RIGHT", xOff = -50, yOff = 0},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -260, bottomRight_xOff = -29, bottomRight_yOff = 35},
		killCreature = true;
	},
	
	[5] = {	--TUTORIAL_TARGETING_ENEMY
		tileHeight = 19, 
		anchorData = {align = "RIGHT", xOff = -50, yOff = 0},
		callOut	= {parent = "MainMenuBar", align = "TOPLEFT", xOff = -5, yOff = -5, width = 525, height = 50},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -145, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-AttackCursor", align = "TOP", xOff = -60, yOff = -60},
		mouseData = {image = "LeftClick", align = "TOP", xOff = 50, yOff = -45},
	},

	[6] = {	--TUTORIAL_COMBAT
		tileHeight = 15, 
		anchorData = {align = "RIGHT", xOff = -50, yOff = -200},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -120, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Spell01", align = "TOP", xOff = -60, yOff = -50},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Spell02", align = "TOP", xOff = 10, yOff = -50},
		imageData3 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Spell03", align = "TOP", xOff = 80, yOff = -50},
	},

	[7] = {	--TUTORIAL_LOOT_QUEST
		tileHeight = 24, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 90},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -195, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-LootCorpse", align = "TOP", xOff = -60, yOff = -13},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-LootCursor", align = "TOP", xOff = 40, yOff = -90},
		mouseData = {image = "RightClick", align = "TOP", xOff = 110, yOff = -65},
	},

	[8] = {	--TUTORIAL_ITEMS
		tileHeight = 21, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 70},
		callOut	= {parent = "MainMenuBarBackpackButton", align = "TOPLEFT", xOff = -5, yOff = 5, width = 50, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -190, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-LootedItem", align = "TOP", xOff = 5, yOff = -55},
	},
	
	[9] = {	--TUTORIAL_USABLE_ITEMS
		tileHeight = 21, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 70},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -200, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-OnUseItem", align = "TOP", xOff = -35, yOff = -70},
		mouseData = {image = "RightClick", align = "TOP", xOff = 110, yOff = -85},
	},
	
	[10] = { --TUTORIAL_SECOND_QUEST
		raceRequired = true;
 		tileHeight = 24, 
		callOut	= {parent = "Minimap", align = "TOPLEFT", xOff = -8, yOff = 0, width = 151, height = 145},
		anchorData = {align = "RIGHT", xOff = -50, yOff = 0},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -260, bottomRight_xOff = -29, bottomRight_yOff = 35},
		killCreature = true;
    },
	
	[11] = { --TUTORIAL_FIRST_QUEST_KILL
		raceRequired = true;
		raidwarning = true,
		tileHeight = 0, 
    },
	
	[12] = { --TUTORIAL_NOT_USED_1
    },
	
	[13] = { --TUTORIAL_TALENTS
		tileHeight = 9, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -150},
		callOut	= {parent = "TalentMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	[14] = { --TUTORIAL_SKILLS
		tileHeight = 17, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -145, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-TrainerCursor", align = "TOP", xOff = 0, yOff = -60},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-TheDude", align = "TOP", xOff = -40, yOff = -10},
		mouseData = {image = "RightClick", align = "TOP", xOff = 80, yOff = -40},
	},
	
	[15] = { --TUTORIAL_NOT_USED_2
	},
	
	[16] = { --TUTORIAL_REPUTATION
		tileHeight = 8, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -150},
		callOut	= {parent = "CharacterMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	[17] = { --TUTORIAL_TELLS
		tileHeight = 6, 
		anchorData = {align = "LEFT", xOff = 25, yOff = -50},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	[18] = { --TUTORIAL_GROUPING
		tileHeight = 20, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -165, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-DudeParty", align = "TOP", xOff = -50, yOff = -63},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-GloveCursor", layer = "OVERLAY", align = "TOP", xOff = 40, yOff = -90},
		mouseData = {image = "RightClick", align = "TOP", xOff = 110, yOff = -65},
	},
	
	[19] = { --TUTORIAL_PLAYERS
        tileHeight = 11, 
        anchorData = {align = "LEFT", xOff = 50, yOff = 150},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -135, bottomRight_xOff = -29, bottomRight_yOff = 35},
--      callOut  = {parent = "TargetFrame", align = "TOPLEFT", xOff = -5, yOff = -5, width = 210, height = 80},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-DudeParty", align = "TOP", xOff = 0, yOff = -40},
    },
	
	[20] = { --TUTORIAL_BUYING_ITEMS
		tileHeight = 17, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 70},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -150, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-LootCursor", align = "TOP", xOff = 0, yOff = -60},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-TheDude", align = "TOP", xOff = -40, yOff = -10},
		mouseData = {image = "RightClick", align = "TOP", xOff = 80, yOff = -40},
	},
	
	[21] = { --TUTORIAL_QUESTLOG
		tileHeight = 10, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -150},
		callOut	= {parent = "QuestLogMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	[22] = { --TUTORIAL_FRIENDS
		tileHeight = 10, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -150},
		callOut	= {parent = "FriendsMicroButton", align = "TOPLEFT", xOff = -4, yOff = 6, width = 38, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	[23] = { --TUTORIAL_CHATTING
		tileHeight = 7, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	[24] = { --TUTORIAL_EQUIPPABLE_ITEMS
		tileHeight = 25, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 70},
		callOut	= {parent = "CharacterMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-EquipItem", align = "TOP", xOff = 10, yOff = -15},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -225, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	[25] = { --TUTORIAL_DEATH
		tileHeight = 22, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 70},
		callOut	= {parent = "Minimap", align = "TOPLEFT", xOff = -8, yOff = 0, width = 151, height = 145},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -185, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-SpiritRez", align = "TOP", xOff = 10, yOff = -50},
	},	
	
	[26] = { --TUTORIAL_RESTED
		tileHeight = 7, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	[27] = { --TUTORIAL_FATIGUE
		tileHeight = 9, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -95, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-FatigueBar", align = "TOP", xOff = 10, yOff = -40},
	},
	
	[28] = { --TUTORIAL_SWIMMING
		tileHeight = 14, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -135, bottomRight_xOff = -29, bottomRight_yOff = 35},
		mouseData = {image = "RightClick", align = "TOP", xOff = 10, yOff = -35},
	},
	
	[29] = { --TUTORIAL_BREATH
		tileHeight = 9, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -95, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-BreathBar", align = "TOP", xOff = 10, yOff = -40},
	},
	
	[30] = { --TUTORIAL_INNS
		tileHeight = 11, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 150},
		callOut	= {parent = "PlayerFrame", align = "TOPLEFT", xOff = 32, yOff = -4, width = 85, height = 85},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},

	[31] = { --TUTORIAL_HEARTHSTONES
		tileHeight = 10, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -120, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Hearthstone", align = "TOP", xOff = 10, yOff = -50},
	},	

	[32] = { --TUTORIAL_PVP
		tileHeight = 10, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 150},
		callOut	= {parent = "PlayerFrame", align = "TOPLEFT", xOff = 34, yOff = -6, width = 78, height = 78},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},	
	
	[33] = { --TUTORIAL_JUMPING
		tileHeight = 7, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},	
	
	[34] = { --TUTORIAL_COMPLETE_QUEST
		raidwarning = true,
		tileHeight = 0, 
	},
	
	[35] = { --TUTORIAL_FLIGHT
		tileHeight = 25, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -195, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-FlightCursor", align = "TOP", xOff = 0, yOff = -110},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-FlightMaster", align = "TOP", xOff = -40, yOff = -50},
		mouseData = {image = "RightClick", align = "TOP", xOff = 80, yOff = -60},
	},	
	
	[36] = { --TUTORIAL_DURABILITY_LOW
		tileHeight = 17, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -20},
		callOut	= {parent = "DurabilityFrame", align = "TOPLEFT", xOff = 0, yOff = 8, width = 58, height = 90},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -150, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-RepairCursor", align = "TOP", xOff = 0, yOff = -60},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-TheDude", align = "TOP", xOff = -40, yOff = -10},
		mouseData = {image = "RightClick", align = "TOP", xOff = 80, yOff = -40},
	},
	
	[37] = { --TUTORIAL_DURABILITY_BROKEN
		tileHeight = 18, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -20},
		callOut	= {parent = "DurabilityFrame", align = "TOPLEFT", xOff = 0, yOff = 8, width = 58, height = 90},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -150, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-RepairCursor", align = "TOP", xOff = 0, yOff = -60},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-TheDude", align = "TOP", xOff = -40, yOff = -10},
		mouseData = {image = "RightClick", align = "TOP", xOff = 80, yOff = -40},
	},
	
	[38] = { --TUTORIAL_PROFESSIONS
		tileHeight = 18, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -150, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-TrainerCursor", align = "TOP", xOff = 0, yOff = -60},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-TheDude", align = "TOP", xOff = -40, yOff = -10},
		mouseData = {image = "RightClick", align = "TOP", xOff = 80, yOff = -40},
	},
	
	[39] = { --TUTORIAL_GROUPS
		tileHeight = 11, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	[40] = { --TUTORIAL_SPELLBOOK
		tileHeight = 28, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -130},
		callOut	= {parent = "SpellbookMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Spellbook", align = "TOP", xOff = 10, yOff = -50},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -225, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	[41] = { --TUTORIAL_ELITE_QUESTS
		tileHeight = 21, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Elite", align = "TOP", xOff = 10, yOff = -50},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -160, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	[42] = { --TUTORIAL_NOT_USED_3
	},
	
	[43] = { --TUTORIAL_FUTURE_QUEST
		tileHeight = 18, 
		anchorData = {align = "RIGHT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -195, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-QuestGray", align = "TOP", xOff = 30, yOff = -50},
	},
	
	[44] = { --TUTORIAL_RANGED_WEAPON
		tileHeight = 20, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -125, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Shoot01", align = "TOP", xOff = -60, yOff = -50},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Shoot02", align = "TOP", xOff = 10, yOff = -50},
		imageData3 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Shoot03", align = "TOP", xOff = 80, yOff = -50},
    },
	
	[45] = { --TUTORIAL_NOT_USED_4
	},

	[46] = { --TUTORIAL_RAID
		tileHeight = 14, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},

	[47] = { --TUTORIAL_TOTEM_BAR
		tileHeight = 12, 
		anchorData = {align = "LEFT", xOff = 15, yOff = -150},
		callOut	= {parent = "MultiCastActionBarFrame", align = "TOPLEFT", xOff = -5, yOff = 4, width = 45, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	[48] = { --TUTORIAL_PVP_QUEUE
		tileHeight = 7, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 70},
		callOut	= {parent = "Minimap", align = "TOPLEFT", xOff = -8, yOff = 0, width = 151, height = 145},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},

	[49] = { --TUTORIAL_PVP_PORT
		tileHeight = 7, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 70},
		callOut	= {parent = "Minimap", align = "TOPLEFT", xOff = -8, yOff = 0, width = 151, height = 145},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},	
	
	[50] = { --TUTORIAL_KEYRINGS
		tileHeight = 7, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -150},
		callOut	= {parent = "KeyRingButton", align = "TOPLEFT", xOff = -8, yOff = 7, width = 35, height = 52},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	[51] = { --TUTORIAL_LOOKINGFORGROUP
		tileHeight = 7, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -150},
		callOut	= {parent = "LFDMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},

	[52] = { --TUTORIAL_CRITTER
		tileHeight = 11, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -150},
		callOut	= {parent = "SpellbookMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	[53] = { --TUTORIAL_MOUNT
		tileHeight = 13, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -150},
		callOut	= {parent = "SpellbookMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	
	[54] = { --TUTORIAL_THREAT_WARNING
		tileHeight = 19, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -150, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Threat", align = "TOP", xOff = 10, yOff = -50},
	},
	
	[55] = { --TUTORIAL_SECOND_QUEST_COMPLETE
		raceRequired = true;
 		tileHeight = 24, 
		anchorData = {align = "RIGHT", xOff = -50, yOff = 0},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -260, bottomRight_xOff = -29, bottomRight_yOff = 35},
		displayNPC = true,
	},
	
	[56] = { --TUTORIAL_PLAYER_HEALTH_MANA
		tileHeight = 19, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 150},
		callOut	= {parent = "PlayerFrame", align = "TOPLEFT", xOff = 100, yOff = -33, width = 135, height = 40},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -125, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-DudeFull", align = "TOP", xOff = 10, yOff = -35},
	},
	
    [57] = { --TUTORIAL_FIRST_QUEST_NOT_COMPLETE
		raceRequired = true;
 		tileHeight = 24, 
		anchorData = {align = "RIGHT", xOff = -50, yOff = 0},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -260, bottomRight_xOff = -29, bottomRight_yOff = 35},
		displayNPC = true,
   },
	
	[58] = { --TUTORIAL_BAG_FULL
		tileHeight = 22, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 70},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -185, bottomRight_xOff = -29, bottomRight_yOff = 35},
		callOut	= {parent = "MainMenuBarBackpackButton", align = "TOPLEFT", xOff = -5, yOff = 5, width = 50, height = 45},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-FullBackpack", align = "TOP", xOff = -22, yOff = -55},
    },
	
	[59] = { --TUTORIAL_BAG_ALMOST_FULL
		tileHeight = 24, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 70},
		callOut	= {parent = "MainMenuBarBackpackButton", align = "TOPLEFT", xOff = -5, yOff = 5, width = 50, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -185, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-FullBackpack", align = "TOP", xOff = -70, yOff = -65},
		mouseData = {image = "RightClick", align = "TOP", xOff = 110, yOff = -65},
    },
	
	[60] = { --TUTORIAL_HAVENT_CAST_SPELL
		tileHeight = 14, 
		anchorData = {align = "LEFT", xOff = 15, yOff = -150},
		callOut	= {parent = "MainMenuBar", align = "TOPLEFT", xOff = -5, yOff = -5, width = 525, height = 50},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -120, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Spell01", align = "TOP", xOff = -60, yOff = -50},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Spell02", align = "TOP", xOff = 10, yOff = -50},
		imageData3 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-Spell03", align = "TOP", xOff = 80, yOff = -50},
	},
	
	[61] = { --TUTORIAL_LEARN_SPELL_1
		spellTutorial = true;
		tileHeight = 21, 
		anchorData = {align = "RIGHT", xOff = 15, yOff = 0},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -180, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	[62] = { --TUTORIAL_LEARN_SPELL_1
		spellTutorial = true;
		tileHeight = 21, 
		anchorData = {align = "RIGHT", xOff = 15, yOff = 0},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -180, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	[63] = { --TUTORIAL_LEARN_SPELL_1
		spellTutorial = true;
		tileHeight = 21, 
		anchorData = {align = "RIGHT", xOff = 15, yOff = 0},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -180, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	[64] = { --TUTORIAL_LEARN_SPELL_1
		spellTutorial = true;
		tileHeight = 21, 
		anchorData = {align = "RIGHT", xOff = 15, yOff = 0},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -180, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
	[65] = { --TUTORIAL_LEARN_SPELL_1
		spellTutorial = true;
		tileHeight = 21, 
		anchorData = {align = "RIGHT", xOff = 15, yOff = 0},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -180, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
};

function TutorialFrame_OnLoad(self)
	self:RegisterEvent("TUTORIAL_TRIGGER");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("LEARNED_SPELL_IN_TAB");	

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

function TutorialFrame_OnEvent(self, event, ...)
	if ( event == "TUTORIAL_TRIGGER" ) then
		local tutorialID, forceShow = ...;
		TutorialFrame_NewTutorial(tutorialID, forceShow);
	elseif ( event == "DISPLAY_SIZE_CHANGED" ) then
		TutorialFrame_Update(TutorialFrame.id);
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		local _, className = UnitClass("player");
		local _, raceName  = UnitRace("player");
		className = strupper(className);
		raceName = strupper(raceName);
		if (TUTORIAL_QUEST_ARRAY[raceName..className]) then
			CURRENT_TUTORIAL_QUEST_INFO = TUTORIAL_QUEST_ARRAY[raceName..className];
			TUTORIAL_QUEST_TO_WATCH = CURRENT_TUTORIAL_QUEST_INFO.questID;
		elseif (TUTORIAL_QUEST_ARRAY[raceName]) then
			CURRENT_TUTORIAL_QUEST_INFO = TUTORIAL_QUEST_ARRAY[raceName];
			TUTORIAL_QUEST_TO_WATCH = CURRENT_TUTORIAL_QUEST_INFO.questID;
		end
	elseif ( event == "LEARNED_SPELL_IN_TAB" ) then
		local spellID = ...;
		for index, value in pairs(DISPLAY_DATA) do
			if (value.spellTutorial) then
				local spellID = ...;
				local _, className = UnitClass("player");
				className = strupper(className);
				local tutorialSpellID = tonumber(_G["TUTORIAL"..index.."_SPELLID_"..className]);
				if (tutorialSpellID == spellID) then
					TutorialFrame_NewTutorial(index, true);
				end
			end
		end
	end
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

function TutorialFrame_OnKeyDown(self, key)
	local displayData = DISPLAY_DATA[ self.id ];
	if (displayData["keyData1"]) then
		local allOff = true;
		for i = 1, MAX_TUTORIAL_KEYS do
			local keyTexture = _G["TutorialFrameKey"..i];
			local keyString = _G["TutorialFrameKeyString"..i];
			local keyData = displayData["keyData"..i];
			if(keyTexture and keyString and keyData) then
				local key1, key2 = GetBindingKey(keyData.command);
				if (key == key1 or key == key2) then
					if (keyData.linkedTexture) then
						_G[keyData.linkedTexture]:Hide();
					end
					keyTexture:ClearAllPoints();
					keyTexture:Hide();
					keyString:Hide();
				end
				if (keyTexture:IsShown()) then
					allOff = false;
				end
			end
		end
		if (allOff) then
			TutorialFrame_Hide();
		end
	end
end

function TutorialFrame_OnMouseDown(self, button)
	-- go through the mouse arrows
	local displayData = DISPLAY_DATA[ self.id ];
	local anyArrows = false;
	for i = 1, getn(ARROW_TYPES) do
		local arrowData = displayData[ ARROW_TYPES[i] ];
		local arrowTexture = _G[ "TutorialFrame"..ARROW_TYPES[i] ];
		if (arrowTexture and arrowData and arrowData.command) then
			anyArrows = true;
			if (arrowTexture:IsShown() and arrowData.command == button) then
				arrowTexture:ClearAllPoints();
				arrowTexture:Hide();
				break;
			end
		end
	end

	local allOff = true;
	for i = 1, getn(ARROW_TYPES) do
		local arrowData = displayData[ ARROW_TYPES[i] ];
		local arrowTexture = _G[ "TutorialFrame"..ARROW_TYPES[i] ];
		if (arrowData and arrowData.command and arrowTexture and arrowTexture:IsShown()) then
			allOff = false;
		end
	end

	if (anyArrows and allOff) then
		TutorialFrame_Hide();
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
	TutorialFrame_ClearTextures();
	TutorialFrame.id = currentTutorial;

	local displayData = DISPLAY_DATA[ currentTutorial ];
	if ( not displayData ) then
		return;
	end

	local _, className = UnitClass("player");
	local _, raceName  = UnitRace("player");
	className = strupper(className);
	raceName = strupper(raceName);
	
	if ( displayData.raceRequired and not CURRENT_TUTORIAL_QUEST_INFO) then
		return;
	end

	-- setup the frame
	if (displayData.anchorData) then
		local anchorData = displayData.anchorData;
		TutorialFrame:SetPoint( anchorData.align, UIParent, anchorData.align, anchorData.xOff, anchorData.yOff );
	end

	if (displayData.tileHeight == 0) then
		TutorialFrameTop:Hide();
		TutorialFrameLeft1:Hide();
		TutorialFrameRight1:Hide();
		TutorialFrameBottom:Hide();
		TutorialFrameBackground:Hide();
		TutorialFrameCloseButton:Hide();
		TutorialFrameOkayButton:Hide();
		TutorialFramePrevButton:Hide();
		TutorialFrameNextButton:Hide();
		if (displayData.background) then
			local background = displayData.background;
			TutorialFrame:SetSize(background.width,background.height);
			TutorialFrameBackground:SetAlpha(background.alpha);
			TutorialFrameBackground:Show();
		else
			TutorialFrame:SetSize(1024, 768);
		end
	else
		TutorialFrameTop:Show();
		TutorialFrameLeft1:Show();
		TutorialFrameRight1:Show();
		TutorialFrameBottom:Show();
		TutorialFrameBackground:Show();
		TutorialFrameCloseButton:Show();
		TutorialFrameOkayButton:Show();
		TutorialFramePrevButton:Show();
		TutorialFrameNextButton:Show();
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
	end

	-- setup the text
	-- check for race-class specific first, then race specific, then class, then normal
	local text = _G["TUTORIAL"..currentTutorial.."_"..raceName.."_"..className];
	if ( not text ) then
		text = _G["TUTORIAL"..currentTutorial.."_"..raceName];
		if ( not text ) then
			if ( displayData.raceRequired ) then
				return;
			end
			text = _G["TUTORIAL"..currentTutorial.."_"..className];
			if ( not text ) then
				text = _G["TUTORIAL"..currentTutorial];
			end
		end
	end
	if (displayData.raidwarning) then
		RaidNotice_AddMessage(RaidWarningFrame, text, HIGHLIGHT_FONT_COLOR);
		return;
	end
	
	local displayNPC, killCreature;
	if ( CURRENT_TUTORIAL_QUEST_INFO ) then
		displayNPC = CURRENT_TUTORIAL_QUEST_INFO.displayNPC;
		killCreature = CURRENT_TUTORIAL_QUEST_INFO.killCreature;
	end
	if (displayData.displayNPC and displayNPC) then
		TutorialNPCModel:SetCreature(displayNPC);
		TutorialNPCModel:Show();
	elseif (displayData.killCreature and killCreature) then
		TutorialNPCModel:SetCreature(killCreature);
		TutorialNPCModel:Show();
	end

	-- setup the title
	-- check for race-class specific first, then race specific, then class, then normal
	if (displayData.tileHeight > 0) then
		local title = _G["TUTORIAL_TITLE"..currentTutorial.."_"..raceName.."_"..className];
		if ( not title ) then
			title = _G["TUTORIAL_TITLE"..currentTutorial.."_"..raceName];
			if ( not title ) then
				title = _G["TUTORIAL_TITLE"..currentTutorial.."_"..className];
				if ( not title ) then
					title = _G["TUTORIAL_TITLE"..currentTutorial];
				end
			end
		end
	end

	if (text) then
		TutorialFrameText:SetText(text);
	end
	
	if (title) then
		TutorialFrameTitle:SetText(title);
	end
	if (displayData.textBox) then
		if(displayData.textBox.font) then
			TutorialFrameText:SetFontObject(displayData.textBox.font);
		end
		TutorialFrameTextScrollFrame:SetPoint("TOPLEFT", TutorialFrame, "TOPLEFT", displayData.textBox.topLeft_xOff, displayData.textBox.topLeft_yOff);
		TutorialFrameTextScrollFrame:SetPoint("BOTTOMRIGHT", TutorialFrame, "BOTTOMRIGHT", displayData.textBox.bottomRight_xOff, displayData.textBox.bottomRight_yOff);
	end

	-- setup the callout
	local callOut = displayData.callOut;
	if(callOut) then
		TutorialFrameCallOut:SetSize(callOut.width, callOut.height);
		TutorialFrameCallOut:SetPoint( callOut.align, callOut.parent, callOut.align, callOut.xOff, callOut.yOff );
		TutorialFrameCallOut:Show();
		AnimateCallout:Play();
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
		TutorialFrameMouse:SetPoint( mouseData.align, TutorialFrame, mouseData.align, mouseData.xOff, mouseData.yOff );
		
		local scale = 1.0;
		if ( mouseData.scale ) then
			scale = mouseData.scale;
		end
		mouseTexture:SetSize( MOUSE_SIZE.x * scale, MOUSE_SIZE.y * scale );
		TutorialFrameMouse:SetSize( MOUSE_SIZE.x * scale, MOUSE_SIZE.y * scale );
		
		if ( mouseData.layer ) then
			mouseTexture:SetDrawLayer(mouseData.layer);
		end
		mouseTexture:Show();
		TutorialFrameMouse:Show();
		AnimateMouse:Play();
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
		local arrowData = displayData[ ARROW_TYPES[i] ];
		local arrowTexture = _G[ "TutorialFrame"..ARROW_TYPES[i] ];
		if ( arrowData and arrowTexture ) then
			arrowTexture:SetPoint( arrowData.align, TutorialFrame, arrowData.align, arrowData.xOff, arrowData.yOff );
			if ( arrowData.layer ) then
				arrowTexture:SetDrawLayer(arrowData.layer);
			end
			local scale = arrowData.scale;
			if ( not scale ) then
				scale = 1.0;
			end
			arrowTexture:SetWidth( ARROW_SIZES[ARROW_TYPES[i]].x * scale );
			arrowTexture:SetHeight( ARROW_SIZES[ARROW_TYPES[i]].y * scale );
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
	TutorialFrameText:SetFontObject(GameFontNormal);
	TutorialFrameText:SetText("");
	TutorialFrameBackground:SetAlpha(1.0);

	TutorialNPCModel:Hide();

	AnimateCallout:Stop();
	TutorialFrameCallOut:ClearAllPoints();
	TutorialFrameCallOut:Hide();
	
	TutorialFrameMouse:ClearAllPoints();
	TutorialFrameMouseRightClick:ClearAllPoints();
	TutorialFrameMouseLeftClick:ClearAllPoints();
	TutorialFrameMouseBothClick:ClearAllPoints();
	TutorialFrameMouseWheel:ClearAllPoints();
	TutorialFrameMouse:Hide();
	TutorialFrameMouseRightClick:Hide();
	TutorialFrameMouseLeftClick:Hide();
	TutorialFrameMouseBothClick:Hide();
	TutorialFrameMouseWheel:Hide();
	AnimateMouse:Stop();

	-- top & left1 & right1 never have thier anchors changed; or are independantly hidden
	for i = 2, MAX_TUTORIAL_VERTICAL_TILE do
		local leftTexture = _G["TutorialFrameLeft"..i];
		local rightTexture = _G["TutorialFrameRight"..i];
		leftTexture:ClearAllPoints();
		rightTexture:ClearAllPoints();
		leftTexture:Hide();
		rightTexture:Hide();
	end

	for i = 1, MAX_TUTORIAL_IMAGES do
		local imageTexture = _G["TutorialFrameImage"..i];
		imageTexture:ClearAllPoints();
		imageTexture:SetTexture("");
		imageTexture:Hide();
	end

	for i = 1, MAX_TUTORIAL_KEYS do
		local keyTexture = _G["TutorialFrameKey"..i];
		local keyString = _G["TutorialFrameKeyString"..i];
		keyTexture:ClearAllPoints();
		keyTexture:Hide();
		keyString:Hide();
	end
	
	for i = 1, getn(ARROW_TYPES) do
		local arrowTexture = _G[ "TutorialFrame"..ARROW_TYPES[i] ];
		arrowTexture:ClearAllPoints();
		arrowTexture:Hide();
	end
end

function TutorialFrame_NewTutorial(tutorialID, forceShow)
	if(forceShow) then
		TutorialFrame_Update(tutorialID);
		return;
	end
	
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
		if (( not TutorialFrame:IsShown() and not InCombatLockdown()) or DISPLAY_DATA[tutorialID].raidwarning ) then
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
	while ( prevTutorial and DISPLAY_DATA[prevTutorial].tileHeight == 0) do
		prevTutorial = GetPrevCompleatedTutorial(prevTutorial);
	end
	if ( prevTutorial ) then
		TutorialFrame_Update(prevTutorial);
	end
end

function TutorialFrameNextButton_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	local nextTutorial = GetNextCompleatedTutorial(TutorialFrame.id);
	while ( nextTutorial and DISPLAY_DATA[nextTutorial].tileHeight == 0) do
		nextTutorial = GetNextCompleatedTutorial(nextTutorial);
	end
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
