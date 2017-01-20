local ContributionCollectorLua =
{
	Name = "ContributionCollector",
	Namespace = "C_ContributionCollector",

	Functions =
	{
		{
			Name = "CanContribute",

			Arguments =
			{
				{ Name = "contributionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "Close",
		},
		{
			Name = "Contribute",

			Arguments =
			{
				{ Name = "contributionID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetActive",

			Returns =
			{
				{ Name = "contributionID", Type = "number", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "GetAtlases",

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
			Name = "GetDescription",

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
			Name = "GetRequiredContributionAmount",

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
			Name = "GetRewardQuestID",

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

			Arguments =
			{
				{ Name = "contributionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "contributionState", Type = "number", Nilable = false },
				{ Name = "contributionPercentageComplete", Type = "number", Nilable = false },
			},
		},
		{
			Name = "HasPendingContribution",

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

			Arguments =
			{
				{ Name = "contributionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "awaitingData", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsBuffActive",

			Arguments =
			{
				{ Name = "contributionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isActive", Type = "bool", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(ContributionCollectorLua);