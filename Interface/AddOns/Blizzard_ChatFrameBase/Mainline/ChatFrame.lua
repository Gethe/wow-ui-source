local _, addonTbl = ...;

local getmetatable = getmetatable;
local securecallfunction = securecallfunction;
local secureexecuterange = secureexecuterange;
local tWipe = table.wipe;

MESSAGE_SCROLLBUTTON_INITIAL_DELAY = 0;
MESSAGE_SCROLLBUTTON_SCROLL_DELAY = 0.05;
CHAT_BUTTON_FLASH_TIME = 0.5;
CHAT_TELL_ALERT_TIME = 300;
NUM_CHAT_WINDOWS = 10;
DEFAULT_CHAT_FRAME = ChatFrame1;
CHAT_FOCUS_OVERRIDE = nil;
NUM_REMEMBERED_TELLS = 10;
MAX_WOW_CHAT_CHANNELS = 20;
MAX_COUNTDOWN_SECONDS = 3600; -- One Hour
ACTIVE_CHAT_EDIT_BOX = nil;
LAST_ACTIVE_CHAT_EDIT_BOX = nil;

DevTools_AddMessageHandler(function(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg);
end);

function GetChatTimestampFormat()
	local value = Settings.GetValue("showTimestamps");
	if value ~= "none" then
		return value;
	end
	return nil;
end

ChatFrameUtil = {};

function ChatFrameUtil.ForEachChatFrame(func)
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName];
		func(frame);
	end
end

CHAT_SHOW_IME = false;

MAX_CHARACTER_NAME_BYTES = 305;

--DEBUG FIXME FOR TESTING
CHAT_OPTIONS = {
	ONE_EDIT_AT_A_TIME = "old"
};

-- Table for event indexed chatFilters.
-- Format ["CHAT_MSG_SYSTEM"] = { function1, function2, function3 }
-- filter, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11 = function1 (self, event, ...) if filter then return true end return false, ... end
local chatFilters = {};

hash_EmoteTokenList = {}
hash_ChatTypeInfoList = {}			--[localizedCommand] -> identifier (Stores all slash commands)

ChatTypeInfo = { };
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
ChatTypeInfo["GUILD_ITEM_LOOTED"]						= CopyTable(ChatTypeInfo["GUILD_ACHIEVEMENT"]);
ChatTypeInfo["COMMUNITIES_CHANNEL"]						= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["VOICE_TEXT"]								= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = false };
ChatTypeInfo["PING"]									= { sticky = 0, flashTab = false, flashTabOnGeneral = false, ignoreChatTypeProcessing = true };
--NEW_CHAT_TYPE -Add the info here.

ChatTypeGroup = {};
ChatTypeGroup["SYSTEM"] = {
	"CHAT_MSG_SYSTEM",
	"TIME_PLAYED_MSG",
	"PLAYER_LEVEL_CHANGED",
	"UNIT_LEVEL",
	"CHARACTER_POINTS_CHANGED",
	"CHAT_MSG_BN_WHISPER_PLAYER_OFFLINE",
	"DISPLAY_EVENT_TOAST_LINK",
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
ChatTypeGroup["CURRENCY"] = {
	"CHAT_MSG_CURRENCY",
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
	"CHAT_MSG_GUILD_ACHIEVEMENT",
	"CHAT_MSG_GUILD_ITEM_LOOTED",
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
}
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
ChatTypeGroup["PING"] = {
	"CHAT_MSG_PING",
};
--NEW_CHAT_TYPE - Add the chat type above.

ChatTypeGroupInverted = {};
for group, values in pairs(ChatTypeGroup) do
	for _, value in pairs(values) do
		ChatTypeGroupInverted[value] = group;
	end
end

CHAT_CATEGORY_LIST = {
	PARTY = { "PARTY_LEADER", "PARTY_GUIDE", "MONSTER_PARTY" },
	RAID = { "RAID_LEADER", "RAID_WARNING" },
	GUILD = { "GUILD_ACHIEVEMENT", "GUILD_ITEM_LOOTED" },
	WHISPER = { "WHISPER_INFORM", "AFK", "DND" },
	CHANNEL = { "CHANNEL_JOIN", "CHANNEL_LEAVE", "CHANNEL_NOTICE", "CHANNEL_USER", "CHANNEL_NOTICE_USER" },
	INSTANCE_CHAT = { "INSTANCE_CHAT_LEADER" },
	BN_WHISPER = { "BN_WHISPER_INFORM" },
};

CHAT_INVERTED_CATEGORY_LIST = {};
for category, sublist in pairs(CHAT_CATEGORY_LIST) do
	for _, item in pairs(sublist) do
		CHAT_INVERTED_CATEGORY_LIST[item] = category;
	end
end

function Chat_GetChatFrame(chatFrameIndex)
	return _G["ChatFrame"..chatFrameIndex];
end

function Chat_GetChatCategory(chatType)
	return CHAT_INVERTED_CATEGORY_LIST[chatType] or chatType;
end

function Chat_GetChannelColor(chatInfo)
	return chatInfo.r, chatInfo.g, chatInfo.b;
end

function Chat_GetCommunitiesChannelName(clubId, streamId)
	return ("Community:%s:%s"):format(tostring(clubId), tostring(streamId));
end

function Chat_GetCommunitiesChannel(clubId, streamId)
	local communitiesChannelName = Chat_GetCommunitiesChannelName(clubId, streamId);
	for i = 1, MAX_WOW_CHAT_CHANNELS do
		local channelID, channelName = GetChannelName(i);
		if channelName and channelName == communitiesChannelName then
			return "CHANNEL"..i, i;
		end
	end
end

function Chat_GetCommunitiesChannelColor(clubId, streamId)
	local channel = Chat_GetCommunitiesChannel(clubId, streamId);
	if channel then
		local chatInfo = ChatTypeInfo[channel];
		if chatInfo then
			return Chat_GetChannelColor(chatInfo);
		end
	end

	local clubInfo = C_Club.GetClubInfo(clubId);
	if clubInfo then
		if clubInfo.clubType == Enum.ClubType.Guild then
			local streamInfo = C_Club.GetStreamInfo(clubId, streamId);
			local chatInfoType = (streamInfo and streamInfo.streamType == Enum.ClubStreamType.Officer) and "OFFICER" or "GUILD";
			return Chat_GetChannelColor(ChatTypeInfo[chatInfoType]);
		elseif clubInfo.clubType == Enum.ClubType.BattleNet then
			return BATTLENET_FONT_COLOR:GetRGB();
		end
	end

	return DEFAULT_CHAT_CHANNEL_COLOR:GetRGB();
end


local MAX_COMMUNITY_NAME_LENGTH = 12;
local MAX_COMMUNITY_NAME_LENGTH_NO_CHANNEL = 24;

local HAS_INITIALIZED_DEFAULT_CHAT_CHANNEL = false;

function ChatFrame_TruncateToMaxLength(text, maxLength)
	local length = strlenutf8(text);
	if ( length > maxLength ) then
		return text:sub(1, maxLength - 2).."...";
	end

	return text;
end

function ChatFrame_ResolvePrefixedChannelName(communityChannelArg)
	local prefix, communityChannel = communityChannelArg:match("(%d+. )(.*)");
	return prefix..ChatFrame_ResolveChannelName(communityChannel);
end

function ChatFrame_GetCommunityAndStreamFromChannel(communityChannel)
	local clubId, streamId = communityChannel:match("(%d+)%:(%d+)");
	return tonumber(clubId), tonumber(streamId);
end

function ChatFrame_ResolveChannelName(communityChannel)
	local clubId, streamId = ChatFrame_GetCommunityAndStreamFromChannel(communityChannel);
	if not clubId or not streamId then
		return communityChannel;
	end

	return ChatFrame_GetCommunityAndStreamName(clubId, streamId);
end

function ChatFrame_GetCommunityAndStreamName(clubId, streamId)
	local streamInfo = C_Club.GetStreamInfo(clubId, streamId);

	if streamInfo and (streamInfo.streamType == Enum.ClubStreamType.Guild or streamInfo.streamType == Enum.ClubStreamType.Officer) then
		return streamInfo.name;
	end

	local streamName = streamInfo and ChatFrame_TruncateToMaxLength(streamInfo.name, MAX_COMMUNITY_NAME_LENGTH) or "";

	local clubInfo = C_Club.GetClubInfo(clubId);
	if streamInfo and streamInfo.streamType == Enum.ClubStreamType.General then
		local communityName = clubInfo and ChatFrame_TruncateToMaxLength(clubInfo.shortName or clubInfo.name, MAX_COMMUNITY_NAME_LENGTH_NO_CHANNEL) or "";
		return communityName;
	else
		local communityName = clubInfo and ChatFrame_TruncateToMaxLength(clubInfo.shortName or clubInfo.name, MAX_COMMUNITY_NAME_LENGTH) or "";
		return communityName.." - "..streamName;
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
		item = C_Container.GetContainerItemLink(bag, slot);
	elseif ( slot ) then
		item = GetInventoryItemLink("player", slot);
	end
	return item, bag, slot;
end

function SecureCmdUseItem(name, bag, slot, target)
	if ( bag ) then
		C_Container.UseContainerItem(bag, slot, target);
	elseif ( slot ) then
		UseInventoryItem(slot, target);
	else
		C_Item.UseItemByName(name, target);
	end
end

local function ChatFrame_ImportListToHash(list, hash)
	local function ImportHash(k, v, hash)
		local i = 1;
		local tag = _G["SLASH_"..k..i];
		while(tag) do
			tag = strupper(tag);
			if ( hash ) then
				hash[tag] = v;
			end
			hash_ChatTypeInfoList[tag] = k;	--Also need to import it here for all types.
			i = i + 1;
			tag = _G["SLASH_"..k..i];
		end
		--Add the item we removed to the proxy table.
		local proxyTable = getmetatable(list).__index;
		proxyTable[k] = v;
	end
	secureexecuterange(list, ImportHash, hash);

	securecallfunction(tWipe, list);
end

function ChatFrame_ImportEmoteTokensToHash()
	-- Hook up per-faction emotes before we build the emote list hash.
	local factionGroup = UnitFactionGroup and UnitFactionGroup("player") or nil;
	if ( factionGroup == "Alliance" ) then
		TextEmoteSpeechList[#TextEmoteSpeechList + 1] = "FORTHEALLIANCE";
	elseif ( factionGroup == "Horde" ) then
		TextEmoteSpeechList[#TextEmoteSpeechList + 1] = "FORTHEHORDE";
	end

	local i = 1;
	local j = 1;
	local cmdString = _G["EMOTE"..i.."_CMD"..j];
	while ( i <= MAXEMOTEINDEX ) do
		local token = _G["EMOTE"..i.."_TOKEN"];
		-- if the code in here changes - change the corresponding code above
		if ( token and cmdString) then
			hash_EmoteTokenList[strupper(cmdString)] = token;	-- add to hash
		end
		j = j + 1;
		cmdString = _G["EMOTE"..i.."_CMD"..j];
		if ( not cmdString ) then
			i = i + 1;
			j = 1;
			cmdString = _G["EMOTE"..i.."_CMD"..j];
		end
	end
end

function ChatFrame_ImportAllListsToHash()
	ChatFrame_ImportListToHash(addonTbl.SecureCmdList, addonTbl.hash_SecureCmdList);
	ChatFrame_ImportListToHash(SlashCmdList, hash_SlashCmdList);
	ChatFrame_ImportListToHash(ChatTypeInfo);
end

function ChatFrame_SetupListProxyTable(list)
	setmetatable(list, { __index = {} });
end

ChatFrame_SetupListProxyTable(ChatTypeInfo);

for index, value in pairs(ChatTypeInfo) do
	value.r = 1.0;
	value.g = 1.0;
	value.b = 1.0;
	value.id = GetChatTypeIndex(index);
end

ChatFrame_ImportAllListsToHash();
ChatFrame_ImportEmoteTokensToHash();

function ChatFrame_AddMessage(self, ...)
	self.BaseAddMessage(self, ...);

	if ( self.addMessageObserver ) then
		self.addMessageObserver(self, ...);
	end
end

-- ChatFrame functions
function ChatFrame_OnLoad(self)
	self:SetTimeVisible(120.0);
	self:SetMaxLines(128);
	self:SetFontObject(ChatFontNormal);
	self:SetIndentedWordWrap(true);
	self:SetJustifyH("LEFT");

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("SETTINGS_LOADED");
	self:RegisterEvent("UPDATE_CHAT_COLOR");
	self:RegisterEvent("UPDATE_CHAT_WINDOWS");
	self:RegisterEvent("CHAT_MSG_CHANNEL");
	self:RegisterEvent("CHAT_MSG_COMMUNITIES_CHANNEL");
	self:RegisterEvent("CLUB_REMOVED");
	self:RegisterEvent("UPDATE_INSTANCE_INFO");
	self:RegisterEvent("UPDATE_CHAT_COLOR_NAME_BY_CLASS");
	self:RegisterEvent("CHAT_SERVER_DISCONNECTED");
	self:RegisterEvent("CHAT_SERVER_RECONNECTED");
	self:RegisterEvent("BN_CONNECTED");
	self:RegisterEvent("BN_DISCONNECTED");
	self:RegisterEvent("PLAYER_REPORT_SUBMITTED");
	self:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT");
	self:RegisterEvent("ALTERNATIVE_DEFAULT_LANGUAGE_CHANGED");
	self:RegisterEvent("NEWCOMER_GRADUATION");
	self:RegisterEvent("CHAT_REGIONAL_STATUS_CHANGED");
	self:RegisterEvent("CHAT_REGIONAL_SEND_FAILED");
	self:RegisterEvent("NOTIFY_CHAT_SUPPRESSED");
	self:RegisterEvent("CAUTIONARY_CHAT_MESSAGE");

	self.channelList = {};
	self.zoneChannelList = {};
	self.messageTypeList = {};

	-- Hook orginal AddMessage function for use in override function in order to keep calls secure
	self.BaseAddMessage = self.AddMessage;
	self.AddMessage = ChatFrame_AddMessage;

	local function OnValueChanged(o, setting, value)
		ChatFrame_UpdateChatFrames();
	end
	Settings.SetOnValueChangedCallback("chatStyle", OnValueChanged);

	local noMouseWheel = not GetCVarBool("chatMouseScroll");
	ScrollUtil.InitScrollingMessageFrameWithScrollBar(self, self.ScrollBar, noMouseWheel);

	-- Scroll bar alpha is managed by a cursor test over the chat frame. Set the initial alpha to 0
	-- so this doesn't appear before the cursor test ever passes. See FCF_FadeInScrollbar and
	-- FCF_FadeOutScrollbar.
	self.ScrollBar:SetAlpha(0);
end

function ChatFrame_UpdateChatFrames()
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName];
		ChatEdit_DeactivateChat(frame.editBox);
	end
	ChatEdit_ActivateChat(FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK).editBox);
	ChatEdit_DeactivateChat(FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK).editBox);
end

function ChatFrame_RegisterForMessages(self, ...)
	local messageGroup;
	local index = 1;
	for i=1, select("#", ...) do
		messageGroup = ChatTypeGroup[select(i, ...)];
		if ( messageGroup ) then
			self.messageTypeList[index] = select(i, ...);
			for _, value in pairs(messageGroup) do
				self:RegisterEvent(value);
				if ( value == "CHAT_MSG_VOICE_TEXT" ) then
					self:RegisterEvent("VOICE_CHAT_CHANNEL_TRANSCRIBING_CHANGED");
				end
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
		tinsert(chatFrame.messageTypeList, group);
		for index, value in pairs(info) do
			chatFrame:RegisterEvent(value);
		end
		AddChatWindowMessages(chatFrame:GetID(), group);
	end
end

function ChatFrame_ContainsMessageGroup(chatFrame, group)
	for i, messageType in pairs(chatFrame.messageTypeList) do
		if group == messageType then
			return true;
		end
	end

	return false;
end

function ChatFrame_AddSingleMessageType(chatFrame, messageType)
	local group = ChatTypeGroupInverted[messageType];
	local info = ChatTypeGroup[group];
	if ( info ) then
		if (not tContains(chatFrame.messageTypeList, group)) then
			tinsert(chatFrame.messageTypeList, group);
		end
		for index, value in pairs(info) do
			if (value == messageType) then
				chatFrame:RegisterEvent(value);
			end
		end
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

function ChatFrame_UnregisterAllMessageGroups(chatFrame)
	for index, value in pairs(chatFrame.messageTypeList) do
		for eventIndex, eventValue in pairs(ChatTypeGroup[value]) do
			chatFrame:UnregisterEvent(eventValue);
		end
	end

	chatFrame.messageTypeList = {};
end

function ChatFrame_RemoveAllMessageGroups(chatFrame)
	for index, value in pairs(chatFrame.messageTypeList) do
		RemoveChatWindowMessages(chatFrame:GetID(), value);
	end

	-- Must be after "for" loop because this call clears messageTypeList.
	ChatFrame_UnregisterAllMessageGroups(chatFrame);
end

function ChatFrame_ContainsChannel(chatFrame, channel)
	for i, channelName in pairs(chatFrame.channelList) do
		if channel == channelName then
			return true;
		end
	end

	return false;
end

function ChatFrame_AddNewCommunitiesChannel(chatFrameIndex, clubId, streamId, setEditBoxToChannel)
	local clubInfo = C_Club.GetClubInfo(clubId);
	if clubInfo then
		C_Club.AddClubStreamChatChannel(clubId, streamId);

		local channelColor = DEFAULT_CHAT_CHANNEL_COLOR;
		local channelName = Chat_GetCommunitiesChannelName(clubId, streamId);
		if clubInfo.clubType == Enum.ClubType.BattleNet then
			channelColor = BATTLENET_FONT_COLOR;

			local channel = Chat_GetCommunitiesChannel(clubId, streamId);
			ChangeChatColor(channel, channelColor:GetRGB());
		end

		local chatFrame = _G["ChatFrame"..chatFrameIndex];
		ChatFrame_AddCommunitiesChannel(chatFrame, channelName, channelColor, setEditBoxToChannel);
	end
end

function ChatFrame_AddCommunitiesChannel(chatFrame, channelName, channelColor, setEditBoxToChannel)
	local channelIndex = ChatFrame_AddChannel(chatFrame, channelName);
	chatFrame:AddMessage(COMMUNITIES_CHANNEL_ADDED_TO_CHAT_WINDOW:format(channelIndex, ChatFrame_ResolveChannelName(channelName)), channelColor:GetRGB());

	if setEditBoxToChannel then
		chatFrame.editBox:SetAttribute("channelTarget", channelIndex);
		chatFrame.editBox:SetAttribute("chatType", "CHANNEL");
		chatFrame.editBox:SetAttribute("stickyType", "CHANNEL");
		ChatEdit_UpdateHeader(chatFrame.editBox);
	end
end

function ChatFrame_GetFullChannelInfo(channelIdentifier)
	local channelInfo = C_ChatInfo.GetChannelInfoFromIdentifier(channelIdentifier);
	if channelInfo then
		channelInfo.humanReadableName = ChatFrame_ResolveChannelName(channelInfo.name);
	end

	return channelInfo;
end

function ChatFrame_CanAddChannel()
	return C_ChatInfo.GetNumActiveChannels() < MAX_WOW_CHAT_CHANNELS;
end

function ChatFrame_AddChannel(chatFrame, channel)
	if ( not AddChatWindowChannel ) then
		return nil;
	end

	local channelIndex = nil;
	local zoneChannel = AddChatWindowChannel(chatFrame:GetID(), channel);
	if ( zoneChannel ) then
		local i = 1;
		while ( chatFrame.channelList[i] ) do
			i = i + 1;
		end
		chatFrame.channelList[i] = channel;
		chatFrame.zoneChannelList[i] = zoneChannel;

		local localId = GetChannelName(channel);
		channelIndex = localId;
	end

	return channelIndex;
end

function ChatFrame_SetChannelEnabled(chatFrame, channel, enabled)
	if enabled then
		ChatFrame_AddChannel(chatFrame, channel);
	else
		ChatFrame_RemoveChannel(chatFrame, channel);
	end
end

local function ChatFrame_CheckAddChannel(chatFrame, eventType, channelID)
	-- This is called in the event that a user receives chat events for a channel that isn't enabled for any chat frames.
	-- Minor hack, because chat channel filtering is backed by the client, but driven entirely from Lua.
	-- This solves the issue of Guides abdicating their status, and then re-applying in the same game session, unless ChatFrame_AddChannel
	-- is called, the channel filter will be off even though it's still enabled in the client, since abdication removes the chat channel and its config.

	-- Only add to default (since multiple chat frames receive the event and we don't want to add to others)
	if chatFrame ~= DEFAULT_CHAT_FRAME then
		return false;
	end

	-- Only add if the user is joining a channel
	if eventType ~= "YOU_CHANGED" then
		return false;
	end

	-- Only add regional channels
	 if not C_ChatInfo.IsChannelRegionalForChannelID(channelID) then
	 	return false;
	 end

	return ChatFrame_AddChannel(chatFrame, C_ChatInfo.GetChannelShortcutForChannelID(channelID)) ~= nil;
end

function ChatFrame_GetCommunitiesChannelLocalID(clubId, streamId)
	local channelName = Chat_GetCommunitiesChannelName(clubId, streamId);
	local localID = GetChannelName(channelName);
	return localID;
end

function ChatFrame_RemoveCommunitiesChannel(chatFrame, clubId, streamId, omitMessage)
	local channelName = Chat_GetCommunitiesChannelName(clubId, streamId);
	local channelIndex = ChatFrame_RemoveChannel(chatFrame, channelName);

	if not omitMessage then
		local r, g, b = Chat_GetCommunitiesChannelColor(clubId, streamId);
		chatFrame:AddMessage(COMMUNITIES_CHANNEL_REMOVED_FROM_CHAT_WINDOW:format(channelIndex, ChatFrame_ResolveChannelName(channelName)), r, g, b);
	end
end

function ChatFrame_RemoveChannel(chatFrame, channel)
	for index, value in pairs(chatFrame.channelList) do
		if ( strupper(channel) == strupper(value) ) then
			chatFrame.channelList[index] = nil;
			chatFrame.zoneChannelList[index] = nil;
		end
	end

	local localId = GetChannelName(channel);
	RemoveChatWindowChannel(chatFrame:GetID(), channel);
	return localId;
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

function ChatFrame_OnEvent(self, event, ...)
	if ( self.customEventHandler and self.customEventHandler(self, event, ...) ) then
		return;
	end

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

function ChatFrame_UpdateColorByID(self, chatTypeID, r, g, b)
	local function TransformColorByID(text, messageR, messageG, messageB, messageChatTypeID, messageAccessID, lineID)
		if messageChatTypeID == chatTypeID then
			return true, r, g, b;
		end
		return false;
	end
	self:AdjustMessageColors(TransformColorByID);
end

-- NOTE: The leave channel event happens before the channel info is removed from the client, so excludeChannels that you're leaving if you don't
-- want to count them.
local function GetFirstChannelIDOfChannelMatchingRuleset(ruleset, excludeChannel)
	for i = 1, GetNumDisplayChannels() do
		local localID, _, active = select(4, GetChannelDisplayInfo(i));
		if active and localID and localID > 0 and localID ~= excludeChannel then
			if C_ChatInfo.GetChannelRuleset(localID) == ruleset then
				return localID;
			end
		end
	end

	return nil;
end

function GetSlashCommandForChannelOpenChat(localID)
  	return "/" .. localID;
end

local function HasNewcomerChannelEnabled(chatFrame)
	for i, channelID in ipairs(chatFrame.zoneChannelList) do
		if C_ChatInfo.GetChannelRulesetForChannelID(channelID) == Enum.ChatChannelRuleset.Mentor then
			return true;
		end
	end
	return false;
end

function ChatFrame_GetDefaultChatTarget(chatFrame)
	if IsActivePlayerNewcomer() then
		if HasNewcomerChannelEnabled(chatFrame) then
			local localID = GetFirstChannelIDOfChannelMatchingRuleset(Enum.ChatChannelRuleset.Mentor);
			if localID then
				return "CHANNEL", localID;
			end
		end
	end

	if #chatFrame.messageTypeList == 1 and #chatFrame.channelList == 0 then
		return chatFrame.messageTypeList[1], nil;
	elseif #chatFrame.messageTypeList == 0 and #chatFrame.channelList == 1 then
		local channelName = chatFrame.channelList[1];
		local localID = GetChannelName(channelName);
		if localID ~= 0 then
			return "CHANNEL", localID;
		else
			return "CHANNEL", channelName;
		end
	end

	return nil;
end

function ChatFrame_UpdateDefaultChatTarget(self)
	local defaultChatType, defaultChannelTarget = ChatFrame_GetDefaultChatTarget(self);
	if defaultChatType then
		local editBox = self.editBox;
		editBox:SetAttribute("chatType", defaultChatType);
		editBox:SetAttribute("stickyType", defaultChatType);
		editBox:SetAttribute("channelTarget", defaultChannelTarget);
		ChatEdit_UpdateHeader(editBox);
	end
end

function ChatFrame_ConfigEventHandler(self, event, ...)
	if C_Glue.IsOnGlueScreen() and not C_GameRules.IsGameRuleActive(Enum.GameRule.FrontEndChat) then
		return;
	end

	if ( event == "PLAYER_ENTERING_WORLD" ) then
		self.defaultLanguage = GetDefaultLanguage();
		self.alternativeDefaultLanguage = GetAlternativeDefaultLanguage();

		if self == DEFAULT_CHAT_FRAME then
			ChatEdit_UpdateNewcomerEditBoxHint(self.editBox);

			local isInitialLogin, isUIReload = ...;
			if isInitialLogin then
				C_Timer.After(3, ChatFrame_CheckShowNewcomerGraduation);
			end
		end
		return true;
	elseif ( event == "SETTINGS_LOADED" ) then
		ChatFrame_UpdateChatFrames();
	elseif ( event == "NEUTRAL_FACTION_SELECT_RESULT" ) then
		self.defaultLanguage = GetDefaultLanguage();
		self.alternativeDefaultLanguage = GetAlternativeDefaultLanguage();
		return true;
	elseif ( event == "ALTERNATIVE_DEFAULT_LANGUAGE_CHANGED" ) then
		self.alternativeDefaultLanguage = GetAlternativeDefaultLanguage();
		return true;
	elseif ( event == "NEWCOMER_GRADUATION" ) then
		local isFromEvent = true;
		ChatFrame_CheckShowNewcomerGraduation(isFromEvent);
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
		-- UPDATE_CHAT_WINDOWS can be received before settings have been downloaded, so reset current state.
		ChatFrame_UnregisterAllMessageGroups(self);
		ChatFrame_RegisterForMessages(self, GetChatWindowMessages(self:GetID()));
		ChatFrame_RegisterForChannels(self, GetChatWindowChannels(self:GetID()));

		ChatFrame_UpdateDefaultChatTarget(self);

		if not C_Glue.IsOnGlueScreen() then
			-- GMOTD may have arrived before this frame registered for the event
			if ( not self.checkedGMOTD and self:IsEventRegistered("GUILD_MOTD") ) then
				self.checkedGMOTD = true;
				ChatFrame_DisplayGMOTD(self, GetGuildRosterMOTD());
			end
		end
		return true;
	end

	local arg1, arg2, arg3, arg4 = ...;
	if ( event == "UPDATE_CHAT_COLOR" ) then
		local info = ChatTypeInfo[strupper(arg1)];
		if ( info ) then
			info.r = arg2;
			info.g = arg3;
			info.b = arg4;
			ChatFrame_UpdateColorByID(self, info.id, info.r, info.g, info.b);

			if ( strupper(arg1) == "WHISPER" ) then
				info = ChatTypeInfo["REPLY"];
				if ( info ) then
					info.r = arg2;
					info.g = arg3;
					info.b = arg4;
					ChatFrame_UpdateColorByID(self, info.id, info.r, info.g, info.b);
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
	end
end

local function GetRegionalChatAvailableString()
	return DoesActivePlayerHaveMentorStatus() and NPEV2_CHAT_AVAILABLE or NPEV2_REGIONAL_CHAT_AVAILABLE;
end

local function GetRegionalChatUnavailableString()
	return DoesActivePlayerHaveMentorStatus() and NPEV2_CHAT_UNAVAILABLE or NPEV2_REGIONAL_CHAT_UNAVAILABLE;
end

function ChatFrame_SystemEventHandler(self, event, ...)
	if ( event == "TIME_PLAYED_MSG" ) then
		local arg1, arg2 = ...;
		ChatFrame_DisplayTimePlayed(self, arg1, arg2);
		return true;
	elseif ( event == "PLAYER_LEVEL_CHANGED" ) then
		local oldLevel, newLevel, real = ...;
		if real and oldLevel ~= 0 and newLevel ~= 0 then
			if newLevel > oldLevel then
				local chatLinkLevelToastsDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.ChatLinkLevelToastsDisabled) or C_PlayerInfo.IsPlayerNPERestricted();
				local levelstring = not chatLinkLevelToastsDisabled and format(LEVEL_UP, newLevel, newLevel) or format(LEVEL_UP_NO_LINK, newLevel);
				local info = ChatTypeInfo["SYSTEM"];
				self:AddMessage(levelstring, info.r, info.g, info.b, info.id);
			end

		end
		return true;
	elseif ( event == "CHARACTER_POINTS_CHANGED" ) then
		local arg1 = ...;
		local info = ChatTypeInfo["SYSTEM"];
		return true;
	elseif ( event == "GUILD_MOTD" ) then
		ChatFrame_DisplayGMOTD(self, ...);
		return true;
	elseif ( event == "UPDATE_INSTANCE_INFO" ) then
		if ( RaidFrame.hasRaidInfo ) then
			local info = ChatTypeInfo["SYSTEM"];
			if ( RaidFrame.slashCommand and GetNumSavedInstances() + GetNumSavedWorldBosses() == 0 and self == DEFAULT_CHAT_FRAME) then
				self:AddMessage(NO_RAID_INSTANCES_SAVED, info.r, info.g, info.b, info.id);
				RaidFrame.slashCommand = nil;
			end
		end
		return true;
	elseif ( event == "CHAT_SERVER_DISCONNECTED" ) then
		local info = ChatTypeInfo["SYSTEM"];
		local isInitialMessage = ...;
		self:AddMessage(CHAT_SERVER_DISCONNECTED_MESSAGE, info.r, info.g, info.b, info.id);
		return true;
	elseif ( event == "CHAT_SERVER_RECONNECTED" ) then
		local info = ChatTypeInfo["SYSTEM"];
		self:AddMessage(CHAT_SERVER_RECONNECTED_MESSAGE, info.r, info.g, info.b, info.id);
		return true;
	elseif ( event == "BN_CONNECTED" ) then
		local suppressNotification = ...;
		local info = ChatTypeInfo["SYSTEM"];
		if not suppressNotification then
			self:AddMessage(BN_CHAT_CONNECTED, info.r, info.g, info.b, info.id);
		end
	elseif ( event == "BN_DISCONNECTED" ) then
		local _, suppressNotification = ...;
		local info = ChatTypeInfo["SYSTEM"];
		if not suppressNotification then
			self:AddMessage(BN_CHAT_DISCONNECTED, info.r, info.g, info.b, info.id);
		end
	elseif event == "CHAT_REGIONAL_STATUS_CHANGED" then
		local isServiceAvailable = ...;
		local info = ChatTypeInfo["SYSTEM"];
		if isServiceAvailable then
			self:AddMessage(GetRegionalChatAvailableString(), info.r, info.g, info.b, info.id);
		else
			self:AddMessage(GetRegionalChatUnavailableString(), info.r, info.g, info.b, info.id);
		end
		return true;
	elseif event == "CHAT_REGIONAL_SEND_FAILED" then
		local info = ChatTypeInfo["SYSTEM"];
		self:AddMessage(GetRegionalChatUnavailableString(), info.r, info.g, info.b, info.id);
		return true;
	elseif event == "NOTIFY_CHAT_SUPPRESSED" then
		local hyperlink = string.format("|Haadcopenconfig|h[%s]", RESTRICT_CHAT_CONFIG_HYPERLINK);
		local message = string.format(RESTRICT_CHAT_CHATFRAME_FORMAT, RESTRICT_CHAT_MESSAGE_SUPPRESSED, LIGHTBLUE_FONT_COLOR:WrapTextInColorCode(hyperlink));
		local info = ChatTypeInfo["SYSTEM"];
		self:AddMessage(message, info.r, info.g, info.b, info.id);
		return true;
	elseif ( event == "PLAYER_REPORT_SUBMITTED" ) then
		local guid = ...;
		FCF_RemoveAllMessagesFromChanSender(self, guid);
		return true;
	elseif ( event == "CLUB_REMOVED" ) then
		local clubId = ...;
		local streamIDs = C_ChatInfo.GetClubStreamIDs(clubId);
		for k, streamID in pairs(streamIDs) do
			local channelName = Chat_GetCommunitiesChannelName(clubId, streamID);

			local function RemoveClubChannelFromChatWindow(chatWindow, chatWindowIndex)
				if ChatFrame_ContainsChannel(chatWindow, channelName) then
					local omitMessage = true;
					ChatFrame_RemoveCommunitiesChannel(chatWindow, clubId, streamID, omitMessage);
				end
			end

			FCF_IterateActiveChatWindows(RemoveClubChannelFromChatWindow);
		end
	elseif(event == "DISPLAY_EVENT_TOAST_LINK") then
		EventToastManagerFrame:DisplayToastLink(self, ...);
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

	--ambiguate guild chat names
	if ( Ambiguate ) then
		if (chatType == "GUILD") then
			arg2 = Ambiguate(arg2, "guild")
		else
			arg2 = Ambiguate(arg2, "none")
		end
	end

	-- arg12 is senderGUID, add timerunning icon when necessary based on player guid
	if arg12 and C_ChatInfo.IsTimerunningPlayer(arg12) then
		arg2 = TimerunningUtil.AddSmallIcon(arg2);
	end

	if ( arg12 and info and Chat_ShouldColorChatByClass(info) and GetPlayerInfoByGUID ~= nil ) then
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

function RemoveExtraSpaces(str)
	return string.gsub(str, "     +", "    ");	--Replace all instances of 5+ spaces with only 4 spaces.
end

function RemoveNewlines(str)
	return string.gsub(str, "\n", "");
end

function ChatFrame_DisplayGMOTD(frame, gmotd)
	if ( gmotd and (gmotd ~= "") ) then
		local info = ChatTypeInfo["GUILD"];
		local string = format(GUILD_MOTD_TEMPLATE, gmotd);
		frame:AddMessage(string, info.r, info.g, info.b, info.id);
	end
end

function ChatFrame_GetMobileEmbeddedTexture(r, g, b)
	r, g, b = floor(r * 255), floor(g * 255), floor(b * 255);
	return format("|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat:14:14:0:0:16:16:0:16:0:16:%d:%d:%d|t", r, g, b);
end

function ChatFrame_CanChatGroupPerformExpressionExpansion(chatGroup)
	if chatGroup == "RAID" then
		return true;
	end

	if chatGroup == "INSTANCE_CHAT" then
		return IsInRaid(LE_PARTY_CATEGORY_INSTANCE);
	end

	return false;
end

function DoesActivePlayerHaveMentorStatus()
	if C_Glue.IsOnGlueScreen() then
		return false;
	end

	return C_PlayerMentorship.IsActivePlayerConsideredNewcomer() or (C_PlayerMentorship.GetMentorshipStatus(PlayerLocation:CreateFromUnit("player")) ~= Enum.PlayerMentorshipStatus.None);
end

function IsActivePlayerGuide()
	if C_Glue.IsOnGlueScreen() then
		return false;
	end

	return C_PlayerMentorship.GetMentorshipStatus(PlayerLocation:CreateFromUnit("player")) == Enum.PlayerMentorshipStatus.Mentor;
end

function IsActivePlayerNewcomer()
	if C_Glue.IsOnGlueScreen() then
		return false;
	end

	return C_PlayerMentorship.GetMentorshipStatus(PlayerLocation:CreateFromUnit("player")) == Enum.PlayerMentorshipStatus.Newcomer;
end

function ChatFrame_GetMentorChannelStatus(entityStatus, channelRuleSet)
	if entityStatus == Enum.PlayerMentorshipStatus.Mentor then
		local shouldShowGuideStatus = C_PlayerMentorship.IsActivePlayerConsideredNewcomer() or (IsActivePlayerGuide() and channelRuleSet == Enum.ChatChannelRuleset.Mentor);
		if shouldShowGuideStatus then
			return Enum.PlayerMentorshipStatus.Mentor;
		end
	elseif entityStatus == Enum.PlayerMentorshipStatus.Newcomer then
		if IsActivePlayerGuide() then
			return Enum.PlayerMentorshipStatus.Newcomer;
		end
	end

	return Enum.PlayerMentorshipStatus.None;
end

local function GetAssertPFlagMessage(specialFlag)
	return string.format("'pflag' at _G[CHAT_FLAG_%s] doesn't exist.", specialFlag);
end

local function GetPFlag(specialFlag, zoneChannelID, localChannelID)
	if specialFlag ~= "" then
		if specialFlag == "GM" or specialFlag == "DEV" then
			-- Add Blizzard Icon if  this was sent by a GM/DEV
			return "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16|t ";
		elseif specialFlag == "GUIDE" then
			if ChatFrame_GetMentorChannelStatus(Enum.PlayerMentorshipStatus.Mentor, C_ChatInfo.GetChannelRulesetForChannelID(zoneChannelID)) == Enum.PlayerMentorshipStatus.Mentor then
				return NPEV2_CHAT_USER_TAG_GUIDE .. " "; -- possibly unable to save global string with trailing whitespace...
			end
		elseif specialFlag == "NEWCOMER" then
			if ChatFrame_GetMentorChannelStatus(Enum.PlayerMentorshipStatus.Newcomer, C_ChatInfo.GetChannelRulesetForChannelID(zoneChannelID)) == Enum.PlayerMentorshipStatus.Newcomer then
				return NPEV2_CHAT_USER_TAG_NEWCOMER;
			end
		else
			local pflag = _G["CHAT_FLAG_"..specialFlag];
			assertsafe(pflag ~= nil, GetAssertPFlagMessage, specialFlag);
			return pflag or "";
		end
	end

	return "";
end

function ChatFrame_ShowNewcomerGraduation(s)
	local localID = C_ChatInfo.GetGeneralChannelLocalID();
	local slashCmd;

	if localID then
		slashCmd = GetSlashCommandForChannelOpenChat(localID);
	else
		slashCmd = ("%s %s"):format(SLASH_JOIN1, C_ChatInfo.GetChannelShortcutForChannelID(C_ChatInfo.GetGeneralChannelID()));
	end

	ChatFrame_DisplaySystemMessageInPrimary(s:format(slashCmd));
end

function ChatFrame_CheckShowNewcomerGraduation(isFromGraduationEvent)
	local hasShownGraduation = GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_NEWCOMER_GRADUATION);
	if not hasShownGraduation and isFromGraduationEvent then
		ChatFrame_ShowNewcomerGraduation(NPEV2_CHAT_NEWCOMER_GRADUATION);
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_NEWCOMER_GRADUATION, true);
	elseif hasShownGraduation and not isFromGraduationEvent and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_NEWCOMER_GRADUATION_REMINDER) then
		ChatFrame_ShowNewcomerGraduation(NPEV2_CHAT_NEWCOMER_GRADUATION_REMINDER);
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_NEWCOMER_GRADUATION_REMINDER, true);
	end
end

local function FlashTabIfNotShown(frame, info, type, chatGroup, chatTarget)
	if ( not frame:IsShown() ) then
		if ( (frame == DEFAULT_CHAT_FRAME and info.flashTabOnGeneral) or (frame ~= DEFAULT_CHAT_FRAME and info.flashTab) ) then
			if ( not CHAT_OPTIONS.HIDE_FRAME_ALERTS or type == "WHISPER" or type == "BN_WHISPER" ) then	--BN_WHISPER FIXME
				if (not FCFManager_ShouldSuppressMessageFlash(frame, chatGroup, chatTarget) ) then
					FCF_StartAlertFlash(frame);
				end
			end
		end
	end
end

local function GetAssertOutMessageFormatKeyMessage(type)
	return string.format("'formatKey' at _G[CHAT_%s_TYPE] doesn't exist.", type);
end

local function GetOutMessageFormatKey(type)
	local formatKey = _G["CHAT_"..type.."_GET"];
	assertsafe(formatKey ~= nil, GetAssertOutMessageFormatKeyMessage, type);
	return formatKey or "";
end

function ChatFrame_HandleCautionaryChatMessage(hyperlinkLineID, confirmNumber)
	local function DoesMessageLineIDMatch(message, r, g, b, infoID, accessID, typeID, event, eventArgs, MessageFormatter, ...)
		if not eventArgs then
			return false;
		end

		local lineID = eventArgs[11];
		return lineID == hyperlinkLineID and type(eventArgs[2]) == "string";
	end

	local function SetMessage(message, r, g, b, infoID, accessID, typeID, event, eventArgs, MessageFormatter, ...)
		local lineID = eventArgs[11];
		local sendTo = eventArgs[2];

		local text = C_ChatInfo.GetChatLineText(lineID);
		local formatArg = MessageFormatter(text);
		local formattedText = CENSORED_MESSAGE_SENDER:format(formatArg, sendTo, lineID, confirmNumber, sendTo, lineID, confirmNumber, sendTo);
		return formattedText, r, g, b, infoID, accessID, typeID, event, eventArgs, MessageFormatter, ...;
	end

	-- The line may be present in multiple chat windows, particularly if chat settings are configured to
	-- send the line to both the default chat window and a whisper tab.
	ChatFrameUtil.ForEachChatFrame(function(chatFrame)
		chatFrame:TransformMessages(DoesMessageLineIDMatch, SetMessage);
	end);
end

function ChatFrame_MessageEventHandler(self, event, ...)
	if ( TextToSpeechFrame_MessageEventHandler ~= nil ) then
		TextToSpeechFrame_MessageEventHandler(self, event, ...)
	end

	if event == "CAUTIONARY_CHAT_MESSAGE" then
		local hyperlinkLineID, confirmNumber = ...;
		ChatFrame_HandleCautionaryChatMessage(hyperlinkLineID, confirmNumber);
	elseif ( strsub(event, 1, 8) == "CHAT_MSG" ) then
		local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = ...;
		if (arg16) then
			-- hiding sender in letterbox: do NOT even show in chat window (only shows in cinematic frame)
			return true;
		end

		local type = strsub(event, 10);
		local info = ChatTypeInfo[type];

		--If it was a GM whisper, dispatch it to the GMChat addon.
		if arg6 == "GM" and type == "WHISPER" then
			return;
		end

		local filter = false;
		if ( chatFilters[event] ) then
			local newarg1, newarg2, newarg3, newarg4, newarg5, newarg6, newarg7, newarg8, newarg9, newarg10, newarg11, newarg12, newarg13, newarg14;
			for _, filterFunc in next, chatFilters[event] do
				filter, newarg1, newarg2, newarg3, newarg4, newarg5, newarg6, newarg7, newarg8, newarg9, newarg10, newarg11, newarg12, newarg13, newarg14 = filterFunc(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14);
				if ( filter ) then
					return true;
				elseif ( newarg1 ) then
					arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14 = newarg1, newarg2, newarg3, newarg4, newarg5, newarg6, newarg7, newarg8, newarg9, newarg10, newarg11, newarg12, newarg13, newarg14;
				end
			end
		end

		local coloredName = GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14);

		local channelLength = strlen(arg4);
		local infoType = type;

		if type == "VOICE_TEXT" and not GetCVarBool("speechToText") then
			return;

		elseif ( (type == "COMMUNITIES_CHANNEL") or ((strsub(type, 1, 7) == "CHANNEL") and (type ~= "CHANNEL_LIST") and ((arg1 ~= "INVITE") or (type ~= "CHANNEL_NOTICE_USER"))) ) then
			if ( arg1 == "WRONG_PASSWORD" ) then
				local staticPopup = _G[StaticPopup_Visible("CHAT_CHANNEL_PASSWORD") or ""];
				if ( staticPopup and strupper(staticPopup.data) == strupper(arg9) ) then
					-- Don't display invalid password messages if we're going to prompt for a password (bug 102312)
					return;
				end
			end

			local found = false;
			for index, value in pairs(self.channelList) do
				if ( channelLength > strlen(value) ) then
					-- arg9 is the channel name without the number in front...
					if ( ((arg7 > 0) and (self.zoneChannelList[index] == arg7)) or (strupper(value) == strupper(arg9)) ) then
						found = true;
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
			if not found or not info then
				local eventType, channelID = arg1, arg7;
				if not ChatFrame_CheckAddChannel(self, eventType, channelID) then
					return true;
				end
			end
		end

		local chatGroup = Chat_GetChatCategory(type);
		local chatTarget = FCFManager_GetChatTarget(chatGroup, arg2, arg8);

		if ( FCFManager_ShouldSuppressMessage(self, chatGroup, chatTarget) ) then
			return true;
		end

		if ( chatGroup == "WHISPER" or chatGroup == "BN_WHISPER" ) then
			if ( self.privateMessageList and not self.privateMessageList[strlower(arg2)] ) then
				return true;
			elseif ( self.excludePrivateMessageList and self.excludePrivateMessageList[strlower(arg2)]
				and ( (chatGroup == "WHISPER" and GetCVar("whisperMode") ~= "popout_and_inline") or (chatGroup == "BN_WHISPER" and GetCVar("whisperMode") ~= "popout_and_inline") ) ) then
				return true;
			end
		end

		if (self.privateMessageList) then
			-- Dedicated BN whisper windows need online/offline messages for only that player
			if ( (chatGroup == "BN_INLINE_TOAST_ALERT" or chatGroup == "BN_WHISPER_PLAYER_OFFLINE") and not self.privateMessageList[strlower(arg2)] ) then
				return true;
			end

			-- HACK to put certain system messages into dedicated whisper windows
			if ( chatGroup == "SYSTEM") then
				local matchFound = false;
				local message = strlower(arg1);
				for playerName, _ in pairs(self.privateMessageList) do
					local playerNotFoundMsg = strlower(format(ERR_CHAT_PLAYER_NOT_FOUND_S, playerName));
					local charOnlineMsg = strlower(format(ERR_FRIEND_ONLINE_SS, playerName, playerName));
					local charOfflineMsg = strlower(format(ERR_FRIEND_OFFLINE_S, playerName));
					if ( message == playerNotFoundMsg or message == charOnlineMsg or message == charOfflineMsg) then
						matchFound = true;
						break;
					end
				end

				if (not matchFound) then
					return true;
				end
			end
		end

		if ( type == "SYSTEM" or type == "SKILL" or type == "CURRENCY" or type == "MONEY" or
			 type == "OPENING" or type == "TRADESKILLS" or type == "PET_INFO" or type == "TARGETICONS" or type == "BN_WHISPER_PLAYER_OFFLINE") then
			self:AddMessage(arg1, info.r, info.g, info.b, info.id);
		elseif (type == "LOOT") then
			self:AddMessage(arg1, info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,7) == "COMBAT_" ) then
			self:AddMessage(arg1, info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,6) == "SPELL_" ) then
			self:AddMessage(arg1, info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,10) == "BG_SYSTEM_" ) then
			self:AddMessage(arg1, info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,11) == "ACHIEVEMENT" ) then
			self:AddMessage(arg1:format(GetPlayerLink(arg2, ("[%s]"):format(coloredName))), info.r, info.g, info.b, info.id);
		elseif ( strsub(type,1,18) == "GUILD_ACHIEVEMENT" ) then
			local message = arg1:format(GetPlayerLink(arg2, ("[%s]"):format(coloredName)));
			self:AddMessage(message, info.r, info.g, info.b, info.id);
		elseif (type == "PING") then
			--Add Timestamps
			local chatTimestampFmt = GetChatTimestampFormat();
			local outMsg = arg1;
			if ( chatTimestampFmt ) then
				outMsg = BetterDate(chatTimestampFmt, time())..outMsg;
			end

			self:AddMessage(outMsg, info.r, info.g, info.b, info.id);
		elseif ( type == "IGNORED" ) then
			self:AddMessage(format(CHAT_IGNORED, arg2), info.r, info.g, info.b, info.id);
		elseif ( type == "FILTERED" ) then
			self:AddMessage(format(CHAT_FILTERED, arg2), info.r, info.g, info.b, info.id);
		elseif ( type == "RESTRICTED" ) then
			self:AddMessage(CHAT_RESTRICTED_TRIAL, info.r, info.g, info.b, info.id);
		elseif ( type == "CHANNEL_LIST") then
			if(channelLength > 0) then
				self:AddMessage(format(GetOutMessageFormatKey(type)..arg1, tonumber(arg8), arg4), info.r, info.g, info.b, info.id);
			else
				self:AddMessage(arg1, info.r, info.g, info.b, info.id);
			end
		elseif (type == "CHANNEL_NOTICE_USER") then
			local globalstring = _G["CHAT_"..arg1.."_NOTICE_BN"];
			if ( not globalstring ) then
				globalstring = _G["CHAT_"..arg1.."_NOTICE"];
			end
			if not globalstring then
				GMError(("Missing global string for %q"):format("CHAT_"..arg1.."_NOTICE_BN"));
				return;
			end
			if(arg5 ~= "") then
				-- TWO users in this notice (E.G. x kicked y)
				self:AddMessage(format(globalstring, arg8, arg4, arg2, arg5), info.r, info.g, info.b, info.id);
			elseif ( arg1 == "INVITE" ) then
				local playerLink = GetPlayerLink(arg2, ("[%s]"):format(arg2), arg11);
				local accessID = ChatHistory_GetAccessID(chatGroup, chatTarget);
				local typeID = ChatHistory_GetAccessID(infoType, chatTarget, arg12);
				self:AddMessage(format(globalstring, arg4, playerLink), info.r, info.g, info.b, info.id, accessID, typeID);
			else
				self:AddMessage(format(globalstring, arg8, arg4, arg2), info.r, info.g, info.b, info.id);
			end
			if ( arg1 == "INVITE" and GetCVarBool("blockChannelInvites") ) then
				self:AddMessage(CHAT_MSG_BLOCK_CHAT_CHANNEL_INVITE, info.r, info.g, info.b, info.id);
			end
		elseif (type == "CHANNEL_NOTICE") then
			local accessID = ChatHistory_GetAccessID(Chat_GetChatCategory(type), arg8);
			local typeID = ChatHistory_GetAccessID(infoType, arg8, arg12);

			if arg1 == "YOU_CHANGED" and C_ChatInfo.GetChannelRuleset(arg8) == Enum.ChatChannelRuleset.Mentor then
				ChatFrame_UpdateDefaultChatTarget(self);
				ChatEdit_UpdateNewcomerEditBoxHint(self.editBox);
			else
				if arg1 == "YOU_LEFT" then
					ChatEdit_UpdateNewcomerEditBoxHint(self.editBox, arg8);
				end

				local globalstring;
				if ( arg1 == "TRIAL_RESTRICTED" ) then
					globalstring = CHAT_TRIAL_RESTRICTED_NOTICE_TRIAL;
				else
					globalstring = _G["CHAT_"..arg1.."_NOTICE_BN"];
					if ( not globalstring ) then
						globalstring = _G["CHAT_"..arg1.."_NOTICE"];
						if not globalstring then
							GMError(("Missing global string for %q"):format("CHAT_"..arg1.."_NOTICE"));
							return;
						end
					end
				end

				self:AddMessage(format(globalstring, arg8, ChatFrame_ResolvePrefixedChannelName(arg4)), info.r, info.g, info.b, info.id, accessID, typeID);
			end
		elseif ( type == "BN_INLINE_TOAST_ALERT" ) then
			local globalstring = _G["BN_INLINE_TOAST_"..arg1];
			if not globalstring then
				GMError(("Missing global string for %q"):format("BN_INLINE_TOAST_"..arg1));
				return;
			end
			local message;
			if ( arg1 == "FRIEND_REQUEST" ) then
				message = globalstring;
			elseif ( arg1 == "FRIEND_PENDING" ) then
				message = format(BN_INLINE_TOAST_FRIEND_PENDING, BNGetNumFriendInvites());
			elseif ( arg1 == "FRIEND_REMOVED" or arg1 == "BATTLETAG_FRIEND_REMOVED" ) then
				message = format(globalstring, arg2);
			elseif ( arg1 == "FRIEND_ONLINE" or arg1 == "FRIEND_OFFLINE") then
				local accountInfo = C_BattleNet.GetAccountInfoByID(arg13);
				if accountInfo and accountInfo.gameAccountInfo.clientProgram ~= "" then
					C_Texture.GetTitleIconTexture(accountInfo.gameAccountInfo.clientProgram, Enum.TitleIconVersion.Small, function(success, texture)
						if success then
							local characterName = BNet_GetValidatedCharacterNameWithClientEmbeddedTexture(accountInfo.gameAccountInfo.characterName, accountInfo.battleTag, texture, 32, 32, 10);
							local linkDisplayText = ("[%s] (%s)"):format(arg2, characterName);
							local playerLink = GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, Chat_GetChatCategory(type), 0);
							local message = format(globalstring, playerLink);
							self:AddMessage(message, info.r, info.g, info.b, info.id);
							FlashTabIfNotShown(self, info, type, chatGroup, chatTarget);
						end
					end);
					return;
				else
					local linkDisplayText = ("[%s]"):format(arg2);
					local playerLink = GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, Chat_GetChatCategory(type), 0);
					message = format(globalstring, playerLink);
				end
			else
				local linkDisplayText = ("[%s]"):format(arg2);
				local playerLink = GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, Chat_GetChatCategory(type), 0);
				message = format(globalstring, playerLink);
			end
			self:AddMessage(message, info.r, info.g, info.b, info.id);
		elseif ( type == "BN_INLINE_TOAST_BROADCAST" ) then
			if ( arg1 ~= "" ) then
				arg1 = RemoveNewlines(RemoveExtraSpaces(arg1));
				local linkDisplayText = ("[%s]"):format(arg2);
				local playerLink = GetBNPlayerLink(arg2, linkDisplayText, arg13, arg11, Chat_GetChatCategory(type), 0);
				self:AddMessage(format(BN_INLINE_TOAST_BROADCAST, playerLink, arg1), info.r, info.g, info.b, info.id);
			end
		elseif ( type == "BN_INLINE_TOAST_BROADCAST_INFORM" ) then
			if ( arg1 ~= "" ) then
				arg1 = RemoveExtraSpaces(arg1);
				self:AddMessage(BN_INLINE_TOAST_BROADCAST_INFORM, info.r, info.g, info.b, info.id);
			end
		else
			local msgTime = time();
			local playerName, lineID, bnetIDAccount = arg2, arg11, arg13;

			local function MessageFormatter(msg)
				local fontHeight = select(2, FCF_GetChatWindowInfo(self:GetID()));
				if ( fontHeight == 0 ) then
					--fontHeight will be 0 if it's still at the default (14)
					fontHeight = 14;
				end

				-- Add AFK/DND flags
				local pflag = GetPFlag(arg6, arg7, arg8);

				if ( type == "WHISPER_INFORM" and GMChatFrame_IsGM and GMChatFrame_IsGM(arg2) ) then
					return;
				end

				local showLink = 1;
				if ( strsub(type, 1, 7) == "MONSTER" or strsub(type, 1, 9) == "RAID_BOSS") then
					showLink = nil;
				else
					msg = gsub(msg, "%%", "%%%%");
				end

				-- Search for icon links and replace them with texture links.
				msg = C_ChatInfo.ReplaceIconAndGroupExpressions(msg, arg17, not ChatFrame_CanChatGroupPerformExpressionExpansion(chatGroup)); -- If arg17 is true, don't convert to raid icons

				--Remove groups of many spaces
				msg = RemoveExtraSpaces(msg);

				local playerLink;
				local playerLinkDisplayText = coloredName;
				local relevantDefaultLanguage = self.defaultLanguage;
				if ( (type == "SAY") or (type == "YELL") ) then
					relevantDefaultLanguage = self.alternativeDefaultLanguage;
				end
				local usingDifferentLanguage = (arg3 ~= "") and (arg3 ~= relevantDefaultLanguage);
				local usingEmote = (type == "EMOTE") or (type == "TEXT_EMOTE");

				if ( usingDifferentLanguage or not usingEmote ) then
					playerLinkDisplayText = ("[%s]"):format(coloredName);
				end

				local isCommunityType = type == "COMMUNITIES_CHANNEL";
				if ( isCommunityType ) then
					local isBattleNetCommunity = bnetIDAccount ~= nil and bnetIDAccount ~= 0;
					local messageInfo, clubId, streamId, clubType = C_Club.GetInfoFromLastCommunityChatLine();
					if (messageInfo ~= nil) then
						if ( isBattleNetCommunity ) then
							playerLink = GetBNPlayerCommunityLink(playerName, playerLinkDisplayText, bnetIDAccount, clubId, streamId, messageInfo.messageId.epoch, messageInfo.messageId.position);
						else
							playerLink = GetPlayerCommunityLink(playerName, playerLinkDisplayText, clubId, streamId, messageInfo.messageId.epoch, messageInfo.messageId.position);
						end
					else
						playerLink = playerLinkDisplayText;
					end
				else
					if ( type == "BN_WHISPER" or type == "BN_WHISPER_INFORM" ) then
						playerLink = GetBNPlayerLink(playerName, playerLinkDisplayText, bnetIDAccount, lineID, chatGroup, chatTarget);
					else
						playerLink = GetPlayerLink(playerName, playerLinkDisplayText, lineID, chatGroup, chatTarget);
					end
				end

				local message = msg;
				-- isMobile
				if arg14 then
					message = ChatFrame_GetMobileEmbeddedTexture(info.r, info.g, info.b)..message;
				end

				local outMsg;
				if ( usingDifferentLanguage ) then
					local languageHeader = "["..arg3.."] ";
					if ( showLink and (arg2 ~= "") ) then
						outMsg = format(GetOutMessageFormatKey(type)..languageHeader..message, pflag..playerLink);
					else
						outMsg = format(GetOutMessageFormatKey(type)..languageHeader..message, pflag..arg2);
					end
				else
					if ( not showLink or arg2 == "" ) then
						if ( type == "TEXT_EMOTE" ) then
							outMsg = message;
						else
							outMsg = format(GetOutMessageFormatKey(type)..message, pflag..arg2, arg2);
						end
					else
						if ( type == "EMOTE" ) then
							outMsg = format(GetOutMessageFormatKey(type)..message, pflag..playerLink);
						elseif ( type == "TEXT_EMOTE") then
							outMsg = string.gsub(message, arg2, pflag..playerLink, 1);
						elseif (type == "GUILD_ITEM_LOOTED") then
							outMsg = string.gsub(message, "$s", GetPlayerLink(arg2, playerLinkDisplayText));
						else
							outMsg = format(GetOutMessageFormatKey(type)..message, pflag..playerLink);
						end
					end
				end

				-- Add Channel
				if (channelLength > 0) then
					outMsg = "|Hchannel:channel:"..arg8.."|h["..ChatFrame_ResolvePrefixedChannelName(arg4).."]|h "..outMsg;
				end

				--Add Timestamps
				local chatTimestampFmt = GetChatTimestampFormat();
				if ( chatTimestampFmt ) then
					outMsg = BetterDate(chatTimestampFmt, msgTime)..outMsg;
				end

				return outMsg;
			end

			local isChatLineCensored = C_ChatInfo.IsChatLineCensored(lineID);
			local msg = isChatLineCensored and arg1 or MessageFormatter(arg1);
			local accessID = ChatHistory_GetAccessID(chatGroup, chatTarget);
			local typeID = ChatHistory_GetAccessID(infoType, chatTarget, arg12 or arg13);

			-- The message formatter is captured so that the original message can be reformatted when a censored message
			-- is approved to be shown.
			local eventArgs = SafePack(...);
			self:AddMessage(msg, info.r, info.g, info.b, info.id, accessID, typeID, event, eventArgs, MessageFormatter);
		end

		if ( type == "WHISPER" or type == "BN_WHISPER" ) then
			--BN_WHISPER FIXME
			ChatEdit_SetLastTellTarget(arg2, type);

			if ( not self.tellTimer or (GetTime() > self.tellTimer) ) then
				PlaySound(SOUNDKIT.TELL_MESSAGE);
			end
			self.tellTimer = GetTime() + CHAT_TELL_ALERT_TIME;
			--FCF_FlashTab(self);

			-- We don't flash the app icon for front end chat for now.
			if FlashClientIcon then
				FlashClientIcon();
			end
		end

		FlashTabIfNotShown(self, info, type, chatGroup, chatTarget);

		return true;
	elseif ( event == "VOICE_CHAT_CHANNEL_TRANSCRIBING_CHANGED" ) then
		local _, isNowTranscribing = ...
		if ( not self.isTranscribing and isNowTranscribing ) then
			ChatFrame_DisplaySystemMessage(self, SPEECH_TO_TEXT_STARTED);
		end
		self.isTranscribing = isNowTranscribing;
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
	local flash = self.ScrollToBottomButton.Flash;
	if flash then
		local shouldFlash = not self:AtBottom();

		if shouldFlash ~= UIFrameIsFlashing(flash) then
			if shouldFlash then
				UIFrameFlash(flash, .1, .1, -1, false, CHAT_BUTTON_FLASH_TIME, CHAT_BUTTON_FLASH_TIME);
				FCF_FadeInScrollbar(self);
			else
				UIFrameFlashStop(flash);
			end
		end
	end
end

function ChatFrame_OnHyperlinkShow(self, link, text, button)
	if not C_Glue.IsOnGlueScreen() then
		SetItemRef(link, text, button, self);
	end
end

function ChatFrame_OnMouseWheel(value)
	if ( value > 0 ) then
		SELECTED_DOCK_FRAME:ScrollUp();
	elseif ( value < 0 ) then
		SELECTED_DOCK_FRAME:ScrollDown();
	end
end

function ChatFrame_SetChatFocusOverride(editBoxOverride)
	CHAT_FOCUS_OVERRIDE = editBoxOverride;
end

function ChatFrame_GetChatFocusOverride()
	return CHAT_FOCUS_OVERRIDE;
end

function ChatFrame_ClearChatFocusOverride()
	CHAT_FOCUS_OVERRIDE = nil;
end

function ChatFrame_OpenChat(text, chatFrame, desiredCursorPosition)
	if chatFrame == nil and CHAT_FOCUS_OVERRIDE ~= nil then
		if CHAT_FOCUS_OVERRIDE.supportsSlashCommands or not text or strsub(text, 0, 1) ~= "/" then
			CHAT_FOCUS_OVERRIDE:SetFocus();
			if text then
				CHAT_FOCUS_OVERRIDE:SetText(text);
			end
			return;
		end
	end

	local editBox = ChatEdit_ChooseBoxForSend(chatFrame);

	-- GAME RULES TODO:: This should be an explicit game rule.
	if C_GameRules.GetActiveGameMode() == Enum.GameMode.Plunderstorm then
		if not HAS_INITIALIZED_DEFAULT_CHAT_CHANNEL then
			HAS_INITIALIZED_DEFAULT_CHAT_CHANNEL = true;

			-- Don't default chat type if we already have a specific type (i.e. BN_WHISPER)
			if editBox:GetAttribute("chatType") == "SAY" then
				local isInGroup;
				if IsInGroup(LE_PARTY_CATEGORY_HOME) then
					local groupCount = GetNumGroupMembers();
					if groupCount > 1 then
						isInGroup = true;
					end
				end

				local chatType = "SAY";
				if C_Glue.IsOnGlueScreen() then
					chatType = "PARTY";
				elseif isInGroup then
					chatType = "INSTANCE_CHAT";
				end

				editBox:SetAttribute("chatType", chatType);
				editBox:SetAttribute("stickyType", chatType);
			end
		end
	end

	ChatEdit_ActivateChat(editBox);
	editBox.desiredCursorPosition = desiredCursorPosition;

	if text then
		editBox.text = text;
		editBox.setText = 1;
	end

	if ( editBox:GetAttribute("chatType") == editBox:GetAttribute("stickyType") ) then
		if ( (editBox:GetAttribute("stickyType") == "PARTY") and (not IsInGroup(LE_PARTY_CATEGORY_HOME)) or
		(editBox:GetAttribute("stickyType") == "RAID") and (not IsInRaid(LE_PARTY_CATEGORY_HOME)) or
		(editBox:GetAttribute("stickyType") == "INSTANCE_CHAT") and (not IsInGroup(LE_PARTY_CATEGORY_INSTANCE))) then
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

function ChatFrame_SendTellWithMessage(name, text, chatFrame)
	local editBox = ChatEdit_ChooseBoxForSend(chatFrame);

	--DEBUG FIXME - for now, we're not going to remove spaces from names. We need to make sure X-server still works.
	-- Remove spaces from the server name for slash command parsing
	--name = gsub(name, " ", "");

	local formattedText = string.format("%s %s %s", SLASH_WHISPER1, name, text);
	if ( editBox ~= ChatEdit_GetActiveWindow() ) then
		ChatFrame_OpenChat(formattedText, chatFrame);
	else
		editBox:SetText(formattedText);
	end
	ChatEdit_ParseText(editBox, 0);
end

function ChatFrame_SendTell(name, chatFrame)
	local message = "";
	ChatFrame_SendTellWithMessage(name, message, chatFrame);
end

function ChatFrame_SendBNetTell(tokenizedName)
	local editBox = ChatEdit_ChooseBoxForSend();
	editBox:SetAttribute("tellTarget", tokenizedName);
	editBox:SetAttribute("chatType", "BN_WHISPER");
	if ( editBox ~= ChatEdit_GetActiveWindow() ) then
		ChatFrame_OpenChat("");
	else
		ChatEdit_UpdateHeader(editBox);
	end
end

function ChatFrame_ReplyTell(chatFrame)
	local editBox = ChatEdit_ChooseBoxForSend(chatFrame);

	local lastTell, lastTellType = ChatEdit_GetLastTellTarget();
	if ( lastTell ) then
		--BN_WHISPER FIXME
		editBox:SetAttribute("chatType", lastTellType);
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

	local lastTold, lastToldType = ChatEdit_GetLastToldTarget();
	if ( lastTold ) then
		--BN_WHISPER FIXME
		editBox:SetAttribute("chatType", lastToldType);
		editBox:SetAttribute("tellTarget", lastTold);
		ChatEdit_UpdateHeader(editBox);
		if ( editBox ~= ChatEdit_GetActiveWindow() ) then
			ChatFrame_OpenChat("", chatFrame);
		end
	else
		-- Error message
	end
end

function ChatFrame_DisplayHelpTextSimple(frame)
	if ( not frame ) then
		return;
	end

	local info = ChatTypeInfo["SYSTEM"];
	frame:AddMessage(HELP_TEXT_SIMPLE, info.r, info.g, info.b, info.id);

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
		if ( i == 10 or i == 15 ) then
			i = i + 1;
		end
		text = _G["CHAT_HELP_TEXT_LINE"..i];
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
	string = format(TIME_PLAYED_LEVEL, format(TIME_DAYHOURMINUTESECOND, d, h, m, s));
	self:AddMessage(string, info.r, info.g, info.b, info.id);
end

function ChatFrame_ChatPageUp()
	SELECTED_CHAT_FRAME:PageUp();
end

function ChatFrame_ChatPageDown()
	SELECTED_CHAT_FRAME:PageDown();
end

function ChatFrame_DisplayUsageError(messageTag)
	ChatFrame_DisplaySystemMessageInPrimary(messageTag);
end

function ChatFrame_DisplaySystemMessageInPrimary(messageTag)
	local info = ChatTypeInfo["SYSTEM"];
	DEFAULT_CHAT_FRAME:AddMessage(messageTag, info.r, info.g, info.b, info.id);
end

function ChatFrame_DisplaySystemMessageInCurrent(messageTag)
	local info = ChatTypeInfo["SYSTEM"];
	SELECTED_CHAT_FRAME:AddMessage(messageTag, info.r, info.g, info.b, info.id);
end

function ChatFrame_DisplaySystemMessage(frame, messageTag)
	local info = ChatTypeInfo["SYSTEM"];
	frame:AddMessage(messageTag, info.r, info.g, info.b, info.id);
end

-- ChatEdit functions

local ChatEdit_LastTell = {};
local ChatEdit_LastTellType = {};
for i = 1, NUM_REMEMBERED_TELLS, 1 do
	ChatEdit_LastTell[i] = "";
	ChatEdit_LastTellType[i] = "";
end
local ChatEdit_LastTold;
local ChatEdit_LastToldType;

function ChatEdit_OnLoad(self)
	self:SetFrameLevel(self.chatFrame:GetFrameLevel()+1);
	self:SetAttribute("chatType", "SAY");
	self:SetAttribute("stickyType", "SAY");
	self.chatLanguage = GetDefaultLanguage();
	self:RegisterEvent("UPDATE_CHAT_COLOR");

	self.addSpaceToAutoComplete = true;
	self.addHighlightedText = true;

	if ( CHAT_OPTIONS.ONE_EDIT_AT_A_TIME == "many" ) then
		self:Show();
	end

	local function ChatEditAutoComplete(editBox, fullText, nameInfo, ambiguatedName)
		if hash_ChatTypeInfoList[string.upper(editBox.command)] == "SMART_WHISPER" then
			if nameInfo.bnetID ~= nil and nameInfo.bnetID ~= 0 then
				editBox:SetAttribute("tellTarget", nameInfo.name);
				editBox:SetAttribute("chatType", "BN_WHISPER");
			else
				editBox:SetAttribute("tellTarget", ambiguatedName);
				editBox:SetAttribute("chatType", "WHISPER");
			end
			editBox:SetText("");
			ChatEdit_UpdateHeader(editBox);
			return true;
		end

		return false;
	end

	AutoCompleteEditBox_SetCustomAutoCompleteFunction(self, ChatEditAutoComplete);

	self:SetParent(UIParent);

	self.HasStickyFocus = ChatEdit_HasStickyFocus;
end

function ChatEdit_OnEvent(self, event, ...)
	if ( event == "UPDATE_CHAT_COLOR" ) then
		local chatType = ...;
		if ( self:IsShown() ) then
			ChatEdit_UpdateHeader(self);
		end
	end
end

function ChatEdit_OnUpdate(self, elapsedSec)
	if ( self.setText == 1) then
		self:SetText(self.text);
		self.setText = 0;
		ChatEdit_ParseText(self, 0, true);

		if self.desiredCursorPosition then
			self:SetCursorPosition(self.desiredCursorPosition);
			self.desiredCursorPosition = nil;
		end
	end
end

function ChatEdit_OnShow(self)
	ChatEdit_ResetChatType(self);
end

function ChatEdit_ResetChatType(self)
	if ( self:GetAttribute("chatType") == "PARTY" and (not IsInGroup(LE_PARTY_CATEGORY_HOME)) ) then
		self:SetAttribute("chatType", "SAY");
	end
	if ( self:GetAttribute("chatType") == "RAID" and (not IsInRaid(LE_PARTY_CATEGORY_HOME)) ) then
		self:SetAttribute("chatType", "SAY");
	end
	if ( (self:GetAttribute("chatType") == "GUILD" or self:GetAttribute("chatType") == "OFFICER") and not IsInGuild() ) then
		self:SetAttribute("chatType", "SAY");
	end
	if ( self:GetAttribute("chatType") == "INSTANCE_CHAT" and (not IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) ) then
		self:SetAttribute("chatType", "SAY");
	end

	-- GAME RULES TODO:: The game modes portion here should be an explicit game rule.
	if ( C_Glue.IsOnGlueScreen() and (C_GameRules.GetActiveGameMode() == Enum.GameMode.Plunderstorm) and IsInGroup(LE_PARTY_CATEGORY_HOME) ) then
		self:SetAttribute("chatType", "PARTY");
	end

	self.lastTabComplete = nil;
	self.tabCompleteText = nil;
	self.tabCompleteTableIndex = 1;
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

	if ( LAST_ACTIVE_CHAT_EDIT_BOX == self and ( self.disableActivate or self:IsShown() ) ) then	--Our parent was hidden. Let's find a new default frame.
		--We'll go with the active dock frame since people think of that as the primary chat.
		ChatEdit_SetLastActiveWindow(FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK).editBox);
	end
end

function ChatEdit_OnEditFocusGained(self)
	ChatEdit_ActivateChat(self);
end

function ChatEdit_OnEditFocusLost(self)
	AutoCompleteEditBox_OnEditFocusLost(self);

	if self:GetText() == "" then
		ChatEdit_DeactivateChat(self);
	end
end

function ChatEdit_ActivateChat(editBox)
	if ( editBox.disableActivate ) then
		return;
	end

	ChatFrame_ClearChatFocusOverride();
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
	ChatEdit_UpdateNewcomerEditBoxHint(editBox);
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
	if ( editBox.disableActivate or ( GetCVar("chatStyle") == "classic" and not editBox.isGM ) ) then
		editBox:Hide();
	else
		editBox:SetText("");
		editBox.header:Hide();
		if ( not editBox.isGM ) then
			editBox:SetAlpha(0.35);
		end
		ChatEdit_UpdateNewcomerEditBoxHint(editBox);
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
		_G.ACTIVE_CHAT_EDIT_BOX = nil;
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
	if ( editBox ~= nil and editBox.disableActivate ) then
		return;
	end

	local previousValue = LAST_ACTIVE_CHAT_EDIT_BOX;
	if ( LAST_ACTIVE_CHAT_EDIT_BOX and not LAST_ACTIVE_CHAT_EDIT_BOX.isGM and LAST_ACTIVE_CHAT_EDIT_BOX ~= editBox ) then
		if ( GetCVar("chatStyle") == "im" ) then
			LAST_ACTIVE_CHAT_EDIT_BOX:Hide();
		end
	end

	LAST_ACTIVE_CHAT_EDIT_BOX = editBox;
	if ( editBox and GetCVar("chatStyle") == "im" and ACTIVE_CHAT_EDIT_BOX ~= editBox ) then
		editBox:Show();
		ChatEdit_SetDeactivated(editBox);
	end

	if ( previousValue ) then
		FCFClickAnywhereButton_UpdateState(previousValue.chatFrame.clickAnywhereButton);
	end

	if ( editBox ) then
		FCFClickAnywhereButton_UpdateState(editBox.chatFrame.clickAnywhereButton);
	end
end

function ChatEdit_GetActiveWindow()
	return ACTIVE_CHAT_EDIT_BOX;
end

function ChatEdit_GetLastActiveWindow()
	return LAST_ACTIVE_CHAT_EDIT_BOX;
end

function ChatEdit_GetActiveChatType()
	local editBox = ChatEdit_GetActiveWindow();
	return editBox and editBox:GetAttribute("chatType") or nil;
end

function ChatEdit_FocusActiveWindow()
	local active = ChatEdit_GetActiveWindow()
	if ( active ) then
		ChatEdit_ActivateChat(active);
	end
end

function ChatEdit_LinkItem(itemID, itemLink)
	if ( not itemLink ) then
		itemLink = select(2, C_Item.GetItemInfo(itemID));
	end
	if ( itemLink ) then
		if ( ChatEdit_GetActiveWindow() ) then
			ChatEdit_InsertLink(itemLink);
		else
			ChatFrame_OpenChat(itemLink);
		end
	end
end

function ChatEdit_InsertLink(text)
	if ( not text ) then
		return false;
	end

	if ( MacroFrameText and MacroFrameText:HasFocus() ) then
		local item;
		if ( strfind(text, "item:", 1, true) ) then
			item = C_Item.GetItemInfo(text);
		end
		local cursorPosition = MacroFrameText:GetCursorPosition();
		if (cursorPosition == 0 or strsub(MacroFrameText:GetText(), cursorPosition, cursorPosition) == "\n" ) then
			if ( item ) then
				if ( C_Item.GetItemSpell(text) ) then
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

	if ( ProfessionsFrame and ProfessionsFrame.CraftingPage.RecipeList.SearchBox:HasFocus() )  then
		local item;
		if ( strfind(text, "item:", 1, true) ) then
			item = C_Item.GetItemInfo(text);
		end
		if ( item ) then
			ProfessionsFrame.CraftingPage.RecipeList.SearchBox:SetText(item);
			return true;
		end
	end
	if ( CommunitiesFrame and CommunitiesFrame.ChatEditBox:HasFocus() ) then
		CommunitiesFrame.ChatEditBox:Insert(text);
		return true;
	end

	local activeWindow = ChatEdit_GetActiveWindow();
	if ( activeWindow ) then
		activeWindow:Insert(text);
		activeWindow:SetFocus();
		return true;
	end
	if ( AuctionHouseFrame and AuctionHouseFrame:IsVisible() ) then
		local item;
		if ( strfind(text, "battlepet:") ) then
			local petName = strmatch(text, "%[(.+)%]");
			item = petName;
		elseif ( strfind(text, "item:", 1, true) ) then
			item = C_Item.GetItemInfo(text);
		end
		if ( item ) then
			if ( AuctionHouseFrame:SetSearchText(item) ) then
				return true;
			end
		end
	end

	return false;
end

function ChatEdit_TryInsertChatLink(link)
	if ( IsModifiedClick("CHATLINK") and link ) then
		return ChatEdit_InsertLink(link);
	end
end

function ChatEdit_TryInsertQuestLinkForQuestID(questID)
	return ChatEdit_TryInsertChatLink(GetQuestLink(questID));
end

function ChatEdit_GetChannelTarget(editBox)
	local channelTarget = editBox:GetAttribute("channelTarget"); -- may be a name or an index
	if channelTarget == nil then
		return 0;
	end

	local localID = GetChannelName(channelTarget);
	return localID;
end

function ChatEdit_GetLastTellTarget()
	for i=1, #ChatEdit_LastTell do
		local value = ChatEdit_LastTell[i];
		if ( value ~= "" ) then
			return value, ChatEdit_LastTellType[i];
		end
	end
	return nil;
end

function ChatEdit_SetLastTellTarget(target, chatType)
	local found = #ChatEdit_LastTell;
	for i=1, #ChatEdit_LastTell do
		local tellTarget, tellChatType = ChatEdit_LastTell[i], ChatEdit_LastTellType[i];
		if ( strupper(target) == strupper(tellTarget) and strupper(chatType) == strupper(tellChatType) ) then
			found = i;
			break;
		end
	end

	for i = found, 2, -1 do
		ChatEdit_LastTell[i] = ChatEdit_LastTell[i-1];
		ChatEdit_LastTellType[i] = ChatEdit_LastTellType[i-1];
	end
	ChatEdit_LastTell[1] = target;
	ChatEdit_LastTellType[1] = chatType;
end

function ChatEdit_GetNextTellTarget(target, chatType)
	if ( not target or target == "" ) then
		return ChatEdit_LastTell[1], ChatEdit_LastTellType[1];
	end

	for i = 1, #ChatEdit_LastTell - 1, 1 do
		if ( ChatEdit_LastTell[i] == "" ) then
			break;
		elseif ( strupper(target) == strupper(ChatEdit_LastTell[i]) and
			strupper(chatType) == strupper(ChatEdit_LastTellType[i]) ) then
			if ( ChatEdit_LastTell[i+1] ~= "" ) then
				return ChatEdit_LastTell[i+1], ChatEdit_LastTellType[i+1];
			else
				break;
			end
		end
	end

	return ChatEdit_LastTell[1], ChatEdit_LastTellType[1];
end

function ChatEdit_GetLastToldTarget()
	return ChatEdit_LastTold, ChatEdit_LastToldType;
end

function ChatEdit_SetLastToldTarget(name, chatType)
	ChatEdit_LastTold = name;
	ChatEdit_LastToldType = chatType;
end

local chatTypesThatRequireTellTarget = 
{
	BN_WHISPER = true,
	WHISPER = true,
	SMART_WHISPER = true,
};

function ChatEdit_UpdateHeader(editBox)
	if IsMacroEditBox(editBox) then
		return;
	end

	local type = editBox:GetAttribute("chatType");
	if ( not type ) then
		return;
	end

	local tellTarget  = editBox:GetAttribute("tellTarget");
	if not tellTarget and chatTypesThatRequireTellTarget[type] then
		return;
	end

	local info;
	if ( type == "VOICE_TEXT" and VoiceTranscription_GetChatTypeAndInfo ) then
		-- This can occur after loading ChatFrame.lua and before loading VoiceChatTranscriptionFrame.lua due to loading screen event signals, so nil check is required before calling the function.
		type, info = VoiceTranscription_GetChatTypeAndInfo();
	else
		info = ChatTypeInfo[type];
	end

	local header = _G[editBox:GetName().."Header"];
	local headerSuffix = _G[editBox:GetName().."HeaderSuffix"];
	if ( not header ) then
		return;
	end

	header:SetWidth(0);
	--BN_WHISPER FIXME
	if ( type == "SMART_WHISPER" ) then
		--If we have a bnetIDAccount or this name, it's a BN whisper.
		if ( BNet_GetBNetIDAccount(tellTarget) ) then
			editBox:SetAttribute("chatType", "BN_WHISPER");
		else
			editBox:SetAttribute("chatType", "WHISPER");
		end
		ChatEdit_UpdateHeader(editBox);
		return;
	elseif ( type == "WHISPER" ) then
		header:SetFormattedText(CHAT_WHISPER_SEND, tellTarget);
	elseif ( type == "BN_WHISPER" ) then
		header:SetFormattedText(CHAT_BN_WHISPER_SEND, tellTarget);
	elseif ( type == "EMOTE" ) then
		header:SetFormattedText(CHAT_EMOTE_SEND, UnitName("player"));
	elseif ( type == "CHANNEL" ) then
		local localID, channelName, instanceID, isCommunitiesChannel = GetChannelName(ChatEdit_GetChannelTarget(editBox));
		if ( channelName ) then
			if ( isCommunitiesChannel ) then
				channelName = ChatFrame_ResolveChannelName(channelName);
			elseif ( instanceID > 0 ) then
				channelName = channelName.." "..instanceID;
			end
			info = ChatTypeInfo["CHANNEL"..localID];
			editBox:SetAttribute("channelTarget", localID);
			header:SetFormattedText(CHAT_CHANNEL_SEND, localID, channelName);
		end
	elseif ( (type == "PARTY") and
		 (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) ) then
		 --Smartly switch to instance chat
		editBox:SetAttribute("chatType", "INSTANCE_CHAT");
		ChatEdit_UpdateHeader(editBox);
		return;
	elseif ( (type == "RAID") and
		 (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) ) then
		 --Smartly switch to instance chat
		editBox:SetAttribute("chatType", "INSTANCE_CHAT");
		ChatEdit_UpdateHeader(editBox);
		return;
	elseif ( (type == "INSTANCE_CHAT") and
		(IsInGroup(LE_PARTY_CATEGORY_HOME) and not IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) )then
		if ( IsInRaid(LE_PARTY_CATEGORY_HOME) ) then
			editBox:SetAttribute("chatType", "RAID");
		else
			editBox:SetAttribute("chatType", "PARTY");
		end
		ChatEdit_UpdateHeader(editBox);
		return;
	elseif ( type == "COMMUNITIES_CHANNEL" and info.channelName ) then
		header:SetFormattedText(CHAT_CHANNEL_SEND_NO_ID, info.channelName);
	else
		header:SetText(_G["CHAT_"..type.."_SEND"]);
	end

	local headerWidth = (header:GetRight() or 0) - (header:GetLeft() or 0);
	local editBoxWidth = (editBox:GetRight() or 0) - (editBox:GetLeft() or 0);

	if ( headerWidth > editBoxWidth / 2 ) then
		header:SetWidth(editBoxWidth / 2);
		headerSuffix:Show();
	else
		headerSuffix:Hide();
	end

	header:SetTextColor(info.r, info.g, info.b);
	headerSuffix:SetTextColor(info.r, info.g, info.b);

	local languageHeaderWidth = 0;
	if (type == "SAY" or type == "YELL") and header:IsShown() and editBox.language and editBox.language ~= GetDefaultLanguage() then
		editBox.languageHeader:Show();
		editBox.languageHeader:SetWidth(0);
		editBox.languageHeader:SetText(string.format(CHAT_LANGUAGE_NAME_TAG, editBox.language));
		languageHeaderWidth = editBox.languageHeader:GetWidth();
	else
		editBox.languageHeader:Hide();
	end

	editBox:SetTextInsets(15 + header:GetWidth() + (headerSuffix:IsShown() and headerSuffix:GetWidth() or 0) + languageHeaderWidth, 13, 0, 0);
	editBox:SetTextColor(info.r, info.g, info.b);

	editBox.focusLeft:SetVertexColor(info.r, info.g, info.b);
	editBox.focusRight:SetVertexColor(info.r, info.g, info.b);
	editBox.focusMid:SetVertexColor(info.r, info.g, info.b);
end

function ChatEdit_DoesCurrentChannelTargetMatch(editBox, localID)
	local type = editBox:GetAttribute("chatType");
	if type == "CHANNEL" then
		return ChatEdit_GetChannelTarget(editBox) == localID;
	end

	return false;
end

function ChatEdit_UpdateNewcomerEditBoxHint(editBox, excludeChannel)
	local shouldBeShown = not editBox.isGM and not editBox.header:IsShown() and IsActivePlayerNewcomer();
	if shouldBeShown then
		local localID = GetFirstChannelIDOfChannelMatchingRuleset(Enum.ChatChannelRuleset.Mentor, excludeChannel);
		editBox.NewcomerHint:SetShown(localID);

		if localID then
			editBox:SetAlpha(1.0);
			if ChatEdit_DoesCurrentChannelTargetMatch(editBox, localID) then
				editBox.NewcomerHint:SetText(NPEV2_CHAT_HELP_HINT_HERE);
			else
				editBox.NewcomerHint:SetFormattedText(NPEV2_CHAT_HELP_HINT_DIFFERENT, GetSlashCommandForChannelOpenChat(localID));
			end
		end
	else
		editBox.NewcomerHint:Hide();
	end

	editBox.prompt:SetShown(not editBox.header:IsShown() and not editBox.NewcomerHint:IsShown());
end

function ChatEdit_CheckUpdateNewcomerEditBoxHint()
	local editBox = ChatEdit_GetActiveWindow() or ChatEdit_GetLastActiveWindow();
	if editBox then
		-- No need for an exlcude channel, this should not be called when leaving a channel.
		ChatEdit_UpdateNewcomerEditBoxHint(editBox);
	end
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
		text = "/"..ChatEdit_GetChannelTarget(editBox);
	end

	local editBoxText = editBox:GetText();
	if ( editBoxText ~= "" ) then
		text = text.." "..editBox:GetText();
	end

	if ( text ~= "" ) then
		editBox:AddHistoryLine(text);
	end
end

function ChatEdit_SendText(editBox, addHistory)
	ChatEdit_ParseText(editBox, 1);

	local type = editBox:GetAttribute("chatType");
	local text = editBox:GetText();
	if ( strfind(text, "%s*[^%s]+") ) then
		text = SubstituteChatMessageBeforeSend(text);
		--BN_WHISPER FIXME
		if ( type == "WHISPER") then
			local target = editBox:GetAttribute("tellTarget");
			ChatEdit_SetLastToldTarget(target, type);
			C_ChatInfo.SendChatMessage(text, type, editBox.languageID, target);
		elseif ( type == "BN_WHISPER" ) then
			local target = editBox:GetAttribute("tellTarget");
			local bnetIDAccount = BNet_GetBNetIDAccount(target);
			if ( bnetIDAccount ) then
				ChatEdit_SetLastToldTarget(target, type);
				BNSendWhisper(bnetIDAccount, text);
			else
				local info = ChatTypeInfo["SYSTEM"]
				editBox.chatFrame:AddMessage(format(BN_UNABLE_TO_RESOLVE_NAME, target), info.r, info.g, info.b);
			end
		elseif ( type == "CHANNEL") then
			C_ChatInfo.SendChatMessage(text, type, editBox.languageID, ChatEdit_GetChannelTarget(editBox));
		else
			C_ChatInfo.SendChatMessage(text, type, editBox.languageID);
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
	if ( chatFrame.isTemporary and chatFrame.chatType ~= "PET_BATTLE_COMBAT_LOG" ) then --Temporary window sticky types never change.
		self:SetAttribute("stickyType", chatFrame.chatType);
		--BN_WHISPER FIXME
		if ( chatFrame.chatType == "WHISPER" or chatFrame.chatType == "BN_WHISPER" ) then
			self:SetAttribute("tellTarget", chatFrame.chatTarget);
		end
	elseif ( ChatTypeInfo[type].sticky == 1 ) then
		self:SetAttribute("stickyType", type);
	end

	ChatEdit_ClearChat(self);
end

function ChatEdit_ClearChat(editBox)
	ChatEdit_ResetChatTypeToSticky(editBox);
	if ( not editBox.isGM and (GetCVar("chatStyle") ~= "im" or IsMacroEditBox(editBox)) ) then
		editBox:SetText("");
		editBox:Hide();
	else
		ChatEdit_DeactivateChat(editBox);
	end
end

function ChatEdit_OnEscapePressed(editBox)
	if ( not AutoCompleteEditBox_OnEscapePressed(editBox) ) then
		ChatEdit_ClearChat(editBox);
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

local tabCompleteTables = { hash_ChatTypeInfoList, hash_EmoteTokenList };
local function ChatEdit_SearchTabCompleteTable(tableCompleteTable, command, cmdString)
	repeat	--Loop through this table to find matching items.
		cmdString = next(tableCompleteTable, cmdString);
	until ( not cmdString or strfind(cmdString, strupper(command), 1, 1) );	--Either we finished going through this table or we found a match.
	return cmdString;
end

function ChatEdit_SecureTabPressed(self)
	local chatType = self:GetAttribute("chatType");
	if ( chatType == "WHISPER" or chatType == "BN_WHISPER" ) then
		local newTarget, newTargetType = ChatEdit_GetNextTellTarget(self:GetAttribute("tellTarget"), chatType);
		if ( newTarget and newTarget ~= "" ) then
			self:SetAttribute("chatType", newTargetType);
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

	ChatFrame_ImportAllListsToHash();

	local lastTabComplete = self.lastTabComplete;

	-- If the string is in the format "/cmd blah", command will be "/cmd"
	local command = strmatch(text, "^(/[^%s]+)") or "";

	local cmdString = lastTabComplete;
	repeat	--The outer loop lets us go through multiple hash tables of commands.
		cmdString = securecallfunction(ChatEdit_SearchTabCompleteTable, tabCompleteTables[self.tabCompleteTableIndex], command, cmdString);
		if ( not cmdString ) then	--Nothing else in the current table, move to the next one.
			self.tabCompleteTableIndex = self.tabCompleteTableIndex + 1;
		end
	until ( cmdString or self.tabCompleteTableIndex > #tabCompleteTables );

	self.lastTabComplete = cmdString;
	if ( cmdString ) then
		self.ignoreTextChange = 1;
		self:SetText(strlower(cmdString));
	else
		self.tabCompleteTableIndex = 1;
		self:SetText(self.tabCompleteText);
	end
end

function ChatEdit_OnTabPressed(self)
	if ( not AutoCompleteEditBox_OnTabPressed(self) ) then
		if ( securecall("ChatEdit_CustomTabPressed", self) ) then
			return;
		end
		ChatEdit_SecureTabPressed(self);
	end
end

function ChatEdit_OnTextChanged(self, userInput)
	ChatEdit_ParseText(self, 0);
	if ( not self.ignoreTextChange ) then
		self.lastTabComplete = nil;
		self.tabCompleteText = nil;
		self.tabCompleteTableIndex = 1;
	end
	self.ignoreTextChange = nil;
	local regex = "^((/[^%s]+)%s+(.+))"
	local full, command, target = strmatch(self:GetText(), regex);
	if ( not target or (strsub(target, 1, 1) == "|") or self.disallowAutoComplete) then
		AutoComplete_HideIfAttachedTo(self);
		return;
	end

	if ( userInput ) then
		self.autoCompleteXOffset = 35;
		AutoComplete_Update(self, target, self:GetUTF8CursorPosition() - strlenutf8(command) - 1);
	end
end

local symbols = {"%%", "%*", "%+", "%-", "%?", "%(", "%)", "%[", "%]", "%$", "%^"} --% has to be escaped first or everything is ruined
local replacements = {"%%%%", "%%%*", "%%%+", "%%%-", "%%%?", "%%%(", "%%%)", "%%%[", "%%%]", "%%%$", "%%%^"}
function escapePatternSymbols(text)
	for i=1, #symbols do
		text = text:gsub(symbols[i], replacements[i])
	end
	return text
end

function ChatEdit_OnChar(self)
	local regex = "^((/[^%s]+)(%s+)(.+))$"
	local text, command, whitespace, target = strmatch(self:GetText(), regex);
	if (command) then
		self.command = command
	else
		self.command = nil;
	end
	if (command and target and self.autoCompleteSource and self.autoCompleteParams) then --if they typed a command with a autocompletable target
		local utf8Position = self:GetUTF8CursorPosition();
		local allowFullMatch = false;
		local nameToShow = self.autoCompleteSource(target, 1, utf8Position, allowFullMatch, unpack(self.autoCompleteParams))[1];
		if (nameToShow and nameToShow.name) then
			local name = Ambiguate and Ambiguate(nameToShow.name, "all") or nameToShow.name;
			--We're going to be setting the text programatically which will clear the userInput flag on the editBox.
			--So we want to manually update the dropdown before we change the text.
			AutoComplete_Update(self, target, utf8Position - strlenutf8(command) - strlen(whitespace));
			if strsub(name, 1, 1) ~= "|" then
				target = escapePatternSymbols(target);

				local newTarget = name;
				self:SetText(string.format("%s%s%s", command, whitespace, newTarget));
				self:HighlightText(strlen(text), strlen(command) + strlen(whitespace) + strlen(newTarget));
			end
		end
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

function ChatEdit_SetGameLanguage(self, language, languageId)
	self.language = language;
	self.languageID = languageId;
	ChatEdit_UpdateHeader(self);
end

-- This is a special function for "ChatEdit_HandleChatType"
local function processChatType(editBox, msg, index, send)
	local autoCompleteInfo = AUTOCOMPLETE_LIST[index];
	if ( autoCompleteInfo ) then
		AutoCompleteEditBox_SetAutoCompleteSource(editBox, GetAutoCompleteResults, autoCompleteInfo.include, autoCompleteInfo.exclude);
	else
		AutoCompleteEditBox_SetAutoCompleteSource(editBox, nil);
	end

	local info = ChatTypeInfo[index];
	if ( info and not info.ignoreChatTypeProcessing ) then
		if ( index == "WHISPER" or index == "SMART_WHISPER" ) then
			local targetFound, target, chatType, parsedMsg = ChatEdit_ExtractTellTarget(editBox, msg, index);
			if ( targetFound ) then
				editBox:SetAttribute("tellTarget", target);
				editBox:SetAttribute("chatType", chatType);
				editBox:SetText(parsedMsg);
				ChatEdit_UpdateHeader(editBox);
			elseif ( send == 1 ) then
				ChatEdit_ClearChat(editBox);
			end
		elseif ( index == "REPLY" ) then
			local lastTell, lastTellType = ChatEdit_GetLastTellTarget();
			if ( lastTell ) then
				--BN_WHISPER FIXME
				editBox:SetAttribute("chatType", lastTellType);
				editBox:SetAttribute("tellTarget", lastTell);
				editBox:SetText(msg);
				ChatEdit_UpdateHeader(editBox);
			else
				if ( send == 1 ) then
					ChatEdit_ClearChat(editBox);
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
	return false;
end

function ChatEdit_HandleChatType(editBox, msg, command, send)
	local channel = strmatch(command, "/([0-9]+)$");
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
		end
	else
		-- first check the hash table
		ChatFrame_ImportAllListsToHash();
		if ( hash_ChatTypeInfoList[command] ) then
			return processChatType(editBox, msg, hash_ChatTypeInfoList[command], send);
		end
	end
	--This isn't one we found in our list, so we're not going to autocomplete.
	AutoCompleteEditBox_SetAutoCompleteSource(editBox, nil);
	return false;
end

function ChatEdit_ParseText(editBox, send, parseIfNoSpaces)

	local text = editBox:GetText();
	if ( text == "" ) then
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
		msg = strmatch(msg, "^%s*(.*)$") or msg;
	end

	command = strupper(command);

	-- Check and see if we've got secure commands to run before we look for chat types or slash commands.
	-- This hash table is prepopulated, unlike the other ones, since nobody can add secure commands. (See line 1205 or thereabouts)
	-- We don't want this code to run unless send is 1, but we need ChatEdit_HandleChatType to run when send is 1 as well, which is why we
	-- didn't just move ChatEdit_HandleChatType inside the send == 0 conditional, which could have also solved the problem with insecure
	-- code having the ability to affect secure commands.

	if ( send == 1 and addonTbl.hash_SecureCmdList[command] ) then
		addonTbl.hash_SecureCmdList[command](strtrim(msg));
		editBox:AddHistoryLine(text);
		ChatEdit_ClearChat(editBox);
		return;
	end

	ChatFrame_ImportAllListsToHash();

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
		ChatEdit_ClearChat(editBox);
		return;
	elseif ( hash_EmoteTokenList[command] ) then
		-- if the code in here changes - change the corresponding code below
		local restricted = DoEmote(hash_EmoteTokenList[command], msg);
		-- If the emote is restricted, we want to treat it as if the player entered an unrecognized chat command.
		if ( not restricted ) then
			editBox:AddHistoryLine(text);
			ChatEdit_ClearChat(editBox);
			return;
		end
	end

	-- Unrecognized chat command, show simple help text
	if ( editBox.chatFrame ) then
		ChatFrame_DisplayHelpTextSimple(editBox.chatFrame);
	end

	-- Reset the chat type and clear the edit box's contents
	ChatEdit_ClearChat(editBox);
	return;
end

function SubstituteChatMessageBeforeSend(msg)
	for tag in string.gmatch(msg, "%b{}") do
		local term = strlower(string.gsub(tag, "[{}]", ""));
		if ( GROUP_TAG_LIST[term] ) then
			local groupIndex = GROUP_TAG_LIST[term];
			msg = string.gsub(msg, tag, "{"..GROUP_LANGUAGE_INDEPENDENT_STRINGS[groupIndex].."}");
		end
	end
	return msg;
end

function ChatEdit_ExtractTellTarget(editBox, msg, chatType)
	local tellTargetExtractionAutoComplete;
	if ( chatType == "WHISPER" ) then
		tellTargetExtractionAutoComplete = AUTOCOMPLETE_LIST.WHISPER_EXTRACT;
	else
		tellTargetExtractionAutoComplete = AUTOCOMPLETE_LIST.SMART_WHISPER_EXTRACT;
	end

	-- Grab the string after the slash command
	local target = strmatch(msg, "%s*(.*)");

	--If we haven't even finished one word, we aren't done.
	if ( not target or not strfind(target, "%s") ) then
		return false;
	end

	if ( strsub(target, 1, 1) == "|" ) then
		return false;
	end

	if ( #GetAutoCompleteResults(target, 1, 0, true, tellTargetExtractionAutoComplete.include, tellTargetExtractionAutoComplete.exclude) > 0 ) then
		--Even if there's a space, we still want to let the person keep typing -- they may be trying to type whatever is in AutoComplete.
		return false;
	end

	--Keep pulling off everything after the last space until we either have something on the AutoComplete list or only a single word is left.
	while ( strfind(target, "%s") ) do
		--Pull off everything after the last space.
		target = strmatch(target, "(.+)%s+[^%s]*");
		if ( #GetAutoCompleteResults(target, 1, 0, true, tellTargetExtractionAutoComplete.include, tellTargetExtractionAutoComplete.exclude) > 0 ) then
			break;
		end
	end
	msg = strsub(msg, strlen(target) + 2);

	if ( chatType ~= "WHISPER" and BNet_GetBNetIDAccount(target) ) then --"WHISPER" forces character whisper
		chatType = "BN_WHISPER";
	else
		chatType = "WHISPER";
	end
	return true, target, chatType, msg;
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

local stickyFocusFrames = { };

function ChatEdit_RegisterForStickyFocus(frame)
	stickyFocusFrames[frame] = 1;
end

function ChatEdit_UnregisterForStickyFocus(frame)
	stickyFocusFrames[frame] = nil;
end

function ChatEdit_HasStickyFocus()
	for frame in pairs(stickyFocusFrames) do
		if frame:HasStickyFocus() then
			return true;
		end
	end
	return false;
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

function ChatChannelDropdown_Show(chatFrame, chatType, chatTarget, chatName)
	MenuUtil.CreateContextMenu(chatFrame, function(owner, rootDescription)
		rootDescription:SetTag("MENU_CHAT_FRAME_CHANNEL");

		rootDescription:CreateTitle(ChatFrame_ResolveChannelName(chatName));

		local clubId, streamId = ChatFrame_GetCommunityAndStreamFromChannel(chatName);
		if clubId and streamId and C_Club.IsEnabled() then
			rootDescription:CreateButton(CHAT_CHANNEL_DROP_DOWN_OPEN_COMMUNITIES_FRAME, function()
				if not CommunitiesFrame or not CommunitiesFrame:IsShown() then
					ToggleCommunitiesFrame();
				end

				CommunitiesFrame:SelectStream(clubId, streamId);
				CommunitiesFrame:SelectClub(clubId);
			end);
		end

		local button = rootDescription:CreateButton(MOVE_TO_NEW_WINDOW, function()
			ChatChannelDropdown_PopOutChat(chatFrame, chatType, chatTarget);
		end);

		if not FCF_CanOpenNewWindow() then
			button:SetEnabled(false);
		end
	end);
end

function ChatChannelDropdown_PopOutChat(sourceChatFrame, chatType, chatTarget)
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

	if ( chatType == "PET_BATTLE_COMBAT_LOG" or chatType == "PET_BATTLE_INFO" ) then
		frame.editBox:SetAttribute("chatType", "SAY");
		frame.editBox:SetAttribute("stickyType", "SAY");
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
	for i = 1, sourceChatFrame:GetNumMessages() do
		local text, r, g, b, chatTypeID, messageAccessID, lineID = sourceChatFrame:GetMessageInfo(i);
		if messageAccessID == accessID then
			frame:AddMessage(text, r, g, b, chatTypeID, messageAccessID, lineID);
		end
	end
	--Remove the messages from the old frame.
	sourceChatFrame:RemoveMessagesByPredicate(function(text, r, g, b, chatTypeID, messageAccessID, lineID) return messageAccessID == accessID; end);
end

function Chat_GetChannelShortcutName(index)
	if not tonumber(index) and type(index) == "string" then
		index = GetChannelName(index);
	end

	return C_ChatInfo.GetChannelShortcut(index);
end

function ChatClassColorOverrideShown()
	local value = GetCVar("chatClassColorOverride");
	if value == "0" then
		return true;
	elseif value == "1" then
		return false;
	else
		return nil;
	end
end

function Chat_ShouldColorChatByClass(chatTypeInfo)
	local override = ChatClassColorOverrideShown();
	local colorByClass = chatTypeInfo and chatTypeInfo.colorNameByClass;
	return override or (override == nil and colorByClass);
end

function Chat_GetColoredChatName(chatType, chatTarget)
	if ( chatType == "CHANNEL" ) then
		local info = ChatTypeInfo["CHANNEL"..chatTarget];
		local colorString = format("|cff%02x%02x%02x", info.r * 255, info.g * 255, info.b * 255);
		local chanNum, channelName = GetChannelName(chatTarget);
		return format("%s|Hchannel:channel:%d|h[%d. %s]|h|r", colorString, chanNum, chanNum, gsub(channelName, "%s%-%s.*", ""));	--The gsub removes zone-specific markings (e.g. "General - Ironforge" to "General")
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

function Chat_AddSystemMessage(messageText)
	local info = ChatTypeInfo["SYSTEM"];
	DEFAULT_CHAT_FRAME:AddMessage(messageText, info.r, info.g, info.b, info.id);
end

local NewLanguageHelpTipInfo = {
	text = NEW_SPOKEN_LANGUAGE_HELPTIP,
	buttonStyle = HelpTip.ButtonStyle.Close,
	offsetX = 0, offsetY = 0,
	targetPoint = HelpTip.Point.RightEdgeCenter,
};

local function GetSelectedLanguageID()
	return DEFAULT_CHAT_FRAME.editBox.languageID;
end

ChatFrameMenuButtonMixin = {};

function ChatFrameMenuButtonMixin:OnLoad()
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("LANGUAGE_LIST_CHANGED");
	self:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT");
	self:RegisterEvent("CAN_PLAYER_SPEAK_LANGUAGE_CHANGED");

	local function SetChatTypeAttribute(chatType)
		local editBox = ChatFrame_OpenChat("");
		editBox:SetAttribute("chatType", chatType);
		ChatEdit_UpdateHeader(editBox);
	end
	
	local function AddEmotes(description, list, func)
		for index, value in ipairs(list) do
			local i = 1;
			local token = _G["EMOTE"..i.."_TOKEN"];
			while ( i < MAXEMOTEINDEX ) do
				if ( token == value ) then
					break;
				end
				i = i + 1;
				token = _G["EMOTE"..i.."_TOKEN"];
			end
	
			local label = _G["EMOTE"..i.."_CMD1"] or value;
			description:CreateButton(label, function(...)
				func(index);
			end);
		end
	end
	
	local function IsLanguageSelected(language)
		return GetSelectedLanguageID() == language[2];
	end
	
	local function SetLanguageSelected(languageData)
		ChatEdit_SetGameLanguage(DEFAULT_CHAT_FRAME.editBox, languageData[1], languageData[2]);
	end

	local function AddSlashInitializer(button, chatShortcut)
		button:AddInitializer(function(button, description, menu)
			local fontString2 = button:AttachFontString();
			local offset = description:HasElements() and -20 or 0;
			fontString2:SetPoint("RIGHT", offset, 0);
			fontString2:SetJustifyH("RIGHT");
			fontString2:SetTextToFit(chatShortcut);

			button.fontString:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		end);
	end
	
	local function ColorInitializer(button, description, menu)
		button.fontString:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	end

	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_CHAT_SHORTCUTS", block);
		rootDescription:SetMinimumWidth(180);

		local function CreateButtonWithShortcut(chatName, chatShortcut, chatType)
			local button = rootDescription:CreateButton(chatName, function()
				SetChatTypeAttribute(chatType);
			end);

			AddSlashInitializer(button, chatShortcut);
			return button;
		end

		local isOnGlueScreen = C_Glue.IsOnGlueScreen();
		if not isOnGlueScreen then
			CreateButtonWithShortcut(SAY_MESSAGE, SLASH_SAY1, "SAY");
		end

		CreateButtonWithShortcut(PARTY_MESSAGE, SLASH_PARTY1, "PARTY");

		if not isOnGlueScreen then
			CreateButtonWithShortcut(RAID_MESSAGE, SLASH_RAID1, "RAID");
			CreateButtonWithShortcut(INSTANCE_CHAT_MESSAGE, SLASH_INSTANCE_CHAT1, "INSTANCE_CHAT");
			CreateButtonWithShortcut(GUILD_MESSAGE, SLASH_GUILD1, "GUILD");
			CreateButtonWithShortcut(YELL_MESSAGE, SLASH_YELL1, "YELL");
		end

		local whisperButton = rootDescription:CreateButton(WHISPER_MESSAGE, function()
			local editBox = ChatFrame_OpenChat(SLASH_SMART_WHISPER1.." ");
			editBox:SetText(SLASH_SMART_WHISPER1.." "..editBox:GetText());
		end);
		AddSlashInitializer(whisperButton, SLASH_SMART_WHISPER1);

		local replyButton = rootDescription:CreateButton(REPLY_MESSAGE, function()
			ChatFrame_ReplyTell();
		end);
		AddSlashInitializer(replyButton, SLASH_REPLY1);

		if not isOnGlueScreen then
			if not C_GameRules.IsGameRuleActive(Enum.GameRule.MacrosDisabled) then
				local macroButton = rootDescription:CreateButton(MACRO, function()
					ShowMacroFrame();
				end);
				AddSlashInitializer(macroButton, SLASH_MACRO1);
			end

			local emoteSubmenu = CreateButtonWithShortcut(EMOTE_MESSAGE, SLASH_EMOTE1, "EMOTE");
			AddEmotes(emoteSubmenu, EmoteList, function(index)
				DoEmote(EmoteList[index]);
			end);

			local voiceEmoteSubmenu = rootDescription:CreateButton(VOICEMACRO_LABEL);
			voiceEmoteSubmenu:AddInitializer(ColorInitializer);

			AddEmotes(voiceEmoteSubmenu, TextEmoteSpeechList, function(index)
				local emote = TextEmoteSpeechList[index];
				if (emote == EMOTE454_TOKEN) or (emote == EMOTE455_TOKEN) then
					local faction = UnitFactionGroup("player", true);
					if faction == "Alliance" then
						emote = EMOTE454_TOKEN;
					elseif faction == "Horde" then
						emote = EMOTE455_TOKEN;
					end
				end
				DoEmote(emote);
			end);

			local languageSubmenu = rootDescription:CreateButton(LANGUAGE);
			languageSubmenu:AddInitializer(ColorInitializer);

			for i = 1, GetNumLanguages() do
				local language, languageID = GetLanguageByIndex(i);
				local languageData = {language, languageID};
				languageSubmenu:CreateRadio(language, IsLanguageSelected, SetLanguageSelected, languageData);
			end
		end
	end);
end

function ChatFrameMenuButtonMixin:Reinitialize()
	self:ValidateSelectedLanguage();
	self:GenerateMenu();
end

function ChatFrameMenuButtonMixin:OnEvent(event, ...)
	if event == "CAN_PLAYER_SPEAK_LANGUAGE_CHANGED" then
		local languageId, canPlayerSpeakLanguage = ...;
		if canPlayerSpeakLanguage and not self:IsMenuOpen() then
			HelpTip:Show(self, NewLanguageHelpTipInfo, self);
		end
	end

	self:Reinitialize();
end

function ChatFrameMenuButtonMixin:OnShow()
	self:Reinitialize();
end

function ChatFrameMenuButtonMixin:ValidateSelectedLanguage()
	local editBoxLanguageID = GetSelectedLanguageID();
	if not editBoxLanguageID or not C_ChatInfo.CanPlayerSpeakLanguage(editBoxLanguageID) then
		local defaultLanguage, defaultLanguageId = GetDefaultLanguage();
		ChatEdit_SetGameLanguage(DEFAULT_CHAT_FRAME.editBox, defaultLanguage, defaultLanguageId);
	end
end

function ChatFrameMenuButtonMixin:OnClick()
	if self:IsMenuOpen() and HelpTip:IsShowingAny(self) then
		HelpTip:HideAll(self);
	end
end
