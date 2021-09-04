local NUM_COLUMNS = 3;
local SELECTION_STATE_HIDDEN = 1;
local SELECTION_STATE_UNSELECTED = 2;
local SELECTION_STATE_SELECTED = 3;

local UNLOCKED_EFFECT_INFO = { effectID = 102, offsetX = -30, offsetY = -20};

StaticPopupDialogs["CONFIRM_SELECT_WEEKLY_REWARD"] = {
	text = WEEKLY_REWARDS_CONFIRM_SELECT,
	button1 = YES,
	button2 = CANCEL,
	OnAccept = function(self)
		PlaySound(SOUNDKIT.UI_WEEKLY_REWARD_CONFIRMED_REWARD);
		C_WeeklyRewards.ClaimReward(self.data);
		HideUIPanel(WeeklyRewardsFrame);
	end,
	timeout = 0,
	hideOnEscape = 1,
	showAlert = 1,
	acceptDelay = 5,
}

local WEEKLY_REWARDS_EVENTS = {
	"WEEKLY_REWARDS_SHOW",
	"WEEKLY_REWARDS_HIDE",
	"WEEKLY_REWARDS_UPDATE",
	"CHALLENGE_MODE_COMPLETED",
	"CHALLENGE_MODE_MAPS_UPDATE",
};

WeeklyRewardsMixin = { };

function WeeklyRewardsMixin:OnLoad()
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
	PlaySound(SOUNDKIT.UI_WEEKLY_REWARD_OPEN_WINDOW);
	self:FullRefresh();
end

function WeeklyRewardsMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, WEEKLY_REWARDS_EVENTS);
	PlaySound(SOUNDKIT.UI_WEEKLY_REWARD_CLOSE_WINDOW);
	self.selectedActivity = nil;
	C_WeeklyRewards.CloseInteraction();
	StaticPopup_Hide("CONFIRM_SELECT_WEEKLY_REWARD");
end

function WeeklyRewardsMixin:OnEvent(event)
	if event == "WEEKLY_REWARDS_SHOW" then
		self:FullRefresh();
	elseif event == "WEEKLY_REWARDS_HIDE" then
		HideUIPanel(self);
	elseif event == "WEEKLY_REWARDS_UPDATE" then
		if not self.hasAvailableRewards and C_WeeklyRewards.HasAvailableRewards() then
			-- this means the week ticked over with the UI open
			-- hide the UI so the rewards can be generated when the user reopens it
			HideUIPanel(self);
		else
			-- On initially opening the chest we might not have reward data available, if this changes then play the sheen
			local playSheenAnims = false;
			if self.couldClaimRewardsInOnShow == false and C_WeeklyRewards.CanClaimRewards() then
				playSheenAnims = true;
				self.couldClaimRewardsInOnShow = nil;
			end

			self:Refresh(playSheenAnims);
		end
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
		-- create a background for the frame but parented to main frame so the modelscene can be over it
		local background = self:CreateTexture(nil, "OVERLAY");
		background:SetPoint("BOTTOMRIGHT", frame);
		frame.Background = background;

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

function WeeklyRewardsMixin:IsReadOnly()
	return self.isReadOnly;
end

function WeeklyRewardsMixin:FullRefresh()
	-- for preview item tooltips
	C_MythicPlus.RequestMapInfo();

	self.hasAvailableRewards = C_WeeklyRewards.HasAvailableRewards();
	self.couldClaimRewardsInOnShow = C_WeeklyRewards.CanClaimRewards();
	self.isReadOnly = not C_WeeklyRewards.HasInteraction();

	self:Refresh(self.couldClaimRewardsInOnShow);
end

function WeeklyRewardsMixin:Refresh(playSheenAnims)
	self:UpdateTitle();
	self:UpdateOverlay();
	self:UpdatePreviousClaim();

	local canClaimRewards = C_WeeklyRewards.CanClaimRewards();
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
		if playSheenAnims then
			frame:MarkForPendingSheenAnim();
		end
		frame:Refresh(activityInfo);
	end

	if C_WeeklyRewards.HasAvailableRewards() then
		self:SetHeight(737);
	else
		self:SetHeight(657);
	end

	self:UpdateSelection();
end

function WeeklyRewardsMixin:UpdateTitle()
	local canClaimRewards = C_WeeklyRewards.CanClaimRewards();
	if canClaimRewards then
		self.HeaderFrame.Text:SetText(WEEKLY_REWARDS_CHOOSE_REWARD);
	elseif not C_WeeklyRewards.HasInteraction() and C_WeeklyRewards.HasAvailableRewards() then
		self.HeaderFrame.Text:SetText(WEEKLY_REWARDS_RETURN_TO_CLAIM);
	else
		self.HeaderFrame.Text:SetText(WEEKLY_REWARDS_ADD_ITEMS);
	end
end

function WeeklyRewardsMixin:UpdateOverlay()
	local show = self:ShouldShowOverlay();

	if self:ShouldShowOverlay() then
		self:GetOrCreateOverlay():Show();
	elseif self.Overlay then
		self.Overlay:Hide();
	end

	self.Blackout:SetShown(show);
end

function WeeklyRewardsMixin:ShouldShowOverlay()
	return self:IsReadOnly() and C_WeeklyRewards.HasAvailableRewards();
end

function WeeklyRewardsMixin:GetOrCreateOverlay()
	if self.Overlay then
		return self.Overlay;
	end

	self.Overlay = CreateFrame("Frame", nil, self, "WeeklyRewardOverlayTemplate");
	self.Overlay:SetPoint("TOP", self, "TOP", 0, -142);
	RaiseFrameLevel(self.Overlay);

	return self.Overlay;
end

function WeeklyRewardsMixin:UpdatePreviousClaim()
	self.PreviousRewardNotification:SetShown(not self:IsReadOnly() and C_WeeklyRewards.HasAvailableRewards() and not C_WeeklyRewards.AreRewardsForCurrentRewardPeriod())
end

function WeeklyRewardsMixin:SelectActivity(activityFrame)
	if self:IsReadOnly() then
		return;
	end

	if activityFrame.hasRewards then
		PlaySound(SOUNDKIT.UI_WEEKLY_REWARD_CLICK_REWARD);
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
	PlaySound(SOUNDKIT.UI_WEEKLY_REWARD_SELECT_REWARD);
	if not self.confirmSelectionFrame then
		self.confirmSelectionFrame = CreateFrame("FRAME", nil, self, "WeeklyRewardConfirmSelectionTemplate");
	end
	self.confirmSelectionFrame:ShowPopup(self.selectedActivity:GetDisplayedItemDBID(), self:GetSelectedActivityInfo());
end

WeeklyRewardOverlayMixin = {};

function WeeklyRewardOverlayMixin:OnShow()
	local effect = { effectID = 102, offsetX = 3, offsetY = 0 };
	self.activeEffect = self.ModelScene:AddDynamicEffect(effect, self);
end

function WeeklyRewardOverlayMixin:OnHide()
	if self.activeEffect then
		self.activeEffect:CancelEffect();
		self.activeEffect = nil;
	end
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
	self.ItemFrame:OnSelectionChanged(state == SELECTION_STATE_SELECTED);
end

function WeeklyRewardsActivityMixin:MarkForPendingSheenAnim()
	self.hasPendingSheenAnim = true;
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

	self:SetProgressText();

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
			self:ClearActiveEffect();
		else
			self.Orb:SetAtlas("weeklyrewards-orb-unlocked", useAtlasSize);
			self.ItemGlow:Hide();
			self:SetActiveEffect(UNLOCKED_EFFECT_INFO);
		end

		if self.hasPendingSheenAnim then
			self.hasPendingSheenAnim = nil;
			self.GlowBurst:Show();
			self.Sheen:Show();
			local startDelay = (self.index - 1) * 0.7
			self.SheenAnim.GlowBurstDelay:SetDuration(startDelay);
			self.SheenAnim.SheenDelay:SetDuration(startDelay);
			self.SheenAnim:Play();
		end
	else
		self.Orb:SetAtlas("weeklyrewards-orb-locked", useAtlasSize);
		self.Background:SetAtlas("weeklyrewards-background-reward-locked", useAtlasSize);
		self.Border:SetAtlas("weeklyrewards-frame-reward-locked", useAtlasSize);
		self.Threshold:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		self.Progress:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		if C_WeeklyRewards.HasAvailableRewards() then
			self.LockIcon:Show();
			self.LockIcon:SetAtlas("weeklyrewards-icon-incomplete", useAtlasSize);
		else
			self.LockIcon:Hide();
		end
		self.ItemFrame:Hide();
		self.ItemGlow:Hide();
		self.GlowBurst:Hide();
		self.Sheen:Hide();
		self:ClearActiveEffect();
	end
end

function WeeklyRewardsActivityMixin:OnSheenAnimFinished()
	self.GlowBurst:Hide();
	self.Sheen:Hide();

	self.ItemFrame:RestartGlowSpinAnim();
end

function WeeklyRewardsActivityMixin:SetActiveEffect(effectInfo)
	if effectInfo == self.activeEffectInfo then
		return;
	end

	self.activeEffectInfo = effectInfo;
	if self.activeEffect then
		self.activeEffect:CancelEffect();
		self.activeEffect = nil;
	end

	if effectInfo then
		local modelScene = self:GetParent().ModelScene;
		self.activeEffect = modelScene:AddDynamicEffect(effectInfo, self);
	end
end

function WeeklyRewardsActivityMixin:ClearActiveEffect()
	self:SetActiveEffect(nil);
end

function WeeklyRewardsActivityMixin:SetProgressText(text)
	local activityInfo = self.info;
	if text then
		self.Progress:SetText(text);
	elseif self.hasRewards then
		self.Progress:SetText(nil);
	elseif self.unlocked then
		if activityInfo.type == Enum.WeeklyRewardChestThresholdType.Raid then
			local name = DifficultyUtil.GetDifficultyName(activityInfo.level);
			self.Progress:SetText(name);
		elseif activityInfo.type == Enum.WeeklyRewardChestThresholdType.MythicPlus then
			self.Progress:SetFormattedText(WEEKLY_REWARDS_MYTHIC, activityInfo.level);
		elseif activityInfo.type == Enum.WeeklyRewardChestThresholdType.RankedPvP then
			self.Progress:SetText(PVPUtil.GetTierName(activityInfo.level));
		end
	else
		if C_WeeklyRewards.CanClaimRewards() then
			-- no progress on incomplete activites during claiming
			self.Progress:SetText(nil);
		else
			self.Progress:SetFormattedText(GENERIC_FRACTION_STRING, activityInfo.progress, activityInfo.threshold);
		end
	end
end

function WeeklyRewardsActivityMixin:OnMouseUp(button, upInside)
	if button == "LeftButton" and upInside then
		self:GetParent():SelectActivity(self);
	end
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
			local hasData, nextLevel, nextItemLevel = C_WeeklyRewards.GetNextMythicPlusIncrease(self.info.level);
			if hasData then
				upgradeItemLevel = nextItemLevel;
			else
				nextLevel = self.info.level + 1;
			end
			self:HandlePreviewMythicRewardTooltip(itemLevel, upgradeItemLevel, nextLevel);
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
	local currentDifficultyName = DifficultyUtil.GetDifficultyName(currentDifficultyID);
	GameTooltip_AddNormalLine(GameTooltip, string.format(WEEKLY_REWARDS_ITEM_LEVEL_RAID, itemLevel, currentDifficultyName));
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	if upgradeItemLevel then
		local nextDifficultyID = DifficultyUtil.GetNextPrimaryRaidDifficultyID(currentDifficultyID);
		if nextDifficultyID then
			local difficultyName = DifficultyUtil.GetDifficultyName(nextDifficultyID);
			GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_IMPROVE_ITEM_LEVEL, upgradeItemLevel), GREEN_FONT_COLOR);
			GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_RAID, difficultyName));

			local encounters = C_WeeklyRewards.GetActivityEncounterInfo(self.info.type, self.info.index);
			if encounters then
				table.sort(encounters, function(left, right)
					if left.instanceID ~= right.instanceID then
						return left.instanceID < right.instanceID;
					end
					local leftCompleted = left.bestDifficulty > 0;
					local rightCompleted = right.bestDifficulty > 0;
					if leftCompleted ~= rightCompleted then
						return leftCompleted;
					end
					return left.uiOrder < right.uiOrder;
				end)
				local lastInstanceID = nil;
				for index, encounter in ipairs(encounters) do
					local name, description, encounterID, rootSectionID, link, instanceID = EJ_GetEncounterInfo(encounter.encounterID);
					if instanceID ~= lastInstanceID then
						local instanceName = EJ_GetInstanceInfo(instanceID);
						GameTooltip_AddBlankLineToTooltip(GameTooltip);	
						GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_ENCOUNTER_LIST, instanceName));
						lastInstanceID = instanceID;
					end
					if name then
						if encounter.bestDifficulty > 0 then
							local completedDifficultyName = DifficultyUtil.GetDifficultyName(encounter.bestDifficulty);
							GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETED_ENCOUNTER, name, completedDifficultyName), GREEN_FONT_COLOR);
						else
							GameTooltip_AddColoredLine(GameTooltip, string.format(DASH_WITH_TEXT, name), DISABLED_FONT_COLOR);
						end
					end
				end
			end
		end
	end
end

function WeeklyRewardsActivityMixin:HandlePreviewMythicRewardTooltip(itemLevel, upgradeItemLevel, nextLevel)
	GameTooltip_AddNormalLine(GameTooltip, string.format(WEEKLY_REWARDS_ITEM_LEVEL_MYTHIC, itemLevel, self.info.level));
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	if upgradeItemLevel then
		GameTooltip_AddColoredLine(GameTooltip, string.format(WEEKLY_REWARDS_IMPROVE_ITEM_LEVEL, upgradeItemLevel), GREEN_FONT_COLOR);
		if self.info.threshold == 1 then
			GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_MYTHIC_SHORT, nextLevel));
		else
			GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_MYTHIC, nextLevel, self.info.threshold));
			local runHistory = C_MythicPlus.GetRunHistory(false, true);
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
					if runHistory[i] then
						local runInfo = runHistory[i];
						local name = C_ChallengeMode.GetMapUIInfo(runInfo.mapChallengeModeID);
						GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_MYTHIC_RUN_INFO, runInfo.level, name));
					end
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
			if ascendTierInfo.ascendRating == 0 then
				GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_PVP_MAX, ascendTierName, tierInfo.ascendRating));
			else
				GameTooltip_AddHighlightLine(GameTooltip, string.format(WEEKLY_REWARDS_COMPLETE_PVP, ascendTierName, tierInfo.ascendRating, ascendTierInfo.ascendRating - 1));
			end
		end
	end
end

function WeeklyRewardsActivityMixin:OnLeave()
	self.UpdateTooltip = nil;
	GameTooltip:Hide();
end

function WeeklyRewardsActivityMixin:OnHide()
	self.hasPendingSheenAnim = nil;
	self:ClearActiveEffect();
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

function WeeklyRewardActivityItemMixin:OnSelectionChanged(selected)
	self.Glow:SetShown(selected);
	self.GlowSpin:SetShown(selected);
	if selected then
		self.GlowSpinAnim:Play();
	else
		self.GlowSpinAnim:Stop();
	end
end

function WeeklyRewardActivityItemMixin:RestartGlowSpinAnim()
	-- working around an anim bug where it captures the wrong state due to a parent's anim playing/finishing
	-- restarting it will re-capture the now correct state
	if self.GlowSpinAnim:IsPlaying() then
		local offset = self.GlowSpinAnim:GetProgress() * self.GlowSpinAnim:GetDuration();
		self.GlowSpinAnim:Stop();
		self.GlowSpinAnim:Play(false, offset);
	end
end

function WeeklyRewardActivityItemMixin:SetDisplayedItem()
	self.displayedItemDBID = nil;
	local bestItemQuality = 0;
	local bestItemLevel = 0;
	for i, rewardInfo in ipairs(self:GetParent().info.rewards) do
		if rewardInfo.type == Enum.CachedRewardType.Item and not C_Item.IsItemKeystoneByID(rewardInfo.id) then
			local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon = GetItemInfo(rewardInfo.id);
			-- want highest item level of highest quality
			-- this comparison is not really needed now since the rewards are 1 equippable and 1 non-equippable item
			if itemQuality > bestItemQuality or (itemQuality == bestItemQuality and itemLevel > bestItemLevel) then
				bestItemQuality = itemQuality;
				bestItemLevel = itemLevel;
				self.displayedItemDBID = rewardInfo.itemDBID;
				self.Name:SetText(itemName);
				self.Icon:SetTexture(itemIcon);
				SetItemButtonOverlay(self, C_WeeklyRewards.GetItemHyperlink(rewardInfo.itemDBID));
			end
		end
	end
	if self.displayedItemDBID then
		local hyperlink = C_WeeklyRewards.GetItemHyperlink(self.displayedItemDBID);
		if hyperlink then
			local itemLevel = GetDetailedItemLevelInfo(hyperlink);
			local progressText = string.format(ITEM_LEVEL, itemLevel);
			self:GetParent():SetProgressText(progressText);
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

function WeeklyRewardsConcessionMixin:MarkForPendingSheenAnim()
	-- nothing?
end

function WeeklyRewardsConcessionMixin:Refresh(activityInfo)
	self.info = nil;

	local comparison = function(entry1, entry2)
		if ( entry1.type ~= entry2.type ) then
			return entry1.type == Enum.CachedRewardType.Item;
		else
			return entry1.quantity > entry2.quantity;
		end
	end
	table.sort(activityInfo.rewards, comparison);

	local rewardIndex;
	for i, rewardInfo in ipairs(activityInfo.rewards) do
		-- no mythic keystone items
		local icon;
		if rewardInfo.type == Enum.CachedRewardType.Item and not C_Item.IsItemKeystoneByID(rewardInfo.id) then
			icon = select(5, GetItemInfoInstant(rewardInfo.id));
		elseif rewardInfo.type == Enum.CachedRewardType.Currency then
			local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(rewardInfo.id);
			icon = currencyInfo and currencyInfo.iconFileID;
		end

		if icon then
			self.RewardsFrame.Text:SetText(string.format(WEEKLY_REWARDS_CONCESSION_FORMAT, icon, rewardInfo.quantity));
			self.RewardsFrame:Layout();
			self.info = activityInfo;
			self.displayedRewardIndex = i;
			self:Show();
			break;
		end
	end
end

function WeeklyRewardsConcessionMixin:OnEnter()
	self:SetScript("OnUpdate", self.OnUpdate);
end

function WeeklyRewardsConcessionMixin:OnLeave()
	self:SetScript("OnUpdate", nil);
	GameTooltip:Hide();
end

function WeeklyRewardsConcessionMixin:OnUpdate()
	if self.info and GameTooltip:GetOwner() ~= self and self.RewardsFrame:IsMouseOver() then
		GameTooltip:SetOwner(self.RewardsFrame, "ANCHOR_RIGHT");
		local rewardInfo = self.info.rewards[self.displayedRewardIndex];
		if rewardInfo.type == Enum.CachedRewardType.Item then
			local itemHyperlink = C_WeeklyRewards.GetItemHyperlink(rewardInfo.itemDBID);
			GameTooltip:SetHyperlink(itemHyperlink);
		elseif rewardInfo.type == Enum.CachedRewardType.Currency then
			GameTooltip:SetCurrencyByID(rewardInfo.id);
		end
	end
end

function WeeklyRewardsConcessionMixin:OnMouseDown()
	self:GetParent():SelectActivity(self);
end

function WeeklyRewardsConcessionMixin:GetDisplayedItemDBID()
	local rewardInfo = self.info.rewards[self.displayedRewardIndex];
	if rewardInfo.type == Enum.CachedRewardType.Item then
		return rewardInfo.itemDBID;
	end
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
	StaticPopup_Show("CONFIRM_SELECT_WEEKLY_REWARD", nil, nil, activityInfo.claimID, self);
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
		local count = 0;
		for i, rewardInfo in ipairs(self.activityInfo.rewards) do
			if rewardInfo.itemDBID == self.itemDBID then
				count = rewardInfo.quantity;
				break;
			end
		end
		SetItemButtonCount(itemFrame, count);
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