-- ------------------------------------------------------------------------------------------------------------
local QuestData = class("QuestData");

-- ------------------------------------------------------------------------------------------------------------
function QuestData:initialize(questID, questTitle)
	self.QuestID = questID;
	self.QuestTitle = questTitle;

	self.Time_Accepted = GetTime();
	self.Time_ObjectivesComplete = nil;
	self.Time_TurnedIn = nil;

	self.WasReinitializedAccepted = TutorialQuestManager.IsReinitializing;
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
function QuestData:GetTurnInMapID()
	return GetQuestUiMapID(self.QuestID);
end

-- ------------------------------------------------------------------------------------------------------------
TutorialQuestManager = {};

TutorialQuestManager.Events =
{
	Quest_Accepted				= "Quest_Accepted",
	Quest_ObjectivesComplete	= "Quest_ObjectivesComplete",
	Quest_Updated				= "Quest_Updated",
	Quest_TurnedIn				= "Quest_TurnedIn",
	Quest_Abandoned				= "Quest_Abandoned",
}

-- ------------------------------------------------------------------------------------------------------------
function TutorialQuestManager:Initialize()
	self.Data = {};
	self.Callbacks = {};
	self.IsReinitializing = false;

	self:ReinitializeExistingQuests();

	Dispatcher:RegisterEvent("QUEST_ACCEPTED", self);
	Dispatcher:RegisterEvent("QUEST_LOG_UPDATE", self);
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialQuestManager:Shutdown()
	Dispatcher:UnregisterAll(self);
	self.Data = {};
	self.Callbacks = {};
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialQuestManager:ReinitializeExistingQuests()
	self.IsReinitializing = true;

	for i = 1, C_QuestLog.GetNumQuestLogEntries() do
		self:QUEST_ACCEPTED(i);
	end

	self:QUEST_LOG_UPDATE();

	self.IsReinitializing = false;
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialQuestManager:AreQuestsPending()
	for questID, questData in pairs(self.Data) do
		if (not questData.Time_ObjectivesComplete) then
			return true;
		end
	end

	return false;
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialQuestManager:QUEST_ACCEPTED(questID)
	local title = C_QuestLog.GetTitleForQuestID(questID);
	if title then
		local data = QuestData:new(questID, title);
		self.Data[questID] = data;
		self:_DoCallback(self.Events.Quest_Accepted, data);
	end
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialQuestManager:QUEST_LOG_UPDATE()
	for questID, questData in pairs(self.Data) do
		if (not questData.IsComplete) then
			if (not questData.Time_ObjectivesComplete) then
				-- check to see if the objectives are complete
				local objectivesComplete = C_QuestLog.IsComplete(questID);
				if (objectivesComplete) then
					questData:ObjectivesComplete();
					self:_DoCallback(self.Events.Quest_ObjectivesComplete, questData);
				else
					local onQuest = C_QuestLog.IsOnQuest(questID);
					if onQuest == true then
						self:_DoCallback(self.Events.Quest_Updated, questData);
					else
						self:_DoCallback(self.Events.Quest_Abandoned, questData);
					end
				end
			else
				if (C_QuestLog.IsQuestFlaggedCompleted(questID)) then
					questData:Complete();
					self:_DoCallback(self.Events.Quest_TurnedIn, questData);
				end
			end
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialQuestManager:SimulateEvents(callbackTargetFilter)
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
function TutorialQuestManager:_DoCallback(event, questData, callbackTargetFilter)
	for obj, v in pairs(self.Callbacks) do
		if ((not callbackTargetFilter) or (callbackTargetFilter == obj)) then
			if (obj and (type(obj[event]) == "function")) then
				obj[event](obj, questData);
			end
		end
	end
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialQuestManager:RegisterForCallbacks(obj)
	self.Callbacks[obj] = true;
	self:SimulateEvents(obj);
end

-- ------------------------------------------------------------------------------------------------------------
function TutorialQuestManager:UnregisterForCallbacks(obj)
	self.Callbacks[obj] = nil;
end
