function UnitPopupSharedUtil.GetBNetIDAccount(contextData)
	if contextData.bnetIDAccount then
		return contextData.bnetIDAccount;
	end

	local guid = contextData.guid;
	if not guid or not C_AccountInfo.IsGUIDBattleNetAccountType(guid) then
		return false;
	end
	
	return C_AccountInfo.GetIDFromBattleNetAccountGUID(guid);
end

function UnitPopupSharedUtil.GetBNetAccountInfo(contextData)
	local bnetIDAccount = UnitPopupSharedUtil.GetBNetIDAccount(contextData);
	if bnetIDAccount then
		return C_BattleNet.GetAccountInfoByID(bnetIDAccount);
	end

	local guid = UnitPopupSharedUtil.GetGUID(contextData)
	if guid then
		return C_BattleNet.GetAccountInfoByGUID(guid);
	end

	return nil;
end


function UnitPopupSharedUtil.TryCreatePlayerLocation(contextData)
	local battlefieldScoreIndex = contextData.battlefieldScoreIndex;
	if battlefieldScoreIndex then
		return PlayerLocation:CreateFromBattlefieldScoreIndex(battlefieldScoreIndex);
	end
	
	local communityClubID = contextData.communityClubID;
	local communityStreamID = contextData.communityStreamID;
	local communityEpoch = contextData.communityEpoch;
	local communityPosition = contextData.communityPosition;
	if communityClubID and communityStreamID and communityEpoch and communityPosition then
		return PlayerLocation:CreateFromCommunityChatData(communityClubID, communityStreamID, communityEpoch, communityPosition);
	end
	
	local guid = UnitPopupSharedUtil.GetGUID(contextData);
	if communityClubID and not communityStreamID then
		return PlayerLocation:CreateFromCommunityInvitation(communityClubID, guid);
	end
	
	local lineID = contextData.lineID;
	if C_ChatInfo.IsValidChatLine(lineID) then
		return PlayerLocation:CreateFromChatLineID(lineID);
	end
	
	if guid then
		return PlayerLocation:CreateFromGUID(guid);
	end
	
	local unit = contextData.unit;
	if unit then
		return PlayerLocation:CreateFromUnit(unit);
	end

	local whoIndex = contextData.whoIndex;
	if whoIndex then
		return PlayerLocation:CreateFromWhoIndex(whoIndex);
	end

	return nil;
end

function UnitPopupSharedUtil.IsBNetFriend(contextData)
	local accountInfo = contextData.accountInfo;
	return accountInfo and accountInfo.isFriend;
end

function UnitPopupSharedUtil.CanAddBNetFriend(contextData, isLocalPlayer, haveBattleTag, isPlayer)
	if isLocalPlayer or not haveBattleTag then
		return false;
	end

	local hasClubInfo = contextData.clubInfo and contextData.clubMemberInfo;
	if not (isPlayer or hasClubInfo or contextData.accountInfo) then
		return false;
	end

	return not UnitPopupSharedUtil.IsBNetFriend(contextData);
end

function UnitPopupSharedUtil.GetFullPlayerName(contextData)
	local name = contextData.name;
	local server = contextData.server;
	local unit = contextData.unit;
	if server and (not unit and GetNormalizedRealmName() ~= server) then
		return name.."-"..server;
	elseif unit and (UnitRealmRelationship(unit) ~= LE_REALM_RELATION_SAME) then
		return name.."-"..server;
	end

	return name; 
end

function UnitPopupSharedUtil.HasLFGRestrictions()
	return HasLFGRestrictions();
end	

function UnitPopupSharedUtil.TryInvite(contextData, inviteType, fullName)
	local isSuggestInvite = inviteType == "SUGGEST_INVITE";
	if isSuggestInvite and C_PartyInfo.IsPartyFull() and not UnitIsGroupLeader("player") then
		ChatFrame_DisplaySystemMessageInPrimary(ERR_GROUP_FULL);
	else
		if isSuggestInvite or inviteType == "INVITE" then
			InviteToGroup(fullName);
		elseif inviteType == "REQUEST_INVITE" then
			RequestInviteFromUnit(fullName);
		end
	end
end