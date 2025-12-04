local LuaCurveObjectAPI =
{
	Name = "LuaCurveObjectAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "AddPoint",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Adds a single point to the curve." },

			Arguments =
			{
				{ Name = "pointX", Type = "number", Nilable = false },
				{ Name = "pointY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ClearPoints",
			Type = "Function",
			Documentation = { "Removes all points from the curve. Evaluating an empty curve always yields a zero value." },

			Arguments =
			{
			},
		},
		{
			Name = "Copy",
			Type = "Function",
			ReturnsNeverSecret = true,
			Documentation = { "Returns a new copy of this curve." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "curve", Type = "LuaCurveObject", Nilable = false },
			},
		},
		{
			Name = "Evaluate",
			Type = "Function",
			ConstSecretAccessor = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns a calculated 'y' value from the configured curve points." },

			Arguments =
			{
				{ Name = "x", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "y", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPoint",
			Type = "Function",
			ConstSecretAccessor = true,
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Returns the vector for an individual point index on the curve." },

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "point", Type = "vector2", Mixin = "Vector2DMixin", Nilable = true },
			},
		},
		{
			Name = "GetPointCount",
			Type = "Function",
			Documentation = { "Returns the total number of points on the curve." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "count", Type = "size", Nilable = false },
			},
		},
		{
			Name = "GetPoints",
			Type = "Function",
			Documentation = { "Returns the vectors for all points on the curve." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "point", Type = "table", InnerType = "vector2", Nilable = false },
			},
		},
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
			Name = "RemovePoint",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Removes a single point from the curve. Raises an error if the supplied point index is out of range." },

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "SetPoints",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Replaces all points on the curve." },

			Arguments =
			{
				{ Name = "point", Type = "table", InnerType = "vector2", Nilable = false },
			},
		},
		{
			Name = "SetToDefaults",
			Type = "Function",
			Documentation = { "Resets all state on the curve, and clears the secret values flag." },

			Arguments =
			{
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

APIDocumentation:AddDocumentationTable(LuaCurveObjectAPI);