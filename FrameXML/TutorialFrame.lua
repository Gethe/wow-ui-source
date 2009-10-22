MAX_TUTORIAL_VERTICAL_TILE = 30;
MAX_TUTORIAL_IMAGES = 3;
MAX_TUTORIAL_KEYS = 4;

TUTORIALFRAME_TOP_HEIGHT = 80;
TUTORIALFRAME_MIDDLE_HEIGHT = 10;
TUTORIALFRAME_BOTTOM_HEIGHT = 15;
TUTORIALFRAME_WIDTH = 364;

TUTORIALFRAME_QUEUE = { };

TUTORIAL_DATA = {
--	[37] = "CrazyEight",
--	[38] = "CrazyEight",
--	[42] = "CrazyEight",
};

DISPLAY_DATA = {
	-- Do not remove "Base" it is the default
	["Base"] = {
		tileHeight = 4, 
		anchorData = {align = "CENTER", xOff = 0, yOff = 0}
	},

	-- layers can be BACKGROUND, BORDER, ARTWORK, OVERLAY, HIGHLIGHT
	-- if you don't assign one it will default to ARTWORK
	["CrazyEight"] = {
		tileHeight = 30, 
		anchorData = {align = "TOPLEFT", xOff = 100, yOff = -300},
		callOut	= {parent = "PlayerFrame", align = "TOPLEFT", xOff = 0, yOff = 0, width = 300, height = 100},
		textBox = {topLeft_xOff = -10, topLeft_yOff = -10, bottomRight_xOff = -10, bottomRight = -10},
		imageData1 = {file ="UI-TutorialFrame-QuestCursor", align = "TOPLEFT", xOff = 100, yOff = -300},
		imageData2 = {file ="UI-TutorialFrame-QuestGiver", align = "TOPLEFT", xOff = 100, yOff = -300},
		mouseData = {image = "RightClick", align = "TOPRIGHT", xOff = -20, yOff = 15},
		keyData1 = {command = "TURNLEFT", layer = "OVERLAY", align = "TOPLEFT", xOff = 35, yOff = -70},
		keyData2 = {command = "MOVEBACKWARD", layer = "OVERLAY", align = "TOPLEFT", xOff = 90, yOff = -70},
		keyData3 = {command = "TURNRIGHT", layer = "OVERLAY", align = "TOPLEFT", xOff = 145, yOff = -70},
		keyData4 = {command = "MOVEFORWARD", align = "TOPLEFT", xOff = 90, yOff = -30},
		arrowUp = {layer = "OVERLAY", align = "TOPRIGHT", xOff = 30, yOff = 0},
		arrowCurveRight = {layer = "OVERLAY", align = "TOPRIGHT", xOff = 60, yOff = 0},
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
	if ( not TutorialFrameCheckButton:GetChecked() ) then
		ClearTutorials();
		return;
	end
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");
	if ( getn(TUTORIALFRAME_QUEUE) > 0 ) then
		TutorialFrame_AlertButton_OnClick( TUTORIALFRAME_QUEUE[1] );
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

	-- Remove the tutorial from the queue
	for index, value in pairs(TUTORIALFRAME_QUEUE) do
		if ( value == currentTutorial ) then
			tremove(TUTORIALFRAME_QUEUE, index);
		end
	end
end

function TutorialFrame_ClearTextures()
	TutorialFrame:Hide();
	TutorialFrame:ClearAllPoints();
	TutorialFrameBottom:ClearAllPoints();
	
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
	if ( not TutorialFrame:IsShown() ) then
		TutorialFrame_Update(tutorialID);
		return;
	else
		tinsert(TUTORIALFRAME_QUEUE, tutorialID);
	end

	local button = TutorialFrameAlertButton;
	if ( not button:IsShown() ) then
		button.id = tutorialID;
		button.tooltip = _G["TUTORIAL_TITLE"..tutorialID];
		button:Show();
	end
end

function TutorialFrame_AlertButton_OnClick(id)
	TutorialFrame_Update(id);
	if ( getn(TUTORIALFRAME_QUEUE) <= 0 ) then
		TutorialFrameAlertButton:Hide();
	end
end

function TutorialFrame_CheckIntro()
	if ( getn(TUTORIALFRAME_QUEUE) > 0 ) then
		TutorialFrame_AlertButton_OnClick( TUTORIALFRAME_QUEUE[1] );
	end
end