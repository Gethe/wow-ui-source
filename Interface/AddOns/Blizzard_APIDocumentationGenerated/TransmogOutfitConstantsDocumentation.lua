local TransmogOutfitConstants =
{
	Tables =
	{
		{
			Name = "TransmogOutfitDisplayType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Unassigned", Type = "TransmogOutfitDisplayType", EnumValue = 0 },
				{ Name = "Assigned", Type = "TransmogOutfitDisplayType", EnumValue = 1 },
				{ Name = "Equipped", Type = "TransmogOutfitDisplayType", EnumValue = 2 },
				{ Name = "Hidden", Type = "TransmogOutfitDisplayType", EnumValue = 3 },
			},
		},
		{
			Name = "TransmogOutfitEntryFlags",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "AutomaticallyAwardedOnLogin", Type = "TransmogOutfitEntryFlags", EnumValue = 1 },
			},
		},
		{
			Name = "TransmogOutfitEntrySource",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "StampedSource", Type = "TransmogOutfitEntrySource", EnumValue = 0 },
				{ Name = "AutomaticallyAwarded", Type = "TransmogOutfitEntrySource", EnumValue = 1 },
				{ Name = "PlayerPurchased", Type = "TransmogOutfitEntrySource", EnumValue = 2 },
			},
		},
		{
			Name = "TransmogOutfitEquipAction",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "Equip", Type = "TransmogOutfitEquipAction", EnumValue = 0 },
				{ Name = "EquipAndLock", Type = "TransmogOutfitEquipAction", EnumValue = 1 },
				{ Name = "Remove", Type = "TransmogOutfitEquipAction", EnumValue = 2 },
				{ Name = "RemoveAndLock", Type = "TransmogOutfitEquipAction", EnumValue = 3 },
				{ Name = "Unlock", Type = "TransmogOutfitEquipAction", EnumValue = 4 },
				{ Name = "Lock", Type = "TransmogOutfitEquipAction", EnumValue = 5 },
			},
		},
		{
			Name = "TransmogOutfitSetType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Equipped", Type = "TransmogOutfitSetType", EnumValue = 0 },
				{ Name = "Outfit", Type = "TransmogOutfitSetType", EnumValue = 1 },
				{ Name = "CustomSet", Type = "TransmogOutfitSetType", EnumValue = 2 },
			},
		},
		{
			Name = "TransmogOutfitSlot",
			Type = "Enumeration",
			NumValues = 15,
			MinValue = 0,
			MaxValue = 14,
			Fields =
			{
				{ Name = "Head", Type = "TransmogOutfitSlot", EnumValue = 0 },
				{ Name = "ShoulderRight", Type = "TransmogOutfitSlot", EnumValue = 1 },
				{ Name = "ShoulderLeft", Type = "TransmogOutfitSlot", EnumValue = 2 },
				{ Name = "Back", Type = "TransmogOutfitSlot", EnumValue = 3 },
				{ Name = "Chest", Type = "TransmogOutfitSlot", EnumValue = 4 },
				{ Name = "Tabard", Type = "TransmogOutfitSlot", EnumValue = 5 },
				{ Name = "Body", Type = "TransmogOutfitSlot", EnumValue = 6 },
				{ Name = "Wrist", Type = "TransmogOutfitSlot", EnumValue = 7 },
				{ Name = "Hand", Type = "TransmogOutfitSlot", EnumValue = 8 },
				{ Name = "Waist", Type = "TransmogOutfitSlot", EnumValue = 9 },
				{ Name = "Legs", Type = "TransmogOutfitSlot", EnumValue = 10 },
				{ Name = "Feet", Type = "TransmogOutfitSlot", EnumValue = 11 },
				{ Name = "WeaponMainHand", Type = "TransmogOutfitSlot", EnumValue = 12 },
				{ Name = "WeaponOffHand", Type = "TransmogOutfitSlot", EnumValue = 13 },
				{ Name = "WeaponRanged", Type = "TransmogOutfitSlot", EnumValue = 14 },
			},
		},
		{
			Name = "TransmogOutfitSlotError",
			Type = "Enumeration",
			NumValues = 15,
			MinValue = 0,
			MaxValue = 14,
			Fields =
			{
				{ Name = "Ok", Type = "TransmogOutfitSlotError", EnumValue = 0 },
				{ Name = "NoItem", Type = "TransmogOutfitSlotError", EnumValue = 1 },
				{ Name = "NotSoulbound", Type = "TransmogOutfitSlotError", EnumValue = 2 },
				{ Name = "Legendary", Type = "TransmogOutfitSlotError", EnumValue = 3 },
				{ Name = "InvalidItemType", Type = "TransmogOutfitSlotError", EnumValue = 4 },
				{ Name = "InvalidDestination", Type = "TransmogOutfitSlotError", EnumValue = 5 },
				{ Name = "Mismatch", Type = "TransmogOutfitSlotError", EnumValue = 6 },
				{ Name = "SameItem", Type = "TransmogOutfitSlotError", EnumValue = 7 },
				{ Name = "InvalidSource", Type = "TransmogOutfitSlotError", EnumValue = 8 },
				{ Name = "InvalidSourceQuality", Type = "TransmogOutfitSlotError", EnumValue = 9 },
				{ Name = "CannotUseItem", Type = "TransmogOutfitSlotError", EnumValue = 10 },
				{ Name = "InvalidSlotForRace", Type = "TransmogOutfitSlotError", EnumValue = 11 },
				{ Name = "NoIllusion", Type = "TransmogOutfitSlotError", EnumValue = 12 },
				{ Name = "InvalidSlotForForm", Type = "TransmogOutfitSlotError", EnumValue = 13 },
				{ Name = "IncompatibleWithMainHand", Type = "TransmogOutfitSlotError", EnumValue = 14 },
			},
		},
		{
			Name = "TransmogOutfitSlotFlags",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 1,
			MaxValue = 4,
			Fields =
			{
				{ Name = "CannotBeHidden", Type = "TransmogOutfitSlotFlags", EnumValue = 1 },
				{ Name = "CanHaveIllusions", Type = "TransmogOutfitSlotFlags", EnumValue = 2 },
				{ Name = "IsSecondarySlot", Type = "TransmogOutfitSlotFlags", EnumValue = 4 },
			},
		},
		{
			Name = "TransmogOutfitSlotOption",
			Type = "Enumeration",
			NumValues = 12,
			MinValue = 0,
			MaxValue = 11,
			Fields =
			{
				{ Name = "None", Type = "TransmogOutfitSlotOption", EnumValue = 0 },
				{ Name = "OneHandedWeapon", Type = "TransmogOutfitSlotOption", EnumValue = 1 },
				{ Name = "TwoHandedWeapon", Type = "TransmogOutfitSlotOption", EnumValue = 2 },
				{ Name = "RangedWeapon", Type = "TransmogOutfitSlotOption", EnumValue = 3 },
				{ Name = "OffHand", Type = "TransmogOutfitSlotOption", EnumValue = 4 },
				{ Name = "Shield", Type = "TransmogOutfitSlotOption", EnumValue = 5 },
				{ Name = "RogueDagger", Type = "TransmogOutfitSlotOption", EnumValue = 6 },
				{ Name = "FuryTwoHandedWeapon", Type = "TransmogOutfitSlotOption", EnumValue = 7 },
				{ Name = "ArtifactSpecOne", Type = "TransmogOutfitSlotOption", EnumValue = 8 },
				{ Name = "ArtifactSpecTwo", Type = "TransmogOutfitSlotOption", EnumValue = 9 },
				{ Name = "ArtifactSpecThree", Type = "TransmogOutfitSlotOption", EnumValue = 10 },
				{ Name = "ArtifactSpecFour", Type = "TransmogOutfitSlotOption", EnumValue = 11 },
			},
		},
		{
			Name = "TransmogOutfitSlotOptionFlags",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 1,
			MaxValue = 4,
			Fields =
			{
				{ Name = "IllusionNotAllowed", Type = "TransmogOutfitSlotOptionFlags", EnumValue = 1 },
				{ Name = "DynamicOptionName", Type = "TransmogOutfitSlotOptionFlags", EnumValue = 2 },
				{ Name = "DisablesOffhandSlot", Type = "TransmogOutfitSlotOptionFlags", EnumValue = 4 },
			},
		},
		{
			Name = "TransmogOutfitSlotPosition",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Left", Type = "TransmogOutfitSlotPosition", EnumValue = 0 },
				{ Name = "Right", Type = "TransmogOutfitSlotPosition", EnumValue = 1 },
				{ Name = "Bottom", Type = "TransmogOutfitSlotPosition", EnumValue = 2 },
			},
		},
		{
			Name = "TransmogOutfitSlotSaveFlags",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "AppearanceIsNotValid", Type = "TransmogOutfitSlotSaveFlags", EnumValue = 1 },
			},
		},
		{
			Name = "TransmogOutfitSlotWarning",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Ok", Type = "TransmogOutfitSlotWarning", EnumValue = 0 },
				{ Name = "InvalidEquippedDestinationItem", Type = "TransmogOutfitSlotWarning", EnumValue = 1 },
				{ Name = "WrongWeaponCategoryEquipped", Type = "TransmogOutfitSlotWarning", EnumValue = 2 },
				{ Name = "PendingWeaponChanges", Type = "TransmogOutfitSlotWarning", EnumValue = 3 },
				{ Name = "NothingEquipped", Type = "TransmogOutfitSlotWarning", EnumValue = 4 },
			},
		},
		{
			Name = "TransmogOutfitTransactionFlags",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 1,
			MaxValue = 27,
			Fields =
			{
				{ Name = "UpdateMetadata", Type = "TransmogOutfitTransactionFlags", EnumValue = 1 },
				{ Name = "UpdateOutfitInfo", Type = "TransmogOutfitTransactionFlags", EnumValue = 2 },
				{ Name = "CreateOutfitInfo", Type = "TransmogOutfitTransactionFlags", EnumValue = 4 },
				{ Name = "UpdateSlots", Type = "TransmogOutfitTransactionFlags", EnumValue = 8 },
				{ Name = "UpdateSituations", Type = "TransmogOutfitTransactionFlags", EnumValue = 16 },
				{ Name = "AddNewOutfitMask", Type = "TransmogOutfitTransactionFlags", EnumValue = 20 },
				{ Name = "UpdateSituationsMask", Type = "TransmogOutfitTransactionFlags", EnumValue = 18 },
				{ Name = "FullOutfitUpdateMask", Type = "TransmogOutfitTransactionFlags", EnumValue = 27 },
				{ Name = "CreateAndUpdateOutfitInfoMask", Type = "TransmogOutfitTransactionFlags", EnumValue = 6 },
			},
		},
		{
			Name = "TransmogOutfitTransactionType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "UpdateMetadata", Type = "TransmogOutfitTransactionType", EnumValue = 0 },
				{ Name = "UpdateOutfitInfo", Type = "TransmogOutfitTransactionType", EnumValue = 1 },
				{ Name = "CreateOutfitInfo", Type = "TransmogOutfitTransactionType", EnumValue = 2 },
				{ Name = "UpdateSlots", Type = "TransmogOutfitTransactionType", EnumValue = 3 },
				{ Name = "UpdateSituations", Type = "TransmogOutfitTransactionType", EnumValue = 4 },
			},
		},
		{
			Name = "TransmogSituation",
			Type = "Enumeration",
			NumValues = 22,
			MinValue = 0,
			MaxValue = 21,
			Fields =
			{
				{ Name = "AllSpecs", Type = "TransmogSituation", EnumValue = 0 },
				{ Name = "Spec", Type = "TransmogSituation", EnumValue = 1 },
				{ Name = "AllLocations", Type = "TransmogSituation", EnumValue = 2 },
				{ Name = "LocationRested", Type = "TransmogSituation", EnumValue = 3 },
				{ Name = "LocationHouse", Type = "TransmogSituation", EnumValue = 4 },
				{ Name = "LocationCharacterSelect", Type = "TransmogSituation", EnumValue = 5 },
				{ Name = "LocationWorld", Type = "TransmogSituation", EnumValue = 6 },
				{ Name = "LocationDelves", Type = "TransmogSituation", EnumValue = 7 },
				{ Name = "LocationDungeons", Type = "TransmogSituation", EnumValue = 8 },
				{ Name = "LocationRaids", Type = "TransmogSituation", EnumValue = 9 },
				{ Name = "LocationArenas", Type = "TransmogSituation", EnumValue = 10 },
				{ Name = "LocationBattlegrounds", Type = "TransmogSituation", EnumValue = 11 },
				{ Name = "AllMovement", Type = "TransmogSituation", EnumValue = 12 },
				{ Name = "MovementUnmounted", Type = "TransmogSituation", EnumValue = 13 },
				{ Name = "MovementSwimming", Type = "TransmogSituation", EnumValue = 14 },
				{ Name = "MovementGroundMount", Type = "TransmogSituation", EnumValue = 15 },
				{ Name = "MovementFlyingMount", Type = "TransmogSituation", EnumValue = 16 },
				{ Name = "AllEquipmentSets", Type = "TransmogSituation", EnumValue = 17 },
				{ Name = "EquipmentSets", Type = "TransmogSituation", EnumValue = 18 },
				{ Name = "AllRacialForms", Type = "TransmogSituation", EnumValue = 19 },
				{ Name = "FormNative", Type = "TransmogSituation", EnumValue = 20 },
				{ Name = "FormNonNative", Type = "TransmogSituation", EnumValue = 21 },
			},
		},
		{
			Name = "TransmogSituationFlags",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 1,
			MaxValue = 64,
			Fields =
			{
				{ Name = "IsPlayerFacing", Type = "TransmogSituationFlags", EnumValue = 1 },
				{ Name = "SpecUseTalentLoadout", Type = "TransmogSituationFlags", EnumValue = 2 },
				{ Name = "AllSituation", Type = "TransmogSituationFlags", EnumValue = 4 },
				{ Name = "DefaultsToOn", Type = "TransmogSituationFlags", EnumValue = 8 },
				{ Name = "DynamicallyNamed", Type = "TransmogSituationFlags", EnumValue = 16 },
				{ Name = "NoneSituation", Type = "TransmogSituationFlags", EnumValue = 32 },
				{ Name = "DisabledSituation", Type = "TransmogSituationFlags", EnumValue = 64 },
			},
		},
		{
			Name = "TransmogSituationGroupFlags",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "DynamicallyCreatesGroups", Type = "TransmogSituationGroupFlags", EnumValue = 1 },
			},
		},
		{
			Name = "TransmogSituationTrigger",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "Manual", Type = "TransmogSituationTrigger", EnumValue = 0 },
				{ Name = "TransmogUpdate", Type = "TransmogSituationTrigger", EnumValue = 1 },
				{ Name = "Location", Type = "TransmogSituationTrigger", EnumValue = 2 },
				{ Name = "Movement", Type = "TransmogSituationTrigger", EnumValue = 3 },
				{ Name = "Specialization", Type = "TransmogSituationTrigger", EnumValue = 4 },
				{ Name = "EquipmentSet", Type = "TransmogSituationTrigger", EnumValue = 5 },
				{ Name = "Forms", Type = "TransmogSituationTrigger", EnumValue = 6 },
			},
		},
		{
			Name = "TransmogSituationTriggerFlags",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 1,
			MaxValue = 16,
			Fields =
			{
				{ Name = "CanLockOutfit", Type = "TransmogSituationTriggerFlags", EnumValue = 1 },
				{ Name = "CanChangeLockedOutfit", Type = "TransmogSituationTriggerFlags", EnumValue = 2 },
				{ Name = "IsPlayerFacing", Type = "TransmogSituationTriggerFlags", EnumValue = 4 },
				{ Name = "SituationsAreExclusive", Type = "TransmogSituationTriggerFlags", EnumValue = 8 },
				{ Name = "DisabledTrigger", Type = "TransmogSituationTriggerFlags", EnumValue = 16 },
			},
		},
		{
			Name = "TransmogOutfitDataConsts",
			Type = "Constants",
			Values =
			{
				{ Name = "EQUIP_TRANSMOG_OUTFIT_MANUAL_SPELL_ID", Type = "number", Value = 1247613 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(TransmogOutfitConstants);