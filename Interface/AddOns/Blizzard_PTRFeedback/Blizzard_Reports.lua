local classicReportOffset = 1000

function PTR_IssueReporter.AttachDefaultCollectionToSurvey(survey)
    local collector = PTR_IssueReporter.DataCollectorTypes
    local GetFaction = function()
        return select(1, UnitFactionGroup(PTR_IssueReporter.Data.UnitTokens.Player))
    end
    
    local GetRaceID = function()
        return select(3, UnitRace(PTR_IssueReporter.Data.UnitTokens.Player))
    end
    
    local GetGender = function()
        return UnitSex(PTR_IssueReporter.Data.UnitTokens.Player)
    end
    
    local GetPlayerLevel = function()
        return UnitLevel(PTR_IssueReporter.Data.UnitTokens.Player)
    end
    
    local GetClassID = function()
        return select(3, UnitClass(PTR_IssueReporter.Data.UnitTokens.Player))
    end
    
    survey:AddDataCollection(1, collector.RunFunction, PTR_IssueReporter.GetMessageKey)
    survey:AddDataCollection(2, collector.SurveyID)
    survey:AddDataCollection(3, collector.RunFunction, GetPlayerLevel)
    survey:AddDataCollection(4, collector.RunFunction, GetFaction)
    survey:AddDataCollection(5, collector.RunFunction, GetRaceID)
    survey:AddDataCollection(6, collector.RunFunction, GetGender)
    survey:AddDataCollection(7, collector.RunFunction, GetClassID)
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.CreateReports()
    local baseCollectors = 7
    local collector = PTR_IssueReporter.DataCollectorTypes
    local event = PTR_IssueReporter.ReportEventTypes
    local tooltips = PTR_IssueReporter.TooltipTypes
    
    ------------------------------------ Confused Reporting --------------------------------------------
    local confusedReport = PTR_IssueReporter.CreateSurvey(classicReportOffset + 1, "Confused Report")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(confusedReport)
    
    confusedReport:AddDataCollection(baseCollectors + 1, collector.OpenEndedQuestion, "What has caused your confusion?")

    confusedReport:RegisterPopEvent(event.UIButtonClicked, "Confused")
    
    --------------------------------------- Bug Reporting ----------------------------------------------
    local bugReport = PTR_IssueReporter.CreateSurvey(classicReportOffset + 2, "Bug Report")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(bugReport)
    
    bugReport:AddDataCollection(baseCollectors + 1, collector.OpenEndedQuestion, "Please describe the issue:")     
    bugReport:RegisterPopEvent(event.UIButtonClicked, "Bug")
    
    ----------------------------------- Creature Reporting ---------------------------------------------
    local creatureReport = PTR_IssueReporter.CreateSurvey(classicReportOffset + 3, "Bug Report: %s")
    creatureReport:PopulateDynamicTitleToken(1, "Name")
    creatureReport:AttachModelViewer("ID")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(creatureReport)
    
    creatureReport:AddDataCollection(baseCollectors + 1, collector.FromDataPackage, "ID")
    creatureReport:AddDataCollection(baseCollectors + 2, collector.OpenEndedQuestion, "What was the issue with this creature?")

    creatureReport:RegisterPopEvent(event.Tooltip, tooltips.unit)
    
    --------------------------------------- Quest Reporting -------------------------------------------
    local questReport = PTR_IssueReporter.CreateSurvey(classicReportOffset + 4, "Bug Report: %s")
    questReport:PopulateDynamicTitleToken(1, "Name")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(questReport)
    
    questReport:AddDataCollection(baseCollectors + 1, collector.FromDataPackage, "ID")
    questReport:AddDataCollection(baseCollectors + 2, collector.OpenEndedQuestion, "What was the issue with this quest?")
    
    local AutoQuestReport = PTR_IssueReporter.CreateSurvey(4, "Bug Report: Quest")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(AutoQuestReport)
    
    AutoQuestReport:AddDataCollection(baseCollectors + 1, collector.FromDataPackage, "ID")
    AutoQuestReport:AddDataCollection(baseCollectors + 2, collector.OpenEndedQuestion, "Did you experience any issues?")
    
    questReport:RegisterPopEvent(event.Tooltip, tooltips.quest)
    AutoQuestReport:RegisterFrameAttachedSurvey(QuestFrame, event.QuestRewardFrameShown, {event.QuestFrameClosed, event.QuestTurnedIn}, -8, 62) 
    
    ------------------------------------- Spell Reporting ----------------------------------------------
    local GetIconFromSpellID = function(value)
        return select(3, GetSpellInfo(value))
    end
    
    local spellReport = PTR_IssueReporter.CreateSurvey(classicReportOffset + 5, "Bug Report: %s")
    spellReport:PopulateDynamicTitleToken(1, "Name")
    spellReport:AttachIconViewer("ID", GetIconFromSpellID)
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(spellReport)
    
    spellReport:AddDataCollection(baseCollectors + 1, collector.FromDataPackage, "ID")
    spellReport:AddDataCollection(baseCollectors + 2, collector.OpenEndedQuestion, "What was the issue with this spell?")

    spellReport:RegisterPopEvent(event.Tooltip, tooltips.spell)
    
    ------------------------------------- Item Reporting -----------------------------------------------
    local GetIconFromItemID = function(value)
        return select(10, GetItemInfo(value))
    end    
    
    local itemReport = PTR_IssueReporter.CreateSurvey(classicReportOffset + 6, "Bug Report: %s")
    itemReport:PopulateDynamicTitleToken(1, "Name")
    itemReport:AttachIconViewer("ID", GetIconFromItemID)
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(itemReport)
    
    itemReport:AddDataCollection(baseCollectors + 1, collector.FromDataPackage, "ID")
    itemReport:AddDataCollection(baseCollectors + 2, collector.OpenEndedQuestion, "What was the issue with this item?")

    itemReport:RegisterPopEvent(event.Tooltip, tooltips.item)
    
    --------------------------------- Achievement Reporting ---------------------------------------------
    local GetIconFromAchievementID = function(value)
        return select(10, GetAchievementInfo(value))
    end
    
    local achievementReport = PTR_IssueReporter.CreateSurvey(classicReportOffset + 7, "Bug Report: %s")
    achievementReport:PopulateDynamicTitleToken(1, "Name")
    achievementReport:AttachIconViewer("ID", GetIconFromAchievementID)
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(achievementReport)
    
    achievementReport:AddDataCollection(baseCollectors + 1, collector.FromDataPackage, "ID")
    achievementReport:AddDataCollection(baseCollectors + 2, collector.OpenEndedQuestion, "What was the issue with this achievement?")

    achievementReport:RegisterPopEvent(event.Tooltip, tooltips.achievement)
    
    ----------------------------------- Currency Reporting ---------------------------------------------
    local GetIconFromCurrencyID = function(value)
        return select(3, GetCurrencyInfo(value))
    end
    
    local currencyReport = PTR_IssueReporter.CreateSurvey(classicReportOffset + 8, "Bug Report: %s")
    currencyReport:PopulateDynamicTitleToken(1, "Name")
    currencyReport:AttachIconViewer("ID", GetIconFromCurrencyID)
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(currencyReport)
    
    currencyReport:AddDataCollection(baseCollectors + 1, collector.FromDataPackage, "ID")
    currencyReport:AddDataCollection(baseCollectors + 2, collector.OpenEndedQuestion, "What was the issue with this currency?")

    currencyReport:RegisterPopEvent(event.Tooltip, tooltips.currency)
    
    ---------------------------------- Classic Talent Reporting -------------------------------------------
    local GetIconFromTalentID = function(value)
        local IDString = {}
        for s in value:gmatch("[^-]+") do
            table.insert(IDString, s)
        end
        if (IDString[2]) then
            local frame = _G["TalentFrameTalent"..IDString[2].."IconTexture"]
            if (frame) then
                return frame:GetTexture()
            end
        end
        
        return "Interface\\Icons\\INV_Misc_QuestionMark"
    end
    
    local classicTalentReport = PTR_IssueReporter.CreateSurvey(classicReportOffset + 9, "Bug Report: %s")
    classicTalentReport:PopulateDynamicTitleToken(1, "Name")
    classicTalentReport:AttachIconViewer("ID", GetIconFromTalentID)
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(classicTalentReport)
    
    classicTalentReport:AddDataCollection(baseCollectors + 1, collector.FromDataPackage, "ID")
    classicTalentReport:AddDataCollection(baseCollectors + 2, collector.OpenEndedQuestion, "What was the issue with this talent?")

    classicTalentReport:RegisterPopEvent(event.Tooltip, tooltips.talent)
    
    ---------------------------------- Classic Skills Reporting -------------------------------------------   
    local classicSkillsReport = PTR_IssueReporter.CreateSurvey(classicReportOffset + 10, "Bug Report: %s")
    classicSkillsReport:PopulateDynamicTitleToken(1, "Name")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(classicSkillsReport)
    
    classicSkillsReport:AddDataCollection(baseCollectors + 1, collector.FromDataPackage, "Name")
    classicSkillsReport:AddDataCollection(baseCollectors + 2, collector.FromDataPackage, "ID") -- This is actually their skill lvl
    classicSkillsReport:AddDataCollection(baseCollectors + 3, collector.OpenEndedQuestion, "What was the issue with this skill?")

    classicSkillsReport:RegisterPopEvent(event.Tooltip, tooltips.skill)

    ---------------------------------- Classic Glyph Reporting -------------------------------------------   
    local classicGlyphReport = PTR_IssueReporter.CreateSurvey(classicReportOffset + 11, "Bug Report: %s")

    classicGlyphReport:PopulateDynamicTitleToken(1, "Name")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(classicGlyphReport)
    
    classicGlyphReport:AddDataCollection(baseCollectors + 1, collector.RunFunction, "ID")
    classicGlyphReport:AddDataCollection(baseCollectors + 2, collector.OpenEndedQuestion, "What was the issue with this glyph?")

    classicGlyphReport:RegisterPopEvent(event.Tooltip, tooltips.glyph)
    
    --------------------------------------- Character Customization Bug Reporting ----------------------------------------------
    local barberShopReport = PTR_IssueReporter.CreateSurvey(classicReportOffset + 12, "Bug Report")
    
    local GetRaceID = function()
        return select(3, UnitRace(PTR_IssueReporter.Data.UnitTokens.Player))
    end

    local GetAllCustomizationSelections = function()
        local customizationCategoryData = C_BarberShop.GetAvailableCustomizations()
        --if the function has changed and doesn't exist then we'll pass through an error index
        if customizationCategoryData == nil then
            return "-1"
        end

        local customizationDataString = ""
        local count = 0

        for key, category in pairs (customizationCategoryData) do
            for optionKey, optionValue in pairs(category.options) do
                if(optionValue.choices[optionValue.currentChoiceIndex].id) then
                    customizationDataString = customizationDataString .. "," .. optionValue.choices[optionValue.currentChoiceIndex].id
                    count = count + 1
                 end
            end
        end
        
        customizationDataString = count .. customizationDataString

        return customizationDataString
    end

    local GetClassID = function()
        return select(3, UnitClass(PTR_IssueReporter.Data.UnitTokens.Player))
    end

    local GetGender = function()
        local currentCharacterData = C_BarberShop.GetCurrentCharacterData()
		return currentCharacterData.sex
    end

    barberShopReport:AddDataCollection(baseCollectors + 1, collector.RunFunction, PTR_IssueReporter.GetMessageKey)
    barberShopReport:AddDataCollection(baseCollectors + 2, collector.OpenEndedQuestion, "Please describe the bug:") 
    barberShopReport:AddDataCollection(baseCollectors + 3, collector.SurveyID)    
    barberShopReport:AddDataCollection(baseCollectors + 4, collector.RunFunction, GetClassID)
    barberShopReport:AddDataCollection(baseCollectors + 5, collector.RunFunction, GetGender)
    barberShopReport:AddDataCollection(baseCollectors + 6, collector.RunFunction, GetRaceID)
    barberShopReport:AddDataCollection(baseCollectors + 7, collector.RunFunction, GetAllCustomizationSelections)
    barberShopReport:RegisterButtonEvent(event.BarberShopOpened)
    barberShopReport:RegisterButtonEventEnd(event.BarberShopClosed)
    barberShopReport:RegisterButtonEventEnd(event.MapIDExit)
end
----------------------------------------------------------------------------------------------------

