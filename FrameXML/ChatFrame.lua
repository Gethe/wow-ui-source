MESSAGE_SCROLLBUTTON_INITIAL_DELAY = 0;
MESSAGE_SCROLLBUTTON_SCROLL_DELAY = 0.05;
CHAT_BUTTON_FLASH_TIME = 0.5;
CHAT_TELL_ALERT_TIME = 300;
NUM_CHAT_WINDOWS = 7;
DEFAULT_CHAT_FRAME = ChatFrame1;
NUM_REMEMBERED_TELLS = 10;

ChatTypeInfo = { };
ChatTypeInfo["SAY"]										= { sticky = 1 };
ChatTypeInfo["PARTY"]									= { sticky = 1 };
ChatTypeInfo["RAID"]									= { sticky = 1 };
ChatTypeInfo["GUILD"]									= { sticky = 1 };
ChatTypeInfo["OFFICER"]									= { sticky = 0 };
ChatTypeInfo["YELL"]									= { sticky = 0 };
ChatTypeInfo["WHISPER"]									= { sticky = 0 };
ChatTypeInfo["WHISPER_INFORM"]							= { sticky = 0 };
ChatTypeInfo["REPLY"]									= { sticky = 0 };
ChatTypeInfo["EMOTE"]									= { sticky = 0 };
ChatTypeInfo["TEXT_EMOTE"]								= { sticky = 0 };
ChatTypeInfo["SYSTEM"]									= { sticky = 0 };
ChatTypeInfo["MONSTER_WHISPER"]							= { sticky = 0 };
ChatTypeInfo["MONSTER_SAY"]								= { sticky = 0 };
ChatTypeInfo["MONSTER_YELL"]							= { sticky = 0 };
ChatTypeInfo["MONSTER_EMOTE"]							= { sticky = 0 };
ChatTypeInfo["CHANNEL"]									= { sticky = 0 };
ChatTypeInfo["CHANNEL_JOIN"]							= { sticky = 0 };
ChatTypeInfo["CHANNEL_LEAVE"]							= { sticky = 0 };
ChatTypeInfo["CHANNEL_LIST"]							= { sticky = 0 };
ChatTypeInfo["CHANNEL_NOTICE"]							= { sticky = 0 };
ChatTypeInfo["CHANNEL_NOTICE_USER"]						= { sticky = 0 };
ChatTypeInfo["AFK"]										= { sticky = 0 };
ChatTypeInfo["DND"]										= { sticky = 0 };
ChatTypeInfo["IGNORED"]									= { sticky = 0 };
ChatTypeInfo["SKILL"]									= { sticky = 0 };
ChatTypeInfo["LOOT"]									= { sticky = 0 };
ChatTypeInfo["COMBAT_ERROR"]							= { sticky = 0 };
ChatTypeInfo["COMBAT_MISC_INFO"]						= { sticky = 0 };
ChatTypeInfo["CHANNEL1"]								= { sticky = 0 };
ChatTypeInfo["CHANNEL2"]								= { sticky = 0 };
ChatTypeInfo["CHANNEL3"]								= { sticky = 0 };
ChatTypeInfo["CHANNEL4"]								= { sticky = 0 };
ChatTypeInfo["CHANNEL5"]								= { sticky = 0 };
ChatTypeInfo["CHANNEL6"]								= { sticky = 0 };
ChatTypeInfo["CHANNEL7"]								= { sticky = 0 };
ChatTypeInfo["CHANNEL8"]								= { sticky = 0 };
ChatTypeInfo["CHANNEL9"]								= { sticky = 0 };
ChatTypeInfo["CHANNEL10"]								= { sticky = 0 };
ChatTypeInfo["COMBAT_SELF_HITS"]						= { sticky = 0 };
ChatTypeInfo["COMBAT_SELF_MISSES"]						= { sticky = 0 };
ChatTypeInfo["COMBAT_PET_HITS"]							= { sticky = 0 };
ChatTypeInfo["COMBAT_PET_MISSES"]						= { sticky = 0 };
ChatTypeInfo["COMBAT_PARTY_HITS"]						= { sticky = 0 };
ChatTypeInfo["COMBAT_PARTY_MISSES"]						= { sticky = 0 };
ChatTypeInfo["COMBAT_FRIENDLYPLAYER_HITS"]				= { sticky = 0 };
ChatTypeInfo["COMBAT_FRIENDLYPLAYER_MISSES"]			= { sticky = 0 };
ChatTypeInfo["COMBAT_HOSTILEPLAYER_HITS"]				= { sticky = 0 };
ChatTypeInfo["COMBAT_HOSTILEPLAYER_MISSES"]				= { sticky = 0 };
ChatTypeInfo["COMBAT_CREATURE_VS_SELF_HITS"]			= { sticky = 0 };
ChatTypeInfo["COMBAT_CREATURE_VS_SELF_MISSES"]			= { sticky = 0 };
ChatTypeInfo["COMBAT_CREATURE_VS_PARTY_HITS"]			= { sticky = 0 };
ChatTypeInfo["COMBAT_CREATURE_VS_PARTY_MISSES"]			= { sticky = 0 };
ChatTypeInfo["COMBAT_CREATURE_VS_CREATURE_HITS"]		= { sticky = 0 };
ChatTypeInfo["COMBAT_CREATURE_VS_CREATURE_MISSES"]		= { sticky = 0 };
ChatTypeInfo["COMBAT_FRIENDLY_DEATH"]					= { sticky = 0 };
ChatTypeInfo["COMBAT_HOSTILE_DEATH"]					= { sticky = 0 };
ChatTypeInfo["COMBAT_XP_GAIN"]							= { sticky = 0 };
ChatTypeInfo["COMBAT_HONOR_GAIN"]						= { sticky = 0 };
ChatTypeInfo["SPELL_SELF_DAMAGE"]						= { sticky = 0 };
ChatTypeInfo["SPELL_SELF_BUFF"]							= { sticky = 0 };
ChatTypeInfo["SPELL_PET_DAMAGE"]						= { sticky = 0 };
ChatTypeInfo["SPELL_PET_BUFF"]							= { sticky = 0 };
ChatTypeInfo["SPELL_PARTY_DAMAGE"]						= { sticky = 0 };
ChatTypeInfo["SPELL_PARTY_BUFF"]						= { sticky = 0 };
ChatTypeInfo["SPELL_FRIENDLYPLAYER_DAMAGE"]				= { sticky = 0 };
ChatTypeInfo["SPELL_FRIENDLYPLAYER_BUFF"]				= { sticky = 0 };
ChatTypeInfo["SPELL_HOSTILEPLAYER_DAMAGE"]				= { sticky = 0 };
ChatTypeInfo["SPELL_HOSTILEPLAYER_BUFF"]				= { sticky = 0 };
ChatTypeInfo["SPELL_CREATURE_VS_SELF_DAMAGE"]			= { sticky = 0 };
ChatTypeInfo["SPELL_CREATURE_VS_SELF_BUFF"]				= { sticky = 0 };
ChatTypeInfo["SPELL_CREATURE_VS_PARTY_DAMAGE"]			= { sticky = 0 };
ChatTypeInfo["SPELL_CREATURE_VS_PARTY_BUFF"]			= { sticky = 0 };
ChatTypeInfo["SPELL_CREATURE_VS_CREATURE_DAMAGE"]		= { sticky = 0 };
ChatTypeInfo["SPELL_CREATURE_VS_CREATURE_BUFF"]			= { sticky = 0 };
ChatTypeInfo["SPELL_TRADESKILLS"]						= { sticky = 0 };
ChatTypeInfo["SPELL_DAMAGESHIELDS_ON_SELF"]				= { sticky = 0 };
ChatTypeInfo["SPELL_DAMAGESHIELDS_ON_OTHERS"]			= { sticky = 0 };
ChatTypeInfo["SPELL_AURA_GONE_SELF"]					= { sticky = 0 };
ChatTypeInfo["SPELL_AURA_GONE_PARTY"]					= { sticky = 0 };
ChatTypeInfo["SPELL_AURA_GONE_OTHER"]					= { sticky = 0 };
ChatTypeInfo["SPELL_ITEM_ENCHANTMENTS"]					= { sticky = 0 };
ChatTypeInfo["SPELL_BREAK_AURA"]						= { sticky = 0 };
ChatTypeInfo["SPELL_PERIODIC_SELF_DAMAGE"]				= { sticky = 0 };
ChatTypeInfo["SPELL_PERIODIC_SELF_BUFFS"]				= { sticky = 0 };
ChatTypeInfo["SPELL_PERIODIC_PARTY_DAMAGE"]				= { sticky = 0 };
ChatTypeInfo["SPELL_PERIODIC_PARTY_BUFFS"]				= { sticky = 0 };
ChatTypeInfo["SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE"]	= { sticky = 0 };
ChatTypeInfo["SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS"]		= { sticky = 0 };
ChatTypeInfo["SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE"]		= { sticky = 0 };
ChatTypeInfo["SPELL_PERIODIC_HOSTILEPLAYER_BUFFS"]		= { sticky = 0 };
ChatTypeInfo["SPELL_PERIODIC_CREATURE_DAMAGE"]			= { sticky = 0 };
ChatTypeInfo["SPELL_PERIODIC_CREATURE_BUFFS"]			= { sticky = 0 };
ChatTypeInfo["SPELL_FAILED_LOCALPLAYER"]				= { sticky = 0 };
ChatTypeInfo["BG_SYSTEM_NEUTRAL"]						= { sticky = 0 };
ChatTypeInfo["BG_SYSTEM_ALLIANCE"]						= { sticky = 0 };
ChatTypeInfo["BG_SYSTEM_HORDE"]							= { sticky = 0 };
ChatTypeInfo["COMBAT_FACTION_CHANGE"]					= { sticky = 0 };
ChatTypeInfo["MONEY"]									= { sticky = 0 };
ChatTypeInfo["RAID_LEADER"]								= { sticky = 0 };
ChatTypeInfo["RAID_WARNING"]							= { sticky = 0 };
ChatTypeInfo["RAID_BOSS_EMOTE"]							= { sticky = 0 };
ChatTypeInfo["FILTERED"]								= { sticky = 0 };
ChatTypeInfo["BATTLEGROUND"]                            = { sticky = 1 };
ChatTypeInfo["BATTLEGROUND_LEADER"]                     = { sticky = 0 };
ChatTypeGroup = {};
ChatTypeGroup["SYSTEM"] = {
	"CHAT_MSG_SYSTEM",
	"CHAT_MSG_AFK",
	"CHAT_MSG_DND",
	"CHAT_MSG_IGNORED",
	"CHAT_MSG_CHANNEL_LIST",
	"TIME_PLAYED_MSG",
	"PLAYER_LEVEL_UP",
	"CHARACTER_POINTS_CHANGED",
	"CHAT_MSG_BG_SYSTEM_NEUTRAL",
	"CHAT_MSG_BG_SYSTEM_ALLIANCE",
	"CHAT_MSG_BG_SYSTEM_HORDE",
	"CHAT_MSG_FILTERED",
};
ChatTypeGroup["SAY"] = {
	"CHAT_MSG_SAY",
	"CHAT_MSG_EMOTE",
	"CHAT_MSG_TEXT_EMOTE",
};
ChatTypeGroup["YELL"] = {
	"CHAT_MSG_YELL",
};
ChatTypeGroup["WHISPER"] = {
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
};
ChatTypeGroup["PARTY"] = {
	"CHAT_MSG_PARTY",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_BATTLEGROUND",
	"CHAT_MSG_BATTLEGROUND_LEADER",
};
ChatTypeGroup["GUILD"] = {
	"CHAT_MSG_GUILD",
	"CHAT_MSG_OFFICER",
	"GUILD_MOTD",
};
ChatTypeGroup["CREATURE"] = {	
	"CHAT_MSG_MONSTER_SAY",
	"CHAT_MSG_MONSTER_YELL",
	"CHAT_MSG_MONSTER_EMOTE",
	"CHAT_MSG_MONSTER_WHISPER",
	"CHAT_MSG_RAID_BOSS_EMOTE",
};
ChatTypeGroup["CHANNEL"] = {
	"CHAT_MSG_CHANNEL_JOIN",
	"CHAT_MSG_CHANNEL_LEAVE",
	"CHAT_MSG_CHANNEL_NOTICE",
	"CHAT_MSG_CHANNEL_NOTICE_USER",
};
ChatTypeGroup["SKILL"] = {
	"CHAT_MSG_SKILL",
};
ChatTypeGroup["LOOT"] = {
	"CHAT_MSG_LOOT",
	"CHAT_MSG_MONEY",
};
ChatTypeGroup["COMBAT_ERROR"] = {
	"CHAT_MSG_COMBAT_ERROR";
};
ChatTypeGroup["COMBAT_MISC_INFO"] = {
	"CHAT_MSG_COMBAT_MISC_INFO";
};
ChatTypeGroup["COMBAT_SELF_HITS"] = {
	"CHAT_MSG_COMBAT_SELF_HITS";
};
ChatTypeGroup["COMBAT_SELF_MISSES"] = {
	"CHAT_MSG_COMBAT_SELF_MISSES";
};
ChatTypeGroup["COMBAT_PET_HITS"] = {
	"CHAT_MSG_COMBAT_PET_HITS";
};
ChatTypeGroup["COMBAT_PET_MISSES"] = {
	"CHAT_MSG_COMBAT_PET_MISSES";
};
ChatTypeGroup["COMBAT_PARTY_HITS"] = {
	"CHAT_MSG_COMBAT_PARTY_HITS";
};
ChatTypeGroup["COMBAT_PARTY_MISSES"] = {
	"CHAT_MSG_COMBAT_PARTY_MISSES";
};
ChatTypeGroup["COMBAT_FRIENDLYPLAYER_HITS"] = {
	"CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS";
};
ChatTypeGroup["COMBAT_FRIENDLYPLAYER_MISSES"] = {
	"CHAT_MSG_COMBAT_FRIENDLYPLAYER_MISSES";
};
ChatTypeGroup["COMBAT_HOSTILEPLAYER_HITS"] = {
	"CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS";
};
ChatTypeGroup["COMBAT_HOSTILEPLAYER_MISSES"] = {
	"CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES";
};
ChatTypeGroup["COMBAT_CREATURE_VS_SELF_HITS"] = {
	"CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS";
};
ChatTypeGroup["COMBAT_CREATURE_VS_SELF_MISSES"] = {
	"CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES";
};
ChatTypeGroup["COMBAT_CREATURE_VS_PARTY_HITS"] = {
	"CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS";
};
ChatTypeGroup["COMBAT_CREATURE_VS_PARTY_MISSES"] = {
	"CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES";
};
ChatTypeGroup["COMBAT_CREATURE_VS_CREATURE_HITS"] = {
	"CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS";
};
ChatTypeGroup["COMBAT_CREATURE_VS_CREATURE_MISSES"] = {
	"CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_MISSES";
};
ChatTypeGroup["COMBAT_FRIENDLY_DEATH"] = {
	"CHAT_MSG_COMBAT_FRIENDLY_DEATH";
};
ChatTypeGroup["COMBAT_HOSTILE_DEATH"] = {
	"CHAT_MSG_COMBAT_HOSTILE_DEATH";
};
ChatTypeGroup["COMBAT_XP_GAIN"] = {
	"CHAT_MSG_COMBAT_XP_GAIN";
}
ChatTypeGroup["COMBAT_HONOR_GAIN"] = {
	"CHAT_MSG_COMBAT_HONOR_GAIN";
}
ChatTypeGroup["SPELL_SELF_DAMAGE"] = {
	"CHAT_MSG_SPELL_SELF_DAMAGE";
};
ChatTypeGroup["SPELL_SELF_BUFF"] = {
	"CHAT_MSG_SPELL_SELF_BUFF";
};
ChatTypeGroup["SPELL_PET_DAMAGE"] = {
	"CHAT_MSG_SPELL_PET_DAMAGE";
};
ChatTypeGroup["SPELL_PET_BUFF"] = {
	"CHAT_MSG_SPELL_PET_BUFF";
};
ChatTypeGroup["SPELL_PARTY_DAMAGE"] = {
	"CHAT_MSG_SPELL_PARTY_DAMAGE";
};
ChatTypeGroup["SPELL_PARTY_BUFF"] = {
	"CHAT_MSG_SPELL_PARTY_BUFF";
};
ChatTypeGroup["SPELL_FRIENDLYPLAYER_DAMAGE"] = {
	"CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE";
};
ChatTypeGroup["SPELL_FRIENDLYPLAYER_BUFF"] = {
	"CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF";
};
ChatTypeGroup["SPELL_HOSTILEPLAYER_DAMAGE"] = {
	"CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE";
};
ChatTypeGroup["SPELL_HOSTILEPLAYER_BUFF"] = {
	"CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF";
};
ChatTypeGroup["SPELL_CREATURE_VS_SELF_DAMAGE"] = {
	"CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE";
};
ChatTypeGroup["SPELL_CREATURE_VS_SELF_BUFF"] = {
	"CHAT_MSG_SPELL_CREATURE_VS_SELF_BUFF";
};
ChatTypeGroup["SPELL_CREATURE_VS_PARTY_DAMAGE"] = {
	"CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE";
};
ChatTypeGroup["SPELL_CREATURE_VS_PARTY_BUFF"] = {
	"CHAT_MSG_SPELL_CREATURE_VS_PARTY_BUFF";
};
ChatTypeGroup["SPELL_CREATURE_VS_CREATURE_DAMAGE"] = {
	"CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE";
};
ChatTypeGroup["SPELL_CREATURE_VS_CREATURE_BUFF"] = {
	"CHAT_MSG_SPELL_CREATURE_VS_CREATURE_BUFF";
};
ChatTypeGroup["SPELL_TRADESKILLS"] = {
	"CHAT_MSG_SPELL_TRADESKILLS";
};
ChatTypeGroup["SPELL_DAMAGESHIELDS_ON_SELF"] = {
	"CHAT_MSG_SPELL_DAMAGESHIELDS_ON_SELF";
};
ChatTypeGroup["SPELL_DAMAGESHIELDS_ON_OTHERS"] = {
	"CHAT_MSG_SPELL_DAMAGESHIELDS_ON_OTHERS";
};
ChatTypeGroup["SPELL_AURA_GONE_SELF"] = {
	"CHAT_MSG_SPELL_AURA_GONE_SELF";
};
ChatTypeGroup["SPELL_AURA_GONE_PARTY"] = {
	"CHAT_MSG_SPELL_AURA_GONE_PARTY";
};
ChatTypeGroup["SPELL_AURA_GONE_OTHER"] = {
	"CHAT_MSG_SPELL_AURA_GONE_OTHER";
};
ChatTypeGroup["SPELL_ITEM_ENCHANTMENTS"] = {
	"CHAT_MSG_SPELL_ITEM_ENCHANTMENTS";
};
ChatTypeGroup["SPELL_BREAK_AURA"] = {
	"CHAT_MSG_SPELL_BREAK_AURA";
};
ChatTypeGroup["SPELL_PERIODIC_SELF_DAMAGE"] = {
	"CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE";
};
ChatTypeGroup["SPELL_PERIODIC_SELF_BUFFS"] = {
	"CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS";
};
ChatTypeGroup["SPELL_PERIODIC_PARTY_DAMAGE"] = {
	"CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE";
};
ChatTypeGroup["SPELL_PERIODIC_PARTY_BUFFS"] = {
	"CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS";
};
ChatTypeGroup["SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE"] = {
	"CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE";
};
ChatTypeGroup["SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS"] = {
	"CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS";
};
ChatTypeGroup["SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE"] = {
	"CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE";
};
ChatTypeGroup["SPELL_PERIODIC_HOSTILEPLAYER_BUFFS"] = {
	"CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_BUFFS";
};
ChatTypeGroup["SPELL_PERIODIC_CREATURE_DAMAGE"] = {
	"CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE";
};
ChatTypeGroup["SPELL_PERIODIC_CREATURE_BUFFS"] = {
	"CHAT_MSG_SPELL_PERIODIC_CREATURE_BUFFS";
};
ChatTypeGroup["SPELL_FAILED_LOCALPLAYER"] = {
	"CHAT_MSG_SPELL_FAILED_LOCALPLAYER";
};
ChatTypeGroup["COMBAT_FACTION_CHANGE"] = {
	"CHAT_MSG_COMBAT_FACTION_CHANGE";
};

ChannelMenuChatTypeGroups = {};
ChannelMenuChatTypeGroups[1] = "SAY";
ChannelMenuChatTypeGroups[2] = "YELL";
ChannelMenuChatTypeGroups[3] = "GUILD";
ChannelMenuChatTypeGroups[4] = "WHISPER";
ChannelMenuChatTypeGroups[5] = "PARTY";

CombatLogMenuChatTypeGroups = {};
CombatLogMenuChatTypeGroups[1]  = "COMBAT_MISC_INFO";
CombatLogMenuChatTypeGroups[2]  = "COMBAT_SELF_HITS";
CombatLogMenuChatTypeGroups[3]  = "COMBAT_SELF_MISSES";
CombatLogMenuChatTypeGroups[4]  = "COMBAT_PET_HITS";
CombatLogMenuChatTypeGroups[5]  = "COMBAT_PET_MISSES";
CombatLogMenuChatTypeGroups[6]  = "COMBAT_PARTY_HITS";
CombatLogMenuChatTypeGroups[7]  = "COMBAT_PARTY_MISSES";
CombatLogMenuChatTypeGroups[8]  = "COMBAT_FRIENDLYPLAYER_HITS";
CombatLogMenuChatTypeGroups[9]  = "COMBAT_FRIENDLYPLAYER_MISSES";
CombatLogMenuChatTypeGroups[10] = "COMBAT_HOSTILEPLAYER_HITS";
CombatLogMenuChatTypeGroups[11] = "COMBAT_HOSTILEPLAYER_MISSES";
CombatLogMenuChatTypeGroups[12] = "COMBAT_CREATURE_VS_SELF_HITS";
CombatLogMenuChatTypeGroups[13] = "COMBAT_CREATURE_VS_SELF_MISSES";
CombatLogMenuChatTypeGroups[14] = "COMBAT_CREATURE_VS_PARTY_HITS";
CombatLogMenuChatTypeGroups[15] = "COMBAT_CREATURE_VS_PARTY_MISSES";
CombatLogMenuChatTypeGroups[16] = "COMBAT_CREATURE_VS_CREATURE_HITS";
CombatLogMenuChatTypeGroups[17] = "COMBAT_CREATURE_VS_CREATURE_MISSES";
CombatLogMenuChatTypeGroups[18] = "COMBAT_FRIENDLY_DEATH";
CombatLogMenuChatTypeGroups[19] = "COMBAT_HOSTILE_DEATH";
CombatLogMenuChatTypeGroups[20] = "COMBAT_XP_GAIN";
CombatLogMenuChatTypeGroups[21] = "COMBAT_HONOR_GAIN";
CombatLogMenuChatTypeGroups[22] = "COMBAT_FACTION_CHANGE";

SpellLogMenuChatTypeGroups = {};
SpellLogMenuChatTypeGroups[1]  = "SPELL_SELF_DAMAGE";
SpellLogMenuChatTypeGroups[2]  = "SPELL_SELF_BUFF";
SpellLogMenuChatTypeGroups[3]  = "SPELL_PET_DAMAGE";
SpellLogMenuChatTypeGroups[4]  = "SPELL_PET_BUFF";
SpellLogMenuChatTypeGroups[5]  = "SPELL_PARTY_DAMAGE";
SpellLogMenuChatTypeGroups[6]  = "SPELL_PARTY_BUFF";
SpellLogMenuChatTypeGroups[7]  = "SPELL_FRIENDLYPLAYER_DAMAGE";
SpellLogMenuChatTypeGroups[8]  = "SPELL_FRIENDLYPLAYER_BUFF";
SpellLogMenuChatTypeGroups[9]  = "SPELL_HOSTILEPLAYER_DAMAGE";
SpellLogMenuChatTypeGroups[10] = "SPELL_HOSTILEPLAYER_BUFF";
SpellLogMenuChatTypeGroups[11] = "SPELL_CREATURE_VS_SELF_DAMAGE";
SpellLogMenuChatTypeGroups[12] = "SPELL_CREATURE_VS_SELF_BUFF";
SpellLogMenuChatTypeGroups[13] = "SPELL_CREATURE_VS_PARTY_DAMAGE";
SpellLogMenuChatTypeGroups[14] = "SPELL_CREATURE_VS_PARTY_BUFF";
SpellLogMenuChatTypeGroups[15] = "SPELL_CREATURE_VS_CREATURE_DAMAGE";
SpellLogMenuChatTypeGroups[16] = "SPELL_CREATURE_VS_CREATURE_BUFF";

SpellLogOtherMenuChatTypeGroups = {};
SpellLogOtherMenuChatTypeGroups [1] = "SPELL_TRADESKILLS";
SpellLogOtherMenuChatTypeGroups [2] = "SPELL_DAMAGESHIELDS_ON_SELF";
SpellLogOtherMenuChatTypeGroups [3] = "SPELL_DAMAGESHIELDS_ON_OTHERS";
SpellLogOtherMenuChatTypeGroups [4] = "SPELL_AURA_GONE_SELF";
SpellLogOtherMenuChatTypeGroups [5] = "SPELL_AURA_GONE_PARTY";
SpellLogOtherMenuChatTypeGroups [6] = "SPELL_AURA_GONE_OTHER";
SpellLogOtherMenuChatTypeGroups [7] = "SPELL_ITEM_ENCHANTMENTS";
SpellLogOtherMenuChatTypeGroups [8] = "SPELL_BREAK_AURA";
SpellLogOtherMenuChatTypeGroups [9] = "SPELL_FAILED_LOCALPLAYER";

PeriodicLogMenuChatTypeGroups = {};
PeriodicLogMenuChatTypeGroups[1]  = "SPELL_PERIODIC_SELF_DAMAGE";
PeriodicLogMenuChatTypeGroups[2]  = "SPELL_PERIODIC_SELF_BUFFS";
PeriodicLogMenuChatTypeGroups[3]  = "SPELL_PERIODIC_PARTY_DAMAGE";
PeriodicLogMenuChatTypeGroups[4]  = "SPELL_PERIODIC_PARTY_BUFFS";
PeriodicLogMenuChatTypeGroups[5]  = "SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE";
PeriodicLogMenuChatTypeGroups[6]  = "SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS";
PeriodicLogMenuChatTypeGroups[7]  = "SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE";
PeriodicLogMenuChatTypeGroups[8]  = "SPELL_PERIODIC_HOSTILEPLAYER_BUFFS";
PeriodicLogMenuChatTypeGroups[9]  = "SPELL_PERIODIC_CREATURE_DAMAGE";
PeriodicLogMenuChatTypeGroups[10] = "SPELL_PERIODIC_CREATURE_BUFFS";

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


-- Arena Team Helper Function
function ArenaTeam_SlashHandler(team)
	if ( team ) then
		team = tonumber(strsub(team, 1, 1));
	end
	local teamname, teamsize, id;
	for i=1, MAX_ARENA_TEAMS do
		teamname, teamsize = GetArenaTeam(i)
		if ( team == teamsize ) then
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
	entry.items = {};
	for i=1, select("#", ...) do
		local action = strlower(strtrim((select(i, ...))));
		if ( GetItemInfo(action) ) then
			entry.items[i] = action;
			entry.spells[i] = strlower(GetItemSpell(action) or "");
		else
			entry.spells[i] = action;
		end
	end
end

local function SetCastSequenceIndex(entry, index)
	if ( entry.macro ) then
		if ( entry.items[index] ) then
			SetMacroItem(entry.macro, entry.items[index]);
		else
			SetMacroSpell(entry.macro, entry.spells[index]);
		end
	end
	entry.index = index;
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
	-- Increment sequences for spells which succeed.
	if ( event == "UNIT_SPELLCAST_SUCCEEDED" ) then
		local name, rank = select(2, ...);
		name, rank = strlower(name), strlower(rank);
		local fullname = name.."("..rank..")";
		for sequence, entry in pairs(CastSequenceTable) do
			if ( entry.spells[entry.index] == name or
			     entry.spells[entry.index] == fullname ) then
				SetNextCastSequence(sequence, entry);
			elseif ( strfind(entry.reset, "spell", 1, true) ) then
				ResetCastSequence(sequence, entry);
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
		CastSequenceManager:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
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
		entry.macro = GetRunningMacro();
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
		UseItemByName(item, target);
	else
		CastSpellByName(spell, target, true);
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
		index = entry.index;
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
			local action = strlower(strtrim((select(1, strsplit(",", spells)))));
			if ( GetItemInfo(action) ) then
				item, spell = action, strlower(GetItemSpell(action) or "");
			else
				item, spell = nil, action;
			end
		end
	end
	return index, item, spell;
end

--
-- SecureCmdOption code contributed with permission by: Tem
--

local function SecureCmdOptionEval(val, desired)
	if ( desired ) then
		return (val == desired);
	else
		return (val > 0);
	end
end
 
local SecureCmdOptionHandlers = {
	-- The rule of thumb for conditionals here is:
	-- 1. The state significantly changes what spells are available.
	-- 2. The player generally has control over the current state.
	-- 3. The designers give it the thumbs up. :)

	combat = function(target, desired)
		return SecureCmdOptionEval(UnitAffectingCombat("player") or UnitAffectingCombat("pet") or 0, tonumber(desired));
	end,

	exists = function(target, desired)
		return SecureCmdOptionEval(UnitExists(target) or 0, tonumber(desired));
	end,

	help = function(target, desired)
		return SecureCmdOptionEval(UnitCanAssist("player",target) or 0, tonumber(desired));
	end,

	harm = function(target, desired)
		return SecureCmdOptionEval(UnitCanAttack("player",target) or 0, tonumber(desired));
	end,

	party = function(target, desired)
		return SecureCmdOptionEval(UnitPlayerOrPetInParty(target) or 0, tonumber(desired));
	end,

	raid = function(target, desired)
		return SecureCmdOptionEval(UnitPlayerOrPetInParty(target) or UnitPlayerOrPetInRaid(target) or 0, tonumber(desired));
	end,

	dead = function(target, desired)
		return SecureCmdOptionEval(UnitIsDead(target) or UnitIsGhost(target) or 0, tonumber(desired));
	end,

	indoors = function(target, desired)
		return SecureCmdOptionEval(IsIndoors() or 0, tonumber(desired));
	end,

	outdoors = function(target, desired)
		return SecureCmdOptionEval(IsOutdoors() or 0, tonumber(desired));
	end,

	swimming = function(target, desired)
		return SecureCmdOptionEval(IsSwimming() or 0, tonumber(desired));
	end,

	flying = function(target, desired)
		return SecureCmdOptionEval(IsFlying() or 0, tonumber(desired));
	end,

	mounted = function(target, desired)
		return SecureCmdOptionEval(IsMounted() or 0, tonumber(desired));
	end,

	stealth = function(target, desired)
		return SecureCmdOptionEval(IsStealthed() or 0, tonumber(desired));
	end,

	group = function(target, ...)
		local n = select("#", ...);
		if ( n > 0 ) then
			for i=1, n do
				local desired = strlower((select(i,...)));
				if ( desired == "party" ) then
					if ( GetNumPartyMembers() > 0 ) then
						return true;
					end
				elseif ( desired == "raid" ) then
					if ( GetNumRaidMembers() > 0 ) then
						return true;
					end
				end
			end
		else
			return (GetNumPartyMembers() > 0) or (GetNumRaidMembers() > 0);
		end
	end,

	stance = function(target, ...)
		local stance = GetShapeshiftForm(true);
		local n = select("#", ...);
		if ( n > 0 ) then
			for i=1, n do
				local desired = tonumber((select(i,...)));
				if ( desired == stance ) then
					return true;
				end
			end
		else
			return (stance > 0);
		end
	end,

	pet = function(target, ...)
		if ( not UnitExists("pet") ) then
			return false;
		end
		local n = select("#", ...);
		if ( n > 0 ) then
			local name = UnitName("pet");
			local family = UnitCreatureFamily("pet") or "";
			name, family = strlower(name), strlower(family);
			for i=1, n do
				local desired = strlower((select(i, ...)));
				if ( desired == name or desired == family ) then
					return true;
				end
			end
		else
			return true;
		end
	end,

	modifier = function(target, ...)
		local n = select("#", ...);
		if ( n > 0 ) then
			for i=1, n do
				local key = strlower((select(i,...)));
				if ( (key == "shift" and IsShiftKeyDown()) or
				     (key == "ctrl" and IsControlKeyDown()) or
				     (key == "alt" and IsAltKeyDown()) ) then
					return true;
				end
			end
		else
			return IsModifierKeyDown();
		end
	end,

	button = function(target, ...)
		local button = GetRunningMacroButton();
		if ( not button ) then
			return false;
		end
		for i=1, select("#", ...) do
			local desired = GetMouseButtonName((select(i,...)));
			if ( desired == button ) then
				return true;
			end
		end
	end,

	actionbar = function(target, ...)
		local page = GetActionBarPage();
		for i=1, select("#", ...) do
			local desired = tonumber((select(i,...)));
			if ( desired == page ) then
				return true;
			end
		end
	end,

	equipped = function(target, ...)
		for i=1, select("#", ...) do
			local type = select(i, ...);
			if ( IsEquippedItemType(type) ) then
				return true;
			end
		end
	end,

	channeling = function(target, ...)
		local spell = UnitChannelInfo("player");
		if ( not spell ) then
			return false;
		end
		spell = strlower(spell);
		local n = select("#", ...);
		if ( n > 0 ) then
			for i=1, n do
				local desired = strlower((select(i, ...)));
				if ( desired == spell ) then
					return true;
				end
			end
		else
			return true;
		end
	end,
}

local function SecureCmdOptionCheckTarget(options)
	local target;
	local s = strmatch(options, "target=[^,]+");
	if ( s ) then
		options = gsub(options, "target=[^,]+,?", "");
		target = strsub(s, 8);
	end
	return options, target;
end

local function SecureCmdOptionCheckOptions(target,...)
	for i=1, select("#",...) do
		local option = strtrim((select(i,...)));
		if ( option ~= "" ) then
			local invert = false;
			local args;
			option, args = strsplit(':', option);
			option = strlower(option);
			if ( strmatch(option, "^no") ) then
				invert = true;
				option = strsub(option, 3);
			end
			local handler = SecureCmdOptionHandlers[option];
			if ( handler ) then
				local value;
				if ( args ) then
					value = handler(target, strsplit('/', args));
				else
					value = handler(target);
				end
				if ( (not value and not invert) or (value and invert) ) then
					return false;
				end
			else
				error("Unknown option: "..option);
			end
		end
	end
	return true;
end

local function SecureCmdOptionParseArgs(...)
	for i=1, select("#",...) do
		local cmd = select(i,...);
		local _, start, options = strfind(cmd, "(%b[])");
		local action = strsub(cmd, (start or 0)+1);
		local valid = true;
		local target;

		if ( options ) then
			options = strsub(options,2,-2);
			options, target = SecureCmdOptionCheckTarget(options);
			if ( options ~= "" ) then
				valid = SecureCmdOptionCheckOptions(target or "target", strsplit(',', options));
			end
		end
		if ( valid ) then
			return strtrim(action), target;
		end
	end
end

function SecureCmdOptionParse(args)
	return SecureCmdOptionParseArgs(strsplit(';', args));
end

function GetRandomArgument(...)
	return (select(random(select("#", ...)), ...));
end

-- Slash commands that are protected from tampering
local SecureCmdList = { };

SecureCmdList["STARTATTACK"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		StartAttack(msg);
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
		if ( GetItemInfo(action) ) then
			UseItemByName(action, target);
		else
			CastSpellByName(action, target);
		end
    end
end

SecureCmdList["CASTRANDOM"] = function(msg)
    local actions, target = SecureCmdOptionParse(msg);
	if ( actions ) then
		local action = strtrim(GetRandomArgument(strsplit(",", actions)));
		if ( GetItemInfo(action) ) then
			UseItemByName(action, target);
		else
			CastSpellByName(action, target);
		end
	end
end

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
		CancelPlayerBuff(name, rank);
	end
end

SecureCmdList["EQUIP"] = function(msg)
	local item = SecureCmdOptionParse(msg);
	if ( item ) then
		EquipItemByName(item);
	end
end

SecureCmdList["EQUIP_TO_SLOT"] = function(msg)
	local slot, item = strmatch(SecureCmdOptionParse(msg), "^(%d+)%s*(.*)");
	if ( item ) then
		EquipItemByName(item, slot);
	end
end

SecureCmdList["USE"] = function(msg)
	local item, target = SecureCmdOptionParse(msg);
	if ( item ) then
		local bag, slot = strmatch(item, "^(%d+)%s+(%d+)$");
		if ( not bag ) then
			slot = strmatch(item, "^(%d+)$");
		end
		if ( bag ) then
			UseContainerItem(bag, slot, target);
		elseif ( slot ) then
			UseInventoryItem(slot, target);
		else
			UseItemByName(item, target);
		end
	end
end

SecureCmdList["USERANDOM"] = function(msg)
    local items, target = SecureCmdOptionParse(msg);
	if ( items ) then
		local item = strtrim(GetRandomArgument(strsplit(",", items)));
		local bag, slot = strmatch(item, "^(%d+)%s+(%d+)$");
		if ( not bag ) then
			slot = strmatch(item, "^(%d+)$");
		end
		if ( bag ) then
			UseContainerItem(bag, slot, target);
		elseif ( slot ) then
			UseInventoryItem(slot, target);
		else
			UseItemByName(item, target);
		end
	end
end

SecureCmdList["CHANGEACTIONBAR"] = function(msg)
	local page = SecureCmdOptionParse(msg);
	if ( page ) then
		ChangeActionBarPage(page);
	end
end

SecureCmdList["SWAPACTIONBAR"] = function(msg)
	local a, b = strmatch(msg, "(%d+)%s+(%d+)");
	if ( GetActionBarPage() == tonumber(a) ) then
		ChangeActionBarPage(b);
	else
		ChangeActionBarPage(a);
	end
end

SecureCmdList["TARGET"] = function(msg)
	local target = SecureCmdOptionParse(msg);
	if ( target ) then
		TargetUnit(target);
	end
end

SecureCmdList["TARGET_NEAREST_ENEMY"] = function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetNearestEnemy(action);
	end
end

SecureCmdList["TARGET_NEAREST_FRIEND"] = function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetNearestFriend(action);
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

SecureCmdList["ASSIST"] = function(msg)
	if ( msg == "" ) then
		AssistUnit();
	else
		local target = SecureCmdOptionParse(msg);
		if ( target ) then
			AssistUnit(target);
		end
	end
end

SecureCmdList["FOCUS"] = function(msg)
	if ( msg == "" ) then
		FocusUnit();
	else
		local target = SecureCmdOptionParse(msg);
		if ( target ) then
			FocusUnit(target);
		end
	end
end

SecureCmdList["CLEARFOCUS"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		ClearFocus();
	end
end

SecureCmdList["DUEL"] = function(msg)
	StartDuel(msg)
end

SecureCmdList["DUEL_CANCEL"] = function(msg)
	CancelDuel()
end

SecureCmdList["PET_ATTACK"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		PetAttack(msg);
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

SecureCmdList["STOPMACRO"] = function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		StopMacro();
	end
end

SecureCmdList["CLICK"] = function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action and action ~= "" ) then
		local button, mouseButton, down = strmatch(action, "([^%s]+)%s+([^%s]+)%s*(.*)");
		if ( button ) then
			button = getglobal(button);
		else
			button = getglobal(action);
		end
		if ( button and button:IsObjectType("Button") ) then
			button:Click(mouseButton, down);
		end
	end
end


-- Slash commands
SlashCmdList = { };

SlashCmdList["CONSOLE"] = function(msg)
	ConsoleExec(msg);
end

SlashCmdList["CHATLOG"] = function()
	local info = ChatTypeInfo["SYSTEM"];
	if ( LoggingChat() ) then
		LoggingChat(false);
		DEFAULT_CHAT_FRAME:AddMessage(TEXT(CHATLOGDISABLED), info.r, info.g, info.b, info.id);
	else
		LoggingChat(true);
		DEFAULT_CHAT_FRAME:AddMessage(TEXT(CHATLOGENABLED), info.r, info.g, info.b, info.id);
	end
end

SlashCmdList["COMBATLOG"] = function()
	local info = ChatTypeInfo["SYSTEM"];
	if ( LoggingCombat() ) then
		LoggingCombat(false);
		DEFAULT_CHAT_FRAME:AddMessage(TEXT(COMBATLOGDISABLED), info.r, info.g, info.b, info.id);
	else
		LoggingCombat(true);
		DEFAULT_CHAT_FRAME:AddMessage(TEXT(COMBATLOGENABLED), info.r, info.g, info.b, info.id);
	end
end

SlashCmdList["INVITE"] = function(msg)
	InviteUnit(msg);
end

SlashCmdList["UNINVITE"] = function(msg)
	UninviteUnit(msg);
end

SlashCmdList["PROMOTE"] = function(msg)
	PromoteToLeader(msg);
end

SlashCmdList["REPLY"] = function(msg)
	local lastTell = ChatEdit_GetLastTellTarget(this);
	if ( strlen(lastTell) > 0 ) then
		SendChatMessage(msg, "WHISPER", this.language, lastTell);
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
		local joinhelp = TEXT(CHAT_JOIN_HELP);
		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(joinhelp, info.r, info.g, info.b, info.id);
	else
		local zoneChannel, channelName = JoinChannelByName(name, password, DEFAULT_CHAT_FRAME:GetID());
		if ( channelName ) then
			name = channelName;
		end
		if ( not zoneChannel ) then
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
	LeaveChannelByName(name);
end

SlashCmdList["LIST_CHANNEL"] = function(msg)
	local name = strmatch(msg, "%s*([^%s]+)");
	if ( name ) then
		ListChannelByName(name);
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
		local newowner = gsub(msg, "%s*([^%s]+)%s*(.*)", "%2");
		if(strlen(channel) > 0) then
			if(strlen(newowner) > 0) then
				SetChannelOwner(channel, newowner);
			else
				DisplayChannelOwner(channel);
			end
		end
	end

SlashCmdList["CHAT_MODERATOR"] = 
	function(msg)
		local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
		if ( channel and player ) then
			ChannelModerator(channel, player);
		end
	end

SlashCmdList["CHAT_UNMODERATOR"] =
	function(msg)
		local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
		if ( channel and player ) then
			ChannelUnmoderator(channel, player);
		end
	end

SlashCmdList["CHAT_MODERATE"] = 
	function(msg)
		local channel = strmatch(msg, "%s*([^%s]+)");
		if ( channel ) then
			ChannelModerate(channel);
		end
	end

SlashCmdList["CHAT_MUTE"] =
	function(msg)
		local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
		if ( channel and player ) then
			ChannelMute(channel, player);
		end
	end

SlashCmdList["CHAT_UNMUTE"] =
	function(msg)
		local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
		if ( channel and player ) then
			ChannelUnmute(channel, player);
		end
	end

SlashCmdList["CHAT_CINVITE"] =
	function(msg)
		local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
		if ( channel and player ) then
			ChannelInvite(channel, player);
		end
	end

SlashCmdList["CHAT_KICK"] =
	function(msg)
		local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
		if ( channel and player ) then
			ChannelKick(channel, player);
		end
	end

SlashCmdList["CHAT_BAN"] =
	function(msg)
		local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
		if ( channel and player ) then
			ChannelBan(channel, player);
		end
	end

SlashCmdList["CHAT_UNBAN"] =
	function(msg)
		local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
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
		local info = ChatTypeInfo["SYSTEM"];
		local index = strfind(msg, " ");
		if ( index ) then
			local name = strsub(msg, index+1);
			local team = ArenaTeam_SlashHandler(msg);
			if ( team ) then
				ArenaTeamInviteByName(team, name);
				return;
			end
		end

		DEFAULT_CHAT_FRAME:AddMessage(TEXT(ERROR_SLASH_TEAM_INVITE), info.r, info.g, info.b, info.id);
	end
end

SlashCmdList["TEAM_QUIT"] = function(msg)
	if ( msg ~= "" ) then
		local info = ChatTypeInfo["SYSTEM"];
		local team = ArenaTeam_SlashHandler(msg);
		if ( team ) then
			ArenaTeamLeave(team);
		else
			DEFAULT_CHAT_FRAME:AddMessage(TEXT(ERROR_SLASH_TEAM_QUIT), info.r, info.g, info.b, info.id);
		end
	end
end

SlashCmdList["TEAM_DEMOTE"] = function(msg)
	if ( msg ~= "" ) then
		local index = strfind(msg, " ");
		local name = strsub(msg, index+1);
		local team = ArenaTeam_SlashHandler(msg);
		if ( team ) then
			ArenaTeamDemoteByName(team, name);
		else
			DEFAULT_CHAT_FRAME:AddMessage(TEXT(ERROR_SLASH_TEAM_DEMOTE), info.r, info.g, info.b, info.id);
		end
	end
end

SlashCmdList["TEAM_CAPTAIN"] = function(msg)
	if ( msg ~= "" ) then
		local index = strfind(msg, " ");
		local name = strsub(msg, index+1);
		local team = ArenaTeam_SlashHandler(msg);
		if ( team ) then
			ArenaTeamSetLeaderByName(team, name);
		else
			DEFAULT_CHAT_FRAME:AddMessage(TEXT(ERROR_SLASH_TEAM_CAPTAIN), info.r, info.g, info.b, info.id);
		end

	end
end

SlashCmdList["TEAM_DISBAND"] = function(msg)
	if ( msg ~= "" ) then
		local info = ChatTypeInfo["SYSTEM"];
		local team = ArenaTeam_SlashHandler(tonumber(strsub(msg, 1, 1)));
		if ( team ) then
			ArenaTeamDisband(team);
		else
			DEFAULT_CHAT_FRAME:AddMessage(TEXT(ERROR_SLASH_TEAM_DISBAND), info.r, info.g, info.b, info.id);
		end
	end
end

SlashCmdList["GUILD_INVITE"] = function(msg)
	GuildInvite(msg);
end

SlashCmdList["GUILD_UNINVITE"] = function(msg)
	GuildUninvite(msg);
end

SlashCmdList["GUILD_PROMOTE"] = function(msg)
	GuildPromote(msg);
end

SlashCmdList["GUILD_DEMOTE"] = function(msg)
	GuildDemote(msg);
end

SlashCmdList["GUILD_LEADER"] = function(msg)
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
	elseif ( msg == "cheat" ) then
		-- Remove the "cheat" part later!
		ShowWhoPanel();
	end
	WhoFrameEditBox:SetText(msg);
	SendWho(msg);
end

SlashCmdList["CHANNEL"] = function(msg)
	SendChatMessage(msg, "CHANNEL", this.language, this:GetAttribute("channelTarget"));
end

SlashCmdList["FRIENDS"] = function(msg)
	if ( msg ~= "" or UnitIsPlayer("target") ) then
		AddFriend(msg);
	else
		ShowFriends();
	end
end

SlashCmdList["REMOVEFRIEND"] = function(msg)
	RemoveFriend(msg);
end

SlashCmdList["IGNORE"] = function(msg)
	if ( msg ~= "" or UnitIsPlayer("target") ) then
		AddOrDelIgnore(msg);
	else
		ShowIgnorePanel();
	end
end

SlashCmdList["UNIGNORE"] = function(msg)
	if ( msg ~= "" or UnitIsPlayer("target") ) then
		DelIgnore(msg);
	else
		ShowIgnorePanel();
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
		ToggleFriendsFrame(4);
		RaidInfoFrame:Show();
	elseif ( not RaidFrame:IsShown() ) then
		ToggleFriendsFrame(4);
	end
end

SlashCmdList["READYCHECK"] = function(msg)
	if ( (IsRaidLeader() and GetNumRaidMembers() > 0) or (IsPartyLeader() and GetNumPartyMembers()) ) then
		DoReadyCheck();
	end
end

SlashCmdList["SAVEGUILDROSTER"] = function(msg)
	SaveGuildRoster();
end

SlashCmdList["LOOKINGFORGROUP"] = function(msg)
	if ( not LFGParentFrame_UpdateTabs() ) then
		ShowUIPanel(LFGParentFrame);
		LFGParentFrameTab1_OnClick();
	else
		-- Send an error
		UIErrorsFrame:AddMessage(ERR_CANT_DO_THAT_IN_A_GROUP, 1.0, 0.1, 0.1, 1.0);
	end
end

SlashCmdList["LOOKINGFORMORE"] = function(msg)
	ShowUIPanel(LFGParentFrame);
	LFGParentFrameTab2_OnClick();
end

-- ChatFrame functions
function ChatFrame_OnLoad()
	this.flashTimer = 0;
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("UPDATE_CHAT_COLOR");
	this:RegisterEvent("UPDATE_CHAT_WINDOWS");
	this:RegisterEvent("CHAT_MSG_CHANNEL");
	this:RegisterEvent("ZONE_UNDER_ATTACK");
	this:RegisterEvent("UPDATE_INSTANCE_INFO");
	this:RegisterEvent("NEW_TITLE_EARNED");
	this:RegisterEvent("OLD_TITLE_LOST");
	this.tellTimer = GetTime();
	this.channelList = {};
	this.zoneChannelList = {};
	this.messageTypeList = {};

	for index, value in pairs(ChatTypeInfo) do
		value.r = 1.0;
		value.g = 1.0;
		value.b = 1.0;
		value.id = GetChatTypeIndex(index);
	end
end

function ChatFrame_RegisterForMessages(...)
	local messageGroup;
	local index = 1;
	for i=1, select("#", ...) do
		messageGroup = ChatTypeGroup[select(i, ...)];
		if ( messageGroup ) then
			this.messageTypeList[index] = select(i, ...);
			for index, value in pairs(messageGroup) do
				this:RegisterEvent(value);
			end
			index = index + 1;
		end
	end
end

function ChatFrame_RegisterForChannels(...)
	local index = 1;
	for i=1, select("#", ...), 2 do
		this.channelList[index], this.zoneChannelList[index] = select(i, ...);
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
	chatFrame.channelList = {};
	chatFrame.zoneChannelList = {};
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
			local defaulteditbox = securecall(GetDefaultChatEditBox);
			self:SetAttribute("chatType", defaulteditbox:GetAttribute("chatType"));
			self:SetAttribute("tellTarget", defaulteditbox:GetAttribute("tellTarget"));
			self:SetAttribute("channelTarget", defaulteditbox:GetAttribute("channelTarget"));
			self:SetText(line);
			ChatEdit_SendText(self);
		end
	);
	editbox:Hide();
end

function ChatFrame_OnEvent(event)
	if ( ChatFrame_ConfigEventHandler(event) ) then
		return;
	end
	if ( ChatFrame_SystemEventHandler(event) ) then
		return
	end
	if ( ChatFrame_MessageEventHandler(event) ) then
		return
	end
end

function ChatFrame_ConfigEventHandler(event)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		this.defaultLanguage = GetDefaultLanguage();
		return true;
	end
	if ( event == "UPDATE_CHAT_WINDOWS" ) then
		local name, fontSize, r, g, b, a, shown, locked = GetChatWindowInfo(this:GetID());
		if ( fontSize > 0 ) then
			local fontFile, unused, fontFlags = this:GetFont();
			this:SetFont(fontFile, fontSize, fontFlags);
		end
		if ( shown ) then
			this:Show();
		end
		-- Do more stuff!!!
		ChatFrame_RegisterForMessages(GetChatWindowMessages(this:GetID()));
		ChatFrame_RegisterForChannels(GetChatWindowChannels(this:GetID()));
		return true;
	end
	if ( event == "UPDATE_CHAT_COLOR" ) then
		local info = ChatTypeInfo[strupper(arg1)];
		if ( info ) then
			info.r = arg2;
			info.g = arg3;
			info.b = arg4;
			this:UpdateColorByID(info.id, info.r, info.g, info.b);

			if ( strupper(arg1) == "WHISPER" ) then
				info = ChatTypeInfo["REPLY"];
				if ( info ) then
					info.r = arg2;
					info.g = arg3;
					info.b = arg4;
					this:UpdateColorByID(info.id, info.r, info.g, info.b);
				end
			end
		end
		return true;
	end
end

function ChatFrame_SystemEventHandler(event)
	if ( event == "TIME_PLAYED_MSG" ) then
		ChatFrame_DisplayTimePlayed(arg1, arg2);
		return true;
	end
	if ( event == "PLAYER_LEVEL_UP" ) then
		-- Level up
		local info = ChatTypeInfo["SYSTEM"];

		local string = format(TEXT(LEVEL_UP), arg1);
		this:AddMessage(string, info.r, info.g, info.b, info.id);

		if ( arg3 > 0 ) then
			string = format(TEXT(LEVEL_UP_HEALTH_MANA), arg2, arg3);
		else
			string = format(TEXT(LEVEL_UP_HEALTH), arg2);
		end
		this:AddMessage(string, info.r, info.g, info.b, info.id);

		if ( arg4 > 0 ) then
			string = format(GetText("LEVEL_UP_CHAR_POINTS", nil, arg4), arg4);
			this:AddMessage(string, info.r, info.g, info.b, info.id);
		end

		if ( arg5 > 0 ) then
			string = format(TEXT(LEVEL_UP_STAT), TEXT(SPELL_STAT1_NAME), arg5);
			this:AddMessage(string, info.r, info.g, info.b, info.id);
		end
		if ( arg6 > 0 ) then
			string = format(TEXT(LEVEL_UP_STAT), TEXT(SPELL_STAT2_NAME), arg6);
			this:AddMessage(string, info.r, info.g, info.b, info.id);
		end
		if ( arg7 > 0 ) then
			string = format(TEXT(LEVEL_UP_STAT), TEXT(SPELL_STAT3_NAME), arg7);
			this:AddMessage(string, info.r, info.g, info.b, info.id);
		end
		if ( arg8 > 0 ) then
			string = format(TEXT(LEVEL_UP_STAT), TEXT(SPELL_STAT4_NAME), arg8);
			this:AddMessage(string, info.r, info.g, info.b, info.id);
		end
		if ( arg9 > 0 ) then
			string = format(TEXT(LEVEL_UP_STAT), TEXT(SPELL_STAT5_NAME), arg9);
			this:AddMessage(string, info.r, info.g, info.b, info.id);
		end
		return true;
	end
	if ( event == "CHARACTER_POINTS_CHANGED" ) then
		local info = ChatTypeInfo["SYSTEM"];
		if ( arg2 > 0 ) then
			local cp1, cp2 = UnitCharacterPoints("player");
			if ( cp2 ) then
				local string = format(GetText("LEVEL_UP_SKILL_POINTS", nil, cp2), cp2);
				this:AddMessage(string, info.r, info.g, info.b, info.id);
			end
		end
		return true;
	end
	if ( event == "GUILD_MOTD" ) then
		if ( arg1 and (strlen(arg1) > 0) ) then
			local info = ChatTypeInfo["GUILD"];
			local string = format(TEXT(GUILD_MOTD_TEMPLATE), arg1);
			this:AddMessage(string, info.r, info.g, info.b, info.id);
		end
		return true;
	end
	if ( event == "ZONE_UNDER_ATTACK" ) then
		local info = ChatTypeInfo["SYSTEM"];
		this:AddMessage(format(TEXT(ZONE_UNDER_ATTACK), arg1), info.r, info.g, info.b, info.id);
		return true;
	end
	if ( event == "UPDATE_INSTANCE_INFO" ) then
		if ( RaidFrame.hasRaidInfo ) then
			local info = ChatTypeInfo["SYSTEM"];
			if ( RaidFrame.slashCommand and GetNumSavedInstances() == 0 and this == DEFAULT_CHAT_FRAME) then
				this:AddMessage(TEXT(NO_RAID_INSTANCES_SAVED), info.r, info.g, info.b, info.id);
				RaidFrame.slashCommand = nil;
			end
		end
		return true;
	end
	if ( event == "NEW_TITLE_EARNED" ) then
		local info = ChatTypeInfo["SYSTEM"];
		this:AddMessage(format(TEXT(NEW_TITLE_EARNED), arg1), info.r, info.g, info.b, info.id);
		return true;
	end
	if ( event == "OLD_TITLE_LOST" ) then
		local info = ChatTypeInfo["SYSTEM"];
		this:AddMessage(format(TEXT(OLD_TITLE_LOST), arg1), info.r, info.g, info.b, info.id);
		return true;
	end
end
	
function ChatFrame_MessageEventHandler(event)
	if ( strsub(event, 1, 8) == "CHAT_MSG" ) then
		local type = strsub(event, 10);
		local info = ChatTypeInfo[type];

		local channelLength = strlen(arg4);
		if ( (strsub(type, 1, 7) == "CHANNEL") and (type ~= "CHANNEL_LIST") and ((arg1 ~= "INVITE") or (type ~= "CHANNEL_NOTICE_USER")) ) then
			local found = 0;
			for index, value in pairs(this.channelList) do
				if ( channelLength > strlen(value) ) then
					-- arg9 is the channel name without the number in front...
					if ( ((arg7 > 0) and (this.zoneChannelList[index] == arg7)) or (strupper(value) == strupper(arg9)) ) then
						found = 1;
						info = ChatTypeInfo["CHANNEL"..arg8];
						if ( (type == "CHANNEL_NOTICE") and (arg1 == "YOU_LEFT") ) then
							this.channelList[index] = nil;
							this.zoneChannelList[index] = nil;
						end
						break;
					end
				end
			end
			if ( (found == 0) or not info ) then
				return true;
			end
		end

		if ( type == "SYSTEM" or type == "TEXT_EMOTE" or type == "SKILL" or type == "LOOT" or type == "MONEY" ) then
			this:AddMessage(arg1, info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,7) == "COMBAT_" ) then
			this:AddMessage(arg1, info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,6) == "SPELL_" ) then
			this:AddMessage(arg1, info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,10) == "BG_SYSTEM_" ) then
			this:AddMessage(arg1, info.r, info.g, info.b, info.id);
		elseif ( type == "IGNORED" ) then
			this:AddMessage(format(TEXT(CHAT_IGNORED), arg2), info.r, info.g, info.b, info.id);
		elseif ( type == "FILTERED" ) then
			this:AddMessage(format(TEXT(CHAT_FILTERED), arg2), info.r, info.g, info.b, info.id);
		elseif ( type == "CHANNEL_LIST") then
			if(channelLength > 0) then
				this:AddMessage(format(TEXT(getglobal("CHAT_"..type.."_GET"))..arg1, arg4), info.r, info.g, info.b, info.id);
			else
				this:AddMessage(arg1, info.r, info.g, info.b, info.id);
			end
		elseif (type == "CHANNEL_NOTICE_USER") then
			if(strlen(arg5) > 0) then
				-- TWO users in this notice (E.G. x kicked y)
				this:AddMessage(format(TEXT(getglobal("CHAT_"..arg1.."_NOTICE")), arg4, arg2, arg5), info.r, info.g, info.b, info.id);
			else
				this:AddMessage(format(TEXT(getglobal("CHAT_"..arg1.."_NOTICE")), arg4, arg2), info.r, info.g, info.b, info.id);
			end
		elseif (type == "CHANNEL_NOTICE") then
			if ( arg10 > 0 ) then
				arg4 = arg4.." "..arg10;
			end
			this:AddMessage(format(TEXT(getglobal("CHAT_"..arg1.."_NOTICE")), arg4), info.r, info.g, info.b, info.id);
		else
			local body;

			-- Add AFK/DND flags
			local pflag;
			if(strlen(arg6) > 0) then
				pflag = TEXT(getglobal("CHAT_FLAG_"..arg6));
			else
				pflag = "";
			end

			local showLink = 1;
			if ( strsub(type, 1, 7) == "MONSTER" or type == "RAID_BOSS_EMOTE" ) then
				showLink = nil;
			else
				arg1 = gsub(arg1, "%%", "%%%%");
			end
			if ( (strlen(arg3) > 0) and (arg3 ~= "Universal") and (arg3 ~= this.defaultLanguage) ) then
				local languageHeader = "["..arg3.."] ";
				if ( showLink and (strlen(arg2) > 0) ) then
					body = format(TEXT(getglobal("CHAT_"..type.."_GET"))..languageHeader..arg1, pflag.."|Hplayer:"..arg2.."|h".."["..arg2.."]".."|h");
				else
					body = format(TEXT(getglobal("CHAT_"..type.."_GET"))..languageHeader..arg1, pflag..arg2);
				end
			else
				if ( showLink and (strlen(arg2) > 0) and (type ~= "EMOTE") ) then
					body = format(TEXT(getglobal("CHAT_"..type.."_GET"))..arg1, pflag.."|Hplayer:"..arg2.."|h".."["..arg2.."]".."|h");
				else
					body = format(TEXT(getglobal("CHAT_"..type.."_GET"))..arg1, pflag..arg2);

					-- Add raid boss emote message
					if ( type == "RAID_BOSS_EMOTE" ) then
						RaidBossEmoteFrame:AddMessage(body, info.r, info.g, info.b, 1.0);
					end
				end
			end

			-- Add Channel
			arg4 = gsub(arg4, "%s%-%s.*", "");
			if(channelLength > 0) then
				body = "["..arg4.."] "..body;
			end
			this:AddMessage(body, info.r, info.g, info.b, info.id);
		end
 
		if ( type == "WHISPER" ) then
			ChatEdit_SetLastTellTarget(this.editBox, arg2);
			if ( this.tellTimer and (GetTime() > this.tellTimer) ) then
				PlaySound("TellMessage");
			end
			this.tellTimer = GetTime() + CHAT_TELL_ALERT_TIME;
			FCF_FlashTab();
		end

		return true;
	end
end

function ChatFrame_OnUpdate(elapsedSec)
	if ( not this:IsVisible() ) then
		return;
	end

	local flash = getglobal(this:GetName().."BottomButtonFlash");
	
	if ( not flash ) then
		return;
	end

	if ( this:AtBottom() ) then
		if ( flash:IsVisible() ) then
			flash:Hide();
		end
		return;
	end

	local flashTimer = this.flashTimer + elapsedSec;
	if ( flashTimer < CHAT_BUTTON_FLASH_TIME ) then
		this.flashTimer = flashTimer;
		return;
	end

	while ( flashTimer >= CHAT_BUTTON_FLASH_TIME ) do
		flashTimer = flashTimer - CHAT_BUTTON_FLASH_TIME;
	end
	this.flashTimer = flashTimer;

	if ( flash:IsVisible() ) then
		flash:Hide();
	else
		flash:Show();
	end
end

function ChatFrame_OnHyperlinkShow(link, text, button)
	SetItemRef(link, text, button);
end

function ChatFrame_OnMouseWheel(value)
	if ( value > 0 ) then
		SELECTED_DOCK_FRAME:ScrollUp();
	elseif ( value < 0 ) then
		SELECTED_DOCK_FRAME:ScrollDown();
	end
end

function ChatFrame_OpenChat(text, chatFrame)
	if ( not chatFrame ) then
		chatFrame = DEFAULT_CHAT_FRAME;
	end

	chatFrame.editBox:Show();
	chatFrame.editBox.setText = 1;
	chatFrame.editBox.text = text;

	if ( chatFrame.editBox:GetAttribute("chatType") == chatFrame.editBox:GetAttribute("stickyType") ) then
		if ( (chatFrame.editBox:GetAttribute("stickyType") == "PARTY") and (GetNumPartyMembers() == 0) ) then
			chatFrame.editBox:SetAttribute("chatType", "SAY");
			ChatEdit_UpdateHeader(chatFrame.editBox);
		elseif ( (chatFrame.editBox:GetAttribute("stickyType") == "RAID") and (GetNumRaidMembers() == 0) ) then
			chatFrame.editBox:SetAttribute("chatType", "SAY");
			ChatEdit_UpdateHeader(chatFrame.editBox);
		elseif ( (chatFrame.editBox:GetAttribute("stickyType") == "BATTLEGROUND") and (GetNumRaidMembers() == 0) ) then
			chatFrame.editBox:SetAttribute("chatType", "BATTLEGROUND");
			ChatEdit_UpdateHeader(chatFrame.editBox);
		end
	end
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
function MessageFrameScrollButton_OnLoad()
	this.clickDelay = MESSAGE_SCROLLBUTTON_INITIAL_DELAY;
	this:RegisterForClicks("LeftButtonDown", "LeftButtonUp", "RightButtonUp", "RightButtonDown");
end

--Controls scrolling for chatframe and combat log
function MessageFrameScrollButton_OnUpdate(elapsed)
	if (this:GetButtonState() == "PUSHED") then
		this.clickDelay = this.clickDelay - elapsed;
		if ( this.clickDelay < 0 ) then
			local name = this:GetName();
			if ( name == this:GetParent():GetName().."DownButton" ) then
				this:GetParent():ScrollDown();
			elseif ( name == this:GetParent():GetName().."UpButton" ) then
				this:GetParent():ScrollUp();
			end
			this.clickDelay = MESSAGE_SCROLLBUTTON_SCROLL_DELAY;
		end
	end
end

function ChatFrame_OpenMenu()
	ChatMenu:Show();
end

function ChatFrame_SendTell(name, chatFrame)
	if ( not chatFrame ) then
		chatFrame = DEFAULT_CHAT_FRAME;
	end

	if ( not chatFrame.editBox:IsVisible() ) then
		ChatFrame_OpenChat("/w "..name.." ", chatFrame);
	else
		chatFrame.editBox:SetText("/w "..name.." ");
	end
	ChatEdit_ParseText(chatFrame.editBox, 0);
--[[
	chatFrame.editBox:SetAttribute("chatType", "WHISPER");
	chatFrame.editBox:SetAttribute("tellTarget", name);
	ChatEdit_UpdateHeader(chatFrame.editBox);
	if ( not chatFrame.editBox:IsVisible() ) then
		ChatFrame_OpenChat("", chatFrame);
	end
]]
end

function ChatFrame_ReplyTell(chatFrame)
	if ( not chatFrame ) then
		chatFrame = DEFAULT_CHAT_FRAME;
	end

	local lastTell = ChatEdit_GetLastTellTarget(chatFrame.editBox);
	if ( strlen(lastTell) > 0 ) then
		chatFrame.editBox:SetAttribute("chatType", "WHISPER");
		chatFrame.editBox:SetAttribute("tellTarget", lastTell);
		ChatEdit_UpdateHeader(chatFrame.editBox);
		if ( not chatFrame.editBox:IsVisible() ) then
			ChatFrame_OpenChat("", chatFrame);
		end
	else
		-- Error message
	end
end

function ChatFrame_ReplyTell2(chatFrame)
	if ( not chatFrame ) then
		chatFrame = DEFAULT_CHAT_FRAME;
	end

	local lastTold = ChatEdit_GetLastToldTarget(chatFrame.editBox);
	if ( strlen(lastTold) > 0 ) then
		chatFrame.editBox:SetAttribute("chatType", "WHISPER");
		chatFrame.editBox:SetAttribute("tellTarget", lastTold);
		ChatEdit_UpdateHeader(chatFrame.editBox);
		if ( not chatFrame.editBox:IsVisible() ) then
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
	local text = TEXT(getglobal("STARTUP_TEXT_LINE"..i));
	while text do
		frame:AddMessage(text, info.r, info.g, info.b, info.id);
		i = i + 1;
		text = TEXT(getglobal("STARTUP_TEXT_LINE"..i));
	end

end

function ChatFrame_DisplayHelpText(frame)
	if ( not frame ) then
		return;
	end

	local info = ChatTypeInfo["SYSTEM"];
	local i = 1;
	local text = TEXT(getglobal("HELP_TEXT_LINE"..i));
	while text do
		frame:AddMessage(text, info.r, info.g, info.b, info.id);
		i = i + 1;
		text = TEXT(getglobal("HELP_TEXT_LINE"..i));
	end

end

function ChatFrame_DisplayMacroHelpText(frame)
	if ( not frame ) then
		return;
	end

	local info = ChatTypeInfo["SYSTEM"];
	local i = 1;
	local text = TEXT(getglobal("MACRO_HELP_TEXT_LINE"..i));
	while text do
		frame:AddMessage(text, info.r, info.g, info.b, info.id);
		i = i + 1;
		text = TEXT(getglobal("MACRO_HELP_TEXT_LINE"..i));
	end

end

function ChatFrame_DisplayChatHelp(frame)
	if ( not frame ) then
		return;
	end

	local info = ChatTypeInfo["SYSTEM"];
	local i = 1;
	local text = TEXT(getglobal("CHAT_HELP_TEXT_LINE"..i));
	while text do
		frame:AddMessage(text, info.r, info.g, info.b, info.id);
		i = i + 1;
		text = TEXT(getglobal("CHAT_HELP_TEXT_LINE"..i));
	end
end

function ChatFrame_DisplayGuildHelp(frame)
	if ( not frame ) then
		return;
	end

	local info = ChatTypeInfo["SYSTEM"];
	local i = 1;
	local text = TEXT(getglobal("GUILD_HELP_TEXT_LINE"..i));
	while text do
		frame:AddMessage(text, info.r, info.g, info.b, info.id);
		i = i + 1;
		text = TEXT(getglobal("GUILD_HELP_TEXT_LINE"..i));
	end
end

function ChatFrame_DisplayGameTime(frame)
	if ( not frame ) then
		return;
	end

	local info = ChatTypeInfo["SYSTEM"];
	frame:AddMessage(GameTime_GetTime(), info.r, info.g, info.b, info.id);
end

function ChatFrame_TimeBreakDown(time)
	local days = floor(time / (60 * 60 * 24));
	local hours = floor((time - (days * (60 * 60 * 24))) / (60 * 60));
	local minutes = floor((time - (days * (60 * 60 * 24)) - (hours * (60 * 60))) / 60);
	local seconds = mod(time, 60);
	return days, hours, minutes, seconds;
end

function ChatFrame_DisplayTimePlayed(totalTime, levelTime)
	local info = ChatTypeInfo["SYSTEM"];
	local d;
	local h;
	local m;
	local s;
	d, h, m, s = ChatFrame_TimeBreakDown(totalTime);
	local string = format(TEXT(TIME_PLAYED_TOTAL), format(TEXT(TIME_DAYHOURMINUTESECOND), d, h, m, s));
	this:AddMessage(string, info.r, info.g, info.b, info.id);
	
	d, h, m, s = ChatFrame_TimeBreakDown(levelTime);
	local string = format(TEXT(TIME_PLAYED_LEVEL), format(TEXT(TIME_DAYHOURMINUTESECOND), d, h, m, s));
	this:AddMessage(string, info.r, info.g, info.b, info.id);
end

function ChatFrame_ChatPageUp()
	SELECTED_CHAT_FRAME:PageUp();
end

function ChatFrame_ChatPageDown()
	SELECTED_CHAT_FRAME:PageDown();
end

-- ChatEdit functions
function ChatEdit_OnLoad()
	this:SetFrameLevel(this.chatFrame:GetFrameLevel()+1);
	this:SetAttribute("chatType", "SAY");
	this:SetAttribute("stickyType", "SAY");
	this.chatLanguage = GetDefaultLanguage();

	this.lastTell = {};
	for i = 1, NUM_REMEMBERED_TELLS, 1 do
		this.lastTell[i] = "";
	end
end

function ChatEdit_OnUpdate(elapsedSec)
	if ( this.setText == 1) then
		this:SetText(this.text);
		this.setText = 0;
		ChatEdit_ParseText(this, 0);
	end
end

function ChatEdit_OnShow()
	if ( this:GetAttribute("chatType") == "PARTY" and UnitName("party1") == "" ) then
		this:SetAttribute("chatType", "SAY");
	end
	if ( this:GetAttribute("chatType") == "RAID" and (GetNumRaidMembers() == 0) ) then
		this:SetAttribute("chatType", "SAY");
	end
	if ( (this:GetAttribute("chatType") == "GUILD" or this:GetAttribute("chatType") == "OFFICER") and not IsInGuild() ) then
		this:SetAttribute("chatType", "SAY");
	end
	if ( this:GetAttribute("chatType") == "BATTLEGROUND" and (GetNumRaidMembers() == 0) ) then
		this:SetAttribute("chatType", "SAY");
	end
	this.tabCompleteIndex = 1;
	this.tabCompleteText = nil;
	ChatEdit_UpdateHeader(this);
	ChatEdit_OnInputLanguageChanged();
	this:SetFocus();
end

function ChatEdit_InsertLink(text)
	if ( ChatFrameEditBox:IsShown() ) then
		ChatFrameEditBox:Insert(text);
		return true;
	end
	if ( MacroFrameText and MacroFrameText:IsVisible() ) then
		local item;
		if ( strfind(text, "item:", 1, true) ) then
			item = GetItemInfo(text);
		end
		if ( MacroFrameText:GetText() == "" ) then
			if ( item ) then
				if ( GetItemSpell(text) ) then
					MacroFrameText:Insert(TEXT(SLASH_USE1).." "..item);
				else
					MacroFrameText:Insert(TEXT(SLASH_EQUIP1).." "..item);
				end
			else
				MacroFrameText:Insert(TEXT(SLASH_CAST1).." "..text);
			end
		else
			MacroFrameText:Insert(item or text);
		end
		return true;
	end
	return false;
end

function ChatEdit_GetLastTellTarget(editBox)
	for index, value in pairs(editBox.lastTell) do
		if ( value and (strlen(value) > 0) ) then
			return value;
		end
	end
	return "";
end

function ChatEdit_GetLastToldTarget(editBox)
	local lastTold = editBox.toldTarget;
	if(not (lastTold == nil)) then
		return lastTold
	else
		--Error
		return ""
	end
end

function ChatEdit_SetLastToldTarget(editBox, name)
	editBox.toldTarget = name;
end

function ChatEdit_SetLastTellTarget(editBox, target)
	local found = NUM_REMEMBERED_TELLS;
	for index, value in pairs(editBox.lastTell) do
		if ( strupper(target) == strupper(value) ) then
			found = index;
			break;
		end
	end

	for i = found, 2, -1 do
		editBox.lastTell[i] = editBox.lastTell[i-1];
	end
	editBox.lastTell[1] = target;
end

function ChatEdit_GetNextTellTarget(editBox, target)
	if ( not target or (strlen(target) == 0) ) then
		return editBox.lastTell[1];
	end

	for i = 1, NUM_REMEMBERED_TELLS - 1, 1 do
		if ( strlen(editBox.lastTell[i]) == 0 ) then
			break;
		elseif ( strupper(target) == strupper(editBox.lastTell[i]) ) then
			if ( strlen(editBox.lastTell[i+1]) > 0 ) then
				return editBox.lastTell[i+1];
			else
				break;
			end
		end
	end

	return editBox.lastTell[1];
end

function ChatEdit_UpdateHeader(editBox)
	local type = editBox:GetAttribute("chatType");
	if ( not type ) then
		return;
	end

	local info = ChatTypeInfo[type];
	local header = getglobal(editBox:GetName().."Header");
	if ( not header ) then
		return;
	end

	if ( type == "WHISPER" ) then
		header:SetText(format(TEXT(getglobal("CHAT_WHISPER_SEND")), editBox:GetAttribute("tellTarget")));
	elseif ( type == "EMOTE" ) then
		header:SetText(format(TEXT(getglobal("CHAT_EMOTE_SEND")), UnitName("player")));
	elseif ( type == "CHANNEL" ) then
		local channel, channelName, instanceID = GetChannelName(editBox:GetAttribute("channelTarget"));
		if ( channelName ) then
			if ( instanceID > 0 ) then
				channelName = channelName.." "..instanceID;
			end
			info = ChatTypeInfo["CHANNEL"..channel];
			editBox:SetAttribute("channelTarget", channel);
			header:SetText(format(TEXT(getglobal("CHAT_CHANNEL_SEND")), channel, channelName));
		end
	else
		header:SetText(TEXT(getglobal("CHAT_"..type.."_SEND")));
	end

	header:SetTextColor(info.r, info.g, info.b);

	editBox:SetTextInsets(15 + header:GetWidth(), 13, 0, 0);
	editBox:SetTextColor(info.r, info.g, info.b);
end

function ChatEdit_AddHistory(editBox)
	local text = "";
	local type = editBox:GetAttribute("chatType");
	local header = getglobal("SLASH_"..type.."1");
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
		if ( type == "WHISPER") then
			if(strlen(text) > 0) then
				ChatEdit_SetLastToldTarget(editBox, editBox:GetAttribute("tellTarget"));
			end
			SendChatMessage(text, type, editBox.language, editBox:GetAttribute("tellTarget"));
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

function ChatEdit_OnEnterPressed()
	ChatEdit_SendText(this, 1);

	local type = this:GetAttribute("chatType");
	if ( ChatTypeInfo[type].sticky == 1 ) then
		this:SetAttribute("stickyType", type);
	end
	
	ChatEdit_OnEscapePressed(this);
end

function ChatEdit_OnEscapePressed(editBox)
	editBox:SetAttribute("chatType", editBox:GetAttribute("stickyType"));
	editBox:SetText("");
	editBox:Hide();
end

function ChatEdit_OnSpacePressed()
	ChatEdit_ParseText(this, 0);
end

function ChatEdit_CustomTabPressed()
end

function ChatEdit_SecureTabPressed()
	if ( this:GetAttribute("chatType") == "WHISPER" ) then
		local newTarget = ChatEdit_GetNextTellTarget(this, this:GetAttribute("tellTarget"));
		if ( newTarget and (strlen(newTarget) > 0) ) then
			this:SetAttribute("tellTarget", newTarget);
			ChatEdit_UpdateHeader(this);
		end
		return;
	end

	local text = this.tabCompleteText;
	if ( not text ) then
		text = this:GetText();
		this.tabCompleteText = text;
	end

	if ( strsub(text, 1, 1) ~= "/" ) then
		return;
	end

	-- Increment the current tabcomplete count
	local tabCompleteIndex = this.tabCompleteIndex;
	this.tabCompleteIndex = tabCompleteIndex + 1;

	-- If the string is in the format "/cmd blah", command will be "/cmd"
	local command = strmatch(text, "^(/[^%s]+)") or "";

	for index, value in pairs(ChatTypeInfo) do
		local i = 1;
		local cmdString = TEXT(getglobal("SLASH_"..index..i));
		while ( cmdString ) do
			if ( strfind(cmdString, command, 1, 1) ) then
				tabCompleteIndex = tabCompleteIndex - 1;
				if ( tabCompleteIndex == 0 ) then
					this.ignoreTextChange = 1;
					this:SetText(cmdString);
					return;
				end
			end
			i = i + 1;
			cmdString = TEXT(getglobal("SLASH_"..index..i));
		end
	end

	for index, value in pairs(SecureCmdList) do
		local i = 1;
		local cmdString = TEXT(getglobal("SLASH_"..index..i));
		while ( cmdString ) do
			if ( strfind(cmdString, command, 1, 1) ) then
				tabCompleteIndex = tabCompleteIndex - 1;
				if ( tabCompleteIndex == 0 ) then
					this.ignoreTextChange = 1;
					this:SetText(cmdString);
					return;
				end
			end
			i = i + 1;
			cmdString = TEXT(getglobal("SLASH_"..index..i));
		end
	end
	for index, value in pairs(SlashCmdList) do
		local i = 1;
		local cmdString = TEXT(getglobal("SLASH_"..index..i));
		while ( cmdString ) do
			if ( strfind(cmdString, command, 1, 1) ) then
				tabCompleteIndex = tabCompleteIndex - 1;
				if ( tabCompleteIndex == 0 ) then
					this.ignoreTextChange = 1;
					this:SetText(cmdString);
					return;
				end
			end
			i = i + 1;
			cmdString = TEXT(getglobal("SLASH_"..index..i));
		end
	end

	local i = 1;
	local j = 1;
	local cmdString = TEXT(getglobal("EMOTE"..i.."_CMD"..j));
	while ( cmdString ) do
		if ( strfind(cmdString, command, 1, 1) ) then
			tabCompleteIndex = tabCompleteIndex - 1;
			if ( tabCompleteIndex == 0 ) then
				this.ignoreTextChange = 1;
				this:SetText(cmdString);
				return;
			end
		end
		j = j + 1;
		cmdString = TEXT(getglobal("EMOTE"..i.."_CMD"..j));
		if ( not cmdString ) then
			i = i + 1;
			j = 1;
			cmdString = TEXT(getglobal("EMOTE"..i.."_CMD"..j));
		end
	end

	-- No tab completion
	this:SetText(this.tabCompleteText);
end

function ChatEdit_OnTabPressed()
	if ( securecall("ChatEdit_CustomTabPressed") ) then
		return;
	end
	ChatEdit_SecureTabPressed();
end

function ChatEdit_OnTextChanged()
	if ( not this.ignoreTextChange ) then
		this.tabCompleteIndex = 1;
		this.tabCompleteText = nil;
	end
	this.ignoreTextChange = nil;
end

function ChatEdit_OnTextSet()
	ChatEdit_ParseText(this, 0);
end

function ChatEdit_OnInputLanguageChanged()
	local button = getglobal(this:GetName().."Language");
	local variable = getglobal("INPUT_"..this:GetInputLanguage());
	button:SetText(TEXT(variable));
end

function ChatEdit_HandleChatType(editBox, msg, command, send)

	local channel = strmatch(command, "/([0-9]+)");

	if( channel and channel >= "0" and channel <= "9" ) then
		local channelNum, channelName = GetChannelName(channel);
		if ( channelNum > 0 ) then
			editBox:SetAttribute("channelTarget", channelNum);
			editBox:SetAttribute("chatType", "CHANNEL");
			editBox:SetText(msg);
			ChatEdit_UpdateHeader(editBox);
			return true;
		end
	else
		for index, value in pairs(ChatTypeInfo) do
			local i = 1;
			local cmdString = TEXT(getglobal("SLASH_"..index..i));
			while ( cmdString ) do
				cmdString = strupper(cmdString);
				if ( cmdString == command ) then
					if ( index == "WHISPER" ) then
						ChatEdit_ExtractTellTarget(editBox, msg);
					elseif ( index == "REPLY" ) then
						local lastTell = ChatEdit_GetLastTellTarget(editBox);
						if ( strlen(lastTell) > 0 ) then
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
					else
						editBox:SetAttribute("chatType", index);
						editBox:SetText(msg);
						ChatEdit_UpdateHeader(editBox);
					end
					return true;
				end
				i = i + 1;
				cmdString = TEXT(getglobal("SLASH_"..index..i));
			end
		end
	end
	return false;
end

function ChatEdit_ParseText(editBox, send)

	local text = editBox:GetText();
	if ( strlen(text) <= 0 ) then
		return;
	end

	if ( strsub(text, 1, 1) ~= "/" ) then
		return;
	end

	-- If the string is in the format "/cmd blah", command will be "cmd"
	local command = strmatch(text, "^(/[^%s]+)") or "";
	local msg = "";


	if ( command ~= text ) then
		msg = strsub(text, strlen(command) + 2);
	end

	command = strupper(command);

	if ( securecall("ChatEdit_HandleChatType", editBox, msg, command, send) ) then
		return;
	end

	if ( send == 0 ) then
		return;
	end

	for index, value in pairs(SecureCmdList) do
		local i = 1;
		local cmdString = TEXT(getglobal("SLASH_"..index..i));
		while ( cmdString ) do
			cmdString = strupper(cmdString);
			if ( cmdString == command ) then
				value(strtrim(msg));
				editBox:AddHistoryLine(text);
				ChatEdit_OnEscapePressed(editBox);
				return;
			end
			i = i + 1;
			cmdString = TEXT(getglobal("SLASH_"..index..i));
		end
	end
	for index, value in pairs(SlashCmdList) do
		local i = 1;
		local cmdString = TEXT(getglobal("SLASH_"..index..i));
		while ( cmdString ) do
			cmdString = strupper(cmdString);
			if ( cmdString == command ) then
				value(strtrim(msg));
				editBox:AddHistoryLine(text);
				ChatEdit_OnEscapePressed(editBox);
				return;
			end
			i = i + 1;
			cmdString = TEXT(getglobal("SLASH_"..index..i));
		end
	end

	local i = 1;
	local j = 1;
	local cmdString = TEXT(getglobal("EMOTE"..i.."_CMD"..j));
	while ( cmdString ) do
		if ( strupper(cmdString) == command ) then
			local token = getglobal("EMOTE"..i.."_TOKEN");
			if ( token ) then
				DoEmote(token, msg);
			end
			editBox:AddHistoryLine(text);
			ChatEdit_OnEscapePressed(editBox);
			return;
		end
		j = j + 1;
		cmdString = TEXT(getglobal("EMOTE"..i.."_CMD"..j));
		if ( not cmdString ) then
			i = i + 1;
			j = 1;
			cmdString = TEXT(getglobal("EMOTE"..i.."_CMD"..j));
		end
	end


	-- Unrecognized chat command, show simple help text
	if ( editBox.chatFrame ) then
		local info = ChatTypeInfo["SYSTEM"];
		editBox.chatFrame:AddMessage(TEXT(HELP_TEXT_SIMPLE), info.r, info.g, info.b, info.id);
	end
	ChatEdit_OnEscapePressed(editBox);
	return;
end

function ChatEdit_ExtractTellTarget(editBox, msg)
	-- Grab the first "word" in the string
	local target = strmatch(msg, "%s*([^%s]+)");
	if ( not target or (strsub(target, 1, 1) == "|") ) then
		return;
	end

	msg = strsub(msg, strlen(target) + 2);

	editBox:SetAttribute("tellTarget", target);
	editBox:SetAttribute("chatType", "WHISPER");
	editBox:SetText(msg);
	ChatEdit_UpdateHeader(editBox);
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

-- Chat menu functions
function ChatMenu_SetChatType(chatFrame, type)
	if ( not chatFrame.editBox:IsVisible() ) then
		ChatFrame_OpenChat("", chatFrame);
	end
	chatFrame.editBox:SetAttribute("chatType", type);
	ChatEdit_UpdateHeader(chatFrame.editBox);
end

function ChatMenu_Say()
	ChatMenu_SetChatType(this:GetParent().chatFrame, "SAY");
end

function ChatMenu_Party()
	ChatMenu_SetChatType(this:GetParent().chatFrame, "PARTY");
end

function ChatMenu_Guild()
	ChatMenu_SetChatType(this:GetParent().chatFrame, "GUILD");
end

function ChatMenu_Yell()
	ChatMenu_SetChatType(this:GetParent().chatFrame, "YELL");
end

function ChatMenu_Whisper()
	local chatFrame = this:GetParent().chatFrame;
	if ( not chatFrame.editBox:IsVisible() ) then
		ChatFrame_OpenChat("/w ", chatFrame);
	else
		chatFrame.editBox:SetText("/w "..chatFrame.editBox:GetText());
	end
end

function ChatMenu_Emote()
	ChatMenu_SetChatType(this:GetParent().chatFrame, "EMOTE");
end

function ChatMenu_Reply()
	ChatFrame_ReplyTell(this:GetParent().chatFrame);
end

function ChatMenu_VoiceMacro()
	ChatMenu_SetChatType(this:GetParent().chatFrame, "YELL");
end

function ChatMenu_OnLoad()
	UIMenu_Initialize();
	UIMenu_AddButton(TEXT(SAY_MESSAGE), TEXT(SLASH_SAY1), ChatMenu_Say);
	UIMenu_AddButton(TEXT(PARTY_MESSAGE), TEXT(SLASH_PARTY1), ChatMenu_Party);
	UIMenu_AddButton(TEXT(GUILD_MESSAGE), TEXT(SLASH_GUILD1), ChatMenu_Guild);
	UIMenu_AddButton(TEXT(YELL_MESSAGE), TEXT(SLASH_YELL1), ChatMenu_Yell);
	UIMenu_AddButton(TEXT(WHISPER_MESSAGE), TEXT(SLASH_WHISPER1), ChatMenu_Whisper);
	UIMenu_AddButton(TEXT(EMOTE_MESSAGE), TEXT(SLASH_EMOTE1), ChatMenu_Emote, "EmoteMenu");
	UIMenu_AddButton(TEXT(REPLY_MESSAGE), TEXT(SLASH_REPLY1), ChatMenu_Reply);
	UIMenu_AddButton(TEXT(LANGUAGE), nil, nil, "LanguageMenu");
	UIMenu_AddButton(TEXT(VOICEMACRO_LABEL), nil, nil, "VoiceMacroMenu");
	UIMenu_AddButton(TEXT(MACRO), TEXT(SLASH_MACRO1), ShowMacroFrame);
end

function ChatMenu_OnShow()
	UIMenu_OnShow();
	EmoteMenu:Hide();
end

function EmoteMenu_Click()
	DoEmote(EmoteList[this:GetID()]);
	ChatMenu:Hide();
end

function TextEmoteSort(token1, token2)
	local i = 1;
	local string1, string2;
	local token = getglobal("EMOTE"..i.."_TOKEN");
	while ( token ) do
		if ( token == token1 ) then
			string1 = TEXT(getglobal("EMOTE"..i.."_CMD1"));
			if ( string2 ) then
				break;
			end
		end
		if ( token == token2 ) then
			string2 = TEXT(getglobal("EMOTE"..i.."_CMD1"));
			if ( string1 ) then
				break;
			end
		end
		i = i + 1;
		token = getglobal("EMOTE"..i.."_TOKEN");
	end
	return string1 < string2;
end

function OnMenuLoad(list,func)
	sort(list, TextEmoteSort);
	UIMenu_Initialize();
	this.parentMenu = "ChatMenu";
	for index, value in pairs(list) do
		local i = 1;
		local token = getglobal("EMOTE"..i.."_TOKEN");
		while ( token ) do
			if ( token == value ) then
				break;
			end
			i = i + 1;
			token = getglobal("EMOTE"..i.."_TOKEN");
		end
		local label = TEXT(getglobal("EMOTE"..i.."_CMD1"));
		if ( not label ) then
			label = value;
		end
		UIMenu_AddButton(label, nil, func);
	end
end

function EmoteMenu_OnLoad()
	OnMenuLoad(EmoteList,EmoteMenu_Click);
end

function LanguageMenu_OnLoad()
	UIMenu_Initialize();
	this.parentMenu = "ChatMenu";
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("LANGUAGE_LIST_CHANGED");
end

function VoiceMacroMenu_Click()
	DoEmote(TextEmoteSpeechList[this:GetID()]);
	ChatMenu:Hide();
end

function VoiceMacroMenu_OnLoad()
	OnMenuLoad(TextEmoteSpeechList,VoiceMacroMenu_Click);
end

function LanguageMenu_OnEvent(event)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		this:Hide();
		UIMenu_Initialize();
		LanguageMenu_LoadLanguages();
		return;
	end
	if ( event == "LANGUAGE_LIST_CHANGED" ) then
		this:Hide();
		UIMenu_Initialize();
		LanguageMenu_LoadLanguages();
		return;
	end
end

function LanguageMenu_LoadLanguages()
	local numLanguages = GetNumLaguages();
	local i;
	for i = 1, numLanguages, 1 do
		local language = GetLanguageByIndex(i);
		UIMenu_AddButton(language, nil, LanguageMenu_Click);
	end
end

function LanguageMenu_Click()
	this:GetParent():GetParent().chatFrame.editBox.language = GetLanguageByIndex(this:GetID());
	ChatMenu:Hide();
end

function ChatFrame_ActivateCombatMessages(chatFrame)
	ChatFrame_AddMessageGroup(chatFrame, "COMBAT_MISC_INFO");
	ChatFrame_AddMessageGroup(chatFrame, "COMBAT_SELF_HITS");
	ChatFrame_AddMessageGroup(chatFrame, "COMBAT_SELF_MISSES");
	ChatFrame_AddMessageGroup(chatFrame, "COMBAT_PET_HITS");
	ChatFrame_AddMessageGroup(chatFrame, "COMBAT_PET_MISSES");
	ChatFrame_AddMessageGroup(chatFrame, "COMBAT_PARTY_HITS");
	ChatFrame_AddMessageGroup(chatFrame, "COMBAT_PARTY_MISSES");
	ChatFrame_AddMessageGroup(chatFrame, "COMBAT_FRIENDLYPLAYER_HITS");
	ChatFrame_AddMessageGroup(chatFrame, "COMBAT_FRIENDLYPLAYER_MISSES");
	ChatFrame_AddMessageGroup(chatFrame, "COMBAT_HOSTILEPLAYER_HITS");
	ChatFrame_AddMessageGroup(chatFrame, "COMBAT_HOSTILEPLAYER_MISSES");
	ChatFrame_AddMessageGroup(chatFrame, "COMBAT_CREATURE_VS_SELF_HITS");
	ChatFrame_AddMessageGroup(chatFrame, "COMBAT_CREATURE_VS_SELF_MISSES");
	ChatFrame_AddMessageGroup(chatFrame, "COMBAT_CREATURE_VS_PARTY_HITS");
	ChatFrame_AddMessageGroup(chatFrame, "COMBAT_CREATURE_VS_PARTY_MISSES");
	ChatFrame_AddMessageGroup(chatFrame, "COMBAT_CREATURE_VS_CREATURE_HITS");
	ChatFrame_AddMessageGroup(chatFrame, "COMBAT_CREATURE_VS_CREATURE_MISSES");
	ChatFrame_AddMessageGroup(chatFrame, "COMBAT_FRIENDLY_DEATH");
	ChatFrame_AddMessageGroup(chatFrame, "COMBAT_HOSTILE_DEATH");
	ChatFrame_AddMessageGroup(chatFrame, "COMBAT_XP_GAIN");
	ChatFrame_AddMessageGroup(chatFrame, "COMBAT_HONOR_GAIN");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_SELF_DAMAGE");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_SELF_BUFF");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_PET_DAMAGE");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_PET_BUFF");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_PARTY_DAMAGE");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_PARTY_BUFF");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_FRIENDLYPLAYER_DAMAGE");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_FRIENDLYPLAYER_BUFF");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_HOSTILEPLAYER_DAMAGE");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_HOSTILEPLAYER_BUFF");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_CREATURE_VS_SELF_DAMAGE");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_CREATURE_VS_SELF_BUFF");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_CREATURE_VS_PARTY_DAMAGE");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_CREATURE_VS_PARTY_BUFF");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_CREATURE_VS_CREATURE_DAMAGE");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_CREATURE_VS_CREATURE_BUFF");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_TRADESKILLS");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_DAMAGESHIELDS_ON_SELF");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_DAMAGESHIELDS_ON_OTHERS");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_AURA_GONE_SELF");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_AURA_GONE_PARTY");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_AURA_GONE_OTHER");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_ITEM_ENCHANTMENTS");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_BREAK_AURA");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_PERIODIC_SELF_DAMAGE");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_PERIODIC_SELF_BUFFS");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_PERIODIC_PARTY_DAMAGE");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_PERIODIC_PARTY_BUFFS");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_PERIODIC_HOSTILEPLAYER_BUFFS");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_PERIODIC_CREATURE_DAMAGE");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_PERIODIC_CREATURE_BUFFS");
	ChatFrame_AddMessageGroup(chatFrame, "SPELL_FAILED_LOCALPLAYER");
end
