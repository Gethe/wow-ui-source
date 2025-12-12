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
			SecretArguments = "AllowedWhenUntainted",

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