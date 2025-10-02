local SummonConstants =
{
	Tables =
	{
		{
			Name = "SummonReason",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Spell", Type = "SummonReason", EnumValue = 0 },
				{ Name = "Scenario", Type = "SummonReason", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SummonConstants);