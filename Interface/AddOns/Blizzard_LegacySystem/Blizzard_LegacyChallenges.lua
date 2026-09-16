LegacyChallengesPageMixin = {}

function LegacyChallengesPageMixin:OnLoad()
	self:RegisterEvent("ACHIEVEMENT_EARNED");
	self:RegisterEvent("CRITERIA_UPDATE");
	self:RegisterEvent("ACHIEVEMENT_SEARCH_UPDATED");

	self:InitFilterMenu(self.CategoryList.FilterDropdown);

	self.CategoryList.SearchBox:SetScript("OnTextChanged", function(editBox)
		SearchBoxTemplate_OnTextChanged(editBox);

		SetAchievementSearchString(editBox:GetText());
	end);
end

function LegacyChallengesPageMixin:OnEvent(event, ...)
	if ( event == "ACHIEVEMENT_EARNED" ) then
		local achievementID = ...;
		self:OnAchievementComplete(achievementID);
	elseif ( event == "CRITERIA_UPDATE" ) then
		self:OnCriteriaUpdate();
	elseif ( event == "ACHIEVEMENT_SEARCH_UPDATED" ) then
		local numResults = GetNumFilteredAchievements();

		self:OnFilterUpdate();
		EventRegistry:TriggerEvent("Legacy.RefreshChallenges");
	end
end

function LegacyChallengesPageMixin:OnShow()
	self:UpdateCategoryList();

	LegacyChallengeObjectives.clearOnClose = false;

	self:GetParent():SetTitle(LEGACY_CHALLENGE_FRAME_TITLE);
end

function LegacyChallengesPageMixin:UpdateCategoryList()
	local dataProvider = self:GenerateDataProvider();
	self.CategoryList.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.DiscardScrollPosition);
end

local function HasChallenges(categoryID)
	local numAchievements, numComplete, numIncomplete = GetCategoryNumAchievements(categoryID);
	local showComplete = LegacyChallengeFilters[ACHIEVEMENTFRAME_FILTER_COMPLETED].value;
	local showIncomplete = LegacyChallengeFilters[ACHIEVEMENTFRAME_FILTER_INCOMPLETE].value;

	if showComplete and not showIncomplete then
		return numComplete > 0;
	end

	if showIncomplete and not showComplete then
		return numIncomplete > 0;
	end

	if showComplete and showIncomplete then
		return numAchievements > 0;
	end

	return false;
end

local function AllChallengesFiltered(categoryID)
	local filteredChallenges = LegacySystem.GetFilteredChallenges();
	local startOffset, count = LegacySystem.GetChallengeIndices(categoryID);
	for index = 1 + startOffset, count + startOffset do
		local achievementId = GetAchievementInfo(categoryID, index);
		if filteredChallenges[achievementId] then
			return false;
		end
	end

	return true;
end

function LegacyChallengesPageMixin:GenerateDataProvider()
	local dataProvider = CreateTreeDataProvider();
	local categories = GetCategoryList();

	-- Determine category visibility prior to tree construction
	local visibleCategoryIDs = {};

	for _, catId in ipairs(categories) do
		if HasChallenges(catId) and not AllChallengesFiltered(catId) then
			local currCatId = catId;
			while currCatId and currCatId ~= -1 and not visibleCategoryIDs[currCatId] do
				visibleCategoryIDs[currCatId] = true;
				local _, parentId = GetCategoryInfo(currCatId);
				currCatId = parentId;
			end
		end
	end

	-- Construct the tree using visibleCategoryIDs to filter out hidden categories
	local categoryIndex = {};

	local function GetOrCreateNodeRecursive(categoryID)
		if not visibleCategoryIDs[categoryID] then
			return nil;
		end

		local existingNode = categoryIndex[categoryID];
		if existingNode then
			return existingNode;
		end

		local categoryName, parentId = GetCategoryInfo(categoryID);

		local attachNode = dataProvider;
		if parentId ~= -1 then
			local parentNode = GetOrCreateNodeRecursive(parentId);
			if parentNode then
				attachNode = parentNode;
			end
		end

		local node = attachNode:Insert({
			categoryInfo = { id = categoryID, name = categoryName },
			hasAchievements = HasChallenges(categoryID),
		});

		if attachNode.GetData then
			local parentData = attachNode:GetData();
			if parentData then
				parentData.isParent = true;
			end
		end

		categoryIndex[categoryID] = node;
		return node;
	end

	for _, catId in ipairs(categories) do
		GetOrCreateNodeRecursive(catId);
	end

	local rootNode = dataProvider:GetRootNode();
	if rootNode then
		rootNode:SetCollapsed(true, true);
	end

	return dataProvider;
end

function LegacyChallengesPageMixin:OnAchievementComplete(achievementId)
	local selectedElementData = AchievementFrameAchievements_GetSelectedElementData();

	EventRegistry:TriggerEvent("Legacy.RefreshChallenges");

	if selectedElementData and selectedElementData.id == achievementId then
		EventRegistry:TriggerEvent("Legacy.SelectChallenge", achievementId);
	end
end

function LegacyChallengesPageMixin:OnCriteriaUpdate()
	local selectedElementData = AchievementFrameAchievements_GetSelectedElementData();
	if selectedElementData then
		EventRegistry:TriggerEvent("Legacy.UpdateChallenge", selectedElementData);
	end
end

function LegacyChallengesPageMixin:SetDefaultFilters()
	for _, filter in ipairs(LegacyChallengeFilters) do
		filter.value = filter.default;
	end
end

function LegacyChallengesPageMixin:IsUsingDefaultFilters()
	local usingDefaults = true;
	for _, filter in ipairs(LegacyChallengeFilters) do
		if filter.value ~= filter.default then
			usingDefaults = false;
			break;
		end
	end
	return usingDefaults;
end

function LegacyChallengesPageMixin:SetupFilterMenu(dropdown, rootDescription)
	for key, filter in pairs(LegacyChallengeFilters) do
		local function isSelected()
			return filter.value;
		end
		local function Select()
			filter.value = not filter.value;
		end

		rootDescription:CreateCheckbox(key, isSelected, Select);
	end
end

function LegacyChallengesPageMixin:OnFilterUpdate()
	local selectedElementData = self.CategoryList.selectionBehavior:GetFirstSelectedElementData();

	self:UpdateCategoryList();

	if selectedElementData then
		EventRegistry:TriggerEvent("Legacy.OpenToChallengeCategory", selectedElementData:GetData().categoryInfo.id);
	end
end

function LegacyChallengesPageMixin:InitFilterMenu(dropdown)
	dropdown:SetDefaultCallback(function()
		self:SetDefaultFilters();
	end);

	dropdown:SetUpdateCallback(function()
		self:OnFilterUpdate();
	end);

	dropdown:SetIsDefaultCallback(function()
		return self:IsUsingDefaultFilters();
	end);

	dropdown:SetupMenu(function(dropdown, rootDescription)
		self:SetupFilterMenu(dropdown, rootDescription);
	end);
end

LegacyChallengePointSummaryMixin = {}

function LegacyChallengePointSummaryMixin:OnLoad()
	EventRegistry:RegisterCallback("Legacy.UpdateCurrencyInfo", function(_, info)
		self:SetCurrencyInfo(info);
	end, self);

	LegacySystem.UpdateCurrencyInfo();
end

function LegacyChallengePointSummaryMixin:SetCurrencyInfo(currencyInfo)
	self:RefreshText(currencyInfo);
	self.PointsBar:Update(currencyInfo);
end

function LegacyChallengePointSummaryMixin:RefreshText(currencyInfo)
	self.Shield.Points:SetText(currencyInfo.renownCurrency);
end

ChallengePointBarMixin = {};

function ChallengePointBarMixin:OnHide()
	if self.interpolator then
		self.interpolator:Cancel();
		self.interpolator = nil;
	end

	self.ratio = nil;
end

function ChallengePointBarMixin:Update(currencyInfo)
	if not currencyInfo or not currencyInfo.traitCurrencyID then
		return;
	end;

	local limitBySourcedMax = false;
	local totalAvailable = C_Traits.GetMaxAvailableTraitCurrency(currencyInfo.traitCurrencyID, limitBySourcedMax);
	self.Text:SetText(LEGACY_POINTS_CURR_MAX:format(currencyInfo.renownCurrency, totalAvailable));

	local newRatio = 0;
	if totalAvailable > 0 then
		newRatio = math.min(currencyInfo.renownCurrency / totalAvailable, 1);
	end

	local sameRatio = self.ratio == newRatio;
	if sameRatio then
		return;
	end

	if self.interpolator then
		self.interpolator:Cancel();
		self.interpolator = nil;
	end

	self.interpolator = CreateInterpolator(InterpolatorUtil.InterpolateEaseOut);
	local oldRatio = self.ratio or 0;
	self.interpolator:Interpolate(0, 1, .5, function(value)
		local u = InterpolatorUtil.InterpolateLinear(oldRatio, newRatio, value);
		self:SetValue(u);
	end, function() self.interpolator = nil; end);

	self.ratio = newRatio;
end

-- Achievement Overrides

function AchievementFrame_SetDateCompleted(frame, day, month, year)
	frame.DateCompleted:SetText(FormatShortDate(day, month, year));
	local padding = 5;
	frame.DateCompleted:SetWidth(frame.DateCompleted:GetStringWidth() + padding);
end

function AchievementFrame_ShowDateCompleted(parent, show)
	parent.DateCompleted:SetShown(show);
	if parent.Shield then
		if parent.Shield.CheckBackground then
			parent.Shield.CheckBackground:SetShown(show);
		end
		if parent.Shield.Check then
			parent.Shield.Check:SetShown(show);
		end
	end
end

function AchievementFrame_ShowAsComplete(completed, wasEarnedByMe)
	return completed and wasEarnedByMe;
end

function AchievementFrame_GetOverridePoints(points, achievementId)
	local legacyPoints = C_Traits.GetTraitCurrencyForAchievement(Constants.LegacyConsts.LEGACY_POINTS_TRAIT_CURRENCY_ID, achievementId);
	return legacyPoints;
end

function AchievementFrame_SelectAchievement(id, forceSelect)
	if ( (not LegacySystemFrame:IsShown() and not forceSelect) or (not C_AchievementInfo.IsValidAchievement(id)) ) then
		return;
	end

	local displayedId = AchievementFrame_FindDisplayedAchievement(id);
	local categoryID = GetAchievementCategory(displayedId);
	EventRegistry:TriggerEvent("Legacy.OpenToChallengeCategory", categoryID);

	EventRegistry:TriggerEvent("Legacy.SelectChallenge", displayedId);
end

function AchievementShield_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local parent = self:GetParent();
	local elementData = parent:GetElementData();
	if elementData then
		local rewardText = select(11, GetAchievementInfo(elementData.id));
		GameTooltip:AddLine(rewardText);
		GameTooltip:Show();
		return;
	end

	-- pass-through to the achievement button
	local func = parent:GetScript("OnEnter");
	if ( func ) then
		func(parent);
	end

	GameTooltip:Show();
end
