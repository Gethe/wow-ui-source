local Transmog =
{
	Name = "Transmogrify",
	Type = "System",
	Namespace = "C_Transmog",

	Functions =
	{
		{
			Name = "ClearAllPending",
			Type = "Function",
		},
		{
			Name = "ClearPending",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogLocation", Type = "table", Mixin = "TransmogLocationMixin", Nilable = false },
			},
		},
		{
			Name = "GetBaseCategory",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "categoryID", Type = "number", Nilable = false },
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
			Name = "GetSlotForInventoryType",
			Type = "Function",

			Arguments =
			{
				{ Name = "inventoryType", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "slot", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetSlotInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogLocation", Type = "table", Mixin = "TransmogLocationMixin", Nilable = false },
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
				{ Name = "texture", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetSlotUseError",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogLocation", Type = "table", Mixin = "TransmogLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "errorCode", Type = "number", Nilable = false },
				{ Name = "errorString", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetSlotVisualInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogLocation", Type = "table", Mixin = "TransmogLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "baseSourceID", Type = "number", Nilable = false },
				{ Name = "baseVisualID", Type = "number", Nilable = false },
				{ Name = "appliedSourceID", Type = "number", Nilable = false },
				{ Name = "appliedVisualID", Type = "number", Nilable = false },
				{ Name = "appliedCategoryID", Type = "number", Nilable = false },
				{ Name = "pendingSourceID", Type = "number", Nilable = false },
				{ Name = "pendingVisualID", Type = "number", Nilable = false },
				{ Name = "pendingCategoryID", Type = "number", Nilable = false },
				{ Name = "hasUndo", Type = "bool", Nilable = false },
				{ Name = "isHideVisual", Type = "bool", Nilable = false },
				{ Name = "itemSubclass", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetPending",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogLocation", Type = "table", Mixin = "TransmogLocationMixin", Nilable = false },
				{ Name = "transmogID", Type = "number", Nilable = false },
				{ Name = "categoryID", Type = "number", Nilable = true },
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
				{ Name = "collectionIndex", Type = "number", Nilable = true },
				{ Name = "modID", Type = "number", Nilable = true },
				{ Name = "itemAppearanceID", Type = "number", Nilable = true },
				{ Name = "reason", Type = "string", Nilable = true },
			},
		},
		{
			Name = "TransmogSearchUpdated",
			Type = "Event",
			LiteralName = "TRANSMOG_SEARCH_UPDATED",
			Payload =
			{
				{ Name = "searchType", Type = "number", Nilable = false },
				{ Name = "collectionType", Type = "number", Nilable = true },
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
				{ Name = "transmogLocation", Type = "table", Mixin = "TransmogLocationMixin", Nilable = false },
			},
		},
		{
			Name = "TransmogrifyUpdate",
			Type = "Event",
			LiteralName = "TRANSMOGRIFY_UPDATE",
			Payload =
			{
				{ Name = "transmogLocation", Type = "table", Mixin = "TransmogLocationMixin", Nilable = true },
				{ Name = "action", Type = "string", Nilable = true },
			},
		},
	},

	Tables =
	{
		{
			Name = "TransmogCollectionType",
			Type = "Enumeration",
			NumValues = 29,
			MinValue = 0,
			MaxValue = 28,
			Fields =
			{
				{ Name = "Head", Type = "TransmogCollectionType", EnumValue = 0 },
				{ Name = "Shoulder", Type = "TransmogCollectionType", EnumValue = 1 },
				{ Name = "Back", Type = "TransmogCollectionType", EnumValue = 2 },
				{ Name = "Chest", Type = "TransmogCollectionType", EnumValue = 3 },
				{ Name = "Shirt", Type = "TransmogCollectionType", EnumValue = 4 },
				{ Name = "Tabard", Type = "TransmogCollectionType", EnumValue = 5 },
				{ Name = "Wrist", Type = "TransmogCollectionType", EnumValue = 6 },
				{ Name = "Hands", Type = "TransmogCollectionType", EnumValue = 7 },
				{ Name = "Waist", Type = "TransmogCollectionType", EnumValue = 8 },
				{ Name = "Legs", Type = "TransmogCollectionType", EnumValue = 9 },
				{ Name = "Feet", Type = "TransmogCollectionType", EnumValue = 10 },
				{ Name = "Wand", Type = "TransmogCollectionType", EnumValue = 11 },
				{ Name = "OneHAxe", Type = "TransmogCollectionType", EnumValue = 12 },
				{ Name = "OneHSword", Type = "TransmogCollectionType", EnumValue = 13 },
				{ Name = "OneHMace", Type = "TransmogCollectionType", EnumValue = 14 },
				{ Name = "Dagger", Type = "TransmogCollectionType", EnumValue = 15 },
				{ Name = "Fist", Type = "TransmogCollectionType", EnumValue = 16 },
				{ Name = "Shield", Type = "TransmogCollectionType", EnumValue = 17 },
				{ Name = "Holdable", Type = "TransmogCollectionType", EnumValue = 18 },
				{ Name = "TwoHAxe", Type = "TransmogCollectionType", EnumValue = 19 },
				{ Name = "TwoHSword", Type = "TransmogCollectionType", EnumValue = 20 },
				{ Name = "TwoHMace", Type = "TransmogCollectionType", EnumValue = 21 },
				{ Name = "Staff", Type = "TransmogCollectionType", EnumValue = 22 },
				{ Name = "Polearm", Type = "TransmogCollectionType", EnumValue = 23 },
				{ Name = "Bow", Type = "TransmogCollectionType", EnumValue = 24 },
				{ Name = "Gun", Type = "TransmogCollectionType", EnumValue = 25 },
				{ Name = "Crossbow", Type = "TransmogCollectionType", EnumValue = 26 },
				{ Name = "Warglaives", Type = "TransmogCollectionType", EnumValue = 27 },
				{ Name = "Paired", Type = "TransmogCollectionType", EnumValue = 28 },
			},
		},
		{
			Name = "TransmogModification",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "None", Type = "TransmogModification", EnumValue = 0 },
				{ Name = "RightShoulder", Type = "TransmogModification", EnumValue = 1 },
			},
		},
		{
			Name = "TransmogSource",
			Type = "Enumeration",
			NumValues = 10,
			MinValue = 0,
			MaxValue = 9,
			Fields =
			{
				{ Name = "None", Type = "TransmogSource", EnumValue = 0 },
				{ Name = "JournalEncounter", Type = "TransmogSource", EnumValue = 1 },
				{ Name = "Quest", Type = "TransmogSource", EnumValue = 2 },
				{ Name = "Vendor", Type = "TransmogSource", EnumValue = 3 },
				{ Name = "WorldDrop", Type = "TransmogSource", EnumValue = 4 },
				{ Name = "HiddenUntilCollected", Type = "TransmogSource", EnumValue = 5 },
				{ Name = "CantCollect", Type = "TransmogSource", EnumValue = 6 },
				{ Name = "Achievement", Type = "TransmogSource", EnumValue = 7 },
				{ Name = "Profession", Type = "TransmogSource", EnumValue = 8 },
				{ Name = "NotValidForTransmog", Type = "TransmogSource", EnumValue = 9 },
			},
		},
		{
			Name = "TransmogType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Appearance", Type = "TransmogType", EnumValue = 0 },
				{ Name = "Illusion", Type = "TransmogType", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Transmog);