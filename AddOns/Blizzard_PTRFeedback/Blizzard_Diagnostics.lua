PTR_FeedbackDiagnostic = {
    UnitToken = "player",
    Data = {},
    BinaryData = {},
}

function PTR_FeedbackDiagnostic:GetPower()
    --need a special handler for determining resources
    local powerString = ""
    if (not Enum.PowerType) then
        return powerString
    end
    local firstPower = true
    for k,v in pairs(Enum.PowerType) do
        if (v >= 0) and (v ~= Enum.PowerType.NumPowerTypes) then
            local powerCurrent, powerMax = UnitPower(PTR_FeedbackDiagnostic.UnitToken, v), UnitPowerMax(PTR_FeedbackDiagnostic.UnitToken, v)
            if (powerMax > 0) then
                --we use k power and have a value of the current percentage
                local percentage = powerCurrent/powerMax
                if (firstPower) then
                    powerString = string.format("%s=%.2f", v, percentage)
                    firstPower = false
                else
                    powerString = string.format("%s:%s=%.2f", powerString, v, percentage)
                end
            end
        end
    end

    return powerString
end

function PTR_FeedbackDiagnostic:GetQuests()
    local numQuests = GetNumQuestLogEntries()
    local questPackageString = ""
    local firstQuest = true
    for i=1,numQuests do
        local questInfo = {GetQuestLogTitle(i)}
        if (not questInfo[4]) then
            if (firstQuest) then
                questPackageString = questInfo[8]
                firstQuest = false
            else
                questPackageString = string.format("%s:%s", questPackageString, questInfo[8])
            end
        end
    end

    return questPackageString
end

function PTR_FeedbackDiagnostic:Get()
    local _, _, classId = UnitClass(PTR_FeedbackDiagnostic.UnitToken)
    local specID = GetSpecialization() or 1
    local specInfoID = GetSpecializationInfo(specID)
    local total, equipped, pvp = GetAverageItemLevel()
    self.Data[1] = string.format("%.2f", UnitHealth(PTR_FeedbackDiagnostic.UnitToken) / UnitHealthMax(PTR_FeedbackDiagnostic.UnitToken))
    self.Data[2] = self:GetPower()
    self.Data[3] = UnitEffectiveLevel(PTR_FeedbackDiagnostic.UnitToken)
    self.Data[4] = UnitRace(PTR_FeedbackDiagnostic.UnitToken)
    self.Data[5] = classId
    self.Data[6] = specInfoID
    self.Data[7] = equipped
    self.Data[8] = self:GetQuests()

    local dataWord = string.format("%s,%s,%s,%s,%s,%s,%s,%s",
        self.Data[1],
        self.Data[2],
        self.Data[3],
        self.Data[4],
        self.Data[5],
        self.Data[6],
        self.Data[7],
        self.Data[8])

    self.BinaryData[1] = UnitAffectingCombat(PTR_FeedbackDiagnostic.UnitToken)
    self.BinaryData[2] = UnitIsDeadOrGhost(PTR_FeedbackDiagnostic.UnitToken)
    self.BinaryData[3] = UnitIsPVP(PTR_FeedbackDiagnostic.UnitToken)
    self.BinaryData[4] = IsMounted()
    self.BinaryData[5] = UnitControllingVehicle(PTR_FeedbackDiagnostic.UnitToken)

    --pack the binary data
    local wordSize = 32
    local words = {}
    for k,v in ipairs(self.BinaryData) do
        local currentWord = math.ceil(k / wordSize)
        words[currentWord] = (words[currentWord] or 0)
        if (v) then
            local powerIndex = (k-1)%wordSize
            local decimalValue = math.pow(2, powerIndex)
            words[currentWord] = words[currentWord] + decimalValue
        end
    end

    --build a maskword
    local maskWord = ""
    local firstMask = true
    for k,v in ipairs(words) do
        if (firstMask) then
            maskWord = v
            firstMask = false
        else
            maskWord = string.format("%s:%s", maskWord, v)
        end
    end

    --construct our message
    local finalMessage = string.format("%s,%s", dataWord, maskWord)
    
    return finalMessage
end