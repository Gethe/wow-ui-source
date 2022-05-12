----------------------------------------------------------------------------------------------------
PTR_IssueReporter.TooltipTypes = {
    spell = "Spell",
    item = "Item",
    unit = "Creature",
    quest = "Quest",
    achievement = "Achievement",
    currency = "Currency",
    talent = "Talent",
    skill = "Skill",
}
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SetupSpellTooltips()
    local setAuraTooltipFunction = function(self, unit, slotNumber, auraType)
        local name = select(1, UnitAura(unit, slotNumber, auraType))
        local id = select(10, UnitAura(unit, slotNumber, auraType))
        if (id) and (name) then
            PTR_IssueReporter.HookIntoTooltip(self, PTR_IssueReporter.TooltipTypes.spell, id, name)
        end
    end
    
    hooksecurefunc(GameTooltip, "SetUnitAura", setAuraTooltipFunction)    
    hooksecurefunc(GameTooltip, "SetUnitBuff", function(self, unit, slotNumber) setAuraTooltipFunction(self, unit, slotNumber, "HELPFUL") end)
    hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self, unit, slotNumber) setAuraTooltipFunction(self, unit, slotNumber, "HARMFUL") end)
    
    hooksecurefunc("SetItemRef", function(link, ...)
        local id = tonumber(link:match("spell:(%d+)"))
        local name = GetSpellInfo(id)
        if (id) then
            PTR_IssueReporter.HookIntoTooltip(ItemRefTooltip, PTR_IssueReporter.TooltipTypes.spell, id, name)
        end
    end)

    GameTooltip:HookScript("OnTooltipSetSpell", function(self)
        local name, id = self:GetSpell()
        if (id) then 
            PTR_IssueReporter.HookIntoTooltip(self, PTR_IssueReporter.TooltipTypes.spell, id, name)
        end
    end)
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SetupItemTooltips()
    local function attachItemTooltip(self)
        local name, link = self:GetItem()
        if (link) and (name) then
            local id = string.match(link, "item:(%d*)")
            if (id == "" or id == "0") and TradeSkillFrame ~= nil and TradeSkillFrame:IsVisible() and GetMouseFocus().reagentIndex then
                local selectedRecipe = TradeSkillFrame.RecipeList:GetSelectedRecipeID()
                for i = 1, 8 do
                    if GetMouseFocus().reagentIndex == i then
                        id = C_TradeSkillUI.GetRecipeReagentItemLink(selectedRecipe, i):match("item:(%d+):") or nil
                        break
                    end
                end
            end
            if (id) then
                PTR_IssueReporter.HookIntoTooltip(self, PTR_IssueReporter.TooltipTypes.item, id, name)
            end
        end
    end

    GameTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
    ItemRefTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SetupUnitTooltips()
    GameTooltip:HookScript("OnTooltipSetUnit", function(self)
        local name, unit = self:GetUnit()
        if (name) and (unit) then
            local guid = UnitGUID(unit) or ""
            local id = tonumber(guid:match("-(%d+)-%x+$"), 10)
            if (id) and (guid:match("%a+") ~= "Player") then
                PTR_IssueReporter.HookIntoTooltip(GameTooltip, PTR_IssueReporter.TooltipTypes.unit, id, name)
            end
        end
    end)
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SetupQuestTooltips()
    local questLogFrames = {}
    
    local UpdateQuestTooltips = function()
        local i = 1
        local frame = true
        while (frame) do
            frame = _G["QuestLogTitle"..i]
            if (frame) then
                frame.buttonIndex = FauxScrollFrame_GetOffset(QuestLogListScrollFrame) + i
                
                if not (questLogFrames[frame]) then -- We want to make sure we don't HookScript more than once
                    questLogFrames[frame] = true
                    
                    frame:HookScript("OnEnter", function(self)
                        local title = GetQuestLogTitle(self.buttonIndex)
                        local questID = select(8, GetQuestLogTitle(self.buttonIndex))
                        if (questID) and (questID > 0) then
                            GameTooltip:ClearAllPoints()
                            GameTooltip:SetOwner(self, "ANCHOR_NONE")
                            GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 0)
                            PTR_IssueReporter.HookIntoTooltip(GameTooltip, PTR_IssueReporter.TooltipTypes.quest, questID, title, true, true)
                            GameTooltip:Show()
                        end
                    end)
                end
                i = i + 1
            end
        end
    end
    
    hooksecurefunc("QuestLog_Update", UpdateQuestTooltips)
    
    if (QuestLogFrame) then
        QuestLogFrame:HookScript("OnShow", UpdateQuestTooltips)    
    end
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SetupSkillTooltips()
    local skillFrames = {}
    
    local UpdateSkillTooltips = function()
        local i = 1
        local frame = true
        while (frame) do
            frame = _G["SkillRankFrame"..i.."Border"]
            if (frame) then
                frame.buttonIndex = FauxScrollFrame_GetOffset(SkillListScrollFrame) + i
                
                if not (skillFrames[frame]) then -- We want to make sure we don't HookScript more than once
                    skillFrames[frame] = true              
                    frame:HookScript("OnEnter", function(self)
                        local skillName = GetSkillLineInfo(self.buttonIndex)
                        local skillRank = select(4, GetSkillLineInfo(self.buttonIndex))                        
                        if (skillRank) and (skillRank > 0) then
                            GameTooltip:SetOwner(self, "ANCHOR_NONE")
                            GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 0)
                            PTR_IssueReporter.HookIntoTooltip(GameTooltip, PTR_IssueReporter.TooltipTypes.skill, skillRank, skillName, true)
                            GameTooltip:Show()
                        end
                    end)
                    
                    frame:HookScript("OnLeave", function()
                        GameTooltip:Hide()
                    end)
                end
                i = i + 1
            end
        end
    end
    
    hooksecurefunc("FauxScrollFrame_Update", function()
        if (SkillFrame) and (SkillFrame:IsVisible()) then
            UpdateSkillTooltips()
        end
    end)
    
    if (SkillFrame) then
        SkillFrame:HookScript("OnShow", UpdateSkillTooltips)    
    end
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SetupTalentTooltips()
    hooksecurefunc(GameTooltip, "SetTalent", function(self, talentTab, talentNumber)        
        local id = string.format("%s-%s", GetTalentTabInfo(talentTab), talentNumber)
        local name = GameTooltipTextLeft1:GetText()
        if (id) then 
            PTR_IssueReporter.HookIntoTooltip(self, PTR_IssueReporter.TooltipTypes.talent, id, name)
        end
    end)
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.InitializePTRTooltips()
    PTR_IssueReporter.SetupSpellTooltips()
    PTR_IssueReporter.SetupItemTooltips()
    PTR_IssueReporter.SetupUnitTooltips()
    PTR_IssueReporter.SetupQuestTooltips()
    PTR_IssueReporter.SetupTalentTooltips()
    PTR_IssueReporter.SetupSkillTooltips()
end
----------------------------------------------------------------------------------------------------