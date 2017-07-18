local ConsoleLua =
{
	Name = "Console",
	Type = "System",
	Namespace = "C_Console",

	Functions =
	{
		{
			Name = "GetAllCommands",
			Type = "Function",

			Returns =
			{
				{ Name = "commands", Type = "table", InnerType = "ConsoleCommandInfo", Nilable = false },
			},
		},
		{
			Name = "GetColorFromType",
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
			Name = "GetFontHeight",
			Type = "Function",

			Returns =
			{
				{ Name = "fontHeightInPixels", Type = "number", Nilable = false },
			},
		},
		{
			Name = "PrintAllMatchingCommands",
			Type = "Function",

			Arguments =
			{
				{ Name = "partialCommandText", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetFontHeight",
			Type = "Function",

			Arguments =
			{
				{ Name = "fontHeightInPixels", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "ConsoleCategory",
			Type = "Enumeration",
			NumValues = 10,
			MinValue = 0,
			MaxValue = 9,
			Fields =
			{
				{ Name = "CategoryDebug", Type = "ConsoleCategory", EnumValue = 0 },
				{ Name = "CategoryGraphics", Type = "ConsoleCategory", EnumValue = 1 },
				{ Name = "CategoryConsole", Type = "ConsoleCategory", EnumValue = 2 },
				{ Name = "CategoryCombat", Type = "ConsoleCategory", EnumValue = 3 },
				{ Name = "CategoryGame", Type = "ConsoleCategory", EnumValue = 4 },
				{ Name = "CategoryDefault", Type = "ConsoleCategory", EnumValue = 5 },
				{ Name = "CategoryNet", Type = "ConsoleCategory", EnumValue = 6 },
				{ Name = "CategorySound", Type = "ConsoleCategory", EnumValue = 7 },
				{ Name = "CategoryGm", Type = "ConsoleCategory", EnumValue = 8 },
				{ Name = "CategoryNone", Type = "ConsoleCategory", EnumValue = 9 },
			},
		},
		{
			Name = "ConsoleColorType",
			Type = "Enumeration",
			NumValues = 11,
			MinValue = 0,
			MaxValue = 10,
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
			},
		},
		{
			Name = "ConsoleCommandType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Cvar", Type = "ConsoleCommandType", EnumValue = 0 },
				{ Name = "Command", Type = "ConsoleCommandType", EnumValue = 1 },
				{ Name = "Script", Type = "ConsoleCommandType", EnumValue = 2 },
			},
		},
		{
			Name = "ConsoleCommandInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "command", Type = "string", Nilable = false },
				{ Name = "help", Type = "string", Nilable = false },
				{ Name = "category", Type = "ConsoleCategory", Nilable = false },
				{ Name = "commandType", Type = "ConsoleCommandType", Nilable = false },
				{ Name = "scriptContents", Type = "string", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ConsoleLua);