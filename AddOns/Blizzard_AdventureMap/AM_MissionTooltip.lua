AdventureMap_MissionTooltipMixin = {};

function AdventureMap_MissionTooltipMixin:SetMissionInfo(missionInfo)
	self:AddName(missionInfo);
	self:AddRarity(missionInfo)
	self:AddBasicInfo(missionInfo);
	self:AddRewards(missionInfo);
	self:AddBonusEffects(missionInfo);
	self:AddFollowers(missionInfo);

	self:UpdateTooltipSize();

	self:Show();

	if missionInfo.inProgress and missionInfo.missionEndTime - GetServerTime() > 0 then
		self.missionInfo = missionInfo;
		self.timeUntilRefresh = .5;
	end
end

function AdventureMap_MissionTooltipMixin:OnHide()
	self.missionInfo = nil;
end

function AdventureMap_MissionTooltipMixin:OnUpdate(elapsed)
	if self.missionInfo then
		self.timeUntilRefresh = self.timeUntilRefresh - elapsed;
		if self.timeUntilRefresh <= 0 then
			self:SetMissionInfo(self.missionInfo);
		end
	end
end

function AdventureMap_MissionTooltipMixin:AddName(missionInfo)
	self.Name:SetText(missionInfo.name);
	self:AddWidget(self.Name);
end

function AdventureMap_MissionTooltipMixin:AddRarity(missionInfo)
	if missionInfo.isRare then
		self:AnchorToPrevious(self.RareMission, 0, -self.RareMission.yspacing);
		self:AddWidget(self.RareMission);
		self.RareMission:Show();
	else
		self.RareMission:Hide();
	end
end

function AdventureMap_MissionTooltipMixin:AddBonusEffects(missionInfo)
	local bonusEffects = C_Garrison.GetMissionBonusAbilityEffects(missionInfo.missionID);
	if bonusEffects then
		--TODO do we care about bonus effects?
	end
end

function AdventureMap_MissionTooltipMixin:AddThreats(missionInfo)
	-- TODO Do we care about threats?
end

function AdventureMap_MissionTooltipMixin:AddBasicInfo(missionInfo)
	if missionInfo.inProgress then
		if missionInfo.isComplete then
			self.InProgress:SetText(COMPLETE);
		else
			self.InProgress:SetText(GARRISON_MISSION_IN_PROGRESS_TOOLTIP);
		end

		self.InProgress:Show();

		self:AnchorToPrevious(self.InProgress, 0, -self.InProgress.yspacing);
		self:AddWidget(self.InProgress);

		if missionInfo.isComplete then
			self.InProgressTimeLeft:Hide();
		else
			local timeLeftSec = missionInfo.missionEndTime - GetServerTime();
			if timeLeftSec > 0 then
				self.InProgressTimeLeft:SetText(SecondsToTime(timeLeftSec, false, false, 1));
			else
				self.InProgressTimeLeft:SetText(SECONDS_ABBR:format(0));
			end

			self:AddWidget(self.InProgressTimeLeft);
			self.InProgressTimeLeft:Show();
		end

		self.Description:Hide();
		self.NumFollowers:Hide();
		self.MissionDuration:Hide();
		self.MissionExpires:Hide();
		self.TimeRemaining:Hide();
	else
		self.InProgress:Hide();
		self.InProgressTimeLeft:Hide();

		self.Description:Show();
		self.NumFollowers:Show();
		self.MissionDuration:Show();

		self:AnchorToPrevious(self.Description, 0, -self.Description.yspacing);
		self.Description:SetText(missionInfo.description);
		
		self.NumFollowers:SetText(GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS:format(missionInfo.numFollowers));
		
		local timeString = NORMAL_FONT_COLOR_CODE .. TIME_LABEL .. FONT_COLOR_CODE_CLOSE .. " ";
		timeString = timeString .. HIGHLIGHT_FONT_COLOR_CODE .. missionInfo.duration .. FONT_COLOR_CODE_CLOSE;
		self.MissionDuration:SetText(timeString);
		self:AddWidget(self.MissionDuration);
		
		self:AddThreats(missionInfo);
		
		if missionInfo.isRare then
			self:AnchorToPrevious(self.MissionExpires, 0, -self.MissionExpires.yspacing);
			self.MissionExpires:Show();
			self.TimeRemaining:SetText(missionInfo.offerTimeRemaining);
			self.TimeRemaining:Show();
			self:AddWidget(self.TimeRemaining);
		else
			self.MissionExpires:Hide();
			self.TimeRemaining:Hide()
		end
	end
end

function AdventureMap_MissionTooltipMixin:AddFollowers(missionInfo)
	self.FollowersHeader:Hide();

	for i, followerName in ipairs(self.FollowerNames) do
		followerName:Hide();
	end

	if missionInfo.inProgress then
		if missionInfo.followers then
			self:AnchorToPrevious(self.FollowersHeader, 0, -self.FollowersHeader.yspacing);
			self.FollowersHeader:Show();

			for i=1, #missionInfo.followers do
				self.FollowerNames[i]:SetText(C_Garrison.GetFollowerName(missionInfo.followers[i]));
				self.FollowerNames[i]:Show();
				self:AddWidget(self.FollowerNames[i]);
			end
		end
	end
end

function AdventureMap_MissionTooltipMixin:AddRewards(missionInfo)
	self.ItemTooltip:Hide();
	self.Reward:Hide();
	self.RewardHeader:Hide();

	if not next(missionInfo.rewards) then
		return;
	end

	self.RewardHeader:Show();

	self:AnchorToPrevious(self.RewardHeader, 0, -self.RewardHeader.yspacing);
	self:AddWidget(self.RewardHeader);
	
	for id, reward in pairs(missionInfo.rewards) do
		if reward.bonusAbilityID then
			-- TODO: Add Icon and Description (see shipyard version)
			self.Reward:SetText(reward.name);
			self.Reward:Show();
			self:AddWidget(self.Reward);
		elseif reward.itemID then
			EmbeddedItemTooltip_SetItemByID(self.ItemTooltip, reward.itemID);
			self:AddWidget(self.ItemTooltip, -6, 0);
		elseif reward.followerXP then
			self.Reward:SetText(format(GARRISON_REWARD_XP_FORMAT, BreakUpLargeNumbers(reward.followerXP)));
			self.Reward:Show();
			self:AddWidget(self.Reward);
		elseif reward.currencyID ~= 0 then
			local currencyTexture = C_CurrencyInfo.GetCurrencyInfo(reward.currencyID).iconFileID;
			self.Reward:SetText(reward.quantity .. " |T" .. currencyTexture .. ":0:0:0:0|t");
			self.Reward:Show();
			self:AddWidget(self.Reward);
		elseif reward.currencyID == 0 then
			self.Reward:SetText(GetMoneyString(reward.quantity));
			self.Reward:Show();
			self:AddWidget(self.Reward);
		end
		break;
	end
end

function AdventureMap_MissionTooltipMixin:UpdateTooltipSize()
	local tooltipWidth = 0;

	if self.ItemTooltip:IsShown() then
		tooltipWidth = math.max(tooltipWidth,  self.ItemTooltip.Tooltip:GetWidth() + 54);
	end

	local WRAP_WIDTH = 250;
	if tooltipWidth < WRAP_WIDTH then
		local maxTextWidth = 0;

		for i, followerName in ipairs(self.FollowerNames) do
			if followerName:IsShown() then
				maxTextWidth = math.max(maxTextWidth, followerName:GetStringWidth() + 20);
			end
		end
		for i, line in ipairs(self.Lines) do
			if line:IsShown() then
				maxTextWidth = math.max(maxTextWidth, line:GetStringWidth() + 20);
			end
		end
	
		maxTextWidth = math.min(maxTextWidth, WRAP_WIDTH);
		tooltipWidth = math.max(maxTextWidth, tooltipWidth);
	end

	self:SetTooltipWidth(tooltipWidth);


	local tooltipHeight = 10;
	for i, followerName in ipairs(self.FollowerNames) do
		if followerName:IsShown() then
			tooltipHeight = tooltipHeight + self.FollowerNames[i]:GetHeight() + self.FollowerNames[i].yspacing;
		end
	end

	for i, line in ipairs(self.Lines) do
		if line:IsShown() then
			tooltipHeight = tooltipHeight + line:GetHeight() + line.yspacing;
		end
	end

	if self.ItemTooltip:IsShown() then
		tooltipHeight = tooltipHeight + self.ItemTooltip:GetHeight() + self.ItemTooltip.yspacing;
	end

	self:SetHeight(tooltipHeight);
end

function AdventureMap_MissionTooltipMixin:SetTooltipWidth(width)
	self:SetWidth(width);

	for i, followerName in ipairs(self.FollowerNames) do
		followerName:SetWidth(width - 20);
	end

	for i, line in ipairs(self.Lines) do
		line:SetWidth(width - 20);
	end
end

function AdventureMap_MissionTooltipMixin:AddWidget(widget, x, y)
	self.bottomWidget = widget;
	self.bottomX = x or 0;
	self.bottomY = y or 0;
end

function AdventureMap_MissionTooltipMixin:AnchorToPrevious(widget, x, y)
	widget:SetPoint("TOPLEFT", self.bottomWidget, "BOTTOMLEFT", self.bottomX + x, self.bottomY + y);
end