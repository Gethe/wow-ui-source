local NotOnActionBarSearchText = TALENT_FRAME_SEARCH_NOT_ON_ACTIONBAR;

ClassTalentSearchMixin = {};

function ClassTalentSearchMixin:InitializeSearch()
	local searchSources = {};

	-- Setup search source for our search controller to use
	local allNodeInfosGetter = GenerateClosure(self.GetAllSearchableNodeInfos, self);
	local definitionInfoGetter = GenerateClosure(self.GetDefinitionInfoForEntry, self);
	local subTreeInfoGetter = GenerateClosure(self.GetSubTreeInfoForEntry, self);
	searchSources[SpellSearchUtil.SourceType.Trait] = CreateAndInitFromMixin(TraitSearchSourceMixin, allNodeInfosGetter, definitionInfoGetter, subTreeInfoGetter);

	-- Initialize search controller
	self.searchController = CreateAndInitFromMixin(SpellSearchControllerMixin, searchSources);

	self.isInspecting = self:IsInspecting();

	self:UpdateEnabledSearchTypes();
end

function ClassTalentSearchMixin:IsSearchInitialized()
	return self.searchController and self.searchController:IsInitialized();
end

function ClassTalentSearchMixin:IsSearchActive()
	return self:IsSearchInitialized() and self.searchController:GetActiveSearchFilter() ~= nil;
end

function ClassTalentSearchMixin:UpdateEnabledSearchTypes()
	-- Avoid reacting if search hasn't initialized yet
	if not self:IsSearchInitialized() then
		return;
	end

	local wasInspecting = self.isInspecting;
	self.isInspecting = self:IsInspecting();

	local disableActionBarSearch = self.isInspecting;
	local forceClearSearch = wasInspecting ~= self.isInspecting;
	self.searchController:SetFilterDisabled(SpellSearchUtil.FilterType.ActionBar, disableActionBarSearch, forceClearSearch);

	if disableActionBarSearch then
		self.SearchPreviewContainer:DisableDefaultResultButton();
	else
		self.SearchPreviewContainer:SetDefaultResultButton(NotOnActionBarSearchText, GenerateClosure(self.OnNotOnActionBarButtonClicked, self));
	end
end

function ClassTalentSearchMixin:SetPreviewResultSearch(previewSearchText)
	if not self:IsSearchInitialized() then
		return;
	end

	if not previewSearchText then
		if self.searchController:IsFilterEnabled(SpellSearchUtil.FilterType.ActionBar) then
			-- Action Bar search enabled, so will show default action bar preview button
			self.SearchPreviewContainer:SetPreviewResults(nil);
			self.SearchPreviewContainer:Show();
		else
			-- Action Bar search disabled, so not showing default action bar preview button
			self:HidePreviewResultSearch();
		end
		return;
	end

	local previewResults = self.searchController:RunFilterOnce(SpellSearchUtil.FilterType.Name, nil, previewSearchText);
	if previewResults and #previewResults > 0 then
		self.SearchPreviewContainer:SetPreviewResults(previewResults);
		self.SearchPreviewContainer:Show();
	else
		self:HidePreviewResultSearch();
	end
end

function ClassTalentSearchMixin:HidePreviewResultSearch()
	self.SearchPreviewContainer:Hide();
	self.SearchPreviewContainer:ClearResults();
end

function ClassTalentSearchMixin:OnPreviewSearchResultClicked(resultInfo)
	if not self:IsSearchInitialized() then
		return;
	end

	if not resultInfo or not resultInfo.name then
		return;
	end

	-- Override the search box text to the selected autocomplete talent's name
	self.SearchBox:ClearFocus();
	self.SearchBox:SetText(resultInfo.name);
	self.SearchPreviewContainer:Hide();

	-- Show the results of searching for that talent name
	self:SetFullResultSearch(resultInfo.name);
end

function ClassTalentSearchMixin:SetFullResultSearch(searchText)
	if not self:IsSearchInitialized() then
		return;
	end

	if self.searchController:IsFilterEnabled(SpellSearchUtil.FilterType.ActionBar) and searchText and SpellSearchUtil.DoStringsMatch(searchText, NotOnActionBarSearchText) then
		self:ActivateSearchFilter(SpellSearchUtil.FilterType.ActionBar);
	else
		self:ActivateSearchFilter(SpellSearchUtil.FilterType.Text, searchText);
	end
end

function ClassTalentSearchMixin:UpdateFullSearchResults()
	if not self:IsSearchInitialized() then
		return;
	end

	self.cachedSearchableNodesMap = nil;
	self.searchController:UpdateActiveSearchResults();
	self:DisplayFullSearchResults();
end

function ClassTalentSearchMixin:ClearActiveSearchState()
	if not self:IsSearchInitialized() then
		return;
	end

	self.cachedSearchableNodesMap = nil;
	self.searchController:ClearActiveSearchResults();
end

function ClassTalentSearchMixin:OnNotOnActionBarButtonClicked()
	if not self:IsSearchInitialized() then
		return;
	end

	if not self.searchController:IsFilterEnabled(SpellSearchUtil.FilterType.ActionBar) then
		return;
	end

	self.SearchBox:ClearFocus();
	self.SearchBox:SetText(NotOnActionBarSearchText);
	self.SearchPreviewContainer:Hide();

	self:ActivateSearchFilter(SpellSearchUtil.FilterType.ActionBar);
end

function ClassTalentSearchMixin:ActivateSearchFilter(filterType, ...)
	self.cachedSearchableNodesMap = nil;
	self.searchController:ActivateSearchFilter(filterType, ...);
	self:DisplayFullSearchResults();
end

function ClassTalentSearchMixin:DisplayFullSearchResults()
	for talentButton in self:EnumerateAllTalentButtons() do
		local nodeID = talentButton:GetNodeID();
		-- Not passing a specific entryID here because we want the best match result across all the node's entries
		-- Which is important for Selection nodes inidcating matches for non-selected entries
		local matchType = self:GetSearchMatchTypeForEntry(nodeID, nil);
		talentButton:SetSearchMatchType(matchType);
	end

	self.HeroTalentsContainer:UpdateSearchDisplay();
end

function ClassTalentSearchMixin:GetSearchMatchTypeForEntry(nodeID, entryID)
	if not self:IsSearchInitialized() then
		return nil;
	end

	return self.searchController:GetMatchTypeForSourceTypeEntry(SpellSearchUtil.SourceType.Trait, nodeID, entryID);
end

function ClassTalentSearchMixin:GetSearchPreviewContainer()
	return self.SearchPreviewContainer;
end

function ClassTalentSearchMixin:GetAllSearchableNodeInfos()
	if self.cachedSearchableNodesMap then
		return self.cachedSearchableNodesMap;
	end

	self.cachedSearchableNodesMap = {};
	for talentButton in self:EnumerateAllTalentButtons() do
		local nodeID = talentButton:GetNodeID();
		local nodeInfo = talentButton:GetNodeInfo();
		if nodeID and nodeInfo then
			self.cachedSearchableNodesMap[nodeID] = nodeInfo;
		end
	end
	return self.cachedSearchableNodesMap;
end