local IconsPerRow = 8;
local IconCoordSize = 0.125;

-- POI text colors (offsets into texture)
local POIButtonColorBlackCoord = 0;
local POIButtonColorYellowCoord = 0.5;

local function POIButton_CalculateNumericTexCoords(index, color)
	if index then
		color = color or POIButtonColorYellowCoord;
		local iconIndex = index - 1;
		local yOffset = color + floor(iconIndex / IconsPerRow) * IconCoordSize;
		local xOffset = mod(iconIndex, IconsPerRow) * IconCoordSize;
		return xOffset, xOffset + IconCoordSize, yOffset, yOffset + IconCoordSize;
	end
end

-- NOTE: These utility functions for setting a texture are used by other Texture regions on the poiButton.
-- Nothing should need to call these externally.
local function POIButton_SetTextureSize(texture, width, height)
	if texture then
		local scale = texture:GetParent():GetPinScale();
		texture:SetSize(scale * width, scale * height);
	end
end

local function POIButton_SetTexture(texture, width, height, file, texLeft, texRight, texTop, texBottom)
	if texture then
		texture:SetTexture(file);
		texture:SetTexCoord(texLeft or 0, texRight or 1, texTop or 0, texBottom or 1);
		POIButton_SetTextureSize(texture, width, height);
	end
end

local function POIButton_SetAtlas(texture, width, height, atlas)
	-- Using this with shared controls that may not have all the same children
	if texture then
		local useAtlasSize = not width and not height;
		texture:SetTexCoord(0, 1, 0, 1);
		texture:SetAtlas(atlas, useAtlasSize);

		if not useAtlasSize then
			POIButton_SetTextureSize(texture, width, height);
		end
	end
end

POIButtonDisplayLayerMixin = {};

function POIButtonDisplayLayerMixin:SetOffset(x, y)
	self.offsetX = x;
	self.offsetY = y;
	self:UpdatePoint(false);
end

function POIButtonDisplayLayerMixin:UpdatePoint(isPushed)
	if self:GetParent():IsEnabled() then
		local pushedX = isPushed and 1 or 0;
		local pushedY = isPushed and -1 or 0;
		local x = (self.offsetX or 0) + pushedX;
		local y = (self.offsetY or 0) + pushedY;
		PixelUtil.SetPoint(self, "CENTER", self:GetParent(), "CENTER", x, y, x, y);
	end
end

function POIButtonDisplayLayerMixin:SetNumber(value)
	local poiButton = self:GetParent();
	local color = poiButton:IsSelected() and POIButtonColorBlackCoord or POIButtonColorYellowCoord;
	POIButton_SetTexture(self.Icon, 32, 32, "Interface/WorldMap/UI-QuestPoi-NumberIcons", POIButton_CalculateNumericTexCoords(value, color));
	self:SetOffset(0, 0);
end

function POIButtonDisplayLayerMixin:SetTextureSize(width, height)
	POIButton_SetTextureSize(self.Icon, width, height);
end

function POIButtonDisplayLayerMixin:SetTexture(width, height, file, texLeft, texRight, texTop, texBottom)
	POIButton_SetTexture(self.Icon, width, height, file, texLeft, texRight, texTop, texBottom);
end

function POIButtonDisplayLayerMixin:SetAtlas(width, height, atlas)
	POIButton_SetAtlas(self.Icon, width, height, atlas);
end

function POIButtonDisplayLayerMixin:SetIconShown(iconShown)
	self.Icon:SetShown(iconShown);
end

function POIButtonDisplayLayerMixin:IsIconShow()
	return self.Icon:IsShown();
end

function POIButtonDisplayLayerMixin:GetPinScale()
	return self:GetParent():GetPinScale();
end

local function POIButton_GetTextureInfoNormal(poiButton)
	if poiButton:IsSelected() then
		return "Interface/WorldMap/UI-QuestPoi-NumberIcons", 0.500, 0.625, 0.375, 0.5;
	else
		return "Interface/WorldMap/UI-QuestPoi-NumberIcons", 0.500, 0.625, 0.875, 1.0;
	end
end

local function POIButton_GetTextureInfoPushed(poiButton)
	if poiButton:IsSelected() then
		return "Interface/WorldMap/UI-QuestPoi-NumberIcons", 0.375, 0.500, 0.375, 0.5;
	else
		return "Interface/WorldMap/UI-QuestPoi-NumberIcons", 0.375, 0.500, 0.875, 1.0;
	end
end

local function POIButton_GetTextureInfoHighlight(poiButton)
	return "Interface/WorldMap/UI-QuestPoi-NumberIcons", 0.625, 0.750, 0.375, 0.5;
end

local function POIButton_GetCampaignAtlasInfoNormal(poiButton)
	if poiButton:IsSelected() then
		return "UI-QuestPoiCampaign-QuestNumber-SuperTracked";
	else
		return "UI-QuestPoiCampaign-QuestNumber";
	end
end

local function POIButton_GetCampaignAtlasInfoPushed(poiButton)
	if poiButton:IsSelected() then
		return "UI-QuestPoiCampaign-QuestNumber-Pressed-SuperTracked";
	else
		return "UI-QuestPoiCampaign-QuestNumber-Pressed";
	end
end

local function POIButton_GetImportantAtlasInfoNormal(poiButton)
	if poiButton:IsSelected() then
		return "UI-QuestPoiImportant-QuestNumber-SuperTracked";
	else
		return "UI-QuestPoiImportant-QuestNumber";
	end
end

local function POIButton_GetImportantAtlasInfoPushed(poiButton)
	if poiButton:IsSelected() then
		return "UI-QuestPoiImportant-QuestNumber-Pressed-SuperTracked";
	else
		return "UI-QuestPoiImportant-QuestNumber-Pressed";
	end
end

local function POIButton_GetQuestCompleteAtlas(poiButton)
	local questID = poiButton:GetQuestID();
	local isLegendaryQuest = questID and C_QuestLog.IsLegendaryQuest(questID) or false;
	return isLegendaryQuest and "UI-QuestPoiLegendary-QuestBangTurnIn" or "UI-QuestIcon-TurnIn-Normal";
end

local function POIButton_UpdateNumericStyleTextures(poiButton)
	POIButton_SetTextureSize(poiButton.Number, 32, 32);

	local questType = poiButton:GetQuestType();
	if questType == POIButtonUtil.QuestTypes.Campaign or questType == POIButtonUtil.QuestTypes.Calling then
		POIButton_SetAtlas(poiButton.Glow, 64, 64, "UI-QuestPoiCampaign-OuterGlow");
		POIButton_SetAtlas(poiButton.NormalTexture, 32, 32, POIButton_GetCampaignAtlasInfoNormal(poiButton));
		POIButton_SetAtlas(poiButton.PushedTexture, 32, 32, POIButton_GetCampaignAtlasInfoPushed(poiButton));
		POIButton_SetAtlas(poiButton.HighlightTexture, 32, 32, "UI-QuestPoiCampaign-InnerGlow");
	elseif questType == POIButtonUtil.QuestTypes.Important then
		POIButton_SetAtlas(poiButton.Glow, 64, 64, "UI-QuestPoiImportant-OuterGlow");
		POIButton_SetAtlas(poiButton.NormalTexture, 32, 36, POIButton_GetImportantAtlasInfoNormal(poiButton));
		POIButton_SetAtlas(poiButton.PushedTexture, 32, 36, POIButton_GetImportantAtlasInfoPushed(poiButton));
		POIButton_SetAtlas(poiButton.HighlightTexture, 32, 36, "UI-QuestPoiImportant-InnerGlow");
	else
		POIButton_SetTexture(poiButton.Glow, 50, 50, "Interface/WorldMap/UI-QuestPoi-IconGlow");
		POIButton_SetTexture(poiButton.NormalTexture, 32, 32, POIButton_GetTextureInfoNormal(poiButton));
		POIButton_SetTexture(poiButton.PushedTexture, 32, 32, POIButton_GetTextureInfoPushed(poiButton));
		POIButton_SetTexture(poiButton.HighlightTexture, 32, 32, POIButton_GetTextureInfoHighlight(poiButton));
	end
end

local function POIButton_UpdateNormalStyleTexture(poiButton)
	-- This may be overridden later
	poiButton.Display:SetOffset(0, 0);

	local style = poiButton.style;
	local isContentTracking = (style == POIButtonUtil.Style.ContentTracking);
	poiButton.Display:SetIconShown(not isContentTracking);
	if isContentTracking then
		local atlas = poiButton:IsSelected() and "waypoint-mappin-minimap-tracked" or "waypoint-mappin-minimap-untracked";
		POIButton_SetAtlas(poiButton.Glow, 32, 32, atlas);
		POIButton_SetAtlas(poiButton.NormalTexture, 32, 32, atlas);
		POIButton_SetAtlas(poiButton.PushedTexture, 32, 32, atlas);
		POIButton_SetAtlas(poiButton.HighlightTexture, 32, 32, atlas);
	else
		local questPOIType = poiButton:GetQuestType();
		if questPOIType == POIButtonUtil.QuestTypes.Campaign then
			poiButton.Display:SetAtlas(32, 32, "UI-QuestPoiCampaign-QuestBangTurnIn");
		elseif questPOIType == POIButtonUtil.QuestTypes.Calling then
			poiButton.Display:SetAtlas(32, 32, "UI-DailyQuestPoiCampaign-QuestBangTurnIn");
		elseif questPOIType == POIButtonUtil.QuestTypes.Important then
			poiButton.Display:SetAtlas(32, 36, "UI-QuestPoiImportant-QuestBangTurnIn");			
		end

		if not questPOIType or (questPOIType == POIButtonUtil.QuestTypes.Normal) then
			poiButton.Display:SetAtlas(24, 24, POIButton_GetQuestCompleteAtlas(poiButton));
			POIButton_SetTexture(poiButton.Glow, 50, 50, "Interface/WorldMap/UI-QuestPoi-IconGlow");
			POIButton_SetTexture(poiButton.NormalTexture, 32, 32, POIButton_GetTextureInfoNormal(poiButton));
			POIButton_SetTexture(poiButton.PushedTexture, 32, 32, POIButton_GetTextureInfoPushed(poiButton));
			POIButton_SetTexture(poiButton.HighlightTexture, 32, 32, POIButton_GetTextureInfoHighlight(poiButton));
		elseif questPOIType == POIButtonUtil.QuestTypes.Important then
			poiButton.Display:SetOffset(0, 0);
			POIButton_SetAtlas(poiButton.Glow, 64, 64, "UI-QuestPoiImportant-OuterGlow");
			POIButton_SetAtlas(poiButton.NormalTexture, 32, 36, POIButton_GetImportantAtlasInfoNormal(poiButton));
			POIButton_SetAtlas(poiButton.PushedTexture, 32, 36, POIButton_GetImportantAtlasInfoPushed(poiButton));
			POIButton_SetAtlas(poiButton.HighlightTexture, 32, 36, "UI-QuestPoiImportant-InnerGlow");			
		else
			poiButton.Display:SetOffset(0, 0);
			POIButton_SetAtlas(poiButton.Glow, 64, 64, "UI-QuestPoiCampaign-OuterGlow");
			POIButton_SetAtlas(poiButton.NormalTexture, 32, 32, POIButton_GetCampaignAtlasInfoNormal(poiButton));
			POIButton_SetAtlas(poiButton.PushedTexture, 32, 32, POIButton_GetCampaignAtlasInfoPushed(poiButton));
			POIButton_SetAtlas(poiButton.HighlightTexture, 32, 32, "UI-QuestPoiCampaign-InnerGlow");
		end

		local buttonAlpha = poiButton:CalculateButtonAlpha();
		poiButton.NormalTexture:SetAlpha(buttonAlpha);
		poiButton.PushedTexture:SetAlpha(buttonAlpha);

		if style == POIButtonUtil.Style.QuestComplete then
			-- Nothing else to do
		elseif style == POIButtonUtil.Style.Waypoint then
			poiButton.Display:SetAtlas(13, 17, "poi-traveldirections-arrow");
		elseif style == POIButtonUtil.Style.QuestDisabled then
			poiButton.Display:SetAtlas(24, 29, "QuestSharing-QuestLog-Padlock");
		elseif style == POIButtonUtil.Style.QuestThreat then
			local iconAtlas = QuestUtil.GetThreatPOIIcon(poiButton.questID);
			poiButton.Display:SetAtlas(18, 18, iconAtlas);
			poiButton.Display:SetOffset(0, 0);
		end
	end
end

local function POIButton_UpdateNumericStyle(poiButton)
	POIButton_UpdateNumericStyleTextures(poiButton);
	poiButton:UpdateNumber();
end

local function POIButton_UpdateNormalStyle(poiButton)
	-- Start with the defaults and shared pieces, some of these may change from the other update functions
	POIButton_UpdateNormalStyleTexture(poiButton);
end

POIButtonMixin = {};

function POIButtonMixin:OnMouseDown()
	self.Display:UpdatePoint(true);

	if self.Display:IsIconShow() then
		self.PushedTexture:SetPoint("CENTER");
		self.HighlightTexture:SetPoint("CENTER");
		self.Glow:SetPoint("CENTER");
	else
		self.PushedTexture:SetPoint("CENTER", 1, -1);
		self.HighlightTexture:SetPoint("CENTER", 1, -1);
		self.Glow:SetPoint("CENTER", 1, -1);
	end
end

function POIButtonMixin:OnMouseUp()
	self.Display:UpdatePoint(false);
	self.PushedTexture:SetPoint("CENTER");
	self.HighlightTexture:SetPoint("CENTER");
	self.Glow:SetPoint("CENTER");
end

function POIButtonMixin:OnClick()
	local questID = self:GetQuestID();
	if questID then
		if ChatEdit_TryInsertQuestLinkForQuestID(questID) then
			return;
		end

		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		if QuestUtils_IsQuestWatched(questID) then
			if IsShiftKeyDown() then
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
	else
		local trackableType, trackableID = self:GetTrackable();
		if trackableType and trackableID then
			if ContentTrackingUtil.ProcessChatLink(trackableType, trackableID) then
				return;
			end

			if C_ContentTracking.IsTracking(trackableType, trackableID) then
				if IsShiftKeyDown() then
					C_ContentTracking.StopTracking(trackableType, trackableID, Enum.ContentTrackingStopType.Manual);
					return;
				end
			else
				-- Note: this case shouldn't be possible with the current design since we'll
				-- only ever show a POI Button for things that are already tracked.
				C_ContentTracking.StartTracking(trackableType, trackableID);
			end
		end

		C_SuperTrack.SetSuperTrackedContent(trackableType, trackableID);
	end
end

function POIButtonMixin:OnEnter()
	if (self:GetStyle() == POIButtonUtil.Style.QuestComplete) and not self:IsEnabled() then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, QUEST_SESSION_ON_HOLD_TOOLTIP_TITLE);
		GameTooltip_AddNormalLine(GameTooltip, QUEST_SESSION_ON_HOLD_TOOLTIP_TEXT);
		GameTooltip:Show();
	else
		local questID = self:GetQuestID();
		if questID and self:GetParent().useHighlightManager then
			POIButtonHighlightManager:SetHighlight(questID);
		else
			self.HighlightTexture:Show();
		end
	end
end

function POIButtonMixin:OnLeave()
	if GameTooltip:GetOwner() == self then
		GameTooltip:Hide();
	end

	if self:GetQuestID() and self:GetParent().useHighlightManager then
		POIButtonHighlightManager:ClearHighlight();
	else
		self.HighlightTexture:Hide();
	end
end

function POIButtonMixin:UpdateButtonStyle()
	if self.style == POIButtonUtil.Style.Numeric then
		POIButton_UpdateNumericStyle(self);
	else
		POIButton_UpdateNormalStyle(self);
	end

	if self.shouldShowGlow then
		self.Glow:SetShown(self:IsSelected());
	end
end

function POIButtonMixin:EvaluateManagedHighlight()
	local questID = self:GetQuestID();
	if questID and (questID == POIButtonHighlightManager:GetQuestID()) then
		if self.style == POIButtonUtil.Style.QuestDisabled then
			return;
		end
		self.HighlightTexture:Show();
	else
		if (self.style == POIButtonUtil.Style.QuestDisabled) or not self:IsMouseOver() then
			self.HighlightTexture:Hide();
		end
	end
end

function POIButtonMixin:GetQuestType()
	local questID = self:GetQuestID();
	if not questID then
		return nil;
	end

	local quest = QuestCache:Get(questID);
	if QuestUtil.ShouldQuestIconsUseCampaignAppearance(questID) then
		return POIButtonUtil.QuestTypes.Campaign;
	elseif quest:IsCalling() then
		return POIButtonUtil.QuestTypes.Calling;
	elseif quest:IsImportant() then
		return POIButtonUtil.QuestTypes.Important;
	else
		return POIButtonUtil.QuestTypes.Normal;
	end
end

function POIButtonMixin:CalculateButtonAlpha()
	return (self:GetStyle() == POIButtonUtil.Style.QuestDisabled) and 0 or 1;
end

function POIButtonMixin:SetNumber(number)
	self.index = number;
	self:UpdateNumber();
end

function POIButtonMixin:UpdateNumber()
	self.Display:SetNumber(self.index);
end

function POIButtonMixin:SetQuestID(questID)
	self.questID = questID;
end

function POIButtonMixin:GetQuestID()
	return self.questID;
end

function POIButtonMixin:SetTrackable(trackableType, trackableID)
	self.trackableType = trackableType;
	self.trackableID = trackableID;
end

function POIButtonMixin:GetTrackable()
	return self.trackableType, self.trackableID;
end

function POIButtonMixin:SetPinScale(scale)
	self.pinScale = scale;
end

function POIButtonMixin:GetPinScale()
	return self.pinScale or 1;
end

function POIButtonMixin:SetStyle(poiButtonStyle)
	self.style = poiButtonStyle;
end

function POIButtonMixin:GetStyle()
	return self.style;
end

function POIButtonMixin:SetSelected()
	self.selected = true;
end

function POIButtonMixin:ClearSelection()
	self.selected = nil;
end

function POIButtonMixin:IsSelected()
	return not not self.selected;
end

function POIButtonMixin:Reset()
	self.poiParent = nil;
	self.pingWorldMap = nil;
	self.pinScale = nil;
	self.index = nil;
	self.questID = nil;
	self.trackableType = nil;
	self.trackableID = nil;
	self.style = nil;
	self.selected = nil;
end
