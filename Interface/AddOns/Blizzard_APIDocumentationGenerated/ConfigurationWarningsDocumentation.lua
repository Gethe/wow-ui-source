local ConfigurationWarnings =
{
	Name = "ConfigurationWarnings",
	Type = "System",
	Namespace = "C_ConfigurationWarnings",

	Functions =
	{
		{
			Name = "GetConfigurationWarningSeen",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
};

APIDocumentation:AddDocumentationTable(ConfigurationWarnings);