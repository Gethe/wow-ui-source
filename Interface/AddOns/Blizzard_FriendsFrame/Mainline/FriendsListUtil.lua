FriendsListUtil = {};

function FriendsListUtil.IsPlayingWoW(gameAccountInfo)
	if not gameAccountInfo then
		return false;
	end

	return gameAccountInfo.clientProgram == BNET_CLIENT_WOW;
end

function FriendsListUtil.IsPlayingDifferentWoWProject(gameAccountInfo)
	if not gameAccountInfo then
		return false;
	end

	return FriendsListUtil.IsPlayingWoW(gameAccountInfo) and gameAccountInfo.wowProjectID ~= WOW_PROJECT_ID;
end

function FriendsListUtil.IsPlayingSameWoWProject(gameAccountInfo)
	if not gameAccountInfo then
		return false;
	end

	return FriendsListUtil.IsPlayingWoW(gameAccountInfo) and gameAccountInfo.wowProjectID == WOW_PROJECT_ID;
end

function FriendsListUtil.GameStateUsesFactions()
	return not C_Glue.IsOnGlueScreen() and not C_GameRules.IsCharacterlessLoginActive();
end

local CLASS_ID_TO_GAME_MODE =
{
	[14] = Enum.GameMode.Plunderstorm,
	[15] = Enum.GameMode.WoWHack,
};

local function CanInviteByGameMode(gameAccountInfo)
	-- This lookup should be replaced with a separate field instead of relying on classID.
	local otherGameMode = CLASS_ID_TO_GAME_MODE[gameAccountInfo.classID];
	local activeGameMode = C_GameRules.GetActiveGameMode();

	if otherGameMode then
		-- If we're both in the same game mode, we can invite them.
		return otherGameMode == activeGameMode;
	else
		-- If we're both in standard we can invite them.
		return activeGameMode == Enum.GameMode.Standard;
	end
end

local function GetHighestPriorityRestriction(restrictionA, restrictionB)
	if not restrictionA then
		return restrictionB;
	end

	local priorityA = BattleNetFriendPartyInviteRestrictionPriority[restrictionA] or 0;
	local priorityB = BattleNetFriendPartyInviteRestrictionPriority[restrictionB] or 0;
	if priorityA > priorityB then
		return restrictionA;
	end

	return restrictionB;
end

function FriendsListUtil.GetGameAccountPartyInviteRestriction(gameAccountInfo)
	if not FriendsListUtil.IsPlayingWoW(gameAccountInfo) then
		return BattleNetFriendPartyInviteRestrictionType.Client;
	end

	local isPlayingSameWoWProject = gameAccountInfo.wowProjectID == WOW_PROJECT_ID;
	if not isPlayingSameWoWProject then
		if gameAccountInfo.wowProjectID == WOW_PROJECT_CLASSIC then
			return BattleNetFriendPartyInviteRestrictionType.WowProjectClassic;
		elseif gameAccountInfo.wowProjectID == WOW_PROJECT_MAINLINE then
			return BattleNetFriendPartyInviteRestrictionType.WowProjectMainline;
		end

		return BattleNetFriendPartyInviteRestrictionType.DifferentWowProject;
	end

	local partyInfoAvailable = not C_Glue.IsOnGlueScreen() and C_PartyInfo ~= nil;
	if partyInfoAvailable then
		local isCrossFactionFriend = gameAccountInfo.factionName and (gameAccountInfo.factionName ~= UnitFactionGroup("player"));
		if isCrossFactionFriend then

			if C_QuestSession.Exists() then
				return BattleNetFriendPartyInviteRestrictionType.QuestSession;
			end

			if not C_PartyInfo.CanFormCrossFactionParties() then
				return BattleNetFriendPartyInviteRestrictionType.Faction;
			end
		end
	end

	local hasValidRealmID = gameAccountInfo.realmID ~= 0;
	if not hasValidRealmID then
		return BattleNetFriendPartyInviteRestrictionType.MissingRealmInfo;
	end

	local realmInfoAvailable = not C_Glue.IsOnGlueScreen();
	if realmInfoAvailable then
		local bothPlayingClassic = (gameAccountInfo.wowProjectID == WOW_PROJECT_CLASSIC) and (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC);
		local bothOnSameRealm = gameAccountInfo.realmID == GetRealmID();
		if bothPlayingClassic and not bothOnSameRealm then
			return BattleNetFriendPartyInviteRestrictionType.Realm;
		end
	end

	if not gameAccountInfo.isInCurrentRegion then
		return BattleNetFriendPartyInviteRestrictionType.DifferentRegion;
	end

	if not CanInviteByGameMode(gameAccountInfo) then
		return BattleNetFriendPartyInviteRestrictionType.IncompatibleGameMode;
	end

	return BattleNetFriendPartyInviteRestrictionType.None;
end

function FriendsListUtil.GetBattleNetFriendPartyInviteRestriction(friendIndex)
	if not friendIndex then
		return BattleNetFriendPartyInviteRestrictionType.NoGameAccounts;
	end

	local numGameAccounts = C_BattleNet.GetFriendNumGameAccounts(friendIndex);
	if numGameAccounts == 0 then
		return BattleNetFriendPartyInviteRestrictionType.NoGameAccounts;
	end

	local highestPriorityRestriction = BattleNetFriendPartyInviteRestrictionType.None;
	for accountIndex = 1, numGameAccounts do
		local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(friendIndex, accountIndex);
		local accountRestriction = FriendsListUtil.GetGameAccountPartyInviteRestriction(gameAccountInfo);

		local hasInvitableAccount = accountRestriction == BattleNetFriendPartyInviteRestrictionType.None;
		if hasInvitableAccount then
			return BattleNetFriendPartyInviteRestrictionType.None;
		end

		highestPriorityRestriction = GetHighestPriorityRestriction(highestPriorityRestriction, accountRestriction);
	end

	return highestPriorityRestriction;
end

local function IsBattleNetFriendGameAccountInfoValidDirectInviteTarget(friendGameAccountInfo, gameStateUsesFactions, playerFaction)
	if not friendGameAccountInfo or not friendGameAccountInfo.playerGuid then
		return false;
	end

	local hasValidRealmID = friendGameAccountInfo.realmID ~= 0;
	if not hasValidRealmID then
		return false;
	end

	if not gameStateUsesFactions then
		return true;
	end

	local hasSameFaction = friendGameAccountInfo.factionName == playerFaction;
	return hasSameFaction;
end

function FriendsListUtil.GetBattleNetFriendGameAccountInfoIfExactlyOneDirectInviteTargetExists(friendIndex)
	if not friendIndex then
		return nil;
	end

	local numGameAccounts = C_BattleNet.GetFriendNumGameAccounts(friendIndex);
	if numGameAccounts <= 0 then
		return nil;
	end

	-- If there is only one game account, then this is the only direct invite target that could potentially exist
	if numGameAccounts == 1 then
		local accountInfo = C_BattleNet.GetFriendAccountInfo(friendIndex);
		local isValidDirectInviteTarget = (accountInfo ~= nil) and (accountInfo.gameAccountInfo.playerGuid ~= nil);
		return isValidDirectInviteTarget and accountInfo.gameAccountInfo or nil;
	end

	-- If there are multiple game accounts, then we need to iterate through them to see if there is exactly one valid direct invite target
	local gameStateUsesFactions = FriendsListUtil.GameStateUsesFactions();
	local playerFaction = gameStateUsesFactions and UnitFactionGroup("player") or nil;
	local directInviteTargetGameAccountInfo = nil;
	for accountIndex = 1, numGameAccounts do
		local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(friendIndex, accountIndex);
		if IsBattleNetFriendGameAccountInfoValidDirectInviteTarget(gameAccountInfo, gameStateUsesFactions, playerFaction) then
			-- If we already found a valid direct invite target, then there are multiple possible invite targets and we should bail
			-- The player will need to pick which one they want to invite from a dropdown menu
			local alreadyFoundOneDirectInviteTarget = directInviteTargetGameAccountInfo ~= nil;
			if alreadyFoundOneDirectInviteTarget then
				return nil;
			end

			directInviteTargetGameAccountInfo = gameAccountInfo;
		end
	end

	-- We found exactly one direct invite target across all the game accounts
	return directInviteTargetGameAccountInfo;
end

local BattleNetFriendPartyInviteRestrictionText =
{
	[BattleNetFriendPartyInviteRestrictionType.Leader] = ERR_TRAVEL_PASS_NOT_LEADER,
	[BattleNetFriendPartyInviteRestrictionType.Faction] = ERR_TRAVEL_PASS_NOT_ALLIED,
	[BattleNetFriendPartyInviteRestrictionType.Realm] = ERR_TRAVEL_PASS_DIFFERENT_REALM,
	[BattleNetFriendPartyInviteRestrictionType.MissingRealmInfo] = ERR_TRAVEL_PASS_NO_INFO,
	[BattleNetFriendPartyInviteRestrictionType.Client] = ERR_TRAVEL_PASS_NOT_WOW,
	[BattleNetFriendPartyInviteRestrictionType.DifferentWowProject] = ERR_TRAVEL_PASS_WRONG_PROJECT,
	[BattleNetFriendPartyInviteRestrictionType.WowProjectMainline] = ERR_TRAVEL_PASS_WRONG_PROJECT_MAINLINE_OVERRIDE,
	[BattleNetFriendPartyInviteRestrictionType.WowProjectClassic] = ERR_TRAVEL_PASS_WRONG_PROJECT_CLASSIC_OVERRIDE,
	[BattleNetFriendPartyInviteRestrictionType.Mobile] = ERR_TRAVEL_PASS_MOBILE,
	[BattleNetFriendPartyInviteRestrictionType.DifferentRegion] = ERR_TRAVEL_PASS_DIFFERENT_REGION,
	[BattleNetFriendPartyInviteRestrictionType.QuestSession] = ERR_TRAVEL_PASS_QUEST_SESSION,
	[BattleNetFriendPartyInviteRestrictionType.IncompatibleGameMode] = ERR_TRAVEL_PASS_GAME_MODE,
};

function FriendsListUtil.GetBattleNetFriendPartyInviteRestrictionText(restrictionType)
	return BattleNetFriendPartyInviteRestrictionText[restrictionType] or "";
end

function FriendsListUtil.ShouldShowRichPresenceOnly(accountInfo)
	if not accountInfo then
		return true;
	end

	local gameAccountInfo = accountInfo.gameAccountInfo;
	-- This lookup should be replaced with a separate field instead of relying on classID.
	local friendIsPlayingOtherGameMode = CLASS_ID_TO_GAME_MODE[gameAccountInfo.classID] ~= nil;
	if friendIsPlayingOtherGameMode then
		return true;
	end

	local friendIsPlayingWow = FriendsListUtil.IsPlayingWoW(gameAccountInfo);
	if not friendIsPlayingWow then
		return true;
	end

	local friendIsPlayingSameWowProject = gameAccountInfo.wowProjectID == WOW_PROJECT_ID;
	if not friendIsPlayingSameWowProject then
		return true;
	end

	local playerIsPlayingClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC;
	if playerIsPlayingClassic then
		-- On glue screens we have no player faction/realm to compare, so default to rich presence
		if C_Glue.IsOnGlueScreen() then
			return true;
		end

		local friendIsSameFaction = gameAccountInfo.factionName == UnitFactionGroup("player");
		local friendIsSameRealm = gameAccountInfo.realmID == GetRealmID();
		if not friendIsSameFaction or not friendIsSameRealm then
			return true;
		end
	end

	local hasValidAreaName = gameAccountInfo.areaName ~= nil;
	return not hasValidAreaName;
end

function FriendsListUtil.GetRelativeTimeText(timestamp)
	local timeDifference = time() - timestamp;

	local withinOneMinute = timeDifference < SECONDS_PER_MIN;
	if withinOneMinute then
		return LASTONLINE_SECS;
	end

	local withinOneHour = timeDifference >= SECONDS_PER_MIN and timeDifference < SECONDS_PER_HOUR;
	if withinOneHour then
		return LASTONLINE_MINUTES:format(floor(timeDifference / SECONDS_PER_MIN));
	end

	local withinOneDay = timeDifference >= SECONDS_PER_HOUR and timeDifference < SECONDS_PER_DAY;
	if withinOneDay then
		return LASTONLINE_HOURS:format(floor(timeDifference / SECONDS_PER_HOUR));
	end

	local withinOneMonth = timeDifference >= SECONDS_PER_DAY and timeDifference < SECONDS_PER_MONTH;
	if withinOneMonth then
		return LASTONLINE_DAYS:format(floor(timeDifference / SECONDS_PER_DAY));
	end

	local withinOneYear = timeDifference >= SECONDS_PER_MONTH and timeDifference < SECONDS_PER_YEAR;
	if withinOneYear then
		return LASTONLINE_MONTHS:format(floor(timeDifference / SECONDS_PER_MONTH));
	end

	return LASTONLINE_YEARS:format(floor(timeDifference / SECONDS_PER_YEAR));
end

function FriendsListUtil.GetLastOnlineText(accountInfo)
	if not accountInfo then
		return FRIENDS_LIST_OFFLINE;
	end

	local hasValidLastOnlineTime = accountInfo.lastOnlineTime > 0;
	local lastOnlineOverAYearAgo = hasValidLastOnlineTime and HasTimePassed(accountInfo.lastOnlineTime, SECONDS_PER_YEAR);
	if not hasValidLastOnlineTime or lastOnlineOverAYearAgo then
		return FRIENDS_LIST_OFFLINE;
	end

	local lastOnlineTimeText = FriendsListUtil.GetRelativeTimeText(accountInfo.lastOnlineTime);
	return BNET_LAST_ONLINE_TIME:format(lastOnlineTimeText);
end

function FriendsListUtil.GetFormattedCharacterName(accountInfo)
	if not accountInfo then
		return "";
	end

	local gameAccountInfo = accountInfo.gameAccountInfo;
	local characterName = BNet_GetValidatedCharacterName(gameAccountInfo.characterName, accountInfo.battleTag, gameAccountInfo.clientProgram);

	if gameAccountInfo.timerunningSeasonID then
		characterName = TimerunningUtil.AddSmallIcon(characterName);
	end

	return characterName;
end

function FriendsListUtil.BuildFriendNameDisplayText(accountInfo)
	local nameText = FriendsListUtil.GetFriendAccountNameText(accountInfo);
	local isOnline = accountInfo and accountInfo.gameAccountInfo.isOnline;
	local displayColor = isOnline and FRIENDS_BNET_NAME_COLOR or DARKGRAY_COLOR;
	return displayColor:WrapTextInColorCode(nameText);
end

function FriendsListUtil.GetFriendAccountNameText(accountInfo)
	if not accountInfo then
		return "";
	end

	return BNet_GetBNetAccountName(accountInfo) or "";
end

function FriendsListUtil.BuildCharacterNameDisplayText(accountInfo)
	if not accountInfo then
		return "";
	end

	local gameAccountInfo = accountInfo.gameAccountInfo;
	if not gameAccountInfo.characterName then
		return "";
	end

	local characterName = FriendsListUtil.GetFormattedCharacterName(accountInfo);
	local displayColor = accountInfo.gameAccountInfo.isOnline and NORMAL_FONT_COLOR or DARKGRAY_COLOR;
	return displayColor:WrapTextInColorCode(characterName);
end

function FriendsListUtil.BuildCharacterLevelDisplayText(accountInfo)
	if not accountInfo or not accountInfo.gameAccountInfo.characterLevel then
		return "";
	end

	local levelText = string.format(SOCIAL_UI_RECENT_ALLIES_CARD_LEVEL_DISPLAY_FORMAT, accountInfo.gameAccountInfo.characterLevel);
	local displayColor = accountInfo.gameAccountInfo.isOnline and HIGHLIGHT_FONT_COLOR or DARKGRAY_COLOR;
	return displayColor:WrapTextInColorCode(levelText);
end

function FriendsListUtil.BuildCharacterClassDisplayText(accountInfo)
	if not accountInfo or not accountInfo.gameAccountInfo.className then
		return "";
	end

	local hasValidClassFilename = accountInfo.gameAccountInfo.classFilename and accountInfo.gameAccountInfo.classFilename ~= "";
	local useClassColor = accountInfo.gameAccountInfo.isOnline and hasValidClassFilename;
	local displayColor = useClassColor and GetClassColorObj(accountInfo.gameAccountInfo.classFilename) or DARKGRAY_COLOR;
	return displayColor:WrapTextInColorCode(accountInfo.gameAccountInfo.className);
end

local function GetDecoratedLocationText(accountInfo, locationText)
	if not accountInfo or not locationText then
		return UNKNOWN;
	end

	local friendIsPlayingWoW = FriendsListUtil.IsPlayingWoW(accountInfo.gameAccountInfo);
	local friendIsRAFLinked = accountInfo.rafLinkType ~= Enum.RafLinkType.None;
	if friendIsPlayingWoW and friendIsRAFLinked then
		local bestRAFString = accountInfo.rafLinkType == Enum.RafLinkType.Recruit and RAF_RECRUIT_FRIEND or RAF_RECRUITER_FRIEND;
		return bestRAFString:format(locationText);
	end

	return locationText;
end

local function BuildOnlineLocationDisplayText(accountInfo)
	if not accountInfo then
		return "";
	end

	local gameAccountInfo = accountInfo.gameAccountInfo;

	local rawLocationText;
	if FriendsListUtil.ShouldShowRichPresenceOnly(accountInfo) then
		rawLocationText = gameAccountInfo.richPresence;
	else
		rawLocationText = gameAccountInfo.areaName;
	end

	return GetDecoratedLocationText(accountInfo, rawLocationText);
end

function FriendsListUtil.BuildLocationDisplayText(accountInfo)
	if not accountInfo then
		return "";
	end

	local isOnline = accountInfo.gameAccountInfo.isOnline;
	local locationText = isOnline and BuildOnlineLocationDisplayText(accountInfo) or FriendsListUtil.GetLastOnlineText(accountInfo);
	local displayColor = isOnline and FRIENDS_GRAY_COLOR or DARKGRAY_COLOR;
	return displayColor:WrapTextInColorCode(locationText);
end

local REGION_NAMES =
{
	[1] = NORTH_AMERICA,
	[2] = KOREA,
	[3] = EUROPE,
	[4] = TAIWAN,
	[5] = CHINA,
};

function FriendsListUtil.GetRegionName(accountInfo)
	if not accountInfo then
		return "";
	end

	return REGION_NAMES[accountInfo.gameAccountInfo.regionID] or UNKNOWN;
end

function FriendsListUtil.BuildTooltipBroadcastText(accountInfo)
	if not accountInfo then
		return nil;
	end

	local hasNoBroadcast = accountInfo.customMessage == "";
	if hasNoBroadcast then
		return nil;
	end

	local hasValidTimestamp = accountInfo.customMessageTime and accountInfo.customMessageTime > 0;
	local broadcastSentWithinAYear = hasValidTimestamp and not HasTimePassed(accountInfo.customMessageTime, SECONDS_PER_YEAR);
	if broadcastSentWithinAYear then
		local broadcastTimeText = FriendsListUtil.GetRelativeTimeText(accountInfo.customMessageTime);
		return SOCIAL_UI_FRIENDS_LIST_BATTLE_NET_FRIEND_BROADCAST_AND_DATE_FORMAT:format(accountInfo.customMessage, broadcastTimeText);
	end

	return SOCIAL_UI_FRIENDS_LIST_BATTLE_NET_FRIEND_BROADCAST_FORMAT:format(accountInfo.customMessage);
end

local INVITE_TYPE_TOOLTIP_TEXT =
{
	["INVITE"] = TRAVEL_PASS_INVITE,
	["SUGGEST_INVITE"] = SUGGEST_INVITE,
	["REQUEST_INVITE"] = REQUEST_INVITE,
	["INVITE_CROSS_FACTION"] = TRAVEL_PASS_INVITE_CROSS_FACTION,
	["SUGGEST_INVITE_CROSS_FACTION"] = SUGGEST_INVITE_CROSS_FACTION,
	["REQUEST_INVITE_CROSS_FACTION"] = REQUEST_INVITE_CROSS_FACTION,
};

function FriendsListUtil.GetBattleNetFriendInviteTypeLabel(inviteType)
	return INVITE_TYPE_TOOLTIP_TEXT[inviteType] or "";
end

local REQUEST_INVITE_TYPES =
{
	"REQUEST_INVITE",
	"REQUEST_INVITE_CROSS_FACTION",
};

function FriendsListUtil.IsRequestInviteType(inviteType)
	return tContains(REQUEST_INVITE_TYPES, inviteType);
end

-- Tries to find the best game account to invite for a Battle.net friend.
-- We prefer a same-faction account if one exists, otherwise we fall back to the last invitable account found.
function FriendsListUtil.GetBattleNetFriendInviteInfo(friendIndex)
	if not friendIndex then
		return {};
	end

	local playerFaction = FriendsListUtil.GameStateUsesFactions() and UnitFactionGroup("player") or nil;
	local friendPlayerGUID = nil;
	local friendFactionName = nil;
	-- Iterate through all game accounts, preferring a same-faction account for the invite target.
	for accountIndex = 1, C_BattleNet.GetFriendNumGameAccounts(friendIndex) do
		local gameAccountInfo = C_BattleNet.GetFriendGameAccountInfo(friendIndex, accountIndex);
		local playerGUID = gameAccountInfo.playerGuid;
		if playerGUID then
			friendPlayerGUID = playerGUID;
			friendFactionName = gameAccountInfo.factionName;

			-- If this account is same-faction then we don't need to keep searching for a better result.
			local isSameFaction = playerFaction and friendFactionName == playerFaction;
			if isSameFaction then
				break;
			end
		end
	end

	local isCrossFaction = playerFaction and friendFactionName and (friendFactionName ~= playerFaction);
	local inviteType = GetDisplayedInviteType(friendPlayerGUID);
	if isCrossFaction then
		inviteType = inviteType .. "_CROSS_FACTION";
	end

	return { inviteType = inviteType, isCrossFaction = isCrossFaction, playerGUID = friendPlayerGUID, factionName = friendFactionName };
end

function FriendsListUtil.InviteOrRequestToJoin(playerGUID, gameAccountID)
	if not gameAccountID then
		return;
	end

	-- GetDisplayedInviteType and party state are not available at glue so we just send the invite directly.
	if C_Glue.IsOnGlueScreen() then
		C_BattleNet.InviteFriend(gameAccountID);
		return;
	end

	local inviteType = playerGUID and GetDisplayedInviteType(playerGUID) or nil;
	if not inviteType then
		return;
	end

	local isRequestInvite = FriendsListUtil.IsRequestInviteType(inviteType);
	if isRequestInvite then
		BNRequestInviteFriend(gameAccountID);
		return;
	end

	local isSuggestInvite = inviteType == "SUGGEST_INVITE" or inviteType == "SUGGEST_INVITE_CROSS_FACTION";
	if isSuggestInvite and C_PartyInfo.IsPartyFull() then
		ChatFrameUtil.DisplaySystemMessageInPrimary(ERR_GROUP_FULL);
		return;
	end

	C_BattleNet.InviteFriend(gameAccountID);
end

function FriendsListUtil.HasMultipleGameAccounts(friendIndex)
	if not friendIndex then
		return false;
	end

	return C_BattleNet.GetFriendNumGameAccounts(friendIndex) > 1;
end
