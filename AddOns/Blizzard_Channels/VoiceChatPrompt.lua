local partyChannelTypeToActivatePrompt =
{
	[Enum.ChatChannelType.Private_Party] = VOICE_CHAT_PROMPT_CHANNEL_ACTIVATE_PARTY,
	[Enum.ChatChannelType.Public_Party] = VOICE_CHAT_PROMPT_CHANNEL_ACTIVATE_INSTANCE,
};

local raidChannelTypeToActivatePrompt =
{
	[Enum.ChatChannelType.Private_Party] = VOICE_CHAT_PROMPT_CHANNEL_ACTIVATE_RAID,
	[Enum.ChatChannelType.Public_Party] = VOICE_CHAT_PROMPT_CHANNEL_ACTIVATE_BATTLEGROUND,
};

local partyChannelTypeToActivatedNotification =
{
	[Enum.ChatChannelType.Private_Party] = VOICE_CHAT_NOTIFICATION_CHANNEL_ACTIVATED_PARTY,
	[Enum.ChatChannelType.Public_Party] = VOICE_CHAT_NOTIFICATION_CHANNEL_ACTIVATED_INSTANCE,
};

local raidChannelTypeToActivatedNotification =
{
	[Enum.ChatChannelType.Private_Party] = VOICE_CHAT_NOTIFICATION_CHANNEL_ACTIVATED_RAID,
	[Enum.ChatChannelType.Public_Party] = VOICE_CHAT_NOTIFICATION_CHANNEL_ACTIVATED_BATTLEGROUND,
};

function Voice_GetChannelActivatePrompt(channel)
	local isRaid = IsChatChannelRaid(channel.channelType);
	return isRaid and raidChannelTypeToActivatePrompt[channel.channelType] or partyChannelTypeToActivatePrompt[channel.channelType];
end

function Voice_GetChannelActivatedNotification(channel)
	local isRaid = IsChatChannelRaid(channel.channelType);
	return isRaid and raidChannelTypeToActivatedNotification[channel.channelType] or partyChannelTypeToActivatedNotification[channel.channelType];
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
		local bindingKey = GetBindingKey("TOGGLE_VOICE_PUSH_TO_TALK", 1);
		if bindingKey then
			return VOICE_CHAT_NOTIFICATION_COMMS_MODE_PTT:format(bindingKey);
		else
			return VOICE_CHAT_NOTIFICATION_COMMS_MODE_PTT_UNBOUND;
		end
	elseif commsMode == Enum.CommunicationMode.OpenMic then
		return VOICE_CHAT_NOTIFICATION_COMMS_MODE_VOICE_ACTIVATED;
	end

	return "";
end

VoiceChatActivateChannelPromptMixin = {};

function VoiceChatActivateChannelPromptMixin:Setup(channel)
	self.Icon:SetAtlas("voicechat-icon-headphone-pending");

	self.Text:SetTextColor(FRIENDS_GRAY_COLOR:GetRGBA());
	self.Text:SetText(Voice_FormatChannelNotification(channel, Voice_GetChannelActivatePrompt(channel)));

	self.channel = channel;
end

function VoiceChatActivateChannelPromptMixin:ShowPrompt(channel)
	self:Setup(channel);
	AlertFrame_ShowNewAlert(self);
end

function VoiceChatActivateChannelPromptMixin:ActivateChannel()
	VoiceChatChannelActivatedNotification:ListenForChannelActivation(self.channel);
	C_VoiceChat.ActivateChannel(self.channel.channelID);
end

VoiceChatActivateChannelPromptButtonMixin = {};

function VoiceChatActivateChannelPromptButtonMixin:OnClick()
	self:GetParent():ActivateChannel();
	self:GetParent():Hide();
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
end