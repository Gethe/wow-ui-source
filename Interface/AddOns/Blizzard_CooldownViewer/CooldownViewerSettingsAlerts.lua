CooldownViewerSettingsEditAlertMixin = CreateFromMixins(CooldownViewerEditAlertBaseMixin);

function CooldownViewerSettingsEditAlertMixin:OnLoad()
	CooldownViewerEditAlertBaseMixin.OnLoad(self);
	self.PrimaryLabel:SetText(COOLDOWN_VIEWER_SETTINGS_ALERT_DIALOG_LABEL_TYPE);
end

function CooldownViewerSettingsEditAlertMixin:SetCooldown(cooldownItem)
	-- NOTE: Cannot save the item here, it comes from a pool that could be refreshed.
	-- TODO: When the alert is added to the cooldown after clicking the "Add Alert" button
	-- the CooldownViewerSettings frame needs to update the relevant cooldownItem that was modified
	-- if it's still visible by calling item:RefreshAlertTypeOverlay();
	self.cooldownID = cooldownItem:GetCooldownID();
	self.cooldownName = cooldownItem:GetNameText();
	self.validCooldownAlertTypes  = cooldownItem:GetValidAlertTypes();

	self:GetIcon():SetTexture(cooldownItem:GetSpellTexture());
	self:GetNameLabel():SetText(cooldownItem:GetNameText());
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
	[Enum.CooldownViewerAlertType.Sound] = Enum.CooldownViewerSound.ImpactsLowThud,
	[Enum.CooldownViewerAlertType.Visual] = Enum.VisualAlertType.MarchingAnts,
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

	self:SetCooldown(cooldownItem);
	self:SetupDropdowns();
	self:Display(isNewAlert);
end

function CooldownViewerSettingsEditAlertMixin:AddCurrentAlert()
	if self.isNewAlert then
		self.owner:GetLayoutManager():AddAlert(self.cooldownID, self.workingCopyOfAlert);
	else
		self.owner:GetLayoutManager():UpdateAlert(self.cooldownID, self.originalAlert, self.workingCopyOfAlert);
	end

	self.owner:RefreshLayout();
end

local alertTypeToPayloadLabelText =
{
	[Enum.CooldownViewerAlertType.Sound] = COOLDOWN_VIEWER_SETTINGS_ALERT_DIALOG_LABEL_SOUND_TYPE,
	[Enum.CooldownViewerAlertType.Visual] = COOLDOWN_VIEWER_SETTINGS_ALERT_DIALOG_LABEL_VISUAL_TYPE,
};

function CooldownViewerSettingsEditAlertMixin:SetupDropdowns()
	-- Type dropdown.
	local function IsAlertTypeSelected(type)
		return CooldownViewerAlert_GetType(self.workingCopyOfAlert) == type;
	end

	local function SetAlertType(type)
		-- NOTE: It's possible for the user to reselect the same thing and this is still called, so don't do the extra work if that's the case
		if CooldownViewerAlert_GetType(self.workingCopyOfAlert) ~= type then
			CooldownViewerAlert_SetType(self.workingCopyOfAlert, type);
			CooldownViewerAlert_SetPayload(self.workingCopyOfAlert, defaultPayloadForAlertType[type]);

			self:SetupDropdowns();
		end
	end

	self.TypeDropdown:SetSelectionText(function(_selections)
		return CooldownViewerAlert_GetTypeText(self.workingCopyOfAlert);
	end);

	self.TypeDropdown:SetupMenu(function(_dropdown, rootDescription)
		rootDescription:SetTag("COOLDOWN_VIEWER_ALERT_TYPE");
		rootDescription:CreateRadio(COOLDOWN_VIEWER_SETTINGS_ALERT_TYPE_SOUND, IsAlertTypeSelected, SetAlertType, Enum.CooldownViewerAlertType.Sound);
		rootDescription:CreateRadio(COOLDOWN_VIEWER_SETTINGS_ALERT_TYPE_VISUAL, IsAlertTypeSelected, SetAlertType, Enum.CooldownViewerAlertType.Visual);
	end);

	-- Event dropdown.
	local function IsAlertEventSelected(event)
		return CooldownViewerAlert_GetEvent(self.workingCopyOfAlert) == event;
	end

	local function SetAlertEvent(event)
		CooldownViewerAlert_SetEvent(self.workingCopyOfAlert, event);
	end

	self.EventDropdown:SetSelectionText(function(selections)
		return CooldownViewerAlert_GetEventText(self.workingCopyOfAlert);
	end);

	local validEventTypes = self:GetValidEventTypesForCooldown();
	self.EventDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("COOLDOWN_VIEWER_ALERT_EVENT");

		if validEventTypes then
			for eventType in pairs(validEventTypes) do
				rootDescription:CreateRadio(CooldownViewerAlert_GetEventText(eventType), IsAlertEventSelected, SetAlertEvent, eventType);
			end
		else
			-- TODO: Add "nothing available...", or likely prevent the frame from showing up at all, this could be queried externally.
			rootDescription:CreateRadio(COOLDOWN_VIEWER_SETTINGS_ALERT_WHEN_AVAILABLE, IsAlertEventSelected, SetAlertEvent, Enum.CooldownViewerAlertEventType.Available);
		end
	end);

	-- Payload dropdown.
	local function IsAlertPayloadSelected(payload)
		return CooldownViewerAlert_GetPayload(self.workingCopyOfAlert) == payload;
	end

	local function SetAlertPayload(payload)
		CooldownViewerAlert_SetPayload(self.workingCopyOfAlert, payload);
	end

	self.PayloadDropdown:SetSelectionText(function(selections)
		return CooldownViewerAlert_GetPayloadText(self.workingCopyOfAlert);
	end);

	local function BuildVisualMenus(description)
		VisualAlertData_ForEach(function(visualData)
			description:CreateRadio(visualData.text, IsAlertPayloadSelected, SetAlertPayload, visualData.enum);
		end);
	end

	self.PayloadDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("COOLDOWN_VIEWER_ALERT_PAYLOAD");

		local alertType = CooldownViewerAlert_GetType(self.workingCopyOfAlert);
		if alertType == Enum.CooldownViewerAlertType.Sound then
			-- Sound menus are in Util methods as some game settings also use them.
			local useHighlightStyle = false;
			CooldownViewerUtil.BuildSoundMenus(rootDescription, IsAlertPayloadSelected, SetAlertPayload, useHighlightStyle);

			local alertDataTTS = {
				text = COOLDOWN_VIEWER_SETTINGS_ALERT_LABEL_SOUND_TYPE_TEXT_TO_SPEECH,
				soundEnum = Enum.CooldownViewerSound.TextToSpeech,
				spellName = self:GetCooldownName()
			};

			local CreateRadio = GenerateClosure(rootDescription.CreateRadio, rootDescription);
			CooldownViewerUtil.AddSoundAlertRadio(alertDataTTS, CreateRadio, IsAlertPayloadSelected, SetAlertPayload, useHighlightStyle);
		elseif alertType == Enum.CooldownViewerAlertType.Visual then
			BuildVisualMenus(rootDescription);
		else
			assertsafe(false, "Unhandled alert type %s in SetupDropdowns", tostring(alertType));
		end
	end);

	-- Update the alert editing frame elements to match the current alert data.
	local alertType = CooldownViewerAlert_GetType(self.workingCopyOfAlert);
	self.PayloadLabel:SetText(alertTypeToPayloadLabelText[alertType]);
end

function CooldownViewerContextMenu_AddNewAlertButton(rootDescription, text, isEnabled, onClickCallback, disabledTooltipCallback)
	local newAlertButton = rootDescription:CreateButton(text, onClickCallback);

	newAlertButton:SetEnabled(isEnabled);

	if not isEnabled and disabledTooltipCallback then
		newAlertButton:SetTooltip(disabledTooltipCallback);
	end

	newAlertButton:AddInitializer(function(button, description, menu)
		local texture = button:AttachTexture();
		texture:SetPoint("LEFT");
		texture:SetAtlas(isEnabled and "editmode-new-layout-plus" or "editmode-new-layout-plus-disabled", true);
		button.fontString:ClearAllPoints();
		button.fontString:SetPoint("LEFT", texture, "RIGHT", 3, 0);
	end);
end

function CooldownViewerContextMenu_AddAlertEntryButton(rootDescription, alertType, payloadText, eventText, editCallback, deleteCallback, playSampleCallback)
	local alertButton = rootDescription:CreateButton("temp", playSampleCallback or nop, 1);

	alertButton:AddInitializer(function(button, description, menu)
		local typeIconButton = MenuTemplates.AttachBasicButton(button, 25, 25);
		typeIconButton:SetPoint("TOPLEFT");
		CooldownViewerAlert_SetupTypeButton(typeIconButton, alertType);

		if playSampleCallback then
			MenuTemplates.SetUtilityButtonTooltipText(typeIconButton, COOLDOWN_VIEWER_SETTINGS_ALERT_MENU_PLAY_SAMPLE);
			MenuTemplates.SetUtilityButtonClickHandler(typeIconButton, playSampleCallback);
			description.playSampleButton = typeIconButton;
		else
			typeIconButton:SetEnabled(false);
		end

		local payloadFontString = button.fontString;
		payloadFontString:SetFontObject("GameFontNormalLarge");
		payloadFontString:SetSize(0, 0);
		payloadFontString:ClearAllPoints();
		payloadFontString:SetPoint("TOPLEFT", typeIconButton, "TOPRIGHT", 3, 0);
		payloadFontString:SetText(payloadText);

		if eventText then
			local eventFontString = button:AttachFontString();
			eventFontString:SetFontObject("GameFontHighlightSmall");
			eventFontString:SetSize(0, 0);
			eventFontString:ClearAllPoints();
			eventFontString:SetPoint("TOPLEFT", payloadFontString, "BOTTOMLEFT", 0, -5);
			eventFontString:SetText(eventText);
		end

		local editButton = MenuTemplates.AttachAutoHideGearButton(button);
		MenuTemplates.SetUtilityButtonTooltipText(editButton, COOLDOWN_VIEWER_SETTINGS_ALERT_MENU_BUTTON_TOOLTIP_EDIT);
		MenuTemplates.SetUtilityButtonAnchor(editButton, MenuVariants.GearButtonAnchor, button);
		MenuTemplates.SetUtilityButtonClickHandler(editButton, function()
			editCallback();
			menu:Close();
		end);

		local deleteButton = MenuTemplates.AttachAutoHideCancelButton(button);
		MenuTemplates.SetUtilityButtonTooltipText(deleteButton, COOLDOWN_VIEWER_SETTINGS_ALERT_MENU_BUTTON_TOOLTIP_DELETE);
		MenuTemplates.SetUtilityButtonAnchor(deleteButton, MenuVariants.CancelButtonAnchor, editButton);
		MenuTemplates.SetUtilityButtonClickHandler(deleteButton, function()
			deleteCallback();
			menu:Close();
		end);

		description.deleteButton = deleteButton;
	end);
end
