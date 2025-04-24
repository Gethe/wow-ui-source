
RegionUtil = {};

function RegionUtil.IsDescendantOf(potentialDescendant, potentialAncestor)
	if not potentialDescendant or not potentialAncestor then
		return false;
	end

	local parent = potentialDescendant:GetParent();
	while parent do
		if parent == potentialAncestor then
			return true;
		end
		parent = parent:GetParent();
	end

	return false;
end

function RegionUtil.IsDescendantOfOrSame(potentialDescendant, potentialAncestorOrSame)
	if potentialDescendant and potentialDescendant == potentialAncestorOrSame then
		return true;
	end

	return RegionUtil.IsDescendantOf(potentialDescendant, potentialAncestorOrSame);
end

function RegionUtil.IsAnyDescendantOfOrSame(potentialDescendants, potentialAncestorOrSame)
	for _, potentialDescendant in ipairs(potentialDescendants) do
		if RegionUtil.IsDescendantOfOrSame(potentialDescendant, potentialAncestorOrSame) then
			return true;
		end
	end

	return false;
end

function RegionUtil.CalculateDistanceSqBetween(region1, region2)
	local x1, y1 = region1:GetCenter();
	local x2, y2 = region2:GetCenter();
	if x1 and x2 then
		return CalculateDistanceSq(x1, y1, x2, y2);
	end
	return 0;
end

function RegionUtil.CalculateDistanceBetween(region1, region2)
	return math.sqrt(RegionUtil.CalculateDistanceSqBetween(region1, region2));
end

function RegionUtil.CalculateAngleBetween(region1, region2)
	local x1, y1 = region1:GetCenter();
	local x2, y2 = region2:GetCenter();
	return CalculateAngleBetween(x1, y1, x2, y2);
end

function RegionUtil.GetSides(region)
	local left, bottom, width, height = region:GetRect();
	return left, left and (left + width), bottom, bottom and (bottom + height);
end

function RegionUtil.GetRegionPoint(region, x, y, invertY)
	local originX, bottom, width, height = region:GetScaledRect();
	if not originX then
		return; -- No valid rect, unable to get local coordinates
	end

	local originY = bottom;
	local scale = region:GetEffectiveScale();
	local localX = (x - originX) / scale;

	if invertY then
		originY = bottom + height;
		local localY = (originY - y) / scale;
		return localX, localY;
	end

	local localY = (y - originY) / scale;
	return localX, localY;
end

function RegionUtil.GetRegionPointFromCursor(region, invertY)
	local x, y = GetCursorPosition();
	return RegionUtil.GetRegionPoint(region, x, y, invertY);
end

function enumerate_regions(frame)
	return ipairs({frame:GetRegions()});
end