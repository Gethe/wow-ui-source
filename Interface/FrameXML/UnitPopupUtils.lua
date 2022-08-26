function UnitPopupSharedUtil:GetBNetIDAccount()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if dropdownMenu.bnetIDAccount then
		return dropdownMenu.bnetIDAccount;
	elseif dropdownMenu.guid and C_AccountInfo.IsGUIDBattleNetAccountType(dropdownMenu.guid) then
		return C_AccountInfo.GetIDFromBattleNetAccountGUID(dropdownMenu.guid);
	end
end

function UnitPopupSharedUtil:GetBNetAccountInfo()
	local bnetIDAccount = UnitPopupSharedUtil.GetBNetIDAccount()
	if bnetIDAccount then
		return C_BattleNet.GetAccountInfoByID(bnetIDAccount);
	else
		local guid = UnitPopupSharedUtil.GetGUID()
		if guid then
			return C_BattleNet.GetAccountInfoByGUID(guid);
		end
	end
end

function UnitPopupSharedUtil:TryCreatePlayerLocation(guid)
	local dropdown = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if dropdown.battlefieldScoreIndex then
		return PlayerLocation:CreateFromBattlefieldScoreIndex(dropdown.battlefieldScoreIndex);
	elseif dropdown.communityClubID and dropdown.communityStreamID and dropdown.communityEpoch and dropdown.communityPosition then
		return PlayerLocation:CreateFromCommunityChatData(dropdown.communityClubID, dropdown.communityStreamID, dropdown.communityEpoch, dropdown.communityPosition);
	elseif dropdown.communityClubID and not dropdown.communityStreamID then
		return PlayerLocation:CreateFromCommunityInvitation(dropdown.communityClubID, guid);
	elseif C_ChatInfo.IsValidChatLine(dropdown.lineID) then
		return PlayerLocation:CreateFromChatLineID(dropdown.lineID);
	elseif guid then
		return PlayerLocation:CreateFromGUID(guid);
	elseif dropdown.unit then
		return PlayerLocation:CreateFromUnit(dropdown.unit);
	elseif dropdown.whoIndex then 
		return PlayerLocation:CreateFromWhoIndex(dropdown.whoIndex);
	end

	return nil;
end
	

function UnitPopupSharedUtil:IsBNetFriend()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	return dropdownMenu.accountInfo and dropdownMenu.accountInfo.isFriend;
end

function UnitPopupSharedUtil:CanAddBNetFriend(isLocalPlayer, haveBattleTag, isPlayer)
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local hasClubInfo = dropdownMenu.clubInfo ~= nil and dropdownMenu.clubMemberInfo ~= nil;
	return not isLocalPlayer and haveBattleTag and (isPlayer or hasClubInfo or dropdownMenu.accountInfo) and not UnitPopupSharedUtil.IsBNetFriend();
end

function UnitPopupSharedUtil:GetCurrentDropdownMenu()
	return UIDROPDOWNMENU_OPEN_MENU or UIDROPDOWNMENU_INIT_MENU; 
end 

function UnitPopupSharedUtil:GetFullPlayerName()
	local dropdownFrame = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	return dropdownFrame.name;
end		

function UnitPopupSharedUtil:HasLFGRestrictions()
	return false; 
end	

function UnitPopupSharedUtil:TryInvite(inviteType, fullname)
	local dropdown = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if inviteType == "SUGGEST_INVITE" and C_PartyInfo.IsPartyFull() and not UnitIsGroupLeader("player") then
		ChatFrame_DisplaySystemMessageInPrimary(ERR_GROUP_FULL);
	else
		if inviteType == "INVITE" or inviteType == "SUGGEST_INVITE" then
			InviteToGroup(fullname);
		elseif inviteType == "REQUEST_INVITE" then
			RequestInviteFromUnit(fullname);
		end
	end
end