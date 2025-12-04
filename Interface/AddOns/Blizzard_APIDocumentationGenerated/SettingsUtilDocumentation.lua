local SettingsUtil =
{
	Name = "SettingsUtil",
	Type = "System",
	Namespace = "C_SettingsUtil",

	Functions =
	{
		{
			Name = "NotifySettingsLoaded",
			Type = "Function",
		},
		{
			Name = "OpenSettingsPanel",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "openToCategoryID", Type = "number", Nilable = true },
				{ Name = "scrollToElementName", Type = "stringView", Nilable = true },
			},
		},
	},

	Events =
	{
		{
			Name = "SettingsLoaded",
			Type = "Event",
			LiteralName = "SETTINGS_LOADED",
			SynchronousEvent = true,
		},
		{
			Name = "SettingsPanelOpen",
			Type = "Event",
			LiteralName = "SETTINGS_PANEL_OPEN",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "openToCategoryID", Type = "number", Nilable = true },
				{ Name = "scrollToElementName", Type = "stringView", Nilable = true },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(SettingsUtil);