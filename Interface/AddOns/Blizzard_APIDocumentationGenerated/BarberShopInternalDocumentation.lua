local BarberShopInternal =
{
	Name = "BarberShop",
	Type = "System",
	Namespace = "C_BarberShopInternal",
	Environment = "All",

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
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(BarberShopInternal);