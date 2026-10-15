QuestUtilsOverrides = {};

function QuestUtilsOverrides.GetQuestTitlePrefix(info)
	if CVarCallbackRegistry:GetCVarValueBool("colorblindMode") or CVarCallbackRegistry:GetCVarValueBool("showQuestLevel") then
		return "[" .. info.difficultyLevel .. "] ";
	end

	return nil;
end

function QuestUtilsOverrides.GetQuestTitleDifficultyColor(questID)
	if not CVarCallbackRegistry:GetCVarValueBool("showQuestDifficultyColor") then
		return nil;
	end

	local difficultyColor = GetDifficultyColor(C_PlayerInfo.GetContentDifficultyQuestForPlayer(questID));
	return CreateColor(difficultyColor.r, difficultyColor.g, difficultyColor.b, 1);
end

function QuestUtilsOverrides.GetQuestTagText(_questID)
	return nil;
end
