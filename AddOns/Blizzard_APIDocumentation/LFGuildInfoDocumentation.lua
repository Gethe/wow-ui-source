local LFGuildInfo =
{
	Name = "LFGuildInfo",
	Type = "System",
	Namespace = "C_LFGuildInfo",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "LfGuildBrowseUpdated",
			Type = "Event",
			LiteralName = "LF_GUILD_BROWSE_UPDATED",
		},
		{
			Name = "LfGuildMembershipListChanged",
			Type = "Event",
			LiteralName = "LF_GUILD_MEMBERSHIP_LIST_CHANGED",
		},
		{
			Name = "LfGuildMembershipListUpdated",
			Type = "Event",
			LiteralName = "LF_GUILD_MEMBERSHIP_LIST_UPDATED",
			Payload =
			{
				{ Name = "numApplicationsRemaining", Type = "number", Nilable = false },
			},
		},
		{
			Name = "LfGuildPostUpdated",
			Type = "Event",
			LiteralName = "LF_GUILD_POST_UPDATED",
		},
		{
			Name = "LfGuildRecruitListChanged",
			Type = "Event",
			LiteralName = "LF_GUILD_RECRUIT_LIST_CHANGED",
		},
		{
			Name = "LfGuildRecruitsUpdated",
			Type = "Event",
			LiteralName = "LF_GUILD_RECRUITS_UPDATED",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(LFGuildInfo);