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
	Settings.SetupCVarCheckBox(category, "cameraTerrainTilt", FOLLOW_TERRAIN, nil);

	-- Head Bob
	Settings.SetupCVarCheckBox(category, "cameraBobbing", HEAD_BOB, nil);

	-- Smart Pivot
	Settings.SetupCVarCheckBox(category, "cameraPivot", SMART_PIVOT, nil);
end