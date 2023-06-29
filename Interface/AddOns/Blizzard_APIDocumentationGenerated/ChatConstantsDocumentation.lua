local ChatConstants =
{
	Tables =
	{
		{
			Name = "ChatChannelRuleset",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 0,
			MaxValue = 8,
			Fields =
			{
				{ Name = "None", Type = "ChatChannelRuleset", EnumValue = 0 },
				{ Name = "Mentor", Type = "ChatChannelRuleset", EnumValue = 1 },
				{ Name = "Disabled", Type = "ChatChannelRuleset", EnumValue = 2 },
				{ Name = "ChromieTimeCataclysm", Type = "ChatChannelRuleset", EnumValue = 3 },
				{ Name = "ChromieTimeBuringCrusade", Type = "ChatChannelRuleset", EnumValue = 4 },
				{ Name = "ChromieTimeWrath", Type = "ChatChannelRuleset", EnumValue = 5 },
				{ Name = "ChromieTimeMists", Type = "ChatChannelRuleset", EnumValue = 6 },
				{ Name = "ChromieTimeWoD", Type = "ChatChannelRuleset", EnumValue = 7 },
				{ Name = "ChromieTimeLegion", Type = "ChatChannelRuleset", EnumValue = 8 },
			},
		},
		{
			Name = "ChatChannelType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "None", Type = "ChatChannelType", EnumValue = 0 },
				{ Name = "Custom", Type = "ChatChannelType", EnumValue = 1 },
				{ Name = "PrivateParty", Type = "ChatChannelType", EnumValue = 2 },
				{ Name = "PublicParty", Type = "ChatChannelType", EnumValue = 3 },
				{ Name = "Communities", Type = "ChatChannelType", EnumValue = 4 },
			},
		},
		{
			Name = "ChatToxityFilterOptOut",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 4294967295,
			Fields =
			{
				{ Name = "FilterAll", Type = "ChatToxityFilterOptOut", EnumValue = 0 },
				{ Name = "ExcludeFilterFriend", Type = "ChatToxityFilterOptOut", EnumValue = 1 },
				{ Name = "ExcludeFilterGuild", Type = "ChatToxityFilterOptOut", EnumValue = 2 },
				{ Name = "ExcludeFilterAll", Type = "ChatToxityFilterOptOut", EnumValue = 4294967295 },
			},
		},
		{
			Name = "ChatWhisperTargetStatus",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "CanWhisper", Type = "ChatWhisperTargetStatus", EnumValue = 0 },
				{ Name = "CanWhisperGuild", Type = "ChatWhisperTargetStatus", EnumValue = 1 },
				{ Name = "Offline", Type = "ChatWhisperTargetStatus", EnumValue = 2 },
				{ Name = "WrongFaction", Type = "ChatWhisperTargetStatus", EnumValue = 3 },
			},
		},
		{
			Name = "ExcludedCensorSources",
			Type = "Enumeration",
			NumValues = 10,
			MinValue = 0,
			MaxValue = 255,
			Fields =
			{
				{ Name = "None", Type = "ExcludedCensorSources", EnumValue = 0 },
				{ Name = "Friends", Type = "ExcludedCensorSources", EnumValue = 1 },
				{ Name = "Guild", Type = "ExcludedCensorSources", EnumValue = 2 },
				{ Name = "Reserve1", Type = "ExcludedCensorSources", EnumValue = 4 },
				{ Name = "Reserve2", Type = "ExcludedCensorSources", EnumValue = 8 },
				{ Name = "Reserve3", Type = "ExcludedCensorSources", EnumValue = 16 },
				{ Name = "Reserve4", Type = "ExcludedCensorSources", EnumValue = 32 },
				{ Name = "Reserve5", Type = "ExcludedCensorSources", EnumValue = 64 },
				{ Name = "Reserve6", Type = "ExcludedCensorSources", EnumValue = 128 },
				{ Name = "All", Type = "ExcludedCensorSources", EnumValue = 255 },
			},
		},
		{
			Name = "LanguageFlag",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 1,
			MaxValue = 4,
			Fields =
			{
				{ Name = "IsExotic", Type = "LanguageFlag", EnumValue = 1 },
				{ Name = "HiddenFromPlayer", Type = "LanguageFlag", EnumValue = 2 },
				{ Name = "HideLanguageNameInChat", Type = "LanguageFlag", EnumValue = 4 },
			},
		},
		{
			Name = "PermanentChatChannelType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "None", Type = "PermanentChatChannelType", EnumValue = 0 },
				{ Name = "Zone", Type = "PermanentChatChannelType", EnumValue = 1 },
				{ Name = "Communities", Type = "PermanentChatChannelType", EnumValue = 2 },
				{ Name = "Custom", Type = "PermanentChatChannelType", EnumValue = 3 },
			},
		},
		{
			Name = "TtsBoolSetting",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "PlaySoundSeparatingChatLineBreaks", Type = "TtsBoolSetting", EnumValue = 0 },
				{ Name = "AddCharacterNameToSpeech", Type = "TtsBoolSetting", EnumValue = 1 },
				{ Name = "PlayActivitySoundWhenNotFocused", Type = "TtsBoolSetting", EnumValue = 2 },
				{ Name = "AlternateSystemVoice", Type = "TtsBoolSetting", EnumValue = 3 },
				{ Name = "NarrateMyMessages", Type = "TtsBoolSetting", EnumValue = 4 },
			},
		},
		{
			Name = "TtsVoiceType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Standard", Type = "TtsVoiceType", EnumValue = 0 },
				{ Name = "Alternate", Type = "TtsVoiceType", EnumValue = 1 },
			},
		},
		{
			Name = "ChatChannelInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "shortcut", Type = "cstring", Nilable = false },
				{ Name = "localID", Type = "number", Nilable = false },
				{ Name = "instanceID", Type = "number", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelType", Type = "PermanentChatChannelType", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ChatConstants);