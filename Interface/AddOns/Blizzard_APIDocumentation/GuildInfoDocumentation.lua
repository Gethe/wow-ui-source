local GuildInfo =
{
	Name = "GuildInfo",
	Type = "System",
	Namespace = "C_GuildInfo",

	Functions =
	{
		{
			Name = "CanSpeakInGuildChat",
			Type = "Function",

			Returns =
			{
				{ Name = "canSpeakInGuildChat", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetGuildRankOrder",
			Type = "Function",

			Arguments =
			{
				{ Name = "guid", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "rankOrder", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GuildControlGetRankFlags",
			Type = "Function",

			Arguments =
			{
				{ Name = "rankOrder", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "permissions", Type = "table", InnerType = "bool", Nilable = false },
			},
		},
		{
			Name = "IsGuildRankAssignmentAllowed",
			Type = "Function",

			Arguments =
			{
				{ Name = "guid", Type = "string", Nilable = false },
				{ Name = "rankOrder", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RemoveFromGuild",
			Type = "Function",

			Arguments =
			{
				{ Name = "guid", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetGuildRankOrder",
			Type = "Function",

			Arguments =
			{
				{ Name = "guid", Type = "string", Nilable = false },
				{ Name = "rankOrder", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetNote",
			Type = "Function",

			Arguments =
			{
				{ Name = "guid", Type = "string", Nilable = false },
				{ Name = "note", Type = "string", Nilable = false },
				{ Name = "isPublic", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "CloseTabardFrame",
			Type = "Event",
			LiteralName = "CLOSE_TABARD_FRAME",
		},
		{
			Name = "DisableDeclineGuildInvite",
			Type = "Event",
			LiteralName = "DISABLE_DECLINE_GUILD_INVITE",
		},
		{
			Name = "EnableDeclineGuildInvite",
			Type = "Event",
			LiteralName = "ENABLE_DECLINE_GUILD_INVITE",
		},
		{
			Name = "GuildInviteCancel",
			Type = "Event",
			LiteralName = "GUILD_INVITE_CANCEL",
		},
		{
			Name = "GuildInviteRequest",
			Type = "Event",
			LiteralName = "GUILD_INVITE_REQUEST",
			Payload =
			{
				{ Name = "inviter", Type = "string", Nilable = false },
				{ Name = "guildName", Type = "string", Nilable = false },
				{ Name = "guildAchievementPoints", Type = "number", Nilable = false },
				{ Name = "oldGuildName", Type = "string", Nilable = false },
				{ Name = "isNewGuild", Type = "bool", Nilable = true },
				{ Name = "bkgColorR", Type = "number", Nilable = true },
				{ Name = "bkgColorG", Type = "number", Nilable = true },
				{ Name = "bkgColorB", Type = "number", Nilable = true },
				{ Name = "borderColorR", Type = "number", Nilable = true },
				{ Name = "borderColorG", Type = "number", Nilable = true },
				{ Name = "borderColorB", Type = "number", Nilable = true },
				{ Name = "emblemColorR", Type = "number", Nilable = true },
				{ Name = "emblemColorG", Type = "number", Nilable = true },
				{ Name = "emblemColorB", Type = "number", Nilable = true },
				{ Name = "emblemFilename", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GuildMotd",
			Type = "Event",
			LiteralName = "GUILD_MOTD",
			Payload =
			{
				{ Name = "motdText", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GuildPartyStateUpdated",
			Type = "Event",
			LiteralName = "GUILD_PARTY_STATE_UPDATED",
			Payload =
			{
				{ Name = "inGuildParty", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GuildRanksUpdate",
			Type = "Event",
			LiteralName = "GUILD_RANKS_UPDATE",
		},
		{
			Name = "GuildRegistrarClosed",
			Type = "Event",
			LiteralName = "GUILD_REGISTRAR_CLOSED",
		},
		{
			Name = "GuildRegistrarShow",
			Type = "Event",
			LiteralName = "GUILD_REGISTRAR_SHOW",
		},
		{
			Name = "GuildRenameRequired",
			Type = "Event",
			LiteralName = "GUILD_RENAME_REQUIRED",
			Payload =
			{
				{ Name = "flagSet", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GuildRosterUpdate",
			Type = "Event",
			LiteralName = "GUILD_ROSTER_UPDATE",
			Payload =
			{
				{ Name = "canRequestRosterUpdate", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GuildtabardUpdate",
			Type = "Event",
			LiteralName = "GUILDTABARD_UPDATE",
		},
		{
			Name = "OpenTabardFrame",
			Type = "Event",
			LiteralName = "OPEN_TABARD_FRAME",
		},
		{
			Name = "PlayerGuildUpdate",
			Type = "Event",
			LiteralName = "PLAYER_GUILD_UPDATE",
			Payload =
			{
				{ Name = "unitTarget", Type = "string", Nilable = false },
			},
		},
		{
			Name = "RequiredGuildRenameResult",
			Type = "Event",
			LiteralName = "REQUIRED_GUILD_RENAME_RESULT",
			Payload =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TabardCansaveChanged",
			Type = "Event",
			LiteralName = "TABARD_CANSAVE_CHANGED",
		},
		{
			Name = "TabardSavePending",
			Type = "Event",
			LiteralName = "TABARD_SAVE_PENDING",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(GuildInfo);