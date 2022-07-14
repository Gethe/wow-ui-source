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
	end

	return nil;
end

local function UnitPopup_IsBNetFriend(dropdownMenu)
	return dropdownMenu.accountInfo and dropdownMenu.accountInfo.isFriend;
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

function UnitPopupSharedUtil:TryInvite(inviteType, fullname)
	local dropdown = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if inviteType == "SUGGEST_INVITE" and C_PartyInfo.IsPartyFull() and not UnitIsGroupLeader("player") then
		ChatFrame_DisplaySystemMessageInPrimary(ERR_GROUP_FULL);
	else
		if not UnitPopupSharedUtil.TryBNInvite(dropdown) then
			if inviteType == "INVITE" or inviteType == "SUGGEST_INVITE" then
				C_PartyInfo.InviteUnit(fullname);
			elseif inviteType == "REQUEST_INVITE" then
				C_PartyInfo.RequestInviteFromUnit(fullname);
			end
		end
	end
end

function UnitPopupSharedUtil:GetFullPlayerName()
	local dropdownFrame = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local fullName = dropdownFrame.name; 
	if dropdownFrame.isRafRecruit and dropdownFrame.accountInfo.gameAccountInfo.characterName and dropdownFrame.accountInfo.gameAccountInfo.realmName then
		fullName = dropdownFrame.accountInfo.gameAccountInfo.characterName.."-"..dropdownFrame.accountInfo.gameAccountInfo.realmName;
	elseif ( dropdownFrame.server and ((not dropdownFrame.unit and GetNormalizedRealmName() ~= dropdownFrame.server) or (dropdownFrame.unit and UnitRealmRelationship(dropdownFrame.unit) ~= LE_REALM_RELATION_SAME)) ) then
		fullName = dropdownFrame.name.."-"..dropdownFrame.server;
	end
	return fullName; 
end		

function UnitPopupSharedUtil:HasLFGRestrictions()
	return HasLFGRestrictions(); 
end	

function UnitPopupSharedUtil:IsInWarModeState()
	if C_PvP.IsWarModeActive() or (TALENT_WAR_MODE_BUTTON and TALENT_WAR_MODE_BUTTON:GetWarModeDesired()) then 
		return true; 
	end 
	return false; 
end