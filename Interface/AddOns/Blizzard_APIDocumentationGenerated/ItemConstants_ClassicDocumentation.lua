local ItemConstants_Classic =
{
	Tables =
	{
		{
			Name = "ItemGemSubclass",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 0,
			MaxValue = 8,
			Fields =
			{
				{ Name = "Red", Type = "ItemGemSubclass", EnumValue = 0 },
				{ Name = "Blue", Type = "ItemGemSubclass", EnumValue = 1 },
				{ Name = "Yellow", Type = "ItemGemSubclass", EnumValue = 2 },
				{ Name = "Purple", Type = "ItemGemSubclass", EnumValue = 3 },
				{ Name = "Green", Type = "ItemGemSubclass", EnumValue = 4 },
				{ Name = "Orange", Type = "ItemGemSubclass", EnumValue = 5 },
				{ Name = "Meta", Type = "ItemGemSubclass", EnumValue = 6 },
				{ Name = "Simple", Type = "ItemGemSubclass", EnumValue = 7 },
				{ Name = "Prismatic", Type = "ItemGemSubclass", EnumValue = 8 },
			},
		},
		{
			Name = "ReforgeFailedReason",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "None", Type = "ReforgeFailedReason", EnumValue = 0 },
				{ Name = "ReforgeSrcStatNotFound", Type = "ReforgeFailedReason", EnumValue = 1 },
				{ Name = "ReforgeInsufficientSrcStat", Type = "ReforgeFailedReason", EnumValue = 2 },
				{ Name = "ReforgeAlreadyHasDstStat", Type = "ReforgeFailedReason", EnumValue = 3 },
				{ Name = "ReforgeItemTooLowLevel", Type = "ReforgeFailedReason", EnumValue = 4 },
				{ Name = "NumReforgeFailedReason", Type = "ReforgeFailedReason", EnumValue = 5 },
			},
		},
		{
			Name = "ScalingArmorType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Cloth", Type = "ScalingArmorType", EnumValue = 0 },
				{ Name = "Leather", Type = "ScalingArmorType", EnumValue = 1 },
				{ Name = "Mail", Type = "ScalingArmorType", EnumValue = 2 },
				{ Name = "Plate", Type = "ScalingArmorType", EnumValue = 3 },
			},
		},
		{
			Name = "InventoryConstants",
			Type = "Constants",
			Values =
			{
				{ Name = "NumBagSlots", Type = "number", Value = NUM_BAG_SLOTS },
				{ Name = "NumGenericBankSlots", Type = "number", Value = BANK_NUM_GENERIC_SLOTS },
				{ Name = "NumBankBagSlots", Type = "number", Value = NUM_BANKBAG_SLOTS },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ItemConstants_Classic);