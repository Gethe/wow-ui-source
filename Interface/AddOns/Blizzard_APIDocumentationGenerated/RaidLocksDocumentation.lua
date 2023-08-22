local RaidLocks =
{
	Name = "RaidLocks",
	Type = "System",
	Namespace = "C_RaidLocks",

	Functions =
	{
		{
			Name = "IsEncounterComplete",
			Type = "Function",

			Arguments =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
				{ Name = "encounterID", Type = "number", Nilable = false },
				{ Name = "difficultyID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "encounterIsComplete", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(RaidLocks);