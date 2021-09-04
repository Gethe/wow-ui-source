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
	["INSPECT"] = { text = INSPECT, disabledInKioskMode = false },
	["ACHIEVEMENTS"] = { text = COMPARE_ACHIEVEMENTS, dist = 1, disabledInKioskMode = true },
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
	["BN_ADD_FAVORITE"]	= { text = ADD_FAVORITE_STATUS, },
	["BN_REMOVE_FAVORITE"]	= { text = REMOVE_FAVORITE_STATUS, },
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
	["LEAVE"] = { text = PARTY_LEAVE, },
	["INSTANCE_LEAVE"] = { text = INSTANCE_PARTY_LEAVE, },
	["FOLLOW"] = { text = FOLLOW, dist = 4 },
	["PET_DISMISS"] = { text = PET_DISMISS, },
	["PET_ABANDON"] = { text = PET_ABANDON, },
	["PET_RENAME"] = { text = PET_RENAME, },
	["PET_SHOW_IN_JOURNAL"] = { text = PET_SHOW_IN_JOURNAL, },
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
	["REPORT_CHEATING"] = { text = REPORT_CHEATING, },
	["REPORT_BATTLE_PET"] = { text = REPORT_PET_NAME, },
	["REPORT_PET"] = { text = REPORT_PET_NAME, },

	["COPY_CHARACTER_NAME"] = { text = COPY_CHARACTER_NAME },

	["DUNGEON_DIFFICULTY"] = { text = DUNGEON_DIFFICULTY, nested = 1, defaultDifficultyID = 1 },
	["DUNGEON_DIFFICULTY1"] = { text = PLAYER_DIFFICULTY1, checkable = 1, difficultyID = 1 },
	["DUNGEON_DIFFICULTY2"] = { text = PLAYER_DIFFICULTY2, checkable = 1, difficultyID = 2 },
	["DUNGEON_DIFFICULTY3"] = { text = PLAYER_DIFFICULTY6, checkable = 1, difficultyID = 23 },

	["RAID_DIFFICULTY"] = { text = RAID_DIFFICULTY, nested = 1, defaultDifficultyID = 14 },
	["RAID_DIFFICULTY1"] = { text = PLAYER_DIFFICULTY1, checkable = 1, difficultyID = 14 },
	["RAID_DIFFICULTY2"] = { text = PLAYER_DIFFICULTY2, checkable = 1, difficultyID = 15 },
	["RAID_DIFFICULTY3"] = { text = PLAYER_DIFFICULTY6, checkable = 1, difficultyID = 16 },

	["LEGACY_RAID_DIFFICULTY1"] = { text = RAID_DIFFICULTY1, checkable = 1, difficultyID = 3 },
	["LEGACY_RAID_DIFFICULTY2"] = { text = RAID_DIFFICULTY2, checkable = 1, difficultyID = 4 },

	["PVP_FLAG"] = { text = PVP_FLAG, nested = 1, tooltipWhileDisabled = true, noTooltipWhileEnabled = true, tooltipOnButton = true },
	["PVP_ENABLE"] = { text = ENABLE, checkable = 1 },
	["PVP_DISABLE"] = { text = DISABLE, checkable = 1 },

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
	["RAF_REMOVE_RECRUIT"] = { text = RAF_REMOVE_RECRUIT, },

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

	--Role icons
	["SELECT_ROLE"] = { text = SET_ROLE, nested = 1 },
	["SET_ROLE_NONE"] = { text = NO_ROLE, checkable = 1 },
	["SET_ROLE_TANK"] = { text = INLINE_TANK_ICON.." "..TANK, checkable = 1 },
	["SET_ROLE_HEALER"] = { text = INLINE_HEALER_ICON.." "..HEALER, checkable = 1 },
	["SET_ROLE_DAMAGER"] = { text = INLINE_DAMAGER_ICON.." "..DAMAGER, checkable = 1 },

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
			return dropdownMenu.clubInfo.clubType == Enum.ClubType.Character and COMMUNITIES_LIST_DROP_DOWN_LEAVE_CHARACTER_COMMUNITY or COMMUNITIES_LIST_DROP_DOWN_LEAVE_COMMUNITY;
		end },
	["GUILDS_LEAVE"] = { text = GUILD_LEAVE },
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
	["GUILDS_SETTINGS"] = { text = GUILD_CONTROL_BUTTON_TEXT, },
	["GUILDS_RECRUITMENT_SETTINGS"] = { text = GUILD_RECRUITMENT, },
	["COMMUNITIES_NOTIFICATION_SETTINGS"] = { text = COMMUNITIES_LIST_DROP_DOWN_COMMUNITIES_NOTIFICATION_SETTINGS, },
	["COMMUNITIES_CLEAR_UNREAD_NOTIFICATIONS"] = { text = COMMUNITIES_LIST_DROP_DOWN_CLEAR_UNREAD_NOTIFICATIONS, },
	["COMMUNITIES_INVITE"] = { text = COMMUNITIES_LIST_DROP_DOWN_INVITE, },
	["GUILDS_INVITE"] = { text = COMMUNITIES_LIST_DROP_DOWN_INVITE, },

	-- Community message line
	["DELETE_COMMUNITIES_MESSAGE"] = { text = COMMUNITY_MESSAGE_DROP_DOWN_DELETE, },
};

-- First level menus
UnitPopupMenus = {
	["SELF"] = { "RAID_TARGET_ICON", "SET_FOCUS", "PVP_FLAG", "LOOT_SUBSECTION_TITLE", "SELECT_LOOT_SPECIALIZATION", "INSTANCE_SUBSECTION_TITLE", "CONVERT_TO_RAID", "CONVERT_TO_PARTY", "DUNGEON_DIFFICULTY", "RAID_DIFFICULTY", "RESET_INSTANCES", "RESET_CHALLENGE_MODE", "GARRISON_VISIT", "OTHER_SUBSECTION_TITLE", "VOICE_CHAT", "SELECT_ROLE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "INSTANCE_LEAVE", "LEAVE", "CANCEL" },
	["PET"] = { "RAID_TARGET_ICON", "SET_FOCUS", "INTERACT_SUBSECTION_TITLE", "PET_RENAME", "PET_DISMISS", "PET_ABANDON", "OTHER_SUBSECTION_TITLE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "CANCEL" },
	["OTHERPET"] = { "RAID_TARGET_ICON", "SET_FOCUS", "OTHER_SUBSECTION_TITLE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME",  "REPORT_PET", "CANCEL" },
	["BATTLEPET"] = { "PET_SHOW_IN_JOURNAL", "SET_FOCUS", "OTHER_SUBSECTION_TITLE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "CANCEL" },
	["OTHERBATTLEPET"] = { "PET_SHOW_IN_JOURNAL", "SET_FOCUS", "OTHER_SUBSECTION_TITLE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "REPORT_BATTLE_PET", "CANCEL" },
	["PARTY"] = { "RAID_TARGET_ICON", "SET_FOCUS", "ADD_FRIEND", "ADD_FRIEND_MENU", "INTERACT_SUBSECTION_TITLE", "RAF_SUMMON", "PROMOTE", "PROMOTE_GUIDE", "WHISPER", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "PET_BATTLE_PVP_DUEL", "OTHER_SUBSECTION_TITLE", "VOICE_CHAT", "SELECT_ROLE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "REPORT_PLAYER", "COPY_CHARACTER_NAME", "PVP_REPORT_AFK", "VOTE_TO_KICK", "UNINVITE", "CANCEL" },
	["PLAYER"] = { "RAID_TARGET_ICON", "SET_FOCUS", "ADD_FRIEND", "ADD_FRIEND_MENU", "INTERACT_SUBSECTION_TITLE", "RAF_SUMMON", "INVITE", "SUGGEST_INVITE", "REQUEST_INVITE", "WHISPER", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "PET_BATTLE_PVP_DUEL", "OTHER_SUBSECTION_TITLE", "VOICE_CHAT", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "REPORT_PLAYER", "COPY_CHARACTER_NAME", "CANCEL" },
	["ENEMY_PLAYER"] = { "SET_FOCUS", "INTERACT_SUBSECTION_TITLE", "INSPECT", "ACHIEVEMENTS", "DUEL", "PET_BATTLE_PVP_DUEL", "OTHER_SUBSECTION_TITLE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "REPORT_PLAYER", "COPY_CHARACTER_NAME", "CANCEL" },
	["RAID_PLAYER"] = { "RAID_TARGET_ICON", "SET_FOCUS", "ADD_FRIEND", "ADD_FRIEND_MENU", "INTERACT_SUBSECTION_TITLE", "RAF_SUMMON", "RAID_LEADER", "RAID_PROMOTE", "RAID_DEMOTE", "WHISPER", "INSPECT", "ACHIEVEMENTS", "TRADE", "FOLLOW", "DUEL", "PET_BATTLE_PVP_DUEL", "OTHER_SUBSECTION_TITLE", "VOICE_CHAT", "SELECT_ROLE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "REPORT_PLAYER", "COPY_CHARACTER_NAME", "PVP_REPORT_AFK", "VOTE_TO_KICK", "RAID_REMOVE", "CANCEL" },
	["RAID"] = { "SET_FOCUS", "INTERACT_SUBSECTION_TITLE", "RAID_LEADER",  "RAID_PROMOTE", "RAID_DEMOTE", "RAID_MAINTANK", "RAID_MAINASSIST", "OTHER_SUBSECTION_TITLE", "VOICE_CHAT", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "REPORT_PLAYER", "COPY_CHARACTER_NAME", "PVP_REPORT_AFK", "VOTE_TO_KICK", "RAID_REMOVE", "CANCEL" },
	["FRIEND"] = { "POP_OUT_CHAT", "TARGET", "SET_NOTE", "INTERACT_SUBSECTION_TITLE", "RAF_SUMMON", "INVITE", "SUGGEST_INVITE", "REQUEST_INVITE", "WHISPER", "OTHER_SUBSECTION_TITLE", "DELETE_COMMUNITIES_MESSAGE", "IGNORE", "REMOVE_FRIEND", "REPORT_PLAYER", "COPY_CHARACTER_NAME", "PVP_REPORT_AFK", "CANCEL" },
	["FRIEND_OFFLINE"] = { "SET_NOTE", "OTHER_SUBSECTION_TITLE", "IGNORE", "REMOVE_FRIEND", "COPY_CHARACTER_NAME", "CANCEL" },
	["BN_FRIEND"] = { "POP_OUT_CHAT", "BN_TARGET", "BN_SET_NOTE", "BN_VIEW_FRIENDS", "INTERACT_SUBSECTION_TITLE", "RAF_SUMMON", "BN_INVITE", "BN_SUGGEST_INVITE", "BN_REQUEST_INVITE", "WHISPER", "OTHER_SUBSECTION_TITLE", "DELETE_COMMUNITIES_MESSAGE", "BN_ADD_FAVORITE", "BN_REMOVE_FAVORITE", "BN_REMOVE_FRIEND", "REPORT_PLAYER", "CANCEL" },
	["BN_FRIEND_OFFLINE"] = { "BN_SET_NOTE", "BN_VIEW_FRIENDS", "INTERACT_SUBSECTION_TITLE", "WHISPER", "OTHER_SUBSECTION_TITLE", "BN_ADD_FAVORITE", "BN_REMOVE_FAVORITE", "BN_REMOVE_FRIEND", "REPORT_PLAYER", "CANCEL" },
	["GUILD"] = { "TARGET", "GUILD_BATTLETAG_FRIEND", "INTERACT_SUBSECTION_TITLE", "INVITE", "SUGGEST_INVITE", "REQUEST_INVITE", "WHISPER", "GUILD_PROMOTE", "OTHER_SUBSECTION_TITLE", "VOICE_CHAT", "IGNORE", "COPY_CHARACTER_NAME", "GUILD_LEAVE", "CANCEL" },
	["GUILD_OFFLINE"] = { "GUILD_BATTLETAG_FRIEND", "INTERACT_SUBSECTION_TITLE", "GUILD_PROMOTE", "OTHER_SUBSECTION_TITLE", "IGNORE", "COPY_CHARACTER_NAME", "GUILD_LEAVE", "CANCEL" },
	["RAID_TARGET_ICON"] = { "RAID_TARGET_8", "RAID_TARGET_7", "RAID_TARGET_6", "RAID_TARGET_5", "RAID_TARGET_4", "RAID_TARGET_3", "RAID_TARGET_2", "RAID_TARGET_1", "RAID_TARGET_NONE" },
	["SELECT_ROLE"] = { "SET_ROLE_TANK", "SET_ROLE_HEALER", "SET_ROLE_DAMAGER", "SET_ROLE_NONE" },
	["CHAT_ROSTER"] = { "VOICE_CHAT_MICROPHONE_VOLUME", "VOICE_CHAT_SPEAKER_VOLUME", "VOICE_CHAT_USER_VOLUME", "SUBSECTION_SEPARATOR", "INTERACT_SUBSECTION_TITLE", "TARGET", "WHISPER", "CHAT_OWNER", "CHAT_PROMOTE", "CHAT_DEMOTE", "SUBSECTION_SEPARATOR", "OTHER_SUBSECTION_TITLE", "REPORT_PLAYER", "COPY_CHARACTER_NAME", "VOICE_CHAT_SETTINGS", "CLOSE" },
	["VEHICLE"] = { "RAID_TARGET_ICON", "SET_FOCUS", "OTHER_SUBSECTION_TITLE", "VEHICLE_LEAVE", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "CANCEL" },
	["TARGET"] = { "RAID_TARGET_ICON", "SET_FOCUS", "ADD_FRIEND", "ADD_FRIEND_MENU", "OTHER_SUBSECTION_TITLE", "VOICE_CHAT", "MOVE_PLAYER_FRAME", "MOVE_TARGET_FRAME", "CANCEL" },
	["ARENAENEMY"] = { "SET_FOCUS", "OTHER_SUBSECTION_TITLE", "CANCEL" },
	["FOCUS"] = { "RAID_TARGET_ICON", "CLEAR_FOCUS", "OTHER_SUBSECTION_TITLE", "VOICE_CHAT", "LARGE_FOCUS", "MOVE_FOCUS_FRAME", "CANCEL" },
	["BOSS"] = { "RAID_TARGET_ICON", "SET_FOCUS", "OTHER_SUBSECTION_TITLE", "CANCEL" },
	["WORLD_STATE_SCORE"] = { "REPORT_PLAYER", "PVP_REPORT_AFK", "CANCEL" },
	["COMMUNITIES_WOW_MEMBER"] = { "TARGET", "ADD_FRIEND_MENU", "SUBSECTION_SEPARATOR", "VOICE_CHAT_MICROPHONE_VOLUME", "VOICE_CHAT_SPEAKER_VOLUME", "VOICE_CHAT_USER_VOLUME", "SUBSECTION_SEPARATOR", "INTERACT_SUBSECTION_TITLE", "INVITE", "SUGGEST_INVITE", "REQUEST_INVITE", "WHISPER", "IGNORE", "COMMUNITIES_LEAVE", "COMMUNITIES_KICK", "COMMUNITIES_MEMBER_NOTE", "COMMUNITIES_ROLE", "OTHER_SUBSECTION_TITLE", "REPORT_PLAYER", "COPY_CHARACTER_NAME", "CANCEL" },
	["COMMUNITIES_GUILD_MEMBER"] = { "TARGET", "ADD_FRIEND_MENU", "SUBSECTION_SEPARATOR", "VOICE_CHAT_MICROPHONE_VOLUME", "VOICE_CHAT_SPEAKER_VOLUME", "VOICE_CHAT_USER_VOLUME", "SUBSECTION_SEPARATOR", "INTERACT_SUBSECTION_TITLE", "INVITE", "SUGGEST_INVITE", "REQUEST_INVITE", "WHISPER", "IGNORE", "GUILD_PROMOTE", "OTHER_SUBSECTION_TITLE", "GUILD_LEAVE", "REPORT_PLAYER", "COPY_CHARACTER_NAME", "CANCEL" },
	["COMMUNITIES_MEMBER"] = { "COMMUNITIES_BATTLETAG_FRIEND", "SUBSECTION_SEPARATOR", "VOICE_CHAT_MICROPHONE_VOLUME", "VOICE_CHAT_SPEAKER_VOLUME", "VOICE_CHAT_USER_VOLUME", "SUBSECTION_SEPARATOR", "COMMUNITIES_LEAVE", "COMMUNITIES_KICK", "COMMUNITIES_MEMBER_NOTE", "COMMUNITIES_ROLE", "OTHER_SUBSECTION_TITLE", "REPORT_PLAYER"  },
	["COMMUNITIES_COMMUNITY"] = { "COMMUNITIES_CLEAR_UNREAD_NOTIFICATIONS", "COMMUNITIES_INVITE", "COMMUNITIES_SETTINGS", "COMMUNITIES_NOTIFICATION_SETTINGS", "COMMUNITIES_FAVORITE", "COMMUNITIES_LEAVE" },
	["GUILDS_GUILD"] = { "COMMUNITIES_CLEAR_UNREAD_NOTIFICATIONS", "GUILDS_INVITE", "GUILDS_SETTINGS", "GUILDS_RECRUITMENT_SETTINGS", "COMMUNITIES_NOTIFICATION_SETTINGS", "GUILDS_LEAVE" },
	["RAF_RECRUIT"] = { "ADD_FRIEND", "ADD_FRIEND_MENU", "INTERACT_SUBSECTION_TITLE", "RAF_SUMMON", "INVITE", "SUGGEST_INVITE", "REQUEST_INVITE", "WHISPER", "OTHER_SUBSECTION_TITLE", "RAF_REMOVE_RECRUIT", "CANCEL" },

	-- Second level menus
	["ADD_FRIEND_MENU"] = { "BATTLETAG_FRIEND", "CHARACTER_FRIEND" },
	["PVP_FLAG"] = { "PVP_ENABLE", "PVP_DISABLE"},
	["SELECT_LOOT_SPECIALIZATION"] = { "LOOT_SPECIALIZATION_DEFAULT","LOOT_SPECIALIZATION_SPEC1", "LOOT_SPECIALIZATION_SPEC2", "LOOT_SPECIALIZATION_SPEC3", "LOOT_SPECIALIZATION_SPEC4"},
	["OPT_OUT_LOOT_TITLE"] = { "OPT_OUT_LOOT_ENABLE", "OPT_OUT_LOOT_DISABLE"},
	["REPORT_PLAYER"] = { "REPORT_SPAM", "REPORT_BAD_LANGUAGE", "REPORT_BAD_NAME", "REPORT_BAD_GUILD_NAME", "REPORT_CHEATING" },
	["DUNGEON_DIFFICULTY"] = { "DUNGEON_DIFFICULTY1", "DUNGEON_DIFFICULTY2", "DUNGEON_DIFFICULTY3" },
	["RAID_DIFFICULTY"] = { "RAID_DIFFICULTY1", "RAID_DIFFICULTY2", "RAID_DIFFICULTY3", "LEGACY_RAID_SUBSECTION_TITLE", "LEGACY_RAID_DIFFICULTY1", "LEGACY_RAID_DIFFICULTY2" },
	["MOVE_PLAYER_FRAME"] = { "UNLOCK_PLAYER_FRAME", "LOCK_PLAYER_FRAME", "RESET_PLAYER_FRAME_POSITION", "PLAYER_FRAME_SHOW_CASTBARS" },
	["MOVE_TARGET_FRAME"] = { "UNLOCK_TARGET_FRAME", "LOCK_TARGET_FRAME", "RESET_TARGET_FRAME_POSITION" , "TARGET_FRAME_BUFFS_ON_TOP"},
	["MOVE_FOCUS_FRAME"] = { "UNLOCK_FOCUS_FRAME", "LOCK_FOCUS_FRAME", "FOCUS_FRAME_BUFFS_ON_TOP"},
	["VOICE_CHAT"] = { "VOICE_CHAT_MICROPHONE_VOLUME", "VOICE_CHAT_SPEAKER_VOLUME", "VOICE_CHAT_USER_VOLUME" },
	["COMMUNITIES_ROLE"] = { "COMMUNITIES_ROLE_OWNER", "COMMUNITIES_ROLE_LEADER", "COMMUNITIES_ROLE_MODERATOR", "COMMUNITIES_ROLE_MEMBER" },
};

UnitPopupShown = { {}, {}, {}, };


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

local function UnitPopup_GetBNetIDAccount(dropdownMenu)
	if dropdownMenu.bnetIDAccount then
		return dropdownMenu.bnetIDAccount;
	elseif dropdownMenu.guid and C_AccountInfo.IsGUIDBattleNetAccountType(dropdownMenu.guid) then
		return C_AccountInfo.GetIDFromBattleNetAccountGUID(dropdownMenu.guid);
	end
end

local function UnitPopup_GetGUID(menu)
	if menu.guid then
		return menu.guid;
	elseif menu.unit then
		return UnitGUID(menu.unit);
	elseif type(menu.userData) == "table" and menu.userData.guid then
		return menu.userData.guid;
	elseif menu.accountInfo and menu.accountInfo.gameAccountInfo.playerGuid then
		return menu.accountInfo.gameAccountInfo.playerGuid;
	end
end

local function UnitPopup_GetBNetAccountInfo(menu)
	local bnetIDAccount = UnitPopup_GetBNetIDAccount(menu)
	if bnetIDAccount then
		return C_BattleNet.GetAccountInfoByID(bnetIDAccount);
	else
		local guid = UnitPopup_GetGUID(menu);
		if guid then
			return C_BattleNet.GetAccountInfoByGUID(guid);
		end
	end
end

local function UnitPopup_GetIsMobile(menu)
	if menu.isMobile ~= nil then
		return menu.isMobile;
	elseif menu.accountInfo and menu.accountInfo.gameAccountInfo then
		return menu.accountInfo.gameAccountInfo.isWowMobile;
	end
end

function UnitPopup_ShowMenu (dropdownMenu, which, unit, name, userData)
	g_mostRecentPopupMenu = nil;

	local server = nil;
	-- Init variables
	dropdownMenu.which = which;
	dropdownMenu.unit = unit;
	if ( unit ) then
		name, server = UnitNameUnmodified(unit);
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
	dropdownMenu.accountInfo = nil;
	dropdownMenu.accountInfo = UnitPopup_GetBNetAccountInfo(dropdownMenu);
	dropdownMenu.isMobile = UnitPopup_GetIsMobile(dropdownMenu);

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

	UnitPopupButtons["GARRISON_VISIT"].text = (C_Garrison.IsUsingPartyGarrison() and GARRISON_RETURN) or GARRISON_VISIT_LEADER;
	-- This allows player to view loot settings if he's not the leader

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
							if ((instanceDifficultyID == DifficultyUtil.ID.Raid10Normal or instanceDifficultyID == DifficultyUtil.ID.Raid25Normal) and UnitPopupButtons[value].difficultyID == DifficultyUtil.ID.PrimaryRaidNormal) then
								info.checked = true;
							elseif ((instanceDifficultyID == DifficultyUtil.ID.Raid10Heroic or instanceDifficultyID == DifficultyUtil.ID.Raid25Heroic) and UnitPopupButtons[value].difficultyID == DifficultyUtil.ID.PrimaryRaidHeroic) then
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
					if ( ( inParty and not isLeader ) or inPublicParty or inInstance or GetRaidDifficultyID() == DifficultyUtil.ID.PrimaryRaidMythic ) then
						info.disabled = true;
					end
					if ( toggleDifficultyID and not GetRaidDifficultyID() == DifficultyUtil.ID.PrimaryRaidMythic and CheckToggleDifficulty(toggleDifficultyID, UnitPopupButtons[value].difficultyID) ) then
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
			titleText = UnitNameUnmodified(unit);
		end

		info.text = titleText or UNKNOWN;
		info.isTitle = true;
		info.notCheckable = true;

		local class;
		if unit and UnitIsPlayer(unit) then
			class = select(2, UnitClass(unit));
		end

		if not class and userData and userData.guid then
			class = select(2, GetPlayerInfoByGUID(userData.guid));
		end

		if class then
			local colorCode = select(4, GetClassColor(class));
			info.disablecolor = "|c" .. colorCode;
		end

		UIDropDownMenu_AddButton(info);
	end
end

local function GetDropDownButtonText(button, dropdownMenu)
	if (type(button.text) == "function") then
		return button.text(dropdownMenu);
	end

	return button.text or "";
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
		if C_PvP.IsWarModeActive() or (TALENT_WAR_MODE_BUTTON and TALENT_WAR_MODE_BUTTON:GetWarModeDesired()) then
			info.hasArrow = nil;
			info.tooltipTitle = PVP_LABEL_WAR_MODE;
			info.tooltipInstruction = PVP_WAR_MODE_ENABLED;
			if (not C_PvP.CanToggleWarMode(true)) then
				info.tooltipWarning = UnitFactionGroup("player") == PLAYER_FACTION_GROUP[0] and PVP_WAR_MODE_NOT_NOW_HORDE or PVP_WAR_MODE_NOT_NOW_ALLIANCE;
			end
		else
			info.hasArrow = true;
		end
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

	local color = cntButton.color;
	if ( color ) then
		info.colorCode = string.format("|cFF%02x%02x%02x",  color.r*255,  color.g*255,  color.b*255);
	else
		info.colorCode = nil;
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
	info.tooltipTitle = cntButton.text;
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

local function UnitPopup_IsValidPlayerLocation(playerLocation)
	return playerLocation and playerLocation:IsValid();
end

local function UnitPopup_IsSameServer(playerLocation, dropdownMenu)
	if playerLocation then
		return C_PlayerInfo.UnitIsSameServer(playerLocation);
	elseif dropdownMenu.accountInfo and dropdownMenu.accountInfo.gameAccountInfo.realmName then
		return dropdownMenu.accountInfo.gameAccountInfo.realmName == GetRealmName();
	end
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
	if menu.isOffline then
		return true;
	elseif menu.clubMemberInfo then
		local presence = menu.clubMemberInfo.presence;
		if presence == Enum.ClubMemberPresence.Offline or presence == Enum.ClubMemberPresence.Unknown then
			return true;
		end
	elseif menu.accountInfo then
		if not menu.accountInfo.gameAccountInfo.isOnline then
			return true;
		end
	end

	return false;
end

local function UnitPopup_IsPlayerFavorite(menu)
	return menu.accountInfo and menu.accountInfo.isFavorite;
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

local function UnitPopup_IsInGroupWithPlayer(dropdownMenu)
	if dropdownMenu.accountInfo and dropdownMenu.accountInfo.gameAccountInfo.characterName then
		return	UnitInParty(dropdownMenu.accountInfo.gameAccountInfo.characterName) or UnitInRaid(dropdownMenu.accountInfo.gameAccountInfo.characterName);
	elseif dropdownMenu.guid then
		return IsGUIDInGroup(dropdownMenu.guid);
	end
end

local function UnitPopup_IsBNetFriend(dropdownMenu)
	return dropdownMenu.accountInfo and dropdownMenu.accountInfo.isFriend;
end

local function UnitPopup_CanAddBNetFriend(dropdownMenu, isLocalPlayer, haveBattleTag, isPlayer)
	local hasClubInfo = dropdownMenu.clubInfo ~= nil and dropdownMenu.clubMemberInfo ~= nil;
	return not isLocalPlayer and haveBattleTag and (isPlayer or hasClubInfo or dropdownMenu.accountInfo) and not UnitPopup_IsBNetFriend(dropdownMenu);
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
	local partyLFGSlot = GetPartyLFGID();
	local partyLFGCategory = UnitPopup_GetLFGCategoryForLFGSlot(partyLFGSlot);
	local guid = UnitPopup_GetGUID(dropdownMenu);
	local playerLocation = UnitPopup_TryCreatePlayerLocation(dropdownMenu, guid);
	local isSameServer = UnitPopup_IsSameServer(playerLocation, dropdownMenu);
	local haveBattleTag = UnitPopup_HasBattleTag();
	local isOffline = UnitPopup_IsPlayerOffline(dropdownMenu);
	local isBNFriend = UnitPopup_IsBNetFriend(dropdownMenu);
	local isBNFriendFavorite = UnitPopup_IsPlayerFavorite(dropdownMenu);
	local isValidPlayerLocation = UnitPopup_IsValidPlayerLocation(playerLocation);
	local isLocalPlayer = UnitPopup_GetIsLocalPlayer(dropdownMenu);

	for index, value in ipairs(UnitPopupMenus[UIDROPDOWNMENU_MENU_VALUE] or UnitPopupMenus[dropdownMenu.which]) do
		local shown = true;
		if ( value == "TRADE" ) then
			if ( not canCoop or not isPlayer ) then
				shown = false;
			end
		elseif ( value == "ADD_FRIEND" ) then
			if ( haveBattleTag or not canCoop or not isPlayer or not isSameServer or C_FriendList.GetFriendInfo(UnitNameUnmodified(dropdownMenu.unit)) ) then
				shown = false;
			end
		elseif ( value == "ADD_FRIEND_MENU" ) then
			local hasClubInfo = dropdownMenu.clubInfo ~= nil and dropdownMenu.clubMemberInfo ~= nil;
			if ( isLocalPlayer or not haveBattleTag or (not isPlayer and not hasClubInfo and not dropdownMenu.isRafRecruit) ) then
				shown = false;
			end
		elseif ( value == "GUILD_BATTLETAG_FRIEND" ) then
			if ( not UnitPopup_CanAddBNetFriend(dropdownMenu, isLocalPlayer, haveBattleTag, isPlayer) ) then
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
			elseif ( dropdownMenu.isMobile ) then
				shown = false;
			end

			local displayedInvite = GetDisplayedInviteType(guid);
			if ( not inParty and dropdownMenu.unit and UnitInAnyGroup(dropdownMenu.unit, LE_PARTY_CATEGORY_HOME) ) then
				--Handle the case where we don't have SocialQueue data about this unit (e.g. because it's a random person)
				--in the world. In this case, we want to display REQUEST_INVITE if they're in a group.
				displayedInvite = "REQUEST_INVITE";
			end
			if ( value ~= displayedInvite ) then
				shown = false;
			end
		elseif ( value == "BN_INVITE" or value == "BN_SUGGEST_INVITE" or value == "BN_REQUEST_INVITE" ) then
			if not dropdownMenu.accountInfo or not dropdownMenu.accountInfo.gameAccountInfo.playerGuid then
				shown = false;
			else
				local inviteType = GetDisplayedInviteType(dropdownMenu.accountInfo.gameAccountInfo.playerGuid);
				if "BN_"..inviteType ~= value then
					shown = false;
				elseif not dropdownMenu.bnetIDAccount or not BNFeaturesEnabledAndConnected() then
					shown = false;
				elseif dropdownMenu.isMobile then
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
				local playerName, playerServer = UnitNameUnmodified("player");
				whisperIsLocalPlayer = (dropdownMenu.name == playerName and dropdownMenu.server == playerServer);
			end

			if whisperIsLocalPlayer or (isOffline and not dropdownMenu.bnetIDAccount) or ( dropdownMenu.unit and (not canCoop or not isPlayer)) or (dropdownMenu.bnetIDAccount and not isBNFriend) then
				shown = false;
			end

			if ( dropdownMenu.isMobile ) then
				shown = false;
			end
		elseif ( value == "DUEL" ) then
			if ( UnitCanAttack("player", dropdownMenu.unit) or not isPlayer ) then
				shown = false;
			end
		elseif ( value == "PET_BATTLE_PVP_DUEL" ) then
			if ( not UnitCanPetBattle("player", dropdownMenu.unit) or not isPlayer ) then
				shown = false;
			end
		elseif ( value == "INSPECT" or value == "ACHIEVEMENTS" ) then
			if ( not dropdownMenu.unit or UnitCanAttack("player", dropdownMenu.unit) or not isPlayer ) then
				shown = false;
			end
		elseif ( value == "IGNORE" ) then
			if ( dropdownMenu.name == UnitNameUnmodified("player") or ( dropdownMenu.unit and not isPlayer ) ) then
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
		elseif ( value == "BN_ADD_FAVORITE" ) then
			if ( not dropdownMenu.friendsList or isBNFriendFavorite) then
				shown = false;
			end
		elseif ( value == "BN_REMOVE_FAVORITE" ) then
			if ( not dropdownMenu.friendsList or not isBNFriendFavorite) then
				shown = false;
			end
		elseif ( value == "REPORT_PLAYER" ) then
			if not isValidPlayerLocation or not C_ReportSystem.CanReportPlayer(playerLocation) then
				shown = false;
			end
		elseif ( value == "REPORT_SPAM" ) then
			if not isValidPlayerLocation or not (playerLocation:IsChatLineID() or playerLocation:IsCommunityInvitation()) or not C_ReportSystem.CanReportPlayerForLanguage(playerLocation) then
				shown = false;
			end
		elseif ( value == "REPORT_BAD_LANGUAGE") then
			if not isValidPlayerLocation or not C_ReportSystem.CanReportPlayerForLanguage(playerLocation) then
				shown = false;
			end
		elseif ( value == "REPORT_CHEATING" ) then
			if dropdownMenu.bnetIDAccount or not isValidPlayerLocation or playerLocation:IsBattleNetGUID() then
				shown = false;
			end
		elseif ( value == "POP_OUT_CHAT" ) then
			if ( (dropdownMenu.chatType ~= "WHISPER" and dropdownMenu.chatType ~= "BN_WHISPER") or dropdownMenu.chatTarget == UnitNameUnmodified("player") or
				FCFManager_GetNumDedicatedFrames(dropdownMenu.chatType, dropdownMenu.chatTarget) > 0 ) then
				shown = false;
			end
		elseif ( value == "TARGET" ) then
			-- We don't want to show a menu option that will end up being blocked
			if ( dropdownMenu.isMobile or InCombatLockdown() or not issecure() ) then
				shown = false;
			end
		elseif ( value == "BN_TARGET" ) then
			-- We don't want to show a menu option that will end up being blocked
			if ( dropdownMenu.isMobile or not isBNFriend or InCombatLockdown() or not issecure() ) then
				shown = false;
			elseif ( dropdownMenu.isMobile ) then
				shown = false;
			end
		elseif ( value == "PROMOTE" ) then
			if ( not inParty or not isLeader or not isPlayer or HasLFGRestrictions()) then
				shown = false;
			end
		elseif ( value == "PROMOTE_GUIDE" ) then
			if ( not inParty or not isLeader or not isPlayer or not HasLFGRestrictions()) then
				shown = false;
			end
		elseif ( value == "GUILD_PROMOTE" ) then
			if ( not IsGuildLeader() or dropdownMenu.name == UnitNameUnmodified("player") ) then
				shown = false;
			end
		elseif ( value == "GUILD_LEAVE" ) then
			if ( dropdownMenu.name ~= UnitNameUnmodified("player") ) then
				shown = false;
			end
		elseif ( value == "UNINVITE" ) then
			if ( not inParty or not isPlayer or not isLeader or (instanceType == "pvp") or (instanceType == "arena") or HasLFGRestrictions() ) then
				shown = false;
			end
		elseif ( value == "VOTE_TO_KICK" ) then
			if ( not inParty or not isPlayer or (instanceType == "pvp") or (instanceType == "arena") or (not HasLFGRestrictions()) or IsInActiveWorldPVP() ) then
				shown = false;
			end
		elseif ( value == "LEAVE" ) then
			if ( not inParty or IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or (instanceType == "pvp") or (instanceType == "arena") ) then
				shown = false;
			end
		elseif ( value == "INSTANCE_LEAVE" ) then
			if ( not inParty or not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or IsPartyWorldPVP() or instanceType == "pvp" or instanceType == "arena" or partyLFGCategory == LE_LFG_CATEGORY_WORLDPVP ) then
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
		elseif ( value == "RAID_LEADER" ) then
			if ( not isLeader or not isPlayer or UnitIsGroupLeader(dropdownMenu.unit)or not dropdownMenu.name ) then
				shown = false;
			end
		elseif ( value == "RAID_PROMOTE" ) then
			if ( not isLeader or not isPlayer or IsEveryoneAssistant() ) then
				shown = false;
			elseif ( isLeader ) then
				if ( UnitIsGroupAssistant(dropdownMenu.unit) ) then
					shown = false;
				end
			end
		elseif ( value == "RAID_DEMOTE" ) then
			if ( ( not isLeader and not isAssistant ) or not dropdownMenu.name or not isPlayer ) then
				shown = false;
			elseif ( not GetPartyAssignment("MAINTANK", dropdownMenu.unit) and not GetPartyAssignment("MAINASSIST", dropdownMenu.unit) ) then
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
			if ( HasLFGRestrictions() or not isPlayer ) then
				shown = false;
			elseif ( ( not isLeader and not isAssistant ) or not dropdownMenu.name or (instanceType == "pvp") or (instanceType == "arena") ) then
				shown = false;
			elseif ( not isLeader and isAssistant and UnitIsGroupAssistant(dropdownMenu.unit) ) then
				shown = false;
			elseif ( isLeader and UnitIsUnit(dropdownMenu.unit, "player") ) then
				shown = false;
			end
		elseif ( value == "PVP_REPORT_AFK" ) then
			if ( C_PvP.IsRatedMap() or  (not IsInActiveWorldPVP() and (not inBattleground or GetCVar("enablePVPNotifyAFK") == "0") ) ) then
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
				if ( dropdownMenu.name == UnitNameUnmodified("player") ) then
					shown = false;
				elseif ( not UnitInBattleground(dropdownMenu.name) and not IsInActiveWorldPVP(dropdownMenu.name) ) then
					shown = false;
				end
			end
		elseif ( value == "RAF_SUMMON" ) then
			if not guid or dropdownMenu.isMobile or not IsRecruitAFriendLinked(guid) then
				shown = false;
			end
		elseif value == "RAF_REMOVE_RECRUIT" then
			if not dropdownMenu.isRafRecruit then
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
				if ( not IsDisplayChannelOwner() or dropdownMenu.owner or dropdownMenu.moderator or dropdownMenu.name == UnitNameUnmodified("player") ) then -- TODO: Name matching is wrong here, needs full name comparison
					shown = false;
				end
			end
		elseif ( value == "CHAT_DEMOTE" ) then
			if ( dropdownMenu.channelType ~= Enum.ChatChannelType.Custom ) then
				shown = false;
			else
				if ( not IsDisplayChannelOwner() or dropdownMenu.owner or not dropdownMenu.moderator or dropdownMenu.name == UnitNameUnmodified("player") ) then -- TODO: Name matching is wrong here, needs full name comparison
					shown = false;
				end
			end
		elseif ( value == "CHAT_OWNER" ) then
			if ( dropdownMenu.channelType ~= Enum.ChatChannelType.Custom ) then
				shown = false;
			else
				if ( not IsDisplayChannelOwner() or dropdownMenu.owner or dropdownMenu.name == UnitNameUnmodified("player") ) then -- TODO: Name matching needs full name comparison
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
		elseif ( value == "SELECT_ROLE" ) then
			if ( C_Scenario.IsInScenario() or not ( IsInGroup() and not HasLFGRestrictions() and (isLeader or isAssistant or UnitIsUnit(dropdownMenu.unit, "player")) ) ) then
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
		elseif ( value == "VOICE_CHAT" ) then
			if not C_VoiceChat.CanPlayerUseVoiceChat() then
				shown = false;
			elseif not (isLocalPlayer or (isValidPlayerLocation and C_VoiceChat.IsPlayerUsingVoice(playerLocation))) then
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
			if not C_VoiceChat.CanPlayerUseVoiceChat() or isLocalPlayer or not isValidPlayerLocation or not C_VoiceChat.IsPlayerUsingVoice(playerLocation) then
				shown = false;
			end
		elseif value == "COMMUNITIES_LEAVE" then
			if dropdownMenu.clubInfo == nil or dropdownMenu.clubMemberInfo == nil or not dropdownMenu.clubMemberInfo.isSelf then
				shown = false;
			end
		elseif value == "GUILDS_LEAVE" then
			if dropdownMenu.clubInfo == nil or dropdownMenu.clubMemberInfo == nil or not dropdownMenu.clubMemberInfo.isSelf or IsGuildLeader() then
				shown = false;
			end
		elseif value == "COMMUNITIES_BATTLETAG_FRIEND" then
			if not haveBattleTag
				or not UnitPopup_CanAddBNetFriend(dropdownMenu, isLocalPlayer, haveBattleTag, isPlayer)
				or dropdownMenu.clubInfo == nil
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
		elseif value == "GUILDS_INVITE" then
			if not CanGuildInvite() then
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
		elseif value == "GUILDS_SETTINGS" then
			if not IsGuildLeader() then
				shown = false;
			end
		elseif value == "GUILDS_RECRUITMENT_SETTINGS" then
			if dropdownMenu.clubInfo then
				local isPostingBanned = C_ClubFinder.IsPostingBanned(dropdownMenu.clubInfo.clubId);
				if not C_ClubFinder.IsEnabled() or C_ClubFinder.GetClubFinderDisableReason() ~= nil or (not IsGuildLeader() and not C_GuildInfo.IsGuildOfficer()) or isPostingBanned then
					shown = false;
				end
			else
				shown = false;
			end
		elseif commandToRoleId[value] ~= nil then
			if not dropdownMenu.clubAssignableRoles or not tContains(dropdownMenu.clubAssignableRoles, commandToRoleId[value]) then
				shown = false;
			end
		elseif value == "COPY_CHARACTER_NAME" then
			if isLocalPlayer or (playerLocation and playerLocation:IsBattleNetGUID()) then
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

	if unitPopupButton.dist and not CheckInteractDistance(dropdownFrame.unit, unitPopupButton.dist) then
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
	local guid = UnitPopup_GetGUID(currentDropDown);
	local playerLocation = UnitPopup_TryCreatePlayerLocation(currentDropDown, guid);
	local isSameServer = UnitPopup_IsSameServer(playerLocation, currentDropDown);
	local isLocalPlayer = UnitPopup_GetIsLocalPlayer(currentDropDown);
	local haveBattleTag = UnitPopup_HasBattleTag();
	local isPlayer = currentDropDown.unit and UnitIsPlayer(currentDropDown.unit);
	local isInGroupWithPlayer = UnitPopup_IsInGroupWithPlayer(currentDropDown);

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
					elseif (value == "PVP_FLAG" or value == "PVP_ENABLE" or value == "PVP_DISABLE") then
						if ( C_PvP.IsWarModeActive() or (TALENT_WAR_MODE_BUTTON and TALENT_WAR_MODE_BUTTON:GetWarModeDesired()) ) then
							enable = false;
						end
					elseif ( value == "UNINVITE" ) then
						if ( not inParty or not isLeader or HasLFGRestrictions() or (instanceType == "pvp") or (instanceType == "arena") ) then
							enable = false;
						end
					elseif ( value == "INVITE" or value == "SUGGEST_INVITE" or value == "REQUEST_INVITE" ) then
						if isInGroupWithPlayer then
							enable = false;
						end
					elseif ( value == "BN_INVITE" or value == "BN_SUGGEST_INVITE" or value == "BN_REQUEST_INVITE" ) then
						if not currentDropDown.bnetIDAccount or not CanGroupWithAccount(currentDropDown.bnetIDAccount) or isInGroupWithPlayer then
							enable = false;
						end
					elseif ( value == "BN_TARGET" ) then
						if ( not currentDropDown.bnetIDAccount) then
							enable = false;
						else
							if not currentDropDown.accountInfo or (currentDropDown.accountInfo.gameAccountInfo.clientProgram ~= BNET_CLIENT_WOW) or (currentDropDown.accountInfo.gameAccountInfo.wowProjectID ~= WOW_PROJECT_ID) then
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
					elseif ( ( strsub(value, 1, 22) == "LEGACY_RAID_DIFFICULTY" ) and ( strlen(value) > 22 ) ) then
						if ( ( inParty and not isLeader ) or inPublicParty or inInstance or GetRaidDifficultyID() == DifficultyUtil.ID.PrimaryRaidMythic ) then
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
						if ( not UnitPopup_CanAddBNetFriend(currentDropDown, isLocalPlayer, haveBattleTag, isPlayer) or not BNFeaturesEnabledAndConnected()) then
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
								if ( not UnitIsSameServer(UIDROPDOWNMENU_INIT_MENU.unit) or C_FriendList.GetFriendInfo(UnitNameUnmodified(UIDROPDOWNMENU_INIT_MENU.unit)) ) then
									enable = false;
								end
							end
						elseif currentDropDown.clubMemberInfo then
							if not isSameServer or C_FriendList.GetFriendInfo(currentDropDown.clubMemberInfo.name) then
								enable = false;
							end
						elseif not isSameServer or not currentDropDown.accountInfo or not currentDropDown.accountInfo.gameAccountInfo.characterName or C_FriendList.GetFriendInfo(currentDropDown.accountInfo.gameAccountInfo.characterName) then
							enable = false;
						end
					elseif ( value == "RAF_SUMMON" ) then
						if not guid then
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

local function TryBNInvite(menu)
	local gameAccountInfo = menu.accountInfo and menu.accountInfo.gameAccountInfo;
	if gameAccountInfo and gameAccountInfo.playerGuid and gameAccountInfo.gameAccountID then
		FriendsFrame_InviteOrRequestToJoin(gameAccountInfo.playerGuid, gameAccountInfo.gameAccountID);
		return true;
	end
end

local function TryInvite(menu, inviteType, fullname)
	if inviteType == "SUGGEST_INVITE" and C_PartyInfo.IsPartyFull() and not UnitIsGroupLeader("player") then
		ChatFrame_DisplaySystemMessageInPrimary(ERR_GROUP_FULL);
	else
		if not TryBNInvite(menu) then
			if inviteType == "INVITE" or inviteType == "SUGGEST_INVITE" then
				C_PartyInfo.InviteUnit(fullname);
			elseif inviteType == "REQUEST_INVITE" then
				C_PartyInfo.RequestInviteFromUnit(fullname);
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

	if dropdownFrame.isRafRecruit and dropdownFrame.accountInfo.gameAccountInfo.characterName and dropdownFrame.accountInfo.gameAccountInfo.realmName then
		fullname = dropdownFrame.accountInfo.gameAccountInfo.characterName.."-"..dropdownFrame.accountInfo.gameAccountInfo.realmName;
	elseif ( server and ((not unit and GetNormalizedRealmName() ~= server) or (unit and UnitRealmRelationship(unit) ~= LE_REALM_RELATION_SAME)) ) then
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
		local isBNetAccount = dropdownFrame.bnetIDAccount or (dropdownFrame.playerLocation and dropdownFrame.playerLocation:IsBattleNetGUID());
		if ( isBNetAccount  ) then
			ChatFrame_SendBNetTell(name);
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
		C_FriendList.AddOrDelIgnore(fullname);
	elseif ( button == "REPORT_SPAM" ) then
		C_ReportSystem.OpenReportPlayerDialog(PLAYER_REPORT_TYPE_SPAM, fullname, playerLocation);
	elseif ( button == "REPORT_BAD_LANGUAGE" ) then
		C_ReportSystem.OpenReportPlayerDialog(PLAYER_REPORT_TYPE_LANGUAGE, fullname, playerLocation);
	elseif ( button == "REPORT_BAD_NAME" ) then
		C_ReportSystem.OpenReportPlayerDialog(PLAYER_REPORT_TYPE_BAD_PLAYER_NAME, fullname, playerLocation);
	elseif ( button == "REPORT_BAD_GUILD_NAME" ) then
		C_ReportSystem.OpenReportPlayerDialog(PLAYER_REPORT_TYPE_BAD_GUILD_NAME, fullname, playerLocation);
	elseif ( button == "REPORT_PET" ) then
		C_ReportSystem.SetPendingReportPetTarget(unit);
		StaticPopup_Show("CONFIRM_REPORT_PET_NAME", fullname);
	elseif ( button == "REPORT_BATTLE_PET" ) then
		C_PetBattles.SetPendingReportTargetFromUnit(unit);
		StaticPopup_Show("CONFIRM_REPORT_BATTLEPET_NAME", fullname);
	elseif ( button == "REPORT_CHEATING" ) then
		HelpFrame_ShowReportCheatingDialog(playerLocation);
	elseif ( button == "POP_OUT_CHAT" ) then
		FCF_OpenTemporaryWindow(dropdownFrame.chatType, dropdownFrame.chatTarget, dropdownFrame.chatFrame, true);
	elseif ( button == "DUEL" ) then
		StartDuel(unit, true);
	elseif ( button == "PET_BATTLE_PVP_DUEL" ) then
		C_PetBattles.StartPVPDuel(unit, true);
	elseif ( button == "INVITE" or button == "REQUEST_INVITE" or button == "SUGGEST_INVITE" ) then
		TryInvite(dropdownFrame, button, fullname);
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
		if dropdownFrame.accountInfo then
			local promptText;
			if dropdownFrame.accountInfo.isBattleTagFriend then
				promptText = string.format(BATTLETAG_REMOVE_FRIEND_CONFIRMATION, dropdownFrame.accountInfo.accountName);
			else
				promptText = string.format(REMOVE_FRIEND_CONFIRMATION, dropdownFrame.accountInfo.accountName);
			end
			local dialog = StaticPopup_Show("CONFIRM_REMOVE_FRIEND", promptText, nil, dropdownFrame.accountInfo.bnetAccountID);
		end
	elseif ( button == "BN_ADD_FAVORITE" ) then
		local accountId = dropdownFrame.bnetIDAccount;
		if accountId then
			BNSetFriendFavoriteFlag(accountId, true);
		end
	elseif ( button == "BN_REMOVE_FAVORITE" ) then
		local accountId = dropdownFrame.bnetIDAccount;
		if accountId then
			BNSetFriendFavoriteFlag(accountId, false);
		end
	elseif ( button == "BN_SET_NOTE" ) then
		FriendsFrame.NotesID = dropdownFrame.bnetIDAccount;
		StaticPopup_Show("SET_BNFRIENDNOTE", fullname);
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	elseif ( button == "BN_VIEW_FRIENDS" ) then
		FriendsFriendsFrame_Show(dropdownFrame.bnetIDAccount);
	elseif ( button == "BN_INVITE" or button == "BN_SUGGEST_INVITE" or button == "BN_REQUEST_INVITE" ) then
		TryBNInvite(dropdownFrame);
	elseif ( button == "BN_TARGET" ) then
		if dropdownFrame.accountInfo and dropdownFrame.accountInfo.gameAccountInfo.characterName then
			TargetUnit(dropdownFrame.accountInfo.gameAccountInfo.characterName);
		end
	elseif ( button == "PROMOTE" or button == "PROMOTE_GUIDE" ) then
		PromoteToLeader(unit, 1);
	elseif ( button == "GUILD_PROMOTE" ) then
		local dialog = StaticPopup_Show("CONFIRM_GUILD_PROMOTE", fullname);
		dialog.data = fullname;
	elseif ( button == "GUILD_LEAVE" ) then
		local guildName = GetGuildInfo("player");
		StaticPopup_Show("CONFIRM_GUILD_LEAVE", guildName);
	elseif ( button == "LEAVE" ) then
		C_PartyInfo.LeaveParty();
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
	elseif ( button == "PVP_ENABLE" ) then
		SetPVP(1);
	elseif ( button == "PVP_DISABLE" ) then
		SetPVP(nil);
	elseif ( button == "CONVERT_TO_RAID" ) then
		C_PartyInfo.ConvertToRaid();
	elseif ( button == "CONVERT_TO_PARTY" ) then
		C_PartyInfo.ConvertToParty();
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
		SummonFriend(guid, fullname);
	elseif ( button == "RAF_REMOVE_RECRUIT" ) then
		StaticPopup_Show("CONFIRM_RAF_REMOVE_RECRUIT", dropdownFrame.name, nil, dropdownFrame.wowAccountGUID);
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
	elseif ( strsub(button, 1, 9) == "SET_ROLE_" ) then
		UnitSetRole(dropdownFrame.unit, strsub(button, 10));
	elseif ( button == "ADD_FRIEND" or button == "CHARACTER_FRIEND" ) then
		C_FriendList.AddFriend(fullname);
	elseif ( button == "BATTLETAG_FRIEND" ) then
		local _, battleTag = BNGetInfo();
		if ( not battleTag ) then
			StaticPopupSpecial_Show(CreateBattleTagFrame);
		elseif ( clubInfo ~= nil and clubMemberInfo ~= nil ) then
			C_Club.SendBattleTagFriendRequest(clubInfo.clubId, clubMemberInfo.memberId);
		elseif dropdownFrame.accountInfo then
			BNSendFriendInvite(dropdownFrame.accountInfo.battleTag);
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
	elseif ( button == "GUILDS_LEAVE" ) then
		local guildName = GetGuildInfo("player");
		StaticPopup_Show("CONFIRM_GUILD_LEAVE", guildName);
	elseif ( button == "COMMUNITIES_BATTLETAG_FRIEND" ) then
		C_Club.SendBattleTagFriendRequest(clubInfo.clubId, clubMemberInfo.memberId);
	elseif ( button == "COMMUNITIES_KICK" ) then
		StaticPopup_Show("CONFIRM_REMOVE_COMMUNITY_MEMBER", nil, nil, { clubType = clubInfo.clubType, name = clubMemberInfo.name, clubId = clubInfo.clubId, memberId = clubMemberInfo.memberId });
	elseif ( button == "COMMUNITIES_MEMBER_NOTE" ) then
		StaticPopup_Show("SET_COMMUNITY_MEMBER_NOTE", clubMemberInfo.name, nil, { clubId = clubInfo.clubId, memberId = clubMemberInfo.memberId });
	elseif ( button == "COMMUNITIES_FAVORITE" ) then
		CommunitiesFrame.CommunitiesList:SetFavorite(clubInfo.clubId, clubInfo.favoriteTimeStamp == nil);
	elseif ( button == "COMMUNITIES_INVITE" or button == "GUILDS_INVITE") then
		local streams = C_Club.GetStreams(clubInfo.clubId);
		local defaultStreamId = #streams > 0 and streams[1] or nil;
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
	elseif (button == "GUILDS_SETTINGS") then
		if ( not GuildControlUI ) then
			UIParentLoadAddOn("Blizzard_GuildControlUI");
		end

		local wasShown = GuildControlUI:IsShown();
		if not wasShown then
			ShowUIPanel(GuildControlUI);
		end
	elseif (button == "GUILDS_RECRUITMENT_SETTINGS") then
		CommunitiesFrame.RecruitmentDialog.clubId = clubInfo.clubId;
		CommunitiesFrame.RecruitmentDialog.clubName = clubInfo.name;
		CommunitiesFrame.RecruitmentDialog.clubAvatarId = clubInfo.avatarId;
		CommunitiesFrame.RecruitmentDialog:UpdatedPostingInformationInit();
	elseif ( button == "COMMUNITIES_NOTIFICATION_SETTINGS" ) then
		CommunitiesFrame:ShowNotificationSettingsDialog(clubInfo.clubId);
	elseif ( button == "COMMUNITIES_CLEAR_UNREAD_NOTIFICATIONS" ) then
		CommunitiesUtil.ClearAllUnreadNotifications(clubInfo.clubId);
	elseif ( button == "DELETE_COMMUNITIES_MESSAGE" ) then
		C_Club.DestroyMessage(dropdownFrame.communityClubID, dropdownFrame.communityStreamID, { epoch = dropdownFrame.communityEpoch, position = dropdownFrame.communityPosition });
	elseif ( commandToRoleId[button] ~= nil ) then
		C_Club.AssignMemberRole(clubInfo.clubId, clubMemberInfo.memberId, commandToRoleId[button]);
	elseif ( button == "COPY_CHARACTER_NAME" ) then
		CopyToClipboard(name);
	end

	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
end

RAID_TOGGLE_MAP = {
	[DifficultyUtil.ID.PrimaryRaidNormal] = { DifficultyUtil.ID.Raid10Normal, DifficultyUtil.ID.Raid25Normal },
	[DifficultyUtil.ID.PrimaryRaidHeroic] = { DifficultyUtil.ID.Raid10Heroic, DifficultyUtil.ID.Raid25Heroic },
	[DifficultyUtil.ID.PrimaryRaidMythic] = {},
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

local function GetMappedLegacyDifficultyID(difficultyID, size)
	for i, mappedDifficultyID in ipairs(RAID_TOGGLE_MAP[difficultyID]) do
		if DifficultyUtil.GetMaxPlayers(mappedDifficultyID) == size then
			return mappedDifficultyID;
		end
	end
	return nil;
end

function SetRaidDifficulties(primaryRaid, difficultyID)
	if primaryRaid then
		local toggleDifficultyID, force;
		local _, instanceType, instanceDifficultyID, _, _, _, isDynamicInstance = GetInstanceInfo();
		if isDynamicInstance and CanChangePlayerDifficulty() then
			_, _, _, _, _, _, toggleDifficultyID = GetDifficultyInfo(instanceDifficultyID);
		end
		if toggleDifficultyID and IsLegacyDifficulty(toggleDifficultyID) then
			force = true;
		end
		SetRaidDifficultyID(difficultyID, force);
		if difficultyID == DifficultyUtil.ID.PrimaryRaidMythic then
			return;
		end
		force = nil;
		if toggleDifficultyID and not IsLegacyDifficulty(toggleDifficultyID) then
			force = true;
		end
		local otherDifficulty = GetLegacyRaidDifficultyID();
		local size = DifficultyUtil.GetMaxPlayers(otherDifficulty);
		local newDifficulty = GetMappedLegacyDifficultyID(difficultyID, size);
		SetLegacyRaidDifficultyID(newDifficulty, force);
	else
		local otherDifficulty = GetRaidDifficultyID();
		local size = DifficultyUtil.GetMaxPlayers(difficultyID);
		local newDifficulty = GetMappedLegacyDifficultyID(otherDifficulty, size)
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