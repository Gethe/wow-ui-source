NameplateLevelFrameMixin = {};

function NameplateLevelFrameMixin:ShouldDisplay(unit)
	if not unit then
		return false;
	end

	if UnitIsGameObject(unit) then
		return false;
	end

	if UnitIsFriend("player", unit) and UnitIsPlayer(unit) and CVarCallbackRegistry:GetCVarValueBool(NamePlateConstants.SHOW_ONLY_NAME_FOR_FRIENDLY_PLAYER_UNITS_CVAR) then
		return false;
	end

	return true;
end

function NameplateLevelFrameMixin:GetDifficultyColor(playerTargetLevelDiff)
	local trivialRange = C_QuestLog.GetTrivialRange();

	if (playerTargetLevelDiff < -trivialRange) then
		return TRIVIAL_DIFFICULTY_COLOR;
	elseif (playerTargetLevelDiff <= -3) then
		return EASY_DIFFICULTY_COLOR;
	elseif (playerTargetLevelDiff <= 2) then
		return FAIR_DIFFICULTY_COLOR;
	elseif (playerTargetLevelDiff <= 4) then
		return DIFFICULT_DIFFICULTY_COLOR;
	else
		return IMPOSSIBLE_DIFFICULTY_COLOR;
	end
end

function NameplateLevelFrameMixin:IsTarget()
	return self.isTarget;
end

function NameplateLevelFrameMixin:SetIsTarget(isTarget)
	self.isTarget = isTarget;

	self:UpdateSelectionBorder();
end

function NameplateLevelFrameMixin:IsFocus()
	return self.isFocus;
end

function NameplateLevelFrameMixin:SetIsFocus(isFocus)
	self.isFocus = isFocus;

	self:UpdateSelectionBorder();
end

function NameplateLevelFrameMixin:UpdateSelectionBorder()
	local isTarget = self:IsTarget();
	local isFocus = self:IsFocus();

	self.selectedBorder:SetShown(isTarget or isFocus);

	local borderColor = nil;
	if isTarget then
		borderColor = NamePlateConstants.TARGET_BORDER_COLOR;
	elseif isFocus then
		borderColor = NamePlateConstants.FOCUS_TARGET_BORDER_COLOR;
	end

	if borderColor then
		self.selectedBorder:SetVertexColor(borderColor.r, borderColor.g, borderColor.b);
	end
end
