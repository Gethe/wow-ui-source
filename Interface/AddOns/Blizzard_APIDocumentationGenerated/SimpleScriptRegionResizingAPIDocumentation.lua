local SimpleScriptRegionResizingAPI =
{
	Name = "SimpleScriptRegionResizingAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "AdjustPointsOffset",
			Type = "Function",

			Arguments =
			{
				{ Name = "x", Type = "uiUnit", Nilable = false },
				{ Name = "y", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "ClearAllPoints",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "ClearPoint",
			Type = "Function",

			Arguments =
			{
				{ Name = "point", Type = "FramePoint", Nilable = false },
			},
		},
		{
			Name = "ClearPointsOffset",
			Type = "Function",

			Arguments =
			{
			},
		},
		{
			Name = "GetNumPoints",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "numPoints", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPoint",
			Type = "Function",

			Arguments =
			{
				{ Name = "anchorIndex", Type = "luaIndex", Nilable = false, Default = 0 },
			},

			Returns =
			{
				{ Name = "point", Type = "FramePoint", Nilable = false },
				{ Name = "relativeTo", Type = "ScriptRegion", Nilable = false },
				{ Name = "relativePoint", Type = "FramePoint", Nilable = false },
				{ Name = "offsetX", Type = "uiUnit", Nilable = false },
				{ Name = "offsetY", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "GetPointByName",
			Type = "Function",

			Arguments =
			{
				{ Name = "point", Type = "FramePoint", Nilable = false },
			},

			Returns =
			{
				{ Name = "point", Type = "FramePoint", Nilable = false },
				{ Name = "relativeTo", Type = "ScriptRegion", Nilable = false },
				{ Name = "relativePoint", Type = "FramePoint", Nilable = false },
				{ Name = "offsetX", Type = "uiUnit", Nilable = false },
				{ Name = "offsetY", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "SetAllPoints",
			Type = "Function",

			Arguments =
			{
				{ Name = "relativeTo", Type = "ScriptRegion", Nilable = false },
				{ Name = "doResize", Type = "bool", Nilable = false, Default = true },
			},
		},
		{
			Name = "SetHeight",
			Type = "Function",

			Arguments =
			{
				{ Name = "height", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "SetPoint",
			Type = "Function",

			Arguments =
			{
				{ Name = "point", Type = "FramePoint", Nilable = false },
				{ Name = "relativeTo", Type = "ScriptRegion", Nilable = false },
				{ Name = "relativePoint", Type = "FramePoint", Nilable = false },
				{ Name = "offsetX", Type = "uiUnit", Nilable = false },
				{ Name = "offsetY", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "SetSize",
			Type = "Function",

			Arguments =
			{
				{ Name = "x", Type = "uiUnit", Nilable = false },
				{ Name = "y", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "SetWidth",
			Type = "Function",

			Arguments =
			{
				{ Name = "width", Type = "uiUnit", Nilable = false },
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

APIDocumentation:AddDocumentationTable(SimpleScriptRegionResizingAPI);