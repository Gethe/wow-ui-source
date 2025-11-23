local StableInfo =
{
	Name = "StableInfo",
	Type = "System",
	Namespace = "C_StableInfo",

	Functions =
	{
		{
			Name = "GetNumActivePets",
			Type = "Function",

			Returns =
			{
				{ Name = "numActivePets", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumStablePets",
			Type = "Function",

			Returns =
			{
				{ Name = "numStablePets", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "PetStableClosed",
			Type = "Event",
			LiteralName = "PET_STABLE_CLOSED",
		},
		{
			Name = "PetStableShow",
			Type = "Event",
			LiteralName = "PET_STABLE_SHOW",
		},
		{
			Name = "PetStableUpdate",
			Type = "Event",
			LiteralName = "PET_STABLE_UPDATE",
		},
		{
			Name = "PetStableUpdatePaperdoll",
			Type = "Event",
			LiteralName = "PET_STABLE_UPDATE_PAPERDOLL",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(StableInfo);