
local ItemListState = {
	NoSearch = 1,
	NoResults = 2,
	ResultsPending = 3,
	ShowResults = 4,
};


AuctionHouseItemListLineMixin = CreateFromMixins(ScrollListLineMixin, TableBuilderRowMixin);

function AuctionHouseItemListLineMixin:OnClick(button)
	-- Overrides register for right click as well, ensure this is a left click. 
	if button == "LeftButton" then
		self:GetItemList():SetSelectedEntry(self.rowData);
	end
end

function AuctionHouseItemListLineMixin:OnLineEnter()
	self.HighlightTexture:Show();
	self:GetItemList():OnEnterListLine(self, self.rowData);
end

function AuctionHouseItemListLineMixin:OnLineLeave()
	self.HighlightTexture:Hide();
	self:GetItemList():OnLeaveListLine(self, self.rowData);
end

function AuctionHouseItemListLineMixin:GetItemList()
	local scrollFrame = self:GetParent():GetParent();
	return scrollFrame:GetParent();
end

function AuctionHouseItemListLineMixin:GetRowData()
	return self.rowData;
end


AuctionHouseFavoritableLineMixin = {};

function AuctionHouseFavoritableLineMixin:InitLine(dropDown, dropDownToggleCallback)
	self.dropDown = dropDown;
	self.dropDownToggleCallback = dropDownToggleCallback;
end

function AuctionHouseFavoritableLineMixin:OnClick(button, ...)
	AuctionHouseItemListLineMixin.OnClick(self, button, ...)

	if button == "RightButton" and self.dropDown and self.dropDownToggleCallback then
		self.dropDownToggleCallback(self, self.dropDown);
	end
end


AuctionHouseItemListMixin = {};

function AuctionHouseItemListMixin:OnLoad()
	AuctionHouseBackgroundMixin.OnLoad(self);
	
	self.RefreshFrame:SetShown(not self.hideRefreshFrame);
	self.RefreshFrame:SetPoint("TOPRIGHT", self.refreshFrameXOffset or 0, self.refreshFrameYOffset or 0);

	self.NineSlice:SetPoint("BOTTOMRIGHT", -22, 0);
end

-- searchStartedFunc should return whether or not a search has been started, and optionally a 2nd return for search results text.
-- getEntry should take an index between 1 and getNumEntries() and return result data to be used in the TableBuilder.
-- getNumEntries should return the number of valid indices for getEntry, 0 for none.
-- (optional) hasFullResultsFunc should return true if there are pending results. This determines whether we show a spinner, or "No Results" if getNumEntries() == 0.
function AuctionHouseItemListMixin:SetDataProvider(searchStartedFunc, getEntry, getNumEntries, hasFullResultsFunc)
	self.searchStartedFunc = searchStartedFunc;
	self.getEntry = getEntry;
	self.getNumEntries = getNumEntries;
	self.hasFullResultsFunc = hasFullResultsFunc;

	if self.tableBuilder then
		self.tableBuilder:SetDataProvider(self.getEntry);
	end
end

-- quantityFunc: Returns the total quantity of items, instead of lines of results.
-- refreshResultsFunc: Function to call when the fresh button is pressed to refresh results.
function AuctionHouseItemListMixin:SetRefreshFrameFunctions(totalQuantityFunc, refreshResultsFunc)
	self.totalQuantityFunc = totalQuantityFunc;
	self.refreshResultsFunc = refreshResultsFunc;
	self.RefreshFrame:SetRefreshCallback(refreshResultsFunc);
end

function AuctionHouseItemListMixin:SetTableBuilderLayout(tableBuilderLayoutFunction)
	self.tableBuilderLayoutFunction = tableBuilderLayoutFunction;
	self.tableBuilderLayoutDirty = true;

	if self.isInitialized and self:IsShown() then
		self:UpdateTableBuilderLayout();
	end
end

function AuctionHouseItemListMixin:SetRefreshCallback(refreshCallback)
	self.refreshCallback = refreshCallback;
end

function AuctionHouseItemListMixin:UpdateTableBuilderLayout()
	if self.tableBuilderLayoutDirty then
		self.tableBuilder:Reset();
		self.tableBuilderLayoutFunction(self.tableBuilder);
		self.tableBuilder:SetTableWidth(self.ScrollFrame:GetWidth());
		self.tableBuilder:Arrange();
		self.tableBuilderLayoutDirty = false;
	end
end

function AuctionHouseItemListMixin:SetSelectionCallback(selectionCallback)
	self.selectionCallback = selectionCallback;
end

function AuctionHouseItemListMixin:SetHighlightCallback(highlightCallback)
	self.highlightCallback = highlightCallback;
end

function AuctionHouseItemListMixin:SetLineTemplate(lineTemplate, ...)
	self.lineTemplate = lineTemplate;
	self.initArgs = { ... };
end

function AuctionHouseItemListMixin:SetCustomError(errorText)
	self:SetState(ItemListState.NoResults);
	self.ResultsText:Show();
	self.ResultsText:SetText(errorText);
end

function AuctionHouseItemListMixin:Init()
	if self.isInitialized then
		return;
	end

	self.SpinnerAnim:Play();

	self.ScrollFrame.update = function()
		self:RefreshScrollFrame();
	end;

	HybridScrollFrame_CreateButtons(self.ScrollFrame, self.lineTemplate or "AuctionHouseItemListLineTemplate", 0, 0);
	
	for i, button in ipairs(self.ScrollFrame.buttons) do
		if self.hideStripes then
			-- Force the texture to stay hidden through button clicks, etc.
			button:GetNormalTexture():SetAlpha(0);
		else
			local oddRow = (i % 2) == 1;
			button:GetNormalTexture():SetAtlas(oddRow and "auctionhouse-rowstripe-1" or "auctionhouse-rowstripe-2");
		end

		if self.lineTemplate then
			button:InitLine(unpack(self.initArgs));
		end
	end

	HybridScrollFrame_SetDoNotHideScrollBar(self.ScrollFrame, true);

	local tableBuilder = CreateTableBuilder(HybridScrollFrame_GetButtons(self.ScrollFrame), AuctionHouseTableBuilderMixin);
	self.tableBuilder = tableBuilder;

	if self.getEntry then
		self.tableBuilder:SetDataProvider(self.getEntry);
	end

	self.isInitialized = true;
end

function AuctionHouseItemListMixin:SetLineOnEnterCallback(callback)
	self.lineOnEnterCallback = callback;
end

function AuctionHouseItemListMixin:OnEnterListLine(line, rowData)
	if self.lineOnEnterCallback then
		self.lineOnEnterCallback(line, rowData);
	end
end

function AuctionHouseItemListMixin:SetLineOnLeaveCallback(callback)
	self.lineOnLeaveCallback = callback;
end

function AuctionHouseItemListMixin:OnLeaveListLine(line, rowData)
	if self.lineOnLeaveCallback then
		self.lineOnLeaveCallback(line, rowData);
	end
end

function AuctionHouseItemListMixin:SetSelectedEntry(rowData)
	if self.selectionCallback then
		if not self.selectionCallback(rowData) then
			return;
		end
	end

	self.selectedRowData = rowData;
	self:DirtyScrollFrame();
end

function AuctionHouseItemListMixin:GetSelectedEntry()
	return self.selectedRowData;
end

function AuctionHouseItemListMixin:OnShow()
	self:Init();
	self:UpdateTableBuilderLayout();
	self:RefreshScrollFrame();

	if self.refreshResultsFunc then
		self.refreshResultsFunc();
	end
end

function AuctionHouseItemListMixin:OnUpdate()
	if self.scrollFrameDirty then
		self:RefreshScrollFrame();
	end
end

function AuctionHouseItemListMixin:Reset()
	if self:GetScrollOffset() == 0 then
		self:RefreshScrollFrame();
	else
		self.ScrollFrame.scrollBar:SetValue(0);
	end
end

function AuctionHouseItemListMixin:SetState(state)
	if self.state == state then
		return;
	end

	self.state = state;

	local showResultsText = state ~= ItemListState.ShowResults and state ~= ItemListState.ResultsPending;
	self.ResultsText:SetShown(showResultsText);
	self.LoadingSpinner:Hide();
	if state == ItemListState.NoSearch then
		local searchResultsText = self.searchStartedFunc and select(2, self.searchStartedFunc());
		self.ResultsText:SetText(searchResultsText or "");
	elseif state == ItemListState.NoResults then
		self.ResultsText:SetText(BROWSE_NO_RESULTS);
	elseif state == ItemListState.ResultsPending then
		self.LoadingSpinner:Show();
	end

	self:UpdateRefreshFrame();

	if state ~= ItemListState.ShowResults then
		local buttons = HybridScrollFrame_GetButtons(self.ScrollFrame);
		for i, button in ipairs(buttons) do
			button:Hide();
		end

		local totalHeight = 0;
		local displayedHeight = 0;
		HybridScrollFrame_Update(self.ScrollFrame, totalHeight, displayedHeight);
	end
end

function AuctionHouseItemListMixin:SetSelectedEntryByCondition(condition, scrollTo)
	if not self.getNumEntries then
		return;
	end

	local numEntries = self.getNumEntries();
	for i = 1, numEntries do
		local rowData = self.getEntry(i);
		if condition(rowData) then
			self:SetSelectedEntry(rowData);
			self:ScrollToEntryIndex(i);
			return;
		end
	end

	self:SetSelectedEntry(nil);
	self:RefreshScrollFrame();
end

function AuctionHouseItemListMixin:ScrollToEntryIndex(entryIndex)
	if not self.isInitialized then
		return;
	end

	local buttons = HybridScrollFrame_GetButtons(self.ScrollFrame);
	local buttonHeight = buttons[1]:GetHeight();
	local currentScrollOffset = self:GetScrollOffset();
	local newScrollOffset = entryIndex - 1;
	if newScrollOffset < currentScrollOffset or newScrollOffset > (currentScrollOffset + #buttons) then
		self.ScrollFrame.scrollBar:SetValue(newScrollOffset * buttonHeight);
	else
		self:RefreshScrollFrame();
	end
end

function AuctionHouseItemListMixin:SetScrollOffset(scrollOffset)
	if not self.isInitialized then
		return;
	end

	local buttons = HybridScrollFrame_GetButtons(self.ScrollFrame);
	local buttonHeight = buttons[1]:GetHeight();
	if scrollOffset ~= self:GetScrollOffset() then
		self.ScrollFrame.scrollBar:SetValue(scrollOffset * buttonHeight);
	else
		self:RefreshScrollFrame();
	end
end

function AuctionHouseItemListMixin:GetScrollOffset()
	return HybridScrollFrame_GetOffset(self.ScrollFrame);
end

function AuctionHouseItemListMixin:GetNumButtons()
	local buttons = HybridScrollFrame_GetButtons(self.ScrollFrame);
	return buttons and #buttons or 0;
end

function AuctionHouseItemListMixin:UpdateRefreshFrame()
	if not self.RefreshFrame:IsShown() then
		return;
	end

	if state == ItemListState.NoSearch then
		self.RefreshFrame:Deactivate();
	elseif state == ItemListState.NoResults then
		self.RefreshFrame:SetQuantity(0);
	elseif state == ItemListState.ResultsPending then
		self.RefreshFrame:Deactivate();
	else -- state == ItemListState.ShowResults
		self.RefreshFrame:SetQuantity(self.totalQuantityFunc and self.totalQuantityFunc() or 0);
	end
end

function AuctionHouseItemListMixin:DirtyScrollFrame()
	self.scrollFrameDirty = true;
end

function AuctionHouseItemListMixin:RefreshScrollFrame()
	self.scrollFrameDirty = false;

	if not self.isInitialized or not self:IsShown() then
		return;
	end

	if not self.getNumEntries then
		error("Data provider not set. Use AuctionHouseItemListMixin:SetDataProvider.");
		return;
	end

	if self.searchStartedFunc and not self.searchStartedFunc() then
		self:SetState(ItemListState.NoSearch);
		return;
	end

	local numResults = self.getNumEntries();
	if numResults == 0 then
		local hasFullResults = not self.hasFullResultsFunc or self.hasFullResultsFunc();
		self:SetState(hasFullResults and ItemListState.NoResults or ItemListState.ResultsPending);
		return;
	end

	self:SetState(ItemListState.ShowResults);

	local buttons = HybridScrollFrame_GetButtons(self.ScrollFrame);
	local buttonCount = #buttons;
	local buttonHeight = buttons[1]:GetHeight();

	local offset = self:GetScrollOffset();
	local populateCount = math.min(buttonCount, numResults);
	self.tableBuilder:Populate(offset, populateCount);

	for i = 1, buttonCount do
		local visible = i + offset <= numResults;
		local button = buttons[i];

		if visible then
			button:SetEnabled(self.selectionCallback ~= nil);

			if self.highlightCallback then
				local highlightShown, highlightAlpha = self.highlightCallback(button.rowData, self.selectedRowData);
				button.SelectedHighlight:SetShown(highlightShown);
				button.SelectedHighlight:SetAlpha(highlightAlpha or 1.0);
			else
				button.SelectedHighlight:Hide();
			end
		end
		
		button:SetShown(visible);
	end

	local totalHeight = numResults * buttonHeight;
	local displayedHeight = populateCount * buttonHeight;
	HybridScrollFrame_Update(self.ScrollFrame, totalHeight, displayedHeight);

	if self.refreshCallback ~= nil then
		local lastDisplayedEntry = offset + buttonCount;
		self.refreshCallback(lastDisplayedEntry);
	end
end

function AuctionHouseItemListMixin:GetHeaderContainer()
	return self.HeaderContainer;
end
