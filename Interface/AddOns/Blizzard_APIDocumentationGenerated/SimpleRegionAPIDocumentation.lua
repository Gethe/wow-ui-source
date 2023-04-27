local SimpleRegionAPI =
{
	Name = "SimpleRegionAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "GetAlpha",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "alpha", Type = "SingleColorValue", Nilable = false },
			},
		},
		{
			Name = "GetDrawLayer",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "layer", Type = "DrawLayer", Nilable = false },
				{ Name = "sublayer", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetEffectiveScale",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "effectiveScale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetScale",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "scale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetVertexColor",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "colorA", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsIgnoringParentAlpha",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isIgnoring", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsIgnoringParentScale",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isIgnoring", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsObjectLoaded",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isLoaded", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetAlpha",
			Type = "Function",

			Arguments =
			{
				{ Name = "alpha", Type = "SingleColorValue", Nilable = false },
			},
		},
		{
			Name = "SetDrawLayer",
			Type = "Function",

			Arguments =
			{
				{ Name = "layer", Type = "DrawLayer", Nilable = false },
				{ Name = "sublevel", Type = "number", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "SetIgnoreParentAlpha",
			Type = "Function",

			Arguments =
			{
				{ Name = "ignore", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetIgnoreParentScale",
			Type = "Function",

			Arguments =
			{
				{ Name = "ignore", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetScale",
			Type = "Function",

			Arguments =
			{
				{ Name = "scale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetVertexColor",
			Type = "Function",

			Arguments =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "a", Type = "SingleColorValue", Nilable = true },
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

APIDocumentation:AddDocumentationTable(SimpleRegionAPI);