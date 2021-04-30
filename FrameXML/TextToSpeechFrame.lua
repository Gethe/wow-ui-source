
TEXTTOSPEECH_CONFIG_DEFAULTS = {
	playSoundWhenEnteringChatWindow = true,
	playSoundSeparatingChatLineBreaks = true,
	addCharacterNameToSpeech = true,
	playActivitySoundWhenNotFocused = true,
	ttsVoiceOptionSelected = 1,
	alternateSystemVoice = false,
	speechRate = 0,
	speechVolume = 100,
	enabledChatTypes = {
		["CHAT_MSG_EMOTE"] = true,
		["CHAT_MSG_WHISPER"] = true,
		["CHAT_MSG_SAY"] = true,
		["CHAT_MSG_YELL"] = true,
		["CHAT_MSG_PARTY_LEADER"] = true,
		["CHAT_MSG_PARTY"] = true,
		["CHAT_MSG_OFFICER"] = true,
		["CHAT_MSG_GUILD"] = true,
		["CHAT_MSG_RAID_LEADER"] = true,
		["CHAT_MSG_RAID"] = true,
		["CHAT_MSG_INSTANCE_CHAT_LEADER"] = true,
		["CHAT_MSG_INSTANCE_CHAT"] = true,
		["CHAT_MSG_BN_WHISPER"] = true,
	}
};

TEXTTOSPEECH_CONFIG = CopyTable(TEXTTOSPEECH_CONFIG_DEFAULTS);

local TEXTTOSPEECH_STANDARD_VOICE_COUNT = 2;

local TextToSpeechChatTypes = {
	"CHAT_MSG_MONSTER_SAY",
	"CHAT_MSG_SYSTEM",
	"CHAT_MSG_EMOTE",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_SAY",
	"CHAT_MSG_YELL",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_BN_WHISPER",
};

-- [[ TextToSpeechFrame ]] --

function TextToSpeechFrame_Show()
	TextToSpeechFrame:SetShown(not TextToSpeechFrame:IsShown());
end

function TextToSpeechFrame_Update(self)
	-- Update checkboxes
	local checkBoxParent = TextToSpeechFramePanelContainer

	checkBoxParent.PlaySoundWhenEnteringChatWindowCheckButton:SetChecked(TEXTTOSPEECH_CONFIG.playSoundWhenEnteringChatWindow);
	checkBoxParent.PlaySoundSeparatingChatLinesCheckButton:SetChecked(TEXTTOSPEECH_CONFIG.playSoundSeparatingChatLineBreaks);
	checkBoxParent.AddCharacterNameToSpeechCheckButton:SetChecked(TEXTTOSPEECH_CONFIG.addCharacterNameToSpeech);
	checkBoxParent.PlayActivitySoundWhenNotFocusedCheckButton:SetChecked(TEXTTOSPEECH_CONFIG.playActivitySoundWhenNotFocused);

	local checkBoxNameString = TextToSpeechFramePanelContainerChatTypeContainer:GetName().."CheckBox";
	local checkBoxName, checkBox;

	local checkBoxTable = TextToSpeechFramePanelContainerChatTypeContainer.checkBoxTable or {}
	for index, value in ipairs(checkBoxTable) do
		checkBoxName = checkBoxNameString..index;
		checkBox = _G[checkBoxName];
		if ( checkBox ~= nil ) then
			checkBox:SetChecked(TEXTTOSPEECH_CONFIG.enabledChatTypes[value]);
		end
	end

	-- Update dropdown
	if TextToSpeechFrameTtsVoiceDropdown.RefreshValue ~= nil then
		TextToSpeechFrameTtsVoiceDropdown:RefreshValue();
	end

	-- Update enabled state
	local systemEnabled = TEXTTOSPEECH_CONFIG.enabledChatTypes["CHAT_MSG_SYSTEM"];
	local color = systemEnabled and WHITE_FONT_COLOR or GRAY_FONT_COLOR;
	checkBoxParent.UseAlternateVoiceForSystemMessagesCheckButton:SetEnabled(systemEnabled);
	checkBoxParent.UseAlternateVoiceForSystemMessagesCheckButton.text:SetTextColor(color:GetRGB());

	TextToSpeechFrame_UpdateSliders();
end

function TextToSpeechFrame_UpdateSliders()
	if ( TEXTTOSPEECH_CONFIG.speechRate == nil ) then
		TEXTTOSPEECH_CONFIG.speechRate = TEXTTOSPEECH_CONFIG_DEFAULTS.speechRate;
	end
	if ( TEXTTOSPEECH_CONFIG.speechVolume == nil ) then
		TEXTTOSPEECH_CONFIG.speechVolume = TEXTTOSPEECH_CONFIG_DEFAULTS.speechVolume;
	end

	local rateVolumeEnabled = TEXTTOSPEECH_CONFIG.ttsVoiceOptionSelected > TEXTTOSPEECH_STANDARD_VOICE_COUNT;
	local color = rateVolumeEnabled and WHITE_FONT_COLOR or GRAY_FONT_COLOR;
	TextToSpeechFrameAdjustRateSlider:SetEnabled(rateVolumeEnabled);
	TextToSpeechFrameAdjustRateSlider:SetValue(TEXTTOSPEECH_CONFIG.speechRate);
	TextToSpeechFrameAdjustRateSlider.Label:SetTextColor(color:GetRGB());
	TextToSpeechFrameAdjustRateSlider.High:SetTextColor(color:GetRGB());
	TextToSpeechFrameAdjustVolumeSlider:SetEnabled(rateVolumeEnabled);
	TextToSpeechFrameAdjustVolumeSlider:SetValue(TEXTTOSPEECH_CONFIG.speechVolume);
	TextToSpeechFrameAdjustVolumeSlider.Label:SetTextColor(color:GetRGB());
	TextToSpeechFrameAdjustVolumeSlider.Low:SetTextColor(color:GetRGB());
	TextToSpeechFrameAdjustVolumeSlider.High:SetTextColor(color:GetRGB());
end

function TextToSpeechFrameOkay_OnClick(self, button)
	ToggleTextToSpeechFrame();
end

function TextToSpeechFrameDefaults_OnClick(self, button)
	StaticPopup_Show("CONFIRM_RESET_TEXTTOSPEECH_SETTINGS");
end

function TextToSpeechFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	TextToSpeechFrame_Update(self);
end

function TextToSpeechFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		TextToSpeechFrame_CreateCheckboxes(TextToSpeechFramePanelContainerChatTypeContainer, TextToSpeechChatTypes, "TextToSpeechChatTypeCheckButtonTemplate");
	end
end

function TextToSpeechFrame_OnShow(self)
	TextToSpeechFrame_Update(self);
end

function TextToSpeechFrame_SetToDefaults()
	TEXTTOSPEECH_CONFIG = CopyTable(TEXTTOSPEECH_CONFIG_DEFAULTS);
	TextToSpeechFrame_Update(TextToSpeechFrame);
end

function ToggleTextToSpeechFrame()
	if ( TextToSpeechFrame:IsShown() ) then
		HideUIPanel(TextToSpeechFrame);
	else
		ShowUIPanel(TextToSpeechFrame);
	end
end

function PlaySoundWhenEnteringChatWindowCheckButton_OnLoad(self)
	self.text:SetText(TEXT_TO_SPEECH_PLAY_CHAT_WINDOW_SOUND);
end

function PlaySoundWhenEnteringChatWindowCheckButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	TEXTTOSPEECH_CONFIG.playSoundWhenEnteringChatWindow = self:GetChecked();
end

function PlaySoundSeparatingChatLinesCheckButton_OnLoad(self)
	self.text:SetText(TEXT_TO_SPEECH_PLAY_LINE_BREAK_SOUND);
end

function PlaySoundSeparatingChatLinesCheckButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	TEXTTOSPEECH_CONFIG.playSoundSeparatingChatLineBreaks = self:GetChecked();
end

function AddCharacterNameToSpeechCheckButton_OnLoad(self)
	self.text:SetText(TEXT_TO_SPEECH_ADD_CHARACTER_NAME);
end

function AddCharacterNameToSpeechCheckButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	TEXTTOSPEECH_CONFIG.addCharacterNameToSpeech = self:GetChecked();
end

function PlayActivitySoundWhenNotFocusedCheckButton_OnLoad(self)
	self.text:SetText(TEXT_TO_SPEECH_PLAY_ACTIVITY_SOUND);
end

function PlayActivitySoundWhenNotFocusedCheckButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	TEXTTOSPEECH_CONFIG.playActivitySoundWhenNotFocused = self:GetChecked();
end

function TextToSpeechFrame_CreateCheckboxes(frame, checkBoxTable, checkBoxTemplate)
	local checkBoxNameString = frame:GetName().."CheckBox";
	local checkBoxName, checkBox, check;
	local width, height;
	local text;
	local checkBoxFontString;
	local secondColIndex = 11;

	frame.checkBoxTable = checkBoxTable;
	for index, value in ipairs(checkBoxTable) do
		--If no checkbox then create it
		checkBoxName = checkBoxNameString..index;
		checkBox = _G[checkBoxName];
		if ( not checkBox ) then
			checkBox = CreateFrame("CheckButton", checkBoxName, frame, checkBoxTemplate);
			checkBox:SetID(index);
		end
		if ( not width ) then
			width = checkBox:GetWidth();
			height = checkBox:GetHeight();
		end
		if ( index == secondColIndex ) then
			checkBox:SetPoint("TOP", frame, "TOP", 8, -8);
			checkBox:SetPoint("LEFT", frame, "CENTER", 0, 0);
		elseif ( index > 1 ) then
			checkBox:SetPoint("TOPLEFT", checkBoxNameString..(index-1), "BOTTOMLEFT", 0, 4);
		else
			checkBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -8);
		end
		checkBox.type = value;
		checkBox:SetChecked(TEXTTOSPEECH_CONFIG.enabledChatTypes[type]);
		checkBoxFontString = _G[checkBoxName.."Text"];
		checkBoxFontString:SetText(_G[strsub(value, 10)] or _G[value] or value);
		checkBoxFontString:SetVertexColor(GetMessageTypeColor(value));
		checkBoxFontString:SetMaxLines(1);
	end
end

function TextToSpeechChatTypeCheckButton_OnClick(self, button)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	TEXTTOSPEECH_CONFIG.enabledChatTypes[self.type] = self:GetChecked();

	if self.type == "CHAT_MSG_SYSTEM" then
		TextToSpeechFrame_Update(TextToSpeechFrame);
	end
end

local function TextToSpeechFrameTtsVoiceDropdown_Initialize()
	local selectedValue = UIDropDownMenu_GetSelectedValue(TextToSpeechFrameTtsVoiceDropdown);
	local info = UIDropDownMenu_CreateInfo();

	info.func = TextToSpeechFrameTtsVoiceDropdown_OnClick;

	local voices = C_VoiceChat.GetTtsVoices() or {};

	for index, value in ipairs(voices) do
		if (index <= TEXTTOSPEECH_STANDARD_VOICE_COUNT) then
			info.text = ("%s %d"):format(VOICE, index);
		else
			info.text = value.name;
		end
		info.value = value.voiceID;
		info.checked = value.voiceID == selectedValue;
		UIDropDownMenu_AddButton(info);
	end
end

function TextToSpeechFrameTtsVoiceDropdown_OnLoad(self)
	C_VoiceChat.GetTtsVoices();
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function TextToSpeechFrameTtsVoiceDropdown_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		function self:SetValue(value)
			TEXTTOSPEECH_CONFIG.ttsVoiceOptionSelected = value;
			UIDropDownMenu_SetSelectedValue(self, value);
			TextToSpeechFrame_UpdateSliders();
		end

		function self:GetValue()
			return UIDropDownMenu_GetSelectedValue(self);
		end

		function self:RefreshValue()
			UIDropDownMenu_Initialize(self, TextToSpeechFrameTtsVoiceDropdown_Initialize);
			UIDropDownMenu_SetSelectedValue(self, TEXTTOSPEECH_CONFIG.ttsVoiceOptionSelected);
			TextToSpeechFrame_UpdateSliders();
		end

		UIDropDownMenu_SetWidth(self, 200);
		
		self:RefreshValue();

		self:UnregisterEvent(event);
	end
end

function TextToSpeechFrameTtsVoiceDropdown_OnClick(self)
	TextToSpeechFrameTtsVoiceDropdown:SetValue(self.value);
end

function TextToSpeechFramePlaySampleButton_OnClick(self)
	C_VoiceChat.SpeakText(
		TEXTTOSPEECH_CONFIG.ttsVoiceOptionSelected,
		TEXT_TO_SPEECH_SAMPLE_TEXT,
		Enum.VoiceTtsDestination.QueuedLocalPlayback,
		TEXTTOSPEECH_CONFIG.speechRate,
		TEXTTOSPEECH_CONFIG.speechVolume
	);
end

function UseAlternateVoiceForSystemMessagesCheckButton_OnLoad(self)
	self.text:SetText(TEXT_TO_SPEECH_ALTERNATE_SYSTEM_VOICE);
end

function UseAlternateVoiceForSystemMessagesCheckButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	TEXTTOSPEECH_CONFIG.alternateSystemVoice = self:GetChecked();
end

function TextToSpeechFrameAdjustRateSlider_OnLoad(self)
	self:SetMinMaxValues(-10, 10);
	self:SetValueStep(1);
	self:SetValue(TEXTTOSPEECH_CONFIG.speechRate);
end

function TextToSpeechFrameAdjustRateSlider_OnValueChanged(self, value)
	TEXTTOSPEECH_CONFIG.speechRate = value;
end

function TextToSpeechFrameAdjustVolumeSlider_OnLoad(self)
	self.Low:Hide();
	self.ValueLabel = self.High;
	self:SetMinMaxValues(0, 100);
	self:SetValueStep(1);
	self:SetValue(TEXTTOSPEECH_CONFIG.speechVolume);
end

function TextToSpeechFrameAdjustVolumeSlider_OnValueChanged(self, value)
	TEXTTOSPEECH_CONFIG.speechVolume = value;
	self.ValueLabel:SetFormattedText(PERCENTAGE_STRING, math.floor(value));
end

local lastMessage = nil;
local lastMessageTime = nil;

function TextToSpeechFrame_PlayMessage(frame, message, id)
	local type = nil;
	
	if id then
		type = C_ChatInfo.GetChatTypeName(id);
	end

	-- Any messages missing a type are treated as SYSTEM messages.
	if ( not type ) then
		type = "SYSTEM";
	end

	local chatMsgType = "CHAT_MSG_" .. type;
	local typeGroup = ChatTypeGroupInverted[chatMsgType];

	-- Check that option is enabled for this type or group of types
	if ( not TEXTTOSPEECH_CONFIG.enabledChatTypes[chatMsgType] and (typeGroup and not TEXTTOSPEECH_CONFIG.enabledChatTypes["CHAT_MSG_" .. typeGroup]) ) then
		return;
	end

	-- Check for a valid message
	if ( not message or message == "") then
		return;
	end

	-- Avoid spam and speaking the same line multiple times by suppressing duplicate messages
	local timeNow = GetTime();
	if ( lastMessage ~= nil and lastMessageTime == timeNow and 
		( message == lastMessage
		or message:sub(-lastMessage:len()) == lastMessage 
		or lastMessage:sub(-message:len()) == message ) ) then
		return;
	end

	lastMessage = message;
	lastMessageTime = timeNow;

	-- Check for missing required config values
	if ( TEXTTOSPEECH_CONFIG.ttsVoiceOptionSelected == nil ) then
		TEXTTOSPEECH_CONFIG.ttsVoiceOptionSelected = TEXTTOSPEECH_CONFIG_DEFAULTS.ttsVoiceOptionSelected;
	end
	if ( TEXTTOSPEECH_CONFIG.speechRate == nil ) then
		TEXTTOSPEECH_CONFIG.speechRate = TEXTTOSPEECH_CONFIG_DEFAULTS.speechRate;
	end
	if ( TEXTTOSPEECH_CONFIG.speechVolume == nil ) then
		TEXTTOSPEECH_CONFIG.speechVolume = TEXTTOSPEECH_CONFIG_DEFAULTS.speechVolume;
	end

	local voiceOption = TEXTTOSPEECH_CONFIG.ttsVoiceOptionSelected;
	if ( TEXTTOSPEECH_CONFIG.alternateSystemVoice and type == "SYSTEM" ) then
		local voices = C_VoiceChat.GetTtsVoices() or {};
		local voiceCount = #voices;
		if ( voiceCount > 1 and voiceOption == voices[1].voiceID ) then
			voiceOption = voices[2].voiceID;
		elseif ( voiceCount > 0 ) then
			voiceOption = voices[1].voiceID;
		end
	end

	if ( TEXTTOSPEECH_CONFIG.playActivitySoundWhenNotFocused and not frame:IsShown() ) then
		PlaySound(SOUNDKIT.UI_VOICECHAT_STOPTALK);
	elseif ( TEXTTOSPEECH_CONFIG.playSoundSeparatingChatLineBreaks ) then
		PlaySound(SOUNDKIT.UI_VOICECHAT_TALKSTART);
	end

	C_VoiceChat.SpeakText(
		voiceOption,
		message,
		Enum.VoiceTtsDestination.QueuedLocalPlayback,
		TEXTTOSPEECH_CONFIG.speechRate,
		TEXTTOSPEECH_CONFIG.speechVolume
	);
end

function TextToSpeechFrame_AddMessageObserver(frame, message, r, g, b, id)
	-- Hook any SYSTEM messages added directly by lua
	if ( id and C_ChatInfo.GetChatTypeName(id) == "SYSTEM" ) then
		if ( GetCVarBool("textToSpeech") ) then
			TextToSpeechFrame_PlayMessage(frame, message, id);
		end
	end
end

function TextToSpeechFrame_MessageEventHandler(frame, event, ...)
	if ( not GetCVarBool("textToSpeech") ) then
		return;
	end

	if ( not frame.addMessageObserver ) then
		frame.addMessageObserver = TextToSpeechFrame_AddMessageObserver;
	end

	if ( TEXTTOSPEECH_CONFIG.playSoundWhenEnteringChatWindow and event == "CHAT_MSG_CHANNEL_NOTICE" ) then
		local arg1 = ...;
		if (arg1 == "YOU_CHANGED") then
			PlaySound(SOUNDKIT.UI_VOICECHAT_JOINCHANNEL);
		end
	elseif ( TEXTTOSPEECH_CONFIG.enabledChatTypes[event] ) then
		local arg1, arg2 = ...;

		local message = arg1;
		local name = Ambiguate(arg2, "none");

		-- Check for empty string before adding any text
		if ( not message:find("%a") ) then
			return;
		end

		-- Add optional text
		if ( TEXTTOSPEECH_CONFIG.addCharacterNameToSpeech and name ~= "" ) then
			if ( type == "YELL" ) then
				message = CHAT_YELL_GET:format(name) .. message;
			else
				message = CHAT_SAY_GET:format(name) .. message;
			end
		end

		-- Check for chat text from the local player and skip it
		if ( name == UnitName("player") ) then
			-- Ensure skipped by observer too
			lastMessage = message;
			lastMessageTime = GetTime();
			return
		end

		local chatType = strsub(event, 10);
		local chatTypeInfo = ChatTypeInfo[chatType];
		if chatTypeInfo and chatTypeInfo.id then
			TextToSpeechFrame_PlayMessage(frame, message, chatTypeInfo.id);
		end
	end
end
