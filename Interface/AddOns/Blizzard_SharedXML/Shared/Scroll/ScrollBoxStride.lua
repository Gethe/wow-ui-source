ScrollBoxListStrideMixin = {};

function ScrollBoxListStrideMixin:GetStride()
	error("GetStride implementation required.")
end

function ScrollBoxListStrideMixin:HasIdenticalStrideExtent()
	error("HasIdenticalStrideExtent implementation required.")
end

function ScrollBoxListStrideMixin:GetIdenticalStrideExtent()
	error("GetIdenticalStrideExtent implementation required.")
end

function ScrollBoxListStrideMixin:GetExtentUntil(scrollBox, dataIndexEnd)
	if dataIndex == 0 then
		return 0;
	end

	local size = self:GetDataProviderSize();
	if size == 0 then
		return 0;
	end

	local stride = self:GetStride();
	local spacing = self:GetExtentSpacing();
	local extent = 0;
	if self:HasIdenticalStrideExtent() then
		local intervals = math.ceil(dataIndexEnd / stride) - 1;
		extent = math.max(0, intervals) * self:GetIdenticalStrideExtent();
		extent = extent + (intervals * spacing);
	else
		local index = dataIndexEnd - stride;
		local intervals = 0;
		while index > 0 do
			extent = extent + self:GetElementExtent(index);
			intervals = intervals + 1;
			index = index - stride;
		end
		extent = extent + (intervals * spacing);
	end
	
	return extent;
end

function ScrollBoxListStrideMixin:GetExtentTo(scrollBox, dataIndexEnd)
	if dataIndexEnd == 0 then
		return 0;
	end

	local size = self:GetDataProviderSize();
	if size == 0 then
		return 0;
	end

	local stride = self:GetStride();
	local spacing = self:GetExtentSpacing();
	local extent = 0;
	if self:HasIdenticalStrideExtent() then
		local intervals = math.ceil(dataIndexEnd / stride);
		extent = intervals * self:GetIdenticalStrideExtent();
		extent = extent + math.max(intervals - 1, 0) * spacing;
	else
		local index = dataIndexEnd;
		local intervals = 0;
		while index > 0 do
			extent = extent + self:GetElementExtent(index);
			intervals = intervals + 1;
			index = index - stride;
		end
		extent = extent + math.max(intervals - 1, 0) * spacing;
	end

	return extent;
end

function ScrollBoxListStrideMixin:CalculateDataIndices(scrollBox)
	local size = self:GetDataProviderSize();
	if size == 0 then
		return 0, 0;
	end

	local visibleExtent = scrollBox:GetVisibleExtent();
	if visibleExtent == 0 then
		return 0, 0;
	end

	if not self:IsVirtualized() then
		return ScrollBoxViewUtil.CheckDataIndicesReturn(1, size);
	end

	local dataIndexBegin;
	local scrollOffset = Round(scrollBox:GetDerivedScrollOffset());
	local upperPadding = scrollBox:GetUpperPadding();
	local stride = self:GetStride();
	local spacing = self:GetExtentSpacing();
	local extentBegin = upperPadding;
	-- For large element ranges (i.e. 10,000+), we're required to use identical element extents 
	-- to avoid performance issues. We're calculating the number of elements that partially or fully
	-- fit inside the extent of the scroll offset to obtain our reference position. If we happen to
	-- be using a traditional data provider, this optimization is still useful.
	if self:HasIdenticalStrideExtent() then
		local extentWithSpacing = self:GetIdenticalStrideExtent() + spacing;
		local intervals = math.floor(math.max(0, scrollOffset - upperPadding) / extentWithSpacing);
		dataIndexBegin = 1 + (intervals * stride);
		local extentTotal = (1 + intervals) * extentWithSpacing;
		extentBegin = extentBegin + extentTotal;
	else
		do
			dataIndexBegin = 1 - stride;
			repeat
				dataIndexBegin = dataIndexBegin + stride;
				local extentWithSpacing = self:GetElementExtent(dataIndexBegin) + spacing;
				extentBegin = extentBegin + extentWithSpacing;
			until ((extentBegin > scrollOffset) or (dataIndexBegin > size));
		end
	end

	-- Addon request to exclude the first element when only spacing is visible.
	-- This will be revised when per-element spacing support is added.
	if (spacing > 0) and ((extentBegin - spacing) < scrollOffset) then
		dataIndexBegin = dataIndexBegin + stride;
		extentBegin = extentBegin + self:GetElementExtent(dataIndexBegin) + spacing;
	end

	-- Optimization above for fixed element extents is not necessary here because we do
	-- not need to iterate over the entire data range. The iteration is limited to the
	-- number of elements that can fit in the displayable area.
	local extentEnd = visibleExtent + scrollOffset;
	local dataIndexEnd = dataIndexBegin;
	while (dataIndexEnd < size) and (extentBegin < extentEnd) do
		local nextDataIndex = dataIndexEnd + stride;
		dataIndexEnd = nextDataIndex;

		local extent = self:GetElementExtent(nextDataIndex);
		if extent == nil or extent == 0 then
			-- We're oor, which is expected in the case of stride > 1. In this case we're done
			-- and the dataIndexEnd will be clamped into range of the data provider below.
			break;
		end

		extentBegin = extentBegin + extent + spacing;
	end

	if stride > 1 then
		dataIndexEnd = math.min(dataIndexEnd - (dataIndexEnd % stride) + stride, size);
	else
		dataIndexEnd = math.min(dataIndexEnd, size);
	end

	return ScrollBoxViewUtil.CheckDataIndicesReturn(dataIndexBegin, dataIndexEnd);
end
