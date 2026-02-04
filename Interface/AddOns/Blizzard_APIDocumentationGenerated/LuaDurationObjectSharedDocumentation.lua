local LuaDurationObjectShared =
{
	Tables =
	{
		{
			Name = "DurationTimeModifier",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "RealTime", Type = "DurationTimeModifier", EnumValue = 0, Documentation = { "Use real time for duration calculations. Durations will speed up or slow down based on the applied mod time." } },
				{ Name = "BaseTime", Type = "DurationTimeModifier", EnumValue = 1, Documentation = { "Use base time for duration calculations. Durations will be unaffected the applied mod time." } },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(LuaDurationObjectShared);