local CombatAudioAlertConstants =
{
	Tables =
	{
		{
			Name = "CAAConstants",
			Type = "Constants",
			Values =
			{
				{ Name = "CAAEnabledDefault", Type = "bool", Value = false },
				{ Name = "CAAVoiceDefault", Type = "number", Value = 2 },
				{ Name = "CAAPlayerHealthPercentDefault", Type = "number", Value = 0 },
				{ Name = "CAAPlayerHealthFormatDefault", Type = "number", Value = 2 },
				{ Name = "CAATargetHealthPercentDefault", Type = "number", Value = 20 },
				{ Name = "CAATargetHealthFormatDefault", Type = "number", Value = 4 },
				{ Name = "CAAThrottleMin", Type = "number", Value = 0 },
				{ Name = "CAAThrottleMax", Type = "number", Value = 5 },
				{ Name = "CAAThrottleDefault", Type = "number", Value = 0 },
				{ Name = "CAAThrottleStep", Type = "number", Value = 0.5 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CombatAudioAlertConstants);