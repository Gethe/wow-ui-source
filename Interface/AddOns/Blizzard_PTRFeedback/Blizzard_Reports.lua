PTR_IssueReporter.Data.Message_Key = "[*WSS&^$&L]"
PTR_IssueReporter.Data.Feedback_Message_Key = "[*WSS&^$&LF]"
PTR_IssueReporter.Data.Current_Message_Key = PTR_IssueReporter.Data.Message_Key
PTR_IssueReporter.LockedReports = {}

function PTR_IssueReporter.AttachDefaultCollectionToSurvey(survey, ignoreTypeQuestion, setAsFeedback)
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
        -- There are rare occurrences where it appeared either GetSpecID or GetCurrentiLvl were returning nil, in case nothing is returned for the select, sending 0 for data completeness
        return select(1, C_SpecializationInfo.GetSpecializationInfo(C_SpecializationInfo.GetSpecialization() or 1)) or 0
    end
    
    local GetCurrentiLvl = function()
        return select(2, GetAverageItemLevel()) or 0
    end

	local GetCurrentConduits = function()
		local results = ""
		local soulbindID = C_Soulbinds.GetActiveSoulbindID()

		if (soulbindID > 0) then
			local soulbindData = C_Soulbinds.GetSoulbindData(soulbindID)

			if (soulbindData) and (soulbindData.tree) and (soulbindData.tree.nodes) then
				for i, nodeInfo in pairs(soulbindData.tree.nodes) do
					if (nodeInfo.conduitID > 0) and (nodeInfo.state == Enum.SoulbindNodeState.Selected) then
						results = results .. ":" .. nodeInfo.conduitID
					end
				end
			end
		end

		return results
	end

	local GetCurrentSoulbindTraits = function()
		local results = ""
		local soulbindID = C_Soulbinds.GetActiveSoulbindID()

		if (soulbindID > 0) then
			local soulbindData = C_Soulbinds.GetSoulbindData(soulbindID)

			if (soulbindData) and (soulbindData.tree) and (soulbindData.tree.nodes) then
				for i, nodeInfo in pairs(soulbindData.tree.nodes) do
					if (nodeInfo.conduitID == 0) and (nodeInfo.spellID > 0) and (nodeInfo.state == Enum.SoulbindNodeState.Selected) then
						results = results .. ":" .. nodeInfo.spellID
					end
				end
			end
		end

		return results
	end
    
    local IsQuestSyncEnabled = function()
        if (C_QuestSession) and (C_QuestSession.Exists) and (C_QuestSession.Exists()) then
            return 1
        else
            return 0
        end
    end
    
    local GetActiveChromieTimeID = function()
        local chromieTimeData = C_ChromieTime.GetChromieTimeExpansionOptions()
        
        for index, expansionOption in pairs (chromieTimeData) do
            if (expansionOption) and (expansionOption.alreadyOn) then
            
                return expansionOption.id
            end
        end
        
        return 0
    end
    
    local IsTimerunningActive = function()
        if (C_UnitAuras.GetPlayerAuraBySpellID(1213439)) then
            return 1
        end
        
        return 0
    end

	local GetCurrentQuestStatus = function(dataPackage)
		local results = ""
		
		for i=1, C_QuestLog.GetNumQuestLogEntries() do
			local questInfo = C_QuestLog.GetInfo(i)
			if (questInfo) and (questInfo.questID) and (questInfo.questID > 0) then
				local questEntry = ":" .. questInfo.questID
				local objectives = C_QuestLog.GetQuestObjectives(questInfo.questID)
		
				if (objectives) then
					for _, objectiveInfo in pairs(objectives) do
						questEntry = questEntry .. "." .. objectiveInfo.numFulfilled
					end
				end

				results = results .. questEntry
			end
		end

		return results
	end
    
    if (setAsFeedback) then
        survey:AddDataCollection(collector.RunFunction, PTR_IssueReporter.GetFeedbackMessageKey)
    else
        survey:AddDataCollection(collector.RunFunction, PTR_IssueReporter.GetMessageKey)
    end
    
    survey:AddDataCollection(collector.SurveyID)
    survey:AddDataCollection(collector.RunFunction, GetPlayerLevel)
    survey:AddDataCollection(collector.RunFunction, GetFaction)
    survey:AddDataCollection(collector.RunFunction, GetRaceID)
    survey:AddDataCollection(collector.RunFunction, GetGender)
    survey:AddDataCollection(collector.RunFunction, GetClassID)
    survey:AddDataCollection(collector.RunFunction, GetSpecID)
    survey:AddDataCollection(collector.RunFunction, GetCurrentiLvl)    
    survey:AddDataCollection(collector.RunFunction, IsQuestSyncEnabled)
    survey:AddDataCollection(collector.RunFunction, GetCurrentQuestStatus)
    survey:AddDataCollection(collector.RunFunction, GetActiveChromieTimeID)
    survey:AddDataCollection(collector.RunFunction, IsTimerunningActive)
    
    if not (ignoreTypeQuestion) then
        survey:AddDataCollection(collector.SelectOne_MessageKeyUpdater, { { Choice = "Bug", Key = PTR_IssueReporter.Data.Message_Key }, { Choice = "Feedback", Key = PTR_IssueReporter.Data.Feedback_Message_Key }}, nil, true)
    end
end
--------------------------------------------------------------------------------------------------------
function PTR_IssueReporter.CreateReports()
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
    --local confusedReport = PTR_IssueReporter.CreateSurvey(1, "Feedback Report")
    --PTR_IssueReporter.AttachDefaultCollectionToSurvey(confusedReport, true, true)
    
    --confusedReport:AddDataCollection(collector.OpenEndedQuestion, "What is your Feedback for this Zone?")

    --confusedReport:RegisterPopEvent(event.UIButtonClicked, "Confused")
    
    --------------------------------------- Bug Reporting ----------------------------------------------
    local bugReport = PTR_IssueReporter.CreateSurvey(2, "Bug Report")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(bugReport, true)
    
    bugReport:AddDataCollection(collector.OpenEndedQuestion, "Please describe the issue:")     
    bugReport:RegisterPopEvent(event.UIButtonClicked, "Zone Bug")
    
    ----------------------------------- Creature Reporting ---------------------------------------------
    local creatureReport = PTR_IssueReporter.CreateSurvey(3, "Issue Report: %s")
    creatureReport:PopulateDynamicTitleToken(1, "Name")
    creatureReport:AttachModelViewer("ID")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(creatureReport, true)
    
    creatureReport:AddDataCollection(collector.FromDataPackage, "ID")
    creatureReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with this creature?")

    creatureReport:RegisterPopEvent(event.Tooltip, tooltips.unit)

     ----------------------------------- AI Bot Reporting ---------------------------------------------
    local GetCreatureIDFromUnitGuid = function(guid)
        if (guid == nil) then
            return
        end
        
		local lines = {}
		for s in guid:gmatch("[^-]+") do
			table.insert(lines, s)
		end
        
        if (lines[6]) then
            return lines[6]
        end
    end
    
    local GetFollowerCIDString = function()
        if IsInRaid() then
            return ""
        end
        
        if not IsInGroup() then
            return ""
        end
        
        local returnValue = ""
        for i = 1, GetNumGroupMembers(), 1 do
            local unit = "party"..i
            if (PTR_IssueReporter.IsUnitAIFollower(unit)) then
                if returnValue == "" then
                    returnValue = GetCreatureIDFromUnitGuid(UnitGUID(unit))
                else
                    returnValue = returnValue .. ":" .. GetCreatureIDFromUnitGuid(UnitGUID(unit))
                end                
            end
        end
        
        return returnValue
    end    
    
    --[[
    local aiFollowerReport = PTR_IssueReporter.CreateSurvey(18, "Issue Report: %s")
    aiFollowerReport:PopulateDynamicTitleToken(1, "Name")
    aiFollowerReport:AttachModelViewer("ID")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(aiFollowerReport, true)
    
    aiFollowerReport:AddDataCollection(collector.FromDataPackage, "ID")
    aiFollowerReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with this follower?")
    aiFollowerReport:AddDataCollection(collector.RunFunction, GetFollowerCIDString)
    aiFollowerReport:RegisterPopEvent(event.Tooltip, tooltips.aibot)
    
    local aiGroupReport = PTR_IssueReporter.CreateSurvey(19, "AI Follower Issue Report")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(aiGroupReport, true)
    
    aiGroupReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with your followers?")
    aiGroupReport:AddDataCollection(collector.RunFunction, GetFollowerCIDString)
    
    aiGroupReport:SetButton("I have found an issue with an AI Follower.", PTR_IssueReporter.Assets.AIBotIcon)
    aiGroupReport:RegisterButtonEvent(event.AIBotsJoinedParty)
    aiGroupReport:RegisterButtonEventEnd(event.AIBotsLeftParty)
    ]]--
    
    --------------------------------------- Quest Reporting -------------------------------------------
    local IsQuestDisabledFromQuestSync = function(dataPackage)
        if (dataPackage) and (dataPackage.ID) and (C_QuestLog) and (C_QuestLog.IsQuestDisabledForSession) and (C_QuestLog.IsQuestDisabledForSession(dataPackage.ID)) then
            return 1
        else
            return 0
        end   
    end
    
    local questReport = PTR_IssueReporter.CreateSurvey(4, "Issue Report: %s")
    questReport:PopulateDynamicTitleToken(1, "Name")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(questReport)
    
    questReport:AddDataCollection(collector.FromDataPackage, "ID")
    questReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with this quest?")    
    questReport:AddDataCollection(collector.RunFunction, IsQuestDisabledFromQuestSync)
    
    local AutoQuestReport = PTR_IssueReporter.CreateSurvey(4, "Issue Report: Quest")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(AutoQuestReport)
    
    AutoQuestReport:AddDataCollection(collector.FromDataPackage, "ID")
    AutoQuestReport:AddDataCollection(collector.OpenEndedQuestion, "Did you experience any issues?")
    AutoQuestReport:AddDataCollection(collector.RunFunction, IsQuestDisabledFromQuestSync)
    
    questReport:RegisterPopEvent(event.Tooltip, tooltips.quest)
    AutoQuestReport:RegisterFrameAttachedSurvey(QuestFrame, event.QuestRewardFrameShown, {event.QuestFrameClosed, event.QuestTurnedIn}, 0, 0) 
    
    ------------------------------------- Island Reporting ----------------------------------------------
    local islandReport = PTR_IssueReporter.CreateSurvey(5, "Issue Report: %s")
    islandReport:PopulateDynamicTitleToken(1, "Name")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(islandReport, true)
    
    islandReport:AddDataCollection(collector.FromDataPackage, "ID")
    islandReport:AddDataCollection(collector.FromDataPackage, "DifficultyID")
    islandReport:AddDataCollection(collector.OpenEndedQuestion, "Did you have any issues with this Island Expedition?")

    local islandDifficultIDs = {
        38,
        39,
        40,
        45,
    }
    islandReport:RegisterPopEvent(event.MapDifficultyIDEnded, islandDifficultIDs)

    ------------------------------------ Warfronts Reporting ---------------------------------------------
    local warfrontsReport = PTR_IssueReporter.CreateSurvey(6, "Issue Report: %s")
    warfrontsReport:PopulateDynamicTitleToken(1, "Name")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(warfrontsReport, true)
    
    warfrontsReport:AddDataCollection(collector.FromDataPackage, "ID")
    warfrontsReport:AddDataCollection(collector.FromDataPackage, "DifficultyID")
    warfrontsReport:AddDataCollection(collector.OpenEndedQuestion, "Did you encounter any issues with this Warfront?")

    local warfrontMapIDs = {
        2111,
        2105,
        1876,
        1943,
    }
    warfrontsReport:RegisterPopEvent(event.MapIDExit, warfrontMapIDs)        
    
    ------------------------------------- Spell Reporting ----------------------------------------------   
    local spellReport = PTR_IssueReporter.CreateSurvey(7, "Issue Report: %s")
    spellReport:PopulateDynamicTitleToken(1, "Name")
    spellReport:AttachIconViewer("ID", C_Spell.GetSpellTexture)
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(spellReport, true)
    
    spellReport:AddDataCollection(collector.FromDataPackage, "ID")
    spellReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with this spell?")

    spellReport:RegisterPopEvent(event.Tooltip, tooltips.spell)
    
    ------------------------------------ Encounter Reporting -------------------------------------------
	local GetMythicPlusInfo = function()
		local returnString = ""
		local keystoneLevel, activeAffixes, keystoneCharged = C_ChallengeMode.GetActiveKeystoneInfo()

		if (keystoneLevel > 0) then
			returnString = keystoneLevel .. ":" .. tostring(keystoneCharged)
			for key, affixId in pairs (activeAffixes) do
				returnString = returnString .. ":" .. affixId
			end
		end

		return returnString
	end

    local encounterReport = PTR_IssueReporter.CreateSurvey(8, "Issue Report: %s")
    encounterReport:PopulateDynamicTitleToken(1, "Name")
    encounterReport:AttachModelViewer("DisplayInfoID", true)
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(encounterReport)
    
    encounterReport:AddDataCollection(collector.FromDataPackage, "ID")
    encounterReport:AddDataCollection(collector.FromDataPackage, "DifficultyID")
    encounterReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with this boss?")
	encounterReport:AddDataCollection(collector.RunFunction, GetMythicPlusInfo)
    
    local automaticEncounterReport = PTR_IssueReporter.CreateSurvey(8, "Issue Report: %s")
    automaticEncounterReport:PopulateDynamicTitleToken(1, "Name")
    automaticEncounterReport:AttachModelViewer("DisplayInfoID", true)
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(automaticEncounterReport)
    
    automaticEncounterReport:AddDataCollection(collector.FromDataPackage, "ID")
    automaticEncounterReport:AddDataCollection(collector.FromDataPackage, "DifficultyID")
    automaticEncounterReport:AddDataCollection(collector.OpenEndedQuestion, "Did you encounter any issues with this boss?")
	automaticEncounterReport:AddDataCollection(collector.RunFunction, GetMythicPlusInfo)
        
    automaticEncounterReport:RegisterPopEvent(event.EncounterSuccess)
    
    encounterReport:SetButton("I have found an issue with this boss.", PTR_IssueReporter.Assets.BossReportIcon)
    encounterReport:RegisterButtonEvent(event.EncounterFailed)
    encounterReport:RegisterButtonEventEnd(event.EncounterSuccess)
    encounterReport:RegisterButtonEventEnd(event.MapIDExit)
    
    ------------------------------------- Item Reporting -----------------------------------------------
    local GetIconFromItemID = function(value)
        return select(10, C_Item.GetItemInfo(value))
    end    
    
    local GetBonusListFromID = function(value)
        --[[
        Format of item string:
        item:itemID:enchantID:gemID1:gemID2:gemID3:gemID4:suffixID:uniqueID:linkLevel:specializationID:upgradeTypeID:instanceDifficultyID:numBonusIDs[:bonusID1:bonusID2:...][:upgradeValue1:upgradeValue2:...]:relic1NumBonusIDs[:relic1BonusID1:relic1BonusID2:...]:relic2NumBonusIDs[:relic2BonusID1:relic2BonusID2:...]:relic3NumBonusIDs[:relic3BonusID1:relic3BonusID2:...]
        Note that the 14th entry is the number of bonus Ids
        ]]--
        local itemString = string.match(value.Additional, "item[%-?%d:]+")
        local elements = {}
        local i = 1
        local from, to = string.find(itemString, ":", i)
        while from do
            table.insert(elements, string.sub(itemString, i, from-1))
            i = to + 1
            from, to = string.find(itemString, ":", i)
        end
        table.insert(elements, string.sub(itemString, i))
        
        if table.getn(elements) > 14 then
            local bonusIDs = {}
            local results = ""
            local numberOfBonusIDs = elements[14]
            if (numberOfBonusIDs) and (tonumber(numberOfBonusIDs)) and (tonumber(numberOfBonusIDs) > 0) then
                for index=15, 15 + numberOfBonusIDs do
                    table.insert(bonusIDs,elements[index])
                end
                for _,v in ipairs(bonusIDs) do
                    results = results .. ":" .. v
                end
            end
            return results
        end
        
        return ""
    end

    local itemReport = PTR_IssueReporter.CreateSurvey(9, "Issue Report: %s")
    itemReport:PopulateDynamicTitleToken(1, "Name")
    itemReport:AttachIconViewer("ID", GetIconFromItemID)
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(itemReport, true)
    
    itemReport:AddDataCollection(collector.FromDataPackage, "ID")
    itemReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with this item?")
    itemReport:AddDataCollection(collector.RunFunction, GetBonusListFromID)
    
    itemReport:RegisterPopEvent(event.Tooltip, tooltips.item)
    
    --------------------------------- Achievement Reporting ---------------------------------------------
    local GetIconFromAchievementID = function(value)
        return select(10, GetAchievementInfo(value))
    end
    
    local achievementReport = PTR_IssueReporter.CreateSurvey(10, "Issue Report: %s")
    achievementReport:PopulateDynamicTitleToken(1, "Name")
    achievementReport:AttachIconViewer("ID", GetIconFromAchievementID)
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(achievementReport)
    
    achievementReport:AddDataCollection(collector.FromDataPackage, "ID")
    achievementReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with this achievement?")

    achievementReport:RegisterPopEvent(event.Tooltip, tooltips.achievement)
    
    ----------------------------------- Currency Reporting ---------------------------------------------
    local GetIconFromCurrencyID = function(value)
        return C_CurrencyInfo.GetCurrencyInfo(value).iconFileID;
    end
    
    local currencyReport = PTR_IssueReporter.CreateSurvey(11, "Issue Report: %s")
    currencyReport:PopulateDynamicTitleToken(1, "Name")
    currencyReport:AttachIconViewer("ID", GetIconFromCurrencyID)
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(currencyReport, true)
    
    currencyReport:AddDataCollection(collector.FromDataPackage, "ID")
    currencyReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with this currency?")

    currencyReport:RegisterPopEvent(event.Tooltip, tooltips.currency)
    
    -------------------------------- Pet Battle Creature Reporting ---------------------------------------
    local petBattleCreatureReport = PTR_IssueReporter.CreateSurvey(12, "Issue Report: Pet Battles")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(petBattleCreatureReport, true)
    
    petBattleCreatureReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with pet battles?")

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
    
    local azeriteEssenceReport = PTR_IssueReporter.CreateSurvey(13, "Issue Report: %s")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(azeriteEssenceReport, true)
    azeriteEssenceReport:PopulateDynamicTitleToken(1, "Name")
    azeriteEssenceReport:AttachIconViewer("ID", GetIconFromAzeriteEssenceID)
    
    azeriteEssenceReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with this Azerite Essence?")
    azeriteEssenceReport:AddDataCollection(collector.FromDataPackage, "ID") 

    azeriteEssenceReport:RegisterPopEvent(event.Tooltip, tooltips.azerite)
    --------------------------------------- Garrison Talent Issue Reporting ----------------------------------------------
    local GetIconFromGarrTalentID = function(talentID)
        local talentInfo = C_Garrison.GetTalentInfo(talentID)
        if (talentInfo) and (talentInfo.icon) then
            return talentInfo.icon
        else
            return 0
        end
    end
    
    local GetCurrentTalentTreeStateFromTalentID = function(dataPackage)
        local talentTreeStateString = ""
        if (dataPackage) and (dataPackage.Additional) then
            local talentTreeInfo = C_Garrison.GetTalentTreeInfo(dataPackage.Additional)
            talentTreeStateString = dataPackage.Additional
            for key, talent in pairs (talentTreeInfo.talents) do
                talentTreeStateString = string.format("%s:%s.%s", talentTreeStateString, talent.id, talent.talentRank)
            end
        end
        
        return talentTreeStateString
    end
    
    local garrTalentReport = PTR_IssueReporter.CreateSurvey(14, "Issue Report: %s")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(garrTalentReport, true)
    garrTalentReport:PopulateDynamicTitleToken(1, "Name")
    garrTalentReport:AttachIconViewer("ID", GetIconFromGarrTalentID)
    
    garrTalentReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with this Talent?")
    garrTalentReport:AddDataCollection(collector.FromDataPackage, "ID") 
    garrTalentReport:AddDataCollection(collector.RunFunction, GetCurrentTalentTreeStateFromTalentID) 
    
    garrTalentReport:RegisterPopEvent(event.Tooltip, tooltips.talent)

    --------------------------------------- Recipe Issue Reporting ----------------------------------------------
    local GetIconFromRecipeID = function(value)
        return value
    end
    
    local recipeReport = PTR_IssueReporter.CreateSurvey(15, "Issue Report: %s")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(recipeReport, true)
    recipeReport:PopulateDynamicTitleToken(1, "Name")
    recipeReport:AttachIconViewer("Additional", GetIconFromRecipeID)
    
    recipeReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with this Recipe?")
    recipeReport:AddDataCollection(collector.FromDataPackage, "ID")
    
    recipeReport:RegisterPopEvent(event.Tooltip, tooltips.recipe)
    
    ----------------------------------------------------------------------------------------------------------
    ------------------------------------------ UI Reporting --------------------------------------------------
    ----------------------------------------------------------------------------------------------------------
    local UIPanelIDs = {
        EditMode = 1,
        MountJornal = 2,
        PetJournal = 3,
        ToyBox = 4,
        Heirlooms = 5,
        Appearances = 6,
        AdventureGuide = 7,
        ClassTalent = 8,
        ProfessionTalents = 9,
        WarbandsCharacterSelect = 10,
    }
    
    ----------------------------------------------- Edit Mode ------------------------------------------------
    local editModeReport = PTR_IssueReporter.CreateSurvey(17, "Issue Report: Edit Mode")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(editModeReport, true)
    
    editModeReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with Edit Mode?")
    editModeReport:AddDataCollection(collector.PassValue, UIPanelIDs.EditMode)
    
    editModeReport:SetButton("I have found an issue with edit mode.", PTR_IssueReporter.Assets.EditModeIcon)
    editModeReport:RegisterButtonEvent(event.EditModeEntered)
    editModeReport:RegisterButtonEventEnd(event.EditModeExit)    
    
    -------------------------------------------- Mount Collection ---------------------------------------------
    local mountUIReport = PTR_IssueReporter.CreateSurvey(17, "Issue Report: Mounts UI")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(mountUIReport, true)
    
    mountUIReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with the Mounts UI?")
    mountUIReport:AddDataCollection(collector.PassValue, UIPanelIDs.MountJornal)

    mountUIReport:RegisterUIPanelClick("CollectionsJournal.TabSet", 1)
    
    ------------------------------------------ Pet  Collection ------------------------------------------------
    local petJournalUIReport = PTR_IssueReporter.CreateSurvey(17, "Issue Report: Pet Journal UI")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(petJournalUIReport, true)
    
    petJournalUIReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with the Pet Journal UI?")
    petJournalUIReport:AddDataCollection(collector.PassValue, UIPanelIDs.PetJournal)

    petJournalUIReport:RegisterUIPanelClick("CollectionsJournal.TabSet", 2, true)
    
    ----------------------------------------------- Toy Box ----------------------------------------------------
    local toyBoxUIReport = PTR_IssueReporter.CreateSurvey(17, "Issue Report: Toy Box UI")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(toyBoxUIReport, true)
    
    toyBoxUIReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with the Toy Box UI?")
    toyBoxUIReport:AddDataCollection(collector.PassValue, UIPanelIDs.ToyBox)

    toyBoxUIReport:RegisterUIPanelClick("CollectionsJournal.TabSet", 3)
    
    ---------------------------------------------- Heirlooms  ---------------------------------------------------
    local heirloomsUIReport = PTR_IssueReporter.CreateSurvey(17, "Issue Report: Heirlooms UI")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(heirloomsUIReport, true)
    
    heirloomsUIReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with the Heirlooms UI?")
    heirloomsUIReport:AddDataCollection(collector.PassValue, UIPanelIDs.Heirlooms)

    heirloomsUIReport:RegisterUIPanelClick("CollectionsJournal.TabSet", 4)
    
    --------------------------------------------- Appearances --------------------------------------------------
    local appearancesUIReport = PTR_IssueReporter.CreateSurvey(17, "Issue Report: Appearances UI")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(appearancesUIReport, true)
    
    appearancesUIReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with the Appearances UI?")
    appearancesUIReport:AddDataCollection(collector.PassValue, UIPanelIDs.Appearances)

    appearancesUIReport:RegisterUIPanelClick("CollectionsJournal.TabSet", 5)
    
    ------------------------------------------- Adventure Guide -------------------------------------------------
    local suggestedContentUIReport = PTR_IssueReporter.CreateSurvey(17, "Issue Report: Adventure Guide UI")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(suggestedContentUIReport, true)
    
    suggestedContentUIReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with the Adventure Guide UI?")
    suggestedContentUIReport:AddDataCollection(collector.PassValue, UIPanelIDs.AdventureGuide)

    suggestedContentUIReport:RegisterUIPanelClick("EncounterJournal.TabSet", 1)
    
    ------------------------------------------- Class Talents -------------------------------------------------
    local getSpecIDFunc = function()
        local ID = 0
        if (PlayerSpellsFrame) and (PlayerSpellsFrame.TalentsFrame) and (PlayerSpellsFrame.TalentsFrame.GetTalentTreeID) then
            ID = PlayerSpellsFrame.TalentsFrame:GetTalentTreeID()
        end
        
        return ID
    end
    
    local getTalentTreeString = function()
        local loadOutString = ""
        
        if (PlayerSpellsFrame) and (PlayerSpellsFrame.TalentsFrame) and (PlayerSpellsFrame.TalentsFrame.GetLoadoutExportString) then
            loadOutString = PlayerSpellsFrame.TalentsFrame:GetLoadoutExportString()
        end
        
        return loadOutString        
    end
    
    local classTalentUIReport = PTR_IssueReporter.CreateSurvey(17, "Issue Report: Class Talent UI")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(classTalentUIReport, true)
    
    classTalentUIReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with the Class Talent UI?")
    classTalentUIReport:AddDataCollection(collector.PassValue, UIPanelIDs.ClassTalent)
    classTalentUIReport:AddDataCollection(collector.RunFunction, getSpecIDFunc)
    classTalentUIReport:AddDataCollection(collector.RunFunction, getTalentTreeString)
    
    classTalentUIReport:RegisterUIPanelClick("PlayerSpellsFrame.TabSet", 2)
    
    ----------------------------------------- Profession Talents -----------------------------------------------
    local getProfSpecID = function()
        local ID = 0
        if (ProfessionsFrame) and (ProfessionsFrame.SpecPage) and (ProfessionsFrame.SpecPage.GetTalentTreeID) then
            ID = ProfessionsFrame.SpecPage:GetTalentTreeID()
        end
        
        return ID
    end
    
    local professionTalentUIReport = PTR_IssueReporter.CreateSurvey(17, "Issue Report: Profession Specialization UI")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(professionTalentUIReport, true)
    
    professionTalentUIReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with the Profession Specialization UI?")
    professionTalentUIReport:AddDataCollection(collector.PassValue, UIPanelIDs.ProfessionTalents)
    professionTalentUIReport:AddDataCollection(collector.RunFunction, getProfSpecID)

    professionTalentUIReport:RegisterUIPanelClick("ProfessionsFrame.TabSet", 2)
    
    --------------------------------- Scenario Reporting ---------------------------------------------
    
    local scenarioReport = PTR_IssueReporter.CreateSurvey(20, "Issue Report: %s")
    scenarioReport:PopulateDynamicTitleToken(1, "Name")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(scenarioReport, true)
    
    scenarioReport:AddDataCollection(collector.FromDataPackage, "ID")
    scenarioReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with this scenario?")

    scenarioReport:RegisterPopEvent(event.Tooltip, tooltips.scenario)
    
    --------------------------------- Radiant Chord Reporting ---------------------------------------------
    
    local radiantChordReport = PTR_IssueReporter.CreateSurvey(21, "Issue Report")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(radiantChordReport, true)
    
    radiantChordReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with this Radiant Chord?")

    radiantChordReport:SetButton("I have found an issue with this Radiant Chord.", PTR_IssueReporter.Assets.RadiantChordIcon)
    radiantChordReport:RegisterButtonEvent(event.RadiantChordStarted)
    radiantChordReport:RegisterButtonEventEnd(event.RadiantChordEnded)
    radiantChordReport:RegisterButtonEventEnd(event.MapIDExit)
    
    --------------------------------------- Character Customization Issue Reporting ----------------------------------------------
    local barberShopReport = PTR_IssueReporter.CreateSurvey(3001, "Issue Report")
    
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

    barberShopReport:AddDataCollection(collector.RunFunction, PTR_IssueReporter.GetMessageKey)
    barberShopReport:AddDataCollection(collector.SurveyID)    
    barberShopReport:AddDataCollection(collector.RunFunction, GetAllCustomizationSelections)
    barberShopReport:AddDataCollection(collector.RunFunction, GetClassID)
    barberShopReport:AddDataCollection(collector.RunFunction, GetGender)
    barberShopReport:AddDataCollection(collector.RunFunction, GetRaceID)
    barberShopReport:AddDataCollection(collector.OpenEndedQuestion, "Please describe the issue:")     
    barberShopReport:RegisterButtonEvent(event.BarberShopOpened)
    barberShopReport:RegisterButtonEventEnd(event.BarberShopClosed)
    barberShopReport:RegisterButtonEventEnd(event.MapIDExit)
end