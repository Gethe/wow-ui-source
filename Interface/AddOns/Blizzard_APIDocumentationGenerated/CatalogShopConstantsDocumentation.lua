local CatalogShopConstants =
{
	Tables =
	{
		{
			Name = "CatalogShopPurchaseEligibility",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "Eligible", Type = "CatalogShopPurchaseEligibility", EnumValue = 0 },
				{ Name = "IneligibleOwned", Type = "CatalogShopPurchaseEligibility", EnumValue = 1 },
				{ Name = "IneligibleTokenOnGlues", Type = "CatalogShopPurchaseEligibility", EnumValue = 2 },
				{ Name = "IneligibleMissingRequiredAchievement", Type = "CatalogShopPurchaseEligibility", EnumValue = 3 },
				{ Name = "IneligibleOwnTooManyFromSelectionGroup", Type = "CatalogShopPurchaseEligibility", EnumValue = 4 },
				{ Name = "IneligibleUnknownProduct", Type = "CatalogShopPurchaseEligibility", EnumValue = 5 },
			},
		},
		{
			Name = "InclusionMode",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 1,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Included", Type = "InclusionMode", EnumValue = 1 },
				{ Name = "PlayerSelectable", Type = "InclusionMode", EnumValue = 2 },
			},
		},
		{
			Name = "SelectionConstraint",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "SelectionConstraint", EnumValue = 0 },
				{ Name = "Unique", Type = "SelectionConstraint", EnumValue = 1 },
				{ Name = "Repeatable", Type = "SelectionConstraint", EnumValue = 2 },
			},
		},
		{
			Name = "VcInitState",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "VcIsReset", Type = "VcInitState", EnumValue = 0 },
				{ Name = "VcIsInitializing", Type = "VcInitState", EnumValue = 1 },
				{ Name = "VcIsInitialized", Type = "VcInitState", EnumValue = 2 },
			},
		},
		{
			Name = "CatalogShopAchievementServerValidationConstants",
			Type = "Constants",
			Values =
			{
				{ Name = "HAS_REQUIRED_ACHIEVEMENT_THROTTLE", Type = "number", Value = 100 },
				{ Name = "SHOP_WOW_STOREFRONT_ATTRIBUTE_REQUIRED_ACHIEVEMENT", Type = "cstring", Value = "RequiredAchievementID" },
				{ Name = "SERVER_VALIDATION_BYPASS_FORMAT", Type = "cstring", Value = "%s but bypass is enabled" },
			},
		},
		{
			Name = "CatalogShopConsts",
			Type = "Constants",
			Values =
			{
				{ Name = "LINK_TAG_SERVICES", Type = "string", Value = "services" },
				{ Name = "PRODUCT_TYPE_MOUNT", Type = "string", Value = "Mount" },
				{ Name = "PRODUCT_TYPE_PET", Type = "string", Value = "Pet" },
				{ Name = "PRODUCT_TYPE_TOY", Type = "string", Value = "Toy" },
				{ Name = "PRODUCT_TYPE_DECOR", Type = "string", Value = "Decor" },
				{ Name = "NUMBER_OF_LICENSES_ON_TRACKING_PRODUCT", Type = "number", Value = 1 },
			},
		},
		{
			Name = "CatalogShopVirtualCurrencyConstants",
			Type = "Constants",
			Values =
			{
				{ Name = "HEARTHSTEEL_VC_CURRENCY_CODE", Type = "cstring", Value = "XVV" },
				{ Name = "TRADERS_TENDER_VC_CURRENCY_CODE", Type = "cstring", Value = "XWP" },
				{ Name = "TALEBOUND_VC_CURRENCY_CODE", Type = "cstring", Value = "XZC" },
				{ Name = "VC_CURRENCY_CODE_SIZE", Type = "number", Value = 3 },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(CatalogShopConstants);