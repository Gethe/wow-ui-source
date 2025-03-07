local WarbandSceneInfoConstants =
{
	Tables =
	{
		{
			Name = "WarbandSceneFlags",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 1,
			MaxValue = 16,
			Fields =
			{
				{ Name = "DoNotInclude", Type = "WarbandSceneFlags", EnumValue = 1 },
				{ Name = "HiddenUntilCollected", Type = "WarbandSceneFlags", EnumValue = 2 },
				{ Name = "CannotBeSaved", Type = "WarbandSceneFlags", EnumValue = 4 },
				{ Name = "AwardedAutomatically", Type = "WarbandSceneFlags", EnumValue = 8 },
				{ Name = "IsDefault", Type = "WarbandSceneFlags", EnumValue = 16 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(WarbandSceneInfoConstants);