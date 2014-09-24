local QUEST_POI_ICONS_PER_ROW = 8;
local QUEST_POI_ICON_SIZE = 0.125;
-- POI text colors (offsets into texture)
local QUEST_POI_COLOR_BLACK = 0;
local QUEST_POI_COLOR_YELLOW = 0.5;

function QuestPOI_Initialize(parent, onCreateFunc)
	parent.poiTable = {
		["numeric"] = { };
		["completed"] = { };
	};
	parent.poiOnCreateFunc = onCreateFunc;
end


function QuestPOI_ResetUsage(parent)
	for _, poiType in pairs(parent.poiTable) do
		for _, poiButton in pairs(poiType) do
			poiButton.used = nil;
		end			
	end
	QuestPOI_ClearSelection(parent);
end

function QuestPOI_GetButton(parent, questID, style, index, storyQuest)
	local poiButton;
	if ( style == "numeric" ) then
		-- numbered POI
		poiButton = parent.poiTable["numeric"][index];
		if ( not poiButton ) then
			poiButton = CreateFrame("Button", nil, parent, "QuestPOINumericTemplate");			
			parent.poiTable["numeric"][index] = poiButton;
			local iconIndex = index - 1;
			local yOffset = 0.5 + floor(iconIndex / QUEST_POI_ICONS_PER_ROW) * QUEST_POI_ICON_SIZE;
			local xOffset = mod(iconIndex, QUEST_POI_ICONS_PER_ROW) * QUEST_POI_ICON_SIZE;
			poiButton.Number:SetTexCoord(xOffset, xOffset + QUEST_POI_ICON_SIZE, yOffset, yOffset + QUEST_POI_ICON_SIZE);
			poiButton.index = index;
			if ( parent.poiOnCreateFunc ) then
				parent.poiOnCreateFunc(poiButton);
			end
		end
		if ( storyQuest and not poiButton.storyQuest ) then		
			poiButton.NormalTexture:SetTexCoord(0.875, 1, 0.375, 0.5);
			poiButton.PushedTexture:SetTexCoord(0.750, 0.875, 0.375, 0.5);
			poiButton.HighlightTexture:SetTexCoord(0.625, 0.750, 0.875, 1);
			poiButton.Glow:SetSize(64, 64);
		elseif ( not storyQuest and poiButton.storyQuest ) then
			poiButton.NormalTexture:SetTexCoord(0.875, 1, 0.875, 1);
			poiButton.PushedTexture:SetTexCoord(0.625, 0.750, 0.875, 1);
			poiButton.HighlightTexture:SetTexCoord(0.625, 0.750, 0.375, 0.5);
			poiButton.Glow:SetSize(50, 50);
		end
	else		
		-- completed POI
		for _, button in pairs(parent.poiTable["completed"]) do
			if ( not button.used ) then
				poiButton = button;
				break;
			end
		end
		if ( not poiButton ) then
			poiButton = CreateFrame("Button", nil, parent, "QuestPOICompletedTemplate");			
			tinsert(parent.poiTable["completed"], poiButton);
			if ( parent.poiOnCreateFunc ) then
				parent.poiOnCreateFunc(poiButton);
			end
		end
		if ( poiButton.style ~= style or poiButton.storyQuest ~= storyQuest ) then
			-- default style is "normal"
			if ( style == "normal" ) then
				poiButton.FullHighlightTexture:Show();
				poiButton.IconHighlightTexture:Hide();
				poiButton.Icon:SetSize(24, 24);
				poiButton.NormalTexture:SetAlpha(1);
				poiButton.PushedTexture:SetAlpha(1);
				if ( storyQuest ) then
					poiButton.NormalTexture:SetTexCoord(0.875, 1, 0.375, 0.5);
					poiButton.PushedTexture:SetTexCoord(0.750, 0.875, 0.375, 0.5);
					poiButton.FullHighlightTexture:SetTexCoord(0.625, 0.750, 0.875, 1);
					poiButton.Glow:SetSize(64, 64);				
				else
					poiButton.NormalTexture:SetTexCoord(0.875, 1, 0.875, 1);
					poiButton.PushedTexture:SetTexCoord(0.750, 0.875, 0.875, 1);
					poiButton.FullHighlightTexture:SetTexCoord(0.625, 0.750, 0.375, 0.5);
					poiButton.Glow:SetSize(50, 50);	
				end
			elseif ( style == "map" ) then
				poiButton.FullHighlightTexture:Hide();
				poiButton.IconHighlightTexture:Show();
				poiButton.Icon:SetSize(32, 32);
				poiButton.NormalTexture:SetAlpha(0);
				poiButton.PushedTexture:SetAlpha(0);
			elseif ( style == "remote" ) then
				poiButton.FullHighlightTexture:Show();
				poiButton.IconHighlightTexture:Hide();
				poiButton.Icon:SetSize(24, 24);
				poiButton.NormalTexture:SetAlpha(1);
				poiButton.PushedTexture:SetAlpha(1);
				if ( storyQuest ) then
					poiButton.NormalTexture:SetTexCoord(0.250, 0.375, 0.875, 1);
					poiButton.PushedTexture:SetTexCoord(0.125, 0.250, 0.875, 1);
					poiButton.FullHighlightTexture:SetTexCoord(0.625, 0.750, 0.875, 1);
					poiButton.Glow:SetSize(64, 64);				
				else
					poiButton.NormalTexture:SetTexCoord(0.500, 0.625, 0.875, 1.0);
					poiButton.PushedTexture:SetTexCoord(0.375, 0.500, 0.875, 1.0);
					poiButton.FullHighlightTexture:SetTexCoord(0.625, 0.750, 0.375, 0.5);
					poiButton.Glow:SetSize(50, 50);
				end
			end
		end
	end

	poiButton.questID = questID;
	poiButton.style = style;
	poiButton.storyQuest = storyQuest;
	poiButton.used = true;
	poiButton:Show();

	return poiButton;
end

function QuestPOI_FindButton(parent, questID)
	if ( parent.poiTable ) then
		for _, poiType in pairs(parent.poiTable) do
			for _, poiButton in pairs(poiType) do
				if ( poiButton.questID == questID and poiButton.used ) then
					return poiButton;
				end
			end
		end
	end
end

function QuestPOI_SelectButtonByQuestID(parent, questID)
	local poiButton = QuestPOI_FindButton(parent, questID);
	if ( poiButton ) then
		QuestPOI_SelectButton(poiButton);
	else
		QuestPOI_ClearSelection(parent);
	end
end

function QuestPOI_SelectButton(poiButton)
	local parent = poiButton:GetParent();
	if ( parent.poiSelectedButton ) then
		if ( parent.selectedPOI == poiButton ) then
			return;
		else
			QuestPOI_ClearSelection(parent);
		end
	end

	local style = poiButton.style;
	if ( style == "numeric" ) then
		if ( poiButton.storyQuest ) then
			poiButton.NormalTexture:SetTexCoord(0.250, 0.375, 0.375, 0.5);
			poiButton.PushedTexture:SetTexCoord(0.125, 0.250, 0.375, 0.5);	
		else
			poiButton.NormalTexture:SetTexCoord(0.500, 0.625, 0.375, 0.5);
			poiButton.PushedTexture:SetTexCoord(0.375, 0.500, 0.375, 0.5);
		end
		QuestPOI_SetTextColor(poiButton, QUEST_POI_COLOR_BLACK);
	else
		if ( poiButton.storyQuest ) then
			poiButton.NormalTexture:SetTexCoord(0.250, 0.375, 0.375, 0.5);
			poiButton.PushedTexture:SetTexCoord(0.125, 0.250, 0.375, 0.5);		
		else
			poiButton.NormalTexture:SetTexCoord(0.500, 0.625, 0.375, 0.5);
			poiButton.PushedTexture:SetTexCoord(0.375, 0.500, 0.375, 0.5);
		end
		if ( style == "map" ) then
			poiButton.FullHighlightTexture:Show();
			poiButton.IconHighlightTexture:Hide();
			poiButton.Icon:SetSize(24, 24);
			poiButton.NormalTexture:SetAlpha(1);
			poiButton.PushedTexture:SetAlpha(1);
		end
	end
	poiButton.Glow:Show();	
	poiButton.selected = true;
	parent.poiSelectedButton = poiButton;
end

function QuestPOI_ClearSelection(parent)
	local poiButton = parent.poiSelectedButton;
	if ( poiButton ) then
		local style = poiButton.style;
		if ( style == "numeric" ) then
			if ( poiButton.storyQuest ) then
				poiButton.NormalTexture:SetTexCoord(0.875, 1, 0.375, 0.5);
				poiButton.PushedTexture:SetTexCoord(0.750, 0.875, 0.375, 0.5);	
			else
				poiButton.NormalTexture:SetTexCoord(0.875, 1, 0.875, 1);
				poiButton.PushedTexture:SetTexCoord(0.750, 0.875, 0.875, 1);
			end
			QuestPOI_SetTextColor(poiButton, QUEST_POI_COLOR_YELLOW);
		elseif ( style == "normal" ) then
			if ( poiButton.storyQuest ) then
				poiButton.NormalTexture:SetTexCoord(0.875, 1, 0.375, 0.5);
				poiButton.PushedTexture:SetTexCoord(0.750, 0.875, 0.375, 0.5);			
			else
				poiButton.NormalTexture:SetTexCoord(0.875, 1, 0.875, 1);
				poiButton.PushedTexture:SetTexCoord(0.750, 0.875, 0.875, 1);
			end
		elseif ( style == "remote" ) then
			if ( poiButton.storyQuest ) then
				poiButton.NormalTexture:SetTexCoord(0.250, 0.375, 0.875, 1);
				poiButton.PushedTexture:SetTexCoord(0.125, 0.250, 0.875, 1);			
			else		
				poiButton.NormalTexture:SetTexCoord(0.500, 0.625, 0.875, 1.0);
				poiButton.PushedTexture:SetTexCoord(0.375, 0.500, 0.875, 1.0);
			end
		elseif ( style == "map" ) then
			poiButton.FullHighlightTexture:Hide();
			poiButton.IconHighlightTexture:Show();
			poiButton.Icon:SetSize(32, 32);
			poiButton.NormalTexture:SetAlpha(0);
			poiButton.PushedTexture:SetAlpha(0);		
		end
		poiButton.Glow:Hide();
		poiButton.selected = nil;
		parent.poiSelectedButton = nil;
	end
end

function QuestPOI_SetTextColor(poiButton, yOffset)
	local index = poiButton.index - 1
	yOffset = yOffset + floor(index / QUEST_POI_ICONS_PER_ROW) * QUEST_POI_ICON_SIZE;
	local xOffset = mod(index, QUEST_POI_ICONS_PER_ROW) * QUEST_POI_ICON_SIZE;
	poiButton.Number:SetTexCoord(xOffset, xOffset + QUEST_POI_ICON_SIZE, yOffset, yOffset + QUEST_POI_ICON_SIZE);	
end

function QuestPOI_HideUnusedButtons(parent)
	for _, poiType in pairs(parent.poiTable) do
		for _, poiButton in pairs(poiType) do
			if ( not poiButton.used ) then
				poiButton:Hide();
			end
		end
	end
end

function QuestPOI_HideAllButtons(parent)
	for _, poiType in pairs(parent.poiTable) do
		for _, poiButton in pairs(poiType) do
			poiButton.used = nil;
			poiButton:Hide();
		end
	end
end

function QuestPOIButton_OnMouseDown(self)
	if ( self.style == "numeric" ) then
		self.Number:SetPoint("CENTER", 1, -1);
	else
		self.Icon:SetPoint("CENTER", 0, -1);
	end
end

function QuestPOIButton_OnMouseUp(self)
	if ( self.style == "numeric" ) then
		self.Number:SetPoint("CENTER", 0, 0);
	else
		self.Icon:SetPoint("CENTER", -1, 0);
	end
end

function QuestPOIButton_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	local questID = self.questID;	
	local questLogIndex = GetQuestLogIndexByID(questID);
	if ( IsQuestWatched(questLogIndex) ) then
		if ( IsShiftKeyDown() ) then
			QuestObjectiveTracker_UntrackQuest(nil, questLogIndex);
			return;
		end
	else
		AddQuestWatch(questLogIndex, true);
	end
	SetSuperTrackedQuestID(questID);
	WorldMapFrame_OnUserChangedSuperTrackedQuest(questID);
end
