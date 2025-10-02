CooldownViewerSettingsEditAlertMixin = {};

function CooldownViewerSettingsEditAlertMixin:SetOwner(owner)
	self.owner = owner;
	self:SetParent(owner);
	self:SetPoint("TOPLEFT", owner, "TOPRIGHT", owner:GetExtraPanelWidth(), 0);
end

function CooldownViewerSettingsEditAlertMixin:OnLoad()
	self.AddAlertButton:SetScript("OnClick", function()
		self:AddCurrentAlert();
	end);
end

function CooldownViewerSettingsEditAlertMixin:OnShow()
	SetUIPanelAttribute(self.owner, "extraWidth", self:GetWidth() + (2 * self.owner:GetExtraPanelWidth()));
	UpdateUIPanelPositions(self.owner);
end

function CooldownViewerSettingsEditAlertMixin:OnHide()
	SetUIPanelAttribute(self.owner, "extraWidth", self.owner:GetExtraPanelWidth());
	UpdateUIPanelPositions(self.owner);
end

function CooldownViewerSettingsEditAlertMixin:SetCooldown(cooldownItem)
	-- NOTE: Cannot save the item here, it comes from a pool that could be refreshed.
	-- TODO: When the alert is added to the cooldown after clicking the "Add Alert" button
	-- the CooldownViewerSettings frame needs to update the relevant cooldownItem that was modified
	-- if it's still visible by calling item:RefreshAlertTypeOverlay();
	self.cooldownID = cooldownItem:GetCooldownID();

	self.Icon:SetTexture(cooldownItem:GetSpellTexture());
	self.CooldownName:SetText(cooldownItem:GetNameText());
end

function CooldownViewerSettingsEditAlertMixin:DisplayForCooldown(cooldownItem)
	local alert = CooldownViewerAlert_Create(Enum.CooldownViewerAlertType.Sound, Enum.CooldownViewerAlertEventType.Available, Enum.CooldownViewerSoundAlertType.Ding1);
	local isNewAlert = true;
	self:DisplayForAlert(cooldownItem, alert, isNewAlert);
end

function CooldownViewerSettingsEditAlertMixin:DisplayForAlert(cooldownItem, alert, isNewAlert)
	self.originalAlert = alert;
	self.workingCopyOfAlert = CopyTable(alert);
	self.isNewAlert = isNewAlert;

	self:UpdateAddButton(isNewAlert);
	self:SetCooldown(cooldownItem);
	self:SetupDropdowns(needsAddToCooldown);
	self:Show();
end

function CooldownViewerSettingsEditAlertMixin:UpdateAddButton(isNewAlert)
	self.AddAlertButton:SetText(isNewAlert and COOLDOWN_VIEWER_SETTINGS_ALERT_MENU_BUTTON_ADD_ALERT or COOLDOWN_VIEWER_SETTINGS_ALERT_MENU_BUTTON_EDIT_EXISTING_ALERT);
end

function CooldownViewerSettingsEditAlertMixin:AddCurrentAlert()
	local status;
	if self.isNewAlert then
		status = self.owner:GetLayoutManager():AddAlert(self.cooldownID, self.workingCopyOfAlert);
	else
		status = self.owner:GetLayoutManager():UpdateAlert(self.cooldownID, self.originalAlert, self.workingCopyOfAlert);
	end

	self:Hide();
	self.owner:RefreshLayout();
	return status;
end

function CooldownViewerSettingsEditAlertMixin:SetupDropdowns()
	local function SetAlertType(elementData, _inputData, _menuProxy)
		CooldownViewerAlert_SetType(self.workingCopyOfAlert, elementData);
	end

	self.TypeDropdown:SetSelectionText(function(selections)
		return CooldownViewerAlert_GetTypeText(self.workingCopyOfAlert);
	end);

	self.TypeDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("COOLDOWN_VIEWER_ALERT_TYPE");
		rootDescription:CreateButton(COOLDOWN_VIEWER_SETTINGS_ALERT_TYPE_SOUND, SetAlertType, Enum.CooldownViewerAlertType.Sound);
	end);

	local function SetAlertEvent(elementData, _inputData, _menuProxy)
		CooldownViewerAlert_SetEvent(self.workingCopyOfAlert, elementData);
	end

	self.EventDropdown:SetSelectionText(function(selections)
		return CooldownViewerAlert_GetEventText(self.workingCopyOfAlert);
	end);

	self.EventDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("COOLDOWN_VIEWER_ALERT_EVENT");
		rootDescription:CreateButton(COOLDOWN_VIEWER_SETTINGS_ALERT_WHEN_AVAILABLE, SetAlertEvent, Enum.CooldownViewerAlertEventType.Available);
		rootDescription:CreateButton(COOLDOWN_VIEWER_SETTINGS_ALERT_WHEN_PANDEMIC, SetAlertEvent, Enum.CooldownViewerAlertEventType.PandemicTime);
		rootDescription:CreateButton(COOLDOWN_VIEWER_SETTINGS_ALERT_WHEN_ON_COOLDOWN, SetAlertEvent, Enum.CooldownViewerAlertEventType.OnCooldown);
		rootDescription:CreateButton(COOLDOWN_VIEWER_SETTINGS_ALERT_WHEN_CHARGE_GAINED, SetAlertEvent, Enum.CooldownViewerAlertEventType.ChargeGained);
	end);

	local function SetAlertPayload(elementData, _inputData, _menuProxy)
		CooldownViewerAlert_SetPayload(self.workingCopyOfAlert, elementData);
	end

	self.PayloadDropdown:SetSelectionText(function(selections)
		return CooldownViewerAlert_GetPayloadText(self.workingCopyOfAlert);
	end);

	self.PayloadDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("COOLDOWN_VIEWER_ALERT_PAYLOAD");
		rootDescription:CreateButton(COOLDOWN_VIEWER_SETTINGS_ALERT_LABEL_SOUND_TYPE_DING1, SetAlertPayload, Enum.CooldownViewerSoundAlertType.Ding1);
		rootDescription:CreateButton(COOLDOWN_VIEWER_SETTINGS_ALERT_LABEL_SOUND_TYPE_DING2, SetAlertPayload, Enum.CooldownViewerSoundAlertType.Ding2);
		rootDescription:CreateButton(COOLDOWN_VIEWER_SETTINGS_ALERT_LABEL_SOUND_TYPE_DING3, SetAlertPayload, Enum.CooldownViewerSoundAlertType.Ding3);
		rootDescription:CreateButton(COOLDOWN_VIEWER_SETTINGS_ALERT_LABEL_SOUND_TYPE_DING4, SetAlertPayload, Enum.CooldownViewerSoundAlertType.Ding4);
		rootDescription:CreateButton(COOLDOWN_VIEWER_SETTINGS_ALERT_LABEL_SOUND_TYPE_TEXT_TO_SPEECH, SetAlertPayload, Enum.CooldownViewerSoundAlertType.TextToSpeech);
	end);
end
