local RestrictedActions =
{
	Name = "RestrictedActions",
	Type = "System",

	Functions =
	{
		{
			Name = "InCombatLockdown",
			Type = "Function",

			Returns =
			{
				{ Name = "inCombatLockdown", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AddonActionBlocked",
			Type = "Event",
			LiteralName = "ADDON_ACTION_BLOCKED",
			Payload =
			{
				{ Name = "isTainted", Type = "cstring", Nilable = false },
				{ Name = "function", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "AddonActionForbidden",
			Type = "Event",
			LiteralName = "ADDON_ACTION_FORBIDDEN",
			Payload =
			{
				{ Name = "isTainted", Type = "cstring", Nilable = false },
				{ Name = "function", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "MacroActionBlocked",
			Type = "Event",
			LiteralName = "MACRO_ACTION_BLOCKED",
			Payload =
			{
				{ Name = "function", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "MacroActionForbidden",
			Type = "Event",
			LiteralName = "MACRO_ACTION_FORBIDDEN",
			Payload =
			{
				{ Name = "function", Type = "cstring", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(RestrictedActions);