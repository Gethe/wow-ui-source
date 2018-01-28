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
	},
};

APIDocumentation:AddDocumentationTable(ScenarioInfo);