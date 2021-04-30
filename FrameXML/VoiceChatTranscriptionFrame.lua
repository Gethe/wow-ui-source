--[[
--	Voice Transcription Frame
--]]

function VoiceTranscriptionFrame_UpdateVisibility(self)
	local id = self:GetID();
	local showVoice = GetCVarBool("speechToText");
	local shown, _, docked = select(7, GetChatWindowInfo(id));
	local update = false;

	if showVoice then
		if not (shown or docked) then
			FCF_DockFrame(self, id);
			update = true;
		end
	else
		if self.minimized then
			FCF_MaximizeFrame(self);
			update = true;
			shown = true;
		end

		if docked then
			FCF_UnDockFrame(self);
			update = true;
			shown = true;
		end

		if shown then
			SetChatWindowShown(id, false);

			if LAST_ACTIVE_CHAT_EDIT_BOX == self.editBox then
				ChatEdit_SetLastActiveWindow(DEFAULT_CHAT_FRAME.editBox);
			end

			update = true;
		end
	end

	if update then
		FloatingChatFrame_Update(id);
		FCF_DockUpdate();
	end
end

function VoiceTranscriptionFrame_UpdateVoiceTab(self)
	-- Determine tab color based on channel type
	local channelType = C_VoiceChat.GetActiveChannelType();
	local chatType = "PARTY_VOICE";
	if (channelType == Enum.ChatChannelType.Communities) then
		local channel = C_VoiceChat.GetChannel(C_VoiceChat.GetActiveChannelID()) or {};
		local clubInfo = C_Club.GetClubInfo(channel.clubId)
		if (clubInfo and clubInfo.clubType == Enum.ClubType.Guild) then
			chatType = "GUILD_VOICE";
		else
			chatType = "COMMUNITIES_VOICE";
		end
	end

	local chatInfo = ChatTypeInfo[chatType];
	
	-- Set tab texture vertex colors
	local tab = self.Tab;
	tab.selectedColorTable = { r = chatInfo.r, g = chatInfo.g, b = chatInfo.b };
	tab.sizePadding = 12;
	FCFTab_UpdateColors(tab, not self.isDocked or self == FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK))

	-- Set tab text with colored icon
	local voiceIconMarkup = CreateAtlasMarkup("speechtotext-chaticon-neutral", 12, 12, 0, 0, chatInfo.r * 255, chatInfo.g * 255, chatInfo.b * 255);
	tab:SetText(voiceIconMarkup .. VOICE);

	-- Set chat type to the appropriate remote text to speech type if enabled
	if ( GetCVarBool("remoteTextToSpeech") ) then
		self.editBox:SetAttribute("chatType", chatType);
		self.editBox:SetAttribute("stickyType", chatType);
	end
end

function VoiceTranscriptionFrame_UpdateEditBox(self)
	local muted = C_VoiceChat.IsMuted();
	local prompt = self.editBox.prompt;
	if muted then
		prompt:SetText(VOICE_TRANSCRIPTION_MUTED);
		prompt:SetTextColor(RED_FONT_COLOR:GetRGB());
	else
		prompt:SetText(REMOTE_TEXT_TO_SPEECH);
		prompt:SetTextColor(WHITE_FONT_COLOR:GetRGB());
	end

	self.editBox.disableActivate = muted;
end

function VoiceTranscriptionFrame_CustomEventHandler(self, event, ...)
	local cvarName = ...
	if ( event == "VARIABLES_LOADED" ) then
		VoiceTranscriptionFrame_UpdateVisibility(self);
		VoiceTranscriptionFrame_UpdateVoiceTab(self);
		VoiceTranscriptionFrame_UpdateEditBox(self);
	elseif ( event == "CVAR_UPDATE" and cvarName == "ENABLE_SPEECH_TO_TEXT_TRANSCRIPTION" ) then
		VoiceTranscriptionFrame_UpdateVisibility(self);
		VoiceTranscriptionFrame_UpdateVoiceTab(self);
	elseif ( event == "VOICE_CHAT_MUTED_CHANGED" ) then
		VoiceTranscriptionFrame_UpdateEditBox(self);
	elseif ( event == "VOICE_CHAT_CHANNEL_ACTIVATED" ) then
		VoiceTranscriptionFrame_UpdateVoiceTab(self);
	elseif ( event == "UPDATE_CHAT_COLOR" ) then
		VoiceTranscriptionFrame_UpdateVoiceTab(self);
	elseif ( event == "VOICE_CHAT_CHANNEL_TRANSCRIBING_CHANGED" ) then
		local channelID, isNowTranscribing = ...
		if ( not self.isTranscribing and isNowTranscribing ) then
			local channel = C_VoiceChat.GetChannel(channelID);
			if channel then
				local atlas = CreateAtlasMarkup("voicechat-icon-stt");
				local announce = Voice_FormatChannelNotification(channel, SPEECH_TO_TEXT_JOINED);
				ChatFrame_DisplaySystemMessageInPrimary(atlas .. announce);
				ChatFrame_DisplaySystemMessage(self, SPEECH_TO_TEXT_STARTED);
			end
		end

		self.isTranscribing = isNowTranscribing;
	end

	-- Continue processing other handlers
	return false;
end

function VoiceTranscriptionFrame_Init(self)
	self.Tab = _G[self:GetName().."Tab"];
	self.customEventHandler = VoiceTranscriptionFrame_CustomEventHandler;
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("UPDATE_CHAT_COLOR");
	self:RegisterEvent("VOICE_CHAT_MUTED_CHANGED");
	self:RegisterEvent("VOICE_CHAT_CHANNEL_ACTIVATED");
	self:RegisterEvent("VOICE_CHAT_CHANNEL_TRANSCRIBING_CHANGED");
	ChatFrame_DisplaySystemMessage(self, SPEECH_TO_TEXT_HEADER);

	VoiceTranscriptionFrame_UpdateVisibility(self);
	VoiceTranscriptionFrame_UpdateVoiceTab(self);
	VoiceTranscriptionFrame_UpdateEditBox(self);
end

local VoiceTranscriptionFrame = ChatFrame3;
VoiceTranscriptionFrame_Init(VoiceTranscriptionFrame);
