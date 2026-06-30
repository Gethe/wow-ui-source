local Discord =
{
	Name = "Discord",
	Type = "System",
	Namespace = "C_Discord",
	Environment = "All",

	Functions =
	{
		{
			Name = "Authorize",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "GetDiscordChannelName",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "serverIndex", Type = "luaIndex", Nilable = false },
				{ Name = "channelIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetDiscordUserID",
			Type = "Function",
			HasRestrictions = true,

			Returns =
			{
				{ Name = "userID", Type = "DiscordID", Nilable = false },
			},
		},
		{
			Name = "GetDisplayNameType",
			Type = "Function",
			HasRestrictions = true,

			Returns =
			{
				{ Name = "type", Type = "DiscordDisplayNameType", Nilable = false },
			},
		},
		{
			Name = "GetGuildLinkStatus",
			Type = "Function",
			HasRestrictions = true,

			Returns =
			{
				{ Name = "isFullyLinked", Type = "bool", Nilable = false },
				{ Name = "linkedChannelName", Type = "string", Nilable = false },
				{ Name = "linkedServerName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetNumDiscordChannels",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "serverIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "count", Type = "number", Nilable = false },
				{ Name = "valid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetNumDiscordServers",
			Type = "Function",
			HasRestrictions = true,

			Returns =
			{
				{ Name = "count", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetServerLinkableChannels",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetServerName",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GuildLink",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "serverIndex", Type = "luaIndex", Nilable = false },
				{ Name = "channelIndex", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GuildUnlink",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "IsEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsGuildChannelLinked",
			Type = "Function",
			HasRestrictions = true,

			Returns =
			{
				{ Name = "isLinked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsGuildSettingSet",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "setting", Type = "DiscordGuildSettings", Nilable = false },
			},

			Returns =
			{
				{ Name = "isSet", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsUserOAuthed",
			Type = "Function",
			HasRestrictions = true,

			Returns =
			{
				{ Name = "hasOAuth", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RefreshAuth",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "SetGuildSetting",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "setting", Type = "DiscordGuildSettings", Nilable = false },
				{ Name = "set", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UpdateDiscordServers",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "UpdateGuildLobby",
			Type = "Function",
			HasRestrictions = true,
		},
	},

	Events =
	{
		{
			Name = "DiscordGuildAchievement",
			Type = "Event",
			LiteralName = "DISCORD_GUILD_ACHIEVEMENT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "achievementID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "DiscordGuildLobbyUpdate",
			Type = "Event",
			LiteralName = "DISCORD_GUILD_LOBBY_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "DiscordGuildSettingsUpdate",
			Type = "Event",
			LiteralName = "DISCORD_GUILD_SETTINGS_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "DiscordLinkUpdate",
			Type = "Event",
			LiteralName = "DISCORD_LINK_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "DiscordServerListUpdate",
			Type = "Event",
			LiteralName = "DISCORD_SERVER_LIST_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "DiscordStatusUpdate",
			Type = "Event",
			LiteralName = "DISCORD_STATUS_UPDATE",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(Discord);