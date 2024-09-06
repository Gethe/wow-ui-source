local CraftingOrderUIShared =
{
	Tables =
	{
		{
			Name = "CraftingOrderBucketInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "skillLineAbilityID", Type = "number", Nilable = false },
				{ Name = "tipAmountAvg", Type = "WOWMONEY", Nilable = false },
				{ Name = "tipAmountMax", Type = "WOWMONEY", Nilable = false },
				{ Name = "numAvailable", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CraftingOrderClaimsRemainingInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "claimsRemaining", Type = "number", Nilable = false, Default = 0 },
				{ Name = "secondsToRecharge", Type = "number", Nilable = true },
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
				{ Name = "iLvlMin", Type = "number", Nilable = false },
				{ Name = "iLvlMax", Type = "number", Nilable = true },
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
				{ Name = "expansionID", Type = "number", Nilable = true },
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
				{ Name = "currentExpansionOnly", Type = "bool", Nilable = false },
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
				{ Name = "orderID", Type = "BigUInteger", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "skillLineAbilityID", Type = "number", Nilable = false },
				{ Name = "orderType", Type = "CraftingOrderType", Nilable = false },
				{ Name = "orderState", Type = "CraftingOrderState", Nilable = false },
				{ Name = "expirationTime", Type = "time_t", Nilable = false },
				{ Name = "claimEndTime", Type = "time_t", Nilable = false },
				{ Name = "minQuality", Type = "number", Nilable = false },
				{ Name = "tipAmount", Type = "WOWMONEY", Nilable = false },
				{ Name = "consortiumCut", Type = "WOWMONEY", Nilable = false },
				{ Name = "isRecraft", Type = "bool", Nilable = false },
				{ Name = "isFulfillable", Type = "bool", Nilable = false },
				{ Name = "reagentState", Type = "CraftingOrderReagentsType", Nilable = false },
				{ Name = "customerGuid", Type = "WOWGUID", Nilable = true },
				{ Name = "customerName", Type = "string", Nilable = true },
				{ Name = "crafterGuid", Type = "WOWGUID", Nilable = true },
				{ Name = "crafterName", Type = "string", Nilable = true },
				{ Name = "npcCustomerCreatureID", Type = "number", Nilable = true },
				{ Name = "customerNotes", Type = "string", Nilable = false },
				{ Name = "reagents", Type = "table", InnerType = "CraftingOrderReagentInfo", Nilable = false },
				{ Name = "outputItemHyperlink", Type = "string", Nilable = true },
				{ Name = "outputItemGUID", Type = "WOWGUID", Nilable = true },
				{ Name = "recraftItemHyperlink", Type = "string", Nilable = true },
				{ Name = "npcOrderRewards", Type = "table", InnerType = "CraftingOrderRewardInfo", Nilable = false },
				{ Name = "npcCraftingOrderSetID", Type = "number", Nilable = false },
				{ Name = "npcTreasureID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CraftingOrderMailInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "reason", Type = "RcoCloseReason", Nilable = false },
				{ Name = "recipeName", Type = "string", Nilable = false },
				{ Name = "commissionPaid", Type = "WOWMONEY", Nilable = true },
				{ Name = "crafterNote", Type = "string", Nilable = true },
				{ Name = "crafterGUID", Type = "WOWGUID", Nilable = true },
				{ Name = "crafterName", Type = "string", Nilable = true },
				{ Name = "customerGUID", Type = "WOWGUID", Nilable = true },
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
				{ Name = "professionName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "CraftingOrderReagentInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "reagent", Type = "CraftingReagentInfo", Nilable = false },
				{ Name = "slotIndex", Type = "luaIndex", Nilable = false },
				{ Name = "source", Type = "CraftingOrderReagentSource", Nilable = false },
				{ Name = "isBasicReagent", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CraftingOrderRewardInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemLink", Type = "string", Nilable = true },
				{ Name = "currencyType", Type = "number", Nilable = true },
				{ Name = "count", Type = "number", Nilable = false },
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
				{ Name = "tipAmount", Type = "WOWMONEY", Nilable = false },
				{ Name = "customerNotes", Type = "string", Nilable = false },
				{ Name = "reagentItems", Type = "table", InnerType = "RegularReagentInfo", Nilable = false },
				{ Name = "craftingReagentItems", Type = "table", InnerType = "CraftingReagentInfo", Nilable = false },
				{ Name = "minCraftingQualityID", Type = "number", Nilable = true },
				{ Name = "orderTarget", Type = "string", Nilable = true },
				{ Name = "recraftItem", Type = "WOWGUID", Nilable = true },
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

APIDocumentation:AddDocumentationTable(CraftingOrderUIShared);