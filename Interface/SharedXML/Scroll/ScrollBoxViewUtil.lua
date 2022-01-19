ScrollBoxViewUtil = {};

function ScrollBoxViewUtil.CalculateSpacingUntil(index, stride, spacing)
	return math.max(0, math.ceil(index/stride) - 1) * spacing;
end