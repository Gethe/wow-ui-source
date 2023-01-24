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
				{ Name = "timeRemaining", Type = "number", Nilable = false },
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
				{ Name = "refundTimeRemaining", Type = "number", Nilable = false },
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
				{ Name = "activityThresholdID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PerksVendorCategoryInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "displayName", Type = "string", Nilable = false },
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
				{ Name = "timeRemaining", Type = "number", Nilable = false },
				{ Name = "purchased", Type = "bool", Nilable = false },
				{ Name = "refundable", Type = "bool", Nilable = false },
				{ Name = "price", Type = "number", Nilable = false },
				{ Name = "perksVendorItemID", Type = "number", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "iconTexture", Type = "string", Nilable = false },
				{ Name = "mountID", Type = "number", Nilable = false },
				{ Name = "speciesID", Type = "number", Nilable = false },
				{ Name = "transmogSetID", Type = "number", Nilable = false },
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PerksProgram);