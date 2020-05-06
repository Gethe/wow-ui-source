local BarberShop =
{
	Name = "BarberShop",
	Type = "System",
	Namespace = "C_BarberShop",

	Functions =
	{
		{
			Name = "ApplyCustomizationChoices",
			Type = "Function",

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Cancel",
			Type = "Function",
		},
		{
			Name = "GetAvailableCustomizations",
			Type = "Function",

			Returns =
			{
				{ Name = "categories", Type = "table", InnerType = "CharCustomizationCategory", Nilable = false },
			},
		},
		{
			Name = "GetCurrentCost",
			Type = "Function",

			Returns =
			{
				{ Name = "cost", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ResetCustomizationChoices",
			Type = "Function",
		},
		{
			Name = "SetCustomizationChoice",
			Type = "Function",

			Arguments =
			{
				{ Name = "optionID", Type = "number", Nilable = false },
				{ Name = "choiceID", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "BarberShopAppearanceApplied",
			Type = "Event",
			LiteralName = "BARBER_SHOP_APPEARANCE_APPLIED",
		},
		{
			Name = "BarberShopClose",
			Type = "Event",
			LiteralName = "BARBER_SHOP_CLOSE",
		},
		{
			Name = "BarberShopCostUpdate",
			Type = "Event",
			LiteralName = "BARBER_SHOP_COST_UPDATE",
		},
		{
			Name = "BarberShopOpen",
			Type = "Event",
			LiteralName = "BARBER_SHOP_OPEN",
		},
		{
			Name = "BarberShopResult",
			Type = "Event",
			LiteralName = "BARBER_SHOP_RESULT",
			Payload =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(BarberShop);