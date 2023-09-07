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
			Name = "ClearTextureSlice",
			Type = "Function",

			Arguments =
			{
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
			Name = "GetTextureSliceMargins",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "left", Type = "number", Nilable = false },
				{ Name = "top", Type = "number", Nilable = false },
				{ Name = "right", Type = "number", Nilable = false },
				{ Name = "bottom", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetTextureSliceMode",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "sliceMode", Type = "UITextureSliceMode", Nilable = false },
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
		{
			Name = "SetTextureSliceMargins",
			Type = "Function",

			Arguments =
			{
				{ Name = "left", Type = "number", Nilable = false },
				{ Name = "top", Type = "number", Nilable = false },
				{ Name = "right", Type = "number", Nilable = false },
				{ Name = "bottom", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetTextureSliceMode",
			Type = "Function",

			Arguments =
			{
				{ Name = "sliceMode", Type = "UITextureSliceMode", Nilable = false },
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