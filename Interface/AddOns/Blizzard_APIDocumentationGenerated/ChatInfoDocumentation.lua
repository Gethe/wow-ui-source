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
			Name = "GetChannelInfoFromIdentifier",
			Type = "Function",

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
			Name = "IsAddonMessagePrefixRegistered",
			Type = "Function",

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
			Name = "IsPartyChannelType",
			Type = "Function",

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
			Name = "RegisterAddonMessagePrefix",
			Type = "Function",
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
			Name = "SwapChatChannelsByChannelIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "firstChannelIndex", Type = "luaIndex", Nilable = false },
				{ Name = "secondChannelIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "UncensorChatLine",
			Type = "Function",

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
		},
		{
			Name = "BnChatMsgAddon",
			Type = "Event",
			LiteralName = "BN_CHAT_MSG_ADDON",
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
			Payload =
			{
				{ Name = "languageId", Type = "number", Nilable = false },
				{ Name = "canSpeakLanguage", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChannelCountUpdate",
			Type = "Event",
			LiteralName = "CHANNEL_COUNT_UPDATE",
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
			Payload =
			{
				{ Name = "displayIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ChannelInviteRequest",
			Type = "Event",
			LiteralName = "CHANNEL_INVITE_REQUEST",
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
			Payload =
			{
				{ Name = "channelID", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ChannelRosterUpdate",
			Type = "Event",
			LiteralName = "CHANNEL_ROSTER_UPDATE",
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
		},
		{
			Name = "ChatCombatMsgArenaPointsGain",
			Type = "Event",
			LiteralName = "CHAT_COMBAT_MSG_ARENA_POINTS_GAIN",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgAchievement",
			Type = "Event",
			LiteralName = "CHAT_MSG_ACHIEVEMENT",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgAddon",
			Type = "Event",
			LiteralName = "CHAT_MSG_ADDON",
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
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgBgSystemAlliance",
			Type = "Event",
			LiteralName = "CHAT_MSG_BG_SYSTEM_ALLIANCE",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgBgSystemHorde",
			Type = "Event",
			LiteralName = "CHAT_MSG_BG_SYSTEM_HORDE",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgBgSystemNeutral",
			Type = "Event",
			LiteralName = "CHAT_MSG_BG_SYSTEM_NEUTRAL",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgBn",
			Type = "Event",
			LiteralName = "CHAT_MSG_BN",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgBnInlineToastAlert",
			Type = "Event",
			LiteralName = "CHAT_MSG_BN_INLINE_TOAST_ALERT",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgBnInlineToastBroadcast",
			Type = "Event",
			LiteralName = "CHAT_MSG_BN_INLINE_TOAST_BROADCAST",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgBnInlineToastBroadcastInform",
			Type = "Event",
			LiteralName = "CHAT_MSG_BN_INLINE_TOAST_BROADCAST_INFORM",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgBnInlineToastConversation",
			Type = "Event",
			LiteralName = "CHAT_MSG_BN_INLINE_TOAST_CONVERSATION",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgBnWhisper",
			Type = "Event",
			LiteralName = "CHAT_MSG_BN_WHISPER",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgBnWhisperInform",
			Type = "Event",
			LiteralName = "CHAT_MSG_BN_WHISPER_INFORM",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgBnWhisperPlayerOffline",
			Type = "Event",
			LiteralName = "CHAT_MSG_BN_WHISPER_PLAYER_OFFLINE",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgChannel",
			Type = "Event",
			LiteralName = "CHAT_MSG_CHANNEL",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgChannelJoin",
			Type = "Event",
			LiteralName = "CHAT_MSG_CHANNEL_JOIN",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgChannelLeave",
			Type = "Event",
			LiteralName = "CHAT_MSG_CHANNEL_LEAVE",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgChannelLeavePrevented",
			Type = "Event",
			LiteralName = "CHAT_MSG_CHANNEL_LEAVE_PREVENTED",
			Payload =
			{
				{ Name = "channelName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ChatMsgChannelList",
			Type = "Event",
			LiteralName = "CHAT_MSG_CHANNEL_LIST",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgChannelNotice",
			Type = "Event",
			LiteralName = "CHAT_MSG_CHANNEL_NOTICE",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgChannelNoticeUser",
			Type = "Event",
			LiteralName = "CHAT_MSG_CHANNEL_NOTICE_USER",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgCombatFactionChange",
			Type = "Event",
			LiteralName = "CHAT_MSG_COMBAT_FACTION_CHANGE",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgCombatHonorGain",
			Type = "Event",
			LiteralName = "CHAT_MSG_COMBAT_HONOR_GAIN",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgCombatMiscInfo",
			Type = "Event",
			LiteralName = "CHAT_MSG_COMBAT_MISC_INFO",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgCombatXpGain",
			Type = "Event",
			LiteralName = "CHAT_MSG_COMBAT_XP_GAIN",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgCommunitiesChannel",
			Type = "Event",
			LiteralName = "CHAT_MSG_COMMUNITIES_CHANNEL",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgCurrency",
			Type = "Event",
			LiteralName = "CHAT_MSG_CURRENCY",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgDnd",
			Type = "Event",
			LiteralName = "CHAT_MSG_DND",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgEmote",
			Type = "Event",
			LiteralName = "CHAT_MSG_EMOTE",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgFiltered",
			Type = "Event",
			LiteralName = "CHAT_MSG_FILTERED",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgGuild",
			Type = "Event",
			LiteralName = "CHAT_MSG_GUILD",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgGuildAchievement",
			Type = "Event",
			LiteralName = "CHAT_MSG_GUILD_ACHIEVEMENT",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgGuildItemLooted",
			Type = "Event",
			LiteralName = "CHAT_MSG_GUILD_ITEM_LOOTED",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgIgnored",
			Type = "Event",
			LiteralName = "CHAT_MSG_IGNORED",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgInstanceChat",
			Type = "Event",
			LiteralName = "CHAT_MSG_INSTANCE_CHAT",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgInstanceChatLeader",
			Type = "Event",
			LiteralName = "CHAT_MSG_INSTANCE_CHAT_LEADER",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgLoot",
			Type = "Event",
			LiteralName = "CHAT_MSG_LOOT",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgMoney",
			Type = "Event",
			LiteralName = "CHAT_MSG_MONEY",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgMonsterEmote",
			Type = "Event",
			LiteralName = "CHAT_MSG_MONSTER_EMOTE",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgMonsterParty",
			Type = "Event",
			LiteralName = "CHAT_MSG_MONSTER_PARTY",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgMonsterSay",
			Type = "Event",
			LiteralName = "CHAT_MSG_MONSTER_SAY",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgMonsterWhisper",
			Type = "Event",
			LiteralName = "CHAT_MSG_MONSTER_WHISPER",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgMonsterYell",
			Type = "Event",
			LiteralName = "CHAT_MSG_MONSTER_YELL",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgOfficer",
			Type = "Event",
			LiteralName = "CHAT_MSG_OFFICER",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgOpening",
			Type = "Event",
			LiteralName = "CHAT_MSG_OPENING",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgParty",
			Type = "Event",
			LiteralName = "CHAT_MSG_PARTY",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgPartyLeader",
			Type = "Event",
			LiteralName = "CHAT_MSG_PARTY_LEADER",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgPetBattleCombatLog",
			Type = "Event",
			LiteralName = "CHAT_MSG_PET_BATTLE_COMBAT_LOG",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgPetBattleInfo",
			Type = "Event",
			LiteralName = "CHAT_MSG_PET_BATTLE_INFO",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgPetInfo",
			Type = "Event",
			LiteralName = "CHAT_MSG_PET_INFO",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgPing",
			Type = "Event",
			LiteralName = "CHAT_MSG_PING",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgRaid",
			Type = "Event",
			LiteralName = "CHAT_MSG_RAID",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgRaidBossEmote",
			Type = "Event",
			LiteralName = "CHAT_MSG_RAID_BOSS_EMOTE",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgRaidBossWhisper",
			Type = "Event",
			LiteralName = "CHAT_MSG_RAID_BOSS_WHISPER",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgRaidLeader",
			Type = "Event",
			LiteralName = "CHAT_MSG_RAID_LEADER",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgRaidWarning",
			Type = "Event",
			LiteralName = "CHAT_MSG_RAID_WARNING",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgRestricted",
			Type = "Event",
			LiteralName = "CHAT_MSG_RESTRICTED",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgSay",
			Type = "Event",
			LiteralName = "CHAT_MSG_SAY",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgSkill",
			Type = "Event",
			LiteralName = "CHAT_MSG_SKILL",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgSystem",
			Type = "Event",
			LiteralName = "CHAT_MSG_SYSTEM",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgTargeticons",
			Type = "Event",
			LiteralName = "CHAT_MSG_TARGETICONS",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgTextEmote",
			Type = "Event",
			LiteralName = "CHAT_MSG_TEXT_EMOTE",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgTradeskills",
			Type = "Event",
			LiteralName = "CHAT_MSG_TRADESKILLS",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgVoiceText",
			Type = "Event",
			LiteralName = "CHAT_MSG_VOICE_TEXT",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgWhisper",
			Type = "Event",
			LiteralName = "CHAT_MSG_WHISPER",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgWhisperInform",
			Type = "Event",
			LiteralName = "CHAT_MSG_WHISPER_INFORM",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatMsgYell",
			Type = "Event",
			LiteralName = "CHAT_MSG_YELL",
			Payload =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "playerName", Type = "cstring", Nilable = false },
				{ Name = "languageName", Type = "cstring", Nilable = false },
				{ Name = "channelName", Type = "cstring", Nilable = false },
				{ Name = "playerName2", Type = "cstring", Nilable = false },
				{ Name = "specialFlags", Type = "cstring", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelIndex", Type = "number", Nilable = false },
				{ Name = "channelBaseName", Type = "cstring", Nilable = false },
				{ Name = "languageID", Type = "number", Nilable = false },
				{ Name = "lineID", Type = "number", Nilable = false },
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "bnSenderID", Type = "number", Nilable = false },
				{ Name = "isMobile", Type = "bool", Nilable = false },
				{ Name = "isSubtitle", Type = "bool", Nilable = false },
				{ Name = "hideSenderInLetterbox", Type = "bool", Nilable = false },
				{ Name = "supressRaidIcons", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatRegionalSendFailed",
			Type = "Event",
			LiteralName = "CHAT_REGIONAL_SEND_FAILED",
		},
		{
			Name = "ChatRegionalStatusChanged",
			Type = "Event",
			LiteralName = "CHAT_REGIONAL_STATUS_CHANGED",
			Payload =
			{
				{ Name = "isServiceAvailable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChatServerDisconnected",
			Type = "Event",
			LiteralName = "CHAT_SERVER_DISCONNECTED",
			Payload =
			{
				{ Name = "isInitialMessage", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "ChatServerReconnected",
			Type = "Event",
			LiteralName = "CHAT_SERVER_RECONNECTED",
		},
		{
			Name = "ClearBossEmotes",
			Type = "Event",
			LiteralName = "CLEAR_BOSS_EMOTES",
		},
		{
			Name = "DailyResetInstanceWelcome",
			Type = "Event",
			LiteralName = "DAILY_RESET_INSTANCE_WELCOME",
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
		},
		{
			Name = "NotifyChatSuppressed",
			Type = "Event",
			LiteralName = "NOTIFY_CHAT_SUPPRESSED",
		},
		{
			Name = "QuestBossEmote",
			Type = "Event",
			LiteralName = "QUEST_BOSS_EMOTE",
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
		},
		{
			Name = "UpdateFloatingChatWindows",
			Type = "Event",
			LiteralName = "UPDATE_FLOATING_CHAT_WINDOWS",
		},
	},

	Tables =
	{
		{
			Name = "RegisterAddonMessagePrefixResult",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Success", Type = "RegisterAddonMessagePrefixResult", EnumValue = 0 },
				{ Name = "DuplicatePrefix", Type = "RegisterAddonMessagePrefixResult", EnumValue = 1 },
				{ Name = "InvalidPrefix", Type = "RegisterAddonMessagePrefixResult", EnumValue = 2 },
				{ Name = "MaxPrefixes", Type = "RegisterAddonMessagePrefixResult", EnumValue = 3 },
			},
		},
		{
			Name = "SendAddonMessageResult",
			Type = "Enumeration",
			NumValues = 10,
			MinValue = 0,
			MaxValue = 9,
			Fields =
			{
				{ Name = "Success", Type = "SendAddonMessageResult", EnumValue = 0 },
				{ Name = "InvalidPrefix", Type = "SendAddonMessageResult", EnumValue = 1 },
				{ Name = "InvalidMessage", Type = "SendAddonMessageResult", EnumValue = 2 },
				{ Name = "AddonMessageThrottle", Type = "SendAddonMessageResult", EnumValue = 3 },
				{ Name = "InvalidChatType", Type = "SendAddonMessageResult", EnumValue = 4 },
				{ Name = "NotInGroup", Type = "SendAddonMessageResult", EnumValue = 5 },
				{ Name = "TargetRequired", Type = "SendAddonMessageResult", EnumValue = 6 },
				{ Name = "InvalidChannel", Type = "SendAddonMessageResult", EnumValue = 7 },
				{ Name = "ChannelThrottle", Type = "SendAddonMessageResult", EnumValue = 8 },
				{ Name = "GeneralError", Type = "SendAddonMessageResult", EnumValue = 9 },
			},
		},
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
	},
};

APIDocumentation:AddDocumentationTable(ChatInfo);