local LuaCurveObjectBaseAPI =
{
	Name = "LuaCurveObjectBaseAPI",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetType",
			Type = "Function",
			Documentation = { "Returns the configured type of the curve." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "curveType", Type = "LuaCurveType", Nilable = false },
			},
		},
		{
			Name = "HasSecretValues",
			Type = "Function",
			ReturnsNeverSecret = true,
			Documentation = { "Returns true if the curve has been configured with any secret values. Curves with secret values always produce secret results when evaluated." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "hasSecretValues", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetType",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Changes the evaluation type of the curve." },

			Arguments =
			{
				{ Name = "type", Type = "LuaCurveType", Nilable = false },
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

APIDocumentation:AddDocumentationTable(LuaCurveObjectBaseAPI);