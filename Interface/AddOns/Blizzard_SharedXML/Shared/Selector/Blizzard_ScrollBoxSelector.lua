
ScrollBoxSelectorMixin = {};

function ScrollBoxSelectorMixin:OnShow()
	if not self.initialized then
		self:Init();
	end
end

function ScrollBoxSelectorMixin:Init()
	local view = CreateScrollBoxListGridView(self:GetStride());

	view:SetElementExtent(self:GetButtonHeight());
	view:SetPadding(self:GetPadding());

	local function InitializeGridSelectorScrollButton(button, selectionIndex)
		self:RunSetup(button, selectionIndex);
	end

	local templateType, buttonTemplate = self:GetButtonTemplate();
	view:SetElementInitializer(buttonTemplate, InitializeGridSelectorScrollButton);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.initialized = true;

	self:UpdateSelections();
end

function ScrollBoxSelectorMixin:UpdateSelections()
	if self.initialized then
		local dataProvider = CreateIndexRangeDataProvider(self:GetNumSelections());
		self.ScrollBox:SetDataProvider(dataProvider);
	end
end

function ScrollBoxSelectorMixin:EnumerateButtons()
	local enumerateFramesIteratorFunction, table, initialIteratorKey = self.ScrollBox:EnumerateFrames();
	local savedKey = initialIteratorKey;
	local function GridSelectorScrollEnumerateButtons(tbl)
		local nextKey, nextValue = enumerateFramesIteratorFunction(tbl, savedKey);
		savedKey = nextKey;
		return nextValue;
	end

	return GridSelectorScrollEnumerateButtons, table, initialIteratorKey;
end

function ScrollBoxSelectorMixin:SetCustomButtonHeight(customButtonHeight)
	self.customButtonHeight = customButtonHeight;
end

function ScrollBoxSelectorMixin:GetButtonHeight()
	return self.customButtonHeight or 36;
end

function ScrollBoxSelectorMixin:SetCustomStride(customStride)
	self.customStride = customStride;
end

function ScrollBoxSelectorMixin:GetStride()
	return self.customStride or 10;
end

function ScrollBoxSelectorMixin:SetCustomPadding(top, bottom, left, right, horizontalSpacing, verticalSpacing)
	self.top = top;
	self.bottom = bottom;
	self.left = left;
	self.right = right;
	self.horizontalSpacing = horizontalSpacing;
	self.verticalSpacing = verticalSpacing;
end

function ScrollBoxSelectorMixin:GetPadding()
	return self.top or 5, self.bottom or 5, self.left or 5, self.right or 5, self.horizontalSpacing or 10, self.verticalSpacing or 10;
end

function ScrollBoxSelectorMixin:AdjustScrollBarOffsets(offsetX, topOffset, bottomOffset)
	self.ScrollBar:SetPoint("TOPRIGHT", offsetX or 0, topOffset or 0);
	self.ScrollBar:SetPoint("BOTTOMRIGHT", offsetX or 0, bottomOffset or 0);
end

function ScrollBoxSelectorMixin:ScrollToSelectedIndex()
	local targetIndex = self:GetSelectedIndex() or 1;
	self:ScrollToElementDataIndex(targetIndex, ScrollBoxConstants.AlignCenter, ScrollBoxConstants.NoScrollInterpolation);
end

function ScrollBoxSelectorMixin:ScrollToElementDataIndex(...)
	self.ScrollBox:ScrollToElementDataIndex(...);
end
