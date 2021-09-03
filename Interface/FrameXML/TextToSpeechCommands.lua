TEXTTOSPEECH_RATE_MIN = -10;
TEXTTOSPEECH_RATE_MAX = 10;

TEXTTOSPEECH_VOLUME_MIN = 0;
TEXTTOSPEECH_VOLUME_MAX = 100;

local TextToSpeechCommandsMixin = {};

function TextToSpeechCommandsMixin:Init()
	self.commands = {};
end

function TextToSpeechCommandsMixin:AddCommand(cmdName, callback, option, helpText, rangeMin, rangeMax, rangeFn)
	local cmdName = string.lower(cmdName);
	self.commands[cmdName] = {
		cmdName = cmdName,
		callback = callback,
		option = option,
		helpText = helpText,
		rangeMin = rangeMin,
		rangeMax = rangeMax,
		rangeFn = rangeFn,
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

function TextToSpeechCommandsMixin:EvaluateTextToSpeechCommand(msg)
	local cmdName, arg1 = self:GetArguments(msg);
	local cmd = self:GetCommand(cmdName);
	if cmd then
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

local function GetCommandArgumentRange(cmd)
	if cmd.rangeFn then
		return cmd.rangeFn();
	end

	return cmd.rangeMin, cmd.rangeMax;
end

function TextToSpeechCommandsMixin:GetCommandHelpText(cmd)
	if cmd and cmd.helpText then
		local rangeMin, rangeMax = GetCommandArgumentRange(cmd);
		if rangeMin and rangeMax then
			local displayText = cmd.helpText:format(rangeMin, rangeMax);
			local narratedText = cmd.helpText:format(GetNumericValueForNarration(rangeMin), GetNumericValueForNarration(rangeMax));
			return SLASH_TEXTTOSPEECH_HELP_FORMATSTRING_RANGE:format(cmd.cmdName, displayText), SLASH_TEXTTOSPEECH_HELP_FORMATSTRING_RANGE:format(cmd.cmdName, narratedText);
		else
			return SLASH_TEXTTOSPEECH_HELP_FORMATSTRING:format(cmd.cmdName, cmd.helpText), SLASH_TEXTTOSPEECH_HELP_FORMATSTRING:format(cmd.cmdName, cmd.helpText);
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

function TextToSpeechCommandsMixin:ShowUsage()
	self:SpeakConfirmation(TEXTTOSPEECH_HELP_OVERVIEW);

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

function TextToSpeechCommandsMixin:SpeakConfirmation(displayText, narratedText)
	narratedText = narratedText or displayText;

	if self.queuedNarration then
		table.insert(self.queuedNarration, narratedText);
	else
		self.queuedNarration = { narratedText };
		C_Timer.After(0.25, function()
			local id = nil;
			local ignoreFilters = true;
			TextToSpeechFrame_PlayMessage(DEFAULT_CHAT_FRAME, table.concat(self.queuedNarration, ". "), id, ignoreFilters);
			self.queuedNarration = nil;
		end);
	end

	TextToSpeechFrame_DisplaySilentSystemMessage(displayText);
end

TextToSpeechCommands = CreateAndInitFromMixin(TextToSpeechCommandsMixin);

local function TextToSpeech_CommandOptionHandler(cmd)
	local val = TEXTTOSPEECH_CONFIG[cmd.option] or false;
	local newVal = not val;
	TEXTTOSPEECH_CONFIG[cmd.option] = newVal;
	cmd:GetCommands():SpeakConfirmation(GetOptionConfirmation(cmd.cmdName, newVal));
	return true;
end

local function TextToSpeech_ToggleTextToSpeechChat(cmd)
	cmd:GetCommands():SpeakConfirmation(GetOptionConfirmation(cmd.cmdName, TextToSpeechFrame_ToggleChatTypeEnabled(cmd.option)));
	return true;
end

TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_PLAYLINE, TextToSpeech_CommandOptionHandler, Enum.TtsBoolSetting.PlaySoundSeparatingChatLineBreaks, SLASH_TEXTTOSPEECH_HELP_PLAYLINE);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_PLAYACTIVITY, TextToSpeech_CommandOptionHandler, Enum.TtsBoolSetting.PlayActivitySoundWhenNotFocused, SLASH_TEXTTOSPEECH_HELP_PLAYACTIVITY);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_SAYNAME, TextToSpeech_CommandOptionHandler, Enum.TtsBoolSetting.AddCharacterNameToSpeech, SLASH_TEXTTOSPEECH_HELP_SAYNAME);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_ALTSYSTEMVOICE, TextToSpeech_CommandOptionHandler, Enum.TtsBoolSetting.AlternateSystemVoice, SLASH_TEXTTOSPEECH_HELP_ALTSYSTEMVOICE);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_MYMESSAGES, TextToSpeech_CommandOptionHandler, Enum.TtsBoolSetting.NarrateMyMessages, SLASH_TEXTTOSPEECH_HELP_MYMESSAGES);

TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_NPC, TextToSpeech_ToggleTextToSpeechChat, "MONSTER_SAY", SLASH_TEXTTOSPEECH_HELP_NPC);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_SYSTEM, TextToSpeech_ToggleTextToSpeechChat, "SYSTEM", SLASH_TEXTTOSPEECH_HELP_SYSTEM);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_EMOTE, TextToSpeech_ToggleTextToSpeechChat, "EMOTE", SLASH_TEXTTOSPEECH_HELP_EMOTE);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_WHISPER, TextToSpeech_ToggleTextToSpeechChat, "WHISPER", SLASH_TEXTTOSPEECH_HELP_WHISPER);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_SAY, TextToSpeech_ToggleTextToSpeechChat, "SAY", SLASH_TEXTTOSPEECH_HELP_SAY);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_YELL, TextToSpeech_ToggleTextToSpeechChat, "YELL", SLASH_TEXTTOSPEECH_HELP_YELL);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_PARTYLEADER, TextToSpeech_ToggleTextToSpeechChat, "PARTY_LEADER", SLASH_TEXTTOSPEECH_HELP_PARTYLEADER);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_PARTY, TextToSpeech_ToggleTextToSpeechChat, "PARTY", SLASH_TEXTTOSPEECH_HELP_PARTY);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_GUILDLEADER, TextToSpeech_ToggleTextToSpeechChat, "OFFICER", SLASH_TEXTTOSPEECH_HELP_GUILDLEADER);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_GUILD, TextToSpeech_ToggleTextToSpeechChat, "GUILD", SLASH_TEXTTOSPEECH_HELP_GUILD);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_GUILD_ANNOUNCE, TextToSpeech_ToggleTextToSpeechChat, "GUILD_ACHIEVEMENT", SLASH_TEXTTOSPEECH_HELP_GUILD_ANNOUNCE);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_RAIDLEADER, TextToSpeech_ToggleTextToSpeechChat, "RAID_LEADER", SLASH_TEXTTOSPEECH_HELP_RAIDLEADER);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_RAID, TextToSpeech_ToggleTextToSpeechChat, "RAID", SLASH_TEXTTOSPEECH_HELP_RAID);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_RAID_WARNING, TextToSpeech_ToggleTextToSpeechChat, "RAID_WARNING", SLASH_TEXTTOSPEECH_HELP_RAID_WARNING);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_INSTANCELEADER, TextToSpeech_ToggleTextToSpeechChat, "INSTANCE_CHAT_LEADER", SLASH_TEXTTOSPEECH_HELP_INSTANCELEADER);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_INSTANCE, TextToSpeech_ToggleTextToSpeechChat, "INSTANCE_CHAT", SLASH_TEXTTOSPEECH_HELP_INSTANCE);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_BLIZZARD, TextToSpeech_ToggleTextToSpeechChat, "BN_WHISPER", SLASH_TEXTTOSPEECH_HELP_BLIZZARD);
TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_ACHIEVEMENT, TextToSpeech_ToggleTextToSpeechChat, "ACHIEVEMENT", SLASH_TEXTTOSPEECH_HELP_ACHIEVEMENT);

do
	local SLASH_TEXTTOSPEECH_TOGGLE = "";
	TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_TOGGLE,
		function(cmd)
			local val = GetCVarBool("textToSpeech");
			local newVal = not val;
			SetCVar("textToSpeech", newVal, "ENABLE_TEXT_TO_SPEECH");
			cmd:GetCommands():SpeakConfirmation(GetOptionConfirmation(TEXT_TO_SPEECH, newVal));
			return true;
		end
	);
end

TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_CHANNEL,
	function(cmd, channelIdentifier)
		local info = ChatFrame_GetFullChannelInfo(channelIdentifier);
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

TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_HELP,
	function(cmd, optCmdName)
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
	end,
	nil,
	SLASH_TEXTTOSPEECH_HELP_HELP
);

TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_SPEED,
	function(cmd, rate)
		if TextToSpeech_SetRate(rate) then
			cmd:GetCommands():SpeakConfirmation(SLASH_TEXTTOSPEECH_CONFIRMATION:format(TEXT_TO_SPEECH_ADJUST_RATE, rate));
			return true;
		end

		return false;
	end, nil, SLASH_TEXTTOSPEECH_HELP_SPEED, TEXTTOSPEECH_RATE_MIN, TEXTTOSPEECH_RATE_MAX
);

TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_VOLUME,
	function(cmd, volume)
		if TextToSpeech_SetVolume(volume) then
			cmd:GetCommands():SpeakConfirmation(SLASH_TEXTTOSPEECH_CONFIRMATION:format(TEXT_TO_SPEECH_ADJUST_VOLUME, volume));
			return true;
		end

		return false;
	end, nil, SLASH_TEXTTOSPEECH_HELP_VOLUME, TEXTTOSPEECH_VOLUME_MIN, TEXTTOSPEECH_VOLUME_MAX
);

local function GetVoiceRange()
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
			end, nil, helpText, nil, nil, GetVoiceRange
		);
	end

	AddVoiceChatCommand(SLASH_TEXTTOSPEECH_VOICE, SLASH_TEXTTOSPEECH_HELP_VOICE, SLASH_TEXTTOSPEECH_VOICE_CHANGED_CONFIRMATION, "standard");
	AddVoiceChatCommand(SLASH_TEXTTOSPEECH_ALTVOICE, SLASH_TEXTTOSPEECH_HELP_ALTVOICE, SLASH_TEXTTOSPEECH_ALTVOICE_CHANGED_CONFIRMATION, "alternate");
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
		TextToSpeech_PlaySample("standard");
		return true;
	end, nil, SLASH_TEXTTOSPEECH_HELP_SAMPLE
);

TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_ALTSAMPLE,
	function(cmd)
		TextToSpeech_PlaySample("alternate");
		return true;
	end, nil, SLASH_TEXTTOSPEECH_HELP_ALTSAMPLE
);

TextToSpeechCommands:AddCommand(SLASH_TEXTTOSPEECH_STOP,
	function(cmd)
		C_VoiceChat.StopSpeakingText();
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
			for cmdName, cmd in pairs(individualCommands) do
				local value = type(cmd.cmdType) == "string" and TextToSpeechFrame_GetChatTypeEnabled(cmd.option) or C_TTSSettings.GetSetting(cmd.option);
				if value then
					table.insert(entries, { GetOptionConfirmation(cmdName, value) });
				end
			end

			commands:SpeakConfirmationEntries(entries);

			return true;
		end, nil, SLASH_TEXTTOSPEECH_HELP_SETTINGS
	);
end