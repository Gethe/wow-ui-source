local Threat =
{
	Name = "Threat",
	Type = "System",

	Functions =
	{
		{
			Name = "GetThreatStatusColor",
			Type = "Function",

			Arguments =
			{
				{ Name = "gameErrorIndex", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsThreatWarningEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(Threat);