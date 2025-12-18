TEXTTOSPEECH_RATE_MIN = -10;
TEXTTOSPEECH_RATE_MAX = 10;

TEXTTOSPEECH_VOLUME_MIN = 0;
TEXTTOSPEECH_VOLUME_MAX = 100;

local VALIDATE_RANGE_YES = true;

local TextToSpeechCommandsMixin = {};

function TextToSpeechCommandsMixin:Init()
	self.commands = {};
end

function TextToSpeechCommandsMixin:AddCommand(cmdName, callback, option, helpText, cmdNameNarrated, rangeMin, rangeMax, rangeFn, validateRange)
	cmdName = string.lower(cmdName);
	self.commands[cmdName] = {
		cmdName = cmdName,
		cmdNameNarrated = cmdNameNarrated or cmdName,
		callback = callback,
		option = option,
		helpText = helpText,
		rangeMin = rangeMin,
		rangeMax = rangeMax,
		rangeFn = rangeFn,
		validateRange = validateRange,
		GetCommands = function() return self; end,
	};
end

function TextToSpeechCommandsMixin:GetCommands()
	return self.commands;
end

function TextToSpeechCommandsMixin:GetCommand(cmdName)
	return cmdName and self.commands[cmdName];
end

function TextToSpeechCommandsMixin:GetArguments(msg)
	if msg then
		local arguments = { string.split(" ", string.lower(msg)) };
		return arguments[1], arguments[2] and table.concat(arguments, " ", 2) or "";
	end
end

local function GetCommandArgumentRange(cmd)
	if cmd.rangeFn then
		return cmd.rangeFn();
	end

	return cmd.rangeMin, cmd.rangeMax;
end

function TextToSpeechCommandsMixin:EvaluateTextToSpeechCommand(msg)
	local cmdName, arg1 = self:GetArguments(msg);
	local cmd = self:GetCommand(cmdName);
	if cmd then
		if cmd.validateRange then
			local rangeMin, rangeMax = GetCommandArgumentRange(cmd);
			local numericArg1 = tonumber(arg1);
			if not numericArg1 or numericArg1 < rangeMin or numericArg1 > rangeMax then
				return false;
			end
		end
		return cmd:callback(arg1);
	end

	return false;
end

function TextToSpeechCommandsMixin:ShowHelp(msg)
	local cmdName, arg1 = self:GetArguments(msg);
	if not self:ShowCommandHelp(self:GetCommand(cmdName)) then
		self:ShowUsage();
	end
end

local function GetNumericValueForNarration(value)
	if value >= 0 then
		return tostring(value);
	end

	return TEXTTOSPEECH_NEGATIVE_QUANTITY_FORMAT:format(math.abs(value));
end

function TextToSpeechCommandsMixin:GetCommandHelpText(cmd)
	if cmd and cmd.helpText then
		local rangeMin, rangeMax = GetCommandArgumentRange(cmd);
		if rangeMin and rangeMax then
			local displayText = cmd.helpText:format(rangeMin, rangeMax);
			local narratedText = cmd.helpText:format(GetNumericValueForNarration(rangeMin), GetNumericValueForNarration(rangeMax));
			return SLASH_TEXTTOSPEECH_HELP_FORMATSTRING_RANGE:format(cmd.cmdName, displayText), SLASH_TEXTTOSPEECH_HELP_FORMATSTRING_RANGE:format(cmd.cmdNameNarrated, narratedText);
		else
			return SLASH_TEXTTOSPEECH_HELP_FORMATSTRING:format(cmd.cmdName, cmd.helpText), SLASH_TEXTTOSPEECH_HELP_FORMATSTRING:format(cmd.cmdNameNarrated, cmd.helpText);
		end
	end
end

function TextToSpeechCommandsMixin:ShowCommandHelp(cmd)
	local displayText, narratedText = self:GetCommandHelpText(cmd);
	if displayText then
		self:SpeakConfirmation(displayText, narratedText);
		return true;
	end

	return false;
end

local function SortEntries(entry1, entry2)
	return strcmputf8i(entry1[1], entry2[1]) < 0;
end

function TextToSpeechCommandsMixin:SpeakConfirmationEntries(entries)
	table.sort(entries, SortEntries);

	for index, entry in ipairs(entries) do
		self:SpeakConfirmation(unpack(entry));
	end
end

function TextToSpeechCommandsMixin:SetHelpOverviewText(helpOverviewText, helpOverviewNarratedText)
	self.helpOverviewText = helpOverviewText;
	self.helpOverviewNarratedText = helpOverviewNarratedText;
end

function TextToSpeechCommandsMixin:ShowUsage()
	self:SpeakConfirmation(self.helpOverviewText, self.helpOverviewNarratedText);

	local usageEntries = {};
	for cmdName, cmd in pairs(self.commands) do
		local displayText, narratedText = self:GetCommandHelpText(cmd);
		if displayText then
			table.insert(usageEntries, { displayText, narratedText });
		end
	end

	self:SpeakConfirmationEntries(usageEntries);
end

local function GetOptionConfirmation(option, enabled)
	return (enabled and SLASH_TEXTTOSPEECH_CONFIRMATION_ENABLED or SLASH_TEXTTOSPEECH_CONFIRMATION_DISABLED):format(option);
end

function TextToSpeechCommandsMixin:PlayMessage(narratedText)
	local id = nil;
	local ignoreFilters = true;
	TextToSpeechFrame_PlayMessage(DEFAULT_CHAT_FRAME, narratedText, id, ignoreFilters);
end

function TextToSpeechCommandsMixin:SpeakConfirmation(displayText, narratedText, skipQueue)
	narratedText = narratedText or displayText;

	if skipQueue then
		self:PlayMessage(narratedText);
	else
		if self.queuedNarration then
			table.insert(self.queuedNarration, narratedText);
		else
			self.queuedNarration = { narratedText };
			C_Timer.After(0.25, function()
				self:PlayMessage(table.concat(self.queuedNarration, ". "));
				self.queuedNarration = nil;
			end);
		end
	end

	TextToSpeechFrame_DisplaySilentSystemMessage(displayText);
end

function TextToSpeechCommandsMixin:SpeakConfirmationSkipQueue(displayText, narratedText)
	self:SpeakConfirmation(displayText, narratedText, true);
end

TextToSpeechCommands = CreateAndInitFromMixin(TextToSpeechCommandsMixin);

local function TextToSpeech_CommandOptionHandler(cmd)
	local val = C_TTSSettings.GetSetting(cmd.option) or false;
	local newVal = not val;
	C_TTSSettings.SetSetting(cmd.option, newVal)
	cmd:GetCommands():SpeakConfirmation(GetOptionConfirmation(cmd.cmdName, newVal));
	return true;
end

local function TextToSpeech_ToggleTextToSpeechChat(cmd)
	cmd:GetCommands():SpeakConfirmation(GetOptionConfirmation(cmd.cmdName, TextToSpeechFrame_ToggleChatTypeEnabled(cmd.option)));
	return true;
end

TextToSpeechCommands:SetHelpOverviewText(TEXTTOSPEECH_HELP_OVERVIEW);

TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_PLAYLINE, TextToSpeech_CommandOptionHandler, Enum.TtsBoolSetting.PlaySoundSeparatingChatLineBreaks, SLASH_TEXTTOSPEECH_HELP_PLAYLINE);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_PLAYACTIVITY, TextToSpeech_CommandOptionHandler, Enum.TtsBoolSetting.PlayActivitySoundWhenNotFocused, SLASH_TEXTTOSPEECH_HELP_PLAYACTIVITY);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_SAYNAME, TextToSpeech_CommandOptionHandler, Enum.TtsBoolSetting.AddCharacterNameToSpeech, SLASH_TEXTTOSPEECH_HELP_SAYNAME);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_ALTSYSTEMVOICE, TextToSpeech_CommandOptionHandler, Enum.TtsBoolSetting.AlternateSystemVoice, SLASH_TEXTTOSPEECH_HELP_ALTSYSTEMVOICE);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_MYMESSAGES, TextToSpeech_CommandOptionHandler, Enum.TtsBoolSetting.NarrateMyMessages, SLASH_TEXTTOSPEECH_HELP_MYMESSAGES);

TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_CREATURE_SAY, TextToSpeech_ToggleTextToSpeechChat, "MONSTER_SAY", SLASH_TEXTTOSPEECH_HELP_CREATURE_SAY);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_CREATURE_YELL, TextToSpeech_ToggleTextToSpeechChat, "MONSTER_YELL", SLASH_TEXTTOSPEECH_HELP_CREATURE_YELL);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_CREATURE_WHISPER, TextToSpeech_ToggleTextToSpeechChat, "MONSTER_WHISPER", SLASH_TEXTTOSPEECH_HELP_CREATURE_WHISPER);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_CREATURE_EMOTE, TextToSpeech_ToggleTextToSpeechChat, "MONSTER_EMOTE", SLASH_TEXTTOSPEECH_HELP_CREATURE_EMOTE);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_BOSS_WHISPER, TextToSpeech_ToggleTextToSpeechChat, "RAID_BOSS_WHISPER", SLASH_TEXTTOSPEECH_HELP_BOSS_WHISPER);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_BOSS_EMOTE, TextToSpeech_ToggleTextToSpeechChat, "RAID_BOSS_EMOTE", SLASH_TEXTTOSPEECH_HELP_BOSS_EMOTE);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_SYSTEM, TextToSpeech_ToggleTextToSpeechChat, "SYSTEM", SLASH_TEXTTOSPEECH_HELP_SYSTEM);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_EMOTE, TextToSpeech_ToggleTextToSpeechChat, "EMOTE", SLASH_TEXTTOSPEECH_HELP_EMOTE);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_WHISPER, TextToSpeech_ToggleTextToSpeechChat, "WHISPER", SLASH_TEXTTOSPEECH_HELP_WHISPER);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_SAY, TextToSpeech_ToggleTextToSpeechChat, "SAY", SLASH_TEXTTOSPEECH_HELP_SAY);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_YELL, TextToSpeech_ToggleTextToSpeechChat, "YELL", SLASH_TEXTTOSPEECH_HELP_YELL);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_PARTYLEADER, TextToSpeech_ToggleTextToSpeechChat, "PARTY_LEADER", SLASH_TEXTTOSPEECH_HELP_PARTYLEADER);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_PARTY, TextToSpeech_ToggleTextToSpeechChat, "PARTY", SLASH_TEXTTOSPEECH_HELP_PARTY);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_GUILDLEADER, TextToSpeech_ToggleTextToSpeechChat, "OFFICER", SLASH_TEXTTOSPEECH_HELP_GUILDLEADER);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_GUILD, TextToSpeech_ToggleTextToSpeechChat, "GUILD", SLASH_TEXTTOSPEECH_HELP_GUILD);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_GUILD_ANNOUNCE, TextToSpeech_ToggleTextToSpeechChat, "GUILD_ACHIEVEMENT", SLASH_TEXTTOSPEECH_HELP_GUILD_ANNOUNCE); --TODO: SLASH_TEXTTOSPEECH_HELP_GUILD_ANNOUNCE does not exist in mainline global strings table
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_RAIDLEADER, TextToSpeech_ToggleTextToSpeechChat, "RAID_LEADER", SLASH_TEXTTOSPEECH_HELP_RAIDLEADER);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_RAID, TextToSpeech_ToggleTextToSpeechChat, "RAID", SLASH_TEXTTOSPEECH_HELP_RAID);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_RAID_WARNING, TextToSpeech_ToggleTextToSpeechChat, "RAID_WARNING", SLASH_TEXTTOSPEECH_HELP_RAID_WARNING);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_INSTANCELEADER, TextToSpeech_ToggleTextToSpeechChat, "INSTANCE_CHAT_LEADER", SLASH_TEXTTOSPEECH_HELP_INSTANCELEADER);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_INSTANCE, TextToSpeech_ToggleTextToSpeechChat, "INSTANCE_CHAT", SLASH_TEXTTOSPEECH_HELP_INSTANCE);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_BLIZZARD, TextToSpeech_ToggleTextToSpeechChat, "BN_WHISPER", SLASH_TEXTTOSPEECH_HELP_BLIZZARD);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_ACHIEVEMENT, TextToSpeech_ToggleTextToSpeechChat, "ACHIEVEMENT", SLASH_TEXTTOSPEECH_HELP_ACHIEVEMENT);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_LOOT, TextToSpeech_ToggleTextToSpeechChat, "LOOT", SLASH_TEXTTOSPEECH_HELP_LOOT);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_CURRENCY, TextToSpeech_ToggleTextToSpeechChat, "CURRENCY", SLASH_TEXTTOSPEECH_HELP_CURRENCY);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_MONEY, TextToSpeech_ToggleTextToSpeechChat, "MONEY", SLASH_TEXTTOSPEECH_HELP_MONEY);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_PING, TextToSpeech_ToggleTextToSpeechChat, "PING", SLASH_TEXTTOSPEECH_HELP_PING);

do
	local SLASH_TEXTTOSPEECH_TOGGLE = "";
	TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_TOGGLE,
		function(cmd)
			local val = GetCVarBool("textToSpeech");
			local newVal = not val;
			SetCVar("textToSpeech", newVal);
			cmd:GetCommands():SpeakConfirmation(GetOptionConfirmation(TEXT_TO_SPEECH, newVal));
			return true;
		end
	);
end

TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_CHANNEL,
	function(cmd, channelIdentifier)
		local info = ChatFrameUtil.GetFullChannelInfo(channelIdentifier);
		if info then
			local enabled = TextToSpeechFrame_ToggleChannelEnabled(info);
			cmd:GetCommands():SpeakConfirmation(GetOptionConfirmation(info.humanReadableName or info.name, enabled));
			return true;
		end

		return false;
	end,
	nil,
	SLASH_TEXTTOSPEECH_HELP_CHANNEL
);

TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_MENU,
	function(cmd)
		if ToggleTextToSpeechFrame() then
			cmd:GetCommands():ShowHelp();
		end
		return true;
	end
);

local function HelpCommandFunc(cmd, optCmdName)
	local commands = cmd:GetCommands();
	if optCmdName and optCmdName ~= "" then
		local optCmd = commands:GetCommand(optCmdName);
		if optCmd then
			commands:ShowCommandHelp(optCmd);
			return true;
		end
	end

	commands:ShowUsage();
	return true;
end

TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_HELP,
	HelpCommandFunc,
	nil,
	SLASH_TEXTTOSPEECH_HELP_HELP
);

local voices = C_VoiceChat.GetTtsVoices();
local minVoiceID = math.huge;
local maxVoiceID = -math.huge;
for index, voice in pairs(voices) do
	if voice.voiceID < minVoiceID then
		minVoiceID = voice.voiceID;
	end

	if voice.voiceID > maxVoiceID then
		maxVoiceID = voice.voiceID;
	end
end

local function GetVoiceRange()
	return minVoiceID, maxVoiceID;
end

do
	local function AddVoiceChatCommand(cmdName, helpText, confirmationText, voiceType)
		TextToSpeechCommands:AddCommand(cmdName,
			function(cmd, newVoice)
				local voice = TextToSpeech_SetVoice(newVoice, voiceType);
				if voice then
					cmd:GetCommands():SpeakConfirmation(confirmationText:format(voice.name));
					return true;
				end

				return false;
			end, nil, helpText, nil, nil, nil, GetVoiceRange
		);
	end

	AddVoiceChatCommand(SLASH_TEXTTOSPEECH_VOICE, SLASH_TEXTTOSPEECH_HELP_VOICE, SLASH_TEXTTOSPEECH_VOICE_CHANGED_CONFIRMATION, Enum.TtsVoiceType.Standard);
	AddVoiceChatCommand(SLASH_TEXTTOSPEECH_ALTVOICE, SLASH_TEXTTOSPEECH_HELP_ALTVOICE, SLASH_TEXTTOSPEECH_ALTVOICE_CHANGED_CONFIRMATION, Enum.TtsVoiceType.Alternate);
end

TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_DEFAULT,
	function (cmd)
		TextToSpeechFrame_SetToDefaults();
		cmd:GetCommands():SpeakConfirmation(SLASH_TEXTTOSPEECH_CONFIRMATION_RESET);
		return true;
	end, nil, SLASH_TEXTTOSPEECH_HELP_DEFAULT
);

TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_SAMPLE,
	function(cmd)
		TextToSpeech_PlaySample(Enum.TtsVoiceType.Standard);
		return true;
	end, nil, SLASH_TEXTTOSPEECH_HELP_SAMPLE
);

TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_ALTSAMPLE,
	function(cmd)
		TextToSpeech_PlaySample(Enum.TtsVoiceType.Alternate);
		return true;
	end, nil, SLASH_TEXTTOSPEECH_HELP_ALTSAMPLE
);

TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_STOP,
	function(cmd)
		TextToSpeech_StopAll();
		return true;
	end, nil, SLASH_TEXTTOSPEECH_HELP_STOP
);

do
	local function DisplaySelectedVoice(commands, voiceType, displayText)
		local voice = TextToSpeech_GetSelectedVoice(voiceType);
		if voice then
			commands:SpeakConfirmation(displayText:format(voice.name));
		end
	end

	TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_SETTINGS,
		function(cmd)
			local commands = cmd:GetCommands();
			commands:SpeakConfirmation(GetOptionConfirmation(TEXT_TO_SPEECH, GetCVarBool("textToSpeech")));
			commands:SpeakConfirmation(SLASH_TEXTTOSPEECH_CONFIRMATION:format(TEXT_TO_SPEECH_ADJUST_VOLUME, C_ChatInfo.GetTTSSpeechVolume));
			commands:SpeakConfirmation(SLASH_TEXTTOSPEECH_CONFIRMATION:format(TEXT_TO_SPEECH_ADJUST_RATE, C_ChatInfo.GetTTSSpeechRate));

			DisplaySelectedVoice(commands, "standard", SLASH_TEXTTOSPEECH_VOICE_CHANGED_CONFIRMATION);
			DisplaySelectedVoice(commands, "alternate", SLASH_TEXTTOSPEECH_ALTVOICE_CHANGED_CONFIRMATION);

			local entries = {};
			local individualCommands = commands:GetCommands();
			for cmdName, cmdInfo in pairs(individualCommands) do
				local value = type(cmdInfo.cmdType) == "string" and TextToSpeechFrame_GetChatTypeEnabled(cmdInfo.option) or C_TTSSettings.GetSetting(cmdInfo.option);
				if value then
					table.insert(entries, { GetOptionConfirmation(cmdName, value) });
				end
			end

			commands:SpeakConfirmationEntries(entries);

			return true;
		end, nil, SLASH_TEXTTOSPEECH_HELP_SETTINGS
	);
end

CAACommands = CreateAndInitFromMixin(TextToSpeechCommandsMixin);

CAACommands:SetHelpOverviewText(CAA_HELP_OVERVIEW, CAA_HELP_OVERVIEW_NARRATED);

CAACommands:AddCommand(SLASH_CAA_HELP,
	HelpCommandFunc,
	nil,
	SLASH_CAA_HELP_HELP
);

local function GetCAAOptionConfirmation(option, enabled, includeHelp)
	if enabled then
		if includeHelp then
			return SLASH_CAA_CONFIRMATION_ENABLED_WITH_HELP:format(option), SLASH_CAA_CONFIRMATION_ENABLED_WITH_HELP_NARRATED:format(option);
		else
			return SLASH_CAA_CONFIRMATION_ENABLED:format(option);
		end
	else
		return SLASH_CAA_CONFIRMATION_DISABLED:format(option);
	end
end

local function CAA_ToggleBoolSetting(cmd)
	local val = GetCVarBool(cmd.option);
	local newVal = not val;
	SetCVar(cmd.option, newVal);
	cmd:GetCommands():SpeakConfirmation(GetCAAOptionConfirmation(cmd.confirmationName, newVal, cmd.includeHelpInConfirmation));
	return true;
end

local function CAA_AddBoolCommand(cmdName, cvarName, helpText, cmdNameNarrated, confirmationName, includeHelpInConfirmation)
	CAACommands:AddCommand(cmdName, CAA_ToggleBoolSetting, cvarName, helpText, cmdNameNarrated);
	local cmd = CAACommands:GetCommand(cmdName);
	cmd.confirmationName = confirmationName;
	cmd.includeHelpInConfirmation = includeHelpInConfirmation;
end

do
	local SLASH_CAA_TOGGLE = "";
	local includeHelpInConfirmationYes = true;
	CAA_AddBoolCommand(SLASH_CAA_TOGGLE, "CAAEnabled", nil, nil, COMBAT_AUDIO_ALERTS, includeHelpInConfirmationYes);
end

CAA_AddBoolCommand(SLASH_CAA_SAY_TARGET_NAME, "CAASayTargetName", SLASH_CAA_HELP_SAY_TARGET_NAME, SLASH_CAA_SAY_TARGET_NAME_NARRATED, CAA_SAY_TARGET_NAME_LABEL);
CAA_AddBoolCommand(SLASH_CAA_SAY_COMBAT_START, "CAASayCombatStart", SLASH_CAA_HELP_SAY_COMBAT_START, SLASH_CAA_SAY_COMBAT_START_NARRATED, CAA_SAY_COMBAT_START_LABEL);
CAA_AddBoolCommand(SLASH_CAA_SAY_COMBAT_END, "CAASayCombatEnd", SLASH_CAA_HELP_SAY_COMBAT_END,SLASH_CAA_SAY_COMBAT_END_NARRATED, CAA_SAY_COMBAT_END_LABEL);
CAA_AddBoolCommand(SLASH_CAA_SAY_TARGET_CASTS_INTERRUPT, "CAAInterruptCast", SLASH_CAA_HELP_SAY_TARGET_CASTS_INTERRUPT, SLASH_CAA_SAY_TARGET_CASTS_INTERRUPT_NARRATED, CAA_SAY_TARGET_CASTS_INTERRUPT_LABEL);
CAA_AddBoolCommand(SLASH_CAA_SAY_TARGET_CASTS_INTERRUPT_SUCCESS, "CAAInterruptCastSuccess", SLASH_CAA_HELP_SAY_TARGET_CASTS_INTERRUPT_SUCCESS, SLASH_CAA_SAY_TARGET_CASTS_INTERRUPT_SUCCESS_NARRATED, CAA_SAY_TARGET_CASTS_INTERRUPT_SUCCESS_LABEL);

do
	local function GetVoiceName(voiceID)
		for index, voice in pairs(voices) do
			if voice.voiceID == voiceID then
				return voice.name;
			end
		end
	end

	local function TrySetCAAVoice(cmd, newVoiceID, confirmationText)
		local voiceName = GetVoiceName(newVoiceID);
		if voiceName then
			cmd:GetCommands():SpeakConfirmationSkipQueue(confirmationText:format(voiceName));
			CombatAudioAlertManager:SetSpeakerVoice(newVoiceID);
			return true;
		end

		return false;
	end

	local function AddCAAVoiceCommand(cmdName, helpText, confirmationText)
		CAACommands:AddCommand(cmdName,
			function(cmd, newVoiceID)
				newVoiceID = (newVoiceID and newVoiceID ~= "") and tonumber(newVoiceID);
				if newVoiceID then
					return TrySetCAAVoice(cmd, newVoiceID, confirmationText);
				else
					local currentVoiceID = tonumber(GetCVar("CAAVoice"));
					newVoiceID = currentVoiceID + 1;
					if newVoiceID > maxVoiceID then
						newVoiceID = minVoiceID;
					end
					return TrySetCAAVoice(cmd, newVoiceID, confirmationText);
				end
			end, nil, helpText, nil, nil, nil, GetVoiceRange, VALIDATE_RANGE_YES
		);
	end

	AddCAAVoiceCommand(SLASH_CAA_VOICE, SLASH_CAA_HELP_VOICE, SLASH_CAA_VOICE_CHANGED_CONFIRMATION);
end

do
	local function CAA_SetSpeedHandler(cmd, newVal)
		cmd:GetCommands():SpeakConfirmationSkipQueue(SLASH_CAA_CONFIRMATION:format(CAA_SPEAKER_SPEED_LABEL, newVal));
		CombatAudioAlertManager:SetSpeakerSpeed(newVal);
		return true;
	end

	CAACommands:AddCommand(SLASH_CAA_SPEED, CAA_SetSpeedHandler, nil, SLASH_CAA_HELP_SPEED, nil, Constants.TTSConstants.TTSRateMin, Constants.TTSConstants.TTSRateMax, nil, VALIDATE_RANGE_YES);
end

do
	local function CAA_SetVolumeHandler(cmd, newVal)
		cmd:GetCommands():SpeakConfirmationSkipQueue(SLASH_CAA_CONFIRMATION:format(CAA_SPEAKER_VOLUME_LABEL, newVal));
		CombatAudioAlertManager:SetSpeakerVolume(newVal);
		return true;
	end

	CAACommands:AddCommand(SLASH_CAA_VOLUME, CAA_SetVolumeHandler, nil, SLASH_CAA_HELP_VOLUME, nil, Constants.TTSConstants.TTSVolumeMin, Constants.TTSConstants.TTSVolumeMax, nil, VALIDATE_RANGE_YES);
end

local PERCENT_MIN = Enum.CombatAudioAlertPercentValuesMeta.MinValue;
local PERCENT_MAX = Enum.CombatAudioAlertPercentValuesMeta.MaxValue;
local THROTTLE_MIN = Constants.CAAConstants.CAAThrottleMin;
local THROTTLE_MAX = Constants.CAAConstants.CAAThrottleMax;
local SAY_CASTS_MIN = Enum.CombatAudioAlertCastStateMeta.MinValue;
local SAY_CASTS_MAX = Enum.CombatAudioAlertCastStateMeta.MaxValue;
local CAST_TIME_MIN = Constants.CAAConstants.CAAMinCastTimeMin;
local CAST_TIME_MAX = Constants.CAAConstants.CAAMinCastTimeMax;
local RESOURCE_FORMAT_MIN = Enum.CombatAudioAlertPlayerResourceFormatValuesMeta.MinValue;
local RESOURCE_FORMAT_MAX = Enum.CombatAudioAlertPlayerResourceFormatValuesMeta.MaxValue;
local EXAMPLE_PERCENT = 20;

local function GetInitialSuboptionFailureStrings()
	return SLASH_CAA_HELP_SUBOPTION_INVALID, SLASH_CAA_HELP_SUBOPTION_INVALID;
end

local function AddSuboptionFailureString(failureText, failureTextNarrated, subOptionString)
	failureText = failureText.."|n"..subOptionString;
	failureTextNarrated = failureTextNarrated..'|n<silence msec="500"/>'..subOptionString;
	return failureText, failureTextNarrated;
end

local percentFailureText;
local percentFailureTextNarrated;

local function InitPercentFailureText()
	if not percentFailureText then
		percentFailureText, percentFailureTextNarrated = GetInitialSuboptionFailureStrings();
		for index, info in CombatAudioAlertUtil.EnumeratePercentInfo() do
			local cvarVal = index - 1;
			local subOptionString = SLASH_CAA_HELP_SUBOPTION_FORMAT:format(cvarVal, info.str);
			percentFailureText, percentFailureTextNarrated = AddSuboptionFailureString(percentFailureText, percentFailureTextNarrated, subOptionString);
		end
	end
end

local sayCastsFailureText;
local sayCastsFailureTextNarrated;

local function InitSayCastsFailureText()
	if not sayCastsFailureText then
		sayCastsFailureText, sayCastsFailureTextNarrated = GetInitialSuboptionFailureStrings();
		for index, info in CombatAudioAlertUtil.EnumerateSayCastInfo() do
			local cvarVal = index - 1;
			local subOptionString = SLASH_CAA_HELP_SUBOPTION_FORMAT:format(cvarVal, info.str);
			sayCastsFailureText, sayCastsFailureTextNarrated = AddSuboptionFailureString(sayCastsFailureText, sayCastsFailureTextNarrated, subOptionString);
		end
	end
end

local resourceFailureText;
local resourceFailureTextNarrated;

local function InitResourceFailureText()
	if not resourceFailureText then
		resourceFailureText, resourceFailureTextNarrated = GetInitialSuboptionFailureStrings();
		for index, info in CombatAudioAlertUtil.EnumeratePlayerResourceFormatInfo() do
			local cvarVal = index - 1;
			local formattedStr = CombatAudioAlertUtil.GetFormattedString(info, CAA_SAMPLE_RESOURCENAME, EXAMPLE_PERCENT);
			local subOptionString = SLASH_CAA_HELP_SUBOPTION_FORMAT:format(cvarVal, formattedStr);
			resourceFailureText, resourceFailureTextNarrated = AddSuboptionFailureString(resourceFailureText, resourceFailureTextNarrated, subOptionString);
		end
	end
end

-- Say Your Health
do
	local function CAA_SayYourHealthHandler(cmd, arg)
		InitPercentFailureText();

		local cvarVal = tonumber(arg);
		if cvarVal and cvarVal >= PERCENT_MIN and cvarVal <= PERCENT_MAX then
			local info = CombatAudioAlertUtil.GetPercentInfo(cvarVal);
			cmd:GetCommands():SpeakConfirmation(SLASH_CAA_CONFIRMATION:format(CAA_SAY_PLAYER_HEALTH_LABEL, info.str));
			SetCVar("CAAPlayerHealthPercent", cvarVal);
			return true;
		end

		return false, percentFailureText, percentFailureTextNarrated;
	end

	CAACommands:AddCommand(SLASH_CAA_SAY_YOUR_HEALTH, CAA_SayYourHealthHandler, nil, SLASH_CAA_HELP_SAY_YOUR_HEALTH, SLASH_CAA_SAY_YOUR_HEALTH_NARRATED, PERCENT_MIN, PERCENT_MAX);
end

-- Say Your Health Format
do
	local failureText;
	local failureTextNarrated;

	local HEALTH_FORMAT_MIN = Enum.CombatAudioAlertPlayerHealthFormatValuesMeta.MinValue;
	local HEALTH_FORMAT_MAX = Enum.CombatAudioAlertPlayerHealthFormatValuesMeta.MaxValue;

	local function InitFailureText()
		if not failureText then
			failureText, failureTextNarrated = GetInitialSuboptionFailureStrings();
			for index, info in CombatAudioAlertUtil.EnumerateUnitFormatInfo("player", Enum.CombatAudioAlertType.Health) do
				local cvarVal = index - 1;
				local formattedStr = CombatAudioAlertUtil.GetFormattedString(info, nil, EXAMPLE_PERCENT)
				local subOptionString = SLASH_CAA_HELP_SUBOPTION_FORMAT:format(cvarVal, formattedStr);
				failureText, failureTextNarrated = AddSuboptionFailureString(failureText, failureTextNarrated, subOptionString);
			end
		end
	end

	local function CAA_SayYourHealthFormatHandler(cmd, arg)
		InitFailureText();

		local cvarVal = tonumber(arg);
		if cvarVal and cvarVal >= HEALTH_FORMAT_MIN and cvarVal <= HEALTH_FORMAT_MAX then
			C_CombatAudioAlert.SetFormatSetting(Enum.CombatAudioAlertUnit.Player, Enum.CombatAudioAlertType.Health, cvarVal);
			local info = CombatAudioAlertUtil.GetUnitFormatInfo("player", Enum.CombatAudioAlertType.Health);
			local formattedStr = CombatAudioAlertUtil.GetFormattedString(info, nil, EXAMPLE_PERCENT);
			cmd:GetCommands():SpeakConfirmation(SLASH_CAA_CONFIRMATION:format(CAA_SAY_PLAYER_HEALTH_FORMAT, formattedStr));
			return true;
		end

		return false, failureText, failureTextNarrated;
	end

	CAACommands:AddCommand(SLASH_CAA_SAY_YOUR_HEALTH_FORMAT, CAA_SayYourHealthFormatHandler, nil, SLASH_CAA_HELP_SAY_YOUR_HEALTH_FORMAT, SLASH_CAA_SAY_YOUR_HEALTH_FORMAT_NARRATED, HEALTH_FORMAT_MIN, HEALTH_FORMAT_MAX);
end

-- Say Your Health Throttle
do
	local function CAA_SayYourHealthThrottleHandler(cmd, arg)
		local cvarVal = tonumber(arg);
		if cvarVal and cvarVal >= THROTTLE_MIN and cvarVal <= THROTTLE_MAX then
			C_CombatAudioAlert.SetThrottle(Enum.CombatAudioAlertThrottle.PlayerHealth, cvarVal);
			local formattedStr = SECONDS_FLOAT:format(cvarVal);
			cmd:GetCommands():SpeakConfirmation(SLASH_CAA_CONFIRMATION:format(CAA_SAY_PLAYER_HEALTH_THROTTLE, formattedStr));
			return true;
		end

		return false;
	end

	CAACommands:AddCommand(SLASH_CAA_SAY_YOUR_HEALTH_THROTTLE, CAA_SayYourHealthThrottleHandler, nil, SLASH_CAA_HELP_SAY_YOUR_HEALTH_THROTTLE, SLASH_CAA_SAY_YOUR_HEALTH_THROTTLE_NARRATED, THROTTLE_MIN, THROTTLE_MAX);
end

-- Say Target Health
do
	local function CAA_SayTargetHealthHandler(cmd, arg)
		InitPercentFailureText();

		local cvarVal = tonumber(arg);
		if cvarVal and cvarVal >= PERCENT_MIN and cvarVal <= PERCENT_MAX then
			local info = CombatAudioAlertUtil.GetPercentInfo(cvarVal);
			cmd:GetCommands():SpeakConfirmation(SLASH_CAA_CONFIRMATION:format(CAA_SAY_TARGET_HEALTH_LABEL, info.str));
			SetCVar("CAATargetHealthPercent", cvarVal);
			return true;
		end

		return false, percentFailureText, percentFailureTextNarrated;
	end

	CAACommands:AddCommand(SLASH_CAA_SAY_TARGET_HEALTH, CAA_SayTargetHealthHandler, nil, SLASH_CAA_HELP_SAY_TARGET_HEALTH, SLASH_CAA_SAY_TARGET_HEALTH_NARRATED, PERCENT_MIN, PERCENT_MAX);
end

-- Say Target Health Format
do
	local failureText;
	local failureTextNarrated;

	local HEALTH_FORMAT_MIN = Enum.CombatAudioAlertTargetHealthFormatValuesMeta.MinValue;
	local HEALTH_FORMAT_MAX = Enum.CombatAudioAlertTargetHealthFormatValuesMeta.MaxValue;

	local function InitFailureText()
		if not failureText then
			failureText, failureTextNarrated = GetInitialSuboptionFailureStrings();
			for index, info in CombatAudioAlertUtil.EnumerateUnitFormatInfo("target", Enum.CombatAudioAlertType.Health) do
				local cvarVal = index - 1;
				local formattedStr = CombatAudioAlertUtil.GetFormattedString(info, nil, EXAMPLE_PERCENT)
				local subOptionString = SLASH_CAA_HELP_SUBOPTION_FORMAT:format(cvarVal, formattedStr);
				failureText, failureTextNarrated = AddSuboptionFailureString(failureText, failureTextNarrated, subOptionString);
			end
		end
	end

	local function CAA_SayTargetHealthFormatHandler(cmd, arg)
		InitFailureText();

		local cvarVal = tonumber(arg);
		if cvarVal and cvarVal >= HEALTH_FORMAT_MIN and cvarVal <= HEALTH_FORMAT_MAX then
			C_CombatAudioAlert.SetFormatSetting(Enum.CombatAudioAlertUnit.Target, Enum.CombatAudioAlertType.Health, cvarVal);
			local info = CombatAudioAlertUtil.GetUnitFormatInfo("target", Enum.CombatAudioAlertType.Health);
			local formattedStr = CombatAudioAlertUtil.GetFormattedString(info, nil, EXAMPLE_PERCENT);
			cmd:GetCommands():SpeakConfirmation(SLASH_CAA_CONFIRMATION:format(CAA_SAY_TARGET_HEALTH_FORMAT, formattedStr));
			return true;
		end

		return false, failureText, failureTextNarrated;
	end

	CAACommands:AddCommand(SLASH_CAA_SAY_TARGET_HEALTH_FORMAT, CAA_SayTargetHealthFormatHandler, nil, SLASH_CAA_HELP_SAY_TARGET_HEALTH_FORMAT, SLASH_CAA_SAY_TARGET_HEALTH_FORMAT_NARRATED, HEALTH_FORMAT_MIN, HEALTH_FORMAT_MAX);
end

-- Say Target Health Throttle
do
	local function CAA_SayTargetHealthThrottleHandler(cmd, arg)
		local cvarVal = tonumber(arg);
		if cvarVal and cvarVal >= THROTTLE_MIN and cvarVal <= THROTTLE_MAX then
			C_CombatAudioAlert.SetThrottle(Enum.CombatAudioAlertThrottle.TargetHealth, cvarVal);
			local formattedStr = SECONDS_FLOAT:format(cvarVal);
			cmd:GetCommands():SpeakConfirmation(SLASH_CAA_CONFIRMATION:format(CAA_SAY_TARGET_HEALTH_THROTTLE, formattedStr));
			return true;
		end

		return false;
	end

	CAACommands:AddCommand(SLASH_CAA_SAY_TARGET_HEALTH_THROTTLE, CAA_SayTargetHealthThrottleHandler, nil, SLASH_CAA_HELP_SAY_TARGET_HEALTH_THROTTLE, SLASH_CAA_SAY_TARGET_HEALTH_THROTTLE_NARRATED, THROTTLE_MIN, THROTTLE_MAX);
end

-- Say If Targeted
do
	local failureText;
	local failureTextNarrated;

	local SAY_IF_TARGETED_MIN = Enum.CombatAudioAlertSayIfTargetedTypeMeta.MinValue;
	local SAY_IF_TARGETED_MAX = Enum.CombatAudioAlertSayIfTargetedTypeMeta.MaxValue;

	local function InitFailureText()
		if not failureText then
			failureText, failureTextNarrated = GetInitialSuboptionFailureStrings();
			for index, info in CombatAudioAlertUtil.EnumerateSayIfTargetedInfo() do
				local cvarVal = index - 1;
				local subOptionString = SLASH_CAA_HELP_SUBOPTION_FORMAT:format(cvarVal, info.str);
				failureText, failureTextNarrated = AddSuboptionFailureString(failureText, failureTextNarrated, subOptionString);
			end
		end
	end

	local function CAA_SayIfTargetedHandler(cmd, arg)
		InitFailureText();

		local cvarVal = tonumber(arg);
		if cvarVal and cvarVal >= SAY_IF_TARGETED_MIN and cvarVal <= SAY_IF_TARGETED_MAX then
			C_CombatAudioAlert.SetSpecSetting(Enum.CombatAudioAlertSpecSetting.SayIfTargeted, cvarVal);
			local info = CombatAudioAlertUtil.GetSayIfTargetedInfo(cvarVal);
			cmd:GetCommands():SpeakConfirmation(SLASH_CAA_CONFIRMATION:format(CAA_SAY_IF_TARGETED_LABEL, info.str));
			return true;
		end

		return false, failureText, failureTextNarrated;
	end

	CAACommands:AddCommand(SLASH_CAA_SAY_IF_TARGETED, CAA_SayIfTargetedHandler, nil, SLASH_CAA_HELP_SAY_IF_TARGETED, SLASH_CAA_SAY_IF_TARGETED_NARRATED, SAY_IF_TARGETED_MIN, SAY_IF_TARGETED_MAX);
end

-- Say Party Health
do
	local failureText;
	local failureTextNarrated;

	local SAY_PARTY_HEALTH_MIN = Enum.CombatAudioAlertPartyPercentValuesMeta.MinValue;
	local SAY_PARTY_HEALTH_MAX = Enum.CombatAudioAlertPartyPercentValuesMeta.MaxValue;

	local function InitFailureText()
		if not failureText then
			failureText, failureTextNarrated = GetInitialSuboptionFailureStrings();
			for index, info in CombatAudioAlertUtil.EnumeratePartyHealthPercentInfo() do
				local cvarVal = index - 1;
				local subOptionString = SLASH_CAA_HELP_SUBOPTION_FORMAT:format(cvarVal, info.str);
				failureText, failureTextNarrated = AddSuboptionFailureString(failureText, failureTextNarrated, subOptionString);
			end
		end
	end

	local function CAA_SayPartyHealthHandler(cmd, arg)
		InitFailureText();

		local cvarVal = tonumber(arg);
		if cvarVal and cvarVal >= SAY_PARTY_HEALTH_MIN and cvarVal <= SAY_PARTY_HEALTH_MAX then
			C_CombatAudioAlert.SetSpecSetting(Enum.CombatAudioAlertSpecSetting.SayIfTargeted, cvarVal);
			local info = CombatAudioAlertUtil.GetPartyHealthPercentInfo(cvarVal);
			cmd:GetCommands():SpeakConfirmation(SLASH_CAA_CONFIRMATION:format(CAA_SAY_PARTY_HEALTH_LABEL, info.str));
			return true;
		end

		return false, failureText, failureTextNarrated;
	end

	CAACommands:AddCommand(SLASH_CAA_SAY_PARTY_HEALTH, CAA_SayPartyHealthHandler, nil, SLASH_CAA_HELP_SAY_PARTY_HEALTH, SLASH_CAA_SAY_PARTY_HEALTH_NARRATED, SAY_PARTY_HEALTH_MIN, SAY_PARTY_HEALTH_MAX);
end

-- Say Party Health Frequency
do
	local function CAA_SetPartyHealthFrequencyHandler(cmd, newVal)
		cmd:GetCommands():SpeakConfirmation(SLASH_CAA_CONFIRMATION:format(CAA_SAY_PARTY_HEALTH_FREQUENCY, newVal));
		SetCVar("CAAPartyHealthFrequency", newVal);
		return true;
	end

	CAACommands:AddCommand(SLASH_CAA_SAY_PARTY_HEALTH_FREQUENCY, CAA_SetPartyHealthFrequencyHandler, nil, SLASH_CAA_HELP_SAY_PARTY_HEALTH_FREQUENCY, SLASH_CAA_SAY_PARTY_HEALTH_FREQUENCY_NARRATED, Constants.CAAConstants.CAAFrequencyMin, Constants.CAAConstants.CAAFrequencyMax, nil, VALIDATE_RANGE_YES);
end

-- Say Your Casts
do
	local function CAA_SayYourCastsHandler(cmd, arg)
		InitSayCastsFailureText();

		local cvarVal = tonumber(arg);
		if cvarVal and cvarVal >= SAY_CASTS_MIN and cvarVal <= SAY_CASTS_MAX then
			local info = CombatAudioAlertUtil.GetSayCastInfo(cvarVal);
			cmd:GetCommands():SpeakConfirmation(SLASH_CAA_CONFIRMATION:format(CAA_SAY_PLAYER_CASTS_LABEL, info.str));
			SetCVar("CAAPlayerCastMode", cvarVal);
			return true;
		end

		return false, sayCastsFailureText, sayCastsFailureTextNarrated;
	end

	CAACommands:AddCommand(SLASH_CAA_SAY_YOUR_CASTS, CAA_SayYourCastsHandler, nil, SLASH_CAA_HELP_SAY_YOUR_CASTS, SLASH_CAA_SAY_YOUR_CASTS_NARRATED, SAY_CASTS_MIN, SAY_CASTS_MAX);
end

-- Say Your Casts Format
do
	local failureText;
	local failureTextNarrated;

	local SAY_YOUR_CASTS_MIN = Enum.CombatAudioAlertPlayerCastFormatValuesMeta.MinValue;
	local SAY_YOUR_CASTS_MAX = Enum.CombatAudioAlertPlayerCastFormatValuesMeta.MaxValue;

	local function InitFailureText()
		if not failureText then
			failureText, failureTextNarrated = GetInitialSuboptionFailureStrings();
			for index, info in CombatAudioAlertUtil.EnumerateUnitFormatInfo("player", Enum.CombatAudioAlertType.Cast) do
				local cvarVal = index - 1;
				local formattedStr = CombatAudioAlertUtil.GetFormattedString(info, CAA_SAMPLE_SPELLNAME);
				local subOptionString = SLASH_CAA_HELP_SUBOPTION_FORMAT:format(cvarVal, formattedStr);
				failureText, failureTextNarrated = AddSuboptionFailureString(failureText, failureTextNarrated, subOptionString);
			end
		end
	end

	local function CAA_SayYourCastsFormatHandler(cmd, arg)
		InitFailureText();

		local cvarVal = tonumber(arg);
		if cvarVal and cvarVal >= SAY_YOUR_CASTS_MIN and cvarVal <= SAY_YOUR_CASTS_MAX then
			C_CombatAudioAlert.SetFormatSetting(Enum.CombatAudioAlertUnit.Player, Enum.CombatAudioAlertType.Cast, cvarVal);
			local info = CombatAudioAlertUtil.GetUnitFormatInfo("player", Enum.CombatAudioAlertType.Cast);
			local formattedStr = CombatAudioAlertUtil.GetFormattedString(info, CAA_SAMPLE_SPELLNAME)
			cmd:GetCommands():SpeakConfirmation(SLASH_CAA_CONFIRMATION:format(CAA_SAY_YOUR_CASTS_FORMAT, formattedStr));
			return true;
		end

		return false, failureText, failureTextNarrated;
	end

	CAACommands:AddCommand(SLASH_CAA_SAY_YOUR_CASTS_FORMAT, CAA_SayYourCastsFormatHandler, nil, SLASH_CAA_HELP_SAY_YOUR_CASTS_FORMAT, SLASH_CAA_SAY_YOUR_CASTS_FORMAT_NARRATED, SAY_YOUR_CASTS_MIN, SAY_YOUR_CASTS_MAX);
end

-- Say Your Casts Min Cast Time
do
	local function CAA_SayYourCastsMinCastTimeHandler(cmd, arg)
		local cvarVal = tonumber(arg);
		if cvarVal and cvarVal >= CAST_TIME_MIN and cvarVal <= CAST_TIME_MAX then
			local formattedStr = SECONDS_FLOAT:format(cvarVal);
			cmd:GetCommands():SpeakConfirmation(SLASH_CAA_CONFIRMATION:format(CAA_SAY_YOUR_CASTS_MIN_CAST_TIME, formattedStr));
			SetCVar("CAAPlayerCastMinTime", cvarVal);
			return true;
		end

		return false;
	end

	CAACommands:AddCommand(SLASH_CAA_SAY_YOUR_CASTS_MIN_CAST_TIME, CAA_SayYourCastsMinCastTimeHandler, nil, SLASH_CAA_HELP_SAY_YOUR_CASTS_MIN_CAST_TIME, SLASH_CAA_SAY_YOUR_CASTS_MIN_CAST_TIME_NARRATED, CAST_TIME_MIN, CAST_TIME_MAX);
end

-- Say Your Casts Throttle
do
	local function CAA_SayYourCastsThrottleHandler(cmd, arg)
		local cvarVal = tonumber(arg);
		if cvarVal and cvarVal >= THROTTLE_MIN and cvarVal <= THROTTLE_MAX then
			C_CombatAudioAlert.SetThrottle(Enum.CombatAudioAlertThrottle.PlayerCast, cvarVal);
			local formattedStr = SECONDS_FLOAT:format(cvarVal);
			cmd:GetCommands():SpeakConfirmation(SLASH_CAA_CONFIRMATION:format(CAA_SAY_YOUR_CASTS_THROTTLE, formattedStr));
			return true;
		end

		return false;
	end

	CAACommands:AddCommand(SLASH_CAA_SAY_YOUR_CASTS_THROTTLE, CAA_SayYourCastsThrottleHandler, nil, SLASH_CAA_HELP_SAY_YOUR_CASTS_THROTTLE, SLASH_CAA_SAY_YOUR_CASTS_THROTTLE_NARRATED, THROTTLE_MIN, THROTTLE_MAX);
end

-- Say Target Casts
do
	local function CAA_SayTargetCastsHandler(cmd, arg)
		InitSayCastsFailureText();

		local cvarVal = tonumber(arg);
		if cvarVal and cvarVal >= SAY_CASTS_MIN and cvarVal <= SAY_CASTS_MAX then
			local info = CombatAudioAlertUtil.GetSayCastInfo(cvarVal);
			cmd:GetCommands():SpeakConfirmation(SLASH_CAA_CONFIRMATION:format(CAA_SAY_TARGET_CASTS_LABEL, info.str));
			SetCVar("CAATargetCastMode", cvarVal);
			return true;
		end

		return false, sayCastsFailureText, sayCastsFailureTextNarrated;
	end

	CAACommands:AddCommand(SLASH_CAA_SAY_TARGET_CASTS, CAA_SayTargetCastsHandler, nil, SLASH_CAA_HELP_SAY_TARGET_CASTS, SLASH_CAA_SAY_TARGET_CASTS_NARRATED, SAY_CASTS_MIN, SAY_CASTS_MAX);
end

-- Say Target Casts Format
do
	local failureText;
	local failureTextNarrated;

	local SAY_TARGET_CASTS_MIN = Enum.CombatAudioAlertTargetCastFormatValuesMeta.MinValue;
	local SAY_TARGET_CASTS_MAX = Enum.CombatAudioAlertTargetCastFormatValuesMeta.MaxValue;

	local function InitFailureText()
		if not failureText then
			failureText, failureTextNarrated = GetInitialSuboptionFailureStrings();
			for index, info in CombatAudioAlertUtil.EnumerateUnitFormatInfo("target", Enum.CombatAudioAlertType.Cast) do
				local cvarVal = index - 1;
				local formattedStr = CombatAudioAlertUtil.GetFormattedString(info, CAA_SAMPLE_SPELLNAME);
				local subOptionString = SLASH_CAA_HELP_SUBOPTION_FORMAT:format(cvarVal, formattedStr);
				failureText, failureTextNarrated = AddSuboptionFailureString(failureText, failureTextNarrated, subOptionString);
			end
		end
	end

	local function CAA_SayTargetCastsFormatHandler(cmd, arg)
		InitFailureText();

		local cvarVal = tonumber(arg);
		if cvarVal and cvarVal >= SAY_TARGET_CASTS_MIN and cvarVal <= SAY_TARGET_CASTS_MAX then
			C_CombatAudioAlert.SetFormatSetting(Enum.CombatAudioAlertUnit.Target, Enum.CombatAudioAlertType.Cast, cvarVal);
			local info = CombatAudioAlertUtil.GetUnitFormatInfo("target", Enum.CombatAudioAlertType.Cast);
			local formattedStr = CombatAudioAlertUtil.GetFormattedString(info, CAA_SAMPLE_SPELLNAME)
			cmd:GetCommands():SpeakConfirmation(SLASH_CAA_CONFIRMATION:format(CAA_SAY_TARGET_CASTS_FORMAT, formattedStr));
			return true;
		end

		return false, failureText, failureTextNarrated;
	end

	CAACommands:AddCommand(SLASH_CAA_SAY_TARGET_CASTS_FORMAT, CAA_SayTargetCastsFormatHandler, nil, SLASH_CAA_HELP_SAY_TARGET_CASTS_FORMAT, SLASH_CAA_SAY_TARGET_CASTS_FORMAT_NARRATED, SAY_TARGET_CASTS_MIN, SAY_TARGET_CASTS_MAX);
end

-- Say Target Casts Min Cast Time
do
	local function CAA_SayTargetCastsMinCastTimeHandler(cmd, arg)
		local cvarVal = tonumber(arg);
		if cvarVal and cvarVal >= CAST_TIME_MIN and cvarVal <= CAST_TIME_MAX then
			local formattedStr = SECONDS_FLOAT:format(cvarVal);
			cmd:GetCommands():SpeakConfirmation(SLASH_CAA_CONFIRMATION:format(CAA_SAY_TARGET_CASTS_MIN_CAST_TIME, formattedStr));
			SetCVar("CAATargetCastMinTime", cvarVal);
			return true;
		end

		return false;
	end

	CAACommands:AddCommand(SLASH_CAA_SAY_TARGET_CASTS_MIN_CAST_TIME, CAA_SayTargetCastsMinCastTimeHandler, nil, SLASH_CAA_HELP_SAY_TARGET_CASTS_MIN_CAST_TIME, SLASH_CAA_SAY_TARGET_CASTS_MIN_CAST_TIME_NARRATED, CAST_TIME_MIN, CAST_TIME_MAX);
end

-- Say Target Casts Throttle
do
	local function CAA_SayTargetCastsThrottleHandler(cmd, arg)
		local cvarVal = tonumber(arg);
		if cvarVal and cvarVal >= THROTTLE_MIN and cvarVal <= THROTTLE_MAX then
			C_CombatAudioAlert.SetThrottle(Enum.CombatAudioAlertThrottle.TargetCast, cvarVal);
			local formattedStr = SECONDS_FLOAT:format(cvarVal);
			cmd:GetCommands():SpeakConfirmation(SLASH_CAA_CONFIRMATION:format(CAA_SAY_TARGET_CASTS_THROTTLE, formattedStr));
			return true;
		end

		return false;
	end

	CAACommands:AddCommand(SLASH_CAA_SAY_TARGET_CASTS_THROTTLE, CAA_SayTargetCastsThrottleHandler, nil, SLASH_CAA_HELP_SAY_TARGET_CASTS_THROTTLE, SLASH_CAA_SAY_TARGET_CASTS_THROTTLE_NARRATED, THROTTLE_MIN, THROTTLE_MAX);
end

-- Say Resource 1
do
	local function CAA_SayResource1Handler(cmd, arg)
		InitPercentFailureText();

		local cvarVal = tonumber(arg);
		if cvarVal and cvarVal >= PERCENT_MIN and cvarVal <= PERCENT_MAX then
			local info = CombatAudioAlertUtil.GetPercentInfo(cvarVal);
			cmd:GetCommands():SpeakConfirmation(SLASH_CAA_CONFIRMATION:format(CAA_SAY_RESOURCE_1, info.str));
			C_CombatAudioAlert.SetSpecSetting(Enum.CombatAudioAlertSpecSetting.Resource1Percent, cvarVal);
			return true;
		end

		return false, percentFailureText, percentFailureTextNarrated;
	end

	CAACommands:AddCommand(SLASH_CAA_SAY_RESOURCE_1, CAA_SayResource1Handler, nil, SLASH_CAA_HELP_SAY_RESOURCE_1, SLASH_CAA_SAY_RESOURCE_1_NARRATED, PERCENT_MIN, PERCENT_MAX);
end

-- Say Resource 1 Format
do
	local function CAA_SayResource1FormatHandler(cmd, arg)
		InitResourceFailureText();

		local cvarVal = tonumber(arg);
		if cvarVal and cvarVal >= RESOURCE_FORMAT_MIN and cvarVal <= RESOURCE_FORMAT_MAX then
			C_CombatAudioAlert.SetSpecSetting(Enum.CombatAudioAlertSpecSetting.Resource1Format, cvarVal);
			local info = CombatAudioAlertUtil.GetPlayerResourceFormatInfoFromCVarVal(cvarVal);
			local formattedStr = CombatAudioAlertUtil.GetFormattedString(info, CAA_SAMPLE_RESOURCENAME, EXAMPLE_PERCENT);
			cmd:GetCommands():SpeakConfirmation(SLASH_CAA_CONFIRMATION:format(CAA_SAY_RESOURCE_1_FORMAT, formattedStr));
			return true;
		end

		return false, resourceFailureText, resourceFailureTextNarrated;
	end

	CAACommands:AddCommand(SLASH_CAA_SAY_RESOURCE_1_FORMAT, CAA_SayResource1FormatHandler, nil, SLASH_CAA_HELP_SAY_RESOURCE_1_FORMAT, SLASH_CAA_SAY_RESOURCE_1_FORMAT_NARRATED, RESOURCE_FORMAT_MIN, RESOURCE_FORMAT_MAX);
end

-- Say Resource 1 Throttle
do
	local function CAA_SayResource1ThrottleHandler(cmd, arg)
		local cvarVal = tonumber(arg);
		if cvarVal and cvarVal >= THROTTLE_MIN and cvarVal <= THROTTLE_MAX then
			C_CombatAudioAlert.SetThrottle(Enum.CombatAudioAlertThrottle.PlayerResource1, cvarVal);
			local formattedStr = SECONDS_FLOAT:format(cvarVal);
			cmd:GetCommands():SpeakConfirmation(SLASH_CAA_CONFIRMATION:format(CAA_SAY_RESOURCE_1_THROTTLE, formattedStr));
			return true;
		end

		return false;
	end

	CAACommands:AddCommand(SLASH_CAA_SAY_RESOURCE_1_THROTTLE, CAA_SayResource1ThrottleHandler, nil, SLASH_CAA_HELP_SAY_RESOURCE_1_THROTTLE, SLASH_CAA_SAY_RESOURCE_1_THROTTLE_NARRATED, THROTTLE_MIN, THROTTLE_MAX);
end

-- Say Resource 2
do
	local function CAA_SayResource2Handler(cmd, arg)
		InitPercentFailureText();

		local cvarVal = tonumber(arg);
		if cvarVal and cvarVal >= PERCENT_MIN and cvarVal <= PERCENT_MAX then
			local info = CombatAudioAlertUtil.GetPercentInfo(cvarVal);
			cmd:GetCommands():SpeakConfirmation(SLASH_CAA_CONFIRMATION:format(CAA_SAY_RESOURCE_2, info.str));
			C_CombatAudioAlert.SetSpecSetting(Enum.CombatAudioAlertSpecSetting.Resource2Percent, cvarVal);
			return true;
		end

		return false, percentFailureText, percentFailureTextNarrated;
	end

	CAACommands:AddCommand(SLASH_CAA_SAY_RESOURCE_2, CAA_SayResource2Handler, nil, SLASH_CAA_HELP_SAY_RESOURCE_2, SLASH_CAA_SAY_RESOURCE_2_NARRATED, PERCENT_MIN, PERCENT_MAX);
end

-- Say Resource 2 Format
do
	local function CAA_SayResource2FormatHandler(cmd, arg)
		InitResourceFailureText();

		local cvarVal = tonumber(arg);
		if cvarVal and cvarVal >= RESOURCE_FORMAT_MIN and cvarVal <= RESOURCE_FORMAT_MAX then
			C_CombatAudioAlert.SetSpecSetting(Enum.CombatAudioAlertSpecSetting.Resource2Format, cvarVal);
			local info = CombatAudioAlertUtil.GetPlayerResourceFormatInfoFromCVarVal(cvarVal);
			local formattedStr = CombatAudioAlertUtil.GetFormattedString(info, CAA_SAMPLE_RESOURCENAME, EXAMPLE_PERCENT);
			cmd:GetCommands():SpeakConfirmation(SLASH_CAA_CONFIRMATION:format(CAA_SAY_RESOURCE_2_FORMAT, formattedStr));
			return true;
		end

		return false, resourceFailureText, resourceFailureTextNarrated;
	end

	CAACommands:AddCommand(SLASH_CAA_SAY_RESOURCE_2_FORMAT, CAA_SayResource2FormatHandler, nil, SLASH_CAA_HELP_SAY_RESOURCE_2_FORMAT, SLASH_CAA_SAY_RESOURCE_2_FORMAT_NARRATED, RESOURCE_FORMAT_MIN, RESOURCE_FORMAT_MAX);
end

-- Say Resource 2 Throttle
do
	local function CAA_SayResource2ThrottleHandler(cmd, arg)
		local cvarVal = tonumber(arg);
		if cvarVal and cvarVal >= THROTTLE_MIN and cvarVal <= THROTTLE_MAX then
			C_CombatAudioAlert.SetThrottle(Enum.CombatAudioAlertThrottle.PlayerResource2, cvarVal);
			local formattedStr = SECONDS_FLOAT:format(cvarVal);
			cmd:GetCommands():SpeakConfirmation(SLASH_CAA_CONFIRMATION:format(CAA_SAY_RESOURCE_2_THROTTLE, formattedStr));
			return true;
		end

		return false;
	end

	CAACommands:AddCommand(SLASH_CAA_SAY_RESOURCE_2_THROTTLE, CAA_SayResource2ThrottleHandler, nil, SLASH_CAA_HELP_SAY_RESOURCE_2_THROTTLE, SLASH_CAA_SAY_RESOURCE_2_THROTTLE_NARRATED, THROTTLE_MIN, THROTTLE_MAX);
end
