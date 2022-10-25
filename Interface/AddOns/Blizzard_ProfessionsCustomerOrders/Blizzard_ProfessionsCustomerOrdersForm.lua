local ProfessionsCustomerOrderFormEvents =
{
    "UNIT_INVENTORY_CHANGED",
};

ProfessionsCustomerOrderFormMixin = {};

function ProfessionsCustomerOrderFormMixin:OnLoad()
	local function PoolReset(pool, slot)
		slot:Reset();
		slot.Button:SetScript("OnEnter", nil);
		slot.Button:SetScript("OnClick", nil);
		slot.Button:SetScript("OnMouseDown", nil);
		FramePool_HideAndClearAnchors(pool, slot);
	end

	self.reagentSlotPool = CreateFramePool("FRAME", self, "ProfessionsReagentSlotTemplate", PoolReset);

	self.BackButton:SetText(PROFESSIONS_CRAFTING_FORM_BACK);

	self.ReagentContainer.Header:SetText(PROFESSIONS_CRAFTING_FORM_PROVIDE_REAGENTS);

	-- Commented out pending design discussion
	--self.ReagentContainer.AllocateBestQualityCheckBox.text:SetText(PROFESSIONS_USE_BEST_QUALITY_REAGENTS);
	--self.ReagentContainer.AllocateBestQualityCheckBox:SetScript("OnClick", function(button, buttonName, down)
	--	local checked = button:GetChecked();
	--	Professions.SetShouldAllocateBestQualityReagents(checked);
	--	Professions.AllocateAllBasicReagents(self.order.transaction, checked);
	--
	--	for slot in self.reagentSlotPool:EnumerateActive() do
	--		slot:Update();
	--	end
	--end);

	self.PaymentContainer.Header:SetText(PROFESSIONS_CRAFTING_FORM_NOTE);
	
	local scrollBox = self.PaymentContainer.ScrollBoxContainer.ScrollingEditBox:GetScrollBox();
	local scrollBar = self.PaymentContainer.ScrollBoxContainer.ScrollBar;
	ScrollUtil.RegisterScrollBoxWithScrollBar(scrollBox, scrollBar);
	
	self.PaymentContainer.Tip:SetText(PROFESSIONS_CRAFTING_FORM_TIP);
	self.PaymentContainer.Tip:SetWidth(self.PaymentContainer.Tip:GetStringWidth());
	self.PaymentContainer.TipMoneyInputFrame:SetOnValueChangedCallback(GenerateClosure(self.UpdateTotalPrice, self));

	self.PaymentContainer.RecommendedTip:SetText(PROFESSIONS_CRAFTING_FORM_RECOMMENDED_TIP);
	self.PaymentContainer.RecommendedTip:SetWidth(self.PaymentContainer.RecommendedTip:GetStringWidth());

	self.PaymentContainer.PostingFee:SetText(PROFESSIONS_CRAFTING_FORM_POSTING_FEE);
	self.PaymentContainer.PostingFee:SetWidth(self.PaymentContainer.PostingFee:GetStringWidth());

	self.PaymentContainer.TotalPrice:SetText(PROFESSIONS_CRAFTING_FORM_TOTAL_PRICE);
	self.PaymentContainer.TotalPrice:SetWidth(self.PaymentContainer.TotalPrice:GetStringWidth());
	
	self.PaymentContainer.ListOrderButton:SetText(PROFESSIONS_CRAFTING_FORM_LIST_ORDER);
	self.PaymentContainer.ListOrderButton:SetScript("OnClick", function()
		self:ListOrder();
		self:Hide();
	end);
end

function ProfessionsCustomerOrderFormMixin:OnShow()
    FrameUtil.RegisterFrameForEvents(self, ProfessionsCustomerOrderFormEvents);
end

function ProfessionsCustomerOrderFormMixin:OnHide()
    FrameUtil.UnregisterFrameForEvents(self, ProfessionsCustomerOrderFormEvents);
end

function ProfessionsCustomerOrderFormMixin:OnEvent(event, ...)
	if event == "UNIT_INVENTORY_CHANGED" then
		-- Need to update the reagent counts and list order button states
		print("ProfessionsCustomerOrderFormMixin", event);
	end
end

function ProfessionsCustomerOrderFormMixin:SetupQualityDropDown()
	local function Initializer(dropDown, level)
		local function DropDownButtonClick(button)
			self:SetMinimumQuality(button.value);
		end
		
		for index = 1, 5 do
			local info = UIDropDownMenu_CreateInfo();
			info.fontObject = Number12Font;
			info.text = ("Quality %d"):format(index);
			info.minWidth = 108;
			info.value = index;
			info.checked = nil;
			info.func = DropDownButtonClick;
			UIDropDownMenu_AddButton(info);
		end
	end

	UIDropDownMenu_Initialize(self.MinimumQualityDropDown, Initializer);
	UIDropDownMenu_SetSelectedValue(self.MinimumQualityDropDown, self.order.quality);
end

function ProfessionsCustomerOrderFormMixin:SetupOrderRecipientDropDown()
	self.OrderRecipient:SetText(PROFESSIONS_CRAFTING_FORM_ORDER_RECIPIENT);
	self.OrderRecipient:SetWidth(self.OrderRecipient:GetStringWidth());

	local function Initializer(dropDown, level)
		local function DropDownButtonClick(button)
			self:SetOrderRecipient(button.value);
		end
	
		local ORDER_RECIPIENT_TEXTS = {
			PROFESSIONS_CRAFTING_FORM_ORDER_RECIPIENT_PUBLIC,
			PROFESSIONS_CRAFTING_FORM_ORDER_RECIPIENT_GUILD,
			PROFESSIONS_CRAFTING_FORM_ORDER_RECIPIENT_PRIVATE,
		};

		for index, text in ipairs(ORDER_RECIPIENT_TEXTS) do
			local info = UIDropDownMenu_CreateInfo();
			info.fontObject = Number12Font;
			info.text = text;
			info.minWidth = 108;
			info.value = index;
			info.checked = nil;
			info.func = DropDownButtonClick;
			UIDropDownMenu_AddButton(info);
		end
	end

	UIDropDownMenu_Initialize(self.OrderRecipientDropDown, Initializer);
	UIDropDownMenu_SetSelectedValue(self.OrderRecipientDropDown, self.order.recipient);

	self:UpdateMinimumQuality();
end

function ProfessionsCustomerOrderFormMixin:SetupDurationDropDown()
	self.PaymentContainer.Duration:SetText(PROFESSIONS_CRAFTING_FORM_CUSTOMER_DURATION);
	self.PaymentContainer.Duration:SetWidth(self.PaymentContainer.Duration:GetStringWidth());

	local function Initializer(dropDown, level)
		local function DropDownButtonClick(button)
			self:SetDuration(button.value);
		end
		
		for index = 1, 3 do
			local info = UIDropDownMenu_CreateInfo();
			info.fontObject = Number12Font;
			info.text = Professions.GetOrderDurationText(index);
			info.minWidth = 108;
			info.value = index;
			info.checked = nil;
			info.func = DropDownButtonClick;
			UIDropDownMenu_AddButton(info);
		end
	end

	UIDropDownMenu_Initialize(self.PaymentContainer.DurationDropDown, Initializer);
	UIDropDownMenu_SetSelectedValue(self.PaymentContainer.DurationDropDown, self.order.duration);
end

function ProfessionsCustomerOrderFormMixin:UpdateMinimumQuality()
	self.MinimumQuality:SetWidth(250);

	if self.order.recipient == Enum.TradeskillOrderRecipient.Public then
		self.MinimumQuality:SetText(PROFESSIONS_CRAFTING_FORM_MIN_QUALITY_ANY);
		self.MinimumQualityDropDown:Hide();

		self.order.quality = 1;

		-- Dropdown cannot be set in another dropdown handler unless it is reinitialized to seed the 
		-- available values.
		self:SetupQualityDropDown();
	else
		self.MinimumQuality:SetText(PROFESSIONS_CRAFTING_FORM_MIN_QUALITY);
		self.MinimumQuality:SetWidth(self.MinimumQuality:GetStringWidth());
		self.MinimumQualityDropDown:Show();
	end

	self.MinimumQuality:SetWidth(self.MinimumQuality:GetStringWidth());
end

function ProfessionsCustomerOrderFormMixin:SetDuration(index)
	self.order.duration = index;

	Professions.SetDefaultOrderDuration(index);

	UIDropDownMenu_SetSelectedValue(self.PaymentContainer.DurationDropDown, index);
end

function ProfessionsCustomerOrderFormMixin:SetOrderRecipient(index)
	self.order.recipient = index;

	Professions.SetDefaultOrderRecipient(index);

	UIDropDownMenu_SetSelectedValue(self.OrderRecipientDropDown, index);

	self:UpdateMinimumQuality();
end

function ProfessionsCustomerOrderFormMixin:SetMinimumQuality(index)
	self.order.quality = index;

	UIDropDownMenu_SetSelectedValue(self.MinimumQualityDropDown, index);
end

function ProfessionsCustomerOrderFormMixin:Init(order)
	self.order = order;
	local transaction = order.transaction;
	local recipeID = transaction:GetRecipeID();
	local recipeSchematic = transaction:GetRecipeSchematic();
	local committed = order.status ~= nil;
	
	if not committed then
		Professions.AllocateAllBasicReagents(transaction, Professions.ShouldAllocateBestQualityReagents());
	end
	
	if self.loader then
		self.loader:Cancel();
	end
	self.loader = CreateProfessionsRecipeLoader(recipeSchematic, function()
		local name = nil;
		local reagents = nil;
		local outputItemInfo = C_TradeSkillUI.GetRecipeOutputItemData(recipeID, reagents, transaction:GetAllocationItemGUID());
		if outputItemInfo.hyperlink then
			local item = Item:CreateFromItemLink(outputItemInfo.hyperlink);
			self.RecipeName:SetText(item:GetItemName());
			self.RecipeName:SetTextColor(item:GetItemQualityColorRGB());
		else
			self.RecipeName:SetText(self.recipeSchematic.name);
			self.RecipeName:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		end

		self.RecipeName:SetHeight(self.RecipeName:GetStringHeight());
		
		Professions.SetupOutputIcon(self.OutputIcon, transaction, outputItemInfo);
	end);
	
	self.OutputIcon:SetScript("OnEnter", function()
		GameTooltip:SetOwner(self.OutputIcon, "ANCHOR_RIGHT");

		local reagents = transaction:CreateOptionalCraftingReagentInfoTbl();
		self.OutputIcon:SetScript("OnUpdate", function() 
			C_TradeSkillUI.SetTooltipRecipeResultItem(recipeSchematic.recipeID, reagents, transaction:GetAllocationItemGUID());
		end);
	end);

	self.OutputIcon:SetScript("OnLeave", function()
		GameTooltip_Hide(); 
		self.OutputIcon:SetScript("OnUpdate", nil);
	end);

	local editBox = self.PaymentContainer.ScrollBoxContainer.ScrollingEditBox;
	editBox:SetDefaultTextEnabled(not committed);
	editBox:SetText(order.message);
	editBox:SetEnabled(not committed);

	self:SetupQualityDropDown();
	self:SetupOrderRecipientDropDown();
	self:SetupDurationDropDown();
	self:UpdateMinimumQuality();

	UIDropDownMenu_SetDropDownEnabled(self.PaymentContainer.DurationDropDown, not committed);
	UIDropDownMenu_SetDropDownEnabled(self.OrderRecipientDropDown, not committed);
	UIDropDownMenu_SetDropDownEnabled(self.MinimumQualityDropDown, not committed);

	self.reagentSlotPool:ReleaseAll();
	local reagentTypes = {};

	local slotParents =
	{
		[Enum.CraftingReagentType.Basic] = self.ReagentContainer.Reagents, 
		[Enum.CraftingReagentType.Optional] = self.ReagentContainer.OptionalReagents,
	};

	for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
		local reagentType = reagentSlotSchematic.reagentType;
		if reagentType ~= Enum.CraftingReagentType.Finishing then
			local slots = reagentTypes[reagentType];
			if not slots then
				slots = {};
				reagentTypes[reagentType] = slots;
			end

			local slot = self.reagentSlotPool:Acquire();
			table.insert(slots, slot);

			slot:SetParent(slotParents[reagentType]);

			slot:Init(transaction, reagentSlotSchematic);
			slot:Show();

			if reagentType == Enum.CraftingReagentType.Basic then
				slot:SetAllocateIconShown(true);

				if Professions.GetReagentInputMode(reagentSlotSchematic) == Professions.ReagentInputMode.Quality then
					slot.Button:SetScript("OnClick", function(button, buttonName, down)
						if IsShiftKeyDown() then
							local qualityIndex = Professions.FindFirstQualityAllocated(transaction, reagentSlotSchematic) or 1;
							local handled, link = Professions.HandleQualityReagentItemLink(recipeID, reagentSlotSchematic, qualityIndex);
							if not handled then
								Professions.TriggerReagentClickedEvent(link);
							end
							return;
						end

						if not slot:IsUnallocatable() then
							if buttonName == "LeftButton" then
								local function OnAllocationsAccepted(dialog, allocations, reagentSlotSchematic)
									transaction:OverwriteAllocations(reagentSlotSchematic.slotIndex, allocations);

									slot:Update();

									self:UpdateListOrderButton();
								end

								self.QualityDialog:RegisterCallback(ProfessionsQualityDialogMixin.Event.Accepted, OnAllocationsAccepted, slot);
								
								local allocationsCopy = transaction:GetAllocationsCopy(slotIndex);
								self.QualityDialog:Open(recipeID, reagentSlotSchematic, allocationsCopy, slotIndex);
							elseif buttonName == "RightButton" then
								transaction:ClearAllocations(slotIndex);

								slot.Button:UpdateCursor();
								slot:Update();
								
								self:UpdateListOrderButton();
							end
						end
					end);

					slot.Button:SetScript("OnEnter", function()
						GameTooltip:SetOwner(slot.Button, "ANCHOR_RIGHT");
						Professions.SetupQualityReagentTooltip(slot, transaction);
						GameTooltip:Show();
					end);
				else
					slot.Button:SetScript("OnClick", function(button, buttonName, down)
						if IsShiftKeyDown() then
							local handled, link = Professions.HandleFixedReagentItemLink(recipeID, reagentSlotSchematic);
							if not handled then
								Professions.TriggerReagentClickedEvent(link);
							end
							return;
						end

						if not slot:IsUnallocatable() then
							if buttonName == "LeftButton" then
								local best = Professions.ShouldAllocateBestQualityReagents();
								Professions.AllocateBasicReagents(transaction, slotIndex, best);
								
								slot:Update();

								self:UpdateListOrderButton();
							elseif buttonName == "RightButton" then
								transaction:ClearAllocations(slotIndex);

								slot.Button:UpdateCursor();
								slot:Update();

								self:UpdateListOrderButton();
							end
						end
					end);

					slot.Button:SetScript("OnEnter", function()
						GameTooltip:SetOwner(slot.Button, "ANCHOR_RIGHT");
						GameTooltip:SetRecipeReagentItem(recipeID, slotIndex);
						GameTooltip:Show();
					end);
				end
			else
				slot.Button:SetLocked(false);

				slot.Button:SetScript("OnEnter", function()
					GameTooltip:SetOwner(slot.Button, "ANCHOR_RIGHT");
					if committed then
						-- FIXME Tooltip required here for indicating no reagent was provided in the order.
						local title = (reagentType == Enum.CraftingReagentType.Finishing) and FINISHING_REAGENT_TOOLTIP_TITLE:format(reagentSlotSchematic.slotInfo.slotText) or EMPTY_OPTIONAL_REAGENT_TOOLTIP_TITLE;
						GameTooltip_SetTitle(GameTooltip, title);
					else
						Professions.SetupOptionalReagentTooltip(slot, recipeID, reagentType, reagentSlotSchematic.slotInfo.slotText, transaction:GetAllocationItemGUID());
					end
					GameTooltip:Show();
				end);
				
				slot.Button:SetScript("OnMouseDown", function(button, buttonName, down)
					if not slot:IsUnallocatable() then
						if buttonName == "LeftButton" then
							local flyout = ToggleProfessionsItemFlyout(slot.Button, ProfessionsCustomerOrdersFrame);
							if flyout then
								local function OnFlyoutItemSelected(o, flyout, item)
									local reagent = Professions.CreateCraftingReagentByItemID(item:GetItemID());
									transaction:OverwriteAllocation(slotIndex, reagent, reagentSlotSchematic.quantityRequired);

									slot:SetItem(item);
								end

								local itemIDs = Professions.ExtractItemIDsFromCraftingReagents(reagentSlotSchematic.reagents);
								flyout:Init(slot.Button, transaction, transaction:GetRecipeID(), itemIDs);
								flyout:RegisterCallback(ProfessionsItemFlyoutMixin.Event.ItemSelected, OnFlyoutItemSelected, slot);
							end
						elseif buttonName == "RightButton" then
							transaction:ClearAllocations(slotIndex);

							slot:ClearItem();
						end
					end
				end);
			end
		end
	end
	
	if committed then
		for slot in self.reagentSlotPool:EnumerateActive() do
			slot:SetUnallocatable(true);
		end
	end

	Professions.LayoutReagentSlots(
		reagentTypes[Enum.CraftingReagentType.Basic], self.ReagentContainer.Reagents,
		reagentTypes[Enum.CraftingReagentType.Optional], self.ReagentContainer.OptionalReagents,
		self.ReagentContainer.VerticalDivider);

	self.PaymentContainer.TipMoneyInputFrame:SetAmount(order.tip);
	self.PaymentContainer.TipMoneyInputFrame:SetEnabled(not committed);
	self.PaymentContainer.RecommendedTipMoneyDisplayFrame:SetAmount(order.recommendedTip);
	self.PaymentContainer.PostingFeeMoneyDisplayFrame:SetAmount(order.fee);
	
	self:UpdateTotalPrice();

	self:UpdateListOrderButton();
end

function ProfessionsCustomerOrderFormMixin:UpdateTotalPrice()
	local tip = self.PaymentContainer.TipMoneyInputFrame:GetAmount();
	local total = self.order.fee + tip;
	self.PaymentContainer.TotalPriceMoneyDisplayFrame:SetAmount(total);
end

function ProfessionsCustomerOrderFormMixin:UpdateListOrderButton()
	local listOrderButton = self.PaymentContainer.ListOrderButton;
	listOrderButton:SetShown(self.order.status == nil);
	
	-- Assuming for now the customer can provide nothing if they choose. When we understand what reagents
	-- are required, we can evaluate those in the transaction object.
	-- PROFESSIONS_INSUFFICIENT_REAGENTS
	local enabled = true;
	listOrderButton:SetEnabled(enabled);
end

function ProfessionsCustomerOrderFormMixin:ListOrder()
	assert(self.order.status == nil);
	self.order.message = self.PaymentContainer.ScrollBoxContainer.ScrollingEditBox:GetInputText();
	self.order.tip = self.PaymentContainer.TipMoneyInputFrame:GetAmount();
	self.order.duration = UIDropDownMenu_GetSelectedValue(self.PaymentContainer.DurationDropDown);
	self.order.recipient = UIDropDownMenu_GetSelectedValue(self.OrderRecipientDropDown);

	if self.order.recipient == Enum.TradeskillOrderRecipient.Public then
		self.order.quality = 1;
	else
		self.order.quality = UIDropDownMenu_GetSelectedValue(self.MinimumQualityDropDown);
	end

	for index, reagentTbl in self.order.transaction:Enumerate() do
		local allocations = reagentTbl.allocations;
		if allocations:HasAllocations() then
			if reagentTbl.reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Basic then
				allocations.customer = true;
			end
		end
	end

	C_TradeSkillUI.ListCraftingOrder(self.order);
end