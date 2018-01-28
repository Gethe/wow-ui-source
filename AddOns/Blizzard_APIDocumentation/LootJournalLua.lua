local LootJournalLua =
{
	Name = "LootJournal",
	Type = "System",
	Namespace = "C_LootJournal",

	Functions =
	{
		{
			Name = "GetFilteredLegendaries",
			Type = "Function",

			Returns =
			{
				{ Name = "journalItems", Type = "table", InnerType = "LegendaryJournalItem", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
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
			Name = "LegendaryJournalItem",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "link", Type = "string", Nilable = false },
				{ Name = "quality", Type = "number", Nilable = false },
				{ Name = "inventoryTypeName", Type = "string", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "transmogSource", Type = "TransmogSource", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(LootJournalLua);