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
				{ Name = "slotID", Type = "number", Nilable = false },
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
				{ Name = "itemInfo", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "canBeTransmogged", Type = "bool", Nilable = false },
				{ Name = "selfFailureReason", Type = "string", Nilable = true },
				{ Name = "canTransmogOthers", Type = "bool", Nilable = false },
				{ Name = "othersFailureReason", Type = "string", Nilable = true },
			},
		},
		{
			Name = "CanTransmogItemWithItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "targetItemInfo", Type = "string", Nilable = false },
				{ Name = "sourceItemInfo", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "canTransmog", Type = "bool", Nilable = false },
				{ Name = "failureReason", Type = "string", Nilable = true },
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
				{ Name = "transmogLocation", Type = "table", Mixin = "TransmogLocationMixin", Nilable = false },
			},
		},
		{
			Name = "Close",
			Type = "Function",
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

			Arguments =
			{
				{ Name = "transmogLocation", Type = "table", Mixin = "TransmogLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "pendingInfo", Type = "table", Mixin = "TransmogPendingInfoMixin", Nilable = false },
			},
		},
		{
			Name = "GetSlotEffectiveCategory",
			Type = "Function",

			Arguments =
			{
				{ Name = "transmogLocation", Type = "table", Mixin = "TransmogLocationMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "categoryID", Type = "TransmogCollectionType", Nilable = false },
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
				{ Name = "transmogLocation", Type = "table", Mixin = "TransmogLocationMixin", Nilable = false },
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
				{ Name = "transmogLocation", Type = "table", Mixin = "TransmogLocationMixin", Nilable = false },
				{ Name = "pendingInfo", Type = "table", Mixin = "TransmogPendingInfoMixin", Nilable = false },
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
			Name = "TransmogModification",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Main", Type = "TransmogModification", EnumValue = 0 },
				{ Name = "Secondary", Type = "TransmogModification", EnumValue = 1 },
			},
		},
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
		{
			Name = "TransmogApplyWarningInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemLink", Type = "string", Nilable = false },
				{ Name = "text", Type = "string", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Transmog);