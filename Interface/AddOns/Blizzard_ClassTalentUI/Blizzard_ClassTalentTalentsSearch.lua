local NotOnActionBarSearchText = TALENT_FRAME_SEARCH_NOT_ON_ACTIONBAR;

ClassTalentTalentsSearchMixin = {};

function ClassTalentTalentsSearchMixin:InitializeSearch()
	if self.isSearchInitialized then
		return;
	end

	self.searchInspectUnit = self:GetInspectUnit();

	self.textSearch = CreateAndInitFromMixin(ClassTalentTextSearchMixin, self, true);
	self.actionBarSearch = CreateAndInitFromMixin(ClassTalentActionBarSearchMixin, self, false);

	self.searchMixins = { self.textSearch, self.actionBarSearch	};

	self.isSearchInitialized = true;

	self:UpdateEnabledSearchTypes();
end

function ClassTalentTalentsSearchMixin:UpdateEnabledSearchTypes()
	-- Avoid reacting if search hasn't initialized yet
	if not self.isSearchInitialized then
		return;
	end

	local oldInspectUnit = self.searchInspectUnit;
	self.searchInspectUnit = self:GetInspectUnit();

	local isActionBarSearchEnabled = not self.searchInspectUnit and not self:HasAnyPendingChanges();
	local wasActionBarSearchEnabled = self.actionBarSearch:GetIsEnabled();
	local wasActionBarSearchActive = self.actionBarSearch:GetIsActive();

	if isActionBarSearchEnabled ~= wasActionBarSearchEnabled then
		self.actionBarSearch:SetEnabled(isActionBarSearchEnabled);

		if self.actionBarSearch:GetIsEnabled() then
			self.SearchPreviewContainer:SetDefaultResultButton(NotOnActionBarSearchText, GenerateClosure(self.OnNotOnActionBarButtonClicked, self));
		else
			self.SearchPreviewContainer:DisableDefaultResultButton();
		end
	end

	if (oldInspectUnit ~= self.searchInspectUnit) or (isActionBarSearchEnabled ~= wasActionBarSearchEnabled and wasActionBarSearchActive) then
		self:ClearActiveSearchState();
	end
end

function ClassTalentTalentsSearchMixin:SetPreviewResultSearch(previewSearchText)
	-- Overrides TalentFrameBaseMixin.

	if not previewSearchText then
		if self.actionBarSearch:GetIsEnabled() then
			-- Action Bar search enabled, so wil show default action bar preview button
			self.SearchPreviewContainer:SetPreviewResults(nil);
			self.SearchPreviewContainer:Show();
		else
			-- Action Bar search disabled, so not showing default action bar preview button
			self.SearchPreviewContainer:Hide();
			self.SearchPreviewContainer:ClearResults();
		end
		return;
	end

	local previewResults = {};
	local lowerPreviewSearchText = previewSearchText:lower();
	local anyResults = false;

	for talentButton in self:EnumerateAllTalentButtons() do
		local nodeInfo = talentButton:GetNodeInfo();
		-- Evaluating every entryID as some buttons have multiple choice talents
		if nodeInfo and nodeInfo.entryIDs then
			for i, entryID in ipairs(nodeInfo.entryIDs) do
				local definitionID = self:GetAndCacheEntryInfo(entryID).definitionID;
				if definitionID then
					local definitionInfo = self:GetAndCacheDefinitionInfo(definitionID);
					if definitionInfo then
						local lowerTalentName = TalentUtil.GetTalentNameFromInfo(definitionInfo):lower();
						if lowerTalentName:find(lowerPreviewSearchText) then
							anyResults = true;
							previewResults[definitionID] = definitionInfo;
						end
					end
				end
			end
		end
	end

	if not anyResults then
		self.SearchPreviewContainer:Hide();
		self.SearchPreviewContainer:ClearResults();
	else
		self.SearchPreviewContainer:SetPreviewResults(previewResults);
		self.SearchPreviewContainer:Show();
	end
end

function ClassTalentTalentsSearchMixin:HidePreviewResultSearch()
	-- Overrides TalentFrameBaseMixin.

	self.SearchPreviewContainer:Hide();
	self.SearchPreviewContainer:ClearResults();
end

function ClassTalentTalentsSearchMixin:SetFullResultSearch(searchText)
	-- Overrides TalentFrameBaseMixin.
	
	if self.actionBarSearch:GetIsEnabled() and searchText and searchText:lower() == NotOnActionBarSearchText:lower() then
		self:ActivateSearchMixin(self.actionBarSearch, true);
	else
		self:ActivateSearchMixin(self.textSearch, searchText);
	end
end

function ClassTalentTalentsSearchMixin:SetSelectedSearchResult(definitionID)
	-- Overrides TalentFrameBaseMixin.

	local definitionInfo = self:GetAndCacheDefinitionInfo(definitionID);
	local talentName = TalentUtil.GetTalentNameFromInfo(definitionInfo);
	-- Override the search box text to the selected autocomplete talent's name
	self.SearchBox:ClearFocus();
	self.SearchBox:SetText(talentName);
	self.SearchPreviewContainer:Hide();

	-- Show the results of searching for that talent name
	self:SetFullResultSearch(talentName);
end

function ClassTalentTalentsSearchMixin:UpdateFullSearchResults()
	local activeSearchMixin = self:GetActiveSearchMixin();
	if activeSearchMixin then
		activeSearchMixin:UpdateSearchResults();
	end
end

function ClassTalentTalentsSearchMixin:ClearActiveSearchState()
	local activeSearchMixin = self:GetActiveSearchMixin();
	if activeSearchMixin then
		activeSearchMixin:ClearSearchResults();
	end

	self.SearchPreviewContainer:Hide();
	self.SearchPreviewContainer:ClearResults();
	self.SearchBox:ClearFocus();
	self.SearchBox:SetText("");
end

function ClassTalentTalentsSearchMixin:OnNotOnActionBarButtonClicked()
	if not self.actionBarSearch:GetIsEnabled() then
		return;
	end

	self.SearchBox:ClearFocus();
	self.SearchBox:SetText(NotOnActionBarSearchText);
	self.SearchPreviewContainer:Hide();

	self:ActivateSearchMixin(self.actionBarSearch, true);
end

function ClassTalentTalentsSearchMixin:GetSearchMatchTypeForEntry(nodeID, entryID)
	local activeSearchMixin = self:GetActiveSearchMixin();
	if activeSearchMixin then
		return activeSearchMixin:GetSearchMatchTypeForEntry(nodeID, entryID);
	end

	return nil;
end

function ClassTalentTalentsSearchMixin:GetActiveSearchMixin()
	for i, mixin in ipairs(self.searchMixins) do
		if mixin:GetIsActive() then
			return mixin;
		end
	end
	return nil;
end

function ClassTalentTalentsSearchMixin:ActivateSearchMixin(searchMixin, ...)
	-- Clear previously active mixin
	local activeSearchMixin = self:GetActiveSearchMixin();
	if activeSearchMixin and activeSearchMixin ~= searchMixin then
		activeSearchMixin:ClearSearchResults();
	end

	-- Set new mixin
	searchMixin:SetSearch(...);
end

function ClassTalentTalentsSearchMixin:GetSearchPreviewContainer()
	-- Overrides TalentFrameBaseMixin.

	return self.SearchPreviewContainer;
end


-- Search Mixins for different unique talent search types
-- These could easily be genericized and reused in the future if another area wants to use the same search types
ClassTalentSearchTypeBaseMixin = {}

function ClassTalentSearchTypeBaseMixin:Init(talentFrame, enabled)
	self.talentFrame = talentFrame;
	self.enabled = enabled;
end

function ClassTalentSearchTypeBaseMixin:SetEnabled(enabled)
	self.enabled = enabled;
	if not self.enabled and self.isActive then
		self:ClearSearchResults();
	end
end

function ClassTalentSearchTypeBaseMixin:GetIsEnabled()
	return self.enabled;
end

function ClassTalentSearchTypeBaseMixin:SetSearch(...)
	if not self:GetIsEnabled() then
		return;
	end

	self.isActive = true;
	self:UpdateSearchResults();
end

function ClassTalentSearchTypeBaseMixin:ClearSearchResults()
	self.isActive = false;

	for talentButton in self:EnumerateAllTalentButtons() do
		talentButton:SetSearchMatchType(nil);
	end
end

function ClassTalentSearchTypeBaseMixin:GetIsActive()
	return self.isActive;
end

function ClassTalentSearchTypeBaseMixin:GetIsActiveAndEnabled()
	return self:GetIsActive() and self:GetIsEnabled();
end

function ClassTalentSearchTypeBaseMixin:GetTalentFrame()
	return self.talentFrame;
end

function ClassTalentSearchTypeBaseMixin:EnumerateAllTalentButtons()
	return self:GetTalentFrame():EnumerateAllTalentButtons();
end

function ClassTalentSearchTypeBaseMixin:UpdateSearchResults()
	-- Implement in your derived mixin.
end

function ClassTalentSearchTypeBaseMixin:GetSearchMatchTypeForEntry(nodeID, entryID)
	-- Implement in your derived mixin.
end


-- Search mixin for basic text-based talent searching
ClassTalentTextSearchMixin = CreateFromMixins(ClassTalentSearchTypeBaseMixin);

function ClassTalentTextSearchMixin:SetSearch(...)
	-- Overrides ClassTalentSearchTypeBaseMixin.
	
	local searchText = ...;

	local newSearch = searchText and searchText:lower() or nil;
	if self.searchString == newSearch then
		return;
	end

	self.searchString = newSearch;

	ClassTalentSearchTypeBaseMixin.SetSearch(self, ...);
end

function ClassTalentTextSearchMixin:ClearSearchResults()
	-- Overrides ClassTalentSearchTypeBaseMixin.

	self.searchString = nil;

	ClassTalentSearchTypeBaseMixin.ClearSearchResults(self);
end

function ClassTalentTextSearchMixin:UpdateSearchResults()
	-- Overrides ClassTalentSearchTypeBaseMixin.

	if not self:GetIsActiveAndEnabled() then
		return;
	end

	self.searchStringExactMatchDescription = nil;

	if not self.searchString then
		self:ClearSearchResults();
		return;
	end

	-- Get the description of any "Exact Match" talent so it can be used to find Related Match talents
	self.searchStringExactMatchDescription = self:GetExactSearchMatchDescription();

	-- Go through and evaluate all buttons
	for talentButton in self:EnumerateAllTalentButtons() do
		local nodeInfo = talentButton:GetNodeInfo();
		local bestMatchTypeForButton = nil;

		if nodeInfo and nodeInfo.entryIDs then
			-- Evaluating every entryID as some buttons have multiple choice talents
			-- We want to mark those buttons with the "best" match type out of those entries
			for i, entryID in ipairs(nodeInfo.entryIDs) do
				local matchTypeForEntry = self:GetSearchMatchTypeForEntry(nodeInfo.ID, entryID);

				if matchTypeForEntry and (not bestMatchTypeForButton or matchTypeForEntry > bestMatchTypeForButton) then
					bestMatchTypeForButton = matchTypeForEntry;
				end
			end
		end

		talentButton:SetSearchMatchType(bestMatchTypeForButton);
	end

	ClassTalentSearchTypeBaseMixin.UpdateSearchResults(self);
end

function ClassTalentTextSearchMixin:GetSearchMatchTypeForEntry(nodeID, entryID)
	-- Overrides ClassTalentSearchTypeBaseMixin.

	if not self:GetIsActiveAndEnabled() or not self.searchString then
		return nil;
	end

	local exactMatchDescription = self.searchStringExactMatchDescription;
	local definitionInfo = self:GetTalentFrame():GetDefinitionInfoForEntry(entryID);
	if definitionInfo then
		local lowerTalentName = TalentUtil.GetTalentNameFromInfo(definitionInfo):lower();
		local lowerTalentDescription = TalentUtil.GetTalentDescriptionFromInfo(definitionInfo):lower();
		local lowerTalentReplacesName = TalentUtil.GetReplacesSpellNameFromInfo(definitionInfo):lower();

		-- Exact Match -> search matches name exactly
		if lowerTalentName == self.searchString then
			return TalentButtonUtil.SearchMatchType.ExactMatch;
		-- Match -> search is in name, description, or name of replaced spell
		elseif lowerTalentName:find(self.searchString) or lowerTalentDescription:find(self.searchString) or lowerTalentReplacesName:find(self.searchString) then
			return TalentButtonUtil.SearchMatchType.Match;
		-- Related Match -> name is in exact match description
		elseif exactMatchDescription and exactMatchDescription:find(lowerTalentName) then
			return TalentButtonUtil.SearchMatchType.RelatedMatch;
		-- No Match
		else
			return nil;
		end
	else
		return nil;
	end
end

function ClassTalentTextSearchMixin:GetExactSearchMatchDescription()
	local lowerExactMatchDescription = nil;
	-- Find any talent whose name matches the search string exactly and, if found, return its description
	for talentButton in self:EnumerateAllTalentButtons() do
		local nodeInfo = talentButton:GetNodeInfo();
		if nodeInfo and nodeInfo.entryIDs then
			-- Evaluating every entryID as some buttons have multiple choice talents
			for i, entryID in ipairs(nodeInfo.entryIDs) do
				local definitionInfo = self:GetTalentFrame():GetDefinitionInfoForEntry(entryID);
				if definitionInfo and TalentUtil.GetTalentNameFromInfo(definitionInfo):lower() == self.searchString then
					lowerExactMatchDescription = TalentUtil.GetTalentDescriptionFromInfo(definitionInfo):lower();
					return lowerExactMatchDescription;
				end
			end
		end
	end
	return nil;
end

-- Search mixin for finding all committed, non-passive talents not slotted in the Action Bar
ClassTalentActionBarSearchMixin = CreateFromMixins(ClassTalentSearchTypeBaseMixin);

local MatchTypeForActionBarStatus = {
	[TalentButtonUtil.ActionBarStatus.NotMissing] = nil,
	[TalentButtonUtil.ActionBarStatus.MissingFromAllBars] = TalentButtonUtil.SearchMatchType.NotOnActionBar,
	[TalentButtonUtil.ActionBarStatus.OnInactiveBonusBar] = TalentButtonUtil.SearchMatchType.OnInactiveBonusBar,
	[TalentButtonUtil.ActionBarStatus.OnDisabledActionBar] = TalentButtonUtil.SearchMatchType.OnDisabledActionBar,
}

function ClassTalentActionBarSearchMixin:UpdateSearchResults()
	-- Overrides ClassTalentSearchTypeBaseMixin.

	if not self:GetIsActiveAndEnabled() then
		return;
	end

	for talentButton in self:EnumerateAllTalentButtons() do
		local matchType = MatchTypeForActionBarStatus[talentButton:GetActionBarStatus()];

		talentButton:SetSearchMatchType(matchType);
	end

	ClassTalentSearchTypeBaseMixin.UpdateSearchResults(self);
end

function ClassTalentActionBarSearchMixin:GetSearchMatchTypeForEntry(nodeID, entryID)
	-- Overrides ClassTalentSearchTypeBaseMixin.

	if not self:GetIsActiveAndEnabled() or not nodeID or not entryID then
		return nil;
	end

	local nodeInfo = self:GetTalentFrame():GetAndCacheNodeInfo(nodeID);
	local definitionInfo = self:GetTalentFrame():GetDefinitionInfoForEntry(entryID);

	if not nodeInfo or not definitionInfo or not definitionInfo.spellID then
		return nil;
	end

	local actionbarStatus = TalentButtonUtil.GetActionBarStatusForNodeEntry(entryID, nodeInfo, definitionInfo.spellID);
	return MatchTypeForActionBarStatus[actionbarStatus];
end