--[[ Camelot EditModeUtil ]]

EditModeUtil = { };

function EditModeUtil.GetBottomActionBars()
	local activeLayoutInfo = EditModeManagerFrame:GetActiveLayoutInfo();
	if activeLayoutInfo and (activeLayoutInfo.interfaceStyle == Enum.InputDeviceInterfaceType.Gamepad) then
		return {};
	end

	local bottomActionBars = {
		MainActionBar,
		SecondaryStatusTrackingBarContainer,
		MainStatusTrackingBarContainer,
		MultiBarBottomRight,
		MultiBarBottomLeft,
		StanceBar,
		PetActionBar,
		PossessActionBar,
		MainMenuBarVehicleLeaveButton
	}
	return bottomActionBars;
end

function EditModeUtil.GetBottomActionBarHierarchy()
	-- In Camelot, the MainActionBar is anchored to the MicroMenuContainer, so use the MicroMenuContainer to determine the height of the bottom bar stack.
	return { OverrideActionBar, MultiBarBottomLeft, MicroMenuContainer };
end

function EditModeUtil.GetCenterManagedSystems()
	return { MainActionBar, MicroMenu, BagsBar };
end
