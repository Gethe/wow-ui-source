ControlsOverrides = {}

function ControlsOverrides.AdjustCameraSettings(category)
	do
		-- Max Camera Distance
		local minValue, maxValue, step = 1.0, 2.0, .1;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);

		local function RoundToOneTenth(value)
			return RoundToSignificantDigits(value, 1);
		end

		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, RoundToOneTenth);
		Settings.SetupCVarSlider(category, "cameraDistanceMaxZoomFactor", options, MAX_FOLLOW_DIST, OPTION_TOOLTIP_MAX_FOLLOW_DIST);
	end

	-- Follow Terrain
	Settings.SetupCVarCheckbox(category, "cameraTerrainTilt", FOLLOW_TERRAIN, OPTION_TOOLTIP_FOLLOW_TERRAIN);

	-- Head Bob
	Settings.SetupCVarCheckbox(category, "cameraBobbing", HEAD_BOB, OPTION_TOOLTIP_HEAD_BOB);

	-- Smart Pivot
	Settings.SetupCVarCheckbox(category, "cameraPivot", SMART_PIVOT, nil);
end

function ControlsOverrides.SetupAutoDismountSetting(category)
	if ClassicExpansionAtLeast(LE_EXPANSION_BURNING_CRUSADE) then
		-- Auto Dismount
		Settings.SetupCVarCheckbox(category, "autoDismountFlying", AUTO_DISMOUNT_FLYING_TEXT, OPTION_TOOLTIP_AUTO_DISMOUNT_FLYING);
	end
end

function ControlsOverrides.RunSettingsCallback(callback)
	callback();
end