UnitPopupSharedUtil = { }; 

--Add your project specific implementation in UnitPopupUtils
function UnitPopupSharedUtil:GetBNetIDAccount()
	return nil; 
end

function UnitPopupSharedUtil:GetGUID()
	local dropdown = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if dropdown.guid then
		return dropdown.guid;
	elseif dropdown.unit then
		return UnitGUID(dropdown.unit);
	elseif type(dropdown.userData) == "table" and dropdown.userData.guid then
		return dropdown.userData.guid;
	elseif dropdown.accountInfo and dropdown.accountInfo.gameAccountInfo.playerGuid then
		return dropdown.accountInfo.gameAccountInfo.playerGuid;
	end
	return nil;
end

--Add your project specific implementation in UnitPopupUtils
function UnitPopupSharedUtil:GetBNetAccountInfo()
	return nil; 
end

function UnitPopupSharedUtil:GetIsMobile()
	local dropdown = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if dropdown.isMobile ~= nil then
		return dropdown.isMobile;
	elseif dropdown.accountInfo and dropdown.accountInfo.gameAccountInfo then
		return dropdown.accountInfo.gameAccountInfo.isWowMobile;
	end
end

--Add your project specific implementation in UnitPopupUtils
function UnitPopupSharedUtil:TryCreatePlayerLocation(guid)
	return nil; 
end

function UnitPopupSharedUtil:IsValidPlayerLocation(playerLocation)
	return playerLocation and playerLocation:IsValid();
end

function UnitPopupSharedUtil:IsSameServer(playerLocation)
	local dropdown = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if playerLocation then
		return C_PlayerInfo.UnitIsSameServer(playerLocation);
	elseif dropdown.accountInfo and dropdown.accountInfo.gameAccountInfo.realmName then
		return dropdown.accountInfo.gameAccountInfo.realmName == GetRealmName();
	end
end

function UnitPopupSharedUtil:IsSameServerFromSelf()
	local guid = UnitPopupSharedUtil.GetGUID();
	local playerLocation = UnitPopupSharedUtil:TryCreatePlayerLocation(guid);
	return UnitPopupSharedUtil:IsSameServer(playerLocation);
end		

function UnitPopupSharedUtil:HasBattleTag()
	if BNFeaturesEnabledAndConnected() then
		local _, battleTag = BNGetInfo();
		if battleTag then
			return true;
		end
	end
end

function UnitPopupSharedUtil:CanCooperate()
	local dropdown = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	return dropdown.unit and UnitCanCooperate("player", dropdown.unit);
end

function UnitPopupSharedUtil:IsPlayer()
	local dropdown = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	return dropdown.unit and UnitIsPlayer(dropdown.unit);
end

function UnitPopupSharedUtil:GetLFGCategoryForLFGSlot(lfgSlot)
	if lfgSlot then
		return GetLFGCategoryForID(lfgSlot);
	end
end

function UnitPopupSharedUtil:IsPlayerOffline()
	local dropdown = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if dropdown.isOffline then
		return true;
	elseif dropdown.clubMemberInfo then
		local presence = dropdown.clubMemberInfo.presence;
		if presence == Enum.ClubMemberPresence.Offline or presence == Enum.ClubMemberPresence.Unknown then
			return true;
		end
	elseif dropdown.accountInfo then
		if not dropdown.accountInfo.gameAccountInfo.isOnline then
			return true;
		end
	end

	return false;
end

function UnitPopupSharedUtil:IsPlayerFavorite()
	local dropdown = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	return dropdown.accountInfo and dropdown.accountInfo.isFavorite;
end

function UnitPopupSharedUtil:IsPlayerMobile()
	local dropdown = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if dropdown.clubMemberInfo then
		local presence = dropdown.clubMemberInfo.presence;
		if presence == Enum.ClubMemberPresence.Offline or presence == Enum.ClubMemberPresence.Unknown then
			return true;
		end
	end

	return false;
end

function UnitPopupSharedUtil:GetIsLocalPlayer()
	local dropdown = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 

	if dropdown.isSelf then
		return true;
	end

	local guid = UnitPopupSharedUtil.GetGUID(dropdown);
	if guid and C_AccountInfo.IsGUIDRelatedToLocalAccount(guid) then
		return true;
	end

	if dropdown.clubMemberInfo and dropdown.clubMemberInfo.isSelf then
		return true;
	end

	return false;
end

function UnitPopupSharedUtil:IsInGroupWithPlayer()
	local dropdown = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if dropdown.accountInfo and dropdown.accountInfo.gameAccountInfo.characterName then
		return	UnitInParty(dropdown.accountInfo.gameAccountInfo.characterName) or UnitInRaid(dropdown.accountInfo.gameAccountInfo.characterName);
	elseif dropdown.guid then
		return IsGUIDInGroup(dropdown.guid);
	end
end

--Add your project specific implementation in UnitPopupUtils
function UnitPopupSharedUtil:IsBNetFriend()
	return nil; 
end

--Add your project specific implementation in UnitPopupUtils
function UnitPopupSharedUtil:CanAddBNetFriend(isLocalPlayer, haveBattleTag, isPlayer)
	return nil; 
end

function UnitPopupSharedUtil:IsEnabled(unitPopupButton)
	if(not unitPopupButton) then
		return false; 
	end 
	local dropdown = UnitPopupSharedUtil.GetCurrentDropdownMenu();

	if unitPopupButton.isUninteractable then
		return false;
	end

	local dist = unitPopupButton:GetInteractDistance();
	if dist and not CheckInteractDistance(dropdown.unit, dist) then
		return false;
	end

	if unitPopupButton:IsDisabledInKioskMode() and Kiosk.IsEnabled() then
		return false;
	end

	if(unitPopupButton:IsDisabled()) then 
		return false; 
	end 

	if(not unitPopupButton:IsEnabled()) then 
		return false; 
	end 

	return true;
end

function UnitPopupSharedUtil:TryBNInvite()
	local dropdown = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local gameAccountInfo = dropdown.accountInfo and dropdown.accountInfo.gameAccountInfo;
	if gameAccountInfo and gameAccountInfo.playerGuid and gameAccountInfo.gameAccountID then
		FriendsFrame_InviteOrRequestToJoin(gameAccountInfo.playerGuid, gameAccountInfo.gameAccountID);
		return true;
	end
	return false; 
end

function UnitPopupSharedUtil:TryInvite(inviteType, fullname)
	return nil;
end

function UnitPopupSharedUtil:CreateUnitPopupReport(reportType, playerName, playerGUID, playerLocation)
	local reportInfo = ReportInfo:CreateReportInfoFromType(reportType);
	if(reportInfo) then 
		reportInfo:SetReportTarget(playerGUID);
		ReportFrame:InitiateReport(reportInfo, playerName, playerLocation); 
	end		
end

function UnitPopupSharedUtil:CreateUnitPopupReportPet(reportType, playerName, petGUID)
	local reportInfo = ReportInfo:CreatePetReportInfo(reportType, petGUID);
	if(reportInfo) then 
		ReportFrame:InitiateReport(reportInfo, playerName, playerLocation); 
	end		
end

function UnitPopupSharedUtil:GetCurrentDropdownMenu()
	return UIDROPDOWNMENU_OPEN_MENU or UIDROPDOWNMENU_INIT_MENU; 
end 

--Add your project specific implementation in UnitPopupUtils
function UnitPopupSharedUtil:GetFullPlayerName()
	return nil; 
end		

--Add your project specific implementation in UnitPopupUtils
function UnitPopupSharedUtil:HasLFGRestrictions()
	return nil; 
end	 