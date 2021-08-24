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
	local setting = checkButton.uncheckedValue or "0";
	if ( checkButton:GetChecked() ) then
		if ( not checkButton.invert ) then
			setting = checkButton.checkedValue or "1"
		end
	elseif ( checkButton.invert ) then
		setting = checkButton.checkedValue or "1"
	end

	checkButton.value = setting;

	if ( checkButton.cvar ) then
		BlizzardOptionsPanel_SetCVarSafe(checkButton.cvar, setting, checkButton.event);
	end

	if ( checkButton.uvar ) then
		_G[checkButton.uvar] = setting;
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

local function InterfaceOptionsPanel_Okay (self, perControlCallback)
	BlizzardOptionsPanel_Okay(self, perControlCallback);
end

function InterfaceOptionsPanel_Cancel (self)
	for _, control in SecureNext, self.controls do
		securecall(InterfaceOptionsPanel_CancelControl, control);
		if ( control.setFunc ) then
			control.setFunc(control:GetValue());
		end
	end
end

function InterfaceOptionsPanel_Default (self)
	for _, control in SecureNext, self.controls do
		securecall(InterfaceOptionsPanel_DefaultControl, control);
		if ( control.setFunc ) then
			control.setFunc(control:GetValue());
		end
	end
	if ( self.defaultFuncs ) then
		for _, defaultFunc in SecureNext, self.defaultFuncs do
			defaultFunc();
		end
	end
end

local function RefreshCallback(panel, control)
	-- record values so we can cancel back to this state
	control.oldValue = control.value;
end

function InterfaceOptionsPanel_Refresh (self)
	BlizzardOptionsPanel_Refresh(self, RefreshCallback);
end

function InterfaceOptionsPanel_OnLoad (self)
	BlizzardOptionsPanel_OnLoad(self, nil, InterfaceOptionsPanel_Cancel, InterfaceOptionsPanel_Default, InterfaceOptionsPanel_Refresh);
	InterfaceOptions_AddCategory(self);
end

function InterfaceOptionsPanel_RegisterSetToDefaultFunc(func, self)
	self.defaultFuncs = self.defaultFuncs or {};
	tinsert(self.defaultFuncs, func);
end

-- [[ Controls Options Panel ]] --

ControlsPanelOptions = {
	deselectOnClick = { text = "GAMEFIELD_DESELECT_TEXT" },
	autoClearAFK = { text = "CLEAR_AFK" },
	autoLootDefault = { text = "AUTO_LOOT_DEFAULT_TEXT" }, -- When this gets changed, the function SetAutoLootDefault needs to get run with its value.
	autoLootKey = { text = "AUTO_LOOT_KEY_TEXT", default = "NONE" },
	interactOnLeftClick = { text = "INTERACT_ON_LEFT_CLICK_TEXT" },
	lootUnderMouse = { text = "LOOT_UNDER_MOUSE_TEXT" },
}

function InterfaceOptionsControlsPanelAutoLootKeyDropDown_OnEvent (self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self.defaultValue = "SHIFT";
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
				AttemptToSaveBindings(GetCurrentBindingSet());
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
	autoSelfCast = { text = "AUTO_SELF_CAST_TEXT" },
	showTargetOfTarget = { text = "SHOW_TARGET_OF_TARGET_TEXT" },
	doNotFlashLowHealthWarning = { text = "FLASH_LOW_HEALTH_WARNING" },
    enableFloatingCombatText = { text = "SHOW_COMBAT_TEXT_TEXT" },
	floatingCombatTextLowManaHealth = { text = "COMBAT_TEXT_SHOW_LOW_HEALTH_MANA_TEXT" },
	floatingCombatTextAuras = { text = "COMBAT_TEXT_SHOW_AURAS_TEXT" },
	floatingCombatTextAuraFade  = { text = "COMBAT_TEXT_SHOW_AURA_FADE_TEXT" }, 
	floatingCombatTextCombatState = { text = "COMBAT_TEXT_SHOW_COMBAT_STATE_TEXT" },
	floatingCombatTextDodgeParryMiss = {text = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS_TEXT" },
	floatingCombatTextDamageReduction = { text = "COMBAT_TEXT_SHOW_RESISTANCES_TEXT" },
	floatingCombatTextRepChanges = { text = "COMBAT_TEXT_SHOW_REPUTATION_TEXT" },
	floatingCombatTextReactives = { text = "COMBAT_TEXT_SHOW_REACTIVES_TEXT" },
	floatingCombatTextFriendlyHealers = { text = "COMBAT_TEXT_SHOW_FRIENDLY_NAMES_TEXT" },
	floatingCombatTextComboPoints = { text = "COMBAT_TEXT_SHOW_COMBO_POINTS_TEXT" },
	floatingCombatTextEnergyGains = { text = "COMBAT_TEXT_SHOW_ENERGIZE_TEXT" },
	floatingCombatTextHonorGains = { text = "COMBAT_TEXT_SHOW_HONOR_GAINED_TEXT" },
	floatingCombatTextCombatDamage = { text = "SHOW_DAMAGE_TEXT_TEXT" },
	floatingCombatTextCombatLogPeriodicSpells = { text = "LOG_PERIODIC_EFFECTS_TEXT" },
	floatingCombatTextPetMeleeDamage = { text = "SHOW_PET_MELEE_DAMAGE_TEXT" },
}

-- [[ Self Cast key dropdown ]] --
function InterfaceOptionsCombatPanelSelfCastKeyDropDown_OnEvent (self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self.defaultValue = "ALT";
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
				AttemptToSaveBindings(GetCurrentBindingSet());
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
--]]

function InterfaceOptionsCombatPanelCombatTextFloatModeDropDown_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self.defaultValue = "1";
		self.value = self.oldValue or self.defaultValue;
		self.tooltip = _G["OPTION_TOOLTIP_COMBAT_TEXT_MODE"];

		UIDropDownMenu_SetWidth(self, 90);
		UIDropDownMenu_Initialize(self, InterfaceOptionsCombatPanelCombatTextFloatModeDropDown_Initialize);
		UIDropDownMenu_SetSelectedValue(self, self.value);

		self.SetValue =
			function (self, value)
				self.value = value;
				SetCVar(self.cvar, value, self.event);
				UIDropDownMenu_SetSelectedValue(self, value);

				COMBAT_TEXT_FLOAT_MODE = self.value;
				UIParentLoadAddOn("Blizzard_CombatText");
				CombatText_UpdateDisplayedMessages();
			end;
		self.GetValue =
			function (self)
				return UIDropDownMenu_GetSelectedValue(self);
			end
		self.RefreshValue =
			function (self)
				UIDropDownMenu_Initialize(self, InterfaceOptionsCombatPanelCombatTextFloatModeDropDown_Initialize);
				UIDropDownMenu_SetSelectedValue(self, self.value);
			end

		self:UnregisterEvent(event);
	end
end

function InterfaceOptionsCombatPanelCombatTextFloatDropDown_OnClick(self)
	InterfaceOptionsCombatPanelCombatTextFloatModeDropDown:SetValue(self.value);
end

function InterfaceOptionsCombatPanelCombatTextFloatModeDropDown_Initialize()

	local selectedValue = UIDropDownMenu_GetSelectedValue(InterfaceOptionsCombatPanelCombatTextFloatModeDropDown);
	local info = UIDropDownMenu_CreateInfo();

	info.text = COMBAT_TEXT_SCROLL_UP;
	info.func = InterfaceOptionsCombatPanelCombatTextFloatDropDown_OnClick;
	info.value = "1";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = COMBAT_TEXT_SCROLL_UP;
	info.tooltipText = OPTION_TOOLTIP_SCROLL_UP;
	UIDropDownMenu_AddButton(info);

	info = {};
	info.text = COMBAT_TEXT_SCROLL_DOWN;
	info.func = InterfaceOptionsCombatPanelCombatTextFloatDropDown_OnClick;
	info.value = "2"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	end
	info.tooltipTitle = COMBAT_TEXT_SCROLL_DOWN;
	info.tooltipText = OPTION_TOOLTIP_SCROLL_DOWN;
	UIDropDownMenu_AddButton(info);

	info = {};
	info.text = COMBAT_TEXT_SCROLL_ARC;
	info.func = InterfaceOptionsCombatPanelCombatTextFloatDropDown_OnClick;
	info.value = "3"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	end
	info.tooltipTitle = COMBAT_TEXT_SCROLL_ARC;
	info.tooltipText = OPTION_TOOLTIP_SCROLL_ARC;
	UIDropDownMenu_AddButton(info);

end

-- [[ Focus Cast key dropdown ]] --
--[[function InterfaceOptionsCombatPanelFocusCastKeyDropDown_OnEvent (self, event, ...)
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
				AttemptToSaveBindings(GetCurrentBindingSet());
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
end]]

function InterfaceOptionsCombatPanel_OnLoad(self)
	self.name = COMBAT_LABEL;
	self.options = CombatPanelOptions;
	InterfaceOptionsPanel_OnLoad(self);

	self:SetScript("OnEvent", InterfaceOptionsCombatPanel_OnEvent);
end

function InterfaceOptionsCombatPanel_OnEvent (self, event, ...)
	BlizzardOptionsPanel_OnEvent(self, event, ...);

	if ( event == "PLAYER_ENTERING_WORLD" ) then
		local control;

        -- run the enable FCT button's set func to refresh floating combat text and make sure the addon is loaded
		control = InterfaceOptionsCombatPanelEnableFloatingCombatText;
		control.setFunc(GetCVar(control.cvar));
	end
end

-- [[ Display Options Panel ]] --

DisplayPanelOptions = {
	findYourselfMode = { text = "SELF_HIGHLIGHT_OPTION", tooltip = OPTION_TOOLTIP_SELF_HIGHLIGHT },
	instantQuestText = { text = "SHOW_QUEST_FADING_TEXT", tooltip = OPTION_TOOLTIP_SHOW_QUEST_FADING },
	autoQuestWatch = { text = "AUTO_QUEST_WATCH_TEXT", tooltip = OPTION_TOOLTIP_AUTO_QUEST_PROGRESS },
	hideOutdoorWorldState = { text = "HIDE_OUTDOOR_WORLD_STATE_TEXT" , tooltip = OPTION_TOOLTIP_HIDE_OUTDOOR_WORLD_STATE },
	rotateMinimap = { text = "ROTATE_MINIMAP" },
	showMinimapClock = { text = "SHOW_MINIMAP_CLOCK" },
	showNewbieTips = { text = "SHOW_NEWBIE_TIPS_TEXT", tooltip = OPTION_TOOLTIP_SHOW_NEWBIE_TIPS },
	showLoadingScreenTips = { text = "SHOW_TIPOFTHEDAY_TEXT", tooltip = OPTION_TOOLTIP_SHOW_TIPOFTHEDAY },
    showTutorials = { text = "SHOW_TUTORIALS" },
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

		control = InterfaceOptionsDisplayPanelRotateMinimap;
		control.setFunc(GetCVar(control.cvar));
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

--[[function InterfaceOptionsDisplayPanelSelfHighlightDropDown_OnShow(self)
	self.cvar = "findYourselfMode";

	self.defaultValue = GetCVarDefault(self.cvar);
	self.value = GetCVar(self.cvar);
	self.oldValue = self.value;

	UIDropDownMenu_SetWidth(self, 180);
	UIDropDownMenu_Initialize(self, InterfaceOptionsDisplayPanelSelfHighlightDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(self, self.value);

	self.SetValue =
		function (self, value)
			self.value = value;
			SetCVar(self.cvar, self.value);
			UIDropDownMenu_SetSelectedValue(self, self.value);
		end
	self.GetValue =
		function (self)
			return UIDropDownMenu_GetSelectedValue(self);
		end
	self.RefreshValue =
		function (self)
			UIDropDownMenu_Initialize(self, InterfaceOptionsDisplayPanelSelfHighlightDropDown_Initialize);
			UIDropDownMenu_SetSelectedValue(self, self.value);
		end

	self.tooltip = OPTION_TOOLTIP_SELF_HIGHLIGHT;
end

function InterfaceOptionsDisplayPanelSelfHighlightDropDown_OnClick(self)
	InterfaceOptionsDisplayPanelSelfHighlightDropDown:SetValue(self.value);
end

function InterfaceOptionsDisplayPanelSelfHighlightDropDown_Initialize()
	local selectedValue = UIDropDownMenu_GetSelectedValue(InterfaceOptionsDisplayPanelSelfHighlightDropDown);
	local info = UIDropDownMenu_CreateInfo();

	info.text = SELF_HIGHLIGHT_MODE_CIRCLE;
	info.func = InterfaceOptionsDisplayPanelSelfHighlightDropDown_OnClick;
	info.value = "0";
	info.checked = info.value == selectedValue;
	UIDropDownMenu_AddButton(info);

	info.text = SELF_HIGHLIGHT_MODE_OUTLINE;
	info.value = "2";
	info.checked = info.value == selectedValue;
	UIDropDownMenu_AddButton(info);

	info.text = SELF_HIGHLIGHT_MODE_CIRCLE_AND_OUTLINE;
	info.value = "1";
	info.checked = info.value == selectedValue;
	UIDropDownMenu_AddButton(info);

    info.text = OFF;
    info.value = "-1";
    info.checked = info.value == selectedValue;
    UIDropDownMenu_AddButton(info);
end]]

function InterfaceOptionsDisplayPanelChatBubblesDropDown_GetValue(self)
    if (GetCVarBool(self.cvar) and GetCVarBool(self.partyCvar)) then
        return 1;
    elseif (GetCVarBool(self.cvar)) then
        return 3;
    else
        return 2;
    end
end

function InterfaceOptionsDisplayPanelChatBubblesDropDown_SetValue(self, value)
    if (value == 1) then
        SetCVar(self.cvar, "1");
        SetCVar(self.partyCvar, "1");
    elseif (value == 2) then
        SetCVar(self.cvar, "0");
        SetCVar(self.partyCvar, "0");
    else
        SetCVar(self.cvar, "1");
        SetCVar(self.partyCvar, "0");
    end
end

function InterfaceOptionsDisplayPanelChatBubblesDropDown_OnShow(self)
	self.cvar = "chatBubbles";
    self.partyCvar = "chatBubblesParty";

    local value = InterfaceOptionsDisplayPanelChatBubblesDropDown_GetValue(self);
	self.value = value;

	UIDropDownMenu_SetWidth(self, 110);
	UIDropDownMenu_Initialize(self, InterfaceOptionsDisplayPanelChatBubbles_Initialize);
	UIDropDownMenu_SetSelectedValue(self, value);

	self.SetValue =
		function (self, value)
			self.value = value;
			InterfaceOptionsDisplayPanelChatBubblesDropDown_SetValue(self, value);
			UIDropDownMenu_SetSelectedValue(self, self.value);
		end
	self.GetValue =
		function (self)
			return UIDropDownMenu_GetSelectedValue(self);
		end
	self.RefreshValue =
		function (self)
			UIDropDownMenu_Initialize(self, InterfaceOptionsDisplayPanelChatBubbles_Initialize);
			UIDropDownMenu_SetSelectedValue(self, self.value);
		end
end

function InterfaceOptionsDisplayPanelChatBubblesDropDown_OnClick(self)
	InterfaceOptionsDisplayPanelChatBubblesDropDown:SetValue(self.value);
end

function InterfaceOptionsDisplayPanelChatBubbles_Initialize(self)
	local selectedValue = UIDropDownMenu_GetSelectedValue(self);
	local info = UIDropDownMenu_CreateInfo();
	self.tooltip = OPTION_TOOLTIP_CHAT_BUBBLES;

	info.text = ALL;
	info.func = InterfaceOptionsDisplayPanelChatBubblesDropDown_OnClick;
	info.value = 1;
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	UIDropDownMenu_AddButton(info);

	info.text =NONE;
	info.func = InterfaceOptionsDisplayPanelChatBubblesDropDown_OnClick;
	info.value = 2;
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	UIDropDownMenu_AddButton(info);

	info.text = CHAT_BUBBLES_EXCLUDE_PARTY_CHAT;
	info.func = InterfaceOptionsDisplayPanelChatBubblesDropDown_OnClick;
	info.value = 3;
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	UIDropDownMenu_AddButton(info);
end

function BlizzardOptionsPanel_UpdateCombatText ()
	-- Fix for bug 106938. CombatText_UpdateDisplayedMessages only exists if the Blizzard_CombatText AddOn is loaded.
	-- We need CombatText options to have their setFunc actually _exist_, so this function is used instead of CombatText_UpdateDisplayedMessages.
	if ( CombatText_UpdateDisplayedMessages ) then
		CombatText_UpdateDisplayedMessages();
	end
end

-- [[ Social Options Panel ]] --

TwitterData = {
	linked = false,
	screenName = nil
}

SocialPanelOptions = {
	profanityFilter = { text = "PROFANITY_FILTER" },

	spamFilter = { text="SPAM_FILTER" },
	showLootSpam = { text="SHOW_LOOT_SPAM" },
	guildMemberNotify = { text="GUILDMEMBER_ALERT" },
	blockTrades = { text = "BLOCK_TRADES" },
	blockChannelInvites = { text = "BLOCK_CHAT_CHANNEL_INVITE" },
    showToastOnline = { text = "SHOW_TOAST_ONLINE_TEXT" },
	showToastOffline = { text = "SHOW_TOAST_OFFLINE_TEXT" },
	showToastBroadcast = { text = "SHOW_TOAST_BROADCAST_TEXT" },
	showToastFriendRequest = { text = "SHOW_TOAST_FRIEND_REQUEST_TEXT" },
	showToastWindow = { text = "SHOW_TOAST_WINDOW_TEXT" },
	enableTwitter = { text = "SOCIAL_ENABLE_TWITTER_FUNCTIONALITY" },
}

function InterfaceOptionsSocialPanel_OnLoad (self)
	self.name = SOCIAL_LABEL;
	self.options = SocialPanelOptions;
	InterfaceOptionsPanel_OnLoad(self);

	self.okay = function (self)
		InterfaceOptionsPanel_Okay(self);
	end

	self:RegisterEvent("BN_DISCONNECTED");
	self:RegisterEvent("BN_CONNECTED");
	self:RegisterEvent("TWITTER_STATUS_UPDATE");
	self:RegisterEvent("TWITTER_LINK_RESULT");
	self:SetScript("OnEvent", InterfaceOptionsSocialPanel_OnEvent);

	-- Send an event to the server to request Twitter status and enable social UI if checked
	C_Social.TwitterCheckStatus();
end

function InterfaceOptionsSocialPanel_OnHide(self)
	SocialBrowserFrame:Hide();
end

function InterfaceOptionsSocialPanel_OnEvent(self, event, ...)
	BlizzardOptionsPanel_OnEvent(self, event, ...);

	if ( event == "TWITTER_STATUS_UPDATE" ) then
		local enabled, linked, screenName = ...;
		if (enabled and not Kiosk.IsEnabled()) then
			self.EnableTwitter:Show();
			self.TwitterLoginButton:Show();
			TwitterData["linked"] = linked;
			if (linked) then
				TwitterData["screenName"] = "@" .. screenName;
			end
			Twitter_Update();
		end
	elseif ( event == "TWITTER_LINK_RESULT" ) then
		local linked, screenName, errorMsg = ...;
		SocialBrowserFrame:Hide();
		TwitterData["linked"] = linked;
		if (linked) then
			TwitterData["screenName"] = "@" .. screenName;
			UIErrorsFrame:AddMessage(SOCIAL_TWITTER_CONNECT_SUCCESS_MESSAGE, 1.0, 1.0, 0.0, 1.0);
		else
			UIErrorsFrame:AddMessage(SOCIAL_TWITTER_CONNECT_FAIL_MESSAGE, 1.0, 0.1, 0.1, 1.0);
		end
		Twitter_Update();
	end
end

function InterfaceOptionsSocialPanelChatStyle_OnEvent (self, event, ...)
	if ( event == "VARIABLES_LOADED" ) then
		self.cvar = "chatStyle";

		local value = GetCVar(self.cvar);
		self.defaultValue = GetCVarDefault(self.cvar);
		self.value = value;
		self.oldValue = value;
		self.tooltip = _G["OPTION_CHAT_STYLE_"..strupper(value)];

		UIDropDownMenu_SetWidth(self, 90);
		UIDropDownMenu_Initialize(self, InterfaceOptionsSocialPanelChatStyle_Initialize);
		UIDropDownMenu_SetSelectedValue(self, value);
		InterfaceOptionsSocialPanelChatStyle_SetChatStyle(value);

		self.SetValue =
			function (self, value)
				self.value = value;
				InterfaceOptionsSocialPanelChatStyle_SetChatStyle(value);
				self.tooltip = _G["OPTION_CHAT_STYLE_"..strupper(value)];
			end
		self.GetValue =
			function (self)
				return UIDropDownMenu_GetSelectedValue(self);
			end
		self.RefreshValue =
			function (self)
				UIDropDownMenu_Initialize(self, InterfaceOptionsSocialPanelChatStyle_Initialize);
				UIDropDownMenu_SetSelectedValue(self, self.value);
			end

		self:UnregisterEvent(event);
	end
end

function InterfaceOptionsSocialPanelChatStyle_OnClick(self)
	InterfaceOptionsSocialPanelChatStyle:SetValue(self.value);
end

function InterfaceOptionsSocialPanelChatStyle_Initialize()
	local selectedValue = UIDropDownMenu_GetSelectedValue(InterfaceOptionsSocialPanelChatStyle);
	local info = UIDropDownMenu_CreateInfo();

	info.text = IM_STYLE;
	info.func = InterfaceOptionsSocialPanelChatStyle_OnClick;
	info.value = "im";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end

	info.tooltipTitle = IM_STYLE;
	info.tooltipText = OPTION_CHAT_STYLE_IM;
	UIDropDownMenu_AddButton(info);

	info.text = CLASSIC_STYLE;
	info.func = InterfaceOptionsSocialPanelChatStyle_OnClick;
	info.value = "classic";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = CLASSIC_STYLE;
	info.tooltipText = OPTION_CHAT_STYLE_CLASSIC;
	UIDropDownMenu_AddButton(info);
end

function InterfaceOptionsSocialPanelChatStyle_SetChatStyle(chatStyle)
	SetCVar("chatStyle", chatStyle, "chatStyle");

	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName];
		ChatEdit_DeactivateChat(frame.editBox);
	end
	ChatEdit_ActivateChat(FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK).editBox);
	ChatEdit_DeactivateChat(FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK).editBox);

	UIDropDownMenu_SetSelectedValue(InterfaceOptionsSocialPanelChatStyle,chatStyle);
end

function InterfaceOptionsSocialPanelConversationMode_OnClick(self)
	self:GetParent().dropdown:SetValue(self.value);
end

function InterfaceOptionsSocialPanelConversationMode_Initialize(self)
	local selectedValue = UIDropDownMenu_GetSelectedValue(self);
	local info = UIDropDownMenu_CreateInfo();

	info.text = CONVERSATION_MODE_POPOUT;
	info.func = InterfaceOptionsSocialPanelConversationMode_OnClick;
	info.value = "popout";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end

	info.tooltipTitle = CONVERSATION_MODE_POPOUT;
	info.tooltipText = _G["OPTION_"..self.conversationType.."_MODE_POPOUT"];
	UIDropDownMenu_AddButton(info);

	info.text = CONVERSATION_MODE_INLINE;
	info.func = InterfaceOptionsSocialPanelConversationMode_OnClick;
	info.value = "inline";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = CONVERSATION_MODE_INLINE;
	info.tooltipText = _G["OPTION_"..self.conversationType.."_MODE_INLINE"];
	UIDropDownMenu_AddButton(info);

	info.text = CONVERSATION_MODE_POPOUT_AND_INLINE;
	info.func = InterfaceOptionsSocialPanelConversationMode_OnClick;
	info.value = "popout_and_inline";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = CONVERSATION_MODE_POPOUT_AND_INLINE;
	info.tooltipText = _G["OPTION_"..self.conversationType.."_MODE_POPOUT_AND_INLINE"];
	UIDropDownMenu_AddButton(info);
end

function InterfaceOptionsSocialPanelWhisperMode_OnEvent (self, event, ...)
	if ( event == "VARIABLES_LOADED" ) then
		self.cvar = "whisperMode";

		local value = GetCVar(self.cvar);
		self.defaultValue = GetCVarDefault(self.cvar);
		self.value = value;
		self.oldValue = value;
		self.tooltip = _G["OPTION_WHISPER_MODE_"..strupper(value)];
		self.conversationType = "WHISPER";

		UIDropDownMenu_SetWidth(self, 90);
		UIDropDownMenu_Initialize(self, InterfaceOptionsSocialPanelConversationMode_Initialize);
		UIDropDownMenu_SetSelectedValue(self, value);

		self.SetValue =
			function (self, value)
				self.value = value;
				SetCVar(self.cvar, self.value);
				self.tooltip = _G["OPTION_WHISPER_MODE_"..strupper(value)];
				UIDropDownMenu_SetSelectedValue(self, self.value);
			end
		self.GetValue =
			function (self)
				return UIDropDownMenu_GetSelectedValue(self);
			end
		self.RefreshValue =
			function (self)
				UIDropDownMenu_Initialize(self, InterfaceOptionsSocialPanelConversationMode_Initialize);
				UIDropDownMenu_SetSelectedValue(self, self.value);
			end

		self:UnregisterEvent(event);
	end
end


function InterfaceOptionsSocialPanelTimestamps_OnEvent (self, event, ...)
	if ( event == "VARIABLES_LOADED" ) then
		self.cvar = "showTimestamps";

		local value = GetCVar(self.cvar);
		if ( value == "none" ) then
			CHAT_TIMESTAMP_FORMAT = nil;
		else
			CHAT_TIMESTAMP_FORMAT = value;
		end
		self.defaultValue = GetCVarDefault(self.cvar);
		self.value = value;
		self.oldValue = value;
		self.tooltip = OPTION_TOOLTIP_TIMESTAMPS;

		UIDropDownMenu_SetWidth(self, 110);
		UIDropDownMenu_Initialize(self, InterfaceOptionsSocialPanelTimestamps_Initialize);
		UIDropDownMenu_SetSelectedValue(self, value);

		self.SetValue =
			function (self, value)
				self.value = value;
				SetCVar(self.cvar, self.value);
				if ( value == "none" ) then
					CHAT_TIMESTAMP_FORMAT = nil;
				else
					CHAT_TIMESTAMP_FORMAT = value;
				end
				UIDropDownMenu_SetSelectedValue(self, self.value);
			end
		self.GetValue =
			function (self)
				return UIDropDownMenu_GetSelectedValue(self);
			end
		self.RefreshValue =
			function (self)
				UIDropDownMenu_Initialize(self, InterfaceOptionsSocialPanelTimestamps_Initialize);
				UIDropDownMenu_SetSelectedValue(self, self.value);
			end

		self:UnregisterEvent(event);
	end
end

function InterfaceOptionsSocialPanelTimestamps_Initialize()
	local selectedValue = UIDropDownMenu_GetSelectedValue(InterfaceOptionsSocialPanelTimestamps);
	local info = UIDropDownMenu_CreateInfo();

	info.func = InterfaceOptionsSocialPanelTimestamps_OnClick;
	info.value = "none";
	info.text = TIMESTAMP_FORMAT_NONE;
	info.checked = info.value == selectedValue;
	UIDropDownMenu_AddButton(info);

	InterfaceOptionsSocialPanelTimestamps_AddTimestampFormat(TIMESTAMP_FORMAT_HHMM, info, selectedValue);
	InterfaceOptionsSocialPanelTimestamps_AddTimestampFormat(TIMESTAMP_FORMAT_HHMMSS, info, selectedValue);
	InterfaceOptionsSocialPanelTimestamps_AddTimestampFormat(TIMESTAMP_FORMAT_HHMM_AMPM, info, selectedValue);
	InterfaceOptionsSocialPanelTimestamps_AddTimestampFormat(TIMESTAMP_FORMAT_HHMMSS_AMPM, info, selectedValue);
	InterfaceOptionsSocialPanelTimestamps_AddTimestampFormat(TIMESTAMP_FORMAT_HHMM_24HR, info, selectedValue);
	InterfaceOptionsSocialPanelTimestamps_AddTimestampFormat(TIMESTAMP_FORMAT_HHMMSS_24HR, info, selectedValue);
end

local exampleTime = {
	year = 2010,
	month = 12,
	day = 15,
	hour = 15,
	min = 27,
	sec = 32,
}

function InterfaceOptionsSocialPanelTimestamps_AddTimestampFormat(timestampFormat, infoTable, selectedValue)
	assert(infoTable);
	infoTable.func = InterfaceOptionsSocialPanelTimestamps_OnClick;
	infoTable.value = timestampFormat;
	infoTable.text = BetterDate(timestampFormat, time(exampleTime));
	infoTable.checked = (selectedValue == timestampFormat);
	UIDropDownMenu_AddButton(infoTable);
end

function InterfaceOptionsSocialPanelTimestamps_OnClick(self)
	InterfaceOptionsSocialPanelTimestamps:SetValue(self.value);
end

-- [[ Twitter options ]] --

function Twitter_GetLoginStatus()
	local statusText = (GRAY_FONT_COLOR_CODE .. SOCIAL_TWITTER_STATUS_NOT_CONNECTED .. FONT_COLOR_CODE_CLOSE);
	if (TwitterData["linked"]) then
		statusText = (GREEN_FONT_COLOR_CODE .. format(SOCIAL_TWITTER_STATUS_CONNECTED, TwitterData["screenName"]) .. FONT_COLOR_CODE_CLOSE);
	end
	return TwitterData["linked"], statusText;
end

function Twitter_SetEnabled(value)
	local enabled = (value == "1");
	InterfaceOptionsSocialPanel.TwitterLoginButton:SetEnabled(enabled);
end

function Twitter_Update()
	local linked, statusText = Twitter_GetLoginStatus();
	local panel = InterfaceOptionsSocialPanel;

	if (linked) then
		panel.TwitterLoginButton:SetText(SOCIAL_TWITTER_DISCONNECT);
	else
		panel.TwitterLoginButton:SetText(SOCIAL_TWITTER_SIGN_IN);
	end
	panel.TwitterLoginButton:SetWidth(panel.TwitterLoginButton:GetTextWidth() + 30);

	panel.EnableTwitter.LoginStatus:SetText(statusText);
end

function Twitter_LoginButton_OnClick(self)
	if (TwitterData["linked"]) then
		C_Social.TwitterDisconnect();
	else
		SocialBrowserFrame:Show();
		C_Social.TwitterConnect();
	end
	Twitter_Update();
end

-- [[ ActionBars Options Panel ]] --

ActionBarsPanelOptions = {
	bottomLeftActionBar = { text = "SHOW_MULTIBAR1_TEXT", default = "0" },
	bottomRightActionBar = { text = "SHOW_MULTIBAR2_TEXT", default = "0" },
	rightActionBar = { text = "SHOW_MULTIBAR3_TEXT", default = "0" },
	rightTwoActionBar = { text = "SHOW_MULTIBAR4_TEXT", default = "0" },
	multiBarRightVerticalLayout = { text = "STACK_RIGHT_BARS", default = "0" },
	lockActionBars = { text = "LOCK_ACTIONBAR_TEXT" },
	alwaysShowActionBars = { text = "ALWAYS_SHOW_MULTIBARS_TEXT" },
	countdownForCooldowns = { text = "COUNTDOWN_FOR_COOLDOWNS_TEXT" },
}

function InterfaceOptionsActionBarsPanel_OnLoad (self)
	self.name = ACTIONBARS_LABEL;
	self.options = ActionBarsPanelOptions;
	InterfaceOptionsPanel_OnLoad(self);

	self:SetScript("OnEvent", InterfaceOptionsActionBarsPanel_OnEvent);
	UIDropDownMenu_SetSelectedValue(InterfaceOptionsActionBarsPanelPickupActionKeyDropDown, GetModifiedClick("PICKUPACTION"));
	UIDropDownMenu_EnableDropDown(InterfaceOptionsActionBarsPanelPickupActionKeyDropDown);
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

	SetActionBarToggles(not not SHOW_MULTI_ACTIONBAR_1, not not SHOW_MULTI_ACTIONBAR_2, not not SHOW_MULTI_ACTIONBAR_3, not not SHOW_MULTI_ACTIONBAR_4, not not ALWAYS_SHOW_MULTIBARS);
	MultiActionBar_Update();
	UIParent_ManageFramePositions();
end

function InterfaceOptionsActionBarsPanelPickupActionKeyDropDown_OnEvent (self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self.defaultValue = "SHIFT";
		self.oldValue = GetModifiedClick("PICKUPACTION");
		self.value = self.oldValue or self.defaultValue;
		self.tooltip = _G["OPTION_TOOLTIP_PICKUP_ACTION_"..self.value.."_KEY"];

		UIDropDownMenu_SetWidth(self, 90);
		UIDropDownMenu_Initialize(self, InterfaceOptionsActionBarsPanelPickupActionKeyDropDown_Initialize);
		UIDropDownMenu_SetSelectedValue(self, self.value);

		self.SetValue =
			function (self, value)
				self.value = value;
				UIDropDownMenu_SetSelectedValue(self, value);
				SetModifiedClick("PICKUPACTION", value);
				AttemptToSaveBindings(GetCurrentBindingSet());
				self.tooltip = _G["OPTION_TOOLTIP_PICKUP_ACTION_"..value.."_KEY"];
			end
		self.GetValue =
			function (self)
				return UIDropDownMenu_GetSelectedValue(self);
			end
		self.RefreshValue =
			function (self)
				UIDropDownMenu_Initialize(self, InterfaceOptionsActionBarsPanelPickupActionKeyDropDown_Initialize);
				UIDropDownMenu_SetSelectedValue(self, self.value);
			end

		self:UnregisterEvent("PLAYER_ENTERING_WORLD");
	end
end

function InterfaceOptionsActionBarsPanelPickupActionKeyDropDown_OnClick(self)
	InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetValue(self.value);
end

function InterfaceOptionsActionBarsPanelPickupActionKeyDropDown_Initialize()
	local selectedValue = UIDropDownMenu_GetSelectedValue(InterfaceOptionsActionBarsPanelPickupActionKeyDropDown);
	local info = UIDropDownMenu_CreateInfo();

	info.text = ALT_KEY;
	info.func = InterfaceOptionsActionBarsPanelPickupActionKeyDropDown_OnClick;
	info.value = "ALT";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = ALT_KEY;
	info.tooltipText = OPTION_TOOLTIP_PICKUP_ACTION_ALT_KEY;
	UIDropDownMenu_AddButton(info);

	info.text = CTRL_KEY;
	info.func = InterfaceOptionsActionBarsPanelPickupActionKeyDropDown_OnClick;
	info.value = "CTRL";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = CTRL_KEY;
	info.tooltipText = OPTION_TOOLTIP_PICKUP_ACTION_CTRL_KEY;
	UIDropDownMenu_AddButton(info);

	info.text = SHIFT_KEY;
	info.func = InterfaceOptionsActionBarsPanelPickupActionKeyDropDown_OnClick;
	info.value = "SHIFT";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = SHIFT_KEY;
	info.tooltipText = OPTION_TOOLTIP_PICKUP_ACTION_SHIFT_KEY;
	UIDropDownMenu_AddButton(info);

	info.text = NONE_KEY;
	info.func = InterfaceOptionsActionBarsPanelPickupActionKeyDropDown_OnClick;
	info.value = "NONE";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = NONE_KEY;
	info.tooltipText = OPTION_TOOLTIP_PICKUP_ACTION_NONE_KEY;
	UIDropDownMenu_AddButton(info);
end

-- [[ Names Options Panel ]] --

NamePanelOptions = {
	UnitNameOwn = { text = "UNIT_NAME_OWN" },
	UnitNameNPC = { text = "UNIT_NAME_NPC" },
	UnitNamePlayerGuild = { text = "UNIT_NAME_GUILD" },
	UnitNamePlayerPVPTitle = { text = "UNIT_NAME_PLAYER_TITLE" },
	UnitNameNonCombatCreatureName = { text = "UNIT_NAME_NONCOMBAT_CREATURE" },

	UnitNameFriendlyPlayerName = { text = "UNIT_NAME_FRIENDLY" },
	UnitNameFriendlyMinionName = { text = "UNIT_NAME_FRIENDLY_MINIONS" },

	UnitNameEnemyPlayerName = { text = "UNIT_NAME_ENEMY" },
	UnitNameEnemyMinionName = { text = "UNIT_NAME_ENEMY_MINIONS" },

	nameplateShowFriends = { text = "UNIT_NAMEPLATES_SHOW_FRIENDS" },
	nameplateShowFriendlyMinions = { text = "UNIT_NAMEPLATES_SHOW_FRIENDLY_MINIONS" },
	nameplateShowEnemies = { text = "UNIT_NAMEPLATES_SHOW_ENEMIES" },
	nameplateShowEnemyMinions = { text = "UNIT_NAMEPLATES_SHOW_ENEMY_MINIONS" },
	nameplateShowEnemyMinus = { text = "UNIT_NAMEPLATES_SHOW_ENEMY_MINUS" },

	nameplateShowAll = { text = "UNIT_NAMEPLATES_AUTOMODE" },
}

-- Namplate Motion Dropdown ---

function InterfaceOptionsNameplateMotionDropDown_OnEvent (self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		local value = tonumber(GetCVar("nameplateMotion"));
		self.tooltip = _G["UNIT_NAMEPLATES_TYPE_TOOLTIP_"..(value + 1)];

		self.defaultValue = 0;
		self.oldValue = value;
		self.value = value;

		UIDropDownMenu_SetWidth(self, 150);
		UIDropDownMenu_Initialize(self, InterfaceOptionsNameplateMotionDropDown_Initialize);
		UIDropDownMenu_SetSelectedValue(self, value);

		self.SetValue =
			function (self, value)
				self.value = value;
				UIDropDownMenu_SetSelectedValue(self, value);
				SetCVar("nameplateMotion", value);
				self.tooltip = _G["UNIT_NAMEPLATES_TYPE_TOOLTIP_"..(value + 1)];
			end;
		self.GetValue =
			function (self)
				return UIDropDownMenu_GetSelectedValue(self);
			end
		self.RefreshValue =
			function (self)
				UIDropDownMenu_Initialize(self, InterfaceOptionsNameplateMotionDropDown_Initialize);
				UIDropDownMenu_SetSelectedValue(self, self.value);
			end
	end
end

function InterfaceOptionsNameplateMotionDropDown_OnClick(self)
	InterfaceOptionsNamesPanelUnitNameplatesMotionDropDown:SetValue(self.value);
end

function InterfaceOptionsNameplateMotionDropDown_Initialize(self)
	local selectedValue = UIDropDownMenu_GetSelectedValue(self);
	local info = UIDropDownMenu_CreateInfo();

	local numTypes = C_NamePlate.GetNumNamePlateMotionTypes();
	for i=1, numTypes do
		info.text = _G["UNIT_NAMEPLATES_TYPE_"..i];
		info.func = InterfaceOptionsNameplateMotionDropDown_OnClick;
		info.value = i - 1;
		info.checked = selectedValue and i == selectedValue + 1;
		info.tooltipTitle = _G["UNIT_NAMEPLATES_TYPE_"..i];
		info.tooltipText = _G["UNIT_NAMEPLATES_TYPE_TOOLTIP_"..i];
		UIDropDownMenu_AddButton(info);
	end
end

function InterfaceOptionsNameplateFriends_OnEnter(self)
	local text = GetBindingKey("FRIENDNAMEPLATES");
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
	if (text and (text ~= "")) then
		GameTooltip:SetText(OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_FRIENDS..NORMAL_FONT_COLOR_CODE.." ("..text..")", 1, 1, 1, 1, true);
	else
		GameTooltip:SetText(KEYBIND_NOT_SET_TOOLTIP, 1, 1, 1, 1, true);
	end
end

function InterfaceOptionsNameplateFriends_OnLeave(self)
	GameTooltip:Hide();
end

function InterfaceOptionsNameplateEnemies_OnEnter(self)
	local text = GetBindingKey("NAMEPLATES");
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT");
	if (text and (text ~= "")) then
		GameTooltip:SetText(OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_ENEMIES..NORMAL_FONT_COLOR_CODE.." ("..text..")", 1, 1, 1, 1, true);
	else
		GameTooltip:SetText(KEYBIND_NOT_SET_TOOLTIP, 1, 1, 1, 1, true);
	end
end

function InterfaceOptionsNameplateEnemies_OnLeave(self)
	GameTooltip:Hide();
end

-- [[ Status Text Options Panel ]] --

StatusTextPanelOptions = {
	xpBarText = { text = "XP_BAR_TEXT" },
	playerStatusText = { text = "STATUS_TEXT_PLAYER" },
	petStatusText = { text = "STATUS_TEXT_PET" },
	partyStatusText = { text = "STATUS_TEXT_PARTY" },
	targetStatusText = { text = "STATUS_TEXT_TARGET" },
	alternateResourceText = { text = "ALTERNATE_RESOURCE_TEXT" },
}

function InterfaceOptionsStatusTextDisplayDropDown_OnEvent (self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self.cvar = "statusTextDisplay";
        self.otherCvar = "statusText";
		local value = GetCVar(self.cvar);
		self.defaultValue = GetCVarDefault(self.cvar);
		self.oldValue = value;
		self.value = value;
		self.tooltip = OPTION_TOOLTIP_STATUS_TEXT_DISPLAY;

		UIDropDownMenu_SetWidth(self, 110);
		UIDropDownMenu_Initialize(self, InterfaceOptionsStatusTextDisplayDropDown_Initialize);
		UIDropDownMenu_SetSelectedValue(self, value);

		self.SetValue =
			function (self, value)
				self.value = value;
                if (value ~= "NONE") then
                    SetCVar(self.otherCvar, "1");
                else
                    SetCVar(self.otherCvar, "0");
                end
				SetCVar(self.cvar, value, self.event);
				UIDropDownMenu_SetSelectedValue(self, value);
			end;
		self.GetValue =
			function (self)
				return UIDropDownMenu_GetSelectedValue(self);
			end
		self.RefreshValue =
			function (self)
				UIDropDownMenu_Initialize(self, InterfaceOptionsStatusTextDisplayDropDown_Initialize);
				UIDropDownMenu_SetSelectedValue(self, self.value);
			end
	end
end

function InterfaceOptionsStatusTextDisplayDropDown_OnClick(self)
	InterfaceOptionsDisplayPanelDisplayDropDown:SetValue(self.value);
end

function InterfaceOptionsStatusTextDisplayDropDown_Initialize(self)
	local selectedValue = UIDropDownMenu_GetSelectedValue(self);
	local info = UIDropDownMenu_CreateInfo();

	info.text = STATUS_TEXT_VALUE;
	info.func = InterfaceOptionsStatusTextDisplayDropDown_OnClick;
	info.value = "NUMERIC";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = STATUS_TEXT_VALUE;
	info.tooltipText = OPTION_TOOLTIP_STATUS_TEXT_DISPLAY;
	UIDropDownMenu_AddButton(info);

	info.text = STATUS_TEXT_PERCENT;
	info.func = InterfaceOptionsStatusTextDisplayDropDown_OnClick;
	info.value = "PERCENT";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = STATUS_TEXT_PERCENT;
	info.tooltipText = OPTION_TOOLTIP_STATUS_TEXT_DISPLAY;
	UIDropDownMenu_AddButton(info);

	info.text = STATUS_TEXT_BOTH;
	info.func = InterfaceOptionsStatusTextDisplayDropDown_OnClick;
	info.value = "BOTH";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = STATUS_TEXT_BOTH;
	info.tooltipText = OPTION_TOOLTIP_STATUS_TEXT_DISPLAY;
	UIDropDownMenu_AddButton(info);

    info.text = NONE;
    info.func = InterfaceOptionsStatusTextDisplayDropDown_OnClick;
    info.value = "NONE";
    if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
    UIDropDownMenu_AddButton(info);
end

-- [[ UnitFrame Options Panel ]] --

UnitFramePanelOptions = {
	showPartyBackground = { text = "SHOW_PARTY_BACKGROUND_TEXT" },
	showPartyPets = { text = "SHOW_PARTY_PETS_TEXT" },
	showArenaEnemyFrames = { text = "SHOW_ARENA_ENEMY_FRAMES_TEXT" },
	showArenaEnemyCastbar = { text = "SHOW_ARENA_ENEMY_CASTBAR_TEXT" },
	showArenaEnemyPets = { text = "SHOW_ARENA_ENEMY_PETS_TEXT" },
	fullSizeFocusFrame = { text = "FULL_SIZE_FOCUS_FRAME_TEXT" },
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

function BlizzardOptionsPanel_UpdateDebuffFrames()
	local frame;
	-- Target frame and its target-of-target
	frame = TargetFrame;
	TargetFrame_UpdateAuras(frame);
	TargetofTarget_Update(frame.totFrame);
	-- Focus frame and its target-of-target
	frame = FocusFrame;
	TargetFrame_UpdateAuras(frame);
	TargetofTarget_Update(frame.totFrame);
	-- Party frames and their pets
	for i = 1, MAX_PARTY_MEMBERS do
		if ( UnitExists("party"..i) ) then
			frame = _G["PartyMemberFrame"..i];
			PartyMemberFrame_UpdateMember(frame);
			PartyMemberFrame_UpdatePet(frame);
		end
	end
	-- own pet
	PetFrame_Update(PetFrame);
end

-- [[ Camera Options Panel ]] --

CameraPanelOptions = {
	cameraWaterCollision = { text = "WATER_COLLISION" },
	cameraYawSmoothSpeed = { text = "AUTO_FOLLOW_SPEED", minValue = 90, maxValue = 270, valueStep = 10 },
	cameraDistanceMaxZoomFactor = { text = "MAX_FOLLOW_DIST", minValue = 1, maxValue = 2, valueStep = .1 },
	cameraTerrainTilt = { text = "FOLLOW_TERRAIN" },
	cameraBobbing = { text = "HEAD_BOB" },
	cameraPivot = { text = "SMART_PIVOT" },
}

function InterfaceOptionsCameraPanel_OnLoad (self)
	self.name = CAMERA_LABEL;
	self.options = CameraPanelOptions;
	InterfaceOptionsPanel_OnLoad(self)
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

		UIDropDownMenu_SetWidth(self, 180);
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
				else
					self.tooltip = _G["OPTION_TOOLTIP_CAMERA"..value];
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

	info.text = CAMERA_SMARTER;
	info.func = InterfaceOptionsCameraPanelStyleDropDown_OnClick;
	info.value = "4";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = CAMERA_SMARTER;
	info.tooltipText = OPTION_TOOLTIP_CAMERA_SMARTER;
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
	enableMouseSpeed = { text = "ENABLE_MOUSE_SPEED" },
	mouseInvertPitch = { text = "INVERT_MOUSE" },
	autointeract = { text = "CLICK_TO_MOVE" },
	mouseSpeed = { text = "MOUSE_SENSITIVITY", minValue = 0.5, maxValue = 1.5, valueStep = 0.05 },
	cameraYawMoveSpeed = { text = "MOUSE_LOOK_SPEED", minValue = 90, maxValue = 270, valueStep = 10 },
	ClipCursor = { text = "LOCK_CURSOR" },
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
			self.tooltip = OPTION_TOOLTIP_CAMERA3;
		else
			self.tooltip = _G["OPTION_TOOLTIP_CAMERA"..value];
		end

		UIDropDownMenu_SetWidth(self, 180);
		UIDropDownMenu_Initialize(self, InterfaceOptionsMousePanelClickMoveStyleDropDown_Initialize);
		UIDropDownMenu_SetSelectedValue(self, value);

		self.SetValue =
			function (self, value)
				self.value = value;
				SetCVar(self.cvar, value, self.event);
				UIDropDownMenu_SetSelectedValue(self, value);
				if ( value == "0" ) then
					--For the purposes of tooltips and dropdown lists, "0" in the CVar cameraSmoothTrackingStyle is "3".
					self.tooltip = OPTION_TOOLTIP_CAMERA3;
				else
					self.tooltip = _G["OPTION_TOOLTIP_CAMERA"..value];
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
	info.tooltipText = OPTION_TOOLTIP_CAMERA_SMART;
	UIDropDownMenu_AddButton(info);

	info.text = CAMERA_SMARTER;
	info.func = InterfaceOptionsMousePanelClickMoveStyleDropDown_OnClick;
	info.value = "4";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = CAMERA_SMARTER;
	info.tooltipText = OPTION_TOOLTIP_CAMERA_SMARTER;
	UIDropDownMenu_AddButton(info);

	info.text = CAMERA_ALWAYS;
	info.func = InterfaceOptionsMousePanelClickMoveStyleDropDown_OnClick;
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
	info.func = InterfaceOptionsMousePanelClickMoveStyleDropDown_OnClick;
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

-- [[ Accessibility Options Panel ]] --

AccessibilityPanelOptions = {
	enableMovePad = { text = "MOVE_PAD" },
    movieSubtitle = { text = "CINEMATIC_SUBTITLES" },
	colorblindMode = { text = "USE_COLORBLIND_MODE" },
	colorblindWeaknessFactor = { text = "ADJUST_COLORBLIND_STRENGTH", minValue = 0.05, maxValue = 1.0, valueStep = 0.05 },
	colorblindSimulator = { text = "COLORBLIND_FILTER" },
}

function InterfaceOptionsAccessibilityPanel_OnLoad(self)
	self.name = ACCESSIBILITY_LABEL;
	self.options = AccessibilityPanelOptions;
	InterfaceOptionsPanel_OnLoad(self);

	self:SetScript("OnEvent", InterfaceOptionsAccessibilityPanel_OnEvent);
end

function InterfaceOptionsAccessibilityPanel_OnEvent(self, event, ...)
	BlizzardOptionsPanel_OnEvent(self, event, ...);
end

function InterfaceOptionsAccessibilityPanelColorFilterDropDown_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self.cvar = "colorblindSimulator";

		local value = BlizzardOptionsPanel_GetCVarSafe(self.cvar);
		self.defaultValue = GetCVarDefault(self.cvar);
		self.value = value;
		self.oldValue = value;

		UIDropDownMenu_SetWidth(self, 130);
		UIDropDownMenu_Initialize(self,InterfaceOptionsAccessibilityPanelColorFilterDropDown_Initialize);
		UIDropDownMenu_SetSelectedValue(self, value);

		function self:SetValue(value)
			self.value = value;
			BlizzardOptionsPanel_SetCVarSafe(self.cvar, value);
			UIDropDownMenu_SetSelectedValue(self, value);

			if self.value == 0 then
				InterfaceOptionsAccessibilityPanelColorblindStrengthSlider:Disable();
			else
				InterfaceOptionsAccessibilityPanelColorblindStrengthSlider:Enable();
			end
		end

		function self:GetValue()
			return UIDropDownMenu_GetSelectedValue(self);
		end

		function self:RefreshValue()
			UIDropDownMenu_Initialize(self, InterfaceOptionsAccessibilityPanelColorFilterDropDown_Initialize);
			UIDropDownMenu_SetSelectedValue(self, self.value);
		end

		self:UnregisterEvent(event);

		-- create and set colorblind item quality display string
		local self = InterfaceOptionsAccessibilityPanel;
		local qualityIdTable = {2,3,4,5}; -- UNCOMMON, RARE, EPIC, LEGENDARY
		local examples = self.ColorblindFilterExamples;
		for i = 1, #qualityIdTable do
			local fontstring = examples.ItemQuality[i];
			if ( not fontstring ) then
				fontstring = examples:CreateFontString(nil, "ARTWORK", "ColorblindItemQualityTemplate");
				fontstring:SetPoint("TOPLEFT", examples.ItemQuality[i-1], "TOPRIGHT", 8, 0);
			end

			local qualityId = qualityIdTable[i];
			fontstring:SetText(_G["ITEM_QUALITY"..qualityId.."_DESC"]);
			local color = ITEM_QUALITY_COLORS[qualityId];
			fontstring:SetTextColor(color.r, color.g, color.b);
		end
	end
end

function InterfaceOptionsAccessibilityPanelColorFilterDropDown_Initialize()
	local selectedValue = UIDropDownMenu_GetSelectedValue(InterfaceOptionsAccessibilityPanelColorFilterDropDown);
	local info = UIDropDownMenu_CreateInfo();

	info.func = InterfaceOptionsAccessibilityPanelColorFilterDropDown_OnClick;

	info.text = COLORBLIND_OPTION_NONE;
	info.value = 0;
	info.checked = info.value == selectedValue;
	UIDropDownMenu_AddButton(info);

	info.text = COLORBLIND_OPTION_PROTANOPIA;
	info.value = 1;
	info.checked = info.value == selectedValue;
	UIDropDownMenu_AddButton(info);

	info.text = COLORBLIND_OPTION_DEUTERANOPIA;
	info.value = 2;
	info.checked = info.value == selectedValue;
	UIDropDownMenu_AddButton(info);

	info.text = COLORBLIND_OPTION_TRITANOPIA;
	info.value = 3;
	info.checked = info.value == selectedValue;
	UIDropDownMenu_AddButton(info);
end

function InterfaceOptionsAccessibilityPanelColorFilterDropDown_OnClick(self)
	InterfaceOptionsAccessibilityPanelColorFilterDropDown:SetValue(self.value);
end

function InterfaceOptions_CombatTextComboPoints(combatTextEnabled)
	if ( combatTextEnabled == "1" ) then
		local class = select(2, UnitClass("player"));
		if ( class ~= "ROGUE" and class ~= "DRUID" ) then
			BlizzardOptionsPanel_CheckButton_Disable(InterfaceOptionsCombatPanelCombatTextComboPoints);
		else
			BlizzardOptionsPanel_CheckButton_Enable(InterfaceOptionsCombatPanelCombatTextComboPoints, true);
		end
	else
		BlizzardOptionsPanel_CheckButton_Disable(InterfaceOptionsCombatPanelCombatTextComboPoints);
	end
end