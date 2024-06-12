ProfessionsUtil = {};

local isCraftingMinimized = false;
function ProfessionsUtil.SetCraftingMinimized(minimized)
	local changed = isCraftingMinimized ~= minimized;
	isCraftingMinimized = minimized;

	if changed then
		EventRegistry:TriggerEvent("ProfessionsFrame.Minimized");
	end
end

function ProfessionsUtil.IsCraftingMinimized()
	return isCraftingMinimized;
end

function ProfessionsUtil.OpenProfessionFrameToRecipe(recipeID)
    local tradeSkillID, skillLineName, parentTradeSkillID = C_TradeSkillUI.GetTradeSkillLineForRecipe(recipeID);
    if tradeSkillID then
        local skillLineID = tradeSkillID;
        tradeSkillID = parentTradeSkillID or tradeSkillID;

        ProfessionsFrame_LoadUI();

        local currBaseProfessionInfo = C_TradeSkillUI.GetBaseProfessionInfo();
        local currentSkillLineInfo = C_TradeSkillUI.GetChildProfessionInfo();
        if currentSkillLineInfo ~= nil and currentSkillLineInfo.professionID == skillLineID then
            local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID);
            ProfessionsFrame:SetTab(ProfessionsFrame.recipesTabID);
            EventRegistry:TriggerEvent("ProfessionsRecipeListMixin.Event.OnRecipeSelected", recipeInfo, nilRecipeList);
            return true;
        elseif currBaseProfessionInfo ~= nil and currBaseProfessionInfo.professionID == tradeSkillID then
            C_TradeSkillUI.SetProfessionChildSkillLineID(skillLineID);
            local professionInfo = C_TradeSkillUI.GetChildProfessionInfo();
            professionInfo.openRecipeID = recipeID;
            EventRegistry:TriggerEvent("Professions.ProfessionSelected", professionInfo);
            return true;
        else
            ProfessionsFrame:SetOpenRecipeResponse(skillLineID, recipeID);
            return C_TradeSkillUI.OpenTradeSkill(tradeSkillID);
        end
    end
    return false;
end

function ProfessionsUtil.CreateRecipeReagentListByPredicate(recipeID, predicate)
	local reagents = {};
	local isRecraft = false;
	local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, isRecraft);
	for _, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
		if predicate(reagentSlotSchematic) then
			tAppendAll(reagents, reagentSlotSchematic.reagents);
		end
	end
	return reagents;
end

function ProfessionsUtil.CreateRecipeReagentsForAllBasicReagents(recipeID, predicate)
	local function IsBasicReagent(reagentSlotSchematic)
		return reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Basic;
	end
	return ProfessionsUtil.CreateRecipeReagentListByPredicate(recipeID, IsBasicReagent);
end

-- This is wrapped in a function because the implementation backing "required" here is likely to change
-- after a planned slot description refactor.
function ProfessionsUtil.IsReagentSlotRequired(reagentSlotSchematic)
	return reagentSlotSchematic.required;
end

function ProfessionsUtil.IsReagentSlotBasicRequired(reagentSlotSchematic)
	return reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Basic and ProfessionsUtil.IsReagentSlotRequired(reagentSlotSchematic);
end

function ProfessionsUtil.IsReagentSlotModifyingRequired(reagentSlotSchematic)
	return reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Modifying and ProfessionsUtil.IsReagentSlotRequired(reagentSlotSchematic);
end

function ProfessionsUtil.GetReagentQuantityInPossession(reagent)
	if reagent.itemID then
		return ItemUtil.GetCraftingReagentCount(reagent.itemID);
	elseif reagent.currencyID then
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(reagent.currencyID);
		return currencyInfo.quantity;
	end
	assert(false);
end

function ProfessionsUtil.AccumulateReagentsInPossession(reagents)
	return AccumulateOp(reagents, function(reagent)
		return ProfessionsUtil.GetReagentQuantityInPossession(reagent);
	end);
end
