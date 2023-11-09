local playbackActive = false;
local queuedMessages = {};
local queuedMessageTimer = nil;

local DefaultLegacySettings =  {
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
		["CHAT_MSG_PING"] = true,
	},
	enabledChannelTypes = {},
};

StaticPopupDialogs["TTS_CONFIRM_SAVE_SETTINGS"] = {
	text = TTS_CONFIRM_SAVE_SETTINGS,
	button1 = YES,
	button2 = CANCEL,
	OnAccept = function()
		TextToSpeechFrame_LoadLegacySettings();
		TextToSpeechFrame_Update(TextToSpeechFrame);
	end,
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

function TextToSpeech_GetSelectedVoice(voiceType)
	local voices = C_VoiceChat.GetTtsVoices();
	local voiceID = C_TTSSettings.GetVoiceOptionID(voiceType);
	local _, voice = FindVoiceByID(voices, voiceID);

	-- Default to voice 1 if settings are invalid.
	if not voice and #voices > 0 then
		voice = voices[1];
	end

	return voice;
end

function TextToSpeech_IsSelectedVoice(voice, voiceType)
	if voice then
		local selectedVoice = TextToSpeech_GetSelectedVoice(voiceType);
		if selectedVoice then
			return selectedVoice.voiceID == voice.voiceID;
		end
	end

	return false;
end

function TextToSpeech_SetSelectedVoice(voice, voiceType)
	C_TTSSettings.SetVoiceOption(voiceType, voice.voiceID);
end

function TextToSpeech_PlaySample(voiceType)
	TextToSpeech_Speak(TEXT_TO_SPEECH_SAMPLE_TEXT, TextToSpeech_GetSelectedVoice(voiceType));
end

local PLACEHOLDER_CURRENCY = 42;
local currencyReplacements = {
	[  GOLD_AMOUNT_TEXTURE:format(PLACEHOLDER_CURRENCY,0,0)] = GOLD_AMOUNT,
	[SILVER_AMOUNT_TEXTURE:format(PLACEHOLDER_CURRENCY,0,0)] = SILVER_AMOUNT,
	[COPPER_AMOUNT_TEXTURE:format(PLACEHOLDER_CURRENCY,0,0)] = COPPER_AMOUNT,
};

local function literalize(str)
	return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%0");
end

function TextToSpeech_StartPlayNextQueuedMessageTimer()
	if not queuedMessageTimer then
		queuedMessageTimer = C_Timer.NewTicker(1, function()
			if UIParent:IsShown() then
				TextToSpeech_PlayNextQueuedMessage();
			end
		end);
	end
end

function TextToSpeech_PlayNextQueuedMessage()
	if queuedMessageTimer then
		queuedMessageTimer:Cancel();
		queuedMessageTimer = nil;
	end
	if #queuedMessages > 0 then
		local queuedMessage = table.remove(queuedMessages, 1);

		-- Add short delay for message sound if enabled, otherwise play next immediately
		if ( C_TTSSettings.GetSetting(Enum.TtsBoolSetting.PlaySoundSeparatingChatLineBreaks) ) then
			playbackActive = true;
			C_Timer.After(1, function()
				playbackActive = false;
				TextToSpeech_Speak(queuedMessage.text, queuedMessage.voice);
			end);
		else
			TextToSpeech_Speak(queuedMessage.text, queuedMessage.voice);
		end
	end
end

function TextToSpeech_Speak(text, voice)
	-- Queue messages
	local uiHidden = not UIParent:IsShown();
	local shouldQueue = playbackActive or uiHidden;
	if shouldQueue then
		table.insert(queuedMessages, {text=text, voice=voice});

		if uiHidden then
			TextToSpeech_StartPlayNextQueuedMessageTimer();
		end

		return;
	end

	if text:match("|T") then
		for textureFormat, stringFormat in pairs(currencyReplacements) do
			local replaceTexture = textureFormat:gsub(PLACEHOLDER_CURRENCY, "");
			local replaceString = stringFormat:format(PLACEHOLDER_CURRENCY):gsub(PLACEHOLDER_CURRENCY, "");

			-- Escape the dash used in texture path
			replaceTexture = literalize(replaceTexture);

			text = text:gsub(replaceTexture, replaceString);
		end
	end

	playbackActive = true;
	C_VoiceChat.SpeakText(
		voice.voiceID,
		text,
		Enum.VoiceTtsDestination.QueuedLocalPlayback,
		C_TTSSettings.GetSpeechRate(),
		C_TTSSettings.GetSpeechVolume()
	);
end

-- [[ TextToSpeechFrame ]] --

function TextToSpeechFrame_Show()
	TextToSpeechFrame:SetShown(not TextToSpeechFrame:IsShown());
end

function TextToSpeechFrame_Update(self)
	-- Update checkboxes
	local checkBoxParent = TextToSpeechFramePanelContainer

	checkBoxParent.PlaySoundSeparatingChatLinesCheckButton:SetChecked(C_TTSSettings.GetSetting(Enum.TtsBoolSetting.PlaySoundSeparatingChatLineBreaks));
	checkBoxParent.AddCharacterNameToSpeechCheckButton:SetChecked(C_TTSSettings.GetSetting(Enum.TtsBoolSetting.AddCharacterNameToSpeech));
	checkBoxParent.PlayActivitySoundWhenNotFocusedCheckButton:SetChecked(C_TTSSettings.GetSetting(Enum.TtsBoolSetting.PlayActivitySoundWhenNotFocused));
	checkBoxParent.NarrateMyMessagesCheckButton:SetChecked(C_TTSSettings.GetSetting(Enum.TtsBoolSetting.NarrateMyMessages));
	checkBoxParent.UseAlternateVoiceForSystemMessagesCheckButton:SetChecked(C_TTSSettings.GetSetting(Enum.TtsBoolSetting.AlternateSystemVoice));

	if ChatConfigTextToSpeechMessageSettingsChatTypeContainer then
		TextToSpeechFrame_UpdateMessageCheckboxes(ChatConfigTextToSpeechMessageSettingsChatTypeContainer);
	end

	-- Update dropdown
	TextToSpeechFrameTtsVoiceDropdown_RefreshValue(TextToSpeechFrameTtsVoiceDropdown);

	TextToSpeechFrame_UpdateAlternate();

	TextToSpeechFrame_UpdateSliders();

	ChatConfigTextToSpeechChannelSettings_UpdateCheckboxes();
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
	local systemEnabled = TextToSpeechFrame_GetChatTypeEnabled("SYSTEM");
	local color = systemEnabled and WHITE_FONT_COLOR or GRAY_FONT_COLOR;
	TextToSpeechFramePanelContainer.UseAlternateVoiceForSystemMessagesCheckButton:SetEnabled(systemEnabled);
	TextToSpeechFramePanelContainer.UseAlternateVoiceForSystemMessagesCheckButton.text:SetTextColor(color:GetRGB());

	local enabled = systemEnabled and C_TTSSettings.GetSetting(Enum.TtsBoolSetting.AlternateSystemVoice);
	UIDropDownMenu_SetDropDownEnabled(TextToSpeechFrameTtsVoiceAlternateDropdown, enabled);
	TextToSpeechFramePlaySampleAlternateButton:SetEnabled(enabled);
end

function TextToSpeechFrame_UpdateSliders()
	TextToSpeechFrameAdjustRateSlider:SetValue(C_TTSSettings.GetSpeechRate());
	TextToSpeechFrameAdjustVolumeSlider:SetValue(C_TTSSettings.GetSpeechVolume());
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

-- Settings moved from Lua to C++ in 9.1.5 - this ports old setting data to the new API
function TextToSpeechFrame_LoadLegacySettings()
	if not TEXTTOSPEECH_CONFIG then
		return;
	end

	-- Need to save into character-specific settings
	local wasCharacterSpecific = GetCVarBool("TTSUseCharacterSettings");
	SetCVar("TTSUseCharacterSettings", true);

	C_TTSSettings.SetDefaultSettings();

	local activitySoundVal = TEXTTOSPEECH_CONFIG.playActivitySoundWhenNotFocused or false;
	C_TTSSettings.SetSetting(Enum.TtsBoolSetting.PlayActivitySoundWhenNotFocused, activitySoundVal);

	local alternateVoiceVal = TEXTTOSPEECH_CONFIG.alternateSystemVoice or false;
	C_TTSSettings.SetSetting(Enum.TtsBoolSetting.AlternateSystemVoice, alternateVoiceVal);

	local addCharacterNameVal = TEXTTOSPEECH_CONFIG.addCharacterNameToSpeech or false;
	C_TTSSettings.SetSetting(Enum.TtsBoolSetting.AddCharacterNameToSpeech, addCharacterNameVal);

	local narrateMyMessagesVal = TEXTTOSPEECH_CONFIG.narrateMyMessages or false;
	C_TTSSettings.SetSetting(Enum.TtsBoolSetting.NarrateMyMessages, narrateMyMessagesVal);

	local separatingSoundVal = TEXTTOSPEECH_CONFIG.playSoundSeparatingChatLineBreaks or false;
	C_TTSSettings.SetSetting(Enum.TtsBoolSetting.PlaySoundSeparatingChatLineBreaks, separatingSoundVal);

	local selectedVoiceStandard = TEXTTOSPEECH_CONFIG.ttsVoiceOptionStandard or TEXTTOSPEECH_CONFIG.ttsVoiceOptionStandardDefault or 0;
	-- Voice selection was stored as either a string or an ID
	local standardType = Enum.TtsVoiceType.Standard;
	if type(selectedVoiceStandard == string) then
		C_TTSSettings.SetVoiceOptionName(standardType, selectedVoiceStandard);
	else
		C_TTSSettings.SetVoiceOption(standardType, selectedVoiceStandard);
	end

	local alternateType = Enum.TtsVoiceType.Alternate;
	local selectedVoiceAlternate = TEXTTOSPEECH_CONFIG.ttsVoiceOptionAlternate or TEXTTOSPEECH_CONFIG.ttsVoiceOptionAlternateDefault or 1;
	if type(selectedVoiceAlternate == string) then
		C_TTSSettings.SetVoiceOptionName(alternateType, selectedVoiceAlternate);
	else
		C_TTSSettings.SetVoiceOption(alternateType, selectedVoiceAlternate);
	end
	local speechRate = TEXTTOSPEECH_CONFIG.speechRate or 0;
	C_TTSSettings.SetSpeechRate(speechRate);

	local speechVolume = TEXTTOSPEECH_CONFIG.speechVolume or 100;
	C_TTSSettings.SetSpeechVolume(speechVolume);

	for _, chatType in ipairs(TEXT_TO_SPEECH_CHAT_TYPES) do
		local chatTypeEnabled = TEXTTOSPEECH_CONFIG.enabledChatTypes and TEXTTOSPEECH_CONFIG.enabledChatTypes["CHAT_MSG_"..chatType];
		C_TTSSettings.SetChatTypeEnabled(chatType, chatTypeEnabled);
	end

	if TEXTTOSPEECH_CONFIG.enabledChannelTypes then
		for channelKey, channelEnabled in pairs(TEXTTOSPEECH_CONFIG.enabledChannelTypes) do
			if channelEnabled then
				C_TTSSettings.SetChannelKeyEnabled(channelKey, channelEnabled);
			end
		end
	end

	SetCVar("TTSUseCharacterSettings", wasCharacterSpecific);
end

function TextToSpeechFrame_OnLoad(self)
	self.loaded = false;
	self.loadedEvents = {};
	FrameUtil.RegisterFrameForEvents(self, loadEvents);

	self:RegisterEvent("VOICE_CHAT_TTS_PLAYBACK_FAILED");
	self:RegisterEvent("VOICE_CHAT_TTS_PLAYBACK_FINISHED");
end

function TextToSpeechFrame_CheckLoad(self)
	if not self.loaded and IsReadyToLoad(self.loadedEvents) then
		self.loaded = true;
		C_VoiceChat.GetTtsVoices();

		TextToSpeechFrameTtsVoiceDropdown_OnLoad(self.PanelContainer.TtsVoiceDropdown);
		TextToSpeechFrameTtsVoiceAlternateDropdown_OnLoad(self.PanelContainer.TtsVoiceAlternateDropdown);
		TextToSpeechFrame_CreateCheckboxes(ChatConfigTextToSpeechMessageSettingsChatTypeContainer, TEXT_TO_SPEECH_CHAT_TYPES, "TextToSpeechChatTypeCheckButtonTemplate");

		local maxSettingsDepth = 2;
		if TEXTTOSPEECH_CONFIG and not tCompare(TEXTTOSPEECH_CONFIG, DefaultLegacySettings, maxSettingsDepth) then
			if not C_TTSSettings.GetCharacterSettingsSaved() then
				TextToSpeechFrame_LoadLegacySettings();
			else
				StaticPopup_Show("TTS_CONFIRM_SAVE_SETTINGS");
			end
		end
		C_TTSSettings.MarkCharacterSettingsSaved();

		TextToSpeechFrame_Update(self);
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

		if ( C_TTSSettings.GetSetting(Enum.TtsBoolSetting.PlaySoundSeparatingChatLineBreaks) ) then
			PlaySound(SOUNDKIT.UI_VOICECHAT_TTSMESSAGE);
		end

		TextToSpeech_PlayNextQueuedMessage();
	else
		self.loadedEvents[event] = true;
	end

	TextToSpeechFrame_CheckLoad(self);
end

function TextToSpeechFrame_OnShow(self)
	TextToSpeechFrame_Update(self);
end

function TextToSpeechFrame_SetToDefaults()
	C_TTSSettings.SetDefaultSettings();

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
	C_TTSSettings.SetSetting(Enum.TtsBoolSetting.PlaySoundSeparatingChatLineBreaks, self:GetChecked());
end

function AddCharacterNameToSpeechCheckButton_OnLoad(self)
	self.text:SetText(TEXT_TO_SPEECH_ADD_CHARACTER_NAME);
end

function AddCharacterNameToSpeechCheckButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	C_TTSSettings.SetSetting(Enum.TtsBoolSetting.AddCharacterNameToSpeech, self:GetChecked());
end

function PlayActivitySoundWhenNotFocusedCheckButton_OnLoad(self)
	self.text:SetText(TEXT_TO_SPEECH_PLAY_ACTIVITY_SOUND);
end

function PlayActivitySoundWhenNotFocusedCheckButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	C_TTSSettings.SetSetting(Enum.TtsBoolSetting.PlayActivitySoundWhenNotFocused, self:GetChecked());
end

function NarrateMyMessagesCheckButton_OnLoad(self)
	self.text:SetText(TEXT_TO_SPEECH_NARRATE_MY_MESSAGES);
end

function NarrateMyMessagesCheckButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	C_TTSSettings.SetSetting(Enum.TtsBoolSetting.NarrateMyMessages, self:GetChecked());
end

local channelsWithTtsName =
{
	LOOT = true,
	MONEY = true,
};

function TextToSpeechFrame_CreateCheckboxes(frame, checkBoxTable, checkBoxTemplate)
	local checkBoxNameString = frame:GetName().."CheckBox";
	local checkBoxName, checkBox;
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
		if ( index == secondColIndex ) then
			checkBox:SetPoint("TOP", frame, "TOP", 8, -8);
			checkBox:SetPoint("LEFT", frame, "CENTER", 0, 0);
		elseif ( index > 1 ) then
			checkBox:SetPoint("TOPLEFT", checkBoxNameString..(index-1), "BOTTOMLEFT", 0, 4);
		else
			checkBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -8);
		end
		checkBox.type = value;
		checkBox:SetChecked(TextToSpeechFrame_GetChatTypeEnabled(value));
		checkBoxFontString = checkBox.text;
		checkBoxFontString:SetText((channelsWithTtsName[value] and _G[value.."_TTS_LABEL"] or _G[value]) or value);
		local r, g, b = GetMessageTypeColor(value);
		checkBoxFontString:SetVertexColor(r, g, b);
		checkBoxFontString:SetMaxLines(1);
	end
end

function TextToSpeechChatTypeCheckButton_OnClick(self, button)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	TextToSpeechFrame_SetChatTypeEnabled(self.type, self:GetChecked());

	if self.type == "SYSTEM" then
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
	local voice = TextToSpeech_GetSelectedVoice(Enum.TtsVoiceType.Standard);
	if voice then
		UIDropDownMenu_SetText(self, FormatVoiceText(voice));
	end
end

function TextToSpeechFrameTtsVoiceDropdown_SetSelectedVoice(self, voice)
	TextToSpeech_SetSelectedVoice(voice, Enum.TtsVoiceType.Standard);
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
	local voice = TextToSpeech_GetSelectedVoice(Enum.TtsVoiceType.Alternate);
	if voice then
		UIDropDownMenu_SetText(self, FormatVoiceText(voice));
	end
end

function TextToSpeechFrameTtsVoiceAlternateDropdown_SetSelectedVoice(self, voice)
	TextToSpeech_SetSelectedVoice(voice, Enum.TtsVoiceType.Alternate);
	TextToSpeechFrameTtsVoiceAlternateDropdown_RefreshValue(self);
end

function TextToSpeechFrameTtsVoicePicker_OnLoad(self)
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("TextToSpeechVoicePickerButtonTemplate", function(button, voice)
		local checked = TextToSpeech_IsSelectedVoice(voice, Enum.TtsVoiceType.Standard);
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
	view:SetElementInitializer("TextToSpeechVoicePickerButtonTemplate", function(button, voice)
		local checked = TextToSpeech_IsSelectedVoice(voice, Enum.TtsVoiceType.Alternate);
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
	self.ScrollBox:SetPoint("BOTTOMRIGHT", (scrollBarShown and -20 or 0), 0);
	self.ScrollBox:SetDataProvider(dataProvider);
end

function TextToSpeechFramePlaySampleButton_OnClick(self)
	TextToSpeech_PlaySample(Enum.TtsVoiceType.Standard);
end

function TextToSpeechFramePlaySampleAlternateButton_OnClick(self)
	TextToSpeech_PlaySample(Enum.TtsVoiceType.Alternate);
end

function UseAlternateVoiceForSystemMessagesCheckButton_OnLoad(self)
	self.text:SetText(TEXT_TO_SPEECH_ALTERNATE_SYSTEM_VOICE);
end

function UseAlternateVoiceForSystemMessagesCheckButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	C_TTSSettings.SetSetting(Enum.TtsBoolSetting.AlternateSystemVoice, self:GetChecked());
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
	self:SetValue(C_TTSSettings.GetSpeechRate());
end

function TextToSpeechFrameAdjustRateSlider_OnValueChanged(self, value)
	C_TTSSettings.SetSpeechRate(value);
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
	self:SetValue(C_TTSSettings.GetSpeechVolume());
end

function TextToSpeechFrameAdjustVolumeSlider_OnValueChanged(self, value)
	C_TTSSettings.SetSpeechVolume(value);
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

local lastMessage = nil;
local lastMessageTime = nil;

local function IsMessageTypeEnabled(messageType)
	if messageType == "CHANNEL" or messageType == "COMMUNITIES_CHANNEL" then
		return true; -- These are always enabled, if we make it this far then the other filters passed.
	end

	if TextToSpeechFrame_GetChatTypeEnabled(messageType) then
		return true;
	end

	local typeGroup = ChatTypeGroupInverted[messageType];
	if typeGroup and TextToSpeechFrame_GetChatTypeEnabled(typeGroup) then
		return true;
	end

	return false;
end

function TextToSpeechFrame_PlayMessage(frame, message, id, ignoreTypeFilters, ignoreActivitySound)
	local type = nil;

	if id then
		type = C_ChatInfo.GetChatTypeName(id);
	end

	-- Any messages missing a type are treated as SYSTEM messages.
	if ( not type ) then
		type = "SYSTEM";
	end

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

	local voice = TextToSpeech_GetSelectedVoice(Enum.TtsVoiceType.Standard);
	if type == "SYSTEM" and C_TTSSettings.GetSetting(Enum.TtsBoolSetting.AlternateSystemVoice) then
		local alternateVoice = TextToSpeech_GetSelectedVoice(Enum.TtsVoiceType.Alternate);
		if alternateVoice then
			voice = alternateVoice;
		end
	end

	if not voice then
		return;
	end

	if ( not ignoreActivitySound and C_TTSSettings.GetSetting(Enum.TtsBoolSetting.PlayActivitySoundWhenNotFocused) and not frame:IsShown() ) then
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
	RAID_BOSS_EMOTE = true, -- Some quests transform the player then use boss emotes sent from the (transformed) player
	LOOT = true,
	CURRENCY = true,
	MONEY = true,
}

local function IsMessageFromPlayer(msgType, msgSenderName)
	if msgType == "WHISPER_INFORM" or msgType == "BN_WHISPER_INFORM" then
		return true;
	end

	return not ignoredMsgTypes[msgType] and msgSenderName == UnitName("player");
end


function TextToSpeechFrame_SetChatTypeEnabled(msgType, enabled)
	if msgType then
		C_TTSSettings.SetChatTypeEnabled(msgType, enabled);
		return enabled;
	end
end

function TextToSpeechFrame_GetChatTypeEnabled(msgType)
	if msgType then
		return C_TTSSettings.GetChatTypeEnabled(msgType);
	end

	return false;
end

function TextToSpeechFrame_ToggleChatTypeEnabled(msgType)
	return TextToSpeechFrame_SetChatTypeEnabled(msgType, not TextToSpeechFrame_GetChatTypeEnabled(msgType));
end

function TextToSpeechFrame_SetChannelEnabled(channelInfo, enabled)
	if channelInfo then
		C_TTSSettings.SetChannelEnabled(channelInfo, enabled);
		return enabled;
	end
end

function TextToSpeechFrame_ToggleChannelEnabled(channelInfo)
	local newVal = not C_TTSSettings.GetChannelEnabled(channelInfo);
	return TextToSpeechFrame_SetChannelEnabled(channelInfo, newVal);
end

function TextToSpeechFrame_DisplaySilentSystemMessage(text)
	local wasEnabled = TextToSpeechFrame_GetChatTypeEnabled("SYSTEM");
	TextToSpeechFrame_SetChatTypeEnabled("SYSTEM", false);
	ChatFrame_DisplaySystemMessageInPrimary(text);
	TextToSpeechFrame_SetChatTypeEnabled("SYSTEM", wasEnabled);
end

function TextToSpeechFrame_IsEventNarrationEnabled(frame, event, ...)
	local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18 = ...;

	local chatType = strsub(event, 10);
	local chatGroup = Chat_GetChatCategory(chatType);
	local chatTarget = FCFManager_GetChatTarget and FCFManager_GetChatTarget(chatGroup, arg2, arg8) or false;

	if ( chatTarget and FCFManager_ShouldSuppressMessage(frame, chatGroup, chatTarget) ) then
		return false;
	end

	if TextToSpeechFrame_GetChatTypeEnabled(chatType) then
		return true;
	end

	if event == "CHAT_MSG_CHANNEL" or event == "CHAT_MSG_COMMUNITIES_CHANNEL" then
		local localID = tostring(arg8);
		local channelInfo = C_ChatInfo.GetChannelInfoFromIdentifier(localID);
		if not channelInfo then
			local channelName = arg9;
			channelInfo = C_ChatInfo.GetChannelInfoFromIdentifier(channelName);
		end

		if channelInfo then
			return C_TTSSettings.GetChannelEnabled(channelInfo);
		end
	end

	local typeGroup = ChatTypeGroupInverted[event];
	if typeGroup and TextToSpeechFrame_GetChatTypeEnabled(typeGroup) then
		return true;
	end

	return false;
end

local chatTypesWithTtsFormat = {
	YELL = true,
	WHISPER = true,
	BN_WHISPER = true,
	WHISPER_INFORM = true,
	BN_WHISPER_INFORM = true,
	MONSTER_YELL = true,
	MONSTER_WHISPER = true,
	EMOTE = true,
};

local chatTypesWithToken = {
	GUILD_ACHIEVEMENT = true,
	ACHIEVEMENT = true,
	MONSTER_EMOTE = true,
	RAID_BOSS_EMOTE = true,
	RAID_BOSS_WHISPER = true,
};

local chatTypesWithoutSays = {
	TEXT_EMOTE = true,
	LOOT = true,
	CURRENCY = true,
	MONEY = true,
};

function TextToSpeechFrame_MessageEventHandler(frame, event, ...)
	if ( not GetCVarBool("textToSpeech") ) then
		return;
	end

	if ( not frame.addMessageObserver ) then
		frame.addMessageObserver = TextToSpeechFrame_AddMessageObserver;
	end

	if TextToSpeechFrame_IsEventNarrationEnabled(frame, event, ...) then
		local message, arg2, _, _, _, _, _, _, _, languageID, lineID = ...;
		local name = Ambiguate(arg2 or "", "none");

		if ( languageID and C_TTSSettings.ShouldOverrideMessage(languageID, message) ) then
			message = UNKNOWN_LANG_TTS_MESSAGE;
		end

		local type = strsub(event, 10);
		if ( chatTypesWithToken[type] ) then
			-- These messages have a token for sender name that needs filled in.
			message = message:format(name);
		elseif ( not chatTypesWithoutSays[type] and C_TTSSettings.GetSetting(Enum.TtsBoolSetting.AddCharacterNameToSpeech) and name ~= "" ) then
			if not lineID or not C_ChatInfo.IsChatLineCensored(lineID) then
				-- Format messages as "<Player> says <message>" except for certain types.
				local formatType = "SAY";
				if ( chatTypesWithTtsFormat[type] ) then
					formatType = type;
				end
				message = _G["CHAT_" .. formatType .. "_GET"]:format(name) .. message;
			end
		end

		-- Check for chat text from the local player and skip it, unless the player wants their messages narrated
		local messageFromPlayer = IsMessageFromPlayer(type, name);
		if messageFromPlayer and not C_TTSSettings.GetSetting(Enum.TtsBoolSetting.NarrateMyMessages) then
			-- Ensure skipped by observer too
			lastMessage = message;
			lastMessageTime = GetTime();
			return;
		end

		local chatType = strsub(event, 10);
		local chatTypeInfo = ChatTypeInfo[chatType];
		if chatTypeInfo and chatTypeInfo.id then
			TextToSpeechFrame_PlayMessage(frame, message, chatTypeInfo.id, false, messageFromPlayer);
		end
	end
end
