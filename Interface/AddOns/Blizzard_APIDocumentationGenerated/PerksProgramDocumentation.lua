local PerksProgram =
{
	Name = "PerksProgram",
	Type = "System",
	Namespace = "C_PerksProgram",

	Functions =
	{
		{
			Name = "ClearFrozenPerksVendorItem",
			Type = "Function",
		},
		{
			Name = "CloseInteraction",
			Type = "Function",
		},
		{
			Name = "GetAvailableCategoryIDs",
			Type = "Function",

			Returns =
			{
				{ Name = "categoryIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetAvailableVendorItemIDs",
			Type = "Function",

			Returns =
			{
				{ Name = "vendorItemIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetCategoryInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "categoryID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "categoryInfo", Type = "PerksVendorCategoryInfo", Nilable = false },
			},
		},
		{
			Name = "GetCurrencyAmount",
			Type = "Function",

			Returns =
			{
				{ Name = "currencyAmount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetDraggedPerksVendorItem",
			Type = "Function",

			Returns =
			{
				{ Name = "perksVendorItemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetFrozenPerksVendorItemInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "vendorItemInfo", Type = "PerksVendorItemInfo", Nilable = false },
			},
		},
		{
			Name = "GetPendingChestRewards",
			Type = "Function",

			Returns =
			{
				{ Name = "pendingRewards", Type = "table", InnerType = "PerksProgramPendingChestRewards", Nilable = false },
			},
		},
		{
			Name = "GetPerksProgramItemDisplayInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "id", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "item", Type = "PerksProgramItemDisplayInfo", Nilable = false },
			},
		},
		{
			Name = "GetTimeRemaining",
			Type = "Function",

			Arguments =
			{
				{ Name = "vendorItemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "timeRemaining", Type = "time_t", Nilable = false },
			},
		},
		{
			Name = "GetVendorItemInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "vendorItemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "vendorItemInfo", Type = "PerksVendorItemInfo", Nilable = false },
			},
		},
		{
			Name = "GetVendorItemInfoRefundTimeLeft",
			Type = "Function",

			Arguments =
			{
				{ Name = "vendorItemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "refundTimeRemaining", Type = "time_t", Nilable = false },
			},
		},
		{
			Name = "IsAttackAnimToggleEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isAttackAnimToggleEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsFrozenPerksVendorItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "perksVendorItemID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isFrozen", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMountSpecialAnimToggleEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isMountSpecialAnimToggleEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ItemSelectedTelemetry",
			Type = "Function",

			Arguments =
			{
				{ Name = "perksVendorItemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PickupPerksVendorItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "perksVendorItemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RequestPendingChestRewards",
			Type = "Function",
		},
		{
			Name = "RequestPurchase",
			Type = "Function",

			Arguments =
			{
				{ Name = "perksVendorItemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RequestRefund",
			Type = "Function",

			Arguments =
			{
				{ Name = "perksVendorItemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ResetHeldItemDragAndDrop",
			Type = "Function",
		},
		{
			Name = "SetFrozenPerksVendorItem",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "ChestRewardsUpdatedFromServer",
			Type = "Event",
			LiteralName = "CHEST_REWARDS_UPDATED_FROM_SERVER",
		},
		{
			Name = "PerksProgramAddPendingShopItem",
			Type = "Event",
			LiteralName = "PERKS_PROGRAM_ADD_PENDING_SHOP_ITEM",
			Payload =
			{
				{ Name = "vendorItemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PerksProgramClose",
			Type = "Event",
			LiteralName = "PERKS_PROGRAM_CLOSE",
		},
		{
			Name = "PerksProgramCurrencyAwarded",
			Type = "Event",
			LiteralName = "PERKS_PROGRAM_CURRENCY_AWARDED",
			Payload =
			{
				{ Name = "value", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PerksProgramCurrencyRefresh",
			Type = "Event",
			LiteralName = "PERKS_PROGRAM_CURRENCY_REFRESH",
			Payload =
			{
				{ Name = "oldValue", Type = "number", Nilable = false },
				{ Name = "newValue", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PerksProgramDataRefresh",
			Type = "Event",
			LiteralName = "PERKS_PROGRAM_DATA_REFRESH",
		},
		{
			Name = "PerksProgramDataSpecificItemRefresh",
			Type = "Event",
			LiteralName = "PERKS_PROGRAM_DATA_SPECIFIC_ITEM_REFRESH",
			Payload =
			{
				{ Name = "vendorItemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PerksProgramDisabled",
			Type = "Event",
			LiteralName = "PERKS_PROGRAM_DISABLED",
		},
		{
			Name = "PerksProgramOpen",
			Type = "Event",
			LiteralName = "PERKS_PROGRAM_OPEN",
		},
		{
			Name = "PerksProgramPurchaseSuccess",
			Type = "Event",
			LiteralName = "PERKS_PROGRAM_PURCHASE_SUCCESS",
			Payload =
			{
				{ Name = "vendorItemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PerksProgramRefundSuccess",
			Type = "Event",
			LiteralName = "PERKS_PROGRAM_REFUND_SUCCESS",
			Payload =
			{
				{ Name = "vendorItemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PerksProgramRemovePendingShopItem",
			Type = "Event",
			LiteralName = "PERKS_PROGRAM_REMOVE_PENDING_SHOP_ITEM",
			Payload =
			{
				{ Name = "vendorItemID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PerksProgramResultError",
			Type = "Event",
			LiteralName = "PERKS_PROGRAM_RESULT_ERROR",
		},
		{
			Name = "PerksProgramSetFrozenItem",
			Type = "Event",
			LiteralName = "PERKS_PROGRAM_SET_FROZEN_ITEM",
			Payload =
			{
				{ Name = "vendorItemID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "ModelSceneActorData",
			Type = "Structure",
			Fields =
			{
				{ Name = "actorID", Type = "number", Nilable = true },
				{ Name = "scriptTag", Type = "string", Nilable = true },
				{ Name = "posX", Type = "number", Nilable = true },
				{ Name = "posY", Type = "number", Nilable = true },
				{ Name = "posZ", Type = "number", Nilable = true },
				{ Name = "yaw", Type = "number", Nilable = true },
				{ Name = "pitch", Type = "number", Nilable = true },
				{ Name = "roll", Type = "number", Nilable = true },
				{ Name = "normalizedScale", Type = "number", Nilable = true },
			},
		},
		{
			Name = "ModelSceneCameraData",
			Type = "Structure",
			Fields =
			{
				{ Name = "cameraID", Type = "number", Nilable = true },
				{ Name = "scriptTag", Type = "string", Nilable = true },
				{ Name = "targetX", Type = "number", Nilable = true },
				{ Name = "targetY", Type = "number", Nilable = true },
				{ Name = "targetZ", Type = "number", Nilable = true },
				{ Name = "yaw", Type = "number", Nilable = true },
				{ Name = "pitch", Type = "number", Nilable = true },
				{ Name = "roll", Type = "number", Nilable = true },
				{ Name = "defaultZoom", Type = "number", Nilable = true },
				{ Name = "zoomMin", Type = "number", Nilable = true },
				{ Name = "zoomMax", Type = "number", Nilable = true },
			},
		},
		{
			Name = "PerksProgramItemDisplayInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "overrideModelSceneID", Type = "number", Nilable = true },
				{ Name = "creatureDisplayInfoID", Type = "number", Nilable = true },
				{ Name = "mainHandItemModifiedAppearanceID", Type = "number", Nilable = true },
				{ Name = "offHandItemModifiedAppearanceID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "PerksProgramPendingChestRewards",
			Type = "Structure",
			Fields =
			{
				{ Name = "rewardTypeID", Type = "number", Nilable = false },
				{ Name = "perksVendorItemID", Type = "number", Nilable = true },
				{ Name = "rewardAmount", Type = "number", Nilable = false },
				{ Name = "monthRewarded", Type = "string", Nilable = true },
				{ Name = "activityMonthID", Type = "number", Nilable = false },
				{ Name = "thresholdOrderIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PerksVendorCategoryInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "displayName", Type = "cstring", Nilable = false },
				{ Name = "defaultUIModelSceneID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PerksVendorItemInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "perksVendorCategoryID", Type = "number", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "timeRemaining", Type = "time_t", Nilable = false },
				{ Name = "purchased", Type = "bool", Nilable = false },
				{ Name = "refundable", Type = "bool", Nilable = false },
				{ Name = "subItemsLoaded", Type = "bool", Nilable = false },
				{ Name = "isPurchasePending", Type = "bool", Nilable = false },
				{ Name = "doesNotExpire", Type = "bool", Nilable = false },
				{ Name = "price", Type = "number", Nilable = false },
				{ Name = "perksVendorItemID", Type = "number", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "iconTexture", Type = "string", Nilable = false },
				{ Name = "mountID", Type = "number", Nilable = false },
				{ Name = "mountTypeName", Type = "string", Nilable = false },
				{ Name = "speciesID", Type = "number", Nilable = false },
				{ Name = "transmogSetID", Type = "number", Nilable = false },
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
				{ Name = "subItems", Type = "table", InnerType = "PerksVendorSubItemInfo", Nilable = false },
				{ Name = "uiGroupInfo", Type = "PerksVendorItemUIGroupInfo", Nilable = true },
			},
		},
		{
			Name = "PerksVendorItemUIGroupInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "priority", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PerksVendorSubItemInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "itemAppearanceID", Type = "number", Nilable = false },
				{ Name = "invType", Type = "string", Nilable = false },
				{ Name = "quality", Type = "ItemQuality", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PerksProgram);