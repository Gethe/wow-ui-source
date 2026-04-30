local Performance =
{
	Name = "PerformanceScript",
	Type = "System",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetAddOnCPUUsage",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "GetEventCPUUsage",
			Type = "Function",

			Returns =
			{
				{ Name = "call_time", Type = "number", Nilable = false },
				{ Name = "call_count", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetFrameCPUUsage",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "GetFunctionCPUUsage",
			Type = "Function",

			Returns =
			{
				{ Name = "call_time", Type = "number", Nilable = false },
				{ Name = "call_count", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetScriptCPUUsage",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
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
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(Performance);