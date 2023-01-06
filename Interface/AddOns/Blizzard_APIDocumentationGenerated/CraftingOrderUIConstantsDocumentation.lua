local CraftingOrderUIConstants =
{
	Tables =
	{
		{
			Name = "CraftingOrderCustomerCategoryType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Primary", Type = "CraftingOrderCustomerCategoryType", EnumValue = 0 },
				{ Name = "Secondary", Type = "CraftingOrderCustomerCategoryType", EnumValue = 1 },
				{ Name = "Tertiary", Type = "CraftingOrderCustomerCategoryType", EnumValue = 2 },
			},
		},
		{
			Name = "CraftingOrderReagentsType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "All", Type = "CraftingOrderReagentsType", EnumValue = 0 },
				{ Name = "Some", Type = "CraftingOrderReagentsType", EnumValue = 1 },
				{ Name = "None", Type = "CraftingOrderReagentsType", EnumValue = 2 },
			},
		},
		{
			Name = "CraftingOrderBucketInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "skillLineAbilityID", Type = "number", Nilable = false },
				{ Name = "tipAmountAvg", Type = "number", Nilable = false },
				{ Name = "tipAmountMax", Type = "number", Nilable = false },
				{ Name = "numAvailable", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CraftingOrderClaimsRemainingInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "claimsRemaining", Type = "number", Nilable = false, Default = 0 },
				{ Name = "hoursToRecharge", Type = "number", Nilable = true },
			},
		},
		{
			Name = "CraftingOrderConsts",
			Type = "Constants",
			Values =
			{
				{ Name = "MAX_CRAFTING_ORDER_FAVORITE_RECIPES", Type = "number", Value = 100 },
			},
		},
		{
			Name = "CraftingOrderCustomerCategory",
			Type = "Structure",
			Fields =
			{
				{ Name = "categoryName", Type = "string", Nilable = false },
				{ Name = "categoryID", Type = "number", Nilable = false },
				{ Name = "uiSortOrder", Type = "number", Nilable = false },
				{ Name = "primaryCategorySortOrder", Type = "number", Nilable = true },
				{ Name = "secondaryCategorySortOrder", Type = "number", Nilable = true },
				{ Name = "type", Type = "CraftingOrderCustomerCategoryType", Nilable = false },
			},
		},
		{
			Name = "CraftingOrderCustomerCategoryFilters",
			Type = "Structure",
			Fields =
			{
				{ Name = "primaryCategoryID", Type = "number", Nilable = true },
				{ Name = "secondaryCategoryID", Type = "number", Nilable = true },
				{ Name = "tertiaryCategoryID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "CraftingOrderCustomerOptionInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "skillLineAbilityID", Type = "number", Nilable = false },
				{ Name = "professionID", Type = "number", Nilable = false },
				{ Name = "skillUpSkillLineID", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "itemName", Type = "string", Nilable = false },
				{ Name = "primaryCategoryID", Type = "number", Nilable = false },
				{ Name = "iLvl", Type = "number", Nilable = false },
				{ Name = "canUse", Type = "bool", Nilable = false },
				{ Name = "bindOnPickup", Type = "bool", Nilable = false },
				{ Name = "qualityIlvlBonuses", Type = "table", InnerType = "number", Nilable = true },
				{ Name = "craftingQualityIDs", Type = "table", InnerType = "number", Nilable = true },
				{ Name = "quality", Type = "ItemQuality", Nilable = true },
				{ Name = "slots", Type = "number", Nilable = true },
				{ Name = "level", Type = "number", Nilable = true },
				{ Name = "skill", Type = "number", Nilable = true },
				{ Name = "secondaryCategoryID", Type = "number", Nilable = true },
				{ Name = "tertiaryCategoryID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "CraftingOrderCustomerSearchParams",
			Type = "Structure",
			Fields =
			{
				{ Name = "categoryFilters", Type = "CraftingOrderCustomerCategoryFilters", Nilable = false },
				{ Name = "searchText", Type = "string", Nilable = true },
				{ Name = "minLevel", Type = "number", Nilable = false },
				{ Name = "maxLevel", Type = "number", Nilable = false },
				{ Name = "uncollectedOnly", Type = "bool", Nilable = false },
				{ Name = "usableOnly", Type = "bool", Nilable = false },
				{ Name = "upgradesOnly", Type = "bool", Nilable = false },
				{ Name = "includePoor", Type = "bool", Nilable = false },
				{ Name = "includeCommon", Type = "bool", Nilable = false },
				{ Name = "includeUncommon", Type = "bool", Nilable = false },
				{ Name = "includeRare", Type = "bool", Nilable = false },
				{ Name = "includeEpic", Type = "bool", Nilable = false },
				{ Name = "includeLegendary", Type = "bool", Nilable = false },
				{ Name = "includeArtifact", Type = "bool", Nilable = false },
				{ Name = "isFavoritesSearch", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CraftingOrderCustomerSearchResults",
			Type = "Structure",
			Fields =
			{
				{ Name = "options", Type = "table", InnerType = "CraftingOrderCustomerOptionInfo", Nilable = false },
				{ Name = "extraColumnType", Type = "AuctionHouseExtraColumn", Nilable = true },
			},
		},
		{
			Name = "CraftingOrderInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "orderID", Type = "number", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "skillLineAbilityID", Type = "number", Nilable = false },
				{ Name = "orderType", Type = "CraftingOrderType", Nilable = false },
				{ Name = "orderState", Type = "CraftingOrderState", Nilable = false },
				{ Name = "expirationTime", Type = "number", Nilable = false },
				{ Name = "claimEndTime", Type = "number", Nilable = false },
				{ Name = "minQuality", Type = "number", Nilable = false },
				{ Name = "tipAmount", Type = "number", Nilable = false },
				{ Name = "consortiumCut", Type = "number", Nilable = false },
				{ Name = "isRecraft", Type = "bool", Nilable = false },
				{ Name = "isFulfillable", Type = "bool", Nilable = false },
				{ Name = "reagentState", Type = "CraftingOrderReagentsType", Nilable = false },
				{ Name = "customerGuid", Type = "string", Nilable = true },
				{ Name = "customerName", Type = "string", Nilable = true },
				{ Name = "crafterGuid", Type = "string", Nilable = true },
				{ Name = "crafterName", Type = "string", Nilable = true },
				{ Name = "customerNotes", Type = "string", Nilable = false },
				{ Name = "reagents", Type = "table", InnerType = "CraftingOrderReagentInfo", Nilable = false },
				{ Name = "outputItemHyperlink", Type = "string", Nilable = true },
				{ Name = "outputItemGUID", Type = "string", Nilable = true },
				{ Name = "recraftItemHyperlink", Type = "string", Nilable = true },
			},
		},
		{
			Name = "CraftingOrderMailInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "reason", Type = "RcoCloseReason", Nilable = false },
				{ Name = "recipeName", Type = "string", Nilable = false },
				{ Name = "commissionPaid", Type = "number", Nilable = true },
				{ Name = "crafterNote", Type = "string", Nilable = true },
				{ Name = "crafterGUID", Type = "string", Nilable = true },
				{ Name = "crafterName", Type = "string", Nilable = true },
				{ Name = "customerGUID", Type = "string", Nilable = true },
				{ Name = "customerName", Type = "string", Nilable = true },
			},
		},
		{
			Name = "CraftingOrderPersonalOrdersInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "profession", Type = "Profession", Nilable = false },
				{ Name = "numPersonalOrders", Type = "number", Nilable = false },
				{ Name = "professionName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "CraftingOrderReagentInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "reagent", Type = "CraftingReagentInfo", Nilable = false },
				{ Name = "reagentSlot", Type = "number", Nilable = false },
				{ Name = "source", Type = "CraftingOrderReagentSource", Nilable = false },
				{ Name = "isBasicReagent", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CraftingOrderSortInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "sortType", Type = "CraftingOrderSortType", Nilable = false },
				{ Name = "reversed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "NewCraftingOrderInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "skillLineAbilityID", Type = "number", Nilable = false },
				{ Name = "orderType", Type = "CraftingOrderType", Nilable = false },
				{ Name = "orderDuration", Type = "CraftingOrderDuration", Nilable = false },
				{ Name = "tipAmount", Type = "number", Nilable = false },
				{ Name = "customerNotes", Type = "string", Nilable = false },
				{ Name = "reagentItems", Type = "table", InnerType = "RegularReagentInfo", Nilable = false },
				{ Name = "craftingReagentItems", Type = "table", InnerType = "CraftingReagentInfo", Nilable = false },
				{ Name = "minCraftingQualityID", Type = "number", Nilable = true },
				{ Name = "orderTarget", Type = "string", Nilable = true },
				{ Name = "recraftItem", Type = "string", Nilable = true },
			},
		},
		{
			Name = "CraftingOrderRequestCallback",
			Type = "CallbackType",

			Arguments =
			{
				{ Name = "result", Type = "CraftingOrderResult", Nilable = false },
				{ Name = "orderType", Type = "CraftingOrderType", Nilable = false },
				{ Name = "displayBuckets", Type = "bool", Nilable = false },
				{ Name = "expectMoreRows", Type = "bool", Nilable = false },
				{ Name = "offset", Type = "number", Nilable = false },
				{ Name = "isSorted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CraftingOrderRequestMyOrdersCallback",
			Type = "CallbackType",

			Arguments =
			{
				{ Name = "result", Type = "CraftingOrderResult", Nilable = false },
				{ Name = "expectMoreRows", Type = "bool", Nilable = false },
				{ Name = "offset", Type = "number", Nilable = false },
				{ Name = "isSorted", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CraftingOrderUIConstants);