MAX_TUTORIAL_VERTICAL_TILE = 30;
MAX_TUTORIAL_IMAGES = 3;
MAX_TUTORIAL_KEYS = 4;

TUTORIALFRAME_TOP_HEIGHT = 80;
TUTORIALFRAME_MIDDLE_HEIGHT = 10;
TUTORIALFRAME_BOTTOM_HEIGHT = 15;
TUTORIALFRAME_WIDTH = 364;

TUTORIALFRAME_QUEUE = { };

TUTORIAL_DATA = {
	[1] = "QuestGiver",
	[2] = "Movement",
	[3] = "LookAround",
	[4] = "Moved",
	[5] = "Combat1",
	[6] = "Spells",
	[7] = "LootPig",
	[8] = "LootedItem",
	[9] = "OnUseItem",
	[10] = "Bags",
	[13] = "Talents",
	[15] = "SpellBook",
	[16] = "Rep",
	[17] = "Reply",
	[19] = "Players",
	[21] = "QuestLog",
	[22] = "Friends",
	[24] = "Equip",
	[25] = "Death",
	[30] = "Resting",
	[31] = "Hearthstones",
	[32] = "Pvp",
	[33] = "Jumping",
	[34] = "QuestComplete",
	[35] = "Travel",
	[37] = "BrokenItems",
	[38] = "Professions",
	[39] = "Groups",
	[40] = "Spellbook2",
	[41] = "EliteQuests",
	[42] = "Welcome",
	[46] = "RaidGroups",
    [47] = "TotemBar",
	[52] = "CosmeticPets",
	[53] = "Mounts",
	[54] = "ThreatWarnings",
	[55] = "LevelUp",
	[56] = "HealthManaBar",
    [57] = "EnemyHealth",
    [58] = "FullBags",
	[59] = "FreeingUpBags",
	[60] = "Hotbar",
};

DISPLAY_DATA = {
	-- Do not remove "Base" it is the default
	["Base"] = {
		tileHeight = 7, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},
	
	["BaseTall"] = {
		tileHeight = 12, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},

	-- layers can be BACKGROUND, BORDER, ARTWORK, OVERLAY, HIGHLIGHT
	-- if you don't assign one it will default to ARTWORK
	["QuestGiver"] = {
		tileHeight = 20, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -185, bottomRight_xOff = -18, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-QuestCursor", align = "CENTER", xOff = 0, yOff = 10},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-QuestGiver", align = "CENTER", xOff = -40, yOff = 30},
		mouseData = {image = "RightClick", align = "CENTER", xOff = 80, yOff = 30},
	},
	
	["Movement"] = {
		tileHeight = 15, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -150, bottomRight_xOff = -18, bottomRight_yOff = 35},
		keyData1 = {command = "TURNLEFT", layer = "OVERLAY", align = "TOPLEFT", xOff = 105, yOff = -80},
		keyData2 = {command = "MOVEBACKWARD", layer = "OVERLAY", align = "TOPLEFT", xOff = 160, yOff = -80},
		keyData3 = {command = "TURNRIGHT", layer = "OVERLAY", align = "TOPLEFT", xOff = 215, yOff = -80},
		keyData4 = {command = "MOVEFORWARD", align = "TOPLEFT", xOff = 160, yOff = -40},
	},
	
	["Moved"] = {
		tileHeight = 20, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -185, bottomRight_xOff = -18, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-QuestCursor", align = "CENTER", xOff = 0, yOff = 10},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-QuestGiver", align = "CENTER", xOff = -40, yOff = 30},
		mouseData = {image = "RightClick", align = "CENTER", xOff = 80, yOff = 30},
	},
	
	["LevelUp"] = {
		tileHeight = 25, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		callOut	= {parent = "PlayerFrame", align = "TOPLEFT", xOff = 34, yOff = -50, width = 37, height = 34},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -215, bottomRight_xOff = -18, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-LevelUp", align = "CENTER", xOff = 10, yOff = 5},
	},
	
	["OnUseItem"] = {
		tileHeight = 20, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 70},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -195, bottomRight_xOff = -18, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-OnUseItem", align = "CENTER", xOff = -35, yOff = 10},
		mouseData = {image = "RightClick", align = "CENTER", xOff = 110, yOff = 15},
	},
	
	["LootedItem"] = {
		tileHeight = 20, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 70},
		callOut	= {parent = "MainMenuBarBackpackButton", align = "TOPLEFT", xOff = -5, yOff = 5, width = 50, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -195, bottomRight_xOff = -18, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-LootedItem", align = "CENTER", xOff = 5, yOff = 25},
	},
	
	["LootPig"] = {
		tileHeight = 20, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 70},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -195, bottomRight_xOff = -18, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-LootCorpse", align = "CENTER", xOff = -60, yOff = 10},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-LootCursor", align = "CENTER", xOff = 40, yOff = 25},
		mouseData = {image = "RightClick", align = "CENTER", xOff = 110, yOff = 25},
	},

	["Spells"] = {
		tileHeight = 7, 
		anchorData = {align = "LEFT", xOff = 15, yOff = -200},
		callOut	= {parent = "MainMenuBar", align = "TOPLEFT", xOff = -5, yOff = -5, width = 525, height = 50},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},

	["Combat1"] = {
		tileHeight = 18, 
		anchorData = {align = "LEFT", xOff = 15, yOff = -150},
		callOut	= {parent = "MainMenuBar", align = "TOPLEFT", xOff = -5, yOff = -5, width = 525, height = 50},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -145, bottomRight_xOff = -18, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-AttackCursor", align = "CENTER", xOff = -60, yOff = 40},
		mouseData = {image = "LeftClick", align = "CENTER", xOff = 50, yOff = 45},
	},

	["LookAround"] = {
		tileHeight = 16, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -170, bottomRight_xOff = -18, bottomRight_yOff = 35},
		mouseData = {image = "LeftClick", align = "CENTER", xOff = 5, yOff = 20},
		arrowCurveLeft = {layer = "OVERLAY", align = "TOPRIGHT", xOff = -215, yOff = -55},
		arrowCurveRight = {layer = "OVERLAY", align = "TOPRIGHT", xOff = -70, yOff = -55},
	},
	
	["Hotbar"] = {
		tileHeight = 7, 
		anchorData = {align = "LEFT", xOff = 15, yOff = -150},
		callOut	= {parent = "MainMenuBar", align = "TOPLEFT", xOff = -5, yOff = -5, width = 525, height = 50},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},

	["SpellBook"] = {
		tileHeight = 12, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -150},
		callOut	= {parent = "SpellbookMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},	
	
	["Death"] = {
		tileHeight = 11, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 70},
		callOut	= {parent = "Minimap", align = "TOPLEFT", xOff = -8, yOff = 0, width = 151, height = 145},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},	
	
	["Resting"] = {
		tileHeight = 11, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 150},
		callOut	= {parent = "PlayerFrame", align = "TOPLEFT", xOff = 34, yOff = -6, width = 78, height = 78},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},

	["Hearthstones"] = {
		tileHeight = 10, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},	

	["Pvp"] = {
		tileHeight = 10, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 150},
		callOut	= {parent = "PlayerFrame", align = "TOPLEFT", xOff = 34, yOff = -6, width = 78, height = 78},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},	
	
	["Jumping"] = {
		tileHeight = 10, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},	
	
	["QuestComplete"] = {
		tileHeight = 10, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 115},
		callOut	= {parent = "Minimap", align = "TOPLEFT", xOff = -8, yOff = 0, width = 151, height = 145},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},
	
	["Travel"] = {
		tileHeight = 15, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},	
	
	["BrokenItems"] = {
		tileHeight = 12, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 0},
		callOut	= {parent = "DurabilityFrame", align = "TOPLEFT", xOff = 0, yOff = 8, width = 58, height = 90},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},
	
	["Professions"] = {
		tileHeight = 12, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},
	
	["Groups"] = {
		tileHeight = 12, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},
	
	["Spellbook2"] = {
		tileHeight = 12, 
		anchorData = {align = "RIGHT", xOff = -50, yOff = -150},
		callOut	= {parent = "SpellbookMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},
	
	["EliteQuests"] = {
		tileHeight = 14, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},
	
	["Welcome"] = {
		tileHeight = 16, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},
	
	["RaidGroups"] = {
		tileHeight = 12, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},

	["TotemBar"] = {
		tileHeight = 12, 
		anchorData = {align = "LEFT", xOff = 15, yOff = -150},
		callOut	= {parent = "MultiCastActionBarFrame", align = "TOPLEFT", xOff = -5, yOff = 4, width = 45, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},
	
	["CosmeticPets"] = {
		tileHeight = 11, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -150},
		callOut	= {parent = "CharacterMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},
	
	["Mounts"] = {
		tileHeight = 13, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -150},
		callOut	= {parent = "CharacterMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},
	
	["ThreatWarnings"] = {
		tileHeight = 13, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},
	
	["HealthManaBar"] = {
		tileHeight = 13, 
		anchorData = {align = "LEFT", xOff = 15, yOff = 150},
		callOut	= {parent = "PlayerFrame", align = "TOPLEFT", xOff = 100, yOff = -33, width = 135, height = 40},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},
	
	["FullBags"] = {
		tileHeight = 20, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 70},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -195, bottomRight_xOff = -18, bottomRight_yOff = 35},
		callOut	= {parent = "MainMenuBarBackpackButton", align = "TOPLEFT", xOff = -5, yOff = 5, width = 50, height = 45},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-FullBackpack", align = "CENTER", xOff = -70, yOff = 15},
		mouseData = {image = "RightClick", align = "CENTER", xOff = 110, yOff = 15},
    },
	
    ["EnemyHealth"] = {
        tileHeight = 7, 
        anchorData = {align = "LEFT", xOff = 15, yOff = 150},
        textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
        callOut  = {parent = "TargetFrame", align = "TOPLEFT", xOff = -5, yOff = -34, width = 140, height = 38},
    },
	
	["FreeingUpBags"] = {
		tileHeight = 12, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 70},
		callOut	= {parent = "MainMenuBarBackpackButton", align = "TOPLEFT", xOff = -5, yOff = 5, width = 50, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
    },
	
	["Bags"] = {
		tileHeight = 7, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = 50},
		callOut	= {parent = "MainMenuBarBackpackButton", align = "TOPLEFT", xOff = -5, yOff = 5, width = 50, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
    },
	
	["Talents"] = {
		tileHeight = 12, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -150},
		callOut	= {parent = "TalentMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},
	
	["Rep"] = {
		tileHeight = 7, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -150},
		callOut	= {parent = "CharacterMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},
	
	["Reply"] = {
		tileHeight = 7, 
		anchorData = {align = "LEFT", xOff = 25, yOff = -50},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},
	
	["Players"] = {
        tileHeight = 7, 
        anchorData = {align = "LEFT", xOff = 50, yOff = 150},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
        callOut  = {parent = "TargetFrame", align = "TOPLEFT", xOff = -5, yOff = -5, width = 210, height = 80},
    },
	
	["QuestLog"] = {
		tileHeight = 7, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -150},
		callOut	= {parent = "QuestLogMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},
	
	["Friends"] = {
		tileHeight = 7, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -150},
		callOut	= {parent = "SocialsMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},
	
	["Equip"] = {
		tileHeight = 7, 
		anchorData = {align = "RIGHT", xOff = -25, yOff = -150},
		callOut	= {parent = "CharacterMicroButton", align = "TOPLEFT", xOff = -5, yOff = -17, width = 38, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -18, bottomRight_yOff = 35},
	},
};

function TutorialFrame_OnLoad(self)
	self:RegisterEvent("TUTORIAL_TRIGGER");
	self:RegisterEvent("CINEMATIC_STOP");

	for i = 1, MAX_TUTORIAL_VERTICAL_TILE do
		local texture = self:CreateTexture("TutorialFrameLeft"..i, "BORDER");
		texture:SetTexture("Interface\\TutorialFrame\\UI-TUTORIAL-FRAME");
		texture:SetTexCoord(0.4433594, 0.4628906, 0.521484375, 0.541015625);
		texture:SetSize(11, 10);
		texture = self:CreateTexture("TutorialFrameRight"..i, "BORDER");
		texture:SetTexture("Interface\\TutorialFrame\\UI-TUTORIAL-FRAME");
		texture:SetTexCoord(0.4433594, 0.4550781, 0.812500025, 0.832031275);
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
		texture:SetTexCoord(0.1542969, 0.3007813, 0.5898438, 0.7285156);
		texture:SetSize(76, 72);
		local keyString = self:CreateFontString("TutorialFrameKeyString"..i, "ARTWORK", "GameFontNormalHugeBlack");
		keyString:SetPoint("CENTER", texture, "CENTER", 0, 10);
	end

	TutorialFrame_ClearTextures();
end

function TutorialFrame_OnHide(self)
	PlaySound("igMainMenuClose");
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");
	
	if ( getn(TUTORIALFRAME_QUEUE) <= 0 ) then
		TutorialFrameAlertButton:Hide();
	elseif ( TutorialFrameCheckButton:GetChecked() and not InCombatLockdown() ) then
		TutorialFrame_AlertButton_OnClick(TutorialFrameAlertButton);
	end
end

function TutorialFrame_Update(currentTutorial)
	FlagTutorial(currentTutorial);
	TutorialFrame.id = currentTutorial;
	local title = _G["TUTORIAL_TITLE"..currentTutorial];
	local text = _G["TUTORIAL"..currentTutorial];
	if ( title and text) then
		TutorialFrameTitle:SetText(title);
		TutorialFrameText:SetText(text);
	end
	
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

	if ( displayData.textBox) then
		TutorialFrameText:SetPoint("TOPLEFT", TutorialFrame, "TOPLEFT", displayData.textBox.topLeft_xOff, displayData.textBox.topLeft_yOff);
		TutorialFrameText:SetPoint("BOTTOMRIGHT", TutorialFrame, "BOTTOMRIGHT", displayData.textBox.bottomRight_xOff, displayData.textBox.bottomRight_yOff);
	end
	
	local height = TUTORIALFRAME_TOP_HEIGHT + (displayData.tileHeight * TUTORIALFRAME_MIDDLE_HEIGHT) + TUTORIALFRAME_BOTTOM_HEIGHT;
	TutorialFrame:SetSize(TUTORIALFRAME_WIDTH, height);

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
			if ( imageData.layer) then
				imageTexture:SetDrawLayer(imageData.layer);
			end
			imageTexture:Show();
		end
	end

	-- setup mouse
	local mouseData = displayData.mouseData;
	if(mouseData) then
		local mouseTexture = _G["TutorialFrameMouse"..mouseData.image];
		mouseTexture:SetPoint( mouseData.align, TutorialFrame, mouseData.align, mouseData.xOff, mouseData.yOff );
		if ( mouseData.layer) then
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
			if ( keyData.layer) then
				keyTexture:SetDrawLayer(keyData.layer);
				keyString:SetDrawLayer(keyData.layer);
			end
			keyTexture:Show();
			keyString:Show();
		end
	end

	-- setup arrows
	if ( displayData.arrowUp) then
		TutorialFrameArrowUp:SetPoint( displayData.arrowUp.align, TutorialFrame, displayData.arrowUp.align, displayData.arrowUp.xOff, displayData.arrowUp.yOff );
		if ( displayData.arrowUp.layer) then
			TutorialFrameArrowUp:SetDrawLayer(displayData.arrowUp.layer);
		end
		TutorialFrameArrowUp:Show();
	end
	if ( displayData.arrowDown) then
		TutorialFrameArrowDown:SetPoint( displayData.arrowDown.align, TutorialFrame, displayData.arrowDown.align, displayData.arrowDown.xOff, displayData.arrowDown.yOff );
		if ( displayData.arrowDown.layer) then
			TutorialFrameArrowDown:SetDrawLayer(displayData.arrowDown.layer);
		end
		TutorialFrameArrowDown:Show();
	end
	if ( displayData.arrowCurveRight) then
		TutorialFrameArrowCurveRight:SetPoint( displayData.arrowCurveRight.align, TutorialFrame, displayData.arrowCurveRight.align, displayData.arrowCurveRight.xOff, displayData.arrowCurveRight.yOff );
		if ( displayData.arrowCurveRight.layer) then
			TutorialFrameArrowCurveRight:SetDrawLayer(displayData.arrowCurveRight.layer);
		end
		TutorialFrameArrowCurveRight:Show();
	end
	if ( displayData.arrowCurveLeft) then
		TutorialFrameArrowCurveLeft:SetPoint( displayData.arrowCurveLeft.align, TutorialFrame, displayData.arrowCurveLeft.align, displayData.arrowCurveLeft.xOff, displayData.arrowCurveLeft.yOff );
		if ( displayData.arrowCurveLeft.layer) then
			TutorialFrameArrowCurveLeft:SetDrawLayer(displayData.arrowCurveLeft.layer);
		end
		TutorialFrameArrowCurveLeft:Show();
	end
	
	-- show
	TutorialFrame:Show();
end

function TutorialFrame_ClearTextures()
	TutorialFrame:Hide();
	TutorialFrame:ClearAllPoints();
	TutorialFrameBottom:ClearAllPoints();
	TutorialFrameText:ClearAllPoints();
	
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

	TutorialFrameArrowUp:ClearAllPoints();
	TutorialFrameArrowDown:ClearAllPoints();
	TutorialFrameArrowCurveRight:ClearAllPoints();
	TutorialFrameArrowCurveLeft:ClearAllPoints();
	TutorialFrameArrowUp:Hide();
	TutorialFrameArrowDown:Hide();
	TutorialFrameArrowCurveRight:Hide();
	TutorialFrameArrowCurveLeft:Hide();

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
		imageTexture:Hide();
	end

	for i = 1, MAX_TUTORIAL_KEYS do
		local keyTexture = _G["TutorialFrameKey"..i];
		keyTexture:ClearAllPoints();
		keyTexture:Hide();
		_G["TutorialFrameKeyString"..i]:Hide();
	end
end

function TutorialFrame_NewTutorial(tutorialID)
	local button = TutorialFrameAlertButton;
	tinsert(TUTORIALFRAME_QUEUE, tutorialID);
	if ( not button:IsShown() ) then
		button.id = tutorialID;
		button.tooltip = _G["TUTORIAL_TITLE"..tutorialID];
		button:Enable();
		button:Show();
		if ( not TutorialFrame:IsShown() and TutorialFrameCheckButton:GetChecked() and not InCombatLockdown() ) then
			TutorialFrame_AlertButton_OnClick(button);
		end
	elseif ( button:IsEnabled() == 0 ) then
		button.id = tutorialID;
		button.tooltip = _G["TUTORIAL_TITLE"..tutorialID];
		button:Enable();
	end
end

function TutorialFrame_AlertButton_OnClick(self)
	if ( TUTORIALFRAME_QUEUE[1] ) then
		TutorialFrame_Update(TUTORIALFRAME_QUEUE[1]);

		-- Remove the tutorial from the queue
		tremove(TUTORIALFRAME_QUEUE, 1);

		if ( getn(TUTORIALFRAME_QUEUE) > 0 ) then
			self.id = TUTORIALFRAME_QUEUE[1];
			self.tooltip = _G["TUTORIAL_TITLE"..TUTORIALFRAME_QUEUE[1]];
			if ( GameTooltip:GetOwner() == self ) then
				GameTooltip:SetText(self.tooltip);
			end
		else
			self:Disable();
		end
	end
end

function TutorialFrame_CheckIntro()
	if ( getn(TUTORIALFRAME_QUEUE) > 0 ) then
		TutorialFrame_AlertButton_OnClick( TutorialFrameAlertButton );
	end
end
