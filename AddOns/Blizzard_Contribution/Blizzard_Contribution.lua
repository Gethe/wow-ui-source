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

function ContributionRewardMixin:OnEnter()
	GameTooltip:SetOwner(self);
	GameTooltip:SetSpellByID(self.rewardID);

	if not self.isEnabled then
		GameTooltip:AddLine(CONTRIBUTION_TOOLTIP_UNLOCKED_WHEN_ACTIVE, RED_FONT_COLOR:GetRGB());
	end

	GameTooltip:Show();
end

function ContributionRewardMixin:OnLeave()
	GameTooltip:Hide();
end

ContributionMixin = {};

function ContributionMixin:OnLoad()
	self.Status:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar"); -- Set to some default texture just to instantiate the bar, fixing this soon since it will use a static texture
	self.Status.Spark:ClearAllPoints();
	self.Status.Spark:SetPoint("CENTER", self.Status:GetStatusBarTexture(), "RIGHT", 0, 0);
end

function ContributionMixin:OnReset(pool)
	FramePool_HideAndClearAnchors(pool, self);

	self.layoutIndex = nil;
	self.contributionID = nil;
	self.rewards = nil;
	self.stateToAtlas = nil;
end

function ContributionMixin:Setup(layoutIndex, contributionID)
	self.layoutIndex = layoutIndex;
	self.contributionID = contributionID;
	self.rewards = {};
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

function ContributionMixin:UpdateRewards()
	self:EnumerateRewards(C_ContributionCollector.GetBuffs(self.contributionID));
end

function ContributionMixin:EnumerateRewards(...)
	for i = 1, select("#", ...) do
		self:AddReward(i, select(i, ...));
	end
end

function ContributionMixin:FindOrAcquireReward(rewardID)
	local reward = self.rewards[rewardID];
	if not reward then
		reward = self:GetParent():AcquireReward();
		self.rewards[rewardID] = reward;
	end

	return reward;
end

function ContributionMixin:AddReward(index, rewardID)
	local reward = self:FindOrAcquireReward(rewardID);

	reward:SetPoint("TOPLEFT", self.Description, "BOTTOMLEFT", 0, (index - 1) * -45);

	local isRewardActive = C_ContributionCollector.IsBuffActive(self.contributionID);
	reward:Setup(rewardID, isRewardActive);
end

function ContributionMixin:UpdateStatus()
	local state, stateAmount = C_ContributionCollector.GetState(self.contributionID);
	local appearance = CONTRIBUTION_APPEARANCE_DATA[state];

	self.Status:SetStatusBarAtlas(appearance.statusBarAtlas);
	self.Status:SetValue(stateAmount);
	self.Status.Spark:SetShown(stateAmount > 0 and stateAmount < 1);

	-- Only show percentages when the contribution is active or under attack
	if state == LE_CONTRIBUTION_STATE_ACTIVE or state == LE_CONTRIBUTION_STATE_UNDER_ATTACK then
		self.Status.Text:SetText(CONTIBUTION_HEALTH_TEXT_WITH_PERCENTAGE:format(FormatPercentage(stateAmount)));
	else
		self.Status.Text:SetText();
	end
end

function ContributionMixin:UpdateContributeButton()
	local canContribute = C_ContributionCollector.CanContribute(self.contributionID);
	self.ContributeButton:SetEnabled(canContribute);

	self.ContributeButton.questID = C_ContributionCollector.GetRewardQuestID(self.contributionID);

	if canContribute then
		local currencyID, currencyAmount = C_ContributionCollector.GetRequiredContributionAmount(self.contributionID);
		self.ContributeButton:SetCurrencyFromID(currencyID, currencyAmount, CONTIBUTION_REQUIRED_CURRENCY);
	else
		self.ContributeButton:SetText(CONTRIBUTION_DISABLED);
	end
end

ContributeButtonMixin = {};

function ContributeButtonMixin:OnClick(button)
	self:Disable();
	self:GetParent():Contribute();
end

function ContributeButtonMixin:OnEnter()
	ContributionTooltip:SetOwner(self, "ANCHOR_RIGHT");
	ContributionTooltip:SetText(CONTRIBUTION_REWARD_TOOLTIP_TITLE);
	GameTooltip_AddQuestRewardsToTooltipWithHeader(ContributionTooltip, self.questID, 0, CONTRIBUTION_REWARD_TOOLTIP_TEXT, HIGHLIGHT_FONT_COLOR);
	ContributionTooltip:Show();
end

function ContributeButtonMixin:OnLeave()
	ContributionTooltip:Hide();
end

ContributionCollectionMixin = {};

function ContributionCollectionMixin:OnLoad()
	self.contributionPool = CreateFramePool("FRAME", self, "ContributionTemplate", function(pool, contribution) contribution:OnReset(pool); end);
	self.rewardPool = CreateFramePool("FRAME", self, "ContributionRewardTemplate");
end

function ContributionCollectionMixin:OnShow()
	self:RegisterEvent("CONTRIBUTION_COLLECTOR_UPDATE");
	self:RegisterEvent("CONTRIBUTION_COLLECTOR_PENDING");
	self:RegisterEvent("CONTRIBUTION_COLLECTOR_UPDATE_SINGLE");
	self:Update();
end

function ContributionCollectionMixin:OnHide()
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
		local contributionID, isPending = ...;
		self:UpdatePendingContribution(contributionID, isPending);
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

function ContributionCollectionMixin:UpdatePendingContribution(contributionID, isPending)
	local contribution = self:FindContribution(contributionID);
	if contribution then
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