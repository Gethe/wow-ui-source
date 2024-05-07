local MAX_TUTORIAL_VERTICAL_TILE = 30;
local MAX_TUTORIAL_IMAGES = 3;
local MAX_TUTORIAL_KEYS = 4;

local TUTORIALFRAME_TOP_HEIGHT = 80;
local TUTORIALFRAME_MIDDLE_HEIGHT = 10;
local TUTORIALFRAME_BOTTOM_HEIGHT = 30;
local TUTORIALFRAME_WIDTH = 364;

local TUTORIAL_LAST_ID = nil;

TUTORIAL_QUEST_ACCEPTED = false; -- used to trigger tutorials after closing the quest log, but after accepting a quest.

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
	["PANDAREN"] = nil,
};
CURRENT_TUTORIAL_QUEST_INFO = nil;


local DISPLAY_DATA = {
	-- layers can be BACKGROUND, BORDER, ARTWORK, OVERLAY, HIGHLIGHT
	-- if you don't assign one it will default to ARTWORK

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
		notNPE = true,
	},

	[22] = { --TUTORIAL_FRIENDS
		tileHeight = 10,
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		callOut	= {parent = "QuickJoinToastButton", align = "TOPLEFT", xOff = -4, yOff = 6, width = 38, height = 45},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
		notNPE = true,
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
		notNPE = true,
	},

	[37] = { --TUTORIAL_DURABILITY_BROKEN
		tileHeight = 18,
		anchorData = {align = "RIGHT", xOff = -105, yOff = -200},
		callOut	= {parent = "DurabilityFrame", align = "TOPLEFT", xOff = -4, yOff = 8, align2 = "BOTTOMRIGHT", xOff2 = 4, yOff2 = -8},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -150, bottomRight_xOff = -29, bottomRight_yOff = 35},
		imageData1 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-RepairCursor", align = "TOP", xOff = 0, yOff = -60},
		imageData2 = {file ="Interface\\TutorialFrame\\UI-TutorialFrame-TheDude", align = "TOP", xOff = -40, yOff = -10},
		mouseData = {image = "RightClick", align = "TOP", xOff = 80, yOff = -40},
	},


	[46] = { --TUTORIAL_RAID
		tileHeight = 14,
		anchorData = {align = "LEFT", xOff = 15, yOff = 30},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},


	[52] = { --TUTORIAL_CRITTER
		tileHeight = 11,
		anchorData = {align = "RIGHT", xOff = -105, yOff = -300},
		callOut	= {parent = "CollectionsMicroButton", align = "TOPLEFT", xOff = -10, yOff = 9, width = 38, height = 42},
		textBox = {topLeft_xOff = 33, topLeft_yOff = -75, bottomRight_xOff = -29, bottomRight_yOff = 35},
	},
};
local DisplayDataFallback = {
	unused = true;
	notNPE = false,
	tileHeight = 0,
};
setmetatable( DISPLAY_DATA, {__index = function () return DisplayDataFallback end });



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
	local prevTutorial = GetPrevCompleatedTutorial(TutorialFrame.id);
	while ( prevTutorial and DISPLAY_DATA[prevTutorial].tileHeight == 0) do
		prevTutorial = GetPrevCompleatedTutorial(prevTutorial);
	end
	if ( prevTutorial ) then
		TutorialFramePrevButton:Enable();
	else
		TutorialFramePrevButton:Disable();
	end

	local nextTutorial = GetNextCompleatedTutorial(TutorialFrame.id);
	while ( nextTutorial and DISPLAY_DATA[nextTutorial].tileHeight == 0) do
		nextTutorial = GetNextCompleatedTutorial(nextTutorial);
	end
	if ( nextTutorial or (getn(TUTORIALFRAME_QUEUE) > 0) ) then
		TutorialFrameNextButton:Enable();
	else
		TutorialFrameNextButton:Disable();
	end
end

function TutorialFrame_Update(currentTutorial)
	if (Kiosk.IsEnabled() and UnitLevel("player") >= GetMaxLevelForExpansionLevel(LE_EXPANSION_LEVEL_PREVIOUS)) then
		return;
	end

	local displayData = DISPLAY_DATA[ currentTutorial ];
	if ( not displayData or displayData.unused ) then
		FlagTutorial(currentTutorial);
		return;
	end

	if ( displayData.notNPE and NewPlayerExperience and NewPlayerExperience:GetIsActive() ) then
		return;
	end

	PlaySound(SOUNDKIT.TUTORIAL_POPUP);
	TutorialFrame_ClearTextures();
	TutorialFrame.id = currentTutorial;
	FlagTutorial(currentTutorial);

	local _, className = UnitClass("player");
	local _, raceName  = UnitRace("player");
	className = strupper(className);
	raceName = strupper(raceName);
	if ( className == "DEATHKNIGHT") then
		raceName = "DEATHKNIGHT";
	end

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
	local title;
	if (displayData.tileHeight > 0) then
		title = _G["TUTORIAL_TITLE"..currentTutorial.."_"..raceName.."_"..className];
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
		if ( callOut.align2 ) then
			TutorialFrameCallOut:SetPoint( callOut.align2, callOut.parent, callOut.align2, callOut.xOff2, callOut.yOff2 );
		else
			TutorialFrameCallOut:SetSize(callOut.width, callOut.height);
		end
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
			keyString:SetText( GetBindingText(GetBindingKey(keyData.command)) );
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
	if not C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.TutorialFrame) or C_PlayerInfo.IsPlayerNPERestricted() then
		return;
	end	

	if(forceShow) then
		TutorialFrame_Update(tutorialID);
		return;
	end

	local displayData = DISPLAY_DATA[ tutorialID ];
	if ( not displayData or displayData.unused ) then
		FlagTutorial(tutorialID);
		return;
	end

	if ( displayData.notNPE and NewPlayerExperience and NewPlayerExperience:GetIsActive() ) then
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
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	local prevTutorial = GetPrevCompleatedTutorial(TutorialFrame.id);
	while ( prevTutorial and DISPLAY_DATA[prevTutorial].tileHeight == 0) do
		prevTutorial = GetPrevCompleatedTutorial(prevTutorial);
	end
	if ( prevTutorial ) then
		TutorialFrame_Update(prevTutorial);
	end
end

function TutorialFrameNextButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
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
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
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


-- *************************************************************************************
HELP_BUTTON_NORMAL_SIZE = 46;
HELP_BUTTON_LARGE_SIZE = 55;

HELP_PLATE_BUTTONS = {};
function HelpPlate_GetButton()
	local frame;
	local i = 1;
	for i=1, #HELP_PLATE_BUTTONS do
		local button = HELP_PLATE_BUTTONS[i];
		if ( not button:IsShown() ) then
			frame = button;
			break;
		end
	end

	if ( not frame ) then
		frame = CreateFrame( "Button", nil, HelpPlate, "HelpPlateButton" );
		frame.box = CreateFrame( "Frame", nil, HelpPlate, "HelpPlateBox" );
		frame.box.button = frame;
		frame.boxHighlight = CreateFrame( "Frame", nil, HelpPlate, "HelpPlateBoxHighlight" );
		table.insert( HELP_PLATE_BUTTONS, frame );
	end
	frame.tooltipDir = "RIGHT";
	frame:SetSize(HELP_BUTTON_NORMAL_SIZE, HELP_BUTTON_NORMAL_SIZE);

	return frame;
end

function HelpPlateBox_OnLoad(self)
	for i=1, #self.Textures do
		self.Textures[i]:SetVertexColor( 1, 0.82, 0 );
	end
end

function HelpPlateBox_OnEnter(self)
	HelpPlate_Button_OnEnter(self.button);
end

function HelpPlateBox_OnLeave(self)
	HelpPlate_Button_OnLeave(self.button);
end

function HelpPlate_ShowTutorialPrompt( self, mainHelpButton )
	if Kiosk.IsEnabled() then
		return;
	end
	mainHelpButton.initialTutorial = true;
	Main_HelpPlate_Button_ShowTooltip(mainHelpButton);
	HelpPlateTooltip.LingerAndFade:Play();
	HelpPlateTooltip.target = self;
end

function HelpPlateTooltip_IsShowing(target)
	return HelpPlateTooltip:IsVisible() and HelpPlateTooltip.target == target;
end

local HELP_PLATE_CURRENT_PLATE = nil;
function HelpPlate_Show( self, parent, mainHelpButton )
	if ( HELP_PLATE_CURRENT_PLATE ) then
		HelpPlate_Hide();
	end

	HELP_PLATE_CURRENT_PLATE = self;
	HELP_PLATE_CURRENT_PLATE.mainHelpButton = mainHelpButton;
	for i = 1, #self do
		if ( not self[i].MinLevel or (UnitLevel("player") >= self[i].MinLevel) ) then
			local button = HelpPlate_GetButton();
			button:ClearAllPoints();
			button:SetPoint( "TOPLEFT", HelpPlate, "TOPLEFT", self[i].ButtonPos.x, self[i].ButtonPos.y );
			button.tooltipDir = self[i].ToolTipDir;
			button.toolTipText = self[i].ToolTipText;
			button.viewed = false;
			button:Show();
			if ( mainHelpButton.initialTutorial ) then
				button.HelpIGlow:Show();
				button.BgGlow:Show();
				button.Pulse:Play();
			else
				button.HelpIGlow:Hide();
				button.BgGlow:Hide();
				button.Pulse:Stop();
			end

			button.box:ClearAllPoints();
			button.box:SetSize( self[i].HighLightBox.width, self[i].HighLightBox.height );
			button.box:SetPoint( "TOPLEFT", HelpPlate, "TOPLEFT", self[i].HighLightBox.x, self[i].HighLightBox.y );
			button.box:Show();

			button.boxHighlight:ClearAllPoints();
			button.boxHighlight:SetSize( self[i].HighLightBox.width, self[i].HighLightBox.height );
			button.boxHighlight:SetPoint( "TOPLEFT", HelpPlate, "TOPLEFT", self[i].HighLightBox.x, self[i].HighLightBox.y );
			button.boxHighlight:Hide();
		end
	end
	HelpPlate:SetPoint( "TOPLEFT", parent, "TOPLEFT", self.FramePos.x, self.FramePos.y );
	HelpPlate:SetSize( self.FrameSize.width, self.FrameSize.height );
	HelpPlate:Show();
end

function HelpPlate_Hide(userToggled)
	if ( not HELP_PLATE_CURRENT_PLATE ) then
		return;
	end

	HELP_PLATE_CURRENT_PLATE.mainHelpButton.initialTutorial = false;

	if (not userToggled) then
		for i = 1, #HELP_PLATE_BUTTONS do
			local button = HELP_PLATE_BUTTONS[i];
			button.tooltipDir = "RIGHT";
			button.box:Hide();
			button:Hide();
		end
		HELP_PLATE_CURRENT_PLATE = nil;
		HelpPlate:Hide();
		return
	end

	-- else animate out
	-- look in HelpPlate_Button_AnimGroup_Show_OnFinished for final cleanup code
	if ( HELP_PLATE_CURRENT_PLATE ) then
		for i = 1, #HELP_PLATE_BUTTONS do
			local button = HELP_PLATE_BUTTONS[i];
			button.tooltipDir = "RIGHT";
			if ( button:IsShown() ) then
				if ( button.animGroup_Show:IsPlaying() ) then
					button.animGroup_Show:Stop();
				end
				button.animGroup_Show:SetScript("OnFinished", HelpPlate_Button_AnimGroup_Show_OnFinished);
				button.animGroup_Show.translate:SetDuration(0.3);
				button.animGroup_Show.alpha:SetDuration(0.3);
				button.animGroup_Show:Play();
			end
		end
	end
end

function HelpPlate_IsShowing(plate)
	return (HELP_PLATE_CURRENT_PLATE == plate);
end

function HelpPlate_Button_OnLoad(self)
	self.animGroup_Show = self:CreateAnimationGroup();
	self.animGroup_Show.translate = self.animGroup_Show:CreateAnimation("Translation");
	self.animGroup_Show.translate:SetSmoothing("IN");
	self.animGroup_Show.alpha = self.animGroup_Show:CreateAnimation("Alpha");
	self.animGroup_Show.alpha:SetFromAlpha(1);
	self.animGroup_Show.alpha:SetToAlpha(0);
	self.animGroup_Show.alpha:SetSmoothing("IN");
	self.animGroup_Show.parent = self;
end

function HelpPlate_Button_AnimGroup_Show_OnFinished(self)
	-- hide the parent button
	self.parent:Hide();
	self:SetScript("OnFinished", nil);

	-- lets see if we can cleanup the help plate now.
	for i = 1, #HELP_PLATE_BUTTONS do
		local button = HELP_PLATE_BUTTONS[i];
		if ( button:IsShown() ) then
			return;
		end
	end

	-- we are done animating. lets hide everything
	for i = 1, #HELP_PLATE_BUTTONS do
		local button = HELP_PLATE_BUTTONS[i];
		button.box:Hide();
		button.boxHighlight:Hide();
	end

	HELP_PLATE_CURRENT_PLATE = nil;
	HelpPlate:Hide();
end

function HelpPlate_Button_OnShow(self)
	local point, relative, relPoint, xOff, yOff = self:GetPoint(1);
	self.animGroup_Show.translate:SetOffset( (-1*xOff), (-1*yOff) );
	self.animGroup_Show.translate:SetDuration(0.5);
	self.animGroup_Show.alpha:SetDuration(0.5);
	self.animGroup_Show:Play(true);
end

function HelpPlate_Button_OnEnter(self)
	HelpPlate_TooltipHide();

	if ( self.tooltipDir == "UP" ) then
		HelpPlateTooltip.ArrowUP:Show();
		HelpPlateTooltip.ArrowGlowUP:Show();
		HelpPlateTooltip:SetPoint("BOTTOM", self, "TOP", 0, 10);
	elseif ( self.tooltipDir == "DOWN" ) then
		HelpPlateTooltip.ArrowDOWN:Show();
		HelpPlateTooltip.ArrowGlowDOWN:Show();
		HelpPlateTooltip:SetPoint("TOP", self, "BOTTOM", 0, -10);
	elseif ( self.tooltipDir == "LEFT" ) then
		HelpPlateTooltip.ArrowLEFT:Show();
		HelpPlateTooltip.ArrowGlowLEFT:Show();
		HelpPlateTooltip:SetPoint("RIGHT", self, "LEFT", -10, 0);
	elseif ( self.tooltipDir == "RIGHT" ) then
		HelpPlateTooltip.ArrowRIGHT:Show();
		HelpPlateTooltip.ArrowGlowRIGHT:Show();
		HelpPlateTooltip:SetPoint("LEFT", self, "RIGHT", 10, 0);
	end
	HelpPlateTooltip.Text:SetText(self.toolTipText)
	HelpPlateTooltip:Show();
	self.box.BG:Hide();
	self.boxHighlight:Show();
	self.Pulse:Stop();
	self.HelpIGlow:Hide();
	self.BgGlow:Hide();
end

function HelpPlate_Button_OnLeave(self)
	HelpPlate_TooltipHide();
	self.box.BG:Show();
	self.boxHighlight:Hide();
	self.viewed = true;

	-- remind the player to use the main button to toggle the help plate
	-- but only if this is the first time they have opened the UI and are
	-- going through the initial tutorial
	if ( HELP_PLATE_CURRENT_PLATE.mainHelpButton.initialTutorial ) then
		for i = 1, #HELP_PLATE_BUTTONS do
			local button = HELP_PLATE_BUTTONS[i];
			if ( button:IsShown() and not button.viewed ) then
				return;
			end
		end
		Main_HelpPlate_Button_OnEnter(HELP_PLATE_CURRENT_PLATE.mainHelpButton);
	end
end

function HelpPlate_TooltipHide()
	HelpPlateTooltip.ArrowUP:Hide();
	HelpPlateTooltip.ArrowGlowUP:Hide();
	HelpPlateTooltip.ArrowDOWN:Hide();
	HelpPlateTooltip.ArrowGlowDOWN:Hide();
	HelpPlateTooltip.ArrowLEFT:Hide();
	HelpPlateTooltip.ArrowGlowLEFT:Hide();
	HelpPlateTooltip.ArrowRIGHT:Hide();
	HelpPlateTooltip.ArrowGlowRIGHT:Hide();
	HelpPlateTooltip:ClearAllPoints();
	HelpPlateTooltip:Hide();
end
