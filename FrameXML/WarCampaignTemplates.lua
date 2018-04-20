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
	local campaignChapterID = C_CampaignInfo.GetCurrentCampaignChapterID();

	if (campaignChapterID) then
		local campaignChapterInfo = C_CampaignInfo.GetCampaignChapterInfo(campaignChapterID);
		if (campaignChapterInfo) then
			self.ChapterTitle:SetText(campaignChapterInfo.name);
			self.Description:SetText(campaignChapterInfo.description);
			self.Description:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
			if ( GetNumQuestLogRewards(campaignChapterInfo.rewardQuestID) > 0 ) then
				if (not EmbeddedItemTooltip_SetItemByQuestReward(self.ItemTooltip, 1, campaignChapterInfo.rewardQuestID)) then
					self.ItemTooltip:Hide();
				end
			else
				if (QuestUtils_AddQuestCurrencyRewardsToTooltip(campaignChapterInfo.rewardQuestID, nil, self.ItemTooltip) == 0 ) then
					self.ItemTooltip:Hide();
				end
			end
		else
			self.ChapterTitle:SetText(warCampaignInfo.name);
			self.Description:SetText(warCampaignInfo.playerConditionFailedReason);
			self.ItemTooltip:Hide();
			self.Description:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		end	
	else
		self.ChapterTitle:SetText(nil);
		self.Description:SetText(warCampaignInfo.playerConditionFailedReason);
		self.ItemTooltip:Hide();
		self.Description:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
	end

	self:UpdateSize();
	self:Show();
end

function WarCampaignTooltipMixin:UpdateSize()
	local tooltipWidth = 0;
	local tooltipHeight = 20;
	local spacing = 12;
	local naturalTextWrapWidth = 250;

	local stringRegions = {
		"Title",
		"ChapterTitle",
		"Description",
	};

	if (self.ItemTooltip:IsShown()) then
		stringRegions[#stringRegions + 1] = "CompleteRewardText";
		self.CompleteRewardText:Show();
	else
		self.CompleteRewardText:Hide();
	end

	for i, region in ipairs(stringRegions) do
		region = self[region];
		if (region:IsShown() and region:GetText()) then
			local textWidth = region:GetStringWidth();
			local currStringWidth = min(region:GetWidth(), region:GetStringWidth());
			tooltipWidth = max(tooltipWidth, currStringWidth);
			tooltipHeight = tooltipHeight + region:GetHeight() + spacing;
		end
	end

	--Add some spacing
	tooltipWidth = tooltipWidth + 20;
	if (self.ItemTooltip:IsShown()) then
		tooltipWidth = max(tooltipWidth, self.ItemTooltip.Tooltip:GetWidth() + 54);
		tooltipHeight = tooltipHeight + self.ItemTooltip:GetHeight() + spacing + 2;
	end

	self:SetSize(tooltipWidth, tooltipHeight);
end
	