local alertTypeText =
{
	[Enum.CooldownViewerAlertType.Sound] = COOLDOWN_VIEWER_SETTINGS_ALERT_TYPE_SOUND,
}

local alertWhenText =
{
	[Enum.CooldownViewerAlertEventType.Available] = COOLDOWN_VIEWER_SETTINGS_ALERT_WHEN_AVAILABLE,
	[Enum.CooldownViewerAlertEventType.PandemicTime] = COOLDOWN_VIEWER_SETTINGS_ALERT_WHEN_PANDEMIC,
	[Enum.CooldownViewerAlertEventType.OnCooldown] = COOLDOWN_VIEWER_SETTINGS_ALERT_WHEN_ON_COOLDOWN,
	[Enum.CooldownViewerAlertEventType.ChargeGained] = COOLDOWN_VIEWER_SETTINGS_ALERT_WHEN_CHARGE_GAINED,
};

local alertSoundTypeText =
{
	[Enum.CooldownViewerSoundAlertType.Ding1] = COOLDOWN_VIEWER_SETTINGS_ALERT_LABEL_SOUND_TYPE_DING1,
	[Enum.CooldownViewerSoundAlertType.Ding2] = COOLDOWN_VIEWER_SETTINGS_ALERT_LABEL_SOUND_TYPE_DING2,
	[Enum.CooldownViewerSoundAlertType.Ding3] = COOLDOWN_VIEWER_SETTINGS_ALERT_LABEL_SOUND_TYPE_DING3,
	[Enum.CooldownViewerSoundAlertType.Ding4] = COOLDOWN_VIEWER_SETTINGS_ALERT_LABEL_SOUND_TYPE_DING4,
	[Enum.CooldownViewerSoundAlertType.TextToSpeech] = COOLDOWN_VIEWER_SETTINGS_ALERT_LABEL_SOUND_TYPE_TEXT_TO_SPEECH,
};

local COOLDOWN_ALERT_FIELD_TYPE = 1;
local COOLDOWN_ALERT_FIELD_EVENT = 2;
local COOLDOWN_ALERT_FIELD_PAYLOAD = 3;

function CooldownViewerAlert_Create(alertType, alertEvent, alertPayload)
	return { alertType, alertEvent, alertPayload };
end

function CooldownViewerAlert_Assign(destAlert, sourceAlert)
	destAlert[COOLDOWN_ALERT_FIELD_TYPE] = sourceAlert[COOLDOWN_ALERT_FIELD_TYPE];
	destAlert[COOLDOWN_ALERT_FIELD_EVENT] = sourceAlert[COOLDOWN_ALERT_FIELD_EVENT];
	destAlert[COOLDOWN_ALERT_FIELD_PAYLOAD] = sourceAlert[COOLDOWN_ALERT_FIELD_PAYLOAD];
	return destAlert;
end

function CooldownViewerAlert_GetAlertStatus(alert)
	local alertType, alertEvent = CooldownViewerAlert_GetValues(alert);

	if alertType ~= Enum.CooldownViewerAlertType.Sound then
		return Enum.CooldownViewerAddAlertStatus.InvalidAlertType;
	end

	if alertEvent < Enum.CooldownViewerAlertEventTypeMeta.MinValue or alertEvent > Enum.CooldownViewerAlertEventTypeMeta.MaxValue then
		return Enum.CooldownViewerAddAlertStatus.InvalidEventType;
	end

	return Enum.CooldownViewerAddAlertStatus.Success;
end

function CooldownViewerAlert_SetType(alert, alertType)
	alert[COOLDOWN_ALERT_FIELD_TYPE] = alertType;
end

function CooldownViewerAlert_GetType(alert)
	return alert[COOLDOWN_ALERT_FIELD_TYPE];
end

function CooldownViewerAlert_GetTypeText(alert)
	return alertTypeText[CooldownViewerAlert_GetType(alert)] or "";
end

function CooldownViewerAlert_SetEvent(alert, alertEvent)
	alert[COOLDOWN_ALERT_FIELD_EVENT] = alertEvent;
end

function CooldownViewerAlert_GetEvent(alert)
	return alert[COOLDOWN_ALERT_FIELD_EVENT];
end

function CooldownViewerAlert_GetEventText(alert)
	return alertWhenText[CooldownViewerAlert_GetEvent(alert)] or "";
end

function CooldownViewerAlert_SetPayload(alert, alertPayload)
	alert[COOLDOWN_ALERT_FIELD_PAYLOAD] = alertPayload;
end

function CooldownViewerAlert_GetPayload(alert)
	return alert[COOLDOWN_ALERT_FIELD_PAYLOAD];
end

function CooldownViewerAlert_GetPayloadText(alert)
	local alertPayload = CooldownViewerAlert_GetPayload(alert);
	if CooldownViewerAlert_GetType(alert) == Enum.CooldownViewerAlertType.Sound then
		return alertSoundTypeText[alertPayload] or "";
	end

	return "";
end

function CooldownViewerAlert_GetValues(alert)
	return unpack(alert);
end

function CooldownViewerAlert_Matches(alert1, alert2)
	return tCompare(alert1, alert2);
end

function CooldownViewerAlert_MatchesTypeAndEvent(alert1, alert2)
	return alert1[COOLDOWN_ALERT_FIELD_TYPE] == alert2[COOLDOWN_ALERT_FIELD_TYPE] and
		   alert1[COOLDOWN_ALERT_FIELD_EVENT] == alert2[COOLDOWN_ALERT_FIELD_EVENT];
end

local ttsAlertFormatters =
{
	[Enum.CooldownViewerAlertEventType.Available] = "%s is available",
	[Enum.CooldownViewerAlertEventType.PandemicTime] = "Reapply %s now",
	[Enum.CooldownViewerAlertEventType.OnCooldown] = "%s is on cooldown",
	[Enum.CooldownViewerAlertEventType.ChargeGained] = "%s gained a charge",
};

local function CooldownViewerAlert_PlayTTSAlert(spellName, alert)
	local alertEvent = CooldownViewerAlert_GetEvent(alert);
	local formatter = ttsAlertFormatters[alertEvent];
	if formatter and spellName then
		print(formatter:format(spellName));
	end
end

local function CooldownViewerAlert_PlaySoundAlert(spellName, alert)
	local alertPayload = CooldownViewerAlert_GetPayload(alert);
	local sound = CooldownViewerAlert_GetPayloadText(alert);
	print(("%s: %s"):format(spellName, sound));
end

local alertTypePlayer =
{
	[Enum.CooldownViewerAlertType.Sound] = function(spellName, alert)
		local alertPayload = CooldownViewerAlert_GetPayload(alert);

		if alertPayload == Enum.CooldownViewerSoundAlertType.TextToSpeech then
			CooldownViewerAlert_PlayTTSAlert(spellName, alert);
		else
			CooldownViewerAlert_PlaySoundAlert(spellName, alert);
		end
	end,
}

function CooldownViewerAlert_PlayAlert(spellName, alert)
	local alertType = CooldownViewerAlert_GetType(alert);
	local player = alertTypePlayer[alertType];
	if player then
		player(spellName, alert);
	end
end
