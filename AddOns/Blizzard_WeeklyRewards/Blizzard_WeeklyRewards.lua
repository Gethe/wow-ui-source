local MYTHIC_DUNGEONS = "Mythic Dungeons"
local WEEKLY_REWARDS_THRESHOLD_RAID = "Defeat %d Raid |4Boss:Bosses";
local WEEKLY_REWARDS_THRESHOLD_MYTHIC = "Complete %d Mythic |4Dungeon:Dungeons";
local WEEKLY_REWARDS_THRESHOLD_PVP = "Earn %d Conquest Points";
local CONFIRM_SELECT_WEEKLY_REWARD = "You will be unable to change this reward once it is selected.|n|nAre you sure you wish to select this item?"
WEEKLY_REWARDS_SELECT_REWARD = "Select Reward"

local NUM_COLUMNS = 3;

StaticPopupDialogs["CONFIRM_SELECT_WEEKLY_REWARD"] = {
	text = CONFIRM_SELECT_WEEKLY_REWARD,
	button1 = YES,
	button2 = CANCEL,
	OnAccept = function(self)
		C_WeeklyRewards.ClaimReward(self.data.id);
	end,
	timeout = 0,
	hideOnEscape = 1,
	hasItemFrame = 1,
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
	self.SelectRewardButton:SetShown(C_WeeklyRewards.CanClaimRewards());

	local activities = C_WeeklyRewards.GetActivities();
	for i, activityInfo in ipairs(activities) do
		local frame = self:GetActivityFrame(activityInfo.type, activityInfo.index);
		frame:Refresh(activityInfo);
	end
	
	self:UpdateSelection();
end

function WeeklyRewardsMixin:SelectActivity(activityFrame)
	if activityFrame.unlocked and C_WeeklyRewards.CanClaimRewards() then
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
	local canClaimRewards = C_WeeklyRewards.CanClaimRewards();
	local selectedActivity = self.selectedActivity;
	local useAtlasSize = true;
	self.SelectRewardButton:SetEnabled(selectedActivity ~= nil);

	for i, frame in ipairs(self.Activities) do
		local atlas = nil;
		if canClaimRewards and selectedActivity and frame.unlocked then
			if frame == selectedActivity then
				atlas = "weeklyrewards-frame-reward-selected";
			else
				atlas = "weeklyrewards-shadow-reward-unselected";
			end
		end
		frame.SelectionTexture:SetAtlas(atlas, useAtlasSize);
	end
end

function WeeklyRewardsMixin:SelectReward()
	local id = self.selectedActivity.ItemFrame.id;
	local itemHyperlink = C_WeeklyRewards.GetActivityRewardHyperlink(id);
	local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon = GetItemInfo(itemHyperlink);
	local r, g, b = GetItemQualityColor(itemQuality);
	StaticPopup_Show("CONFIRM_SELECT_WEEKLY_REWARD", nil, nil, { id = id, texture = itemIcon, name = itemName, color = {r, g, b, 1}, link = itemHyperlink });
end

WeeklyRewardsActivityMixin = { };

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

	self.unlocked = activityInfo.progress == activityInfo.threshold;

	local useAtlasSize = true;
	local canClaimRewards = C_WeeklyRewards.CanClaimRewards();

	if self.unlocked then
		self.Background:SetAtlas("weeklyrewards-background-reward-unlocked", useAtlasSize);
		self.Border:SetAtlas("weeklyrewards-frame-reward-unlocked", useAtlasSize);
		self.Threshold:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		self.Progress:SetTextColor(GREEN_FONT_COLOR:GetRGB());
		self.Progress:SetFormattedText(GENERIC_FRACTION_STRING, activityInfo.progress, activityInfo.threshold);
		self.LockIcon:Show();
		self.LockIcon:SetAtlas("weeklyrewards-icon-unlocked", useAtlasSize);
		if canClaimRewards then
			self.Orb:SetTexture(nil);
			self.ItemFrame:SetItem(activityInfo.id);
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
		self.Progress:SetFormattedText(GENERIC_FRACTION_STRING, activityInfo.progress, activityInfo.threshold);
		if canClaimRewards then
			self.LockIcon:Show();
			self.LockIcon:SetAtlas("weeklyrewards-icon-incomplete", useAtlasSize);
		else
			self.LockIcon:Hide();
		end
		self.ItemFrame:Hide();
		self.ItemGlow:Hide();
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

WeeklyRewardActivityItemMixin = { };

function WeeklyRewardActivityItemMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -3, -6);
	GameTooltip:SetWeeklyReward(self.id);
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
		local hyperlink = C_WeeklyRewards.GetActivityRewardHyperlink(self.id);
		HandleModifiedItemClick(hyperlink);
	else
		activityFrame:GetParent():SelectActivity(activityFrame);
	end
end

function WeeklyRewardActivityItemMixin:SetItem(id)
	local hyperlink = C_WeeklyRewards.GetActivityRewardHyperlink(id);
	if not hyperlink then
		return;
	end

	self.id = id;
	local item = Item:CreateFromItemLink(hyperlink);
	if not item:IsItemEmpty() then
		item:ContinueOnItemLoad(function()
			self.Name:SetText(item:GetItemName());
			self.Icon:SetTexture(item:GetItemIcon());
			self:Show();
		end);
	end
end