local ScenarioInfo =
{
	Name = "ScenarioInfo",
	Type = "System",
	Namespace = "C_ScenarioInfo",

	Functions =
	{
		{
			Name = "GetJailersTowerTypeString",
			Type = "Function",

			Arguments =
			{
				{ Name = "runType", Type = "JailersTowerType", Nilable = false },
			},

			Returns =
			{
				{ Name = "typeString", Type = "string", Nilable = true },
			},
		},
		{
			Name = "GetScenarioInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "scenarioInfo", Type = "ScenarioInformation", Nilable = false },
			},
		},
		{
			Name = "GetScenarioStepInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "scenarioStepID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "scenarioStepInfo", Type = "ScenarioStepInfo", Nilable = false },
			},
		},
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
			NumValues = 14,
			MinValue = 0,
			MaxValue = 13,
			Fields =
			{
				{ Name = "TwistingCorridors", Type = "JailersTowerType", EnumValue = 0 },
				{ Name = "SkoldusHalls", Type = "JailersTowerType", EnumValue = 1 },
				{ Name = "FractureChambers", Type = "JailersTowerType", EnumValue = 2 },
				{ Name = "Soulforges", Type = "JailersTowerType", EnumValue = 3 },
				{ Name = "Coldheart", Type = "JailersTowerType", EnumValue = 4 },
				{ Name = "Mortregar", Type = "JailersTowerType", EnumValue = 5 },
				{ Name = "UpperReaches", Type = "JailersTowerType", EnumValue = 6 },
				{ Name = "ArkobanHall", Type = "JailersTowerType", EnumValue = 7 },
				{ Name = "TormentChamberJaina", Type = "JailersTowerType", EnumValue = 8 },
				{ Name = "TormentChamberThrall", Type = "JailersTowerType", EnumValue = 9 },
				{ Name = "TormentChamberAnduin", Type = "JailersTowerType", EnumValue = 10 },
				{ Name = "AdamantVaults", Type = "JailersTowerType", EnumValue = 11 },
				{ Name = "ForgottenCatacombs", Type = "JailersTowerType", EnumValue = 12 },
				{ Name = "Ossuary", Type = "JailersTowerType", EnumValue = 13 },
			},
		},
		{
			Name = "ScenarioInformation",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "currentStage", Type = "number", Nilable = false },
				{ Name = "numStages", Type = "number", Nilable = false },
				{ Name = "flags", Type = "number", Nilable = false },
				{ Name = "isComplete", Type = "bool", Nilable = false },
				{ Name = "xp", Type = "number", Nilable = false },
				{ Name = "money", Type = "number", Nilable = false },
				{ Name = "type", Type = "number", Nilable = false },
				{ Name = "area", Type = "string", Nilable = false },
				{ Name = "uiTextureKit", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ScenarioStepInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "title", Type = "string", Nilable = false },
				{ Name = "description", Type = "string", Nilable = false },
				{ Name = "numCriteria", Type = "number", Nilable = false },
				{ Name = "stepFailed", Type = "bool", Nilable = false },
				{ Name = "isBonusStep", Type = "bool", Nilable = false },
				{ Name = "isForCurrentStepOnly", Type = "bool", Nilable = false },
				{ Name = "shouldShowBonusObjective", Type = "bool", Nilable = false },
				{ Name = "spells", Type = "table", InnerType = "ScenarioStepSpellInfo", Nilable = false },
				{ Name = "weightedProgress", Type = "number", Nilable = true },
				{ Name = "rewardQuestID", Type = "number", Nilable = false },
				{ Name = "widgetSetID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "ScenarioStepSpellInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "icon", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ScenarioInfo);