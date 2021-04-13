ScrollBoxGridPaddingMixin = CreateFromMixins(ScrollBoxPaddingMixin);

function ScrollBoxGridPaddingMixin:Init(top, bottom, left, right, horizontalSpacing, verticalSpacing)
	ScrollBoxPaddingMixin.Init(self, top, bottom, left, right);
	self:SetHorizontalSpacing(horizontalSpacing or 0);
	self:SetVerticalSpacing(verticalSpacing or 0);
end

function ScrollBoxGridPaddingMixin:GetHorizontalSpacing()
	return self.horizontalSpacing;
end

function ScrollBoxGridPaddingMixin:SetHorizontalSpacing(spacing)
	self.horizontalSpacing = spacing;
end

function ScrollBoxGridPaddingMixin:GetVerticalSpacing()
	return self.verticalSpacing;
end

function ScrollBoxGridPaddingMixin:SetVerticalSpacing(spacing)
	self.verticalSpacing = spacing;
end

function CreateScrollBoxGridPadding(top, bottom, left, right, horizontalSpacing, verticalSpacing)
	return CreateAndInitFromMixin(ScrollBoxGridPaddingMixin, top, bottom, left, right, horizontalSpacing, verticalSpacing);
end

ScrollBoxListGridViewMixin = CreateFromMixins(ScrollBoxListViewMixin);

function ScrollBoxListGridViewMixin:Init(stride, top, bottom, left, right, horizontalSpacing, verticalSpacing)
	ScrollBoxListViewMixin.Init(self);
	self:SetStride(stride);
	self:SetPadding(top, bottom, left, right, horizontalSpacing, verticalSpacing);
end

function ScrollBoxListGridViewMixin:SetPadding(top, bottom, left, right, horizontalSpacing, verticalSpacing)
	local padding = CreateScrollBoxGridPadding(top, bottom, left, right, horizontalSpacing, verticalSpacing);
	ScrollBoxViewMixin.SetPadding(self, padding);
end

function ScrollBoxListGridViewMixin:GetHorizontalSpacing()
	return self.padding:GetHorizontalSpacing();
end

function ScrollBoxListGridViewMixin:GetVerticalSpacing()
	return self.padding:GetVerticalSpacing();
end

function ScrollBoxListGridViewMixin:SetStride(stride)
	self.stride = stride;
end

function ScrollBoxListGridViewMixin:GetStride()
	return self.stride;
end

function ScrollBoxListGridViewMixin:Layout()
	local frames = self:GetFrames();
	local frameCount = frames and #frames or 0;
	if frameCount == 0 then
		return 0;
	end

	local stride = self:GetStride();
	local horizontalSpacing = self:GetHorizontalSpacing();
	local verticalSpacing = self:GetVerticalSpacing();
	local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, stride, horizontalSpacing, verticalSpacing);
	local anchor = CreateAnchor("TOPLEFT", self:GetScrollTarget(), "TOPLEFT", 0, 0);
	AnchorUtil.GridLayout(frames, anchor, layout);

	local extent = self:GetFrameExtent(frames[1]) * math.ceil(frameCount / stride);
	local space = ScrollBoxViewUtil.CalculateSpacingUntil(frameCount, stride, verticalSpacing);
	return extent + space;
end

function ScrollBoxListGridViewMixin:CalculateDataIndices(scrollBox)
	return ScrollBoxListViewMixin.CalculateDataIndices(self, scrollBox, self:GetStride(), self:GetVerticalSpacing());
end

function ScrollBoxListGridViewMixin:GetExtent(recalculate, scrollBox)
	return ScrollBoxListViewMixin.GetExtent(self, recalculate, scrollBox, self:GetStride(), self:GetVerticalSpacing());
end

function ScrollBoxListGridViewMixin:GetExtentUntil(scrollBox, dataIndex)
	return ScrollBoxListViewMixin.GetExtentUntil(self, scrollBox, dataIndex, self:GetStride(), self:GetVerticalSpacing());
end

function ScrollBoxListGridViewMixin:GetPanExtent()
	return ScrollBoxListViewMixin.GetPanExtent(self, self:GetVerticalSpacing());
end

function CreateScrollBoxListGridView(stride, top, bottom, left, right, horizontalSpacing, verticalSpacing)
	return CreateAndInitFromMixin(ScrollBoxListGridViewMixin, stride, top or 0, bottom or 0, left or 0, right or 0, horizontalSpacing or 0, verticalSpacing or 0);
end