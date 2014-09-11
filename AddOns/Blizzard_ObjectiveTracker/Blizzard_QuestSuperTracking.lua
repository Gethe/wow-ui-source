local PENDING_QUEST_ID;

function QuestSuperTracking_OnQuestTracked(questID)
	-- We should supertrack quest if it got added to the top of the tracker
	-- First check if we have POI info. Could be missing if 1) we didn't know about this quest before, 2) just doesn't have POIs
	if ( QuestHasPOIInfo(questID) ) then
		-- now check if quest is at the top of the tracker
		if ( GetQuestWatchInfo(1) == questID ) then
			SetSuperTrackedQuestID(questID);
		end		
		PENDING_QUEST_ID = nil;
	else
		-- no POI info, could be arriving later
		PENDING_QUEST_ID = questID;
	end
end

function QuestSuperTracking_OnQuestCompleted()
	QuestSuperTracking_ChooseClosestQuest();
end

function QuestSuperTracking_OnQuestUntracked()
	QuestSuperTracking_ChooseClosestQuest();
end

function QuestSuperTracking_OnPOIUpdate()
	-- if we were waiting on data for an added quest, we should supertrack it if it has POI data and it's at the top of the tracker
	if ( PENDING_QUEST_ID and QuestHasPOIInfo(PENDING_QUEST_ID) ) then
		-- check top of tracker
		if ( GetQuestWatchInfo(1) == PENDING_QUEST_ID ) then
			SetSuperTrackedQuestID(PENDING_QUEST_ID);
		end
	elseif ( GetSuperTrackedQuestID() == 0 ) then
		-- otherwise pick something if we're not supertrack anything
		QuestSuperTracking_ChooseClosestQuest();
	end
	PENDING_QUEST_ID = nil;
end

function QuestSuperTracking_ChooseClosestQuest()
	local minDistSqr = math.huge;
	local closestQuestID;
	for i = 1, GetNumQuestWatches() do
		local questID, title, questLogIndex = GetQuestWatchInfo(i);
		if ( questID and QuestHasPOIInfo(questID) ) then
			local distSqr, onContinent = GetDistanceSqToQuest(questLogIndex);
			if ( onContinent and distSqr <= minDistSqr ) then
				minDistSqr = distSqr;
				closestQuestID = questID;
			end
		end
	end
	-- If nothing with POI data is being tracked expand search to quest log
	if ( not closestQuestID ) then
		for questLogIndex = 1, GetNumQuestLogEntries() do
			local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID = GetQuestLogTitle(questLogIndex);	
			if ( not isHeader and QuestHasPOIInfo(questID) ) then
				local distSqr, onContinent = GetDistanceSqToQuest(questLogIndex);
				if ( onContinent and distSqr <= minDistSqr ) then
					minDistSqr = distSqr;
					closestQuestID = questID;
				end
			end
		end
	end
	-- Supertrack if we have a valid quest
	if ( closestQuestID ) then
		SetSuperTrackedQuestID(closestQuestID);
	else
		SetSuperTrackedQuestID(0);
	end
end

function QuestSuperTracking_CheckSelection()
	-- if supertracked quest is not in the quest log anymore, switch selection
	local trackedQuestID = GetSuperTrackedQuestID();
	if ( trackedQuestID == 0 or GetQuestLogIndexByID(trackedQuestID) == 0 ) then
		QuestSuperTracking_ChooseClosestQuest();
	end
end