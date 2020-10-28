local Covenants =
{
	Name = "Covenant",
	Type = "System",
	Namespace = "C_Covenants",

	Functions =
	{
		{
			Name = "GetActiveCovenantID",
			Type = "Function",

			Returns =
			{
				{ Name = "covenantID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetCovenantData",
			Type = "Function",

			Arguments =
			{
				{ Name = "covenantID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "data", Type = "CovenantData", Nilable = true },
			},
		},
		{
			Name = "GetCovenantIDs",
			Type = "Function",

			Returns =
			{
				{ Name = "covenantID", Type = "table", InnerType = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "CovenantChosen",
			Type = "Event",
			LiteralName = "COVENANT_CHOSEN",
			Payload =
			{
				{ Name = "covenantID", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "CovenantData",
			Type = "Structure",
			Fields =
			{
				{ Name = "ID", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "string", Nilable = false },
				{ Name = "celebrationSoundKit", Type = "number", Nilable = false },
				{ Name = "animaChannelSelectSoundKit", Type = "number", Nilable = false },
				{ Name = "animaChannelActiveSoundKit", Type = "number", Nilable = false },
				{ Name = "animaGemsFullSoundKit", Type = "number", Nilable = false },
				{ Name = "animaNewGemSoundKit", Type = "number", Nilable = false },
				{ Name = "animaReinforceSelectSoundKit", Type = "number", Nilable = false },
				{ Name = "upgradeTabSelectSoundKitID", Type = "number", Nilable = false },
				{ Name = "reservoirFullSoundKitID", Type = "number", Nilable = false },
				{ Name = "beginResearchSoundKitID", Type = "number", Nilable = false },
				{ Name = "renownFanfareSoundKitID", Type = "number", Nilable = false },
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "soulbindIDs", Type = "table", InnerType = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Covenants);