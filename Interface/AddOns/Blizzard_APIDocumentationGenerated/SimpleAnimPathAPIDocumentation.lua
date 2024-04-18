local SimpleAnimPathAPI =
{
	Name = "SimpleAnimPathAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "CreateControlPoint",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = true },
				{ Name = "templateName", Type = "cstring", Nilable = true },
				{ Name = "order", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "point", Type = "SimpleControlPoint", Nilable = false },
			},
		},
		{
			Name = "GetControlPoints",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "scriptObject", Type = "ScriptObject", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "GetCurveType",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "curveType", Type = "CurveType", Nilable = false },
			},
		},
		{
			Name = "GetMaxControlPointOrder",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "maxOrder", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetCurveType",
			Type = "Function",

			Arguments =
			{
				{ Name = "curveType", Type = "CurveType", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleAnimPathAPI);