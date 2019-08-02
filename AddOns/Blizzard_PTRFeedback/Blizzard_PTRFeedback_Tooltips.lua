----------------------------------------------------------------------------------------------------
PTR_IssueReporter.TooltipTypes = {
    spell = "Spell",
    item = "Item",
    unit = "Creature",
    quest = "Quest",
    achievement = "Achievement",
    currency = "Currency",
    petBattleAbility = "Pet Battle Ability",
    petBattleCreature = "Pet Battle Creature",
    azerite = "Azerite Essence",
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
        if (C_PetBattles.IsInBattle()) then
            return
        end
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
    hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(self)
        local title = GetQuestLogTitle(self.questLogIndex)
        local questID = select(8, GetQuestLogTitle(self.questLogIndex))
        if (questID) and (title) then
            PTR_IssueReporter.HookIntoTooltip(GameTooltip, PTR_IssueReporter.TooltipTypes.quest, questID, title)
        end
     end)
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SetupAchievementTooltips()
    local frame = CreateFrame("frame")
    frame:RegisterEvent("ADDON_LOADED")
    frame:SetScript("OnEvent", function(_, _, eventSender)
        if eventSender == "Blizzard_AchievementUI" then
            for i,button in ipairs(AchievementFrameAchievementsContainer.buttons) do
                button:HookScript("OnEnter", function()
                    GameTooltip:SetOwner(button, "ANCHOR_NONE")
                    GameTooltip:SetPoint("TOPLEFT", button, "TOPRIGHT", 0, 0)
                    local id = button.id
                    if (id) then
                        local achievementTitle = select(2, GetAchievementInfo(id))
                        PTR_IssueReporter.HookIntoTooltip(GameTooltip, PTR_IssueReporter.TooltipTypes.achievement,id, achievementTitle, true)
                        GameTooltip:Show()
                    end
                end)
                button:HookScript("OnLeave", function()
                    GameTooltip:Hide()
                end)
            end
            frame:UnregisterEvent("ADDON_LOADED")            
        end
    end)
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SetupCurrencyTooltips()
    hooksecurefunc(GameTooltip, "SetCurrencyToken", function(self, index)
        local id = tonumber(string.match(GetCurrencyListLink(index),"currency:(%d+)"))
        local name = GetCurrencyInfo(id)
        if (id) then
            PTR_IssueReporter.HookIntoTooltip(self, PTR_IssueReporter.TooltipTypes.currency, id, name)
        end
    end)
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SetupAzeriteTooltips()
    if (SetAzeriteEssence) then
        hooksecurefunc(GameTooltip, "SetAzeriteEssence", function(self, azeriteID, rank)
            if (azeriteID) and (C_AzeriteEssence) and (C_AzeriteEssence.GetEssenceInfo) then
                local azeriteData = C_AzeriteEssence.GetEssenceInfo(azeriteID)
                PTR_IssueReporter.HookIntoTooltip(self, PTR_IssueReporter.TooltipTypes.azerite, azeriteID, azeriteData.name)
            end
        end)
    end
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.InitializePTRTooltips()
    PTR_IssueReporter.SetupSpellTooltips()
    PTR_IssueReporter.SetupItemTooltips()
    PTR_IssueReporter.SetupUnitTooltips()
    PTR_IssueReporter.SetupQuestTooltips()
    PTR_IssueReporter.SetupAchievementTooltips()
    PTR_IssueReporter.SetupCurrencyTooltips()
    PTR_IssueReporter.SetupAzeriteTooltips()
end
----------------------------------------------------------------------------------------------------