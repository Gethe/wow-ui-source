
TEXTTOSPEECH_CONFIG_DEFAULTS = {
	playSoundSeparatingChatLineBreaks = true,
	addCharacterNameToSpeech = true,
	playActivitySoundWhenNotFocused = true,
	ttsVoiceOptionStandardDefault = 0,
	ttsVoiceOptionStandard = nil,
	ttsVoiceOptionAlternateDefault = 1,
	ttsVoiceOptionAlternate = nil,
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
	},
	enabledChannelTypes = {},
};

TEXTTOSPEECH_CONFIG = CopyTable(TEXTTOSPEECH_CONFIG_DEFAULTS);

local playbackActive = false;
local queuedMessages = {};

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

local function FormatVoiceText(voice)
	return voice.name;
end

local function FindVoiceByName(voices, voiceName)
	return FindInTableIf(voices, function(voice) return voice.name == voiceName; end);
end

local function FindVoiceByID(voices, voiceID)
	return FindInTableIf(voices, function(voice) return voice.voiceID == voiceID; end);
end

local function FindVoiceBySetting(voiceNameKey, voiceDefaultIDKey)
	local voices = C_VoiceChat.GetTtsVoices();
	local index, voice = FindVoiceByName(voices, TEXTTOSPEECH_CONFIG[voiceNameKey]);
	if not voice then
		index, voice = FindVoiceByID(voices, TEXTTOSPEECH_CONFIG[voiceDefaultIDKey]);
	end

	return voice;
end

local cachedVoices = {};
local function CacheVoice(voiceType, voice)
	cachedVoices[voiceType] = voice;
	return voice;
end

local function GetSelectedVoiceBySettings(settingName, settingDefaultID)
	local cachedVoice = cachedVoices[settingName];
	if cachedVoice then
		return cachedVoice;
	end

	return CacheVoice(settingName, FindVoiceBySetting(settingName, settingDefaultID));
end

local function GetSettingNamesByVoiceType(voiceType)
	if voiceType == "alternate" then
		return "ttsVoiceOptionAlternate", "ttsVoiceOptionAlternateDefault";
	end

	return "ttsVoiceOptionStandard", "ttsVoiceOptionStandardDefault";
end

function TextToSpeech_GetSelectedVoice(voiceType)
	return GetSelectedVoiceBySettings(GetSettingNamesByVoiceType(voiceType));
end

function TextToSpeech_IsSelectedVoice(voice, voiceType)
	if voice then
		local selectedVoice = TextToSpeech_GetSelectedVoice(voiceType);
		if selectedVoice then
			return selectedVoice.name == voice.name;
		end
	end

	return false;
end

function TextToSpeech_SetSelectedVoice(voice, voiceType)
	local settingName = GetSettingNamesByVoiceType(voiceType);
	TEXTTOSPEECH_CONFIG[settingName] = voice.name;
	CacheVoice(settingName, voice);
end

function TextToSpeech_GetSetting(setting)
	-- TODO: Moving this to chat settings soon.
	return TEXTTOSPEECH_CONFIG[setting] or TextToSpeechFrame_GetChatTypeEnabled(setting);
end

function TextToSpeech_IsUsingAlternateSystemVoice()
	return TextToSpeech_GetSetting("alternateSystemVoice");
end

function TextToSpeech_SetUseAlternateSystemVoice(enabled)
	TEXTTOSPEECH_CONFIG.alternateSystemVoice = enabled;
end

function TextToSpeech_PlaySample(voiceType)
	TextToSpeech_Speak(TEXT_TO_SPEECH_SAMPLE_TEXT, TextToSpeech_GetSelectedVoice(voiceType));
end

function TextToSpeech_Speak(text, voice)
	-- Queue messages
	if playbackActive then
		table.insert(queuedMessages, {text=text, voice=voice});
		return;
	end

	playbackActive = true;

	C_VoiceChat.SpeakText(
		voice.voiceID,
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
	checkBoxParent.NarrateMyMessagesCheckButton:SetChecked(TEXTTOSPEECH_CONFIG.narrateMyMessages);
	checkBoxParent.UseAlternateVoiceForSystemMessagesCheckButton:SetChecked(TextToSpeech_IsUsingAlternateSystemVoice());

	if ChatConfigTextToSpeechMessageSettingsChatTypeContainer then
		TextToSpeechFrame_UpdateMessageCheckboxes(ChatConfigTextToSpeechMessageSettingsChatTypeContainer);
	end

	-- Update dropdown
	TextToSpeechFrameTtsVoiceDropdown_RefreshValue(TextToSpeechFrameTtsVoiceDropdown);

	TextToSpeechFrame_UpdateAlternate();

	TextToSpeechFrame_UpdateSliders();
end

function TextToSpeechFrame_UpdateMessageCheckboxes(frame)
	local checkBoxNameString = frame:GetName().."CheckBox";
	local checkBoxName, checkBox;

	local checkBoxTable = frame.checkBoxTable or {}
	for index, value in ipairs(checkBoxTable) do
		checkBoxName = checkBoxNameString..index;
		checkBox = _G[checkBoxName];
		if ( checkBox ~= nil ) then
			checkBox:SetChecked(TextToSpeechFrame_GetChatTypeEnabled(value));
		end
	end
end

function TextToSpeechFrame_UpdateAlternate()
	TextToSpeechFrameTtsVoiceAlternateDropdown_RefreshValue(TextToSpeechFrameTtsVoiceAlternateDropdown);

	-- Update enabled state
	local systemEnabled = TextToSpeechFrame_GetChatTypeEnabled("CHAT_MSG_SYSTEM");
	local color = systemEnabled and WHITE_FONT_COLOR or GRAY_FONT_COLOR;
	TextToSpeechFramePanelContainer.UseAlternateVoiceForSystemMessagesCheckButton:SetEnabled(systemEnabled);
	TextToSpeechFramePanelContainer.UseAlternateVoiceForSystemMessagesCheckButton.text:SetTextColor(color:GetRGB());

	local enabled = systemEnabled and TextToSpeech_IsUsingAlternateSystemVoice();
	UIDropDownMenu_SetDropDownEnabled(TextToSpeechFrameTtsVoiceAlternateDropdown, enabled);
	TextToSpeechFramePlaySampleAlternateButton:SetEnabled(enabled);
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

function TextToSpeechFrameDefaults_OnClick(self, button)
	StaticPopup_Show("CONFIRM_RESET_TEXTTOSPEECH_SETTINGS");
end

local loadEvents = {
	"PLAYER_ENTERING_WORLD",
	"VARIABLES_LOADED",
	"ADDON_LOADED",
};

local function IsReadyToLoad(loadedEvents)
	for index, event in pairs(loadEvents) do
		if not loadedEvents[event] then
			return false;
		end
	end

	return true;
end

function TextToSpeechFrame_OnLoad(self)
	self.loadedEvents = {};
	FrameUtil.RegisterFrameForEvents(self, loadEvents);

	self:RegisterEvent("VOICE_CHAT_TTS_PLAYBACK_FAILED");
	self:RegisterEvent("VOICE_CHAT_TTS_PLAYBACK_FINISHED");
end

function TextToSpeechFrame_CheckLoad(self)
	if IsReadyToLoad(self.loadedEvents) then
		C_VoiceChat.GetTtsVoices();

		TextToSpeechFrameTtsVoiceDropdown_OnLoad(self.PanelContainer.TtsVoiceDropdown);
		TextToSpeechFrameTtsVoiceAlternateDropdown_OnLoad(self.PanelContainer.TtsVoiceAlternateDropdown);
		TextToSpeechFrame_Update(self);
		TextToSpeechFrame_CreateCheckboxes(ChatConfigTextToSpeechMessageSettingsChatTypeContainer, TextToSpeechChatTypes, "TextToSpeechChatTypeCheckButtonTemplate");
		TextToSpeech_CheckConfig();
	end
end

function TextToSpeechFrame_OnEvent(self, event, ...)
	if event == "ADDON_LOADED" then
		local addonName = ...;
		if addonName == "Blizzard_ClientSavedVariables" then
			self.loadedEvents[event] = true;
		end
	elseif event == "VOICE_CHAT_TTS_PLAYBACK_FINISHED" or event == "VOICE_CHAT_TTS_PLAYBACK_FAILED" then
		playbackActive = false;

		if ( TEXTTOSPEECH_CONFIG.playSoundSeparatingChatLineBreaks ) then
			PlaySound(SOUNDKIT.UI_VOICECHAT_TTSMESSAGE);
		end

		if #queuedMessages > 0 then
			local queuedMessage = table.remove(queuedMessages, 1);

			-- Add short delay for message sound if enabled, otherwise play next immediately
			if ( TEXTTOSPEECH_CONFIG.playSoundSeparatingChatLineBreaks ) then
				C_Timer.After(1, function()
					TextToSpeech_Speak(queuedMessage.text, queuedMessage.voice);
				end);
			else
				TextToSpeech_Speak(queuedMessage.text, queuedMessage.voice);
			end
		end
	else
		self.loadedEvents[event] = true;
	end

	TextToSpeechFrame_CheckLoad(self);
end

function TextToSpeechFrame_OnShow(self)
	TextToSpeechFrame_Update(self);
end

function TextToSpeechFrame_SetToDefaults()
	TEXTTOSPEECH_CONFIG = CopyTable(TEXTTOSPEECH_CONFIG_DEFAULTS);
	TextToSpeechFrame_Update(TextToSpeechFrame);
end

function ToggleTextToSpeechFrame()
	if ( ChatConfigFrame:IsShown() ) then
		HideUIPanel(ChatConfigFrame);
        return false;
	else
		ShowUIPanel(ChatConfigFrame);
		ChatConfigFrameChatTabManager:UpdateSelection(VOICE_WINDOW_ID);
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

function NarrateMyMessagesCheckButton_OnLoad(self)
	self.text:SetText(TEXT_TO_SPEECH_NARRATE_MY_MESSAGES);
end

function NarrateMyMessagesCheckButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	TEXTTOSPEECH_CONFIG.narrateMyMessages = self:GetChecked();
end

function TextToSpeechFrame_CreateCheckboxes(frame, checkBoxTable, checkBoxTemplate)
	local checkBoxNameString = frame:GetName().."CheckBox";
	local checkBoxName, checkBox, check;
	local width, height;
	local text;
	local checkBoxFontString;
	local secondColIndex = 15;

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
		checkBox:SetChecked(TextToSpeechFrame_GetChatTypeEnabled(type));
		checkBoxFontString = checkBox.text;
		checkBoxFontString:SetText(_G[strsub(value, 10)] or _G[value] or value);
		checkBoxFontString:SetVertexColor(GetMessageTypeColor(value));
		checkBoxFontString:SetMaxLines(1);
	end
end

function TextToSpeechChatTypeCheckButton_OnClick(self, button)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	TextToSpeechFrame_SetChatTypeEnabled(self.type, self:GetChecked());

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
	UIDropDownMenu_SetInitializeFunction(self, TextToSpeechFrameTtsVoiceDropdown_Initialize);
	UIDropDownMenu_SetWidth(self, 200);
	TextToSpeechFrameTtsVoiceDropdown_RefreshValue(self);
end

function TextToSpeechFrameTtsVoiceDropdown_RefreshValue(self)
	local voice = TextToSpeech_GetSelectedVoice("standard");
	if voice then
		UIDropDownMenu_SetText(self, FormatVoiceText(voice));
	end
end

function TextToSpeechFrameTtsVoiceDropdown_SetSelectedVoice(self, voice)
	TextToSpeech_SetSelectedVoice(voice);
	TextToSpeechFrameTtsVoiceDropdown_RefreshValue(self);
end

local function TextToSpeechFrameTtsVoiceAlternateDropdown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	info.customFrame = TextToSpeechFramePanelContainer.VoiceAlternatePicker;
	UIDropDownMenu_AddButton(info);
end

function TextToSpeechFrameTtsVoiceAlternateDropdown_OnLoad(self)
	UIDropDownMenu_SetInitializeFunction(self, TextToSpeechFrameTtsVoiceAlternateDropdown_Initialize);
	UIDropDownMenu_SetWidth(self, 200);
	TextToSpeechFrameTtsVoiceAlternateDropdown_RefreshValue(self);
end

function TextToSpeechFrameTtsVoiceAlternateDropdown_RefreshValue(self)
	local voice = TextToSpeech_GetSelectedVoice("alternate");
	if voice then
		UIDropDownMenu_SetText(self, FormatVoiceText(voice));
	end
end

function TextToSpeechFrameTtsVoiceAlternateDropdown_SetSelectedVoice(self, voice)
	TextToSpeech_SetSelectedVoice(voice, "alternate");
	TextToSpeechFrameTtsVoiceAlternateDropdown_RefreshValue(self);
end

function TextToSpeechFrameTtsVoicePicker_OnLoad(self)
	local view = CreateScrollBoxListLinearView();
	view:SetElementExtent(18);
	view:SetElementInitializer("Button", "TextToSpeechVoicePickerButtonTemplate", function(button, voice)
		local checked = TextToSpeech_IsSelectedVoice(voice);
		button.Check:SetShown(checked);
		button.UnCheck:SetShown(not checked);

		button:SetText(FormatVoiceText(voice));

		button:SetScript("OnClick", function(button, buttonName)
			TextToSpeechFrameTtsVoiceDropdown_SetSelectedVoice(TextToSpeechFrameTtsVoiceDropdown, voice);
			CloseDropDownMenus();
		end);
	end);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function TextToSpeechFrameTtsVoiceAlternatePicker_OnLoad(self)
	local view = CreateScrollBoxListLinearView();
	view:SetElementExtent(18);
	view:SetElementInitializer("Button", "TextToSpeechVoicePickerButtonTemplate", function(button, voice)
		local checked = TextToSpeech_IsSelectedVoice("alternate");
		button.Check:SetShown(checked);
		button.UnCheck:SetShown(not checked);

		button:SetText(FormatVoiceText(voice));

		button:SetScript("OnClick", function(button, buttonName)
			TextToSpeechFrameTtsVoiceAlternateDropdown_SetSelectedVoice(TextToSpeechFrameTtsVoiceAlternateDropdown, voice);
			CloseDropDownMenus();
		end);
	end);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function TextToSpeechFrameTtsVoicePicker_OnShow(self)
	local dataProvider = CreateDataProvider(C_VoiceChat.GetTtsVoices());

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
	TextToSpeech_PlaySample("standard");
end

function TextToSpeechFramePlaySampleAlternateButton_OnClick(self)
	TextToSpeech_PlaySample("alternate");
end

function UseAlternateVoiceForSystemMessagesCheckButton_OnLoad(self)
	self.text:SetText(TEXT_TO_SPEECH_ALTERNATE_SYSTEM_VOICE);
end

function UseAlternateVoiceForSystemMessagesCheckButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	TextToSpeech_SetUseAlternateSystemVoice(self:GetChecked());
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
	self.Low:SetText(SLOW);
	self.High:SetText(FAST);
	self:SetMinMaxValues(TEXTTOSPEECH_RATE_MIN, TEXTTOSPEECH_RATE_MAX);
	self:SetValueStep(1);
	self:SetValue(TEXTTOSPEECH_CONFIG.speechRate);
end

function TextToSpeechFrameAdjustRateSlider_OnValueChanged(self, value)
	TEXTTOSPEECH_CONFIG.speechRate = value;
end

function TextToSpeech_SetVolume(volume)
	volume = tonumber(volume);
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

local function TextToSpeech_GetNextVoice(voices, voiceType)
	local selectedVoice = TextToSpeech_GetSelectedVoice(voiceType);
	if selectedVoice then
		local index, voice = FindVoiceByName(voices, selectedVoice.name);
		if index + 1 <= #voices then
			return voices[index + 1];
		end
	end

	-- Default to voice 1.
	if #voices > 0 then
		return voices[1];
	end
end

function TextToSpeech_SetVoice(newVoiceID, voiceType)
	newVoiceID = (newVoiceID and newVoiceID ~= "") and tonumber(newVoiceID);
	local voices = C_VoiceChat.GetTtsVoices();

	if newVoiceID then
		local _, voice = FindVoiceByID(voices, newVoiceID);
		if voice then
			TextToSpeech_SetSelectedVoice(voice, voiceType);
			return TextToSpeech_GetSelectedVoice(voiceType);
		end
	else
		local nextVoice = TextToSpeech_GetNextVoice(voices, voiceType);
		if nextVoice then
			TextToSpeech_SetSelectedVoice(nextVoice, voiceType);
			return TextToSpeech_GetSelectedVoice(voiceType);
		end
	end

	return nil;
end

function TextToSpeech_ResetDefaults()
	TEXTTOSPEECH_CONFIG = CopyTable(TEXTTOSPEECH_CONFIG_DEFAULTS);
	TextToSpeechFrame_Update(TextToSpeechFrame);
end

local lastMessage = nil;
local lastMessageTime = nil;

local function IsMessageTypeEnabled(messageType)
	local chatMsgType = "CHAT_MSG_" .. messageType;

	if messageType == "CHANNEL" or messageType == "COMMUNITIES_CHANNEL" then
		return true; -- These are always enabled, if we make it this far then the other filters passed.
	end

	if TextToSpeechFrame_GetChatTypeEnabled(chatMsgType) then
		return true;
	end

	local typeGroup = ChatTypeGroupInverted[chatMsgType];
	if typeGroup and TextToSpeechFrame_GetChatTypeEnabled("CHAT_MSG_" .. typeGroup) then
		return true;
	end

	return false;
end

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
		if not IsMessageTypeEnabled(type) then
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

	local voice = TextToSpeech_GetSelectedVoice("standard");
	if type == "SYSTEM" and TextToSpeech_IsUsingAlternateSystemVoice() then
		local alternateVoice = TextToSpeech_GetSelectedVoice("alternate");
		if alternateVoice then
			voice = alternateVoice;
		end
	end

	if ( TEXTTOSPEECH_CONFIG.playActivitySoundWhenNotFocused and not frame:IsShown() ) then
		PlaySound(SOUNDKIT.UI_VOICECHAT_TTSACTIVITY);
	end

	TextToSpeech_Speak(message, voice);
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

local chatTypeMappings = {
	CHAT_MSG_TEXT_EMOTE = "CHAT_MSG_EMOTE";
};

function TextToSpeechFrame_GetChatTypeEnabled(msgType)
	if msgType then
		return TEXTTOSPEECH_CONFIG.enabledChatTypes[chatTypeMappings[msgType] or msgType];
	end

	return false;
end

function TextToSpeechFrame_ToggleChatTypeEnabled(msgType)
	return TextToSpeechFrame_SetChatTypeEnabled(msgType, not TextToSpeechFrame_GetChatTypeEnabled(msgType));
end

local CHANNEL_KEY_FORMAT = "%s:%s";
local function GetChannelKey(channelInfo)
	if channelInfo.channelType == Enum.PermanentChatChannelType.Zone then
		return CHANNEL_KEY_FORMAT:format(tostring(channelInfo.channelType), tostring(channelInfo.zoneChannelID));
	end

	return CHANNEL_KEY_FORMAT:format(tostring(channelInfo.channelType), tostring(channelInfo.name));
end

function TextToSpeechFrame_SetChannelEnabled(channelInfo, enabled)
	if channelInfo then
		TEXTTOSPEECH_CONFIG.enabledChannelTypes[GetChannelKey(channelInfo)] = enabled;
		return enabled;
	end
end

function TextToSpeechFrame_GetChannelEnabled(channelInfo)
	return channelInfo and TEXTTOSPEECH_CONFIG.enabledChannelTypes[GetChannelKey(channelInfo)];
end

function TextToSpeechFrame_ToggleChannelEnabled(channelInfo)
	return TextToSpeechFrame_SetChannelEnabled(channelInfo, not TextToSpeechFrame_GetChannelEnabled(channelInfo));
end

function TextToSpeechFrame_DisplaySilentSystemMessage(text)
	local wasEnabled = TextToSpeechFrame_GetChatTypeEnabled("CHAT_MSG_SYSTEM");
	TextToSpeechFrame_SetChatTypeEnabled("CHAT_MSG_SYSTEM", false);
	ChatFrame_DisplaySystemMessageInPrimary(text);
	TextToSpeechFrame_SetChatTypeEnabled("CHAT_MSG_SYSTEM", wasEnabled);
end

function TextToSpeechFrame_IsEventNarrationEnabled(event, ...)
	local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18 = ...;

	if TextToSpeechFrame_GetChatTypeEnabled(event) then
		return true;
	end

	if event == "CHAT_MSG_CHANNEL" or event == "CHAT_MSG_COMMUNITIES_CHANNEL" then
		local localID = tostring(arg8);
		local channelInfo = C_ChatInfo.GetChannelInfoFromIdentifier(localID);
		return TextToSpeechFrame_GetChannelEnabled(channelInfo);
	end

	local typeGroup = ChatTypeGroupInverted[event];
	if typeGroup and TextToSpeechFrame_GetChatTypeEnabled("CHAT_MSG_" .. typeGroup) then
		return true;
	end
end

function TextToSpeechFrame_MessageEventHandler(frame, event, ...)
	if ( not GetCVarBool("textToSpeech") ) then
		return;
	end

	if ( not frame.addMessageObserver ) then
		frame.addMessageObserver = TextToSpeechFrame_AddMessageObserver;
	end

	if TextToSpeechFrame_IsEventNarrationEnabled(event, ...) then
		local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18 = ...;
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
			elseif ( type == "WHISPER_INFORM" ) then
				message = CHAT_WHISPER_INFORM_GET:format(name) .. message;
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