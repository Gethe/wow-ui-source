local SimpleScrollFrameAPI =
{
	Name = "SimpleScrollFrameAPI",
	Type = "ScriptObject",

	Functions =
	{
		{
			Name = "GetHorizontalScroll",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "offset", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "GetHorizontalScrollRange",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "range", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "GetScrollChild",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "scrollChild", Type = "SimpleFrame", Nilable = false },
			},
		},
		{
			Name = "GetVerticalScroll",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "offset", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "GetVerticalScrollRange",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "range", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "SetHorizontalScroll",
			Type = "Function",

			Arguments =
			{
				{ Name = "offset", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "SetScrollChild",
			Type = "Function",

			Arguments =
			{
				{ Name = "scrollChild", Type = "SimpleFrame", Nilable = false },
			},
		},
		{
			Name = "SetVerticalScroll",
			Type = "Function",

			Arguments =
			{
				{ Name = "offset", Type = "uiUnit", Nilable = false },
			},
		},
		{
			Name = "UpdateScrollChildRect",
			Type = "Function",

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
	},
};

APIDocumentation:AddDocumentationTable(SimpleScrollFrameAPI);