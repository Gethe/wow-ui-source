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
	self:SetAtlas(nil, nil, inProgressAtlas);
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

local function POIButton_GetLegendaryAtlasInfoNormal(poiButton)
	if poiButton:IsSelected() then
		return "UI-QuestPoiLegendary-QuestNumber-SuperTracked";
	else
		return "UI-QuestPoiLegendary-QuestNumber";
	end
end

local function POIButton_GetLegendaryAtlasInfoPushed(poiButton)
	if poiButton:IsSelected() then
		return "UI-QuestPoiLegendary-QuestNumber-Pressed-SuperTracked";
	else
		return "UI-QuestPoiLegendary-QuestNumber-Pressed";
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

local function POIButton_GetBonusObjectiveAtlasInfoNormal(poiButton)
	if poiButton:IsSelected() then
		return "worldquest-questmarker-epic-supertracked";
	else
		return "worldquest-questmarker-epic";
	end
end

local function POIButton_GetBonusObjectiveAtlasInfoPushed(poiButton)
	if poiButton:IsSelected() then
		return "worldquest-questmarker-epic-down-supertracked";
	else
		return "worldquest-questmarker-epic-down";
	end
end

local function POIButton_GetAreaPOIDisplay(poiButton)
	-- TODO: This could need to support textures, it just won't for now.
	-- Also, note that these currently all have to be map pins, that's where the
	local info = poiButton:GetAreaPOIInfo();

	-- Events that aren't current only use the default icon
	if not info.isCurrentEvent then
		return "UI-EventPoi-Horn-big";
	end

	-- Hack: Overrides for older events that haven't been updated
	if info.atlasName == "minimap-genericevent-hornicon" then
		return "UI-EventPoi-Horn-big";
	end

	return info.atlasName;
end

local function POIButton_GetAreaPOIAtlasInfoNormal(poiButton)
	if poiButton:IsSelected() then
		return "worldquest-questmarker-epic-supertracked";
	else
		return "worldquest-questmarker-epic";
	end
end

local function POIButton_GetAreaPOIAtlasInfoPushed(poiButton)
	if poiButton:IsSelected() then
		return "worldquest-questmarker-epic-down-supertracked";
	else
		return "worldquest-questmarker-epic-down";
	end
end

local function POIButton_GetContentTrackingAtlas(poiButton)
	if poiButton:IsSelected() then
		return "waypoint-mappin-minimap-tracked";
	else
		return "waypoint-mappin-minimap-untracked";
	end
end

local function POIButton_GetQuestCompleteAtlas(poiButton)
	local questID = poiButton:GetQuestID();
	local isLegendaryQuest = questID and C_QuestLog.IsLegendaryQuest(questID) or false;
	return isLegendaryQuest and "UI-QuestPoiLegendary-QuestBangTurnIn" or "UI-QuestIcon-TurnIn-Normal";
end

local function POIButton_UpdateQuestInProgressStyle(poiButton)
	local questClassification = poiButton:GetQuestClassification();
	if questClassification == Enum.QuestClassification.Legendary then
		POIButton_SetAtlas(poiButton.Glow, nil, nil, "UI-QuestPoiLegendary-OuterGlow");
		POIButton_SetAtlas(poiButton.NormalTexture, nil, nil, POIButton_GetLegendaryAtlasInfoNormal(poiButton));
		POIButton_SetAtlas(poiButton.PushedTexture, nil, nil, POIButton_GetLegendaryAtlasInfoPushed(poiButton));
		POIButton_SetAtlas(poiButton.HighlightTexture, nil, nil, "UI-QuestPoiLegendary-InnerGlow");
	elseif questClassification == Enum.QuestClassification.Campaign or questClassification == Enum.QuestClassification.Calling then
		POIButton_SetAtlas(poiButton.Glow, nil, nil, "UI-QuestPoiCampaign-OuterGlow");
		POIButton_SetAtlas(poiButton.NormalTexture, nil, nil, POIButton_GetCampaignAtlasInfoNormal(poiButton));
		POIButton_SetAtlas(poiButton.PushedTexture, nil, nil, POIButton_GetCampaignAtlasInfoPushed(poiButton));
		POIButton_SetAtlas(poiButton.HighlightTexture, nil, nil, "UI-QuestPoiCampaign-InnerGlow");
	elseif questClassification == Enum.QuestClassification.Recurring then
		POIButton_SetAtlas(poiButton.Glow, nil, nil, "UI-QuestPoiRecurring-OuterGlow");
		POIButton_SetAtlas(poiButton.NormalTexture, nil, nil, POIButton_GetRecurringAtlasInfoNormal(poiButton));
		POIButton_SetAtlas(poiButton.PushedTexture, nil, nil, POIButton_GetRecurringAtlasInfoPushed(poiButton));
		POIButton_SetAtlas(poiButton.HighlightTexture, nil, nil, "UI-QuestPoiRecurring-InnerGlow");
	elseif questClassification == Enum.QuestClassification.Important then
		POIButton_SetAtlas(poiButton.Glow, nil, nil, "UI-QuestPoiImportant-OuterGlow");
		POIButton_SetAtlas(poiButton.NormalTexture, nil, nil, POIButton_GetImportantAtlasInfoNormal(poiButton));
		POIButton_SetAtlas(poiButton.PushedTexture, nil, nil, POIButton_GetImportantAtlasInfoPushed(poiButton));
		POIButton_SetAtlas(poiButton.HighlightTexture, nil, nil, "UI-QuestPoiImportant-InnerGlow");
	elseif questClassification == Enum.QuestClassification.Meta then
		poiButton.Display:SetOffset(0, 0);
		POIButton_SetAtlas(poiButton.Glow, nil, nil, "UI-QuestPoiWrapper-OuterGlow");
		POIButton_SetAtlas(poiButton.NormalTexture, nil, nil, POIButton_GetMetaAtlasInfoNormal(poiButton));
		POIButton_SetAtlas(poiButton.PushedTexture, nil, nil, POIButton_GetMetaAtlasInfoPushed(poiButton));
		POIButton_SetAtlas(poiButton.HighlightTexture, nil, nil, "UI-QuestPoiWrapper-InnerGlow");
	else
		POIButton_SetAtlas(poiButton.Glow, nil, nil, "UI-QuestPoi-OuterGlow");
		POIButton_SetAtlas(poiButton.NormalTexture, nil, nil, POIButton_GetAtlasInfoNormal(poiButton));
		POIButton_SetAtlas(poiButton.PushedTexture, nil, nil, POIButton_GetAtlasInfoPushed(poiButton));
		POIButton_SetAtlas(poiButton.HighlightTexture, nil, nil, POIButton_GetAtlasInfoHighlight(poiButton));
	end

	poiButton:ClearQuestTagInfo();
	poiButton:UpdateInProgress();
	poiButton:UpdateUnderlay();
end

local function POIButton_UpdateNormalStyle(poiButton)
	-- This may be overridden later
	poiButton.Display:SetOffset(0, 0);

	local style = poiButton:GetStyle();
	if style == POIButtonUtil.Style.ContentTracking then
		poiButton.Display:SetAtlas(nil, nil, nil);
		POIButton_SetAtlas(poiButton.Glow, 32, 32, POIButton_GetContentTrackingAtlas(poiButton));
		POIButton_SetAtlas(poiButton.NormalTexture, 32, 32, POIButton_GetContentTrackingAtlas(poiButton));
		POIButton_SetAtlas(poiButton.PushedTexture, 32, 32, POIButton_GetContentTrackingAtlas(poiButton));
		POIButton_SetAtlas(poiButton.HighlightTexture, 32, 32, POIButton_GetContentTrackingAtlas(poiButton));
	elseif style == POIButtonUtil.Style.BonusObjective then
		poiButton.Display:SetAtlas(nil, nil, "Bonus-Objective-Star");
		POIButton_SetAtlas(poiButton.Glow, nil, nil, "UI-QuestPoi-OuterGlow");
		POIButton_SetAtlas(poiButton.NormalTexture, nil, nil, POIButton_GetBonusObjectiveAtlasInfoNormal(poiButton));
		POIButton_SetAtlas(poiButton.PushedTexture, nil, nil, POIButton_GetBonusObjectiveAtlasInfoPushed(poiButton));
		POIButton_SetAtlas(poiButton.HighlightTexture, nil, nil, POIButton_GetAtlasInfoHighlight(poiButton));
	elseif style == POIButtonUtil.Style.AreaPOI then
		poiButton.Display:SetAtlas(nil, nil, POIButton_GetAreaPOIDisplay(poiButton)); -- TODO: This could need to support textures, it just won't for now.
		POIButton_SetAtlas(poiButton.Glow, nil, nil, "UI-QuestPoi-OuterGlow");
		POIButton_SetAtlas(poiButton.NormalTexture, nil, nil, POIButton_GetAreaPOIAtlasInfoNormal(poiButton));
		POIButton_SetAtlas(poiButton.PushedTexture, nil, nil, POIButton_GetAreaPOIAtlasInfoPushed(poiButton));
		POIButton_SetAtlas(poiButton.HighlightTexture, nil, nil, POIButton_GetAtlasInfoHighlight(poiButton));
	else
		local questClassification = poiButton:GetQuestClassification();

		if questClassification == Enum.QuestClassification.Legendary then
			poiButton.Display:SetAtlas(nil, nil, "UI-QuestPoiLegendary-QuestBangTurnIn");
		elseif questClassification == Enum.QuestClassification.Campaign then
			poiButton.Display:SetAtlas(nil, nil, "UI-QuestPoiCampaign-QuestBangTurnIn");
		elseif questClassification == Enum.QuestClassification.Calling then
			poiButton.Display:SetAtlas(nil, nil, "UI-DailyQuestPoiCampaign-QuestBangTurnIn");
		elseif questClassification == Enum.QuestClassification.Recurring then
			poiButton.Display:SetAtlas(nil, nil, "UI-QuestPoiRecurring-QuestBangTurnIn");
		elseif questClassification == Enum.QuestClassification.Important then
			poiButton.Display:SetAtlas(nil, nil, "UI-QuestPoiImportant-QuestBangTurnIn");
		elseif questClassification == Enum.QuestClassification.Meta then
			poiButton.Display:SetAtlas(nil, nil, "UI-QuestPoiWrapper-QuestBangTurnIn");
		end

		local basicLook = not questClassification or (questClassification == Enum.QuestClassification.Normal) or (questClassification == Enum.QuestClassification.Questline);
		if basicLook then
			poiButton.Display:SetAtlas(nil, nil, POIButton_GetQuestCompleteAtlas(poiButton));
			POIButton_SetAtlas(poiButton.Glow, nil, nil, "UI-QuestPoi-OuterGlow");
			POIButton_SetAtlas(poiButton.NormalTexture, nil, nil, POIButton_GetAtlasInfoNormal(poiButton));
			POIButton_SetAtlas(poiButton.PushedTexture, nil, nil, POIButton_GetAtlasInfoPushed(poiButton));
			POIButton_SetAtlas(poiButton.HighlightTexture, nil, nil, POIButton_GetAtlasInfoHighlight(poiButton));
		elseif questClassification == Enum.QuestClassification.Recurring then
			poiButton.Display:SetOffset(0, 0);
			POIButton_SetAtlas(poiButton.Glow, nil, nil, "UI-QuestPoiRecurring-OuterGlow");
			POIButton_SetAtlas(poiButton.NormalTexture, nil, nil, POIButton_GetRecurringAtlasInfoNormal(poiButton));
			POIButton_SetAtlas(poiButton.PushedTexture, nil, nil, POIButton_GetRecurringAtlasInfoPushed(poiButton));
			POIButton_SetAtlas(poiButton.HighlightTexture, nil, nil, "UI-QuestPoiRecurring-InnerGlow");
		elseif questClassification == Enum.QuestClassification.Important then
			poiButton.Display:SetOffset(0, 0);
			POIButton_SetAtlas(poiButton.Glow, nil, nil, "UI-QuestPoiImportant-OuterGlow");
			POIButton_SetAtlas(poiButton.NormalTexture, nil, nil, POIButton_GetImportantAtlasInfoNormal(poiButton));
			POIButton_SetAtlas(poiButton.PushedTexture, nil, nil, POIButton_GetImportantAtlasInfoPushed(poiButton));
			POIButton_SetAtlas(poiButton.HighlightTexture, nil, nil, "UI-QuestPoiImportant-InnerGlow");
		elseif questClassification == Enum.QuestClassification.Meta then
			poiButton.Display:SetOffset(0, 0);
			POIButton_SetAtlas(poiButton.Glow, nil, nil, "UI-QuestPoiWrapper-OuterGlow");
			POIButton_SetAtlas(poiButton.NormalTexture, nil, nil, POIButton_GetMetaAtlasInfoNormal(poiButton));
			POIButton_SetAtlas(poiButton.PushedTexture, nil, nil, POIButton_GetMetaAtlasInfoPushed(poiButton));
			POIButton_SetAtlas(poiButton.HighlightTexture, nil, nil, "UI-QuestPoiWrapper-InnerGlow");
		elseif questClassification == Enum.QuestClassification.WorldQuest then
			poiButton.Display:SetOffset(0, 0);
			POIButton_SetAtlas(poiButton.Glow, nil, nil, "UI-QuestPoi-OuterGlow");
			POIButton_SetAtlas(poiButton.NormalTexture, nil, nil, POIButton_GetAtlasInfoNormal(poiButton));
			POIButton_SetAtlas(poiButton.PushedTexture, nil, nil, POIButton_GetAtlasInfoPushed(poiButton));
			POIButton_SetAtlas(poiButton.HighlightTexture, nil, nil, POIButton_GetAtlasInfoHighlight(poiButton));
		elseif questClassification == Enum.QuestClassification.Legendary then
			poiButton.Display:SetOffset(0, 0);
			POIButton_SetAtlas(poiButton.Glow, nil, nil, "UI-QuestPoiLegendary-OuterGlow");
			POIButton_SetAtlas(poiButton.NormalTexture, nil, nil, POIButton_GetLegendaryAtlasInfoNormal(poiButton));
			POIButton_SetAtlas(poiButton.PushedTexture, nil, nil, POIButton_GetLegendaryAtlasInfoPushed(poiButton));
			POIButton_SetAtlas(poiButton.HighlightTexture, nil, nil, "UI-QuestPoiLegendary-InnerGlow");
		else
			poiButton.Display:SetOffset(0, 0);
			POIButton_SetAtlas(poiButton.Glow, nil, nil, "UI-QuestPoiCampaign-OuterGlow");
			POIButton_SetAtlas(poiButton.NormalTexture, nil, nil, POIButton_GetCampaignAtlasInfoNormal(poiButton));
			POIButton_SetAtlas(poiButton.PushedTexture, nil, nil, POIButton_GetCampaignAtlasInfoPushed(poiButton));
			POIButton_SetAtlas(poiButton.HighlightTexture, nil, nil, "UI-QuestPoiCampaign-InnerGlow");
		end

		local buttonAlpha = poiButton:CalculateButtonAlpha();
		poiButton.NormalTexture:SetAlpha(buttonAlpha);
		poiButton.PushedTexture:SetAlpha(buttonAlpha);

		poiButton:ClearQuestTagInfo();

		local questID = poiButton:GetQuestID();

		if style == POIButtonUtil.Style.QuestComplete then
			-- Nothing else to do
		elseif style == POIButtonUtil.Style.Waypoint then
			poiButton.Display:SetAtlas(13, 17, "poi-traveldirections-arrow");
		elseif style == POIButtonUtil.Style.QuestDisabled then
			poiButton.Display:SetAtlas(24, 29, "QuestSharing-QuestLog-Padlock");
		elseif style == POIButtonUtil.Style.QuestThreat then
			local iconAtlas = QuestUtil.GetThreatPOIIcon(questID);
			poiButton.Display:SetAtlas(18, 18, iconAtlas);
			poiButton.Display:SetOffset(0, 0);
		elseif style == POIButtonUtil.Style.WorldQuest then
			local info = C_QuestLog.GetQuestTagInfo(questID);
			poiButton:SetQuestTagInfo(info);
			if info then
				-- NOTE: In-progress isn't really used any more, but this should be stored on the poiButton as some kind of state
				-- it can't be passed in as a hardcoded false.
				local atlas, width, height = QuestUtil.GetWorldQuestAtlasInfo(questID, info, false);
				poiButton.Display:SetAtlas(width, height, atlas);

				-- Update the glow if this is an elite quest, the size needs to be hardcoded for now
				if info.isElite then
					POIButton_SetAtlas(poiButton.Glow, nil, nil, "worldquest-questmarker-dragon-glow");
				end
			end
		end
	end

	poiButton:UpdateUnderlay();
	poiButton:UpdateSubTypeIcon();
end

POIButtonMixin = {};

function POIButtonMixin:IsPOIButton()
    return true;
end

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

function POIButtonMixin:OnClick(button)
	if button ~= "LeftButton" then
		return;
	end

	if self:IsSelected() then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		C_SuperTrack.ClearAllSuperTracked();
		return;
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

	local questID = self:GetQuestID();
	if questID then
		if ChatEdit_TryInsertQuestLinkForQuestID(questID) then
			return;
		end

		if QuestUtils_IsQuestWatched(questID) then
			if IsShiftKeyDown() then
				C_QuestLog.RemoveQuestWatch(questID);
				return;
			end
		else
			C_QuestLog.AddQuestWatch(questID);
		end

		C_SuperTrack.SetSuperTrackedQuestID(questID);
		if self:GetPingWorldMap() then
			WorldMapPing_StartPingQuest(questID);
		end
		return;
	end

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

		C_SuperTrack.SetSuperTrackedContent(trackableType, trackableID);
		return;
	end

	local areaPOIID = self:GetAreaPOIID();
	if areaPOIID then
		C_SuperTrack.SetSuperTrackedMapPin(Enum.SuperTrackingMapPinType.AreaPOI, areaPOIID);
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

			if self.UnderlayBannerAtlasHighlight and self:IsUnderlayBannerEnabled() then
				self.UnderlayBannerAtlasHighlight:Show();
			end
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

		if self.UnderlayBannerAtlasHighlight then
			self.UnderlayBannerAtlasHighlight:Hide();
		end
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

function POIButtonMixin:GetQuestClassification()
	local questID = self:GetQuestID();
	if questID then
		return QuestCache:Get(questID):GetQuestClassification();
	end

	return nil;
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

function POIButtonMixin:SetAreaPOIInfo(info)
	self.areaPOIInfo = info;
	self:SetAreaPOIID(info.areaPoiID);
end

function POIButtonMixin:GetAreaPOIInfo()
	return self.areaPOIInfo;
end

function POIButtonMixin:SetAreaPOIID(areaPOIID)
	self.areaPOIID = areaPOIID;
end

function POIButtonMixin:GetAreaPOIID()
	return self.areaPOIID;
end

function POIButtonMixin:SetPinScale(scale)
	self.pinScale = scale;
end

function POIButtonMixin:GetPinScale()
	return self.pinScale or 1;
end

function POIButtonMixin:SetPingWorldMap(ping)
	self.pingWorldMap = ping;
end

function POIButtonMixin:GetPingWorldMap()
	return self.pingWorldMap;
end

function POIButtonMixin:SetStyle(poiButtonStyle)
	self.style = poiButtonStyle;
	self.type = POIButtonUtil.GetTypeFromStyle(poiButtonStyle);
end

function POIButtonMixin:GetStyle()
	return self.style;
end

function POIButtonMixin:GetButtonType()
	return self.type;
end

function POIButtonMixin:IsForWorldQuest()
	return self:GetStyle() == POIButtonUtil.Style.WorldQuest;
end

function POIButtonMixin:SetSelected(selected)
	self.selected = selected;
end

function POIButtonMixin:ClearSelected()
	self:SetSelected(nil);
end

function POIButtonMixin:IsSelected()
	-- This can be returned as true/false/nil
	-- Nil indicates that it has not been initialized yet so that the selected update can easily work.
	return self.selected;
end

function POIButtonMixin:ChangeSelected(selected)
	if self:IsSelected() ~= selected then
		self:SetSelected(selected);
		self:UpdateButtonStyle();
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

function POIButtonMixin:SetUnderlayBannerEnabled(enabled)
	self.underlayBannerEnabled = enabled;
end

function POIButtonMixin:IsUnderlayBannerEnabled()
	return self.underlayBannerEnabled;
end

do
	local function CreateUnderlay(self)
		local t = self:CreateTexture(nil, "BORDER");
		t:SetPoint("CENTER");
		return t;
	end

	local function GetUnderlayAtlas(self)
		local info = self:GetQuestTagInfo();
		if info and info.isElite then
			return "worldquest-questmarker-dragon", TextureKitConstants.UseAtlasSize;
		end
	end

	local function CreateUnderlayBannerInternal(self, sublevel)
		local t = self:CreateTexture(nil, "BACKGROUND", nil, sublevel);
		t:SetSize(34, 34); -- TODO: Would be ideal to avoid hardcoding these sizes/offsets
		t:SetPoint("TOP", self, "TOP", 0, 5);
		return t;
	end

	local function CreateUnderlayBanner(self)
		return CreateUnderlayBannerInternal(self, -4);
	end

	local function CreateUnderlayBannerHighlight(self)
		local t = CreateUnderlayBannerInternal(self, -3);
		t:SetBlendMode("ADD");
		t:SetAlpha(0.3);
		return t;
	end

	local function GetUnderlayBannerAtlas(self)
		local info = self:GetQuestTagInfo();
		self:SetUnderlayBannerEnabled(info and (info.worldQuestType == Enum.QuestTagType.Capstone));
		
		if self:IsUnderlayBannerEnabled() then
			return "worldquest-Capstone-Banner", TextureKitConstants.IgnoreAtlasSize;
		end
	end

	local function CheckCreateExtraTexture(self, parentKey, getAtlas, factory, overrideParent)
		local atlas, useAtlasSize = getAtlas(self); -- self must be a POIButton here
		local parent = overrideParent or self;
		local texture = parent[parentKey];
		if atlas and not texture then
			texture = factory(parent);
			texture:SetAtlas(atlas, useAtlasSize);
			parent[parentKey] = texture;
		end

		if texture then
			texture:SetShown(atlas ~= nil);
		end
	end

	function POIButtonMixin:UpdateUnderlay()
		CheckCreateExtraTexture(self, "UnderlayAtlas", GetUnderlayAtlas, CreateUnderlay);
		CheckCreateExtraTexture(self, "UnderlayBannerAtlas", GetUnderlayBannerAtlas, CreateUnderlayBanner);
		CheckCreateExtraTexture(self, "UnderlayBannerAtlasHighlight", GetUnderlayBannerAtlas, CreateUnderlayBannerHighlight);
	end

	local function GetSubTypeAtlas(self)
		local areaPOIInfo = self:GetAreaPOIInfo();
		if areaPOIInfo and areaPOIInfo.isCurrentEvent then
			-- TODO: The 2x atlases weren't made correctly, must override size...remove this when the fix propagates
			-- return "UI-EventPoi-Horn-small-corner", TextureKitConstants.UseAtlasSize;
			return "UI-EventPoi-Horn-small-corner", TextureKitConstants.IgnoreAtlasSize;
		end
	end

	local function CreateSubTypeIcon(self) -- NOTE: self is a POIButton.Display here.
		local t = self:CreateTexture(nil, "ARTWORK", nil, 2);
		t:SetSize(32, 32); -- TODO: The 2x atlases weren't made correctly, must override size...remove this when the fix propagates
		t:SetPoint("CENTER", self, "CENTER", 0, 0); -- TODO: Would be ideal to avoid hardcoding these sizes/offsets
		return t;
	end

	function POIButtonMixin:UpdateSubTypeIcon()
		CheckCreateExtraTexture(self, "SubTypeIcon", GetSubTypeAtlas, CreateSubTypeIcon, self.Display);
	end
end

local function OnSuperTrackingChanged_Quest(self, supertracker)
	assertsafe(self:GetButtonType() == POIButtonUtil.Type.Quest);

	local supertrackedQuestID = QuestSuperTracking_GetSuperTrackedQuestID(supertracker);
	local isSelected = self:GetQuestID() == supertrackedQuestID;
	self:ChangeSelected(isSelected);
end

local function OnSuperTrackingChanged_Content(self, supertracker)
	assertsafe(self:GetButtonType() == POIButtonUtil.Type.Content);

	local supertrackedType, supertrackedID = QuestSuperTracking_GetSuperTrackedContent(supertracker);
	local poiType, poiID = self:GetTrackable();
	local isSelected = (supertrackedType == poiType) and (supertrackedID == poiID);
	self:ChangeSelected(isSelected);
end

local function OnSuperTrackingChanged_AreaPOI(self, supertracker)
	assertsafe(self:GetButtonType() == POIButtonUtil.Type.AreaPOI);

	local supertrackedType, supertrackedID = QuestSuperTracking_GetSuperTrackedMapPin(supertracker);
	local areaPOIID = self:GetAreaPOIID();
	local isSelected = (supertrackedType == Enum.SuperTrackingMapPinType.AreaPOI) and (supertrackedID == self:GetAreaPOIID());
	self:ChangeSelected(isSelected);
end

local superTrackerChangeHandlers =
{
	[POIButtonUtil.Type.Quest] = OnSuperTrackingChanged_Quest,
	[POIButtonUtil.Type.Content] = OnSuperTrackingChanged_Content,
	[POIButtonUtil.Type.AreaPOI] = OnSuperTrackingChanged_AreaPOI,
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
	self.pingWorldMap = nil;
	self.pinScale = nil;
	self.index = nil;
	self.questID = nil;
	self.areaPOIID = nil;
	self.trackableType = nil;
	self.trackableID = nil;
	self.style = nil;
	self.type = nil;
	self.selected = nil;
end

-- Override methods for when a POIButton is used in the context of a map canvas

function POIButtonMixin:SetMapPinScale(scale, scaleFactor, startScale, endScale)
	self:SetScalingLimits(scaleFactor, startScale, endScale);
	self:SetPinScale(scale);
end

function POIButtonMixin:SetDefaultMapPinScale()
	self:SetMapPinScale(1, 1, 1, 1);
end
