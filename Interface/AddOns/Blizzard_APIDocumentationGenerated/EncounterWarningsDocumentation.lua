local EncounterWarnings =
{
	Name = "EncounterWarnings",
	Type = "System",
	Namespace = "C_EncounterWarnings",

	Functions =
	{
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
				{ Name = "isEnabled", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "EncounterWarning",
			Type = "Event",
			LiteralName = "ENCOUNTER_WARNING",
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
				{ Name = "text", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "casterGUID", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "casterName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "targetGUID", Type = "WOWGUID", Nilable = false, ConditionalSecret = true },
				{ Name = "targetName", Type = "cstring", Nilable = false, ConditionalSecret = true },
				{ Name = "iconFileID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "tooltipSpellID", Type = "number", Nilable = false, ConditionalSecret = true },
				{ Name = "duration", Type = "DurationSeconds", Nilable = false },
				{ Name = "severity", Type = "EncounterEventSeverity", Nilable = false },
				{ Name = "shouldPlaySound", Type = "bool", Nilable = false },
				{ Name = "shouldShowChatMessage", Type = "bool", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(EncounterWarnings);