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

    --------------------------------------- Bug Reporting ----------------------------------------------
    local bugReport = PTR_IssueReporter.CreateSurvey(3001, "Bug Report")
    
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

    bugReport:AddDataCollection(collector.RunFunction, PTR_IssueReporter.GetMessageKey)
    bugReport:AddDataCollection(collector.SurveyID)    
    bugReport:AddDataCollection(collector.RunFunction, GetAllCustomizationSelections)
    bugReport:AddDataCollection(collector.RunFunction, GetSelectedClass)
    bugReport:AddDataCollection(collector.RunFunction, GetSelectedSex)
    bugReport:AddDataCollection(collector.RunFunction, GetSelectedRace)
    bugReport:AddDataCollection(collector.OpenEndedQuestion, "Please describe the issue:")     
    bugReport:RegisterPopEvent(event.UIButtonClicked, "Bug")
end