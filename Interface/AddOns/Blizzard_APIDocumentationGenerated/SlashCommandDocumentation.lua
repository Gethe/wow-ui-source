local SlashCommand =
{
	Name = "SlashCommand",
	Type = "System",
	Environment = "All",

	Functions =
	{
		{
			Name = "AreDangerousScriptsAllowed",
			Type = "Function",

			Returns =
			{
				{ Name = "allowed", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetAllowDangerousScripts",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "allowed", Type = "bool", Nilable = false, Default = false },
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

APIDocumentation:AddDocumentationTable(SlashCommand);