local CovenantSanctum =
{
	Name = "CovenantSanctumUI",
	Type = "System",
	Namespace = "C_CovenantSanctumUI",

	Functions =
	{
		{
			Name = "CanDepositAnima",
			Type = "Function",

			Returns =
			{
				{ Name = "canDeposit", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "DepositAnima",
			Type = "Function",
		},
		{
			Name = "EndInteraction",
			Type = "Function",
		},
		{
			Name = "GetAnimaInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "currencyID", Type = "number", Nilable = false },
				{ Name = "maxDisplayableValue", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetFeatures",
			Type = "Function",

			Returns =
			{
				{ Name = "features", Type = "table", InnerType = "CovenantSanctumFeatureInfo", Nilable = false },
			},
		},
		{
			Name = "GetRenownLevel",
			Type = "Function",

			Returns =
			{
				{ Name = "level", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRenownMilestones",
			Type = "Function",

			Arguments =
			{
				{ Name = "covenantID", Type = "number", Nilable = false },
				{ Name = "renownLevel", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "milestones", Type = "table", InnerType = "CovenantSanctumRenownMilestoneInfo", Nilable = false },
			},
		},
		{
			Name = "GetRenownRewardsForLevel",
			Type = "Function",

			Arguments =
			{
				{ Name = "covenantID", Type = "number", Nilable = false },
				{ Name = "renownLevel", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "rewards", Type = "table", InnerType = "CovenantSanctumRenownRewardInfo", Nilable = false },
			},
		},
		{
			Name = "GetSanctumType",
			Type = "Function",

			Returns =
			{
				{ Name = "sanctumType", Type = "GarrTalentFeatureSubtype", Nilable = true },
			},
		},
		{
			Name = "GetSoulCurrencies",
			Type = "Function",

			Returns =
			{
				{ Name = "currencyIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "CovenantSanctumInteractionEnded",
			Type = "Event",
			LiteralName = "COVENANT_SANCTUM_INTERACTION_ENDED",
		},
		{
			Name = "CovenantSanctumInteractionStarted",
			Type = "Event",
			LiteralName = "COVENANT_SANCTUM_INTERACTION_STARTED",
		},
		{
			Name = "CovenantSanctumRenownLevelChanged",
			Type = "Event",
			LiteralName = "COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED",
			Payload =
			{
				{ Name = "newRenownLevel", Type = "number", Nilable = false },
				{ Name = "oldRenownLevel", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "CovenantSanctumFeatureInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "garrTalentTreeID", Type = "number", Nilable = false },
				{ Name = "featureType", Type = "number", Nilable = false },
				{ Name = "uiOrder", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CovenantSanctumRenownMilestoneInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "locked", Type = "bool", Nilable = false },
				{ Name = "isCapstone", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CovenantSanctumRenownRewardInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "uiOrder", Type = "number", Nilable = false },
				{ Name = "itemID", Type = "number", Nilable = true },
				{ Name = "spellID", Type = "number", Nilable = true },
				{ Name = "mountID", Type = "number", Nilable = true },
				{ Name = "transmogID", Type = "number", Nilable = true },
				{ Name = "transmogSetID", Type = "number", Nilable = true },
				{ Name = "titleID", Type = "number", Nilable = true },
				{ Name = "garrFollowerID", Type = "number", Nilable = true },
				{ Name = "transmogIllusionSourceID", Type = "number", Nilable = true },
				{ Name = "icon", Type = "number", Nilable = true },
				{ Name = "name", Type = "string", Nilable = true },
				{ Name = "description", Type = "string", Nilable = true },
				{ Name = "toastDescription", Type = "string", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CovenantSanctum);