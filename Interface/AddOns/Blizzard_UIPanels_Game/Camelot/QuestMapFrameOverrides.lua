QuestMapFrameOverrides = {};

-- no tabs in Camelot, events and map legend are hidden
QuestMapFrameOverrides.questTabHidden = true;
QuestMapFrameOverrides.eventsTabHidden = true;
QuestMapFrameOverrides.mapLegendTabHidden = true;
QuestMapFrameOverrides.titleFrameLeftPadding = 4;

function QuestMapFrameOverrides.GetQuestsTabAnchorOffset()
	return 5, -28;
end

-- Camelot prepends the quest level to the quest log title.
function QuestMapFrameOverrides.GetQuestTitlePrefix(info)
	local eliteSuffix = C_QuestLog.IsEliteQuest(info.questID) and "+" or "";
	return "[" .. info.difficultyLevel .. eliteSuffix .. "] ";
end

-- Camelot displays extra text for elite quests in the quest log title.
function QuestMapFrameOverrides.GetQuestTagText(info)
	return C_QuestLog.IsEliteQuest(info.questID) and PARENS_TEMPLATE:format(ELITE) or nil;
end
