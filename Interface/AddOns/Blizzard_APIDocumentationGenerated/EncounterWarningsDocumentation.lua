local EncounterWarnings =
{
	Name = "EncounterWarnings",
	Type = "System",
	Namespace = "C_EncounterWarnings",

	Functions =
	{
		{
			Name = "GetEditModeWarningInfo",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "severity", Type = "EncounterEventSeverity", Nilable = false },
			},

			Returns =
			{
				{ Name = "warningInfo", Type = "EncounterWarningInfo", Nilable = false },
			},
		},
		{
			Name = "GetSoundKitForSeverity",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "severity", Type = "EncounterEventSeverity", Nilable = false },
			},

			Returns =
			{
				{ Name = "soundKitID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsFeatureAvailable",
			Type = "Function",

			Returns =
			{
				{ Name = "isAvailable", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsFeatureEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isAvailableAndEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "PlaySound",
			Type = "Function",
			MayReturnNothing = true,
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "severity", Type = "EncounterEventSeverity", Nilable = false },
			},

			Returns =
			{
				{ Name = "soundHandle", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "EncounterWarning",
			Type = "Event",
			LiteralName = "ENCOUNTER_WARNING",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "encounterWarningInfo", Type = "EncounterWarningInfo", Nilable = false },
			},
		},
	},

	Tables =
	{
		{
			Name = "EncounterWarningInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "text", Type = "cstring", Nilable = false, SecretValue = true },
				{ Name = "casterGUID", Type = "WOWGUID", Nilable = false, SecretValue = true },
				{ Name = "casterName", Type = "cstring", Nilable = false, SecretValue = true },
				{ Name = "targetGUID", Type = "WOWGUID", Nilable = false, SecretValue = true },
				{ Name = "targetName", Type = "cstring", Nilable = false, SecretValue = true },
				{ Name = "iconFileID", Type = "number", Nilable = false, SecretValue = true },
				{ Name = "tooltipSpellID", Type = "number", Nilable = false, SecretValue = true },
				{ Name = "isDeadly", Type = "bool", Nilable = false, SecretValue = true },
				{ Name = "duration", Type = "DurationSeconds", Nilable = false },
				{ Name = "severity", Type = "EncounterEventSeverity", Nilable = false },
				{ Name = "shouldPlaySound", Type = "bool", Nilable = false },
				{ Name = "shouldShowChatMessage", Type = "bool", Nilable = false },
				{ Name = "shouldShowWarning", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(EncounterWarnings);