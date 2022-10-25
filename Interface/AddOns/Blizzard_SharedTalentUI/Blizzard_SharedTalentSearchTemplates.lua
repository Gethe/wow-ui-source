TalentSearchPreviewButtonMixin = {}

function TalentSearchPreviewButtonMixin:Init(elementData)
	self.definitionID = elementData.definitionID;
	self.definitionInfo = elementData.definitionInfo;
	self.index = elementData.index;
	self.owningFrame = elementData.owner;

	local name = TalentUtil.GetTalentName(self.definitionInfo.overrideName, self.definitionInfo.spellID);
	local icon = TalentButtonUtil.CalculateIconTexture(self.definitionInfo, self.definitionInfo.spellID);

	self.Name:SetText(name);
	self.Icon:SetTexture(icon);
	self.HighlightTexture:SetShown(false);
end

function TalentSearchPreviewButtonMixin:SetHighlighted(isHighlighted)
	self.HighlightTexture:SetShown(isHighlighted);
end

function TalentSearchPreviewButtonMixin:GetIndex()
	return self.index;
end

function TalentSearchPreviewButtonMixin:GetDefinitionID()
	return self.definitionID;
end

function TalentSearchPreviewButtonMixin:OnClick()
	self.owningFrame:SelectPreviewResult(self:GetDefinitionID());
end

function TalentSearchPreviewButtonMixin:OnEnter()
	self.owningFrame:HighlightPreviewResult(self:GetIndex());
end

function TalentSearchPreviewButtonMixin:OnShow()
	self:SetFrameLevel(self:GetParent():GetFrameLevel() + 10);
end


TalentSearchPreviewContainerMixin = {}

function TalentSearchPreviewContainerMixin:OnLoad()
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("TalentSearchPreviewButtonTemplate", function(button, elementData)
		button:Init(elementData);
	end);
	view:SetPadding(1,3,0,0,1);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
	
	self.DefaultResultButton:SetScript("OnClick", GenerateClosure(self.OnDefaultResultButtonClicked, self));
	self.DefaultResultButton:SetScript("OnEnter", GenerateClosure(self.OnDefaultResultButtonEnter, self));
end

function TalentSearchPreviewContainerMixin:SetDefaultResultButton(buttonText, buttonCallback)
	self.defaultButtonCallback = buttonCallback;
	self.DefaultResultButton.Text:SetText(buttonText);
end

function TalentSearchPreviewContainerMixin:DisableDefaultResultButton()
	self.defaultButtonCallback = nil;
	self.DefaultResultButton.Text:SetText(nil);
end

function TalentSearchPreviewContainerMixin:OnShow()
	self.ScrollBox:ScrollToBegin(ScrollBoxConstants.NoScrollInterpolation);
end

function TalentSearchPreviewContainerMixin:SetPreviewResults(previewResults)
	self:ClearResults();

	if previewResults then
		local dataProvider = CreateDataProvider();

		local index = 0;
		local totalCount = 0;
		for definitionID, definitionInfo in pairs(previewResults) do
			totalCount = totalCount + 1;

			if totalCount <= self.maximumEntries then
				index = index + 1;
				dataProvider:Insert({definitionID=definitionID, definitionInfo=definitionInfo, index=index, owner=self});
			end
		end
	
		if index > 0 then
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

function TalentSearchPreviewContainerMixin:UpdateResultsDisplay()
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

function TalentSearchPreviewContainerMixin:ClearResults()
	if self.ScrollBox:HasDataProvider() then
		self.ScrollBox:Flush();
	end

	self.highlightedIndex = 0;
	self.DefaultResultButton.HighlightTexture:Hide();
	self.OverflowCount:Hide();

	self:UpdateResultsDisplay();
end

function TalentSearchPreviewContainerMixin:HighlightPreviewResult(index)
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

function TalentSearchPreviewContainerMixin:CycleHighlightedResultUp()
	self:HighlightPreviewResult(self.highlightedIndex - 1);
end

function TalentSearchPreviewContainerMixin:CycleHighlightedResultDown()
	self:HighlightPreviewResult(self.highlightedIndex + 1);
end

function TalentSearchPreviewContainerMixin:SelectHighlightedResult()
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
			self:SelectPreviewResult(frame:GetDefinitionID());
			return true;
		end
	end);

	return false;
end

function TalentSearchPreviewContainerMixin:SelectPreviewResult(definitionID)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:GetTalentFrame():SetSelectedSearchResult(definitionID);
end

function TalentSearchPreviewContainerMixin:OnDefaultResultButtonClicked()
	if self.defaultButtonCallback then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		self.defaultButtonCallback();
	end
end

function TalentSearchPreviewContainerMixin:OnDefaultResultButtonEnter()
	self:HighlightPreviewResult(1);
end

function TalentSearchPreviewContainerMixin:GetTalentFrame()
	return self:GetParent();
end


TalentSearchBoxMixin = {}

function TalentSearchBoxMixin:OnLoad()
	SearchBoxTemplate_OnLoad(self);

	self.HasStickyFocus = function()
		local searchPreviewContainer = self:GetSearchPreviewContainer();
		local mouseFocus = GetMouseFocus();
		-- Ensure OnFocusLost doesn't precede Search Preview result clicks
		return (searchPreviewContainer and DoesAncestryInclude(searchPreviewContainer, mouseFocus)) or
		-- Ensure OnFocusLost doesn't precede our ClearButton clicks
				DoesAncestryInclude(self, mouseFocus);
	end

	self.clearButton:SetScript("OnClick", function(btn)
		self:UpdateFullResults(nil);
		SearchBoxTemplateClearButton_OnClick(btn);
	end);
end

function TalentSearchBoxMixin:OnTextChanged()
	SearchBoxTemplate_OnTextChanged(self);

	if self:HasFocus() then
		self:UpdatePreviewResults(self:EvaluateSearchText());
	end
end

function TalentSearchBoxMixin:OnKeyDown(key)
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

function TalentSearchBoxMixin:OnEnterPressed()
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

function TalentSearchBoxMixin:OnFocusLost()
	SearchBoxTemplate_OnEditFocusLost(self);
	self:HidePreviewResults();
end

function TalentSearchBoxMixin:OnFocusGained()
	SearchBoxTemplate_OnEditFocusGained(self);
	self:UpdatePreviewResults(self:EvaluateSearchText());
end

function TalentSearchBoxMixin:SetSearchText(searchText)
	self:SetText(searchText);
end

function TalentSearchBoxMixin:EvaluateSearchText()
	local searchText = self:GetText();

	if strlen(searchText) >= MIN_CHARACTER_SEARCH then
		return searchText;
	else
		return nil;
	end
end

function TalentSearchBoxMixin:UpdatePreviewResults(searchText)
	self:GetTalentFrame():SetPreviewResultSearch(searchText);
end

function TalentSearchBoxMixin:HidePreviewResults()
	self:GetTalentFrame():HidePreviewResultSearch();
end

function TalentSearchBoxMixin:UpdateFullResults(searchText)
	self:GetTalentFrame():SetFullResultSearch(searchText);
end

function TalentSearchBoxMixin:GetTalentFrame()
	return self:GetParent();
end

function TalentSearchBoxMixin:GetSearchPreviewContainer()
	local talentFrame = self:GetTalentFrame();
	return talentFrame and talentFrame:GetSearchPreviewContainer() or nil;
end