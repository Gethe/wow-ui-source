-- POI text colors (offsets into texture)
local POIButtonColorBlackCoord = 0;
local POIButtonColorYellowCoord = 0.5;

-- NOTE: These utility functions for setting a texture are used by other Texture regions on the poiButton.
-- Nothing should need to call these externally.
local function POIButton_SetTextureSize(texture, width, height)
	if texture then
		local scale = texture:GetParent():GetPinScale();
		texture:SetSize(scale * width, scale * height);
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

function POIButtonDisplayLayerMixin:UpdateInProgress()
	local poiButton = self:GetParent();
	local inProgressAtlas = poiButton:IsSelected() and "Quest-In-Progress-Icon-Brown" or "Quest-In-Progress-Icon-yellow";
	self:SetAtlas(32, 32, inProgressAtlas);
	self:SetOffset(0, 0);
end

function POIButtonDisplayLayerMixin:SetTextureSize(width, height)
	POIButton_SetTextureSize(self.Icon, width, height);
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

local function POIButton_GetAtlasInfoNormal(poiButton)
	if poiButton:IsSelected() then
		return "UI-QuestPoi-QuestNumber-SuperTracked";
	else
		return "UI-QuestPoi-QuestNumber";
	end
end

local function POIButton_GetAtlasInfoPushed(poiButton)
	if poiButton:IsSelected() then
		return "UI-QuestPoi-QuestNumber-Pressed-SuperTracked";
	else
		return "UI-QuestPoi-QuestNumber-Pressed"
	end
end

local function POIButton_GetAtlasInfoHighlight(poiButton)
	return "UI-QuestPoi-InnerGlow";
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

local function POIButton_GetMetaAtlasInfoNormal(poiButton)
	if poiButton:IsSelected() then
		return "UI-QuestPoiWrapper-QuestNumber-SuperTracked";
	else
		return "UI-QuestPoiWrapper-QuestNumber";
	end
end

local function POIButton_GetMetaAtlasInfoPushed(poiButton)
	if poiButton:IsSelected() then
		return "UI-QuestPoiWrapper-QuestNumber-Pressed-SuperTracked";
	else
		return "UI-QuestPoiWrapper-QuestNumber-Pressed";
	end
end

local function POIButton_GetRecurringAtlasInfoNormal(poiButton)
	if poiButton:IsSelected() then
		return "UI-QuestPoiRecurring-QuestNumber-SuperTracked";
	else
		return "UI-QuestPoiRecurring-QuestNumber";
	end
end

local function POIButton_GetRecurringAtlasInfoPushed(poiButton)
	if poiButton:IsSelected() then
		return "UI-QuestPoiRecurring-QuestNumber-Pressed-SuperTracked";
	else
		return "UI-QuestPoiRecurring-QuestNumber-Pressed";
	end
end

local function POIButton_GetQuestCompleteAtlas(poiButton)
	local questID = poiButton:GetQuestID();
	local isLegendaryQuest = questID and C_QuestLog.IsLegendaryQuest(questID) or false;
	return isLegendaryQuest and "UI-QuestPoiLegendary-QuestBangTurnIn" or "UI-QuestIcon-TurnIn-Normal";
end

local function POIButton_UpdateQuestInProgressStyle(poiButton)
	local questType = poiButton:GetQuestType();
	if questType == POIButtonUtil.QuestTypes.Campaign or questType == POIButtonUtil.QuestTypes.Calling then
		POIButton_SetAtlas(poiButton.Glow, 64, 64, "UI-QuestPoiCampaign-OuterGlow");
		POIButton_SetAtlas(poiButton.NormalTexture, 32, 32, POIButton_GetCampaignAtlasInfoNormal(poiButton));
		POIButton_SetAtlas(poiButton.PushedTexture, 32, 32, POIButton_GetCampaignAtlasInfoPushed(poiButton));
		POIButton_SetAtlas(poiButton.HighlightTexture, 32, 32, "UI-QuestPoiCampaign-InnerGlow");
	elseif questType == POIButtonUtil.QuestTypes.Recurring then
		POIButton_SetAtlas(poiButton.Glow, 64, 64, "UI-QuestPoiRecurring-OuterGlow");
		POIButton_SetAtlas(poiButton.NormalTexture, 32, 32, POIButton_GetRecurringAtlasInfoNormal(poiButton));
		POIButton_SetAtlas(poiButton.PushedTexture, 32, 32, POIButton_GetRecurringAtlasInfoPushed(poiButton));
		POIButton_SetAtlas(poiButton.HighlightTexture, 32, 32, "UI-QuestPoiRecurring-InnerGlow");
	elseif questType == POIButtonUtil.QuestTypes.Important then
		POIButton_SetAtlas(poiButton.Glow, 64, 64, "UI-QuestPoiImportant-OuterGlow");
		POIButton_SetAtlas(poiButton.NormalTexture, 32, 36, POIButton_GetImportantAtlasInfoNormal(poiButton));
		POIButton_SetAtlas(poiButton.PushedTexture, 32, 36, POIButton_GetImportantAtlasInfoPushed(poiButton));
		POIButton_SetAtlas(poiButton.HighlightTexture, 32, 36, "UI-QuestPoiImportant-InnerGlow");
	elseif questPOIType == POIButtonUtil.QuestTypes.Meta then
		poiButton.Display:SetOffset(0, 0);
		POIButton_SetAtlas(poiButton.Glow, 64, 64, "UI-QuestPoiWrapper-OuterGlow");
		POIButton_SetAtlas(poiButton.NormalTexture, 32, 36, POIButton_GetMetaAtlasInfoNormal(poiButton));
		POIButton_SetAtlas(poiButton.PushedTexture, 32, 36, POIButton_GetMetaAtlasInfoPushed(poiButton));
		POIButton_SetAtlas(poiButton.HighlightTexture, 32, 36, "UI-QuestPoiWrapper-InnerGlow");
	else
		POIButton_SetAtlas(poiButton.Glow, 50, 50, "UI-QuestPoi-OuterGlow");
		POIButton_SetAtlas(poiButton.NormalTexture, 32, 32, POIButton_GetAtlasInfoNormal(poiButton));
		POIButton_SetAtlas(poiButton.PushedTexture, 32, 32, POIButton_GetAtlasInfoPushed(poiButton));
		POIButton_SetAtlas(poiButton.HighlightTexture, 32, 32, POIButton_GetAtlasInfoHighlight(poiButton));
	end

	 poiButton:UpdateInProgress();
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
		local questID = poiButton:GetQuestID();
		if questPOIType == POIButtonUtil.QuestTypes.Campaign then
			poiButton.Display:SetAtlas(32, 32, "UI-QuestPoiCampaign-QuestBangTurnIn");
		elseif questPOIType == POIButtonUtil.QuestTypes.Calling then
			poiButton.Display:SetAtlas(32, 32, "UI-DailyQuestPoiCampaign-QuestBangTurnIn");
		elseif questPOIType == POIButtonUtil.QuestTypes.Recurring then
			poiButton.Display:SetAtlas(32, 32, "UI-QuestPoiRecurring-QuestBangTurnIn");
		elseif questPOIType == POIButtonUtil.QuestTypes.Important then
			poiButton.Display:SetAtlas(32, 36, "UI-QuestPoiImportant-QuestBangTurnIn");
		elseif questPOIType == POIButtonUtil.QuestTypes.Meta then
			poiButton.Display:SetAtlas(32, 36, "UI-QuestPoiWrapper-QuestBangTurnIn");
		end

		if not questPOIType or (questPOIType == POIButtonUtil.QuestTypes.Normal) then
			poiButton.Display:SetAtlas(24, 24, POIButton_GetQuestCompleteAtlas(poiButton));
			POIButton_SetAtlas(poiButton.Glow, 50, 50, "UI-QuestPoi-OuterGlow");
			POIButton_SetAtlas(poiButton.NormalTexture, 32, 32, POIButton_GetAtlasInfoNormal(poiButton));
			POIButton_SetAtlas(poiButton.PushedTexture, 32, 32, POIButton_GetAtlasInfoPushed(poiButton));
			POIButton_SetAtlas(poiButton.HighlightTexture, 32, 32, POIButton_GetAtlasInfoHighlight(poiButton));
		elseif questPOIType == POIButtonUtil.QuestTypes.Recurring then
			poiButton.Display:SetOffset(0, 0);
			POIButton_SetAtlas(poiButton.Glow, 64, 64, "UI-QuestPoiRecurring-OuterGlow");
			POIButton_SetAtlas(poiButton.NormalTexture, 32, 32, POIButton_GetRecurringAtlasInfoNormal(poiButton));
			POIButton_SetAtlas(poiButton.PushedTexture, 32, 32, POIButton_GetRecurringAtlasInfoPushed(poiButton));
			POIButton_SetAtlas(poiButton.HighlightTexture, 32, 32, "UI-QuestPoiRecurring-InnerGlow");
		elseif questPOIType == POIButtonUtil.QuestTypes.Important then
			poiButton.Display:SetOffset(0, 0);
			POIButton_SetAtlas(poiButton.Glow, 64, 64, "UI-QuestPoiImportant-OuterGlow");
			POIButton_SetAtlas(poiButton.NormalTexture, 32, 36, POIButton_GetImportantAtlasInfoNormal(poiButton));
			POIButton_SetAtlas(poiButton.PushedTexture, 32, 36, POIButton_GetImportantAtlasInfoPushed(poiButton));
			POIButton_SetAtlas(poiButton.HighlightTexture, 32, 36, "UI-QuestPoiImportant-InnerGlow");
		elseif questPOIType == POIButtonUtil.QuestTypes.Meta then
			poiButton.Display:SetOffset(0, 0);
			POIButton_SetAtlas(poiButton.Glow, 64, 64, "UI-QuestPoiWrapper-OuterGlow");
			POIButton_SetAtlas(poiButton.NormalTexture, 32, 36, POIButton_GetMetaAtlasInfoNormal(poiButton));
			POIButton_SetAtlas(poiButton.PushedTexture, 32, 36, POIButton_GetMetaAtlasInfoPushed(poiButton));
			POIButton_SetAtlas(poiButton.HighlightTexture, 32, 36, "UI-QuestPoiWrapper-InnerGlow");
		elseif questPOIType == POIButtonUtil.QuestTypes.Rare then
			poiButton.Display:SetOffset(0, 0);
			POIButton_SetAtlas(poiButton.Glow, 50, 50, "UI-QuestPoi-OuterGlow");
			POIButton_SetAtlas(poiButton.NormalTexture, 18, 18, "worldquest-questmarker-rare");
			POIButton_SetAtlas(poiButton.PushedTexture, 18, 18, "worldquest-questmarker-rare-down");
			POIButton_SetAtlas(poiButton.HighlightTexture, 32, 32, POIButton_GetAtlasInfoHighlight(poiButton));
		elseif questPOIType == POIButtonUtil.QuestTypes.Epic then
			poiButton.Display:SetOffset(0, 0);
			POIButton_SetAtlas(poiButton.Glow, 50, 50, "UI-QuestPoi-OuterGlow");
			POIButton_SetAtlas(poiButton.NormalTexture, 18, 18, "worldquest-questmarker-epic");
			POIButton_SetAtlas(poiButton.PushedTexture, 18, 18, "worldquest-questmarker-epic-down");
			POIButton_SetAtlas(poiButton.HighlightTexture, 32, 32, POIButton_GetAtlasInfoHighlight(poiButton));
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

		poiButton:ClearQuestTagInfo();

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
		elseif style == POIButtonUtil.Style.WorldQuest then
			local info = C_QuestLog.GetQuestTagInfo(questID);
			poiButton:SetQuestTagInfo(info);
			local atlas, width, height = QuestUtil.GetWorldQuestAtlasInfo(info.worldQuestType, false, info.tradeskillLineID);
			poiButton.Display:SetAtlas(width, height, atlas);
		end

		poiButton:UpdateUnderlay();
	end
end

local function POIButton_UpdateNormalStyle(poiButton)
	-- Start with the defaults and shared pieces, some of these may change from the other update functions
	POIButton_UpdateNormalStyleTexture(poiButton);
end

POIButtonMixin = {};

function POIButtonMixin:OnShow()
	EventRegistry:RegisterCallback("Supertracking.OnChanged", self.OnSuperTrackingChanged, self);
end

function POIButtonMixin:OnHide()
	EventRegistry:UnregisterCallback("Supertracking.OnChanged", self);
end

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
				C_QuestLog.RemoveQuestWatch(questID);
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
	if self:GetStyle() == POIButtonUtil.Style.QuestInProgress then
		POIButton_UpdateQuestInProgressStyle(self);
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
		if self:GetStyle() == POIButtonUtil.Style.QuestDisabled then
			return;
		end
		self.HighlightTexture:Show();
	else
		if (self:GetStyle() == POIButtonUtil.Style.QuestDisabled) or not self:IsMouseOver() then
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
	elseif quest:IsMeta() then
		return POIButtonUtil.QuestTypes.Meta;
	elseif QuestUtil.IsFrequencyRecurring(quest.frequency) then
		return POIButtonUtil.QuestTypes.Recurring;
	elseif quest:IsImportant() then
		return POIButtonUtil.QuestTypes.Important;
	elseif self:IsForWorldQuest() then
		local info = C_QuestLog.GetQuestTagInfo(questID);
		if info.quality == Enum.WorldQuestQuality.Rare then
			return POIButtonUtil.QuestTypes.Rare;
		elseif info.quality == Enum.WorldQuestQuality.Epic then
			return POIButtonUtil.QuestTypes.Epic;
		else
			return POIButtonUtil.QuestTypes.Normal;
		end
	else
		return POIButtonUtil.QuestTypes.Normal;
	end
end

function POIButtonMixin:CalculateButtonAlpha()
	return (self:GetStyle() == POIButtonUtil.Style.QuestDisabled) and 0 or 1;
end

function POIButtonMixin:UpdateInProgress()
	self.Display:UpdateInProgress();
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

function POIButtonMixin:IsForWorldQuest()
	return self.style == POIButtonUtil.Style.WorldQuest;
end

function POIButtonMixin:SetSelected(selected)
	self.selected = selected;
end

function POIButtonMixin:IsSelected()
	return not not self.selected;
end

function POIButtonMixin:ChangeSelected(selected)
	if self:IsSelected() ~= selected then
		self:SetSelected(selected);
		self:UpdateButtonStyle();
	end
end

function POIButtonMixin:GetButtonType()
	local questID = self:GetQuestID();
	if questID then
		return "quest";
	end

	local trackableType, trackableID = self:GetTrackable();
	if trackableType and trackableID then
		return "content";
	end
end

function POIButtonMixin:SetQuestTagInfo(info)
	self.questTagInfo = info;
end

function POIButtonMixin:ClearQuestTagInfo()
	self:SetQuestTagInfo(nil);
end

function POIButtonMixin:GetQuestTagInfo()
	return self.questTagInfo;
end

do
	local function CreateUnderlay(self)
		local t = self:CreateTexture(nil, "BORDER");
		t:SetSize(34, 34);
		t:SetPoint("CENTER", 0, -2);
		return t;
	end

	local function GetUnderlayAtlas(info)
		if info and info.isElite then
			return "worldquest-questmarker-dragon";
		end
	end

	local function CreateUnderlayBanner(self)
		local t = self:CreateTexture(nil, "BACKGROUND", nil, -3);
		t:SetSize(34, 34);
		t:SetPoint("TOP", self, "TOP", 0, 5);
		return t;
	end

	local function GetUnderlayBannerAtlas(info)
		if info and (info.worldQuestType == Enum.QuestTagType.Capstone) then
			return "worldquest-Capstone-Banner";
		end
	end

	local function CheckCreateUnderlay(self, parentKey, getAtlas, factory)
		local atlas = getAtlas(self:GetQuestTagInfo());
		local texture = self[parentKey];
		if atlas and not texture then
			texture = factory(self);
			texture:SetAtlas(atlas);
			self[parentKey] = texture;
		end

		if texture then
			texture:SetShown(atlas ~= nil);
		end
	end

	function POIButtonMixin:UpdateUnderlay()
		CheckCreateUnderlay(self, "UnderlayAtlas", GetUnderlayAtlas, CreateUnderlay);
		CheckCreateUnderlay(self, "UnderlayBannerAtlas", GetUnderlayBannerAtlas, CreateUnderlayBanner);
	end
end

local function OnSuperTrackingChanged_Quest(self, supertracker)
	assertsafe(self:GetButtonType() == "quest");

	local supertrackedQuestID = QuestSuperTracking_GetSuperTrackedQuestID(supertracker);
	local isSelected = self:GetQuestID() == supertrackedQuestID;
	self:ChangeSelected(isSelected);
end

local function OnSuperTrackingChanged_Content(self, supertracker)
	assertsafe(self:GetButtonType() == "content");

	local supertrackedType, supertrackedID = QuestSuperTracking_GetSuperTrackedContent(supertracker);
	local poiType, poiID = self:GetTrackable();
	local isSelected = (supertrackedType == poiType) and (supertrackedID == poiID);
	self:ChangeSelected(isSelected);
end

local superTrackerChangeHandlers =
{
	quest = OnSuperTrackingChanged_Quest,
	content = OnSuperTrackingChanged_Content,
};

function POIButtonMixin:OnSuperTrackingChanged(supertracker)
	local poiButtonType = self:GetButtonType();
	if poiButtonType then
		local handler = superTrackerChangeHandlers[poiButtonType];
		if handler then
			handler(self, supertracker);
		end
	end
end

function POIButtonMixin:UpdateSelected()
	self:OnSuperTrackingChanged();
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
