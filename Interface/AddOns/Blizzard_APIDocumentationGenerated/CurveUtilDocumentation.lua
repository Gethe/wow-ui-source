local CurveUtil =
{
	Name = "CurveUtil",
	Type = "System",
	Namespace = "C_CurveUtil",

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