CommunitiesGuildPreferredPlaySettingsFrameMixin = {};

local function GetLockoutSecondsRemaining(lastChangeDate, changeCooldownDays)
	if not lastChangeDate or lastChangeDate <= 0 then
		return 0;
	end

	local unlockTime = lastChangeDate + (changeCooldownDays * 24 * 60 * 60);
	return math.max(0, unlockTime - time());
end

local function BuildLockoutText(secondsRemaining)
	return format(PREFERRED_PLAY_SETTINGS_LOCKED_REASON_FORMAT, SecondsToTime(secondsRemaining));
end

local function FindNameForID(ids, names, targetID)
	if not ids then
		return nil;
	end

	for index, id in ipairs(ids) do
		if id == targetID then
			return (names and names[index]) or tostring(id);
		end
	end

	return nil;
end

-- All dropdowns share the same DropDownList frames, so the text has to be set explicitly rather
-- than letting UIDropDownMenu_SetSelectedValue derive it from whichever menu was populated last.
local function SetDropdownSelection(dropdown, selectedID, ids, names)
	UIDropDownMenu_SetSelectedValue(dropdown, selectedID);
	UIDropDownMenu_SetText(dropdown, FindNameForID(ids, names, selectedID) or "");
end

function CommunitiesGuildPreferredPlaySettingsFrameMixin:OnLoad()
	self.state = {
		loaded = false,
		preferredLocaleID = 0,
		preferredDatacenterLocalityID = 0,
		lastPreferredLocaleChangeDate = 0,
		lastPreferredDatacenterLocalityChangeDate = 0,
		changeCooldownDays = 0,
	};

	self.stagedLocaleID = 0;
	self.stagedDatacenterLocalityID = 0;

	self.Title:SetText(PREFERRED_PLAY_SETTINGS);
	self.LocaleLabel:SetText(PREFERRED_LOCALE_LABEL);
	self.DatacenterLabel:SetText(PREFERRED_GUILD_DATACENTER_LOCALITY_LABEL);
	self.LocaleApplyButton:SetMotionScriptsWhileDisabled(true);
	self.DatacenterApplyButton:SetMotionScriptsWhileDisabled(true);

	UIDropDownMenu_SetWidth(self.LocaleDropdown, 180);
	UIDropDownMenu_Initialize(self.LocaleDropdown, function(dropdown, level)
		self:InitializeLocaleDropdown(level);
	end);

	UIDropDownMenu_SetWidth(self.DatacenterDropdown, 180);
	UIDropDownMenu_Initialize(self.DatacenterDropdown, function(dropdown, level)
		self:InitializeDatacenterDropdown(level);
	end);

	self:RegisterEvent("GUILD_PREFERRED_PLAY_SETTINGS_UPDATED");
end

function CommunitiesGuildPreferredPlaySettingsFrameMixin:OnShow()
	self:RefreshState();

	local startedSuccessfully = C_GuildInfo.RequestPreferredPlaySettings();
	if not startedSuccessfully then
		self:RefreshState();
	end
end

function CommunitiesGuildPreferredPlaySettingsFrameMixin:OnHide()
end

function CommunitiesGuildPreferredPlaySettingsFrameMixin:OnEvent(event, ...)
	if event == "GUILD_PREFERRED_PLAY_SETTINGS_UPDATED" then
		self:RefreshState();
	end
end

function CommunitiesGuildPreferredPlaySettingsFrameMixin:RefreshState()
	local loaded, preferredLocaleID, preferredDatacenterLocalityID, lastPreferredLocaleChangeDate, lastPreferredDatacenterLocalityChangeDate, changeCooldownDays = C_GuildInfo.GetPreferredPlaySettings();

	self.state.loaded = loaded;
	self.state.preferredLocaleID = preferredLocaleID;
	self.state.preferredDatacenterLocalityID = preferredDatacenterLocalityID;
	self.state.lastPreferredLocaleChangeDate = lastPreferredLocaleChangeDate;
	self.state.lastPreferredDatacenterLocalityChangeDate = lastPreferredDatacenterLocalityChangeDate;
	self.state.changeCooldownDays = changeCooldownDays;

	if self.stagedLocaleID == 0 then
		self.stagedLocaleID = preferredLocaleID;
	end
	if self.stagedDatacenterLocalityID == 0 then
		self.stagedDatacenterLocalityID = preferredDatacenterLocalityID;
	end

	local isGuildMaster = IsGuildLeader();
	self.NotGuildMasterNotice:SetShown(not isGuildMaster);
	self.NotGuildMasterNotice:SetText(GUILD_PREFERRED_PLAY_SETTINGS_NO_PERMISSION);

	local canChangeLocale, canChangeDatacenterLocality = C_GuildInfo.GetPreferredPlaySettingsFeatures();

	self.LocaleDropdown:SetShown(canChangeLocale);
	self.LocaleApplyButton:SetShown(canChangeLocale);
	self.LocaleLabel:SetShown(canChangeLocale);
	if canChangeLocale then
		local localeIDs, localeNames = C_AccountServices.GetPreferredLocales();
		SetDropdownSelection(self.LocaleDropdown, self.stagedLocaleID, localeIDs, localeNames);
		UIDropDownMenu_EnableDropDown(self.LocaleDropdown);
		if not isGuildMaster then
			UIDropDownMenu_DisableDropDown(self.LocaleDropdown);
		end

		local localeLockoutSeconds = GetLockoutSecondsRemaining(lastPreferredLocaleChangeDate, changeCooldownDays);
		local canApplyLocale = isGuildMaster and loaded and localeLockoutSeconds == 0 and self.stagedLocaleID ~= preferredLocaleID;
		self.LocaleApplyButton:SetEnabled(canApplyLocale);
		if localeLockoutSeconds > 0 then
			self.LocaleApplyButton.lockoutTooltipText = BuildLockoutText(localeLockoutSeconds);
		else
			self.LocaleApplyButton.lockoutTooltipText = nil;
		end
	end

	self.DatacenterDropdown:SetShown(canChangeDatacenterLocality);
	self.DatacenterApplyButton:SetShown(canChangeDatacenterLocality);
	self.DatacenterLabel:SetShown(canChangeDatacenterLocality);
	if canChangeDatacenterLocality then
		local datacenterLocalityIDs, datacenterLocalityNames = C_AccountServices.GetPreferredDatacenterLocalities();
		SetDropdownSelection(self.DatacenterDropdown, self.stagedDatacenterLocalityID, datacenterLocalityIDs, datacenterLocalityNames);
		UIDropDownMenu_EnableDropDown(self.DatacenterDropdown);
		if not isGuildMaster then
			UIDropDownMenu_DisableDropDown(self.DatacenterDropdown);
		end

		local datacenterLockoutSeconds = GetLockoutSecondsRemaining(lastPreferredDatacenterLocalityChangeDate, changeCooldownDays);
		local canApplyDatacenter = isGuildMaster and loaded and datacenterLockoutSeconds == 0 and self.stagedDatacenterLocalityID ~= preferredDatacenterLocalityID;
		self.DatacenterApplyButton:SetEnabled(canApplyDatacenter);
		if datacenterLockoutSeconds > 0 then
			self.DatacenterApplyButton.lockoutTooltipText = BuildLockoutText(datacenterLockoutSeconds);
		else
			self.DatacenterApplyButton.lockoutTooltipText = nil;
		end
	end
end

function CommunitiesGuildPreferredPlaySettingsFrameMixin:InitializeLocaleDropdown(level)
	local localeIDs, localeNames = C_AccountServices.GetPreferredLocales();
	localeIDs = localeIDs or {};
	localeNames = localeNames or {};

	for index, localeID in ipairs(localeIDs) do
		local info = UIDropDownMenu_CreateInfo();
		info.text = localeNames[index] or tostring(localeID);
		info.value = localeID;
		info.func = function(button)
			self.stagedLocaleID = button.value;
			SetDropdownSelection(self.LocaleDropdown, button.value, localeIDs, localeNames);
			self:RefreshState();
		end;
		info.checked = (self.stagedLocaleID == localeID);
		UIDropDownMenu_AddButton(info, level);
	end
end

function CommunitiesGuildPreferredPlaySettingsFrameMixin:InitializeDatacenterDropdown(level)
	local datacenterLocalityIDs, datacenterLocalityNames = C_AccountServices.GetPreferredDatacenterLocalities();
	datacenterLocalityIDs = datacenterLocalityIDs or {};
	datacenterLocalityNames = datacenterLocalityNames or {};

	for index, datacenterLocalityID in ipairs(datacenterLocalityIDs) do
		local info = UIDropDownMenu_CreateInfo();
		info.text = datacenterLocalityNames[index] or tostring(datacenterLocalityID);
		info.value = datacenterLocalityID;
		info.func = function(button)
			self.stagedDatacenterLocalityID = button.value;
			SetDropdownSelection(self.DatacenterDropdown, button.value, datacenterLocalityIDs, datacenterLocalityNames);
			self:RefreshState();
		end;
		info.checked = (self.stagedDatacenterLocalityID == datacenterLocalityID);
		UIDropDownMenu_AddButton(info, level);
	end
end

function CommunitiesGuildPreferredPlaySettingsFrameMixin:ApplyLocaleSelection()
	if self.stagedLocaleID ~= self.state.preferredLocaleID then
		C_GuildInfo.SetPreferredPlaySettings(self.stagedLocaleID, 0);
	end
end

function CommunitiesGuildPreferredPlaySettingsFrameMixin:ApplyDatacenterLocalitySelection()
	if self.stagedDatacenterLocalityID ~= self.state.preferredDatacenterLocalityID then
		C_GuildInfo.SetPreferredPlaySettings(0, self.stagedDatacenterLocalityID);
	end
end

function CommunitiesGuildPreferredPlaySettingsFrame_OnLocaleApplyButtonClick(button)
	button:GetParent():ApplyLocaleSelection();
end

function CommunitiesGuildPreferredPlaySettingsFrame_OnLocaleApplyButtonEnter(button)
	if button.lockoutTooltipText then
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
		GameTooltip:SetText(button.lockoutTooltipText);
		GameTooltip:Show();
	end
end

function CommunitiesGuildPreferredPlaySettingsFrame_OnLocaleApplyButtonLeave(button)
	GameTooltip:Hide();
end

function CommunitiesGuildPreferredPlaySettingsFrame_OnDatacenterApplyButtonClick(button)
	button:GetParent():ApplyDatacenterLocalitySelection();
end

function CommunitiesGuildPreferredPlaySettingsFrame_OnDatacenterApplyButtonEnter(button)
	if button.lockoutTooltipText then
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
		GameTooltip:SetText(button.lockoutTooltipText);
		GameTooltip:Show();
	end
end

function CommunitiesGuildPreferredPlaySettingsFrame_OnDatacenterApplyButtonLeave(button)
	GameTooltip:Hide();
end
