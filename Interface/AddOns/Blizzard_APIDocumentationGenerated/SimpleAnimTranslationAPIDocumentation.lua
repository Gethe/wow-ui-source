local SimpleAnimTranslationAPI =
{
	Name = "SimpleAnimTranslationAPI",
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
				{ Name = "offsetX", Type = "uiUnit", Nilable = false },
				{ Name = "offsetY", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "SetOffset",
			Type = "Function",

			Arguments =
			{
				{ Name = "offsetX", Type = "uiUnit", Nilable = false },
				{ Name = "offsetY", Type = "uiUnit", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleAnimTranslationAPI);