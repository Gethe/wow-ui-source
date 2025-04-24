function CompactUnitFrameProfiles_OnLoad(self)
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("COMPACT_UNIT_FRAME_PROFILES_LOADED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("GROUP_JOINED");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	
	--Get this working with the InterfaceOptions panel.
	self.name = COMPACT_UNIT_FRAME_PROFILES_LABEL;
	self.options = {
		useCompactPartyFrames = { text = "USE_RAID_STYLE_PARTY_FRAMES" },
	}
end

function CompactUnitFrameProfiles_OnEvent(self, event, ...)
	if ( event == "COMPACT_UNIT_FRAME_PROFILES_LOADED" ) then
		--HasLoadedCUFProfiles will now return true.
		self:UnregisterEvent(event);
		CompactUnitFrameProfiles_ValidateProfilesLoaded(self);
	elseif ( event == "VARIABLES_LOADED" ) then
		self.variablesLoaded = true;
		self:UnregisterEvent(event);
		CompactUnitFrameProfiles_ValidateProfilesLoaded(self);
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then	--Check for zoning
		CompactUnitFrameProfiles_CheckAutoActivation();
	elseif ( event == "GROUP_JOINED" or event == "GROUP_ROSTER_UPDATE" ) then
			CompactUnitFrameProfiles_CheckAutoActivation();
		end
end

function CompactUnitFrameProfiles_ValidateProfilesLoaded(self)
	if ( HasLoadedCUFProfiles() and self.variablesLoaded ) then
		if ( RaidProfileExists(GetActiveRaidProfile()) ) then
			CompactUnitFrameProfiles_ActivateRaidProfile(GetActiveRaidProfile());
		elseif ( GetNumRaidProfiles() == 0 ) then	--If we don't have any profiles, we need to create a new one.
			CompactUnitFrameProfiles_ResetToDefaults();
		else
			CompactUnitFrameProfiles_ActivateRaidProfile(GetRaidProfileName(1));
		end
	end
end

function CompactUnitFrameProfiles_DefaultCallback(self)
	CompactUnitFrameProfiles_ResetToDefaults();
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
	CompactUnitFrameProfiles_ActivateRaidProfile(DEFAULT_CUF_PROFILE_NAME);
end

function CompactUnitFrameProfiles_SaveChanges(self)
	SaveRaidProfileCopy(self.selectedProfile);	--Save off the current version in case we cancel.
	CompactUnitFrameProfiles_UpdateManagementButtons();
end

function CompactUnitFrameProfiles_CancelCallback(self)
	CompactUnitFrameProfiles_CancelChanges(self);
end

function CompactUnitFrameProfiles_CancelChanges(self)
	RestoreRaidProfileFromCopy();
	CompactUnitFrameProfiles_UpdateCurrentPanel();
	CompactUnitFrameProfiles_ApplyCurrentSettings();
end

function CompactUnitFrameProfilesNewProfileDialogBaseProfileSelector_OnLoad(self)
	WowStyle1DropdownMixin.OnLoad(self);

	self:SetWidth(190);
end

function CompactUnitFrameProfilesNewProfileDialogBaseProfileSelector_OnShow(self)
	local function IsSelected(name)
		return CompactUnitFrameProfiles.newProfileDialog.baseProfile == name;
	end
	
	local function SetSelected(name)
		CompactUnitFrameProfiles.newProfileDialog.baseProfile = name;
	end

	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_COMPACT_RAID_FRAME_DIALOG_PROFILES");

		rootDescription:CreateRadio(DEFAULTS, IsSelected, SetSelected, nil);
		for i=1, GetNumRaidProfiles() do
			local name = GetRaidProfileName(i);
			rootDescription:CreateRadio(name, IsSelected, SetSelected, name);
		end
	end);
end

function CompactUnitFrameProfilesProfileSelector_OnLoad(self)
	WowStyle1DropdownMixin.OnLoad(self);
	
	self:SetWidth(190);
end

function CompactUnitFrameProfilesProfileSelector_OnShow(self)
	local function IsSelected(name)
		return CompactUnitFrameProfiles.selectedProfile == name;
	end
	
	local function SetSelected(name)
		if ( RaidProfileHasUnsavedChanges() ) then
			CompactUnitFrameProfiles_ConfirmUnsavedChanges("select", name);
		else
			CompactUnitFrameProfiles_ActivateRaidProfile(name);
		end
	end

	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_COMPACT_RAID_FRAME_PROFILES_SELECTOR");
		for i=1, GetNumRaidProfiles() do
			local name = GetRaidProfileName(i);
			rootDescription:CreateRadio(name, IsSelected, SetSelected, name);
		end

		local profileButton = rootDescription:CreateButton(NEW_COMPACT_UNIT_FRAME_PROFILE, function()
			if ( RaidProfileHasUnsavedChanges() ) then
				CompactUnitFrameProfiles_ConfirmUnsavedChanges("new");
			else
				CompactUnitFrameProfiles_ShowNewProfileDialog();
			end
		end);

		if GetNumRaidProfiles() >= GetMaxNumCUFProfiles() then
			profileButton:SetEnabled(false);
		end
	end);
end

function CompactUnitFrameProfiles_ActivateRaidProfile(profile)	
	CompactUnitFrameProfiles.selectedProfile = profile;
	SaveRaidProfileCopy(profile);	--Save off the current version in case we cancel.
	SetActiveRaidProfile(profile);
	CompactUnitFrameProfilesProfileSelector:GenerateMenu();
	CompactRaidFrameManagerDisplayFrameProfileSelector:GenerateMenu();
	
	CompactUnitFrameProfiles_HidePopups();
	CompactUnitFrameProfiles_UpdateCurrentPanel();
	CompactUnitFrameProfiles_ApplyCurrentSettings();
end

function CompactUnitFrameProfiles_SetRaidProfile(profile)
	CompactUnitFrameProfiles.selectedProfile = profile;
	SaveRaidProfileCopy(profile);	--Save off the current version in case we cancel.
	SetActiveRaidProfile(profile);
end

function CompactUnitFrameProfiles_ApplyCurrentSettings()
	CompactUnitFrameProfiles_ApplyProfile(GetActiveRaidProfile());
end


function CompactUnitFrameProfiles_UpdateCurrentPanel()
	CompactUnitFrameProfiles_UpdateManagementButtons();
	CompactUnitFrameProfile_UpdateAutoActivationDisabledLabel();
end

function CompactUnitFrameProfiles_CreateProfile(profileName)
	CreateNewRaidProfile(profileName, CompactUnitFrameProfiles.newProfileDialog.baseProfile);
	CompactUnitFrameProfiles_ActivateRaidProfile(profileName);
end

function CompactUnitFrameProfiles_UpdateNewProfileCreateButton()
	local button = CompactUnitFrameProfiles.newProfileDialog.createButton;
	local text = strtrim(CompactUnitFrameProfiles.newProfileDialog.editBox:GetText());
	
	if ( text == "" or RaidProfileExists(text) or strlower(text) == strlower(DEFAULTS) ) then
		button:Disable();
	else
		button:Enable();
	end
end

function CompactUnitFrameProfiles_HideNewProfileDialog()
	CompactUnitFrameProfiles.newProfileDialog:Hide();
end

function CompactUnitFrameProfiles_ShowNewProfileDialog()
	CompactUnitFrameProfiles.newProfileDialog.baseProfile = nil;
	CompactUnitFrameProfiles.newProfileDialog:Show();
	CompactUnitFrameProfiles.newProfileDialog.editBox:SetText("");
	CompactUnitFrameProfiles.newProfileDialog.editBox:SetFocus();
	CompactUnitFrameProfilesNewProfileDialogBaseProfileSelector:GenerateMenu();
	CompactUnitFrameProfiles_UpdateNewProfileCreateButton();
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
		CompactUnitFrameProfiles_ActivateRaidProfile(profileArg);
	elseif ( action == "new" ) then
		CompactUnitFrameProfiles_ShowNewProfileDialog();
	end
end

function CompactUnitFrameProfiles_HidePopups()
	CompactUnitFrameProfiles.newProfileDialog:Hide();
	CompactUnitFrameProfiles.deleteProfileDialog:Hide();
	CompactUnitFrameProfiles.unsavedProfileDialog:Hide();
end

function SetActiveRaidProfile(profile)
	SetCVar("activeCUFProfile", profile);
end

function GetActiveRaidProfile()
	return GetCVar("activeCUFProfile");
end

local autoActivateGroupSizes = { 2, 3, 5, 10, 15, 20, 40 };
local countMap = {};	--Maps number of players to the category.
for i, autoActivateGroupSize in ipairs(autoActivateGroupSizes) do
	local groupSizeStart = i > 1 and (autoActivateGroupSizes[i - 1] + 1) or 1;
	for groupSize = groupSizeStart, autoActivateGroupSize do
		countMap[groupSize] = autoActivateGroupSize;
	end
end

function CompactUnitFrameProfiles_GetAutoActivationState()
	local name, instanceType, difficultyIndex, difficultyName, maxPlayers, dynamicDifficulty, isDynamic = GetInstanceInfo();
	if ( not name ) then	--We don't have info.
		return false;
	end
	
	local numPlayers, profileType, enemyType;
	
	if ( instanceType == "party" or instanceType == "raid" ) then
		numPlayers = maxPlayers > 0 and countMap[maxPlayers] or 5;
		profileType = instanceType;
		enemyType = "PvE";
	elseif ( instanceType == "arena" ) then
		numPlayers = countMap[GetNumGroupMembers()];
		profileType = instanceType;
		enemyType = "PvP";
	elseif ( instanceType == "pvp" ) then
		numPlayers = countMap[maxPlayers];
		profileType = instanceType;
		enemyType = "PvP";
	else
		numPlayers = countMap[GetNumGroupMembers()];
		profileType = "world";
		enemyType = "PvE";
	end
	
	if ( not numPlayers ) then
		return false;
	end
	
	return true, numPlayers, profileType, enemyType;
end

local checkAutoActivationTimer;
function CompactUnitFrameProfiles_CheckAutoActivation()
	--We only want to adjust the profile when you zone. We don't want to automatically
	--change the profile when you are in the uninstanced world.
	if ( not IsInGroup() ) then
		CompactUnitFrameProfiles_SetLastActivationType(nil, nil, nil, nil);
		return;
	end
	
	local success, numPlayers, activationType, enemyType = CompactUnitFrameProfiles_GetAutoActivationState();
	
	if ( not success ) then
		--We didn't have all the relevant info yet. Update again soon.
		if ( checkAutoActivationTimer ) then
			checkAutoActivationTimer:Cancel();
		end
		checkAutoActivationTimer = C_Timer.NewTimer(3, CompactUnitFrameProfiles_CheckAutoActivation);
		return;
	else
		if ( checkAutoActivationTimer ) then
			checkAutoActivationTimer:Cancel();
			checkAutoActivationTimer = nil;
		end
	end
		
	local lastActivationType, lastNumPlayers, lastEnemyType = CompactUnitFrameProfiles_GetLastActivationType();
	
	if ( lastActivationType == activationType and lastNumPlayers == numPlayers and lastEnemyType == enemyType ) then
		--If we last auto-adjusted for this same thing, we don't change. (In case they manually changed the profile.)
		return;
	end
	
	if ( CompactUnitFrameProfiles_ProfileMatchesAutoActivation(GetActiveRaidProfile(), numPlayers, enemyType) ) then
		CompactUnitFrameProfiles_SetLastActivationType(activationType, numPlayers, enemyType);
	else
		for i=1, GetNumRaidProfiles() do
			local profile = GetRaidProfileName(i);
			if ( CompactUnitFrameProfiles_ProfileMatchesAutoActivation(profile, numPlayers, enemyType) ) then
				CompactUnitFrameProfiles_ActivateRaidProfile(profile);
				CompactUnitFrameProfiles_SetLastActivationType(activationType, numPlayers, enemyType);
			end
		end
	end
end

function CompactUnitFrameProfiles_SetLastActivationType(activationType, numPlayers, enemyType)
	CompactUnitFrameProfiles.lastActivationType = activationType;
	CompactUnitFrameProfiles.lastNumPlayers = numPlayers;
	CompactUnitFrameProfiles.lastEnemyType = enemyType;
end

function CompactUnitFrameProfiles_GetLastActivationType()
	return CompactUnitFrameProfiles.lastActivationType, CompactUnitFrameProfiles.lastNumPlayers, CompactUnitFrameProfiles.lastEnemyType;
end

function CompactUnitFrameProfiles_ProfileMatchesAutoActivation(profile, numPlayers, enemyType)
	return GetRaidProfileOption(profile, "autoActivate"..numPlayers.."Players") and GetRaidProfileOption(profile, "autoActivate"..enemyType);
end

function CompactUnitFrameProfilesGeneralOptionsFrame_OnShow(self)
	local height = 293;
	self.autoActivateBG:SetHeight(height);
end


function CompactUnitFrameProfile_UpdateAutoActivationDisabledLabel()
	local profile = GetActiveRaidProfile();
	local hasGroupSize = false;
	for i=1, #autoActivateGroupSizes do
		if ( GetRaidProfileOption(profile, "autoActivate"..autoActivateGroupSizes[i].."Players") ) then
			hasGroupSize = true;
			break;
		end
	end
	
	local hasEnemyType = false;
	if ( GetRaidProfileOption(profile, "autoActivatePvP") or GetRaidProfileOption(profile, "autoActivatePvE") ) then
		hasEnemyType = true;
	end
	
	if ( hasGroupSize == hasEnemyType ) then
		CompactUnitFrameProfiles.optionsFrame.autoActivateDisabledLabel:Hide();
	elseif ( not hasGroupSize ) then
		CompactUnitFrameProfiles.optionsFrame.autoActivateDisabledLabel:SetText(AUTO_ACTIVATE_PROFILE_NO_SIZE);
		CompactUnitFrameProfiles.optionsFrame.autoActivateDisabledLabel:Show();
	elseif ( not hasEnemyType ) then
		CompactUnitFrameProfiles.optionsFrame.autoActivateDisabledLabel:SetText(AUTO_ACTIVATE_PROFILE_NO_ENEMYTYPE);
		CompactUnitFrameProfiles.optionsFrame.autoActivateDisabledLabel:Show();
	end
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
function CompactUnitFrameProfilesDropdown_OnLoad(self, optionName, options)
	CompactUnitFrameProfilesOption_OnLoad(self);

	self.optionName = optionName;
	self.options = options;
	local tag = format("COMPACT_UNIT_FRAME_PROFILE_%s", strupper(optionName));
	self.label:SetText(_G[tag] or "Need string: "..tag);
	self.updateFunc = CompactUnitFrameProfilesDropdown_Update;

	self:SetWidth(self.width or 160);
end

function CompactUnitFrameProfilesDropdown_OnShow(self)
	local function IsSelected(id)
		return GetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, self.optionName) == id;
	end

	local function SetSelected(id)
		SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, self.optionName, id);
		CompactUnitFrameProfiles_ApplyCurrentSettings();
		CompactUnitFrameProfiles_UpdateCurrentPanel();
	end

	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_COMPACT_RAID_FRAME_PROFILES");

		for i, id in ipairs(self.options) do
			local tag = format("COMPACT_UNIT_FRAME_PROFILE_%s_%s", strupper(self.optionName), strupper(id));
			local text = _G[tag] or "Need string: "..tag;
			rootDescription:CreateRadio(text, IsSelected, SetSelected, id);
		end
	end);
end

function CompactUnitFrameProfilesDropdown_Update(self)
	self:GenerateMenu();
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

function CompactUnitFrameProfilesSlider_OnValueChanged(self, value, userInput)
	if ( userInput ) then
		SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, self.optionName, value);
		CompactUnitFrameProfiles_ApplyCurrentSettings();
		CompactUnitFrameProfiles_UpdateCurrentPanel();
	end
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
	if ( self:GetChecked() ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, self.optionName, self:GetChecked());
	CompactUnitFrameProfiles_ApplyCurrentSettings();
	CompactUnitFrameProfiles_UpdateCurrentPanel();
end

-------------------------------------------------------------
-----------------Applying of Options----------------------
-------------------------------------------------------------

function CompactUnitFrameProfiles_ApplyProfile(profile)

	local settings = GetRaidProfileFlattenedOptions(profile);
	for settingName, value in pairs(settings) do
		local func = CUFProfileActionTable[settingName];
		if ( func ) then
			func(value);
		end
	end
	
	--Refresh all frames to make sure the changes stick.
	CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "normal", DefaultCompactUnitFrameSetup);
	CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "normal", CompactUnitFrame_UpdateAll);
	CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "mini", DefaultCompactMiniFrameSetup);
	CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "mini", CompactUnitFrame_UpdateAll);
	--CompactRaidFrameContainer_ApplyToFrames(CompactRaidFrameContainer, "group", CompactRaidGroup_UpdateLayout);	--UpdateBorder calls UpdateLayout.
	
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
	displayNonBossDebuffs = CompactUnitFrameProfiles_GenerateOptionSetter("displayNonBossDebuffs", "normal"),
	displayOnlyDispellableDebuffs = CompactUnitFrameProfiles_GenerateOptionSetter("displayOnlyDispellableDebuffs", "normal"),
	useClassColors = CompactUnitFrameProfiles_GenerateOptionSetter("useClassColors", "normal"),
	horizontalGroups = CompactUnitFrameProfiles_GenerateRaidManagerSetting("HorizontalGroups");
	healthText = CompactUnitFrameProfiles_GenerateOptionSetter("healthText", "normal"),
	frameWidth = CompactUnitFrameProfiles_GenerateSetUpOptionSetter("width", "all");
	frameHeight = 	function(value)
								DefaultCompactUnitFrameSetupOptions.height = value;
								DefaultCompactMiniFrameSetUpOptions.height = value / 2;
							end,
	displayBorder = function(value)
								DefaultCompactUnitFrameSetupOptions.displayBorder = value;
								DefaultCompactMiniFrameSetUpOptions.displayBorder = value;
								CompactRaidFrameManager_SetSetting("ShowBorders", value);
							end,
							
	--State
	locked = CompactUnitFrameProfiles_GenerateRaidManagerSetting("Locked"),
	shown = CompactUnitFrameProfiles_GenerateRaidManagerSetting("IsShown"),
}

-- This addon depends on some function from the following addon, so making sure it is enabled.
C_AddOns.EnableAddOn("Blizzard_CompactRaidFrames");
