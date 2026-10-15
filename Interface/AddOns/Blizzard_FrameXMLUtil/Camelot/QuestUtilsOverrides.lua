QuestUtilsOverrides = {};

-- Camelot conveys the quest type as text only, so drop the icon markup.
QuestUtilsOverrides.questTagIconHidden = true;

function QuestUtilsOverrides.GetQuestTitlePrefix(info)
	local eliteSuffix = C_QuestLog.IsEliteQuest(info.questID) and "+" or "";
	return "[" .. info.difficultyLevel .. eliteSuffix .. "] ";
end

function QuestUtilsOverrides.GetQuestTitleDifficultyColor(questID)
	if not CVarCallbackRegistry:GetCVarValueBool("showQuestDifficultyColor") then
		return nil;
	end

	local difficultyColor = GetDifficultyColor(C_PlayerInfo.GetContentDifficultyQuestForPlayer(questID));
	return CreateColor(difficultyColor.r, difficultyColor.g, difficultyColor.b, 1);
end

function QuestUtilsOverrides.GetQuestTagText(questID)
	local tagInfo = C_QuestLog.GetQuestTagInfo(questID);
	local tagID = tagInfo and tagInfo.tagID;

	if tagID == Constants.QuestConsts.QUEST_INFO_ELITE_ID then
		return PARENS_TEMPLATE:format(ELITE);
	elseif tagID == Constants.QuestConsts.QUEST_INFO_DUNGEON_ID then
		return PARENS_TEMPLATE:format(CALENDAR_TYPE_DUNGEON);
	elseif tagID == Constants.QuestConsts.QUEST_INFO_PVP_ID then
		return PARENS_TEMPLATE:format(CALENDAR_TYPE_PVP);
	elseif tagID == Constants.QuestConsts.QUEST_INFO_RAID_ID then
		return PARENS_TEMPLATE:format(RAID);
	end

	return nil;
end
