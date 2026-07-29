CombatAudioAlertConstants =
{
	CVars =
	{
		ENABLED_CVAR = {name = "CAAEnabled", refreshEvents = true},
		VOICE_CVAR = {name = "CAAVoice", playSample = true, categoryType = Enum.CombatAudioAlertCategory.General},
		SPEED_CVAR = {name = "CAASpeed", playSample = true, categoryType = Enum.CombatAudioAlertCategory.General},
		VOLUME_CVAR = {name = "CAAVolume", playSample = true, categoryType = Enum.CombatAudioAlertCategory.General},

		SAY_COMBAT_START_CVAR = {name = "CAASayCombatStart", refreshEvents = true},
		SAY_COMBAT_END_CVAR = {name = "CAASayCombatEnd", refreshEvents = true},

		PLAYER_HEALTH_PCT_CVAR = {name = "CAAPlayerHealthPercent", refreshEvents = true},
		PLAYER_HEALTH_FMT_CVAR = {name = "CAAPlayerHealthFormat"},
		PLAYER_HEALTH_THROTTLE_CVAR = {name = "CAAPlayerHealthThrottle", refreshThrottles = true},
		PLAYER_HEALTH_VOICE_CVAR = {name = "CAAPlayerHealthVoice", playSample = true, categoryType = Enum.CombatAudioAlertCategory.PlayerHealth},
		PLAYER_HEALTH_VOLUME_CVAR = {name = "CAAPlayerHealthVolume", playSample = true, categoryType = Enum.CombatAudioAlertCategory.PlayerHealth},

		SAY_TARGET_NAME_CVAR = {name = "CAASayTargetName", refreshEvents = true},
		SAY_IF_TARGETED_CVAR = {name = "CAASayIfTargeted", refreshEvents = true},
		TARGET_DEATH_BEHAVIOR_CVAR = {name = "CAATargetDeathBehavior"},
		TARGET_HEALTH_PCT_CVAR = {name = "CAATargetHealthPercent", refreshEvents = true},
		TARGET_HEALTH_FMT_CVAR = {name = "CAATargetHealthFormat"},
		TARGET_HEALTH_THROTTLE_CVAR = {name = "CAATargetHealthThrottle", refreshThrottles = true},
		TARGET_HEALTH_VOICE_CVAR = {name = "CAATargetHealthVoice", playSample = true, categoryType = Enum.CombatAudioAlertCategory.TargetHealth},
		TARGET_HEALTH_VOLUME_CVAR = {name = "CAATargetHealthVolume", playSample = true, categoryType = Enum.CombatAudioAlertCategory.TargetHealth},

		PARTY_HEALTH_PCT_CVAR = {name = "CAAPartyHealthPercent", refreshEvents = true},
		PARTY_HEALTH_FREQ_CVAR = {name = "CAAPartyHealthFrequency"},
		PARTY_HEALTH_VOICE_CVAR = {name = "CAAPartyHealthVoice", playSample = true, categoryType = Enum.CombatAudioAlertCategory.PartyHealth},
		PARTY_HEALTH_VOLUME_CVAR = {name = "CAAPartyHealthVolume", playSample = true, categoryType = Enum.CombatAudioAlertCategory.PartyHealth},

		PLAYER_RESOURCE_1_PCT_CVAR = {name = "CAAResource1Percents", refreshEvents = true},
		PLAYER_RESOURCE_1_FMT_CVAR = {name = "CAAResource1Formats"},
		PLAYER_RESOURCE_1_THROTTLE_CVAR = {name = "CAAResource1Throttle", refreshThrottles = true},
		PLAYER_RESOURCE_1_VOICE_CVAR = {name = "CAAResource1Voice", playSample = true, categoryType = Enum.CombatAudioAlertCategory.PlayerResource1},
		PLAYER_RESOURCE_1_VOLUME_CVAR = {name = "CAAResource1Volume", playSample = true, categoryType = Enum.CombatAudioAlertCategory.PlayerResource1},

		PLAYER_RESOURCE_2_PCT_CVAR = {name = "CAAResource2Percents", refreshEvents = true},
		PLAYER_RESOURCE_2_FMT_CVAR = {name = "CAAResource2Formats"},
		PLAYER_RESOURCE_2_THROTTLE_CVAR = {name = "CAAResource2Throttle", refreshThrottles = true},
		PLAYER_RESOURCE_2_VOICE_CVAR = {name = "CAAResource2Voice", playSample = true, categoryType = Enum.CombatAudioAlertCategory.PlayerResource2},
		PLAYER_RESOURCE_2_VOLUME_CVAR = {name = "CAAResource2Volume", playSample = true, categoryType = Enum.CombatAudioAlertCategory.PlayerResource2},

		SAY_PLAYER_CAST_CVAR = {name = "CAAPlayerCastMode", refreshEvents = true},
		SAY_PLAYER_CAST_FMT_CVAR = {name = "CAAPlayerCastFormat"},
		SAY_PLAYER_CAST_MIN_TIME_CVAR = {name = "CAAPlayerCastMinTime"},
		SAY_PLAYER_CAST_THROTTLE_CVAR = {name = "CAAPlayerCastThrottle", refreshThrottles = true},
		SAY_PLAYER_CAST_VOICE_CVAR = {name = "CAAPlayerCastVoice", playSample = true, categoryType = Enum.CombatAudioAlertCategory.PlayerCast},
		SAY_PLAYER_CAST_VOLUME_CVAR = {name = "CAAPlayerCastVolume", playSample = true, categoryType = Enum.CombatAudioAlertCategory.PlayerCast},

		SAY_TARGET_CAST_CVAR = {name = "CAATargetCastMode", refreshEvents = true},
		SAY_TARGET_CAST_FMT_CVAR = {name = "CAATargetCastFormat"},
		SAY_TARGET_CAST_MIN_TIME_CVAR = {name = "CAATargetCastMinTime"},
		SAY_TARGET_CAST_THROTTLE_CVAR = {name = "CAATargetCastThrottle", refreshThrottles = true},
		SAY_TARGET_CAST_VOICE_CVAR = {name = "CAATargetCastVoice", playSample = true, categoryType = Enum.CombatAudioAlertCategory.TargetCast},
		SAY_TARGET_CAST_VOLUME_CVAR = {name = "CAATargetCastVolume", playSample = true, categoryType = Enum.CombatAudioAlertCategory.TargetCast},

		SAY_INTERRUPT_CAST_CVAR = {name = "CAAInterruptCast", refreshEvents = true},
		SAY_INTERRUPT_CAST_SUCCESS_CVAR = {name = "CAAInterruptCastSuccess", refreshEvents = true},

		SAY_YOUR_DEBUFFS_CVAR = {name = "CAASayYourDebuffs", refreshEvents = true},
		SAY_YOUR_DEBUFFS_FORMAT_CVAR = {name = "CAASayYourDebuffsFormat"},
		SAY_YOUR_DEBUFFS_MIN_DURATION_CVAR = {name = "CAASayYourDebuffsMinDuration"},
		SAY_YOUR_DEBUFFS_VOICE_CVAR = {name = "CAASayYourDebuffsVoice", playSample = true, categoryType = Enum.CombatAudioAlertCategory.PlayerDebuffs},
		SAY_YOUR_DEBUFFS_VOLUME_CVAR = {name = "CAASayYourDebuffsVolume", playSample = true, categoryType = Enum.CombatAudioAlertCategory.PlayerDebuffs},
		DEBUFF_SELF_ALERT_CVAR = {name = "CAADebuffSelfAlert", refreshEvents = true},
	},

	PARTY_HEALTH_UPDATE_MIN_SECONDS = 1;
	PARTY_HEALTH_UPDATE_MAX_SECONDS = 5;

	ALLOW_OVERLAP_NO = false;
	ALLOW_OVERLAP_YES = true;
};
