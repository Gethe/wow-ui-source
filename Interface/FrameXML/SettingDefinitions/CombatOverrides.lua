CombatOverrides = {}

function CombatOverrides.CreateRaidSelfHighlightSetting(category)
	local function GetOptions()
		local container = Settings.CreateControlTextContainer();
		container:Add(0, SELF_HIGHLIGHT_MODE_CIRCLE);
		container:Add(2, SELF_HIGHLIGHT_MODE_OUTLINE);
		container:Add(1, SELF_HIGHLIGHT_MODE_CIRCLE_AND_OUTLINE);
		container:Add(-1, OFF);
		return container:GetData();
	end

	return Settings.SetupCVarDropDown(category, "findYourselfMode", Settings.VarType.Number, GetOptions, SELF_HIGHLIGHT_OPTION, OPTION_TOOLTIP_SELF_HIGHLIGHT);
end

function CombatOverrides.CreateFloatingCombatTextSetting(category)
	Settings.SetupCVarCheckBox(category, "enableFloatingCombatText", SHOW_COMBAT_TEXT_TEXT, OPTION_TOOLTIP_SHOW_COMBAT_TEXT);
	Settings.LoadAddOnCVarWatcher("enableFloatingCombatText", "Blizzard_CombatText");
end

function CombatOverrides.AdjustCombatSettings(category)
end