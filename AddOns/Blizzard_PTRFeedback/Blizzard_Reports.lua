PTR_IssueReporter.Data.Message_Key = "[*M&^$#@]"

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
        return UnitEffectiveLevel(PTR_IssueReporter.Data.UnitTokens.Player)
    end
    
    local GetClassID = function()
        return select(3, UnitClass(PTR_IssueReporter.Data.UnitTokens.Player))
    end
    
    local GetSpecID = function()
        return select(1, GetSpecializationInfo(GetSpecialization() or 1))
    end
    
    local GetCurrentiLvl = function()
        return select(2, GetAverageItemLevel())
    end
    
    survey:AddDataCollection(1, collector.RunFunction, PTR_IssueReporter.GetMessageKey)
    survey:AddDataCollection(2, collector.SurveyID)
    survey:AddDataCollection(3, collector.RunFunction, GetPlayerLevel)
    survey:AddDataCollection(4, collector.RunFunction, GetFaction)
    survey:AddDataCollection(5, collector.RunFunction, GetRaceID)
    survey:AddDataCollection(6, collector.RunFunction, GetGender)
    survey:AddDataCollection(7, collector.RunFunction, GetClassID)
    survey:AddDataCollection(8, collector.RunFunction, GetSpecID)
    survey:AddDataCollection(9, collector.RunFunction, GetCurrentiLvl)
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.CreateReports()
    local baseCollectors = 9
    local collector = PTR_IssueReporter.DataCollectorTypes
    local event = PTR_IssueReporter.ReportEventTypes
    local tooltips = PTR_IssueReporter.TooltipTypes
    ----------------------------------- Suppressed Locations -------------------------------------------       
    local IslandMapIDs = {
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
    PTR_IssueReporter.AddMapToSuppressedList(IslandMapIDs) 
    
    ------------------------------------ Confused Reporting --------------------------------------------
    local confusedReport = PTR_IssueReporter.CreateSurvey(1, "Confused Report")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(confusedReport)
    
    confusedReport:AddDataCollection(baseCollectors + 1, collector.OpenEndedQuestion, "What has caused your confusion?")

    confusedReport:RegisterPopEvent(event.UIButtonClicked, "Confused")
    
    --------------------------------------- Bug Reporting ----------------------------------------------
    local bugReport = PTR_IssueReporter.CreateSurvey(2, "Bug Report")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(bugReport)
    
    bugReport:AddDataCollection(baseCollectors + 1, collector.OpenEndedQuestion, "Please describe the issue:")     
    bugReport:RegisterPopEvent(event.UIButtonClicked, "Bug")
    
    ----------------------------------- Creature Reporting ---------------------------------------------
    local creatureReport = PTR_IssueReporter.CreateSurvey(3, "Bug Report: %s")
    creatureReport:PopulateDynamicTitleToken(1, "Name")
    creatureReport:AttachModelViewer("ID")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(creatureReport)
    
    creatureReport:AddDataCollection(baseCollectors + 1, collector.FromDataPackage, "ID")
    creatureReport:AddDataCollection(baseCollectors + 2, collector.OpenEndedQuestion, "What was the issue with this creature?")

    creatureReport:RegisterPopEvent(event.Tooltip, tooltips.unit)
    
    --------------------------------------- Quest Reporting -------------------------------------------
    local questReport = PTR_IssueReporter.CreateSurvey(4, "Bug Report: %s")
    questReport:PopulateDynamicTitleToken(1, "Name")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(questReport)
    
    questReport:AddDataCollection(baseCollectors + 1, collector.FromDataPackage, "ID")
    questReport:AddDataCollection(baseCollectors + 2, collector.OpenEndedQuestion, "What was the issue with this quest?")
    
    local AutoQuestReport = PTR_IssueReporter.CreateSurvey(4, "Bug Report: Quest")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(AutoQuestReport)
    
    AutoQuestReport:AddDataCollection(baseCollectors + 1, collector.FromDataPackage, "ID")
    AutoQuestReport:AddDataCollection(baseCollectors + 2, collector.OpenEndedQuestion, "Did you experience any issues?")
    
    questReport:RegisterPopEvent(event.Tooltip, tooltips.quest)
    AutoQuestReport:RegisterFrameAttachedSurvey(QuestFrame, event.QuestRewardFrameShown, {event.QuestFrameClosed, event.QuestTurnedIn}, 0, 0) 
    
    ------------------------------------- Island Reporting ----------------------------------------------
    local islandReport = PTR_IssueReporter.CreateSurvey(5, "Bug Report: %s")
    islandReport:PopulateDynamicTitleToken(1, "Name")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(islandReport)
    
    islandReport:AddDataCollection(baseCollectors + 1, collector.FromDataPackage, "ID")
    islandReport:AddDataCollection(baseCollectors + 2, collector.FromDataPackage, "DifficultyID")
    islandReport:AddDataCollection(baseCollectors + 3, collector.OpenEndedQuestion, "Did you have any issues with this Island Expedition?")

    local islandDifficultIDs = {
        38,
        39,
        40,
        45,
    }
    islandReport:RegisterPopEvent(event.MapDifficultyIDEnded, islandDifficultIDs)

    ------------------------------------ Warfronts Reporting ---------------------------------------------
    local warfrontsReport = PTR_IssueReporter.CreateSurvey(6, "Bug Report: %s")
    warfrontsReport:PopulateDynamicTitleToken(1, "Name")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(warfrontsReport)
    
    warfrontsReport:AddDataCollection(baseCollectors + 1, collector.FromDataPackage, "ID")
    warfrontsReport:AddDataCollection(baseCollectors + 2, collector.FromDataPackage, "DifficultyID")
    warfrontsReport:AddDataCollection(baseCollectors + 3, collector.OpenEndedQuestion, "Did you encounter any issues with this Warfront?")

    local warfrontMapIDs = {
        2111,
        2105,
        1876,
        1943,
    }
    warfrontsReport:RegisterPopEvent(event.MapIDExit, warfrontMapIDs)        
    
    ------------------------------------- Spell Reporting ----------------------------------------------
    local GetIconFromSpellID = function(value)
        return select(3, GetSpellInfo(value))
    end
    
    local spellReport = PTR_IssueReporter.CreateSurvey(7, "Bug Report: %s")
    spellReport:PopulateDynamicTitleToken(1, "Name")
    spellReport:AttachIconViewer("ID", GetIconFromSpellID)
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(spellReport)
    
    spellReport:AddDataCollection(baseCollectors + 1, collector.FromDataPackage, "ID")
    spellReport:AddDataCollection(baseCollectors + 2, collector.OpenEndedQuestion, "What was the issue with this spell?")

    spellReport:RegisterPopEvent(event.Tooltip, tooltips.spell)
    
    ------------------------------------ Encounter Reporting -------------------------------------------
    local encounterReport = PTR_IssueReporter.CreateSurvey(8, "Bug Report: %s")
    encounterReport:PopulateDynamicTitleToken(1, "Name")
    encounterReport:AttachModelViewer("DisplayInfoID", true)
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(encounterReport)
    
    encounterReport:AddDataCollection(baseCollectors + 1, collector.FromDataPackage, "ID")
    encounterReport:AddDataCollection(baseCollectors + 2, collector.FromDataPackage, "DifficultyID")
    encounterReport:AddDataCollection(baseCollectors + 3, collector.OpenEndedQuestion, "What was the issue with this boss?")
    
    local automaticEncounterReport = PTR_IssueReporter.CreateSurvey(8, "Bug Report: %s")
    automaticEncounterReport:PopulateDynamicTitleToken(1, "Name")
    automaticEncounterReport:AttachModelViewer("DisplayInfoID", true)
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(automaticEncounterReport)
    
    automaticEncounterReport:AddDataCollection(baseCollectors + 1, collector.FromDataPackage, "ID")
    automaticEncounterReport:AddDataCollection(baseCollectors + 2, collector.FromDataPackage, "DifficultyID")
    automaticEncounterReport:AddDataCollection(baseCollectors + 3, collector.OpenEndedQuestion, "Did you encounter any issues with this boss?")
        
    automaticEncounterReport:RegisterPopEvent(event.EncounterSuccess)
    
    encounterReport:SetButton("I have found an issue with this boss.", PTR_IssueReporter.Assets.BossReportIcon)
    encounterReport:RegisterButtonEvent(event.EncounterFailed)
    encounterReport:RegisterButtonEventEnd(event.EncounterSuccess)
    encounterReport:RegisterButtonEventEnd(event.MapIDExit)
    
    ------------------------------------- Item Reporting -----------------------------------------------
    local GetIconFromItemID = function(value)
        return select(10, GetItemInfo(value))
    end    
    
    local itemReport = PTR_IssueReporter.CreateSurvey(9, "Bug Report: %s")
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
    
    local achievementReport = PTR_IssueReporter.CreateSurvey(10, "Bug Report: %s")
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
    
    local currencyReport = PTR_IssueReporter.CreateSurvey(11, "Bug Report: %s")
    currencyReport:PopulateDynamicTitleToken(1, "Name")
    currencyReport:AttachIconViewer("ID", GetIconFromCurrencyID)
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(currencyReport)
    
    currencyReport:AddDataCollection(baseCollectors + 1, collector.FromDataPackage, "ID")
    currencyReport:AddDataCollection(baseCollectors + 2, collector.OpenEndedQuestion, "What was the issue with this currency?")

    currencyReport:RegisterPopEvent(event.Tooltip, tooltips.currency)
    
    -------------------------------- Pet Battle Creature Reporting ---------------------------------------
    local petBattleCreatureReport = PTR_IssueReporter.CreateSurvey(12, "Bug Report: Pet Battles")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(petBattleCreatureReport)
    
    petBattleCreatureReport:AddDataCollection(baseCollectors + 1, collector.OpenEndedQuestion, "What was the issue with pet battles?")

    petBattleCreatureReport:SetButton("I have found an issue with this encounter.", PTR_IssueReporter.Assets.PetReportIcon)
    petBattleCreatureReport:RegisterButtonEvent(event.PetBattleStart)
    petBattleCreatureReport:RegisterButtonEventEnd(event.PetBattleEnd)
    petBattleCreatureReport:RegisterButtonEventEnd(event.MapIDExit)
    
    -------------------------------- Azerite Essences Reporting -----------------------------------------
    local GetIconFromAzeriteEssenceID = function(value)
        local azeriteData = C_AzeriteEssence.GetEssenceInfo(value)
        if (azeriteData) then
            return azeriteData.icon
        else
            return nil
        end
    end
    
    local azeriteEssenceReport = PTR_IssueReporter.CreateSurvey(13, "Bug Report: %s")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(azeriteEssenceReport)
    azeriteEssenceReport:PopulateDynamicTitleToken(1, "Name")
    azeriteEssenceReport:AttachIconViewer("ID", GetIconFromAzeriteEssenceID)
    
    azeriteEssenceReport:AddDataCollection(baseCollectors + 1, collector.OpenEndedQuestion, "What was the issue with this Azerite Essence?")
    -- ID and comment are Inverted.  Needs to be fixed before 8.3.
    azeriteEssenceReport:AddDataCollection(baseCollectors + 2, collector.FromDataPackage, "ID") 

    azeriteEssenceReport:RegisterPopEvent(event.Tooltip, tooltips.azerite)
    
    ----------------------------------------------------------------------------------------------------
end