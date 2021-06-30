-------------------------------------------------------------------------------------------------------
-- Overall Quality
-------------------------------------------------------------------------------------------------------
VideoData["Graphics_Quality"]={
	name = OVERALL_QUALITY;
	childOptions = {
				"Graphics_ViewDistanceSlider",
				"Graphics_ParticleDensityDropDown",
				"Graphics_EnvironmentalDetailSlider",
				"Graphics_GroundClutterSlider",
				"Graphics_ShadowsDropDown",
				"Graphics_TextureResolutionDropDown",
				"Graphics_SpellDensityDropDown",
				"Graphics_LiquidDetailDropDown",
				"Graphics_ProjectedTexturesDropDown",
				"Graphics_SSAODropDown",
				"Graphics_DepthEffectsDropDown",
				"Graphics_ComputeEffectsDropDown",
				"Graphics_OutlineModeDropDown",
			},
	numQualityLevels = 10,
	SetDisplayValue =
		function(self,value)
		end,
	preGetValue =
		function(self)
			self.selectedID = nil;
		end,
	GetValueNew =
		function(self)
			if(self.preGetValue) then
				self:preGetValue();
			end
			if(self.selectedID == nil) then
				self.selectedID = (self.doGetValue or Graphics_TableGetValue)(self);
			end
			return self.selectedID;
		end,
	GetCurrentValue =
		function(self)
			local value = self:GetValue();
			return value;
		end,
	description =  "Video Quality:",
	dependtarget = Graphics_ControlRefreshValue,
	initialize =
		function(self)
			self:SetWidth(550);
			local parent = self:GetParent():GetName();
			local name = self:GetName();

			_G[name.."Text"]:SetFontObject("OptionsFontSmall");
			_G[name.."Low"]:Hide();
			_G[name.."High"]:Hide();

			self.noclick = true;
			if(not self.isdependtarget) then
				self:setinitialslider();
			end
			self:updatecustomfield(self:GetValue());
			self.noclick = false;
		end,
	setinitialslider = function(self)
		self.noclick = true;
		if (self.raid) then
			RaidGraphics_Quality:SetValue(BlizzardOptionsPanel_GetCVarSafe("RAIDgraphicsQuality"));	-- set the slider only
		else
			Graphics_Quality:SetValue(BlizzardOptionsPanel_GetCVarSafe("graphicsQuality"));	-- set the slider only
		end
		self.noclick = false;
	end,
	onload = function(self)
		self.sliderGetValue = self.GetValue;
		self.GetValue = self.GetValueNew;
		self:setinitialslider();
	end,
	updatecustomfield =
		function(self, value)
			if(not value) then
				_G["Graphics_RightQualityLabel"]:Show();
			else
				self.noclick = true;
				Graphics_Quality:SetValue(value);	-- set the slider only
				self.noclick = false;
				if ( not self:GetValue() ) then
					_G["Graphics_RightQualityLabel"]:Show();
				else
					_G["Graphics_RightQualityLabel"]:Hide();
				end
			end
		end,
	onvaluechanged =
		function(self, value)
			value = floor(value + 0.5);
			self.savevalue = value;
			if(not self.noclick) then
				VideoOptions_OnClick(self, value);
				self:updatecustomfield(value);
			end
		end,
	commitslider =
		function(self)
			local value = self:GetValue();
			if(not value) then
				value = self:sliderGetValue();
			end
			local graphicsQualityCVar = "graphicsQuality";
			if (self.raid) then
				graphicsQualityCVar = "RAIDgraphicsQuality";
			end
			BlizzardOptionsPanel_SetCVarSafe(graphicsQualityCVar, value);
		end,
}

VideoData["RaidGraphics_Quality"] = {};
setmetatable( VideoData["RaidGraphics_Quality"], {__index = VideoData["Graphics_Quality"]});
VideoData["RaidGraphics_Quality"].childOptions = {
				"RaidGraphics_ViewDistanceSlider",
				"RaidGraphics_ParticleDensityDropDown",
				"RaidGraphics_EnvironmentalDetailSlider",
				"RaidGraphics_GroundClutterSlider",
				"RaidGraphics_ShadowsDropDown",
				"RaidGraphics_TextureResolutionDropDown",
				"RaidGraphics_SpellDensityDropDown",
				"RaidGraphics_LiquidDetailDropDown",
				"RaidGraphics_ProjectedTexturesDropDown",
				"RaidGraphics_SSAODropDown",
				"RaidGraphics_DepthEffectsDropDown",
				"RaidGraphics_ComputeEffectsDropDown",
				"RaidGraphics_OutlineModeDropDown",
			};
VideoData["RaidGraphics_Quality"].numQualityLevels = 10;
VideoData["RaidGraphics_Quality"].updatecustomfield =
	function(self, value)
		if(not value) then
			_G["RaidGraphics_RightQualityLabel"]:Show();
		else
			self.noclick = true;
			RaidGraphics_Quality:SetValue(value);	-- set the slider only
			self.noclick = false;
			if ( self:GetValue() > self.numQualityLevels ) then
				_G["RaidGraphics_RightQualityLabel"]:Show();
			else
				_G["RaidGraphics_RightQualityLabel"]:Hide();
			end
		end
	end;

-------------------------------------------------------------------------------------------------------
-- Display
-------------------------------------------------------------------------------------------------------

VideoData["Display_DisplayModeDropDown"]={
	name = DISPLAY_MODE;
	description = OPTION_TOOLTIP_DISPLAY_MODE,
	data = {
		[1] = {
			text = VIDEO_OPTIONS_WINDOWED,
			cvars =	{
				gxMaximize = 0,
			},
			windowed = true;
			fullscreen = false;
		},
		[2] = {
			text = VIDEO_OPTIONS_WINDOWED_FULLSCREEN,
			cvars =	{
				gxMaximize = 1,
			},
			windowed = false;
			fullscreen = true;
		},
	},
	dependent = {
		"Display_ResolutionDropDown",
	},
	GetSafeValue =
		function(self)
			local value = self:GetValue();
			return  (value <= #self.data) and value or 1;
		end,
	windowedmode =
		function(self)
			return self.data[self:GetSafeValue()].windowed;
		end,
	fullscreenmode =
		function(self)
			return self.data[self:GetSafeValue()].fullscreen;
		end,
	lookup = Graphics_TableLookupSafe,
	windowUpdate = true,
}
-------------------------------------------------------------------------------------------------------
VideoData["Display_UseUIScale"]={
	name = USE_UISCALE;
	tooltip = OPTION_TOOLTIP_USE_UISCALE,
}
-------------------------------------------------------------------------------------------------------
VideoData["Display_PrimaryMonitorDropDown"]={
	name = PRIMARY_MONITOR;
	description = OPTION_TOOLTIP_PRIMARY_MONITOR,

	table = {},
	tablefunction =
		function(self)
			local count = GetMonitorCount();
			for i=1, count do
				local name = GetMonitorName(i);
				if(not name) then
					if(i == 1) then
						name = VIDEO_OPTIONS_MONITOR_PRIMARY;
					else
						name = string.format(VIDEO_OPTIONS_MONITOR, i-1);
					end
				end
				self.table[i] = name;
			end
		end,
	SetValue =
		function (self, value)
			BlizzardOptionsPanel_SetCVarSafe(self.cvar, value-1);
		end,
	doGetValue =
		function (self)
			return 1+BlizzardOptionsPanel_GetCVarSafe(self.cvar);
		end,
	cvar = "gxMonitor",
	dependent = {
		"Display_DisplayModeDropDown",
		"Display_ResolutionDropDown",	--resolutions may disappear when we change the monitor
	},
	landscape =
		function(self)
			local ratio = GetMonitorAspectRatio(self:GetValue());
			return (ratio>=1.0);
		end,
	windowUpdate = true,
}

-------------------------------------------------------------------------------------------------------

VideoData["Display_ResolutionDropDown"]={
	name = WINDOW_SIZE;
	description = OPTION_TOOLTIP_RESOLUTION,

	tablefunction =
		function(self)
			return GetScreenResolutions(Display_PrimaryMonitorDropDown:GetValue(), Display_DisplayModeDropDown:fullscreenmode());
		end,
	SetValue =
		function (self, value)
			SetScreenResolution(self.table[value]);
		end,
	doGetValue =
		function(self)
			return GetCurrentResolution(Display_PrimaryMonitorDropDown:GetValue(), Display_DisplayModeDropDown:fullscreenmode());
		end,
	onrefresh =
	function(self)
		VideoOptions_Enable(self);
	end,
	lookup = Graphics_TableLookupSafe,
	windowUpdate = true,
}

-------------------------------------------------------------------------------------------------------
VideoData["Display_VerticalSyncDropDown"]={
	name = VERTICAL_SYNC;
	description = OPTION_TOOLTIP_VERTICAL_SYNC,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
			cvars =	{
				vsync = 0,
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_ENABLED,
			cvars =	{
				vsync = 1,
			},
		},
	},
	windowUpdate = true,
}

-------------------------------------------------------------------------------------------------------
local function GenerateMSAAData(data, advanced, ...)
	local lastSampleCount;
	for i = 1, select("#", ...), 3 do
		local msaaQuality, sampleCount, coverageCount = select(i, ...);

		if advanced or sampleCount ~= lastSampleCount then
			data[#data + 1] = {
				text = advanced and ADVANCED_ANTIALIASING_MSAA_FORMAT:format(sampleCount, coverageCount) or ANTIALIASING_MSAA_FORMAT:format(sampleCount),
				cvars =	{
					ffxAntiAliasingMode = not advanced and 0 or nil,
					MSAAQuality = msaaQuality,
				},
			};

			lastSampleCount = sampleCount;
		end
	end
end

local function GenerateFFXAntiAliasingData(data, advanced)
	local fxaa, cmaa = AntiAliasingSupported();

	if fxaa then
		data[#data + 1] = {
			text = ANTIALIASING_FXAA_LOW,
			cvars =	{
				ffxAntiAliasingMode = 1,
				MSAAQuality = not advanced and 0 or nil,
			},
		};

		data[#data + 1] = {
			text = ANTIALIASING_FXAA_HIGH,
			cvars =	{
				ffxAntiAliasingMode = 2,
				MSAAQuality = not advanced and 0 or nil,
			},
		};
	end

	if cmaa then
		data[#data + 1] = {
			text = ANTIALIASING_CMAA,
			cvars =	{
				ffxAntiAliasingMode = 3,
				MSAAQuality = not advanced and 0 or nil,
			},
		};
	end

	return fxaa, cmaa;
end

local function GenerateAntiAliasingDropDownData()
	local data = {};

	data[#data + 1] = {
		text = VIDEO_OPTIONS_NONE,
		cvars =	{
			ffxAntiAliasingMode = 0,
			MSAAQuality = 0,
		},
	};

	local fxaa, cmaa = GenerateFFXAntiAliasingData(data, false);

	GenerateMSAAData(data, false, MultiSampleAntiAliasingSupported());

	return data;
end

VideoData["Display_AntiAliasingDropDown"]={
	name = ANTIALIASING;
	description = OPTION_TOOLTIP_ANTIALIASING,
	onload =
		function(self)
			self.data = GenerateAntiAliasingDropDownData();
		end,
}

VideoData["Display_RaidSettingsEnabledCheckBox"]={
	name = RAID_SETTINGS_ENABLED,
	tooltip = RAID_SETTINGS_ENABLED_TOOLTIP,
}

-------------------------------------------------------------------------------------------------------
-- Graphics
-------------------------------------------------------------------------------------------------------

VideoData["Graphics_ViewDistanceSlider"]={
	name = FARCLIP;
	tooltip = OPTION_TOOLTIP_FARCLIP,
	graphicsCVar = "graphicsViewDistance",
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_ViewDistanceSlider"]={
	name = FARCLIP;
	tooltip = OPTION_TOOLTIP_FARCLIP,
	graphicsCVar = "raidGraphicsViewDistance",
	dependent = {
		"RaidGraphics_Quality",
	},
}
-------------------------------------------------------------------------------------------------------
VideoData["Graphics_GroundClutterSlider"]={
	name= GROUND_CLUTTER;
	tooltip = OPTION_TOOLTIP_GROUND_CLUTTER,
	graphicsCVar = "graphicsGroundClutter",
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_GroundClutterSlider"]={
	name= GROUND_CLUTTER;
	tooltip = OPTION_TOOLTIP_GROUND_CLUTTER,
	graphicsCVar = "raidGraphicsGroundClutter",
	dependent = {
		"RaidGraphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_EnvironmentalDetailSlider"]={
	name = ENVIRONMENT_DETAIL;
	tooltip = OPTION_TOOLTIP_ENVIRONMENT_DETAIL,
	graphicsCVar = "graphicsEnvironmentDetail",
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_EnvironmentalDetailSlider"]={
	name = ENVIRONMENT_DETAIL;
	tooltip = OPTION_TOOLTIP_ENVIRONMENT_DETAIL,
	graphicsCVar = "raidGraphicsEnvironmentDetail",
	dependent = {
		"RaidGraphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_ParticleDensityDropDown"]={
	name = PARTICLE_DENSITY;
	description = OPTION_TOOLTIP_PARTICLE_DENSITY,
	graphicsCVar =	"graphicsParticleDensity",
	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
			warning = VIDEO_OPTIONS_COMBAT_CUES_DISABLED_WARNING,
			skipForSlider = true;
		},
		[2] = {
			text = VIDEO_OPTIONS_LOW,
		},
		[3] = {
			text = VIDEO_OPTIONS_FAIR,
		},
		[4] = {
			text = VIDEO_OPTIONS_MEDIUM,
		},
		[5] = {
			text = VIDEO_OPTIONS_HIGH,
		},
		[6] = {
			text = VIDEO_OPTIONS_ULTRA,
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_ParticleDensityDropDown"]={
	name = PARTICLE_DENSITY;
	description = OPTION_TOOLTIP_PARTICLE_DENSITY,
	graphicsCVar =	"raidGraphicsParticleDensity",
	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
		},
		[4] = {
			text = VIDEO_OPTIONS_HIGH,
		},
		[5] = {
			text = VIDEO_OPTIONS_ULTRA,
		},
	},
	dependent = {
		"RaidGraphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_SSAODropDown"]={
	name = SSAO_LABEL;
	description = OPTION_TOOLTIP_SSAO,
	graphicsCVar =	"graphicsSSAO",
	data = {
		{
			text = VIDEO_OPTIONS_DISABLED,
		},
		{
			text = VIDEO_OPTIONS_LOW,
		},
		{
			text = VIDEO_OPTIONS_MEDIUM,
		},
		{
			text = VIDEO_OPTIONS_HIGH,
		},
		{
			text = VIDEO_OPTIONS_ULTRA,
		},
	},

	dependent = {
		"Graphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["RaidGraphics_SSAODropDown"]={
	name = SSAO_LABEL;
	description = OPTION_TOOLTIP_SSAO,
	graphicsCVar =	"raidGraphicsSSAO",
	data = {
		{
			text = VIDEO_OPTIONS_DISABLED,
		},
		{
			text = VIDEO_OPTIONS_LOW,
		},
		{
			text = VIDEO_OPTIONS_MEDIUM,
		},
		{
			text = VIDEO_OPTIONS_HIGH,
		},
		{
			text = VIDEO_OPTIONS_ULTRA,
		},
	},

	dependent = {
		"RaidGraphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_ShadowsDropDown"]={
	name = SHADOW_QUALITY;
	description = OPTION_TOOLTIP_SHADOW_QUALITY,
	graphicsCVar =	"graphicsShadowQuality",
	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_LOW;
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_FAIR;
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_MEDIUM;
		},
		[4] = {
			text = VIDEO_OPTIONS_HIGH,
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_HIGH;
		},
		[5] = {
			text = VIDEO_OPTIONS_ULTRA,
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_ULTRA;
		},
		[6] = {
			text = VIDEO_OPTIONS_ULTRA_HIGH,
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_ULTRA_HIGH;
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_ShadowsDropDown"]={
	name = SHADOW_QUALITY;
	description = OPTION_TOOLTIP_SHADOW_QUALITY,
	graphicsCVar =	"raidGraphicsShadowQuality",
	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_LOW;
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_FAIR;
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_MEDIUM;
		},
		[4] = {
			text = VIDEO_OPTIONS_HIGH,
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_HIGH;
		},
		[5] = {
			text = VIDEO_OPTIONS_ULTRA,
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_ULTRA;
		},
		[6] = {
			text = VIDEO_OPTIONS_ULTRA_HIGH,
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_ULTRA_HIGH;
		},
	},
	dependent = {
		"RaidGraphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_TextureResolutionDropDown"]={
	name = TEXTURE_DETAIL;
	description = OPTION_TOOLTIP_TEXTURE_DETAIL,
	graphicsCVar =	"graphicsTextureResolution",
	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			tooltip = VIDEO_OPTIONS_TEXTURE_DETAIL_LOW,
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			tooltip = VIDEO_OPTIONS_TEXTURE_DETAIL_FAIR,
		},
		[3] = {
			text = VIDEO_OPTIONS_HIGH,
			tooltip = VIDEO_OPTIONS_TEXTURE_DETAIL_HIGH,
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_TextureResolutionDropDown"]={
	name = TEXTURE_DETAIL;
	description = OPTION_TOOLTIP_TEXTURE_DETAIL,
	graphicsCVar =	"raidGraphicsTextureResolution",
	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			tooltip = VIDEO_OPTIONS_TEXTURE_DETAIL_LOW,
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			tooltip = VIDEO_OPTIONS_TEXTURE_DETAIL_FAIR,
		},
		[3] = {
			text = VIDEO_OPTIONS_HIGH,
			tooltip = VIDEO_OPTIONS_TEXTURE_DETAIL_HIGH,
		},
	},
	dependent = {
		"RaidGraphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_ProjectedTexturesDropDown"]={
	name = PROJECTED_TEXTURES;
	description = OPTION_TOOLTIP_PROJECTED_TEXTURES,
	graphicsCVar =	"graphicsProjectedTextures",
	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
			warning = VIDEO_OPTIONS_COMBAT_CUES_DISABLED_WARNING,
		},
		[2] = {
			text = VIDEO_OPTIONS_ENABLED,
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_ProjectedTexturesDropDown"]={
	name = PROJECTED_TEXTURES;
	description = OPTION_TOOLTIP_PROJECTED_TEXTURES,
	graphicsCVar =	"raidGraphicsProjectedTextures",
	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
		},
		[2] = {
			text = VIDEO_OPTIONS_ENABLED,
		},
	},
	dependent = {
		"RaidGraphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_SpellDensityDropDown"]={
	name = SPELL_DENSITY;
	description = OPTION_TOOLTIP_SPELL_DENSITY,
	graphicsCVar =	"graphicsSpellDensity",
	data = {
		[1] = {
			text = VIDEO_OPTIONS_ONLY_ESSENTIAL,
			tooltip = VIDEO_OPTIONS_SPELL_DENSITY_ONLY_ESSENTIAL,
		},
		[2] = {
			text = VIDEO_OPTIONS_SOME,
			tooltip = VIDEO_OPTIONS_SPELL_DENSITY_SOME,
		},
		[3] = {
			text = VIDEO_OPTIONS_HALF,
			tooltip = VIDEO_OPTIONS_SPELL_DENSITY_HALF,
		},
		[4] = {
			text = VIDEO_OPTIONS_MOST,
			tooltip = VIDEO_OPTIONS_SPELL_DENSITY_MOST,
		},
		[5] = {
			text = VIDEO_OPTIONS_DYNAMIC,
			tooltip = VIDEO_OPTIONS_SPELL_DENSITY_DYNAMIC,
		},
		[6] = {
			text = VIDEO_OPTIONS_EVERYTHING,
			tooltip = VIDEO_OPTIONS_SPELL_DENSITY_EVERYTHING,
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_SpellDensityDropDown"]={
	name = SPELL_DENSITY;
	description = OPTION_TOOLTIP_SPELL_DENSITY,
	graphicsCVar =	"raidGraphicsSpellDensity",
	data = {
		[1] = {
			text = VIDEO_OPTIONS_ONLY_ESSENTIAL,
			tooltip = VIDEO_OPTIONS_SPELL_DENSITY_ONLY_ESSENTIAL,
		},
		[2] = {
			text = VIDEO_OPTIONS_SOME,
			tooltip = VIDEO_OPTIONS_SPELL_DENSITY_SOME,
		},
		[3] = {
			text = VIDEO_OPTIONS_HALF,
			tooltip = VIDEO_OPTIONS_SPELL_DENSITY_HALF,
		},
		[4] = {
			text = VIDEO_OPTIONS_MOST,
			tooltip = VIDEO_OPTIONS_SPELL_DENSITY_MOST,
		},
		[5] = {
			text = VIDEO_OPTIONS_DYNAMIC,
			tooltip = VIDEO_OPTIONS_SPELL_DENSITY_DYNAMIC,
		},
		[6] = {
			text = VIDEO_OPTIONS_EVERYTHING,
			tooltip = VIDEO_OPTIONS_SPELL_DENSITY_EVERYTHING,
		},
	},
	dependent = {
		"RaidGraphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_LiquidDetailDropDown"]={
	name = LIQUID_DETAIL;
	description = OPTION_TOOLTIP_LIQUID_DETAIL,
	graphicsCVar = "graphicsLiquidDetail",
	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			tooltip = VIDEO_OPTIONS_LIQUID_DETAIL_LOW,
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			tooltip = VIDEO_OPTIONS_LIQUID_DETAIL_FAIR,
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			tooltip = VIDEO_OPTIONS_LIQUID_DETAIL_MEDIUM,
		},
		[4] = {
			text = VIDEO_OPTIONS_ULTRA,
			tooltip = VIDEO_OPTIONS_LIQUID_DETAIL_ULTRA,
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_LiquidDetailDropDown"]={
	name = LIQUID_DETAIL;
	description = OPTION_TOOLTIP_LIQUID_DETAIL,
	graphicsCVar = "raidGraphicsLiquidDetail",
	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			tooltip = VIDEO_OPTIONS_LIQUID_DETAIL_LOW,
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			tooltip = VIDEO_OPTIONS_LIQUID_DETAIL_FAIR,
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			tooltip = VIDEO_OPTIONS_LIQUID_DETAIL_MEDIUM,
		},
		[4] = {
			text = VIDEO_OPTIONS_ULTRA,
			tooltip = VIDEO_OPTIONS_LIQUID_DETAIL_ULTRA,
		},
	},
	dependent = {
		"RaidGraphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_DepthEffectsDropDown"]={
	name = DEPTH_EFFECTS;
	description = OPTION_TOOLTIP_DEPTH_EFFECTS,
	graphicsCVar =	"graphicsDepthEffects",
	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
			tooltip = VIDEO_OPTIONS_DEPTH_EFFECTS_DISABLED,
		},
		[2] = {
			text = VIDEO_OPTIONS_LOW,
			tooltip = VIDEO_OPTIONS_DEPTH_EFFECTS_LOW,
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			tooltip = VIDEO_OPTIONS_DEPTH_EFFECTS_MEDIUM,
		},
		[4] = {
			text = VIDEO_OPTIONS_HIGH,
			tooltip = VIDEO_OPTIONS_DEPTH_EFFECTS_HIGH,
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_DepthEffectsDropDown"]={
	name = DEPTH_EFFECTS;
	description = OPTION_TOOLTIP_DEPTH_EFFECTS,
	graphicsCVar =	"raidGraphicsDepthEffects",
	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
			tooltip = VIDEO_OPTIONS_DEPTH_EFFECTS_DISABLED,
		},
		[2] = {
			text = VIDEO_OPTIONS_LOW,
			tooltip = VIDEO_OPTIONS_DEPTH_EFFECTS_LOW,
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			tooltip = VIDEO_OPTIONS_DEPTH_EFFECTS_MEDIUM,
		},
		[4] = {
			text = VIDEO_OPTIONS_HIGH,
			tooltip = VIDEO_OPTIONS_DEPTH_EFFECTS_HIGH,
		},
	},
	dependent = {
		"RaidGraphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_ComputeEffectsDropDown"]={
	name = COMPUTE_EFFECTS;
	description = OPTION_TOOLTIP_COMPUTE_EFFECTS,
	graphicsCVar =	"graphicsComputeEffects",
	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
			tooltip = VIDEO_OPTIONS_COMPUTE_EFFECTS_DISABLED,
		},
		[2] = {
			text = VIDEO_OPTIONS_LOW,
			tooltip = VIDEO_OPTIONS_COMPUTE_EFFECTS_LOW,
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			tooltip = VIDEO_OPTIONS_COMPUTE_EFFECTS_MEDIUM,
		},
		[4] = {
			text = VIDEO_OPTIONS_HIGH,
			tooltip = VIDEO_OPTIONS_COMPUTE_EFFECTS_HIGH,
		},
		[5] = {
			text = VIDEO_OPTIONS_ULTRA,
			tooltip = VIDEO_OPTIONS_COMPUTE_EFFECTS_ULTRA,
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_ComputeEffectsDropDown"]={
	name = COMPUTE_EFFECTS;
	description = OPTION_TOOLTIP_COMPUTE_EFFECTS,
	graphicsCVar =	"raidGraphicsComputeEffects",
	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
			tooltip = VIDEO_OPTIONS_COMPUTE_EFFECTS_DISABLED,
		},
		[2] = {
			text = VIDEO_OPTIONS_LOW,
			tooltip = VIDEO_OPTIONS_COMPUTE_EFFECTS_LOW,
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			tooltip = VIDEO_OPTIONS_COMPUTE_EFFECTS_MEDIUM,
		},
		[4] = {
			text = VIDEO_OPTIONS_HIGH,
			tooltip = VIDEO_OPTIONS_COMPUTE_EFFECTS_HIGH,
		},
		[5] = {
			text = VIDEO_OPTIONS_ULTRA,
			tooltip = VIDEO_OPTIONS_COMPUTE_EFFECTS_ULTRA,
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_OutlineModeDropDown"]={
	name = OUTLINE_MODE;
	description = OPTION_TOOLTIP_OUTLINE_MODE,
	graphicsCVar = "graphicsOutlineMode",
	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
		},
		[2] = {
			text = VIDEO_OPTIONS_MEDIUM,
		},
		[3] = {
			text = VIDEO_OPTIONS_HIGH,
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["RaidGraphics_OutlineModeDropDown"]={
	name = OUTLINE_MODE;
	description = OPTION_TOOLTIP_OUTLINE_MODE,
	graphicsCVar = "raidGraphicsOutlineMode",
	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
		},
		[2] = {
			text = VIDEO_OPTIONS_MEDIUM,
		},
		[3] = {
			text = VIDEO_OPTIONS_HIGH,
		},
	},
	dependent = {
		"RaidGraphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
-- Advanced
-------------------------------------------------------------------------------------------------------

VideoData["Advanced_BufferingDropDown"]={
	name = TRIPLE_BUFFER;
	description = OPTION_TOOLTIP_TRIPLE_BUFFER,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
			cvars =	{
				gxMaxFrameLatency = 2,
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_ENABLED,
			cvars =	{
				gxMaxFrameLatency = 3,
			},
		},
	},
	restart = true;
}

-------------------------------------------------------------------------------------------------------
VideoData["Advanced_FilteringDropDown"]={
	name = ANISOTROPIC;
	description = OPTION_TOOLTIP_ANISOTROPIC,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_BILINEAR,
			cvars =	{
				textureFilteringMode = 0,
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_TRILINEAR,
			cvars =	{
				textureFilteringMode = 1,
			},
		},
		[3] = {
			text = VIDEO_OPTIONS_2XANISOTROPIC,
			cvars =	{
				textureFilteringMode = 2,
			},
		},
		[4] = {
			text = VIDEO_OPTIONS_4XANISOTROPIC,
			cvars =	{
				textureFilteringMode = 3,
			},
		},
		[5] = {
			text = VIDEO_OPTIONS_8XANISOTROPIC,
			cvars =	{
				textureFilteringMode = 4,
			},
		},
		[6] = {
			text = VIDEO_OPTIONS_16XANISOTROPIC,
			cvars =	{
				textureFilteringMode = 5,
			},
		},
	},
}

VideoData["Advanced_MultisampleAntiAliasingDropDown"]={
	name = MULTISAMPLE_ANTIALIASING;
	description = OPTION_TOOLTIP_ADVANCED_MSAA,
	onload =
		function(self)
			self.data = {
				{
					text = VIDEO_OPTIONS_NONE,
					cvars =	{
						MSAAQuality = 0,
					},
				},
			};

			GenerateMSAAData(self.data, true, MultiSampleAntiAliasingSupported());
		end,
}

VideoData["Advanced_PostProcessAntiAliasingDropDown"]={
	name = POSTPROCESS_ANTI_ALIASING;
	description = OPTION_TOOLTIP_ADVANCED_PPAA,
	onload =
		function(self)
			self.data = {
				{
					text = VIDEO_OPTIONS_NONE,
					cvars =	{
						ffxAntiAliasingMode = 0,
					},
				}
			};

			GenerateFFXAntiAliasingData(self.data, true);
		end,
}

VideoData["Advanced_ResampleQualityDropDown"]={
	name = RESAMPLE_QUALITY;
	description = OPTION_TOOLTIP_RESAMPLE_QUALITY,

	data = {
		{
			text = VIDEO_OPTIONS_NONE,
			cvars =    {
				resampleQuality = 0,
			},
		},
		{
			text = RESAMPLE_QUALITY_BILINEAR,
			cvars =	{
				resampleQuality = 1,
			},
		},
		{
			text = RESAMPLE_QUALITY_BICUBIC,
			cvars =	{
				resampleQuality = 2,
			},
		},
	},
}

VideoData["Advanced_RTShadowQualityDropDown"]={
	name = RT_SHADOW_QUALITY;
	description = OPTION_TOOLTIP_RT_SHADOW_QUALITY,
	validateOnGXRestart = true,

	data = {
		{
			text = VIDEO_OPTIONS_DISABLED,
			cvars =    {
				shadowrt = 0,
				
			},
		},
		{
			text = VIDEO_OPTIONS_FAIR,
			tooltip = VIDEO_OPTIONS_RT_SHADOW_QUALITY_FAIR,
			cvars =	{
				shadowrt = 1,
			},
		},
		{
			text = VIDEO_OPTIONS_MEDIUM,
			tooltip = VIDEO_OPTIONS_RT_SHADOW_QUALITY_MEDIUM,
			cvars =	{
				shadowrt = 2,
			},
		},
		{
			text = VIDEO_OPTIONS_HIGH,
			tooltip = VIDEO_OPTIONS_RT_SHADOW_QUALITY_HIGH,
			cvars =	{
				shadowrt = 3,
			},
		},
	},
}

VideoData["Advanced_SSAOTypeDropDown"]={
	name = SSAO_TYPE_LABEL;
	validateOnGXRestart = true,

	data = {
		{
			text = GX_ADAPTER_AUTO_DETECT,
			cvars =    {
				ResolvedSSAOType = 0,
			},
		},
		{
			text = SSAO_TYPE_ASSAO,
			cvars =    {
				ResolvedSSAOType = 1,
			},
		},
		{
			text = SSAO_TYPE_CACAO,
			cvars =	{
				ResolvedSSAOType = 2,
			},
		},
	},
}

VideoData["Advanced_MaxFPSSlider"]={
	name = MAXFPS;
	tooltip = OPTION_MAXFPS,
	initialize =
		function(self)
			local value = self:GetCurrentValue();
			if(value == 0) then
				_G["Advanced_MaxFPSCheckBox"]:SetChecked(false);
				VideoOptions_Disable(self);
			else
				_G["Advanced_MaxFPSCheckBox"]:SetChecked(true);
				VideoOptions_Enable(self);
			end
		end,
}
VideoData["Advanced_MaxFPSBKSlider"]={
	name = MAXFPSBK;
	tooltip = OPTION_MAXFPSBK,
	initialize =
		function(self)
			local value = self:GetCurrentValue();
			if(value == 0) then
				_G["Advanced_MaxFPSBKCheckBox"]:SetChecked(false);
				VideoOptions_Disable(self);
			else
				_G["Advanced_MaxFPSBKCheckBox"]:SetChecked(true);
				VideoOptions_Enable(self);
			end
		end,
}
VideoData["Advanced_TargetFPSSlider"]={
	name = TARGETFPS;
	tooltip = OPTION_TARGETFPS,
	initialize =
		function(self)
			local value = self:GetCurrentValue();
			if(value == 0) then
				_G["Advanced_TargetFPSCheckBox"]:SetChecked(false);
				VideoOptions_Disable(self);
			else
				_G["Advanced_TargetFPSCheckBox"]:SetChecked(true);
				VideoOptions_Enable(self);
			end
		end,
}

VideoData["Advanced_ContrastSlider"]={
	name = OPTION_CONTRAST;
	tooltip = OPTION_TOOLTIP_CONTRAST,
}

VideoData["Advanced_BrightnessSlider"]={
	name = OPTIONS_BRIGHTNESS;
	tooltip = OPTION_TOOLTIP_BRIGHTNESS,
}

VideoData["Advanced_GammaSlider"]={
	name = GAMMA;
	tooltip = OPTION_TOOLTIP_GAMMA,
}

VideoData["Advanced_MaxFPSCheckBox"]={
	name = MAXFPS_CHECK;
	tooltip = OPTION_MAXFPS_CHECK,
}
VideoData["Advanced_MaxFPSBKCheckBox"]={
	name = MAXFPSBK_CHECK;
	tooltip = OPTION_MAXFPSBK_CHECK,
}
VideoData["Advanced_TargetFPSCheckBox"]={
	name = TARGETFPS_CHECK;
	tooltip = OPTION_TARGETFPS_CHECK,
}
VideoData["Advanced_AdapterDropDown"]={
	name = GRAPHICS_CARD,
	description = OPTION_TOOLTIP_GRAPHICS_CARD,
	validateOnAdapterListChange = true,
	rebuildTableOnValidate = true,
	tablefunction =
		function(self)
			self.adapters = C_VideoOptions.GetGxAdapterInfo();
			local adapterNames = {};
			for idx, val in ipairs(self.adapters) do
				if ( val.isExternal ) then
					adapterNames[idx] = string.format(GX_ADAPTER_EXTERNAL, val.name);
				elseif ( val.isLowPower ) then
					adapterNames[idx] = string.format(GX_ADAPTER_LOW_POWER, val.name);
				else
					adapterNames[idx] = val.name;
				end
			end
			return GX_ADAPTER_AUTO_DETECT, unpack(adapterNames);
		end,
	SetValue =
		function (self, value)
			if ( value == 1 ) then
				SetCVar("gxAdapter", "");
			else
				SetCVar("gxAdapter", self.adapters[value - 1].name);
			end
		end,
	doGetValue =
		function(self)
			local adapter = GetCVar("gxAdapter");
			if ( adapter == "" ) then
				return 1;
			end
			for i = 1, #self.adapters do
				if (string.lower(self.adapters[i].name) == string.lower(adapter)) then
					return i + 1;
				end
			end
		end,
	restart = true,
}

VideoData["Advanced_MultisampleAlphaTest"]={
	name = MULTISAMPLE_ALPHA_TEST,
	description = OPTION_TOOLTIP_MULTISAMPLE_ALPHA_TEST,

	data = {
		{
			text = VIDEO_OPTIONS_DISABLED,
			cvars =	{
				msaaAlphaTest = 0,
			},
		},
		{
			text = VIDEO_OPTIONS_ENABLED,
			cvars =	{
				msaaAlphaTest = 1,
			},
		},
	},
}

VideoData["Display_RenderScaleSlider"]={
	name = RENDER_SCALE,
	tooltip = OPTION_TOOLTIP_RENDER_SCALE,
	graphicsCVar = "RenderScale",
	dependtarget = Graphics_ControlRefreshValue,
	preventValueChangeHandlerFromSettingLabel = true,

	SetDisplayValue = function(self,value)
		self.noclick = true;
		self:sliderSetValue(value);
		self:updatecustomfield(value);
		self.noclick = false;
	end,

	SetCVarValue = function(self, value)
		BlizzardOptionsPanel_SetCVarSafe(self.graphicsCVar, value);
	end,

	initialize = function(self)
		self:SetDisplayValue(tonumber(BlizzardOptionsPanel_GetCVarSafe(self.graphicsCVar)));
	end,

	onload = function(self)
		self:SetMinMaxValues(GetMinRenderScale(), GetMaxRenderScale());
		self:RegisterEvent("DISPLAY_SIZE_CHANGED");

		self.Text:SetFontObject("OptionsFontSmall");
		self.Text:ClearAllPoints();
		self.Text:SetPoint("RIGHT", self, "LEFT", -20, 0);
		self.Text:SetText(RENDER_SCALE);

		-- Alias Low and High fontStrings to be Value and Resolution respectively.
		self.Value = self.Low;
		self.Value:ClearAllPoints();
		self.Value:SetPoint("LEFT", self, "RIGHT", 3, 2);

		self.Resolution = self.High;
		self.Resolution:ClearAllPoints();
		self.Resolution:SetPoint("TOP", self, "BOTTOM", 0, 0);

		self.sliderSetValue = self.SetValue;
		self.SetValue = self.SetCVarValue;
	end,

	updatecustomfield = function(self, value)
		local renderScale = value;
		local roundToNearestInteger = true;
		self.Value:SetText(FormatPercentage(renderScale, roundToNearestInteger));
		local width, height = GetPhysicalScreenSize();
		self.Resolution:SetText(math.floor(width * renderScale).."x"..math.floor(height * renderScale));
	end,

	onvaluechanged = function(self, value)
		self:updatecustomfield(value);
	end,
}

-------------------------------------------------------------------------------------------------------
VideoData["Advanced_GraphicsAPIDropDown"]={
	name = GXAPI;
	description = OPTION_TOOLTIP_GXAPI;

	tablefunction =
		function(self)
			self.cvarValues = { GetGraphicsAPIs() };	-- this is a table of the cvar values, ie "d3d11", "metal", etc
			local temp = { };
			for i = 1, #self.cvarValues do
				tinsert(temp, _G["GXAPI_"..strupper(self.cvarValues[i])]);
			end
			return unpack(temp);
		end,
	SetValue =
		function (self, value)
			SetCVar("gxapi", self.cvarValues[value]);
		end,
	doGetValue =
		function(self)
			local api = GetCVar("gxapi");
			for i = 1, #self.cvarValues do
				if (string.lower(self.cvarValues[i]) == string.lower(api)) then
					return i;
				end
			end
		end,
	lookup = Graphics_TableLookupSafe,
	restart = true,
}

VideoData["Advanced_PhysicsInteractionDropDown"]={
	name = PHYSICS_INTERACTION;
	description = OPTION_PHYSICS_OPTIONS;

	data = {
		{
			text = NO_ENVIRONMENT_INTERACTION,
			cvars =	{
				physicsLevel = 0,
			},
		},
		{
			text = PLAYER_ONLY_INTERACTION,
			cvars =	{
				physicsLevel = 1,
			},
		},
		{
			text = PLAYER_AND_NPC_INTERACTION,
			cvars = {
				physicsLevel = 2,
			},
		},
	},
	clientRestart = true,
	gameRestart = true,
}
