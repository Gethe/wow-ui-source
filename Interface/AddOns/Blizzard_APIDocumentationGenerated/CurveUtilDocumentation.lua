local CurveUtil =
{
	Name = "CurveUtil",
	Type = "System",
	Namespace = "C_CurveUtil",
	Environment = "All",

	Functions =
	{
		{
			Name = "CreateColorCurve",
			Type = "Function",
			Documentation = { "Returns a new color curve object with no assigned points." },

			Returns =
			{
				{ Name = "curve", Type = "LuaColorCurveObject", Nilable = false },
			},
		},
		{
			Name = "CreateCurve",
			Type = "Function",
			Documentation = { "Returns a new curve object with no assigned points." },

			Returns =
			{
				{ Name = "curve", Type = "LuaCurveObject", Nilable = false },
			},
		},
		{
			Name = "EvaluateColorFromBoolean",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",
			Documentation = { "Evaluates a potentially-secret boolean value and returns a color." },

			Arguments =
			{
				{ Name = "boolean", Type = "bool", Nilable = false },
				{ Name = "valueIfTrue", Type = "colorRGBA", Mixin = "ColorMixin", Nilable = false },
				{ Name = "valueIfFalse", Type = "colorRGBA", Mixin = "ColorMixin", Nilable = false },
			},

			Returns =
			{
				{ Name = "value", Type = "colorRGBA", Mixin = "ColorMixin", Nilable = false },
			},
		},
		{
			Name = "EvaluateColorValueFromBoolean",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",
			Documentation = { "Evaluates a potentially-secret boolean value and returns a single color component (eg. alpha)." },

			Arguments =
			{
				{ Name = "boolean", Type = "bool", Nilable = false },
				{ Name = "valueIfTrue", Type = "SingleColorValue", Nilable = false },
				{ Name = "valueIfFalse", Type = "SingleColorValue", Nilable = false },
			},

			Returns =
			{
				{ Name = "value", Type = "SingleColorValue", Nilable = false },
			},
		},
		{
			Name = "EvaluateGameCurve",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "curveID", Type = "number", Nilable = false },
				{ Name = "x", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "y", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(CurveUtil);