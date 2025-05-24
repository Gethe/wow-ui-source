local AzeriteConstants =
{
	Tables =
	{
		{
			Name = "AzeriteEssenceSlot",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "MainSlot", Type = "AzeriteEssenceSlot", EnumValue = 0 },
				{ Name = "PassiveOneSlot", Type = "AzeriteEssenceSlot", EnumValue = 1 },
				{ Name = "PassiveTwoSlot", Type = "AzeriteEssenceSlot", EnumValue = 2 },
				{ Name = "PassiveThreeSlot", Type = "AzeriteEssenceSlot", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(AzeriteConstants);