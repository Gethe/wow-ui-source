local ToyBoxInfo =
{
	Name = "ToyBoxInfo",
	Type = "System",
	Namespace = "C_ToyBoxInfo",

	Functions =
	{
		{
			Name = "ClearFanfare",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "NeedsFanfare",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "needsFanfare", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "NewToyAdded",
			Type = "Event",
			LiteralName = "NEW_TOY_ADDED",
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ToysUpdated",
			Type = "Event",
			LiteralName = "TOYS_UPDATED",
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = true },
				{ Name = "isNew", Type = "bool", Nilable = true },
				{ Name = "hasFanfare", Type = "bool", Nilable = true },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(ToyBoxInfo);