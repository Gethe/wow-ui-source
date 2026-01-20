NewSettings["10.1.0"] = {
	"PROXY_CENSOR_MESSAGES",
};
NewSettings["10.1.5"] = {
	"ReplaceOtherPlayerPortraits",
	"ReplaceMyPlayerPortrait",
};

NewSettings["10.1.7"] = {
	"restrictCalendarInvites",
	"enablePings",
};

NewSettings["10.2.0"] = {
	"PROXY_ADV_FLY_PITCH_CONTROL",
	"advFlyPitchControlGroundDebounce",
	"advFlyPitchControlCameraChase",
	"advFlyKeyboardMinPitchFactor",
	"advFlyKeyboardMaxPitchFactor",
	"advFlyKeyboardMinTurnFactor",
	"advFlyKeyboardMaxTurnFactor",
};

NewSettings["11.0.0"] = {
	"arachnophobiaMode",
};

NewSettings["11.1.5"] = {
	"cooldownViewerEnabled",
	"panelItemQualityColorOverrides",
};

NewSettingsPredicates["cooldownViewerEnabled"] = function()
	return C_CooldownViewer.IsCooldownViewerAvailable();
end

NewSettings["11.1.7"] = {
	"ASSISTED_COMBAT_ROTATION",
	"assistedCombatHighlight",
};

NewSettingsPredicates["ASSISTED_COMBAT_ROTATION"] = function()
	return C_AssistedCombat.IsAvailable();
end;

NewSettingsPredicates["assistedCombatHighlight"] = function()
	return C_AssistedCombat.IsAvailable();
end;

NewSettings["11.2.0"] = {
	"PROXY_ACCESSIBILITY_FONT_SIZE",
	"PROXY_SPELL_DENSITY",
	"PROXY_RAID_SPELL_DENSITY",
	"GameplaySoundEffects",
};

NewSettings["11.2.5"] = {
	"ADVANCED_COOLDOWN_SETTINGS",
};

NewSettings["12.0.0"] = {
	"NAMEPLATES_LABEL", -- entire section is new
	"COMBAT_WARNINGS_LABEL", -- entire section is new
	"DAMAGE_METER_LABEL", -- entire section is new
	"SPELL_DIMINISH_SECTION_HEADER_LABEL", -- entire section is new
	"EXTERNAL_DEFENSIVES_LABEL", -- entire section is new
	"CAA_COMBAT_AUDIO_ALERTS_LABEL", -- entire section is new
	"chatBubblesRaid",
	"raidFramesDisplayClassColor",
	"raidFramesDisplayLargerRoleSpecificDebuffs",
	"raidFramesCenterBigDefensive",
	"raidFramesDispelIndicatorType",
	"raidFramesDispelIndicatorOverlay",
};
