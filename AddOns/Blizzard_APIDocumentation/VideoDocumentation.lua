local Video =
{
	Name = "Video",
	Type = "System",
	Namespace = "C_Video",

	Functions =
	{
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
	},
};

APIDocumentation:AddDocumentationTable(Video);