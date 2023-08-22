local SimpleAnimScaleAPI =
{
	Name = "SimpleAnimScaleAPI",
	Type = "ScriptObject",

	Functions =
	{
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
			Name = "GetScale",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "scaleX", Type = "number", Nilable = false },
				{ Name = "scaleY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetScaleFrom",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "scaleX", Type = "number", Nilable = false },
				{ Name = "scaleY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetScaleTo",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "scaleX", Type = "number", Nilable = false },
				{ Name = "scaleY", Type = "number", Nilable = false },
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
			Name = "SetScale",
			Type = "Function",

			Arguments =
			{
				{ Name = "scaleX", Type = "number", Nilable = false },
				{ Name = "scaleY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetScaleFrom",
			Type = "Function",

			Arguments =
			{
				{ Name = "scaleX", Type = "number", Nilable = false },
				{ Name = "scaleY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetScaleTo",
			Type = "Function",

			Arguments =
			{
				{ Name = "scaleX", Type = "number", Nilable = false },
				{ Name = "scaleY", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleAnimScaleAPI);