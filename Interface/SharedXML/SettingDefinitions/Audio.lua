VoiceTestMicrophoneMixin = CreateFromMixins(SettingsListElementMixin);

function VoiceTestMicrophoneMixin:OnLoad()
	SettingsListElementMixin.OnLoad(self);

	Mixin(self.Tooltip, DefaultTooltipMixin);
	self.Tooltip:SetScript("OnEnter", self.Tooltip.OnEnter);
	self.Tooltip:SetScript("OnLeave", self.Tooltip.OnLeave);

	self.VUMeter.Status:SetMinMaxValues(0, 1);
	self.VUMeter.Status:SetValue(0);

	self.ToggleTest:SetScript("OnClick", function(button, buttonName, down)
		self:ToggleTesting(self);
		self:UpdateTestButton();
	end);
end

function VoiceTestMicrophoneMixin:OnEvent(event, ...)
	if event == "ADDONS_UNLOADING" then
		self:EndInputDeviceTest(self);
	elseif event == "VOICE_CHAT_AUDIO_CAPTURE_ENERGY" then
		self:UpdateVUMeter(...);
	end
end

function VoiceTestMicrophoneMixin:ReactivateChannel()
	-- Intentionally leaving this set after reactivation, potentially need to handle async case using events.
	if self.data.currentActiveChannel then
		C_VoiceChat.ActivateChannel(self.data.currentActiveChannel);
	end
end

function VoiceTestMicrophoneMixin:BeginInputDeviceTest()
	if not self.data.isTesting then
		self.data.isTesting = true;
		self.data.currentActiveChannel = C_VoiceChat.GetActiveChannelID();

		local listenToLocalUser = true;
		C_VoiceChat.BeginLocalCapture(listenToLocalUser);
	end
end

function VoiceTestMicrophoneMixin:EndInputDeviceTest()
	if self.data.isTesting then
		self.data.isTesting = false;
		C_VoiceChat.EndLocalCapture();
		self:ReactivateChannel();
		self.VUMeter.Status:SetValue(0);
	end
end

function VoiceTestMicrophoneMixin:ToggleTesting()
	if self.data.isTesting then
		self:EndInputDeviceTest();
	else
		self:BeginInputDeviceTest();
	end
end

function VoiceTestMicrophoneMixin:Init(initializer)
	SettingsListElementMixin.Init(self, initializer);

	self:RegisterEvent("ADDONS_UNLOADING");
	self:RegisterEvent("VOICE_CHAT_AUDIO_CAPTURE_ENERGY");
end

function VoiceTestMicrophoneMixin:UpdateVUMeter(isSpeaking, energy)
	self.VUMeter.Status:SetValue(self.data.isTesting and energy or 0);

	if self.VUMeter.isSpeaking ~= isSpeaking then
		self.VUMeter.isSpeaking = isSpeaking;
		if isSpeaking then
			self.VUMeter.Status:SetStatusBarColor(0, 1, 0, 1);
		else
			self.VUMeter.Status:SetStatusBarColor(1, 1, 1, 1);
		end
	end
end

function VoiceTestMicrophoneMixin:Release()
	SettingsListElementMixin.Release(self);

	self:UnregisterEvent("ADDONS_UNLOADING");
	self:UnregisterEvent("VOICE_CHAT_AUDIO_CAPTURE_ENERGY");
end

function VoiceTestMicrophoneMixin:UpdateTestButton()
	local texture = "Interface\\OptionsFrame\\VoiceChat-Play";
	if self.data.isTesting then
		texture = "Interface\\OptionsFrame\\VoiceChat-Record";
	end

	self.ToggleTest.Texture:SetTexture(texture);
end

function VoiceTestMicrophoneMixin:EvaluateState()
end

VoicePushToTalkMixin = CreateFromMixins(SettingsListElementMixin);


function VoicePushToTalkMixin:OnLoad()
	SettingsListElementMixin.OnLoad(self);
end

function VoicePushToTalkMixin:Init(data)
	SettingsListElementMixin.Init(self, data);
	
	if not self.PushToTalkKeybindButton then
		self.PushToTalkKeybindButton = CustomBindingManager:RegisterHandlerAndCreateButton(CreateVoicePushToTalkBindingHandler(), "CustomBindingButtonTemplate", self);
		self.PushToTalkKeybindButton:SetPoint("LEFT", self, "CENTER", -80, 0);
		self.PushToTalkKeybindButton:SetWidth(140); -- TODO: Needs to dynamically size
		self.PushToTalkKeybindButton.selectedHighlight:SetWidth(self.PushToTalkKeybindButton:GetWidth());
	end

	BindingButtonTemplate_SetupBindingButton(nil, self.PushToTalkKeybindButton);
end

local function SortVoiceChatDevices(deviceA, deviceB)
	if deviceA.isSystemDefault ~= deviceB.isSystemDefault then
		return deviceA.isSystemDefault;
	end
	if deviceA.isCommsDefault ~= deviceB.isCommsDefault then
		return deviceA.isCommsDefault;
	end

	return strcmputf8i(deviceA.displayName, deviceB.displayName) < 0;
end

local function GetDeviceID(device)
	return device and device.deviceID or "";
end

local function FindDeviceByPredicate(devices, predicate)
	if devices then
		for index, device in ipairs(devices) do
			if predicate(device) then
				return device;
			end
		end
	end
	return nil;
end
	
local function FindActiveDevice(devices)
	return FindDeviceByPredicate(devices, function(device)
		return device.isActive;
	end);
end

local function FindDefaultDevice(devices)
	return FindDeviceByPredicate(devices, function(device)
		return device.isSystemDefault;
	end);
end

local function GetActiveInputDevice()
	return FindActiveDevice(C_VoiceChat.GetAvailableInputDevices());
end

local function GetDefaultInputDevice()
	return FindDefaultDevice(C_VoiceChat.GetAvailableInputDevices());
end

local function GetActiveInputDeviceID()
	return GetDeviceID(GetActiveInputDevice());
end

local function GetDefaultInputDeviceID()
	return GetDeviceID(GetDefaultInputDevice());
end

local function GetActiveOutputDevice()
	return FindActiveDevice(C_VoiceChat.GetAvailableOutputDevices());
end

local function GetDefaultOutputDevice()
	return FindDefaultDevice(C_VoiceChat.GetAvailableOutputDevices());
end

local function GetActiveOutputDeviceID()
	return GetDeviceID(GetActiveOutputDevice());
end

local function GetDefaultOutputDeviceID()
	return GetDeviceID(GetDefaultOutputDevice());
end

local VoiceMaxValue = 100;
local function FormatScaledPercentage(value)
	return FormatPercentage(value/VoiceMaxValue);
end

MacMicrophoneAccessWarningMixin = {};

function MacMicrophoneAccessWarningMixin:OnLoad()
	self.OpenAccessButton:SetScript("OnClick", function(button, buttonName, down)
		MacOptions_OpenMicrophoneRequestDialogue();
	end);

	self.Label:SetFormattedText(MAC_MIC_PREMISSIONS_NOTIFICATION, MacOptions_GetGameBundleName());
end

local function InitVoiceSettings(category, layout)
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(CHAT_VOICE));

	local function PopulateOptions(container, devices, defaultDeviceName)
		if devices then
			table.sort(devices, SortVoiceChatDevices);
			for index, device in ipairs(devices) do
				local label = device.isSystemDefault and defaultDeviceName or device.displayName;
				local value = device.deviceID;
				container:Add(value, label);
			end
		else
			container:Add(VOICE_CHAT_INVALID_DEVICE, VOICE_CHAT_INVALID_DEVICE);
		end
	end

	-- System Prefs
	if IsMacClient() and not MacOptions_IsMicrophoneEnabled() then
		local data = {};
		local initializer = Settings.CreatePanelInitializer("MacMicrophoneAccessWarningTemplate", data);
		layout:AddInitializer(initializer);
	end

	-- Output Device
	do
		local outputInitializer = nil;
		do
			local function GetOptions()
				local container = Settings.CreateDropDownTextContainer();
				PopulateOptions(container, C_VoiceChat.GetAvailableOutputDevices(), VOICE_CHAT_OUTPUT_DEVICE_DEFAULT);
				return container:GetData();
			end

			local defaultValue = GetDefaultOutputDeviceID();
			local setting = Settings.RegisterProxySetting(category, "PROXY_VOICE_OUTPUT_DEVICE", Settings.DefaultVarLocation,
				Settings.VarType.String, VOICE_CHAT_OUTPUT_DEVICE, defaultValue, GetActiveOutputDeviceID, C_VoiceChat.SetOutputDevice);

			outputInitializer = Settings.CreateDropDown(category, setting, GetOptions, OPTION_TOOLTIP_VOICE_CHAT_OUTPUT_DEVICE);
		end
		
		-- Volume
		do
			local defaultValue = tonumber(GetCVarDefault("VoiceOutputVolume"));
			local setting = Settings.RegisterProxySetting(category, "PROXY_VOICE_OUTPUT_VOLUME", Settings.DefaultVarLocation,
				Settings.VarType.Number, VOICE_CHAT_VOLUME, defaultValue, C_VoiceChat.GetOutputVolume, C_VoiceChat.SetOutputVolume);

			local minValue, maxValue, step = 0, VoiceMaxValue, 1;
			local options = Settings.CreateSliderOptions(minValue, maxValue, step);
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatScaledPercentage);

			local initializer = Settings.CreateSlider(category, setting, options, OPTION_TOOLTIP_VOICE_CHAT_VOLUME);
			initializer:SetParentInitializer(outputInitializer);
		end

		-- Ducking
		do
			local max = 1.0;
			local function GetValue()
				return max - C_VoiceChat.GetMasterVolumeScale();
			end
			
			local function SetValue(value)
				C_VoiceChat.SetMasterVolumeScale(max - value);
			end
		
			local defaultValue = tonumber(GetCVarDefault("VoiceChatMasterVolumeScale"));
			local setting = Settings.RegisterProxySetting(category, "PROXY_VOICE_DUCKING", Settings.DefaultVarLocation,
				Settings.VarType.Number, VOICE_CHAT_DUCKING_SCALE, defaultValue, GetValue, SetValue);

			local minValue, maxValue, step = 0, max, .01;
			local options = Settings.CreateSliderOptions(minValue, maxValue, step);
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatPercentage);

			local initializer = Settings.CreateSlider(category, setting, options, OPTION_TOOLTIP_VOICE_CHAT_DUCKING_SCALE);
			initializer:SetParentInitializer(outputInitializer);
			-- FIXME SEARCH
		end
	end

	-- Input Device
	do
		local inputInitializer = nil;
		do
			local function GetOptions()
				local container = Settings.CreateDropDownTextContainer();
				PopulateOptions(container, C_VoiceChat.GetAvailableInputDevices(), VOICE_CHAT_INPUT_DEVICE_DEFAULT);
				return container:GetData();
			end

			local defaultValue = GetDefaultInputDeviceID();
			local setting = Settings.RegisterProxySetting(category, "PROXY_VOICE_INPUT_DEVICE", Settings.DefaultVarLocation, 
				Settings.VarType.String, VOICE_CHAT_MIC_DEVICE, defaultValue, GetActiveInputDeviceID, C_VoiceChat.SetInputDevice);

			inputInitializer = Settings.CreateDropDown(category, setting, GetOptions, OPTION_TOOLTIP_VOICE_CHAT_MIC_DEVICE);
		end

		-- Volume
		do
			local defaultValue = tonumber(GetCVarDefault("VoiceInputVolume"));
			local setting = Settings.RegisterProxySetting(category, "PROXY_VOICE_INPUT_VOLUME", Settings.DefaultVarLocation,
				Settings.VarType.Number, VOICE_CHAT_MIC_VOLUME, defaultValue, C_VoiceChat.GetInputVolume, C_VoiceChat.SetInputVolume);

			local minValue, maxValue, step = 0, VoiceMaxValue, 1;
			local options = Settings.CreateSliderOptions(minValue, maxValue, step);
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatScaledPercentage);

			local initializer = Settings.CreateSlider(category, setting, options, OPTION_TOOLTIP_VOICE_CHAT_MIC_VOLUME);
			initializer:SetParentInitializer(inputInitializer);
		end

		-- Sensitivity
		do
			local defaultValue = tonumber(GetCVarDefault("VoiceVADSensitivity"));
			local setting = Settings.RegisterProxySetting(category, "PROXY_VOICE_SENSITIVITY", Settings.DefaultVarLocation,
				Settings.VarType.Number, VOICE_CHAT_MIC_SENSITIVITY, defaultValue, C_VoiceChat.GetVADSensitivity, C_VoiceChat.SetVADSensitivity);

			local minValue, maxValue, step = 0, VoiceMaxValue, 1;
			local options = Settings.CreateSliderOptions(minValue, maxValue, step);
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatScaledPercentage);
			
			local initializer = Settings.CreateSlider(category, setting, options, OPTION_TOOLTIP_VOICE_CHAT_MIC_SENSITIVITY);
			initializer:SetParentInitializer(inputInitializer);
		end

		-- Test Microphone
		do
			local data = {name = VOICE_CHAT_TEST_MIC_DEVICE, tooltip = OPTION_TOOLTIP_VOICE_CHAT_TEST_MIC_DEVICE};
			local initializer = Settings.CreateElementInitializer("VoiceTestMicrophoneTemplate", data);
			initializer:AddSearchTags(VOICE_CHAT_TEST_MIC_DEVICE);
			initializer:SetParentInitializer(inputInitializer);
			layout:AddInitializer(initializer);
		end
	end

	-- Voice Chat Mode
	do
		local chatModeInitializer = nil;
		do
			local function GetOptionData(options)
				local container = Settings.CreateDropDownTextContainer();
				container:Add(Enum.CommunicationMode.PushToTalk, PUSH_TO_TALK);
				container:Add(Enum.CommunicationMode.OpenMic, OPEN_MIC);
				return container:GetData();
			end

			local defaultValue = Enum.CommunicationMode.PushToTalk;
			local setting = Settings.RegisterProxySetting(category, "PROXY_VOICE_CHAT_MODE", Settings.DefaultVarLocation,
				Settings.VarType.Number, VOICE_CHAT_MODE, defaultValue, C_VoiceChat.GetCommunicationMode, C_VoiceChat.SetCommunicationMode);

			chatModeInitializer = Settings.CreateDropDown(category, setting, GetOptionData, OPTION_TOOLTIP_VOICE_CHAT_MODE);
		end

		-- Push To Talk
		do
			local initializer = Settings.CreateElementInitializer("VoicePushToTalkTemplate");
			initializer:AddSearchTags(VOICE_CHAT_MODE_KEY);
			initializer:SetParentInitializer(chatModeInitializer);
			layout:AddInitializer(initializer);
		end
	end
end

local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(AUDIO_LABEL);

	-- Game Sound Ouptut
	do
		local function GetOptions()
			local container = Settings.CreateDropDownTextContainer();
			local count = Sound_GameSystem_GetNumOutputDrivers();
			for index = 0, count - 1 do
				local name = Sound_GameSystem_GetOutputDriverNameByIndex(index);
				container:Add(index, name);
			end
			return container:GetData();
		end

		Settings.SetupCVarDropDown(category, "Sound_OutputDriverIndex", Settings.VarType.Number, GetOptions, AUDIO_OUTPUT_DEVICE, OPTION_TOOLTIP_AUDIO_OUTPUT);
	end

	-- Sound Channels
	do
		local minValue, maxValue, step = 20, 128, 1;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);

		Settings.SetupCVarSlider(category, "Sound_NumChannels", options, AUDIO_CHANNELS, OPTION_TOOLTIP_AUDIO_CHANNELS);
	end

	-- Sound Cache Size
	do
		local SMALL_CACHE_SIZE_BYTES = 67108864;
		local LARGE_CACHE_SIZE_BYTES = 134217728;
		local BYTE_PER_MB = 1024*1024;
		local function GetOptions()
			local container = Settings.CreateDropDownTextContainer();
			container:Add(SMALL_CACHE_SIZE_BYTES, AUDIO_CACHE_SIZE_SMALL:format(SMALL_CACHE_SIZE_BYTES/BYTE_PER_MB));
			container:Add(LARGE_CACHE_SIZE_BYTES, AUDIO_CACHE_SIZE_LARGE:format(LARGE_CACHE_SIZE_BYTES/BYTE_PER_MB));
			return container:GetData();
		end

		Settings.SetupCVarDropDown(category, "Sound_MaxCacheSizeInBytes", Settings.VarType.Number, GetOptions, AUDIO_CACHE_SIZE, OPTION_TOOLTIP_AUDIO_CACHE_SIZE);
	end

	-- Enable Sound
	Settings.SetupCVarCheckBox(category, "Sound_EnableAllSound", ENABLE_SOUND, OPTION_TOOLTIP_ENABLE_SOUND);
	
	do
		local minValue, maxValue, step = 0, 1, .05;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatPercentage);

		-- Master Volume
		local masterSetting, masterInitializer = Settings.SetupCVarSlider(category, "Sound_MasterVolume", options, MASTER_VOLUME, OPTION_TOOLTIP_MASTER_VOLUME);
		
		-- Music Volume
		local setting, initializer = Settings.SetupCVarSlider(category, "Sound_MusicVolume", options, MUSIC_VOLUME, OPTION_TOOLTIP_MUSIC_VOLUME);
		initializer:SetParentInitializer(masterInitializer);

		-- Effects Volume
		local setting, initializer = Settings.SetupCVarSlider(category, "Sound_SFXVolume", options, FX_VOLUME, OPTION_TOOLTIP_FX_VOLUME);
		initializer:SetParentInitializer(masterInitializer);

		-- Ambience Volume
		local setting, initializer = Settings.SetupCVarSlider(category, "Sound_AmbienceVolume", options, AMBIENCE_VOLUME, OPTION_TOOLTIP_AMBIENCE_VOLUME);
		initializer:SetParentInitializer(masterInitializer);
		
		-- Dialog Volume
		local setting, initializer = Settings.SetupCVarSlider(category, "Sound_DialogVolume", options, DIALOG_VOLUME, OPTION_TOOLTIP_DIALOG_VOLUME);
		initializer:SetParentInitializer(masterInitializer);
	end
	
	-- Music
	do
		local musicSetting, musicInitializer = Settings.SetupCVarCheckBox(category, "Sound_EnableMusic", ENABLE_MUSIC, OPTION_TOOLTIP_ENABLE_SOUNDFX);

		-- Loop Music
		local loopingSetting, loopingInitializer = Settings.SetupCVarCheckBox(category, "Sound_ZoneMusicNoDelay", ENABLE_MUSIC_LOOPING, OPTION_TOOLTIP_ENABLE_MUSIC_LOOPING);
		local function IsModifiable()
			return musicSetting:GetValue();
		end
		loopingInitializer:SetParentInitializer(musicInitializer, IsModifiable);
		
		-- Pet Battle Music
		local petBattleSetting, petBattleInitializer = Settings.SetupCVarCheckBox(category, "Sound_EnablePetBattleMusic", ENABLE_PET_BATTLE_MUSIC, OPTION_TOOLTIP_ENABLE_PET_BATTLE_MUSIC);
		local function IsModifiable()
			return musicSetting:GetValue();
		end
		petBattleInitializer:SetParentInitializer(musicInitializer, IsModifiable);
	end

	-- Sound Effects
	do
		local soundFXSetting, soundFXInitializer = Settings.SetupCVarCheckBox(category, "Sound_EnableSFX", ENABLE_SOUNDFX, OPTION_TOOLTIP_ENABLE_SOUNDFX);

		-- Pet Sounds
		local petSoundsSetting, petSoundsInitializer = Settings.SetupCVarCheckBox(category, "Sound_EnablePetSounds", ENABLE_PET_SOUNDS, OPTION_TOOLTIP_ENABLE_PET_SOUNDS);
		local function IsModifiable()
			return soundFXSetting:GetValue();
		end
		petSoundsInitializer:SetParentInitializer(soundFXInitializer, IsModifiable);
			
		-- Emote Sounds
		local emoteSoundsSetting, emoteSoundsInitializer = Settings.SetupCVarCheckBox(category, "Sound_EnableEmoteSounds", ENABLE_EMOTE_SOUNDS, OPTION_TOOLTIP_ENABLE_EMOTE_SOUNDS);
		local function IsModifiable()
			return soundFXSetting:GetValue();
		end
		emoteSoundsInitializer:SetParentInitializer(soundFXInitializer, IsModifiable);
	end

	-- Dialog
	do
		local dialogSetting, dialogInitializer = Settings.SetupCVarCheckBox(category, "Sound_EnableDialog", ENABLE_DIALOG, OPTION_TOOLTIP_ENABLE_DIALOG);

		-- Error Speech
		local errorSpeechSetting, errorSpeechInitializer = Settings.SetupCVarCheckBox(category, "Sound_EnableErrorSpeech", ENABLE_ERROR_SPEECH, OPTION_TOOLTIP_ENABLE_ERROR_SPEECH);
		local function IsModifiable()
			return dialogSetting:GetValue();
		end
		errorSpeechInitializer:SetParentInitializer(dialogInitializer, IsModifiable);
	end
	
	-- Ambient Sounds
	Settings.SetupCVarCheckBox(category, "Sound_EnableAmbience", ENABLE_AMBIENCE, OPTION_TOOLTIP_ENABLE_AMBIENCE);
	
	-- Sound in Background
	Settings.SetupCVarCheckBox(category, "Sound_EnableSoundWhenGameIsInBG", ENABLE_BGSOUND, OPTION_TOOLTIP_ENABLE_BGSOUND);

	-- Enable Reverb
	Settings.SetupCVarCheckBox(category, "Sound_EnableReverb", ENABLE_REVERB, OPTION_TOOLTIP_ENABLE_REVERB);

	-- Sound at Character
	Settings.SetupCVarCheckBox(category, "Sound_ListenerAtCharacter", ENABLE_SOUND_AT_CHARACTER, OPTION_TOOLTIP_ENABLE_SOUND_AT_CHARACTER);
	
	-- Distance Filtering
	Settings.SetupCVarCheckBox(category, "Sound_EnablePositionalLowPassFilter", ENABLE_SOFTWARE_HRTF, OPTION_TOOLTIP_ENABLE_SOFTWARE_HRTF);

	--Voice
	if not IsOnGlueScreen() then
		if C_VoiceChat.IsVoiceChatConnected() then
			InitVoiceSettings(category, layout);
		else
			local function ContinueInitVoiceSettings()
				InitVoiceSettings(category, layout);
			end
			EventUtil.ContinueAfterAllEvents(ContinueInitVoiceSettings, "VOICE_CHAT_CONNECTION_SUCCESS", "VOICE_CHAT_VAD_SETTINGS_UPDATED");
		end
	end
	
	Settings.RegisterCategory(category, SETTING_GROUP_SYSTEM);
end

SettingsRegistrar:AddRegistrant(Register);