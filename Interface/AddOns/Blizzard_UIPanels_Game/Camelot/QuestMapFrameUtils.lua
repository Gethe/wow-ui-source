QuestMapFrameUtils = QuestMapFrameUtils or {}

function QuestMapFrameUtils:IsPartySyncEnabled()
	return false;
end

function QuestLogQuests_ShowQuestCount()
	QuestLogCount:Show();

	if InputUtil.IsMKBUIEnabled() then
		QuestScrollFrame.SearchBox:SetSize(200, 20);
	else
		QuestScrollFrame.SearchBox:SetSize(130, 20);
	end

	local numEntries, numQuests = C_QuestLog.GetNumQuestLogEntries();
	-- Update Quest Count
	if (numQuests > Constants.QuestLogConsts.MAXIMUM_NUM_QUESTS_LOG_CAN_ACCEPT) then
		QuestLogQuestCount:SetFormattedText(QUEST_LOG_COUNT_TEMPLATE, RED_FONT_COLOR_CODE, numQuests, Constants.QuestLogConsts.MAXIMUM_NUM_QUESTS_LOG_CAN_ACCEPT);
	else
		QuestLogQuestCount:SetFormattedText(QUEST_LOG_COUNT_TEMPLATE, "|cffffffff", numQuests, Constants.QuestLogConsts.MAXIMUM_NUM_QUESTS_LOG_CAN_ACCEPT);
	end
end
