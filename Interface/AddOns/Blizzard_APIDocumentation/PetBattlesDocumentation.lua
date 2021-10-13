local PetBattles =
{
	Name = "PetBattles",
	Type = "System",
	Namespace = "C_PetBattles",

	Functions =
	{
		{
			Name = "GetBreedQuality",
			Type = "Function",

			Arguments =
			{
				{ Name = "petOwner", Type = "number", Nilable = false },
				{ Name = "slot", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "quality", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetIcon",
			Type = "Function",

			Arguments =
			{
				{ Name = "petOwner", Type = "number", Nilable = false },
				{ Name = "slot", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "iconFileID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetName",
			Type = "Function",

			Arguments =
			{
				{ Name = "petOwner", Type = "number", Nilable = false },
				{ Name = "slot", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "customName", Type = "string", Nilable = false },
				{ Name = "speciesName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "IsPlayerNPC",
			Type = "Function",

			Returns =
			{
				{ Name = "isPlayerNPC", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsWildBattle",
			Type = "Function",

			Returns =
			{
				{ Name = "isWildBattle", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(PetBattles);