local AddOnProfilerConstants =
{
	Tables =
	{
		{
			Name = "AddOnPerformanceMessageType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "SpecificAddOnChatWarning", Type = "AddOnPerformanceMessageType", EnumValue = 0, Documentation = { "Warning in chat when an AddOn is close to exceeding thresholds." } },
				{ Name = "SpecificAddOnErrorDialog", Type = "AddOnPerformanceMessageType", EnumValue = 1, Documentation = { "Error message modal dialog when an AddOn has exceeded thresholds." } },
				{ Name = "OverallAddOnErrorDialog", Type = "AddOnPerformanceMessageType", EnumValue = 2, Documentation = { "Error message modal dialog when all AddOns combined have exceeded thresholds." } },
			},
		},
		{
			Name = "AddOnProfilerMetric",
			Type = "Enumeration",
			NumValues = 12,
			MinValue = 0,
			MaxValue = 11,
			Fields =
			{
				{ Name = "SessionAverageTime", Type = "AddOnProfilerMetric", EnumValue = 0, Documentation = { "Average time since application startup" } },
				{ Name = "RecentAverageTime", Type = "AddOnProfilerMetric", EnumValue = 1, Documentation = { "Average time over the last 60 ticks" } },
				{ Name = "EncounterAverageTime", Type = "AddOnProfilerMetric", EnumValue = 2, Documentation = { "Average time over the duration of a boss encounter" } },
				{ Name = "LastTime", Type = "AddOnProfilerMetric", EnumValue = 3, Documentation = { "Total time in the most recent tick" } },
				{ Name = "PeakTime", Type = "AddOnProfilerMetric", EnumValue = 4, Documentation = { "Highest time recorded since application startup" } },
				{ Name = "CountTimeOver1Ms", Type = "AddOnProfilerMetric", EnumValue = 5, Documentation = { "Number of ticks where time exceeded 1ms" } },
				{ Name = "CountTimeOver5Ms", Type = "AddOnProfilerMetric", EnumValue = 6, Documentation = { "Number of ticks where time exceeded 5ms" } },
				{ Name = "CountTimeOver10Ms", Type = "AddOnProfilerMetric", EnumValue = 7, Documentation = { "Number of ticks where time exceeded 10ms" } },
				{ Name = "CountTimeOver50Ms", Type = "AddOnProfilerMetric", EnumValue = 8, Documentation = { "Number of ticks where time exceeded 50ms" } },
				{ Name = "CountTimeOver100Ms", Type = "AddOnProfilerMetric", EnumValue = 9, Documentation = { "Number of ticks where time exceeded 100ms" } },
				{ Name = "CountTimeOver500Ms", Type = "AddOnProfilerMetric", EnumValue = 10, Documentation = { "Number of ticks where time exceeded 500ms" } },
				{ Name = "CountTimeOver1000Ms", Type = "AddOnProfilerMetric", EnumValue = 11, Documentation = { "Number of ticks where time exceeded 1000ms" } },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(AddOnProfilerConstants);