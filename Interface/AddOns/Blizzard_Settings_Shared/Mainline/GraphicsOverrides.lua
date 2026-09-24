GraphicsOverrides = {}

function GraphicsOverrides.CreateAdvancedSettingsTable(category, addFunc)
	local advSettings = {};

	addFunc(advSettings, category, "graphicsQuality", GRAPHICS_QUALITY, "PROXY_GRAPHICS_QUALITY");
	addFunc(advSettings, category, "graphicsShadowQuality", SHADOW_QUALITY, "PROXY_SHADOW_QUALITY");
	addFunc(advSettings, category, "graphicsLiquidDetail", LIQUID_DETAIL, "PROXY_LIQUID_DETAIL");
	if C_VideoOptions.IsPBRWaterSupported() then
		addFunc(advSettings, category, "graphicsPBRLiquidDetail", PBR_LIQUID_DETAIL, "PROXY_PBR_LIQUID_DETAIL");
	end
	addFunc(advSettings, category, "graphicsParticleDensity", PARTICLE_DENSITY, "PROXY_PARTICLE_DENSITY", 1);
	addFunc(advSettings, category, "graphicsSSAO", SSAO_LABEL, "PROXY_SSAO");
	addFunc(advSettings, category, "graphicsDepthEffects", DEPTH_EFFECTS, "PROXY_DEPTH_EFFECTS");
	addFunc(advSettings, category, "graphicsComputeEffects", COMPUTE_EFFECTS, "PROXY_COMPUTE_EFFECTS");
	if(C_VideoOptions.IsOutlineModeSupported()) then
		addFunc(advSettings, category, "graphicsOutlineMode", OUTLINE_MODE, "PROXY_OUTLINE_MODE");
	end
	addFunc(advSettings, category, "graphicsTextureResolution", TEXTURE_DETAIL, "PROXY_TEXTURE_RESOLUTION");
	if(C_VideoOptions.IsSpellVisualDensitySystemSupported()) then
		addFunc(advSettings, category, "graphicsSpellDensity", SPELL_DENSITY, "PROXY_SPELL_DENSITY");
	end
	addFunc(advSettings, category, "graphicsProjectedTextures", PROJECTED_TEXTURES, "PROXY_PROJECTED_TEXTURES");
	if (C_VideoOptions.IsSecondaryLightingSupported()) then
		addFunc(advSettings, category, "graphicsLightMode", LIGHTING_MODE, "PROXY_LIGHT_MODE");
	end
	addFunc(advSettings, category, "graphicsViewDistance", FARCLIP, "PROXY_VIEW_DISTANCE");
	addFunc(advSettings, category, "graphicsEnvironmentDetail", ENVIRONMENT_DETAIL, "PROXY_ENVIRONMENT_DETAIL");
	addFunc(advSettings, category, "graphicsGroundClutter", GROUND_CLUTTER, "PROXY_GROUND_CLUTTER");
	if (C_VideoOptions.IsLinearEnabledOnStart()) then
		addFunc(advSettings, category, "graphicsBloomUserMult", BLOOM_MULT, "PROXY_BLOOM_MULT");
	end
	return advSettings;
end

function GraphicsOverrides.CreateAdvancedRaidSettingsTable(category, addFunc)
	local advRaidSettings = {};

	addFunc(advRaidSettings, category, "raidGraphicsQuality", GRAPHICS_QUALITY, "PROXY_RAID_GRAPHICS_QUALITY");
	addFunc(advRaidSettings, category, "raidGraphicsShadowQuality", SHADOW_QUALITY, "PROXY_RAID_SHADOW_QUALITY");
	addFunc(advRaidSettings, category, "raidGraphicsLiquidDetail", LIQUID_DETAIL, "PROXY_RAID_LIQUID_DETAIL");
	if C_VideoOptions.IsPBRWaterSupported() then
		addFunc(advRaidSettings, category, "raidGraphicsPBRLiquidDetail", PBR_LIQUID_DETAIL, "PROXY_RAID_PBR_LIQUID_DETAIL");
	end
	addFunc(advRaidSettings, category, "raidGraphicsParticleDensity", PARTICLE_DENSITY, "PROXY_RAID_PARTICLE_DENSITY");
	addFunc(advRaidSettings, category, "raidGraphicsSSAO", SSAO_LABEL, "PROXY_RAID_SSAO");
	addFunc(advRaidSettings, category, "raidGraphicsDepthEffects", DEPTH_EFFECTS, "PROXY_RAID_DEPTH_EFFECTS");
	addFunc(advRaidSettings, category, "raidGraphicsComputeEffects", COMPUTE_EFFECTS, "PROXY_RAID_COMPUTE_EFFECTS");
	if(C_VideoOptions.IsOutlineModeSupported()) then
		addFunc(advRaidSettings, category, "raidGraphicsOutlineMode", OUTLINE_MODE, "PROXY_RAID_OUTLINE_MODE");
	end
	addFunc(advRaidSettings, category, "raidGraphicsTextureResolution", TEXTURE_DETAIL, "PROXY_RAID_TEXTURE_RESOLUTION");
	if(C_VideoOptions.IsSpellVisualDensitySystemSupported()) then
		addFunc(advRaidSettings, category, "raidGraphicsSpellDensity", SPELL_DENSITY, "PROXY_RAID_SPELL_DENSITY");
	end
	addFunc(advRaidSettings, category, "raidGraphicsProjectedTextures", PROJECTED_TEXTURES, "PROXY_RAID_PROJECTED_TEXTURES");
	if (C_VideoOptions.IsSecondaryLightingSupported()) then
		addFunc(advRaidSettings, category, "raidGraphicsLightMode", LIGHTING_MODE, "PROXY_RAID_LIGHT_MODE");
	end
	addFunc(advRaidSettings, category, "raidGraphicsViewDistance", FARCLIP, "PROXY_RAID_VIEW_DISTANCE");
	addFunc(advRaidSettings, category, "raidGraphicsEnvironmentDetail", ENVIRONMENT_DETAIL, "PROXY_RAID_ENVIRONMENT_DETAIL");
	addFunc(advRaidSettings, category, "raidGraphicsGroundClutter", GROUND_CLUTTER, "PROXY_RAID_GROUND_CLUTTER");
	if (C_VideoOptions.IsLinearEnabledOnStart()) then
		addFunc(advRaidSettings, category, "raidGraphicsBloomUserMult", BLOOM_MULT, "PROXY_RAID_BLOOM_MULT");
	end

	return advRaidSettings;
end

function GraphicsOverrides.AdjustAdvancedQualityControls(parentElement, settings, raid, initDropdownFunc, addOptionFunc, addRecommendedFunc)
end

function GraphicsOverrides.GetTextureResolutionOptions(settingTextureResolution, addValidatedSettingOptionFunc, addRecommendedFunc)
		local container = Settings.CreateControlTextContainer();
		local variable = settingTextureResolution:GetVariable();
		addValidatedSettingOptionFunc(container, variable, raid, 0, VIDEO_OPTIONS_LOW, VIDEO_OPTIONS_TEXTURE_DETAIL_LOW);
		addValidatedSettingOptionFunc(container, variable, raid, 1, VIDEO_OPTIONS_FAIR, VIDEO_OPTIONS_TEXTURE_DETAIL_FAIR);
		addValidatedSettingOptionFunc(container, variable, raid, 2, VIDEO_OPTIONS_HIGH, VIDEO_OPTIONS_TEXTURE_DETAIL_HIGH);
		addRecommendedFunc(container, variable);
		return container:GetData();
end

function GraphicsOverrides.CreateHDSDToggleOptions(category, layout)
	if (not C_GameRules.IsSDHDToggleEnabled()) then 
		return;
	end

	local function GetOptions()
		local container = Settings.CreateControlTextContainer();
		container:Add(true, STANDARD_DEFINITION, STANDARD_DEFINITION_TOOLTIP);
		container:Add(false, HIGH_DEFINITION, HIGH_DEFINITION_TOOLTIP);
		return container:GetData();
	end

	local function GetValue()
		if C_GameRules.IsSDHDToggleEnabled() then
			return C_GameRules.AccountHasSDEnabled();
		end
		return false;
	end

	local function SetValue(value)
		if C_GameRules.IsSDHDToggleEnabled() then
			C_GameRules.SetSDHDToggleValue(value);
		end
	end

	local function GetDefaultValue()
		-- If we want Classic as the default, then we should return true.
		-- If we want Modern as the default, return false.
		return C_GameRules.GetForeverExperiencePreset() == Enum.ForeverExperiencePreset.Classic;
	end

	local setting = Settings.RegisterProxySetting(category, "PROXY_CHARACTER_MODELS_TOGGLE", 
		Settings.VarType.Boolean, CHARACTER_MODELS, GetDefaultValue, GetValue, SetValue);

	setting:SetCommitFlags(Settings.CommitFlag.Apply, Settings.CommitFlag.UIReload);

	local initializer = Settings.CreateDropdown(category, setting, GetOptions, OPTION_TOOLTIP_CHARACTER_MODELS);
	initializer:AddShownPredicate(C_GameRules.IsSDHDToggleEnabled);
	initializer:AddModifyPredicate(C_GameRules.IsSDHDToggleEnabled);
	initializer:AddSearchTags(SD_SEARCH_TAG);
	initializer:AddSearchTags(HD_SEARCH_TAG);
	initializer:AddSearchTags(STANDARD_DEFINITION);
	initializer:AddSearchTags(HIGH_DEFINITION);
end

function GraphicsOverrides.CreateHiResOptions(category, layout)
	if (not C_VideoOptions.AreHighResTexturesAvailable()) then 
		return;
	end

	local function GetOptions()
		local container = Settings.CreateControlTextContainer();
		container:Add(false, VIDEO_OPTIONS_DISABLED);
		container:Add(true, VIDEO_OPTIONS_ENABLED);
		return container:GetData();
	end

	local function GetValue()
		if C_BattleNet.AreHighResTexturesInstalled() then
			return GetCVarBool("useHighResTextures");
		end
		return false;
	end

	local function SetValue(value)
		if C_BattleNet.AreHighResTexturesInstalled() then
			SetCVar("useHighResTextures", value);
		end
	end

	local setting = Settings.RegisterProxySetting(category, "PROXY_HIGH_RES_TEXTURES", 
	Settings.VarType.Boolean, OPTION_HD_TEXTURES, Settings.Default.True, GetValue, SetValue);
	if (C_BattleNet.CanToggleHighResTexturesWithoutClientReload()) then
		setting:SetCommitFlags(Settings.CommitFlag.Apply);
	else
		setting:SetCommitFlags(Settings.CommitFlag.Apply, Settings.CommitFlag.ClientRestart);
	end

	local initializer = Settings.CreateDropdown(category, setting, GetOptions, OPTION_TOOLTIP_HD_TEXTURES);
	initializer:AddShownPredicate(BNConnected);
	initializer:AddModifyPredicate(C_BattleNet.AreHighResTexturesInstalled);

	if not C_BattleNet.AreHighResTexturesInstalled() then
		local function OnClick()
			StaticPopup_Show("DOWNLOAD_HIGH_RES_TEXTURES");
		end

		local addSearchTags = true;
		local hdTexturesInitializer = CreateSettingsButtonInitializer(OPTION_HD_TEXTURES, HD_TEXTURES_BUTTON, OnClick, OPTION_TOOLTIP_HD_TEXTURES, addSearchTags);
		hdTexturesInitializer.hideText = true;

		local version = GetBuildInfo();
		hdTexturesInitializer.showNew = version == "4.4.1";
		hdTexturesInitializer:AddShownPredicate(BNConnected);
		layout:AddInitializer(hdTexturesInitializer);
	end
end

function GraphicsOverrides.RunSettingsCallback(callback)
	callback();
end
