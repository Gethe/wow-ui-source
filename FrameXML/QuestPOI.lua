local QUEST_POI_ICONS_PER_ROW = 8;
local QUEST_POI_ICON_SIZE = 0.125;
-- POI text colors (offsets into texture)
QUEST_POI_COLOR_BLACK = 0;
QUEST_POI_COLOR_YELLOW = 0.5;

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

function QuestPOI_CalculateNumericTexCoords(index, color)
	color = color or QUEST_POI_COLOR_YELLOW;
	local iconIndex = index - 1;
	local yOffset = color + floor(iconIndex / QUEST_POI_ICONS_PER_ROW) * QUEST_POI_ICON_SIZE;
	local xOffset = mod(iconIndex, QUEST_POI_ICONS_PER_ROW) * QUEST_POI_ICON_SIZE;
	return xOffset, xOffset + QUEST_POI_ICON_SIZE, yOffset, yOffset + QUEST_POI_ICON_SIZE;
end

function QuestPOI_GetButton(parent, questID, style, index)
	local poiButton;
	if ( style == "numeric" ) then
		-- numbered POI
		poiButton = parent.poiTable["numeric"][index];
		if ( not poiButton ) then
			poiButton = CreateFrame("Button", nil, parent, "QuestPOINumericTemplate");
			parent.poiTable["numeric"][index] = poiButton;
			poiButton.Number:SetTexCoord(QuestPOI_CalculateNumericTexCoords(index));
			poiButton.index = index;
			if ( parent.poiOnCreateFunc ) then
				parent.poiOnCreateFunc(poiButton);
			end
		end
	else
		-- completed or waypoint POI
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

		if ( poiButton.style ~= style ) then
			-- default style is "normal"
			poiButton.Icon.offsetX = -1;
			poiButton.Icon.offsetY = 0;
			if ( style == "normal" ) then
				poiButton.FullHighlightTexture:Show();
				poiButton.IconHighlightTexture:Hide();
				poiButton.Icon:SetTexCoord(0, 0.5, 0, 0.5);
				poiButton.Icon:SetTexture("Interface\\WorldMap\\UI-WorldMap-QuestIcon");
				poiButton.Icon:SetSize(24, 24);
				poiButton.NormalTexture:SetAlpha(1);
				poiButton.PushedTexture:SetAlpha(1);
				poiButton.NormalTexture:SetTexCoord(0.875, 1, 0.375, 0.5);
				poiButton.PushedTexture:SetTexCoord(0.750, 0.875, 0.375, 0.5);
			elseif ( style == "map" ) then
				poiButton.FullHighlightTexture:Hide();
				poiButton.IconHighlightTexture:Show();
				poiButton.Icon:SetTexCoord(0, 0.5, 0, 0.5);
				poiButton.Icon:SetTexture("Interface\\WorldMap\\UI-WorldMap-QuestIcon");
				poiButton.Icon:SetSize(32, 32);
				poiButton.NormalTexture:SetAlpha(0);
				poiButton.PushedTexture:SetAlpha(0);
			elseif ( style == "remote" ) then
				poiButton.FullHighlightTexture:Show();
				poiButton.IconHighlightTexture:Hide();
				poiButton.Icon:SetTexCoord(0, 0.5, 0, 0.5);
				poiButton.Icon:SetTexture("Interface\\WorldMap\\UI-WorldMap-QuestIcon");
				poiButton.Icon:SetSize(24, 24);
				poiButton.NormalTexture:SetAlpha(1);
				poiButton.PushedTexture:SetAlpha(1);
				poiButton.NormalTexture:SetTexCoord(0.500, 0.625, 0.875, 1.0);
				poiButton.PushedTexture:SetTexCoord(0.375, 0.500, 0.875, 1.0);
			elseif ( style == "waypoint" ) then
				poiButton.FullHighlightTexture:Show();
				poiButton.IconHighlightTexture:Hide();
				poiButton.Icon:SetTexCoord(0, 1, 0, 1);
				poiButton.Icon:SetAtlas("poi-traveldirections-arrow");
				poiButton.Icon:SetSize(13, 17);
				poiButton.NormalTexture:SetAlpha(1);
				poiButton.PushedTexture:SetAlpha(1);
				poiButton.NormalTexture:SetTexCoord(0.500, 0.625, 0.875, 1.0);
				poiButton.PushedTexture:SetTexCoord(0.375, 0.500, 0.875, 1.0);
			elseif ( style == "disabled" ) then
				poiButton.FullHighlightTexture:Hide();
				poiButton.IconHighlightTexture:Hide();
				poiButton.Icon:SetTexCoord(0, 1, 0, 1);
				poiButton.Icon:SetAtlas("QuestSharing-QuestLog-Padlock", true);
				poiButton.NormalTexture:SetAlpha(0);
				poiButton.PushedTexture:SetAlpha(0);
			elseif ( style == "threat" ) then
				poiButton.FullHighlightTexture:Show();
				poiButton.IconHighlightTexture:Hide();
				poiButton.Icon:SetTexCoord(0, 1, 0, 1);
				poiButton.Icon:SetAtlas("worldquest-icon-nzoth", true);
				poiButton.NormalTexture:SetAlpha(1);
				poiButton.PushedTexture:SetAlpha(1);
				poiButton.Icon.offsetX = 0;
			end
			poiButton.Icon:SetPoint("CENTER", poiButton.Icon.offsetX, poiButton.Icon.offsetY);
		end
	end

	poiButton:SetEnabled(style ~= "disabled");
	poiButton.questID = questID;
	poiButton.style = style;
	poiButton.used = true;
	poiButton.poiParent = parent;
	poiButton.pingWorldMap = false;
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
	local parent = poiButton.poiParent;
	if ( parent.poiSelectedButton ) then
		if ( parent.selectedPOI == poiButton ) then
			return;
		else
			QuestPOI_ClearSelection(parent);
		end
	end

	poiButton.NormalTexture:SetTexCoord(0.500, 0.625, 0.375, 0.5);
	poiButton.PushedTexture:SetTexCoord(0.375, 0.500, 0.375, 0.5);
	local style = poiButton.style;
	if ( style == "numeric" ) then
		QuestPOI_SetTextColor(poiButton, QUEST_POI_COLOR_BLACK);
	else
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
			poiButton.NormalTexture:SetTexCoord(0.875, 1, 0.875, 1);
			poiButton.PushedTexture:SetTexCoord(0.750, 0.875, 0.875, 1);
			QuestPOI_SetTextColor(poiButton, QUEST_POI_COLOR_YELLOW);
		elseif ( style == "normal" ) then
			poiButton.NormalTexture:SetTexCoord(0.875, 1, 0.875, 1);
			poiButton.PushedTexture:SetTexCoord(0.750, 0.875, 0.875, 1);
		elseif ( style == "remote" ) then
			poiButton.NormalTexture:SetTexCoord(0.500, 0.625, 0.875, 1.0);
			poiButton.PushedTexture:SetTexCoord(0.375, 0.500, 0.875, 1.0);
		elseif ( style == "waypoint" ) then
			poiButton.NormalTexture:SetTexCoord(0.500, 0.625, 0.875, 1.0);
			poiButton.PushedTexture:SetTexCoord(0.375, 0.500, 0.875, 1.0);
		elseif ( style == "map" ) then
			poiButton.FullHighlightTexture:Hide();
			poiButton.IconHighlightTexture:Show();
			poiButton.Icon:SetSize(32, 32);
			poiButton.NormalTexture:SetAlpha(0);
			poiButton.PushedTexture:SetAlpha(0);
		elseif ( style == "threat" ) then
			poiButton.NormalTexture:SetTexCoord(0.875, 1, 0.875, 1);
			poiButton.PushedTexture:SetTexCoord(0.750, 0.875, 0.875, 1);
		end
		poiButton.Glow:Hide();
		poiButton.selected = nil;
		parent.poiSelectedButton = nil;
	end
end

function QuestPOI_SetTextColor(poiButton, color)
	poiButton.Number:SetTexCoord(QuestPOI_CalculateNumericTexCoords(poiButton.index, color));
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
	if self:IsEnabled() then
		if ( self.style == "numeric" ) then
			self.Number:SetPoint("CENTER", 1, -1);
		else
			self.Icon:SetPoint("CENTER", self.Icon.offsetX + 1, self.Icon.offsetY - 1);
		end
	end
end

function QuestPOIButton_OnMouseUp(self)
	if self:IsEnabled() then
		if ( self.style == "numeric" ) then
			self.Number:SetPoint("CENTER", 0, 0);
		else
			self.Icon:SetPoint("CENTER", self.Icon.offsetX, self.Icon.offsetY);
		end
	end
end

function QuestPOIButton_OnClick(self)
	local questID = self.questID;

	if ( ChatEdit_TryInsertQuestLinkForQuestID(questID) ) then
		return;
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	local questLogIndex = GetQuestLogIndexByID(questID);
	if ( IsQuestWatched(questLogIndex) ) then
		if ( IsShiftKeyDown() ) then
			QuestObjectiveTracker_UntrackQuest(nil, questID);
			return;
		end
	else
		AddQuestWatch(questLogIndex, true);
	end

	SetSuperTrackedQuestID(questID);
	if self.pingWorldMap then
		WorldMapPing_StartPingQuest(questID);
	end
end

function QuestPOIButton_OnEnter(self)
	if not self:IsEnabled() then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, QUEST_SESSION_ON_HOLD_TOOLTIP_TITLE);
		GameTooltip_AddNormalLine(GameTooltip, QUEST_SESSION_ON_HOLD_TOOLTIP_TEXT);
		GameTooltip:Show();
	end
end

function QuestPOIButton_OnLeave(self)
	if GameTooltip:GetOwner() == self then
		GameTooltip:Hide();
	end
end