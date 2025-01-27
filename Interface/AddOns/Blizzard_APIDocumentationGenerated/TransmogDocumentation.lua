local Transmog =
{
	Name = "Transmogrify",
	Type = "System",
	Namespace = "C_Transmog",

	Functions =
	{
		{
			Name = "ApplyAllPending",
			Type = "Function",

			Arguments =
			{
				{ Name = "currentSpecOnly", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "requestSent", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanHaveSecondaryAppearanceForSlotID",
			Type = "Function",

			Arguments =
			{
				{ Name = "slotID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "canHaveSecondaryAppearance", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanTransmogItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "canBeTransmogged", Type = "bool", Nilable = false },
				{ Name = "selfFailureReason", Type = "cstring", Nilable = true },
				{ Name = "canTransmogOthers", Type = "bool", Nilable = false },
				{ Name = "othersFailureReason", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "CanTransmogItemWithItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "targetItemInfo", Type = "ItemInfo", Nilable = false },
				{ Name = "sourceItemInfo", Type = "ItemInfo", Nilable = false },
			},

			Returns =
			{
				{ Name = "canTransmog", Type = "bool", Nilable = false },
				{ Name = "failureReason", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "ClearAllPending",
			Type = "Function",
		},
		{
			Name = "ClearPending",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogLocation", Type = "TransmogLocation", Mixin = "TransmogLocationMixin", Nilable = false },
			},
		},
		{
			Name = "Close",
			Type = "Function",
		},
		{
			Name = "ExtractTransmogIDList",
			Type = "Function",

			Arguments =
			{
				{ Name = "input", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "transmogIDList", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetAllSetAppearancesByID",
			Type = "Function",

			Arguments =
			{
				{ Name = "setID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "setItems", Type = "table", InnerType = "TransmogSetItemInfo", Nilable = true },
			},
		},
		{
			Name = "GetApplyCost",
			Type = "Function",

			Returns =
			{
				{ Name = "cost", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetApplyWarnings",
			Type = "Function",

			Returns =
			{
				{ Name = "warnings", Type = "table", InnerType = "TransmogApplyWarningInfo", Nilable = false },
			},
		},
		{
			Name = "GetBaseCategory",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "transmogID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "categoryID", Type = "TransmogCollectionType", Nilable = false },
			},
		},
		{
			Name = "GetCreatureDisplayIDForSource",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "creatureDisplayID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetItemIDForSource",
			Type = "Function",

			Arguments =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetPending",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "transmogLocation", Type = "TransmogLocation", Mixin = "TransmogLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "pendingInfo", Type = "TransmogPendingInfo", Mixin = "TransmogPendingInfoMixin", Nilable = false },
			},
		},
		{
			Name = "GetSlotEffectiveCategory",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogLocation", Type = "TransmogLocation", Mixin = "TransmogLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "categoryID", Type = "TransmogCollectionType", Nilable = false },
			},
		},
		{
			Name = "GetSlotForInventoryType",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "inventoryType", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "slot", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "GetSlotInfo",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "transmogLocation", Type = "TransmogLocation", Mixin = "TransmogLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isTransmogrified", Type = "bool", Nilable = false },
				{ Name = "hasPending", Type = "bool", Nilable = false },
				{ Name = "isPendingCollected", Type = "bool", Nilable = false },
				{ Name = "canTransmogrify", Type = "bool", Nilable = false },
				{ Name = "cannotTransmogrifyReason", Type = "number", Nilable = false },
				{ Name = "hasUndo", Type = "bool", Nilable = false },
				{ Name = "isHideVisual", Type = "bool", Nilable = false },
				{ Name = "texture", Type = "fileID", Nilable = true },
			},
		},
		{
			Name = "GetSlotUseError",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "transmogLocation", Type = "TransmogLocation", Mixin = "TransmogLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "errorCode", Type = "number", Nilable = false },
				{ Name = "errorString", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetSlotVisualInfo",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "transmogLocation", Type = "TransmogLocation", Mixin = "TransmogLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "baseSourceID", Type = "number", Nilable = false },
				{ Name = "baseVisualID", Type = "number", Nilable = false },
				{ Name = "appliedSourceID", Type = "number", Nilable = false },
				{ Name = "appliedVisualID", Type = "number", Nilable = false },
				{ Name = "pendingSourceID", Type = "number", Nilable = false },
				{ Name = "pendingVisualID", Type = "number", Nilable = false },
				{ Name = "hasUndo", Type = "bool", Nilable = false },
				{ Name = "isHideVisual", Type = "bool", Nilable = false },
				{ Name = "itemSubclass", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsAtTransmogNPC",
			Type = "Function",

			Returns =
			{
				{ Name = "isAtNPC", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSlotBeingCollapsed",
			Type = "Function",
			Documentation = { "Returns true if the only pending for the location's slot is a ToggleOff for the secondary appearance." },

			Arguments =
			{
				{ Name = "transmogLocation", Type = "TransmogLocation", Mixin = "TransmogLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "isBeingCollapsed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LoadOutfit",
			Type = "Function",

			Arguments =
			{
				{ Name = "outfitID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetPending",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogLocation", Type = "TransmogLocation", Mixin = "TransmogLocationMixin", Nilable = false },
				{ Name = "pendingInfo", Type = "TransmogPendingInfo", Mixin = "TransmogPendingInfoMixin", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "TransmogCollectionCameraUpdate",
			Type = "Event",
			LiteralName = "TRANSMOG_COLLECTION_CAMERA_UPDATE",
		},
		{
			Name = "TransmogCollectionItemFavoriteUpdate",
			Type = "Event",
			LiteralName = "TRANSMOG_COLLECTION_ITEM_FAVORITE_UPDATE",
			Payload =
			{
				{ Name = "itemAppearanceID", Type = "number", Nilable = false },
				{ Name = "isFavorite", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TransmogCollectionItemUpdate",
			Type = "Event",
			LiteralName = "TRANSMOG_COLLECTION_ITEM_UPDATE",
		},
		{
			Name = "TransmogCollectionSourceAdded",
			Type = "Event",
			LiteralName = "TRANSMOG_COLLECTION_SOURCE_ADDED",
			Payload =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TransmogCollectionSourceRemoved",
			Type = "Event",
			LiteralName = "TRANSMOG_COLLECTION_SOURCE_REMOVED",
			Payload =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TransmogCollectionUpdated",
			Type = "Event",
			LiteralName = "TRANSMOG_COLLECTION_UPDATED",
			Payload =
			{
				{ Name = "collectionIndex", Type = "luaIndex", Nilable = true },
				{ Name = "modID", Type = "number", Nilable = true },
				{ Name = "itemAppearanceID", Type = "number", Nilable = true },
				{ Name = "reason", Type = "cstring", Nilable = true },
			},
		},
		{
			Name = "TransmogCosmeticCollectionSourceAdded",
			Type = "Event",
			LiteralName = "TRANSMOG_COSMETIC_COLLECTION_SOURCE_ADDED",
			Payload =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TransmogSearchUpdated",
			Type = "Event",
			LiteralName = "TRANSMOG_SEARCH_UPDATED",
			Payload =
			{
				{ Name = "searchType", Type = "TransmogSearchType", Nilable = false },
				{ Name = "collectionType", Type = "TransmogCollectionType", Nilable = true },
			},
		},
		{
			Name = "TransmogSetsUpdateFavorite",
			Type = "Event",
			LiteralName = "TRANSMOG_SETS_UPDATE_FAVORITE",
		},
		{
			Name = "TransmogSourceCollectabilityUpdate",
			Type = "Event",
			LiteralName = "TRANSMOG_SOURCE_COLLECTABILITY_UPDATE",
			Payload =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
				{ Name = "collectable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TransmogrifyClose",
			Type = "Event",
			LiteralName = "TRANSMOGRIFY_CLOSE",
		},
		{
			Name = "TransmogrifyItemUpdate",
			Type = "Event",
			LiteralName = "TRANSMOGRIFY_ITEM_UPDATE",
		},
		{
			Name = "TransmogrifyOpen",
			Type = "Event",
			LiteralName = "TRANSMOGRIFY_OPEN",
		},
		{
			Name = "TransmogrifySuccess",
			Type = "Event",
			LiteralName = "TRANSMOGRIFY_SUCCESS",
			Payload =
			{
				{ Name = "transmogLocation", Type = "TransmogLocation", Mixin = "TransmogLocationMixin", Nilable = false },
			},
		},
		{
			Name = "TransmogrifyUpdate",
			Type = "Event",
			LiteralName = "TRANSMOGRIFY_UPDATE",
			Payload =
			{
				{ Name = "transmogLocation", Type = "TransmogLocation", Mixin = "TransmogLocationMixin", Nilable = true },
				{ Name = "action", Type = "cstring", Nilable = true },
			},
		},
	},

	Tables =
	{
		{
			Name = "TransmogPendingType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Apply", Type = "TransmogPendingType", EnumValue = 0 },
				{ Name = "Revert", Type = "TransmogPendingType", EnumValue = 1 },
				{ Name = "ToggleOn", Type = "TransmogPendingType", EnumValue = 2 },
				{ Name = "ToggleOff", Type = "TransmogPendingType", EnumValue = 3 },
			},
		},
		{
			Name = "TransmogApplyWarningInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemLink", Type = "string", Nilable = false },
				{ Name = "text", Type = "string", Nilable = false },
			},
		},
		{
			Name = "TransmogSetItemInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
				{ Name = "invSlot", Type = "number", Nilable = false },
				{ Name = "invType", Type = "string", Nilable = false },
			},
		},
		{
			Name = "TransmogSlotInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "isTransmogrified", Type = "bool", Nilable = false },
				{ Name = "hasPending", Type = "bool", Nilable = false },
				{ Name = "isPendingCollected", Type = "bool", Nilable = false },
				{ Name = "canTransmogrify", Type = "bool", Nilable = false },
				{ Name = "cannotTransmogrifyReason", Type = "number", Nilable = false },
				{ Name = "hasUndo", Type = "bool", Nilable = false },
				{ Name = "isHideVisual", Type = "bool", Nilable = false },
				{ Name = "texture", Type = "fileID", Nilable = true },
			},
		},
		{
			Name = "TransmogSlotVisualInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "baseSourceID", Type = "number", Nilable = false },
				{ Name = "baseVisualID", Type = "number", Nilable = false },
				{ Name = "appliedSourceID", Type = "number", Nilable = false },
				{ Name = "appliedVisualID", Type = "number", Nilable = false },
				{ Name = "pendingSourceID", Type = "number", Nilable = false },
				{ Name = "pendingVisualID", Type = "number", Nilable = false },
				{ Name = "hasUndo", Type = "bool", Nilable = false },
				{ Name = "isHideVisual", Type = "bool", Nilable = false },
				{ Name = "itemSubclass", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Transmog);