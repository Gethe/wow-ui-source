-------------------------------------------------------------------------------------------------------
-- Overall Quality
-------------------------------------------------------------------------------------------------------

VideoData["Graphics_QualityDropDown"]={
	name=OVERALL_QUALITY;
    data = {
		[1] = {
			text = TEXT_LOW,
			tooltip = VIDEO_QUALITY_SUBTEXT1,
			notify = {
				Graphics_ViewDistanceDropDown = TEXT_LOW,
				Graphics_BlendingDropDown = TEXT_LOW,
				Graphics_ParticleDensityDropDown = TEXT_LOW,
				Graphics_EnvironmentalDetailDropDown = TEXT_LOW,
				Graphics_GroundClutterRadiusDropDown = TEXT_LOW,
				Graphics_GroundClutterDensityDropDown = TEXT_LOW,
				Graphics_ShadowsDropDown = TEXT_LOW,
				Graphics_TextureResolutionDropDown = TEXT_LOW,
				Graphics_FilteringDropDown = TEXT_LOW,
				Graphics_WeatherIntensityDropDown = TEXT_LOW,
				Graphics_PlayerDropDown = TEXT_LOW,
				Graphics_LiquidDetailDropDown = TEXT_LOW,
				Graphics_SunshaftsDropDown = TEXT_DISABLED,
				Graphics_FullScreenGlowDropDown = TEXT_DISABLED,
				Graphics_ProjectedTexturesDropDown = TEXT_DISABLED,
			},
		},
        [2] = {
            text = TEXT_FAIR,
            tooltip = VIDEO_QUALITY_SUBTEXT2,
            notify = {
				Graphics_ViewDistanceDropDown = TEXT_FAIR,
				Graphics_BlendingDropDown = TEXT_LOW,
				Graphics_ParticleDensityDropDown = TEXT_FAIR,
				Graphics_EnvironmentalDetailDropDown = TEXT_FAIR,
				Graphics_GroundClutterRadiusDropDown = TEXT_FAIR,
				Graphics_GroundClutterDensityDropDown = TEXT_FAIR,
				Graphics_ShadowsDropDown = TEXT_FAIR,
				Graphics_TextureResolutionDropDown = TEXT_LOW,
				Graphics_FilteringDropDown = TEXT_FAIR,
				Graphics_WeatherIntensityDropDown = TEXT_MEDIUM,
				Graphics_PlayerDropDown = TEXT_LOW,
				Graphics_LiquidDetailDropDown = TEXT_LOW,
				Graphics_SunshaftsDropDown = TEXT_DISABLED,
				Graphics_FullScreenGlowDropDown = TEXT_ENABLED,
				Graphics_ProjectedTexturesDropDown = TEXT_DISABLED,
            },
        },
        [3] = {
            text = TEXT_MEDIUM,
            tooltip = VIDEO_QUALITY_SUBTEXT3,
            notify = {
				Graphics_ViewDistanceDropDown = TEXT_MEDIUM,
				Graphics_BlendingDropDown = TEXT_LOW,
				Graphics_ParticleDensityDropDown = TEXT_MEDIUM,
				Graphics_EnvironmentalDetailDropDown = TEXT_MEDIUM,
				Graphics_GroundClutterRadiusDropDown = TEXT_MEDIUM,
				Graphics_GroundClutterDensityDropDown = TEXT_MEDIUM,
				Graphics_ShadowsDropDown = TEXT_MEDIUM,
				Graphics_TextureResolutionDropDown = TEXT_HIGH,
				Graphics_FilteringDropDown = TEXT_MEDIUM,
				Graphics_WeatherIntensityDropDown = TEXT_MEDIUM,
				Graphics_PlayerDropDown = TEXT_HIGH,
				Graphics_LiquidDetailDropDown = TEXT_FAIR,
				Graphics_SunshaftsDropDown = TEXT_LOW,
				Graphics_FullScreenGlowDropDown = TEXT_ENABLED,
				Graphics_ProjectedTexturesDropDown = TEXT_DISABLED,
            },
        },
        [4] = {
            text = TEXT_HIGH,
            tooltip = VIDEO_QUALITY_SUBTEXT4,
            notify = {
				Graphics_ViewDistanceDropDown = TEXT_HIGH,
				Graphics_BlendingDropDown = TEXT_HIGH,
				Graphics_ParticleDensityDropDown = TEXT_HIGH,
				Graphics_EnvironmentalDetailDropDown = TEXT_HIGH,
				Graphics_GroundClutterRadiusDropDown = TEXT_HIGH,
				Graphics_GroundClutterDensityDropDown = TEXT_HIGH,
				Graphics_ShadowsDropDown = TEXT_HIGH,
				Graphics_TextureResolutionDropDown = TEXT_HIGH,
				Graphics_FilteringDropDown = TEXT_HIGH,
				Graphics_WeatherIntensityDropDown = TEXT_HIGH,
				Graphics_PlayerDropDown = TEXT_HIGH,
				Graphics_LiquidDetailDropDown = TEXT_MEDIUM,
				Graphics_SunshaftsDropDown = TEXT_HIGH,
				Graphics_FullScreenGlowDropDown = TEXT_ENABLED,
				Graphics_ProjectedTexturesDropDown = TEXT_DISABLED,
            },
        },
        [5] = {
            text = TEXT_ULTRA,
            tooltip = VIDEO_QUALITY_SUBTEXT5,
            notify = {
				Graphics_ViewDistanceDropDown = TEXT_ULTRA,
				Graphics_BlendingDropDown = TEXT_HIGH,
				Graphics_TextureResolutionDropDown = TEXT_HIGH,
				Graphics_ParticleDensityDropDown = TEXT_ULTRA,
				Graphics_EnvironmentalDetailDropDown = TEXT_ULTRA,
				Graphics_GroundClutterRadiusDropDown = TEXT_ULTRA,
				Graphics_GroundClutterDensityDropDown = TEXT_ULTRA,
				Graphics_ShadowsDropDown = TEXT_ULTRA,
				Graphics_TextureResolutionDropDown = TEXT_HIGH,
				Graphics_FilteringDropDown = TEXT_ULTRA,
				Graphics_WeatherIntensityDropDown = TEXT_ULTRA,
				Graphics_PlayerDropDown = TEXT_HIGH,
				Graphics_LiquidDetailDropDown = TEXT_ULTRA,
				Graphics_SunshaftsDropDown = TEXT_HIGH,
				Graphics_FullScreenGlowDropDown = TEXT_ENABLED,
				Graphics_ProjectedTexturesDropDown = TEXT_ENABLED,
            },
        },
    },
-- always calculated, never based on selectedID
	GetValue = 
		function(self)
			self.selectedID = nil;
			return Graphics_TableGetValue(self);
		end,
    description =  "Video Quality:",
	dependtarget = Graphics_TableRefreshValue,	-- recalculate based on the cvars
}

-------------------------------------------------------------------------------------------------------
-- Display
-------------------------------------------------------------------------------------------------------

VideoData["Graphics_DisplayModeDropDown"]={
	name=DISPLAY_MODE;
	description = "Allows you to change the primary display mode of the game to Fullscreen, Windowed, or Windowed (Fullscreen).  Windowed modes may cause a drop in performance.",
	
	data = {
		[1] = {
			text = "Windowed",
			cvars =	{
				gxWindow = 1,
				gxMaximize = 0,
			},
			windowed = true;
			fullscreen = false;
		},
		[2] = {
			text = "Windowed (Fullscreen)",
			cvars =	{
				gxWindow = 1,
				gxMaximize = 1,
			},
			windowed = true;
			fullscreen = true;
		},
		[3] = {
			text = "Fullscreen",
			cvars =	{
				gxWindow = 0,
				gxMaximize = 0,
			},
			windowed = false;
			fullscreen = true;
		},
	},
	dependent = {
		"Graphics_ResolutionDropDown",
		"Graphics_RefreshDropDown",
		"Graphics_GammaSlider",
		"Graphics_ResizeDropDown",
	},
	restart = true,
	windowedmode =
		function(self)
			return self.data[self.selectedID or self.value].windowed;
		end,
	fullscreenmode =
		function(self)
			return self.data[self.selectedID or self.value].fullscreen;
		end,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_PrimaryMonitorDropDown"]={
	name=PRIMARY_MONITOR;
	description = "Allows you to change the primary monitor used by the display.",
	
	table = {},
	tablefunction = 
		function(self)
			local count = GetMonitorCount();
			for i=1, count do
				self.table[i] = GetMonitorName(i);
			end
		end,
	SetValue = 
		function (self, value)
			BlizzardOptionsPanel_SetCVarSafe(self.cvar, value-1);
		end,
	GetValue = 
		function (self)
			return 1+BlizzardOptionsPanel_GetCVarSafe(self.cvar);
		end,
	cvar = "gxMonitor",
	dependent = {
		"Graphics_ResolutionDropDown",	--resolutions may disappear when we change the monitor
	},
	restart = true,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_ResolutionDropDown"]={
	name=RESOLUTION;
	description = "Higher resolution will result in increased clarity, but this greatly affects performance.  Choose a resolution that matches the aspect ratio of your monitor.",	
	
	tablefunction = 
		function(self)
			return GetScreenResolutions(Graphics_PrimaryMonitorDropDown:GetValue());
		end,
	readfilter =
		function(self, value)
			local xIndex = strfind(value, "x");
			local width = strsub(value, 1, xIndex-1);
			local height = strsub(value, xIndex+1, strlen(value));
			if ( width/height > 4/3 ) then
				value = value.." ".. WIDESCREEN_TAG;
			end
			return value;
		end,
	SetValue =
		function (self, value)
			SetScreenResolution(value);
		end,
	GetValue = 
		function(self)
			return self.selectedID or GetCurrentResolution();
		end,
	dependent = {
		"Graphics_RefreshDropDown"
	},
	restart = true,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_MultiSampleDropDown"]={
	name=MULTISAMPLE;
	description = OPTION_TOOLTIP_MULTISAMPLING;
	
	table = {},
	tablefunction = GetMultisampleFormats;
	tablenext = 3;
	readfilter =
		function(self, colorBits, depthBits, multiSample)
			return format(MULTISAMPLING_FORMAT_STRING, colorBits, depthBits, multiSample);
		end,
	SetValue = 
		function (self, value)
			SetMultisampleFormat(value);
		end,
	GetValue = GetCurrentMultisampleFormat;
	restart = true,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_RefreshDropDown"]={
	name=REFRESH_RATE;
	description = "Refers to the number of times the image is drawn to the monitor.  Some players may see a flicker if the refresh rate is too low.",
	
	cvar = "gxRefresh";
	-- code run for dependent target
	tablefunction = 
		function()
			-- get refresh rates for the currently selected resolution
			return GetRefreshRates(Graphics_ResolutionDropDown:GetValue(), Graphics_PrimaryMonitorDropDown:GetValue());
		end,
	readfilter =
		function(self, value)
			return value .. HERTZ;
		end,
	SetValue =
		function(self, value)
			local str = self.table[value];
			if(str ~= nil) then
				local val = string.match(self.table[value], "(%d+)");
				BlizzardOptionsPanel_SetCVarSafe(self.cvar, val);
			end
		end,
	GetValue = 
		function(self)
			return self:lookup(self.table[self.selectedID] or BlizzardOptionsPanel_GetCVarSafe(self.cvar) .. HERTZ);
		end,
	lookup = Graphics_TableLookupValidate,
	dependtarget = VideoOptionsDropDownMenu_dependtarget_refreshtable,
	onrefresh =
		function(self)
			if(Graphics_DisplayModeDropDown:windowedmode()) then
				VideoOptions_Disable(self);
			else
				VideoOptions_Enable(self);
			end
		end,
	restart = true,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_VerticalSyncDropDown"]={
	name=VERTICAL_SYNC;
	description = "Synchronizes your frame rate to some fraction of your monitor's refresh rate.",
	
	data = {
		[1] = {
			text = "Disabled",
			cvars =	{
				gxVSync = 0,
			},
		},
		[2] = {
			text = "Enabled",
			cvars =	{
				gxVSync = 1,
			},
		},
	},
	restart = true,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_GammaSlider"]={
	name=GAMMA;
	description = OPTION_TOOLTIP_GAMMA,
	type = CONTROLTYPE_SLIDER,
	onrefresh =
		function(self)
			if(Graphics_DisplayModeDropDown:windowedmode()) then
				VideoOptions_Disable(self);
			else
				VideoOptions_Enable(self);
			end
		end,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_ResizeDropDown"]={
	name=RESIZE_WINDOW;
	description = "Determines whether you can resize the window.",
	
	data = {
		[1] = {
			text = TEXT_ENABLED,
			cvars =	{
				windowResizeLock = 0,
			},
		},
		[2] = {
			text = TEXT_DISABLED,
			cvars =	{
				windowResizeLock = 1,
			},
		},
	},
	restart = true,
	onload =
		function(self)
			if(IsMacClient()) then
				self:Hide();
			end
		end,
	onrefresh =
		function(self)
			if(Graphics_DisplayModeDropDown:windowedmode()) then
				VideoOptions_Enable(self);
			else
				VideoOptions_Disable(self);
			end
		end,
}

-------------------------------------------------------------------------------------------------------
-- Graphics
-------------------------------------------------------------------------------------------------------

VideoData["Graphics_ViewDistanceDropDown"]={
	name=FARCLIP;
	description = "These are the view distances:",

	data = {
		[1] = {
			text = TEXT_LOW,
			cvars =	{
				farClip = 177,
			},
		},
		[2] = {
			text = TEXT_FAIR,
			cvars =	{
				farClip = 507,
			},
		},
		[3] = {
			text = TEXT_MEDIUM,
			cvars =	{
				farClip = 727,
			},
		},
		[4] = {
			text = TEXT_HIGH,
			cvars =	{
				farClip = 1057,
			},
		},
		[5] = {
			text = TEXT_ULTRA,
			cvars =	{
				farClip = 1250,
			},
		},
	},
	dependent = {
		"Graphics_QualityDropDown",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_GroundClutterRadiusDropDown"]={
	name=GROUND_RADIUS;
	description = OPTION_TOOLTIP_GROUND_RADIUS,

	data = {
		[1] = {
			text = TEXT_LOW,
			cvars =	{
				groundEffectDist = 70,
			},
		},
		[2] = {
			text = TEXT_FAIR,
			cvars =	{
				groundEffectDist = 110,
			},
		},
		[3] = {
			text = TEXT_MEDIUM,
			cvars =	{
				groundEffectDist = 160,
			},
		},
		[4] = {
			text = TEXT_HIGH,
			cvars =	{
				groundEffectDist = 220,
			},
		},
		[5] = {
			text = TEXT_ULTRA,
			cvars =	{
				groundEffectDist = 300,
			},
		},
	},
	dependent = {
		"Graphics_QualityDropDown",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_GroundClutterDensityDropDown"]={
	name=GROUND_DENSITY;
	description = OPTION_TOOLTIP_GROUND_DENSITY,

	data = {
		[1] = {
			text = TEXT_LOW,
			cvars =	{
				groundEffectDensity = 16,
			},
		},
		[2] = {
			text = TEXT_FAIR,
			cvars =	{
				groundEffectDensity = 40,
			},
		},
		[3] = {
			text = TEXT_MEDIUM,
			cvars =	{
				groundEffectDensity = 64,
			},
		},
		[4] = {
			text = TEXT_HIGH,
			cvars =	{
				groundEffectDensity = 96,
			},
		},
		[5] = {
			text = TEXT_ULTRA,
			cvars =	{
				groundEffectDensity = 128,
			},
		},
	},
	dependent = {
		"Graphics_QualityDropDown",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_EnvironmentalDetailDropDown"]={
	name=ENVIRONMENT_DETAIL;
	description = OPTION_TOOLTIP_ENVIRONMENT_DETAIL,

	data = {
		[1] = {
			text = TEXT_LOW,
			cvars =	{
				environmentDetail = 50,
			},
		},
		[2] = {
			text = TEXT_FAIR,
			cvars =	{
				environmentDetail = 75,
			},
		},
		[3] = {
			text = TEXT_MEDIUM,
			cvars =	{
				environmentDetail = 100,
			},
		},
		[4] = {
			text = TEXT_HIGH,
			cvars =	{
				environmentDetail = 125,
			},
		},
		[5] = {
			text = TEXT_ULTRA,
			cvars =	{
				environmentDetail = 150,
			},
		},
	},
	dependent = {
		"Graphics_QualityDropDown",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_ParticleDensityDropDown"]={
	name=PARTICLE_DENSITY;
	description =  OPTION_TOOLTIP_PARTICLE_DENSITY,

	data = {
		[1] = {
			text = TEXT_LOW,
			cvars =	{
				particleDensity = 10,
			},
		},
		[2] = {
			text = TEXT_FAIR,
			cvars =	{
				particleDensity = 40,
			},
		},
		[3] = {
			text = TEXT_MEDIUM,
			cvars =	{
				particleDensity = 60,
			},
		},
		[4] = {
			text = TEXT_HIGH,
			cvars =	{
				particleDensity = 80,
			},
		},
		[5] = {
			text = TEXT_ULTRA,
			cvars =	{
				particleDensity = 100,
			},
		},
	},
	dependent = {
		"Graphics_QualityDropDown",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_FullScreenGlowDropDown"]={
	name=FULL_SCREEN_GLOW;
	description = OPTION_TOOLTIP_FULL_SCREEN_GLOW,

	data = {
		[1] = {
			text = TEXT_DISABLED,
			cvars =	{
				ffxGlow = 0,
			},
		},
		[2] = {
			text = TEXT_ENABLED,
			cvars =	{
				ffxGlow = 1,
			},
		},
	},
	dependent = {
		"Graphics_QualityDropDown",
	},
}
-------------------------------------------------------------------------------------------------------
VideoData["Graphics_ShadowsDropDown"]={
	name=SHADOW_QUALITY;
	description = OPTION_TOOLTIP_CHARACTER_SHADOWS,

	data = {
		[1] = {
			text = TEXT_LOW,
			cvars =	{
				shadowMode = 0,
				shadowTextureSize = 1024,	-- TODO, this shouldn't be needed here.
			},
			tooltip = "Low-resolution terrain shadows, blob shadows for units.";
		},
		[2] = {
			text = TEXT_FAIR,
			cvars =	{
				shadowMode = 1,
				shadowTextureSize = 1024,
			},
			tooltip = "Low-resolution terrain shadows, low-resolution dynamic shadows near player.";
		},
		[3] = {
			text = TEXT_MEDIUM,
			cvars =	{
				shadowMode = 1,
				shadowTextureSize = 2048,
			},
			tooltip = "Low-resolution terrain shadows, high-resolution dynamic shadows near player.";
		},
		[4] = {
			text = TEXT_HIGH,
			cvars =	{
				shadowMode = 2,
				shadowTextureSize = 2048,
			},
			tooltip = "High-resolution environment shadows, high-resolution dynamic shadows near player.";
		},
		[5] = {
			text = TEXT_ULTRA,
			cvars =	{
				shadowMode = 3,
				shadowTextureSize = 2048,
			},
			tooltip = "High-resolution shadows for the entire scene.";
		},
	},
	dependent = {
		"Graphics_QualityDropDown",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_WeatherIntensityDropDown"]={
	name=WEATHER_DETAIL;
	description = OPTION_TOOLTIP_WEATHER_DETAIL,

	data = {
		[1] = {
			text = TEXT_LOW,
			cvars =	{
				weatherDensity = 0,
			},
		},
		[2] = {
			text = TEXT_MEDIUM,
			cvars =	{
				weatherDensity = 1,
			},
		},
		[3] = {
			text = TEXT_HIGH,
			cvars =	{
				weatherDensity = 2,
			},
		},
		[4] = {
			text = TEXT_ULTRA,
			cvars =	{
				weatherDensity = 3,
			},
		},
	},
	dependent = {
		"Graphics_QualityDropDown",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_TextureResolutionDropDown"]={
	name=TEXTURE_DETAIL;
	description = OPTION_TOOLTIP_TEXTURE_DETAIL,

	data = {
		[1] = {
			text = TEXT_LOW,
			cvars =	{
				baseMip = 1,
			},
		},
		[2] = {
			text = TEXT_HIGH,
			cvars =	{
				baseMip = 0,
			},
		},
	},
	dependent = {
		"Graphics_QualityDropDown",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_ProjectedTexturesDropDown"]={
	name=PROJECTED_TEXTURES;
	description = OPTION_TOOLTIP_PROJECTED_TEXTURES,

	data = {
		[1] = {
			text = TEXT_DISABLED,
			cvars =	{
				projectedTextures = 0,
			},
		},
		[2] = {
			text = TEXT_ENABLED,
			cvars =	{
				projectedTextures = 1,
			},
		},
	},
	dependent = {
		"Graphics_QualityDropDown",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_FilteringDropDown"]={
	name=ANISOTROPIC;
	description = OPTION_TOOLTIP_TRILINEAR,

	data = {
		[1] = {
			text = TEXT_LOW,
			cvars =	{
				textureFilteringMode = 0,
			},
		},
		[2] = {
			text = TEXT_FAIR,
			cvars =	{
				textureFilteringMode = 1,
			},
		},
		[3] = {
			text = TEXT_MEDIUM,
			cvars =	{
				textureFilteringMode = 2,
			},
		},
		[4] = {
			text = TEXT_HIGH,
			cvars =	{
				textureFilteringMode = 4,
			},
		},
		[5] = {
			text = TEXT_ULTRA,
			cvars =	{
				textureFilteringMode = 5,
			},
		},
	},
	dependent = {
		"Graphics_QualityDropDown",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_LiquidDetailDropDown"]={
	name=LIQUID_DETAIL;
	description = OPTION_TOOLTIP_LIQUID_DETAIL,

	data = {
		[1] = {
			text = TEXT_LOW,
			cvars =	{
				waterDetail = 0,
			},
		},
		[2] = {
			text = TEXT_FAIR,
			cvars =	{
				waterDetail = 1,
			},
		},
		[3] = {
			text = TEXT_MEDIUM,
			cvars =	{
				waterDetail = 2,
			},
		},
		[4] = {
			text = TEXT_ULTRA,
			cvars =	{
				waterDetail = 3,
			},
		},
	},
	dependent = {
		"Graphics_QualityDropDown",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_SunshaftsDropDown"]={
	name=SUNSHAFTS;
	description = "Sunshafts:",

	data = {
		[1] = {
			text = TEXT_DISABLED,
			cvars =	{
				sunshafts = 0,
			},
		},
		[2] = {
			text = TEXT_LOW,
			cvars =	{
				sunshafts = 1,
			},
		},
		[3] = {
			text = TEXT_HIGH,
			cvars =	{
				sunshafts = 2,
			},
		},
	},
	dependent = {
		"Graphics_QualityDropDown",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_PlayerDropDown"]={
	name=PLAYER_DETAIL;
	description = OPTION_TOOLTIP_PLAYER_DETAIL,

	data = {
		[1] = {
			text = TEXT_LOW,
			cvars =	{
				componentTextureLevel = 8,
			},
		},
		[2] = {
			text = TEXT_HIGH,
			cvars =	{
				componentTextureLevel = 9,
			},
		},
	},
	dependent = {
		"Graphics_QualityDropDown",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_BlendingDropDown"]={
	name=TERRAIN_MIP;
	description =  OPTION_TOOLTIP_TERRAIN_TEXTURE,

	data = {
		[1] = {
			text = TEXT_LOW,
			cvars =	{
				terrainMipLevel = 1,
			},
		},
		[2] = {
			text = TEXT_HIGH,
			cvars =	{
				terrainMipLevel = 0,
			},
		},
	},
	dependent = {
		"Graphics_QualityDropDown",
	},
}

-------------------------------------------------------------------------------------------------------
-- Stereo
-------------------------------------------------------------------------------------------------------

VideoStereoPanelOptions = {
	gxStereoEnabled = { text = "ENABLE_STEREO_VIDEO" },
	gxStereoConvergence = { text = "DEPTH_CONVERGENCE", minValue = 0.2, maxValue = 50, valueStep = 0.1, tooltip = OPTION_STEREO_CONVERGENCE},
	gxStereoSeparation = { text = "EYE_SEPARATION", minValue = 0, maxValue = 100, valueStep = 1, tooltip = OPTION_STEREO_SEPARATION},
	gxCursor = { text = "STEREO_HARDWARE_CURSOR" },
}

-------------------------------------------------------------------------------------------------------
-- Advanced
-------------------------------------------------------------------------------------------------------

VideoData["VideoOptionsEffectsPanelBufferingDropDown"]={
	name=TRIPLE_BUFFER;
	data = {
		[1] = {
			text = TEXT_DISABLED,
			cvars =	{
				gxTripleBuffer = 0,
			},
		},
		[2] = {
			text = TEXT_ENABLED,
			cvars =	{
				gxTripleBuffer = 1,
			},
		},
	},
	restart = true;
	description =  OPTION_TOOLTIP_TRIPLE_BUFFER,
}

-------------------------------------------------------------------------------------------------------
VideoData["VideoOptionsEffectsPanelLagDropDown"]={
	name=FIX_LAG;
	data = {
		[1] = {
			text = TEXT_DISABLED,
			cvars =	{
				gxFixLag = 0,
			},
		},
		[2] = {
			text = TEXT_ENABLED,
			cvars =	{
				gxFixLag = 1,
			},
		},
	},
	restart = true,
	description =  OPTION_TOOLTIP_FIX_LAG,
}

-------------------------------------------------------------------------------------------------------
VideoData["VideoOptionsEffectsPanelHardwareCursorDropDown"]={
	name=HARDWARE_CURSOR;
	data = {
		[1] = {
			text = TEXT_DISABLED,
			cvars =	{
				gxCursor = 0,
			},
		},
		[2] = {
			text = TEXT_ENABLED,
			cvars =	{
				gxCursor = 1,
			},
		},
	},
	description =  OPTION_TOOLTIP_HARDWARE_CURSOR,
	restart = true,
}

-------------------------------------------------------------------------------------------------------
-- Unused
-------------------------------------------------------------------------------------------------------

VideoData["VideoOptionsEffectsPanelUiScaleDropDown"]={
	name=UI_SCALE;
	data = {
		[1] = {
			text = TEXT_MEDIUM,
			cvars =	{
				uiscale = 0.5,
			},
		},
		[2] = {
			text = TEXT_HIGH,
			cvars =	{
				uiscale = 0.75,
			},
		},
		[3] = {
			text = TEXT_ULTRA,
			cvars =	{
				uiscale = 1,
			},
		},
	},
	description =  OPTION_TOOLTIP_UI_SCALE,
	SetValue = 
		function(self, value)
			if(not InGlue()) then
				Graphics_TableSetValue(self,value);
			end
		end,
	GetValue = 
		function(self, value)
			if(not InGlue()) then
				return Graphics_TableGetValue(self);
			else
				return 0;
			end
		end,
	onload =
		function(self)
			if(InGlue()) then
				self:Hide();
			else
				self:Show();
			end
		end,
}

VideoData["VideoOptionsEffectsPanelMaxFPSSlider"]={
	name=MAXFPS;
}
VideoData["VideoOptionsEffectsPanelMaxFPSBKSlider"]={
	name=MAXFPSBK;
}

