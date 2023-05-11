InterfaceOverrides = {}

function InterfaceOverrides.CreateLargerNameplateSetting(category)
	local normalScale = 1.0;
	local function GetValue()
		local hScale = GetCVarNumberOrDefault("NamePlateHorizontalScale");
		local vScale = GetCVarNumberOrDefault("NamePlateVerticalScale");
		local cScale = GetCVarNumberOrDefault("NamePlateClassificationScale");
		return not (ApproximatelyEqual(hScale, normalScale) and ApproximatelyEqual(vScale, normalScale) and ApproximatelyEqual(cScale, normalScale));
	end
		
	local function SetValue(value)
		if value then
			SetCVar("NamePlateHorizontalScale", 1.4);
			SetCVar("NamePlateVerticalScale", 2.7);
			SetCVar("NamePlateClassificationScale", 1.25);
		else
			SetCVar("NamePlateHorizontalScale", normalScale);
			SetCVar("NamePlateVerticalScale", normalScale);
			SetCVar("NamePlateClassificationScale", normalScale);
		end
	end

	local defaultValue = false;
	local setting = Settings.RegisterProxySetting(category, "PROXY_LARGER_SETTINGS", Settings.DefaultVarLocation, 
		Settings.VarType.Boolean, UNIT_NAMEPLATES_MAKE_LARGER, defaultValue, GetValue, SetValue);
	local initializer = Settings.CreateCheckBox(category, setting, OPTION_TOOLTIP_UNIT_NAMEPLATES_MAKE_LARGER);
	initializer:AddModifyPredicate(function()
		return not C_Commentator.IsSpectating();
	end);
end

function InterfaceOverrides.AdjustNameplateSettings(category)
end

function InterfaceOverrides.AdjustDisplaySettings(category)
end

function InterfaceOverrides.CreateRaidFrameSettings(category, layout)
	-- Raid Frame Preview
	do
		local data = { };
		local initializer = Settings.CreatePanelInitializer("RaidFramePreviewTemplate", data);
		layout:AddInitializer(initializer);
	end

	-- Incoming Heals
	if C_CVar.GetCVar("raidFramesDisplayIncomingHeals") then
		Settings.SetupCVarCheckBox(category, "raidFramesDisplayIncomingHeals", COMPACT_UNIT_FRAME_PROFILE_DISPLAYHEALPREDICTION, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYHEALPREDICTION);
	end

	-- Power Bars
	local raidFramesDisplayPowerBarsSetting, raidFramesDisplayPowerBarsInitializer = Settings.SetupCVarCheckBox(category, "raidFramesDisplayPowerBars", COMPACT_UNIT_FRAME_PROFILE_DISPLAYPOWERBAR, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYPOWERBAR);

	local _, raidFramesDisplayOnlyHealerPowerBarsInitializer = Settings.SetupCVarCheckBox(category, "raidFramesDisplayOnlyHealerPowerBars", COMPACT_UNIT_FRAME_PROFILE_DISPLAYONLYHEALERPOWERBARS, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYONLYHEALERPOWERBARS);
	local function EnableRaidFramesDisplayOnlyHealerPowerBarsSetting()
		return raidFramesDisplayPowerBarsSetting:GetValue();
	end
	raidFramesDisplayOnlyHealerPowerBarsInitializer:SetParentInitializer(raidFramesDisplayPowerBarsInitializer, EnableRaidFramesDisplayOnlyHealerPowerBarsSetting);

	-- Aggro Highlight
	if C_CVar.GetCVar("raidFramesDisplayAggroHighlight") then
		Settings.SetupCVarCheckBox(category, "raidFramesDisplayAggroHighlight", COMPACT_UNIT_FRAME_PROFILE_DISPLAYAGGROHIGHLIGHT, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYAGGROHIGHLIGHT);
	end

	-- Class Colors
	Settings.SetupCVarCheckBox(category, "raidFramesDisplayClassColor", COMPACT_UNIT_FRAME_PROFILE_USECLASSCOLORS, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_USECLASSCOLORS);

	-- Pets
	Settings.SetupCVarCheckBox(category, "raidOptionDisplayPets", COMPACT_UNIT_FRAME_PROFILE_DISPLAYPETS, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYPETS);

	-- Main Tank and Assist
	Settings.SetupCVarCheckBox(category, "raidOptionDisplayMainTankAndAssist", COMPACT_UNIT_FRAME_PROFILE_DISPLAYMAINTANKANDASSIST, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYMAINTANKANDASSIST);

	do
		-- Debuffs
		local debuffSetting, debuffInitializer = Settings.SetupCVarCheckBox(category, "raidFramesDisplayDebuffs", COMPACT_UNIT_FRAME_PROFILE_DISPLAYNONBOSSDEBUFFS, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYNONBOSSDEBUFFS);

		-- Only Dispellable Debuffs
		local function IsModifiable()
			return debuffSetting:GetValue();
		end

		local _, initializer = Settings.SetupCVarCheckBox(category, "raidFramesDisplayOnlyDispellableDebuffs", COMPACT_UNIT_FRAME_PROFILE_DISPLAYONLYDISPELLABLEDEBUFFS, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYONLYDISPELLABLEDEBUFFS);
		initializer:SetParentInitializer(debuffInitializer, IsModifiable);
	end

	-- Health Text
	do 
		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add("none", COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE);
			container:Add("health", COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH);
			container:Add("losthealth", COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH);
			container:Add("perc", COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC);
			return container:GetData();
		end

		Settings.SetupCVarDropDown(category, "raidFramesHealthText", Settings.VarType.String, GetOptions, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT);
	end
end