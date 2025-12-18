local DyeColorInfo =
{
	Name = "DyeColorInfo",
	Type = "System",
	Namespace = "C_DyeColor",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetAllDyeColorCategories",
			Type = "Function",

			Returns =
			{
				{ Name = "dyeColorCategoryIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetAllDyeColors",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "ownedColorsOnly", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "dyeColorIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetDyeColorCategoryInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "dyeColorCategoryID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "dyeColorCategoryInfo", Type = "DyeColorCategoryDisplayInfo", Nilable = true },
			},
		},
		{
			Name = "GetDyeColorForItem",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "itemLinkOrID", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "dyeColorID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetDyeColorForItemLocation",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "itemLocation", Type = "ItemLocation", Mixin = "ItemLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "dyeColorID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetDyeColorInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "dyeColorID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "dyeColorInfo", Type = "DyeColorDisplayInfo", Nilable = true },
			},
		},
		{
			Name = "GetDyeColorsInCategory",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "dyeColorCategory", Type = "number", Nilable = false },
				{ Name = "ownedColorsOnly", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "dyeColorIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "IsDyeColorOwned",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "True if the player owns any of the consumable item used to apply the specified dye" },

			Arguments =
			{
				{ Name = "dyeColorID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isOwned", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "DyeColorCategoryUpdated",
			Type = "Event",
			LiteralName = "DYE_COLOR_CATEGORY_UPDATED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "dyeColorCategoryID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "DyeColorUpdated",
			Type = "Event",
			LiteralName = "DYE_COLOR_UPDATED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "dyeColorID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(DyeColorInfo);