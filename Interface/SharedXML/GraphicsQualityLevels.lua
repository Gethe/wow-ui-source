-------------------------------------------------------------------------------------------------------
-- Overall Quality
-------------------------------------------------------------------------------------------------------
ClassicGraphicsQuality = 3;

VideoData["Graphics_Quality"]={
	name = OVERALL_QUALITY;
	childOptions = {
				"Graphics_ParticleDensityDropDown",
				"Graphics_EnvironmentalDetailSlider",
				"Graphics_GroundClutterSlider",
				"Graphics_ShadowsDropDown",
				"Graphics_TextureResolutionDropDown",
				"Graphics_FilteringDropDown",
				"Graphics_LiquidDetailDropDown",
				"Graphics_SunshaftsDropDown",
				"Graphics_ProjectedTexturesDropDown",
				"Graphics_SSAODropDown",
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
				"RaidGraphics_ParticleDensityDropDown",
				"RaidGraphics_EnvironmentalDetailSlider",
				"RaidGraphics_GroundClutterSlider",
				"RaidGraphics_ShadowsDropDown",
				"RaidGraphics_TextureResolutionDropDown",
				"RaidGraphics_FilteringDropDown",
				"RaidGraphics_LiquidDetailDropDown",
				"RaidGraphics_SunshaftsDropDown",
				"RaidGraphics_ProjectedTexturesDropDown",
				"RaidGraphics_SSAODropDown",
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
	restart = true,
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
	restart = true,
}

-------------------------------------------------------------------------------------------------------

-- helper function to deal with decoding the resolution string
function DecodeResolution(valueString)
	if(valueString == nil) then
		return 0,0;
	end
	local xIndex = strfind(valueString, "x");
	local width = strsub(valueString, 1, xIndex-1);
	local height = strsub(valueString, xIndex+1, strlen(valueString));
	local widthIndex = strfind(height, " ");
	if (widthIndex ~= nil) then
		height = strsub(height, 0, widthIndex-1);
	end
	return tonumber(width), tonumber(height);
end

VideoData["Display_ResolutionDropDown"]={
	name = WINDOW_SIZE;
	description = OPTION_TOOLTIP_RESOLUTION,	
	
	tablefunction = 
		function(self)
			return GetScreenResolutions(Display_PrimaryMonitorDropDown:GetValue());
		end,
	getValues = 
		function(self)
			return DecodeResolution(self.table[self:GetValue()]);
		end,
	readfilter =
		function(self, value)
			local width, height = DecodeResolution(value);
			return value;
		end,
	SetValue =
		function (self, value)
			local width, height = DecodeResolution(self.table[value]);
			SetScreenResolution(width, height, Display_DisplayModeDropDown:fullscreenmode());
		end,
	doGetValue = 
		function(self)
			return GetCurrentResolution(Display_PrimaryMonitorDropDown:GetValue(), Display_DisplayModeDropDown:fullscreenmode());
		end,
	onrefresh =
	function(self)
		if(Display_DisplayModeDropDown:fullscreenmode()) then
			VideoOptions_Disable(self);
		else
			VideoOptions_Enable(self);
		end
	end,
	lookup = Graphics_TableLookupSafe,
	restart = true,
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
	restart = true,
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

VideoData["Graphics_GroundClutterSlider"]={
	name= GROUND_CLUTTER;
	tooltip = OPTION_TOOLTIP_GROUND_CLUTTER,
	graphicsCVar = "graphicsGroundClutter",
	classic = 3,
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_GroundClutterSlider"]={
	name= GROUND_CLUTTER;
	tooltip = OPTION_TOOLTIP_GROUND_CLUTTER,
	graphicsCVar = "raidGraphicsGroundClutter",
	classic = 3,
	dependent = {
		"RaidGraphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_EnvironmentalDetailSlider"]={
	name = ENVIRONMENT_DETAIL;
	tooltip = OPTION_TOOLTIP_ENVIRONMENT_DETAIL,
	graphicsCVar = "graphicsEnvironmentDetail",
	classic = 3,
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_EnvironmentalDetailSlider"]={
	name = ENVIRONMENT_DETAIL;
	tooltip = OPTION_TOOLTIP_ENVIRONMENT_DETAIL,
	graphicsCVar = "raidGraphicsEnvironmentDetail",
	classic = 3,
	dependent = {
		"RaidGraphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_ParticleDensityDropDown"]={
	name = PARTICLE_DENSITY;
	description = OPTION_TOOLTIP_PARTICLE_DENSITY,
	graphicsCVar =	"graphicsParticleDensity",
	classic = 3,
	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
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

VideoData["RaidGraphics_ParticleDensityDropDown"]={
	name = PARTICLE_DENSITY;
	description = OPTION_TOOLTIP_PARTICLE_DENSITY,
	graphicsCVar =	"raidGraphicsParticleDensity",
	classic = 3,
	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
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
VideoData["Graphics_SSAODropDown"]={
	name = SSAO_LABEL;
	description = OPTION_TOOLTIP_SSAO,
	graphicsCVar =	"graphicsSSAO",
	classic = 1,
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
	classic = 1,
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
			tooltip = VIDEO_OPTIONS_SSAO_ULTRA,
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
	classic = 1,
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
	classic = 1,
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
	classic = 2,
	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			tooltip = VIDEO_OPTIONS_TEXTURE_DETAIL_LOW,
		},
		[2] = {
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
	classic = 2,
	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			tooltip = VIDEO_OPTIONS_TEXTURE_DETAIL_LOW,
		},
		[2] = {
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
	classic = 2,
	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
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
	classic = 2,
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
VideoData["Graphics_FilteringDropDown"]={
	name = ANISOTROPIC;
	description = OPTION_TOOLTIP_ANISOTROPIC,
	graphicsCVar =	"graphicsTextureFiltering",
	classic = 3,
	data = {
		[1] = {
			text = VIDEO_OPTIONS_BILINEAR,
		},
		[2] = {
			text = VIDEO_OPTIONS_TRILINEAR,
		},
		[3] = {
			text = VIDEO_OPTIONS_2XANISOTROPIC,
		},
		[4] = {
			text = VIDEO_OPTIONS_4XANISOTROPIC,
		},
		[5] = {
			text = VIDEO_OPTIONS_8XANISOTROPIC,
		},
		[6] = {
			text = VIDEO_OPTIONS_16XANISOTROPIC,
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_FilteringDropDown"]={
	name = ANISOTROPIC;
	description = OPTION_TOOLTIP_ANISOTROPIC,
	graphicsCVar =	"raidGraphicsTextureFiltering",
	classic = 3,
	data = {
		[1] = {
			text = VIDEO_OPTIONS_BILINEAR,
		},
		[2] = {
			text = VIDEO_OPTIONS_TRILINEAR,
		},
		[3] = {
			text = VIDEO_OPTIONS_2XANISOTROPIC,
		},
		[4] = {
			text = VIDEO_OPTIONS_4XANISOTROPIC,
		},
		[5] = {
			text = VIDEO_OPTIONS_8XANISOTROPIC,
		},
		[6] = {
			text = VIDEO_OPTIONS_16XANISOTROPIC,
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
	classic = 1,
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
	classic = 1,
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
VideoData["Graphics_SunshaftsDropDown"]={
	name = SUNSHAFTS;
	description = OPTION_TOOLTIP_SUNSHAFTS,
	graphicsCVar =	"graphicsSunshafts",
	classic = 1,
	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
			tooltip = VIDEO_OPTIONS_SUNSHAFTS_DISABLED,
		},
		[2] = {
			text = VIDEO_OPTIONS_LOW,
			tooltip = VIDEO_OPTIONS_SUNSHAFTS_LOW,
		},
		[3] = {
			text = VIDEO_OPTIONS_HIGH,
			tooltip = VIDEO_OPTIONS_SUNSHAFTS_HIGH,
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

VideoData["RaidGraphics_SunshaftsDropDown"]={
	name = SUNSHAFTS;
	description = OPTION_TOOLTIP_SUNSHAFTS,
	graphicsCVar =	"raidGraphicsSunshafts",
	classic = 1,
	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
			tooltip = VIDEO_OPTIONS_SUNSHAFTS_DISABLED,
		},
		[2] = {
			text = VIDEO_OPTIONS_LOW,
			tooltip = VIDEO_OPTIONS_SUNSHAFTS_LOW,
		},
		[3] = {
			text = VIDEO_OPTIONS_HIGH,
			tooltip = VIDEO_OPTIONS_SUNSHAFTS_HIGH,
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
				gxTripleBuffer = 0,
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_ENABLED,
			cvars =	{
				gxTripleBuffer = 1,
			},
		},
	},
	restart = true;
}

-------------------------------------------------------------------------------------------------------
VideoData["Advanced_LagDropDown"]={
	name = FIX_LAG;
	description = OPTION_TOOLTIP_FIX_LAG,
	
	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
			cvars =	{
				gxFixLag = 0,
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_ENABLED,
			cvars =	{
				gxFixLag = 1,
			},
		},
	},
	restart = true,
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
VideoData["Advanced_UseUIScale"]={
	name = USE_UISCALE;
	tooltip = OPTION_TOOLTIP_USE_UISCALE,
}
VideoData["Advanced_AdapterDropDown"]={
	name = GRAPHICS_CARD,
	description = OPTION_TOOLTIP_GRAPHICS_CARD,
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

VideoData["Advanced_StereoEnabled"]={
	name = ENABLE_STEREO_VIDEO;
	tooltip = OPTION_TOOLTIP_ENABLE_STEREO_VIDEO,
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
	name = RENDER_SCALE;
	tooltip = OPTION_TOOLTIP_RENDER_SCALE,
}
