local Build =
{
	Name = "Build",
	Type = "System",

	Functions =
	{
		{
			Name = "GetBuildInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "buildVersion", Type = "cstring", Nilable = false },
				{ Name = "buildNumber", Type = "cstring", Nilable = false },
				{ Name = "buildDate", Type = "cstring", Nilable = false },
				{ Name = "interfaceVersion", Type = "number", Nilable = false },
				{ Name = "localizedVersion", Type = "cstring", Nilable = false },
				{ Name = "buildInfo", Type = "string", Nilable = false },
			},
		},
		{
			Name = "Is64BitClient",
			Type = "Function",

			Returns =
			{
				{ Name = "is64Bit", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsBetaBuild",
			Type = "Function",

			Returns =
			{
				{ Name = "isBetaBuild", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsDebugBuild",
			Type = "Function",

			Returns =
			{
				{ Name = "isDebugBuild", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsLinuxClient",
			Type = "Function",

			Returns =
			{
				{ Name = "isLinux", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMacClient",
			Type = "Function",

			Returns =
			{
				{ Name = "isMac", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsPublicBuild",
			Type = "Function",

			Returns =
			{
				{ Name = "isPublicBuild", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsTestBuild",
			Type = "Function",

			Returns =
			{
				{ Name = "isTestBuild", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsWindowsClient",
			Type = "Function",

			Returns =
			{
				{ Name = "isWindows", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SupportsClipCursor",
			Type = "Function",

			Returns =
			{
				{ Name = "supportsClipCursor", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(Build);