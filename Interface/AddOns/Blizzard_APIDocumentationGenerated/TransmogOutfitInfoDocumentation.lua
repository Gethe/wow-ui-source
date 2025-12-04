local TransmogOutfitInfo =
{
	Name = "TransmogOutfitInfo",
	Type = "System",
	Namespace = "C_TransmogOutfitInfo",

	Functions =
	{
		{
			Name = "AddNewOutfit",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
			},
		},
		{
			Name = "ChangeDisplayedOutfit",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "outfitID", Type = "number", Nilable = false },
				{ Name = "trigger", Type = "TransmogSituationTrigger", Nilable = false },
				{ Name = "toggleLock", Type = "bool", Nilable = false },
				{ Name = "allowRemoveOutfit", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ChangeViewedOutfit",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "outfitID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ClearAllPendingSituations",
			Type = "Function",
		},
		{
			Name = "ClearAllPendingTransmogs",
			Type = "Function",
		},
		{
			Name = "ClearDisplayedOutfit",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "trigger", Type = "TransmogSituationTrigger", Nilable = false },
				{ Name = "toggleLock", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CommitAndApplyAllPending",
			Type = "Function",
		},
		{
			Name = "CommitOutfitInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "outfitID", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
			},
		},
		{
			Name = "CommitPendingSituations",
			Type = "Function",
		},
		{
			Name = "GetActiveOutfitID",
			Type = "Function",

			Returns =
			{
				{ Name = "outfitID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetAllSlotLocationInfo",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "appearanceSlotInfo", Type = "table", InnerType = "TransmogOutfitSlotInfo", Nilable = false },
				{ Name = "illusionSlotInfo", Type = "table", InnerType = "TransmogOutfitSlotInfo", Nilable = false },
			},
		},
		{
			Name = "GetCollectionInfoForSlotAndOption",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slot", Type = "TransmogOutfitSlot", Nilable = false },
				{ Name = "weaponOption", Type = "TransmogOutfitSlotOption", Nilable = false },
				{ Name = "collectionType", Type = "TransmogCollectionType", Nilable = false },
			},

			Returns =
			{
				{ Name = "collectionInfo", Type = "TransmogOutfitWeaponCollectionInfo", Nilable = false },
			},
		},
		{
			Name = "GetCurrentlyViewedOutfitID",
			Type = "Function",

			Returns =
			{
				{ Name = "outfitID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetEquippedSlotOptionFromTransmogSlot",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slot", Type = "TransmogOutfitSlot", Nilable = false },
			},

			Returns =
			{
				{ Name = "weaponOption", Type = "TransmogOutfitSlotOption", Nilable = false },
			},
		},
		{
			Name = "GetIllusionDefaultIMAIDForCollectionType",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "collectionType", Type = "TransmogCollectionType", Nilable = false },
			},

			Returns =
			{
				{ Name = "imaID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetLinkedSlotInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slot", Type = "TransmogOutfitSlot", Nilable = false },
			},

			Returns =
			{
				{ Name = "linkedSlotInfo", Type = "TransmogOutfitLinkedSlotInfo", Nilable = false },
			},
		},
		{
			Name = "GetMaxNumberOfTotalOutfitsForSource",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "source", Type = "TransmogOutfitEntrySource", Nilable = false },
			},

			Returns =
			{
				{ Name = "maxOutfitCount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMaxNumberOfUsableOutfits",
			Type = "Function",

			Returns =
			{
				{ Name = "maxOutfitCount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNextOutfitCost",
			Type = "Function",

			Returns =
			{
				{ Name = "outfitCost", Type = "BigUInteger", Nilable = false },
			},
		},
		{
			Name = "GetNumberOfOutfitsUnlockedForSource",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "source", Type = "TransmogOutfitEntrySource", Nilable = false },
			},

			Returns =
			{
				{ Name = "unlockedOutfitCount", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetOutfitInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "outfitID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "outfitsInfo", Type = "TransmogOutfitEntryInfo", Nilable = false },
			},
		},
		{
			Name = "GetOutfitSituation",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "option", Type = "TransmogSituationOption", Nilable = false },
			},

			Returns =
			{
				{ Name = "value", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetOutfitSituationsEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetOutfitsInfo",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "outfitsInfo", Type = "table", InnerType = "TransmogOutfitEntryInfo", Nilable = false },
			},
		},
		{
			Name = "GetPendingTransmogCost",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "cost", Type = "BigUInteger", Nilable = false },
			},
		},
		{
			Name = "GetSecondarySlotState",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slot", Type = "TransmogOutfitSlot", Nilable = false },
			},

			Returns =
			{
				{ Name = "state", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetSetSourcesForSlot",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "transmogSetID", Type = "number", Nilable = false },
				{ Name = "slot", Type = "TransmogOutfitSlot", Nilable = false },
			},

			Returns =
			{
				{ Name = "sources", Type = "table", InnerType = "AppearanceSourceInfo", Nilable = false },
			},
		},
		{
			Name = "GetSlotGroupInfo",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "slotGroups", Type = "table", InnerType = "TransmogOutfitSlotGroup", Nilable = false },
			},
		},
		{
			Name = "GetSourceIDsForSlot",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "transmogSetID", Type = "number", Nilable = false },
				{ Name = "slot", Type = "TransmogOutfitSlot", Nilable = false },
			},

			Returns =
			{
				{ Name = "sources", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetTransmogOutfitSlotForInventoryType",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "inventoryType", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "slot", Type = "TransmogOutfitSlot", Nilable = false },
			},
		},
		{
			Name = "GetTransmogOutfitSlotFromInventorySlot",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "inventorySlot", Type = "InventorySlots", Nilable = false },
			},

			Returns =
			{
				{ Name = "slot", Type = "TransmogOutfitSlot", Nilable = false },
			},
		},
		{
			Name = "GetUISituationCategoriesAndOptions",
			Type = "Function",
			MayReturnNothing = true,

			Returns =
			{
				{ Name = "categoryData", Type = "table", InnerType = "TransmogSituationCategory", Nilable = false },
			},
		},
		{
			Name = "GetUnassignedAtlasForSlot",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slot", Type = "TransmogOutfitSlot", Nilable = false },
			},

			Returns =
			{
				{ Name = "atlas", Type = "textureAtlas", Nilable = false },
			},
		},
		{
			Name = "GetUnassignedDisplayAtlasForSlot",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slot", Type = "TransmogOutfitSlot", Nilable = false },
			},

			Returns =
			{
				{ Name = "atlas", Type = "textureAtlas", Nilable = false },
			},
		},
		{
			Name = "GetViewedOutfitSlotInfo",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slot", Type = "TransmogOutfitSlot", Nilable = false },
				{ Name = "type", Type = "TransmogType", Nilable = false },
				{ Name = "option", Type = "TransmogOutfitSlotOption", Nilable = false },
			},

			Returns =
			{
				{ Name = "slotInfo", Type = "ViewedTransmogOutfitSlotInfo", Nilable = false },
			},
		},
		{
			Name = "GetWeaponOptionsForSlot",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slot", Type = "TransmogOutfitSlot", Nilable = false },
			},

			Returns =
			{
				{ Name = "weaponOptions", Type = "table", InnerType = "TransmogOutfitWeaponOptionInfo", Nilable = false },
				{ Name = "artifactOptions", Type = "table", InnerType = "TransmogOutfitWeaponOptionInfo", Nilable = true },
			},
		},
		{
			Name = "HasPendingOutfitSituations",
			Type = "Function",

			Returns =
			{
				{ Name = "hasPending", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "HasPendingOutfitTransmogs",
			Type = "Function",

			Returns =
			{
				{ Name = "hasPending", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEquippedGearOutfitDisplayed",
			Type = "Function",

			Returns =
			{
				{ Name = "isDisplayed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEquippedGearOutfitLocked",
			Type = "Function",

			Returns =
			{
				{ Name = "isLocked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsLockedOutfit",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "outfitID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isLocked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsValidTransmogOutfitName",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "isApproved", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PickupOutfit",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "outfitID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ResetOutfitSituations",
			Type = "Function",
		},
		{
			Name = "RevertPendingTransmog",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slot", Type = "TransmogOutfitSlot", Nilable = false },
				{ Name = "type", Type = "TransmogType", Nilable = false },
				{ Name = "option", Type = "TransmogOutfitSlotOption", Nilable = false },
			},
		},
		{
			Name = "SetOutfitSituationsEnabled",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetOutfitToCustomSet",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "transmogCustomSetID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetOutfitToSet",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "transmogSetID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetPendingTransmog",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slot", Type = "TransmogOutfitSlot", Nilable = false },
				{ Name = "type", Type = "TransmogType", Nilable = false },
				{ Name = "option", Type = "TransmogOutfitSlotOption", Nilable = false },
				{ Name = "transmogID", Type = "number", Nilable = false },
				{ Name = "displayType", Type = "TransmogOutfitDisplayType", Nilable = false },
			},
		},
		{
			Name = "SetSecondarySlotState",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slot", Type = "TransmogOutfitSlot", Nilable = false },
				{ Name = "state", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetViewedWeaponOptionForSlot",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slot", Type = "TransmogOutfitSlot", Nilable = false },
				{ Name = "weaponOption", Type = "TransmogOutfitSlotOption", Nilable = false },
			},
		},
		{
			Name = "SlotHasSecondary",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "slot", Type = "TransmogOutfitSlot", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasSecondary", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "UpdatePendingSituation",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "option", Type = "TransmogSituationOption", Nilable = false },
				{ Name = "value", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "TransmogDisplayedOutfitChanged",
			Type = "Event",
			LiteralName = "TRANSMOG_DISPLAYED_OUTFIT_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "TransmogOutfitsChanged",
			Type = "Event",
			LiteralName = "TRANSMOG_OUTFITS_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "newOutfitID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "ViewedTransmogOutfitChanged",
			Type = "Event",
			LiteralName = "VIEWED_TRANSMOG_OUTFIT_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "ViewedTransmogOutfitSecondarySlotsChanged",
			Type = "Event",
			LiteralName = "VIEWED_TRANSMOG_OUTFIT_SECONDARY_SLOTS_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "ViewedTransmogOutfitSituationsChanged",
			Type = "Event",
			LiteralName = "VIEWED_TRANSMOG_OUTFIT_SITUATIONS_CHANGED",
			SynchronousEvent = true,
		},
		{
			Name = "ViewedTransmogOutfitSlotRefresh",
			Type = "Event",
			LiteralName = "VIEWED_TRANSMOG_OUTFIT_SLOT_REFRESH",
			UniqueEvent = true,
		},
		{
			Name = "ViewedTransmogOutfitSlotSaveSuccess",
			Type = "Event",
			LiteralName = "VIEWED_TRANSMOG_OUTFIT_SLOT_SAVE_SUCCESS",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "slot", Type = "TransmogOutfitSlot", Nilable = false },
				{ Name = "type", Type = "TransmogType", Nilable = false },
				{ Name = "option", Type = "TransmogOutfitSlotOption", Nilable = false },
			},
		},
		{
			Name = "ViewedTransmogOutfitSlotWeaponOptionChanged",
			Type = "Event",
			LiteralName = "VIEWED_TRANSMOG_OUTFIT_SLOT_WEAPON_OPTION_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "slot", Type = "TransmogOutfitSlot", Nilable = false },
				{ Name = "weaponOption", Type = "TransmogOutfitSlotOption", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "TransmogOutfitEntryInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "outfitID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "situationCategories", Type = "table", InnerType = "cstring", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
			},
		},
		{
			Name = "TransmogOutfitLinkedSlotInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "primarySlotInfo", Type = "TransmogOutfitSlotInfo", Nilable = false },
				{ Name = "secondarySlotInfo", Type = "TransmogOutfitSlotInfo", Nilable = false },
			},
		},
		{
			Name = "TransmogOutfitSlotGroup",
			Type = "Structure",
			Fields =
			{
				{ Name = "position", Type = "TransmogOutfitSlotPosition", Nilable = false },
				{ Name = "appearanceSlotInfo", Type = "table", InnerType = "TransmogOutfitSlotInfo", Nilable = false },
				{ Name = "illusionSlotInfo", Type = "table", InnerType = "TransmogOutfitSlotInfo", Nilable = false },
			},
		},
		{
			Name = "TransmogOutfitSlotInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "slot", Type = "TransmogOutfitSlot", Nilable = false },
				{ Name = "type", Type = "TransmogType", Nilable = false },
				{ Name = "collectionType", Type = "TransmogCollectionType", Nilable = false },
				{ Name = "slotName", Type = "cstring", Nilable = false },
				{ Name = "isSecondary", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TransmogOutfitWeaponCollectionInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "isWeapon", Type = "bool", Nilable = false },
				{ Name = "canHaveIllusions", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TransmogOutfitWeaponOptionInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "weaponOption", Type = "TransmogOutfitSlotOption", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TransmogSituationCategory",
			Type = "Structure",
			Fields =
			{
				{ Name = "triggerID", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "description", Type = "cstring", Nilable = false },
				{ Name = "isRadioButton", Type = "bool", Nilable = false },
				{ Name = "groupData", Type = "table", InnerType = "TransmogSituationGroup", Nilable = false },
			},
		},
		{
			Name = "TransmogSituationGroup",
			Type = "Structure",
			Fields =
			{
				{ Name = "groupID", Type = "number", Nilable = false },
				{ Name = "secondaryID", Type = "number", Nilable = false },
				{ Name = "optionData", Type = "table", InnerType = "TransmogSituationOptionData", Nilable = false },
			},
		},
		{
			Name = "TransmogSituationOption",
			Type = "Structure",
			Fields =
			{
				{ Name = "situationID", Type = "number", Nilable = false },
				{ Name = "specID", Type = "number", Nilable = false },
				{ Name = "loadoutID", Type = "number", Nilable = false },
				{ Name = "equipmentSetID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "TransmogSituationOptionData",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "value", Type = "bool", Nilable = false },
				{ Name = "option", Type = "TransmogSituationOption", Nilable = false },
			},
		},
		{
			Name = "ViewedTransmogOutfitSlotInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "transmogID", Type = "number", Nilable = false },
				{ Name = "displayType", Type = "TransmogOutfitDisplayType", Nilable = false },
				{ Name = "isTransmogrified", Type = "bool", Nilable = false },
				{ Name = "hasPending", Type = "bool", Nilable = false },
				{ Name = "isPendingCollected", Type = "bool", Nilable = false },
				{ Name = "canTransmogrify", Type = "bool", Nilable = false },
				{ Name = "warning", Type = "TransmogOutfitSlotWarning", Nilable = false },
				{ Name = "warningText", Type = "cstring", Nilable = false },
				{ Name = "error", Type = "TransmogOutfitSlotError", Nilable = false },
				{ Name = "errorText", Type = "cstring", Nilable = false },
				{ Name = "texture", Type = "fileID", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(TransmogOutfitInfo);