local ArdenwealdGardening =
{
	Name = "ArdenwealdGardening",
	Type = "System",
	Namespace = "C_ArdenwealdGardening",

	Functions =
	{
		{
			Name = "GetGardenData",
			Type = "Function",

			Returns =
			{
				{ Name = "data", Type = "ArdenwealdGardenData", Nilable = false },
			},
		},
		{
			Name = "IsGardenAccessible",
			Type = "Function",

			Returns =
			{
				{ Name = "accessible", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "ArdenwealdGardenData",
			Type = "Structure",
			Fields =
			{
				{ Name = "active", Type = "number", Nilable = false },
				{ Name = "ready", Type = "number", Nilable = false },
				{ Name = "remainingSeconds", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ArdenwealdGardening);