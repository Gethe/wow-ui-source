local AddonName = ...;

function ExpansionTrial_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ClassTrial_IsExpansionTrialUpgradeDialogShowing()
	if ExpansionTrialThanksForPlayingDialog then
		return ExpansionTrialThanksForPlayingDialog:IsShowingExpansionTrialUpgrade();
	end

	if ExpansionTrialCheckPointDialog then
		return ExpansionTrialCheckPointDialog:IsShowingExpansionTrialUpgrade();
	end

	return false;
end
