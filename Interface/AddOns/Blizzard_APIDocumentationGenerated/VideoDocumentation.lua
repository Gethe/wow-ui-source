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
				{ Name = "size", Type = "vector2", Mixin = "Vector2DMixin", Nilable = false },
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
				{ Name = "size", Type = "vector2", Mixin = "Vector2DMixin", Nilable = false },
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
				{ Name = "sizes", Type = "table", InnerType = "vector2", Nilable = false },
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
			Name = "GlueScreenshotStarted",
			Type = "Event",
			LiteralName = "GLUE_SCREENSHOT_STARTED",
		},
		{
			Name = "GlueScreenshotSucceeded",
			Type = "Event",
			LiteralName = "GLUE_SCREENSHOT_SUCCEEDED",
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
			NumValues = 42,
			MinValue = 0,
			MaxValue = 41,
			Fields =
			{
				{ Name = "Supported", Type = "GraphicsValidationResult", EnumValue = 0 },
				{ Name = "Illegal", Type = "GraphicsValidationResult", EnumValue = 1 },
				{ Name = "Unsupported", Type = "GraphicsValidationResult", EnumValue = 2 },
				{ Name = "Graphics", Type = "GraphicsValidationResult", EnumValue = 3 },
				{ Name = "DualCore", Type = "GraphicsValidationResult", EnumValue = 4 },
				{ Name = "QuadCore", Type = "GraphicsValidationResult", EnumValue = 5 },
				{ Name = "CpuMem_2", Type = "GraphicsValidationResult", EnumValue = 6 },
				{ Name = "CpuMem_4", Type = "GraphicsValidationResult", EnumValue = 7 },
				{ Name = "CpuMem_8", Type = "GraphicsValidationResult", EnumValue = 8 },
				{ Name = "Needs_5_0", Type = "GraphicsValidationResult", EnumValue = 9 },
				{ Name = "Needs_6_0", Type = "GraphicsValidationResult", EnumValue = 10 },
				{ Name = "NeedsRt", Type = "GraphicsValidationResult", EnumValue = 11 },
				{ Name = "NeedsDx12", Type = "GraphicsValidationResult", EnumValue = 12 },
				{ Name = "NeedsDx12Vrs2", Type = "GraphicsValidationResult", EnumValue = 13 },
				{ Name = "NeedsAppleGpu", Type = "GraphicsValidationResult", EnumValue = 14 },
				{ Name = "NeedsAmdGpu", Type = "GraphicsValidationResult", EnumValue = 15 },
				{ Name = "NeedsIntelGpu", Type = "GraphicsValidationResult", EnumValue = 16 },
				{ Name = "NeedsNvidiaGpu", Type = "GraphicsValidationResult", EnumValue = 17 },
				{ Name = "NeedsQualcommGpu", Type = "GraphicsValidationResult", EnumValue = 18 },
				{ Name = "NeedsMacOs_10_13", Type = "GraphicsValidationResult", EnumValue = 19 },
				{ Name = "NeedsMacOs_10_14", Type = "GraphicsValidationResult", EnumValue = 20 },
				{ Name = "NeedsMacOs_10_15", Type = "GraphicsValidationResult", EnumValue = 21 },
				{ Name = "NeedsMacOs_11_0", Type = "GraphicsValidationResult", EnumValue = 22 },
				{ Name = "NeedsMacOs_12_0", Type = "GraphicsValidationResult", EnumValue = 23 },
				{ Name = "NeedsMacOs_13_0", Type = "GraphicsValidationResult", EnumValue = 24 },
				{ Name = "NeedsWindows_10", Type = "GraphicsValidationResult", EnumValue = 25 },
				{ Name = "NeedsWindows_11", Type = "GraphicsValidationResult", EnumValue = 26 },
				{ Name = "MacOsUnsupported", Type = "GraphicsValidationResult", EnumValue = 27 },
				{ Name = "WindowsUnsupported", Type = "GraphicsValidationResult", EnumValue = 28 },
				{ Name = "LegacyUnsupported", Type = "GraphicsValidationResult", EnumValue = 29 },
				{ Name = "Dx11Unsupported", Type = "GraphicsValidationResult", EnumValue = 30 },
				{ Name = "Dx12Win7Unsupported", Type = "GraphicsValidationResult", EnumValue = 31 },
				{ Name = "RemoteDesktopUnsupported", Type = "GraphicsValidationResult", EnumValue = 32 },
				{ Name = "WineUnsupported", Type = "GraphicsValidationResult", EnumValue = 33 },
				{ Name = "NvapiWineUnsupported", Type = "GraphicsValidationResult", EnumValue = 34 },
				{ Name = "AppleGpuUnsupported", Type = "GraphicsValidationResult", EnumValue = 35 },
				{ Name = "AmdGpuUnsupported", Type = "GraphicsValidationResult", EnumValue = 36 },
				{ Name = "IntelGpuUnsupported", Type = "GraphicsValidationResult", EnumValue = 37 },
				{ Name = "NvidiaGpuUnsupported", Type = "GraphicsValidationResult", EnumValue = 38 },
				{ Name = "QualcommGpuUnsupported", Type = "GraphicsValidationResult", EnumValue = 39 },
				{ Name = "GpuDriver", Type = "GraphicsValidationResult", EnumValue = 40 },
				{ Name = "Unknown", Type = "GraphicsValidationResult", EnumValue = 41 },
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