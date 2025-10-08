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

function CooldownViewerSettingsEditAlertMixin:GetCooldownID()
	return self.cooldownID;
end

function CooldownViewerSettingsEditAlertMixin:GetValidEventTypesForCooldown()
	local cooldownID = self:GetCooldownID();

	-- TODO: Add query API for valid events from cooldownID; something like C_CooldownViewer.GetValidAlertTypes...
	-- note: also requires that the event types be moved to tag
	if cooldownID then
		return { Enum.CooldownViewerAlertEventType.Available, Enum.CooldownViewerAlertEventType.PandemicTime, Enum.CooldownViewerAlertEventType.OnCooldown, Enum.CooldownViewerAlertEventType.ChargeGained };
	end

	return nil;
end

function CooldownViewerSettingsEditAlertMixin:DisplayForCooldown(cooldownItem)
	local alert = CooldownViewerAlert_Create(Enum.CooldownViewerAlertType.Sound, Enum.CooldownViewerAlertEventType.Available, CooldownViewerSound.ImpactsLowThud);
	local isNewAlert = true;
	self:DisplayForAlert(cooldownItem, alert, isNewAlert);
end

function CooldownViewerSettingsEditAlertMixin:DisplayForAlert(cooldownItem, alert, isNewAlert)
	self.originalAlert = alert;
	self.workingCopyOfAlert = CopyTable(alert);
	self.isNewAlert = isNewAlert;

	self:UpdateAddButton(isNewAlert);
	self:SetCooldown(cooldownItem);
	self:SetupDropdowns();
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

local eventTypeDropdownData =
{
	[Enum.CooldownViewerAlertEventType.Available] = COOLDOWN_VIEWER_SETTINGS_ALERT_WHEN_AVAILABLE,
	[Enum.CooldownViewerAlertEventType.PandemicTime] = COOLDOWN_VIEWER_SETTINGS_ALERT_WHEN_PANDEMIC,
	[Enum.CooldownViewerAlertEventType.OnCooldown] = COOLDOWN_VIEWER_SETTINGS_ALERT_WHEN_ON_COOLDOWN,
	[Enum.CooldownViewerAlertEventType.ChargeGained] = COOLDOWN_VIEWER_SETTINGS_ALERT_WHEN_CHARGE_GAINED,
};

local soundCategoryKeyToText =
{
	Animals = COOLDOWN_VIEWER_SETTINGS_SOUND_ALERT_CATEGORY_ANIMALS,
	Devices = COOLDOWN_VIEWER_SETTINGS_SOUND_ALERT_CATEGORY_DEVICES,
	Impacts = COOLDOWN_VIEWER_SETTINGS_SOUND_ALERT_CATEGORY_IMPACTS,
	Instruments = COOLDOWN_VIEWER_SETTINGS_SOUND_ALERT_CATEGORY_INSTRUMENTS,
	War2 = COOLDOWN_VIEWER_SETTINGS_SOUND_ALERT_CATEGORY_WAR2,
	War3 = COOLDOWN_VIEWER_SETTINGS_SOUND_ALERT_CATEGORY_WAR3,
}

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

	local validEventTypes = self:GetValidEventTypesForCooldown();
	self.EventDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("COOLDOWN_VIEWER_ALERT_EVENT");

		if validEventTypes then
			for _, eventType in ipairs(validEventTypes) do
				rootDescription:CreateButton(eventTypeDropdownData[eventType], SetAlertEvent, eventType);
			end
		else
			-- TODO: Add "nothing available...", or likely prevent the frame from showing up at all, this could be queried externally.
			rootDescription:CreateButton(COOLDOWN_VIEWER_SETTINGS_ALERT_WHEN_AVAILABLE, SetAlertEvent, Enum.CooldownViewerAlertEventType.Available);
		end
	end);

	local function SetAlertPayload(elementData, _inputData, _menuProxy)
		CooldownViewerAlert_SetPayload(self.workingCopyOfAlert, elementData);
	end

	self.PayloadDropdown:SetSelectionText(function(selections)
		return CooldownViewerAlert_GetPayloadText(self.workingCopyOfAlert);
	end);

	local function BuildSoundMenus(description, currentTable)
		for key, value in pairs (currentTable) do
			if value.soundEnum and value.text then
				description:CreateButton(value.text, SetAlertPayload, value.soundEnum);
			elseif type(value) == "table" then
				local nestedDescription = description:CreateButton(soundCategoryKeyToText[key], nop, -1);
				BuildSoundMenus(nestedDescription, value);
			end
		end
	end

	self.PayloadDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("COOLDOWN_VIEWER_ALERT_PAYLOAD");
		BuildSoundMenus(rootDescription, CooldownViewerSoundData);
		rootDescription:CreateButton(COOLDOWN_VIEWER_SETTINGS_ALERT_LABEL_SOUND_TYPE_TEXT_TO_SPEECH, SetAlertPayload, CooldownViewerSound.TextToSpeech);

	end);
end
