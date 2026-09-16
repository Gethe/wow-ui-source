local WeatherConstants =
{
	Tables =
	{
		{
			Name = "WeatherType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Clear", Type = "WeatherType", EnumValue = 0 },
				{ Name = "Rain", Type = "WeatherType", EnumValue = 1 },
				{ Name = "Snow", Type = "WeatherType", EnumValue = 2 },
				{ Name = "Sandstorm", Type = "WeatherType", EnumValue = 3 },
				{ Name = "Miscellaneous", Type = "WeatherType", EnumValue = 4 },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(WeatherConstants);