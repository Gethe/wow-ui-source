local TransmogConstants =
{
	Tables =
	{
		{
			Name = "TransmogSlot",
			Type = "Enumeration",
			NumValues = 13,
			MinValue = 0,
			MaxValue = 12,
			Fields =
			{
				{ Name = "Head", Type = "TransmogSlot", EnumValue = 0 },
				{ Name = "Shoulder", Type = "TransmogSlot", EnumValue = 1 },
				{ Name = "Back", Type = "TransmogSlot", EnumValue = 2 },
				{ Name = "Chest", Type = "TransmogSlot", EnumValue = 3 },
				{ Name = "Body", Type = "TransmogSlot", EnumValue = 4 },
				{ Name = "Tabard", Type = "TransmogSlot", EnumValue = 5 },
				{ Name = "Wrist", Type = "TransmogSlot", EnumValue = 6 },
				{ Name = "Hand", Type = "TransmogSlot", EnumValue = 7 },
				{ Name = "Waist", Type = "TransmogSlot", EnumValue = 8 },
				{ Name = "Legs", Type = "TransmogSlot", EnumValue = 9 },
				{ Name = "Feet", Type = "TransmogSlot", EnumValue = 10 },
				{ Name = "Mainhand", Type = "TransmogSlot", EnumValue = 11 },
				{ Name = "Offhand", Type = "TransmogSlot", EnumValue = 12 },
			},
		},
		{
			Name = "Transmog",
			Type = "Constants",
			Values =
			{
				{ Name = "NoTransmogID", Type = "number", Value = 0 },
				{ Name = "MainHandTransmogIsIndividualWeapon", Type = "number", Value = -1 },
				{ Name = "MainHandTransmogIsPairedWeapon", Type = "number", Value = 0 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(TransmogConstants);