local SimpleLineAPI =
{
	Name = "SimpleLineAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "ClearAllPoints",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "GetEndPoint",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "relativePoint", Type = "FramePoint", Nilable = false },
				{ Name = "relativeTo", Type = "table", Nilable = false },
				{ Name = "offsetX", Type = "number", Nilable = false },
				{ Name = "offsetY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetStartPoint",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "relativePoint", Type = "FramePoint", Nilable = false },
				{ Name = "relativeTo", Type = "table", Nilable = false },
				{ Name = "offsetX", Type = "number", Nilable = false },
				{ Name = "offsetY", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetThickness",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "thickness", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetEndPoint",
			Type = "Function",

			Arguments =
			{
				{ Name = "relativePoint", Type = "FramePoint", Nilable = false },
				{ Name = "relativeTo", Type = "table", Nilable = false },
				{ Name = "offsetX", Type = "number", Nilable = false, Default = 0 },
				{ Name = "offsetY", Type = "number", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "SetStartPoint",
			Type = "Function",

			Arguments =
			{
				{ Name = "relativePoint", Type = "FramePoint", Nilable = false },
				{ Name = "relativeTo", Type = "table", Nilable = false },
				{ Name = "offsetX", Type = "number", Nilable = false, Default = 0 },
				{ Name = "offsetY", Type = "number", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "SetThickness",
			Type = "Function",

			Arguments =
			{
				{ Name = "thickness", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleLineAPI);