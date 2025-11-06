RTTSMixin = CreateFromMixins(SettingsDropdownControlMixin);

function RTTSMixin:OnLoad()
	SettingsDropdownControlMixin.OnLoad(self);

	self.Button:ClearAllPoints();
	self.Button:SetPoint("TOPLEFT", self.Dropdown, "BOTTOMLEFT");
end

function RTTSMixin:Init(initializer)
	SettingsDropdownControlMixin.Init(self, initializer);
	
	local options = initializer.data.options();
	if #options == 0 then
		local function OnVoiceUpdate()
			local setting = self:GetSetting();
			self.Dropdown:SetValue(setting:GetValue());
			self:UnregisterEvent("VOICE_CHAT_TTS_VOICES_UPDATE");
		end

		EventUtil.RegisterOnceFrameEventAndCallback("VOICE_CHAT_TTS_VOICES_UPDATE", OnVoiceUpdate);
	end

	self.Button:SetText(TEXT_TO_SPEECH_PLAY_SAMPLE);
	self.Button:SetScript("OnClick", function()
		C_VoiceChat.SpeakRemoteTextSample(TEXT_TO_SPEECH_SAMPLE_TEXT);
	end);
end

function RTTSMixin:EvaluateState()
	local enabled = SettingsDropdownControlMixin.EvaluateState(self);
	self:SetButtonState(enabled);
end

function RTTSMixin:SetButtonState(enabled)
	self.Button:SetEnabled(enabled);
end

function RTTSMixin:OnSettingValueChanged(setting, value)
	SettingsDropdownControlMixin.OnSettingValueChanged(self, setting, value);
	self:SetButtonState(value);
end

function RTTSMixin:Release()
	SettingsDropdownControlMixin.Release(self);
	self.Button:SetScript("OnClick", nil);
end

local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(ACCESSIBILITY_AUDIO_LABEL);

	local function InitSettings(category)
		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(CHAT_TTS_LABEL));

		local voiceChatEnabled = C_VoiceChat.IsEnabled();

		local function AddTTSSearchTags(initializer)
			initializer:AddSearchTags(TEXT_TO_SPEECH, TEXT_TO_SPEECH_SHORT);
		end

		-- Transcribe Voice Chat
		if voiceChatEnabled then
			local setting = Settings.RegisterCVarSetting(category, "speechToText", Settings.VarType.Boolean, ENABLE_SPEECH_TO_TEXT_TRANSCRIPTION);
			local options = nil;
			local data = Settings.CreateSettingInitializerData(setting, options, OPTION_TOOLTIP_ENABLE_SPEECH_TO_TEXT_TRANSCRIPTION);
			local initializer = Settings.CreateSettingInitializer("STTTemplate", data);
			layout:AddInitializer(initializer);
		end

		-- Read Chat Text out Loud
		do
			local ttsSetting = Settings.RegisterCVarSetting(category, "textToSpeech", Settings.VarType.Boolean, ENABLE_TEXT_TO_SPEECH);
			local function OnButtonClick()
				ToggleTextToSpeechFrame();
			end;
			local initializer = CreateSettingsCheckboxWithButtonInitializer(ttsSetting, CONFIGURE_TEXT_TO_SPEECH, OnButtonClick, true, OPTION_TOOLTIP_ENABLE_TEXT_TO_SPEECH);
			AddTTSSearchTags(initializer);
			layout:AddInitializer(initializer);
		end

		-- Speak for me in Voice Chat
		if voiceChatEnabled then
			local rtttSetting, rtttInitializer = Settings.SetupCVarCheckbox(category, "remoteTextToSpeech", ENABLE_REMOTE_TEXT_TO_SPEECH, OPTION_TOOLTIP_ENABLE_REMOTE_TEXT_TO_SPEECH);

			local function IsSpeakForMeAllowed()
				return C_VoiceChat.IsSpeakForMeAllowed();
			end
			rtttInitializer:AddShownPredicate(IsSpeakForMeAllowed);
			rtttInitializer:AddEvaluateStateFrameEvent("VOICE_CHAT_SPEAK_FOR_ME_FEATURE_STATUS_UPDATED");
			
			-- Voices
			do
				local function GetVoiceOptions()
					local container = Settings.CreateControlTextContainer();
					for index, voice in ipairs(C_VoiceChat.GetRemoteTtsVoices()) do
						container:Add(voice.voiceID, VOICE_GENERIC_FORMAT:format(voice.voiceID));
					end
					return container:GetData();
				end

				local setting = Settings.RegisterCVarSetting(category, "remoteTextToSpeechVoice", Settings.VarType.Number, VOICE);
				local data = Settings.CreateSettingInitializerData(setting, GetVoiceOptions);

				local initializer = Settings.CreateSettingInitializer("RTTSTemplate", data);
				local function IsModifiable()
					return C_VoiceChat.IsSpeakForMeActive();
				end
				initializer:SetParentInitializer(rtttInitializer, IsModifiable);
				initializer:AddShownPredicate(IsSpeakForMeAllowed);
				initializer:AddEvaluateStateFrameEvent("VOICE_CHAT_SPEAK_FOR_ME_FEATURE_STATUS_UPDATED");
				initializer:AddEvaluateStateFrameEvent("VOICE_CHAT_SPEAK_FOR_ME_ACTIVE_STATUS_UPDATED");

				layout:AddInitializer(initializer);
			end
		end

		-- Combat Audio Alerts
		if voiceChatEnabled then
			-- Header
			do
				local initializer = CreateSettingsListSectionHeaderInitializer(CAA_COMBAT_AUDIO_ALERTS_LABEL, CAA_COMBAT_AUDIO_ALERTS_TOOLTIP);
				AddTTSSearchTags(initializer);
				initializer:AddSearchTags(CAA_SEARCH_TAG_SHORT);
				layout:AddInitializer(initializer);
			end

			-- Enable Combat Audio Alerts
			local caaEnableSetting, caaEnableInitializer = Settings.SetupCVarCheckbox(category, "CAAEnabled", CAA_ENABLE_COMBAT_AUDIO_ALERTS, CAA_ENABLE_COMBAT_AUDIO_ALERTS_TOOLTIP);
			caaEnableInitializer:AddSearchTags(CAA_SEARCH_TAG_SHORT);
			AddTTSSearchTags(caaEnableInitializer);

			local function CAAOptionsModifiable()
				return GetCVarBool("CAAEnabled");
			end

			local function AddCAASearchTags(initializer)
				initializer:AddSearchTags(CAA_COMBAT_AUDIO_ALERTS_LABEL, CAA_SEARCH_TAG_SHORT);
			end

			local function InitCAAOption(initializer)
				initializer:AddModifyPredicate(CAAOptionsModifiable);
				AddTTSSearchTags(initializer);
				AddCAASearchTags(initializer);
				initializer:AddEvaluateStateCVar("CAAEnabled");
			end

			-- Combat Speaker Voice
			do
				local function GetVoiceOptions()
					local container = Settings.CreateControlTextContainer();
					for index, voice in ipairs(C_VoiceChat.GetTtsVoices()) do
						container:Add(voice.voiceID, voice.name);
					end
					return container:GetData();
				end

				local setting = Settings.RegisterCVarSetting(category, "CAAVoice", Settings.VarType.Number, CAA_SPEAKER_VOICE_LABEL);
				local initializer = Settings.CreateDropdown(category, setting, GetVoiceOptions, CAA_SPEAKER_VOICE_TOOLTIP);
				InitCAAOption(initializer);
			end

			-- Combat Speaker Speed
			do
				local function GetValue()
					return C_CombatAudioAlert.GetSpeakerSpeed();
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetSpeakerSpeed(value);
				end

				local defaultValue = Constants.TTSConstants.TTSRateDefault;
				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_SPEED",
					Settings.VarType.Number, CAA_SPEAKER_SPEED_LABEL, defaultValue, GetValue, SetValue);

				local minValue, maxValue, step = Constants.TTSConstants.TTSRateMin, Constants.TTSConstants.TTSRateMax, 1;
				local options = Settings.CreateSliderOptions(minValue, maxValue, step);
				options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
				local initializer = Settings.CreateSlider(category, setting, options, CAA_SPEAKER_SPEED_TOOLTIP);
				InitCAAOption(initializer);
			end

			-- Combat Speaker Volume
			do
				local function GetValue()
					return C_CombatAudioAlert.GetSpeakerVolume();
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetSpeakerVolume(value);
				end

				local defaultValue = Constants.TTSConstants.TTSVolumeDefault;
				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_VOLUME",
					Settings.VarType.Number, CAA_SPEAKER_VOLUME_LABEL, defaultValue, GetValue, SetValue);

				local minValue, maxValue, step = Constants.TTSConstants.TTSVolumeMin, Constants.TTSConstants.TTSVolumeMax, 1;
				local options = Settings.CreateSliderOptions(minValue, maxValue, step);
				options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
				local initializer = Settings.CreateSlider(category, setting, options,CAA_SPEAKER_VOLUME_TOOLTIP);
				InitCAAOption(initializer);
			end

			local function GetPercentOptionString(percent)
				return EVERY_X_PERCENT:format(percent);
			end

			local function GetUnitHealthPercentOptions()
				local container = Settings.CreateControlTextContainer();
				container:Add(0, LOC_OPTION_OFF);
				container:Add(10, GetPercentOptionString(10));
				container:Add(20, GetPercentOptionString(20));
				container:Add(30, GetPercentOptionString(30));
				container:Add(40, GetPercentOptionString(40));
				container:Add(50, GetPercentOptionString(50));
				return container:GetData();
			end

			-- Say Your Health
			local sayPlayerHealthSetting = Settings.RegisterCVarSetting(category, "CAAPlayerHealthPercent", Settings.VarType.Number, CAA_SAY_PLAYER_HEALTH_LABEL);
			local sayPlayerHealthInitializer = Settings.CreateDropdown(category, sayPlayerHealthSetting, GetUnitHealthPercentOptions, CAA_SAY_PLAYER_HEALTH_TOOLTIP);
			InitCAAOption(sayPlayerHealthInitializer);

			local function SayPlayerHealthOptionsModifiable()
				return GetCVarNumberOrDefault("CAAPlayerHealthPercent") > 0;
			end

			local exampleHealthPercent = 20;

			-- Say Your Health Format
			do
				local function GetValue()
					return C_CombatAudioAlert.GetCurrentUnitHealthFormat(Enum.CombatAudioAlertUnit.Player);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetCurrentUnitHealthFormat(Enum.CombatAudioAlertUnit.Player, value);
				end

				local function GetFormatOptions()
					local container = Settings.CreateControlTextContainer();
					for cvarVal, formatInfo in CombatAudioAlertUtil.EnumerateUnitFormatInfo("player") do
						container:Add(cvarVal, CombatAudioAlertUtil.GetFormattedHealthString(formatInfo, exampleHealthPercent));
					end
					return container:GetData();
				end

				local defaultValue = Constants.CAAConstants.CAAPlayerHealthFormatDefault;
				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_PLAYER_HEALTH_FORMAT",
					Settings.VarType.Number, CAA_SAY_PLAYER_HEALTH_FORMAT_LABEL, defaultValue, GetValue, SetValue);
				local initializer = Settings.CreateDropdown(category, setting, GetFormatOptions, CAA_SAY_PLAYER_HEALTH_FORMAT_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayPlayerHealthInitializer, SayPlayerHealthOptionsModifiable);
			end

			local function FormatSeconds(value)
				return SECONDS_FLOAT_ABBR:format(value);
			end

			-- Say Health Throttle
			do
				local function GetValue()
					return C_CombatAudioAlert.GetThrottle(Enum.CombatAudioAlertUnit.Player);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetThrottle(Enum.CombatAudioAlertUnit.Player, value);
				end

				local defaultValue = Constants.CAAConstants.CAAThrottleDefault;
				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_PLAYER_HEALTH_THROTTLE",
					Settings.VarType.Number, CAA_SAY_PLAYER_HEALTH_THROTTLE_LABEL, defaultValue, GetValue, SetValue);

				local minValue, maxValue, step = Constants.CAAConstants.CAAThrottleMin, Constants.CAAConstants.CAAThrottleMax, Constants.CAAConstants.CAAThrottleStep;
				local options = Settings.CreateSliderOptions(minValue, maxValue, step);
				options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatSeconds);
				local initializer = Settings.CreateSlider(category, setting, options, CAA_SAY_PLAYER_HEALTH_THROTTLE_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayPlayerHealthInitializer, SayPlayerHealthOptionsModifiable);
			end

			-- Say Target Health
			local sayTargetHealthSetting = Settings.RegisterCVarSetting(category, "CAATargetHealthPercent", Settings.VarType.Number, CAA_SAY_TARGET_HEALTH_LABEL);
			local sayTargetHealthInitializer = Settings.CreateDropdown(category, sayTargetHealthSetting, GetUnitHealthPercentOptions, CAA_SAY_TARGET_HEALTH_TOOLTIP);
			InitCAAOption(sayTargetHealthInitializer);

			local function SayTargetHealthOptionsModifiable()
				return GetCVarNumberOrDefault("CAATargetHealthPercent") > 0;
			end

			-- Say Target Health Format
			do
				local function GetValue()
					return C_CombatAudioAlert.GetCurrentUnitHealthFormat(Enum.CombatAudioAlertUnit.Target);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetCurrentUnitHealthFormat(Enum.CombatAudioAlertUnit.Target, value);
				end

				local function GetFormatOptions()
					local container = Settings.CreateControlTextContainer();
					for cvarVal, formatInfo in CombatAudioAlertUtil.EnumerateUnitFormatInfo("target") do
						container:Add(cvarVal, CombatAudioAlertUtil.GetFormattedHealthString(formatInfo, exampleHealthPercent));
					end
					return container:GetData();
				end

				local defaultValue = Constants.CAAConstants.CAATargetHealthFormatDefault;
				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_TARGET_HEALTH_FORMAT",
					Settings.VarType.Number, CAA_SAY_PLAYER_HEALTH_FORMAT_LABEL, defaultValue, GetValue, SetValue);
				local initializer = Settings.CreateDropdown(category, setting, GetFormatOptions, CAA_SAY_PLAYER_HEALTH_FORMAT_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayTargetHealthInitializer, SayTargetHealthOptionsModifiable);
			end

			-- Say Target Throttle
			do
				local function GetValue()
					return C_CombatAudioAlert.GetThrottle(Enum.CombatAudioAlertUnit.Target);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetThrottle(Enum.CombatAudioAlertUnit.Target, value);
				end

				local defaultValue = Constants.CAAConstants.CAAThrottleDefault;
				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_TARGET_HEALTH_THROTTLE",
					Settings.VarType.Number, CAA_SAY_TARGET_HEALTH_THROTTLE_LABEL, defaultValue, GetValue, SetValue);

				local minValue, maxValue, step = Constants.CAAConstants.CAAThrottleMin, Constants.CAAConstants.CAAThrottleMax, Constants.CAAConstants.CAAThrottleStep;
				local options = Settings.CreateSliderOptions(minValue, maxValue, step);
				options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatSeconds);
				local initializer = Settings.CreateSlider(category, setting, options, CAA_SAY_TARGET_HEALTH_THROTTLE_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayTargetHealthInitializer, SayTargetHealthOptionsModifiable);
			end
		end
	end

	do
		local function InitVoices()
			local voices = C_VoiceChat.GetRemoteTtsVoices();
			if #voices > 0 then
				InitSettings(category);
			else
				EventUtil.RegisterOnceFrameEventAndCallback("VOICE_CHAT_TTS_VOICES_UPDATE", function()
					InitSettings(category);
				end);
			end
		end

		if not C_VoiceChat.IsEnabled() then
			-- If voice chat is disabled, there is no async dependency for voices to get loaded.
			InitSettings(category);
		elseif C_VoiceChat.IsVoiceChatConnected() then
			InitVoices();
		else
			EventUtil.RegisterOnceFrameEventAndCallback("VOICE_CHAT_CONNECTION_SUCCESS", function()
				InitVoices();
			end);
		end
	end

	Settings.RegisterCategory(category, SETTING_GROUP_ACCESSIBILITY);
end

SettingsRegistrar:AddRegistrant(Register);
