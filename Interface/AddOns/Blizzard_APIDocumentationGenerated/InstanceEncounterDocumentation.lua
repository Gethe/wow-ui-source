local InstanceEncounter =
{
	Name = "InstanceEncounter",
	Type = "System",
	Namespace = "C_InstanceEncounter",
	Environment = "All",

	Functions =
	{
		{
			Name = "IsEncounterInProgress",
			Type = "Function",

			Returns =
			{
				{ Name = "isInProgress", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEncounterLimitingResurrections",
			Type = "Function",

			Returns =
			{
				{ Name = "isLimitingResurrections", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEncounterSuppressingRelease",
			Type = "Function",

			Returns =
			{
				{ Name = "isSuppressingRelease", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldShowTimelineForEncounter",
			Type = "Function",

			Returns =
			{
				{ Name = "shouldShow", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "EncounterStateChanged",
			Type = "Event",
			LiteralName = "ENCOUNTER_STATE_CHANGED",
			SynchronousEvent = true,
			CallbackEvent = true,
			Documentation = { "Signaled when the in-progress state of an encounter changes." },
			Payload =
			{
				{ Name = "isInProgress", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "InstanceEncounterAddTimer",
			Type = "Event",
			LiteralName = "INSTANCE_ENCOUNTER_ADD_TIMER",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "timeRemaining", Type = "number", Nilable = false },
			},
		},
		{
			Name = "InstanceEncounterEngageUnit",
			Type = "Event",
			LiteralName = "INSTANCE_ENCOUNTER_ENGAGE_UNIT",
			SynchronousEvent = true,
		},
		{
			Name = "InstanceEncounterObjectiveComplete",
			Type = "Event",
			LiteralName = "INSTANCE_ENCOUNTER_OBJECTIVE_COMPLETE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "objectiveID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "InstanceEncounterObjectiveStart",
			Type = "Event",
			LiteralName = "INSTANCE_ENCOUNTER_OBJECTIVE_START",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "objectiveID", Type = "number", Nilable = false },
				{ Name = "objectiveProgress", Type = "number", Nilable = false },
			},
		},
		{
			Name = "InstanceEncounterObjectiveUpdate",
			Type = "Event",
			LiteralName = "INSTANCE_ENCOUNTER_OBJECTIVE_UPDATE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "objectiveID", Type = "number", Nilable = false },
				{ Name = "objectiveProgress", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(InstanceEncounter);