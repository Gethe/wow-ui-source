local DiscordConstants =
{
	Tables =
	{
		{
			Name = "DiscordAccountType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Normal", Type = "DiscordAccountType", EnumValue = 0 },
				{ Name = "Provisional", Type = "DiscordAccountType", EnumValue = 1 },
			},
		},
		{
			Name = "DiscordChannelID",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 0,
			MaxValue = 0,
			Fields =
			{
				{ Name = "InvalidDiscordID", Type = "DiscordChannelID", EnumValue = 0 },
			},
		},
		{
			Name = "DiscordDisplayNameType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Default", Type = "DiscordDisplayNameType", EnumValue = 0 },
				{ Name = "LastOnline", Type = "DiscordDisplayNameType", EnumValue = 1 },
				{ Name = "GlobalName", Type = "DiscordDisplayNameType", EnumValue = 2 },
			},
		},
		{
			Name = "DiscordGuildID",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 0,
			MaxValue = 0,
			Fields =
			{
				{ Name = "InvalidDiscordID", Type = "DiscordGuildID", EnumValue = 0 },
			},
		},
		{
			Name = "DiscordGuildSettings",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "SeparateStream", Type = "DiscordGuildSettings", EnumValue = 1 },
			},
		},
		{
			Name = "DiscordID",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 0,
			MaxValue = 0,
			Fields =
			{
				{ Name = "InvalidDiscordID", Type = "DiscordID", EnumValue = 0 },
			},
		},
		{
			Name = "DiscordLobbyID",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 0,
			MaxValue = 0,
			Fields =
			{
				{ Name = "InvalidDiscordID", Type = "DiscordLobbyID", EnumValue = 0 },
			},
		},
		{
			Name = "DiscordMemberID",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 0,
			MaxValue = 0,
			Fields =
			{
				{ Name = "InvalidDiscordID", Type = "DiscordMemberID", EnumValue = 0 },
			},
		},
		{
			Name = "DiscordMessageID",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 0,
			MaxValue = 0,
			Fields =
			{
				{ Name = "InvalidDiscordID", Type = "DiscordMessageID", EnumValue = 0 },
			},
		},
		{
			Name = "DiscordChatInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "userID", Type = "DiscordMemberOpaqueID", Nilable = false },
				{ Name = "globalName", Type = "string", Nilable = false },
				{ Name = "type", Type = "DiscordDisplayNameType", Nilable = false, Default = "Default" },
				{ Name = "lastOnlineGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "lastOnlineName", Type = "string", Nilable = false },
				{ Name = "hasAttachment", Type = "bool", Nilable = false },
				{ Name = "hasPoll", Type = "bool", Nilable = false },
				{ Name = "hasEmbed", Type = "bool", Nilable = false },
				{ Name = "hasSticker", Type = "bool", Nilable = false },
				{ Name = "hasEmoji", Type = "bool", Nilable = false },
				{ Name = "hasError", Type = "bool", Nilable = false },
				{ Name = "hasForwardedMessage", Type = "bool", Nilable = false },
				{ Name = "forwardedMessage", Type = "string", Nilable = false },
				{ Name = "fromDiscord", Type = "bool", Nilable = false },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(DiscordConstants);