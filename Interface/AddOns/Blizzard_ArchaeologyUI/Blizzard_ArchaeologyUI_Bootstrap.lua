local AddonName = ...;

function ArchaeologyFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ArcheologyDigsiteProgressBar_OnSurveyCast(event, ...)
	if ArchaeologyFrame_LoadUI() then
		ArcheologyDigsiteProgressBar:OnEvent(event, ...);
	end
end

function ArchaeologyFrame_ToggleUI()
	if ArchaeologyFrame_LoadUI() then
		if ArchaeologyFrame:IsShown() then
			ArchaeologyFrame_Hide();
		else
			ArchaeologyFrame_Show();
		end
	end
end
