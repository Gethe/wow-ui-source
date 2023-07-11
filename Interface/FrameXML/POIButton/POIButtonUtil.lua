
POIButtonUtil = {};

POIButtonUtil.Style = {
	Waypoint = 1,
	Numeric = 2,
	QuestComplete = 3,
	QuestDisabled = 4,
	QuestThreat = 5,
	ContentTracking = 6,
};

POIButtonUtil.QuestTypes = {
	Normal = 1,
	Campaign = 2,
	Calling = 3,
	Important = 4,
};

function POIButtonUtil.GetStyleFromQuestData(isComplete, isWaypoint)
	if isWaypoint then
		return POIButtonUtil.Style.Waypoint;
	elseif isComplete then
		return POIButtonUtil.Style.QuestComplete;
	else
		return POIButtonUtil.Style.Numeric;
	end
end
