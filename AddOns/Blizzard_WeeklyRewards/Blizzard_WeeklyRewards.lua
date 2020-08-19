local NUM_COLUMNS = 3;
local SELECTION_STATE_HIDDEN = 1;
local SELECTION_STATE_UNSELECTED = 2;
local SELECTION_STATE_SELECTED = 3;

StaticPopupDialogs["CONFIRM_SELECT_WEEKLY_REWARD"] = {
	text = WEEKLY_REWARDS_CONFIRM_SELECT,
	button1 = YES,
	button2 = CANCEL,
	OnAccept = function(self)
		C_WeeklyRewards.ClaimReward(self.data);
		HideUIPanel(WeeklyRewardsFrame);
	end,
	timeout = 0,
	hideOnEscape = 1,
	showAlert = 1,
}

local WEEKLY_REWARDS_EVENTS = {
	"WEEKLY_REWARDS_HIDE",
	"WEEKLY_REWARDS_UPDATE",
	"CHALLENGE_MODE_COMPLETED",
	"CHALLENGE_MODE_MAPS_UPDATE",
};

WeeklyRewardsMixin = { };

function WeeklyRewardsMixin:OnLoad()
	NineSliceUtil.ApplyUniqueCornersLayout(self.NineSlice, "Oribos");
	UIPanelCloseButton_SetBorderAtlas(self.CloseButton, "UI-Frame-Oribos-ExitButtonBorder", -1, 1);

	self:SetUpActivity(self.RaidFrame, RAIDS, "weeklyrewards-background-raid", Enum.WeeklyRewardChestThresholdType.Raid);
	self:SetUpActivity(self.MythicFrame, MYTHIC_DUNGEONS, "weeklyrewards-background-mythic", Enum.WeeklyRewardChestThresholdType.MythicPlus);
	self:SetUpActivity(self.PVPFrame, PVP, "weeklyrewards-background-pvp", Enum.WeeklyRewardChestThresholdType.RankedPvP);

	local attributes = 
	{ 
		area = "center",
		pushable = 0,
		allowOtherPanels = 1,
	};
	RegisterUIPanel(WeeklyRewardsFrame, attributes);
end

function WeeklyRewardsMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, WEEKLY_REWARDS_EVENTS);
	
	-- for preview item tooltips
	C_MythicPlus.RequestMapInfo();

	self:Refresh();
end

function WeeklyRewardsMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, WEEKLY_REWARDS_EVENTS);
	self.selectedActivity = nil;
	C_WeeklyRewards.CloseInteraction();
	StaticPopup_Hide("CONFIRM_SELECT_WEEKLY_REWARD");
end

function WeeklyRewardsMixin:OnEvent(event)
	if event == "WEEKLY_REWARDS_HIDE" then
		HideUIPanel(self);
	elseif event == "WEEKLY_REWARDS_UPDATE" then
		self:Refresh();
	elseif event == "CHALLENGE_MODE_COMPLETED" then
		C_MythicPlus.RequestMapInfo();
	elseif event == "CHALLENGE_MODE_MAPS_UPDATE" then
		local tooltipOwner = GameTooltip:GetOwner();
		if tooltipOwner then
			for i = 1, NUM_COLUMNS do
				local frame = self:GetActivityFrame(Enum.WeeklyRewardChestThresholdType.MythicPlus, i);
				if frame == tooltipOwner and frame:CanShowPreviewItemTooltip() then
					frame:ShowPreviewItemTooltip();
					break;
				end
			end
		end
	end
end

function WeeklyRewardsMixin:SetUpActivity(activityTypeFrame, name, atlas, activityType)
	activityTypeFrame.Name:SetText(name);
	activityTypeFrame.Background:SetAtlas(atlas);

	local prevFrame;
	for i = 1, NUM_COLUMNS do
		local frame = CreateFrame("FRAME", nil, self, "WeeklyRewardActivityTemplate");
		if prevFrame then
			frame:SetPoint("LEFT", prevFrame, "RIGHT", 9, 0);
		else
			frame:SetPoint("LEFT", activityTypeFrame, "RIGHT", 56, 3);
		end
		frame.type = activityType;
		frame.index = i;
		prevFrame = frame;
	end
end

function WeeklyRewardsMixin:GetActivityFrame(activityType, index)
	for i, frame in ipairs(self.Activities) do
		if frame.type == activityType and frame.index == index then
			return frame;
		end
	end
end

function WeeklyRewardsMixin:Refresh()
	local canClaimRewards = C_WeeklyRewards.CanClaimRewards();
	if canClaimRewards then
		self.HeaderFrame.Text:SetText(WEEKLY_REWARDS_CHOOSE_REWARD);
	else
		self.HeaderFrame.Text:SetText(WEEKLY_REWARDS_ADD_ITEMS);
	end
	self.SelectRewardButton:SetShown(canClaimRewards);

	-- always hide concession, if there are rewards the refresh will show it
	self.ConcessionFrame:Hide();

	local activities = C_WeeklyRewards.GetActivities();
	for i, activityInfo in ipairs(activities) do
		local frame = self:GetActivityFrame(activityInfo.type, activityInfo.index);
		-- hide current progress for current week if rewards are present
		if canClaimRewards and #activityInfo.rewards == 0 then
			activityInfo.progress = 0;
		end
		frame:Refresh(activityInfo);
	end
	
	if self.ConcessionFrame:IsShown() then
		self:SetHeight(737);
	else
		self:SetHeight(657);
	end

	self:UpdateSelection();
end

function WeeklyRewardsMixin:SelectActivity(activityFrame)
	if activityFrame.hasRewards then
		if self.selectedActivity == activityFrame then
			self.selectedActivity = nil;
		else
			self.selectedActivity = activityFrame;
		end
		self:UpdateSelection();
		StaticPopup_Hide("CONFIRM_SELECT_WEEKLY_REWARD");
	end
end

function WeeklyRewardsMixin:UpdateSelection()
	local selectedActivity = self.selectedActivity;
	local useAtlasSize = true;
	self.SelectRewardButton:SetEnabled(selectedActivity ~= nil);

	for i, frame in ipairs(self.Activities) do
		local selectionState = SELECTION_STATE_HIDDEN;
		if selectedActivity and frame.hasRewards then
			if frame == selectedActivity then
				selectionState = SELECTION_STATE_SELECTED;
			else
				selectionState = SELECTION_STATE_UNSELECTED;
			end
		end
		frame:SetSelectionState(selectionState);
	end
end

function WeeklyRewardsMixin:GetSelectedActivityInfo()
	return self.selectedActivity and self.selectedActivity.info;
end

function WeeklyRewardsMixin:SelectReward()
	WeeklyRewardConfirmSelectionFrame:ShowPopup(self.selectedActivity:GetDisplayedItemDBID(), self:GetSelectedActivityInfo());
end

WeeklyRewardsActivityMixin = { };

function WeeklyRewardsActivityMixin:SetSelectionState(state)
	if state == SELECTION_STATE_SELECTED then
		self.SelectedTexture:Show();
		self.UnselectedFrame:Hide();
	elseif state == SELECTION_STATE_UNSELECTED then
		self.SelectedTexture:Hide();
		self.UnselectedFrame:Show();
	else
		self.SelectedTexture:Hide();
		self.UnselectedFrame:Hide();
	end
end

function WeeklyRewardsActivityMixin:Refresh(activityInfo)
	local thresholdString;
	if activityInfo.type == Enum.WeeklyRewardChestThresholdType.Raid then
		thresholdString = WEEKLY_REWARDS_THRESHOLD_RAID;
	elseif activityInfo.type == Enum.WeeklyRewardChestThresholdType.MythicPlus then
		thresholdString = WEEKLY_REWARDS_THRESHOLD_MYTHIC;
	elseif activityInfo.type == Enum.WeeklyRewardChestThresholdType.RankedPvP then
		thresholdString = WEEKLY_REWARDS_THRESHOLD_PVP;
	end
	self.Threshold:SetFormattedText(thresholdString, activityInfo.threshold);

	self.unlocked = activityInfo.progress >= activityInfo.threshold;
	self.hasRewards = #activityInfo.rewards > 0;
	self.info = activityInfo;

	self:SetProgressText(activityInfo);

	local useAtlasSize = true;

	if self.unlocked or self.hasRewards then
		self.Background:SetAtlas("weeklyrewards-background-reward-unlocked", useAtlasSize);
		self.Border:SetAtlas("weeklyrewards-frame-reward-unlocked", useAtlasSize);
		self.Threshold:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		self.Progress:SetTextColor(GREEN_FONT_COLOR:GetRGB());
		self.LockIcon:Show();
		self.LockIcon:SetAtlas("weeklyrewards-icon-unlocked", useAtlasSize);
		self.ItemFrame:Hide();
		if self.hasRewards then
			self.Orb:SetTexture(nil);
			self.ItemFrame:SetRewards(activityInfo.rewards);
			self.ItemGlow:Show();
		else
			self.Orb:SetAtlas("weeklyrewards-orb-unlocked", useAtlasSize);
			self.ItemGlow:Hide();
		end
	else
		self.Orb:SetAtlas("weeklyrewards-orb-locked", useAtlasSize);
		self.Background:SetAtlas("weeklyrewards-background-reward-locked", useAtlasSize);
		self.Border:SetAtlas("weeklyrewards-frame-reward-locked", useAtlasSize);
		self.Threshold:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		self.Progress:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		self.LockIcon:Hide();
		self.ItemFrame:Hide();
		self.ItemGlow:Hide();
	end
end

function WeeklyRewardsActivityMixin:SetProgressText()
	local activityInfo = self.info;
	if self.hasRewards then
		self.Progress:SetText(nil);	
	elseif self.unlocked then
		if activityInfo.type == Enum.WeeklyRewardChestThresholdType.Raid then
			local name = GetDifficultyInfo(activityInfo.level);
			self.Progress:SetText(name);
		elseif activityInfo.type == Enum.WeeklyRewardChestThresholdType.MythicPlus then
			self.Progress:SetFormattedText(WEEKLY_REWARDS_MYTHIC, activityInfo.level);
		elseif activityInfo.type == Enum.WeeklyRewardChestThresholdType.RankedPvP then
			self.Progress:SetText(PVPUtil.GetTierName(activityInfo.level));
		end
	else
		self.Progress:SetFormattedText(GENERIC_FRACTION_STRING, activityInfo.progress, activityInfo.threshold);
	end
end

function WeeklyRewardsActivityMixin:OnMouseDown()
	self:GetParent():SelectActivity(self);
end

function WeeklyRewardsActivityMixin:CanShowPreviewItemTooltip()
	return self.unlocked and not C_WeeklyRewards.CanClaimRewards();
end

function WeeklyRewardsActivityMixin:OnEnter()
	if self:CanShowPreviewItemTooltip() then
		self:ShowPreviewItemTooltip();		
	end
end

function WeeklyRewardsActivityMixin:ShowPreviewItemTooltip()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -7, -11);
	GameTooltip_SetTitle(GameTooltip, WEEKLY_REWARDS_CURRENT_REWARD);
	local itemLink, upgradeItemLink = C_WeeklyRewards.GetExampleRewardItemHyperlinks(self.info.id);
	local itemLevel, upgradeItemLevel;
	if itemLink then
		itemLevel = GetDetailedItemLevelInfo(itemLink);
	end
	if upgradeItemLink then
		upgradeItemLevel = GetDetailedItemLevelInfo(upgradeItemLink);
	end
	if not itemLevel then
		GameTooltip_AddErrorLine(GameTooltip, RETRIEVING_ITEM_INFO);
		self.UpdateTooltip = self.ShowPreviewItemTooltip;
	else
		self.UpdateTooltip = nil;
		if self.info.type == Enum.WeeklyRewardChestThresholdType.Raid then
			self:HandlePreviewRaidRewardTooltip(itemLevel, upgradeItemLevel);
		elseif self.info.type == Enum.WeeklyRewardChestThresholdType.MythicPlus then
			self:HandlePreviewMythicRewardTooltip(itemLevel, upgradeItemLevel);
		elseif self.info.type == Enum.WeeklyRewardChestThresholdType.RankedPvP then
			self:HandlePreviewPvPRewardTooltip(itemLevel, upgradeItemLevel);
		end
		if not upgradeItemLevel then
			GameTooltip_AddColoredLine(GameTooltip, WEEKLY_REWARDS_MAXED_REWARD, GREEN_FONT_COLOR);
		end
	end
	GameTooltip:Show();
end

function WeeklyRewardsActivityMixin:HandlePreviewRaidRewardTooltip(itemLevel, upgradeItemLevel)
	local currentDifficultyID = self.info.level;
	local currentDifficultyName = GetDifficultyInfo(currentDifficultyID);
	GameTooltip_AddNormalLine(GameTooltip, string.format(WEEKLY_REWARDS_ITEM_LEVEL_RAID, itemLevel, currentDifficultyName));
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	if upgradeItemLevel then
		local targetIndex;
		-- looking for the next difficulty after current one
		for i, difficultyID in ipairs(DIFFICULTY_PRIMARYRAIDS) do
			if i == targetIndex then
				local difficultyName = GetDifficultyInfo(difficultyID);
				GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_IMPROVE_ITEM_LEVEL, upgradeItemLevel), GREEN_FONT_COLOR);
				GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_RAID, difficultyName));
				break;
			elseif currentDifficultyID == difficultyID then
				targetIndex = i + 1;
			end
		end
	end
end

function WeeklyRewardsActivityMixin:HandlePreviewMythicRewardTooltip(itemLevel, upgradeItemLevel)
	GameTooltip_AddNormalLine(GameTooltip, string.format(WEEKLY_REWARDS_ITEM_LEVEL_MYTHIC, itemLevel, self.info.level));
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	if upgradeItemLevel then
		GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_IMPROVE_ITEM_LEVEL, upgradeItemLevel), GREEN_FONT_COLOR);
		if self.info.threshold == 1 then
			GameTooltip_AddHighlightLine(GameTooltip, WEEKLY_REWARDS_COMPLETE_MYTHIC_SHORT);
		else
			GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_MYTHIC, self.info.level + 1, self.info.threshold));
			local runHistory = C_MythicPlus.GetRunHistory();
			if #runHistory > 0 then
				GameTooltip_AddBlankLineToTooltip(GameTooltip);
				GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_MYTHIC_TOP_RUNS, self.info.threshold));			
				local comparison = function(entry1, entry2)
					if ( entry1.level == entry2.level ) then
						return entry1.mapChallengeModeID < entry2.mapChallengeModeID;
					else
						return entry1.level > entry2.level;
					end
				end
				table.sort(runHistory, comparison);
				for i = 1, self.info.threshold do
					local runInfo = runHistory[i];
					local name = C_ChallengeMode.GetMapUIInfo(runInfo.mapChallengeModeID);
					GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_MYTHIC_RUN_INFO, runInfo.level, name));
				end
			end
		end
	end
end

function WeeklyRewardsActivityMixin:HandlePreviewPvPRewardTooltip(itemLevel, upgradeItemLevel)
	local tierName = PVPUtil.GetTierName(self.info.level);
	GameTooltip_AddNormalLine(GameTooltip, string.format(WEEKLY_REWARDS_ITEM_LEVEL_PVP, itemLevel, tierName));
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	if upgradeItemLevel then
		-- All brackets have the same breakpoints, use the first one
		local tierID = C_PvP.GetPvpTierID(self.info.level, CONQUEST_BRACKET_INDEXES[1]);
		local tierInfo = C_PvP.GetPvpTierInfo(tierID);
		local ascendTierInfo = C_PvP.GetPvpTierInfo(tierInfo.ascendTier);
		if ascendTierInfo then
			GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_IMPROVE_ITEM_LEVEL, upgradeItemLevel), GREEN_FONT_COLOR);
			local ascendTierName = PVPUtil.GetTierName(ascendTierInfo.pvpTierEnum);
			GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_PVP, ascendTierName, tierInfo.ascendRating, ascendTierInfo.ascendRating - 1));
		end
	end
end

function WeeklyRewardsActivityMixin:OnLeave()
	self.UpdateTooltip = nil;
	GameTooltip:Hide();
end

function WeeklyRewardsActivityMixin:GetDisplayedItemDBID()
	return self.ItemFrame.displayedItemDBID;
end

WeeklyRewardActivityItemMixin = { };

function WeeklyRewardActivityItemMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -3, -6);
	GameTooltip:SetWeeklyReward(self.displayedItemDBID);
	self:SetScript("OnUpdate", self.OnUpdate);
end

function WeeklyRewardActivityItemMixin:OnLeave()
	GameTooltip:Hide();
	self:SetScript("OnUpdate", nil);
end

function WeeklyRewardActivityItemMixin:OnUpdate()
	if IsModifiedClick("COMPAREITEMS") or GetCVarBool("alwaysCompareItems") then
		GameTooltip_ShowCompareItem(GameTooltip);
	else
		GameTooltip_HideShoppingTooltips(GameTooltip);
	end
end

function WeeklyRewardActivityItemMixin:OnClick()
	local activityFrame = self:GetParent();
	if IsModifiedClick() then
		local hyperlink = C_WeeklyRewards.GetItemHyperlink(self.displayedItemDBID);
		HandleModifiedItemClick(hyperlink);
	else
		activityFrame:GetParent():SelectActivity(activityFrame);
	end
end

function WeeklyRewardActivityItemMixin:SetDisplayedItem()
	self.displayedItemDBID = nil;
	local bestItemQuality = 0;
	local bestItemLevel = 0;
	for i, rewardInfo in ipairs(self:GetParent().info.rewards) do
		if rewardInfo.type == Enum.CachedRewardType.Item then
			local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon = GetItemInfo(rewardInfo.id);
			if itemEquipLoc ~= "" then
				-- want highest item level of highest quality
				-- this comparison is not really needed now since the rewards are 1 equippable and 1 non-equippable item
				if itemQuality > bestItemQuality or (itemQuality == bestItemQuality and itemLevel > bestItemLevel) then
					self.displayedItemDBID = rewardInfo.itemDBID;
					self.Name:SetText(itemName);
					self.Icon:SetTexture(itemIcon);
					SetItemButtonOverlay(self, C_WeeklyRewards.GetItemHyperlink(rewardInfo.itemDBID));
				end
			end
		end
	end

	self:SetShown(self.displayedItemDBID ~= nil);
end

function WeeklyRewardActivityItemMixin:SetRewards(rewards)
	local continuableContainer = ContinuableContainer:Create();
	for i, rewardInfo in ipairs(rewards) do
		if rewardInfo.type == Enum.CachedRewardType.Item then
			local item = Item:CreateFromItemID(rewardInfo.id);
			continuableContainer:AddContinuable(item);
		end
	end

	continuableContainer:ContinueOnLoad(function()
		self:SetDisplayedItem();
	end);
end

WeeklyRewardsConcessionMixin = { };

function WeeklyRewardsConcessionMixin:OnLoad()
	self.RewardsFrame:CreateLabel(WEEKLY_REWARDS_GET_CONCESSION, NORMAL_FONT_COLOR, "GameFontHighlight", 2);
end

function WeeklyRewardsConcessionMixin:SetSelectionState(state)
	if state == SELECTION_STATE_SELECTED then
		self.SelectedTexture:Show();
		self.UnselectedFrame:Hide();
	elseif state == SELECTION_STATE_UNSELECTED then
		self.SelectedTexture:Hide();
		self.UnselectedFrame:Show();
	else
		self.SelectedTexture:Hide();
		self.UnselectedFrame:Hide();
	end
end

function WeeklyRewardsConcessionMixin:Refresh(activityInfo)
	-- only supports currencies
	self.RewardsFrame:Clear();
	local currencyAdded = false;
	for i, rewardInfo in ipairs(activityInfo.rewards) do
		if rewardInfo.type == Enum.CachedRewardType.Currency then
			self.RewardsFrame:AddCurrency(rewardInfo.id, rewardInfo.quantity);
			currencyAdded = true;
		end
	end

	if currencyAdded then
		self.RewardsFrame:Layout();
		self.info = activityInfo;
		self:Show();
	end
end

function WeeklyRewardsConcessionMixin:OnMouseDown()
	self:GetParent():SelectActivity(self);
end

function WeeklyRewardsConcessionMixin:GetDisplayedItemDBID()
	-- this only displays currencies
	return nil;
end

WeeklyRewardConfirmSelectionMixin = { }

function WeeklyRewardConfirmSelectionMixin:OnEvent(event, ...)
	self:RefreshRewards();
end

function WeeklyRewardConfirmSelectionMixin:ShowPopup(itemDBID, activityInfo)
	self.itemDBID = itemDBID;
	self.activityInfo = activityInfo;
	self:RefreshRewards();
	StaticPopup_Show("CONFIRM_SELECT_WEEKLY_REWARD", nil, nil, activityInfo.id, self);
end

function WeeklyRewardConfirmSelectionMixin:RefreshRewards()
	local heightUsed = 19;
	local itemFrame = self.ItemFrame;
	local currencyFrame = self.CurrencyFrame;
	local hasMissingData = false;
	if self.itemDBID then
		local itemHyperlink = C_WeeklyRewards.GetItemHyperlink(self.itemDBID);
		local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon = GetItemInfo(itemHyperlink);
		itemFrame.Icon:SetTexture(itemIcon or QUESTION_MARK_ICON);
		local r, g, b = GetItemQualityColor(itemQuality or Enum.ItemQuality.Common);
		SetItemButtonQuality(itemFrame, itemQuality, itemHyperlink);
		if itemName and itemQuality then
			itemFrame.Name:SetText(itemName);
			itemFrame.Name:SetTextColor(r, g, b);
		else
			itemFrame.Name:SetText(RETRIEVING_ITEM_INFO);
			itemFrame.Name:SetTextColor(RED_FONT_COLOR:GetRGB());
			hasMissingData = true;
		end
		itemFrame.itemHyperlink = itemHyperlink;
		itemFrame:Show();
		currencyFrame:Hide();
		heightUsed = heightUsed + itemFrame:GetHeight();
	else
		currencyFrame:Clear();
		for i, rewardInfo in ipairs(self.activityInfo.rewards) do
			if rewardInfo.type == Enum.CachedRewardType.Currency then
				currencyFrame:AddCurrency(rewardInfo.id, rewardInfo.quantity);
			end
		end
		currencyFrame:Layout();
		currencyFrame:Show();
		itemFrame:Hide();
		heightUsed = heightUsed + currencyFrame:GetHeight();
	end

	-- display items that are not the primary reward
	local alsoItemsFrame = self.AlsoItemsFrame;
	if #self.activityInfo.rewards > 1 then
		if alsoItemsFrame.pool then
			alsoItemsFrame.pool:ReleaseAll();
		else
			alsoItemsFrame.pool = CreateFramePool("FRAME", alsoItemsFrame, "WeeklyRewardAlsoItemTemplate");
		end
		for i, rewardInfo in ipairs(self.activityInfo.rewards) do
			if rewardInfo.itemDBID and rewardInfo.itemDBID ~= self.itemDBID then
				local frame = alsoItemsFrame.pool:Acquire();
				local itemHyperlink = C_WeeklyRewards.GetItemHyperlink(rewardInfo.itemDBID);
				local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon = GetItemInfo(itemHyperlink);
				if not itemIcon or not itemQuality then
					hasMissingData = true;
				end
				frame.Icon:SetTexture(itemIcon or QUESTION_MARK_ICON);
				local r, g, b = GetItemQualityColor(itemQuality or Enum.ItemQuality.Common);
				frame.IconBorder:SetVertexColor(r, g, b);
				frame.layoutIndex = i;
				frame.itemHyperlink = itemHyperlink;
				frame:Show();
			end
		end
		alsoItemsFrame:Layout();
		alsoItemsFrame:Show();
		heightUsed = heightUsed + 38;
	else
		alsoItemsFrame:Hide();
	end

	if hasMissingData then
		self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
	else
		self:UnregisterEvent("GET_ITEM_INFO_RECEIVED");
	end
	self:SetHeight(heightUsed);
end