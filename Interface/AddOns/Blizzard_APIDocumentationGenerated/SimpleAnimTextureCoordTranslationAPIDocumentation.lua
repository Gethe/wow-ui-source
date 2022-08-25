local SimpleAnimTextureCoordTranslationAPI =
{
	Name = "SimpleAnimTextureCoordTranslationAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "GetOffset",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "offsetU", Type = "number", Nilable = false },
				{ Name = "offsetV", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetOffset",
			Type = "Function",

			Arguments =
			{
				{ Name = "offsetU", Type = "number", Nilable = false },
				{ Name = "offsetV", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleAnimTextureCoordTranslationAPI);