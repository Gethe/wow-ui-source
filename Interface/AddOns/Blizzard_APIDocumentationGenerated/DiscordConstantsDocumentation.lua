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
			Name = "DiscordChatInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "userID", Type = "DiscordID", Nilable = false },
				{ Name = "globalName", Type = "string", Nilable = false },
				{ Name = "username", Type = "string", Nilable = false },
				{ Name = "type", Type = "DiscordDisplayNameType", Nilable = false, Default = "Default" },
				{ Name = "lastOnlineGUID", Type = "WOWGUID", Nilable = false },
				{ Name = "lastOnlineName", Type = "string", Nilable = false },
				{ Name = "hasAttachment", Type = "bool", Nilable = false },
				{ Name = "hasPoll", Type = "bool", Nilable = false },
				{ Name = "hasEmbed", Type = "bool", Nilable = false },
				{ Name = "hasSticker", Type = "bool", Nilable = false },
				{ Name = "hasEmoji", Type = "bool", Nilable = false },
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