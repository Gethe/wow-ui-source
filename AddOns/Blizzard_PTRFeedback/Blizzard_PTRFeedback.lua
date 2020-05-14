PTR_IssueReporter = CreateFrame("Frame", nil, GetAppropriateTopLevelParent())
PTR_IssueReporter.Data = {
    UnitTokens = {
        Player = "player",
        Target = "target",
    },
    CurrentMapID = 0,
    CurrentMapDifficultyID = 0,
    PreviousMapID = 0,
    PreviousMapDifficultyID = 0,
    RegisteredSurveys = {},
    RegisteredButtonEvents = {},
    RegisteredButtonEndEvents = {},
    RegisteredFrameAttachedEvents = {},
    FrameAttachedSurveyFrames = {},
    RegisteredEventFunctions = {},
    RegisteredSlashSetups = {},
    RegisteredSlashSurveys = {},
    DefaultKeybind = "F6",
    SuppressedLocations = {},
    BugReportString = "I have encountered a bug.",
    ButtonDataPackage = {},
    bossBugButtonText = "Bug & Feedback - %s",
    CurrentBugButtonContext = "",
    DefaultBugButtonContext = "Bug",
    Height = 50,
    FrameComponents = {},
    UnusedFrameComponents = {},
    SubmitText = "Submit",
    NextText = "Next",
    FrameComponentMargin = 3,
    PopSurveyQueue = {},
    IsLoaded = false,
    SubmitButtonHeight = 32,
}

PTR_IssueReporter.Assets = {
    InfoIcon = "Interface\\FriendsFrame\\InformationIcon.blp",
    InfoIconHighlight = "Interface\\FriendsFrame\\InformationIcon-Highlight.blp",
    ConfusedIcon = "Interface\\TutorialFrame\\TutorialFrame-QuestionMark",
    BugReportIcon = "Interface\\HelpFrame\\HelpIcon-Bug.blp",
    PushedTexture = "Interface\\Buttons\\UI-Quickslot-Depress",
    BackgroundTexture = "Interface\\FrameGeneral\\UI-Background-Marble",
    TestWatermark = "Interface\\FrameGeneral\\UI-Background-TestWatermark",
    FontString = "GameFontNormal",
    BossReportIcon = "Interface\\HelpFrame\\HelpIcon-Bug-Red",
    PetReportIcon = "Interface\\Icons\\tracking_wildpet",
}
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.Init()
    Blizzard_PTRIssueReporter_Saved = Blizzard_PTRIssueReporter_Saved or {}
    
    PTR_IssueReporter.InitializePTRTooltips()
    PTR_IssueReporter.SetDefaultKeybindIfUnusedAndNotSet()
    
    for key, value in pairs (PTR_IssueReporter.ReportEventTypes) do
        PTR_IssueReporter.Data.RegisteredSurveys[key] = {}
        PTR_IssueReporter.Data.RegisteredButtonEvents[key]  = {}
        PTR_IssueReporter.Data.RegisteredButtonEndEvents[key]  = {}
        PTR_IssueReporter.Data.RegisteredFrameAttachedEvents[key] = {}
        PTR_IssueReporter.Data.RegisteredEventFunctions[key] = {}
    end
    
    PTR_IssueReporter.Data.RegisteredSurveys.FallbackEvents = {}
    PTR_IssueReporter.Data.RegisteredButtonEvents.FallbackEvents = {}
    PTR_IssueReporter.Data.RegisteredButtonEndEvents.FallbackEvents = {}
    
    PTR_IssueReporter.CreateReports()
    PTR_IssueReporter.RunPreviousSetupCommands()
    PTR_IssueReporter.CreateMainView()
    if not(IsOnGlueScreen()) then
        C_Timer.NewTicker(5, PTR_IssueReporter.CheckSurveyQueue)
    end
    PTR_IssueReporter.Data.IsLoaded = true
    PTR_IssueReporter.HandleMapEvents()
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.GlueInit()
    Blizzard_PTRIssueReporter_Saved = Blizzard_PTRIssueReporter_Saved or {}
    
    for key, value in pairs (PTR_IssueReporter.ReportEventTypes) do
        PTR_IssueReporter.Data.RegisteredSurveys[key] = {}
        PTR_IssueReporter.Data.RegisteredButtonEvents[key]  = {}
        PTR_IssueReporter.Data.RegisteredButtonEndEvents[key]  = {}
        PTR_IssueReporter.Data.RegisteredFrameAttachedEvents[key] = {}
        PTR_IssueReporter.Data.RegisteredEventFunctions[key] = {}
    end
    
    PTR_IssueReporter.Data.RegisteredSurveys.FallbackEvents = {}
    PTR_IssueReporter.Data.RegisteredButtonEvents.FallbackEvents = {}
    PTR_IssueReporter.Data.RegisteredButtonEndEvents.FallbackEvents = {}

    PTR_IssueReporter.CreateReports()
    PTR_IssueReporter.RunPreviousSetupCommands()
    PTR_IssueReporter.CreateMainView()    
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SlashHandeler(msg)
    local words = {}
    for s in msg:gmatch("[^ ]+") do
        table.insert(words, s)
    end
    
    local unlockWord = words[2]
    if (strupper(words[1]) == "ENABLE") and (unlockWord) and (type(PTR_IssueReporter.Data.RegisteredSlashSetups[strupper(unlockWord)]) == "function") then
        if not (Blizzard_PTRIssueReporter_Saved.RanSetups) then
            Blizzard_PTRIssueReporter_Saved.RanSetups = {}
        end
        
        if not (Blizzard_PTRIssueReporter_Saved.RanSetups[strupper(unlockWord)]) then
            PTR_IssueReporter.Data.RegisteredSlashSetups[strupper(unlockWord)]()
            print(string.format("%s Survey's have been Enabled!", unlockWord))
            Blizzard_PTRIssueReporter_Saved.RanSetups[strupper(unlockWord)] = true
        end
    elseif (strupper(words[1]) == "SURVEY") and (unlockWord) and (PTR_IssueReporter.Data.RegisteredSlashSurveys[strupper(unlockWord)]) then
        PTR_IssueReporter.PopStandaloneSurvey(PTR_IssueReporter.Data.RegisteredSlashSurveys[strupper(unlockWord)])
    end
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.RegisterSetupCommand(unlockWord, func)
    PTR_IssueReporter.Data.RegisteredSlashSetups[strupper(unlockWord)] = func
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.RegisterSurveyPopCommand(unlockWord, survey)
    PTR_IssueReporter.Data.RegisteredSlashSurveys[strupper(unlockWord)] = survey
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.RunPreviousSetupCommands()
    if (Blizzard_PTRIssueReporter_Saved) and (Blizzard_PTRIssueReporter_Saved.RanSetups) then --
        for ranSetup, value in pairs (Blizzard_PTRIssueReporter_Saved.RanSetups) do
            if (PTR_IssueReporter.Data.RegisteredSlashSetups[ranSetup]) then
                PTR_IssueReporter.Data.RegisteredSlashSetups[ranSetup]()
            end        
        end
    end
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.GetKeybind()
    local i = 1
    while i <= GetNumBindings() do
        local bindingName, bindingGroup, bindingKey = GetBinding(i)
        if bindingName == "Open Bug Report" and bindingGroup == "PTR" then
            return bindingKey or ""
        end
        i = i + 1
    end
    return ""
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SetDefaultKeybindIfUnusedAndNotSet()
    local i = 1
    local bindingAlreadyUsed = false
    while i <= GetNumBindings() do
        local bindingName, bindingGroup, bindingKey = GetBinding(i)
        if bindingKey == PTR_IssueReporter.Data.DefaultKeybind then
            bindingAlreadyUsed = true
        end
        i = i + 1
    end
    
    if not (bindingAlreadyUsed) and (PTR_IssueReporter.GetKeybind() == "") then
        SetBinding(PTR_IssueReporter.Data.DefaultKeybind, "Open Bug Report")
    end
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.CreateSurvey(reportID, reportTitle)
    local newSurvey = {
        ID = reportID,
        Title = reportTitle,
        Collectors = {},
        DynamicTitleTokens = {},
    }
    
    function newSurvey:AddDataCollection(questionType, ...)
        PTR_IssueReporter.AddDataCollectorToReport(self, questionType, ...)
    end
    
    function newSurvey:RegisterPopEvent(popEventType, eventArgument)    
        PTR_IssueReporter.RegisterEventToReport(PTR_IssueReporter.Data.RegisteredSurveys, self, popEventType, eventArgument)
    end
    
    function newSurvey:SetButton(buttonTooltip, buttonIcon)
        newSurvey.Tooltip = buttonTooltip
        newSurvey.Icon = buttonIcon
    end
    
    function newSurvey:RegisterButtonEvent(popEventType, eventArgument)    
        PTR_IssueReporter.RegisterEventToReport(PTR_IssueReporter.Data.RegisteredButtonEvents, self, popEventType, eventArgument)
    end
    
    function newSurvey:RegisterButtonEventEnd(popEventType, eventArgument)
        PTR_IssueReporter.RegisterEventToReport(PTR_IssueReporter.Data.RegisteredButtonEndEvents, self, popEventType, eventArgument)
    end
    
    function newSurvey:PopSurveyOnSubmit(survey)
        newSurvey.OnSubmitPoppedSurvey = survey
    end
    
    function newSurvey:RegisterFrameAttachedSurvey(frame, startEvent, endEvent, xOffset, yOffset, point, relativePoint)
        PTR_IssueReporter.AttachSurveyToFrameOnEvent(self, frame, startEvent, endEvent, xOffset, yOffset, point, relativePoint)
    end
    
    function newSurvey:PopulateDynamicTitleToken(index, dataPackageKey, functionToUse)
        local dynamicTitleToken = {
            key = dataPackageKey,
            func = functionToUse,
        }
        
        self.DynamicTitleTokens[index] = dynamicTitleToken
    end
    
    function newSurvey:AttachModelViewer(dataPackageKey, useDisplayInfoID, functionToUse)
         self.ModelViewerData = {
            key = dataPackageKey,
            useDisplayInfoID = useDisplayInfoID,
            func = functionToUse,
        }
    end
    
    function newSurvey:AttachIconViewer(dataPackageKey, functionToUse)
        self.IconViewerData = {
            key = dataPackageKey,
            func = functionToUse,
        }
    end
    
    return newSurvey
end
----------------------------------------------------------------------------------------------------
PTR_IssueReporter.DataCollectorTypes = {
    SelectOne_MultipleChoiceQuestion = 1,
    SelectMultiple_MultipleChoiceQuestion = 2,
    OpenEndedQuestion = 3,
    RunFunction = 4,
    FromDataPackage = 5, 
    SurveyID = 6,
    TextBlock = 7,
}

function PTR_IssueReporter.AddDataCollectorToReport(survey, collectorType, ...)
    local types = PTR_IssueReporter.DataCollectorTypes
    
    if (survey) and (survey.Collectors) then
        if (collectorType == types.SelectOne_MultipleChoiceQuestion) or (collectorType == types.SelectMultiple_MultipleChoiceQuestion) then
            local question, choices, displayVertically = ...
            if (question) and (choices) and ((type(choices) == "table")) then                
                if (displayVertically == null) then
                    displayVertically = false
                end
                
                local newDataCollector = {
                    collectorType = collectorType,
                    question = question,
                    choices = choices,
                    displayVertically = displayVertically,
                }
                table.insert(survey.Collectors, newDataCollector)
            end           
            
        elseif collectorType == types.OpenEndedQuestion then
            local question = ...
            question = question or ""
            
            if (question) then
                local newDataCollector = {
                    collectorType = collectorType,
                    question = question,
                    choices = choices,
                }
                table.insert(survey.Collectors, newDataCollector)
            end
            
        elseif collectorType == types.RunFunction then
            local collectorFunction = ...

            if (collectorFunction) then
                local newDataCollector = {
                    collectorType = collectorType,
                    collectorFunction = collectorFunction,
                }
                
                table.insert(survey.Collectors, newDataCollector)
            end
            
        elseif collectorType == types.FromDataPackage then
            local dataPackageKey = ...

            if (dataPackageKey) then
                local newDataCollector = {
                    collectorType = collectorType,
                    dataPackageKey = dataPackageKey,
                }
                table.insert(survey.Collectors, newDataCollector)
            end
        elseif collectorType == types.SurveyID then
            local newDataCollector = {
                collectorType = collectorType,
            }
            table.insert(survey.Collectors, newDataCollector)
        elseif collectorType == types.TextBlock then
            local text = ...
            
            local newDataCollector = {
                collectorType = collectorType,
                text = text,
            }
            table.insert(survey.Collectors, newDataCollector)
        end
    end
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.GetMessageKey()
    return PTR_IssueReporter.Data.Message_Key
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.RegisterEventToReport(tableToUse, survey, popEventType, eventArgument)    
    if (survey) and (popEventType) and (PTR_IssueReporter.ReportEventTypes[popEventType]) then
        if (eventArgument) then
            if (type(eventArgument) == "table") then
                for key, argument in pairs (eventArgument) do
                    tableToUse[popEventType][argument] = survey
                end
            else
                tableToUse[popEventType][eventArgument] = survey
            end
        else
            tableToUse.FallbackEvents[popEventType] = survey
        end
    end
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.AttachSurveyToFrameOnEvent(survey, frameToAttach, showPopEventType, hidePopEventType, xOffset, yOffset, point, relativePoint)
    if (survey) and (showPopEventType) and (PTR_IssueReporter.ReportEventTypes[showPopEventType]) and (hidePopEventType) then
        local framePopData = {
            xOffset = xOffset or 0,
            yOffset = yOffset or 0,
            point = point or "TOP",
            relativePoint = relativePoint or "BOTTOM",
            survey = survey,
            endEvent = hidePopEventType,
            frame = frameToAttach,
        }
        
        PTR_IssueReporter.Data.RegisteredFrameAttachedEvents[showPopEventType] = framePopData
    end
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.RegisterFunctionToEvent(event, func)
    if (PTR_IssueReporter.ReportEventTypes[event]) and (func) then
        table.insert(PTR_IssueReporter.Data.RegisteredEventFunctions[event], func)
    end
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.AddMapToSuppressedList(suppressedMapID)
    if (suppressedMapID) and (type(suppressedMapID) == "table") then
        for key, mapID in pairs (suppressedMapID) do
            PTR_IssueReporter.Data.SuppressedLocations[mapID] = true
        end
    elseif (suppressedMapID) then
        PTR_IssueReporter.Data.SuppressedLocations[suppressedMapID] = true
    end
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.HandleMapEvents()
    local mapID = select(4, UnitPosition(PTR_IssueReporter.Data.UnitTokens.Player)) or 0
    local difficultyID = select(3, GetInstanceInfo()) or 0
    
    if not (PTR_IssueReporter.Data.CurrentMapID == mapID) then
        PTR_IssueReporter.Data.PreviousMapID = PTR_IssueReporter.Data.CurrentMapID
        PTR_IssueReporter.Data.PreviousMapDifficultyID = PTR_IssueReporter.Data.CurrentMapDifficultyID
        PTR_IssueReporter.Data.PreviousMapName = PTR_IssueReporter.Data.CurrentMapName
        
        PTR_IssueReporter.Data.CurrentMapID = mapID
        PTR_IssueReporter.Data.CurrentMapDifficultyID = difficultyID
        
        local bestMapForUnit = (C_Map.GetBestMapForUnit(PTR_IssueReporter.Data.UnitTokens.Player))
        if (bestMapForUnit) then
            PTR_IssueReporter.Data.CurrentMapName = C_Map.GetMapInfo(bestMapForUnit)["name"]
        elseif (MinimapZoneText) then
            PTR_IssueReporter.Data.CurrentMapName = MinimapZoneText:GetText()
        end
        
        local currentMapDataPackage = {
            ID = PTR_IssueReporter.Data.CurrentMapID,
            DifficultyID = PTR_IssueReporter.Data.CurrentMapDifficultyID,
            Name = PTR_IssueReporter.Data.CurrentMapName,
        }
        
        local previousMapDataPackage = {
            ID = PTR_IssueReporter.Data.PreviousMapID,
            DifficultyID = PTR_IssueReporter.Data.PreviousMapDifficultyID,
            Name = PTR_IssueReporter.Data.PreviousMapName,
        }       
        
        PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.MapIDExit, PTR_IssueReporter.Data.PreviousMapID, previousMapDataPackage)
        PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.MapIDEnter, PTR_IssueReporter.Data.CurrentMapID, currentMapDataPackage)
        PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.MapDifficultyIDEnded, PTR_IssueReporter.Data.PreviousMapDifficultyID, previousMapDataPackage)
        PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.MapDifficultyIDStarted, PTR_IssueReporter.Data.CurrentMapDifficultyID, currentMapDataPackage)        
    end
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.TriggerEvent(event, eventArgument, dataPackage)
    --  Standalone Popped Surveys
    if not (PTR_IssueReporter.Data.SuppressedLocations[PTR_IssueReporter.Data.CurrentMapID]) then  -- Don't pop events in suppressed locations, to ensure we aren't interrupting gameplay
        if (PTR_IssueReporter.Data.RegisteredSurveys[event]) and (PTR_IssueReporter.Data.RegisteredSurveys[event][eventArgument]) then
            PTR_IssueReporter.QueueStandaloneSurvey(event, PTR_IssueReporter.Data.RegisteredSurveys[event][eventArgument], dataPackage)
        elseif (PTR_IssueReporter.Data.RegisteredSurveys.FallbackEvents[event]) then
            PTR_IssueReporter.QueueStandaloneSurvey(event, PTR_IssueReporter.Data.RegisteredSurveys.FallbackEvents[event], dataPackage)
        end
    end
    
    -- Context Button    
    if (PTR_IssueReporter.Data.RegisteredButtonEvents[event]) then
        local survey = PTR_IssueReporter.Data.RegisteredButtonEvents[event][eventArgument]
        
        if not(survey) then
            survey = PTR_IssueReporter.Data.RegisteredButtonEvents.FallbackEvents[event]
        end

        if (survey) then 
            local surveyTitle = PTR_IssueReporter.GetTitleFromSurvey(survey, dataPackage)
            survey:RegisterPopEvent(PTR_IssueReporter.ReportEventTypes.UIButtonClicked, surveyTitle)
            PTR_IssueReporter.SetBugButtonContext(surveyTitle, survey.Tooltip, survey.Icon)
            PTR_IssueReporter.Data.ButtonDataPackage = dataPackage
        end
    end
    
    -- End Context Button
    if (PTR_IssueReporter.Data.RegisteredButtonEndEvents[event]) then
        local survey = PTR_IssueReporter.Data.RegisteredButtonEndEvents[event][eventArgument]
        local fallbackSurvey = PTR_IssueReporter.Data.RegisteredButtonEndEvents.FallbackEvents[event]
        if (survey) then
            PTR_IssueReporter.SetBugButtonContext()
        elseif (fallbackSurvey) then
            PTR_IssueReporter.SetBugButtonContext()
        end
    end
    
    -- Frame Attached Surveys
    if (PTR_IssueReporter.Data.RegisteredFrameAttachedEvents[event]) then
        PTR_IssueReporter.PopFrameAttachedSurvey(PTR_IssueReporter.Data.RegisteredFrameAttachedEvents[event], dataPackage)
    end
    
    -- Registered Functions
    if (PTR_IssueReporter.Data.RegisteredEventFunctions[event]) then
        for key, func in pairs (PTR_IssueReporter.Data.RegisteredEventFunctions[event]) do
            func()
        end
    end    
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.HandleTooltipKeypress()
    if (PTR_IssueReporter.CurrentTooltipSurvey) and (PTR_IssueReporter.CurrentTooltipSurvey.Survey) and (PTR_IssueReporter.CurrentTooltipSurvey.DataPackage) then
        PTR_IssueReporter.QueueStandaloneSurvey(PTR_IssueReporter.ReportEventTypes.Tooltip, PTR_IssueReporter.CurrentTooltipSurvey.Survey, PTR_IssueReporter.CurrentTooltipSurvey.DataPackage)
    end
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.QueueStandaloneSurvey(event, survey, dataPackage)
    if (IsOnGlueScreen() or event == PTR_IssueReporter.ReportEventTypes.UIButtonClicked) or (event == PTR_IssueReporter.ReportEventTypes.Tooltip) then -- These event types warrant an immediate pop due to them being prompted from the player, the rest should be delayed until combat ends since their are prompted from game state
        PTR_IssueReporter.PopStandaloneSurvey(survey, dataPackage)
    else
        table.insert(PTR_IssueReporter.Data.PopSurveyQueue, {survey = survey, dataPackage = dataPackage})
    end
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.CheckSurveyQueue()
    local numberOfQueuedSurveys = #PTR_IssueReporter.Data.PopSurveyQueue
    if (not UnitAffectingCombat(PTR_IssueReporter.Data.UnitTokens.Player)) and (numberOfQueuedSurveys > 0) and (not PTR_IssueReporter.GetStandaloneSurveyFrame():IsVisible()) then
        local survey = PTR_IssueReporter.Data.PopSurveyQueue[numberOfQueuedSurveys].survey
        local dataPackage = PTR_IssueReporter.Data.PopSurveyQueue[numberOfQueuedSurveys].dataPackage
        PTR_IssueReporter.PopStandaloneSurvey(survey, dataPackage)
        PTR_IssueReporter.Data.PopSurveyQueue[numberOfQueuedSurveys] = nil
    end
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.GetTitleFromSurvey(survey, dataPackage)
    local titleString = ""
    
    if (#survey.DynamicTitleTokens > 0) then
        local titleTokens = {}
        
        for key, dynamicTitleToken in pairs (survey.DynamicTitleTokens) do
            local tokenString = ""
            if (dynamicTitleToken.key) then
                local dataPackageValue = dataPackage[dynamicTitleToken.key]
                if (dataPackageValue) then
                    if(dynamicTitleToken.func) and (type(dynamicTitleToken.func) == "function") then
                        tokenString = dynamicTitleToken.func(dataPackageValue)
                    elseif (type(dataPackageValue) == "string") then
                        tokenString = dataPackageValue
                    end
                end
            end
            
            table.insert(titleTokens, tokenString)
        end
        test = titleTokens
        titleString = string.format(survey.Title, unpack(titleTokens))
    elseif (survey.Title) then
        titleString = survey.Title
    end
    
    return titleString
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.BuildSurveyFrameFromSurveyData(surveyFrame, survey, dataPackage)
    
    PTR_IssueReporter.CleanReportFrame(surveyFrame)
    
    local types = PTR_IssueReporter.DataCollectorTypes
    local collectedString = ""
    local totalFrameHeight = 0
    
    if (survey.ModelViewerData) then
        PTR_IssueReporter.AttachModelViewer(surveyFrame, survey, dataPackage)
    end
    
    if (survey.IconViewerData) then
        PTR_IssueReporter.AttachIconViewer(surveyFrame, survey, dataPackage)
    end
    
    for key, collector in pairs (survey.Collectors) do   
        local newString = "" 
        local skipExpandingString = false
        if (collector.collectorType == types.RunFunction) then
            if (collector.collectorFunction) and (type(collector.collectorFunction) == "function") then
                newString = collector.collectorFunction(dataPackage)
            end
        elseif (collector.collectorType == types.FromDataPackage) then
            local data = tostring(dataPackage[collector.dataPackageKey])
            if (data) then
                newString = data
            end
        elseif (collector.collectorType == types.OpenEndedQuestion) then
            PTR_IssueReporter.AttachStandaloneQuestion(surveyFrame, collector.question, collector.characterLimit)
            newString = "%s"
        elseif (collector.collectorType == types.SelectOne_MultipleChoiceQuestion) or (collector.collectorType == types.SelectMultiple_MultipleChoiceQuestion) then
            PTR_IssueReporter.AttachMultipleChoiceQuestion(surveyFrame, collector.question, collector.choices, (collector.collectorType == types.SelectMultiple_MultipleChoiceQuestion), collector.displayVertically)
            newString = "%s"
        elseif (collector.collectorType == types.SurveyID) then
            newString = survey.ID
        elseif (collector.collectorType == types.TextBlock) then
            PTR_IssueReporter.AttachTextBlock(surveyFrame, collector.text)
            skipExpandingString = true
        end
        
        if not (skipExpandingString) then
            if collectedString == "" then
                collectedString = string.format("%s", newString)
            else
                collectedString = string.format("%s,%s", collectedString, newString)
            end
        end
    end
    
    surveyFrame:SetHeight(surveyFrame.FrameHeight - PTR_IssueReporter.Data.FrameComponentMargin)
    surveyFrame.SurveyString = collectedString
    surveyFrame.CurrentSurvey = survey
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.PopFrameAttachedSurvey(framePopData, dataPackage)
    local RegisterAttachedFrameEndEvent = function(endEvent)
        if (PTR_IssueReporter.ReportEventTypes[endEvent]) then
            PTR_IssueReporter.RegisterFunctionToEvent(endEvent, function()
                PTR_IssueReporter.Data.FrameAttachedSurveyFrames[framePopData.frame]:SubmitBugReport()
            end)
        end
    end
    
    if (framePopData) and (framePopData.endEvent) and (framePopData.survey) and (framePopData.frame) and (framePopData.frame.IsShown) and (framePopData.frame:IsShown()) then
        if not (PTR_IssueReporter.Data.FrameAttachedSurveyFrames[framePopData.frame]) then
            PTR_IssueReporter.Data.FrameAttachedSurveyFrames[framePopData.frame] = PTR_IssueReporter.CreateSurveyFrame()           
            if (type(framePopData.endEvent) == "table") then
                for key, endEvent in pairs (framePopData.endEvent) do
                    RegisterAttachedFrameEndEvent(endEvent)
                end
            else
                RegisterAttachedFrameEndEvent(framePopData.endEvent)
            end            
        end
        
        local surveyFrame = PTR_IssueReporter.Data.FrameAttachedSurveyFrames[framePopData.frame]
        surveyFrame:Show()
        PTR_IssueReporter.BuildSurveyFrameFromSurveyData(surveyFrame, framePopData.survey, dataPackage)
        surveyFrame:SetPoint(framePopData.point, framePopData.frame, framePopData.relativePoint, framePopData.xOffset, framePopData.yOffset)
    end
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.PopStandaloneSurvey(survey, dataPackage)
    local standaloneSurveyFrame = PTR_IssueReporter.GetStandaloneSurveyFrame((survey.OnSubmitPoppedSurvey)) --survey.OnSubmitPoppedSurvey)    
    PTR_IssueReporter.BuildSurveyFrameFromSurveyData(standaloneSurveyFrame.SurveyFrame, survey, dataPackage)
    standaloneSurveyFrame:Hide() -- Makes sure that the OnShow function fires to ensure proper positioning
    standaloneSurveyFrame:Show()
    local sideInset = standaloneSurveyFrame.SurveyFrame:GetWidth() / 3
    local additionalInset = 10
    standaloneSurveyFrame:SetClampRectInsets(-sideInset, sideInset, additionalInset, -(standaloneSurveyFrame.SurveyFrame.FrameHeight + PTR_IssueReporter.Data.SubmitButtonHeight + additionalInset))
    
    standaloneSurveyFrame:SetLabelText(PTR_IssueReporter.GetTitleFromSurvey(survey, dataPackage))
end
----------------------------------------------------------------------------------------------------
local function PlayerEnteringWorldHandler()
    PTR_IssueReporter.Init()
    PTR_IssueReporter:UnregisterEvent("PLAYER_ENTERING_WORLD")  
    
    SLASH_PTRFEEDBACK1 = "/PTR"
    SLASH_PTRFEEDBACK2 = "/PTRFEEDBACK"
    SlashCmdList["PTRFEEDBACK"] = PTR_IssueReporter.SlashHandeler
end
if not(IsOnGlueScreen()) then
	PTR_IssueReporter:RegisterEvent("PLAYER_ENTERING_WORLD")  
	PTR_IssueReporter:SetScript("OnEvent", PlayerEnteringWorldHandler)
end

local function PlayerEnteringCharacterCustomization()
    if PTR_IssueReporter.ReportBug then
        PTR_IssueReporter:Show()
    else
        PTR_IssueReporter.GlueInit()
    end
end

local function CustomizationScreenExit()
    PTR_IssueReporter:Hide()
end

if IsOnGlueScreen() then
    CharCustomizeFrame:HookScript("OnShow", PlayerEnteringCharacterCustomization)
    CharCustomizeFrame:HookScript("OnHide", CustomizationScreenExit)
end
----------------------------------------------------------------------------------------------------