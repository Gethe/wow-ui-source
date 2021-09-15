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
		{
			Name = "ConfigurationWarning",
			Type = "Enumeration",
			NumValues = 8,
			MinValue = 0,
			MaxValue = 7,
			Fields =
			{
				{ Name = "ShaderModelWillBeOutdated", Type = "ConfigurationWarning", EnumValue = 0 },
				{ Name = "ShaderModelIsOutdated", Type = "ConfigurationWarning", EnumValue = 1 },
				{ Name = "ConsoleDeviceSseOutdated", Type = "ConfigurationWarning", EnumValue = 2 },
				{ Name = "DriverBlocklisted", Type = "ConfigurationWarning", EnumValue = 3 },
				{ Name = "DriverOutOfDate", Type = "ConfigurationWarning", EnumValue = 4 },
				{ Name = "DeviceBlocklisted", Type = "ConfigurationWarning", EnumValue = 5 },
				{ Name = "GraphicsApiWillBeOutdated", Type = "ConfigurationWarning", EnumValue = 6 },
				{ Name = "OsBitsWillBeOutdated", Type = "ConfigurationWarning", EnumValue = 7 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ConfigurationWarnings);