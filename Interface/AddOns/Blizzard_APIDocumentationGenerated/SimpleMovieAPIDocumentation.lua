local SimpleMovieAPI =
{
	Name = "SimpleMovieAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "EnableSubtitles",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "enable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "StartMovie",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "movieID", Type = "number", Nilable = false },
				{ Name = "looping", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
				{ Name = "returnCode", Type = "number", Nilable = false },
			},
		},
		{
			Name = "StartMovieByName",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "movieName", Type = "cstring", Nilable = false },
				{ Name = "looping", Type = "bool", Nilable = false, Default = false },
				{ Name = "resolution", Type = "number", Nilable = false, Default = 0 },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
				{ Name = "returnCode", Type = "number", Nilable = false },
			},
		},
		{
			Name = "StopMovie",
			Type = "Function",

			Arguments =
			{
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

APIDocumentation:AddDocumentationTable(SimpleMovieAPI);