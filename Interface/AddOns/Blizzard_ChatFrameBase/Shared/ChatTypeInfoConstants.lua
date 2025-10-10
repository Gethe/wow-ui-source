ChatTypeInfo = {};

ChatTypeInfo["SYSTEM"]									= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["SAY"]										= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["PARTY"]									= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["RAID"]									= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["GUILD"]									= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["OFFICER"]									= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["YELL"]									= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["WHISPER"]									= { sticky = 1, flashTab = true, flashTabOnGeneral = true, ignoreChatTypeProcessing = false };
ChatTypeInfo["SMART_WHISPER"]							= CopyTable(ChatTypeInfo["WHISPER"]);
ChatTypeInfo["WHISPER_INFORM"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["REPLY"]									= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["EMOTE"]									= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["TEXT_EMOTE"]								= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["MONSTER_SAY"]								= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["MONSTER_PARTY"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["MONSTER_YELL"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["MONSTER_WHISPER"]							= { sticky = 0, flashTab = true, flashTabOnGeneral = true, ignoreChatTypeProcessing = false };
ChatTypeInfo["MONSTER_EMOTE"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL"]									= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL_JOIN"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL_LEAVE"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL_LIST"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL_NOTICE"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL_NOTICE_USER"]						= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["TARGETICONS"]								= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["AFK"]										= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["DND"]										= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["IGNORED"]									= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["SKILL"]									= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["LOOT"]									= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CURRENCY"]								= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["MONEY"]									= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["OPENING"]									= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["TRADESKILLS"]								= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["PET_INFO"]								= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["COMBAT_MISC_INFO"]						= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["COMBAT_XP_GAIN"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["COMBAT_HONOR_GAIN"]						= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["COMBAT_FACTION_CHANGE"]					= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["BG_SYSTEM_NEUTRAL"]						= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["BG_SYSTEM_ALLIANCE"]						= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["BG_SYSTEM_HORDE"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["RAID_LEADER"]								= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["RAID_WARNING"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["RAID_BOSS_WHISPER"]						= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["RAID_BOSS_EMOTE"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["QUEST_BOSS_EMOTE"]						= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["FILTERED"]								= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["INSTANCE_CHAT"]                            = { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["INSTANCE_CHAT_LEADER"]                     = { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["RESTRICTED"] 			                    = { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL1"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL2"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL3"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL4"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL5"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL6"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL7"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL8"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL9"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL10"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL11"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL12"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL13"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL14"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL15"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL16"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL17"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL18"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL19"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["CHANNEL20"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["ACHIEVEMENT"]								= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["GUILD_ACHIEVEMENT"]						= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["PARTY_LEADER"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["BN_WHISPER"]								= { sticky = 1, flashTab = true, flashTabOnGeneral = true, ignoreChatTypeProcessing = false };
ChatTypeInfo["BN_WHISPER_INFORM"]						= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["BN_ALERT"]								= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["BN_BROADCAST"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["BN_BROADCAST_INFORM"]						= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["BN_INLINE_TOAST_ALERT"]					= { sticky = 0, flashTab = true, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["BN_INLINE_TOAST_BROADCAST"]				= { sticky = 0, flashTab = true, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["BN_INLINE_TOAST_BROADCAST_INFORM"]		= { sticky = 0, flashTab = true, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["BN_WHISPER_PLAYER_OFFLINE"] 				= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["PET_BATTLE_COMBAT_LOG"]					= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["PET_BATTLE_INFO"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["COMMUNITIES_CHANNEL"]						= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["VOICE_TEXT"]								= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
--NEW_CHAT_TYPE -Add the info here.

ChatTypeGroup = {};

ChatTypeGroup["SAY"] = {
	"CHAT_MSG_SAY",
};

ChatTypeGroup["EMOTE"] = {
	"CHAT_MSG_EMOTE",
	"CHAT_MSG_TEXT_EMOTE",
};

ChatTypeGroup["YELL"] = {
	"CHAT_MSG_YELL",
};

ChatTypeGroup["WHISPER"] = {
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_AFK",
	"CHAT_MSG_DND",
};

ChatTypeGroup["PARTY"] = {
	"CHAT_MSG_PARTY",
	"CHAT_MSG_MONSTER_PARTY",
};

ChatTypeGroup["PARTY_LEADER"] = {
	"CHAT_MSG_PARTY_LEADER",
};

ChatTypeGroup["RAID"] = {
	"CHAT_MSG_RAID",
};

ChatTypeGroup["RAID_LEADER"] = {
	"CHAT_MSG_RAID_LEADER",
};

ChatTypeGroup["RAID_WARNING"] = {
	"CHAT_MSG_RAID_WARNING",
};

ChatTypeGroup["INSTANCE_CHAT"] = {
	"CHAT_MSG_INSTANCE_CHAT",
};

ChatTypeGroup["INSTANCE_CHAT_LEADER"] = {
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
};

ChatTypeGroup["GUILD"] = {
	"CHAT_MSG_GUILD",
	"GUILD_MOTD",
};

ChatTypeGroup["OFFICER"] = {
	"CHAT_MSG_OFFICER",
};

ChatTypeGroup["MONSTER_SAY"] = {
	"CHAT_MSG_MONSTER_SAY",
};

ChatTypeGroup["MONSTER_YELL"] = {
	"CHAT_MSG_MONSTER_YELL",
};

ChatTypeGroup["MONSTER_EMOTE"] = {
	"CHAT_MSG_MONSTER_EMOTE",
};

ChatTypeGroup["MONSTER_WHISPER"] = {
	"CHAT_MSG_MONSTER_WHISPER",
};

ChatTypeGroup["MONSTER_BOSS_EMOTE"] = {
	"CHAT_MSG_RAID_BOSS_EMOTE",
};

ChatTypeGroup["MONSTER_BOSS_WHISPER"] = {
	"CHAT_MSG_RAID_BOSS_WHISPER",
};

ChatTypeGroup["ERRORS"] = {
	"CHAT_MSG_RESTRICTED",
	"CHAT_MSG_FILTERED",
};

ChatTypeGroup["AFK"] = {
	"CHAT_MSG_AFK",
};

ChatTypeGroup["DND"] = {
	"CHAT_MSG_DND",
};

ChatTypeGroup["IGNORED"] = {
	"CHAT_MSG_IGNORED",
};

ChatTypeGroup["BG_HORDE"] = {
	"CHAT_MSG_BG_SYSTEM_HORDE",
};

ChatTypeGroup["BG_ALLIANCE"] = {
	"CHAT_MSG_BG_SYSTEM_ALLIANCE",
};

ChatTypeGroup["BG_NEUTRAL"] = {
	"CHAT_MSG_BG_SYSTEM_NEUTRAL",
};

ChatTypeGroup["COMBAT_XP_GAIN"] = {
	"CHAT_MSG_COMBAT_XP_GAIN";
}
ChatTypeGroup["COMBAT_HONOR_GAIN"] = {
	"CHAT_MSG_COMBAT_HONOR_GAIN";
}
ChatTypeGroup["COMBAT_FACTION_CHANGE"] = {
	"CHAT_MSG_COMBAT_FACTION_CHANGE";
};

ChatTypeGroup["SKILL"] = {
	"CHAT_MSG_SKILL",
};

ChatTypeGroup["LOOT"] = {
	"CHAT_MSG_LOOT",
};

ChatTypeGroup["MONEY"] = {
	"CHAT_MSG_MONEY",
};

ChatTypeGroup["CURRENCY"] = {
	"CHAT_MSG_CURRENCY",
};

ChatTypeGroup["OPENING"] = {
	"CHAT_MSG_OPENING";
};

ChatTypeGroup["TRADESKILLS"] = {
	"CHAT_MSG_TRADESKILLS";
};

ChatTypeGroup["PET_INFO"] = {
	"CHAT_MSG_PET_INFO";
};

ChatTypeGroup["COMBAT_MISC_INFO"] = {
	"CHAT_MSG_COMBAT_MISC_INFO";
};

ChatTypeGroup["ACHIEVEMENT"] = {
	"CHAT_MSG_ACHIEVEMENT";
};

ChatTypeGroup["CHANNEL"] = {
	"CHAT_MSG_CHANNEL_JOIN",
	"CHAT_MSG_CHANNEL_LEAVE",
	"CHAT_MSG_CHANNEL_NOTICE",
	"CHAT_MSG_CHANNEL_NOTICE_USER",
	"CHAT_MSG_CHANNEL_LIST",
};

ChatTypeGroup["COMMUNITIES_CHANNEL"] = {
	"CHAT_MSG_COMMUNITIES_CHANNEL",
};

ChatTypeGroup["TARGETICONS"] = {
	"CHAT_MSG_TARGETICONS"
};

ChatTypeGroup["BN_WHISPER"] = {
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BN_WHISPER_INFORM",
};

ChatTypeGroup["BN_INLINE_TOAST_ALERT"] = {
	"CHAT_MSG_BN_INLINE_TOAST_ALERT",
	"CHAT_MSG_BN_INLINE_TOAST_BROADCAST",
	"CHAT_MSG_BN_INLINE_TOAST_BROADCAST_INFORM",
};

ChatTypeGroup["PET_BATTLE_COMBAT_LOG"] = {
	"CHAT_MSG_PET_BATTLE_COMBAT_LOG",
};

ChatTypeGroup["PET_BATTLE_INFO"] = {
	"CHAT_MSG_PET_BATTLE_INFO",
};

ChatTypeGroup["VOICE_TEXT"] = {
	"CHAT_MSG_VOICE_TEXT",
};

--NEW_CHAT_TYPE - Add the chat type above.
