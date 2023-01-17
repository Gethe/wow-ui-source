local NewItems =
{
	Name = "NewItems",
	Type = "System",
	Namespace = "C_NewItems",

	Functions =
	{
		{
			Name = "ClearAll",
			Type = "Function",
		},
		{
			Name = "IsNewItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "containerIndex", Type = "number", Nilable = false },
				{ Name = "slotIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isNew", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RemoveNewItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "containerIndex", Type = "number", Nilable = false },
				{ Name = "slotIndex", Type = "number", Nilable = false },
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