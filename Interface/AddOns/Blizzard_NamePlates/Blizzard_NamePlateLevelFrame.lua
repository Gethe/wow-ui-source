NameplateLevelFrameMixin = {};

function NameplateLevelFrameMixin:ShouldDisplay(unit)
	if not unit then
		return false;
	end

	local isActivePlayer = UnitIsUnit(unit, "player");
	return C_GameRules.IsGameRuleActive(Enum.GameRule.PlayerNameplateDifficultyIcon)
		and UnitIsPlayer(unit)
		and not isActivePlayer
		and not UnitInParty(unit);
end

function NameplateLevelFrameMixin:GetDifficultyColor(playerTargetLevelDiff)
	if (playerTargetLevelDiff <= -2) then
		return EASY_DIFFICULTY_COLOR;
	elseif (playerTargetLevelDiff <= 1) then
		return FAIR_DIFFICULTY_COLOR;
	elseif (playerTargetLevelDiff <= 3) then
		return DIFFICULT_DIFFICULTY_COLOR;
	else
		return IMPOSSIBLE_DIFFICULTY_COLOR;
	end
end

function NameplateLevelFrameMixin:SetIsTarget(isTarget)
	-- Functionality unused in base version, stubbing for shared callsite
end

function NameplateLevelFrameMixin:SetIsFocus(isFocus)
	-- Functionality unused in base version, stubbing for shared callsite
end
