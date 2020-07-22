----------------------------------------------------------------------------------------------------
local PTR_Event_Frame = CreateFrame("Frame")

PTR_IssueReporter.InBarbershop = false

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
    PlayerDeath = "PlayerDeath",
    TimeSincePlayerProgress = "TimeSincePlayerProgress",
    TotalTimePlayedThisChar = "TotalTimePlayedThisChar",
    GameMenuFrameOpened = "GameMenuFrameOpened",
    GameMenuButtonQuit = "GameMenuButtonQuit",
    GameMenuButtonLogout = "GameMenuButtonLogout",
    GameMenuFrameClosed = "GameMenuFrameClosed",
    BarberShopOpened = "BarberShopOpened",
    BarberShopClosed = "BarberShopClosed"
}

local previousQuestProgress = {}
local timeSinceLastProgress = 0
local lastPlayerPosition = false
local currentNumberOfQuests = 0
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
    
    if (previousQuestProgress[questID]) then
        previousQuestProgress[questID] = nil
        timeSinceLastProgress = 0
    end
end
----------------------------------------------------------------------------------------------------
local function QuestFinishedHandler()
    PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.QuestFrameClosed)
end
----------------------------------------------------------------------------------------------------
local function PlayerDeathHandler()
    local deathEvents = DeathRecap_GetEvents()
    
    if (deathEvents[1]) and (deathEvents[1].sourceGUID) then
        local creatureID = GetCreatureIDFromGuid(deathEvents[1].sourceGUID)
        
        if (creatureID) then
            PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.PlayerDeath, creatureID)
        end
    end
end
----------------------------------------------------------------------------------------------------
local function GetCreatureIDFromGuid(guid)
    local parts = {}
    for s in guid:gmatch("[^-]+") do -- Split string by '-', The 6th option is creatureID
        table.insert(parts, s)
    end
    
    if (parts[6]) then
        return parts[6]
    else
        return 0
    end
end
----------------------------------------------------------------------------------------------------
local function QuestProgressHandler()
    local numberOfEntries = C_QuestLog.GetNumQuestLogEntries()
    local questIDs = {}
    local questCount = 0
    for i = 1, numberOfEntries, 1 do
        local info = C_QuestLog.GetInfo(i)
        if (info) and (info.questID) and (not info.isHidden) and (info.questID > 0) then
            table.insert(questIDs, info.questID)
            questCount = questCount + 1
        end
    end
    currentNumberOfQuests = questCount
    
    for key, questID in pairs (questIDs) do
        local objectives = C_QuestLog.GetQuestObjectives(questID)
        
        if (objectives) and (#objectives > 0) then
            if not (previousQuestProgress[questID]) then
                previousQuestProgress[questID] = {}
                timeSinceLastProgress = 0
            end
            
            for index, objectiveInfo in pairs (objectives) do
                if not (previousQuestProgress[questID][index]) then
                    previousQuestProgress[questID][index] = {
                        current = objectiveInfo.numFulfilled,
                        required = objectiveInfo.numRequired,                    
                    }
                    timeSinceLastProgress = 0
                else
                    if (previousQuestProgress[questID][index].current ~= objectiveInfo.numFulfilled) then
                        previousQuestProgress[questID][index].current = objectiveInfo.numFulfilled
                        timeSinceLastProgress = 0
                    end
                end
            end
        end
    end
    
    local map = C_Map.GetBestMapForUnit("player")
    local playerName = UnitName("player")
    local currentPosition
    
    if (map) then    
        currentPosition = C_Map.GetPlayerMapPosition(map, "player")
    end
    
    if not (Blizzard_PTRIssueReporter_Saved.TotalTimePlayedThisChar) then
        Blizzard_PTRIssueReporter_Saved.TotalTimePlayedThisChar = {}
    end
    
    if not (Blizzard_PTRIssueReporter_Saved.TotalTimePlayedThisChar[playerName]) then
        Blizzard_PTRIssueReporter_Saved.TotalTimePlayedThisChar[playerName] = 0
    end

    if (currentNumberOfQuests > 0) and (currentPosition) then
        if (lastPlayerPosition) and ((UnitAffectingCombat("player")) or (lastPlayerPosition.x ~= currentPosition.x) or (lastPlayerPosition.y ~= currentPosition.y)) then
            PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.TimeSincePlayerProgress, timeSinceLastProgress)
            timeSinceLastProgress = timeSinceLastProgress + 1
            Blizzard_PTRIssueReporter_Saved.TotalTimePlayedThisChar[playerName] = Blizzard_PTRIssueReporter_Saved.TotalTimePlayedThisChar[playerName] + 1
        end        
        lastPlayerPosition = currentPosition
    end
end
----------------------------------------------------------------------------------------------------
local function BarberShopOpenedHandler()
    PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.BarberShopOpened)
    PTR_IssueReporter:SetParent(CharCustomizeFrame)
    PTR_IssueReporter:SetFrameStrata("DIALOG")
	PTR_IssueReporter.InBarbershop = true
end
----------------------------------------------------------------------------------------------------
local function BarberShopClosedHandler()
    PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.BarberShopClosed)
    PTR_IssueReporter:SetParent(GetAppropriateTopLevelParent())
	PTR_IssueReporter:SetFrameStrata("DIALOG")
    PTR_IssueReporter.InBarbershop = false
end
----------------------------------------------------------------------------------------------------
C_Timer.NewTicker(1, QuestProgressHandler)
----------------------------------------------------------------------------------------------------
function GetTimeSinceLastQuestProgress()
    return GetTime() - lastProgressTime
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
    PLAYER_DEAD = CombatLogEventHandler,
    BARBER_SHOP_OPEN = BarberShopOpenedHandler,
    BARBER_SHOP_CLOSE = BarberShopClosedHandler
}

for event, func in pairs (PTR_IssueReporter.Data.RegisteredEvents) do
    PTR_Event_Frame:RegisterEvent(event)
end

if (GameMenuFrame) then
    GameMenuFrame:HookScript("OnShow", function()
        PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.GameMenuFrameOpened)
    end)
    
    GameMenuFrame:HookScript("OnHide", function()
        PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.GameMenuFrameClosed)
    end)
end

if (GameMenuButtonLogout) then
    GameMenuButtonLogout:HookScript("OnClick", function()
        PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.GameMenuButtonLogout)
    end)
end

if (GameMenuButtonQuit) then
    GameMenuButtonQuit:HookScript("OnClick", function()
        PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.GameMenuButtonQuit)
    end)
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