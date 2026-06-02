local ConfigurationWarnings =
{
	Name = "ConfigurationWarnings",
	Type = "System",
	Namespace = "C_ConfigurationWarnings",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetConfigurationWarningSeen",
			Type = "Function",

			Arguments =
			{
				{ Name = "configurationWarning", Type = "ConfigurationWarning", Nilable = false },
			},

			Returns =
			{
				{ Name = "hasSeenConfigurationWarning", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetConfigurationWarningString",
			Type = "Function",
			MayReturnNothing = true,

			Arguments =
			{
				{ Name = "configurationWarning", Type = "ConfigurationWarning", Nilable = false },
			},

			Returns =
			{
				{ Name = "configurationWarningString", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetConfigurationWarnings",
			Type = "Function",

			Arguments =
			{
				{ Name = "includeSeenWarnings", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "configurationWarnings", Type = "table", InnerType = "ConfigurationWarning", Nilable = false },
			},
		},
		{
			Name = "SetConfigurationWarningSeen",
			Type = "Function",

			Arguments =
			{
				{ Name = "configurationWarning", Type = "ConfigurationWarning", Nilable = false },
			},
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

APIDocumentation:AddDocumentationTable(ConfigurationWarnings);