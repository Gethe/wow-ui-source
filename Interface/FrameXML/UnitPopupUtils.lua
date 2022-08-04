function UnitPopupSharedUtil:GetBNetIDAccount()
	return nil;
end

function UnitPopupSharedUtil:GetBNetAccountInfo()
	return nil;
end

function UnitPopupSharedUtil:GetIsMobile()
	return nil;
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
	return nil;
end

function UnitPopupSharedUtil:CanAddBNetFriend(isLocalPlayer, haveBattleTag, isPlayer)
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if dropdownMenu.clubInfo == nil
		or dropdownMenu.clubMemberInfo == nil
		or dropdownMenu.clubMemberInfo.isSelf then
		return false; 
	end
	return true; 
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