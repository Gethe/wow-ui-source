local Console =
{
	Name = "Console",
	Type = "System",

	Functions =
	{
		{
			Name = "ConsoleGetAllCommands",
			Type = "Function",

			Returns =
			{
				{ Name = "commands", Type = "table", InnerType = "ConsoleCommandInfo", Nilable = false },
			},
		},
		{
			Name = "ConsoleGetColorFromType",
			Type = "Function",

			Arguments =
			{
				{ Name = "colorType", Type = "ConsoleColorType", Nilable = false },
			},

			Returns =
			{
				{ Name = "color", Type = "colorRGB", Mixin = "ColorMixin", Nilable = false },
			},
		},
		{
			Name = "ConsoleGetFontHeight",
			Type = "Function",

			Returns =
			{
				{ Name = "fontHeightInPixels", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ConsolePrintAllMatchingCommands",
			Type = "Function",

			Arguments =
			{
				{ Name = "partialCommandText", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ConsoleSetFontHeight",
			Type = "Function",

			Arguments =
			{
				{ Name = "fontHeightInPixels", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetConsoleKey",
			Type = "Function",

			Arguments =
			{
				{ Name = "keystring", Type = "cstring", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "ConsoleClear",
			Type = "Event",
			LiteralName = "CONSOLE_CLEAR",
		},
		{
			Name = "ConsoleColorsChanged",
			Type = "Event",
			LiteralName = "CONSOLE_COLORS_CHANGED",
		},
		{
			Name = "ConsoleFontSizeChanged",
			Type = "Event",
			LiteralName = "CONSOLE_FONT_SIZE_CHANGED",
		},
		{
			Name = "ConsoleLog",
			Type = "Event",
			LiteralName = "CONSOLE_LOG",
			Payload =
			{
				{ Name = "message", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ConsoleMessage",
			Type = "Event",
			LiteralName = "CONSOLE_MESSAGE",
			Payload =
			{
				{ Name = "message", Type = "cstring", Nilable = false },
				{ Name = "colorType", Type = "number", Nilable = false },
			},
		},
		{
			Name = "CvarUpdate",
			Type = "Event",
			LiteralName = "CVAR_UPDATE",
			Payload =
			{
				{ Name = "eventName", Type = "cstring", Nilable = false },
				{ Name = "value", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GlueConsoleLog",
			Type = "Event",
			LiteralName = "GLUE_CONSOLE_LOG",
			Payload =
			{
				{ Name = "message", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "ToggleConsole",
			Type = "Event",
			LiteralName = "TOGGLE_CONSOLE",
			Payload =
			{
				{ Name = "showConsole", Type = "bool", Nilable = true },
			},
		},
	},

	Tables =
	{
		{
			Name = "ConsoleCategory",
			Type = "Enumeration",
			NumValues = 11,
			MinValue = 0,
			MaxValue = 10,
			Fields =
			{
				{ Name = "Debug", Type = "ConsoleCategory", EnumValue = 0 },
				{ Name = "Graphics", Type = "ConsoleCategory", EnumValue = 1 },
				{ Name = "Console", Type = "ConsoleCategory", EnumValue = 2 },
				{ Name = "Combat", Type = "ConsoleCategory", EnumValue = 3 },
				{ Name = "Game", Type = "ConsoleCategory", EnumValue = 4 },
				{ Name = "Default", Type = "ConsoleCategory", EnumValue = 5 },
				{ Name = "Net", Type = "ConsoleCategory", EnumValue = 6 },
				{ Name = "Sound", Type = "ConsoleCategory", EnumValue = 7 },
				{ Name = "Gm", Type = "ConsoleCategory", EnumValue = 8 },
				{ Name = "Reveal", Type = "ConsoleCategory", EnumValue = 9 },
				{ Name = "None", Type = "ConsoleCategory", EnumValue = 10 },
			},
		},
		{
			Name = "ConsoleColorType",
			Type = "Enumeration",
			NumValues = 12,
			MinValue = 0,
			MaxValue = 11,
			Fields =
			{
				{ Name = "DefaultColor", Type = "ConsoleColorType", EnumValue = 0 },
				{ Name = "InputColor", Type = "ConsoleColorType", EnumValue = 1 },
				{ Name = "EchoColor", Type = "ConsoleColorType", EnumValue = 2 },
				{ Name = "ErrorColor", Type = "ConsoleColorType", EnumValue = 3 },
				{ Name = "WarningColor", Type = "ConsoleColorType", EnumValue = 4 },
				{ Name = "GlobalColor", Type = "ConsoleColorType", EnumValue = 5 },
				{ Name = "AdminColor", Type = "ConsoleColorType", EnumValue = 6 },
				{ Name = "HighlightColor", Type = "ConsoleColorType", EnumValue = 7 },
				{ Name = "BackgroundColor", Type = "ConsoleColorType", EnumValue = 8 },
				{ Name = "ClickbufferColor", Type = "ConsoleColorType", EnumValue = 9 },
				{ Name = "PrivateColor", Type = "ConsoleColorType", EnumValue = 10 },
				{ Name = "DefaultGreen", Type = "ConsoleColorType", EnumValue = 11 },
			},
		},
		{
			Name = "ConsoleCommandType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Cvar", Type = "ConsoleCommandType", EnumValue = 0 },
				{ Name = "Command", Type = "ConsoleCommandType", EnumValue = 1 },
				{ Name = "Macro", Type = "ConsoleCommandType", EnumValue = 2 },
				{ Name = "Script", Type = "ConsoleCommandType", EnumValue = 3 },
			},
		},
		{
			Name = "ConsoleCommandInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "command", Type = "cstring", Nilable = false },
				{ Name = "help", Type = "cstring", Nilable = false },
				{ Name = "category", Type = "ConsoleCategory", Nilable = false },
				{ Name = "commandType", Type = "ConsoleCommandType", Nilable = false },
				{ Name = "scriptContents", Type = "cstring", Nilable = false },
				{ Name = "scriptParameters", Type = "cstring", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Console);