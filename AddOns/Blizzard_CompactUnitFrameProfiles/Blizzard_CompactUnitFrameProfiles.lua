function CompactUnitFrameProfiles_OnLoad(self)
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("COMPACT_UNIT_FRAME_PROFILES_LOADED");
	
	--Get this working with the InterfaceOptions panel.
	self.name = COMPACT_UNIT_FRAME_PROFILES;
	self.options = {};
	self.controls = {};
	
	BlizzardOptionsPanel_OnLoad(self, CompactUnitFrameProfiles_SaveChanges, CompactUnitFrameProfiles_CancelChanges, CompactUnitFrameProfiles_ResetToDefaults, CompactUnitFrameProfiles_UpdateCurrentPanel);
	InterfaceOptions_AddCategory(self);
end

function CompactUnitFrameProfiles_OnEvent(self, event, ...)
	if ( event == "COMPACT_UNIT_FRAME_PROFILES_LOADED" ) then
		self.profilesLoaded = true;
		self:UnregisterEvent(event);
	elseif ( event == "VARIABLES_LOADED" ) then
		self.variablesLoaded = true;
		self:UnregisterEvent(event);
	end
	if ( self.profilesLoaded and self.variablesLoaded ) then
		if ( not RaidProfileExists(GetActiveRaidProfile()) ) then 	--This one doesn't exist.
			if ( GetNumRaidProfiles() == 0 ) then
				CompactUnitFrameProfiles_ResetToDefaults();
			else
				SetActiveRaidProfile(GetRaidProfileName(1));
			end
		end
		CompactUnitFrameProfiles_SetSelectedProfile(GetActiveRaidProfile());
	end
end

function CompactUnitFrameProfiles_ResetToDefaults()
	local profiles = {};
	for i=1, GetNumRaidProfiles() do
		tinsert(profiles, GetRaidProfileName(i));
	end
	for i=1, #profiles do
		DeleteRaidProfile(profiles[i]);
	end
	CreateNewRaidProfile(DEFAULT_CUF_PROFILE_NAME);
	SetActiveRaidProfile(DEFAULT_CUF_PROFILE_NAME);
	CompactUnitFrameProfiles_SetSelectedProfile(GetRaidProfileName(1));
end

function CompactUnitFrameProfiles_SaveChanges(self)
	SaveRaidProfileCopy(self.selectedProfile);	--Save off the current version in case we cancel.
	CompactUnitFrameProfiles_UpdateManagementButtons();
end

function CompactUnitFrameProfiles_CancelChanges(self)
	RestoreRaidProfileFromCopy();
	CompactUnitFrameProfiles_UpdateCurrentPanel();
	CompactUnitFrameProfiles_ApplyCurrentSettings();
end

function CompactUnitFrameProfilesNewProfileDialogBaseProfileSelector_SetUp(self)
	UIDropDownMenu_SetWidth(self, 190);
	UIDropDownMenu_Initialize(self, CompactUnitFrameProfilesNewProfileDialogBaseProfileSelector_Initialize);
end


function CompactUnitFrameProfilesNewProfileDialogBaseProfileSelector_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	
	info.text = DEFAULTS;
	info.value = nil;
	info.func = CompactUnitFrameProfilesNewProfileDialogBaseProfileSelectorButton_OnClick;
	info.checked = CompactUnitFrameProfiles.newProfileDialog.baseProfile == info.value;
	UIDropDownMenu_AddButton(info);
	
	for i=1, GetNumRaidProfiles() do
		local name = GetRaidProfileName(i);
		info.text = name;
		info.value = name;
		info.func = CompactUnitFrameProfilesNewProfileDialogBaseProfileSelectorButton_OnClick;
		info.checked = CompactUnitFrameProfiles.newProfileDialog.baseProfile == info.value;
		UIDropDownMenu_AddButton(info);
	end
end

function CompactUnitFrameProfilesNewProfileDialogBaseProfileSelectorButton_OnClick(self)
	CompactUnitFrameProfiles.newProfileDialog.baseProfile = self.value;
	UIDropDownMenu_SetSelectedValue(CompactUnitFrameProfilesNewProfileDialogBaseProfileSelector, self.value);
end

function CompactUnitFrameProfilesProfileSelector_SetUp(self)
	UIDropDownMenu_SetWidth(self, 190);
	UIDropDownMenu_Initialize(self, CompactUnitFrameProfilesProfileSelector_Initialize);
	--UIDropDownMenu_SetSelectedValue(self, GetActiveRaidProfile());
end

function CompactUnitFrameProfilesProfileSelector_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	
	for i=1, GetNumRaidProfiles() do
		local name = GetRaidProfileName(i);
		info.text = name;
		info.func = CompactUnitFrameProfilesProfileSelectorButton_OnClick;
		info.value = name;
		info.checked = CompactUnitFrameProfiles.selectedProfile == name;
		UIDropDownMenu_AddButton(info);
	end
	
	info.text = NEW_COMPACT_UNIT_FRAME_PROFILE;
	info.func = CompactUnitFrameProfiles_NewProfileButtonClicked;
	info.value = nil;
	info.checked = false;
	UIDropDownMenu_AddButton(info);
end

function CompactUnitFrameProfilesProfileSelectorButton_OnClick(self)
	if ( RaidProfileHasUnsavedChanges() ) then
		CompactUnitFrameProfiles_ConfirmUnsavedChanges("select", self.value);
	else
		CompactUnitFrameProfiles_SetSelectedProfile(self.value);
	end
end

function CompactUnitFrameProfiles_NewProfileButtonClicked()
	if ( RaidProfileHasUnsavedChanges() ) then
		CompactUnitFrameProfiles_ConfirmUnsavedChanges("new");
	else
		CompactUnitFrameProfiles_ShowNewProfileDialog();
	end
end

function CompactUnitFrameProfiles_SetSelectedProfile(profile)
	CompactUnitFrameProfiles.selectedProfile = profile;
	SaveRaidProfileCopy(profile);	--Save off the current version in case we cancel.
	SetActiveRaidProfile(profile);
	UIDropDownMenu_SetSelectedValue(CompactUnitFrameProfilesProfileSelector, profile);
	UIDropDownMenu_SetText(CompactUnitFrameProfilesProfileSelector, profile);
	
	CompactUnitFrameProfiles_UpdateCurrentPanel();
	CompactUnitFrameProfiles_ApplyCurrentSettings();
end

function CompactUnitFrameProfiles_ApplyCurrentSettings()
	CompactUnitFrameProfiles_ApplyProfile(GetActiveRaidProfile());
end


function CompactUnitFrameProfiles_UpdateCurrentPanel()
	local panel = CompactUnitFrameProfiles.optionsFrame;
	for i=1, #panel.optionControls do
		panel.optionControls[i]:updateFunc();
	end
	CompactUnitFrameProfiles_UpdateManagementButtons();
end

function CompactUnitFrameProfiles_CreateProfile(profileName)
	CreateNewRaidProfile(profileName, CompactUnitFrameProfiles.newProfileDialog.baseProfile);
	CompactUnitFrameProfiles_SetSelectedProfile(profileName);
end

function CompactUnitFrameProfiles_HideNewProfileDialog()
	CompactUnitFrameProfiles.newProfileDialog:Hide();
end

function CompactUnitFrameProfiles_ShowNewProfileDialog()
	UIDropDownMenu_SetText(CompactUnitFrameProfilesNewProfileDialogBaseProfileSelector, DEFAULTS);
	CompactUnitFrameProfiles.newProfileDialog.baseProfile = nil;
	CompactUnitFrameProfiles.newProfileDialog:Show();
	CompactUnitFrameProfiles.newProfileDialog.editBox:SetText("");
	CompactUnitFrameProfiles.newProfileDialog.editBox:SetFocus();
end

function CompactUnitFrameProfiles_ConfirmProfileDeletion(profile)
	CompactUnitFrameProfiles.deleteProfileDialog.profile = profile;
	CompactUnitFrameProfiles.deleteProfileDialog.label:SetFormattedText(CONFIRM_COMPACT_UNIT_FRAME_PROFILE_DELETION, profile);
	CompactUnitFrameProfiles.deleteProfileDialog:Show();
end

function CompactUnitFrameProfiles_UpdateManagementButtons()
	if ( GetNumRaidProfiles() <= 1 ) then
		CompactUnitFrameProfilesDeleteButton:Disable();
	else
		CompactUnitFrameProfilesDeleteButton:Enable();
	end
	
	if ( RaidProfileHasUnsavedChanges() ) then
		CompactUnitFrameProfilesSaveButton:Enable();
	else
		CompactUnitFrameProfilesSaveButton:Disable();
	end
end

function CompactUnitFrameProfiles_ConfirmUnsavedChanges(action, profileArg)
	CompactUnitFrameProfiles.unsavedProfileDialog.action = action;
	CompactUnitFrameProfiles.unsavedProfileDialog.profile = profileArg;
	CompactUnitFrameProfiles.unsavedProfileDialog.label:SetFormattedText(CONFIRM_COMPACT_UNIT_FRAME_PROFILE_UNSAVED_CHANGES, CompactUnitFrameProfiles.selectedProfile);
	CompactUnitFrameProfiles.unsavedProfileDialog:Show();
end

function CompactUnitFrameProfiles_AfterConfirmUnsavedChanges()
	local action = CompactUnitFrameProfiles.unsavedProfileDialog.action;
	local profileArg = CompactUnitFrameProfiles.unsavedProfileDialog.profile;
	if ( action == "select" ) then
		CompactUnitFrameProfiles_SetSelectedProfile(profileArg);
	elseif ( action == "new" ) then
		CompactUnitFrameProfiles_ShowNewProfileDialog();
	end
end

function SetActiveRaidProfile(profile)
	SetCVar("activeCUFProfile", profile);
end

function GetActiveRaidProfile()
	return GetCVar("activeCUFProfile");
end

--------------------------------------------------------------
-----------------UI Option Templates---------------------
--------------------------------------------------------------

function CompactUnitFrameProfilesOption_OnLoad(self)
	if ( not self:GetParent().optionControls ) then
		self:GetParent().optionControls = {};
	end
	tinsert(self:GetParent().optionControls, self);
end

-------------------------
----Dropdown--------
-------------------------
-- Required key/value pairs:
-- .optionName - String, name of option
-- .options - Array, array of possible options
-- Required strings:
-- COMPACT_UNIT_FRAME_PROFILE_<OPTION_NAME>
-- COMPACT_UNIT_FRAME_PROFILE_<OPTION_NAME>_<OPTION_VALUE>
function CompactUnitFrameProfilesDropdown_InitializeWidget(self, optionName, options, updateFunc)
	self.optionName = optionName;
	self.options = options;
	local tag = format("COMPACT_UNIT_FRAME_PROFILE_%s", strupper(optionName));
	self.label:SetText(_G[tag] or "Need string: "..tag);
	self.updateFunc = updateFunc or CompactUnitFrameProfilesDropdown_Update;
	CompactUnitFrameProfilesOption_OnLoad(self);
end

function CompactUnitFrameProfilesDropdown_OnShow(self)
	UIDropDownMenu_SetWidth(self, self.width or 160);
	UIDropDownMenu_Initialize(self, CompactUnitFrameProfilesDropdown_Initialize);
	CompactUnitFrameProfilesDropdown_Update(self);
end

function CompactUnitFrameProfilesDropdown_Update(self)
	UIDropDownMenu_Initialize(self, CompactUnitFrameProfilesDropdown_Initialize);
	UIDropDownMenu_SetSelectedValue(self, GetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, self.optionName));
end

function CompactUnitFrameProfilesDropdown_Initialize(dropDown)
	local info = UIDropDownMenu_CreateInfo();
	
	local currentValue = GetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, dropDown.optionName);
	for i=1, #dropDown.options do
		local id = dropDown.options[i];
		local tag = format("COMPACT_UNIT_FRAME_PROFILE_%s_%s", strupper(dropDown.optionName), strupper(id));
		info.text = _G[tag] or "Need string: "..tag;
		info.func = CompactUnitFrameProfilesDropdownButton_OnClick;
		info.arg1 = dropDown;
		info.value = id;
		info.checked = currentValue == id;
		UIDropDownMenu_AddButton(info);
	end
end

function CompactUnitFrameProfilesDropdownButton_OnClick(button, dropDown)
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, dropDown.optionName, button.value);
	UIDropDownMenu_SetSelectedValue(dropDown, button.value);
	CompactUnitFrameProfiles_ApplyCurrentSettings();
	CompactUnitFrameProfiles_UpdateCurrentPanel();
end

------------------------------
----------Slider-------------
------------------------------
function CompactUnitFrameProfilesSlider_InitializeWidget(self, optionName, minText, maxText, updateFunc)
	self.optionName = optionName;
	local tag = format("COMPACT_UNIT_FRAME_PROFILE_%s", strupper(optionName));
	self.label:SetText(_G[tag] or "Need string: "..tag);
	if ( minText ) then
		self.minLabel:SetText(minText);
	end
	if ( maxText ) then
		self.maxLabel:SetText(maxText);
	end
	self.updateFunc = updateFunc or CompactUnitFrameProfilesSlider_Update;
	CompactUnitFrameProfilesOption_OnLoad(self);
end

function CompactUnitFrameProfilesSlider_Update(self)
	local currentValue = GetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, self.optionName);
	self:SetValue(currentValue);
end

function CompactUnitFrameProfilesSlider_OnValueChanged(self, value)
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, self.optionName, value);
	CompactUnitFrameProfiles_ApplyCurrentSettings();
	CompactUnitFrameProfiles_UpdateCurrentPanel();
end

-------------------------------
-------Check Button---------
-------------------------------
function CompactUnitFrameProfilesCheckButton_InitializeWidget(self, optionName, updateFunc)
	self.optionName = optionName;
	local tag = format("COMPACT_UNIT_FRAME_PROFILE_%s", strupper(optionName));
	self.label:SetText(_G[tag] or "Need string: "..tag);
	self.updateFunc = updateFunc or CompactUnitFrameProfilesCheckButton_Update;
	CompactUnitFrameProfilesOption_OnLoad(self);
end

function CompactUnitFrameProfilesCheckButton_Update(self)
	local currentValue = GetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, self.optionName);
	self:SetChecked(currentValue);
end

function CompactUnitFrameProfilesCheckButton_OnClick(self, button)
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, self.optionName, not not self:GetChecked());
	CompactUnitFrameProfiles_ApplyCurrentSettings();
	CompactUnitFrameProfiles_UpdateCurrentPanel();
end

-------------------------------------------------------------
-----------------Applying of Options----------------------
-------------------------------------------------------------

function CompactUnitFrameProfiles_ApplyProfile(profile)

	local settings = GetRaidProfileFlattenedOptions(profile);
	for settingName, value in pairs(settings) do
		CUFProfileActionTable[settingName](value);
	end
	
	local state = GetRaidProfileFlattenedState(profile)
	for stateName, value in pairs(state) do
		CUFProfileActionTable[stateName](value);
	end
	
	--Refresh all frames to make sure the changes stick.
	CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "normal", DefaultCompactUnitFrameSetup);
	CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "normal", CompactUnitFrame_UpdateAll);
	CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "mini", DefaultCompactMiniFrameSetup);
	CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "mini", CompactUnitFrame_UpdateAll);
	CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "group", CompactRaidGroup_UpdateLayout);
	
	--Update the borders on the group frames.
	CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "group", CompactRaidGroup_UpdateBorder);
	
	--Update the position of the container.
	CompactRaidFrameManager_ResizeFrame_LoadPosition(CompactRaidFrameManager);
	
	--Update the container in case sizes and such changed.
	CompactRaidFrameContainer_TryUpdate(CompactRaidFrameContainer);
end

local function CompactUnitFrameProfiles_GenerateRaidManagerSetting(optionName)
	return function(value)
		CompactRaidFrameManager_SetSetting(optionName, value);
	end
end

local function CompactUnitFrameProfiles_GenerateOptionSetter(optionName, optionTarget)
	return function(value)
		if ( optionTarget == "normal" or optionTarget == "all" ) then
			DefaultCompactUnitFrameOptions[optionName] = value;
		end
		if ( optionTarget == "mini" or optionTarget == "all" ) then
			DefaultCompactMiniFrameOptions[optionName] = value;
		end
	end
end

local function CompactUnitFrameProfiles_GenerateSetUpOptionSetter(optionName, optionTarget)
	return function(value)
		if ( optionTarget == "normal" or optionTarget == "all" ) then
			DefaultCompactUnitFrameSetupOptions[optionName] = value;
		end
		if ( optionTarget == "mini" or optionTarget == "all" ) then
			DefaultCompactMiniFrameSetUpOptions[optionName] = value;
		end
	end
end

CUFProfileActionTable = {
	--Settings
	keepGroupsTogether = CompactUnitFrameProfiles_GenerateRaidManagerSetting("KeepGroupsTogether"),
	sortBy = CompactUnitFrameProfiles_GenerateRaidManagerSetting("SortMode"),
	displayPets = CompactUnitFrameProfiles_GenerateRaidManagerSetting("DisplayPets"),
	displayMainTankAndAssist = CompactUnitFrameProfiles_GenerateRaidManagerSetting("DisplayMainTankAndAssist"),
	displayHealPrediction = CompactUnitFrameProfiles_GenerateOptionSetter("displayHealPrediction", "all"),
	displayPowerBar = CompactUnitFrameProfiles_GenerateSetUpOptionSetter("displayPowerBar", "normal"),
	displayAggroHighlight = CompactUnitFrameProfiles_GenerateOptionSetter("displayAggroHighlight", "all"),
	displayOnlyDispellableDebuffs = CompactUnitFrameProfiles_GenerateOptionSetter("displayOnlyDispellableDebuffs", "normal"),
	useClassColors = CompactUnitFrameProfiles_GenerateOptionSetter("useClassColors", "normal"),
	healthText = CompactUnitFrameProfiles_GenerateOptionSetter("healthText", "normal"),
	frameWidth = CompactUnitFrameProfiles_GenerateSetUpOptionSetter("width", "all");
	frameHeight = 	function(value)
								DefaultCompactUnitFrameSetupOptions.height = value;
								DefaultCompactMiniFrameSetUpOptions.height = value / 2;
							end,
	displayBorder = function(value)
								RAID_BORDERS_SHOWN = value;
								DefaultCompactUnitFrameSetupOptions.displayBorder = value;
								DefaultCompactMiniFrameSetUpOptions.displayBorder = value;
								CompactRaidFrameManager_SetSetting("ShowBorders", value);
							end,
							
	--State
	locked = CompactUnitFrameProfiles_GenerateRaidManagerSetting("Locked"),
	shown = CompactUnitFrameProfiles_GenerateRaidManagerSetting("IsShown"),
}