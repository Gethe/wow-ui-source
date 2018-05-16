WarCampaignTooltipMixin = {};

function WarCampaignTooltipMixin:OnLoad()
	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
end

function WarCampaignTooltipMixin:OnShow()
	self.ticker = C_Timer.NewTicker(0.25, function()
		self:SetWarCampaign(self.warCampaignID);
	end)
end

function WarCampaignTooltipMixin:OnHide()
	if ( self.ticker ) then
		self.ticker:Cancel();
		self.ticker = nil;
	end
end

function WarCampaignTooltipMixin:SetWarCampaign(warCampaignID)
	self.warCampaignID = warCampaignID;
	local warCampaignInfo = C_CampaignInfo.GetCampaignInfo(warCampaignID);
	
	assert(warCampaignInfo);
	self.Title:SetText(warCampaignInfo.name);
	local campaignChapterID = C_CampaignInfo.GetCurrentCampaignChapterID();

	if (campaignChapterID) then
		local campaignChapterInfo = C_CampaignInfo.GetCampaignChapterInfo(campaignChapterID);
		if (campaignChapterInfo) then
			self.ChapterTitle:SetText(campaignChapterInfo.name);
			self.Description:SetText(campaignChapterInfo.description);
			self.Description:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
			if ( GetNumQuestLogRewards(campaignChapterInfo.rewardQuestID) > 0 ) then
				if (not EmbeddedItemTooltip_SetItemByQuestReward(self.ItemTooltip, 1, campaignChapterInfo.rewardQuestID)) then
					self.ItemTooltip:Hide();
				end
			elseif ( GetNumQuestLogRewardSpells(campaignChapterInfo.rewardQuestID) > 0 ) then
				if (not EmbeddedItemTooltip_SetSpellByQuestReward(self.ItemTooltip, 1, campaignChapterInfo.rewardQuestID)) then
					self.ItemTooltip:Hide();
				end
			else
				if (QuestUtils_AddQuestCurrencyRewardsToTooltip(campaignChapterInfo.rewardQuestID, nil, self.ItemTooltip) == 0 ) then
					self.ItemTooltip:Hide();
				end
				EmbeddedItemTooltip_UpdateSize(self.ItemTooltip);
			end
		else
			self.ChapterTitle:SetText(warCampaignInfo.name);
			self.Description:SetText(warCampaignInfo.playerConditionFailedReason);
			self.ItemTooltip:Hide();
			self.Description:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		end	
	else
		if ( warCampaignInfo.complete ) then
			self.Description:SetText(WAR_CAMPAIGN_DONE_DESCRIPTION);
		else
			self.Description:SetText(warCampaignInfo.playerConditionFailedReason);
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
