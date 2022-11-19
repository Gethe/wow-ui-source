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
			Name = "LanguageFlag",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 1,
			MaxValue = 2,
			Fields =
			{
				{ Name = "IsExotic", Type = "LanguageFlag", EnumValue = 1 },
				{ Name = "HiddenFromPlayer", Type = "LanguageFlag", EnumValue = 2 },
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
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "shortcut", Type = "string", Nilable = false },
				{ Name = "localID", Type = "number", Nilable = false },
				{ Name = "instanceID", Type = "number", Nilable = false },
				{ Name = "zoneChannelID", Type = "number", Nilable = false },
				{ Name = "channelType", Type = "PermanentChatChannelType", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ChatConstants);