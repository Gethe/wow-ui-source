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