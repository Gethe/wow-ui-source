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

local function GetVoiceOptions()
	local container = Settings.CreateControlTextContainer();
	for _index, voice in ipairs(C_VoiceChat.GetTtsVoices()) do
		container:Add(voice.voiceID, voice.name);
	end
	return container:GetData();
end

local function InitScreenNarrationSettings(category, layout)
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(SCREEN_NARRATOR));

	local function IsScreenNarrationEnabled()
		return CVarCallbackRegistry:GetCVarValueBool("accessibilityScreenNarrationEnabled");
	end

	local _enabledSetting, enabledInitializer = Settings.SetupCVarCheckbox(category, "accessibilityScreenNarrationEnabled", ENABLE_SCREEN_NARRATOR, OPTION_TOOLTIP_ENABLE_SCREEN_NARRATOR);

	do
		local _setting, initializer = Settings.SetupCVarDropdown(category, "accessibilityScreenNarrationVoice", Settings.VarType.Number, GetVoiceOptions, SCREEN_NARRATOR_VOICE, OPTION_TOOLTIP_SCREEN_NARRATOR_VOICE);
		initializer:SetParentInitializer(enabledInitializer, IsScreenNarrationEnabled);
	end

	do
		local setting = Settings.RegisterCVarSetting(category, "accessibilityScreenNarrationSpeechRate", Settings.VarType.Number, SCREEN_NARRATOR_SPEECH_RATE);
		local minValue, maxValue, step = Constants.TTSConstants.TTSRateMin, Constants.TTSConstants.TTSRateMax, 1;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
		local initializer = Settings.CreateSlider(category, setting, options, OPTION_TOOLTIP_SCREEN_NARRATOR_SPEECH_RATE);
		initializer:SetParentInitializer(enabledInitializer, IsScreenNarrationEnabled);
	end

	do
		local setting = Settings.RegisterCVarSetting(category, "accessibilityScreenNarrationSpeechVolume", Settings.VarType.Number, SCREEN_NARRATOR_SPEECH_VOLUME);
		local minValue, maxValue, step = Constants.TTSConstants.TTSVolumeMin, Constants.TTSConstants.TTSVolumeMax, 1;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
		local initializer = Settings.CreateSlider(category, setting, options, OPTION_TOOLTIP_SCREEN_NARRATOR_SPEECH_VOLUME);
		initializer:SetParentInitializer(enabledInitializer, IsScreenNarrationEnabled);
	end
end

local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(ACCESSIBILITY_AUDIO_LABEL);

	local function InitGameSettings(category)
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
			local initializer = CreateSettingsCheckboxWithButtonInitializer(ttsSetting, CONFIGURE_TEXT_TO_SPEECH, OnButtonClick, nil, true, OPTION_TOOLTIP_ENABLE_TEXT_TO_SPEECH);
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
				local function GetRemoteTtsVoiceFormatedString(voiceID)
					local formatString;
					if voiceID == 1 then
						formatString = VOICE_GENERIC_FORMAT_MASCULINE;
					elseif voiceID == 2 then
						formatString = VOICE_GENERIC_FORMAT_FEMININE;
					else
						formatString = VOICE_GENERIC_FORMAT;
					end
					return formatString:format(voiceID);
				end

				local function GetRemoteVoiceOptions()
					local container = Settings.CreateControlTextContainer();
					for _index, voice in ipairs(C_VoiceChat.GetRemoteTtsVoices()) do
						container:Add(voice.voiceID, GetRemoteTtsVoiceFormatedString(voice.voiceID));
					end
					return container:GetData();
				end

				local setting = Settings.RegisterCVarSetting(category, "remoteTextToSpeechVoice", Settings.VarType.Number, VOICE);
				local data = Settings.CreateSettingInitializerData(setting, GetRemoteVoiceOptions);

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

		InitScreenNarrationSettings(category, layout);

		-- Combat Audio Alerts
		if voiceChatEnabled then
			-- CooldownViewerSound enum elements have fixed values. In order to not have any overlap between those values and non-sound dropdown elements, a fixed offset is added when using them with the cvar system.
			-- When referenced elsewhere, this offset should be removed in order to correctly look up the associated sound info.
			local function CooldownViewerSoundToCAAValue(value)
				return value + CombatAudioAlertConstants.COOLDOWN_VIEWER_SOUND_OFFSET;
			end

			-- Header
			do
				local _sectionTooltip = nil;
				local sectionNewTagID = "CAA_COMBAT_AUDIO_ALERTS_LABEL";
				local initializer = CreateSettingsListSectionHeaderInitializer(CAA_COMBAT_AUDIO_ALERTS_LABEL, _sectionTooltip, sectionNewTagID);
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
					return C_CombatAudioAlert.GetCategoryVolume(Enum.CombatAudioAlertCategory.General);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetCategoryVolume(Enum.CombatAudioAlertCategory.General, value);
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
				local cvarCombatStart = "CAASayCombatStart";
				local setting = Settings.RegisterCVarSetting(category, cvarCombatStart, Settings.VarType.Number, CAA_SAY_COMBAT_START_LABEL);
				local function GetOptions()
					local container = Settings.CreateControlTextContainer();
					for index, info in CombatAudioAlertUtil.EnumerateSayCombatStartInfo() do
						container:Add(index - 1, info.str);
					end
					return container:GetData();
				end
				local initializer = Settings.CreateDropdown(category, setting, GetOptions, CAA_SAY_COMBAT_START_TOOLTIP);

				-- Add in Cooldown Viewer audio sounds as valid options.
				-- Offset the soundEnum value by the other options listed above to be valid for the cvar.
				local function IsSelected(soundEnum)
					return Settings.GetValue(cvarCombatStart) == CooldownViewerSoundToCAAValue(soundEnum);
				end

				local function SetSelected(soundEnum)
					Settings.SetValue(cvarCombatStart, CooldownViewerSoundToCAAValue(soundEnum));
				end

				initializer.customOptionHandler = function (rootDescription)
					local useHighlightStyle = true;
					CooldownViewerUtil.BuildSoundMenus(rootDescription, IsSelected, SetSelected, useHighlightStyle);
				end;

				InitCAAOption(initializer);
			end

			-- Say Combat End
			do
				local cvarCombatEnd = "CAASayCombatEnd";
				local setting = Settings.RegisterCVarSetting(category, cvarCombatEnd, Settings.VarType.Number, CAA_SAY_COMBAT_END_LABEL);
				local function GetOptions()
					local container = Settings.CreateControlTextContainer();
					for index, info in CombatAudioAlertUtil.EnumerateSayCombatEndInfo() do
						container:Add(index - 1, info.str);
					end
					return container:GetData();
				end
				local initializer = Settings.CreateDropdown(category, setting, GetOptions, CAA_SAY_COMBAT_END_TOOLTIP);

				-- Add in Cooldown Viewer audio sounds as valid options.
				-- Offset the soundEnum value by the other options listed above to be valid for the cvar.
				local function IsSelected(soundEnum)
					return Settings.GetValue(cvarCombatEnd) == CooldownViewerSoundToCAAValue(soundEnum);
				end

				local function SetSelected(soundEnum)
					Settings.SetValue(cvarCombatEnd, CooldownViewerSoundToCAAValue(soundEnum));
				end

				initializer.customOptionHandler = function (rootDescription)
					local useHighlightStyle = true;
					CooldownViewerUtil.BuildSoundMenus(rootDescription, IsSelected, SetSelected, useHighlightStyle);
				end;

				InitCAAOption(initializer);
			end

			local function GetPercentOptions()
				local container = Settings.CreateControlTextContainer();
				for index, percentInfo in CombatAudioAlertUtil.EnumeratePercentInfo() do
					container:Add(index - 1, percentInfo.str);
				end
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
					for index, formatInfo in CombatAudioAlertUtil.EnumerateUnitFormatInfo("player", Enum.CombatAudioAlertType.Health) do
						container:Add(index - 1, CombatAudioAlertUtil.GetFormattedString(formatInfo, nil, examplePercent));
					end
					return container:GetData();
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_PLAYER_HEALTH_FORMAT",
					Settings.VarType.Number, CAA_SAY_PLAYER_HEALTH_FORMAT_LABEL, Constants.CAAConstants.CAAPlayerHealthFormatDefault, GetValue, SetValue);

				local initializer = Settings.CreateDropdown(category, setting, GetOptions, CAA_SAY_PLAYER_HEALTH_FORMAT_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayPlayerHealthInitializer, SayPlayerHealthOptionsModifiable);
			end

			-- Say Your Health Voice
			do
				local setting = Settings.RegisterCVarSetting(category, "CAAPlayerHealthVoice", Settings.VarType.Number, CAA_VOICE_LABEL);
				local initializer = Settings.CreateDropdown(category, setting, GetVoiceOptions, CAA_SAY_PLAYER_HEALTH_VOICE_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayPlayerHealthInitializer, SayPlayerHealthOptionsModifiable);
			end

			local function FormatSeconds(value)
				return SECONDS_FLOAT_ABBR:format(value);
			end

			-- Say Your Health Throttle
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

			-- Say Your Health Volume
			do
				local function GetValue()
					return C_CombatAudioAlert.GetCategoryVolume(Enum.CombatAudioAlertCategory.PlayerHealth);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetCategoryVolume(Enum.CombatAudioAlertCategory.PlayerHealth, value);
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_PLAYER_HEALTH_VOLUME",
					Settings.VarType.Number, CAA_VOLUME_LABEL, Constants.TTSConstants.TTSVolumeDefault, GetValue, SetValue);

				local options = Settings.CreateSliderOptions(Constants.TTSConstants.TTSVolumeMin, Constants.TTSConstants.TTSVolumeMax, 1);
				options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);

				local initializer = Settings.CreateSlider(category, setting, options, CAA_SAY_PLAYER_HEALTH_VOLUME_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayPlayerHealthInitializer, SayPlayerHealthOptionsModifiable);
			end

			-- Say Target Name
			do
				local setting, initializer = Settings.SetupCVarCheckbox(category, "CAASayTargetName", CAA_SAY_TARGET_NAME_LABEL, CAA_SAY_TARGET_NAME_TOOLTIP);
				InitCAAOption(initializer);
			end

			-- Say If Targeted
			do
				local function GetValue()
					return C_CombatAudioAlert.GetSpecSetting(Enum.CombatAudioAlertSpecSetting.SayIfTargeted);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetSpecSetting(Enum.CombatAudioAlertSpecSetting.SayIfTargeted, value);
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_SAY_IF_TARGETED",
					Settings.VarType.Number, CAA_SAY_IF_TARGETED_LABEL, Constants.CAAConstants.CAASayIfTargetedDefault, GetValue, SetValue);

				local function GetOptions()
					local container = Settings.CreateControlTextContainer();
					for index, info in CombatAudioAlertUtil.EnumerateSayIfTargetedInfo() do
						container:Add(index - 1, info.str);
					end
					return container:GetData();
				end
				local initializer = Settings.CreateDropdown(category, setting, GetOptions, CAA_SAY_IF_TARGETED_TOOLTIP);

				-- Add in Cooldown Viewer audio sounds as valid options.
				-- Offset the soundEnum value by the other options listed above to be valid for the cvar.
				local function IsSelected(soundEnum)
					return GetValue() == CooldownViewerSoundToCAAValue(soundEnum);
				end

				local function SetSelected(soundEnum)
					SetValue(CooldownViewerSoundToCAAValue(soundEnum));
				end

				initializer.customOptionHandler = function (rootDescription)
					local useHighlightStyle = true;
					CooldownViewerUtil.BuildSoundMenus(rootDescription, IsSelected, SetSelected, useHighlightStyle);
				end;

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
					for index, formatInfo in CombatAudioAlertUtil.EnumerateUnitFormatInfo("target", Enum.CombatAudioAlertType.Health) do
						container:Add(index - 1, CombatAudioAlertUtil.GetFormattedString(formatInfo, nil, examplePercent));
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
				local cvarTargetDeathBehavior = "CAATargetDeathBehavior";
				local setting = Settings.RegisterCVarSetting(category, cvarTargetDeathBehavior, Settings.VarType.Number, CAA_WHEN_TARGET_DIES_LABEL);
				local function GetOptions()
					local container = Settings.CreateControlTextContainer();
					for index, info in CombatAudioAlertUtil.EnumeratetWhenTargetDiesInfo() do
						container:Add(index - 1, info.str);
					end
					return container:GetData();
				end
				local initializer = Settings.CreateDropdown(category, setting, GetOptions, CAA_WHEN_TARGET_DIES_TOOLTIP);

				-- Add in Cooldown Viewer audio sounds as valid options.
				-- Offset the soundEnum value by the other options listed above to be valid for the cvar.
				local function IsSelected(soundEnum)
					return Settings.GetValue(cvarTargetDeathBehavior) == CooldownViewerSoundToCAAValue(soundEnum);
				end

				local function SetSelected(soundEnum)
					Settings.SetValue(cvarTargetDeathBehavior, CooldownViewerSoundToCAAValue(soundEnum));
				end

				initializer.customOptionHandler = function (rootDescription)
					local useHighlightStyle = true;
					CooldownViewerUtil.BuildSoundMenus(rootDescription, IsSelected, SetSelected, useHighlightStyle);
				end;

				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayTargetHealthInitializer, SayTargetHealthOptionsModifiable);
			end

			-- Say Target Health Voice
			do
				local setting = Settings.RegisterCVarSetting(category, "CAATargetHealthVoice", Settings.VarType.Number, CAA_VOICE_LABEL);
				local initializer = Settings.CreateDropdown(category, setting, GetVoiceOptions, CAA_SAY_TARGET_HEALTH_VOICE_TOOLTIP);
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

			-- Say Target Health Volume
			do
				local function GetValue()
					return C_CombatAudioAlert.GetCategoryVolume(Enum.CombatAudioAlertCategory.TargetHealth);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetCategoryVolume(Enum.CombatAudioAlertCategory.TargetHealth, value);
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_TARGET_HEALTH_VOLUME",
					Settings.VarType.Number, CAA_VOLUME_LABEL, Constants.TTSConstants.TTSVolumeDefault, GetValue, SetValue);

				local options = Settings.CreateSliderOptions(Constants.TTSConstants.TTSVolumeMin, Constants.TTSConstants.TTSVolumeMax, 1);
				options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);

				local initializer = Settings.CreateSlider(category, setting, options, CAA_SAY_TARGET_HEALTH_VOLUME_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayTargetHealthInitializer, SayTargetHealthOptionsModifiable);
			end

			local function GetUnderPercentOptions()
				local container = Settings.CreateControlTextContainer();
				for index, percentInfo in CombatAudioAlertUtil.EnumeratePartyHealthPercentInfo() do
					container:Add(index - 1, percentInfo.str);
				end
				return container:GetData();
			end

			-- Say Party Health
			local sayPartyHealthSetting = Settings.RegisterCVarSetting(category, "CAAPartyHealthPercent", Settings.VarType.Number, CAA_SAY_PARTY_HEALTH_LABEL);
			local sayPartyHealthInitializer = Settings.CreateDropdown(category, sayPartyHealthSetting, GetUnderPercentOptions, CAA_SAY_PARTY_HEALTH_TOOLTIP);
			InitCAAOption(sayPartyHealthInitializer);

			local function SayPartyHealthOptionsModifiable()
				return GetCVarNumberOrDefault("CAAPartyHealthPercent") > 0;
			end

			-- Say Party Health Voice
			do
				local setting = Settings.RegisterCVarSetting(category, "CAAPartyHealthVoice", Settings.VarType.Number, CAA_VOICE_LABEL);
				local initializer = Settings.CreateDropdown(category, setting, GetVoiceOptions, CAA_SAY_PARTY_HEALTH_VOICE_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayPartyHealthInitializer, SayPartyHealthOptionsModifiable);
			end

			-- Say Party Health Frequency
			do
				local setting = Settings.RegisterCVarSetting(category, "CAAPartyHealthFrequency", Settings.VarType.Number, CAA_SAY_PARTY_HEALTH_FREQUENCY_LABEL);

				local options = Settings.CreateSliderOptions(Constants.CAAConstants.CAAFrequencyMin, Constants.CAAConstants.CAAFrequencyMax, 1);
				options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);

				local initializer = Settings.CreateSlider(category, setting, options, CAA_SAY_PARTY_HEALTH_FREQUENCY_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayPartyHealthInitializer, SayPartyHealthOptionsModifiable);
			end

			-- Say Party Health Volume
			do
				local function GetValue()
					return C_CombatAudioAlert.GetCategoryVolume(Enum.CombatAudioAlertCategory.PartyHealth);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetCategoryVolume(Enum.CombatAudioAlertCategory.PartyHealth, value);
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_PARTY_HEALTH_VOLUME",
					Settings.VarType.Number, CAA_VOLUME_LABEL, Constants.TTSConstants.TTSVolumeDefault, GetValue, SetValue);

				local options = Settings.CreateSliderOptions(Constants.TTSConstants.TTSVolumeMin, Constants.TTSConstants.TTSVolumeMax, 1);
				options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);

				local initializer = Settings.CreateSlider(category, setting, options, CAA_SAY_PARTY_HEALTH_VOLUME_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayPartyHealthInitializer, SayPartyHealthOptionsModifiable);
			end

			-- Player Resource Options
			local resource1PowerName, resource2PowerName;

			local function GetResourceSettingFormattedString(formatString, primary)
				local _resource1PowerType, resource1PowerToken = UnitPowerType("player");
				resource1PowerName = resource1PowerToken and _G[resource1PowerToken];

				if GetUnitSecondaryPowerInfo then
					local _resource2PowerType, resource2PowerToken = GetUnitSecondaryPowerInfo("player");
					resource2PowerName = resource2PowerToken and _G[resource2PowerToken];
				end

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
				return C_CombatAudioAlert.GetSpecSetting(Enum.CombatAudioAlertSpecSetting.Resource1Percent);
			end

			local function SetResource1Value(value)
				C_CombatAudioAlert.SetSpecSetting(Enum.CombatAudioAlertSpecSetting.Resource1Percent, value);
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
					return C_CombatAudioAlert.GetSpecSetting(Enum.CombatAudioAlertSpecSetting.Resource1Format);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetSpecSetting(Enum.CombatAudioAlertSpecSetting.Resource1Format, value);
				end

				local function GetOptions()
					local container = Settings.CreateControlTextContainer();
					for index, formatInfo in CombatAudioAlertUtil.EnumeratePlayerResourceFormatInfo() do
						container:Add(index - 1, CombatAudioAlertUtil.GetFormattedString(formatInfo, resource1PowerName, examplePercent));
					end
					return container:GetData();
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_PLAYER_RESOURCE_1_FORMAT",
					Settings.VarType.Number, CAA_SAY_PLAYER_RESOURCE_FORMAT_LABEL, Constants.CAAConstants.CAAPlayerResourceFormatDefault, GetValue, SetValue);

				local initializer = Settings.CreateDropdown(category, setting, GetOptions, GetResourceSettingFormattedString(CAA_SAY_PLAYER_RESOURCE_FORMAT_TOOLTIP, isPrimaryYes));
				InitCAAResource1Option(initializer);
				initializer:SetParentInitializer(sayResource1Initializer, SayResource1OptionsModifiable);
			end

			-- Say Resource 1 Voice
			do
				local function GetValue()
					return C_CombatAudioAlert.GetSpecSetting(Enum.CombatAudioAlertSpecSetting.Resource1Voice);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetSpecSetting(Enum.CombatAudioAlertSpecSetting.Resource1Voice, value);
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_PLAYER_RESOURCE_1_VOICE",
					Settings.VarType.Number, CAA_VOICE_LABEL, Constants.CAAConstants.CAAVoiceDefault, GetValue, SetValue);

				local initializer = Settings.CreateDropdown(category, setting, GetVoiceOptions, GetResourceSettingFormattedString(CAA_SAY_PLAYER_RESOURCE_VOICE_TOOLTIP, isPrimaryYes));
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

			-- Say Resource 1 Volume
			do
				local function GetValue()
					return C_CombatAudioAlert.GetSpecSetting(Enum.CombatAudioAlertSpecSetting.Resource1Volume);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetSpecSetting(Enum.CombatAudioAlertSpecSetting.Resource1Volume, value);
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_PLAYER_RESOURCE_1_VOLUME",
					Settings.VarType.Number, CAA_VOLUME_LABEL, Constants.TTSConstants.TTSVolumeDefault, GetValue, SetValue);

				local options = Settings.CreateSliderOptions(Constants.TTSConstants.TTSVolumeMin, Constants.TTSConstants.TTSVolumeMax, 1);
				options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);

				local initializer = Settings.CreateSlider(category, setting, options, GetResourceSettingFormattedString(CAA_SAY_PLAYER_RESOURCE_VOLUME_TOOLTIP, isPrimaryYes));
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
				return C_CombatAudioAlert.GetSpecSetting(Enum.CombatAudioAlertSpecSetting.Resource2Percent);
			end

			local function SetResource2Value(value)
				C_CombatAudioAlert.SetSpecSetting(Enum.CombatAudioAlertSpecSetting.Resource2Percent, value);
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
					return C_CombatAudioAlert.GetSpecSetting(Enum.CombatAudioAlertSpecSetting.Resource2Format);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetSpecSetting(Enum.CombatAudioAlertSpecSetting.Resource2Format, value);
				end

				local function GetOptions()
					local container = Settings.CreateControlTextContainer();
					for index, formatInfo in CombatAudioAlertUtil.EnumeratePlayerResourceFormatInfo() do
						container:Add(index - 1, CombatAudioAlertUtil.GetFormattedString(formatInfo, resource2PowerName, examplePercent));
					end
					return container:GetData();
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_PLAYER_RESOURCE_2_FORMAT",
					Settings.VarType.Number, CAA_SAY_PLAYER_RESOURCE_FORMAT_LABEL, Constants.CAAConstants.CAAPlayerResourceFormatDefault, GetValue, SetValue);

				local initializer = Settings.CreateDropdown(category, setting, GetOptions, GetResourceSettingFormattedString(CAA_SAY_PLAYER_RESOURCE_FORMAT_TOOLTIP, isPrimaryNo));
				InitCAAResource2Option(initializer);
				initializer:SetParentInitializer(sayResource2Initializer, SayResource2OptionsModifiable);
			end

			-- Say Resource 2 Voice
			do
				local function GetValue()
					return C_CombatAudioAlert.GetSpecSetting(Enum.CombatAudioAlertSpecSetting.Resource2Voice);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetSpecSetting(Enum.CombatAudioAlertSpecSetting.Resource2Voice, value);
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_PLAYER_RESOURCE_2_VOICE",
					Settings.VarType.Number, CAA_VOICE_LABEL, Constants.CAAConstants.CAAVoiceDefault, GetValue, SetValue);

				local initializer = Settings.CreateDropdown(category, setting, GetVoiceOptions, GetResourceSettingFormattedString(CAA_SAY_PLAYER_RESOURCE_VOICE_TOOLTIP, isPrimaryNo));
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

			-- Say Resource 2 Volume
			do
				local function GetValue()
					return C_CombatAudioAlert.GetSpecSetting(Enum.CombatAudioAlertSpecSetting.Resource2Volume);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetSpecSetting(Enum.CombatAudioAlertSpecSetting.Resource2Volume, value);
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_PLAYER_RESOURCE_2_VOLUME",
					Settings.VarType.Number, CAA_VOLUME_LABEL, Constants.TTSConstants.TTSVolumeDefault, GetValue, SetValue);

				local options = Settings.CreateSliderOptions(Constants.TTSConstants.TTSVolumeMin, Constants.TTSConstants.TTSVolumeMax, 1);
				options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);

				local initializer = Settings.CreateSlider(category, setting, options, GetResourceSettingFormattedString(CAA_SAY_PLAYER_RESOURCE_VOLUME_TOOLTIP, isPrimaryNo));
				InitCAAResource2Option(initializer);
				initializer:SetParentInitializer(sayResource2Initializer, SayResource2OptionsModifiable);
			end

			local function GetCastModeOptions()
				local container = Settings.CreateControlTextContainer();
				for index, info in CombatAudioAlertUtil.EnumerateSayCastInfo() do
					container:Add(index - 1, info.str);
				end
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
					for index, formatInfo in CombatAudioAlertUtil.EnumerateUnitFormatInfo("player", Enum.CombatAudioAlertType.Cast) do
						container:Add(index - 1, CombatAudioAlertUtil.GetFormattedString(formatInfo, CAA_SAMPLE_SPELLNAME));
					end
					return container:GetData();
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_PLAYER_CAST_FORMAT",
					Settings.VarType.Number, CAA_SAY_PLAYER_CASTS_FORMAT_LABEL, Constants.CAAConstants.CAAPlayerCastFormatDefault, GetValue, SetValue);

				local initializer = Settings.CreateDropdown(category, setting, GetOptions, CAA_SAY_PLAYER_CASTS_FORMAT_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayPlayerCastInitializer, SayPlayerCastOptionsModifiable);
			end

			-- Say Player Cast Voice
			do
				local setting = Settings.RegisterCVarSetting(category, "CAAPlayerCastVoice", Settings.VarType.Number, CAA_VOICE_LABEL);
				local initializer = Settings.CreateDropdown(category, setting, GetVoiceOptions, CAA_SAY_PLAYER_CASTS_VOICE_TOOLTIP);
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

			-- Say Player Cast Volume
			do
				local function GetValue()
					return C_CombatAudioAlert.GetCategoryVolume(Enum.CombatAudioAlertCategory.PlayerCast);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetCategoryVolume(Enum.CombatAudioAlertCategory.PlayerCast, value);
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_PLAYER_CAST_VOLUME",
					Settings.VarType.Number, CAA_VOLUME_LABEL, Constants.TTSConstants.TTSVolumeDefault, GetValue, SetValue);

				local options = Settings.CreateSliderOptions(Constants.TTSConstants.TTSVolumeMin, Constants.TTSConstants.TTSVolumeMax, 1);
				options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);

				local initializer = Settings.CreateSlider(category, setting, options, CAA_SAY_PLAYER_CASTS_VOLUME_TOOLTIP);
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
					for index, formatInfo in CombatAudioAlertUtil.EnumerateUnitFormatInfo("target", Enum.CombatAudioAlertType.Cast) do
						container:Add(index - 1, CombatAudioAlertUtil.GetFormattedString(formatInfo, CAA_SAMPLE_SPELLNAME));
					end
					return container:GetData();
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_TARGET_CAST_FORMAT",
					Settings.VarType.Number, CAA_SAY_TARGET_CASTS_FORMAT_LABEL, Constants.CAAConstants.CAATargetCastFormatDefault, GetValue, SetValue);

				local initializer = Settings.CreateDropdown(category, setting, GetOptions, CAA_SAY_TARGET_CASTS_FORMAT_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayTargetCastInitializer, SayTargetCastOptionsModifiable);
			end

			-- Say Target Cast Voice
			do
				local setting = Settings.RegisterCVarSetting(category, "CAATargetCastVoice", Settings.VarType.Number, CAA_VOICE_LABEL);
				local initializer = Settings.CreateDropdown(category, setting, GetVoiceOptions, CAA_SAY_TARGET_CASTS_VOICE_TOOLTIP);
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

			-- Say Target Cast Volume
			do
				local function GetValue()
					return C_CombatAudioAlert.GetCategoryVolume(Enum.CombatAudioAlertCategory.TargetCast);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetCategoryVolume(Enum.CombatAudioAlertCategory.TargetCast, value);
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_TARGET_CAST_VOLUME",
					Settings.VarType.Number, CAA_VOLUME_LABEL, Constants.TTSConstants.TTSVolumeDefault, GetValue, SetValue);

				local options = Settings.CreateSliderOptions(Constants.TTSConstants.TTSVolumeMin, Constants.TTSConstants.TTSVolumeMax, 1);
				options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);

				local initializer = Settings.CreateSlider(category, setting, options, CAA_SAY_TARGET_CASTS_VOLUME_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayTargetCastInitializer, SayTargetCastOptionsModifiable);
			end

			-- Interrupt Alert
			do
				local cvarInterruptCast = "CAAInterruptCast";
				local setting = Settings.RegisterCVarSetting(category, cvarInterruptCast, Settings.VarType.Number, CAA_SAY_TARGET_CASTS_INTERRUPT_LABEL);
				local function GetOptions()
					local container = Settings.CreateControlTextContainer();
					for index, info in CombatAudioAlertUtil.EnumerateInterruptCastInfo() do
						container:Add(index - 1, info.str);
					end
					return container:GetData();
				end
				local initializer = Settings.CreateDropdown(category, setting, GetOptions, CAA_SAY_TARGET_CASTS_INTERRUPT_TOOLTIP);

				-- Add in Cooldown Viewer audio sounds as valid options.
				-- Offset the soundEnum value by the other options listed above to be valid for the cvar.
				local function IsSelected(soundEnum)
					return Settings.GetValue(cvarInterruptCast) == CooldownViewerSoundToCAAValue(soundEnum);
				end

				local function SetSelected(soundEnum)
					Settings.SetValue(cvarInterruptCast, CooldownViewerSoundToCAAValue(soundEnum));
				end

				initializer.customOptionHandler = function (rootDescription)
					local useHighlightStyle = true;
					CooldownViewerUtil.BuildSoundMenus(rootDescription, IsSelected, SetSelected, useHighlightStyle);
				end;

				InitCAAOption(initializer);
			end

			-- Successful Interrupt Alert
			do
				local cvarInterruptCastSuccess = "CAAInterruptCastSuccess";
				local setting = Settings.RegisterCVarSetting(category, cvarInterruptCastSuccess, Settings.VarType.Number, CAA_SAY_TARGET_CASTS_INTERRUPT_SUCCESS_LABEL);
				local function GetOptions()
					local container = Settings.CreateControlTextContainer();
					for index, info in CombatAudioAlertUtil.EnumerateInterruptCastSuccessInfo() do
						container:Add(index - 1, info.str);
					end
					return container:GetData();
				end
				local initializer = Settings.CreateDropdown(category, setting, GetOptions, CAA_SAY_TARGET_CASTS_INTERRUPT_SUCCESS_TOOLTIP);

				-- Add in Cooldown Viewer audio sounds as valid options.
				-- Offset the soundEnum value by the other options listed above to be valid for the cvar.
				local function IsSelected(soundEnum)
					return Settings.GetValue(cvarInterruptCastSuccess) == CooldownViewerSoundToCAAValue(soundEnum);
				end

				local function SetSelected(soundEnum)
					Settings.SetValue(cvarInterruptCastSuccess, CooldownViewerSoundToCAAValue(soundEnum));
				end

				initializer.customOptionHandler = function (rootDescription)
					local useHighlightStyle = true;
					CooldownViewerUtil.BuildSoundMenus(rootDescription, IsSelected, SetSelected, useHighlightStyle);
				end;

				InitCAAOption(initializer);
			end

			-- Say Your Debuffs
			local sayYourDebuffsSetting, sayYourDebuffsInitializer = Settings.SetupCVarCheckbox(category, "CAASayYourDebuffs", CAA_SAY_YOUR_DEBUFFS_LABEL, CAA_SAY_YOUR_DEBUFFS_TOOLTIP);
			InitCAAOption(sayYourDebuffsInitializer);

			local function SayYourDebuffsOptionsModifiable()
				return GetCVarBool("CAASayYourDebuffs");
			end

			-- Say Your Debuffs Format
			do
				local function GetOptions()
					local container = Settings.CreateControlTextContainer();
					for index, formatInfo in CombatAudioAlertUtil.EnumeratePlayerDebuffFormatInfo() do
						container:Add(index - 1, CombatAudioAlertUtil.GetFormattedString(formatInfo, CAA_SAMPLE_DEBUFFNAME));
					end
					return container:GetData();
				end

				local setting = Settings.RegisterCVarSetting(category, "CAASayYourDebuffsFormat", Settings.VarType.Number, CAA_SAY_YOUR_DEBUFFS_FORMAT_LABEL);
				local initializer = Settings.CreateDropdown(category, setting, GetOptions, CAA_SAY_YOUR_DEBUFFS_FORMAT_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayYourDebuffsInitializer, SayYourDebuffsOptionsModifiable);
			end

			-- Say Your Debuffs Voice
			do
				local setting = Settings.RegisterCVarSetting(category, "CAASayYourDebuffsVoice", Settings.VarType.Number, CAA_VOICE_LABEL);
				local initializer = Settings.CreateDropdown(category, setting, GetVoiceOptions, CAA_SAY_YOUR_DEBUFFS_VOICE_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayYourDebuffsInitializer, SayYourDebuffsOptionsModifiable);
			end

			-- Say Your Debuffs Minimum Duration
			do
				local setting = Settings.RegisterCVarSetting(category, "CAASayYourDebuffsMinDuration", Settings.VarType.Number, CAA_SAY_YOUR_DEBUFFS_MIN_DURATION_LABEL);

				local options = Settings.CreateSliderOptions(Constants.CAAConstants.CAASayYourDebuffsMinDurationMin, Constants.CAAConstants.CAASayYourDebuffsMinDurationMax, Constants.CAAConstants.CAASayYourDebuffsMinDurationStep);
				options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatSeconds);

				local initializer = Settings.CreateSlider(category, setting, options, CAA_SAY_YOUR_DEBUFFS_MIN_DURATION_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayYourDebuffsInitializer, SayYourDebuffsOptionsModifiable);
			end

			-- Say Your Debuffs Volume
			do
				local function GetValue()
					return C_CombatAudioAlert.GetCategoryVolume(Enum.CombatAudioAlertCategory.PlayerDebuffs);
				end

				local function SetValue(value)
					C_CombatAudioAlert.SetCategoryVolume(Enum.CombatAudioAlertCategory.PlayerDebuffs, value);
				end

				local setting = Settings.RegisterProxySetting(category, "PROXY_CAA_PLAYER_DEBUFFS_VOLUME",
					Settings.VarType.Number, CAA_VOLUME_LABEL, Constants.TTSConstants.TTSVolumeDefault, GetValue, SetValue);

				local options = Settings.CreateSliderOptions(Constants.TTSConstants.TTSVolumeMin, Constants.TTSConstants.TTSVolumeMax, 1);
				options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);

				local initializer = Settings.CreateSlider(category, setting, options, CAA_SAY_YOUR_DEBUFFS_VOLUME_TOOLTIP);
				InitCAAOption(initializer);
				initializer:SetParentInitializer(sayYourDebuffsInitializer, SayYourDebuffsOptionsModifiable);
			end

			-- Debuff Self Alert
			do
				local cvarDebuffSelf = "CAADebuffSelfAlert";
				local setting = Settings.RegisterCVarSetting(category, cvarDebuffSelf, Settings.VarType.Number, CAA_DEBUFF_SELF_ALERT_LABEL);
				local function GetOptions()
					local container = Settings.CreateControlTextContainer();
					container:Add(Enum.CombatAudioAlertDebuffSelfAlertValues.Off, LOC_OPTION_OFF);
					container:Add(Enum.CombatAudioAlertDebuffSelfAlertValues.DispelType, CAA_DEBUFF_SELF_ALERT_FORMAT_DEBUFF_TYPE:format(CAA_SAMPLE_DISPELTTYPE));
					return container:GetData();
				end
				local initializer = Settings.CreateDropdown(category, setting, GetOptions, CAA_DEBUFF_SELF_ALERT_TOOLTIP);

				-- Add in Cooldown Viewer audio sounds as valid options.
				-- Offset the soundEnum value by the other options listed above to be valid for the cvar.
				local function IsSelected(soundEnum)
					return Settings.GetValue(cvarDebuffSelf) == CooldownViewerSoundToCAAValue(soundEnum);
				end

				local function SetSelected(soundEnum)
					Settings.SetValue(cvarDebuffSelf, CooldownViewerSoundToCAAValue(soundEnum));
				end

				initializer.customOptionHandler = function (rootDescription)
					local useHighlightStyle = true;
					CooldownViewerUtil.BuildSoundMenus(rootDescription, IsSelected, SetSelected, useHighlightStyle);
				end;

				InitCAAOption(initializer);
			end
		end
	end

	local function InitGlueSettings(category)
		InitScreenNarrationSettings(category, layout);
	end

	local function InitSettings(category)
		if C_Glue.IsOnGlueScreen() then
			InitGlueSettings(category);
		else
			InitGameSettings(category);
		end
	end

	do
		local function InitRemoteVoices(category)
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
			-- If voice chat is disabled, there is no async dependency for remote voices to get loaded.
			InitSettings(category);
		elseif C_Glue.IsOnGlueScreen() then
			-- On the glue screens there is no async dependency for voice chat to be connected.
			InitSettings(category);
		elseif C_VoiceChat.IsVoiceChatConnected() then
			InitRemoteVoices(category);
		else
			EventUtil.RegisterOnceFrameEventAndCallback("VOICE_CHAT_CONNECTION_SUCCESS", function()
				InitRemoteVoices(category);
			end);
		end
	end

	Settings.RegisterCategory(category, SETTING_GROUP_ACCESSIBILITY);
end

SettingsRegistrar:AddRegistrant(Register);
