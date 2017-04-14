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

	Events =
	{
	},

	Tables =
	{
		{
			Name = "StoreDeliveryType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Item", Type = "StoreDeliveryType", EnumValue = 0 },
				{ Name = "Mount", Type = "StoreDeliveryType", EnumValue = 1 },
				{ Name = "Battlepet", Type = "StoreDeliveryType", EnumValue = 2 },
				{ Name = "Collection", Type = "StoreDeliveryType", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(StorePublicUI);