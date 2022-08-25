local Video =
{
	Name = "Video",
	Type = "System",
	Namespace = "C_VideoOptions",

	Functions =
	{
		{
			Name = "GetCurrentGameWindowSize",
			Type = "Function",

			Returns =
			{
				{ Name = "size", Type = "table", Mixin = "Vector2DMixin", Nilable = false },
			},
		},
		{
			Name = "GetDefaultGameWindowSize",
			Type = "Function",

			Arguments =
			{
				{ Name = "monitor", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "size", Type = "table", Mixin = "Vector2DMixin", Nilable = false },
			},
		},
		{
			Name = "GetGameWindowSizes",
			Type = "Function",

			Arguments =
			{
				{ Name = "monitor", Type = "number", Nilable = false },
				{ Name = "fullscreen", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "sizes", Type = "table", InnerType = "table", Nilable = false },
			},
		},
		{
			Name = "GetGxAdapterInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "adapters", Type = "table", InnerType = "GxAdapterInfoDetails", Nilable = false },
			},
		},
		{
			Name = "SetGameWindowSize",
			Type = "Function",

			Arguments =
			{
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "AdapterListChanged",
			Type = "Event",
			LiteralName = "ADAPTER_LIST_CHANGED",
		},
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
			Name = "GxRestarted",
			Type = "Event",
			LiteralName = "GX_RESTARTED",
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
			Name = "GraphicsValidationResult",
			Type = "Enumeration",
			NumValues = 19,
			MinValue = 0,
			MaxValue = 18,
			Fields =
			{
				{ Name = "Supported", Type = "GraphicsValidationResult", EnumValue = 0 },
				{ Name = "Illegal", Type = "GraphicsValidationResult", EnumValue = 1 },
				{ Name = "Unsupported", Type = "GraphicsValidationResult", EnumValue = 2 },
				{ Name = "Graphics", Type = "GraphicsValidationResult", EnumValue = 3 },
				{ Name = "DualCore", Type = "GraphicsValidationResult", EnumValue = 4 },
				{ Name = "CpuMem_2", Type = "GraphicsValidationResult", EnumValue = 5 },
				{ Name = "CpuMem_4", Type = "GraphicsValidationResult", EnumValue = 6 },
				{ Name = "Needs_5_0", Type = "GraphicsValidationResult", EnumValue = 7 },
				{ Name = "Needs_6_0", Type = "GraphicsValidationResult", EnumValue = 8 },
				{ Name = "NeedsRt", Type = "GraphicsValidationResult", EnumValue = 9 },
				{ Name = "NeedsMacOs_10_13", Type = "GraphicsValidationResult", EnumValue = 10 },
				{ Name = "NeedsMacOs_10_14", Type = "GraphicsValidationResult", EnumValue = 11 },
				{ Name = "NeedsMacOs_10_15", Type = "GraphicsValidationResult", EnumValue = 12 },
				{ Name = "NeedsMacOs_11_0", Type = "GraphicsValidationResult", EnumValue = 13 },
				{ Name = "NeedsWindows_10", Type = "GraphicsValidationResult", EnumValue = 14 },
				{ Name = "MacOsUnsupported", Type = "GraphicsValidationResult", EnumValue = 15 },
				{ Name = "WindowsUnsupported", Type = "GraphicsValidationResult", EnumValue = 16 },
				{ Name = "GpuDriver", Type = "GraphicsValidationResult", EnumValue = 17 },
				{ Name = "Unknown", Type = "GraphicsValidationResult", EnumValue = 18 },
			},
		},
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