function PTR_IssueReporter.AttachDefaultCollectionToSurvey(survey)
    local collector = PTR_IssueReporter.DataCollectorTypes
    
    survey:AddDataCollection(collector.RunFunction, PTR_IssueReporter.GetMessageKey)
    survey:AddDataCollection(collector.SurveyID)
end

--------------------------------------------------------------------------------------------------------
function PTR_IssueReporter.CreateReports()
    
    local collector = PTR_IssueReporter.DataCollectorTypes
    local event = PTR_IssueReporter.ReportEventTypes
    local tooltips = PTR_IssueReporter.TooltipTypes

    --------------------------------------- Character Customization ----------------------------------------------
    local characterCustomizationBug = PTR_IssueReporter.CreateSurvey(3001, "Character Customization")
    
    local GetSelectedRace = function()
        return C_CharacterCreation.GetSelectedRace();
    end

    local GetAllCustomizationSelections = function()        
        local customizationCategoryData = C_CharacterCreation.GetAvailableCustomizations()
        --if the function has changed and doesn't exist then we'll pass through an error index
        if customizationCategoryData == nil then
            return "-1"
        end

        local customizationDataString = ""
        local count = 0

        for key, component in pairs (customizationCategoryData) do
            for optionKey, optionValue in pairs(component.options) do
                if(optionValue.choices[optionValue.currentChoiceIndex].id) then
                    customizationDataString = customizationDataString .. "," .. optionValue.choices[optionValue.currentChoiceIndex].id
                    count = count + 1
                 end
            end
        end
        
        customizationDataString = count .. customizationDataString

        return customizationDataString
    end

    local GetSelectedClass = function()
        local selectedClassData = C_CharacterCreation.GetSelectedClass()
        return selectedClassData.classID
    end

    local GetSelectedSex = function()
        return C_CharacterCreation.GetSelectedSex()
    end

    characterCustomizationBug:AddDataCollection(collector.RunFunction, PTR_IssueReporter.GetMessageKey)
    characterCustomizationBug:AddDataCollection(collector.SurveyID)    
    characterCustomizationBug:AddDataCollection(collector.RunFunction, GetAllCustomizationSelections)
    characterCustomizationBug:AddDataCollection(collector.RunFunction, GetSelectedClass)
    characterCustomizationBug:AddDataCollection(collector.RunFunction, GetSelectedSex)
    characterCustomizationBug:AddDataCollection(collector.RunFunction, GetSelectedRace)
    characterCustomizationBug:AddDataCollection(collector.OpenEndedQuestion, "Please describe the issue:")     
    
    characterCustomizationBug:SetButton("I have found an issue with a Character Customization.", PTR_IssueReporter.Assets.EditModeIcon)
    characterCustomizationBug:RegisterButtonEvent(event.CharacterCustomizationShow)
    characterCustomizationBug:RegisterButtonEventEnd(event.CharacterCustomizationHide)
    
    --------------------------------------- Bug Reporting ----------------------------------------------
    
    local WarbandsCharacterSelectID = 10
    local WarbandMaxCampSize = 4
    
    local GetWarbandsDebugInfo = function()
        local characterInfos = {}
        local returnString = ""
        
        CharacterSelectListUtil.ForEachCharacterDo(function(frame)
            if #characterInfos < WarbandMaxCampSize then
                table.insert(characterInfos, frame.characterInfo)
            end
        end)
        
        for i = 1, WarbandMaxCampSize, 1 do
            if #returnString > 0 then
                returnString = returnString .. ":"
            end
            
            local isGhost = 0            
           
            
            if (characterInfos[i]) then
                if (characterInfos[i].isGhost) then
                    isGhost = 1
                end
                
                returnString = returnString .. characterInfos[i].raceID or 0
                returnString = returnString .. "." .. characterInfos[i].genderID or 0
                returnString = returnString .. "." .. characterInfos[i].classID or 0
                returnString = returnString .. "." .. characterInfos[i].specID or 0
                returnString = returnString .. "." .. characterInfos[i].faction or "Unknown"
                returnString = returnString .. "." .. isGhost 
            else
                returnString = returnString .. "0.0.0.0.Unknown.0"
            end
        end
        
        return returnString
    end
    
    local warbandCharSelectBug = PTR_IssueReporter.CreateSurvey(3002, "Warband Character Selection") 

    warbandCharSelectBug:AddDataCollection(collector.RunFunction, PTR_IssueReporter.GetMessageKey)
    warbandCharSelectBug:AddDataCollection(collector.SurveyID)
    warbandCharSelectBug:AddDataCollection(collector.RunFunction, GetWarbandsDebugInfo)
    warbandCharSelectBug:AddDataCollection(collector.PassValue, WarbandsCharacterSelectID)
    warbandCharSelectBug:AddDataCollection(collector.OpenEndedQuestion, "Please describe the issue:")     
    
    warbandCharSelectBug:SetButton("I have found an issue with my Warband.", PTR_IssueReporter.Assets.BugReportIcon)
    warbandCharSelectBug:RegisterButtonEvent(event.WarbandsShow)
    warbandCharSelectBug:RegisterButtonEventEnd(event.WarbandsHide)
end