local isGMClient = IsGMClient()
local PTR_IssueReporter = CreateFrame("Frame", nil, UIParent)

function PTR_IssueReporter.Init()
    Blizzard_PTRIssueReporter_Saved = Blizzard_PTRIssueReporter_Saved or {}
    --------------------------------------------------ALWAYS DISPLAYED BUTTONS--------------------------------------------------
    local IgnoreLocations = {
        1813, -- Un'gol Ruins (Islands 1)
        1814, -- Havenswood (Islands 2)
        1907, -- Snowblossom Village (Islands 3)
        1893, -- The Dread Chain (Islands 4)
        1898, -- Skittering Hollow (Islands 5)
        1897, -- Molten Cay (Islands 6)
        1879, -- Jorundall (Islands 7)
        1882, -- Verdant Wilds (Islands 8)
        1892, -- The Rotting Mire (Islands 9)
        1883, -- Whispering Reef (Islands 10)
    }

    PTR_IssueReporter.Body = CreateFrame("Frame", nil, PTR_IssueReporter)
    PTR_IssueReporter.Data = {
        targetQuests = {
            --if this list remains empty it will ask on every quest, otherwise only those specified by ID
        },
        bossKillProbabilityPopup = 100, --from 0 to 100 percent
        throttleSubmitTime = 5, --seconds since last sending a feedback update
        AlertQueueSize = 3,
        QuestHistorySize = 5,
        npcAlertQuestion = "Did you experience any bugs with this enemy?",
        watermark = "Interface\\FrameGeneral\\UI-Background-TestWatermark",
        textureFile = "Interface\\FrameGeneral\\UI-Background-Marble",
        textureFile2 = "Interface\\FrameGeneral\\UI-Background-Marble",
        pushedTexture = "Interface\\Buttons\\UI-Quickslot-Depress",
        fontString = "GameFontNormal",
        confusedIcon = "Interface\\TutorialFrame\\TutorialFrame-QuestionMark",
        bugreport = "Interface\\HelpFrame\\HelpIcon-Bug.blp",
        bossreport = "Interface\\HelpFrame\\HelpIcon-Bug-Red",
        height = 50,
        lastSubmitTime,
        unitToken = "player",
        targetToken = "target",
        bossToken = "boss1",
        alertFrameText = "Did you experience any bugs with this creature?",
        bossBugButtonText = "Bug & Feedback - %s",
        bossMouseoverText = "I have encountered a bug or want to submit feedback for %s.",
        bugMouseoverText = "I have encountered a bug.",
        SELF_REPORTED_CONFUSED = 1,
        SELF_REPORTED_BUG = 2,
        BOSS_KILL = 3,
        QUEST_TURNED_IN = 4,
        ISLANDS = 5,
        WARFRONTS = 6,
        MESSAGE_KEY = "[&#@^$M*]",
        Thanks = "Your bug has been received.",
        SubmitText = "Submit Bug",
    }
    PTR_IssueReporter.TriggerEvents = {
        [1] = {enabled = true, label = "Confused Report", question = "", checkboxes = {}},
        [2] = {enabled = true, label = "Bug Report", question = "", checkboxes = {}},
        [5] = {enabled = true, label = "Island Expedition", question = "Did you experience any bugs with this Island Expedition?", checkboxes = {"Yes", "No"}},
        [6] = {enabled = true, label = "Warfront", question = "Did you experience any bugs with this Warfront?", checkboxes = {"Yes", "No"}},
    }
    PTR_IssueReporter.BossTriggeredTimerDuration = 600 -- how long the Boss Bug button will remain active after a failed boss encounter pull
    PTR_IssueReporter.BossBugTriggered = GetTime()

    function PTR_IssueReporter.Reminder(enable, ...)
        if (not Blizzard_PTRIssueReporter_Saved.sawHighlight) then
            for k,v in pairs({...}) do
                if (enable) then
                    ActionButton_ShowOverlayGlow(v)
                else
                    ActionButton_HideOverlayGlow(v)
                end
            end
            if (not enable) then
                Blizzard_PTRIssueReporter_Saved.sawHighlight = true
            end
        end
    end

    function PTR_IssueReporter.CreateIssueButton(name, icon, tooltip, func)
        local scalar = PTR_IssueReporter.Body:GetHeight()
        local newbutton = CreateFrame("Button", name, PTR_IssueReporter)
        newbutton:SetSize(scalar, scalar)
        newbutton:SetHighlightTexture(icon, "ADD")
        newbutton:SetNormalTexture(icon)
        newbutton:SetPushedTexture(PTR_IssueReporter.Data.pushedTexture)
        FramePainter.AddBorder(newbutton)
        newbutton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
            GameTooltip:SetText(name, 1, 1, 1, true);
            GameTooltip:AddLine(tooltip, nil, nil, nil, true);
            GameTooltip:SetMinimumWidth(100);
            GameTooltip:Show()
        end)
        newbutton:SetScript("OnLeave", function(self)
            self:SetButtonState("NORMAL")
            GameTooltip:Hide()
        end)
        if (func) then
            newbutton:SetScript("OnClick", function(self, button, down)
                func()
            end)
        end
        newbutton:SetScript("OnHide", function(self)
            self:Show()
        end)
        return newbutton
    end
    
    function PTR_IssueReporter.SetupBugButton(bossName)
        if (bossName) then
            PTR_IssueReporter.BossBugTriggered = GetTime()
            if (PTR_IssueReporter.ReportBug.bossName ~= bossName) then
                PTR_IssueReporter.ReportBug.bossName = bossName
                PTR_IssueReporter.ReportBug:SetHighlightTexture(PTR_IssueReporter.Data.bossreport, "ADD")
                PTR_IssueReporter.ReportBug:SetNormalTexture(PTR_IssueReporter.Data.bossreport)
                
                local instanceName, instanceType, difficultyID, difficultyName, _ = GetInstanceInfo()
                local bossID = PTR_IssueReporter.AlertFrame.Classification[difficultyName][bossName]
                
                PTR_IssueReporter.ReportBug:SetScript("OnClick", function(self, button, down)
                    
                    PTR_IssueReporter.SetBossInfo(bossName, bossID, difficultyName)
                    PTR_IssueReporter.Data.alertFrameText = PTR_IssueReporter.Data.npcAlertQuestion
                    PTR_IssueReporter.AlertFrame:Show()
                    PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
                end)
                
                PTR_IssueReporter.ReportBug:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
                    GameTooltip:SetText(string.format(PTR_IssueReporter.Data.bossBugButtonText, bossName), 1, 1, 1, true);
                    GameTooltip:AddLine(string.format(PTR_IssueReporter.Data.bossMouseoverText, bossName), nil, nil, nil, true);
                    GameTooltip:SetMinimumWidth(100);
                    GameTooltip:Show()
                    end)
                PTR_IssueReporter.ReportBug:SetScript("OnLeave", function(self)
                    self:SetButtonState("NORMAL")
                    GameTooltip:Hide()
                end)
                
                PTR_IssueReporter.ReportBug:HookScript("OnEnter", function() ActionButton_HideOverlayGlow(PTR_IssueReporter.ReportBug) end)
                ActionButton_ShowOverlayGlow(PTR_IssueReporter.ReportBug)
            end
        else
            PTR_IssueReporter.ReportBug.bossName = nil
            PTR_IssueReporter.ReportBug:SetHighlightTexture(PTR_IssueReporter.Data.bugreport, "ADD")
            PTR_IssueReporter.ReportBug:SetNormalTexture(PTR_IssueReporter.Data.bugreport)
            
            PTR_IssueReporter.ReportBug:SetScript("OnClick", function(self, button, down)
                PTR_IssueReporter.PopEvent(PTR_IssueReporter.Data.SELF_REPORTED_BUG)
                PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
            end)
            
            PTR_IssueReporter.ReportBug:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
                GameTooltip:SetText("Bug", 1, 1, 1, true);
                GameTooltip:AddLine(PTR_IssueReporter.Data.bugMouseoverText, nil, nil, nil, true);
                GameTooltip:SetMinimumWidth(100);
                GameTooltip:Show()
                end)
            PTR_IssueReporter.ReportBug:SetScript("OnLeave", function(self)
                self:SetButtonState("NORMAL")
                GameTooltip:Hide()
            end)
            
            if (Blizzard_PTRIssueReporter_Saved.sawHighlight) then
                ActionButton_HideOverlayGlow(PTR_IssueReporter.ReportBug)
            end
            
            PTR_IssueReporter.ReportBug:HookScript("OnEnter", function() PTR_IssueReporter.Reminder(false, PTR_IssueReporter.Confused, PTR_IssueReporter.ReportBug) end)
        end
    end

    function PTR_IssueReporter.ExclusiveCheckButton(buttons, index)
        for i=1,#buttons do
            if (i == index) then
                buttons[i]:SetChecked(true)
            else
                buttons[i]:SetChecked(false)
            end
        end
        return index
    end

    function PTR_IssueReporter.SendResults(reportType, ...)
        --reset idle time
        local packageString = PTR_FeedbackDiagnostic:Get()
        local finalMessage = string.format('%s,%s,%s', PTR_IssueReporter.Data.MESSAGE_KEY or "", reportType or "", packageString or "")
        if (reportType == PTR_IssueReporter.Data.BOSS_KILL) then
            local choice, bossName, bossID, bossDifficulty, comments = ...
            bossName = bossName:gsub(",", " ")
            bossDifficulty = bossDifficulty:gsub(",", " ")
            comments = comments:gsub(","," ")
            finalMessage = string.format('%s,%s,%s,%s,%s,%s', finalMessage or "", choice or "", bossName or "", bossID or "", bossDifficulty or "", comments or "")
        elseif (reportType == PTR_IssueReporter.Data.QUEST_TURNED_IN) then
            local choice, questID, comments, history = ...
            comments = comments:gsub(","," ")
            finalMessage = string.format('%s,%s,%s,%s,%s', finalMessage or "", choice or "", questID or "", comments or "", history or "")
        elseif (PTR_IssueReporter.TriggerEvents[reportType]) then
            local choice, instanceID, comments = ...
            comments = comments:gsub(","," ")
            if (reportType == PTR_IssueReporter.Data.SELF_REPORTED_CONFUSED) or (reportType == PTR_IssueReporter.Data.SELF_REPORTED_BUG) then
                finalMessage = string.format('%s,%s', finalMessage or "", comments or "")
            else
                finalMessage = string.format('%s,%s,%s,%s', finalMessage or "", choice or "", instanceID or "", comments or "")
            end
        else
            local comments = ...
            comments = comments:gsub(","," ")
            finalMessage = string.format('%s,%s', finalMessage or "", comments or "")
        end

        if (GMSubmitBug) then
            GMSubmitBug(finalMessage)
            UIErrorsFrame:Clear()
        end
        return finalMessage
    end

    --cosmetics
    PTR_IssueReporter:Hide()
    PTR_IssueReporter:SetScript("OnShow", function(self)
        PTR_IssueReporter:ClearAllPoints()
        if (Blizzard_PTRIssueReporter_Saved.x and Blizzard_PTRIssueReporter_Saved.y) then
            PTR_IssueReporter:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", Blizzard_PTRIssueReporter_Saved.x, Blizzard_PTRIssueReporter_Saved.y)
        else
            PTR_IssueReporter:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, UIParent:GetHeight()*0.25)
        end
    end)
    PTR_IssueReporter:SetFrameStrata("HIGH")
    PTR_IssueReporter.text = PTR_IssueReporter:CreateFontString("CheckListText", "OVERLAY", PTR_IssueReporter.Data.fontString)
    PTR_IssueReporter.text:SetWidth(PTR_IssueReporter:GetWidth())
    PTR_IssueReporter.text:SetHeight(PTR_IssueReporter:GetHeight())
    PTR_IssueReporter.text:SetPoint("CENTER", PTR_IssueReporter, "CENTER", 0, 0)
    PTR_IssueReporter.text:SetText("Bug\nReporter")
    PTR_IssueReporter:SetSize(PTR_IssueReporter.text:GetStringWidth()*1.5,32)
    FramePainter.AddBorder(PTR_IssueReporter)
    PTR_IssueReporter.Body:SetSize(PTR_IssueReporter:GetWidth(), PTR_IssueReporter.Data.height)
    PTR_IssueReporter.Body:SetPoint("TOP", PTR_IssueReporter, "BOTTOM", 0, PTR_IssueReporter:GetHeight()*0.05)
    FramePainter.AddBackground(PTR_IssueReporter, PTR_IssueReporter.Data.textureFile2)

    PTR_IssueReporter:SetScript("OnEnter", function(self)
        SetCursor("Interface\\CURSOR\\UI-Cursor-Move.blp")
    end)
    PTR_IssueReporter:SetScript("OnLeave", function(self)
        ResetCursor()
    end)

    PTR_IssueReporter:SetScript("OnUpdate", function(self, elapsed)
        PTR_IssueReporter.Data.lastSubmitTime = PTR_IssueReporter.Data.lastSubmitTime or 0
        if (PTR_IssueReporter.Data.lastSubmitTime > 0) then
            PTR_IssueReporter.Data.lastSubmitTime = PTR_IssueReporter.Data.lastSubmitTime - elapsed
        end
    end)

    --information button
    FramePainter.AddInfoButton(PTR_IssueReporter)
    FramePainter.AddTooltip(PTR_IssueReporter.InfoButton,
        "How Can I Help?",
        "|cffFFFFFFPlease Provide:|r\n-What you were doing\n-What you observed\n\n|cffFFFFFFAutomatically Collected:|r\n-Your world location\n-Your character information")

    --create buttons
    PTR_IssueReporter.Confused = PTR_IssueReporter.CreateIssueButton("Confused",
        PTR_IssueReporter.Data.confusedIcon,
        "I'm not sure what I should do\nand/or where I should go.")
    PTR_IssueReporter.ReportBug = PTR_IssueReporter.CreateIssueButton("Bug",
        PTR_IssueReporter.Data.bugreport,
        PTR_IssueReporter.Data.bugMouseoverText)
    

    PTR_IssueReporter.Confused:SetScript("OnClick", function(self, button, down)
        PTR_IssueReporter.PopEvent(PTR_IssueReporter.Data.SELF_REPORTED_CONFUSED)
        PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
    end)


    PTR_IssueReporter.Confused:HookScript("OnEnter", function() PTR_IssueReporter.Reminder(false, PTR_IssueReporter.Confused, PTR_IssueReporter.ReportBug) end)
    PTR_IssueReporter.ReportBug:HookScript("OnEnter", function() PTR_IssueReporter.Reminder(false, PTR_IssueReporter.Confused, PTR_IssueReporter.ReportBug) end)

    PTR_IssueReporter.ReportBug:SetPoint("TOPLEFT", PTR_IssueReporter.Body, "TOP", 2, -6)
    PTR_IssueReporter.Confused:SetPoint("TOPRIGHT", PTR_IssueReporter.Body, "TOP", -2, -6)
    PTR_IssueReporter.Body.Texture = PTR_IssueReporter.Body:CreateTexture()
    PTR_IssueReporter.Body.Texture:SetTexture(PTR_IssueReporter.Data.textureFile)
    PTR_IssueReporter.Body.Texture:SetPoint("TOPLEFT", PTR_IssueReporter.Confused, "TOPLEFT")
    PTR_IssueReporter.Body.Texture:SetPoint("BOTTOMRIGHT", PTR_IssueReporter.ReportBug, "BOTTOMRIGHT")
    PTR_IssueReporter.Body.Texture:SetDrawLayer("BACKGROUND")

    --behaviors
    FramePainter.AddDrag(PTR_IssueReporter)
    PTR_IssueReporter:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local left, bottom, width, height = self:GetRect()
        Blizzard_PTRIssueReporter_Saved.x = left
        Blizzard_PTRIssueReporter_Saved.y = bottom
        PTR_IssueReporter.Reminder(false, PTR_IssueReporter.Confused, PTR_IssueReporter.ReportBug)
    end)
    PTR_IssueReporter:SetScript("OnHide", function(self)
        self:Show()
    end)

    --timers/reminders/notifications, only one time ever on login
    C_Timer.After(1, function(self) PTR_IssueReporter.Reminder(true, PTR_IssueReporter.Confused, PTR_IssueReporter.ReportBug) end)

    --------------------------------------------------ALWAYS DISPLAYED BUTTONS--------------------------------------------------
    --========================================================================================================================--

    --========================================================================================================================--
    ------------------------------------------------BOSS KILL / RARE KILL PROMPT------------------------------------------------

    PTR_IssueReporter.AlertFrame = CreateFrame("Frame", "PTRIssueReporterAlertFrame", UIParent)
    PTR_IssueReporter.AlertFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 16, -116)
    PTR_IssueReporter.AlertFrame:SetSize(338, 496)
    PTR_IssueReporter.AlertFrame.TitleBox = CreateFrame("Frame", nil, PTR_IssueReporter.AlertFrame)
    PTR_IssueReporter.AlertFrame.TitleBox:SetPoint("BOTTOM", PTR_IssueReporter.AlertFrame, "TOP", 0, 2)
    PTR_IssueReporter.AlertFrame.TitleBox.text = PTR_IssueReporter.AlertFrame.TitleBox:CreateFontString("CheckListText", "OVERLAY", PTR_IssueReporter.Data.fontString)
    PTR_IssueReporter.AlertFrame.TitleBox.text:SetWidth(PTR_IssueReporter.AlertFrame.TitleBox:GetWidth())
    PTR_IssueReporter.AlertFrame.TitleBox.text:SetHeight(PTR_IssueReporter.AlertFrame.TitleBox:GetHeight())
    PTR_IssueReporter.AlertFrame.TitleBox.text:SetPoint("CENTER", PTR_IssueReporter.AlertFrame.TitleBox, "CENTER", 0, 0)
    PTR_IssueReporter.AlertFrame.TitleBox.text:SetText("Bug Reporter")

    PTR_IssueReporter.AlertFrame.TitleBox:SetSize(PTR_IssueReporter.AlertFrame.TitleBox.text:GetWidth()*1.5, PTR_IssueReporter.AlertFrame.TitleBox.text:GetHeight()*2)
    FramePainter.AddBackground(PTR_IssueReporter.AlertFrame.TitleBox, PTR_IssueReporter.Data.textureFile2)
    FramePainter.AddBorder(PTR_IssueReporter.AlertFrame.TitleBox)
    FramePainter.AddBorder(PTR_IssueReporter.AlertFrame)
    FramePainter.AddBackground(PTR_IssueReporter.AlertFrame, PTR_IssueReporter.Data.watermark)
    PTR_IssueReporter.AlertFrame.ClassByID = {}

    --info button
    FramePainter.AddInfoButton(PTR_IssueReporter.AlertFrame)
    FramePainter.AddTooltip(PTR_IssueReporter.AlertFrame.InfoButton,
        "Enemy bug examples",
        "This enemy hit too hard.\nThis enemy could not be hit.\nI couldn't find this enemy.\nThis enemy never moved.",
        "ANCHOR_BOTTOMRIGHT",
        PTR_IssueReporter.AlertFrame:GetWidth() - 2*PTR_IssueReporter.AlertFrame.InfoButton:GetWidth())
    --check buttons
    PTR_IssueReporter.AlertFrame.CheckButtons = {}
    --queue list
    PTR_IssueReporter.AlertFrame.Queue = {}
    PTR_IssueReporter.AlertFrame.Classification = {}
    PTR_IssueReporter.AlertFrame.Defeated = {}
    PTR_IssueReporter.AlertFrame.Choice = 0
    --model frame
    PTR_IssueReporter.AlertFrame.CreatureID = 12435
    PTR_IssueReporter.AlertFrame.Name = "Razorgore the Untamed"
    PTR_IssueReporter.AlertFrame.Model = CreateFrame("PlayerModel", nil, PTR_IssueReporter.AlertFrame)
    PTR_IssueReporter.AlertFrame.Model:SetPoint("CENTER")
    PTR_IssueReporter.AlertFrame.Model:SetSize(PTR_IssueReporter.AlertFrame:GetWidth()*0.9, PTR_IssueReporter.AlertFrame:GetHeight()*(2/3))
    PTR_IssueReporter.AlertFrame.Model:SetCreature(PTR_IssueReporter.AlertFrame.CreatureID)
    --model/name/location
    PTR_IssueReporter.AlertFrame.text = CreateFrame("Button", nil, PTR_IssueReporter.AlertFrame, "UIPanelButtonTemplate")
    PTR_IssueReporter.AlertFrame.text:SetButtonState("NORMAL", true)
    PTR_IssueReporter.AlertFrame.text:SetNormalTexture(PTR_IssueReporter.Data.textureFile2)
    PTR_IssueReporter.AlertFrame.text:EnableMouse(false)
    PTR_IssueReporter.AlertFrame.text:SetPoint("TOP", PTR_IssueReporter.AlertFrame, "TOP", 0, -15)
    PTR_IssueReporter.AlertFrame.text:SetText(PTR_IssueReporter.Data.npcAlertQuestion)
    PTR_IssueReporter.AlertFrame.text:SetSize(math.min(PTR_IssueReporter.AlertFrame.text:GetTextWidth()*1.5, PTR_IssueReporter.AlertFrame:GetWidth()*0.9), 40)
    FramePainter.AddBorder(PTR_IssueReporter.AlertFrame.text)
    --close button
    PTR_IssueReporter.AlertFrame.CloseButton = CreateFrame("Button", nil, PTR_IssueReporter.AlertFrame, "UIPanelCloseButton")
    PTR_IssueReporter.AlertFrame.CloseButton:SetPoint("CENTER", PTR_IssueReporter.AlertFrame, "TOPRIGHT")
    PTR_IssueReporter.AlertFrame.CloseButton:SetScript("OnHide", function(self)
        PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
    end)
    table.insert(UISpecialFrames, PTR_IssueReporter.AlertFrame:GetName())
    --text
    PTR_IssueReporter.AlertFrame.Title = PTR_IssueReporter.AlertFrame:CreateFontString("CheckListText", "OVERLAY", PTR_IssueReporter.Data.fontString)
    PTR_IssueReporter.AlertFrame.Title:SetText(PTR_IssueReporter.AlertFrame.Name)
    PTR_IssueReporter.AlertFrame.Title:SetSize(PTR_IssueReporter.AlertFrame.Title:GetStringWidth(), PTR_IssueReporter.AlertFrame.Title:GetStringHeight()*2)
    PTR_IssueReporter.AlertFrame.Title:SetPoint("TOP", PTR_IssueReporter.AlertFrame.text, "BOTTOM", 0, -8)

    PTR_IssueReporter.AlertFrame:SetScript("OnUpdate", function(self, elapsed)
        PTR_IssueReporter.AlertFrame.Timer = (PTR_IssueReporter.AlertFrame.Timer or 0) + elapsed
        if (PTR_IssueReporter.AlertFrame.Timer > math.pi*2) then
            PTR_IssueReporter.AlertFrame.Timer = 0
        end
        PTR_IssueReporter.AlertFrame.Model:SetRotation(PTR_IssueReporter.AlertFrame.Timer)
    end)

    PTR_IssueReporter.AlertFrame.SubmitButton = CreateFrame("Button", nil, PTR_IssueReporter.AlertFrame, "UIPanelButtonTemplate")
    PTR_IssueReporter.AlertFrame.SubmitButton:SetPoint("TOP", PTR_IssueReporter.AlertFrame, "BOTTOM")
    PTR_IssueReporter.AlertFrame.SubmitButton:SetText(PTR_IssueReporter.Data.SubmitText)
    PTR_IssueReporter.AlertFrame.SubmitButton:SetSize(PTR_IssueReporter.AlertFrame.SubmitButton:GetTextWidth()*1.5, 32)
    
    PTR_IssueReporter.AlertFrame:Hide()

    function PTR_IssueReporter.SetBossInfo(name, creatureId, difficulty)
        PTR_IssueReporter.AlertFrame.CreatureID = creatureId
        PTR_IssueReporter.AlertFrame.Name = name
        PTR_IssueReporter.AlertFrame.Difficulty = difficulty
        if (PTR_IssueReporter.AlertFrame.CreatureID) then
            PTR_IssueReporter.AlertFrame.Model:SetCreature(PTR_IssueReporter.AlertFrame.CreatureID)
        end
        if (#PTR_IssueReporter.AlertFrame.Difficulty == 0) then
            PTR_IssueReporter.AlertFrame.Title:SetText(string.format("%s", PTR_IssueReporter.AlertFrame.Name))
        else
            PTR_IssueReporter.AlertFrame.Title:SetText(string.format("(%s)\n%s", PTR_IssueReporter.AlertFrame.Difficulty, PTR_IssueReporter.AlertFrame.Name))
        end
        PTR_IssueReporter.AlertFrame.Title:SetWidth(math.min(PTR_IssueReporter.AlertFrame.Title:GetStringWidth()*1.5, PTR_IssueReporter.AlertFrame:GetWidth()*0.9))
        PTR_IssueReporter.AlertFrame.Choice = PTR_IssueReporter.ExclusiveCheckButton(PTR_IssueReporter.AlertFrame.CheckButtons, 0)
        PTR_IssueReporter.AlertFrame.Model:SetAnimation(190)
    end

    function PTR_IssueReporter.PushNextBoss()
        --in combat fail
        if (UnitAffectingCombat(PTR_IssueReporter.Data.unitToken)) then
            return
        end
        if (#PTR_IssueReporter.AlertFrame.Queue <= 0) then
            --no bosses to push
            if (PTR_IssueReporter.AlertFrame:IsShown()) then
                PTR_IssueReporter.AlertFrame.hideFromCombat = true
                PTR_IssueReporter.AlertFrame:Hide()
            end
        else
            --take the first boss and set it if not flagged
            PTR_IssueReporter.SetBossInfo(PTR_IssueReporter.AlertFrame.Queue[#PTR_IssueReporter.AlertFrame.Queue].name,
                PTR_IssueReporter.AlertFrame.Queue[#PTR_IssueReporter.AlertFrame.Queue].id,
                PTR_IssueReporter.AlertFrame.Queue[#PTR_IssueReporter.AlertFrame.Queue].difficulty)
            PTR_IssueReporter.Data.alertFrameText = PTR_IssueReporter.Data.npcAlertQuestion
            PTR_IssueReporter.AlertFrame:Show()
        end
    end

    function PTR_IssueReporter.FlagDefeated() --if a user has submitted feedback on a boss already, don't ask again
        local lastBoss = PTR_IssueReporter.AlertFrame.Name
        local difficultyID = PTR_IssueReporter.AlertFrame.Difficulty
        PTR_IssueReporter.AlertFrame.Defeated[difficultyID] = PTR_IssueReporter.AlertFrame.Defeated[difficultyID] or {}
        PTR_IssueReporter.AlertFrame.Defeated[difficultyID][lastBoss] = true
    end

    function PTR_IssueReporter.ClearNextBoss()
        PTR_IssueReporter.AlertFrame.Queue[#PTR_IssueReporter.AlertFrame.Queue] = nil
        --also clean up any flagged bosses here
        for i=#PTR_IssueReporter.AlertFrame.Queue,1,-1 do
            local isDefeated = PTR_IssueReporter.AlertFrame.Defeated[PTR_IssueReporter.AlertFrame.Queue[i].difficulty] or {}
            if (isDefeated[PTR_IssueReporter.AlertFrame.Queue[i].name]) then
                PTR_IssueReporter.AlertFrame.Queue[i] = nil
            end
        end
    end

    function PTR_IssueReporter.AddBoss(name, creatureId, difficultyName)
        local roll = math.random(0, 99)
        if (roll < PTR_IssueReporter.Data.bossKillProbabilityPopup) then
            if (#PTR_IssueReporter.AlertFrame.Queue >= PTR_IssueReporter.Data.AlertQueueSize) then
                --push out the first one
                local numAhead = 1 + (#PTR_IssueReporter.AlertFrame.Queue - PTR_IssueReporter.Data.AlertQueueSize)
                local numIterations = PTR_IssueReporter.Data.AlertQueueSize - 1
                for i = 1, numIterations do
                    PTR_IssueReporter.AlertFrame.Queue[i] = PTR_IssueReporter.AlertFrame.Queue[i+numAhead]
                end
                for i = #PTR_IssueReporter.AlertFrame.Queue, numIterations+1, -1 do
                    PTR_IssueReporter.AlertFrame.Queue[i] = nil
                end
            end
            table.insert(PTR_IssueReporter.AlertFrame.Queue, {name = name, id = creatureId, difficulty = difficultyName})
        end
    end
    
    function PTR_IssueReporter.CheckValidLocation(searchedArray, currentLocation)
        for index, value in ipairs(searchedArray) do
            if value == currentLocation then
                return false
            end
        end
        return true
    end
    
    function PTR_IssueReporter.AddUnitIDToTracking(unitID, encounterName)
        if UnitExists(unitID) then
            local classid = UnitClassification(unitID)
            local name = encounterName or UnitName(unitID)
            local _,_,_,_,_,creatureID,guid = strsplit("-", UnitGUID(unitID) or "", 7)
            local instanceName, instanceType, difficultyID, difficultyName, _ = GetInstanceInfo()
            PTR_IssueReporter.AlertFrame.Classification[difficultyName] = PTR_IssueReporter.AlertFrame.Classification[difficultyName] or {}
            if (name and classid) then
                if (classid == "elite" or classid == "worldboss" or classid == "rare" or classid == "rareelite") and (not PTR_IssueReporter.AlertFrame.Classification[difficultyName][name]) then
                    PTR_IssueReporter.AlertFrame.Classification[difficultyName][name] = creatureID
                    PTR_IssueReporter.AlertFrame.ClassByID[creatureID] = classid
                end
            end
        end
    end
    
    function PTR_IssueReporter.DoesEncounterHaveID(encounterName)
        local instanceName, instanceType, difficultyID, difficultyName, _ = GetInstanceInfo()
        return ((PTR_IssueReporter.AlertFrame.Classification[difficultyName]) and (PTR_IssueReporter.AlertFrame.Classification[difficultyName][encounterName]))   
    end

    do
        PTR_IssueReporter.AlertFrame.CheckButtons[1] = FramePainter.NewCheckBox("CENTER", PTR_IssueReporter.AlertFrame, "BOTTOMLEFT", "Yes", PTR_IssueReporter.AlertFrame:GetWidth()*(1/3), 80)
        PTR_IssueReporter.AlertFrame.CheckButtons[2] = FramePainter.NewCheckBox("CENTER", PTR_IssueReporter.AlertFrame, "BOTTOMLEFT", "No", PTR_IssueReporter.AlertFrame:GetWidth()*(2/3), 80)

        PTR_IssueReporter.AlertFrame.AdditionalInfo = FramePainter.NewEditBox("BugAdditionalCommentsBossKill", "BOTTOM", PTR_IssueReporter.AlertFrame, "BOTTOM", "Additional Comments or Feedback?", PTR_IssueReporter.AlertFrame:GetWidth(), 40)
        FramePainter.AddBackground(PTR_IssueReporter.AlertFrame.AdditionalInfo, PTR_IssueReporter.Data.textureFile)
        --set scripts
        for i=1,#PTR_IssueReporter.AlertFrame.CheckButtons do
            PTR_IssueReporter.AlertFrame.CheckButtons[i]:SetScript("OnClick", function(self,button,down)
                PTR_IssueReporter.AlertFrame.Choice = PTR_IssueReporter.ExclusiveCheckButton(PTR_IssueReporter.AlertFrame.CheckButtons, i)
                PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
            end)
        end
    end

    PTR_IssueReporter.AlertFrame.SubmitButton:SetScript("OnClick", function(self, button, down)
        --close and submit
        if (PTR_IssueReporter.AlertFrame.Difficulty) then
            local commentField = PTR_IssueReporter.AlertFrame.AdditionalInfo:GetText()
            commentField = commentField:gsub(",", " ")
            PTR_IssueReporter.SendResults(PTR_IssueReporter.Data.BOSS_KILL, PTR_IssueReporter.AlertFrame.Choice, PTR_IssueReporter.AlertFrame.Name, PTR_IssueReporter.AlertFrame.CreatureID, PTR_IssueReporter.AlertFrame.Difficulty, commentField)
            --submit answers
            PTR_IssueReporter.FlagDefeated()
            PTR_IssueReporter.ClearNextBoss()
            PTR_IssueReporter.PushNextBoss()
            UIErrorsFrame:AddMessage(PTR_IssueReporter.Data.Thanks)
            PTR_IssueReporter.AlertFrame.Choice = PTR_IssueReporter.ExclusiveCheckButton(PTR_IssueReporter.AlertFrame.CheckButtons, 0)
            PTR_IssueReporter.AlertFrame.AdditionalInfo:SetText("")
        else
            PTR_IssueReporter.AlertFrame:Hide()
        end
        PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
    end)

    PTR_IssueReporter.AlertFrame:SetScript("OnShow", function(self)
        --init data
        PTR_IssueReporter.AlertFrame.text:SetText(PTR_IssueReporter.Data.alertFrameText)
        PTR_IssueReporter.AlertFrame.AdditionalInfo:SetText("")
        PTR_IssueReporter.AlertFrame.Choice = PTR_IssueReporter.ExclusiveCheckButton(PTR_IssueReporter.AlertFrame.CheckButtons, 0)
        PlaySound(620)
    end)

    PTR_IssueReporter.AlertFrame:SetScript("OnHide", function(self)
        --init data
        if (not PTR_IssueReporter.AlertFrame.hideFromCombat) then
            --clear bosses
            PTR_IssueReporter.FlagDefeated()
            PTR_IssueReporter.ClearNextBoss()
            PTR_IssueReporter.PushNextBoss()
        end
        PTR_IssueReporter.AlertFrame.hideFromCombat = false
    end)

    PTR_IssueReporter.AlertFrame:SetScript("OnEvent", function(self, event, ...)
        if (PTR_IssueReporter.ReportBug.bossName) then --If this exists then the Bug Reporter button is currently set to a Boss Mob
            if (GetTime() >= (PTR_IssueReporter.BossTriggeredTimerDuration + PTR_IssueReporter.BossBugTriggered)) then
                PTR_IssueReporter.SetupBugButton()
            end
        end
        if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
            local eventArgs = {...}
            if (CombatLogGetCurrentEventInfo) then
                eventArgs = {CombatLogGetCurrentEventInfo()}
            end
            local combatevent = eventArgs[2]
            if (combatevent == "PARTY_KILL") or (UnitControllingVehicle(PTR_IssueReporter.Data.unitToken) and combatevent == "UNIT_DIED") then
                local creatureName = eventArgs[9]
                local creatureID = eventArgs[8]
                local unittype,_,_,_,_,id,guid = strsplit("-",creatureID,7)
                local instanceName, instanceType, difficultyID, difficultyName, _ = GetInstanceInfo()
                --key by difficulty
                PTR_IssueReporter.AlertFrame.Classification[difficultyName] = PTR_IssueReporter.AlertFrame.Classification[difficultyName] or {}
                PTR_IssueReporter.AlertFrame.Defeated[difficultyName] = PTR_IssueReporter.AlertFrame.Defeated[difficultyName] or {}
                if (PTR_IssueReporter.AlertFrame.Classification[difficultyName][creatureName]) then
                    if (not PTR_IssueReporter.AlertFrame.Defeated[difficultyName][creatureName]) then
                        if (PTR_IssueReporter.AlertFrame.ClassByID[id]) and (PTR_IssueReporter.AlertFrame.ClassByID[id] == "rare" or PTR_IssueReporter.AlertFrame.ClassByID[id] == "worldboss" or PTR_IssueReporter.AlertFrame.ClassByID[id] == "rareelite") then
                            if (PTR_IssueReporter.CheckValidLocation(IgnoreLocations, select(8,GetInstanceInfo()))) then
                                PTR_IssueReporter.AddBoss(creatureName, id, difficultyName)
                            end
                        end
                    end
                end
            end
        elseif (event == "ENCOUNTER_END") then
            local eventArgs = {...}
            local bossname = eventArgs[2]
            if eventArgs[5] == 1 then -- Checking to see if the ENCOUNTER_END returned the encounter as successful or failed
                local instanceName, instanceType, difficultyID, difficultyName, _ = GetInstanceInfo()
                PTR_IssueReporter.AlertFrame.Classification[difficultyName] = PTR_IssueReporter.AlertFrame.Classification[difficultyName] or {}
                local bossID = PTR_IssueReporter.AlertFrame.Classification[difficultyName][bossname]
                PTR_IssueReporter.AddBoss(bossname, bossID, difficultyName)
                PTR_IssueReporter.PushNextBoss()
                PTR_IssueReporter.SetupBugButton()
            else
                PTR_IssueReporter.SetupBugButton(bossname)
            end
        elseif (event == "ENCOUNTER_START") then
            local eventArgs = {...}
            PTR_IssueReporter.Data.CurrentEncounter = eventArgs[2]
        elseif (event == "PLAYER_TARGET_CHANGED") then
            PTR_IssueReporter.AddUnitIDToTracking(PTR_IssueReporter.Data.targetToken)
            -- Checking this here for cases such as the first boss in Hellfire raid where the Encounter Event Name does not match a creature that exists in the encounter. 
            if (PTR_IssueReporter.Data.CurrentEncounter) and UnitExists(PTR_IssueReporter.Data.bossToken) and not PTR_IssueReporter.DoesEncounterHaveID(PTR_IssueReporter.Data.CurrentEncounter) then 
                PTR_IssueReporter.AddUnitIDToTracking(PTR_IssueReporter.Data.bossToken, PTR_IssueReporter.Data.CurrentEncounter)          
            end
        elseif (event == "PLAYER_FOCUS_CHANGED") then
            PTR_IssueReporter.AddUnitIDToTracking(PTR_IssueReporter.Data.focusToken)
        elseif (event == "PLAYER_REGEN_ENABLED") then
            --combat ended
            PTR_IssueReporter.PushNextBoss()
        elseif (event == "PLAYER_REGEN_DISABLED") then
            --combat began
            if (PTR_IssueReporter.AlertFrame:IsShown()) then
                PTR_IssueReporter.AlertFrame.hideFromCombat = true
                PTR_IssueReporter.AlertFrame:Hide()
            end
        elseif (event == "PLAYER_ENTERING_WORLD") then
            PTR_IssueReporter.SetupBugButton()
        end
    end)
    PTR_IssueReporter.AlertFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    PTR_IssueReporter.AlertFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    PTR_IssueReporter.AlertFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    PTR_IssueReporter.AlertFrame:RegisterEvent("ENCOUNTER_START")
    PTR_IssueReporter.AlertFrame:RegisterEvent("ENCOUNTER_END")
    PTR_IssueReporter.AlertFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    PTR_IssueReporter.AlertFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    PTR_IssueReporter.AlertFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

    ------------------------------------------------BOSS KILL / RARE KILL PROMPT------------------------------------------------
    --========================================================================================================================--

    --========================================================================================================================--
    ---------------------------------------------------IMPORTANT QUEST PROMPT---------------------------------------------------

    PTR_IssueReporter.QuestSubmit = CreateFrame("Frame", nil, QuestFrame)
    PTR_IssueReporter.QuestSubmit:Hide()
    PTR_IssueReporter.QuestSubmit:SetSize(QuestFrame:GetWidth() - 4, 150)
    FramePainter.AddBackground(PTR_IssueReporter.QuestSubmit, PTR_IssueReporter.Data.watermark)
    FramePainter.AddBorder(PTR_IssueReporter.QuestSubmit)
    PTR_IssueReporter.QuestSubmit:SetPoint("TOPLEFT", QuestFrame, "BOTTOMLEFT")
    PTR_IssueReporter.QuestSubmit.CheckButtons = {}
    PTR_IssueReporter.QuestSubmit.Choice = 0
    PTR_IssueReporter.QuestSubmit.History = {}

    --question
    PTR_IssueReporter.QuestSubmit.text = PTR_IssueReporter.QuestSubmit:CreateFontString("CheckListText", "OVERLAY", PTR_IssueReporter.Data.fontString)

    PTR_IssueReporter.QuestSubmit.text:SetText("|cffFFFFFFBug Reporter|r\nDid you experience any bugs with this quest?")

    PTR_IssueReporter.QuestSubmit.text:SetSize(PTR_IssueReporter.QuestSubmit:GetWidth(), PTR_IssueReporter.QuestSubmit.text:GetHeight())
    PTR_IssueReporter.QuestSubmit.text:SetPoint("TOP", PTR_IssueReporter.QuestSubmit, "TOP", 0, -8)

    FramePainter.AddInfoButton(PTR_IssueReporter.QuestSubmit, "TOPRIGHT")
    FramePainter.AddTooltip(PTR_IssueReporter.QuestSubmit.InfoButton,
        "Quest bug examples",
        "This quest was hard to find.\nThe marker on my map wasn't where I needed to go.\nIt took a long time to complete this quest.",
        "ANCHOR_BOTTOMRIGHT")

    function PTR_IssueReporter.IsTargetQuest()
        if (#PTR_IssueReporter.Data.targetQuests < 1) then
            return true
        else
            local currentQuestID = GetQuestID() or 0
            for k,v in pairs(PTR_IssueReporter.Data.targetQuests) do
                if (currentQuestID == v) then
                    return true
                end
            end
        end

        return false
    end

    function PTR_IssueReporter.AddQuestHistory(id)
        table.insert(PTR_IssueReporter.QuestSubmit.History, id, 1)
        local maxSize = PTR_IssueReporter.Data.QuestHistorySize
        if (#PTR_IssueReporter.QuestSubmit.History > maxSize) then
            for i = #PTR_IssueReporter.QuestSubmit.History,(maxSize+1),-1 do
                PTR_IssueReporter.QuestSubmit.History[i] = nil
            end
        end
    end

    function PTR_IssueReporter.GetQuestHistory()
        local historyString = ""
        local firstQuest = true
        for k,v in ipairs(PTR_IssueReporter.QuestSubmit.History) do
            if (firstQuest) then
                historyString = string.format("%s", v)
                firstQuest = false
            else
                historyString = string.format("%s:%s", historyString, v)
            end
        end

        return historyString
    end

    --add checkboxes on the popup
    do
        --input field for more comments
        PTR_IssueReporter.QuestSubmit.AdditionalInfo = FramePainter.NewEditBox("IssueReporterAdditionalComments", "BOTTOM", PTR_IssueReporter.QuestSubmit, "BOTTOM", "Additional Comments?", PTR_IssueReporter.QuestSubmit:GetWidth(), 40)
        FramePainter.AddBackground(PTR_IssueReporter.QuestSubmit.AdditionalInfo, PTR_IssueReporter.Data.textureFile)
        PTR_IssueReporter.QuestSubmit.CheckButtons[1] = FramePainter.NewCheckBox("BOTTOMRIGHT", PTR_IssueReporter.QuestSubmit.AdditionalInfo, "TOP", "Yes", -20, 25, 1, 1, 1)
        PTR_IssueReporter.QuestSubmit.CheckButtons[2] = FramePainter.NewCheckBox("BOTTOMLEFT", PTR_IssueReporter.QuestSubmit.AdditionalInfo, "TOP", "No", 20, 25, 1, 1, 1)
        --set scripts
        for i=1,#PTR_IssueReporter.QuestSubmit.CheckButtons do
            PTR_IssueReporter.QuestSubmit.CheckButtons[i]:SetScript("OnClick", function(self,button,down)
                PTR_IssueReporter.QuestSubmit.Choice = PTR_IssueReporter.ExclusiveCheckButton(PTR_IssueReporter.QuestSubmit.CheckButtons, i)
                PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
            end)
        end
    end

    PTR_IssueReporter.QuestSubmit:SetScript("OnShow", function(self)
        --empty comment box
        PTR_IssueReporter.QuestSubmit.AdditionalInfo:SetText("")
        --reset checkbox
        PTR_IssueReporter.QuestSubmit.Choice = PTR_IssueReporter.ExclusiveCheckButton(PTR_IssueReporter.QuestSubmit.CheckButtons, 0)
    end)
    --listen for QUEST_DETAIL
    PTR_IssueReporter.QuestSubmit:SetScript("OnEvent", function(self, event, ...)
        if (event == "QUEST_COMPLETE") then
            if (PTR_IssueReporter.IsTargetQuest() and (not GetCVarBool("showNPETutorials")) or (UnitLevel(PTR_IssueReporter.Data.unitToken) >= (NPE_TUTORIAL_COMPLETE_LEVEL or 1))) then
                self:Show()
            end
        elseif (event == "QUEST_TURNED_IN") then
            if (not GetCVarBool("showNPETutorials")) or (UnitLevel(PTR_IssueReporter.Data.unitToken) >= (NPE_TUTORIAL_COMPLETE_LEVEL or 1)) then
                local questID = select(1,...)
                --submit diagnostics
                local commentField = PTR_IssueReporter.QuestSubmit.AdditionalInfo:GetText()
                commentField = commentField:gsub(",", "")
                if (PTR_IssueReporter.QuestSubmit.Choice > 0) or (#commentField > 0) then
                    PTR_IssueReporter.SendResults(PTR_IssueReporter.Data.QUEST_TURNED_IN, PTR_IssueReporter.QuestSubmit.Choice, questID, commentField, PTR_IssueReporter.GetQuestHistory())
                    UIErrorsFrame:AddMessage(PTR_IssueReporter.Data.Thanks)
                end
                PTR_IssueReporter.QuestSubmit.Choice = PTR_IssueReporter.ExclusiveCheckButton(PTR_IssueReporter.QuestSubmit.CheckButtons, 0)
                PTR_IssueReporter.QuestSubmit.AdditionalInfo:SetText("")
            end
            self:Hide()
        elseif (event == "QUEST_FINISHED") then
            PTR_IssueReporter.QuestSubmit.Choice = PTR_IssueReporter.ExclusiveCheckButton(PTR_IssueReporter.QuestSubmit.CheckButtons, 0)
            PTR_IssueReporter.QuestSubmit.AdditionalInfo:SetText("")
            self:Hide()
        end
    end)

    PTR_IssueReporter.QuestSubmit:RegisterEvent("QUEST_COMPLETE")
    PTR_IssueReporter.QuestSubmit:RegisterEvent("QUEST_TURNED_IN")
    PTR_IssueReporter.QuestSubmit:RegisterEvent("QUEST_FINISHED") --called when quest window closes

---------------------------------------------------IMPORTANT QUEST PROMPT---------------------------------------------------
--========================================================================================================================--
    PTR_IssueReporter.EventPopup = CreateFrame("Frame", "PTRIssueReporterEventPopup", UIParent)
    PTR_IssueReporter.EventPopup:SetFrameStrata("HIGH")
    table.insert(UISpecialFrames, PTR_IssueReporter.EventPopup:GetName())
    PTR_IssueReporter.EventPopup.Reason = 0
    PTR_IssueReporter.EventPopup:SetSize(350, 30)
    if (Blizzard_PTRIssueReporter_Saved.PopupX and Blizzard_PTRIssueReporter_Saved.PopupY) then
        PTR_IssueReporter.EventPopup:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", Blizzard_PTRIssueReporter_Saved.PopupX, Blizzard_PTRIssueReporter_Saved.PopupY)
    else
        PTR_IssueReporter.EventPopup:SetPoint("CENTER", UIParent, "CENTER")
    end
    FramePainter.AddBackground(PTR_IssueReporter.EventPopup, PTR_IssueReporter.Data.textureFile2)
    FramePainter.AddBorder(PTR_IssueReporter.EventPopup)
    PTR_IssueReporter.EventPopup:SetMovable(true)
    PTR_IssueReporter.EventPopup:EnableMouse(true)
    PTR_IssueReporter.EventPopup:SetClampedToScreen(true)

    PTR_IssueReporter.EventPopup:RegisterForDrag("LeftButton")
    PTR_IssueReporter.EventPopup:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    PTR_IssueReporter.EventPopup:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local left, bottom, width, height = self:GetRect()
        Blizzard_PTRIssueReporter_Saved.PopupX = left
        Blizzard_PTRIssueReporter_Saved.PopupY = bottom
    end)

    PTR_IssueReporter.EventPopup.Label = PTR_IssueReporter.EventPopup:CreateFontString(nil, "OVERLAY")
    PTR_IssueReporter.EventPopup.Label:SetFont("Fonts\\FRIZQT__.TTF", PTR_IssueReporter.EventPopup:GetHeight()*0.5, "OUTLINE, THICK")
    PTR_IssueReporter.EventPopup.Label:SetPoint("LEFT", PTR_IssueReporter.EventPopup, "LEFT", 8, 0)
    PTR_IssueReporter.EventPopup.Label:SetJustifyH("LEFT")
    PTR_IssueReporter.EventPopup.Label:SetTextColor(1, 0.8, 0.2, 1)
    PTR_IssueReporter.EventPopup.TopLabel = PTR_IssueReporter.EventPopup.Border:CreateFontString(nil, "OVERLAY")
    PTR_IssueReporter.EventPopup.TopLabel:SetFont("Fonts\\FRIZQT__.TTF", PTR_IssueReporter.EventPopup:GetHeight()*0.8, "OUTLINE, THICK")
    PTR_IssueReporter.EventPopup.TopLabel:SetText("")
    PTR_IssueReporter.EventPopup.TopLabel:SetTextColor(1, 0.8, 0.2, 1)
    PTR_IssueReporter.EventPopup.TopLabel:SetPoint("BOTTOM", PTR_IssueReporter.EventPopup, "TOP")

    PTR_IssueReporter.EventPopup:SetScript("OnEnter", function(self)
        SetCursor("Interface\\CURSOR\\UI-Cursor-Move.blp")
    end)
    PTR_IssueReporter.EventPopup:SetScript("OnLeave", function(self)
        ResetCursor()
    end)

    PTR_IssueReporter.EventPopup.CloseButton = CreateFrame("Button", nil, PTR_IssueReporter.EventPopup, "UIPanelCloseButtonNoScripts")
    PTR_IssueReporter.EventPopup.CloseButton:SetPoint("RIGHT", PTR_IssueReporter.EventPopup, "RIGHT")
    PTR_IssueReporter.EventPopup.CloseButton:SetScript("OnClick", function(self)
        PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
        PTR_IssueReporter.EventPopup:Hide()
    end)
    PTR_IssueReporter.EventPopup.Label:SetPoint("RIGHT", PTR_IssueReporter.EventPopup.CloseButton, "LEFT", 0, 0)

    PTR_IssueReporter.EventPopup.Pool = {}
    PTR_IssueReporter.EventPopup.CheckBoxes = CreateFrame("Frame", nil, PTR_IssueReporter.EventPopup)
    PTR_IssueReporter.EventPopup.CheckBoxes:SetPoint("TOPLEFT", PTR_IssueReporter.EventPopup, "BOTTOMLEFT")
    PTR_IssueReporter.EventPopup.CheckBoxes:SetPoint("TOPRIGHT", PTR_IssueReporter.EventPopup, "BOTTOMRIGHT")
    FramePainter.AddBackground(PTR_IssueReporter.EventPopup.CheckBoxes, PTR_IssueReporter.Data.textureFile2)
    FramePainter.AddBorder(PTR_IssueReporter.EventPopup.CheckBoxes)
    PTR_IssueReporter.EventPopup.CheckBoxes.Question = PTR_IssueReporter.EventPopup.CheckBoxes:CreateFontString(nil, "OVERLAY")
    PTR_IssueReporter.EventPopup.CheckBoxes.Question:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE, THICK")
    PTR_IssueReporter.EventPopup.CheckBoxes.Question:SetPoint("TOPLEFT", PTR_IssueReporter.EventPopup.CheckBoxes, "TOPLEFT", 8, -8)
    PTR_IssueReporter.EventPopup.CheckBoxes.Question:SetPoint("TOPRIGHT", PTR_IssueReporter.EventPopup.CheckBoxes, "TOPRIGHT", -8, -8)
    PTR_IssueReporter.EventPopup.CheckBoxes.Question:SetJustifyV("TOP")
    PTR_IssueReporter.EventPopup.CheckBoxes.Question:SetJustifyH("LEFT")
    PTR_IssueReporter.EventPopup.CheckBoxes.Question:SetTextColor(1, 1, 1, 1)
    PTR_IssueReporter.EventPopup.CheckBoxes:SetHeight(100)

    PTR_IssueReporter.EventPopup.Body = CreateFrame("Frame", nil, PTR_IssueReporter.EventPopup.CheckBoxes)
    PTR_IssueReporter.EventPopup.Body:SetHeight(200)
    PTR_IssueReporter.EventPopup.Body:EnableMouse(true)
    PTR_IssueReporter.EventPopup.Body:SetPoint("TOPLEFT", PTR_IssueReporter.EventPopup.CheckBoxes, "BOTTOMLEFT")
    PTR_IssueReporter.EventPopup.Body:SetPoint("TOPRIGHT", PTR_IssueReporter.EventPopup.CheckBoxes, "BOTTOMRIGHT")
    FramePainter.AddBackground(PTR_IssueReporter.EventPopup.Body, PTR_IssueReporter.Data.watermark)
    FramePainter.AddBorder(PTR_IssueReporter.EventPopup.Body)
    PTR_IssueReporter.EventPopup.Body.Counter = PTR_IssueReporter.EventPopup.Body:CreateFontString(nil, "OVERLAY")
    PTR_IssueReporter.EventPopup.Body.Counter:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE, THICK")
    PTR_IssueReporter.EventPopup.Body.Counter:SetPoint("BOTTOMRIGHT", PTR_IssueReporter.EventPopup.Body, "BOTTOMRIGHT")

    PTR_IssueReporter.EventPopup.Body.EditBox = CreateFrame("EditBox", nil, PTR_IssueReporter.EventPopup.Body)
    PTR_IssueReporter.EventPopup.Body.EditBox.MaxLetters = 255
    PTR_IssueReporter.EventPopup.Body.EditBox:SetAllPoints(PTR_IssueReporter.EventPopup.Body)
    PTR_IssueReporter.EventPopup.Body.EditBox:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE, THICK")
    PTR_IssueReporter.EventPopup.Body.EditBox:SetAutoFocus(false)
    PTR_IssueReporter.EventPopup.Body.EditBox:SetTextInsets(12, 12, 8, -8)
    PTR_IssueReporter.EventPopup.Body.EditBox:SetJustifyV("TOP")
    PTR_IssueReporter.EventPopup.Body.EditBox:SetJustifyH("LEFT")
    PTR_IssueReporter.EventPopup.Body.EditBox:SetMultiLine(true)
    PTR_IssueReporter.EventPopup.Body.EditBox:SetMaxLetters(PTR_IssueReporter.EventPopup.Body.EditBox.MaxLetters)
    PTR_IssueReporter.EventPopup.Body.EditBox.Preface = PTR_IssueReporter.EventPopup.Body.EditBox:CreateFontString(nil, "OVERLAY")
    PTR_IssueReporter.EventPopup.Body.EditBox.Preface:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE, THICK")
    PTR_IssueReporter.EventPopup.Body.EditBox.Preface:SetPoint("TOPLEFT", PTR_IssueReporter.EventPopup.Body, "TOPLEFT", 14, -8)
    PTR_IssueReporter.EventPopup.Body.EditBox.Preface:SetText("Comments...")
    PTR_IssueReporter.EventPopup.Body.EditBox.Preface:SetTextColor(1, 1, 1, 0.5)
    PTR_IssueReporter.EventPopup.Body.EditBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    PTR_IssueReporter.EventPopup.Body.EditBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    PTR_IssueReporter.EventPopup.Body.EditBox:SetScript("OnTextChanged", function(self)
        local body = self:GetText()
        if (#body > 0) then
            PTR_IssueReporter.EventPopup.Body.EditBox.Preface:Hide()
        else
            PTR_IssueReporter.EventPopup.Body.EditBox.Preface:Show()
        end
        local count = string.format("%s / %s", #body, PTR_IssueReporter.EventPopup.Body.EditBox.MaxLetters)
        PTR_IssueReporter.EventPopup.Body.Counter:SetText(count)
    end)

    PTR_IssueReporter.EventPopup.Footer = CreateFrame("Frame", nil, PTR_IssueReporter.EventPopup.Body)
    PTR_IssueReporter.EventPopup.Footer:SetHeight(35)
    PTR_IssueReporter.EventPopup.Footer:SetPoint("TOPLEFT", PTR_IssueReporter.EventPopup.Body, "BOTTOMLEFT", 0, 0)
    PTR_IssueReporter.EventPopup.Footer:SetPoint("TOPRIGHT", PTR_IssueReporter.EventPopup.Body, "BOTTOMRIGHT", 0, 0)

    PTR_IssueReporter.EventPopup.SubmitButton = CreateFrame("Button", nil, PTR_IssueReporter.EventPopup.Footer, "UIPanelButtonTemplate")
    PTR_IssueReporter.EventPopup.SubmitButton:SetSize(140, 35)
    PTR_IssueReporter.EventPopup.SubmitButton:SetPoint("TOP", PTR_IssueReporter.EventPopup.Footer, "TOP")
    PTR_IssueReporter.EventPopup.SubmitButton:SetText(PTR_IssueReporter.Data.SubmitText)
    PTR_IssueReporter.EventPopup.SubmitButton:SetScript("OnClick", function(self, button, down)
        if (button == "LeftButton") then
            PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
            PTR_IssueReporter.EventPopup:Hide()

            local choice, reason, comments, refID = PTR_IssueReporter.GetEventInfo()
            if (comments) and (#comments > 0) then
                PTR_IssueReporter.SendResults(reason, choice, refID, comments)
            end
            PTR_IssueReporter.EventPopup.Reason = 0
            UIErrorsFrame:AddMessage(PTR_IssueReporter.Data.Thanks)
        end
    end)
    
    PTR_IssueReporter.EventPopup:SetClampRectInsets(0, 0, 0, -(PTR_IssueReporter.EventPopup.Body:GetHeight() + PTR_IssueReporter.EventPopup.Footer:GetHeight() + PTR_IssueReporter.EventPopup.CheckBoxes:GetHeight()))

    function PTR_IssueReporter.GetCheckBoxFromPool()
        for k,v in ipairs(PTR_IssueReporter.EventPopup.Pool) do
            if (v.isAvailable) then
                v.isAvailable = false
                return v
            end
        end

        local onDemandCheckBox = FramePainter.NewCheckBox(nil, PTR_IssueReporter.EventPopup.CheckBoxes, nil, "", 0, 0, nil, nil, nil, true)
        table.insert(PTR_IssueReporter.EventPopup.Pool, onDemandCheckBox)
        onDemandCheckBox.index = #PTR_IssueReporter.EventPopup.Pool
        onDemandCheckBox:SetScript("OnClick", function(self)
            PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
            PTR_IssueReporter.ExclusiveCheckButton(PTR_IssueReporter.EventPopup.Pool, self.index)
        end)
        return onDemandCheckBox
    end

    function PTR_IssueReporter.GetEventInfo()
        local choice, reason, comments, refID = 0, PTR_IssueReporter.EventPopup.Reason, PTR_IssueReporter.EventPopup.Body.EditBox:GetText(), 0
        if (PTR_IssueReporter.EventPopup.MapInfo) and (PTR_IssueReporter.EventPopup.MapInfo.id) then
            refID = PTR_IssueReporter.EventPopup.MapInfo.id
        end
        for k,v in ipairs(PTR_IssueReporter.EventPopup.Pool) do
            if (v:GetChecked()) then
                choice = k
                break
            end
        end

        return choice, reason, comments, refID
    end

    function PTR_IssueReporter.GetReason()
        local instanceName, instanceType, difficultyID, difficultyName, _ = GetInstanceInfo()
        local _, _, _, mapID = UnitPosition(PTR_IssueReporter.Data.unitToken)
        if (instanceName:match("[Ww]arfront")) then
            PTR_IssueReporter.EventPopup.MapInfo = {name = instanceName, id = mapID}
            return PTR_IssueReporter.Data.WARFRONTS
        end
        if (not difficultyID) then
            return 0
        end
        if (difficultyID == 45) or (difficultyID == 40) or (difficultyID == 39) or (difficultyID == 38) then
            PTR_IssueReporter.EventPopup.MapInfo = {name = instanceName, id = mapID}
            return PTR_IssueReporter.Data.ISLANDS
        end

        return 0
    end
    
    function PTR_IssueReporter.StringToArrayByCharacter(StringToConvert, char)
        local lines = {}
        for s in StringToConvert:gmatch("[^"..char.."]+") do
            table.insert(lines, s)
        end
        return lines
    end

    function PTR_IssueReporter.PopEvent(reason)
        PTR_IssueReporter.EventPopup.Body.EditBox:ClearFocus()
        PTR_IssueReporter.EventPopup.Reason = reason
        local eventPackage = PTR_IssueReporter.TriggerEvents[reason]
        if (not eventPackage.enabled) then
            return
        end
        local title, description = eventPackage.label, eventPackage.question
        if (PTR_IssueReporter.EventPopup.MapInfo) and (PTR_IssueReporter.EventPopup.MapInfo.name) then
            local mapName = PTR_IssueReporter.StringToArrayByCharacter(PTR_IssueReporter.EventPopup.MapInfo.name, "(")
            if (mapName[1]) then
                mapName = mapName[1]
            else
                mapName = PTR_IssueReporter.EventPopup.MapInfo.name
            end
            if (title == "Warfront") then
                title = mapName
            else
                title = string.format("%s - %s", title, mapName)
            end
        end
        PTR_IssueReporter.EventPopup.Label:SetText(title)
        PTR_IssueReporter.EventPopup.Body.EditBox:SetText("")
        local options = eventPackage.checkboxes
        local boxes = {}
        PTR_IssueReporter.ExclusiveCheckButton(PTR_IssueReporter.EventPopup.Pool, 0)
        for k,v in pairs(PTR_IssueReporter.EventPopup.Pool) do
            v.isAvailable = true
            v:Hide()
        end

        local spacing = PTR_IssueReporter.EventPopup.CheckBoxes:GetWidth() / (#options + 1)
        for k,v in ipairs(options) do
            local Box = PTR_IssueReporter.GetCheckBoxFromPool()
            Box:ClearAllPoints()
            Box.text:SetText(v)
            table.insert(boxes, Box)
            Box:SetPoint("BOTTOM", PTR_IssueReporter.EventPopup.CheckBoxes, "BOTTOMLEFT", k*spacing, 0)
            Box:Show()
        end
        PTR_IssueReporter.EventPopup:Show()
        PTR_IssueReporter.EventPopup.CheckBoxes.Question:SetText(description)
        PTR_IssueReporter.EventPopup.CheckBoxes:SetHeight(PTR_IssueReporter.EventPopup.CheckBoxes.Question:GetHeight() + 15 + ((#boxes > 0) and 50 or 0))
        if (#description == 0) then
            PTR_IssueReporter.EventPopup.CheckBoxes:SetHeight(1)
            PTR_IssueReporter.EventPopup.CheckBoxes.Border:Hide()
        else
            PTR_IssueReporter.EventPopup.CheckBoxes.Border:Show()
        end
        PTR_IssueReporter.EventPopup:SetClampRectInsets(0, 0, 0, -(PTR_IssueReporter.EventPopup.Body:GetHeight() + PTR_IssueReporter.EventPopup.Footer:GetHeight() + PTR_IssueReporter.EventPopup.CheckBoxes:GetHeight()))
    end

    PTR_IssueReporter.EventPopup:RegisterEvent("PLAYER_ENTERING_WORLD")
    PTR_IssueReporter.EventPopup:SetScript("OnEvent", function(self, event, ...)
        PTR_IssueReporter.EventPopup:Hide()
        PTR_IssueReporter.EventPopup.LastMap = PTR_IssueReporter.EventPopup.NewMap or 0
        PTR_IssueReporter.EventPopup.NewMap = PTR_IssueReporter.GetReason()

        if (PTR_IssueReporter.EventPopup.LastMap > 0) and (PTR_IssueReporter.EventPopup.NewMap == 0) then
            C_Timer.After(3, function()
                PTR_IssueReporter.PopEvent(PTR_IssueReporter.EventPopup.LastMap)
            end)
        end
    end)
    PTR_IssueReporter.EventPopup:Hide()
    PTR_IssueReporter:Show()
    PTR_IssueReporter:SetClampRectInsets(0, 0, 0, -PTR_IssueReporter.ReportBug:GetHeight())
end

--========================================================================================================================--
if (isGMClient) then
    PTRFeedbackAddonSetup = false
    DEFAULT_CHAT_FRAME:AddMessage("[INTERNAL ONLY] Type /ptrfeedback to view options.", 1, 1, 0.5)
    SLASH_PTRFEEDBACK1 = '/ptrfeedback'
    function handler(msg)
        if (#msg == 0) then
            DEFAULT_CHAT_FRAME:AddMessage("PTR Feedback is currently disabled.\nTo setup the PTR Feedback addon:\n/ptrfeedback setup", 1, 1, 0.5)
        elseif (msg:lower() == "setup") then
            if PTRFeedbackAddonSetup then
                print("The PTR Feedback Addon is already setup.")
            else
                print("Setting up the PTR Feedback Addon...")
                PTR_IssueReporter.Init()
                PTRFeedbackAddonSetup = true
            end
        end
    end
    SlashCmdList["PTRFEEDBACK"] = handler
else
    PTR_IssueReporter:RegisterEvent("ADDON_LOADED")
    PTR_IssueReporter:SetScript("OnEvent", function(self, event, ...)
        if (select(1,...) == "Blizzard_PTRFeedback") then
            PTR_IssueReporter.Init()
        end
    end)
end