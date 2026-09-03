
InputUtil = {};

function InputUtil.ShowInspectCursor()
	SetCursor("INSPECT_CURSOR");
end

function ShowInspectCursor()
	InputUtil.ShowInspectCursor();
end

function InputUtil.GetCursorPosition(parent)
	local x, y = GetCursorPosition();
	local scale = parent:GetEffectiveScale();
	return x / scale, y / scale;
end

function InputUtil.GetCursorDelta(parent)
	local x, y = GetCursorDelta();
	local scale = parent:GetEffectiveScale();
	return x / scale, y / scale;
end

function InputUtil.IsMouseOver(region, topOffset, bottomOffset, leftOffset, rightOffset)
	return region:IsMouseOver(topOffset, bottomOffset, leftOffset, rightOffset);
end

function InputUtil.CursorUpdate(region)
	if ( IsModifiedClick("DRESSUP") and region.hasItem ) then
		InputUtil.ShowInspectCursor();
	else
		ResetCursor();
	end
end

function CursorUpdate(region)
	InputUtil.CursorUpdate(region);
end

function InputUtil.CursorOnUpdate(region)
	if ( GameTooltip:IsOwned(region) ) then
		InputUtil.CursorUpdate(region);
	end
end

function CursorOnUpdate(region)
	InputUtil.CursorOnUpdate(region);
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