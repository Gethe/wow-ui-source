UIPanelWindows["ContributionCollectionFrame"] = { area = "center", allowOtherPanels = 1 };

ContributionRewardMixin = {};

function ContributionRewardMixin:Setup(rewardID, isEnabled)
	self.rewardID = rewardID;
	self.isEnabled = isEnabled;

	local name, _, icon = GetSpellInfo(rewardID);
	self.Icon:SetTexture(icon);
	self.Icon:SetDesaturated(not isEnabled);
	self.PadLock:SetShown(not isEnabled);
	self.RewardName:SetText(name);
	self:Show();
end

local function GetExtents(...)
	local minX, minY, maxX, maxY;

	for i = 1, select("#", ...) do
		local frame = select(i, ...);
		if frame:IsShown() then
			local frameMinX, frameMinY, frameWidth, frameHeight = frame:GetRect();
			local frameMaxX, frameMaxY = frameMinX + frameWidth, frameMinY + frameHeight;

			minX = not minX and frameMinX or math.min(minX, frameMinX);
			minY = not minY and frameMinY or math.min(minY, frameMinY);
			maxX = not maxX and frameMaxX or math.max(maxX, frameMaxX);
			maxY = not maxY and frameMaxY or math.max(maxY, frameMaxY);
		end
	end

	return minX, minY, maxX, maxY;
end

local function ResizeToFitContents(containerFrame, extraWidth, extraHeight, ...)
	local minX, minY, maxX, maxY = GetExtents(...);
	containerFrame:SetSize(maxX - minX + extraWidth, maxY - minY + extraHeight);
end

function ContributionRewardMixin:OnEnter()
	ContributionBuffTooltip:ClearAllPoints();
	ContributionBuffTooltip:SetPoint("BOTTOMLEFT", self.Icon, "TOPRIGHT", 0, 0);

	local name, _, icon = GetSpellInfo(self.rewardID);

	ContributionBuffTooltip.Icon:SetTexture(icon);
	ContributionBuffTooltip.Name:SetText(name);
	ContributionBuffTooltip.Description:SetText(GetSpellDescription(self.rewardID));

	ContributionBuffTooltip.Footer:SetShown(not self.isEnabled);
	if not self.isEnabled then
		ContributionBuffTooltip.Footer:SetText(CONTRIBUTION_TOOLTIP_UNLOCKED_WHEN_ACTIVE);
		ContributionBuffTooltip.Footer:SetVertexColor(RED_FONT_COLOR:GetRGB());
	end

	-- Must add padding because of the way that the tooltip border frame is built.  Leaving those textures out of this calculation.
	ResizeToFitContents(ContributionBuffTooltip, 20, 20, ContributionBuffTooltip.Icon, ContributionBuffTooltip.Name, ContributionBuffTooltip.Description, ContributionBuffTooltip.Footer);

	ContributionBuffTooltip:Show();
end

function ContributionRewardMixin:OnLeave()
	ContributionBuffTooltip:Hide();
end

ContributionRewardMouseOverMixin = {}

function ContributionRewardMouseOverMixin:OnEnter()
	self:GetParent():OnEnter();
end

function ContributionRewardMouseOverMixin:OnLeave()
	self:GetParent():OnLeave();
end

ContributionStatusMixin = {}

function ContributionStatusMixin:OnLoad()
	self.Bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar"); -- Set to some default texture just to instantiate the bar
	self.Spark:ClearAllPoints();
	self.Spark:SetPoint("CENTER", self.Bar:GetStatusBarTexture(), "RIGHT", 0, 0);
	self.Spark:SetParent(self.Bar);

	self.Bar:ClearAllPoints();
	self.Bar:SetAllPoints(self);
	self.Bar:SetStatusBarColor(1, 1, 1, 1);
	self.Bar.BarBG:SetAtlas("Legionfall_BarBackground");
	self.Bar.IconBG:Hide();

	self.Bar.BarGlow:ClearAllPoints();
	self.Bar.BarGlow:SetPoint("TOPLEFT", self.Bar, "TOPLEFT", -6.0, 4.0);
	self.Bar.BarGlow:SetPoint("BOTTOMRIGHT", self.Bar, "BOTTOMRIGHT", 6.0, -4.0);

	self.Bar.Label:SetPoint("CENTER", self.Bar, "CENTER", 0, 0);
	self.Bar.Label:SetFontObject(GameFontHighlight);

	local SetupBarFrame = function(barFrame)
		barFrame:ClearAllPoints();
		barFrame:SetPoint("TOPLEFT", self.Bar, "TOPLEFT", -7.0, 7.0);
		barFrame:SetPoint("BOTTOMRIGHT", self.Bar, "BOTTOMRIGHT", 7.0, -7.0);

		barFrame:SetAtlas("Legionfall_BarFrame");
	end

	SetupBarFrame(self.Bar.BarFrame);
	SetupBarFrame(self.Bar.BarFrame2);
	SetupBarFrame(self.Bar.BarFrame3);

	self.FullBarFlare1:SetHeight(42);
	self.FullBarFlare2:SetHeight(42);
end

function ContributionStatusMixin:SetContributionID(contributionID)
	self.contributionID = contributionID;
end

function ContributionStatusMixin:Update()
	local state, stateAmount, timeOfNextStateChange = C_ContributionCollector.GetState(self.contributionID);
	local appearance = CONTRIBUTION_APPEARANCE_DATA[state];

	BonusObjectiveTrackerProgressBar_SetValue(self, stateAmount * 100);
	self.AnimValue = stateAmount * 100;

	self.Bar:SetStatusBarAtlas(appearance.statusBarAtlas);
	self.Spark:SetShown(state == Enum.ContributionState.Building and stateAmount > 0 and stateAmount < 1);

	local text;
	self.onlyShowTextOnMouseEnter = false;
	if state == Enum.ContributionState.Active and timeOfNextStateChange then
		local time = math.max(timeOfNextStateChange - GetServerTime(), 60); -- Never display times below 1 minute
		text = CONTRIBUTION_POI_TOOLTIP_REMAINING_ACTIVE_TIME:format(SecondsToTime(time, true, true, 1));
	elseif state == Enum.ContributionState.UnderAttack then
		text = CONTIBUTION_HEALTH_TEXT_WITH_PERCENTAGE:format(FormatPercentage(stateAmount));
	elseif state == Enum.ContributionState.Destroyed then
		text = DISABLED_FONT_COLOR:WrapTextInColorCode(CONTIBUTION_HEALTH_TEXT_WITH_PERCENTAGE:format(FormatPercentage(stateAmount)));
	elseif state == Enum.ContributionState.Building then
		text = FormatPercentage(stateAmount);
		self.onlyShowTextOnMouseEnter = true;
	end

	self.Bar.Label:SetText(text);
	self:UpdateTextVisibility();
end

function ContributionStatusMixin:PlayFlashAnimation()
	PlaySound("UI_72_Buildings_Contribute_Resources", nil, false);
	BonusObjectiveTrackerProgressBar_PlayAnimation(self, self.AnimValue, 1, 15);
end

function ContributionStatusMixin:OnUpdate()
	local timeNow = GetTime();
	if timeNow >= self.nextUpdate then
		self.nextUpdate = timeNow + self.updateDelay;
		self:Update();
	end
end

function ContributionStatusMixin:OnEnter()
	self.isMouseOver = true;
	self:UpdateTextVisibility();
end

function ContributionStatusMixin:OnLeave()
	self.isMouseOver = false;
	self:UpdateTextVisibility();
end

function ContributionStatusMixin:UpdateTextVisibility()
	local shouldShowText = not self.onlyShowTextOnMouseEnter or self.isMouseOver;
	self.Bar.Label:SetShown(shouldShowText);
end

ContributeButtonMixin = {};

function ContributeButtonMixin:OnClick(button)
	PlaySound("UI_72_Buildings_Contribute_Power_Menu_Click");
	self:Disable();
	self:GetParent():Contribute();
end

function ContributeButtonMixin:OnEnter()
	local isEnabled = self:IsEnabled();
	local shouldShowTooltip = isEnabled or (self.contributionResult == Enum.ContributionResult.IncorrectState) or (self.contributionResult == Enum.ContributionResult.FailedConditionCheck);

	if shouldShowTooltip then
		ContributionTooltip:SetOwner(self, "ANCHOR_RIGHT");

		if isEnabled or (self.contributionResult == Enum.ContributionResult.FailedConditionCheck) then
			ContributionTooltip:SetText(CONTRIBUTION_REWARD_TOOLTIP_TITLE, HIGHLIGHT_FONT_COLOR:GetRGBA());
			GameTooltip_AddQuestRewardsToTooltipWithHeader(ContributionTooltip, self.questID, 0, CONTRIBUTION_REWARD_TOOLTIP_TEXT, NORMAL_FONT_COLOR, false);

			local currencyID, requiredCurrency = C_ContributionCollector.GetRequiredContributionAmount(self.contributionID);
			requiredCurrency = BreakUpLargeNumbers(requiredCurrency);
			local currencyName, ownedCurrency = GetCurrencyInfo(currencyID);
			local ownedCurrency = BreakUpLargeNumbers(ownedCurrency);
			local currencyLine = CONTRIBUTION_TOOLTIP_PLAYER_CURRENCY_AMOUNT:format(ownedCurrency, requiredCurrency, currencyName);
			local currencyLineColor = (ownedCurrency >= requiredCurrency) and NORMAL_FONT_COLOR or RED_FONT_COLOR;

			ContributionTooltip.Currency:Show();
			ContributionTooltip.Currency:SetVertexColor(currencyLineColor:GetRGBA());
			ContributionTooltip.Currency:SetText(currencyLine);
		elseif self.contributionResult == Enum.ContributionResult.IncorrectState then
			ContributionTooltip:SetText(CONTRIBUTION_BUTTON_ONLY_WHEN_UNDER_CONSTRUCTION_TOOLTIP, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, 1, true);
			ContributionTooltip.Currency:Hide();
		end

		ContributionTooltip:Show();
	end
end

function ContributionTooltip_CalculatePadding(tooltip)
	local itemWidth, itemHeight, currencyWidth, currencyHeight = 0, 0, 0, 0;

	if tooltip.ItemTooltip:IsShown() then
		itemWidth, itemHeight = tooltip.ItemTooltip:GetSize();
		itemWidth = itemWidth + 9; -- extra padding for this line
	end

	if tooltip.Currency:IsShown() then
		currencyWidth, currencyHeight = tooltip.Currency:GetSize();
		currencyWidth = currencyWidth + 20; -- extra width padding for this line
	end

	local extraWidth = math.max(itemWidth, currencyWidth);
	local extraHeight = itemHeight + currencyHeight;

	local oldPaddingWidth, oldPaddingHeight = tooltip:GetPadding();
	local actualTooltipWidth = tooltip:GetWidth() - oldPaddingWidth;
	local paddingWidth = (actualTooltipWidth <= extraWidth) and extraWidth - actualTooltipWidth or 0;
	local paddingHeight = (extraHeight > 0) and extraHeight + 12 or 0;

	if(math.abs(paddingWidth - oldPaddingWidth) > 0.5 or math.abs(paddingHeight - oldPaddingHeight) > 0.5) then
		tooltip:SetPadding(paddingWidth, paddingHeight);
	end
end

function ContributeButtonMixin:OnLeave()
	ContributionTooltip:Hide();
end

function ContributeButtonMixin:SetContributionID(contributionID)
	self.contributionID = contributionID;
end

function ContributeButtonMixin:Update()
	local result = C_ContributionCollector.GetContributionResult(self.contributionID);
	local canContribute = (result == Enum.ContributionResult.Success);
	self:SetEnabled(canContribute);

	local state = C_ContributionCollector.GetState(self.contributionID);
	self.contributionResult = result;
	self.questID = C_ContributionCollector.GetRewardQuestID(self.contributionID);

	if canContribute or (result == Enum.ContributionResult.FailedConditionCheck) then
		local currencyID, currencyAmount = C_ContributionCollector.GetRequiredContributionAmount(self.contributionID);
		local currencyColorCode = canContribute and HIGHLIGHT_FONT_COLOR_CODE or RED_FONT_COLOR_CODE;
		self:SetCurrencyFromID(currencyID, currencyAmount, CONTIBUTION_REQUIRED_CURRENCY, currencyColorCode);
	else
		self:SetText(CONTRIBUTION_DISABLED);
	end
end

ContributionMixin = {};

function ContributionMixin:OnHide()
	self:StopAnimations();
end

function ContributionMixin:OnReset(pool)
	self:ReleaseRewards();
	FramePool_HideAndClearAnchors(pool, self);

	self.layoutIndex = nil;
	self.contributionID = nil;
	self.stateToAtlas = nil;
end

function ContributionMixin:Setup(layoutIndex, contributionID)
	self.layoutIndex = layoutIndex;
	self.contributionID = contributionID;
	self.stateToAtlas = C_ContributionCollector.GetAtlases(self.contributionID);

	self:Update();
	self:Show();
end

function ContributionMixin:Update()
	local contributionName = C_ContributionCollector.GetName(self.contributionID);
	local contributionDescription = C_ContributionCollector.GetDescription(self.contributionID);
	local state, stateAmount = C_ContributionCollector.GetState(self.contributionID);
	local appearance = CONTRIBUTION_APPEARANCE_DATA[state];

	self.Header.Text:SetText(contributionName);
	self.Description:SetText(contributionDescription);

	self.Header.Background:SetAtlas(appearance.bannerAtlas);
	self.State.Text:SetText(appearance.stateName);
	self.State.Text:SetVertexColor(appearance.stateColor:GetRGB());
	self.State.Border:SetAtlas(appearance.borderAtlas);
	self.State.Icon:SetAtlas(self.stateToAtlas[state] or "");

	self:UpdateRewards();
	self:UpdateStatus();
	self:UpdateContributeButton();
end

function ContributionMixin:Contribute()
	C_ContributionCollector.Contribute(self.contributionID);
end

function ContributionMixin:ReleaseRewards()
	if (self.rewards) then
		for rewardID, reward in pairs(self.rewards) do
			self:GetParent():ReleaseReward(reward);
		end

		self.rewards = nil;
	end
end

function ContributionMixin:FindOrAcquireReward(rewardID)
	if not self.rewards then
		self.rewards = {};
	end

	local reward = self.rewards[rewardID];
	if not reward then
		reward = self:GetParent():AcquireReward();
		self.rewards[rewardID] = reward;
	end

	return reward;
end

function ContributionMixin:UpdateRewards()
	self:ReleaseRewards();
	self:EnumerateRewards(C_ContributionCollector.GetBuffs(self.contributionID));
end

function ContributionMixin:EnumerateRewards(...)
	for i = 1, select("#", ...) do
		self:AddReward(i, select(i, ...));
	end
end

function ContributionMixin:AddReward(index, rewardID)
	local reward = self:FindOrAcquireReward(rewardID);

	reward:SetPoint("TOPLEFT", self.Description, "BOTTOMLEFT", 0, (index - 1) * -45);

	local state, stateAmount = C_ContributionCollector.GetState(self.contributionID);
	local isRewardActive = state == Enum.ContributionState.Active;
	local isRewardVisible = state ~= Enum.ContributionState.Destroyed;
	reward:Setup(rewardID, isRewardActive);
	reward:SetShown(isRewardVisible);
end

function ContributionMixin:UpdateStatus()
	self.Status:SetContributionID(self.contributionID);
	self.Status:Update();
end

function ContributionMixin:UpdateContributeButton()
	self.ContributeButton:SetContributionID(self.contributionID);
	self.ContributeButton:Update();
	self:UpdatePendingAnimations();
end

function ContributionMixin:QueueAnimation(shouldQueue)
	self.hasPendingAnimation = shouldQueue;
	self.animationLoopCount = 0;
end

function ContributionMixin:UpdatePendingAnimations()
	if self.hasPendingAnimation then
		self.Status:PlayFlashAnimation();
		self.hasPendingAnimation = false;
	end
end

function ContributionMixin:StopAnimations()
	self:QueueAnimation(false);
end

ContributionCollectionMixin = {};

function ContributionCollectionMixin:OnLoad()
	self.contributionPool = CreateFramePool("FRAME", self, "ContributionTemplate", function(pool, contribution) contribution:OnReset(pool); end);
	self.rewardPool = CreateFramePool("FRAME", self, "ContributionRewardTemplate");
end

function ContributionCollectionMixin:OnShow()
	PlaySound("UI_72_Building_Contribution_Table_Open");

	self:RegisterEvent("CONTRIBUTION_COLLECTOR_UPDATE");
	self:RegisterEvent("CONTRIBUTION_COLLECTOR_PENDING");
	self:RegisterEvent("CONTRIBUTION_COLLECTOR_UPDATE_SINGLE");
	self:Update();
end

function ContributionCollectionMixin:OnHide()
	PlaySound("UI_72_Buildings_Contribution_Table_Close");

	self:UnregisterEvent("CONTRIBUTION_COLLECTOR_UPDATE");
	self:UnregisterEvent("CONTRIBUTION_COLLECTOR_PENDING");
	self:UnregisterEvent("CONTRIBUTION_COLLECTOR_UPDATE_SINGLE");
	C_ContributionCollector.Close();
end

function ContributionCollectionMixin:OnEvent(event, ...)
	if event == "CONTRIBUTION_COLLECTOR_UPDATE" then
		self:Update();
	elseif event == "CONTRIBUTION_COLLECTOR_UPDATE_SINGLE" then
		local contributionID = ...;
		self:UpdateSingle(contributionID);
	elseif event == "CONTRIBUTION_COLLECTOR_PENDING" then
		local contributionID, isPending, result = ...;
		self:UpdatePendingContribution(contributionID, isPending, result);
	end
end

function ContributionCollectionMixin:Update()
	self.contributionPool:ReleaseAll();
	self.rewardPool:ReleaseAll();

	self:EnumerateContributions(C_ContributionCollector.GetActive());
end

function ContributionCollectionMixin:UpdateSingle(contributionID)
	local contribution = self:FindContribution(contributionID);
	if contribution then
		contribution:Update();
	end
end

function ContributionCollectionMixin:EnumerateContributions(...)
	local contributionIDs = {...};
	table.sort(contributionIDs, function(id1, id2)
		return C_ContributionCollector.GetOrderIndex(id1) < C_ContributionCollector.GetOrderIndex(id2);
	end);

	for i, contributionID in ipairs(contributionIDs) do
		self:AddContribution(i, contributionID);
	end
end

local contributionResultErrorMessages =
{
	[Enum.ContributionResult.IncorrectState] = CONTRIBUTION_RESULT_ERROR_INCORRECT_STATE,
	[Enum.ContributionResult.InvalidID] = CONTRIBUTION_RESULT_ERROR_INVALID_ID,
	[Enum.ContributionResult.QuestDataMissing] = CONTRIBUTION_RESULT_ERROR_UNABLE_TO_COMPLETE_QUEST,
	[Enum.ContributionResult.FailedConditionCheck] = CONTRIBUTION_RESULT_ERROR_UNABLE_TO_COMPLETE_QUEST,
	[Enum.ContributionResult.UnableToCompleteTurnIn] = CONTRIBUTION_RESULT_ERROR_UNABLE_TO_COMPLETE_QUEST,
};

function ContributionCollectionMixin:HandleContributionResult(result)
	local errorMessage = contributionResultErrorMessages[result];
	if errorMessage then
		UIErrorsFrame:AddMessage(errorMessage, RED_FONT_COLOR:GetRGBA());
	end
end

function ContributionCollectionMixin:UpdatePendingContribution(contributionID, isPending, result)
	local contribution = self:FindContribution(contributionID);
	if contribution then
		local successfulContribution = result == Enum.ContributionResult.Success and not isPending;
		local unsuccessfulContribution = result ~= Enum.ContributionResult.Success and not isPending;
		if unsuccessfulContribution then
			self:HandleContributionResult(result);
			contribution:StopAnimations();
		elseif successfulContribution then
			contribution:QueueAnimation(true);
		end

		contribution:UpdateContributeButton();
	end
end

function ContributionCollectionMixin:AddContribution(index, contributionID)
	local contributionFrame = self.contributionPool:Acquire();
	contributionFrame:Setup(index, contributionID);
end

function ContributionCollectionMixin:FindContribution(contributionID)
	for contribution in self.contributionPool:EnumerateActive() do
		if contribution.contributionID == contributionID then
			return contribution;
		end
	end
end

function ContributionCollectionMixin:AcquireReward()
	return self.rewardPool:Acquire();
end

function ContributionCollectionMixin:ReleaseReward(reward)
	self.rewardPool:Release(reward);
end

function ContributionCollectionUI_Show()
	ShowUIPanel(ContributionCollectionFrame);
end

function ContributionCollectionUI_Hide()
	HideUIPanel(ContributionCollectionFrame);
end