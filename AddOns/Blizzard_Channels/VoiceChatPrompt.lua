local partyChannelTypeToActivatePrompt =
{
	[Enum.ChatChannelType.Private_Party] = VOICE_CHAT_PROMPT_CHANNEL_ACTIVATE_PARTY,
	[Enum.ChatChannelType.Public_Party] = VOICE_CHAT_PROMPT_CHANNEL_ACTIVATE_INSTANCE,
};

local raidChannelTypeToActivatePrompt =
{
	[Enum.ChatChannelType.Private_Party] = VOICE_CHAT_PROMPT_CHANNEL_ACTIVATE_RAID,
	[Enum.ChatChannelType.Public_Party] = VOICE_CHAT_PROMPT_CHANNEL_ACTIVATE_INSTANCE,
};

local partyChannelTypeToActivatedNotification =
{
	[Enum.ChatChannelType.Private_Party] = VOICE_CHAT_NOTIFICATION_CHANNEL_ACTIVATED_PARTY,
	[Enum.ChatChannelType.Public_Party] = VOICE_CHAT_NOTIFICATION_CHANNEL_ACTIVATED_INSTANCE,
};

local raidChannelTypeToActivatedNotification =
{
	[Enum.ChatChannelType.Private_Party] = VOICE_CHAT_NOTIFICATION_CHANNEL_ACTIVATED_RAID,
	[Enum.ChatChannelType.Public_Party] = VOICE_CHAT_NOTIFICATION_CHANNEL_ACTIVATED_INSTANCE,
};

function Voice_GetChannelActivatePrompt(channel)
	local isRaid = IsChatChannelRaid(channel.channelType);
	return isRaid and raidChannelTypeToActivatePrompt[channel.channelType] or partyChannelTypeToActivatePrompt[channel.channelType];
end

function Voice_GetChannelActivatedNotification(channel)
	if channel.channelType == Enum.ChatChannelType.Communities then
		return VOICE_CHAT_NOTIFICATION_CHANNEL_ACTIVATED_CUSTOM_NAME:format(ChatFrame_GetCommunityAndStreamName(channel.clubId, channel.streamId));
	else
		local isRaid = IsChatChannelRaid(channel.channelType);
		return isRaid and raidChannelTypeToActivatedNotification[channel.channelType] or partyChannelTypeToActivatedNotification[channel.channelType];
	end
end

function Voice_FormatChannelNotification(channel, notification)
	-- This is really not ideal...chat system is using rgb colors, which means that in order to use string:format for
	-- coloring text, a color object is ideal.  By caching the color, this runs the risk of getting out of date with
	-- the chat system color.  There are a few different ways to fix that...this also won't update as the user adjusts
	-- the channel colors in realtime...not sure it's actually worth fixing that though.
	local r, g, b = Voice_GetVoiceChannelNotificationColor(channel.channelID);
	return notification:format(CreateColor(r, g, b, 1):GenerateHexColor());
end

function Voice_GetCommunicationModeNotification(channel)
	local commsMode = C_VoiceChat.GetCommunicationMode();
	if commsMode == Enum.CommunicationMode.PushToTalk then
		local bindingKeys = C_VoiceChat.GetPushToTalkBinding();
		if bindingKeys then
			return VOICE_CHAT_NOTIFICATION_COMMS_MODE_PTT:format(GetBindingText(CreateKeyChordStringFromTable(bindingKeys)));
		else
			return VOICE_CHAT_NOTIFICATION_COMMS_MODE_PTT_UNBOUND;
		end
	elseif commsMode == Enum.CommunicationMode.OpenMic then
		return VOICE_CHAT_NOTIFICATION_COMMS_MODE_VOICE_ACTIVATED;
	end

	return "";
end

VoiceChatActivateChannelPromptMixin = {};

function VoiceChatActivateChannelPromptMixin:OnShow()
	self:RegisterEvent("VOICE_CHAT_CHANNEL_ACTIVATED");
end

function VoiceChatActivateChannelPromptMixin:OnHide()
	self:UnregisterEvent("VOICE_CHAT_CHANNEL_ACTIVATED");
end

function VoiceChatActivateChannelPromptMixin:OnEvent(event, ...)
	if event == "VOICE_CHAT_CHANNEL_ACTIVATED" then
		self:OnVoiceChannelActivated(...);
	end
end

function VoiceChatActivateChannelPromptMixin:OnVoiceChannelActivated(channelID)
	-- Hide prompt when channel is externally activated.
	if channelID == self.channel.channelID then
		self:Hide();
	end
end

function VoiceChatActivateChannelPromptMixin:Setup(channel)
	self.Icon:SetAtlas("voicechat-icon-headphone-pending");

	self.Text:SetTextColor(FRIENDS_GRAY_COLOR:GetRGBA());
	self.Text:SetText(Voice_FormatChannelNotification(channel, Voice_GetChannelActivatePrompt(channel)));

	self.channel = channel;
end

function VoiceChatActivateChannelPromptMixin:ShowPrompt(channel)
	self:Setup(channel);

	self:SetExternallyManagedOutroAnimation(true);
	AlertFrame_ShowNewAlert(self);
	VoiceChatChannelActivatedNotification:ListenForChannelActivation(self.channel);

    C_Timer.After(10, function()
    	self:SetExternallyManagedOutroAnimation(false);
    	AlertFrame_PlayOutroAnimation(self);
    end);
end

function VoiceChatActivateChannelPromptMixin:CheckActivateChannel(channel)
	if self:ShouldPromptForChannelActivate(channel) then
		self:ShowPrompt(channel);
	end
end

local function CountActiveChannelMembers(channel)
	local count = 0;
	for index, member in ipairs(channel.members) do
		if member.isActive then
			count = count + 1;
		end
	end

	return count;
end

function VoiceChatActivateChannelPromptMixin:ShouldPromptForChannelActivate(channel)
	return C_ChatInfo.IsPartyChannelType(channel.channelType) and CountActiveChannelMembers(channel) > 0;
end

function VoiceChatActivateChannelPromptMixin:ActivateChannel()
	C_VoiceChat.ActivateChannel(self.channel.channelID);
	self:UnregisterEvent("VOICE_CHAT_CHANNEL_ACTIVATED");
end

VoiceChatActivateChannelPromptButtonMixin = {};

function VoiceChatActivateChannelPromptButtonMixin:OnClick()
	local parent = self:GetParent();
	parent:ActivateChannel();
	parent:Hide();
end

VoiceChatChannelActivatedNotificationMixin = {};

function VoiceChatChannelActivatedNotificationMixin:OnEvent(event, ...)
	if event == "VOICE_CHAT_CHANNEL_ACTIVATED" then
		self:OnVoiceChannelActivated(...);
	end
end

function VoiceChatChannelActivatedNotificationMixin:OnVoiceChannelActivated(channelID)
	if channelID == self.channel.channelID then
		self:UnregisterEvent("VOICE_CHAT_CHANNEL_ACTIVATED");

		self:Setup();
		AlertFrame_ShowNewAlert(self);
	end
end

function VoiceChatChannelActivatedNotificationMixin:ListenForChannelActivation(channel)
	self:RegisterEvent("VOICE_CHAT_CHANNEL_ACTIVATED");
	self.channel = channel;
end

function VoiceChatChannelActivatedNotificationMixin:Setup()
	self.Icon:SetAtlas("voicechat-icon-headphone-on");

	self.Text:SetTextColor(FRIENDS_GRAY_COLOR:GetRGBA());
	self.Text:SetText(Voice_FormatChannelNotification(self.channel, Voice_GetChannelActivatedNotification(self.channel)));

	self.Text2:SetTextColor(FRIENDS_GRAY_COLOR:GetRGBA());
	self.Text2:SetText(Voice_GetCommunicationModeNotification());

	local heightDiff = self.Text2:GetHeight() - 12;
	self:SetHeight(52 + heightDiff);
end