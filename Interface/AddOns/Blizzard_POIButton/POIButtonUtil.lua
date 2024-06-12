
POIButtonUtil = {};

POIButtonUtil.Style = {
	Waypoint = 1,
	QuestInProgress = 2,
	QuestComplete = 3,
	QuestDisabled = 4,
	QuestThreat = 5,
	ContentTracking = 6,
	WorldQuest = 7,
};

POIButtonUtil.QuestTypes = {
	Normal = 1,
	Campaign = 2,
	Calling = 3,
	Important = 4,
	Meta = 5,
	Recurring = 6,
	Rare = 7,
	Epic = 8,
};

function POIButtonUtil.GetStyleFromQuestData(isComplete, isWaypoint, isDisabled)
	if isWaypoint then
		return POIButtonUtil.Style.Waypoint;
	elseif isComplete then
		return POIButtonUtil.Style.QuestComplete;
	elseif isDisabled then
		return POIButtonUtil.Style.QuestDisabled;
	else
		return POIButtonUtil.Style.QuestInProgress;
	end
end
