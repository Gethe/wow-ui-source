QuestMapFrameOverrides = {};

-- no tabs in Camelot, events and map legend are hidden
QuestMapFrameOverrides.questTabHidden = true;
QuestMapFrameOverrides.eventsTabHidden = true;
QuestMapFrameOverrides.mapLegendTabHidden = true;
QuestMapFrameOverrides.titleFrameLeftPadding = 4;

function QuestMapFrameOverrides.GetQuestsTabAnchorOffset()
	return 5, -28;
end

