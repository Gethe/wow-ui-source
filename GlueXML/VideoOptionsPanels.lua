-- if you change something here you probably want to change the frame version too

local OPTIONS_FARCLIP_MIN = 177;
local OPTIONS_FARCLIP_MAX = 1277;

local VIDEO_OPTIONS_CUSTOM_QUALITY = 6;

local VIDEO_OPTIONS_COMPARISON_EPSILON = 0.000001;


-- [[ Generic Video Options Panel ]] --

function VideoOptionsPanel_Okay (self)
	for _, control in next, self.controls do
		if ( control.newValue ) then
			if ( control.value ~= control.newValue ) then
				if ( control.gameRestart ) then
					VideoOptionsFrame.gameRestart = true;
				end
				if ( control.restart ) then
					VideoOptionsFrame.gxRestart = true;
				end
				control:SetValue(control.newValue);
				control.value = control.newValue;
				control.newValue = nil;
			end
		elseif ( control.value ) then
			control:SetValue(control.value);
		end
	end
end

function VideoOptionsPanel_Cancel (self)
	for _, control in next, self.controls do
		if ( control.newValue ) then
			if ( control.value and control.value ~= control.newValue ) then
				if ( control.restart ) then
					VideoOptionsFrame.gxRestart = true;
				end
				-- we need to force-set the value here just in case the control was doing dynamic updating
				control:SetValue(control.value);
				control.newValue = nil;
			end
		elseif ( control.value ) then
			control:SetValue(control.value);
		end
	end
end

function VideoOptionsPanel_Default (self)
	for _, control in next, self.controls do
		if ( control.defaultValue and control.value ~= control.defaultValue ) then
			if ( control.restart ) then
				VideoOptionsFrame.gxRestart = true;
			end
			control:SetValue(control.defaultValue);
			control.newValue = nil;
		end
	end
end

function VideoOptionsPanel_OnLoad (self, okay, cancel, default, refresh)
	okay = okay or VideoOptionsPanel_Okay;
	cancel = cancel or VideoOptionsPanel_Cancel;
	default = default or VideoOptionsPanel_Default;
	refresh = refresh or BlizzardOptionsPanel_Refresh;
	BlizzardOptionsPanel_OnLoad(self, okay, cancel, default, refresh);

	OptionsFrame_AddCategory(VideoOptionsFrame, self);
end

-- [[ Resolution Panel ]] --

ResolutionPanelOptions = {
	gxVSync = { text = "VERTICAL_SYNC" },
	gxTripleBuffer = { text = "TRIPLE_BUFFER" },
	gxCursor = { text = "HARDWARE_CURSOR" },
	gxFixLag = { text = "FIX_LAG" },
	gxWindow = { text = "WINDOWED_MODE" },
	gxMaximize = { text = "WINDOWED_MAXIMIZED" },
	windowResizeLock = { text = "WINDOW_LOCK" },
	desktopGamma = { text = "DESKTOP_GAMMA" },
	gamma = { text = "GAMMA", minValue = -.5, maxValue = .5, valueStep = .1 },
}

function VideoOptionsResolutionPanel_Default (self)
	RestoreVideoResolutionDefaults();
	for _, control in next, self.controls do
		control.newValue = nil;
	end
end

function VideoOptionsResolutionPanel_Refresh (self)
	BlizzardOptionsPanel_Refresh(self);
	VideoOptionsResolutionPanel_RefreshGammaControls();
end

function VideoOptionsResolutionPanel_OnLoad (self)
	self.name = RESOLUTION_LABEL;
	self.options = ResolutionPanelOptions;
	VideoOptionsPanel_OnLoad(self, nil, nil, VideoOptionsResolutionPanel_Default, VideoOptionsResolutionPanel_Refresh);

	self:SetScript("OnEvent", VideoOptionsResolutionPanel_OnEvent);
end

function VideoOptionsResolutionPanel_OnEvent (self, event, ...)
	BlizzardOptionsPanel_OnEvent(self, event, ...);

	if ( event == "SET_GLUE_SCREEN" ) then
		-- don't allow systems that don't support features to enable them
		local anisotropic, pixelShaders, vertexShaders, trilinear, buffering, maxAnisotropy, hardwareCursor = GetVideoCaps();
		if ( not hardwareCursor ) then
			VideoOptionsResolutionPanelHardwareCursor:SetChecked(false);
			VideoOptionsResolutionPanelHardwareCursor:Disable();
		end
		VideoOptionsResolutionPanelHardwareCursor.SetChecked =
			function (self, checked)
				local anisotropic, pixelShaders, vertexShaders, trilinear, buffering, maxAnisotropy, hardwareCursor = GetVideoCaps();
				if ( not hardwareCursor ) then
					checked = false;
				end
				getmetatable(self).__index.SetChecked(self, checked);
			end
		VideoOptionsResolutionPanelHardwareCursor.Enable =
			function (self)
				local anisotropic, pixelShaders, vertexShaders, trilinear, buffering, maxAnisotropy, hardwareCursor = GetVideoCaps();
				if ( not hardwareCursor ) then
					return;
				end
				getmetatable(self).__index.Enable(self);
				local text = _G[self:GetName().."Text"];
				local fontObject = text:GetFontObject();
				_G[self:GetName().."Text"]:SetTextColor(fontObject:GetTextColor());
			end
	end
end

function VideoOptionsResolutionPanel_RefreshGammaControls ()
	if ( VideoOptionsResolutionPanelWindowed:GetChecked() ) then
		VideoOptionsResolutionPanelDesktopGamma:SetChecked();
		VideoOptionsResolutionPanelDesktopGamma:Disable();
		BlizzardOptionsPanel_Slider_Disable(VideoOptionsResolutionPanelGammaSlider);
	else
		VideoOptionsResolutionPanelDesktopGamma:Enable();
		if ( VideoOptionsResolutionPanelDesktopGamma:GetChecked() ) then
			BlizzardOptionsPanel_Slider_Disable(VideoOptionsResolutionPanelGammaSlider);
		else
			BlizzardOptionsPanel_Slider_Enable(VideoOptionsResolutionPanelGammaSlider);
		end
	end
end

function VideoOptionsResolutionPanel_SetWindowed ()
	VideoOptionsResolutionPanel_RefreshGammaControls();
	local value;
	if ( VideoOptionsResolutionPanelWindowed:GetChecked() or
		 VideoOptionsResolutionPanelDesktopGamma:GetChecked() ) then
		value = 1;
	else
		value = 0;
	end
	BlizzardOptionsPanel_SetCVarSafe("desktopGamma", value);
end

function VideoOptionsResolutionPanel_SetGamma (value)
	VideoOptionsResolutionPanel_RefreshGammaControls();
	BlizzardOptionsPanel_SetCVarSafe("desktopGamma", value);
end

function VideoOptionsResolutionPanelResolutionDropDown_OnLoad(self)
	--self.cvar = "gxResolution";

	local value = GetCurrentResolution();

	--self.defaultValue = BlizzardOptionsPanel_GetCVarDefaultSafe(self.cvar);
	self.value = value;
	self.restart = true;

	GlueDropDownMenu_SetWidth(self, 110);
	GlueDropDownMenu_Initialize(self, VideoOptionsResolutionPanelResolutionDropDown_Initialize);
	GlueDropDownMenu_SetSelectedID(self, value, 1);

	self.SetValue = 
		function (self, value)
			SetScreenResolution(value);
		end
	self.GetValue =
		function (self)
			return GetCurrentResolution();
		end
	self.RefreshValue = 
		function (self)
			local value = GetCurrentResolution();
			GlueDropDownMenu_Initialize(self, VideoOptionsResolutionPanelResolutionDropDown_Initialize);
			GlueDropDownMenu_SetSelectedID(self, value, 1);
			self.value = value;
			self.newValue = value;
		end
end

function VideoOptionsResolutionPanelResolutionDropDown_Initialize()
	VideoOptionsResolutionPanelResolutionDropDown_LoadResolutions(GetScreenResolutions());	
end

function VideoOptionsResolutionPanelResolutionDropDown_LoadResolutions(...)
	local info = GlueDropDownMenu_CreateInfo();
	local resolution, xIndex, width, height;
	for i=1, select("#", ...) do
		resolution = (select(i, ...));
		xIndex = strfind(resolution, "x");
		width = strsub(resolution, 1, xIndex-1);
		height = strsub(resolution, xIndex+1, strlen(resolution));
		if ( width/height > 4/3 ) then
			resolution = resolution.." "..WIDESCREEN_TAG;
		end
		info.text = resolution;
		info.value = resolution;
		info.func = VideoOptionsResolutionPanelResolutionDropDown_OnClick;
		info.checked = nil;
		GlueDropDownMenu_AddButton(info);
	end
end

function VideoOptionsResolutionPanelResolutionDropDown_OnClick(self)
	local value = self:GetID();
	local dropdown = VideoOptionsResolutionPanelResolutionDropDown;
	GlueDropDownMenu_SetSelectedID(dropdown, value, 1);
	if ( dropdown.value == value ) then
		dropdown.newValue = nil;
	else
		dropdown.newValue = value;
	end
	VideoOptionsFrameApply:Enable();
end

function VideoOptionsResolutionPanelRefreshDropDown_OnLoad(self)
	self.cvar = "gxRefresh";

	local value = BlizzardOptionsPanel_GetCVarSafe(self.cvar);

	self.defaultValue = BlizzardOptionsPanel_GetCVarDefaultSafe(self.cvar);
	self.value = value;
	self.restart = true;

	GlueDropDownMenu_SetWidth(self, 110);
	GlueDropDownMenu_Initialize(self, VideoOptionsResolutionPanelRefreshDropDown_Initialize);
	GlueDropDownMenu_SetSelectedValue(self, value);

	self.SetValue =
		function (self, value) 
			BlizzardOptionsPanel_SetCVarSafe(self.cvar, value);
		end;
	self.GetValue =
		function (self)
			return BlizzardOptionsPanel_GetCVarSafe(self.cvar);
		end
	self.RefreshValue = 
		function (self)
			local value = BlizzardOptionsPanel_GetCVarSafe(self.cvar);
			GlueDropDownMenu_Initialize(self, VideoOptionsResolutionPanelRefreshDropDown_Initialize);
			GlueDropDownMenu_SetSelectedValue(self, value);
			self.value = value;
			self.newValue = value;
		end
end

function VideoOptionsResolutionPanelRefreshDropDown_Initialize()
	VideoOptionsResolutionPanel_GetRefreshRates(GetRefreshRates(GlueDropDownMenu_GetSelectedID(VideoOptionsResolutionPanelResolutionDropDown)));
end

function VideoOptionsResolutionPanel_GetRefreshRates(...)
	local info = GlueDropDownMenu_CreateInfo();
	if ( select("#", ...) == 1 and select(1, ...) == 0 ) then
		VideoOptionsResolutionPanelRefreshDropDownButton:Disable();
		VideoOptionsResolutionPanelRefreshDropDownLabel:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		VideoOptionsResolutionPanelRefreshDropDownText:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		return;
	end
	for i=1, select("#", ...) do
		info.text = select(i, ...)..HERTZ;
		info.func = VideoOptionsResolutionPanelRefreshDropDown_OnClick;

		if ( GlueDropDownMenu_GetSelectedValue(VideoOptionsResolutionPanelRefreshDropDown) and tonumber(GlueDropDownMenu_GetSelectedValue(VideoOptionsResolutionPanelRefreshDropDown)) == select(i, ...) ) then
			info.checked = 1;
			GlueDropDownMenu_SetText(VideoOptionsResolutionPanelRefreshDropDown, info.text);
		else
			info.checked = nil;
		end
		info.value = select(i, ...)
		GlueDropDownMenu_AddButton(info);
	end
end

function VideoOptionsResolutionPanelRefreshDropDown_OnClick(self)
	local value = self.value;
	local dropdown = VideoOptionsResolutionPanelRefreshDropDown;
	GlueDropDownMenu_SetSelectedValue(dropdown, value);
	if ( dropdown.value == value ) then
		dropdown.newValue = nil;
	else
		dropdown.newValue = value;
	end
	VideoOptionsFrameApply:Enable();
end

function VideoOptionsResolutionPanelMultiSampleDropDown_OnLoad(self)
	local value = GetCurrentMultisampleFormat();

	--self.defaultValue = 1;
	self.value = value;
	self.restart = true;

	GlueDropDownMenu_SetWidth(self, 160);
	GlueDropDownMenu_SetAnchor(self, -200, 23, "TOPRIGHT", "VideoOptionsResolutionPanelMultiSampleDropDownRight", "BOTTOMRIGHT");
	GlueDropDownMenu_Initialize(self, VideoOptionsResolutionPanelMultiSampleDropDown_Initialize);
	GlueDropDownMenu_SetSelectedID(self, value);

	self.SetValue = 
		function (self, value)
			SetMultisampleFormat(value);
		end;
	self.GetValue =
		function (self)
			return GetCurrentMultisampleFormat();
		end
	self.RefreshValue = 
		function (self)
			local value = GetCurrentMultisampleFormat();
			GlueDropDownMenu_Initialize(self, VideoOptionsResolutionPanelMultiSampleDropDown_Initialize);
			GlueDropDownMenu_SetSelectedID(self, value);
			self.value = value;
			self.newValue = value;
		end
end

function VideoOptionsResolutionPanelMultiSampleDropDown_Initialize()
	VideoOptionsResolutionPanel_GetMultisampleFormats(GetMultisampleFormats());
end

function VideoOptionsResolutionPanel_GetMultisampleFormats(...)
	local colorBits, depthBits, multiSample;
	local info = GlueDropDownMenu_CreateInfo();
	local checked;
	local index = 1;
	for i=1, select("#", ...), 3 do
		colorBits, depthBits, multiSample = select(i, ...);
		info.text = format(MULTISAMPLING_FORMAT_STRING, colorBits, depthBits, multiSample);
		info.func = VideoOptionsResolutionPanelMultiSampleDropDown_OnClick;
		
		if ( index == GlueDropDownMenu_GetSelectedID(VideoOptionsResolutionPanelMultiSampleDropDown) ) then
			checked = 1;
			GlueDropDownMenu_SetText(VideoOptionsResolutionPanelMultiSampleDropDown, info.text);
		else
			checked = nil;
		end
		info.checked = checked;
		GlueDropDownMenu_AddButton(info);
		index = index + 1;
	end
end

function VideoOptionsResolutionPanelMultiSampleDropDown_OnClick(self)
	local value = self:GetID();
	local dropdown = VideoOptionsResolutionPanelMultiSampleDropDown;
	GlueDropDownMenu_SetSelectedID(dropdown, value);
	if ( dropdown.value == value ) then
		dropdown.newValue = nil;
	else
		dropdown.newValue = value;
	end
	VideoOptionsFrameApply:Enable();
end


-- [[ Effects Panel ]] --

EffectsPanelOptions = {
	farclip = { text = "FARCLIP", minValue = OPTIONS_FARCLIP_MIN, maxValue = OPTIONS_FARCLIP_MAX, valueStep = (OPTIONS_FARCLIP_MAX - OPTIONS_FARCLIP_MIN)/10},
	TerrainMip = { text = "TERRAIN_MIP", minValue = 0, maxValue = 1, valueStep = 1, tooltip = OPTION_TOOLTIP_TERRAIN_TEXTURE, },
	particleDensity = { text = "PARTICLE_DENSITY", minValue = 0.1, maxValue = 1.0, valueStep = 0.1},
	environmentDetail = { text = "ENVIRONMENT_DETAIL", minValue = 0.5, maxValue = 1.5, valueStep = .25},
	groundEffectDensity = { text = "GROUND_DENSITY", minValue = 16, maxValue = 128, valueStep = 8},
	groundEffectDist = { text = "GROUND_RADIUS", minValue = 70, maxValue = 300, valueStep = 10 },
	BaseMip = { text = "TEXTURE_DETAIL", minValue = 0, maxValue = 1, valueStep = 1, tooltipPoint = "BOTTOMRIGHT", tooltipOwnerPoint = "TOPLEFT", },
	extShadowQuality = { text = "SHADOW_QUALITY", minValue = 0, maxValue = 5, valueStep = 1 },	
	textureFilteringMode = { text = "ANISOTROPIC", minValue = 0, maxValue = 5, valueStep = 1, tooltipPoint = "BOTTOMRIGHT", tooltipOwnerPoint = "TOPLEFT",  },
	weatherDensity = { text = "WEATHER_DETAIL", minValue = 0, maxValue = 3, valueStep = 1, tooltipPoint = "BOTTOMRIGHT", tooltipOwnerPoint = "TOPLEFT", },
	componentTextureLevel = { text = "PLAYER_DETAIL", minValue = 8, maxValue = 9, valueStep = 1, tooltipPoint = "BOTTOMRIGHT", tooltipOwnerPoint = "TOPLEFT", gameRestart = 1, tooltipRequirement = OPTION_RESTART_REQUIREMENT, },
	waterDetail = { text = "LIQUID_DETAIL", minValue = 0, maxValue = 3, valueStep = 1 },
	sunshafts = { text = "SUNSHAFTS" },
	ffxGlow = { text = "FULL_SCREEN_GLOW", },
	ffxDeath = { text = "DEATH_EFFECT", },
	projectedTextures = { text = "PROJECTED_TEXTURES", },
	quality = { text = "", minValue = 1, maxValue = 6, valueStep = 1 },
}

function VideoOptionsEffectsPanel_Default (self)
	RestoreVideoEffectsDefaults();
	for _, control in next, self.controls do
		if ( control ~= VideoOptionsEffectsPanelQualitySlider ) then
			control.newValue = nil;
		end
	end
end

function VideoOptionsEffectsPanel_Refresh (self)
	BlizzardOptionsPanel_Refresh(self);
	VideoOptionsEffectsPanel_UpdateVideoQuality();
	-- HACK: force update the quality slider because the update video quality call will change the new value
	VideoOptionsEffectsPanelQualitySlider.value = VideoOptionsEffectsPanelQualitySlider.newValue;
end

function VideoOptionsEffectsPanel_OnLoad (self)
	self.name = EFFECTS_LABEL;
	self.options = EffectsPanelOptions;
	VideoOptionsPanel_OnLoad(self, nil, nil, VideoOptionsEffectsPanel_Default, VideoOptionsEffectsPanel_Refresh);

	-- this must come AFTER the parent OnLoad because the functions will be set to defaults there
	self:SetScript("OnEvent", VideoOptionsEffectsPanel_OnEvent);
end

function VideoOptionsEffectsPanel_OnEvent (self, event, ...)
	BlizzardOptionsPanel_OnEvent(self, event, ...);

	if ( event == "SET_GLUE_SCREEN" ) then
		-- fixup value steps for the farclip control, which has an adjustable min/max
		local farclipControl = VideoOptionsEffectsPanelViewDistance;
		local minValue, maxValue = farclipControl:GetMinMaxValues();
		farclipControl:SetValueStep((maxValue - minValue) / 10);

		-- some of the values in the preset graphics quality levels aren't available on all platforms, so we
		-- need to fixup the quality levels now
		VideoOptionsEffectsPanel_UpdateVideoQuality();
		
		if ( not IsPlayerResolutionAvailable() ) then
			VideoOptionsEffectsPanelPlayerTexture:Disable();
		end
	end
end

function VideoOptionsEffectsPanel_SetVideoQuality (quality)
	if ( not quality or not GraphicsQualityLevels[quality] or VideoOptionsEffectsPanel.videoQuality == quality ) then
		return;
	elseif ( quality == VIDEO_OPTIONS_CUSTOM_QUALITY ) then
		VideoOptionsEffectsPanel.videoQuality = quality;
		VideoOptionsEffectsPanel_SetVideoQualityLabels(quality);
		return;
	end

	for control, value in next, GraphicsQualityLevels[quality] do
		control = _G[control];
		if ( control.type == CONTROLTYPE_SLIDER ) then
			control:SetDisplayValue(value);
		elseif ( control.type == CONTROLTYPE_CHECKBOX ) then
			if ( value ) then
				control:SetChecked(true);
			else
				control:SetChecked(false);
			end
			BlizzardOptionsPanel_CheckButton_SetNewValue(control);
		end
	end

	VideoOptionsEffectsPanel.videoQuality = quality;
	VideoOptionsEffectsPanel_SetVideoQualityLabels(quality);
end

function VideoOptionsEffectsPanel_SetVideoQualityLabels (quality)
	quality = quality or 5;
	VideoOptionsEffectsPanelQualityLabel:SetFormattedText(VIDEO_QUALITY_S, _G["VIDEO_QUALITY_LABEL" .. quality]);
	VideoOptionsEffectsPanelQualitySubText:SetText(_G["VIDEO_QUALITY_SUBTEXT" .. quality]);
	VideoOptionsEffectsPanelQualitySlider:SetValue(quality);
end

function VideoOptionsEffectsPanel_GetVideoQuality ()
	for quality, controls in ipairs(GraphicsQualityLevels) do 
		local mismatch = false;
		for control, value in next, controls do
			control = _G[control];
			if ( control.type == CONTROLTYPE_CHECKBOX  ) then
				local checked = control:GetChecked();
				if ( ( value and not checked ) or ( not value and checked ) ) then
					mismatch = true;
					break;
				end
			elseif ( control.GetValue ) then
				if ( not (abs(control:GetValue() - value) <= VIDEO_OPTIONS_COMPARISON_EPSILON) ) then
					-- you may have been expecting ( control:GetValue() ~= value ) but here's why we can't use that:
					-- 1) floating point error: if we set a value to 0.4 and the machine's floating point error results in the value being 0.40000000596046 instead,
					--    we want those two values to be considered equal
					-- 2) NaN/IND numbers: if for whatever reason a control gives us an NaN or IND number, any comparisons with those numbers will evaluate to false,
					--    so we phrase the comparison inversely so NaN/IND comparisons result in a mismatch
					mismatch = true;
					break;
				end
			end
		end
		if ( not mismatch ) then
			return quality;
		end
	end

	return VIDEO_OPTIONS_CUSTOM_QUALITY;
end

function VideoOptionsEffectsPanel_SetCustomQuality ()
	for control in next, GraphicsQualityLevels[1] do
		control = _G[control];
		control:Enable();
	end
end

function VideoOptionsEffectsPanel_SetPresetQuality ()
	for control in next, GraphicsQualityLevels[1] do
		control = _G[control];
		control:Disable();
	end
end

function VideoOptionsEffectsPanel_UpdateVideoQuality ()
	local quality = VideoOptionsEffectsPanel_GetVideoQuality();
	if ( quality ~= VideoOptionsEffectsPanel.videoQuality ) then
		VideoOptionsEffectsPanel_SetVideoQuality(quality);
	end
end

function VideoOptionsEffectsPanelSlider_OnValueChanged (self, value)
	self.newValue = value;
	if(self:GetParent():IsVisible()) then
		VideoOptionsEffectsPanel_UpdateVideoQuality();
		VideoOptionsFrameApply:Enable();
	end
end

--[[Stereo Options]]

VideoStereoPanelOptions = {
	gxStereoEnabled = { text = "ENABLE_STEREO_VIDEO" },
	gxStereoConvergence = { text = "DEPTH_CONVERGENCE", minValue = 0.2, maxValue = 50, valueStep = 0.1, tooltip = OPTION_STEREO_CONVERGENCE},
	gxStereoSeparation = { text = "EYE_SEPARATION", minValue = 0, maxValue = 100, valueStep = 1, tooltip = OPTION_STEREO_SEPARATION},
	gxCursor = { text = "STEREO_HARDWARE_CURSOR" },
}

function VideoOptionsStereoPanel_OnLoad (self)
	self.name = STEREO_VIDEO_LABEL;
	self.options = VideoStereoPanelOptions;
	if ( IsStereoVideoAvailable() ) then
		VideoOptionsPanel_OnLoad(self);
	end
	self:RegisterEvent("SET_GLUE_SCREEN");
	self:SetScript("OnEvent", VideoOptionsStereoPanel_OnEvent);
end

function VideoOptionsStereoPanel_Default (self)
	RestoreVideoStereoDefaults();
	for _, control in next, self.controls do
		if ( control.defaultValue and control.value ~= control.defaultValue ) then
			control:SetValue(control.defaultValue);
		end
		control.newValue = nil;
	end
end

function VideoOptionsStereoPanel_OnEvent(self, event, ...)
	BlizzardOptionsPanel_OnEvent(self, event, ...);
	
	if ( event == "SET_GLUE_SCREEN" ) then
		-- don't allow systems that don't support features to enable them
		local anisotropic, pixelShaders, vertexShaders, trilinear, buffering, maxAnisotropy, hardwareCursor = GetVideoCaps();
		if ( not hardwareCursor ) then
			VideoOptionsStereoPanelHardwareCursor:SetChecked(false);
			VideoOptionsStereoPanelHardwareCursor:Disable();
		end
		VideoOptionsStereoPanelHardwareCursor.SetChecked =
			function (self, checked)
				local anisotropic, pixelShaders, vertexShaders, trilinear, buffering, maxAnisotropy, hardwareCursor = GetVideoCaps();
				if ( not hardwareCursor ) then
					checked = false;
				end
				getmetatable(self).__index.SetChecked(self, checked);
			end
		VideoOptionsStereoPanelHardwareCursor.Enable =
			function (self)
				local anisotropic, pixelShaders, vertexShaders, trilinear, buffering, maxAnisotropy, hardwareCursor = GetVideoCaps();
				if ( not hardwareCursor ) then
					return;
				end
				getmetatable(self).__index.Enable(self);
				local text = _G[self:GetName().."Text"];
				local fontObject = text:GetFontObject();
				_G[self:GetName().."Text"]:SetTextColor(fontObject:GetTextColor());
			end
	end
end
