local DurationTextBindingShared =
{
	Tables =
	{
		{
			Name = "DurationTextBindingProperty",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "RemainingDuration", Type = "DurationTextBindingProperty", EnumValue = 0 },
				{ Name = "RemainingPercent", Type = "DurationTextBindingProperty", EnumValue = 1 },
				{ Name = "ElapsedDuration", Type = "DurationTextBindingProperty", EnumValue = 2 },
				{ Name = "ElapsedPercent", Type = "DurationTextBindingProperty", EnumValue = 3 },
				{ Name = "TotalDuration", Type = "DurationTextBindingProperty", EnumValue = 4 },
				{ Name = "StartTime", Type = "DurationTextBindingProperty", EnumValue = 5 },
				{ Name = "EndTime", Type = "DurationTextBindingProperty", EnumValue = 6 },
			},
		},
		{
			Name = "DurationTextBindingFormatComponent",
			Type = "Structure",
			Fields =
			{
				{ Name = "property", Type = "DurationTextBindingProperty", Nilable = false, Documentation = { "The duration property sampled for this format component." } },
				{ Name = "formatter", Type = "NumericFormatter", Nilable = false, Documentation = { "The numeric formatter used to convert the sampled duration property into text." } },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(DurationTextBindingShared);