local UICovenantDisplayInfoConstants =
{
	Tables =
	{
		{
			Name = "UICovenantDisplayInfoFlags",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 1,
			MaxValue = 8,
			Fields =
			{
				{ Name = "DisplayCovenantAsJourney", Type = "UICovenantDisplayInfoFlags", EnumValue = 1 },
				{ Name = "UseJourneyRewardTrack", Type = "UICovenantDisplayInfoFlags", EnumValue = 2 },
				{ Name = "UseJourneyUnlockToastText", Type = "UICovenantDisplayInfoFlags", EnumValue = 4 },
				{ Name = "HideRenownLevelUpToast", Type = "UICovenantDisplayInfoFlags", EnumValue = 8 },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(UICovenantDisplayInfoConstants);