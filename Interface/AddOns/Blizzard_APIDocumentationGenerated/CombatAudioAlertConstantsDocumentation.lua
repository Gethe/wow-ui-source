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
				{ Name = "CAAPlayerCastModeDefault", Type = "number", Value = 0 },
				{ Name = "CAAPlayerCastFormatDefault", Type = "number", Value = 5 },
				{ Name = "CAATargetCastModeDefault", Type = "number", Value = 0 },
				{ Name = "CAATargetCastFormatDefault", Type = "number", Value = 1 },
				{ Name = "CAAInterruptCastDefault", Type = "number", Value = 0 },
				{ Name = "CAAInterruptCastSuccessDefault", Type = "number", Value = 0 },
				{ Name = "CAAPlayerResourcePercentDefault", Type = "number", Value = 0 },
				{ Name = "CAAPlayerResourceFormatDefault", Type = "number", Value = 1 },
				{ Name = "CAAMinCastTimeMin", Type = "number", Value = 0 },
				{ Name = "CAAMinCastTimeMax", Type = "number", Value = 5 },
				{ Name = "CAAMinCastTimeDefault", Type = "number", Value = 1.5 },
				{ Name = "CAAMinCastTimeStep", Type = "number", Value = 0.5 },
				{ Name = "CAAThrottleMin", Type = "number", Value = 0 },
				{ Name = "CAAThrottleMax", Type = "number", Value = 5 },
				{ Name = "CAAThrottleDefault", Type = "number", Value = 0 },
				{ Name = "CAAThrottleStep", Type = "number", Value = 0.5 },
				{ Name = "CAASampleTextThrottleTime", Type = "number", Value = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CombatAudioAlertConstants);