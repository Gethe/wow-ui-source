UIOptionsFrameCheckButtons = { };
UIOptionsFrameCheckButtons["INVERT_MOUSE"] = { index = 1, cvar = "mouseInvertPitch" , tooltipText = OPTION_TOOLTIP_INVERT_MOUSE};
UIOptionsFrameCheckButtons["STATUS_BAR_TEXT"] = { index = 2, cvar = "statusBarText" , tooltipText = OPTION_TOOLTIP_STATUS_BAR_TEXT};
UIOptionsFrameCheckButtons["ASSIST_ATTACK"] = { index = 3, cvar = "assistAttack" , tooltipText = OPTION_TOOLTIP_ASSIST_ATTACK};
UIOptionsFrameCheckButtons["PROFANITY_FILTER"] = { index = 5, cvar = "profanityFilter" , tooltipText = OPTION_TOOLTIP_PROFANITY_FILTER};
UIOptionsFrameCheckButtons["CLICK_TO_MOVE"] = { index = 6, cvar = "autointeract" , tooltipText = OPTION_TOOLTIP_CLICK_TO_MOVE};
UIOptionsFrameCheckButtons["SIMPLE_CHAT_TEXT"] = { index = 7, uvar = "SIMPLE_CHAT" , tooltipText = OPTION_TOOLTIP_SIMPLE_CHAT};
UIOptionsFrameCheckButtons["CHAT_LOCKED_TEXT"] = { index = 8, uvar = "CHAT_LOCKED" , tooltipText = OPTION_TOOLTIP_CHAT_LOCKED};
UIOptionsFrameCheckButtons["SHOW_PET_MELEE_DAMAGE"] = { index = 9, cvar = "PetMeleeDamage" , tooltipText = OPTION_TOOLTIP_PET_MELEE_DAMAGE };
UIOptionsFrameCheckButtons["LOG_PERIODIC_EFFECTS"] = { index = 11, cvar = "CombatLogPeriodicSpells" , tooltipText = OPTION_TOOLTIP_PERIODIC_EFFECTS};
UIOptionsFrameCheckButtons["USE_UBERTOOLTIPS"] = { index = 12, cvar = "UberTooltips" , tooltipText = OPTION_TOOLTIP_UBERTOOLTIPS};
UIOptionsFrameCheckButtons["GUILDMEMBER_ALERT"] = { index = 13, cvar = "guildMemberNotify" , tooltipText = OPTION_TOOLTIP_GUILDMEMBER_ALERT};
UIOptionsFrameCheckButtons["BLOCK_TRADES"] = { index = 14, cvar = "BlockTrades" , tooltipText = OPTION_TOOLTIP_BLOCK_TRADES};
UIOptionsFrameCheckButtons["SMART_PIVOT"] = { index = 15, cvar = "cameraPivot" , tooltipText = OPTION_TOOLTIP_CAMERA_MODE};
UIOptionsFrameCheckButtons["CLEAR_AFK"] = { index = 16, cvar = "autoClearAFK" , tooltipText = OPTION_TOOLTIP_CLEAR_AFK};
UIOptionsFrameCheckButtons["SHOW_PET_NAMEPLATES"] = { index = 17, cvar = "PetNamePlates", tooltipText = OPTION_TOOLTIP_PET_NAMEPLATES};
UIOptionsFrameCheckButtons["REMOVE_CHAT_DELAY_TEXT"] = { index = 18, uvar = "REMOVE_CHAT_DELAY", tooltipText = OPTION_TOOLTIP_REMOVE_CHAT_DELAY};
UIOptionsFrameCheckButtons["SHOW_DAMAGE_TEXT"] = { index = 19, cvar = "CombatDamage", tooltipText = OPTION_TOOLTIP_SHOW_DAMAGE};
UIOptionsFrameCheckButtons["SHOW_NPC_NAMES"] = { index = 20, cvar = "UnitNameNPC", tooltipText = OPTION_TOOLTIP_SHOW_NPC_NAMES};
UIOptionsFrameCheckButtons["SHOW_PLAYER_NAMES"] = { index = 21, cvar = "UnitNamePlayer", tooltipText = OPTION_TOOLTIP_SHOW_PLAYER_NAMES};
UIOptionsFrameCheckButtons["SHOW_GUILD_NAMES"] = { index = 22, cvar = "UnitNamePlayerGuild", tooltipText = OPTION_TOOLTIP_SHOW_GUILD_NAMES};
UIOptionsFrameCheckButtons["SHOW_PLAYER_TITLES"] = { index = 23, cvar = "UnitNamePlayerPVPTitle", tooltipText = OPTION_TOOLTIP_SHOW_PLAYER_TITLES};
UIOptionsFrameCheckButtons["FOLLOW_TERRAIN"] = { index = 24, cvar = "cameraTerrainTilt", tooltipText = OPTION_TOOLTIP_FOLLOW_TERRAIN};
UIOptionsFrameCheckButtons["HEAD_BOB"] = { index = 26, cvar = "cameraBobbing", tooltipText = OPTION_TOOLTIP_HEAD_BOB};
UIOptionsFrameCheckButtons["WATER_COLLISION"] = { index = 27, cvar = "cameraWaterCollision", tooltipText = OPTION_TOOLTIP_WATER_COLLISION};
UIOptionsFrameCheckButtons["SHOW_TUTORIALS"] = { index = 28, tooltipText = OPTION_TOOLTIP_SHOW_TUTORIALS};
UIOptionsFrameCheckButtons["SHOW_NEWBIE_TIPS_TEXT"] = { index = 29, uvar = "SHOW_NEWBIE_TIPS", tooltipText = OPTION_TOOLTIP_SHOW_NEWBIE_TIPS};
UIOptionsFrameCheckButtons["SHOW_CLOAK"] = { index = 30, func = ShowingCloak, setFunc = ShowCloak , tooltipText = OPTION_TOOLTIP_SHOW_CLOAK};
UIOptionsFrameCheckButtons["SHOW_HELM"] = { index = 31, func = ShowingHelm , setFunc = ShowHelm, tooltipText = OPTION_TOOLTIP_SHOW_HELM};
UIOptionsFrameCheckButtons["LOCK_ACTIONBAR_TEXT"] = { index = 32, uvar="LOCK_ACTIONBAR", tooltipText = OPTION_TOOLTIP_LOCK_ACTIONBAR};
UIOptionsFrameCheckButtons["SHOW_MULTIBAR1_TEXT"] = { index = 33, func = MultiBar1_IsVisible, setFunc = Multibar_EmptyFunc, tooltipText = OPTION_TOOLTIP_SHOW_MULTIBAR1};
UIOptionsFrameCheckButtons["SHOW_MULTIBAR2_TEXT"] = { index = 34, func = MultiBar2_IsVisible, setFunc = Multibar_EmptyFunc, tooltipText = OPTION_TOOLTIP_SHOW_MULTIBAR2};
UIOptionsFrameCheckButtons["SHOW_MULTIBAR3_TEXT"] = { index = 35, func = MultiBar3_IsVisible, setFunc = Multibar_EmptyFunc, tooltipText = OPTION_TOOLTIP_SHOW_MULTIBAR3};
UIOptionsFrameCheckButtons["SHOW_MULTIBAR4_TEXT"] = { index = 36, func = MultiBar4_IsVisible, setFunc = Multibar_EmptyFunc, tooltipText = OPTION_TOOLTIP_SHOW_MULTIBAR4};
UIOptionsFrameCheckButtons["CHAT_BUBBLES_TEXT"] = { index = 37, cvar = "ChatBubbles", tooltipText = OPTION_TOOLTIP_CHAT_BUBBLES_TEXT};
UIOptionsFrameCheckButtons["PARTY_CHAT_BUBBLES_TEXT"] = { index = 38, cvar = "ChatBubblesParty", tooltipText = OPTION_TOOLTIP_PARTY_CHAT_BUBBLES_TEXT};
UIOptionsFrameCheckButtons["SHOW_BUFF_DURATION_TEXT"] = { index = 39, uvar = "SHOW_BUFF_DURATIONS", tooltipText = OPTION_TOOLTIP_SHOW_BUFF_DURATION};
UIOptionsFrameCheckButtons["ALWAYS_SHOW_MULTIBARS_TEXT"] = { index = 40, uvar = "ALWAYS_SHOW_MULTIBARS", tooltipText = OPTION_TOOLTIP_ALWAYS_SHOW_MULTIBARS};
UIOptionsFrameCheckButtons["SHOW_PARTY_PETS_TEXT"] = { index = 41, uvar = "SHOW_PARTY_PETS", tooltipText = OPTION_TOOLTIP_SHOW_PARTY_PETS};
UIOptionsFrameCheckButtons["SHOW_QUEST_FADING_TEXT"] = { index = 42, uvar = "QUEST_FADING_DISABLE", tooltipText = OPTION_TOOLTIP_SHOW_QUEST_FADING};

UIOptionsFrameSliders = {
	{ text = MOUSE_SENSITIVITY, cvar = "mousespeed", minValue = 0.5, maxValue = 1.5, valueStep = 0.05 , tooltipText = OPTION_TOOLTIP_MOUSE_SENSITIVITY},
	{ text = AUTO_FOLLOW_SPEED, cvar = "cameraYawSmoothSpeed", minValue = 90, maxValue = 270, valueStep = 10 , tooltipText = OPTION_TOOLTIP_AUTO_FOLLOW_SPEED},
	{ text = MOUSE_LOOK_SPEED, cvar = "cameraYawMoveSpeed", minValue = 90, maxValue = 270, valueStep = 10 , tooltipText = OPTION_TOOLTIP_MOUSE_LOOK_SPEED},
	{ text = MAX_FOLLOW_DIST, cvar = "cameraDistanceMaxFactor", minValue = 1, maxValue = 2, valueStep = 0.1 , tooltipText = OPTION_TOOLTIP_MAX_FOLLOW_DIST},
};

function UIOptionsFrame_Init()
	SIMPLE_CHAT = "0";
	RegisterForSave("SIMPLE_CHAT");
	CHAT_LOCKED = "0"
	RegisterForSave("CHAT_LOCKED");
	REMOVE_CHAT_DELAY = "0";
	RegisterForSave("REMOVE_CHAT_DELAY");
	SHOW_NEWBIE_TIPS = "1";
	RegisterForSave("SHOW_NEWBIE_TIPS");
	LOCK_ACTIONBAR = "0";
	RegisterForSave("LOCK_ACTIONBAR");
	SHOW_BUFF_DURATIONS = "0";
	RegisterForSave("SHOW_BUFF_DURATIONS");
	ALWAYS_SHOW_MULTIBARS = "0";
	RegisterForSave("ALWAYS_SHOW_MULTIBARS");
	SHOW_PARTY_PETS = "1";
	RegisterForSave("SHOW_PARTY_PETS");
	QUEST_FADING_DISABLE = "0";
	RegisterForSave("QUEST_FADING_DISABLE");
	UIOptionsFrameCheckButtons["STATUS_BAR_TEXT"].value = GetCVar("statusBarText");
	this:RegisterEvent("CVAR_UPDATE");
end

function UIOptionsFrame_OnEvent()
	if ( event == "CVAR_UPDATE" ) then
		local info = UIOptionsFrameCheckButtons[arg1];
		if ( info ) then
			info.value = arg2;
		end
		return;
	end
end

function UIOptionsFrame_Load()
	local button, string, checked;
	for index, value in UIOptionsFrameCheckButtons do
		button = getglobal("UIOptionsFrameCheckButton"..value.index);
		string = getglobal("UIOptionsFrameCheckButton"..value.index.."Text");
		checked = nil;
		button.disabled = nil;
		if ( value.func ) then
			checked = value.func();
		elseif ( index == "SHOW_TUTORIALS" ) then
			if ( TutorialsEnabled() ) then
				checked = 1;
			end
		elseif ( value.uvar ) then
			checked = getglobal(value.uvar);
		elseif ( GetCVar(value.cvar) == "1" ) then
			checked = 1;
		end
		OptionsFrame_EnableCheckBox(button);
		button:SetChecked(checked);
		string:SetText(TEXT(getglobal(index)));
		button.tooltipText = value.tooltipText;
	end
	for index, value in UIOptionsFrameSliders do
		local slider = getglobal("UIOptionsFrameSlider"..index);
		local string = getglobal("UIOptionsFrameSlider"..index.."Text");
		local getvalue = getglobal("Get"..value.cvar);
		getvalue = GetCVar(value.cvar);			
		OptionsFrame_EnableSlider(slider);
		slider:SetMinMaxValues(value.minValue, value.maxValue);
		slider:SetValueStep(value.valueStep);
		slider:SetValue(getvalue);
		string:SetText(TEXT(value.text));
		slider.tooltipText = value.tooltipText;
		slider.tooltipRequirement = value.tooltipRequirement;
		slider.gxRestart = value.gxRestart;
		slider.restartClient = value.restartClient;
	end
	OptionsFrame_EnableDropDown(UIOptionsFrameClickCameraDropDown);
	OptionsFrame_EnableDropDown(UIOptionsFrameCameraDropDown);
	UIOptionsFrame_UpdateDependencies();
end

function UIOptionsFrame_Save()
	for index, value in UIOptionsFrameCheckButtons do
		local button = getglobal("UIOptionsFrameCheckButton"..value.index);
		if ( button:GetChecked() ) then
			value.value = "1";
		else
			value.value = "0";
		end
		if ( value.setFunc ) then
			value.setFunc(value.value);
		elseif ( value.uvar == "SIMPLE_CHAT" ) then
			setglobal(value.uvar, value.value);
			if ( value.value == "1" ) then
				FCF_Set_SimpleChat();
			else
				FCF_Set_NormalChat();
			end
		elseif ( value.uvar == "SHOW_PARTY_PETS" ) then
			setglobal(value.uvar, value.value);
			for i=1, MAX_PARTY_MEMBERS do
					PartyMemberFrame_UpdatePet(i);
			end
		elseif ( value.uvar ) then
			setglobal(value.uvar, value.value);
		elseif ( index == "SHOW_TUTORIALS" ) then
			if ( tonumber(value.value) ~= TutorialsEnabled() ) then
				if ( value.value == "1" ) then
					ResetTutorials();
					TutorialFrameCheckButton:SetChecked(1);
				else
					ClearTutorials();
				end
				TutorialFrame_HideAllAlerts();
			end
		elseif ( index == "SHOW_PET_MELEE_DAMAGE" ) then
			SetCVar(value.cvar, value.value, index);
			SetCVar("PetSpellDamage", value.value);
		else
			SetCVar(value.cvar, value.value, index);
		end
	end
	for index, value in UIOptionsFrameSliders do
		local slider = getglobal("UIOptionsFrameSlider"..index);
		local sliderValue = slider:GetValue()		
		if ( value.text == AUTO_FOLLOW_SPEED ) then
			SetCVar("cameraYawSmoothSpeed", sliderValue);
			SetCVar("cameraPitchSmoothSpeed", sliderValue/4);
		elseif ( value.text == MOUSE_LOOK_SPEED ) then
			SetCVar("cameraYawMoveSpeed", sliderValue);
			SetCVar("cameraPitchMoveSpeed", sliderValue/2);
		else
			SetCVar(value.cvar, sliderValue);
		end
	end

	-- Save multibar state
	SetActionBarToggles(SHOW_MULTI_ACTIONBAR_1, SHOW_MULTI_ACTIONBAR_2, SHOW_MULTI_ACTIONBAR_3, SHOW_MULTI_ACTIONBAR_4);

	-- Save Click to move camera style
	SetCVar("cameraSmoothTrackingStyle", UIDropDownMenu_GetSelectedValue(UIOptionsFrameClickCameraDropDown));
	-- Save move camera style
	SetCVar("cameraSmoothStyle", UIDropDownMenu_GetSelectedValue(UIOptionsFrameCameraDropDown));
end

function UIOptionsFrameClickCameraDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, UIOptionsFrameClickCameraDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(this, GetCVar("cameraSmoothTrackingStyle"));
	UIOptionsFrameClickCameraDropDown.tooltip = getglobal("OPTION_TOOLTIP_CLICK_CAMERA"..UIDropDownMenu_GetSelectedID(UIOptionsFrameClickCameraDropDown));
	UIDropDownMenu_SetWidth(90, UIOptionsFrameClickCameraDropDown);
end

function UIOptionsFrameClickCameraDropDown_OnClick()
	UIDropDownMenu_SetSelectedValue(UIOptionsFrameClickCameraDropDown, this.value);
	UIOptionsFrameClickCameraDropDown.tooltip = getglobal("OPTION_TOOLTIP_CLICK_CAMERA"..this:GetID());
end

function UIOptionsFrameClickCameraDropDown_Initialize()
	local selectedValue = UIDropDownMenu_GetSelectedValue(UIOptionsFrameClickCameraDropDown);
	local info;

	info = {};
	info.text = CAMERA_SMART;
	info.func = UIOptionsFrameClickCameraDropDown_OnClick;
	info.value = "1"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	end
	info.tooltipTitle = CAMERA_SMART;
	info.tooltipText = OPTION_TOOLTIP_CLICKCAMERA_SMART;
	UIDropDownMenu_AddButton(info);

	info = {};
	info.text = CAMERA_LOCKED;
	info.func = UIOptionsFrameClickCameraDropDown_OnClick;
	info.value = "2"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	end
	info.tooltipTitle = CAMERA_LOCKED;
	info.tooltipText = OPTION_TOOLTIP_CLICKCAMERA_LOCKED;
	UIDropDownMenu_AddButton(info);

	info = {};
	info.text = CAMERA_NEVER;
	info.func = UIOptionsFrameClickCameraDropDown_OnClick;
	info.value = "0"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	end
	info.tooltipTitle = CAMERA_NEVER;
	info.tooltipText = OPTION_TOOLTIP_CLICKCAMERA_NEVER;
	UIDropDownMenu_AddButton(info);
end

function UIOptionsFrameCameraDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, UIOptionsFrameCameraDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(this, GetCVar("cameraSmoothStyle"));
	UIOptionsFrameCameraDropDown.tooltip = getglobal("OPTION_TOOLTIP_CAMERA"..UIDropDownMenu_GetSelectedID(UIOptionsFrameCameraDropDown));
	UIDropDownMenu_SetWidth(90, UIOptionsFrameCameraDropDown);
end

function UIOptionsFrameCameraDropDown_OnClick()
	UIDropDownMenu_SetSelectedValue(UIOptionsFrameCameraDropDown, this.value);
	UIOptionsFrameCameraDropDown.tooltip = getglobal("OPTION_TOOLTIP_CAMERA"..this:GetID());
	if ( UIDropDownMenu_GetSelectedID(UIOptionsFrameCameraDropDown) == 3 ) then
		OptionsFrame_DisableSlider(UIOptionsFrameSlider2);
	else
		OptionsFrame_EnableSlider(UIOptionsFrameSlider2);
	end
end

function UIOptionsFrameCameraDropDown_Initialize()
	local selectedValue = UIDropDownMenu_GetSelectedValue(UIOptionsFrameCameraDropDown);
	local info;

	info = {};
	info.text = CAMERA_SMART;
	info.func = UIOptionsFrameCameraDropDown_OnClick;
	info.value = "1"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	end
	info.tooltipTitle = CAMERA_SMART;
	info.tooltipText = OPTION_TOOLTIP_CAMERA_SMART;
	UIDropDownMenu_AddButton(info);

	info = {};
	info.text = CAMERA_ALWAYS;
	info.func = UIOptionsFrameCameraDropDown_OnClick;
	info.value = "2"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	end
	info.tooltipTitle = CAMERA_ALWAYS;
	info.tooltipText = OPTION_TOOLTIP_CAMERA_ALWAYS;
	UIDropDownMenu_AddButton(info);

	info = {};
	info.text = CAMERA_NEVER;
	info.func = UIOptionsFrameCameraDropDown_OnClick;
	info.value = "0"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	end
	info.tooltipTitle = CAMERA_NEVER;
	info.tooltipText = OPTION_TOOLTIP_CAMERA_NEVER;
	UIDropDownMenu_AddButton(info);
end

function UIOptionsFrame_SetDamageCheckBoxes(showDamage)
	if ( showDamage == "1" ) then
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton11, UIOptionsFrameCheckButton11:GetChecked());
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton9, UIOptionsFrameCheckButton9:GetChecked());
	else
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton11);
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton9);
	end
end

function UIOptionsFrame_SetDefaults()
	local checkButton, slider;
	for index, value in UIOptionsFrameCheckButtons do
		checkButton = getglobal("UIOptionsFrameCheckButton"..value.index);
		if ( value.index == "SHOW_CLOAK" ) then
			checkButton:SetChecked(1);
		elseif ( value.index == "SHOW_HELM" ) then
			checkButton:SetChecked(1);
		elseif ( value.cvar ) then
			OptionsFrame_EnableCheckBox(checkButton, GetCVarDefault(value.cvar));
		elseif ( index == "SHOW_TUTORIALS" ) then
			OptionsFrame_EnableCheckBox(checkButton, 1);
		end
	end

	local sliderValue;
	for index, value in UIOptionsFrameSliders do
		slider = getglobal("UIOptionsFrameSlider"..index);
		sliderValue = GetCVarDefault(value.cvar);
		slider:SetValue(sliderValue);
		OptionsFrame_EnableSlider(slider);
	end

	UIDropDownMenu_Initialize(UIOptionsFrameClickCameraDropDown, UIOptionsFrameClickCameraDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(UIOptionsFrameClickCameraDropDown, "1");
	OptionsFrame_EnableDropDown(UIOptionsFrameClickCameraDropDown);

	UIDropDownMenu_Initialize(UIOptionsFrameCameraDropDown, UIOptionsFrameCameraDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(UIOptionsFrameCameraDropDown, "1");
	OptionsFrame_EnableDropDown(UIOptionsFrameCameraDropDown);

	-- Enable/disable the proper checkboxes, sliders, and dropdowns
	UIOptionsFrame_UpdateDependencies();
end

function UIOptionsFrame_UpdateDependencies()
	if ( not UIOptionsFrameCheckButton6:GetChecked() ) then
		OptionsFrame_DisableDropDown(UIOptionsFrameClickCameraDropDown);
	else
		OptionsFrame_EnableDropDown(UIOptionsFrameClickCameraDropDown);
	end
	if ( not UIOptionsFrameCheckButton21:GetChecked() ) then
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton22);
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton23);
	else
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton22, UIOptionsFrameCheckButton22:GetChecked());
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton23, UIOptionsFrameCheckButton23:GetChecked());
	end
	if ( not UIOptionsFrameCheckButton19:GetChecked() ) then
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton9);
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton11);
	else
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton9, UIOptionsFrameCheckButton9:GetChecked());
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton11, UIOptionsFrameCheckButton11:GetChecked());
	end
	if ( UIDropDownMenu_GetSelectedID(UIOptionsFrameCameraDropDown) == 3 ) then
		OptionsFrame_DisableSlider(UIOptionsFrameSlider2);
	else
		OptionsFrame_EnableSlider(UIOptionsFrameSlider2);
	end
	if ( not UIOptionsFrameCheckButton35:GetChecked() ) then
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton36);
	else
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton36, MultiBar4_IsVisible());
	end
end
