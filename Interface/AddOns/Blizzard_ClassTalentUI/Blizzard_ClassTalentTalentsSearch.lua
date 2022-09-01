ClassTalentTalentsSearchMixin = {};

function ClassTalentTalentsSearchMixin:SetPreviewResultSearch(previewSearchText)
	-- Overrides TalentFrameBaseMixin.
	if not previewSearchText then
		-- TODO:: Add Default Autocomplete Search result
		--self.SearchPreviewContainer:SetPreviewResults(nil);
		--self.SearchPreviewContainer:Show();
		self.SearchPreviewContainer:Hide();
		self.SearchPreviewContainer:ClearResults();
		return;
	end

	local previewResults = {};
	local lowerPreviewSearchText = previewSearchText:lower();
	local anyResults = false;

	for talentButton in self:EnumerateAllTalentButtons() do
		local talentNodeInfo = talentButton:GetTalentNodeInfo();
		-- Evaluating every entryID as some buttons have multiple choice talents
		if talentNodeInfo and talentNodeInfo.entryIDs then
			for i, entryID in ipairs(talentNodeInfo.entryIDs) do
				local talentID = self:GetAndCacheEntryInfo(entryID).talentID;
				if talentID then
					local talentInfo = self:GetAndCacheTalentInfo(talentID);
					if talentInfo then
						local lowerTalentName = TalentUtil.GetTalentNameFromInfo(talentInfo):lower();
						if lowerTalentName:find(lowerPreviewSearchText) then
							anyResults = true;
							previewResults[talentID] = talentInfo;
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
	local newSearch = searchText and searchText:lower() or nil;
	if self.searchString == newSearch then
		return;
	end

	self.searchString = newSearch;
	self:UpdateFullSearchResults();
end

function ClassTalentTalentsSearchMixin:SetSelectedSearchResult(talentID)
	-- Overrides TalentFrameBaseMixin.
	local talentInfo = self:GetAndCacheTalentInfo(talentID);
	local talentName = TalentUtil.GetTalentNameFromInfo(talentInfo);
	-- Override the search box text to the selected autocomplete talent's name
	self.SearchBox:ClearFocus();
	self.SearchBox:SetText(talentName);
	self.SearchPreviewContainer:Hide();
	-- Show the results of searching for that talent name
	self:SetFullResultSearch(talentName);
end

function ClassTalentTalentsSearchMixin:UpdateFullSearchResults()
	self.searchStringExactMatchDescription = nil;

	-- No search, clear out all matches
	if not self.searchString then
		for talentButton in self:EnumerateAllTalentButtons() do
			talentButton:SetSearchMatchType(nil);
		end
		return;
	end

	-- Get the description of any "Exact Match" talent so it can be used to find Related Match talents
	self.searchStringExactMatchDescription = self:GetExactSearchMatchDescription();

	for talentButton in self:EnumerateAllTalentButtons() do
		local talentNodeInfo = talentButton:GetTalentNodeInfo();
		local bestMatchTypeForButton = nil;

		if talentNodeInfo and talentNodeInfo.entryIDs then
			-- Evaluating every entryID as some buttons have multiple choice talents
			-- We want to mark those buttons with the "best" match type out of those entries
			for i, entryID in ipairs(talentNodeInfo.entryIDs) do
				local matchTypeForEntry = self:GetSearchMatchTypeForEntryID(entryID);

				if matchTypeForEntry and (not bestMatchTypeForButton or matchTypeForEntry > bestMatchTypeForButton) then
					bestMatchTypeForButton = matchTypeForEntry;
				end
			end
		end

		talentButton:SetSearchMatchType(bestMatchTypeForButton);
	end
end

-- TODO:: Add Default Autocomplete Search result
-- function ClassTalentTalentsSearchMixin:OnDefaultSearchButtonClicked()
-- 	--self.SearchPreviewContainer:Hide();
-- end

function ClassTalentTalentsSearchMixin:GetSearchMatchTypeForEntryID(entryID)
	if not self.searchString then
		return nil;
	end

	local exactMatchDescription = self.searchStringExactMatchDescription;
	local talentInfo = self:GetTalentInfoForEntry(entryID);
	if talentInfo then
		local lowerTalentName = TalentUtil.GetTalentNameFromInfo(talentInfo):lower();
		local lowerTalentDescription = TalentUtil.GetTalentDescriptionFromInfo(talentInfo):lower();

		-- Exact Match -> search matches name exactly
		if lowerTalentName == self.searchString then
			return TalentButtonUtil.SearchMatchType.ExactMatch;
		-- Match -> search is in name or description
		elseif lowerTalentName:find(self.searchString) or lowerTalentDescription:find(self.searchString) then
			return TalentButtonUtil.SearchMatchType.Match;
		-- Related Match -> name is in exact match description
		elseif exactMatchDescription and exactMatchDescription:find(lowerTalentName) then
			return TalentButtonUtil.SearchMatchType.RelatedMatch;
		-- No Match
		else
			return nil;
		end
	end
end

function ClassTalentTalentsSearchMixin:GetExactSearchMatchDescription()
	local lowerExactMatchDescription = nil;
	for talentButton in self:EnumerateAllTalentButtons() do
		local talentNodeInfo = talentButton:GetTalentNodeInfo();
		if talentNodeInfo and talentNodeInfo.entryIDs then
			-- Evaluating every entryID as some buttons have multiple choice talents
			for i, entryID in ipairs(talentNodeInfo.entryIDs) do
				local talentInfo = self:GetTalentInfoForEntry(entryID);
				if talentInfo and TalentUtil.GetTalentNameFromInfo(talentInfo):lower() == self.searchString then
					lowerExactMatchDescription = TalentUtil.GetTalentDescriptionFromInfo(talentInfo):lower();
					return lowerExactMatchDescription;
				end
			end
		end
	end
	return nil;
end