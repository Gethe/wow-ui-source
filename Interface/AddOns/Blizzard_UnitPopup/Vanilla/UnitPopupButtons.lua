function UnitPopupLootThresholdButtonMixin:GetColor()
	local color = ITEM_QUALITY_COLORS[GetLootThreshold()];
	return color.r, color.g, color.b;
end

-- Overrides
function UnitPopupRaidDifficulty1ButtonMixin:IsChecked(contextData)
	local instanceDifficultyID, _, _, _, isDynamicInstance = select(3, GetInstanceInfo());
	if isDynamicInstance then
		local difficulty = self:GetDifficultyID();
		if IsLegacyDifficulty(instanceDifficultyID) then
			local validNormalSize = instanceDifficultyID == DIFFICULTY_RAID10_NORMAL or instanceDifficultyID == DIFFICULTY_RAID25_NORMAL;
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
	return false;
end

function UnitPopupAchievementButtonMixin:CanShow(contextData)
	return false; 
end

function UnitPopupSetFocusButtonMixin:CanShow(contextData)
	return false; 
end 

UnitPopupDuelToTheDeathButtonMixin = CreateFromMixins(UnitPopupButtonBaseMixin);

function UnitPopupDuelToTheDeathButtonMixin:GetText(contextData)
	return DUEL_TO_DEATH;
end

function UnitPopupDuelToTheDeathButtonMixin:GetInteractDistance()
	return 3;
end

function UnitPopupDuelToTheDeathButtonMixin:IsDisabledInKioskMode()
	return false;
end

function UnitPopupDuelToTheDeathButtonMixin:CanShow(contextData)
	if UnitCanAttack("player", contextData.unit) then
		return false;
	end

	if not UnitPopupSharedUtil.IsPlayer(contextData) then
		return false;
	end

	return C_GameRules.IsHardcoreActive();
end

function UnitPopupDuelToTheDeathButtonMixin:OnClick(contextData)
	local fullName = UnitPopupSharedUtil.GetFullPlayerName(contextData);
	local text2 = nil;
	StaticPopup_Show("DUEL_TO_THE_DEATH_CHALLENGE_CONFIRM", fullName, text2, contextData);
end

function UnitPopupDuelToTheDeathButtonMixin:IsEnabled(contextData)
	if UnitIsDeadOrGhost("player") then
		return false;
	end

	if not HasFullControl() then
		return false;
	end

	return not UnitIsDeadOrGhost(contextData.unit);
end