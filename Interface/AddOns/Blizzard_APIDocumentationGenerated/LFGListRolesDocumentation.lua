local LFGListRoles =
{
	Name = "LFGListRoles",
	Type = "System",
	Namespace = "C_LFGListRoles",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetRoles",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "roles", Type = "LFGRoles", Nilable = false },
			},
		},
		{
			Name = "GetSavedRoles",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "roles", Type = "LFGRoles", Nilable = false },
			},
		},
		{
			Name = "SetRoles",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "roles", Type = "LFGRoles", Nilable = false },
				{ Name = "limitToClassRoles", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "LfgListRoleUpdate",
			Type = "Event",
			LiteralName = "LFG_LIST_ROLE_UPDATE",
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

APIDocumentation:AddDocumentationTable(LFGListRoles);