-------------------------------- Preview Result -------------------------------

SpellSearchPreviewResultMixin = {};

function SpellSearchPreviewResultMixin:Init(elementData)
	self.resultInfo = elementData.resultInfo;
	self.resultID = self.resultInfo.resultID;
	self.index = elementData.index;
	self.owningFrame = elementData.owner;
	self.resultType = self.resultInfo.resultType;

	self.Name:SetText(self.resultInfo.name);
	self.Icon:SetTexture(self.resultInfo.icon);
	self.HighlightTexture:SetShown(false);

	self.Icon:SetDesaturated(self.resultInfo.desaturate);
end

function SpellSearchPreviewResultMixin:SetHighlighted(isHighlighted)
	self.HighlightTexture:SetShown(isHighlighted);
end

function SpellSearchPreviewResultMixin:OnClick()
	self.owningFrame:SelectPreviewResult(self.resultInfo);
end

function SpellSearchPreviewResultMixin:OnEnter()
	self.owningFrame:HighlightPreviewResult(self:GetIndex());
end

function SpellSearchPreviewResultMixin:OnShow()
	self:SetFrameLevel(self:GetParent():GetFrameLevel() + 10);
end

function SpellSearchPreviewResultMixin:GetIndex()
	return self.index;
end

function SpellSearchPreviewResultMixin:GetResultID()
	return self.resultID;
end

function SpellSearchPreviewResultMixin:GetResultType()
	return self.resultType;
end

function SpellSearchPreviewResultMixin:GetResultInfo()
	return self.resultInfo;
end

-------------------------------- Preview Results Container -------------------------------

SpellSearchPreviewContainerMixin = {};

function SpellSearchPreviewContainerMixin:OnLoad()
	local view = CreateScrollBoxListLinearView(1,3,0,0,1);
	view:SetElementInitializer("SpellSearchPreviewResultTemplate", function(button, elementData)
		button:Init(elementData);
	end);
	self.ScrollBox:SetView(view);

	local resetFunc = nil;
	local forbidden = nil;
	local function postCreate(button)
		button:SetScript("OnEnter", GenerateClosure(self.OnSuggestedResultButtonEnter, self, button));
		button:SetScript("OnClick", GenerateClosure(self.OnSuggestedResultButtonClicked, self, button));
	end
	self.suggestedResultButtonsPool = CreateFramePool("BUTTON", self, "SpellSearchSuggestedResultButtonTemplate", resetFunc, forbidden, postCreate);

	self.suggestedResultInfos = { };
end

function SpellSearchPreviewContainerMixin:OnShow()
	self.ScrollBox:ScrollToBegin(ScrollBoxConstants.NoScrollInterpolation);
end

function SpellSearchPreviewContainerMixin:AddSuggestedResult(buttonText, clickCallback, canShowPredicate)
	local info = { text = buttonText, clickCallback = clickCallback, canShowPredicate = canShowPredicate };
	table.insert(self.suggestedResultInfos, info);
end

function SpellSearchPreviewContainerMixin:SetPreviewResults(previewResults)
	self:ClearResults();

	if previewResults then
		local dataProvider = CreateDataProvider();

		local displayedCount = 0;
		local totalCount = 0;
		for _, resultInfo in ipairs(previewResults) do
			totalCount = totalCount + 1;

			if displayedCount < self.maximumEntries then
				displayedCount = displayedCount + 1;
				dataProvider:Insert({resultInfo = resultInfo, index = displayedCount, owner = self});
			end
		end
	
		if displayedCount > 0 then
			self.ScrollBox:SetDataProvider(dataProvider);
		end

		 local overflowNum = totalCount - self.maximumEntries;

		 if overflowNum > 0 then
			self.OverflowCount.Text:SetText(TALENT_FRAME_SEARCH_PREVIEW_OVERFLOW_FORMAT:format(overflowNum));
			self.OverflowCount:Show();
		 end
	end

	self:UpdateResultsDisplay();
end

function SpellSearchPreviewContainerMixin:UpdateResultsDisplay()
	self.suggestedResultButtonsPool:ReleaseAll();

	local hideDisplay = true;
	-- Have results, show results
	if self.ScrollBox:HasDataProvider() then
		local view = self.ScrollBox:GetView();
		local viewHeight = view:GetExtent();

		if self.OverflowCount:IsShown() then
			viewHeight = viewHeight + self.OverflowCount:GetHeight();
		end

		self:SetSize(self:GetWidth(), viewHeight);
		self.ScrollBox:Show();
		hideDisplay = false;

	-- No results but have suggested results, show any that are valid
	elseif #self.suggestedResultInfos > 0 then
		local numShown = 0;
		local lastButton;
		for i, info in ipairs(self.suggestedResultInfos) do
			if not info.canShowPredicate or info.canShowPredicate() then
				local button = self.suggestedResultButtonsPool:Acquire();
				button:Show();
				button.Text:SetText(info.text);
				numShown = numShown + 1;
				button.displayIndex = numShown;
				button.clickCallback = info.clickCallback;
				if lastButton then
					button:SetPoint("TOPLEFT", lastButton, "BOTTOMLEFT");
					button:SetPoint("TOPRIGHT", lastButton, "BOTTOMRIGHT");
				else
					button:SetPoint("TOPLEFT");
					button:SetPoint("TOPRIGHT");
				end
				lastButton = button;
			end
		end

		if numShown > 0 then
			self.ScrollBox:Hide();
			self.OverflowCount:Hide();
			self:SetSize(self:GetWidth(), lastButton:GetHeight() * numShown + 3);
			hideDisplay = false;
		end
	end

	-- No results, no suggested results, show nothing
	if hideDisplay then
		self:Hide();
	end
end

function SpellSearchPreviewContainerMixin:ClearResults()
	if self.ScrollBox:HasDataProvider() then
		self.ScrollBox:Flush();
	end

	self.highlightedIndex = 0;
	for button in self.suggestedResultButtonsPool:EnumerateActive() do
		button.HighlightTexture:Hide();
	end
	self.OverflowCount:Hide();

	self:UpdateResultsDisplay();
end

function SpellSearchPreviewContainerMixin:HighlightPreviewResult(index)
	-- No results, highlight a suggested result button if there are any
	if not self.ScrollBox:HasDataProvider() then
		local numButtons = self.suggestedResultButtonsPool:GetNumActive();
		if numButtons > 0 then
			-- Keep index within bounds
			index = (index - 1) % self.suggestedResultButtonsPool:GetNumActive() + 1;

			for button in self.suggestedResultButtonsPool:EnumerateActive() do
				if button.displayIndex == index then
					self.highlightedIndex = index;
					button.HighlightTexture:Show();
				else
					button.HighlightTexture:Hide();
				end
			end
		end
		return;
	end

	local numResults = self.ScrollBox:GetDataProviderSize();

	-- Keep index within bounds
	index = (index - 1) % numResults + 1;

	self.highlightedIndex = index;

	-- Highlight the right result entry, un-highlight others
	self.ScrollBox:ForEachFrame(function(frame, elementData)
		frame:SetHighlighted(frame:GetIndex() == self.highlightedIndex);
	end);
end

function SpellSearchPreviewContainerMixin:CycleHighlightedResultUp()
	self:HighlightPreviewResult(self.highlightedIndex - 1);
end

function SpellSearchPreviewContainerMixin:CycleHighlightedResultDown()
	self:HighlightPreviewResult(self.highlightedIndex + 1);
end

function SpellSearchPreviewContainerMixin:SelectHighlightedResult()
	-- Not currently highlighting anything, nothing to select
	if not self.highlightedIndex or self.highlightedIndex <= 0 then
		return false;
	end

	-- No results, could only be highlighting a suggested result button
	if not self.ScrollBox:HasDataProvider() then
		for button in self.suggestedResultButtonsPool:EnumerateActive() do
			if button.displayIndex == self.highlightedIndex then
				self:OnSuggestedResultButtonClicked(button);
				return true;
			end
		end
		return false;
	end

	self.ScrollBox:ForEachFrame(function(frame, elementData)
		if frame:GetIndex() == self.highlightedIndex then
			self:SelectPreviewResult(frame:GetResultInfo());
			return true;
		end
	end);

	return false;
end

function SpellSearchPreviewContainerMixin:SelectPreviewResult(resultInfo)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:GetParent():OnPreviewSearchResultClicked(resultInfo);
end

function SpellSearchPreviewContainerMixin:OnSuggestedResultButtonClicked(button)
	if button.clickCallback then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		button.clickCallback();
	end
end

function SpellSearchPreviewContainerMixin:OnSuggestedResultButtonEnter(button)
	self:HighlightPreviewResult(button.displayIndex);
end


-------------------------------- Search Box -------------------------------

SpellSearchBoxMixin = {};

function SpellSearchBoxMixin:OnLoad()
	SearchBoxTemplate_OnLoad(self);

	self.HasStickyFocus = function()
		local searchPreviewContainer = self:GetSearchPreviewContainer();
		local mouseFoci = GetMouseFoci();
		-- Ensure OnFocusLost doesn't precede Search Preview result clicks
		return (searchPreviewContainer and DoesAncestryIncludeAny(searchPreviewContainer, mouseFoci)) or
		-- Ensure OnFocusLost doesn't precede our ClearButton clicks
				DoesAncestryIncludeAny(self, mouseFoci);
	end

	self.clearButton:SetScript("OnClick", function(btn)
		self:UpdateFullResults(nil);
		SearchBoxTemplateClearButton_OnClick(btn);
	end);
end

function SpellSearchBoxMixin:OnTextChanged()
	SearchBoxTemplate_OnTextChanged(self);

	if self:HasFocus() then
		self:UpdatePreviewResults(self:EvaluateSearchText());
	end
end

function SpellSearchBoxMixin:OnKeyDown(key)
	if key == "UP" or key == "DOWN" then
		local searchPreviewContainer = self:GetSearchPreviewContainer();
		if not searchPreviewContainer then
			return;
		end

		if key == "UP" then
			searchPreviewContainer:CycleHighlightedResultUp();
		elseif key == "DOWN" then
			searchPreviewContainer:CycleHighlightedResultDown();
		end
	end
end

function SpellSearchBoxMixin:OnEnterPressed()
	-- Try having the Preview Container handle the input by selecting its currently highlighted result
	local previewContainer = self:GetSearchPreviewContainer();
	local isHandledByPreview = previewContainer and previewContainer:SelectHighlightedResult();

	-- Otherwise, handle it with the current text input
	if not isHandledByPreview then
		self:HidePreviewResults();
		self:UpdateFullResults(self:EvaluateSearchText());
		self:ClearFocus();
	end
end

function SpellSearchBoxMixin:OnFocusLost()
	SearchBoxTemplate_OnEditFocusLost(self);
	self:HidePreviewResults();
end

function SpellSearchBoxMixin:OnFocusGained()
	SearchBoxTemplate_OnEditFocusGained(self);
	self:UpdatePreviewResults(self:EvaluateSearchText());
end

function SpellSearchBoxMixin:SetSearchText(searchText)
	self:SetText(searchText);
end

function SpellSearchBoxMixin:EvaluateSearchText()
	local searchText = self:GetText();

	if strlen(searchText) >= MIN_CHARACTER_SEARCH then
		return searchText;
	else
		return nil;
	end
end

function SpellSearchBoxMixin:UpdatePreviewResults(searchText)
	self:GetSearchFrame():SetPreviewResultSearch(searchText);
end

function SpellSearchBoxMixin:HidePreviewResults()
	self:GetSearchFrame():HidePreviewResultSearch();
end

function SpellSearchBoxMixin:UpdateFullResults(searchText)
	self:GetSearchFrame():SetFullResultSearch(searchText);
end

function SpellSearchBoxMixin:GetSearchFrame()
	return self:GetParent();
end

function SpellSearchBoxMixin:GetSearchPreviewContainer()
	local searchFrame = self:GetSearchFrame();
	return searchFrame and searchFrame:GetSearchPreviewContainer() or nil;
end
