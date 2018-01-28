local Transmog =
{
	Name = "Transmogrify",
	Type = "System",
	Namespace = "C_Transmog",

	Functions =
	{
		{
			Name = "GetSlotForInventoryType",
			Type = "Function",

			Arguments =
			{
				{ Name = "inventoryType", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "slot", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(Transmog);