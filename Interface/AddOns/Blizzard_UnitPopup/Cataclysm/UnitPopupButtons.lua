UnitPopupTeamPromoteButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);

function UnitPopupTeamPromoteButtonMixin:GetText(contextData)
	return TEAM_PROMOTE; 
end

function UnitPopupTeamPromoteButtonMixin:GetInteractDistance()
	return 0; 
end

function UnitPopupTeamPromoteButtonMixin:CanShow(contextData)
	if not PVPTeamDetails:IsShown() then
		return false;
	end

	if contextData.name == UnitName("player") then
		return false;
	end

	return IsArenaTeamCaptain(PVPTeamDetails.team);
end

function UnitPopupTeamPromoteButtonMixin:OnClick(contextData)
	local name = contextData.name;
	local team = PVPTeamDetails.team;
	local arenaName, teamIndex = GetArenaTeam(team);
	local dialog = StaticPopup_Show("CONFIRM_TEAM_PROMOTE", name, arenaName, teamIndex);
	if dialog then
		dialog.data = team;
		dialog.data2 = name;
	end
end

UnitPopupTeamKickButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);

function UnitPopupTeamKickButtonMixin:GetText(contextData)
	return TEAM_KICK; 
end

function UnitPopupTeamKickButtonMixin:GetInteractDistance()
	return 0; 
end

function UnitPopupTeamKickButtonMixin:CanShow(contextData)
	if not PVPTeamDetails:IsShown() then
		return false;
	end

	if contextData.name == UnitName("player") then
		return false; 
	end

	return IsArenaTeamCaptain(PVPTeamDetails.team);
end

function UnitPopupTeamKickButtonMixin:OnClick(contextData)
	local name = contextData.name;
	local team = PVPTeamDetails.team;
	local arenaName, teamIndex = GetArenaTeam(team);
	local dialog = StaticPopup_Show("CONFIRM_TEAM_KICK", name, arenaName, teamIndex );
	if dialog then
		dialog.data = team;
		dialog.data2 = name;
	end
end

UnitPopupTeamLeaveButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);

function UnitPopupTeamLeaveButtonMixin:GetText(contextData)
	return TEAM_LEAVE; 
end

function UnitPopupTeamLeaveButtonMixin:GetInteractDistance()
	return 0; 
end

function UnitPopupTeamLeaveButtonMixin:CanShow(contextData)
	if not PVPTeamDetails:IsShown() then
		return;
	end

	return contextData.name == UnitName("player");
end

function UnitPopupTeamLeaveButtonMixin:OnClick(contextData)
	local team = PVPTeamDetails.team;
	local arenaName = GetArenaTeam(team);
	local dialog = StaticPopup_Show("CONFIRM_TEAM_LEAVE", arenaName);
	if dialog then
		dialog.data = team;
	end
end

UnitPopupTeamDisbandButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);

function UnitPopupTeamDisbandButtonMixin:GetText(contextData)
	return TEAM_DISBAND; 
end

function UnitPopupTeamDisbandButtonMixin:GetInteractDistance()
	return 0; 
end

function UnitPopupTeamDisbandButtonMixin:CanShow(contextData)
	if PVPTeamDetails:IsShown() then
		if not IsArenaTeamCaptain(PVPTeamDetails.team) then
			return false;
		end

		if contextData.name ~= UnitName("player") then
			return false;
		end
	end

	return true;
end

function UnitPopupTeamDisbandButtonMixin:OnClick(contextData)
	local team = PVPTeamDetails.team;
	local arenaName = GetArenaTeam(team);
	local dialog = StaticPopup_Show("CONFIRM_TEAM_DISBAND", arenaName);
	if dialog then
		dialog.data = team;
	end
end

function UnitPopupLootThresholdButtonMixin:GetColor()
	local color = ITEM_QUALITY_COLORS[GetLootThreshold()].color;
	return color.r, color.g, color.b;
end

-- Overrides
function UnitPopupRaidDifficultyButtonMixin:GetEntries()
	return { 
		UnitPopupRaidDifficulty1ButtonMixin,
		UnitPopupRaidDifficulty2ButtonMixin, 
		UnitPopupRaidDifficulty3ButtonMixin, 
		UnitPopupRaidDifficulty4ButtonMixin,
	}
end 

function UnitPopupRaidDifficulty1ButtonMixin:GetText(contextData)
	return RAID_DIFFICULTY1; 
end

function UnitPopupRaidDifficulty1ButtonMixin:IsChecked()
	return self:GetDifficultyID() == GetRaidDifficultyID();
end

function UnitPopupRaidDifficultyButtonMixin:CanShow(contextData)
	return not (UnitLevel("player") < 65 and GetDungeonDifficultyID() == 1);
end

function UnitPopupRaidDifficulty1ButtonMixin:GetDifficultyID()
	return DIFFICULTY_RAID10_NORMAL;
end 

function UnitPopupRaidDifficulty1ButtonMixin:OnClick(contextData)
	local raidDifficultyID = self:GetDifficultyID();
	SetRaidDifficultyID(raidDifficultyID);
end

UnitPopupRaidDifficulty2ButtonMixin = CreateFromMixins(UnitPopupRaidDifficulty1ButtonMixin);

function UnitPopupRaidDifficulty2ButtonMixin:GetText(contextData)
	return RAID_DIFFICULTY2; 
end 

function UnitPopupRaidDifficulty2ButtonMixin:GetDifficultyID()
	return DIFFICULTY_RAID25_NORMAL;
end

UnitPopupRaidDifficulty3ButtonMixin = CreateFromMixins(UnitPopupRaidDifficulty1ButtonMixin);

function UnitPopupRaidDifficulty3ButtonMixin:GetText(contextData)
	return RAID_DIFFICULTY3; 
end 

function UnitPopupRaidDifficulty3ButtonMixin:GetDifficultyID()
	return DIFFICULTY_RAID10_HEROIC;
end

UnitPopupRaidDifficulty4ButtonMixin = CreateFromMixins(UnitPopupRaidDifficulty1ButtonMixin);

function UnitPopupRaidDifficulty4ButtonMixin:GetText(contextData)
	return RAID_DIFFICULTY4; 
end 

function UnitPopupRaidDifficulty4ButtonMixin:GetDifficultyID()
	return DIFFICULTY_RAID25_HEROIC;
end

function UnitPopupInviteButtonMixin:CanShow(contextData)
	if UnitPopupSharedUtil.GetIsLocalPlayer(contextData) then
		return false;
	end
	
	if UnitPopupSharedUtil.IsPlayerOffline(contextData) then
		return false;
	end

	local unit = contextData.unit;
	if unit then
		if not UnitPopupSharedUtil.CanCooperate(contextData) then
			return false;
		end
		
		if UnitIsUnit("player", unit) then
			return false;
		end
	elseif contextData.fromRosterFrame then
		if UnitInRaid(contextData.name) ~= nil then
			return false;
		end
	elseif contextData.fromFriendFrame and contextData.isMobile then
		return false;
	else
		local name = contextData.name;
		if name == UnitName("party1") or
			name == UnitName("party2") or
			name == UnitName("party3") or
			name == UnitName("party4") or
			name == UnitName("player") then
			return false;
		end
	end

	local displayedInvite;
	if unit and (not IsInGroup()) and UnitInAnyGroup(unit, LE_PARTY_CATEGORY_HOME) then
		--Handle the case where we don't have SocialQueue data about this unit (e.g. because it's a random person)
		--in the world. In this case, we want to display REQUEST_INVITE if they're in a group.
		displayedInvite = "REQUEST_INVITE";
	else
		displayedInvite = GetDisplayedInviteType(UnitPopupSharedUtil.GetGUID(contextData));
	end

	return self:GetInviteName() == displayedInvite;
end

function UnitPopupDungeonDifficultyButtonMixin:CanShow(contextData)
	return not (UnitLevel("player") < 70 and GetDungeonDifficultyID() == 1);
end

function UnitPopupAchievementButtonMixin:GetText(contextData)
	return COMPARE_ACHIEVEMENTS; 
end 

function UnitPopupAchievementButtonMixin:GetInteractDistance()
	return 1; 
end

function UnitPopupAchievementButtonMixin:CanShow(contextData)
	local unit = contextData.unit;
	if not unit or UnitCanAttack("player", unit) then
		return false;
	end

	if not UnitPopupSharedUtil.IsPlayer(contextData) then
		return false;
	end

	return true;
end		

function UnitPopupAchievementButtonMixin:OnClick(contextData)
	InspectAchievements(contextData.unit);
end

function UnitPopupSelectRoleButtonMixin:CanShow(contextData)
	if not CanShowSetRoleButton() then
		return false;
	end

	if not IsInGroup() then
		return false;
	end

	return UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") or UnitIsUnit(contextData.unit, "player"); 
end