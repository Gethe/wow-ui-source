local function GetNotchHeight()
	if not C_UI.ShouldUIParentAvoidNotch() then
		return 0;
	end

	local notchHeight = select(4, C_UI.GetTopLeftNotchSafeRegion());
	local physicalHeight = select(2, GetPhysicalScreenSize());
	local normalizedHeight = notchHeight / physicalHeight;
	local finalHeight = normalizedHeight * UIParent:GetHeight();
	return finalHeight;
end

function UpdateUIParentPosition()
	local notchHeight = GetNotchHeight();
	local debugBarsHeight = DebugBarManager:GetTotalHeight();
	local topOffset = math.max(debugBarsHeight, notchHeight);
	UIParent:SetPoint("TOPLEFT", 0, -topOffset);
end
