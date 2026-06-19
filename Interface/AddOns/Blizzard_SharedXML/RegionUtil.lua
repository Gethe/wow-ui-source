
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

function RegionUtil.GetPointsArray(region)
	local points = {};
	for i = 1, region:GetNumPoints() do
		table.insert(points, AnchorUtil.CreateAnchorFromPoint(region, i));
	end

	return points;
end

function RegionUtil.ApplyRegionPoints(region, points)
	if not points or #points == 0 then
		return;
	end

	region:ClearAllPoints();
	for _i, anchor in ipairs(points) do
		anchor:SetPoint(region);
	end
end

function RegionUtil.GetBounds(region)
	local l = region:GetLeft();
	local r = region:GetRight();
	local t = region:GetTop();
	local b = region:GetBottom();
	return l, r, t, b;
end

local function GetTopLeftSortKey(region)
	local left, bottom, _width, height = region:GetRect();
	if not left or not height then
		return nil;
	end

	-- 20000 is chosen to be safely larger than any expected screen dimension.
	-- We could normalize the coordinates to the screen size, but this is sufficient
	-- for sorting purposes and avoids needing to query the screen size.
	local top = bottom + height;
	return top * 20000 - left;
end

function RegionUtil.SortByTopLeft(regions)
	local sortKeys = {};
	for _, region in ipairs(regions) do
		sortKeys[region] = GetTopLeftSortKey(region);
	end

	table.sort(regions, function(regionA, regionB)
		local keyA = sortKeys[regionA];
		local keyB = sortKeys[regionB];

		if not keyA then
			return false;
		end

		if not keyB then
			return true;
		end

		return keyA > keyB;
	end);

	return regions;
end

function RegionUtil.GetTopLeftMost(regions)
	local best = nil;
	local bestKey = nil;

	for _, region in ipairs(regions) do
		local key = GetTopLeftSortKey(region);
		if key and (not bestKey or key > bestKey) then
			best = region;
			bestKey = key;
		end
	end

	return best or regions[1];
end

local ALLOWED_KEYBIND_SET = {
	["FSTACK"] = true,
	["RELOADUI"] = true,
	["TOGGLEGAMEMENU"] = true,
	["TOGGLEMUSIC"] = true,
	["TOGGLESOUND"] = true,
	["SCREENSHOT"] = true,
};

-- For use with "OnKeyDown" scripts that are blocking keyboard input.
function RegionUtil.RunStandardKeybind(key)
	local keybind = GetBindingFromInput(key);
	if ALLOWED_KEYBIND_SET[keybind] then
		RunBinding(keybind);
	end
end

function enumerate_regions(frame)
	return ipairs({frame:GetRegions()});
end