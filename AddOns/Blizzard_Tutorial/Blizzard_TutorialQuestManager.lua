-- ------------------------------------------------------------------------------------------------------------
local QuestData = class("QuestData");

-- ------------------------------------------------------------------------------------------------------------
function QuestData:initialize(questID, questTitle)
	self.QuestID = questID;
	self.QuestTitle = questTitle;

	self.Time_Accepted = GetTime();
	self.Time_ObjectivesComplete = nil;
	self.Time_TurnedIn = nil;

	self.WasReinitializedAccepted = NPE_QuestManager.IsReinitializing;
end

-- ------------------------------------------------------------------------------------------------------------
function QuestData:AreObjectivesComplete()
	return self.Time_ObjectivesComplete ~= nil;
end

-- ------------------------------------------------------------------------------------------------------------
function QuestData:ObjectivesComplete()
	self.Time_ObjectivesComplete = GetTime();
end

-- ------------------------------------------------------------------------------------------------------------
function QuestData:Complete()
	self.Time_TurnedIn = GetTime();
	self.IsComplete = true;
end

-- ------------------------------------------------------------------------------------------------------------
-- Returns the amount of time the player was actively working on objectives
function QuestData:GetActiveTime()
	if (self.Time_ObjectivesComplete) then
		return self.Time_ObjectivesComplete - self.Time_Accepted;
	end
end

-- ------------------------------------------------------------------------------------------------------------
-- Returns the total amount of time the player had the quest (from quest accept to quest turn in)
function QuestData:GetTotalTime()
	if (self.Time_TurnedIn) then
		return self.Time_TurnedIn - self.Time_Accepted;
	end
end










-- ------------------------------------------------------------------------------------------------------------
NPE_QuestManager = {};

NPE_QuestManager.Events =
{
	Quest_Accepted				= "Quest_Accepted",
	Quest_ObjectivesComplete	= "Quest_ObjectivesComplete",
	Quest_TurnedIn				= "Quest_TurnedIn",
	Quest_Abandoned				= "Quest_Abandoned",
}

-- ------------------------------------------------------------------------------------------------------------
function NPE_QuestManager:Initialize()
	self.Data = {};
	self.Callbacks = {};
	self.IsReinitializing = false;

	self:ReinitializeExistingQuests();

	Dispatcher:RegisterEvent("QUEST_ACCEPTED", self);
	Dispatcher:RegisterEvent("QUEST_LOG_UPDATE", self);
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_QuestManager:Shutdown()
	Dispatcher:UnregisterAll(self);
	self.Data = {};
	self.Callbacks = {};
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_QuestManager:ReinitializeExistingQuests()
	self.IsReinitializing = true;

	for i = 1, GetNumQuestLogEntries() do
		self:QUEST_ACCEPTED(i);
	end

	self:QUEST_LOG_UPDATE();

	self.IsReinitializing = false;
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_QuestManager:AreQuestsPending()
	for questID, questData in pairs(self.Data) do
		if (not questData.Time_ObjectivesComplete) then
			return true;
		end
	end

	return false;
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_QuestManager:QUEST_ACCEPTED(questLogIndex)
	local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID = GetQuestLogTitle(questLogIndex);

	if (not isHeader) then
		local data = QuestData:new(questID, title);

		self.Data[questID] = data;

		self:_DoCallback(self.Events.Quest_Accepted, data);
	end
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_QuestManager:QUEST_LOG_UPDATE()
	for questID, questData in pairs(self.Data) do
		if (not questData.IsComplete) then
			if (not questData.Time_ObjectivesComplete) then
				-- check to see if the objectives are complete
				local objectivesComplete = select(6, GetQuestLogTitle(GetQuestLogIndexByID(questID)));
				if (objectivesComplete) then
					questData:ObjectivesComplete();
					self:_DoCallback(self.Events.Quest_ObjectivesComplete, questData);
				end
			else
				if (IsQuestFlaggedCompleted(questID)) then
					questData:Complete();
					self:_DoCallback(self.Events.Quest_TurnedIn, questData);
				end
			end
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_QuestManager:SimulateEvents(callbackTargetFilter)
	for questID, questData in pairs(self.Data) do
		if (not questData.IsComplete) then
			if (not questData.Time_ObjectivesComplete) then
				self:_DoCallback(self.Events.Quest_Accepted, questData, callbackTargetFilter);
			else
				self:_DoCallback(self.Events.Quest_ObjectivesComplete, questData, callbackTargetFilter);
			end
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_QuestManager:_DoCallback(event, questData, callbackTargetFilter)
	for obj, v in pairs(self.Callbacks) do
		if ((not callbackTargetFilter) or (callbackTargetFilter == obj)) then
			if (obj and (type(obj[event]) == "function")) then
				obj[event](obj, questData);
			end
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_QuestManager:RegisterForCallbacks(obj)
	self.Callbacks[obj] = true;
	self:SimulateEvents(obj);
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_QuestManager:UnregisterForCallbacks(obj)
	self.Callbacks[obj] = nil;
end

-- ------------------------------------------------------------------------------------------------------------
NPE_QuestManager:Initialize();