-------------------------------------------------------------------------------------------------------
VideoStereoPanelOptions = {
	gxStereoEnabled = { text = "ENABLE_STEREO_VIDEO" },
	gxStereoConvergence = { text = "DEPTH_CONVERGENCE", minValue = 0.2, maxValue = 50, valueStep = 0.1, tooltip = OPTION_STEREO_CONVERGENCE},
	gxStereoSeparation = { text = "EYE_SEPARATION", minValue = 0, maxValue = 100, valueStep = 1, tooltip = OPTION_STEREO_SEPARATION},
	gxCursor = { text = "STEREO_HARDWARE_CURSOR" },
}
------------------------------------------------------------------------------------------------------
VideoData["VideoOptionsEffectsPanelBufferingDropDown"]={
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
VideoData["Graphics_QualityDropDown"]={
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
				Graphics_WeatherIntensityDropDown = TEXT_FAIR,
				Graphics_PlayerDropDown = TEXT_FAIR,
				Graphics_LiquidDetailDropDown = TEXT_FAIR,
				Graphics_SunshaftsDropDown = TEXT_DISABLED,
				Graphics_FullScreenGlowDropDown = TEXT_DISABLED,
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
				Graphics_PlayerDropDown = TEXT_LOW,
				Graphics_LiquidDetailDropDown = TEXT_MEDIUM,
				Graphics_SunshaftsDropDown = TEXT_DISABLED,
				Graphics_FullScreenGlowDropDown = TEXT_DISABLED,
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
				Graphics_PlayerDropDown = TEXT_LOW,
				Graphics_LiquidDetailDropDown = TEXT_HIGH,
				Graphics_SunshaftsDropDown = TEXT_DISABLED,
				Graphics_FullScreenGlowDropDown = TEXT_DISABLED,
				Graphics_ProjectedTexturesDropDown = TEXT_DISABLED,
            },
        },
        [5] = {
            text = TEXT_ULTRA,
            tooltip = VIDEO_QUALITY_SUBTEXT5,
            notify = {
				Graphics_ViewDistanceDropDown = TEXT_ULTRA,
				Graphics_BlendingDropDown = TEXT_HIGH,
				Graphics_TextureResolutionDropDown = TEXT_ENABLED,
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
				Graphics_SunshaftsDropDown = TEXT_ENABLED,
				Graphics_FullScreenGlowDropDown = TEXT_ENABLED,
				Graphics_ProjectedTexturesDropDown = TEXT_ENABLED,
            },
        },
    },
    restart = true,
	clickhelper = 
		function(self, value)
			for key, notify_value in pairs(self.data[value].notify) do
				_G[key].notify(_G[key], notify_value);
			end
		end,
	onclickfunction=
        function(self)	-- this self is the button dropdown
			local us = self:GetParent().dropdown;
			us.clickhelper(us, self:GetID());
            VideoOptionsDropDown_OnClick(self);
        end,
    description =  "Video Quality:",
}


-------------------------------------------------------------------------------------------------------
VideoData["Graphics_DisplayModeDropDown"]={
	name = "Display Mode",
	description = "Allows you to change the primary display mode of the game to Fullscreen, Windowed, or Windowed (Fullscreen).  Windowed modes may cause a drop in performance.",
	data = {
		[1] = {
			text = "Windowed",
			cvars =	{
				gxWindow = 1,
				gxMaximize = 0,
			},
		},
		[2] = {
			text = "Windowed (Fullscreen)",
			cvars =	{
				gxWindow = 1,
				gxMaximize = 1,
			},
		},
		[3] = {
			text = "Fullscreen",
			cvars =	{
				gxWindow = 0,
				gxMaximize = 0,
			},
		},
	},
	restart = true,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_ResolutionDropDown"]={
	name = "Resolution",
	description = "Higher resolution will result in increased clarity, but this greatly affects performance.  Choose a resolution that matches the aspect ratio of your monitor.",	
	tablefunction = GetScreenResolutions,
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
	GetValue = GetCurrentResolution,
	onclickfunction=
		function(self)	-- this self is the button dropdown
			Graphics_RefreshDropDown.updaterefresh(Graphics_RefreshDropDown);
			VideoOptionsDropDown_OnClick(self);
		end,
	restart = true,
}
-------------------------------------------------------------------------------------------------------
VideoData["Graphics_RefreshDropDown"]={
	name = "Refresh Rate",
	description = "Refers to the number of times the image is drawn to the monitor.  Some players may see a flicker if the refresh rate is too low.",
	
	cvar = "gxRefresh";
	restart = true,
	useValue = true,	-- we don't return an ID (index), we return a string that must be compared.
	updaterefresh =
		function(self)
			self.tablerefresh = true;						--our table is out of date. Does our value still exist?
			local value = tonumber(self.newValue);			--
			local values = {self.tablefunction()};			--
			for i, val in ipairs(values) do
				if(val == value) then
					return;
				end
			end
			self.notify(self, self.readfilter(self, values[#values]));	--update
		end,
	tablefunction = 
		function()
			-- get refresh rates for the currently selected resolution
			local id = VideoOptionsDropDownMenu_GetSelectedID(Graphics_ResolutionDropDown) or GetCurrentResolution();
			return GetRefreshRates(id);
		end,
	readfilter =
		function(self, value)
			return value .. HERTZ;
		end,
	SetValue =
		function(self, value)
			BlizzardOptionsPanel_SetCVarSafe(self.cvar, tonumber(value));
		end,
	GetValue = 
		function(self)
			return BlizzardOptionsPanel_GetCVarSafe(self.cvar) .. HERTZ;
		end,
	restart = true,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_ResizeDropDown"]={
	name = "Resize Window",
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
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_PrimaryMonitorDropDown"]={
	name = "Primary Monitor",
	description = "Allows you to change the primary monitor used by the display.",
	
	data = {
		[1] = {
			text = "Default",
			cvars =	{
			},
		},
		[2] = {
			text = "Monitor 1",
			cvars =	{
			},
		},
		[3] = {
			text = "Monitor 2",
			cvars =	{
			},
		},
	},
	restart = true,
}
-------------------------------------------------------------------------------------------------------
VideoData["Graphics_MultiSampleDropDown"]={
	name = "Multisampling",
	description = OPTION_TOOLTIP_MULTISAMPLING;
	
	restart=true,
	table = {},
	tabledata = {},
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
VideoData["Graphics_VerticalSyncDropDown"]={
	name = "Vertical Sync",
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

--"Determines the overall brightness of the game.  Use this if your monitor causes the game to be too bright or too dark.",
-------------------------------------------------------------------------------------------------------
VideoData["Graphics_GammaSlider"]={
	name = "Gamma",
	description = OPTION_TOOLTIP_GAMMA,
	type = CONTROLTYPE_SLIDER,
	restart = true,
}
-------------------------------------------------------------------------------------------------------
VideoData["Graphics_ViewDistanceDropDown"]={
	data = {
		[1] = {
			text = TEXT_LOW,
			cvars =	{
				farclip = 177,
			},
		},
		[2] = {
			text = TEXT_FAIR,
			cvars =	{
				farclip = 507,
			},
		},
		[3] = {
			text = TEXT_MEDIUM,
			cvars =	{
				farclip = 727,
			},
		},
		[4] = {
			text = TEXT_HIGH,
			cvars =	{
				farclip = 1057,
			},
		},
		[5] = {
			text = TEXT_ULTRA,
			cvars =	{
				farclip = 1277,
			},
		},
	},
	description = "These are the view distances:",
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_GroundClutterRadiusDropDown"]={
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
	description = OPTION_TOOLTIP_GROUND_RADIUS,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_GroundClutterDensityDropDown"]={
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
	description =  OPTION_TOOLTIP_GROUND_DENSITY,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_EnvironmentalDetailDropDown"]={
	data = {
		[1] = {
			text = TEXT_LOW,
			cvars =	{
				environmentDetail = 0.5,
			},
		},
		[2] = {
			text = TEXT_FAIR,
			cvars =	{
				environmentDetail = 0.75,
			},
		},
		[3] = {
			text = TEXT_MEDIUM,
			cvars =	{
				environmentDetail = 1.0,
			},
		},
		[4] = {
			text = TEXT_HIGH,
			cvars =	{
				environmentDetail = 1.25,
			},
		},
		[5] = {
			text = TEXT_ULTRA,
			cvars =	{
				environmentDetail = 1.5,
			},
		},
	},
	description =  OPTION_TOOLTIP_ENVIRONMENT_DETAIL,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_ParticleDensityDropDown"]={
	data = {
		[1] = {
			text = TEXT_LOW,
			cvars =	{
				particleDensity = 0.1,
			},
		},
		[2] = {
			text = TEXT_FAIR,
			cvars =	{
				particleDensity = 0.4,
			},
		},
		[3] = {
			text = TEXT_MEDIUM,
			cvars =	{
				particleDensity = 0.6,
			},
		},
		[4] = {
			text = TEXT_HIGH,
			cvars =	{
				particleDensity = 0.8,
			},
		},
		[5] = {
			text = TEXT_ULTRA,
			cvars =	{
				particleDensity = 1.0,
			},
		},
	},
	description =  OPTION_TOOLTIP_PARTICLE_DENSITY,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_FullScreenGlowDropDown"]={
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
	description =  OPTION_TOOLTIP_FULL_SCREEN_GLOW,
}
-------------------------------------------------------------------------------------------------------
VideoData["Graphics_ShadowsDropDown"]={
	data = {
		[1] = {
			text = TEXT_LOW,
			cvars =	{
				extShadowQuality = 0,
			},
		},
		[2] = {
			text = TEXT_FAIR,
			cvars =	{
				extShadowQuality = 0,
			},
		},
		[3] = {
			text = TEXT_MEDIUM,
			cvars =	{
				extShadowQuality = 1,
			},
		},
		[4] = {
			text = TEXT_HIGH,
			cvars =	{
				extShadowQuality = 4,
			},
		},
		[5] = {
			text = TEXT_ULTRA,
			cvars =	{
				extShadowQuality = 5,
			},
		},
	},
	description = OPTION_TOOLTIP_CHARACTER_SHADOWS,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_WeatherIntensityDropDown"]={
	data = {
		[1] = {
			text = TEXT_LOW,
			cvars =	{
				weatherDensity = 0,
			},
		},
		[2] = {
			text = TEXT_FAIR,
			cvars =	{
				weatherDensity = 0,
			},
		},
		[3] = {
			text = TEXT_MEDIUM,
			cvars =	{
				weatherDensity = 1,
			},
		},
		[4] = {
			text = TEXT_HIGH,
			cvars =	{
				weatherDensity = 2,
			},
		},
		[5] = {
			text = TEXT_ULTRA,
			cvars =	{
				weatherDensity = 3,
			},
		},
	},
	description = OPTION_TOOLTIP_WEATHER_DETAIL,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_TextureResolutionDropDown"]={
	data = {
		[1] = {
			text = TEXT_DISABLED,
			cvars =	{
				BaseMip = 0,
			},
		},
		[2] = {
			text = TEXT_ENABLED,
			cvars =	{
				BaseMip = 1,
			},
		},
	},
	description =  OPTION_TOOLTIP_TEXTURE_DETAIL,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_ProjectedTexturesDropDown"]={
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
	description =  OPTION_TOOLTIP_PROJECTED_TEXTURES,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_FilteringDropDown"]={
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
	description =  OPTION_TOOLTIP_TRILINEAR,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_LiquidDetailDropDown"]={
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
			text = TEXT_HIGH,
			cvars =	{
				waterDetail = 2,
			},
		},
		[5] = {
			text = TEXT_ULTRA,
			cvars =	{
				waterDetail = 3,
			},
		},
	},
	description =  OPTION_TOOLTIP_LIQUID_DETAIL,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_SunshaftsDropDown"]={
	data = {
		[1] = {
			text = TEXT_DISABLED,
			cvars =	{
				sunshafts = 0,
			},
		},
		[2] = {
			text = TEXT_ENABLED,
			cvars =	{
				sunshafts = 1,
			},
		},
	},
	description =  "Sunshafts:",
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_PlayerDropDown"]={
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
	restart=true,
	description =  OPTION_TOOLTIP_PLAYER_DETAIL,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_BlendingDropDown"]={
	data = {
		[1] = {
			text = TEXT_LOW,
			cvars =	{
				shadowLevel = 1,
			},
		},
		[2] = {
			text = TEXT_HIGH,
			cvars =	{
				shadowLevel = 0,
			},
		},
	},
	restart=true,
	description =  OPTION_TOOLTIP_TERRAIN_TEXTURE,
}
-------------------------------------------------------------------------------------------------------


VideoData["VideoOptionsEffectsPanelUiScaleDropDown"]={
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

