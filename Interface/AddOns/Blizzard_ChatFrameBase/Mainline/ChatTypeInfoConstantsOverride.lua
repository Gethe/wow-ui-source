ChatTypeInfo["GUILD_ITEM_LOOTED"]						= CopyTable(ChatTypeInfo["GUILD_ACHIEVEMENT"]);
ChatTypeInfo["PING"]									= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = true };

ChatTypeGroup["SYSTEM"] = {
	"CHAT_MSG_SYSTEM",
	"TIME_PLAYED_MSG",
	"PLAYER_LEVEL_CHANGED",
	"UNIT_LEVEL",
	"CHAT_MSG_BN_WHISPER_PLAYER_OFFLINE",
	"DISPLAY_EVENT_TOAST_LINK",
};

ChatTypeGroup["GUILD_ACHIEVEMENT"] = {
	"CHAT_MSG_GUILD_ACHIEVEMENT",
	"CHAT_MSG_GUILD_ITEM_LOOTED",
};

ChatTypeGroup["PING"] = {
	"CHAT_MSG_PING",
};
