VoiceChatTranscriptionButtonMixin = {};

function VoiceChatTranscriptionButtonMixin:OnLoad()
	self:RegisterEvent("VOICE_CHAT_CHANNEL_REMOVED");
	self:RegisterEvent("VOICE_CHAT_CHANNEL_ACTIVATED");
	self:RegisterEvent("VOICE_CHAT_CHANNEL_DEACTIVATED");
	self:RegisterEvent("VOICE_CHAT_CHANNEL_TRANSCRIBING_CHANGED");
	self:RegisterEvent("VOICE_CHAT_LOGOUT");
	self:RegisterEvent("VOICE_CHAT_ERROR");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("CVAR_UPDATE");
end

function VoiceChatTranscriptionButtonMixin:OnEvent(event, ...)
	if event == "VOICE_CHAT_CHANNEL_REMOVED" then
		self:OnVoiceChannelRemoved(...);
	elseif event == "VOICE_CHAT_CHANNEL_ACTIVATED" then
		self:OnVoiceChannelActivated(...);
	elseif event == "VOICE_CHAT_CHANNEL_DEACTIVATED" then
		self:OnVoiceChannelDeactivated(...);
	elseif event == "VOICE_CHAT_CHANNEL_TRANSCRIBING_CHANGED" then
		self:OnVoiceChannelTranscribingChanged(...);
	elseif event == "VOICE_CHAT_LOGOUT" then
		self:ClearPendingState();
	elseif event == "VOICE_CHAT_ERROR" then
		self:OnVoiceChatError(...);
	elseif event == "VARIABLES_LOADED" then
		self:Update();
	elseif event == "CVAR_UPDATE" then
		local arg1 = ...;
		if arg1 == "ENABLE_SPEECH_TO_TEXT_TRANSCRIPTION" then
			self:Update();
		end
	end
end

function VoiceChatTranscriptionButtonMixin:VoiceChannelIDMatches(voiceChannelID)
	return voiceChannelID == self:GetVoiceChannelID();
end

function VoiceChatTranscriptionButtonMixin:OnVoiceChannelRemoved(voiceChannelID)
	if self:VoiceChannelIDMatches(voiceChannelID) then
		self:ClearVoiceChannel();
	end
end

function VoiceChatTranscriptionButtonMixin:OnVoiceChannelActivated(voiceChannelID)
	if self:VoiceChannelIDMatches(voiceChannelID) then
		self:SetVoiceActive(true);
	end
end

function VoiceChatTranscriptionButtonMixin:OnVoiceChannelDeactivated(voiceChannelID)
	if self:VoiceChannelIDMatches(voiceChannelID) then
		self:SetVoiceActive(false);
	end
end

function VoiceChatTranscriptionButtonMixin:OnVoiceChannelTranscribingChanged(voiceChannelID, isTranscribing)
	if self:VoiceChannelIDMatches(voiceChannelID) then
		self:SetTranscriptionActive(isTranscribing);
		self:ClearPendingState();
	end
end

function VoiceChatTranscriptionButtonMixin:ClearPendingState()
	self:GetParent():SetPendingState(false);
end

function VoiceChatTranscriptionButtonMixin:OnVoiceChatError(platformCode, statusCode)
	if Voice_IsConnectionError(statusCode) then
		self:ClearPendingState();
		self:ClearVoiceChannel();
	end
end

function VoiceChatTranscriptionButtonMixin:OnClick()
	local voiceChannel = self:GetVoiceChannel();
	if voiceChannel then
		local isActive = self:IsTranscriptionActive();
		if isActive then
			C_VoiceChat.DeactivateChannelTranscription(voiceChannel.channelID);
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		else
			C_VoiceChat.ActivateChannelTranscription(voiceChannel.channelID);
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
			self:GetParent():SetPendingState(true);
		end
	end

	if self.onClickFn then
		self:onClickFn();
	end
end

function VoiceChatTranscriptionButtonMixin:SetOnClickCallback(fn)
	self.onClickFn = fn;
end

function VoiceChatTranscriptionButtonMixin:SetVoiceChannel(voiceChannel)
	self.linkedVoiceChannel = voiceChannel;

	if self.linkedVoiceChannel then
		self:SetVoiceActive(self.linkedVoiceChannel.isActive);
		self:SetTranscriptionActive(self.linkedVoiceChannel.isTranscribing);
	else
		self:SetVoiceActive(false);
		self:SetTranscriptionActive(false);
	end
end

function VoiceChatTranscriptionButtonMixin:ClearVoiceChannel()
	self:SetVoiceChannel(nil);
end

function VoiceChatTranscriptionButtonMixin:GetVoiceChannel()
	return self.linkedVoiceChannel;
end

function VoiceChatTranscriptionButtonMixin:GetVoiceChannelID()
	if self.linkedVoiceChannel then
		return self.linkedVoiceChannel.channelID;
	end

	return nil;
end

function VoiceChatTranscriptionButtonMixin:SetVoiceActive(voiceActive)
	self.voiceActive = voiceActive;
	self:Update();
end

function VoiceChatTranscriptionButtonMixin:SetTranscriptionActive(transcriptionActive)
	self.transcriptionActive = transcriptionActive;
	self:Update();
end

function VoiceChatTranscriptionButtonMixin:IsVoiceActive()
	return self.voiceActive;
end

function VoiceChatTranscriptionButtonMixin:IsTranscriptionActive()
	return self.transcriptionActive;
end

function VoiceChatTranscriptionButtonMixin:OnEnter()
	self:ShowTooltip();
end

function VoiceChatTranscriptionButtonMixin:OnLeave()
	GameTooltip:Hide();
end

function VoiceChatTranscriptionButtonMixin:OnShow()
	self:Update();
end

function VoiceChatTranscriptionButtonMixin:OnHide()
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_SPEECH_TO_TEXT, true);
	HelpTip:Hide(UIParent, SPEECH_TO_TEXT_TUTORIAL);
end

function VoiceChatTranscriptionButtonMixin:ShowTooltip()
	local isActive = self:IsTranscriptionActive();
	local message = isActive and VOICE_CHAT_TRANSCRIPTION_DISABLE or VOICE_CHAT_TRANSCRIPTION_ENABLE;

	local tooltip = GameTooltip;
	tooltip:SetOwner(self, "ANCHOR_RIGHT");

	GameTooltip_SetTitle(tooltip, message);
	tooltip:Show();
end

function VoiceChatTranscriptionButtonMixin:ShouldEnable()
	if not GetCVarBool("speechToText") then
		return false;
	end

	-- Can only enable transcription once voice channel is activated
	if not self:IsVoiceActive() then
		return false;
	end

	if not self:GetVoiceChannel() then
		return false;
	end

	return true;
end

function VoiceChatTranscriptionButtonMixin:Update()
	if self:ShouldEnable() then
		self:SetShown(true);

		local isActive = self:IsTranscriptionActive();
		local atlas = isActive and "voicechat-channellist-icon-STT-on" or "voicechat-channellist-icon-STT-off";
		self:SetNormalAtlas(atlas);
		self:SetHighlightAtlas(atlas);

		if GameTooltip:GetOwner() == self then
			self:ShowTooltip();
		end

		if(self:IsVisible() and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_SPEECH_TO_TEXT)) then
			local helpTipInfo = {
				text = SPEECH_TO_TEXT_TUTORIAL,
				buttonStyle = HelpTip.ButtonStyle.Close,
				cvarBitfield = "closedInfoFrames",
				bitfieldFlag = LE_FRAME_TUTORIAL_SPEECH_TO_TEXT,
				targetPoint = HelpTip.Point.TopEdgeCenter,
			};
			HelpTip:Show(UIParent, helpTipInfo, self);
		end
	else
		self:SetShown(false);

		if GameTooltip:GetOwner() == self then
			GameTooltip:Hide();
		end

		-- Deactivate if turned off through options
		if self:IsTranscriptionActive() then
			local voiceChannel = self:GetVoiceChannel();
			if voiceChannel then
				C_VoiceChat.DeactivateChannelTranscription(voiceChannel.channelID);
			end
		end
	end
end

VoiceChatTranscriptionMixin = {};

function VoiceChatTranscriptionMixin:SetVoiceChannel(...)
	self.Button:SetVoiceChannel(...);
end

function VoiceChatTranscriptionMixin:SetPendingState(pending)
	if pending then
		self.PendingDots:PlayAnimation();
	else
		self.PendingDots:StopAnimation();
	end
end

