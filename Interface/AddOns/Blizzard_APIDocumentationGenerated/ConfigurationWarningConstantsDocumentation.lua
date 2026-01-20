local ConfigurationWarningConstants =
{
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

APIDocumentation:AddDocumentationTable(ConfigurationWarningConstants);