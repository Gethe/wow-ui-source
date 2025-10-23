local ChatInfo =
{
	Name = "ChatInfo",
	Type = "System",
	Namespace = "C_ChatInfo",

	Functions =
	{
		{
			Name = "CanPlayerSpeakLanguage",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "languageId", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "canSpeakLanguage", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CancelEmote",
			Type = "Function",
		},
		{
			Name = "DropCautionaryChatMessage",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "confirmNumber", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetChannelInfoFromIdentifier",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "channelIdentifier", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "ChatChannelInfo", Nilable = true },
			},
		},
		{
			Name = "GetChannelRosterInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "channelIndex", Type = "luaIndex", Nilable = false },
				{ Name = "rosterIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "owner", Type = "bool", Nilable = false },
				{ Name = "moderator", Type = "bool", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "GetChannelRuleset",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "channelIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "ruleset", Type = "ChatChannelRuleset", Nilable = false },
			},
		},
		{
			Name = "GetChannelRulesetForChannelID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "channelID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "ruleset", Type = "ChatChannelRuleset", Nilable = false },
			},
		},
		{
			Name = "GetChannelShortcut",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "channelIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "shortcut", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetChannelShortcutForChannelID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "channelID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "shortcut", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetChatLineSenderGUID",
			Type = "Function",
			SecretInChatMessagingLockdown = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "chatLine", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "GetChatLineSenderName",
			Type = "Function",
			SecretInChatMessagingLockdown = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "chatLine", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetChatLineText",
			Type = "Function",
			SecretInChatMessagingLockdown = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "chatLine", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "text", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetChatTypeName",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "typeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetClubStreamIDs",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "clubID", Type = "ClubId", Nilable = false },
			},

			Returns =
			{
				{ Name = "ids", Type = "table", InnerType = "ClubStreamId", Nilable = false },
			},
		},
		{
			Name = "GetColorForChatType",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "chatType", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "color", Type = "colorRGB", Mixin = "ColorMixin", Nilable = true },
			},
		},
		{
			Name = "GetGeneralChannelID",
			Type = "Function",

			Returns =
			{
				{ Name = "channelID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetGeneralChannelLocalID",
			Type = "Function",

			Returns =
			{
				{ Name = "localID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetMentorChannelID",
			Type = "Function",

			Returns =
			{
				{ Name = "channelID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumActiveChannels",
			Type = "Function",

			Returns =
			{
				{ Name = "numChannels", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumReservedChatWindows",
			Type = "Function",

			Returns =
			{
				{ Name = "numReserved", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRegisteredAddonMessagePrefixes",
			Type = "Function",

			Returns =
			{
				{ Name = "registeredPrefixes", Type = "table", InnerType = "cstring", Nilable = false },
			},
		},
		{
			Name = "InChatMessagingLockdown",
			Type = "Function",
			Documentation = { "Returns true if API security restrictions regarding chat messaging are in effect." },

			Returns =
			{
				{ Name = "isRestricted", Type = "bool", Nilable = false },
				{ Name = "lockdownReason", Type = "ChatMessagingLockdownReason", Nilable = true, Documentation = { "Optionally specified reason for the chat lockdown. Always nil if isRestricted is false, but should also be treated as potentially nil if true." } },
			},
		},
		{
			Name = "IsAddonMessagePrefixRegistered",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "prefix", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "isRegistered", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsChannelRegional",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "channelIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isRegional", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsChannelRegionalForChannelID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "channelID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isRegional", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsChatLineCensored",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "chatLine", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isCensored", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsLoggingChat",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsLoggingCombat",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
				{ Name = "advanced", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPartyChannelType",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "channelType", Type = "ChatChannelType", Nilable = false },
			},

			Returns =
			{
				{ Name = "isPartyChannelType", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRegionalServiceAvailable",
			Type = "Function",

			Returns =
			{
				{ Name = "available", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsTimerunningPlayer",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "playerGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "isTimerunning", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsValidChatLine",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "chatLine", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "isValid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsValidCombatFilterName",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "isApproved", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PerformEmote",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "emoteName", Type = "cstring", Nilable = false },
				{ Name = "targetName", Type = "cstring", Nilable = true },
				{ Name = "suppressMoveError", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RegisterAddonMessagePrefix",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Registers interest in addon messages with this prefix, cannot be an empty string." },

			Arguments =
			{
				{ Name = "prefix", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "RegisterAddonMessagePrefixResult", Nilable = false },
			},
		},
		{
			Name = "ReplaceIconAndGroupExpressions",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "input", Type = "string", Nilable = false },
				{ Name = "noIconReplacement", Type = "bool", Nilable = true },
				{ Name = "noGroupReplacement", Type = "bool", Nilable = true },
			},

			Returns =
			{
				{ Name = "output", Type = "string", Nilable = false },
			},
		},
		{
			Name = "RequestCanLocalWhisperTarget",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "whisperTarget", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "ResetDefaultZoneChannels",
			Type = "Function",
		},
		{
			Name = "SendAddonMessage",
			Type = "Function",
			SecretArguments = "NotAllowed",
			Documentation = { "Sends a text payload to other clients specified by chatChannel and target which are registered to listen for prefix." },

			Arguments =
			{
				{ Name = "prefix", Type = "cstring", Nilable = false },
				{ Name = "message", Type = "cstring", Nilable = false },
				{ Name = "chatType", Type = "cstring", Nilable = true, Documentation = { "ChatType, defaults to SLASH_CMD_PARTY." } },
				{ Name = "target", Type = "cstring", Nilable = true, Documentation = { "Only applies for targeted channels" } },
			},

			Returns =
			{
				{ Name = "result", Type = "SendAddonMessageResult", Nilable = false },
			},
		},
		{
			Name = "SendAddonMessageLogged",
			Type = "Function",
			SecretArguments = "NotAllowed",
			Documentation = { "Sends a text payload to other clients specified by chatChannel and target which are registered to listen for prefix. Intended for plain text payloads; logged and throttled." },

			Arguments =
			{
				{ Name = "prefix", Type = "cstring", Nilable = false },
				{ Name = "message", Type = "cstring", Nilable = false },
				{ Name = "chatType", Type = "cstring", Nilable = true, Documentation = { "ChatType, defaults to SLASH_CMD_PARTY." } },
				{ Name = "target", Type = "cstring", Nilable = true, Documentation = { "Only applies for targeted channels" } },
			},

			Returns =
			{
				{ Name = "result", Type = "SendAddonMessageResult", Nilable = true },
			},
		},
		{
			Name = "SendCautionaryChatMessage",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "confirmNumber", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SendChatMessage",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "message", Type = "cstring", Nilable = false },
				{ Name = "chatType", Type = "SendChatMessageType", Nilable = true, Documentation = { "Chat type string ('SAY', 'EMOTE', etc.). Defaults to 'SAY' if not specified." } },
				{ Name = "languageID", Type = "number", Nilable = true, Documentation = { "Language to send the message in." } },
				{ Name = "target", Type = "cstring", Nilable = true, Documentation = { "Name of the player to send a message to. Only applies to chat types that support targeted messages." } },
			},
		},
		{
			Name = "SwapChatChannelsByChannelIndex",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "firstChannelIndex", Type = "luaIndex", Nilable = false },
				{ Name = "secondChannelIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "UncensorChatLine",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "chatLine", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AlternativeDefaultLanguageChanged",
			Type = "Event",
			LiteralName = "ALTERNATIVE_DEFAULT_LANGUAGE_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "BnChatMsgAddon",
			Type = "Event",
			LiteralName = "BN_CHAT_MSG_ADDON",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "prefix", Type = "cstring", Nilable = false },
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "channel", Type = "cstring", Nilable = false },
				{ Name = "senderID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CanLocalWhisperTargetResponse",
			Type = "Event",
			LiteralName = "CAN_LOCAL_WHISPER_TARGET_RESPONSE",
			UniqueEvent = true,
			Payload =
			{
				{ Name = "whisperTarget", Type = "WOWGUID", Nilable = false },
				{ Name = "status", Type = "ChatWhisperTargetStatus", Nilable = false },
			},
		},
		{
			Name = "CanPlayerSpeakLanguageChanged",
			Type = "Event",
			LiteralName = "CAN_PLAYER_SPEAK_LANGUAGE_CHANGED",
			UniqueEvent = true,
			Payload =
			{
				{ Name = "languageId", Type = "number", Nilable = false },
				{ Name = "canSpeakLanguage", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CautionaryChannelMessage",
			Type = "Event",
			LiteralName = "CAUTIONARY_CHANNEL_MESSAGE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "confirmNumber", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CautionaryChatMessage",
			Type = "Event",
			LiteralName = "CAUTIONARY_CHAT_MESSAGE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "chatLineID", Type = "number", Nilable = false },
				{ Name = "confirmNumber", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ChannelCountUpdate",
			Type = "Event",
			LiteralName = "CHANNEL_COUNT_UPDATE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "displayIndex", Type = "number", Nilable = false },
				{ Name = "count", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ChannelFlagsUpdated",
			Type = "Event",
			LiteralName = "CHANNEL_FLAGS_UPDATED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "displayIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ChannelInviteRequest",
			Type = "Event",
			LiteralName = "CHANNEL_INVITE_REQUEST",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "channelID", Type = "cstring", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ChannelLeft",
			Type = "Event",
			LiteralName = "CHANNEL_LEFT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "chatChannelID", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ChannelPasswordRequest",
			Type = "Event",
			LiteralName = "CHANNEL_PASSWORD_REQUEST",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "channelID", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ChannelRosterUpdate",
			Type = "Event",
			LiteralName = "CHANNEL_ROSTER_UPDATE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "displayIndex", Type = "number", Nilable = false },
				{ Name = "count", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ChannelUiUpdate",
			Type = "Event",
			LiteralName = "CHANNEL_UI_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "ChatCombatMsgArenaPointsGain",
			Type = "Event",
			LiteralName = "CHAT_COMBAT_MSG_ARENA_POINTS_GAIN",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatLoggingChanged",
			Type = "Event",
			LiteralName = "CHAT_LOGGING_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "whichLog", Type = "number", Nilable = false },
				{ Name = "isEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgAchievement",
			Type = "Event",
			LiteralName = "CHAT_MSG_ACHIEVEMENT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgAddon",
			Type = "Event",
			LiteralName = "CHAT_MSG_ADDON",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "prefix", Type = "cstring", Nilable = false },
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "channel", Type = "cstring", Nilable = false },
				{ Name = "sender", Type = "cstring", Nilable = false },
				{ Name = "target", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "localID", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "instanceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ChatMsgAddonLogged",
			Type = "Event",
			LiteralName = "CHAT_MSG_ADDON_LOGGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "prefix", Type = "cstring", Nilable = false },
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "channel", Type = "cstring", Nilable = false },
				{ Name = "sender", Type = "cstring", Nilable = false },
				{ Name = "target", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "localID", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "instanceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ChatMsgAfk",
			Type = "Event",
			LiteralName = "CHAT_MSG_AFK",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgBgSystemAlliance",
			Type = "Event",
			LiteralName = "CHAT_MSG_BG_SYSTEM_ALLIANCE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgBgSystemHorde",
			Type = "Event",
			LiteralName = "CHAT_MSG_BG_SYSTEM_HORDE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgBgSystemNeutral",
			Type = "Event",
			LiteralName = "CHAT_MSG_BG_SYSTEM_NEUTRAL",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgBn",
			Type = "Event",
			LiteralName = "CHAT_MSG_BN",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgBnInlineToastAlert",
			Type = "Event",
			LiteralName = "CHAT_MSG_BN_INLINE_TOAST_ALERT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgBnInlineToastBroadcast",
			Type = "Event",
			LiteralName = "CHAT_MSG_BN_INLINE_TOAST_BROADCAST",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgBnInlineToastBroadcastInform",
			Type = "Event",
			LiteralName = "CHAT_MSG_BN_INLINE_TOAST_BROADCAST_INFORM",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgBnInlineToastConversation",
			Type = "Event",
			LiteralName = "CHAT_MSG_BN_INLINE_TOAST_CONVERSATION",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgBnWhisper",
			Type = "Event",
			LiteralName = "CHAT_MSG_BN_WHISPER",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgBnWhisperInform",
			Type = "Event",
			LiteralName = "CHAT_MSG_BN_WHISPER_INFORM",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgBnWhisperPlayerOffline",
			Type = "Event",
			LiteralName = "CHAT_MSG_BN_WHISPER_PLAYER_OFFLINE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgChannel",
			Type = "Event",
			LiteralName = "CHAT_MSG_CHANNEL",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgChannelJoin",
			Type = "Event",
			LiteralName = "CHAT_MSG_CHANNEL_JOIN",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgChannelLeave",
			Type = "Event",
			LiteralName = "CHAT_MSG_CHANNEL_LEAVE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgChannelLeavePrevented",
			Type = "Event",
			LiteralName = "CHAT_MSG_CHANNEL_LEAVE_PREVENTED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "channelName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ChatMsgChannelList",
			Type = "Event",
			LiteralName = "CHAT_MSG_CHANNEL_LIST",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgChannelNotice",
			Type = "Event",
			LiteralName = "CHAT_MSG_CHANNEL_NOTICE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgChannelNoticeUser",
			Type = "Event",
			LiteralName = "CHAT_MSG_CHANNEL_NOTICE_USER",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgCombatFactionChange",
			Type = "Event",
			LiteralName = "CHAT_MSG_COMBAT_FACTION_CHANGE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgCombatHonorGain",
			Type = "Event",
			LiteralName = "CHAT_MSG_COMBAT_HONOR_GAIN",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgCombatMiscInfo",
			Type = "Event",
			LiteralName = "CHAT_MSG_COMBAT_MISC_INFO",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgCombatXpGain",
			Type = "Event",
			LiteralName = "CHAT_MSG_COMBAT_XP_GAIN",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgCommunitiesChannel",
			Type = "Event",
			LiteralName = "CHAT_MSG_COMMUNITIES_CHANNEL",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgCurrency",
			Type = "Event",
			LiteralName = "CHAT_MSG_CURRENCY",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgDnd",
			Type = "Event",
			LiteralName = "CHAT_MSG_DND",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgEmote",
			Type = "Event",
			LiteralName = "CHAT_MSG_EMOTE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgEncounterEvent",
			Type = "Event",
			LiteralName = "CHAT_MSG_ENCOUNTER_EVENT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgFiltered",
			Type = "Event",
			LiteralName = "CHAT_MSG_FILTERED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgGuild",
			Type = "Event",
			LiteralName = "CHAT_MSG_GUILD",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgGuildAchievement",
			Type = "Event",
			LiteralName = "CHAT_MSG_GUILD_ACHIEVEMENT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgGuildItemLooted",
			Type = "Event",
			LiteralName = "CHAT_MSG_GUILD_ITEM_LOOTED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgIgnored",
			Type = "Event",
			LiteralName = "CHAT_MSG_IGNORED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgInstanceChat",
			Type = "Event",
			LiteralName = "CHAT_MSG_INSTANCE_CHAT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgInstanceChatLeader",
			Type = "Event",
			LiteralName = "CHAT_MSG_INSTANCE_CHAT_LEADER",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgLoot",
			Type = "Event",
			LiteralName = "CHAT_MSG_LOOT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgMoney",
			Type = "Event",
			LiteralName = "CHAT_MSG_MONEY",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgMonsterEmote",
			Type = "Event",
			LiteralName = "CHAT_MSG_MONSTER_EMOTE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgMonsterParty",
			Type = "Event",
			LiteralName = "CHAT_MSG_MONSTER_PARTY",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgMonsterSay",
			Type = "Event",
			LiteralName = "CHAT_MSG_MONSTER_SAY",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgMonsterWhisper",
			Type = "Event",
			LiteralName = "CHAT_MSG_MONSTER_WHISPER",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgMonsterYell",
			Type = "Event",
			LiteralName = "CHAT_MSG_MONSTER_YELL",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgOfficer",
			Type = "Event",
			LiteralName = "CHAT_MSG_OFFICER",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgOpening",
			Type = "Event",
			LiteralName = "CHAT_MSG_OPENING",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgParty",
			Type = "Event",
			LiteralName = "CHAT_MSG_PARTY",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgPartyLeader",
			Type = "Event",
			LiteralName = "CHAT_MSG_PARTY_LEADER",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgPetBattleCombatLog",
			Type = "Event",
			LiteralName = "CHAT_MSG_PET_BATTLE_COMBAT_LOG",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgPetBattleInfo",
			Type = "Event",
			LiteralName = "CHAT_MSG_PET_BATTLE_INFO",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgPetInfo",
			Type = "Event",
			LiteralName = "CHAT_MSG_PET_INFO",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgPing",
			Type = "Event",
			LiteralName = "CHAT_MSG_PING",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgRaid",
			Type = "Event",
			LiteralName = "CHAT_MSG_RAID",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgRaidBossEmote",
			Type = "Event",
			LiteralName = "CHAT_MSG_RAID_BOSS_EMOTE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgRaidBossWhisper",
			Type = "Event",
			LiteralName = "CHAT_MSG_RAID_BOSS_WHISPER",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgRaidLeader",
			Type = "Event",
			LiteralName = "CHAT_MSG_RAID_LEADER",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgRaidWarning",
			Type = "Event",
			LiteralName = "CHAT_MSG_RAID_WARNING",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgRestricted",
			Type = "Event",
			LiteralName = "CHAT_MSG_RESTRICTED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgSay",
			Type = "Event",
			LiteralName = "CHAT_MSG_SAY",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgSkill",
			Type = "Event",
			LiteralName = "CHAT_MSG_SKILL",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgSystem",
			Type = "Event",
			LiteralName = "CHAT_MSG_SYSTEM",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgTargeticons",
			Type = "Event",
			LiteralName = "CHAT_MSG_TARGETICONS",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgTextEmote",
			Type = "Event",
			LiteralName = "CHAT_MSG_TEXT_EMOTE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgTradeskills",
			Type = "Event",
			LiteralName = "CHAT_MSG_TRADESKILLS",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgVoiceText",
			Type = "Event",
			LiteralName = "CHAT_MSG_VOICE_TEXT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgWhisper",
			Type = "Event",
			LiteralName = "CHAT_MSG_WHISPER",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgWhisperInform",
			Type = "Event",
			LiteralName = "CHAT_MSG_WHISPER_INFORM",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgYell",
			Type = "Event",
			LiteralName = "CHAT_MSG_YELL",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatRegionalSendFailed",
			Type = "Event",
			LiteralName = "CHAT_REGIONAL_SEND_FAILED",
			SynchronousEvent = true,
		},
		{
			Name = "ChatRegionalStatusChanged",
			Type = "Event",
			LiteralName = "CHAT_REGIONAL_STATUS_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "isServiceAvailable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatServerDisconnected",
			Type = "Event",
			LiteralName = "CHAT_SERVER_DISCONNECTED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "isInitialMessage", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "ChatServerReconnected",
			Type = "Event",
			LiteralName = "CHAT_SERVER_RECONNECTED",
			SynchronousEvent = true,
		},
		{
			Name = "ClearBossEmotes",
			Type = "Event",
			LiteralName = "CLEAR_BOSS_EMOTES",
			SynchronousEvent = true,
		},
		{
			Name = "DailyResetInstanceWelcome",
			Type = "Event",
			LiteralName = "DAILY_RESET_INSTANCE_WELCOME",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "mapname", Type = "cstring", Nilable = false },
				{ Name = "timeLeft", Type = "number", Nilable = false },
			},
		},
		{
			Name = "InstanceResetWarning",
			Type = "Event",
			LiteralName = "INSTANCE_RESET_WARNING",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "warningMessage", Type = "cstring", Nilable = false },
				{ Name = "timeLeft", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LanguageListChanged",
			Type = "Event",
			LiteralName = "LANGUAGE_LIST_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "NotifyChatSuppressed",
			Type = "Event",
			LiteralName = "NOTIFY_CHAT_SUPPRESSED",
			SynchronousEvent = true,
		},
		{
			Name = "QuestBossEmote",
			Type = "Event",
			LiteralName = "QUEST_BOSS_EMOTE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "displayTime", Type = "number", Nilable = false },
				{ Name = "enableBossEmoteWarningSound", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RaidBossEmote",
			Type = "Event",
			LiteralName = "RAID_BOSS_EMOTE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "displayTime", Type = "number", Nilable = false },
				{ Name = "enableBossEmoteWarningSound", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RaidBossWhisper",
			Type = "Event",
			LiteralName = "RAID_BOSS_WHISPER",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "displayTime", Type = "number", Nilable = false },
				{ Name = "enableBossEmoteWarningSound", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RaidInstanceWelcome",
			Type = "Event",
			LiteralName = "RAID_INSTANCE_WELCOME",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "mapname", Type = "cstring", Nilable = false },
				{ Name = "timeLeft", Type = "number", Nilable = false },
				{ Name = "locked", Type = "number", Nilable = false },
				{ Name = "extended", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UpdateChatColor",
			Type = "Event",
			LiteralName = "UPDATE_CHAT_COLOR",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "r", Type = "number", Nilable = false },
				{ Name = "g", Type = "number", Nilable = false },
				{ Name = "b", Type = "number", Nilable = false },
			},
		},
		{
			Name = "UpdateChatColorNameByClass",
			Type = "Event",
			LiteralName = "UPDATE_CHAT_COLOR_NAME_BY_CLASS",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "colorNameByClass", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UpdateChatWindows",
			Type = "Event",
			LiteralName = "UPDATE_CHAT_WINDOWS",
			SynchronousEvent = true,
		},
		{
			Name = "UpdateFloatingChatWindows",
			Type = "Event",
			LiteralName = "UPDATE_FLOATING_CHAT_WINDOWS",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
		{
			Name = "AddonMessageParams",
			Type = "Structure",
			Fields =
			{
				{ Name = "prefix", Type = "cstring", Nilable = false },
				{ Name = "message", Type = "cstring", Nilable = false },
				{ Name = "chatType", Type = "cstring", Nilable = true, Documentation = { "ChatType, defaults to SLASH_CMD_PARTY." } },
				{ Name = "target", Type = "cstring", Nilable = true, Documentation = { "Only applies for targeted channels" } },
			},
		},
		{
			Name = "ChatMessageEventParams",
			Type = "Structure",
			Fields =
			{
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "playerName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "bnSenderID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "suppressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SendChatMessageParams",
			Type = "Structure",
			Fields =
			{
				{ Name = "message", Type = "cstring", Nilable = false },
				{ Name = "chatType", Type = "SendChatMessageType", Nilable = true, Documentation = { "Chat type string ('SAY', 'EMOTE', etc.). Defaults to 'SAY' if not specified." } },
				{ Name = "languageID", Type = "number", Nilable = true, Documentation = { "Language to send the message in." } },
				{ Name = "target", Type = "cstring", Nilable = true, Documentation = { "Name of the player to send a message to. Only applies to chat types that support targeted messages." } },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ChatInfo);