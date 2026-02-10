local UICovenantDisplayInfoConstants =
{
	Tables =
	{
		{
			Name = "UICovenantDisplayInfoFlags",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 1,
			MaxValue = 3,
			Fields =
			{
				{ Name = "DisplayCovenantAsJourney", Type = "UICovenantDisplayInfoFlags", EnumValue = 1 },
				{ Name = "UseJourneyRewardTrack", Type = "UICovenantDisplayInfoFlags", EnumValue = 2 },
				{ Name = "UseJourneyUnlockToastText", Type = "UICovenantDisplayInfoFlags", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UICovenantDisplayInfoConstants);