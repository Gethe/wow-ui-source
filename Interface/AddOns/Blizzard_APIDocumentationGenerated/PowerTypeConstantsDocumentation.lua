local PowerTypeConstants =
{
	Tables =
	{
		{
			Name = "BalanceType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = -1,
			MaxValue = 0,
			Fields =
			{
				{ Name = "None", Type = "BalanceType", EnumValue = -1 },
				{ Name = "Eclipse", Type = "BalanceType", EnumValue = 0 },
			},
		},
		{
			Name = "PowerType",
			Type = "Enumeration",
			NumValues = 27,
			MinValue = 0,
			MaxValue = 26,
			Fields =
			{
				{ Name = "Mana", Type = "PowerType", EnumValue = 0 },
				{ Name = "Rage", Type = "PowerType", EnumValue = 1 },
				{ Name = "Focus", Type = "PowerType", EnumValue = 2 },
				{ Name = "Energy", Type = "PowerType", EnumValue = 3 },
				{ Name = "ComboPoints", Type = "PowerType", EnumValue = 4 },
				{ Name = "Runes", Type = "PowerType", EnumValue = 5 },
				{ Name = "RunicPower", Type = "PowerType", EnumValue = 6 },
				{ Name = "SoulShards", Type = "PowerType", EnumValue = 7 },
				{ Name = "LunarPower", Type = "PowerType", EnumValue = 8 },
				{ Name = "HolyPower", Type = "PowerType", EnumValue = 9 },
				{ Name = "Alternate", Type = "PowerType", EnumValue = 10 },
				{ Name = "Maelstrom", Type = "PowerType", EnumValue = 11 },
				{ Name = "Chi", Type = "PowerType", EnumValue = 12 },
				{ Name = "Insanity", Type = "PowerType", EnumValue = 13 },
				{ Name = "Obsolete", Type = "PowerType", EnumValue = 14 },
				{ Name = "Obsolete2", Type = "PowerType", EnumValue = 15 },
				{ Name = "ArcaneCharges", Type = "PowerType", EnumValue = 16 },
				{ Name = "Fury", Type = "PowerType", EnumValue = 17 },
				{ Name = "Pain", Type = "PowerType", EnumValue = 18 },
				{ Name = "Essence", Type = "PowerType", EnumValue = 19 },
				{ Name = "RuneBlood", Type = "PowerType", EnumValue = 20 },
				{ Name = "RuneFrost", Type = "PowerType", EnumValue = 21 },
				{ Name = "RuneUnholy", Type = "PowerType", EnumValue = 22 },
				{ Name = "AlternateQuest", Type = "PowerType", EnumValue = 23 },
				{ Name = "AlternateEncounter", Type = "PowerType", EnumValue = 24 },
				{ Name = "AlternateMount", Type = "PowerType", EnumValue = 25 },
				{ Name = "Balance", Type = "PowerType", EnumValue = 26 },
			},
		},
		{
			Name = "PowerTypeSign",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = -1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "None", Type = "PowerTypeSign", EnumValue = -1 },
				{ Name = "Positive", Type = "PowerTypeSign", EnumValue = 0 },
				{ Name = "Negative", Type = "PowerTypeSign", EnumValue = 1 },
			},
		},
		{
			Name = "PowerTypeSlot",
			Type = "Enumeration",
			NumValues = 10,
			MinValue = 0,
			MaxValue = 9,
			Fields =
			{
				{ Name = "Slot_0", Type = "PowerTypeSlot", EnumValue = 0 },
				{ Name = "Slot_1", Type = "PowerTypeSlot", EnumValue = 1 },
				{ Name = "Slot_2", Type = "PowerTypeSlot", EnumValue = 2 },
				{ Name = "Slot_3", Type = "PowerTypeSlot", EnumValue = 3 },
				{ Name = "Slot_4", Type = "PowerTypeSlot", EnumValue = 4 },
				{ Name = "Slot_5", Type = "PowerTypeSlot", EnumValue = 5 },
				{ Name = "Slot_6", Type = "PowerTypeSlot", EnumValue = 6 },
				{ Name = "Slot_7", Type = "PowerTypeSlot", EnumValue = 7 },
				{ Name = "Slot_8", Type = "PowerTypeSlot", EnumValue = 8 },
				{ Name = "Slot_9", Type = "PowerTypeSlot", EnumValue = 9 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(PowerTypeConstants);