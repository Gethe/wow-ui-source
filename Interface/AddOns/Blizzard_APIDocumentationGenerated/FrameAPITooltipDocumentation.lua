local FrameAPITooltip =
{
	Name = "FrameAPITooltip",
	Type = "ScriptObject",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetLeftLine",
			Type = "Function",

			Arguments =
			{
				{ Name = "line", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "leftFontString", Type = "SimpleFontString", Nilable = false },
			},
		},
		{
			Name = "GetMinimumWidth",
			Type = "Function",

			Arguments =
			{
			},

			Returns =
			{
				{ Name = "width", Type = "number", Nilable = false },
				{ Name = "forced", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetRightLine",
			Type = "Function",

			Arguments =
			{
				{ Name = "line", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "rightFontString", Type = "SimpleFontString", Nilable = false },
			},
		},
		{
			Name = "SetMinimumWidth",
			Type = "Function",

			Arguments =
			{
				{ Name = "width", Type = "number", Nilable = false },
				{ Name = "force", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetText",
			Type = "Function",

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "alpha", Type = "number", Nilable = false, Default = 1 },
				{ Name = "wrap", Type = "bool", Nilable = false, Default = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(FrameAPITooltip);