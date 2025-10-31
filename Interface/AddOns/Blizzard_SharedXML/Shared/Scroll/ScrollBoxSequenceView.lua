-- Identical element optimization is not implemented because this view is expected to be used
-- with elements of varied sizes, whereas elements of the same size are already accomodated by
-- GridView.
ScrollBoxListSequenceViewMixin = CreateFromMixins(ScrollBoxListBiaxalViewMixin);

function ScrollBoxListSequenceViewMixin:Layout(scrollBox)
	local frames = self:GetFrames();
	local frameCount = frames and #frames or 0;
	if frameCount == 0 then
		return;
	end

	local scrollTarget = self:GetScrollTarget();
	local frameLevelCounter = ScrollBoxViewUtil.CreateFrameLevelCounter(self:GetFrameLevelPolicy(), 
		scrollTarget:GetFrameLevel(), frameCount);
	
	local visibleWidth = scrollTarget:GetWidth();
	local verticalSpacing = self:GetVerticalSpacing();
	local horizontalSpacing = self:GetHorizontalSpacing();
	local dataIndexBegin, dataIndexEnd = self:GetDataRange();
	local currentWidth = 0;
	local currentHeight = 0;
	local nextHeight = 0;

	local baseIndex = dataIndexBegin - 1;
	for index, frame in ipairs(frames) do
		local elementWidth, elementHeight = self:GetElementSize(baseIndex + index);
		if elementWidth == ScrollBoxConstants.FillExtent then
			elementWidth = visibleWidth;
			frame:SetWidth(elementWidth);
		end

		frame:ClearAllPoints();

		local nextWidth = currentWidth + elementWidth;
		local fits = nextWidth <= visibleWidth;
		if fits then
			frame:SetPoint("TOPLEFT", scrollTarget, "TOPLEFT", currentWidth, -nextHeight);
			currentWidth = nextWidth + horizontalSpacing;

			local lastHeight = currentHeight;
			currentHeight = math.max(currentHeight, elementHeight);
		else
			nextHeight = nextHeight + currentHeight + verticalSpacing;
			frame:SetPoint("TOPLEFT", scrollTarget, "TOPLEFT", 0, -nextHeight);

			currentWidth = elementWidth + horizontalSpacing;
			currentHeight = elementHeight;
		end

		if frameLevelCounter then
			frame:SetFrameLevel(frameLevelCounter());
		end
	end
end

function ScrollBoxListSequenceViewMixin:CalculateNumElementsInRow(startDataIndex)
	local size = self:GetDataProviderSize();
	local scrollTarget = self:GetScrollTarget();
	local visibleWidth = scrollTarget:GetWidth();
	local horizontalSpacing = self:GetHorizontalSpacing();

	local currentWidth = 0;
	local nextDataIndex = startDataIndex;
	while nextDataIndex <= size do
		local elementWidth, elementHeight = self:GetElementSize(nextDataIndex);
		if elementWidth == 0 then
			elementWidth = visibleWidth;
		end

		local isFirstElement = nextDataIndex == startDataIndex;
		local nextElementWidth;
		if isFirstElement then 
			nextElementWidth = elementWidth;
		else
			nextElementWidth = elementWidth + horizontalSpacing;
		end

		local nextWidth = currentWidth + nextElementWidth;
		local willExceedWidth = nextWidth > visibleWidth;
		if isFirstElement or (not willExceedWidth) then
			currentWidth = nextWidth;
		end

		if willExceedWidth then
			break;
		end

		nextDataIndex = nextDataIndex + 1;
	end

	return (nextDataIndex - startDataIndex);
end

function ScrollBoxListSequenceViewMixin:CalculateDataIndices(scrollBox)
	local size = self:GetDataProviderSize();
	if size == 0 then
		return 0, 0;
	end

	local visibleExtent = scrollBox:GetVisibleExtent();
	if visibleExtent == 0 then
		return 0, 0;
	end

	local scrollTarget = self:GetScrollTarget();
	local visibleWidth = scrollTarget:GetWidth();
	if visibleWidth == 0 then
		return 0, 0;
	end

	if not self:IsVirtualized() then
		return ScrollBoxViewUtil.CheckDataIndicesReturn(1, size);
	end

	local scrollOffset = Round(scrollBox:GetDerivedScrollOffset());
	local upperPadding = scrollBox:GetUpperPadding();
	local verticalSpacing = self:GetVerticalSpacing();
	local horizontalSpacing = self:GetHorizontalSpacing();
	
	local rowStartIndex = 1;
	local extent = upperPadding;
	local extentEnd = visibleExtent + scrollOffset;
	local currentWidth = 0;
	local currentHeight = 0;
	local dataIndexBegin;
	local dataIndexEnd;
	local nextDataIndex = 1;
	while nextDataIndex <= size do
		local elementWidth, elementHeight = self:GetElementSize(nextDataIndex);
		if elementWidth == 0 then
			elementWidth = visibleWidth;
		end

		local nextWidth = currentWidth + elementWidth;
		if nextWidth <= visibleWidth then
			currentWidth = nextWidth + horizontalSpacing;

			local lastHeight = currentHeight;
			currentHeight = math.max(currentHeight, elementHeight);
			extent = extent + math.max(0, currentHeight - lastHeight);
		else
			currentWidth = elementWidth + horizontalSpacing;

			currentHeight = elementHeight;
			extent = extent + currentHeight + verticalSpacing;

			rowStartIndex = nextDataIndex;
		end

		if (dataIndexBegin == nil) and (extent > scrollOffset) then
			dataIndexBegin = rowStartIndex;
		end

		if extent >= extentEnd then
			local numElements = self:CalculateNumElementsInRow(rowStartIndex);
			dataIndexEnd = rowStartIndex + numElements - 1;
			break;
		end

		dataIndexEnd = nextDataIndex;
		nextDataIndex = nextDataIndex + 1;
	end

	return ScrollBoxViewUtil.CheckDataIndicesReturn(dataIndexBegin, dataIndexEnd);
end

function ScrollBoxListSequenceViewMixin:GetExtentTo(scrollBox, dataIndexEnd)
	local size = self:GetDataProviderSize();
	if size == 0 then
		return 0;
	end

	local scrollTarget = self:GetScrollTarget();
	local visibleWidth = scrollTarget:GetWidth();
	local verticalSpacing = self:GetVerticalSpacing();
	local horizontalSpacing = self:GetHorizontalSpacing();

	local extent = 0;
	local currentWidth = 0;
	local currentHeight = 0;

	local dataIndexBegin = 1;
	while dataIndexBegin <= dataIndexEnd do
		local elementWidth, elementHeight = self:GetElementSize(dataIndexBegin);
		if elementWidth == 0 then
			elementWidth = visibleWidth;
		end

		local nextWidth = currentWidth + elementWidth;
		if nextWidth <= visibleWidth then
			currentWidth = nextWidth + horizontalSpacing;

			local lastHeight = currentHeight;
			currentHeight = math.max(currentHeight, elementHeight);
			extent = extent + math.max(0, currentHeight - lastHeight);
		else
			currentWidth = elementWidth + horizontalSpacing;

			currentHeight = elementHeight;
			extent = extent + currentHeight + verticalSpacing;
		end

		dataIndexBegin = dataIndexBegin + 1;
	end

	return extent;
end

function ScrollBoxListSequenceViewMixin:GetExtentUntil(scrollBox, dataIndexEnd)
	local size = self:GetDataProviderSize();
	if size == 0 then
		return 0;
	end

	local scrollTarget = self:GetScrollTarget();
	local visibleWidth = scrollTarget:GetWidth();
	local verticalSpacing = self:GetVerticalSpacing();
	local horizontalSpacing = self:GetHorizontalSpacing();
	
	local extent = 0;
	local currentWidth = 0;
	local currentHeight = 0;

	local dataIndexBegin = 1;
	while dataIndexBegin <= dataIndexEnd do
		local elementWidth, elementHeight = self:GetElementSize(dataIndexBegin);
		if elementWidth == 0 then
			elementWidth = visibleWidth;
		end

		local nextWidth = currentWidth + elementWidth;
		if nextWidth <= visibleWidth then
			if dataIndexBegin == dataIndexEnd then
				extent = extent - currentHeight;
			else
				currentWidth = nextWidth + horizontalSpacing;

				local lastHeight = currentHeight;
				currentHeight = math.max(currentHeight, elementHeight);
				extent = extent + math.max(0, currentHeight - lastHeight);
			end
		else
			currentWidth = elementWidth + horizontalSpacing;

			currentHeight = elementHeight;
			if dataIndexBegin == dataIndexEnd then
				extent = extent + verticalSpacing;
			else
				extent = extent + currentHeight + verticalSpacing;
			end
		end

		dataIndexBegin = dataIndexBegin + 1;
	end

	return extent;
end

function CreateScrollBoxListSequenceView(top, bottom, left, right, horizontalSpacing, verticalSpacing)
	return CreateAndInitFromMixin(ScrollBoxListSequenceViewMixin, top, bottom, left, right, horizontalSpacing, verticalSpacing);
end
