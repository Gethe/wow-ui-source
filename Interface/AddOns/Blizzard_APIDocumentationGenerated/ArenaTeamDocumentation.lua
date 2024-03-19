local ArenaTeam =
{
	Name = "ArenaTeam",
	Type = "System",

	Functions =
	{
		{
			Name = "AcceptArenaTeam",
			Type = "Function",
		},
		{
			Name = "ArenaTeamDisband",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "ArenaTeamInviteByName",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
				{ Name = "target", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ArenaTeamLeave",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "ArenaTeamSetLeaderByName",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
				{ Name = "target", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ArenaTeamUninviteByName",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
				{ Name = "target", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "DeclineArenaTeam",
			Type = "Function",
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(ArenaTeam);