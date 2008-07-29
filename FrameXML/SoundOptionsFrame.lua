SoundChannelSliderSlot = {};
SoundChannelSliderSlot["12"] = "1";
SoundChannelSliderSlot["32"] = "2";
SoundChannelSliderSlot["64"] = "3";
SoundChannelSliderSlot["128"] = "4";

SoundChannelNumChannels = {};
SoundChannelNumChannels["1"] = "12";
SoundChannelNumChannels["2"] = "32";
SoundChannelNumChannels["3"] = "64";
SoundChannelNumChannels["4"] = "128";

SoundOptionsFrameCheckButtons = { };
SoundOptionsFrameCheckButtons["ENABLE_ERROR_SPEECH"] = { index = 3, cvar = "Sound_EnableErrorSpeech", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_ERROR_SPEECH};
SoundOptionsFrameCheckButtons["ENABLE_MUSIC"] = { index = 5, cvar = "Sound_EnableMusic", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_MUSIC};
SoundOptionsFrameCheckButtons["ENABLE_AMBIENCE"] = { index = 7, cvar = "Sound_EnableAmbience", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_AMBIENCE};
SoundOptionsFrameCheckButtons["ENABLE_SOUNDFX"] = { index = 2, cvar = "Sound_EnableSFX", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_SOUNDFX};
SoundOptionsFrameCheckButtons["ENABLE_SOUND"] = { index = 1, cvar = "Sound_EnableAllSound", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_SOUND};
SoundOptionsFrameCheckButtons["ENABLE_SOUND_AT_CHARACTER"] = { index = 8, cvar = "Sound_ListenerAtCharacter", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_SOUND_AT_CHARACTER};
SoundOptionsFrameCheckButtons["ENABLE_EMOTE_SOUNDS"] = { index = 4, cvar = "Sound_EnableEmoteSounds", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_EMOTE_SOUNDS};
SoundOptionsFrameCheckButtons["ENABLE_MUSIC_LOOPING"] = { index = 6, cvar = "Sound_ZoneMusicNoDelay", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_MUSIC_LOOPING};
SoundOptionsFrameCheckButtons["ENABLE_BGSOUND"] = { index = 9, cvar = "Sound_EnableSoundWhenGameIsInBG", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_BGSOUND};
SoundOptionsFrameCheckButtons["ENABLE_REVERB"] = { index = 10, cvar = "Sound_EnableReverb", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_REVERB,};
SoundOptionsFrameCheckButtons["ENABLE_HARDWARE"] = { index = 11, cvar = "Sound_EnableHardware", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_HARDWARE};

SoundOptionsFrameSliders = {
	{ index = 2, text = SOUND_VOLUME, cvar = "Sound_SFXVolume", minValue = 0, maxValue = 1, valueStep = 0.1, initialValue = nil , tooltipText = OPTION_TOOLTIP_SOUND_VOLUME},
	{ index = 3, text = MUSIC_VOLUME, cvar = "Sound_MusicVolume", minValue = 0, maxValue = 1, valueStep = 0.1, initialValue = nil , tooltipText = OPTION_TOOLTIP_MUSIC_VOLUME},
	{ index = 4, text = AMBIENCE_VOLUME, cvar = "Sound_AmbienceVolume", minValue = 0, maxValue = 1, valueStep = 0.1, initialValue = nil , tooltipText = OPTION_TOOLTIP_AMBIENCE_VOLUME},
	{ index = 1, text = MASTER_VOLUME, cvar = "Sound_MasterVolume", minValue = 0, maxValue = 1, valueStep = 0.1, initialValue = nil , tooltipText = OPTION_TOOLTIP_MASTER_VOLUME},
	{ index = 5, text = SOUND_CHANNELS, cvar = "Sound_NumChannels", minValue = 2, maxValue = 3, valueStep = 1, initialValue = nil, tooltipText = OPTION_TOOLTIP_SOUND_CHANNELS},
	{ index = 6, text = SOUND_QUALITY, cvar = "Sound_OutputQuality", minValue = 0, maxValue = 2, valueStep = 1, initialValue = 1, tooltipText = OPTION_TOOLTIP_SOUND_QUALITY},
};

function SoundOptionsFrame_Init(self)
	for index, value in pairs(SoundOptionsFrameCheckButtons) do
		local string = GetCVar(value.cvar);
		if ( string and (string ~= "0") ) then
			value.value = 1;
		else
			value.value = 0;
		end

		if ( IsMacClient() and value.index == 11 ) then
			SoundOptionsFrameCheckButton11:Hide();
		end
	end
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("SOUND_DEVICE_UPDATE");
end

function SoundOptionsFrame_OnEvent(self, event, ...)
	if ( event == "CVAR_UPDATE" and SoundOptionsFrame:IsVisible() ) then
		SoundOptionsFrame_Load();
	elseif ( event == "SOUND_DEVICE_UPDATE" ) then
		SoundOptionsFrame_RefreshSoundDevices();
	end
end

function SoundOptionsFrame_Load()
	-- Load values for the Voice Options Frame
	local masterSoundEnabled = GetCVar("Sound_EnableSFX");
	local button, string, checked;
	for index, value in pairs(SoundOptionsFrameCheckButtons) do
		button = getglobal("SoundOptionsFrameCheckButton"..value.index);
		string = getglobal("SoundOptionsFrameCheckButton"..value.index.."Text");
		checked = GetCVar(value.cvar);
		button:SetChecked(checked);
		string:SetText(getglobal(index));
		-- Save the intial value
		value.initialValue = checked;
		button.tooltipText = value.tooltipText;
		button.tooltipRequirement = value.tooltipRequirement;
	end
	for index, value in pairs(SoundOptionsFrameSliders) do
		local slider = getglobal("SoundOptionsFrameSlider"..value.index);
		local string = getglobal("SoundOptionsFrameSlider"..value.index.."Text");
		-- Save the intial value
		if ( value.cvar == "Sound_NumChannels" ) then
			value.initialValue = SoundChannelSliderSlot[ GetCVar(value.cvar) ];
		else
			value.initialValue = GetCVar(value.cvar);
		end
		slider:SetMinMaxValues(value.minValue, value.maxValue);
		slider:SetValueStep(value.valueStep);
		if ( value.initialValue ) then
			slider:SetValue(value.initialValue);
		end
		string:SetText(value.text);
		slider.tooltipText = value.tooltipText;
		slider.tooltipRequirement = value.tooltipRequirement;
	end
	SoundOptionsOutputDropDown_Load();
end

function SoundOptionsFrame_Cancel()
	for index, value in pairs(SoundOptionsFrameCheckButtons) do
		SetCVar(value.cvar, value.initialValue);
	end
	for index, value in pairs(SoundOptionsFrameSliders) do
		if ( value.cvar == "Sound_NumChannels" ) then
			SetCVar(value.cvar, SoundChannelNumChannels[value.initialValue] );
		else
			SetCVar(value.cvar, value.initialValue);
		end
	end

	
	if ( SoundOptionsOutputDropDown.initialValue ) then
		local currentIndex = GetCVar("Sound_OutputDriverIndex");
		SetCVar("Sound_OutputDriverIndex", SoundOptionsOutputDropDown.initialValue);
		SetCVar("Sound_OutputDriverName", SoundOptionsOutputDropDown.initialText);
		UIDropDownMenu_SetSelectedValue(SoundOptionsOutputDropDown, SoundOptionsOutputDropDown.initialValue);
		UIDropDownMenu_SetText(SoundOptionsOutputDropDown, SoundOptionsOutputDropDown.initialText);
		if ( currentIndex ~= SoundOptionsOutputDropDown.initialValue ) then
			AudioOptionsFrame_RestartEngine();
		end
		SoundOptionsOutputDropDown.initialValue = nil;
		SoundOptionsOutputDropDown.initialText = nil;
	end
end

function SoundOptionsCheckButton_OnClick(self)
	for index, value in pairs(SoundOptionsFrameCheckButtons) do
		if ( value.index == self:GetID() ) then
			if ( index == "ENABLE_ALL_SOUND" ) then
				SoundOptionsFrame_ToggleSound(self, "CLICK");
			else
				SetCVar(value.cvar, self:GetChecked());
				value.value = self:GetChecked();
			end
			if ( value.cvar == "Sound_EnableHardware" ) then
				if ( value.initialValue ~= value.value ) then
					AudioOptionsFrame.SoundRestart = 1;
				elseif ( AudioOptionsFrame.SoundRestart == 1 ) then
					local sliderChanged = false;
					for index, value in pairs(SoundOptionsFrameSliders) do
						if ( value.cvar == "Sound_NumChannels" and value.initialValue ~= value.previousValue ) then
							sliderChanged = true;
						end
					end
					
					if ( not sliderChanged and value.value ~= 1 ) then
						--If only Reverb has changed and we're not using hardware for sound, then don't restart.
						AudioOptionsFrame.SoundRestart = nil;
					end
				end
			elseif ( value.cvar == "Sound_EnableReverb" ) then
				if ( SoundOptionsFrameCheckButtons["ENABLE_HARDWARE"].value == 1 ) then
					AudioOptionsFrame.SoundRestart = 1;
				end
			end
		end
	end
	if ( self:GetChecked() ) then
		PlaySound("igMainMenuOptionCheckBoxOff");
	else
		PlaySound("igMainMenuOptionCheckBoxOn");
	end
	SoundOptionsFrame_UpdateDependencies();
end

function SoundOptionsSlider_OnValueChanged(self, value)
	local valueText = getglobal(self:GetName().."Value");
	-- need to scale the value down to between 0 and 1
	if ( valueText ) then
		local low, high = self:GetMinMaxValues();
		local suffix = nil;
		if ( high > 1 ) then
			if ( value >= 3 ) then
				valueText:SetText(HIGH);
			else
				valueText:SetText(LOW);
			end

		else
			suffix = "%";
			valueText:SetText(tostring(ceil(value * 100))..suffix);
		end
	end

	for index, slider in pairs(SoundOptionsFrameSliders) do
		if ( slider.index == self:GetID() ) then
			if ( slider.cvar == "Sound_NumChannels" ) then
				local cvarValue = GetCVar(slider.cvar);
				if ( tonumber(cvarValue) == tonumber(SoundChannelNumChannels[tostring(value)]) ) then
					--Nothing changed
				else
					SetCVar(slider.cvar, tonumber(SoundChannelNumChannels[tostring(value)]) );
					AudioOptionsFrame.SoundRestart = 1;
				end
			elseif ( slider.cvar == "Sound_OutputQuality" ) then
				local cvarValue = GetCVar(slider.cvar);
				if ( tonumber(cvarValue) == value ) then
					--Nothing changed
				else
					SetCVar(slider.cvar, value);
					AudioOptionsFrame.SoundRestart = 1;
				end
			else
				SetCVar(slider.cvar, value);
			end
			slider.previousValue = value;
		end
	end
end

-- Keybinding functions
function SoundOptionsFrame_ToggleMusic()
	if ( GetCVar("Sound_EnableMusic") == "1" ) then
		SetCVar("Sound_EnableMusic", 0);
	else
		SetCVar("Sound_EnableMusic", 1);
	end
	SoundOptionsFrame_Load();
end

function SoundOptionsFrame_ToggleSound(self, isClicked)
	local checked;
	-- Need different behavior if a button is clicked or if sound is toggled by hotkey
	if ( isClicked ) then
		if ( self:GetChecked() ) then
			SetCVar("Sound_EnableSFX", 1);
		else
			SetCVar("Sound_EnableSFX", 0);
		end
	else
		if ( GetCVar("Sound_EnableSFX") == "0" ) then
			SetCVar("Sound_EnableSFX", 1);
			SetCVar("Sound_EnableAmbience", 1);
		else
			SetCVar("Sound_EnableSFX", 0);
			SetCVar("Sound_EnableAmbience", 0);
		end
		SoundOptionsFrameCheckButton1:SetChecked(GetCVar("Sound_EnableSFX"));
	end
	SoundOptionsFrame_UpdateDependencies();
end

function SoundOptionsFrame_MasterVolumeUp()
	local masterVolume = GetCVar("Sound_MasterVolume") + 0;
	if ( masterVolume < 1.0 ) then
		masterVolume = masterVolume + 0.1;
		SetCVar("Sound_MasterVolume", masterVolume);
	end
end

function SoundOptionsFrame_MasterVolumeDown()
	local masterVolume = GetCVar("Sound_MasterVolume") + 0;
	if ( masterVolume > 0.0 ) then
		masterVolume = masterVolume - 0.1;
		SetCVar("Sound_MasterVolume", masterVolume);
	end
end

function SoundOptionsFrame_SetDefaults()
	local checkButton
	for index, value in pairs(SoundOptionsFrameCheckButtons) do
		checkButton = getglobal("SoundOptionsFrameCheckButton"..value.index);
		OptionsFrame_EnableCheckBox(checkButton, 1, GetCVarDefault(value.cvar), 1);
		SetCVar(value.cvar, GetCVarDefault(value.cvar));
	end
	for index, value in pairs(SoundOptionsFrameSliders) do
		local slider = getglobal("SoundOptionsFrameSlider"..value.index);
		if ( value.cvar == "Sound_NumChannels" ) then
			slider:SetValue( SoundChannelSliderSlot[GetCVarDefault(value.cvar)] );
		else
			slider:SetValue(GetCVarDefault(value.cvar));
		end
		SetCVar(value.cvar, GetCVarDefault(value.cvar));
	end
	SoundOptionsFrame_UpdateDependencies();
end

function SoundOptionsFrame_UpdateDependencies()

	if ( SoundOptionsFrameCheckButton1:GetChecked() ) then
		for i, value in pairs(SoundOptionsFrameCheckButtons) do
			OptionsFrame_EnableCheckBox(getglobal("SoundOptionsFrameCheckButton"..value.index));
			if ( SoundOptionsFrameCheckButton2:GetChecked() ) then
				OptionsFrame_EnableCheckBox(SoundOptionsFrameCheckButton3);
				OptionsFrame_EnableCheckBox(SoundOptionsFrameCheckButton4);
			else
				OptionsFrame_DisableCheckBox(SoundOptionsFrameCheckButton3);
				OptionsFrame_DisableCheckBox(SoundOptionsFrameCheckButton4);
			end
			if ( SoundOptionsFrameCheckButton5:GetChecked() ) then
				OptionsFrame_EnableCheckBox(SoundOptionsFrameCheckButton6);
			else
				OptionsFrame_DisableCheckBox(SoundOptionsFrameCheckButton6);
			end
		end
		for i, value in pairs(SoundOptionsFrameSliders) do
			AudioOptionsFrame_EnableSlider(getglobal("SoundOptionsFrameSlider"..value.index));
		end
		if ( Sound_GameSystem_GetNumOutputDrivers() > 0 ) then
			UIDropDownMenu_EnableDropDown(SoundOptionsOutputDropDown);
		else
			UIDropDownMenu_DisableDropDown(SoundOptionsOutputDropDown);
		end
	else
		for i, value in pairs(SoundOptionsFrameCheckButtons) do
			if ( i ~= "ENABLE_SOUND" ) then
				OptionsFrame_DisableCheckBox(getglobal("SoundOptionsFrameCheckButton"..value.index));
			end
		end
		for i, value in pairs(SoundOptionsFrameSliders) do
			AudioOptionsFrame_DisableSlider(getglobal("SoundOptionsFrameSlider"..value.index));
		end
		UIDropDownMenu_DisableDropDown(SoundOptionsOutputDropDown);
	end	
end

function SoundOptionsFrame_RefreshSoundDevices()
	local deviceName, numDrivers, currentDevice, currentValue, initialValue;
	
	local found = false;
	initialValue = SoundOptionsOutputDropDown.initalValue;
	SoundOptionsOutputDropDown.initalValue = nil;
	
	numDrivers = Sound_GameSystem_GetNumOutputDrivers();
	if ( numDrivers > 0 ) then
		currentDevice = UIDropDownMenu_GetText(SoundOptionsOutputDropDown);
		currentValue = UIDropDownMenu_GetSelectedValue(SoundOptionsOutputDropDown);
		for index = 0, numDrivers - 1 do
			deviceName = Sound_GameSystem_GetOutputDriverNameByIndex(index);
			if ( deviceName == currentDevice ) then
				UIDropDownMenu_SetSelectedValue(SoundOptionsOutputDropDown, index);
				UIDropDownMenu_SetText(SoundOptionsOutputDropDown, deviceName);
				if ( currentValue == initialValue ) then
					SoundOptionsOutputDropDown.initialValue = index;
				end
				SetCVar("Sound_OutputDriverIndex", index);
				found = true;
			end
		end
		
		if ( not found ) then
			UIDropDownMenu_SetSelectedValue(SoundOptionsOutputDropDown, 0);
			UIDropDownMenu_SetText(SoundOptionsOutputDropDown, Sound_GameSystem_GetOutputDriverNameByIndex(0));
			SoundOptionsOutputDropDown.initialValue = 0;
		end
	end
end

-- Output Device DropDown
function SoundOptionsOutputDropDown_Load()
	UIDropDownMenu_Initialize(SoundOptionsOutputDropDown, SoundOptionsOutputDropDown_Initialize);
	UIDropDownMenu_SetWidth(SoundOptionsOutputDropDown, 140);

	local selectedDriverIndex = GetCVar("Sound_OutputDriverIndex");
	SoundOptionsOutputDropDown.initialValue = selectedDriverIndex;

--	local deviceName = GetCVar("Sound_OutputDriverName");
	local deviceName = Sound_GameSystem_GetOutputDriverNameByIndex(tonumber(selectedDriverIndex));
	SoundOptionsOutputDropDown.initialText = deviceName;

	UIDropDownMenu_SetSelectedValue(SoundOptionsOutputDropDown, deviceName, 1);
	SoundOptionsOutputDropDown.tooltip = OPTION_RESTART_REQUIREMENT;
	UIDropDownMenu_SetText(SoundOptionsOutputDropDown, deviceName);
end

function SoundOptionsOutputDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedValue(SoundOptionsOutputDropDown, self.value);
	SetCVar("Sound_OutputDriverIndex", self.value);
	AudioOptionsFrame_RestartEngine();
end

function SoundOptionsOutputDropDown_Initialize()
	local selectedDriverIndex = GetCVar("Sound_OutputDriverIndex");
	local num = Sound_GameSystem_GetNumOutputDrivers();
	local info = UIDropDownMenu_CreateInfo();
	for index=0,num-1,1 do
		local description = Sound_GameSystem_GetOutputDriverNameByIndex(index);
		info.text = description;
		info.value = index;
		info.checked = nil;
		if (index == tonumber(selectedDriverIndex)) then
			info.checked = 1;
		end
		info.func = SoundOptionsOutputDropDown_OnClick;
		
		UIDropDownMenu_AddButton(info);
	end
end