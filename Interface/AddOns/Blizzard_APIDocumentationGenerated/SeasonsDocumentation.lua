local Seasons =
{
	Name = "SeasonsScripts",
	Type = "System",
	Namespace = "C_Seasons",

	Functions =
	{
		{
			Name = "GetActiveSeason",
			Type = "Function",

			Returns =
			{
				{ Name = "seasonID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "HasActiveSeason",
			Type = "Function",

			Returns =
			{
				{ Name = "value", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(Seasons);