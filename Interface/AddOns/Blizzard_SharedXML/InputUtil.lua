
InputUtil = {};

function InputUtil.GetCursorPosition(parent)
	local x, y = GetCursorPosition();
	local scale = parent:GetEffectiveScale();
	return x / scale, y / scale;
end

function InputUtil.AnchorRegionToCursor(region, point)
	local parent = GetAppropriateTopLevelParent();
	local x, y = InputUtil.GetCursorPosition(parent);
	
	-- Accounts for the letterboxing that causes the UI origin to be shifted
	-- closer to the position of the cursor.
	local _, _, _, pointX, _ = parent:GetPointByName("TOPLEFT");
	if pointX then
		x = x - pointX;
	end

	region:ClearAllPoints();
	region:SetPoint(point, parent, "BOTTOMLEFT", x, y);
end