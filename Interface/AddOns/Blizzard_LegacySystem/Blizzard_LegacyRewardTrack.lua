LegacyRewardTrackPageMixin = {}

-- Lines up the cards from the LegacyRewardProgressFrame with progress bar fill based on 0-100 scale
local CARD_POSITION_TO_PROGRESS = {3, 27, 50, 73, 97};
-- Same mapping for the left justified layout, where every card is on screen and none of them are centered.
local STATIC_CARD_POSITION_TO_PROGRESS = {12, 38, 63, 88};
local VISIBLE_CARDS = #CARD_POSITION_TO_PROGRESS;
-- Any more than this and the cards can't all fit at once, so the track scrolls instead.
local MAX_STATIC_ITEMS = #STATIC_CARD_POSITION_TO_PROGRESS;

function LegacyRewardTrackPageMixin:OnLoad()
	EventRegistry:RegisterCallback("Legacy.UpdateCurrencyInfo", function(_, info)
		self:RefreshPoints(info);
	end, self);

	local progressBar = self.LegacyRewardProgressBar;
	self.progressBarMaskTextures = { self.ProgressBarBackground, progressBar:GetStatusBarTexture(), progressBar.ProgressBarFrame };

	LegacySystem.UpdateCurrencyInfo();

	self.majorFactionData = C_MajorFactions.GetMajorFactionData(Constants.LegacyConsts.LEGACY_REWARD_TRACK_FACTION_ID);

	self:SetupRewardTrack();
end

function LegacyRewardTrackPageMixin:OnShow()
	self.centerIndex = 1;
	self:Refresh();
	self.LegacyRewardProgressFrame:SetSelection(1, true);

	self:GetParent():SetTitle(LEGACY_TRACK_FRAME_TITLE);
end

function LegacyRewardTrackPageMixin:RefreshPoints(currencyInfo)
	self.Points:SetText(currencyInfo.renownCurrency);
end

function LegacyRewardTrackPageMixin:IsScrollingTrack()
	return #self.renownLevelsInfo > MAX_STATIC_ITEMS;
end

function LegacyRewardTrackPageMixin:SetupRewardTrack()
	self.renownLevelsInfo = C_MajorFactions.GetRenownLevels(self.majorFactionData.factionID);
	self.maxLevel = self.majorFactionData.maxLevel;

	for level, levelInfo in ipairs(self.renownLevelsInfo) do
		levelInfo.rewardInfo = C_MajorFactions.GetRenownRewardsForLevel(self.majorFactionData.factionID, levelInfo.level);
	end

	self:GamepadSetupRewardTrack_Pre();

	local isScrollingTrack = self:IsScrollingTrack() and InputUtil.IsMKBUIEnabled();
	local progressFrame = self.LegacyRewardProgressFrame;
	progressFrame:SetCenteringEnabled(isScrollingTrack);
	progressFrame:Init(self.renownLevelsInfo, self.majorFactionData.paragonInfo);
	progressFrame.LeftButton:SetShown(isScrollingTrack);
	progressFrame.RightButton:SetShown(isScrollingTrack);
	progressFrame.JumpLeftButton:SetShown(isScrollingTrack);
	progressFrame.JumpRightButton:SetShown(isScrollingTrack);
	progressFrame:Show();

	self:GamepadSetupRewardTrack_Post();

	-- Clicks only select a card to scroll it to the center, which a static track has no use for.
	for _, element in ipairs(progressFrame:GetElements()) do
		element:SetMouseClickEnabled(isScrollingTrack);
	end

	self:UpdateProgressBarMask(isScrollingTrack);
end

function LegacyRewardTrackPageMixin:UpdateProgressBarMask(shouldMask)
	local maskTexture = self.LegacyRewardProgressFrame.ClipFrame.Mask;
	if not maskTexture or self.progressBarMasked == shouldMask then
		return;
	end

	self.progressBarMasked = shouldMask;
	for _, texture in ipairs(self.progressBarMaskTextures) do
		if shouldMask then
			texture:AddMaskTexture(maskTexture);
		else
			texture:RemoveMaskTexture(maskTexture);
		end
	end
end

function LegacyRewardTrackPageMixin:GamepadSetupRewardTrack_Pre()
	if not InputUtil.IsGamepadUIEnabled() then
		return;
	end

	local elements = self.LegacyRewardProgressFrame:GetElements();
	if not elements then
		return;
	end

	for i, frame in ipairs(elements) do
		SmartNavigation_ClearJumpNavigationOverrides(frame);
	end
end

function LegacyRewardTrackPageMixin:GamepadSetupRewardTrack_Post()
	if not InputUtil.IsGamepadUIEnabled() then
		return;
	end

	local function TrackJumpOverride(dir, i)
		local elements = self.LegacyRewardProgressFrame:GetElements();
		local button = self.LegacyRewardProgressFrame.RightButton;
		if dir < 0 then
			button = self.LegacyRewardProgressFrame.LeftButton;
		end
		-- All the buttons are parented to each other and thus a `SetPoint()` on the head track
		-- button in `MouseDown` causes all of them to be put on the resize pending list at end of
		-- frame. The return button is checked for if `IsRectValid()` which isn't true if a resize
		-- is pending. We don't need to check that since `SetPoint` is still a valid call for the
		-- SmartNav cursor and it will get updated when the resize list is executed later on its parent.
		-- For now just do the `SelectButton` ourselves until I have time to look at SmartNav.
		local nextIndex = i + dir;
		if (nextIndex >= 1) and (nextIndex <= #elements) then
			SmartNavigation:SelectButton(elements[i + dir]);
			button:MouseDown();
			button:MouseUp();
		end
		return true;
	end

	for i, frame in ipairs(self.LegacyRewardProgressFrame:GetElements()) do
		SmartNavigation_AddJumpNavigationOverride(frame, SMART_NAV_INPUT_DIRECTION.RIGHT, GenerateFlatClosure(TrackJumpOverride, 1, i));
		SmartNavigation_AddJumpNavigationOverride(frame, SMART_NAV_INPUT_DIRECTION.LEFT, GenerateFlatClosure(TrackJumpOverride, -1, i));
	end
end

function LegacyRewardTrackPageMixin:OnTrackUpdate(leftIndex, centerIndex, rightIndex, isMoving)
	local elements = self.LegacyRewardProgressFrame:GetElements();
	local selectionEnabled = self:IsScrollingTrack();
	local maskTexture = self.LegacyRewardProgressFrame.ClipFrame.Mask;
	for i = leftIndex, rightIndex do
		local selected = selectionEnabled and not isMoving and centerIndex == i;
		local frame = elements[i];
		frame:Refresh(self.actualLevel, self.displayLevel, selected);
		if maskTexture and frame.Textures then
			for _, texture in ipairs(frame.Textures) do
				texture:RemoveMaskTexture(maskTexture);
			end
		end
		local alpha = self.LegacyRewardProgressFrame:GetDesiredAlphaForIndex(i);
		frame:ApplyAlpha(alpha);
	end

	self.centerIndex = centerIndex;
	self:SetupProgressDetails();
end

function LegacyRewardTrackPageMixin:SelectLevel(level, forceRefresh)
	local selectionIndex;
	local elements = self.LegacyRewardProgressFrame:GetElements();
	for i, frame in ipairs(elements) do
		if frame:GetLevel() == level then
			selectionIndex = i;
			break;
		end
	end
	self.LegacyRewardProgressFrame:SetSelection(selectionIndex, forceRefresh);
end

function LegacyRewardTrackPageMixin:GetLevels()
	local renownLevel = C_MajorFactions.GetCurrentRenownLevel(self.majorFactionData.factionID);
	self.actualLevel = renownLevel;
	self.displayLevel = self.actualLevel;
end

function LegacyRewardTrackPageMixin:Refresh()
	if not self.majorFactionData or not self.majorFactionData.factionID then
		return;
	end

	self:GetLevels();

	self:SetupRewardTrack();
	if self.majorFactionData.isUnlocked and not C_MajorFactions.IsMajorFactionHiddenFromExpansionPage(self.majorFactionData.factionID) then
		self:SetupProgressDetails();
	end
end

function LegacyRewardTrackPageMixin:SetupProgressDetails()
	local level = self.majorFactionData.renownLevel;
	local threshold = self.majorFactionData.renownLevelThreshold;
	local progress = self.majorFactionData.renownReputationEarned;

	local thresholdLevel = 0;
	local progressToNextLevel = level;
	local nextLevelThresholdDifference = 100;
	local lastThreshold = 0;
	for i, levelInfo in ipairs(self.renownLevelsInfo) do
		if level >= levelInfo.level then
			thresholdLevel = i;
			progressToNextLevel = progressToNextLevel - (levelInfo.level - lastThreshold);
		else
			nextLevelThresholdDifference = levelInfo.level - lastThreshold;
			break;
		end
		lastThreshold = levelInfo.level;
	end

	local cardPositions = STATIC_CARD_POSITION_TO_PROGRESS;
	local minIndex = 1;
	if self:IsScrollingTrack() then
		cardPositions = CARD_POSITION_TO_PROGRESS;
		minIndex = self.centerIndex - (VISIBLE_CARDS - 1) / 2;
	end
	local maxIndex = minIndex + #cardPositions - 1;

	local maxValue = 100;
	local displayValue = 0;
	if thresholdLevel < 1 or thresholdLevel < minIndex then
		displayValue = progressToNextLevel;
	elseif thresholdLevel > maxIndex then
		displayValue = maxValue;
	else
		local cardIdx = thresholdLevel - minIndex + 1;
		displayValue = cardPositions[cardIdx];

		local valueToNextLevel = 0;
		if cardIdx < #cardPositions then
			valueToNextLevel = cardPositions[cardIdx+1] - displayValue;
		end

		local progressPctToNextLevel = progressToNextLevel / nextLevelThresholdDifference;
		local partialProgress = valueToNextLevel * progressPctToNextLevel;
		displayValue = displayValue + partialProgress;
	end

	self.LegacyRewardProgressBar:SetMinMaxValues(0, maxValue);
	self.LegacyRewardProgressBar:SetValue(displayValue);

	self.LegacyRewardProgressBar:Show();
end

function LegacyRewardTrackPageMixin:CancelLevelEffect()
	-- required interface for RewardTrackFrameMixin, but no-op for the Legacy System
end
