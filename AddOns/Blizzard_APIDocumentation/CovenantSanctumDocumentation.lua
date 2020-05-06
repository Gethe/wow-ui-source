local CovenantSanctum =
{
	Name = "CovenantSanctumUI",
	Type = "System",
	Namespace = "C_CovenantSanctumUI",

	Functions =
	{
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
	},
};

APIDocumentation:AddDocumentationTable(CovenantSanctum);