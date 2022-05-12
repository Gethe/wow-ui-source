UnitPopupTeamPromoteButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);

function UnitPopupTeamPromoteButtonMixin:GetText()
	return TEAM_PROMOTE; 
end

function UnitPopupTeamPromoteButtonMixin:GetInteractDistance()
	return 0; 
end

function UnitPopupTeamPromoteButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if ( dropdownMenu.name == UnitName("player") or not PVPTeamDetails:IsShown() ) then
		return false; 
	elseif ( PVPTeamDetails:IsShown() and not IsArenaTeamCaptain(PVPTeamDetails.team) ) then
		return false; 
	end
	return true;
end

function UnitPopupTeamPromoteButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	local arenaName, teamIndex = GetArenaTeam(PVPTeamDetails.team);
	local dialog = StaticPopup_Show("CONFIRM_TEAM_PROMOTE", dropdownMenu.name, arenaName, teamIndex );
	if ( dialog ) then
		dialog.data = PVPTeamDetails.team;
		dialog.data2 = dropdownMenu.name;
	end
end

UnitPopupTeamKickButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);

function UnitPopupTeamKickButtonMixin:GetText()
	return TEAM_KICK; 
end

function UnitPopupTeamKickButtonMixin:GetInteractDistance()
	return 0; 
end

function UnitPopupTeamKickButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if ( dropdownMenu.name == UnitName("player") or not PVPTeamDetails:IsShown() ) then
		return false; 
	elseif ( PVPTeamDetails:IsShown() and not IsArenaTeamCaptain(PVPTeamDetails.team) ) then
		return false; 
	end
	return true;
end

function UnitPopupTeamKickButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	local arenaName, teamIndex = GetArenaTeam(PVPTeamDetails.team);
	local dialog = StaticPopup_Show("CONFIRM_TEAM_KICK", dropdownMenu.name, arenaName, teamIndex );
	if ( dialog ) then
		dialog.data = PVPTeamDetails.team;
		dialog.data2 = dropdownMenu.name;
	end
end

UnitPopupTeamLeaveButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);

function UnitPopupTeamLeaveButtonMixin:GetText()
	return TEAM_LEAVE; 
end

function UnitPopupTeamLeaveButtonMixin:GetInteractDistance()
	return 0; 
end

function UnitPopupTeamLeaveButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if (dropdownMenu.name ~= UnitName("player") or not PVPTeamDetails:IsShown() ) then
		return false;
	end
	return true;
end

function UnitPopupTeamLeaveButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	local arenaName = GetArenaTeam(PVPTeamDetails.team);
	local dialog = StaticPopup_Show("CONFIRM_TEAM_LEAVE", arenaName);
	if ( dialog ) then
		dialog.data = PVPTeamDetails.team;
	end
end

UnitPopupTeamDisbandButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);

function UnitPopupTeamDisbandButtonMixin:GetText()
	return TEAM_DISBAND; 
end

function UnitPopupTeamDisbandButtonMixin:GetInteractDistance()
	return 0; 
end

function UnitPopupTeamDisbandButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if ( PVPTeamDetails:IsShown() and (not IsArenaTeamCaptain(PVPTeamDetails.team) or dropdownMenu.name ~= UnitName("player")) ) then
		return false
	end
	return true;
end

function UnitPopupTeamDisbandButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	local arenaName = GetArenaTeam(PVPTeamDetails.team);
	local dialog = StaticPopup_Show("CONFIRM_TEAM_DISBAND", arenaName);
	if ( dialog ) then
		dialog.data = PVPTeamDetails.team;
	end
end


UnitPopupLootMethodButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);

function UnitPopupLootMethodButtonMixin:GetText()
	return LOOT_METHOD;
end

function UnitPopupLootMethodButtonMixin:IsNested()
	return true; 
end

function UnitPopupLootMethodButtonMixin:CanShow()
	return IsInGroup();
end

function UnitPopupLootMethodButtonMixin:IsEnabled()
	return UnitIsGroupLeader("player");
end

function UnitPopupLootMethodButtonMixin:GetButtons()
	return {
		UnitPopupLootFreeForAllButtonMixin,
		UnitPopupLootRoundRobinButtonMixin,
		UnitPopupMasterLooterButtonMixin,
		UnitPopupGroupLootButtonMixin,
		UnitPopupNeedBeforeGreedButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end 

UnitPopupLootFreeForAllButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);

function UnitPopupLootFreeForAllButtonMixin:GetText()
	return LOOT_FREE_FOR_ALL;
end

function UnitPopupLootFreeForAllButtonMixin:GetTooltipText()
	return NEWBIE_TOOLTIP_UNIT_FREE_FOR_ALL;
end 

function UnitPopupLootFreeForAllButtonMixin:GetLootMethod()
	return "freeforall";
end	

function UnitPopupLootFreeForAllButtonMixin:CanShow()
	if(not IsInGroup()) then 
		return false; 
	elseif (not UnitIsGroupLeader("player")) then
		return false; 
	elseif (GetLootMethod() == self:GetLootMethod()) then 
		return false;
	end 
	return true; 
end

function UnitPopupLootFreeForAllButtonMixin:OnClick()
	SetLootMethod(self:GetLootMethod());
	UIDropDownMenu_Refresh(UnitPopupSharedUtil.GetCurrentDropdownMenu(), nil, 1);
end

UnitPopupLootRoundRobinButtonMixin = CreateFromMixins(UnitPopupLootFreeForAllButtonMixin);
function UnitPopupLootRoundRobinButtonMixin:GetText()
	return LOOT_ROUND_ROBIN;
end

function UnitPopupLootRoundRobinButtonMixin:GetTooltipText()
	return NEWBIE_TOOLTIP_UNIT_ROUND_ROBIN;
end 

function UnitPopupLootRoundRobinButtonMixin:GetLootMethod()
	return "roundrobin";
end		

UnitPopupMasterLooterButtonMixin = CreateFromMixins(UnitPopupLootFreeForAllButtonMixin);
function UnitPopupMasterLooterButtonMixin:GetText()
	return LOOT_MASTER_LOOTER;
end

function UnitPopupMasterLooterButtonMixin:GetTooltipText()
	return NEWBIE_TOOLTIP_UNIT_MASTER_LOOTER;
end 

function UnitPopupMasterLooterButtonMixin:GetLootMethod()
	return "master";
end		

UnitPopupGroupLootButtonMixin = CreateFromMixins(UnitPopupLootFreeForAllButtonMixin);
function UnitPopupGroupLootButtonMixin:GetText()
	return LOOT_GROUP_LOOT;
end

function UnitPopupGroupLootButtonMixin:GetTooltipText()
	return NEWBIE_TOOLTIP_UNIT_GROUP_LOOT;
end 

function UnitPopupGroupLootButtonMixin:GetLootMethod()
	return "group";
end		

UnitPopupNeedBeforeGreedButtonMixin = CreateFromMixins(UnitPopupLootFreeForAllButtonMixin);
function UnitPopupNeedBeforeGreedButtonMixin:GetText()
	return LOOT_NEED_BEFORE_GREED;
end

function UnitPopupNeedBeforeGreedButtonMixin:GetLootMethod()
	return "needbeforegreed";
end		

function UnitPopupNeedBeforeGreedButtonMixin:GetTooltipText()
	return NEWBIE_TOOLTIP_UNIT_NEED_BEFORE_GREED;
end 

UnitPopupLootThresholdButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin)
function UnitPopupLootThresholdButtonMixin:GetText()
	return  _G["ITEM_QUALITY"..GetLootThreshold().."_DESC"];
end 

function UnitPopupLootThresholdButtonMixin:IsNested()
	return (IsInGroup() and UnitIsGroupLeader("player"));
end 

function UnitPopupLootThresholdButtonMixin:GetColor()
	return ITEM_QUALITY_COLORS[GetLootThreshold()].color; 
end

function UnitPopupLootThresholdButtonMixin:CanShow() 
	return IsInGroup(); 
end 

function UnitPopupLootThresholdButtonMixin:GetButtons()
	return { 
		UnitPopupItemQuality2DescButtonMixin,
		UnitPopupItemQuality3DescButtonMixin,
		UnitPopupItemQuality4DescButtonMixin,
		UnitPopupCancelButtonMixin,
	}
end 

function UnitPopupLootPromoteButtonMixin:GetText()
	return LOOT_PROMOTE;
end 

function UnitPopupLootPromoteButtonMixin:CanShow()
	local isMaster = nil;
	local lootMethod, partyIndex, raidIndex = GetLootMethod();
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();

	if ( (dropdownMenu.which == "RAID") or (dropdownMenu.which == "RAID_PLAYER") ) then
		if ( raidIndex and (dropdownMenu.unit == "raid"..raidIndex) ) then
			isMaster = true;
		end
	elseif ( dropdownMenu.which == "SELF" ) then
			if ( partyIndex and (partyIndex == 0) ) then
			isMaster = true;
			end
	else
		if ( partyIndex and (dropdownMenu.unit == "party"..partyIndex) ) then
			isMaster = true;
		end
	end
	if ( not IsInGroup() or not UnitIsGroupLeader("player") or (lootMethod ~= "master") or isMaster ) then
		return false; 
	end
	return true; 
end 

function UnitPopupLootPromoteButtonMixin:IsEnabled()
	local lootMethod, partyMaster, raidMaster = GetLootMethod();
	local dropdownFrame = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if ( not IsInGroup() or not UnitIsGroupLeader("player") or (lootMethod ~= "master") ) then
		return false; 
	else
		local masterName = 0;
		if ( partyMaster and (partyMaster == 0) ) then
			masterName = "player";
		elseif ( partyMaster ) then
			masterName = "party"..partyMaster;
		elseif ( raidMaster ) then
			masterName = "raid"..raidMaster;
		end
		if ( dropdownFrame.unit and UnitIsUnit(dropdownFrame.unit, masterName) ) then
			return false; 
		end
	end
	return true; 
end

function UnitPopupLootPromoteButtonMixin:OnClick()
	SetLootMethod("master", UnitPopupSharedUtil.GetFullPlayerName(), 2);
end

function UnitPopupRafGrantLevelButtonMixin:GetText()
	return RAF_GRANT_LEVEL;
end 

function UnitPopupRafGrantLevelButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	return IsReferAFriendLinked(dropdownMenu.unit)
end

function UnitPopupRafGrantLevelButtonMixin:IsEnabled()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	return CanGrantLevel(dropdownMenu.unit)
end

function UnitPopupRafGrantLevelButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local isAlliedRace = UnitAlliedRaceInfo(dropdownMenu.unit);
	if (isAlliedRace) then
		StaticPopup_Show("RAF_GRANT_LEVEL_ALLIED_RACE", nil, nil, dropdownMenu.unit);
	else
		GrantLevel(dropdownMenu.unit);
	end
end 
--------------------------- UnitPopup Button Overrides ------------------------------------------


function UnitPopupRaidDifficultyButtonMixin:GetButtons()
	return { 
		UnitPopupRaidDifficulty1ButtonMixin,
		UnitPopupRaidDifficulty2ButtonMixin, 
		--UnitPopupRaidDifficulty3ButtonMixin, 
		--UnitPopupRaidDifficulty4ButtonMixin,
	}
end 

function UnitPopupRaidDifficulty1ButtonMixin:GetText()
	return RAID_DIFFICULTY1; 
end

function UnitPopupRaidDifficulty1ButtonMixin:IsChecked()
	if ( self:GetDifficultyID() == GetRaidDifficultyID() ) then
		return true;
	end
	return false; 
end

function UnitPopupRaidDifficulty1ButtonMixin:IsDisabled()
	local inInstance, instanceType = IsInInstance();
	if ( ( IsInGroup() and not UnitIsGroupLeader("player") ) or IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or inInstance ) then
		return true;
	end
	
	local toggleDifficultyID;
	local _, instanceType, instanceDifficultyID = GetInstanceInfo();
	if ( isDynamicInstance and CanChangePlayerDifficulty() ) then
		_, _, _, _, _, _, toggleDifficultyID = GetDifficultyInfo(instanceDifficultyID);
	end

	if ( toggleDifficultyID and CheckToggleDifficulty(toggleDifficultyID, self:GetDifficultyID()) ) then
		return nil;
	end
end	

function UnitPopupRaidDifficulty1ButtonMixin:IsEnabled()
	local inInstance, instanceType = IsInInstance();
	local isPublicParty = IsInGroup(LE_PARTY_CATEGORY_INSTANCE); 
	if( isPublicParty or (inInstance and instanceType ~= "raid") ) then
		return false;
	end
	if ( ( IsInGroup() and not UnitIsGroupLeader("player") ) or isPublicParty or inInstance ) then
		return false;
	end

	local toggleDifficultyID;
	local _, _, instanceDifficultyID, _, _, _, isDynamicInstance = GetInstanceInfo();
	if ( isDynamicInstance and CanChangePlayerDifficulty() ) then
		_, _, _, _, _, _, toggleDifficultyID = GetDifficultyInfo(instanceDifficultyID);
	end

	if (toggleDifficultyID) then
		if(not CheckToggleDifficulty(toggleDifficultyID, self:GetDifficultyID())) then 
			return false; 
		end 
	end

	if (self:GetDifficultyID() == DIFFICULTY_PRIMARYRAID_MYTHIC and UnitLevel("player") < MAX_PLAYER_LEVEL_TABLE[LE_EXPANSION_MISTS_OF_PANDARIA]) then
		return false;
	end
	return true; 
end

function UnitPopupRaidDifficultyButtonMixin:CanShow()
	if ((UnitLevel("player") < 65 and GetDungeonDifficultyID() == 1 )) then
		return false
	end
	return true; 
end

function UnitPopupRaidDifficulty1ButtonMixin:GetDifficultyID()
	return DIFFICULTY_RAID10_NORMAL;
end 

function UnitPopupRaidDifficulty1ButtonMixin:OnClick()
	local raidDifficultyID = self:GetDifficultyID();
	SetRaidDifficultyID(raidDifficultyID);
end

UnitPopupRaidDifficulty2ButtonMixin = CreateFromMixins(UnitPopupRaidDifficulty1ButtonMixin);
function UnitPopupRaidDifficulty2ButtonMixin:GetText()
	return RAID_DIFFICULTY2; 
end 

function UnitPopupRaidDifficulty2ButtonMixin:GetDifficultyID()
	return DIFFICULTY_RAID25_NORMAL;
end



function UnitPopupInviteButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu()
	if ( UnitPopupSharedUtil.GetIsLocalPlayer() or UnitPopupSharedUtil.IsPlayerOffline() ) then
		return false;
	elseif ( dropdownMenu.unit ) then
		if ( not UnitPopupSharedUtil.CanCooperate() or UnitIsUnit("player", dropdownMenu.unit) ) then
			return false;
		end
	elseif ( (dropdownMenu == ChannelRosterDropDown) ) then
		if ( UnitInRaid(dropdownMenu.name) ~= nil ) then
			return false;
		end
	elseif ( dropdownMenu == FriendsDropDown and dropdownMenu.isMobile ) then
		return false;
	elseif ( dropdownMenu == GuildMenuDropDown and dropdownMenu.isMobile ) then 
		return false; 
	else
		if ( dropdownMenu.name == UnitName("party1") or
				dropdownMenu.name == UnitName("party2") or
				dropdownMenu.name == UnitName("party3") or
				dropdownMenu.name == UnitName("party4") or
				dropdownMenu.name == UnitName("player")) then
			return false
		end
	end

	local displayedInvite = GetDisplayedInviteType(UnitPopupSharedUtil.GetGUID());
	if ( self:GetButtonName() ~= displayedInvite ) then
		return false;
	end
	return true;
end	

function UnitPopupAddGuildBtagFriendButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if ( not UnitPopupSharedUtil.CanAddBNetFriend(dropdownMenu, UnitPopupSharedUtil.GetIsLocalPlayer(dropdownMenu), UnitPopupSharedUtil.HasBattleTag(), UnitPopupSharedUtil.IsPlayer(dropdownMenu))) then
		return false; 
	end
	return true; 
end

function UnitPopupBnetInviteButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local bnetIDAccount, accountName, battleTag, isBattleTag, characterName, bnetIDGameAccount = BNGetFriendInfoByID(dropdownMenu.bnetIDAccount);
	if not bnetIDGameAccount then
		return false;
	else
		local guid = select(20, BNGetGameAccountInfo(bnetIDGameAccount));
		local inviteType = GetDisplayedInviteType(guid);
		if (self:GetButtonName() ~= "BN_"..inviteType) then
			return false; 
		elseif ( not dropdownMenu.bnetIDAccount or not BNFeaturesEnabledAndConnected() ) then
			return false; 
		elseif UnitPopupSharedUtil.IsInGroupWithPlayer() then
			return false; 
		end
	end
	return true; 
end	

function UnitPopupCommunitiesLeaveButtonMixin:GetText()
	return COMMUNITIES_LIST_DROP_DOWN_LEAVE_COMMUNITY; 
end

function UnitPopupWhisperButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local whisperIsLocalPlayer =  UnitPopupSharedUtil.GetIsLocalPlayer();
	local isOffline = UnitPopupSharedUtil.IsPlayerOffline(dropdownMenu);
	local canCoop = UnitPopupSharedUtil.CanCooperate(dropdownMenu);
	local isPlayer = UnitPopupSharedUtil.IsPlayer(dropdownMenu);
	local isBNFriend = UnitPopupSharedUtil.IsBNetFriend(dropdownMenu);
	if not whisperIsLocalPlayer then
		local playerName, playerServer = UnitName("player");
		whisperIsLocalPlayer = (dropdownMenu.name == playerName and dropdownMenu.server == playerServer);
	end
	if whisperIsLocalPlayer or (isOffline and not dropdownMenu.bnetIDAccount) or ( dropdownMenu.unit and (not canCoop or not isPlayer)) or (dropdownMenu.bnetIDAccount and not isBNFriend) then
		return false;
	end
	return true; 
end	

function UnitPopupPetBattleDuelButtonMixin:CanShow()
	return false; 
end

function UnitPopupPvpReportAfkButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local inBattleground = UnitInBattleground("player");


	if ( not inBattleground or GetCVar("enablePVPNotifyAFK") == "0" ) then
		return false; 
	elseif ( dropdownMenu.unit ) then
		if ( UnitIsUnit(dropdownMenu.unit,"player") ) then
			return false; 
		elseif ( not UnitInBattleground(dropdownMenu.unit) and not IsInActiveWorldPVP(dropdownMenu.unit) ) then
			return false; 
		end
	elseif ( dropdownMenu.name ) then
		if ( dropdownMenu.name == UnitName("player") ) then
			return false; 
		elseif ( not UnitInBattleground(dropdownMenu.name) ) then
			return false; 
		end
	end

	return true;
end	

function UnitPopupRafSummonButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if( not IsReferAFriendLinked(dropdownMenu.unit) ) then
		return false; 
	end
	return true;
end	

function UnitPopupRafSummonButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu()
	SummonFriend(dropdownMenu.unit); 
end

function UnitPopupBnetTargetButtonMixin:IsEnabled()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if ( not dropdownMenu.bnetIDAccount) then
		enable = false;
	else
		if not dropdownMenu.accountInfo or (dropdownMenu.accountInfo.gameAccountInfo.clientProgram ~= BNET_CLIENT_WOW) or (dropdownMenu.accountInfo.gameAccountInfo.wowProjectID ~= WOW_PROJECT_ID) then
			enable = false;
		end
	end
end 

function UnitPopupVoteToKickButtonMixin:CanShow()
	return false; 
end

function UnitPopupDungeonDifficultyButtonMixin:CanShow()
	if ((UnitLevel("player") < 65 and GetDungeonDifficultyID() == 1 )) then
		return false
	end
	return true; 
end

function UnitPopupDungeonDifficultyButtonMixin:GetButtons()
	return { 
		UnitPopupDungeonDifficulty1ButtonMixin, 
		UnitPopupDungeonDifficulty2ButtonMixin,
	}
end 

function UnitPopupAchievementButtonMixin:GetText()
	return COMPARE_ACHIEVEMENTS; 
end 

function UnitPopupAchievementButtonMixin:GetInteractDistance()
	return 1; 
end

function UnitPopupAchievementButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	return (dropdownMenu.unit and not UnitCanAttack("player", dropdownMenu.unit) and UnitPopupSharedUtil.IsPlayer(dropdownMenu));
end		

function UnitPopupAchievementButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	InspectAchievements(dropdownMenu.unit);
end

function UnitPopupPartyInstanceLeaveButtonMixin:CanShow()
	return false; 
end

function UnitPopupConvertToRaidButtonMixin:OnClick()
	ConvertToRaid();
end

function UnitPopupConvertToPartyButtonMixin:OnClick()
	ConvertToParty();
end

function UnitPopupPartyLeaveButtonMixin:OnClick()
	LeaveParty();
end
