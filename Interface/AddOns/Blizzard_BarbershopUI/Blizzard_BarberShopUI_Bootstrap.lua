local AddonName = ...;

function BarberShopFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ShowBarberShopFrame()
	if BarberShopFrame_LoadUI() then
		ShowUIPanel(BarberShopFrame);
	end
end

function HideBarberShopFrame()
	if C_AddOns.IsAddOnLoaded(AddonName) and BarberShopFrame:IsVisible() then
		HideUIPanel(BarberShopFrame);
	end
end
