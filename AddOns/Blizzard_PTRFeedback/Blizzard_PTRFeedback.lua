function SetupPTRFeedbackFrames()
    --------------------------------------------------ALWAYS DISPLAYED BUTTONS--------------------------------------------------
    local IgnoreLocations = {1813, 1814, 1879, 1882, 1883, 1892,  1893, 1897, 1898, 1907}
    local PTR_Feedback = CreateFrame("Frame", nil, UIParent)
    PTR_Feedback.Body = CreateFrame("Frame", nil, PTR_Feedback)
    PTR_Feedback.Data = {
        targetQuests = {
            --if this list remains empty it will ask on every quest, otherwise only those specified by ID
        },
        bossKillProbabilityPopup = 100, --from 0 to 100 percent
        throttleSubmitTime = 5, --seconds since last sending a feedback update
        AlertQueueSize = 3,
        QuestHistorySize = 5,
        npcAlertQuestion = "Did you experience any bugs or problems\nwith this enemy?",
        watermark = "Interface\\Addons\\Blizzard_PTRFeedback\\Assets\\Textures\\watermark",
        textureFile = "Interface\\Addons\\Blizzard_PTRFeedback\\Assets\\Textures\\UI-Background-Marble",
        textureFile2 = "Interface\\Addons\\Blizzard_PTRFeedback\\Assets\\Textures\\UI-Background-Marble",
        pushedTexture = "Interface\\Addons\\Blizzard_PTRFeedback\\Assets\\Buttons\\UI-Quickslot-Depress",
        fontString = "GameFontNormal",
        confusedIcon = "Interface\\Addons\\Blizzard_PTRFeedback\\Assets\\Icons\\TutorialFrame-QuestionMark",
        bugreport = "Interface\\Addons\\Blizzard_PTRFeedback\\Assets\\Icons\\HelpIcon-Bug",
        height = 50,
        lastSubmitTime,
        unitToken = "player",
        targetToken = "target",
        alertFrameText = "Did you have any bugs or other problems\nwith this creature?",
        SELF_REPORTED_CONFUSED = 1,
        SELF_REPORTED_BUG = 2,
        BOSS_KILL = 3,
        QUEST_TURNED_IN = 4,
        MESSAGE_KEY = "[&#@^$M*]",
    }

    function PTR_Feedback.Reminder(enable, ...)
        for k,v in pairs({...}) do
            if (enable) then
                ActionButton_ShowOverlayGlow(v)
            else
                ActionButton_HideOverlayGlow(v)
            end
        end
    end

    function PTR_Feedback.CreateFeedbackButton(name, icon, tooltip, func)
        local scalar = PTR_Feedback.Body:GetHeight()
        local newbutton = CreateFrame("Button", name, PTR_Feedback)
        newbutton:SetSize(scalar, scalar)
        newbutton:SetHighlightTexture(icon, "ADD")
        newbutton:SetNormalTexture(icon)
        newbutton:SetPushedTexture(PTR_Feedback.Data.pushedTexture)
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

    function PTR_Feedback.ExclusiveCheckButton(buttons, index)
        for i=1,#buttons do
            if (i == index) then
                buttons[i]:SetChecked(true)
            else
                buttons[i]:SetChecked(false)
            end
        end
        return index
    end

    function PTR_Feedback.SendResults(reportType, ...)
        --reset idle time
        local packageString = PTR_FeedbackDiagnostic:Get()
        local finalMessage = string.format('%s,%s,%s', PTR_Feedback.Data.MESSAGE_KEY, reportType, packageString)
        if (reportType == PTR_Feedback.Data.BOSS_KILL) then
            local choice, bossName, bossID, bossDifficulty, comments = ...
            bossName = bossName:gsub(",", " ")
            bossDifficulty = bossDifficulty:gsub(",", " ")
            comments = comments:gsub(","," ")
            finalMessage = string.format('%s,%s,%s,%s,%s,%s', finalMessage, choice, bossName, bossID, bossDifficulty, comments)
        elseif (reportType == PTR_Feedback.Data.QUEST_TURNED_IN) then
            local choice, questID, comments, history = ...
            comments = comments:gsub(","," ")
            finalMessage = string.format('%s,%s,%s,%s,%s', finalMessage, choice, questID, comments, history)
        else
            local comments = ...
            comments = comments:gsub(","," ")
            finalMessage = string.format('%s,%s', finalMessage, comments)
        end

        if (GMSubmitBug) then
            GMSubmitBug(finalMessage)
            UIErrorsFrame:Clear()
        end
        return finalMessage
    end

    --cosmetics
    PTR_Feedback:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, UIParent:GetHeight()*0.25)
    PTR_Feedback:SetFrameStrata("HIGH")
    PTR_Feedback.text = PTR_Feedback:CreateFontString("CheckListText", "OVERLAY", PTR_Feedback.Data.fontString)
    PTR_Feedback.text:SetWidth(PTR_Feedback:GetWidth())
    PTR_Feedback.text:SetHeight(PTR_Feedback:GetHeight())
    PTR_Feedback.text:SetPoint("CENTER", PTR_Feedback, "CENTER", 0, 0)
    PTR_Feedback.text:SetText("Test\nFeedback")
    PTR_Feedback:SetSize(PTR_Feedback.text:GetStringWidth()*1.5,32)
    FramePainter.AddBorder(PTR_Feedback)
    PTR_Feedback.Body:SetSize(PTR_Feedback:GetWidth(), PTR_Feedback.Data.height)
    PTR_Feedback.Body:SetPoint("TOP", PTR_Feedback, "BOTTOM", 0, PTR_Feedback:GetHeight()*0.05)
    FramePainter.AddBackground(PTR_Feedback, PTR_Feedback.Data.textureFile2)

    PTR_Feedback:SetScript("OnUpdate", function(self, elapsed)
        PTR_Feedback.Data.lastSubmitTime = PTR_Feedback.Data.lastSubmitTime or 0
        if (PTR_Feedback.Data.lastSubmitTime > 0) then
            PTR_Feedback.Data.lastSubmitTime = PTR_Feedback.Data.lastSubmitTime - elapsed
        end
    end)

    --information button
    FramePainter.AddInfoButton(PTR_Feedback)
    FramePainter.AddTooltip(PTR_Feedback.InfoButton,
        "Bug feedback examples",
        "This enemy could not be hit.\nI fell through the ground.\nMy spell isn't doing what it says it should do.\nThere are missing graphics here.")

    --create buttons
    local Confused = PTR_Feedback.CreateFeedbackButton("Confused",
        PTR_Feedback.Data.confusedIcon,
        "I'm not sure what I should do\nand/or where I should go.")
    local ReportBug = PTR_Feedback.CreateFeedbackButton("Bug",
        PTR_Feedback.Data.bugreport,
        "I have encountered a bug or other technical problem.")
    ReportBug.InputBox = CreateFrame("Frame", "ReportBugInputBox", ReportBug)
    ReportBug.InputBox:SetPoint("CENTER", UIParent, "CENTER")
    ReportBug.InputBox:SetSize(200, 200)
    FramePainter.AddBackground(ReportBug.InputBox, PTR_Feedback.Data.watermark);
    FramePainter.AddBorder(ReportBug.InputBox)
    ReportBug.InputBox.InputField = FramePainter.NewEditBox("ReportBugExtraInfo", "BOTTOM", ReportBug.InputBox, "BOTTOM", "", ReportBug.InputBox:GetWidth(), 40)
    ReportBug.InputBox.text = ReportBug.InputBox:CreateFontString("CheckListText", "OVERLAY", PTR_Feedback.Data.fontString)
    ReportBug.InputBox.text:SetPoint("TOPLEFT", ReportBug.InputBox, "TOPLEFT", 8, -8)
    ReportBug.InputBox.text:SetPoint("BOTTOMRIGHT", ReportBug.InputBox.InputField, "TOPRIGHT", -8, 8)
    ReportBug.InputBox.text:SetJustifyH("LEFT")
    ReportBug.InputBox.text:SetJustifyV("TOP")
    ReportBug.InputBox.text:SetWordWrap(true)
    ReportBug.InputBox.text:SetNonSpaceWrap(true)
    FramePainter.AddBackground(ReportBug.InputBox.InputField, PTR_Feedback.Data.textureFile)
    ReportBug.InputBox.InputField:SetScript("OnTextChanged", function(self, userInput)
        local body = self:GetText()
        ReportBug.InputBox.text:SetText(body)
    end)
    ReportBug.InputBox.SubmitButton = CreateFrame("Button", nil, ReportBug.InputBox, "UIPanelButtonTemplate")
    ReportBug.InputBox.SubmitButton:SetPoint("TOP", ReportBug.InputBox, "BOTTOM", 0, 0)
    ReportBug.InputBox.SubmitButton:SetText("Submit Feedback")
    ReportBug.InputBox.SubmitButton:SetSize(ReportBug.InputBox.SubmitButton:GetTextWidth()*1.5, 32)
    ReportBug.InputBox.SubmitButton:SetScript("OnClick", function(self, button, down)
        local comments = ReportBug.InputBox.text:GetText() or ""
        if (ReportBug.InputBox.Reason == PTR_Feedback.Data.SELF_REPORTED_BUG) then
            PTR_Feedback.SendResults(PTR_Feedback.Data.SELF_REPORTED_BUG, comments)
        else
            PTR_Feedback.SendResults(PTR_Feedback.Data.SELF_REPORTED_CONFUSED, comments)
        end
        UIErrorsFrame:AddMessage("Your feedback has been received.")
        ReportBug.InputBox:Hide()
        PlaySound(1115)
    end)
    ReportBug.InputBox.Reason = SELF_REPORTED_BUG
    ReportBug.InputBox.Title = CreateFrame("Button", nil, ReportBug.InputBox, "UIPanelButtonTemplate")
    ReportBug.InputBox.Title:SetButtonState("NORMAL", true)
    ReportBug.InputBox.Title:SetNormalTexture(PTR_Feedback.Data.textureFile2)
    ReportBug.InputBox.Title:EnableMouse(false)
    ReportBug.InputBox.Title:SetPoint("BOTTOM", ReportBug.InputBox, "TOP", 0, 2)
    ReportBug.InputBox.Title:SetSize(ReportBug.InputBox:GetWidth(), 32)
    FramePainter.AddBorder(ReportBug.InputBox.Title)
    table.insert(UISpecialFrames, ReportBug.InputBox:GetName())
    ReportBug.InputBox:Hide()
    ReportBug.InputBox:SetScript("OnShow", function(self)
        ReportBug.InputBox.InputField:SetText("")
    end)
    ReportBug:SetScript("OnClick", function(self, button, down)
        if (self.InputBox:IsShown()) then

            if (self.InputBox.Reason == PTR_Feedback.Data.SELF_REPORTED_CONFUSED) then
                ReportBug.InputBox.Reason = PTR_Feedback.Data.SELF_REPORTED_BUG
                self.InputBox.Title:SetText("Test Bug Report")
            else
                self.InputBox:Hide()
            end
        else
            self.InputBox.Reason = PTR_Feedback.Data.SELF_REPORTED_BUG
            self.InputBox.Title:SetText("Test Bug Report")
            self.InputBox:Show()
            self.InputBox.InputField:SetFocus()
        end
        PlaySound(1115)
    end)

    Confused:SetScript("OnClick", function(self, button, down)
        if (ReportBug.InputBox:IsShown()) then
            if (ReportBug.InputBox.Reason == PTR_Feedback.Data.SELF_REPORTED_BUG) then

                ReportBug.InputBox.Reason = PTR_Feedback.Data.SELF_REPORTED_CONFUSED
                ReportBug.InputBox.Title:SetText("Test Confused Report")
            else
                ReportBug.InputBox:Hide()
            end
        else
            ReportBug.InputBox.Reason = PTR_Feedback.Data.SELF_REPORTED_CONFUSED
            ReportBug.InputBox.Title:SetText("Test Confused Report")
            ReportBug.InputBox:Show()
            ReportBug.InputBox.InputField:SetFocus()
        end
        PlaySound(1115)
    end)


    Confused:HookScript("OnEnter", function() PTR_Feedback.Reminder(false, Confused, ReportBug) end)
    ReportBug:HookScript("OnEnter", function() PTR_Feedback.Reminder(false, Confused, ReportBug) end)

    ReportBug:SetPoint("TOPLEFT", PTR_Feedback.Body, "TOP", 2, -6)
    Confused:SetPoint("TOPRIGHT", PTR_Feedback.Body, "TOP", -2, -6)
    PTR_Feedback.Body.Texture = PTR_Feedback.Body:CreateTexture()
    PTR_Feedback.Body.Texture:SetTexture(PTR_Feedback.Data.textureFile)
    PTR_Feedback.Body.Texture:SetPoint("TOPLEFT", Confused, "TOPLEFT")
    PTR_Feedback.Body.Texture:SetPoint("BOTTOMRIGHT", ReportBug, "BOTTOMRIGHT")
    PTR_Feedback.Body.Texture:SetDrawLayer("BACKGROUND")

    --behaviors
    FramePainter.AddDrag(PTR_Feedback)
    --set clamp rect for body
    PTR_Feedback:SetClampRectInsets(0, 0, 0, -PTR_Feedback.Body.Texture:GetHeight())
    PTR_Feedback:SetScript("OnHide", function(self)
        self:Show()
    end)

    --timers/reminders/notifications, only one time ever on login
    C_Timer.After(1, function(self) PTR_Feedback.Reminder(true, Confused, ReportBug) end)

    --------------------------------------------------ALWAYS DISPLAYED BUTTONS--------------------------------------------------
    --========================================================================================================================--

    --========================================================================================================================--
    ------------------------------------------------BOSS KILL / RARE KILL PROMPT------------------------------------------------

    PTR_Feedback.AlertFrame = CreateFrame("Frame", "PTRFeedbackAlertFrame", UIParent)
    PTR_Feedback.AlertFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 16, -116)
    PTR_Feedback.AlertFrame:SetSize(338, 496)
    PTR_Feedback.AlertFrame.TitleBox = CreateFrame("Frame", nil, PTR_Feedback.AlertFrame)
    PTR_Feedback.AlertFrame.TitleBox:SetPoint("BOTTOM", PTR_Feedback.AlertFrame, "TOP", 0, 2)
    PTR_Feedback.AlertFrame.TitleBox.text = PTR_Feedback.AlertFrame.TitleBox:CreateFontString("CheckListText", "OVERLAY", PTR_Feedback.Data.fontString)
    PTR_Feedback.AlertFrame.TitleBox.text:SetWidth(PTR_Feedback.AlertFrame.TitleBox:GetWidth())
    PTR_Feedback.AlertFrame.TitleBox.text:SetHeight(PTR_Feedback.AlertFrame.TitleBox:GetHeight())
    PTR_Feedback.AlertFrame.TitleBox.text:SetPoint("CENTER", PTR_Feedback.AlertFrame.TitleBox, "CENTER", 0, 0)
    PTR_Feedback.AlertFrame.TitleBox.text:SetText("Public Test Feedback Report")

    PTR_Feedback.AlertFrame.TitleBox:SetSize(PTR_Feedback.AlertFrame.TitleBox.text:GetWidth()*1.5, PTR_Feedback.AlertFrame.TitleBox.text:GetHeight()*2)
    FramePainter.AddBackground(PTR_Feedback.AlertFrame.TitleBox, PTR_Feedback.Data.textureFile2)
    FramePainter.AddBorder(PTR_Feedback.AlertFrame.TitleBox)
    FramePainter.AddBorder(PTR_Feedback.AlertFrame)
    FramePainter.AddBackground(PTR_Feedback.AlertFrame, PTR_Feedback.Data.watermark)
    PTR_Feedback.AlertFrame.ClassByID = {}

    --info button
    FramePainter.AddInfoButton(PTR_Feedback.AlertFrame)
    FramePainter.AddTooltip(PTR_Feedback.AlertFrame.InfoButton,
        "Enemy feedback examples",
        "This enemy hit too hard.\nThis enemy could not be hit.\nI couldn't find this enemy.\nThis enemy never moved.",
        "ANCHOR_BOTTOMRIGHT",
        PTR_Feedback.AlertFrame:GetWidth() - 2*PTR_Feedback.AlertFrame.InfoButton:GetWidth())
    --check buttons
    PTR_Feedback.AlertFrame.CheckButtons = {}
    --queue list
    PTR_Feedback.AlertFrame.Queue = {}
    PTR_Feedback.AlertFrame.Classification = {}
    PTR_Feedback.AlertFrame.Defeated = {}
    PTR_Feedback.AlertFrame.Choice = 0
    --model frame
    PTR_Feedback.AlertFrame.CreatureID = 12435
    PTR_Feedback.AlertFrame.Name = "Razorgore the Untamed"
    PTR_Feedback.AlertFrame.Model = CreateFrame("PlayerModel", nil, PTR_Feedback.AlertFrame)
    PTR_Feedback.AlertFrame.Model:SetPoint("CENTER")
    PTR_Feedback.AlertFrame.Model:SetSize(PTR_Feedback.AlertFrame:GetWidth()*0.9, PTR_Feedback.AlertFrame:GetHeight()*(2/3))
    PTR_Feedback.AlertFrame.Model:SetCreature(PTR_Feedback.AlertFrame.CreatureID)
    --model/name/location
    PTR_Feedback.AlertFrame.text = CreateFrame("Button", nil, PTR_Feedback.AlertFrame, "UIPanelButtonTemplate")
    PTR_Feedback.AlertFrame.text:SetButtonState("NORMAL", true)
    PTR_Feedback.AlertFrame.text:SetNormalTexture(PTR_Feedback.Data.textureFile2)
    PTR_Feedback.AlertFrame.text:EnableMouse(false)
    PTR_Feedback.AlertFrame.text:SetPoint("TOP", PTR_Feedback.AlertFrame, "TOP", 0, -15)
    PTR_Feedback.AlertFrame.text:SetText(PTR_Feedback.Data.npcAlertQuestion)
    PTR_Feedback.AlertFrame.text:SetSize(math.min(PTR_Feedback.AlertFrame.text:GetTextWidth()*1.5, PTR_Feedback.AlertFrame:GetWidth()*0.9), 40)
    FramePainter.AddBorder(PTR_Feedback.AlertFrame.text)
    --close button
    PTR_Feedback.AlertFrame.CloseButton = CreateFrame("Button", nil, PTR_Feedback.AlertFrame, "UIPanelCloseButton")
    PTR_Feedback.AlertFrame.CloseButton:SetPoint("CENTER", PTR_Feedback.AlertFrame, "TOPRIGHT")
    PTR_Feedback.AlertFrame.CloseButton:SetScript("OnHide", function(self)
        PlaySound(1115)
    end)
    table.insert(UISpecialFrames, PTR_Feedback.AlertFrame:GetName())
    --text
    PTR_Feedback.AlertFrame.Title = PTR_Feedback.AlertFrame:CreateFontString("CheckListText", "OVERLAY", PTR_Feedback.Data.fontString)
    PTR_Feedback.AlertFrame.Title:SetText(PTR_Feedback.AlertFrame.Name)
    PTR_Feedback.AlertFrame.Title:SetSize(PTR_Feedback.AlertFrame.Title:GetStringWidth(), PTR_Feedback.AlertFrame.Title:GetStringHeight()*2)
    PTR_Feedback.AlertFrame.Title:SetPoint("TOP", PTR_Feedback.AlertFrame.text, "BOTTOM", 0, -8)

    PTR_Feedback.AlertFrame:SetScript("OnUpdate", function(self, elapsed)
        PTR_Feedback.AlertFrame.Timer = (PTR_Feedback.AlertFrame.Timer or 0) + elapsed
        if (PTR_Feedback.AlertFrame.Timer > math.pi*2) then
            PTR_Feedback.AlertFrame.Timer = 0
        end
        PTR_Feedback.AlertFrame.Model:SetRotation(PTR_Feedback.AlertFrame.Timer)
    end)

    PTR_Feedback.AlertFrame.SubmitButton = CreateFrame("Button", nil, PTR_Feedback.AlertFrame, "UIPanelButtonTemplate")
    PTR_Feedback.AlertFrame.SubmitButton:SetPoint("TOP", PTR_Feedback.AlertFrame, "BOTTOM")
    PTR_Feedback.AlertFrame.SubmitButton:SetText("Submit Feedback")
    PTR_Feedback.AlertFrame.SubmitButton:SetSize(PTR_Feedback.AlertFrame.SubmitButton:GetTextWidth()*1.5, 32)
    
    PTR_Feedback.AlertFrame:Hide()

    function PTR_Feedback.SetBossInfo(name, creatureId, difficulty)
        PTR_Feedback.AlertFrame.CreatureID = creatureId
        PTR_Feedback.AlertFrame.Name = name
        PTR_Feedback.AlertFrame.Difficulty = difficulty

        PTR_Feedback.AlertFrame.Model:SetCreature(PTR_Feedback.AlertFrame.CreatureID)
        if (#PTR_Feedback.AlertFrame.Difficulty == 0) then
            PTR_Feedback.AlertFrame.Title:SetText(string.format("%s", PTR_Feedback.AlertFrame.Name))
        else
            PTR_Feedback.AlertFrame.Title:SetText(string.format("(%s)\n%s", PTR_Feedback.AlertFrame.Difficulty, PTR_Feedback.AlertFrame.Name))
        end
        PTR_Feedback.AlertFrame.Title:SetWidth(math.min(PTR_Feedback.AlertFrame.Title:GetStringWidth()*1.5, PTR_Feedback.AlertFrame:GetWidth()*0.9))
        PTR_Feedback.AlertFrame.Choice = PTR_Feedback.ExclusiveCheckButton(PTR_Feedback.AlertFrame.CheckButtons, 0)
        PTR_Feedback.AlertFrame.Model:SetAnimation(190)
    end

    function PTR_Feedback.PushNextBoss()
        --in combat fail
        if (UnitAffectingCombat(PTR_Feedback.Data.unitToken)) then
            return
        end
        if (#PTR_Feedback.AlertFrame.Queue <= 0) then
            --no bosses to push
            PTR_Feedback.AlertFrame:Hide()
        else
            --take the first boss and set it if not flagged
            PTR_Feedback.SetBossInfo(PTR_Feedback.AlertFrame.Queue[#PTR_Feedback.AlertFrame.Queue].name,
                PTR_Feedback.AlertFrame.Queue[#PTR_Feedback.AlertFrame.Queue].id,
                PTR_Feedback.AlertFrame.Queue[#PTR_Feedback.AlertFrame.Queue].difficulty)
            PTR_Feedback.Data.alertFrameText = PTR_Feedback.Data.npcAlertQuestion
            PTR_Feedback.AlertFrame:Show()
        end
    end

    function PTR_Feedback.FlagDefeated() --if a user has submitted feedback on a boss already, don't ask again
        local lastBoss = PTR_Feedback.AlertFrame.Name
        local difficultyID = PTR_Feedback.AlertFrame.Difficulty
        PTR_Feedback.AlertFrame.Defeated[difficultyID] = PTR_Feedback.AlertFrame.Defeated[difficultyID] or {}
        PTR_Feedback.AlertFrame.Defeated[difficultyID][lastBoss] = true
    end

    function PTR_Feedback.ClearNextBoss()
        PTR_Feedback.AlertFrame.Queue[#PTR_Feedback.AlertFrame.Queue] = nil
        --also clean up any flagged bosses here
        for i=#PTR_Feedback.AlertFrame.Queue,1,-1 do
            local isDefeated = PTR_Feedback.AlertFrame.Defeated[PTR_Feedback.AlertFrame.Queue[i].difficulty] or {}
            if (isDefeated[PTR_Feedback.AlertFrame.Queue[i].name]) then
                PTR_Feedback.AlertFrame.Queue[i] = nil
            end
        end
    end

    function PTR_Feedback.AddBoss(name, creatureId, difficultyName)
        local roll = math.random(0, 99)
        if (roll < PTR_Feedback.Data.bossKillProbabilityPopup) then
            if (#PTR_Feedback.AlertFrame.Queue >= PTR_Feedback.Data.AlertQueueSize) then
                --push out the first one
                local numAhead = 1 + (#PTR_Feedback.AlertFrame.Queue - PTR_Feedback.Data.AlertQueueSize)
                local numIterations = PTR_Feedback.Data.AlertQueueSize - 1
                for i = 1, numIterations do
                    PTR_Feedback.AlertFrame.Queue[i] = PTR_Feedback.AlertFrame.Queue[i+numAhead]
                end
                for i = #PTR_Feedback.AlertFrame.Queue, numIterations+1, -1 do
                    PTR_Feedback.AlertFrame.Queue[i] = nil
                end
            end
            table.insert(PTR_Feedback.AlertFrame.Queue, {name = name, id = creatureId, difficulty = difficultyName})
        end
    end
    
    function PTR_Feedback.CheckValidLocation(searchedArray, currentLocation)
        for index, value in ipairs(searchedArray) do
            if value == currentLocation then
                return false
            end
        end
        return true
    end

    do
        PTR_Feedback.AlertFrame.CheckButtons[1] = FramePainter.NewCheckBox("CENTER", PTR_Feedback.AlertFrame, "BOTTOMLEFT", "Yes", PTR_Feedback.AlertFrame:GetWidth()*(1/3), 80)
        PTR_Feedback.AlertFrame.CheckButtons[2] = FramePainter.NewCheckBox("CENTER", PTR_Feedback.AlertFrame, "BOTTOMLEFT", "No", PTR_Feedback.AlertFrame:GetWidth()*(2/3), 80)

        PTR_Feedback.AlertFrame.AdditionalInfo = FramePainter.NewEditBox("FeedbackAdditionalCommentsBossKill", "BOTTOM", PTR_Feedback.AlertFrame, "BOTTOM", "Additional Comments?", PTR_Feedback.AlertFrame:GetWidth(), 40)
        FramePainter.AddBackground(PTR_Feedback.AlertFrame.AdditionalInfo, PTR_Feedback.Data.textureFile)
        --set scripts
        for i=1,#PTR_Feedback.AlertFrame.CheckButtons do
            PTR_Feedback.AlertFrame.CheckButtons[i]:SetScript("OnClick", function(self,button,down)
                PTR_Feedback.AlertFrame.Choice = PTR_Feedback.ExclusiveCheckButton(PTR_Feedback.AlertFrame.CheckButtons, i)
                PlaySound(1115)
            end)
        end
    end

    PTR_Feedback.AlertFrame.SubmitButton:SetScript("OnClick", function(self, button, down)
        --close and submit
        if (PTR_Feedback.AlertFrame.Difficulty) then
            local commentField = PTR_Feedback.AlertFrame.AdditionalInfo:GetText()
            commentField = commentField:gsub(",", " ")
            PTR_Feedback.SendResults(PTR_Feedback.Data.BOSS_KILL, PTR_Feedback.AlertFrame.Choice, PTR_Feedback.AlertFrame.Name, PTR_Feedback.AlertFrame.CreatureID, PTR_Feedback.AlertFrame.Difficulty, commentField)
            --submit answers
            PTR_Feedback.FlagDefeated()
            PTR_Feedback.ClearNextBoss()
            PTR_Feedback.PushNextBoss()
            UIErrorsFrame:AddMessage("Your feedback has been received.")
            PTR_Feedback.AlertFrame.Choice = PTR_Feedback.ExclusiveCheckButton(PTR_Feedback.AlertFrame.CheckButtons, 0)
            PTR_Feedback.AlertFrame.AdditionalInfo:SetText("")
        else
            PTR_Feedback.AlertFrame:Hide()
        end
        PlaySound(1115)
    end)

    PTR_Feedback.AlertFrame:SetScript("OnShow", function(self)
        --init data
        PTR_Feedback.AlertFrame.text:SetText(PTR_Feedback.Data.alertFrameText)
        PTR_Feedback.AlertFrame.AdditionalInfo:SetText("")
        PTR_Feedback.AlertFrame.Choice = PTR_Feedback.ExclusiveCheckButton(PTR_Feedback.AlertFrame.CheckButtons, 0)
        PlaySound(620)
    end)

    PTR_Feedback.AlertFrame:SetScript("OnEvent", function(self, event, ...)
        if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
            local eventArgs = {...}
            if (CombatLogGetCurrentEventInfo) then
                eventArgs = {CombatLogGetCurrentEventInfo()}
            end
            local combatevent = eventArgs[2]
            if (combatevent == "PARTY_KILL") or (UnitControllingVehicle(PTR_Feedback.Data.unitToken) and combatevent == "UNIT_DIED") then
                local creatureName = eventArgs[9]
                local creatureID = eventArgs[8]
                local unittype,_,_,_,_,id,guid = strsplit("-",creatureID,7)
                local instanceName, instanceType, difficultyID, difficultyName, _ = GetInstanceInfo()
                --key by difficulty
                PTR_Feedback.AlertFrame.Classification[difficultyName] = PTR_Feedback.AlertFrame.Classification[difficultyName] or {}
                PTR_Feedback.AlertFrame.Defeated[difficultyName] = PTR_Feedback.AlertFrame.Defeated[difficultyName] or {}
                if (PTR_Feedback.AlertFrame.Classification[difficultyName][creatureName]) then
                    if (not PTR_Feedback.AlertFrame.Defeated[difficultyName][creatureName]) then
                        if (PTR_Feedback.AlertFrame.ClassByID[id]) and (PTR_Feedback.AlertFrame.ClassByID[id] == "rare" or PTR_Feedback.AlertFrame.ClassByID[id] == "worldboss" or PTR_Feedback.AlertFrame.ClassByID[id] == "rareelite") then
                            if (PTR_Feedback.CheckValidLocation(IgnoreLocations, select(8,GetInstanceInfo()))) then
                                PTR_Feedback.AddBoss(creatureName, id, difficultyName)
                            end
                        end
                    end
                end
            end
        elseif (event == "ENCOUNTER_END") then
            local bossname = select(2,...)
            local instanceName, instanceType, difficultyID, difficultyName, _ = GetInstanceInfo()
            PTR_Feedback.AlertFrame.Classification[difficultyName] = PTR_Feedback.AlertFrame.Classification[difficultyName] or {}
            local bossID = PTR_Feedback.AlertFrame.Classification[difficultyName][bossname]
            if (bossID) then
                PTR_Feedback.AddBoss(bossname, bossID, difficultyName)
            end
        elseif (event == "UNIT_TARGET") then
            if (select(1,...) == PTR_Feedback.Data.unitToken) then
                local classid = UnitClassification(PTR_Feedback.Data.targetToken)
                local name = UnitName(PTR_Feedback.Data.targetToken)
                local _,_,_,_,_,creatureID,guid = strsplit("-", UnitGUID(PTR_Feedback.Data.targetToken) or "", 7)
                local instanceName, instanceType, difficultyID, difficultyName, _ = GetInstanceInfo()
                PTR_Feedback.AlertFrame.Classification[difficultyName] = PTR_Feedback.AlertFrame.Classification[difficultyName] or {}
                if (name and classid) then
                    if (classid == "elite" or classid == "worldboss" or classid == "rare" or classid == "rareelite") and (not PTR_Feedback.AlertFrame.Classification[difficultyName][name]) then
                        PTR_Feedback.AlertFrame.Classification[difficultyName][name] = creatureID
                        PTR_Feedback.AlertFrame.ClassByID[creatureID] = classid
                    end
                end
            end
        elseif (event == "PLAYER_REGEN_ENABLED") then
            --combat ended
            PTR_Feedback.PushNextBoss()
        elseif (event == "PLAYER_REGEN_DISABLED") then
            --combat began
            PTR_Feedback.AlertFrame:Hide()
        end
    end)
    PTR_Feedback.AlertFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    PTR_Feedback.AlertFrame:RegisterEvent("UNIT_TARGET")
    PTR_Feedback.AlertFrame:RegisterEvent("ENCOUNTER_END")
    PTR_Feedback.AlertFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    PTR_Feedback.AlertFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

    ------------------------------------------------BOSS KILL / RARE KILL PROMPT------------------------------------------------
    --========================================================================================================================--

    --========================================================================================================================--
    ---------------------------------------------------IMPORTANT QUEST PROMPT---------------------------------------------------

    PTR_Feedback.QuestSubmit = CreateFrame("Frame", nil, QuestFrame)
    PTR_Feedback.QuestSubmit:Hide()
    PTR_Feedback.QuestSubmit:SetSize(QuestFrame:GetWidth() - 4, 150)
    FramePainter.AddBackground(PTR_Feedback.QuestSubmit, PTR_Feedback.Data.watermark)
    FramePainter.AddBorder(PTR_Feedback.QuestSubmit)
    PTR_Feedback.QuestSubmit:SetPoint("TOPLEFT", QuestFrame, "BOTTOMLEFT")
    PTR_Feedback.QuestSubmit.CheckButtons = {}
    PTR_Feedback.QuestSubmit.Choice = 0
    PTR_Feedback.QuestSubmit.History = {}

    --question
    PTR_Feedback.QuestSubmit.text = PTR_Feedback.QuestSubmit:CreateFontString("CheckListText", "OVERLAY", PTR_Feedback.Data.fontString)

    PTR_Feedback.QuestSubmit.text:SetText("|cffFFFFFFPublic Test Feedback|r\nDid you experience any bugs or problems\nwith this quest?")

    PTR_Feedback.QuestSubmit.text:SetSize(PTR_Feedback.QuestSubmit:GetWidth(), PTR_Feedback.QuestSubmit.text:GetHeight())
    PTR_Feedback.QuestSubmit.text:SetPoint("TOP", PTR_Feedback.QuestSubmit, "TOP", 0, -8)

    FramePainter.AddInfoButton(PTR_Feedback.QuestSubmit, "TOPRIGHT")
    FramePainter.AddTooltip(PTR_Feedback.QuestSubmit.InfoButton,
        "Quest feedback examples",
        "This quest was hard to find.\nThe marker on my map wasn't where I needed to go.\nIt took a long time to complete this quest.",
        "ANCHOR_BOTTOMRIGHT")

    function PTR_Feedback.IsTargetQuest()
        if (#PTR_Feedback.Data.targetQuests < 1) then
            return true
        else
            local currentQuestID = GetQuestID() or 0
            for k,v in pairs(PTR_Feedback.Data.targetQuests) do
                if (currentQuestID == v) then
                    return true
                end
            end
        end

        return false
    end

    function PTR_Feedback.AddQuestHistory(id)
        table.insert(PTR_Feedback.QuestSubmit.History, id, 1)
        local maxSize = PTR_Feedback.Data.QuestHistorySize
        if (#PTR_Feedback.QuestSubmit.History > maxSize) then
            for i = #PTR_Feedback.QuestSubmit.History,(maxSize+1),-1 do
                PTR_Feedback.QuestSubmit.History[i] = nil
            end
        end
    end

    function PTR_Feedback.GetQuestHistory()
        local historyString = ""
        local firstQuest = true
        for k,v in ipairs(PTR_Feedback.QuestSubmit.History) do
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
        PTR_Feedback.QuestSubmit.AdditionalInfo = FramePainter.NewEditBox("FeedbackAdditionalComments", "BOTTOM", PTR_Feedback.QuestSubmit, "BOTTOM", "Additional Comments?", PTR_Feedback.QuestSubmit:GetWidth(), 40)
        FramePainter.AddBackground(PTR_Feedback.QuestSubmit.AdditionalInfo, PTR_Feedback.Data.textureFile)
        PTR_Feedback.QuestSubmit.CheckButtons[1] = FramePainter.NewCheckBox("BOTTOMRIGHT", PTR_Feedback.QuestSubmit.AdditionalInfo, "TOP", "Yes", -20, 25, 1, 1, 1)
        PTR_Feedback.QuestSubmit.CheckButtons[2] = FramePainter.NewCheckBox("BOTTOMLEFT", PTR_Feedback.QuestSubmit.AdditionalInfo, "TOP", "No", 20, 25, 1, 1, 1)
        --set scripts
        for i=1,#PTR_Feedback.QuestSubmit.CheckButtons do
            PTR_Feedback.QuestSubmit.CheckButtons[i]:SetScript("OnClick", function(self,button,down)
                PTR_Feedback.QuestSubmit.Choice = PTR_Feedback.ExclusiveCheckButton(PTR_Feedback.QuestSubmit.CheckButtons, i)
                PlaySound(1115)
            end)
        end
    end

    PTR_Feedback.QuestSubmit:SetScript("OnShow", function(self)
        --empty comment box
        PTR_Feedback.QuestSubmit.AdditionalInfo:SetText("")
        --reset checkbox
        PTR_Feedback.QuestSubmit.Choice = PTR_Feedback.ExclusiveCheckButton(PTR_Feedback.QuestSubmit.CheckButtons, 0)
    end)
    --listen for QUEST_DETAIL
    PTR_Feedback.QuestSubmit:SetScript("OnEvent", function(self, event, ...)
        if (event == "QUEST_COMPLETE") then
            if (PTR_Feedback.IsTargetQuest() and (not GetCVarBool("showNPETutorials")) or (UnitLevel(PTR_Feedback.Data.unitToken) >= (NPE_TUTORIAL_COMPLETE_LEVEL or 1))) then
                self:Show()
            end
        elseif (event == "QUEST_TURNED_IN") then
            if (not GetCVarBool("showNPETutorials")) or (UnitLevel(PTR_Feedback.Data.unitToken) >= (NPE_TUTORIAL_COMPLETE_LEVEL or 1)) then
                local questID = select(1,...)
                --submit diagnostics
                local commentField = PTR_Feedback.QuestSubmit.AdditionalInfo:GetText()
                commentField = commentField:gsub(",", "")
                if (PTR_Feedback.QuestSubmit.Choice > 0) or (#commentField > 0) then
                    PTR_Feedback.SendResults(PTR_Feedback.Data.QUEST_TURNED_IN, PTR_Feedback.QuestSubmit.Choice, questID, commentField, PTR_Feedback.GetQuestHistory())
                    UIErrorsFrame:AddMessage("Your feedback has been received.")
                end
                PTR_Feedback.QuestSubmit.Choice = PTR_Feedback.ExclusiveCheckButton(PTR_Feedback.QuestSubmit.CheckButtons, 0)
                PTR_Feedback.QuestSubmit.AdditionalInfo:SetText("")
            end
            self:Hide()
        elseif (event == "QUEST_FINISHED") then
            PTR_Feedback.QuestSubmit.Choice = PTR_Feedback.ExclusiveCheckButton(PTR_Feedback.QuestSubmit.CheckButtons, 0)
            PTR_Feedback.QuestSubmit.AdditionalInfo:SetText("")
            self:Hide()
        end
    end)

    PTR_Feedback.QuestSubmit:RegisterEvent("QUEST_COMPLETE")
    PTR_Feedback.QuestSubmit:RegisterEvent("QUEST_TURNED_IN")
    PTR_Feedback.QuestSubmit:RegisterEvent("QUEST_FINISHED") --called when quest window closes

    ---------------------------------------------------IMPORTANT QUEST PROMPT---------------------------------------------------
    --========================================================================================================================--
end

--========================================================================================================================--
if IsGMClient() then
    PTRFeedbackAddonSetup = false
    
    SLASH_PTRFEEDBACK1 = '/ptrfeedback'
    function handler(msg, editbox)
        if msg == '' then
        DEFAULT_CHAT_FRAME:AddMessage("PTR Feedback is currently disabled.")
        DEFAULT_CHAT_FRAME:AddMessage("To setup the PTR Feedback addon:")
        DEFAULT_CHAT_FRAME:AddMessage("/ptrfeedback setup")
        DEFAULT_CHAT_FRAME:AddMessage("To set the boss kill probability to 100:")
        DEFAULT_CHAT_FRAME:AddMessage("/ptrfeedback always")
        DEFAULT_CHAT_FRAME:AddMessage("To set the boss kill probability to 20 (Normal):")
        DEFAULT_CHAT_FRAME:AddMessage("/ptrfeedback normal")
        end
        if msg == 'setup' then
            if PTRFeedbackAddonSetup then
                print("The PTR Feedback Addon is already setup.")
            else
                print("Setting up the PTR Feedback Addon...")
                SetupPTRFeedbackFrames()
                PTRFeedbackAddonSetup = true
            end
        end
    end
    SlashCmdList["PTRFEEDBACK"] = handler
else
    SetupPTRFeedbackFrames()  
end