--[[ Mainline EditModeUtil ]]

EditModeUtil = { };

function EditModeUtil.GetBottomActionBars()
	return { MainActionBar, MultiBarBottomLeft, MultiBarBottomRight, StanceBar, PetActionBar, PossessActionBar, MainMenuBarVehicleLeaveButton };
end

function EditModeUtil.GetBottomActionBarHierarchy()
	return { MainMenuBarVehicleLeaveButton, PossessActionBar, PetActionBar, StanceBar, OverrideActionBar, MultiBarBottomRight, MultiBarBottomLeft, MainActionBar };
end

function EditModeUtil.GetCenterManagedSystems()
	return { MainActionBar };
end
