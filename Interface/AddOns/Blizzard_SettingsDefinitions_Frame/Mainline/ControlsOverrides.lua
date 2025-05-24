ControlsOverrides = {}

function ControlsOverrides.AdjustCameraSettings(category)
end

function ControlsOverrides.SetupAutoDismountSetting(category)
	-- Plunderstorm doesn't have mounts.
	if Settings.IsPlunderstorm() then
		return;
	end

	-- Auto Dismount
	Settings.SetupCVarCheckbox(category, "autoDismountFlying", AUTO_DISMOUNT_FLYING_TEXT, OPTION_TOOLTIP_AUTO_DISMOUNT_FLYING);
end
function ControlsOverrides.RunSettingsCallback(callback)
	if not Settings.IsPlunderstorm() then
		callback();
	end	
end