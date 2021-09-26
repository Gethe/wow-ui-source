
UNITPOPUP_TITLE_HEIGHT = 26;
UNITPOPUP_BUTTON_HEIGHT = 15;
UNITPOPUP_BORDER_HEIGHT = 8;
UNITPOPUP_BORDER_WIDTH = 19;

UNITPOPUP_NUMBUTTONS = 9;
UNITPOPUP_TIMEOUT = 5;

UNITPOPUP_SPACER_SPACING = 6;

local function makeUnitPopupSubsectionTitle(titleText)
	return { text = titleText, isTitle = true, isUninteractable = true, isSubsection = true, isSubsectionTitle = true, isSubsectionSeparator = true, };
end

local function makeUnitPopupSubsectionSeparator()
	return { text = "", isTitle = true, isUninteractable = true, isSubsection = true, isSubsectionTitle = false, isSubsectionSeparator = true, };
end

UnitPopupButtons = {
	["CANCEL"] = { text = CANCEL, space = 1, isCloseCommand = true, },
	["CLOSE"] = { text = CLOSE, space = 1, isCloseCommand = true, },
	["TRADE"] = { text = TRADE, dist = 2 },
	["INSPECT"] = { text = INSPECT, dist = 1, disabledInKioskMode = false },
	["TARGET"] = { text = TARGET, },
	["IGNORE"]	= {
		text = function(dropdownMenu)
			return C_FriendList.IsIgnored(dropdownMenu.name) and IGNORE_REMOVE or IGNORE;
		end,
	},
	["POP_OUT_CHAT"] = { text = MOVE_TO_WHISPER_WINDOW, },
	["DUEL"] = { text = DUEL, dist = 3, space = 1, disabledInKioskMode = false },
	["PET_BATTLE_PVP_DUEL"] = { text = PET_BATTLE_PVP_DUEL, dist = 5, space = 1, disabledInKioskMode = true },
	["WHISPER"]	= { text = WHISPER, },
	["INVITE"]	= { text = PARTY_INVITE, },
	["SUGGEST_INVITE"]	= { text = SUGGEST_INVITE, },
	["REQUEST_INVITE"]	= { text = REQUEST_INVITE, },
	["UNINVITE"] = { text = PARTY_UNINVITE, },
	["REMOVE_FRIEND"]	= { text = REMOVE_FRIEND, },
	["SET_NOTE"]	= { text = SET_NOTE, },
	["BN_REMOVE_FRIEND"]	= { text = REMOVE_FRIEND, },
	["BN_SET_NOTE"]	= { text = SET_NOTE, },
	["BN_VIEW_FRIENDS"]	= { text = VIEW_FRIENDS_OF_FRIENDS, },
	["BN_INVITE"] = { text = PARTY_INVITE, },
	["BN_SUGGEST_INVITE"] = { text = SUGGEST_INVITE, },
	["BN_REQUEST_INVITE"] = { text = REQUEST_INVITE, },
	["BN_TARGET"] = { text = TARGET, },
	["VOTE_TO_KICK"] = { text = VOTE_TO_KICK, },
	["PROMOTE"] = { text = PARTY_PROMOTE, },
	["PROMOTE_GUIDE"] = { text = PARTY_PROMOTE_GUIDE, },
	["GUILD_PROMOTE"] = { text = GUILD_PROMOTE, },
	["GUILD_LEAVE"] = { text = GUILD_LEAVE, },
	["TEAM_PROMOTE"] = { text = TEAM_PROMOTE, dist = 0 },
	["TEAM_KICK"] = { text = TEAM_KICK, dist = 0 },
	["TEAM_LEAVE"] = { text = TEAM_LEAVE, dist = 0 },
	["TEAM_DISBAND"] = { text = TEAM_DISBAND, dist = 0 },
	["LEAVE"] = { text = PARTY_LEAVE, },
	["INSTANCE_LEAVE"] = { text = INSTANCE_PARTY_LEAVE, },
	["FOLLOW"] = { text = FOLLOW, dist = 4 },
	["PET_DISMISS"] = { text = PET_DISMISS, },
	["PET_ABANDON"] = { text = PET_ABANDON, },
	["PET_RENAME"] = { text = PET_RENAME, },
	["PET_SHOW_IN_JOURNAL"] = { text = PET_SHOW_IN_JOURNAL, },
	["LOOT_METHOD"] = { text = LOOT_METHOD, nested = 1},
	["FREE_FOR_ALL"] = { text = LOOT_FREE_FOR_ALL },
	["ROUND_ROBIN"] = { text = LOOT_ROUND_ROBIN },
	["MASTER_LOOTER"] = { text = LOOT_MASTER_LOOTER },
	["GROUP_LOOT"] = { text = LOOT_GROUP_LOOT },
	["NEED_BEFORE_GREED"] = { text = LOOT_NEED_BEFORE_GREED },
	["RESET_INSTANCES"] = { text = RESET_INSTANCES, },
	["RESET_CHALLENGE_MODE"] = { text = RESET_CHALLENGE_MODE, },
	["CONVERT_TO_RAID"] = { text = CONVERT_TO_RAID, },
	["CONVERT_TO_PARTY"] = { text = CONVERT_TO_PARTY, },

	["LOOT_SUBSECTION_TITLE"] = makeUnitPopupSubsectionTitle(UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_LOOT),
	["INSTANCE_SUBSECTION_TITLE"] = makeUnitPopupSubsectionTitle(UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_INSTANCE),
	["OTHER_SUBSECTION_TITLE"] = makeUnitPopupSubsectionTitle(UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_OTHER),
	["INTERACT_SUBSECTION_TITLE"] = makeUnitPopupSubsectionTitle(UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_INTERACT),
	["LEGACY_RAID_SUBSECTION_TITLE"] = makeUnitPopupSubsectionTitle(UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_LEGACY_RAID),
	["SUBSECTION_SEPARATOR"] = makeUnitPopupSubsectionSeparator(),

	["REPORT_PLAYER"] = { text = REPORT_PLAYER_FOR, nested = 1 },
	["REPORT_SPAM"]	= { text = REPORT_SPAMMING, },
	["REPORT_BAD_LANGUAGE"] = { text = REPORT_BAD_LANGUAGE, },
	["REPORT_BAD_NAME"] = { text = REPORT_BAD_NAME, },
	["REPORT_BAD_GUILD_NAME"] = { text = REPORT_BAD_GUILD_NAME, },
	["REPORT_BAD_ARENA_TEAM_NAME"] = { text = REPORT_BAD_ARENA_TEAM_NAME, },
	["REPORT_CHEATING"] = { text = REPORT_CHEATING, },
	["REPORT_BATTLE_PET"] = { text = REPORT_PET_NAME, },
	["REPORT_PET"] = { text = REPORT_PET_NAME, },

	["DUNGEON_DIFFICULTY"] = { text = DUNGEON_DIFFICULTY, nested = 1,  defaultDifficultyID = 1 },
	["DUNGEON_DIFFICULTY1"] = { text = PLAYER_DIFFICULTY1, checkable = 1, difficultyID = 1 },
	["DUNGEON_DIFFICULTY2"] = { text = PLAYER_DIFFICULTY2, checkable = 1, difficultyID = 2 },

	["RAID_DIFFICULTY"] = { text = RAID_DIFFICULTY, nested = 1, defaultDifficultyID = 14 },
	["RAID_DIFFICULTY1"] = { text = PLAYER_DIFFICULTY1, checkable = 1, difficultyID = 14 },
	["RAID_DIFFICULTY2"] = { text = PLAYER_DIFFICULTY2, checkable = 1, difficultyID = 15 },
	["RAID_DIFFICULTY3"] = { text = PLAYER_DIFFICULTY6, checkable = 1, difficultyID = 16 },

	["LEGACY_RAID_DIFFICULTY1"] = { text = RAID_DIFFICULTY1, checkable = 1, difficultyID = 3 },
	["LEGACY_RAID_DIFFICULTY2"] = { text = RAID_DIFFICULTY2, checkable = 1, difficultyID = 4 },

	["PVP_FLAG"] = { text = PVP_FLAG, nested = 1, tooltipWhileDisabled = true, noTooltipWhileEnabled = true, tooltipOnButton = true },
	["PVP_ENABLE"] = { text = ENABLE, checkable = 1 },
	["PVP_DISABLE"] = { text = DISABLE, checkable = 1 },

	["LOOT_THRESHOLD"] = { text = LOOT_THRESHOLD, nested = 1 },
	["LOOT_PROMOTE"] = { text = LOOT_PROMOTE },
	["ITEM_QUALITY2_DESC"] = { text = ITEM_QUALITY2_DESC, color = ITEM_QUALITY_COLORS[2], checkable = 1 },
	["ITEM_QUALITY3_DESC"] = { text = ITEM_QUALITY3_DESC, color = ITEM_QUALITY_COLORS[3], checkable = 1 },
	["ITEM_QUALITY4_DESC"] = { text = ITEM_QUALITY4_DESC, color = ITEM_QUALITY_COLORS[4], checkable = 1 },

	["SELECT_LOOT_SPECIALIZATION"] = { text = SELECT_LOOT_SPECIALIZATION, nested = 1, tooltipText = SELECT_LOOT_SPECIALIZATION_TOOLTIP },
	["LOOT_SPECIALIZATION_DEFAULT"] = { text = LOOT_SPECIALIZATION_DEFAULT, checkable = 1, specializationID = 0 },
	["LOOT_SPECIALIZATION_SPEC1"] = { text = "spec1", checkable = 1, specializationID = 0 },
	["LOOT_SPECIALIZATION_SPEC2"] = { text = "spec2", checkable = 1, specializationID = 0 },
	["LOOT_SPECIALIZATION_SPEC3"] = { text = "spec3", checkable = 1, specializationID = 0 },
	["LOOT_SPECIALIZATION_SPEC4"] = { text = "spec4", checkable = 1, specializationID = 0 },

	["OPT_OUT_LOOT_TITLE"] = { text = OPT_OUT_LOOT_TITLE, nested = 1, tooltipText = NEWBIE_TOOLTIP_UNIT_OPT_OUT_LOOT },
	["OPT_OUT_LOOT_ENABLE"] = { text = YES, checkable = 1 },
	["OPT_OUT_LOOT_DISABLE"] = { text = NO, checkable = 1 },

	["RAID_LEADER"] = { text = SET_RAID_LEADER, },
	["RAID_PROMOTE"] = { text = SET_RAID_ASSISTANT, },
	["RAID_MAINTANK"] = { text = SET_MAIN_TANK, },
	["RAID_MAINASSIST"] = { text = SET_MAIN_ASSIST, },
	["RAID_DEMOTE"] = { text = DEMOTE, },
	["RAID_REMOVE"] = { text = REMOVE, },

	["PVP_REPORT_AFK"] = { text = PVP_REPORT_AFK, },

	["RAF_SUMMON"] = { text = RAF_SUMMON, },
	["RAF_GRANT_LEVEL"] = { text = RAF_GRANT_LEVEL, },

	["VEHICLE_LEAVE"] = { text = VEHICLE_LEAVE, },

	["SET_FOCUS"] = { text = SET_FOCUS, },
	["CLEAR_FOCUS"] = { text = CLEAR_FOCUS, },
	["LARGE_FOCUS"] = { text = FULL_SIZE_FOCUS_FRAME_TEXT, checkable = 1, isNotRadio = 1 },
	["LOCK_FOCUS_FRAME"] = { text = LOCK_FOCUS_FRAME, },
	["UNLOCK_FOCUS_FRAME"] = { text = UNLOCK_FOCUS_FRAME, },
	["MOVE_FOCUS_FRAME"] = { text = MOVE_FRAME, nested = 1 },
	["FOCUS_FRAME_BUFFS_ON_TOP"] = { text = BUFFS_ON_TOP, checkable = 1, isNotRadio = 1 },

	["MOVE_PLAYER_FRAME"] = { text = MOVE_FRAME, nested = 1 },
	["LOCK_PLAYER_FRAME"] = { text = LOCK_FRAME, },
	["UNLOCK_PLAYER_FRAME"] = { text = UNLOCK_FRAME, },
	["RESET_PLAYER_FRAME_POSITION"] = { text = RESET_POSITION, },
	["PLAYER_FRAME_SHOW_CASTBARS"] = { text = PLAYER_FRAME_SHOW_CASTBARS, checkable = 1, isNotRadio = 1 },

	["MOVE_TARGET_FRAME"] = { text = MOVE_FRAME, nested = 1 },
	["LOCK_TARGET_FRAME"] = { text = LOCK_FRAME, },
	["UNLOCK_TARGET_FRAME"] = { text = UNLOCK_FRAME, },
	["TARGET_FRAME_BUFFS_ON_TOP"] = { text = BUFFS_ON_TOP, checkable = 1, isNotRadio = 1 },
	["RESET_TARGET_FRAME_POSITION"] = { text = RESET_POSITION, },

	-- Add Friend related
	["ADD_FRIEND"] = { text = ADD_FRIEND, disabledInKioskMode = true },
	["ADD_FRIEND_MENU"] = { text = ADD_FRIEND, nested = 1, disabledInKioskMode = true },
	["CHARACTER_FRIEND"] = { text = ADD_CHARACTER_FRIEND, disabledInKioskMode = true },
	["BATTLETAG_FRIEND"] = { text = SEND_BATTLETAG_REQUEST, disabledInKioskMode = true },
	["GUILD_BATTLETAG_FRIEND"] = { text = SEND_BATTLETAG_REQUEST, disabledInKioskMode = true },

	["RAID_TARGET_ICON"] = { text = RAID_TARGET_ICON, nested = 1 },
	["RAID_TARGET_1"] = { text = RAID_TARGET_1, checkable = 1, color = {r = 1.0, g = 0.92, b = 0}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0, tCoordRight = 0.25, tCoordTop = 0, tCoordBottom = 0.25 },
	["RAID_TARGET_2"] = { text = RAID_TARGET_2, checkable = 1, color = {r = 0.98, g = 0.57, b = 0}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0.25, tCoordRight = 0.5, tCoordTop = 0, tCoordBottom = 0.25 },
	["RAID_TARGET_3"] = { text = RAID_TARGET_3, checkable = 1, color = {r = 0.83, g = 0.22, b = 0.9}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0.5, tCoordRight = 0.75, tCoordTop = 0, tCoordBottom = 0.25 },
	["RAID_TARGET_4"] = { text = RAID_TARGET_4, checkable = 1, color = {r = 0.04, g = 0.95, b = 0}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0.75, tCoordRight = 1, tCoordTop = 0, tCoordBottom = 0.25 },
	["RAID_TARGET_5"] = { text = RAID_TARGET_5, checkable = 1, color = {r = 0.7, g = 0.82, b = 0.875}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0, tCoordRight = 0.25, tCoordTop = 0.25, tCoordBottom = 0.5 },
	["RAID_TARGET_6"] = { text = RAID_TARGET_6, checkable = 1, color = {r = 0, g = 0.71, b = 1}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0.25, tCoordRight = 0.5, tCoordTop = 0.25, tCoordBottom = 0.5 },
	["RAID_TARGET_7"] = { text = RAID_TARGET_7, checkable = 1, color = {r = 1.0, g = 0.24, b = 0.168}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0.5, tCoordRight = 0.75, tCoordTop = 0.25, tCoordBottom = 0.5 },
	["RAID_TARGET_8"] = { text = RAID_TARGET_8, checkable = 1, color = {r = 0.98, g = 0.98, b = 0.98}, icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcons", tCoordLeft = 0.75, tCoordRight = 1, tCoordTop = 0.25, tCoordBottom = 0.5 },
	["RAID_TARGET_NONE"] = { text = RAID_TARGET_NONE, checkable = 1 },

	-- Chat Channel Player Commands
	["CHAT_PROMOTE"] = { text = MAKE_MODERATOR, },
	["CHAT_DEMOTE"] = { text = REMOVE_MODERATOR, },
	["CHAT_OWNER"] = { text = CHAT_OWNER, },
	["CHAT_KICK"] = { text = CHAT_KICK, },
	["CHAT_BAN"] = { text = CHAT_BAN, },

	-- Garrison
	["GARRISON_VISIT"] = { text = GARRISON_VISIT_LEADER, },

	-- Voice Chat
	["VOICE_CHAT"] = { text = VOICE_CHAT, nested = 1, },
	["VOICE_CHAT_MICROPHONE_VOLUME"] = { customFrame = UnitPopupVoiceMicrophoneVolume, },
	["VOICE_CHAT_SPEAKER_VOLUME"] = { customFrame = UnitPopupVoiceSpeakerVolume, },
	["VOICE_CHAT_USER_VOLUME"] = { customFrame = UnitPopupVoiceUserVolume, },
	["VOICE_CHAT_SETTINGS"] = { text = VOICE_CHAT_SETTINGS, },

	-- Community Member
	["COMMUNITIES_LEAVE"] = { text = function(dropdownMenu)
			return COMMUNITIES_LIST_DROP_DOWN_LEAVE_COMMUNITY;
		end },
	["COMMUNITIES_BATTLETAG_FRIEND"] = { text = COMMUNITY_MEMBER_LIST_DROP_DOWN_BATTLETAG_FRIEND },
	["COMMUNITIES_KICK"] = { text = COMMUNITY_MEMBER_LIST_DROP_DOWN_REMOVE },
	["COMMUNITIES_MEMBER_NOTE"] = { text = COMMUNITY_MEMBER_LIST_DROP_DOWN_SET_NOTE },
	["COMMUNITIES_ROLE"] = { text = COMMUNITY_MEMBER_LIST_DROP_DOWN_ROLES, nested = 1 },
	["COMMUNITIES_ROLE_MEMBER"] = { text = COMMUNITY_MEMBER_ROLE_NAME_MEMBER, checkable = 1 },
	["COMMUNITIES_ROLE_MODERATOR"] = { text = COMMUNITY_MEMBER_ROLE_NAME_MODERATOR, checkable = 1 },
	["COMMUNITIES_ROLE_LEADER"] = { text = COMMUNITY_MEMBER_ROLE_NAME_LEADER, checkable = 1 },
	["COMMUNITIES_ROLE_OWNER"] = { text = COMMUNITY_MEMBER_ROLE_NAME_OWNER, checkable = 1 },
	["COMMUNITIES_FAVORITE"] = { text = function(dropdownMenu)
			return dropdownMenu.clubInfo.favoriteTimeStamp and COMMUNITIES_LIST_DROP_DOWN_UNFAVORITE or COMMUNITIES_LIST_DROP_DOWN_FAVORITE;
		end },
	["COMMUNITIES_SETTINGS"] = { text = COMMUNITIES_LIST_DROP_DOWN_COMMUNITIES_SETTINGS, },
	["COMMUNITIES_NOTIFICATION_SETTINGS"] = { text = COMMUNITIES_LIST_DROP_DOWN_COMMUNITIES_NOTIFICATION_SETTINGS, },
	["COMMUNITIES_CLEAR_UNREAD_NOTIFICATIONS"] = { text = COMMUNITIES_LIST_DROP_DOWN_CLEAR_UNREAD_NOTIFICATIONS, },
	["COMMUNITIES_INVITE"] = { text = COMMUNITIES_LIST_DROP_DOWN_INVITE, },

	-- Community message line
	["DELETE_COMMUNITIES_MESSAGE"] = { text = COMMUNITY_MESSAGE_DROP_DOWN_DELETE, },
};

-- First level menus
UnitPopupMenus = {
	["SELF"] = { "RAID_TARGET_ICON", "SET_FOCUS", "PVP_FLAG", "LOOT_SUBSECTION_TITLE", "LOOT_METHOD", "LOOT_THRESHOLD", "OPT_OUT_LOOT_TITLE", "LOOT_PROMOTE", "INSTANCE_SUBSECTION_TITLE", "CONVERT_TO_RAID", "CONVERT_TO_PARTY", "DUNGEON_DIFFICULTY", "RAID_DIFFICULTY", "RESET_INSTANCES", "OTHER_SUBSECTION_TITLE", "VOICE_CHAT", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "INSTANCE_LEAVE", "LEAVE", "CANCEL" },
	["PET"] = { "RAID_TARGET_ICON", "SET_FOCUS", "INTERACT_SUBSECTION_TITLE", "PET_RENAME", "PET_DISMISS", "PET_ABANDON", "OTHER_SUBSECTION_TITLE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "CANCEL" },
	["OTHERPET"] = { "RAID_TARGET_ICON", "SET_FOCUS", "OTHER_SUBSECTION_TITLE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME",  "REPORT_PET", "CANCEL" },
	["BATTLEPET"] = { "PET_SHOW_IN_JOURNAL", "SET_FOCUS", "OTHER_SUBSECTION_TITLE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "CANCEL" },
	["OTHERBATTLEPET"] = { "PET_SHOW_IN_JOURNAL", "SET_FOCUS", "OTHER_SUBSECTION_TITLE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "REPORT_BATTLE_PET", "CANCEL" },
	["PARTY"] = { "RAID_TARGET_ICON", "SET_FOCUS", "ADD_FRIEND", "ADD_FRIEND_MENU", "INTERACT_SUBSECTION_TITLE", "RAF_SUMMON", "RAF_GRANT_LEVEL", "PROMOTE", "PROMOTE_GUIDE", "LOOT_PROMOTE", "WHISPER", "INSPECT", "TRADE", "FOLLOW", "DUEL", "PET_BATTLE_PVP_DUEL", "OTHER_SUBSECTION_TITLE", "VOICE_CHAT", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "REPORT_PLAYER", "PVP_REPORT_AFK", "VOTE_TO_KICK", "UNINVITE", "CANCEL" },
	["PLAYER"] = { "RAID_TARGET_ICON", "SET_FOCUS", "ADD_FRIEND", "ADD_FRIEND_MENU", "INTERACT_SUBSECTION_TITLE", "RAF_SUMMON", "RAF_GRANT_LEVEL", "INVITE", "SUGGEST_INVITE", "REQUEST_INVITE", "WHISPER", "INSPECT", "TRADE", "FOLLOW", "DUEL", "PET_BATTLE_PVP_DUEL", "OTHER_SUBSECTION_TITLE", "VOICE_CHAT", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "REPORT_PLAYER", "CANCEL" },
	["ENEMY_PLAYER"] = {"SET_FOCUS", "INSPECT", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "REPORT_PLAYER", "CANCEL"},
	["RAID_PLAYER"] = { "RAID_TARGET_ICON", "SET_FOCUS", "ADD_FRIEND", "ADD_FRIEND_MENU", "INTERACT_SUBSECTION_TITLE", "RAF_SUMMON", "RAF_GRANT_LEVEL", "RAID_LEADER", "RAID_PROMOTE", "RAID_DEMOTE", "LOOT_PROMOTE", "WHISPER", "INSPECT", "TRADE", "FOLLOW", "DUEL", "PET_BATTLE_PVP_DUEL", "OTHER_SUBSECTION_TITLE", "VOICE_CHAT", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "REPORT_PLAYER", "PVP_REPORT_AFK", "VOTE_TO_KICK", "RAID_REMOVE", "CANCEL" },
	["RAID"] = { "SET_FOCUS", "INTERACT_SUBSECTION_TITLE", "RAID_LEADER",  "RAID_PROMOTE", "RAID_DEMOTE", "RAID_MAINTANK", "RAID_MAINASSIST", "LOOT_PROMOTE", "OTHER_SUBSECTION_TITLE", "VOICE_CHAT", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "REPORT_PLAYER", "PVP_REPORT_AFK", "VOTE_TO_KICK", "RAID_REMOVE", "CANCEL" },
	["FRIEND"] = { "POP_OUT_CHAT", "TARGET", "SET_NOTE", "INTERACT_SUBSECTION_TITLE", "INVITE", "SUGGEST_INVITE", "REQUEST_INVITE", "WHISPER", "OTHER_SUBSECTION_TITLE", "DELETE_COMMUNITIES_MESSAGE", "IGNORE", "REMOVE_FRIEND", "REPORT_PLAYER", "PVP_REPORT_AFK", "CANCEL" },
	["TEAM"] = { "WHISPER", "INVITE", "TARGET", "TEAM_PROMOTE", "TEAM_KICK", "TEAM_LEAVE", "TEAM_DISBAND", "CANCEL" },
	["FRIEND_OFFLINE"] = { "SET_NOTE", "OTHER_SUBSECTION_TITLE", "IGNORE", "REMOVE_FRIEND", "CANCEL" },
	["BN_FRIEND"] = { "POP_OUT_CHAT", "BN_TARGET", "BN_SET_NOTE", "BN_VIEW_FRIENDS", "INTERACT_SUBSECTION_TITLE", "BN_INVITE", "BN_SUGGEST_INVITE", "BN_REQUEST_INVITE", "WHISPER", "OTHER_SUBSECTION_TITLE", "DELETE_COMMUNITIES_MESSAGE", "BN_REMOVE_FRIEND", "REPORT_PLAYER", "CANCEL" },
	["BN_FRIEND_OFFLINE"] = { "BN_SET_NOTE", "BN_VIEW_FRIENDS", "OTHER_SUBSECTION_TITLE", "BN_REMOVE_FRIEND", "REPORT_PLAYER", "CANCEL" },
	["GUILD"] = { "TARGET", "GUILD_BATTLETAG_FRIEND", "INTERACT_SUBSECTION_TITLE", "INVITE", "SUGGEST_INVITE", "REQUEST_INVITE", "WHISPER", "GUILD_PROMOTE", "OTHER_SUBSECTION_TITLE", "VOICE_CHAT", "IGNORE", "GUILD_LEAVE", "CANCEL" },
	["GUILD_OFFLINE"] = { "GUILD_BATTLETAG_FRIEND", "INTERACT_SUBSECTION_TITLE", "GUILD_PROMOTE", "OTHER_SUBSECTION_TITLE", "IGNORE", "GUILD_LEAVE", "CANCEL" },
	["RAID_TARGET_ICON"] = { "RAID_TARGET_8", "RAID_TARGET_7", "RAID_TARGET_6", "RAID_TARGET_5", "RAID_TARGET_4", "RAID_TARGET_3", "RAID_TARGET_2", "RAID_TARGET_1", "RAID_TARGET_NONE" },
	["CHAT_ROSTER"] = { "VOICE_CHAT_MICROPHONE_VOLUME", "VOICE_CHAT_SPEAKER_VOLUME", "VOICE_CHAT_USER_VOLUME", "SUBSECTION_SEPARATOR", "INTERACT_SUBSECTION_TITLE", "TARGET", "WHISPER", "CHAT_OWNER", "CHAT_PROMOTE", "CHAT_DEMOTE", "SUBSECTION_SEPARATOR", "OTHER_SUBSECTION_TITLE", "REPORT_PLAYER", "VOICE_CHAT_SETTINGS", "CLOSE" },
	["VEHICLE"] = { "RAID_TARGET_ICON", "SET_FOCUS", "OTHER_SUBSECTION_TITLE", "VEHICLE_LEAVE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "CANCEL" },
	["TARGET"] = { "RAID_TARGET_ICON", "SET_FOCUS", "ADD_FRIEND", "ADD_FRIEND_MENU", "OTHER_SUBSECTION_TITLE", "VOICE_CHAT", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "CANCEL" },
	["ARENAENEMY"] = { "SET_FOCUS", "OTHER_SUBSECTION_TITLE", "CANCEL" },
	["FOCUS"] = { "RAID_TARGET_ICON", "CLEAR_FOCUS", "OTHER_SUBSECTION_TITLE", "VOICE_CHAT", "LARGE_FOCUS", "MOVE_FOCUS_FRAME", "CANCEL" },
	["BOSS"] = { "RAID_TARGET_ICON", "SET_FOCUS", "OTHER_SUBSECTION_TITLE", "CANCEL" },
	["WORLD_STATE_SCORE"] = { "REPORT_PLAYER", "PVP_REPORT_AFK", "CANCEL" },
	["COMMUNITIES_WOW_MEMBER"] = { "ADD_FRIEND_MENU", "SUBSECTION_SEPARATOR", "VOICE_CHAT_MICROPHONE_VOLUME", "VOICE_CHAT_SPEAKER_VOLUME", "VOICE_CHAT_USER_VOLUME", "SUBSECTION_SEPARATOR", "INVITE", "SUGGEST_INVITE", "REQUEST_INVITE", "WHISPER", "IGNORE", "COMMUNITIES_LEAVE", "COMMUNITIES_KICK", "COMMUNITIES_MEMBER_NOTE", "COMMUNITIES_ROLE", "OTHER_SUBSECTION_TITLE", "REPORT_PLAYER" },
	["COMMUNITIES_GUILD_MEMBER"] = { "VOICE_CHAT_MICROPHONE_VOLUME", "VOICE_CHAT_SPEAKER_VOLUME", "VOICE_CHAT_USER_VOLUME", "SUBSECTION_SEPARATOR", "INVITE", "SUGGEST_INVITE", "REQUEST_INVITE", "WHISPER", "IGNORE", "OTHER_SUBSECTION_TITLE", "GUILD_PROMOTE", "GUILD_LEAVE", "REPORT_PLAYER" },
	["COMMUNITIES_MEMBER"] = { "COMMUNITIES_BATTLETAG_FRIEND", "SUBSECTION_SEPARATOR", "VOICE_CHAT_MICROPHONE_VOLUME", "VOICE_CHAT_SPEAKER_VOLUME", "VOICE_CHAT_USER_VOLUME", "SUBSECTION_SEPARATOR", "COMMUNITIES_LEAVE", "COMMUNITIES_KICK", "COMMUNITIES_MEMBER_NOTE", "COMMUNITIES_ROLE", "OTHER_SUBSECTION_TITLE", "REPORT_PLAYER"  },
	["COMMUNITIES_COMMUNITY"] = { "COMMUNITIES_CLEAR_UNREAD_NOTIFICATIONS", "COMMUNITIES_INVITE", "COMMUNITIES_SETTINGS", "COMMUNITIES_NOTIFICATION_SETTINGS", "COMMUNITIES_FAVORITE", "COMMUNITIES_LEAVE" },

	-- Second level menus
	["ADD_FRIEND_MENU"] = { "BATTLETAG_FRIEND", "CHARACTER_FRIEND" },
	["PVP_FLAG"] = { "PVP_ENABLE", "PVP_DISABLE"},
	["LOOT_METHOD"] = { "FREE_FOR_ALL", "ROUND_ROBIN", "MASTER_LOOTER", "GROUP_LOOT", "NEED_BEFORE_GREED", "CANCEL" };
	["LOOT_THRESHOLD"] = { "ITEM_QUALITY2_DESC", "ITEM_QUALITY3_DESC", "ITEM_QUALITY4_DESC", "CANCEL" },
	["OPT_OUT_LOOT_TITLE"] = { "OPT_OUT_LOOT_ENABLE", "OPT_OUT_LOOT_DISABLE"},
	["REPORT_PLAYER"] = { "REPORT_SPAM", "REPORT_BAD_LANGUAGE", "REPORT_BAD_NAME", "REPORT_BAD_GUILD_NAME", "REPORT_CHEATING", "REPORT_BAD_ARENA_TEAM_NAME"},
	["DUNGEON_DIFFICULTY"] = { "DUNGEON_DIFFICULTY1", "DUNGEON_DIFFICULTY2" },
	["RAID_DIFFICULTY"] = { "RAID_DIFFICULTY1", "RAID_DIFFICULTY2", "RAID_DIFFICULTY3", "LEGACY_RAID_SUBSECTION_TITLE", "LEGACY_RAID_DIFFICULTY1", "LEGACY_RAID_DIFFICULTY2" },
	["MOVE_PLAYER_FRAME"] = { "UNLOCK_PLAYER_FRAME", "LOCK_PLAYER_FRAME", "RESET_PLAYER_FRAME_POSITION", "PLAYER_FRAME_SHOW_CASTBARS" },
	["MOVE_TARGET_FRAME"] = { "UNLOCK_TARGET_FRAME", "LOCK_TARGET_FRAME", "RESET_TARGET_FRAME_POSITION" , "TARGET_FRAME_BUFFS_ON_TOP"},
	["MOVE_FOCUS_FRAME"] = { "UNLOCK_FOCUS_FRAME", "LOCK_FOCUS_FRAME", "FOCUS_FRAME_BUFFS_ON_TOP"},
	["VOICE_CHAT"] = { "VOICE_CHAT_MICROPHONE_VOLUME", "VOICE_CHAT_SPEAKER_VOLUME", "VOICE_CHAT_USER_VOLUME" },
	["COMMUNITIES_ROLE"] = { "COMMUNITIES_ROLE_OWNER", "COMMUNITIES_ROLE_LEADER", "COMMUNITIES_ROLE_MODERATOR", "COMMUNITIES_ROLE_MEMBER" },
};

UnitPopupShown = { {}, {}, {}, };

UnitLootMethod = {
	["freeforall"] = { text = LOOT_FREE_FOR_ALL, tooltipText = NEWBIE_TOOLTIP_UNIT_FREE_FOR_ALL };
	["roundrobin"] = { text = LOOT_ROUND_ROBIN, tooltipText = NEWBIE_TOOLTIP_UNIT_ROUND_ROBIN };
	["master"] = { text = LOOT_MASTER_LOOTER, tooltipText = NEWBIE_TOOLTIP_UNIT_MASTER_LOOTER };
	["group"] = { text = LOOT_GROUP_LOOT, tooltipText = NEWBIE_TOOLTIP_UNIT_GROUP_LOOT };
	["needbeforegreed"] = { text = LOOT_NEED_BEFORE_GREED, tooltipText = NEWBIE_TOOLTIP_UNIT_NEED_BEFORE_GREED };
};

local function UnitPopup_CheckAddSubsection(dropdownMenu, info, menuLevel, currentButton, previousButton, previousIndex, previousValue)
	if previousButton and previousButton.isSubsection then
		if not currentButton.isSubsection then
			if previousButton.isSubsectionSeparator then
				UIDropDownMenu_AddSeparator(menuLevel);
			end

			if previousButton.isSubsectionTitle and info then
				UnitPopup_AddDropDownButton(info, dropdownMenu, previousButton, previousValue, menuLevel);
			end
		else
			UnitPopupShown[menuLevel][previousIndex] = 0;
		end
	end
end

local g_mostRecentPopupMenu;

function UnitPopup_HasVisibleMenu()
	return g_mostRecentPopupMenu == UIDROPDOWNMENU_OPEN_MENU;
end

local function GetDropDownButtonText(button, dropdownMenu)
	if (type(button.text) == "function") then
		return button.text(dropdownMenu);
	end

	return button.text or "";
end

function UnitPopup_ShowMenu (dropdownMenu, which, unit, name, userData)
	g_mostRecentPopupMenu = nil;

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
		if( UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] == 1 and not UnitPopupButtons[value].isCloseCommand ) then
			count = count + 1;
		end
	end
	if ( count < 1 ) then
		return;
	end

	-- Note the fact that a popup is being shown. If this menu is hidden through other means, it's fine, the unitpopup system
	-- checks to see if this is visible.
	g_mostRecentPopupMenu = dropdownMenu;

	-- Determine which loot method and which loot threshold are selected and set the corresponding buttons to the same text
	dropdownMenu.selectedLootMethod = UnitLootMethod[GetLootMethod()].text;
	UnitPopupButtons["LOOT_METHOD"].text = dropdownMenu.selectedLootMethod;
	UnitPopupButtons["LOOT_METHOD"].tooltipText = UnitLootMethod[GetLootMethod()].tooltipText;
	dropdownMenu.selectedLootThreshold = _G["ITEM_QUALITY"..GetLootThreshold().."_DESC"];
	UnitPopupButtons["LOOT_THRESHOLD"].text = dropdownMenu.selectedLootThreshold;

	-- UnitPopupButtons["GARRISON_VISIT"].text = (C_Garrison.IsUsingPartyGarrison() and GARRISON_RETURN) or GARRISON_VISIT_LEADER;
	-- This allows player to view loot settings if he's not the leader
	local inParty = IsInGroup();
	local inInstance, instanceType = IsInInstance();
	local isLeader = UnitIsGroupLeader("player");
	local showLootOptions = inParty and isLeader;
	local lootOption = showLootOptions and 1 or nil;

	UnitPopupButtons["LOOT_METHOD"].nested = lootOption;
	UnitPopupButtons["LOOT_THRESHOLD"].nested = lootOption;

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

	local inPublicParty = IsInGroup(LE_PARTY_CATEGORY_INSTANCE);

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
	--local specIndex = GetSpecialization();
	local sex = UnitSex("player");
	--[[if ( specIndex) then
		local specID, specName = GetSpecializationInfo(specIndex, nil, nil, nil, sex);
		if ( specName ) then
			specPopupButton.text = format(LOOT_SPECIALIZATION_DEFAULT, specName);
		end
	end]]
	-- setup specialization coices for Loot Specialization
	--[[for index = 1, 4 do
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
	end]]

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
		local previousButton, previousIndex, previousValue;
		for index, value in ipairs(UnitPopupMenus[UIDROPDOWNMENU_MENU_VALUE]) do
			if( UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] == 1 ) then
				local cntButton = UnitPopupButtons[value];

				UnitPopup_CheckAddSubsection(dropdownMenu, info, UIDROPDOWNMENU_MENU_LEVEL, cntButton, previousButton, previousIndex, previousValue);

				-- Note, for the subsections, this info is 'created' later so that when the subsection is added retroactively, it doesn't overwrite or lose fields
				info = UIDropDownMenu_CreateInfo();
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
				if (cntButton.isSubsectionTitle) then
					info.tooltipTitle = UnitPopupButtons[value].text;
				else
					-- We need to call GetDropDownButtonText here in case the text is a function (e.g. IGNORE).
					info.tooltipTitle = GetDropDownButtonText(cntButton, dropdownMenu);
				end
				info.tooltipText = _G["NEWBIE_TOOLTIP_UNIT_"..value];

				if not cntButton.isSubsection then
					UnitPopup_AddDropDownButton(info, dropdownMenu, cntButton, value, UIDROPDOWNMENU_MENU_LEVEL);
				end

				previousButton = cntButton;
				previousIndex = index;
				previousValue = value;
			end
		end
		return;
	end

	UnitPopup_AddDropDownTitle(unit, name, userData);

	-- Set which menu is being opened
	OPEN_DROPDOWNMENUS[UIDROPDOWNMENU_MENU_LEVEL] = {which = dropdownMenu.which, unit = dropdownMenu.unit};
	-- Show the buttons which are used by this menu
	info = UIDropDownMenu_CreateInfo();
	local tooltipText;
	local previousButton, previousIndex, previousValue;
	for index, value in ipairs(UnitPopupMenus[which]) do
		if( UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] == 1 ) then
			local cntButton = UnitPopupButtons[value];

			UnitPopup_CheckAddSubsection(dropdownMenu, info, UIDROPDOWNMENU_MENU_LEVEL, cntButton, previousButton, previousIndex, previousValue);

			if not cntButton.isSubsection then
				UnitPopup_AddDropDownButton(info, dropdownMenu, cntButton, value);
			end

			previousButton = cntButton;
			previousIndex = index;
			previousValue = value;
				end
			end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
end

function UnitPopup_AddDropDownTitle(unit, name, userData)
	if ( unit or name ) then
		local info = UIDropDownMenu_CreateInfo();

		local titleText = name;
		if not titleText and unit then
			titleText = UnitName(unit);
		end

		info.text = titleText or UNKNOWN;
		info.isTitle = true;
		info.notCheckable = true;

		UIDropDownMenu_AddButton(info);
	end
end

local commandToRoleId = {
	["COMMUNITIES_ROLE_MEMBER"] = Enum.ClubRoleIdentifier.Member,
	["COMMUNITIES_ROLE_MODERATOR"] = Enum.ClubRoleIdentifier.Moderator,
	["COMMUNITIES_ROLE_LEADER"] = Enum.ClubRoleIdentifier.Leader,
	["COMMUNITIES_ROLE_OWNER"] = Enum.ClubRoleIdentifier.Owner
};

function UnitPopup_GetOverrideIsChecked(command, currentIsChecked, dropdownMenu)
	if command == "LARGE_FOCUS" then
		if GetCVarBool("fullSizeFocusFrame") then
			return true;
		end
	elseif commandToRoleId[command] ~= nil  then
		return dropdownMenu.clubMemberInfo.role == commandToRoleId[command];
	end

	-- If there was no override, use the current value
	return currentIsChecked;
end

function UnitPopup_UpdateButtonInfo(info)
	if info.value == "PVP_FLAG" then
		info.hasArrow = true;
	end
end

local function UnitPopup_GetGUID(menu)
	if menu.guid then
		return menu.guid;
	elseif menu.unit then
		return UnitGUID(menu.unit);
	elseif type(menu.userData) == "table" and menu.userData.guid then
		return menu.userData.guid;
	end
end

local function UnitPopup_TryCreatePlayerLocation(menu, guid)
	if menu.battlefieldScoreIndex then
		return PlayerLocation:CreateFromBattlefieldScoreIndex(menu.battlefieldScoreIndex);
	elseif menu.communityClubID and menu.communityStreamID and menu.communityEpoch and menu.communityPosition then
		return PlayerLocation:CreateFromCommunityChatData(menu.communityClubID, menu.communityStreamID, menu.communityEpoch, menu.communityPosition);
	elseif menu.communityClubID and not menu.communityStreamID then
		return PlayerLocation:CreateFromCommunityInvitation(menu.communityClubID, guid);
	elseif C_ChatInfo.IsValidChatLine(menu.lineID) then
		return PlayerLocation:CreateFromChatLineID(menu.lineID);
	elseif guid then
		return PlayerLocation:CreateFromGUID(guid);
	elseif menu.unit then
		return PlayerLocation:CreateFromUnit(menu.unit);
	end

	return nil;
end

function UnitPopup_AddDropDownButton(info, dropdownMenu, cntButton, buttonIndex, level)
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

	info.checked = UnitPopup_GetOverrideIsChecked(buttonIndex, info.checked, dropdownMenu);

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
		info.isTitle = nil;

		-- NOTE: UnitPopup_AddDropDownButton is called for both level 1 and 2 buttons, level 2 buttons already
		-- had a disable mechanism, so only set disabled to nil for level 1 buttons.
		-- All buttons can define IsDisabledFn to override behavior.
		-- NOTE: There are issues when both 'nested' and 'disabled' are true, the label on the menu won't respect
		-- the disabled state, but the arrow will.  Should fix this at some point.
		if cntButton.IsDisabledFn then
			info.disabled = cntButton.IsDisabledFn();
		else
		if (level == 1) then
			info.disabled = nil;
		end
		end
	end

	-- Setup newbie tooltips
	if (cntButton.isSubsectionTitle) then
		info.tooltipTitle = cntButton.text;
	else
		-- We need to call GetDropDownButtonText here in case the text is a function (e.g. IGNORE).
		info.tooltipTitle = GetDropDownButtonText(cntButton, dropdownMenu);
	end

	local tooltipText = _G["NEWBIE_TOOLTIP_UNIT_"..buttonIndex];
	if ( not tooltipText ) then
		tooltipText = cntButton.tooltipText;
	end

	info.tooltipText = tooltipText;
	info.customFrame = cntButton.customFrame;
	if info.customFrame then
		local guid = UnitPopup_GetGUID(dropdownMenu);
		local playerLocation = UnitPopup_TryCreatePlayerLocation(dropdownMenu, guid);
		local contextData = {
			guid = guid,
			playerLocation = playerLocation,
			voiceChannelID = dropdownMenu.voiceChannelID,
			voiceMemberID = dropdownMenu.voiceMemberID,
			voiceChannel = dropdownMenu.voiceChannel,
		};

		info.customFrame:SetContextData(contextData);
	end

	info.tooltipWhileDisabled = cntButton.tooltipWhileDisabled;
	info.noTooltipWhileEnabled = cntButton.noTooltipWhileEnabled;
	info.tooltipOnButton = cntButton.tooltipOnButton;
	info.tooltipInstruction = cntButton.tooltipInstruction;
	info.tooltipWarning = cntButton.tooltipWarning;

	UnitPopup_UpdateButtonInfo(info);

	UIDropDownMenu_AddButton(info, level);
end

local function UnitPopup_HasBattleTag()
	if BNFeaturesEnabledAndConnected() then
		local _, battleTag = BNGetInfo();
		if battleTag then
			return true;
		end
	end
end

local function UnitPopup_GetLFGCategoryForLFGSlot(lfgSlot)
	if lfgSlot then
		return GetLFGCategoryForID(lfgSlot);
	end
end

local function UnitPopup_IsPlayerOffline(menu)
	if menu.clubMemberInfo then
		local presence = menu.clubMemberInfo.presence;
		if presence == Enum.ClubMemberPresence.Offline or presence == Enum.ClubMemberPresence.Unknown then
			return true;
		end
	end

	return false;
end

local function UnitPopup_IsPlayerMobile(menu)
	if menu.clubMemberInfo then
		local presence = menu.clubMemberInfo.presence;
		if presence == Enum.ClubMemberPresence.Offline or presence == Enum.ClubMemberPresence.Unknown then
			return true;
		end
	end

	return false;
end

local function UnitPopup_GetIsLocalPlayer(menu)
	if menu.isSelf then
		return true;
	end

	local guid = UnitPopup_GetGUID(menu);
	if guid and C_AccountInfo.IsGUIDRelatedToLocalAccount(guid) then
		return true;
	end

	if menu.clubMemberInfo and menu.clubMemberInfo.isSelf then
		return true;
	end

	return false;
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
	local guid = UnitPopup_GetGUID(dropdownMenu);
	local playerLocation = UnitPopup_TryCreatePlayerLocation(dropdownMenu, guid);
	local haveBattleTag = UnitPopup_HasBattleTag();
	local isOffline = UnitPopup_IsPlayerOffline(dropdownMenu);

	local isLocalPlayer = UnitPopup_GetIsLocalPlayer(dropdownMenu);

	for index, value in ipairs(UnitPopupMenus[UIDROPDOWNMENU_MENU_VALUE] or UnitPopupMenus[dropdownMenu.which]) do
		local shown = true;
		if ( value == "TRADE" ) then
			if ( not canCoop or not isPlayer ) then
				shown = false;
			end
		elseif ( value == "ADD_FRIEND" ) then
			if ( haveBattleTag or not canCoop or not isPlayer or not UnitIsSameServer(dropdownMenu.unit) or C_FriendList.GetFriendInfo(UnitName(dropdownMenu.unit)) ) then
				shown = false;
			end
		elseif ( value == "ADD_FRIEND_MENU" ) then
			local hasClubInfo = dropdownMenu.clubInfo ~= nil and dropdownMenu.clubMemberInfo ~= nil;
			if ( not haveBattleTag or (not isPlayer and not hasClubInfo) ) then
				shown = false;
			end
		elseif ( value == "GUILD_BATTLETAG_FRIEND" ) then
			if ( not haveBattleTag or UnitName("player" ) == dropdownMenu.name ) then
				shown = false;
			end
		elseif ( value == "INVITE" or value == "SUGGEST_INVITE" or value == "REQUEST_INVITE" ) then
			if ( isLocalPlayer or isOffline ) then
				shown = false;
			elseif ( dropdownMenu.unit ) then
				if ( not canCoop  or UnitIsUnit("player", dropdownMenu.unit) ) then
					shown = false;
				end
			elseif ( (dropdownMenu == ChannelRosterDropDown) ) then
				if ( UnitInRaid(dropdownMenu.name) ~= nil ) then
					shown = false;
				end
			elseif ( dropdownMenu == FriendsDropDown and dropdownMenu.isMobile ) then
				shown = false;
			elseif ( dropdownMenu == GuildMenuDropDown and dropdownMenu.isMobile ) then
				shown = false;
			else
				if ( dropdownMenu.name == UnitName("party1") or
					 dropdownMenu.name == UnitName("party2") or
					 dropdownMenu.name == UnitName("party3") or
					 dropdownMenu.name == UnitName("party4") or
					 dropdownMenu.name == UnitName("player")) then
					shown = false;
				end
			end

			local displayedInvite = GetDisplayedInviteType(guid);
			if ( value ~= displayedInvite ) then
				shown = false;
			end
		elseif ( value == "BN_INVITE" or value == "BN_SUGGEST_INVITE" or value == "BN_REQUEST_INVITE" ) then
			local bnetIDAccount, accountName, battleTag, isBattleTag, characterName, bnetIDGameAccount = BNGetFriendInfoByID(dropdownMenu.bnetIDAccount);
			if not bnetIDGameAccount then
				shown = false;
			else
				local guid = select(20, BNGetGameAccountInfo(bnetIDGameAccount));
				local inviteType = GetDisplayedInviteType(guid);
				if ( "BN_"..inviteType ~= value ) then
					shown = false;
				elseif ( not dropdownMenu.bnetIDAccount or not BNFeaturesEnabledAndConnected() ) then
					shown = false;
				elseif ( UnitInParty(characterName) or UnitInRaid(characterName) ) then
					shown = false;
				end
			end
		elseif ( value == "FOLLOW" ) then
			if ( not canCoop or not isPlayer ) then
				shown = false;
			end
		elseif ( value == "WHISPER" ) then
			local whisperIsLocalPlayer = isLocalPlayer;
			if not whisperIsLocalPlayer then
			local playerName, playerServer = UnitName("player");
				whisperIsLocalPlayer = (dropdownMenu.name == playerName and dropdownMenu.server == playerServer);
				end

			if whisperIsLocalPlayer or (isOffline and not dropdownMenu.bnetIDAccount) or ( dropdownMenu.unit and (not canCoop or not isPlayer)) or (dropdownMenu.bnetIDAccount and not BNIsFriend(dropdownMenu.bnetIDAccount)) then
				shown = false;
			end
		elseif ( value == "DUEL" ) then
			if ( UnitCanAttack("player", dropdownMenu.unit) or not isPlayer ) then
				shown = false;
			end
		elseif ( value == "PET_BATTLE_PVP_DUEL" ) then
			--if ( not UnitCanPetBattle("player", dropdownMenu.unit) or not isPlayer ) then
			if ( true ) then
				shown = false;
			end
		elseif ( value == "INSPECT" ) then
			if ( not dropdownMenu.unit or UnitCanAttack("player", dropdownMenu.unit) or not isPlayer ) then
				shown = false;
			end
		elseif ( value == "IGNORE" ) then
			if ( dropdownMenu.name == UnitName("player") or ( dropdownMenu.unit and not isPlayer ) ) then
				shown = false;
			end
		elseif ( value == "REMOVE_FRIEND" ) then
			if ( not dropdownMenu.friendsList ) then
				shown = false;
			end
		elseif ( value == "SET_NOTE" ) then
			if ( not dropdownMenu.friendsList ) then
				shown = false;
			end
		elseif ( value == "BN_SET_NOTE" ) then
			if ( not dropdownMenu.friendsList ) then
				shown = false;
			end
		elseif ( value == "BN_VIEW_FRIENDS" ) then
			if ( not dropdownMenu.friendsList ) then
				shown = false;
			end
		elseif ( value == "BN_REMOVE_FRIEND" ) then
			if ( not dropdownMenu.friendsList ) then
				shown = false;
			end
		elseif ( value == "REPORT_PLAYER" ) then
			if not playerLocation or not playerLocation:IsValid() or not C_ChatInfo.CanReportPlayer(playerLocation) then
				shown = false;
			end
		elseif ( value == "REPORT_SPAM" ) then
			if not playerLocation:IsChatLineID() and not playerLocation:IsCommunityInvitation() then
				shown = false;
			end
		elseif ( value == "REPORT_CHEATING" ) then
			if dropdownMenu.bnetIDAccount or not playerLocation or playerLocation:IsBattleNetGUID() then
				shown = false;
			end
		elseif ( value == "POP_OUT_CHAT" ) then
			if ( (dropdownMenu.chatType ~= "WHISPER" and dropdownMenu.chatType ~= "BN_WHISPER") or dropdownMenu.chatTarget == UnitName("player") or
				FCFManager_GetNumDedicatedFrames(dropdownMenu.chatType, dropdownMenu.chatTarget) > 0 ) then
				shown = false;
			end
		elseif ( value == "TARGET" ) then
			-- We don't want to show a menu option that will end up being blocked
			if ( InCombatLockdown() or not issecure() ) then
				shown = false;
			elseif ( dropdownMenu.isMobile ) then
				shown = false;
			end
		elseif ( value == "BN_TARGET" ) then
			-- We don't want to show a menu option that will end up being blocked
			if ( not dropdownMenu.bnetIDAccount or not BNIsFriend(dropdownMenu.bnetIDAccount) or InCombatLockdown() or not issecure() ) then
				shown = false;
			end
		elseif ( value == "PROMOTE" ) then
			if ( not inParty or not isLeader or not isPlayer) then
				shown = false;
			end
		elseif ( value == "PROMOTE_GUIDE" ) then
			--if ( not inParty or not isLeader or not isPlayer or not HasLFGRestrictions()) then
			if ( true ) then
				shown = false;
			end
		elseif ( value == "GUILD_PROMOTE" ) then
			if ( not IsGuildLeader() or dropdownMenu.name == UnitName("player") ) then
				shown = false;
			end
		elseif ( value == "GUILD_LEAVE" ) then
			if ( dropdownMenu.name ~= UnitName("player") ) then
				shown = false;
			end
		elseif ( value == "TEAM_PROMOTE" ) then
			if ( dropdownMenu.name == UnitName("player") or not PVPTeamDetails:IsShown() ) then
				shown = false;
			elseif ( PVPTeamDetails:IsShown() and not IsArenaTeamCaptain(PVPTeamDetails.team) ) then
				shown = false;
			end
		elseif ( value == "TEAM_KICK" ) then
			if ( dropdownMenu.name == UnitName("player") or not PVPTeamDetails:IsShown() ) then
				shown = false;
			elseif ( PVPTeamDetails:IsShown() and not IsArenaTeamCaptain(PVPTeamDetails.team) ) then
				shown = false;
			end
		elseif ( value == "TEAM_LEAVE" ) then
			if (dropdownMenu.name ~= UnitName("player") or not PVPTeamDetails:IsShown() ) then
				shown = false;
			end
		elseif ( value == "TEAM_DISBAND" ) then
			if ( PVPTeamDetails:IsShown() and (not IsArenaTeamCaptain(PVPTeamDetails.team) or dropdownMenu.name ~= UnitName("player")) ) then
				shown = false;
			end
		elseif ( value == "UNINVITE" ) then
			if ( not inParty or not isPlayer or not isLeader or (instanceType == "pvp") or (instanceType == "arena") ) then
				shown = false;
			end
		elseif ( value == "VOTE_TO_KICK" ) then
			--if ( not inParty or not isPlayer or (instanceType == "pvp") or (instanceType == "arena") or (not HasLFGRestrictions()) or IsInActiveWorldPVP() ) then
			if ( true ) then
				shown = false;
			end
		elseif ( value == "LEAVE" ) then
			if ( not inParty or IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or (instanceType == "pvp") or (instanceType == "arena") ) then
				shown = false;
			end
		elseif ( value == "INSTANCE_LEAVE" ) then
			--if ( not inParty or not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or IsPartyWorldPVP() or instanceType == "pvp" or instanceType == "arena" or partyLFGCategory == LE_LFG_CATEGORY_WORLDPVP ) then
			if ( true ) then
				shown = false;
			end
		elseif ( value == "FREE_FOR_ALL" ) then
			if ( (inParty == 0) or ((isLeader == 0) and (GetLootMethod() ~= "freeforall")) ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "ROUND_ROBIN" ) then
			if ( (inParty == 0) or ((isLeader == 0) and (GetLootMethod() ~= "roundrobin")) ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "MASTER_LOOTER" ) then
			if ( (inParty == 0) or ((isLeader == 0) and (GetLootMethod() ~= "master")) ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "GROUP_LOOT" ) then
			if ( (inParty == 0) or ((isLeader == 0) and (GetLootMethod() ~= "group")) ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "NEED_BEFORE_GREED" ) then
			if ( (inParty == 0) or ((isLeader == 0) and (GetLootMethod() ~= "needbeforegreed")) ) then
				UnitPopupShown[index] = 0;
			end
		elseif ( value == "LOOT_THRESHOLD" ) then
			if ( not inParty ) then
				shown = false;
			end
		elseif ( value == "MOVE_PLAYER_FRAME" ) then
			if ( dropdownMenu ~= PlayerFrameDropDown ) then
				shown = false;
			end
		elseif ( value == "LOCK_PLAYER_FRAME" ) then
			if ( not PLAYER_FRAME_UNLOCKED ) then
				shown = false;
			end
		elseif ( value == "UNLOCK_PLAYER_FRAME" ) then
			if ( PLAYER_FRAME_UNLOCKED ) then
				shown = false;
			end
		elseif ( value == "MOVE_TARGET_FRAME" ) then
			if ( dropdownMenu ~= TargetFrameDropDown ) then
				shown = false;
			end
		elseif ( value == "LOCK_TARGET_FRAME" ) then
			if ( not TARGET_FRAME_UNLOCKED ) then
				shown = false;
			end
		elseif ( value == "UNLOCK_TARGET_FRAME" ) then
			if ( TARGET_FRAME_UNLOCKED ) then
				shown = false;
			end
	   elseif ( value == "LARGE_FOCUS" ) then
			if ( dropdownMenu ~= FocusFrameDropDown ) then
				shown = false;
			end
	   elseif ( value == "MOVE_FOCUS_FRAME" ) then
			if ( dropdownMenu ~= FocusFrameDropDown ) then
				shown = false;
			end
		elseif ( value == "LOCK_FOCUS_FRAME" ) then
			if ( FocusFrame_IsLocked() ) then
				shown = false;
			end
		elseif ( value == "UNLOCK_FOCUS_FRAME" ) then
			if ( not FocusFrame_IsLocked() ) then
				shown = false;
			end
		elseif ( value == "OPT_OUT_LOOT_TITLE" ) then
			if ( not inParty or ( inParty and GetLootMethod() == "freeforall" ) ) then
				shown = false;
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
				shown = false;
			end
		elseif ( value == "LOOT_METHOD" ) then
			if ( not inParty ) then
				shown = false;
			end
		elseif ( value == "SELECT_LOOT_SPECIALIZATION" ) then
			if ( not GetSpecialization() ) then
				shown = false;
			end
		elseif ( strsub(value, 1, 20) == "LOOT_SPECIALIZATION_" ) then
			if ( UnitPopupButtons[value].specializationID == -1 ) then
				shown = false;
			end
		elseif ( value == "CONVERT_TO_RAID" ) then
			if ( not inParty or inRaid or not isLeader or IsInGroup(LE_PARTY_CATEGORY_INSTANCE) ) then
				shown = false;
			end
		elseif ( value == "CONVERT_TO_PARTY" ) then
			if ( not inRaid or not isLeader or IsInGroup(LE_PARTY_CATEGORY_INSTANCE) ) then
				shown = false;
			end
		elseif ( value == "RESET_INSTANCES" ) then
			if ( ( inParty and not isLeader ) or inInstance) then
				shown = false;
			end
		elseif ( value == "RESET_CHALLENGE_MODE" ) then
			if ( not inInstance or not C_ChallengeMode.IsChallengeModeActive() or ( inParty and not isLeader ) ) then
				shown = false;
			end
		elseif ( value == "DUNGEON_DIFFICULTY" ) then
			-- Dungeon Difficulty can only be set in Burning Crusade or higher
			if ( GetClassicExpansionLevel() < LE_EXPANSION_BURNING_CRUSADE or (UnitLevel("player") < 65 and GetDungeonDifficultyID() == UnitPopupButtons[value].defaultDifficultyID )) then
				shown = false;
			end
		elseif ( value == "RAID_DIFFICULTY" ) then
			--if ( UnitLevel("player") < MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_WRATH_OF_THE_LICH_KING] and GetRaidDifficultyID() == UnitPopupButtons[value].defaultDifficultyID ) then
				shown = false;
			--end
		elseif ( value == "RAID_LEADER" ) then
			if ( not isLeader or not isPlayer or UnitIsGroupLeader(dropdownMenu.unit)or not dropdownMenu.name ) then
				shown = false;
			end
		elseif ( value == "RAID_PROMOTE" ) then
			if ( not isLeader or not isPlayer or IsEveryoneAssistant() ) then
				shown = false;
			elseif ( isLeader ) then
				if ( UnitIsGroupLeader(dropdownMenu.unit) or UnitIsGroupAssistant(dropdownMenu.unit) ) then
					shown = false;
				end
			end
		elseif ( value == "RAID_DEMOTE" ) then
			if ( ( not isLeader and not isAssistant ) or not dropdownMenu.name or not isPlayer ) then
				shown = false;
			elseif ( not GetPartyAssignment("MAINTANK", dropdownMenu.name, 1) and not GetPartyAssignment("MAINASSIST", dropdownMenu.name, 1) ) then
				if ( not isLeader  and isAssistant and UnitIsGroupAssistant(dropdownMenu.unit) ) then
					shown = false;
				elseif ( isLeader or isAssistant ) then
					if ( UnitIsGroupLeader(dropdownMenu.unit) or not UnitIsGroupAssistant(dropdownMenu.unit) or IsEveryoneAssistant()) then
						shown = false;
					end
				end
			end
		elseif ( value == "RAID_MAINTANK" ) then
			-- We don't want to show a menu option that will end up being blocked
            if ( not issecure() or (not isLeader and not isAssistant) or not isPlayer or GetPartyAssignment("MAINTANK", dropdownMenu.unit) ) then
				shown = false;
			end
		elseif ( value == "RAID_MAINASSIST" ) then
			-- We don't want to show a menu option that will end up being blocked
            if ( not issecure() or (not isLeader and not isAssistant) or not isPlayer or GetPartyAssignment("MAINASSIST", dropdownMenu.unit) ) then
				shown = false;
			end
		elseif ( value == "RAID_REMOVE" ) then
			if ( not isPlayer ) then
				shown = false;
			elseif ( ( not isLeader and not isAssistant ) or not dropdownMenu.name or (instanceType == "pvp") or (instanceType == "arena") ) then
				shown = false;
			elseif ( not isLeader and isAssistant and UnitIsGroupAssistant(dropdownMenu.unit) ) then
				shown = false;
			elseif ( isLeader and UnitIsUnit(dropdownMenu.unit, "player") ) then
				shown = false;
			end
		elseif ( value == "PVP_REPORT_AFK" ) then
			if ( not inBattleground or GetCVar("enablePVPNotifyAFK") == "0" ) then
				shown = false;
			elseif ( dropdownMenu.unit ) then
				if ( UnitIsUnit(dropdownMenu.unit,"player") ) then
					shown = false;
				elseif ( not UnitInBattleground(dropdownMenu.unit) and not IsInActiveWorldPVP(dropdownMenu.unit) ) then
					shown = false;
				elseif ( (PlayerIsPVPInactive(dropdownMenu.unit)) ) then
					shown = false;
				end
			elseif ( dropdownMenu.name ) then
				if ( dropdownMenu.name == UnitName("player") ) then
					shown = false;
--				elseif ( not UnitInBattleground(dropdownMenu.name) and not IsInActiveWorldPVP(dropdownMenu.name) ) then
				elseif ( not UnitInBattleground(dropdownMenu.name) ) then
					shown = false;
				end
			end
		elseif ( value == "RAF_SUMMON" ) then
			if( not IsReferAFriendLinked(dropdownMenu.unit) ) then
				shown = false;
			end
		elseif ( value == "RAF_GRANT_LEVEL" ) then
			if( not IsReferAFriendLinked(dropdownMenu.unit) ) then
				shown = false;
			end
		elseif ( value == "PET_RENAME" ) then
			if( not PetCanBeAbandoned() or not PetCanBeRenamed() ) then
				shown = false;
			end
		elseif ( value == "PET_ABANDON" ) then
			if( not PetCanBeAbandoned() or not PetHasActionBar() ) then
				shown = false;
			end
		elseif ( value == "PET_DISMISS" ) then
			if( ( PetCanBeAbandoned() and not IsSpellKnown(HUNTER_DISMISS_PET) ) or not PetCanBeDismissed() ) then
				shown = false;
			end
		elseif ( strsub(value, 1, 12)  == "RAID_TARGET_" ) then
			-- Task #30755. Let any party member mark targets
			-- Task 34335 - But only raid leaders can mark targets.
			if ( inRaid and not isLeader and not isAssistant ) then
				shown = false;
			end
			if ( not (dropdownMenu.which == "SELF") ) then
				if ( UnitExists("target") and not UnitPlayerOrPetInParty("target") and not UnitPlayerOrPetInRaid("target") ) then
					if ( UnitIsPlayer("target") and (not UnitCanCooperate("player", "target") and not UnitIsUnit("target", "player")) ) then
						shown = false;
					end
				end
			end
		elseif ( value == "CHAT_PROMOTE" ) then
			if ( dropdownMenu.channelType ~= Enum.ChatChannelType.Custom ) then
				shown = false;
			else
				if ( not IsDisplayChannelOwner() or dropdownMenu.owner or dropdownMenu.moderator or dropdownMenu.name == UnitName("player") ) then -- TODO: Name matching is wrong here, needs full name comparison
					shown = false;
				end
			end
		elseif ( value == "CHAT_DEMOTE" ) then
			if ( dropdownMenu.channelType ~= Enum.ChatChannelType.Custom ) then
				shown = false;
			else
				if ( not IsDisplayChannelOwner() or dropdownMenu.owner or not dropdownMenu.moderator or dropdownMenu.name == UnitName("player") ) then -- TODO: Name matching is wrong here, needs full name comparison
					shown = false;
				end
			end
		elseif ( value == "CHAT_OWNER" ) then
			if ( dropdownMenu.channelType ~= Enum.ChatChannelType.Custom ) then
				shown = false;
			else
				if ( not IsDisplayChannelOwner() or dropdownMenu.owner or dropdownMenu.name == UnitName("player") ) then -- TODO: Name matching needs full name comparison
					shown = false;
				end
			end
		elseif ( value == "CHAT_KICK" ) then
			shown = false;
		elseif ( value == "CHAT_LEAVE" ) then
			if ( not dropdownMenu.active or dropdownMenu.group) then
				shown = false;
			end
		elseif ( value == "VEHICLE_LEAVE" ) then
			if ( not CanExitVehicle() ) then
				shown = false;
			end
		elseif ( value == "GARRISON_VISIT" ) then
			if ( not C_Garrison.IsVisitGarrisonAvailable() ) then
				shown = false;
			end
		elseif ( value == "REPORT_BAD_GUILD_NAME" ) then
			if ( not dropdownMenu.unit or not GetGuildInfo(dropdownMenu.unit) ) then
				shown = false;
			end
		elseif ( value == "REPORT_BAD_ARENA_TEAM_NAME" ) then
			if not dropdownMenu.teamName then
				shown = false;
			end
		elseif ( value == "VOICE_CHAT" ) then
			if not C_VoiceChat.CanPlayerUseVoiceChat() or not isLocalPlayer and not C_VoiceChat.IsPlayerUsingVoice(playerLocation) then
				shown = false;
			end
		elseif value == "VOICE_CHAT_MICROPHONE_VOLUME" then
			if not C_VoiceChat.CanPlayerUseVoiceChat() or not isLocalPlayer then
				shown = false;
			end
		elseif value == "VOICE_CHAT_SPEAKER_VOLUME" then
			if not C_VoiceChat.CanPlayerUseVoiceChat() or not isLocalPlayer then
				shown = false;
			end
		elseif value == "VOICE_CHAT_SETTINGS" then
			if not C_VoiceChat.CanPlayerUseVoiceChat() or not isLocalPlayer then
				shown = false;
			end
		elseif value == "VOICE_CHAT_USER_VOLUME" then
			if not C_VoiceChat.CanPlayerUseVoiceChat() or isLocalPlayer or not C_VoiceChat.IsPlayerUsingVoice(playerLocation) then
				shown = false;
			end
		elseif value == "COMMUNITIES_LEAVE" then
			if dropdownMenu.clubInfo == nil or dropdownMenu.clubMemberInfo == nil or not dropdownMenu.clubMemberInfo.isSelf then
				shown = false;
			end
		elseif value == "COMMUNITIES_BATTLETAG_FRIEND" then
			if dropdownMenu.clubInfo == nil
				or dropdownMenu.clubMemberInfo == nil
				or dropdownMenu.clubMemberInfo.isSelf then
				shown = false;
			end
		elseif value == "COMMUNITIES_KICK" then
			if dropdownMenu.clubInfo == nil
				or dropdownMenu.clubMemberInfo == nil
				or dropdownMenu.clubMemberInfo.isSelf
				or not CommunitiesUtil.CanKickClubMember(dropdownMenu.clubPrivileges, dropdownMenu.clubMemberInfo) then
				shown = false;
			end
		elseif value == "COMMUNITIES_MEMBER_NOTE" then
			if dropdownMenu.clubInfo == nil
				or dropdownMenu.clubMemberInfo == nil
				or (dropdownMenu.clubMemberInfo.isSelf and not dropdownMenu.clubPrivileges.canSetOwnMemberNote)
				or (not dropdownMenu.clubMemberInfo.isSelf and not dropdownMenu.clubPrivileges.canSetOtherMemberNote) then
				shown = false;
			end
		elseif value == "COMMUNITIES_ROLE" then
			if not dropdownMenu.clubAssignableRoles or #dropdownMenu.clubAssignableRoles == 0 then
				shown = false;
			end
		elseif value == "DELETE_COMMUNITIES_MESSAGE" then
			local clubId = dropdownMenu.communityClubID;
			local streamId = dropdownMenu.communityStreamID;
			if clubId and streamId and dropdownMenu.communityEpoch and dropdownMenu.communityPosition then
				local messageId = { epoch = dropdownMenu.communityEpoch, position = dropdownMenu.communityPosition };
				local function CanDestroyMessage(clubId, streamId, messageId)
					local messageInfo = C_Club.GetMessageInfo(clubId, streamId, messageId);
					if not messageInfo or messageInfo.destroyed then
						return false;
					end

					local privileges = C_Club.GetClubPrivileges(clubId);
					if not messageInfo.author.isSelf and not privileges.canDestroyOtherMessage then
						return false;
					elseif messageInfo.author.isSelf and not privileges.canDestroyOwnMessage then
						return false;
					end

					return true;
				end

				if not CanDestroyMessage(clubId, streamId, messageId) then
					shown = false;
				end
			else
				shown = false;
		end
		elseif value == "COMMUNITIES_INVITE" then
			if dropdownMenu.clubInfo then
				local privileges = C_Club.GetClubPrivileges(dropdownMenu.clubInfo.clubId);
				if not privileges.canSendInvitation then
					shown = false;
	end
			else
				shown = false;
			end
		elseif value == "COMMUNITIES_SETTINGS" then
			if dropdownMenu.clubInfo then
				local privileges = C_Club.GetClubPrivileges(dropdownMenu.clubInfo.clubId);
				local hasCommunitySettingsPrivilege = privileges.canSetName or privileges.canSetDescription or privileges.canSetAvatar or privileges.canSetBroadcast;
				if not hasCommunitySettingsPrivilege then
					shown = false;
				end
			else
				shown = false;
			end
		elseif commandToRoleId[value] ~= nil then
			if not dropdownMenu.clubAssignableRoles or not tContains(dropdownMenu.clubAssignableRoles, commandToRoleId[value]) then
				shown = false;
			end
		end
		UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = shown and 1 or 0;
	end
end

local function UnitPopup_IsEnabled(dropdownFrame, unitPopupButton)
	if unitPopupButton.isUninteractable then
		return false;
	end

	if (unitPopupButton.dist and unitPopupButton.dist > 0) and not CheckInteractDistance(dropdownFrame.unit, unitPopupButton.dist) then
		return false;
	end

	if unitPopupButton.disabledInKioskMode and Kiosk.IsEnabled() then
		return false;
	end

	return true;
end

function UnitPopup_OnUpdate (elapsed)
	if ( not DropDownList1:IsShown() ) then
		return;
	end

	if ( not UnitPopup_HasVisibleMenu() ) then
			return;
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
					local enable = UnitPopup_IsEnabled(dropdownFrame, UnitPopupButtons[value]);
					local notClickable = false;

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
					elseif ( value == "UNINVITE" ) then
						if ( not inParty or not isLeader or (instanceType == "pvp") or (instanceType == "arena") ) then
							enable = false;
						end
					elseif ( value == "BN_INVITE" or value == "BN_SUGGEST_INVITE" or value == "BN_REQUEST_INVITE" ) then
						if ( not currentDropDown.bnetIDAccount or not CanGroupWithAccount(currentDropDown.bnetIDAccount) ) then
							enable = false;
						end
					elseif ( value == "BN_TARGET" ) then
						if ( not currentDropDown.bnetIDAccount) then
							enable = false;
						else
							local _, _, _, _, _, _, client, _, _, _, _, _, _, _, _, wowProjectID = BNGetFriendInfoByID(currentDropDown.bnetIDAccount);
							if (client ~= BNET_CLIENT_WOW or wowProjectID ~= WOW_PROJECT_ID) then
								enable = false;
							end
						end
					elseif ( value == "VOTE_TO_KICK" ) then
						--if ( not inParty or not HasLFGRestrictions() ) then
						if ( true ) then
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
						if ( not isLeader ) then
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
						if ( ( inParty and not isLeader ) or inInstance ) then
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
						if ( ( inParty and not isLeader ) or inInstance ) then
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
						if ( UIDROPDOWNMENU_INIT_MENU.unit ~= nil ) then
						if ( not UnitCanCooperate("player", UIDROPDOWNMENU_INIT_MENU.unit) ) then
							enable = false;
						else
							-- disable if player is from another realm or already on friends list
								if ( not UnitIsSameServer(UIDROPDOWNMENU_INIT_MENU.unit) or C_FriendList.GetFriendInfo(UnitName(UIDROPDOWNMENU_INIT_MENU.unit)) ) then
								enable = false;
							end
						end
                    --[[elseif ( value == "MASTER_LOOTER" ) then
						if (not IsInGuildGroup()) then
	                        enable = false;]]
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
	local clubInfo = dropdownFrame.clubInfo;
	local clubMemberInfo = dropdownFrame.clubMemberInfo;

	if ( server and ((not unit and GetNormalizedRealmName() ~= server) or (unit and UnitRealmRelationship(unit) ~= LE_REALM_RELATION_SAME)) ) then
		fullname = name.."-"..server;
	end

	local guid = UnitPopup_GetGUID(dropdownFrame);
	local playerLocation = UnitPopup_TryCreatePlayerLocation(dropdownFrame, guid);

	local inParty = IsInGroup();
	local isLeader = UnitIsGroupLeader("player");
	local isAssistant = UnitIsGroupAssistant("player");

	if ( button == "TRADE" ) then
		InitiateTrade(unit);
	elseif ( button == "WHISPER" ) then
		if ( dropdownFrame.bnetIDAccount ) then
			ChatFrame_SendBNetTell(fullname);
		else
			ChatFrame_SendTell(fullname, dropdownFrame.chatFrame);
		end
	elseif ( button == "INSPECT" ) then
		InspectUnit(unit);
	elseif ( button == "TARGET" ) then
		TargetUnit(fullname, true);
	elseif ( button == "IGNORE" ) then
		C_FriendList.AddOrDelIgnore(fullname);
	elseif ( button == "REPORT_SPAM" ) then
		PlayerReportFrame:InitiateReport(PLAYER_REPORT_TYPE_SPAM, fullname, playerLocation)
	elseif ( button == "REPORT_BAD_LANGUAGE" ) then
		PlayerReportFrame:InitiateReport(PLAYER_REPORT_TYPE_LANGUAGE, fullname, playerLocation)
	elseif ( button == "REPORT_BAD_NAME" ) then
		PlayerReportFrame:InitiateReport(PLAYER_REPORT_TYPE_BAD_PLAYER_NAME, fullname, playerLocation)
	elseif ( button == "REPORT_BAD_GUILD_NAME" ) then
		PlayerReportFrame:InitiateReport(PLAYER_REPORT_TYPE_BAD_GUILD_NAME, fullname, playerLocation)
	elseif ( button == "REPORT_BAD_ARENA_TEAM_NAME" ) then
		SetPendingReportArenaTeamName(dropdownFrame.teamName);
		PlayerReportFrame:InitiateReport(PLAYER_REPORT_TYPE_BAD_ARENA_TEAM_NAME, fullname, playerLocation)
	elseif ( button == "REPORT_PET" ) then
		SetPendingReportPetTarget(unit);
		StaticPopup_Show("CONFIRM_REPORT_PET_NAME", fullname);
	elseif ( button == "REPORT_BATTLE_PET" ) then
		C_PetBattles.SetPendingReportTargetFromUnit(unit);
		StaticPopup_Show("CONFIRM_REPORT_BATTLEPET_NAME", fullname);
	elseif ( button == "REPORT_CHEATING" ) then
		PlayerReportFrame:InitiateReport(PLAYER_REPORT_TYPE_CHEATING, fullname, playerLocation);
	elseif ( button == "POP_OUT_CHAT" ) then
		FCF_OpenTemporaryWindow(dropdownFrame.chatType, dropdownFrame.chatTarget, dropdownFrame.chatFrame, true);
	elseif ( button == "DUEL" ) then
		StartDuel(unit, true);
	elseif ( button == "PET_BATTLE_PVP_DUEL" ) then
		C_PetBattles.StartPVPDuel(unit, true);
	elseif ( button == "INVITE" or button == "SUGGEST_INVITE" ) then
		InviteToGroup(fullname);
	elseif ( button == "REQUEST_INVITE" ) then
		RequestInviteFromUnit(fullname);
	elseif ( button == "UNINVITE" or button == "VOTE_TO_KICK" ) then
		UninviteUnit(fullname, nil, 1);
	elseif ( button == "REMOVE_FRIEND" ) then
		if(not C_FriendList.RemoveFriend(fullname)) then
			UIErrorsFrame:AddExternalErrorMessage(ERR_FRIEND_NOT_FOUND);
		end
	elseif ( button == "SET_NOTE" ) then
		FriendsFrame.NotesID = fullname;
		StaticPopup_Show("SET_FRIENDNOTE", fullname);
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
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
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	elseif ( button == "BN_VIEW_FRIENDS" ) then
		FriendsFriendsFrame_Show(dropdownFrame.bnetIDAccount);
	elseif ( button == "BN_INVITE" or button == "BN_SUGGEST_INVITE" or button == "BN_REQUEST_INVITE" ) then
		FriendsFrame_BattlenetInvite(nil, dropdownFrame.bnetIDAccount);
	elseif ( button == "BN_TARGET" ) then
		local bnetIDAccount, accountName, battleTag, isBattleTag, characterName = BNGetFriendInfoByID(dropdownFrame.bnetIDAccount);
		if ( characterName ) then
			TargetUnit(characterName);
		end
	elseif ( button == "PROMOTE" or button == "PROMOTE_GUIDE" ) then
		PromoteToLeader(unit, 1);
	elseif ( button == "GUILD_PROMOTE" ) then
		local dialog = StaticPopup_Show("CONFIRM_GUILD_PROMOTE", fullname);
		dialog.data = fullname;
	elseif ( button == "GUILD_LEAVE" ) then
		local guildName = GetGuildInfo("player");
		StaticPopup_Show("CONFIRM_GUILD_LEAVE", guildName);
	elseif ( button == "TEAM_PROMOTE" ) then
		local arenaName, teamIndex = GetArenaTeam(PVPTeamDetails.team);
		local dialog = StaticPopup_Show("CONFIRM_TEAM_PROMOTE", name, arenaName, teamIndex );
		if ( dialog ) then
			dialog.data = PVPTeamDetails.team;
			dialog.data2 = name;
		end
	elseif ( button == "TEAM_KICK" ) then
		local arenaName, teamIndex = GetArenaTeam(PVPTeamDetails.team);
		local dialog = StaticPopup_Show("CONFIRM_TEAM_KICK", name, arenaName, teamIndex );
		if ( dialog ) then
			dialog.data = PVPTeamDetails.team;
			dialog.data2 = name;
		end
	elseif ( button == "TEAM_LEAVE" ) then
		local arenaName = GetArenaTeam(PVPTeamDetails.team);
		local dialog = StaticPopup_Show("CONFIRM_TEAM_LEAVE", arenaName );
		if ( dialog ) then
			dialog.data = PVPTeamDetails.team;
		end
	elseif ( button == "TEAM_DISBAND" ) then
		local arenaName = GetArenaTeam(PVPTeamDetails.team);
		local dialog = StaticPopup_Show("CONFIRM_TEAM_DISBAND", arenaName);
		if ( dialog ) then
			dialog.data = PVPTeamDetails.team;
		end
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
	elseif ( button == "ROUND_ROBIN" ) then
		SetLootMethod("roundrobin");
		UIDropDownMenu_SetButtonText(self:GetParent().parentLevel, self:GetParent().parentID, UnitPopupButtons[button].text);
		UIDropDownMenu_Refresh(dropdownFrame, nil, 1);
	elseif ( button == "MASTER_LOOTER" ) then
		SetLootMethod("master", fullname, 2);
		UIDropDownMenu_SetButtonText(self:GetParent().parentLevel, self:GetParent().parentID, UnitPopupButtons[button].text);
		UIDropDownMenu_Refresh(dropdownFrame, nil, 1);
	elseif ( button == "GROUP_LOOT" ) then
		SetLootMethod("group");
		UIDropDownMenu_SetButtonText(self:GetParent().parentLevel, self:GetParent().parentID, UnitPopupButtons[button].text);
		UIDropDownMenu_Refresh(dropdownFrame, nil, 1);
	elseif ( button == "NEED_BEFORE_GREED" ) then
		SetLootMethod("needbeforegreed");
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
		SetLootMethod("master", fullname, 2);
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
		local isAlliedRace = UnitAlliedRaceInfo(unit);
		if (isAlliedRace) then
			StaticPopup_Show("RAF_GRANT_LEVEL_ALLIED_RACE", nil, nil, unit);
		else
			GrantLevel(unit);
		end
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
	elseif ( button == "ADD_FRIEND" or button == "CHARACTER_FRIEND" ) then
		C_FriendList.AddFriend(fullname);
	elseif ( button == "BATTLETAG_FRIEND" ) then
		local _, battleTag = BNGetInfo();
		if ( not battleTag ) then
			StaticPopupSpecial_Show(CreateBattleTagFrame);
		elseif ( clubInfo ~= nil and clubMemberInfo ~= nil ) then
			C_Club.SendBattleTagFriendRequest(clubInfo.clubId, clubMemberInfo.memberId);
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
	elseif ( button == "VOICE_CHAT_SETTINGS" ) then
		ChannelFrame:ToggleVoiceSettings();
	elseif ( button == "COMMUNITIES_LEAVE" ) then
		if (#C_Club.GetClubMembers(clubInfo.clubId) == 1) then
			StaticPopup_Show("CONFIRM_LEAVE_AND_DESTROY_COMMUNITY", nil, nil, clubInfo);
		elseif (clubMemberInfo.isSelf and clubMemberInfo.role == Enum.ClubRoleIdentifier.Owner) then
			UIErrorsFrame:AddMessage(COMMUNITIES_LIST_TRANSFER_OWNERSHIP_FIRST, RED_FONT_COLOR:GetRGBA());
		else
			StaticPopup_Show("CONFIRM_LEAVE_COMMUNITY", nil, nil, clubInfo);
	end
	elseif ( button == "COMMUNITIES_BATTLETAG_FRIEND" ) then
		C_Club.SendBattleTagFriendRequest(clubInfo.clubId, clubMemberInfo.memberId);
	elseif ( button == "COMMUNITIES_KICK" ) then
		StaticPopup_Show("CONFIRM_REMOVE_COMMUNITY_MEMBER", nil, nil, { clubType = clubInfo.clubType, name = clubMemberInfo.name, clubId = clubInfo.clubId, memberId = clubMemberInfo.memberId });
	elseif ( button == "COMMUNITIES_MEMBER_NOTE" ) then
		StaticPopup_Show("SET_COMMUNITY_MEMBER_NOTE", clubMemberInfo.name, nil, { clubId = clubInfo.clubId, memberId = clubMemberInfo.memberId });
	elseif ( button == "COMMUNITIES_FAVORITE" ) then
		CommunitiesFrame.CommunitiesList:SetFavorite(clubInfo.clubId, clubInfo.favoriteTimeStamp == nil);
	elseif ( button == "COMMUNITIES_INVITE" ) then
		local streams = C_Club.GetStreams(clubInfo.clubId);
		local defaultStreamId = #streams > 0 and streams[1].streamId or nil;
		for i, stream in ipairs(streams) do
			if stream.streamType == Enum.ClubStreamType.General or stream.streamType == Enum.ClubStreamType.Guild then
				defaultStreamId = stream.streamId;
				break;
			end
		end

		if defaultStreamId then
			CommunitiesUtil.OpenInviteDialog(clubInfo.clubId, defaultStreamId);
		end
	elseif ( button == "COMMUNITIES_SETTINGS" ) then
		OpenCommunitiesSettingsDialog(clubInfo.clubId);
	elseif ( button == "COMMUNITIES_NOTIFICATION_SETTINGS" ) then
		CommunitiesFrame:ShowNotificationSettingsDialog(clubInfo.clubId);
	elseif ( button == "COMMUNITIES_CLEAR_UNREAD_NOTIFICATIONS" ) then
		CommunitiesUtil.ClearAllUnreadNotifications(clubInfo.clubId);
	elseif ( button == "DELETE_COMMUNITIES_MESSAGE" ) then
		C_Club.DestroyMessage(dropdownFrame.communityClubID, dropdownFrame.communityStreamID, { epoch = dropdownFrame.communityEpoch, position = dropdownFrame.communityPosition });
	elseif ( commandToRoleId[button] ~= nil ) then
		C_Club.AssignMemberRole(clubInfo.clubId, clubMemberInfo.memberId, commandToRoleId[button]);
	end

	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
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