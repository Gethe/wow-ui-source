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
function UnitPopupRaidDifficulty1ButtonMixin:IsChecked()
	local _, instanceType, instanceDifficultyID, _, _, _, isDynamicInstance = GetInstanceInfo();
	if ( isDynamicInstance ) then
		local difficulty = self:GetDifficultyID();
		if ( IsLegacyDifficulty(instanceDifficultyID) ) then
			if ((instanceDifficultyID == DIFFICULTY_RAID10_NORMAL or instanceDifficultyID == DIFFICULTY_RAID25_NORMAL) and difficulty == DIFFICULTY_PRIMARYRAID_NORMAL) then
				return true;
			elseif ((instanceDifficultyID == DIFFICULTY_RAID10_HEROIC or instanceDifficultyID == DIFFICULTY_RAID25_HEROIC) and difficulty == DIFFICULTY_PRIMARYRAID_HEROIC) then
				return true;
			end
		elseif ( instanceDifficultyID == difficulty ) then
			return true;
		end
	else
		if ( difficulty == self:GetDifficultyID() ) then
			return true;
		end
	end
	return false; 
end

function UnitPopupRaidDifficultyButtonMixin:CanShow()
	return false;
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

function UnitPopupDungeonDifficultyButtonMixin:CanShow()
	if ( GetClassicExpansionLevel() < LE_EXPANSION_BURNING_CRUSADE or (UnitLevel("player") < 70 and GetDungeonDifficultyID() == 1 )) then
		return false
	end
	return true; 
end

function UnitPopupAchievementButtonMixin:CanShow()
	return false; 
end