CONTROLTYPE_CHECKBOX = 1;
CONTROLTYPE_DROPDOWN = 2;
CONTROLTYPE_SLIDER = 3;

-- [[ Controls Options Panel ]] --

ControlsPanelOptions = {
	deselectOnClick = { text = "GAMEFIELD_DESELECT_TEXT", default="1" },
	autoDismountFlying = { text = "AUTO_DISMOUNT_FLYING_TEXT", default="0" },
	autoClearAFK = { text = "CLEAR_AFK", default="1" },
	lootUnderMouse = { text = "LOOT_UNDER_MOUSE_TEXT", default="0" },
	autoLootCorpse = { text = "AUTO_LOOT_DEFAULT_TEXT", default="0" }, -- When this gets changed, the function SetAutoLootDefault needs to get run with its value.
	autoLootKey = { text="AUTO_LOOT_KEY_TEXT", default="0" },
}

function InterfaceOptionsControlsPanelAutoLootKeyDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, InterfaceOptionsControlsPanelAutoLootKeyDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(this, GetModifiedClick("AUTOLOOTTOGGLE"));
	this.defaultValue = "NONE";
	this.currValue = GetModifiedClick("AUTOLOOTTOGGLE");
	this.value = this.currValue;
	InterfaceOptionsControlsPanelAutoLootKeyDropDown.tooltip = getglobal("OPTION_TOOLTIP_AUTO_LOOT_"..UIDropDownMenu_GetSelectedValue(InterfaceOptionsControlsPanelAutoLootKeyDropDown).."_KEY");
	UIDropDownMenu_SetWidth(90, InterfaceOptionsControlsPanelAutoLootKeyDropDown);
	this.SetValue = 
		function (self, value) 
			UIDropDownMenu_SetSelectedValue(self, value);
			SetModifiedClick("AUTOLOOTTOGGLE", value);
			InterfaceOptionsControlsPanelAutoLootKeyDropDown.tooltip = getglobal("OPTION_TOOLTIP_AUTO_LOOT_"..UIDropDownMenu_GetSelectedValue(InterfaceOptionsControlsPanelAutoLootKeyDropDown).."_KEY");	
		end;
	this.GetValue =
		function (self)
			return UIDropDownMenu_GetSelectedValue(self);
		end
	if ( GetCVar("autoLootCorpse") == "1" ) then
		InterfaceOptionsControlsPanelAutoLootKeyDropDownLabel:SetText(LOOT_KEY_TEXT);
	else
		InterfaceOptionsControlsPanelAutoLootKeyDropDownLabel:SetText(AUTO_LOOT_KEY_TEXT);
	end
end

function InterfaceOptionsControlsPanelAutoLootKeyDropDown_OnClick()
	UIDropDownMenu_SetSelectedValue(InterfaceOptionsControlsPanelAutoLootKeyDropDown, this.value);
	SetModifiedClick("AUTOLOOTTOGGLE", this.value);
	InterfaceOptionsControlsPanelAutoLootKeyDropDown.tooltip = getglobal("OPTION_TOOLTIP_AUTO_LOOT_"..UIDropDownMenu_GetSelectedValue(InterfaceOptionsControlsPanelAutoLootKeyDropDown).."_KEY");
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
	assistAttack = { text = "ASSIST_ATTACK", default = "1" },
	autoRangedCombat = { text = "AUTO_RANGED_COMBAT_TEXT", default = "1" },
	autoSelfCast = { text = "AUTO_SELF_CAST_TEXT", default = "0" },
	stopAutoAttackOnTargetChange = { text = "STOP_AUTO_ATTACK", default = "0" },
	showTargetOfTarget = { text = "SHOW_TARGET_OF_TARGET_TEXT", default = "0" },
	ShowTargetCastbar = { text = "SHOW_TARGET_CASTBAR", default = "0" },
	ShowVKeyCastbar = { text = "SHOW_TARGET_CASTBAR_IN_V_KEY", default = "0" },
}

function InterfaceOptionsCombatPanelTOTDropDown_OnLoad()
	this.defaultValue = "5";
	this.value = GetCVar("targetOfTargetMode");
	this.currValue = this.value;
	setglobal(this.uvar, this.value);
	UIDropDownMenu_Initialize(this, InterfaceOptionsCombatPanelTOTDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(this, this.value);
	InterfaceOptionsCombatPanelTOTDropDown.tooltip = getglobal("OPTION_TOOLTIP_TARGETOFTARGET" .. this.value);
	UIDropDownMenu_SetWidth(110, InterfaceOptionsCombatPanelTOTDropDown);	
	this.SetValue = function (self, value)
		self.value = value;
		SetCVar("targetOfTargetMode", value);
		setglobal(self.uvar, value);
		UIDropDownMenu_SetSelectedValue(self, value);
		self.tooltip = getglobal("OPTION_TOOLTIP_TARGETOFTARGET" .. value);
	end
	this.GetValue = function (self)
		return UIDropDownMenu_GetSelectedValue(self);
	end
end

function InterfaceOptionsCombatPanelTOTDropDown_OnClick()
	InterfaceOptionsCombatPanelTOTDropDown:SetValue(this.value);
end

function InterfaceOptionsCombatPanelTOTDropDown_Initialize()
	local selectedValue = UIDropDownMenu_GetSelectedValue(InterfaceOptionsCombatPanelTOTDropDown);
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
	info.tooltipTitle = PARTY;
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

-- [[ Display Options Panel ]] --

DisplayPanelOptions = {
	showCloak = { text = "SHOW_CLOAK", default = "1" },
	showHelm = { text = "SHOW_HELM", default = "1" },
	buffDurations = { text = "SHOW_BUFF_DURATION_TEXT", default = "0" },
	rotateMinimap = { text = "ROTATE_MINIMAP", default = "0" },
	scriptErrors = { text = "SHOW_LUA_ERRORS", default = "0" },
	screenEdgeFlash = { text = "SHOW_FULLSCREEN_STATUS_TEXT", default="1" },
	showLootSpam = { text = "SHOW_LOOT_SPAM", default="1" },
	displayFreeBagSlots = { text = "DISPLAY_FREE_BAG_SLOTS", default="0" },
}

-- [[ Quest Options Panel ]] --

QuestPanelOptions = {
	questFadingDisable = { text = "SHOW_QUEST_FADING_TEXT", default = "0" },
	autoQuestWatch = { text = "AUTO_QUEST_WATCH_TEXT", default = "1" },
}

-- [[ Social Options Panel ]] --

SocialPanelOptions = {
	profanityFilter = { text = "PROFANITY_FILTER", default="1" },
	ChatBubbles = { text="CHAT_BUBBLES_TEXT", default="1" },
	ChatBubblesParty = { text="PARTY_CHAT_BUBBLES_TEXT", default="1" },
	spamFilter = { text="DISABLE_SPAM_FILTER", default="1" },
	removeChatDelay = { text="REMOVE_CHAT_DELAY_TEXT", default="0" },
	guildMemberNotify = { text="GUILDMEMBER_ALERT", default="1" },
	guildRecruitmentChannel = { text="AUTO_JOIN_GUILD_CHANNEL", default="1" },
	BlockTrades = { text="BLOCK_TRADES", default="0" },
	chatLocked = { text="CHAT_LOCKED_TEXT", default="0" },	
}

-- [[ ActionBars Options Panel ]] --

ActionBarsPanelOptions = {
	bottomLeftActionBar = { text = "SHOW_MULTIBAR1_TEXT", default = "0" },
	bottomRightActionBar = { text = "SHOW_MULTIBAR2_TEXT", default = "0" },
	rightActionBar = { text = "SHOW_MULTIBAR3_TEXT", default = "0" },
	rightTwoActionBar = { text = "SHOW_MULTIBAR4_TEXT", default = "0" },
	lockActionBars = { text = "LOCK_ACTIONBAR_TEXT", default = "0" },
	alwaysShowActionBars = { text = "ALWAYS_SHOW_MULTIBARS_TEXT", default = "0" },
	secureAbilityToggle = { text = "SECURE_ABILITY_TOGGLE", default = "0" },
}

function InterfaceOptions_UpdateMultiActionBars ()
	--Clean up "0" values so they evaluate as false.

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
		LOCK_ACITONBAR = nil;
	end
	
	SetActionBarToggles(SHOW_MULTI_ACTIONBAR_1, SHOW_MULTI_ACTIONBAR_2, SHOW_MULTI_ACTIONBAR_3, SHOW_MULTI_ACTIONBAR_4, ALWAYS_SHOW_MULTIBARS);
	MultiActionBar_Update();
	MultiActionBar_UpdateGridVisibility();
	UIParent_ManageFramePositions();
end

-- [[ Names Options Panel ]] --

NamePanelOptions = {
	UnitNameOwn = { text = "UNIT_NAME_OWN", default="1" },
	UnitNameNPC = { text = "UNIT_NAME_NPC", default="1" },
	UnitNamePlayerGuild = { text = "UNIT_NAME_GUILD", default="1" },
	UnitNamePlayerPVPTitle = { text = "UNIT_NAME_PLAYER_TITLE", default="1" },
	UnitNameEnemyPlayerName = { text = "UNIT_NAME_ENEMY", default="1" },
	UnitNameEnemyPetName = { text = "UNIT_NAME_ENEMY_PETS", default="1" },
	UnitNameEnemyCreationName = { text = "UNIT_NAME_ENEMY_CREATIONS", default="1" },
	UnitNameFriendlyPlayerName = { text = "UNIT_NAME_FRIENDLY", default="1" },
	UnitNameFriendlyPetName = { text = "UNIT_NAME_FRIENDLY_PETS", default="1" },
	UnitNameFriendlyCreationName = { text = "UNIT_NAME_FRIENDLY_CREATIONS", default="1" },
	UnitNameCompanionName = { text = "UNIT_NAME_COMPANIONS", default="1" },
}

-- [[ Combat Text Options Panel ]] --

FCTPanelOptions = {
	enableCombatText = { text = "SHOW_COMBAT_TEXT_TEXT", default="0" },
	fctCombatState = { text = "COMBAT_TEXT_SHOW_COMBAT_STATE_TEXT", default="1" },
	fctDodgeParryMiss = { text = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS_TEXT", default="0" },
	fctDamageReduction = { text = "COMBAT_TEXT_SHOW_RESISTANCES_TEXT", default="0" },
	fctRepChanges = { text = "COMBAT_TEXT_SHOW_REPUTATION_TEXT", default="0" },
	fctReactives = { text = "COMBAT_TEXT_SHOW_REACTIVES_TEXT", default="0" },
	fctFriendlyHealers = { text = "COMBAT_TEXT_SHOW_FRIENDLY_NAMES_TEXT", default="0" },
	fctComboPoints = { text = "COMBAT_TEXT_SHOW_COMBO_POINTS_TEXT", default="0" },
	fctLowManaHealth = { text = "COMBAT_TEXT_SHOW_LOW_HEALTH_MANA_TEXT", default="1" },
	fctEnergyGains = { text = "COMBAT_TEXT_SHOW_MANA_TEXT", default="0" },
	fctHonorGains = { text = "COMBAT_TEXT_SHOW_HONOR_GAINED_TEXT", default="1" },
	fctAuras = { text = "COMBAT_TEXT_SHOW_AURAS_TEXT", default="1" },
	CombatDamage = { text = "SHOW_DAMAGE_TEXT", default="1" },
	CombatLogPeriodicSpells = { text = "LOG_PERIODIC_EFFECTS", default="1" },
	PetMeleeDamage = { text = "SHOW_PET_MELEE_DAMAGE", default="1" },
	CombatHealing = { text = "SHOW_COMBAT_HEALING", default="1" },
}

function BlizzardOptionsPanel_UpdateCombatText ()
	-- Fix for bug 106938. CombatText_UpdateDisplayedMessages only exists if the Blizzard_CombatText AddOn is loaded.
	-- We need CombatText options to have their setFunc actually _exist_, so this function is used instead of CombatText_UpdateDisplayedMessages.
	if ( CombatText_UpdateDisplayedMessages ) then
		CombatText_UpdateDisplayedMessages();
	end
end

function InterfaceOptionsCombatTextPanelFCTDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, InterfaceOptionsCombatTextPanelFCTDropDown_Initialize);
	this.defaultValue = "1";
	this.value = GetCVar("combatTextFloatMode");
	this.currValue = this.value;
	UIDropDownMenu_SetSelectedValue(this, this.value);
	InterfaceOptionsCombatTextPanelFCTDropDown.tooltip = OPTION_TOOLTIP_COMBAT_TEXT_MODE;
	UIDropDownMenu_SetWidth(110, InterfaceOptionsCombatTextPanelFCTDropDown);
	this.SetValue = 
		function (self, value) 
			UIDropDownMenu_SetSelectedValue(self, value);
			SetCVar("combatTextFloatMode", value, self.event);
			this.value = value;
		end;	
	this.GetValue =
		function (self)
			return UIDropDownMenu_GetSelectedValue(self);
		end
end

function InterfaceOptionsCombatTextPanelFCTDropDown_OnClick()
	UIDropDownMenu_SetSelectedValue(InterfaceOptionsCombatTextPanelFCTDropDown, this.value);
	SetCVar("combatTextFloatMode", this.value);
	UIParentLoadAddOn("Blizzard_CombatText");
	CombatText_UpdateDisplayedMessages();
end

function InterfaceOptionsCombatTextPanelFCTDropDown_Initialize()
	local selectedValue = UIDropDownMenu_GetSelectedValue(InterfaceOptionsCombatTextPanelFCTDropDown);
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
	xpBarText = { text = "XP_BAR_TEXT", default="0" },
	playerStatusText = { text = "STATUS_TEXT_PLAYER", default="0" },
	petStatusText = { text = "STATUS_TEXT_PET", default="0" },
	partyStatusText = { text = "STATUS_TEXT_PARTY", default="0" },
	targetStatusText = { text = "STATUS_TEXT_TARGET", default="0" },
	statusTextPercentage = { text = "STATUS_TEXT_PERCENT", default="0" },
}

-- [[ Party & Raid Options Panel ]] --

PartyRaidPanelOptions = {
	showPartyBackground = { text = "SHOW_PARTY_BACKGROUND_TEXT", default="0" },
	hidePartyInRaid = { text = "HIDE_PARTY_INTERFACE_TEXT", default="0" },
	showPartyPets = { text = "SHOW_PARTY_PETS_TEXT", default="1" },
	showPartyDebuffs = { text = "SHOW_DISPELLABLE_DEBUFFS_TEXT", default="0" },
	showPartyBuffs = { text = "SHOW_CASTABLE_BUFFS_TEXT", default="0" },
	showRaidRange = { text = "SHOW_RAID_RANGE_TEXT", default="0" },
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
	cameraTerrainTilt = { text = "FOLLOW_TERRAIN", default="0" },
	cameraBobbing = { text = "HEAD_BOB", default="0" },
	cameraWaterCollision = { text = "WATER_COLLISION", default="0" },
	cameraPivot = { text = "SMART_PIVOT", default="0" },
	cameraYawSmoothSpeed = { text = "AUTO_FOLLOW_SPEED", minValue = 90, maxValue = 270, valueStep = 10, default = 180 },
	cameraDistanceMaxFactor = { text = "MAX_FOLLOW_DIST", minValue = 1, maxValue = 2, valueStep = 0.1, default = 1 },
}

function InterfaceOptionsCameraPanelStyleDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, InterfaceOptionsCameraPanelStyleDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(this, GetCVar("cameraSmoothStyle"));
	InterfaceOptionsCameraPanelStyleDropDown.tooltip = getglobal("OPTION_TOOLTIP_CAMERA"..UIDropDownMenu_GetSelectedID(InterfaceOptionsCameraPanelStyleDropDown));
	UIDropDownMenu_SetWidth(144, InterfaceOptionsCameraPanelStyleDropDown);
	this.defaultValue = "1";
	this.value = GetCVar("cameraSmoothStyle");
	this.currValue = this.value;
	this.SetValue = 
		function (self, value)
			UIDropDownMenu_SetSelectedValue(self, value);
			SetCVar("cameraSmoothStyle", value, self.event);
			self.value = value;
			if ( tostring(value) == "0" ) then
				--For the purposes of tooltips and the dropdown list, value "0" in the CVar cameraSmoothStyle is actually "3".
				InterfaceOptionsCameraPanelStyleDropDown.tooltip = OPTION_TOOLTIP_CAMERA3;
				OptionsFrame_DisableSlider(InterfaceOptionsCameraPanelFollowSpeedSlider);
			else
				InterfaceOptionsCameraPanelStyleDropDown.tooltip = getglobal("OPTION_TOOLTIP_CAMERA" .. tostring(value));
				OptionsFrame_EnableSlider(InterfaceOptionsCameraPanelFollowSpeedSlider);
			end	
		end
	this.GetValue =
		function (self)
			return UIDropDownMenu_GetSelectedValue(self);
		end
end

function InterfaceOptionsCameraPanelStyleDropDown_OnClick()
	InterfaceOptionsCameraPanelStyleDropDown:SetValue(this.value);
end

function InterfaceOptionsCameraPanelStyleDropDown_Initialize()
	local selectedValue = UIDropDownMenu_GetSelectedValue(InterfaceOptionsCameraPanelStyleDropDown);
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
	mouseInvertPitch = { text = "INVERT_MOUSE", default="0" },
	autointeract = { text = "CLICK_TO_MOVE", default="0" },
	mousespeed = { text = "MOUSE_SENSITIVITY", minValue = 0.5, maxValue = 1.5, valueStep = 0.05, default = 1 },
	cameraYawMoveSpeed = { text = "MOUSE_LOOK_SPEED", minValue = 90, maxValue = 270, valueStep = 10, default = 180 },
}

function InterfaceOptionsMousePanelClickMoveStyleDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, InterfaceOptionsMousePanelClickMoveStyleDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(this, GetCVar("cameraSmoothTrackingStyle"));
	InterfaceOptionsMousePanelClickMoveStyleDropDown.tooltip = getglobal("OPTION_TOOLTIP_CLICK_CAMERA"..UIDropDownMenu_GetSelectedID(InterfaceOptionsMousePanelClickMoveStyleDropDown));
	UIDropDownMenu_SetWidth(140, InterfaceOptionsMousePanelClickMoveStyleDropDown);
	this.defaultValue = "1";
	this.value = GetCVar("cameraSmoothTrackingStyle");
	this.currValue = this.value;
	this.SetValue = 
		function (self, value)
			UIDropDownMenu_SetSelectedValue(self, value);
			SetCVar("cameraSmoothTrackingStyle", value, self.event);
			self.value = value;
			if ( tostring(value) == "0" ) then
				--For the purposes of tooltips and dropdown lists, "0" in the CVar cameraSmoothTrackingStyle is "3".
				InterfaceOptionsMousePanelClickMoveStyleDropDown.tooltip = OPTION_TOOLTIP_CLICK_CAMERA3;
			else
				InterfaceOptionsMousePanelClickMoveStyleDropDown.tooltip = getglobal("OPTION_TOOLTIP_CLICK_CAMERA" .. tostring(value));
			end
		end
	this.GetValue =
		function (self)
			return UIDropDownMenu_GetSelectedValue(self);
		end
end

function InterfaceOptionsMousePanelClickMoveStyleDropDown_OnClick()
	InterfaceOptionsMousePanelClickMoveStyleDropDown:SetValue(this.value);
end

function InterfaceOptionsMousePanelClickMoveStyleDropDown_Initialize()
	local selectedValue = UIDropDownMenu_GetSelectedValue(InterfaceOptionsMousePanelClickMoveStyleDropDown);
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
	showTutorials = { text = "SHOW_TUTORIALS", default="1" },
	showGameTips = { text = "SHOW_TIPOFTHEDAY_TEXT", default="1" },
	UberTooltips = { text = "USE_UBERTOOLTIPS", default="1" },
	showNewbieTips = { text = "SHOW_NEWBIE_TIPS_TEXT", default="1" },
}

-- [[ General functions ]] --

local ALT_KEY = "altkey";
local CONTROL_KEY = "controlkey";
local SHIFT_KEY = "shiftkey";
local NO_KEY = "none";

function BlizzardOptionsPanel_OnLoad (frame)
	InterfaceOptionsFrame_SetupBlizzardPanel(frame);
	InterfaceOptions_AddCategory(frame);
	if ( frame.options and frame.controls ) then
		local entry;
		for i, control in next, frame.controls do
			entry = frame.options[control.cvar];
			if ( entry ) then
				if ( entry.text ) then
					control.tooltipText = (getglobal("OPTION_TOOLTIP_" .. gsub(entry.text, "_TEXT$", "")) or entry.tooltip);
					getglobal(control:GetName() .. "Text"):SetText(getglobal(entry.text) or entry.text);
				end
				
				control.defaultValue = control.defaultValue or entry.default;
				control.event = entry.event or entry.text;
				
				if ( control.type == CONTROLTYPE_SLIDER ) then
					OptionsFrame_EnableSlider(control);
					control:SetMinMaxValues(entry.minValue, entry.maxValue);
					control:SetValueStep(entry.valueStep);
					control:SetValue(GetCVar(control.cvar));
				end
			end
		end
	end
end

function BlizzardOptionsPanel_OnShow (panel)
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
		if ( control.type == CONTROLTYPE_CHECKBOX ) then
			value = GetCVar(control.cvar);
			control.currValue = value;
			control.value = value;
			if ( control.uvar ) then
				setglobal(control.uvar, value);
			end
			
			if ( control.setFunc ) then
				control.setFunc(value);
			end
			control.GetValue = function(self) return GetCVar(self.cvar); end
			control.SetValue = function(self, value) self.value = value; SetCVar(self.cvar, value, self.event); if ( self.uvar ) then setglobal(self.uvar, value) end if ( self.setFunc ) then self.setFunc(value) end end
		elseif ( control.type == CONTROLTYPE_SLIDER ) then
			control.currValue = GetCVar(control.cvar);
		end
	end
end

function BlizzardOptionsPanel_SetupDependentControl (dependency, control)
	if ( not dependency ) then
		return;
	end
	
	control = control or this;
	
	dependency.dependentControls = dependency.dependentControls or {};
	tinsert(dependency.dependentControls, control);
	
	if ( control.type ~= CONTROLTYPE_DROPDOWN ) then
		control.oldDisable = control.Disable;
		control.oldEnable = control.Enable;
		control.Disable = function (self) self:oldDisable() getglobal(self:GetName().."Text"):SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b) end;
		control.Enable = function (self) self:oldEnable() getglobal(self:GetName().."Text"):SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b) end;
	else
		control.Disable = function (self) UIDropDownMenu_DisableDropDown(self) end;
		control.Enable = function (self) UIDropDownMenu_EnableDropDown(self) end;
	end
end

function BlizzardOptionsPanel_CheckButton_OnClick (checkButton)
	if ( not checkButton.invert ) then
		if ( checkButton:GetChecked() ) then
			checkButton.value = "1"
			SetCVar(checkButton.cvar, "1", checkButton.event);
			if ( checkButton.uvar ) then
				setglobal(checkButton.uvar, "1");
			end
		else
			checkButton.value = "0"
			SetCVar(checkButton.cvar, "0", checkButton.event);
			if ( checkButton.uvar ) then
				setglobal(checkButton.uvar, "0");
			end
		end
	else
		if ( checkButton:GetChecked() ) then
			checkButton.value = "0"
			SetCVar(checkButton.cvar, "0", checkButton.event);
			if ( checkButton.uvar ) then
				setglobal(checkButton.uvar, "0");
			end
		else
			checkButton.value = "1"
			SetCVar(checkButton.cvar, "1", checkButton.event);
			if ( checkButton.uvar ) then
				setglobal(checkButton.uvar, "1");
			end
		end
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
