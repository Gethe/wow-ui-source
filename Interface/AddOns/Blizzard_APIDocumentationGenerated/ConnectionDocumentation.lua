local Connection =
{
	Name = "ConnectionScript",
	Type = "System",

	Functions =
	{
		{
			Name = "CancelLogout",
			Type = "Function",
		},
		{
			Name = "ForceLogout",
			Type = "Function",
		},
		{
			Name = "ForceQuit",
			Type = "Function",
		},
		{
			Name = "GetNetIpTypes",
			Type = "Function",

			Returns =
			{
				{ Name = "ipTypes", Type = "ConnectionIptype", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "GetNetStats",
			Type = "Function",

			Returns =
			{
				{ Name = "in", Type = "number", Nilable = false },
				{ Name = "out", Type = "number", Nilable = false },
				{ Name = "latencyList", Type = "number", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "GetRealmID",
			Type = "Function",

			Returns =
			{
				{ Name = "realmID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRealmName",
			Type = "Function",

			Returns =
			{
				{ Name = "realmName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "IsOnTournamentRealm",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Logout",
			Type = "Function",
		},
		{
			Name = "Quit",
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

APIDocumentation:AddDocumentationTable(Connection);