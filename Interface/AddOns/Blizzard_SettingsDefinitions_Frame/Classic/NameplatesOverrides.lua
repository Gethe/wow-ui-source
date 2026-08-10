NameplatesOverrides = {}

NameplatesOverrides.NPCNamesDefaultValue = 5; -- This is the NPC_NAMES_DROPDOWN_NONE setting. No names by default for Classic! (This was the original default behavior up until Cataclysm, where Quests became the default.)

function NameplatesOverrides.ShowClassicStyleOption()
	return true;
end

function NameplatesOverrides.ShowHighlightImportantCastsOption()
	return false;
end

function NameplatesOverrides.ShowClassColorSetting()
	return true;
end

function NameplatesOverrides.AdjustNameplateSettings(category)
	do
		-- Nameplate Distance
		InterfaceOverrides.RunSettingsCallback(function()
			local minValue, maxValue, step = 20, 41, 1;
			local options = Settings.CreateSliderOptions(minValue, maxValue, step);
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, IncrementByOne);
			Settings.SetupCVarSlider(category, "nameplateMaxDistance", options, UNIT_NAMEPLATES_MAX_DISTANCE, OPTION_TOOLTIP_UNIT_NAMEPLATES_MAX_DISTANCE);
		end);
	end
end
