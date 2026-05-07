local DungeonEncounterConstants =
{
	Tables =
	{
		{
			Name = "EncounterEventCastState",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 1,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Casting", Type = "EncounterEventCastState", EnumValue = 1 },
				{ Name = "NotCasting", Type = "EncounterEventCastState", EnumValue = 2 },
				{ Name = "Expired", Type = "EncounterEventCastState", EnumValue = 3 },
			},
		},
		{
			Name = "EncounterEventIconmask",
			Type = "Enumeration",
			NumValues = 10,
			MinValue = 1,
			MaxValue = 512,
			Fields =
			{
				{ Name = "DeadlyEffect", Type = "EncounterEventIconmask", EnumValue = 1 },
				{ Name = "EnrageEffect", Type = "EncounterEventIconmask", EnumValue = 2 },
				{ Name = "BleedEffect", Type = "EncounterEventIconmask", EnumValue = 4 },
				{ Name = "MagicEffect", Type = "EncounterEventIconmask", EnumValue = 8 },
				{ Name = "DiseaseEffect", Type = "EncounterEventIconmask", EnumValue = 16 },
				{ Name = "CurseEffect", Type = "EncounterEventIconmask", EnumValue = 32 },
				{ Name = "PoisonEffect", Type = "EncounterEventIconmask", EnumValue = 64 },
				{ Name = "TankRole", Type = "EncounterEventIconmask", EnumValue = 128 },
				{ Name = "HealerRole", Type = "EncounterEventIconmask", EnumValue = 256 },
				{ Name = "DpsRole", Type = "EncounterEventIconmask", EnumValue = 512 },
			},
		},
		{
			Name = "EncounterEventSeverity",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Low", Type = "EncounterEventSeverity", EnumValue = 0 },
				{ Name = "Medium", Type = "EncounterEventSeverity", EnumValue = 1 },
				{ Name = "High", Type = "EncounterEventSeverity", EnumValue = 2 },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(DungeonEncounterConstants);