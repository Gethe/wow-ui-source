
SoundOptionsFrameCheckButtons = { };
SoundOptionsFrameCheckButtons["ENABLE_ERROR_SPEECH"] = { index = 4, cvar = "EnableErrorSpeech", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_ERROR_SPEECH};
SoundOptionsFrameCheckButtons["ENABLE_MUSIC"] = { index = 5, cvar = "EnableMusic", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_MUSIC};
SoundOptionsFrameCheckButtons["ENABLE_AMBIENCE"] = { index = 2, cvar = "EnableAmbience", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_AMBIENCE};
SoundOptionsFrameCheckButtons["ENABLE_ALL_SOUND"] = { index = 1, cvar = "MasterSoundEffects", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_ALL_SOUND};
SoundOptionsFrameCheckButtons["ENABLE_SOUND_AT_CHARACTER"] = { index = 6, cvar = "SoundListenerAtCharacter", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_SOUND_AT_CHARACTER};
SoundOptionsFrameCheckButtons["ENABLE_EMOTE_SOUNDS"] = { index = 7, cvar = "EmoteSounds", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_EMOTE_SOUNDS};
SoundOptionsFrameCheckButtons["ENABLE_MUSIC_LOOPING"] = { index = 8, cvar = "SoundZoneMusicNoDelay", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_MUSIC_LOOPING};

SoundOptionsFrameSliders = {
	{ index = 2, text = SOUND_VOLUME, cvar = "SoundVolume", minValue = 0, maxValue = 1, valueStep = 0.1, initialValue = nil , tooltipText = OPTION_TOOLTIP_SOUND_VOLUME},
	{ index = 3, text = MUSIC_VOLUME, cvar = "MusicVolume", minValue = 0, maxValue = 1, valueStep = 0.1, initialValue = nil , tooltipText = OPTION_TOOLTIP_MUSIC_VOLUME},
	{ index = 4, text = AMBIENCE_VOLUME, cvar = "AmbienceVolume", minValue = 0, maxValue = 1, valueStep = 0.1, initialValue = nil , tooltipText = OPTION_TOOLTIP_AMBIENCE_VOLUME},
	{ index = 1, text = MASTER_VOLUME, cvar = "MasterVolume", minValue = 0, maxValue = 1, valueStep = 0.1, initialValue = nil , tooltipText = OPTION_TOOLTIP_MASTER_VOLUME},
};

function SoundOptionsFrame_Init()
	for index, value in SoundOptionsFrameCheckButtons do
		local string = GetCVar(value.cvar);
		if ( string and (string ~= "0") ) then
			value.value = 1;
		else
			value.value = 0;
		end
	end
	this:RegisterEvent("CVAR_UPDATE");
end

function SoundOptionsFrame_OnEvent()
	if ( event == "CVAR_UPDATE" ) then
		SoundOptionsFrame_Load();
	end
end

function SoundOptionsFrame_Load()
	local masterSoundEnabled = GetCVar("MasterSoundEffects");
	
	local button, string, checked;
	for index, value in SoundOptionsFrameCheckButtons do
		button = getglobal("SoundOptionsFrameCheckButton"..value.index);
		string = getglobal("SoundOptionsFrameCheckButton"..value.index.."Text");
		checked = GetCVar(value.cvar);
		button:SetChecked(checked);
		string:SetText(TEXT(getglobal(index)));
		-- Save the intial value
		value.initialValue = checked;
		if ( index == "ENABLE_ALL_SOUND" or index == "ENABLE_MUSIC" or index == "ENABLE_SOUND_AT_CHARACTER" or index == "ENABLE_EMOTE_SOUNDS" or index == "ENABLE_MUSIC_LOOPING") then
			string:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		end
		button.tooltipText = value.tooltipText;
	end
	for index, value in SoundOptionsFrameSliders do
		local slider = getglobal("SoundOptionsFrameSlider"..value.index);
		local string = getglobal("SoundOptionsFrameSlider"..value.index.."Text");
		-- Save the intial value
		value.initialValue = GetCVar(value.cvar);
		slider:SetMinMaxValues(value.minValue, value.maxValue);
		slider:SetValueStep(value.valueStep);
		slider:SetValue(value.initialValue);
		string:SetText(TEXT(value.text));
		slider.tooltipText = value.tooltipText;
	end
	SoundOptionsFrame_UpdateDependencies();
end

function SoundOptionsFrame_Cancel()
	for index, value in SoundOptionsFrameCheckButtons do
		SetCVar(value.cvar, value.initialValue);
	end
	for index, value in SoundOptionsFrameSliders do
		SetCVar(value.cvar, value.initialValue);
	end
end

function SoundOptionsCheckButton_OnClick()
	for index, value in SoundOptionsFrameCheckButtons do
		if ( value.index == this:GetID() ) then
			if ( index == "ENABLE_ALL_SOUND" ) then
				SoundOptionsFrame_ToggleSound("CLICK");
			else
				SetCVar(value.cvar, this:GetChecked());
			end
		end
	end
	if ( this:GetChecked() ) then
		PlaySound("igMainMenuOptionCheckBoxOff");
	else
		PlaySound("igMainMenuOptionCheckBoxOn");
	end
end

function SoundOptionsSlider_OnValueChanged()
	for index, value in SoundOptionsFrameSliders do
		if ( value.index == this:GetID() ) then
			SetCVar(value.cvar, this:GetValue());
			value.previousValue = this:GetValue();
		end
	end
end

-- Keybinding functions
function SoundOptionsFrame_ToggleMusic()
	if ( GetCVar("EnableMusic") == "1" ) then
		SetCVar("EnableMusic", 0);
	else
		SetCVar("EnableMusic", 1);
	end
	SoundOptionsFrame_Load();
end

function SoundOptionsFrame_ToggleSound(isClicked)
	local checked;
	-- Need different behavior if a button is clicked or if sound is toggled by hotkey
	if ( isClicked ) then
		if ( this:GetChecked() ) then
			SetCVar("MasterSoundEffects", 1);
		else
			SetCVar("MasterSoundEffects", 0);
		end
	else
		if ( GetCVar("MasterSoundEffects") == "0" ) then
			SetCVar("MasterSoundEffects", 1);
		else
			SetCVar("MasterSoundEffects", 0);
		end
		SoundOptionsFrameCheckButton1:SetChecked(GetCVar("MasterSoundEffects"));
		
	end
	SoundOptionsFrame_UpdateDependencies();
end

function SoundOptionsFrame_MasterVolumeUp()
	local masterVolume = GetCVar("MasterVolume") + 0;
	if ( masterVolume < 1.0 ) then
		masterVolume = masterVolume + 0.1;
		SetCVar("MasterVolume", masterVolume);
	end
end

function SoundOptionsFrame_MasterVolumeDown()
	local masterVolume = GetCVar("MasterVolume") + 0;
	if ( masterVolume > 0.0 ) then
		masterVolume = masterVolume - 0.1;
		SetCVar("MasterVolume", masterVolume);
	end
end

function SoundOptionsFrame_SetDefaults()
	for index, value in SoundOptionsFrameCheckButtons do
		checkButton = getglobal("SoundOptionsFrameCheckButton"..value.index);
		OptionsFrame_EnableCheckBox(checkButton, 1, GetCVarDefault(value.cvar), 1);
		SetCVar(value.cvar, GetCVarDefault(value.cvar));
	end
	for index, value in SoundOptionsFrameSliders do
		local slider = getglobal("SoundOptionsFrameSlider"..value.index);
		slider:SetValue(GetCVarDefault(value.cvar));
		SetCVar(value.cvar, GetCVarDefault(value.cvar));
	end
	SoundOptionsFrame_UpdateDependencies();
end

function SoundOptionsFrame_UpdateDependencies()
	if ( SoundOptionsFrameCheckButton1:GetChecked() ) then
		OptionsFrame_EnableCheckBox(SoundOptionsFrameCheckButton2);
		OptionsFrame_EnableCheckBox(SoundOptionsFrameCheckButton4);
	else
		OptionsFrame_DisableCheckBox(SoundOptionsFrameCheckButton2);
		OptionsFrame_DisableCheckBox(SoundOptionsFrameCheckButton4);
	end
end
