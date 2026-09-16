
AutoCompletePopupListResultMixin = {};

function AutoCompletePopupListResultMixin:Init(elementData)
	self.resultInfo = elementData.resultInfo;
	self.index = elementData.index;
	self.owningFrame = elementData.owner;
	self:SetWidth(self.owningFrame:GetWidth());

	self.Name:ClearAllPoints();
	self.Name:SetPoint("RIGHT", -5, 0);

	local hasTexture = elementData.displayTexture ~= nil;
	self.Icon:SetShown(hasTexture);
	self.IconFrame:SetShown(hasTexture);
	if hasTexture then
		self.Icon:SetTexture(elementData.displayTexture);
		self.Name:SetPoint("LEFT", self.Icon, "RIGHT", 5, 1);
	else
		self.Name:SetPoint("LEFT", 5, 1);
	end

	self.Name:SetText(elementData.displayText);

	local hasSubtext = elementData.subtext ~= nil;
	self.Subtext:SetShown(hasSubtext);

	if hasSubtext then
		self.Name:SetPoint("TOP", 0, -2);
		self.Subtext:SetText(elementData.subtext or "");
	end

	self.Name:SetMaxLines(hasSubtext and 1 or 2);

	self.HighlightTexture:Hide();
end

function AutoCompletePopupListResultMixin:SetHighlighted(isHighlighted)
	self.HighlightTexture:SetShown(isHighlighted);
end

function AutoCompletePopupListResultMixin:OnClick()
	self.owningFrame:SelectResult(self.resultInfo);
end

function AutoCompletePopupListResultMixin:OnEnter()
	self.owningFrame:HighlightResult(self:GetIndex());

	if self.Name:IsTruncated() or self.Subtext:IsTruncated() then
		local tooltip = GetAppropriateTooltip();
		tooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_AddColoredLine(tooltip, self.Name:GetText(), HIGHLIGHT_FONT_COLOR);
		GameTooltip_AddColoredLine(tooltip, self.Subtext:GetText(), GRAY_FONT_COLOR);
		tooltip:Show();
	end
end

function AutoCompletePopupListResultMixin:OnLeave()
	GetAppropriateTooltip():Hide();
end

function AutoCompletePopupListResultMixin:OnShow()
	self:SetFrameLevel(self:GetParent():GetFrameLevel() + 10);
end

function AutoCompletePopupListResultMixin:GetIndex()
	return self.index;
end

function AutoCompletePopupListResultMixin:GetResultInfo()
	return self.resultInfo;
end

AutoCompletePopupListMixin = {};

function AutoCompletePopupListMixin:OnLoad()
	local view = CreateScrollBoxListLinearView(1, 3, 0, 0, 1);
	view:SetElementInitializer("AutoCompletePopupListResultTemplate", function(button, elementData)
		button:Init(elementData);
	end);
	self.ScrollBox:SetView(view);
end

function AutoCompletePopupListMixin:OnShow()
	self.ScrollBox:ScrollToBegin(ScrollBoxConstants.NoScrollInterpolation);
end

function AutoCompletePopupListMixin:UpdateResults()
	assertsafe(self.resultsListCallback, "AutoCompletePopupLists require a resultsListCallback. Use :SetResultsListCallback");
	if not self.resultsListCallback then
		self:ClearResults();
		return;
	end

	local numResults, resultsList, displayInfoCallback = self.resultsListCallback();
	self:SetResults(numResults, resultsList, displayInfoCallback);
	self:HighlightResult(1);
end

function AutoCompletePopupListMixin:SetResults(numResults, resultsList, displayInfoCallback)
	self:ClearResults();

	local dataProvider = CreateDataProvider();

	local displayedCount = 0;
	for i, resultInfo in ipairs(resultsList or {}) do
		if displayedCount > self.maximumEntries then
			break;
		end

		displayedCount = displayedCount + 1;

		local displayText = nil;
		local subtext = nil;
		local displayTexture = nil;
		if displayInfoCallback then
			displayText, subtext, displayTexture = displayInfoCallback(resultInfo);
		end

		dataProvider:Insert({ displayText = displayText or resultInfo.text, subtext = subtext, displayTexture = displayTexture, resultInfo = resultInfo, index = displayedCount, owner = self, });
	end

	if displayedCount > 0 then
		self.ScrollBox:SetDataProvider(dataProvider);
	end

	local overflowNum = numResults - self.maximumEntries;
	if overflowNum > 0 then
		self.OverflowCount.Text:SetText(TALENT_FRAME_SEARCH_PREVIEW_OVERFLOW_FORMAT:format(overflowNum));
		self.OverflowCount:Show();
	end

	self:UpdateResultsDisplay();
end

function AutoCompletePopupListMixin:UpdateResultsDisplay()
	if self:HasResults() then
		local view = self.ScrollBox:GetView();
		local viewHeight = view:GetExtent();

		if self.OverflowCount:IsShown() then
			viewHeight = viewHeight + self.OverflowCount:GetHeight();
		end

		self:SetSize(self:GetWidth(), viewHeight);
		self.ScrollBox:Show();
		self:Show();
	else
		self:Hide();
	end
end

function AutoCompletePopupListMixin:ClearResults()
	if self:HasResults() then
		self.ScrollBox:Flush();
	end

	self.highlightedIndex = 0;
	self.OverflowCount:Hide();

	self:UpdateResultsDisplay();
end

function AutoCompletePopupListMixin:HighlightResult(index)
	if not self:HasResults() then
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

function AutoCompletePopupListMixin:CycleHighlightedResultUp()
	self:HighlightResult(self.highlightedIndex - 1);
end

function AutoCompletePopupListMixin:CycleHighlightedResultDown()
	self:HighlightResult(self.highlightedIndex + 1);
end

function AutoCompletePopupListMixin:SelectHighlightedResult()
	-- Not currently highlighting anything, nothing to select
	if not self.highlightedIndex or self.highlightedIndex <= 0 then
		return false;
	end

	if not self:HasResults() then
		return false;
	end

	return not not self.ScrollBox:ForEachFrame(function(frame, elementData)
		if frame:GetIndex() == self.highlightedIndex then
			self:SelectResult(frame:GetResultInfo());
			return true;
		end
	end);
end

function AutoCompletePopupListMixin:HasResults()
	return self.ScrollBox:HasDataProvider();
end

function AutoCompletePopupListMixin:SelectResult(resultInfo)
	if self.selectResultCallback then
		self.selectResultCallback(resultInfo);
	end
end

function AutoCompletePopupListMixin:GetMaximumEntries()
	return self.maximumEntries;
end

function AutoCompletePopupListMixin:SetSelectResultCallback(selectResultCallback)
	self.selectResultCallback = selectResultCallback;
end

-- resultsListCallback: function () -> numResults, resultsList, displayInfoCallback
-- numResults: if 0, the other returns will be ignored.
-- resultsList: should be a list of resultInfo tables. Only the first 'maximumEntries' number of entries will be considered.
-- displayInfoCallback (optional): function (resultInfo) -> displayText, subtext, displayTexture
-- displayInfoCallback can be used to specify display info for a result. If not present, resultInfo.text will be used.
function AutoCompletePopupListMixin:SetResultsListCallback(resultsListCallback)
	self.resultsListCallback = resultsListCallback;
	self:UpdateResults();
end
