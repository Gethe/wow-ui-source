
ScrollBoxViewUtil = {};

function ScrollBoxViewUtil.CalculateSpacingUntil(index, stride, spacing)
	return math.max(0, math.ceil(index/stride) - 1) * spacing;
end

function ScrollBoxViewUtil.GetFrameExtent(frame, isHorizontal)
	return ScrollDirectionUtil.GetFrameExtent(frame, isHorizontal);
end

function ScrollBoxViewUtil.SetFrameExtent(frame, value, isHorizontal)
	ScrollDirectionUtil.SetFrameExtent(frame, value, isHorizontal);
end

function ScrollBoxViewUtil.GetUpper(frame, isHorizontal)
	return ScrollDirectionUtil.GetUpper(frame, isHorizontal);
end

function ScrollBoxViewUtil.GetLower(frame, isHorizontal)
	return ScrollDirectionUtil.GetLower(frame, isHorizontal);
end

function ScrollBoxViewUtil.SelectCursorComponent(parent, isHorizontal)
	return ScrollDirectionUtil.SelectCursorComponent(parent, isHorizontal);
end

function ScrollBoxViewUtil.SelectPointComponent(frame, isHorizontal)
	return ScrollDirectionUtil.SelectPointComponent(frame, isHorizontal);
end

-- Points are cleared first to avoid some complications related to drag and drop.
function ScrollBoxViewUtil.SetPoint(frame, offset, indent, elementStretchDisabled, scrollTarget, isHorizontal)
	frame:ClearAllPoints();
	if isHorizontal then
		frame:SetPoint("TOPLEFT", scrollTarget, "TOPLEFT", offset, -indent);
		if not elementStretchDisabled then
			frame:SetPoint("BOTTOMLEFT", scrollTarget, "BOTTOMLEFT", offset, 0);
		end
		return frame:GetWidth();
	else
		frame:SetPoint("TOPLEFT", scrollTarget, "TOPLEFT", indent, -offset);
		if not elementStretchDisabled then
			frame:SetPoint("TOPRIGHT", scrollTarget, "TOPRIGHT", 0, -offset);
		end
		return frame:GetHeight();
	end
end

-- Backward-compatible wrappers around SetPoint.
function ScrollBoxViewUtil.SetHorizontalPoint(frame, offset, indent, elementStretchDisabled, scrollTarget)
	return ScrollBoxViewUtil.SetPoint(frame, offset, indent, elementStretchDisabled, scrollTarget, true);
end

function ScrollBoxViewUtil.SetVerticalPoint(frame, offset, indent, elementStretchDisabled, scrollTarget)
	return ScrollBoxViewUtil.SetPoint(frame, offset, indent, elementStretchDisabled, scrollTarget, false);
end

function ScrollBoxViewUtil.CheckDataIndicesReturn(dataIndexBegin, dataIndexEnd)
	if type(dataIndexBegin) ~= "number" or type(dataIndexEnd) ~= "number" then
		error(string.format("CheckDataIndicesReturn expected numeric indices but received begin=%s, end=%s", tostring(dataIndexBegin), tostring(dataIndexEnd)));
	end

	if dataIndexEnd < dataIndexBegin then
		error(string.format("CheckDataIndicesReturn encountered an invalid range [%d, %d): end index must not be less than begin index.", dataIndexBegin, dataIndexEnd));
	end

	local size = dataIndexEnd - dataIndexBegin;
	local capacity = 1000;
	if size >= capacity then
		--[[ 
		Erroring here to avoid stalling the client by requesting an excessive number. This can happen
		if a frame doesn't correct frame extents (1 height/width), causing a much larger range to be 
		displayed than expected.
		]]--
		error(string.format("CheckDataIndicesReturn encountered an unsupported index range [%d, %d) with size %d/%d. This can happen when frame extents are invalid or not initialized.", dataIndexBegin, dataIndexEnd, size, capacity));
	end

	return dataIndexBegin, dataIndexEnd;
end

function ScrollBoxViewUtil.CreateFrameLevelCounter(frameLevelPolicy, referenceFrameLevel, range)
	if frameLevelPolicy == ScrollBoxViewMixin.FrameLevelPolicy.Ascending then
		local frameLevel = referenceFrameLevel + 1;
		return function()
			frameLevel = frameLevel + 1;
			return frameLevel;
		end
	elseif frameLevelPolicy == ScrollBoxViewMixin.FrameLevelPolicy.Descending then
		local frameLevel = referenceFrameLevel + 1 + range;
		return function()
			frameLevel = frameLevel - 1;
			return frameLevel;
		end
	end
	return nil;
end
