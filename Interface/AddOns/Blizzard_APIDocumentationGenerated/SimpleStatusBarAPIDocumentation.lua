local SimpleStatusBarAPI =
{
	Name = "SimpleStatusBarAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "GetFillStyle",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "fillStyle", Type = "StatusBarFillStyle", Nilable = false },
			},
		},
		{
			Name = "GetMinMaxValues",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "minValue", Type = "number", Nilable = false },
				{ Name = "maxValue", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetOrientation",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "orientation", Type = "Orientation", Nilable = false },
			},
		},
		{
			Name = "GetReverseFill",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "isReverseFill", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetRotatesTexture",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "rotatesTexture", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetStatusBarColor",
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
			Name = "GetStatusBarDesaturation",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "desaturation", Type = "normalizedValue", Nilable = false },
			},
		},
		{
			Name = "GetStatusBarTexture",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "texture", Type = "SimpleTexture", Nilable = false },
			},
		},
		{
			Name = "GetValue",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "value", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsStatusBarDesaturated",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "desaturated", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetColorFill",
			Type = "Function",

			Arguments =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "a", Type = "SingleColorValue", Nilable = true },
			},
		},
		{
			Name = "SetFillStyle",
			Type = "Function",

			Arguments =
			{
				{ Name = "fillStyle", Type = "StatusBarFillStyle", Nilable = false },
			},
		},
		{
			Name = "SetMinMaxValues",
			Type = "Function",

			Arguments =
			{
				{ Name = "minValue", Type = "number", Nilable = false },
				{ Name = "maxValue", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetOrientation",
			Type = "Function",

			Arguments =
			{
				{ Name = "orientation", Type = "Orientation", Nilable = false },
			},
		},
		{
			Name = "SetReverseFill",
			Type = "Function",

			Arguments =
			{
				{ Name = "isReverseFill", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetRotatesTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "rotatesTexture", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetStatusBarColor",
			Type = "Function",

			Arguments =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "a", Type = "SingleColorValue", Nilable = true },
			},
		},
		{
			Name = "SetStatusBarDesaturated",
			Type = "Function",

			Arguments =
			{
				{ Name = "desaturated", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetStatusBarDesaturation",
			Type = "Function",

			Arguments =
			{
				{ Name = "desaturation", Type = "normalizedValue", Nilable = false },
			},
		},
		{
			Name = "SetStatusBarTexture",
			Type = "Function",

			Arguments =
			{
				{ Name = "asset", Type = "TextureAsset", Nilable = false },
			},
		},
		{
			Name = "SetValue",
			Type = "Function",

			Arguments =
			{
				{ Name = "value", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleStatusBarAPI);