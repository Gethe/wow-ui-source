local EncounterJournalLua =
{
	Name = "EncounterJournal",
	Type = "System",
	Namespace = "C_EncounterJournal",

	Functions =
	{
		{
			Name = "GetCurrentMapEncounters",
			Type = "Function",

			Arguments =
			{
				{ Name = "fromJournal", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "encounters", Type = "table", InnerType = "EncounterJournalMapEncounterInfo", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "EncounterJournalMapEncounterInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "encounterID", Type = "number", Nilable = false },
				{ Name = "mapX", Type = "number", Nilable = false },
				{ Name = "mapY", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(EncounterJournalLua);