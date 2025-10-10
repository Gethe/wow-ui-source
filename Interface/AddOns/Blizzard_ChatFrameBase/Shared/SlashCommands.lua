local _, addonTbl = ...;

local issecure = issecure;
local forceinsecure = forceinsecure;

local allowedCommandsSet = nil;
local excludedCommandsSet = nil;

-- These are all the pre-defined generic slash commands that are filtered per
-- game mode. Additional slash commands may be added directly by addons.
-- Anything that needs to be disallowed for different game modes should be added here.
SLASH_COMMAND = {
	TARGET = "TARGET",
	INSPECT = "INSPECT",
	STOPATTACK = "STOPATTACK",
	CAST = "CAST",
	USE = "USE",
	STOPCASTING = "STOPCASTING",
	STOPSPELLTARGET = "STOPSPELLTARGET",
	CANCELAURA = "CANCELAURA",
	CANCELFORM = "CANCELFORM",
	EQUIP = "EQUIP",
	EQUIP_TO_SLOT = "EQUIP_TO_SLOT",
	CHANGEACTIONBAR = "CHANGEACTIONBAR",
	SWAPACTIONBAR = "SWAPACTIONBAR",
	TARGET_EXACT = "TARGET_EXACT",
	TARGET_NEAREST_ENEMY = "TARGET_NEAREST_ENEMY",
	TARGET_NEAREST_ENEMY_PLAYER = "TARGET_NEAREST_ENEMY_PLAYER",
	TARGET_NEAREST_FRIEND = "TARGET_NEAREST_FRIEND",
	TARGET_NEAREST_FRIEND_PLAYER = "TARGET_NEAREST_FRIEND_PLAYER",
	TARGET_NEAREST_PARTY = "TARGET_NEAREST_PARTY",
	TARGET_NEAREST_RAID = "TARGET_NEAREST_RAID",
	CLEARTARGET = "CLEARTARGET",
	TARGET_LAST_TARGET = "TARGET_LAST_TARGET",
	TARGET_LAST_ENEMY = "TARGET_LAST_ENEMY",
	TARGET_LAST_FRIEND = "TARGET_LAST_FRIEND",
	ASSIST = "ASSIST",
	FOCUS = "FOCUS",
	CLEARFOCUS = "CLEARFOCUS",
	MAINTANKON = "MAINTANKON",
	MAINTANKOFF = "MAINTANKOFF",
	MAINASSISTON = "MAINASSISTON",
	MAINASSISTOFF = "MAINASSISTOFF",
	DUEL = "DUEL",
	DUEL_CANCEL = "DUEL_CANCEL",
	PET_ATTACK = "PET_ATTACK",
	PET_FOLLOW = "PET_FOLLOW",
	PET_MOVE_TO = "PET_MOVE_TO",
	PET_STAY = "PET_STAY",
	PET_PASSIVE = "PET_PASSIVE",
	PET_DEFENSIVE = "PET_DEFENSIVE",
	PET_DEFENSIVEASSIST = "PET_DEFENSIVEASSIST",
	PET_AGGRESSIVE = "PET_AGGRESSIVE",
	STOPMACRO = "STOPMACRO",
	CANCELQUEUEDSPELL = "CANCELQUEUEDSPELL",
	CLICK = "CLICK",
	PET_DISMISS = "PET_DISMISS",
	LOGOUT = "LOGOUT",
	QUIT = "QUIT",
	GUILD_UNINVITE = "GUILD_UNINVITE",
	GUILD_PROMOTE = "GUILD_PROMOTE",
	GUILD_DEMOTE = "GUILD_DEMOTE",
	GUILD_LEADER = "GUILD_LEADER",
	GUILD_LEAVE = "GUILD_LEAVE",
	GUILD_DISBAND = "GUILD_DISBAND",
	EQUIP_SET = "EQUIP_SET",
	WORLD_MARKER = "WORLD_MARKER",
	CLEAR_WORLD_MARKER = "CLEAR_WORLD_MARKER",
	STARTATTACK = "STARTATTACK",
	CONSOLE = "CONSOLE",
	CHATLOG = "CHATLOG",
	COMBATLOG = "COMBATLOG",
	UNINVITE = "UNINVITE",
	PROMOTE = "PROMOTE",
	REPLY = "REPLY",
	HELP = "HELP",
	MACROHELP = "MACROHELP",
	TIME = "TIME",
	PLAYED = "PLAYED",
	FOLLOW = "FOLLOW",
	TRADE = "TRADE",
	JOIN = "JOIN",
	LEAVE = "LEAVE",
	LIST_CHANNEL = "LIST_CHANNEL",
	CHAT_HELP = "CHAT_HELP",
	CHAT_PASSWORD = "CHAT_PASSWORD",
	CHAT_OWNER = "CHAT_OWNER",
	CHAT_MODERATOR = "CHAT_MODERATOR",
	CHAT_UNMODERATOR = "CHAT_UNMODERATOR",
	CHAT_CINVITE = "CHAT_CINVITE",
	CHAT_KICK = "CHAT_KICK",
	CHAT_BAN = "CHAT_BAN",
	CHAT_UNBAN = "CHAT_UNBAN",
	CHAT_ANNOUNCE = "CHAT_ANNOUNCE",
	GUILD_INVITE = "GUILD_INVITE",
	GUILD_MOTD = "GUILD_MOTD",
	GUILD_INFO = "GUILD_INFO",
	CHAT_DND = "CHAT_DND",
	WHO = "WHO",
	CHANNEL = "CHANNEL",
	FRIENDS = "FRIENDS",
	REMOVEFRIEND = "REMOVEFRIEND",
	IGNORE = "IGNORE",
	UNIGNORE = "UNIGNORE",
	SCRIPT = "SCRIPT",
	RANDOM = "RANDOM",
	MACRO = "MACRO",
	PVP = "PVP",
	READYCHECK = "READYCHECK",
	BENCHMARK = "BENCHMARK",
	DISMOUNT = "DISMOUNT",
	RESETCHAT = "RESETCHAT",
	ENABLE_ADDONS = "ENABLE_ADDONS",
	DISABLE_ADDONS = "DISABLE_ADDONS",
	STOPWATCH = "STOPWATCH",
	ACHIEVEMENTUI = "ACHIEVEMENTUI",
	UI_ERRORS_OFF = "UI_ERRORS_OFF",
	UI_ERRORS_ON = "UI_ERRORS_ON",
	EVENTTRACE = "EVENTTRACE",
	TABLEINSPECT = "TABLEINSPECT",
	DUMP = "DUMP",
	RELOAD = "RELOAD",
	WARGAME = "WARGAME",
	TARGET_MARKER = "TARGET_MARKER",
	OPEN_LOOT_HISTORY = "OPEN_LOOT_HISTORY",
	RAIDFINDER = "RAIDFINDER",
	API = "API",
	COMMENTATOR_OVERRIDE = "COMMENTATOR_OVERRIDE",
	COMMENTATOR_NAMETEAM = "COMMENTATOR_NAMETEAM",
	COMMENTATOR_ASSIGNPLAYER = "COMMENTATOR_ASSIGNPLAYER",
	RESET_COMMENTATOR_SETTINGS = "RESET_COMMENTATOR_SETTINGS",
	VOICECHAT = "VOICECHAT",
	TEXTTOSPEECH = "TEXTTOSPEECH",
	COUNTDOWN = "COUNTDOWN",
	PET_ASSIST = "PET_ASSIST",
	PET_AUTOCASTON = "PET_AUTOCASTON",
	PET_AUTOCASTOFF = "PET_AUTOCASTOFF",
	PET_AUTOCASTTOGGLE = "PET_AUTOCASTTOGGLE",
	SUMMON_BATTLE_PET = "SUMMON_BATTLE_PET",
	RANDOMPET = "RANDOMPET",
	RANDOMFAVORITEPET = "RANDOMFAVORITEPET",
	DISMISSBATTLEPET = "DISMISSBATTLEPET",
	USE_TOY = "USE_TOY",
	PING = "PING",
	ABANDON = "ABANDON",
	INVITE = "INVITE",
	REQUEST_INVITE = "REQUEST_INVITE",
	CHAT_AFK = "CHAT_AFK",
	RAID_INFO = "RAID_INFO",
	DUNGEONS = "DUNGEONS",
	LEAVEVEHICLE = "LEAVEVEHICLE",
	CALENDAR = "CALENDAR",
	SET_TITLE = "SET_TITLE",
	FRAMESTACK = "FRAMESTACK",
	SOLOSHUFFLE_WARGAME = "SOLOSHUFFLE_WARGAME",
	SOLORBG_WARGAME = "SOLORBG_WARGAME",
	SPECTATOR_WARGAME = "SPECTATOR_WARGAME",
	SPECTATOR_SOLOSHUFFLE_WARGAME = "SPECTATOR_SOLOSHUFFLE_WARGAME",
	SPECTATOR_SOLORBG_WARGAME = "SPECTATOR_SOLORBG_WARGAME",
	GUILDFINDER = "GUILDFINDER",
	TRANSMOG_OUTFIT = "TRANSMOG_OUTFIT",
	COMMUNITY = "COMMUNITY",
	RAF = "RAF",
	EDITMODE = "EDITMODE",
};

SLASH_COMMAND_CATEGORY = {
	-- SLASH_COMMAND_CATEGORY.ALL should only be used by itself since other includes
	-- would be redundant.
	ALL = 1,
	TARGETING = 2,
	FOCUS_TARGETING = 3,
	PLAYER_INTERACTION = 4,
	CHAT_COMMAND = 5, -- Generic commands like /dnd, /logout, /reload etc.
	CHAT_CHANNEL = 6,
	COMBAT = 7,
	PET_COMMAND = 8,
	EQUIPMENT = 9,
	ACTION_BAR = 10,
	ROLES = 11,
	GUILD = 13,
	WORLD_MARKER = 14,
	DEBUG_COMMAND = 15,
	LOGGING = 16,
	GROUP_COMMAND = 17,
	MACRO = 18,
	SOCIAL = 19,
	PVP = 20,
	ADDON = 21,
	ACHIEVEMENT = 22,
	TARGET_MARKER = 23,
	LOOT_HISTORY = 24,
	RAID_FINDER = 25,
	COMMENTATOR = 26,
	VOICE_CHAT = 27,
	PET_BATTLE = 28,
	TOY = 29,
	PING = 30,
	RAID = 31,
	DUNGEON = 32,
	VEHICLE = 33,
	CALENDAR = 34,
	TITLE = 35,
	TRANSMOG = 36,
	COMMUNITY = 37,
	EDIT_MODE = 38,
};

--[[ Commands table should be formatted as:
[Enum.GameMode.Foo] = {
	INCLUDE = {
		-- Include entire categories.
		SLASH_COMMAND_CATEGORY.COMBAT,

		-- Include single commands explicitly.
		SLASH_COMMAND.PING
	},
	EXCLUDE = {
		-- Exclude specific commands from included categories.
		SLASH_COMMAND.USE,
	},
},
--]]

local COMMANDS_BY_GAME_MODE = {
	[Enum.GameMode.Standard] = {
		INCLUDE = {
			SLASH_COMMAND_CATEGORY.ALL,
		},
	},

	[Enum.GameMode.Plunderstorm] = {
		INCLUDE = {
			SLASH_COMMAND_CATEGORY.FOCUS_TARGETING,
			SLASH_COMMAND_CATEGORY.CHAT_COMMAND,
			SLASH_COMMAND_CATEGORY.SOCIAL,
			SLASH_COMMAND_CATEGORY.TARGET_MARKER,
			SLASH_COMMAND_CATEGORY.VOICE_CHAT,
			SLASH_COMMAND_CATEGORY.PING,
		},
	},

	[Enum.GameMode.WoWHack] = {
		INCLUDE = {
			SLASH_COMMAND_CATEGORY.FOCUS_TARGETING,
			SLASH_COMMAND_CATEGORY.CHAT_COMMAND,
			SLASH_COMMAND_CATEGORY.SOCIAL,
			SLASH_COMMAND_CATEGORY.TARGET_MARKER,
			SLASH_COMMAND_CATEGORY.VOICE_CHAT,
			SLASH_COMMAND_CATEGORY.PING,
			SLASH_COMMAND_CATEGORY.CALENDAR,
			SLASH_COMMAND_CATEGORY.ACHIEVEMENT,
			SLASH_COMMAND_CATEGORY.WORLD_MARKER,
			SLASH_COMMAND_CATEGORY.LOGGING,
			SLASH_COMMAND_CATEGORY.GROUP_COMMAND,
			SLASH_COMMAND_CATEGORY.PLAYER_INTERACTION,
			SLASH_COMMAND_CATEGORY.CHAT_CHANNEL,
		},
	},
};

if IsGMClient() then
	for _gameMode, commands in pairs(COMMANDS_BY_GAME_MODE) do
		if commands.INCLUDE then
			table.insert(commands.INCLUDE, SLASH_COMMAND_CATEGORY.DEBUG_COMMAND);
		else
			commands.INCLUDE = { SLASH_COMMAND_CATEGORY.DEBUG_COMMAND };
		end
	end
end

local function GetOrCreateCommandsSets()
	if allowedCommandsSet and excludedCommandsSet then
		return allowedCommandsSet, excludedCommandsSet;
	end

	allowedCommandsSet = {};
	excludedCommandsSet = {};

	local gameMode = C_GameRules.GetActiveGameMode();
	local commands = COMMANDS_BY_GAME_MODE[gameMode];
	if commands then
		if commands.INCLUDE then
			for _i, categoryOrCommand in ipairs(commands.INCLUDE) do
				if categoryOrCommand == SLASH_COMMAND_CATEGORY.ALL then
					for _categoryName, categoryKey in pairs(SLASH_COMMAND_CATEGORY) do
						allowedCommandsSet[categoryKey] = true;
					end
				else
					allowedCommandsSet[categoryOrCommand] = true;
				end
			end

			-- Note: there's no need to exclude anything if nothing is included.
			if commands.EXCLUDE then
				for _i, categoryOrCommand in ipairs(commands.EXCLUDE) do
					excludedCommandsSet[categoryOrCommand] = true;
				end
			end
		end
	end

	return allowedCommandsSet, excludedCommandsSet;
end

local function ShouldAddCommand(commandKey, category)
	local allowedSet, excludedSet = GetOrCreateCommandsSets();
	if not allowedSet[commandKey] and not allowedSet[category] then
		return false;
	end

	return not excludedSet[commandKey] and not excludedSet[category];
end

SlashCommandUtil = {};

function SlashCommandUtil.CheckAddSecureSlashCommand(commandKey, category, callback)
	-- Insecure code is not allowed to register secure slash commands.
	if not issecure() then
		SlashCommandUtil.CheckAddSlashCommand(commandKey, category, callback);
		return;
	end

	if not ShouldAddCommand(commandKey, category) then
		return;
	end

	addonTbl.SecureCmdList[commandKey] = callback;
end

function SlashCommandUtil.CheckAddSlashCommand(commandKey, category, callback)
	if not ShouldAddCommand(commandKey, category) then
		return;
	end

	SlashCmdList[commandKey] = callback;
end

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.STARTATTACK, SLASH_COMMAND_CATEGORY.COMBAT, function(msg)
	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		if ( not target  or target == "target" ) then
			target = action;
		end
		StartAttack(target);
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.STOPATTACK, SLASH_COMMAND_CATEGORY.COMBAT, function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		StopAttack();
	end
end);

-- We want to prefer spells for /cast and items for /use but we can use either
SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.CAST, SLASH_COMMAND_CATEGORY.COMBAT, function(msg)
	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		local spellExists = C_Spell.DoesSpellExist(action)
		local name, bag, slot = SecureCmdItemParse(action);
		if ( spellExists ) then
			CastSpellByName(action, target);
		elseif ( slot or C_Item.GetItemInfo(name) ) then
			SecureCmdUseItem(name, bag, slot, target);
		end
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.USE, SLASH_COMMAND_CATEGORY.COMBAT, function(msg)
	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		local name, bag, slot = SecureCmdItemParse(action);
		if ( slot or C_Item.GetItemInfo(name) ) then
			SecureCmdUseItem(name, bag, slot, target);
		else
			CastSpellByName(action, target);
		end
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.STOPCASTING, SLASH_COMMAND_CATEGORY.COMBAT, function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		SpellStopCasting();
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.STOPSPELLTARGET, SLASH_COMMAND_CATEGORY.COMBAT, function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		SpellStopTargeting();
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.CANCELAURA, SLASH_COMMAND_CATEGORY.COMBAT, function(msg)
	local spell = SecureCmdOptionParse(msg);

	local spellID = tonumber(spell);

	if spellID then
		C_Spell.CancelSpellByID(spellID);
	elseif spell then
		CancelSpellByName(spell);
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.CANCELFORM, SLASH_COMMAND_CATEGORY.COMBAT, function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		CancelShapeshiftForm();
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.EQUIP, SLASH_COMMAND_CATEGORY.EQUIPMENT, function(msg)
	local item = SecureCmdOptionParse(msg);
	if ( item ) then
		local parsedItem = SecureCmdItemParse(item);
		C_Item.EquipItemByName(parsedItem);
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.EQUIP_TO_SLOT, SLASH_COMMAND_CATEGORY.EQUIPMENT, function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		local slot, item = strmatch(action, "^(%d+)%s+(.*)");
		if ( item ) then
			if ( PaperDoll_IsEquippedSlot(slot) ) then
				local parsedItem = SecureCmdItemParse(item);
				C_Item.EquipItemByName(parsedItem, slot);
			else
				-- user specified a bad slot number (slot that you can't equip an item to)
				ChatFrameUtil.DisplayUsageError(format(ERROR_SLASH_EQUIP_TO_SLOT, INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED));
			end
		elseif ( slot ) then
			-- user specified a slot but not an item
			ChatFrameUtil.DisplayUsageError(format(ERROR_SLASH_EQUIP_TO_SLOT, INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED));
		end
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.CHANGEACTIONBAR, SLASH_COMMAND_CATEGORY.ACTION_BAR, function(msg)
	local page = SecureCmdOptionParse(msg);
	if ( page and page ~= "" ) then
		page = tonumber(page);
		if (page and page >= 1 and page <= NUM_ACTIONBAR_PAGES) then
			ChangeActionBarPage(page);
		else
			ChatFrameUtil.DisplayUsageError(format(ERROR_SLASH_CHANGEACTIONBAR, 1, NUM_ACTIONBAR_PAGES));
		end
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.SWAPACTIONBAR, SLASH_COMMAND_CATEGORY.ACTION_BAR, function(msg)
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
				ChatFrameUtil.DisplayUsageError(format(ERROR_SLASH_SWAPACTIONBAR, 1, NUM_ACTIONBAR_PAGES));
			end
		end
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.TARGET, SLASH_COMMAND_CATEGORY.TARGETING, function(msg)
	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		if ( not target or target == "target" ) then
			target = action;
		end
		TargetUnit(target);
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.TARGET_EXACT, SLASH_COMMAND_CATEGORY.TARGETING, function(msg)
	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		if ( not target or target == "target" ) then
			target = action;
		end
		TargetUnit(target, true);
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.TARGET_NEAREST_ENEMY, SLASH_COMMAND_CATEGORY.TARGETING, function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetNearestEnemy(ValueToBoolean(action, false));
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.TARGET_NEAREST_ENEMY_PLAYER, SLASH_COMMAND_CATEGORY.TARGETING, function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetNearestEnemyPlayer(ValueToBoolean(action, false));
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.TARGET_NEAREST_FRIEND, SLASH_COMMAND_CATEGORY.TARGETING, function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetNearestFriend(ValueToBoolean(action, false));
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.TARGET_NEAREST_FRIEND_PLAYER, SLASH_COMMAND_CATEGORY.TARGETING, function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetNearestFriendPlayer(ValueToBoolean(action, false));
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.TARGET_NEAREST_PARTY, SLASH_COMMAND_CATEGORY.TARGETING, function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetNearestPartyMember(ValueToBoolean(action, false));
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.TARGET_NEAREST_RAID, SLASH_COMMAND_CATEGORY.TARGETING, function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetNearestRaidMember(ValueToBoolean(action, false));
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.CLEARTARGET, SLASH_COMMAND_CATEGORY.TARGETING, function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		ClearTarget();
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.TARGET_LAST_TARGET, SLASH_COMMAND_CATEGORY.TARGETING, function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		TargetLastTarget();
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.TARGET_LAST_ENEMY, SLASH_COMMAND_CATEGORY.TARGETING, function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetLastEnemy(action);
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.TARGET_LAST_FRIEND, SLASH_COMMAND_CATEGORY.TARGETING, function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action ) then
		TargetLastFriend(action);
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.ASSIST, SLASH_COMMAND_CATEGORY.TARGETING, function(msg)
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
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.FOCUS, SLASH_COMMAND_CATEGORY.FOCUS_TARGETING, function(msg)
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
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.CLEARFOCUS, SLASH_COMMAND_CATEGORY.FOCUS_TARGETING, function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		ClearFocus();
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.MAINTANKON, SLASH_COMMAND_CATEGORY.ROLES, function(msg)
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
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.MAINTANKOFF, SLASH_COMMAND_CATEGORY.ROLES, function(msg)
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
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.MAINASSISTON, SLASH_COMMAND_CATEGORY.ROLES, function(msg)
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
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.MAINASSISTOFF, SLASH_COMMAND_CATEGORY.ROLES, function(msg)
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
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.DUEL, SLASH_COMMAND_CATEGORY.PLAYER_INTERACTION, function(msg)
	StartDuel(msg)
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.DUEL_CANCEL, SLASH_COMMAND_CATEGORY.PLAYER_INTERACTION, function(msg)
	ForfeitDuel()
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.PET_ATTACK, SLASH_COMMAND_CATEGORY.PET_COMMAND, function(msg)
	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		if ( not target or target == "pettarget" ) then
			target = action;
		end
		PetAttack(target);
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.PET_FOLLOW, SLASH_COMMAND_CATEGORY.PET_COMMAND, function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		PetFollow();
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.PET_MOVE_TO, SLASH_COMMAND_CATEGORY.PET_COMMAND, function(msg)
	local action, target = SecureCmdOptionParse(msg);
	if ( action ) then
		PetMoveTo(target);
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.PET_STAY, SLASH_COMMAND_CATEGORY.PET_COMMAND, function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		PetWait();
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.PET_PASSIVE, SLASH_COMMAND_CATEGORY.PET_COMMAND, function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		PetPassiveMode();
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.PET_DEFENSIVE, SLASH_COMMAND_CATEGORY.PET_COMMAND, function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		PetDefensiveMode();
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.PET_DEFENSIVEASSIST, SLASH_COMMAND_CATEGORY.PET_COMMAND, function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		PetDefensiveAssistMode();
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.PET_AGGRESSIVE, SLASH_COMMAND_CATEGORY.PET_COMMAND, function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		PetAggressiveMode();
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.STOPMACRO, SLASH_COMMAND_CATEGORY.COMBAT, function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		StopMacro();
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.CANCELQUEUEDSPELL, SLASH_COMMAND_CATEGORY.COMBAT, function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		SpellCancelQueuedSpell();
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.CLICK, SLASH_COMMAND_CATEGORY.CHAT_COMMAND, function(msg)
	local action = SecureCmdOptionParse(msg);
	if ( action and action ~= "" ) then
		local name, mouseButton, down = strmatch(action, "([^%s]+)%s+([^%s]+)%s*(.*)");
		if ( not name ) then
			name = action;
		end
		if ( not mouseButton ) then
			mouseButton = "LeftButton";
		end
		down = StringToBoolean(down or "", false);

		local button = GetClickFrame(name);
		if ( button and button:IsObjectType("Button") and not button:IsForbidden() ) then
			button:Click(mouseButton, down);
		end
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.PET_DISMISS, SLASH_COMMAND_CATEGORY.PET_COMMAND, function(msg)
	if ( PetCanBeAbandoned() ) then
		CastSpellByID(Constants.SpellBookSpellIDs.SPELL_ID_DISMISS_PET);
	else
		PetDismiss();
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.LOGOUT, SLASH_COMMAND_CATEGORY.CHAT_COMMAND, function(msg)
	if Kiosk.IsEnabled() then
		return;
	end
	Logout();
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.QUIT, SLASH_COMMAND_CATEGORY.CHAT_COMMAND, function(msg)
	if (Kiosk.IsEnabled()) then
		return;
	end
	Quit();
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.GUILD_UNINVITE, SLASH_COMMAND_CATEGORY.GUILD, function(msg)
	if(msg == "") then
		msg = UnitName("target");
	end
	if( msg and (strlen(msg) > Constants.ChatFrameConstants.MaxCharacterNameBytes) ) then
		ChatFrameUtil.DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	C_GuildInfo.Uninvite(msg);
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.GUILD_PROMOTE, SLASH_COMMAND_CATEGORY.GUILD, function(msg)
	if( msg and (strlen(msg) > Constants.ChatFrameConstants.MaxCharacterNameBytes) ) then
		ChatFrameUtil.DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	C_GuildInfo.Promote(msg);
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.GUILD_DEMOTE, SLASH_COMMAND_CATEGORY.GUILD, function(msg)
	if( msg and (strlen(msg) > Constants.ChatFrameConstants.MaxCharacterNameBytes) ) then
		ChatFrameUtil.DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	C_GuildInfo.Demote(msg);
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.GUILD_LEADER, SLASH_COMMAND_CATEGORY.GUILD, function(msg)
	if( msg and (strlen(msg) > Constants.ChatFrameConstants.MaxCharacterNameBytes) ) then
		ChatFrameUtil.DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	C_GuildInfo.SetLeader(msg);
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.GUILD_LEAVE, SLASH_COMMAND_CATEGORY.GUILD, function(msg)
	C_GuildInfo.Leave();
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.GUILD_DISBAND, SLASH_COMMAND_CATEGORY.GUILD, function(msg)
	if ( IsGuildLeader() ) then
		StaticPopup_Show("CONFIRM_GUILD_DISBAND");
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.EQUIP_SET, SLASH_COMMAND_CATEGORY.EQUIPMENT, function(msg)
	local set = SecureCmdOptionParse(msg);
	if ( set and set ~= "" ) then
		C_EquipmentSet.UseEquipmentSet(C_EquipmentSet.GetEquipmentSetID(set));
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.WORLD_MARKER, SLASH_COMMAND_CATEGORY.WORLD_MARKER, function(msg)
	local marker, target = SecureCmdOptionParse(msg);
	if ( tonumber(marker) ) then
		PlaceRaidMarker(tonumber(marker), target);
	end
end);

SlashCommandUtil.CheckAddSecureSlashCommand(SLASH_COMMAND.CLEAR_WORLD_MARKER, SLASH_COMMAND_CATEGORY.WORLD_MARKER, function(msg)
	local marker = SecureCmdOptionParse(msg);
	if ( tonumber(marker) ) then
		ClearRaidMarker(tonumber(marker));
	elseif ( type(marker) == "string" and strtrim(strlower(marker)) == strlower(ALL) ) then
		ClearRaidMarker(nil);	--Clear all world markers.
	end
end);

-- Non-secure commands.

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.CONSOLE, SLASH_COMMAND_CATEGORY.DEBUG_COMMAND, function(msg)
	forceinsecure();
	ConsoleExec(msg);
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.CHATLOG, SLASH_COMMAND_CATEGORY.LOGGING, function(msg)
	local info = ChatTypeInfo["SYSTEM"];
	if ( LoggingChat() ) then
		LoggingChat(false);
		DEFAULT_CHAT_FRAME:AddMessage(CHATLOGDISABLED, info.r, info.g, info.b, info.id);
	else
		LoggingChat(true);
		DEFAULT_CHAT_FRAME:AddMessage(CHATLOGENABLED, info.r, info.g, info.b, info.id);
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.COMBATLOG, SLASH_COMMAND_CATEGORY.LOGGING, function(msg)
	local info = ChatTypeInfo["SYSTEM"];
	if ( LoggingCombat() ) then
		LoggingCombat(false);
		DEFAULT_CHAT_FRAME:AddMessage(COMBATLOGDISABLED, info.r, info.g, info.b, info.id);
	else
		LoggingCombat(true);
		DEFAULT_CHAT_FRAME:AddMessage(COMBATLOGENABLED, info.r, info.g, info.b, info.id);
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.UNINVITE, SLASH_COMMAND_CATEGORY.GROUP_COMMAND, function(msg)
	if(msg == "") then
		msg = GetUnitName("target", true);
	end
	if(msg == nil) then
		ChatFrameUtil.DisplayUsageError(ERR_NO_TARGET_OR_NAME);
		return;
	end
	UninviteUnit(msg);
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.PROMOTE, SLASH_COMMAND_CATEGORY.GROUP_COMMAND, function(msg)
	PromoteToLeader(msg);
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.REPLY, SLASH_COMMAND_CATEGORY.CHAT_COMMAND, function(msg, editBox)
	local lastTell = ChatFrameUtil.GetLastTellTarget();
	if ( lastTell ) then
		msg = ChatFrameUtil.SubstituteChatMessageBeforeSend(msg);
		C_ChatInfo.SendChatMessage(msg, "WHISPER", editBox.languageID, lastTell);
	else
		-- error message
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.HELP, SLASH_COMMAND_CATEGORY.CHAT_COMMAND, function(msg)
	ChatFrameUtil.DisplayHelpText(DEFAULT_CHAT_FRAME);
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.MACROHELP, SLASH_COMMAND_CATEGORY.MACRO, function(msg)
	ChatFrameUtil.DisplayMacroHelpText(DEFAULT_CHAT_FRAME);
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.TIME, SLASH_COMMAND_CATEGORY.CHAT_COMMAND, function(msg)
	ChatFrameUtil.DisplayGameTime(DEFAULT_CHAT_FRAME);
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.PLAYED, SLASH_COMMAND_CATEGORY.CHAT_COMMAND, function(msg)
	RequestTimePlayed();
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.FOLLOW, SLASH_COMMAND_CATEGORY.PLAYER_INTERACTION, function(msg)
	FollowUnit(msg);
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.TRADE, SLASH_COMMAND_CATEGORY.PLAYER_INTERACTION, function(msg)
	InitiateTrade("target");
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.INSPECT, SLASH_COMMAND_CATEGORY.EQUIPMENT, function (_msg)
	InspectUnit("target");
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.JOIN, SLASH_COMMAND_CATEGORY.CHAT_CHANNEL, function(msg)
	local name = gsub(msg, "%s*([^%s]+).*", "%1");
	local password = gsub(msg, "%s*([^%s]+)%s*(.*)", "%2");
	if(name == "") then
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
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.LEAVE, SLASH_COMMAND_CATEGORY.CHAT_CHANNEL, function(msg)
	local name = strmatch(msg, "%s*([^%s]+)");
	if ( name ) then
		LeaveChannelByName(name);
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.LIST_CHANNEL, SLASH_COMMAND_CATEGORY.CHAT_CHANNEL, function(msg)
	local name = strmatch(msg, "%s*([^%s]+)");
	if ( name ) then
		ListChannelByName(name);
	else
		ListChannels();
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.CHAT_HELP, SLASH_COMMAND_CATEGORY.CHAT_CHANNEL, function(msg)
	ChatFrameUtil.DisplayChatHelp(DEFAULT_CHAT_FRAME);
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.CHAT_PASSWORD, SLASH_COMMAND_CATEGORY.CHAT_CHANNEL, function(msg)
	local name = gsub(msg, "%s*([^%s]+).*", "%1");
	local password = gsub(msg, "%s*([^%s]+)%s*(.*)", "%2");
	SetChannelPassword(name, password);
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.CHAT_OWNER, SLASH_COMMAND_CATEGORY.CHAT_CHANNEL, function(msg)
	local channel = gsub(msg, "%s*([^%s]+).*", "%1");
	local newOwner = gsub(msg, "%s*([^%s]+)%s*(.*)", "%2");
	if ( not channel or not newOwner ) then
		return;
	end
	local newOwnerLen = strlen(newOwner);
	if ( newOwnerLen > Constants.ChatFrameConstants.MaxCharacterNameBytes ) then
		ChatFrameUtil.DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	if ( channel ~= "" ) then
		if ( newOwnerLen > 0 ) then
			SetChannelOwner(channel, newOwner);
		else
			DisplayChannelOwner(channel);
		end
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.CHAT_MODERATOR, SLASH_COMMAND_CATEGORY.CHAT_CHANNEL, function(msg)
	local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
	if ( not channel or not player ) then
		return;
	end
	if ( strlen(player) > Constants.ChatFrameConstants.MaxCharacterNameBytes ) then
		ChatFrameUtil.DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	ChannelModerator(channel, player);
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.CHAT_UNMODERATOR, SLASH_COMMAND_CATEGORY.CHAT_CHANNEL, function(msg)
	local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
	if ( not channel or not player ) then
		return;
	end
	if ( strlen(player) > Constants.ChatFrameConstants.MaxCharacterNameBytes ) then
		ChatFrameUtil.DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	if ( channel and player ) then
		ChannelUnmoderator(channel, player);
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.CHAT_CINVITE, SLASH_COMMAND_CATEGORY.CHAT_CHANNEL, function(msg)
	local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
	if ( not channel or not player ) then
		return;
	end

	if ( channel and player ) then
		if ( strlen(player) > Constants.ChatFrameConstants.MaxCharacterNameBytes ) then
			ChatFrameUtil.DisplayUsageError(ERR_NAME_TOO_LONG2);
			return;
		end
		ChannelInvite(channel, player);
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.CHAT_KICK, SLASH_COMMAND_CATEGORY.CHAT_CHANNEL, function(msg)
	local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
	if ( not channel or not player ) then
		return;
	end
	if ( strlen(player) > Constants.ChatFrameConstants.MaxCharacterNameBytes ) then
		ChatFrameUtil.DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	if ( channel and player ) then
		ChannelKick(channel, player);
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.CHAT_BAN, SLASH_COMMAND_CATEGORY.CHAT_CHANNEL, function(msg)
	local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
	if ( not channel or not player ) then
		return;
	end
	if ( strlen(player) > Constants.ChatFrameConstants.MaxCharacterNameBytes ) then
		ChatFrameUtil.DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	if ( channel and player ) then
		ChannelBan(channel, player);
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.CHAT_UNBAN, SLASH_COMMAND_CATEGORY.CHAT_CHANNEL, function(msg)
	local channel, player = strmatch(msg, "%s*([^%s]+)%s*(.*)");
	if ( not channel or not player ) then
		return;
	end
	if ( strlen(player) > Constants.ChatFrameConstants.MaxCharacterNameBytes ) then
		ChatFrameUtil.DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	if ( channel and player ) then
		ChannelUnban(channel, player);
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.CHAT_ANNOUNCE, SLASH_COMMAND_CATEGORY.CHAT_CHANNEL, function(msg)
	local channel = strmatch(msg, "%s*([^%s]+)");
	if ( channel ) then
		ChannelToggleAnnouncements(channel);
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.GUILD_INVITE, SLASH_COMMAND_CATEGORY.GUILD, function(msg)
	if(msg == "") then
		msg = GetUnitName("target", true);
	end
	if( msg and (strlen(msg) > Constants.ChatFrameConstants.MaxCharacterNameBytes) ) then
		ChatFrameUtil.DisplayUsageError(ERR_NAME_TOO_LONG2);
		return;
	end
	C_GuildInfo.Invite(msg);
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.GUILD_MOTD, SLASH_COMMAND_CATEGORY.GUILD, function(msg)
	C_GuildInfo.SetMOTD(msg)
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.GUILD_INFO, SLASH_COMMAND_CATEGORY.GUILD, function(msg)
	GuildInfo();
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.CHAT_DND, SLASH_COMMAND_CATEGORY.CHAT_COMMAND, function(msg)
	C_ChatInfo.SendChatMessage(msg, "DND");
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.WHO, SLASH_COMMAND_CATEGORY.SOCIAL, function(msg)
	local inGameWhoListDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.IngameWhoListDisabled);
	if (Kiosk.IsEnabled() or inGameWhoListDisabled) then
		return;
	end
	if ( msg == "" ) then
		msg = WhoFrame_GetDefaultWhoCommand();
		ShowWhoPanel();
	end
	WhoFrameEditBox:SetText(msg);
	C_FriendList.SendWho(msg, Enum.SocialWhoOrigin.Chat);
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.CHANNEL, SLASH_COMMAND_CATEGORY.CHAT_CHANNEL, function(msg, editBox)
	msg = ChatFrameUtil.SubstituteChatMessageBeforeSend(msg);
	C_ChatInfo.SendChatMessage(msg, "CHANNEL", editBox.languageID, editBox:GetChannelTarget());
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.FRIENDS, SLASH_COMMAND_CATEGORY.SOCIAL, function(msg)
	local inGameFriendsListDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.IngameFriendsListDisabled);
	if inGameFriendsListDisabled then
		return;
	end

	if msg == "" and UnitIsPlayer("target") then
		msg = GetUnitName("target", true)
	end
	if not msg or msg == "" then
		ToggleFriendsPanel();
	else
		local player, note = strmatch(msg, "%s*([^%s]+)%s*(.*)");
		if player then
			C_FriendList.AddOrRemoveFriend(player, note);
		end
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.REMOVEFRIEND, SLASH_COMMAND_CATEGORY.SOCIAL, function(msg)
	C_FriendList.RemoveFriend(msg);
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.IGNORE, SLASH_COMMAND_CATEGORY.SOCIAL, function(msg)
	if ( msg ~= "" or UnitIsPlayer("target") ) then
		local bNetIDAccount = BNet_GetBNetIDAccount(msg);
		if ( bNetIDAccount ) then
			if ( BNIsFriend(bNetIDAccount) ) then
				SendSystemMessage(ERR_CANNOT_IGNORE_BN_FRIEND);
			else
				BNSetBlocked(bNetIDAccount, not BNIsBlocked(bNetIDAccount));
			end
		else
			C_FriendList.AddOrDelIgnore(msg);
		end
	else
		ToggleIgnorePanel();
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.UNIGNORE, SLASH_COMMAND_CATEGORY.SOCIAL, function(msg)
	if ( msg ~= "" or UnitIsPlayer("target") ) then
		C_FriendList.DelIgnore(msg);
	else
		ToggleIgnorePanel();
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.SCRIPT, SLASH_COMMAND_CATEGORY.DEBUG_COMMAND, function(msg)
	if Kiosk.IsEnabled() then
		return;
	end

	local userScriptsDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.UserScriptsDisabled);
	if ( not C_AddOns.GetScriptsDisallowedForBeta() and not userScriptsDisabled ) then
		if ( not AreDangerousScriptsAllowed() ) then
			StaticPopup_Show("DANGEROUS_SCRIPTS_WARNING");
			return;
		end
		RunScript(msg);
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.RANDOM, SLASH_COMMAND_CATEGORY.CHAT_COMMAND, function(msg)
	local num1 = gsub(msg, "(%s*)(%d+)(.*)", "%2", 1);
	local rest = gsub(msg, "(%s*)(%d+)(.*)", "%3", 1);
	local num2 = "";
	local numSubs;
	if ( rest ~= "" ) then
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
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.MACRO, SLASH_COMMAND_CATEGORY.MACRO, function(msg)
	if Kiosk.IsEnabled() then
		return;
	end

	ShowMacroFrame();
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.PVP, SLASH_COMMAND_CATEGORY.PVP, function(msg)
	C_PvP.TogglePVP();
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.READYCHECK, SLASH_COMMAND_CATEGORY.GROUP_COMMAND, function(msg)
	if ( UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") ) then
		DoReadyCheck();
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.BENCHMARK, SLASH_COMMAND_CATEGORY.DEBUG_COMMAND, function(msg)
	SetTaxiBenchmarkMode(ValueToBoolean(msg), true);
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.DISMOUNT, SLASH_COMMAND_CATEGORY.COMBAT, function(msg)
	if ( SecureCmdOptionParse(msg) ) then
		Dismount();
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.RESETCHAT, SLASH_COMMAND_CATEGORY.CHAT_COMMAND, function(msg)
	FCF_ResetAllWindows();
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.ENABLE_ADDONS, SLASH_COMMAND_CATEGORY.ADDON, function(msg)
	C_AddOns.EnableAllAddOns(msg);
	ReloadUI();
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.DISABLE_ADDONS, SLASH_COMMAND_CATEGORY.ADDON, function(msg)
	C_AddOns.DisableAllAddOns(msg);
	ReloadUI();
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.STOPWATCH, SLASH_COMMAND_CATEGORY.CHAT_COMMAND, function(msg)
	if ( not C_AddOns.IsAddOnLoaded("Blizzard_TimeManager") ) then
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
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.ACHIEVEMENTUI, SLASH_COMMAND_CATEGORY.ACHIEVEMENT, function(msg)
	if Kiosk.IsEnabled() then
		return;
	end
	ToggleAchievementFrame();
end);

-- easier method to turn on/off errors for macros
SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.UI_ERRORS_OFF, SLASH_COMMAND_CATEGORY.CHAT_COMMAND, function(msg)
	UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE");
	SetCVar("Sound_EnableSFX", "0");
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.UI_ERRORS_ON, SLASH_COMMAND_CATEGORY.CHAT_COMMAND, function(msg)
	UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE");
	SetCVar("Sound_EnableSFX", "1");
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.EVENTTRACE, SLASH_COMMAND_CATEGORY.DEBUG_COMMAND, function(msg)
	UIParentLoadAddOn("Blizzard_EventTrace");
	EventTrace:ProcessChatCommand(msg);
end);

if IsGMClient() then
	SLASH_COMMAND.TEXELVIS = "TEXELVIS";
	SLASH_TEXELVIS1 = "/texelvis";
	SLASH_TEXELVIS2 = "/tvis";
	SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.TEXELVIS, SLASH_COMMAND_CATEGORY.DEBUG_COMMAND, function(msg)
		UIParentLoadAddOn("Blizzard_DebugTools");
		TexelSnappingVisualizer:Show();
	end);
end

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.TABLEINSPECT, SLASH_COMMAND_CATEGORY.DEBUG_COMMAND, function(msg)
	local userScriptsDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.UserScriptsDisabled);
	if ( Kiosk.IsEnabled() or C_AddOns.GetScriptsDisallowedForBeta() or userScriptsDisabled ) then
		return;
	end
	if ( not AreDangerousScriptsAllowed() ) then
		StaticPopup_Show("DANGEROUS_SCRIPTS_WARNING");
		return;
	end
	forceinsecure();
	UIParentLoadAddOn("Blizzard_DebugTools");

	local focusedTable = nil;
	if msg ~= "" and msg ~= " " then
		local focusedFunction = loadstring(("return %s"):format(msg));
		focusedTable = focusedFunction and focusedFunction();
	end

	if focusedTable and type(focusedTable) == "table" then
		DisplayTableInspectorWindow(focusedTable);
	else
		local highlightFrame = FrameStackTooltip:SetFrameStack();
		if highlightFrame then
			DisplayTableInspectorWindow(highlightFrame);
		else
			DisplayTableInspectorWindow(UIParent);
		end
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.DUMP, SLASH_COMMAND_CATEGORY.DEBUG_COMMAND, function(msg)
	local userScriptsDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.UserScriptsDisabled);
	if (not Kiosk.IsEnabled() and not C_AddOns.GetScriptsDisallowedForBeta() and not userScriptsDisabled) then
		if ( not AreDangerousScriptsAllowed() ) then
			StaticPopup_Show("DANGEROUS_SCRIPTS_WARNING");
			return;
		end
		UIParentLoadAddOn("Blizzard_DebugTools");
		DevTools_DumpCommand(msg);
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.RELOAD, SLASH_COMMAND_CATEGORY.CHAT_COMMAND, function(msg)
	ReloadUI();
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.WARGAME, SLASH_COMMAND_CATEGORY.PVP, function(msg)
	-- Parameters are (playername, area, isTournamentMode). Since the player name can be multiple words,
	-- we pass in theses parameters as a whitespace delimited string and let the C side tokenize it
	StartWarGameByName(msg);
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.TARGET_MARKER, SLASH_COMMAND_CATEGORY.TARGET_MARKER, function(msg)
	local marker, target = SecureCmdOptionParse(msg);
	if ( not target ) then
		target = "target";
	end
	if ( tonumber(marker) ) then
		SetRaidTarget(target, tonumber(marker));	--Using /tm 0 will clear the target marker.
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.OPEN_LOOT_HISTORY, SLASH_COMMAND_CATEGORY.LOOT_HISTORY, function(msg)
	ToggleLootHistoryFrame();
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.RAIDFINDER, SLASH_COMMAND_CATEGORY.RAID_FINDER, function(msg)
	if C_LFGInfo.IsLFREnabled() then
		PVEFrame_ToggleFrame("GroupFinderFrame", RaidFinderFrame);
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.API, SLASH_COMMAND_CATEGORY.DEBUG_COMMAND, function(msg)
	APIDocumentation_LoadUI();
	APIDocumentation:HandleSlashCommand(msg);
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.COMMENTATOR_OVERRIDE, SLASH_COMMAND_CATEGORY.COMMENTATOR, function(msg)
	if not C_AddOns.IsAddOnLoaded("Blizzard_Commentator") then
		return;
	end

	local originalName, overrideName = msg:match("^(%S-)%s+(.+)");
	if not originalName or not overrideName then
		DEFAULT_CHAT_FRAME:AddMessage(ERROR_SLASH_COMMENTATOROVERRIDE, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
		DEFAULT_CHAT_FRAME:AddMessage(ERROR_SLASH_COMMENTATOROVERRIDE_EXAMPLE, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
		return;
	end

	originalName = originalName:sub(1, 1):upper() .. originalName:sub(2, -1);

	DEFAULT_CHAT_FRAME:AddMessage((SLASH_COMMENTATOROVERRIDE_SUCCESS):format(originalName, overrideName), YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);

	C_Commentator.AddPlayerOverrideName(originalName, overrideName);

	-- Also add character name without the realm if we got CharacterName-Realm.
	-- Prepend possible realm separators with % so they are matched literally
	local realmSeparateMatchList = string.gsub(REALM_SEPARATORS, ".", "%%%1");
	local characterName = string.match(originalName, "(..-)["..realmSeparateMatchList.."].");
	if characterName and characterName ~= originalName then
		DEFAULT_CHAT_FRAME:AddMessage((SLASH_COMMENTATOROVERRIDE_SUCCESS):format(characterName, overrideName), YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
		C_Commentator.AddPlayerOverrideName(characterName, overrideName);
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.COMMENTATOR_NAMETEAM, SLASH_COMMAND_CATEGORY.COMMENTATOR, function(msg)
	if not C_AddOns.IsAddOnLoaded("Blizzard_Commentator") then
		return;
	end

	local teamIndex, teamName = msg:match("^(%d+) (.+)");
	teamIndex = tonumber(teamIndex);

	if not teamIndex or not teamName then
		DEFAULT_CHAT_FRAME:AddMessage(ERROR_SLASH_COMMENTATOR_NAMETEAM, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
		DEFAULT_CHAT_FRAME:AddMessage(ERROR_SLASH_COMMENTATOR_NAMETEAM_EXAMPLE, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
		return;
	end

	if not C_Commentator.IsSpectating() then
		DEFAULT_CHAT_FRAME:AddMessage(CONTEXT_ERROR_SLASH_COMMENTATOR_NAMETEAM, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
		return;
	else
		DEFAULT_CHAT_FRAME:AddMessage((SLASH_COMMENTATOR_NAMETEAM_SUCCESS):format(teamIndex, teamName), YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
	end

	C_Commentator.AssignPlayersToTeamInCurrentInstance(teamIndex, teamName);
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.COMMENTATOR_ASSIGNPLAYER, SLASH_COMMAND_CATEGORY.COMMENTATOR, function(msg)
	if not C_AddOns.IsAddOnLoaded("Blizzard_Commentator") then
		return;
	end

	local playerName, teamName = msg:match("^(%S-)%s+(.+)");
	if not playerName or not teamName then
		DEFAULT_CHAT_FRAME:AddMessage(ERROR_SLASH_COMMENTATOR_ASSIGNPLAYER, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
		DEFAULT_CHAT_FRAME:AddMessage(ERROR_SLASH_COMMENTATOR_ASSIGNPLAYER_EXAMPLE, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
		return;
	end

	DEFAULT_CHAT_FRAME:AddMessage((SLASH_COMMENTATOR_ASSIGNPLAYER_SUCCESS):format(playerName, teamName), YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
	C_Commentator.AssignPlayerToTeam(playerName, teamName);
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.RESET_COMMENTATOR_SETTINGS, SLASH_COMMAND_CATEGORY.COMMENTATOR, function(msg)
	if not C_AddOns.IsAddOnLoaded("Blizzard_Commentator") then
		return;
	end

	C_Commentator.ResetSettings();
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.VOICECHAT, SLASH_COMMAND_CATEGORY.VOICE_CHAT, function(msg)
	if msg == "" then
		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(VOICE_COMMAND_SYNTAX, info.r, info.g, info.b, info.id);
		return;
	end
	local name = msg;
	local lowerName = string.lower(name);

	if lowerName == string.lower(VOICE_LEAVE_COMMAND) then
		local channelID = C_VoiceChat.GetActiveChannelID();
		if channelID then
			C_VoiceChat.DeactivateChannel(channelID);
		end
		return;
	end

	local channelType;
	local communityID;
	local streamID;
	if lowerName == string.lower(PARTY) then
		channelType = Enum.ChatChannelType.PrivateParty;
	elseif lowerName == string.lower(INSTANCE) then
		channelType = Enum.ChatChannelType.PublicParty;
	elseif lowerName == string.lower(GUILD) then
		communityID, streamID = CommunitiesUtil.FindGuildStreamByType(Enum.ClubStreamType.Guild);
	elseif lowerName == string.lower(OFFICER) then
		communityID, streamID = CommunitiesUtil.FindGuildStreamByType(Enum.ClubStreamType.Officer);
	else
		local communityName, streamName = string.split(":", name);
		communityID, streamID = CommunitiesUtil.FindCommunityAndStreamByName(communityName, streamName);
	end

	if channelType then
		if channelType ~= C_VoiceChat.GetActiveChannelType() then
			local activate = true;
			ChannelFrame:TryJoinVoiceChannelByType(channelType, activate);
		end
	elseif communityID and streamID then
		local activeChannelID = C_VoiceChat.GetActiveChannelID();
		local communityStreamChannel = C_VoiceChat.GetChannelForCommunityStream(communityID, streamID);
		local communityStreamChannelID = communityStreamChannel and communityStreamChannel.channelID;
		if not activeChannelID or activeChannelID ~= communityStreamChannelID then
			ChannelFrame:TryJoinCommunityStreamChannel(communityID, streamID);
		end
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.TEXTTOSPEECH, SLASH_COMMAND_CATEGORY.VOICE_CHAT, function(msg)
	if TextToSpeechCommands:EvaluateTextToSpeechCommand(msg) then
		TextToSpeechFrame_Update(TextToSpeechFrame);
	else
		TextToSpeechCommands:SpeakConfirmation(TEXTTOSPEECH_COMMAND_SYNTAX_ERROR);
		TextToSpeechCommands:ShowHelp(msg)
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.COUNTDOWN, SLASH_COMMAND_CATEGORY.GROUP_COMMAND, function(msg)
	local num1 = gsub(msg, "(%s*)(%d+)", "%2");
	local number = tonumber(num1);
	if(number and number <= Constants.PartyCountdownConstants.MaxCountdownSeconds) then
		C_PartyInfo.DoCountdown(number);
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.SUMMON_BATTLE_PET, SLASH_COMMAND_CATEGORY.PET_BATTLE, function(msg)
	-- GAME RULES TODO:: This should be an explicit game rule.
	if C_GameRules.GetActiveGameMode() == Enum.GameMode.Plunderstorm then
		return;
	end

	local pet = SecureCmdOptionParse(msg);
	if ( type(pet) == "string" ) then
		local _, petID = C_PetJournal.FindPetIDByName(string.trim(pet));
		if ( petID ) then
			C_PetJournal.SummonPetByGUID(petID);
		else
			C_PetJournal.SummonPetByGUID(pet);
		end
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.RANDOMPET, SLASH_COMMAND_CATEGORY.PET_BATTLE, function(msg)
	-- GAME RULES TODO:: This should be an explicit game rule.
	if C_GameRules.GetActiveGameMode() == Enum.GameMode.Plunderstorm then
		return;
	end

	if ( SecureCmdOptionParse(msg) ) then
		C_PetJournal.SummonRandomPet(false);
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.RANDOMFAVORITEPET, SLASH_COMMAND_CATEGORY.PET_BATTLE, function(msg)
	-- GAME RULES TODO:: This should be an explicit game rule.
	if C_GameRules.GetActiveGameMode() == Enum.GameMode.Plunderstorm then
		return;
	end

	if ( SecureCmdOptionParse(msg) ) then
		C_PetJournal.SummonRandomPet(true);
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.DISMISSBATTLEPET, SLASH_COMMAND_CATEGORY.PET_BATTLE, function(msg)
	-- GAME RULES TODO:: This should be an explicit game rule.
	if C_GameRules.GetActiveGameMode() == Enum.GameMode.Plunderstorm then
		return;
	end

	if ( SecureCmdOptionParse(msg) ) then
		local petID = C_PetJournal.GetSummonedPetGUID();
		if ( petID ) then
			C_PetJournal.SummonPetByGUID(petID);
		end
	end
end);

SlashCommandUtil.CheckAddSlashCommand(SLASH_COMMAND.RAID_INFO, SLASH_COMMAND_CATEGORY.RAID, function(msg)
	RaidFrame.slashCommand = 1;
	if ( ( GetNumSavedInstances() + GetNumSavedWorldBosses() > 0 ) and not RaidInfoFrame:IsVisible() ) then
		ToggleRaidFrame();
		RaidInfoFrame:Show();
	elseif ( not RaidFrame:IsVisible() ) then
		ToggleRaidFrame();
	end
end);
