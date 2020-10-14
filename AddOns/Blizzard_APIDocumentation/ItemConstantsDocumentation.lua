local ItemConstants =
{
	Tables =
	{
		{
			Name = "InventoryType",
			Type = "Enumeration",
			NumValues = 29,
			MinValue = 0,
			MaxValue = 28,
			Fields =
			{
				{ Name = "IndexNonEquipType", Type = "InventoryType", EnumValue = 0 },
				{ Name = "IndexHeadType", Type = "InventoryType", EnumValue = 1 },
				{ Name = "IndexNeckType", Type = "InventoryType", EnumValue = 2 },
				{ Name = "IndexShoulderType", Type = "InventoryType", EnumValue = 3 },
				{ Name = "IndexBodyType", Type = "InventoryType", EnumValue = 4 },
				{ Name = "IndexChestType", Type = "InventoryType", EnumValue = 5 },
				{ Name = "IndexWaistType", Type = "InventoryType", EnumValue = 6 },
				{ Name = "IndexLegsType", Type = "InventoryType", EnumValue = 7 },
				{ Name = "IndexFeetType", Type = "InventoryType", EnumValue = 8 },
				{ Name = "IndexWristType", Type = "InventoryType", EnumValue = 9 },
				{ Name = "IndexHandType", Type = "InventoryType", EnumValue = 10 },
				{ Name = "IndexFingerType", Type = "InventoryType", EnumValue = 11 },
				{ Name = "IndexTrinketType", Type = "InventoryType", EnumValue = 12 },
				{ Name = "IndexWeaponType", Type = "InventoryType", EnumValue = 13 },
				{ Name = "IndexShieldType", Type = "InventoryType", EnumValue = 14 },
				{ Name = "IndexRangedType", Type = "InventoryType", EnumValue = 15 },
				{ Name = "IndexCloakType", Type = "InventoryType", EnumValue = 16 },
				{ Name = "Index2HweaponType", Type = "InventoryType", EnumValue = 17 },
				{ Name = "IndexBagType", Type = "InventoryType", EnumValue = 18 },
				{ Name = "IndexTabardType", Type = "InventoryType", EnumValue = 19 },
				{ Name = "IndexRobeType", Type = "InventoryType", EnumValue = 20 },
				{ Name = "IndexWeaponmainhandType", Type = "InventoryType", EnumValue = 21 },
				{ Name = "IndexWeaponoffhandType", Type = "InventoryType", EnumValue = 22 },
				{ Name = "IndexHoldableType", Type = "InventoryType", EnumValue = 23 },
				{ Name = "IndexAmmoType", Type = "InventoryType", EnumValue = 24 },
				{ Name = "IndexThrownType", Type = "InventoryType", EnumValue = 25 },
				{ Name = "IndexRangedrightType", Type = "InventoryType", EnumValue = 26 },
				{ Name = "IndexQuiverType", Type = "InventoryType", EnumValue = 27 },
				{ Name = "IndexRelicType", Type = "InventoryType", EnumValue = 28 },
			},
		},
		{
			Name = "ItemQuality",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 0,
			MaxValue = 8,
			Fields =
			{
				{ Name = "Poor", Type = "ItemQuality", EnumValue = 0 },
				{ Name = "Common", Type = "ItemQuality", EnumValue = 1 },
				{ Name = "Uncommon", Type = "ItemQuality", EnumValue = 2 },
				{ Name = "Rare", Type = "ItemQuality", EnumValue = 3 },
				{ Name = "Epic", Type = "ItemQuality", EnumValue = 4 },
				{ Name = "Legendary", Type = "ItemQuality", EnumValue = 5 },
				{ Name = "Artifact", Type = "ItemQuality", EnumValue = 6 },
				{ Name = "Heirloom", Type = "ItemQuality", EnumValue = 7 },
				{ Name = "WoWToken", Type = "ItemQuality", EnumValue = 8 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ItemConstants);