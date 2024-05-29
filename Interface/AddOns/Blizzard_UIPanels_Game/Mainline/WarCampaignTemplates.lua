local CAMPAIGN_TITLE_MAX_WIDTH = 214;

CampaignTooltipMixin = {};

function CampaignTooltipMixin:OnShow()
	self.ticker = C_Timer.NewTicker(0.25, function()
		self:SetCampaign(self.campaign);
	end)
end

function CampaignTooltipMixin:OnHide()
	if ( self.ticker ) then
		self.ticker:Cancel();
		self.ticker = nil;
	end
end

function CampaignTooltipMixin:SetCampaign(campaign)
	self.campaign = campaign;

	if campaign.isWarCampaign then
		self:SetWarCampaign(campaign);
	else
		self:SetJourneyCampaign(campaign);
	end
end

function CampaignTooltipMixin:SetWarCampaign(campaign)
	-- Restore spacing
	self.ChapterTitle:SetSpacing(0);
	self.Description:SetSpacing(0);

	self.Title:SetText(campaign.name);

	local chapterID = campaign:GetCurrentChapterID();
	if (chapterID) then
		local campaignChapterInfo = C_CampaignInfo.GetCampaignChapterInfo(chapterID);
		if (campaignChapterInfo) then
			self.ChapterTitle:SetText(campaignChapterInfo.name);
			self.Description:SetText(campaignChapterInfo.description);
			self.Description:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
			if ( GetNumQuestLogRewards(campaignChapterInfo.rewardQuestID) > 0 ) then
				if (not EmbeddedItemTooltip_SetItemByQuestReward(self.ItemTooltip, 1, campaignChapterInfo.rewardQuestID)) then
					self.ItemTooltip:Hide();
				end
			elseif C_QuestInfoSystem.HasQuestRewardSpells(campaignChapterInfo.rewardQuestID) then
				if not EmbeddedItemTooltip_SetSpellByFirstQuestReward(self.ItemTooltip, campaignChapterInfo.rewardQuestID) then
					self.ItemTooltip:Hide();
				end
			else
				if (QuestUtils_AddQuestCurrencyRewardsToTooltip(campaignChapterInfo.rewardQuestID, nil, self.ItemTooltip) == 0 ) then
					self.ItemTooltip:Hide();
				end
				EmbeddedItemTooltip_UpdateSize(self.ItemTooltip);
			end
		else
			self.ChapterTitle:SetText(campaign.name);

			local failureReason = campaign:GetFailureReason();
			self.Description:SetText(failureReason and failureReason.text or "");

			self.ItemTooltip:Hide();
			self.Description:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		end
	else
		if campaign:IsComplete() then
			self.Description:SetText(WAR_CAMPAIGN_DONE_DESCRIPTION);
		else
			local failureReason = campaign:GetFailureReason();
			self.Description:SetText(failureReason and failureReason.text or "");
		end
		self.ChapterTitle:SetText(nil);
		self.ItemTooltip:Hide();
		self.Description:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	end

	if (self.ItemTooltip:IsShown()) then
		self.CompleteRewardText:Show();
	else
		self.CompleteRewardText:Hide();
	end

	self:Layout();
	self:Show();
end

function CampaignTooltipMixin:SetJourneyCampaign(campaign)
	self.ItemTooltip:Hide();
	self.CompleteRewardText:Hide();

	local lineSpacing = 4;
	self.ChapterTitle:SetSpacing(lineSpacing);
	self.Description:SetSpacing(lineSpacing);

	self.Title:SetText(campaign.name);
	self.ChapterTitle:SetText(CampaignUtil.BuildChapterProgressText(campaign, CAMPAIGN_PROGRESS_CHAPTERS_TOOLTIP));
	self.Description:SetText(CampaignUtil.BuildAllChaptersText(campaign, lineSpacing));

	self:Layout();
	self:Show();
end

CampaignHeaderDisplayMixin = {};

function CampaignHeaderDisplayMixin:UpdateComplete(isComplete)
	self.Background:SetDesaturated(isComplete);
end

local function SetFieldText(field, text, color)
	field:SetText(text or "");
	field:SetTextColor((color or NORMAL_FONT_COLOR):GetRGB());
end

function CampaignHeaderDisplayMixin:SetProgressText(text, color)
	SetFieldText(self.Progress, text, color);
end

function CampaignHeaderDisplayMixin:UpdateJourneyProgressText(state)
	local campaign = self:GetCampaign();
	if campaign:IsContainerCampaign() then
		self:SetProgressText(CONTAINER_CAMPAIGN_PROGRESS, HIGHLIGHT_FONT_COLOR);
	else
		local text = CampaignUtil.BuildChapterProgressText(self:GetCampaign());
		self:SetProgressText(text, HIGHLIGHT_FONT_COLOR);
	end
end

function CampaignHeaderDisplayMixin:UpdateProgress(state)
	self:UpdateJourneyProgressText(state);
end

function CampaignHeaderDisplayMixin:UpdateNextObjective(state)
	if state == Enum.CampaignState.Stalled and not self.suppressNextText then
		local failureReason = self:GetCampaign():GetFailureReason();
		if failureReason and failureReason.text and not self:IsCollapsed() then
			self.NextObjective:Set(failureReason);
			self:SetHitRectInsets(0, 0, 0, self.NextObjective.Text:GetStringHeight() + 6);
			self.bottomPadding = 10;
			return;
		end
	end

	self.NextObjective:Clear();
	self:SetHitRectInsets(0, 0, 0, 0);
	self.bottomPadding = 0;
end

function CampaignHeaderDisplayMixin:UpdateTitle(isComplete)
	local useHighlight = not isComplete;
	self.Text:SetWidth(CAMPAIGN_TITLE_MAX_WIDTH);
	SetFieldText(self.Text, self:GetCampaign().name, QuestLogHeaderCodeMixin.GetTitleColor(self, useHighlight));
	local stringWidth = self.Text:GetStringWidth();
	-- add 1 so any rounding in the wrong direction doesn't cause "..." to appear
	self.Text:SetWidth(stringWidth + 1);
end

do

	local CampaignTextureKitInfo = {
		Background = "Campaign_%s",
		HighlightTexture = "Campaign_%s",
	};

	function CampaignHeaderDisplayMixin:UpdateTextureKit()
		SetupTextureKitOnRegions(self:GetCampaign().uiTextureKit, self, CampaignTextureKitInfo);
	end
end

function CampaignHeaderDisplayMixin:SetCampaign(campaignID)
	local campaign = CampaignCache:Get(campaignID);
	self.campaign = campaign;

	self:UpdateTextureKit();

	if self.CollapseButton then
		self.CollapseButton:SetShown(not campaign:IsContainerCampaign());
	end

	local state = campaign:GetState();
	local isComplete = state == Enum.CampaignState.Complete;
	self:UpdateComplete(isComplete);
	self:UpdateTitle(isComplete);
	self:UpdateProgress(state);
	self:UpdateNextObjective(state);
	self:MarkDirty();
	self:Show();
end

function CampaignHeaderDisplayMixin:GetCampaign()
	return self.campaign;
end

function CampaignHeaderDisplayMixin:SetCampaignFromQuestHeader(questHeader)
	self.questLogIndex = questHeader.questLogIndex;
	self.isCollapsed = questHeader.isCollapsed;
	self:SetCampaign(questHeader.campaignID);
end

function CampaignHeaderDisplayMixin:GetQuestLogIndex()
	return self.questLogIndex;
end

function CampaignHeaderDisplayMixin:IsCollapsed()
	return self.isCollapsed;
end

CampaignHeaderCollapsibleMixin = {};

function CampaignHeaderCollapsibleMixin:OnClick(button)
	local campaign = self:GetCampaign();
	if campaign:IsContainerCampaign() then		
		return;
	end

	if button == "LeftButton" then
		if self:IsCollapsed() then
			self.minimumHeight = self.minimumExpandedHeight;
		else
			self.minimumHeight = self.minimumCollapsedHeight;
		end
		local isCollapsed = self:ToggleCollapsed();

		if isCollapsed then
			PlaySound(SOUNDKIT.UI_JOURNEYS_COLLAPSE_HEADER);
		else
			PlaySound(SOUNDKIT.UI_JOURNEYS_EXPAND_HEADER);
		end
	end
end

function CampaignHeaderCollapsibleMixin:SetCollapsed(collapsed)
	-- Make the request to the client, allow the update to refresh the visual state.
	if collapsed then
		CollapseQuestHeader(self.questLogIndex);
	else
		ExpandQuestHeader(self.questLogIndex);
	end

	return collapsed;
end

function CampaignHeaderCollapsibleMixin:ToggleCollapsed()
	return self:SetCollapsed(not self:IsCollapsed());
end

function CampaignHeaderCollapsibleMixin:UpdateCollapsedState()
	local isCollapsed = self:IsCollapsed();
	self.CollapseButton:UpdateCollapsedState(isCollapsed);
	if self.SelectedHighlight then
		self.SelectedHighlight:SetShown(not isCollapsed);
	end
	return isCollapsed;
end

CampaignHeaderTooltipableMixin = {};

function CampaignHeaderTooltipableMixin:ShowTooltip()
	local campaign = self:GetCampaign();
	if campaign:IsContainerCampaign() then
		return;
	end
	
	local tooltip = QuestMapLog_GetCampaignTooltip();
	tooltip:SetCampaign(campaign);
	tooltip:ClearAllPoints();
	if (tooltip:GetWidth() > UIParent:GetRight() - WorldMapFrame:GetRight()) then
		tooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 0);
	else
		tooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 27, 0);
	end
	tooltip:Show();
end

CampaignHeaderMixin = CreateFromMixins(CampaignHeaderDisplayMixin);

function CampaignHeaderMixin:GetButtonType()
	return QuestLogButtonTypes.HeaderCampaign;
end

function CampaignHeaderMixin:SetCampaign(campaignID)
	CampaignHeaderDisplayMixin.SetCampaign(self, campaignID);

	self:UpdateCollapsedState();
	self:RequestLore();
end

function CampaignHeaderMixin:RequestLore()
	self.LoreButton:SetMode("overview");
	self:RegisterEvent("LORE_TEXT_UPDATED_CAMPAIGN");
	self.hasLoreEntries = false;
	C_LoreText.RequestLoreTextForCampaignID(self:GetCampaign():GetID());
end

function CampaignHeaderMixin:OnEnter()
	self:ShowTooltip();
	self.HighlightTexture:Show();
	-- Keep requesting lore for every mouse enter, the alternative is to make the dangerous assumption that lore would only update on quest complete
	if not self:HasLoreEntries() then
		C_LoreText.RequestLoreTextForCampaignID(self:GetCampaign():GetID());
	end
end

function CampaignHeaderMixin:OnLeave()
	QuestMapLog_GetCampaignTooltip():Hide();
	self.HighlightTexture:Hide();
end

function CampaignHeaderMixin:CheckOnLeave()
	-- nop
end

function CampaignHeaderMixin:OnMouseUp(button, upInside)
	if upInside then
		self:OnClick(button);
	end
	local pressed = false;
	self.CollapseButton:UpdatePressedState(pressed);
end

function CampaignHeaderMixin:OnMouseDown()
	local pressed = true;
	self.CollapseButton:UpdatePressedState(pressed);
end

function CampaignHeaderMixin:OnEvent(event, ...)
	if event == "LORE_TEXT_UPDATED_CAMPAIGN" then
		local id, entries = ...;
		if id == self:GetCampaign():GetID() then
			self.hasLoreEntries = #entries > 0;
			if self.hasLoreEntries then
				self:UnregisterEvent("LORE_TEXT_UPDATED_CAMPAIGN");
			end
			self:UpdateLoreButtonVisibility();
		end
	end
end

function CampaignHeaderMixin:HasLoreEntries()
	return self.hasLoreEntries;
end

function CampaignHeaderMixin:UpdateLoreButtonVisibility()
	local showLore = self:HasLoreEntries();
	self.LoreButton:SetShown(showLore);
	self:SetDrawLayerEnabled("HIGHLIGHT", mouseOver);

	if showLore then
		self:CheckShowLoreTutorial();
	end
end

local function UnlockLoreButtonFromHelpTip(acknowledged, campaignHeader)
	campaignHeader:SetLoreButtonLocked(false);
	campaignHeader:UpdateLoreButtonVisibility();
end

function CampaignHeaderMixin:SetLoreButtonLocked(locked)
	self.loreButtonLocked = locked;
end

function CampaignHeaderMixin:IsLoreButtonLocked()
	return self.loreButtonLocked;
end

function CampaignHeaderMixin:CheckShowLoreTutorial()
	if HelpTip:IsShowing(QuestScrollFrame, CAMPAIGN_LORE_BUTTON_HELPTIP) then
		return;
	end

	local helpTipInfo =
	{
		text = CAMPAIGN_LORE_BUTTON_HELPTIP,
		buttonStyle = HelpTip.ButtonStyle.Close,
		targetPoint = HelpTip.Point.TopEdgeCenter,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_CAMPAIGN_LORE_TEXT,
		checkCVars = true,
		onHideCallback = UnlockLoreButtonFromHelpTip,
		callbackArg = self,
		system = "LoreTextButton",
	};

	if HelpTip:Show(QuestScrollFrame, helpTipInfo, self.LoreButton) then
		self:SetLoreButtonLocked(true);
	end
end

CampaignHeaderMinimalMixin = CreateFromMixins(CampaignHeaderDisplayMixin);

function CampaignHeaderMinimalMixin:GetButtonType()
	return QuestLogButtonTypes.HeaderCampaignMinimal;
end

function CampaignHeaderMinimalMixin:CheckOnLeave()
	self:OnLeave();
end

function CampaignHeaderMinimalMixin:SetCampaign(campaignID)
	CampaignHeaderDisplayMixin.SetCampaign(self, campaignID);

	self:UpdateCollapsedState();
end

function CampaignHeaderMinimalMixin:UpdateTitle(isComplete)
	local useHighlight = false;
	SetFieldText(self.Text, self:GetCampaign().name, QuestLogHeaderCodeMixin.GetTitleColor(self, useHighlight));
end

function CampaignHeaderMinimalMixin:UpdateTextureKit()
	-- nop
end

function CampaignHeaderMinimalMixin:UpdateComplete()
	-- nop
end

function CampaignHeaderMinimalMixin:UpdateProgress()
	-- nop
end

function CampaignHeaderMinimalMixin:UpdateTextureKit()
	-- nop
end

CampaignLoreButtonMixin = {};

function CampaignLoreButtonMixin:SetMode(mode)
	if mode ~= self.mode then
		if mode == "overview" then
			self:SetHighlightAtlas("Campaign-QuestLog-LoreBook-Highlight", "ADD");
			self:SetNormalAtlas("Campaign-QuestLog-LoreBook");
		elseif mode == "questlog" then
			self:SetHighlightAtlas("Campaign-QuestLog-LoreBook-Back-Glow", "ADD");
			self:SetNormalAtlas("Campaign-QuestLog-LoreBook-Back");
		end

		self.mode = mode;
	end
end

function CampaignLoreButtonMixin:OnClick()
	if self.mode == "overview" then
		PlaySound(SOUNDKIT.UI_JOURNEYS_OPEN_LORE_BOOK);
		HelpTip:Acknowledge(QuestScrollFrame, CAMPAIGN_LORE_BUTTON_HELPTIP);
		EventRegistry:TriggerEvent("QuestLog.ShowCampaignOverview", self:GetParent():GetCampaign():GetID());
	elseif self.mode == "questlog" then
		PlaySound(SOUNDKIT.UI_JOURNEYS_CLOSE_LORE_BOOK);
		EventRegistry:TriggerEvent("QuestLog.HideCampaignOverview");
	end
end

function CampaignLoreButtonMixin:OnEnter()
	if self.Glow then
		self.Glow:SetShown(self.mode == "overview");
	end
end

function CampaignLoreButtonMixin:OnLeave()
	if self.Glow then
		self.Glow:Hide();
	end
end

CampaignNextObjectiveMixin = {};

function CampaignNextObjectiveMixin:Set(failureReason)
	self.mapID = failureReason.mapID;
	self.questID = failureReason.questID;
	if failureReason.text then
		self.Text:SetText(failureReason.text);
	end

	self:Show();
	self:MarkDirty();
end

function CampaignNextObjectiveMixin:Clear()
	self.Text:SetText("");
	self.mapID = nil;
	self:Hide();
	self:GetParent():MarkDirty();
end

function CampaignNextObjectiveMixin:OnEnter()
	self.Text:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGBA());
end

function CampaignNextObjectiveMixin:OnLeave()
	self.Text:SetTextColor(NORMAL_FONT_COLOR:GetRGBA());
end

function CampaignNextObjectiveMixin:OnMouseUp(button, upInside)
	if self.mapID and upInside and button == "LeftButton" then
		OpenWorldMap(self.mapID); -- and ping quest?
	end
end