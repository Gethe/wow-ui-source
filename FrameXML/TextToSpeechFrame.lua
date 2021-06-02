
TEXTTOSPEECH_CONFIG_DEFAULTS = {
	playSoundSeparatingChatLineBreaks = true,
	addCharacterNameToSpeech = true,
	playActivitySoundWhenNotFocused = true,
	ttsVoiceOptionSelected = 0,
	ttsVoiceOptionSelectedAlternate = 1,
	alternateSystemVoice = true,
	narrateMyMessages = false,
	speechRate = 0,
	speechVolume = 100,
	enabledChatTypes = {
		["CHAT_MSG_EMOTE"] = true,
		["CHAT_MSG_SYSTEM"] = true,
		["CHAT_MSG_WHISPER"] = true,
		["CHAT_MSG_SAY"] = true,
		["CHAT_MSG_YELL"] = true,
		["CHAT_MSG_PARTY_LEADER"] = true,
		["CHAT_MSG_PARTY"] = true,
		["CHAT_MSG_OFFICER"] = true,
		["CHAT_MSG_GUILD"] = true,
		["CHAT_MSG_GUILD_ACHIEVEMENT"] = true,
		["CHAT_MSG_ACHIEVEMENT"] = true,
		["CHAT_MSG_RAID_LEADER"] = true,
		["CHAT_MSG_RAID"] = true,
		["CHAT_MSG_RAID_WARNING"] = true,
		["CHAT_MSG_INSTANCE_CHAT_LEADER"] = true,
		["CHAT_MSG_INSTANCE_CHAT"] = true,
		["CHAT_MSG_BN_WHISPER"] = true,
	}
};

TEXTTOSPEECH_CONFIG = CopyTable(TEXTTOSPEECH_CONFIG_DEFAULTS);

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
	"CHAT_MSG_GUILD_ACHIEVEMENT",
	"CHAT_MSG_ACHIEVEMENT",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_BN_WHISPER",
};

local function GetVoices()
	return C_VoiceChat.GetTtsVoices();
end

local function FindVoiceByID(voiceID)
	local index, value = FindInTableIf(GetVoices(), function(voice)
		return voice.voiceID == voiceID;
	end);
	return index, value;
end

local function FormatVoiceText(voice)
	local index = FindVoiceByID(voice.voiceID);
	return voice.name;
end

TextToSpeech_FindVoiceByID = FindVoiceByID;

function TextToSpeech_GetSetting(setting)
	-- TODO: Moving this to chat settings soon.
	return TEXTTOSPEECH_CONFIG[setting] or TEXTTOSPEECH_CONFIG.enabledChatTypes[setting];
end

function TextToSpeech_Speak(text, optionalVoiceOption)
	local voiceOption = optionalVoiceOption or TEXTTOSPEECH_CONFIG.ttsVoiceOptionSelected;
	C_VoiceChat.SpeakText(
		voiceOption,
		text,
		Enum.VoiceTtsDestination.QueuedLocalPlayback,
		TEXTTOSPEECH_CONFIG.speechRate,
		TEXTTOSPEECH_CONFIG.speechVolume
	);
end

function TextToSpeech_CheckConfig()
	-- Check for missing required config values and reset to default
	for key, value in pairs(TEXTTOSPEECH_CONFIG_DEFAULTS) do
		if TEXTTOSPEECH_CONFIG[key] == nil then
			TEXTTOSPEECH_CONFIG[key] = value;
		end
	end
end

-- [[ TextToSpeechFrame ]] --

function TextToSpeechFrame_Show()
	TextToSpeechFrame:SetShown(not TextToSpeechFrame:IsShown());
end

function TextToSpeechFrame_Update(self)
	-- Update checkboxes
	local checkBoxParent = TextToSpeechFramePanelContainer

	checkBoxParent.PlaySoundSeparatingChatLinesCheckButton:SetChecked(TEXTTOSPEECH_CONFIG.playSoundSeparatingChatLineBreaks);
	checkBoxParent.AddCharacterNameToSpeechCheckButton:SetChecked(TEXTTOSPEECH_CONFIG.addCharacterNameToSpeech);
	checkBoxParent.PlayActivitySoundWhenNotFocusedCheckButton:SetChecked(TEXTTOSPEECH_CONFIG.playActivitySoundWhenNotFocused);
	checkBoxParent.UseAlternateVoiceForSystemMessagesCheckButton:SetChecked(TEXTTOSPEECH_CONFIG.alternateSystemVoice);

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
	TextToSpeechFrameTtsVoiceDropdown_RefreshValue(TextToSpeechFrameTtsVoiceDropdown);

	TextToSpeechFrame_UpdateAlternate();

	TextToSpeechFrame_UpdateSliders();
end

function TextToSpeechFrame_UpdateAlternate()
	TextToSpeechFrameTtsVoiceAlternateDropdown_RefreshValue(TextToSpeechFrameTtsVoiceAlternateDropdown);

	-- Update enabled state
	local systemEnabled = TEXTTOSPEECH_CONFIG.enabledChatTypes["CHAT_MSG_SYSTEM"];
	local color = systemEnabled and WHITE_FONT_COLOR or GRAY_FONT_COLOR;
	TextToSpeechFramePanelContainer.UseAlternateVoiceForSystemMessagesCheckButton:SetEnabled(systemEnabled);
	TextToSpeechFramePanelContainer.UseAlternateVoiceForSystemMessagesCheckButton.text:SetTextColor(color:GetRGB());

	if systemEnabled and TEXTTOSPEECH_CONFIG.alternateSystemVoice then
		UIDropDownMenu_EnableDropDown(TextToSpeechFrameTtsVoiceAlternateDropdown);
	else
		UIDropDownMenu_DisableDropDown(TextToSpeechFrameTtsVoiceAlternateDropdown);
	end

	TextToSpeechFramePlaySampleAlternateButton:SetEnabled(systemEnabled and TEXTTOSPEECH_CONFIG.alternateSystemVoice);
end

function TextToSpeechFrame_UpdateSliders()
	if ( TEXTTOSPEECH_CONFIG.speechRate == nil ) then
		TEXTTOSPEECH_CONFIG.speechRate = TEXTTOSPEECH_CONFIG_DEFAULTS.speechRate;
	end
	if ( TEXTTOSPEECH_CONFIG.speechVolume == nil ) then
		TEXTTOSPEECH_CONFIG.speechVolume = TEXTTOSPEECH_CONFIG_DEFAULTS.speechVolume;
	end

	TextToSpeechFrameAdjustRateSlider:SetValue(TEXTTOSPEECH_CONFIG.speechRate);
	TextToSpeechFrameAdjustVolumeSlider:SetValue(TEXTTOSPEECH_CONFIG.speechVolume);
end

function TextToSpeechFrameOkay_OnClick(self, button)
	ToggleTextToSpeechFrame();
end

function TextToSpeechFrameDefaults_OnClick(self, button)
	StaticPopup_Show("CONFIRM_RESET_TEXTTOSPEECH_SETTINGS");
end

function TextToSpeechFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("VARIABLES_LOADED");
	TextToSpeechFrame_Update(self);
end

function TextToSpeechFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		TextToSpeechFrame_CreateCheckboxes(TextToSpeechFramePanelContainerChatTypeContainer, TextToSpeechChatTypes, "TextToSpeechChatTypeCheckButtonTemplate");
	elseif ( event == "VARIABLES_LOADED" ) then
		TextToSpeech_CheckConfig();
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
        return false;
	else
		ShowUIPanel(TextToSpeechFrame);
        return true;
	end
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
	local info = UIDropDownMenu_CreateInfo();
	info.customFrame = TextToSpeechFramePanelContainer.VoicePicker;
	UIDropDownMenu_AddButton(info);
end

function TextToSpeechFrameTtsVoiceDropdown_OnLoad(self)
	C_VoiceChat.GetTtsVoices();
	self:RegisterEvent("PLAYER_ENTERING_WORLD");

	UIDropDownMenu_SetInitializeFunction(self, TextToSpeechFrameTtsVoiceDropdown_Initialize);
end

function TextToSpeechFrameTtsVoiceDropdown_RefreshValue(self)
	local index, voice = FindVoiceByID(TEXTTOSPEECH_CONFIG.ttsVoiceOptionSelected);
	if voice then
		UIDropDownMenu_SetText(self, FormatVoiceText(voice));
	end
end

function TextToSpeechFrameTtsVoiceDropdown_SetVoiceID(self, voiceID)
	TEXTTOSPEECH_CONFIG.ttsVoiceOptionSelected = voiceID;
	TextToSpeechFrameTtsVoiceDropdown_RefreshValue(self);
end

function TextToSpeechFrameTtsVoiceDropdown_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		UIDropDownMenu_SetWidth(self, 200);

		TextToSpeechFrameTtsVoiceDropdown_RefreshValue(self);

		self:UnregisterEvent(event);
	end
end

local function TextToSpeechFrameTtsVoiceAlternateDropdown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	info.customFrame = TextToSpeechFramePanelContainer.VoiceAlternatePicker;
	UIDropDownMenu_AddButton(info);
end

function TextToSpeechFrameTtsVoiceAlternateDropdown_OnLoad(self)
	C_VoiceChat.GetTtsVoices();
	self:RegisterEvent("PLAYER_ENTERING_WORLD");

	UIDropDownMenu_SetInitializeFunction(self, TextToSpeechFrameTtsVoiceAlternateDropdown_Initialize);
end

function TextToSpeechFrameTtsVoiceAlternateDropdown_RefreshValue(self)
	local index, voice = FindVoiceByID(TEXTTOSPEECH_CONFIG.ttsVoiceOptionSelectedAlternate);
	if voice then
		UIDropDownMenu_SetText(self, FormatVoiceText(voice));
	end
end

function TextToSpeechFrameTtsVoiceAlternateDropdown_SetVoiceID(self, voiceID)
	TEXTTOSPEECH_CONFIG.ttsVoiceOptionSelectedAlternate = voiceID;
	TextToSpeechFrameTtsVoiceAlternateDropdown_RefreshValue(self);
end

function TextToSpeechFrameTtsVoiceAlternateDropdown_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		UIDropDownMenu_SetWidth(self, 200);

		TextToSpeechFrameTtsVoiceAlternateDropdown_RefreshValue(self);

		self:UnregisterEvent(event);
	end
end

function TextToSpeechFrameTtsVoicePicker_OnLoad(self)
	local view = CreateScrollBoxListLinearView();
	view:SetElementExtent(18);
	view:SetElementInitializer("Button", "TextToSpeechVoicePickerButtonTemplate", function(button, voice)
		local checked = voice.voiceID == TEXTTOSPEECH_CONFIG.ttsVoiceOptionSelected;
		button.Check:SetShown(checked);
		button.UnCheck:SetShown(not checked);

		button:SetText(FormatVoiceText(voice));

		button:SetScript("OnClick", function(button, buttonName)
			TextToSpeechFrameTtsVoiceDropdown_SetVoiceID(TextToSpeechFrameTtsVoiceDropdown, voice.voiceID);
			CloseDropDownMenus();
		end);
	end);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function TextToSpeechFrameTtsVoiceAlternatePicker_OnLoad(self)
	local view = CreateScrollBoxListLinearView();
	view:SetElementExtent(18);
	view:SetElementInitializer("Button", "TextToSpeechVoicePickerButtonTemplate", function(button, voice)
		local checked = voice.voiceID == TEXTTOSPEECH_CONFIG.ttsVoiceOptionSelectedAlternate;
		button.Check:SetShown(checked);
		button.UnCheck:SetShown(not checked);

		button:SetText(FormatVoiceText(voice));

		button:SetScript("OnClick", function(button, buttonName)
			TextToSpeechFrameTtsVoiceAlternateDropdown_SetVoiceID(TextToSpeechFrameTtsVoiceAlternateDropdown, voice.voiceID);
			CloseDropDownMenus();
		end);
	end);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function TextToSpeechFrameTtsVoicePicker_OnShow(self)
	local dataProvider = CreateDataProvider(GetVoices());

	local elementHeight = 18;
	local maxVisibleLines = 6;
	local maxHeight = maxVisibleLines * elementHeight;
	local utilizedHeight = elementHeight * dataProvider:GetSize();

	self:SetHeight(math.min(utilizedHeight, maxHeight));
	self:SetWidth(350);

	local scrollBarShown = dataProvider:GetSize() > maxVisibleLines;
	self.ScrollBar:SetShown(scrollBarShown);
	self.ScrollBox:SetPoint("BOTTOMRIGHT", (scrollBarShown and -25 or 0), 0);
	self.ScrollBox:SetDataProvider(dataProvider);
end

function TextToSpeechFramePlaySampleButton_OnClick(self)
	TextToSpeech_Speak(TEXT_TO_SPEECH_SAMPLE_TEXT);
end

function TextToSpeechFramePlaySampleAlternateButton_OnClick(self)
	TextToSpeech_Speak(TEXT_TO_SPEECH_SAMPLE_TEXT, TEXTTOSPEECH_CONFIG.ttsVoiceOptionSelectedAlternate);
end

function UseAlternateVoiceForSystemMessagesCheckButton_OnLoad(self)
	self.text:SetText(TEXT_TO_SPEECH_ALTERNATE_SYSTEM_VOICE);
end

function UseAlternateVoiceForSystemMessagesCheckButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	TEXTTOSPEECH_CONFIG.alternateSystemVoice = self:GetChecked();
	TextToSpeechFrame_UpdateAlternate();
end

function TextToSpeech_SetRate(rate)
	rate = tonumber(rate);
	if type(rate) == "number" then
		if rate >= TEXTTOSPEECH_RATE_MIN and rate <= TEXTTOSPEECH_RATE_MAX then
			TextToSpeechFrameAdjustRateSlider:SetValue(Clamp(rate, TEXTTOSPEECH_RATE_MIN, TEXTTOSPEECH_RATE_MAX));
			return true;
		end
	end

	return false;
end

function TextToSpeechFrameAdjustRateSlider_OnLoad(self)
	self:SetMinMaxValues(TEXTTOSPEECH_RATE_MIN, TEXTTOSPEECH_RATE_MAX);
	self:SetValueStep(1);
	self:SetValue(TEXTTOSPEECH_CONFIG.speechRate);
end

function TextToSpeechFrameAdjustRateSlider_OnValueChanged(self, value)
	TEXTTOSPEECH_CONFIG.speechRate = value;
end

function TextToSpeech_SetVolume(volume)
	if type(volume) == "number" then
		if volume >= TEXTTOSPEECH_VOLUME_MIN and volume <= TEXTTOSPEECH_VOLUME_MAX then
			TextToSpeechFrameAdjustVolumeSlider:SetValue(Clamp(volume, TEXTTOSPEECH_VOLUME_MIN, TEXTTOSPEECH_VOLUME_MAX));
			return true;
		end
	end

	return false;
end

function TextToSpeechFrameAdjustVolumeSlider_OnLoad(self)
	self.Low:Hide();
	self.ValueLabel = self.High;
	self:SetMinMaxValues(TEXTTOSPEECH_VOLUME_MIN, TEXTTOSPEECH_VOLUME_MAX);
	self:SetValueStep(1);
	self:SetValue(TEXTTOSPEECH_CONFIG.speechVolume);
end

function TextToSpeechFrameAdjustVolumeSlider_OnValueChanged(self, value)
	TEXTTOSPEECH_CONFIG.speechVolume = value;
	self.ValueLabel:SetFormattedText(PERCENTAGE_STRING, math.floor(value));
end

function TextToSpeech_SetVoice(newVoice)
	newVoice = (newVoice and newVoice ~= "") and tonumber(newVoice);
	local voices = C_VoiceChat.GetTtsVoices();

	if newVoice then
		for index, voice in ipairs(voices) do
			if voice.voiceID == newVoice then
				TEXTTOSPEECH_CONFIG.ttsVoiceOptionSelected = newVoice;
				break;
			end
		end
	else
		local nextVoice = 1;
		for index, voice in ipairs(voices) do
			if voice.voiceID == TEXTTOSPEECH_CONFIG.ttsVoiceOptionSelected and index < #voices then
				nextVoice = index + 1;
				break;
			end
		end
		if nextVoice <= #voices then
			TEXTTOSPEECH_CONFIG.ttsVoiceOptionSelected = voices[nextVoice].voiceID;
		end
	end

	local _, voice = TextToSpeech_FindVoiceByID(TEXTTOSPEECH_CONFIG.ttsVoiceOptionSelected);
	return voice;
end

function TextToSpeech_ResetDefaults()
	TEXTTOSPEECH_CONFIG = CopyTable(TEXTTOSPEECH_CONFIG_DEFAULTS);
	TextToSpeechFrame_Update(TextToSpeechFrame);
end

local lastMessage = nil;
local lastMessageTime = nil;

function TextToSpeechFrame_PlayMessage(frame, message, id, ignoreTypeFilters)
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
	if not ignoreTypeFilters then
		if ( not TEXTTOSPEECH_CONFIG.enabledChatTypes[chatMsgType] and (typeGroup and not TEXTTOSPEECH_CONFIG.enabledChatTypes["CHAT_MSG_" .. typeGroup]) ) then
			return;
		end
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

	TextToSpeech_CheckConfig();

	local voiceOption = TEXTTOSPEECH_CONFIG.ttsVoiceOptionSelected;
	if ( TEXTTOSPEECH_CONFIG.alternateSystemVoice and type == "SYSTEM" ) then
		voiceOption = TEXTTOSPEECH_CONFIG.ttsVoiceOptionSelectedAlternate;
	end

	if ( TEXTTOSPEECH_CONFIG.playActivitySoundWhenNotFocused and not frame:IsShown() ) then
		PlaySound(SOUNDKIT.UI_VOICECHAT_TTSACTIVITY);
	elseif ( TEXTTOSPEECH_CONFIG.playSoundSeparatingChatLineBreaks ) then
		PlaySound(SOUNDKIT.UI_VOICECHAT_TTSMESSAGE);
	end

	TextToSpeech_Speak(message, voiceOption);
end

function TextToSpeechFrame_AddMessageObserver(frame, message, r, g, b, id)
	-- Hook any SYSTEM messages added directly by lua
	if ( id and C_ChatInfo.GetChatTypeName(id) == "SYSTEM" ) then
		if ( GetCVarBool("textToSpeech") ) then
			TextToSpeechFrame_PlayMessage(frame, message, id);
		end
	end
end

local ignoredMsgTypes = {
	ACHIEVEMENT = true,
	GUILD_ACHIEVEMENT = true,
	--SYSTEM = true,
}

local function IsMessageFromPlayer(msgType, msgSenderName)
	return not ignoredMsgTypes[msgType] and msgSenderName == UnitName("player");
end

function TextToSpeechFrame_SetChatTypeEnabled(msgType, enabled)
	if msgType then
		TEXTTOSPEECH_CONFIG.enabledChatTypes[msgType] = enabled;
		return enabled;
	end
end

function TextToSpeechFrame_GetChatTypeEnabled(msgType)
	return msgType and TEXTTOSPEECH_CONFIG.enabledChatTypes[msgType];
end

function TextToSpeechFrame_ToggleChatTypeEnabled(msgType)
	return TextToSpeechFrame_SetChatTypeEnabled(msgType, not TextToSpeechFrame_GetChatTypeEnabled(msgType));
end

function TextToSpeechFrame_DisplaySilentSystemMessage(text)
	local wasEnabled = TextToSpeechFrame_GetChatTypeEnabled("CHAT_MSG_SYSTEM");
	TextToSpeechFrame_SetChatTypeEnabled("CHAT_MSG_SYSTEM", false);
	ChatFrame_DisplaySystemMessageInPrimary(text);
	TextToSpeechFrame_SetChatTypeEnabled("CHAT_MSG_SYSTEM", wasEnabled);
end

function TextToSpeechFrame_MessageEventHandler(frame, event, ...)
	if ( not GetCVarBool("textToSpeech") ) then
		return;
	end

	if ( not frame.addMessageObserver ) then
		frame.addMessageObserver = TextToSpeechFrame_AddMessageObserver;
	end

	local typeGroup = ChatTypeGroupInverted[event];
	if TEXTTOSPEECH_CONFIG.enabledChatTypes[event] or (typeGroup and TextToSpeechFrame_GetChatTypeEnabled("CHAT_MSG_" .. typeGroup)) then
		local arg1, arg2 = ...;

		local message = arg1;
		local name = Ambiguate(arg2 or "", "none");

		-- Add optional text
		local type = strsub(event, 10);
		if ( type == "GUILD_ACHIEVEMENT" or type == "ACHIEVEMENT" ) then
			message = message:format(name);
		elseif ( type ~= "TEXT_EMOTE" and TEXTTOSPEECH_CONFIG.addCharacterNameToSpeech and name ~= "" ) then
			if ( type == "YELL" ) then
				message = CHAT_YELL_GET:format(name) .. message;
			elseif ( type == "WHISPER" or type == "BN_WHISPER" ) then
				message = CHAT_WHISPER_GET:format(name) .. message;
			else
				message = CHAT_SAY_GET:format(name) .. message;
			end
		end

		-- Check for chat text from the local player and skip it, unless the player wants their messages narrated
		if IsMessageFromPlayer(type, name) and not TEXTTOSPEECH_CONFIG.narrateMyMessages then
			-- Ensure skipped by observer too
			lastMessage = message;
			lastMessageTime = GetTime();
			return;
		end

		local chatType = strsub(event, 10);
		local chatTypeInfo = ChatTypeInfo[chatType];
		if chatTypeInfo and chatTypeInfo.id then
			TextToSpeechFrame_PlayMessage(frame, message, chatTypeInfo.id);
		end
	end
end
