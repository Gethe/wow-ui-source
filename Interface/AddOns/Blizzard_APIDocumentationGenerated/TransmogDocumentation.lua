local Transmog =
{
	Name = "Transmogrify",
	Type = "System",
	Namespace = "C_Transmog",
	Environment = "All",

	Functions =
	{
		{
			Name = "CanHaveSecondaryAppearanceForSlotID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "ExtractTransmogIDList",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "GetItemIDForSource",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "GetSlotForInventoryType",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "GetSlotVisualInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "transmogLocation", Type = "TransmogLocation", Mixin = "TransmogLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "slotVisualInfo", Type = "TransmogSlotVisualInfo", Nilable = false },
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
	},

	Events =
	{
		{
			Name = "TransmogCollectionCameraUpdate",
			Type = "Event",
			LiteralName = "TRANSMOG_COLLECTION_CAMERA_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "TransmogCollectionItemFavoriteUpdate",
			Type = "Event",
			LiteralName = "TRANSMOG_COLLECTION_ITEM_FAVORITE_UPDATE",
			SynchronousEvent = true,
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
			UniqueEvent = true,
		},
		{
			Name = "TransmogCollectionSourceAdded",
			Type = "Event",
			LiteralName = "TRANSMOG_COLLECTION_SOURCE_ADDED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TransmogCollectionSourceRemoved",
			Type = "Event",
			LiteralName = "TRANSMOG_COLLECTION_SOURCE_REMOVED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TransmogCollectionUpdated",
			Type = "Event",
			LiteralName = "TRANSMOG_COLLECTION_UPDATED",
			SynchronousEvent = true,
			UniqueEvent = true,
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
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "itemModifiedAppearanceID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TransmogSearchUpdated",
			Type = "Event",
			LiteralName = "TRANSMOG_SEARCH_UPDATED",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
		},
		{
			Name = "TransmogSourceCollectabilityUpdate",
			Type = "Event",
			LiteralName = "TRANSMOG_SOURCE_COLLECTABILITY_UPDATE",
			SynchronousEvent = true,
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
			SynchronousEvent = true,
		},
		{
			Name = "TransmogrifyItemUpdate",
			Type = "Event",
			LiteralName = "TRANSMOGRIFY_ITEM_UPDATE",
			UniqueEvent = true,
		},
		{
			Name = "TransmogrifyOpen",
			Type = "Event",
			LiteralName = "TRANSMOGRIFY_OPEN",
			SynchronousEvent = true,
		},
		{
			Name = "TransmogrifySuccess",
			Type = "Event",
			LiteralName = "TRANSMOGRIFY_SUCCESS",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "transmogLocation", Type = "TransmogLocation", Mixin = "TransmogLocationMixin", Nilable = false },
			},
		},
		{
			Name = "TransmogrifyUpdate",
			Type = "Event",
			LiteralName = "TRANSMOGRIFY_UPDATE",
			SynchronousEvent = true,
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