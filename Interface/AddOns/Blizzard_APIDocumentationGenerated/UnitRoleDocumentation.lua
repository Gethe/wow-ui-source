local UnitRole =
{
	Name = "UnitRole",
	Type = "System",

	Functions =
	{
		{
			Name = "AreClassRolesSoftSuggestions",
			Type = "Function",
			Documentation = { "If true, UnitGetAvailableRoles results should be treated as suggested role, not hard limits on what role the current player can display as." },

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanShowSetRoleButton",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "InitiateRolePoll",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitGetAvailableRoles",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
			},

			Returns =
			{
				{ Name = "tank", Type = "bool", Nilable = false },
				{ Name = "healer", Type = "bool", Nilable = false },
				{ Name = "dps", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitSetRole",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "roleStr", Type = "cstring", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UnitSetRoleEnum",
			Type = "Function",

			Arguments =
			{
				{ Name = "unit", Type = "UnitToken", Nilable = false },
				{ Name = "role", Type = "LFGRole", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "RoleChangedInform",
			Type = "Event",
			LiteralName = "ROLE_CHANGED_INFORM",
			Payload =
			{
				{ Name = "changedName", Type = "cstring", Nilable = false },
				{ Name = "fromName", Type = "cstring", Nilable = false },
				{ Name = "oldRole", Type = "cstring", Nilable = false },
				{ Name = "newRole", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "RolePollBegin",
			Type = "Event",
			LiteralName = "ROLE_POLL_BEGIN",
			Payload =
			{
				{ Name = "fromName", Type = "cstring", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(UnitRole);