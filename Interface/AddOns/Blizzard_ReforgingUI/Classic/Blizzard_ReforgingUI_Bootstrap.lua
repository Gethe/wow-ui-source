local AddonName = ...;

function Reforging_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ShowReforgingFrame()
	if Reforging_LoadUI() then
		ReforgingFrame_Show();
	end
end

function HideReforgingFrame()
	if C_AddOns.IsAddOnLoaded(AddonName) and ReforgingFrame_Hide then
		ReforgingFrame_Hide();
	end
end
