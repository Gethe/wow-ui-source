local MacOptions =
{
	Name = "MacOptions",
	Type = "System",
	Namespace = "C_MacOptions",

	Functions =
	{
		{
			Name = "AreOSShortcutsDisabled",
			Type = "Function",

			Returns =
			{
				{ Name = "osShortcutsDisabledCVar", Type = "bool", Nilable = true },
				{ Name = "osShortcutsDisabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetGameBundleName",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "HasNewStyleInputMonitoring",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsInputMonitoringEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsMicrophoneEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsUniversalAccessEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "OpenInputMonitoring",
			Type = "Function",
		},
		{
			Name = "OpenMicrophoneRequestDialogue",
			Type = "Function",
		},
		{
			Name = "OpenUniversalAccess",
			Type = "Function",
		},
		{
			Name = "SetOSShortcutsDisabled",
			Type = "Function",

			Arguments =
			{
				{ Name = "disable", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(MacOptions);