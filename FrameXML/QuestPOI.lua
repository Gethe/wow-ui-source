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

function QuestPOI_SetPinScale(poiButton, scale)
	poiButton.pinScale = scale;

	if poiButton.Display then
		poiButton.Display.pinScale = scale;
	end
end

function QuestPOI_GetPinScale(poiButton)
	return poiButton.pinScale or 1;
end

function QuestPOI_CalculateNumericTexCoords(index, color)
	if index then
		color = color or QUEST_POI_COLOR_YELLOW;
		local iconIndex = index - 1;
		local yOffset = color + floor(iconIndex / QUEST_POI_ICONS_PER_ROW) * QUEST_POI_ICON_SIZE;
		local xOffset = mod(iconIndex, QUEST_POI_ICONS_PER_ROW) * QUEST_POI_ICON_SIZE;
		return xOffset, xOffset + QUEST_POI_ICON_SIZE, yOffset, yOffset + QUEST_POI_ICON_SIZE;
	end
end

-- NOTE: These utility functions for setting a texture are used by other Texture regions on the poiButton.
-- Nothing should need to call these externally.
local function QuestPOI_SetTextureSize(texture, width, height)
	if texture then
		local scale = QuestPOI_GetPinScale(texture:GetParent());
		texture:SetSize(scale * width, scale * height);
	end
end

local function QuestPOI_SetTexture(texture, width, height, file, texLeft, texRight, texTop, texBottom)
	if texture then
		texture:SetTexture(file);
		texture:SetTexCoord(texLeft or 0, texRight or 1, texTop or 0, texBottom or 1);
		QuestPOI_SetTextureSize(texture, width, height);
	end
end

local function QuestPOI_SetAtlas(texture, width, height, atlas)
	-- Using this with shared controls that may not have all the same children
	if texture then
		local useAtlasSize = not width and not height;
		texture:SetTexCoord(0, 1, 0, 1);
		texture:SetAtlas(atlas, useAtlasSize);

		if not useAtlasSize then
			QuestPOI_SetTextureSize(texture, width, height);
		end
	end
end

QuestPOIDisplayLayerMixin = {};

function QuestPOIDisplayLayerMixin:SetOffset(x, y)
	self.offsetX = x;
	self.offsetY = y;
	self:UpdatePoint(false);
end

function QuestPOIDisplayLayerMixin:UpdatePoint(isPushed)
	if self:GetParent():IsEnabled() then
		local pushedX = isPushed and 1 or 0;
		local pushedY = isPushed and -1 or 0;
		local x = (self.offsetX or 0) + pushedX;
		local y = (self.offsetY or 0) + pushedY;
		PixelUtil.SetPoint(self, "CENTER", self:GetParent(), "CENTER", x, y, x, y);
	end
end

function QuestPOIDisplayLayerMixin:SetNumber(value)
	local poiButton = self:GetParent();
	local color = poiButton.selected and QUEST_POI_COLOR_BLACK or QUEST_POI_COLOR_YELLOW;
	QuestPOI_SetTexture(self.Icon, 32, 32, "Interface/WorldMap/UI-QuestPoi-NumberIcons", QuestPOI_CalculateNumericTexCoords(value, color));
	self:SetOffset(0, 0);
end

function QuestPOIDisplayLayerMixin:SetTextureSize(width, height)
	QuestPOI_SetTextureSize(self.Icon, width, height);
end

function QuestPOIDisplayLayerMixin:SetTexture(width, height, file, texLeft, texRight, texTop, texBottom)
	QuestPOI_SetTexture(self.Icon, width, height, file, texLeft, texRight, texTop, texBottom);
end

function QuestPOIDisplayLayerMixin:SetAtlas(width, height, atlas)
	QuestPOI_SetAtlas(self.Icon, width, height, atlas);
end

function QuestPOI_GetStyleFromQuestData(poiButton, isComplete, isWaypoint)
	if isWaypoint then
		return "waypoint";
	elseif isComplete then
		return "normal";
	else
		return "numeric";
	end
end

function QuestPOI_GetTextureInfoNormal(poiButton)
	if poiButton.selected then
		return "Interface/WorldMap/UI-QuestPoi-NumberIcons", 0.500, 0.625, 0.375, 0.5;
	else
		return "Interface/WorldMap/UI-QuestPoi-NumberIcons", 0.500, 0.625, 0.875, 1.0;
	end
end

function QuestPOI_GetTextureInfoPushed(poiButton)
	if poiButton.selected then
		return "Interface/WorldMap/UI-QuestPoi-NumberIcons", 0.375, 0.500, 0.375, 0.5;
	else
		return "Interface/WorldMap/UI-QuestPoi-NumberIcons", 0.375, 0.500, 0.875, 1.0;
	end
end

function QuestPOI_GetTextureInfoHighlight(poiButton)
	return "Interface/WorldMap/UI-QuestPoi-NumberIcons", 0.625, 0.750, 0.375, 0.5;
end

function QuestPOI_GetCampaignAtlasInfoNormal(poiButton)
	if poiButton.selected then
		return "UI-QuestPoiCampaign-QuestNumber-SuperTracked";
	else
		return "UI-QuestPoiCampaign-QuestNumber";
	end
end

function QuestPOI_GetCampaignAtlasInfoPushed(poiButton)
	if poiButton.selected then
		return "UI-QuestPoiCampaign-QuestNumber-Pressed-SuperTracked";
	else
		return "UI-QuestPoiCampaign-QuestNumber-Pressed";
	end
end

function QuestPOI_GetButtonAlpha(poiButton)
	return poiButton.style ~= "disabled" and 1 or 0;
end

function QuestPOI_GetQuestCompleteAtlas(poiButton)
	local isLegendaryQuest = C_QuestLog.IsLegendaryQuest(poiButton.questID);
	return isLegendaryQuest and "UI-QuestIcon-TurnIn-Legendary" or "UI-QuestIcon-TurnIn-Normal";
end

function QuestPOI_SetNumber(poiButton)
	poiButton.Display:SetNumber(poiButton.index);
end

Enum.QuestPOIQuestTypes = {
	Normal = 1,
	Campaign = 2,
	Calling = 3,
};

local function QuestPOI_GetQuestType(poiButton)
	local quest = QuestCache:Get(poiButton.questID);
	if QuestUtil.ShouldQuestIconsUseCampaignAppearance(poiButton.questID) then
		return Enum.QuestPOIQuestTypes.Campaign;
	elseif quest:IsCalling() then
		return Enum.QuestPOIQuestTypes.Calling;
	else
		return Enum.QuestPOIQuestTypes.Normal;
	end
end

function QuestPOI_UpdateNumericStyleTextures(poiButton)
	QuestPOI_SetTextureSize(poiButton.Number, 32, 32);

	if QuestPOI_GetQuestType(poiButton) ~= Enum.QuestPOIQuestTypes.Normal then
		QuestPOI_SetAtlas(poiButton.Glow, 64, 64, "UI-QuestPoiCampaign-OuterGlow");
		QuestPOI_SetAtlas(poiButton.NormalTexture, 32, 32, QuestPOI_GetCampaignAtlasInfoNormal(poiButton));
		QuestPOI_SetAtlas(poiButton.PushedTexture, 32, 32, QuestPOI_GetCampaignAtlasInfoPushed(poiButton));
		QuestPOI_SetAtlas(poiButton.HighlightTexture, 32, 32, "UI-QuestPoiCampaign-InnerGlow");
	else
		QuestPOI_SetTexture(poiButton.Glow, 50, 50, "Interface/WorldMap/UI-QuestPoi-IconGlow");
		QuestPOI_SetTexture(poiButton.NormalTexture, 32, 32, QuestPOI_GetTextureInfoNormal(poiButton));
		QuestPOI_SetTexture(poiButton.PushedTexture, 32, 32, QuestPOI_GetTextureInfoPushed(poiButton));
		QuestPOI_SetTexture(poiButton.HighlightTexture, 32, 32, QuestPOI_GetTextureInfoHighlight(poiButton));
	end
end

function QuestPOI_UpdateNormalStyleTexture(poiButton)
	-- This may be overridden later
	poiButton.Display:SetOffset(0, 0);

	local questPOIType = QuestPOI_GetQuestType(poiButton);

	if questPOIType == Enum.QuestPOIQuestTypes.Campaign then
		poiButton.Display:SetAtlas(32, 32, "UI-QuestPoiCampaign-QuestBangTurnIn");
	elseif questPOIType == Enum.QuestPOIQuestTypes.Calling then
		poiButton.Display:SetAtlas(32, 32, "UI-DailyQuestPoiCampaign-QuestBangTurnIn");
	end

	if questPOIType == Enum.QuestPOIQuestTypes.Normal then
		poiButton.Display:SetAtlas(24, 24, QuestPOI_GetQuestCompleteAtlas(poiButton));
		QuestPOI_SetTexture(poiButton.Glow, 50, 50, "Interface/WorldMap/UI-QuestPoi-IconGlow");
		QuestPOI_SetTexture(poiButton.NormalTexture, 32, 32, QuestPOI_GetTextureInfoNormal(poiButton));
		QuestPOI_SetTexture(poiButton.PushedTexture, 32, 32, QuestPOI_GetTextureInfoPushed(poiButton));
		QuestPOI_SetTexture(poiButton.HighlightTexture, 32, 32, QuestPOI_GetTextureInfoHighlight(poiButton));
	else
		poiButton.Display:SetOffset(0, 0);
		QuestPOI_SetAtlas(poiButton.Glow, 64, 64, "UI-QuestPoiCampaign-OuterGlow");
		QuestPOI_SetAtlas(poiButton.NormalTexture, 32, 32, QuestPOI_GetCampaignAtlasInfoNormal(poiButton));
		QuestPOI_SetAtlas(poiButton.PushedTexture, 32, 32, QuestPOI_GetCampaignAtlasInfoPushed(poiButton));
		QuestPOI_SetAtlas(poiButton.HighlightTexture, 32, 32, "UI-QuestPoiCampaign-InnerGlow");
	end

	local buttonAlpha = QuestPOI_GetButtonAlpha(poiButton);
	poiButton.NormalTexture:SetAlpha(buttonAlpha);
	poiButton.PushedTexture:SetAlpha(buttonAlpha);

	local style = poiButton.style; -- NOTE: Older unused style of "map"...not sure where it was ever used.
	if style == "normal" then
		-- Nothing else to do
	elseif style == "waypoint" then
		poiButton.Display:SetAtlas(13, 17, "poi-traveldirections-arrow");
	elseif style == "disabled" then
		poiButton.Display:SetAtlas(24, 29, "QuestSharing-QuestLog-Padlock");
	elseif style == "threat" then
		local iconAtlas = QuestUtil.GetThreatPOIIcon(poiButton.questID);
		poiButton.Display:SetAtlas(18, 18, iconAtlas);
		poiButton.Display:SetOffset(0, 0);
	end
end

function QuestPOI_UpdateNumericStyle(poiButton)
	QuestPOI_UpdateNumericStyleTextures(poiButton);
	QuestPOI_SetNumber(poiButton);
end

function QuestPOI_UpdateNormalStyle(poiButton)
	-- Start with the defaults and shared pieces, some of these may change from the other update functions
	QuestPOI_UpdateNormalStyleTexture(poiButton);
end

function QuestPOI_UpdateButtonStyle(poiButton)
	if poiButton.style == "numeric" then
		QuestPOI_UpdateNumericStyle(poiButton);
	else
		QuestPOI_UpdateNormalStyle(poiButton);
	end

	if poiButton.Glow then
		poiButton.Glow:SetShown(poiButton.selected);
	end
end

local function QuestPOI_CallOnCreateFunction(parent, poiButton)
	if parent.poiOnCreateFunc then
		parent.poiOnCreateFunc(poiButton);
	end
end

local function QuestPOI_GetButtonInternal(parent, questID, style, index)
	local poiButton;

	if style == "numeric" then
		-- numbered POI
		poiButton = parent.poiTable[style][index];
		if ( not poiButton ) then
			poiButton = CreateFrame("Button", nil, parent, "QuestPOINumericTemplate");
			parent.poiTable["numeric"][index] = poiButton;
			poiButton.index = index;
			QuestPOI_SetNumber(poiButton);
			QuestPOI_CallOnCreateFunction(parent, poiButton);
		end
	else
		-- completed or waypoint POI
		for _, button in pairs(parent.poiTable["completed"]) do
			if ( not button.used ) then
				poiButton = button;
				break;
			end
		end

		if not poiButton then
			poiButton = CreateFrame("Button", nil, parent, "QuestPOICompletedTemplate");
			tinsert(parent.poiTable["completed"], poiButton);
			QuestPOI_CallOnCreateFunction(parent, poiButton);
		end
	end

	poiButton:SetEnabled(style ~= "disabled");
	poiButton.questID = questID;
	poiButton.style = style;
	poiButton.used = true;
	poiButton.poiParent = parent;
	poiButton.pingWorldMap = false;

	return poiButton;
end

function QuestPOI_GetButton(parent, questID, style, index)
	if C_QuestLog.IsQuestCalling(questID) then
		return;
	end

	local poiButton = QuestPOI_GetButtonInternal(parent, questID, style, index);
	QuestPOI_UpdateButtonStyle(poiButton);
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
	if parent.poiSelectedButton then
		QuestPOI_ClearSelection(parent);
	end

	parent.poiSelectedButton = poiButton;
	poiButton.selected = true;
	QuestPOI_UpdateButtonStyle(poiButton);
end

function QuestPOI_ClearSelection(parent)
	local poiButton = parent.poiSelectedButton;
	if poiButton then
		parent.poiSelectedButton = nil;
		poiButton.selected = nil;
		QuestPOI_UpdateButtonStyle(poiButton);
	end
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
	self.Display:UpdatePoint(true);
end

function QuestPOIButton_OnMouseUp(self)
	self.Display:UpdatePoint(false);
end

function QuestPOIButton_OnClick(self)
	local questID = self.questID;

	if ( ChatEdit_TryInsertQuestLinkForQuestID(questID) ) then
		return;
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if QuestUtils_IsQuestWatched(questID) then
		if ( IsShiftKeyDown() ) then
			QuestObjectiveTracker_UntrackQuest(nil, questID);
			return;
		end
	else
		C_QuestLog.AddQuestWatch(questID, Enum.QuestWatchType.Manual);
	end

	C_SuperTrack.SetSuperTrackedQuestID(questID);
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
