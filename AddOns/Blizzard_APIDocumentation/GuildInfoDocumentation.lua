local GuildInfo =
{
	Name = "GuildInfo",
	Type = "System",
	Namespace = "C_GuildInfo",

	Functions =
	{
		{
			Name = "QueryGuildMemberRecipes",
			Type = "Function",

			Arguments =
			{
				{ Name = "guildMemberGUID", Type = "string", Nilable = false },
				{ Name = "skillLineID", Type = "number", Nilable = false },
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
			Name = "GuildChallengeCompleted",
			Type = "Event",
			LiteralName = "GUILD_CHALLENGE_COMPLETED",
			Payload =
			{
				{ Name = "challengeType", Type = "number", Nilable = false },
				{ Name = "currentCount", Type = "number", Nilable = false },
				{ Name = "maxCount", Type = "number", Nilable = false },
				{ Name = "goldAwarded", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GuildChallengeUpdated",
			Type = "Event",
			LiteralName = "GUILD_CHALLENGE_UPDATED",
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
			Name = "GuildNewsUpdate",
			Type = "Event",
			LiteralName = "GUILD_NEWS_UPDATE",
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
			Name = "GuildRecipeKnownByMembers",
			Type = "Event",
			LiteralName = "GUILD_RECIPE_KNOWN_BY_MEMBERS",
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
			Name = "GuildRewardsList",
			Type = "Event",
			LiteralName = "GUILD_REWARDS_LIST",
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
			Name = "GuildTradeskillUpdate",
			Type = "Event",
			LiteralName = "GUILD_TRADESKILL_UPDATE",
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