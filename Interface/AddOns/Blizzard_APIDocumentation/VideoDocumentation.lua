local Video =
{
	Name = "Video",
	Type = "System",
	Namespace = "C_VideoOptions",

	Functions =
	{
		{
			Name = "GetGxAdapterInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "adapters", Type = "table", InnerType = "GxAdapterInfoDetails", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "DisplaySizeChanged",
			Type = "Event",
			LiteralName = "DISPLAY_SIZE_CHANGED",
		},
		{
			Name = "GlueScreenshotFailed",
			Type = "Event",
			LiteralName = "GLUE_SCREENSHOT_FAILED",
		},
		{
			Name = "ScreenshotFailed",
			Type = "Event",
			LiteralName = "SCREENSHOT_FAILED",
		},
		{
			Name = "ScreenshotStarted",
			Type = "Event",
			LiteralName = "SCREENSHOT_STARTED",
		},
		{
			Name = "ScreenshotSucceeded",
			Type = "Event",
			LiteralName = "SCREENSHOT_SUCCEEDED",
		},
	},

	Tables =
	{
		{
			Name = "GxAdapterInfoDetails",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "string", Nilable = false },
				{ Name = "isLowPower", Type = "bool", Nilable = false },
				{ Name = "isExternal", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Video);