local ContributionCollector =
{
	Name = "ContributionCollector",
	Type = "System",
	Namespace = "C_ContributionCollector",

	Functions =
	{
	},

	Events =
	{
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