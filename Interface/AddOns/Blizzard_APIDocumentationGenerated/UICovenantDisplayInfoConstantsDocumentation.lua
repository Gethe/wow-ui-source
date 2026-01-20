local UICovenantDisplayInfoConstants =
{
	Tables =
	{
		{
			Name = "UICovenantDisplayInfoFlags",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 1,
			MaxValue = 2,
			Fields =
			{
				{ Name = "DisplayCovenantAsJourney", Type = "UICovenantDisplayInfoFlags", EnumValue = 1 },
				{ Name = "UseJourneyRewardTrack", Type = "UICovenantDisplayInfoFlags", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UICovenantDisplayInfoConstants);