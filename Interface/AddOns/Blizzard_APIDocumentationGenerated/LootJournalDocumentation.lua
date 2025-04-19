local LootJournal =
{
	Name = "LootJournal",
	Type = "System",
	Namespace = "C_LootJournal",

	Functions =
	{
		{
			Name = "GetItemSetItems",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "setID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "items", Type = "table", InnerType = "LootJournalItemInfo", Nilable = false },
			},
		},
		{
			Name = "GetItemSets",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "classID", Type = "number", Nilable = true },
				{ Name = "specID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "itemSets", Type = "table", InnerType = "LootJournalItemSetInfo", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "LootJournalItemUpdate",
			Type = "Event",
			LiteralName = "LOOT_JOURNAL_ITEM_UPDATE",
		},
	},

	Tables =
	{
		{
			Name = "LootJournalItemInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemID", Type = "number", Nilable = false },
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "invType", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "LootJournalItemSetInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "setID", Type = "number", Nilable = false },
				{ Name = "itemLevel", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(LootJournal);