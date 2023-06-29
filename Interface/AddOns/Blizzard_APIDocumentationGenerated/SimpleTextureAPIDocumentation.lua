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
				{ Name = "mask", Type = "SimpleMaskTexture", Nilable = false },
			},
		},
		{
			Name = "GetMaskTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "mask", Type = "SimpleMaskTexture", Nilable = false },
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
				{ Name = "count", Type = "size", Nilable = false },
			},
		},
		{
			Name = "RemoveMaskTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "mask", Type = "SimpleMaskTexture", Nilable = false },
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