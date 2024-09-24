
InputUtil = {};

function InputUtil.GetCursorPosition(parent)
	local x, y = GetCursorPosition();
	local scale = parent:GetEffectiveScale();
	return x / scale, y / scale;
end

function InputUtil.GetAnchorPositionAtCursor()
	local x, y = InputUtil.GetCursorPosition(GetAppropriateTopLevelParent());
	-- Cursor is relative to BL while frame coordinates are relative to TL.
	return x, (-GetScreenHeight() + y);
end