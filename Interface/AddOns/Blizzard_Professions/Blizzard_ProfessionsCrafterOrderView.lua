
ProfessionsCrafterOrderRewardMixin = CreateFromMixins(ProfessionsReagentSlotButtonMixin);

function ProfessionsCrafterOrderRewardMixin:SetReward(reward)
	self.reward = reward;

	if reward.itemLink then
		self:SetItem(reward.itemLink);
		local _, itemQuality, _ = self:GetItemInfo();
		self:SetSlotQuality(self, itemQuality);
		self.minDisplayCount = 1;
		SetItemButtonCount(self, self.reward.count);
	elseif reward.currencyType then
		self:SetCurrency(reward.currencyType);
		self.minDisplayCount = 0;
		SetItemButtonCount(self, self.reward.count);
	end

	self:Show();
end

function ProfessionsCrafterOrderRewardMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	local itemLink = self:GetItemLink();
	if itemLink then
		GameTooltip:SetHyperlink(itemLink);
	elseif self.reward.currencyType then
		GameTooltip:SetCurrencyByID(self.reward.currencyType, self.reward.count);
	end
end

function ProfessionsCrafterOrderRewardMixin:OnLeave()
	GameTooltip:Hide();
end

ProfessionsCrafterOrderRewardTooltipMixin = {};

function ProfessionsCrafterOrderRewardTooltipMixin:SetReward(reward)
	self.Reward:SetReward(reward);

	local itemName, itemQuality;

	if reward.itemLink then
		local _itemLink;
		itemName, _itemLink, itemQuality = C_Item.GetItemInfo(reward.itemLink);
	elseif reward.currencyType then
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(reward.currencyType);
		if currencyInfo then
			itemName = currencyInfo.name;
			itemQuality = currencyInfo.quality;
		end
	end

	local itemQualityColor = ITEM_QUALITY_COLORS[itemQuality or Enum.ItemQuality.Common];
	local itemDisplayText = itemQualityColor.color:WrapTextInColorCode(itemName or "");
	self.RewardName:SetText(itemDisplayText);

	self:SetHeight(self.Reward:GetHeight());
	self:SetWidth(self.Reward:GetWidth() + self.RewardName:GetWidth() + 20);
end

ProfessionsCrafterOrderViewMixin = {};
local ownReagentsConfirmationReferenceKey = {};
local ignoreConfirmationReferenceKey = {};

function ProfessionsCrafterOrderViewMixin:InitButtons()
    self.OrderInfo.BackButton:SetScript("OnClick", function() self:CloseOrder(); end);
    self.OrderInfo.StartOrderButton:SetScript("OnClick", function() C_CraftingOrders.ClaimOrder(self.order.orderID, C_TradeSkillUI.GetChildProfessionInfo().profession); end);
    self.OrderInfo.ReleaseOrderButton:SetScript("OnClick", function() C_CraftingOrders.ReleaseOrder(self.order.orderID, C_TradeSkillUI.GetChildProfessionInfo().profession); end);
    self.OrderInfo.DeclineOrderButton:SetScript("OnClick", function()
        self.DeclineOrderDialog.NoteEditBox.ScrollingEditBox:SetText("");
        self.DeclineOrderDialog:Show();
    end);

    self.CreateButton:SetScript("OnClick", function()
		local function StartCraft()
			if self:IsRecrafting() then
				self:RecraftOrder();
			else
				self:CraftOrder();
			end
		end

		local providedReagents = false;
		for slotIndex, allocations in self.OrderDetails.SchematicForm.transaction:EnumerateAllAllocations() do
			if allocations:HasAnyAllocations() and not self.reagentSlotProvidedByCustomer[slotIndex] then
				providedReagents = true;
				break;
			end
		end

		local referenceKey = ownReagentsConfirmationReferenceKey;
		if providedReagents then
			if not StaticPopup_IsCustomGenericConfirmationShown(referenceKey) then
				local customData = 
				{
					text = CRAFTING_ORDERS_OWN_REAGENTS_CONFIRMATION,
					callback = StartCraft,
					acceptText = YES,
					cancelText = CANCEL,
					referenceKey = referenceKey,
				};

				StaticPopup_ShowCustomGenericConfirmation(customData);
			end
		else
			StartCraft();
		end

		if self.order.orderType == Enum.CraftingOrderType.Npc then
			HelpTip:Hide(self.CreateButton, CRAFTING_ORDERS_FIRST_NPC_ORDER_HELPTIP);
			SetCVarBitfield("closedInfoFramesAccountWide", LE_FRAME_TUTORIAL_ACCOUNT_NPC_CRAFTING_ORDER_CREATE_BUTTON, true);
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
		self:CloseGenericConfirmation();
    end);

    self.CompleteOrderButton:SetScript("OnClick", function() 
        local note = self.OrderDetails.FulfillmentForm.NoteEditBox.ScrollingEditBox:GetInputText();
        note = string.gsub(note, "\n", "");
        C_CraftingOrders.FulfillOrder(self.order.orderID, note, C_TradeSkillUI.GetChildProfessionInfo().profession);
    end);
    
    self.DeclineOrderDialog.ConfirmButton:SetScript("OnClick", function() C_CraftingOrders.RejectOrder(self.order.orderID, self.DeclineOrderDialog.NoteEditBox.ScrollingEditBox:GetInputText(), C_TradeSkillUI.GetChildProfessionInfo().profession) end);
    self.DeclineOrderDialog.CancelButton:SetScript("OnClick", function() self.DeclineOrderDialog:Hide(); end);

	SquareButton_SetIcon(self.OrderInfo.SocialDropdown, "DOWN");

	self.OrderInfo.SocialDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_PROFESSIONS_CRAFTER_ORDER_VIEW");

		if not self.order or self.order.customerGuid == nil then
			return;
		end

		local whisperStatus = self:GetWhisperCustomerStatus();

		-- Add whisper option
		local canWhisper = whisperStatus == Enum.ChatWhisperTargetStatus.CanWhisper or whisperStatus == Enum.ChatWhisperTargetStatus.CanWhisperGuild;
		if canWhisper then
			rootDescription:CreateButton(WHISPER_MESSAGE, function()
				ChatFrame_SendTell(self.order.customerName);
			end);
		else
			local button = rootDescription:CreateButton(WHISPER_MESSAGE, nop);
			button:SetEnabled(false);
			button:SetTooltip(function(tooltip, elementDescription)
				if whisperStatus == Enum.ChatWhisperTargetStatus.Offline then
					GameTooltip_AddNormalLine(tooltip, PROF_ORDER_CANT_WHISPER_OFFLINE);
				elseif whisperStatus == Enum.ChatWhisperTargetStatus.WrongFaction then
					GameTooltip_AddNormalLine(tooltip, PROF_ORDER_CANT_WHISPER_WRONG_FACTION);
				end
			end);
		end

		-- Add "Add Friend" option
		local alreadyIsFriend = C_FriendList.IsFriend(self.order.customerGuid);
		local canAddFriend = whisperStatus == Enum.ChatWhisperTargetStatus.CanWhisper and not alreadyIsFriend;
		if canAddFriend then
			rootDescription:CreateButton(ADD_CHARACTER_FRIEND, function()
				C_FriendList.AddFriend(self.order.customerName);
			end);
		else
			local button = rootDescription:CreateButton(ADD_CHARACTER_FRIEND, nop);
			button:SetEnabled(false);
			button:SetTooltip(function(tooltip, elementDescription)
				if alreadyIsFriend then
					GameTooltip_AddNormalLine(tooltip, ALREADY_FRIEND_FMT:format(self.order.customerName));
				elseif whisperStatus == Enum.ChatWhisperTargetStatus.Offline then
					GameTooltip_AddNormalLine(tooltip, PROF_ORDER_CANT_ADD_FRIEND_OFFLINE);
				elseif whisperStatus == Enum.ChatWhisperTargetStatus.WrongFaction or whisperStatus == Enum.ChatWhisperTargetStatus.CanWhisperGuild then
					-- CanWhisperGuild means we can whisper the player despite them being cross-faction because they are in our guild
					GameTooltip_AddNormalLine(tooltip, PROF_ORDER_CANT_ADD_FRIEND_WRONG_FACTION);
				end
			end);
		end
		
		-- Add ignore option
		local canIgnore = self.order.orderState == Enum.CraftingOrderState.Created and not C_FriendList.IsIgnoredByGuid(self.order.customerGuid);
		if canIgnore then
			rootDescription:CreateButton(IGNORE, function()
				local referenceKey = ignoreConfirmationReferenceKey;
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
		else
			local button = rootDescription:CreateButton(ADD_CHARACTER_FRIEND, nop);
			button:SetEnabled(false);
			button:SetTooltip(function(tooltip, elementDescription)
				local text = self.order.orderState ~= Enum.CraftingOrderState.Created and PROF_ORDER_CANT_IGNORE_IN_PROGRESS or PROF_ORDER_CANT_IGNORE_ALREADY_IGNORED;
				GameTooltip_AddNormalLine(tooltip, text);
			end);
		end

		
		-- Add report button
		local canReport = self.order.orderState == Enum.CraftingOrderState.Created;
		if canReport then
			rootDescription:CreateButton(PROF_ORDER_REPORT, function()
				if not ReportFrame:IsShown() then
					local reportInfo = ReportInfo:CreateCraftingOrderReportInfo(Enum.ReportType.CraftingOrder, self.order.orderID);
					if reportInfo then
						local playerLocation = PlayerLocation:CreateFromGUID(self.order.customerGuid);
						ReportFrame:InitiateReport(reportInfo, nil, playerLocation);
					end
				end
			end);
		else
			local button = rootDescription:CreateButton(PROF_ORDER_REPORT, nop);
			button:SetEnabled(false);
			button:SetTooltip(function(tooltip, elementDescription)
				GameTooltip_AddNormalLine(tooltip, PROF_ORDER_CANT_REPORT_IN_PROGRESS);
			end);
		end
	end);
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
	"CRAFTINGORDERS_CRAFT_ORDER_RESPONSE",
	"CRAFTINGORDERS_FULFILL_ORDER_RESPONSE",
    "CRAFTINGORDERS_UPDATE_CUSTOMER_NAME",
	"CRAFTINGORDERS_UPDATE_REWARDS",
    "CRAFTINGORDERS_CLAIMED_ORDER_ADDED",
    "CRAFTINGORDERS_CLAIMED_ORDER_REMOVED",
    "CRAFTINGORDERS_CLAIMED_ORDER_UPDATED",
	"CRAFTINGORDERS_UNEXPECTED_ERROR",
    "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_FAILED",
    "UPDATE_TRADESKILL_CAST_STOPPED",
    "PLAYER_MONEY",
    "IGNORELIST_UPDATE",
	"TRADE_SKILL_LIST_UPDATE",
	"BAG_UPDATE",
	"BAG_UPDATE_DELAYED",
	"CAN_LOCAL_WHISPER_TARGET_RESPONSE",
	"PLAYER_REPORT_SUBMITTED",
};
function ProfessionsCrafterOrderViewMixin:OnEvent(event, ...)
    if event == "CRAFTINGORDERS_CLAIM_ORDER_RESPONSE" then
        local result, orderID = ...;
        if orderID ~= self.order.orderID then
            return;
        end

        local success = result == Enum.CraftingOrderResult.Ok;
        if not success then
			if result == Enum.CraftingOrderResult.CannotClaimOwnOrder then
				UIErrorsFrame:AddExternalErrorMessage(PROFESSIONS_ORDER_CANNOT_CLAIM_OWN_ORDER);
			elseif result == Enum.CraftingOrderResult.OutOfPublicOrderCapacity then
				UIErrorsFrame:AddExternalErrorMessage(PROFESSIONS_ORDER_FAILED_NO_CLAIMS);
			else
				UIErrorsFrame:AddExternalErrorMessage(PROFESSIONS_ORDER_NOT_AVAILABLE);
			end
            self:CloseOrder();
        end

		self:CloseGenericConfirmation();
        -- View will update when the order added event comes in
    elseif event == "CRAFTINGORDERS_RELEASE_ORDER_RESPONSE" or event == "CRAFTINGORDERS_REJECT_ORDER_RESPONSE" then
        local result, orderID = ...;
        if orderID ~= self.order.orderID then
            return;
        end

		local success = result == Enum.CraftingOrderResult.Ok;
        if success then
			self:CloseOrder();
		else
			UIErrorsFrame:AddExternalErrorMessage(PROFESSIONS_ORDER_OP_FAILED);
        end
	elseif event == "CRAFTINGORDERS_CRAFT_ORDER_RESPONSE" then
		local result, orderID = ...;
        if orderID ~= self.order.orderID then
            return;
        end

		if result == Enum.CraftingOrderResult.NoAccountItems then
			UIErrorsFrame:AddExternalErrorMessage(CRAFTING_ORDER_FAILED_ACCOUNT_ITEMS);
		else
			UIErrorsFrame:AddExternalErrorMessage(PROFESSIONS_ORDER_OP_FAILED);
		end
	elseif event == "CRAFTINGORDERS_FULFILL_ORDER_RESPONSE" then
		local result, orderID = ...;
		if orderID ~= self.order.orderID then
            return;
        end

		local success = result == Enum.CraftingOrderResult.Ok;
        if not success then
			UIErrorsFrame:AddExternalErrorMessage(PROFESSIONS_ORDER_OP_FAILED);
        end
		-- View will update when the order removed event comes in
	elseif event == "CRAFTINGORDERS_UNEXPECTED_ERROR" then
		UIErrorsFrame:AddExternalErrorMessage(PROFESSIONS_ORDER_OP_FAILED);
    elseif event == "CRAFTINGORDERS_UPDATE_CUSTOMER_NAME" then
        local customerName, orderID = ...;
        if orderID ~= self.order.orderID then
            return;
        end

        self.OrderInfo.PostedByValue:SetText(customerName);
        self.order.customerName = customerName;
	elseif event == "CRAFTINGORDERS_UPDATE_REWARDS" then
        local rewards, orderID = ...;
        if orderID ~= self.order.orderID then
            return;
        end

        self.order.npcOrderRewards = rewards;
		self:UpdateRewards(self.order);
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
			local function Update()
				-- Clear recrafting so that we go back to the order complete view if we were recrafting
				self.recraftingOrderID = nil;
				self:SetOrder(C_CraftingOrders.GetClaimedOrder());
			end

			if self.OrderDetails.SchematicForm.Details.QualityMeter.animating then
				self.OrderDetails.SchematicForm.Details.QualityMeter:SetOnAnimationsFinished(function()
					Update();
					self.OrderDetails.SchematicForm.Details.QualityMeter:SetOnAnimationsFinished(nil);
				end);
			else
				Update();
			end
        end
    elseif event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED" or event == "UPDATE_TRADESKILL_CAST_STOPPED" then
		self:SetOverrideCastBarActive(false);
    elseif event == "PLAYER_MONEY" then
        self:UpdateFulfillButton();
    elseif event == "IGNORELIST_UPDATE" then
        if C_FriendList.IsIgnoredByGuid(self.order.customerGuid) and self.order and self.order.orderState == Enum.CraftingOrderState.Created then
            self:CloseOrder();
        end
	elseif event == "TRADE_SKILL_LIST_UPDATE" then
		self:UpdateCreateButton();
		self:UpdateStartOrderButton();
	elseif event == "BAG_UPDATE" or event == "BAG_UPDATE_DELAYED" then
		local recipeInfo = C_TradeSkillUI.GetRecipeInfo(self.order.spellID);
		local highestRecipe = Professions.GetHighestLearnedRecipe(recipeInfo);
		self.OrderDetails.SchematicForm:Init(highestRecipe or recipeInfo, self:IsRecrafting());
		self:UpdateCreateButton();
	elseif event == "CAN_LOCAL_WHISPER_TARGET_RESPONSE" then
		local whisperTarget, status = ...;
		
		if whisperTarget == self.order.customerGuid then
			self:SetWhisperCustomerStatus(status);
		end
	elseif event == "PLAYER_REPORT_SUBMITTED" then
		local reportedGuid = ...;
		if reportedGuid == self.order.customerGuid then
			self:CloseOrder();
		end
    end
end

function ProfessionsCrafterOrderViewMixin:OnShow()
    FrameUtil.RegisterFrameForEvents(self, ProfessionsCrafterOrderViewEvents);
    self:SetScript("OnUpdate", self.OnUpdate);

    local function AllocationUpdatedCallback()
        self:UpdateCreateButton();
    end
    EventRegistry:RegisterCallback("Professions.AllocationUpdated", AllocationUpdatedCallback, self);

    local function TransactionUpdatedCallback()
        self:UpdateCreateButton();
    end
    EventRegistry:RegisterCallback("Professions.TransactionUpdated", TransactionUpdatedCallback, self);
end

function ProfessionsCrafterOrderViewMixin:ShowingGenericConfirmation()
	return StaticPopup_IsCustomGenericConfirmationShown(ownReagentsConfirmationReferenceKey) or StaticPopup_IsCustomGenericConfirmationShown(ignoreConfirmationReferenceKey);
end

function ProfessionsCrafterOrderViewMixin:CloseGenericConfirmation()
	if self:ShowingGenericConfirmation() then
		StaticPopup_Hide("GENERIC_CONFIRMATION");
	end
end

function ProfessionsCrafterOrderViewMixin:OnHide()
	self.CraftingOutputLog:Close();
    FrameUtil.UnregisterFrameForEvents(self, ProfessionsCrafterOrderViewEvents);
    self:SetScript("OnUpdate", nil);
    EventRegistry:UnregisterCallback("Professions.AllocationUpdated", self);
    EventRegistry:UnregisterCallback("Professions.TransactionUpdated", self);
    self:SetOverrideCastBarActive(false);
	self:CloseGenericConfirmation();
end

function ProfessionsCrafterOrderViewMixin:OnUpdate()
    local orderState = self.order.orderState;

    if orderState == Enum.CraftingOrderState.Claimed then
        self:UpdateClaimEndTime();
    end
end

function ProfessionsCrafterOrderViewMixin:UpdateClaimEndTime()
    local timeRemaining = Professions.GetCraftingOrderRemainingTime(self.order.claimEndTime);
    self.OrderInfo.TimeRemainingValue:SetText(Professions.OrderTimeLeftFormatter:Format(timeRemaining));
end

function ProfessionsCrafterOrderViewMixin:CloseOrder()
    self:GetParent():CloseOrder();
end

function ProfessionsCrafterOrderViewMixin:CancelAsyncLoads()
    if self.asyncContainers then
		for _, container in ipairs(self.asyncContainers) do
			container:Cancel();
		end
	end
	self.asyncContainers = {};
end

function ProfessionsCrafterOrderViewMixin:SchematicPostInit()
	self:CancelAsyncLoads();

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
				self.reagentSlotProvidedByCustomer[slotIndex] = true;
				reagentSlotToItemID[slotIndex] = modification.itemID;
            end
        end
    
        for slotIndex, reagentSlotSchematic in ipairs(self.OrderDetails.SchematicForm.recipeSchematic.reagentSlotSchematics) do
            if reagentSlotSchematic.dataSlotType == Enum.TradeskillSlotDataType.ModifiedReagent then
                AllocateModification(slotIndex, reagentSlotSchematic);
            end
        end
    end

	-- Don't re-use reagents for subsequent recrafts. When viewing the form after creating the item once,
	-- the full reagent information will come from the modifications above, because we'll be looking at the
	-- actual item.
    if not self.order.isFulfillable then
        for _, reagentInfo in ipairs(self.order.reagents) do
            local allocations = transaction:GetAllocations(reagentInfo.slotIndex);

			-- isBasicReagent check here to handle multiple allocations within the same slot (qualities)
            if not self.reagentSlotProvidedByCustomer[reagentInfo.slotIndex] or not reagentInfo.isBasicReagent then
                allocations:Clear();
                self.reagentSlotProvidedByCustomer[reagentInfo.slotIndex] = true;
            end
            -- These allocations get cleared before sending the craft, but we allocate them for craft readiness validation
            allocations:Allocate(reagentInfo.reagent, reagentInfo.reagent.quantity);
            reagentSlotToItemID[reagentInfo.slotIndex] = reagentInfo.reagent.itemID;
        end
    end

	if self:IsRecrafting() then
		-- After the allocations above, strip any reagents that fail to meet prerequisites. This is a workaround for
		-- incompatible reagents being part of the original order data because it is not removed until the item is
		-- actually recreated. Since the crafter cannot modify this slot anyways, it's empty state will be the only
		-- correct state.
		for slotIndex, reagentSlotSchematic in ipairs(self.OrderDetails.SchematicForm.recipeSchematic.reagentSlotSchematics) do
            if reagentSlotSchematic.dataSlotType == Enum.TradeskillSlotDataType.ModifiedReagent then
				-- Skip any slots where the existing modification was replaced by another customer provided slot.
				local allocs = transaction:GetAllocations(slotIndex);
				local alloc = allocs:SelectFirst();
				if alloc then
					local reagent = alloc:GetReagent();
					local itemID = reagent.itemID;
					if itemID and itemID > 0 and not transaction:AreAllRequirementsAllocatedByItemID(itemID) then
						transaction:ClearAllocations(slotIndex);
						transaction:ClearModification(reagentSlotSchematic.dataSlotIndex);
						self.reagentSlotProvidedByCustomer[slotIndex] = nil;
						reagentSlotToItemID[slotIndex] = nil;
					end
				end
            end
        end
	end

	-- Avoid using the reagentType index because the reagentSlots now contain
	-- multiple different reagent types (i.e. modifying-required + basic)
    for _, slots in pairs(self.OrderDetails.SchematicForm.reagentSlots) do
        for _, slot in ipairs(slots) do
			local reagentType = slot:GetReagentType();
			local reagentSlotSchematic = slot:GetReagentSlotSchematic();
            local providedByCustomer = self.reagentSlotProvidedByCustomer[slot:GetSlotIndex()];
            if providedByCustomer then
                slot:SetUnallocatable(true);
                slot:SetOverrideNameColor(HIGHLIGHT_FONT_COLOR);
				slot:SetShowOnlyRequired(true);

				if reagentSlotSchematic.required then
					slot:SetCheckmarkShown(true);
					slot:SetCheckmarkTooltipText(PROFESSIONS_CUSTOMER_ORDER_REAGENT_PROVIDED);
					slot:SetCheckmarkAtlas("Professions-Icon-Customer");
				end
			else
				if reagentSlotSchematic.required then
					slot:SetCheckmarkShown(true);
					slot:SetCheckmarkTooltipText(PROFESSIONS_CUSTOMER_ORDER_REAGENT_NOTPROVIDED);
					slot:SetCheckmarkAtlas("Professions-Icon-Crafter");
				end
			end

            if self.order.orderState == Enum.CraftingOrderState.Created then
                slot:SetUnallocatable(true);
                slot:SetAddIconDesaturated(true);
            end

            if reagentType == Enum.CraftingReagentType.Modifying then
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
					table.insert(self.asyncContainers, continuableContainer);

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
        self.OrderDetails.SchematicForm.recraftSlot:Init(transaction, function() return false; end, nop, self.order.outputItemHyperlink or self.order.recraftItemHyperlink);
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

    self.OrderDetails.SchematicForm:UpdateDetailsStats();
    self:UpdateCreateButton();
end

function ProfessionsCrafterOrderViewMixin:UpdateMinimumQualityIcon()
	-- NOTE: FulfillmentForm check must be IsShown() since IsVisible() will not toggle until the frame after the form gets shown
	local showMinimumQuality = self.order.minQuality > 1 and not self.OrderDetails.FulfillmentForm:IsShown();
    self.OrderDetails.MinimumQualityIcon:SetShown(showMinimumQuality);
    if showMinimumQuality then
        local small = true;
        self.OrderDetails.MinimumQualityIcon:SetAtlas(Professions.GetIconForQuality(self.order.minQuality, small), TextureKitConstants.UseAtlasSize);
        self.OrderDetails.MinimumQualityIcon:ClearAllPoints();
        local outputText = self:IsRecrafting() and self.OrderDetails.SchematicForm.RecraftingOutputText or self.OrderDetails.SchematicForm.OutputText;
        self.OrderDetails.MinimumQualityIcon:SetPoint("LEFT", outputText, "RIGHT", 5, 0);
    end
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
        errorReason = PROFESSIONS_CRAFTER_OUT_OF_CLAIMS_FMT:format(SecondsToTime(claimInfo.secondsToRecharge));
    elseif not recipeInfo or not recipeInfo.learned or (self.order.isRecraft and not C_CraftingOrders.OrderCanBeRecrafted(self.order.orderID)) then
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

local npcOrderCreateButtonHelpTipInfo =
{
	text = CRAFTING_ORDERS_FIRST_NPC_ORDER_HELPTIP,
	buttonStyle = HelpTip.ButtonStyle.Close,
	targetPoint = HelpTip.Point.BottomEdgeCenter,
	alignment = HelpTip.Alignment.Center,
	offsetX = 0,
	cvarBitfield = "closedInfoFramesAccountWide",
	bitfieldFlag = LE_FRAME_TUTORIAL_ACCOUNT_NPC_CRAFTING_ORDER_CREATE_BUTTON,
	checkCVars = true,
};

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
    elseif not transaction:HasMetAllRequirements() then
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

	if self.order.orderType == Enum.CraftingOrderType.Npc then
		HelpTip:Show(self.CreateButton, npcOrderCreateButtonHelpTipInfo);
	end
end

function ProfessionsCrafterOrderViewMixin:UpdateRewards(order)
	for i, reward in ipairs(order.npcOrderRewards) do
		if i <= #self.OrderInfo.NPCRewardsFrame.RewardItems then
			self.OrderInfo.NPCRewardsFrame.RewardItems[i]:SetReward(reward);
		end
	end
	for i = #order.npcOrderRewards + 1, #self.OrderInfo.NPCRewardsFrame.RewardItems do
		self.OrderInfo.NPCRewardsFrame.RewardItems[i]:Hide();
	end
	self.OrderInfo.NPCRewardsFrame:SetShown(#order.npcOrderRewards > 0);

	assertsafe(
		#order.npcOrderRewards <= #self.OrderInfo.NPCRewardsFrame.RewardItems,
		"Too many rewards (%d rewards > %d supported in UI) in NPC Crafting Order Set ID %d Treasure ID %d",
		#order.npcOrderRewards,
		#self.OrderInfo.NPCRewardsFrame.RewardItems,
		order.npcCraftingOrderSetID, 
		order.npcTreasureID
	);
end

function ProfessionsCrafterOrderViewMixin:SetOrder(order)
    self.order = order;

    self.OrderInfo.PostedByValue:SetText(order.customerName);
    self.OrderInfo.NoteBox.NoteText:SetText(order.customerNotes);
	self.OrderInfo.NoteBox:SetShown(not C_CraftingOrders.AreOrderNotesDisabled());
	local showDisabledNoteBox = order.orderType == Enum.CraftingOrderType.Npc;
	self.OrderInfo.NoteBox.NoteTitle:SetFontObject(showDisabledNoteBox and GameFontDisable or GameFontNormal);
	self.OrderInfo.NoteBox:SetAlpha(showDisabledNoteBox and 0.5 or 1.0);
    self.OrderInfo.CommissionTitleMoneyDisplayFrame:SetAmount(order.tipAmount);
    self.OrderInfo.ConsortiumCutMoneyDisplayFrame:SetAmount(order.consortiumCut);
    self.OrderInfo.FinalTipMoneyDisplayFrame:SetAmount(order.tipAmount - order.consortiumCut);

	self:UpdateRewards(order);

	local warningText, atlas;
	if self.order.reagentState == Enum.CraftingOrderReagentsType.All then
		warningText = PROFESSIONS_CUSTOMER_ORDER_REAGENTS_ALL;
		atlas = "Professions-Icon-Customer";
	elseif self.order.reagentState == Enum.CraftingOrderReagentsType.Some then
		warningText = PROFESSIONS_CUSTOMER_ORDER_REAGENTS_SOME;
		atlas = "Professions_Icon_Warning";
	elseif self.order.reagentState == Enum.CraftingOrderReagentsType.None then
		warningText = PROFESSIONS_CUSTOMER_ORDER_REAGENTS_NONE;
		atlas = "Professions_Icon_Warning";
	end
	self.OrderInfo.OrderReagentsWarning.Icon:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
	self.OrderInfo.OrderReagentsWarning.Text:SetText(warningText);
	local warningWidth = self.OrderInfo.OrderReagentsWarning.Text:GetStringWidth();
	self.OrderInfo.OrderReagentsWarning.Text:SetWidth(math.min(warningWidth, 220));

    self.OrderDetails.FulfillmentForm.NoteEditBox.ScrollingEditBox:SetText("");
	self.OrderDetails.FulfillmentForm.NoteEditBox:SetShown(not C_CraftingOrders.AreOrderNotesDisabled());
	self.DeclineOrderDialog.NoteEditBox:SetShown(not C_CraftingOrders.AreOrderNotesDisabled());

    local isRecraft = self:IsRecrafting();
	local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(self.order.spellID, isRecraft);
    self.OrderDetails.SchematicForm.transaction = CreateProfessionsRecipeTransaction(recipeSchematic);
    self.OrderDetails.SchematicForm.transaction:SetUseCharacterInventoryOnly(true);
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

	self:SetWhisperCustomerStatus(Enum.ChatWhisperTargetStatus.Offline);
	if order.customerGuid then
		C_ChatInfo.RequestCanLocalWhisperTarget(order.customerGuid);
	end

	self.ConcentrationDisplay:ShowProfessionConcentration(Professions.GetProfessionInfo());
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
    local showSocialDropdown = self.order.customerGuid and self.order.customerGuid ~= UnitGUID("player");

    if orderState == Enum.CraftingOrderState.Created then
        showBackButton = true;
        showStartOrderButton = true;
        showSchematic = true;
        showDeclineOrderButton = self.order.orderType == Enum.CraftingOrderType.Personal;
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
    self.OrderInfo.SocialDropdown:SetShown(showSocialDropdown);
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
    local yOfs = showDeclineOrderButton and 8 or 55;
    self.OrderInfo.StartOrderButton:SetPoint("BOTTOM", self.OrderInfo, "BOTTOM", xOfs, yOfs);

	-- Sits above StartOrderButton with a fixed x position because the x position of the StartOrderButton
	-- changes between private and public order.
	self.OrderInfo.OrderReagentsWarning:ClearAllPoints();
	self.OrderInfo.OrderReagentsWarning:SetPoint("BOTTOMLEFT", self.OrderInfo, "BOTTOMLEFT", 20, yOfs + 35);

	self:UpdateMinimumQualityIcon();
end

function ProfessionsCrafterOrderViewMixin:CraftOrder()
    self:SetOverrideCastBarActive(true);
    local recipeID = self.order.spellID;
    local count = 1;
    local predicate = function(reagentTbl, slotIndex)
		return reagentTbl.reagentSlotSchematic.dataSlotType == Enum.TradeskillSlotDataType.ModifiedReagent and not self.reagentSlotProvidedByCustomer[slotIndex];
	end
	local transaction = self.OrderDetails.SchematicForm.transaction;
    local craftingReagentTbl = transaction:CreateCraftingReagentInfoTblIf(predicate);
    local recipeLevel = self.OrderDetails.SchematicForm:GetCurrentRecipeLevel();
	local applyConcentration = transaction:IsApplyingConcentration();
    C_TradeSkillUI.CraftRecipe(recipeID, count, craftingReagentTbl, recipeLevel, self.order.orderID, applyConcentration);
end

function ProfessionsCrafterOrderViewMixin:RecraftOrder()
    self:SetOverrideCastBarActive(true);
    local predicate = function(reagentTbl, slotIndex)
		return reagentTbl.reagentSlotSchematic.dataSlotType == Enum.TradeskillSlotDataType.ModifiedReagent and not self.reagentSlotProvidedByCustomer[slotIndex];
	end

	local transaction = self.OrderDetails.SchematicForm.transaction;
    local craftingReagentTbl = transaction:CreateCraftingReagentInfoTblIf(predicate);
	
	-- Not passing any removed modifications since the server resolves this when handling overrides or
	-- swapping between prerequisite reagents of different seasons. If we do need to pass these, the
	-- implementation in PrepareRecipeRecraft won't be applicable anyways since we aren't accounting
	-- for unmodified reagent slots.
	Professions.PrepareRecipeRecraft(transaction, craftingReagentTbl);

	local removedModificationsNone = nil;
	local applyConcentration = transaction:IsApplyingConcentration();
    C_TradeSkillUI.RecraftRecipeForOrder(self.order.orderID, self.order.outputItemGUID, craftingReagentTbl, removedModificationsNone, applyConcentration);
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

function ProfessionsCrafterOrderViewMixin:GetWhisperCustomerStatus()
	return self.whisperCustomerStatus;
end

function ProfessionsCrafterOrderViewMixin:SetWhisperCustomerStatus(status)
	self.whisperCustomerStatus = status;
end