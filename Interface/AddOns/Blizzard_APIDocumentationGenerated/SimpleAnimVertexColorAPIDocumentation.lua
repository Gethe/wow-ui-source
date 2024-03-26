local SimpleAnimVertexColorAPI =
{
	Name = "SimpleAnimVertexColorAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "GetEndColor",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "color", Type = "colorRGBA", Mixin = "ColorMixin", Nilable = false },
			},
		},
		{
			Name = "GetStartColor",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "color", Type = "colorRGBA", Mixin = "ColorMixin", Nilable = false },
			},
		},
		{
			Name = "SetEndColor",
			Type = "Function",

			Arguments =
			{
				{ Name = "color", Type = "colorRGBA", Mixin = "ColorMixin", Nilable = false },
			},
		},
		{
			Name = "SetStartColor",
			Type = "Function",

			Arguments =
			{
				{ Name = "color", Type = "colorRGBA", Mixin = "ColorMixin", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleAnimVertexColorAPI);