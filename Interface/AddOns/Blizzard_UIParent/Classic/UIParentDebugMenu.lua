function UpdateUIParentRelativeToDebugMenu()
	if (DebugMenu and DebugMenu.IsVisible()) then
		UIParent:SetPoint("TOPLEFT", 0, -DebugMenu.GetMenuHeight());
	else
		UIParent:SetPoint("TOPLEFT", 0, 0);
	end
end