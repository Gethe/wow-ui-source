CombatOverrides = {}

function CombatOverrides.CreateRaidSelfHighlightSetting(category)
	-- The get and set essentially perform bitwise operations with powers of 2 instead of bits 
	local function GetValue()
		local circleOn = GetCVarBool("findYourselfModeCircle");
		local outlineOn = GetCVarBool("findYourselfModeOutline");
		local iconOn = GetCVarBool("findYourselfModeIcon");

		local value = (circleOn and 1 or 0) + (outlineOn and 2 or 0) + (iconOn and 4 or 0); 
		return value;
	end
	
	local function SetValue(value)
		local NUM_COMBINATIONS = 8;
		SetCVar("findYourselfAnywhere", value > 0 and value < NUM_COMBINATIONS);

		SetCVar("findYourselfModeIcon", value >= 4);
		if (value >= 4) then
			value = value - 4;
		end

		SetCVar("findYourselfModeOutline", value >= 2);
		if (value >= 2) then
			value = value - 2;
		end

		SetCVar("findYourselfModeCircle", value >= 1);
	end

	local function GetOptions()
		local container = Settings.CreateControlTextContainer();
		container:Add(1, SELF_HIGHLIGHT_MODE_CIRCLE);
		container:Add(2, SELF_HIGHLIGHT_MODE_OUTLINE);
		container:Add(4, SELF_HIGHLIGHT_MODE_ICON);
		container:Add(3, SELF_HIGHLIGHT_MODE_CIRCLE_AND_OUTLINE);
		container:Add(5, SELF_HIGHLIGHT_MODE_CIRCLE_AND_ICON);
		container:Add(6, SELF_HIGHLIGHT_MODE_OUTLINE_AND_ICON);
		container:Add(7, SELF_HIGHLIGHT_MODE_CIRCLE_OUTLINE_AND_ICON);

		container:Add(0, OFF);
		return container:GetData();
	end

	local defaultValue = 0;
	local setting = Settings.RegisterProxySetting(category, "PROXY_SELF_HIGHLIGHT",
		Settings.VarType.Number, SELF_HIGHLIGHT_OPTION, defaultValue, GetValue, SetValue);
	return setting, Settings.CreateDropdown(category, setting, GetOptions, OPTION_TOOLTIP_SELF_HIGHLIGHT);
end

function CombatOverrides.CreateFloatingCombatTextSetting(category)
	Settings.SetupCVarCheckbox(category, "enableFloatingCombatText", SHOW_COMBAT_TEXT_TEXT, OPTION_TOOLTIP_SHOW_COMBAT_TEXT);
	Settings.LoadAddOnCVarWatcher("enableFloatingCombatText", "Blizzard_CombatText");
end

function CombatOverrides.CreateOccludedSilhouettePlayerSetting(category)
	return Settings.SetupCVarCheckbox(category, "occludedSilhouettePlayer", SHOW_SILHOUETTE_OPTION, OPTION_TOOLTIP_SHOW_SILHOUETTE);
end

function CombatOverrides.AdjustCombatSettings(category)
end

function CombatOverrides.RunSettingsCallback(callback)
	if not Settings.IsPlunderstorm() then
		callback();
	end
end