ProfessionsUtil = {};

do
	local function Matches(lhs, rhs)
		return lhs and (lhs ~= 0) and (lhs == rhs);
	end
	
	function ProfessionsUtil.CraftingReagentMatches(reagent1, reagent2)
		return Matches(reagent1.itemID, reagent2.itemID) or 
			Matches(reagent1.currencyID, reagent2.currencyID);
	end
end

do
	-- Returns the quantity required by the slot, or a variable quantity determined by
	-- the reagent.
	local function GetQuantityRequired(reagentSlotSchematic, reagent)
		for index, variableQuantity in ipairs(reagentSlotSchematic.variableQuantities) do
			if ProfessionsUtil.CraftingReagentMatches(reagent, variableQuantity.reagent) then
				return variableQuantity.quantity;
			end
		end

		return reagentSlotSchematic.quantityRequired;
	end

	local function HasVariableQuantities(reagentSlotSchematic)
		return #reagentSlotSchematic.variableQuantities > 0;
	end

	local function IsVariableQuantityReagent(reagentSlotSchematic, reagent)
		for index, variableQuantity in ipairs(reagentSlotSchematic.variableQuantities) do
			if ProfessionsUtil.CraftingReagentMatches(reagent, reagent) then
				return true;
			end
		end
		return false;
	end

	local function GetVariableQuantityRange(reagentSlotSchematic, reagent)
		local min, max = math.huge, 0;
		for index, variableQuantity in ipairs(reagentSlotSchematic.variableQuantities) do
			local quantity = variableQuantity.quantity;
			min = math.min(min, quantity);
			max = math.max(max, quantity)
		end
		return min, max;
	end

	function ProfessionsUtil.GetRecipeSchematic(...)
		local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(...);
	
		for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
			reagentSlotSchematic.GetQuantityRequired = GetQuantityRequired;
			reagentSlotSchematic.HasVariableQuantities = HasVariableQuantities;
			reagentSlotSchematic.IsVariableQuantityReagent = IsVariableQuantityReagent;
			reagentSlotSchematic.GetVariableQuantityRange = GetVariableQuantityRange;
		end
	
		return recipeSchematic;
	end
end

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
	local recipeSchematic = ProfessionsUtil.GetRecipeSchematic(recipeID, isRecraft);
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

function ProfessionsUtil.GetReagentQuantityInPossession(reagent, characterInventoryOnly)
	if reagent.itemID then
		return ItemUtil.GetCraftingReagentCount(reagent.itemID, characterInventoryOnly);
	elseif reagent.currencyID then
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(reagent.currencyID);
		return currencyInfo.quantity;
	end
	assert(false);
end

function ProfessionsUtil.AccumulateReagentsInPossession(reagents, characterInventoryOnly)
	return AccumulateOp(reagents, function(reagent)
		return ProfessionsUtil.GetReagentQuantityInPossession(reagent, characterInventoryOnly);
	end);
end

function ProfessionsUtil.CreateProfessionsRecipeTransactionFromCraftingOrder(order)
	local recipeSchematic = ProfessionsUtil.GetRecipeSchematic(order.spellID, order.isRecraft);
	local transaction = CreateProfessionsRecipeTransaction(recipeSchematic);
	for _, reagentInfo in ipairs(order.reagents) do
		local allocations = transaction:GetAllocations(reagentInfo.slotIndex);
		allocations:Allocate(reagentInfo.reagentInfo.reagent, reagentInfo.reagentInfo.quantity);
	end
	return transaction;
end
