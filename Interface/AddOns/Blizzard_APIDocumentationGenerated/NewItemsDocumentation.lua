local NewItems =
{
	Name = "NewItems",
	Type = "System",
	Namespace = "C_NewItems",
	Environment = "All",

	Functions =
	{
		{
			Name = "ClearAll",
			Type = "Function",
		},
		{
			Name = "IsNewItem",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "containerIndex", Type = "BagIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isNew", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RemoveNewItem",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "containerIndex", Type = "BagIndex", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
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

APIDocumentation:AddDocumentationTable(NewItems);