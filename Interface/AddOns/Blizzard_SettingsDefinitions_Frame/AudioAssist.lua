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
				local function GetOptions()
					local container = Settings.CreateControlTextContainer();
					for index, voice in ipairs(C_VoiceChat.GetTtsVoices()) do
						container:Add(voice.voiceID, voice.name);
					end
					return container:GetData();
				end

				local setting = Settings.RegisterCVarSetting(category, "CAAVoice", Settings.VarType.Number, CAA_SPEAKER_VOICE_LABEL);
				local initializer = Settings.CreateDropdown(category, setting, GetOptions, CAA_SPEAKER_VOICE_TOOLTIP);
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

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_SPEED",
					Settings.VarType.Number, CAA_SPEAKER_SPEED_LABEL, Constants.TTSConstants.TTSRateDefault, GetValue, SetValue);

				local options = Settings.CreateSliderOptions(Constants.TTSConstants.TTSRateMin, Constants.TTSConstants.TTSRateMax, 1);
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

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_VOLUME",
					Settings.VarType.Number, CAA_SPEAKER_VOLUME_LABEL, Constants.TTSConstants.TTSVolumeDefault, GetValue, SetValue);

				local options = Settings.CreateSliderOptions(Constants.TTSConstants.TTSVolumeMin, Constants.TTSConstants.TTSVolumeMax, 1);
				options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);

				local initializer = Settings.CreateSlider(category, setting, options,CAA_SPEAKER_VOLUME_TOOLTIP);
				InitCAAOption(initializer);
			end

			-- Say Combat Start
			do
				local setting = Settings.RegisterCVarSetting(category, "CAASayCombatStart", Settings.VarType.Number, CAA_SAY_COMBAT_START_LABEL);
				local function GetOptions()
					local container = Settings.CreateControlTextContainer();
					container:Add(0, LOC_OPTION_OFF);
					container:Add(1, CAA_SAY_COMBAT_START_TEXT);
					return container:GetData();
				end
				local initializer = Settings.CreateDropdown(category, setting, GetOptions, CAA_SAY_COMBAT_START_TOOLTIP);
				InitCAAOption(initializer);
			end

			-- Say Combat End
			do
				local setting = Settings.RegisterCVarSetting(category, "CAASayCombatEnd", Settings.VarType.Number, CAA_SAY_COMBAT_END_LABEL);
				local function GetOptions()
					local container = Settings.CreateControlTextContainer();
					container:Add(0, LOC_OPTION_OFF);
					container:Add(1, CAA_SAY_COMBAT_END_TEXT);
					return container:GetData();
				end
				local initializer = Settings.CreateDropdown(category, setting, GetOptions, CAA_SAY_COMBAT_END_TOOLTIP);
				InitCAAOption(initializer);
			end

			local function GetPercentOptionString(percent)
				return EVERY_X_PERCENT:format(percent);
			end

			local function GetPercentOptions()
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
			local sayPlayerHealthInitializer = Settings.CreateDropdown(category, sayPlayerHealthSetting, GetPercentOptions, CAA_SAY_PLAYER_HEALTH_TOOLTIP);
			InitCAAOption(sayPlayerHealthInitializer);

			local function SayPlayerHealthOptionsModifiable()
				return GetCVarNumberOrDefault("CAAPlayerHealthPercent") > 0;
			end

			local examplePercent = 20;

			-- Say Your Health Format
			do
				local function GetValue()
					return C_CombatAudioAlert.GetFormatSetting(Enum.CombatAudioAlertUnit.Player, Enum.CombatAudioAlertType.Health);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetFormatSetting(Enum.CombatAudioAlertUnit.Player, Enum.CombatAudioAlertType.Health, value);
				end

				local function GetOptions()
					local container = Settings.CreateControlTextContainer();
					for cvarVal, formatInfo in CombatAudioAlertUtil.EnumerateUnitFormatInfo("player", Enum.CombatAudioAlertType.Health) do
						container:Add(cvarVal, CombatAudioAlertUtil.GetFormattedString(formatInfo, nil, examplePercent));
					end
					return container:GetData();
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_PLAYER_HEALTH_FORMAT",
					Settings.VarType.Number, CAA_SAY_PLAYER_HEALTH_FORMAT_LABEL, Constants.CAAConstants.CAAPlayerHealthFormatDefault, GetValue, SetValue);

				local initializer = Settings.CreateDropdown(category, setting, GetOptions, CAA_SAY_PLAYER_HEALTH_FORMAT_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayPlayerHealthInitializer, SayPlayerHealthOptionsModifiable);
			end

			local function FormatSeconds(value)
				return SECONDS_FLOAT_ABBR:format(value);
			end

			-- Say Health Throttle
			do
				local function GetValue()
					return C_CombatAudioAlert.GetThrottle(Enum.CombatAudioAlertThrottle.PlayerHealth);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetThrottle(Enum.CombatAudioAlertThrottle.PlayerHealth, value);
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_PLAYER_HEALTH_THROTTLE",
					Settings.VarType.Number, CAA_SAY_PLAYER_HEALTH_THROTTLE_LABEL, Constants.CAAConstants.CAAThrottleDefault, GetValue, SetValue);

				local options = Settings.CreateSliderOptions(Constants.CAAConstants.CAAThrottleMin, Constants.CAAConstants.CAAThrottleMax, Constants.CAAConstants.CAAThrottleStep);
				options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatSeconds);

				local initializer = Settings.CreateSlider(category, setting, options, CAA_SAY_PLAYER_HEALTH_THROTTLE_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayPlayerHealthInitializer, SayPlayerHealthOptionsModifiable);
			end

			-- Say Target Name
			do
				local setting, initializer = Settings.SetupCVarCheckbox(category, "CAASayTargetName", CAA_SAY_TARGET_NAME_LABEL, CAA_SAY_TARGET_NAME_TOOLTIP);
				InitCAAOption(initializer);
			end

			-- Say Target Health
			local sayTargetHealthSetting = Settings.RegisterCVarSetting(category, "CAATargetHealthPercent", Settings.VarType.Number, CAA_SAY_TARGET_HEALTH_LABEL);
			local sayTargetHealthInitializer = Settings.CreateDropdown(category, sayTargetHealthSetting, GetPercentOptions, CAA_SAY_TARGET_HEALTH_TOOLTIP);
			InitCAAOption(sayTargetHealthInitializer);

			local function SayTargetHealthOptionsModifiable()
				return GetCVarNumberOrDefault("CAATargetHealthPercent") > 0;
			end

			-- Say Target Health Format
			do
				local function GetValue()
					return C_CombatAudioAlert.GetFormatSetting(Enum.CombatAudioAlertUnit.Target, Enum.CombatAudioAlertType.Health);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetFormatSetting(Enum.CombatAudioAlertUnit.Target, Enum.CombatAudioAlertType.Health, value);
				end

				local function GetOptions()
					local container = Settings.CreateControlTextContainer();
					for cvarVal, formatInfo in CombatAudioAlertUtil.EnumerateUnitFormatInfo("target", Enum.CombatAudioAlertType.Health) do
						container:Add(cvarVal, CombatAudioAlertUtil.GetFormattedString(formatInfo, nil, examplePercent));
					end
					return container:GetData();
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_TARGET_HEALTH_FORMAT",
					Settings.VarType.Number, CAA_SAY_TARGET_HEALTH_FORMAT_LABEL, Constants.CAAConstants.CAATargetHealthFormatDefault, GetValue, SetValue);

				local initializer = Settings.CreateDropdown(category, setting, GetOptions, CAA_SAY_TARGET_HEALTH_FORMAT_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayTargetHealthInitializer, SayTargetHealthOptionsModifiable);
			end

			-- When Target Dies Behavior
			do
				local setting = Settings.RegisterCVarSetting(category, "CAATargetDeathBehavior", Settings.VarType.Number, CAA_WHEN_TARGET_DIES_LABEL);
				local function GetOptions()
					local container = Settings.CreateControlTextContainer();
					container:Add(Enum.CombatAudioAlertTargetDeathBehavior.Default, CAA_WHEN_TARGET_DIES_USE_FORMAT);
					container:Add(Enum.CombatAudioAlertTargetDeathBehavior.SayTargetDead, CAA_WHEN_TARGET_DIES_VOICE_TARGET_DEAD);
					return container:GetData();
				end
				local initializer = Settings.CreateDropdown(category, setting, GetOptions, CAA_WHEN_TARGET_DIES_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayTargetHealthInitializer, SayTargetHealthOptionsModifiable);
			end

			-- Say Target Throttle
			do
				local function GetValue()
					return C_CombatAudioAlert.GetThrottle(Enum.CombatAudioAlertThrottle.TargetHealth);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetThrottle(Enum.CombatAudioAlertThrottle.TargetHealth, value);
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_TARGET_HEALTH_THROTTLE",
					Settings.VarType.Number, CAA_SAY_TARGET_HEALTH_THROTTLE_LABEL, Constants.CAAConstants.CAAThrottleDefault, GetValue, SetValue);

				local options = Settings.CreateSliderOptions(Constants.CAAConstants.CAAThrottleMin, Constants.CAAConstants.CAAThrottleMax, Constants.CAAConstants.CAAThrottleStep);
				options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatSeconds);

				local initializer = Settings.CreateSlider(category, setting, options, CAA_SAY_TARGET_HEALTH_THROTTLE_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayTargetHealthInitializer, SayTargetHealthOptionsModifiable);
			end

			-- Player Resource Options
			local resource1PowerName, resource2PowerName;

			local function GetResourceSettingFormattedString(formatString, primary)
				local _resource1PowerType, resource1PowerToken = UnitPowerType("player");
				resource1PowerName = resource1PowerToken and _G[resource1PowerToken];

				local _resource2PowerType, resource2PowerToken = GetUnitSecondaryPowerInfo("player");
				resource2PowerName = resource2PowerToken and _G[resource2PowerToken];

				local powerName = primary and resource1PowerName or resource2PowerName;
				if powerName then
					return formatString:format(powerName);
				end

				-- Important:
				-- This empty string return is what causes the resource settings to hide if the player's spec doesn't use a resource (see IsResource1Allowed and IsResource2Allowed)
				-- It must return a string (rather than nil) or ErrorIfInvalidSettingArguments will error
				return "";
			end

			-- Player Resource 1 Options
			local isPrimaryYes = true;

			local function GetResource1Label()
				return GetResourceSettingFormattedString(CAA_SAY_PLAYER_RESOURCE_LABEL, isPrimaryYes);
			end

			local function IsResource1Allowed()
				return GetResource1Label() ~= "";
			end

			local function InitCAAResource1Option(initializer)
				initializer:AddShownPredicate(IsResource1Allowed);
				InitCAAOption(initializer);
			end

			-- Say Resource 1
			local function GetResource1Value()
				return C_CombatAudioAlert.GetResourceSettingForCurrentSpec(Enum.CombatAudioAlertResourceSetting.Resource1Percent);
			end

			local function SetResource1Value(value)
				C_CombatAudioAlert.SetResourceSettingForCurrentSpec(Enum.CombatAudioAlertResourceSetting.Resource1Percent, value);
			end

			local sayResource1Setting = Settings.RegisterProxySetting(category, "PROXY_CAA_PLAYER_RESOURCE_1_PERCENT",
				Settings.VarType.Number, GetResource1Label, Constants.CAAConstants.CAAPlayerResourcePercentDefault, GetResource1Value, SetResource1Value);
			local sayResource1Initializer = Settings.CreateDropdown(category, sayResource1Setting, GetPercentOptions, GetResourceSettingFormattedString(CAA_SAY_PLAYER_RESOURCE_TOOLTIP, isPrimaryYes));
			InitCAAResource1Option(sayResource1Initializer);

			local function SayResource1OptionsModifiable()
				return GetResource1Value() > 0;
			end

			-- Say Resource 1 Format
			do
				local function GetValue()
					return C_CombatAudioAlert.GetResourceSettingForCurrentSpec(Enum.CombatAudioAlertResourceSetting.Resource1Format);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetResourceSettingForCurrentSpec(Enum.CombatAudioAlertResourceSetting.Resource1Format, value);
				end

				local function GetOptions()
					local container = Settings.CreateControlTextContainer();
					for cvarVal, formatInfo in CombatAudioAlertUtil.EnumeratePlayerResourceFormatInfo() do
						container:Add(cvarVal, CombatAudioAlertUtil.GetFormattedString(formatInfo, resource1PowerName, examplePercent));
					end
					return container:GetData();
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_PLAYER_RESOURCE_1_FORMAT",
					Settings.VarType.Number, CAA_SAY_PLAYER_RESOURCE_FORMAT_LABEL, Constants.CAAConstants.CAAPlayerResourceFormatDefault, GetValue, SetValue);

				local initializer = Settings.CreateDropdown(category, setting, GetOptions, GetResourceSettingFormattedString(CAA_SAY_PLAYER_RESOURCE_FORMAT_TOOLTIP, isPrimaryYes));
				InitCAAResource1Option(initializer);
				initializer:SetParentInitializer(sayResource1Initializer, SayResource1OptionsModifiable);
			end

			-- Say Resource 1 Throttle
			do
				local function GetValue()
					return C_CombatAudioAlert.GetThrottle(Enum.CombatAudioAlertThrottle.PlayerResource1);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetThrottle(Enum.CombatAudioAlertThrottle.PlayerResource1, value);
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_PLAYER_RESOURCE_1_THROTTLE",
					Settings.VarType.Number, CAA_SAY_PLAYER_RESOURCE_THROTTLE_LABEL, Constants.CAAConstants.CAAThrottleDefault, GetValue, SetValue);

				local options = Settings.CreateSliderOptions(Constants.CAAConstants.CAAThrottleMin, Constants.CAAConstants.CAAThrottleMax, Constants.CAAConstants.CAAThrottleStep);
				options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatSeconds);

				local initializer = Settings.CreateSlider(category, setting, options, GetResourceSettingFormattedString(CAA_SAY_PLAYER_RESOURCE_THROTTLE_TOOLTIP, isPrimaryYes));
				InitCAAResource1Option(initializer);
				initializer:SetParentInitializer(sayResource1Initializer, SayResource1OptionsModifiable);
			end

			-- Player Resource 2 Options
			local isPrimaryNo = false;
			local function GetResource2Label()
				return GetResourceSettingFormattedString(CAA_SAY_PLAYER_RESOURCE_LABEL, isPrimaryNo);
			end

			local function IsResource2Allowed()
				return GetResource2Label() ~= "";
			end

			local function InitCAAResource2Option(initializer)
				initializer:AddShownPredicate(IsResource2Allowed);
				InitCAAOption(initializer);
			end

			-- Say Resource 2
			local function GetResource2Value()
				return C_CombatAudioAlert.GetResourceSettingForCurrentSpec(Enum.CombatAudioAlertResourceSetting.Resource2Percent);
			end

			local function SetResource2Value(value)
				C_CombatAudioAlert.SetResourceSettingForCurrentSpec(Enum.CombatAudioAlertResourceSetting.Resource2Percent, value);
			end

			local sayResource2Setting = Settings.RegisterProxySetting(category, "PROXY_CAA_PLAYER_RESOURCE_2_PERCENT",
				Settings.VarType.Number, GetResource2Label, Constants.CAAConstants.CAAPlayerResourcePercentDefault, GetResource2Value, SetResource2Value);
			local sayResource2Initializer = Settings.CreateDropdown(category, sayResource2Setting, GetPercentOptions, GetResourceSettingFormattedString(CAA_SAY_PLAYER_RESOURCE_TOOLTIP, isPrimaryNo));
			InitCAAResource2Option(sayResource2Initializer);

			local function SayResource2OptionsModifiable()
				return GetResource2Value() > 0;
			end

			-- Say Resource 2 Format
			do
				local function GetValue()
					return C_CombatAudioAlert.GetResourceSettingForCurrentSpec(Enum.CombatAudioAlertResourceSetting.Resource2Format);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetResourceSettingForCurrentSpec(Enum.CombatAudioAlertResourceSetting.Resource2Format, value);
				end

				local function GetOptions()
					local container = Settings.CreateControlTextContainer();
					for cvarVal, formatInfo in CombatAudioAlertUtil.EnumeratePlayerResourceFormatInfo() do
						container:Add(cvarVal, CombatAudioAlertUtil.GetFormattedString(formatInfo, resource2PowerName, examplePercent));
					end
					return container:GetData();
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_PLAYER_RESOURCE_2_FORMAT",
					Settings.VarType.Number, CAA_SAY_PLAYER_RESOURCE_FORMAT_LABEL, Constants.CAAConstants.CAAPlayerResourceFormatDefault, GetValue, SetValue);

				local initializer = Settings.CreateDropdown(category, setting, GetOptions, GetResourceSettingFormattedString(CAA_SAY_PLAYER_RESOURCE_FORMAT_TOOLTIP, isPrimaryNo));
				InitCAAResource2Option(initializer);
				initializer:SetParentInitializer(sayResource2Initializer, SayResource2OptionsModifiable);
			end

			-- Say Resource 2 Throttle
			do
				local function GetValue()
					return C_CombatAudioAlert.GetThrottle(Enum.CombatAudioAlertThrottle.PlayerResource2);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetThrottle(Enum.CombatAudioAlertThrottle.PlayerResource2, value);
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_PLAYER_RESOURCE_2_THROTTLE",
					Settings.VarType.Number, CAA_SAY_PLAYER_RESOURCE_THROTTLE_LABEL, Constants.CAAConstants.CAAThrottleDefault, GetValue, SetValue);

				local options = Settings.CreateSliderOptions(Constants.CAAConstants.CAAThrottleMin, Constants.CAAConstants.CAAThrottleMax, Constants.CAAConstants.CAAThrottleStep);
				options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatSeconds);

				local initializer = Settings.CreateSlider(category, setting, options, GetResourceSettingFormattedString(CAA_SAY_PLAYER_RESOURCE_THROTTLE_TOOLTIP, isPrimaryNo));
				InitCAAResource2Option(initializer);
				initializer:SetParentInitializer(sayResource2Initializer, SayResource2OptionsModifiable);
			end

			local function GetCastModeOptions()
				local container = Settings.CreateControlTextContainer();
				container:Add(Enum.CombatAudioAlertCastState.Off, LOC_OPTION_OFF);
				container:Add(Enum.CombatAudioAlertCastState.OnCastStart, CAA_SAY_CASTS_START_OF_CAST);
				container:Add(Enum.CombatAudioAlertCastState.OnCastEnd, CAA_SAY_CASTS_END_OF_CAST);
				return container:GetData();
			end

			-- Say Player Cast
			local sayPlayerCastSetting = Settings.RegisterCVarSetting(category, "CAAPlayerCastMode", Settings.VarType.Number, CAA_SAY_PLAYER_CASTS_LABEL);
			local sayPlayerCastInitializer = Settings.CreateDropdown(category, sayPlayerCastSetting, GetCastModeOptions, CAA_SAY_PLAYER_CASTS_TOOLTIP);
			InitCAAOption(sayPlayerCastInitializer);

			local function SayPlayerCastOptionsModifiable()
				return GetCVarNumberOrDefault("CAAPlayerCastMode") > 0;
			end

			-- Say Player Cast Format
			do
				local function GetValue()
					return C_CombatAudioAlert.GetFormatSetting(Enum.CombatAudioAlertUnit.Player, Enum.CombatAudioAlertType.Cast);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetFormatSetting(Enum.CombatAudioAlertUnit.Player, Enum.CombatAudioAlertType.Cast, value);
				end

				local function GetOptions()
					local container = Settings.CreateControlTextContainer();
					for cvarVal, formatInfo in CombatAudioAlertUtil.EnumerateUnitFormatInfo("player", Enum.CombatAudioAlertType.Cast) do
						container:Add(cvarVal, CombatAudioAlertUtil.GetFormattedString(formatInfo, CAA_SAMPLE_SPELLNAME));
					end
					return container:GetData();
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_PLAYER_CAST_FORMAT",
					Settings.VarType.Number, CAA_SAY_PLAYER_CASTS_FORMAT_LABEL, Constants.CAAConstants.CAAPlayerCastFormatDefault, GetValue, SetValue);

				local initializer = Settings.CreateDropdown(category, setting, GetOptions, CAA_SAY_PLAYER_CASTS_FORMAT_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayPlayerCastInitializer, SayPlayerCastOptionsModifiable);
			end

			-- Say Player Cast Min Cast TIme
			do
				local setting = Settings.RegisterCVarSetting(category, "CAAPlayerCastMinTime", Settings.VarType.Number, CAA_SAY_PLAYER_CASTS_MIN_CAST_TIME_LABEL);

				local options = Settings.CreateSliderOptions(Constants.CAAConstants.CAAMinCastTimeMin, Constants.CAAConstants.CAAMinCastTimeMax, Constants.CAAConstants.CAAMinCastTimeStep);
				options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatSeconds);

				local initializer = Settings.CreateSlider(category, setting, options, CAA_SAY_PLAYER_CASTS_MIN_CAST_TIME_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayPlayerCastInitializer, SayPlayerCastOptionsModifiable);
			end

			-- Say Player Cast Throttle
			do
				local function GetValue()
					return C_CombatAudioAlert.GetThrottle(Enum.CombatAudioAlertThrottle.PlayerCast);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetThrottle(Enum.CombatAudioAlertThrottle.PlayerCast, value);
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_PLAYER_CAST_THROTTLE",
					Settings.VarType.Number, CAA_SAY_PLAYER_CASTS_THROTTLE_LABEL, Constants.CAAConstants.CAAThrottleDefault, GetValue, SetValue);

				local options = Settings.CreateSliderOptions(Constants.CAAConstants.CAAThrottleMin, Constants.CAAConstants.CAAThrottleMax, Constants.CAAConstants.CAAThrottleStep);
				options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatSeconds);

				local initializer = Settings.CreateSlider(category, setting, options, CAA_SAY_PLAYER_CASTS_THROTTLE_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayPlayerCastInitializer, SayPlayerCastOptionsModifiable);
			end

			-- Say Target Cast
			local sayTargetCastSetting = Settings.RegisterCVarSetting(category, "CAATargetCastMode", Settings.VarType.Number, CAA_SAY_TARGET_CASTS_LABEL);
			local sayTargetCastInitializer = Settings.CreateDropdown(category, sayTargetCastSetting, GetCastModeOptions, CAA_SAY_TARGET_CASTS_TOOLTIP);
			InitCAAOption(sayTargetCastInitializer);

			local function SayTargetCastOptionsModifiable()
				return GetCVarNumberOrDefault("CAATargetCastMode") > 0;
			end

			-- Say Target Cast Format
			do
				local function GetValue()
					return C_CombatAudioAlert.GetFormatSetting(Enum.CombatAudioAlertUnit.Target, Enum.CombatAudioAlertType.Cast);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetFormatSetting(Enum.CombatAudioAlertUnit.Target, Enum.CombatAudioAlertType.Cast, value);
				end

				local function GetOptions()
					local container = Settings.CreateControlTextContainer();
					for cvarVal, formatInfo in CombatAudioAlertUtil.EnumerateUnitFormatInfo("target", Enum.CombatAudioAlertType.Cast) do
						container:Add(cvarVal, CombatAudioAlertUtil.GetFormattedString(formatInfo, CAA_SAMPLE_SPELLNAME));
					end
					return container:GetData();
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_TARGET_CAST_FORMAT",
					Settings.VarType.Number, CAA_SAY_TARGET_CASTS_FORMAT_LABEL, Constants.CAAConstants.CAATargetCastFormatDefault, GetValue, SetValue);

				local initializer = Settings.CreateDropdown(category, setting, GetOptions, CAA_SAY_TARGET_CASTS_FORMAT_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayTargetCastInitializer, SayTargetCastOptionsModifiable);
			end

			-- Say Target Cast Min Cast TIme
			do
				local setting = Settings.RegisterCVarSetting(category, "CAATargetCastMinTime", Settings.VarType.Number, CAA_SAY_TARGET_CASTS_MIN_CAST_TIME_LABEL);

				local options = Settings.CreateSliderOptions(Constants.CAAConstants.CAAMinCastTimeMin, Constants.CAAConstants.CAAMinCastTimeMax, Constants.CAAConstants.CAAMinCastTimeStep);
				options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatSeconds);

				local initializer = Settings.CreateSlider(category, setting, options, CAA_SAY_TARGET_CASTS_MIN_CAST_TIME_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayTargetCastInitializer, SayTargetCastOptionsModifiable);
			end

			-- Say Target Cast Throttle
			do
				local function GetValue()
					return C_CombatAudioAlert.GetThrottle(Enum.CombatAudioAlertThrottle.TargetCast);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetThrottle(Enum.CombatAudioAlertThrottle.TargetCast, value);
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_TARGET_CAST_THROTTLE",
					Settings.VarType.Number, CAA_SAY_TARGET_CASTS_THROTTLE_LABEL, Constants.CAAConstants.CAAThrottleDefault, GetValue, SetValue);

				local options = Settings.CreateSliderOptions(Constants.CAAConstants.CAAThrottleMin, Constants.CAAConstants.CAAThrottleMax, Constants.CAAConstants.CAAThrottleStep);
				options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatSeconds);

				local initializer = Settings.CreateSlider(category, setting, options, CAA_SAY_TARGET_CASTS_THROTTLE_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayTargetCastInitializer, SayTargetCastOptionsModifiable);
			end

			-- Interrupt Alert
			do
				local setting = Settings.RegisterCVarSetting(category, "CAAInterruptCast", Settings.VarType.Number, CAA_SAY_TARGET_CASTS_INTERRUPT_LABEL);
				local function GetOptions()
					local container = Settings.CreateControlTextContainer();
					container:Add(0, LOC_OPTION_OFF);
					container:Add(1, CAA_SAY_TARGET_CASTS_INTERRUPT_TEXT);
					return container:GetData();
				end
				local initializer = Settings.CreateDropdown(category, setting, GetOptions, CAA_SAY_TARGET_CASTS_INTERRUPT_TOOLTIP);
				InitCAAOption(initializer);
			end

			-- Successful Interrupt Alert
			do
				local setting = Settings.RegisterCVarSetting(category, "CAAInterruptCastSuccess", Settings.VarType.Number, CAA_SAY_TARGET_CASTS_INTERRUPT_SUCCESS_LABEL);
				local function GetOptions()
					local container = Settings.CreateControlTextContainer();
					container:Add(0, LOC_OPTION_OFF);
					container:Add(1, CAA_SAY_TARGET_CAST_INTERRUPT_SUCCESS_TEXT);
					return container:GetData();
				end
				local initializer = Settings.CreateDropdown(category, setting, GetOptions, CAA_SAY_TARGET_CASTS_INTERRUPT_SUCCESS_TOOLTIP);
				InitCAAOption(initializer);
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
