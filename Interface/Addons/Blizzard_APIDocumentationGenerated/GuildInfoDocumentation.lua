local GuildInfo =
{
	Name = "GuildInfo",
	Type = "System",
	Namespace = "C_GuildInfo",

	Functions =
	{
		{
			Name = "CanEditOfficerNote",
			Type = "Function",

			Returns =
			{
				{ Name = "canEditOfficerNote", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanSpeakInGuildChat",
			Type = "Function",

			Returns =
			{
				{ Name = "canSpeakInGuildChat", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanViewOfficerNote",
			Type = "Function",

			Returns =
			{
				{ Name = "canViewOfficerNote", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Demote",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "Disband",
			Type = "Function",
		},
		{
			Name = "GetGuildRankOrder",
			Type = "Function",

			Arguments =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "rankOrder", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetGuildTabardInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = true },
			},

			Returns =
			{
				{ Name = "tabardInfo", Type = "GuildTabardInfo", Nilable = true },
			},
		},
		{
			Name = "GuildControlGetRankFlags",
			Type = "Function",

			Arguments =
			{
				{ Name = "rankOrder", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "permissions", Type = "table", InnerType = "bool", Nilable = false },
			},
		},
		{
			Name = "GuildRoster",
			Type = "Function",
		},
		{
			Name = "Invite",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "IsGuildOfficer",
			Type = "Function",

			Returns =
			{
				{ Name = "isOfficer", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsGuildRankAssignmentAllowed",
			Type = "Function",

			Arguments =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "rankOrder", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isGuildRankAssignmentAllowed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Leave",
			Type = "Function",
		},
		{
			Name = "MemberExistsByName",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "exists", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Promote",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "QueryGuildMembersForRecipe",
			Type = "Function",

			Arguments =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
				{ Name = "recipeSpellID", Type = "number", Nilable = false },
				{ Name = "recipeLevel", Type = "luaIndex", Nilable = true },
			},

			Returns =
			{
				{ Name = "updatedRecipeSpellID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RemoveFromGuild",
			Type = "Function",

			Arguments =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
			},
		},
		{
			Name = "SetGuildRankOrder",
			Type = "Function",

			Arguments =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "rankOrder", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "SetLeader",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "SetMOTD",
			Type = "Function",

			Arguments =
			{
				{ Name = "motd", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "SetNote",
			Type = "Function",

			Arguments =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
				{ Name = "note", Type = "cstring", Nilable = false },
				{ Name = "isPublic", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Uninvite",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
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
			Name = "GuildEventLogUpdate",
			Type = "Event",
			LiteralName = "GUILD_EVENT_LOG_UPDATE",
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
				{ Name = "inviter", Type = "cstring", Nilable = false },
				{ Name = "guildName", Type = "cstring", Nilable = false },
				{ Name = "guildAchievementPoints", Type = "number", Nilable = false },
				{ Name = "oldGuildName", Type = "cstring", Nilable = false },
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
				{ Name = "emblemFilename", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "GuildMotd",
			Type = "Event",
			LiteralName = "GUILD_MOTD",
			Payload =
			{
				{ Name = "motdText", Type = "cstring", Nilable = false },
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
				{ Name = "unitTarget", Type = "UnitToken", Nilable = false },
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