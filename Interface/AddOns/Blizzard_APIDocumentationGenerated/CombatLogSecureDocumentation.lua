local CombatLogSecure =
{
	Name = "CombatLogSecure",
	Type = "System",
	Namespace = "C_CombatLogSecure",
	Environment = "SecureOnly",

	Functions =
	{
		{
			Name = "AddEventFilter",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "ClearEventFilters",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "CreateCombatLogMessage",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "message", Type = "string", Nilable = false },
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "order", Type = "CombatLogMessageOrder", Nilable = false },
			},
		},
		{
			Name = "GetCurrentEntryInfo",
			Type = "Function",
			HasRestrictions = true,

			Returns =
			{
			},
		},
		{
			Name = "GetCurrentEventInfo",
			Type = "Function",
			HasRestrictions = true,

			Returns =
			{
			},
		},
		{
			Name = "GetEntryCount",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "ignoreFilter", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "count", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SeekToNewestEntry",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "ignoreFilter", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "isValidEntry", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SeekToPreviousEntry",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "ignoreFilter", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "isValidEntry", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldShowCurrentEntry",
			Type = "Function",
			HasRestrictions = true,

			Returns =
			{
				{ Name = "shouldShow", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "CombatLogApplyFilterSettings",
			Type = "Event",
			LiteralName = "COMBAT_LOG_APPLY_FILTER_SETTINGS",
			HasRestrictions = true,
			CallbackEvent = true,
			Payload =
			{
				{ Name = "filterSettings", Type = "LuaValueVariant", Nilable = false },
			},
		},
		{
			Name = "CombatLogMessage",
			Type = "Event",
			LiteralName = "COMBAT_LOG_MESSAGE",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "message", Type = "string", Nilable = false, Documentation = { "A preformatted combat log message protected by a |K string wrapper." } },
				{ Name = "colorR", Type = "number", Nilable = false },
				{ Name = "colorG", Type = "number", Nilable = false },
				{ Name = "colorB", Type = "number", Nilable = false },
				{ Name = "order", Type = "CombatLogMessageOrder", Nilable = false },
			},
		},
		{
			Name = "CombatLogRefilterEntries",
			Type = "Event",
			LiteralName = "COMBAT_LOG_REFILTER_ENTRIES",
			HasRestrictions = true,
			CallbackEvent = true,
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(CombatLogSecure);