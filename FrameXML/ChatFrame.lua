MESSAGE_SCROLLBUTTON_INITIAL_DELAY = 0;
MESSAGE_SCROLLBUTTON_SCROLL_DELAY = 0.05;
CHAT_BUTTON_FLASH_TIME = 0.5;
CHAT_TELL_ALERT_TIME = 300;
NUM_CHAT_WINDOWS = 10;
DEFAULT_CHAT_FRAME = ChatFrame1;
NUM_REMEMBERED_TELLS = 10;
MAX_WOW_CHAT_CHANNELS = 10;

CHAT_TIMESTAMP_FORMAT = nil;		-- gets set from Interface Options
CHAT_SHOW_IME = false;

MAX_CHARACTER_NAME_BYTES = 48;

--DEBUG FIXME FOR TESTING
CHAT_OPTIONS = {
	ONE_EDIT_AT_A_TIME = "old"
};

-- Table for event indexed chatFilters.
-- Format ["CHAT_MSG_SYSTEM"] = { function1, function2, function3 }
-- filter, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11 = function1 (self, event, ...) if filter then return true end return false, ... end
local chatFilters = {};

-- These hash tables are to improve performance of common lookups
-- if you change what these tables point to (ie slash command, emote, chat)
-- then you need to invalidate the entry in the hash table
local hash_SecureCmdList = {}
hash_SlashCmdList = {}
hash_EmoteTokenList = {}
hash_ChatTypeInfoList = {}

ChatTypeInfo = { };
ChatTypeInfo["SYSTEM"]									= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["SAY"]										= { sticky = 1, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["PARTY"]									= { sticky = 1, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["RAID"]									= { sticky = 1, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["GUILD"]									= { sticky = 1, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["OFFICER"]									= { sticky = 1, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["YELL"]									= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["WHISPER"]									= { sticky = 1, flashTab = true, flashTabOnGeneral = true };
ChatTypeInfo["WHISPER_INFORM"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["REPLY"]									= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["EMOTE"]									= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["TEXT_EMOTE"]								= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["MONSTER_SAY"]								= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["MONSTER_PARTY"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["MONSTER_YELL"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["MONSTER_WHISPER"]							= { sticky = 0, flashTab = true, flashTabOnGeneral = true };
ChatTypeInfo["MONSTER_EMOTE"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["CHANNEL"]									= { sticky = 1, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["CHANNEL_JOIN"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["CHANNEL_LEAVE"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["CHANNEL_LIST"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["CHANNEL_NOTICE"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["CHANNEL_NOTICE_USER"]						= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["TARGETICONS"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["AFK"]										= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["DND"]										= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["IGNORED"]									= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["SKILL"]									= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["LOOT"]									= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["MONEY"]									= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["OPENING"]									= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["TRADESKILLS"]								= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["PET_INFO"]								= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["COMBAT_MISC_INFO"]						= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["COMBAT_XP_GAIN"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["COMBAT_HONOR_GAIN"]						= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["COMBAT_FACTION_CHANGE"]					= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["BG_SYSTEM_NEUTRAL"]						= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["BG_SYSTEM_ALLIANCE"]						= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["BG_SYSTEM_HORDE"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["RAID_LEADER"]								= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["RAID_WARNING"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["RAID_BOSS_WHISPER"]						= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["RAID_BOSS_EMOTE"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["FILTERED"]								= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["BATTLEGROUND"]                            = { sticky = 1, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["BATTLEGROUND_LEADER"]                     = { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["RESTRICTED"] 			                    = { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["CHANNEL1"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["CHANNEL2"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["CHANNEL3"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["CHANNEL4"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["CHANNEL5"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["CHANNEL6"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["CHANNEL7"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["CHANNEL8"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["CHANNEL9"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["CHANNEL10"]								= { sticky = 1, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["ACHIEVEMENT"]								= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["GUILD_ACHIEVEMENT"]						= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["PARTY_LEADER"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["BN_WHISPER"]							= { sticky = 1, flashTab = true, flashTabOnGeneral = true };
ChatTypeInfo["BN_WHISPER_INFORM"]				= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["BN_CONVERSATION"]					= { sticky = 1, flashTab = true, flashTabOnGeneral = false };
ChatTypeInfo["BN_CONVERSATION_NOTICE"]					= { sticky = 0, flashTab = true, flashTabOnGeneral = false };
ChatTypeInfo["BN_CONVERSATION_LIST"]					= { sticky = 0, flashTab = true, flashTabOnGeneral = false };
ChatTypeInfo["BN_ALERT"]								= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["BN_BROADCAST"]							= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["BN_BROADCAST_INFORM"]						= { sticky = 0, flashTab = false, flashTabOnGeneral = false };
ChatTypeInfo["BN_INLINE_TOAST_ALERT"]					= { sticky = 0, flashTab = true, flashTabOnGeneral = false };
ChatTypeInfo["BN_INLINE_TOAST_BROADCAST"]				= { sticky = 0, flashTab = true, flashTabOnGeneral = false };
ChatTypeInfo["BN_INLINE_TOAST_BROADCAST_INFORM"]		= { sticky = 0, flashTab = true, flashTabOnGeneral = false };
ChatTypeInfo["BN_INLINE_TOAST_CONVERSATION"]			= { sticky = 0, flashTab = true, flashTabOnGeneral = false };

ChatTypeGroup = {};
ChatTypeGroup["SYSTEM"] = {
	"CHAT_MSG_SYSTEM",
	"TIME_PLAYED_MSG",
	"PLAYER_LEVEL_UP",
	"CHARACTER_POINTS_CHANGED",
};
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
ChatTypeGroup["BATTLEGROUND"] = {
	"CHAT_MSG_BATTLEGROUND",
};
ChatTypeGroup["BATTLEGROUND_LEADER"] = {
	"CHAT_MSG_BATTLEGROUND_LEADER",
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
ChatTypeGroup["GUILD_ACHIEVEMENT"] = {
	"CHAT_MSG_GUILD_ACHIEVEMENT";
};
ChatTypeGroup["CHANNEL"] = {
	"CHAT_MSG_CHANNEL_JOIN",
	"CHAT_MSG_CHANNEL_LEAVE",
	"CHAT_MSG_CHANNEL_NOTICE",
	"CHAT_MSG_CHANNEL_NOTICE_USER",
	"CHAT_MSG_CHANNEL_LIST",
};
ChatTypeGroup["TARGETICONS"] = {
	"CHAT_MSG_TARGETICONS"
};
ChatTypeGroup["BN_WHISPER"] = {
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BN_WHISPER_INFORM",
};
ChatTypeGroup["BN_CONVERSATION"] = {
	"CHAT_MSG_BN_CONVERSATION",
	"CHAT_MSG_BN_CONVERSATION_NOTICE",
	"CHAT_MSG_BN_CONVERSATION_LIST",
};
ChatTypeGroup["BN_INLINE_TOAST_ALERT"] = {
	"CHAT_MSG_BN_INLINE_TOAST_ALERT",
	"CHAT_MSG_BN_INLINE_TOAST_BROADCAST",
	"CHAT_MSG_BN_INLINE_TOAST_BROADCAST_INFORM",
	"CHAT_MSG_BN_INLINE_TOAST_CONVERSATION",
};
ChatTypeGroupInverted = {};
for group, values in pairs(ChatTypeGroup) do
	for _, value in pairs(values) do
		ChatTypeGroupInverted[value] = group;
	end
end

CHAT_CATEGORY_LIST = {
	PARTY = { "PARTY_LEADER", "PARTY_GUIDE", "MONSTER_PARTY" },
	RAID = { "RAID_LEADER", "RAID_WARNING" },
	GUILD = { "GUILD_ACHIEVEMENT" },
	WHISPER = { "WHISPER_INFORM", "AFK", "DND" },
	CHANNEL = { "CHANNEL_JOIN", "CHANNEL_LEAVE", "CHANNEL_NOTICE", "CHANNEL_USER" },
	BATTLEGROUND = { "BATTLEGROUND_LEADER" },
	BN_WHISPER = { "BN_WHISPER_INFORM" },
	BN_CONVERSATION = { "BN_CONVERSATION_NOTICE", "BN_CONVERSATION_LIST" },
};

CHAT_INVERTED_CATEGORY_LIST = {};
for category, sublist in pairs(CHAT_CATEGORY_LIST) do
	for _, item in pairs(sublist) do
		CHAT_INVERTED_CATEGORY_LIST[item] = category;
	end
end

function Chat_GetChatCategory(chatType)
	return CHAT_INVERTED_CATEGORY_LIST[chatType] or chatType;
end

ChannelMenuChatTypeGroups = {};
ChannelMenuChatTypeGroups[1] = "SAY";
ChannelMenuChatTypeGroups[2] = "YELL";
ChannelMenuChatTypeGroups[3] = "GUILD";
ChannelMenuChatTypeGroups[4] = "WHISPER";
ChannelMenuChatTypeGroups[5] = "PARTY";

CombatLogMenuChatTypeGroups = {};
CombatLogMenuChatTypeGroups[1] = "OPENING";
CombatLogMenuChatTypeGroups[2] = "TRADESKILLS";
CombatLogMenuChatTypeGroups[3] = "PET_INFO";
CombatLogMenuChatTypeGroups[4] = "COMBAT_MISC_INFO";
CombatLogMenuChatTypeGroups[5] = "COMBAT_XP_GAIN";
CombatLogMenuChatTypeGroups[6] = "COMBAT_HONOR_GAIN";
CombatLogMenuChatTypeGroups[7] = "COMBAT_FACTION_CHANGE";

OtherMenuChatTypeGroups = {};
OtherMenuChatTypeGroups[1] = "CREATURE";
OtherMenuChatTypeGroups[2] = "SKILL";
OtherMenuChatTypeGroups[3] = "LOOT";

-- list of text emotes that we want to show on the Emote submenu (these have anims)
EmoteList = {
	"WAVE",
	"BOW",
	"DANCE",
	"APPLAUD",
	"BEG",
	"CHICKEN",
	"CRY",
	"EAT",
	"FLEX",
	"KISS",
	"LAUGH",
	"POINT",
	"ROAR",
	"RUDE",
	"SALUTE",
	"SHY",
	"TALK",
	"STAND",
	"SIT",
	"SLEEP",
	"KNEEL",
};

-- list of text emotes that we want to show on the Speech submenu (these have sounds)
TextEmoteSpeechList = {
	"HELPME",
	"INCOMING",
	"CHARGE",
	"FLEE",
	"ATTACKMYTARGET",
	"OOM",
	"FOLLOW",
	"WAIT",
	"HEALME",
	"CHEER",
	"OPENFIRE",
	"RASP",
	"HELLO",
	"BYE",
	"NOD",
	"NO",
	"THANK",
	"WELCOME",
	"CONGRATULATE",
	"FLIRT",
	"JOKE",
	"TRAIN",
};

-- These are text emote tokens - add new ones at the bottom of the list!
EMOTE1_TOKEN = "AGREE";
EMOTE2_TOKEN = "AMAZE";
EMOTE3_TOKEN = "ANGRY";
EMOTE4_TOKEN = "APOLOGIZE";
EMOTE5_TOKEN = "APPLAUD";
EMOTE6_TOKEN = "BASHFUL";
EMOTE7_TOKEN = "BECKON";
EMOTE8_TOKEN = "BEG";
EMOTE9_TOKEN = "BITE";
EMOTE10_TOKEN = "BLEED";
EMOTE11_TOKEN = "BLINK";
EMOTE12_TOKEN = "BLUSH";
EMOTE13_TOKEN = "BONK";
EMOTE14_TOKEN = "BORED";
EMOTE15_TOKEN = "BOUNCE";
EMOTE16_TOKEN = "BRB";
EMOTE17_TOKEN = "BOW";
EMOTE18_TOKEN = "BURP";
EMOTE19_TOKEN = "BYE";
EMOTE20_TOKEN = "CACKLE";
EMOTE21_TOKEN = "CHEER";
EMOTE22_TOKEN = "CHICKEN";
EMOTE23_TOKEN = "CHUCKLE";
EMOTE24_TOKEN = "CLAP";
EMOTE25_TOKEN = "CONFUSED";
EMOTE26_TOKEN = "CONGRATULATE";
EMOTE27_TOKEN = "UNUSED";
EMOTE28_TOKEN = "COUGH";
EMOTE29_TOKEN = "COWER";
EMOTE30_TOKEN = "CRACK";
EMOTE31_TOKEN = "CRINGE";
EMOTE32_TOKEN = "CRY";
EMOTE33_TOKEN = "CURIOUS";
EMOTE34_TOKEN = "CURTSEY";
EMOTE35_TOKEN = "DANCE";
EMOTE36_TOKEN = "DRINK";
EMOTE37_TOKEN = "DROOL";
EMOTE38_TOKEN = "EAT";
EMOTE39_TOKEN = "EYE";
EMOTE40_TOKEN = "FART";
EMOTE41_TOKEN = "FIDGET";
EMOTE42_TOKEN = "FLEX";
EMOTE43_TOKEN = "FROWN";
EMOTE44_TOKEN = "GASP";
EMOTE45_TOKEN = "GAZE";
EMOTE46_TOKEN = "GIGGLE";
EMOTE47_TOKEN = "GLARE";
EMOTE48_TOKEN = "GLOAT";
EMOTE49_TOKEN = "GREET";
EMOTE50_TOKEN = "GRIN";
EMOTE51_TOKEN = "GROAN";
EMOTE52_TOKEN = "GROVEL";
EMOTE53_TOKEN = "GUFFAW";
EMOTE54_TOKEN = "HAIL";
EMOTE55_TOKEN = "HAPPY";
EMOTE56_TOKEN = "HELLO";
EMOTE57_TOKEN = "HUG";
EMOTE58_TOKEN = "HUNGRY";
EMOTE59_TOKEN = "KISS";
EMOTE60_TOKEN = "KNEEL";
EMOTE61_TOKEN = "LAUGH";
EMOTE62_TOKEN = "LAYDOWN";
EMOTE63_TOKEN = "MASSAGE";
EMOTE64_TOKEN = "MOAN";
EMOTE65_TOKEN = "MOON";
EMOTE66_TOKEN = "MOURN";
EMOTE67_TOKEN = "NO";
EMOTE68_TOKEN = "NOD";
EMOTE69_TOKEN = "NOSEPICK";
EMOTE70_TOKEN = "PANIC";
EMOTE71_TOKEN = "PEER";
EMOTE72_TOKEN = "PLEAD";
EMOTE73_TOKEN = "POINT";
EMOTE74_TOKEN = "POKE";
EMOTE75_TOKEN = "PRAY";
EMOTE76_TOKEN = "ROAR";
EMOTE77_TOKEN = "ROFL";
EMOTE78_TOKEN = "RUDE";
EMOTE79_TOKEN = "SALUTE";
EMOTE80_TOKEN = "SCRATCH";
EMOTE81_TOKEN = "SEXY";
EMOTE82_TOKEN = "SHAKE";
EMOTE83_TOKEN = "SHOUT";
EMOTE84_TOKEN = "SHRUG";
EMOTE85_TOKEN = "SHY";
EMOTE86_TOKEN = "SIGH";
EMOTE87_TOKEN = "SIT";
EMOTE88_TOKEN = "SLEEP";
EMOTE89_TOKEN = "SNARL";
EMOTE90_TOKEN = "SPIT";
EMOTE91_TOKEN = "STARE";
EMOTE92_TOKEN = "SURPRISED";
EMOTE93_TOKEN = "SURRENDER";
EMOTE94_TOKEN = "TALK";
EMOTE95_TOKEN = "TALKEX";
EMOTE96_TOKEN = "TALKQ";
EMOTE97_TOKEN = "TAP";
EMOTE98_TOKEN = "THANK";
EMOTE99_TOKEN = "THREATEN";
EMOTE100_TOKEN = "TIRED";
EMOTE101_TOKEN = "VICTORY";
EMOTE102_TOKEN = "WAVE";
EMOTE103_TOKEN = "WELCOME";
EMOTE104_TOKEN = "WHINE";
EMOTE105_TOKEN = "WHISTLE";
EMOTE106_TOKEN = "WORK";
EMOTE107_TOKEN = "YAWN";
EMOTE108_TOKEN = "BOGGLE";
EMOTE109_TOKEN = "CALM";
EMOTE110_TOKEN = "COLD";
EMOTE111_TOKEN = "COMFORT";
EMOTE112_TOKEN = "CUDDLE";
EMOTE113_TOKEN = "DUCK";
EMOTE114_TOKEN = "INSULT";
EMOTE115_TOKEN = "INTRODUCE";
EMOTE116_TOKEN = "JK";
EMOTE117_TOKEN = "LICK";
EMOTE118_TOKEN = "LISTEN";
EMOTE119_TOKEN = "LOST";
EMOTE120_TOKEN = "MOCK";
EMOTE121_TOKEN = "PONDER";
EMOTE122_TOKEN = "POUNCE";
EMOTE123_TOKEN = "PRAISE";
EMOTE124_TOKEN = "PURR";
EMOTE125_TOKEN = "PUZZLE";
EMOTE126_TOKEN = "RAISE";
EMOTE127_TOKEN = "READY";
EMOTE128_TOKEN = "SHIMMY";
EMOTE129_TOKEN = "SHIVER";
EMOTE130_TOKEN = "SHOO";
EMOTE131_TOKEN = "SLAP";
EMOTE132_TOKEN = "SMIRK";
EMOTE133_TOKEN = "SNIFF";
EMOTE134_TOKEN = "SNUB";
EMOTE135_TOKEN = "SOOTHE";
EMOTE136_TOKEN = "STINK";
EMOTE137_TOKEN = "TAUNT";
EMOTE138_TOKEN = "TEASE";
EMOTE139_TOKEN = "THIRSTY";
EMOTE140_TOKEN = "VETO";
EMOTE141_TOKEN = "SNICKER";
EMOTE142_TOKEN = "TICKLE";
EMOTE143_TOKEN = "STAND";
EMOTE144_TOKEN = "VIOLIN";
EMOTE145_TOKEN = "SMILE";
EMOTE146_TOKEN = "RASP";
EMOTE147_TOKEN = "GROWL";
EMOTE148_TOKEN = "BARK";
EMOTE149_TOKEN = "PITY";
EMOTE150_TOKEN = "SCARED";
EMOTE151_TOKEN = "FLOP";
EMOTE152_TOKEN = "LOVE";
EMOTE153_TOKEN = "MOO";
EMOTE154_TOKEN = "COMMEND";
EMOTE155_TOKEN = "TRAIN";
EMOTE156_TOKEN = "HELPME";
EMOTE157_TOKEN = "INCOMING";
EMOTE158_TOKEN = "OPENFIRE";
EMOTE159_TOKEN = "CHARGE";
EMOTE160_TOKEN = "FLEE";
EMOTE161_TOKEN = "ATTACKMYTARGET";
EMOTE162_TOKEN = "OOM";
EMOTE163_TOKEN = "FOLLOW";
EMOTE164_TOKEN = "WAIT";
EMOTE165_TOKEN = "FLIRT";
EMOTE166_TOKEN = "HEALME";
EMOTE167_TOKEN = "JOKE";
EMOTE168_TOKEN = "WINK";
EMOTE169_TOKEN = "PAT";
EMOTE170_TOKEN = "GOLFCLAP";
EMOTE171_TOKEN = "MOUNTSPECIAL";
EMOTE304_TOKEN = "INCOMING";
EMOTE306_TOKEN = "FLEE";
EMOTE368_TOKEN = "BLAME"
EMOTE369_TOKEN = "BLANK"
EMOTE370_TOKEN = "BRANDISH"
EMOTE371_TOKEN = "BREATH"
EMOTE372_TOKEN = "DISAGREE"
EMOTE373_TOKEN = "DOUBT"
EMOTE374_TOKEN = "EMBARRASS"
EMOTE375_TOKEN = "ENCOURAGE"
EMOTE376_TOKEN = "ENEMY"
EMOTE377_TOKEN = "EYEBROW"
EMOTE380_TOKEN = "HIGHFIVE"
EMOTE381_TOKEN = "ABSENT"
EMOTE382_TOKEN = "ARM"
EMOTE383_TOKEN = "AWE"
EMOTE384_TOKEN = "BACKPACK"
EMOTE385_TOKEN = "BADFEELING"
EMOTE386_TOKEN = "CHALLENGE"
EMOTE387_TOKEN = "CHUG"
EMOTE389_TOKEN = "DING"
EMOTE390_TOKEN = "FACEPALM"
EMOTE391_TOKEN = "FAINT"
EMOTE392_TOKEN = "GO"
EMOTE393_TOKEN = "GOING"
EMOTE394_TOKEN = "GLOWER"
EMOTE395_TOKEN = "HEADACHE"
EMOTE396_TOKEN = "HICCUP"
EMOTE398_TOKEN = "HISS"
EMOTE399_TOKEN = "HOLDHAND"
EMOTE401_TOKEN = "HURRY"
EMOTE402_TOKEN = "IDEA"
EMOTE403_TOKEN = "JEALOUS"
EMOTE404_TOKEN = "LUCK"
EMOTE405_TOKEN = "MAP"
EMOTE406_TOKEN = "MERCY"
EMOTE407_TOKEN = "MUTTER"
EMOTE408_TOKEN = "NERVOUS"
EMOTE409_TOKEN = "OFFER"
EMOTE410_TOKEN = "PET"
EMOTE411_TOKEN = "PINCH"
EMOTE413_TOKEN = "PROUD"
EMOTE414_TOKEN = "PROMISE"
EMOTE415_TOKEN = "PULSE"
EMOTE416_TOKEN = "PUNCH"
EMOTE417_TOKEN = "POUT"
EMOTE418_TOKEN = "REGRET"
EMOTE420_TOKEN = "REVENGE"
EMOTE421_TOKEN = "ROLLEYES"
EMOTE422_TOKEN = "RUFFLE"
EMOTE423_TOKEN = "SAD"
EMOTE424_TOKEN = "SCOFF"
EMOTE425_TOKEN = "SCOLD"
EMOTE426_TOKEN = "SCOWL"
EMOTE427_TOKEN = "SEARCH"
EMOTE428_TOKEN = "SHAKEFIST"
EMOTE429_TOKEN = "SHIFTY"
EMOTE430_TOKEN = "SHUDDER"
EMOTE431_TOKEN = "SIGNAL"
EMOTE432_TOKEN = "SILENCE"
EMOTE433_TOKEN = "SING"
EMOTE434_TOKEN = "SMACK"
EMOTE435_TOKEN = "SNEAK"
EMOTE436_TOKEN = "SNEEZE"
EMOTE437_TOKEN = "SNORT"
EMOTE438_TOKEN = "SQUEAL"
EMOTE440_TOKEN = "SUSPICIOUS"
EMOTE441_TOKEN = "THINK"
EMOTE442_TOKEN = "TRUCE"
EMOTE443_TOKEN = "TWIDDLE"
EMOTE444_TOKEN = "WARN"
EMOTE445_TOKEN = "SNAP"
EMOTE446_TOKEN = "CHARM"
EMOTE447_TOKEN = "COVEREARS"
EMOTE448_TOKEN = "CROSSARMS"
EMOTE449_TOKEN = "LOOK"
EMOTE450_TOKEN = "OBJECT"
EMOTE451_TOKEN = "SWEAT"
EMOTE452_TOKEN = "YW"
local MAXEMOTEINDEX = 452;


ICON_LIST = {
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:",
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:",
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:",
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:",
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:",
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:",
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:",
	"|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:",
}

--Links tags from Global Strings to indicies for entries in ICON_LIST. This way addons can easily replace icons
ICON_TAG_LIST =
{
	[strlower(ICON_TAG_RAID_TARGET_STAR1)] = 1,
	[strlower(ICON_TAG_RAID_TARGET_STAR2)] = 1,
	[strlower(ICON_TAG_RAID_TARGET_CIRCLE1)] = 2,
	[strlower(ICON_TAG_RAID_TARGET_CIRCLE2)] = 2,
	[strlower(ICON_TAG_RAID_TARGET_DIAMOND1)] = 3,
	[strlower(ICON_TAG_RAID_TARGET_DIAMOND2)] = 3,
	[strlower(ICON_TAG_RAID_TARGET_TRIANGLE1)] = 4,
	[strlower(ICON_TAG_RAID_TARGET_TRIANGLE2)] = 4,
	[strlower(ICON_TAG_RAID_TARGET_MOON1)] = 5,
	[strlower(ICON_TAG_RAID_TARGET_MOON2)] = 5,
	[strlower(ICON_TAG_RAID_TARGET_SQUARE1)] = 6,
	[strlower(ICON_TAG_RAID_TARGET_SQUARE2)] = 6,
	[strlower(ICON_TAG_RAID_TARGET_CROSS1)] = 7,
	[strlower(ICON_TAG_RAID_TARGET_CROSS2)] = 7,
	[strlower(ICON_TAG_RAID_TARGET_SKULL1)] = 8,
	[strlower(ICON_TAG_RAID_TARGET_SKULL2)] = 8,
	[strlower(RAID_TARGET_1)] = 1,
	[strlower(RAID_TARGET_2)] = 2,
	[strlower(RAID_TARGET_3)] = 3,
	[strlower(RAID_TARGET_4)] = 4,
	[strlower(RAID_TARGET_5)] = 5,
	[strlower(RAID_TARGET_6)] = 6,
	[strlower(RAID_TARGET_7)] = 7,
	[strlower(RAID_TARGET_8)] = 8,
}

-- Arena Team Helper Function
function ArenaTeam_GetTeamSizeID(teamsizearg)
	local teamname, teamsize, id;
	for i=1, MAX_ARENA_TEAMS do
		teamname, teamsize = GetArenaTeam(i)
		if ( teamsizearg == teamsize ) then
			id = i;
		end
	end
	return id;
end

--
-- CastSequence support
--

local CastSequenceManager;
local CastSequenceTable = {};
local CastSequenceFreeList = {};

local function CreateCanonicalActions(entry, ...)
	entry.spells = {};
	entry.spellNames = {};
	entry.items = {};
	for i=1, select("#", ...) do
		local action = strlower(strtrim((select(i, ...))));
		if ( GetItemInfo(action) or select(3, SecureCmdItemParse(action)) ) then
			entry.items[i] = action;
			entry.spells[i] = strlower(GetItemSpell(action) or "");
			entry.spellNames[i] = entry.spells[i];
		else
			entry.spells[i] = action;
			entry.spellNames[i] = gsub(action, "!*(.*)", "%1");
		end
	end
end

local function SetCastSequenceIndex(entry, index)
	entry.index = index;
	entry.pending = nil;
end

local function ResetCastSequence(sequence, entry)
	SetCastSequenceIndex(entry, 1);
	CastSequenceFreeList[sequence] = entry;
	CastSequenceTable[sequence] = nil;
end

local function SetNextCastSequence(sequence, entry)
	if ( entry.index == #entry.spells ) then
		ResetCastSequence(sequence, entry);
	else
		SetCastSequenceIndex(entry, entry.index + 1);
	end
end

local function CastSequenceManager_OnEvent(self, event, ...)

	-- Reset all sequences when the player dies
	if ( event == "PLAYER_DEAD" ) then
		for sequence, entry in pairs(CastSequenceTable) do
			ResetCastSequence(sequence, entry);
		end
		return;
	end

	-- Increment sequences for spells which succeed.
	if ( event == "UNIT_SPELLCAST_SENT" or
	     event == "UNIT_SPELLCAST_SUCCEEDED" or
	     event == "UNIT_SPELLCAST_INTERRUPTED" or
	     event == "UNIT_SPELLCAST_FAILED" or
	     event == "UNIT_SPELLCAST_FAILED_QUIET" ) then
		local unit, name, rank = ...;

		if ( not name ) then
			-- This was a server-side only spell affecting the player somehow, don't do anything with cast sequencing, just bail.
			return;
		end

		if ( unit == "player" or unit == "pet" ) then
			name, rank = strlower(name), strlower(rank);
			local nameplus = name.."()";
			local fullname = name.."("..rank..")";
			for sequence, entry in pairs(CastSequenceTable) do
				local entryName = entry.spellNames[entry.index];
				if ( entryName == name or entryName == nameplus or entryName == fullname ) then
					if ( event == "UNIT_SPELLCAST_SENT" ) then
						entry.pending = 1;
					else
						entry.pending = nil;
						if ( event == "UNIT_SPELLCAST_SUCCEEDED" ) then
							SetNextCastSequence(sequence, entry);
						end
					end
				end
			end
		end
		return;
	end

	-- Handle reset events
	local reset = "";
	if ( event == "PLAYER_TARGET_CHANGED" ) then
		reset = "target";
	elseif ( event == "PLAYER_REGEN_ENABLED" ) then
		reset = "combat";
	end
	for sequence, entry in pairs(CastSequenceTable) do
		if ( strfind(entry.reset, reset, 1, true) ) then
			ResetCastSequence(sequence, entry);
		end
	end
end

local function CastSequenceManager_OnUpdate(self, elapsed)
	elapsed = self.elapsed + elapsed;
	if ( elapsed < 1 ) then
		self.elapsed = elapsed;
		return;
	end
	for sequence, entry in pairs(CastSequenceTable) do
		if ( entry.timeout ) then
			if ( elapsed >= entry.timeout ) then
				ResetCastSequence(sequence, entry);
			else
				entry.timeout = entry.timeout - elapsed;
			end
		end
	end
	self.elapsed = 0;
end

local function ExecuteCastSequence(sequence, target)
	if ( not CastSequenceManager ) then
		CastSequenceManager = CreateFrame("Frame");
		CastSequenceManager.elapsed = 0;
		CastSequenceManager:RegisterEvent("PLAYER_DEAD");
		CastSequenceManager:RegisterEvent("UNIT_SPELLCAST_SENT");
		CastSequenceManager:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
		CastSequenceManager:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
		CastSequenceManager:RegisterEvent("UNIT_SPELLCAST_FAILED");
		CastSequenceManager:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET");
		CastSequenceManager:RegisterEvent("PLAYER_TARGET_CHANGED");
		CastSequenceManager:RegisterEvent("PLAYER_REGEN_ENABLED");
		CastSequenceManager:SetScript("OnEvent", CastSequenceManager_OnEvent);
		CastSequenceManager:SetScript("OnUpdate", CastSequenceManager_OnUpdate);
	end

	local entry = CastSequenceTable[sequence];
	if ( not entry ) then
		entry = CastSequenceFreeList[sequence];
		if ( not entry ) then
			local reset, spells = strmatch(sequence, "^reset=([^%s]+)%s*(.*)");
			if ( not reset ) then
				spells = sequence;
			end
			entry = {};
			CreateCanonicalActions(entry, strsplit(",", spells));
			entry.reset = strlower(reset or "");
		end
		CastSequenceTable[sequence] = entry;
		entry.index = 1;
	end

	-- Don't do anything if this entry is still pending
	if ( entry.pending ) then
		return;
	end

	-- See if modified click restarts the sequence
	if ( (IsShiftKeyDown() and strfind(entry.reset, "shift", 1, true)) or
	     (IsControlKeyDown() and strfind(entry.reset, "ctrl", 1, true)) or
		 (IsAltKeyDown() and strfind(entry.reset, "alt", 1, true)) ) then
		SetCastSequenceIndex(entry, 1);
	end

	-- Reset the timeout each time the sequence is used
	local timeout = strmatch(entry.reset, "(%d+)");
	if ( timeout ) then
		entry.timeout = CastSequenceManager.elapsed + tonumber(timeout);
	end

	-- Execute the sequence!
	local item, spell = entry.items[entry.index], entry.spells[entry.index];
	if ( item ) then
		local name, bag, slot = SecureCmdItemParse(item);
		if ( slot ) then
			if ( name ) then
				spell = strlower(GetItemSpell(name) or "");
			else
				spell = "";
			end
			entry.spellNames[entry.index] = spell;
		end
		if ( IsEquippableItem(name) and not IsEquippedItem(name) ) then
			EquipItemByName(name);
		else
			SecureCmdUseItem(name, bag, slot, target);
		end
	else
		CastSpellByName(spell, target);
	end
	if ( spell == "" ) then
		SetNextCastSequence(sequence, entry);
	end
end

function QueryCastSequence(sequence)
	local index = 1;
	local item, spell;
	local entry = CastSequenceTable[sequence];
	if ( entry ) then
		if ( (IsShiftKeyDown() and strfind(entry.reset, "shift", 1, true)) or
			 (IsControlKeyDown() and strfind(entry.reset, "ctrl", 1, true)) or
			 (IsAltKeyDown() and strfind(entry.reset, "alt", 1, true)) ) then
			index = 1;
		else
			index = entry.index;
		end
		item, spell = entry.items[index], entry.spells[index];
	else
		entry = CastSequenceFreeList[sequence];
		if ( entry ) then
			item, spell = entry.items[index], entry.spells[index];
		else
			local reset, spells = strmatch(sequence, "^reset=([^%s]+)%s*(.*)");
			if ( not reset ) then
				spells = sequence;
			end
			local action = strlower(strtrim((strsplit(",", spells))));
			if ( GetItemInfo(action) or select(3, SecureCmdItemParse(action)) ) then
				item, spell = action, strlower(GetItemSpell(action) or "");
			else
				item, spell = nil, action;
			end
		end
	end
	if ( item ) then
		local name, bag, slot = SecureCmdItemParse(item);
		if ( slot ) then
			if ( name ) then
				spell = strlower(GetItemSpell(name) or "");
			else
				spell = "";
			end
		end
	end
	return index, item, spell;
end


local CastRandomManager;
local CastRandomTable = {};

local function CastRandomManager_OnEvent(self, event, ...)
	local unit, name, rank = ...;

	if ( not name ) then
		-- This was a server-side only spell affecting the player somehow, don't do anything with cast sequencing, just bail.
		return;
	end

	if ( unit == "player" ) then
		name, rank = strlower(name), strlower(rank);
		local nameplus = name.."()";
		local fullname = name.."("..rank..")";
		for sequence, entry in pairs(CastRandomTable) do
			if ( entry.pending and entry.value ) then
				local entryName = strlower(entry.value);
				if ( entryName == name or entryName == nameplus or entryName == fullname ) then
					entry.pending = nil;
					if ( event == "UNIT_SPELLCAST_SUCCEEDED" ) then
						entry.value = nil;
					end
				end
			end
		end
	end
end

local function ExecuteCastRandom(actions)
	if ( not CastRandomManager ) then
		CastRandomManager = CreateFrame("Frame");
		CastRandomManager:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
		CastRandomManager:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
		CastRandomManager:RegisterEvent("UNIT_SPELLCAST_FAILED");
		CastRandomManager:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET");
		CastRandomManager:SetScript("OnEvent", CastRandomManager_OnEvent);
	end

	local entry = CastRandomTable[actions];
	if ( not entry ) then
		entry = {};
		CreateCanonicalActions(entry, strsplit(",", actions));
		CastRandomTable[actions] = entry;
	end
	if ( not entry.value ) then
		entry.value = strtrim(GetRandomArgument(strsplit(",", actions)));
	end
	entry.pending = true;
	return entry.value;
end

function GetRandomArgument(...)
	return (select(random(select("#", ...)), ...));
end

-- Slash commands that are protected from tampering
local SecureCmdList = { };

function IsSecureCmd(command)
	command = strupper(command);
	-- first check the hash table
	if ( hash_SecureCmdList[command] ) then
		return true;
	end

	for index, value in pairs(SecureCmdList) do
		local i = 1;
		local cmdString = _G["SLASH_"..index..i];
		while ( cmdString ) do
			cmdString = strupper(cmdString);
			if ( cmdString == command ) then
				return true;
			end
			i = i + 1;
			cmdString = _G["SLASH_"..index..i];
		end
	end
end

function SecureCmdItemParse(item)
	if ( not item ) then
		return nil, nil, nil;
	end
	local bag, slot = strmatch(item, "^(%d+)%s+(%d+)$");
	if ( not bag ) then
		slot = strmatch(item, "^(%d+)$");
	end
	if ( bag ) then
		item = GetContainerItemLink(bag, slot);
	elseif ( slot ) then
		item = GetInventoryItemLink("player", slot);
	end
	return item, bag, slot;
end

function SecureCmdUseItem(name, bag, slot, target)
	if ( bag ) then
		UseContainerItem(bag, slot, target);
	elseif ( slot ) then
		UseInventoryItem(slot, target);
	else
		UseItemByName(name, target);
	end
end

SecureCmdList["STARTATTACK"] = function(msg)
	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		if ( not target  or target == "target" ) then
			target = action;
		end
		StartAttack(target);
	end
end

SecureCmdList["STOPATTACK"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		StopAttack();
	end
end

SecureCmdList["CAST"] = function(msg)
    local action, target = SecureCmdOptionParse(msg);
    if ( action ) then
		local name, bag, slot = SecureCmdItemParse(action);
		if ( slot or GetItemInfo(name) ) then
			SecureCmdUseItem(name, bag, slot, target);
		else
			CastSpellByName(action, target);
		end
    end
end
SecureCmdList["USE"] = SecureCmdList["CAST"];

SecureCmdList["CASTRANDOM"] = function(msg)
    local actions, target = SecureCmdOptionParse(msg);
	if ( actions ) then
		local action = ExecuteCastRandom(actions);
		local name, bag, slot = SecureCmdItemParse(action);
		if ( slot or GetItemInfo(name) ) then
			SecureCmdUseItem(name, bag, slot, target);
		else
			CastSpellByName(action, target);
		end
	end
end
SecureCmdList["USERANDOM"] = SecureCmdList["CASTRANDOM"];

SecureCmdList["CASTSEQUENCE"] = function(msg)
	local sequence, target = SecureCmdOptionParse(msg);
	if ( sequence ) then
		ExecuteCastSequence(sequence, target);
	end
end

SecureCmdList["STOPCASTING"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		SpellStopCasting();
	end
end

SecureCmdList["CANCELAURA"] = function(msg)
	local spell = SecureCmdOptionParse(msg);
	if ( spell ) then
		local name, rank = strmatch(spell, "([^(]+)[(]([^)]+)[)]");
		if ( not name ) then
			name = spell;
		end
		CancelUnitBuff("player", name, rank);
	end
end

SecureCmdList["CANCELFORM"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		CancelShapeshiftForm();
	end
end

SecureCmdList["EQUIP"] = function(msg)
	local item = SecureCmdOptionParse(msg);
	if ( item ) then
		EquipItemByName((SecureCmdItemParse(item)));
	end
end

SecureCmdList["EQUIP_TO_SLOT"] = function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		local slot, item = strmatch(action, "^(%d+)%s+(.*)");
		if ( item ) then
			if ( PaperDoll_IsEquippedSlot(slot) ) then
				EquipItemByName(SecureCmdItemParse(item), slot);
			else
				-- user specified a bad slot number (slot that you can't equip an item to)
				ChatFrame_DisplayUsageError(format(ERROR_SLASH_EQUIP_TO_SLOT, EQUIPPED_FIRST, EQUIPPED_LAST));
			end
		elseif ( slot ) then
			-- user specified a slot but not an item
			ChatFrame_DisplayUsageError(format(ERROR_SLASH_EQUIP_TO_SLOT, EQUIPPED_FIRST, EQUIPPED_LAST));
		end
	end
end

SecureCmdList["CHANGEACTIONBAR"] = function(msg)
	local page = SecureCmdOptionParse(msg);
	if ( page and page ~= "" ) then
		page = tonumber(page);
		if (page and page >= 1 and page <= NUM_ACTIONBAR_PAGES) then
			ChangeActionBarPage(page);
		else
			ChatFrame_DisplayUsageError(format(ERROR_SLASH_CHANGEACTIONBAR, 1, NUM_ACTIONBAR_PAGES));
		end
	end
end

SecureCmdList["SWAPACTIONBAR"] = function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		local a, b = strmatch(action, "(%d+)%s+(%d+)");
		if ( a and b ) then
			a = tonumber(a);
			b = tonumber(b);
			if ( ( a and a >= 1 and a <= NUM_ACTIONBAR_PAGES ) and ( b and b >= 1 and b <= NUM_ACTIONBAR_PAGES ) ) then
				if ( GetActionBarPage() == a ) then
					ChangeActionBarPage(b);
				else
					ChangeActionBarPage(a);
				end
			else
				ChatFrame_DisplayUsageError(format(ERROR_SLASH_SWAPACTIONBAR, 1, NUM_ACTIONBAR_PAGES));
			end
		end
	end
end

SecureCmdList["TARGET"] = function(msg)
	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		if ( not target or target == "target" ) then
			target = action;
		end
		TargetUnit(target);
	end
end

SecureCmdList["TARGET_EXACT"] = function(msg)
	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		if ( not target or target == "target" ) then
			target = action;
		end
		TargetUnit(target, 1);
	end
end

SecureCmdList["TARGET_NEAREST_ENEMY"] = function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetNearestEnemy(action);
	end
end

SecureCmdList["TARGET_NEAREST_ENEMY_PLAYER"] = function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetNearestEnemyPlayer(action);
	end
end

SecureCmdList["TARGET_NEAREST_FRIEND"] = function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetNearestFriend(action);
	end
end

SecureCmdList["TARGET_NEAREST_FRIEND_PLAYER"] = function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetNearestFriendPlayer(action);
	end
end

SecureCmdList["TARGET_NEAREST_PARTY"] = function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetNearestPartyMember(action);
	end
end

SecureCmdList["TARGET_NEAREST_RAID"] = function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetNearestRaidMember(action);
	end
end

SecureCmdList["CLEARTARGET"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		ClearTarget();
	end
end

SecureCmdList["TARGET_LAST_TARGET"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		TargetLastTarget();
	end
end

SecureCmdList["TARGET_LAST_ENEMY"] = function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetLastEnemy(action);
	end
end

SecureCmdList["TARGET_LAST_FRIEND"] = function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetLastFriend(action);
	end
end

SecureCmdList["ASSIST"] = function(msg)
	if ( msg == "" ) then
		AssistUnit();
	else
		local action, target = SecureCmdOptionParse(msg);
		if ( action ) then
			if ( not target ) then
				target = action;
			end
			AssistUnit(target);
		end
	end
end

SecureCmdList["FOCUS"] = function(msg)
	if ( msg == "" ) then
		FocusUnit();
	else
		local action, target = SecureCmdOptionParse(msg);
		if ( action ) then
			if ( not target or target == "focus" ) then
				target = action;
			end
			FocusUnit(target);
		end
	end
end

SecureCmdList["CLEARFOCUS"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		ClearFocus();
	end
end

SecureCmdList["CLEARMAINTANK"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		ClearPartyAssignment("MAINTANK");
	end
end

SecureCmdList["MAINTANKON"] = function(msg)
	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		if ( not target ) then
			target = action;
		end
		if ( target == "" ) then
			target = "target";
		end
		SetPartyAssignment("MAINTANK", target);
	end
end

SecureCmdList["MAINTANKOFF"] = function(msg)
	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		if ( not target ) then
			target = action;
		end
		if ( target == "" ) then
			target = "target";
		end
		ClearPartyAssignment("MAINTANK", target);
	end
end

SecureCmdList["CLEARMAINASSIST"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		ClearPartyAssignment("MAINASSIST");
	end
end

SecureCmdList["MAINASSISTON"] = function(msg)
	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		if ( not target ) then
			target = action;
		end
		if ( target == "" ) then
			target = "target";
		end
		SetPartyAssignment("MAINASSIST", target);
	end
end

SecureCmdList["MAINASSISTOFF"] = function(msg)
	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		if ( not target ) then
			target = action;
		end
		if ( target == "" ) then
			target = "target";
		end
		ClearPartyAssignment("MAINASSIST", target);
	end
end

SecureCmdList["DUEL"] = function(msg)
	StartDuel(msg)
end

SecureCmdList["DUEL_CANCEL"] = function(msg)
	CancelDuel()
end

SecureCmdList["PET_ATTACK"] = function(msg)
	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		if ( not target or target == "pettarget" ) then
			target = action;
		end
		PetAttack(target);
	end
end

SecureCmdList["PET_FOLLOW"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		PetFollow();
	end
end

SecureCmdList["PET_STAY"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		PetWait();
	end
end

SecureCmdList["PET_PASSIVE"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		PetPassiveMode();
	end
end

SecureCmdList["PET_DEFENSIVE"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		PetDefensiveMode();
	end
end

SecureCmdList["PET_AGGRESSIVE"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		PetAggressiveMode();
	end
end

SecureCmdList["PET_AUTOCASTON"] = function(msg)
	local spell = SecureCmdOptionParse(msg);
	if ( spell ) then
		EnableSpellAutocast(spell);
	end
end

SecureCmdList["PET_AUTOCASTOFF"] = function(msg)
	local spell = SecureCmdOptionParse(msg);
	if ( spell ) then
		DisableSpellAutocast(spell);
	end
end

SecureCmdList["PET_AUTOCASTTOGGLE"] = function(msg)
	local spell = SecureCmdOptionParse(msg);
	if ( spell ) then
		ToggleSpellAutocast(spell);
	end
end

SecureCmdList["STOPMACRO"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		StopMacro();
	end
end

SecureCmdList["CLICK"] = function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action and action ~= "" ) then
		local name, mouseButton, down = strmatch(action, "([^%s]+)%s+([^%s]+)%s*(.*)");
		if ( not name ) then
			name = action;
		end
		local button = GetClickFrame(name);
		if ( button and button:IsObjectType("Button") ) then
			button:Click(mouseButton, down);
		end
	end
end

-- Pre-populate the secure command hash table
for index, value in pairs(SecureCmdList) do
	local i = 1;
	local cmdString = _G["SLASH_"..index..i];
	while ( cmdString ) do
		cmdString = strupper(cmdString);
		hash_SecureCmdList[cmdString] = value;	-- add to hash
		i = i + 1;
		cmdString = _G["SLASH_"..index..i];
	end
end

-- Slash commands
SlashCmdList = { };

SlashCmdList["CONSOLE"] = function(msg)
	ConsoleExec(msg);
end

SlashCmdList["CHATLOG"] = function(msg)
	local info = ChatTypeInfo["SYSTEM"];
	if ( LoggingChat() ) then
		LoggingChat(false);
		DEFAULT_CHAT_FRAME:AddMessage(CHATLOGDISABLED, info.r, info.g, info.b, info.id);
	else
		LoggingChat(true);
		DEFAULT_CHAT_FRAME:AddMessage(CHATLOGENABLED, info.r, info.g, info.b, info.id);
	end
end

SlashCmdList["COMBATLOG"] = function(msg)
	local info = ChatTypeInfo["SYSTEM"];
	if ( LoggingCombat() ) then
		LoggingCombat(false);
		DEFAULT_CHAT_FRAME:AddMessage(COMBATLOGDISABLED, info.r, info.g, info.b, info.id);
	else
		LoggingCombat(true);
		DEFAULT_CHAT_FRAME:AddMessage(COMBATLOGENABLED, info.r, info.g, info.b, info.id);
	end
end

SlashCmdList["INVITE"] = function(msg)
	if(msg == "") then
		msg = UnitName("target");
	end
	if( msg and (strlen(msg) > MAX_CHARACTER_NAME_BYTES) ) then
		ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	InviteUnit(msg);
end

SlashCmdList["UNINVITE"] = function(msg)
	if(msg == "") then
		msg = UnitName("target");
	end
	UninviteUnit(msg);
end

SlashCmdList["PROMOTE"] = function(msg)
	PromoteToLeader(msg);
end

SlashCmdList["REPLY"] = function(msg, editBox)
	local lastTell = ChatEdit_GetLastTellTarget();
	if ( lastTell ~= "" ) then
		SendChatMessage(msg, "WHISPER", editBox.language, lastTell);
	else
		-- error message
	end
end

SlashCmdList["HELP"] = function(msg)
	ChatFrame_DisplayHelpText(DEFAULT_CHAT_FRAME);
end

SlashCmdList["MACROHELP"] = function(msg)
	ChatFrame_DisplayMacroHelpText(DEFAULT_CHAT_FRAME);
end

SlashCmdList["TIME"] = function(msg)
	ChatFrame_DisplayGameTime(DEFAULT_CHAT_FRAME);
end

SlashCmdList["PLAYED"] = function(msg)
	RequestTimePlayed();
end

SlashCmdList["FOLLOW"] = function(msg)
	FollowUnit(msg);
end

SlashCmdList["TRADE"] = function(msg)
	InitiateTrade("target");
end

SlashCmdList["INSPECT"] = function(msg)
	InspectUnit("target");
end

SlashCmdList["LOGOUT"] = function(msg)
	Logout();
end

SlashCmdList["QUIT"] = function(msg)
	Quit();
end

SlashCmdList["JOIN"] = 	function(msg)
	local name = gsub(msg, "%s*([^%s]+).*", "%1");
	local password = gsub(msg, "%s*([^%s]+)%s*(.*)", "%2");
	if(strlen(name) <= 0) then
		local joinhelp = CHAT_JOIN_HELP;
		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(joinhelp, info.r, info.g, info.b, info.id);
	else
		local zoneChannel, channelName = JoinPermanentChannel(name, password, DEFAULT_CHAT_FRAME:GetID(), 1);
		if ( channelName ) then
			name = channelName;
		end
		if ( not zoneChannel ) then
			local info = ChatTypeInfo["CHANNEL"];
			DEFAULT_CHAT_FRAME:AddMessage(CHAT_INVALID_NAME_NOTICE, info.r, info.g, info.b, info.id);
			return;
		end

		local i = 1;
		while ( DEFAULT_CHAT_FRAME.channelList[i] ) do
			i = i + 1;
		end
		DEFAULT_CHAT_FRAME.channelList[i] = name;
		DEFAULT_CHAT_FRAME.zoneChannelList[i] = zoneChannel;
	end
end

SlashCmdList["LEAVE"] = function(msg)
	local name = strmatch(msg, "%s*([^%s]+)");
	if ( name ) then
		local nameNum = tonumber(name);
		if ( nameNum and nameNum > MAX_WOW_CHAT_CHANNELS ) then
			BNLeaveConversation(nameNum - MAX_WOW_CHAT_CHANNELS);
		else
			LeaveChannelByName(name);
		end
	end
	
end

SlashCmdList["LIST_CHANNEL"] = function(msg)
	local name = strmatch(msg, "%s*([^%s]+)");
	if ( name ) then
		local nameNum = tonumber(name);
		if ( nameNum and nameNum > MAX_WOW_CHAT_CHANNELS ) then
			BNListConversation(nameNum - MAX_WOW_CHAT_CHANNELS);
		else
			ListChannelByName(name);
		end	
	else
		ListChannels();
	end
end

SlashCmdList["CHAT_HELP"] = 
	function(msg)
		ChatFrame_DisplayChatHelp(DEFAULT_CHAT_FRAME)
	end

SlashCmdList["CHAT_PASSWORD"] =
	function(msg)
		local name = gsub(msg, "%s*([^%s]+).*", "%1");
		local password = gsub(msg, "%s*([^%s]+)%s*(.*)", "%2");
		SetChannelPassword(name, password);
	end

SlashCmdList["CHAT_OWNER"] =
	function(msg)
		local channel = gsub(msg, "%s*([^%s]+).*", "%1");
		local newOwner = gsub(msg, "%s*([^%s]+)%s*(.*)", "%2");
		if ( not channel or not newOwner ) then
			return;
		end
		local newOwnerLen = strlen(newOwner);
		if ( newOwnerLen > MAX_CHARACTER_NAME_BYTES ) then
			ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
			return;
		end
		if ( strlen(channel) > 0 ) then
			if ( newOwnerLen > 0 ) then
				SetChannelOwner(channel, newOwner);
			else
				DisplayChannelOwner(channel);
			end
		end
	end

SlashCmdList["CHAT_MODERATOR"] = 
	function(msg)
		local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
		if ( not channel or not player ) then
			return;
		end
		if ( strlen(player) > MAX_CHARACTER_NAME_BYTES ) then
			ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
			return;
		end
		ChannelModerator(channel, player);
	end

SlashCmdList["CHAT_UNMODERATOR"] =
	function(msg)
		local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
		if ( not channel or not player ) then
			return;
		end
		if ( strlen(player) > MAX_CHARACTER_NAME_BYTES ) then
			ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
			return;
		end
		if ( channel and player ) then
			ChannelUnmoderator(channel, player);
		end
	end

SlashCmdList["CHAT_MUTE"] =
	function(msg)
		local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
		if ( not channel or not player ) then
			return;
		end
		if ( strlen(player) > MAX_CHARACTER_NAME_BYTES ) then
			ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
			return;
		end
		if ( channel and player ) then
			ChannelMute(channel, player);
		end
	end

SlashCmdList["CHAT_UNMUTE"] =
	function(msg)
		local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
		if ( not channel or not player ) then
			return;
		end
		if ( strlen(player) > MAX_CHARACTER_NAME_BYTES ) then
			ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
			return;
		end
		if ( channel and player ) then
			ChannelUnmute(channel, player);
		end
	end

SlashCmdList["CHAT_CINVITE"] =
	function(msg)
		local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
		if ( not channel or not player ) then
			return;
		end
		
		if ( channel and player ) then
			if ( tonumber(channel) and tonumber(channel) > MAX_WOW_CHAT_CHANNELS ) then
				--We have a BNet conversation.
				channel = tonumber(channel) - MAX_WOW_CHAT_CHANNELS;
				if ( BNGetConversationInfo(channel) ) then
					local presenceID = BNet_GetPresenceID(player);
					if ( presenceID ) then
						BNInviteToConversation(channel, presenceID);
					end
				end
			else
				if ( strlen(player) > MAX_CHARACTER_NAME_BYTES ) then
					ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
					return;
				end
				ChannelInvite(channel, player);
			end
		end
	end

SlashCmdList["CHAT_KICK"] =
	function(msg)
		local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
		if ( not channel or not player ) then
			return;
		end
		if ( strlen(player) > MAX_CHARACTER_NAME_BYTES ) then
			ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
			return;
		end
		if ( channel and player ) then
			ChannelKick(channel, player);
		end
	end

SlashCmdList["CHAT_BAN"] =
	function(msg)
		local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
		if ( not channel or not player ) then
			return;
		end
		if ( strlen(player) > MAX_CHARACTER_NAME_BYTES ) then
			ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
			return;
		end
		if ( channel and player ) then
			ChannelBan(channel, player);
		end
	end

SlashCmdList["CHAT_UNBAN"] =
	function(msg)
		local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
		if ( not channel or not player ) then
			return;
		end
		if ( strlen(player) > MAX_CHARACTER_NAME_BYTES ) then
			ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
			return;
		end
		if ( channel and player ) then
			ChannelUnban(channel, player);
		end
	end

SlashCmdList["CHAT_ANNOUNCE"] =
	function(msg)
		local channel = strmatch(msg, "%s*([^%s]+)");
		if ( channel ) then
			ChannelToggleAnnouncements(channel);
		end
	end

SlashCmdList["TEAM_INVITE"] = function(msg)
	if ( msg ~= "" ) then
		local team, name = strmatch(msg, "^(%d+)[%w+%d+]*%s+(.*)");
		if ( team and name ) then
			if ( strlen(name) > MAX_CHARACTER_NAME_BYTES ) then
				ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
				return;
			end
			team = tonumber(team);
			if ( team ) then
				local teamsizeID = ArenaTeam_GetTeamSizeID(team);
				if ( teamsizeID ) then
					ArenaTeamInviteByName(teamsizeID, name);
				end
				return;
			end
		end
	end
	ChatFrame_DisplayUsageError(ERROR_SLASH_TEAM_INVITE);
end

SlashCmdList["TEAM_QUIT"] = function(msg)
	if ( msg ~= "" ) then
		local team = strmatch(msg, "^(%d+)[%w+%d+]*");
		if ( team ) then
			team = tonumber(team);
			if ( team ) then
				local teamsizeID = ArenaTeam_GetTeamSizeID(team);
				if ( teamsizeID ) then
					ArenaTeamLeave(teamsizeID);
				end
				return;
			end
		end
	end
	ChatFrame_DisplayUsageError(ERROR_SLASH_TEAM_QUIT);
end

SlashCmdList["TEAM_UNINVITE"] = function(msg)
	if ( msg ~= "" ) then
		local team, name = strmatch(msg, "^(%d+)[%w+%d+]*%s+(.*)");
		if ( team and name ) then
			if ( strlen(name) > MAX_CHARACTER_NAME_BYTES ) then
				ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
				return;
			end
			team = tonumber(team);
			if ( team ) then
				local teamsizeID = ArenaTeam_GetTeamSizeID(team);
				if ( teamsizeID ) then
					ArenaTeamUninviteByName(teamsizeID, name);
				end
				return;
			end
		end
	end
	ChatFrame_DisplayUsageError(ERROR_SLASH_TEAM_UNINVITE);
end

SlashCmdList["TEAM_CAPTAIN"] = function(msg)
	if ( msg ~= "" ) then
		local team, name = strmatch(msg, "^(%d+)[%w+%d+]*%s+(.*)");
		if ( team and name ) then
			if ( strlen(name) > MAX_CHARACTER_NAME_BYTES ) then
				ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
				return;
			end
			team = tonumber(team);
			if ( team ) then
				local teamsizeID = ArenaTeam_GetTeamSizeID(team);
				if ( teamsizeID ) then
					ArenaTeamSetLeaderByName(teamsizeID, name);
				end
				return;
			end
		end
	end
	ChatFrame_DisplayUsageError(ERROR_SLASH_TEAM_CAPTAIN);
end

SlashCmdList["TEAM_DISBAND"] = function(msg)
	if ( msg ~= "" ) then
		local team = strmatch(msg, "^(%d+)[%w+%d+]*");
		if ( team ) then
			team = tonumber(team);
			if ( team ) then
				local teamsizeID = ArenaTeam_GetTeamSizeID(team);
				if ( teamsizeID ) then
					local teamName, teamSize = GetArenaTeam(teamsizeID);
					for i = 1, teamSize * 2 do
						name, rank = GetArenaTeamRosterInfo(teamsizeID, i);
						if ( rank == 0 ) then
							if ( name == UnitName("player") ) then
								local dialog = StaticPopup_Show("CONFIRM_TEAM_DISBAND", teamName);
								if ( dialog ) then
									dialog.data = teamsizeID;
								end
							end
							break;
						end
					end
				end
				return;
			end
		end
	end
	ChatFrame_DisplayUsageError(ERROR_SLASH_TEAM_DISBAND);
end

SlashCmdList["GUILD_INVITE"] = function(msg)
	if(msg == "") then
		msg = UnitName("target");
	end
	if( msg and (strlen(msg) > MAX_CHARACTER_NAME_BYTES) ) then
		ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	GuildInvite(msg);
end

SlashCmdList["GUILD_UNINVITE"] = function(msg)
	if(msg == "") then
		msg = UnitName("target");
	end
	if( msg and (strlen(msg) > MAX_CHARACTER_NAME_BYTES) ) then
		ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	GuildUninvite(msg);
end

SlashCmdList["GUILD_PROMOTE"] = function(msg)
	if( msg and (strlen(msg) > MAX_CHARACTER_NAME_BYTES) ) then
		ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	GuildPromote(msg);
end

SlashCmdList["GUILD_DEMOTE"] = function(msg)
	if( msg and (strlen(msg) > MAX_CHARACTER_NAME_BYTES) ) then
		ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	GuildDemote(msg);
end

SlashCmdList["GUILD_LEADER"] = function(msg)
	if( msg and (strlen(msg) > MAX_CHARACTER_NAME_BYTES) ) then
		ChatFrame_DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	GuildSetLeader(msg);
end

SlashCmdList["GUILD_MOTD"] = function(msg)
	GuildSetMOTD(msg)
end

SlashCmdList["GUILD_LEAVE"] = function(msg)
	GuildLeave();
end

SlashCmdList["GUILD_DISBAND"] = function(msg)
	if ( IsGuildLeader() ) then
		StaticPopup_Show("CONFIRM_GUILD_DISBAND");
	end
end

SlashCmdList["GUILD_INFO"] = function(msg)
	GuildInfo();
end

SlashCmdList["GUILD_ROSTER"] = function(msg)
	if ( IsInGuild() ) then
		PanelTemplates_SetTab(FriendsFrame, 3);
		FriendsFrame_ShowSubFrame("GuildFrame");
		ShowUIPanel(FriendsFrame);
	end
end

--SlashCmdList["GUILD_HELP"] = function(msg)
--	ChatFrame_DisplayGuildHelp(DEFAULT_CHAT_FRAME);
--end

SlashCmdList["CHAT_AFK"] = function(msg)
	SendChatMessage(msg, "AFK");
end

SlashCmdList["CHAT_DND"] = function(msg)
	SendChatMessage(msg, "DND");
end

SlashCmdList["WHO"] = function(msg)
	if ( msg == "" ) then
		msg = WhoFrame_GetDefaultWhoCommand();
		ShowWhoPanel();
	end
	WhoFrameEditBox:SetText(msg);
	SendWho(msg);
end

SlashCmdList["CHANNEL"] = function(msg, editBox)
	SendChatMessage(msg, "CHANNEL", editBox.language, editBox:GetAttribute("channelTarget"));
end

SlashCmdList["FRIENDS"] = function(msg)
	local player, note = strmatch(msg, "%s*([^%s]+)%s*(.*)");
	if ( player ~= "" or UnitIsPlayer("target") ) then
		AddOrRemoveFriend(player, note);
	else
		ToggleFriendsPanel();
	end
end

SlashCmdList["REMOVEFRIEND"] = function(msg)
	RemoveFriend(msg);
end

SlashCmdList["IGNORE"] = function(msg)
	if ( msg ~= "" or UnitIsPlayer("target") ) then
		local presenceID = BNet_GetPresenceID(msg);
		if ( presenceID ) then
			if ( BNIsFriend(presenceID) ) then
				SendSystemMessage(ERR_CANNOT_IGNORE_BN_FRIEND);
			else
				BNSetToonBlocked(presenceID, not BNIsToonBlocked(presenceID));
			end
		else
			AddOrDelIgnore(msg);
		end
	else
		ToggleIgnorePanel();
	end
end

SlashCmdList["UNIGNORE"] = function(msg)
	if ( msg ~= "" or UnitIsPlayer("target") ) then
		DelIgnore(msg);
	else
		ToggleIgnorePanel();
	end
end

SlashCmdList["SCRIPT"] = function(msg)
	RunScript(msg);
end

SlashCmdList["LOOT_FFA"] = function(msg)
	SetLootMethod("freeforall");
end

SlashCmdList["LOOT_ROUNDROBIN"] = function(msg)
	SetLootMethod("roundrobin");
end

SlashCmdList["LOOT_MASTER"] = function(msg)
	SetLootMethod("master", msg);
end

SlashCmdList["LOOT_GROUP"] = function(msg)
	SetLootMethod("group");
end

SlashCmdList["LOOT_NEEDBEFOREGREED"] = function(msg)
	SetLootMethod("needbeforegreed");
end

SlashCmdList["LOOT_SETTHRESHOLD"] = function(msg)
	if ( not msg ) then
		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(format(ERROR_SLASH_LOOT_SETTHRESHOLD, MIN_LOOT_THRESHOLD, MAX_LOOT_THRESHOLD), info.r, info.g, info.b, info.id);
		return;
	end

	local MIN_LOOT_THRESHOLD = 2;	-- "good" item quality
	local MAX_LOOT_THRESHOLD = 6;	-- "artifact" item quality

	local threshold = strmatch(msg, "(%d+)");
	threshold = tonumber(threshold);
	if ( threshold and threshold >= MIN_LOOT_THRESHOLD and threshold <= MAX_LOOT_THRESHOLD ) then
		-- try to match a threshold number first
		SetLootThreshold(threshold);
	else
		msg = strupper(msg);
		if ( msg == strupper(ITEM_QUALITY2_DESC) ) then
			SetLootThreshold(2);
		elseif ( msg == strupper(ITEM_QUALITY3_DESC) ) then
			SetLootThreshold(3);
		elseif ( msg == strupper(ITEM_QUALITY4_DESC) ) then
			SetLootThreshold(4);
		elseif ( msg == strupper(ITEM_QUALITY5_DESC) ) then
			SetLootThreshold(5);
		elseif ( msg == strupper(ITEM_QUALITY6_DESC) ) then
			SetLootThreshold(6);
		else
			-- no matches found
			local info = ChatTypeInfo["SYSTEM"];
			DEFAULT_CHAT_FRAME:AddMessage(format(ERROR_SLASH_LOOT_SETTHRESHOLD, MIN_LOOT_THRESHOLD, MAX_LOOT_THRESHOLD), info.r, info.g, info.b, info.id);
		end
	end
end

SlashCmdList["RANDOM"] = function(msg)
	local num1 = gsub(msg, "(%s*)(%d+)(.*)", "%2", 1);
	local rest = gsub(msg, "(%s*)(%d+)(.*)", "%3", 1);
	local num2 = "";
	local numSubs;
	if ( strlen(rest) > 0 ) then
		num2, numSubs = gsub(msg, "(%s*)(%d+)([-%s]+)(%d+)(.*)", "%4", 1);
		if ( numSubs == 0 ) then
			num2 = "";
		end
	end
	if ( num1 == "" and num2 == "" ) then
		RandomRoll("1", "100");
	elseif ( num2 == "" ) then
		RandomRoll("1", num1);
	else
		RandomRoll(num1, num2);
	end
end

SlashCmdList["MACRO"] = function(msg)
	ShowMacroFrame();
end

SlashCmdList["PVP"] = function(msg)
	TogglePVP();
end

SlashCmdList["RAID_INFO"] = function(msg)
	RaidFrame.slashCommand = 1;
	if ( ( GetNumSavedInstances() > 0 ) and not RaidInfoFrame:IsShown() ) then
		ToggleFriendsFrame(5);
		RaidInfoFrame:Show();
	elseif ( not RaidFrame:IsShown() ) then
		ToggleFriendsFrame(5);
	end
end

SlashCmdList["READYCHECK"] = function(msg)
	if ( ((IsRaidLeader() or IsRaidOfficer()) and GetNumRaidMembers() > 0) or (IsPartyLeader() and GetNumPartyMembers() > 0) ) then
		DoReadyCheck();
	end
end

--[[All of this information is obtainable through the armory now.
SlashCmdList["SAVEGUILDROSTER"] = function(msg)
	SaveGuildRoster();
end]]

SlashCmdList["DUNGEONS"] = function(msg)
	ToggleLFDParentFrame();
end

SlashCmdList["RAIDBROWSER"] = function(msg)
	ToggleLFRParentFrame();
end

SlashCmdList["BENCHMARK"] = function(msg)
	SetTaxiBenchmarkMode(msg);
end

SlashCmdList["DISMOUNT"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		Dismount();
	end
end

SlashCmdList["LEAVEVEHICLE"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		VehicleExit();
	end
end

SlashCmdList["RESETCHAT"] = function(msg)
	FCF_ResetAllWindows();
end

SlashCmdList["ENABLE_ADDONS"] = function(msg)
	EnableAllAddOns();
	ReloadUI();
end

SlashCmdList["DISABLE_ADDONS"] = function(msg)
	DisableAllAddOns();
	ReloadUI();
end

SlashCmdList["STOPWATCH"] = function(msg)
	if ( not IsAddOnLoaded("Blizzard_TimeManager") ) then
		UIParentLoadAddOn("Blizzard_TimeManager");
	end
	if ( StopwatchFrame ) then
		local text = strmatch(msg, "%s*([^%s]+)%s*");
		if ( text ) then
			text = strlower(text);

			-- in any of the following cases, the stopwatch will be shown
			StopwatchFrame:Show();

			-- try to match a command
			local function MatchCommand(param, text)
				local i, compare;
				i = 1;
				repeat
					compare = _G[param..i];
					if ( compare and compare == text ) then
						return true;
					end
					i = i + 1;
				until ( not compare );
				return false;
			end
			if ( MatchCommand("SLASH_STOPWATCH_PARAM_PLAY", text) ) then
				Stopwatch_Play();
				return;
			end
			if ( MatchCommand("SLASH_STOPWATCH_PARAM_PAUSE", text) ) then
				Stopwatch_Pause();
				return;
			end
			if ( MatchCommand("SLASH_STOPWATCH_PARAM_STOP", text) ) then
				Stopwatch_Clear();
				return;
			end
			-- try to match a countdown
			-- kinda ghetto, but hey, it's simple and it works =)
			local hour, minute, second = strmatch(msg, "(%d+):(%d+):(%d+)");
			if ( not hour ) then
				minute, second = strmatch(msg, "(%d+):(%d+)");
				if ( not minute ) then
					second = strmatch(msg, "(%d+)");
				end
			end
			Stopwatch_StartCountdown(tonumber(hour), tonumber(minute), tonumber(second));
		else
			Stopwatch_Toggle();
		end
	end
end

SlashCmdList["CALENDAR"] = function(msg)
	if ( not IsAddOnLoaded("Blizzard_Calendar") ) then
		UIParentLoadAddOn("Blizzard_Calendar");
	end
	if ( Calendar_Toggle ) then
		Calendar_Toggle();
	end
end

SlashCmdList["ACHIEVEMENTUI"] = function(msg)
	ToggleAchievementFrame();
end

SlashCmdList["EQUIP_SET"] = function(msg)
	local set = SecureCmdOptionParse(msg);
	if ( set and set ~= "" ) then
		EquipmentManager_EquipSet(set);
	end
end

SlashCmdList["SET_TITLE"] = function(msg)
	local name = SecureCmdOptionParse(msg);
	if ( name and name ~= "") then
		if(not SetTitleByName(name)) then
			UIErrorsFrame:AddMessage(TITLE_DOESNT_EXIST, 1.0, 0.1, 0.1, 1.0);
		end
	else
		SetCurrentTitle(-1)
	end
end

SlashCmdList["USE_TALENT_SPEC"] = function(msg)
	local group = SecureCmdOptionParse(msg);
	if ( group ) then
		local groupNumber = tonumber(group);
		if ( groupNumber ) then
			SetActiveTalentGroup(groupNumber);
		end
	end
end

-- easier method to turn on/off errors for macros
SlashCmdList["UI_ERRORS_OFF"] = function(msg)
	UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE");
	SetCVar("Sound_EnableSFX", "0");
end

SlashCmdList["UI_ERRORS_ON"] = function(msg)
	UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE");
	SetCVar("Sound_EnableSFX", "1");
end

SlashCmdList["FRAMESTACK"] = function(msg)
	UIParentLoadAddOn("Blizzard_DebugTools");
	if(msg == tostring(true)) then
		FrameStackTooltip_Toggle(true);
	else
		FrameStackTooltip_Toggle();
	end
end

SlashCmdList["EVENTTRACE"] = function(msg)
	UIParentLoadAddOn("Blizzard_DebugTools");
	EventTraceFrame_HandleSlashCmd(msg);
end

SlashCmdList["DUMP"] = function(msg)
	UIParentLoadAddOn("Blizzard_DebugTools");
	DevTools_DumpCommand(msg);
end

SlashCmdList["RELOAD"] = function(msg)
	ConsoleExec("reloadui");
end

for index, value in pairs(ChatTypeInfo) do
	value.r = 1.0;
	value.g = 1.0;
	value.b = 1.0;
	value.id = GetChatTypeIndex(index);
end
	
-- ChatFrame functions
function ChatFrame_OnLoad(self)
	self.flashTimer = 0;
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UPDATE_CHAT_COLOR");
	self:RegisterEvent("UPDATE_CHAT_WINDOWS");
	self:RegisterEvent("CHAT_MSG_CHANNEL");
	self:RegisterEvent("ZONE_UNDER_ATTACK");
	self:RegisterEvent("UPDATE_INSTANCE_INFO");
	self:RegisterEvent("NEW_TITLE_EARNED");
	self:RegisterEvent("OLD_TITLE_LOST");
	self:RegisterEvent("UPDATE_CHAT_COLOR_NAME_BY_CLASS");
	self:RegisterEvent("VARIABLES_LOADED");
	self.tellTimer = GetTime();
	self.channelList = {};
	self.zoneChannelList = {};
	self.messageTypeList = {};
	
	self.defaultLanguage = GetDefaultLanguage(); --If PLAYER_ENTERING_WORLD hasn't been called yet, this is nil, but it'll be fixed whent he event is fired.
end

function ChatFrame_RegisterForMessages(self, ...)
	local messageGroup;
	local index = 1;
	for i=1, select("#", ...) do
		messageGroup = ChatTypeGroup[select(i, ...)];
		if ( messageGroup ) then
			self.messageTypeList[index] = select(i, ...);
			for index, value in pairs(messageGroup) do
				self:RegisterEvent(value);
			end
			index = index + 1;
		end
	end
end

function ChatFrame_RegisterForChannels(self, ...)
	local index = 1;
	for i=1, select("#", ...), 2 do
		self.channelList[index], self.zoneChannelList[index] = select(i, ...);
		index = index + 1;
	end
end

function ChatFrame_AddMessageGroup(chatFrame, group)
	local info = ChatTypeGroup[group];
	if ( info ) then
		local i = 1;
		while ( chatFrame.messageTypeList[i] ) do
			i = i + 1;
		end
		chatFrame.messageTypeList[i] = group;
		for index, value in pairs(info) do
			chatFrame:RegisterEvent(value);
		end
		AddChatWindowMessages(chatFrame:GetID(), group);
	end
end

function ChatFrame_RemoveMessageGroup(chatFrame, group)
	local info = ChatTypeGroup[group];
	if ( info ) then
		for index, value in pairs(chatFrame.messageTypeList) do
			if ( strupper(value) == strupper(group) ) then
				chatFrame.messageTypeList[index] = nil;
			end
		end
		for index, value in pairs(info) do
			chatFrame:UnregisterEvent(value);
		end
		RemoveChatWindowMessages(chatFrame:GetID(), group);
	end
end

function ChatFrame_RemoveAllMessageGroups(chatFrame)
	for index, value in pairs(chatFrame.messageTypeList) do
		for eventIndex, eventValue in pairs(ChatTypeGroup[value]) do
			chatFrame:UnregisterEvent(eventValue);
		end
		RemoveChatWindowMessages(chatFrame:GetID(), value);
	end
	
	chatFrame.messageTypeList = {};
end

function ChatFrame_AddChannel(chatFrame, channel)
	local zoneChannel = AddChatWindowChannel(chatFrame:GetID(), channel);
	if ( zoneChannel ) then
		local i = 1;
		while ( chatFrame.channelList[i] ) do
			i = i + 1;
		end
		chatFrame.channelList[i] = channel;
		chatFrame.zoneChannelList[i] = zoneChannel;
	end
end

function ChatFrame_RemoveChannel(chatFrame, channel)
	for index, value in pairs(chatFrame.channelList) do
		if ( strupper(channel) == strupper(value) ) then
			chatFrame.channelList[index] = nil;
			chatFrame.zoneChannelList[index] = nil;
		end
	end
	RemoveChatWindowChannel(chatFrame:GetID(), channel);
end

function ChatFrame_RemoveAllChannels(chatFrame)
	for index, value in pairs(chatFrame.channelList) do
		RemoveChatWindowChannel(chatFrame:GetID(), value);
	end
	chatFrame.channelList = {};
	chatFrame.zoneChannelList = {};
end

function ChatFrame_AddPrivateMessageTarget(chatFrame, chatTarget)
	ChatFrame_RemoveExcludePrivateMessageTarget(chatFrame, chatTarget);
	if ( chatFrame.privateMessageList ) then
		chatFrame.privateMessageList[strlower(chatTarget)] = true;
	else
		chatFrame.privateMessageList = { [strlower(chatTarget)] = true };
	end
end

function ChatFrame_RemovePrivateMessageTarget(chatFrame, chatTarget)
	if ( chatFrame.privateMessageList ) then
		chatFrame.privateMessageList[strlower(chatTarget)] = nil;
	end
end

function ChatFrame_ExcludePrivateMessageTarget(chatFrame, chatTarget)
	ChatFrame_RemovePrivateMessageTarget(chatFrame, chatTarget);
	if ( chatFrame.excludePrivateMessageList ) then
		chatFrame.excludePrivateMessageList[strlower(chatTarget)] = true;
	else
		chatFrame.excludePrivateMessageList = { [strlower(chatTarget)] = true };
	end
end

function ChatFrame_RemoveExcludePrivateMessageTarget(chatFrame, chatTarget)
	if ( chatFrame.excludePrivateMessageList ) then
		chatFrame.excludePrivateMessageList[strlower(chatTarget)] = nil;
	end
end
	
function ChatFrame_ReceiveAllPrivateMessages(chatFrame)
	chatFrame.privateMessageList = nil;
	chatFrame.excludePrivateMessageList = nil;
end

function ChatFrame_AddBNConversationTarget(chatFrame, chatTarget)
	ChatFrame_RemoveExcludeBNConversationTarget(chatFrame, chatTarget);
	if ( chatFrame.bnConversationList ) then
		chatFrame.bnConversationList[tonumber(chatTarget)] = true;
	else
		chatFrame.bnConversationList = { [tonumber(chatTarget)] = true };
	end
end

function ChatFrame_RemoveBNConversationTarget(chatFrame, chatTarget)
	if ( chatFrame.bnConversationList ) then
		chatFrame.bnConversationList[tonumber(chatTarget)] = nil;
	end
end

function ChatFrame_ExcludeBNConversationTarget(chatFrame, chatTarget)
	ChatFrame_RemoveBNConversationTarget(chatFrame, chatTarget);
	if ( chatFrame.excludeBNConversationList ) then
		chatFrame.excludeBNConversationList[tonumber(chatTarget)] = true;
	else
		chatFrame.excludeBNConversationList = { [tonumber(chatTarget)] = true };
	end
end

function ChatFrame_RemoveExcludeBNConversationTarget(chatFrame, chatTarget)
	if ( chatFrame.excludeBNConversationList ) then
		chatFrame.excludeBNConversationList[tonumber(chatTarget)] = nil;
	end
end
	
function ChatFrame_ReceiveAllBNConversations(chatFrame)
	chatFrame.bnConversationList = nil;
	chatFrame.excludeBNConversationList = nil;
end

-- Set up a private editbox to handle macro execution
do
	local function GetDefaultChatEditBox(field)
		return DEFAULT_CHAT_FRAME.editBox;
	end

    local editbox = CreateFrame("Editbox", "MacroEditBox");
    editbox:RegisterEvent("EXECUTE_CHAT_LINE");
    editbox:SetScript("OnEvent",
		function(self,event,line)
			if ( event == "EXECUTE_CHAT_LINE" ) then
				local defaulteditbox = securecall(GetDefaultChatEditBox);
				self:SetAttribute("chatType", defaulteditbox:GetAttribute("chatType"));
				self:SetAttribute("tellTarget", defaulteditbox:GetAttribute("tellTarget"));
				self:SetAttribute("channelTarget", defaulteditbox:GetAttribute("channelTarget"));
				self:SetText(line);
				ChatEdit_SendText(self);
			end
		end
	);
	editbox:Hide();
end

function ChatFrame_OnEvent(self, event, ...)
	if ( ChatFrame_ConfigEventHandler(self, event, ...) ) then
		return;
	end
	if ( ChatFrame_SystemEventHandler(self, event, ...) ) then
		return
	end
	if ( ChatFrame_MessageEventHandler(self, event, ...) ) then
		return
	end
end

function ChatFrame_ConfigEventHandler(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self.defaultLanguage = GetDefaultLanguage();
		return true;
	elseif ( event == "UPDATE_CHAT_WINDOWS" ) then
		local name, fontSize, r, g, b, a, shown, locked = FCF_GetChatWindowInfo(self:GetID());
		if ( fontSize > 0 ) then
			local fontFile, unused, fontFlags = self:GetFont();
			self:SetFont(fontFile, fontSize, fontFlags);
		end
		if ( shown and not self.minimized ) then
			self:Show();
		end
		-- Do more stuff!!!
		ChatFrame_RegisterForMessages(self, GetChatWindowMessages(self:GetID()));
		ChatFrame_RegisterForChannels(self, GetChatWindowChannels(self:GetID()));
		return true;
	end
	
	local arg1, arg2, arg3, arg4 = ...;
	if ( event == "UPDATE_CHAT_COLOR" ) then
		local info = ChatTypeInfo[strupper(arg1)];
		if ( info ) then
			info.r = arg2;
			info.g = arg3;
			info.b = arg4;
			self:UpdateColorByID(info.id, info.r, info.g, info.b);

			if ( strupper(arg1) == "WHISPER" ) then
				info = ChatTypeInfo["REPLY"];
				if ( info ) then
					info.r = arg2;
					info.g = arg3;
					info.b = arg4;
					self:UpdateColorByID(info.id, info.r, info.g, info.b);
				end
			end
		end
		return true;
	elseif ( event == "UPDATE_CHAT_COLOR_NAME_BY_CLASS" ) then
		local info = ChatTypeInfo[strupper(arg1)];
		if ( info ) then
			info.colorNameByClass = arg2;
			if ( strupper(arg1) == "WHISPER" ) then
				info = ChatTypeInfo["REPLY"];
				if ( info ) then
					info.colorNameByClass = arg2;
				end
			end
		end
		return true;
	elseif ( event == "VARIABLES_LOADED" ) then
		if ( GetCVarBool("chatMouseScroll") ) then
			self:SetScript("OnMouseWheel", FloatingChatFrame_OnMouseScroll);
			self:EnableMouseWheel(true);
		end
		self:UnregisterEvent("VARIABLES_LOADED");
		return true;
	end
end

function ChatFrame_SystemEventHandler(self, event, ...)
	if ( event == "TIME_PLAYED_MSG" ) then
		local arg1, arg2 = ...;
		ChatFrame_DisplayTimePlayed(self, arg1, arg2);
		return true;
	elseif ( event == "PLAYER_LEVEL_UP" ) then
		local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9 = ...;
		-- Level up
		local info = ChatTypeInfo["SYSTEM"];

		local string = format(LEVEL_UP, arg1);
		self:AddMessage(string, info.r, info.g, info.b, info.id);

		if ( arg3 > 0 ) then
			string = format(LEVEL_UP_HEALTH_MANA, arg2, arg3);
		else
			string = format(LEVEL_UP_HEALTH, arg2);
		end
		self:AddMessage(string, info.r, info.g, info.b, info.id);

		if ( arg4 > 0 ) then
			string = format(LEVEL_UP_CHAR_POINTS, arg4);
			self:AddMessage(string, info.r, info.g, info.b, info.id);
		end

		if ( arg5 > 0 ) then
			string = format(LEVEL_UP_STAT, SPELL_STAT1_NAME, arg5);
			self:AddMessage(string, info.r, info.g, info.b, info.id);
		end
		if ( arg6 > 0 ) then
			string = format(LEVEL_UP_STAT, SPELL_STAT2_NAME, arg6);
			self:AddMessage(string, info.r, info.g, info.b, info.id);
		end
		if ( arg7 > 0 ) then
			string = format(LEVEL_UP_STAT, SPELL_STAT3_NAME, arg7);
			self:AddMessage(string, info.r, info.g, info.b, info.id);
		end
		if ( arg8 > 0 ) then
			string = format(LEVEL_UP_STAT, SPELL_STAT4_NAME, arg8);
			self:AddMessage(string, info.r, info.g, info.b, info.id);
		end
		if ( arg9 > 0 ) then
			string = format(LEVEL_UP_STAT, SPELL_STAT5_NAME, arg9);
			self:AddMessage(string, info.r, info.g, info.b, info.id);
		end
		return true;
	elseif ( event == "CHARACTER_POINTS_CHANGED" ) then
		local arg1, arg2 = ...;
		local info = ChatTypeInfo["SYSTEM"];
		if ( arg2 > 0 ) then
			local cp1, cp2 = UnitCharacterPoints("player");
			if ( cp2 ) then
				local string = format(LEVEL_UP_SKILL_POINTS, cp2);
				self:AddMessage(string, info.r, info.g, info.b, info.id);
			end
		end
		return true;
	elseif ( event == "GUILD_MOTD" ) then
		local arg1 = ...;
		if ( arg1 and (strlen(arg1) > 0) ) then
			local info = ChatTypeInfo["GUILD"];
			local string = format(GUILD_MOTD_TEMPLATE, arg1);
			self:AddMessage(string, info.r, info.g, info.b, info.id);
		end
		return true;
	elseif ( event == "ZONE_UNDER_ATTACK" ) then
		local arg1 = ...;
		local info = ChatTypeInfo["SYSTEM"];
		self:AddMessage(format(ZONE_UNDER_ATTACK, arg1), info.r, info.g, info.b, info.id);
		return true;
	elseif ( event == "UPDATE_INSTANCE_INFO" ) then
		if ( RaidFrame.hasRaidInfo ) then
			local info = ChatTypeInfo["SYSTEM"];
			if ( RaidFrame.slashCommand and GetNumSavedInstances() == 0 and self == DEFAULT_CHAT_FRAME) then
				self:AddMessage(NO_RAID_INSTANCES_SAVED, info.r, info.g, info.b, info.id);
				RaidFrame.slashCommand = nil;
			end
		end
		return true;
	elseif ( event == "NEW_TITLE_EARNED" ) then
		local arg1 = ...;
		local info = ChatTypeInfo["SYSTEM"];
		self:AddMessage(format(NEW_TITLE_EARNED, arg1), info.r, info.g, info.b, info.id);
		return true;
	elseif ( event == "OLD_TITLE_LOST" ) then
		local arg1 = ...;	
		local info = ChatTypeInfo["SYSTEM"];
		self:AddMessage(format(OLD_TITLE_LOST, arg1), info.r, info.g, info.b, info.id);
		return true;
	end
end

function GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12)
	local chatType = strsub(event, 10);
	if ( strsub(chatType, 1, 7) == "WHISPER" ) then
		chatType = "WHISPER";
	end
	if ( strsub(chatType, 1, 7) == "CHANNEL" ) then
		chatType = "CHANNEL"..arg8;
	end
	local info = ChatTypeInfo[chatType];
	
	if ( info and info.colorNameByClass and arg12 ~= "" ) then
		local localizedClass, englishClass, localizedRace, englishRace, sex = GetPlayerInfoByGUID(arg12)
		
		if ( englishClass ) then
			local classColorTable = RAID_CLASS_COLORS[englishClass];
			if ( not classColorTable ) then
				return arg2;
			end
			return string.format("\124cff%.2x%.2x%.2x", classColorTable.r*255, classColorTable.g*255, classColorTable.b*255)..arg2.."\124r"
		end
	end
	
	return arg2;
end

function ChatFrame_MessageEventHandler(self, event, ...)
	if ( strsub(event, 1, 8) == "CHAT_MSG" ) then
		local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12 = ...;
		local type = strsub(event, 10);
		local info = ChatTypeInfo[type];

		local filter = false;
		if ( chatFilters[event] ) then
			local newarg1, newarg2, newarg3, newarg4, newarg5, newarg6, newarg7, newarg8, newarg9, newarg10, newarg11, newarg12;
			for _, filterFunc in next, chatFilters[event] do
				filter, newarg1, newarg2, newarg3, newarg4, newarg5, newarg6, newarg7, newarg8, newarg9, newarg10, newarg11, newarg12 = filterFunc(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12);
				if ( filter ) then
					return true;
				elseif ( newarg1 ) then
					arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12 = newarg1, newarg2, newarg3, newarg4, newarg5, newarg6, newarg7, newarg8, newarg9, newarg10, newarg11, newarg12;
				end
			end
		end
		
		local coloredName = GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12);
		
		local channelLength = strlen(arg4);
		local infoType = type;
		if ( (strsub(type, 1, 7) == "CHANNEL") and (type ~= "CHANNEL_LIST") and ((arg1 ~= "INVITE") or (type ~= "CHANNEL_NOTICE_USER")) ) then
			if ( arg1 == "WRONG_PASSWORD" ) then
				local staticPopup = _G[StaticPopup_Visible("CHAT_CHANNEL_PASSWORD") or ""];
				if ( staticPopup and strupper(staticPopup.data) == strupper(arg9) ) then
					-- Don't display invalid password messages if we're going to prompt for a password (bug 102312)
					return;
				end
			end
			
			local found = 0;
			for index, value in pairs(self.channelList) do
				if ( channelLength > strlen(value) ) then
					-- arg9 is the channel name without the number in front...
					if ( ((arg7 > 0) and (self.zoneChannelList[index] == arg7)) or (strupper(value) == strupper(arg9)) ) then
						found = 1;
						infoType = "CHANNEL"..arg8;
						info = ChatTypeInfo[infoType];
						if ( (type == "CHANNEL_NOTICE") and (arg1 == "YOU_LEFT") ) then
							self.channelList[index] = nil;
							self.zoneChannelList[index] = nil;
						end
						break;
					end
				end
			end
			if ( (found == 0) or not info ) then
				return true;
			end
		end

		local chatGroup = Chat_GetChatCategory(type);
		local chatTarget;
		if ( chatGroup == "CHANNEL" or chatGroup == "BN_CONVERSATION" ) then
			chatTarget = tostring(arg8);
		elseif ( chatGroup == "WHISPER" or chatGroup == "BN_WHISPER" ) then
			chatTarget = strupper(arg2);
		end
		
		if ( FCFManager_ShouldSuppressMessage(self, chatGroup, chatTarget) ) then
			return true;
		end
			
		if ( chatGroup == "WHISPER" or chatGroup == "BN_WHISPER" ) then
			if ( self.privateMessageList and not self.privateMessageList[strlower(arg2)] ) then
				return true;
			elseif ( self.excludePrivateMessageList and self.excludePrivateMessageList[strlower(arg2)] ) then
				return true;
			end
		elseif ( chatGroup == "BN_CONVERSATION" ) then
			if ( self.bnConversationList and not self.bnConversationList[arg8] ) then
				return true;
			elseif ( self.excludeBNConversationList and self.excludeBNConversationList[arg8] ) then
				return true;
			end
		end
	
		if ( type == "SYSTEM" or type == "SKILL" or type == "LOOT" or type == "MONEY" or
		     type == "OPENING" or type == "TRADESKILLS" or type == "PET_INFO" or type == "TARGETICONS") then
			self:AddMessage(arg1, info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,7) == "COMBAT_" ) then
			self:AddMessage(arg1, info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,6) == "SPELL_" ) then
			self:AddMessage(arg1, info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,10) == "BG_SYSTEM_" ) then
			self:AddMessage(arg1, info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,11) == "ACHIEVEMENT" ) then
			self:AddMessage(format(arg1, "|Hplayer:"..arg2.."|h".."["..coloredName.."]".."|h"), info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,18) == "GUILD_ACHIEVEMENT" ) then
			self:AddMessage(format(arg1, "|Hplayer:"..arg2.."|h".."["..coloredName.."]".."|h"), info.r, info.g, info.b, info.id);
		elseif ( type == "IGNORED" ) then
			self:AddMessage(format(CHAT_IGNORED, arg2), info.r, info.g, info.b, info.id);
		elseif ( type == "FILTERED" ) then
			self:AddMessage(format(CHAT_FILTERED, arg2), info.r, info.g, info.b, info.id);
		elseif ( type == "RESTRICTED" ) then
			self:AddMessage(CHAT_RESTRICTED, info.r, info.g, info.b, info.id);
		elseif ( type == "CHANNEL_LIST") then
			if(channelLength > 0) then
				self:AddMessage(format(_G["CHAT_"..type.."_GET"]..arg1, tonumber(arg8), arg4), info.r, info.g, info.b, info.id);
			else
				self:AddMessage(arg1, info.r, info.g, info.b, info.id);
			end
		elseif (type == "CHANNEL_NOTICE_USER") then
			local globalstring = _G["CHAT_"..arg1.."_NOTICE_BN"];
			if ( not globalstring ) then
				globalstring = _G["CHAT_"..arg1.."_NOTICE"];
			end
			if(strlen(arg5) > 0) then
				-- TWO users in this notice (E.G. x kicked y)
				self:AddMessage(format(globalstring, arg8, arg4, arg2, arg5), info.r, info.g, info.b, info.id);
			elseif ( arg1 == "INVITE" ) then
				self:AddMessage(format(globalstring, arg4, arg2), info.r, info.g, info.b, info.id);
			else
				self:AddMessage(format(globalstring, arg8, arg4, arg2), info.r, info.g, info.b, info.id);
			end
		elseif (type == "CHANNEL_NOTICE") then
			local globalstring = _G["CHAT_"..arg1.."_NOTICE_BN"];
			if ( not globalstring ) then
				globalstring = _G["CHAT_"..arg1.."_NOTICE"];
			end
			if ( arg10 > 0 ) then
				arg4 = arg4.." "..arg10;
			end
			
			local accessID = ChatHistory_GetAccessID(Chat_GetChatCategory(type), arg8);
			local typeID = ChatHistory_GetAccessID(infoType, arg8);
			self:AddMessage(format(globalstring, arg8, arg4), info.r, info.g, info.b, info.id, false, accessID, typeID);
		elseif ( type == "BN_CONVERSATION_NOTICE" ) then
			local channelLink = format(CHAT_BN_CONVERSATION_GET_LINK, arg8, MAX_WOW_CHAT_CHANNELS + arg8);
			local playerLink = format("|HBNplayer:%s:%s:%s:%s:%s|h[%s]|h", arg2, arg13, arg11, Chat_GetChatCategory(type), arg8, arg2);
			local message = format(_G["CHAT_CONVERSATION_"..arg1.."_NOTICE"], channelLink, playerLink)
			
			local accessID = ChatHistory_GetAccessID(Chat_GetChatCategory(type), arg8);
			local typeID = ChatHistory_GetAccessID(infoType, arg8);
			self:AddMessage(message, info.r, info.g, info.b, info.id, false, accessID, typeID);
		elseif ( type == "BN_CONVERSATION_LIST" ) then
			local channelLink = format(CHAT_BN_CONVERSATION_GET_LINK, arg8, MAX_WOW_CHAT_CHANNELS + arg8);
			local message = format(CHAT_BN_CONVERSATION_LIST, channelLink, arg1);
			self:AddMessage(message, info.r, info.g, info.b, info.id, false, accessID, typeID);
		elseif ( type == "BN_INLINE_TOAST_ALERT" ) then
			local globalstring = _G["BN_INLINE_TOAST_"..arg1];
			local message;
			if ( arg1 == "FRIEND_REQUEST" ) then
				message = globalstring;
			elseif ( arg1 == "FRIEND_PENDING" ) then
				message = format(BN_INLINE_TOAST_FRIEND_PENDING, BNGetNumFriendInvites());
			elseif ( arg1 == "FRIEND_REMOVED" ) then
				message = format(globalstring, arg2);
			else
				local playerLink = format("|HBNplayer:%s:%s:%s:%s:%s|h[%s]|h", arg2, arg13, arg11, Chat_GetChatCategory(type), 0, arg2);
				message = format(globalstring, playerLink);
			end
			self:AddMessage(message, info.r, info.g, info.b, info.id);
		elseif ( type == "BN_INLINE_TOAST_BROADCAST" ) then
			if ( arg1 ~= "" ) then
				local playerLink = format("|HBNplayer:%s:%s:%s:%s:%s|h[%s]|h", arg2, arg13, arg11, Chat_GetChatCategory(type), 0, arg2);
				self:AddMessage(format(BN_INLINE_TOAST_BROADCAST, playerLink, arg1), info.r, info.g, info.b, info.id);
			end
		elseif ( type == "BN_INLINE_TOAST_BROADCAST_INFORM" ) then
			if ( arg1 ~= "" ) then
				self:AddMessage(BN_INLINE_TOAST_BROADCAST_INFORM, info.r, info.g, info.b, info.id);
			end
		elseif ( type == "BN_INLINE_TOAST_CONVERSATION" ) then
			self:AddMessage(format(BN_INLINE_TOAST_CONVERSATION, arg1), info.r, info.g, info.b, info.id);
		else
			local body;

			local _, fontHeight = FCF_GetChatWindowInfo(self:GetID());
			
			if ( fontHeight == 0 ) then
				--fontHeight will be 0 if it's still at the default (14)
				fontHeight = 14;
			end
			
			-- Add AFK/DND flags
			local pflag;
			if(strlen(arg6) > 0) then
				if ( arg6 == "GM" ) then
					--If it was a whisper, dispatch it to the GMChat addon.
					if ( type == "WHISPER" ) then
						return;
					end
					--Add Blizzard Icon, this was sent by a GM
					pflag = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz.blp:0:2:0:-3|t ";
				elseif ( arg6 == "DEV" ) then
					--Add Blizzard Icon, this was sent by a Dev
					pflag = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz.blp:0:2:0:-3|t ";
				else
					pflag = _G["CHAT_FLAG_"..arg6];
				end
			else
				pflag = "";
			end
			if ( type == "WHISPER_INFORM" and GMChatFrame_IsGM and GMChatFrame_IsGM(arg2) ) then
				return;
			end

			local showLink = 1;
			if ( strsub(type, 1, 7) == "MONSTER" or strsub(type, 1, 9) == "RAID_BOSS") then
				showLink = nil;
			else
				arg1 = gsub(arg1, "%%", "%%%%");
			end
			
			if ((type == "PARTY_LEADER") and (HasLFGRestrictions())) then
				type = "PARTY_GUIDE";
			end
			
			-- Search for icon links and replace them with texture links.
			local term;
			for tag in string.gmatch(arg1, "%b{}") do
				term = strlower(string.gsub(tag, "[{}]", ""));
				if ( ICON_TAG_LIST[term] and ICON_LIST[ICON_TAG_LIST[term]] ) then
					arg1 = string.gsub(arg1, tag, ICON_LIST[ICON_TAG_LIST[term]] .. "0|t");
				end
			end
			
			local playerLink;

			if ( type ~= "BN_WHISPER" and type ~= "BN_WHISPER_INFORM" and type ~= "BN_CONVERSATION" ) then
				playerLink = "|Hplayer:"..arg2..":"..arg11..":"..chatGroup..(chatTarget and ":"..chatTarget or "").."|h";
			else
				playerLink = "|HBNplayer:"..arg2..":"..arg13..":"..arg11..":"..chatGroup..(chatTarget and ":"..chatTarget or "").."|h";
			end
			
			if ( (strlen(arg3) > 0) and (arg3 ~= "Universal") and (arg3 ~= self.defaultLanguage) ) then
				local languageHeader = "["..arg3.."] ";
				if ( showLink and (strlen(arg2) > 0) ) then
					body = format(_G["CHAT_"..type.."_GET"]..languageHeader..arg1, pflag..playerLink.."["..coloredName.."]".."|h");
				else
					body = format(_G["CHAT_"..type.."_GET"]..languageHeader..arg1, pflag..arg2);
				end
			else
				if ( not showLink or strlen(arg2) == 0 ) then
					body = format(_G["CHAT_"..type.."_GET"]..arg1, pflag..arg2, arg2);
				else
					if ( type == "EMOTE" ) then
						body = format(_G["CHAT_"..type.."_GET"]..arg1, pflag..playerLink..coloredName.."|h");
					elseif ( type == "TEXT_EMOTE") then
						body = string.gsub(arg1, arg2, pflag..playerLink..coloredName.."|h", 1);
					else
						body = format(_G["CHAT_"..type.."_GET"]..arg1, pflag..playerLink.."["..coloredName.."]".."|h");
					end
				end
			end

			-- Add Channel
			arg4 = gsub(arg4, "%s%-%s.*", "");
			if( chatGroup  == "BN_CONVERSATION" ) then
				body = format(CHAT_BN_CONVERSATION_GET_LINK, arg8, MAX_WOW_CHAT_CHANNELS + arg8)..body;
			elseif(channelLength > 0) then
				body = "|Hchannel:channel:"..arg8.."|h["..arg4.."]|h "..body;
			end
			
			--Add Timestamps
			if ( CHAT_TIMESTAMP_FORMAT ) then
				body = BetterDate(CHAT_TIMESTAMP_FORMAT, time())..body;
			end
			
			local accessID = ChatHistory_GetAccessID(chatGroup, chatTarget);
			local typeID = ChatHistory_GetAccessID(infoType, chatTarget);
			self:AddMessage(body, info.r, info.g, info.b, info.id, false, accessID, typeID);
		end
 
		if ( type == "WHISPER" or type == "BN_WHISPER" ) then
			--BN_WHISPER FIXME
			ChatEdit_SetLastTellTarget(arg2);
			if ( self.tellTimer and (GetTime() > self.tellTimer) ) then
				PlaySound("TellMessage");
			end
			self.tellTimer = GetTime() + CHAT_TELL_ALERT_TIME;
			--FCF_FlashTab(self);
		end

		if ( not self:IsShown() ) then
			if ( (self == DEFAULT_CHAT_FRAME and info.flashTabOnGeneral) or (self ~= DEFAULT_CHAT_FRAME and info.flashTab) ) then
				if ( not CHAT_OPTIONS.HIDE_FRAME_ALERTS or type == "WHISPER" or type == "BN_WHISPER" ) then	--BN_WHISPER FIXME
					FCF_StartAlertFlash(self);
				end
			end
		end

		return true;
	end
end

function ChatFrame_AddMessageEventFilter (event, filter)
	assert(event and filter);
	
	if ( chatFilters[event] ) then
		-- Only allow a filter to be added once
		for index, filterFunc in next, chatFilters[event] do
			if ( filterFunc == filter ) then
				return;
			end
		end
	else
		chatFilters[event] = {};
	end
	
	tinsert(chatFilters[event], filter);
end

function ChatFrame_RemoveMessageEventFilter (event, filter)
	assert(event and filter);
	
	if ( chatFilters[event] ) then
		for index, filterFunc in next, chatFilters[event] do
			if ( filterFunc == filter ) then
				tremove(chatFilters[event], index);
			end
		end
		
		if ( #chatFilters[event] == 0 ) then
			chatFilters[event] = nil;
		end
	end
end

function ChatFrame_GetMessageEventFilters (event)
	assert(event);
	
	return chatFilters[event];
end

function ChatFrame_OnUpdate(self, elapsedSec)
	local flash = _G[self:GetName().."ButtonFrameBottomButtonFlash"];
	
	if ( not flash ) then
		return;
	end

	if ( self:AtBottom() ) then
		if ( flash:IsShown() ) then
			flash:Hide();
		end
		return;
	end

	local flashTimer = self.flashTimer + elapsedSec;
	if ( flashTimer < CHAT_BUTTON_FLASH_TIME ) then
		self.flashTimer = flashTimer;
		return;
	end

	while ( flashTimer >= CHAT_BUTTON_FLASH_TIME ) do
		flashTimer = flashTimer - CHAT_BUTTON_FLASH_TIME;
	end
	self.flashTimer = flashTimer;

	if ( flash:IsShown() ) then
		flash:Hide();
	else
		flash:Show();
	end
end

function ChatFrame_OnHyperlinkShow(self, link, text, button)
	SetItemRef(link, text, button, self);
end

function ChatFrame_OnMouseWheel(value)
	if ( value > 0 ) then
		SELECTED_DOCK_FRAME:ScrollUp();
	elseif ( value < 0 ) then
		SELECTED_DOCK_FRAME:ScrollDown();
	end
end

function ChatFrame_OpenChat(text, chatFrame)
	local editBox = ChatEdit_ChooseBoxForSend(chatFrame);

	ChatEdit_ActivateChat(editBox);
	editBox.setText = 1;
	editBox.text = text;

	if ( editBox:GetAttribute("chatType") == editBox:GetAttribute("stickyType") ) then
		if ( (editBox:GetAttribute("stickyType") == "PARTY") and (GetNumPartyMembers() == 0) or
		(editBox:GetAttribute("stickyType") == "RAID") and (GetNumRaidMembers() == 0) or
		(editBox:GetAttribute("stickyType") == "BATTLEGROUND") and (GetNumRaidMembers() == 0) ) then
			editBox:SetAttribute("chatType", "SAY");
		end
	end
	
	ChatEdit_UpdateHeader(editBox);
	return editBox;
end

function ChatFrame_ScrollToBottom()
	SELECTED_DOCK_FRAME:ScrollToBottom();
end

function ChatFrame_ScrollUp()
	SELECTED_DOCK_FRAME:ScrollUp();
end

function ChatFrame_ScrollDown()
	SELECTED_DOCK_FRAME:ScrollDown();
end

--used for chatframe and combat log
function MessageFrameScrollButton_OnLoad(self)
	self.clickDelay = MESSAGE_SCROLLBUTTON_INITIAL_DELAY;
	self:RegisterForClicks("LeftButtonDown", "LeftButtonUp", "RightButtonUp", "RightButtonDown");
end

--Controls scrolling for chatframe and combat log
function MessageFrameScrollButton_OnUpdate(self, elapsed)
	if (self:GetButtonState() == "PUSHED") then
		self.clickDelay = self.clickDelay - elapsed;
		if ( self.clickDelay < 0 ) then
			local name = self:GetName();
			if ( name == self:GetParent():GetName().."DownButton" ) then
				self:GetParent():GetParent():ScrollDown();
			elseif ( name == self:GetParent():GetName().."UpButton" ) then
				self:GetParent():GetParent():ScrollUp();
			end
			self.clickDelay = MESSAGE_SCROLLBUTTON_SCROLL_DELAY;
		end
	end
end

function ChatFrame_OpenMenu()
	ChatMenu:Show();
end

function ChatFrameMenu_UpdateAnchorPoint()
	--Update the menu anchor point
	if ( FCF_GetButtonSide(DEFAULT_CHAT_FRAME) == "right" ) then
		ChatMenu:ClearAllPoints();
		ChatMenu:SetPoint("BOTTOMRIGHT", ChatFrameMenuButton, "TOPLEFT");
	else
		ChatMenu:ClearAllPoints();
		ChatMenu:SetPoint("BOTTOMLEFT", ChatFrameMenuButton, "TOPRIGHT");
	end
end

function ChatFrame_SendTell(name, chatFrame)
	local editBox = ChatEdit_ChooseBoxForSend(chatFrame);
	
	--DEBUG FIXME - for now, we're not going to remove spaces from names. We need to make sure X-server still works.
	-- Remove spaces from the server name for slash command parsing
	--name = gsub(name, " ", "");

	if ( editBox ~= ChatEdit_GetActiveWindow() ) then
		ChatFrame_OpenChat(SLASH_WHISPER1.." "..name.." ", chatFrame);
	else
		editBox:SetText(SLASH_WHISPER1.." "..name.." ");
	end
	ChatEdit_ParseText(editBox, 0);
--[[
	chatFrame.editBox:SetAttribute("chatType", "WHISPER");
	chatFrame.editBox:SetAttribute("tellTarget", name);
	ChatEdit_UpdateHeader(chatFrame.editBox);
	if ( editBox ~= ChatEdit_GetActiveWindow() ) then
		ChatFrame_OpenChat("", chatFrame);
	end
]]
end

function ChatFrame_ReplyTell(chatFrame)
	local editBox = ChatEdit_ChooseBoxForSend(chatFrame);

	local lastTell = ChatEdit_GetLastTellTarget();
	if ( lastTell ~= "" ) then
		--BN_WHISPER FIXME
		editBox:SetAttribute("chatType", "WHISPER");
		editBox:SetAttribute("tellTarget", lastTell);
		ChatEdit_UpdateHeader(editBox);
		if ( editBox ~= ChatEdit_GetActiveWindow() ) then
			ChatFrame_OpenChat("", chatFrame);
		end
	else
		-- Error message
	end
end

function ChatFrame_ReplyTell2(chatFrame)
	local editBox = ChatEdit_ChooseBoxForSend(chatFrame);

	local lastTold = ChatEdit_GetLastToldTarget();
	if ( lastTold ~= "" ) then
		--BN_WHISPER FIXME
		editBox:SetAttribute("chatType", "WHISPER");
		editBox:SetAttribute("tellTarget", lastTold);
		ChatEdit_UpdateHeader(editBox);
		if ( editBox ~= ChatEdit_GetActiveWindow() ) then
			ChatFrame_OpenChat("", chatFrame);
		end
	else
		-- Error message
	end
end

function ChatFrame_DisplayStartupText(frame)
	if ( not frame ) then
		return;
	end

	local info = ChatTypeInfo["SYSTEM"];
	local i = 1;
	local text = _G["STARTUP_TEXT_LINE"..i];
	while text do
		frame:AddMessage(text, info.r, info.g, info.b, info.id);
		i = i + 1;
		text = _G["STARTUP_TEXT_LINE"..i];
	end

end

function ChatFrame_DisplayHelpText(frame)
	if ( not frame ) then
		return;
	end

	local info = ChatTypeInfo["SYSTEM"];
	local i = 1;
	local text = _G["HELP_TEXT_LINE"..i];
	while text do
		frame:AddMessage(text, info.r, info.g, info.b, info.id);
		i = i + 1;
		text = _G["HELP_TEXT_LINE"..i];
	end

end

function ChatFrame_DisplayMacroHelpText(frame)
	if ( not frame ) then
		return;
	end

	local info = ChatTypeInfo["SYSTEM"];
	local i = 1;
	local text = _G["MACRO_HELP_TEXT_LINE"..i];
	while text do
		frame:AddMessage(text, info.r, info.g, info.b, info.id);
		i = i + 1;
		text = _G["MACRO_HELP_TEXT_LINE"..i];
	end

end

function ChatFrame_DisplayChatHelp(frame)
	if ( not frame ) then
		return;
	end

	local info = ChatTypeInfo["SYSTEM"];
	local i = 1;
	local text = _G["CHAT_HELP_TEXT_LINE"..i];
	while text do
		frame:AddMessage(text, info.r, info.g, info.b, info.id);
		i = i + 1;
		-- hack fix for removing a line without causing localization problems
		if ( i == 15 ) then
			i = i + 1;
		end
		text = _G["CHAT_HELP_TEXT_LINE"..i];
	end
end

function ChatFrame_DisplayGuildHelp(frame)
	if ( not frame ) then
		return;
	end

	local info = ChatTypeInfo["SYSTEM"];
	local i = 1;
	local text = _G["GUILD_HELP_TEXT_LINE"..i];
	while text do
		frame:AddMessage(text, info.r, info.g, info.b, info.id);
		i = i + 1;
		text = _G["GUILD_HELP_TEXT_LINE"..i];
	end
end

function ChatFrame_DisplayGameTime(frame)
	if ( not frame ) then
		return;
	end

	local info = ChatTypeInfo["SYSTEM"];
	frame:AddMessage(GameTime_GetGameTime(true), info.r, info.g, info.b, info.id);
end

function ChatFrame_TimeBreakDown(time)
	local days = floor(time / (60 * 60 * 24));
	local hours = floor((time - (days * (60 * 60 * 24))) / (60 * 60));
	local minutes = floor((time - (days * (60 * 60 * 24)) - (hours * (60 * 60))) / 60);
	local seconds = mod(time, 60);
	return days, hours, minutes, seconds;
end

function ChatFrame_DisplayTimePlayed(self, totalTime, levelTime)
	local info = ChatTypeInfo["SYSTEM"];
	local d;
	local h;
	local m;
	local s;
	d, h, m, s = ChatFrame_TimeBreakDown(totalTime);
	local string = format(TIME_PLAYED_TOTAL, format(TIME_DAYHOURMINUTESECOND, d, h, m, s));
	self:AddMessage(string, info.r, info.g, info.b, info.id);
	
	d, h, m, s = ChatFrame_TimeBreakDown(levelTime);
	local string = format(TIME_PLAYED_LEVEL, format(TIME_DAYHOURMINUTESECOND, d, h, m, s));
	self:AddMessage(string, info.r, info.g, info.b, info.id);
end

function ChatFrame_ChatPageUp()
	SELECTED_CHAT_FRAME:PageUp();
end

function ChatFrame_ChatPageDown()
	SELECTED_CHAT_FRAME:PageDown();
end

function ChatFrame_DisplayUsageError(messageTag)
	local info = ChatTypeInfo["SYSTEM"];
	DEFAULT_CHAT_FRAME:AddMessage(messageTag, info.r, info.g, info.b, info.id);
end

-- ChatEdit functions

local ChatEdit_LastTell = {};
for i = 1, NUM_REMEMBERED_TELLS, 1 do
	ChatEdit_LastTell[i] = "";
end
local ChatEdit_LastTold = "";

function ChatEdit_OnLoad(self)
	self:SetFrameLevel(self.chatFrame:GetFrameLevel()+1);
	self:SetAttribute("chatType", "SAY");
	self:SetAttribute("stickyType", "SAY");
	self.chatLanguage = GetDefaultLanguage();
	self:RegisterEvent("UPDATE_CHAT_COLOR");
	
	self.addSpaceToAutoComplete = true;
	
	if ( CHAT_OPTIONS.ONE_EDIT_AT_A_TIME == "many" ) then
		self:Show();
	end
end

function ChatEdit_OnEvent(self, event, ...)
	if ( event == "UPDATE_CHAT_COLOR" ) then
		local chatType = ...;
		if ( chatType == self:GetAttribute("chatType") ) then
			ChatEdit_UpdateHeader(self);
		end
	end
end

function ChatEdit_OnUpdate(self, elapsedSec)
	if ( self.setText == 1) then
		self:SetText(self.text);
		self.setText = 0;
		ChatEdit_ParseText(self, 0, true);
	end
end

function ChatEdit_OnShow(self)
	ChatEdit_ResetChatType(self);
end

function ChatEdit_ResetChatType(self)
	if ( self:GetAttribute("chatType") == "PARTY" and UnitName("party1") == "" ) then
		self:SetAttribute("chatType", "SAY");
	end
	if ( self:GetAttribute("chatType") == "RAID" and (GetNumRaidMembers() == 0) ) then
		self:SetAttribute("chatType", "SAY");
	end
	if ( (self:GetAttribute("chatType") == "GUILD" or self:GetAttribute("chatType") == "OFFICER") and not IsInGuild() ) then
		self:SetAttribute("chatType", "SAY");
	end
	if ( self:GetAttribute("chatType") == "BATTLEGROUND" and (GetNumRaidMembers() == 0) ) then
		self:SetAttribute("chatType", "SAY");
	end
	self.tabCompleteIndex = 1;
	self.tabCompleteText = nil;
	ChatEdit_UpdateHeader(self);
	ChatEdit_OnInputLanguageChanged(self);
	--[[if ( CHAT_OPTIONS.ONE_EDIT_AT_A_TIME == "old") then
		self:SetFocus();
	end]]
end

function ChatEdit_OnHide(self)
	if ( ACTIVE_CHAT_EDIT_BOX == self ) then
		ChatEdit_DeactivateChat(self);
	end
	
	if ( LAST_ACTIVE_CHAT_EDIT_BOX == self and self:IsShown() ) then	--Our parent was hidden. Let's find a new default frame.
		--We'll go with the active dock frame since people think of that as the primary chat.
		ChatEdit_SetLastActiveWindow(FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK).editBox);
	end
end

function ChatEdit_OnEditFocusGained(self)
	ChatEdit_ActivateChat(self);
end

function ChatEdit_OnEditFocusLost(self)
	AutoCompleteEditBox_OnEditFocusLost(self);
	ChatEdit_DeactivateChat(self);
end

function ChatEdit_ActivateChat(editBox)
	if ( ACTIVE_CHAT_EDIT_BOX and ACTIVE_CHAT_EDIT_BOX ~= editBox ) then
		ChatEdit_DeactivateChat(ACTIVE_CHAT_EDIT_BOX);
	end
	ACTIVE_CHAT_EDIT_BOX = editBox;
	
	ChatEdit_SetLastActiveWindow(editBox);
	
	--Stop any sort of fading
	UIFrameFadeRemoveFrame(editBox);
	
	editBox:Show();
	editBox:SetFocus();
	editBox:SetFrameStrata("DIALOG");
	editBox:Raise();
	
	editBox.header:Show();
	editBox.focusLeft:Show();
	editBox.focusRight:Show();
	editBox.focusMid:Show();
	editBox:SetAlpha(1.0);
	
	ChatEdit_UpdateHeader(editBox);
	
	if ( CHAT_SHOW_IME ) then
		_G[editBox:GetName().."Language"]:Show();
	end
end

local function ChatEdit_SetDeactivated(editBox)
	editBox:SetFrameStrata("LOW");
	if ( GetCVar("chatStyle") == "classic") then
		editBox:Hide();
	else
		editBox:SetText("");
		editBox.header:Hide();
		editBox:SetAlpha(0.35);
		editBox:ClearFocus();
		
		editBox.focusLeft:Hide();
		editBox.focusRight:Hide();
		editBox.focusMid:Hide();
		ChatEdit_ResetChatTypeToSticky(editBox);
		ChatEdit_ResetChatType(editBox);
	end
	_G[editBox:GetName().."Language"]:Hide();
end

function ChatEdit_DeactivateChat(editBox)
	if ( ACTIVE_CHAT_EDIT_BOX == editBox ) then
		ACTIVE_CHAT_EDIT_BOX = nil;
	end
	
	ChatEdit_SetDeactivated(editBox);
end

function ChatEdit_ChooseBoxForSend(preferredChatFrame)
	if ( GetCVar("chatStyle") == "classic" ) then
		return DEFAULT_CHAT_FRAME.editBox;
	elseif ( preferredChatFrame and preferredChatFrame:IsShown() ) then
		return preferredChatFrame.editBox;
	elseif ( ChatEdit_GetLastActiveWindow()  and ChatEdit_GetLastActiveWindow():GetParent():IsShown() ) then
		return ChatEdit_GetLastActiveWindow();
	else
		return FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK).editBox;
	end
end

function ChatEdit_SetLastActiveWindow(editBox)
	local previousValue = LAST_ACTIVE_CHAT_EDIT_BOX;
	if ( LAST_ACTIVE_CHAT_EDIT_BOX and LAST_ACTIVE_CHAT_EDIT_BOX ~= editBox ) then
		if ( GetCVar("chatStyle") == "im" ) then
			LAST_ACTIVE_CHAT_EDIT_BOX:Hide();
		end
	end
	
	LAST_ACTIVE_CHAT_EDIT_BOX = editBox;
	if ( GetCVar("chatStyle") == "im" and ACTIVE_CHAT_EDIT_BOX ~= editBox ) then
		editBox:Show();
		ChatEdit_SetDeactivated(editBox);
	end
	
	if ( previousValue ) then
		FCFClickAnywhereButton_UpdateState(previousValue.chatFrame.clickAnywhereButton);
	end
	FCFClickAnywhereButton_UpdateState(editBox.chatFrame.clickAnywhereButton);
end

function ChatEdit_GetActiveWindow()
	return ACTIVE_CHAT_EDIT_BOX;
end

function ChatEdit_GetLastActiveWindow()
	return LAST_ACTIVE_CHAT_EDIT_BOX;
end

function ChatEdit_FocusActiveWindow()
	local active = ChatEdit_GetActiveWindow()
	if ( active ) then
		ChatEdit_ActivateChat(active);
	end
end

function ChatEdit_InsertLink(text)
	if ( not text ) then
		return false;
	end
	
	local activeWindow = ChatEdit_GetActiveWindow();
	if ( activeWindow ) then
		-- add a space for proper parsing
		activeWindow:Insert(" "..text);
		return true;
	end
	if ( BrowseName and BrowseName:IsVisible() ) then
		local item;
		if ( strfind(text, "item:", 1, true) ) then
			item = GetItemInfo(text);
		end
		if ( item ) then
			BrowseName:SetText(item);
			return true;
		end
	end
	if ( MacroFrameText and MacroFrameText:IsVisible() ) then
		local item;
		if ( strfind(text, "item:", 1, true) ) then
			item = GetItemInfo(text);
		end
		local cursorPosition = MacroFrameText:GetCursorPosition();
		if (cursorPosition == 0 or strsub(MacroFrameText:GetText(), cursorPosition, cursorPosition) == "\n" ) then
			if ( item ) then
				if ( GetItemSpell(text) ) then
					MacroFrameText:Insert(SLASH_USE1.." "..item.."\n");
				else
					MacroFrameText:Insert(SLASH_EQUIP1.." "..item.."\n");
				end
			else
				MacroFrameText:Insert(SLASH_CAST1.." "..text.."\n");
			end
		else
			MacroFrameText:Insert(item or text);
		end
		return true;
	end
	return false;
end

function ChatEdit_GetLastTellTarget()
	for index, value in ipairs(ChatEdit_LastTell) do
		if ( value ~= "" ) then
			return value;
		end
	end
	return "";
end

function ChatEdit_SetLastTellTarget(target)
	local found = #ChatEdit_LastTell;
	for index, value in ipairs(ChatEdit_LastTell) do
		if ( strupper(target) == strupper(value) ) then
			found = index;
			break;
		end
	end

	for i = found, 2, -1 do
		ChatEdit_LastTell[i] = ChatEdit_LastTell[i-1];
	end
	ChatEdit_LastTell[1] = target;
end

function ChatEdit_GetNextTellTarget(target)
	if ( not target or target == "" ) then
		return ChatEdit_LastTell[1];
	end

	for i = 1, #ChatEdit_LastTell - 1, 1 do
		if ( ChatEdit_LastTell[i] == "" ) then
			break;
		elseif ( strupper(target) == strupper(ChatEdit_LastTell[i]) ) then
			if ( ChatEdit_LastTell[i+1] ~= "" ) then
				return ChatEdit_LastTell[i+1];
			else
				break;
			end
		end
	end

	return ChatEdit_LastTell[1];
end

function ChatEdit_GetLastToldTarget()
	return ChatEdit_LastTold;
end

function ChatEdit_SetLastToldTarget(name)
	ChatEdit_LastTold = name or "";
end

function ChatEdit_UpdateHeader(editBox)
	local type = editBox:GetAttribute("chatType");
	if ( not type ) then
		return;
	end

	local info = ChatTypeInfo[type];
	local header = _G[editBox:GetName().."Header"];
	if ( not header ) then
		return;
	end

	--BN_WHISPER FIXME
	if ( type == "WHISPER" ) then
		--If we have a BN presence ID for this name, it's a BN whisper.
		if ( BNet_GetPresenceID(editBox:GetAttribute("tellTarget")) ) then
			editBox:SetAttribute("chatType", "BN_WHISPER");
			ChatEdit_UpdateHeader(editBox);
			return;
		end
		
		header:SetFormattedText(CHAT_WHISPER_SEND, editBox:GetAttribute("tellTarget"));
	elseif ( type == "BN_WHISPER" ) then
		header:SetFormattedText(CHAT_BN_WHISPER_SEND, editBox:GetAttribute("tellTarget"));
	elseif ( type == "EMOTE" ) then
		header:SetFormattedText(CHAT_EMOTE_SEND, UnitName("player"));
	elseif ( type == "CHANNEL" ) then
		local channel, channelName, instanceID = GetChannelName(editBox:GetAttribute("channelTarget"));
		if ( channelName ) then
			if ( instanceID > 0 ) then
				channelName = channelName.." "..instanceID;
			end
			info = ChatTypeInfo["CHANNEL"..channel];
			editBox:SetAttribute("channelTarget", channel);
			header:SetFormattedText(CHAT_CHANNEL_SEND, channel, channelName);
		end
	elseif ( type == "BN_CONVERSATION" ) then
		local conversationID = editBox:GetAttribute("channelTarget");
		header:SetFormattedText(CHAT_BN_CONVERSATION_SEND, conversationID + MAX_WOW_CHAT_CHANNELS);
	else
		header:SetText(_G["CHAT_"..type.."_SEND"]);
	end

	header:SetTextColor(info.r, info.g, info.b);

	editBox:SetTextInsets(15 + header:GetWidth(), 13, 0, 0);
	editBox:SetTextColor(info.r, info.g, info.b);
	
	editBox.focusLeft:SetVertexColor(info.r, info.g, info.b);
	editBox.focusRight:SetVertexColor(info.r, info.g, info.b);
	editBox.focusMid:SetVertexColor(info.r, info.g, info.b);
end

function ChatEdit_AddHistory(editBox)
	local text = "";
	local type = editBox:GetAttribute("chatType");
	local header = _G["SLASH_"..type.."1"];
	if ( header ) then
		text = header;
	end

	if ( type == "WHISPER" ) then
		text = text.." "..editBox:GetAttribute("tellTarget");
	elseif ( type == "CHANNEL" ) then
		text = "/"..editBox:GetAttribute("channelTarget");
	end

	local editBoxText = editBox:GetText();
	if ( strlen(editBoxText) > 0 ) then
		text = text.." "..editBox:GetText();
	end

	if ( strlen(text) > 0 ) then
		editBox:AddHistoryLine(text);
	end
end

function ChatEdit_SendText(editBox, addHistory)
	ChatEdit_ParseText(editBox, 1);

	local type = editBox:GetAttribute("chatType");
	local text = editBox:GetText();
	if ( strfind(text, "%s*[^%s]+") ) then
		--BN_WHISPER FIXME
		if ( type == "WHISPER") then
			local target = editBox:GetAttribute("tellTarget");
			ChatEdit_SetLastToldTarget(target);
			SendChatMessage(text, type, editBox.language, target);
		elseif ( type == "BN_WHISPER" ) then
			local target = editBox:GetAttribute("tellTarget");
			local presenceID = BNet_GetPresenceID(target);
			if ( presenceID ) then
				ChatEdit_SetLastToldTarget(target);
				BNSendWhisper(presenceID, text);
			else
				local info = ChatTypeInfo["SYSTEM"]
				editBox.chatFrame:AddMessage(format(BN_UNABLE_TO_RESOLVE_NAME, target), info.r, info.g, info.b);
			end
		elseif ( type == "BN_CONVERSATION" ) then
			local target = tonumber(editBox:GetAttribute("channelTarget"));
			BNSendConversationMessage(target, text);
		elseif ( type == "CHANNEL") then
			SendChatMessage(text, type, editBox.language, editBox:GetAttribute("channelTarget"));
		else
			SendChatMessage(text, type, editBox.language);
		end
		if ( addHistory ) then
			ChatEdit_AddHistory(editBox);
		end
	end
end

function ChatEdit_OnEnterPressed(self)
	if(AutoCompleteEditBox_OnEnterPressed(self)) then
		return;
	end
	ChatEdit_SendText(self, 1);

	local type = self:GetAttribute("chatType");
	local chatFrame = self:GetParent();
	if ( chatFrame.isTemporary ) then --Temporary window sticky types never change.
		self:SetAttribute("stickyType", chatFrame.chatType);
		--BN_WHISPER FIXME
		if ( chatFrame.chatType == "WHISPER" or chatFrame.chatType == "BN_WHISPER" ) then
			self:SetAttribute("tellTarget", chatFrame.chatTarget);
		end
	elseif ( ChatTypeInfo[type].sticky == 1 ) then
		self:SetAttribute("stickyType", type);
	end
	
	ChatEdit_OnEscapePressed(self);
end

function ChatEdit_OnEscapePressed(editBox)
	if ( not AutoCompleteEditBox_OnEscapePressed(editBox) ) then
		ChatEdit_ResetChatTypeToSticky(editBox);
		if ( GetCVar("chatStyle") ~= "im" or editBox == MacroEditBox ) then
			editBox:SetText("");
			editBox:Hide();
		else
			ChatEdit_DeactivateChat(editBox);
		end
	end
end

function ChatEdit_ResetChatTypeToSticky(editBox)
	editBox:SetAttribute("chatType", editBox:GetAttribute("stickyType"));
end

function ChatEdit_OnSpacePressed(self)
	ChatEdit_ParseText(self, 0);
end

function ChatEdit_CustomTabPressed(self)
end

function ChatEdit_SecureTabPressed(self)
	local chatType = self:GetAttribute("chatType");
	if ( chatType == "WHISPER" or chatType == "BN_WHISPER" ) then
		local newTarget = ChatEdit_GetNextTellTarget(self:GetAttribute("tellTarget"));
		if ( newTarget and newTarget ~= "" ) then
			self:SetAttribute("chatType", "WHISPER");	--UpdateHeader will change it to BN_WHISPER if needed.
			self:SetAttribute("tellTarget", newTarget);
			ChatEdit_UpdateHeader(self);
		end
		return;
	end

	local text = self.tabCompleteText;
	if ( not text ) then
		text = self:GetText();
		self.tabCompleteText = text;
	end

	if ( strsub(text, 1, 1) ~= "/" ) then
		return;
	end

	-- Increment the current tabcomplete count
	local tabCompleteIndex = self.tabCompleteIndex;
	self.tabCompleteIndex = tabCompleteIndex + 1;

	-- If the string is in the format "/cmd blah", command will be "/cmd"
	local command = strmatch(text, "^(/[^%s]+)") or "";

	for index, value in pairs(ChatTypeInfo) do
		local i = 1;
		local cmdString = _G["SLASH_"..index..i];
		while ( cmdString ) do
			if ( strfind(cmdString, command, 1, 1) ) then
				tabCompleteIndex = tabCompleteIndex - 1;
				if ( tabCompleteIndex == 0 ) then
					self.ignoreTextChange = 1;
					self:SetText(cmdString);
					return;
				end
			end
			i = i + 1;
			cmdString = _G["SLASH_"..index..i];
		end
	end

	for index, value in pairs(SecureCmdList) do
		local i = 1;
		local cmdString = _G["SLASH_"..index..i];
		while ( cmdString ) do
			if ( strfind(cmdString, command, 1, 1) ) then
				tabCompleteIndex = tabCompleteIndex - 1;
				if ( tabCompleteIndex == 0 ) then
					self.ignoreTextChange = 1;
					self:SetText(cmdString);
					return;
				end
			end
			i = i + 1;
			cmdString = _G["SLASH_"..index..i];
		end
	end
	for index, value in pairs(SlashCmdList) do
		local i = 1;
		local cmdString = _G["SLASH_"..index..i];
		while ( cmdString ) do
			if ( strfind(cmdString, command, 1, 1) ) then
				tabCompleteIndex = tabCompleteIndex - 1;
				if ( tabCompleteIndex == 0 ) then
					self.ignoreTextChange = 1;
					self:SetText(cmdString);
					return;
				end
			end
			i = i + 1;
			cmdString = _G["SLASH_"..index..i];
		end
	end

	local i = 1;
	local j = 1;
	local cmdString = _G["EMOTE"..i.."_CMD"..j];
	while ( cmdString ) do
		if ( strfind(cmdString, command, 1, 1) ) then
			tabCompleteIndex = tabCompleteIndex - 1;
			if ( tabCompleteIndex == 0 ) then
				self.ignoreTextChange = 1;
				self:SetText(cmdString);
				return;
			end
		end
		j = j + 1;
		cmdString = _G["EMOTE"..i.."_CMD"..j];
		if ( not cmdString ) then
			i = i + 1;
			j = 1;
			cmdString = _G["EMOTE"..i.."_CMD"..j];
		end
	end

	-- No tab completion
	self:SetText(self.tabCompleteText);
end

function ChatEdit_OnTabPressed(self)
	if ( not AutoCompleteEditBox_OnTabPressed(self) ) then
		if ( securecall("ChatEdit_CustomTabPressed") ) then
			return;
		end
		ChatEdit_SecureTabPressed(self);
	end
end

function ChatEdit_OnTextChanged(self, userInput)
	ChatEdit_ParseText(self, 0);
	if ( not self.ignoreTextChange ) then
		self.tabCompleteIndex = 1;
		self.tabCompleteText = nil;
	end
	self.ignoreTextChange = nil;
	local regex = "^((/[^%s]+)%s+)(.+)"
	local full, command, target = strmatch(self:GetText(), regex);
	if ( not target or (strsub(target, 1, 1) == "|") ) then
		AutoComplete_HideIfAttachedTo(self);
		return;
	end
	
	if ( userInput ) then
		self.autoCompleteRegex = regex;
		self.autoCompleteFormatRegex = "%2$s%1$s"
		self.autoCompleteXOffset = 35;
		AutoComplete_Update(self, target, self:GetUTF8CursorPosition() - strlenutf8(command) - 1);
	end
end

function ChatEdit_OnTextSet(self)
	ChatEdit_ParseText(self, 0);
end

function ChatEdit_LanguageShow()
	CHAT_SHOW_IME = true;
end

function ChatEdit_OnInputLanguageChanged(self)
	local button = _G[self:GetName().."Language"];
	local variable = _G["INPUT_"..self:GetInputLanguage()];
	button:SetText(variable);
end

local function processChatType(editBox, msg, index, send)
	editBox.autoCompleteParams = AUTOCOMPLETE_LIST[index];
-- this is a special function for "ChatEdit_HandleChatType"
	if ( ChatTypeInfo[index] ) then
		if ( index == "WHISPER" ) then
			local targetFound = ChatEdit_ExtractTellTarget(editBox, msg);
			if ( send == 1 and not targetFound) then
				ChatEdit_OnEscapePressed(editBox);
			end	
		elseif ( index == "REPLY" ) then
			local lastTell = ChatEdit_GetLastTellTarget();
			if ( lastTell ~= "" ) then
				--BN_WHISPER FIXME
				editBox:SetAttribute("chatType", "WHISPER");
				editBox:SetAttribute("tellTarget", lastTell);
				editBox:SetText(msg);
				ChatEdit_UpdateHeader(editBox);
			else
				if ( send == 1 ) then
					ChatEdit_OnEscapePressed(editBox);
				end
			end
		elseif (index == "CHANNEL") then
			ChatEdit_ExtractChannel(editBox, msg);
		elseif ( index == "BN_CONVERSATION" ) then
			ChatEdit_ExtractBNConversation(editBox, msg);
		else
			editBox:SetAttribute("chatType", index);
			editBox:SetText(msg);
			ChatEdit_UpdateHeader(editBox);
		end
		return true;
	end
	return false;
end

function ChatEdit_HandleChatType(editBox, msg, command, send)
	local channel = strmatch(command, "/([0-9]+)");

	if( channel ) then
		local chanNum = tonumber(channel);
		if ( chanNum > 0 and chanNum <= MAX_WOW_CHAT_CHANNELS ) then
			local channelNum, channelName = GetChannelName(channel);
			if ( channelNum > 0 ) then
				editBox:SetAttribute("channelTarget", channelNum);
				editBox:SetAttribute("chatType", "CHANNEL");
				editBox:SetText(msg);
				ChatEdit_UpdateHeader(editBox);
				return true;
			end
		elseif ( chanNum > MAX_WOW_CHAT_CHANNELS ) then	--This is a B.Net chat.
			local conversationNum = chanNum - MAX_WOW_CHAT_CHANNELS;
			if ( BNGetConversationInfo(conversationNum) ) then
				editBox:SetAttribute("channelTarget", conversationNum);
				editBox:SetAttribute("chatType", "BN_CONVERSATION");
				editBox:SetText(msg);
				ChatEdit_UpdateHeader(editBox);
				return true;
			end
		end
	else
		-- first check the hash table
		if ( hash_ChatTypeInfoList[command] ) then
			return processChatType(editBox, msg, hash_ChatTypeInfoList[command], send);
		end
		for index, value in pairs(SecureCmdList) do
			local i = 1;
			local cmdString = _G["SLASH_"..index..i];
			while ( cmdString ) do
				cmdString = strupper(cmdString);
				if ( cmdString == command ) then
					hash_ChatTypeInfoList[command] = index;
					return processChatType(editBox, msg, index, send);
				end
				i = i + 1;
				cmdString = _G["SLASH_"..index..i];
			end
		end
		for index, value in pairs(SlashCmdList) do
			local i = 1;
			local cmdString = _G["SLASH_"..index..i];
			while ( cmdString ) do
				cmdString = strupper(cmdString);
				if ( cmdString == command ) then
					hash_ChatTypeInfoList[command] = index;
					return processChatType(editBox, msg, index, send);
				end
				i = i + 1;
				cmdString = _G["SLASH_"..index..i];
			end
		end
		for index, value in pairs(ChatTypeInfo) do
			local i = 1;
			local cmdString = _G["SLASH_"..index..i];
			while ( cmdString ) do
				cmdString = strupper(cmdString);
				if ( cmdString == command ) then
					hash_ChatTypeInfoList[command] = index;	-- add to hash table
					return processChatType(editBox, msg, index, send);
				end
				i = i + 1;
				cmdString = _G["SLASH_"..index..i];
			end
		end
	end
	--This isn't one we found in our list, so we're not going to autocomplete.
	editBox.autoCompleteParams = nil;
	return false;
end

function ChatEdit_ParseText(editBox, send, parseIfNoSpaces)

	local text = editBox:GetText();
	if ( strlen(text) <= 0 ) then
		return;
	end

	if ( strsub(text, 1, 1) ~= "/" ) then
		return;
	end

	--Do not bother parsing if there is no space in the message and we aren't sending.
	if ( send ~= 1 and not parseIfNoSpaces and not strfind(text, "%s") ) then
		return;
	end
	
	-- If the string is in the format "/cmd blah", command will be "/cmd"
	local command = strmatch(text, "^(/[^%s]+)") or "";
	local msg = "";


	if ( command ~= text ) then
		msg = strsub(text, strlen(command) + 2);
	end

	command = strupper(command);

	-- Check and see if we've got secure commands to run before we look for chat types or slash commands.	
	-- This hash table is prepopulated, unlike the other ones, since nobody can add secure commands. (See line 1205 or thereabouts)
	-- We don't want this code to run unless send is 1, but we need ChatEdit_HandleChatType to run when send is 1 as well, which is why we
	-- didn't just move ChatEdit_HandleChatType inside the send == 0 conditional, which could have also solved the problem with insecure
	-- code having the ability to affect secure commands.
	
	if ( send == 1 and hash_SecureCmdList[command] ) then
		hash_SecureCmdList[command](strtrim(msg));
		editBox:AddHistoryLine(text);
		ChatEdit_OnEscapePressed(editBox);
		return;
	end

	-- Handle chat types. No need for a securecall here, since we should be done with anything secure.
	if ( ChatEdit_HandleChatType(editBox, msg, command, send) ) then
		return;
	end

	if ( send == 0 ) then
		return;
	end

	-- Check the hash tables for slash commands and emotes to see if we've run this before. 
	if ( hash_SlashCmdList[command] ) then
		-- if the code in here changes - change the corresponding code below
		hash_SlashCmdList[command](strtrim(msg), editBox);
		editBox:AddHistoryLine(text);
		ChatEdit_OnEscapePressed(editBox);
		return;
	elseif ( hash_EmoteTokenList[command] ) then
		-- if the code in here changes - change the corresponding code below
		DoEmote(hash_EmoteTokenList[command], msg);
		editBox:AddHistoryLine(text);
		ChatEdit_OnEscapePressed(editBox);
		return;
	end

	-- If we didn't have the command in the hash tables, look for it the slow way...
	for index, value in pairs(SlashCmdList) do
		local i = 1;
		local cmdString = _G["SLASH_"..index..i];
		while ( cmdString ) do
			cmdString = strupper(cmdString);
			if ( cmdString == command ) then
				-- if the code in here changes - change the corresponding code above
				hash_SlashCmdList[command] = value;	-- add to hash
				value(strtrim(msg), editBox);
				editBox:AddHistoryLine(text);
				ChatEdit_OnEscapePressed(editBox);
				return;
			end
			i = i + 1;
			cmdString = _G["SLASH_"..index..i];
		end
	end

	local i = 1;
	local j = 1;
	local cmdString = _G["EMOTE"..i.."_CMD"..j];
	while ( i <= MAXEMOTEINDEX ) do
		if ( cmdString and strupper(cmdString) == command ) then
			local token = _G["EMOTE"..i.."_TOKEN"];
			-- if the code in here changes - change the corresponding code above
			if ( token ) then
				hash_EmoteTokenList[command] = token;	-- add to hash
				DoEmote(token, msg);
			end
			editBox:AddHistoryLine(text);
			ChatEdit_OnEscapePressed(editBox);
			return;
		end
		j = j + 1;
		cmdString = _G["EMOTE"..i.."_CMD"..j];
		if ( not cmdString ) then
			i = i + 1;
			j = 1;
			cmdString = _G["EMOTE"..i.."_CMD"..j];
		end
	end

	-- Unrecognized chat command, show simple help text
	if ( editBox.chatFrame ) then
		local info = ChatTypeInfo["SYSTEM"];
		editBox.chatFrame:AddMessage(HELP_TEXT_SIMPLE, info.r, info.g, info.b, info.id);
	end
	
	-- Reset the chat type and clear the edit box's contents
	ChatEdit_OnEscapePressed(editBox);
	return;
end

local tellTargetExtractionAutoComplete = AUTOCOMPLETE_LIST.ALL;
function ChatEdit_ExtractTellTarget(editBox, msg)
	-- Grab the string after the slash command
	local target = strmatch(msg, "%s*(.*)");
	
	--If we haven't even finished one word, we aren't done.
	if ( not target or not strfind(target, "%s") or (strsub(target, 1, 1) == "|") ) then
		return false;
	end
	
	if ( GetAutoCompleteResults(target, tellTargetExtractionAutoComplete.include, tellTargetExtractionAutoComplete.exclude, 1, nil, true) ) then
		--Even if there's a space, we still want to let the person keep typing -- they may be trying to type whatever is in AutoComplete.
		return false;
	end
	
	--Keep pulling off everything after the last space until we either have something on the AutoComplete list or only a single word is left.
	while ( strfind(target, "%s") ) do
		--Pull off everything after the last space.
		target = strmatch(target, "(.+)%s+[^%s]*");
		if ( GetAutoCompleteResults(target, tellTargetExtractionAutoComplete.include, tellTargetExtractionAutoComplete.exclude, 1, nil, true)  ) then
			break;
		end
	end

	msg = strsub(msg, strlen(target) + 2);

	editBox:SetAttribute("tellTarget", target);
	--BN_WHISPER FIXME
	editBox:SetAttribute("chatType", "WHISPER");
	editBox:SetText(msg);
	ChatEdit_UpdateHeader(editBox);
	return true;
end

function ChatEdit_ExtractChannel(editBox, msg)
	local target = strmatch(msg, "%s*([^%s]+)");
	if ( not target ) then
		return;
	end
	
	local channelNum, channelName = GetChannelName(target);
	if ( channelNum <= 0 ) then
		return;
	end

	msg = strsub(msg, strlen(target) + 2);

	editBox:SetAttribute("channelTarget", channelNum);
	editBox:SetAttribute("chatType", "CHANNEL");
	editBox:SetText(msg);
	ChatEdit_UpdateHeader(editBox);
end

function ChatEdit_ExtractBNConversation(editBox, msg)
	local target = tonumber(strmatch(msg, "%s*(%d+)"));
	if ( not target ) then
		return;
	end
	
	local conversationType = BNGetConversationInfo(target);
	if ( not conversationType ) then
		return;
	end
	
	msg = strsub(msg, strlen(tostring(target)) + 2);
	
	editBox:SetAttribute("channelTarget", target);
	editBox:SetAttribute("chatType", "BN_CONVERSATION");
	editBox:SetText(msg);
	ChatEdit_UpdateHeader(editBox);
end

-- Chat menu functions
function ChatMenu_SetChatType(chatFrame, type)
	local editBox = ChatFrame_OpenChat("");
	editBox:SetAttribute("chatType", type);
	ChatEdit_UpdateHeader(editBox);
end

function ChatMenu_Say(self)
	ChatMenu_SetChatType(self:GetParent().chatFrame, "SAY");
end

function ChatMenu_Party(self)
	ChatMenu_SetChatType(self:GetParent().chatFrame, "PARTY");
end

function ChatMenu_Raid(self)
	ChatMenu_SetChatType(self:GetParent().chatFrame, "RAID");
end

function ChatMenu_Battleground(self)
	ChatMenu_SetChatType(self:GetParent().chatFrame, "BATTLEGROUND");
end

function ChatMenu_Guild(self)
	ChatMenu_SetChatType(self:GetParent().chatFrame, "GUILD");
end

function ChatMenu_Yell(self)
	ChatMenu_SetChatType(self:GetParent().chatFrame, "YELL");
end

function ChatMenu_Whisper(self)
	local editBox = ChatFrame_OpenChat(SLASH_WHISPER1.." ", chatFrame);
	editBox:SetText(SLASH_WHISPER1.." "..editBox:GetText());
end

function ChatMenu_Emote(self)
	ChatMenu_SetChatType(self:GetParent().chatFrame, "EMOTE");
end

function ChatMenu_Reply(self)
	ChatFrame_ReplyTell();
end

function ChatMenu_VoiceMacro(self)
	ChatMenu_SetChatType(self:GetParent().chatFrame, "YELL");
end

function ChatMenu_OnLoad(self)
	self.chatFrame = DEFAULT_CHAT_FRAME;
	
	UIMenu_Initialize(self);
	UIMenu_AddButton(self, SAY_MESSAGE, SLASH_SAY1, ChatMenu_Say);
	UIMenu_AddButton(self, PARTY_MESSAGE, SLASH_PARTY1, ChatMenu_Party);
	UIMenu_AddButton(self, RAID_MESSAGE, SLASH_RAID1, ChatMenu_Raid);
	UIMenu_AddButton(self, BATTLEGROUND_MESSAGE, SLASH_BATTLEGROUND1, ChatMenu_Battleground);
	UIMenu_AddButton(self, GUILD_MESSAGE, SLASH_GUILD1, ChatMenu_Guild);
	UIMenu_AddButton(self, YELL_MESSAGE, SLASH_YELL1, ChatMenu_Yell);
	UIMenu_AddButton(self, WHISPER_MESSAGE, SLASH_WHISPER1, ChatMenu_Whisper);
	UIMenu_AddButton(self, EMOTE_MESSAGE, SLASH_EMOTE1, ChatMenu_Emote, "EmoteMenu");
	UIMenu_AddButton(self, REPLY_MESSAGE, SLASH_REPLY1, ChatMenu_Reply);
	UIMenu_AddButton(self, LANGUAGE, nil, nil, "LanguageMenu");
	UIMenu_AddButton(self, VOICEMACRO_LABEL, nil, nil, "VoiceMacroMenu");
	UIMenu_AddButton(self, MACRO, SLASH_MACRO1, ShowMacroFrame);
	UIMenu_AutoSize(self);
end

function ChatMenu_OnShow(self)
	UIMenu_OnShow(self);
	EmoteMenu:Hide();
	LanguageMenu:Hide();
	VoiceMacroMenu:Hide();
	
	self:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
	self:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
end

function EmoteMenu_Click(self)
	DoEmote(EmoteList[self:GetID()]);
	ChatMenu:Hide();
end

function TextEmoteSort(token1, token2)
	local i = 1;
	local string1, string2;
	local token = _G["EMOTE"..i.."_TOKEN"];
	while ( token ) do
		if ( token == token1 ) then
			string1 = _G["EMOTE"..i.."_CMD1"];
			if ( string2 ) then
				break;
			end
		end
		if ( token == token2 ) then
			string2 = _G["EMOTE"..i.."_CMD1"];
			if ( string1 ) then
				break;
			end
		end
		i = i + 1;
		token = _G["EMOTE"..i.."_TOKEN"];
	end
	return string1 < string2;
end

function OnMenuLoad(self,list,func)
	sort(list, TextEmoteSort);
	UIMenu_Initialize(self);
	self.parentMenu = "ChatMenu";
	for index, value in pairs(list) do
		local i = 1;
		local token = _G["EMOTE"..i.."_TOKEN"];
		while ( token ) do
			if ( token == value ) then
				break;
			end
			i = i + 1;
			token = _G["EMOTE"..i.."_TOKEN"];
		end
		local label = _G["EMOTE"..i.."_CMD1"];
		if ( not label ) then
			label = value;
		end
		UIMenu_AddButton(self, label, nil, func);
	end
	UIMenu_AutoSize(self);
end

function EmoteMenu_OnLoad(self)
	OnMenuLoad(self, EmoteList, EmoteMenu_Click);
end

function LanguageMenu_OnLoad(self)
	UIMenu_Initialize(self);
	self.parentMenu = "ChatMenu";
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("LANGUAGE_LIST_CHANGED");
end

function VoiceMacroMenu_Click(self)
	DoEmote(TextEmoteSpeechList[self:GetID()]);
	ChatMenu:Hide();
end

function VoiceMacroMenu_OnLoad(self)
	OnMenuLoad(self, TextEmoteSpeechList, VoiceMacroMenu_Click);
end

function LanguageMenu_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self:Hide();
		UIMenu_Initialize(self);
		LanguageMenu_LoadLanguages(self);
		self:GetParent().chatFrame.editBox.language = GetDefaultLanguage();
		return;
	end
	if ( event == "LANGUAGE_LIST_CHANGED" ) then
		self:Hide();
		UIMenu_Initialize(self);
		LanguageMenu_LoadLanguages(self);
		return;
	end
end

function LanguageMenu_LoadLanguages(self)
	local numLanguages = GetNumLanguages();
	local i;
	local editBoxLanguage = self:GetParent().chatFrame.editBox.language;
	local languageKnown = false;
	for i = 1, numLanguages, 1 do
		local language = GetLanguageByIndex(i);
		UIMenu_AddButton(self, language, nil, LanguageMenu_Click);
		if ( language == editBoxLanguage ) then
			languageKnown = true;
		end
	end
	
	if ( languageKnown ~= true ) then
		self:GetParent().chatFrame.editBox.language = GetLanguageByIndex(1);
	end
	
	UIMenu_AutoSize(self);
end

function LanguageMenu_Click(self)
	self:GetParent():GetParent().chatFrame.editBox.language = GetLanguageByIndex(self:GetID());
	ChatMenu:Hide();
end

function ChatFrame_ActivateCombatMessages(chatFrame)
	ChatFrame_AddMessageGroup(chatFrame, "OPENING");
	ChatFrame_AddMessageGroup(chatFrame, "TRADESKILLS");
	ChatFrame_AddMessageGroup(chatFrame, "PET_INFO");
	ChatFrame_AddMessageGroup(chatFrame, "COMBAT_MISC_INFO");
	ChatFrame_AddMessageGroup(chatFrame, "COMBAT_XP_GAIN");
	ChatFrame_AddMessageGroup(chatFrame, "COMBAT_HONOR_GAIN");
	ChatFrame_AddMessageGroup(chatFrame, "COMBAT_FACTION_CHANGE");
end

function ChatChannelDropDown_Show(chatFrame, chatType, chatTarget, chatName)
	HideDropDownMenu(1);
	ChatChannelDropDown.initialize = ChatChannelDropDown_Initialize;
	ChatChannelDropDown.displayMode = "MENU";
	ChatChannelDropDown.chatType = chatType;
	ChatChannelDropDown.chatTarget = chatTarget;
	ChatChannelDropDown.chatName = chatName;
	ChatChannelDropDown.chatFrame = chatFrame;
	ToggleDropDownMenu(1, nil, ChatChannelDropDown, "cursor");
end

function ChatChannelDropDown_Initialize()
	local frame = ChatChannelDropDown;
	
	local info = UIDropDownMenu_CreateInfo();
	
	info.text = frame.chatName;
	info.notCheckable = true;
	info.isTitle = true;
	UIDropDownMenu_AddButton(info, 1);
	
	info = UIDropDownMenu_CreateInfo();
	
	if ( frame.chatType ~= "BN_CONVERSATION" or (FCFManager_GetNumDedicatedFrames(frame.chatType, frame.chatTarget) == 0)) then
		if ( frame.chatType == "BN_CONVERSATION" ) then
			info.text = MOVE_TO_CONVERSATION_WINDOW;
		else
			info.text = MOVE_TO_NEW_WINDOW;
		end
		info.notCheckable = 1;
		info.func = ChatChannelDropDown_PopOutChat;
		info.arg1 = frame.chatType;
		info.arg2 = frame.chatTarget;
		
		if ( frame.chatType ~= "BN_CONVERSATION" and FCF_GetNumActiveChatFrames() == NUM_CHAT_WINDOWS ) then
			info.disabled = 1;
		end
		
		UIDropDownMenu_AddButton(info);
	end
	
	if ( frame.chatType == "BN_CONVERSATION" ) then
		info = UIDropDownMenu_CreateInfo();
		info.text = INVITE_FRIEND_TO_CONVERSATION;
		info.notCheckable = 1;
		info.func = ChatChannelDropDown_InviteToConversation;
		info.arg1 = frame.chatType;
		info.arg2 = frame.chatTarget;
		UIDropDownMenu_AddButton(info);
		
		info = UIDropDownMenu_CreateInfo();
		info.text = LEAVE_CONVERSATION;
		info.notCheckable = 1;
		info.func = ChatChannelDropDown_LeaveConversation;
		info.arg1 = frame.chatType;
		info.arg2 = frame.chatTarget;
		UIDropDownMenu_AddButton(info);
	end
end

function ChatChannelDropDown_InviteToConversation(self, chatType, chatTarget)
	if ( chatType == "BN_CONVERSATION" ) then
		BNConversationInvite_SelectPlayers(chatTarget);
	end
end

function ChatChannelDropDown_LeaveConversation(self, chatType, chatTarget)
	BNLeaveConversation(chatTarget);
end

function ChatChannelDropDown_PopOutChat(self, chatType, chatTarget)
	local sourceChatFrame = ChatChannelDropDown.chatFrame;
	
	if ( chatType == "BN_CONVERSATION" ) then
		FCF_OpenTemporaryWindow(chatType, chatTarget, sourceChatFrame, true);
	else
		local windowName;
		if ( chatType == "CHANNEL" ) then
			windowName = Chat_GetChannelShortcutName(chatTarget);
		else
			windowName = _G[chatType];
		end
		local frame = FCF_OpenNewWindow(windowName);
		FCF_CopyChatSettings(frame, sourceChatFrame);
		
		ChatFrame_RemoveAllMessageGroups(frame);
		ChatFrame_RemoveAllChannels(frame);
		ChatFrame_ReceiveAllPrivateMessages(frame);
		ChatFrame_ReceiveAllBNConversations(frame);
		
		ChatFrame_AddMessageGroup(frame, chatType);
		
		if ( CHAT_CATEGORY_LIST[chatType] ) then
			for _, chat in pairs(CHAT_CATEGORY_LIST[chatType]) do
				ChatFrame_AddMessageGroup(frame, chat);
			end
		end
		
		frame.editBox:SetAttribute("chatType", chatType);
		frame.editBox:SetAttribute("stickyType", chatType);
		
		if ( chatType == "CHANNEL" ) then
			frame.editBox:SetAttribute("channelTarget", chatTarget);
			ChatFrame_AddChannel(frame, Chat_GetChannelShortcutName(chatTarget));
		end
		
		--Remove the things popped out from the source chat frame.
		if ( chatType == "CHANNEL" ) then
			ChatFrame_RemoveChannel(sourceChatFrame, Chat_GetChannelShortcutName(chatTarget));
		else
			ChatFrame_RemoveMessageGroup(sourceChatFrame, chatType);
			if ( CHAT_CATEGORY_LIST[chatType] ) then
				for _, chat in pairs(CHAT_CATEGORY_LIST[chatType]) do
					ChatFrame_RemoveMessageGroup(sourceChatFrame, chat);
				end
			end
		end
		
		--Copy over messages
		local accessID = ChatHistory_GetAccessID(chatType, chatTarget);
		for i = 1, sourceChatFrame:GetNumMessages(accessID) do
			local text, accessID, lineID, extraData = sourceChatFrame:GetMessageInfo(i, accessID);
			local cType, cTarget = ChatHistory_GetChatType(extraData);

			local info = ChatTypeInfo[cType];
			frame:AddMessage(text, info.r, info.g, info.b, lineID, false, accessID, extraData);
		end
		--Remove the messages from the old frame.
		sourceChatFrame:RemoveMessagesByAccessID(accessID);
	end
end

function Chat_GetChannelShortcutName(index)
	local _, name = GetChannelName(index);
	name = strtrim(name:match("([^%-]+)"));
	return name;
end

function ChatChannelDropDown_PopInChat(self, chatType, chatTarget)
	--PopOutChat_PopInChat(chatType, chatTarget);
end

function Chat_GetColoredChatName(chatType, chatTarget)
	if ( chatType == "CHANNEL" ) then
		local info = ChatTypeInfo["CHANNEL"..chatTarget];
		local colorString = format("|cff%02x%02x%02x", info.r * 255, info.g * 255, info.b * 255);
		local chanNum, channelName = GetChannelName(chatTarget);
		return format("%s|Hchannel:channel:%d|h[%d. %s]|h", colorString, chanNum, chanNum, gsub(channelName, "%s%-%s.*", ""));	--The gsub removes zone-specific markings (e.g. "General - Ironforge" to "General")
	elseif ( chatType == "WHISPER" ) then
		local info = ChatTypeInfo["WHISPER"];
		local colorString = format("|cff%02x%02x%02x", info.r * 255, info.g * 255, info.b * 255);
		return format("%s[%s] |Hplayer:%3$s|h[%3$s]|h|r", colorString, _G[chatType], chatTarget);
	else
		local info = ChatTypeInfo[chatType];
		local colorString = format("|cff%02x%02x%02x", info.r * 255, info.g * 255, info.b * 255);
		return format("%s|Hchannel:%s|h[%s]|h|r", colorString, chatType, _G[chatType]);
	end
end