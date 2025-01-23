local LFGListRoles =
{
	Name = "LFGListRoles",
	Type = "System",
	Namespace = "C_LFGListRoles",

	Functions =
	{
		{
			Name = "GetRoles",
			Type = "Function",

			Returns =
			{
				{ Name = "roles", Type = "LFGRoles", Nilable = false },
			},
		},
		{
			Name = "GetSavedRoles",
			Type = "Function",

			Returns =
			{
				{ Name = "roles", Type = "LFGRoles", Nilable = false },
			},
		},
		{
			Name = "SetRoles",
			Type = "Function",

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
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(LFGListRoles);