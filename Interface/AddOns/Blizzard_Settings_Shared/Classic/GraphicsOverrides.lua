GraphicsOverrides = {}

function GraphicsOverrides.CreateAdvancedSettingsTable(category, addFunc)
	local advSettings = {};

	addFunc(advSettings, category, "graphicsQuality", GRAPHICS_QUALITY, "PROXY_GRAPHICS_QUALITY");
	addFunc(advSettings, category, "graphicsShadowQuality", SHADOW_QUALITY, "PROXY_SHADOW_QUALITY");
	addFunc(advSettings, category, "graphicsLiquidDetail", LIQUID_DETAIL, "PROXY_LIQUID_DETAIL");
	addFunc(advSettings, category, "graphicsParticleDensity", PARTICLE_DENSITY, "PROXY_PARTICLE_DENSITY", 1);
	addFunc(advSettings, category, "graphicsSSAO", SSAO_LABEL, "PROXY_SSAO");
	addFunc(advSettings, category, "graphicsTextureResolution", TEXTURE_DETAIL, "PROXY_TEXTURE_RESOLUTION");
	addFunc(advSettings, category, "graphicsSpellDensity", SPELL_DENSITY, "PROXY_SPELL_DENSITY");
	addFunc(advSettings, category, "graphicsProjectedTextures", PROJECTED_TEXTURES, "PROXY_PROJECTED_TEXTURES");
	addFunc(advSettings, category, "graphicsEnvironmentDetail", ENVIRONMENT_DETAIL, "PROXY_ENVIRONMENT_DETAIL");
	addFunc(advSettings, category, "graphicsGroundClutter", GROUND_CLUTTER, "PROXY_GROUND_CLUTTER");
	addFunc(advSettings, category, "graphicsSunshafts", SUNSHAFTS, "PROXY_SUNSHAFTS");

	return advSettings;
end

function GraphicsOverrides.CreateAdvancedRaidSettingsTable(category, addFunc)
	local advRaidSettings = {};

	addFunc(advRaidSettings, category, "raidGraphicsQuality", GRAPHICS_QUALITY, "PROXY_RAID_GRAPHICS_QUALITY");
	addFunc(advRaidSettings, category, "raidGraphicsShadowQuality", SHADOW_QUALITY, "PROXY_RAID_SHADOW_QUALITY");
	addFunc(advRaidSettings, category, "raidGraphicsLiquidDetail", LIQUID_DETAIL, "PROXY_RAID_LIQUID_DETAIL");
	addFunc(advRaidSettings, category, "raidGraphicsParticleDensity", PARTICLE_DENSITY, "PROXY_RAID_PARTICLE_DENSITY");
	addFunc(advRaidSettings, category, "raidGraphicsSSAO", SSAO_LABEL, "PROXY_RAID_SSAO");
	addFunc(advRaidSettings, category, "raidGraphicsTextureResolution", TEXTURE_DETAIL, "PROXY_RAID_TEXTURE_RESOLUTION");
	addFunc(advRaidSettings, category, "raidGraphicsSpellDensity", SPELL_DENSITY, "PROXY_RAID_SPELL_DENSITY");
	addFunc(advRaidSettings, category, "raidGraphicsProjectedTextures", PROJECTED_TEXTURES, "PROXY_RAID_PROJECTED_TEXTURES");
	addFunc(advRaidSettings, category, "raidGraphicsEnvironmentDetail", ENVIRONMENT_DETAIL, "PROXY_RAID_ENVIRONMENT_DETAIL");
	addFunc(advRaidSettings, category, "raidGraphicsGroundClutter", GROUND_CLUTTER, "PROXY_RAID_GROUND_CLUTTER");
	addFunc(advRaidSettings, category, "raidGraphicsSunshafts", SUNSHAFTS, "PROXY_RAID_SUNSHAFTS");

	return advRaidSettings;
end

function GraphicsOverrides.AdjustAdvancedQualityControls(parentElement, settings, raid, initDropdownFunc, addOptionFunc, addRecommendedFunc)
	parentElement.TextureResolution:SetPoint("TOPLEFT", parentElement.DepthEffects, "BOTTOMLEFT", 0, -10);
	parentElement.EnvironmentDetail:SetPoint("TOPLEFT", parentElement.ProjectedTextures, "BOTTOMLEFT", 0, -10);

	local settingSunshafts = settings["graphicsSunshafts"] or settings["raidGraphicsSunshafts"];
	local function GetSunshaftsOptions()
		local container = Settings.CreateControlTextContainer();
		local variable = settingSunshafts:GetVariable();
		addOptionFunc(container, variable, raid, 0, VIDEO_OPTIONS_DISABLED, VIDEO_OPTIONS_SUNSHAFTS_DISABLED);
		addOptionFunc(container, variable, raid, 1, VIDEO_OPTIONS_LOW, VIDEO_OPTIONS_SUNSHAFTS_LOW);
		addOptionFunc(container, variable, raid, 2, VIDEO_OPTIONS_HIGH, VIDEO_OPTIONS_SUNSHAFTS_HIGH);
		addRecommendedFunc(container, variable);
		return container:GetData();
	end

	--reclaiming the DepthEffects control for sunshafts
	initDropdownFunc(parentElement.DepthEffects, settingSunshafts, SUNSHAFTS, OPTION_TOOLTIP_SUNSHAFTS, GetSunshaftsOptions);
	parentElement.DepthEffects:Show();
end

function GraphicsOverrides.GetTextureResolutionOptions(settingTextureResolution, addValidatedSettingOptionFunc, addRecommendedFunc)
	local container = Settings.CreateControlTextContainer();
	local variable = settingTextureResolution:GetVariable();
	addValidatedSettingOptionFunc(container, variable, raid, 0, VIDEO_OPTIONS_LOW, VIDEO_OPTIONS_TEXTURE_DETAIL_LOW);
	addValidatedSettingOptionFunc(container, variable, raid, 1, VIDEO_OPTIONS_HIGH, VIDEO_OPTIONS_TEXTURE_DETAIL_HIGH);
	addRecommendedFunc(container, variable);
	return container:GetData();
end 

function GraphicsOverrides.CreateHiResOptions(category, layout)
	if (not AreHighResTexturesAvailable()) then 
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
	setting:SetCommitFlags(Settings.CommitFlag.Apply);

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
	if not InGlue() then
		callback();
	end
end