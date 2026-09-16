local AddonName = ...;

function AzeriteEmpoweredItemUI_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function OpenAzeriteEmpoweredItemUIFromItemLocation(itemLocation)
	if AzeriteEmpoweredItemUI_LoadUI() then
		ShowUIPanel(AzeriteEmpoweredItemUI);
		if AzeriteEmpoweredItemUI:IsShown() then -- may fail to display
			AzeriteEmpoweredItemUI:SetToItemAtLocation(itemLocation);
		end
	end
end

function OpenAzeriteEmpoweredItemUIFromLink(itemLink, overrideClassID, overrideSelectedPowersList)
	if AzeriteEmpoweredItemUI_LoadUI() then
		ShowUIPanel(AzeriteEmpoweredItemUI);
		if AzeriteEmpoweredItemUI:IsShown() then -- may fail to display
			AzeriteEmpoweredItemUI:SetToItemLink(itemLink, overrideClassID, overrideSelectedPowersList);
		end
	end
end
