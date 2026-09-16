function DifficultyUtil.GetDifficultyColor(difficulty)
	if (difficulty == Enum.RelativeContentDifficulty.Trivial) then
		return QuestDifficultyColors["trivial"], QuestDifficultyHighlightColors["trivial"];
	elseif (difficulty == Enum.RelativeContentDifficulty.Easy) then
		return QuestDifficultyColors["standard"], QuestDifficultyHighlightColors["standard"];
	elseif (difficulty == Enum.RelativeContentDifficulty.Fair) then
		return QuestDifficultyColors["difficult"], QuestDifficultyHighlightColors["difficult"];
	elseif (difficulty == Enum.RelativeContentDifficulty.Difficult) then
		return QuestDifficultyColors["verydifficult"], QuestDifficultyHighlightColors["verydifficult"];
	elseif (difficulty == Enum.RelativeContentDifficulty.Impossible) then
		return QuestDifficultyColors["impossible"], QuestDifficultyHighlightColors["impossible"];
	else
		return QuestDifficultyColors["difficult"], QuestDifficultyHighlightColors["difficult"];
	end
end

function DifficultyUtil.GetQuestDifficultyColor(level, isScaling, optQuestID)
	if optQuestID and C_QuestLog.IsQuestDisabledForSession(optQuestID) then
		return QuestDifficultyColors["disabled"], QuestDifficultyHighlightColors["disabled"];
	end

	if (isScaling) then
		return DifficultyUtil.GetScalingQuestDifficultyColor(level);
	end

	return DifficultyUtil.GetRelativeDifficultyColor(UnitEffectiveLevel("player"), level);
end

function DifficultyUtil.GetCreatureDifficultyColor(level)
	return DifficultyUtil.GetRelativeDifficultyColor(UnitEffectiveLevel("player"), level);
end

function DifficultyUtil.GetRelativeDifficultyColor(unitLevel, challengeLevel)
	local levelDiff = challengeLevel - unitLevel;
	if ( levelDiff >= 5 ) then
		return QuestDifficultyColors["impossible"], QuestDifficultyHighlightColors["impossible"];
	elseif ( levelDiff >= 3 ) then
		return QuestDifficultyColors["verydifficult"], QuestDifficultyHighlightColors["verydifficult"];
	elseif ( levelDiff >= -4 ) then
		return QuestDifficultyColors["difficult"], QuestDifficultyHighlightColors["difficult"];
	elseif ( -levelDiff <= UnitQuestTrivialLevelRange("player") ) then
		return QuestDifficultyColors["standard"], QuestDifficultyHighlightColors["standard"];
	else
		return QuestDifficultyColors["trivial"], QuestDifficultyHighlightColors["trivial"];
	end
end

function DifficultyUtil.GetScalingQuestDifficultyColor(questLevel)
	local playerLevel = UnitEffectiveLevel("player");
	local levelDiff = questLevel - playerLevel;
	if ( levelDiff >= 5 ) then
		return QuestDifficultyColors["impossible"], QuestDifficultyHighlightColors["impossible"];
	elseif ( levelDiff >= 3 ) then
		return QuestDifficultyColors["verydifficult"], QuestDifficultyHighlightColors["verydifficult"];
	elseif ( levelDiff >= 0 ) then
		return QuestDifficultyColors["difficult"], QuestDifficultyHighlightColors["difficult"];
	elseif ( -levelDiff <= UnitQuestTrivialLevelRangeScaling("player") ) then
		return QuestDifficultyColors["standard"], QuestDifficultyHighlightColors["standard"];
	else
		return QuestDifficultyColors["trivial"], QuestDifficultyHighlightColors["trivial"];
	end
end

function GetDifficultyColor(difficulty)
	return DifficultyUtil.GetDifficultyColor(difficulty);
end

function GetQuestDifficultyColor(level, isScaling, optQuestID)
	return DifficultyUtil.GetQuestDifficultyColor(level, isScaling, optQuestID);
end

function GetCreatureDifficultyColor(level)
	return DifficultyUtil.GetCreatureDifficultyColor(level);
end

function GetRelativeDifficultyColor(unitLevel, challengeLevel)
	return DifficultyUtil.GetRelativeDifficultyColor(unitLevel, challengeLevel);
end

function GetScalingQuestDifficultyColor(questLevel)
	return DifficultyUtil.GetScalingQuestDifficultyColor(questLevel);
end