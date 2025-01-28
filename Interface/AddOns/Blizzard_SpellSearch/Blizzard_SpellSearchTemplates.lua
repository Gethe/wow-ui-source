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

	self.DefaultResultButton:SetScript("OnClick", GenerateClosure(self.OnDefaultResultButtonClicked, self));
	self.DefaultResultButton:SetScript("OnEnter", GenerateClosure(self.OnDefaultResultButtonEnter, self));
end

function SpellSearchPreviewContainerMixin:OnShow()
	self.ScrollBox:ScrollToBegin(ScrollBoxConstants.NoScrollInterpolation);
end

function SpellSearchPreviewContainerMixin:SetDefaultResultButton(buttonText, buttonCallback)
	self.defaultButtonCallback = buttonCallback;
	self.DefaultResultButton.Text:SetText(buttonText);
	self:UpdateResultsDisplay();
end

function SpellSearchPreviewContainerMixin:DisableDefaultResultButton()
	self.defaultButtonCallback = nil;
	self.DefaultResultButton.Text:SetText(nil);
	self:UpdateResultsDisplay();
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
	-- Have results, show results
	if self.ScrollBox:HasDataProvider() then
		self.DefaultResultButton:Hide();
		local view = self.ScrollBox:GetView();
		local viewHeight = view:GetExtent();

		if self.OverflowCount:IsShown() then
			viewHeight = viewHeight + self.OverflowCount:GetHeight();
		end

		self:SetSize(self:GetWidth(), viewHeight);
		self.ScrollBox:Show();

	-- No results but have default button, show that
	elseif self.defaultButtonCallback then
		self.ScrollBox:Hide();
		self.OverflowCount:Hide();

		self:SetSize(self:GetWidth(), self.DefaultResultButton:GetHeight()+3);
		self.DefaultResultButton:Show();

	-- No results, no default button, show nothing
	else
		self:Hide();
	end
end

function SpellSearchPreviewContainerMixin:ClearResults()
	if self.ScrollBox:HasDataProvider() then
		self.ScrollBox:Flush();
	end

	self.highlightedIndex = 0;
	self.DefaultResultButton.HighlightTexture:Hide();
	self.OverflowCount:Hide();

	self:UpdateResultsDisplay();
end

function SpellSearchPreviewContainerMixin:HighlightPreviewResult(index)
	-- No results, highlight the default button if we're using it
	if not self.ScrollBox:HasDataProvider() then
		if self.defaultButtonCallback then
			self.highlightedIndex = 1;
			self.DefaultResultButton.HighlightTexture:Show();
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

	-- No results, could only be highlighting the default button
	if not self.ScrollBox:HasDataProvider() then
		if self.defaultButtonCallback then
			self:OnDefaultResultButtonClicked();
			return true;
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

function SpellSearchPreviewContainerMixin:OnDefaultResultButtonClicked()
	if self.defaultButtonCallback then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		self.defaultButtonCallback();
	end
end

function SpellSearchPreviewContainerMixin:OnDefaultResultButtonEnter()
	self:HighlightPreviewResult(1);
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