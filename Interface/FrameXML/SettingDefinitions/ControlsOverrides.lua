ControlsOverrides = {}

function ControlsOverrides.AdjustCameraSettings(category)
end

function ControlsOverrides.SetupAutoDismountSetting(category)
	-- Auto Dismount
	Settings.SetupCVarCheckBox(category, "autoDismountFlying", AUTO_DISMOUNT_FLYING_TEXT, OPTION_TOOLTIP_AUTO_DISMOUNT_FLYING);
end