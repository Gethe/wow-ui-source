
UNITPOPUP_TITLE_HEIGHT = 26;
UNITPOPUP_BUTTON_HEIGHT = 15;
UNITPOPUP_BORDER_HEIGHT = 8;
UNITPOPUP_BORDER_WIDTH = 19;

UNITPOPUP_NUMBUTTONS = 9;
UNITPOPUP_TIMEOUT = 5;

UNITPOPUP_SPACER_SPACING = 6;

local function makeUnitPopupSubsectionTitle(titleText)
	return { text = titleText, dist = 0, isTitle = true, isUninteractable = true, isSubsectionTitle = true, };
end

UnitPopupButtons = {
	["CANCEL"] = { text = CANCEL, dist = 0, space = 1 },
	["TRADE"] = { text = TRADE, dist = 2 },
	["INSPECT"] = { text = INSPECT, dist = 0, disabledInKioskMode = true },
	["ACHIEVEMENTS"] = { text = COMPARE_ACHIEVEMENTS, dist = 1, disabledInKioskMode = true },
	["TARGET"] = { text = TARGET, dist = 0 },
	["IGNORE"]	= {
		dist = 0,
		text = function(dropdownMenu)
			return IsIgnored(dropdownMenu.name) and IGNORE_REMOVE or IGNORE;
		end,
	},
	["POP_OUT_CHAT"] = { text = MOVE_TO_WHISPER_WINDOW, dist = 0 },
	["DUEL"] = { text = DUEL, dist = 3, space = 1, disabledInKioskMode = true },
	["PET_BATTLE_PVP_DUEL"] = { text = PET_BATTLE_PVP_DUEL, dist = 5, space = 1, disabledInKioskMode = true },
	["WHISPER"]	= { text = WHISPER, dist = 0 },
	["INVITE"]	= { text = PARTY_INVITE, dist = 0 },
	["UNINVITE"] = { text = PARTY_UNINVITE, dist = 0 },
	["REMOVE_FRIEND"]	= { text = REMOVE_FRIEND, dist = 0 },
	["SET_NOTE"]	= { text = SET_NOTE, dist = 0 },
	["BN_REMOVE_FRIEND"]	= { text = REMOVE_FRIEND, dist = 0 },
	["BN_SET_NOTE"]	= { text = SET_NOTE, dist = 0 },
	["BN_VIEW_FRIENDS"]	= { text = VIEW_FRIENDS_OF_FRIENDS, dist = 0 },
	["BN_INVITE"] = { text = PARTY_INVITE, dist = 0 },
	["BN_TARGET"] = { text = TARGET, dist = 0 },
	["BLOCK_COMMUNICATION"] = { text = BLOCK_COMMUNICATION, dist = 0 },
	["VOTE_TO_KICK"] = { text = VOTE_TO_KICK, dist = 0 },
	["PROMOTE"] = { text = PARTY_PROMOTE, dist = 0 },
	["PROMOTE_GUIDE"] = { text = PARTY_PROMOTE_GUIDE, dist = 0 },
	["GUILD_PROMOTE"] = { text = GUILD_PROMOTE, dist = 0 },
	["GUILD_LEAVE"] = { text = GUILD_LEAVE, dist = 0 },
	["LEAVE"] = { text = PARTY_LEAVE, dist = 0 },
	["INSTANCE_LEAVE"] = { text = INSTANCE_PARTY_LEAVE, dist = 0 },
	["FOLLOW"] = { text = FOLLOW, dist = 4 },
	["PET_DISMISS"] = { text = PET_DISMISS, dist = 0 },
	["PET_ABANDON"] = { text = PET_ABANDON, dist = 0 },
	["PET_RENAME"] = { text = PET_RENAME, dist = 0 },
	["PET_SHOW_IN_JOURNAL"] = { text = PET_SHOW_IN_JOURNAL, dist = 0 },
	["LOOT_METHOD"] = { text = LOOT_METHOD, dist = 0, nested = 1},
	["FREE_FOR_ALL"] = { text = LOOT_FREE_FOR_ALL, dist = 0 },
	["MASTER_LOOTER"] = { text = LOOT_MASTER_LOOTER, dist = 0 },
	["GROUP_LOOT"] = { text = LOOT_GROUP_LOOT, dist = 0 },
	["PERSONAL_LOOT"] = { text = LOOT_PERSONAL_LOOT, dist = 0 },
	["RESET_INSTANCES"] = { text = RESET_INSTANCES, dist = 0 },
	["RESET_CHALLENGE_MODE"] = { text = RESET_CHALLENGE_MODE, dist = 0 },
	["CONVERT_TO_RAID"] = { text = CONVERT_TO_RAID, dist = 0 },
	["CONVERT_TO_PARTY"] = { text = CONVERT_TO_PARTY, dist = 0 },
	
	["SUBSECTION_SEPARATOR"] = { dist = 0, isTitle = true, isUninteractable = true, iconOnly = true, icon = "Interface\\Common\\UI-TooltipDivider-Transparent", tCoordLeft = 0, tCoordRight = 1, tCoordTop = 0, tCoordBottom = 1, tSizeX = 0, tFitDropDownSizeX = true, tSizeY = 8, },
	
	["LOOT_SUBSECTION_TITLE"] = makeUnitPopupSubsectionTitle(UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_LOOT),
	["INSTANCE_SUBSECTION_TITLE"] = makeUnitPopupSubsectionTitle(UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_INSTANCE),
	["OTHER_SUBSECTION_TITLE"] = makeUnitPopupSubsectionTitle(UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_OTHER),
	["INTERACT_SUBSECTION_TITLE"] = makeUnitPopupSubsectionTitle(UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_INTERACT),
	["LEGACY_RAID_SUBSECTION_TITLE"] = makeUnitPopupSubsectionTitle(UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_LEGACY_RAID),
	
	["REPORT_PLAYER"] = { text = REPORT_PLAYER_FOR, dist = 0, nested = 1 },
	["REPORT_SPAM"]	= { text = REPORT_SPAMMING, dist = 0 },
	["REPORT_BAD_LANGUAGE"] = { text = REPORT_BAD_LANGUAGE, dist = 0},
	["REPORT_BAD_NAME"] = { text = REPORT_BAD_NAME, dist = 0 },
	["REPORT_CHEATING"] = { text = REPORT_CHEATING, dist = 0 },
	["REPORT_BATTLE_PET"] = { text = REPORT_PET_NAME, dist = 0 },
	["REPORT_PET"] = { text = REPORT_PET_NAME, dist = 0 },

	["DUNGEON_DIFFICULTY"] = { text = DUNGEON_DIFFICULTY, dist = 0,  nested = 1, defaultDifficultyID = 1 },
	["DUNGEON_DIFFICULTY1"] = { text = PLAYER_DIFFICULTY1, dist = 0, checkable = 1, difficultyID = 1 },
	["DUNGEON_DIFFICULTY2"] = { text = PLAYER_DIFFICULTY2, dist = 0, checkable = 1, difficultyID = 2 },
	["DUNGEON_DIFFICULTY3"] = { text = PLAYER_DIFFICULTY6, dist = 0, checkable = 1, difficultyID = 23 },

	["RAID_DIFFICULTY"] = { text = RAID_DIFFICULTY, dist = 0,  nested = 1, defaultDifficultyID = 14 },
	["RAID_DIFFICULTY1"] = { text = PLAYER_DIFFICULTY1, dist = 0, checkable = 1, difficultyID = 14 },
	["RAID_DIFFICULTY2"] = { text = PLAYER_DIFFICULTY2, dist = 0, checkable = 1, difficultyID = 15 },
	["RAID_DIFFICULTY3"] = { text = PLAYER_DIFFICULTY6, dist = 0, checkable = 1, difficultyID = 16 },
	
	["LEGACY_RAID_DIFFICULTY1"] = { text = RAID_DIFFICULTY1, dist = 0, checkable = 1, difficultyID = 3 },
	["LEGACY_RAID_DIFFICULTY2"] = { text = RAID_DIFFICULTY2, dist = 0, checkable = 1, difficultyID = 4 },
	
	["PVP_FLAG"] = { text = PVP_FLAG, dist = 0, nested = 1 },
	["PVP_ENABLE"] = { text = ENABLE, dist = 0, checkable = 1, checkable = 1 },
	["PVP_DISABLE"] = { text = DISABLE, dist = 0, checkable = 1, checkable = 1 },
	
	["LOOT_THRESHOLD"] = { text = LOOT_THRESHOLD, dist = 0, nested = 1 },
	["LOOT_PROMOTE"] = { text = LOOT_PROMOTE, dist = 0 },
	["ITEM_QUALITY2_DESC"] = { text = ITEM_QUALITY2_DESC, dist = 0, color = ITEM_QUALITY_COLORS[2], checkable = 1 },
	["ITEM_QUALITY3_DESC"] = { text = ITEM_QUALITY3_DESC, dist = 0, color = ITEM_QUALITY_COLORS[3], checkable = 1 },
	["ITEM_QUALITY4_DESC"] = { text = ITEM_QUALITY4_DESC, dist = 0, color = ITEM_QUALITY_COLORS[4], checkable = 1 },
	
	["SELECT_LOOT_SPECIALIZATION"] = { text = SELECT_LOOT_SPECIALIZATION, dist = 0, nested = 1, tooltipText = SELECT_LOOT_SPECIALIZATION_TOOLTIP },
	["LOOT_SPECIALIZATION_DEFAULT"] = { text = LOOT_SPECIALIZATION_DEFAULT, dist = 0, checkable = 1, specializationID = 0 },
	["LOOT_SPECIALIZATION_SPEC1"] = { text = "spec1", dist = 0, checkable = 1, specializationID = 0 },
	["LOOT_SPECIALIZATION_SPEC2"] = { text = "spec2", dist = 0, checkable = 1, specializationID = 0 },
	["LOOT_SPECIALIZATION_SPEC3"] = { text = "spec3", dist = 0, checkable = 1, specializationID = 0 },
	["LOOT_SPECIALIZATION_SPEC4"] = { text = "spec4", dist = 0, checkable = 1, specializationID = 0 },
	
	["OPT_OUT_LOOT_TITLE"] = { text = OPT_OUT_LOOT_TITLE, dist = 0, nested = 1, tooltipText = NEWBIE_TOOLTIP_UNIT_OPT_OUT_LOOT },
	["OPT_OUT_LOOT_ENABLE"] = { text = YES, dist = 0, checkable = 1 },
	["OPT_OUT_LOOT_DISABLE"] = { text = NO, dist = 0, checkable = 1 },
	
	["BN_REPORT"] = { text = BNET_REPORT, dist = 0, nested = 1 },
	["BN_REPORT_SPAM"] = { text = BNET_REPORT_SPAM, dist = 0 },
	["BN_REPORT_ABUSE"] = { text = BNET_REPORT_ABUSE, dist = 0 },
	["BN_REPORT_THREAT"] = { text = BNET_REPORT_THREAT, dist = 0 },
	["BN_REPORT_NAME"] = { text = BNET_REPORT_NAME, dist = 0 },
	
	["RAID_LEADER"] = { text = SET_RAID_LEADER, dist = 0 },
	["RAID_PROMOTE"] = { text = SET_RAID_ASSISTANT, dist = 0 },
	["RAID_MAINTANK"] = { text = SET_MAIN_TANK, dist = 0 },
	["RAID_MAINASSIST"] = { text = SET_MAIN_ASSIST, dist = 0 },
	["RAID_DEMOTE"] = { text = DEMOTE, dist = 0 },
	["RAID_REMOVE"] = { text = REMOVE, dist = 0 },
	
	["PVP_REPORT_AFK"] = { text = PVP_REPORT_AFK, dist = 0 },
	
	["RAF_SUMMON"] = { text = RAF_SUMMON, dist = 0 },
	["RAF_GRANT_LEVEL"] = { text = RAF_GRANT_LEVEL, dist = 0 },
	
	["VEHICLE_LEAVE"] = { text = VEHICLE_LEAVE, dist = 0 },
	
	["SET_FOCUS"] = { text = SET_FOCUS, dist = 0 },
	["CLEAR_FOCUS"] = { text = CLEAR_FOCUS, dist = 0 },
	["LARGE_FOCUS"] = { text = FULL_SIZE_FOCUS_FRAME_TEXT, dist = 0, checkable = 1, isNotRadio = 1 },
	["LOCK_FOCUS_FRAME"] = { text = LOCK_FOCUS_FRAME, dist = 0 },
	["UNLOCK_FOCUS_FRAME"] = { text = UNLOCK_FOCUS_FRAME, dist = 0 },
	["MOVE_FOCUS_FRAME"] = { text = MOVE_FRAME, dist = 0, nested = 1 },
	["FOCUS_FRAME_BUFFS_ON_TOP"] = { text = BUFFS_ON_TOP, dist = 0, checkable = 1, isNotRadio = 1 },
	
	["MOVE_PLAYER_FRAME"] = { text = MOVE_FRAME, dist = 0, nested = 1 },
	["LOCK_PLAYER_FRAME"] = { text = LOCK_FRAME, dist = 0 },
	["UNLOCK_PLAYER_FRAME"] = { text = UNLOCK_FRAME, dist = 0 },
	["RESET_PLAYER_FRAME_POSITION"] = { text = RESET_POSITION, dist = 0 },
	["PLAYER_FRAME_SHOW_CASTBARS"] = { text = PLAYER_FRAME_SHOW_CASTBARS, dist = 0, checkable = 1, isNotRadio = 1 },
	
	["MOVE_TARGET_FRAME"] = { text = MOVE_FRAME, dist = 0, nested = 1 },
	["LOCK_TARGET_FRAME"] = { text = LOCK_FRAME, dist = 0 },
	["UNLOCK_TARGET_FRAME"] = { text = UNLOCK_FRAME, dist = 0 },
	["TARGET_FRAME_BUFFS_ON_TOP"] = { text = BUFFS_ON_TOP, dist = 0, checkable = 1, isNotRadio = 1 },
	["RESET_TARGET_FRAME_POSITION"] = { text = RESET_POSITION, dist = 0 },

	-- Add Friend related
	["ADD_FRIEND"] = { text = ADD_FRIEND, dist = 0, disabledInKioskMode = true },
	["ADD_FRIEND_MENU"] = { text = ADD_FRIEND, dist = 0, nested = 1, disabledInKioskMode = true },
	["CHARACTER_FRIEND"] = { text = ADD_CHARACTER_FRIEND, dist = 0, disabledInKioskMode = true },
	["BATTLETAG_FRIEND"] = { text = SEND_BATTLETAG_REQUEST, dist = 0, disabledInKioskMode = true },
	["GUILD_BATTLETAG_FRIEND"] = { text = SEND_BATTLETAG_REQUEST, dist = 0, disabledInKioskMode = true },

	-- Voice Chat Related
	["MUTE"] = { text = MUTE, dist = 0 },
	["UNMUTE"] = { text = UNMUTE, dist = 0 },

	["RAID_TARGET_ICON"] = { text = RAID_TARGET_ICON, dist = 0, nested = 1 },
	["RAID_TARGET_1"] = { text = RAID_TARGET_1, dist = 0, checkable = 1, color = {r = 1.0, g = 0.92, b = 0}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0, tCoordRight = 0.25, tCoordTop = 0, tCoordBottom = 0.25 },
	["RAID_TARGET_2"] = { text = RAID_TARGET_2, dist = 0, checkable = 1, color = {r = 0.98, g = 0.57, b = 0}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0.25, tCoordRight = 0.5, tCoordTop = 0, tCoordBottom = 0.25 },
	["RAID_TARGET_3"] = { text = RAID_TARGET_3, dist = 0, checkable = 1, color = {r = 0.83, g = 0.22, b = 0.9}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0.5, tCoordRight = 0.75, tCoordTop = 0, tCoordBottom = 0.25 },
	["RAID_TARGET_4"] = { text = RAID_TARGET_4, dist = 0, checkable = 1, color = {r = 0.04, g = 0.95, b = 0}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0.75, tCoordRight = 1, tCoordTop = 0, tCoordBottom = 0.25 },
	["RAID_TARGET_5"] = { text = RAID_TARGET_5, dist = 0, checkable = 1, color = {r = 0.7, g = 0.82, b = 0.875}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0, tCoordRight = 0.25, tCoordTop = 0.25, tCoordBottom = 0.5 },
	["RAID_TARGET_6"] = { text = RAID_TARGET_6, dist = 0, checkable = 1, color = {r = 0, g = 0.71, b = 1}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0.25, tCoordRight = 0.5, tCoordTop = 0.25, tCoordBottom = 0.5 },
	["RAID_TARGET_7"] = { text = RAID_TARGET_7, dist = 0, checkable = 1, color = {r = 1.0, g = 0.24, b = 0.168}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0.5, tCoordRight = 0.75, tCoordTop = 0.25, tCoordBottom = 0.5 },
	["RAID_TARGET_8"] = { text = RAID_TARGET_8, dist = 0, checkable = 1, color = {r = 0.98, g = 0.98, b = 0.98}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0.75, tCoordRight = 1, tCoordTop = 0.25, tCoordBottom = 0.5 },
	["RAID_TARGET_NONE"] = { text = RAID_TARGET_NONE, dist = 0, checkable = 1 },

	--Role icons
	["SELECT_ROLE"] = { text = SET_ROLE, dist = 0, nested = 1 },
	["SET_ROLE_NONE"] = { text = NO_ROLE, dist = 0, checkable = 1 },
	["SET_ROLE_TANK"] = { text = INLINE_TANK_ICON.." "..TANK, dist = 0, checkable = 1 },
	["SET_ROLE_HEALER"] = { text = INLINE_HEALER_ICON.." "..HEALER, dist = 0, checkable = 1 },
	["SET_ROLE_DAMAGER"] = { text = INLINE_DAMAGER_ICON.." "..DAMAGER, dist = 0, checkable = 1 },

	-- Chat Channel Player Commands
	["CHAT_PROMOTE"] = { text = MAKE_MODERATOR, dist = 0 },
	["CHAT_DEMOTE"] = { text = REMOVE_MODERATOR, dist = 0 },
	["CHAT_OWNER"] = { text = CHAT_OWNER, dist = 0 },
	["CHAT_SILENCE"] = { text = CHAT_SILENCE, dist = 0 },
	["CHAT_UNSILENCE"] = { text = CHAT_UNSILENCE, dist = 0 },
	["PARTY_SILENCE"] = { text = PARTY_SILENCE, dist = 0 },
	["PARTY_UNSILENCE"] = { text = PARTY_UNSILENCE, dist = 0 },
	["RAID_SILENCE"] = { text = RAID_SILENCE, dist = 0 },
	["RAID_UNSILENCE"] = { text = RAID_UNSILENCE, dist = 0 },
	["BATTLEGROUND_SILENCE"] = { text = BATTLEGROUND_SILENCE, dist = 0 },
	["BATTLEGROUND_UNSILENCE"] = { text = BATTLEGROUND_UNSILENCE, dist = 0 },
	["CHAT_KICK"] = { text = CHAT_KICK, dist = 0 },
	["CHAT_BAN"] = { text = CHAT_BAN, dist = 0 },

	-- Garrison
	["GARRISON_VISIT"] = { text = GARRISON_VISIT_LEADER, dist = 0 },
};

-- First level menus
UnitPopupMenus = {
	["SELF"] = { "RAID_TARGET_ICON", "SET_FOCUS", "PVP_FLAG", "LOOT_SUBSECTION_TITLE", "LOOT_METHOD", "LOOT_THRESHOLD", "OPT_OUT_LOOT_TITLE", "LOOT_PROMOTE", "SELECT_LOOT_SPECIALIZATION", "INSTANCE_SUBSECTION_TITLE", "CONVERT_TO_RAID", "CONVERT_TO_PARTY", "DUNGEON_DIFFICULTY", "RAID_DIFFICULTY", "RESET_INSTANCES", "RESET_CHALLENGE_MODE", "GARRISON_VISIT", "OTHER_SUBSECTION_TITLE", "SELECT_ROLE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "INSTANCE_LEAVE", "LEAVE", "CANCEL" },
	["PET"] = { "RAID_TARGET_ICON", "SET_FOCUS", "INTERACT_SUBSECTION_TITLE", "PET_RENAME", "PET_DISMISS", "PET_ABANDON", "OTHER_SUBSECTION_TITLE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "CANCEL" },
	["OTHERPET"] = { "RAID_TARGET_ICON", "SET_FOCUS", "OTHER_SUBSECTION_TITLE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME",  "REPORT_PET", "CANCEL" },
	["BATTLEPET"] = { "PET_SHOW_IN_JOURNAL", "SET_FOCUS", "OTHER_SUBSECTION_TITLE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "CANCEL" },
	["OTHERBATTLEPET"] = { "PET_SHOW_IN_JOURNAL", "SET_FOCUS", "OTHER_SUBSECTION_TITLE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "REPORT_BATTLE_PET", "CANCEL" },
	["PARTY"] = { "RAID_TARGET_ICON", "SET_FOCUS", "ADD_FRIEND", "ADD_FRIEND_MENU", "INTERACT_SUBSECTION_TITLE", "RAF_SUMMON", "RAF_GRANT_LEVEL", "PROMOTE", "PROMOTE_GUIDE", "LOOT_PROMOTE", "WHISPER", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "PET_BATTLE_PVP_DUEL", "OTHER_SUBSECTION_TITLE", "SELECT_ROLE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "MUTE", "UNMUTE", "PARTY_SILENCE", "PARTY_UNSILENCE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "REPORT_PLAYER", "PVP_REPORT_AFK", "VOTE_TO_KICK", "UNINVITE", "CANCEL" },
	["PLAYER"] = { "RAID_TARGET_ICON", "SET_FOCUS", "ADD_FRIEND", "ADD_FRIEND_MENU", "INTERACT_SUBSECTION_TITLE", "RAF_SUMMON", "RAF_GRANT_LEVEL", "INVITE", "WHISPER", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "PET_BATTLE_PVP_DUEL", "OTHER_SUBSECTION_TITLE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "REPORT_PLAYER", "CANCEL" },	
	["RAID_PLAYER"] = { "RAID_TARGET_ICON", "SET_FOCUS", "ADD_FRIEND", "ADD_FRIEND_MENU", "INTERACT_SUBSECTION_TITLE", "RAF_SUMMON", "RAF_GRANT_LEVEL", "RAID_LEADER", "RAID_PROMOTE", "RAID_DEMOTE", "LOOT_PROMOTE", "WHISPER", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "PET_BATTLE_PVP_DUEL", "OTHER_SUBSECTION_TITLE", "SELECT_ROLE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "REPORT_PLAYER", "PVP_REPORT_AFK", "VOTE_TO_KICK", "RAID_REMOVE", "CANCEL" },
	["RAID"] = { "SET_FOCUS", "INTERACT_SUBSECTION_TITLE", "RAID_LEADER",  "RAID_PROMOTE", "RAID_DEMOTE", "RAID_MAINTANK", "RAID_MAINASSIST", "LOOT_PROMOTE", "OTHER_SUBSECTION_TITLE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "MUTE", "UNMUTE", "RAID_SILENCE", "RAID_UNSILENCE", "BATTLEGROUND_SILENCE", "BATTLEGROUND_UNSILENCE", "REPORT_PLAYER", "PVP_REPORT_AFK", "VOTE_TO_KICK", "RAID_REMOVE", "CANCEL" },
	["FRIEND"] = { "POP_OUT_CHAT", "TARGET", "SET_NOTE", "INTERACT_SUBSECTION_TITLE", "INVITE", "WHISPER", "OTHER_SUBSECTION_TITLE", "IGNORE", "REMOVE_FRIEND", "REPORT_PLAYER", "PVP_REPORT_AFK", "CANCEL" },
	["FRIEND_OFFLINE"] = { "SET_NOTE", "OTHER_SUBSECTION_TITLE", "IGNORE", "REMOVE_FRIEND", "CANCEL" },
	["BN_FRIEND"] = { "POP_OUT_CHAT", "BN_TARGET", "BN_SET_NOTE", "BN_VIEW_FRIENDS", "INTERACT_SUBSECTION_TITLE", "BN_INVITE", "WHISPER", "OTHER_SUBSECTION_TITLE", "BLOCK_COMMUNICATION", "BN_REMOVE_FRIEND", "BN_REPORT", "CANCEL" },
	["BN_FRIEND_OFFLINE"] = { "BN_SET_NOTE", "BN_VIEW_FRIENDS", "OTHER_SUBSECTION_TITLE", "BN_REMOVE_FRIEND", "BN_REPORT", "CANCEL" },
	["GUILD"] = { "TARGET", "GUILD_BATTLETAG_FRIEND", "INTERACT_SUBSECTION_TITLE", "INVITE", "WHISPER", "GUILD_PROMOTE", "OTHER_SUBSECTION_TITLE", "IGNORE", "GUILD_LEAVE", "CANCEL" },
	["GUILD_OFFLINE"] = { "GUILD_BATTLETAG_FRIEND", "INTERACT_SUBSECTION_TITLE", "GUILD_PROMOTE", "OTHER_SUBSECTION_TITLE", "IGNORE", "GUILD_LEAVE", "CANCEL" },
	["RAID_TARGET_ICON"] = { "RAID_TARGET_8", "RAID_TARGET_7", "RAID_TARGET_6", "RAID_TARGET_5", "RAID_TARGET_4", "RAID_TARGET_3", "RAID_TARGET_2", "RAID_TARGET_1", "RAID_TARGET_NONE" },
	["SELECT_ROLE"] = { "SET_ROLE_TANK", "SET_ROLE_HEALER", "SET_ROLE_DAMAGER", "SET_ROLE_NONE" },
	["CHAT_ROSTER"] = { "TARGET", "INTERACT_SUBSECTION_TITLE", "WHISPER", "CHAT_OWNER", "CHAT_PROMOTE", "OTHER_SUBSECTION_TITLE", "MUTE", "UNMUTE", "CHAT_SILENCE", "CHAT_UNSILENCE", "CHAT_DEMOTE", "CANCEL"  },
	["VEHICLE"] = { "RAID_TARGET_ICON", "SET_FOCUS", "OTHER_SUBSECTION_TITLE", "VEHICLE_LEAVE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "CANCEL" },
	["TARGET"] = { "RAID_TARGET_ICON", "SET_FOCUS", "ADD_FRIEND", "ADD_FRIEND_MENU", "OTHER_SUBSECTION_TITLE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "CANCEL" },
	["ARENAENEMY"] = { "SET_FOCUS", "OTHER_SUBSECTION_TITLE", "CANCEL" },
	["FOCUS"] = { "RAID_TARGET_ICON", "CLEAR_FOCUS", "OTHER_SUBSECTION_TITLE", "LARGE_FOCUS", "MOVE_FOCUS_FRAME", "CANCEL" },
	["BOSS"] = { "RAID_TARGET_ICON", "SET_FOCUS", "OTHER_SUBSECTION_TITLE", "CANCEL" },
	["WORLD_STATE_SCORE"] = { "REPORT_PLAYER", "PVP_REPORT_AFK", "CANCEL" },

	-- Second level menus
	["ADD_FRIEND_MENU"] = { "BATTLETAG_FRIEND", "CHARACTER_FRIEND" },
	["PVP_FLAG"] = { "PVP_ENABLE", "PVP_DISABLE"},
	["LOOT_METHOD"] = { "PERSONAL_LOOT", "GROUP_LOOT", "FREE_FOR_ALL", "MASTER_LOOTER", "CANCEL" },
	["LOOT_THRESHOLD"] = { "ITEM_QUALITY2_DESC", "ITEM_QUALITY3_DESC", "ITEM_QUALITY4_DESC", "CANCEL" },
	["SELECT_LOOT_SPECIALIZATION"] = { "LOOT_SPECIALIZATION_DEFAULT","LOOT_SPECIALIZATION_SPEC1", "LOOT_SPECIALIZATION_SPEC2", "LOOT_SPECIALIZATION_SPEC3", "LOOT_SPECIALIZATION_SPEC4"},
	["OPT_OUT_LOOT_TITLE"] = { "OPT_OUT_LOOT_ENABLE", "OPT_OUT_LOOT_DISABLE"},
	["REPORT_PLAYER"] = { "REPORT_SPAM", "REPORT_BAD_LANGUAGE", "REPORT_BAD_NAME", "REPORT_CHEATING" },
	["DUNGEON_DIFFICULTY"] = { "DUNGEON_DIFFICULTY1", "DUNGEON_DIFFICULTY2", "DUNGEON_DIFFICULTY3" },
	["RAID_DIFFICULTY"] = { "RAID_DIFFICULTY1", "RAID_DIFFICULTY2", "RAID_DIFFICULTY3", "LEGACY_RAID_SUBSECTION_TITLE", "LEGACY_RAID_DIFFICULTY1", "LEGACY_RAID_DIFFICULTY2" },
	["BN_REPORT"] = { "BN_REPORT_SPAM", "BN_REPORT_ABUSE", "BN_REPORT_NAME" },
	["MOVE_PLAYER_FRAME"] = { "UNLOCK_PLAYER_FRAME", "LOCK_PLAYER_FRAME", "RESET_PLAYER_FRAME_POSITION", "PLAYER_FRAME_SHOW_CASTBARS" },
	["MOVE_TARGET_FRAME"] = { "UNLOCK_TARGET_FRAME", "LOCK_TARGET_FRAME", "RESET_TARGET_FRAME_POSITION" , "TARGET_FRAME_BUFFS_ON_TOP"},
	["MOVE_FOCUS_FRAME"] = { "UNLOCK_FOCUS_FRAME", "LOCK_FOCUS_FRAME", "FOCUS_FRAME_BUFFS_ON_TOP"},
};

UnitPopupShown = { {}, {}, {}, };

UnitLootMethod = {
    ["personalloot"] = { text = LOOT_PERSONAL_LOOT, tooltipText = NEWBIE_TOOLTIP_UNIT_PERSONAL },
    ["group"] = { text = LOOT_GROUP_LOOT, tooltipText = NEWBIE_TOOLTIP_UNIT_GROUP_LOOT },
	["freeforall"] = { text = LOOT_FREE_FOR_ALL, tooltipText = NEWBIE_TOOLTIP_UNIT_FREE_FOR_ALL },
	["master"] = { text = LOOT_MASTER_LOOTER, tooltipText = NEWBIE_TOOLTIP_UNIT_MASTER_LOOTER },
};

UnitPopupFrames = {
	"PlayerFrameDropDown",
	"TargetFrameDropDown",
	"FocusFrameDropDown",
	"PartyMemberFrame1DropDown",
	"PartyMemberFrame2DropDown",
	"PartyMemberFrame3DropDown",
	"PartyMemberFrame4DropDown",
	"FriendsDropDown",
	"PetBattleUnitFrameDropDown",
	"GuildMemberDropDown",
	"WorldStateButtonDropDown",
};

function UnitPopup_ShowMenu (dropdownMenu, which, unit, name, userData)
	local server = nil;
	-- Init variables
	dropdownMenu.which = which;
	dropdownMenu.unit = unit;
	if ( unit ) then
		name, server = UnitName(unit);
	elseif ( name ) then
		local n, s = strmatch(name, "^([^-]+)-(.*)");
		if ( n ) then
			name = n;
			server = s;
		end
	end
	dropdownMenu.name = name;
	dropdownMenu.userData = userData;
	dropdownMenu.server = server;

	-- Determine which buttons should be shown or hidden
	UnitPopup_HideButtons();
	
	-- If only one menu item (the cancel button) then don't show the menu
	local count = 0;
	for index, value in ipairs(UnitPopupMenus[UIDROPDOWNMENU_MENU_VALUE] or UnitPopupMenus[which]) do
		if( UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] == 1 and value ~= "CANCEL" ) then
			count = count + 1;
		end
	end
	if ( count < 1 ) then
		return;
	end
	
	-- Determine which loot method and which loot threshold are selected and set the corresponding buttons to the same text
	dropdownMenu.selectedLootMethod = UnitLootMethod[GetLootMethod()].text;
	UnitPopupButtons["LOOT_METHOD"].text = dropdownMenu.selectedLootMethod;
	UnitPopupButtons["LOOT_METHOD"].tooltipText = UnitLootMethod[GetLootMethod()].tooltipText;
	dropdownMenu.selectedLootThreshold = _G["ITEM_QUALITY"..GetLootThreshold().."_DESC"];
	UnitPopupButtons["LOOT_THRESHOLD"].text = dropdownMenu.selectedLootThreshold;
	
	UnitPopupButtons["GARRISON_VISIT"].text = (C_Garrison.IsUsingPartyGarrison() and GARRISON_RETURN) or GARRISON_VISIT_LEADER;
	-- This allows player to view loot settings if he's not the leader
	local inParty = IsInGroup();
	local inPublicParty = IsInGroup(LE_PARTY_CATEGORY_INSTANCE);
	local isLeader = UnitIsGroupLeader("player");
		
	if ( inParty and isLeader and not HasLFGRestrictions() ) then
		-- If this is true then player is the party leader
		UnitPopupButtons["LOOT_METHOD"].nested = 1;
		UnitPopupButtons["LOOT_THRESHOLD"].nested = 1;
	else
		UnitPopupButtons["LOOT_METHOD"].nested = nil;
		UnitPopupButtons["LOOT_THRESHOLD"].nested = nil;
	end
	-- Set the selected opt out of loot option to the opt out of loot button text
	if ( GetOptOutOfLoot() ) then
		UnitPopupButtons["OPT_OUT_LOOT_TITLE"].text = format(OPT_OUT_LOOT_TITLE, UnitPopupButtons["OPT_OUT_LOOT_ENABLE"].text);
	else
		UnitPopupButtons["OPT_OUT_LOOT_TITLE"].text = format(OPT_OUT_LOOT_TITLE, UnitPopupButtons["OPT_OUT_LOOT_DISABLE"].text);
	end
	-- Disable dungeon and raid difficulty in instances except for for leaders in dynamic instances
	local toggleDifficultyID;
	local _, instanceType, instanceDifficultyID, _, _, _, isDynamicInstance = GetInstanceInfo();
	if ( isDynamicInstance and CanChangePlayerDifficulty() ) then
		_, _, _, _, _, _, toggleDifficultyID = GetDifficultyInfo(instanceDifficultyID);
	end	

	local inInstance, instanceType = IsInInstance();
	if ( not inInstance ) then
		UnitPopupButtons["DUNGEON_DIFFICULTY"].nested = 1;
		if( inPublicParty ) then
			UnitPopupButtons["RAID_DIFFICULTY"].nested = nil;
		else
			UnitPopupButtons["RAID_DIFFICULTY"].nested = 1;	
		end
	else
		if (instanceType == "raid") then
			UnitPopupButtons["RAID_DIFFICULTY"].nested = 1;
			UnitPopupButtons["DUNGEON_DIFFICULTY"].nested = nil;
		else
			UnitPopupButtons["DUNGEON_DIFFICULTY"].nested = 1;
			UnitPopupButtons["RAID_DIFFICULTY"].nested = nil;
		end
	end
	
	-- setup default Loot Specialization
	local specPopupButton = UnitPopupButtons["LOOT_SPECIALIZATION_DEFAULT"];
	local specIndex = GetSpecialization();
	local sex = UnitSex("player");
	if ( specIndex) then
		local specID, specName = GetSpecializationInfo(specIndex, nil, nil, nil, sex);
		if ( specName ) then
			specPopupButton.text = format(LOOT_SPECIALIZATION_DEFAULT, specName);
		end
	end
	-- setup specialization coices for Loot Specialization
	for index = 1, 4 do
		specPopupButton = UnitPopupButtons["LOOT_SPECIALIZATION_SPEC"..index];
		if ( specPopupButton ) then
			local id, name = GetSpecializationInfo(index, nil, nil, nil, sex);
			if ( id ) then
				specPopupButton.specializationID = id;
				specPopupButton.text = name;
			else
				specPopupButton.specializationID = -1;
			end
		end
	end
		
	--Add the cooldown to the RAF Summon
	do
		local start, duration = GetSummonFriendCooldown();
		local remaining = start + duration - GetTime();
		if ( remaining > 0 ) then
			UnitPopupButtons["RAF_SUMMON"].text = format(RAF_SUMMON_WITH_COOLDOWN, SecondsToTime(remaining, true));
		else
			UnitPopupButtons["RAF_SUMMON"].text = RAF_SUMMON;
		end
	end
	
	-- If level 2 dropdown
	local info;
	local color;
	local icon;
	if ( UIDROPDOWNMENU_MENU_LEVEL == 2 ) then
		dropdownMenu.which = UIDROPDOWNMENU_MENU_VALUE;
		-- Set which menu is being opened
		OPEN_DROPDOWNMENUS[UIDROPDOWNMENU_MENU_LEVEL] = {which = dropdownMenu.which, unit = dropdownMenu.unit};
		info = UIDropDownMenu_CreateInfo();
		local subsectionTitleValue = nil;
		local subsectionTitleIndex = nil;
		local previousWasSubsectionTitle = false;
		for index, value in ipairs(UnitPopupMenus[UIDROPDOWNMENU_MENU_VALUE]) do
			if( UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] == 1 ) then
				info.text = UnitPopupButtons[value].text;
				info.owner = UIDROPDOWNMENU_MENU_VALUE;
				-- Set the text color
				color = UnitPopupButtons[value].color;
				if ( color ) then
					info.colorCode = string.format("|cFF%02x%02x%02x", color.r*255, color.g*255, color.b*255);
				else
					info.colorCode = nil;
				end
				-- Icons
				info.icon = UnitPopupButtons[value].icon;
				info.tCoordLeft = UnitPopupButtons[value].tCoordLeft;
				info.tCoordRight = UnitPopupButtons[value].tCoordRight;
				info.tCoordTop = UnitPopupButtons[value].tCoordTop;
				info.tCoordBottom = UnitPopupButtons[value].tCoordBottom;
				-- Checked conditions
				info.checked = nil;
				if ( info.text == dropdownMenu.selectedLootMethod  ) then
					info.checked = true;
				elseif ( info.text == dropdownMenu.selectedLootThreshold ) then
					info.checked = true;
				elseif ( strsub(value, 1, 12) == "RAID_TARGET_" ) then
					local buttonRaidTargetIndex = strsub(value, 13);
					if ( buttonRaidTargetIndex == "NONE" ) then
						buttonRaidTargetIndex = 0;
					else
						buttonRaidTargetIndex = tonumber(buttonRaidTargetIndex);
					end
					
					local activeRaidTargetIndex = GetRaidTargetIndex(unit);
					if ( activeRaidTargetIndex == buttonRaidTargetIndex ) then
						info.checked = true;
					end
				elseif ( strsub(value, 1, 18) == "DUNGEON_DIFFICULTY" and (strlen(value) > 18)) then
					local dungeonDifficultyID = GetDungeonDifficultyID();
					if ( dungeonDifficultyID == UnitPopupButtons[value].difficultyID ) then
						info.checked = true;
					end
					if ( ( inParty and not isLeader ) or inInstance ) then
						info.disabled = true;	
					end
				elseif (strsub(value, 1, 15) == "RAID_DIFFICULTY" and (strlen(value) > 15) ) then
					if ( isDynamicInstance ) then
						-- Yay, legacy hacks!
						if ( IsLegacyDifficulty(instanceDifficultyID) ) then
							-- 3 and 4 are normal, 5 and 6 are heroic
							if ((instanceDifficultyID == DIFFICULTY_RAID10_NORMAL or instanceDifficultyID == DIFFICULTY_RAID25_NORMAL) and UnitPopupButtons[value].difficultyID == DIFFICULTY_PRIMARYRAID_NORMAL) then
								info.checked = true;
							elseif ((instanceDifficultyID == DIFFICULTY_RAID10_HEROIC or instanceDifficultyID == DIFFICULTY_RAID25_HEROIC) and UnitPopupButtons[value].difficultyID == DIFFICULTY_PRIMARYRAID_HEROIC) then
								info.checked = true;
							end
						elseif ( instanceDifficultyID == UnitPopupButtons[value].difficultyID ) then
							info.checked = true;
						end
					else
						local raidDifficultyID = GetRaidDifficultyID();
						if ( raidDifficultyID == UnitPopupButtons[value].difficultyID ) then
							info.checked = true;
						end
					end
				
					if ( ( inParty and not isLeader ) or inPublicParty or inInstance ) then
						info.disabled = true;
					end
					if ( toggleDifficultyID and CheckToggleDifficulty(toggleDifficultyID, UnitPopupButtons[value].difficultyID) ) then
						info.disabled = nil;
					end
				elseif (strsub(value, 1, 22) == "LEGACY_RAID_DIFFICULTY" and (strlen(value) > 15) ) then
					if ( isDynamicInstance ) then
						if ( NormalizeLegacyDifficultyID(instanceDifficultyID) == UnitPopupButtons[value].difficultyID ) then
							info.checked = true;
						end
					else
						local raidDifficultyID = GetLegacyRaidDifficultyID();
						if ( NormalizeLegacyDifficultyID(raidDifficultyID) == UnitPopupButtons[value].difficultyID ) then
							info.checked = true;
						end
					end
					if ( ( inParty and not isLeader ) or inPublicParty or inInstance or GetRaidDifficultyID() == DIFFICULTY_PRIMARYRAID_MYTHIC ) then
						info.disabled = true;
					end
					if ( toggleDifficultyID and not GetRaidDifficultyID() == DIFFICULTY_PRIMARYRAID_MYTHIC and CheckToggleDifficulty(toggleDifficultyID, UnitPopupButtons[value].difficultyID) ) then
						info.disabled = nil;
					end
				elseif ( value == "PVP_ENABLE" ) then
					if ( GetPVPDesired()) then
						info.checked = true;
					end
				elseif ( value == "PVP_DISABLE" ) then
					if ( not GetPVPDesired() ) then
						info.checked = true;
					end
				elseif ( strsub(value, 1, 20) == "LOOT_SPECIALIZATION_" ) then
					if ( GetLootSpecialization() == UnitPopupButtons[value].specializationID ) then
						info.checked = true;
					end
				elseif ( value == "OPT_OUT_LOOT_ENABLE" ) then
					if ( GetOptOutOfLoot() ) then
						info.checked = true;
					end
				elseif ( value == "OPT_OUT_LOOT_DISABLE" ) then
					if ( not GetOptOutOfLoot() ) then
						info.checked = true;
					end
				elseif ( value == "TARGET_FRAME_BUFFS_ON_TOP" ) then
					if ( TARGET_FRAME_BUFFS_ON_TOP ) then
						info.checked = true;
					end
				elseif ( value == "FOCUS_FRAME_BUFFS_ON_TOP" ) then
					if ( FOCUS_FRAME_BUFFS_ON_TOP ) then
						info.checked = true;
					end
				elseif ( value == "PLAYER_FRAME_SHOW_CASTBARS" ) then
					if ( PLAYER_FRAME_CASTBARS_SHOWN ) then
						info.checked = true;
					end
				elseif ( strsub(value, 1, 9) == "SET_ROLE_" ) then
					if ( UnitGroupRolesAssigned(unit) == strsub(value, 10) ) then
						info.checked = true;
					end
				end
				
				info.value = value;
				info.func = UnitPopup_OnClick;
				if ( not UnitPopupButtons[value].checkable ) then
					info.notCheckable = true;
				else
					info.notCheckable = nil;
				end
				if ( UnitPopupButtons[value].isNotRadio ) then
					info.isNotRadio = true;
				else
					info.isNotRadio = nil;
				end
				-- Setup newbie tooltips
				info.tooltipTitle = UnitPopupButtons[value].text;
				info.tooltipText = _G["NEWBIE_TOOLTIP_UNIT_"..value];
				
				local cntButton = UnitPopupButtons[value];
						
				if ( previousWasSubsectionTitle ) then 
					if ( not cntButton.isSubsectionTitle ) then
						UnitPopup_AddDropDownButton(info, dropdownMenu, UnitPopupButtons["SUBSECTION_SEPARATOR"], "SUBSECTION_SEPARATOR", UIDROPDOWNMENU_MENU_LEVEL);
						UnitPopup_AddDropDownButton(info, dropdownMenu, UnitPopupButtons[subsectionTitleValue], subsectionTitleValue, UIDROPDOWNMENU_MENU_LEVEL);
					else
						UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][subsectionTitleIndex] = 0;
					end
					subsectionTitleIndex = nil;
					subsectionTitleValue = nil;
				end
				
				previousWasSubsectionTitle = false;
				
				if ( cntButton.isSubsectionTitle ) then
					subsectionTitleValue = value;
					subsectionTitleIndex = index;
					previousWasSubsectionTitle = true;
				else
					UnitPopup_AddDropDownButton(info, dropdownMenu, cntButton, value, UIDROPDOWNMENU_MENU_LEVEL);
				end
			end
		end
		return;			
	end

	-- Add dropdown title
	if ( unit or name ) then
		info = UIDropDownMenu_CreateInfo();
		if ( name ) then
			info.text = name;
		else
			info.text = UNKNOWN;
		end
		info.isTitle = true;
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info);
	end
	
	-- Set which menu is being opened
	OPEN_DROPDOWNMENUS[UIDROPDOWNMENU_MENU_LEVEL] = {which = dropdownMenu.which, unit = dropdownMenu.unit};
	-- Show the buttons which are used by this menu
	local tooltipText;
	info = UIDropDownMenu_CreateInfo();
	local subsectionTitleValue = nil;
	local subsectionTitleIndex = nil;
	local previousWasSubsectionTitle = false;
	for index, value in ipairs(UnitPopupMenus[which]) do
		if( UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] == 1 ) then
			local cntButton = UnitPopupButtons[value];
			
			if ( previousWasSubsectionTitle ) then 
				if ( not cntButton.isSubsectionTitle ) then
					UnitPopup_AddDropDownButton(info, dropdownMenu, UnitPopupButtons["SUBSECTION_SEPARATOR"], "SUBSECTION_SEPARATOR");
					UnitPopup_AddDropDownButton(info, dropdownMenu, UnitPopupButtons[subsectionTitleValue], subsectionTitleValue);
				else
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][subsectionTitleIndex] = 0;
				end
				subsectionTitleIndex = nil;
				subsectionTitleValue = nil;
			end
			
			previousWasSubsectionTitle = false;
			
			if ( cntButton.isSubsectionTitle ) then
				subsectionTitleValue = value;
				subsectionTitleIndex = index;
				previousWasSubsectionTitle = true;
			else
				UnitPopup_AddDropDownButton(info, dropdownMenu, cntButton, value);
			end
		end
	end
	PlaySound("igMainMenuOpen");
end

local function GetDropDownButtonText(button, dropdownMenu)
	if (type(button.text) == "function") then
		return button.text(dropdownMenu);
	end
	
	return button.text;
end

function UnitPopup_AddDropDownButton (info, dropdownMenu, cntButton, buttonIndex, level)
	if (not level) then
		level = 1;
	end

	info.text = GetDropDownButtonText(cntButton, dropdownMenu);
	info.value = buttonIndex;
	info.owner = nil;
	info.func = UnitPopup_OnClick;
	if ( not cntButton.checkable ) then
		info.notCheckable = true;
	else
		info.notCheckable = nil;
	end
	-- Text color
	if ( buttonIndex == "LOOT_THRESHOLD" ) then
		-- Set the text color
		info.colorCode = ITEM_QUALITY_COLORS[GetLootThreshold()].hex;
	else
		local color = cntButton.color;
		if ( color ) then
			info.colorCode = string.format("|cFF%02x%02x%02x",  color.r*255,  color.g*255,  color.b*255);
		else
			info.colorCode = nil;
		end
	end
		-- Icons
	if ( cntButton.iconOnly ) then
		info.iconOnly = 1;
		info.icon = cntButton.icon;
		info.iconInfo = { tCoordLeft = cntButton.tCoordLeft, 
							tCoordRight = cntButton.tCoordRight,
							tCoordTop = cntButton.tCoordTop,
							tCoordBottom = cntButton.tCoordBottom,
							tSizeX = cntButton.tSizeX,
							tSizeY = cntButton.tSizeY,
							tFitDropDownSizeX = cntButton.tFitDropDownSizeX };
	else
		info.iconOnly = nil;
		info.icon = cntButton.icon;
		info.tCoordLeft = cntButton.tCoordLeft;
		info.tCoordRight = cntButton.tCoordRight;
		info.tCoordTop = cntButton.tCoordTop;
		info.tCoordBottom = cntButton.tCoordBottom;
		info.iconInfo = nil;
	end
	
	-- Checked conditions
	if (level == 1) then
		info.checked = nil;
	end
	if ( buttonIndex == "LARGE_FOCUS" ) then
		if ( GetCVarBool("fullSizeFocusFrame") ) then
			info.checked = true;
		end
	end
	
	if ( cntButton.nested ) then
		info.hasArrow = true;
	else
		info.hasArrow = nil;
	end
	if ( cntButton.isNotRadio ) then
		info.isNotRadio = true
	else
		info.isNotRadio = nil;
	end
	if ( cntButton.isTitle ) then
		info.isTitle = true;
	else
		if (level == 1) then
			info.disabled = nil;
		end
		info.isTitle = nil;
	end
	
	-- Setup newbie tooltips
	info.tooltipTitle = cntButton.text;
	local tooltipText = _G["NEWBIE_TOOLTIP_UNIT_"..buttonIndex];
	if ( not tooltipText ) then
		tooltipText = cntButton.tooltipText;
	end
	info.tooltipText = tooltipText;
	
	UIDropDownMenu_AddButton(info, level);	
end

function UnitPopup_HideButtons ()
	local dropdownMenu = UIDROPDOWNMENU_INIT_MENU;
	local inInstance, instanceType = IsInInstance();

	local inParty = IsInGroup();
	local inRaid = IsInRaid();
	local isLeader = UnitIsGroupLeader("player");
	local isAssistant = UnitIsGroupAssistant("player");
	local inBattleground = UnitInBattleground("player");
	local canCoop = dropdownMenu.unit and UnitCanCooperate("player", dropdownMenu.unit);
	local isPlayer = dropdownMenu.unit and UnitIsPlayer(dropdownMenu.unit);
	
	local haveBattleTag;
	if ( BNFeaturesEnabledAndConnected() ) then
		local _, battleTag = BNGetInfo();
		if ( battleTag ) then
			haveBattleTag = true;
		end
	end

	for index, value in ipairs(UnitPopupMenus[UIDROPDOWNMENU_MENU_VALUE] or UnitPopupMenus[dropdownMenu.which]) do
		UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 1;
		if ( value == "TRADE" ) then
			if ( not canCoop or not isPlayer ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "ADD_FRIEND" ) then
			if ( haveBattleTag or not canCoop or not isPlayer or not UnitIsSameServer(dropdownMenu.unit) or GetFriendInfo(UnitName(dropdownMenu.unit)) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "ADD_FRIEND_MENU" ) then
			if ( not haveBattleTag or not isPlayer ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "GUILD_BATTLETAG_FRIEND" ) then
			if ( not haveBattleTag or UnitName("player" ) == dropdownMenu.name ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "INVITE" ) then
			if ( dropdownMenu.unit ) then
				if ( not canCoop  or UnitIsUnit("player", dropdownMenu.unit) ) then
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				end
			elseif ( (dropdownMenu == ChannelRosterDropDown) ) then
				if ( UnitInRaid(dropdownMenu.name) ~= nil ) then
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				end
			elseif ( dropdownMenu == FriendsDropDown and dropdownMenu.isMobile ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			elseif ( dropdownMenu == GuildMenuDropDown and dropdownMenu.isMobile ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			else
				if ( dropdownMenu.name == UnitName("party1") or
					 dropdownMenu.name == UnitName("party2") or
					 dropdownMenu.name == UnitName("party3") or
					 dropdownMenu.name == UnitName("party4") or
					 dropdownMenu.name == UnitName("player")) then
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				end
			end
		elseif ( value == "BN_INVITE" ) then
			if ( not dropdownMenu.bnetIDAccount or not BNFeaturesEnabledAndConnected() ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			else
				local bnetIDAccount, accountName, battleTag, isBattleTag, characterName, bnetIDGameAccount = BNGetFriendInfoByID(dropdownMenu.bnetIDAccount);
				if ( CanCooperateWithGameAccount(bnetIDGameAccount) and (UnitInParty(characterName) or UnitInRaid(characterName)) ) then
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				end
			end
		elseif ( value == "FOLLOW" ) then
			if ( not canCoop or not isPlayer ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "WHISPER" ) then
			local playerName, playerServer = UnitName("player");
			if ( dropdownMenu.unit ) then
				if ( not canCoop or not isPlayer or (dropdownMenu.name == playerName and dropdownMenu.server == playerServer) ) then
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				end
			end
		elseif ( value == "DUEL" ) then
			if ( UnitCanAttack("player", dropdownMenu.unit) or not isPlayer ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "PET_BATTLE_PVP_DUEL" ) then
			if ( not UnitCanPetBattle("player", dropdownMenu.unit) or not isPlayer ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "INSPECT" or value == "ACHIEVEMENTS" ) then
			if ( not dropdownMenu.unit or UnitCanAttack("player", dropdownMenu.unit) or not isPlayer ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "IGNORE" ) then
			if ( dropdownMenu.name == UnitName("player") or ( dropdownMenu.unit and not isPlayer ) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "REMOVE_FRIEND" ) then
			if ( not dropdownMenu.friendsList ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "SET_NOTE" ) then
			if ( not dropdownMenu.friendsList ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "BN_SET_NOTE" ) then
			if ( not dropdownMenu.friendsList ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "BN_VIEW_FRIENDS" ) then
			if ( not dropdownMenu.friendsList ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "BN_REMOVE_FRIEND" ) then
			if ( not dropdownMenu.friendsList ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "BLOCK_COMMUNICATION" ) then
			-- only show it for bnetIDAccounts that are not friends
			if ( dropdownMenu.bnetIDAccount and BNFeaturesEnabledAndConnected()) then
				local bnetIDAccount, accountName, battleTag, isBattleTag, characterName, bnetIDGameAccount, client, isOnline, lastOnline, isAFK, isDND, broadcastText, noteText, isFriend = BNGetFriendInfoByID(dropdownMenu.bnetIDAccount);
				if ( isFriend ) then
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				end
			else
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "BN_REPORT" ) then
			if ( not dropdownMenu.bnetIDAccount or not BNFeaturesEnabledAndConnected() ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "REPORT_PLAYER" ) then
			if ( (not dropdownMenu.unit) and (not dropdownMenu.battlefieldScoreIndex) and
				(not dropdownMenu.lineID or not CanComplainChat(dropdownMenu.lineID)) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "REPORT_SPAM" ) then
			if ( not dropdownMenu.lineID or not CanComplainChat(dropdownMenu.lineID) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "REPORT_BAD_LANGUAGE" ) then
			if ( not dropdownMenu.lineID or not CanComplainChat(dropdownMenu.lineID) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "POP_OUT_CHAT" ) then
			if ( (dropdownMenu.chatType ~= "WHISPER" and dropdownMenu.chatType ~= "BN_WHISPER") or dropdownMenu.chatTarget == UnitName("player") or
				FCFManager_GetNumDedicatedFrames(dropdownMenu.chatType, dropdownMenu.chatTarget) > 0 ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "TARGET" ) then
			-- We don't want to show a menu option that will end up being blocked
			if ( InCombatLockdown() or not issecure() ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			elseif ( dropdownMenu.isMobile ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "BN_TARGET" ) then
			-- We don't want to show a menu option that will end up being blocked
			if ( not dropdownMenu.bnetIDAccount or InCombatLockdown() or not issecure() ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "PROMOTE" ) then
			if ( not inParty or not isLeader or not isPlayer or HasLFGRestrictions()) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "PROMOTE_GUIDE" ) then
			if ( not inParty or not isLeader or not isPlayer or not HasLFGRestrictions()) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "GUILD_PROMOTE" ) then
			if ( not IsGuildLeader() or not isPlayer or dropdownMenu.name == UnitName("player") ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "GUILD_LEAVE" ) then
			if ( dropdownMenu.name ~= UnitName("player") ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "UNINVITE" ) then
			if ( not inParty or not isPlayer or not isLeader or (instanceType == "pvp") or (instanceType == "arena") or HasLFGRestrictions() ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "VOTE_TO_KICK" ) then
			if ( not inParty or not isPlayer or (instanceType == "pvp") or (instanceType == "arena") or (not HasLFGRestrictions()) or IsInActiveWorldPVP() ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "LEAVE" ) then
			if ( not inParty or IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or (instanceType == "pvp") or (instanceType == "arena") ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "INSTANCE_LEAVE" ) then
			if ( not inParty or not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or IsPartyWorldPVP() or instanceType == "pvp" or instanceType == "arena" ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "FREE_FOR_ALL" ) then
			if ( not inParty or (not isLeader and (GetLootMethod() ~= "freeforall")) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "MASTER_LOOTER" ) then
			if ( not inParty or (not isLeader and (GetLootMethod() ~= "master")) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "GROUP_LOOT" ) then
			if ( not inParty or (not isLeader and (GetLootMethod() ~= "group")) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "PERSONAL_LOOT" ) then
			if ( not inParty or (not isLeader and (GetLootMethod() ~= "personalloot")) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "LOOT_THRESHOLD" ) then
			if ( not inParty or HasLFGRestrictions() ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "MOVE_PLAYER_FRAME" ) then
			if ( dropdownMenu ~= PlayerFrameDropDown ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "LOCK_PLAYER_FRAME" ) then
			if ( not PLAYER_FRAME_UNLOCKED ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "UNLOCK_PLAYER_FRAME" ) then
			if ( PLAYER_FRAME_UNLOCKED ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "MOVE_TARGET_FRAME" ) then
			if ( dropdownMenu ~= TargetFrameDropDown ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "LOCK_TARGET_FRAME" ) then
			if ( not TARGET_FRAME_UNLOCKED ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "UNLOCK_TARGET_FRAME" ) then
			if ( TARGET_FRAME_UNLOCKED ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
	   elseif ( value == "LARGE_FOCUS" ) then
			if ( dropdownMenu ~= FocusFrameDropDown ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
	   elseif ( value == "MOVE_FOCUS_FRAME" ) then
			if ( dropdownMenu ~= FocusFrameDropDown ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "LOCK_FOCUS_FRAME" ) then
			if ( FocusFrame_IsLocked() ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "UNLOCK_FOCUS_FRAME" ) then
			if ( not FocusFrame_IsLocked() ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "OPT_OUT_LOOT_TITLE" ) then
			if ( not inParty or ( inParty and GetLootMethod() == "freeforall" ) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "LOOT_PROMOTE" ) then
			local isMaster = nil;
			local lootMethod, partyIndex, raidIndex = GetLootMethod();
			if ( (dropdownMenu.which == "RAID") or (dropdownMenu.which == "RAID_PLAYER") ) then
				if ( raidIndex and (dropdownMenu.unit == "raid"..raidIndex) ) then
					isMaster = true;
				end
			elseif ( dropdownMenu.which == "SELF" ) then
				 if ( partyIndex and (partyIndex == 0) ) then
					isMaster = true;
				 end
			else
				if ( partyIndex and (dropdownMenu.unit == "party"..partyIndex) ) then
					isMaster = true;
				end
			end
			if ( not inParty or not isLeader or (lootMethod ~= "master") or isMaster ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "LOOT_METHOD" ) then
			if ( not inParty ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "SELECT_LOOT_SPECIALIZATION" ) then
			if ( not GetSpecialization() ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( strsub(value, 1, 20) == "LOOT_SPECIALIZATION_" ) then
			if ( UnitPopupButtons[value].specializationID == -1 ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "CONVERT_TO_RAID" ) then
			if ( not inParty or inRaid or not isLeader or IsInGroup(LE_PARTY_CATEGORY_INSTANCE) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "CONVERT_TO_PARTY" ) then
			if ( not inRaid or not isLeader or IsInGroup(LE_PARTY_CATEGORY_INSTANCE) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "RESET_INSTANCES" ) then
			if ( ( inParty and not isLeader ) or inInstance) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "RESET_CHALLENGE_MODE" ) then
			if ( not inInstance or not C_ChallengeMode.IsChallengeModeActive() or ( inParty and not isLeader ) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "DUNGEON_DIFFICULTY" ) then
			if ( UnitLevel("player") < 65 and GetDungeonDifficultyID() == UnitPopupButtons[value].defaultDifficultyID ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "RAID_DIFFICULTY" ) then
			if ( UnitLevel("player") < MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_WRATH_OF_THE_LICH_KING] and GetRaidDifficultyID() == UnitPopupButtons[value].defaultDifficultyID ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "MUTE" ) then
			if ( not IsVoiceChatEnabled() or not isPlayer or (dropdownMenu.unit and not UnitIsConnected(dropdownMenu.unit)) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;			
			else
				-- Hide if already muted.
				local playerName, playerServer = UnitName("player");
				if ( (dropdownMenu.name == playerName and dropdownMenu.server == playerServer) or IsMuted(dropdownMenu.name) ) then
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				end
			end
		elseif ( value == "UNMUTE" ) then
			if ( not IsVoiceChatEnabled() or not isPlayer ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;			
			else
				-- Hide if not muted or not online.
				if ( dropdownMenu.name == UnitName("player") or not IsMuted(dropdownMenu.name) ) then
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				end
			end
		elseif ( value == "RAID_LEADER" ) then
			if ( not isLeader or not isPlayer or UnitIsGroupLeader(dropdownMenu.unit)or not dropdownMenu.name ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "RAID_PROMOTE" ) then
			if ( not isLeader or not isPlayer or IsEveryoneAssistant() ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			elseif ( isLeader ) then
				if ( UnitIsGroupAssistant(dropdownMenu.unit) ) then
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				end			
			end
		elseif ( value == "RAID_DEMOTE" ) then
			if ( ( not isLeader and not isAssistant ) or not dropdownMenu.name or not isPlayer ) then			
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			elseif ( not GetPartyAssignment("MAINTANK", dropdownMenu.name, 1) and not GetPartyAssignment("MAINASSIST", dropdownMenu.name, 1) ) then
				if ( not isLeader  and isAssistant and UnitIsGroupAssistant(dropdownMenu.unit) ) then
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				elseif ( isLeader or isAssistant ) then
					if ( UnitIsGroupLeader(dropdownMenu.unit) or not UnitIsGroupAssistant(dropdownMenu.unit) or IsEveryoneAssistant()) then
						UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
					end
				end
			end
		elseif ( value == "RAID_MAINTANK" ) then
			-- We don't want to show a menu option that will end up being blocked
            if ( not issecure() or (not isLeader and not isAssistant) or not isPlayer or GetPartyAssignment("MAINTANK", dropdownMenu.unit) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "RAID_MAINASSIST" ) then
			-- We don't want to show a menu option that will end up being blocked
            if ( not issecure() or (not isLeader and not isAssistant) or not isPlayer or GetPartyAssignment("MAINASSIST", dropdownMenu.unit) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "RAID_REMOVE" ) then
			if ( HasLFGRestrictions() or not isPlayer ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			elseif ( ( not isLeader and not isAssistant ) or not dropdownMenu.name or (instanceType == "pvp") or (instanceType == "arena") ) then			
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			elseif ( not isLeader and isAssistant and UnitIsGroupAssistant(dropdownMenu.unit) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			elseif ( isLeader and UnitIsUnit(dropdownMenu.unit, "player") ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "PVP_REPORT_AFK" ) then
			if ( IsRatedMap() or  (not IsInActiveWorldPVP() and (not inBattleground or GetCVar("enablePVPNotifyAFK") == "0") ) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			elseif ( dropdownMenu.unit ) then
				if ( UnitIsUnit(dropdownMenu.unit,"player") ) then
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				elseif ( not UnitInBattleground(dropdownMenu.unit) and not IsInActiveWorldPVP(dropdownMenu.unit) ) then
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				elseif ( (PlayerIsPVPInactive(dropdownMenu.unit)) ) then
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				end
			elseif ( dropdownMenu.name ) then
				if ( dropdownMenu.name == UnitName("player") ) then
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				elseif ( not UnitInBattleground(dropdownMenu.name) and not IsInActiveWorldPVP(dropdownMenu.name) ) then
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				end
			end
		elseif ( value == "RAF_SUMMON" ) then
			if( not IsReferAFriendLinked(dropdownMenu.unit) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "RAF_GRANT_LEVEL" ) then
			if( not IsReferAFriendLinked(dropdownMenu.unit) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "PET_RENAME" ) then
			if( not PetCanBeAbandoned() or not PetCanBeRenamed() ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "PET_ABANDON" ) then
			if( not PetCanBeAbandoned() or not PetHasActionBar() ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "PET_DISMISS" ) then
			if( ( PetCanBeAbandoned() and not IsSpellKnown(HUNTER_DISMISS_PET) ) or not PetCanBeDismissed() ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( strsub(value, 1, 12)  == "RAID_TARGET_" ) then
			-- Task #30755. Let any party member mark targets
			-- Task 34335 - But only raid leaders can mark targets.
			if ( inRaid and not isLeader and not isAssistant ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
			if ( not (dropdownMenu.which == "SELF") ) then
				if ( UnitExists("target") and not UnitPlayerOrPetInParty("target") and not UnitPlayerOrPetInRaid("target") ) then
					if ( UnitIsPlayer("target") and (not UnitCanCooperate("player", "target") and not UnitIsUnit("target", "player")) ) then
						UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
					end
				end
			end

		elseif ( value == "CHAT_PROMOTE" ) then
			if ( dropdownMenu.category == "CHANNEL_CATEGORY_GROUP" ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			else
				if ( not IsDisplayChannelOwner() or dropdownMenu.owner or dropdownMenu.moderator or dropdownMenu.name == UnitName("player") ) then
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				end
			end
		elseif ( value == "CHAT_DEMOTE" ) then
			if ( dropdownMenu.category == "CHANNEL_CATEGORY_GROUP" ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			else
				if ( not IsDisplayChannelOwner() or dropdownMenu.owner or not dropdownMenu.moderator or dropdownMenu.name == UnitName("player") ) then
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				end
			end
		elseif ( value == "CHAT_OWNER" ) then
			if ( dropdownMenu.category == "CHANNEL_CATEGORY_GROUP" ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			else
				if ( not IsDisplayChannelOwner() or dropdownMenu.owner or dropdownMenu.name == UnitName("player") ) then
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				end
			end
		elseif ( value == "CHAT_SILENCE" ) then
			if ( not IsVoiceChatEnabled() or not dropdownMenu.name or dropdownMenu.name == UNKNOWNOBJECT or not GetVoiceStatus(dropdownMenu.name) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;			
			else
				if ( IsDisplayChannelModerator() and dropdownMenu.name ~= UnitName("player") ) then
					if ( IsSilenced(dropdownMenu.name) ) then
						UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
					end
				else
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				end
			end
		elseif ( value == "CHAT_UNSILENCE" ) then
			if ( not IsVoiceChatEnabled() or not dropdownMenu.name or dropdownMenu.name == UNKNOWNOBJECT or not GetVoiceStatus(dropdownMenu.name) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;			
			else
				if ( IsDisplayChannelModerator() ) then
					if ( not IsSilenced(dropdownMenu.name) ) then
						UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
					end
				else
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				end
			end
		elseif ( value == "PARTY_SILENCE" ) then
			if ( not IsVoiceChatEnabled() or not dropdownMenu.name or dropdownMenu.name == UNKNOWNOBJECT or not GetVoiceStatus(dropdownMenu.name) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;			
			else
				if ( ( inParty and isLeader and not inRaid ) and dropdownMenu.name ~= UnitName("player") ) then
					if ( UnitIsSilenced(dropdownMenu.name, "party") ) then
						UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
					end
					dropdownMenu.channelName = "party";
				else
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				end
			end
		elseif ( value == "PARTY_UNSILENCE" ) then
			if ( not IsVoiceChatEnabled() or not dropdownMenu.name or dropdownMenu.name == UNKNOWNOBJECT or not GetVoiceStatus(dropdownMenu.name) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;			
			else
				if ( ( inParty and isLeader and not inRaid ) ) then
					if ( not UnitIsSilenced(dropdownMenu.name, "party") ) then
						UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
					end
					dropdownMenu.channelName = "party";
				else
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				end
			end
		elseif ( value == "RAID_SILENCE" ) then
			if ( not IsVoiceChatEnabled() or not dropdownMenu.name or dropdownMenu.name == UNKNOWNOBJECT or not GetVoiceStatus(dropdownMenu.name) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;			
			else
				if (  not inBattleground ) then
					if ( ( inParty and isAssistant and inRaid ) and dropdownMenu.name ~= UnitName("player") ) then
						if ( UnitIsSilenced(dropdownMenu.name, "raid") ) then
							UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
						end
						dropdownMenu.channelName = "raid";
					else
						UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
					end
				else
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				end
			end
		elseif ( value == "RAID_UNSILENCE" ) then
			if ( not IsVoiceChatEnabled() or not dropdownMenu.name or dropdownMenu.name == UNKNOWNOBJECT or not GetVoiceStatus(dropdownMenu.name) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;			
			else
				if ( not inBattleground ) then
					if ( ( inParty and isAssistant and inRaid ) ) then
						if ( not UnitIsSilenced(dropdownMenu.name, "raid") ) then
							UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
						end
						dropdownMenu.channelName = "raid";
					else
						UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
					end
				else
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				end
			end
		elseif ( value == "BATTLEGROUND_SILENCE" ) then
			if ( not IsVoiceChatEnabled() or not dropdownMenu.name or dropdownMenu.name == UNKNOWNOBJECT or not GetVoiceStatus(dropdownMenu.name) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;	
			else
				if (  inBattleground ) then
					if ( ( inParty and isAssistant and inRaid ) and dropdownMenu.name ~= UnitName("player") ) then
						if ( UnitIsSilenced(dropdownMenu.name, "battleground") ) then
							UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
						end
						dropdownMenu.channelName = "battleground";
					else
						UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
					end
				else
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				end
			end
		elseif ( value == "BATTLEGROUND_UNSILENCE" ) then
			if ( not IsVoiceChatEnabled() or not dropdownMenu.name or dropdownMenu.name == UNKNOWNOBJECT or not GetVoiceStatus(dropdownMenu.name) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;			
			else
				if (  inBattleground ) then
					if ( ( inParty and isAssistant and inRaid ) ) then
						if ( not UnitIsSilenced(dropdownMenu.name, "battleground") ) then
							UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
						end
						dropdownMenu.channelName = "battleground";
					else
						UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
					end
				else
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
				end
			end
		elseif ( value == "CHAT_KICK" ) then
			UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
		elseif ( value == "CHAT_LEAVE" ) then
			if ( not dropdownMenu.active or dropdownMenu.group) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "VEHICLE_LEAVE" ) then
			if ( not CanExitVehicle() ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "SELECT_ROLE" ) then
			if ( C_Scenario.IsInScenario() or not ( IsInGroup() and not HasLFGRestrictions() and (isLeader or isAssistant or UnitIsUnit(dropdownMenu.unit, "player")) ) ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		elseif ( value == "GARRISON_VISIT" ) then
			if ( not C_Garrison.IsVisitGarrisonAvailable() ) then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 0;
			end
		end
	end
end

function UnitPopup_OnUpdate (elapsed)
	if ( not DropDownList1:IsShown() ) then
		return;
	end

	-- If none of the untipopup frames are visible then return
	for index, value in ipairs(UnitPopupFrames) do
		if ( UIDROPDOWNMENU_OPEN_MENU == _G[value] ) then
			break;
		elseif ( index == #UnitPopupFrames ) then
			return;
		end
	end

	local currentDropDown = UIDROPDOWNMENU_OPEN_MENU;

	local inParty = IsInGroup();
	local inPublicParty = IsInGroup(LE_PARTY_CATEGORY_INSTANCE);
	local isLeader = UnitIsGroupLeader("player");
	local isAssistant = UnitIsGroupAssistant("player");
	
	-- dynamic difficulty
	local toggleDifficultyID;
	local _, instanceType, instanceDifficultyID, _, _, _, isDynamicInstance = GetInstanceInfo();
	if ( isDynamicInstance and CanChangePlayerDifficulty() ) then
		_, _, _, _, _, _, toggleDifficultyID = GetDifficultyInfo(instanceDifficultyID);
	end
	
	-- Loop through all menus and enable/disable their buttons appropriately
	local count, tempCount;
	local inInstance, instanceType = IsInInstance();
	for level, dropdownFrame in pairs(OPEN_DROPDOWNMENUS) do
		if ( dropdownFrame ) then
			count = 0;
			for index, value in ipairs(UnitPopupMenus[dropdownFrame.which]) do
				if ( UnitPopupShown[level][index] == 1 ) then
					count = count + 1;
					local enable = true;
					local notClickable = false;
					if ( UnitPopupButtons[value].isUninteractable or 
						(UnitPopupButtons[value].dist > 0 and not CheckInteractDistance(dropdownFrame.unit, UnitPopupButtons[value].dist)) or (UnitPopupButtons[value].disabledInKioskMode and IsKioskModeEnabled())) then
						enable = false;
					end

					if ( value == "TRADE" ) then
						if ( UnitIsDeadOrGhost("player") or (not HasFullControl()) or UnitIsDeadOrGhost(dropdownFrame.unit) ) then
							enable = false;
						end
					elseif ( value == "LEAVE" ) then
						if ( not inParty ) then
							enable = false;
						end
					elseif ( value == "INSTANCE_LEAVE" ) then
						if ( not inParty ) then
							enable = false;
						end
					elseif ( value == "INVITE" ) then
						if ( inParty and (not isLeader and not isAssistant) ) then
							enable = false;
						end
					elseif ( value == "UNINVITE" ) then
						if ( not inParty or not isLeader or HasLFGRestrictions() or (instanceType == "pvp") or (instanceType == "arena") ) then
							enable = false;
						end
					elseif ( value == "BN_INVITE" ) then
						if ( not currentDropDown.bnetIDAccount or not CanGroupWithAccount(currentDropDown.bnetIDAccount) ) then
							enable = false;
						end
					elseif ( value == "BN_TARGET" ) then
						if ( not currentDropDown.bnetIDAccount) then
							enable = false;
						else
							local _, _, _, _, _, _, client = BNGetFriendInfoByID(currentDropDown.bnetIDAccount);
							if (client ~= BNET_CLIENT_WOW) then
								enable = false;
							end
						end
					elseif ( value == "VOTE_TO_KICK" ) then
						if ( not inParty or not HasLFGRestrictions() ) then
							enable = false;
						end
					elseif ( value == "PROMOTE" or value == "PROMOTE_GUIDE" ) then
						if ( not inParty or not isLeader or ( dropdownFrame.unit and not UnitIsConnected(dropdownFrame.unit) ) ) then
							enable = false;
						end
					elseif ( value == "WHISPER" ) then
						if ( dropdownFrame.unit and not UnitIsConnected(dropdownFrame.unit) ) then
							enable = false;
						end
					elseif ( value == "MUTE" ) then
						if ( dropdownFrame.unit and not UnitIsConnected(dropdownFrame.unit) ) then
							enable = false;
						end
					elseif ( value == "INSPECT" ) then
						if ( UnitIsDeadOrGhost("player") ) then
							enable = false;
						end
					elseif ( value == "FOLLOW" ) then
						if ( UnitIsDead("player") ) then
							enable = false;
						end
					elseif ( value == "DUEL" ) then
						if ( UnitIsDeadOrGhost("player") or (not HasFullControl()) or UnitIsDeadOrGhost(dropdownFrame.unit) ) then
							enable = false;
						end
					elseif ( value == "PET_BATTLE_PVP_DUEL" ) then
						if ( UnitIsDeadOrGhost("player") or (not HasFullControl()) or UnitIsDeadOrGhost(dropdownFrame.unit) ) then
							enable = false;
						end
					elseif ( value == "LOOT_METHOD" ) then
						if ( not isLeader or HasLFGRestrictions() ) then
							enable = false;
						end
					elseif ( value == "LOOT_PROMOTE" ) then
						local lootMethod, partyMaster, raidMaster = GetLootMethod();
						if ( not inParty or not isLeader or (lootMethod ~= "master") ) then
							enable = false;
						else
							local masterName = 0;
							if ( partyMaster and (partyMaster == 0) ) then
								masterName = "player";
							elseif ( partyMaster ) then
								masterName = "party"..partyMaster;
							elseif ( raidMaster ) then
								masterName = "raid"..raidMaster;
							end
							if ( dropdownFrame.unit and UnitIsUnit(dropdownFrame.unit, masterName) ) then
								enable = false;
							end
						end
					elseif ( value == "DUNGEON_DIFFICULTY" and inInstance and instanceType == "raid" ) then
						enable = false;
					elseif ( ( strsub(value, 1, 18) == "DUNGEON_DIFFICULTY" ) and ( strlen(value) > 18 ) ) then
						if ( ( inParty and not isLeader ) or inInstance or HasLFGRestrictions() ) then
							enable = false;	
						end
					elseif ( value == "RAID_DIFFICULTY" ) then
						if( inPublicParty or (inInstance and instanceType ~= "raid") ) then
							enable = false;
						end
					elseif ( ( strsub(value, 1, 15) == "RAID_DIFFICULTY" ) and ( strlen(value) > 15 ) ) then
						if ( ( inParty and not isLeader ) or inPublicParty or inInstance ) then
							enable = false;	
						end
						if (toggleDifficultyID) then
							enable = CheckToggleDifficulty(toggleDifficultyID, UnitPopupButtons[value].difficultyID);
						end
						if (UnitPopupButtons[value].difficultyID == DIFFICULTY_PRIMARYRAID_MYTHIC and UnitLevel("player") < MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_MISTS_OF_PANDARIA]) then
							enable = false;
						end
					elseif ( ( strsub(value, 1, 22) == "LEGACY_RAID_DIFFICULTY" ) and ( strlen(value) > 22 ) ) then
						if ( ( inParty and not isLeader ) or inPublicParty or inInstance or GetRaidDifficultyID() == DIFFICULTY_PRIMARYRAID_MYTHIC ) then
							enable = false;	
						end
						if (toggleDifficultyID) then
							if (IsLegacyDifficulty(toggleDifficultyID)) then
								notClickable = CheckToggleDifficulty(toggleDifficultyID, UnitPopupButtons[value].difficultyID);
							end
							enable = false;
						end
					elseif ( value == "CONVERT_TO_PARTY" ) then
						if ( GetNumGroupMembers() > MEMBERS_PER_RAID_GROUP ) then
							enable = false;
						end
					elseif ( value == "RESET_INSTANCES" ) then
						if ( ( inParty and not isLeader ) or inInstance or HasLFGRestrictions() ) then
							enable = false;			
						end
					elseif ( value == "RESET_CHALLENGE_MODE" ) then
						local _, _, energized = C_ChallengeMode.GetActiveKeystoneInfo();
						if (energized) then
							enable = false;
						end
					elseif ( value == "RAF_SUMMON" ) then
						if( not CanSummonFriend(dropdownFrame.unit) ) then
							enable = false;
						end
					elseif ( value == "RAF_GRANT_LEVEL" ) then
						if( not CanGrantLevel(dropdownFrame.unit) ) then
							enable = false;
						end
					elseif ( value == "SET_ROLE_TANK" ) then
						local canBeTank, canBeHealer, canBeDamager = UnitGetAvailableRoles(dropdownFrame.unit);
						if ( not canBeTank ) then
							enable = false;
						end
					elseif ( value == "SET_ROLE_HEALER" ) then
						local canBeTank, canBeHealer, canBeDamager = UnitGetAvailableRoles(dropdownFrame.unit);
						if ( not canBeHealer ) then
							enable = false;
						end
					elseif ( value == "SET_ROLE_DAMAGER" ) then
						local canBeTank, canBeHealer, canBeDamager = UnitGetAvailableRoles(dropdownFrame.unit);
						if ( not canBeDamager ) then
							enable = false;
						end
					elseif ( value == "BATTLETAG_FRIEND" ) then
						if ( not BNFeaturesEnabledAndConnected() ) then
							enable = false;
						end
					elseif ( value == "GUILD_BATTLETAG_FRIEND" ) then
						-- the unit popup menu cannot handle colors of options that can be disabled
						if ( not BNFeaturesEnabledAndConnected() ) then
							enable = false;
						end
					elseif ( value == "CHARACTER_FRIEND" ) then
						if ( not UnitCanCooperate("player", UIDROPDOWNMENU_INIT_MENU.unit) ) then
							enable = false;
						else
							-- disable if player is from another realm or already on friends list
							if ( not UnitIsSameServer(UIDROPDOWNMENU_INIT_MENU.unit) or GetFriendInfo(UnitName(UIDROPDOWNMENU_INIT_MENU.unit)) ) then
								enable = false;
							end
						end
                    elseif ( value == "MASTER_LOOTER" ) then
						if (not IsInGuildGroup()) then
	                        enable = false;
						end
					end

					local diff = (level > 1) and 0 or 1;

					if ( UnitPopupButtons[value].isSubsectionTitle ) then
						--If the button is a title then it has a separator above it that is not in UnitPopupButtons.
						--So 1 extra is added to each count because UnitPopupButtons does not count the separators and
						--the DropDown does.
						tempCount = count + diff;
						count = count + 1;
					else
						tempCount = count + diff;
					end

					if ( enable) then
						UIDropDownMenu_EnableButton(level, tempCount);
					else
						if (notClickable == 1) then
							UIDropDownMenu_SetButtonNotClickable(level, tempCount);
						else
							UIDropDownMenu_SetButtonClickable(level, tempCount);
						end
						UIDropDownMenu_DisableButton(level, tempCount);
					end
				end
			end
		end
	end
end

function UnitPopup_OnClick (self)
	local dropdownFrame = UIDROPDOWNMENU_INIT_MENU;
	local button = self.value;
	local unit = dropdownFrame.unit;
	local name = dropdownFrame.name;
	local server = dropdownFrame.server;
	local fullname = name;
	
	if ( server and (not unit or UnitRealmRelationship(unit) ~= LE_REALM_RELATION_SAME) ) then
		fullname = name.."-"..server;
	end
	
	local inParty = IsInGroup();
	local isLeader = UnitIsGroupLeader("player");
	local isAssistant = UnitIsGroupAssistant("player");

	if ( button == "TRADE" ) then
		InitiateTrade(unit);
	elseif ( button == "WHISPER" ) then
		if ( dropdownFrame.bnetIDAccount ) then
			ChatFrame_SendSmartTell(fullname, dropdownFrame.chatFrame);
		else
			ChatFrame_SendTell(fullname, dropdownFrame.chatFrame);
		end
	elseif ( button == "INSPECT" ) then
		InspectUnit(unit);
	elseif ( button == "ACHIEVEMENTS" ) then
		InspectAchievements(unit);
	elseif ( button == "TARGET" ) then
		TargetUnit(fullname, true);
	elseif ( button == "IGNORE" ) then
		AddOrDelIgnore(fullname);
	elseif ( button == "REPORT_SPAM" ) then
		local dialog = StaticPopup_Show("CONFIRM_REPORT_SPAM_CHAT", fullname);
		if ( dialog ) then
			dialog.data = dropdownFrame.unit or tonumber(dropdownFrame.lineID);
		end
	elseif ( button == "REPORT_BAD_LANGUAGE" ) then
		local dialog = StaticPopup_Show("CONFIRM_REPORT_BAD_LANGUAGE_CHAT", fullname);
		if ( dialog ) then
			dialog.data = dropdownFrame.unit or tonumber(dropdownFrame.lineID);
		end
	elseif ( button == "REPORT_BAD_NAME" ) then
		if ( GMEuropaComplaintsEnabled() and not GMQuickTicketSystemThrottled() ) then
			if (dropdownFrame.unit) then
				HelpFrame_SetReportPlayerByUnitTag(ReportPlayerNameDialog, dropdownFrame.unit);
			elseif (tonumber(dropdownFrame.lineID)) then
				HelpFrame_SetReportPlayerByLineID(ReportPlayerNameDialog, tonumber(dropdownFrame.lineID));
			elseif (dropdownFrame.battlefieldScoreIndex) then
				HelpFrame_SetReportPlayerByBattlefieldScoreIndex(ReportPlayerNameDialog, dropdownFrame.battlefieldScoreIndex);
			end
			
			HelpFrame_ShowReportPlayerNameDialog();
		else
			UIErrorsFrame:AddMessage(ERR_REPORT_SUBMISSION_FAILED , 1.0, 0.1, 0.1, 1.0);
			local info = ChatTypeInfo["SYSTEM"];
			if ( dropdownFrame.chatFrame ) then
				dropdownFrame.chatFrame:AddMessage(ERR_REPORT_SUBMISSION_FAILED, info.r, info.g, info.b);
			else
				DEFAULT_CHAT_FRAME:AddMessage(ERR_REPORT_SUBMISSION_FAILED, info.r, info.g, info.b);
			end
		end
	elseif ( button == "REPORT_PET" ) then
		SetPendingReportPetTarget(unit);
		StaticPopup_Show("CONFIRM_REPORT_PET_NAME", fullname);
	elseif ( button == "REPORT_BATTLE_PET" ) then
		C_PetBattles.SetPendingReportTargetFromUnit(unit);
		StaticPopup_Show("CONFIRM_REPORT_BATTLEPET_NAME", fullname);
	elseif ( button == "REPORT_CHEATING" ) then
		if ( GMEuropaComplaintsEnabled() and not GMQuickTicketSystemThrottled() ) then
			if (dropdownFrame.unit) then
				HelpFrame_SetReportPlayerByUnitTag(ReportCheatingDialog, dropdownFrame.unit);
			elseif (tonumber(dropdownFrame.lineID)) then
				HelpFrame_SetReportPlayerByLineID(ReportCheatingDialog, tonumber(dropdownFrame.lineID));
			elseif (dropdownFrame.battlefieldScoreIndex) then
				HelpFrame_SetReportPlayerByBattlefieldScoreIndex(ReportCheatingDialog, dropdownFrame.battlefieldScoreIndex);
			end
			
			HelpFrame_ShowReportCheatingDialog();
		else
			UIErrorsFrame:AddMessage(ERR_REPORT_SUBMISSION_FAILED , 1.0, 0.1, 0.1, 1.0);
			local info = ChatTypeInfo["SYSTEM"];
			if ( dropdownFrame.chatFrame ) then
				dropdownFrame.chatFrame:AddMessage(ERR_REPORT_SUBMISSION_FAILED, info.r, info.g, info.b);
			else
				DEFAULT_CHAT_FRAME:AddMessage(ERR_REPORT_SUBMISSION_FAILED, info.r, info.g, info.b);
			end
		end
	elseif ( button == "POP_OUT_CHAT" ) then
		FCF_OpenTemporaryWindow(dropdownFrame.chatType, dropdownFrame.chatTarget, dropdownFrame.chatFrame, true);
	elseif ( button == "DUEL" ) then
		StartDuel(unit, true);
	elseif ( button == "PET_BATTLE_PVP_DUEL" ) then
		C_PetBattles.StartPVPDuel(unit, true);
	elseif ( button == "INVITE" ) then
		InviteToGroup(fullname);
	elseif ( button == "UNINVITE" or button == "VOTE_TO_KICK" ) then
		UninviteUnit(fullname, nil, 1);
	elseif ( button == "REMOVE_FRIEND" ) then
		RemoveFriend(fullname);
	elseif ( button == "SET_NOTE" ) then
		FriendsFrame.NotesID = fullname;
		StaticPopup_Show("SET_FRIENDNOTE", fullname);
		PlaySound("igCharacterInfoClose");
	elseif ( button == "BN_REMOVE_FRIEND" ) then
		local bnetIDAccount, accountName, _, isBattleTag = BNGetFriendInfoByID(dropdownFrame.bnetIDAccount);
		if ( bnetIDAccount ) then
			local promptText;
			if ( isBattleTag ) then
				promptText = string.format(BATTLETAG_REMOVE_FRIEND_CONFIRMATION, accountName);
			else
				promptText = string.format(REMOVE_FRIEND_CONFIRMATION, accountName);
			end
			local dialog = StaticPopup_Show("CONFIRM_REMOVE_FRIEND", promptText, nil, bnetIDAccount);
		end
	elseif ( button == "BN_SET_NOTE" ) then
		FriendsFrame.NotesID = dropdownFrame.bnetIDAccount;
		StaticPopup_Show("SET_BNFRIENDNOTE", fullname);
		PlaySound("igCharacterInfoClose");
	elseif ( button == "BN_VIEW_FRIENDS" ) then
		FriendsFriendsFrame_Show(dropdownFrame.bnetIDAccount);
	elseif ( button == "BN_INVITE" ) then
		FriendsFrame_BattlenetInvite(nil, dropdownFrame.bnetIDAccount);
	elseif ( button == "BN_TARGET" ) then
		local bnetIDAccount, accountName, battleTag, isBattleTag, characterName = BNGetFriendInfoByID(dropdownFrame.bnetIDAccount);
		if ( characterName ) then
			TargetUnit(characterName);
		end
	elseif ( button == "BLOCK_COMMUNICATION" ) then
		BNSetBlocked(dropdownFrame.bnetIDAccount, true);
	elseif ( button == "PROMOTE" or button == "PROMOTE_GUIDE" ) then
		PromoteToLeader(unit, 1);
	elseif ( button == "GUILD_PROMOTE" ) then
		local dialog = StaticPopup_Show("CONFIRM_GUILD_PROMOTE", fullname);
		dialog.data = fullname;
	elseif ( button == "GUILD_LEAVE" ) then
		local guildName = GetGuildInfo("player");
		StaticPopup_Show("CONFIRM_GUILD_LEAVE", guildName);
	elseif ( button == "LEAVE" ) then
		LeaveParty();
	elseif ( button == "INSTANCE_LEAVE" ) then
		ConfirmOrLeaveLFGParty();
	elseif ( button == "PET_DISMISS" ) then
		if ( PetCanBeAbandoned() ) then
			CastSpellByID(HUNTER_DISMISS_PET);
		else
			PetDismiss();
		end
	elseif ( button == "PET_ABANDON" ) then
		StaticPopup_Show("ABANDON_PET");
	elseif ( button == "PET_RENAME" ) then
		StaticPopup_Show("RENAME_PET");
	elseif ( button == "PET_SHOW_IN_JOURNAL" ) then
		if (not CollectionsJournal) then
			CollectionsJournal_LoadUI();
		end
		if (not CollectionsJournal:IsShown()) then
			ShowUIPanel(CollectionsJournal);
		end
		CollectionsJournal_SetTab(CollectionsJournal, 2);
		PetJournal_SelectSpecies(PetJournal, UnitBattlePetSpeciesID(unit));
	elseif ( button == "FREE_FOR_ALL" ) then
		SetLootMethod("freeforall");
		UIDropDownMenu_SetButtonText(self:GetParent().parentLevel, self:GetParent().parentID, UnitPopupButtons[button].text);
		UIDropDownMenu_Refresh(dropdownFrame, nil, 1);
	elseif ( button == "MASTER_LOOTER" ) then
		SetLootMethod("master", fullname, 1);
		UIDropDownMenu_SetButtonText(self:GetParent().parentLevel, self:GetParent().parentID, UnitPopupButtons[button].text);
		UIDropDownMenu_Refresh(dropdownFrame, nil, 1);
	elseif ( button == "GROUP_LOOT" ) then
		SetLootMethod("group");
		UIDropDownMenu_SetButtonText(self:GetParent().parentLevel, self:GetParent().parentID, UnitPopupButtons[button].text);
		UIDropDownMenu_Refresh(dropdownFrame, nil, 1);
	elseif ( button == "PERSONAL_LOOT" ) then
		SetLootMethod("personalloot");
		UIDropDownMenu_SetButtonText(self:GetParent().parentLevel, self:GetParent().parentID, UnitPopupButtons[button].text);
		UIDropDownMenu_Refresh(dropdownFrame, nil, 1);
	elseif ( button == "OPT_OUT_LOOT_ENABLE" ) then
		SetOptOutOfLoot(1);
		CloseDropDownMenus()
	elseif ( button == "OPT_OUT_LOOT_DISABLE" ) then
		SetOptOutOfLoot(nil);
		CloseDropDownMenus();
	elseif ( strsub(button, 1, 20) == "LOOT_SPECIALIZATION_" ) then
		SetLootSpecialization(UnitPopupButtons[button].specializationID);
	elseif ( strsub(button, 1, 18) == "DUNGEON_DIFFICULTY" and (strlen(button) > 18) ) then
		local dungeonDifficultyID = UnitPopupButtons[button].difficultyID;
		SetDungeonDifficultyID(dungeonDifficultyID);
	elseif ( strsub(button, 1, 15) == "RAID_DIFFICULTY" and (strlen(button) > 15)) then
		local raidDifficultyID = UnitPopupButtons[button].difficultyID;
		SetRaidDifficulties(true, raidDifficultyID);
	elseif ( strsub(button, 1, 22) == "LEGACY_RAID_DIFFICULTY" and (strlen(button) > 22)) then
		local raidDifficultyID = UnitPopupButtons[button].difficultyID;
		SetRaidDifficulties(false, raidDifficultyID);
	elseif ( button == "LOOT_PROMOTE" ) then
		SetLootMethod("master", fullname, 1);
	elseif ( button == "PVP_ENABLE" ) then
		SetPVP(1);
	elseif ( button == "PVP_DISABLE" ) then
		SetPVP(nil);
	elseif ( button == "CONVERT_TO_RAID" ) then
		ConvertToRaid();
	elseif ( button == "CONVERT_TO_PARTY" ) then
		ConvertToParty();
	elseif ( button == "RESET_INSTANCES" ) then
		StaticPopup_Show("CONFIRM_RESET_INSTANCES");
	elseif ( button == "RESET_CHALLENGE_MODE" ) then
		StaticPopup_Show("CONFIRM_RESET_CHALLENGE_MODE");
	elseif ( button == "FOLLOW" ) then
		FollowUnit(fullname, true);
	elseif ( button == "MUTE" ) then
		AddMute(fullname);
	elseif ( button == "UNMUTE" ) then
		DelMute(fullname);
	elseif ( button == "RAID_LEADER" ) then
		PromoteToLeader(fullname, true)
	elseif ( button == "RAID_PROMOTE" ) then
		PromoteToAssistant(fullname, true);
	elseif ( button == "RAID_DEMOTE" ) then
		if ( isLeader and UnitIsGroupAssistant(unit) ) then
			DemoteAssistant(fullname, true);
		end
		if ( GetPartyAssignment("MAINTANK", fullname, true) ) then
			ClearPartyAssignment("MAINTANK", fullname, true);
		elseif ( GetPartyAssignment("MAINASSIST", fullname, true) ) then	
			ClearPartyAssignment("MAINASSIST", fullname, true);
		end
	elseif ( button == "RAID_MAINTANK" ) then
		SetPartyAssignment("MAINTANK", fullname, true);
	elseif ( button == "RAID_MAINASSIST" ) then
		SetPartyAssignment("MAINASSIST", fullname, true);
	elseif ( button == "RAID_REMOVE" ) then
		UninviteUnit(fullname, nil, 1);
	elseif ( button == "PVP_REPORT_AFK" ) then
		ReportPlayerIsPVPAFK(fullname);
	elseif ( button == "RAF_SUMMON" ) then
		SummonFriend(unit)
	elseif ( button == "RAF_GRANT_LEVEL" ) then
		GrantLevel(unit);
	elseif ( button == "ITEM_QUALITY2_DESC" or button == "ITEM_QUALITY3_DESC" or button == "ITEM_QUALITY4_DESC" ) then
		local id = self:GetID()+1;
		SetLootThreshold(id);
		UIDropDownMenu_SetButtonText(self:GetParent().parentLevel, self:GetParent().parentID, UnitPopupButtons[button].text, ITEM_QUALITY_COLORS[id].hex);
	elseif ( strsub(button, 1, 12) == "RAID_TARGET_" and button ~= "RAID_TARGET_ICON" ) then
		local raidTargetIndex = strsub(button, 13);
		if ( raidTargetIndex == "NONE" ) then
			raidTargetIndex = 0;
		end
		SetRaidTargetIcon(unit, tonumber(raidTargetIndex));
	elseif ( button == "CHAT_PROMOTE" ) then
		ChannelModerator(dropdownFrame.channelName, fullname);
	elseif ( button == "CHAT_DEMOTE" ) then
		ChannelUnmoderator(dropdownFrame.channelName, fullname);
	elseif ( button == "CHAT_OWNER" ) then
		SetChannelOwner(dropdownFrame.channelName, fullname);
	elseif ( button == "CHAT_SILENCE" or button == "PARTY_SILENCE" or button == "RAID_SILENCE" or button == "BATTLEGROUND_SILENCE" ) then
		ChannelSilenceVoice(dropdownFrame.channelName, fullname);
	elseif ( button == "CHAT_UNSILENCE" or button == "PARTY_UNSILENCE" or button == "RAID_UNSILENCE" or button == "BATTLEGROUND_UNSILENCE" ) then
		ChannelUnSilenceVoice(dropdownFrame.channelName, fullname);
	elseif ( button == "CHAT_KICK" ) then
		ChannelKick(dropdownFrame.channelName, fullname);
	elseif ( button == "CHAT_BAN" ) then
		ChannelBan(dropdownFrame.channelName, fullname);
	elseif ( button == "VEHICLE_LEAVE" ) then
		VehicleExit();
	elseif ( button == "SET_FOCUS" ) then
		FocusUnit(unit);
	elseif ( button == "CLEAR_FOCUS" ) then
		ClearFocus(unit);
	elseif ( button == "LOCK_FOCUS_FRAME" ) then
		FocusFrame_SetLock(true);
	elseif ( button == "UNLOCK_FOCUS_FRAME" ) then
		FocusFrame_SetLock(false);
	elseif ( button == "LOCK_PLAYER_FRAME" ) then
		PlayerFrame_SetLocked(true);
	elseif ( button == "UNLOCK_PLAYER_FRAME" ) then
		PlayerFrame_SetLocked(false);
	elseif ( button == "LOCK_TARGET_FRAME" ) then
		TargetFrame_SetLocked(true);
	elseif ( button == "UNLOCK_TARGET_FRAME" ) then
		TargetFrame_SetLocked(false);
	elseif ( button == "RESET_PLAYER_FRAME_POSITION" ) then
		PlayerFrame_ResetUserPlacedPosition();
	elseif ( button == "RESET_TARGET_FRAME_POSITION" ) then
		TargetFrame_ResetUserPlacedPosition();
	elseif ( button == "TARGET_FRAME_BUFFS_ON_TOP" ) then
		TARGET_FRAME_BUFFS_ON_TOP = not TARGET_FRAME_BUFFS_ON_TOP;
		TargetFrame_UpdateBuffsOnTop();
	elseif ( button == "FOCUS_FRAME_BUFFS_ON_TOP" ) then
		FOCUS_FRAME_BUFFS_ON_TOP = not FOCUS_FRAME_BUFFS_ON_TOP;
		FocusFrame_UpdateBuffsOnTop();
	elseif ( button == "LARGE_FOCUS" ) then
		local setting = GetCVarBool("fullSizeFocusFrame");
		setting = not setting;
		SetCVar("fullSizeFocusFrame", setting and "1" or "0" )
		FocusFrame_SetSmallSize(not setting, true);
	elseif ( button == "PLAYER_FRAME_SHOW_CASTBARS" ) then
		PLAYER_FRAME_CASTBARS_SHOWN = not PLAYER_FRAME_CASTBARS_SHOWN;
		if ( PLAYER_FRAME_CASTBARS_SHOWN ) then
			PlayerFrame_AttachCastBar();
		else
			PlayerFrame_DetachCastBar();
		end
	elseif ( strsub(button, 1, 10) == "BN_REPORT_" ) then
		BNet_InitiateReport(dropdownFrame.bnetIDAccount, strsub(button, 11));
	elseif ( strsub(button, 1, 9) == "SET_ROLE_" ) then
		UnitSetRole(dropdownFrame.unit, strsub(button, 10));
	elseif ( button == "ADD_FRIEND" or button == "CHARACTER_FRIEND" ) then
		AddFriend(fullname);
	elseif ( button == "BATTLETAG_FRIEND" ) then
		local _, battleTag = BNGetInfo();
		if ( not battleTag ) then
			StaticPopupSpecial_Show(CreateBattleTagFrame);
		else
			BNCheckBattleTagInviteToUnit(unit);
		end
		CloseDropDownMenus();
	elseif ( button == "GUILD_BATTLETAG_FRIEND" ) then
		local _, battleTag = BNGetInfo();
		if ( not battleTag ) then
			StaticPopupSpecial_Show(CreateBattleTagFrame);
		else
			BNCheckBattleTagInviteToGuildMember(fullname);
		end
		CloseDropDownMenus();
	elseif ( button == "GARRISON_VISIT" ) then
		C_Garrison.SetUsingPartyGarrison( not C_Garrison.IsUsingPartyGarrison());
	end
	PlaySound("UChatScrollButton");
end

RAID_DIFFICULTY_MAP = {
	[DIFFICULTY_PRIMARYRAID_NORMAL] = { [10] = DIFFICULTY_RAID10_NORMAL, [25] = DIFFICULTY_RAID25_NORMAL }, -- Normal -> 10-man normal, 25-man normal
	[DIFFICULTY_PRIMARYRAID_HEROIC] = { [10] = DIFFICULTY_RAID10_HEROIC, [25] = DIFFICULTY_RAID25_HEROIC }, -- Heroic -> 10-man heroic, 25-man heroic
};

RAID_DIFFICULTY_SIZES = {
	[DIFFICULTY_RAID10_NORMAL] = 10,
	[DIFFICULTY_RAID25_NORMAL] = 25,
	[DIFFICULTY_RAID10_HEROIC] = 10,
	[DIFFICULTY_RAID25_HEROIC] = 25,
}

RAID_TOGGLE_MAP = {
	[DIFFICULTY_PRIMARYRAID_NORMAL] = { DIFFICULTY_RAID10_NORMAL, DIFFICULTY_RAID25_NORMAL },
	[DIFFICULTY_PRIMARYRAID_HEROIC] = { DIFFICULTY_RAID10_HEROIC, DIFFICULTY_RAID25_HEROIC },
	[DIFFICULTY_PRIMARYRAID_MYTHIC] = {},
}

function NormalizeLegacyDifficultyID(difficultyID)
	if (not IsLegacyDifficulty(difficultyID)) then
		return difficultyID;
	end

	-- Normal difficulties are 3 and 4 for 10-player and 25-player, heroic are 5 and 6 respectively.  To "normalize"
	-- it, we want to always use 3 and 4 (the normal versions), so we subtract 2 to go from heroic to normal.
	if (difficultyID > 4) then
		difficultyID = difficultyID - 2;
	end
	return difficultyID;
end

function SetRaidDifficulties(primaryRaid, difficultyID)
	local otherDifficulty = 0;
	if (primaryRaid) then
		local toggleDifficultyID, force;
		local _, instanceType, instanceDifficultyID, _, _, _, isDynamicInstance = GetInstanceInfo();
		if ( isDynamicInstance and CanChangePlayerDifficulty() ) then
			_, _, _, _, _, _, toggleDifficultyID = GetDifficultyInfo(instanceDifficultyID);
		end
		if (UnitLevel("player") >= MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_MISTS_OF_PANDARIA]) then			
			if (toggleDifficultyID ~= nil and IsLegacyDifficulty(toggleDifficultyID)) then
				force = true;
			end
			SetRaidDifficultyID(difficultyID, force);
		end
		if (difficultyID == DIFFICULTY_PRIMARYRAID_MYTHIC) then
			return;
		end
		force = nil;
		if (toggleDifficultyID ~= nil and not IsLegacyDifficulty(toggleDifficultyID)) then
			force = true;
		end
		otherDifficulty = GetLegacyRaidDifficultyID();
		local size = RAID_DIFFICULTY_SIZES[otherDifficulty];
		local newDifficulty = RAID_DIFFICULTY_MAP[difficultyID][size];
		SetLegacyRaidDifficultyID(newDifficulty, force);
	else
		local otherDifficulty = GetRaidDifficultyID();
		local size = RAID_DIFFICULTY_SIZES[difficultyID];
		local newDifficulty = RAID_DIFFICULTY_MAP[otherDifficulty][size];
		SetLegacyRaidDifficultyID(newDifficulty);
	end
end

function CheckToggleDifficulty(toggleDifficultyID, difficultyID)
	if (IsLegacyDifficulty(toggleDifficultyID)) then
		if (not IsLegacyDifficulty(difficultyID)) then
			return tContains(RAID_TOGGLE_MAP[difficultyID], toggleDifficultyID);
		else
			return NormalizeLegacyDifficultyID(difficultyID) == NormalizeLegacyDifficultyID(toggleDifficultyID);
		end
	else
		if (IsLegacyDifficulty(difficultyID)) then
			return false;
		else
			return toggleDifficultyID == difficultyID;
		end
	end

	return false;
end
