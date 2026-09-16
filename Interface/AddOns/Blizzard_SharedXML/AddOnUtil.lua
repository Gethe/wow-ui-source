local failedAddOnLoad = {};

function LoadAddOnWithErrorHandling(name)
	local loaded, reason = C_AddOns.LoadAddOn(name);
	if not loaded and not failedAddOnLoad[name] then
		SetBasicMessageDialogText(format(ADDON_LOAD_FAILED, name, _G["ADDON_" .. reason]));
		failedAddOnLoad[name] = true;
	end

	return loaded;
end
