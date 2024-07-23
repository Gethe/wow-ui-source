ObjectiveTrackerFrameMixin = { };

function ObjectiveTrackerFrameMixin:OnLoad()
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("QUEST_ACCEPTED");
end

function ObjectiveTrackerFrameMixin:OnEvent(event, ...)
	if event == "ZONE_CHANGED_NEW_AREA" then
		C_QuestLog.SortQuestWatches();
	elseif event == "ZONE_CHANGED" then
		local mapID = C_Map.GetBestMapForUnit("player");
		if mapID ~= self.lastSortMapID then
			C_QuestLog.SortQuestWatches();
			self.lastSortMapID = mapID;
		end
	elseif ( event == "QUEST_ACCEPTED" ) then
		local questID = ...;
		if not C_QuestLog.IsQuestBounty(questID) and not C_QuestLog.IsQuestTask(questID) then
			if GetCVarBool("autoQuestWatch") and C_QuestLog.GetNumQuestWatches() < Constants.QuestWatchConsts.MAX_QUEST_WATCHES then
				C_QuestLog.AddQuestWatch(questID);
			end
		end
	end
end