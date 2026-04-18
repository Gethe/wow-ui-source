local StableInfo =
{
	Name = "StableInfo",
	Type = "System",
	Namespace = "C_StableInfo",
	Environment = "All",

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
			SynchronousEvent = true,
		},
		{
			Name = "PetStableShow",
			Type = "Event",
			LiteralName = "PET_STABLE_SHOW",
			SynchronousEvent = true,
		},
		{
			Name = "PetStableUpdate",
			Type = "Event",
			LiteralName = "PET_STABLE_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "PetStableUpdatePaperdoll",
			Type = "Event",
			LiteralName = "PET_STABLE_UPDATE_PAPERDOLL",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(StableInfo);