PTR_IssueReporter.Data.Message_Key = "[*S&^$&L]"
PTR_IssueReporter.LockedReports = {}

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
    
    survey:AddDataCollection(collector.RunFunction, PTR_IssueReporter.GetMessageKey)
    survey:AddDataCollection(collector.SurveyID)
    survey:AddDataCollection(collector.RunFunction, GetPlayerLevel)
    survey:AddDataCollection(collector.RunFunction, GetFaction)
    survey:AddDataCollection(collector.RunFunction, GetRaceID)
    survey:AddDataCollection(collector.RunFunction, GetGender)
    survey:AddDataCollection(collector.RunFunction, GetClassID)
    survey:AddDataCollection(collector.RunFunction, GetSpecID)
    survey:AddDataCollection(collector.RunFunction, GetCurrentiLvl)
	survey:AddDataCollection(collector.RunFunction, C_Covenants.GetActiveCovenantID)
	survey:AddDataCollection(collector.RunFunction, C_Soulbinds.GetActiveSoulbindID)
	survey:AddDataCollection(collector.RunFunction, GetCurrentConduits)
	survey:AddDataCollection(collector.RunFunction, GetCurrentSoulbindTraits)
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
    local confusedReport = PTR_IssueReporter.CreateSurvey(1, "Confused Report")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(confusedReport)
    
    confusedReport:AddDataCollection(collector.OpenEndedQuestion, "What has caused your confusion?")

    confusedReport:RegisterPopEvent(event.UIButtonClicked, "Confused")
    
    --------------------------------------- Bug Reporting ----------------------------------------------
    local bugReport = PTR_IssueReporter.CreateSurvey(2, "Bug Report")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(bugReport)
    
    bugReport:AddDataCollection(collector.OpenEndedQuestion, "Please describe the issue:")     
    bugReport:RegisterPopEvent(event.UIButtonClicked, "Bug")
    
    ----------------------------------- Creature Reporting ---------------------------------------------
    local creatureReport = PTR_IssueReporter.CreateSurvey(3, "Bug Report: %s")
    creatureReport:PopulateDynamicTitleToken(1, "Name")
    creatureReport:AttachModelViewer("ID")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(creatureReport)
    
    creatureReport:AddDataCollection(collector.FromDataPackage, "ID")
    creatureReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with this creature?")

    creatureReport:RegisterPopEvent(event.Tooltip, tooltips.unit)
    
    --------------------------------------- Quest Reporting -------------------------------------------
    local IsQuestDisabledFromQuestSync = function(dataPackage)
        if (dataPackage) and (dataPackage.ID) and (C_QuestLog) and (C_QuestLog.IsQuestDisabledForSession) and (C_QuestLog.IsQuestDisabledForSession(dataPackage.ID)) then
            return 1
        else
            return 0
        end   
    end
    
    local IsQuestSyncEnabled = function()
        if (C_QuestSession) and (C_QuestSession.Exists) and (C_QuestSession.Exists()) then
            return 1
        else
            return 0
        end
    end

	local GetCurrentQuestStatus = function(dataPackage)
		local results = ""
		
		for i=1, C_QuestLog.GetNumQuestLogEntries() do
			local questInfo = C_QuestLog.GetInfo(i)
			if (questInfo) and (questInfo.questID) and (questInfo.questID > 0) then
				local questEntry = ":" .. questInfo.questID
				local objectives = C_QuestLog.GetQuestObjectives(questInfo.questID)
		
				if (objectives) then
					for i, objectiveInfo in pairs(objectives) do
						questEntry = questEntry .. "." .. objectiveInfo.numFulfilled
					end
				end

				results = results .. questEntry
			end
		end

		return results
	end
    
    local questReport = PTR_IssueReporter.CreateSurvey(4, "Bug Report: %s")
    questReport:PopulateDynamicTitleToken(1, "Name")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(questReport)
    
    questReport:AddDataCollection(collector.FromDataPackage, "ID")
    questReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with this quest?")
    questReport:AddDataCollection(collector.RunFunction, IsQuestSyncEnabled)
    questReport:AddDataCollection(collector.RunFunction, IsQuestDisabledFromQuestSync)
	questReport:AddDataCollection(collector.RunFunction, GetCurrentQuestStatus)
    
    local AutoQuestReport = PTR_IssueReporter.CreateSurvey(4, "Bug Report: Quest")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(AutoQuestReport)
    
    AutoQuestReport:AddDataCollection(collector.FromDataPackage, "ID")
    AutoQuestReport:AddDataCollection(collector.OpenEndedQuestion, "Did you experience any issues?")
    AutoQuestReport:AddDataCollection(collector.RunFunction, IsQuestSyncEnabled)
    AutoQuestReport:AddDataCollection(collector.RunFunction, IsQuestDisabledFromQuestSync)
	AutoQuestReport:AddDataCollection(collector.RunFunction, GetCurrentQuestStatus)
    
    questReport:RegisterPopEvent(event.Tooltip, tooltips.quest)
    AutoQuestReport:RegisterFrameAttachedSurvey(QuestFrame, event.QuestRewardFrameShown, {event.QuestFrameClosed, event.QuestTurnedIn}, 0, 0) 
    
    ------------------------------------- Island Reporting ----------------------------------------------
    local islandReport = PTR_IssueReporter.CreateSurvey(5, "Bug Report: %s")
    islandReport:PopulateDynamicTitleToken(1, "Name")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(islandReport)
    
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
    local warfrontsReport = PTR_IssueReporter.CreateSurvey(6, "Bug Report: %s")
    warfrontsReport:PopulateDynamicTitleToken(1, "Name")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(warfrontsReport)
    
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
    local GetIconFromSpellID = function(value)
        return select(3, GetSpellInfo(value))
    end
    
    local spellReport = PTR_IssueReporter.CreateSurvey(7, "Bug Report: %s")
    spellReport:PopulateDynamicTitleToken(1, "Name")
    spellReport:AttachIconViewer("ID", GetIconFromSpellID)
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(spellReport)
    
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

    local encounterReport = PTR_IssueReporter.CreateSurvey(8, "Bug Report: %s")
    encounterReport:PopulateDynamicTitleToken(1, "Name")
    encounterReport:AttachModelViewer("DisplayInfoID", true)
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(encounterReport)
    
    encounterReport:AddDataCollection(collector.FromDataPackage, "ID")
    encounterReport:AddDataCollection(collector.FromDataPackage, "DifficultyID")
    encounterReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with this boss?")
	encounterReport:AddDataCollection(collector.RunFunction, GetMythicPlusInfo)
    
    local automaticEncounterReport = PTR_IssueReporter.CreateSurvey(8, "Bug Report: %s")
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
        return select(10, GetItemInfo(value))
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
                for i=15, 15 + numberOfBonusIDs do
                    table.insert(bonusIDs,elements[i])
                end
                for i,v in ipairs(bonusIDs) do
                    results = results .. ":" .. v
                end
            end
            return results
        end
        
        return ""
    end

    local itemReport = PTR_IssueReporter.CreateSurvey(9, "Bug Report: %s")
    itemReport:PopulateDynamicTitleToken(1, "Name")
    itemReport:AttachIconViewer("ID", GetIconFromItemID)
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(itemReport)
    
    itemReport:AddDataCollection(collector.FromDataPackage, "ID")
    itemReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with this item?")
    itemReport:AddDataCollection(collector.RunFunction, GetBonusListFromID)
    
    itemReport:RegisterPopEvent(event.Tooltip, tooltips.item)
    
    --------------------------------- Achievement Reporting ---------------------------------------------
    local GetIconFromAchievementID = function(value)
        return select(10, GetAchievementInfo(value))
    end
    
    local achievementReport = PTR_IssueReporter.CreateSurvey(10, "Bug Report: %s")
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
    
    local currencyReport = PTR_IssueReporter.CreateSurvey(11, "Bug Report: %s")
    currencyReport:PopulateDynamicTitleToken(1, "Name")
    currencyReport:AttachIconViewer("ID", GetIconFromCurrencyID)
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(currencyReport)
    
    currencyReport:AddDataCollection(collector.FromDataPackage, "ID")
    currencyReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with this currency?")

    currencyReport:RegisterPopEvent(event.Tooltip, tooltips.currency)
    
    -------------------------------- Pet Battle Creature Reporting ---------------------------------------
    local petBattleCreatureReport = PTR_IssueReporter.CreateSurvey(12, "Bug Report: Pet Battles")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(petBattleCreatureReport)
    
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
    
    local azeriteEssenceReport = PTR_IssueReporter.CreateSurvey(13, "Bug Report: %s")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(azeriteEssenceReport)
    azeriteEssenceReport:PopulateDynamicTitleToken(1, "Name")
    azeriteEssenceReport:AttachIconViewer("ID", GetIconFromAzeriteEssenceID)
    
    azeriteEssenceReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with this Azerite Essence?")
    azeriteEssenceReport:AddDataCollection(collector.FromDataPackage, "ID") 

    azeriteEssenceReport:RegisterPopEvent(event.Tooltip, tooltips.azerite)
    --------------------------------------- Garrison Talent Bug Reporting ----------------------------------------------
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
    
    local garrTalentReport = PTR_IssueReporter.CreateSurvey(14, "Bug Report: %s")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(garrTalentReport)
    garrTalentReport:PopulateDynamicTitleToken(1, "Name")
    garrTalentReport:AttachIconViewer("ID", GetIconFromGarrTalentID)
    
    garrTalentReport:AddDataCollection(collector.OpenEndedQuestion, "What was the issue with this Talent?")
    garrTalentReport:AddDataCollection(collector.FromDataPackage, "ID") 
    garrTalentReport:AddDataCollection(collector.RunFunction, GetCurrentTalentTreeStateFromTalentID) 
    
    garrTalentReport:RegisterPopEvent(event.Tooltip, tooltips.talent)
    
    --------------------------------------- Character Customization Bug Reporting ----------------------------------------------
    local barberShopReport = PTR_IssueReporter.CreateSurvey(3001, "Bug Report")
    
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
--------------------------------------------------------------------------------------------------------
function PTR_IssueReporter.CreateNPEReports() -- These surveys are for the New Player Experience being test in 9.0 Alpha
    local URSurveyIndexOffset = 2000
    local collector = PTR_IssueReporter.DataCollectorTypes
    local event = PTR_IssueReporter.ReportEventTypes
    local tooltips = PTR_IssueReporter.TooltipTypes
    
    local endOfPlayReport = PTR_IssueReporter.CreateSurvey(URSurveyIndexOffset + 1, "End of Session Report")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(endOfPlayReport)
    
    endOfPlayReport:AddDataCollection(collector.OpenEndedQuestion, "Before you go, can you please tell us a little bit about why you are ending your play session?")
    endOfPlayReport:RegisterFrameAttachedSurvey(GameMenuFrame, event.GameMenuFrameOpened, {event.GameMenuButtonQuit, event.GameMenuButtonLogout, event.GameMenuFrameClosed}, 4, 8, "BOTTOMLEFT", "BOTTOMRIGHT")
    
    local lackOfProgressSurvey = PTR_IssueReporter.CreateSurvey(URSurveyIndexOffset + 2, "Objective Clarity Survey")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(lackOfProgressSurvey)
    
    lackOfProgressSurvey:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "How clear is your current quest objective(s)?", {"Not At All Clear", "Slightly Clear", "Moderately Clear", "Very Clear", "Extremely Clear"})
    lackOfProgressSurvey:AddDataCollection(collector.OpenEndedQuestion, "Can you please briefly describe your current quest objective(s)?")
    lackOfProgressSurvey:RegisterPopEvent(event.TimeSincePlayerProgress, 300)
    
    local endOfHubReports = {
        Murloc_Hideaway = {        
            ReportID = URSurveyIndexOffset + 3,
            QuestChainTitle = "Murloc Hideaway",
            QuestChainSentence = "the Murloc Hideaway",
            EndQuestID = 54952,
        },
        Quilboar_Briar_Patch = {        
            ReportID = URSurveyIndexOffset + 4,
            QuestChainTitle = "Quilboar Briar Patch",
            QuestChainSentence = "the Quilboar Briar Patch",
            EndQuestID = 55186,
        },
        Henrys_Rescue = {        
            ReportID = URSurveyIndexOffset + 5,
            QuestChainTitle = "Henry Garrick's Rescue",
            QuestChainSentence = "Henry Garrick's Rescue",
            EndQuestID = 55879,
        },
        Hruns_Barrow = {        
            ReportID = URSurveyIndexOffset + 6,
            QuestChainTitle = "Hrun’s Barrow",
            QuestChainSentence = "Hrun’s Barrow",
            EndQuestID = 55639,
        },
        Harpy_Roost = {        
            ReportID = URSurveyIndexOffset + 7,
            QuestChainTitle = "Harpy's Roost",
            QuestChainSentence = "the Harpy's Roost",
            EndQuestID = 55882,
        },
        Darkmaul_Citadel = {        
            ReportID = URSurveyIndexOffset + 8,
            QuestChainTitle = "Darkmaul Citadel",
            QuestChainSentence = "Darkmaul Citadel",
            EndQuestID = 55990,
        },
        Darkmaul_Citadel_Dungeon = {        
            ReportID = URSurveyIndexOffset + 9,
            QuestChainTitle = "Darkmaul Citadel (Dungeon)",
            QuestChainSentence = "Darkmaul Citadel (Dungeon)",
            EndQuestID = 55992,
        },
    }
    
    local startOfSurvey = PTR_IssueReporter.CreateSurvey(URSurveyIndexOffset + 27, "Welcome to Shadowlands!")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(startOfSurvey)
    startOfSurvey:AddDataCollection(collector.TextBlock, "Welcome to the Shadowlands Alpha!\n This survey will prompt you with questions while you play through the New Player Experience.")
    startOfSurvey:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "Before we get started, are you a new or novice World of Warcraft player?", {"Yes", "No"}, true)
    startOfSurvey:RegisterPopEvent(event.QuestTurnedIn, 54952)
    
    for key, endOfHubData in pairs (endOfHubReports) do
        local endOfHubReport = PTR_IssueReporter.CreateSurvey(endOfHubData.ReportID, endOfHubData.QuestChainTitle)
        PTR_IssueReporter.AttachDefaultCollectionToSurvey(endOfHubReport)
        endOfHubReport:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "How fun were the quests in\n"..endOfHubData.QuestChainSentence.."?", {"Not At\nAll Fun" , "Slightly\nFun" , "Moderately\nFun" , "Very\nFun" , "Extremely\nFun"})
        endOfHubReport:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "How clear were the quest objectives for the quests\nin "..endOfHubData.QuestChainSentence.."?", {"Not At\nAll Clear" , "Slightly\nClear" , "Moderately\nClear" , "Very\nClear" , "Extremely\nClear"})
        endOfHubReport:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "How difficult was it to find your way around in "..endOfHubData.QuestChainSentence.."?", {"Not At\nAll Difficult" , "Slightly\nDifficult" , "Moderately\nDifficult" , "Very\nDifficult" , "Extremely\nDifficult"})
        endOfHubReport:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "How challenging were the quests\nin "..endOfHubData.QuestChainSentence.."?", {"Not At\nAll Challenging" , "Slightly\nChallenging" , "Moderately\nChallenging" , "Very\nChallenging" , "Extremely\nChallenging"})
        endOfHubReport:AddDataCollection(collector.OpenEndedQuestion, "While you were questing in "..endOfHubData.QuestChainSentence..",\nwas there any part of the game that was\nunclear or confusing?")
        endOfHubReport:AddDataCollection(collector.OpenEndedQuestion, "Do you have any additional comments on your experiences in "..endOfHubData.QuestChainSentence.."?")
        if (endOfHubData.EndQuestID == 54952) then -- This quest ID is going to be asked after asking an intro quest
            startOfSurvey:PopSurveyOnSubmit(endOfHubReport)
        else
            endOfHubReport:RegisterPopEvent(event.QuestTurnedIn, endOfHubData.EndQuestID)
        end
    end
    
    local GetIconFromSpellID = function(value)
        return select(3, GetSpellInfo(value))
    end
    
    local classQuestReportData = {
        DRUID = {
            ReportID = URSurveyIndexOffset + 10,
            QuestTitle = "A Druid's Form",
            SpellID = 783,
            SpellName = "Travel Form",
            CompletionQuestID = 59350,
            ClassName = "Druid",
        },
        HUNTER = {
            ReportID = URSurveyIndexOffset + 11,
            QuestTitle = "The Art of Taming",
            SpellID = 83242,
            SpellName = "Tame Beast",
            CompletionQuestID = 60168,
            ClassName = "Hunter",            
        },
        MAGE = {
            ReportID = URSurveyIndexOffset + 12,
            QuestTitle = "The Best Way to Use Sheep",
            SpellID = 118,
            SpellName = "Polymorph",
            CompletionQuestID = 59354,   
            ClassName = "Mage",
        },
        MONK = {
            ReportID = URSurveyIndexOffset + 13,
            QuestTitle = "One Last Spar",
            SpellID = 322109,
            SpellName = "Touch of Death",
            CompletionQuestID = 59349,
            ClassName = "Monk",
        },
        PALADIN = {
            ReportID = URSurveyIndexOffset + 14,
            QuestTitle = "The Divine's Shield",
            SpellID = 642,
            SpellName = "Divine Shield",
            CompletionQuestID = 58946,
            ClassName = "Paladin",
        },
        PRIEST = {
            ReportID = URSurveyIndexOffset + 15,
            QuestTitle = "Resurrecting the Recruits",
            SpellID = 2006,
            SpellName = "Resurrection",
            CompletionQuestID = 58960,
            ClassName = "Priest",
        },
        ROGUE = {
            ReportID = URSurveyIndexOffset + 16,
            QuestTitle = "The Deadliest of Poisons",
            SpellID = 315584,
            SpellName = "Instant Poison",
            CompletionQuestID = 58933,
            ClassName = "Rogue",
        },
        SHAMAN = {
            ReportID = URSurveyIndexOffset + 17,
            QuestTitle = "A Shaman's Duty",
            SpellID = 2645,
            SpellName = "Ghost Wolf",
            CompletionQuestID = 59002,
            ClassName = "Shaman",
        },
        WARLOCK = {
            ReportID = URSurveyIndexOffset + 18,
            QuestTitle = "A Warlock's Bargain",
            SpellID = 697,
            SpellName = "Summon Voidwalker",
            CompletionQuestID = 58962,
            ClassName = "Warlock",
        },
        WARRIOR = {
            ReportID = URSurveyIndexOffset + 19,
            QuestTitle = "Hjalmar's Final Execution",
            SpellID = 163201,
            SpellName = "Execute",
            CompletionQuestID = 58915,
            ClassName = "Warrior",
        },        
    }
    
    for class, reportData in pairs (classQuestReportData) do
        local classQuestReport = PTR_IssueReporter.CreateSurvey(reportData.ReportID, reportData.QuestTitle)
        classQuestReport:AttachIconViewer("ID", function() return GetIconFromSpellID(reportData.SpellID) end)
        
        PTR_IssueReporter.AttachDefaultCollectionToSurvey(classQuestReport)
        classQuestReport:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "How useful does "..reportData.SpellName.." seem?", {"Not At\nAll Useful" , "Slightly\nUseful" , "Moderately\nUseful" , "Very\nUseful" , "Extremely\nUseful"})
        classQuestReport:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "How much did the last quest affect your understanding of what a "..reportData.ClassName.." is like in World of Warcraft? ", {"Understand Far Less" , "Understand A Bit Less" , "Did Not Affect Understanding" , "Understand A Bit More" , "Understand Far More"})
        classQuestReport:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "How satisfied are you with your choice to play a "..reportData.ClassName.." so far?", {"Not At All\nSatisfied" , "Slightly\nSatisfied" , "Moderately\nSatisfied" , "Very\nSatisfied" , "Extremely\nSatisfied"})
        classQuestReport:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "If given the option, how likely would you be to change your class at this point? ", {"Not At All\nLikely" , "Slightly\nLikely" , "Moderately\nLikely" , "Very\nLikely" , "Extremely\nLikely"})
        classQuestReport:RegisterPopEvent(event.QuestTurnedIn, reportData.CompletionQuestID)
    end
    
    local overall_experience_survey = PTR_IssueReporter.CreateSurvey(URSurveyIndexOffset + 20, "Overall Experience")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(overall_experience_survey)
    overall_experience_survey:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "Overall, how fun was your experience?", {"Not At\nAll Fun" , "Slightly\nFun" , "Moderately\nFun" , "Very\nFun" , "Extremely\nFun"})
    overall_experience_survey:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "Overall, how clear were the objectives in your experience?", {"Not At\nAll Clear" , "Slightly\nClear" , "Moderately\nClear" , "Very\nClear" , "Extremely\nClear"})
    overall_experience_survey:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "Overall, how difficult was it to find your way around during your experience?", {"Not At\nAll Difficult" , "Slightly\nDifficult" , "Moderately\nDifficult" , "Very\nDifficult" , "Extremely\nDifficult"})
    overall_experience_survey:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "Overall, how challenging was your experience?", {"Not At\nAll Challenging" , "Slightly\nChallenging" , "Moderately\nChallenging" , "Very\nChallenging" , "Extremely\nChallenging"})
    overall_experience_survey:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "Overall, how appropriate was the level of challenge of your experience?", {"Not At\nAll Challenging" , "Slightly\nChallenging" , "Moderately\nChallenging" , "Very\nChallenging" , "Extremely\nChallenging"})
    
    local localizedClass, englishClass = UnitClass("player")
    
    local GetClassLevelingSpell = function()        
        if (classQuestReportData) and (classQuestReportData[englishClass]) then
            return classQuestReportData[englishClass].SpellName
        else
            return ""
        end
    end
    
    local GetClassLevelingSpellID = function()        
        if (classQuestReportData) and (classQuestReportData[englishClass]) then
            return classQuestReportData[englishClass].SpellID
        else
            return 0
        end
    end
    
    local GetClassName = function()
        return localizedClass
    end
    
    local classQuestReport = PTR_IssueReporter.CreateSurvey(URSurveyIndexOffset + 21, "Overall Experience - Class")
    classQuestReport:AttachIconViewer("ID", function() return GetIconFromSpellID(GetClassLevelingSpellID()) end)    
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(classQuestReport)
    classQuestReport:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "How useful was "..GetClassLevelingSpell()..", the ability that you obtained from your class quest?", {"Not At\nAll Useful" , "Slightly\nUseful" , "Moderately\nUseful" , "Very\nUseful" , "Extremely\nUseful"})
    classQuestReport:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "How satisfied are you with your choice to play a "..GetClassName().."?", {"Not At All\nSatisfied" , "Slightly\nSatisfied" , "Moderately\nSatisfied" , "Very\nSatisfied" , "Extremely\nSatisfied"})
    classQuestReport:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "If given the option, how likely would you be to change your class at this point? ", {"Not At All\nLikely" , "Slightly\nLikely" , "Moderately\nLikely" , "Very\nLikely" , "Extremely\nLikely"})
    
    local personalExperienceReport = PTR_IssueReporter.CreateSurvey(URSurveyIndexOffset + 22, "Overall Experience")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(personalExperienceReport)
    personalExperienceReport:AddDataCollection(collector.OpenEndedQuestion, "What was your favorite or most memorable\npart of this experience overall?")
    personalExperienceReport:AddDataCollection(collector.OpenEndedQuestion, "What was the most difficult or frustrating\npart of this experience overall?")
    
    local whatWasLearnedReport = PTR_IssueReporter.CreateSurvey(URSurveyIndexOffset + 23, "Overall Experience - Tutorials")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(whatWasLearnedReport)
    whatWasLearnedReport:AddDataCollection(0, collector.TextBlock, "|cFFFFFFFFThe goal of this experience is to teach new\nplayers about the basics of World of Warcraft.\n\nThe next set of questions will ask about a few different aspects that the team is trying to teach players. Please rate each based on how well you felt like you learned them by the end of the experience.\n\nPlease be honest - if you don't feel like you learned how to do these things it means that our experience is not working, not that you missed anything!")
    whatWasLearnedReport:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "Moving Your Camera", {"Did Not\nLearn At All" , "Learned\nSlightly Well" , "Learned\nModerately Well" , "Learned\nVery Well" , "Learned\nExtremely\nWell"})
    whatWasLearnedReport:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "Moving Your Character", {"Did Not\nLearn At All" , "Learned\nSlightly Well" , "Learned\nModerately Well" , "Learned\nVery Well" , "Learned\nExtremely\nWell"})
    whatWasLearnedReport:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "Obtaining & Completing Quests", {"Did Not\nLearn At All" , "Learned\nSlightly Well" , "Learned\nModerately Well" , "Learned\nVery Well" , "Learned\nExtremely\nWell"})
    whatWasLearnedReport:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "Fighting One Enemy", {"Did Not\nLearn At All" , "Learned\nSlightly Well" , "Learned\nModerately Well" , "Learned\nVery Well" , "Learned\nExtremely\nWell"})
    whatWasLearnedReport:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "Fighting Multiple Enemies", {"Did Not\nLearn At All" , "Learned\nSlightly Well" , "Learned\nModerately Well" , "Learned\nVery Well" , "Learned\nExtremely\nWell"})
    
    local whatWasLearnedReport2 = PTR_IssueReporter.CreateSurvey(URSurveyIndexOffset + 24, "Overall Experience - Tutorials")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(whatWasLearnedReport2)
    whatWasLearnedReport2:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "Obtaining New Spells & Abilities", {"Did Not\nLearn At All" , "Learned\nSlightly Well" , "Learned\nModerately Well" , "Learned\nVery Well" , "Learned\nExtremely\nWell"})
    whatWasLearnedReport2:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "Using Spells & Abilities Effectively in Combat", {"Did Not\nLearn At All" , "Learned\nSlightly Well" , "Learned\nModerately Well" , "Learned\nVery Well" , "Learned\nExtremely\nWell"})
    whatWasLearnedReport2:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "Obtaining & Equipping New Gear", {"Did Not\nLearn At All" , "Learned\nSlightly Well" , "Learned\nModerately Well" , "Learned\nVery Well" , "Learned\nExtremely\nWell"})
    whatWasLearnedReport2:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "Quest Objectives", {"Did Not\nLearn At All" , "Learned\nSlightly Well" , "Learned\nModerately Well" , "Learned\nVery Well" , "Learned\nExtremely\nWell"})
    whatWasLearnedReport2:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "Using Items To Complete Quests", {"Did Not\nLearn At All" , "Learned\nSlightly Well" , "Learned\nModerately Well" , "Learned\nVery Well" , "Learned\nExtremely\nWell"})
    
    local whatWasLearnedReport3 = PTR_IssueReporter.CreateSurvey(URSurveyIndexOffset + 25, "Overall Experience - Tutorials")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(whatWasLearnedReport3)
    whatWasLearnedReport3:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "Buying & Selling Items", {"Did Not\nLearn At All" , "Learned\nSlightly Well" , "Learned\nModerately Well" , "Learned\nVery Well" , "Learned\nExtremely\nWell"})
    whatWasLearnedReport3:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "Mini-Map User Interface", {"Did Not\nLearn At All" , "Learned\nSlightly Well" , "Learned\nModerately Well" , "Learned\nVery Well" , "Learned\nExtremely\nWell"})
    whatWasLearnedReport3:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "Large Map User Interface", {"Did Not\nLearn At All" , "Learned\nSlightly Well" , "Learned\nModerately Well" , "Learned\nVery Well" , "Learned\nExtremely\nWell"})
    whatWasLearnedReport3:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "Interactable Objects", {"Did Not\nLearn At All" , "Learned\nSlightly Well" , "Learned\nModerately Well" , "Learned\nVery Well" , "Learned\nExtremely\nWell"})
    whatWasLearnedReport3:AddDataCollection(collector.SelectOne_MultipleChoiceQuestion, "Finding A Group For Activities", {"Did Not\nLearn At All" , "Learned\nSlightly Well" , "Learned\nModerately Well" , "Learned\nVery Well" , "Learned\nExtremely\nWell"})
    
    local endOfSurvey = PTR_IssueReporter.CreateSurvey(URSurveyIndexOffset + 26, "Thank you!")
    PTR_IssueReporter.AttachDefaultCollectionToSurvey(endOfSurvey)
    endOfSurvey:AddDataCollection(collector.TextBlock, "|cFFFFFFFFThank you for completing the Shadowlands\nNew Player Experience! Your feedback\nis important to us.\n\nWe appreciate your dedication to helping Blizzard create the most epic entertainment experiences ever!")
    endOfSurvey:AddDataCollection(collector.OpenEndedQuestion, "Do you have any additional comments on your experiences?")
    
    overall_experience_survey:RegisterPopEvent(event.QuestTurnedIn, 55991)
    PTR_IssueReporter.RegisterSurveyPopCommand("NPE", overall_experience_survey)
    overall_experience_survey:PopSurveyOnSubmit(classQuestReport)
    classQuestReport:PopSurveyOnSubmit(personalExperienceReport)
    personalExperienceReport:PopSurveyOnSubmit(whatWasLearnedReport)
    whatWasLearnedReport:PopSurveyOnSubmit(whatWasLearnedReport2)
    whatWasLearnedReport2:PopSurveyOnSubmit(whatWasLearnedReport3)
    whatWasLearnedReport3:PopSurveyOnSubmit(endOfSurvey)
end

PTR_IssueReporter.RegisterSetupCommand("NPE", PTR_IssueReporter.CreateNPEReports)