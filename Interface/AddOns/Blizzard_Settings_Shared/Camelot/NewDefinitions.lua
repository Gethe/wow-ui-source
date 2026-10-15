NewSettings["1.60.1"] = {
	"voiceProvider",
	"voiceUseDiscordSettings",
};

local function IsDiscordVoiceEnabled()
	return C_Discord.IsVoiceEnabled();
end

NewSettingsPredicates["voiceProvider"] = IsDiscordVoiceEnabled;
NewSettingsPredicates["voiceUseDiscordSettings"] = IsDiscordVoiceEnabled;
