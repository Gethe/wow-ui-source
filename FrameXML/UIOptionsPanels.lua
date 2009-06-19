local next = next;
local function SecureNext(elements, key)
	return securecall(next, elements, key);
end


-- [[ Generic Interface Options Panel ]] --

function InterfaceOptionsPanel_CheckButton_OnClick (checkButton)
	if ( checkButton:GetChecked() and checkButton.interruptCheck ) then
		checkButton.interruptCheck(checkButton);
		checkButton:SetChecked(false);	--Make it look like the button wasn't changed, but after the interrupt function has had a chance to look at what it was set to.
		return;
	elseif ( not checkButton:GetChecked() and checkButton.interruptUncheck ) then
		checkButton.interruptUncheck(checkButton);
		checkButton:SetChecked(true);	--Make it look like the button wasn't changed, but after the interrupt function has had a chance to look at what it was set to.
		return;
	end
	
	InterfaceOptionsPanel_CheckButton_Update(checkButton);
end
	
function InterfaceOptionsPanel_CheckButton_Update (checkButton)
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
		BlizzardOptionsPanel_SetCVarSafe(checkButton.cvar, setting, checkButton.event);
	end

	if ( checkButton.uvar ) then
		setglobal(checkButton.uvar, setting);
	end

	if ( checkButton.dependentControls ) then
		if ( checkButton:GetChecked() ) then
			for _, control in SecureNext, checkButton.dependentControls do
				control:Enable();
			end
		else
			for _, control in SecureNext, checkButton.dependentControls do
				control:Disable();
			end
		end
	end

	if ( checkButton.setFunc ) then
		checkButton.setFunc(setting);
	end
end


local function InterfaceOptionsPanel_CancelControl (control)
	if ( control.oldValue ) then
		if ( control.value and control.value ~= control.oldValue ) then
			control:SetValue(control.oldValue);
		end
	elseif ( control.value ) then
		if ( control:GetValue() ~= control.value ) then
			control:SetValue(control.value);
		end
	end
end

local function InterfaceOptionsPanel_DefaultControl (control)
	if ( control.defaultValue and control.value ~= control.defaultValue ) then
		control:SetValue(control.defaultValue);
		control.value = control.defaultValue;
	end
end

local function InterfaceOptionsPanel_Okay (self)
	for _, control in SecureNext, self.controls do
		securecall(BlizzardOptionsPanel_OkayControl, control);
	end
end

local function InterfaceOptionsPanel_Cancel (self)
	for _, control in SecureNext, self.controls do
		securecall(InterfaceOptionsPanel_CancelControl, control);
		if ( control.setFunc ) then
			control.setFunc(control:GetValue());
		end
	end
end

local function InterfaceOptionsPanel_Default (self)
	for _, control in SecureNext, self.controls do
		securecall(InterfaceOptionsPanel_DefaultControl, control);
		if ( control.setFunc ) then
			control.setFunc(control:GetValue());
		end
	end
end

local function InterfaceOptionsPanel_Refresh (self)
	for _, control in SecureNext, self.controls do
		securecall(BlizzardOptionsPanel_RefreshControl, control);
		-- record values so we can cancel back to this state
		control.oldValue = control.value;
	end
end


function InterfaceOptionsPanel_OnLoad (self)
	BlizzardOptionsPanel_OnLoad(self, nil, InterfaceOptionsPanel_Cancel, InterfaceOptionsPanel_Default, InterfaceOptionsPanel_Refresh);
	InterfaceOptions_AddCategory(self);
end


-- [[ Controls Options Panel ]] --

ControlsPanelOptions = {
	deselectOnClick = { text = "GAMEFIELD_DESELECT_TEXT" },
	autoDismountFlying = { text = "AUTO_DISMOUNT_FLYING_TEXT" },
	autoClearAFK = { text = "CLEAR_AFK" },
	blockTrades = { text = "BLOCK_TRADES" },
	lootUnderMouse = { text = "LOOT_UNDER_MOUSE_TEXT" },
	autoLootDefault = { text = "AUTO_LOOT_DEFAULT_TEXT" }, -- When this gets changed, the function SetAutoLootDefault needs to get run with its value.
	autoLootKey = { text = "AUTO_LOOT_KEY_TEXT", default = "NONE" },
	equipmentManager = { text = "USE_EQUIPMENT_MANAGER" },	
}

function InterfaceOptionsControlsPanelAutoLootKeyDropDown_OnEvent (self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self.defaultValue = "NONE";
		self.oldValue = GetModifiedClick("AUTOLOOTTOGGLE");
		self.value = self.oldValue or self.defaultValue;
		self.tooltip = _G["OPTION_TOOLTIP_AUTO_LOOT_"..self.value.."_KEY"];

		UIDropDownMenu_SetWidth(self, 90);
		UIDropDownMenu_Initialize(self, InterfaceOptionsControlsPanelAutoLootKeyDropDown_Initialize);
		UIDropDownMenu_SetSelectedValue(self, self.value);

		self.SetValue = 
			function (self, value)
				self.value = value;
				UIDropDownMenu_SetSelectedValue(self, value);
				SetModifiedClick("AUTOLOOTTOGGLE", value);
				SaveBindings(GetCurrentBindingSet());
				self.tooltip = _G["OPTION_TOOLTIP_AUTO_LOOT_"..value.."_KEY"];
			end
		self.GetValue =
			function (self)
				return UIDropDownMenu_GetSelectedValue(self);
			end
		self.RefreshValue =
			function (self)
				UIDropDownMenu_Initialize(self, InterfaceOptionsControlsPanelAutoLootKeyDropDown_Initialize);
				UIDropDownMenu_SetSelectedValue(self, self.value);
			end

		if ( GetCVar("autoLootDefault") == "1" ) then
			InterfaceOptionsControlsPanelAutoLootKeyDropDownLabel:SetText(LOOT_KEY_TEXT);
		else
			InterfaceOptionsControlsPanelAutoLootKeyDropDownLabel:SetText(AUTO_LOOT_KEY_TEXT);
		end
		
		self:UnregisterEvent(event);
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

function InterfaceOptionsControlsPanelAutoLootKeyDropDown_Update (value)
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

function InterfaceOptionsCombatPanelTOTDropDown_OnEvent (self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self.cvar = "targetOfTargetMode";

		local value = GetCVar(self.cvar);
		self.defaultValue = GetCVarDefault(self.cvar);
		self.value = value;
		self.oldValue = value;
		self.tooltip = _G["OPTION_TOOLTIP_TARGETOFTARGET" .. value];
		setglobal(self.uvar, value);

		UIDropDownMenu_SetWidth(self, 110);	
		UIDropDownMenu_Initialize(self, InterfaceOptionsCombatPanelTOTDropDown_Initialize);
		UIDropDownMenu_SetSelectedValue(self, value);

		self.SetValue =
			function (self, value)
				self.value = value;
				SetCVar(self.cvar, value);
				setglobal(self.uvar, value);
				UIDropDownMenu_SetSelectedValue(self, value);
				self.tooltip = _G["OPTION_TOOLTIP_TARGETOFTARGET" .. value];
			end
		self.GetValue =
			function (self)
				return UIDropDownMenu_GetSelectedValue(self);
			end
		self.RefreshValue =
			function (self)
				UIDropDownMenu_Initialize(self, InterfaceOptionsCombatPanelTOTDropDown_Initialize);
				UIDropDownMenu_SetSelectedValue(self, self.value);
			end
			
		self:UnregisterEvent(event);
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
		self.defaultValue = "NONE";
		self.oldValue = GetModifiedClick("SELFCAST");
		self.value = self.oldValue or self.defaultValue;
		self.tooltip = _G["OPTION_TOOLTIP_AUTO_SELF_CAST_"..self.value.."_KEY"];

		UIDropDownMenu_SetWidth(self, 90);
		UIDropDownMenu_Initialize(self, InterfaceOptionsCombatPanelSelfCastKeyDropDown_Initialize);
		UIDropDownMenu_SetSelectedValue(self, self.value);

		self.SetValue = 
			function (self, value) 
				self.value = value;
				UIDropDownMenu_SetSelectedValue(self, value);
				SetModifiedClick("SELFCAST", value);
				SaveBindings(GetCurrentBindingSet());
				self.tooltip = _G["OPTION_TOOLTIP_AUTO_SELF_CAST_"..value.."_KEY"];
			end;
		self.GetValue =
			function (self)
				return UIDropDownMenu_GetSelectedValue(self);
			end
		self.RefreshValue =
			function (self)
				UIDropDownMenu_Initialize(self, InterfaceOptionsCombatPanelSelfCastKeyDropDown_Initialize);
				UIDropDownMenu_SetSelectedValue(self, self.value);
			end
			
		self:UnregisterEvent(event);
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
		self.defaultValue = "NONE";
		self.oldValue = GetModifiedClick("FOCUSCAST");
		self.value = self.oldValue or self.defaultValue;
		self.tooltip = _G["OPTION_TOOLTIP_FOCUS_CAST_"..self.value.."_KEY"];

		UIDropDownMenu_SetWidth(self, 90);
		UIDropDownMenu_Initialize(self, InterfaceOptionsCombatPanelFocusCastKeyDropDown_Initialize);
		UIDropDownMenu_SetSelectedValue(self, self.value);

		self.SetValue =
			function (self, value)
				self.value = value;
				UIDropDownMenu_SetSelectedValue(self, value);
				SetModifiedClick("FOCUSCAST", value);
				SaveBindings(GetCurrentBindingSet());
				self.tooltip = _G["OPTION_TOOLTIP_FOCUS_CAST_"..value.."_KEY"];
			end;
		self.GetValue =
			function (self)
				return UIDropDownMenu_GetSelectedValue(self);
			end
		self.RefreshValue =
			function (self)
				UIDropDownMenu_Initialize(self, InterfaceOptionsCombatPanelFocusCastKeyDropDown_Initialize);
				UIDropDownMenu_SetSelectedValue(self, self.value);
			end
			
		self:UnregisterEvent(event);
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
	info.tooltipText = OPTION_TOOLTIP_FOCUS_CAST_CTRL_KEY;
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
	info.tooltipText = OPTION_TOOLTIP_FOCUS_CAST_SHIFT_KEY;
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
	info.tooltipText = OPTION_TOOLTIP_FOCUS_CAST_NONE_KEY;
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
	movieSubtitle = { text = "CINEMATIC_SUBTITLES" },
	threatShowNumeric = { text = "SHOW_NUMERIC_THREAT" },
	colorblindMode = { text = "USE_COLORBLIND_MODE" },
	previewTalents = { text = "PREVIEW_TALENT_CHANGES" },
}

function InterfaceOptionsDisplayPanel_OnLoad (self)
	self.name = DISPLAY_LABEL;
	self.options = DisplayPanelOptions;
	InterfaceOptionsPanel_OnLoad(self);

	self:SetScript("OnEvent", InterfaceOptionsDisplayPanel_OnEvent);
end

function InterfaceOptionsDisplayPanel_OnEvent (self, event, ...)
	BlizzardOptionsPanel_OnEvent(self, event, ...);

	if ( event == "PLAYER_ENTERING_WORLD" ) then
		local control;

		control = InterfaceOptionsDisplayPanelBuffDurations;
		control.setFunc(GetCVar(control.cvar));

		control = InterfaceOptionsDisplayPanelShowClock;
		control.setFunc(GetCVar(control.cvar));

		control = InterfaceOptionsDisplayPanelRotateMinimap;
		control.setFunc(GetCVar(control.cvar));
	end
end

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

function InterfaceOptionsDisplayPanelShowAggroPercentage_SetFunc()
	UnitFrame_Update(TargetFrame);
	UnitFrame_Update(FocusFrame);
end

function InterfaceOptionsDisplayPanelPreviewTalentChanges_SetFunc()
	if ( PlayerTalentFrame and PlayerTalentFrame:IsShown() and PlayerTalentFrame_Refresh ) then
		PlayerTalentFrame_Refresh();
	end
end

function InterfaceOptionsDisplayPanelWorldPVPObjectiveDisplay_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self.cvar = "displayWorldPVPObjectives";

		local value = GetCVar(self.cvar);
		self.defaultValue = GetCVarDefault(self.cvar);
		self.oldValue = value;
		self.value = value;
		self.tooltip = _G["OPTION_TOOLTIP_WORLD_PVP_DISPLAY"..value];

		UIDropDownMenu_SetWidth(self, 90);
		UIDropDownMenu_Initialize(self, InterfaceOptionsDisplayPanelWorldPVPObjectiveDisplay_Initialize);
		UIDropDownMenu_SetSelectedValue(self, value);

		WORLD_PVP_OBJECTIVES_DISPLAY = value;
		WorldStateAlwaysUpFrame_Update();

		self.SetValue = 
			function (self, value)
				self.value = value;
				SetCVar(self.cvar, value, self.event);
				self.tooltip = _G["OPTION_TOOLTIP_WORLD_PVP_DISPLAY"..value];
				UIDropDownMenu_SetSelectedValue(self, value);
				WORLD_PVP_OBJECTIVES_DISPLAY = value;
				WorldStateAlwaysUpFrame_Update();
			end
		self.GetValue =
			function (self)
				return UIDropDownMenu_GetSelectedValue(self);
			end
		self.RefreshValue =
			function (self)
				UIDropDownMenu_Initialize(self, InterfaceOptionsDisplayPanelWorldPVPObjectiveDisplay_Initialize);
				UIDropDownMenu_SetSelectedValue(self, self.value);
			end
			
		self:UnregisterEvent(event);
	end
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


function InterfaceOptionsDisplayPanelAggroWarningDisplay_OnEvent (self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self.cvar = "threatWarning";

		local value = GetCVar(self.cvar);
		self.defaultValue = GetCVarDefault(self.cvar);
		self.value = value;
		self.oldValue = value;
		self.tooltip = _G["OPTION_TOOLTIP_AGGRO_WARNING_DISPLAY"..(value+1)];

		UIDropDownMenu_SetWidth(self, 90);
		UIDropDownMenu_Initialize(self, InterfaceOptionsDisplayPanelAggroWarningDisplay_Initialize);
		UIDropDownMenu_SetSelectedValue(self, value);

		self.SetValue = 
			function (self, value)
				self.value = value;
				SetCVar(self.cvar, value, self.event);
				UIDropDownMenu_SetSelectedValue(self, value);
				self.tooltip = _G["OPTION_TOOLTIP_AGGRO_WARNING_DISPLAY"..(value+1)];
			end
		self.GetValue =
			function (self)
				return UIDropDownMenu_GetSelectedValue(self);
			end
		self.RefreshValue =
			function (self)
				UIDropDownMenu_Initialize(self, InterfaceOptionsDisplayPanelAggroWarningDisplay_Initialize);
				UIDropDownMenu_SetSelectedValue(self, self.value);
			end
			
		self:UnregisterEvent(event);
	end
end

function InterfaceOptionsDisplayPanelAggroWarningDisplay_OnClick(self)
	InterfaceOptionsDisplayPanelAggroWarningDisplay:SetValue(self.value);
end

function InterfaceOptionsDisplayPanelAggroWarningDisplay_Initialize()
	local selectedValue = UIDropDownMenu_GetSelectedValue(InterfaceOptionsDisplayPanelAggroWarningDisplay);
	local info = UIDropDownMenu_CreateInfo();

	info.text = ALWAYS;
	info.func = InterfaceOptionsDisplayPanelAggroWarningDisplay_OnClick;
	info.value = "3";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = ALWAYS;
	info.tooltipText = OPTION_TOOLTIP_AGGRO_WARNING_DISPLAY4;
	UIDropDownMenu_AddButton(info);

	info.text = AGGRO_WARNING_IN_INSTANCE;
	info.func = InterfaceOptionsDisplayPanelAggroWarningDisplay_OnClick;
	info.value = "1";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = AGGRO_WARNING_IN_INSTANCE;
	info.tooltipText = OPTION_TOOLTIP_AGGRO_WARNING_DISPLAY2;
	UIDropDownMenu_AddButton(info);

	info.text = AGGRO_WARNING_IN_PARTY;
	info.func = InterfaceOptionsDisplayPanelAggroWarningDisplay_OnClick;
	info.value = "2";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = AGGRO_WARNING_IN_PARTY;
	info.tooltipText = OPTION_TOOLTIP_AGGRO_WARNING_DISPLAY3;
	UIDropDownMenu_AddButton(info);

	info.text = NEVER;
	info.func = InterfaceOptionsDisplayPanelAggroWarningDisplay_OnClick;
	info.value = "0";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = NEVER;
	info.tooltipText = OPTION_TOOLTIP_AGGRO_WARNING_DISPLAY1;
	UIDropDownMenu_AddButton(info);
end

-- [[ Objectives Options Panel ]] --

ObjectivesPanelOptions = {
	questFadingDisable = { text = "SHOW_QUEST_FADING_TEXT" },
	autoQuestWatch = { text = "AUTO_QUEST_WATCH_TEXT" },
	autoQuestProgress = { text = "AUTO_QUEST_PROGRESS_TEXT" },
	advancedWatchFrame = { text = "ADVANCED_OBJECTIVES_TEXT" },
	watchFrameIgnoreCursor = { text = "OBJECTIVES_IGNORE_CURSOR_TEXT" },
	
}

function InterfaceOptionsObjectivesPanel_OnLoad (self)
	self.name = OBJECTIVES_LABEL;
	self.options = ObjectivesPanelOptions;
	InterfaceOptionsPanel_OnLoad(self);
	
	self:SetScript("OnEvent", InterfaceOptionsObjectivesPanel_OnEvent);
end

function InterfaceOptionsObjectivesPanel_OnEvent (self, event, ...)
	BlizzardOptionsPanel_OnEvent(self, event, ...);
	
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		local control = InterfaceOptionsObjectivesPanelAdvancedWatchFrame;
		control.setFunc(GetCVar(control.cvar));
		
		control = InterfaceOptionsObjectivesPanelIgnoreCursor;
		control.setFunc(GetCVar(control.cvar));
	end
end

function InterfaceOptionsObjectivesPanelAdvancedWatchFrame_UncheckInterrupt(self)
	StaticPopup_Show("ADVANCED_WATCHFRAME_OPTION_ENABLE_INTERRUPT");
end

function InterfaceOptionsObjectivesPanelAdvancedWatchFrame_ConfirmUncheck()
	local checkButton = InterfaceOptionsObjectivesPanelAdvancedWatchFrame;
	checkButton:SetChecked(false);
	InterfaceOptionsPanel_CheckButton_Update(checkButton);
end

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

function InterfaceOptionsSocialPanel_OnLoad (self)
	self.name = SOCIAL_LABEL;
	self.options = SocialPanelOptions;
	InterfaceOptionsPanel_OnLoad(self);

	self.okay = function (self)
		InterfaceOptionsPanel_Okay(self);

		-- I guess it's ok if simple chat is the only option that gets applied on okay...it is destructive
		if ( InterfaceOptionsSocialPanelSimpleChat:GetChecked() ) then
			SIMPLE_CHAT = "1";
			FCF_Set_SimpleChat();
		else
			SIMPLE_CHAT = "0";
			FCF_Set_NormalChat();
		end
	end

	self:SetScript("OnEvent", InterfaceOptionsSocialPanel_OnEvent);
end

function InterfaceOptionsSocialPanel_OnEvent(self, event, ...)
	BlizzardOptionsPanel_OnEvent(self, event, ...);

	if ( event == "PLAYER_ENTERING_WORLD" ) then
		local control;

		control = InterfaceOptionsSocialPanelChatHoverDelay;
		control.setFunc(GetCVar(control.cvar));

		-- bug 110191: The combat log overlaps the chat log after relogging with Simple Chat toggled.
		-- force the floating chat frames to simple chat mode (if it is enabled) to fix position and size issues
		if ( SIMPLE_CHAT == "1" ) then
			FCF_Set_SimpleChat();
		end
	end
end

function InterfaceOptionsSocialPanelSimpleChat_CheckInterrupt(self)
	StaticPopup_Show("SIMPLE_CHAT_OPTION_ENABLE_INTERRUPT");
end

function InterfaceOptionsSocialPanelSimpleChat_ConfirmCheck()
	local checkButton = InterfaceOptionsSocialPanelSimpleChat;
	checkButton:SetChecked(true);
	InterfaceOptionsPanel_CheckButton_Update(checkButton);
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

function InterfaceOptionsActionBarsPanel_OnLoad (self)
	self.name = ACTIONBARS_LABEL;
	self.options = ActionBarsPanelOptions;
	InterfaceOptionsPanel_OnLoad(self);

	self:SetScript("OnEvent", InterfaceOptionsActionBarsPanel_OnEvent);
end

function InterfaceOptionsActionBarsPanel_OnEvent (self, event, ...)
	BlizzardOptionsPanel_OnEvent(self, event, ...);

	if ( event == "PLAYER_ENTERING_WORLD" ) then
		local control;

		control = InterfaceOptionsActionBarsPanelAlwaysShowActionBars;
		control.setFunc(GetCVar(control.cvar));
	end
end

function InterfaceOptions_UpdateMultiActionBars ()
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
	fctSpellMechanics = { text = "SHOW_TARGET_EFFECTS" },
	fctSpellMechanicsOther = { text = "SHOW_OTHER_TARGET_EFFECTS" },
}

function BlizzardOptionsPanel_UpdateCombatText ()
	-- Fix for bug 106938. CombatText_UpdateDisplayedMessages only exists if the Blizzard_CombatText AddOn is loaded.
	-- We need CombatText options to have their setFunc actually _exist_, so this function is used instead of CombatText_UpdateDisplayedMessages.
	if ( CombatText_UpdateDisplayedMessages ) then
		CombatText_UpdateDisplayedMessages();
	end
end

function InterfaceOptionsCombatTextPanel_OnLoad (self)
	self.name = COMBATTEXT_LABEL;
	self.options = FCTPanelOptions;
	InterfaceOptionsPanel_OnLoad(self);

	self:SetScript("OnEvent", InterfaceOptionsCombatTextPanel_OnEvent);
end

function InterfaceOptionsCombatTextPanel_OnEvent (self, event, ...)
	BlizzardOptionsPanel_OnEvent(self, event, ...);

	if ( event == "PLAYER_ENTERING_WORLD" ) then
		local control;

		-- run the enable FCT button's set func to refresh floating combat text and make sure the addon is loaded
		control = InterfaceOptionsCombatTextPanelEnableFCT;
		control.setFunc(GetCVar(control.cvar));

		-- fix for bug 106687: self button can no longer be enabled if you're not a rogue or a druid
		control = InterfaceOptionsCombatTextPanelComboPoints;
		control.SetChecked =
			function (self, checked)
				local _, class = UnitClass("player");
				if ( class ~= "ROGUE" and class ~= "DRUID" ) then
					checked = false;
				end
				getmetatable(self).__index.SetChecked(self, checked);
			end
		control.Enable =
			function (self)
				local _, class = UnitClass("player");
				if ( class ~= "ROGUE" and class ~= "DRUID" ) then
					return;
				end
				getmetatable(self).__index.Enable(self);
				local text = _G[self:GetName().."Text"];
				local fontObject = text:GetFontObject();
				_G[self:GetName().."Text"]:SetTextColor(fontObject:GetTextColor());
			end
		control.setFunc(GetCVar(control.cvar));
	end
end

function InterfaceOptionsCombatTextPanelFCTDropDown_OnEvent (self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self.cvar = "combatTextFloatMode";

		local value = GetCVar(self.cvar);
		self.defaultValue = GetCVarDefault(self.cvar);
		self.oldValue = value;
		self.value = value;
		self.tooltip = OPTION_TOOLTIP_COMBAT_TEXT_MODE;

		UIDropDownMenu_SetWidth(self, 110);
		UIDropDownMenu_Initialize(self, InterfaceOptionsCombatTextPanelFCTDropDown_Initialize);
		UIDropDownMenu_SetSelectedValue(self, value);

		COMBAT_TEXT_FLOAT_MODE = value;
		if ( CombatText_UpdateDisplayedMessages ) then
			-- If the CombatText AddOn has already been loaded, we need to reinit it to pick up the previous COMBAT_TEXT_FLOAT_MODE.
			CombatText_UpdateDisplayedMessages();
		end

		self.SetValue = 
			function (self, value) 
				self.value = value;
				SetCVar(self.cvar, value, self.event);
				UIDropDownMenu_SetSelectedValue(self, value);

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
		self.RefreshValue =
			function (self)
				UIDropDownMenu_Initialize(self, InterfaceOptionsCombatTextPanelFCTDropDown_Initialize);
				UIDropDownMenu_SetSelectedValue(self, self.value);
			end
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
	info.value = "1";
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
	info.value = "2";
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
	info.value = "3";
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

-- [[ UnitFrame Options Panel ]] --

UnitFramePanelOptions = {
	showPartyBackground = { text = "SHOW_PARTY_BACKGROUND_TEXT" },
	hidePartyInRaid = { text = "HIDE_PARTY_INTERFACE_TEXT" },
	showPartyPets = { text = "SHOW_PARTY_PETS_TEXT" },
	showDispelDebuffs = { text = "SHOW_DISPELLABLE_DEBUFFS_TEXT" },
	showCastableBuffs = { text = "SHOW_CASTABLE_BUFFS_TEXT" },
	showRaidRange = { text = "SHOW_RAID_RANGE_TEXT" },
	showArenaEnemyFrames = { text = "SHOW_ARENA_ENEMY_FRAMES_TEXT" },
	showArenaEnemyCastbar = { text = "SHOW_ARENA_ENEMY_CASTBAR_TEXT" },
	showArenaEnemyPets = { text = "SHOW_ARENA_ENEMY_PETS_TEXT" },
}

function BlizzardOptionsPanel_UpdateRaidPullouts ()
	if ( type(NUM_RAID_PULLOUT_FRAMES) ~= "number" ) then
		return;
	end

	local frame;
	for i = 1, NUM_RAID_PULLOUT_FRAMES do
		frame = _G["RaidPullout" .. i];
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

function InterfaceOptionsCameraPanel_OnLoad (self)
	self.name = CAMERA_LABEL;
	self.options = CameraPanelOptions;
	InterfaceOptionsPanel_OnLoad(self)

	self:SetScript("OnEvent", InterfaceOptionsCameraPanel_OnEvent);
end

function InterfaceOptionsCameraPanel_OnEvent (self, event, ...)
	BlizzardOptionsPanel_OnEvent(self, event, ...);

	if ( event == "PLAYER_ENTERING_WORLD" ) then
		if ( GetCVar("cameraSmoothStyle") == "0" ) then
			BlizzardOptionsPanel_Slider_Disable(InterfaceOptionsCameraPanelFollowSpeedSlider);
			InterfaceOptionsCameraPanelFollowTerrain:Disable();
		end
	end
end

function InterfaceOptionsCameraPanelStyleDropDown_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self.cvar = "cameraSmoothStyle";

		local value = GetCVar(self.cvar);
		self.defaultValue = GetCVarDefault(self.cvar);
		self.value = value;
		self.oldValue = value;
		if ( value == "0" ) then
			--For the purposes of tooltips and the dropdown list, value "0" in the CVar cameraSmoothStyle is actually "3".
			self.tooltip = OPTION_TOOLTIP_CAMERA3;
		else
			self.tooltip = _G["OPTION_TOOLTIP_CAMERA"..value];
		end	

		UIDropDownMenu_SetWidth(self, 144);
		UIDropDownMenu_Initialize(self, InterfaceOptionsCameraPanelStyleDropDown_Initialize);
		UIDropDownMenu_SetSelectedValue(self, value);

		self.SetValue = 
			function (self, value)
				self.value = value;
				SetCVar(self.cvar, value, self.event);
				UIDropDownMenu_SetSelectedValue(self, value);
				if ( value == "0" ) then
					--For the purposes of tooltips and the dropdown list, value "0" in the CVar cameraSmoothStyle is actually "3".
					self.tooltip = OPTION_TOOLTIP_CAMERA3;
					BlizzardOptionsPanel_Slider_Disable(InterfaceOptionsCameraPanelFollowSpeedSlider);
					InterfaceOptionsCameraPanelFollowTerrain:Disable();
				else
					self.tooltip = _G["OPTION_TOOLTIP_CAMERA"..value];
					BlizzardOptionsPanel_Slider_Enable(InterfaceOptionsCameraPanelFollowSpeedSlider);
					InterfaceOptionsCameraPanelFollowTerrain:Enable();
				end	
			end
		self.GetValue =
			function (self)
				return UIDropDownMenu_GetSelectedValue(self);
			end
		self.RefreshValue =
			function (self)
				UIDropDownMenu_Initialize(self, InterfaceOptionsCameraPanelStyleDropDown_Initialize);
				UIDropDownMenu_SetSelectedValue(self, self.value);
			end
			
		self:UnregisterEvent(event);
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
	info.value = "1";
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
	info.value = "2";
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
	info.value = "0";
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

function InterfaceOptionsMousePanelClickMoveStyleDropDown_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self.cvar = "cameraSmoothTrackingStyle";

		local value = GetCVar(self.cvar);
		self.defaultValue = GetCVarDefault(self.cvar);
		self.oldValue = value;
		self.value = value;
		if ( value == "0" ) then
			--For the purposes of tooltips and dropdown lists, "0" in the CVar cameraSmoothTrackingStyle is "3".
			self.tooltip = OPTION_TOOLTIP_CLICK_CAMERA3;
		else
			self.tooltip = _G["OPTION_TOOLTIP_CLICK_CAMERA"..value];
		end

		UIDropDownMenu_SetWidth(self, 140);
		UIDropDownMenu_Initialize(self, InterfaceOptionsMousePanelClickMoveStyleDropDown_Initialize);
		UIDropDownMenu_SetSelectedValue(self, value);

		self.SetValue = 
			function (self, value)
				self.value = value;
				SetCVar(self.cvar, value, self.event);
				UIDropDownMenu_SetSelectedValue(self, value);
				if ( value == "0" ) then
					--For the purposes of tooltips and dropdown lists, "0" in the CVar cameraSmoothTrackingStyle is "3".
					self.tooltip = OPTION_TOOLTIP_CLICK_CAMERA3;
				else
					self.tooltip = _G["OPTION_TOOLTIP_CLICK_CAMERA"..value];
				end
			end
		self.GetValue =
			function (self)
				return UIDropDownMenu_GetSelectedValue(self);
			end
		self.RefreshValue =
			function (self)
				UIDropDownMenu_Initialize(self, InterfaceOptionsMousePanelClickMoveStyleDropDown_Initialize);
				UIDropDownMenu_SetSelectedValue(self, self.value);
			end
		
		self:UnregisterEvent(event);
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
	info.value = "1";
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
	info.value = "2";
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
	info.value = "0";
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
	showTutorials = { text = "SHOW_TUTORIALS", default = "1", tooltipText = OPTION_TOOLTIP_SHOW_TUTORIALS },
	showGameTips = { text = "SHOW_TIPOFTHEDAY_TEXT" },
	UberTooltips = { text = "USE_UBERTOOLTIPS" },
	showNewbieTips = { text = "SHOW_NEWBIE_TIPS_TEXT" },
	scriptErrors = { text = "SHOW_LUA_ERRORS" },
}

function InterfaceOptionsHelpPanel_SetTutorials (value)
	if ( value == "1" and not TutorialsEnabled() ) then
		ResetTutorials();
	elseif ( value == "0" and TutorialsEnabled() ) then
		ClearTutorials();
		TutorialFrame_HideAllAlerts();
	end
end

-- [[ Languages Options Panel ]] --

LanguagesPanelOptions = {
	useEnglishAudio = { text = "USE_ENGLISH_AUDIO" },
}

function InterfaceOptionsLanguagesPanel_OnLoad (panel)
	-- Check and see if we have more than one locale. If we don't, then don't register this panel.
	if ( #({GetExistingLocales()}) <= 1 ) then
		return;
	end

	InterfaceOptionsPanel_OnLoad(panel);
end

function InterfaceOptionsLanguagesPanelLocaleDropDown_OnEvent (self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self.cvar = "locale";

		local value = GetCVar(self.cvar);
		self.defaultValue = GetCVarDefault(self.cvar);
		self.oldValue = value;
		self.value = value;
		self.tooltip = OPTION_TOOLTIP_LOCALE;

		UIDropDownMenu_SetWidth(self, 120);
		UIDropDownMenu_Initialize(self, InterfaceOptionsLanguagesPanelLocaleDropDown_Initialize);
		UIDropDownMenu_SetSelectedValue(self, value);

		self.SetValue = 
			function (self, value)
				UIDropDownMenu_SetSelectedValue(self, value);
				SetCVar("locale", value, self.event);
				self.value = value;
				if ( self.oldValue ~= value ) then
					InterfaceOptionsFrame.gameRestart = true;
				end
			end
		self.GetValue =
			function (self)
				return UIDropDownMenu_GetSelectedValue(self);
			end
		self.RefreshValue =
			function (self)
				UIDropDownMenu_Initialize(self, InterfaceOptionsLanguagesPanelLocaleDropDown_Initialize);
				UIDropDownMenu_SetSelectedValue(self, self.value);
			end
			
		self:UnregisterEvent(event);
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
			createInfo.text = _G[strupper(value)];
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
