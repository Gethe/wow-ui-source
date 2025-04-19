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
    talent = "Talent",
    recipe = "Recipe",
    aibot = "Follower",
    scenario = "Scenario",
}
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SetupSpellTooltips()
    local setAuraTooltipFunction = function(self, unit, slotNumber, auraType)
		local auraData = C_UnitAuras.GetAuraDataByIndex(unit, slotNumber, auraType);
        if auraData and auraData.spellId and auraData.name then
            PTR_IssueReporter.HookIntoTooltip(self, PTR_IssueReporter.TooltipTypes.spell, auraData.spellId, auraData.name)
        end
    end

    hooksecurefunc(GameTooltip, "SetUnitAura", setAuraTooltipFunction)
    hooksecurefunc(GameTooltip, "SetUnitBuff", function(self, unit, slotNumber) setAuraTooltipFunction(self, unit, slotNumber, "HELPFUL") end)
    hooksecurefunc(GameTooltip, "SetUnitDebuff", function(self, unit, slotNumber) setAuraTooltipFunction(self, unit, slotNumber, "HARMFUL") end)

    hooksecurefunc("SetItemRef", function(link, ...)
        local id = tonumber(link:match("spell:(%d+)"))
        if (id) then
            local name = C_Spell.GetSpellName(id)
            PTR_IssueReporter.HookIntoTooltip(ItemRefTooltip, PTR_IssueReporter.TooltipTypes.spell, id, name)
        end
    end)

    local onTooltipSetSpellFunction = function(tooltip, tooltipData)
		if (tooltip == GameTooltip or tooltip == EmbeddedItemTooltip) then
			local name, id = tooltip:GetSpell()
			if (id) then
				PTR_IssueReporter.HookIntoTooltip(tooltip, PTR_IssueReporter.TooltipTypes.spell, id, name)
			end
		end
	end
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, onTooltipSetSpellFunction)

    local bindingFunc = function(self, talentFrame, tooltip)
        if (talentFrame) and (tooltip) then
            local spellID = talentFrame:GetSpellID()
            if (spellID) then
                local name = C_Spell.GetSpellName(spellID)
                PTR_IssueReporter.HookIntoTooltip(tooltip, PTR_IssueReporter.TooltipTypes.spell, spellID, name)
            end
        end
    end

    EventRegistry:RegisterCallback("TalentDisplay.TooltipCreated", bindingFunc, "PTR_IssueReporter")
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SetupItemTooltips()
    local function attachItemTooltip(self)
        local name, link = self:GetItem()
        if (link) and (name) then
            local id = string.match(link, "item:(%d*)")
			-- Professions refactor requires an update to this code in both fetching the current recipe ID and retrieving the
			-- reagent information from the mouse position.
           --if (id == "" or id == "0") and TradeSkillFrame ~= nil and TradeSkillFrame:IsVisible() and GetMouseFocus().reagentIndex then
           --    local selectedRecipe = TradeSkillFrame.RecipeList:GetSelectedRecipeID()
           --    for i = 1, 8 do
           --        if GetMouseFocus().reagentIndex == i then
           --            id = C_TradeSkillUI.GetRecipeReagentItemLink(selectedRecipe, i):match("item:(%d+):") or nil
           --            break
           --        end
           --    end
           --end
            if (id) then
                PTR_IssueReporter.HookIntoTooltip(self, PTR_IssueReporter.TooltipTypes.item, id, name, nil, nil, link)
            end
        end
    end

	local function onTooltipSetItemFunction(tooltip, tooltipData)
		if (tooltip == GameTooltip or tooltip == ItemRefTooltip) then
			attachItemTooltip(tooltip)
		end
	end
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, onTooltipSetItemFunction)
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.IsUnitAIFollower(unit)
    return UnitExists(unit) and not UnitPlayerControlled(unit) and UnitInParty(unit)
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SetupUnitTooltips()
    local function onTooltipSetUnitFunction(tooltip, tooltipData)
        if (C_PetBattles.IsInBattle()) then
            return
        end        
        
        local name, unit = tooltip:GetUnit()
        local isBot = PTR_IssueReporter.IsUnitAIFollower(unit)
        if (name) and (unit) then
            local guid = UnitGUID(unit) or ""
            local id = tonumber(guid:match("-(%d+)-%x+$"), 10)
            if (id) and (guid:match("%a+") ~= "Player") then
                local tooltipType = PTR_IssueReporter.TooltipTypes.unit
                if (isBot) then
                    tooltipType = PTR_IssueReporter.TooltipTypes.aibot
                end
                
                PTR_IssueReporter.HookIntoTooltip(GameTooltip, tooltipType, id, name)
            end
        end
    end
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, onTooltipSetUnitFunction)

    local bindingFunc = function(sender, name, guid)
        if (name) and (guid) then
            local id = select(6, strsplit("-", guid))

            --The actual method that sets the tooltip is in c++, so we can't fire a lua event during the set process, only just before
            --the delay is to make sure the hook isn't until after the tooltip has been built
            C_Timer.After(0.1, function()
                PTR_IssueReporter.HookIntoTooltip(ItemRefTooltip, PTR_IssueReporter.TooltipTypes.unit, id, name)
            end)
        end
    end

    EventRegistry:RegisterCallback("ItemRefTooltip.UnitSet", bindingFunc, "JiraIntegration")
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SetupQuestTooltips()
    local function HookIntoQuestTooltip(sender, self, questID, isGroup)
        local title = C_QuestLog.GetTitleForQuestID(questID)
        if (isGroup ~= nil and not isGroup) then
            --If isGroup is null, that means the event always shows tooltip
            --If isGroup is a bool, it only shows a tooltip if true, so when false we must provide our own
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, 0)
            GameTooltip:SetOwner(self, "ANCHOR_PRESERVE")
            PTR_IssueReporter.HookIntoTooltip(GameTooltip, PTR_IssueReporter.TooltipTypes.quest, questID, title, true)
            GameTooltip:Show()
        else
            PTR_IssueReporter.HookIntoTooltip(GameTooltip, PTR_IssueReporter.TooltipTypes.quest, questID, title)
        end
    end

    EventRegistry:RegisterCallback("TaskPOI.TooltipShown", HookIntoQuestTooltip, PTR_IssueReporter)
    EventRegistry:RegisterCallback("MapCanvas.QuestPin.OnEnter", HookIntoQuestTooltip, PTR_IssueReporter)
    EventRegistry:RegisterCallback("QuestMapLogTitleButton.OnEnter", HookIntoQuestTooltip, PTR_IssueReporter)
    EventRegistry:RegisterCallback("OnQuestBlockHeader.OnEnter", HookIntoQuestTooltip, PTR_IssueReporter)
    EventRegistry:RegisterCallback("TaskPOI.TooltipShown", HookIntoQuestTooltip, PTR_IssueReporter)
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SetupAchievementTooltips()
    local bindingFunc = function(sender, self, achievementID)
        local title = select(2, GetAchievementInfo(achievementID))

        GameTooltip:ClearAllPoints();
        GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 0);
        GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
        PTR_IssueReporter.HookIntoTooltip(GameTooltip, PTR_IssueReporter.TooltipTypes.achievement, achievementID, achievementTitle, true)        GameTooltip:Show()
    end

    local exitBindingFunc = function()
        GameTooltip:Hide()
    end

    EventRegistry:RegisterCallback("AchievementFrameAchievement.OnEnter", bindingFunc, PTR_IssueReporter)
    EventRegistry:RegisterCallback("AchievementFrameAchievement.OnLeave", exitBindingFunc, PTR_IssueReporter)
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SetupCurrencyTooltips()
    hooksecurefunc(GameTooltip, "SetCurrencyToken", function(self, index)
        local id = tonumber(string.match(C_CurrencyInfo.GetCurrencyListLink(index),"currency:(%d+)"))
        local name = C_CurrencyInfo.GetCurrencyInfo(id).name
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
function PTR_IssueReporter.SetupMapPinTooltips()
    local function OnAreaPOIPinMouseOver(self, pin, tooltipIsShown, areaPOIID, areaPOIName)
        if not tooltipIsShown then
            GameTooltip:SetOwner(pin, "ANCHOR_RIGHT")
            GameTooltip_AddNormalLine(GameTooltip, areaPOIName)
        end

        -- Todo: PTR_IssueReporter.HookIntoTooltip should replace these.
        GameTooltip_AddBlankLineToTooltip(GameTooltip)
        GameTooltip_AddNormalLine(GameTooltip, RED_FONT_COLOR:WrapTextInColorCode("Todo: add a debug hook."))
        GameTooltip:Show()
    end

    -- Commented out for now as they are some details to work out still.
    -- EventRegistry:RegisterCallback("AreaPOIPin.MouseOver", OnAreaPOIPinMouseOver, PTR_IssueReporter)
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SetupGarrisonTalentTooltips()
    local bindingFunc = function(self, tooltip, talent, talentTreeID)
        if (tooltip) and (talent) and (talent.id) and (talent.name) and (talentTreeID) then
            PTR_IssueReporter.HookIntoTooltip(tooltip, PTR_IssueReporter.TooltipTypes.talent, talent.id, talent.name, nil, nil, talentTreeID)
        end
    end

    EventRegistry:RegisterCallback("GarrisonTalentButtonMixin.TalentTooltipShown", bindingFunc, "PTR_IssueReporter")
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SetupReagentListTooltips()
    local bindingFunc = function(sender, self, recipeID, recipeName, iconID)
        if (recipeID) and (recipeName) and (iconID) then
            GameTooltip:ClearAllPoints();
            GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 0);
            GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
            PTR_IssueReporter.HookIntoTooltip(GameTooltip, PTR_IssueReporter.TooltipTypes.recipe, recipeID, recipeName, true, nil, iconID)
            GameTooltip:Show()
        end
    end

    EventRegistry:RegisterCallback("Professions.RecipeListOnEnter", bindingFunc, "PTR_IssueReporter")
end
----------------------------------------------------------------------------------------------------
function PTR_IssueReporter.SetupScenarioTooltips()
    local bindingFunc = function(sender, tooltip)
        if (tooltip) then
            local scenarioObj = C_ScenarioInfo.GetScenarioInfo()
            PTR_IssueReporter.HookIntoTooltip(tooltip, PTR_IssueReporter.TooltipTypes.scenario, scenarioObj.scenarioID, scenarioObj.name)
        end
    end
    
    EventRegistry:RegisterCallback("Scenario.ObjectTracker_OnEnter", bindingFunc, "JiraIntegration")
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
    PTR_IssueReporter.SetupMapPinTooltips()
    PTR_IssueReporter.SetupGarrisonTalentTooltips()
    PTR_IssueReporter.SetupReagentListTooltips()
    PTR_IssueReporter.SetupScenarioTooltips()
end
----------------------------------------------------------------------------------------------------