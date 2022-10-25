local CraftingOrderUI =
{
	Name = "CraftingOrderUI",
	Type = "System",
	Namespace = "C_CraftingOrders",

	Functions =
	{
		{
			Name = "CloseCustomerCraftingOrders",
			Type = "Function",
		},
		{
			Name = "GetCustomerCategories",
			Type = "Function",

			Returns =
			{
				{ Name = "categories", Type = "table", InnerType = "CraftingOrderCustomerCategory", Nilable = false },
			},
		},
		{
			Name = "GetCustomerOptions",
			Type = "Function",

			Arguments =
			{
				{ Name = "params", Type = "CraftingOrderCustomerSearchParams", Nilable = false },
			},

			Returns =
			{
				{ Name = "results", Type = "CraftingOrderCustomerSearchResults", Nilable = false },
			},
		},
		{
			Name = "HasFavoriteCustomerOptions",
			Type = "Function",

			Returns =
			{
				{ Name = "hasFavorites", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsCustomerOptionFavorited",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "favorited", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ParseCustomerOptions",
			Type = "Function",
		},
		{
			Name = "SetCustomerOptionFavorited",
			Type = "Function",

			Arguments =
			{
				{ Name = "recipeID", Type = "number", Nilable = false },
				{ Name = "favorited", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "CraftingordersCustomerFavoritesChanged",
			Type = "Event",
			LiteralName = "CRAFTINGORDERS_CUSTOMER_FAVORITES_CHANGED",
		},
		{
			Name = "CraftingordersCustomerOptionsParsed",
			Type = "Event",
			LiteralName = "CRAFTINGORDERS_CUSTOMER_OPTIONS_PARSED",
		},
		{
			Name = "CraftingordersHideCrafter",
			Type = "Event",
			LiteralName = "CRAFTINGORDERS_HIDE_CRAFTER",
		},
		{
			Name = "CraftingordersHideCustomer",
			Type = "Event",
			LiteralName = "CRAFTINGORDERS_HIDE_CUSTOMER",
		},
		{
			Name = "CraftingordersShowCrafter",
			Type = "Event",
			LiteralName = "CRAFTINGORDERS_SHOW_CRAFTER",
		},
		{
			Name = "CraftingordersShowCustomer",
			Type = "Event",
			LiteralName = "CRAFTINGORDERS_SHOW_CUSTOMER",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(CraftingOrderUI);