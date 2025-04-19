local InstanceEncounter =
{
	Name = "InstanceEncounter",
	Type = "System",
	Namespace = "C_InstanceEncounter",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "InstanceEncounterAddTimer",
			Type = "Event",
			LiteralName = "INSTANCE_ENCOUNTER_ADD_TIMER",
			Payload =
			{
				{ Name = "timeRemaining", Type = "number", Nilable = false },
			},
		},
		{
			Name = "InstanceEncounterEngageUnit",
			Type = "Event",
			LiteralName = "INSTANCE_ENCOUNTER_ENGAGE_UNIT",
		},
		{
			Name = "InstanceEncounterObjectiveComplete",
			Type = "Event",
			LiteralName = "INSTANCE_ENCOUNTER_OBJECTIVE_COMPLETE",
			Payload =
			{
				{ Name = "objectiveID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "InstanceEncounterObjectiveStart",
			Type = "Event",
			LiteralName = "INSTANCE_ENCOUNTER_OBJECTIVE_START",
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