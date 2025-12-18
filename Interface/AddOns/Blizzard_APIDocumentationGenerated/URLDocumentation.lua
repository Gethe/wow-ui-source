local URL =
{
	Name = "URL",
	Type = "System",
	Environment = "All",

	Functions =
	{
		{
			Name = "LaunchURL",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "url", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "LoadURLIndex",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
				{ Name = "param", Type = "number", Nilable = true },
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

APIDocumentation:AddDocumentationTable(URL);