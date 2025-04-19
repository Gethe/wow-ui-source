local AddOnProfiler =
{
	Name = "AddOnProfiler",
	Type = "System",
	Namespace = "C_AddOnProfiler",

	Functions =
	{
		{
			Name = "AddPerformanceMessageShown",
			Type = "Function",
			Documentation = { "Internal API for telemetry." },

			Arguments =
			{
				{ Name = "msg", Type = "AddOnPerformanceMessage", Nilable = false },
			},
		},
		{
			Name = "CheckForPerformanceMessage",
			Type = "Function",
			MayReturnNothing = true,
			Documentation = { "Optimized check for determining if AddOns are severely impacting UI performance." },

			Returns =
			{
				{ Name = "msg", Type = "AddOnPerformanceMessage", Nilable = false },
			},
		},
		{
			Name = "GetAddOnMetric",
			Type = "Function",
			Documentation = { "Gets an AddOn profiler value - all times returned are in milliseconds." },

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "metric", Type = "AddOnProfilerMetric", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetApplicationMetric",
			Type = "Function",
			Documentation = { "Overall profiling data for the entire application (not just the UI)" },

			Arguments =
			{
				{ Name = "metric", Type = "AddOnProfilerMetric", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetOverallMetric",
			Type = "Function",
			Documentation = { "Overall profiling data for all addons" },

			Arguments =
			{
				{ Name = "metric", Type = "AddOnProfilerMetric", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTopKAddOnsForMetric",
			Type = "Function",
			Documentation = { "Gets top K AddOns for a given metric." },

			Arguments =
			{
				{ Name = "metric", Type = "AddOnProfilerMetric", Nilable = false },
				{ Name = "k", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "results", Type = "table", InnerType = "AddOnProfilerResult", Nilable = false },
			},
		},
		{
			Name = "IsEnabled",
			Type = "Function",
			Documentation = { "AddOn profiler will be enabled for all users, but this will return false if it ever isn't" },

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "AddOnPerformanceMessage",
			Type = "Structure",
			Fields =
			{
				{ Name = "type", Type = "AddOnPerformanceMessageType", Nilable = false },
				{ Name = "metric", Type = "AddOnProfilerMetric", Nilable = false },
				{ Name = "addOnName", Type = "string", Nilable = true },
				{ Name = "metricValue", Type = "number", Nilable = false },
				{ Name = "thresholdValue", Type = "number", Nilable = false },
			},
		},
		{
			Name = "AddOnProfilerResult",
			Type = "Structure",
			Fields =
			{
				{ Name = "addOnName", Type = "cstring", Nilable = false },
				{ Name = "metricValue", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(AddOnProfiler);