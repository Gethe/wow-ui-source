InterfaceOverrides = {}

function InterfaceOverrides.AdjustNameplateSettings(category, layout)
	-- Unused in mainline.
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
		Settings.SetupCVarCheckbox(category, "raidFramesDisplayIncomingHeals", COMPACT_UNIT_FRAME_PROFILE_DISPLAYHEALPREDICTION, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYHEALPREDICTION);
	end

	-- Power Bars
	local raidFramesDisplayPowerBarsSetting, raidFramesDisplayPowerBarsInitializer = Settings.SetupCVarCheckbox(category, "raidFramesDisplayPowerBars", COMPACT_UNIT_FRAME_PROFILE_DISPLAYPOWERBAR, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYPOWERBAR);

	local _, raidFramesDisplayOnlyHealerPowerBarsInitializer = Settings.SetupCVarCheckbox(category, "raidFramesDisplayOnlyHealerPowerBars", COMPACT_UNIT_FRAME_PROFILE_DISPLAYONLYHEALERPOWERBARS, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYONLYHEALERPOWERBARS);
	local function EnableRaidFramesDisplayOnlyHealerPowerBarsSetting()
		return raidFramesDisplayPowerBarsSetting:GetValue();
	end
	raidFramesDisplayOnlyHealerPowerBarsInitializer:SetParentInitializer(raidFramesDisplayPowerBarsInitializer, EnableRaidFramesDisplayOnlyHealerPowerBarsSetting);

	-- Aggro Highlight
	if C_CVar.GetCVar("raidFramesDisplayAggroHighlight") then
		Settings.SetupCVarCheckbox(category, "raidFramesDisplayAggroHighlight", COMPACT_UNIT_FRAME_PROFILE_DISPLAYAGGROHIGHLIGHT, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYAGGROHIGHLIGHT);
	end

	-- Class Colors
	do
		local displayClassColorsSetting = Settings.RegisterCVarSetting(category, "raidFramesDisplayClassColor", Settings.VarType.Boolean, COMPACT_UNIT_FRAME_PROFILE_USECLASSCOLORS);

		local function GetCVarHealthBarColor()
			local healthColorString = CVarCallbackRegistry:GetCVarValue("raidFramesHealthBarColor");
			local color = CreateColorFromHexString(healthColorString);
			return color or COMPACT_UNIT_FRAME_FRIENDLY_HEALTH_COLOR;
		end

		local function OpenHealthBarColorPicker(swatch, button, isDown)
			local info = {};
			info.swatch = swatch;

			local healthColor = GetCVarHealthBarColor();
			info.r, info.g, info.b = healthColor:GetRGB();

			local currentColor = CreateColor(0, 0, 0, 0); -- Making this here to avoid churn
			info.swatchFunc = function()
				local r,g,b = ColorPickerFrame:GetColorRGB();
				currentColor:SetRGB(r, g, b);
				SetCVar("raidFramesHealthBarColor", currentColor:GenerateHexColor());
			end;

			info.cancelFunc = function()
				local r,g,b = ColorPickerFrame:GetPreviousValues();
				currentColor:SetRGB(r, g, b);
				SetCVar("raidFramesHealthBarColor", currentColor:GenerateHexColor());
			end;

			ColorPickerFrame:SetupColorPickerAndShow(info);
		end

		local clickRequiresSet = true;
		local invertClickRequiresSet = true;
		local displayClassColorsInitializer = CreateSettingsCheckboxWithColorSwatchInitializer(
			displayClassColorsSetting,
			OpenHealthBarColorPicker,
			clickRequiresSet,
			invertClickRequiresSet,
			COMPACT_UNIT_FRAME_PROFILE_USECLASSCOLORS,
			GetCVarHealthBarColor
		);

		layout:AddInitializer(displayClassColorsInitializer);
	end

	-- Pets
	Settings.SetupCVarCheckbox(category, "raidOptionDisplayPets", COMPACT_UNIT_FRAME_PROFILE_DISPLAYPETS, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYPETS);

	-- Main Tank and Assist
	Settings.SetupCVarCheckbox(category, "raidOptionDisplayMainTankAndAssist", COMPACT_UNIT_FRAME_PROFILE_DISPLAYMAINTANKANDASSIST, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYMAINTANKANDASSIST);

	-- Debuffs
	do
		local debuffSetting, debuffInitializer = Settings.SetupCVarCheckbox(category, "raidFramesDisplayDebuffs", COMPACT_UNIT_FRAME_PROFILE_DISPLAYNONBOSSDEBUFFS, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYNONBOSSDEBUFFS);

		local function IsModifiable()
			return debuffSetting:GetValue();
		end

		-- Bigger Role Debuffs
		local _, largerDebuffsInitializer = Settings.SetupCVarCheckbox(category, "raidFramesDisplayLargerRoleSpecificDebuffs", COMPACT_UNIT_FRAME_PROFILE_DISPLAY_ROLE_DEBUFFS_LARGER, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAY_ROLE_DEBUFFS_LARGER);
		largerDebuffsInitializer:SetParentInitializer(debuffInitializer, IsModifiable);

		-- Only Dispellable Debuffs
		local _, dispellableInitializer = Settings.SetupCVarCheckbox(category, "raidFramesDisplayOnlyDispellableDebuffs", COMPACT_UNIT_FRAME_PROFILE_DISPLAYONLYDISPELLABLEDEBUFFS, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYONLYDISPELLABLEDEBUFFS);
		dispellableInitializer:SetParentInitializer(debuffInitializer, IsModifiable);
	end

	-- Center Big Defensive Buffs
	Settings.SetupCVarCheckbox(category, "raidFramesCenterBigDefensive", COMPACT_UNIT_FRAME_PROFILE_SHOW_BIG_DEFENSIVES, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_SHOW_BIG_DEFENSIVES);

	-- Dispel Indicator Types (upper right poison, magic, disease, bleed, curse)
	do
		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(Enum.RaidDispelDisplayType.Disabled, COMPACT_UNIT_FRAME_PROFILE_DISPELLABLE_INDICATOR_TYPE_DISABLED, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPELLABLE_INDICATOR_TYPE_DISABLED);
			container:Add(Enum.RaidDispelDisplayType.DispellableByMe, COMPACT_UNIT_FRAME_PROFILE_DISPELLABLE_INDICATOR_TYPE_ME, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPELLABLE_INDICATOR_TYPE_ME);
			container:Add(Enum.RaidDispelDisplayType.DisplayAll, COMPACT_UNIT_FRAME_PROFILE_DISPELLABLE_INDICATOR_TYPE_ALL, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPELLABLE_INDICATOR_TYPE_ALL);
			return container:GetData();
		end

		local dispelSetting, dispelInitializer = Settings.SetupCVarDropdown(category, "raidFramesDispelIndicatorType", Settings.VarType.Number, GetOptions, COMPACT_UNIT_FRAME_PROFILE_DISPELLABLE_INDICATOR_TYPE, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPELLABLE_INDICATOR_TYPE);

		local function IsModifiable()
			return tonumber(dispelSetting:GetValue()) ~= Enum.RaidDispelDisplayType.Disabled;
		end

		-- Dispel Color Overlay
		local _, dispelOverlayInitializer = Settings.SetupCVarCheckbox(category, "raidFramesDispelIndicatorOverlay", COMPACT_UNIT_FRAME_PROFILE_DISPLAY_DISPEL_OVERLAY, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAY_DISPEL_OVERLAY);
		dispelOverlayInitializer:SetParentInitializer(dispelInitializer, IsModifiable);
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

		Settings.SetupCVarDropdown(category, "raidFramesHealthText", Settings.VarType.String, GetOptions, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT);
	end
end

function InterfaceOverrides.CreatePvpFrameSettings(category, layout)
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(PVP_FRAMES_LABEL));

	-- Pvp Power Bars
	local pvpFramesDisplayPowerBarsSetting, pvpFramesDisplayPowerBarsInitializer = Settings.SetupCVarCheckbox(category, "pvpFramesDisplayPowerBars", PVP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYPOWERBAR, OPTION_TOOLTIP_PVP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYPOWERBAR);

	local _, pvpFramesDisplayOnlyHealerPowerBarsInitializer = Settings.SetupCVarCheckbox(category, "pvpFramesDisplayOnlyHealerPowerBars", PVP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYONLYHEALERPOWERBARS, OPTION_TOOLTIP_PVP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYONLYHEALERPOWERBARS);
	local function EnablePvpFramesDisplayOnlyHealerPowerBarsSetting()
		return pvpFramesDisplayPowerBarsSetting:GetValue();
	end
	pvpFramesDisplayOnlyHealerPowerBarsInitializer:SetParentInitializer(pvpFramesDisplayPowerBarsInitializer, EnablePvpFramesDisplayOnlyHealerPowerBarsSetting);

	-- Pvp Class Colors
	Settings.SetupCVarCheckbox(category, "pvpFramesDisplayClassColor", PVP_COMPACT_UNIT_FRAME_PROFILE_USECLASSCOLORS, OPTION_TOOLTIP_PVP_COMPACT_UNIT_FRAME_PROFILE_USECLASSCOLORS);

	-- Pvp Pets
	Settings.SetupCVarCheckbox(category, "pvpOptionDisplayPets", PVP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYPETS, OPTION_TOOLTIP_PVP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYPETS);

	-- Pvp Health Text
	do
		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add("none", PVP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, OPTION_TOOLTIP_PVP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE);
			container:Add("health", PVP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, OPTION_TOOLTIP_PVP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH);
			container:Add("losthealth", PVP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH, OPTION_TOOLTIP_PVP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH);
			container:Add("perc", PVP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, OPTION_TOOLTIP_PVP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC);
			return container:GetData();
		end

		Settings.SetupCVarDropdown(category, "pvpFramesHealthText", Settings.VarType.String, GetOptions, PVP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, OPTION_TOOLTIP_PVP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT);
	end
end

-- These popups have a "Don't show this again" checkbox that the player can click to skip them in the future.
local function ResetConfirmationPopups()
	SetCVar("bankConfirmTabCleanUp", true);
end

function InterfaceOverrides.ShowTutorialsOnButtonClick()
		SetCVar("closedInfoFrames", ""); -- reset the help plates too
		SetCVar("closedInfoFramesAccountWide", "");
		SetCVar("showNPETutorials", "1");
		ResetTutorials();
		TutorialFrame_ClearQueue();
		NPETutorial_AttemptToBegin();
		TriggerTutorial(1);
		ResetConfirmationPopups();
		TutorialManager:ResetTutorials();
end

function InterfaceOverrides.RunSettingsCallback(callback)
	if not C_GameRules.IsPlunderstorm() then
		callback();
	end
end

function InterfaceOverrides.CreateQuestSettings(category, layout)
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(QUEST_SETTINGS_LABEL));

	local function SetQuestTracking(filter, value)
		local filterIndex = MinimapUtil.GetFilterIndexForFilterID(filter);
		if filterIndex then
			C_Minimap.SetTracking(filterIndex, value);
		end
	end

	-- Account completed quest filter
	local function SetAccountCompletedQuestTracking(value)
		SetQuestTracking(Enum.MinimapTrackingFilter.AccountCompletedQuests, value);
	end

	local function IsTrackingAccountCompletedQuests()
		return not C_Minimap.IsFilteredOut(Enum.MinimapTrackingFilter.AccountCompletedQuests);
	end

	local accountCompletedQuestFilterSetting = Settings.RegisterProxySetting(category, "PROXY_ACCOUNT_COMPLETED_QUEST_FILTERING",
		Settings.VarType.Boolean, SETTINGS_ACCOUNT_COMPLETED_QUEST_FILTER, Settings.Default.False, IsTrackingAccountCompletedQuests, SetAccountCompletedQuestTracking);
	Settings.CreateCheckbox(category, accountCompletedQuestFilterSetting, ACCOUNT_COMPLETED_QUESTS_FILTER_DESCRIPTION);

	-- Trivial quest filter
	local function SetTrivialQuestTracking(value)
		SetQuestTracking(Enum.MinimapTrackingFilter.TrivialQuests, value);
	end

	local function IsTrackingTrivialQuests()
		return not C_Minimap.IsFilteredOut(Enum.MinimapTrackingFilter.TrivialQuests);
	end

	local trivialQuestFilterSetting = Settings.RegisterProxySetting(category, "PROXY_TRIVIAL_QUEST_FILTERING",
		Settings.VarType.Boolean, SETTINGS_TRIVIAL_QUEST_FILTER, Settings.Default.False, IsTrackingTrivialQuests, SetTrivialQuestTracking);
	Settings.CreateCheckbox(category, trivialQuestFilterSetting);
end
