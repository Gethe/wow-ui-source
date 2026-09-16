local CLICK_BINDING_ADDON_NAME = "Blizzard_ClickBindingUI";

function InClickBindingMode()
	return ClickBindingFrame and ClickBindingFrame:IsShown();
end

function ToggleClickBindingFrame()
	LoadAddOnWithErrorHandling(CLICK_BINDING_ADDON_NAME);
	if ( ClickBindingFrame_Toggle ) then
		ClickBindingFrame_Toggle();
	end
end

function ClickBindingFrame_LoadUI()
	LoadAddOnWithErrorHandling(CLICK_BINDING_ADDON_NAME);
end
