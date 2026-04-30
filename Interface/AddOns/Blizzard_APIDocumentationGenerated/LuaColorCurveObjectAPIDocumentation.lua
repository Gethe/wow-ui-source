local LuaColorCurveObjectAPI =
{
	Name = "LuaColorCurveObjectAPI",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "AddPoint",
			Type = "Function",
			Documentation = { "Adds a single point to the curve." },

			Arguments =
			{
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "colorRGBA", Nilable = false },
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
			Documentation = { "Returns a new copy of this curve." },

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "curve", Type = "LuaColorCurveObject", Nilable = false },
			},
		},
		{
			Name = "Evaluate",
			Type = "Function",
			Documentation = { "Returns a calculated color value from the configured curve points." },

			Arguments =
			{
				{ Name = "x", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "y", Type = "colorRGBA", Nilable = false },
			},
		},
		{
			Name = "EvaluateUnpacked",
			Type = "Function",
			Documentation = { "Returns an unpacked calculated color value from the configured curve points." },

			Arguments =
			{
				{ Name = "x", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "yR", Type = "number", Nilable = false },
				{ Name = "yG", Type = "number", Nilable = false },
				{ Name = "yB", Type = "number", Nilable = false },
				{ Name = "yA", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPoint",
			Type = "Function",
			Documentation = { "Returns the vector for an individual point index on the curve." },

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "point", Type = "LuaColorCurvePoint", Nilable = true },
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
				{ Name = "point", Type = "table", InnerType = "LuaColorCurvePoint", Nilable = false },
			},
		},
		{
			Name = "RemovePoint",
			Type = "Function",
			Documentation = { "Removes a single point from the curve. Raises an error if the supplied point index is out of range." },

			Arguments =
			{
				{ Name = "index", Type = "luaIndex", Nilable = false },
			},
		},
		{
			Name = "SetPoints",
			Type = "Function",
			Documentation = { "Replaces all points on the curve." },

			Arguments =
			{
				{ Name = "point", Type = "table", InnerType = "LuaColorCurvePoint", Nilable = false },
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
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "LuaColorCurvePoint",
			Type = "Structure",
			Fields =
			{
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "colorRGBA", Nilable = false },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(LuaColorCurveObjectAPI);