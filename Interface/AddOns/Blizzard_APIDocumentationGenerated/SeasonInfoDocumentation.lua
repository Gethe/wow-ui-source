local SeasonInfo =
{
	Name = "SeasonInfo",
	Type = "System",
	Namespace = "C_SeasonInfo",

	Functions =
	{
		{
			Name = "GetCurrentDisplaySeasonExpansion",
			Type = "Function",

			Returns =
			{
				{ Name = "expansionID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetCurrentDisplaySeasonID",
			Type = "Function",

			Returns =
			{
				{ Name = "seasonID", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SeasonInfo);