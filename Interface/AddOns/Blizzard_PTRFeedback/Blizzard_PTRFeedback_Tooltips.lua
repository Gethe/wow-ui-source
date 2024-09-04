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
    glyph = "Glyph",
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
function PTR_IssueReporter.SetupCurrencyTooltips()
    hooksecurefunc(GameTooltip, "SetCurrencyToken", function(self, index)
        local id = tonumber(string.match(C_CurrencyInfo.GetCurrencyListLink(index),"currency:(%d+)"))
        local name = C_CurrencyInfo.GetCurrencyInfo(id).name
        if (id) and (name) then
            PTR_IssueReporter.HookIntoTooltip(self, PTR_IssueReporter.TooltipTypes.currency, id, name)
        end
    end)
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SetupItemTooltips()
    local function attachItemTooltip(self)
        local name, link = self:GetItem()
        if (link) and (name) then
            local id = string.match(link, "item:(%d*)")

			local mouseoverReagentIndex = nil;
			local mouseMotionFoci = GetMouseFoci();
			for _, focus in ipairs(mouseMotionFoci) do
				if focus.reagentIndex then
					mouseoverReagentIndex = focus.reagentIndex;
				end
			end

            if (id == "" or id == "0") and TradeSkillFrame ~= nil and TradeSkillFrame:IsVisible() and mouseoverReagentIndex then
                local selectedRecipe = TradeSkillFrame.RecipeList:GetSelectedRecipeID()
                for i = 1, 8 do
                    if mouseoverReagentIndex == i then
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
    local bindingFunc = function(EventCallbackData, self, questName, questID, inParty)
        if (questID) and (questName) then
            GameTooltip:SetOwner(self, "ANCHOR_NONE")
            GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 0)
            GameTooltip:AddLine(string.format("%s (QID%s)", questName, questID))
            PTR_IssueReporter.HookIntoTooltip(GameTooltip, PTR_IssueReporter.TooltipTypes.quest, questID, questName)
            GameTooltip:Show()
        end
    end

    EventRegistry:RegisterCallback("QuestLogFrame.MouseOver", bindingFunc, "PTR_IssueReporter")
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
function PTR_IssueReporter.SetupGlyphTooltips()
    local bindingFunc = function(sender, frame, glyphName, glyphSpellID)
        if (glyphName) and (glyphSpellID) then
            PTR_IssueReporter.HookIntoTooltip(GameTooltip, PTR_IssueReporter.TooltipTypes.glyph, glyphSpellID, glyphName)
        end
    end

    EventRegistry:RegisterCallback("GlyphFrameGlyph.MouseOver", bindingFunc,"PTR_IssueReporter")
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.InitializePTRTooltips()
    PTR_IssueReporter.SetupSpellTooltips()
    PTR_IssueReporter.SetupItemTooltips()
    PTR_IssueReporter.SetupUnitTooltips()
    PTR_IssueReporter.SetupQuestTooltips()
    PTR_IssueReporter.SetupTalentTooltips()
    PTR_IssueReporter.SetupSkillTooltips()
    PTR_IssueReporter.SetupGlyphTooltips()
    PTR_IssueReporter.SetupCurrencyTooltips()
end
----------------------------------------------------------------------------------------------------