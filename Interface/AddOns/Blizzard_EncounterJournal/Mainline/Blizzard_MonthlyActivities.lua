-------------------------------------------------
--------------Monthly Activities Panel Func--------------
-------------------------------------------------

local MonthlyActivityFilterSelection;
local MonthlyActivitySelectedID = nil;

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

local function IsActivityPendingComplete(activityID)
	return EncounterJournal.MonthlyActivitiesFrame:IsActivityPendingComplete(activityID);
end

local function GetPendingCompleteActivityAnimStartTime(activityID)
	return EncounterJournal.MonthlyActivitiesFrame:GetPendingCompleteActivityAnimStartTime(activityID);
end

local function IsTimedActivity(activityData)
	return activityData.eventStartTime ~= nil and activityData.eventEndTime ~= nil;
end

local function HasTimedActivityBegun(activityData)
	if not IsTimedActivity(activityData) then
		return false;
	end
	local currentTime = GetServerTime();
	return currentTime > activityData.eventStartTime;
end

local function HasTimedActivityExpired(activityData)
	if not IsTimedActivity(activityData) then
		return false;
	end
	local currentTime = GetServerTime();
	return currentTime > activityData.eventEndTime;
end

local function IsTimedActivityActive(activityData)
	return HasTimedActivityBegun(activityData) and not HasTimedActivityExpired(activityData);
end

local function GetActivityTimeRemaining(activityData)
	if not IsTimedActivityActive(activityData) then
		return 0;
	end

	local currentTime = GetServerTime();
	return activityData.eventEndTime - currentTime;
end

local function IsTimedActivityCloseToExpiring(activityData)
	if not IsTimedActivityActive(activityData) then
		return false;
	end

	local timeRemaining = GetActivityTimeRemaining(activityData);
	local timeRemainingUnits = ConvertSecondsToUnits(timeRemaining);

	local totalEventTime = activityData.eventEndTime - activityData.eventStartTime;
	local totalEventTimeUnits = ConvertSecondsToUnits(totalEventTime);
	if totalEventTimeUnits.days >= 7 then
		return timeRemainingUnits.days <= 3;
	else
		return timeRemainingUnits.days <= 1;
	end
end

local ActivityTimeRemainingFormatter = CreateFromMixins(SecondsFormatterMixin);
ActivityTimeRemainingFormatter:Init(0, SecondsFormatter.Abbreviation.None, false, true);
function ActivityTimeRemainingFormatter:GetMinInterval(seconds)
	return SecondsFormatter.Interval.Hours;
end

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

-- MonthlyActivityButtonTextContainerMixin
MonthlyActivitiesButtonTextContainerMixin = {};
function MonthlyActivitiesButtonTextContainerMixin:OnLoad()
	self.NameText:SetMaxLines(2);
	self.ConditionsText:SetMaxLines(1);
end

function MonthlyActivitiesButtonTextContainerMixin:GetClockAtlasText(data)
	if data.completed then
		return CreateAtlasMarkup("activities-clock-completed");
	elseif not data.areAllConditionsMet then
		return CreateAtlasMarkup("activities-clock-ineligible");
	elseif IsTimedActivityCloseToExpiring(data) then
		return CreateAtlasMarkup("activities-clock-expiringsoon");
	elseif not IsTimedActivityActive(data) then
		return CreateAtlasMarkup("activities-clock-disabled");
	end
	return CreateAtlasMarkup("activities-clock-standard");
end

function MonthlyActivitiesButtonTextContainerMixin:UpdateTextColor(data)
	local isTimedActivity = IsTimedActivity(data);

	-- NameText
	if data.completed then
		-- Changing font too since GameFontHighlightMedium looked off when colored black
		self.NameText:SetFontObject("GameFontBlackMedium");
		self.NameText:SetTextColor(BLACK_FONT_COLOR:GetRGB());
	else
		self.NameText:SetFontObject("GameFontHighlightMedium");
		if isTimedActivity and HasTimedActivityExpired(data) then
			self.NameText:SetTextColor(LIGHTGRAY_FONT_COLOR:GetRGB());
		else
			self.NameText:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		end
	end

	-- ConditionsText
	if data.completed then
		self.ConditionsText:SetFontObject("GameFontBlack");
		self.ConditionsText:SetTextColor(BLACK_FONT_COLOR:GetRGB());
	else
		self.ConditionsText:SetFontObject("GameFontNormal");
		if isTimedActivity and not IsTimedActivityActive(data) then
			self.ConditionsText:SetTextColor(LIGHTGRAY_FONT_COLOR:GetRGB());
		elseif not data.areAllConditionsMet then
			self.ConditionsText:SetTextColor(RED_FONT_COLOR:GetRGB());
		elseif isTimedActivity and IsTimedActivityCloseToExpiring(data) then
			self.ConditionsText:SetTextColor(ORANGE_FONT_COLOR:GetRGB());
		else
			self.ConditionsText:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		end
	end
end

function MonthlyActivitiesButtonTextContainerMixin:UpdateConditionsText(data)
	local conditionsText = "";
	if not data.isChild then
		if IsTimedActivity(data) then
			conditionsText = self:GetClockAtlasText(data);

			if not data.completed and IsTimedActivityCloseToExpiring(data) then
				local timeRemainingText = ActivityTimeRemainingFormatter:Format(GetActivityTimeRemaining(data));
				conditionsText = conditionsText.." "..MONTHLY_ACTIVITIES_EVENT_TIME_LEFT:format(timeRemainingText);
			else
				if data.eventName then
					conditionsText = conditionsText.." "..data.eventName;
				end

				local eventStartTimeUnits = date("*t", data.eventStartTime);
				local eventStartDate = FormatShortDate(eventStartTimeUnits.day, eventStartTimeUnits.month);

				local eventEndTimeUnits = date("*t", data.eventEndTime);
				local eventEndDate = FormatShortDate(eventEndTimeUnits.day, eventEndTimeUnits.month);

				local durationText = MONTHLY_ACTIVITIES_EVENT_DURATION:format(eventStartDate, eventEndDate);
				conditionsText = conditionsText.." "..durationText;
			end
		end

		for index, condition in ipairs(data.conditions) do
			if conditionsText ~= "" then
				conditionsText = conditionsText..", ";
			end
			conditionsText = conditionsText..condition.text;
		end
	end

	self.ConditionsText:SetText(conditionsText);
end

function MonthlyActivitiesButtonTextContainerMixin:UpdateText(data)
	self.NameText:SetText(data.name);
	self:UpdateConditionsText(data);
	self:UpdateTextColor(data);
	self:Layout();
end

-- MonthlyActivitiesButton
MonthlyActivitiesButtonMixin = { };

function MonthlyActivitiesButtonMixin:Init()
	self:GetElementData():SetCollapsed(true);
	self:UpdateButtonState();

	-- Handle scrolling down the list while anims are playing on an existing button
	self.CheckmarkAnim:Stop();
	self.CoinAnim:Stop();

	local data = self:GetData();
	if data then
		EncounterJournal.MonthlyActivitiesFrame:PlayPendingCompleteActivityAnim(self, data.ID);
	end
end

function MonthlyActivitiesButtonMixin:NeedsToAnimatePendingComplete()
	local data = self:GetData();
	if not data then
		return false;
	end

	return EncounterJournal.MonthlyActivitiesFrame:NeedsToAnimatePendingComplete(data.ID);
end

function MonthlyActivitiesButtonMixin:UpdateButtonStateShared()
	local data = self:GetData();
	if not data then
		return;
	end

	local needsToAnimatePendingComplete = self:NeedsToAnimatePendingComplete();

	self:UpdateDesaturated();
	self:UpdateTracked();
	self.TextContainer:UpdateText(data);
	self.Points:SetText(data.points);
	self.Points:SetShown(not data.restricted and not data.completed and data.rewardAvailable and not needsToAnimatePendingComplete);
	self.Checkmark:SetShown(not data.restricted and data.completed and not needsToAnimatePendingComplete);
	local normalActiveTexture = data.ID == MonthlyActivitySelectedID and "activities-incomplete-active" or "activities-incomplete"
	self:SetNormalAtlas(data.completed and "activities-complete" or normalActiveTexture);

	-- Prevent hover state and tooltip when restricted
	self:SetEnabled(not data.restricted);
end

function MonthlyActivitiesButtonMixin:UpdateTracked()
	local data = self:GetData();
	self.TrackingCheckmark:SetShown(data and data.tracked);
end

function MonthlyActivitiesButtonMixin:UpdateButtonState()
	local data = self:GetData();
	if not data then
		return;
	end

	self.CheckmarkFlipbook:SetShown(self:NeedsToAnimatePendingComplete());

	local showRibbon = not data.restricted and (data.completed or data.rewardAvailable);
	local node = self:GetElementData();
	local isCollapsed = node:IsCollapsed();

	if data.hasChild then
		self.HeaderCollapseIndicator:SetAtlas(isCollapsed and "campaign_headericon_closed" or "campaign_headericon_open");
		self.HeaderCollapseIndicator:SetShown(true);
		self.Ribbon:SetShown(false);
		self.RibbonStacked:SetShown(showRibbon);
	else
		self.HeaderCollapseIndicator:SetShown(false);
		self.RibbonStacked:SetShown(false);
		self.Ribbon:SetShown(showRibbon);
	end

	self:UpdateButtonStateShared();
end

function MonthlyActivitiesButtonMixin:OnEnter()
	local data = self:GetData();
	if not data then
		return;
	end

	if data.requirementsList then
		self.showingTooltip = true;
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT");
		self:ShowTooltip();
	end
end

-- Returns true if this method acted on the click
-- This may be needed since if the internal method handles the click in a way which leads to the button being released back to the pool then we won't want to continue after
function MonthlyActivitiesButtonMixin:OnClick_Internal()
	local data = self:GetData();
	if not data then
		return false;
	end

	if ( IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
		local perksActivityLink = C_PerksActivities.GetPerksActivityChatLink(data.ID);
		ChatEdit_InsertLink(perksActivityLink);
		return true;
	end

	if ( IsModifiedClick("QUESTWATCHTOGGLE") ) then
		if data.tracked then
			C_PerksActivities.RemoveTrackedPerksActivity(data.ID);
		elseif self:CanTrack() then
			C_PerksActivities.AddTrackedPerksActivity(data.ID);
		end
		if self.showingTooltip then
			self:ShowTooltip();
		end

		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		return true;
	end

	return false;
end

function MonthlyActivitiesButtonMixin:OnClick()
	if self:OnClick_Internal() then
		return;
	end

	local data = self:GetData();
	if data and data.hasChild then
		local node = self:GetElementData();
		node:ToggleCollapsed();
		self:UpdateButtonState();
	end
end

function MonthlyActivitiesButtonMixin:OnLeave()
	GameTooltip:Hide();
	self.showingTooltip = false;
end

function MonthlyActivitiesButtonMixin:ShowTooltip()
	local data = self:GetData();
	if not data then
		return;
	end

	GameTooltip_SetTitle(GameTooltip, data.name, NORMAL_FONT_COLOR, true);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);

	if #data.description > 0 then
		GameTooltip:AddLine(data.description, 1, 1, 1, true);
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
	end

	for _, requirement in ipairs(data.requirementsList) do
		local tooltipLine = requirement.requirementText;
		tooltipLine = string.gsub(tooltipLine, " / ", "/");
		local color = not requirement.completed and WHITE_FONT_COLOR or DISABLED_FONT_COLOR;
		GameTooltip:AddLine(tooltipLine, color.r, color.g, color.b, true);
	end

	local conditionLines = {};
	local function AddConditionLine(text, r, g, b)
		table.insert(conditionLines, {
			text = text,
			r = r,
			g = g,
			b = b,
		});
	end

	if not data.completed and IsTimedActivity(data) then
		if not HasTimedActivityBegun(data) then
			AddConditionLine(MONTHLY_ACTIVITIES_EVENT_NOT_BEGUN, 1, 0, 0);
		elseif HasTimedActivityExpired(data) then
			AddConditionLine(MONTHLY_ACTIVITIES_EVENT_EXPIRED, 1, 0, 0);
		end
	end

	for index, condition in ipairs(data.conditions) do
		AddConditionLine(condition.text, 1, condition.isMet and 1 or 0, condition.isMet and 1 or 0);
	end

	if #conditionLines > 0 then
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		for index, conditionLine in ipairs(conditionLines) do
			GameTooltip:AddLine(conditionLine.text, conditionLine.r, conditionLine.g, conditionLine.b);
		end
	end

	if data.tracked then
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip:AddLine(MONTHLY_ACTIVITIES_UNTRACK, 0, 1, 0);
	elseif self:CanTrack() then
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip:AddLine(MONTHLY_ACTIVITIES_TRACK, 0, 1, 0);
	end

	GameTooltip:Show();
	EventRegistry:TriggerEvent("MonthlyActivities.ActivityTooltipShown", GameTooltip, data);
end

function MonthlyActivitiesButtonMixin:GetData()
	local node = self:GetElementData();
	if not node then
		return nil;
	end
	return node:GetData();
end

function MonthlyActivitiesButtonMixin:CanTrack()
	local data = self:GetData();
	if not data then
		return false;
	end

	if IsTimedActivity(data) and HasTimedActivityExpired(data) then
		return false;
	end

	return not data.completed;
end

function MonthlyActivitiesButtonMixin:UpdateDesaturatedShared()
	local desaturate = false;
	local data = self:GetData();
	if data then
		desaturate = not data.completed and HasTimedActivityExpired(data);
	end

	self.TrackingCheckmark:SetDesaturated(desaturate);
	self.Checkmark:SetDesaturated(desaturate);
	self.NormalTexture:SetDesaturated(desaturate);
	self.HighlightTexture:SetDesaturated(desaturate);
	self.Points:SetFontObject(desaturate and "GameFontDisableMed2" or "GameFontHighlightMed2");

	return desaturate;
end

function MonthlyActivitiesButtonMixin:UpdateDesaturated()
	local desaturate = self:UpdateDesaturatedShared();
	self.Coin:SetDesaturated(desaturate);
	self.Ribbon:SetDesaturated(desaturate);
	self.RibbonStacked:SetDesaturated(desaturate);
	self.HeaderCollapseIndicator:SetDesaturated(desaturate);
end

function MonthlyActivitiesButtonMixin:GetCheckmarkAnimDuration()
	return self.CheckmarkAnim:GetDuration();
end

-- Make sure to call the ActivitiesFrame's PlayPendingCompleteActivityAnim first so all pending complete anims can sync up
function MonthlyActivitiesButtonMixin:PlayPendingCompleteAnim(timeOffset)
	self.CoinAnim:Restart(false, timeOffset);
	self.CheckmarkAnim:Restart(false, timeOffset);
	PlaySound(SOUNDKIT.TRADING_POST_UI_COMPLETED_ACTIVITY);
end

-- MonthlySupersedeActivitiesButton
MonthlySupersedeActivitiesButtonMixin = CreateFromMixins(MonthlyActivitiesButtonMixin);

function MonthlySupersedeActivitiesButtonMixin:Init()
	self:UpdateButtonState();
end

function MonthlySupersedeActivitiesButtonMixin:UpdateButtonState()
	MonthlyActivitiesButtonMixin.UpdateButtonStateShared(self);
end

function MonthlySupersedeActivitiesButtonMixin:OnClick()
	MonthlyActivitiesButtonMixin.OnClick_Internal(self);
end

function MonthlySupersedeActivitiesButtonMixin:UpdateDesaturated()
	MonthlyActivitiesButtonMixin.UpdateDesaturatedShared(self);
end

-- MonthlyActivitiesThresholdMixin
MonthlyActivitiesThresholdMixin = { };
function MonthlyActivitiesThresholdMixin:SetCurrentPoints(points)
	self.RewardCurrency:SetCurrentPoints(points);

	local aboveThreshold = points >= self.thresholdInfo.requiredContributionAmount;

	self.LineIncomplete:SetShown(not aboveThreshold and self.showLine);
	self.LineComplete:SetShown(aboveThreshold and self.showLine);

	local initialSet = self.aboveThreshold == nil;
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
		self.RewardItem:SetRewardItem(thresholdInfo.itemReward);
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

function MonthlyActivitiesFilterListButtonMixin:OnButtonStateChanged()
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

	ScrollUtil.InitScrollBoxWithScrollBar(self.ScrollBox, self.ScrollBar, view);
	local scrollBoxAnchorsWithBar = {
		CreateAnchor("TOPLEFT", 0, 0),
		CreateAnchor("BOTTOMRIGHT", -20, 0);
	};
	local scrollBoxAnchorsWithoutBar = {
		CreateAnchor("TOPLEFT", 0, 0),
		CreateAnchor("BOTTOMRIGHT", 0, 0);
	};
	ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar);

	local function OnSelectionChanged(o, elementData, selected)
		local button = self.ScrollBox:FindFrame(elementData);
		if button then
			button:SetSelected(selected);
		end

		if selected then
			self.ScrollBox:ScrollToElementData(elementData, ScrollBoxConstants.AlignNearest);
		end

		if elementData.filter == self:GetFilterSetting() then
			return;
		end
		self:SetFilterSetting(elementData.filter);
		local activitiesInfo = C_PerksActivities.GetPerksActivitiesInfo();
		EncounterJournal.MonthlyActivitiesFrame:SetActivities(activitiesInfo.activities, ScrollBoxConstants.DiscardScrollPosition);
		EncounterJournal.MonthlyActivitiesFrame:CollapseAllMonthlyActivities();
	end;

	MonthlyActivityFilterSelection = ScrollUtil.AddSelectionBehavior(self.ScrollBox);
	MonthlyActivityFilterSelection:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, OnSelectionChanged, self);
end

local currentFilterSetting = ALL;
function MonthlyActivitiesFilterListMixin:SetFilterSetting(newFilterSetting)
	currentFilterSetting = newFilterSetting;
end

function MonthlyActivitiesFilterListMixin:GetFilterSetting()
	return currentFilterSetting;
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

local MonthlyActivitiesFrameEvents =
{
	"PERKS_ACTIVITIES_TRACKED_UPDATED",
	"PERKS_ACTIVITIES_UPDATED",
	"CHEST_REWARDS_UPDATED_FROM_SERVER",
	"PERKS_ACTIVITY_COMPLETED",
	"PERKS_ACTIVITIES_TRACKED_LIST_CHANGED",
};

function MonthlyActivitiesFrameMixin:OnLoad()
	self:ResetCachedPendingCompleteActivities();

	-- Anchors can't be set on BarFill in layout, has to be OnLoad
	self.ThresholdBar.BarFillGlow:SetPoint("LEFT", self.ThresholdBar.BarFill, "LEFT", 0, 0);
	self.ThresholdBar.BarFillGlow:SetPoint("RIGHT", self.ThresholdBar.BarFill, "RIGHT", 0, 0);
	self.ThresholdBar.BarEnd:SetPoint("CENTER", self.ThresholdBar.BarFill, "RIGHT", 0, 0);

	local DefaultPad = 0;
	local DefaultSpacing = 0;
	local indent = 32;
	local view = CreateScrollBoxListTreeListView(indent, DefaultPad, DefaultPad, DefaultPad, DefaultPad, DefaultSpacing);
	view:SetPanExtent(20);

	local function Initializer(button, node)
		button:Init();
	end

	view:SetElementFactory(function(factory, node)
		local data = node:GetData();
		local activityTemplate = data.isChild == true and "MonthlySupersedeActivitiesButtonTemplate" or "MonthlyActivitiesButtonTemplate";
		factory(activityTemplate, Initializer);
	end);
	ScrollUtil.InitScrollBoxWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.FilterList:UpdateFilters();

	C_PerksProgram.RequestPendingChestRewards();
end

function MonthlyActivitiesFrameMixin:CollapseAllMonthlyActivities()
	local dataProvider = self.ScrollBox:GetDataProvider();
	if dataProvider then
		dataProvider:CollapseAll();
	end
end

function MonthlyActivitiesFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, MonthlyActivitiesFrameEvents);

	self.ScrollBox:ScrollToBegin();
	self:UpdateActivities();
end

function MonthlyActivitiesFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, MonthlyActivitiesFrameEvents);

	self:UpdateBarTargetValue();
	if self.targetValue then
		self:SetCurrentPoints(self.targetValue);
	end

	self:ResetCachedPendingCompleteActivities();
	C_PerksActivities.ClearPerksActivitiesPendingCompletion();

	if self.progressionSoundHandle then
		StopSound(self.progressionSoundHandle);
		self.progressionSoundHandle = nil;
	end

	local helpPlate = MonthlyActivities_HelpPlate;
	if ( helpPlate and HelpPlate_IsShowing(helpPlate) ) then
		HelpPlate_Hide(false);
	end

	self:SetSelectedActivityID(nil);
end

function MonthlyActivitiesFrameMixin:OnEvent(event, ...)
	if ( event == "PERKS_ACTIVITIES_UPDATED" or event == "PERKS_ACTIVITIES_TRACKED_LIST_CHANGED" ) then
		local activitiesInfo = C_PerksActivities.GetPerksActivitiesInfo();
		self:UpdateActivities(ScrollBoxConstants.RetainScrollPosition, activitiesInfo);
	elseif ( event == "PERKS_ACTIVITIES_TRACKED_UPDATED" ) then
		local perksActivitiesTracked = C_PerksActivities.GetTrackedPerksActivities();
		local trackedActivityIDs = perksActivitiesTracked.trackedIDs;
		local dataProvider = self.ScrollBox:GetDataProvider();
		local excludeCollapsed = false;
		dataProvider:ForEach(function(elementData)
			local data = elementData:GetData();
			data.tracked = tContains(trackedActivityIDs, data.ID);
		end, excludeCollapsed);
		self.ScrollBox:ForEachFrame(function(frame, elementData)
			frame:UpdateTracked();
		end);

		if MonthlyActivitySelectedID and not tContains(trackedActivityIDs, MonthlyActivitySelectedID) then
			self:SetSelectedActivityID(nil);
		end
	elseif ( event == "CHEST_REWARDS_UPDATED_FROM_SERVER" ) then
		self:UpdateActivities(ScrollBoxConstants.RetainScrollPosition);
		self:CollapseAllMonthlyActivities();
	elseif ( event == "PERKS_ACTIVITY_COMPLETED" ) then
		self.ScrollBox:ScrollToBegin();
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

	local earnedThresholdAmount = 0;
	for _, activity in pairs(activitiesInfo.activities) do
		if activity.completed then
			earnedThresholdAmount = earnedThresholdAmount + activity.thresholdContributionAmount;
		end
	end
	earnedThresholdAmount = math.min(earnedThresholdAmount, thresholdMax);

	local pendingCompletionIDs = C_PerksActivities.GetPerksActivitiesPendingCompletion().pendingIDs;
	for _, id in ipairs(pendingCompletionIDs) do
		self.pendingCompleteActivities[id] = true;
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

	local lastPoints = tonumber(GetCVar("perksActivitiesLastPoints"));
	self:SetCurrentPoints(lastPoints);

	if earnedThresholdAmount ~= lastPoints then
		self.pendingTargetValue = earnedThresholdAmount;
	end
end

function MonthlyActivitiesFrameMixin:UpdateBarTargetValue(playSfx)
	if self.pendingTargetValue then
		self.targetValue = self.pendingTargetValue;
		self.pendingTargetValue = nil;

		if playSfx then
			self.progressionSFXQueued = true;
		end
	end
end

function MonthlyActivitiesFrameMixin:ClearCurrentAnimWindow()
	if not self.pendingCompleteCurrentAnimWindow then
		return;
	end

	if self.pendingCompleteCurrentAnimWindow.timer then
		self.pendingCompleteCurrentAnimWindow.timer:Cancel();
	end

	table.insert(self.pendingCompleteFinishedAnimWindows, self.pendingCompleteCurrentAnimWindow);

	self.pendingCompleteCurrentAnimWindow = nil;
end

function MonthlyActivitiesFrameMixin:ResetCachedPendingCompleteActivities()
	self.pendingCompleteActivities = {};
	self:ClearCurrentAnimWindow();
	self.pendingCompleteFinishedAnimWindows = {};
end

function MonthlyActivitiesFrameMixin:IsActivityPendingComplete(activityID)
	return self.pendingCompleteActivities[activityID];
end

function MonthlyActivitiesFrameMixin:HasPendingCompleteActivityFinishedAnimating(activityID)
	for _, animWindow in pairs(self.pendingCompleteFinishedAnimWindows) do
		if animWindow.activityIDs[activityID] then
			return true;
		end
	end
	return false;
end

function MonthlyActivitiesFrameMixin:NeedsToAnimatePendingComplete(activityID)
	return self:IsActivityPendingComplete(activityID) and not self:HasPendingCompleteActivityFinishedAnimating(activityID);
end

function MonthlyActivitiesFrameMixin:GetPendingCompleteActivityAnimStartTime(activityID)
	if self.pendingCompleteCurrentAnimWindow and self.pendingCompleteCurrentAnimWindow.activityIDs[activityID] then
		return self.pendingCompleteCurrentAnimWindow.startTime;
	end

	for _, animWindow in pairs(self.pendingCompleteFinishedAnimWindows) do
		if animWindow.activityIDs[activityID] then
			return animWindow.startTime;
		end
	end

	return nil;
end

function MonthlyActivitiesFrameMixin:PlayPendingCompleteActivityAnim(activityFrame, activityID)
	if not self:IsActivityPendingComplete(activityID) then
		return;
	end

	-- If this activity already animated then we shouldn't animate
	if self:HasPendingCompleteActivityFinishedAnimating(activityID) then
		return;
	end

	-- If we don't already have a current animation window then make one
	-- These animation windows represent groups of pending complete activities all animating together
	-- The idea is that all pending complete activities will animate together and new complete activities can join late if need be
	-- Then once a window is complete we animate the bar and if we get new completions after that we'll start a new window
	if not self.pendingCompleteCurrentAnimWindow then
		local timerDuration = activityFrame:GetCheckmarkAnimDuration();
		self.pendingCompleteCurrentAnimWindow = {
			startTime = GetTime(),
			timer = C_Timer.NewTimer(timerDuration, function()
				local playSfx = true;
				self:UpdateBarTargetValue(playSfx);
				self:ClearCurrentAnimWindow();
			end),
			activityIDs = {},
		};
	end
	self.pendingCompleteCurrentAnimWindow.activityIDs[activityID] = true;

	-- Offset animations based on elapsed time in the current window so that all animations in a given window sync up
	local animWindowElapsedTimeOffset = GetTime() - self.pendingCompleteCurrentAnimWindow.startTime;
	activityFrame:PlayPendingCompleteAnim(animWindowElapsedTimeOffset);
	self:SetAnimating(true);
end

local function FindActivity(activityID, activities)	
	local function CheckChildren(activityID, activity)
		if activity and activity.child then
			if activity.child.ID == activityID then
				return activity.child;
			else
				return CheckChildren(activityID, activity.child);
			end
		end
		return nil;
	end

	for _, activity in pairs(activities) do
		if activity.ID == activityID then
			return activity;
		else
			local returnActivity = CheckChildren(activityID, activity);
			if returnActivity then
				return returnActivity;
			end
		end
	end
	return nil;
end

local function BuildActivityTree(activities)
	local parentActivities = {};
	local childActivities = {};

	for _, activity in pairs(activities) do
		if activity.supersedes == 0 then
			table.insert(parentActivities, activity);
		else
			table.insert(childActivities, activity);
		end
	end
	
	for i = #childActivities, 1, -1 do
		local childActivity = childActivities[i];
		local parentActivityID = childActivity.supersedes;
		local parentActivity = FindActivity(parentActivityID, childActivities);
		if not parentActivity then
			parentActivity = FindActivity(parentActivityID, parentActivities);
		end
		if parentActivity then
			parentActivity.child = childActivity;
			table.remove(childActivities, i);
		end
	end
	if #childActivities > 0 then
		assertsafe(#childActivities == 0, "child activities missing parent");
		for i = #childActivities, 1, -1 do
			local childActivity = childActivities[i];
			local exceptionMessage = ("child activity has no parent: %d"):format(childActivity.ID)
			assertsafe(false, exceptionMessage);
		end
	end

	return parentActivities;
end

--[[
Order that activities should appear once sorted:
0. Pending Completion (completed tasks which still need to animate)
	1. Sort by Anim Start Time (most recent to top)
	2. Sort by points (highest points to the top)
	3. Sort by Alphabetical
1. Close to expiring activities
	1. Sort by end time (expiring soonest to the top)
	2. Sort by In Progress (in progress to the top)
	3. Sort by points (highest points to the top)
	4. Sort by Alphabetical
2. Non-expired In-Progress activities
	1. Sort by end time (expiring soonest to the top)
	2. Sort by points
	3. Sort by Alphabetical
3. Active timed activities
	2. Sort by end time (expiring soonest to the top)
	3. Sort by points
	4. Sort by Alphabetical
4. Non-timed activities
	1. Sort by points
	2. Sort by Alphabetical
5. Not yet begun timed activities
	1. Sort by start time (starting soonest to the top)
	2. Sort by points
	3. Sort by Alphabetical
6. Expired timed activities
	1. Sort by end time (most recently expired to the top)
	2. Sort by points
	3. Sort by Alphabetical
7. Completed activities
	1. Non-timed
		1. Points
		2. Alphabetical
	2. Sort by starting time (earliest to top)
		1. Sort by points
		2. Sort by Alphabetical
--]]
local function ActivitySortFallbackSortComparator(aData, bData)
	-- Fallback to sorting by points and alphabetical
	if aData.points ~= bData.points then
		return aData.points > bData.points;
	end

	return aData.name < bData.name;
end
local function ActivitySortComparator(a, b)
	if not a or not b then
		return a ~= nil;
	end

	local aData = a:GetData();
	local bData = b:GetData();

	-- Put pending complete to the top
	local aIsPendingComplete, bIsPendingComplete = IsActivityPendingComplete(aData.ID), IsActivityPendingComplete(bData.ID)
	if aIsPendingComplete ~= bIsPendingComplete then
		return aIsPendingComplete;
	elseif aIsPendingComplete and bIsPendingComplete then
		-- Sort by animation start times putting most recent to the top
		-- If a frame has no anim start time yet then assume it will be most recent once it does start animating
		-- We want this sorting so animating frames appear at the top and are seen when we force a scroll to the top when new stuff is completed and begins to animate
		local aAnimStartTime, bAnimStartTime = GetPendingCompleteActivityAnimStartTime(aData.ID), GetPendingCompleteActivityAnimStartTime(bData.ID);
		if not aAnimStartTime and bAnimStartTime then
			return true;
		elseif aAnimStartTime and not bAnimStartTime then
			return false;
		elseif aAnimStartTime and bAnimStartTime then
			return aAnimStartTime > bAnimStartTime;
		end

		return ActivitySortFallbackSortComparator(aData, bData);
	end

	-- Put completed to bottom
	local aIsTimed, bIsTimed = IsTimedActivity(aData), IsTimedActivity(bData);
	local aIsNotTimed, bIsNotTimed = not aIsTimed, not bIsTimed;
	if aData.completed ~= bData.completed then
		return bData.completed;
	elseif aData.completed and bData.completed then
		-- Put non-timed activities to top
		if aIsNotTimed ~= bIsNotTimed then
			return aIsNotTimed;
		elseif aIsNotTimed and bIsNotTimed then
			return ActivitySortFallbackSortComparator(aData, bData);
		end

		-- Put earliest starting timed activities next
		if aData.eventStartTime ~= bData.eventStartTime then
			return aData.eventStartTime < bData.eventStartTime;
		end

		return ActivitySortFallbackSortComparator(aData, bData);
	end

	-- Put close to expiring activities to the top
	local aIsCloseToExpiring, bIsCloseToExpiring = IsTimedActivityCloseToExpiring(aData), IsTimedActivityCloseToExpiring(bData);
	if aIsCloseToExpiring ~= bIsCloseToExpiring then
		return aIsCloseToExpiring;
	elseif aIsCloseToExpiring and bIsCloseToExpiring then
		-- Put expiring soonest to top
		if aData.eventEndTime ~= bData.eventEndTime then
			return aData.eventEndTime < bData.eventEndTime;
		end

		-- Put in progress next
		if aData.inProgress ~= bData.inProgress then
			return aData.inProgress;
		end

		return ActivitySortFallbackSortComparator(aData, bData);
	end

	-- Put Non-expired In-Progress activities to top
	local aHasExpired, bHasExpired = HasTimedActivityExpired(aData), HasTimedActivityExpired(bData);
	local aIsInProgressAndNotExpired = aData.inProgress and not aHasExpired;
	local bIsInProgressAndNotExpired = bData.inProgress and not bHasExpired;
	if aIsInProgressAndNotExpired ~= bIsInProgressAndNotExpired then
		return aIsInProgressAndNotExpired;
	elseif aIsInProgressAndNotExpired and bIsInProgressAndNotExpired then
		-- Put expiring soonest to top
		if aIsTimed ~= bIsTimed then
			return aIsTimed;
		elseif aIsTimed and bIsTimed then
			if aData.eventEndTime ~= bData.eventEndTime then
				return aData.eventEndTime < bData.eventEndTime;
			end
		end

		return ActivitySortFallbackSortComparator(aData, bData);
	end

	-- Put active timed activities next
	local aIsTimedAndActive, bIsTimedAndActive = IsTimedActivityActive(aData), IsTimedActivityActive(bData);
	if aIsTimedAndActive ~= bIsTimedAndActive then
		return aIsTimedAndActive;
	elseif aIsTimedAndActive and aIsTimedAndActive then
		-- Put expiring soonest to top
		if aData.eventEndTime ~= bData.eventEndTime then
			return aData.eventEndTime < bData.eventEndTime;
		end

		return ActivitySortFallbackSortComparator(aData, bData);
	end

	-- Put non-timed activities next
	if aIsNotTimed ~= bIsNotTimed then
		return aIsNotTimed;
	elseif aIsNotTimed and bIsNotTimed then
		return ActivitySortFallbackSortComparator(aData, bData);
	end

	-- Put timed activities which haven't begun yet
	local aHasNotBegun, bHasNotBegun = not HasTimedActivityBegun(aData), not HasTimedActivityBegun(bData);
	if aHasNotBegun ~= bHasNotBegun then
		return aHasNotBegun;
	elseif aHasNotBegun and bHasNotBegun then
		-- Put starting soonest to top
		if aData.eventStartTime ~= bData.eventStartTime then
			return aData.eventStartTime < bData.eventStartTime;
		end

		return ActivitySortFallbackSortComparator(aData, bData);
	end

	-- Put expired timed activities next
	if aHasExpired ~= bHasExpired then
		return aHasExpired;
	elseif aHasExpired and bHasExpired then
		-- Put most recently expired to top
		if aData.eventEndTime ~= bData.eventEndTime then
			return aData.eventEndTime > bData.eventEndTime;
		end

		return ActivitySortFallbackSortComparator(aData, bData);
	end

	return ActivitySortFallbackSortComparator(aData, bData);
end

local function ActivityConditionSortComparator(lhs, rhs)
	if lhs.uiPriority ~= rhs.uiPriority then
		return lhs.uiPriority > rhs.uiPriority;
	end

	return lhs.text < rhs.text;
end

function MonthlyActivitiesFrameMixin:SetActivities(activities, retainScrollPosition)
	local selected = MonthlyActivityFilterSelection:GetFirstSelectedElementData();
	local selectedFilter = selected and selected.filter;
	local restricted = AreMonthlyActivitiesRestricted();

	local activityTree = BuildActivityTree(activities);

	local function DataProviderAdd(dataProvider, activity)
		activity.rewardAvailable = not self.allRewardsEarned;
		activity.thresholdMax = self.thresholdMax;
		activity.restricted = restricted;
		activity.name = activity.activityName;
		activity.hasChild = activity.hasChild or false;
		activity.isChild = activity.isChild or false;
		activity.points = activity.thresholdContributionAmount;

		table.sort(activity.conditions, ActivityConditionSortComparator);

		dataProvider:Insert(activity);
	end
	local dataProvider = CreateTreeDataProvider();

	for _, activity in pairs(activityTree) do
		local activityFiltered = selectedFilter ~= ALL;
		for _, tag in pairs(activity.tagNames) do
			if tag == selectedFilter then
				activityFiltered = false;
			end
		end

		if not activityFiltered then
			DataProviderAdd(dataProvider, activity);

			local function FindNode(ID)
				return dataProvider:FindElementDataByPredicate(function(node)
					local data = node:GetData();
					return data.ID == ID;
				end, TreeDataProviderConstants.IncludeCollapsed);
			end
			local parentNode = FindNode(activity.ID);

			local child = activity.child;
			while child do
				local parentData = parentNode:GetData();
				if parentData.completed  then
					DataProviderAdd(dataProvider, child);
					parentNode = FindNode(child.ID);
				elseif child.completed then
					DataProviderAdd(dataProvider, child);
				else
					child.isChild = true;
					DataProviderAdd(parentNode, child);
					parentData.hasChild = true;
				end
				child = child.child;
			end
		end
	end

	dataProvider:SetSortComparator(ActivitySortComparator);
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
	if barValue >= self.targetValue then
		if self.progressionSoundHandle then
			StopSound(self.progressionSoundHandle);
			self.progressionSoundHandle = nil;
		end

		if self.allRewardsEarned then
			PlaySound(SOUNDKIT.TRADING_POST_UI_COMPLETED_PROGRESS);
		else
			PlaySound(SOUNDKIT.TRADING_POST_UI_ACTIVITY_PROGRESSION_STOP);
		end
	end

	self:SetCurrentPoints(barValue);
end

function MonthlyActivitiesFrameMixin:SetCurrentPoints(barValue)
	self.ThresholdBar:SetValue(barValue);
	self.ThresholdBar.BarFillGlow:SetTexCoord(self.ThresholdBar.BarFill:GetTexCoord());

	for _, thresholdFrame in pairs(self.thresholdFrames) do
		thresholdFrame:SetCurrentPoints(barValue);
	end

	self.ThresholdBar.TextContainer.ProgressText:SetText(MONTHLY_ACTIVITIES_PROGRESS_TEXT:format(barValue, self.thresholdMax));
	self.ThresholdBar.BarEnd:SetShown(barValue > 0);

	local allRewardsEarned = barValue >= self.thresholdMax;
	self:SetRewardsEarnedAndCollected(allRewardsEarned, self.allRewardsCollected);

	if self.targetValue and barValue >= self.targetValue then
		SetCVar("perksActivitiesLastPoints", self.targetValue);
		self.targetValue = nil;
	end

	if not self.targetValue then
		self:SetAnimating(false);
	end
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
	self.HeaderContainer.TimeLeft:SetText(MONTHLY_ACTIVITIES_DAYS:format(text));

	if displayMonthName and #displayMonthName > 0 then
		self.HeaderContainer.Month:SetText(displayMonthName);
	else
		local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime();
		self.HeaderContainer.Month:SetText(ACTIVITIES_MONTH_NAMES[currentCalendarTime.month]);
	end
end

function MonthlyActivitiesFrameMixin:SetSelectedActivityID(activityID)
	local scrollBox = self.ScrollBox;
	local view = scrollBox:GetView();
	if view then
		local function FindFrame(ID)
			return view:FindFrameByPredicate(function(frame)
				return frame.id == ID;
			end);
		end

		local oldSelectedFrame = MonthlyActivitySelectedID and FindFrame(MonthlyActivitySelectedID);
		local newSelectedFrame = FindFrame(activityID);

		MonthlyActivitySelectedID = activityID;
		if oldSelectedFrame ~= newSelectedFrame then
			if oldSelectedFrame then
				oldSelectedFrame:UpdateButtonState();
			end
			if newSelectedFrame then
				newSelectedFrame:UpdateButtonState();
			end
		end
	end
end

function MonthlyActivitiesFrameMixin:ScrollToPerksActivityID(activityID)
	local scrollBox = self.ScrollBox;
	local function FindNode(ID)
		local dataProvider = scrollBox:GetDataProvider();
		if dataProvider then
			return dataProvider:FindElementDataByPredicate(function(node)
				local data = node:GetData();
				return data.ID == ID;
			end, TreeDataProviderConstants.IncludeCollapsed);
		end
	end
	local selectedNode = FindNode(activityID);
	if not selectedNode then
		-- Reset filter to ALL
		MonthlyActivityFilterSelection:SelectFirstElementData();
		selectedNode = FindNode(activityID);
	end
	if selectedNode then
		scrollBox:ScrollToElementData(selectedNode, ScrollBoxConstants.AlignCenter);
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

	MonthlyActivitiesFrame_OpenFrame();
	
	EncounterJournal.MonthlyActivitiesFrame:CollapseAllMonthlyActivities();
	EncounterJournal.MonthlyActivitiesFrame:ScrollToPerksActivityID(activityID);
	EncounterJournal.MonthlyActivitiesFrame:SetSelectedActivityID(activityID);
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

function MonthlyActivitiesRewardButtonMixin:SetRewardItem(itemId)
	self:SetItem(itemId);
	self.rewardItemId = itemId;
end

function MonthlyActivitiesRewardButtonMixin:OnEnter()
	if self.rewardItemId then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		local tooltipInfo = CreateBaseTooltipInfo("GetItemByID", self.rewardItemId);
		tooltipInfo.excludeLines = {
				Enum.TooltipDataLineType.SellPrice,
		};
		GameTooltip:ProcessInfo(tooltipInfo);
	end
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

-- MonthlyActivitiesThemeContainerMixin
MonthlyActivitiesThemeContainerMixin = {};

function MonthlyActivitiesThemeContainerMixin:OnLoad()
	local function PositionFrame(frame, point, relativeTo, relativePoint, offsetX, offsetY)
		frame:ClearAllPoints();
		frame:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY);
	end

	PositionFrame(self.FilterList, "CENTER", EncounterJournalMonthlyActivitiesFrame.FilterList, "CENTER", 0, 0);
	PositionFrame(self.Top, "BOTTOM", EncounterJournal, "TOP", 0, -133);
	PositionFrame(self.Bottom, "TOP", EncounterJournal, "BOTTOM", 0, 7);
	PositionFrame(self.Left, "RIGHT", EncounterJournal, "LEFT", 7, -11);
	PositionFrame(self.Right, "LEFT", EncounterJournal, "RIGHT", -6, -11);
end

function MonthlyActivitiesThemeContainerMixin:OnShow()
	local theme = C_PerksActivities.GetPerksUIThemePrefix();
	local atlasPrefix = "perks-theme-"..theme.."-tl-";

	local function SetAtlas(texture, atlasSuffix)
		local atlasName = atlasPrefix..atlasSuffix;
		if not C_Texture.GetAtlasInfo(atlasName) then
			texture:SetTexture(nil);
			return;
		end

		texture:SetAtlas(atlasName, true);
	end

	SetAtlas(self.FilterList, "box");
	SetAtlas(self.Top, "top");
	SetAtlas(self.Bottom, "bottom");
	SetAtlas(self.Left, "left");
	SetAtlas(self.Right, "right");
end