----------------------------------------------------------------------------------------------------
local PTR_Event_Frame = CreateFrame("Frame")
PTR_IssueReporter.ReportEventTypes = {
    UIButtonClicked = "UIButtonClicked",
    GameMenuFrameOpened = "GameMenuFrameOpened",
    GameMenuButtonQuit = "GameMenuButtonQuit",
    GameMenuButtonLogout = "GameMenuButtonLogout",
    GameMenuFrameClosed = "GameMenuFrameClosed",
    CharacterCustomizationShow = "CharacterCustomizationShow",
    CharacterCustomizationHide = "CharacterCustomizationHide",
    WarbandsShow = "WarbandsShow",
    WarbandsHide = "WarbandsHide",
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

local function PlayerEnteringCharacterCustomization()
    PTR_IssueReporter:Show()
    PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.CharacterCustomizationShow)
end

local function CustomizationScreenExit()
    PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.CharacterCustomizationHide)
    PTR_IssueReporter:Hide()
end

local function WarbandsShow()
    PTR_IssueReporter:Show()
    PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.WarbandsShow)
end

local function WarbandsHide()
    PTR_IssueReporter.TriggerEvent(PTR_IssueReporter.ReportEventTypes.WarbandsHide)
    PTR_IssueReporter:Hide()
end

if IsOnGlueScreen() then
    -- Temporarily hiding until functionality built properly
    CharCustomizeFrame:HookScript("OnShow", PlayerEnteringCharacterCustomization)
    CharCustomizeFrame:HookScript("OnHide", CustomizationScreenExit)
    
    if (CharacterSelectMapScene) then
        CharacterSelectMapScene:HookScript("OnShow", WarbandsShow)
        CharacterSelectMapScene:HookScript("OnHide", WarbandsHide)
    end
end

PTR_IssueReporter.GlueInit()
PTR_IssueReporter:Hide()