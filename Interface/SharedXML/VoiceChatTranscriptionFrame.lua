--[[
--	Voice Transcription Frame
--]]

function VoiceTranscriptionFrame_UpdateVisibility(self)
	local id = self:GetID();
	local showVoice = (GetCVarBool("speechToText") and self.isTranscribing) or C_VoiceChat.IsSpeakForMeActive();
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

function VoiceTranscription_GetChatTypeAndInfo()
	local chatType = "PARTY";
	local channelType = C_VoiceChat.GetActiveChannelType();
	local chatInfo = nil;

	if (channelType == Enum.ChatChannelType.Private_Party) then
		if (IsInRaid()) then
			chatType = "RAID";
		else
			chatType = "PARTY";
		end
	elseif (channelType == Enum.ChatChannelType.Public_Party) then
		chatType = "INSTANCE_CHAT";
	elseif (channelType == Enum.ChatChannelType.Communities) then
		local channel = C_VoiceChat.GetChannel(C_VoiceChat.GetActiveChannelID()) or {};
		local streamInfo = C_Club.GetStreamInfo(channel.clubId, channel.streamId);
		if (streamInfo) then
			if streamInfo.streamType == Enum.ClubStreamType.Guild then
				chatType = "GUILD";
			elseif streamInfo.streamType == Enum.ClubStreamType.Officer then
				chatType = "OFFICER";
			else
				chatType = "COMMUNITIES_CHANNEL";
				-- Check if the channel is registered as a chat channel
				local clubInfo = C_Club.GetClubInfo(channel.clubId);
				if (clubInfo) then
					local chatChannel, channelIdx = Chat_GetCommunitiesChannel(channel.clubId, channel.streamId);
					local channelName, channelColor;
					if (chatChannel) then
						channelName = string.format("%d. %s", channelIdx, clubInfo.shortName or clubInfo.name);
						local channelInfo = ChatTypeInfo[chatChannel];
						channelColor = {
							r = channelInfo.r,
							g = channelInfo.g,
							b = channelInfo.b,
						};
					else
						channelName = clubInfo.shortName or clubInfo.name;
						channelColor = (clubInfo.clubType == Enum.ClubType.BattleNet) and BATTLENET_FONT_COLOR or DEFAULT_CHAT_CHANNEL_COLOR;
					end
					chatInfo =
						{
							channelName = channelName,
							r = channelColor.r,
							g = channelColor.g,
							b = channelColor.b,
						};
				end
			end
		end
	end

	if (not chatInfo) then
		chatInfo = ChatTypeInfo[chatType];
	end;

	return chatType, chatInfo;
end

function VoiceTranscriptionFrame_UpdateVoiceTab(self)
	-- Determine tab color based on channel type
	local _, chatInfo = VoiceTranscription_GetChatTypeAndInfo();
	
	-- Set tab texture vertex colors
	local tab = self.Tab;
	tab.selectedColorTable = { r = chatInfo.r, g = chatInfo.g, b = chatInfo.b };
	tab.sizePadding = 12;

	FCFTab_UpdateColors(tab, not self.isDocked or self == FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK));

	-- Set chat type to the appropriate remote text to speech type if enabled
	if ( C_VoiceChat.IsSpeakForMeActive() ) then
		self.editBox:SetAttribute("chatType", "VOICE_TEXT");
		self.editBox:SetAttribute("stickyType", "VOICE_TEXT");
	end
end

function VoiceTranscriptionFrame_UpdateEditBox(self)
	local speakForMeEnabled = C_VoiceChat.IsSpeakForMeActive();
	local muted = C_VoiceChat.IsMuted();
	local prompt = self.editBox.prompt;
	if muted then
		prompt:SetText(VOICE_TRANSCRIPTION_MUTED);
		prompt:SetTextColor(RED_FONT_COLOR:GetRGB());
	elseif speakForMeEnabled then
		prompt:SetText(REMOTE_TEXT_TO_SPEECH);
		prompt:SetTextColor(WHITE_FONT_COLOR:GetRGB());
	else
		prompt:SetText("");
	end

	self.editBox.disableActivate = muted or not speakForMeEnabled;

	if not speakForMeEnabled then
		self.editBox:Hide();
	end
end

function VoiceTranscriptionFrame_CustomEventHandler(self, event, ...)
	local cvarName = ...
	if ( event == "VARIABLES_LOADED" ) then
		VoiceTranscriptionFrame_UpdateVisibility(self);
		VoiceTranscriptionFrame_UpdateVoiceTab(self);
		VoiceTranscriptionFrame_UpdateEditBox(self);
	elseif ( ( event == "CVAR_UPDATE" and (cvarName == "ENABLE_TEXT_TO_SPEECH" or cvarName == "speechToText") ) or event == "VOICE_CHAT_SPEAK_FOR_ME_ACTIVE_STATUS_UPDATED" ) then
		VoiceTranscriptionFrame_UpdateVisibility(self);
		VoiceTranscriptionFrame_UpdateVoiceTab(self);
		VoiceTranscriptionFrame_UpdateEditBox(self);
	elseif ( event == "VOICE_CHAT_MUTED_CHANGED" ) then
		VoiceTranscriptionFrame_UpdateEditBox(self);
	elseif ( event == "VOICE_CHAT_CHANNEL_ACTIVATED" ) then
		VoiceTranscriptionFrame_UpdateVoiceTab(self);
	elseif ( event == "UPDATE_CHAT_COLOR" or event == "GROUP_ROSTER_UPDATE" ) then
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
		VoiceTranscriptionFrame_UpdateVisibility(self);
		VoiceTranscriptionFrame_UpdateVoiceTab(self);
	end

	-- Continue processing other handlers
	return false;
end

function VoiceTranscriptionFrame_Init(self)
	self.Tab = _G[self:GetName().."Tab"];
	self.customEventHandler = VoiceTranscriptionFrame_CustomEventHandler;
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("VOICE_CHAT_SPEAK_FOR_ME_ACTIVE_STATUS_UPDATED");
	self:RegisterEvent("UPDATE_CHAT_COLOR");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("VOICE_CHAT_MUTED_CHANGED");
	self:RegisterEvent("VOICE_CHAT_CHANNEL_ACTIVATED");
	self:RegisterEvent("VOICE_CHAT_CHANNEL_TRANSCRIBING_CHANGED");

	ChatFrame_DisplaySystemMessage(self, SPEECH_TO_TEXT_HEADER);
	VoiceTranscriptionFrame_UpdateVisibility(self);
	VoiceTranscriptionFrame_UpdateVoiceTab(self);
	VoiceTranscriptionFrame_UpdateEditBox(self);

	self.editBox:SetMaxLetters(100);
end

local VoiceTranscriptionFrame = ChatFrame3;
VoiceTranscriptionFrame_Init(VoiceTranscriptionFrame);

VOICE_WINDOW_ID = VoiceTranscriptionFrame:GetID();
