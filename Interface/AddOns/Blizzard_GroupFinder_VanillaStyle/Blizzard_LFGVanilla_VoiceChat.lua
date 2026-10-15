local VoiceChat = {};

VoiceChat.VoiceModeLabels = {
	[Enum.LFGEntryVoiceMode.None] = VOICE_CHAT_MODE_NONE,
	[Enum.LFGEntryVoiceMode.Legacy] = VOICE_CHAT_MODE_LEGACY,
	[Enum.LFGEntryVoiceMode.Discord] = VOICE_CHAT_MODE_DISCORD,
	[Enum.LFGEntryVoiceMode.Custom] = VOICE_CHAT_MODE_CUSTOM,
};

return VoiceChat;
