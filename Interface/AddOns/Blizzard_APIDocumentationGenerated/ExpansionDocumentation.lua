local Expansion =
{
	Name = "Expansion",
	Type = "System",

	Functions =
	{
		{
			Name = "CanUpgradeExpansion",
			Type = "Function",

			Returns =
			{
				{ Name = "canUpgradeExpansion", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "DoesCurrentLocaleSellExpansionLevels",
			Type = "Function",

			Returns =
			{
				{ Name = "regionSellsExpansions", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetAccountExpansionLevel",
			Type = "Function",

			Returns =
			{
				{ Name = "expansionLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetClientDisplayExpansionLevel",
			Type = "Function",

			Returns =
			{
				{ Name = "expansionLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetExpansionDisplayInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "expansionLevel", Type = "number", Nilable = false },
				{ Name = "desiredReleaseType", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "ExpansionDisplayInfo", Nilable = true },
			},
		},
		{
			Name = "GetExpansionLevel",
			Type = "Function",

			Returns =
			{
				{ Name = "expansionLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetExpansionTrialInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "isExpansionTrialAccount", Type = "bool", Nilable = false },
				{ Name = "expansionTrialRemainingSeconds", Type = "time_t", Nilable = true },
			},
		},
		{
			Name = "GetMaxLevelForExpansionLevel",
			Type = "Function",
			Documentation = { "Maps an expansion level to a maximum character level for that expansion." },

			Arguments =
			{
				{ Name = "expansionLevel", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "maxLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMaximumExpansionLevel",
			Type = "Function",

			Returns =
			{
				{ Name = "expansionLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMinimumExpansionLevel",
			Type = "Function",

			Returns =
			{
				{ Name = "expansionLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumExpansions",
			Type = "Function",

			Returns =
			{
				{ Name = "numExpansions", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetServerExpansionLevel",
			Type = "Function",

			Returns =
			{
				{ Name = "serverExpansionLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsExpansionTrial",
			Type = "Function",

			Returns =
			{
				{ Name = "isExpansionTrialAccount", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsTrialAccount",
			Type = "Function",

			Returns =
			{
				{ Name = "isTrialAccount", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsVeteranTrialAccount",
			Type = "Function",

			Returns =
			{
				{ Name = "isVeteranTrialAccount", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "MaxExpansionLevelUpdated",
			Type = "Event",
			LiteralName = "MAX_EXPANSION_LEVEL_UPDATED",
		},
		{
			Name = "MinExpansionLevelUpdated",
			Type = "Event",
			LiteralName = "MIN_EXPANSION_LEVEL_UPDATED",
		},
	},

	Tables =
	{
		{
			Name = "ExpansionDisplayInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "logo", Type = "fileID", Nilable = false },
				{ Name = "banner", Type = "textureAtlas", Nilable = false },
				{ Name = "features", Type = "table", InnerType = "ExpansionDisplayInfoFeature", Nilable = false },
			},
		},
		{
			Name = "ExpansionDisplayInfoFeature",
			Type = "Structure",
			Fields =
			{
				{ Name = "icon", Type = "fileID", Nilable = false },
				{ Name = "text", Type = "cstring", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Expansion);