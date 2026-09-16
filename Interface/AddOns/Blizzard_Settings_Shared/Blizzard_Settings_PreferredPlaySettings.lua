RequestPreferredPlaySettings = {}

local preferredPlayState = {
	loaded = false,
	preferredLocaleID = 0,
	preferredDatacenterLocalityID = 0,
	lastPreferredLocaleChangeDate = 0,
	lastPreferredDatacenterLocalityChangeDate = 0,
	changeCooldownDays = 0,
};

local stagedPreferredPlayState = {
	localeID = 0,
	datacenterLocalityID = 0,
};

local function RefreshPreferredPlayState()
	local loaded, preferredLocaleID, preferredDatacenterLocalityID, lastPreferredLocaleChangeDate, lastPreferredDatacenterLocalityChangeDate, changeCooldownDays = C_AccountServices.GetPreferredPlaySettings();
	preferredPlayState.loaded = loaded;
	preferredPlayState.preferredLocaleID = preferredLocaleID;
	preferredPlayState.preferredDatacenterLocalityID = preferredDatacenterLocalityID;
	preferredPlayState.lastPreferredLocaleChangeDate = lastPreferredLocaleChangeDate;
	preferredPlayState.lastPreferredDatacenterLocalityChangeDate = lastPreferredDatacenterLocalityChangeDate;
	preferredPlayState.changeCooldownDays = changeCooldownDays;

	if stagedPreferredPlayState.localeID < 1 then
		stagedPreferredPlayState.localeID = preferredPlayState.preferredLocaleID;
	end
	if stagedPreferredPlayState.datacenterLocalityID < 1 then
		stagedPreferredPlayState.datacenterLocalityID = preferredPlayState.preferredDatacenterLocalityID;
	end
	EventRegistry:TriggerEvent("PREFERRED_PLAY_SETTINGS_UPDATED");
end

local function RequestPreferredPlayState()
	local startedSuccessfully = C_AccountServices.RequestPreferredPlaySettings();
	if not startedSuccessfully then
		RefreshPreferredPlayState();
	end
end

local function GetLockoutSecondsRemaining(lastChangeDate, changeCooldownDays)
	if not lastChangeDate or lastChangeDate <= 0 then
		return 0;
	end

	local unlockTime = lastChangeDate + (changeCooldownDays * 24 * 60 * 60);
	return math.max(0, unlockTime - time());
end

local function BuildLockoutReason(secondsRemaining)
	return format(PREFERRED_PLAY_SETTINGS_LOCKED_REASON_FORMAT, SecondsToTime(secondsRemaining));
end

local function BuildLocaleOptions()
	local container = Settings.CreateControlTextContainer();
	local localeIDs, localeNames = C_AccountServices.GetPreferredLocales();
	localeIDs = localeIDs or {};
	localeNames = localeNames or {};

	for index, localeID in ipairs(localeIDs) do
		local optionLabel = localeNames[index] or (PREFERRED_PLAY_LOCALE_FALLBACK .. localeID);
		local option = container:Add(localeID, optionLabel);
		if not preferredPlayState.loaded and localeID ~= preferredPlayState.preferredLocaleID then
			option.disabled = true;
			option.disabledReason = PREFERRED_PLAY_SETTINGS_UNAVAILABLE_REASON;
		end
	end

	return container:GetData();
end

local function BuildDatacenterLocalityOptions()
	local container = Settings.CreateControlTextContainer();
	local datacenterLocalityIDs, datacenterLocalityNames = C_AccountServices.GetPreferredDatacenterLocalities();
	datacenterLocalityIDs = datacenterLocalityIDs or {};
	datacenterLocalityNames = datacenterLocalityNames or {};

	for index, datacenterLocalityID in ipairs(datacenterLocalityIDs) do
		local optionLabel = datacenterLocalityNames[index] or (PREFERRED_PLAY_DATACENTER_LOCALITY_FALLBACK .. datacenterLocalityID);
		local option = container:Add(datacenterLocalityID, optionLabel);
		if not preferredPlayState.loaded and datacenterLocalityID ~= preferredPlayState.preferredDatacenterLocalityID then
			option.disabled = true;
			option.disabledReason = PREFERRED_PLAY_SETTINGS_UNAVAILABLE_REASON;
		end
	end

	return container:GetData();
end

function RequestPreferredPlaySettings.Setup(category, layout)
	if Kiosk.IsEnabled() then
		return;
	end

	local canChangeLocale, canChangeDatacenterLocality = C_AccountServices.GetPreferredPlaySettingsFeatures();

	if not canChangeLocale and not canChangeDatacenterLocality then
		return;
	end

	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(LANGUAGES_SOCIAL_LABEL));

	RefreshPreferredPlayState();
	RequestPreferredPlayState();

	local addSearchTags = false;

	-- Locale Selector --

	local function GetPreferredLocaleID()
		return stagedPreferredPlayState.localeID;
	end

	local function SetPreferredLocaleID(preferredLocaleID)
		stagedPreferredPlayState.localeID = preferredLocaleID;
		EventRegistry:TriggerEvent("PREFERRED_PLAY_SETTINGS_SELECTION_CHANGED");
	end

	local function GetLocaleTooltip()
		if preferredPlayState.changeCooldownDays > 0 then
			return format(PREFERRED_LOCALE_TOOLTIP, preferredPlayState.changeCooldownDays);
		end
		return nil;
	end

	local function ApplyLocaleSelection()
		if stagedPreferredPlayState.localeID ~= preferredPlayState.preferredLocaleID then
			C_AccountServices.SetPreferredPlaySettings(stagedPreferredPlayState.localeID, 0);
		end
	end

	local function CanApplyLocale()
		local lockoutSecondsRemaining = GetLockoutSecondsRemaining(preferredPlayState.lastPreferredLocaleChangeDate, preferredPlayState.changeCooldownDays);
		return lockoutSecondsRemaining == 0 and preferredPlayState.loaded and stagedPreferredPlayState.localeID ~= preferredPlayState.preferredLocaleID;
	end

	local function GetLocaleApplyTooltip()
		local lockoutSecondsRemaining = GetLockoutSecondsRemaining(preferredPlayState.lastPreferredLocaleChangeDate, preferredPlayState.changeCooldownDays);
		if lockoutSecondsRemaining > 0 then
			return BuildLockoutReason(lockoutSecondsRemaining);
		end
		return nil;
	end

	if canChangeLocale then
		local localeSetting = Settings.RegisterProxySetting(category, "PROXY_PREFERRED_PLAY_LOCALE", Settings.VarType.Number, PREFERRED_LOCALE_LABEL, 0, GetPreferredLocaleID, SetPreferredLocaleID);
		stagedPreferredPlayState.localeID = preferredPlayState.preferredLocaleID;
		localeSetting:SetValue(preferredPlayState.preferredLocaleID);
		local localeInitializer = Settings.CreateDropdown(category, localeSetting, BuildLocaleOptions, GetLocaleTooltip);
		localeInitializer:AddEvaluateStateFrameEvent("PREFERRED_PLAY_SETTINGS_UPDATED");

		local applyLocaleButtonInitializer = CreateSettingsButtonInitializer("", APPLY, ApplyLocaleSelection, GetLocaleApplyTooltip, addSearchTags);
		applyLocaleButtonInitializer.data.buttonAlignment = "CENTER";
		applyLocaleButtonInitializer:AddModifyPredicate(CanApplyLocale);
		applyLocaleButtonInitializer:AddEvaluateStateFrameEvent("PREFERRED_PLAY_SETTINGS_UPDATED");
		applyLocaleButtonInitializer:AddEvaluateStateFrameEvent("PREFERRED_PLAY_SETTINGS_SELECTION_CHANGED");
		layout:AddInitializer(applyLocaleButtonInitializer);
	end

	-- Datacenter Locality Selector --

	local function GetPreferredDatacenterLocalityID()
		return stagedPreferredPlayState.datacenterLocalityID;
	end

	local function SetPreferredDatacenterLocalityID(preferredDatacenterLocalityID)
		stagedPreferredPlayState.datacenterLocalityID = preferredDatacenterLocalityID;
		EventRegistry:TriggerEvent("PREFERRED_PLAY_SETTINGS_SELECTION_CHANGED");
	end

	local function GetDatacenterLocalityTooltip()
		if preferredPlayState.changeCooldownDays > 0 then
			return format(PREFERRED_DATACENTER_LOCALITY_TOOLTIP, preferredPlayState.changeCooldownDays);
		end
		return nil;
	end

	local function ApplyDatacenterLocalitySelection()
		if stagedPreferredPlayState.datacenterLocalityID ~= preferredPlayState.preferredDatacenterLocalityID then
			C_AccountServices.SetPreferredPlaySettings(0, stagedPreferredPlayState.datacenterLocalityID);
		end
	end

	local function CanApplyDatacenterLocality()
		local lockoutSecondsRemaining = GetLockoutSecondsRemaining(preferredPlayState.lastPreferredDatacenterLocalityChangeDate, preferredPlayState.changeCooldownDays);
		return lockoutSecondsRemaining == 0 and preferredPlayState.loaded and stagedPreferredPlayState.datacenterLocalityID ~= preferredPlayState.preferredDatacenterLocalityID;
	end

	local function GetDatacenterLocalityApplyTooltip()
		local lockoutSecondsRemaining = GetLockoutSecondsRemaining(preferredPlayState.lastPreferredDatacenterLocalityChangeDate, preferredPlayState.changeCooldownDays);
		if lockoutSecondsRemaining > 0 then
			return BuildLockoutReason(lockoutSecondsRemaining);
		end
		return nil;
	end

	if canChangeDatacenterLocality then
		local datacenterLocalitySetting = Settings.RegisterProxySetting(category, "PROXY_PREFERRED_PLAY_DATACENTER_LOCALITY", Settings.VarType.Number, PREFERRED_DATACENTER_LOCALITY_LABEL, 0, GetPreferredDatacenterLocalityID, SetPreferredDatacenterLocalityID);
		stagedPreferredPlayState.datacenterLocalityID = preferredPlayState.preferredDatacenterLocalityID;
		datacenterLocalitySetting:SetValue(preferredPlayState.preferredDatacenterLocalityID);
		local datacenterLocalityInitializer = Settings.CreateDropdown(category, datacenterLocalitySetting, BuildDatacenterLocalityOptions, GetDatacenterLocalityTooltip);
		datacenterLocalityInitializer:AddEvaluateStateFrameEvent("PREFERRED_PLAY_SETTINGS_UPDATED");

		local applyDatacenterButtonInitializer = CreateSettingsButtonInitializer("", APPLY, ApplyDatacenterLocalitySelection, GetDatacenterLocalityApplyTooltip, addSearchTags);
		applyDatacenterButtonInitializer.data.buttonAlignment = "CENTER";
		applyDatacenterButtonInitializer:AddModifyPredicate(CanApplyDatacenterLocality);
		applyDatacenterButtonInitializer:AddEvaluateStateFrameEvent("PREFERRED_PLAY_SETTINGS_UPDATED");
		applyDatacenterButtonInitializer:AddEvaluateStateFrameEvent("PREFERRED_PLAY_SETTINGS_SELECTION_CHANGED");
		layout:AddInitializer(applyDatacenterButtonInitializer);
	end

	-- Global Hooks --

	local eventFrame = CreateFrame("Frame");
	eventFrame:RegisterEvent("PREFERRED_PLAY_SETTINGS_UPDATED");
	eventFrame:SetScript("OnEvent", function()
		RefreshPreferredPlayState();
	end);
end
