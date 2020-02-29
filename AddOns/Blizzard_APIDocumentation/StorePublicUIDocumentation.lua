local StorePublicUI =
{
	Name = "StorePublic",
	Type = "System",
	Namespace = "C_StorePublic",

	Functions =
	{
		{
			Name = "DoesGroupHavePurchaseableProducts",
			Type = "Function",

			Arguments =
			{
				{ Name = "groupID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasPurchaseableProducts", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasPurchaseableProducts",
			Type = "Function",

			Returns =
			{
				{ Name = "hasPurchaseableProducts", Type = "bool", Nilable = false },
			},
		},
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

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(StorePublicUI);