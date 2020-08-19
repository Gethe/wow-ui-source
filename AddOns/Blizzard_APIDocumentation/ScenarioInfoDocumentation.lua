local ScenarioInfo =
{
	Name = "ScenarioInfo",
	Type = "System",
	Namespace = "C_ScenarioInfo",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "JailersTowerLevelUpdate",
			Type = "Event",
			LiteralName = "JAILERS_TOWER_LEVEL_UPDATE",
			Payload =
			{
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "type", Type = "JailersTowerType", Nilable = false },
			},
		},
		{
			Name = "ScenarioBonusObjectiveComplete",
			Type = "Event",
			LiteralName = "SCENARIO_BONUS_OBJECTIVE_COMPLETE",
			Payload =
			{
				{ Name = "bonusObjectiveID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ScenarioBonusVisibilityUpdate",
			Type = "Event",
			LiteralName = "SCENARIO_BONUS_VISIBILITY_UPDATE",
		},
		{
			Name = "ScenarioCompleted",
			Type = "Event",
			LiteralName = "SCENARIO_COMPLETED",
			Payload =
			{
				{ Name = "questID", Type = "number", Nilable = true },
				{ Name = "xp", Type = "number", Nilable = true },
				{ Name = "money", Type = "number", Nilable = true },
			},
		},
		{
			Name = "ScenarioCriteriaShowStateUpdate",
			Type = "Event",
			LiteralName = "SCENARIO_CRITERIA_SHOW_STATE_UPDATE",
			Payload =
			{
				{ Name = "show", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ScenarioCriteriaUpdate",
			Type = "Event",
			LiteralName = "SCENARIO_CRITERIA_UPDATE",
			Payload =
			{
				{ Name = "criteriaID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ScenarioPoiUpdate",
			Type = "Event",
			LiteralName = "SCENARIO_POI_UPDATE",
		},
		{
			Name = "ScenarioSpellUpdate",
			Type = "Event",
			LiteralName = "SCENARIO_SPELL_UPDATE",
		},
		{
			Name = "ScenarioUpdate",
			Type = "Event",
			LiteralName = "SCENARIO_UPDATE",
			Payload =
			{
				{ Name = "newStep", Type = "bool", Nilable = true },
			},
		},
	},

	Tables =
	{
		{
			Name = "JailersTowerType",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "TwistingCorridors", Type = "JailersTowerType", EnumValue = 0 },
				{ Name = "SkoldusHalls", Type = "JailersTowerType", EnumValue = 1 },
				{ Name = "FractureChambers", Type = "JailersTowerType", EnumValue = 2 },
				{ Name = "Soulforges", Type = "JailersTowerType", EnumValue = 3 },
				{ Name = "Coldheart", Type = "JailersTowerType", EnumValue = 4 },
				{ Name = "Mortregar", Type = "JailersTowerType", EnumValue = 5 },
				{ Name = "UpperReaches", Type = "JailersTowerType", EnumValue = 6 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ScenarioInfo);