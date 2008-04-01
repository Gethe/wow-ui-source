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

EmoteList = {
	"WAVE",
	"BOW",
	"DANCE",
	"APPLAUD",
	"BEG",
	"CHEER",
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

-- NEVER rely on the ordering of these entries to match anything because the entries in
-- VoiceMacroList get sorted according to the client's locale. There's a lookup in
-- SoundInterfaceVocal.cpp (s_voiceMacroLabels) that does the lookup.
VoiceMacroList = {
	"HELPME",
	"INCOMING",
	"CHARGE",
	"FLEE",
	"ATTACKMYTARGET",
	"OUTOFMANA",
	"FOLLOWME",
	"WAITHERE",
	"HEALME",
	"CHEER",
	"OPENFIRE",
	"RASPBERRY",
	"HELLO",
	"GOODBYE",
	"YES",
	"NO",
	"THANKYOU",
	"YOUREWELCOME",
	"CONGRATULATIONS",
	"FLIRT",
	"JOKE",
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

function GetSlashCmdTarget(msg, nonPlayers)
	local target = gsub(msg, "(%s*)([^%s]+)(.*)", "%2", 1);
	if ( (strlen(target) <= 0) and (nonPlayers or UnitIsPlayer("target")) ) then
		target = UnitName("target");
	end
	if ( target and (strlen(target) == 0) ) then
		target = nil;
	end
	return target;
end


-- Slash commands
SlashCmdList = { };

SlashCmdList["CONSOLE"] = function(msg)
	ConsoleExec(msg);
end

SlashCmdList["COMBATLOG"] = function()
	ToggleCombatLogFileWrite();
end

SlashCmdList["INVITE"] = function(msg)
	if ( GetSlashCmdTarget(msg) ) then
		InviteByName(GetSlashCmdTarget(msg));
	end
end

SlashCmdList["UNINVITE"] = function(msg)
	if ( GetSlashCmdTarget(msg) ) then
		UninviteByName(GetSlashCmdTarget(msg));
	end
end

SlashCmdList["PROMOTE"] = function(msg)
	if ( GetSlashCmdTarget(msg) ) then
		PromoteByName(GetSlashCmdTarget(msg));
	end
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
	ChatFrame_DisplayHelpText(this.chatFrame);
end

SlashCmdList["MACROHELP"] = function(msg)
	ChatFrame_DisplayMacroHelpText(this.chatFrame);
end

SlashCmdList["TIME"] = function(msg)
	ChatFrame_DisplayGameTime(this.chatFrame);
end

SlashCmdList["PLAYED"] = function(msg)
	RequestTimePlayed();
end

SlashCmdList["ASSIST"] = function(msg)
	if ( GetSlashCmdTarget(msg) ) then
		AssistByName(GetSlashCmdTarget(msg));
	else
		AssistUnit("target");
	end
end

SlashCmdList["TARGET"] = function(msg)
	if ( GetSlashCmdTarget(msg) ) then
		TargetByName(GetSlashCmdTarget(msg));
	end
end

SlashCmdList["FOLLOW"] = function(msg)
	if ( GetSlashCmdTarget(msg) ) then
		FollowByName(GetSlashCmdTarget(msg));
	else
		FollowUnit("target");
	end
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

SlashCmdList["BUG"] = function(msg)
	ShowSuggestFrame(msg, "bug");
end

SlashCmdList["SUGGEST"] = function(msg)
	ShowSuggestFrame(msg, "suggest");
end

SlashCmdList["NOTE"] = function(msg)
	ReportNote(msg);
end

SlashCmdList["JOIN"] = 	function(msg)
	local name = gsub(msg, "%s*([^%s]+).*", "%1");
	local password = gsub(msg, "%s*([^%s]+)%s*(.*)", "%2");
	if(strlen(name) <= 0) then
		local joinhelp = TEXT(getglobal("CHAT_JOIN_HELP"));
		local info = ChatTypeInfo["SYSTEM"];
		this.chatFrame:AddMessage(joinhelp, info.r, info.g, info.b, info.id);
	else
		local zoneChannel, channelName = JoinChannelByName(name, password, this.chatFrame:GetID());
		if ( channelName ) then
			name = channelName;
		end
		if ( not zoneChannel ) then
			return;
		end

		local i = 1;
		while ( this.chatFrame.channelList[i] ) do
			i = i + 1;
		end
		this.chatFrame.channelList[i] = name;
		this.chatFrame.zoneChannelList[i] = zoneChannel;
	end
end

SlashCmdList["LEAVE"] = function(msg)
	local name = gsub(msg, "%s*([^%s]+).*", "%1");
	LeaveChannelByName(name);
end

SlashCmdList["LIST_CHANNEL"] = function(msg)
	local name = gsub(msg, "%s*([^%s]+).*", "%1");
	if(strlen(name) > 0) then
		ListChannelByName(name);
	else
		ListChannels();
	end
end

SlashCmdList["CHAT_HELP"] = 
	function(msg)
		ChatFrame_DisplayChatHelp(this.chatFrame)
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
		local channel = gsub(msg, "%s*([^%s]+).*", "%1");
		local player = gsub(msg, "%s*([^%s]+)%s*(.*)", "%2");
		if(strlen(channel) > 0) then
			if(strlen(player) > 0) then
				ChannelModerator(channel, player);
			end
		end
	end

SlashCmdList["CHAT_UNMODERATOR"] =
	function(msg)
		local channel = gsub(msg, "%s*([^%s]+).*", "%1");
		local player = gsub(msg, "%s*([^%s]+)%s*(.*)", "%2");
		if(strlen(channel) > 0) then
			if(strlen(player) > 0) then
				ChannelUnmoderator(channel, player);
			end
		end
	end

SlashCmdList["CHAT_MODERATE"] = 
	function(msg)
		local channel = gsub(msg, "%s*([^%s]+).*", "%1");
		if(strlen(channel) > 0) then
			ChannelModerate(channel);
		end
	end

SlashCmdList["CHAT_MUTE"] =
	function(msg)
		local channel = gsub(msg, "%s*([^%s]+).*", "%1");
		local player = gsub(msg, "%s*([^%s]+)%s*(.*)", "%2");
		if(strlen(channel) > 0) then
			if(strlen(player) > 0) then
				ChannelMute(channel, player);
			end
		end
	end

SlashCmdList["CHAT_UNMUTE"] =
	function(msg)
		local channel = gsub(msg, "%s*([^%s]+).*", "%1");
		local player = gsub(msg, "%s*([^%s]+)%s*(.*)", "%2");
		if(strlen(channel) > 0) then
			if(strlen(player) > 0) then
				ChannelUnmute(channel, player);
			end
		end
	end

SlashCmdList["CHAT_CINVITE"] =
	function(msg)
		local channel = gsub(msg, "%s*([^%s]+).*", "%1");
		local player = gsub(msg, "%s*([^%s]+)%s*(.*)", "%2");
		if(strlen(channel) > 0) then
			if(strlen(player) > 0) then
				ChannelInvite(channel, player);
			end
		end
	end

SlashCmdList["CHAT_KICK"] =
	function(msg)
		local channel = gsub(msg, "%s*([^%s]+).*", "%1");
		local player = gsub(msg, "%s*([^%s]+)%s*(.*)", "%2");
		if(strlen(channel) > 0) then
			if(strlen(player) > 0) then
				ChannelKick(channel, player);
			end
		end
	end

SlashCmdList["CHAT_BAN"] =
	function(msg)
		local channel = gsub(msg, "%s*([^%s]+).*", "%1");
		local player = gsub(msg, "%s*([^%s]+)%s*(.*)", "%2");
		if(strlen(channel) > 0) then
			if(strlen(player) > 0) then
				ChannelBan(channel, player);
			end
		end
	end

SlashCmdList["CHAT_UNBAN"] =
	function(msg)
		local channel = gsub(msg, "%s*([^%s]+).*", "%1");
		local player = gsub(msg, "%s*([^%s]+)%s*(.*)", "%2");
		if(strlen(channel) > 0) then
			if(strlen(player) > 0) then
				ChannelUnban(channel, player);
			end
		end
	end

SlashCmdList["CHAT_ANNOUNCE"] =
	function(msg)
		local channel = gsub(msg, "%s*([^%s]+).*", "%1");
		if(strlen(channel) > 0) then
			ChannelToggleAnnouncements(channel);
		end
	end

SlashCmdList["GUILD_INVITE"] = function(msg)
	if ( GetSlashCmdTarget(msg) ) then
		GuildInviteByName(GetSlashCmdTarget(msg));
	end
end

SlashCmdList["GUILD_UNINVITE"] = function(msg)
	if ( GetSlashCmdTarget(msg) ) then
		GuildUninviteByName(GetSlashCmdTarget(msg));
	end
end

SlashCmdList["GUILD_PROMOTE"] = function(msg)
	if ( GetSlashCmdTarget(msg) ) then
		GuildPromoteByName(GetSlashCmdTarget(msg));
	end
end

SlashCmdList["GUILD_DEMOTE"] = function(msg)
	if ( GetSlashCmdTarget(msg) ) then
		GuildDemoteByName(GetSlashCmdTarget(msg));
	end
end

SlashCmdList["GUILD_LEADER"] = function(msg)
	if ( GetSlashCmdTarget(msg) ) then
		GuildSetLeaderByName(GetSlashCmdTarget(msg));
	end
end

SlashCmdList["GUILD_MOTD"] = function(msg)
	GuildSetMOTD(msg)
end

SlashCmdList["GUILD_LEAVE"] = function(msg)
	GuildLeave();
end

SlashCmdList["GUILD_DISBAND"] = function(msg)
	GuildDisband();
end

SlashCmdList["GUILD_INFO"] = function(msg)
	GuildInfo();
end

SlashCmdList["GUILD_ROSTER"] = function(msg)
	GuildRoster();
end

--SlashCmdList["GUILD_HELP"] = function(msg)
--	ChatFrame_DisplayGuildHelp(this.chatFrame);
--end

SlashCmdList["CHAT_AFK"] = function(msg)
	SendChatMessage(msg, "AFK");
end

SlashCmdList["CHAT_DND"] = function(msg)
	SendChatMessage(msg, "DND");
end

SlashCmdList["WHO"] = function(msg)
	if ( msg == "") then
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
	SendChatMessage(msg, "CHANNEL", this.language, this.channelTarget);
end

SlashCmdList["FRIENDS"] = function(msg)
	if ( GetSlashCmdTarget(msg) ) then
		AddFriend(GetSlashCmdTarget(msg));
	else
		ShowFriends();
	end
end

SlashCmdList["REMOVEFRIEND"] = function(msg)
	if ( GetSlashCmdTarget(msg) ) then
		RemoveFriend(GetSlashCmdTarget(msg));
	end
end

SlashCmdList["IGNORE"] = function(msg)
	if ( GetSlashCmdTarget(msg) ) then
		AddOrDelIgnore(GetSlashCmdTarget(msg));
	else
		ShowIgnorePanel();
	end
end

SlashCmdList["UNIGNORE"] = function(msg)
	if ( GetSlashCmdTarget(msg) ) then
		DelIgnore(GetSlashCmdTarget(msg));
	else
		ShowIgnorePanel();
	end
end

SlashCmdList["DUEL"] = function(msg)
	StartDuel(GetSlashCmdTarget(msg))
end

SlashCmdList["DUEL_CANCEL"] = function(msg)
	CancelDuel()
end

SlashCmdList["SPLIT"] = function(msg)
	if ( msg ~= "" ) then
		if ( SplitMoney(msg) ) then
			return;
		end
	end

	local splithelp = TEXT(getglobal("SPLIT_MONEY_HELP"));
	local info = ChatTypeInfo["SYSTEM"];
	this.chatFrame:AddMessage(splithelp, info.r, info.g, info.b, info.id);
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
	SetLootMethod("master", GetSlashCmdTarget(msg));
end

SlashCmdList["RANDOM"] = function(msg)
	local num1 = gsub(msg, "(%s*)(%d+)(.*)", "%2", 1);
	local rest = gsub(msg, "(%s*)(%d+)(.*)", "%3", 1);
	local num2 = 0;
	if ( strlen(rest) > 0 ) then
		num2 = gsub(msg, "(%s*)(%d+)([-%s]+)(%d+)(.*)", "%4", 1);
	end

	if ( num1 == 0 and num2 == 0 ) then
		RandomRoll("1", "100");
	elseif ( num2 == 0 ) then
		RandomRoll("1", num1);
	else
		RandomRoll(num1, num2);
	end
end

SlashCmdList["MACRO"] = function(msg)
	--if(msg == "") then
		ShowMacroFrame();
	--else
		--RunMacro(msg);
	--end
end

SlashCmdList["CAST"] = function(msg)
	if(msg ~= "") then
		CastSpellByName(msg);
	end
end

SlashCmdList["PVP"] = function(msg)
	EnablePVP();
end

-- ChatFrame functions
function ChatFrame_OnLoad()
	this.flashTimer = 0;
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("UPDATE_CHAT_COLOR");
	this:RegisterEvent("UPDATE_CHAT_WINDOWS");
	this:RegisterEvent("CHAT_MSG_CHANNEL");
	this:RegisterEvent("ZONE_UNDER_ATTACK");
	this.tellTimer = GetTime();
	this.channelList = {};
	this.zoneChannelList = {};
	this.messageTypeList = {};

	for index, value in ChatTypeInfo do
		value.r = 1.0;
		value.g = 1.0;
		value.b = 1.0;
		value.id = GetChatTypeIndex(index);
	end
end

function ChatFrame_RegisterForMessages(...)
	local messageGroup;
	local index = 1;
	for i=1, arg.n do
		messageGroup = ChatTypeGroup[arg[i]];
		if ( messageGroup ) then
			this.messageTypeList[index] = arg[i];
			for index, value in messageGroup do
				this:RegisterEvent(value);
			end
			index = index + 1;
		end
	end
end

function ChatFrame_RegisterForChannels(...)
	local index = 1;
	for i=1, arg.n, 2 do
		this.channelList[index] = arg[i];
		this.zoneChannelList[index] = arg[i+1];
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
		for index, value in info do
			chatFrame:RegisterEvent(value);
		end
		AddChatWindowMessages(chatFrame:GetID(), group);
	end
end

function ChatFrame_RemoveMessageGroup(chatFrame, group)
	local info = ChatTypeGroup[group];
	if ( info ) then
		for index, value in chatFrame.messageTypeList do
			if ( strupper(value) == strupper(group) ) then
				chatFrame.messageTypeList[index] = nil;
			end
		end
		for index, value in info do
			chatFrame:UnregisterEvent(value);
		end
		RemoveChatWindowMessages(chatFrame:GetID(), group);
	end
end

function ChatFrame_RemoveAllMessageGroups(chatFrame)
	for index, value in chatFrame.messageTypeList do
		for eventIndex, eventValue in ChatTypeGroup[value] do
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
	for index, value in chatFrame.channelList do
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

function ChatFrame_OnEvent(event)
	if ( event == "UPDATE_CHAT_WINDOWS" ) then
		local name, fontSize, r, g, b, a, shown, locked = GetChatWindowInfo(this:GetID());
		if ( fontSize > 0 ) then
			this:SetFontHeight(fontSize);
		end
		if ( shown ) then
			this:Show();
		end
		-- Do more stuff!!!
		ChatFrame_RegisterForMessages(GetChatWindowMessages(this:GetID()));
		ChatFrame_RegisterForChannels(GetChatWindowChannels(this:GetID()));
		return;
	end
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		this.defaultLanguage = GetDefaultLanguage();
		return;
	end
	if ( event == "TIME_PLAYED_MSG" ) then
		ChatFrame_DisplayTimePlayed(arg1, arg2);
		return;
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
			string = format(TEXT(LEVEL_UP_STAT), TEXT(SPELL_STAT0_NAME), arg5);
			this:AddMessage(string, info.r, info.g, info.b, info.id);
		end
		if ( arg6 > 0 ) then
			string = format(TEXT(LEVEL_UP_STAT), TEXT(SPELL_STAT1_NAME), arg6);
			this:AddMessage(string, info.r, info.g, info.b, info.id);
		end
		if ( arg7 > 0 ) then
			string = format(TEXT(LEVEL_UP_STAT), TEXT(SPELL_STAT2_NAME), arg7);
			this:AddMessage(string, info.r, info.g, info.b, info.id);
		end
		if ( arg8 > 0 ) then
			string = format(TEXT(LEVEL_UP_STAT), TEXT(SPELL_STAT3_NAME), arg8);
			this:AddMessage(string, info.r, info.g, info.b, info.id);
		end
		if ( arg9 > 0 ) then
			string = format(TEXT(LEVEL_UP_STAT), TEXT(SPELL_STAT4_NAME), arg9);
			this:AddMessage(string, info.r, info.g, info.b, info.id);
		end
		return;
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
		return;
	end
	if ( event == "GUILD_MOTD" ) then
		local info = ChatTypeInfo["GUILD"];
		local string = format(TEXT(GUILD_MOTD_TEMPLATE), arg1);
		this:AddMessage(string, info.r, info.g, info.b, info.id);
		return;
	end
	if ( event == "EXECUTE_CHAT_LINE" ) then
		this.editBox:SetText(arg1);
		ChatEdit_SendText(this.editBox);
		ChatEdit_OnEscapePressed(this.editBox);
		return;
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
		return;
	end
	if ( strsub(event, 1, 8) == "CHAT_MSG" ) then
		local type = strsub(event, 10);
		local info = ChatTypeInfo[type];
		
		local channelLength = strlen(arg4);
		if ( (strsub(type, 1, 7) == "CHANNEL") and (type ~= "CHANNEL_LIST") and (arg1 ~= "INVITE") ) then
			local found = 0;
			for index, value in this.channelList do
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
				return;
			end
		end

		if ( type == "SYSTEM" or type == "TEXT_EMOTE" or type == "SKILL" or type == "LOOT" ) then
			this:AddMessage(arg1, info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,7) == "COMBAT_" ) then
			this:AddMessage(arg1, info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,6) == "SPELL_" ) then
			this:AddMessage(arg1, info.r, info.g, info.b, info.id);
		elseif ( type == "IGNORED" ) then
			this:AddMessage(format(TEXT(getglobal("CHAT_IGNORED")), arg2), info.r, info.g, info.b, info.id);
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
			this:AddMessage(format(TEXT(getglobal("CHAT_"..arg1.."_NOTICE")), arg4), info.r, info.g, info.b, info.id);
		else
			arg1 = gsub(arg1, "%%", "%%%%");
			local body;

			-- Add AFK/DND flags
			local pflag;
			if(strlen(arg6) > 0) then
				pflag = TEXT(getglobal("CHAT_FLAG_"..arg6));
			else
				pflag = "";
			end

			local showLink = 1;
			if ( strsub(type, 1, 7) == "MONSTER" ) then
				showLink = nil;
			end
			if ( (strlen(arg3) > 0) and (arg3 ~= "Universal") and (arg3 ~= this.defaultLanguage) ) then
				local languageHeader = "["..arg3.."] ";
				if ( showLink and (strlen(arg2) > 0) ) then
					body = format(TEXT(getglobal("CHAT_"..type.."_GET"))..languageHeader..arg1, pflag.."|HPlayer:"..arg2.."|h".."["..arg2.."]".."|h");
				else
					body = format(TEXT(getglobal("CHAT_"..type.."_GET"))..languageHeader..arg1, pflag..arg2);
				end
			else
				if ( showLink and (strlen(arg2) > 0) and (type ~= "EMOTE") ) then
					body = format(TEXT(getglobal("CHAT_"..type.."_GET"))..arg1, pflag.."|HPlayer:"..arg2.."|h".."["..arg2.."]".."|h");
				else
					body = format(TEXT(getglobal("CHAT_"..type.."_GET"))..arg1, pflag..arg2);
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
		return;
	end
	if ( event == "ZONE_UNDER_ATTACK" ) then
		local info = ChatTypeInfo["SYSTEM"];
		this:AddMessage(format(TEXT(ZONE_UNDER_ATTACK), arg1), info.r, info.g, info.b, info.id);
		return;
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

function ChatFrame_OnHyperlinkShow(link)
	SetItemRef(link);
end

function ChatFrame_OnHyperlinkHide()
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

	if ( (chatFrame.editBox.stickyType == "PARTY") and (GetNumPartyMembers() == 0) ) then
		chatFrame.editBox.chatType = "SAY";
		ChatEdit_UpdateHeader(chatFrame.editBox);
	elseif ( (chatFrame.editBox.stickyType == "RAID") and (GetNumRaidMembers() == 0) ) then
		chatFrame.editBox.chatType = "SAY";
		ChatEdit_UpdateHeader(chatFrame.editBox);
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

function ChatFrame_ReplyTell(chatFrame)
	if ( not chatFrame ) then
		chatFrame = DEFAULT_CHAT_FRAME;
	end

	local lastTell = ChatEdit_GetLastTellTarget(chatFrame.editBox);
	if ( strlen(lastTell) > 0 ) then
		chatFrame.editBox.chatType = "WHISPER";
		chatFrame.editBox.tellTarget = lastTell;
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
	this.chatType = "SAY";
	this.stickyType = "SAY";
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
	if ( this.chatType == "PARTY" and UnitName("party1") == "" ) then
		this.chatType = "SAY";
	end
	if ( this.chatType == "RAID" and (GetNumRaidMembers() == 0) ) then
		this.chatType = "SAY";
	end
	if ( (this.chatType == "GUILD" or this.chatType == "OFFICER") and not IsInGuild() ) then
		this.chatType = "SAY";
	end
	this.tabCompleteIndex = 1;
	this.tabCompleteText = nil;
	ChatEdit_UpdateHeader(this);
	ChatEdit_OnInputLanguageChanged();
end

function ChatEdit_GetLastTellTarget(editBox)
	for index, value in editBox.lastTell do
		if ( value and (strlen(value) > 0) ) then
			return value;
		end
	end
	return "";
end

function ChatEdit_SetLastTellTarget(editBox, target)
	local found = NUM_REMEMBERED_TELLS;
	for index, value in editBox.lastTell do
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
	local type = editBox.chatType;
	if ( not type ) then
		return;
	end

	local info = ChatTypeInfo[type];
	local header = getglobal(editBox:GetName().."Header");
	if ( not header ) then
		return;
	end

	if ( type == "WHISPER" ) then
		header:SetText(format(TEXT(getglobal("CHAT_WHISPER_SEND")), editBox.tellTarget));
	elseif ( type == "EMOTE" ) then
		header:SetText(format(TEXT(getglobal("CHAT_EMOTE_SEND")), UnitName("player")));
	elseif ( type == "CHANNEL" ) then
		local channel, channelName = GetChannelName(editBox.channelTarget);
		if ( channelName ) then
			info = ChatTypeInfo["CHANNEL"..channel];
			editBox.channelTarget = channel;
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
	local type = editBox.chatType;
	local header = getglobal("SLASH_"..type.."1");
	if ( header ) then
		text = header;
	end

	if ( type == "WHISPER" ) then
		text = text.." "..editBox.tellTarget;
	elseif ( type == "CHANNEL" ) then
		text = "/"..editBox.channelTarget;
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

	local type = editBox.chatType;
	local text = editBox:GetText();
	if ( strlen(gsub(text, "%s*(.*)", "%1")) > 0 ) then
		if ( type == "WHISPER") then
			SendChatMessage(text, type, editBox.language, editBox.tellTarget);
		elseif ( type == "CHANNEL") then
			SendChatMessage(text, type, editBox.language, editBox.channelTarget);
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

	local type = this.chatType;
	if ( ChatTypeInfo[type].sticky == 1 ) then
		this.stickyType = type;
	end
	
	ChatEdit_OnEscapePressed(this);
end

function ChatEdit_OnEscapePressed(editBox)
	editBox.chatType = editBox.stickyType;
	editBox:SetText("");
	editBox:Hide();
end

function ChatEdit_OnSpacePressed()
	ChatEdit_ParseText(this, 0);
end

function ChatEdit_OnTabPressed()
	if ( this.chatType == "WHISPER" ) then
		local newTarget = ChatEdit_GetNextTellTarget(this, this.tellTarget);
		if ( newTarget and (strlen(newTarget) > 0) ) then
			this.tellTarget = newTarget;
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

	-- If the string is in the format "/cmd blah", command will be "cmd"
	local command = gsub(text, "/([^%s]+)%s(.*)", "/%1", 1);

	for index, value in ChatTypeInfo do
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

	for index, value in SlashCmdList do
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

function ChatEdit_ParseText(editBox, send)

	local text = editBox:GetText();
	if ( strlen(text) <= 0 ) then
		return;
	end

	if ( strsub(text, 1, 1) ~= "/" ) then
		return;
	end

	-- If the string is in the format "/cmd blah", command will be "cmd"
	local command = gsub(text, "/([^%s]+)%s(.*)", "/%1", 1);
	local msg = "";


	if ( command ~= text ) then
		msg = strsub(text, strlen(command) + 2);
	end

	command = gsub(command, "%s+", "");
	command = strupper(command);

	local channel = gsub(command, "/([0-9]+)", "%1");

	if( strlen(channel) > 0 and channel >= "0" and channel <= "9" ) then
		local channelNum, channelName = GetChannelName(channel);
		if ( channelNum > 0 ) then
			editBox.channelTarget = channelNum;
			command = strupper(SLASH_CHANNEL1);
			editBox.chatType = "CHANNEL";
			editBox:SetText(msg);
			ChatEdit_UpdateHeader(editBox);
			return;
		end
	else
		for index, value in ChatTypeInfo do
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
							editBox.chatType = "WHISPER";
							editBox.tellTarget = lastTell;
							editBox:SetText(msg);
							ChatEdit_UpdateHeader(editBox);
						else
							if ( send == 1 ) then
								ChatEdit_OnEscapePressed(editBox);
							end
							return;
						end
					elseif (index == "CHANNEL") then
						ChatEdit_ExtractChannel(editBox, msg);
					else
						editBox.chatType = index;
						editBox:SetText(msg);
						ChatEdit_UpdateHeader(editBox);
					end
					return;
				end
				i = i + 1;
				cmdString = TEXT(getglobal("SLASH_"..index..i));
			end
		end
	end

	if ( send == 0 ) then
		return;
	end


	for index, value in SlashCmdList do
		local i = 1;
		local cmdString = TEXT(getglobal("SLASH_"..index..i));
		while ( cmdString ) do
			cmdString = strupper(cmdString);
			if ( cmdString == command ) then
				value(msg);
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

	i = 1;
	cmdString = TEXT(getglobal("SLASH_VOICEMACRO"..i));
	while ( cmdString ) do
		if( strupper(cmdString) == command ) then
			for index, value in VoiceMacroList do
				j = 1;
				local token = getglobal("VOICEMACRO_LABEL_"..value..j);
				while ( token ) do
					if ( strupper(token) == strupper(msg) ) then
						editBox:AddHistoryLine(text);
						PlayVocalCategory(VoiceMacroList[index]);
						ChatEdit_OnEscapePressed(editBox);
						return;
					end
					j = j + 1;
					token = getglobal("VOICEMACRO_LABEL_"..value..j);
				end
			end
		end
		i = i + 1;
		cmdString = TEXT(getglobal("SLASH_VOICEMACRO"..i));
	end

	-- Unrecognized chat command, show simple help text
	local info = ChatTypeInfo["SYSTEM"];
	editBox.chatFrame:AddMessage(TEXT(HELP_TEXT_SIMPLE), info.r, info.g, info.b, info.id);
	ChatEdit_OnEscapePressed(editBox);
	return;
end

function ChatEdit_ExtractTellTarget(editBox, msg)
	-- Grab the first "word" in the string
	local target = gsub(msg, "(%s*)([^%s]+)(.*)", "%2", 1);
	if ( strlen(target) <= 0 ) then
		return;
	end

	msg = strsub(msg, strlen(target) + 2);

	editBox.tellTarget = target;
	editBox.chatType = "WHISPER";
	editBox:SetText(msg);
	ChatEdit_UpdateHeader(editBox);
end

function ChatEdit_ExtractChannel(editBox, msg)
	local target = gsub(msg, "(%s*)([^%s]+)(.*)", "%2", 1);
	if ( strlen(target) <= 0 ) then
		return;
	end
	
	local channelNum, channelName = GetChannelName(target);
	if ( channelNum <= 0 ) then
		return;
	end

	msg = strsub(msg, strlen(target) + 2);

	editBox.channelTarget = channelNum;
	editBox.chatType = "CHANNEL";
	editBox:SetText(msg);
	ChatEdit_UpdateHeader(editBox);
end

-- Chat menu functions
function ChatMenu_SetChatType(chatFrame, type)
	if ( not chatFrame.editBox:IsVisible() ) then
		ChatFrame_OpenChat("", chatFrame);
	end
	chatFrame.editBox.chatType = type;
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

function EmoteSort(token1, token2)
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

function EmoteMenu_OnLoad()
	sort(EmoteList, EmoteSort);
	UIMenu_Initialize();
	this.parentMenu = "ChatMenu";
	for index, value in EmoteList do
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
		UIMenu_AddButton(label, nil, EmoteMenu_Click);
	end
end

function LanguageMenu_OnLoad()
	UIMenu_Initialize();
	this.parentMenu = "ChatMenu";
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("LANGUAGE_LIST_CHANGED");
end

function VoiceMacroMenu_Click()
	PlayVocalCategory(VoiceMacroList[this:GetID()]);
	ChatMenu:Hide();
end

function VoiceSort(token1, token2)
	return getglobal("VOICEMACRO_LABEL_"..token1.."1") < getglobal("VOICEMACRO_LABEL_"..token2.."1");
end

function VoiceMacroMenu_OnLoad()
	sort(VoiceMacroList, VoiceSort);
	UIMenu_Initialize();
	this.parentMenu = "ChatMenu";
	for index, value in VoiceMacroList do
		local token = TEXT(SLASH_VOICEMACRO1).." "..TEXT(getglobal("VOICEMACRO_LABEL_"..value.."1"));
		if ( token ) then
			UIMenu_AddButton(token, nil, VoiceMacroMenu_Click);
		end
	end
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

-- Included here so that it exists when the ChatMenu is initialized
function ShowMacroFrame()
	ShowUIPanel(MacroFrame);
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