local ToyBoxInfo =
{
	Name = "ToyBoxInfo",
	Type = "System",
	Namespace = "C_ToyBoxInfo",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "ToysUpdated",
			Type = "Event",
			LiteralName = "TOYS_UPDATED",
			Payload =
			{
				{ Name = "itemID", Type = "number", Nilable = true },
				{ Name = "isNew", Type = "bool", Nilable = true },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(ToyBoxInfo);