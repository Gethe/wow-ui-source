local CraftingOrderUI =
{
	Name = "CraftingOrderUI",
	Type = "System",
	Namespace = "C_CraftingOrders",

	Functions =
	{
		{
			Name = "AreOrderNotesDisabled",
			Type = "Function",

			Returns =
			{
				{ Name = "areNotesDisabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CalculateCraftingOrderPostingFee",
			Type = "Function",

			Arguments =
			{
				{ Name = "skillLineAbilityID", Type = "number", Nilable = false },
				{ Name = "orderType", Type = "CraftingOrderType", Nilable = false },
				{ Name = "orderDuration", Type = "CraftingOrderDuration", Nilable = false },
			},

			Returns =
			{
				{ Name = "deposit", Type = "WOWMONEY", Nilable = false },
			},
		},
		{
			Name = "CanOrderSkillAbility",
			Type = "Function",

			Arguments =
			{
				{ Name = "skillLineAbilityID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "canOrder", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CancelOrder",
			Type = "Function",

			Arguments =
			{
				{ Name = "orderID", Type = "BigUInteger", Nilable = false },
			},
		},
		{
			Name = "ClaimOrder",
			Type = "Function",

			Arguments =
			{
				{ Name = "orderID", Type = "BigUInteger", Nilable = false },
				{ Name = "profession", Type = "Profession", Nilable = false },
			},
		},
		{
			Name = "CloseCrafterCraftingOrders",
			Type = "Function",
		},
		{
			Name = "CloseCustomerCraftingOrders",
			Type = "Function",
		},
		{
			Name = "FulfillOrder",
			Type = "Function",

			Arguments =
			{
				{ Name = "orderID", Type = "BigUInteger", Nilable = false },
				{ Name = "crafterNote", Type = "string", Nilable = false },
				{ Name = "profession", Type = "Profession", Nilable = false },
			},
		},
		{
			Name = "GetClaimedOrder",
			Type = "Function",

			Returns =
			{
				{ Name = "order", Type = "CraftingOrderInfo", Nilable = true },
			},
		},
		{
			Name = "GetCrafterBuckets",
			Type = "Function",

			Returns =
			{
				{ Name = "buckets", Type = "table", InnerType = "CraftingOrderBucketInfo", Nilable = false },
			},
		},
		{
			Name = "GetCrafterOrders",
			Type = "Function",

			Returns =
			{
				{ Name = "orders", Type = "table", InnerType = "CraftingOrderInfo", Nilable = false },
			},
		},
		{
			Name = "GetCraftingOrderTime",
			Type = "Function",

			Returns =
			{
				{ Name = "time", Type = "BigUInteger", Nilable = false },
			},
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
			Name = "GetCustomerOrders",
			Type = "Function",

			Returns =
			{
				{ Name = "customerOrders", Type = "table", InnerType = "CraftingOrderInfo", Nilable = false },
			},
		},
		{
			Name = "GetDefaultOrdersSkillLine",
			Type = "Function",

			Returns =
			{
				{ Name = "skillLineID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetMyOrders",
			Type = "Function",

			Returns =
			{
				{ Name = "myOrders", Type = "table", InnerType = "CraftingOrderInfo", Nilable = false },
			},
		},
		{
			Name = "GetNumFavoriteCustomerOptions",
			Type = "Function",

			Returns =
			{
				{ Name = "numFavorites", Type = "BigUInteger", Nilable = false },
			},
		},
		{
			Name = "GetOrderClaimInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "profession", Type = "Profession", Nilable = false },
			},

			Returns =
			{
				{ Name = "claimInfo", Type = "CraftingOrderClaimsRemainingInfo", Nilable = false },
			},
		},
		{
			Name = "GetPersonalOrdersInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "infos", Type = "table", InnerType = "CraftingOrderPersonalOrdersInfo", Nilable = false },
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
			Name = "ListMyOrders",
			Type = "Function",

			Arguments =
			{
				{ Name = "request", Type = "CraftingOrderRequestMyOrdersInfo", Nilable = false },
			},
		},
		{
			Name = "OpenCrafterCraftingOrders",
			Type = "Function",
		},
		{
			Name = "OpenCustomerCraftingOrders",
			Type = "Function",
		},
		{
			Name = "OrderCanBeRecrafted",
			Type = "Function",

			Arguments =
			{
				{ Name = "orderID", Type = "BigUInteger", Nilable = false },
			},

			Returns =
			{
				{ Name = "recraftable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ParseCustomerOptions",
			Type = "Function",
		},
		{
			Name = "PlaceNewOrder",
			Type = "Function",

			Arguments =
			{
				{ Name = "orderInfo", Type = "NewCraftingOrderInfo", Nilable = false },
			},
		},
		{
			Name = "RejectOrder",
			Type = "Function",

			Arguments =
			{
				{ Name = "orderID", Type = "BigUInteger", Nilable = false },
				{ Name = "crafterNote", Type = "string", Nilable = false },
				{ Name = "profession", Type = "Profession", Nilable = false },
			},
		},
		{
			Name = "ReleaseOrder",
			Type = "Function",

			Arguments =
			{
				{ Name = "orderID", Type = "BigUInteger", Nilable = false },
				{ Name = "profession", Type = "Profession", Nilable = false },
			},
		},
		{
			Name = "RequestCrafterOrders",
			Type = "Function",

			Arguments =
			{
				{ Name = "request", Type = "CraftingOrderRequestInfo", Nilable = false },
			},
		},
		{
			Name = "RequestCustomerOrders",
			Type = "Function",

			Arguments =
			{
				{ Name = "request", Type = "CraftingOrderRequestInfo", Nilable = false },
			},
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
		{
			Name = "ShouldShowCraftingOrderTab",
			Type = "Function",

			Returns =
			{
				{ Name = "showTab", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SkillLineHasOrders",
			Type = "Function",

			Arguments =
			{
				{ Name = "skillLineID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasOrders", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UpdateIgnoreList",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "CraftingHouseDisabled",
			Type = "Event",
			LiteralName = "CRAFTING_HOUSE_DISABLED",
		},
		{
			Name = "CraftingordersCanRequest",
			Type = "Event",
			LiteralName = "CRAFTINGORDERS_CAN_REQUEST",
		},
		{
			Name = "CraftingordersClaimOrderResponse",
			Type = "Event",
			LiteralName = "CRAFTINGORDERS_CLAIM_ORDER_RESPONSE",
			Payload =
			{
				{ Name = "result", Type = "CraftingOrderResult", Nilable = false },
				{ Name = "orderID", Type = "BigUInteger", Nilable = false },
			},
		},
		{
			Name = "CraftingordersClaimedOrderAdded",
			Type = "Event",
			LiteralName = "CRAFTINGORDERS_CLAIMED_ORDER_ADDED",
		},
		{
			Name = "CraftingordersClaimedOrderRemoved",
			Type = "Event",
			LiteralName = "CRAFTINGORDERS_CLAIMED_ORDER_REMOVED",
		},
		{
			Name = "CraftingordersClaimedOrderUpdated",
			Type = "Event",
			LiteralName = "CRAFTINGORDERS_CLAIMED_ORDER_UPDATED",
			Payload =
			{
				{ Name = "orderID", Type = "BigUInteger", Nilable = false },
			},
		},
		{
			Name = "CraftingordersCraftOrderResponse",
			Type = "Event",
			LiteralName = "CRAFTINGORDERS_CRAFT_ORDER_RESPONSE",
			Payload =
			{
				{ Name = "result", Type = "CraftingOrderResult", Nilable = false },
				{ Name = "orderID", Type = "BigUInteger", Nilable = false },
			},
		},
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
			Name = "CraftingordersDisplayCrafterFulfilledMsg",
			Type = "Event",
			LiteralName = "CRAFTINGORDERS_DISPLAY_CRAFTER_FULFILLED_MSG",
			Payload =
			{
				{ Name = "orderTypeString", Type = "cstring", Nilable = false },
				{ Name = "itemNameString", Type = "cstring", Nilable = false },
				{ Name = "playerNameString", Type = "cstring", Nilable = false },
				{ Name = "tipAmount", Type = "WOWMONEY", Nilable = false },
				{ Name = "quantityCrafted", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CraftingordersFulfillOrderResponse",
			Type = "Event",
			LiteralName = "CRAFTINGORDERS_FULFILL_ORDER_RESPONSE",
			Payload =
			{
				{ Name = "result", Type = "CraftingOrderResult", Nilable = false },
				{ Name = "orderID", Type = "BigUInteger", Nilable = false },
			},
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
			Name = "CraftingordersOrderCancelResponse",
			Type = "Event",
			LiteralName = "CRAFTINGORDERS_ORDER_CANCEL_RESPONSE",
			Payload =
			{
				{ Name = "result", Type = "CraftingOrderResult", Nilable = false },
			},
		},
		{
			Name = "CraftingordersOrderPlacementResponse",
			Type = "Event",
			LiteralName = "CRAFTINGORDERS_ORDER_PLACEMENT_RESPONSE",
			Payload =
			{
				{ Name = "result", Type = "CraftingOrderResult", Nilable = false },
			},
		},
		{
			Name = "CraftingordersRejectOrderResponse",
			Type = "Event",
			LiteralName = "CRAFTINGORDERS_REJECT_ORDER_RESPONSE",
			Payload =
			{
				{ Name = "result", Type = "CraftingOrderResult", Nilable = false },
				{ Name = "orderID", Type = "BigUInteger", Nilable = false },
			},
		},
		{
			Name = "CraftingordersReleaseOrderResponse",
			Type = "Event",
			LiteralName = "CRAFTINGORDERS_RELEASE_ORDER_RESPONSE",
			Payload =
			{
				{ Name = "result", Type = "CraftingOrderResult", Nilable = false },
				{ Name = "orderID", Type = "BigUInteger", Nilable = false },
			},
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
		{
			Name = "CraftingordersUnexpectedError",
			Type = "Event",
			LiteralName = "CRAFTINGORDERS_UNEXPECTED_ERROR",
		},
		{
			Name = "CraftingordersUpdateCustomerName",
			Type = "Event",
			LiteralName = "CRAFTINGORDERS_UPDATE_CUSTOMER_NAME",
			Payload =
			{
				{ Name = "customerName", Type = "cstring", Nilable = false },
				{ Name = "orderID", Type = "BigUInteger", Nilable = false },
			},
		},
		{
			Name = "CraftingordersUpdateOrderCount",
			Type = "Event",
			LiteralName = "CRAFTINGORDERS_UPDATE_ORDER_COUNT",
			Payload =
			{
				{ Name = "orderType", Type = "CraftingOrderType", Nilable = false },
				{ Name = "numOrders", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CraftingordersUpdatePersonalOrderCounts",
			Type = "Event",
			LiteralName = "CRAFTINGORDERS_UPDATE_PERSONAL_ORDER_COUNTS",
		},
		{
			Name = "CraftingordersUpdateRewards",
			Type = "Event",
			LiteralName = "CRAFTINGORDERS_UPDATE_REWARDS",
			Payload =
			{
				{ Name = "npcOrderRewards", Type = "table", InnerType = "CraftingOrderRewardInfo", Nilable = false },
				{ Name = "orderID", Type = "BigUInteger", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "CraftingOrderRequestInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "orderType", Type = "CraftingOrderType", Nilable = false },
				{ Name = "selectedSkillLineAbility", Type = "number", Nilable = true },
				{ Name = "searchFavorites", Type = "bool", Nilable = false },
				{ Name = "initialNonPublicSearch", Type = "bool", Nilable = false },
				{ Name = "primarySort", Type = "CraftingOrderSortInfo", Nilable = false },
				{ Name = "secondarySort", Type = "CraftingOrderSortInfo", Nilable = false },
				{ Name = "forCrafter", Type = "bool", Nilable = false },
				{ Name = "offset", Type = "number", Nilable = false },
				{ Name = "callback", Type = "CraftingOrderRequestCallback", Nilable = false },
				{ Name = "profession", Type = "Profession", Nilable = true },
			},
		},
		{
			Name = "CraftingOrderRequestMyOrdersInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "primarySort", Type = "CraftingOrderSortInfo", Nilable = false },
				{ Name = "secondarySort", Type = "CraftingOrderSortInfo", Nilable = false },
				{ Name = "offset", Type = "number", Nilable = false },
				{ Name = "callback", Type = "CraftingOrderRequestMyOrdersCallback", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CraftingOrderUI);