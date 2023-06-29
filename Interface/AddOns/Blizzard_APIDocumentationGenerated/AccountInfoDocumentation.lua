local AccountInfo =
{
	Name = "AccountInfo",
	Type = "System",
	Namespace = "C_AccountInfo",

	Functions =
	{
		{
			Name = "GetIDFromBattleNetAccountGUID",
			Type = "Function",

			Arguments =
			{
				{ Name = "battleNetAccountGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "battleNetAccountID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsGUIDBattleNetAccountType",
			Type = "Function",

			Arguments =
			{
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
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
				{ Name = "guid", Type = "WOWGUID", Nilable = false },
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