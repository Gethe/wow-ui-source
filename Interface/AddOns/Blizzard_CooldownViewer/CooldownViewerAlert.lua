local alertTypeText =
{
	[Enum.CooldownViewerAlertType.Sound] = COOLDOWN_VIEWER_SETTINGS_ALERT_TYPE_SOUND,
	[Enum.CooldownViewerAlertType.Visual] = COOLDOWN_VIEWER_SETTINGS_ALERT_TYPE_VISUAL,
}

local alertWhenText =
{
	[Enum.CooldownViewerAlertEventType.Available] = COOLDOWN_VIEWER_SETTINGS_ALERT_WHEN_AVAILABLE,
	[Enum.CooldownViewerAlertEventType.PandemicTime] = COOLDOWN_VIEWER_SETTINGS_ALERT_WHEN_PANDEMIC,
	[Enum.CooldownViewerAlertEventType.OnCooldown] = COOLDOWN_VIEWER_SETTINGS_ALERT_WHEN_ON_COOLDOWN,
	[Enum.CooldownViewerAlertEventType.ChargeGained] = COOLDOWN_VIEWER_SETTINGS_ALERT_WHEN_CHARGE_GAINED,
	[Enum.CooldownViewerAlertEventType.OnAuraApplied] = COOLDOWN_VIEWER_SETTINGS_ALERT_WHEN_AURA_APPLIED,
	[Enum.CooldownViewerAlertEventType.OnAuraRemoved] = COOLDOWN_VIEWER_SETTINGS_ALERT_WHEN_AURA_REMOVED,
};

function CooldownViewerAlert_GetTypeAtlas(alertType)
	if alertType == Enum.CooldownViewerAlertType.Sound then
		return "common-icon-sound";
	elseif alertType == Enum.CooldownViewerAlertType.Visual then
		return "common-icon-visual";
	end
end

function CooldownViewerAlert_SetupTypeButton(button, alertType)
	if alertType == Enum.CooldownViewerAlertType.Sound then
		button:SetNormalTexture("common-icon-sound");
		button:SetPushedTexture("common-icon-sound-pressed");
		button:SetDisabledTexture("common-icon-sound-disabled");
		button:SetHighlightTexture("common-icon-sound", "ADD");
		button:GetHighlightTexture():SetAlpha(0.4);
	elseif alertType == Enum.CooldownViewerAlertType.Visual then
		button:SetNormalTexture("common-icon-visual");
		button:SetPushedTexture("common-icon-visual-pressed");
		button:SetDisabledTexture("common-icon-visual-disabled");
		button:SetHighlightTexture("common-icon-visual-disabled", "ADD");
		button:GetHighlightTexture():SetAlpha(0.4);
	end
end

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

local legalAlertTypes =
{
	[Enum.CooldownViewerAlertType.Sound] = true,
	[Enum.CooldownViewerAlertType.Visual] = true,
}

function CooldownViewerAlert_GetAlertStatus(alert)
	local alertType, alertEvent = CooldownViewerAlert_GetValues(alert);

	if not legalAlertTypes[alertType] then
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

function CooldownViewerAlert_GetEventText(alertOrAlertEventType)
	if type(alertOrAlertEventType) == "table" then
		return alertWhenText[CooldownViewerAlert_GetEvent(alertOrAlertEventType)] or "";
	else
		return alertWhenText[alertOrAlertEventType] or "";
	end
end

function CooldownViewerAlert_SetPayload(alert, alertPayload)
	alert[COOLDOWN_ALERT_FIELD_PAYLOAD] = alertPayload;
end

function CooldownViewerAlert_GetPayload(alert)
	return alert[COOLDOWN_ALERT_FIELD_PAYLOAD];
end

function CooldownViewerAlert_GetPayloadText(alert)
	local alertPayload = CooldownViewerAlert_GetPayload(alert);
	local alertType = CooldownViewerAlert_GetType(alert);

	if alertType == Enum.CooldownViewerAlertType.Sound then
		if alertPayload == Enum.CooldownViewerSound.TextToSpeech then
			return COOLDOWN_VIEWER_SETTINGS_ALERT_LABEL_SOUND_TYPE_TEXT_TO_SPEECH;
		end

		return CooldownViewerUtil.GetSoundTypeText(alertPayload) or "";
	elseif alertType == Enum.CooldownViewerAlertType.Visual then
		return VisualAlert_GetTypeText(alertPayload) or "";
	end

	return "";
end

function CooldownViewerAlert_GetPayloadContextData(alert)
	local alertPayload = CooldownViewerAlert_GetPayload(alert);
	local alertType = CooldownViewerAlert_GetType(alert);
	if alertType == Enum.CooldownViewerAlertType.Sound then
		if alertPayload ~= Enum.CooldownViewerSound.TextToSpeech then
			return CooldownViewerUtil.GetSoundTypeSoundKit(alertPayload);
		end
	elseif alertType == Enum.CooldownViewerAlertType.Visual then
		return VisualAlert_GetTypeTemplate(alertPayload);
	end

	return nil;
end

function CooldownViewerAlert_GetValues(alert)
	return unpack(alert);
end

function CooldownViewerAlert_Matches(alert1, alert2)
	return tCompare(alert1, alert2);
end

-- TODO: Dust still settling, these may become global strings, or we may just always read only the spell name
local ttsAlertFormatters =
{
	[Enum.CooldownViewerAlertEventType.Available] = "%s",
	[Enum.CooldownViewerAlertEventType.PandemicTime] = "%s",
	[Enum.CooldownViewerAlertEventType.OnCooldown] = "%s",
	[Enum.CooldownViewerAlertEventType.ChargeGained] = "%s",
	[Enum.CooldownViewerAlertEventType.OnAuraApplied] = "%s",
	[Enum.CooldownViewerAlertEventType.OnAuraRemoved] = "%s",
};

local function CooldownViewerAlert_PlayTTSAlert(_cooldownItem, spellName, alert)
	local alertEvent = CooldownViewerAlert_GetEvent(alert);
	local formatter = ttsAlertFormatters[alertEvent];
	if formatter and spellName then
		local allowOverlappedSpeech = true;
		TextToSpeechFrame_PlayCooldownAlertMessage(alert, formatter:format(spellName), allowOverlappedSpeech);
	end
end

local function CooldownViewerAlert_PlaySoundAlert(_cooldownItem, _spellName, alert, soundSubType)
	local soundKit = CooldownViewerAlert_GetPayloadContextData(alert);
	if soundKit then
		local playSoundParams = {
			soundKitID = soundKit,
			uiSoundSubType = soundSubType,
		};
		C_Sound.PlaySoundWithOptions(playSoundParams);
	end
end

local function CooldownViewerAlert_PlayVisualAlert(cooldownItem, _spellName, alert)
	VisualAlertsManager:AcquireAlert(CooldownViewerAlert_GetPayload(alert), cooldownItem);
end

local alertTypePlayer =
{
	[Enum.CooldownViewerAlertType.Visual] = function(cooldownItem, spellName, alert, _soundSubType)
		CooldownViewerAlert_PlayVisualAlert(cooldownItem, spellName, alert);
	end,
	[Enum.CooldownViewerAlertType.Sound] = function(cooldownItem, spellName, alert, soundSubType)
		local alertPayload = CooldownViewerAlert_GetPayload(alert);

		if alertPayload == Enum.CooldownViewerSound.TextToSpeech then
			CooldownViewerAlert_PlayTTSAlert(cooldownItem, spellName, alert);
		else
			CooldownViewerAlert_PlaySoundAlert(cooldownItem, spellName, alert, soundSubType);
		end
	end,
}

function CooldownViewerAlert_PlayAlert(cooldownItem, spellName, alert, soundSubType)
	local alertType = CooldownViewerAlert_GetType(alert);
	local player = alertTypePlayer[alertType];
	if player then
		player(cooldownItem, spellName, alert, soundSubType);
	end
end
