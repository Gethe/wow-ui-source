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
	self:RegisterEvent("WEEKLY_REWARDS_HIDE");
	self:RegisterEvent("WEEKLY_REWARDS_UPDATE");
	
	self:Refresh();
end

function WeeklyRewardsMixin:OnHide()
	self:UnregisterEvent("WEEKLY_REWARDS_HIDE");
	self:UnregisterEvent("WEEKLY_REWARDS_UPDATE");
	self.selectedActivity = nil;
	C_WeeklyRewards.CloseInteraction();
	StaticPopup_Hide("CONFIRM_SELECT_WEEKLY_REWARD");
end

function WeeklyRewardsMixin:OnEvent(event)
	if event == "WEEKLY_REWARDS_HIDE" then
		HideUIPanel(self);
	elseif event == "WEEKLY_REWARDS_UPDATE" then
		self:Refresh();
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
	local selectionFrame = WeeklyRewardConfirmSelectionFrame;
	local itemFrame = selectionFrame.ItemFrame;
	local currencyFrame = selectionFrame.CurrencyFrame;
	local activityInfo = self:GetSelectedActivityInfo();
	local heightUsed = 19;

	local itemDBID = self.selectedActivity:GetDisplayedItemDBID();
	if itemDBID then
		local itemHyperlink = C_WeeklyRewards.GetItemHyperlink(itemDBID);
		local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon = GetItemInfo(itemHyperlink);
		local r, g, b = GetItemQualityColor(itemQuality);
		itemFrame.Icon:SetTexture(itemIcon);
		itemFrame.Name:SetText(itemName);
		itemFrame.Name:SetTextColor(r, g, b);
		itemFrame.itemHyperlink = itemHyperlink;
		SetItemButtonQuality(itemFrame, itemQuality, itemHyperlink);
		itemFrame:Show();
		currencyFrame:Hide();
		heightUsed = heightUsed + itemFrame:GetHeight();
	else
		currencyFrame:Clear();
		for i, rewardInfo in ipairs(activityInfo.rewards) do
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
	local alsoItemsFrame = selectionFrame.AlsoItemsFrame;
	if #activityInfo.rewards > 1 then
		if alsoItemsFrame.pool then
			alsoItemsFrame.pool:ReleaseAll();
		else
			alsoItemsFrame.pool = CreateFramePool("FRAME", alsoItemsFrame, "WeeklyRewardAlsoItemTemplate");
		end
		for i, rewardInfo in ipairs(activityInfo.rewards) do
			if rewardInfo.itemDBID and rewardInfo.itemDBID ~= itemDBID then
				local frame = alsoItemsFrame.pool:Acquire();
				local itemHyperlink = C_WeeklyRewards.GetItemHyperlink(rewardInfo.itemDBID);
				local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon = GetItemInfo(itemHyperlink);
				local r, g, b = GetItemQualityColor(itemQuality);
				frame.Icon:SetTexture(itemIcon);
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

	selectionFrame:SetHeight(heightUsed);
	StaticPopup_Show("CONFIRM_SELECT_WEEKLY_REWARD", nil, nil, activityInfo.id, selectionFrame);
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
		if self.hasRewards then
			self.Orb:SetTexture(nil);
			self.ItemFrame:SetRewards(activityInfo.rewards);
			self.ItemGlow:Show();
		else
			self.Orb:SetAtlas("weeklyrewards-orb-unlocked", useAtlasSize);
			self.ItemFrame:Hide();
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

function WeeklyRewardsActivityMixin:OnEnter()
	if not C_WeeklyRewards.CanClaimRewards() then
		-- TODO: Tooltip for item preview
		--GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -7, -11);
	end
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