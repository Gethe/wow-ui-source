local EncounterInfo =
{
	Name = "EncounterInfo",
	Type = "System",
	Namespace = "C_EncounterInfo",
	Environment = "All",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "BossKill",
			Type = "Event",
			LiteralName = "BOSS_KILL",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "encounterID", Type = "number", Nilable = false },
				{ Name = "encounterName", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "DisableLowLevelRaid",
			Type = "Event",
			LiteralName = "DISABLE_LOW_LEVEL_RAID",
			SynchronousEvent = true,
		},
		{
			Name = "EnableLowLevelRaid",
			Type = "Event",
			LiteralName = "ENABLE_LOW_LEVEL_RAID",
			SynchronousEvent = true,
		},
		{
			Name = "EncounterEnd",
			Type = "Event",
			LiteralName = "ENCOUNTER_END",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "encounterID", Type = "number", Nilable = false },
				{ Name = "encounterName", Type = "cstring", Nilable = false },
				{ Name = "difficultyID", Type = "number", Nilable = false },
				{ Name = "groupSize", Type = "number", Nilable = false },
				{ Name = "success", Type = "number", Nilable = false },
			},
		},
		{
			Name = "EncounterStart",
			Type = "Event",
			LiteralName = "ENCOUNTER_START",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "encounterID", Type = "number", Nilable = false },
				{ Name = "encounterName", Type = "cstring", Nilable = false },
				{ Name = "difficultyID", Type = "number", Nilable = false },
				{ Name = "groupSize", Type = "number", Nilable = false },
			},
		},
		{
			Name = "InstanceLockStart",
			Type = "Event",
			LiteralName = "INSTANCE_LOCK_START",
			SynchronousEvent = true,
		},
		{
			Name = "InstanceLockStop",
			Type = "Event",
			LiteralName = "INSTANCE_LOCK_STOP",
			SynchronousEvent = true,
		},
		{
			Name = "InstanceLockWarning",
			Type = "Event",
			LiteralName = "INSTANCE_LOCK_WARNING",
			SynchronousEvent = true,
		},
		{
			Name = "RaidTargetUpdate",
			Type = "Event",
			LiteralName = "RAID_TARGET_UPDATE",
			SynchronousEvent = true,
		},
		{
			Name = "UpdateInstanceInfo",
			Type = "Event",
			LiteralName = "UPDATE_INSTANCE_INFO",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(EncounterInfo);