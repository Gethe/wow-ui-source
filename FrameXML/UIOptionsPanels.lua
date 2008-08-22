CONTROLTYPE_CHECKBOX = 1;
CONTROLTYPE_DROPDOWN = 2;
CONTROLTYPE_SLIDER = 3;

-- [[ Controls Options Panel ]] --

ControlsPanelOptions = {
	deselectOnClick = { text = "GAMEFIELD_DESELECT_TEXT" },
	gxFixLag = { text = "FIX_LAG" },
	autoDismountFlying = { text = "AUTO_DISMOUNT_FLYING_TEXT" },
	autoClearAFK = { text = "CLEAR_AFK" },
	blockTrades = { text="BLOCK_TRADES" },
	lootUnderMouse = { text = "LOOT_UNDER_MOUSE_TEXT" },
	autoLootDefault = { text = "AUTO_LOOT_DEFAULT_TEXT" }, -- When this gets changed, the function SetAutoLootDefault needs to get run with its value.
	autoLootKey = { text="AUTO_LOOT_KEY_TEXT", default="NONE" },
}

function InterfaceOptionsControlsPanelAutoLootKeyDropDown_OnLoad()

end

function InterfaceOptionsControlsPanelAutoLootKeyDropDown_OnEvent (self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD");
		UIDropDownMenu_Initialize(self, InterfaceOptionsControlsPanelAutoLootKeyDropDown_Initialize);
		UIDropDownMenu_SetSelectedValue(self, GetModifiedClick("AUTOLOOTTOGGLE"));
		self.defaultValue = "NONE";
		self.currValue = GetModifiedClick("AUTOLOOTTOGGLE");
		self.value = self.currValue;
		InterfaceOptionsControlsPanelAutoLootKeyDropDown.tooltip = getglobal("OPTION_TOOLTIP_AUTO_LOOT_"..self.value.."_KEY");
		UIDropDownMenu_SetWidth(self, 90);
		self.SetValue = 
			function (self, value) 
				self.value = value;
				UIDropDownMenu_SetSelectedValue(self, value);
				SetModifiedClick("AUTOLOOTTOGGLE", value);
				SaveBindings(GetCurrentBindingSet());
				InterfaceOptionsControlsPanelAutoLootKeyDropDown.tooltip = getglobal("OPTION_TOOLTIP_AUTO_LOOT_"..value.."_KEY");	
			end;
		self.GetValue =
			function (self)
				return UIDropDownMenu_GetSelectedValue(self);
			end
		if ( GetCVar("autoLootDefault") == "1" ) then
			InterfaceOptionsControlsPanelAutoLootKeyDropDownLabel:SetText(LOOT_KEY_TEXT);
		else
			InterfaceOptionsControlsPanelAutoLootKeyDropDownLabel:SetText(AUTO_LOOT_KEY_TEXT);
		end
	end
end

function InterfaceOptionsControlsPanelAutoLootKeyDropDown_OnClick(self)
	InterfaceOptionsControlsPanelAutoLootKeyDropDown:SetValue(self.value);
end

function InterfaceOptionsControlsPanelAutoLootKeyDropDown_Initialize()
	local selectedValue = UIDropDownMenu_GetSelectedValue(InterfaceOptionsControlsPanelAutoLootKeyDropDown);
	local info = UIDropDownMenu_CreateInfo();

	info.text = ALT_KEY;
	info.func = InterfaceOptionsControlsPanelAutoLootKeyDropDown_OnClick;
	info.value = "ALT";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = ALT_KEY;
	info.tooltipText = OPTION_TOOLTIP_AUTO_LOOT_ALT_KEY;
	UIDropDownMenu_AddButton(info);

	info.text = CTRL_KEY;
	info.func = InterfaceOptionsControlsPanelAutoLootKeyDropDown_OnClick;
	info.value = "CTRL";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = CTRL_KEY;
	info.tooltipText = OPTION_TOOLTIP_AUTO_LOOT_CTRL_KEY;
	UIDropDownMenu_AddButton(info);

	info.text = SHIFT_KEY;
	info.func = InterfaceOptionsControlsPanelAutoLootKeyDropDown_OnClick;
	info.value = "SHIFT";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = SHIFT_KEY;
	info.tooltipText = OPTION_TOOLTIP_AUTO_LOOT_SHIFT_KEY;
	UIDropDownMenu_AddButton(info);

	info.text = NONE_KEY;
	info.func = InterfaceOptionsControlsPanelAutoLootKeyDropDown_OnClick;
	info.value = "NONE";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = NONE_KEY;
	info.tooltipText = OPTION_TOOLTIP_AUTO_LOOT_NONE_KEY;
	UIDropDownMenu_AddButton(info);
end

function BlizzardOptionsPanel_UpdateAutoLootDropDown (value)
	if ( not InterfaceOptionsControlsPanelAutoLootKeyDropDownLabel ) then
		return;
	end

	if ( value == "1" ) then
		InterfaceOptionsControlsPanelAutoLootKeyDropDownLabel:SetText(LOOT_KEY_TEXT);
	else
		InterfaceOptionsControlsPanelAutoLootKeyDropDownLabel:SetText(AUTO_LOOT_KEY_TEXT);
	end
end

-- [[ Combat Options Panel ]] --

CombatPanelOptions = {
	assistAttack = { text = "ASSIST_ATTACK" },
	autoRangedCombat = { text = "AUTO_RANGED_COMBAT_TEXT" },
	autoSelfCast = { text = "AUTO_SELF_CAST_TEXT" },
	stopAutoAttackOnTargetChange = { text = "STOP_AUTO_ATTACK" },
	showTargetOfTarget = { text = "SHOW_TARGET_OF_TARGET_TEXT" },
	showTargetCastbar = { text = "SHOW_TARGET_CASTBAR" },
	showVKeyCastbar = { text = "SHOW_TARGET_CASTBAR_IN_V_KEY" },
	ShowClassColorInNameplate = { text = "SHOW_CLASS_COLOR_IN_V_KEY" },
}

function InterfaceOptionsCombatPanelTOTDropDown_OnLoad(self)
	self.defaultValue = "5";
	self.value = GetCVar("targetOfTargetMode");
	self.currValue = self.value;
	setglobal(self.uvar, self.value);
	UIDropDownMenu_Initialize(self, InterfaceOptionsCombatPanelTOTDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(self, self.value);
	InterfaceOptionsCombatPanelTOTDropDown.tooltip = getglobal("OPTION_TOOLTIP_TARGETOFTARGET" .. self.value);
	UIDropDownMenu_SetWidth(self, 110);	
	self.SetValue = function (self, value)
		self.value = value;
		SetCVar("targetOfTargetMode", value);
		setglobal(self.uvar, value);
		UIDropDownMenu_SetSelectedValue(self, value);
		self.tooltip = getglobal("OPTION_TOOLTIP_TARGETOFTARGET" .. value);
	end
	self.GetValue = function (self)
		return UIDropDownMenu_GetSelectedValue(self);
	end
end

function InterfaceOptionsCombatPanelTOTDropDown_OnClick(self)
	InterfaceOptionsCombatPanelTOTDropDown:SetValue(self.value);
end

function InterfaceOptionsCombatPanelTOTDropDown_Initialize(self)
	local selectedValue = UIDropDownMenu_GetSelectedValue(self);
	local info = UIDropDownMenu_CreateInfo();

	info.text = RAID;
	info.func = InterfaceOptionsCombatPanelTOTDropDown_OnClick;
	info.value = "1"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = RAID;
	info.tooltipText = OPTION_TOOLTIP_TARGETOFTARGET_RAID;
	UIDropDownMenu_AddButton(info);

	info.text = PARTY;
	info.func = InterfaceOptionsCombatPanelTOTDropDown_OnClick;
	info.value = "2"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = PARTY;
	info.tooltipText = OPTION_TOOLTIP_TARGETOFTARGET_PARTY;
	UIDropDownMenu_AddButton(info);

	info.text = SOLO;
	info.func = InterfaceOptionsCombatPanelTOTDropDown_OnClick;
	info.value = "3"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = SOLO;
	info.tooltipText = OPTION_TOOLTIP_TARGETOFTARGET_SOLO;
	UIDropDownMenu_AddButton(info);

	info.text = RAID_AND_PARTY;
	info.func = InterfaceOptionsCombatPanelTOTDropDown_OnClick;
	info.value = "4"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = RAID_AND_PARTY;
	info.tooltipText = OPTION_TOOLTIP_TARGETOFTARGET_RAID_AND_PARTY;
	UIDropDownMenu_AddButton(info);

	info.text = ALWAYS;
	info.func = InterfaceOptionsCombatPanelTOTDropDown_OnClick;
	info.value = "5"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = ALWAYS;
	info.tooltipText = OPTION_TOOLTIP_TARGETOFTARGET_ALWAYS;
	UIDropDownMenu_AddButton(info);
end

-- [[ Self Cast key dropdown ]] --
function InterfaceOptionsCombatPanelSelfCastKeyDropDown_OnEvent (self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD");
		UIDropDownMenu_Initialize(self, InterfaceOptionsCombatPanelSelfCastKeyDropDown_Initialize);
		UIDropDownMenu_SetSelectedValue(self, GetModifiedClick("SELFCAST"));
		self.defaultValue = "NONE";
		self.currValue = GetModifiedClick("SELFCAST");
		self.value = self.currValue;
		InterfaceOptionsCombatPanelSelfCastKeyDropDown.tooltip = getglobal("OPTION_TOOLTIP_AUTO_SELF_CAST_"..self.value.."_KEY");
		UIDropDownMenu_SetWidth(self, 90);
		self.SetValue = 
			function (self, value) 
				self.value = value;
				UIDropDownMenu_SetSelectedValue(self, value);
				SetModifiedClick("SELFCAST", value);
				SaveBindings(GetCurrentBindingSet());
				InterfaceOptionsCombatPanelSelfCastKeyDropDown.tooltip = getglobal("OPTION_TOOLTIP_AUTO_SELF_CAST_"..value.."_KEY");	
			end;
		self.GetValue =
			function (self)
				return UIDropDownMenu_GetSelectedValue(self);
			end
	end
end

function InterfaceOptionsCombatPanelSelfCastKeyDropDown_OnClick(self)
	InterfaceOptionsCombatPanelSelfCastKeyDropDown:SetValue(self.value);
end

function InterfaceOptionsCombatPanelSelfCastKeyDropDown_Initialize()
	local selectedValue = UIDropDownMenu_GetSelectedValue(InterfaceOptionsCombatPanelSelfCastKeyDropDown);
	local info = UIDropDownMenu_CreateInfo();

	info.text = ALT_KEY;
	info.func = InterfaceOptionsCombatPanelSelfCastKeyDropDown_OnClick;
	info.value = "ALT";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = ALT_KEY;
	info.tooltipText = OPTION_TOOLTIP_AUTO_SELF_CAST_ALT_KEY;
	UIDropDownMenu_AddButton(info);

	info.text = CTRL_KEY;
	info.func = InterfaceOptionsCombatPanelSelfCastKeyDropDown_OnClick;
	info.value = "CTRL";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = CTRL_KEY;
	info.tooltipText = OPTION_TOOLTIP_AUTO_SELF_CAST_CTRL_KEY;
	UIDropDownMenu_AddButton(info);

	info.text = SHIFT_KEY;
	info.func = InterfaceOptionsCombatPanelSelfCastKeyDropDown_OnClick;
	info.value = "SHIFT";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = SHIFT_KEY;
	info.tooltipText = OPTION_TOOLTIP_AUTO_SELF_CAST_SHIFT_KEY;
	UIDropDownMenu_AddButton(info);

	info.text = NONE_KEY;
	info.func = InterfaceOptionsCombatPanelSelfCastKeyDropDown_OnClick;
	info.value = "NONE";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = NONE_KEY;
	info.tooltipText = OPTION_TOOLTIP_AUTO_SELF_CAST_NONE_KEY;
	UIDropDownMenu_AddButton(info);
end

-- [[ Focus Cast key dropdown ]] --
function InterfaceOptionsCombatPanelFocusCastKeyDropDown_OnEvent (self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD");
		UIDropDownMenu_Initialize(self, InterfaceOptionsCombatPanelFocusCastKeyDropDown_Initialize);
		UIDropDownMenu_SetSelectedValue(self, GetModifiedClick("FOCUSCAST"));
		self.defaultValue = "NONE";
		self.currValue = GetModifiedClick("FOCUSCAST");
		self.value = self.currValue;
		InterfaceOptionsCombatPanelFocusCastKeyDropDown.tooltip = getglobal("OPTION_TOOLTIP_FOCUS_CAST_"..self.value.."_KEY");
		UIDropDownMenu_SetWidth(self, 90);
		self.SetValue = 
			function (self, value) 
				self.value = value;
				UIDropDownMenu_SetSelectedValue(self, value);
				SetModifiedClick("FOCUSCAST", value);
				SaveBindings(GetCurrentBindingSet());
				InterfaceOptionsCombatPanelFocusCastKeyDropDown.tooltip = getglobal("OPTION_TOOLTIP_FOCUS_CAST_"..value.."_KEY");	
			end;
		self.GetValue =
			function (self)
				return UIDropDownMenu_GetSelectedValue(self);
			end
	end
end

function InterfaceOptionsCombatPanelFocusCastKeyDropDown_OnClick(self)
	InterfaceOptionsCombatPanelFocusCastKeyDropDown:SetValue(self.value);
end

function InterfaceOptionsCombatPanelFocusCastKeyDropDown_Initialize()
	local selectedValue = UIDropDownMenu_GetSelectedValue(InterfaceOptionsCombatPanelFocusCastKeyDropDown);
	local info = UIDropDownMenu_CreateInfo();

	info.text = ALT_KEY;
	info.func = InterfaceOptionsCombatPanelFocusCastKeyDropDown_OnClick;
	info.value = "ALT";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = ALT_KEY;
	info.tooltipText = OPTION_TOOLTIP_FOCUS_CAST_ALT_KEY;
	UIDropDownMenu_AddButton(info);

	info.text = CTRL_KEY;
	info.func = InterfaceOptionsCombatPanelFocusCastKeyDropDown_OnClick;
	info.value = "CTRL";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = CTRL_KEY;
	info.tooltipText = OPTION_TOOLTIP_AUTO_SELF_CAST_CTRL_KEY;
	UIDropDownMenu_AddButton(info);

	info.text = SHIFT_KEY;
	info.func = InterfaceOptionsCombatPanelFocusCastKeyDropDown_OnClick;
	info.value = "SHIFT";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = SHIFT_KEY;
	info.tooltipText = OPTION_TOOLTIP_AUTO_SELF_CAST_SHIFT_KEY;
	UIDropDownMenu_AddButton(info);

	info.text = NONE_KEY;
	info.func = InterfaceOptionsCombatPanelFocusCastKeyDropDown_OnClick;
	info.value = "NONE";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = NONE_KEY;
	info.tooltipText = OPTION_TOOLTIP_AUTO_SELF_CAST_NONE_KEY;
	UIDropDownMenu_AddButton(info);
end


-- [[ Display Options Panel ]] --

DisplayPanelOptions = {
	buffDurations = { text = "SHOW_BUFF_DURATION_TEXT" },
	rotateMinimap = { text = "ROTATE_MINIMAP" },
	screenEdgeFlash = { text = "SHOW_FULLSCREEN_STATUS_TEXT" },
	showLootSpam = { text = "SHOW_LOOT_SPAM" },
	displayFreeBagSlots = { text = "DISPLAY_FREE_BAG_SLOTS" },
	showClock = { text = "SHOW_CLOCK" },
}

function InterfaceOptionsDisplayPanelShowClock_SetFunc(value)
	if ( value == "1" ) then
		TimeManager_LoadUI();
		if ( TimeManagerClockButton_Show ) then
			TimeManagerClockButton_Show();
		end
	else
		if ( TimeManagerClockButton_Hide ) then
			TimeManagerClockButton_Hide();
		end
	end
end

function InterfaceOptionsDisplayPanelWorldPVPObjectiveDisplay_OnLoad (self)
	UIDropDownMenu_Initialize(InterfaceOptionsDisplayPanelWorldPVPObjectiveDisplay, InterfaceOptionsDisplayPanelWorldPVPObjectiveDisplay_Initialize);
	UIDropDownMenu_SetWidth(self, 90);
	local value = GetCVar("displayWorldPVPObjectives");
	self.defaultValue = "1";
	self.value = value;
	self.currValue = value;
	UIDropDownMenu_SetSelectedValue(InterfaceOptionsDisplayPanelWorldPVPObjectiveDisplay, value);
	WORLD_PVP_OBJECTIVES_DISPLAY = value;
	InterfaceOptionsDisplayPanelWorldPVPObjectiveDisplay.tooltip = getglobal("OPTION_TOOLTIP_WORLD_PVP_DISPLAY"..value);
	self.SetValue = 
		function (self, value)
			UIDropDownMenu_SetSelectedValue(self, value);
			SetCVar("displayWorldPVPObjectives", value, self.event);
			self.value = value;
			InterfaceOptionsDisplayPanelWorldPVPObjectiveDisplay.tooltip = getglobal("OPTION_TOOLTIP_WORLD_PVP_DISPLAY"..tostring(value));
			WORLD_PVP_OBJECTIVES_DISPLAY = value;
			WorldStateAlwaysUpFrame_Update();
		end
	self.GetValue =
		function (self)
			return UIDropDownMenu_GetSelectedValue(self);
		end
	BlizzardOptionsPanel_RegisterControl(self, InterfaceOptionsDisplayPanel);
end

function InterfaceOptionsDisplayPanelWorldPVPObjectiveDisplay_OnClick(self)
	InterfaceOptionsDisplayPanelWorldPVPObjectiveDisplay:SetValue(self.value);
end

function InterfaceOptionsDisplayPanelWorldPVPObjectiveDisplay_Initialize()
	local selectedValue = UIDropDownMenu_GetSelectedValue(InterfaceOptionsDisplayPanelWorldPVPObjectiveDisplay);
	local info = UIDropDownMenu_CreateInfo();

	info.text = ALWAYS;
	info.func = InterfaceOptionsDisplayPanelWorldPVPObjectiveDisplay_OnClick;
	info.value = "1";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = ALWAYS;
	info.tooltipText = OPTION_TOOLTIP_WORLD_PVP_DISPLAY_ALWAYS;
	UIDropDownMenu_AddButton(info);

	info.text = DYNAMIC;
	info.func = InterfaceOptionsDisplayPanelWorldPVPObjectiveDisplay_OnClick;
	info.value = "2";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = DYNAMIC;
	info.tooltipText = OPTION_TOOLTIP_WORLD_PVP_DISPLAY_DYNAMIC;
	UIDropDownMenu_AddButton(info);

	info.text = NEVER;
	info.func = InterfaceOptionsDisplayPanelWorldPVPObjectiveDisplay_OnClick;
	info.value = "3";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = NEVER;
	info.tooltipText = OPTION_TOOLTIP_WORLD_PVP_DISPLAY_NEVER;
	UIDropDownMenu_AddButton(info);
end

-- [[ Quest Options Panel ]] --

QuestPanelOptions = {
	questFadingDisable = { text = "SHOW_QUEST_FADING_TEXT" },
	autoQuestWatch = { text = "AUTO_QUEST_WATCH_TEXT" },
}

-- [[ Social Options Panel ]] --

SocialPanelOptions = {
	profanityFilter = { text = "PROFANITY_FILTER" },
	chatBubbles = { text="CHAT_BUBBLES_TEXT" },
	chatBubblesParty = { text="PARTY_CHAT_BUBBLES_TEXT" },
	spamFilter = { text="DISABLE_SPAM_FILTER" },
	removeChatDelay = { text="REMOVE_CHAT_DELAY_TEXT" },
	guildMemberNotify = { text="GUILDMEMBER_ALERT" },
	guildRecruitmentChannel = { text="AUTO_JOIN_GUILD_CHANNEL" },
	showChatIcons = { text="SHOW_CHAT_ICONS" },
	useSimpleChat = { text="SIMPLE_CHAT_TEXT" },
	chatLocked = { text="CHAT_LOCKED_TEXT" },	
}

function InterfaceOptionsSocialPanel_OnLoad (panel)
	panel.okay = function (self)
		for _, control in next, self.controls do
			securecall(BlizzardOptionsPanel_UpdateCurrentControlValue, control);
		end
		
		if ( InterfaceOptionsSocialPanelSimpleChat:GetChecked() ) then
			SIMPLE_CHAT = "1";
			FCF_Set_SimpleChat();
		else
			SIMPLE_CHAT = "0";
			FCF_Set_NormalChat();
		end
	end
	panel:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function InterfaceOptionsSocialPanel_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		SIMPLE_CHAT = (GetCVar("useSimpleChat") == "1" and "1") or "0";
		-- bug 110191: The combat log overlaps the chat log after relogging with Simple Chat toggled.
		-- to fix this, force the floating chat frames to simple chat mode so that the combat log is
		-- correctly positioned and sized
		if ( SIMPLE_CHAT == "1" ) then
			FCF_Set_SimpleChat();
		end

		BlizzardOptionsPanel_OnEvent(self, event, ...);
		self:UnregisterEvent(event);
	end
end

-- [[ ActionBars Options Panel ]] --

ActionBarsPanelOptions = {
	bottomLeftActionBar = { text = "SHOW_MULTIBAR1_TEXT", default = "0" },
	bottomRightActionBar = { text = "SHOW_MULTIBAR2_TEXT", default = "0" },
	rightActionBar = { text = "SHOW_MULTIBAR3_TEXT", default = "0" },
	rightTwoActionBar = { text = "SHOW_MULTIBAR4_TEXT", default = "0" },
	lockActionBars = { text = "LOCK_ACTIONBAR_TEXT" },
	alwaysShowActionBars = { text = "ALWAYS_SHOW_MULTIBARS_TEXT" },
	secureAbilityToggle = { text = "SECURE_ABILITY_TOGGLE" },
}

function InterfaceOptionsActionBarsPanel_OnLoad (panel)
	panel:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function InterfaceOptionsActionBarsPanel_OnEvent (self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		SHOW_MULTI_ACTIONBAR_1, SHOW_MULTI_ACTIONBAR_2, SHOW_MULTI_ACTIONBAR_3, SHOW_MULTI_ACTIONBAR_4 = GetActionBarToggles();
		ALWAYS_SHOW_MULTIBARS = (GetCVar("alwaysShowActionBars") == "1" and "1") or "0";
		MultiActionBar_Update();
		UIParent_ManageFramePositions();

		BlizzardOptionsPanel_OnEvent(self, event, ...);
		self:UnregisterEvent(event);
	end
end

function InterfaceOptions_UpdateMultiActionBars ()
	--Clean up "0" values so they evaluate as false.
	if ( InterfaceOptionsActionBarsPanel:IsEventRegistered("PLAYER_ENTERING_WORLD") ) then
		return;
	end
		
	if ( SHOW_MULTI_ACTIONBAR_1 == "0" ) then
		SHOW_MULTI_ACTIONBAR_1 = nil;
	end
	
	if ( SHOW_MULTI_ACTIONBAR_2 == "0" ) then
		SHOW_MULTI_ACTIONBAR_2 = nil;
	end
	
	if ( SHOW_MULTI_ACTIONBAR_3 == "0" ) then
		SHOW_MULTI_ACTIONBAR_3 = nil;
	end
	
	if ( SHOW_MULTI_ACTIONBAR_4 == "0" ) then
		SHOW_MULTI_ACTIONBAR_4 = nil;
	end
	
	if ( ALWAYS_SHOW_MULTIBARS == "0" ) then
		ALWAYS_SHOW_MULTIBARS = nil;
	end
	
	if ( LOCK_ACTIONBAR == "0" ) then
		LOCK_ACTIONBAR = nil;
	end
	
	SetActionBarToggles(SHOW_MULTI_ACTIONBAR_1, SHOW_MULTI_ACTIONBAR_2, SHOW_MULTI_ACTIONBAR_3, SHOW_MULTI_ACTIONBAR_4, ALWAYS_SHOW_MULTIBARS);
	MultiActionBar_Update();
	UIParent_ManageFramePositions();
end

-- [[ Names Options Panel ]] --

NamePanelOptions = {
	UnitNameOwn = { text = "UNIT_NAME_OWN" },
	UnitNameNPC = { text = "UNIT_NAME_NPC" },
	UnitNamePlayerGuild = { text = "UNIT_NAME_GUILD" },
	UnitNamePlayerPVPTitle = { text = "UNIT_NAME_PLAYER_TITLE" },
	UnitNameEnemyPlayerName = { text = "UNIT_NAME_ENEMY" },
	UnitNameEnemyPetName = { text = "UNIT_NAME_ENEMY_PETS" },
	UnitNameEnemyCreationName = { text = "UNIT_NAME_ENEMY_CREATIONS" },
	UnitNameFriendlyPlayerName = { text = "UNIT_NAME_FRIENDLY" },
	UnitNameFriendlyPetName = { text = "UNIT_NAME_FRIENDLY_PETS" },
	UnitNameFriendlyCreationName = { text = "UNIT_NAME_FRIENDLY_CREATIONS" },
	UnitNameCompanionName = { text = "UNIT_NAME_COMPANIONS" },
}

-- [[ Combat Text Options Panel ]] --

FCTPanelOptions = {
	enableCombatText = { text = "SHOW_COMBAT_TEXT_TEXT" },
	fctCombatState = { text = "COMBAT_TEXT_SHOW_COMBAT_STATE_TEXT" },
	fctDodgeParryMiss = { text = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS_TEXT" },
	fctDamageReduction = { text = "COMBAT_TEXT_SHOW_RESISTANCES_TEXT" },
	fctRepChanges = { text = "COMBAT_TEXT_SHOW_REPUTATION_TEXT" },
	fctReactives = { text = "COMBAT_TEXT_SHOW_REACTIVES_TEXT" },
	fctFriendlyHealers = { text = "COMBAT_TEXT_SHOW_FRIENDLY_NAMES_TEXT" },
	fctComboPoints = { text = "COMBAT_TEXT_SHOW_COMBO_POINTS_TEXT" },
	fctLowManaHealth = { text = "COMBAT_TEXT_SHOW_LOW_HEALTH_MANA_TEXT" },
	fctEnergyGains = { text = "COMBAT_TEXT_SHOW_ENERGIZE_TEXT" },
	fctPeriodicEnergyGains = { text = "COMBAT_TEXT_SHOW_PERIODIC_ENERGIZE_TEXT" },
	fctHonorGains = { text = "COMBAT_TEXT_SHOW_HONOR_GAINED_TEXT" },
	fctAuras = { text = "COMBAT_TEXT_SHOW_AURAS_TEXT" },
	CombatDamage = { text = "SHOW_DAMAGE_TEXT" },
	CombatLogPeriodicSpells = { text = "LOG_PERIODIC_EFFECTS" },
	PetMeleeDamage = { text = "SHOW_PET_MELEE_DAMAGE" },
	CombatHealing = { text = "SHOW_COMBAT_HEALING" },
}

function BlizzardOptionsPanel_UpdateCombatText ()
	-- Fix for bug 106938. CombatText_UpdateDisplayedMessages only exists if the Blizzard_CombatText AddOn is loaded.
	-- We need CombatText options to have their setFunc actually _exist_, so this function is used instead of CombatText_UpdateDisplayedMessages.
	if ( CombatText_UpdateDisplayedMessages ) then
		CombatText_UpdateDisplayedMessages();
	end
end

function InterfaceOptionsCombatTextPanelFCTDropDown_OnLoad (self)
	UIDropDownMenu_Initialize(self, InterfaceOptionsCombatTextPanelFCTDropDown_Initialize);
	self.defaultValue = "1";
	local value = GetCVar("combatTextFloatMode");
	self.value = value;
	COMBAT_TEXT_FLOAT_MODE = value;
	
	if ( CombatText_UpdateDisplayedMessages ) then
		-- If the CombatText AddOn has already been loaded, we need to reinit it to pick up the previous COMBAT_TEXT_FLOAT_MODE.
		CombatText_UpdateDisplayedMessages();
	end
	self.currValue = value;
	UIDropDownMenu_SetSelectedValue(self, value);
	InterfaceOptionsCombatTextPanelFCTDropDown.tooltip = OPTION_TOOLTIP_COMBAT_TEXT_MODE;
	UIDropDownMenu_SetWidth(self, 110);
	self.SetValue = 
		function (self, value) 
			self.value = value;
			UIDropDownMenu_SetSelectedValue(self, value);
			SetCVar("combatTextFloatMode", value, self.event);
			COMBAT_TEXT_FLOAT_MODE = value;
			
			if ( CombatText_UpdateDisplayedMessages ) then
				CombatText_UpdateDisplayedMessages();
			else
				UIParentLoadAddOn("Blizzard_CombatText");
				CombatText_UpdateDisplayedMessages();
			end
		end;	
	self.GetValue =
		function (self)
			return UIDropDownMenu_GetSelectedValue(self);
		end
end

function InterfaceOptionsCombatTextPanelFCTDropDown_OnClick(self)
	InterfaceOptionsCombatTextPanelFCTDropDown:SetValue(self.value);
end

function InterfaceOptionsCombatTextPanelFCTDropDown_Initialize(self)
	local selectedValue = UIDropDownMenu_GetSelectedValue(self);
	local info = UIDropDownMenu_CreateInfo();

	info.text = COMBAT_TEXT_SCROLL_UP;
	info.func = InterfaceOptionsCombatTextPanelFCTDropDown_OnClick;
	info.value = "1"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = COMBAT_TEXT_SCROLL_UP;
	info.tooltipText = OPTION_TOOLTIP_SCROLL_UP;
	UIDropDownMenu_AddButton(info);

	info.text = COMBAT_TEXT_SCROLL_DOWN;
	info.func = InterfaceOptionsCombatTextPanelFCTDropDown_OnClick;
	info.value = "2"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = COMBAT_TEXT_SCROLL_DOWN;
	info.tooltipText = OPTION_TOOLTIP_SCROLL_DOWN;
	UIDropDownMenu_AddButton(info);

	info.text = COMBAT_TEXT_SCROLL_ARC;
	info.func = InterfaceOptionsCombatTextPanelFCTDropDown_OnClick;
	info.value = "3"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = COMBAT_TEXT_SCROLL_ARC;
	info.tooltipText = OPTION_TOOLTIP_SCROLL_ARC;
	UIDropDownMenu_AddButton(info);
end

-- [[ Status Text Options Panel ]] --

StatusTextPanelOptions = {
	xpBarText = { text = "XP_BAR_TEXT" },
	playerStatusText = { text = "STATUS_TEXT_PLAYER" },
	petStatusText = { text = "STATUS_TEXT_PET" },
	partyStatusText = { text = "STATUS_TEXT_PARTY" },
	targetStatusText = { text = "STATUS_TEXT_TARGET" },
	statusTextPercentage = { text = "STATUS_TEXT_PERCENT" },
}

-- [[ Party & Raid Options Panel ]] --

PartyRaidPanelOptions = {
	showPartyBackground = { text = "SHOW_PARTY_BACKGROUND_TEXT" },
	hidePartyInRaid = { text = "HIDE_PARTY_INTERFACE_TEXT" },
	showPartyPets = { text = "SHOW_PARTY_PETS_TEXT" },
	showDispelDebuffs = { text = "SHOW_DISPELLABLE_DEBUFFS_TEXT" },
	showCastableBuffs = { text = "SHOW_CASTABLE_BUFFS_TEXT" },
	showRaidRange = { text = "SHOW_RAID_RANGE_TEXT" },
}

function BlizzardOptionsPanel_UpdateRaidPullouts ()
	if ( type(NUM_RAID_PULLOUT_FRAMES) ~= "number" ) then
		return;
	end

	local frame;
	for i = 1, NUM_RAID_PULLOUT_FRAMES do
		frame = getglobal("RaidPullout" .. i);
		if ( frame and frame:IsShown() ) then
			RaidPullout_Update(frame);
		end
	end
end

-- [[ Camera Options Panel ]] --

CameraPanelOptions = {
	cameraTerrainTilt = { text = "FOLLOW_TERRAIN" },
	cameraBobbing = { text = "HEAD_BOB" },
	cameraWaterCollision = { text = "WATER_COLLISION" },
	cameraPivot = { text = "SMART_PIVOT" },
	cameraYawSmoothSpeed = { text = "AUTO_FOLLOW_SPEED", minValue = 90, maxValue = 270, valueStep = 10 },
	cameraDistanceMaxFactor = { text = "MAX_FOLLOW_DIST", minValue = 1, maxValue = 2, valueStep = 0.1 },
}

function InterfaceOptionsCameraPanelStyleDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, InterfaceOptionsCameraPanelStyleDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(self, GetCVar("cameraSmoothStyle"));
	InterfaceOptionsCameraPanelStyleDropDown.tooltip = getglobal("OPTION_TOOLTIP_CAMERA"..UIDropDownMenu_GetSelectedID(InterfaceOptionsCameraPanelStyleDropDown));
	UIDropDownMenu_SetWidth(self, 144);
	self.defaultValue = "1";
	self.value = GetCVar("cameraSmoothStyle");
	self.currValue = self.value;
	
	if ( tostring(self.value) == "0" ) then
		OptionsFrame_DisableSlider(InterfaceOptionsCameraPanelFollowSpeedSlider);
		InterfaceOptionsCameraPanelFollowTerrain:Disable();
	end
	
	self.SetValue = 
		function (self, value)
			UIDropDownMenu_SetSelectedValue(self, value);
			SetCVar("cameraSmoothStyle", value, self.event);
			self.value = value;
			if ( tostring(value) == "0" ) then
				--For the purposes of tooltips and the dropdown list, value "0" in the CVar cameraSmoothStyle is actually "3".
				InterfaceOptionsCameraPanelStyleDropDown.tooltip = OPTION_TOOLTIP_CAMERA3;
				OptionsFrame_DisableSlider(InterfaceOptionsCameraPanelFollowSpeedSlider);
				InterfaceOptionsCameraPanelFollowTerrain:Disable();
			else
				InterfaceOptionsCameraPanelStyleDropDown.tooltip = getglobal("OPTION_TOOLTIP_CAMERA" .. tostring(value));
				OptionsFrame_EnableSlider(InterfaceOptionsCameraPanelFollowSpeedSlider);
				InterfaceOptionsCameraPanelFollowTerrain:Enable();
			end	
		end
	self.GetValue =
		function (self)
			return UIDropDownMenu_GetSelectedValue(self);
		end
end

function InterfaceOptionsCameraPanelStyleDropDown_OnClick(self)
	InterfaceOptionsCameraPanelStyleDropDown:SetValue(self.value);
end

function InterfaceOptionsCameraPanelStyleDropDown_Initialize(self)
	local selectedValue = UIDropDownMenu_GetSelectedValue(self);
	local info = UIDropDownMenu_CreateInfo();

	info.text = CAMERA_SMART;
	info.func = InterfaceOptionsCameraPanelStyleDropDown_OnClick;
	info.value = "1"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = CAMERA_SMART;
	info.tooltipText = OPTION_TOOLTIP_CAMERA_SMART;
	UIDropDownMenu_AddButton(info);

	info.text = CAMERA_ALWAYS;
	info.func = InterfaceOptionsCameraPanelStyleDropDown_OnClick;
	info.value = "2"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = CAMERA_ALWAYS;
	info.tooltipText = OPTION_TOOLTIP_CAMERA_ALWAYS;
	UIDropDownMenu_AddButton(info);

	info.text = CAMERA_NEVER;
	info.func = InterfaceOptionsCameraPanelStyleDropDown_OnClick;
	info.value = "0"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = CAMERA_NEVER;
	info.tooltipText = OPTION_TOOLTIP_CAMERA_NEVER;
	UIDropDownMenu_AddButton(info);
end

-- [[ Mouse Options Panel ]] --

MousePanelOptions = {
	mouseInvertPitch = { text = "INVERT_MOUSE" },
	autointeract = { text = "CLICK_TO_MOVE" },
	mouseSpeed = { text = "MOUSE_SENSITIVITY", minValue = 0.5, maxValue = 1.5, valueStep = 0.05 },
	cameraYawMoveSpeed = { text = "MOUSE_LOOK_SPEED", minValue = 90, maxValue = 270, valueStep = 10 },
}

function InterfaceOptionsMousePanelClickMoveStyleDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, InterfaceOptionsMousePanelClickMoveStyleDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(self, GetCVar("cameraSmoothTrackingStyle"));
	self.tooltip = getglobal("OPTION_TOOLTIP_CLICK_CAMERA"..UIDropDownMenu_GetSelectedID(self));
	UIDropDownMenu_SetWidth(self, 140);
	self.defaultValue = "1";
	self.value = GetCVar("cameraSmoothTrackingStyle");
	self.currValue = self.value;
	self.SetValue = 
		function (self, value)
			UIDropDownMenu_SetSelectedValue(self, value);
			SetCVar("cameraSmoothTrackingStyle", value, self.event);
			self.value = value;
			if ( tostring(value) == "0" ) then
				--For the purposes of tooltips and dropdown lists, "0" in the CVar cameraSmoothTrackingStyle is "3".
				self.tooltip = OPTION_TOOLTIP_CLICK_CAMERA3;
			else
				self.tooltip = getglobal("OPTION_TOOLTIP_CLICK_CAMERA" .. tostring(value));
			end
		end
	self.GetValue =
		function (self)
			return UIDropDownMenu_GetSelectedValue(self);
		end
end

function InterfaceOptionsMousePanelClickMoveStyleDropDown_OnClick(self)
	InterfaceOptionsMousePanelClickMoveStyleDropDown:SetValue(self.value);
end

function InterfaceOptionsMousePanelClickMoveStyleDropDown_Initialize(self)
	local selectedValue = UIDropDownMenu_GetSelectedValue(self);
	local info = UIDropDownMenu_CreateInfo();

	info.text = CAMERA_SMART;
	info.func = InterfaceOptionsMousePanelClickMoveStyleDropDown_OnClick;
	info.value = "1"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = CAMERA_SMART;
	info.tooltipText = OPTION_TOOLTIP_CLICKCAMERA_SMART;
	UIDropDownMenu_AddButton(info);

	info.text = CAMERA_LOCKED;
	info.func = InterfaceOptionsMousePanelClickMoveStyleDropDown_OnClick;
	info.value = "2"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = CAMERA_LOCKED;
	info.tooltipText = OPTION_TOOLTIP_CLICKCAMERA_LOCKED;
	UIDropDownMenu_AddButton(info);

	info.text = CAMERA_NEVER;
	info.func = InterfaceOptionsMousePanelClickMoveStyleDropDown_OnClick;
	info.value = "0"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = CAMERA_NEVER;
	info.tooltipText = OPTION_TOOLTIP_CLICKCAMERA_NEVER;
	UIDropDownMenu_AddButton(info);
end

-- [[ Help Options Panel ]] --

HelpPanelOptions = {
	showTutorials = { text = "SHOW_TUTORIALS" },
	showGameTips = { text = "SHOW_TIPOFTHEDAY_TEXT" },
	UberTooltips = { text = "USE_UBERTOOLTIPS" },
	showNewbieTips = { text = "SHOW_NEWBIE_TIPS_TEXT" },
	scriptErrors = { text = "SHOW_LUA_ERRORS" },
}

function InterfaceOptionsHelpPanel_OnLoad (panel)
	panel.okay = function (self)
		for _, control in next, self.controls do
			securecall(BlizzardOptionsPanel_UpdateCurrentControlValue, control);
		end
		if ( InterfaceOptionsHelpPanelTutorials:GetChecked() and not TutorialsEnabled() ) then
			ResetTutorials();
		elseif ( ( not InterfaceOptionsHelpPanelTutorials:GetChecked() ) and TutorialsEnabled() ) then
			ClearTutorials();
			TutorialFrame_HideAllAlerts();
		end
	end
end

-- [[ Languages Options Panel ]] --

function InterfaceOptionsLanguagesPanel_OnLoad (panel)
	-- Check and see if we have more than one locale. If we don't, then don't register this panel.
	if ( #({GetExistingLocales()}) <= 1 ) then				
		return;
	end
	
	BlizzardOptionsPanel_OnLoad(panel);
end

function InterfaceOptionsLanguagesPanelLocaleDropDown_OnLoad (self)
	UIDropDownMenu_Initialize(self, InterfaceOptionsLanguagesPanelLocaleDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(self, GetCVar("locale"));
	InterfaceOptionsLanguagesPanelLocaleDropDown.tooltip = OPTION_TOOLTIP_LOCALE;
	UIDropDownMenu_SetWidth(self, 120);
	
	self.defaultValue = GetCVar("locale");
	self.value = GetCVar("locale");
	self.origValue = self.value;
	self.currValue = self.value;
	self.SetValue = 
		function (self, value)
			UIDropDownMenu_SetSelectedValue(self, value);
			SetCVar("locale", value, self.event);
			self.value = value;
			if ( self.origValue ~= value ) then
				StaticPopup_Show("CLIENT_RESTART_ALERT");
			end
		end
	self.GetValue =
		function (self)
			return UIDropDownMenu_GetSelectedValue(self);
		end
end

function InterfaceOptionsLanguagesPanelLocaleDropDown_OnClick (self)
	InterfaceOptionsLanguagesPanelLocaleDropDown:SetValue(self.value);
end

function InterfaceOptionsLanguagesPanelLocaleDropDown_Initialize (self)
	local selectedValue = UIDropDownMenu_GetSelectedValue(self);
	local info = UIDropDownMenu_CreateInfo();

	InterfaceOptionsLanguagesPanelLocaleDropDown_InitializeHelper(info, selectedValue, GetExistingLocales());
end

function InterfaceOptionsLanguagesPanelLocaleDropDown_InitializeHelper (createInfo, selectedValue, ...)
	for i = 1, select("#", ...) do
		local value = select(i, ...);
		if (value) then
			createInfo.text = getglobal(strupper(value));
			createInfo.func = InterfaceOptionsLanguagesPanelLocaleDropDown_OnClick;
			createInfo.value = value;
			if ( createInfo.value == selectedValue ) then
				createInfo.checked = 1;
			else
				createInfo.checked = nil;
			end
			UIDropDownMenu_AddButton(createInfo);
		end
	end
end
-- [[ General functions ]] --

local ALT_KEY = "altkey";
local CONTROL_KEY = "controlkey";
local SHIFT_KEY = "shiftkey";
local NO_KEY = "none";

function BlizzardOptionsPanel_SetupControl (control)
	local value
	if ( control.cvar ) then
		if ( control.type == CONTROLTYPE_CHECKBOX ) then			
			value = GetCVar(control.cvar);
			control.currValue = value;
			control.value = value;
			if ( control.uvar ) then
				setglobal(control.uvar, value);
			end
			
			control.GetValue = function(self) return GetCVar(self.cvar); end
			control.SetValue = function(self, value) self.value = value; SetCVar(self.cvar, value, self.event); if ( self.uvar ) then setglobal(self.uvar, value) end if ( self.setFunc ) then self.setFunc(value) end end
		elseif ( control.type == CONTROLTYPE_SLIDER ) then
			control.currValue = GetCVar(control.cvar);
			control:SetValue(control.currValue);
		end
	end
	if ( control.setFunc ) then
		control.setFunc(control.value);
	end
end

function BlizzardOptionsPanel_OnEvent (self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		for i, control in next, self.controls do
			securecall(BlizzardOptionsPanel_SetupControl, control);
		end
		self:UnregisterEvent(event);
	end
end

function BlizzardOptionsPanel_OnLoad (frame)
	InterfaceOptionsFrame_SetupBlizzardPanel(frame);
	InterfaceOptions_AddCategory(frame);
	frame:RegisterEvent("PLAYER_ENTERING_WORLD");
	if ( not frame:GetScript("OnEvent") ) then
		frame:SetScript("OnEvent", BlizzardOptionsPanel_OnEvent);
	end
	
	if ( frame.options and frame.controls ) then
		local entry;
		for i, control in next, frame.controls do
			entry = frame.options[(control.cvar or control.label)];
			if ( entry ) then
				if ( entry.text ) then
					control.tooltipText = (getglobal("OPTION_TOOLTIP_" .. gsub(entry.text, "_TEXT$", "")) or entry.tooltip);
					getglobal(control:GetName() .. "Text"):SetText(getglobal(entry.text) or entry.text);
				end
				
				if ( control.cvar ) then
					control.defaultValue = GetCVarDefault(control.cvar);
				else
				control.defaultValue = control.defaultValue or entry.default;
				end
				
				control.event = entry.event or entry.text;
				
				if ( control.type == CONTROLTYPE_SLIDER ) then
					OptionsFrame_EnableSlider(control);
					control:SetMinMaxValues(entry.minValue, entry.maxValue);
					control:SetValueStep(entry.valueStep);
				end
			end
		end
	end
end

function BlizzardOptionsPanel_OnShow (panel)
	-- This function needs to be reworked.

	local value;
	
	for _, control in next, panel.controls do
		if ( control.cvar ) then
			if ( control.type == CONTROLTYPE_CHECKBOX ) then
				value = GetCVar(control.cvar);
				
				if ( not control.invert ) then
					if ( value == "1" ) then
						control:SetChecked(true);
					else
						control:SetChecked(false);
					end
				else
					if ( value == "0" ) then
						control:SetChecked(true);
					else
						control:SetChecked(false);
					end
				end
				
				if ( control.dependentControls ) then
					if ( control:GetChecked() ) then
						for _, depControl in next, control.dependentControls do
							depControl:Enable();
						end
					else
						for _, depControl in next, control.dependentControls do
							depControl:Disable();
						end
					end
				end
			elseif ( control.type == CONTROLTYPE_SLIDER ) then
				-- Don't do anything.
			end
		elseif ( control.GetValue ) then
			if ( control.type == CONTROLTYPE_CHECKBOX ) then
				value = tostring(control:GetValue());
				
				if ( not control.invert ) then
					if ( value == "1" ) then
						control:SetChecked(true);
					else
						control:SetChecked(false);
					end
				else
					if ( value == "0" ) then
						control:SetChecked(true);
					else
						control:SetChecked(false);
					end
				end
				
				if ( control.dependentControls ) then
					if ( control:GetChecked() ) then
						for _, depControl in next, control.dependentControls do
							depControl:Enable();
						end
					else
						for _, depControl in next, control.dependentControls do
							depControl:Disable();
						end
					end
				end
			end
		end
	end
end

function BlizzardOptionsPanel_RegisterControl (control, parentFrame)
	if ( ( not parentFrame ) or ( not control ) ) then
		return;
	end
	
	parentFrame.controls = parentFrame.controls or {};
	
	tinsert(parentFrame.controls, control);
	
	local value;
	if ( control.cvar ) then
		-- Don't do anything here any more, just wait.
	elseif ( control.GetValue ) then
		if ( control.type == CONTROLTYPE_CHECKBOX ) then
			value = ((control:GetValue() and "1") or "0");
			control.currValue = value;
			control.value = value;
			if ( control.uvar ) then
				setglobal(control.uvar, value);
			end
			
			control.SetValue = function(self, value) self.value = value; if ( self.uvar ) then setglobal(self.uvar, value); end if ( self.setFunc ) then self.setFunc(value) end end;
		end
	end
end

function BlizzardOptionsPanel_SetupDependentControl (dependency, control)
	if ( not dependency ) then
		return;
	end
	
	assert(control);
	
	dependency.dependentControls = dependency.dependentControls or {};
	tinsert(dependency.dependentControls, control);
	
	if ( control.type ~= CONTROLTYPE_DROPDOWN ) then
		control.Disable = function (self) getmetatable(self).__index.Disable(self) getglobal(self:GetName().."Text"):SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b) end;
		control.Enable = function (self) getmetatable(self).__index.Enable(self) getglobal(self:GetName().."Text"):SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b) end;
	else
		control.Disable = function (self) UIDropDownMenu_DisableDropDown(self) end;
		control.Enable = function (self) UIDropDownMenu_EnableDropDown(self) end;
	end
end

function BlizzardOptionsPanel_CheckButton_OnClick (checkButton)
	local setting = "0";
	if ( checkButton:GetChecked() ) then
		if ( not checkButton.invert ) then
			setting = "1"
		end
	elseif ( checkButton.invert ) then
		setting = "1"
	end 
	
	checkButton.value = setting;
	
	if ( checkButton.cvar ) then
		SetCVar(checkButton.cvar, setting, checkButton.event);
	end

	if ( checkButton.uvar ) then
		setglobal(checkButton.uvar, setting);
	end

	if ( checkButton.dependentControls ) then
		if ( checkButton:GetChecked() ) then
			for _, control in next, checkButton.dependentControls do
				control:Enable();
			end
		else
			for _, control in next, checkButton.dependentControls do
				control:Disable();
			end
		end
	end
	
	if ( checkButton.setFunc ) then	
		checkButton.setFunc(checkButton.value);
	end
end
