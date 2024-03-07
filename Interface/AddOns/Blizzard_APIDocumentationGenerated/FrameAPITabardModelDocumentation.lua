local FrameAPITabardModel =
{
	Name = "FrameAPITabardModel",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "GetLowerBackgroundFileName",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "path", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetLowerEmblemFileName",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "path", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetUpperBackgroundFileName",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "path", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetUpperEmblemFileName",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "path", Type = "string", Nilable = false },
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

APIDocumentation:AddDocumentationTable(FrameAPITabardModel);