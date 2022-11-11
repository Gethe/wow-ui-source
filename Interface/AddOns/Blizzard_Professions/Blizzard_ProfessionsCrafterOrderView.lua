
ProfessionsCrafterOrderViewMixin = {};

function ProfessionsCrafterOrderViewMixin:InitButtons()
    self.OrderInfo.BackButton:SetScript("OnClick", function() self:CloseOrder(); end);
    self.OrderInfo.StartOrderButton:SetScript("OnClick", function() C_CraftingOrders.ClaimOrder(self.order.orderID, C_TradeSkillUI.GetChildProfessionInfo().profession); end);
    self.OrderInfo.ReleaseOrderButton:SetScript("OnClick", function() C_CraftingOrders.ReleaseOrder(self.order.orderID, C_TradeSkillUI.GetChildProfessionInfo().profession); end);
    self.OrderInfo.DeclineOrderButton:SetScript("OnClick", function()
        self.DeclineOrderDialog.NoteEditBox.ScrollingEditBox:SetText("");
        self.DeclineOrderDialog:Show();
    end);
    self.OrderInfo.IgnoreButton:SetScript("OnClick", function() 
        local referenceKey = self;
		if not StaticPopup_IsCustomGenericConfirmationShown(referenceKey) then
			local customData = 
            {
				text = CRAFTING_ORDERS_IGNORE_CONFIRMATION,
                text_arg1 = self.order.customerName,
				callback = function()
                    C_FriendList.AddIgnore(self.order.customerName);
                end,
				acceptText = YES,
				cancelText = NO,
				referenceKey = referenceKey,
			};

			StaticPopup_ShowCustomGenericConfirmation(customData);
		end
     end);

    self.CreateButton:SetScript("OnClick", function()
        if self:IsRecrafting() then
            self:RecraftOrder();
        else
            self:CraftOrder();
        end
     end);

    self.StartRecraftButton:SetScript("OnEnter", function(frame)
        if not frame:IsEnabled() then
            GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
            GameTooltip_AddErrorLine(GameTooltip, CRAFTING_ORDER_CANT_RECRAFT_CRAFTER);
            GameTooltip:Show();
        end
    end);
    self.StartRecraftButton:SetScript("OnClick", function()
        self.recraftingOrderID = self.order.orderID;
        self:SetOrder(self.order); -- Refresh all
    end);
    self.StopRecraftButton:SetScript("OnClick", function()
        self.recraftingOrderID = nil;
        self:SetOrder(self.order); -- Refresh all
    end);

    self.CompleteOrderButton:SetScript("OnClick", function() 
        local note = self.OrderDetails.FulfillmentForm.NoteEditBox.ScrollingEditBox:GetInputText();
        note = string.gsub(note, "\n", "");
        C_CraftingOrders.FulfillOrder(self.order.orderID, note, C_TradeSkillUI.GetChildProfessionInfo().profession);
    end);
    
    self.DeclineOrderDialog.ConfirmButton:SetScript("OnClick", function() C_CraftingOrders.RejectOrder(self.order.orderID, self.DeclineOrderDialog.NoteEditBox.ScrollingEditBox:GetInputText(), C_TradeSkillUI.GetChildProfessionInfo().profession) end);
    self.DeclineOrderDialog.CancelButton:SetScript("OnClick", function() self.DeclineOrderDialog:Hide(); end);
end

function ProfessionsCrafterOrderViewMixin:InitRegions()
    self.OrderDetails.FulfillmentForm.OrderCompleteText:SetText(PROFESSIONS_ORDER_COMPLETE);
    self.OrderDetails.FulfillmentForm.ItemIcon:SetScript("OnEnter", function(icon)
        if self.order.outputItemHyperlink then
            GameTooltip:SetOwner(icon, "ANCHOR_RIGHT");
            GameTooltip:SetHyperlink(self.order.outputItemHyperlink);
        end
    end);
    self.OrderDetails.FulfillmentForm.RecraftSlot.InputSlot:SetScript("OnEnter", function(slot)
        if self.order.recraftItemHyperlink then
            GameTooltip:SetOwner(slot, "ANCHOR_RIGHT");
            GameTooltip:SetHyperlink(self.order.recraftItemHyperlink);
        end
    end);
    self.OrderDetails.FulfillmentForm.RecraftSlot.InputSlot:SetScript("OnLeave", GameTooltip_Hide);
    self.OrderDetails.FulfillmentForm.RecraftSlot.OutputSlot:SetScript("OnEnter", function(slot)
        if self.order.outputItemHyperlink then
            GameTooltip:SetOwner(slot, "ANCHOR_RIGHT");
            GameTooltip:SetHyperlink(self.order.outputItemHyperlink);
        end
    end);
    self.OrderDetails.FulfillmentForm.RecraftSlot.OutputSlot:SetScript("OnLeave", GameTooltip_Hide);

    self.OrderDetails.MinimumQualityIcon:SetScript("OnEnter", function(icon)
        GameTooltip:SetOwner(icon, "ANCHOR_RIGHT");

		local smallIcon = true;
        GameTooltip_AddHighlightLine(GameTooltip, PROFESSIONS_ORDER_HAS_MINIMUM_QUALITY_FMT:format(Professions.GetChatIconMarkupForQuality(self.order.minQuality, smallIcon)));
        GameTooltip:Show();
    end);
    self.OrderDetails.MinimumQualityIcon:SetScript("OnLeave", function()
        GameTooltip_Hide();
    end);

    self.DeclineOrderDialog:SetTitle(PROFESSIONS_DECLINE_DIALOG_TITLE);

    self.OrderInfo.ConsortiumCutMoneyDisplayFrame:SetFontObject(NumberFontNormalRightRed);

	self.CraftingOutputLog:SetScript("OnShow", function()
		local p, r, rp, x, y = self.CraftingOutputLog:GetPointByName("TOPLEFT");
		local width = ProfessionsFrame:GetWidth() + self.CraftingOutputLog:GetMaxPossibleWidth() + x;
		SetUIPanelAttribute(ProfessionsFrame, "width", width);
		UpdateUIPanelPositions(ProfessionsFrame);
	end);

	self.CraftingOutputLog:SetScript("OnHide", function()
		ProfessionsCraftingOutputLogMixin.OnHide(self.CraftingOutputLog);
		local width = ProfessionsFrame:GetWidth();
		SetUIPanelAttribute(ProfessionsFrame, "width", width);
		UpdateUIPanelPositions(ProfessionsFrame);
	end);
end

function ProfessionsCrafterOrderViewMixin:OnLoad()
    self:InitButtons();
    self:InitRegions();

    self.OrderDetails.SchematicForm.postInit = function() self:SchematicPostInit(); end;
end

local ProfessionsCrafterOrderViewEvents =
{
    "CRAFTINGORDERS_CLAIM_ORDER_RESPONSE",
    "CRAFTINGORDERS_RELEASE_ORDER_RESPONSE",
    "CRAFTINGORDERS_REJECT_ORDER_RESPONSE",
    "CRAFTINGORDERS_UPDATE_CUSTOMER_NAME",
    "CRAFTINGORDERS_CLAIMED_ORDER_ADDED",
    "CRAFTINGORDERS_CLAIMED_ORDER_REMOVED",
    "CRAFTINGORDERS_CLAIMED_ORDER_UPDATED",
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_FAILED",
    "UPDATE_TRADESKILL_CAST_COMPLETE",
    "PLAYER_MONEY",
    "IGNORELIST_UPDATE",
	"TRADE_SKILL_LIST_UPDATE",
};
function ProfessionsCrafterOrderViewMixin:OnEvent(event, ...)
    if event == "CRAFTINGORDERS_CLAIM_ORDER_RESPONSE" then
        local result, orderID = ...;
        if orderID ~= self.order.orderID then
            return;
        end

        local success = result == Enum.CraftingOrderResult.Ok;
        if not success then
			if (result == Enum.CraftingOrderResult.CannotClaimOwnOrder) then
				UIErrorsFrame:AddExternalErrorMessage(PROFESSIONS_ORDER_CANNOT_CLAIM_OWN_ORDER);
			else
				UIErrorsFrame:AddExternalErrorMessage(PROFESSIONS_ORDER_NOT_AVAILABLE);
			end
            self:CloseOrder();
        end
        -- View will update when the order added event comes in
    elseif event == "CRAFTINGORDERS_RELEASE_ORDER_RESPONSE" then
        local result, orderID = ...;
        if orderID ~= self.order.orderID then
            return;
        end

        self:CloseOrder();
    elseif event == "CRAFTINGORDERS_REJECT_ORDER_RESPONSE" then
        local result, orderID = ...;
        if orderID ~= self.order.orderID then
            return;
        end

        self:CloseOrder();
    elseif event == "CRAFTINGORDERS_UPDATE_CUSTOMER_NAME" then
        local customerName, orderID = ...;
        if orderID ~= self.order.orderID then
            return;
        end

        self.OrderInfo.PostedByValue:SetText(customerName);
        self.order.customerName = customerName;
    elseif event == "CRAFTINGORDERS_CLAIMED_ORDER_ADDED" then
        self:SetOrder(C_CraftingOrders.GetClaimedOrder());
    elseif event == "CRAFTINGORDERS_CLAIMED_ORDER_REMOVED" then
        if self.order.orderState == Enum.CraftingOrderState.Claimed and not C_CraftingOrders.GetClaimedOrder() then
            -- Claimed order got removed
            self:CloseOrder();
        end
    elseif event == "CRAFTINGORDERS_CLAIMED_ORDER_UPDATED" then
        local orderID = ...;
        if orderID == self.order.orderID then
            self:SetOrder(C_CraftingOrders.GetClaimedOrder());
        end
    elseif event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED" or event == "UPDATE_TRADESKILL_CAST_COMPLETE" then
		self:SetOverrideCastBarActive(false);
    elseif event == "PLAYER_MONEY" then
        self:UpdateFulfillButton();
    elseif event == "IGNORELIST_UPDATE" then
        if C_FriendList.IsIgnoredByGuid(self.order.customerGuid) then
            self:CloseOrder();
        end
	elseif event == "TRADE_SKILL_LIST_UPDATE" then
		self:UpdateCreateButton();
		self:UpdateStartOrderButton();
    end
end

function ProfessionsCrafterOrderViewMixin:OnShow()
    FrameUtil.RegisterFrameForEvents(self, ProfessionsCrafterOrderViewEvents);
    self:SetScript("OnUpdate", self.OnUpdate);

    local function AllocationUpdatedUpdatedCallback()
        self:UpdateCreateButton();
    end
    EventRegistry:RegisterCallback("Professions.AllocationUpdated", AllocationUpdatedUpdatedCallback, self);
end

function ProfessionsCrafterOrderViewMixin:OnHide()
	self.CraftingOutputLog:Close();
    FrameUtil.UnregisterFrameForEvents(self, ProfessionsCrafterOrderViewEvents);
    self:SetScript("OnUpdate", nil);
    EventRegistry:UnregisterCallback("Professions.AllocationUpdated", self);
    self:SetOverrideCastBarActive(false);
    StaticPopup_Hide("GENERIC_CONFIRMATION");
end

function ProfessionsCrafterOrderViewMixin:OnUpdate()
    local orderState = self.order.orderState;

    if orderState == Enum.CraftingOrderState.Claimed then
        self:UpdateClaimEndTime();
    end
end

function ProfessionsCrafterOrderViewMixin:UpdateClaimEndTime()
    local timeRemaining = Professions.GetCraftingOrderRemainingTime(self.order.claimEndTime);
    local fmt, time = SecondsToTimeAbbrev(timeRemaining);
    self.OrderInfo.TimeRemainingValue:SetText(fmt:format(time));
end

function ProfessionsCrafterOrderViewMixin:CloseOrder()
    self:GetParent():CloseOrder();
end

function ProfessionsCrafterOrderViewMixin:SchematicPostInit()
    self.hasOptionalReagentSlots = true;
    self.reagentSlotProvidedByCustomer = {};

    local transaction = self.OrderDetails.SchematicForm.transaction;
    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(self.order.spellID);
    local reagentSlotToItemID = {};

    if self:IsRecrafting() then
        local function AllocateModification(slotIndex, reagentSlotSchematic)
            local modification = transaction:GetModification(reagentSlotSchematic.dataSlotIndex);
            if modification and modification.itemID > 0 then
                local reagent = Professions.CreateCraftingReagentByItemID(modification.itemID);
                transaction:OverwriteAllocation(slotIndex, reagent, reagentSlotSchematic.quantityRequired);
            end
        end
    
        for slotIndex, reagentSlotSchematic in ipairs(self.OrderDetails.SchematicForm.recipeSchematic.reagentSlotSchematics) do
            if reagentSlotSchematic.dataSlotType == Enum.TradeskillSlotDataType.ModifiedReagent then
                AllocateModification(slotIndex, reagentSlotSchematic);
            end
        end
    end

    if not self.order.isFulfillable then -- Don't re-use reagents for subsequent recrafts
        for _, reagentInfo in ipairs(self.order.reagents) do
            local allocations = transaction:GetAllocations(reagentInfo.reagentSlot);

            if not self.reagentSlotProvidedByCustomer[reagentInfo.reagentSlot] then
                allocations:Clear();
                self.reagentSlotProvidedByCustomer[reagentInfo.reagentSlot] = true;
            end
            -- These allocations get cleared before sending the craft, but we allocate them for craft readiness validation
            allocations:Allocate(reagentInfo.reagent, reagentInfo.reagent.quantity);
            reagentSlotToItemID[reagentInfo.reagentSlot] = reagentInfo.reagent.itemID;
        end
    end

    for reagentType, slots in pairs(self.OrderDetails.SchematicForm.reagentSlots) do
        for _, slot in ipairs(slots) do
            local providedByCustomer = self.reagentSlotProvidedByCustomer[slot:GetSlotIndex()];
            if providedByCustomer then
                slot:SetUnallocatable(true);
                slot:SetOverrideNameColor(HIGHLIGHT_FONT_COLOR);
				slot:SetShowOnlyRequired(true);
                slot:SetCheckmarkShown(true);
				slot:SetCheckmarkTooltipText(PROFESSIONS_CUSTOMER_ORDER_REAGENT_PROVIDED);
            end

            if self.order.orderState == Enum.CraftingOrderState.Created then
                slot:SetUnallocatable(true);
                slot:SetAddIconDesaturated(true);
            end

            if reagentType == Enum.CraftingReagentType.Optional then
				local modification = transaction:GetModification(slot:GetReagentSlotSchematic().dataSlotIndex);
				if modification and modification.itemID > 0 then
					slot:SetItem(Item:CreateFromItemID(modification.itemID));
				end
                local locked, lockedReason = Professions.GetReagentSlotStatus(slot:GetReagentSlotSchematic(), recipeInfo);

                if providedByCustomer then
                    local continuableContainer = ContinuableContainer:Create();
                    local item = Item:CreateFromItemID(reagentSlotToItemID[slot:GetSlotIndex()]);
                    continuableContainer:AddContinuable(item);
                    continuableContainer:ContinueOnLoad(function()
                        slot:SetItem(item);
                    end);

                    if locked then
                        slot:SetOverrideNameColor(ERROR_COLOR);
                        slot:SetColorOverlay(ERROR_COLOR);
                        slot.Button.InputOverlay.LockedIcon:Show();
                        self.hasOptionalReagentSlots = false;
                    end
                end

                if (not providedByCustomer) and (not locked) and slot:GetReagentSlotSchematic().orderSource == Enum.CraftingOrderReagentSource.Customer and not self:IsRecrafting() then
                    slot:SetOverrideNameColor(DISABLED_REAGENT_COLOR);
                    slot:SetUnallocatable(true);
                    slot:SetAddIconDesaturated(true);
                    slot.Button:SetScript("OnEnter", function()
                        GameTooltip:SetOwner(slot.Button, "ANCHOR_RIGHT");
		                GameTooltip_AddHighlightLine(GameTooltip, PROFESSIONS_SLOT_ONLY_BY_CUSTOMER);
		                GameTooltip:Show();
                    end);
                elseif self:IsRecrafting() and (not locked) and (not providedByCustomer) then
                    slot:SetOverrideNameColor(DISABLED_REAGENT_COLOR);
                    slot:SetUnallocatable(true);
                    slot:SetAddIconDesaturated(true);
                    slot.Button:SetScript("OnEnter", function()
                        GameTooltip:SetOwner(slot.Button, "ANCHOR_RIGHT");
		                GameTooltip_AddHighlightLine(GameTooltip, PROFESSIONS_SLOT_CANT_CHANGE_IN_RECRAFT);
		                GameTooltip:Show();
                    end);
                end
            end
        end
    end

    if self:IsRecrafting() then
        self.OrderDetails.SchematicForm.recraftSlot:Init(self.transaction, function() return false; end, nop, self.order.outputItemHyperlink or self.order.recraftItemHyperlink);
        self.OrderDetails.SchematicForm.recraftSlot.InputSlot:SetScript("OnEnter", function(slot)
            GameTooltip:SetOwner(slot, "ANCHOR_RIGHT");
            GameTooltip:SetHyperlink(self.order.outputItemHyperlink or self.order.recraftItemHyperlink);
            GameTooltip:Show();
        end);
        self.OrderDetails.SchematicForm.recraftSlot.OutputSlot:SetScript("OnEnter", function(slot)
            GameTooltip:SetOwner(slot, "ANCHOR_RIGHT");
            local reagents = transaction:CreateCraftingReagentInfoTbl();
            GameTooltip:SetRecipeResultItemForOrder(self.order.spellID, reagents, self.order.orderID, self.OrderDetails.SchematicForm:GetCurrentRecipeLevel());
        end);
        self.OrderDetails.SchematicForm.recraftSlot.InputSlot:SetScript("OnMouseDown", nil);
    end

    self.OrderDetails.MinimumQualityIcon:SetShown(self.order.minQuality > 1);
    if self.order.minQuality > 1 then
        local small = true;
        self.OrderDetails.MinimumQualityIcon:SetAtlas(Professions.GetIconForQuality(self.order.minQuality, small), TextureKitConstants.UseAtlasSize);
        self.OrderDetails.MinimumQualityIcon:ClearAllPoints();
        local outputText = self:IsRecrafting() and self.OrderDetails.SchematicForm.RecraftingOutputText or self.OrderDetails.SchematicForm.OutputText;
        self.OrderDetails.MinimumQualityIcon:SetPoint("LEFT", outputText, "RIGHT", 5, 0);
    end

    self.OrderDetails.SchematicForm:UpdateDetailsStats();
    self:UpdateCreateButton();
end

function ProfessionsCrafterOrderViewMixin:UpdateStartOrderButton()
    local enabled = true;
    local errorReason;

    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(self.order.spellID);
	local profession = C_TradeSkillUI.GetChildProfessionInfo().profession;
    local claimInfo = profession and C_CraftingOrders.GetOrderClaimInfo(profession);
    if self.order.customerGuid == UnitGUID("player") then
        enabled = false;
        errorReason = PROFESSIONS_CRAFTER_CANT_CLAIM_OWN;
    elseif claimInfo and self.order.orderType == Enum.CraftingOrderType.Public and claimInfo.claimsRemaining <= 0 and Professions.GetCraftingOrderRemainingTime(self.order.expirationTime) > Constants.ProfessionConsts.PUBLIC_CRAFTING_ORDER_STALE_THRESHOLD then
        enabled = false;
        errorReason = PROFESSIONS_CRAFTER_OUT_OF_CLAIMS_FMT:format(claimInfo.hoursToRecharge);
    elseif not recipeInfo or not recipeInfo.learned then
        enabled = false;
        errorReason = PROFESSIONS_CRAFTER_CANT_CLAIM_UNLEARNED;
    elseif not self.hasOptionalReagentSlots then
        enabled = false;
        errorReason = PROFESSIONS_CRAFTER_CANT_CLAIM_REAGENT_SLOT;
    end

    self.OrderInfo.StartOrderButton:SetEnabled(enabled);
    if not enabled then
        self.OrderInfo.StartOrderButton:SetScript("OnEnter", function()
            GameTooltip:SetOwner(self.OrderInfo.StartOrderButton, "ANCHOR_RIGHT");
		    GameTooltip_AddErrorLine(GameTooltip, errorReason);
		    GameTooltip:Show();
        end);
    else
        self.OrderInfo.StartOrderButton:SetScript("OnEnter", function()
            GameTooltip:SetOwner(self.OrderInfo.StartOrderButton, "ANCHOR_RIGHT");
            GameTooltip_AddHighlightLine(GameTooltip, PROFESSIONS_START_ORDER_TOOLTIP);
            GameTooltip:Show();
        end);
    end
end

function ProfessionsCrafterOrderViewMixin:UpdateFulfillButton()
    local enabled = true;
    local errorReason;

    local maxGold = 99999999999;
    if GetMoney() + self.order.tipAmount - self.order.consortiumCut > maxGold then
        enabled = false;
        errorReason = ERR_TOO_MUCH_GOLD;
    end

    self.CompleteOrderButton:SetEnabled(enabled);
    if not enabled then
        self.CompleteOrderButton:SetScript("OnEnter", function()
            GameTooltip:SetOwner(self.CompleteOrderButton, "ANCHOR_RIGHT");
		    GameTooltip_AddErrorLine(GameTooltip, errorReason);
		    GameTooltip:Show();
        end);
    else
        self.CompleteOrderButton:SetScript("OnEnter", nil);
    end
end

function ProfessionsCrafterOrderViewMixin:UpdateCreateButton()
    local transaction = self.OrderDetails.SchematicForm.transaction;
    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(self.order.spellID);
    if transaction:IsRecipeType(Enum.TradeskillRecipeType.Enchant) then
        self.CreateButton:SetText(CREATE_PROFESSION_ENCHANT);
    else
        if recipeInfo and recipeInfo.abilityVerb then
            -- abilityVerb is recipe-level override
            self.CreateButton:SetText(recipeInfo.abilityVerb);
        elseif recipeInfo and recipeInfo.alternateVerb then
            -- alternateVerb is profession-level override
            self.CreateButton:SetText(recipeInfo.alternateVerb);
        elseif self:IsRecrafting() then
            self.CreateButton:SetText(PROFESSIONS_CRAFTING_RECRAFT);
        else
            self.CreateButton:SetText(CREATE_PROFESSION);
        end
    end

    local enabled = true;
    local errorReason;

    if Professions.IsRecipeOnCooldown(self.order.spellID) then
        enabled = false;
        errorReason = PROFESSIONS_RECIPE_COOLDOWN;
    elseif not transaction:HasAllocatedReagentRequirements() then
        enabled = false;
        errorReason = PROFESSIONS_INSUFFICIENT_REAGENTS;
    elseif self.order.minQuality and self.OrderDetails.SchematicForm.Details:GetProjectedQuality() and self.order.minQuality > self.OrderDetails.SchematicForm.Details:GetProjectedQuality() then
        enabled = false;

		local smallIcon = true;
        errorReason = PROFESSIONS_ORDER_HAS_MINIMUM_QUALITY_FMT:format(Professions.GetChatIconMarkupForQuality(self.order.minQuality, smallIcon));
    end

    self.CreateButton:SetEnabled(enabled);
    if not enabled then
        self.CreateButton:SetScript("OnEnter", function()
            GameTooltip:SetOwner(self.CreateButton, "ANCHOR_RIGHT");
		    GameTooltip_AddErrorLine(GameTooltip, errorReason);
		    GameTooltip:Show();
        end);
    else
        self.CreateButton:SetScript("OnEnter", nil);
    end
end

function ProfessionsCrafterOrderViewMixin:SetOrder(order)
    self.order = order;

    self.OrderInfo.PostedByValue:SetText(order.customerName);
    self.OrderInfo.NoteBox.NoteText:SetText(order.customerNotes);
    self.OrderInfo.CommissionTitleMoneyDisplayFrame:SetAmount(order.tipAmount);
    self.OrderInfo.ConsortiumCutMoneyDisplayFrame:SetAmount(order.consortiumCut);
    self.OrderInfo.FinalTipMoneyDisplayFrame:SetAmount(order.tipAmount - order.consortiumCut);
    self.OrderDetails.FulfillmentForm.NoteEditBox.ScrollingEditBox:SetText("");

    local isRecraft = self:IsRecrafting();
	local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(self.order.spellID, isRecraft);
    self.OrderDetails.SchematicForm.transaction = CreateProfessionsRecipeTransaction(recipeSchematic);
    if isRecraft then
        self.OrderDetails.SchematicForm.transaction:SetRecraftAllocationOrderID(order.orderID);
    end
    local recipeInfo = C_TradeSkillUI.GetRecipeInfo(self.order.spellID);
    local highestRecipe = Professions.GetHighestLearnedRecipe(recipeInfo);
	self.OrderDetails.SchematicForm:Init(highestRecipe or recipeInfo, isRecraft);
    self:UpdateStartOrderButton(); -- Must get called after the schematic form is initialized
    self:UpdateFulfillButton();

    if order.outputItemHyperlink then
        self.OrderDetails.FulfillmentForm.ItemIcon:SetShown(not order.isRecraft);
        self.OrderDetails.FulfillmentForm.ItemName:SetShown(not order.isRecraft);
        self.OrderDetails.FulfillmentForm.RecraftSlot:SetShown(order.isRecraft);

        local craftedItem = Item:CreateFromItemLink(order.outputItemHyperlink);
        self.OrderDetails.FulfillmentForm.OrderCompleteText:ClearAllPoints();
        if order.isRecraft then
            local originalItem = Item:CreateFromItemLink(order.recraftItemHyperlink);
            self.OrderDetails.FulfillmentForm.RecraftSlot.InputSlot:Init(originalItem);
            self.OrderDetails.FulfillmentForm.RecraftSlot.OutputSlot:Init(craftedItem);
            self.OrderDetails.FulfillmentForm.RecraftSlot:PlayAnimations();

            self.OrderDetails.FulfillmentForm.OrderCompleteText:SetPoint("LEFT", self.OrderDetails.FulfillmentForm.RecraftSlot, "RIGHT", -55, 10);
        else
            self.OrderDetails.FulfillmentForm.RecraftSlot:StopAnimations();
            local schematic = C_TradeSkillUI.GetRecipeSchematic(order.spellID, isRecraft, self.OrderDetails.SchematicForm:GetCurrentRecipeLevel());
            local icon = craftedItem:GetItemIcon();
            local itemLink = craftedItem:GetItemLink();
            local quality = craftedItem:GetItemQuality();
            Professions.SetupOutputIconCommon(self.OrderDetails.FulfillmentForm.ItemIcon, schematic.quantityMin, schematic.quantityMax, icon, itemLink, quality);
    
            local color = craftedItem:GetItemQualityColor().color;
            local itemNameText = WrapTextInColor(craftedItem:GetItemName(), color);
            self.OrderDetails.FulfillmentForm.ItemName:SetWidth(500);
            self.OrderDetails.FulfillmentForm.ItemName:SetText(itemNameText);
            self.OrderDetails.FulfillmentForm.ItemName:SetWidth(self.OrderDetails.FulfillmentForm.ItemName:GetStringWidth());

            self.OrderDetails.FulfillmentForm.OrderCompleteText:SetPoint("TOPLEFT", self.OrderDetails.FulfillmentForm.ItemName, "TOPLEFT", 0, -15);
        end
    end

    self.DeclineOrderDialog:Hide();
    self:SetOrderState(order.orderState);
end

function ProfessionsCrafterOrderViewMixin:SetOrderState(orderState)
    local showBackButton = false;
    local showStartOrderButton = false;
    local showReleaseOrderButton = false;
    local showTimeRemaining = false;
    local showCreateButton = false;
    local showSchematic = false;
    local showFulfillmentForm = false;
    local showCompleteOrderButton = false;
    local showStartRecraftButton = false;
    local enableStartRecraftButton = false;
    local showStopRecraftButton = false;
    local showDeclineOrderButton = false;
    local showIgnoreCustomerButton = false;

    if orderState == Enum.CraftingOrderState.Created then
        showBackButton = true;
        showStartOrderButton = true;
        showSchematic = true;
        showDeclineOrderButton = self.order.orderType == Enum.CraftingOrderType.Personal;
        showIgnoreCustomerButton = self.order.customerGuid ~= UnitGUID("player");
    elseif orderState == Enum.CraftingOrderState.Claimed then
        showTimeRemaining = true;

        if self.order.isFulfillable and self.recraftingOrderID ~= self.order.orderID then
            showCompleteOrderButton = true;
            showStartRecraftButton = C_CraftingOrders.OrderCanBeRecrafted(self.order.orderID);
            enableStartRecraftButton = showStartRecraftButton and (C_TradeSkillUI.GetItemCraftedQualityByItemInfo(self.order.outputItemHyperlink) < #C_TradeSkillUI.GetQualitiesForRecipe(self.order.spellID));
            showFulfillmentForm = true;
        else
            showCreateButton = true;
            showSchematic = true;
            showReleaseOrderButton = not self.order.isFulfillable;
            showStopRecraftButton = self.recraftingOrderID == self.order.orderID;
        end
    end

    self.OrderInfo.BackButton:SetShown(showBackButton);
    self.OrderInfo.IgnoreButton:SetShown(showIgnoreCustomerButton);
    self.OrderInfo.StartOrderButton:SetShown(showStartOrderButton);
    self.OrderInfo.ReleaseOrderButton:SetShown(showReleaseOrderButton);
    self.OrderInfo.TimeRemainingTitle:SetShown(showTimeRemaining);
    self.OrderInfo.TimeRemainingValue:SetShown(showTimeRemaining);
    self.CreateButton:SetShown(showCreateButton);
    self.OrderDetails.SchematicForm:SetShown(showSchematic);
    self.OrderDetails.FulfillmentForm:SetShown(showFulfillmentForm);
    self.CompleteOrderButton:SetShown(showCompleteOrderButton);
    self.StartRecraftButton:SetShown(showStartRecraftButton);
    self.StartRecraftButton:SetEnabled(enableStartRecraftButton);
    self.StopRecraftButton:SetShown(showStopRecraftButton);
    self.OrderInfo.DeclineOrderButton:SetShown(showDeclineOrderButton);

    self.OrderInfo.StartOrderButton:ClearAllPoints();
    local xOfs = showDeclineOrderButton and -70 or 0;
    local yOfs = showDeclineOrderButton and 8 or 125;
    self.OrderInfo.StartOrderButton:SetPoint("BOTTOM", self.OrderInfo, "BOTTOM", xOfs, yOfs);
end

function ProfessionsCrafterOrderViewMixin:CraftOrder()
    self:SetOverrideCastBarActive(true);
    local recipeID = self.order.spellID;
    local count = 1;
    local predicate = function(reagentTbl, slotIndex)
		return reagentTbl.reagentSlotSchematic.dataSlotType == Enum.TradeskillSlotDataType.ModifiedReagent and not self.reagentSlotProvidedByCustomer[slotIndex];
	end
    local craftingReagentTbl = self.OrderDetails.SchematicForm.transaction:CreateCraftingReagentInfoTblIf(predicate);
    local recipeLevel = self.OrderDetails.SchematicForm:GetCurrentRecipeLevel();
    C_TradeSkillUI.CraftRecipe(recipeID, count, craftingReagentTbl, recipeLevel, self.order.orderID);
	self.CraftingOutputLog:StartListening();
end

function ProfessionsCrafterOrderViewMixin:RecraftOrder()
    self:SetOverrideCastBarActive(true);
    local predicate = function(reagentTbl, slotIndex)
		return reagentTbl.reagentSlotSchematic.dataSlotType == Enum.TradeskillSlotDataType.ModifiedReagent and not self.reagentSlotProvidedByCustomer[slotIndex];
	end
    local craftingReagentTbl = self.OrderDetails.SchematicForm.transaction:CreateCraftingReagentInfoTblIf(predicate);
    local itemMods = self.OrderDetails.SchematicForm.transaction:GetRecraftItemMods();
    if itemMods then
        for dataSlotIndex, modification in ipairs(itemMods) do
            if modification.itemID > 0 then
                for _, craftingReagentInfo in ipairs(craftingReagentTbl) do
                    if (craftingReagentInfo.itemID == modification.itemID) and (craftingReagentInfo.dataSlotIndex == modification.dataSlotIndex) then
                        -- If the modification still exists in the same position, set it's quantity to 0 to inform the server
                        -- not to modify this reagent.
                        craftingReagentInfo.quantity = 0;
                        break;
                    end
                end
            end
        end
    end
    C_TradeSkillUI.RecraftRecipeForOrder(self.order.orderID, self.order.outputItemGUID, craftingReagentTbl);
	self.CraftingOutputLog:StartListening();
end

function ProfessionsCrafterOrderViewMixin:IsRecrafting()
    return self.order.isRecraft or self.recraftingOrderID == self.order.orderID
end

function ProfessionsCrafterOrderViewMixin:SetOverrideCastBarActive(active)
	if active == self.isOverrideCastBarActive then
		return;
	end

	if active then
		-- Only override the cast bar if the Player Cast Bar is currently locked to the Player Frame
		if PlayerCastingBarFrame:IsAttachedToPlayerFrame() then
			OverlayPlayerCastingBarFrame:StartReplacingPlayerBarAt(self.OverlayCastBarAnchor, { hideBarText = true });
			self.isOverrideCastBarActive = true;
		end
	else
		OverlayPlayerCastingBarFrame:EndReplacingPlayerBar();
		self.isOverrideCastBarActive = false;
	end
end