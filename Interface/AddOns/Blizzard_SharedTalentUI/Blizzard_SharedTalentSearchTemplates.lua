TalentSearchPreviewButtonMixin = {}

function TalentSearchPreviewButtonMixin:Init(elementData)
	self.talentID = elementData.talentID;
	self.talentInfo = elementData.talentInfo;
	self.owningFrame = elementData.owner;

	local name = TalentUtil.GetTalentName(self.talentInfo.overrideName, self.talentInfo.spellID);
	local icon = TalentButtonUtil.CalculateIconTexture(self.talentInfo, self.talentInfo.spellID);

	self.Name:SetText(name);
	self.Icon:SetTexture(icon);
end

function TalentSearchPreviewButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self.owningFrame:SelectPreviewResult(self.talentID);
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
end

function TalentSearchPreviewContainerMixin:SetDefaultResultButton(buttonText, buttonCallback)
	self.defaultButtonCallback = buttonCallback;
	self.DefaultResultButton.Text:SetText(buttonText);
end

function TalentSearchPreviewContainerMixin:OnShow()
	self.ScrollBox:ScrollToBegin(ScrollBoxConstants.NoScrollInterpolation);
end

function TalentSearchPreviewContainerMixin:SetPreviewResults(previewResults)
	self:ClearResults();

	if previewResults then
		local dataProvider = CreateDataProvider();

		local count = 0;
		for talentID, talentInfo in pairs(previewResults) do
			count = count + 1;
	
			dataProvider:Insert({talentID=talentID, talentInfo=talentInfo, owner=self});
	
			if count >= self.maximumEntries then
				break;
			end
		end
	
		if count > 0 then
			self.ScrollBox:SetDataProvider(dataProvider);
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
		self:SetSize(self:GetWidth(), viewHeight);
		self.ScrollBox:Show();
	-- No results but have default button, show that
	elseif self.defaultButtonCallback then
		self.ScrollBox:Hide();
		self.DefaultResultButton:Show();
		self:SetSize(self:GetWidth(), self.DefaultResultButton:GetHeight()+2);
	-- No results, no default button, show nothing
	else
		self:Hide();
	end
end

function TalentSearchPreviewContainerMixin:ClearResults()
	if self.ScrollBox:HasDataProvider() then
		self.ScrollBox:Flush();
	end

	self:UpdateResultsDisplay();
end

function TalentSearchPreviewContainerMixin:SelectPreviewResult(talentID)
	self:GetTalentFrame():SetSelectedSearchResult(talentID);
end

function TalentSearchPreviewContainerMixin:OnDefaultResultButtonClicked()
	if self.defaultButtonCallback then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		self.defaultButtonCallback();
	end
end

function TalentSearchPreviewContainerMixin:GetTalentFrame()
	return self:GetParent();
end

TalentSearchBoxMixin = {}

function TalentSearchBoxMixin:OnLoad()
	SearchBoxTemplate_OnLoad(self);

	self.HasStickyFocus = function()
		local mouseFocus = GetMouseFocus();
		-- Ensure OnFocusLost doesn't precede Search Preview result clicks
		return DoesAncestryInclude(self:GetTalentFrame().SearchPreviewContainer, GetMouseFocus()) or
		-- Ensure OnFocusLost doesn't precede our ClearButton clicks
				DoesAncestryInclude(self, GetMouseFocus());
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

function TalentSearchBoxMixin:OnEnterPressed()
	self:HidePreviewResults();
	self:UpdateFullResults(self:EvaluateSearchText());
	self:ClearFocus();
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