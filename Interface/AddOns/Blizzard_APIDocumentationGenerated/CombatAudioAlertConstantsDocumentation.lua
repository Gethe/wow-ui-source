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
				{ Name = "CAAVoiceDefault", Type = "number", Value = 0 },
				{ Name = "CAASayCombatStartDefault", Type = "bool", Value = true },
				{ Name = "CAASayCombatEndDefault", Type = "bool", Value = true },
				{ Name = "CAAPlayerHealthPercentDefault", Type = "number", Value = 0 },
				{ Name = "CAAPlayerHealthFormatDefault", Type = "number", Value = 2 },
				{ Name = "CAATargetNameDefault", Type = "bool", Value = true },
				{ Name = "CAATargetHealthPercentDefault", Type = "number", Value = 20 },
				{ Name = "CAATargetHealthFormatDefault", Type = "number", Value = 4 },
				{ Name = "CAATargetDeathBehaviorDefault", Type = "number", Value = 0 },
				{ Name = "CAAThrottleMin", Type = "number", Value = 0 },
				{ Name = "CAAThrottleMax", Type = "number", Value = 5 },
				{ Name = "CAAThrottleDefault", Type = "number", Value = 0 },
				{ Name = "CAAThrottleStep", Type = "number", Value = 0.5 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CombatAudioAlertConstants);