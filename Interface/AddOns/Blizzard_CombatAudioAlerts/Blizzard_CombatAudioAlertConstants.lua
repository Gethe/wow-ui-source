CombatAudioAlertConstants =
{
	CVars =
	{
		ENABLED_CVAR = {name = "CAAEnabled", refreshEvents = true},
		VOICE_CVAR = {name = "CAAVoice", playSample = true},
		SPEED_CVAR = {name = "CAASpeed", playSample = true},
		VOLUME_CVAR = {name = "CAAVolume", playSample = true},

		SAY_COMBAT_START_CVAR = {name = "CAASayCombatStart", refreshEvents = true},
		SAY_COMBAT_END_CVAR = {name = "CAASayCombatEnd", refreshEvents = true},

		PLAYER_HEALTH_PCT_CVAR = {name = "CAAPlayerHealthPercent", refreshEvents = true},
		PLAYER_HEALTH_FMT_CVAR = {name = "CAAPlayerHealthFormat", refreshEvents = true},
		PLAYER_HEALTH_THROTTLE_CVAR = {name = "CAAPlayerHealthThrottle", refreshThrottles = true},

		SAY_TARGET_NAME_CVAR = {name = "CAASayTargetName", refreshEvents = true},
		TARGET_DEATH_BEHAVIOR_CVAR = {name = "CAATargetDeathBehavior"},
		TARGET_HEALTH_PCT_CVAR = {name = "CAATargetHealthPercent", refreshEvents = true},
		TARGET_HEALTH_FMT_CVAR = {name = "CAATargetHealthFormat", refreshEvents = true},
		TARGET_HEALTH_THROTTLE_CVAR = {name = "CAATargetHealthThrottle", refreshThrottles = true},
	},

	ALLOW_OVERLAPPED_SPEECH = true,
	SAMPLE_TEXT_THROTTLE_SECS = 1,

	ThrottleTypes = EnumUtil.MakeEnum(
		"Sample",
		"PlayerHealth",
		"TargetHealth"
	);
};
