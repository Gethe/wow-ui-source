GraphicsOverrides = {}

function GraphicsOverrides.CreateAdvancedSettingsTable(category, addFunc)
	local advSettings = {};

	addFunc(advSettings, category, "graphicsQuality", GRAPHICS_QUALITY, "PROXY_GRAPHICS_QUALITY");
	addFunc(advSettings, category, "graphicsShadowQuality", SHADOW_QUALITY, "PROXY_SHADOW_QUALITY");
	addFunc(advSettings, category, "graphicsLiquidDetail", LIQUID_DETAIL, "PROXY_LIQUID_DETAIL");
	addFunc(advSettings, category, "graphicsParticleDensity", PARTICLE_DENSITY, "PROXY_PARTICLE_DENSITY", 1);
	addFunc(advSettings, category, "graphicsSSAO", SSAO_LABEL, "PROXY_SSAO");
	addFunc(advSettings, category, "graphicsDepthEffects", DEPTH_EFFECTS, "PROXY_DEPTH_EFFECTS");
	addFunc(advSettings, category, "graphicsComputeEffects", COMPUTE_EFFECTS, "PROXY_COMPUTE_EFFECTS");
	addFunc(advSettings, category, "graphicsOutlineMode", OUTLINE_MODE, "PROXY_OUTLINE_MODE");
	addFunc(advSettings, category, "graphicsTextureResolution", TEXTURE_DETAIL, "PROXY_TEXTURE_RESOLUTION");
	addFunc(advSettings, category, "graphicsSpellDensity", SPELL_DENSITY, "PROXY_SPELL_DENSITY");
	addFunc(advSettings, category, "graphicsProjectedTextures", PROJECTED_TEXTURES, "PROXY_PROJECTED_TEXTURES");
	addFunc(advSettings, category, "graphicsViewDistance", FARCLIP, "PROXY_VIEW_DISTANCE");
	addFunc(advSettings, category, "graphicsEnvironmentDetail", ENVIRONMENT_DETAIL, "PROXY_ENVIRONMENT_DETAIL");
	addFunc(advSettings, category, "graphicsGroundClutter", GROUND_CLUTTER, "PROXY_GROUND_CLUTTER");

	return advSettings;
end

function GraphicsOverrides.CreateAdvancedRaidSettingsTable(category, addFunc)
	local advRaidSettings = {};

	addFunc(advRaidSettings, category, "raidGraphicsQuality", GRAPHICS_QUALITY, "PROXY_RAID_GRAPHICS_QUALITY");
	addFunc(advRaidSettings, category, "raidGraphicsShadowQuality", SHADOW_QUALITY, "PROXY_RAID_SHADOW_QUALITY");
	addFunc(advRaidSettings, category, "raidGraphicsLiquidDetail", LIQUID_DETAIL, "PROXY_RAID_LIQUID_DETAIL");
	addFunc(advRaidSettings, category, "raidGraphicsParticleDensity", PARTICLE_DENSITY, "PROXY_RAID_PARTICLE_DENSITY");
	addFunc(advRaidSettings, category, "raidGraphicsSSAO", SSAO_LABEL, "PROXY_RAID_SSAO");
	addFunc(advRaidSettings, category, "raidGraphicsDepthEffects", DEPTH_EFFECTS, "PROXY_RAID_DEPTH_EFFECTS");
	addFunc(advRaidSettings, category, "raidGraphicsComputeEffects", COMPUTE_EFFECTS, "PROXY_RAID_COMPUTE_EFFECTS");
	addFunc(advRaidSettings, category, "raidGraphicsOutlineMode", OUTLINE_MODE, "PROXY_RAID_OUTLINE_MODE");
	addFunc(advRaidSettings, category, "raidGraphicsTextureResolution", TEXTURE_DETAIL, "PROXY_RAID_TEXTURE_RESOLUTION");
	addFunc(advRaidSettings, category, "raidGraphicsSpellDensity", SPELL_DENSITY, "PROXY_RAID_SPELL_DENSITY");
	addFunc(advRaidSettings, category, "raidGraphicsProjectedTextures", PROJECTED_TEXTURES, "PROXY_RAID_PROJECTED_TEXTURES");
	addFunc(advRaidSettings, category, "raidGraphicsViewDistance", FARCLIP, "PROXY_RAID_VIEW_DISTANCE");
	addFunc(advRaidSettings, category, "raidGraphicsEnvironmentDetail", ENVIRONMENT_DETAIL, "PROXY_RAID_ENVIRONMENT_DETAIL");
	addFunc(advRaidSettings, category, "raidGraphicsGroundClutter", GROUND_CLUTTER, "PROXY_RAID_GROUND_CLUTTER");

	return advRaidSettings;
end

function GraphicsOverrides.CreatePhysicsInteractionSetting(category)
	local function GetOptions()
		local container = Settings.CreateControlTextContainer();
		container:Add(0, NO_ENVIRONMENT_INTERACTION);
		container:Add(1, PLAYER_ONLY_INTERACTION);
		container:Add(2, PLAYER_AND_NPC_INTERACTION);
		return container:GetData();
	end

	local getValue, setValue, getDefaultValue = Settings.CreateCVarAccessorClosures("physicsLevel", Settings.VarType.Number);
	local commitValue = setValue;
	local setting = Settings.RegisterProxySetting(category, "PROXY_PHYSICS_LEVEL", Settings.DefaultVarLocation,
		Settings.VarType.Number, PHYSICS_INTERACTION, getDefaultValue(), getValue, nil, commitValue);
	setting:SetCommitFlags(Settings.CommitFlag.ClientRestart);

	Settings.CreateDropDown(category, setting, GetOptions, OPTION_PHYSICS_OPTIONS);
end

function GraphicsOverrides.AdjustAdvancedQualityControls(parentElement, settings, raid, initDropDownFunc, addOptionFunc, addRecommendedFunc)
end