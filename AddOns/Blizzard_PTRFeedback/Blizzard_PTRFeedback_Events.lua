----------------------------------------------------------------------------------------------------
local PTR_Event_Frame = CreateFrame("Frame")
PTR_IssueReporter.ReportEventTypes = {
    Tooltip = "Tooltip",
    MapIDEnter = "MapIDEnter",
    MapIDExit = "MapIDExit",
    MapDifficultyIDStarted = "MapDifficultyIDStarted",
    MapDifficultyIDEnded = "MapDifficultyIDEnded",    
    EncounterFailed = "EncounterFailed",
    EncounterSuccess = "EncounterSuccess",
    UIButtonClicked = "UIButtonClicked",
    PetBattleStart = "PetBattleStart",
    PetBattleEnd = "PetBattleEnd",
    QuestFrameClosed = "QuestFrameClosed",
    QuestRewardFrameShown = "QuestRewardFrameShown",
    QuestTurnedIn = "QuestTurnedIn",
}
----------------------------------------------------------------------------------------------------
local function EncounterEndHandler(...)
    local instanceName, instanceType, difficultyID, difficultyName = GetInstanceInfo()
    local encounterID, encounterName, difficultyID, groupSize, encounterSuccessful = ...
    
    local uiMapID = C_Map.GetBestMapForUnit("player")        
    local displayInfoID
    local i = 1
    local ejEncounterName = ""
    -- 20 is protection against infinite loop, Highest number of encounters in a zone currently is 18, this should ensure we aren't missing one
    -- loop typically exists after 1-2 based on how many bosses are on a floor 
    while (ejEncounterName) and (i<20) do 
        ejEncounterName = select(4, EJ_GetMapEncounter(uiMapID, i))
        -- Sometimes encounters are named 'The Boss' and then the event that is sent is just 'Boss', checking both contains will catch those
        if (ejEncounterName) and (string.match(ejEncounterName, encounterName) or string.match(ejEncounterName, encounterName)) then
            displayInfoID = select(4, EJ_GetCreatureInfo(1, select(6, EJ_GetMapEncounter(uiMapID, i))))
        end
        i = i + 1
    end
    
    local dataPackage = {
        ID = encounterID,
        Name = encounterName,
        DifficultyID = difficultyID,
        GroupSize = groupSize,
        DisplayInfoID = displayInfoID,
    }
    
    if (encounterSuccessful == 1) then        
        PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.EncounterSuccess, encounterID, dataPackage)
    else
        PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.EncounterFailed, encounterID, dataPackage)
    end
end
----------------------------------------------------------------------------------------------------
local function PetBattleStartHandler()
    PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.PetBattleStart)
end
----------------------------------------------------------------------------------------------------
local function PetBattleEndHandler()
    PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.PetBattleEnd)
end
----------------------------------------------------------------------------------------------------
local function QuestCompleteHandler()
    PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.QuestRewardFrameShown, questID, {ID = GetQuestID()})
end
----------------------------------------------------------------------------------------------------
local function QuestTurnedInHandler(...)
    local questID = ...
    PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.QuestTurnedIn, questID, {ID = questID})
end
----------------------------------------------------------------------------------------------------
local function QuestFinishedHandler()
    PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.QuestFrameClosed)
end    
----------------------------------------------------------------------------------------------------
PTR_IssueReporter.Data.RegisteredEvents = 
{
    ZONE_CHANGED = PTR_IssueReporter.HandleMapEvents,
    ZONE_CHANGED_INDOORS = PTR_IssueReporter.HandleMapEvents,
    ZONE_CHANGED_NEW_AREA = PTR_IssueReporter.HandleMapEvents,
    ENCOUNTER_END = EncounterEndHandler,
    PET_BATTLE_OPENING_START = PetBattleStartHandler,
    PET_BATTLE_CLOSE = PetBattleEndHandler,
    QUEST_COMPLETE = QuestCompleteHandler,
    QUEST_TURNED_IN = QuestTurnedInHandler,
    QUEST_FINISHED = QuestFinishedHandler,
    PLAYER_REGEN_ENABLED = PTR_IssueReporter.CheckSurveyQueue,
}
for event, func in pairs (PTR_IssueReporter.Data.RegisteredEvents) do
    PTR_Event_Frame:RegisterEvent(event)
end
----------------------------------------------------------------------------------------------------
local function PTR_Event_Frame_OnEvent(self, event, ...)
    if (PTR_IssueReporter.Data.IsLoaded) or (event == "PLAYER_ENTERING_WORLD") then
        local eventFunction = PTR_IssueReporter.Data.RegisteredEvents[event]
        if (eventFunction) and (type(eventFunction) == "function") then
            eventFunction(...)
        end
    end
end
PTR_Event_Frame:SetScript("OnEvent", PTR_Event_Frame_OnEvent)
----------------------------------------------------------------------------------------------------