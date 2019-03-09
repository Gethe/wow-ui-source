Voice_PartyChannelTypeToChatInfoType =
{
	[Enum.ChatChannelType.Private_Party] = "PARTY",
	[Enum.ChatChannelType.Public_Party] = "INSTANCE_CHAT",
};

Voice_RaidChannelTypeToChatInfoType =
{
	[Enum.ChatChannelType.Private_Party] = "RAID",
	[Enum.ChatChannelType.Public_Party] = "INSTANCE_CHAT",
};

function Voice_GetChatInfoForChannelType(channel)
	local isRaid = IsChatChannelRaid(channel.channelType);
	local chatType = isRaid and Voice_RaidChannelTypeToChatInfoType[channel.channelType] or Voice_PartyChannelTypeToChatInfoType[channel.channelType];
	if chatType then
		return ChatTypeInfo[chatType];
	end
end

local function GetVoiceChannelNotificationColor(channel)
	if channel then
		local chatInfo = Voice_GetChatInfoForChannelType(channel);
		if chatInfo then
			return Chat_GetChannelColor(chatInfo);
		elseif channel.channelType == Enum.ChatChannelType.Communities then
			return Chat_GetCommunitiesChannelColor(channel.clubId, channel.streamId);
		end
	end

	return DEFAULT_CHAT_CHANNEL_COLOR:GetRGB();
end

function Voice_GetVoiceChannelNotificationColor(channelID)
	return GetVoiceChannelNotificationColor(C_VoiceChat.GetChannel(channelID));
end

function Voice_FormatTextForChannel(channel, text)
	local r, g, b = GetVoiceChannelNotificationColor(channel);
	return WrapTextInColorCode(text, CreateColor(r, g, b, 1):GenerateHexColor());
end

function Voice_FormatTextForChannelID(channelID, text)
	return Voice_FormatTextForChannel(C_VoiceChat.GetChannel(channelID), text);
end

local SUPPRESS_ERROR_MESSAGE = true;
local DISPLAY_BASIC_ERROR_ONLY = false;

local voiceChatStatusToGameError =
{
	[Enum.VoiceChatStatusCode.Success] = SUPPRESS_ERROR_MESSAGE,
	[Enum.VoiceChatStatusCode.OperationPending] = DISPLAY_BASIC_ERROR_ONLY,
	[Enum.VoiceChatStatusCode.ClientAlreadyLoggedIn] = DISPLAY_BASIC_ERROR_ONLY,
	[Enum.VoiceChatStatusCode.AlreadyInChannel] = DISPLAY_BASIC_ERROR_ONLY,
	[Enum.VoiceChatStatusCode.TooManyRequests] = LE_GAME_ERR_VOICE_CHAT_TOO_MANY_REQUESTS,
	[Enum.VoiceChatStatusCode.ChannelNameTooShort] = LE_GAME_ERR_VOICE_CHAT_CHANNEL_NAME_TOO_SHORT,
	[Enum.VoiceChatStatusCode.ChannelNameTooLong] = LE_GAME_ERR_VOICE_CHAT_CHANNEL_NAME_TOO_LONG,
	[Enum.VoiceChatStatusCode.ChannelAlreadyExists] = LE_GAME_ERR_VOICE_CHAT_CHANNEL_ALREADY_EXISTS,
	[Enum.VoiceChatStatusCode.TargetNotFound] = LE_GAME_ERR_VOICE_CHAT_TARGET_NOT_FOUND,
	[Enum.VoiceChatStatusCode.ProxyConnectionTimeOut] = LE_GAME_ERR_VOICE_CHAT_SERVICE_LOST,
	[Enum.VoiceChatStatusCode.ProxyConnectionUnexpectedDisconnect] = LE_GAME_ERR_VOICE_CHAT_SERVICE_LOST,
	[Enum.VoiceChatStatusCode.UnableToLaunchProxy] = LE_GAME_ERR_VOICE_CHAT_GENERIC_UNABLE_TO_CONNECT,
	[Enum.VoiceChatStatusCode.ProxyConnectionUnableToConnect] = LE_GAME_ERR_VOICE_CHAT_GENERIC_UNABLE_TO_CONNECT,
	[Enum.VoiceChatStatusCode.PlayerSilenced] = LE_GAME_ERR_VOICE_CHAT_PLAYER_SILENCED,
	[Enum.VoiceChatStatusCode.PlayerVoiceChatParentalDisabled] = LE_GAME_ERR_VOICE_CHAT_PARENTAL_DISABLE_ALL,
	[Enum.VoiceChatStatusCode.Disabled] = LE_GAME_ERR_VOICE_CHAT_DISABLED,
};

function Voice_GetGameErrorFromStatusCode(statusCode)
	local gameError = voiceChatStatusToGameError[statusCode];
	if gameError == SUPPRESS_ERROR_MESSAGE then
		return nil;
	end

	return gameError;
end

function Voice_GetGameErrorStringFromStatusCode(statusCode)
	local gameError = Voice_GetGameErrorFromStatusCode(statusCode);
	if gameError then
		local stringId = GetGameMessageInfo(gameError);
		if stringId then
			return _G[stringId] .. VOICE_CHAT_ERROR_CODE_FORMATTER:format(statusCode);
		end
	elseif gameError == DISPLAY_BASIC_ERROR_ONLY then
		return VOICE_CHAT_ERROR_CODE_FORMATTER:format(statusCode);
	end
end

function Voice_IsConnectionError(statusCode)
	return statusCode == Enum.VoiceChatStatusCode.ProxyConnectionTimeOut or statusCode == Enum.VoiceChatStatusCode.ProxyConnectionUnexpectedDisconnect;
end

-- This exists so that the chat frame isn't spammed with voice errors related to certain features being disabled.
-- However, panels like Voice Options should be able to display the current system error, so they use
-- a different filtering/blacklisting table.
local SUPPRESS_ALERT_MESSAGE = true;
local voiceChatStatusAlertBlacklist =
{
	[Enum.VoiceChatStatusCode.PlayerVoiceChatParentalDisabled] = SUPPRESS_ALERT_MESSAGE,
	[Enum.VoiceChatStatusCode.Disabled] = SUPPRESS_ALERT_MESSAGE,
};

function Voice_GetGameAlertStringFromStatusCode(statusCode)
	if voiceChatStatusAlertBlacklist[statusCode] == SUPPRESS_ALERT_MESSAGE then
		return nil;
	end

	return Voice_GetGameErrorStringFromStatusCode(statusCode);
end

local partyCategoryToChannelType =
{
	[LE_PARTY_CATEGORY_HOME] = Enum.ChatChannelType.Private_Party;
	[LE_PARTY_CATEGORY_INSTANCE] = Enum.ChatChannelType.Public_Party;
};

function GetChannelTypeFromPartyCategory(partyCategory)
	return partyCategoryToChannelType[partyCategory];
end

local channelTypeToPartyCategory = tInvert(partyCategoryToChannelType);

function GetPartyCategoryFromChannelType(channelType)
	return channelTypeToPartyCategory[channelType];
end

function IsPublicVoiceChannel(channel)
	return channel and channel.channelType == Enum.ChatChannelType.Public_Party;
end
