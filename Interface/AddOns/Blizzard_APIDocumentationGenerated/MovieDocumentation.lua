local Movie =
{
	Name = "Movie",
	Type = "System",

	Functions =
	{
		{
			Name = "CancelPreloadingMovie",
			Type = "Function",

			Arguments =
			{
				{ Name = "movieId", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMovieDownloadProgress",
			Type = "Function",

			Arguments =
			{
				{ Name = "movieId", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "inProgress", Type = "bool", Nilable = false },
				{ Name = "downloaded", Type = "BigUInteger", Nilable = false },
				{ Name = "total", Type = "BigUInteger", Nilable = false },
			},
		},
		{
			Name = "IsMovieLocal",
			Type = "Function",

			Arguments =
			{
				{ Name = "movieId", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isLocal", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMoviePlayable",
			Type = "Function",

			Arguments =
			{
				{ Name = "movieId", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isPlayable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMovieReadable",
			Type = "Function",

			Arguments =
			{
				{ Name = "movieId", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "readable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PreloadMovie",
			Type = "Function",

			Arguments =
			{
				{ Name = "movieId", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(Movie);