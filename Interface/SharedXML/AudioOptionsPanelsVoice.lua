-- [[ Voice Options Panel ]] --

VoicePanelOptions = {
	EnableVoiceChat = { text = "ENABLE_VOICECHAT" },
	EnableMicrophone = { text = "ENABLE_MICROPHONE" },
	OutboundChatVolume = { text = "VOICE_INPUT_VOLUME", minValue = 0.25, maxValue = 2.5, valueStep = 0.05 },
	InboundChatVolume = { text = "VOICE_OUTPUT_VOLUME", minValue = 0, maxValue = 1, valueStep = 0.01 },
	ChatSoundVolume = { text = "", minValue = 0, maxValue = 1, valueStep = 0.01, tooltip = OPTION_TOOLTIP_VOICE_SOUND },
	ChatMusicVolume = { text = "", minValue = 0, maxValue = 1, valueStep = 0.01, tooltip = OPTION_TOOLTIP_VOICE_MUSIC },
	ChatAmbienceVolume = { text = "", minValue = 0, maxValue = 1, valueStep = 0.01, tooltip = OPTION_TOOLTIP_VOICE_AMBIENCE },
	PushToTalkSound = { text = "PUSHTOTALK_SOUND_TEXT" },
	VoiceActivationSensitivity = { text = "VOICE_ACTIVATION_SENSITIVITY", minValue = 0, maxValue = 1, valueStep = 0.02 },
}

local AudioOptionsVoicePanelFrameMicrophoneList =
{
	AudioOptionsVoicePanelMicrophoneVolumeLabel = NORMAL_FONT_COLOR,
	AudioOptionsVoicePanelMicTestText = NORMAL_FONT_COLOR,
};

function AudioOptionsVoicePanel_OnDismiss(self, shouldApply)
	if self.PushToTalkKeybindButton then
		CustomBindingManager:OnDismissed(self.PushToTalkKeybindButton:GetCustomBindingType(), shouldApply);
	end
end

function AudioOptionsVoicePanel_Okay(self)
	BlizzardOptionsPanel_Okay(self);
	AudioOptionsVoicePanel_OnDismiss(self, true);
end

function AudioOptionsVoicePanel_Cancel(self)
	BlizzardOptionsPanel_Cancel(self);
	AudioOptionsVoicePanel_OnDismiss(self, false);
end

function AudioOptionsVoicePanel_Refresh(self)
	BlizzardOptionsPanel_Refresh(self);
	AudioOptionsVoicePanelEnableVoice_UpdateControls(self);
end

function AudioOptionsVoicePanel_OnLoad(self)
	self.name = VOICE_CHAT;
	self.options = VoicePanelOptions;
	self:SetScript("OnEvent", AudioOptionsVoicePanel_OnEvent);
	BlizzardOptionsPanel_OnLoad(self, AudioOptionsVoicePanel_Okay, AudioOptionsVoicePanel_Cancel, nil, AudioOptionsVoicePanel_Refresh);
end

function AudioOptionsVoicePanel_OnShow(self)
	VideoOptionsPanel_OnShow(self);
	AudioOptionsVoicePanel_InitializeCommunicationModeUI(self);
	self:RegisterEvent("UPDATE_BINDINGS");
	self:RegisterEvent("VOICE_CHAT_ERROR");
	self:RegisterEvent("VOICE_CHAT_CONNECTION_SUCCESS");
end

function AudioOptionsVoicePanel_OnHide(self)
	if self.PushToTalkKeybindButton then
		self.ChatModeDropdown.PushToTalkNotification:SetText("");
		CustomBindingManager:OnDismissed(self.PushToTalkKeybindButton:GetCustomBindingType(), false);
		BindingButtonTemplate_SetSelected(self.PushToTalkKeybindButton, false);
	end

	self:UnregisterEvent("VOICE_CHAT_CONNECTION_SUCCESS");
	self:UnregisterEvent("VOICE_CHAT_ERROR");
	self:UnregisterEvent("UPDATE_BINDINGS");
end

function AudioOptionsVoicePanel_OnEvent(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		OptionsFrame_AddCategory(VideoOptionsFrame, self);
		self:UnregisterEvent(event);
	elseif event == "UPDATE_BINDINGS" then
		AudioOptionsVoicePanel_UpdateCommunicationModeUI(self);
	elseif event == "VOICE_CHAT_ERROR" or event == "VOICE_CHAT_CONNECTION_SUCCESS" then
		AudioOptionsVoicePanel_Refresh(self);
	end
end

function DisplayUniversalAccessDialogIfRequiredForVoiceChatKeybind(keys)
	if IsMacClient() then
		local hasNonMetaKey = false;
		for i, key in ipairs(keys) do
			if not IsMetaKey(key) then
				hasNonMetaKey = true;
				break;
			end
		end
		if hasNonMetaKey then
			if not MacOptions_IsInputMonitoringEnabled() then
				StaticPopup_Show("MAC_OPEN_INPUT_MONITORING");
			end
		end
	end
end

function AudioOptionsVoicePanel_InitializeCommunicationModeUI(self)
	if not self.PushToTalkKeybindButton then
		local handler = CustomBindingHandler:CreateHandler(Enum.CustomBindingType.VoicePushToTalk);

		handler:SetOnBindingModeActivatedCallback(function(isActive)
			if isActive then
				self.ChatModeDropdown.PushToTalkNotification:SetFormattedText(BIND_KEY_TO_COMMAND, GetBindingName("TOGGLE_VOICE_PUSH_TO_TALK"));
			end
		end);

		handler:SetOnBindingCompletedCallback(function(completedSuccessfully, keys)
			self.ChatModeDropdown.PushToTalkNotification:SetText("");
			BindingButtonTemplate_SetSelected(self.PushToTalkKeybindButton, false);
			AudioOptionsVoicePanel_UpdateCommunicationModeUI(self);

			if completedSuccessfully and keys then
				DisplayUniversalAccessDialogIfRequiredForVoiceChatKeybind(keys);
			end
		end);

		self.PushToTalkKeybindButton = CustomBindingManager:RegisterHandlerAndCreateButton(handler, "CustomBindingButtonTemplateWithLabel", self);
		self.PushToTalkKeybindButton.KeyLabel:SetText(VOICE_CHAT_MODE_KEY);
		self.PushToTalkKeybindButton:SetPoint("BOTTOMLEFT", self.ChatModeDropdown, "BOTTOMRIGHT", 0, 5);
		self.PushToTalkKeybindButton:SetWidth(140); -- TODO: Needs to dynamically size
		self.PushToTalkKeybindButton.selectedHighlight:SetWidth(140);

		AudioOptionsVoicePanel_KeyBindButton_SetEnabled(self.PushToTalkKeybindButton, not self.ChatModeDropdown.isDisabled); -- TODO: Hide binding ui if openMic is selected?
		BlizzardOptionsPanel_RegisterControl(self.PushToTalkKeybindButton, self);
	end

	AudioOptionsVoicePanel_UpdateCommunicationModeUI(self);
end

local function GetFirstValidBindingKey(...)
	for i = 1, select("#", ...) do
		local key = select(i, ...);
		if key and #key > 0 then
			return key;
		end
	end
end

local function GetPreferredBindingKey(action, mode)
	return GetFirstValidBindingKey(GetBindingKey(action, mode));
end

function AudioOptionsVoicePanel_UpdateCommunicationModeUI(self)
	if self.PushToTalkKeybindButton then
		BindingButtonTemplate_SetupBindingButton(nil, self.PushToTalkKeybindButton);
	end
end

function AudioOptionsVoicePanel_KeyBindButton_SetEnabled(self, enabled)
	local color = enabled and NORMAL_FONT_COLOR or GRAY_FONT_COLOR;
	self:SetEnabled(enabled);
	self.KeyLabel:SetTextColor(color:GetRGB());
end

function AudioOptionsVoicePanel_TestInputDevice_SetEnabled(self, enabled)
	local color = enabled and NORMAL_FONT_COLOR or GRAY_FONT_COLOR;
	self.ToggleTest:SetEnabled(enabled);
	self.Label:SetTextColor(color:GetRGB());
end

function AudioOptionsVoicePanel_SetCustomControlsEnabled(self, enabled)
	if(self.PushToTalkKeybindButton) then
		AudioOptionsVoicePanel_KeyBindButton_SetEnabled(self.PushToTalkKeybindButton, enabled);
	end
	AudioOptionsVoicePanel_TestInputDevice_SetEnabled(self.TestInputDevice, enabled);
end

function AudioOptionsVoicePanelEnableVoice_UpdateControls(self)
	local statusCode = C_VoiceChat.GetCurrentVoiceChatConnectionStatusCode();
	local errorString = Voice_GetGameErrorStringFromStatusCode(statusCode);

	local enabled = (not errorString);
	BlizzardOptionsPanel_SetControlsEnabled(self, enabled);
	AudioOptionsVoicePanel_SetCustomControlsEnabled(self, enabled);
	self.MacMicrophoneAccessWarning:UpdateState();

	if(enabled) then
		self.ErrorStateMessage:Hide();
	else
		self.ErrorStateMessage:SetText(errorString)
		self.ErrorStateMessage:Show();
	end
end

local function AudioOptionsPanelVoiceChatSlider_BaseOnLoad(self, cvar, getCurrentFn)
	BlizzardOptionsPanel_RegisterControl(self, self:GetParent());
	local max = self.isValueNormalized and 1.0 or 100;
	self:SetMinMaxValues(0, max);
	self.Low:Hide();
	self.High:Hide();
	self.Text:ClearAllPoints();
	self.Text:SetPoint("LEFT", self, "RIGHT", 6, 1);

	local current, defaultValue = GetCVarInfo(cvar);
	self.defaultValue = defaultValue;

	self.GetCurrentValue = function(self)
		local value = getCurrentFn();
		if value ~= nil then
			return self.isValueInverted and (max - value) or value;
		end
	end

	self.RefreshValue = function(self)
		local value = self:GetCurrentValue();
		if value ~= nil then
			self:SetValue(value);
		end
	end

	self:RefreshValue();
end

local function AudioOptionsPanelVoiceChatSlider_BaseOnValueChanged(self, value, setValueFn)
	local max;
	-- Normalized values are in the range of [0,1].
	if self.isValueNormalized then
		self.newValue = value;
		max = 1.0;
	else
		self.newValue = floor(value);
		max = 100;
	end
	self.Text:SetText(FormatPercentage(self.newValue / max, true));

	-- If the underlying cvar's value has an inverse range, i.e. the slider
	-- range is [0,1], but the cvar represents this range as [0,1], the value
	-- can be inverted before returning. This changes a slider value of .9 to
	-- a cvar value of .1.
	if self.isValueInverted then
		setValueFn(max - self.newValue);
	else
		setValueFn(self.newValue);
	end
end

function AudioOptionsPanelVoiceChatVolumeSlider_OnLoad(self)
	AudioOptionsPanelVoiceChatSlider_BaseOnLoad(self, "VoiceOutputVolume", C_VoiceChat.GetOutputVolume);
end

function AudioOptionsPanelVoiceChatVolumeSlider_OnValueChanged(self, value)
	AudioOptionsPanelVoiceChatSlider_BaseOnValueChanged(self, value, C_VoiceChat.SetOutputVolume);
end

function AudioOptionsPanelVoiceChatDuckingSlider_OnLoad(self)
	AudioOptionsPanelVoiceChatSlider_BaseOnLoad(self, "VoiceChatMasterVolumeScale", C_VoiceChat.GetMasterVolumeScale);
end

function AudioOptionsPanelVoiceChatDuckingSlider_OnValueChanged(self, value)
	AudioOptionsPanelVoiceChatSlider_BaseOnValueChanged(self, value, C_VoiceChat.SetMasterVolumeScale);
end

function AudioOptionsPanelVoiceChatMicVolumeSlider_OnLoad(self)
	AudioOptionsPanelVoiceChatSlider_BaseOnLoad(self, "VoiceInputVolume", C_VoiceChat.GetInputVolume);
end

function AudioOptionsPanelVoiceChatMicVolumeSlider_OnValueChanged(self, value)
	AudioOptionsPanelVoiceChatSlider_BaseOnValueChanged(self, value, C_VoiceChat.SetInputVolume);
end

function AudioOptionsPanelVoiceChatMicSensitivitySlider_OnLoad(self)
	AudioOptionsPanelVoiceChatSlider_BaseOnLoad(self, "VoiceVADSensitivity", C_VoiceChat.GetVADSensitivity);
end

function AudioOptionsPanelVoiceChatMicSensitivitySlider_OnValueChanged(self, value)
	AudioOptionsPanelVoiceChatSlider_BaseOnValueChanged(self, value, C_VoiceChat.SetVADSensitivity);
end

-- Voice Chat Input/Output devices
AudioOptionsVoicePanelMicDeviceDropDown_OnLoad = nop;
AudioOptionsVoicePanelOutputDeviceDropDown_OnLoad = nop;
AudioOptionsVoicePanelChatModeDropdown_OnLoad = nop;
AudioOptionsVoicePanelChatModeDropdown_Initialize = nop;

do
	local function FindActiveDevice(devices)
		if devices then
			for index, device in ipairs(devices) do
				if device.isActive then
					return device;
				end
			end
		end
	end

	local function GetDeviceID(device)
		return device and device.deviceID or "";
	end

	local function GetDeviceDisplayName(device)
		return device and device.displayName or VOICE_CHAT_INVALID_DEVICE;
	end

	local function GetActiveInputDevice()
		return FindActiveDevice(C_VoiceChat.GetAvailableInputDevices());
	end

	local function GetActiveInputDeviceID()
		return GetDeviceID(GetActiveInputDevice());
	end

	local function GetActiveInputDeviceDisplayName()
		return GetDeviceDisplayName(GetActiveInputDevice());
	end

	local function GetActiveOutputDevice()
		return FindActiveDevice(C_VoiceChat.GetAvailableOutputDevices());
	end

	local function GetActiveOutputDeviceID()
		return GetDeviceID(GetActiveOutputDevice());
	end

	local function GetActiveOutputDeviceDisplayName()
		return GetDeviceDisplayName(GetActiveOutputDevice());
	end

	local function SortVoiceChatDevices(deviceA, deviceB)
		if deviceA.isSystemDefault ~= deviceB.isSystemDefault then
			return deviceA.isSystemDefault;
		end
		if deviceA.isCommsDefault ~= deviceB.isCommsDefault then
			return deviceA.isCommsDefault;
		end

		return strcmputf8i(deviceA.displayName, deviceB.displayName) < 0;
	end

	local function VoiceBaseDeviceDropdown_OnClick(self)
		local value = self.value;
		UIDropDownMenu_SetSelectedValue(self.owner, value);
		self.owner:SetValue(value);
	end

	local function BuildVoiceChatDeviceEntries(self)
		local devices = self.getAvailableEntries();
		if not devices then
			return 0;
		end

		table.sort(devices, SortVoiceChatDevices);

		local selectedValue = UIDropDownMenu_GetSelectedValue(self);
		local info = UIDropDownMenu_CreateInfo();

		info.func = self.dropdownOnClickFn;
		info.owner = self;

		for index, device in ipairs(devices) do
			if device.isSystemDefault then
				info.text = self.defaultDeviceDisplayName;
			else
				info.text = device.displayName;
			end

			info.value = device.deviceID;
			if info.value == selectedValue then
				info.checked = 1;
				UIDropDownMenu_SetText(self, info.text);
			else
				info.checked = nil;
			end
			UIDropDownMenu_AddButton(info);
		end

		return #devices;
	end

	local function VoiceBaseDeviceDropdown_DropdownInitialize(self)
		local numDevices = BuildVoiceChatDeviceEntries(self);
		if numDevices == 0 then
			local info = UIDropDownMenu_CreateInfo();
			info.text = VOICE_CHAT_INVALID_DEVICE;
			info.value = VOICE_CHAT_INVALID_DEVICE;
			info.checked = 1;
			UIDropDownMenu_AddButton(info);
		end
	end

	local function VoiceBaseDeviceDropdown_OnLoad(self)
		BlizzardOptionsPanel_RegisterControl(self, self:GetParent());
		UIDropDownMenu_SetWidth(self, 140);

		self.SetValue = function(self, value)
			self.newValue = value;
			self.setValueFn(value);
		end

		self.GetValue = function(self)
			return self.newValue or self.value;
		end

		self.RefreshValue = function(self)
			self.newValue = self.getCurrentValueFn();
			UIDropDownMenu_Initialize(self, self.dropdownInitFn);
			UIDropDownMenu_SetSelectedValue(self, self.newValue);
		end

		self:RefreshValue();
	end

	AudioOptionsVoicePanelMicDeviceDropDown_OnLoad = function(self)
		self.setValueFn = C_VoiceChat.SetInputDevice;
		self.getCurrentValueFn = GetActiveInputDeviceID;
		self.getCurrentTextFn = GetActiveInputDeviceDisplayName;
		self.getAvailableEntries = C_VoiceChat.GetAvailableInputDevices;
		self.defaultDeviceDisplayName = VOICE_CHAT_INPUT_DEVICE_DEFAULT;
		self.dropdownOnClickFn = VoiceBaseDeviceDropdown_OnClick;
		self.dropdownInitFn = VoiceBaseDeviceDropdown_DropdownInitialize;

		VoiceBaseDeviceDropdown_OnLoad(self);
	end

	AudioOptionsVoicePanelOutputDeviceDropDown_OnLoad = function(self)
		self.setValueFn = C_VoiceChat.SetOutputDevice;
		self.getCurrentValueFn = GetActiveOutputDeviceID;
		self.getCurrentTextFn = GetActiveOutputDeviceDisplayName;
		self.getAvailableEntries = C_VoiceChat.GetAvailableOutputDevices;
		self.defaultDeviceDisplayName = VOICE_CHAT_OUTPUT_DEVICE_DEFAULT;
		self.dropdownOnClickFn = VoiceBaseDeviceDropdown_OnClick;
		self.dropdownInitFn = VoiceBaseDeviceDropdown_DropdownInitialize;

		VoiceBaseDeviceDropdown_OnLoad(self);
	end

	AudioOptionsVoicePanelChatModeDropdown_OnLoad = function(self)
		local chatModeToText =
		{
			[Enum.CommunicationMode.PushToTalk] = PUSH_TO_TALK,
			[Enum.CommunicationMode.OpenMic] = OPEN_MIC,
		};

		self.setValueFn = C_VoiceChat.SetCommunicationMode;
		self.getCurrentValueFn = C_VoiceChat.GetCommunicationMode;
		self.getCurrentTextFn = function() return chatModeToText[C_VoiceChat.GetCommunicationMode()] or PUSH_TO_TALK; end
		self.defaultValue = Enum.CommunicationMode.PushToTalk;
		self.dropdownInitFn = AudioOptionsVoicePanelChatModeDropdown_Initialize;
		self.dropdownOnClickFn = AudioOptionsVoicePanelChatModeDropdown_OnClick;

		VoiceBaseDeviceDropdown_OnLoad(self);
	end
end

function AudioOptionsVoicePanelChatModeDropdown_Initialize(self)
	local selectedValue = self.getCurrentValueFn() or self.defaultValue;
	local info = UIDropDownMenu_CreateInfo();

	info.func = self.dropdownOnClickFn;
	info.owner = self;

	info.text = PUSH_TO_TALK;
	info.value = Enum.CommunicationMode.PushToTalk;
	if info.value == selectedValue then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = PUSH_TO_TALK;
	info.tooltipText = OPTION_TOOLTIP_VOICE_TYPE1;
	UIDropDownMenu_AddButton(info);

	info.text = OPEN_MIC;
	info.value = Enum.CommunicationMode.OpenMic;
	if info.value == selectedValue then
		info.checked = 1;
	else
		info.checked = nil;
	end
	info.tooltipTitle = OPEN_MIC
	info.tooltipText  = OPTION_TOOLTIP_VOICE_TYPE2;
	UIDropDownMenu_AddButton(info);
end

function AudioOptionsVoicePanelChatModeDropdown_OnClick(self)
	local chatMode = self.value;
	UIDropDownMenu_SetSelectedValue(self.owner, chatMode);
	self.owner.tooltip = _G["OPTION_TOOLTIP_VOICE_TYPE"..(chatMode + 1)];
	self.owner:SetValue(chatMode);
end

local function ReactivateChannel(self)
	-- Intentionally leaving this set after reactivation, potentially need to handle async case using events.
	if self.currentActiveChannel then
		C_VoiceChat.ActivateChannel(self.currentActiveChannel);
	end
end

local function UpdateTestButton(self)
	local texture = "Interface\\OptionsFrame\\VoiceChat-Play";
	if self.isTesting then
		texture = "Interface\\OptionsFrame\\VoiceChat-Record";
	end

	self.ToggleTest.Texture:SetTexture(texture);
end

local function BeginInputDeviceTest(self)
	if not self.isTesting then
		self.isTesting = true;
		self.currentActiveChannel = C_VoiceChat.GetActiveChannelID();

		local listenToLocalUser = true;
		C_VoiceChat.BeginLocalCapture(listenToLocalUser);
		UpdateTestButton(self);
	end
end

local function EndInputDeviceTest(self)
	if self.isTesting then
		self.isTesting = false;
		C_VoiceChat.EndLocalCapture();
		ReactivateChannel(self);
		self.VUMeter.Status:SetValue(0);
		UpdateTestButton(self);
	end
end

local function UpdateVUMeter(self, isSpeaking, energy)
	energy = self.isTesting and energy or 0;
	self.VUMeter.Status:SetValue(energy);

	if self.VUMeter.isSpeaking ~= isSpeaking then
		self.VUMeter.isSpeaking = isSpeaking;
		if isSpeaking then
			self.VUMeter.Status:SetStatusBarColor(0, 1, 0, 1);
		else
			self.VUMeter.Status:SetStatusBarColor(1, 1, 1, 1);
		end
	end
end

local function ToggleTesting(self)
	if self.isTesting then
		EndInputDeviceTest(self);
	else
		BeginInputDeviceTest(self);
	end
end

function AudioOptionsVoicePanelTestInputDevice_OnClick(self, button)
	ToggleTesting(self:GetParent());
end

function AudioOptionsVoicePanelTestInputDevice_OnLoad(self)
	self:RegisterEvent("ADDONS_UNLOADING");

	self.VUMeter.Status:SetMinMaxValues(0, 1);
	self.VUMeter.Status:SetValue(0);
	UpdateTestButton(self);
end

function AudioOptionsVoicePanelTestInputDevice_OnShow(self)
	self:RegisterEvent("VOICE_CHAT_AUDIO_CAPTURE_ENERGY");
end

function AudioOptionsVoicePanelTestInputDevice_OnHide(self)
	self:UnregisterEvent("VOICE_CHAT_AUDIO_CAPTURE_ENERGY");
	EndInputDeviceTest(self);
end

function AudioOptionsVoicePanelTestInputDevice_OnEvent(self, event, ...)
	if event == "ADDONS_UNLOADING" then
		EndInputDeviceTest(self);
	elseif event == "VOICE_CHAT_AUDIO_CAPTURE_ENERGY" then
		UpdateVUMeter(self, ...);
	end
end

MacMicrophoneAccessWarningMixin = {};

function MacMicrophoneAccessWarningMixin:UpdateState()
	local shown = MacOptions_IsMicrophoneEnabled and not MacOptions_IsMicrophoneEnabled();
	if shown then
		self.Label:SetFormattedText(MAC_MIC_PREMISSIONS_NOTIFICATION, MacOptions_GetGameBundleName());
	end

	self:SetShown(shown);
	local color = shown and RED_FONT_COLOR or NORMAL_FONT_COLOR;
	AudioOptionsVoicePanelOutputDeviceDropdownLabel:SetTextColor(color:GetRGBA());
	AudioOptionsVoicePanelMicDeviceDropdownLabel:SetTextColor(color:GetRGBA());
end
