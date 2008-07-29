VOICE_OPTIONS_BINDING_FADE = 3;

VoiceOptionsFrameCheckButtons = { };
VoiceOptionsFrameCheckButtons["ENABLE_VOICECHAT"] = { index = 1, cvar = "EnableVoiceChat", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_VOICECHAT};
VoiceOptionsFrameCheckButtons["ENABLE_MICROPHONE"] = { index = 2, cvar = "EnableMicrophone", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_MICROPHONE};
VoiceOptionsFrameCheckButtons["PUSHTOTALK_SOUND_TEXT"] = { index = 3, cvar = "PushToTalkSound", initialValue = nil , tooltipText = OPTION_TOOLTIP_PUSHTOTALK_SOUND};

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

function VoiceOptionsFrame_OnLoad(self)
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("SOUND_DEVICE_UPDATE");
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

function VoiceOptionsFrame_OnShow(self)
	AudioOptionsFrame_Load();
	VoiceOptionsFrame_Update();
	VoiceOptionsFrameType_Update();
end

function VoiceOptionsFrame_OnUpdate(self, elapsed)
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

	VoiceOptionsFrameTypeDropDown_OnLoad(VoiceOptionsFrameTypeDropDown);
	VoiceOptionsFrameOutputDeviceDropDown_OnLoad(VoiceOptionsFrameOutputDeviceDropDown);
	VoiceOptionsFrameInputDeviceDropDown_OnLoad(VoiceOptionsFrameInputDeviceDropDown);
end

function VoiceOptionsFrameCheckButton_OnClick(self)
	if ( self:GetChecked() ) then
		checked = "1";
	else
		checked = "0";
	end
	for index, value in pairs(VoiceOptionsFrameCheckButtons) do
		if ( value.index == self:GetID() ) then
			if ( value.cvar ) then
				SetCVar(value.cvar, checked);
			else
				setglobal(value.uvar, checked);
			end
		end
	end
	if ( self:GetChecked() ) then
		PlaySound("igMainMenuOptionCheckBoxOff");
	else
		PlaySound("igMainMenuOptionCheckBoxOn");
	end
end

function VoiceOptionsFrameSlider_OnValueChanged(self, value)
	local valueText = getglobal(self:GetName().."Value");
	-- need to scale the value down to between 0 and 1
	local valueCVar;
	
	for index, slider in pairs(VoiceOptionsFrameSliders) do
		if ( slider.index == self:GetID() ) then
			if ( slider.cvar == "VoiceActivationSensitivity" ) then
				valueCVar = 1 - value;
			else
				valueCVar = value;
			end
			if ( valueText ) then
				value = ceil(valueCVar * 100); 
				valueText:SetText(tostring(value).."%");
			end
			SetCVar(slider.cvar, valueCVar);
			slider.previousValue = valueCVar;
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
	UIDropDownMenu_SetText(VoiceOptionsFrameTypeDropDown, VoiceOptionsFrameTypeDropDown.initialText);

	if ( VoiceOptionsFrameInputDeviceDropDown.initialValue ) then
		SetCVar("Sound_VoiceChatInputDriverIndex", VoiceOptionsFrameInputDeviceDropDown.initialValue);
		if ( VoiceGetCurrentCaptureDevice() ~= tonumber(VoiceOptionsFrameInputDeviceDropDown.initialValue) ) then
			VoiceSelectCaptureDevice(VoiceEnumerateCaptureDevices(VoiceOptionsFrameInputDeviceDropDown.initialValue));
		end
		UIDropDownMenu_SetSelectedValue(VoiceOptionsFrameInputDeviceDropDown, VoiceOptionsFrameInputDeviceDropDown.initialValue, 1);
		UIDropDownMenu_SetText(VoiceOptionsFrameInputDeviceDropDown, VoiceOptionsFrameInputDeviceDropDown.initialText);
		VoiceOptionsFrameInputDeviceDropDown.initialValue = nil;
	end

	if ( VoiceOptionsFrameOutputDeviceDropDown.initialValue ) then
		SetCVar("Sound_VoiceChatOutputDriverIndex", VoiceOptionsFrameOutputDeviceDropDown.initialValue);
		if ( VoiceGetCurrentOutputDevice() ~= tonumber(VoiceOptionsFrameOutputDeviceDropDown.initialValue) ) then
			VoiceSelectOutputDevice(VoiceEnumerateOutputDevices(VoiceOptionsFrameOutputDeviceDropDown.initialValue));
		end
		UIDropDownMenu_SetSelectedValue(VoiceOptionsFrameOutputDeviceDropDown, VoiceOptionsFrameOutputDeviceDropDown.initialValue, 1);
		UIDropDownMenu_SetText(VoiceOptionsFrameOutputDeviceDropDown, VoiceOptionsFrameOutputDeviceDropDown.initialText);
		VoiceOptionsFrameOutputDeviceDropDown.initialValue = nil;
	end
end

function VoiceOptionsFrame_Okay()
	MiniMapVoiceChat_Update();
	VoiceChat_Toggle();
end


function VoiceChatOptionsFrameBindingButton_OnShow(self)
	PUSH_TO_TALK_BUTTON = GetCVar("PushToTalkButton");
	local bindingText = GetBindingText(PUSH_TO_TALK_BUTTON, "KEY_");
	VoiceOptionsFrameType1KeyBindingButtonHiddenText:SetText(bindingText);
	self:SetText(bindingText);
end

function VoiceChatOptionsFrameBindingButton_OnClick(self, button)
	if ( button == "UNKNOWN" ) then
		return;
	end
	if ( not IsShiftKeyDown() and not IsControlKeyDown() and not IsAltKeyDown() ) then
		if ( button == "LeftButton" or button == "RightButton" ) then
			if ( self.buttonPressed ) then
				self:UnlockHighlight();
				self.buttonPressed = nil;
				VoiceOptionsFrameBindingOutputText:SetText("");
			else
				self:LockHighlight();
				self.buttonPressed = 1;
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

	if ( self.buttonPressed ) then
		if ( PUSH_TO_TALK_BUTTON ~= "" ) then
			VoiceOptionsFrameBindingOutputText:SetText(ERROR_CANNOT_BIND);
			VoiceOptionsFrameBindingOutput:SetAlpha(1.0);
			VoiceOptionsFrameBindingOutput.fade = 6;
			VoiceOptionsFrameBindingOutputText:SetVertexColor(1, 1, 1);
			VoiceOptionsFrameBindingOutputText:SetText("");
			self:UnlockHighlight();
			self.buttonPressed = nil;
			return;
		end

		if ( PUSH_TO_TALK_MODIFIER == "" ) then
			PUSH_TO_TALK_BUTTON = button;
		else
			PUSH_TO_TALK_BUTTON = PUSH_TO_TALK_MODIFIER.."-"..button;
		end
		VoiceChatOptionsFrameBindingButton_BindButton(self);
	end
end

function VoiceChatOptionsFrameBindingButton_BindButton(self)
	if ( PUSH_TO_TALK_BUTTON == "" and PUSH_TO_TALK_MODIFIER ~= "" ) then
		PUSH_TO_TALK_BUTTON = PUSH_TO_TALK_MODIFIER;
	end
	if ( PUSH_TO_TALK_BUTTON ~= "" ) then
		SetCVar("PushToTalkButton", PUSH_TO_TALK_BUTTON);
		local bindingText = GetBindingText(PUSH_TO_TALK_BUTTON, "KEY_");
		self:SetText(bindingText);
		VoiceOptionsFrameType1KeyBindingButtonHiddenText:SetText(bindingText);

		self:UnlockHighlight();
		self.buttonPressed = nil;

		local currentbinding = GetBindingByKey(PUSH_TO_TALK_BUTTON);
		if ( currentbinding ) then
			 UIErrorsFrame:AddMessage( format(ALREADY_BOUND, GetBindingText(currentbinding, "BINDING_NAME_")), 1.0, 1.0, 0, 1, 10) 
		end

		VoiceOptionsFrameBindingOutputText:SetText(PTT_BOUND);
		VoiceOptionsFrameBindingOutput:SetAlpha(1.0);
		VoiceOptionsFrameBindingOutput.fade = VOICE_OPTIONS_BINDING_FADE;
	end
	VoiceChatOptionsFrameBindingButton_SetTooltip(self);
	if ( GameTooltip:GetOwner() == self ) then
		VoiceChatOptionsFrameBindingButton_OnEnter(self);
	end
end

function VoiceChatOptionsFrameBindingButton_OnKeyUp(self, button)
	if ( self.buttonPressed ) then
		VoiceChatOptionsFrameBindingButton_BindButton(self);
	end
end

function VoiceChatOptionsFrameBindingButton_OnKeyDown(self, button)
	if ( not self.buttonPressed and button == "ESCAPE" ) then
		PlaySound("gsTitleOptionExit");
		VoiceOptionsFrame_Cancel();
		SoundOptionsFrame_Cancel();
		VoiceOptionsFrameBindingOutputText:SetText("");
		VoiceOptionsFrameBindingOutput.fade = nil;
		HideUIPanel(AudioOptionsFrame);
	else
		if ( GetBindingFromClick(button) == "SCREENSHOT" ) then
			RunBinding("SCREENSHOT");
			return;
		end
		if ( self.buttonPressed ) then
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
				self:UnlockHighlight();
				self.buttonPressed = nil;
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

function VoiceChatOptionsFrameBindingButton_SetTooltip(self)
	local textWidth = VoiceOptionsFrameType1KeyBindingButtonHiddenText:GetWidth();	
	if ( textWidth > 135) then
		self.tooltip = VoiceOptionsFrameType1KeyBindingButtonHiddenText:GetText();
	else
		self.tooltip = nil;
	end
end

function VoiceChatOptionsFrameBindingButton_OnEnter(self)
	if ( self.tooltip ) then
		GameTooltip:SetOwner(self);
		GameTooltip:SetText(self.tooltip);
		GameTooltip:Show();
	end
end

-- Voice Chat Type DropDown
function VoiceOptionsFrameTypeDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, VoiceOptionsFrameTypeDropDown_Initialize);

	local voiceChatMode = GetCVar("VoiceChatMode");
	self.initialValue = voiceChatMode;
	UIDropDownMenu_SetSelectedValue(self, voiceChatMode);

	self.initialText = UIDropDownMenu_GetText(self);

	self.tooltip = getglobal("OPTION_TOOLTIP_VOICE_TYPE"..(voiceChatMode+1));
	UIDropDownMenu_SetWidth(self, 140);
end

function VoiceOptionsFrameTypeDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedValue(VoiceOptionsFrameTypeDropDown, self.value);
	VoiceOptionsFrameTypeDropDown.tooltip = getglobal("OPTION_TOOLTIP_VOICE_TYPE"..(self.value+1));
	SetCVar("VoiceChatMode", self.value);
	VoiceOptionsFrameType_Update();
	SetSelfMuteState();
end

function VoiceOptionsFrameTypeDropDown_Initialize(self)
	local selectedValue = UIDropDownMenu_GetSelectedValue(self);
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
				UIDropDownMenu_SetText(VoiceOptionsFrameInputDeviceDropDown, deviceName);
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
			UIDropDownMenu_SetText(VoiceOptionsFrameInputDeviceDropDown, VoiceEnumerateCaptureDevices(0));
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
				UIDropDownMenu_SetText(VoiceOptionsFrameOutputDeviceDropDown, deviceName);
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
			UIDropDownMenu_SetText(VoiceOptionsFrameOutputDeviceDropDown, VoiceEnumerateOutputDevices(0));
			VoiceOptionsFrameOutputDeviceDropDown.initialValue = 0;
			VoiceOptionsFrame_SetOutputDevice(0);
		end
	end
end

-- Input Device DropDown
function VoiceOptionsFrameInputDeviceDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, VoiceOptionsFrameInputDeviceDropDown_Initialize);
	UIDropDownMenu_SetWidth(self, 140);

	local selectedInputDriverIndex = GetCVar("Sound_VoiceChatInputDriverIndex");
	self.initialValue = selectedInputDriverIndex;
	local deviceName = VoiceEnumerateCaptureDevices(selectedInputDriverIndex);
	self.initialText = deviceName;
	UIDropDownMenu_SetSelectedValue(self, deviceName, 1);
	UIDropDownMenu_SetText(self, deviceName);
end

function VoiceOptionsFrameInputDeviceDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedValue(VoiceOptionsFrameInputDeviceDropDown, self.value);
	VoiceOptionsFrame_SetInputDevice(self.value);
end

function VoiceOptionsFrameInputDeviceDropDown_Initialize(self)
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
	
	UIDropDownMenu_SetSelectedValue(self, tonumber(selectedInputDriverIndex));
end

-- Output Device DropDown
function VoiceOptionsFrameOutputDeviceDropDown_OnLoad(self)
	--local selectedValue = VoiceEnumerateOutputDevices(VoiceGetCurrentOutputDevice());
	local selectedOutputDriverIndex = GetCVar("Sound_VoiceChatOutputDriverIndex");
	self.initialValue = selectedOutputDriverIndex;
	local deviceName = VoiceEnumerateOutputDevices(selectedOutputDriverIndex);
	self.initialText = deviceName;
	UIDropDownMenu_Initialize(self, VoiceOptionsFrameOutputDeviceDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(self, deviceName, 1);
	UIDropDownMenu_SetText(self, deviceName);
	UIDropDownMenu_SetWidth(self, 140);
end

function VoiceOptionsFrameOutputDeviceDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedValue(VoiceOptionsFrameOutputDeviceDropDown, self.value);
	VoiceOptionsFrame_SetOutputDevice(self.value);
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
function RecordLoopbackSoundButton_OnUpdate(self)
	if ( self.clicked ) then
		if (GetCVar("EnableVoiceChat") == "0" or GetCVar("EnableMicrophone") == "0") then
			RecordLoopbackSoundButton:Disable();
			RecordLoopbackSoundButtonTexture:SetVertexColor(0.5, 0.5, 0.5);								
		else
			local isRecording = VoiceChat_IsRecordingLoopbackSound();
			if ( isRecording == 0 ) then
				RecordLoopbackSoundButton:Enable();
				RecordLoopbackSoundButtonTexture:SetVertexColor(1, 0, 0);	
				self.clicked = nil;
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

function LoopbackVUMeter_OnLoad(self)
    self:SetMinMaxValues(0, 100);
	self:SetValue(0);
end


function LoopbackVUMeter_OnUpdate(self, elapsed)
    local isRecording = VoiceChat_IsRecordingLoopbackSound();
    local isPlaying = VoiceChat_IsPlayingLoopbackSound();
    if ( isRecording == 0 and isPlaying == 0 ) then
        self:SetValue(0);
    else
        local volume = VoiceChat_GetCurrentMicrophoneSignalLevel();
        self:SetValue(volume);
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
