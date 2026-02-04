local Log =
{
	Name = "Log",
	Type = "System",
	Namespace = "C_Log",
	Environment = "All",

	Functions =
	{
		{
			Name = "LogErrorMessage",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "message", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "LogMessage",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "message", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "LogMessageWithPriority",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "priority", Type = "LogPriority", Nilable = false },
				{ Name = "message", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "LogWarningMessage",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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