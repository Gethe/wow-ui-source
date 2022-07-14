local VoiceChat =
{
	Name = "VoiceChat",
	Type = "System",
	Namespace = "C_VoiceChat",

	Functions =
	{
		{
			Name = "ActivateChannel",
			Type = "Function",

			Arguments =
			{
				{ Name = "channelID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "BeginLocalCapture",
			Type = "Function",

			Arguments =
			{
				{ Name = "listenToLocalUser", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanPlayerUseVoiceChat",
			Type = "Function",

			Returns =
			{
				{ Name = "canUseVoiceChat", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CreateChannel",
			Type = "Function",

			Arguments =
			{
				{ Name = "channelDisplayName", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "status", Type = "VoiceChatStatusCode", Nilable = false },
			},
		},
		{
			Name = "DeactivateChannel",
			Type = "Function",

			Arguments =
			{
				{ Name = "channelID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "EndLocalCapture",
			Type = "Function",
		},
		{
			Name = "GetActiveChannelID",
			Type = "Function",

			Returns =
			{
				{ Name = "channelID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetActiveChannelType",
			Type = "Function",

			Returns =
			{
				{ Name = "channelType", Type = "ChatChannelType", Nilable = true },
			},
		},
		{
			Name = "GetAvailableInputDevices",
			Type = "Function",

			Returns =
			{
				{ Name = "inputDevices", Type = "table", InnerType = "VoiceAudioDevice", Nilable = true },
			},
		},
		{
			Name = "GetAvailableOutputDevices",
			Type = "Function",

			Returns =
			{
				{ Name = "outputDevices", Type = "table", InnerType = "VoiceAudioDevice", Nilable = true },
			},
		},
		{
			Name = "GetChannel",
			Type = "Function",

			Arguments =
			{
				{ Name = "channelID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "channel", Type = "VoiceChatChannel", Nilable = true },
			},
		},
		{
			Name = "GetChannelForChannelType",
			Type = "Function",

			Arguments =
			{
				{ Name = "channelType", Type = "ChatChannelType", Nilable = false },
			},

			Returns =
			{
				{ Name = "channel", Type = "VoiceChatChannel", Nilable = true },
			},
		},
		{
			Name = "GetChannelForCommunityStream",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "channel", Type = "VoiceChatChannel", Nilable = true },
			},
		},
		{
			Name = "GetCommunicationMode",
			Type = "Function",

			Returns =
			{
				{ Name = "communicationMode", Type = "CommunicationMode", Nilable = true },
			},
		},
		{
			Name = "GetCurrentVoiceChatConnectionStatusCode",
			Type = "Function",

			Returns =
			{
				{ Name = "statusCode", Type = "VoiceChatStatusCode", Nilable = false },
			},
		},
		{
			Name = "GetInputVolume",
			Type = "Function",

			Returns =
			{
				{ Name = "volume", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetJoinClubVoiceChannelError",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "errorReason", Type = "VoiceChannelErrorReason", Nilable = true },
			},
		},
		{
			Name = "GetLocalPlayerActiveChannelMemberInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "memberInfo", Type = "VoiceChatMember", Nilable = true },
			},
		},
		{
			Name = "GetLocalPlayerMemberID",
			Type = "Function",

			Arguments =
			{
				{ Name = "channelID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "memberID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetMasterVolumeScale",
			Type = "Function",

			Returns =
			{
				{ Name = "scale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMemberGUID",
			Type = "Function",

			Arguments =
			{
				{ Name = "memberID", Type = "number", Nilable = false },
				{ Name = "channelID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "memberGUID", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetMemberID",
			Type = "Function",

			Arguments =
			{
				{ Name = "channelID", Type = "number", Nilable = false },
				{ Name = "memberGUID", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "memberID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetMemberInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "memberID", Type = "number", Nilable = false },
				{ Name = "channelID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "memberInfo", Type = "VoiceChatMember", Nilable = true },
			},
		},
		{
			Name = "GetMemberName",
			Type = "Function",

			Arguments =
			{
				{ Name = "memberID", Type = "number", Nilable = false },
				{ Name = "channelID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "memberName", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetMemberVolume",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerLocation", Type = "table", Mixin = "PlayerLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "volume", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetOutputVolume",
			Type = "Function",

			Returns =
			{
				{ Name = "volume", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetPTTButtonPressedState",
			Type = "Function",

			Returns =
			{
				{ Name = "isPressed", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "GetProcesses",
			Type = "Function",

			Returns =
			{
				{ Name = "processes", Type = "table", InnerType = "VoiceChatProcess", Nilable = false },
			},
		},
		{
			Name = "GetPushToTalkBinding",
			Type = "Function",

			Returns =
			{
				{ Name = "keys", Type = "table", InnerType = "string", Nilable = true },
			},
		},
		{
			Name = "GetVADSensitivity",
			Type = "Function",

			Returns =
			{
				{ Name = "sensitivity", Type = "number", Nilable = true },
			},
		},
		{
			Name = "IsChannelJoinPending",
			Type = "Function",

			Arguments =
			{
				{ Name = "channelType", Type = "ChatChannelType", Nilable = false },
				{ Name = "clubId", Type = "string", Nilable = true },
				{ Name = "streamId", Type = "string", Nilable = true },
			},

			Returns =
			{
				{ Name = "isPending", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsDeafened",
			Type = "Function",

			Returns =
			{
				{ Name = "isDeafened", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "IsEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsLoggedIn",
			Type = "Function",

			Returns =
			{
				{ Name = "isLoggedIn", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMemberLocalPlayer",
			Type = "Function",

			Arguments =
			{
				{ Name = "memberID", Type = "number", Nilable = false },
				{ Name = "channelID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isLocalPlayer", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMemberMuted",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerLocation", Type = "table", Mixin = "PlayerLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "mutedForMe", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "IsMemberMutedForAll",
			Type = "Function",

			Arguments =
			{
				{ Name = "memberID", Type = "number", Nilable = false },
				{ Name = "channelID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "mutedForAll", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "IsMemberSilenced",
			Type = "Function",

			Arguments =
			{
				{ Name = "memberID", Type = "number", Nilable = false },
				{ Name = "channelID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "silenced", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "IsMuted",
			Type = "Function",

			Returns =
			{
				{ Name = "isMuted", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "IsParentalDisabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isParentalDisabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsParentalMuted",
			Type = "Function",

			Returns =
			{
				{ Name = "isParentalMuted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPlayerUsingVoice",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerLocation", Type = "table", Mixin = "PlayerLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isUsingVoice", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSilenced",
			Type = "Function",

			Returns =
			{
				{ Name = "isSilenced", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "LeaveChannel",
			Type = "Function",

			Arguments =
			{
				{ Name = "channelID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "Login",
			Type = "Function",

			Returns =
			{
				{ Name = "status", Type = "VoiceChatStatusCode", Nilable = false },
			},
		},
		{
			Name = "Logout",
			Type = "Function",

			Returns =
			{
				{ Name = "status", Type = "VoiceChatStatusCode", Nilable = false },
			},
		},
		{
			Name = "MarkChannelsDiscovered",
			Type = "Function",
			Documentation = { "Once the UI has enumerated all channels, use this to reset the channel discovery state, it will be updated again if appropriate" },
		},
		{
			Name = "RequestJoinAndActivateCommunityStreamChannel",
			Type = "Function",

			Arguments =
			{
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
			},
		},
		{
			Name = "RequestJoinChannelByChannelType",
			Type = "Function",

			Arguments =
			{
				{ Name = "channelType", Type = "ChatChannelType", Nilable = false },
				{ Name = "autoActivate", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "SetCommunicationMode",
			Type = "Function",

			Arguments =
			{
				{ Name = "communicationMode", Type = "CommunicationMode", Nilable = false },
			},
		},
		{
			Name = "SetDeafened",
			Type = "Function",

			Arguments =
			{
				{ Name = "isDeafened", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetInputDevice",
			Type = "Function",

			Arguments =
			{
				{ Name = "deviceID", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetInputVolume",
			Type = "Function",

			Arguments =
			{
				{ Name = "volume", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetMasterVolumeScale",
			Type = "Function",

			Arguments =
			{
				{ Name = "scale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetMemberMuted",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerLocation", Type = "table", Mixin = "PlayerLocationMixin", Nilable = false },
				{ Name = "muted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetMemberVolume",
			Type = "Function",
			Documentation = { "Adjusts member volume across all channels" },

			Arguments =
			{
				{ Name = "playerLocation", Type = "table", Mixin = "PlayerLocationMixin", Nilable = false },
				{ Name = "volume", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetMuted",
			Type = "Function",

			Arguments =
			{
				{ Name = "isMuted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetOutputDevice",
			Type = "Function",

			Arguments =
			{
				{ Name = "deviceID", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetOutputVolume",
			Type = "Function",

			Arguments =
			{
				{ Name = "volume", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetPortraitTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "textureObject", Type = "table", Nilable = false },
				{ Name = "memberID", Type = "number", Nilable = false },
				{ Name = "channelID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetPushToTalkBinding",
			Type = "Function",

			Arguments =
			{
				{ Name = "keys", Type = "table", InnerType = "string", Nilable = false },
			},
		},
		{
			Name = "SetVADSensitivity",
			Type = "Function",

			Arguments =
			{
				{ Name = "sensitivity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ShouldDiscoverChannels",
			Type = "Function",
			Documentation = { "Use this while loading to determine if the UI should attempt to rediscover the previously joined/active voice channels" },

			Returns =
			{
				{ Name = "shouldDiscoverChannels", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ToggleDeafened",
			Type = "Function",
		},
		{
			Name = "ToggleMemberMuted",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerLocation", Type = "table", Mixin = "PlayerLocationMixin", Nilable = false },
			},
		},
		{
			Name = "ToggleMuted",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "VoiceChatActiveInputDeviceUpdated",
			Type = "Event",
			LiteralName = "VOICE_CHAT_ACTIVE_INPUT_DEVICE_UPDATED",
		},
		{
			Name = "VoiceChatActiveOutputDeviceUpdated",
			Type = "Event",
			LiteralName = "VOICE_CHAT_ACTIVE_OUTPUT_DEVICE_UPDATED",
		},
		{
			Name = "VoiceChatAudioCaptureEnergy",
			Type = "Event",
			LiteralName = "VOICE_CHAT_AUDIO_CAPTURE_ENERGY",
			Payload =
			{
				{ Name = "isSpeaking", Type = "bool", Nilable = false },
				{ Name = "energy", Type = "number", Nilable = false },
			},
		},
		{
			Name = "VoiceChatAudioCaptureStarted",
			Type = "Event",
			LiteralName = "VOICE_CHAT_AUDIO_CAPTURE_STARTED",
		},
		{
			Name = "VoiceChatAudioCaptureStopped",
			Type = "Event",
			LiteralName = "VOICE_CHAT_AUDIO_CAPTURE_STOPPED",
		},
		{
			Name = "VoiceChatChannelActivated",
			Type = "Event",
			LiteralName = "VOICE_CHAT_CHANNEL_ACTIVATED",
			Payload =
			{
				{ Name = "channelID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "VoiceChatChannelDeactivated",
			Type = "Event",
			LiteralName = "VOICE_CHAT_CHANNEL_DEACTIVATED",
			Payload =
			{
				{ Name = "channelID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "VoiceChatChannelDisplayNameChanged",
			Type = "Event",
			LiteralName = "VOICE_CHAT_CHANNEL_DISPLAY_NAME_CHANGED",
			Payload =
			{
				{ Name = "channelID", Type = "number", Nilable = false },
				{ Name = "channelDisplayName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "VoiceChatChannelJoined",
			Type = "Event",
			LiteralName = "VOICE_CHAT_CHANNEL_JOINED",
			Payload =
			{
				{ Name = "status", Type = "VoiceChatStatusCode", Nilable = false },
				{ Name = "channelID", Type = "number", Nilable = false },
				{ Name = "channelType", Type = "ChatChannelType", Nilable = false },
				{ Name = "clubId", Type = "string", Nilable = true },
				{ Name = "streamId", Type = "string", Nilable = true },
			},
		},
		{
			Name = "VoiceChatChannelMemberActiveStateChanged",
			Type = "Event",
			LiteralName = "VOICE_CHAT_CHANNEL_MEMBER_ACTIVE_STATE_CHANGED",
			Payload =
			{
				{ Name = "memberID", Type = "number", Nilable = false },
				{ Name = "channelID", Type = "number", Nilable = false },
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "VoiceChatChannelMemberAdded",
			Type = "Event",
			LiteralName = "VOICE_CHAT_CHANNEL_MEMBER_ADDED",
			Payload =
			{
				{ Name = "memberID", Type = "number", Nilable = false },
				{ Name = "channelID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "VoiceChatChannelMemberEnergyChanged",
			Type = "Event",
			LiteralName = "VOICE_CHAT_CHANNEL_MEMBER_ENERGY_CHANGED",
			Payload =
			{
				{ Name = "memberID", Type = "number", Nilable = false },
				{ Name = "channelID", Type = "number", Nilable = false },
				{ Name = "speakingEnergy", Type = "number", Nilable = false },
			},
		},
		{
			Name = "VoiceChatChannelMemberGuidUpdated",
			Type = "Event",
			LiteralName = "VOICE_CHAT_CHANNEL_MEMBER_GUID_UPDATED",
			Payload =
			{
				{ Name = "memberID", Type = "number", Nilable = false },
				{ Name = "channelID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "VoiceChatChannelMemberMuteForAllChanged",
			Type = "Event",
			LiteralName = "VOICE_CHAT_CHANNEL_MEMBER_MUTE_FOR_ALL_CHANGED",
			Payload =
			{
				{ Name = "memberID", Type = "number", Nilable = false },
				{ Name = "channelID", Type = "number", Nilable = false },
				{ Name = "isMutedForAll", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "VoiceChatChannelMemberMuteForMeChanged",
			Type = "Event",
			LiteralName = "VOICE_CHAT_CHANNEL_MEMBER_MUTE_FOR_ME_CHANGED",
			Payload =
			{
				{ Name = "memberID", Type = "number", Nilable = false },
				{ Name = "channelID", Type = "number", Nilable = false },
				{ Name = "isMutedForMe", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "VoiceChatChannelMemberRemoved",
			Type = "Event",
			LiteralName = "VOICE_CHAT_CHANNEL_MEMBER_REMOVED",
			Payload =
			{
				{ Name = "memberID", Type = "number", Nilable = false },
				{ Name = "channelID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "VoiceChatChannelMemberSilencedChanged",
			Type = "Event",
			LiteralName = "VOICE_CHAT_CHANNEL_MEMBER_SILENCED_CHANGED",
			Payload =
			{
				{ Name = "memberID", Type = "number", Nilable = false },
				{ Name = "channelID", Type = "number", Nilable = false },
				{ Name = "isSilenced", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "VoiceChatChannelMemberSpeakingStateChanged",
			Type = "Event",
			LiteralName = "VOICE_CHAT_CHANNEL_MEMBER_SPEAKING_STATE_CHANGED",
			Payload =
			{
				{ Name = "memberID", Type = "number", Nilable = false },
				{ Name = "channelID", Type = "number", Nilable = false },
				{ Name = "isSpeaking", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "VoiceChatChannelMemberVolumeChanged",
			Type = "Event",
			LiteralName = "VOICE_CHAT_CHANNEL_MEMBER_VOLUME_CHANGED",
			Payload =
			{
				{ Name = "memberID", Type = "number", Nilable = false },
				{ Name = "channelID", Type = "number", Nilable = false },
				{ Name = "volume", Type = "number", Nilable = false },
			},
		},
		{
			Name = "VoiceChatChannelMuteStateChanged",
			Type = "Event",
			LiteralName = "VOICE_CHAT_CHANNEL_MUTE_STATE_CHANGED",
			Payload =
			{
				{ Name = "channelID", Type = "number", Nilable = false },
				{ Name = "isMuted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "VoiceChatChannelPttChanged",
			Type = "Event",
			LiteralName = "VOICE_CHAT_CHANNEL_PTT_CHANGED",
			Payload =
			{
				{ Name = "channelID", Type = "number", Nilable = false },
				{ Name = "pushToTalkSetting", Type = "string", Nilable = false },
			},
		},
		{
			Name = "VoiceChatChannelRemoved",
			Type = "Event",
			LiteralName = "VOICE_CHAT_CHANNEL_REMOVED",
			Payload =
			{
				{ Name = "channelID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "VoiceChatChannelTransmitChanged",
			Type = "Event",
			LiteralName = "VOICE_CHAT_CHANNEL_TRANSMIT_CHANGED",
			Payload =
			{
				{ Name = "channelID", Type = "number", Nilable = false },
				{ Name = "isTransmitting", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "VoiceChatChannelVolumeChanged",
			Type = "Event",
			LiteralName = "VOICE_CHAT_CHANNEL_VOLUME_CHANGED",
			Payload =
			{
				{ Name = "channelID", Type = "number", Nilable = false },
				{ Name = "volume", Type = "number", Nilable = false },
			},
		},
		{
			Name = "VoiceChatCommunicationModeChanged",
			Type = "Event",
			LiteralName = "VOICE_CHAT_COMMUNICATION_MODE_CHANGED",
			Payload =
			{
				{ Name = "communicationMode", Type = "CommunicationMode", Nilable = false },
			},
		},
		{
			Name = "VoiceChatConnectionSuccess",
			Type = "Event",
			LiteralName = "VOICE_CHAT_CONNECTION_SUCCESS",
		},
		{
			Name = "VoiceChatDeafenedChanged",
			Type = "Event",
			LiteralName = "VOICE_CHAT_DEAFENED_CHANGED",
			Payload =
			{
				{ Name = "isDeafened", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "VoiceChatError",
			Type = "Event",
			LiteralName = "VOICE_CHAT_ERROR",
			Payload =
			{
				{ Name = "platformCode", Type = "number", Nilable = false },
				{ Name = "statusCode", Type = "VoiceChatStatusCode", Nilable = false },
			},
		},
		{
			Name = "VoiceChatInputDevicesUpdated",
			Type = "Event",
			LiteralName = "VOICE_CHAT_INPUT_DEVICES_UPDATED",
		},
		{
			Name = "VoiceChatLogin",
			Type = "Event",
			LiteralName = "VOICE_CHAT_LOGIN",
			Payload =
			{
				{ Name = "status", Type = "VoiceChatStatusCode", Nilable = false },
			},
		},
		{
			Name = "VoiceChatLogout",
			Type = "Event",
			LiteralName = "VOICE_CHAT_LOGOUT",
			Payload =
			{
				{ Name = "status", Type = "VoiceChatStatusCode", Nilable = false },
			},
		},
		{
			Name = "VoiceChatMutedChanged",
			Type = "Event",
			LiteralName = "VOICE_CHAT_MUTED_CHANGED",
			Payload =
			{
				{ Name = "isMuted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "VoiceChatOutputDevicesUpdated",
			Type = "Event",
			LiteralName = "VOICE_CHAT_OUTPUT_DEVICES_UPDATED",
		},
		{
			Name = "VoiceChatPendingChannelJoinState",
			Type = "Event",
			LiteralName = "VOICE_CHAT_PENDING_CHANNEL_JOIN_STATE",
			Payload =
			{
				{ Name = "channelType", Type = "ChatChannelType", Nilable = false },
				{ Name = "clubId", Type = "string", Nilable = true },
				{ Name = "streamId", Type = "string", Nilable = true },
				{ Name = "pendingJoin", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "VoiceChatPttButtonPressedStateChanged",
			Type = "Event",
			LiteralName = "VOICE_CHAT_PTT_BUTTON_PRESSED_STATE_CHANGED",
			Payload =
			{
				{ Name = "isPressed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "VoiceChatSilencedChanged",
			Type = "Event",
			LiteralName = "VOICE_CHAT_SILENCED_CHANGED",
			Payload =
			{
				{ Name = "isSilenced", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "CommunicationMode",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "PushToTalk", Type = "CommunicationMode", EnumValue = 0 },
				{ Name = "OpenMic", Type = "CommunicationMode", EnumValue = 1 },
			},
		},
		{
			Name = "VoiceChannelErrorReason",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Unknown", Type = "VoiceChannelErrorReason", EnumValue = 0 },
				{ Name = "IsBattleNetChannel", Type = "VoiceChannelErrorReason", EnumValue = 1 },
			},
		},
		{
			Name = "VoiceChatStatusCode",
			Type = "Enumeration",
			NumValues = 25,
			MinValue = 0,
			MaxValue = 24,
			Fields =
			{
				{ Name = "Success", Type = "VoiceChatStatusCode", EnumValue = 0 },
				{ Name = "OperationPending", Type = "VoiceChatStatusCode", EnumValue = 1 },
				{ Name = "TooManyRequests", Type = "VoiceChatStatusCode", EnumValue = 2 },
				{ Name = "LoginProhibited", Type = "VoiceChatStatusCode", EnumValue = 3 },
				{ Name = "ClientNotInitialized", Type = "VoiceChatStatusCode", EnumValue = 4 },
				{ Name = "ClientNotLoggedIn", Type = "VoiceChatStatusCode", EnumValue = 5 },
				{ Name = "ClientAlreadyLoggedIn", Type = "VoiceChatStatusCode", EnumValue = 6 },
				{ Name = "ChannelNameTooShort", Type = "VoiceChatStatusCode", EnumValue = 7 },
				{ Name = "ChannelNameTooLong", Type = "VoiceChatStatusCode", EnumValue = 8 },
				{ Name = "ChannelAlreadyExists", Type = "VoiceChatStatusCode", EnumValue = 9 },
				{ Name = "AlreadyInChannel", Type = "VoiceChatStatusCode", EnumValue = 10 },
				{ Name = "TargetNotFound", Type = "VoiceChatStatusCode", EnumValue = 11 },
				{ Name = "Failure", Type = "VoiceChatStatusCode", EnumValue = 12 },
				{ Name = "ServiceLost", Type = "VoiceChatStatusCode", EnumValue = 13 },
				{ Name = "UnableToLaunchProxy", Type = "VoiceChatStatusCode", EnumValue = 14 },
				{ Name = "ProxyConnectionTimeOut", Type = "VoiceChatStatusCode", EnumValue = 15 },
				{ Name = "ProxyConnectionUnableToConnect", Type = "VoiceChatStatusCode", EnumValue = 16 },
				{ Name = "ProxyConnectionUnexpectedDisconnect", Type = "VoiceChatStatusCode", EnumValue = 17 },
				{ Name = "Disabled", Type = "VoiceChatStatusCode", EnumValue = 18 },
				{ Name = "UnsupportedChatChannelType", Type = "VoiceChatStatusCode", EnumValue = 19 },
				{ Name = "InvalidCommunityStream", Type = "VoiceChatStatusCode", EnumValue = 20 },
				{ Name = "PlayerSilenced", Type = "VoiceChatStatusCode", EnumValue = 21 },
				{ Name = "PlayerVoiceChatParentalDisabled", Type = "VoiceChatStatusCode", EnumValue = 22 },
				{ Name = "InvalidInputDevice", Type = "VoiceChatStatusCode", EnumValue = 23 },
				{ Name = "InvalidOutputDevice", Type = "VoiceChatStatusCode", EnumValue = 24 },
			},
		},
		{
			Name = "VoiceAudioDevice",
			Type = "Structure",
			Fields =
			{
				{ Name = "deviceID", Type = "string", Nilable = false },
				{ Name = "displayName", Type = "string", Nilable = false },
				{ Name = "power", Type = "number", Nilable = false },
				{ Name = "isActive", Type = "bool", Nilable = false },
				{ Name = "isSystemDefault", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "VoiceChatChannel",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "channelID", Type = "number", Nilable = false },
				{ Name = "channelType", Type = "ChatChannelType", Nilable = false },
				{ Name = "clubId", Type = "string", Nilable = false },
				{ Name = "streamId", Type = "string", Nilable = false },
				{ Name = "volume", Type = "number", Nilable = false },
				{ Name = "isActive", Type = "bool", Nilable = false },
				{ Name = "isMuted", Type = "bool", Nilable = false },
				{ Name = "isTransmitting", Type = "bool", Nilable = false },
				{ Name = "isLocalProcess", Type = "bool", Nilable = false },
				{ Name = "members", Type = "table", InnerType = "VoiceChatMember", Nilable = false },
			},
		},
		{
			Name = "VoiceChatMember",
			Type = "Structure",
			Fields =
			{
				{ Name = "energy", Type = "number", Nilable = false },
				{ Name = "memberID", Type = "number", Nilable = false },
				{ Name = "isActive", Type = "bool", Nilable = false },
				{ Name = "isSpeaking", Type = "bool", Nilable = false },
				{ Name = "isMutedForAll", Type = "bool", Nilable = false },
				{ Name = "isSilenced", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "VoiceChatProcess",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "channels", Type = "table", InnerType = "VoiceChatChannel", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(VoiceChat);