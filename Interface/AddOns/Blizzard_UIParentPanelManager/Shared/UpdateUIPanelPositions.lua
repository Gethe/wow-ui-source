if not IsInGlobalEnvironment() then
	return;
end

UIParent:SetScript("OnAttributeChanged", UpdateUIPanelPositions);