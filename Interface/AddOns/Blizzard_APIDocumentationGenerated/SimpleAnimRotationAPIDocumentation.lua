local SimpleAnimRotationAPI =
{
	Name = "SimpleAnimRotationAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "GetDegrees",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "angle", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetOrigin",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "point", Type = "FramePoint", Nilable = false },
				{ Name = "originX", Type = "number", Nilable = false },
				{ Name = "originY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetRadians",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "angle", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetDegrees",
			Type = "Function",

			Arguments =
			{
				{ Name = "angle", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetOrigin",
			Type = "Function",

			Arguments =
			{
				{ Name = "point", Type = "FramePoint", Nilable = false },
				{ Name = "originX", Type = "number", Nilable = false },
				{ Name = "originY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetRadians",
			Type = "Function",

			Arguments =
			{
				{ Name = "angle", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleAnimRotationAPI);