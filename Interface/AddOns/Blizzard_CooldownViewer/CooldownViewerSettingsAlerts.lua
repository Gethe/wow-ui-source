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
	self.cooldownName = cooldownItem:GetNameText();
	self.validCooldownAlertTypes  = cooldownItem:GetValidAlertTypes();

	self.Icon:SetTexture(cooldownItem:GetSpellTexture());
	self.CooldownName:SetText(cooldownItem:GetNameText());
end

function CooldownViewerSettingsEditAlertMixin:GetCooldownID()
	return self.cooldownID;
end

function CooldownViewerSettingsEditAlertMixin:GetCooldownName()
	return self.cooldownName;
end

function CooldownViewerSettingsEditAlertMixin:GetValidEventTypesForCooldown()
	return self.validCooldownAlertTypes;
end

local defaultPayloadForAlertType = {
	[Enum.CooldownViewerAlertType.Sound] = CooldownViewerSound.ImpactsLowThud,
	[Enum.CooldownViewerAlertType.Visual] = CooldownViewerVisual.MarchingAnts,
};

function CooldownViewerSettingsEditAlertMixin:DisplayForCooldown(cooldownItem)
	-- Only pick an initial default from the set of valid events for this cooldownItem.
	local firstEvent = cooldownItem:GetFirstValidAlertType();
	assertsafe(firstEvent ~= nil, "DisplayForCooldown invoked when cooldown %d doesn't support events", tostring(cooldownItem:GetCooldownID()));

	local alert = CooldownViewerAlert_Create(Enum.CooldownViewerAlertType.Sound, firstEvent, defaultPayloadForAlertType[Enum.CooldownViewerAlertType.Sound]);
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

local alertTypeToPayloadLabelText =
{
	[Enum.CooldownViewerAlertType.Sound] = COOLDOWN_VIEWER_SETTINGS_ALERT_DIALOG_LABEL_SOUND_TYPE,
	[Enum.CooldownViewerAlertType.Visual] = COOLDOWN_VIEWER_SETTINGS_ALERT_DIALOG_LABEL_VISUAL_TYPE,
};

function CooldownViewerSettingsEditAlertMixin:SetupDropdowns()
	local function SetAlertType(elementData, _inputData, _menuProxy)
		-- NOTE: It's possible for the user to reselect the same thing and this is still called, so don't do the extra work if that's the case
		if CooldownViewerAlert_GetType(self.workingCopyOfAlert) ~= elementData then
			CooldownViewerAlert_SetType(self.workingCopyOfAlert, elementData);
			CooldownViewerAlert_SetPayload(self.workingCopyOfAlert, defaultPayloadForAlertType[elementData]);

			self:SetupDropdowns();
		end
	end

	self.TypeDropdown:SetSelectionText(function(selections)
		return CooldownViewerAlert_GetTypeText(self.workingCopyOfAlert);
	end);

	self.TypeDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("COOLDOWN_VIEWER_ALERT_TYPE");
		rootDescription:CreateButton(COOLDOWN_VIEWER_SETTINGS_ALERT_TYPE_SOUND, SetAlertType, Enum.CooldownViewerAlertType.Sound);
		rootDescription:CreateButton(COOLDOWN_VIEWER_SETTINGS_ALERT_TYPE_VISUAL, SetAlertType, Enum.CooldownViewerAlertType.Visual);
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
			for eventType in pairs(validEventTypes) do
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

	local function AddSoundAlertButton(description, buttonText, alertPayload)
		local selectPayloadButton = description:CreateButton(buttonText, SetAlertPayload, alertPayload);
		selectPayloadButton:AddInitializer(function(button, description, menu)
			local playSampleButton = MenuTemplates.AttachUtilityButton(button);
			playSampleButton.Texture:Hide();
			CooldownViewerAlert_SetupTypeButton(playSampleButton, Enum.CooldownViewerAlertType.Sound);

			MenuTemplates.SetUtilityButtonTooltipText(playSampleButton, COOLDOWN_VIEWER_SETTINGS_ALERT_MENU_PLAY_SAMPLE);
			MenuTemplates.SetUtilityButtonAnchor(playSampleButton, MenuVariants.GearButtonAnchor, button); -- gear means throw on the right
			MenuTemplates.SetUtilityButtonClickHandler(playSampleButton, function()
				local alert = CooldownViewerAlert_Create(Enum.CooldownViewerAlertType.Sound, Enum.CooldownViewerAlertEventType.Available, alertPayload);
				CooldownViewerAlert_PlayAlert(self, self:GetCooldownName(), alert);
			end);
		end);
	end

	local function BuildSoundMenus(description, currentTable)
		for key, value in pairs (currentTable) do
			if value.soundEnum and value.text then
				AddSoundAlertButton(description, value.text, value.soundEnum);
			elseif type(value) == "table" then
				local nestedDescription = description:CreateButton(soundCategoryKeyToText[key], nop, -1);
				BuildSoundMenus(nestedDescription, value);
			end
		end
	end

	local function BuildVisualMenus(description, currentTable)
		for key, value in pairs (currentTable) do
			if value.enum and value.text then
				description:CreateButton(value.text, SetAlertPayload, value.enum);
			end
		end
	end

	self.PayloadDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("COOLDOWN_VIEWER_ALERT_PAYLOAD");

		local alertType = CooldownViewerAlert_GetType(self.workingCopyOfAlert);
		if alertType == Enum.CooldownViewerAlertType.Sound then
			BuildSoundMenus(rootDescription, CooldownViewerSoundData);
			AddSoundAlertButton(rootDescription, COOLDOWN_VIEWER_SETTINGS_ALERT_LABEL_SOUND_TYPE_TEXT_TO_SPEECH, CooldownViewerSound.TextToSpeech);
		elseif alertType == Enum.CooldownViewerAlertType.Visual then
			BuildVisualMenus(rootDescription, CooldownViewerVisualData);
		else
			assertsafe(false, "Unhandled alert type %s in SetupDropdowns", tostring(alertType));
		end
	end);

	-- Update the alert editing frame elements to match the current alert data.
	local alertType = CooldownViewerAlert_GetType(self.workingCopyOfAlert);
	self.PayloadLabel:SetText(alertTypeToPayloadLabelText[alertType]);
end
