local SimpleTextureAPI =
{
	Name = "SimpleTextureAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "AddMaskTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "mask", Type = "table", Nilable = false },
			},
		},
		{
			Name = "GetMaskTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "mask", Type = "table", Nilable = false },
			},
		},
		{
			Name = "GetNumMaskTextures",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "count", Type = "number", Nilable = false },
			},
		},
		{
			Name = "RemoveMaskTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "mask", Type = "table", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleTextureAPI);