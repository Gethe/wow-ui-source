function LFD_IsEmpowered()
	-- Solo players are always empowered.
	if ( not IsInGroup() ) then
		return true;
	end

	-- The leader may always queue or dequeue.
	if ( UnitIsGroupLeader("player") ) then
		return true;
	end

	return false;
end

function IsInLFDBattlefield()
	return false;
end

function LeaveInstanceParty()
	if ( IsInLFDBattlefield() ) then
		LFGTeleport(true);
	else
		LeaveParty();
	end
end

function ConfirmOrLeaveBattlefield()
	if ( GetBattlefieldWinner() ) then
		LeaveBattlefield();
	else
		StaticPopup_Show("CONFIRM_LEAVE_BATTLEFIELD");
	end
end

function WillAcceptInviteRemoveQueues()
	--Dungeon/Raid Finder
	for i = 1, NUM_LE_LFG_CATEGORYS do
		local mode = GetLFGMode(i);
		if ( mode and mode ~= "lfgparty" ) then
			return true;
		end
	end

	--PvP
	for i = 1, GetMaxBattlefieldID() do
		local status, _, _, _, _, _, _, _, _, _, _, _, asGroup = GetBattlefieldStatus(i);
		if ( ( status == "queued" or status == "confirmed" ) and asGroup ) then
			return true;
		end
	end

	return false;
end

function SetLookingForGroupUIAvailable(available)
	if C_LFGList and C_LFGList.GetPremadeGroupFinderStyle and C_LFGList.GetPremadeGroupFinderStyle() == Enum.PremadeGroupFinderStyle.Vanilla then
		if available then
			GroupFinderVanillaStyle_LoadUI();
		end
		return;
	end

	if available then
		LFGMicroButton:Show();
		MiniMapWorldMapButton:Show();
	else
		LFGMicroButton:Hide();
		MiniMapWorldMapButton:Hide();
	end
end

-- Only really works on friends and guild-mates.
function GetDisplayedInviteType(guid)
	if ( IsInGroup() ) then
		if ( UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") ) then
			return "INVITE";
		else
			return "SUGGEST_INVITE";
		end
	else
		if ( not guid ) then
			return "INVITE";
		end

		local party = UnitInParty(guid);--, isSoloQueueParty = C_SocialQueue.GetGroupForPlayer(guid);
		if ( party ) then
			return "REQUEST_INVITE";
		else
			return "INVITE";
		end
	end
end

function SocialQueueUtil_GetRelationshipInfo(guid, missingNameFallback, clubId)
	local hasFocus, characterName, client, realmName, realmID, faction, race, class, _, zoneName, level, gameText, broadcast, broadcastTime, online, bnetIDGameAccount, bnetIDAccount = BNGetGameAccountInfoByGUID(guid);
	if ( characterName and bnetIDAccount ) then
		local bnetIDAccountFriend, accountName = BNGetFriendInfoByID(bnetIDAccount);
		if ( accountName ) then
			return accountName, FRIENDS_BNET_NAME_COLOR_CODE, "bnfriend", GetBNPlayerLink(accountName, accountName, bnetIDAccountFriend, 0, 0, 0);
		end
	end

	local name, normalizedRealmName = select(6, GetPlayerInfoByGUID(guid));
	name = (name or missingNameFallback) or UNKNOWNOBJECT;
	local linkName = name;
	local playerLink;

	if name ~= UNKNOWNOBJECT then
		playerLink = GetPlayerLink(linkName, name);
	end

	if ( C_FriendList.IsFriend(guid) ) then
		return name, FRIENDS_WOW_NAME_COLOR_CODE, "wowfriend", playerLink;
	end

	if ( IsGuildMember(guid) ) then
		return name, RGBTableToColorCode(ChatTypeInfo.GUILD), "guild", playerLink;
	end

	if ( clubId ) then
		return name, FRIENDS_WOW_NAME_COLOR_CODE, "club", playerLink;
	end

	return name, FRIENDS_WOW_NAME_COLOR_CODE, nil, playerLink;
end
