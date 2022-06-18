function UnitPopupLootThresholdButtonMixin:GetColor()
	return { ITEM_QUALITY_COLORS[GetLootThreshold()].r, ITEM_QUALITY_COLORS[GetLootThreshold()].g, ITEM_QUALITY_COLORS[GetLootThreshold()].b }; 
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
	if ( UnitPopupSharedUtil.GetIsLocalPlayer(dropdownMenu) or UnitPopupSharedUtil.IsPlayerOffline(dropdownMenu) ) then
		return false;
	elseif ( dropdownMenu.unit ) then
		if ( not UnitPopupSharedUtil.CanCooperate(dropdownMenu) or UnitIsUnit("player", dropdownMenu.unit) ) then
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
	if ( UnitLevel("player") < 65 and GetDungeonDifficultyID() == 1 ) then
		return false; 
	end
	return true; 
end

function UnitPopupAchievementButtonMixin:CanShow()
	return false; 
end

function UnitPopupSetFocusButtonMixin:CanShow()
	return false; 
end 