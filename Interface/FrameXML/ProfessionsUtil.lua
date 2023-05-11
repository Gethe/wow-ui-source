ProfessionsUtil = {};

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