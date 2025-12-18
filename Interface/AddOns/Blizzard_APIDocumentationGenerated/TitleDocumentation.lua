local Title =
{
	Name = "Title",
	Type = "System",
	Environment = "All",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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