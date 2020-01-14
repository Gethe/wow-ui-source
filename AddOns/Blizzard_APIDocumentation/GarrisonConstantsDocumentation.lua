local GarrisonConstants =
{
	Tables =
	{
		{
			Name = "GarrTalentResearchCostSource",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Talent", Type = "GarrTalentResearchCostSource", EnumValue = 0 },
				{ Name = "Tree", Type = "GarrTalentResearchCostSource", EnumValue = 1 },
			},
		},
		{
			Name = "GarrTalentTreeType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Tiers", Type = "GarrTalentTreeType", EnumValue = 0 },
				{ Name = "Classic", Type = "GarrTalentTreeType", EnumValue = 1 },
			},
		},
		{
			Name = "GarrTalentType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Standard", Type = "GarrTalentType", EnumValue = 0 },
				{ Name = "Minor", Type = "GarrTalentType", EnumValue = 1 },
				{ Name = "Major", Type = "GarrTalentType", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(GarrisonConstants);