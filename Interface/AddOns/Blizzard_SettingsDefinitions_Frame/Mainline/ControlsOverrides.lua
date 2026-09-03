ControlsOverrides = {}

function ControlsOverrides.AdjustCameraSettings(category)
end

function ControlsOverrides.SetupAutoDismountSetting(category)
	-- Plunderstorm doesn't have mounts.
	if C_GameRules.IsPlunderstorm() then
		return;
	end

	-- Auto Dismount
	Settings.SetupCVarCheckbox(category, "autoDismountFlying", AUTO_DISMOUNT_FLYING_TEXT, OPTION_TOOLTIP_AUTO_DISMOUNT_FLYING);
end

function ControlsOverrides.SetupCombinedBagsSetting(category)
	if C_CVar.GetCVar("combinedBags") then
		-- Use Combined Inventory Bags
		Settings.SetupCVarCheckbox(category, "combinedBags", USE_COMBINED_BAGS_TEXT, OPTION_TOOLTIP_USE_COMBINED_BAGS);
	end
end

function ControlsOverrides.RunSettingsCallback(callback)
	if not C_GameRules.IsPlunderstorm() then
		callback();
	end	
end
