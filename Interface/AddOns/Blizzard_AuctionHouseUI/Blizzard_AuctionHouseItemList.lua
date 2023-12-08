
local ItemListState = {
	NoSearch = 1,
	NoResults = 2,
	ResultsPending = 3,
	ShowResults = 4,
};


AuctionHouseItemListLineMixin = CreateFromMixins(TableBuilderRowMixin);

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
	return self:GetParent():GetParent():GetParent();
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

	self.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnScroll, self.OnScrollBoxScroll, self);
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
		self.tableBuilder:SetTableWidth(self.ScrollBox:GetWidth());
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

-- Can be removed once the exceptions on related to nil rowData have been confirmed fixed.
local canAssertOnInvalidRowData = true;

function AuctionHouseItemListMixin:Init()
	if self.isInitialized then
		return;
	end

	local view = CreateScrollBoxListLinearView();
	view:SetElementFactory(function(factory, elementData)
		local function Initializer(button, elementData)
			if self.hideStripes then
				-- Force the texture to stay hidden through button clicks, etc.
				button:GetNormalTexture():SetAlpha(0);
			end
		
			if self.lineTemplate then
				button:InitLine(unpack(self.initArgs));
			end
		
			button:SetEnabled(self.selectionCallback ~= nil);
		end
		factory(self.lineTemplate or "AuctionHouseItemListLineTemplate", Initializer);
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
	
	local tableBuilder = CreateTableBuilder(nil, AuctionHouseTableBuilderMixin);
	self.tableBuilder = tableBuilder;

	local function ElementDataTranslator(elementData)
		return elementData;
	end;
	ScrollUtil.RegisterTableBuilder(self.ScrollBox, tableBuilder, ElementDataTranslator);

	if self.getEntry then
		self.tableBuilder:SetDataProvider(self.getEntry);
	end
	
	ScrollUtil.RegisterAlternateRowBehavior(self.ScrollBox, function(button, alternate)
		if self.highlightCallback then
			local highlightShow = false;
			local highlightAlpha = 1.0;

			-- rowData and elementData are expected to be non-nil.
			local rowData = button.rowData;
			local elementData = button:GetElementData();
			if rowData and elementData then
				highlightShown, highlightAlpha = self.highlightCallback(rowData, self.selectedRowData, elementData);
			elseif canAssertOnInvalidRowData then
				-- We don't need/want an assert for every element in the range. Once will suffice.
				canAssertOnInvalidRowData = false;
				assertsafe(false, "Missing row data for auction house item list.")
			end

			if not self.hideStripes then
				button:GetNormalTexture():SetAtlas(alternate and "auctionhouse-rowstripe-1" or "auctionhouse-rowstripe-2");
			end

			button.SelectedHighlight:SetShown(highlightShown);
			button.SelectedHighlight:SetAlpha(highlightAlpha or 1.0);
		else
			button.SelectedHighlight:Hide();
		end
	end);

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
	self.ScrollBox:ScrollToBegin();
	self:RefreshScrollFrame();
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
		self.ScrollBox:RemoveDataProvider();
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
	self.ScrollBox:ScrollToElementDataIndex(entryIndex, ScrollBoxConstants.AlignCenter, ScrollBoxConstants.NoScrollInterpolation);
end

function AuctionHouseItemListMixin:GetScrollBoxDataIndexBegin()
	return self.ScrollBox:GetDataIndexBegin();
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

	local dataProvider = CreateIndexRangeDataProvider(numResults);
	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
	
	self:CallRefreshCallback();
end

function AuctionHouseItemListMixin:CallRefreshCallback()
	if self.refreshCallback ~= nil then
		local lastDisplayedEntry = self.ScrollBox:GetDataIndexEnd();
		self.refreshCallback(lastDisplayedEntry);
	end
end

function AuctionHouseItemListMixin:OnScrollBoxScroll(scrollPercentage, visibleExtentPercentage, panExtentPercentage)
	self:CallRefreshCallback();
end

function AuctionHouseItemListMixin:GetHeaderContainer()
	return self.HeaderContainer;
end
