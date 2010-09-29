-------------------------------------------------------------------------------------------------------
-- Overall Quality
-------------------------------------------------------------------------------------------------------
VideoData["Graphics_Quality"]={
	name = OVERALL_QUALITY;
	data = {
		[1] = {
			text = VIDEO_QUALITY_LABEL1,
			tooltip = VIDEO_QUALITY_SUBTEXT1,
			notify = {
				Graphics_ViewDistanceDropDown = VIDEO_OPTIONS_LOW,
				Graphics_ParticleDensityDropDown = VIDEO_OPTIONS_LOW,
				Graphics_EnvironmentalDetailDropDown = VIDEO_OPTIONS_LOW,
				Graphics_GroundClutterDropDown = VIDEO_OPTIONS_LOW,
				Graphics_ShadowsDropDown = VIDEO_OPTIONS_LOW,
				Graphics_TextureResolutionDropDown = VIDEO_OPTIONS_LOW,
				Graphics_FilteringDropDown = VIDEO_OPTIONS_BILINEAR,
				Graphics_LiquidDetailDropDown = VIDEO_OPTIONS_LOW,
				Graphics_SunshaftsDropDown = VIDEO_OPTIONS_DISABLED,
				Graphics_ProjectedTexturesDropDown = VIDEO_OPTIONS_DISABLED,
			},
		},
		[2] = {
			text = VIDEO_QUALITY_LABEL2,
			tooltip = VIDEO_QUALITY_SUBTEXT2,
			notify = {
				Graphics_ViewDistanceDropDown = VIDEO_OPTIONS_FAIR,
				Graphics_ParticleDensityDropDown = VIDEO_OPTIONS_FAIR,
				Graphics_EnvironmentalDetailDropDown = VIDEO_OPTIONS_FAIR,
				Graphics_GroundClutterDropDown = VIDEO_OPTIONS_FAIR,
				Graphics_ShadowsDropDown = VIDEO_OPTIONS_FAIR,
				Graphics_TextureResolutionDropDown = VIDEO_OPTIONS_FAIR,
				Graphics_FilteringDropDown = VIDEO_OPTIONS_TRILINEAR,
				Graphics_LiquidDetailDropDown = VIDEO_OPTIONS_FAIR,
				Graphics_SunshaftsDropDown = VIDEO_OPTIONS_DISABLED,
				Graphics_ProjectedTexturesDropDown = VIDEO_OPTIONS_DISABLED,
			},
		},
		[3] = {
			text = VIDEO_QUALITY_LABEL3,
			tooltip = VIDEO_QUALITY_SUBTEXT3,
			notify = {
				Graphics_ViewDistanceDropDown = VIDEO_OPTIONS_MEDIUM,
				Graphics_ParticleDensityDropDown = VIDEO_OPTIONS_MEDIUM,
				Graphics_EnvironmentalDetailDropDown = VIDEO_OPTIONS_MEDIUM,
				Graphics_GroundClutterDropDown = VIDEO_OPTIONS_MEDIUM,
				Graphics_ShadowsDropDown = VIDEO_OPTIONS_MEDIUM,
				Graphics_TextureResolutionDropDown = VIDEO_OPTIONS_HIGH,
				Graphics_FilteringDropDown = VIDEO_OPTIONS_4XANISOTROPIC,
				Graphics_LiquidDetailDropDown = VIDEO_OPTIONS_MEDIUM,
				Graphics_SunshaftsDropDown = VIDEO_OPTIONS_LOW,
				Graphics_ProjectedTexturesDropDown = VIDEO_OPTIONS_ENABLED,
			},
		},
		[4] = {
			text = VIDEO_QUALITY_LABEL4,
			tooltip = VIDEO_QUALITY_SUBTEXT4,
			notify = {
				Graphics_ViewDistanceDropDown = VIDEO_OPTIONS_HIGH,
				Graphics_ParticleDensityDropDown = VIDEO_OPTIONS_HIGH,
				Graphics_EnvironmentalDetailDropDown = VIDEO_OPTIONS_HIGH,
				Graphics_GroundClutterDropDown = VIDEO_OPTIONS_HIGH,
				Graphics_ShadowsDropDown = VIDEO_OPTIONS_HIGH,
				Graphics_TextureResolutionDropDown = VIDEO_OPTIONS_HIGH,
				Graphics_FilteringDropDown = VIDEO_OPTIONS_8XANISOTROPIC,
				Graphics_LiquidDetailDropDown = VIDEO_OPTIONS_MEDIUM,
				Graphics_SunshaftsDropDown = VIDEO_OPTIONS_HIGH,
				Graphics_ProjectedTexturesDropDown = VIDEO_OPTIONS_ENABLED,
			},
		},
		[5] = {
			text = VIDEO_QUALITY_LABEL5,
			tooltip = VIDEO_QUALITY_SUBTEXT5,
			notify = {
				Graphics_ViewDistanceDropDown = VIDEO_OPTIONS_ULTRA,
				Graphics_TextureResolutionDropDown = VIDEO_OPTIONS_HIGH,
				Graphics_ParticleDensityDropDown = VIDEO_OPTIONS_ULTRA,
				Graphics_EnvironmentalDetailDropDown = VIDEO_OPTIONS_ULTRA,
				Graphics_GroundClutterDropDown = VIDEO_OPTIONS_ULTRA,
				Graphics_ShadowsDropDown = VIDEO_OPTIONS_ULTRA,
				Graphics_TextureResolutionDropDown = VIDEO_OPTIONS_HIGH,
				Graphics_FilteringDropDown = VIDEO_OPTIONS_16XANISOTROPIC,
				Graphics_LiquidDetailDropDown = VIDEO_OPTIONS_ULTRA,
				Graphics_SunshaftsDropDown = VIDEO_OPTIONS_HIGH,
				Graphics_ProjectedTexturesDropDown = VIDEO_OPTIONS_ENABLED,
			},
		},
	},
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
			local max = 0;
			local valid = true;
			for i, value in ipairs(self.data) do
				for key, val in pairs(value.notify) do
					local j = _G[key]:lookup(val)
					if( not IsValid ( _G[key], j) ) then
						valid = false;
						break;
					end
				end
				if(not valid) then
					break;
				end
				max = max + 1;
			end
			self:SetBackdrop({bgFile = "Interface\\Buttons\\UI-SliderBar-Background", edgeFile = "Interface\\Buttons\\UI-SliderBar-Border", tile = true, tileSize = 8, edgeSize = 8, pieces=93, insets = { left = 3, right = 3, top = 6, bottom = 6 } } );
			local parent = self:GetParent():GetName();
			local name = self:GetName();

			_G[name.."Text"]:SetFontObject("OptionsFontSmall");
			_G[name.."Low"]:Hide();
			_G[name.."High"]:Hide();

			local fullwidth = _G[parent .."GraphicsHeaderUnderline"]:GetWidth() - 20;
			self.noclick = true;
			if((max < #self.data) and (max>0)) then
				local area = fullwidth * (max-1)/4 + 20;
				self:SetWidth(area);
				_G[name .. "Invalid"]:SetWidth(fullwidth - area + 10);
				_G[name .. "Invalid"]:Show();
				self:SetMinMaxValues(1,max);
			else
				self:SetWidth(fullwidth);
				_G[name .. "Invalid"]:Hide();
			end
			if(not self.isdependtarget) then
				self:setinitialslider();
			end
			self:updatecustomfield(self:GetValue());
			self.noclick = false;
		end,
	setinitialslider = function(self)
		self.noclick = true;
		Graphics_Quality:SetValue(BlizzardOptionsPanel_GetCVarSafe("graphicsQuality"));	-- set the slider only
		self.noclick = false;
	end,
	onload = function(self)
		self.sliderGetValue = self.GetValue;
		self.GetValue = self.GetValueNew;
		self:setinitialslider();
	end,
	updatecustomfield =
		function(self, value)
			if(value > #self.data) then
				_G["Graphics_RightQualityLabel"]:Show();
			else
				self.noclick = true;
				Graphics_Quality:SetValue(value);	-- set the slider only
				self.noclick = false;
				_G["Graphics_RightQualityLabel"]:Hide();
			end
		end,
	onvaluechanged = 
		function(self, value)
			self.savevalue = value;
			if(not self.noclick) then
				self:updatecustomfield(value);
				VideoOptions_OnClick(self, value);
			end
		end,
	commitslider =
		function(self)
			local value = self:GetValue();
			if(value > #self.data) then
				value = self:sliderGetValue();
			end
			BlizzardOptionsPanel_SetCVarSafe("graphicsQuality", value);
		end,
}
-------------------------------------------------------------------------------------------------------
-- Display
-------------------------------------------------------------------------------------------------------

VideoData["Graphics_DisplayModeDropDown"]={
	name = DISPLAY_MODE;
	description = OPTION_TOOLTIP_DISPLAY_MODE,
	dataA = {
		[1] = {
			text = VIDEO_OPTIONS_WINDOWED,
			cvars =	{
				gxWindow = 1,
				gxMaximize = 0,
			},
			windowed = true;
			fullscreen = false;
		},
		[2] = {
			text = VIDEO_OPTIONS_WINDOWED_FULLSCREEN,
			cvars =	{
				gxWindow = 1,
				gxMaximize = 1,
			},
			windowed = true;
			fullscreen = true;
		},
		[3] = {
			text = VIDEO_OPTIONS_FULLSCREEN,
			cvars =	{
				gxWindow = 0,
				gxMaximize = 0,
			},
			windowed = false;
			fullscreen = true;
		},
	},
	dataB = {
		[1] = {
			text = VIDEO_OPTIONS_WINDOWED,
			cvars =	{
				gxWindow = 1,
				gxMaximize = 0,
			},
			windowed = true;
			fullscreen = false;
		},
	},
	onload =
		function(self)
			self.data = self.dataA;
		end,
	onrefresh =
		function(self)
			if(Graphics_PrimaryMonitorDropDown:landscape()) then
				self.data = self.dataA;
			else
				self.data = self.dataB;
			end
		end,
	dependtarget = VideoOptionsDropDownMenu_dependtarget_refreshtable;
	dependent = {
		"Graphics_ResolutionDropDown",
		"Graphics_RefreshDropDown",
		"Advanced_GammaSlider",
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
VideoData["Graphics_PrimaryMonitorDropDown"]={
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
		"Graphics_DisplayModeDropDown",
		"Graphics_ResolutionDropDown",	--resolutions may disappear when we change the monitor
		"Graphics_RefreshDropDown",
		"Advanced_GammaSlider",
	},
	landscape =
		function(self)
			local ratio = GetMonitorAspectRatio(self:GetValue());
			return (ratio>=1.0);
		end,
	clientRestart = true,
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

VideoData["Graphics_ResolutionDropDown"]={
	name = RESOLUTION;
	description = OPTION_TOOLTIP_RESOLUTION,	
	
	tablefunction = 
		function(self)
			return GetScreenResolutions(Graphics_PrimaryMonitorDropDown:GetValue());
		end,
	getValues = 
		function(self)
			return DecodeResolution(self.table[self:GetValue()]);
		end,
	readfilter =
		function(self, value)
			local width, height = DecodeResolution(value);
			if ( width/height > 4/3 ) then
				value = value.." ".. WIDESCREEN_TAG;
			end
			return value;
		end,
	SetValue =
		function (self, value)
			local width, height = DecodeResolution(self.table[value]);
			SetScreenResolution(width, height);
		end,
	doGetValue = 
		function(self)
			return GetCurrentResolution(Graphics_PrimaryMonitorDropDown:GetValue());
		end,
	dependtarget = VideoOptionsDropDownMenu_dependtarget_refreshtable,
	dependent = {
		"Graphics_RefreshDropDown"
	},
	lookup = Graphics_TableLookupSafe,
	restart = true,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_MultiSampleDropDown"]={
	name = MULTISAMPLE;
	description = OPTION_TOOLTIP_MULTISAMPLING;
	
	table = {},
	tablefunction = GetMultisampleFormats;
	tablenext = 3;
	readfilter =
		function(self, colorBits, depthBits, multiSample)
			return format(VIDEO_OPTIONS_MULTISAMPLE_FORMAT_STRING, multiSample);
		end,
	SetValue = 
		function (self, value)
			SetMultisampleFormat(value);
		end,
	doGetValue = GetCurrentMultisampleFormat;
	restart = true,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_RefreshDropDown"]={
	name = REFRESH_RATE;
	description = OPTION_TOOLTIP_REFRESH_RATE,
	
	cvar = "gxRefresh";
	-- code run for dependent target
	tablefunction = 
		function()
			-- get refresh rates for the currently selected resolution
			local x, y = Graphics_ResolutionDropDown:getValues();
			return GetRefreshRates(x, y, Graphics_PrimaryMonitorDropDown:GetValue());
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
	doGetValue = 
		function(self)
			return self:lookup(self.table[self.selectedID] or BlizzardOptionsPanel_GetCVarSafe(self.cvar) .. HERTZ);
		end,
	dependtarget = VideoOptionsDropDownMenu_dependtarget_refreshtable,
	onrefresh =
		function(self)
			if(Graphics_DisplayModeDropDown:windowedmode()) then
				VideoOptions_Disable(self);
			else
				VideoOptions_Enable(self);
			end
		end,
	lookup = Graphics_TableLookupSafe,
	restart = true,
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_VerticalSyncDropDown"]={
	name = VERTICAL_SYNC;
	description = OPTION_TOOLTIP_VERTICAL_SYNC,
	
	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
			cvars =	{
				gxVSync = 0,
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_ENABLED,
			cvars =	{
				gxVSync = 1,
			},
		},
	},
	restart = true,
}

-------------------------------------------------------------------------------------------------------
-- Graphics
-------------------------------------------------------------------------------------------------------

VideoData["Graphics_ViewDistanceDropDown"]={
	name = FARCLIP;
	description = OPTION_TOOLTIP_FARCLIP,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				farClip = 185,
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			cvars =	{
				farClip = 507,
			},
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			cvars =	{
				farClip = 727,
			},
		},
		[4] = {
			text = VIDEO_OPTIONS_HIGH,
			cvars =	{
				farClip = 1057,
			},
		},
		[5] = {
			text = VIDEO_OPTIONS_ULTRA,
			cvars =	{
				farClip = 1250,
			},
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_GroundClutterDropDown"]={
	name= GROUND_CLUTTER;
	description = OPTION_TOOLTIP_GROUND_CLUTTER,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				groundEffectDist = 70,
				groundEffectDensity = 16,
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			cvars =	{
				groundEffectDist = 110,
				groundEffectDensity = 40,
			},
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			cvars =	{
				groundEffectDist = 160,
				groundEffectDensity = 64,
			},
		},
		[4] = {
			text = VIDEO_OPTIONS_HIGH,
			cvars =	{
				groundEffectDist = 200,
				groundEffectDensity = 96,
			},
		},
		[5] = {
			text = VIDEO_OPTIONS_ULTRA,
			cvars =	{
				groundEffectDist = 260,
				groundEffectDensity = 128,
			},
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_EnvironmentalDetailDropDown"]={
	name = ENVIRONMENT_DETAIL;
	description = OPTION_TOOLTIP_ENVIRONMENT_DETAIL,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				environmentDetail = 50,
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			cvars =	{
				environmentDetail = 75,
			},
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			cvars =	{
				environmentDetail = 100,
			},
		},
		[4] = {
			text = VIDEO_OPTIONS_HIGH,
			cvars =	{
				environmentDetail = 125,
			},
		},
		[5] = {
			text = VIDEO_OPTIONS_ULTRA,
			cvars =	{
				environmentDetail = 150,
			},
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_ParticleDensityDropDown"]={
	name = PARTICLE_DENSITY;
	description = OPTION_TOOLTIP_PARTICLE_DENSITY,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				particleDensity = 10,
				weatherDensity = 0,
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			cvars =	{
				particleDensity = 40,
				weatherDensity = 1,
			},
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			cvars =	{
				particleDensity = 60,
				weatherDensity = 1,
			},
		},
		[4] = {
			text = VIDEO_OPTIONS_HIGH,
			cvars =	{
				particleDensity = 80,
				weatherDensity = 2,
			},
		},
		[5] = {
			text = VIDEO_OPTIONS_ULTRA,
			cvars =	{
				particleDensity = 100,
				weatherDensity = 3,
			},
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_ShadowsDropDown"]={
	name = SHADOW_QUALITY;
	description = OPTION_TOOLTIP_SHADOW_QUALITY,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				shadowMode = 0,
			},
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_LOW;
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			cvars =	{
				shadowMode = 1,
				shadowTextureSize = 1024,
			},
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_FAIR;
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			cvars =	{
				shadowMode = 1,
				shadowTextureSize = 2048,
			},
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_MEDIUM;
		},
		[4] = {
			text = VIDEO_OPTIONS_HIGH,
			cvars =	{
				shadowMode = 2,
				shadowTextureSize = 2048,
			},
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_HIGH;
		},
		[5] = {
			text = VIDEO_OPTIONS_ULTRA,
			cvars =	{
				shadowMode = 3,
				shadowTextureSize = 2048,
			},
			tooltip = VIDEO_OPTIONS_SHADOW_QUALITY_ULTRA;
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_TextureResolutionDropDown"]={
	name = TEXTURE_DETAIL;
	description = OPTION_TOOLTIP_TEXTURE_DETAIL,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				baseMip = 1,
				terrainMipLevel = 1,
				componentTextureLevel = 8,
			},
			tooltip = VIDEO_OPTIONS_TEXTURE_DETAIL_LOW,
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			cvars =	{
				baseMip = 0,
				terrainMipLevel = 1,
				componentTextureLevel = 8,
			},
			tooltip = VIDEO_OPTIONS_TEXTURE_DETAIL_FAIR,
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			cvars =	{
				baseMip = 0,
				terrainMipLevel = 0,
				componentTextureLevel = 8,
			},
			tooltip = VIDEO_OPTIONS_TEXTURE_DETAIL_MEDIUM,
		},
		[4] = {
			text = VIDEO_OPTIONS_HIGH,
			cvars =	{
				baseMip = 0,
				terrainMipLevel = 0,
				componentTextureLevel = 9,
			},
			tooltip = VIDEO_OPTIONS_TEXTURE_DETAIL_HIGH,
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_ProjectedTexturesDropDown"]={
	name = PROJECTED_TEXTURES;
	description = OPTION_TOOLTIP_PROJECTED_TEXTURES,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
			cvars =	{
				projectedTextures = 0,
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_ENABLED,
			cvars =	{
				projectedTextures = 1,
			},
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_FilteringDropDown"]={
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
	dependent = {
		"Graphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_LiquidDetailDropDown"]={
	name = LIQUID_DETAIL;
	description = OPTION_TOOLTIP_LIQUID_DETAIL,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				waterDetail = 0,
			},
			tooltip = VIDEO_OPTIONS_LIQUID_DETAIL_LOW,
		},
		[2] = {
			text = VIDEO_OPTIONS_FAIR,
			cvars =	{
				waterDetail = 1,
				reflectionMode = 0,
			},
			tooltip = VIDEO_OPTIONS_LIQUID_DETAIL_FAIR,
		},
		[3] = {
			text = VIDEO_OPTIONS_MEDIUM,
			cvars =	{
				waterDetail = 2,
				rippleDetail = 1,
				reflectionMode = 0,
			},
			tooltip = VIDEO_OPTIONS_LIQUID_DETAIL_MEDIUM,
		},
		[4] = {
			text = VIDEO_OPTIONS_ULTRA,
			cvars =	{
				waterDetail = 3,
				rippleDetail = 2,
				reflectionMode = 3,
			},
			tooltip = VIDEO_OPTIONS_LIQUID_DETAIL_ULTRA,
		},
	},
	dependent = {
		"Graphics_Quality",
	},
}

-------------------------------------------------------------------------------------------------------
VideoData["Graphics_SunshaftsDropDown"]={
	name = SUNSHAFTS;
	description = OPTION_TOOLTIP_SUNSHAFTS,

	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
			cvars =	{
				sunshafts = 0,
			},
			tooltip = VIDEO_OPTIONS_SUNSHAFTS_DISABLED,
		},
		[2] = {
			text = VIDEO_OPTIONS_LOW,
			cvars =	{
				sunshafts = 1,
			},
			tooltip = VIDEO_OPTIONS_SUNSHAFTS_LOW,
		},
		[3] = {
			text = VIDEO_OPTIONS_HIGH,
			cvars =	{
				sunshafts = 2,
			},
			tooltip = VIDEO_OPTIONS_SUNSHAFTS_HIGH,
		},
	},
	dependent = {
		"Graphics_Quality",
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

-------------------------------------------------------------------------------------------------------
VideoData["Advanced_HardwareCursorDropDown"]={
	name = HARDWARE_CURSOR;
	description = OPTION_TOOLTIP_HARDWARE_CURSOR,
	
	data = {
		[1] = {
			text = VIDEO_OPTIONS_DISABLED,
			cvars =	{
				gxCursor = 0,
			},
		},
		[2] = {
			text = VIDEO_OPTIONS_ENABLED,
			cvars =	{
				gxCursor = 1,
			},
		},
	},
	onload =
		function(self)
			local anisotropic, pixelShaders, vertexShaders, trilinear, buffering, maxAnisotropy, hardwareCursor = GetVideoCaps();
			if ( not hardwareCursor ) then
				self:Disable();
			end
		end,
	restart = true,
}

VideoData["Advanced_MaxFPSSlider"]={
	name = MAXFPS;
	tooltip = OPTION_MAXFPS,
	initialize = 
		function(self)
			local value = self:GetCurrentValue();
			if(value == 0) then
				_G["Advanced_MaxFPSCheckBox"]:SetChecked(0);
				VideoOptions_Disable(self);
			else
				_G["Advanced_MaxFPSCheckBox"]:SetChecked(1);
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
				_G["Advanced_MaxFPSBKCheckBox"]:SetChecked(0);
				VideoOptions_Disable(self);
			else
				_G["Advanced_MaxFPSBKCheckBox"]:SetChecked(1);
				VideoOptions_Enable(self);
			end
		end,
}

VideoData["Advanced_MaxFPSCheckBox"]={
	name = MAXFPS_CHECK;
	tooltip = OPTION_MAXFPS_CHECK,
}
VideoData["Advanced_MaxFPSBKCheckBox"]={
	name = MAXFPSBK_CHECK;
	tooltip = OPTION_MAXFPSBK_CHECK,
}
-------------------------------------------------------------------------------------------------------
VideoData["Advanced_GammaSlider"]={
	name = GAMMA;
	tooltip = OPTION_TOOLTIP_GAMMA,
	type = CONTROLTYPE_SLIDER,
	onrefresh =
		function(self)
			local parent = (self:GetParent()):GetName();
			local checkbox = _G[parent .. "DesktopGamma"];
			if(Graphics_DisplayModeDropDown:windowedmode()) then
				self:Hide();
				checkbox:Hide();
			else
				self:Show();
				checkbox:Show();
				local value = Advanced_DesktopGamma:GetChecked();
				if(Advanced_DesktopGamma:GetChecked()) then
					VideoOptions_Disable(self);
				else
					VideoOptions_Enable(self);
				end
			end
		end,
	initialize = function(self)
	end,
}
-------------------------------------------------------------------------------------------------------
VideoData["Advanced_DesktopGamma"]={
	name = DESKTOP_GAMMA;
	tooltip = OPTION_TOOLTIP_DESKTOP_GAMMA,
	cvar = "desktopGamma",
	GetValue =
		function(self)
			return BlizzardOptionsPanel_GetCVarSafe(self.cvar);
		end,
	SetValue = 
		function (self, value)
			BlizzardOptionsPanel_SetCVarSafe(self.cvar, value);
			self:SetChecked(value);
			Advanced_GammaSlider:onrefresh();
		end,
	SetDisplayValue =
		function (self, value)
			self:SetValue(value);	-- live updating
		end,
	onload =
		function(self)
			self:SetChecked(self:GetValue());
		end,
	onclick = 
		function(self)
			if ( self:GetChecked() ) then
				PlaySound("igMainMenuOptionCheckBoxOn");
			else
				PlaySound("igMainMenuOptionCheckBoxOff");
			end
			BlizzardOptionsPanel_CheckButton_OnClick(self);
			VideoOptionsValueChanged(self, (self:GetChecked() and 1 or 0), flag);
			Graphics_EnableApply(self);
		end,
}
VideoData["Advanced_UseUIScale"]={
	name = USE_UISCALE;
	tooltip = OPTION_TOOLTIP_USE_UISCALE,
}
VideoData["Advanced_StereoEnabled"]={
	name = ENABLE_STEREO_VIDEO;
	tooltip = OPTION_TOOLTIP_ENABLE_STEREO_VIDEO,
}


