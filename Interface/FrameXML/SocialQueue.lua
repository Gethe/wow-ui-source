-----------------------------
--Utils
-----------------------------
local function AppendQueueName(textTable, name, nameFormatter)
	if ( name ) then
		if ( nameFormatter ) then
			name = nameFormatter:format(name);
		end

		table.insert(textTable, name);
	end
end

function SocialQueueUtil_GetQueueName(queue, nameFormatter)
	local nameText = {};

	if ( queue.queueType == "lfg" ) then
		for i, lfgID in ipairs(queue.lfgIDs) do
			local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, textureFilename, difficulty, maxPlayers, description, isHoliday, _, _, isTimeWalker = GetLFGDungeonInfo(lfgID);
			if ( typeID == TYPEID_RANDOM_DUNGEON or isTimeWalker or isHoliday ) then
				-- Name remains unchanged
			elseif ( subtypeID == LFG_SUBTYPEID_DUNGEON ) then
				name = SOCIAL_QUEUE_FORMAT_DUNGEON:format(name);
			elseif ( subtypeID == LFG_SUBTYPEID_HEROIC ) then
				name = SOCIAL_QUEUE_FORMAT_HEROIC_DUNGEON:format(name);
			elseif ( subtypeID == LFG_SUBTYPEID_RAID ) then
				name = SOCIAL_QUEUE_FORMAT_RAID:format(name);
			elseif ( subtypeID == LFG_SUBTYPEID_FLEXRAID ) then
				name = SOCIAL_QUEUE_FORMAT_RAID:format(name);
			elseif ( subtypeID == LFG_SUBTYPEID_WORLDPVP ) then
				name = SOCIAL_QUEUE_FORMAT_WORLDPVP:format(name);
			else
				-- Name remains unchanged
			end

			AppendQueueName(nameText, name, nameFormatter);
		end
	elseif ( queue.queueType == "pvp" ) then
		local battlefieldType = queue.battlefieldType;
		local isBrawl = queue.isBrawl;
		local name = queue.mapName;
		if (isBrawl) then
			local brawlInfo = C_PvP.GetAvailableBrawlInfo();
			if (brawlInfo and brawlInfo.active) then
				name = brawlInfo.name;
			end
		elseif ( battlefieldType == "BATTLEGROUND" ) then
			name = SOCIAL_QUEUE_FORMAT_BATTLEGROUND:format(name);
		elseif ( battlefieldType == "ARENA" ) then
			name = SOCIAL_QUEUE_FORMAT_ARENA:format(queue.teamSize);
		elseif ( battlefieldType == "ARENASKIRMISH" ) then
			name = SOCIAL_QUEUE_FORMAT_ARENA_SKIRMISH;
		end

		AppendQueueName(nameText, name, nameFormatter);
	elseif ( queue.queueType == "lfglist" ) then
		local name;
		if ( queue.lfgListID ) then
			local searchResultInfo = C_LFGList.GetSearchResultInfo(queue.lfgListID);
			if searchResultInfo then
				name = searchResultInfo.name;
			end
		else
			if ( queue.activityID ) then
				name = C_LFGList.GetActivityInfo(queue.activityID);
			end
		end

		AppendQueueName(nameText, name, nameFormatter);
	end

	if ( #nameText > 0 ) then
		return table.concat(nameText, "\n");
	end

	return UNKNOWNOBJECT;
end

function SocialQueueUtil_GetHeaderName(groupGUID)
	local members = C_SocialQueue.GetGroupMembers(groupGUID);
	if ( not members ) then
		return "";
	else
		members = SocialQueueUtil_SortGroupMembers(members);

		local clubId = members[1].clubId;
		local playerName, color, relationship = SocialQueueUtil_GetRelationshipInfo(members[1].guid, nil, clubId);
		if ( #members > 1 ) then
			playerName = string.format(QUICK_JOIN_TOAST_EXTRA_PLAYERS, playerName, #members - 1);
		end
		playerName = color..playerName;

		if ( relationship == "club" and clubId ) then
			local clubInfo = C_Club.GetClubInfo(clubId);
			if ( clubInfo ) then
				playerName = SOCIAL_QUEUE_COMMUNITIES_HEADER_FORMAT:format(playerName, clubInfo.name);
			end
		end

		playerName = playerName..FONT_COLOR_CODE_CLOSE;

		return playerName;
	end
end

function SocialQueueUtil_SetTooltip(tooltip, playerDisplayName, queues, canJoin, hasRelationshipWithLeader)
	local firstQueue = queues[1];
	assert(firstQueue);

	local isAutoAccept = false;
	local canEffectivelyJoin = canJoin;
	local needTank, needHealer, needDamage;

	--For now, you can't queue for both LFGList and LFG+PvP.
	if ( firstQueue.queueData.queueType == "lfglist" ) then
		needTank, needHealer, needDamage = firstQueue.needTank, firstQueue.needHealer, firstQueue.needDamage;

		canEffectivelyJoin = canJoin and C_LFGList.HasSearchResultInfo(firstQueue.queueData.lfgListID);

		if ( canEffectivelyJoin ) then
			isAutoAccept = firstQueue.isAutoAccept; -- Auto accept is set on the premade group entry
			LFGListUtil_SetSearchEntryTooltip(tooltip, firstQueue.queueData.lfgListID, LFG_LIST_UTIL_SUPPRESS_AUTO_ACCEPT_LINE);
		else
			tooltip:SetText(playerDisplayName, 1, 1, 1, true);
			tooltip:AddLine(LFG_LIST_ENTRY_DELISTED, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
		end
	else
		tooltip:SetText(playerDisplayName, 1, 1, 1, true);
		tooltip:AddLine(SOCIAL_QUEUE_QUEUED_FOR, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		for i, queue in ipairs(queues) do
			local queueName = SocialQueueUtil_GetQueueName(queue.queueData, "- %s");
			if ( queue.isZombie ) then
				tooltip:AddLine(queueName, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true);
			else
				tooltip:AddLine(queueName, nil, nil, nil, true);
				isAutoAccept = (isAutoAccept or queue.isAutoAccept) and hasRelationshipWithLeader; -- Must know the leader to have autoaccept apply

				needTank = needTank or queue.needTank;
				needHealer = needHealer or queue.needHealer;
				needDamage = needDamage or queue.needDamage;
			end
		end

		if ( not canJoin ) then
			tooltip:AddLine(LFG_LIST_ENTRY_DELISTED, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
		end
	end

	-- Only add this information if joining the group is still relevant
	if ( canEffectivelyJoin ) then
		local roleIcons = "";
		if needTank then roleIcons = roleIcons..CreateAtlasMarkup("groupfinder-icon-role-large-tank", 16, 16); end
		if needHealer then roleIcons = roleIcons..CreateAtlasMarkup("groupfinder-icon-role-large-heal", 16, 16); end
		if needDamage then roleIcons = roleIcons..CreateAtlasMarkup("groupfinder-icon-role-large-dps", 16, 16); end

		tooltip:AddLine(" ");

		if roleIcons ~= "" then
			tooltip:AddLine(QUICK_JOIN_TOOLTIP_AVAILABLE_ROLES_FORMAT:format(QUICK_JOIN_TOOLTIP_AVAILABLE_ROLES, roleIcons), NORMAL_FONT_COLOR:GetRGB());
		else
			tooltip:AddLine(QUICK_JOIN_TOOLTIP_NO_AVAILABLE_ROLES, NORMAL_FONT_COLOR:GetRGB());
		end

		if isAutoAccept then
			tooltip:AddLine(QUICK_JOIN_IS_AUTO_ACCEPT_TOOLTIP, LIGHTBLUE_FONT_COLOR:GetRGB());
		end
	end
end

function SocialQueueUtil_GetRelationshipInfo(guid, missingNameFallback, clubId)
	local accountInfo = C_BattleNet.GetAccountInfoByGUID(guid);
	if accountInfo then
		return accountInfo.accountName, FRIENDS_BNET_NAME_COLOR_CODE, "bnfriend", GetBNPlayerLink(accountInfo.accountName, accountInfo.accountName, accountInfo.bnetAccountID, 0, 0, 0);
	end

	local name, normalizedRealmName = select(6, GetPlayerInfoByGUID(guid));
	name = name or missingNameFallback;

	local hasName = name ~= nil;
	if ( not hasName ) then
		name = UNKNOWNOBJECT;
	elseif ( normalizedRealmName and normalizedRealmName ~= "" ) then
		name = FULL_PLAYER_NAME:format(name, normalizedRealmName);
	end

	local linkName = name;
	local playerLink;

	if ( hasName ) then
		playerLink = GetPlayerLink(linkName, name);
	end

	if ( C_FriendList.IsFriend(guid) ) then
		return name, FRIENDS_WOW_NAME_COLOR_CODE, "wowfriend", playerLink;
	end

	if ( IsGuildMember(guid) ) then
		return name, RGBTableToColorCode(ChatTypeInfo.GUILD), "guild", playerLink;
	end

	local clubInfo = clubId and C_Club.GetClubInfo(clubId) or nil;
	if ( clubInfo ) then
		return name, FRIENDS_WOW_NAME_COLOR_CODE, "club", playerLink;
	end

	return name, FRIENDS_WOW_NAME_COLOR_CODE, nil, playerLink;
end

local relationshipPriorityOrdering = {
	["bnfriend"] = 1,
	["wowfriend"] = 2,
	["guild"] = 3,
	["club"] = 4,
};

function SocialQueueUtil_SortGroupMembers(members)
	table.sort(members, function(lhs, rhs)
		local lhsName, _, lhsRelationship = SocialQueueUtil_GetRelationshipInfo(lhs.guid, nil, lhs.clubId);
		local rhsName, _, rhsRelationship = SocialQueueUtil_GetRelationshipInfo(rhs.guid, nil, lhs.clubId);

		-- Sort order bnFriend
		if lhsRelationship ~= rhsRelationship then
			local lhsPriority = lhsRelationship and relationshipPriorityOrdering[lhsRelationship] or 10;
			local rhsPriority = rhsRelationship and relationshipPriorityOrdering[rhsRelationship] or 10;
			return lhsPriority < rhsPriority;
		end

		return strcmputf8i(lhsName, rhsName) <= 0;
	end);
	return members;
end

function SocialQueueUtil_HasRelationshipWithLeader(partyGuid)
	local leaderGuid = select(7, C_SocialQueue.GetGroupInfo(partyGuid));
	if ( leaderGuid ) then
		return select(3, SocialQueueUtil_GetRelationshipInfo(leaderGuid)) ~= nil;
	end

	return false;
end