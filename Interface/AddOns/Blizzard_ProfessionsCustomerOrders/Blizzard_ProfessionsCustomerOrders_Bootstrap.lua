local AddonName = ...;

function ProfessionsCustomerOrders_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ShowProfessionsCustomerOrdersFrame()
	if ProfessionsCustomerOrders_LoadUI() then
		ShowUIPanel(ProfessionsCustomerOrdersFrame);
	end
end

function HideProfessionsCustomerOrdersFrame()
	if C_AddOns.IsAddOnLoaded(AddonName) then
		HideUIPanel(ProfessionsCustomerOrdersFrame);
	end
end
