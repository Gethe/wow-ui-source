local AddOnProfiler =
{
	Name = "AddOnProfiler",
	Type = "System",
	Namespace = "C_AddOnProfiler",

	Functions =
	{
		{
			Name = "AddMeasuredCallEvent",
			Type = "Function",
			Documentation = { "Adds a measured event to any ongoing measured calls. If no such calls are currently taking place, this function does nothing." },

			Arguments =
			{
				{ Name = "name", Type = "stringView", Nilable = false, Documentation = { "User-defined string describing the measured event. This should be kept under 48 bytes to avoid memory allocations." } },
			},
		},
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
			Name = "GetTicksPerSecond",
			Type = "Function",
			Documentation = { "Returns the number of profiling clock ticks that occur within a single real-time second." },

			Returns =
			{
				{ Name = "frequency", Type = "BigInteger", Nilable = false },
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
		{
			Name = "MeasureCall",
			Type = "Function",
			Documentation = { "Performs a profiled measurement of a single function call with any supplied arguments." },

			Arguments =
			{
				{ Name = "func", Type = "LuaValueVariant", Nilable = false },
				{ Name = "unpackedPrimitiveType", Type = "number", Nilable = false, StrideIndex = 1 },
			},

			Returns =
			{
				{ Name = "results", Type = "AddOnProfilerCallResults", Nilable = false },
				{ Name = "unpackedPrimitiveType", Type = "number", Nilable = false, StrideIndex = 1 },
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
			Name = "AddOnProfilerCallEvent",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false, Documentation = { "User-defined string describing the measured event." } },
				{ Name = "allocatedBytes", Type = "BigUInteger", Nilable = false, Documentation = { "Snapshot of the allocated byte count when this event was recorded." } },
				{ Name = "deallocatedBytes", Type = "BigUInteger", Nilable = false, Documentation = { "Snapshot of the deallocated byte count when this event was recorded." } },
				{ Name = "elapsedMilliseconds", Type = "number", Nilable = false, Documentation = { "Snapshot of the elapsed milliseconds when this event was recorded." } },
				{ Name = "elapsedTicks", Type = "BigInteger", Nilable = false, Documentation = { "Snapshot of the elapsed tick count when this event was recorded." } },
			},
		},
		{
			Name = "AddOnProfilerCallResults",
			Type = "Structure",
			Fields =
			{
				{ Name = "elapsedMilliseconds", Type = "number", Nilable = false, Documentation = { "Total number of milliseconds spent executing the function." } },
				{ Name = "elapsedTicks", Type = "BigInteger", Nilable = false, Documentation = { "Total number of profiling clock ticks spent executing the function." } },
				{ Name = "allocatedBytes", Type = "BigUInteger", Nilable = false, Documentation = { "Total number of bytes allocated during call execution." } },
				{ Name = "deallocatedBytes", Type = "BigUInteger", Nilable = false, Documentation = { "Total number of bytes deallocated during call execution." } },
				{ Name = "events", Type = "table", InnerType = "AddOnProfilerCallEvent", Nilable = false, Documentation = { "Events recorded by any AddMeasuredCallEvent calls that took place during function execution." } },
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