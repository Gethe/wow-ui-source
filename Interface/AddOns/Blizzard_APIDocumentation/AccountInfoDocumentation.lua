local AccountInfo =
{
	Name = "AccountInfo",
	Type = "System",
	Namespace = "C_AccountInfo",

	Functions =
	{
		{
			Name = "IsGUIDBattleNetAccountType",
			Type = "Function",

			Arguments =
			{
				{ Name = "guid", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "isBNet", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsGUIDRelatedToLocalAccount",
			Type = "Function",

			Arguments =
			{
				{ Name = "guid", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "isLocalUser", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(AccountInfo);