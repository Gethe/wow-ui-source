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
