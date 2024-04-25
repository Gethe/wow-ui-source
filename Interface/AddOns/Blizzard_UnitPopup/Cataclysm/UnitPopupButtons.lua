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

function UnitPopupLootThresholdButtonMixin:GetColor()
	return ITEM_QUALITY_COLORS[GetLootThreshold()].color; 
end

--------------------------- UnitPopup Button Overrides ------------------------------------------
function UnitPopupRaidDifficultyButtonMixin:GetButtons()
	return { 
		UnitPopupRaidDifficulty1ButtonMixin,
		UnitPopupRaidDifficulty2ButtonMixin, 
		UnitPopupRaidDifficulty3ButtonMixin, 
		UnitPopupRaidDifficulty4ButtonMixin,
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

UnitPopupRaidDifficulty3ButtonMixin = CreateFromMixins(UnitPopupRaidDifficulty1ButtonMixin);
function UnitPopupRaidDifficulty3ButtonMixin:GetText()
	return RAID_DIFFICULTY3; 
end 

function UnitPopupRaidDifficulty3ButtonMixin:GetDifficultyID()
	return DIFFICULTY_RAID10_HEROIC;
end

UnitPopupRaidDifficulty4ButtonMixin = CreateFromMixins(UnitPopupRaidDifficulty1ButtonMixin);
function UnitPopupRaidDifficulty4ButtonMixin:GetText()
	return RAID_DIFFICULTY4; 
end 

function UnitPopupRaidDifficulty4ButtonMixin:GetDifficultyID()
	return DIFFICULTY_RAID25_HEROIC;
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

function UnitPopupDungeonDifficultyButtonMixin:CanShow()
	if ((UnitLevel("player") < 70 and GetDungeonDifficultyID() == 1 )) then
		return false
	end
	return true; 
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

function UnitPopupSelectRoleButtonMixin:CanShow()
	local isEnabled = CanShowSetRoleButton();
	if ( not isEnabled ) then
		return false;
	end

	local dropdownMenu = UnitPopupSharedUtil.GetCurrentDropdownMenu(); 
	local isLeader = UnitIsGroupLeader("player");
	local isAssistant = UnitIsGroupAssistant("player");
	if ( not ( IsInGroup() and (isLeader or isAssistant or UnitIsUnit(dropdownMenu.unit, "player")) ) ) then
		return false; 
	end
	return true; 
end
