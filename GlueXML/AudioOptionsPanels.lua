-- if you change something here you probably want to change the frame version too

-- [[ Generic Audio Options Panel ]] --

function AudioOptionsPanel_CheckButton_OnClick (checkButton)
	local setting = "0";
	if ( checkButton:GetChecked() ) then
		if ( not checkButton.invert ) then
			setting = "1"
		end
	elseif ( checkButton.invert ) then
		setting = "1"
	end

	local prevValue = checkButton:GetValue();

	checkButton:SetValue(setting);

	if ( checkButton.restart and prevValue ~= setting ) then
		AudioOptionsFrame_AudioRestart();
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

	if ( checkButton.setFunc ) then
		checkButton.setFunc(setting);
	end
end


local function AudioOptionsPanel_Okay (self)
	for _, control in next, self.controls do
		if ( control.value and control:GetValue() ~= control.value ) then
			if ( control.restart ) then
				AudioOptionsFrame.audioRestart = true;
			end
			control:SetValue(control.value);
		end
	end
end

local function AudioOptionsPanel_Cancel (self)
	for _, control in next, self.controls do
		if ( control.oldValue ) then
			if ( control.value and control.value ~= control.oldValue ) then
				if ( control.restart ) then
					AudioOptionsFrame.audioRestart = true;
				end
				control:SetValue(control.oldValue);
			end
		elseif ( control.value ) then
			if ( control:GetValue() ~= control.value ) then
				if ( control.restart ) then
					AudioOptionsFrame.audioRestart = true;
				end
				control:SetValue(control.value);
			end
		end
	end
end

local function AudioOptionsPanel_Default (self)
	for _, control in next, self.controls do
		if ( control.defaultValue and control.value ~= control.defaultValue ) then
			if ( control.restart ) then
				AudioOptionsFrame.audioRestart = true;
			end
			control:SetValue(control.defaultValue);
			control.value = control.defaultValue;
		end
	end
end

local function AudioOptionsPanel_Refresh (self)
	for _, control in next, self.controls do
		BlizzardOptionsPanel_RefreshControl(control);
		-- record values so we can cancel back to this state
		control.oldValue = control.value;
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
	Sound_EnablePetSounds = { text = "ENABLE_PET_SOUNDS" },
	Sound_ZoneMusicNoDelay = { text = "ENABLE_MUSIC_LOOPING" },
	Sound_EnablePetBattleMusic = { text = "ENABLE_PET_BATTLE_MUSIC" },
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

function AudioOptionsSoundPanel_OnLoad (self)
	self.name = SOUND_LABEL;
	self.options = SoundPanelOptions;
	BlizzardOptionsPanel_OnLoad(self, AudioOptionsPanel_Okay, AudioOptionsPanel_Cancel, AudioOptionsPanel_Default, AudioOptionsPanel_Refresh);
	OptionsFrame_AddCategory(VideoOptionsFrame, self);
end

function AudioOptionsSoundPanelHardwareDropDown_OnLoad (self)
	self.cvar = "Sound_OutputDriverIndex";

	local selectedDriverIndex = BlizzardOptionsPanel_GetCVarSafe(self.cvar);

	self.defaultValue = BlizzardOptionsPanel_GetCVarDefaultSafe(self.cvar);
	self.value = selectedDriverIndex;
	self.newValue = selectedDriverIndex;
	self.restart = true;

	GlueDropDownMenu_SetWidth(self, 136)
	GlueDropDownMenu_SetSelectedValue(self, selectedDriverIndex);
	GlueDropDownMenu_Initialize(self, AudioOptionsSoundPanelHardwareDropDown_Initialize);

	self.SetValue = 
		function (self, value)
			self.value = value;
			BlizzardOptionsPanel_SetCVarSafe(self.cvar, value);
		end
	self.GetValue =
		function (self)
			return BlizzardOptionsPanel_GetCVarSafe(self.cvar);
		end
	self.RefreshValue =
		function (self)
			local selectedDriverIndex = BlizzardOptionsPanel_GetCVarSafe(self.cvar);
			local deviceName = Sound_GameSystem_GetOutputDriverNameByIndex(selectedDriverIndex);
			self.value = selectedDriverIndex;
			self.newValue = selectedDriverIndex;

			GlueDropDownMenu_SetSelectedValue(self, selectedDriverIndex);
			GlueDropDownMenu_Initialize(self, AudioOptionsSoundPanelHardwareDropDown_Initialize);
		end
end

function AudioOptionsSoundPanelHardwareDropDown_Initialize()
	local dropdown = AudioOptionsSoundPanelHardwareDropDown;
	local selectedValue = GlueDropDownMenu_GetSelectedValue(dropdown);
	local num = Sound_GameSystem_GetNumOutputDrivers();

	local info = GlueDropDownMenu_CreateInfo();
	for index=0,num-1,1 do
		info.text = Sound_GameSystem_GetOutputDriverNameByIndex(index);
		info.value = index;
		info.checked = nil;
		if (selectedValue and index == selectedValue) then
			GlueDropDownMenu_SetText(dropdown, info.text);
			info.checked = 1;
		else
			info.checked = nil;
		end
		info.func = AudioOptionsSoundPanelHardwareDropDown_OnClick;

		GlueDropDownMenu_AddButton(info);
	end
end

function AudioOptionsSoundPanelHardwareDropDown_OnClick(self)
	local value = self.value;
	local dropdown = AudioOptionsSoundPanelHardwareDropDown;
	GlueDropDownMenu_SetSelectedValue(dropdown, value);
	GlueDropDownMenu_SetText(dropdown, Sound_GameSystem_GetOutputDriverNameByIndex(value));

	local prevValue = dropdown:GetValue();
	dropdown:SetValue(value);
	if ( dropdown.restart and prevValue ~= value ) then
		AudioOptionsFrame_AudioRestart();
	end
end

function AudioOptionsSoundPanelSoundChannelsDropDown_OnLoad (self)
	self.cvar = "Sound_NumChannels";

	local selected = BlizzardOptionsPanel_GetCVarSafe(self.cvar);
	self.defaultValue = BlizzardOptionsPanel_GetCVarDefaultSafe(self.cvar);
	self.value = selected;
	self.newValue = selected;
	self.restart = true;

	GlueDropDownMenu_SetWidth(self, 136);
	GlueDropDownMenu_Initialize(self, AudioOptionsSoundPanelSoundChannelsDropDown_Initialize);
	GlueDropDownMenu_SetSelectedValue(self, selected);

	self.SetValue = 
		function (self, value)
			self.value = value;
			BlizzardOptionsPanel_SetCVarSafe(self.cvar, value);
			GlueDropDownMenu_SetSelectedValue(self, value);
		end
	self.GetValue =
		function (self)
			return BlizzardOptionsPanel_GetCVarSafe(self.cvar);
		end
	self.RefreshValue =
		function (self)
			local selected = BlizzardOptionsPanel_GetCVarSafe(self.cvar);
			self.value = selected;
			self.newValue = selected;

			GlueDropDownMenu_Initialize(self, AudioOptionsSoundPanelSoundChannelsDropDown_Initialize);
			GlueDropDownMenu_SetSelectedValue(self, selected);
		end
end

local soundChannelValues = { 24, 32, 64 };
local soundChannelText = { "SOUND_CHANNELS_LOW", "SOUND_CHANNELS_MEDIUM", "SOUND_CHANNELS_HIGH" };
function AudioOptionsSoundPanelSoundChannelsDropDown_Initialize(self)
	local selectedValue = GlueDropDownMenu_GetSelectedValue(self);
	local info = GlueDropDownMenu_CreateInfo();
	
	for i=1, #soundChannelValues do
		info.text = format(_G[soundChannelText[i]], soundChannelValues[i]);
		info.value = soundChannelValues[i];
		if ( selectedValue and info.value == selectedValue ) then
			info.checked = 1;
		else
			info.checked = nil;
		end
		info.func = AudioOptionsSoundPanelSoundChannelsDropDown_OnClick;
		
		GlueDropDownMenu_AddButton(info);
	end
end

function AudioOptionsSoundPanelSoundChannelsDropDown_OnClick(self)
	local value = self.value;
	local dropdown = AudioOptionsSoundPanelSoundChannelsDropDown;
	GlueDropDownMenu_SetSelectedValue(dropdown, value);

	local prevValue = dropdown:GetValue();
	dropdown:SetValue(value);
	if ( dropdown.restart and prevValue ~= value ) then
		AudioOptionsFrame_AudioRestart();
	end
end

