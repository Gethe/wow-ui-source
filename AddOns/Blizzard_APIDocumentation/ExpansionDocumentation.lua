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
			Name = "GetCurrentRegionName",
			Type = "Function",

			Returns =
			{
				{ Name = "regionName", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetExpansionDisplayInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "expansionLevel", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "ExpansionDisplayInfo", Nilable = true },
			},
		},
		{
			Name = "GetExpansionForLevel",
			Type = "Function",

			Arguments =
			{
				{ Name = "playerLevel", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "expansionLevel", Type = "number", Nilable = false },
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
				{ Name = "expansionTrialRemainingSeconds", Type = "number", Nilable = true },
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
			Name = "GetMaxLevelForLatestExpansion",
			Type = "Function",

			Returns =
			{
				{ Name = "maxLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMaxLevelForPlayerExpansion",
			Type = "Function",

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
		{
			Name = "SendSubscriptionInterstitialResponse",
			Type = "Function",

			Arguments =
			{
				{ Name = "response", Type = "SubscriptionInterstitialResponseType", Nilable = false },
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
		{
			Name = "ShowSubscriptionInterstitial",
			Type = "Event",
			LiteralName = "SHOW_SUBSCRIPTION_INTERSTITIAL",
			Payload =
			{
				{ Name = "type", Type = "SubscriptionInterstitialType", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "SubscriptionInterstitialResponseType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Clicked", Type = "SubscriptionInterstitialResponseType", EnumValue = 0 },
				{ Name = "Closed", Type = "SubscriptionInterstitialResponseType", EnumValue = 1 },
				{ Name = "WebRedirect", Type = "SubscriptionInterstitialResponseType", EnumValue = 2 },
			},
		},
		{
			Name = "SubscriptionInterstitialType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Standard", Type = "SubscriptionInterstitialType", EnumValue = 0 },
				{ Name = "LeftNpeArea", Type = "SubscriptionInterstitialType", EnumValue = 1 },
				{ Name = "MaxLevel", Type = "SubscriptionInterstitialType", EnumValue = 2 },
			},
		},
		{
			Name = "ExpansionDisplayInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "logo", Type = "number", Nilable = false },
				{ Name = "banner", Type = "string", Nilable = false },
				{ Name = "features", Type = "table", InnerType = "ExpansionDisplayInfoFeature", Nilable = false },
			},
		},
		{
			Name = "ExpansionDisplayInfoFeature",
			Type = "Structure",
			Fields =
			{
				{ Name = "icon", Type = "number", Nilable = false },
				{ Name = "text", Type = "string", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Expansion);