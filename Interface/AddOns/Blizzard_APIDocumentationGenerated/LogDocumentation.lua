local Log =
{
	Name = "Log",
	Type = "System",
	Namespace = "C_Log",

	Functions =
	{
		{
			Name = "LogErrorMessage",
			Type = "Function",

			Arguments =
			{
				{ Name = "message", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "LogMessage",
			Type = "Function",

			Arguments =
			{
				{ Name = "message", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "LogMessageWithPriority",
			Type = "Function",

			Arguments =
			{
				{ Name = "priority", Type = "LogPriority", Nilable = false },
				{ Name = "message", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "LogWarningMessage",
			Type = "Function",

			Arguments =
			{
				{ Name = "message", Type = "cstring", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Log);