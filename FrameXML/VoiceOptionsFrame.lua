VOICE_OPTIONS_BINDING_FADE = 3;

VoiceOptionsFrameCheckButtons = { };
VoiceOptionsFrameCheckButtons["ENABLE_VOICECHAT"] = { index = 1, cvar = "EnableVoiceChat", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_VOICECHAT};
VoiceOptionsFrameCheckButtons["ENABLE_MICROPHONE"] = { index = 2, cvar = "EnableMicrophone", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_MICROPHONE};
VoiceOptionsFrameCheckButtons["PUSHTOTALK_SOUND_TEXT"] = { index = 3, uvar = "PUSHTOTALK_SOUND", initialValue = nil , tooltipText = OPTION_TOOLTIP_PUSHTOTALK_SOUND};

VoiceOptionsFrameSliders = {
	{ index = 1, text = VOICE_ACTIVATION_SENSITIVITY, cvar = "VoiceActivationSensitivity", minValue = 0, maxValue = 1, valueStep = 0.02, initialValue = nil, tooltipText = OPTION_TOOLTIP_VOICE_ACTIVATION_SENSITIVITY},
	{ index = 2, text = VOICE_INPUT_VOLUME, cvar = "OutboundChatVolume", minValue = 0.25, maxValue = 2.5, valueStep = 0.05, initialValue = nil, tooltipText = OPTION_TOOLTIP_VOICE_INPUT_VOLUME},
	{ index = 3, text = VOICE_OUTPUT_VOLUME, cvar = "InboundChatVolume", minValue = 0, maxValue = 1, valueStep = 0.1, initialValue = nil, tooltipText = OPTION_TOOLTIP_VOICE_OUTPUT_VOLUME},
	{ index = 4, text = SOUND_VOLUME, cvar = "ChatSoundVolume", minValue = 0, maxValue = 1, valueStep = 0.1, initialValue = nil, tooltipText = OPTION_TOOLTIP_VOICE_SOUND},
	{ index = 5, text = MUSIC_VOLUME, cvar = "ChatMusicVolume", minValue = 0, maxValue = 1, valueStep = 0.1, initialValue = nil, tooltipText = OPTION_TOOLTIP_VOICE_MUSIC},
	{ index = 6, text = AMBIENCE_VOLUME, cvar = "ChatAmbienceVolume", minValue = 0, maxValue = 1, valueStep = 0.1, initialValue = nil, tooltipText = OPTION_TOOLTIP_VOICE_AMBIENCE},
};

VoiceOptionsFrameDisableList = {
		VoiceOptionsFrameType1Label = NORMAL_FONT_COLOR,
		VoiceOptionsFrameAudioLabel = NORMAL_FONT_COLOR,
		VoiceOptionsFrameAudioDescription = HIGHLIGHT_FONT_COLOR,
		VoiceOptionsFrameAudioOff = HIGHLIGHT_FONT_COLOR,
		VoiceOptionsFrameAudioNormal = HIGHLIGHT_FONT_COLOR,
};

VoiceOptionsFrameMicrophoneList = {
		VoiceOptionsFrameMicTestText = NORMAL_FONT_COLOR,
		PlayLoopbackSoundButtonTexture = NORMAL_FONT_COLOR,
		RecordLoopbackSoundButtonTexture = RED_FONT_COLOR,
};

PUSH_TO_TALK_BUTTON = "";
PUSH_TO_TALK_MODIFIER = "";

function VoiceOptionsFrame_Init()
	PUSHTOTALK_SOUND = "0";
	RegisterForSave("PUSHTOTALK_SOUND");
	this:RegisterEvent("CVAR_UPDATE");
	this:RegisterEvent("SOUND_DEVICE_UPDATE");
end

function VoiceOptionsFrame_OnEvent(self, event, ...)
	if ( event == "CVAR_UPDATE" ) then
		--It turns out that this code wasn't doing anything actually related to the VoiceOptionsFrame. No items in UIOptionsFrameCheckButtons exist with cvars of "EnableVoiceChat" or "EnableMicrophone", making this pointless.
		-- local info = UIOptionsFrameCheckButtons[arg1];
		-- if ( info ) then
			-- info.value = arg2;
			-- if ( info.cvar == "EnableVoiceChat" ) then
				-- VoiceOptionsFrame_Update();
			-- elseif ( info.cvar == "EnableMicrophone" ) then
				-- VoiceOptionsFrame_UpdateMicrophoneControls();
			-- end
		-- end
		return;
	elseif ( event == "SOUND_DEVICE_UPDATE" ) then
		VoiceOptionsFrame_RefreshSoundDevices();
	end
end

function VoiceOptionsFrame_OnShow()
	AudioOptionsFrame_Load();
	VoiceOptionsFrame_Update();
	VoiceOptionsFrameType_Update();
end

function VoiceOptionsFrame_OnUpdate(elapsed)
	local fade = VoiceOptionsFrameBindingOutput.fade;
	if ( fade ) then
		if ( fade < 0 ) then
			UIFrameFadeOut(VoiceOptionsFrameBindingOutput, 2); 
			fade = nil;
		else
			fade = fade - elapsed;
		end
	end	
	if ( VoiceOptionsFrame:IsShown() ) then
		VoiceChatTalkers:SetAlpha(1);
	end
	VoiceOptionsFrameBindingOutput.fade = fade;
end

function VoiceOptionsFrame_Update()
	local state = GetCVar("EnableVoiceChat");
	if ( VoiceIsDisabledByClient() ) then
		--Comsat is disabled either because the computer is way old (No SSE) or another copy of WoW is running.
		state = "0";
		VoiceOptionsFrameCheckButton1:Hide();
		VoiceOptionsFrameDisabledMessage:Show();
	elseif ( not VoiceOptionsFrameCheckButton1:IsShown() ) then
		--Pretty certain this won't be changing dynamically, but better safe than sorry.
		VoiceOptionsFrameCheckButton1:Show();
		VoiceOptionsFrameDisabledMessage:Hide();
	end
	
	if ( VoiceOptionsFrame:IsVisible() ) then
		if ( VoiceChatTalkers:IsVisible() and state == "0" ) then
			VoiceChatTalkers:Hide();
			-- update the managed frame positions since the voice chat button is one of the managed frames
			UIParent_ManageFramePositions();
		elseif ( not VoiceChatTalkers:IsVisible() and state == "1"  ) then
			VoiceChatTalkers:Show();
			-- update the managed frame positions since the voice chat button is one of the managed frames
			UIParent_ManageFramePositions();
		end
	end
	VoiceOptionsFrameCheckButton1:SetChecked(state);
	if ( state == "0" ) then
		UIDropDownMenu_DisableDropDown(VoiceOptionsFrameTypeDropDown);
		UIDropDownMenu_DisableDropDown(VoiceOptionsFrameOutputDeviceDropDown);

		VoiceOptionsFrameType1KeyBindingButton:Disable();
		
		for i, value in pairs(VoiceOptionsFrameDisableList) do
			getglobal(i):SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		end

		for i, value in pairs(VoiceOptionsFrameSliders) do
			AudioOptionsFrame_DisableSlider(getglobal("VoiceOptionsFrameSlider"..value.index));
		end
		OptionsFrame_DisableCheckBox(VoiceOptionsFrameCheckButton2);
		OptionsFrame_DisableCheckBox(VoiceOptionsFrameCheckButton3);
		VoiceOptionsFrame_UpdateMicrophoneControls();
		
		if ( ChannelPullout:IsShown() ) then
			ChannelPullout_ToggleDisplay();
		end
	else
		UIDropDownMenu_EnableDropDown(VoiceOptionsFrameTypeDropDown);
		if ( Sound_ChatSystem_GetNumOutputDrivers() > 0 ) then
			UIDropDownMenu_EnableDropDown(VoiceOptionsFrameOutputDeviceDropDown);
		else
			UIDropDownMenu_DisableDropDown(VoiceOptionsFrameOutputDeviceDropDown);
		end
		VoiceOptionsFrameType1KeyBindingButton:Enable();		

		for i, value in pairs(VoiceOptionsFrameDisableList) do
			getglobal(i):SetVertexColor(value.r, value.g, value.b);
		end
		
		for i, value in pairs(VoiceOptionsFrameSliders) do
			AudioOptionsFrame_EnableSlider(getglobal("VoiceOptionsFrameSlider"..i));
		end
		OptionsFrame_EnableCheckBox(VoiceOptionsFrameCheckButton3);
		
		if ( Sound_ChatSystem_GetNumInputDrivers() > 0 ) then
			OptionsFrame_EnableCheckBox(VoiceOptionsFrameCheckButton2);
			VoiceOptionsFrame_UpdateMicrophoneControls();
		else
			OptionsFrame_DisableCheckBox(VoiceOptionsFrameCheckButton2);
			VoiceOptionsFrame_DisableMicrophoneControls();
		end
	end	
end

function VoiceOptionsFrameType_Update()
	if ( UIDropDownMenu_GetSelectedValue(VoiceOptionsFrameTypeDropDown) == "0" ) then
		 VoiceOptionsFrameType1:Show(); 
		 VoiceOptionsFrameType2:Hide();
	else
		 VoiceOptionsFrameType1:Hide(); 
		 VoiceOptionsFrameType2:Show();		
	end
end

function VoiceOptionsFrame_Load()
	local button, string, checked, mode;
	for index, value in pairs(VoiceOptionsFrameCheckButtons) do
		button = getglobal("VoiceOptionsFrameCheckButton"..value.index);
		string = getglobal("VoiceOptionsFrameCheckButton"..value.index.."Text");
		checked = nil;
		button.disabled = nil;
		if ( value.cvar ) then
			value.initialValue = GetCVar(value.cvar);
			if ( value.initialValue == "1" ) then
				checked = 1;
			end
		elseif ( value.uvar ) then
			value.initialValue = getglobal(value.uvar)
			checked = getglobal(value.uvar);
		end
		OptionsFrame_EnableCheckBox(button);
		button:SetChecked(checked);
		string:SetText(getglobal(index));
		button.tooltipText = value.tooltipText;
	end
	for index, value in pairs(VoiceOptionsFrameSliders) do
		local slider = getglobal("VoiceOptionsFrameSlider"..index);
		local string = getglobal("VoiceOptionsFrameSlider"..index.."Text");
		local pct = getglobal("VoiceOptionsFrameSlider"..index.."Value");
		local getvalue = GetCVar(value.cvar);
		value.initialValue = getvalue;
		if ( value.cvar == "VoiceActivationSensitivity" ) then
			getvalue = 1 - getvalue;
		end
		AudioOptionsFrame_EnableSlider(slider);
		slider:SetMinMaxValues(value.minValue, value.maxValue);
		slider:SetValueStep(value.valueStep);
		slider:SetValue(getvalue);
		string:SetText(value.text);
		if ( pct ) then
			pct:SetText(ceil(getvalue*100).."%");
		end
		slider.tooltipText = value.tooltipText;
		slider.tooltipRequirement = value.tooltipRequirement;
	end
	--Set the button text width and height to truncate it and keep it from wrapping
	VoiceOptionsFrameType1KeyBindingButtonText:SetWidth(135);
	VoiceOptionsFrameType1KeyBindingButtonText:SetHeight(13);

	VoiceOptionsFrameTypeDropDown_Load();
	VoiceOptionsFrameOutputDeviceDropDown_Load();
	VoiceOptionsFrameInputDeviceDropDown_Load();
end

function VoiceOptionsFrameCheckButton_OnClick()
	if ( this:GetChecked() ) then
		checked = "1";
	else
		checked = "0";
	end
	for index, value in pairs(VoiceOptionsFrameCheckButtons) do
		if ( value.index == this:GetID() ) then
			if ( value.cvar ) then
				SetCVar(value.cvar, checked);
			else
				setglobal(value.uvar, checked);
			end
		end
	end
	if ( this:GetChecked() ) then
		PlaySound("igMainMenuOptionCheckBoxOff");
	else
		PlaySound("igMainMenuOptionCheckBoxOn");
	end
end

function VoiceOptionsFrameSlider_OnValueChanged()
	local valueText = getglobal(this:GetName().."Value");
	-- need to scale the value down to between 0 and 1
	local val;
	local valueCVar;
	
	for index, value in pairs(VoiceOptionsFrameSliders) do
		if ( value.index == this:GetID() ) then
			if ( value.cvar == "VoiceActivationSensitivity" ) then
				valueCVar = 1 - this:GetValue();
			else
				valueCVar = this:GetValue();
			end
			if ( valueText ) then
				val = ceil(valueCVar * 100); 
				valueText:SetText(tostring(val).."%");
			end
			SetCVar(value.cvar, valueCVar);
			value.previousValue = valueCVar;
		end
	end
end


function VoiceOptionsFrame_Cancel()
	for index, value in pairs(VoiceOptionsFrameCheckButtons) do
		if ( value.cvar ) then
			SetCVar(value.cvar, value.initialValue);
		else
			setglobal(value.uvar, value.initialValue);
		end
	end
	for index, value in pairs(VoiceOptionsFrameSliders) do
		SetCVar(value.cvar, value.initialValue);
	end
	MiniMapVoiceChat_Update();
	VoiceChat_Toggle();

	SetCVar("VoiceChatMode", VoiceOptionsFrameTypeDropDown.initialValue);
	UIDropDownMenu_SetSelectedValue(VoiceOptionsFrameTypeDropDown, VoiceOptionsFrameTypeDropDown.initialValue);
	UIDropDownMenu_SetText(VoiceOptionsFrameTypeDropDown.initialText, VoiceOptionsFrameTypeDropDown);

	if ( VoiceOptionsFrameInputDeviceDropDown.initialValue ) then
		SetCVar("Sound_VoiceChatInputDriverIndex", VoiceOptionsFrameInputDeviceDropDown.initialValue);
		if ( VoiceGetCurrentCaptureDevice() ~= tonumber(VoiceOptionsFrameInputDeviceDropDown.initialValue) ) then
			VoiceSelectCaptureDevice(VoiceEnumerateCaptureDevices(VoiceOptionsFrameInputDeviceDropDown.initialValue));
		end
		UIDropDownMenu_SetSelectedValue(VoiceOptionsFrameInputDeviceDropDown, VoiceOptionsFrameInputDeviceDropDown.initialValue, 1);
		UIDropDownMenu_SetText(VoiceOptionsFrameInputDeviceDropDown.initialText, VoiceOptionsFrameInputDeviceDropDown);
		VoiceOptionsFrameInputDeviceDropDown.initialValue = nil;
	end

	if ( VoiceOptionsFrameOutputDeviceDropDown.initialValue ) then
		SetCVar("Sound_VoiceChatOutputDriverIndex", VoiceOptionsFrameOutputDeviceDropDown.initialValue);
		if ( VoiceGetCurrentOutputDevice() ~= tonumber(VoiceOptionsFrameOutputDeviceDropDown.initialValue) ) then
			VoiceSelectOutputDevice(VoiceEnumerateOutputDevices(VoiceOptionsFrameOutputDeviceDropDown.initialValue));
		end
		UIDropDownMenu_SetSelectedValue(VoiceOptionsFrameOutputDeviceDropDown, VoiceOptionsFrameOutputDeviceDropDown.initialValue, 1);
		UIDropDownMenu_SetText(VoiceOptionsFrameOutputDeviceDropDown.initialText, VoiceOptionsFrameOutputDeviceDropDown);
		VoiceOptionsFrameOutputDeviceDropDown.initialValue = nil;
	end
end

function VoiceOptionsFrame_Okay()
	MiniMapVoiceChat_Update();
	VoiceChat_Toggle();
end


function VoiceChatOptionsFrameBindingButton_OnShow()
	PUSH_TO_TALK_BUTTON = GetCVar("PushToTalkButton");
	local bindingText = GetBindingText(PUSH_TO_TALK_BUTTON, "KEY_");
	VoiceOptionsFrameType1KeyBindingButtonHiddenText:SetText(bindingText);
	this:SetText(bindingText);
end

function VoiceChatOptionsFrameBindingButton_OnClick(button)
	if ( button == "UNKNOWN" ) then
		return;
	end
	if ( not IsShiftKeyDown() and not IsControlKeyDown() and not IsAltKeyDown() ) then
		if ( button == "LeftButton" or button == "RightButton" ) then
			if ( this.buttonPressed ) then
				this:UnlockHighlight();
				this.buttonPressed = nil;
				VoiceOptionsFrameBindingOutputText:SetText("");
			else
				this:LockHighlight();
				this.buttonPressed = 1;
				VoiceOptionsFrameBindingOutputText:SetText(CAN_BIND_PTT);
			end
			VoiceOptionsFrameBindingOutput:SetAlpha(1.0)
			VoiceOptionsFrameBindingOutput.fade = nil;
			UIFrameFadeIn(VoiceOptionsFrameBindingOutput, 0); 
			PUSH_TO_TALK_BUTTON = "";
			PUSH_TO_TALK_MODIFIER = "";
			return;
		end
	end

	if ( this.buttonPressed ) then
		if ( PUSH_TO_TALK_BUTTON ~= "" ) then
			VoiceOptionsFrameBindingOutputText:SetText(ERROR_CANNOT_BIND);
			VoiceOptionsFrameBindingOutput:SetAlpha(1.0);
			VoiceOptionsFrameBindingOutput.fade = 6;
			VoiceOptionsFrameBindingOutputText:SetVertexColor(1, 1, 1);
			VoiceOptionsFrameBindingOutputText:SetText("");
			this:UnlockHighlight();
			this.buttonPressed = nil;
			return;
		end

		if ( PUSH_TO_TALK_MODIFIER == "" ) then
			PUSH_TO_TALK_BUTTON = button;
		else
			PUSH_TO_TALK_BUTTON = PUSH_TO_TALK_MODIFIER.."-"..button;
		end
		VoiceChatOptionsFrameBindingButton_BindButton();
	end
end

function VoiceChatOptionsFrameBindingButton_BindButton()
	if ( PUSH_TO_TALK_BUTTON == "" and PUSH_TO_TALK_MODIFIER ~= "" ) then
		PUSH_TO_TALK_BUTTON = PUSH_TO_TALK_MODIFIER;
	end
	if ( PUSH_TO_TALK_BUTTON ~= "" ) then
		SetCVar("PushToTalkButton", PUSH_TO_TALK_BUTTON);
		local bindingText = GetBindingText(PUSH_TO_TALK_BUTTON, "KEY_");
		this:SetText(bindingText);
		VoiceOptionsFrameType1KeyBindingButtonHiddenText:SetText(bindingText);

		this:UnlockHighlight();
		this.buttonPressed = nil;

		local currentbinding = GetBindingByKey(PUSH_TO_TALK_BUTTON);
		if ( currentbinding ) then
			 UIErrorsFrame:AddMessage( format(ALREADY_BOUND, GetBindingText(currentbinding, "BINDING_NAME_")), 1.0, 1.0, 0, 1, 10) 
		end

		VoiceOptionsFrameBindingOutputText:SetText(PTT_BOUND);
		VoiceOptionsFrameBindingOutput:SetAlpha(1.0);
		VoiceOptionsFrameBindingOutput.fade = VOICE_OPTIONS_BINDING_FADE;
	end
	VoiceChatOptionsFrameBindingButton_SetTooltip();
	if ( GameTooltip:GetOwner() == this ) then
		VoiceChatOptionsFrameBindingButton_OnEnter();
	end
end

function VoiceChatOptionsFrameBindingButton_OnKeyUp(button)
	if ( this.buttonPressed ) then
		VoiceChatOptionsFrameBindingButton_BindButton();
	end
end

function VoiceChatOptionsFrameBindingButton_OnKeyDown(button)
	if ( not this.buttonPressed and button == "ESCAPE" ) then
		PlaySound("gsTitleOptionExit");
		VoiceOptionsFrame_Cancel();
		SoundOptionsFrame_Cancel();
		VoiceOptionsFrameBindingOutputText:SetText("");
		VoiceOptionsFrameBindingOutput.fade = nil;
		HideUIPanel(AudioOptionsFrame);
	else
		if ( GetBindingFromClick(arg1) == "SCREENSHOT" ) then
			RunBinding("SCREENSHOT");
			return;
		end
		if ( this.buttonPressed ) then
			if ( button == "UNKNOWN" ) then
				return;
			end

			if ( button == "LSHIFT" or button == "RSHIFT" or button == "LCTRL" or button == "RCTRL" or button == "LALT" or button == "RALT" ) then
				if ( PUSH_TO_TALK_MODIFIER == "" ) then
					PUSH_TO_TALK_MODIFIER = button;
				else
					PUSH_TO_TALK_MODIFIER = PUSH_TO_TALK_MODIFIER.."-"..button;
				end
				return;
			elseif ( PUSH_TO_TALK_BUTTON ~= "" ) then
				VoiceOptionsFrameBindingOutputText:SetText(ERROR_CANNOT_BIND);
				VoiceOptionsFrameBindingOutput:SetAlpha(1.0);
				VoiceOptionsFrameBindingOutput.fade = 6;
				this:UnlockHighlight();
				this.buttonPressed = nil;
				return;
			end

			if ( PUSH_TO_TALK_MODIFIER == "" ) then
				PUSH_TO_TALK_BUTTON = button;
			else
				PUSH_TO_TALK_BUTTON = PUSH_TO_TALK_MODIFIER.."-"..button;
			end
		end
	end
end

function VoiceChatOptionsFrameBindingButton_SetTooltip()
	local textWidth = VoiceOptionsFrameType1KeyBindingButtonHiddenText:GetWidth();	
	if ( textWidth > 135) then
		this.tooltip = VoiceOptionsFrameType1KeyBindingButtonHiddenText:GetText();
	else
		this.tooltip = nil;
	end
end

function VoiceChatOptionsFrameBindingButton_OnEnter()
	if ( this.tooltip ) then
		GameTooltip:SetOwner(this);
		GameTooltip:SetText(this.tooltip);
		GameTooltip:Show();
	end
end

-- Voice Chat Type DropDown
function VoiceOptionsFrameTypeDropDown_Load()
	UIDropDownMenu_Initialize(VoiceOptionsFrameTypeDropDown, VoiceOptionsFrameTypeDropDown_Initialize);

	local voiceChatMode = GetCVar("VoiceChatMode");
	VoiceOptionsFrameTypeDropDown.initialValue = voiceChatMode;
	UIDropDownMenu_SetSelectedValue(VoiceOptionsFrameTypeDropDown, voiceChatMode);

	VoiceOptionsFrameTypeDropDown.initialText = UIDropDownMenu_GetText(VoiceOptionsFrameTypeDropDown);

	VoiceOptionsFrameTypeDropDown.tooltip = getglobal("OPTION_TOOLTIP_VOICE_TYPE"..(voiceChatMode+1));
	UIDropDownMenu_SetWidth(140, VoiceOptionsFrameTypeDropDown);
end

function VoiceOptionsFrameTypeDropDown_OnClick()
	UIDropDownMenu_SetSelectedValue(VoiceOptionsFrameTypeDropDown, this.value);
	VoiceOptionsFrameTypeDropDown.tooltip = getglobal("OPTION_TOOLTIP_VOICE_TYPE"..(this.value+1));
	SetCVar("VoiceChatMode", this.value);
	VoiceOptionsFrameType_Update();
	SetSelfMuteState();
end

function VoiceOptionsFrameTypeDropDown_Initialize()
	local selectedValue = UIDropDownMenu_GetSelectedValue(VoiceOptionsFrameTypeDropDown);
	local info = UIDropDownMenu_CreateInfo();

	info.text = PUSH_TO_TALK;
	info.func = VoiceOptionsFrameTypeDropDown_OnClick;
	info.value = "0";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = PUSH_TO_TALK;
	info.tooltipText = OPTION_TOOLTIP_VOICE_TYPE1;
	UIDropDownMenu_AddButton(info);

	info.text = VOICE_ACTIVATED;
	info.func = VoiceOptionsFrameTypeDropDown_OnClick;
	info.value = "1";
	if ( info.value == selectedValue ) then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = VOICE_ACTIVATED;
	info.tooltipText  = OPTION_TOOLTIP_VOICE_TYPE2;
	UIDropDownMenu_AddButton(info);
end

function out(text)
	 DEFAULT_CHAT_FRAME:AddMessage(text)
	 UIErrorsFrame:AddMessage(text, 1.0, 1.0, 0, 1, 10) 
end

--Run on SOUND_DEVICE_UPDATE
function VoiceOptionsFrame_RefreshSoundDevices ()
	VoiceOptionsFrame_Update();
	
	local deviceName, numDrivers, currentDevice, currentValue, initialValue;
	
	local found = false;
	
	--Clear the initial value setting to prevent unexpected behaviors if non-selected option is the initialValue when devices update and that non-selected option still exists.
	--This is kinda wonky but anything else would require a more substantial rework.
	initialValue = VoiceOptionsFrameInputDeviceDropDown.initialValue;
	VoiceOptionsFrameInputDeviceDropDown.initialValue = nil;
	
	numDrivers = Sound_ChatSystem_GetNumInputDrivers();
	if ( numDrivers > 0 ) then
		currentDevice = UIDropDownMenu_GetText(VoiceOptionsFrameInputDeviceDropDown);
		currentValue = UIDropDownMenu_GetSelectedValue(VoiceOptionsFrameInputDeviceDropDown);
		for index = 0, numDrivers - 1 do
			--Check to see if the previously selected input device still exists, if it does, use that.
			deviceName = VoiceEnumerateCaptureDevices(index);
			if ( deviceName == currentDevice ) then
				UIDropDownMenu_SetSelectedValue(VoiceOptionsFrameInputDeviceDropDown, index);
				UIDropDownMenu_SetText(deviceName, VoiceOptionsFrameInputDeviceDropDown);
				if ( currentValue == initialValue ) then
					VoiceOptionsFrameInputDeviceDropDown.initialValue = index;
				end
				VoiceOptionsFrame_SetInputDevice(index);
				found = true;
			end
		end
		
		--Default to system default!
		if ( not found ) then
			UIDropDownMenu_SetSelectedValue(VoiceOptionsFrameInputDeviceDropDown, 0);
			UIDropDownMenu_SetText(VoiceEnumerateCaptureDevices(0), VoiceOptionsFrameInputDeviceDropDown);
			VoiceOptionsFrameInputDeviceDropDown.initialValue = 0;
			VoiceOptionsFrame_SetInputDevice(0);
		end
	end
	
	found = false;
	
	initialValue = VoiceOptionsFrameOutputDeviceDropDown.initialValue;
	VoiceOptionsFrameOutputDeviceDropDown.initialValue = nil;
	
	numDrivers = Sound_ChatSystem_GetNumOutputDrivers();
	if ( numDrivers > 0 ) then
		currentDevice = UIDropDownMenu_GetText(VoiceOptionsFrameOutputDeviceDropDown);
		currentValue = UIDropDownMenu_GetSelectedValue(VoiceOptionsFrameOutputDeviceDropDown);
		for index = 0, numDrivers -1 do
			deviceName = Sound_ChatSystem_GetOutputDriverNameByIndex(index);
			if ( deviceName == currentDevice ) then
				UIDropDownMenu_SetSelectedValue(VoiceOptionsFrameOutputDeviceDropDown, index);
				UIDropDownMenu_SetText(deviceName, VoiceOptionsFrameOutputDeviceDropDown);
				if ( currentValue == initialValue ) then
					VoiceOptionsFrameOutputDeviceDropDown.initialValue = index;
				end
				VoiceOptionsFrame_SetOutputDevice(index);
				found = true;
				break;
			end
		end
		
		if ( not found ) then
			UIDropDownMenu_SetSelectedValue(VoiceOptionsFrameOutputDeviceDropDown, 0);
			UIDropDownMenu_SetText(VoiceEnumerateOutputDevices(0), VoiceOptionsFrameOutputDeviceDropDown);
			VoiceOptionsFrameOutputDeviceDropDown.initialValue = 0;
			VoiceOptionsFrame_SetOutputDevice(0);
		end
	end
end

-- Input Device DropDown
function VoiceOptionsFrameInputDeviceDropDown_Load()
	UIDropDownMenu_Initialize(VoiceOptionsFrameInputDeviceDropDown, VoiceOptionsFrameInputDeviceDropDown_Initialize);
	UIDropDownMenu_SetWidth(140, VoiceOptionsFrameInputDeviceDropDown);

	local selectedInputDriverIndex = GetCVar("Sound_VoiceChatInputDriverIndex");
	VoiceOptionsFrameInputDeviceDropDown.initialValue = selectedInputDriverIndex;
	local deviceName = VoiceEnumerateCaptureDevices(selectedInputDriverIndex);
	VoiceOptionsFrameInputDeviceDropDown.initialText = deviceName;
	UIDropDownMenu_SetSelectedValue(VoiceOptionsFrameInputDeviceDropDown, deviceName, 1);
	UIDropDownMenu_SetText(deviceName, VoiceOptionsFrameInputDeviceDropDown);
end

function VoiceOptionsFrameInputDeviceDropDown_OnClick()
	UIDropDownMenu_SetSelectedValue(VoiceOptionsFrameInputDeviceDropDown, this.value);
	VoiceOptionsFrame_SetInputDevice(this.value);
end

function VoiceOptionsFrameInputDeviceDropDown_Initialize()
	local selectedInputDriverIndex = GetCVar("Sound_VoiceChatInputDriverIndex");
	local num = Sound_ChatSystem_GetNumInputDrivers();
	local info = UIDropDownMenu_CreateInfo();
	for index=0,num-1,1 do
		local description = Sound_ChatSystem_GetInputDriverNameByIndex(index);
		info.text = description;
		info.value = index;
		info.checked = nil;
		if (index == tonumber(selectedInputDriverIndex)) then
			info.checked = 1;
		end
		info.func = VoiceOptionsFrameInputDeviceDropDown_OnClick;
		
		UIDropDownMenu_AddButton(info);
	end
	
	UIDropDownMenu_SetSelectedValue(VoiceOptionsFrameInputDeviceDropDown, tonumber(selectedInputDriverIndex));
end

-- Output Device DropDown
function VoiceOptionsFrameOutputDeviceDropDown_Load()
	--local selectedValue = VoiceEnumerateOutputDevices(VoiceGetCurrentOutputDevice());
	local selectedOutputDriverIndex = GetCVar("Sound_VoiceChatOutputDriverIndex");
	VoiceOptionsFrameOutputDeviceDropDown.initialValue = selectedOutputDriverIndex;
	local deviceName = VoiceEnumerateOutputDevices(selectedOutputDriverIndex);
	VoiceOptionsFrameOutputDeviceDropDown.initialText = deviceName;
	UIDropDownMenu_Initialize(VoiceOptionsFrameOutputDeviceDropDown, VoiceOptionsFrameOutputDeviceDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(VoiceOptionsFrameOutputDeviceDropDown, deviceName, 1);
	UIDropDownMenu_SetText(deviceName, VoiceOptionsFrameOutputDeviceDropDown);
	UIDropDownMenu_SetWidth(140, VoiceOptionsFrameOutputDeviceDropDown);
end

function VoiceOptionsFrameOutputDeviceDropDown_OnClick()
	UIDropDownMenu_SetSelectedValue(VoiceOptionsFrameOutputDeviceDropDown, this.value);
	VoiceOptionsFrame_SetOutputDevice(this.value);
end

function VoiceOptionsFrameOutputDeviceDropDown_Initialize()
	local selectedOutputDriverIndex = GetCVar("Sound_VoiceChatOutputDriverIndex");
	local num = Sound_ChatSystem_GetNumOutputDrivers();
	local info = UIDropDownMenu_CreateInfo();
	for index=0,num-1,1 do
		local description = Sound_ChatSystem_GetOutputDriverNameByIndex(index);
		info.text = description;
		info.value = index;
        info.checked = nil;
        if (index == tonumber(selectedOutputDriverIndex)) then
			info.checked = 1;
		end
		info.func = VoiceOptionsFrameOutputDeviceDropDown_OnClick;
		
		UIDropDownMenu_AddButton(info);
	end
end


function VoiceOptionsFrame_SetOutputDevice(deviceIndex)
	VoiceSelectOutputDevice(VoiceEnumerateOutputDevices(deviceIndex));
end

function VoiceOptionsFrame_SetInputDevice(deviceIndex)
	VoiceSelectCaptureDevice(VoiceEnumerateCaptureDevices(deviceIndex));
end

--==============================
--
-- Record Loopback functions
--
--==============================
function UpdateRecordLoopbackButton()
	if ( this.clicked ) then
		if (GetCVar("EnableVoiceChat") == "0" or GetCVar("EnableMicrophone") == "0") then
			RecordLoopbackSoundButton:Disable();
			RecordLoopbackSoundButtonTexture:SetVertexColor(0.5, 0.5, 0.5);								
		else
			local isRecording = VoiceChat_IsRecordingLoopbackSound();
			if ( isRecording == 0 ) then
				RecordLoopbackSoundButton:Enable();
				RecordLoopbackSoundButtonTexture:SetVertexColor(1, 0, 0);	
				this.clicked = nil;
			else
				RecordLoopbackSoundButton:Disable();
				RecordLoopbackSoundButtonTexture:SetVertexColor(0.5, 0.5, 0.5);								
			end
		end
	end
end

--==============================
--
-- VU Meter functions
--
--==============================

function LoopbackVUMeter_Init()
    LoopbackVUMeter:SetMinMaxValues(0, 100);
	LoopbackVUMeter:SetValue(0);
end


function LoopbackVUMeter_Update()
    local isRecording = VoiceChat_IsRecordingLoopbackSound();
    local isPlaying = VoiceChat_IsPlayingLoopbackSound();
    if ( isRecording == 0 and isPlaying == 0 ) then
        LoopbackVUMeter:SetValue(0);
    else
        local volume = VoiceChat_GetCurrentMicrophoneSignalLevel();
        LoopbackVUMeter:SetValue(volume);
    end
end

--==============================
--
-- Functions for managing "Talking" pane
--
--==============================

function VoiceOptionsFrame_UpdateMicrophoneControls()
	if ( GetCVar("EnableVoiceChat") == "0" or GetCVar("EnableMicrophone") == "0" or VoiceIsDisabledByClient() ) then
		--If VoiceChat is disabled, the microphone controls should be too.
		VoiceOptionsFrame_DisableMicrophoneControls();
	else
		VoiceOptionsFrame_EnableMicrophoneControls();
	end
end

function VoiceOptionsFrame_DisableMicrophoneControls ()
	UIDropDownMenu_DisableDropDown(VoiceOptionsFrameInputDeviceDropDown);
	RecordLoopbackSoundButton:Disable();
	PlayLoopbackSoundButton:Disable();
	VoiceChat_StopRecordingLoopbackSound();
	VoiceChat_StopPlayingLoopbackSound();
	
	for i in pairs(VoiceOptionsFrameMicrophoneList) do
		getglobal(i):SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
	
	AudioOptionsFrame_DisableSlider(VoiceOptionsFrameSlider2);
end

function VoiceOptionsFrame_EnableMicrophoneControls ()
	UIDropDownMenu_EnableDropDown(VoiceOptionsFrameInputDeviceDropDown);
	RecordLoopbackSoundButton:Enable();
	PlayLoopbackSoundButton:Enable();

	for i, value in pairs(VoiceOptionsFrameMicrophoneList) do
		getglobal(i):SetVertexColor(value.r, value.g, value.b);
	end
	
	AudioOptionsFrame_EnableSlider(VoiceOptionsFrameSlider2);
end
