local AddonName = ...;

function NPE_LoadUI()
	if not GetTutorialsEnabled() or C_AddOns.IsAddOnLoaded(AddonName) then
		return;
	end

	if TutorialManager.CanBootstrapNPE() then
		return LoadAddOnWithErrorHandling(AddonName);
	end
end

function NPE_InitializeIfLoaded()
	if C_AddOns.IsAddOnLoaded(AddonName) then
		NewPlayerExperience:Initialize();
		return true;
	end

	return false;
end
