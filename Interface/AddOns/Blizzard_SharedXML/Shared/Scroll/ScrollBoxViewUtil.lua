
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
