local SimpleRegionAPI =
{
	Name = "SimpleRegionAPI",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetAlpha",
			Type = "Function",
			SecretReturnsForAspect = { Enum.SecretAspect.Alpha },

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
			SecretReturnsForAspect = { Enum.SecretAspect.Scale },

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
			SecretReturnsForAspect = { Enum.SecretAspect.Scale },

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
			MayReturnNothing = true,
			SecretReturnsForAspect = { Enum.SecretAspect.VertexColor, Enum.SecretAspect.Alpha },

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
			SecretArgumentsAddAspect = { Enum.SecretAspect.Alpha },
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "alpha", Type = "SingleColorValue", Nilable = false },
			},
		},
		{
			Name = "SetAlphaFromBoolean",
			Type = "Function",
			SecretArgumentsAddAspect = { Enum.SecretAspect.Alpha },
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "value", Type = "bool", Nilable = false },
				{ Name = "alphaIfTrue", Type = "SingleColorValue", Nilable = false, Default = 255 },
				{ Name = "alphaIfFalse", Type = "SingleColorValue", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "SetDrawLayer",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "layer", Type = "DrawLayer", Nilable = false },
				{ Name = "sublevel", Type = "number", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "SetIgnoreParentAlpha",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "ignore", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetIgnoreParentScale",
			Type = "Function",
			IsProtectedFunction = true,
			SecretArguments = "NotAllowed",

			Arguments =
			{
				{ Name = "ignore", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetScale",
			Type = "Function",
			IsProtectedFunction = true,
			SecretArgumentsAddAspect = { Enum.SecretAspect.Scale },
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "scale", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetVertexColor",
			Type = "Function",
			SecretArgumentsAddAspect = { Enum.SecretAspect.VertexColor, Enum.SecretAspect.Alpha },
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "a", Type = "SingleColorValue", Nilable = true },
			},
		},
		{
			Name = "SetVertexColorFromBoolean",
			Type = "Function",
			SecretArgumentsAddAspect = { Enum.SecretAspect.VertexColor, Enum.SecretAspect.Alpha },
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "value", Type = "bool", Nilable = false },
				{ Name = "colorIfTrue", Type = "colorRGBA", Mixin = "ColorMixin", Nilable = false },
				{ Name = "colorIfFalse", Type = "colorRGBA", Mixin = "ColorMixin", Nilable = false },
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