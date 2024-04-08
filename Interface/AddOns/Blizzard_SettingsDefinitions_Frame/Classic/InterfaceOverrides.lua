InterfaceOverrides = {}

function InterfaceOverrides.CreateLargerNameplateSetting(category)
	--no setting in Classic
end

function InterfaceOverrides.AdjustNameplateSettings(category)
	if GetClassicExpansionLevel() > LE_EXPANSION_CLASSIC then
		-- Nameplate Distance
		local minValue, maxValue, step = 20, 41, 1;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, IncrementByOne);
		Settings.SetupCVarSlider(category, "nameplateMaxDistance", options, UNIT_NAMEPLATES_MAX_DISTANCE, OPTION_TOOLTIP_UNIT_NAMEPLATES_MAX_DISTANCE);
	end
end

function InterfaceOverrides.AdjustDisplaySettings(category)
	do
		-- Show Helm
		local function GetValue()
			return ShowingHelm();
		end
		
		local function SetValue(value)
			ShowHelm(value);
		end
		
		local defaultValue = true;
		local setting = Settings.RegisterProxySetting(category, "PROXY_SHOW_HELM", Settings.DefaultVarLocation, 
			Settings.VarType.Boolean, SHOW_HELM, defaultValue, GetValue, SetValue);
		Settings.CreateCheckBox(category, setting, OPTION_TOOLTIP_SHOW_HELM);
	end

	do
		-- Show Cloak
		local function GetValue()
			return ShowingCloak();
		end
		
		local function SetValue(value)
			ShowCloak(value);
		end
		
		local defaultValue = true;
		local setting = Settings.RegisterProxySetting(category, "PROXY_SHOW_CLOAK", Settings.DefaultVarLocation, 
			Settings.VarType.Boolean, SHOW_CLOAK, defaultValue, GetValue, SetValue);
		Settings.CreateCheckBox(category, setting, OPTION_TOOLTIP_SHOW_CLOAK);
	end

	if (C_GameRules.IsHardcoreActive()) then
		do
			-- What sort of messages to filter in the "HardcoreDeaths" channel
			local function GetOptions()
				local container = Settings.CreateControlTextContainer();
				container:Add(0, HARDCORE_ANNOUNCE_DEATH_GUILD, OPTION_TOOLTIP_HARDCORE_ANNOUNCE_DEATH_DISPLAY1);
				container:Add(1, HARDCORE_ANNOUNCE_DEATH_ALL, OPTION_TOOLTIP_HARDCORE_ANNOUNCE_DEATH_DISPLAY2);
				return container:GetData();
			end
	
			Settings.SetupCVarDropDown(category, "hardcoreDeathChatType", Settings.VarType.Number, GetOptions, HARDCORE_ANNOUNCE_DEATH, nil);
		end
		do
			-- What sort of messages to announce as a raid-style warning
			local function GetOptions()
				local container = Settings.CreateControlTextContainer();
				container:Add(0, NEVER, OPTION_TOOLTIP_HARDCORE_ANNOUNCE_DEATH_ALERT_DISPLAY1);
				container:Add(1, HARDCORE_ANNOUNCE_DEATH_GUILD, OPTION_TOOLTIP_HARDCORE_ANNOUNCE_DEATH_ALERT_DISPLAY2);
				container:Add(2, HARDCORE_ANNOUNCE_DEATH_ALL, OPTION_TOOLTIP_HARDCORE_ANNOUNCE_DEATH_ALERT_DISPLAY3);
				return container:GetData();
			end
	
			Settings.SetupCVarDropDown(category, "hardcoreDeathAlertType", Settings.VarType.Number, GetOptions, HARDCORE_ANNOUNCE_DEATH_ALERT, nil);
		end

		Settings.SetupCVarCheckBox(category, "showMaxLevelAnnouncements", SHOW_MAX_LEVEL_ANNOUNCEMENT, SHOW_MAX_LEVEL_ANNOUNCEMENT_TOOLTIP);
	end

	-- Instant Quest Text
	Settings.SetupCVarCheckBox(category, "instantQuestText", SHOW_QUEST_FADING_TEXT, OPTION_TOOLTIP_SHOW_QUEST_FADING);

	-- Automatic Quest Tracking
	Settings.SetupCVarCheckBox(category, "autoQuestWatch", AUTO_QUEST_WATCH_TEXT, OPTION_TOOLTIP_AUTO_QUEST_PROGRESS);

	do
		local function CVarChangedCB()
			local displayFreeBagSlots = C_CVar.GetCVarBool("displayFreeBagSlots");
			if ( displayFreeBagSlots ) then
				MainMenuBarBackpackButtonCount:Show();
			else
				MainMenuBarBackpackButtonCount:Hide();
			end
			MainMenuBarBackpackButton_UpdateFreeSlots();
		end

		-- Show Free Bag Space
		Settings.SetupCVarCheckBox(category, "displayFreeBagSlots", DISPLAY_FREE_BAG_SLOTS, OPTION_TOOLTIP_DISPLAY_FREE_BAG_SLOTS);
		CVarCallbackRegistry:RegisterCVarChangedCallback(CVarChangedCB, nil);
	end

	do
		-- Consolidate Buffs
		local function CVarChangedCB()
			BuffFrame_Update();
		end

		Settings.SetupCVarCheckBox(category, "consolidateBuffs", CONSOLIDATE_BUFFS_TEXT, OPTION_TOOLTIP_CONSOLIDATE_BUFFS);
		CVarCallbackRegistry:RegisterCVarChangedCallback(CVarChangedCB, nil);
	end

	-- Hide Zone Objective Tracker
	Settings.SetupCVarCheckBox(category, "hideOutdoorWorldState", HIDE_OUTDOOR_WORLD_STATE_TEXT, OPTION_TOOLTIP_HIDE_OUTDOOR_WORLD_STATE);

	do
		-- Rotate Minimap
		local function CVarChangedCB()
			Minimap_UpdateRotationSetting();
		end

		Settings.SetupCVarCheckBox(category, "rotateMinimap", ROTATE_MINIMAP, OPTION_TOOLTIP_ROTATE_MINIMAP);
		CVarCallbackRegistry:RegisterCVarChangedCallback(CVarChangedCB, nil);
	end

	do
		-- Show Minimap Clock
		local function CVarChangedCB()
			if (C_AddOns.IsAddOnLoaded("Blizzard_TimeManager")) then
				TimeManagerClockButton_UpdateShowClockSetting();
			end
		end

		Settings.SetupCVarCheckBox(category, "showMinimapClock", SHOW_MINIMAP_CLOCK, OPTION_TOOLTIP_SHOW_MINIMAP_CLOCK);
		CVarCallbackRegistry:RegisterCVarChangedCallback(CVarChangedCB, nil);
	end

	-- Beginner Tooltips
	Settings.SetupCVarCheckBox(category, "showNewbieTips", SHOW_NEWBIE_TIPS_TEXT, OPTION_TOOLTIP_SHOW_NEWBIE_TIPS);

	-- Loading Screen Tips
	Settings.SetupCVarCheckBox(category, "showLoadingScreenTips", SHOW_TIPOFTHEDAY_TEXT, OPTION_TOOLTIP_SHOW_TIPOFTHEDAY);

	do
		-- Display Aggro Warning
		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(0, NEVER, OPTION_TOOLTIP_AGGRO_WARNING_DISPLAY1);
			container:Add(1, AGGRO_WARNING_IN_INSTANCE, OPTION_TOOLTIP_AGGRO_WARNING_DISPLAY2);
			container:Add(2, AGGRO_WARNING_IN_PARTY, OPTION_TOOLTIP_AGGRO_WARNING_DISPLAY3);
			container:Add(3, ALWAYS, OPTION_TOOLTIP_AGGRO_WARNING_DISPLAY4);
			return container:GetData();
		end

		Settings.SetupCVarDropDown(category, "threatWarning", Settings.VarType.Number, GetOptions, AGGRO_WARNING_DISPLAY, nil);
	end

	--Show Aggro Percentages
	Settings.SetupCVarCheckBox(category, "threatShowNumeric", SHOW_AGGRO_PERCENTAGES, OPTION_TOOLTIP_SHOW_NUMERIC_THREAT);

	--Show Enemy Castbars
	if GetClassicExpansionLevel() == LE_EXPANSION_CLASSIC then
		Settings.SetupCVarCheckBox(category, "showTargetCastbar", SHOW_ENEMY_CASTBARS, OPTION_TOOLTIP_SHOW_ENEMY_CASTBARS);		
	end

	--Show active player debuffs larger on target
	if GetClassicExpansionLevel() == LE_EXPANSION_CLASSIC then
		Settings.SetupCVarCheckBox(category, "showDynamicBuffSize", SHOW_DYNAMIC_BUFF_SIZE, OPTION_TOOLTIP_SHOW_DYNAMIC_BUFF_SIZE);		
	end

	if C_Engraving.IsEngravingEnabled() then
		Settings.SetupCVarCheckBox(category, "alwaysShowRuneIcons", ALWAYS_SHOW_RUNE_ICONS, OPTION_TOOLTIP_ALWAYS_SHOW_RUNE_ICONS);		
	end

	if ClassicExpansionAtLeast(LE_EXPANSION_WRATH_OF_THE_LICH_KING) then
		do
			-- Use Equipment Manager
			local function CVarChangedCB()
				local equipmentManager = C_CVar.GetCVarBool("equipmentManager");
				
				local toggleButton;
				if GetClassicExpansionLevel() == LE_EXPANSION_WRATH_OF_THE_LICH_KING then
					toggleButton = GearManagerToggleButton;
				else
					toggleButton = PaperDollSidebarTab3;
				end
				
				if ( equipmentManager ) then 
					toggleButton:Show() 
				else 
					toggleButton:Hide() 
				end 
			end
			
			CVarCallbackRegistry:RegisterCVarChangedCallback(CVarChangedCB, nil);
		end
	
		-- Preview Talent Changes
		Settings.SetupCVarCheckBox(category, "previewTalentsOption", PREVIEW_TALENT_CHANGES, OPTION_PREVIEW_TALENT_CHANGES_DESCRIPTION);
	end
end

-- RaidProfilesMixin
RaidProfilesMixin = CreateFromMixins(SettingsDropDownControlMixin);

function RaidProfilesMixin:OnLoad()
	SettingsDropDownControlMixin.OnLoad(self);

	self.NewButton:ClearAllPoints();
	self.NewButton:SetPoint("TOPRIGHT", self.DropDown.Button, "BOTTOM");

	self.DeleteButton:ClearAllPoints();
	self.DeleteButton:SetPoint("TOPLEFT", self.NewButton, "TOPRIGHT", -10);
end

function RaidProfilesMixin:Init(initializer)
	SettingsDropDownControlMixin.Init(self, initializer);

	self.NewButton:SetText(NEW_COMPACT_UNIT_FRAME_PROFILE);
	self.NewButton:SetScript("OnClick", function()
		StaticPopup_Show("RAID_PROFILE_NEW", CompactUnitFrameProfiles.selectedProfile, nil, { cbObject = self });
	end);

	self.DeleteButton:SetText(DELETE);
	self.DeleteButton:SetScript("OnClick", function()
		StaticPopup_Show("RAID_PROFILE_DELETION", CompactUnitFrameProfiles.selectedProfile, nil, { profile = CompactUnitFrameProfiles.selectedProfile, cbObject = self } );
	end);

	self:RefreshSelected();
	self:EvaluateButtonState();
end

function RaidProfilesMixin:Release()
	SettingsDropDownControlMixin.Release(self);
	self.NewButton:SetScript("OnClick", nil);
	self.DeleteButton:SetScript("OnClick", nil);
end

function RaidProfilesMixin:RefreshList()
	self:InitDropDown();
	self:SetValue(1);
	self:EvaluateButtonState();
end

function RaidProfilesMixin:RefreshSelected()
	for i=1, GetNumRaidProfiles() do
		local name = GetRaidProfileName(i);
		if CompactUnitFrameProfiles.selectedProfile == name then
			self:SetValue(i);
		end
	end
end

function RaidProfilesMixin:OnAdded(newProfileName)
	self:InitDropDown();
	for i=1, GetNumRaidProfiles() do
		local name = GetRaidProfileName(i);
		if newProfileName == name then
			self:SetValue(i);
			break;
		end
	end
	self:EvaluateButtonState();
end

function RaidProfilesMixin:OnDeleted()
	self:RefreshList();
end

function RaidProfilesMixin:EvaluateButtonState()
	self.NewButton:SetEnabled(GetNumRaidProfiles() < GetMaxNumCUFProfiles());
	self.DeleteButton:SetEnabled(GetNumRaidProfiles() > 1 );
end

local function RefreshSetting(name)
	local setting = Settings.GetSetting(name);
	securecallfunction(setting.SetValue, setting, setting:GetInitValue());
end

function InterfaceOverrides.RefreshRaidOptions()
	RefreshSetting("PROXY_RAID_FRAME_CLASS_COLORS");
	RefreshSetting("PROXY_RAID_FRAME_PETS");
	RefreshSetting("PROXY_RAID_FRAME_TANK_ASSIST");
	RefreshSetting("PROXY_RAID_FRAME_BORDER");
	RefreshSetting("PROXY_RAID_FRAME_SHOW_DEBUFFS");
	RefreshSetting("PROXY_RAID_FRAME_KEEP_GROUPS_TOGETHER");
	RefreshSetting("PROXY_RAID_FRAME_KEEP_HORIZONTAL_GROUPS");
	RefreshSetting("PROXY_RAID_FRAME_SORT_BY");
	RefreshSetting("PROXY_RAID_FRAME_POWER_BAR");
	RefreshSetting("PROXY_RAID_FRAME_DISPELLABLE_DEBUFFS");
	RefreshSetting("PROXY_RAID_HEALTH_TEXT");
	RefreshSetting("PROXY_RAID_FRAME_HEIGHT");
	RefreshSetting("PROXY_RAID_FRAME_WIDTH");
	RefreshSetting("PROXY_RAID_AUTO_ACTIVATE");
	RefreshSetting("PROXY_RAID_AUTO_ACTIVATE_2");
	RefreshSetting("PROXY_RAID_AUTO_ACTIVATE_3");
	RefreshSetting("PROXY_RAID_AUTO_ACTIVATE_5");
	RefreshSetting("PROXY_RAID_AUTO_ACTIVATE_10");
	RefreshSetting("PROXY_RAID_AUTO_ACTIVATE_15");
	RefreshSetting("PROXY_RAID_AUTO_ACTIVATE_20");
	RefreshSetting("PROXY_RAID_AUTO_ACTIVATE_40");
end

function InterfaceOverrides.GetRaidProfileOption(option, default)
	if(CompactUnitFrameProfiles.selectedProfile) then
		return GetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, option);	
	end

	return default;
end

function InterfaceOverrides.SetRaidProfileOption(option, value)
	if(CompactUnitFrameProfiles.selectedProfile) then
		SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, option, value);
		CompactUnitFrameProfiles_ApplyCurrentSettings();
	end	
end

function InterfaceOverrides.CreateRaidFrameSettings(category, layout)
	if ( not C_AddOns.IsAddOnLoaded("Blizzard_CUFProfiles") ) then
		UIParentLoadAddOn("Blizzard_CUFProfiles");
	end

	do
		-- Raid-Style Party Frames
		local function CVarChangedCB()
			local compactFrames = C_CVar.GetCVarBool("useCompactPartyFrames");
			RaidOptionsFrame_UpdatePartyFrames()
			CompactRaidFrameManager_UpdateShown(CompactRaidFrameManager);
			InterfaceOverrides.RefreshRaidOptions();
		end

		Settings.SetupCVarCheckBox(category, "useCompactPartyFrames", USE_RAID_STYLE_PARTY_FRAMES, OPTION_TOOLTIP_USE_RAID_STYLE_PARTY_FRAMES);
		CVarCallbackRegistry:RegisterCVarChangedCallback(CVarChangedCB, nil);
	end

	do
		-- Profile Drop Down
		local function GetValue()
			for i=1, GetNumRaidProfiles() do
				local name = GetRaidProfileName(i);
				if CompactUnitFrameProfiles.selectedProfile == name then
					return i;
				end
			end
			return 0;
		end
		
		local function SetValue(value)
			if ( RaidProfileHasUnsavedChanges() ) then
				CompactUnitFrameProfiles_SaveChanges(CompactUnitFrameProfiles);
			end

			CompactUnitFrameProfiles_SetRaidProfile(GetRaidProfileName(value));
			InterfaceOverrides.RefreshRaidOptions();
			CompactUnitFrameProfiles_ApplyCurrentSettings();
		end

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			for i=1, GetNumRaidProfiles() do
				local name = GetRaidProfileName(i);
				container:Add(i, name, nil);
			end
			return container:GetData();
		end

		local defaultValue = 1;
		local raidProfileSetting = Settings.RegisterProxySetting(category, "PROXY_RAID_PROFILE", Settings.DefaultVarLocation,
			Settings.VarType.Number, COMPACT_UNIT_FRAME_PROFILE_LABEL, defaultValue, GetValue, SetValue);
		local raidProfileData = Settings.CreateSettingInitializerData(raidProfileSetting, GetOptions);

		local raidProfileInitializer = Settings.CreateSettingInitializer("RaidProfilesTemplate", raidProfileData);

		layout:AddInitializer(raidProfileInitializer);

	end

	do
		-- Keep Groups Together
		local defaultValue = false;
		local function GetValue()
			return InterfaceOverrides.GetRaidProfileOption("keepGroupsTogether", defaultValue);
		end
		
		local function SetValue(value)
			local test = InterfaceOverrides.GetRaidProfileOption("keepGroupsTogether", defaultValue);
			InterfaceOverrides.SetRaidProfileOption("keepGroupsTogether", value);
		end
		
		local keepGroupsTogetherSetting = Settings.RegisterProxySetting(category, "PROXY_RAID_FRAME_KEEP_GROUPS_TOGETHER", Settings.DefaultVarLocation, 
			Settings.VarType.Boolean, COMPACT_UNIT_FRAME_PROFILE_KEEPGROUPSTOGETHER, defaultValue, GetValue, SetValue);
		local keepGroupsInitializer = Settings.CreateCheckBox(category, keepGroupsTogetherSetting, OPTION_TOOLTIP_KEEP_GROUPS_TOGETHER);

		-- Horizontal Groups
		local defaultValue = true;
		local function GetValue()
			return InterfaceOverrides.GetRaidProfileOption("horizontalGroups", defaultValue);
		end
		
		local function SetValue(value)
			InterfaceOverrides.SetRaidProfileOption("horizontalGroups", value);
		end

		local horizontalSetting = Settings.RegisterProxySetting(category, "PROXY_RAID_FRAME_KEEP_HORIZONTAL_GROUPS", Settings.DefaultVarLocation, 
			Settings.VarType.Boolean, COMPACT_UNIT_FRAME_PROFILE_HORIZONTALGROUPS, defaultValue, GetValue, SetValue);
		local horizontalGroupsInitializer = Settings.CreateCheckBox(category, horizontalSetting, nil);

		local function HorizontalShouldShow()
			return keepGroupsTogetherSetting:GetValue();
		end

		horizontalGroupsInitializer:SetParentInitializer(keepGroupsInitializer);
		horizontalGroupsInitializer:AddShownPredicate(HorizontalShouldShow);

		-- Sort By
		local defaultValue = "role";
		local function GetValue()
			return InterfaceOverrides.GetRaidProfileOption("sortBy", defaultValue);
		end
		
		local function SetValue(value)
			InterfaceOverrides.SetRaidProfileOption("sortBy", value);
		end

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add("role", RAID_SORT_ROLE, OPTION_RAID_SORT_BY_ROLE);
			container:Add("group", RAID_SORT_GROUP, OPTION_RAID_SORT_BY_GROUP);
			container:Add("alphabetical", RAID_SORT_ALPHABETICAL, OPTION_RAID_SORT_BY_ALPHABETICAL);
			return container:GetData();
		end

		local sortBySetting = Settings.RegisterProxySetting(category, "PROXY_RAID_FRAME_SORT_BY", Settings.DefaultVarLocation,
			Settings.VarType.String, COMPACT_UNIT_FRAME_PROFILE_SORTBY, defaultValue, GetValue, SetValue);


		local sortByInitializer = Settings.CreateDropDown(category, sortBySetting, GetOptions, TOOLTIP_TEXT);

		local function SortShouldShow()
			return not keepGroupsTogetherSetting:GetValue();
		end

		sortByInitializer:SetParentInitializer(keepGroupsInitializer);
		sortByInitializer:AddShownPredicate(SortShouldShow);
	end

	do
		-- Display Power Bars
		local defaultValue = false;
		local function GetValue()
			return InterfaceOverrides.GetRaidProfileOption("displayPowerBar", defaultValue);
		end
		
		local function SetValue(value)
			InterfaceOverrides.SetRaidProfileOption("displayPowerBar", value);
		end
		
		local setting = Settings.RegisterProxySetting(category, "PROXY_RAID_FRAME_POWER_BAR", Settings.DefaultVarLocation, 
			Settings.VarType.Boolean, COMPACT_UNIT_FRAME_PROFILE_DISPLAYPOWERBAR, defaultValue, GetValue, SetValue);
		Settings.CreateCheckBox(category, setting, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYPOWERBAR);
	end
	
	do
		-- Use Class Colors
		local defaultValue = false;
		local function GetValue()
			return InterfaceOverrides.GetRaidProfileOption("useClassColors", defaultValue);
		end
		
		local function SetValue(value)
			InterfaceOverrides.SetRaidProfileOption("useClassColors", value);
		end
		
		local setting = Settings.RegisterProxySetting(category, "PROXY_RAID_FRAME_CLASS_COLORS", Settings.DefaultVarLocation, 
			Settings.VarType.Boolean, COMPACT_UNIT_FRAME_PROFILE_USECLASSCOLORS, defaultValue, GetValue, SetValue);
		Settings.CreateCheckBox(category, setting, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_USECLASSCOLORS);
	end

	do
		-- Display Pets
		local defaultValue = false;
		local function GetValue()
			return InterfaceOverrides.GetRaidProfileOption("displayPets", defaultValue);
		end
		
		local function SetValue(value)
			InterfaceOverrides.SetRaidProfileOption("displayPets", value);
		end
		
		local setting = Settings.RegisterProxySetting(category, "PROXY_RAID_FRAME_PETS", Settings.DefaultVarLocation, 
			Settings.VarType.Boolean, COMPACT_UNIT_FRAME_PROFILE_DISPLAYPETS, defaultValue, GetValue, SetValue);
		Settings.CreateCheckBox(category, setting, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYPETS);
	end

	do
		-- Display Main Tank and Assist
		local defaultValue = true;
		local function GetValue()
			return InterfaceOverrides.GetRaidProfileOption("displayMainTankAndAssist", defaultValue);
		end
		
		local function SetValue(value)
			InterfaceOverrides.SetRaidProfileOption("displayMainTankAndAssist", value);
		end
		
		local setting = Settings.RegisterProxySetting(category, "PROXY_RAID_FRAME_TANK_ASSIST", Settings.DefaultVarLocation, 
			Settings.VarType.Boolean, COMPACT_UNIT_FRAME_PROFILE_DISPLAYMAINTANKANDASSIST, defaultValue, GetValue, SetValue);
		Settings.CreateCheckBox(category, setting, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYMAINTANKANDASSIST);
	end

	do
		-- Display Border
		local defaultValue = true;
		local function GetValue()
			return InterfaceOverrides.GetRaidProfileOption("displayBorder", defaultValue);
		end
		
		local function SetValue(value)
			InterfaceOverrides.SetRaidProfileOption("displayBorder", value);
		end
		
		local setting = Settings.RegisterProxySetting(category, "PROXY_RAID_FRAME_BORDER", Settings.DefaultVarLocation, 
			Settings.VarType.Boolean, COMPACT_UNIT_FRAME_PROFILE_DISPLAYBORDER, defaultValue, GetValue, SetValue);
		Settings.CreateCheckBox(category, setting, nil);
	end

	do
		-- Show Debuffs
		local defaultValue = true;
		local function GetValue()
			return InterfaceOverrides.GetRaidProfileOption("displayNonBossDebuffs", defaultValue);
		end
		
		local function SetValue(value)
			InterfaceOverrides.SetRaidProfileOption("displayNonBossDebuffs", value);
		end

		local debuffsSetting = Settings.RegisterProxySetting(category, "PROXY_RAID_FRAME_SHOW_DEBUFFS", Settings.DefaultVarLocation, 
			Settings.VarType.Boolean, COMPACT_UNIT_FRAME_PROFILE_DISPLAYNONBOSSDEBUFFS, defaultValue, GetValue, SetValue);
		local debuffsInitializer = Settings.CreateCheckBox(category, debuffsSetting, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYNONBOSSDEBUFFS);

		-- Display Only Dispellable Debuffs
		local defaultValue = true;
		local function GetValue()
			return InterfaceOverrides.GetRaidProfileOption("displayOnlyDispellableDebuffs", defaultValue);
		end
		
		local function SetValue(value)
			InterfaceOverrides.SetRaidProfileOption("displayOnlyDispellableDebuffs", value);
		end

		local dispellableSetting = Settings.RegisterProxySetting(category, "PROXY_RAID_FRAME_DISPELLABLE_DEBUFFS", Settings.DefaultVarLocation, 
			Settings.VarType.Boolean, DISPLAY_ONLY_DISPELLABLE_DEBUFFS, defaultValue, GetValue, SetValue);
		local dispellableInitializer = Settings.CreateCheckBox(category, dispellableSetting, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYONLYDISPELLABLEDEBUFFS);

		local function IsModifiable()
			return debuffsSetting:GetValue();
		end

		dispellableInitializer:SetParentInitializer(debuffsInitializer, IsModifiable);
	 end


	 do
		-- Display Health Text
		local defaultValue = "none";
		local function GetValue()
			return InterfaceOverrides.GetRaidProfileOption("healthText", defaultValue);
		end
		
		local function SetValue(value)
			InterfaceOverrides.SetRaidProfileOption("healthText", value);
		end

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add("none", COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, nil);
			container:Add("health", COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, nil);
			container:Add("losthealth", COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH, nil);
			container:Add("perc", COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, nil);
			return container:GetData();
		end

		local healthTextSetting = Settings.RegisterProxySetting(category, "PROXY_RAID_HEALTH_TEXT", Settings.DefaultVarLocation,
			Settings.VarType.String, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, defaultValue, GetValue, SetValue);
		Settings.CreateDropDown(category, healthTextSetting, GetOptions, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT);
	end

	do
		-- Frame Height
		local defaultValue = 36;
		local function GetValue()
			return InterfaceOverrides.GetRaidProfileOption("frameHeight", defaultValue);
		end
		
		local function SetValue(value)
			InterfaceOverrides.SetRaidProfileOption("frameHeight", value);
		end
		
		local setting = Settings.RegisterProxySetting(category, "PROXY_RAID_FRAME_HEIGHT", Settings.DefaultVarLocation, 
			Settings.VarType.Number, COMPACT_UNIT_FRAME_PROFILE_FRAMEHEIGHT, defaultValue, GetValue, SetValue);

		local function FormatScaledPercentage(value)
			return FormatPercentage(value/36);
		end

		local minValue, maxValue, step = 36, 72, 2;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatScaledPercentage);
		Settings.CreateSlider(category, setting, options, nil);
	end

	do
		-- Frame Width
		local defaultValue = 36;
		local function GetValue()
			return InterfaceOverrides.GetRaidProfileOption("frameWidth", defaultValue);
		end
		
		local function SetValue(value)
			InterfaceOverrides.SetRaidProfileOption("frameWidth", value);
		end
		
		local setting = Settings.RegisterProxySetting(category, "PROXY_RAID_FRAME_WIDTH", Settings.DefaultVarLocation, 
			Settings.VarType.Number, COMPACT_UNIT_FRAME_PROFILE_FRAMEWIDTH, defaultValue, GetValue, SetValue);

		local function FormatScaledPercentage(value)
			return FormatPercentage(value/72);
		end

		local minValue, maxValue, step = 72, 144, 2;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatScaledPercentage);
		Settings.CreateSlider(category, setting, options, nil);
	end

	do
		--Auto Activate PvE/PvP
		local function GetValue()
			local pvp = InterfaceOverrides.GetRaidProfileOption("autoActivatePvP", false);
			local pve = InterfaceOverrides.GetRaidProfileOption("autoActivatePvE", false);
			if ( pvp and pve ) then
				return 4;
			elseif ( pvp )  then
				return 3;
			elseif ( pve ) then
				return 2;
			end

			-- disabled
			return 1;
		end
		
		local function SetValue(value)
			SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "autoActivatePvP", value == 4 or value == 3);
			SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "autoActivatePvE", value == 4 or value == 2);
			CompactUnitFrameProfiles_ApplyCurrentSettings();
		end

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(1, VIDEO_OPTIONS_DISABLED, nil);
			container:Add(2, COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATEPVE, nil);
			container:Add(3, COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATEPVP, nil);
			container:Add(4, PVE_AND_PVP, nil);
			return container:GetData();
		end

		local defaultValue = 1;
		local autoActivateSetting = Settings.RegisterProxySetting(category, "PROXY_RAID_AUTO_ACTIVATE", Settings.DefaultVarLocation,
			Settings.VarType.Number, AUTO_ACTIVATE_ON, defaultValue, GetValue, SetValue);
		local autoActivateInitializer = Settings.CreateDropDown(category, autoActivateSetting, GetOptions, nil);


		--Auto Activate Player Count

		local function IsModifiable()
			return autoActivateSetting:GetValue() ~= 1;
		end

		do
			-- Auto Activate 2
			local defaultValue = false;
			local function GetValue()
				return InterfaceOverrides.GetRaidProfileOption("autoActivate2Players", defaultValue);
			end
		
			local function SetValue(value)
				InterfaceOverrides.SetRaidProfileOption("autoActivate2Players", value);
			end
		
			local setting = Settings.RegisterProxySetting(category, "PROXY_RAID_AUTO_ACTIVATE_2", Settings.DefaultVarLocation, 
				Settings.VarType.Boolean, COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATE2PLAYERS, defaultValue, GetValue, SetValue);
			local initializer = Settings.CreateCheckBox(category, setting, nil);
			initializer:SetParentInitializer(autoActivateInitializer, IsModifiable);
		end

		do
			-- Auto Activate 3
			local defaultValue = false;
			local function GetValue()
				return InterfaceOverrides.GetRaidProfileOption("autoActivate3Players", defaultValue);
			end
		
			local function SetValue(value)
				InterfaceOverrides.SetRaidProfileOption("autoActivate3Players", value);
			end

			local setting = Settings.RegisterProxySetting(category, "PROXY_RAID_AUTO_ACTIVATE_3", Settings.DefaultVarLocation, 
				Settings.VarType.Boolean, COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATE3PLAYERS, defaultValue, GetValue, SetValue);
			local initializer = Settings.CreateCheckBox(category, setting, nil);
			initializer:SetParentInitializer(autoActivateInitializer, IsModifiable);
		end

		do
			-- Auto Activate 5
			local defaultValue = false;
			local function GetValue()
				return InterfaceOverrides.GetRaidProfileOption("autoActivate5Players", defaultValue);
			end
		
			local function SetValue(value)
				InterfaceOverrides.SetRaidProfileOption("autoActivate5Players", value);
			end

			local setting = Settings.RegisterProxySetting(category, "PROXY_RAID_AUTO_ACTIVATE_5", Settings.DefaultVarLocation, 
				Settings.VarType.Boolean, COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATE5PLAYERS, defaultValue, GetValue, SetValue);
			local initializer = Settings.CreateCheckBox(category, setting, nil);
			initializer:SetParentInitializer(autoActivateInitializer, IsModifiable);
		end

		do
			-- Auto Activate 10
			local defaultValue = false;
			local function GetValue()
				return InterfaceOverrides.GetRaidProfileOption("autoActivate10Players", defaultValue);
			end
		
			local function SetValue(value)
				InterfaceOverrides.SetRaidProfileOption("autoActivate10Players", value);
			end

			local setting = Settings.RegisterProxySetting(category, "PROXY_RAID_AUTO_ACTIVATE_10", Settings.DefaultVarLocation, 
				Settings.VarType.Boolean, COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATE10PLAYERS, defaultValue, GetValue, SetValue);
			local initializer = Settings.CreateCheckBox(category, setting, nil);
			initializer:SetParentInitializer(autoActivateInitializer, IsModifiable);
		end

		do
			-- Auto Activate 15
			local defaultValue = false;
			local function GetValue()
				return InterfaceOverrides.GetRaidProfileOption("autoActivate15Players", defaultValue);
			end
		
			local function SetValue(value)
				InterfaceOverrides.SetRaidProfileOption("autoActivate15Players", value);
			end

			local setting = Settings.RegisterProxySetting(category, "PROXY_RAID_AUTO_ACTIVATE_15", Settings.DefaultVarLocation, 
				Settings.VarType.Boolean, COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATE15PLAYERS, defaultValue, GetValue, SetValue);
			local initializer = Settings.CreateCheckBox(category, setting, nil);
			initializer:SetParentInitializer(autoActivateInitializer, IsModifiable);
		end

		do
			-- Auto Activate 20
			local defaultValue = false;
			local function GetValue()
				return InterfaceOverrides.GetRaidProfileOption("autoActivate20Players", defaultValue);
			end
		
			local function SetValue(value)
				InterfaceOverrides.SetRaidProfileOption("autoActivate20Players", value);
			end

			local setting = Settings.RegisterProxySetting(category, "PROXY_RAID_AUTO_ACTIVATE_20", Settings.DefaultVarLocation, 
				Settings.VarType.Boolean, COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATE20PLAYERS, defaultValue, GetValue, SetValue);
			local initializer = Settings.CreateCheckBox(category, setting, nil);
			initializer:SetParentInitializer(autoActivateInitializer, IsModifiable);
		end

		do
			-- Auto Activate 40
			local defaultValue = false;
			local function GetValue()
				return InterfaceOverrides.GetRaidProfileOption("autoActivate40Players", defaultValue);
			end
		
			local function SetValue(value)
				InterfaceOverrides.SetRaidProfileOption("autoActivate40Players", value);
			end

			local setting = Settings.RegisterProxySetting(category, "PROXY_RAID_AUTO_ACTIVATE_40", Settings.DefaultVarLocation, 
				Settings.VarType.Boolean, COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATE40PLAYERS, defaultValue, GetValue, SetValue);
			local initializer = Settings.CreateCheckBox(category, setting, nil);
			initializer:SetParentInitializer(autoActivateInitializer, IsModifiable);
		end
	end
end

function InterfaceOverrides.CreatePvpFrameSettings(category, layout)
	--No setting in Classic
end

function InterfaceOverrides.ShowTutorialsOnButtonClick()
		SetCVar("closedInfoFrames", ""); -- reset the help plates too
		SetCVar("showTutorials", "1");
		ResetTutorials();
		TutorialFrame_HideAllAlerts();
end

function InterfaceOverrides.RunSettingsCallback(callback)
	callback();
end