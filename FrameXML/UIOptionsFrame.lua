UIOptionsFrameCheckButtons = { };
------------------- Basic Options -------------------
-- Controls
UIOptionsFrameCheckButtons["INVERT_MOUSE"] =				{ index = 1, cvar = "mouseInvertPitch" };

-- General
UIOptionsFrameCheckButtons["CLICK_TO_MOVE"] =				{ index = 6,  cvar = "autointeract" };
UIOptionsFrameCheckButtons["GAMEFIELD_DESELECT_TEXT"] =			{ index = 45, cvar = "deselectOnClick"};
UIOptionsFrameCheckButtons["ASSIST_ATTACK"] =				{ index = 3,  cvar = "assistAttack" };
UIOptionsFrameCheckButtons["CLEAR_AFK"] =				{ index = 16, cvar = "autoClearAFK" };
UIOptionsFrameCheckButtons["BLOCK_TRADES"] =				{ index = 14, cvar = "BlockTrades" };
UIOptionsFrameCheckButtons["AUTO_SELF_CAST_TEXT"] =			{ index = 61, cvar = "autoSelfCast"};

-- Display
UIOptionsFrameCheckButtons["USE_UBERTOOLTIPS"] =			{ index = 12, cvar = "UberTooltips" };
UIOptionsFrameCheckButtons["STATUS_BAR_TEXT"] =				{ index = 2,  cvar = "statusBarText" };
UIOptionsFrameCheckButtons["PROFANITY_FILTER"] =			{ index = 5,  cvar = "profanityFilter" };
UIOptionsFrameCheckButtons["SHOW_CLOAK"] =				{ index = 31, func = ShowingCloak, setFunc = ShowCloak};
UIOptionsFrameCheckButtons["SHOW_HELM"] =				{ index = 20, func = ShowingHelm , setFunc = ShowHelm };
UIOptionsFrameCheckButtons["SHOW_QUEST_FADING_TEXT"] =			{ index = 42, uvar = "QUEST_FADING_DISABLE", default = "0"};
UIOptionsFrameCheckButtons["SHOW_BUFF_DURATION_TEXT"] =			{ index = 39, uvar = "SHOW_BUFF_DURATIONS", default = "0"};
UIOptionsFrameCheckButtons["SHOW_PLAYER_NAMES"] =			{ index = 21, cvar = "UnitNamePlayer"};
UIOptionsFrameCheckButtons["SHOW_GUILD_NAMES"] =			{ index = 22, cvar = "UnitNamePlayerGuild"};
UIOptionsFrameCheckButtons["SHOW_PLAYER_TITLES"] =			{ index = 23, cvar = "UnitNamePlayerPVPTitle"};
UIOptionsFrameCheckButtons["SHOW_NPC_NAMES"] =				{ index = 30, cvar = "UnitNameNPC"};
UIOptionsFrameCheckButtons["SHOW_OWN_NAME"] =				{ index = 67, cvar = "UnitNameOwn"};
UIOptionsFrameCheckButtons["SHOW_PARTY_BACKGROUND_TEXT"] =		{ index = 43, uvar = "SHOW_PARTY_BACKGROUND"};
UIOptionsFrameCheckButtons["HIDE_OUTDOOR_WORLD_STATE_TEXT"] =		{ index = 62, uvar = "HIDE_OUTDOOR_WORLD_STATE", default = "0"};
UIOptionsFrameCheckButtons["AUTO_QUEST_WATCH_TEXT"] =			{ index = 66, uvar = "AUTO_QUEST_WATCH", default = "1"};

-- Camera Controls
UIOptionsFrameCheckButtons["FOLLOW_TERRAIN"] =				{ index = 24, cvar = "cameraTerrainTilt"};
UIOptionsFrameCheckButtons["HEAD_BOB"] =				{ index = 26, cvar = "cameraBobbing"};
UIOptionsFrameCheckButtons["WATER_COLLISION"] =				{ index = 27, cvar = "cameraWaterCollision"};
UIOptionsFrameCheckButtons["SMART_PIVOT"] =				{ index = 15, cvar = "cameraPivot" };
-- Help
UIOptionsFrameCheckButtons["SHOW_TUTORIALS"] =				{ index = 28};
UIOptionsFrameCheckButtons["SHOW_NEWBIE_TIPS_TEXT"] =			{ index = 29, uvar = "SHOW_NEWBIE_TIPS"};
UIOptionsFrameCheckButtons["SHOW_TIPOFTHEDAY_TEXT"] =			{ index = 44, cvar = "showGameTips"};

------------------- Advanced Options -------------------
-- Chat
UIOptionsFrameCheckButtons["SIMPLE_CHAT_TEXT"] =			{ index = 7,  uvar = "SIMPLE_CHAT" , default = "1"};
UIOptionsFrameCheckButtons["CHAT_LOCKED_TEXT"] =			{ index = 8,  uvar = "CHAT_LOCKED" , default = "1"};
UIOptionsFrameCheckButtons["GUILDMEMBER_ALERT"] =			{ index = 13, cvar = "guildMemberNotify" };
UIOptionsFrameCheckButtons["REMOVE_CHAT_DELAY_TEXT"] =			{ index = 18, uvar = "REMOVE_CHAT_DELAY", default = "0"};
UIOptionsFrameCheckButtons["CHAT_BUBBLES_TEXT"] =			{ index = 37, cvar = "ChatBubbles"};
UIOptionsFrameCheckButtons["PARTY_CHAT_BUBBLES_TEXT"] =			{ index = 38, cvar = "ChatBubblesParty"};
UIOptionsFrameCheckButtons["SHOW_LOOT_SPAM"] =				{ index = 46, cvar = "showLootSpam"};
UIOptionsFrameCheckButtons["AUTO_JOIN_GUILD_CHANNEL"] =			{ index = 51};
UIOptionsFrameCheckButtons["DISABLE_SPAM_FILTER"] =			{ index = 68, cvar = "spamFilter"};

-- Action Bars
UIOptionsFrameCheckButtons["LOCK_ACTIONBAR_TEXT"] =			{ index = 32, uvar = "LOCK_ACTIONBAR", default = "0"};
UIOptionsFrameCheckButtons["SHOW_MULTIBAR1_TEXT"] =			{ index = 33, func = MultiBar1_IsVisible, setFunc = Multibar_EmptyFunc};
UIOptionsFrameCheckButtons["SHOW_MULTIBAR2_TEXT"] =			{ index = 34, func = MultiBar2_IsVisible, setFunc = Multibar_EmptyFunc};
UIOptionsFrameCheckButtons["SHOW_MULTIBAR3_TEXT"] =			{ index = 35, func = MultiBar3_IsVisible, setFunc = Multibar_EmptyFunc};
UIOptionsFrameCheckButtons["SHOW_MULTIBAR4_TEXT"] =			{ index = 36, func = MultiBar4_IsVisible, setFunc = Multibar_EmptyFunc};
UIOptionsFrameCheckButtons["ALWAYS_SHOW_MULTIBARS_TEXT"] =		{ index = 40, func = MultibarGrid_IsVisible, setFunc = Multibar_EmptyFunc};

-- Raid & Party Options
UIOptionsFrameCheckButtons["HIDE_PARTY_INTERFACE_TEXT"] =		{ index = 47, uvar = "HIDE_PARTY_INTERFACE" , default = "0"};
UIOptionsFrameCheckButtons["SHOW_DISPELLABLE_DEBUFFS_TEXT"] =		{ index = 48, uvar = "SHOW_DISPELLABLE_DEBUFFS" , default = "1"};
UIOptionsFrameCheckButtons["SHOW_CASTABLE_BUFFS_TEXT"] =		{ index = 49, uvar = "SHOW_CASTABLE_BUFFS" , default = "1"};
UIOptionsFrameCheckButtons["SHOW_TARGET_OF_TARGET_TEXT"] =		{ index = 50, uvar = "SHOW_TARGET_OF_TARGET" , default = "0"};
UIOptionsFrameCheckButtons["SHOW_PARTY_PETS_TEXT"] =			{ index = 41, uvar = "SHOW_PARTY_PETS", default = "1"};

-- Combat Text
UIOptionsFrameCheckButtons["SHOW_COMBAT_TEXT_TEXT"] =			{ index = 52, uvar = "SHOW_COMBAT_TEXT" , default = "0"};
UIOptionsFrameCheckButtons["COMBAT_TEXT_SHOW_LOW_HEALTH_MANA_TEXT"] =	{ index = 53, uvar = "COMBAT_TEXT_SHOW_LOW_HEALTH_MANA" , default = "1"};
UIOptionsFrameCheckButtons["COMBAT_TEXT_SHOW_AURAS_TEXT"] =		{ index = 54, uvar = "COMBAT_TEXT_SHOW_AURAS" , default = "1"};
UIOptionsFrameCheckButtons["COMBAT_TEXT_SHOW_AURA_FADE_TEXT"] =		{ index = 55, uvar = "COMBAT_TEXT_SHOW_AURA_FADE" , default = "0"};
UIOptionsFrameCheckButtons["COMBAT_TEXT_SHOW_COMBAT_STATE_TEXT"] =	{ index = 56, uvar = "COMBAT_TEXT_SHOW_COMBAT_STATE" , default = "1"};
UIOptionsFrameCheckButtons["COMBAT_TEXT_SHOW_DODGE_PARRY_MISS_TEXT"] =	{ index = 57, uvar = "COMBAT_TEXT_SHOW_DODGE_PARRY_MISS", default = "0"};
UIOptionsFrameCheckButtons["COMBAT_TEXT_SHOW_RESISTANCES_TEXT"] =	{ index = 58, uvar = "COMBAT_TEXT_SHOW_RESISTANCES", default = "0"};
UIOptionsFrameCheckButtons["COMBAT_TEXT_SHOW_REPUTATION_TEXT"] =	{ index = 60, uvar = "COMBAT_TEXT_SHOW_REPUTATION", default = "0"};
UIOptionsFrameCheckButtons["SHOW_DAMAGE_TEXT"] =			{ index = 19, cvar = "CombatDamage"};
UIOptionsFrameCheckButtons["LOG_PERIODIC_EFFECTS"] =			{ index = 11, cvar = "CombatLogPeriodicSpells" };
UIOptionsFrameCheckButtons["SHOW_PET_MELEE_DAMAGE"] =			{ index = 9,  cvar = "PetMeleeDamage" };
UIOptionsFrameCheckButtons["COMBAT_TEXT_SHOW_REACTIVES_TEXT"] =		{ index = 63, uvar = "COMBAT_TEXT_SHOW_REACTIVES", default = "0"};
UIOptionsFrameCheckButtons["COMBAT_TEXT_SHOW_FRIENDLY_NAMES_TEXT"] =	{ index = 64, uvar = "COMBAT_TEXT_SHOW_FRIENDLY_NAMES", default = "0"};
UIOptionsFrameCheckButtons["COMBAT_TEXT_SHOW_COMBO_POINTS_TEXT"] =	{ index = 65, uvar = "COMBAT_TEXT_SHOW_COMBO_POINTS", default = "0"};
UIOptionsFrameCheckButtons["COMBAT_TEXT_SHOW_MANA_TEXT"] =		{ index = 59, uvar = "COMBAT_TEXT_SHOW_MANA", default = "0"};
UIOptionsFrameCheckButtons["COMBAT_TEXT_SHOW_HONOR_GAINED_TEXT"] =	{ index = 69, uvar = "COMBAT_TEXT_SHOW_HONOR_GAINED", default = "1"};

UIOptionsFrameSliders = {
	{ text = "MOUSE_SENSITIVITY", cvar = "mousespeed", minValue = 0.5, maxValue = 1.5, valueStep = 0.05 },
	{ text = "AUTO_FOLLOW_SPEED", cvar = "cameraYawSmoothSpeed", minValue = 90, maxValue = 270, valueStep = 10 },
	{ text = "MOUSE_LOOK_SPEED",  cvar = "cameraYawMoveSpeed", minValue = 90, maxValue = 270, valueStep = 10 },
	{ text = "MAX_FOLLOW_DIST",   cvar = "cameraDistanceMaxFactor", minValue = 1, maxValue = 2, valueStep = 0.1 },
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
	SHOW_PARTY_BACKGROUND = "0";
	RegisterForSave("SHOW_PARTY_BACKGROUND");
	HIDE_PARTY_INTERFACE = "0";
	RegisterForSave("HIDE_PARTY_INTERFACE");
	SHOW_TARGET_OF_TARGET = "0";
	SHOW_TARGET_OF_TARGET_STATE = "5";
	RegisterForSave("SHOW_TARGET_OF_TARGET");
	RegisterForSave("SHOW_TARGET_OF_TARGET_STATE");
	HIDE_OUTDOOR_WORLD_STATE = "0";
	RegisterForSave("HIDE_OUTDOOR_WORLD_STATE");
	AUTO_QUEST_WATCH = 1;
	RegisterForSave("AUTO_QUEST_WATCH");
	-- Combat text uvars
	SHOW_COMBAT_TEXT = "0";
	RegisterForSave("SHOW_COMBAT_TEXT");
	COMBAT_TEXT_SHOW_LOW_HEALTH_MANA = "1";
	RegisterForSave("COMBAT_TEXT_SHOW_LOW_HEALTH_MANA");
	COMBAT_TEXT_SHOW_AURAS = "1";
	RegisterForSave("COMBAT_TEXT_SHOW_AURAS");
	COMBAT_TEXT_SHOW_AURA_FADE = "0";
	RegisterForSave("COMBAT_TEXT_SHOW_AURA_FADE");
	COMBAT_TEXT_SHOW_COMBAT_STATE = "1";
	RegisterForSave("COMBAT_TEXT_SHOW_COMBAT_STATE");
	COMBAT_TEXT_SHOW_DODGE_PARRY_MISS = "0";
	RegisterForSave("COMBAT_TEXT_SHOW_DODGE_PARRY_MISS");
	COMBAT_TEXT_SHOW_RESISTANCES = "0";
	RegisterForSave("COMBAT_TEXT_SHOW_RESISTANCES");
	COMBAT_TEXT_SHOW_REPUTATION = "0";
	RegisterForSave("COMBAT_TEXT_SHOW_REPUTATION");
	COMBAT_TEXT_SHOW_REACTIVES = "0";
	RegisterForSave("COMBAT_TEXT_SHOW_REACTIVES");
	COMBAT_TEXT_SHOW_FRIENDLY_NAMES = "0";
	RegisterForSave("COMBAT_TEXT_SHOW_FRIENDLY_NAMES");
	COMBAT_TEXT_SHOW_COMBO_POINTS = "0";
	RegisterForSave("COMBAT_TEXT_SHOW_COMBO_POINTS");
	COMBAT_TEXT_SHOW_MANA = "0";
	RegisterForSave("COMBAT_TEXT_SHOW_MANA");
	COMBAT_TEXT_FLOAT_MODE = "1";
	RegisterForSave("COMBAT_TEXT_FLOAT_MODE");
	COMBAT_TEXT_SHOW_HONOR_GAINED = "1";
	RegisterForSave("COMBAT_TEXT_SHOW_HONOR_GAINED");

	this:RegisterEvent("CVAR_UPDATE");
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("ADDON_LOADED");

	-- Tab Handling code
	PanelTemplates_SetNumTabs(this, 2);
	PanelTemplates_SetTab(this, 1);

	-- Position sections
	BasicOptionsGeneral:SetHeight(95);
	--BasicOptionsGeneral:SetPoint("TOPRIGHT", BasicOptions, "BOTTOMRIGHT", UIOptionsFrame:GetWidth()*-0.5, -104);
	BasicOptionsDisplay:SetPoint("TOPLEFT", BasicOptionsGeneral, "BOTTOMLEFT", 0, -20);
	BasicOptionsDisplay:SetPoint("TOPRIGHT", BasicOptionsGeneral, "BOTTOMRIGHT", 0, -20);
	AdvancedOptionsActionBars:SetPoint("TOPLEFT", AdvancedOptions, "TOPLEFT", 32, -104);
	AdvancedOptionsActionBars:SetPoint("TOPRIGHT", AdvancedOptions, "TOPRIGHT", -32, -104);
	AdvancedOptionsChat:SetPoint("TOPLEFT", AdvancedOptionsActionBars, "BOTTOMLEFT", 0, -20);
	AdvancedOptionsChat:SetPoint("TOPRIGHT", AdvancedOptionsActionBars, "BOTTOMRIGHT", BasicOptions:GetWidth()*-0.65, -20);
	AdvancedOptionsRaid:SetPoint("TOPLEFT", AdvancedOptionsActionBars, "BOTTOMLEFT", BasicOptions:GetWidth()*0.32, -20);
	AdvancedOptionsRaid:SetPoint("TOPRIGHT", AdvancedOptionsActionBars, "BOTTOMRIGHT", BasicOptions:GetWidth()*-0.32, -20);
	AdvancedOptionsRaid:SetPoint("BOTTOMLEFT", AdvancedOptionsChat, "BOTTOMRIGHT", 0, 0);
	AdvancedOptionsCombatText:SetPoint("TOPLEFT", AdvancedOptionsActionBars, "BOTTOMLEFT", BasicOptions:GetWidth()*0.65, -20);
	AdvancedOptionsCombatText:SetPoint("TOPRIGHT", AdvancedOptionsActionBars, "BOTTOMRIGHT", 0, -20);
	AdvancedOptionsCombatText:SetPoint("BOTTOMLEFT", AdvancedOptionsRaid, "BOTTOMRIGHT", 0, 0);
	UIOptionsFrameTitle:SetPoint("TOP", AdvancedOptions, "TOP", 0, -5);

	-- Variables not displayed in the ui options but they needed a home
	RegisterForSave("NAMEPLATES_ON");
	NAMEPLATES_ON = nil;
	RegisterForSave("NAMEPLATES_ON");
	FRIENDNAMEPLATES_ON = nil;
end

function UIOptionsFrame_OnEvent()
	if ( event == "CVAR_UPDATE" ) then
		local info = UIOptionsFrameCheckButtons[arg1];
		if ( info ) then
			info.value = arg2;
		end
		return;
	elseif ( event == "VARIABLES_LOADED" ) then
		local button, checked;
		for index, value in UIOptionsFrameCheckButtons do
			checked = nil;
			if ( value.uvar ) then
				button = getglobal("UIOptionsFrameCheckButton"..value.index);
				checked = getglobal(value.uvar);
				value.value = checked;
				button:SetChecked(checked);
			end
		end
		-- Option specific function calls
		-- Buff Durations
		BuffButtons_UpdatePositions();
		-- Simple Chat
		if ( SIMPLE_CHAT == "1" ) then
			FCF_Set_SimpleChat();
		end
		-- Chat Locked
		if ( CHAT_LOCKED == "1" ) then
			FCF_Set_ChatLocked(1);
		end
		-- Chat mouse over delay
		SetChatMouseOverDelay(REMOVE_CHAT_DELAY);
		-- Always show multibars
		if ( ALWAYS_SHOW_MULTIBARS == "1" or ALWAYS_SHOW_MULTIBARS == 1 ) then
			MultiActionBar_ShowAllGrids();
		end
		-- Hide party interface
		RaidOptionsFrame_UpdatePartyFrames();
		-- Update combat text options
		if ( SHOW_COMBAT_TEXT == "1" ) then
			UIParentLoadAddOn("Blizzard_CombatText");
		end
	end
end

function UIOptionsFrame_Load()
	local button, string, checked, mode;
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
		elseif ( index == "AUTO_JOIN_GUILD_CHANNEL" ) then
			if ( GetGuildRecruitmentMode() == 1 ) then
				checked = 1;
			else
				checked = 0;
			end
		elseif ( index == "GAMEFIELD_DESELECT_TEXT" ) then
			if ( GetCVar(value.cvar) == "0" ) then
				checked = 1;
			end
		elseif ( index == "DISABLE_SPAM_FILTER" ) then
			if ( GetCVar(value.cvar) == "0" ) then
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
		button.tooltipText = getglobal("OPTION_TOOLTIP_"..gsub(index, "_TEXT$", ""));
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
		string:SetText(getglobal(value.text));
		slider.tooltipText = getglobal("OPTION_TOOLTIP_"..value.text);
		slider.tooltipRequirement = value.tooltipRequirement;
		slider.gxRestart = value.gxRestart;
		slider.restartClient = value.restartClient;
	end
	OptionsFrame_EnableDropDown(UIOptionsFrameClickCameraDropDown);
	OptionsFrame_EnableDropDown(UIOptionsFrameCameraDropDown);
	UIOptionsFrame_UpdateDependencies();
end

function UIOptionsFrame_Save()
	local mode;
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
		elseif ( value.uvar == "HIDE_PARTY_INTERFACE" ) then
			setglobal(value.uvar, value.value);
			RaidOptionsFrame_UpdatePartyFrames();
		elseif ( value.uvar == "HIDE_OUTDOOR_WORLD_STATE" ) then
			setglobal(value.uvar, value.value);
			WorldStateAlwaysUpFrame_Update();
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
		elseif ( index == "AUTO_JOIN_GUILD_CHANNEL" ) then
			mode = button:GetChecked();
			if ( not mode ) then
				mode = 0;
			end
			SetGuildRecruitmentMode(mode);
		elseif ( index == "SHOW_PET_MELEE_DAMAGE" ) then
			SetCVar(value.cvar, value.value, index);
			SetCVar("PetSpellDamage", value.value);
		elseif ( index == "GAMEFIELD_DESELECT_TEXT" or index == "DISABLE_SPAM_FILTER" ) then
			if ( value.value == "1" ) then
				value.value = "0";
			else
				value.value = "1";
			end
			SetCVar(value.cvar, value.value, index);
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
	SetActionBarToggles(SHOW_MULTI_ACTIONBAR_1, SHOW_MULTI_ACTIONBAR_2, SHOW_MULTI_ACTIONBAR_3, SHOW_MULTI_ACTIONBAR_4, ALWAYS_SHOW_MULTIBARS);
	-- Save Target of Target options
	SHOW_TARGET_OF_TARGET_STATE = UIDropDownMenu_GetSelectedValue(UIOptionsFrameTargetofTargetDropDown);
	-- Save Click to move camera style
	SetCVar("cameraSmoothTrackingStyle", UIDropDownMenu_GetSelectedValue(UIOptionsFrameClickCameraDropDown));
	-- Save move camera style
	SetCVar("cameraSmoothStyle", UIDropDownMenu_GetSelectedValue(UIOptionsFrameCameraDropDown));
	-- Update combat text
	if ( SHOW_COMBAT_TEXT == "1" ) then
		UIParentLoadAddOn("Blizzard_CombatText");
	end
	if ( CombatText_UpdateDisplayedMessages ) then
		CombatText_UpdateDisplayedMessages();
	end
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

function UIOptionsFrameTargetofTargetDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, UIOptionsFrameTargetofTargetDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(this, SHOW_TARGET_OF_TARGET_STATE);
	UIOptionsFrameTargetofTargetDropDown.tooltip = getglobal("OPTION_TOOLTIP_TARGETOFTARGET"..UIDropDownMenu_GetSelectedValue(UIOptionsFrameTargetofTargetDropDown));
	UIDropDownMenu_SetWidth(110, UIOptionsFrameTargetofTargetDropDown);
end

function UIOptionsFrameTargetofTargetDropDown_OnClick()
	UIDropDownMenu_SetSelectedValue(UIOptionsFrameTargetofTargetDropDown, this.value);
	UIOptionsFrameTargetofTargetDropDown.tooltip = getglobal("OPTION_TOOLTIP_TARGETOFTARGET"..this:GetID());
end

function UIOptionsFrameTargetofTargetDropDown_Initialize()
	local selectedValue = UIDropDownMenu_GetSelectedValue(UIOptionsFrameTargetofTargetDropDown);
	local info;

	info = {};
	info.text = RAID;
	info.func = UIOptionsFrameTargetofTargetDropDown_OnClick;
	info.value = "1"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	end
	info.tooltipTitle = RAID;
	info.tooltipText = OPTION_TOOLTIP_TARGETOFTARGET_RAID;
	UIDropDownMenu_AddButton(info);

	info = {};
	info.text = PARTY;
	info.func = UIOptionsFrameTargetofTargetDropDown_OnClick;
	info.value = "2"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	end
	info.tooltipTitle = PARTY;
	info.tooltipText = OPTION_TOOLTIP_TARGETOFTARGET_PARTY;
	UIDropDownMenu_AddButton(info);

	info = {};
	info.text = SOLO;
	info.func = UIOptionsFrameTargetofTargetDropDown_OnClick;
	info.value = "3"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	end
	info.tooltipTitle = PARTY;
	info.tooltipText = OPTION_TOOLTIP_TARGETOFTARGET_SOLO;
	UIDropDownMenu_AddButton(info);

	info = {};
	info.text = RAID_AND_PARTY;
	info.func = UIOptionsFrameTargetofTargetDropDown_OnClick;
	info.value = "4"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	end
	info.tooltipTitle = RAID_AND_PARTY;
	info.tooltipText = OPTION_TOOLTIP_TARGETOFTARGET_RAID_AND_PARTY;
	UIDropDownMenu_AddButton(info);

	info = {};
	info.text = ALWAYS;
	info.func = UIOptionsFrameTargetofTargetDropDown_OnClick;
	info.value = "5"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	end
	info.tooltipTitle = ALWAYS;
	info.tooltipText = OPTION_TOOLTIP_TARGETOFTARGET_ALWAYS;
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

function UIOptionsFrameCombatTextDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, UIOptionsFrameCombatTextDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(this, COMBAT_TEXT_FLOAT_MODE);
	UIOptionsFrameCombatTextDropDown.tooltip = OPTION_TOOLTIP_COMBAT_TEXT_MODE;
	UIDropDownMenu_SetWidth(90, UIOptionsFrameCombatTextDropDown);
end

function UIOptionsFrameCombatTextDropDown_OnClick()
	UIDropDownMenu_SetSelectedValue(UIOptionsFrameCombatTextDropDown, this.value);
	COMBAT_TEXT_FLOAT_MODE = this.value;
	UIParentLoadAddOn("Blizzard_CombatText");
	CombatText_UpdateDisplayedMessages();
end

function UIOptionsFrameCombatTextDropDown_Initialize()
	local selectedValue = UIDropDownMenu_GetSelectedValue(UIOptionsFrameCombatTextDropDown);
	local info;

	info = {};
	info.text = COMBAT_TEXT_SCROLL_UP;
	info.func = UIOptionsFrameCombatTextDropDown_OnClick;
	info.value = "1"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	end
	info.tooltipTitle = COMBAT_TEXT_SCROLL_UP;
	info.tooltipText = OPTION_TOOLTIP_SCROLL_UP;
	UIDropDownMenu_AddButton(info);

	info = {};
	info.text = COMBAT_TEXT_SCROLL_DOWN;
	info.func = UIOptionsFrameCombatTextDropDown_OnClick;
	info.value = "2"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	end
	info.tooltipTitle = COMBAT_TEXT_SCROLL_DOWN;
	info.tooltipText = OPTION_TOOLTIP_SCROLL_DOWN;
	UIDropDownMenu_AddButton(info);

	info = {};
	info.text = COMBAT_TEXT_SCROLL_ARC;
	info.func = UIOptionsFrameCombatTextDropDown_OnClick;
	info.value = "3"
	if ( info.value == selectedValue ) then
		info.checked = 1;
	end
	info.tooltipTitle = COMBAT_TEXT_SCROLL_ARC;
	info.tooltipText = OPTION_TOOLTIP_SCROLL_ARC;
	UIDropDownMenu_AddButton(info);
end

function UIOptionsFrame_SetDamageCheckBoxes(showDamage)
	if ( showDamage == "1" ) then
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton11);
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton9);
	else
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton11);
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton9);
	end
end

-- Return Multibars to their prior state.
function UIOptionsFrameMultiBar_Reset()
	SHOW_MULTI_ACTIONBAR_1 = STATE_MultiBar1;
	SHOW_MULTI_ACTIONBAR_2 = STATE_MultiBar2;
	SHOW_MULTI_ACTIONBAR_3 = STATE_MultiBar3;
	SHOW_MULTI_ACTIONBAR_4 = STATE_MultiBar4;
	ALWAYS_SHOW_MULTIBARS = STATE_AlwaysShowMultibars;
end

function UIOptionsFrame_SetDefaults()
	local checkButton, slider;
	for index, value in UIOptionsFrameCheckButtons do
		checkButton = getglobal("UIOptionsFrameCheckButton"..value.index);
		if ( index == "SHOW_CLOAK" ) then
			checkButton:SetChecked(1);
		elseif ( index == "SHOW_HELM" ) then
			checkButton:SetChecked(1);
		elseif ( index == "SHOW_MULTIBAR1_TEXT" ) then
			checkButton:SetChecked(0);
		elseif ( index == "SHOW_MULTIBAR2_TEXT" ) then
			checkButton:SetChecked(0);
		elseif ( index == "SHOW_MULTIBAR3_TEXT" ) then
			checkButton:SetChecked(0);
		elseif ( index == "SHOW_MULTIBAR4_TEXT" ) then
			checkButton:SetChecked(0);
		elseif ( value.cvar ) then
			OptionsFrame_EnableCheckBox(checkButton, 1, GetCVarDefault(value.cvar));
		elseif ( index == "SHOW_TUTORIALS" ) then
			OptionsFrame_EnableCheckBox(checkButton, 1, 1);
		elseif ( index == "AUTO_JOIN_GUILD_CHANNEL" ) then
			SetGuildRecruitmentMode(1);
		elseif ( value.uvar ) then	
			if ( value.default ) then 
				if ( value.default == "1" ) then
					checkButton:SetChecked(1);
				else
					checkButton:SetChecked(nil);
				end
			end
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

	UIDropDownMenu_Initialize(UIOptionsFrameTargetofTargetDropDown, UIOptionsFrameTargetofTargetDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(UIOptionsFrameTargetofTargetDropDown, "5");
	SHOW_TARGET_OF_TARGET_STATE = "5";
	
	UIDropDownMenu_Initialize(UIOptionsFrameCombatTextDropDown, UIOptionsFrameCombatTextDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(UIOptionsFrameCombatTextDropDown, "1");
	COMBAT_TEXT_FLOAT_MODE = "1";

	-- Enable/disable the proper checkboxes, sliders, and dropdowns
	UIOptionsFrame_UpdateDependencies();
end

function UIOptionsFrame_UpdateDependencies()
	-- Dependency for Click to Move Camera dropdown
	if ( not UIOptionsFrameCheckButton6:GetChecked() ) then
		OptionsFrame_DisableDropDown(UIOptionsFrameClickCameraDropDown);
	else
		OptionsFrame_EnableDropDown(UIOptionsFrameClickCameraDropDown);
	end

	-- Dependency for Target of Target dropdown
	if ( not UIOptionsFrameCheckButton50:GetChecked() ) then
		OptionsFrame_DisableDropDown(UIOptionsFrameTargetofTargetDropDown);
	else
		OptionsFrame_EnableDropDown(UIOptionsFrameTargetofTargetDropDown);
	end

	if ( not UIOptionsFrameCheckButton21:GetChecked() ) then
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton22);
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton23);
	else
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton22);
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton23);
	end
	if ( not UIOptionsFrameCheckButton19:GetChecked() ) then
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton9);
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton11);
	else
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton9);
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton11);
	end
	if ( UIDropDownMenu_GetSelectedID(UIOptionsFrameCameraDropDown) == 3 ) then
		OptionsFrame_DisableSlider(UIOptionsFrameSlider2);
	else
		OptionsFrame_EnableSlider(UIOptionsFrameSlider2);
	end
	if ( not UIOptionsFrameCheckButton35:GetChecked() ) then
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton36);
	else
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton36, 1, MultiBar4_IsVisible());
	end
	-- Additional combat text dependancies
	if ( not UIOptionsFrameCheckButton52:GetChecked() ) then
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton53);
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton54);
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton55);
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton56);
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton57);
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton58);
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton59);
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton60);
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton63);
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton64);
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton65);
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton69);
		OptionsFrame_DisableDropDown(UIOptionsFrameCombatTextDropDown);
	else
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton53);
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton54);
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton55);
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton56);
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton57);
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton58);
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton59);
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton60);
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton63);
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton64);
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton65);
		OptionsFrame_EnableCheckBox(UIOptionsFrameCheckButton69);
		OptionsFrame_EnableDropDown(UIOptionsFrameCombatTextDropDown);
	end

	-- Disable combo point combat text checkbox if not a rogue or druid
	local temp, class = UnitClass("player");
	class = strupper(class);
	if ( class ~= "ROGUE" and class ~= "DRUID" ) then
		OptionsFrame_DisableCheckBox(UIOptionsFrameCheckButton65);
	end
end


-- Nameplate display function -- It is not used by the options ui, but I put it here since this is the most closely related file.
function UpdateNameplates()
	if ( NAMEPLATES_ON ) then
		ShowNameplates();
	else
		HideNameplates();
	end
	if ( FRIENDNAMEPLATES_ON ) then
		ShowFriendNameplates();
		HideFriendNameplates();
	else
		HideFriendNameplates();
	end
end
