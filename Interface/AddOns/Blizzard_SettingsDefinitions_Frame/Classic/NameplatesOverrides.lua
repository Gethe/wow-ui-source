NameplatesOverrides = {}

function NameplatesOverrides.ShowClassicStyleOption()
	return true;
end

function NameplatesOverrides.ShowHighlightImportantCastsOption()
	return false;
end

function NameplatesOverrides.AdjustNameplateSettings(category)
	do
		-- Nameplate Distance
		local minValue, maxValue, step = 20, 41, 1;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, IncrementByOne);
		Settings.SetupCVarSlider(category, "nameplateMaxDistance", options, UNIT_NAMEPLATES_MAX_DISTANCE, OPTION_TOOLTIP_UNIT_NAMEPLATES_MAX_DISTANCE);
	end
end
