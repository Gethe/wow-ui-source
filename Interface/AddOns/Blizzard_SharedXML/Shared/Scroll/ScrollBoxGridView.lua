ScrollBoxListGridViewMixin = CreateFromMixins(ScrollBoxListBiaxalViewMixin, ScrollBoxListStrideMixin);

function ScrollBoxListGridViewMixin:Init(stride, top, bottom, left, right, horizontalSpacing, verticalSpacing)
	ScrollBoxListBiaxalViewMixin.Init(self, top, bottom, left, right, horizontalSpacing, verticalSpacing);

	self:SetStride(stride or 1);
end

function ScrollBoxListGridViewMixin:SetStride(stride)
	self.stride = stride;
end

function ScrollBoxListGridViewMixin:GetStride()
	local strideExtent = self:GetStrideExtent();
	if strideExtent then
		local scrollTarget = self:GetScrollTarget();
		local extent = scrollTarget:GetWidth();
		local spacing = self:GetHorizontalSpacing();
		local stride = math.max(1, math.floor(extent / strideExtent));
		local extentWithSpacing = (stride * strideExtent) + ((stride-1) * spacing);
		while stride > 1 and extentWithSpacing > extent do
			stride = stride - 1;
			extentWithSpacing = extentWithSpacing - (strideExtent + spacing);
		end
		return stride;
	end

	return self.stride;
end

function ScrollBoxListGridViewMixin:HasIdenticalStrideExtent()
	return self:HasIdenticalElementSize();
end

function ScrollBoxListGridViewMixin:GetIdenticalStrideExtent()
	local width, height = self:GetIdenticalElementSize();
	-- This is always the height because BiaxalView doesn't support horizontal mode.
	return height;
end

function ScrollBoxListGridViewMixin:SetStrideExtent(extent)
	self.strideExtent = extent;
end

function ScrollBoxListGridViewMixin:GetStrideExtent()
	return self.strideExtent;
end

-- Note: If you're using a direction tagged as 'isVertical' then this will
-- require the view to be non-virtualized which can be a significant performance cost.
function ScrollBoxListGridViewMixin:SetGridLayoutDirection(direction)
	self.direction = direction;

	-- Virtualizing a vertical layout would require displaying multiple non-continguous ranges which
	-- is not supported by the current implementation.
	-- For instance, if we have space to show 4 items we want to display 1-2 and 4-5, not 1-4:
	-- [ 1  4 ]
	-- [ 2  5 ]
	--   3  6   (these are not visible)
	if direction.isVertical then
		self:SetVirtualized(false);
	end
end

function ScrollBoxListGridViewMixin:GetGridLayoutDirection()
	return self.direction or GridLayoutMixin.Direction.TopLeftToBottomRight;
end

function ScrollBoxListGridViewMixin:Layout()
	local frames = self:GetFrames();
	local frameCount = #frames;
	if frameCount == 0 then
		return 0;
	end

	local stride = self:GetStride();
	local horizontalSpacing = self:GetHorizontalSpacing();
	local verticalSpacing = self:GetVerticalSpacing();
	local layoutDirection = self:GetGridLayoutDirection();
	if layoutDirection.isVertical then
		local frameHeight = self:GetFrameExtent(frames[1]);
		local verticalSpacePerFrame = frameHeight + verticalSpacing;
		local spacePerColumn = self:GetScrollBox():GetVisibleExtent();
		local framesPerColumn = 1 + math.max(0, math.floor((spacePerColumn - frameHeight) / verticalSpacePerFrame));
		stride = math.max(framesPerColumn, math.ceil(frameCount / stride));
	end

	local layout = AnchorUtil.CreateGridLayout(layoutDirection, stride, horizontalSpacing, verticalSpacing);
	local anchor = CreateAnchor("TOPLEFT", self:GetScrollTarget(), "TOPLEFT", 0, 0);
	AnchorUtil.GridLayout(frames, anchor, layout);
end

function CreateScrollBoxListGridView(stride, top, bottom, left, right, horizontalSpacing, verticalSpacing)
	return CreateAndInitFromMixin(ScrollBoxListGridViewMixin, stride, top, bottom, left, right, horizontalSpacing, verticalSpacing);
end