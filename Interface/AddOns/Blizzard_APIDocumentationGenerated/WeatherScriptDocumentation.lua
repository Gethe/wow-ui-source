local WeatherScript =
{
	Name = "WeatherScript",
	Type = "System",
	Namespace = "C_Weather",
	Environment = "All",
	Documentation = { "Cloudy, with a chance of documentation." },

	Functions =
	{
		{
			Name = "GetCurrentWeather",
			Type = "Function",
			Documentation = { "C_Weather the outlook is favorable." },

			Returns =
			{
				{ Name = "info", Type = "WeatherInfo", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "WeatherChanged",
			Type = "Event",
			LiteralName = "WEATHER_CHANGED",
			UniqueEvent = true,
			Documentation = { "The weather has taken a turn." },
		},
	},

	Tables =
	{
		{
			Name = "WeatherInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "type", Type = "WeatherType", Nilable = false, Default = "Clear" },
				{ Name = "intensity", Type = "number", Nilable = false },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(WeatherScript);