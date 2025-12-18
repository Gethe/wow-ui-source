local CombatLog =
{
	Name = "CombatLog",
	Type = "System",
	Namespace = "C_CombatLog",
	Environment = "All",

	Functions =
	{
		{
			Name = "ApplyFilterSettings",
			Type = "Function",
			HasRestrictions = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "filterSettings", Type = "LuaValueVariant", Nilable = false },
			},
		},
		{
			Name = "AreFilteredEventsEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ClearEntries",
			Type = "Function",
		},
		{
			Name = "DoesObjectMatchFilter",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mask", Type = "CombatLogObject", Nilable = false },
				{ Name = "flags", Type = "CombatLogObject", Nilable = false },
			},

			Returns =
			{
				{ Name = "matches", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetEntryRetentionTime",
			Type = "Function",

			Returns =
			{
				{ Name = "retentionTime", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMessageLimit",
			Type = "Function",

			Returns =
			{
				{ Name = "messageLimit", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsCombatLogRestricted",
			Type = "Function",

			Returns =
			{
				{ Name = "restricted", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "RefilterEntries",
			Type = "Function",
		},
		{
			Name = "SetEntryRetentionTime",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "retentionTime", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetFilteredEventsEnabled",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetMessageLimit",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "messageLimit", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "CombatLogEntriesCleared",
			Type = "Event",
			LiteralName = "COMBAT_LOG_ENTRIES_CLEARED",
			SynchronousEvent = true,
		},
		{
			Name = "CombatLogEvent",
			Type = "Event",
			LiteralName = "COMBAT_LOG_EVENT",
			HasRestrictions = true,
			SynchronousEvent = true,
			CallbackEvent = true,
		},
		{
			Name = "CombatLogEventUnfiltered",
			Type = "Event",
			LiteralName = "COMBAT_LOG_EVENT_UNFILTERED",
			HasRestrictions = true,
			SynchronousEvent = true,
			CallbackEvent = true,
		},
		{
			Name = "CombatLogMessageLimitChanged",
			Type = "Event",
			LiteralName = "COMBAT_LOG_MESSAGE_LIMIT_CHANGED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "messageLimit", Type = "number", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(CombatLog);