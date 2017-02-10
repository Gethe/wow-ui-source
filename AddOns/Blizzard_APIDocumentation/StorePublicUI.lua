local StorePublicUI =
{
	Name = "StorePublic",
	Type = "System",
	Namespace = "C_StorePublic",

	Functions =
	{
		{
			Name = "IsDisabledByParentalControls",
			Type = "Function",

			Returns =
			{
				{ Name = "disabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(StorePublicUI);