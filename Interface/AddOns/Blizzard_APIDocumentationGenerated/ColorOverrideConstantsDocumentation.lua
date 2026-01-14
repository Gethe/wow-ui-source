local ColorOverrideConstants =
{
	Tables =
	{
		{
			Name = "ColorOverride",
			Type = "Enumeration",
			NumValues = 8,
			MinValue = 0,
			MaxValue = 7,
			Fields =
			{
				{ Name = "ItemQualityPoor", Type = "ColorOverride", EnumValue = 0 },
				{ Name = "ItemQualityCommon", Type = "ColorOverride", EnumValue = 1 },
				{ Name = "ItemQualityUncommon", Type = "ColorOverride", EnumValue = 2 },
				{ Name = "ItemQualityRare", Type = "ColorOverride", EnumValue = 3 },
				{ Name = "ItemQualityEpic", Type = "ColorOverride", EnumValue = 4 },
				{ Name = "ItemQualityLegendary", Type = "ColorOverride", EnumValue = 5 },
				{ Name = "ItemQualityArtifact", Type = "ColorOverride", EnumValue = 6 },
				{ Name = "ItemQualityAccount", Type = "ColorOverride", EnumValue = 7 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ColorOverrideConstants);