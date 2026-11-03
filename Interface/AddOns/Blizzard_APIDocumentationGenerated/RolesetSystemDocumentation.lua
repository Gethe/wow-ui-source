local RolesetSystem =
{
	Name = "RolesetSystem",
	Type = "System",
	Namespace = "C_Roleset",
	Environment = "All",

	Functions =
	{
		{
			Name = "ApplyRolesetFilters",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Sets or clears both blocklist and allowlist filters atomically with a single visibility reevaluation. Pass an empty table to clear the corresponding filter. Blocked for tainted callers while in combat lockdown." },

			Arguments =
			{
				{ Name = "blockedRolesets", Type = "table", InnerType = "string", Nilable = false },
				{ Name = "allowedRolesets", Type = "table", InnerType = "string", Nilable = false },
			},
		},
		{
			Name = "GetActiveAllowedRolesets",
			Type = "Function",
			Documentation = { "Returns the rolesets in the currently active allowlist." },

			Returns =
			{
				{ Name = "allowedRolesets", Type = "table", InnerType = "string", Nilable = false },
			},
		},
		{
			Name = "GetActiveBlockedRolesets",
			Type = "Function",
			Documentation = { "Returns the rolesets in the currently active blocklist." },

			Returns =
			{
				{ Name = "blockedRolesets", Type = "table", InnerType = "string", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(RolesetSystem);