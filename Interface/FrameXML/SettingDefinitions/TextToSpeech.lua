RTTSMixin = CreateFromMixins(SettingsDropDownControlMixin);

function RTTSMixin:OnLoad()
	SettingsDropDownControlMixin.OnLoad(self);

	self.Button:ClearAllPoints();
	self.Button:SetPoint("TOPLEFT", self.DropDown, "BOTTOMLEFT");
end

function RTTSMixin:Init(initializer)
	SettingsDropDownControlMixin.Init(self, initializer);
	
	local options = initializer.data.options();
	if #options == 0 then
		local function OnVoiceUpdate()
			local setting = self:GetSetting();
			self.DropDown:SetValue(setting:GetValue());
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
	local enabled = SettingsDropDownControlMixin.EvaluateState(self);
	self:SetButtonState(enabled);
end

function RTTSMixin:SetButtonState(enabled)
	self.Button:SetEnabled(enabled);
end

function RTTSMixin:OnSettingValueChanged(setting, value)
	SettingsDropDownControlMixin.OnSettingValueChanged(self, setting, value);
	self:SetButtonState(value);
end

function RTTSMixin:Release()
	SettingsDropDownControlMixin.Release(self);
	self.Button:SetScript("OnClick", nil);
end

local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(TTS_LABEL);

	local function InitSettings(category)
		-- Transcribe Voice Chat
		do
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
			local initializer = CreateSettingsCheckBoxWithButtonInitializer(ttsSetting, CONFIGURE_TEXT_TO_SPEECH, OnButtonClick, true, OPTION_TOOLTIP_ENABLE_TEXT_TO_SPEECH);
			layout:AddInitializer(initializer);
		end

		-- Speak for me in Voice Chat
		do
			local rtttSetting, rtttInitializer = Settings.SetupCVarCheckBox(category, "remoteTextToSpeech", ENABLE_REMOTE_TEXT_TO_SPEECH, OPTION_TOOLTIP_ENABLE_REMOTE_TEXT_TO_SPEECH);

			local function IsSpeakForMeAllowed()
				return C_VoiceChat.IsSpeakForMeAllowed();
			end
			rtttInitializer:AddShownPredicate(IsSpeakForMeAllowed);
			rtttInitializer:AddEvaluateStateFrameEvent("VOICE_CHAT_SPEAK_FOR_ME_FEATURE_STATUS_UPDATED");
			
			-- Voices
			do
				local setting = Settings.RegisterCVarSetting(category, "remoteTextToSpeechVoice", Settings.VarType.Number, VOICE);
				local function GetOptions()
					local container = Settings.CreateControlTextContainer();
					for index, voice in ipairs(C_VoiceChat.GetRemoteTtsVoices()) do
						container:Add(voice.voiceID, VOICE_GENERIC_FORMAT:format(voice.voiceID));
					end
					return container:GetData();
				end
				local data = Settings.CreateSettingInitializerData(setting, GetOptions);

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

		if C_VoiceChat.IsVoiceChatConnected() then
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
