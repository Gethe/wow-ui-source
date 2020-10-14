----------------------------------------------------------------------------------------------------
local PTR_Event_Frame = CreateFrame("Frame")
PTR_IssueReporter.ReportEventTypes = {
    UIButtonClicked = "UIButtonClicked",
    GameMenuFrameOpened = "GameMenuFrameOpened",
    GameMenuButtonQuit = "GameMenuButtonQuit",
    GameMenuButtonLogout = "GameMenuButtonLogout",
    GameMenuFrameClosed = "GameMenuFrameClosed",
}

----------------------------------------------------------------------------------------------------
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