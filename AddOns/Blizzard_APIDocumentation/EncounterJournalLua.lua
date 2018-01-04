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
		{
			Name = "GetSectionIconFlags",
			Type = "Function",
			Documentation = { "Represents the icon indices for this EJ section.  An icon index can be used to arrive at texture coordinates for specific encounter types, e.g.: EncounterJournal_SetFlagIcon" },

			Arguments =
			{
				{ Name = "sectionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "iconFlags", Type = "table", InnerType = "number", Nilable = true },
			},
		},
		{
			Name = "GetSectionInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "sectionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "EncounterJournalSectionInfo", Nilable = false },
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
		{
			Name = "EncounterJournalSectionInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "title", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = true },
				{ Name = "headerType", Type = "number", Nilable = false },
				{ Name = "abilityIcon", Type = "number", Nilable = false },
				{ Name = "creatureDisplayID", Type = "number", Nilable = false },
				{ Name = "uiModelSceneID", Type = "number", Nilable = false },
				{ Name = "siblingSectionID", Type = "number", Nilable = true },
				{ Name = "firstChildSectionID", Type = "number", Nilable = true },
				{ Name = "filteredByDifficulty", Type = "bool", Nilable = false },
				{ Name = "link", Type = "string", Nilable = false },
				{ Name = "startsOpen", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(EncounterJournalLua);