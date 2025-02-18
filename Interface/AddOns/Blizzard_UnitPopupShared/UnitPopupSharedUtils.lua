local PROJECT_IMPL_REQUIRED = "Add implementation in UnitPopupUtils.lua";

UnitPopupSharedUtil = { }; 

function UnitPopupSharedUtil.GetBNetIDAccount(contextData)
	return nil;
end

function UnitPopupSharedUtil.GetGUID(contextData)
	if contextData.guid then
		return contextData.guid;
	end
	
	local unit = contextData.unit;
	if unit then
		return UnitGUID(unit);
	end
	
	local accountInfo = contextData.accountInfo;
	if not accountInfo then
		return nil;
	end

	return accountInfo.gameAccountInfo.playerGuid;
end

function UnitPopupSharedUtil.GetBNetAccountInfo(contextData)
	return nil; 
end

function UnitPopupSharedUtil.GetIsMobile(contextData)
	local isMobile = contextData.isMobile;
	if isMobile ~= nil then
		return isMobile;
	end
	
	local accountInfo = contextData.accountInfo;
	if not accountInfo then
		return false;
	end

	local gameAccountInfo = accountInfo.gameAccountInfo;
	if not gameAccountInfo then
		return false;
	end

	return gameAccountInfo.isWowMobile;
end

function UnitPopupSharedUtil.TryCreatePlayerLocation(contextData)
	return nil; 
end

function UnitPopupSharedUtil.IsValidPlayerLocation(playerLocation)
	return playerLocation and playerLocation:IsValid();
end

function UnitPopupSharedUtil.IsSameServer(contextData, playerLocation)
	if playerLocation then
		return C_PlayerInfo.UnitIsSameServer(playerLocation);
	end
	
	local accountInfo = contextData.accountInfo;
	if not accountInfo then
		return false;
	end

	local realmName = accountInfo.gameAccountInfo.realmName;
	if not realmName then
		return false;
	end

	return realmName == GetRealmName();
end

function UnitPopupSharedUtil.IsSameServerFromSelf(contextData)
	local playerLocation = UnitPopupSharedUtil.TryCreatePlayerLocation(contextData);
	return UnitPopupSharedUtil.IsSameServer(contextData, playerLocation);
end		

function UnitPopupSharedUtil.HasBattleTag()
	if not BNFeaturesEnabledAndConnected() then
		return false;
	end

	local battleTag = select(2, BNGetInfo());
	return battleTag ~= nil;
end

function UnitPopupSharedUtil.CanCooperate(contextData)
	local unit = contextData.unit;
	return unit and UnitCanCooperate("player", unit);
end

function UnitPopupSharedUtil.IsPlayer(contextData)
	local unit = contextData.unit;
	return unit and UnitIsPlayer(unit);
end

function UnitPopupSharedUtil.IsPlayerOffline(contextData)
	if contextData.isOffline then
		return true;
	end
	
	local clubMemberInfo = contextData.clubMemberInfo;
	if clubMemberInfo then
		local presence = clubMemberInfo.presence;
		if presence == Enum.ClubMemberPresence.Offline or presence == Enum.ClubMemberPresence.Unknown then
			return true;
		end
	else
		local accountInfo = contextData.accountInfo;
		if accountInfo and not accountInfo.gameAccountInfo.isOnline then
			return true;
		end
	end

	return false;
end

function UnitPopupSharedUtil.IsPlayerFavorite(contextData)
	local accountInfo = contextData.accountInfo;
	return accountInfo and accountInfo.isFavorite;
end

function UnitPopupSharedUtil.IsPlayerMobile(contextData)
	local clubMemberInfo = contextData.clubMemberInfo;
	if not clubMemberInfo then
		return false;
	end

	local presence = clubMemberInfo.presence;
	return presence == Enum.ClubMemberPresence.Offline or presence == Enum.ClubMemberPresence.Unknown;
end

function UnitPopupSharedUtil.GetIsLocalPlayer(contextData)
	if contextData.isSelf then
		return true;
	end
	
	local clubMemberInfo = contextData.clubMemberInfo;
	if clubMemberInfo and clubMemberInfo.isSelf then
		return true;
	end

	local guid = UnitPopupSharedUtil.GetGUID(contextData);
	if guid and C_AccountInfo.IsGUIDRelatedToLocalAccount(guid) then
		return true;
	end

	return false;
end

function UnitPopupSharedUtil.IsInGroupWithPlayer(contextData)
	local accountInfo = contextData.accountInfo;
	if accountInfo then
		local characterName = accountInfo.gameAccountInfo.characterName;
		if characterName then
			return UnitInParty(characterName) or UnitInRaid(characterName);
		end
	end

	local guid = contextData.guid;
	if guid then
		return IsGUIDInGroup(guid);
	end

	return false;
end

function UnitPopupSharedUtil.IsBNetFriend(contextData)
	error(PROJECT_IMPL_REQUIRED);
	return nil; 
end

function UnitPopupSharedUtil.CanAddBNetFriend(contextData, isLocalPlayer, haveBattleTag, isPlayer)
	error(PROJECT_IMPL_REQUIRED);
	return nil; 
end

function UnitPopupSharedUtil.IsEnabled(contextData, unitPopupButton)
	assertsafe(contextData);
	if not unitPopupButton then
		return false; 
	end 

	if unitPopupButton:IsUninteractable() then
		return false;
	end

	local unit = contextData.unit;
	if unit then
		local dist = unitPopupButton:GetInteractDistance();
		if dist and not CheckInteractDistance(unit, dist) then
			return false;
		end
	end

	if Kiosk.IsEnabled() and unitPopupButton:IsDisabledInKioskMode() then
		return false;
	end

	if unitPopupButton:IsDisabled(contextData) then 
		return false; 
	end 

	if not unitPopupButton:IsEnabled(contextData) then 
		return false; 
	end 

	return true;
end

function UnitPopupSharedUtil.TryBNInvite(contextData)
	local gameAccountInfo = contextData.accountInfo and contextData.accountInfo.gameAccountInfo;
	if not gameAccountInfo then
		return false;
	end

	local playerGuid = gameAccountInfo.playerGuid;
	local gameAccountID = gameAccountInfo.gameAccountID;
	if not (playerGuid and gameAccountID) then
		return false;
	end

	FriendsFrame_InviteOrRequestToJoin(playerGuid, gameAccountID);
	return true; 
end

function UnitPopupSharedUtil.TryInvite(contextData, inviteType, fullname)
	return nil;
end

function UnitPopupSharedUtil.CreateUnitPopupReport(reportType, playerName, playerGUID, playerLocation)
	local reportInfo = ReportInfo:CreateReportInfoFromType(reportType);
	if not reportInfo then
		return;
	end
	
	reportInfo:SetReportTarget(playerGUID);
	ReportFrame:InitiateReport(reportInfo, playerName, playerLocation); 
end

function UnitPopupSharedUtil.CreateUnitPopupReportPet(reportType, playerName, petGUID)
	local reportInfo = ReportInfo:CreatePetReportInfo(reportType, petGUID);
	if not reportInfo then 
		return;
	end		
	
	ReportFrame:InitiateReport(reportInfo, playerName, playerLocation); 
end

function UnitPopupSharedUtil.GetFullPlayerName(contextData)
	return nil; 
end		

function UnitPopupSharedUtil.HasLFGRestrictions()
	error(PROJECT_IMPL_REQUIRED);
	return nil; 
end	 