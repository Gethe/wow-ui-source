local ItemConstants_Mainline =
{
	Tables =
	{
		{
			Name = "ItemGemSubclass",
			Type = "Enumeration",
			NumValues = 12,
			MinValue = 0,
			MaxValue = 11,
			Fields =
			{
				{ Name = "Intellect", Type = "ItemGemSubclass", EnumValue = 0 },
				{ Name = "Agility", Type = "ItemGemSubclass", EnumValue = 1 },
				{ Name = "Strength", Type = "ItemGemSubclass", EnumValue = 2 },
				{ Name = "Stamina", Type = "ItemGemSubclass", EnumValue = 3 },
				{ Name = "Spirit", Type = "ItemGemSubclass", EnumValue = 4 },
				{ Name = "Criticalstrike", Type = "ItemGemSubclass", EnumValue = 5 },
				{ Name = "Mastery", Type = "ItemGemSubclass", EnumValue = 6 },
				{ Name = "Haste", Type = "ItemGemSubclass", EnumValue = 7 },
				{ Name = "Versatility", Type = "ItemGemSubclass", EnumValue = 8 },
				{ Name = "Other", Type = "ItemGemSubclass", EnumValue = 9 },
				{ Name = "Multiplestats", Type = "ItemGemSubclass", EnumValue = 10 },
				{ Name = "Artifactrelic", Type = "ItemGemSubclass", EnumValue = 11 },
			},
		},
		{
			Name = "ItemRedundancySlot",
			Type = "Enumeration",
			NumValues = 17,
			MinValue = 0,
			MaxValue = 16,
			Fields =
			{
				{ Name = "Head", Type = "ItemRedundancySlot", EnumValue = 0 },
				{ Name = "Neck", Type = "ItemRedundancySlot", EnumValue = 1 },
				{ Name = "Shoulder", Type = "ItemRedundancySlot", EnumValue = 2 },
				{ Name = "Chest", Type = "ItemRedundancySlot", EnumValue = 3 },
				{ Name = "Waist", Type = "ItemRedundancySlot", EnumValue = 4 },
				{ Name = "Legs", Type = "ItemRedundancySlot", EnumValue = 5 },
				{ Name = "Feet", Type = "ItemRedundancySlot", EnumValue = 6 },
				{ Name = "Wrist", Type = "ItemRedundancySlot", EnumValue = 7 },
				{ Name = "Hand", Type = "ItemRedundancySlot", EnumValue = 8 },
				{ Name = "Finger", Type = "ItemRedundancySlot", EnumValue = 9 },
				{ Name = "Trinket", Type = "ItemRedundancySlot", EnumValue = 10 },
				{ Name = "Cloak", Type = "ItemRedundancySlot", EnumValue = 11 },
				{ Name = "Twohand", Type = "ItemRedundancySlot", EnumValue = 12 },
				{ Name = "MainhandWeapon", Type = "ItemRedundancySlot", EnumValue = 13 },
				{ Name = "OnehandWeapon", Type = "ItemRedundancySlot", EnumValue = 14 },
				{ Name = "OnehandWeaponSecond", Type = "ItemRedundancySlot", EnumValue = 15 },
				{ Name = "Offhand", Type = "ItemRedundancySlot", EnumValue = 16 },
			},
		},
		{
			Name = "InventoryConstants",
			Type = "Constants",
			Values =
			{
				{ Name = "NumBagSlots", Type = "number", Value = NUM_BAG_SLOTS },
				{ Name = "NumCharacterBankSlots", Type = "number", Value = NUM_CHARACTERBANK_SLOTS },
				{ Name = "NumReagentBagSlots", Type = "number", Value = NUM_REAGENTBAG_SLOTS },
				{ Name = "NumAccountBankSlots", Type = "number", Value = NUM_ACCOUNTBANK_SLOTS },
				{ Name = "MAX_TRANSACTION_BANK_TABS", Type = "number", Value = 0 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ItemConstants_Mainline);