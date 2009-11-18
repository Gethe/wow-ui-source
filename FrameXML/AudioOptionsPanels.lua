-- if you change something here you probably want to change the glue version too

local VOICE_OPTIONS_BINDING_SUCCESS_FADE = 3;
local VOICE_OPTIONS_BINDING_FAIL_FADE = 6;


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
	MiniMapVoiceChat_Update();
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
	MiniMapVoiceChat_Update();
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
	Sound_EnableSoundWhenGameIsInBG = { text = "ENABLE_BGSOUND" },
	Sound_EnableReverb = { text = "ENABLE_REVERB" },
	Sound_EnableHardware = { text = "ENABLE_HARDWARE" },
	Sound_EnableSoftwareHRTF = { text = "ENABLE_SOFTWARE_HRTF" },
	Sound_EnableDSPEffects = { text = "ENABLE_DSP_EFFECTS" },
	Sound_SFXVolume = { text = "SOUND_VOLUME", minValue = 0, maxValue = 1, valueStep = 0.1, },
	Sound_MusicVolume = { text = "MUSIC_VOLUME", minValue = 0, maxValue = 1, valueStep = 0.1, },
	Sound_AmbienceVolume = { text = "AMBIENCE_VOLUME", minValue = 0, maxValue = 1, valueStep = 0.1, },
	Sound_MasterVolume = { text = "MASTER_VOLUME", minValue = 0, maxValue = 1, valueStep = SOUND_MASTERVOLUME_STEP, },
	Sound_NumChannels = { text = "SOUND_CHANNELS", minValue = 32, maxValue = 64, valueStep = 32, },
	Sound_OutputQuality = { text = "SOUND_QUALITY", minValue = 0, maxValue = 2, valueStep = 1 },
}

function AudioOptionsSoundPanel_OnLoad (self)
	self.name = SOUND_LABEL;
	self.options = SoundPanelOptions;
	BlizzardOptionsPanel_OnLoad(self, AudioOptionsPanel_Okay, AudioOptionsPanel_Cancel, AudioOptionsPanel_Default, AudioOptionsPanel_Refresh);
	OptionsFrame_AddCategory(AudioOptionsFrame, self);
end

function AudioOptionsSoundPanelHardwareDropDown_OnLoad (self)
	self.cvar = "Sound_OutputDriverIndex";

	local selectedDriverIndex = BlizzardOptionsPanel_GetCVarSafe(self.cvar);
	local deviceName = Sound_GameSystem_GetOutputDriverNameByIndex(selectedDriverIndex);
	self.defaultValue = BlizzardOptionsPanel_GetCVarDefaultSafe(self.cvar);
	self.value = selectedDriverIndex;
	self.newValue = selectedDriverIndex;
	self.restart = true;

	UIDropDownMenu_SetWidth(self, 136);
	UIDropDownMenu_SetSelectedValue(self, selectedDriverIndex);
	UIDropDownMenu_Initialize(self, AudioOptionsSoundPanelHardwareDropDown_Initialize);

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

			UIDropDownMenu_SetSelectedValue(self, selectedDriverIndex);
			UIDropDownMenu_Initialize(self, AudioOptionsSoundPanelHardwareDropDown_Initialize);
		end
end

function AudioOptionsSoundPanelHardwareDropDown_Initialize(self)
	local selectedValue = UIDropDownMenu_GetSelectedValue(self);
	local num = Sound_GameSystem_GetNumOutputDrivers();
	local info = UIDropDownMenu_CreateInfo();
	for index=0,num-1,1 do
		info.text = Sound_GameSystem_GetOutputDriverNameByIndex(index);
		info.value = index;
		info.checked = nil;
		if (selectedValue and index == selectedValue) then
			UIDropDownMenu_SetText(self, info.text);
			info.checked = 1;
		else
			info.checked = nil;
		end
		info.func = AudioOptionsSoundPanelHardwareDropDown_OnClick;

		UIDropDownMenu_AddButton(info);
	end
end

function AudioOptionsSoundPanelHardwareDropDown_OnClick(self)
	local value = self.value;
	local dropdown = AudioOptionsSoundPanelHardwareDropDown;
	UIDropDownMenu_SetSelectedValue(dropdown, value);

	local prevValue = dropdown:GetValue();
	dropdown:SetValue(value);
	if ( dropdown.restart and prevValue ~= value ) then
		AudioOptionsFrame_AudioRestart();
	end
end


-- [[ Voice Options Panel ]] --

VoicePanelOptions = {
	EnableVoiceChat = { text = "ENABLE_VOICECHAT" },
	EnableMicrophone = { text = "ENABLE_MICROPHONE" },
	OutboundChatVolume = { text = "VOICE_INPUT_VOLUME", minValue = 0.25, maxValue = 2.5, valueStep = 0.05 },
	InboundChatVolume = { text = "VOICE_OUTPUT_VOLUME", minValue = 0, maxValue = 1, valueStep = 0.01 },
	ChatSoundVolume = { text = "", minValue = 0, maxValue = 1, valueStep = 0.01, tooltip = OPTION_TOOLTIP_VOICE_SOUND },
	ChatMusicVolume = { text = "", minValue = 0, maxValue = 1, valueStep = 0.01, tooltip = OPTION_TOOLTIP_VOICE_MUSIC },
	ChatAmbienceVolume = { text = "", minValue = 0, maxValue = 1, valueStep = 0.01, tooltip = OPTION_TOOLTIP_VOICE_AMBIENCE },
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

function AudioOptionsVoicePanel_Refresh (self)
	AudioOptionsPanel_Refresh(self);
	AudioOptionsVoicePanelEnableVoice_UpdateControls(GetCVar(AudioOptionsVoicePanelEnableVoice.cvar));
	AudioOptionsVoicePanelBindingType_Update(GetCVar(AudioOptionsVoicePanelChatModeDropDown.cvar));
	AudioOptionsVoicePanelKeyBindingButton_Refresh();
	AudioOptionsVoicePanelKeyBindingButton_SetTooltip();
end

function AudioOptionsVoicePanel_OnLoad (self)
	self.name = VOICE_LABEL;
	self.options = VoicePanelOptions;
	BlizzardOptionsPanel_OnLoad(self, AudioOptionsPanel_Okay, AudioOptionsPanel_Cancel, AudioOptionsPanel_Default, AudioOptionsVoicePanel_Refresh);
	self:SetScript("OnEvent", AudioOptionsVoicePanel_OnEvent);
end

function AudioOptionsVoicePanel_OnEvent (self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		if ( IsVoiceChatAllowedByServer() ) then
			OptionsFrame_AddCategory(AudioOptionsFrame, self);
			BlizzardOptionsPanel_OnEvent(self, event, ...);
		end
		self:UnregisterEvent(event);
	end
end

function AudioOptionsVoicePanel_OnShow (self)
	VoiceChatTalkers:SetAlpha(1);
	VoiceChatTalkers.optionsLock = true;
end

function AudioOptionsVoicePanel_OnHide (self)
	AudioOptionsVoicePanelKeyBindingButton_CancelBinding();
	VoiceChatTalkers.optionsLock = nil;
	if ( VoiceChatTalkers_CanHide() ) then
		VoiceChatTalkers_FadeOut();
	end
end

function AudioOptionsVoicePanelEnableVoice_UpdateControls (value)
	local voiceChatEnabled = value == "1";
	if ( VoiceIsDisabledByClient() ) then
		--Comsat is disabled either because the computer is way old (No SSE) or another copy of WoW is running.
		BlizzardOptionsPanel_SetCVarSafe("EnableVoiceChat", 0);
		voiceChatEnabled = false;
		AudioOptionsVoicePanelEnableVoice:Hide();
		AudioOptionsVoicePanelDisabledMessage:Show();
	elseif ( not AudioOptionsVoicePanelEnableVoice:IsShown() ) then
		--Pretty certain this won't be changing dynamically, but better safe than sorry.
		AudioOptionsVoicePanelEnableVoice:Show();
		AudioOptionsVoicePanelDisabledMessage:Hide();
	end
	if ( voiceChatEnabled ) then
		UIDropDownMenu_EnableDropDown(AudioOptionsVoicePanelOutputDeviceDropDown);
		UIDropDownMenu_EnableDropDown(AudioOptionsVoicePanelChatModeDropDown);

		AudioOptionsVoicePanelChatMode1KeyBindingButton:Enable();

		for index, value in pairs(AudioOptionsVoicePanelDisableList) do
			_G[index]:SetVertexColor(value.r, value.g, value.b);
		end

		BlizzardOptionsPanel_Slider_Enable(AudioOptionsVoicePanelVoiceActivateSlider);
		BlizzardOptionsPanel_Slider_Enable(AudioOptionsVoicePanelSpeakerVolume);
		BlizzardOptionsPanel_Slider_Enable(AudioOptionsVoicePanelSoundFade);
		BlizzardOptionsPanel_Slider_Enable(AudioOptionsVoicePanelMusicFade);
		BlizzardOptionsPanel_Slider_Enable(AudioOptionsVoicePanelAmbienceFade);

		AudioOptionsVoicePanelEnableMicrophone:Enable();
		AudioOptionsVoicePanelPushToTalkSound:Enable();
		AudioOptionsVoicePanelEnableMicrophone_UpdateControls(AudioOptionsVoicePanelEnableMicrophone:GetChecked());

		if ( ChannelPullout:IsShown() ) then
			ChannelPullout_ToggleDisplay();
		end
	else
		UIDropDownMenu_DisableDropDown(AudioOptionsVoicePanelOutputDeviceDropDown);
		UIDropDownMenu_DisableDropDown(AudioOptionsVoicePanelChatModeDropDown);

		AudioOptionsVoicePanelChatMode1KeyBindingButton:Disable();

		for index, value in pairs(AudioOptionsVoicePanelDisableList) do
			_G[index]:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		end

		BlizzardOptionsPanel_Slider_Disable(AudioOptionsVoicePanelVoiceActivateSlider);
		BlizzardOptionsPanel_Slider_Disable(AudioOptionsVoicePanelSpeakerVolume);
		BlizzardOptionsPanel_Slider_Disable(AudioOptionsVoicePanelSoundFade);
		BlizzardOptionsPanel_Slider_Disable(AudioOptionsVoicePanelMusicFade);
		BlizzardOptionsPanel_Slider_Disable(AudioOptionsVoicePanelAmbienceFade);

		AudioOptionsVoicePanelEnableMicrophone:Disable();
		AudioOptionsVoicePanelPushToTalkSound:Disable();
		AudioOptionsVoicePanelEnableMicrophone_UpdateControls(AudioOptionsVoicePanelEnableMicrophone:GetChecked());

		if ( ChannelPullout:IsShown() ) then
			ChannelPullout_ToggleDisplay();
		end
	end
end

function AudioOptionsVoicePanel_DisableMicrophoneControls ()
	UIDropDownMenu_DisableDropDown(AudioOptionsVoicePanelInputDeviceDropDown);
	RecordLoopbackSoundButton:Disable();
	PlayLoopbackSoundButton:Disable();
	VoiceChat_StopRecordingLoopbackSound();
	VoiceChat_StopPlayingLoopbackSound();

	for index in pairs(AudioOptionsVoicePanelFrameMicrophoneList) do
		_G[index]:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end

	BlizzardOptionsPanel_Slider_Disable(AudioOptionsVoicePanelMicrophoneVolume);
end

function AudioOptionsVoicePanel_EnableMicrophoneControls ()
	UIDropDownMenu_EnableDropDown(AudioOptionsVoicePanelInputDeviceDropDown);
	RecordLoopbackSoundButton:Enable();
	PlayLoopbackSoundButton:Enable();

	for index, value in pairs(AudioOptionsVoicePanelFrameMicrophoneList) do
		_G[index]:SetVertexColor(value.r, value.g, value.b);
	end

	BlizzardOptionsPanel_Slider_Enable(AudioOptionsVoicePanelMicrophoneVolume);
end

function AudioOptionsVoicePanelEnableMicrophone_UpdateControls (value)
	if ( not AudioOptionsVoicePanelEnableVoice:GetChecked() or
		 not value or value == "0" or
		 VoiceIsDisabledByClient() ) then
		--If VoiceChat is disabled, the microphone controls should be too.
		AudioOptionsVoicePanel_DisableMicrophoneControls();
	else
		AudioOptionsVoicePanel_EnableMicrophoneControls();
	end
end

function AudioOptionsVoicePanelBindingType_Update (value)
	local mode = tonumber(value) + 1;
	if ( mode == 1 ) then
		AudioOptionsVoicePanelChatMode1:Show();
		AudioOptionsVoicePanelChatMode2:Hide();
	else
		AudioOptionsVoicePanelChatMode1:Hide();
		AudioOptionsVoicePanelChatMode2:Show();
	end
end

function AudioOptionsVoicePanelKeyBindingButton_Refresh ()
	PUSH_TO_TALK_BUTTON = BlizzardOptionsPanel_GetCVarSafe("PushToTalkButton");
	local bindingText = GetBindingText(PUSH_TO_TALK_BUTTON, "KEY_");
	AudioOptionsVoicePanelChatMode1KeyBindingButtonHiddenText:SetText(bindingText);
	AudioOptionsVoicePanelChatMode1KeyBindingButton:SetText(bindingText);
end

function AudioOptionsVoicePanelKeyBindingButton_SetTooltip ()
	local textWidth = AudioOptionsVoicePanelChatMode1KeyBindingButtonHiddenText:GetWidth();	
	if ( textWidth > 135 ) then
		AudioOptionsVoicePanelChatMode1KeyBindingButton.tooltip = AudioOptionsVoicePanelChatMode1KeyBindingButtonHiddenText:GetText();
	else
		AudioOptionsVoicePanelChatMode1KeyBindingButton.tooltip = nil;
	end
end

function AudioOptionsVoicePanelKeyBindingButton_OnEnter (self)
	if ( self.tooltip ) then
		GameTooltip:SetOwner(self);
		GameTooltip:SetText(self.tooltip);
		GameTooltip:Show();
	end
end

function AudioOptionsVoicePanelKeyBindingButton_OnKeyUp (self, key)
	if ( self.buttonPressed ) then
		AudioOptionsVoicePanelKeyBindingButton_BindButton(self);
	end
end

function AudioOptionsVoicePanelKeyBindingButton_OnKeyDown (self, key)
	if ( GetBindingFromClick(key) == "SCREENSHOT" ) then
		RunBinding("SCREENSHOT");
		return;
	end
	if ( self.buttonPressed ) then
		if ( key == "UNKNOWN" ) then
			return;
		end

		if ( key == "LSHIFT" or key == "RSHIFT" or key == "LCTRL" or key == "RCTRL" or key == "LALT" or key == "RALT" ) then
			if ( PUSH_TO_TALK_MODIFIER == "" ) then
				PUSH_TO_TALK_MODIFIER = key;
			else
				PUSH_TO_TALK_MODIFIER = PUSH_TO_TALK_MODIFIER.."-"..key;
			end
			return;
		elseif ( PUSH_TO_TALK_BUTTON ~= "" ) then
			AudioOptionsVoicePanelBindingOutputText:SetText(ERROR_CANNOT_BIND);
			AudioOptionsVoicePanelBindingOutputTextConflict:SetText("");
			AudioOptionsVoicePanelBindingOutput:SetAlpha(1.0);
			AudioOptionsVoicePanelBindingOutput.fade = VOICE_OPTIONS_BINDING_FAIL_FADE;
			self:UnlockHighlight();
			self.buttonPressed = nil;
			return;
		end

		if ( PUSH_TO_TALK_MODIFIER == "" ) then
			PUSH_TO_TALK_BUTTON = key;
		else
			PUSH_TO_TALK_BUTTON = PUSH_TO_TALK_MODIFIER.."-"..key;
		end
	end

end

function AudioOptionsVoicePanelKeyBindingButton_CancelBinding ()
	local self = AudioOptionsVoicePanelChatMode1KeyBindingButton;
	self:UnlockHighlight();
	self.buttonPressed = nil;
	AudioOptionsVoicePanelBindingOutputText:SetText("");
	AudioOptionsVoicePanelBindingOutputTextConflict:SetText("");
	self:SetScript("OnKeyDown", nil);
	self:SetScript("OnKeyUp", nil);
	AudioOptionsVoicePanelBindingOutput:SetAlpha(1.0)
	AudioOptionsVoicePanelBindingOutput.fade = 0;
	UIFrameFadeIn(AudioOptionsVoicePanelBindingOutput, 0); 
	PUSH_TO_TALK_BUTTON = "";
	PUSH_TO_TALK_MODIFIER = "";
end

function AudioOptionsVoicePanelKeyBindingButton_OnClick (self, button)
	if ( button == "UNKNOWN" ) then
		return;
	end
	if ( not IsShiftKeyDown() and not IsControlKeyDown() and not IsAltKeyDown() ) then
		if ( button == "LeftButton" or button == "RightButton" ) then
			if ( self.buttonPressed ) then
				AudioOptionsVoicePanelKeyBindingButton_CancelBinding(self);
			else
				self:LockHighlight();
				self.buttonPressed = 1;
				AudioOptionsVoicePanelBindingOutputText:SetText(CAN_BIND_PTT);
				self:SetScript("OnKeyDown", AudioOptionsVoicePanelKeyBindingButton_OnKeyDown);
				self:SetScript("OnKeyUp", AudioOptionsVoicePanelKeyBindingButton_OnKeyUp);
				AudioOptionsVoicePanelBindingOutput:SetAlpha(1.0)
				AudioOptionsVoicePanelBindingOutput.fade = 0;
				UIFrameFadeIn(AudioOptionsVoicePanelBindingOutput, 0); 
				AudioOptionsVoicePanelBindingOutputTextConflict:SetText("");
				PUSH_TO_TALK_BUTTON = "";
				PUSH_TO_TALK_MODIFIER = "";
			end
			return;
		end
	end

	if ( self.buttonPressed ) then
		if ( PUSH_TO_TALK_BUTTON ~= "" ) then
			AudioOptionsVoicePanelBindingOutputText:SetText(ERROR_CANNOT_BIND);
			AudioOptionsVoicePanelBindingOutput:SetAlpha(1.0);
			AudioOptionsVoicePanelBindingOutput.fade = VOICE_OPTIONS_BINDING_FAIL_FADE;
			AudioOptionsVoicePanelBindingOutputText:SetVertexColor(1, 1, 1);
			AudioOptionsVoicePanelBindingOutputTextConflict:SetText("");
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
		BlizzardOptionsPanel_SetCVarSafe("PushToTalkButton", PUSH_TO_TALK_BUTTON);
		local bindingText = GetBindingText(PUSH_TO_TALK_BUTTON, "KEY_");
		self:SetText(bindingText);
		AudioOptionsVoicePanelChatMode1KeyBindingButtonHiddenText:SetText(bindingText);

		self:UnlockHighlight();
		self.buttonPressed = nil;

		local currentbinding = GetBindingByKey(PUSH_TO_TALK_BUTTON);
		if ( currentbinding ) then
			UIErrorsFrame:AddMessage(format(ALREADY_BOUND, GetBindingText(currentbinding, "BINDING_NAME_")), 1.0, 1.0, 0.0, 1.0);
			AudioOptionsVoicePanelBindingOutputTextConflict:SetText(format(ALREADY_BOUND, GetBindingText(currentbinding, "BINDING_NAME_")));
		else
			AudioOptionsVoicePanelBindingOutputTextConflict:SetText("");
		end

		AudioOptionsVoicePanelBindingOutputText:SetText(PTT_BOUND);
		AudioOptionsVoicePanelBindingOutput:SetAlpha(1.0);
		AudioOptionsVoicePanelBindingOutput.fade = VOICE_OPTIONS_BINDING_SUCCESS_FADE;
		self:SetScript("OnKeyDown", nil);
		self:SetScript("OnKeyUp", nil);
	end
	AudioOptionsVoicePanelKeyBindingButton_SetTooltip();
	if ( GameTooltip:GetOwner() == self ) then
		AudioOptionsVoicePanelKeyBindingButton_OnEnter(self);
	end
end

function AudioOptionsVoicePanelBindingOutput_OnUpdate(self, elapsed)
	if ( self.fade and self.fade > 0 ) then
		self:SetAlpha(self.fade);
		self.fade = self.fade - elapsed;
		if ( self.fade < 0 ) then
			self.fade = 0;
			self:SetAlpha(0);
		end
	end
end

function AudioOptionsVoicePanel_SetOutputDevice(deviceIndex)
	VoiceSelectOutputDevice(VoiceEnumerateOutputDevices(deviceIndex));
end

function AudioOptionsVoicePanel_SetInputDevice(deviceIndex)
	VoiceSelectCaptureDevice(VoiceEnumerateCaptureDevices(deviceIndex));
end

function AudioOptionsVoicePanelInputDeviceDropDown_OnLoad (self)
	UIDropDownMenu_SetWidth(self, 140);

	self.cvar = "Sound_VoiceChatInputDriverIndex";

	local selectedDriverIndex = BlizzardOptionsPanel_GetCVarSafe(self.cvar);

	self.defaultValue = BlizzardOptionsPanel_GetCVarDefaultSafe(self.cvar);
	self.value = selectedDriverIndex;
	self.nextValue = selectedDriverIndex;
	self.restart = true;

	UIDropDownMenu_SetSelectedValue(self, selectedDriverIndex);
	UIDropDownMenu_Initialize(self, AudioOptionsVoicePanelInputDeviceDropDown_Initialize);

	self.SetValue = 
		function (self, value)
			self.value = value;
			AudioOptionsVoicePanel_SetInputDevice(value);
			BlizzardOptionsPanel_SetCVarSafe(self.cvar, value);
		end
	self.GetValue =
		function (self)
			return BlizzardOptionsPanel_GetCVarSafe(self.cvar);
		end
	self.RefreshValue =
		function (self)
			local selectedDriverIndex = BlizzardOptionsPanel_GetCVarSafe(self.cvar);

			self.value = selectedDriverIndex;
			self.newValue = selectedDriverIndex;

			UIDropDownMenu_SetSelectedValue(self, selectedDriverIndex);
			UIDropDownMenu_Initialize(self, AudioOptionsVoicePanelInputDeviceDropDown_Initialize);
		end
end

function AudioOptionsVoicePanelInputDeviceDropDown_Initialize(self)
	local selectedValue = UIDropDownMenu_GetSelectedValue(self);
	local num = Sound_ChatSystem_GetNumInputDrivers();
	local info = UIDropDownMenu_CreateInfo();
	for index=0,num-1,1 do
		info.text = Sound_ChatSystem_GetInputDriverNameByIndex(index);
		info.value = index;
		if (selectedValue and index == selectedValue) then
			info.checked = 1;
			UIDropDownMenu_SetText(self, info.text);
		else
			info.checked = nil;
		end
		info.func = AudioOptionsVoicePanelInputDeviceDropDown_OnClick;

		UIDropDownMenu_AddButton(info);
	end
end

function AudioOptionsVoicePanelInputDeviceDropDown_OnClick(self)
	local value = self.value;
	local dropdown = AudioOptionsVoicePanelInputDeviceDropDown;
	UIDropDownMenu_SetSelectedValue(dropdown, value);
	dropdown:SetValue(value);
end

--==============================
--
-- Record Loopback functions
--
--==============================

function RecordLoopbackSoundButton_OnUpdate (self)
	if ( self.clicked ) then
		if ( not AudioOptionsVoicePanelEnableVoice:GetChecked() or
			 not AudioOptionsVoicePanelEnableMicrophone:GetChecked() ) then
			-- NOTE: add VoiceIsDisabledByClient() if turning voice on and off ever happens dynamically
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
	UIDropDownMenu_SetWidth(self, 140);

	self.cvar = "VoiceChatMode";

	local voiceChatMode = BlizzardOptionsPanel_GetCVarSafe(self.cvar);

	self.tooltip = _G["OPTION_TOOLTIP_VOICE_TYPE"..(voiceChatMode+1)];
	self.defaultValue = BlizzardOptionsPanel_GetCVarDefaultSafe(self.cvar);
	self.value = voiceChatMode;
	self.newValue = voiceChatMode;
	self.restart = true;

	UIDropDownMenu_SetSelectedValue(self, voiceChatMode);
	UIDropDownMenu_Initialize(self, AudioOptionsVoicePanelChatModeDropDown_Initialize);

	self.SetValue = 
		function (self, value)
			self.value = value;
			BlizzardOptionsPanel_SetCVarSafe(self.cvar, value);
			AudioOptionsVoicePanelBindingType_Update(value);
			SetSelfMuteState();
		end
	self.GetValue =
		function (self)
			return BlizzardOptionsPanel_GetCVarSafe(self.cvar);
		end
	self.RefreshValue =
		function (self)
			local voiceChatMode = BlizzardOptionsPanel_GetCVarSafe(self.cvar);

			self.tooltip = _G["OPTION_TOOLTIP_VOICE_TYPE"..(voiceChatMode+1)];
			self.value = voiceChatMode;
			self.newValue = voiceChatMode;

			UIDropDownMenu_SetSelectedValue(self, voiceChatMode);
			UIDropDownMenu_Initialize(self, AudioOptionsVoicePanelChatModeDropDown_Initialize);
		end
end

function AudioOptionsVoicePanelChatModeDropDown_Initialize(self)
	local selectedValue = UIDropDownMenu_GetSelectedValue(self);
	local info = UIDropDownMenu_CreateInfo();

	info.text = PUSH_TO_TALK;
	info.func = AudioOptionsVoicePanelChatModeDropDown_OnClick;
	info.value = 0;
	if ( info.value == selectedValue ) then
		info.checked = 1;
		UIDropDownMenu_SetText(self, info.text);
	else
		info.checked = nil;
	end
	info.tooltipTitle = PUSH_TO_TALK;
	info.tooltipText = OPTION_TOOLTIP_VOICE_TYPE1;
	UIDropDownMenu_AddButton(info);

	info.text = VOICE_ACTIVATED;
	info.func = AudioOptionsVoicePanelChatModeDropDown_OnClick;
	info.value = 1;
	if ( info.value == selectedValue ) then
		info.checked = 1;
		UIDropDownMenu_SetText(self, info.text);
	else
		info.checked = nil;
	end
	info.tooltipTitle = VOICE_ACTIVATED;
	info.tooltipText  = OPTION_TOOLTIP_VOICE_TYPE2;
	UIDropDownMenu_AddButton(info);
end

function AudioOptionsVoicePanelChatModeDropDown_OnClick(self)
	local value = self.value;
	local dropdown = AudioOptionsVoicePanelChatModeDropDown;
	UIDropDownMenu_SetSelectedValue(dropdown, value);
	dropdown.tooltip = _G["OPTION_TOOLTIP_VOICE_TYPE"..(value+1)];
	dropdown:SetValue(value);
end

function AudioOptionsVoicePanelOutputDeviceDropDown_OnLoad (self)
	UIDropDownMenu_SetWidth(self, 140);

	self.cvar = "Sound_VoiceChatOutputDriverIndex";

	local selectedDriverIndex = BlizzardOptionsPanel_GetCVarSafe(self.cvar);

	self.defaultValue = BlizzardOptionsPanel_GetCVarDefaultSafe(self.cvar);
	self.value = selectedDriverIndex;
	self.nextValue = selectedDriverIndex;
	self.restart = true;

	UIDropDownMenu_SetSelectedValue(self, selectedDriverIndex);
	UIDropDownMenu_Initialize(self, AudioOptionsVoicePanelOutputDeviceDropDown_Initialize);

	self.SetValue = 
		function (self, value)
			self.value = value;
			AudioOptionsVoicePanel_SetOutputDevice(value);
			BlizzardOptionsPanel_SetCVarSafe("Sound_VoiceChatOutputDriverIndex", value);
		end
	self.GetValue =
		function (self)
			return BlizzardOptionsPanel_GetCVarSafe(self.cvar);
		end
	self.RefreshValue =
		function (self)
			local selectedDriverIndex = BlizzardOptionsPanel_GetCVarSafe(self.cvar);

			self.value = selectedDriverIndex;
			self.nextValue = selectedDriverIndex;

			UIDropDownMenu_SetSelectedValue(self, selectedDriverIndex);
			UIDropDownMenu_Initialize(self, AudioOptionsVoicePanelOutputDeviceDropDown_Initialize);
		end
end

function AudioOptionsVoicePanelOutputDeviceDropDown_Initialize(self)
	local selectedValue = UIDropDownMenu_GetSelectedValue(self);
	local num = Sound_ChatSystem_GetNumOutputDrivers();	
	local info = UIDropDownMenu_CreateInfo();
	if ( num == 0 ) then
		UIDropDownMenu_SetText(self, "");
	else
		for index=0,num-1,1 do
			info.text = Sound_ChatSystem_GetOutputDriverNameByIndex(index);
			info.value = index;
	        if (selectedValue and index == selectedValue) then
				info.checked = 1;
				UIDropDownMenu_SetText(self, info.text);
			else
				info.checked = nil;
			end
			info.func = AudioOptionsVoicePanelOutputDeviceDropDown_OnClick;

			UIDropDownMenu_AddButton(info);
		end
	end
end

function AudioOptionsVoicePanelOutputDeviceDropDown_OnClick(self)
	local value = self.value;
	local dropdown = AudioOptionsVoicePanelOutputDeviceDropDown;
	UIDropDownMenu_SetSelectedValue(dropdown, value);
	dropdown:SetValue(value);
end

function AudioOptionsVoicePanelOutputDeviceDropDown_OnEvent(self, event, ...)
	if ( event == "VOICE_CHAT_ENABLED_UPDATE" ) then
		UIDropDownMenu_Initialize(self, AudioOptionsVoicePanelOutputDeviceDropDown_Initialize);
	end
end
