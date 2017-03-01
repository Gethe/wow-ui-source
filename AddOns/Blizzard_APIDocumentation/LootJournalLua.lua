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

	Tables =
	{
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
				{ Name = "isCraftable", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(LootJournalLua);