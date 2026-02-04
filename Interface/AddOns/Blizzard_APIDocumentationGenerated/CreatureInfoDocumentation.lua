local CreatureInfo =
{
	Name = "CreatureInfo",
	Type = "System",
	Namespace = "C_CreatureInfo",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetClassInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "GetCreatureFamilyIDs",
			Type = "Function",

			Returns =
			{
				{ Name = "creatureFamilyIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetCreatureFamilyInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "creatureFamilyID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "creatureFamilyInfo", Type = "CreatureFamilyInfo", Nilable = true },
			},
		},
		{
			Name = "GetCreatureID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "creatureGUID", Type = "WOWGUID", Nilable = false },
			},

			Returns =
			{
				{ Name = "creatureID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetCreatureTypeIDs",
			Type = "Function",

			Returns =
			{
				{ Name = "creatureTypeIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
		{
			Name = "GetCreatureTypeInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "creatureTypeID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "creatureTypeInfo", Type = "CreatureTypeInfo", Nilable = true },
			},
		},
		{
			Name = "GetFactionInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "CreatureFamilyInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "iconFile", Type = "fileID", Nilable = true },
			},
		},
		{
			Name = "CreatureTypeInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "id", Type = "number", Nilable = false },
				{ Name = "name", Type = "cstring", Nilable = false },
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