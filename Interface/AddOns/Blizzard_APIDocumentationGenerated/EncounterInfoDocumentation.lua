local EncounterInfo =
{
	Name = "EncounterInfo",
	Type = "System",
	Namespace = "C_EncounterInfo",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "BossKill",
			Type = "Event",
			LiteralName = "BOSS_KILL",
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
		},
		{
			Name = "EnableLowLevelRaid",
			Type = "Event",
			LiteralName = "ENABLE_LOW_LEVEL_RAID",
		},
		{
			Name = "EncounterEnd",
			Type = "Event",
			LiteralName = "ENCOUNTER_END",
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
		},
		{
			Name = "InstanceLockStop",
			Type = "Event",
			LiteralName = "INSTANCE_LOCK_STOP",
		},
		{
			Name = "InstanceLockWarning",
			Type = "Event",
			LiteralName = "INSTANCE_LOCK_WARNING",
		},
		{
			Name = "RaidTargetUpdate",
			Type = "Event",
			LiteralName = "RAID_TARGET_UPDATE",
		},
		{
			Name = "UpdateInstanceInfo",
			Type = "Event",
			LiteralName = "UPDATE_INSTANCE_INFO",
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(EncounterInfo);