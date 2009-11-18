local QUEST_POI_BUTTONS_MAX = { };				-- max of a button created
local QUEST_POI_BUTTONS_SELECTED = { };			-- selected button
QUEST_POI_SWAP_BUTTONS = { };				-- buttons that need to swap in (for QUEST_POI_COMPLETE_SWAP type)
QUEST_POI_ICONS_PER_ROW = 8;
QUEST_POI_ICON_SIZE = 0.125;

-- POI types
local QUEST_POI_MAX_TYPES = 4;
QUEST_POI_NUMERIC = 1;				-- number within a circle
QUEST_POI_COMPLETE_IN = 2;			-- completed quest icon within a normal circle
QUEST_POI_COMPLETE_OUT = 3;			-- completed quest icon within a darker circle (quest outside current zone)
QUEST_POI_COMPLETE_SWAP = 4;		-- completed quest icon without a circle that needs to be swapped on selection (for map)

-- POI text colors (offsets into texture)
local QUEST_POI_COLOR_BLACK = 0;
local QUEST_POI_COLOR_YELLOW = 0.5;

function QuestPOI_DisplayButton(parentName, buttonType, buttonIndex, questId)
	local buttonName = "poi"..parentName..buttonType.."_"..buttonIndex;
	local poiButton = _G[buttonName];
	local swapButton;
	
	if ( not poiButton ) then
		if ( buttonType == QUEST_POI_COMPLETE_SWAP ) then
			poiButton = CreateFrame("Button", buttonName, _G[parentName], "QuestPOICompletedTemplate");
			if ( not QUEST_POI_SWAP_BUTTONS[parentName] ) then
				swapButton = true;
			end
		else
			poiButton = CreateFrame("Button", buttonName, _G[parentName], "QuestPOITemplate");
		end
		-- frame-specific stuff
		if ( parentName == "WatchFrameLines" ) then
			poiButton:SetScale(0.9);
			poiButton:SetScript("OnClick", WatchFrameQuestPOI_OnClick);
		elseif ( parentName == "WorldMapPOIFrame" ) then
			poiButton:SetScript("OnEnter", WorldMapQuestPOI_OnEnter);
			poiButton:SetScript("OnLeave", WorldMapQuestPOI_OnLeave);
			poiButton:SetScript("OnClick", WorldMapQuestPOI_OnClick);
			if ( swapButton ) then
				swapButton = CreateFrame("Button", "poi"..parentName.."_Swap", _G[parentName], "QuestPOITemplate");
				QUEST_POI_SWAP_BUTTONS[parentName] = swapButton;
				swapButton.type = buttonType;
				swapButton:SetScript("OnEnter", WorldMapQuestPOI_OnEnter);
				swapButton:SetScript("OnLeave", WorldMapQuestPOI_OnLeave);
				swapButton:SetScript("OnClick", WorldMapQuestPOI_OnClick);
				swapButton:SetFrameLevel(poiButton:GetFrameLevel() + 2);
				swapButton.selectionGlow:Show();
				swapButton.normalTexture:SetTexCoord(0.500, 0.625, 0.375, 0.5);
				swapButton.pushedTexture:SetTexCoord(0.375, 0.500, 0.375, 0.5);
				swapButton.highlightTexture:SetTexCoord(0.625, 0.750, 0.375, 0.5);
				swapButton.turnin:Show();
				swapButton.number:Hide();		
			end
		end
		-- *
		poiButton.index = buttonIndex;
		poiButton.type = buttonType;
		poiButton.parentName = parentName;
		QUEST_POI_BUTTONS_MAX[parentName..buttonType] = buttonIndex;
		if ( buttonType == QUEST_POI_COMPLETE_IN ) then
			poiButton.turnin:Show();
			poiButton.number:Hide();
		elseif ( buttonType == QUEST_POI_COMPLETE_OUT ) then
			poiButton.turnin:Show();
			poiButton.number:Hide();
			poiButton.normalTexture:SetTexCoord(0.500, 0.625, 0.875, 1.0);
			poiButton.pushedTexture:SetTexCoord(0.375, 0.500, 0.875, 1.0);
			poiButton.highlightTexture:SetTexCoord(0.625, 0.750, 0.375, 0.5);
		elseif ( buttonType == QUEST_POI_NUMERIC ) then
			buttonIndex = buttonIndex - 1;
			local yOffset = 0.5 + floor(buttonIndex / QUEST_POI_ICONS_PER_ROW) * QUEST_POI_ICON_SIZE;
			local xOffset = mod(buttonIndex, QUEST_POI_ICONS_PER_ROW) * QUEST_POI_ICON_SIZE;
			poiButton.number:SetTexCoord(xOffset, xOffset + QUEST_POI_ICON_SIZE, yOffset, yOffset + QUEST_POI_ICON_SIZE);
		end
	end
	poiButton.questId = questId;
	if ( poiButton.isSelected ) then
		QuestPOI_DeselectButton(poiButton);
	end
	poiButton:Show();
	return poiButton;
end

local function QuestPOI_FindButtonByQuestId(parentName, questId)
	local poiButton;
	local numButtons;
		
	for i = 1, QUEST_POI_MAX_TYPES do
		numButtons = QUEST_POI_BUTTONS_MAX[parentName..i];
		if ( numButtons ) then
			for j = 1, numButtons do
				poiButton = _G["poi"..parentName..i.."_"..j];
				if ( poiButton.questId == questId ) then
					return poiButton;
				end
			end
		end
	end
end

function QuestPOI_SelectButtonByIndex(parentName, buttonType, buttonIndex)
	QuestPOI_SelectButton(_G["poi"..parentName..buttonType.."_"..buttonIndex]);
end

function QuestPOI_SelectButtonByQuestId(parentName, questId, deselectOnFail)
	local poiButton = QuestPOI_FindButtonByQuestId(parentName, questId);
	if ( poiButton ) then
		QuestPOI_SelectButton(poiButton);
	elseif ( deselectOnFail ) then
		poiButton = QUEST_POI_BUTTONS_SELECTED[parentName];
		if ( poiButton ) then
			QuestPOI_DeselectButton(poiButton);
		end
	end
end

function QuestPOI_SelectButton(poiButton)
	if ( poiButton ) then
		local parentName = poiButton.parentName;
		if ( QUEST_POI_BUTTONS_SELECTED[parentName] ) then
			-- return if already selected
			if ( QUEST_POI_BUTTONS_SELECTED[parentName] == poiButton ) then
				return;
			else
				QuestPOI_DeselectButton(QUEST_POI_BUTTONS_SELECTED[parentName]);
			end		
		end
		-- select
		QUEST_POI_BUTTONS_SELECTED[parentName] = poiButton;
		poiButton.isSelected = true;		
		if ( poiButton.type == QUEST_POI_NUMERIC ) then
			poiButton.selectionGlow:Show();
			poiButton.normalTexture:SetTexCoord(0.500, 0.625, 0.375, 0.5);
			poiButton.pushedTexture:SetTexCoord(0.375, 0.500, 0.375, 0.5);
			poiButton.highlightTexture:SetTexCoord(0.625, 0.750, 0.375, 0.5);
			QuestPOI_SetTextColor(poiButton, QUEST_POI_COLOR_BLACK);
		elseif ( poiButton.type == QUEST_POI_COMPLETE_IN ) then
			poiButton.selectionGlow:Show();
			poiButton.normalTexture:SetTexCoord(0.500, 0.625, 0.375, 0.5);
			poiButton.pushedTexture:SetTexCoord(0.375, 0.500, 0.375, 0.5);
			poiButton.highlightTexture:SetTexCoord(0.625, 0.750, 0.375, 0.5);		
		elseif ( poiButton.type == QUEST_POI_COMPLETE_OUT ) then
			-- has no selected mode, should switch to QUEST_POI_COMPLETE_IN type upon being selected
		elseif ( poiButton.type == QUEST_POI_COMPLETE_SWAP ) then
			local swapButton = QUEST_POI_SWAP_BUTTONS[parentName];
			swapButton:ClearAllPoints();
			swapButton:SetPoint("CENTER", poiButton);
			swapButton.quest = poiButton.quest;
			swapButton:Show();
			poiButton:Hide();
		end
	end
end

function QuestPOI_DeselectButtonByParent(parentName)
	QuestPOI_DeselectButton(QUEST_POI_BUTTONS_SELECTED[parentName]);
end

function QuestPOI_DeselectButton(poiButton)
	if ( poiButton and poiButton.isSelected ) then
		if ( poiButton.type == QUEST_POI_NUMERIC ) then
			poiButton.selectionGlow:Hide();
			poiButton.normalTexture:SetTexCoord(0.875, 1, 0.875, 1);
			poiButton.pushedTexture:SetTexCoord(0.750, 0.875, 0.875, 1);
			poiButton.highlightTexture:SetTexCoord(0.625, 0.750, 0.875, 1);
			QuestPOI_SetTextColor(poiButton, QUEST_POI_COLOR_YELLOW);
		elseif ( poiButton.type == QUEST_POI_COMPLETE_IN ) then
			poiButton.selectionGlow:Hide();
			poiButton.normalTexture:SetTexCoord(0.875, 1, 0.875, 1);
			poiButton.pushedTexture:SetTexCoord(0.750, 0.875, 0.875, 1);
			poiButton.highlightTexture:SetTexCoord(0.625, 0.750, 0.875, 1);
		elseif ( poiButton.type == QUEST_POI_COMPLETE_OUT ) then
			-- has no selected mode
		elseif ( poiButton.type == QUEST_POI_COMPLETE_SWAP ) then
			poiButton:Show();
			QUEST_POI_SWAP_BUTTONS[poiButton.parentName]:Hide();
		end
		QUEST_POI_BUTTONS_SELECTED[poiButton.parentName] = nil;
		poiButton.isSelected = false;
	end
end

function QuestPOI_SetTextColor(poiButton, yOffset)
	local index = poiButton.index - 1
	yOffset = yOffset + floor(index / QUEST_POI_ICONS_PER_ROW) * QUEST_POI_ICON_SIZE;
	local xOffset = mod(index, QUEST_POI_ICONS_PER_ROW) * QUEST_POI_ICON_SIZE;
	poiButton.number:SetTexCoord(xOffset, xOffset + QUEST_POI_ICON_SIZE, yOffset, yOffset + QUEST_POI_ICON_SIZE);	
end

function QuestPOI_HideButtons(parentName, buttonType, buttonIndex)
	local numButtons;
		
	numButtons = QUEST_POI_BUTTONS_MAX[parentName..buttonType];
	if ( numButtons ) then
		local poiButton;
		local buttonName = "poi"..parentName..buttonType.."_";
		for i = buttonIndex, numButtons do
			poiButton = _G[buttonName..i];
			if ( poiButton.isSelected and poiButton.type == QUEST_POI_COMPLETE_SWAP ) then
				QuestPOI_DeselectButton(poiButton);
			end
			poiButton:Hide();
		end
	end
end

function QuestPOI_HideAllButtons(parentName)
	local numButtons;
	
	for i = 1, QUEST_POI_MAX_TYPES do
		numButtons = QUEST_POI_BUTTONS_MAX[parentName..i];
		if ( numButtons ) then
			local poiButton;
			local buttonName = "poi"..parentName..i.."_";
			for j = 1, numButtons do
				poiButton = _G[buttonName..j];
				if ( poiButton.isSelected and poiButton.type == QUEST_POI_COMPLETE_SWAP ) then
					QuestPOI_DeselectButton(poiButton);
				end
				poiButton:Hide();
			end
		end
	end
end

function QuestPOIButton_OnMouseDown(self)
	if ( self.isComplete ) then
		self.turnin:SetPoint("CENTER", 0, -1);
	else
		self.number:SetPoint("CENTER", 1, -1);
	end
end

function QuestPOIButton_OnMouseUp(self)
	if ( self.isComplete ) then
		self.turnin:SetPoint("CENTER", -1, 0);
	else
		self.number:SetPoint("CENTER", 0, 0);
	end
end