local CooldownFrameConstants =
{
	Tables =
	{
		{
			Name = "CooldownFrameDefaults",
			Type = "Constants",
			Values =
			{
				{ Name = "COOLDOWN_DEFAULT_COUNTDOWN_ABBREV_THRESHOLD_MS", Type = "number", Value = 120000 },
				{ Name = "COOLDOWN_DEFAULT_COUNTDOWN_MILLISECOND_THRESHOLD_MS", Type = "number", Value = 0 },
				{ Name = "COOLDOWN_DEFAULT_COUNTDOWN_MINIMUM_DURATION_MS", Type = "number", Value = 2000 },
				{ Name = "COOLDOWN_DEFAULT_BLING_DURATION_MS", Type = "number", Value = 1000 },
				{ Name = "COOLDOWN_DEFAULT_USE_AURA_DISPLAY_TIME", Type = "bool", Value = false },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(CooldownFrameConstants);