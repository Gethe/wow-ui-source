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
	local dialog = StaticPopup_Show("CONFIRM_TEAM_KICK", name, arenaName, teamIndex);
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
	return ITEM_QUALITY_COLORS[GetLootThreshold()].color; 
end 

-- Overrides
function UnitPopupRaidDifficulty1ButtonMixin:IsChecked()
	local instanceDifficultyID, _, _, _, isDynamicInstance = select(3, GetInstanceInfo());
	if isDynamicInstance then
		local difficulty = self:GetDifficultyID();
		if IsLegacyDifficulty(instanceDifficultyID) then
			local validNormalSize = difficultyID == DIFFICULTY_RAID10_NORMAL or difficultyID == DIFFICULTY_RAID25_NORMAL;
			if validNormalSize and difficulty == DIFFICULTY_PRIMARYRAID_NORMAL then
				return true;
			end

			local validHeroicSize = difficultyID == DIFFICULTY_RAID10_HEROIC or difficultyID == DIFFICULTY_RAID25_HEROIC;
			if validHeroicSize and difficulty == DIFFICULTY_PRIMARYRAID_HEROIC then
				return true;
			end
		elseif instanceDifficultyID == difficulty then
			return true;
		end
		
		if difficulty == self:GetDifficultyID() then
			return true;
		end	
	end
	
	return false; 
end

function UnitPopupRaidDifficultyButtonMixin:CanShow(contextData)
	return false;
end

function UnitPopupInviteButtonMixin:CanShow(contextData)
	if UnitPopupSharedUtil.GetIsLocalPlayer(contextData) then
		return false;
	end
	
	if UnitPopupSharedUtil.IsPlayerOffline(contextData)then
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

	local displayedInvite = GetDisplayedInviteType(UnitPopupSharedUtil.GetGUID(contextData));
	return self:GetInviteName() == displayedInvite;
end

function UnitPopupDungeonDifficultyButtonMixin:CanShow(contextData)
	if GetClassicExpansionLevel() < LE_EXPANSION_BURNING_CRUSADE then
		return false;
	end

	return (UnitLevel("player") >= 70) and (GetDungeonDifficultyID() == 1); 
end

function UnitPopupAchievementButtonMixin:CanShow(contextData)
	return false; 
end