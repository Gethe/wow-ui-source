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

UnitPopupBnetAddFavoriteButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupBnetAddFavoriteButtonMixin:GetText()
	return ADD_FAVORITE_STATUS; 
end 

function UnitPopupBnetAddFavoriteButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	local accountId = dropdownMenu.bnetIDAccount;
	if accountId then
		BNSetFriendFavoriteFlag(accountId, true);
	end
end

function UnitPopupBnetAddFavoriteButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if ( not dropdownMenu.friendsList or UnitPopupSharedUtil.IsPlayerFavorite(dropdownMenu)) then
		return false;
	end
	return true;
end 

UnitPopupBnetRemoveFavoriteButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupBnetRemoveFavoriteButtonMixin:GetText()
	return REMOVE_FAVORITE_STATUS; 
end 

function UnitPopupBnetRemoveFavoriteButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	local accountId = dropdownMenu.bnetIDAccount;
	if accountId then
		BNSetFriendFavoriteFlag(accountId, false);
	end
end

function UnitPopupBnetRemoveFavoriteButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if ( not dropdownMenu.friendsList or not UnitPopupSharedUtil.IsPlayerFavorite(dropdownMenu)) then
		return false;
	end
	return true;
end 

UnitPopupDungeonDifficulty3ButtonMixin = CreateFromMixins(UnitPopupDungeonDifficulty1ButtonMixin);
function UnitPopupDungeonDifficulty3ButtonMixin:GetText()
	return PLAYER_DIFFICULTY6; 
end 

function UnitPopupDungeonDifficulty3ButtonMixin:GetDifficultyID()
	return 23;
end 

UnitPopupRafRemoveRecruitButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupRafRemoveRecruitButtonMixin:GetText()
	return RAF_REMOVE_RECRUIT; 
end 

function UnitPopupRafRemoveRecruitButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if not dropdownMenu.isRafRecruit then
		return false;
	end
	return true;
end	

function UnitPopupRafRemoveRecruitButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	StaticPopup_Show("CONFIRM_RAF_REMOVE_RECRUIT", dropdownMenu.name, nil, dropdownMenu.wowAccountGUID);
end

UnitPopupSelectRoleButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupSelectRoleButtonMixin:GetText()
	return SET_ROLE; 
end 

function UnitPopupSelectRoleButtonMixin:IsNested()
	return true; 
end

function UnitPopupSelectRoleButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	local isLeader = UnitIsGroupLeader("player"); 
	local isAssistant = UnitIsGroupAssistant("player"); 
	if ( C_Scenario.IsInScenario() or not ( IsInGroup() and not HasLFGRestrictions() and (isLeader or isAssistant or UnitIsUnit(dropdownMenu.unit, "player")) ) ) then
		return false; 
	end
	return true; 
end

function UnitPopupSelectRoleButtonMixin:GetButtons()
	return { 
		UnitPopupSetRoleTankButton,
		UnitPopupSetRoleHealerButton,
		UnitPopupSetRoleDpsButton,
		UnitPopupSetRoleNoneButton,
	}
end 

UnitPopupSetRoleNoneButton = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupSetRoleNoneButton:GetText()
	return NO_ROLE; 
end 

function UnitPopupSetRoleNoneButton:IsCheckable()
	return true; 
end

function UnitPopupSetRoleNoneButton:GetRole()
	return "NONE";
end

function UnitPopupSetRoleNoneButton:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	UnitSetRole(dropdownMenu.unit, self:GetRole());
end 

function UnitPopupSetRoleNoneButton:IsChecked()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	if ( UnitGroupRolesAssigned(dropdownMenu.unit) == self:GetRole()) then
		return true
	end
end

UnitPopupSetRoleTankButton = CreateFromMixins(UnitPopupSetRoleNoneButton);
function UnitPopupSetRoleTankButton:GetText()
	return INLINE_TANK_ICON.." "..TANK; 
end 

function UnitPopupSetRoleTankButton:GetRole()
	return "TANK";
end

function UnitPopupSetRoleTankButton:IsEnabled()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	local canBeTank, canBeHealer, canBeDamager = UnitGetAvailableRoles(dropdownMenu.unit);
	return canBeTank; 
end

UnitPopupSetRoleDpsButton = CreateFromMixins(UnitPopupSetRoleNoneButton);
function UnitPopupSetRoleDpsButton:GetText()
	return INLINE_DAMAGER_ICON.." "..DAMAGER; 
end 

function UnitPopupSetRoleDpsButton:GetRole()
	return "DAMAGER";
end

function UnitPopupSetRoleDpsButton:IsEnabled()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	local canBeTank, canBeHealer, canBeDamager = UnitGetAvailableRoles(dropdownMenu.unit);
	return canBeDamager; 
end

UnitPopupSetRoleHealerButton = CreateFromMixins(UnitPopupSetRoleNoneButton);
function UnitPopupSetRoleHealerButton:GetText()
	return INLINE_HEALER_ICON.." "..HEALER; 
end 

function UnitPopupSetRoleHealerButton:GetRole()
	return "HEALER";
end

function UnitPopupSetRoleHealerButton:IsEnabled()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	local canBeTank, canBeHealer, canBeDamager = UnitGetAvailableRoles(dropdownMenu.unit);
	return canBeHealer; 
end

UnitPopupGuildSettingButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupGuildSettingButtonMixin:GetText()
	return GUILD_CONTROL_BUTTON_TEXT;
end 

function UnitPopupGuildSettingButtonMixin:OnClick()
	if ( not GuildControlUI ) then
		UIParentLoadAddOn("Blizzard_GuildControlUI");
	end

	local wasShown = GuildControlUI:IsShown();
	if not wasShown then
		ShowUIPanel(GuildControlUI);
	end
end 

function UnitPopupGuildSettingButtonMixin:CanShow()
	return IsGuildLeader();
end

UnitPopupGuildRecruitmentSettingButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupGuildRecruitmentSettingButtonMixin:GetText()
	return GUILD_RECRUITMENT;
end 

function UnitPopupGuildRecruitmentSettingButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local clubInfo = dropdownMenu.clubInfo; 
	CommunitiesFrame.RecruitmentDialog.clubId = clubInfo.clubId;
	CommunitiesFrame.RecruitmentDialog.clubName = clubInfo.name;
	CommunitiesFrame.RecruitmentDialog.clubAvatarId = clubInfo.avatarId;
	CommunitiesFrame.RecruitmentDialog:UpdatedPostingInformationInit();
end 

function UnitPopupGuildRecruitmentSettingButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if dropdownMenu.clubInfo then
		local isPostingBanned = C_ClubFinder.IsPostingBanned(dropdownMenu.clubInfo.clubId);
		if not C_ClubFinder.IsEnabled() or C_ClubFinder.GetClubFinderDisableReason() ~= nil or (not IsGuildLeader() and not C_GuildInfo.IsGuildOfficer()) or isPostingBanned then
			return false;
		end
	else
		return false;
	end
end

UnitPopupGuildInviteButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);
function UnitPopupGuildInviteButtonMixin:GetText()
	return COMMUNITIES_LIST_DROP_DOWN_INVITE;
end 

function UnitPopupGuildInviteButtonMixin:OnClick()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local streams = C_Club.GetStreams(dropdownMenu.clubInfo.clubId);
	local defaultStreamId = #streams > 0 and streams[1] or nil;
	for i, stream in ipairs(streams) do
		if stream.streamType == Enum.ClubStreamType.General or stream.streamType == Enum.ClubStreamType.Guild then
			defaultStreamId = stream.streamId;
			break;
		end
	end

	if defaultStreamId then
		CommunitiesUtil.OpenInviteDialog(dropdownMenu.clubInfo.clubId, defaultStreamId);
	end
end 

function UnitPopupGuildInviteButtonMixin:CanShow()
	return CanGuildInvite();
end 

--------------------------- Unitpop Button Overrides ------------------------------------------
function UnitPopupRaidDifficulty1ButtonMixin:IsChecked()
	local _, instanceType, instanceDifficultyID, _, _, _, isDynamicInstance = GetInstanceInfo();
	if ( isDynamicInstance ) then
		if ( IsLegacyDifficulty(instanceDifficultyID) ) then
			if ((instanceDifficultyID == DifficultyUtil.ID.Raid10Normal or instanceDifficultyID == DifficultyUtil.ID.Raid25Normal) and self:GetDifficultyID() == DifficultyUtil.ID.PrimaryRaidNormal) then
				return true;
			elseif ((instanceDifficultyID == DifficultyUtil.ID.Raid10Heroic or instanceDifficultyID == DifficultyUtil.ID.Raid25Heroic) and self:GetDifficultyID() == DifficultyUtil.ID.PrimaryRaidHeroic) then
				return true;
			end
		elseif ( instanceDifficultyID == self:GetDifficultyID() ) then
			return true;
		end
	else
		local raidDifficultyID = GetRaidDifficultyID();
		if ( raidDifficultyID == self:GetDifficultyID() ) then
			return true;
		end
	end
	return false; 
end

function UnitPopupRaidDifficulty1ButtonMixin:IsDisabled()
	local inInstance, instanceType = IsInInstance();
	if ( ( IsInGroup() and not UnitIsGroupLeader("player") ) or IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or inInstance ) then
		return true; 
	end
	
	local toggleDifficultyID;
	local _, instanceType, instanceDifficultyID, _, _, _, isDynamicInstance = GetInstanceInfo();
	if ( isDynamicInstance and CanChangePlayerDifficulty() ) then
		_, _, _, _, _, _, toggleDifficultyID = GetDifficultyInfo(instanceDifficultyID);
	end

	if (toggleDifficultyID) then
		return CheckToggleDifficulty(toggleDifficultyID, self:GetDifficultyID());
	end
	return false;
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
		return CheckToggleDifficulty(toggleDifficultyID, self:GetDifficultyID());
	end
	return true; 
end

function UnitPopupAddFriendButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if ( UnitPopupSharedUtil.HasBattleTag() or not UnitPopupSharedUtil.CanCooperate() or not UnitPopupSharedUtil.IsPlayer() or not UnitPopupSharedUtil.IsSameServerFromSelf() or C_FriendList.GetFriendInfo(UnitNameUnmodified(dropdownMenu.unit)) ) then
		return false
	end
	return true; 
end

function UnitPopupAddFriendMenuButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local hasClubInfo = dropdownMenu.clubInfo ~= nil and dropdownMenu.clubMemberInfo ~= nil;
	if (  UnitPopupSharedUtil.GetIsLocalPlayer() or not UnitPopupSharedUtil.HasBattleTag() or (not UnitPopupSharedUtil.IsPlayer() and not hasClubInfo and not dropdownMenu.isRafRecruit) ) then
		return false;
	end
	return true; 
end

function UnitPopupInviteButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu()
	if ( UnitPopupSharedUtil.GetIsLocalPlayer(dropdownMenu) or UnitPopupSharedUtil.IsPlayerOffline(dropdownMenu) ) then
		return false;
	elseif ( dropdownMenu.unit ) then
		if ( not UnitPopupSharedUtil.CanCooperate(dropdownMenu)  or UnitIsUnit("player", dropdownMenu.unit) ) then
			return false;
		end
	elseif ( (dropdownMenu == ChannelRosterDropDown) ) then
		if ( UnitInRaid(dropdownMenu.name) ~= nil ) then
			return false;
		end
	elseif ( dropdownMenu.isMobile ) then
		return false;
	end

	local displayedInvite = GetDisplayedInviteType(UnitPopupSharedUtil.GetGUID(dropdownMenu));
	local inParty = IsInGroup();
	if ( not inParty and dropdownMenu.unit and UnitInAnyGroup(dropdownMenu.unit, LE_PARTY_CATEGORY_HOME) ) then
		--Handle the case where we don't have SocialQueue data about this unit (e.g. because it's a random person)
		--in the world. In this case, we want to display REQUEST_INVITE if they're in a group.
		displayedInvite = "REQUEST_INVITE";
	end
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
	if not dropdownMenu.accountInfo or not dropdownMenu.accountInfo.gameAccountInfo.playerGuid then
		return false; 
	else
		local inviteType = GetDisplayedInviteType(dropdownMenu.accountInfo.gameAccountInfo.playerGuid);
		if self:GetButtonName() ~= "BN_"..inviteType then
			return false; 
		elseif not dropdownMenu.bnetIDAccount or not BNFeaturesEnabledAndConnected() then
			return false; 
		elseif dropdownMenu.isMobile then
			return false; 
		end
	end
	return true; 
end	

function UnitPopupCommunitiesLeaveButtonMixin:GetText()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	return dropdownMenu.clubInfo.clubType == Enum.ClubType.Character and COMMUNITIES_LIST_DROP_DOWN_LEAVE_CHARACTER_COMMUNITY or COMMUNITIES_LIST_DROP_DOWN_LEAVE_COMMUNITY;
end

function UnitPopupWhisperButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local whisperIsLocalPlayer = UnitPopupSharedUtil.GetIsLocalPlayer(dropdownMenu);
	local isOffline = UnitPopupSharedUtil.IsPlayerOffline(dropdownMenu);
	local canCoop = UnitPopupSharedUtil.CanCooperate(dropdownMenu);
	local isPlayer = UnitPopupSharedUtil.IsPlayer(dropdownMenu);
	local isBNFriend = UnitPopupSharedUtil.IsBNetFriend(dropdownMenu);

	if not whisperIsLocalPlayer then
		local playerName, playerServer = UnitNameUnmodified("player");
		whisperIsLocalPlayer = (dropdownMenu.name == playerName and dropdownMenu.server == playerServer);
	end

	if whisperIsLocalPlayer or (isOffline and not dropdownMenu.bnetIDAccount) or ( dropdownMenu.unit and (not canCoop or not isPlayer)) or (dropdownMenu.bnetIDAccount and not isBNFriend) then
		return false;
	end

	if ( dropdownMenu.isMobile ) then
		return false;
	end
	return true; 
end	

function UnitPopupPvpReportAfkButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local inBattleground = UnitInBattleground("player");

	if ( C_PvP.IsRatedMap() or  (not IsInActiveWorldPVP() and (not inBattleground or GetCVar("enablePVPNotifyAFK") == "0") ) ) then
		return false; 
	elseif ( dropdownMenu.unit ) then
		if ( UnitIsUnit(dropdownMenu.unit,"player") ) then
			return false; 
		elseif ( not UnitInBattleground(dropdownMenu.unit) and not IsInActiveWorldPVP(dropdownMenu.unit) ) then
			return false; 
		end
	elseif ( dropdownMenu.name ) then
		if ( dropdownMenu.name == UnitNameUnmodified("player") ) then
			return false; 
		elseif ( not UnitInBattleground(dropdownMenu.name) and not IsInActiveWorldPVP(dropdownMenu.name) ) then
			return false; 
		end
	end

	return true;
end	

function UnitPopupRafSummonButtonMixin:CanShow()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	local guid = UnitPopupSharedUtil.GetGUID();
	if not guid or dropdownMenu.isMobile or not IsRecruitAFriendLinked(guid) then
		return false;
	end
	return true;
end	

function UnitPopupRafSummonButtonMixin:OnClick()
	SummonFriend(UnitPopupSharedUtil.GetGUID(), UnitPopupSharedUtil.GetFullPlayerName());
end

function UnitPopupBnetTargetButtonMixin:IsEnabled()
	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu();
	if ( not dropdownMenu.bnetIDAccount) then
		return false; 
	else
		if not dropdownMenu.accountInfo or (dropdownMenu.accountInfo.gameAccountInfo.clientProgram ~= BNET_CLIENT_WOW) or (dropdownMenu.accountInfo.gameAccountInfo.wowProjectID ~= WOW_PROJECT_ID) then
			return false; 
		end
	end
	return true; 
end 

function UnitPopupVoteToKickButtonMixin:IsEnabled()
	if (not IsInGroup() or not HasLFGRestrictions()) then
		return false;
	end
	return true; 
end

function UnitPopupDungeonDifficultyButtonMixin:GetButtons()
	return { 
		UnitPopupDungeonDifficulty1ButtonMixin, 
		UnitPopupDungeonDifficulty2ButtonMixin,
		UnitPopupDungeonDifficulty3ButtonMixin,
	}
end 

function UnitPopupPartyInstanceLeaveButtonMixin:CanShow()
	local partyLFGSlot = GetPartyLFGID();
	local partyLFGCategory = UnitPopupSharedUtil.GetLFGCategoryForLFGSlot(partyLFGSlot);
	local _, instanceType = IsInInstance();
	if ( not IsInGroup() or not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or IsPartyWorldPVP() or instanceType == "pvp" or instanceType == "arena" or partyLFGCategory == LE_LFG_CATEGORY_WORLDPVP) then
		return false;
	end
	return true;
end

function UnitPopupPvpFlagButtonMixin:IsEnabled()
	if UnitPopupSharedUtil.IsInWarModeState() then
		return false;
	end
	return true; 
end

function UnitPopupPvpFlagButtonMixin:TooltipTitle()
	if UnitPopupSharedUtil.IsInWarModeState() then
		return PVP_LABEL_WAR_MODE;
	end
	return nil
end 

function UnitPopupPvpFlagButtonMixin:TooltipInstruction()
	if UnitPopupSharedUtil.IsInWarModeState() then
		return PVP_WAR_MODE_ENABLED;
	end
	return nil
end 

function UnitPopupPvpFlagButtonMixin:TooltipWarning()
	if UnitPopupSharedUtil.IsInWarModeState()then
		return UnitFactionGroup("player") == PLAYER_FACTION_GROUP[0] and PVP_WAR_MODE_NOT_NOW_HORDE or PVP_WAR_MODE_NOT_NOW_ALLIANCE;
	end
	return nil
end	

function UnitPopupPvpFlagButtonMixin:HasArrow()
	if UnitPopupSharedUtil.IsInWarModeState() then
		return nil;
	end 
	return true; 
end 

function UnitPopupConvertToRaidButtonMixin:OnClick()
	C_PartyInfo.ConvertToRaid();
end

function UnitPopupConvertToPartyButtonMixin:OnClick()
	C_PartyInfo.ConvertToParty();
end

function UnitPopupPartyLeaveButtonMixin:OnClick()
	C_PartyInfo.LeaveParty();
end

function UnitPopupGarrisonVisitButtonMixin:CanShow()
	return C_Garrison.IsVisitGarrisonAvailable() and (not C_PartyInfo.IsCrossFactionParty());
end