local Performance =
{
	Name = "PerformanceScript",
	Type = "System",

	Functions =
	{
		{
			Name = "GetAddOnCPUUsage",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetAddOnMemoryUsage",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "uiAddon", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetFrameCPUUsage",
			Type = "Function",

			Arguments =
			{
				{ Name = "frame", Type = "SimpleFrame", Nilable = false },
				{ Name = "includeChildren", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "call_time", Type = "number", Nilable = false },
				{ Name = "call_count", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ResetCPUUsage",
			Type = "Function",
		},
		{
			Name = "UpdateAddOnCPUUsage",
			Type = "Function",
		},
		{
			Name = "UpdateAddOnMemoryUsage",
			Type = "Function",
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Performance);