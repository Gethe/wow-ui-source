local AddonName = ...;

function CovenantPreviewFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function TryShowCovenantPreviewFrame(...)
	if CovenantPreviewFrame_LoadUI() then
		CovenantPreviewFrame:TryShow(...);
	end
end
