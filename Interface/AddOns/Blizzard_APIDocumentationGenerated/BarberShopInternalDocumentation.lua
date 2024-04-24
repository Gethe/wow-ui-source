local BarberShopInternal =
{
	Name = "BarberShop",
	Type = "System",
	Namespace = "C_BarberShopInternal",

	Functions =
	{
		{
			Name = "SetQAMode",
			Type = "Function",

			Arguments =
			{
				{ Name = "qaModeEnabled", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(BarberShopInternal);