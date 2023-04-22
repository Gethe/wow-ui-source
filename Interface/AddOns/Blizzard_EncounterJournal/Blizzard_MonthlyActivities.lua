-------------------------------------------------
--------------Monthly Activities Panel Func--------------
-------------------------------------------------

local MonthlyActivityFilterSelection;
local MonthlyActivitySelected = nil;

local ACTIVITIES_MONTH_NAMES = {
	MONTH_JANUARY,
	MONTH_FEBRUARY,
	MONTH_MARCH,
	MONTH_APRIL,
	MONTH_MAY,
	MONTH_JUNE,
	MONTH_JULY,
	MONTH_AUGUST,
	MONTH_SEPTEMBER,
	MONTH_OCTOBER,
	MONTH_NOVEMBER,
	MONTH_DECEMBER,
};

MonthlyActivities_HelpPlate = {
	FramePos = { x = 2, y = 40 },
	FrameSize = { width = 800, height = 480 },
	[1] = { ButtonPos = { x = 6,	y = -110 }, HighLightBox = { x = 00,  y = -94, width = 790, height = 80 },		ToolTipDir = "RIGHT",   ToolTipText = MONTHLY_ACTIVITIES_HELP_1 },
	[2] = { ButtonPos = { x = 230,  y = -176 }, HighLightBox = { x = 230, y = -176, width = 560, height = 295 },	ToolTipDir = "RIGHT",   ToolTipText = MONTHLY_ACTIVITIES_HELP_2 },
}

function MonthlyActivities_ToggleTutorial()
	local helpPlate = MonthlyActivities_HelpPlate;
	if ( helpPlate and not HelpPlate_IsShowing(helpPlate) ) then
		HelpPlate_Show( helpPlate, EncounterJournal.MonthlyActivitiesFrame, EncounterJournal.MonthlyActivitiesFrame.HelpButton );
	else
		HelpPlate_Hide(true);
	end
end

function AreMonthlyActivitiesRestricted()
	return IsTrialAccount() or IsVeteranTrialAccount();
end

-- MonthlyActivitiesButton
MonthlyActivitiesButtonMixin = { };

function MonthlyActivitiesButtonMixin:Init(elementData)
	-- Handle scrolling down the list while anims are playing on an existing button
	if self.CheckmarkAnim:IsPlaying() or self.CoinAnim:IsPlaying() then
		self.CheckmarkAnim:Stop();
		self.CoinAnim:Stop();
		self.pendingComplete = false;
		MonthlyActivities_PendingAnimComplete();
	end

	self.id = elementData.id;
	self.tracked = elementData.tracked;
	self.requirementsList = elementData.requirementsList;
	self.activityName = elementData.name;
	self.description = elementData.description;
	self.completed = elementData.completed;
	self.Name:SetText(elementData.name);
	self.Name:SetFontObject(elementData.completed and "GameFontBlackMedium" or "GameFontHighlightMedium");
	self.Ribbon:SetShown(not elementData.restricted and (elementData.completed or elementData.rewardAvailable));
	self.Points:SetText(elementData.points);
	self.Points:SetShown(not elementData.restricted and not elementData.completed and elementData.rewardAvailable and not elementData.pendingComplete);
	self.Checkmark:SetShown(not elementData.restricted and elementData.completed and not elementData.pendingComplete);
	self.CheckmarkFlipbook:SetShown(elementData.pendingComplete);
	self.ActiveBg:SetShown(self.id == MonthlyActivitySelected);
	self.TrackingCheckmark:SetShown(elementData.tracked and not elementData.completed);

	self:SetNormalAtlas(elementData.completed and "activities-complete" or "activities-incomplete");

	-- Prevent hover state and tooltip when restricted
	self:SetEnabled(not elementData.restricted);

	self:Show();
end

function MonthlyActivitiesButtonMixin:OnEnter()
	if self.requirementsList then
		self.showingTooltip = true;
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT");
		self:ShowTooltip();
	end
end

function MonthlyActivitiesButtonMixin:OnClick()
	if ( IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
		local perksActivityLink = C_PerksActivities.GetPerksActivityChatLink(self.id);
		ChatEdit_InsertLink(perksActivityLink);
		return;
	end

	if ( IsModifiedClick("QUESTWATCHTOGGLE") ) then
		if self.tracked then
			C_PerksActivities.RemoveTrackedPerksActivity(self.id);
		elseif not self.completed then
			C_PerksActivities.AddTrackedPerksActivity(self.id);
		end
		if self.showingTooltip then
			self:ShowTooltip();
		end

		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end

function MonthlyActivitiesButtonMixin:OnLeave()
	GameTooltip:Hide();
	self.showingTooltip = false;
end

function MonthlyActivitiesButtonMixin:ShowTooltip()
	GameTooltip_SetTitle(GameTooltip, self.activityName, NORMAL_FONT_COLOR, true);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);

	if #self.description > 0 then
		GameTooltip:AddLine(self.description, 1, 1, 1, true);
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
	end

	for _, requirement in ipairs(self.requirementsList) do
		local tooltipLine = requirement.requirementText;
		tooltipLine = string.gsub(tooltipLine, " / ", "/");
		local color = not requirement.completed and WHITE_FONT_COLOR or DISABLED_FONT_COLOR;
		GameTooltip:AddLine(tooltipLine, color.r, color.g, color.b, true);
	end

	if self.tracked then
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip:AddLine(MONTHLY_ACTIVITIES_UNTRACK, 0, 1, 0);
	elseif not self.completed then
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip:AddLine(MONTHLY_ACTIVITIES_TRACK, 0, 1, 0);
	end
	GameTooltip:Show();
end

-- MonthlyActivitiesThresholdMixin
MonthlyActivitiesThresholdMixin = { };

function MonthlyActivitiesThresholdMixin:SetCurrentPoints(points)
	self.RewardCurrency:SetCurrentPoints(points);

	self.LineIncomplete:SetShown(not aboveThreshold and self.showLine);
	self.LineComplete:SetShown(aboveThreshold and self.showLine);
	
	local initialSet = self.aboveThreshold == nil;
	local aboveThreshold = points >= self.thresholdInfo.requiredContributionAmount;
	if self.aboveThreshold == aboveThreshold then
		return;
	end

	self.aboveThreshold = aboveThreshold;

	if not initialSet and aboveThreshold and self.thresholdInfo.itemReward then
		GlobalFXDialogModelScene:AddEffect(163, self.RewardItem);
	end
end

function MonthlyActivitiesThresholdMixin:SetThresholdInfo(thresholdInfo, showLine)
	self.thresholdInfo = thresholdInfo;
	self.showLine = showLine;

	self.RewardCurrency:SetThresholdInfo(thresholdInfo);

	self.RewardItem:SetShown(thresholdInfo.itemReward ~= nil);
	if thresholdInfo.itemReward then
		self.RewardItem:SetItem(thresholdInfo.itemReward);
	end
end

-- MonthlyActivitiesRewardCurrencyMixin
MonthlyActivitiesRewardCurrencyMixin = { };

function MonthlyActivitiesRewardCurrencyMixin:SetCurrentPoints(points)
	local aboveThreshold = points >= self.thresholdInfo.requiredContributionAmount;

	self.PendingGlow:SetShown(aboveThreshold and self.thresholdInfo.pendingReward);

	local initialSet = self.aboveThreshold == nil;
	if self.aboveThreshold == aboveThreshold then
		return;
	end

	self.aboveThreshold = aboveThreshold;

	if not initialSet and aboveThreshold then
		if self:IsVisible() then
			PlaySound(SOUNDKIT.TRADING_POST_UI_REWARD_TIER_COMPLETE);
		end
		self.EarnedAnim:Play();
	end

	self.DiamondIncomplete:SetShown(not aboveThreshold);
	self.DiamondComplete:SetShown(aboveThreshold);
	self.Points:SetShown(not aboveThreshold);
	self.EarnedCheckmark:SetShown(aboveThreshold);
end

function MonthlyActivitiesRewardCurrencyMixin:SetThresholdInfo(thresholdInfo)
	self.thresholdInfo = thresholdInfo;

	-- Reset alpha on re-initialize to handle case where animations have adjusted it.
	self.EarnedCheckmark:SetAlpha(1);
	self.Points:SetAlpha(1);
	self.CheckmarkFlipbook:SetAlpha(0);

	self.Points:SetText(thresholdInfo.currencyAwardAmount);

	self.item = self.thresholdInfo.itemReward and Item:CreateFromItemID(self.thresholdInfo.itemReward) or nil;
end

function MonthlyActivitiesRewardCurrencyMixin:OnEnter()
	if self.item and not self.item:IsItemDataCached() then
		self.itemDataLoadedCancelFunc = self.item:ContinueOnItemLoad(GenerateClosure(self.OnEnter, self));
		return;
	end

	self.itemDataLoadedCancelFunc = nil;

	GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT");

	local rewardFormat = self.thresholdInfo.itemReward and MONTHLY_ACTIVITIES_THRESHOLD_TOOLTIP_REWARDS or MONTHLY_ACTIVITIES_THRESHOLD_TOOLTIP_REWARD;
	GameTooltip:AddLine(rewardFormat:format(self.thresholdInfo.currencyAwardAmount, CreateSimpleTextureMarkup([[Interface\ICONS\TradingPostCurrency]], 14, 14)), nil, nil, nil, true);

	if self.item then
		local itemName = self.item:GetItemName();
		
		local textureSettings = {
			width = 14,
			height = 14,
			verticalOffset = 0,
			margin = { right = 2, top = 2, bottom = 2 },
		};
		local color = self.item:GetItemQualityColor();
		GameTooltip:AddLine(itemName, color.r, color.g, color.b, true);
		GameTooltip:AddTexture(self.item:GetItemIcon(), textureSettings);
	end

	if self.thresholdInfo.pendingReward then
		GameTooltip:AddLine(MONTHLY_ACTIVITIES_THRESHOLD_TOOLTIP_PENDING, nil, nil, nil, true);
	end

	GameTooltip:Show();
end

function MonthlyActivitiesRewardCurrencyMixin:OnLeave()
	GameTooltip:Hide();

	if self.itemDataLoadedCancelFunc then
		self.itemDataLoadedCancelFunc();
		self.itemDataLoadedCancelFunc = nil;
	end
end

-- MonthlyActivitiesFilterListButtonMixin
MonthlyActivitiesFilterListButtonMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function MonthlyActivitiesFilterListButtonMixin:OnEnter()
	if ButtonStateBehaviorMixin.OnEnter(self) then
		self:UpdateState();
	end
end

function MonthlyActivitiesFilterListButtonMixin:OnLeave()
	if ButtonStateBehaviorMixin.OnLeave(self) then
		self:UpdateState();
	end
end

function MonthlyActivitiesFilterListButtonMixin:UpdateStateInternal(selected)
	if selected then
		self.Label:SetFontObject("GameFontHighlight");
		self.Texture:SetAtlas("Options_List_Active", TextureKitConstants.UseAtlasSize);
		self.Texture:Show();
	else
		self.Label:SetFontObject("GameFontNormal");
		if self.over then
			self.Texture:SetAtlas("Options_List_Hover", TextureKitConstants.UseAtlasSize);
			self.Texture:Show();
		else
			self.Texture:Hide();
		end
	end
end

function MonthlyActivitiesFilterListButtonMixin:UpdateState()
	self:UpdateStateInternal(MonthlyActivityFilterSelection:IsSelected(self));
end

function MonthlyActivitiesFilterListButtonMixin:Init(elementData)
	local filter = elementData.filter;

	self.Label:SetText(filter);
	self.LockIcon:SetShown(AreMonthlyActivitiesRestricted());
	
	self:SetSelected(MonthlyActivityFilterSelection:IsSelected(self));
end

function MonthlyActivitiesFilterListButtonMixin:SetSelected(selected)
	self:UpdateStateInternal(selected);
end

-- MonthlyActivitiesFilterListMixin
MonthlyActivitiesFilterListMixin = { };

function MonthlyActivitiesFilterListMixin:OnLoad()
	local pad = 10;
	local spacing = 2;
	local view = CreateScrollBoxListLinearView(pad, pad, pad, pad, spacing);
		
	local function Initializer(button, elementData)
		button:Init(elementData);

		button:SetScript("OnClick", function(button, buttonName, down)
			MonthlyActivityFilterSelection:Select(button);
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		end);
	end

	view:SetElementInitializer("MonthlyActivitiesFilterListButtonTemplate", Initializer);

	self.ScrollBox:Init(view);

	local function OnSelectionChanged(o, elementData, selected)
		local button = self.ScrollBox:FindFrame(elementData);
		if button then
			button:SetSelected(selected);
		end

		if selected then
			self.ScrollBox:ScrollToElementData(elementData, ScrollBoxConstants.AlignNearest);
		end

		local activitiesInfo = C_PerksActivities.GetPerksActivitiesInfo();
		EncounterJournal.MonthlyActivitiesFrame:SetActivities(activitiesInfo.activities, ScrollBoxConstants.RetainScrollPosition);
	end;

	MonthlyActivityFilterSelection = ScrollUtil.AddSelectionBehavior(self.ScrollBox);
	MonthlyActivityFilterSelection:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, OnSelectionChanged, self);
end

function MonthlyActivitiesFilterListMixin:UpdateFilters()
	local oldSelection = MonthlyActivityFilterSelection:GetFirstSelectedElementData();

	local dataProvider = CreateDataProvider();
	
	local allTags = C_PerksActivities.GetAllPerksActivityTags();
	
	local activitiesInfo = C_PerksActivities.GetPerksActivitiesInfo();
	
	local usedTags = { };
	for _, activityInfo in pairs(activitiesInfo.activities) do
		for _, tag in pairs(activityInfo.tagNames) do
			usedTags[tag] = true;
		end
	end

	local sortedTags = { };
	for _, tag in ipairs(allTags.tagName) do
		if usedTags[tag] then
			table.insert(sortedTags, tag);
		end
	end
	table.sort(sortedTags);

	dataProvider:Insert({ filter = ALL });

	local hasOther = false;
	for _, tag in ipairs(sortedTags) do
		if tag == OTHER then
			hasOther = true;
		else
			dataProvider:Insert({ filter = tag });
		end
	end

	if hasOther then
		dataProvider:Insert({ filter = OTHER });
	end
	
	self.ScrollBox:SetDataProvider(dataProvider);

	if oldSelection then
		MonthlyActivityFilterSelection:SelectElementDataByPredicate(function(elementData) return elementData.filter == oldSelection.filter; end);
	else
		MonthlyActivityFilterSelection:SelectFirstElementData();
	end
end

-- MonthlyActivitiesFrame
MonthlyActivitiesFrameMixin = { };

function MonthlyActivitiesFrameMixin:OnLoad()
	self.pendingComplete = { };

	-- Anchors can't be set on BarFill in layout, has to be OnLoad
	self.ThresholdBar.BarFillGlow:SetPoint("LEFT", self.ThresholdBar.BarFill, "LEFT", 0, 0);
	self.ThresholdBar.BarFillGlow:SetPoint("RIGHT", self.ThresholdBar.BarFill, "RIGHT", 0, 0);
	self.ThresholdBar.BarEnd:SetPoint("CENTER", self.ThresholdBar.BarFill, "RIGHT", 0, 0);

	local leftPad = 10;
	local Pad = 0;
	local Spacing = 0;
	local view = CreateScrollBoxListLinearView(leftPad, Pad, Pad, Pad, Spacing);
		
	local function Initializer(button, elementData)
		button:Init(elementData);
	end

	view:SetElementInitializer("MonthlyActivitiesButtonTemplate", Initializer);

	ScrollUtil.InitScrollBoxWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.FilterList:UpdateFilters();

	self:UpdateActivities();
	self:RegisterEvent("PERKS_ACTIVITIES_TRACKED_UPDATED");
	self:RegisterEvent("PERKS_ACTIVITIES_UPDATED");
	self:RegisterEvent("CHEST_REWARDS_UPDATED_FROM_SERVER");
	self:RegisterEvent("PERKS_ACTIVITY_COMPLETED");

	C_PerksProgram.RequestPendingChestRewards();
end

function MonthlyActivitiesFrameMixin:OnHide()
	if self.progressionSoundHandle then
		StopSound(self.progressionSoundHandle);
		self.progressionSoundHandle = nil;
	end

	local helpPlate = MonthlyActivities_HelpPlate;
	if ( helpPlate and HelpPlate_IsShowing(helpPlate) ) then
		HelpPlate_Hide(false);
	end
end

function MonthlyActivitiesFrameMixin:OnEvent(event, ...)
	if ( event == "PERKS_ACTIVITIES_UPDATED" ) then
		local activitiesInfo = ...;
		self:UpdateActivities(ScrollBoxConstants.RetainScrollPosition, activitiesInfo);
	elseif ( event == "PERKS_ACTIVITIES_TRACKED_UPDATED" or event == "CHEST_REWARDS_UPDATED_FROM_SERVER" ) then
		self:UpdateActivities(ScrollBoxConstants.RetainScrollPosition);
	elseif ( event == "PERKS_ACTIVITY_COMPLETED" ) then
		self:UpdateActivities(ScrollBoxConstants.RetainScrollPosition);
		Chat_AddSystemMessage(MONTHLY_ACTIVITIES_UPDATED);
	end
end

function MonthlyActivitiesFrameMixin:UpdateActivities(retainScrollPosition, activitiesInfo)
	if not activitiesInfo then
		activitiesInfo = C_PerksActivities.GetPerksActivitiesInfo();
	end
	
	-- Gather info based on all activities, thresholds, and pending rewards that will affect how they are all displayed
	local pendingRewards = C_PerksProgram.GetPendingChestRewards();

	local function HasPendingReward(thresholdOrderIndex)
		for _, reward in pairs(pendingRewards) do
			if reward.activityMonthID == activitiesInfo.activePerksMonth and reward.thresholdOrderIndex == thresholdOrderIndex then
				return true;
			end
		end
		return false;
	end

	local thresholdMax = 0;
	for _, thresholdInfo in pairs(activitiesInfo.thresholds) do
		thresholdInfo.pendingReward = HasPendingReward(thresholdInfo.thresholdOrderIndex);

		if thresholdInfo.requiredContributionAmount > thresholdMax then
			thresholdMax = thresholdInfo.requiredContributionAmount;
		end
	end

	self.allRewardsCollected = TableIsEmpty(pendingRewards);

	-- Prevent divide by zero below
	if thresholdMax == 0 then
		thresholdMax = 1000;
	end

	self.pendingComplete = { };

	local earnedThresholdAmount = 0;
	for _, activity in pairs(activitiesInfo.activities) do
		if activity.completed then
			earnedThresholdAmount = earnedThresholdAmount + activity.thresholdContributionAmount;
		end
	end
	earnedThresholdAmount = math.min(earnedThresholdAmount, thresholdMax);

	local pendingIDs = C_PerksActivities.GetPerksActivitiesPendingCompletion().pendingIDs;
	for _, id in ipairs(pendingIDs) do
		self.pendingComplete[id] = true;
	end

	-- Build UI - rewards text or threshold bar at the top, activities list below
	self:UpdateTime(activitiesInfo.displayMonthName, activitiesInfo.secondsRemaining);
	self:SetThresholds(activitiesInfo.thresholds, earnedThresholdAmount, thresholdMax);
	self:SetActivities(activitiesInfo.activities, retainScrollPosition);
	self.FilterList:UpdateFilters();

	local currentMonth = tonumber(GetCVar("perksActivitiesCurrentMonth"));
	if currentMonth ~= activitiesInfo.activePerksMonth then
		SetCVar("perksActivitiesCurrentMonth", activitiesInfo.activePerksMonth);
		SetCVar("perksActivitiesLastPoints", 0);
	end

	-- Reset bar animation targets if already started from a previous update
	self.pendingTargetValue = nil;
	self.targetValue = nil;

	local lastPoints = tonumber(GetCVar("perksActivitiesLastPoints"));
	self:SetCurrentPoints(lastPoints, lastPoints);

	if earnedThresholdAmount ~= lastPoints or not TableIsEmpty(self.pendingComplete) then
		self.pendingTargetValue = earnedThresholdAmount;
		self.PauseAnim:Play();
	end
end

function MonthlyActivitiesFrameMixin:TriggerNextPending()
	local frame = self.ScrollBox:FindFrameByPredicate(function(frame)
		return self.pendingComplete[frame.id];
	end);
	if frame then
		self.pendingComplete[frame.id] = nil;
		frame:GetElementData().pendingComplete = false;
		frame.CoinAnim:Play();
		frame.CheckmarkAnim:Play();
		self:SetAnimating(true);

		if self:IsVisible() then
			PlaySound(SOUNDKIT.TRADING_POST_UI_COMPLETED_ACTIVITY);
		end
	else
		self.pendingComplete = { };
		self.ScrollBox:GetDataProvider():ForEach(function(elementData)
			elementData.pendingComplete = false;
		end);
		C_PerksActivities.ClearPerksActivitiesPendingCompletion();

		if self.pendingTargetValue then
			self.targetValue = self.pendingTargetValue;
			self.pendingTargetValue = nil;
			self.progressionSFXQueued = true;
		end
	end
end

function MonthlyActivities_PendingAnimComplete(anim)
	EncounterJournal.MonthlyActivitiesFrame:TriggerNextPending();
end

function MonthlyActivitiesFrameMixin:SetActivities(activities, retainScrollPosition)
	local selected = MonthlyActivityFilterSelection:GetFirstSelectedElementData();
	local selectedFilter = selected and selected.filter;
	local restricted = AreMonthlyActivitiesRestricted();

	-- Add activity buttons
	local dataProvider = CreateDataProvider();
	for _, activity in pairs(activities) do
		local activityFiltered = selectedFilter ~= ALL;

		for _, tag in pairs(activity.tagNames) do
			if tag == selectedFilter then
				activityFiltered = false;
			end
		end

		if not activityFiltered then
			dataProvider:Insert({
				id = activity.ID,
				name = activity.activityName,
				description = activity.description,
				points = activity.thresholdContributionAmount,
				completed = activity.completed,
				requirementsList = activity.requirementsList,
				tracked = activity.tracked,
				rewardAvailable = not self.allRewardsEarned,
				pendingComplete = self.pendingComplete[activity.ID],
				thresholdMax = self.thresholdMax,
				restricted = restricted,
				uiPriority = activity.uiPriority,
			});
		end
	end

	dataProvider:SetSortComparator(function(a, b)
		-- Sort pending complete to the top
		if a.pendingComplete ~= b.pendingComplete then
			return a.pendingComplete;
		end

		-- But sort already completed to the bottom
		if a.completed ~= b.completed then
			return b.completed;
		end

		-- Sort by data driven ui priority field
		if a.uiPriority ~= b.uiPriority then
			return a.uiPriority > b.uiPriority;
		end
	
		-- Then sort by points descending
		if a.points ~= b.points then
			return a.points > b.points;
		end
	
		-- Last sort by alphabetical name
		return a.name < b.name;
	end);

	self.ScrollBox:SetDataProvider(dataProvider, retainScrollPosition);
end

function MonthlyActivitiesFrameMixin:OnUpdate()
	if not self.targetValue then
		return;
	end

	if self.progressionSFXQueued then
		self.progressionSFXQueued = false;

		if not self.progressionSoundHandle then
			local _, progressionSoundHandle = PlaySound(SOUNDKIT.TRADING_POST_UI_ACTIVITY_PROGRESSION);
			self.progressionSoundHandle = progressionSoundHandle;
		end
	end

	local curValue = self.ThresholdBar:GetValue();
	local barValue = math.min(curValue + 5, self.targetValue);
	self:SetCurrentPoints(curValue, barValue);

	if barValue >= self.targetValue then
		SetCVar("perksActivitiesLastPoints", self.targetValue);
		self.targetValue = nil;
		self:SetAnimating(false);

		if self.progressionSoundHandle then
			StopSound(self.progressionSoundHandle);
			self.progressionSoundHandle = nil;
		end

		if self.allRewardsEarned then
			PlaySound(SOUNDKIT.TRADING_POST_UI_COMPLETED_PROGRESS);
		else
			PlaySound(SOUNDKIT.TRADING_POST_UI_ACTIVITY_PROGRESSION_STOP);
		end

		-- Re-sort completed activities to bottom once all animations are complete.
		self.ScrollBox:GetDataProvider():Sort();
	end
end

function MonthlyActivitiesFrameMixin:SetCurrentPoints(curValue, barValue)
	self.ThresholdBar:SetValue(barValue);
	self.ThresholdBar.BarFillGlow:SetTexCoord(self.ThresholdBar.BarFill:GetTexCoord());

	for _, thresholdFrame in pairs(self.thresholdFrames) do
		thresholdFrame:SetCurrentPoints(barValue);
	end

	self.ThresholdBar.TextContainer.ProgressText:SetText(MONTHLY_ACTIVITIES_PROGRESS_TEXT:format(barValue, self.thresholdMax));
	self.ThresholdBar.BarEnd:SetShown(barValue > 0);

	local allRewardsEarned = barValue >= self.thresholdMax;
	self:SetRewardsEarnedAndCollected(allRewardsEarned, self.allRewardsCollected);
end

function MonthlyActivitiesFrameMixin:SetAnimating(isAnimating)
	if self.isAnimating ~= isAnimating then
		self.isAnimating = isAnimating;

		local reverse = not isAnimating;
		self.ThresholdBar.GlowAnim:Play(reverse);
	end
end

function MonthlyActivitiesFrameMixin:SetThresholds(thresholds, earnedThresholdAmount, thresholdMax)
	-- Setup point threshold bar
	self.ThresholdBar:SetMinMaxValues(0, thresholdMax);

	self.thresholdMax = thresholdMax;

	local earnedNewReward = false;

	if not self.thresholdFrames then
		self.thresholdFrames = { };
	end

	local thresholdTotal = #thresholds;
	local thresholdCount = 0;
	for _, thresholdInfo in pairs(thresholds) do
		thresholdCount = thresholdCount + 1;
		local thresholdName = "Threshold" .. thresholdCount;
		local thresholdFrame = self.ThresholdBar[thresholdName];
		if not thresholdFrame then
			thresholdFrame = CreateFrame("Frame", nil, self.ThresholdBar, "MonthlyActivitiesThresholdTemplate");
			self.ThresholdBar[thresholdName] = thresholdFrame;
			table.insert(self.thresholdFrames, thresholdFrame);
		end
		
		local xOffset = thresholdInfo.requiredContributionAmount * self.ThresholdBar:GetWidth() / thresholdMax;
		local yOffset = 0;
		thresholdFrame:SetPoint("CENTER", self.ThresholdBar, "BOTTOMLEFT", xOffset, yOffset);

		local showLine = thresholdCount < thresholdTotal;

		thresholdFrame:SetThresholdInfo(thresholdInfo, showLine);

		if self.previousEarnedContribution and self.previousEarnedContribution < thresholdInfo.requiredContributionAmount and earnedThresholdAmount >= thresholdInfo.requiredContributionAmount then
			earnedNewReward = true;
		end
	end

	if earnedNewReward then
		C_PerksProgram.RequestPendingChestRewards();
	end

	self.previousEarnedContribution = earnedThresholdAmount;
end

function MonthlyActivitiesFrameMixin:SetRewardsEarnedAndCollected(allRewardsEarned, allRewardsCollected)
	local restricted = AreMonthlyActivitiesRestricted();

	if self.allRewardsEarned ~= allRewardsEarned or self.restricted ~= restricted then
		self.allRewardsEarned = allRewardsEarned;
		self.restricted = restricted;

		self.RestrictedText:SetShown(restricted);

		if restricted then
			self.BarComplete:SetAlpha(0);
			self.ThresholdBar:Hide();
		elseif allRewardsEarned then
			self.BarComplete.FadeInAnim:Play();
			self.ThresholdBar.FadeOutAnim:Play();
		else
			self.BarComplete.FadeInAnim:Stop();
			self.ThresholdBar.FadeOutAnim:Stop();
			self.BarComplete:SetAlpha(0);
			self.ThresholdBar:SetAlpha(1);
			self.ThresholdBar:Show();
		end
	end

	self.BarComplete.AllRewardsCollectedText:SetShown(allRewardsEarned and allRewardsCollected);
	self.BarComplete.PendingRewardsText:SetShown(allRewardsEarned and not allRewardsCollected);

	local factionGroup = UnitFactionGroup("player");
	local tradingPostLocation = factionGroup == "Alliance" and MONTHLY_ACTIVITIES_TRADING_POST_ALLIANCE or MONTHLY_ACTIVITIES_TRADING_POST_HORDE;
	self.BarComplete.PendingRewardsText:SetText(MONTHLY_ACTIVITIES_PENDING_REWARDS:format(tradingPostLocation));

	local pendingRewardsChestAtlas = factionGroup == "Alliance" and "activities-chest-sw" or "activities-chest-org";
	self.BarComplete.PendingRewardsChest:SetAtlas(pendingRewardsChestAtlas, TextureKitConstants.UseAtlasSize);
	self.BarComplete.PendingRewardsChest:SetShown(allRewardsEarned and not allRewardsCollected);

	local pendingRewardsChestGlowAtlas = factionGroup == "Alliance" and "activities-chest-sw-glow" or "activities-chest-org-glow";
	self.BarComplete.PendingRewardsChestGlow:SetAtlas(pendingRewardsChestGlowAtlas, TextureKitConstants.UseAtlasSize);
	self.BarComplete.PendingRewardsChestGlow:SetShown(allRewardsEarned and not allRewardsCollected);

	if not self.BarComplete.PendingRewardsChestGlowPulse:IsPlaying() then
		self.BarComplete.PendingRewardsChestGlowPulse:Play();
	end
end

function MonthlyActivitiesFrameMixin:UpdateTime(displayMonthName, secondsRemaining)
	local text = MonthlyActivitiesFrameMixin.TimeLeftFormatter:Format(secondsRemaining);
	self.TimeLeft:SetText(MONTHLY_ACTIVITIES_DAYS:format(text));

	if displayMonthName and #displayMonthName > 0 then
		self.Month:SetText(displayMonthName);
	else
		self.Month:SetText(ACTIVITIES_MONTH_NAMES[currentCalendarTime.month]);
	end
end

function MonthlyActivitiesFrameMixin:ScrollToPerksActivityID(activityID)
	local scrollBox = self.ScrollBox;
	local dataProvider = scrollBox:GetDataProvider();
	if dataProvider then
		local function SelectElement(elementData) return elementData.id == activityID; end
		scrollBox:ScrollToElementDataByPredicate(SelectElement, ScrollBoxConstants.AlignCenter, ScrollBoxConstants.NoScrollInterpolation);
	end
end

MonthlyActivitiesFrameMixin.TimeLeftFormatter = CreateFromMixins(SecondsFormatterMixin);
MonthlyActivitiesFrameMixin.TimeLeftFormatter:Init(0, SecondsFormatter.Abbreviation.OneLetter, false, true);
MonthlyActivitiesFrameMixin.TimeLeftFormatter:SetStripIntervalWhitespace(true);
function MonthlyActivitiesFrameMixin.TimeLeftFormatter:GetMinInterval(seconds)
	return SecondsFormatter.Interval.Minutes;
end

function MonthlyActivitiesFrameMixin.TimeLeftFormatter:GetDesiredUnitCount(seconds)
	return 2;
end


-- External API
function MonthlyActivitiesFrame_OpenFrame()
	EJ_ContentTab_Select(EncounterJournal.MonthlyActivitiesTab:GetID());
	NavBar_Reset(EncounterJournal.navBar);
end

function MonthlyActivitiesFrame_OpenFrameToActivity(activityID)
	if ( not C_PlayerInfo.IsTravelersLogAvailable() ) then
		return;
	end

	if ( not EncounterJournal:IsShown() ) then
		EncounterJournal_OpenJournal();
	end
	MonthlyActivitySelected = activityID;
	MonthlyActivitiesFrame_OpenFrame();
	EncounterJournal.MonthlyActivitiesFrame:ScrollToPerksActivityID(activityID);
	EncounterJournal.MonthlyActivitiesFrame:UpdateActivities(ScrollBoxConstants.RetainScrollPosition);
end

-- MonthlyActivitiesRewardButton
MonthlyActivitiesRewardButtonMixin = { };

function MonthlyActivitiesRewardButtonMixin:OnLoad()
	self:SetNormalAtlas("activities-reward-border");
	self:SetHighlightAtlas("activities-reward-border");
	self:SetPushedAtlas("activities-reward-border");
	self.NormalTexture:ClearAllPoints();
	self.NormalTexture:SetAllPoints(self);
	self.IconBorder:SetAlpha(0);
	self.HighlightTexture:SetAlpha(0.3);
end

function MonthlyActivitiesRewardButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:SetItemByID(self:GetItemID());
end

function MonthlyActivitiesRewardButtonMixin:OnLeave()
	GameTooltip:Hide();
	ResetCursor();
end

function MonthlyActivitiesRewardButtonMixin:OnClick()
	if ( IsModifiedClick() ) then
		HandleModifiedItemClick(self.itemLink);
	end
end

function MonthlyActivitiesRewardButtonMixin:OnUpdate()
	if GameTooltip:IsOwned(self) then
		if IsModifiedClick("DRESSUP") then
			ShowInspectCursor();
		else
			ResetCursor();
		end
	end
end
