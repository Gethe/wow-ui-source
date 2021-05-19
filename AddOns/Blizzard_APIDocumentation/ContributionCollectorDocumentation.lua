local ContributionCollector =
{
	Name = "ContributionCollector",
	Type = "System",
	Namespace = "C_ContributionCollector",

	Functions =
	{
		{
			Name = "Close",
			Type = "Function",
		},
		{
			Name = "Contribute",
			Type = "Function",

			Arguments =
			{
				{ Name = "contributionID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetActive",
			Type = "Function",

			Returns =
			{
				{ Name = "contributionID", Type = "number", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "GetAtlases",
			Type = "Function",

			Arguments =
			{
				{ Name = "contributionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "atlasName", Type = "table", InnerType = "string", Nilable = false },
			},
		},
		{
			Name = "GetBuffs",
			Type = "Function",

			Arguments =
			{
				{ Name = "contributionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "spellID", Type = "number", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "GetContributionAppearance",
			Type = "Function",

			Arguments =
			{
				{ Name = "contributionID", Type = "number", Nilable = false },
				{ Name = "contributionState", Type = "ContributionState", Nilable = false },
			},

			Returns =
			{
				{ Name = "appearance", Type = "ContributionAppearance", Nilable = true },
			},
		},
		{
			Name = "GetContributionCollectorsForMap",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "contributionCollectors", Type = "table", InnerType = "ContributionMapInfo", Nilable = false },
			},
		},
		{
			Name = "GetContributionResult",
			Type = "Function",

			Arguments =
			{
				{ Name = "contributionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "ContributionResult", Nilable = false },
			},
		},
		{
			Name = "GetDescription",
			Type = "Function",

			Arguments =
			{
				{ Name = "contributionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "description", Type = "string", Nilable = false, Default = "" },
			},
		},
		{
			Name = "GetManagedContributionsForCreatureID",
			Type = "Function",

			Arguments =
			{
				{ Name = "creatureID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "contributionID", Type = "number", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "GetName",
			Type = "Function",

			Arguments =
			{
				{ Name = "contributionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = false, Default = "" },
			},
		},
		{
			Name = "GetOrderIndex",
			Type = "Function",

			Arguments =
			{
				{ Name = "contributionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "orderIndex", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRequiredContributionCurrency",
			Type = "Function",

			Arguments =
			{
				{ Name = "contributionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "currencyID", Type = "number", Nilable = false, Default = 0 },
				{ Name = "currencyAmount", Type = "number", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "GetRequiredContributionItem",
			Type = "Function",

			Arguments =
			{
				{ Name = "contributionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "itemID", Type = "number", Nilable = false, Default = 0 },
				{ Name = "itemCount", Type = "number", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "GetRewardQuestID",
			Type = "Function",

			Arguments =
			{
				{ Name = "contributionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "questID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetState",
			Type = "Function",

			Arguments =
			{
				{ Name = "contributionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "contributionState", Type = "ContributionState", Nilable = false, Default = "None" },
				{ Name = "contributionPercentageComplete", Type = "number", Nilable = false },
				{ Name = "timeOfNextStateChange", Type = "number", Nilable = true },
				{ Name = "startTime", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HasPendingContribution",
			Type = "Function",

			Arguments =
			{
				{ Name = "contributionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasPending", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsAwaitingRewardQuestData",
			Type = "Function",

			Arguments =
			{
				{ Name = "contributionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "awaitingData", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "ContributionChanged",
			Type = "Event",
			LiteralName = "CONTRIBUTION_CHANGED",
			Payload =
			{
				{ Name = "state", Type = "ContributionState", Nilable = false },
				{ Name = "result", Type = "ContributionResult", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "contributionID", Type = "number", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "ContributionCollectorClose",
			Type = "Event",
			LiteralName = "CONTRIBUTION_COLLECTOR_CLOSE",
		},
		{
			Name = "ContributionCollectorOpen",
			Type = "Event",
			LiteralName = "CONTRIBUTION_COLLECTOR_OPEN",
		},
		{
			Name = "ContributionCollectorPending",
			Type = "Event",
			LiteralName = "CONTRIBUTION_COLLECTOR_PENDING",
			Payload =
			{
				{ Name = "contributionID", Type = "number", Nilable = false },
				{ Name = "isPending", Type = "bool", Nilable = false },
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ContributionCollectorUpdate",
			Type = "Event",
			LiteralName = "CONTRIBUTION_COLLECTOR_UPDATE",
		},
		{
			Name = "ContributionCollectorUpdateSingle",
			Type = "Event",
			LiteralName = "CONTRIBUTION_COLLECTOR_UPDATE_SINGLE",
			Payload =
			{
				{ Name = "contributionID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "ContributionAppearanceFlags",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 0,
			MaxValue = 0,
			Fields =
			{
				{ Name = "TooltipUseTimeRemaining", Type = "ContributionAppearanceFlags", EnumValue = 0 },
			},
		},
		{
			Name = "ContributionResult",
			Type = "Enumeration",
			NumValues = 8,
			MinValue = 0,
			MaxValue = 7,
			Fields =
			{
				{ Name = "Success", Type = "ContributionResult", EnumValue = 0 },
				{ Name = "MustBeNearNpc", Type = "ContributionResult", EnumValue = 1 },
				{ Name = "IncorrectState", Type = "ContributionResult", EnumValue = 2 },
				{ Name = "InvalidID", Type = "ContributionResult", EnumValue = 3 },
				{ Name = "QuestDataMissing", Type = "ContributionResult", EnumValue = 4 },
				{ Name = "FailedConditionCheck", Type = "ContributionResult", EnumValue = 5 },
				{ Name = "UnableToCompleteTurnIn", Type = "ContributionResult", EnumValue = 6 },
				{ Name = "InternalError", Type = "ContributionResult", EnumValue = 7 },
			},
		},
		{
			Name = "ContributionAppearance",
			Type = "Structure",
			Fields =
			{
				{ Name = "stateName", Type = "string", Nilable = false },
				{ Name = "stateColor", Type = "table", Mixin = "ColorMixin", Nilable = false },
				{ Name = "tooltipLine", Type = "string", Nilable = false },
				{ Name = "tooltipUseTimeRemaining", Type = "bool", Nilable = false },
				{ Name = "statusBarAtlas", Type = "string", Nilable = false },
				{ Name = "borderAtlas", Type = "string", Nilable = false },
				{ Name = "bannerAtlas", Type = "string", Nilable = false },
			},
		},
		{
			Name = "ContributionMapInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "areaPoiID", Type = "number", Nilable = false },
				{ Name = "position", Type = "table", Mixin = "Vector2DMixin", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "atlasName", Type = "string", Nilable = false },
				{ Name = "collectorCreatureID", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ContributionCollector);