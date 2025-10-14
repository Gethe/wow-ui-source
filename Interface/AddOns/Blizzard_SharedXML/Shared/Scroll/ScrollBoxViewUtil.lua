
ScrollBoxViewUtil = {};

function ScrollBoxViewUtil.CalculateSpacingUntil(index, stride, spacing)
	return math.max(0, math.ceil(index/stride) - 1) * spacing;
end

-- Points are cleared first to avoid some complications related to drag and drop.
function ScrollBoxViewUtil.SetHorizontalPoint(frame, offset, indent, elementStretchDisabled, scrollTarget)
	frame:ClearAllPoints();
	frame:SetPoint("TOPLEFT", scrollTarget, "TOPLEFT", offset, -indent);
	if not elementStretchDisabled then
		frame:SetPoint("BOTTOMLEFT", scrollTarget, "BOTTOMLEFT", offset, 0);
	end
	return frame:GetWidth();
end

function ScrollBoxViewUtil.SetVerticalPoint(frame, offset, indent, elementStretchDisabled, scrollTarget)
	frame:ClearAllPoints();
	frame:SetPoint("TOPLEFT", scrollTarget, "TOPLEFT", indent, -offset);
	if not elementStretchDisabled then
		frame:SetPoint("TOPRIGHT", scrollTarget, "TOPRIGHT", 0, -offset);
	end
	return frame:GetHeight();
end

function ScrollBoxViewUtil.CheckDataIndicesReturn(dataIndexBegin, dataIndexEnd)
	local size = dataIndexEnd - dataIndexBegin;
	local capacity = 1000;
	if size >= capacity then
		--[[ 
		Erroring here to avoid stalling the client by requesting an excessive number. This can happen
		if a frame doesn't correct frame extents (1 height/width), causing a much larger range to be 
		displayed than expected.
		]]--
		error(string.format("CheckDataIndicesReturn encountered an unsupported size. %d/%d", size, capacity));
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
