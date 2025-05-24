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
				{ Name = "relativeTo", Type = "ScriptRegion", Nilable = false },
				{ Name = "offsetX", Type = "uiUnit", Nilable = false },
				{ Name = "offsetY", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "GetHitRectThickness",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "thickness", Type = "uiUnit", Nilable = false },
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
				{ Name = "relativeTo", Type = "ScriptRegion", Nilable = false },
				{ Name = "offsetX", Type = "uiUnit", Nilable = false },
				{ Name = "offsetY", Type = "uiUnit", Nilable = false },
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
				{ Name = "thickness", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "SetEndPoint",
			Type = "Function",

			Arguments =
			{
				{ Name = "relativePoint", Type = "FramePoint", Nilable = false },
				{ Name = "relativeTo", Type = "ScriptRegion", Nilable = false },
				{ Name = "offsetX", Type = "uiUnit", Nilable = false, Default = 0 },
				{ Name = "offsetY", Type = "uiUnit", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "SetHitRectThickness",
			Type = "Function",

			Arguments =
			{
				{ Name = "thickness", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "SetStartPoint",
			Type = "Function",

			Arguments =
			{
				{ Name = "relativePoint", Type = "FramePoint", Nilable = false },
				{ Name = "relativeTo", Type = "ScriptRegion", Nilable = false },
				{ Name = "offsetX", Type = "uiUnit", Nilable = false, Default = 0 },
				{ Name = "offsetY", Type = "uiUnit", Nilable = false, Default = 0 },
			},
		},
		{
			Name = "SetThickness",
			Type = "Function",

			Arguments =
			{
				{ Name = "thickness", Type = "uiUnit", Nilable = false },
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