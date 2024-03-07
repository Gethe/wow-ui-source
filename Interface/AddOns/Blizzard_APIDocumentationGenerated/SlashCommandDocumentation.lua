local SlashCommand =
{
	Name = "SlashCommand",
	Type = "System",

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