local AddonName = ...;

function RuneforgeFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ShowRuneforgeFrame(isUpgrade)
	if RuneforgeFrame_LoadUI() then
		RuneforgeFrame:SetRuneforgeState(isUpgrade and RuneforgeUtil.RuneforgeState.Upgrade or RuneforgeUtil.RuneforgeState.Craft);
		ShowUIPanel(RuneforgeFrame);
	end
end
