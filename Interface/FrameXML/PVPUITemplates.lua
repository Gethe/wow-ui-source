PVPConquestRewardMixin = { };
function PVPConquestRewardMixin:Setup()
	local weeklyProgress = C_WeeklyRewards.GetConquestWeeklyProgress();
	local progress = weeklyProgress.progress;
	local maxProgress = weeklyProgress.maxProgress;
	local displayType = weeklyProgress.displayType;

	if progress < maxProgress then
		if displayType == Enum.ConquestProgressBarDisplayType.Seasonal then
			self:SetTexture("Interface\\icons\\achievement_legionpvp2tier3", 1);
		else
			self:SetTexture("Interface\\icons\\Inv_trinket_oribos_01_silver", 1);
		end
		self.CheckMark:Hide();
		self.Ring:SetDesaturated(false);
	else
		self:SetTexture("Interface\\icons\\achievement_legionpvp2tier3", 0.2);
		self.CheckMark:Show();
		self.CheckMark:SetDesaturated(true);
		self.Ring:SetDesaturated(true);
	end
end

function PVPConquestRewardMixin:Clear()
	self:SetTexture(nil, 1);
	self.questID = nil;
	self.CheckMark:Hide();
end

function PVPConquestRewardMixin:SetTexture(texture, alpha)
	if texture then
		self.Icon:SetTexture(texture);
	else
		self.Icon:SetColorTexture(0, 0, 0);
	end
	self.Icon:SetAlpha(alpha);
end

function PVPConquestRewardMixin:SetTooltipAnchor(questTooltipAnchor)
	self.questTooltipAnchor = questTooltipAnchor;
end

function PVPConquestRewardMixin:TryShowTooltip()
	GameTooltip_SetTitle(EmbeddedItemTooltip, PVP_CONQUEST, HIGHLIGHT_FONT_COLOR);
	EmbeddedItemTooltip:SetOwner(self, "ANCHOR_RIGHT");

	if not ConquestFrame_HasActiveSeason() then
		GameTooltip_AddColoredLine(EmbeddedItemTooltip, CONQUEST_REQUIRES_PVP_SEASON, NORMAL_FONT_COLOR);
	else
		GameTooltip_SetTitle(EmbeddedItemTooltip, PVP_CONQUEST, HIGHLIGHT_FONT_COLOR);

		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CONQUEST_CURRENCY_ID);
		local maxProgress = currencyInfo.maxQuantity;
		local progress = math.min(currencyInfo.totalEarned, maxProgress);

		-- these string names are not accurate because their contents were changed, but they were not renamed
		local message = CONQUEST_PVP_WEEK_NO_CONQUEST; 
		if progress == maxProgress then
			message = CONQUEST_PVP_WEEK_CONQUEST_COMPLETE;
		end
		GameTooltip_AddColoredLine(EmbeddedItemTooltip, message, NORMAL_FONT_COLOR);
	end
	EmbeddedItemTooltip:Show();
end

function PVPConquestRewardMixin:HideTooltip()
	EmbeddedItemTooltip:Hide();
	self.UpdateTooltip = nil;
end

function PVPConquestRewardMixin:OnEnter()
	self:TryShowTooltip();
end

function PVPConquestRewardMixin:OnLeave()
	ResetCursor();
	self:HideTooltip();
end

function PVPConquestRewardMixin:OnClick()
	if self.questID and self.questID > 0 and IsModifiedClick() then
		local itemIndex, rewardType = QuestUtils_GetBestQualityItemRewardIndex(self.questID);
		HandleModifiedItemClick(GetQuestLogItemLink(rewardType, itemIndex, self.questID));
	end
end

PVPHonorRewardMixin = {};
function PVPHonorRewardMixin:OnEnter()
	local honorLevel = UnitHonorLevel("player");
	local nextHonorLevelForReward = C_PvP.GetNextHonorLevelForReward(honorLevel);
	local rewardInfo = nextHonorLevelForReward and C_PvP.GetHonorRewardInfo(nextHonorLevelForReward);
	if rewardInfo then
		local rewardText = select(11, GetAchievementInfo(rewardInfo.achievementRewardedID));
		if rewardText and rewardText ~= "" then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -4, -4);
			GameTooltip:SetText(PVP_PRESTIGE_RANK_UP_NEXT_MAX_LEVEL_REWARD:format(nextHonorLevelForReward));
			local WRAP = true;
			GameTooltip_AddColoredLine(GameTooltip, rewardText, HIGHLIGHT_FONT_COLOR, WRAP);
			GameTooltip:Show();
		end
	end
end
function PVPHonorRewardMixin:OnLeave()
	GameTooltip_Hide();
end
function PVPHonorRewardMixin:Update()
	local honorLevel = UnitHonorLevel("player");
	local nextHonorLevelForReward = C_PvP.GetNextHonorLevelForReward(honorLevel);
	if not nextHonorLevelForReward then
		self.LevelLabel:SetText("");
		self.RingBorder:SetAtlas("pvpqueue-rewardring-black");
	else
		local nextRewardInfo = C_PvP.GetHonorRewardInfo(nextHonorLevelForReward);
		if nextRewardInfo then
			local iconTexture = select(10, GetAchievementInfo(nextRewardInfo.achievementRewardedID));
			if iconTexture then
				self.RewardIcon:SetTexture(iconTexture);
			else
				self.RewardIcon:SetColorTexture(0, 0, 0);
			end
			-- light up the reward if it's at the end of this level
			if honorLevel + 1 == nextHonorLevelForReward then
				self.RingBorder:SetAtlas("pvpqueue-rewardring");
				self.LevelLabel:SetText("");
				self.RewardIcon:SetDesaturated(false);
				self.IconCover:Hide();
			else
				self.RingBorder:SetAtlas("pvpqueue-rewardring-black");
				self.LevelLabel:SetText(nextHonorLevelForReward);
				self.RewardIcon:SetDesaturated(true);
				self.IconCover:Show();
			end
		end
	end
end

function PVPGetConquestLevelInfo()
	local CONQUEST_QUESTLINE_ID = 782;
	local currentQuestID = QuestUtils_GetCurrentQuestLineQuest(CONQUEST_QUESTLINE_ID);

	-- if not on a current quest that means all caught up for this week
	if currentQuestID == 0 then
		return 0, 0, 0;
	end

	if not HaveQuestData(currentQuestID) then
		return 0, 0, nil;
	end

	local objectives = C_QuestLog.GetQuestObjectives(currentQuestID);
	if not objectives or not objectives[1] then
		return 0, 0, nil;
	end

	return objectives[1].numFulfilled, objectives[1].numRequired, currentQuestID;
end

PVPRatedTierMixin = {};
function PVPRatedTierMixin:Setup(tierInfo, ranking)
	if tierInfo then
		self.Icon:SetTexture(tierInfo.tierIconID);
		self:Show();
		if ranking then
			self.RankingShadow:Show();
			self.Ranking:SetText(ranking);
		else
			self.RankingShadow:Hide();
			self.Ranking:SetText();
		end
	else
		self:Hide();
	end

	self.tierInfo = tierInfo;
end

PVPLootMixin = CreateFromMixins(LootItemExtendedMixin);
function PVPLootMixin:Init(itemLink, quantity, specID, isCurrency, isUpgraded, isIconBorderShown, isIconBorderDropShadowShown, iconDrawLayer)
	LootItemExtendedMixin.Init(self, itemLink, quantity, specID, isCurrency, isUpgraded, isIconBorderShown, isIconBorderDropShadowShown, iconDrawLayer);

	self.link = itemLink;
end
function PVPLootMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetHyperlink(self.link);
	GameTooltip:Show();
end
function PVPLootMixin:OnLeave()
	GameTooltip:Hide();
end