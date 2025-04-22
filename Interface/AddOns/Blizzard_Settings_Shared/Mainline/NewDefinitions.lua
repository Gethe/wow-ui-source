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
	if not C_CooldownViewer.IsCooldownViewerAvailable() then
		return false;
	end

	return true;
end;
