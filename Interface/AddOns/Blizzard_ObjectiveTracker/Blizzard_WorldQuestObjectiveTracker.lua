local settings = {
	headerText = TRACKER_HEADER_WORLD_QUESTS,
	events = { "QUEST_TURNED_IN", "QUEST_LOG_UPDATE", "QUEST_WATCH_LIST_CHANGED", "QUEST_ACCEPTED", "SUPER_TRACKING_CHANGED" },
	-- for this module
	showWorldQuests = true,
};

WorldQuestObjectiveTrackerMixin = CreateFromMixins(BonusObjectiveTrackerMixin, settings);

function WorldQuestObjectiveTrackerMixin:OnEvent(event, ...)
	if event == "QUEST_TURNED_IN" then
		self:OnQuestTurnedIn(...);
	elseif event == "QUEST_ACCEPTED" then
		local questID = ...;
		if QuestUtil.IsQuestTrackableTask(questID) then
			if QuestUtils_IsQuestWorldQuest(questID) then
				self:OnQuestAccepted(questID);
			end
		end
	elseif event == "QUEST_WATCH_LIST_CHANGED" then
		local questID = ...;
		self:SetNeedsFanfare(questID);
		self:MarkDirty();
	else
		self:MarkDirty();
	end
end

function WorldQuestObjectiveTrackerMixin:TryAddingExpirationWarningLine(block, questID)
	if QuestUtils_ShouldDisplayExpirationWarning(questID) then
		local timeLeftMinutes = C_TaskQuest.GetQuestTimeLeftMinutes(questID);
		local text = "";
		if timeLeftMinutes and self.tickerSeconds then
			if timeLeftMinutes > 0 then
				if timeLeftMinutes < WORLD_QUESTS_TIME_CRITICAL_MINUTES then
					local timeString = SecondsToTime(timeLeftMinutes * 60);
					text = BONUS_OBJECTIVE_TIME_LEFT:format(timeString);
					-- want to update the time every 10 seconds
					self.tickerSeconds = 10;
				else
					-- want to update 10 seconds before the difference becomes 0 minutes
					-- once at 0 minutes we want a 10 second update to catch the transition below WORLD_QUESTS_TIME_CRITICAL_MINUTES
					local timeToAlert = min((timeLeftMinutes - WORLD_QUESTS_TIME_CRITICAL_MINUTES) * 60 - 10, 10);
					if self.tickerSeconds == 0 or timeToAlert < self.tickerSeconds then
						self.tickerSeconds = timeToAlert;
					end
				end
			end
		end
		local line = block:AddObjective("TimeLeft", text, nil, nil, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["TimeLeft"], true);
		line.Icon:Hide();
	end
end

local function SortWorldQuestsHelper(questID1, questID2)
	local inArea1, onMap1 = GetTaskInfo(questID1);
	local inArea2, onMap2 = GetTaskInfo(questID2);

	if inArea1 ~= inArea2 then
		return inArea1;
	elseif onMap1 ~= onMap2 then
		return onMap1;
	else
		return questID1 < questID2;
	end
end

function WorldQuestObjectiveTrackerMixin:GetSortedWorldQuests()
	local sortedQuests = {};
	for i = 1, C_QuestLog.GetNumWorldQuestWatches() do
		tinsert(sortedQuests, C_QuestLog.GetQuestIDForWorldQuestWatchIndex(i));
	end

	table.sort(sortedQuests, SortWorldQuestsHelper);

	return sortedQuests;
end

function WorldQuestObjectiveTrackerMixin:LayoutContents()
	if self.ticker then
		self.ticker:Cancel();
		self.ticker = nil;
	end
	self.tickerSeconds = 0;

	-- local area WQs first
	local tasksTable = GetTasksTable();
	for i = 1, #tasksTable do
		local questID = tasksTable[i];
		if QuestUtils_IsQuestWorldQuest(questID) and not QuestUtils_IsQuestWatched(questID) then
			if not self:AddQuest(questID) then
				break;
			end
		end
	end

	-- then the tracked ones
	local sortedQuests = self:GetSortedWorldQuests();
	for i, questID in ipairs(sortedQuests) do
		local isTrackedWorldQuest = true;
		if not self:AddQuest(questID, isTrackedWorldQuest) then
			break;
		end
	end

	if self.tickerSeconds > 0 then
		self.ticker = C_Timer.NewTicker(self.tickerSeconds, function()
			self:MarkDirty();
		end);
	end
end