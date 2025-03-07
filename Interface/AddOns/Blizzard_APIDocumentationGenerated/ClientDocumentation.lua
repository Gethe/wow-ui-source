local Client =
{
	Name = "Client",
	Type = "System",

	Functions =
	{
		{
			Name = "FlashClientIcon",
			Type = "Function",

			Arguments =
			{
				{ Name = "briefly", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "GetBillingTimeRested",
			Type = "Function",

			Returns =
			{
				{ Name = "billingTimeRested", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetFileIDFromPath",
			Type = "Function",

			Arguments =
			{
				{ Name = "filePath", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "fileID", Type = "fileID", Nilable = false },
			},
		},
		{
			Name = "GetFramerate",
			Type = "Function",

			Returns =
			{
				{ Name = "framerate", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsCpuBound",
			Type = "Function",

			Returns =
			{
				{ Name = "isCpuBound", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "ReportBug",
			Type = "Function",

			Arguments =
			{
				{ Name = "description", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ReportSuggestion",
			Type = "Function",

			Arguments =
			{
				{ Name = "description", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "RestartGx",
			Type = "Function",
		},
		{
			Name = "Screenshot",
			Type = "Function",
		},
		{
			Name = "UpdateWindow",
			Type = "Function",
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(Client);