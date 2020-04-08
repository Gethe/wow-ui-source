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