
ScrollBoxViewUtil = {};

function ScrollBoxViewUtil.CalculateSpacingUntil(index, stride, spacing)
	return math.max(0, math.ceil(index/stride) - 1) * spacing;
end

-- Points are cleared first to avoid some complications related to drag and drop.
function ScrollBoxViewUtil.SetHorizontalPoint(frame, offset, indent, scrollTarget)
	frame:ClearAllPoints();
	frame:SetPoint("TOPLEFT", scrollTarget, "TOPLEFT", offset, -indent);
	frame:SetPoint("BOTTOMLEFT", scrollTarget, "BOTTOMLEFT", offset, 0);
	return frame:GetWidth();
end

function ScrollBoxViewUtil.SetVerticalPoint(frame, offset, indent, scrollTarget)
	frame:ClearAllPoints();
	frame:SetPoint("TOPLEFT", scrollTarget, "TOPLEFT", indent, -offset);
	frame:SetPoint("TOPRIGHT", scrollTarget, "TOPRIGHT", 0, -offset);
	return frame:GetHeight();
end
