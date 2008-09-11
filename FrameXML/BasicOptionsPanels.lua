CONTROLTYPE_CHECKBOX = 1;
CONTROLTYPE_DROPDOWN = 2;
CONTROLTYPE_SLIDER = 3;

OPTIONS_FARCLIP_MIN = 177;
OPTIONS_FARCLIP_MAX = 1277;

VIDEO_OPTIONS_CUSTOM_QUALITY = 5;

function VideoOptionsPanel_Okay (self)
	for _, control in next, self.controls do
		if ( control.newValue ) then
			control:SetValue(control.newValue);
			control.value = control.newValue;
			control.newValue = nil;
			if ( control.restart ) then
				InterfaceOptionsFrame.gxRestart = true;
			end
		end
	end
end

function VideoOptionsPanel_Cancel (self)
	for _, control in next, self.controls do
		control.newValue = nil;
		if ( control.value ) then
			control:SetValue(control.value);
		end
	end
end

function VideoOptionsPanel_Default (self)
	for _, control in next, self.controls do
		if ( control.value ~= control.defaultValue ) then
			if ( control:Default() ) then
				InterfaceOptionsFrame.gxRestart = true;
			end
		end
	end
end

function AudioOptionsPanel_Okay (self)
	for _, control in next, self.controls do
		if ( control.restart and control.currValue ~= control.value ) then
			InterfaceOptionsFrame.audioRestart = true;
		end
		control.currValue = control.value;
	end
end

function AudioOptionsPanel_Cancel (self)
	for _, control in next, self.controls do
		if ( control.value and control.currValue and ( control.value ~= control.currValue ) ) then
			control:SetValue(control.currValue);
		end
	end
end

function AudioOptionsPanel_Default (self)
	for _, control in next, self.controls do
		control:SetValue(control.defaultValue);
		if ( control.restart ) then
			InterfaceOptionsFrame.audioRestart = true;
		end
	end
end

-- [[ General functions ]] --

function BasicOptionsPanel_RegisterControl (control, parentFrame)
	if ( ( not parentFrame ) or ( not control ) ) then
		return;
	end
	
	parentFrame.controls = parentFrame.controls or {};
	
	tinsert(parentFrame.controls, control);
	
	local value;
	if ( control.cvar ) then
		-- Wait and setup the control after CVars are loaded using the panel's OnEvent handler
	elseif ( control.GetValue ) then
		if ( control.type == CONTROLTYPE_CHECKBOX ) then
			value = ((control:GetValue() and "1") or "0");
			control.value = value;
			if ( control.uvar ) then
				setglobal(control.uvar, value);
			end
			
			control.SetValue = function(self, value) self.value = value; if ( self.uvar ) then setglobal(self.uvar, value); end if ( self.setFunc ) then self.setFunc(value) end end;
			control.Disable = function (self) getmetatable(self).__index.Disable(self) getglobal(self:GetName().."Text"):SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b) end;
			control.Enable = function (self) getmetatable(self).__index.Enable(self) getglobal(self:GetName().."Text"):SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b) end;
		end
	end
	
	if ( control.type == CONTROLTYPE_SLIDER ) then
		control.Disable = OptionsFrame_DisableSlider
		control.Enable = OptionsFrame_EnableSlider
	end
end

function BasicOptionsPanel_SetupDependentControl (dependency, control)
	if ( not dependency ) then
		return;
	end
	
	dependency.dependentControls = dependency.dependentControls or {};
	tinsert(dependency.dependentControls, control);
	
	if ( control.type == CONTROLTYPE_CHECKBOX ) then
		control.Disable = function (self) getmetatable(self).__index.Disable(self) getglobal(self:GetName().."Text"):SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b) end;
		control.Enable = function (self) getmetatable(self).__index.Enable(self) getglobal(self:GetName().."Text"):SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b) end;
	elseif ( control.type == CONTROLTYPE_DROPDOWN ) then
		control.Disable = UIDropDownMenu_DisableDropDown;
		control.Enable = UIDropDownMenu_EnableDropDown;
	end
end

-- [[ Video functions ]] --

local ALT_KEY = "altkey";
local CONTROL_KEY = "controlkey";
local SHIFT_KEY = "shiftkey";
local NO_KEY = "none";

function VideoOptionsPanel_SetupControl (control)
	if ( control.cvar ) then
		if ( control.type == CONTROLTYPE_CHECKBOX ) then			
			local value = GetCVar(control.cvar);
			control.value = value;
			if ( control.uvar ) then
				setglobal(control.uvar, value);
			end
			
			control.GetValue = function(self) return GetCVar(self.cvar); end
			control.SetValue = function(self, value) self.value = value; SetCVar(self.cvar, value, self.event); if ( self.uvar ) then setglobal(self.uvar, value) end if ( self.setFunc ) then self.setFunc(value) end end
			control.Disable = function (self) getmetatable(self).__index.Disable(self) getglobal(self:GetName().."Text"):SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b) end;
			control.Enable = function (self) getmetatable(self).__index.Enable(self) getglobal(self:GetName().."Text"):SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b) end;
		elseif ( control.type == CONTROLTYPE_SLIDER ) then
			local value;
			if ( control.cvar ) then
				value = GetCVar(control.cvar);
			elseif ( control.GetCurrentValue ) then
				value = control:GetCurrentValue();
			else
				value = control:GetValue();
			end
			
			control.value = value;
			control:SetValue(value);
			control.Disable = OptionsFrame_DisableSlider
			control.Enable = OptionsFrame_EnableSlider
		end
	end
	if ( control.setFunc ) then
		control.setFunc(control.value);
	end
end

function VideoOptionsPanel_OnEvent (frame, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		if ( frame.options and frame.controls ) then
			local entry;
			for i, control in next, frame.controls do
				entry = frame.options[(control.cvar or control.label)];
				if ( entry ) then
					if ( entry.text ) then
						control.tooltipText = (getglobal("OPTION_TOOLTIP_" .. gsub(entry.text, "_TEXT$", "")) or entry.tooltip);
						getglobal(control:GetName() .. "Text"):SetText(getglobal(entry.text) or entry.text);
					end
					
					if ( control.type == CONTROLTYPE_SLIDER ) then
						control:Enable();
						control:SetMinMaxValues(entry.minValue, entry.maxValue);
						control:SetValueStep(entry.valueStep);
					end
					
					if ( control.cvar ) then
						control.defaultValue = GetCVarDefault(control.cvar);
						VideoOptionsPanel_SetupControl(control);
					else
					control.defaultValue = control.defaultValue or entry.default;
					end
					
					control.event = entry.event or entry.text;
				end
			end
		end
		frame:UnregisterEvent(event);
	end
end

function VideoOptionsPanel_OnLoad (frame)
	InterfaceOptionsFrame_SetupBlizzardPanel(frame);
	InterfaceOptions_AddCategory(frame);
	frame:RegisterEvent("PLAYER_ENTERING_WORLD");
	frame:SetScript("OnEvent", VideoOptionsPanel_OnEvent);
end

function VideoOptionsPanel_OnShow (panel)
	-- This function needs to be reworked.

	local value;
	
	if ( not panel.controls ) then
		return;
	end
	
	for _, control in next, panel.controls do
		if ( control.cvar ) then
			if ( control.type == CONTROLTYPE_CHECKBOX ) then
				value = GetCVar(control.cvar);
				
				if ( not control.invert ) then
					if ( value == "1" ) then
						control:SetChecked(true);
					else
						control:SetChecked(false);
					end
				else
					if ( value == "0" ) then
						control:SetChecked(true);
					else
						control:SetChecked(false);
					end
				end
				
				if ( control.dependentControls ) then
					if ( control:GetChecked() ) then
						for _, depControl in next, control.dependentControls do
							depControl:Enable();
						end
					else
						for _, depControl in next, control.dependentControls do
							depControl:Disable();
						end
					end
				end
			elseif ( control.type == CONTROLTYPE_SLIDER ) then
				-- Don't do anything.
			end
		elseif ( control.GetValue ) then
			if ( control.type == CONTROLTYPE_CHECKBOX ) then
				value = tostring(control:GetValue());
				
				if ( not control.invert ) then
					if ( value == "1" ) then
						control:SetChecked(true);
					else
						control:SetChecked(false);
					end
				else
					if ( value == "0" ) then
						control:SetChecked(true);
					else
						control:SetChecked(false);
					end
				end
				
				if ( control.dependentControls ) then
					if ( control:GetChecked() ) then
						for _, depControl in next, control.dependentControls do
							depControl:Enable();
						end
					else
						for _, depControl in next, control.dependentControls do
							depControl:Disable();
						end
					end
				end
			end
		end
	end
end

function VideoOptionsPanel_CheckButton_OnClick (checkButton)
	local setting = "0";
	if ( checkButton:GetChecked() ) then
		if ( not checkButton.invert ) then
			setting = "1"
		end
	elseif ( checkButton.invert ) then
		setting = "1"
	end 
	
	if ( setting == checkButton.value ) then
		checkButton.newValue = nil;
	else
		checkButton.newValue = setting;
	end
	
	if ( checkButton.setFunc ) then
		checkButton:setFunc(setting);
	end
	
	if ( checkButton.dependentControls ) then
		if ( checkButton:GetChecked() ) then
			for _, control in next, checkButton.dependentControls do
				control:Enable();
			end
		else
			for _, control in next, checkButton.dependentControls do
				control:Disable();
			end
		end
	end
end

-- [[ Resolution Options Panel ]] --

ResolutionPanelOptions = {
	useUiScale = { text = "USE_UISCALE" },
	gxVSync = { text = "VERTICAL_SYNC" },
	gxTripleBuffer = { text = "TRIPLE_BUFFER" },
	gxCursor = { text = "HARDWARE_CURSOR" },
	gxWindow = { text = "WINDOWED_MODE" },
	gxMaximize = { text = "WINDOWED_MAXIMIZED" },
	windowResizeLock = { text = "WINDOW_LOCK" },
	desktopGamma = { text = "DESKTOP_GAMMA" },
	gamma = { text = "GAMMA", minValue = -.5, maxValue = .5, valueStep = .1 },
	quality = { text = "", minValue = 1, maxValue = 5, valueStep = 1 },
	uiscale = { text = "", minValue = .64, maxValue = 1, valueStep = .01 },
}

function VideoOptionsPanel_OnEvent (frame, event, ...)
	frame:UnregisterEvent(event);	
	if ( frame.options and frame.controls ) then
		local entry;
		for i, control in next, frame.controls do
			entry = frame.options[(control.cvar or control.label)];
			if ( entry ) then
				if ( entry.text ) then
					control.tooltipText = (getglobal("OPTION_TOOLTIP_" .. gsub(entry.text, "_TEXT$", "")) or entry.tooltip);
					getglobal(control:GetName() .. "Text"):SetText(getglobal(entry.text) or entry.text);
				end
				
				if ( control.cvar ) then
					control.defaultValue = GetCVarDefault(control.cvar);
					VideoOptionsPanel_SetupControl(control)
				else
				control.defaultValue = control.defaultValue or entry.default;
				end
				
				control.event = entry.event or entry.text;
				
				if ( control.type == CONTROLTYPE_SLIDER ) then
					OptionsFrame_EnableSlider(control);
					control:SetMinMaxValues(entry.minValue, entry.maxValue);
					control:SetValueStep(entry.valueStep);
					if ( control.value ) then
						control:SetValue(control.value);
					end
				end
			end
		end
	end
end

function VideoOptionsPanel_OnLoad (frame)
	frame.okay = VideoOptionsPanel_Okay;
	frame.cancel = VideoOptionsPanel_Cancel;
	frame.default = VideoOptionsPanel_Default;
	InterfaceOptions_AddCategory(frame);
	
	frame:RegisterEvent("PLAYER_ENTERING_WORLD");
	frame:SetScript("OnEvent", VideoOptionsPanel_OnEvent);
end

function VideoOptionsResolutionPanelResolutionDropDown_OnLoad(self)
	local currValue = GetCurrentResolution();
	UIDropDownMenu_Initialize(self, VideoOptionsResolutionPanelResolutionDropDown_Initialize);
	UIDropDownMenu_SetSelectedID(self, currValue, 1);
	
	self.value = currValue;
	self.restart = true;
	UIDropDownMenu_SetWidth(self, 140);
	self.SetValue = 
		function (self, value) 
			self.value = value;
			SetScreenResolution(value);
		end;
	self.GetValue =
		function (self)
			return GetCurrentResolution();
		end
end

function VideoOptionsResolutionPanelResolutionDropDown_Initialize()
	VideoOptionsResolutionPanelResolutionDropDown_LoadResolutions(GetScreenResolutions());	
end

function VideoOptionsResolutionPanelResolutionDropDown_LoadResolutions(...)
	local info = UIDropDownMenu_CreateInfo();
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
		info.func = VideoOptionsResolutionPanelResolutionButton_OnClick;
		info.checked = nil;
		UIDropDownMenu_AddButton(info);
	end
end

function VideoOptionsResolutionPanelResolutionButton_OnClick(self)
	local value = self:GetID();
	local dropdown = VideoOptionsResolutionPanelResolutionDropDown;
	UIDropDownMenu_SetSelectedID(VideoOptionsResolutionPanelResolutionDropDown, value, 1);
	if ( dropdown.value == value ) then
		dropdown.newValue = nil;
	else
		dropdown.newValue = value;
	end
	
end

function VideoOptionsResolutionPanelRefreshDropDown_OnLoad(self)
	local currValue = GetCVar("gxRefresh");
	UIDropDownMenu_SetSelectedValue(self, currValue);
	UIDropDownMenu_Initialize(self, VideoOptionsResolutionPanelRefreshDropDown_Initialize);
	self.value = currValue;
	self.restart = true;
	UIDropDownMenu_SetWidth(self, 140);
	self.SetValue = 
		function (self, value) 
			self.value = value;
			SetCVar("gxRefresh", value);
		end;
	self.GetValue =
		function (self)
			return GetCVar("gxRefresh");
		end
	-- Add self.default here
end

function VideoOptionsResolutionPanelRefreshDropDown_Initialize()
	VideoOptionsResolutionPanel_GetRefreshRates(GetRefreshRates());
end

function VideoOptionsResolutionPanel_GetRefreshRates(...)
	local info = UIDropDownMenu_CreateInfo();
	local checked;
	if ( select("#", ...) == 1 and select(1, ...) == 0 ) then
		VideoOptionsResolutionPanelRefreshDropDownButton:Disable();
		VideoOptionsResolutionPanelRefreshDropDownLabel:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		VideoOptionsResolutionPanelRefreshDropDownText:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		return;
	end
	for i=1, select("#", ...) do
		info.text = select(i, ...)..HERTZ;
		info.func = VideoOptionsResolutionPanelRefreshDropDown_OnClick;
		
		if ( UIDropDownMenu_GetSelectedValue(VideoOptionsResolutionPanelRefreshDropDown) and tonumber(UIDropDownMenu_GetSelectedValue(VideoOptionsResolutionPanelRefreshDropDown)) == select(i, ...) ) then
			checked = 1;
			UIDropDownMenu_SetText(VideoOptionsResolutionPanelRefreshDropDown, info.text);
		else
			checked = nil;
		end
		info.value = select(i, ...)
		info.checked = checked;
		UIDropDownMenu_AddButton(info);
	end
end

function VideoOptionsResolutionPanelRefreshDropDown_OnClick(self)
	local value = self.value;
	local dropdown = VideoOptionsResolutionPanelRefreshDropDown;
	UIDropDownMenu_SetSelectedValue(dropdown, value);
	if ( dropdown.value == value ) then
		dropdown.newValue = nil;
	else
		dropdown.newValue = value;
	end
end

function VideoOptionsResolutionPanelMultiSampleDropDown_OnLoad(self)
	local value = GetCurrentMultisampleFormat();
	UIDropDownMenu_SetSelectedID(self, value);
	UIDropDownMenu_Initialize(self, VideoOptionsResolutionPanelMultiSampleDropDown_Initialize);
	self.defaultValue = 1;
	self.value = value;
	self.restart = true;
	UIDropDownMenu_SetWidth(self, 160);
	UIDropDownMenu_SetAnchor(self, -5, 23, "TOPRIGHT", "VideoOptionsResolutionPanelMultiSampleDropDownRight", "BOTTOMRIGHT");
	self.SetValue = 
		function (self, value) 
			self.value = value;
			SetMultisampleFormat(value);
		end;
	self.GetValue =
		function (self)
			return GetCurrentMultisampleFormat();
		end
end

function VideoOptionsResolutionPanelMultiSampleDropDown_Initialize()
	VideoOptionsResolutionPanel_GetMultisampleFormats(GetMultisampleFormats());
end

function VideoOptionsResolutionPanel_GetMultisampleFormats(...)
	local colorBits, depthBits, multiSample;
	local info = UIDropDownMenu_CreateInfo();
	local checked;
	local index = 1;
	for i=1, select("#", ...), 3 do
		colorBits, depthBits, multiSample = select(i, ...);
		info.text = format(MULTISAMPLING_FORMAT_STRING, colorBits, depthBits, multiSample);
		info.func = VideoOptionsResolutionPanelMultiSampleDropDown_OnClick;
		
		if ( index == UIDropDownMenu_GetSelectedID(VideoOptionsResolutionPanelMultiSampleDropDown) ) then
			checked = 1;
			UIDropDownMenu_SetText(VideoOptionsResolutionPanelMultiSampleDropDown, info.text);
		else
			checked = nil;
		end
		info.checked = checked;
		UIDropDownMenu_AddButton(info);
		index = index + 1;
	end
end

function VideoOptionsResolutionPanelMultiSampleDropDown_OnClick(self)
	local value = self:GetID();
	local dropdown = VideoOptionsResolutionPanelMultiSampleDropDown;
	UIDropDownMenu_SetSelectedID(dropdown, value);
	if ( dropdown.value == value ) then
		dropdown.newValue = nil;
	else
		dropdown.newValue = value;
	end
end

function VideoOptionsResolutionPanel_UpdateGammaControls ()
	local value = "0";
	if ( VideoOptionsResolutionPanelWindowed:GetChecked() ) then
		value = "1";
		VideoOptionsResolutionPanelDesktopGamma:SetChecked();
		VideoOptionsResolutionPanelDesktopGamma:Disable();
		OptionsFrame_DisableSlider(VideoOptionsResolutionPanelGammaSlider);
	else
		VideoOptionsResolutionPanelDesktopGamma:Enable();
		if ( VideoOptionsResolutionPanelDesktopGamma:GetChecked() ) then
			OptionsFrame_DisableSlider(VideoOptionsResolutionPanelGammaSlider);
			value = "1";
		else
			OptionsFrame_EnableSlider(VideoOptionsResolutionPanelGammaSlider);
		end
	end
	-- SetCVar("desktopGamma", value);
end

-- [[ Effects Options Panel ]] --

function VideoOptionsPanel_SetVideoQuality (value)
	if ( not value or not GraphicsQualityLevels[value] or InterfaceOptionsFrame.videoQuality == value ) then
		return;
	elseif ( value == VIDEO_OPTIONS_CUSTOM_QUALITY ) then
		InterfaceOptionsFrame.videoQuality = value
		VideoOptionsPanel_SetVideoQualityLabels (value);	
		return
	end
	
	for control, value in next, GraphicsQualityLevels[value] do
		control = getglobal(control);
		if ( control.type == CONTROLTYPE_SLIDER ) then
			control:oldSetValue(value);
		elseif ( control.type == CONTROLTYPE_CHECKBOX ) then
			if ( value ) then
				control:SetChecked(true);
			else
				control:SetChecked(false);
			end
			VideoOptionsPanel_CheckButton_OnClick(control);
		end
	end

	VideoOptionsPanel_SetVideoQualityLabels (value);	
	InterfaceOptionsFrame.videoQuality = value;
end

function VideoOptionsPanel_SetVideoQualityLabels (value)
	value = value or 5;
	VideoOptionsEffectsPanelQualityLabel:SetText(format(VIDEO_QUALITY_S, getglobal("VIDEO_QUALITY_LABEL" .. value)));
	VideoOptionsEffectsPanelQualitySubText:SetText(getglobal("VIDEO_QUALITY_SUBTEXT" .. value));
	VideoOptionsEffectsPanelQualitySlider:oldSetValue(value);
end

function VideoOptionsPanel_GetVideoQuality ()
	for quality, controls in ipairs(GraphicsQualityLevels) do 
		local mismatch = false;
		for control, value in next, controls do
			control = getglobal(control);
			if ( control.type == CONTROLTYPE_SLIDER ) then
				if ( control:GetValue() ~= value ) then
					mismatch = true;
					break;
				end
			elseif ( not control.GetValue and control.type == CONTROLTYPE_CHECKBOX  ) then
				-- We're in the midst of loading...
			else
				local currValue = control:GetChecked()
				if ( ( value and not currValue ) or ( not value and currValue ) ) then
					mismatch = true;
					break;
				end			
			end
		end
		if ( not mismatch ) then
			return quality;
		end
	end

	return VIDEO_OPTIONS_CUSTOM_QUALITY
end

EffectsPanelOptions = {
	farclip = { text = "FARCLIP", minValue = OPTIONS_FARCLIP_MIN, maxValue = OPTIONS_FARCLIP_MAX, valueStep = (OPTIONS_FARCLIP_MAX - OPTIONS_FARCLIP_MIN)/10},
	TerrainMip = { text = "TERRAIN_MIP", minValue = 0, maxValue = 1, valueStep = 1, tooltip = OPTION_TOOLTIP_TERRAIN_TEXTURE},
	spellEffectLevel = { text = "SPELL_DETAIL", minValue = 0, maxValue = 9, valueStep = 1},
	extShadowQuality = { text = "SHADOW_QUALITY", minValue = 0, maxValue = 4, valueStep = 1},
	environmentDetail = { text = "ENVIRONMENT_DETAIL", minValue = 0.5, maxValue = 1.5, valueStep = .25},
	groundEffectDensity = { text = "GROUND_DENSITY", minValue = 16, maxValue = 64, valueStep = 8},
	groundEffectDist = { text = "GROUND_RADIUS", minValue = 70, maxValue = 140, valueStep = 10 },
	BaseMip = { text = "TEXTURE_DETAIL", minValue = 0, maxValue = 1, valueStep = 1},
	textureFilteringMode = { text = "ANISOTROPIC", minValue = 0, maxValue = 5, valueStep = 1},
	weatherDensity = { text = "WEATHER_DETAIL", minValue = 0, maxValue = 3, valueStep = 1},
	specular = { text = "TERRAIN_HIGHLIGHTS", },
	ffxGlow = { text = "FULL_SCREEN_GLOW", },
	ffxDeath = { text = "DEATH_EFFECT", },
	quality = { text = "", minValue = 1, maxValue = 5, valueStep = 1 },
}

function VideoOptionsEffectsPanel_SetCustomQuality ()
	for control in next, GraphicsQualityLevels[1] do
		control = getglobal(control);
		control:Enable();
	end
end

function VideoOptionsEffectsPanel_SetPresetQuality ()
	for control in next, GraphicsQualityLevels[1] do
		control = getglobal(control);
		control:Disable();
	end
end

function VideoOptionsEffectsPanel_UpdateVideoQuality ()
	local quality = VideoOptionsPanel_GetVideoQuality();
	if ( quality ~= InterfaceOptionsFrame.videoQuality ) then
		VideoOptionsPanel_SetVideoQuality(quality);
	end
end

-- [[ Sound Options Panel ]] --

SoundPanelOptions = {
	Sound_EnableErrorSpeech = { text = "ENABLE_ERROR_SPEECH" },
	Sound_EnableMusic = { text = "ENABLE_MUSIC" },
	Sound_EnableAmbience = { text = "ENABLE_AMBIENCE" },
	Sound_EnableSFX = { text = "ENABLE_SOUNDFX" },
	Sound_EnableAllSound = { text = "ENABLE_SOUND" },
	Sound_ListenerAtCharacter = { text = "ENABLE_SOUND_AT_CHARACTER" },
	Sound_EnableEmoteSounds = { text = "ENABLE_EMOTE_SOUNDS" },
	Sound_ZoneMusicNoDelay = { text = "ENABLE_MUSIC_LOOPING" },
	Sound_EnableSoundWhenGameIsInBG = { text = "ENABLE_BGSOUND" },
	Sound_EnableReverb = { text = "ENABLE_REVERB" },
	Sound_EnableHardware = { text = "ENABLE_HARDWARE" },
	Sound_EnableSoftwareHRTF = { text = "ENABLE_SOFTWARE_HRTF" },
	Sound_EnableDSPEffects = { text = "ENABLE_DSP_EFFECTS" },
	Sound_SFXVolume = { text = "SOUND_VOLUME", minValue = 0, maxValue = 1, valueStep = 0.1, },
	Sound_MusicVolume = { text = "MUSIC_VOLUME", minValue = 0, maxValue = 1, valueStep = 0.1, },
	Sound_AmbienceVolume = { text = "AMBIENCE_VOLUME", minValue = 0, maxValue = 1, valueStep = 0.1, },
	Sound_MasterVolume = { text = "MASTER_VOLUME", minValue = 0, maxValue = 1, valueStep = 0.1, },
	Sound_NumChannels = { text = "SOUND_CHANNELS", minValue = 32, maxValue = 64, valueStep = 32, },
	Sound_OutputQuality = { text = "SOUND_QUALITY", minValue = 0, maxValue = 2, valueStep = 1 },
}

function AudioOptionsSoundPanel_ToggleMusic()
	if ( GetCVar("Sound_EnableMusic") == "1" ) then
		SetCVar("Sound_EnableMusic", 0);
	else
		SetCVar("Sound_EnableMusic", 1);
	end
	if ( AudioOptionsSoundPanel:IsShown() ) then
		BlizzardOptionsPanel_OnShow(AudioOptionsSoundPanel);
	end
end

function AudioOptionsSoundPanel_ToggleSound()
	if ( GetCVar("Sound_EnableSFX") == "0" ) then
		SetCVar("Sound_EnableSFX", 1);
		SetCVar("Sound_EnableAmbience", 1);
	else
		SetCVar("Sound_EnableSFX", 0);
		SetCVar("Sound_EnableAmbience", 0);
	end
	if ( AudioOptionsSoundPanel:IsShown() ) then
		BlizzardOptionsPanel_OnShow(AudioOptionsSoundPanel);
	end
end

function AudioOptionsSoundPanel_MasterVolumeUp()
	local masterVolume = GetCVar("Sound_MasterVolume") + 0;
	if ( masterVolume < 1.0 ) then
		masterVolume = masterVolume + 0.1;
		SetCVar("Sound_MasterVolume", masterVolume);
	end
	if ( AudioOptionsSoundPanel:IsShown() ) then
		BlizzardOptionsPanel_OnShow(AudioOptionsSoundPanel);
	end
end

function AudioOptionsSoundPanel_MasterVolumeDown()
	local masterVolume = GetCVar("Sound_MasterVolume") + 0;
	if ( masterVolume > 0.0 ) then
		masterVolume = masterVolume - 0.1;
		SetCVar("Sound_MasterVolume", masterVolume);
	end
	if ( AudioOptionsSoundPanel:IsShown() ) then
		BlizzardOptionsPanel_OnShow(AudioOptionsSoundPanel);
	end
end

function AudioOptionsSoundPanelHardwareDropDown_OnLoad (self)
	local selectedDriverIndex = GetCVar("Sound_OutputDriverIndex");
	local deviceName = Sound_GameSystem_GetOutputDriverNameByIndex(tonumber(selectedDriverIndex));

	UIDropDownMenu_SetWidth(self, 136)
	UIDropDownMenu_Initialize(self, AudioOptionsSoundPanelHardwareDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(self, selectedDriverIndex, 1);
	UIDropDownMenu_SetText(self, deviceName);
	self.currValue = selectedDriverIndex;
	self.value = selectedDriverIndex;
	self.restart = true;
	
	self.SetValue = 
		function (self, value) 
			self.value = value;
			UIDropDownMenu_SetSelectedValue(AudioOptionsSoundPanelHardwareDropDown, value);
			SetCVar("Sound_OutputDriverIndex", self.value);
			InterfaceOptionsFrame_AudioRestart();
		end;
	self.GetValue =
		function (self)
			return GetCurrentMultisampleFormat();
		end
end

function AudioOptionsSoundPanelHardwareDropDown_Initialize()
	local selectedDriverIndex = GetCVar("Sound_OutputDriverIndex");
	local num = Sound_GameSystem_GetNumOutputDrivers();
	local info = UIDropDownMenu_CreateInfo();
	for index=0,num-1,1 do
		local description = Sound_GameSystem_GetOutputDriverNameByIndex(index);
		info.text = description;
		info.value = index;
		info.checked = nil;
		if (index == tonumber(selectedDriverIndex)) then
			info.checked = 1;
		end
		info.func = AudioOptionsSoundPanelHardwareDropDown_OnClick;
		
		UIDropDownMenu_AddButton(info);
	end
end

function AudioOptionsSoundPanelHardwareDropDown_OnClick(self)
	AudioOptionsSoundPanelHardwareDropDown:SetValue(self.value);
end

VoicePanelOptions = {
	EnableVoiceChat = { text = "ENABLE_VOICECHAT" },
	EnableMicrophone = { text = "ENABLE_MICROPHONE" },
	OutboundChatVolume = { text = "VOICE_INPUT_VOLUME", minValue = 0.25, maxValue = 2.5, valueStep = 0.05 },
	InboundChatVolume = { text = "VOICE_OUTPUT_VOLUME", minValue = 0, maxValue = 1, valueStep = 0.01 },
	ChatSoundVolume = { text = "", minValue = 0, maxValue = 1, valueStep = 0.01 },
	ChatMusicVolume = { text = "", minValue = 0, maxValue = 1, valueStep = 0.01 },
	ChatAmbienceVolume = { text = "", minValue = 0, maxValue = 1, valueStep = 0.01 },
	PushToTalkSound = { text = "PUSHTOTALK_SOUND_TEXT" },
	VoiceActivationSensitivity = { text = "VOICE_ACTIVATION_SENSITIVITY", minValue = 0, maxValue = 1, valueStep = 0.02 },
}

local AudioOptionsVoicePanelDisableList = 
{	
	AudioOptionsVoicePanelChatMode1Label = NORMAL_FONT_COLOR,
	AudioOptionsVoicePanelAudioLabel = NORMAL_FONT_COLOR,
	AudioOptionsVoicePanelAudioDescription = HIGHLIGHT_FONT_COLOR,
	AudioOptionsVoicePanelAudioOff = HIGHLIGHT_FONT_COLOR,
	AudioOptionsVoicePanelAudioNormal = HIGHLIGHT_FONT_COLOR,
	AudioOptionsVoicePanelSpeakerVolumeLabel = NORMAL_FONT_COLOR,
	AudioOptionsVoicePanelSoundFadeLabel = NORMAL_FONT_COLOR,
	AudioOptionsVoicePanelMusicFadeLabel = NORMAL_FONT_COLOR,
	AudioOptionsVoicePanelAmbienceFadeLabel = NORMAL_FONT_COLOR,
};

local AudioOptionsVoicePanelFrameMicrophoneList = 
{
	AudioOptionsVoicePanelMicrophoneVolumeLabel = NORMAL_FONT_COLOR,
	AudioOptionsVoicePanelMicTestText = NORMAL_FONT_COLOR,
	PlayLoopbackSoundButtonTexture = NORMAL_FONT_COLOR,
	RecordLoopbackSoundButtonTexture = RED_FONT_COLOR,
};

function AudioOptionsVoicePanel_OnEvent (self, event, ...)
	self:UnregisterEvent(event);
	if ( IsVoiceChatAllowedByServer() ) then
		InterfaceOptions_AddCategory(self, nil, 4);
		BlizzardOptionsPanel_OnEvent(self, event, ...);	
	end
end

function AudioOptionsVoicePanel_OnLoad (self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:SetScript("OnEvent", AudioOptionsVoicePanel_OnEvent);
	
	local entry;
	for i, control in next, self.controls do
		entry = self.options[(control.cvar or control.label)];
		if ( entry ) then
			if ( entry.text ) then
				control.tooltipText = (getglobal("OPTION_TOOLTIP_" .. gsub(entry.text, "_TEXT$", "")) or entry.tooltip);
				getglobal(control:GetName() .. "Text"):SetText(getglobal(entry.text) or entry.text);
			end
			
			if ( control.cvar ) then
				control.defaultValue = GetCVarDefault(control.cvar);
			else
				control.defaultValue = control.defaultValue or entry.default;
			end
				
			control.event = entry.event or entry.text;
				
			if ( control.type == CONTROLTYPE_SLIDER ) then
				OptionsFrame_EnableSlider(control);
				control:SetMinMaxValues(entry.minValue, entry.maxValue);
				control:SetValueStep(entry.valueStep);
			end
		end
	end
	
	AudioOptionsVoicePanelBindingType_Update()
end

function AudioOptionsVoicePanel_UpdateControls ()
	if ( VoiceIsDisabledByClient() ) then
		--Comsat is disabled either because the computer is way old (No SSE) or another copy of WoW is running.
		SetCVar("EnableVoiceChat", "0");
		AudioOptionsVoicePanelEnableVoice:Hide();
		AudioOptionsVoicePanelDisabledMessage:Show();
	elseif ( not AudioOptionsVoicePanelEnableVoice:IsShown() ) then
		--Pretty certain this won't be changing dynamically, but better safe than sorry.
		AudioOptionsVoicePanelEnableVoice:Show();
		AudioOptionsVoicePanelDisabledMessage:Hide();
	end
	if ( GetCVar("EnableVoiceChat") == "1" ) then
		UIDropDownMenu_EnableDropDown(AudioOptionsVoicePanelOutputDeviceDropDown)
		UIDropDownMenu_EnableDropDown(AudioOptionsVoicePanelChatModeDropDown)
		
		AudioOptionsVoicePanelChatMode1KeyBindingButton:Enable();
		
		for i, value in pairs(AudioOptionsVoicePanelDisableList) do
			getglobal(i):SetVertexColor(value.r, value.g, value.b);
		end

		OptionsFrame_EnableSlider(AudioOptionsVoicePanelVoiceActivateSlider);
		OptionsFrame_EnableSlider(AudioOptionsVoicePanelSpeakerVolume);
		OptionsFrame_EnableSlider(AudioOptionsVoicePanelSoundFade);
		OptionsFrame_EnableSlider(AudioOptionsVoicePanelMusicFade);
		OptionsFrame_EnableSlider(AudioOptionsVoicePanelAmbienceFade);
		
		OptionsFrame_EnableCheckBox(AudioOptionsVoicePanelEnableMicrophone);
		OptionsFrame_EnableCheckBox(AudioOptionsVoicePanelPushToTalkSound);
		AudioOptionsVoicePanel_UpdateMicrophoneControls();
		
		if ( ChannelPullout:IsShown() ) then
			ChannelPullout_ToggleDisplay();
		end
	else
		UIDropDownMenu_DisableDropDown(AudioOptionsVoicePanelOutputDeviceDropDown)
		UIDropDownMenu_DisableDropDown(AudioOptionsVoicePanelChatModeDropDown)
		
		AudioOptionsVoicePanelChatMode1KeyBindingButton:Disable();
		
		for i, value in pairs(AudioOptionsVoicePanelDisableList) do
			getglobal(i):SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		end

		OptionsFrame_DisableSlider(AudioOptionsVoicePanelVoiceActivateSlider);
		OptionsFrame_DisableSlider(AudioOptionsVoicePanelSpeakerVolume);
		OptionsFrame_DisableSlider(AudioOptionsVoicePanelSoundFade);
		OptionsFrame_DisableSlider(AudioOptionsVoicePanelMusicFade);
		OptionsFrame_DisableSlider(AudioOptionsVoicePanelAmbienceFade);
		
		OptionsFrame_DisableCheckBox(AudioOptionsVoicePanelEnableMicrophone);
		OptionsFrame_DisableCheckBox(AudioOptionsVoicePanelPushToTalkSound);
		AudioOptionsVoicePanel_UpdateMicrophoneControls();
		
		if ( ChannelPullout:IsShown() ) then
			ChannelPullout_ToggleDisplay();
		end
	end
end

function AudioOptionsVoicePanel_UpdateMicrophoneControls ()
	if ( GetCVar("EnableVoiceChat") == "0" or GetCVar("EnableMicrophone") == "0" or VoiceIsDisabledByClient() ) then
		--If VoiceChat is disabled, the microphone controls should be too.
		AudioOptionsVoicePanel_DisableMicrophoneControls();
	else
		AudioOptionsVoicePanel_EnableMicrophoneControls();
	end
end

function AudioOptionsVoicePanelBindingType_Update ()
	local mode = tonumber(GetCVar("VoiceChatMode")) + 1;
	if ( mode == 1 ) then
		AudioOptionsVoicePanelChatMode1:Show();
		AudioOptionsVoicePanelChatMode2:Hide();
	else
		AudioOptionsVoicePanelChatMode1:Hide();
		AudioOptionsVoicePanelChatMode2:Show();
	end
end

function AudioOptionsVoicePanelKeyBindingButton_OnShow (self)
	PUSH_TO_TALK_BUTTON = GetCVar("PushToTalkButton");
	local bindingText = GetBindingText(PUSH_TO_TALK_BUTTON, "KEY_");
	AudioOptionsVoicePanelChatMode1KeyBindingButtonHiddenText:SetText(bindingText);
	self:SetText(bindingText);
end

function AudioOptionsVoicePanelKeyBindingButton_OnKeyUp (self, button)
	if ( self.buttonPressed ) then
		AudioOptionsVoicePanelKeyBindingButton_BindButton(self);
	end
end

function AudioOptionsVoicePanelKeyBindingButton_OnKeyDown (self, button)
	if ( GetBindingFromClick(button) == "SCREENSHOT" ) then
		RunBinding("SCREENSHOT");
		return;
	end
	if ( self.buttonPressed ) then
		if ( button == "UNKNOWN" ) then
			return;
		end

		if ( button == "LSHIFT" or button == "RSHIFT" or button == "LCTRL" or button == "RCTRL" or button == "LALT" or button == "RALT" ) then
			if ( PUSH_TO_TALK_MODIFIER == "" ) then
				PUSH_TO_TALK_MODIFIER = button;
			else
				PUSH_TO_TALK_MODIFIER = PUSH_TO_TALK_MODIFIER.."-"..button;
			end
			return;
		elseif ( PUSH_TO_TALK_BUTTON ~= "" ) then
			AudioOptionsVoicePanelBindingOutputText:SetText(ERROR_CANNOT_BIND);
			AudioOptionsVoicePanelBindingOutput:SetAlpha(1.0);
			AudioOptionsVoicePanelBindingOutput.fade = 6;
			self:UnlockHighlight();
			self.buttonPressed = nil;
			return;
		end

		if ( PUSH_TO_TALK_MODIFIER == "" ) then
			PUSH_TO_TALK_BUTTON = button;
		else
			PUSH_TO_TALK_BUTTON = PUSH_TO_TALK_MODIFIER.."-"..button;
		end
	end

end

function AudioOptionsVoicePanelKeyBindingButton_OnClick (self, button)
	if ( button == "UNKNOWN" ) then
		return;
	end
	if ( not IsShiftKeyDown() and not IsControlKeyDown() and not IsAltKeyDown() ) then
		if ( button == "LeftButton" or button == "RightButton" ) then
			if ( self.buttonPressed ) then
				self:UnlockHighlight();
				self.buttonPressed = nil;
				AudioOptionsVoicePanelBindingOutputText:SetText("");
				self:SetScript("OnKeyDown", nil);
				self:SetScript("OnKeyUp", nil);
			else
				self:LockHighlight();
				self.buttonPressed = 1;
				AudioOptionsVoicePanelBindingOutputText:SetText(CAN_BIND_PTT);
				self:SetScript("OnKeyDown", AudioOptionsVoicePanelKeyBindingButton_OnKeyDown);
				self:SetScript("OnKeyUp", AudioOptionsVoicePanelKeyBindingButton_OnKeyUp);
			end
			AudioOptionsVoicePanelBindingOutput:SetAlpha(1.0)
			AudioOptionsVoicePanelBindingOutput.fade = nil;
			UIFrameFadeIn(AudioOptionsVoicePanelBindingOutput, 0); 
			PUSH_TO_TALK_BUTTON = "";
			PUSH_TO_TALK_MODIFIER = "";
			return;
		end
	end

	if ( self.buttonPressed ) then
		if ( PUSH_TO_TALK_BUTTON ~= "" ) then
			AudioOptionsVoicePanelBindingOutputText:SetText(ERROR_CANNOT_BIND);
			AudioOptionsVoicePanelBindingOutput:SetAlpha(1.0);
			AudioOptionsVoicePanelBindingOutput.fade = 6;
			AudioOptionsVoicePanelBindingOutputText:SetVertexColor(1, 1, 1);
			AudioOptionsVoicePanelBindingOutputText:SetText("");
			self:UnlockHighlight();
			self.buttonPressed = nil;
			return;
		end

		if ( PUSH_TO_TALK_MODIFIER == "" ) then
			PUSH_TO_TALK_BUTTON = button;
		else
			PUSH_TO_TALK_BUTTON = PUSH_TO_TALK_MODIFIER.."-"..button;
		end
		AudioOptionsVoicePanelKeyBindingButton_BindButton(self);
	end
end

function AudioOptionsVoicePanelKeyBindingButton_BindButton (self)
	if ( PUSH_TO_TALK_BUTTON == "" and PUSH_TO_TALK_MODIFIER ~= "" ) then
		PUSH_TO_TALK_BUTTON = PUSH_TO_TALK_MODIFIER;
	end
	if ( PUSH_TO_TALK_BUTTON ~= "" ) then
		SetCVar("PushToTalkButton", PUSH_TO_TALK_BUTTON);
		local bindingText = GetBindingText(PUSH_TO_TALK_BUTTON, "KEY_");
		self:SetText(bindingText);
		AudioOptionsVoicePanelChatMode1KeyBindingButtonHiddenText:SetText(bindingText);

		self:UnlockHighlight();
		self.buttonPressed = nil;

		local currentbinding = GetBindingByKey(PUSH_TO_TALK_BUTTON);
		if ( currentbinding ) then
			 UIErrorsFrame:AddMessage( format(ALREADY_BOUND, GetBindingText(currentbinding, "BINDING_NAME_")), 1.0, 1.0, 0, 1, 10) 
		end

		AudioOptionsVoicePanelBindingOutputText:SetText(PTT_BOUND);
		AudioOptionsVoicePanelBindingOutput:SetAlpha(1.0);
		AudioOptionsVoicePanelBindingOutput.fade = VOICE_OPTIONS_BINDING_FADE;
		self:SetScript("OnKeyDown", nil);
		self:SetScript("OnKeyUp", nil);
	end
	AudioOptionsVoicePanelKeyBindingButton_SetTooltip(self);
	if ( GameTooltip:GetOwner() == self ) then
		AudioOptionsVoicePanelKeyBindingButton_OnEnter(self);
	end
end

function AudioOptionsVoicePanelKeyBindingButton_SetTooltip (self)
	local textWidth = AudioOptionsVoicePanelChatMode1KeyBindingButtonHiddenText:GetWidth();	
	if ( textWidth > 135) then
		self.tooltip = AudioOptionsVoicePanelChatMode1KeyBindingButtonHiddenText:GetText();
	else
		self.tooltip = nil;
	end
end

function AudioOptionsVoicePanelKeyBindingButton_OnEnter (self)
	if ( self.tooltip ) then
		GameTooltip:SetOwner(self);
		GameTooltip:SetText(self.tooltip);
		GameTooltip:Show();
	end
end

function AudioOptionsVoicePanel_DisableMicrophoneControls ()
	UIDropDownMenu_DisableDropDown(AudioOptionsVoicePanelInputDeviceDropDown);
	RecordLoopbackSoundButton:Disable();
	PlayLoopbackSoundButton:Disable();
	VoiceChat_StopRecordingLoopbackSound();
	VoiceChat_StopPlayingLoopbackSound();
	
	for i in pairs(AudioOptionsVoicePanelFrameMicrophoneList) do
		getglobal(i):SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
	
	OptionsFrame_DisableSlider(AudioOptionsVoicePanelMicrophoneVolume);
end

function AudioOptionsVoicePanel_EnableMicrophoneControls ()
	UIDropDownMenu_EnableDropDown(AudioOptionsVoicePanelInputDeviceDropDown);
	RecordLoopbackSoundButton:Enable();
	PlayLoopbackSoundButton:Enable();

	for i, value in pairs(AudioOptionsVoicePanelFrameMicrophoneList) do
		getglobal(i):SetVertexColor(value.r, value.g, value.b);
	end
	
	OptionsFrame_EnableSlider(AudioOptionsVoicePanelMicrophoneVolume);
end

function AudioOptionsVoicePanel_SetOutputDevice(deviceIndex)
	VoiceSelectOutputDevice(VoiceEnumerateOutputDevices(deviceIndex));
end

function AudioOptionsVoicePanel_SetInputDevice(deviceIndex)
	VoiceSelectCaptureDevice(VoiceEnumerateCaptureDevices(deviceIndex));
end

function AudioOptionsVoicePanelInputDeviceDropDown_OnLoad (self)
	UIDropDownMenu_Initialize(self, AudioOptionsVoicePanelInputDeviceDropDown_Initialize);
	UIDropDownMenu_SetWidth(self, 140);

	local selectedInputDriverIndex = GetCVar("Sound_VoiceChatInputDriverIndex");
	local deviceName = VoiceEnumerateCaptureDevices(selectedInputDriverIndex);

	UIDropDownMenu_SetSelectedValue(self, deviceName, 1);
	UIDropDownMenu_SetText(self, deviceName);
	
	self.currValue = selectedInputDriverIndex;
	self.value = selectedInputDriverIndex;
	self.restart = true;
	
	self.SetValue = 
		function (self, value) 
			self.value = value;
			UIDropDownMenu_SetSelectedValue(AudioOptionsVoicePanelInputDeviceDropDown, value);
			local deviceName = VoiceEnumerateCaptureDevices(value);
			UIDropDownMenu_SetText(self, deviceName);
			AudioOptionsVoicePanel_SetInputDevice(self.value);
		end;
	self.GetValue =
		function (self)
			return GetCVar("Sound_VoiceChatInputDriverIndex");
		end
end

function AudioOptionsVoicePanelInputDeviceDropDown_OnClick(self)
	AudioOptionsVoicePanelInputDeviceDropDown:SetValue(self.value);
end

function AudioOptionsVoicePanelInputDeviceDropDown_Initialize(self)
	local selectedInputDriverIndex = GetCVar("Sound_VoiceChatInputDriverIndex");
	local num = Sound_ChatSystem_GetNumInputDrivers();
	local info = UIDropDownMenu_CreateInfo();
	for index=0,num-1,1 do
		local description = Sound_ChatSystem_GetInputDriverNameByIndex(index);
		info.text = description;
		info.value = index;
		info.checked = nil;
		if (index == tonumber(selectedInputDriverIndex)) then
			info.checked = 1;
		end
		info.func = AudioOptionsVoicePanelInputDeviceDropDown_OnClick;
		
		UIDropDownMenu_AddButton(info);
	end
	
	UIDropDownMenu_SetSelectedValue(self, tonumber(selectedInputDriverIndex));
end

--==============================
--
-- Record Loopback functions
--
--==============================

function RecordLoopbackSoundButton_OnUpdate (self)
	if ( self.clicked ) then
		if (GetCVar("EnableVoiceChat") == "0" or GetCVar("EnableMicrophone") == "0") then
			RecordLoopbackSoundButton:Disable();
			RecordLoopbackSoundButtonTexture:SetVertexColor(0.5, 0.5, 0.5);								
		else
			local isRecording = VoiceChat_IsRecordingLoopbackSound();
			if ( isRecording == 0 ) then
				RecordLoopbackSoundButton:Enable();
				RecordLoopbackSoundButtonTexture:SetVertexColor(1, 0, 0);	
				self.clicked = nil;
			else
				RecordLoopbackSoundButton:Disable();
				RecordLoopbackSoundButtonTexture:SetVertexColor(0.5, 0.5, 0.5);								
			end
		end
	end
end

--==============================
--
-- VU Meter functions
--
--==============================

function LoopbackVUMeter_OnLoad (self)
    self:SetMinMaxValues(0, 100);
	self:SetValue(0);
end

function LoopbackVUMeter_OnUpdate (self, elapsed)
    local isRecording = VoiceChat_IsRecordingLoopbackSound();
    local isPlaying = VoiceChat_IsPlayingLoopbackSound();
    if ( isRecording == 0 and isPlaying == 0 ) then
        self:SetValue(0);
    else
        local volume = VoiceChat_GetCurrentMicrophoneSignalLevel();
        self:SetValue(volume);
    end
end

function AudioOptionsVoicePanelChatModeDropDown_OnLoad (self)
	UIDropDownMenu_Initialize(self, AudioOptionsVoicePanelChatModeDropDown_Initialize);

	local voiceChatMode = GetCVar("VoiceChatMode");
	UIDropDownMenu_SetSelectedValue(self, voiceChatMode);

	self.tooltip = getglobal("OPTION_TOOLTIP_VOICE_TYPE"..(voiceChatMode+1));
	UIDropDownMenu_SetWidth(self, 140);
	
	self.currValue = voiceChatMode;
	self.value = voiceChatMode;
	self.restart = true;
	
	self.SetValue = 
		function (self, value) 
			self.value = value;
			UIDropDownMenu_SetSelectedValue(AudioOptionsVoicePanelChatModeDropDown, value);
			self.tooltip = getglobal("OPTION_TOOLTIP_VOICE_TYPE"..(value+1));
			SetCVar("VoiceChatMode", value);
			AudioOptionsVoicePanelBindingType_Update();
			SetSelfMuteState();
		end;
	self.GetValue =
		function (self)
			return GetCVar("VoiceChatMode");
		end
end

function AudioOptionsVoicePanelChatModeDropDown_OnClick(self)
	AudioOptionsVoicePanelChatModeDropDown:SetValue(self.value);
end

function AudioOptionsVoicePanelChatModeDropDown_Initialize(self)
	local selectedValue = UIDropDownMenu_GetSelectedValue(self);
	local info = UIDropDownMenu_CreateInfo();

	info.text = PUSH_TO_TALK;
	info.func = AudioOptionsVoicePanelChatModeDropDown_OnClick;
	info.value = "0";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = PUSH_TO_TALK;
	info.tooltipText = OPTION_TOOLTIP_VOICE_TYPE1;
	UIDropDownMenu_AddButton(info);

	info.text = VOICE_ACTIVATED;
	info.func = AudioOptionsVoicePanelChatModeDropDown_OnClick;
	info.value = "1";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = VOICE_ACTIVATED;
	info.tooltipText  = OPTION_TOOLTIP_VOICE_TYPE2;
	UIDropDownMenu_AddButton(info);
end

function AudioOptionsVoicePanelOutputDeviceDropDown_OnLoad (self)
	local selectedOutputDriverIndex = GetCVar("Sound_VoiceChatOutputDriverIndex");
	local deviceName = VoiceEnumerateOutputDevices(selectedOutputDriverIndex);
	UIDropDownMenu_Initialize(self, AudioOptionsVoicePanelOutputDeviceDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(self, deviceName, 1);
	UIDropDownMenu_SetText(self, deviceName);
	UIDropDownMenu_SetWidth(self, 140);
	
	self.currValue = selectedOutputDriverIndex;
	self.value = selectedOutputDriverIndex;
	self.restart = true;
	
	self.SetValue = 
		function (self, value) 
			self.value = value;
			UIDropDownMenu_SetSelectedValue(AudioOptionsVoicePanelOutputDeviceDropDown, value);
			local deviceName = VoiceEnumerateOutputDevices(value);
			UIDropDownMenu_SetText(self, deviceName);
			AudioOptionsVoicePanel_SetOutputDevice(self.value);
		end;
	self.GetValue =
		function (self)
			return GetCVar("Sound_VoiceChatOutputDriverIndex");
		end
end

function AudioOptionsVoicePanelOutputDeviceDropDown_OnClick(self)
	AudioOptionsVoicePanelOutputDeviceDropDown:SetValue(self.value);
end

function AudioOptionsVoicePanelOutputDeviceDropDown_Initialize()
	local selectedOutputDriverIndex = GetCVar("Sound_VoiceChatOutputDriverIndex");
	local num = Sound_ChatSystem_GetNumOutputDrivers();
	local info = UIDropDownMenu_CreateInfo();
	for index=0,num-1,1 do
		local description = Sound_ChatSystem_GetOutputDriverNameByIndex(index);
		info.text = description;
		info.value = index;
        info.checked = nil;
        if (index == tonumber(selectedOutputDriverIndex)) then
			info.checked = 1;
		end
		info.func = AudioOptionsVoicePanelOutputDeviceDropDown_OnClick;
		
		UIDropDownMenu_AddButton(info);
	end
end

