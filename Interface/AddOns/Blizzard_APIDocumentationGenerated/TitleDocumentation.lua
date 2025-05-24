local Title =
{
	Name = "Title",
	Type = "System",

	Functions =
	{
		{
			Name = "GetCurrentTitle",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetNumTitles",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTitleName",
			Type = "Function",

			Arguments =
			{
				{ Name = "titleMaskID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "titleString", Type = "string", Nilable = false },
				{ Name = "playerTitle", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsTitleKnown",
			Type = "Function",

			Arguments =
			{
				{ Name = "titleMaskID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetCurrentTitle",
			Type = "Function",

			Arguments =
			{
				{ Name = "titleMaskID", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(Title);