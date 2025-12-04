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
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "EventStoreUISetShown",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "newShown", Type = "bool", Nilable = false },
				{ Name = "contextKey", Type = "string", Nilable = true },
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