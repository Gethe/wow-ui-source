
SoundOptionsFrameCheckButtons = { };
SoundOptionsFrameCheckButtons["ENABLE_GROUP_SPEECH"] = { index = 3, cvar = "EnableGroupSpeech", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_GROUP_SPEECH};
SoundOptionsFrameCheckButtons["ENABLE_ERROR_SPEECH"] = { index = 4, cvar = "EnableErrorSpeech", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_ERROR_SPEECH};
SoundOptionsFrameCheckButtons["ENABLE_MUSIC"] = { index = 5, cvar = "EnableMusic", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_MUSIC};
SoundOptionsFrameCheckButtons["ENABLE_AMBIENCE"] = { index = 2, cvar = "EnableAmbience", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_AMBIENCE};
SoundOptionsFrameCheckButtons["ENABLE_ALL_SOUND"] = { index = 1, cvar = "MasterSoundEffects", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_ALL_SOUND};
SoundOptionsFrameCheckButtons["ENABLE_SOUND_AT_CHARACTER"] = { index = 6, cvar = "SoundListenerAtCharacter", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_SOUND_AT_CHARACTER};
SoundOptionsFrameCheckButtons["ENABLE_EMOTE_SOUNDS"] = { index = 7, cvar = "EmoteSounds", initialValue = nil , tooltipText = OPTION_TOOLTIP_ENABLE_EMOTE_SOUNDS};

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
		-- Enable or disable button
		if ( index == "ENABLE_GROUP_SPEECH" or index == "ENABLE_ERROR_SPEECH" or index == "ENABLE_SOUND" or index == "ENABLE_AMBIENCE" ) then
			if ( masterSoundEnabled == "1" ) then
				-- Enable
				string:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				button:Enable();
			else
				-- Disable
				string:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
				button:Disable();
			end
		end
		if ( index == "ENABLE_ALL_SOUND" or index == "ENABLE_MUSIC" or index == "ENABLE_SOUND_AT_CHARACTER" or index == "ENABLE_EMOTE_SOUNDS") then
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
				SoundOptionsFrame_ToggleSound();
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

function SoundOptionsFrame_ToggleSound()
	local checked = GetCVar("MasterSoundEffects");
	if ( checked == "0"  ) then
		SetCVar("MasterSoundEffects", 1);
	else
		SetCVar("MasterSoundEffects", 0);
	end
	local string, button;
	for index, value in SoundOptionsFrameCheckButtons do
		if ( index == "ENABLE_GROUP_SPEECH" or index == "ENABLE_ERROR_SPEECH" or index == "ENABLE_SOUND" or index == "ENABLE_AMBIENCE" ) then
			SetCVar(value.cvar, GetCVar(value.cvar));
			button = getglobal("SoundOptionsFrameCheckButton"..value.index);
			string = getglobal("SoundOptionsFrameCheckButton"..value.index.."Text");
			if ( checked == "0" ) then
				-- Enable
				string:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
				button:Enable();
			else
				-- Disable
				string:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
				button:Disable();
			end
		end
	end
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
