local CreatureInfo =
{
	Name = "CreatureInfo",
	Type = "System",
	Namespace = "C_CreatureInfo",

	Functions =
	{
		{
			Name = "GetClassInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "classID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "classInfo", Type = "ClassInfo", Nilable = true },
			},
		},
		{
			Name = "GetFactionInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "raceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "factionInfo", Type = "FactionInfo", Nilable = true },
			},
		},
		{
			Name = "GetRaceInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "raceID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "raceInfo", Type = "RaceInfo", Nilable = true },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "ClassInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "className", Type = "string", Nilable = false },
				{ Name = "classFile", Type = "string", Nilable = false },
				{ Name = "classID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "FactionInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "groupTag", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "RaceInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "raceName", Type = "string", Nilable = false },
				{ Name = "clientFileString", Type = "string", Nilable = false },
				{ Name = "raceID", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CreatureInfo);