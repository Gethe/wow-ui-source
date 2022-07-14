local orderDurationFormatter = CreateFromMixins(SecondsFormatterMixin);
orderDurationFormatter:Init(
	SecondsFormatterConstants.ZeroApproximationThreshold, 
	SecondsFormatter.Abbreviation.Truncate, 
	SecondsFormatterConstants.DontRoundUpLastUnit, 
	SecondsFormatterConstants.DontConvertToLower);
orderDurationFormatter:SetDesiredUnitCount(2);

local LayoutEntry = EnumUtil.MakeEnum("Tools", "Cooldown", "Description", "NextRank", "Source", "Reagents");

ProfessionsCrafterOrderFormMixin = {};

local ProfessionsCrafterOrderFormEvents =
{
	"TRADE_SKILL_ITEM_CRAFTED_RESULT",
};

function ProfessionsCrafterOrderFormMixin:OnLoad()
	self.CustomerDetails.BackButton:SetText(PROFESSIONS_CRAFTING_FORM_BACK);
	
	self.CustomerDetails.CancelOrderButton:SetTextToFit(PROFESSIONS_CRAFTING_FORM_CANCEL_ORDER);
	self.CustomerDetails.CancelOrderButton:SetScript("OnClick", GenerateClosure(self.CancelOrder, self));

	self.CustomerDetails.DeclineOrderButton:SetTextToFit(PROFESSIONS_CRAFTING_FORM_DECLINE_ORDER);
	self.CustomerDetails.DeclineOrderButton:SetScript("OnClick", GenerateClosure(self.DeclineOrder, self));

	self.CustomerDetails.Note:SetText(PROFESSIONS_CRAFTING_FORM_NOTE_TO_CRAFTER);

	self.CustomerDetails.Tip:SetText(PROFESSIONS_CRAFTING_FORM_TIP);
	self.CustomerDetails.Tip:SetWidth(self.CustomerDetails.Tip:GetStringWidth());

	self.StartOrderButton:SetTextToFit(PROFESSIONS_CRAFTING_FORM_START_ORDER);
	self.StartOrderButton:SetScript("OnClick", GenerateClosure(self.StartOrder, self));

	self.CreateOrderButton:SetTextToFit(PROFESSIONS_CRAFTING_FORM_CREATE_ORDER);
	self.CreateOrderButton:SetScript("OnClick", GenerateClosure(self.CreateOrder, self));
	
	local function OnUseBestQualityModified(o, checked)
		self:AllocateUnprovidedBasicReagents();
		self:SetupCraftingButtons();
	end

	self.SchematicForm:RegisterCallback(ProfessionsRecipeSchematicFormMixin.Event.UseBestQualityModified, OnUseBestQualityModified, self);
end

function ProfessionsCrafterOrderFormMixin:OnEvent(event, ...)
	if event == "TRADE_SKILL_ITEM_CRAFTED_RESULT" then
		if self.order then
			self:DisplayOutput();
		end
	end
end

function ProfessionsCrafterOrderFormMixin:OnUpdate()
	if self.order and self.order:IsStatus(Enum.TradeskillOrderStatus.Started) then
		self:UpdateOrderDuration();
	end
end

function ProfessionsCrafterOrderFormMixin:OnShow()
    FrameUtil.RegisterFrameForEvents(self, ProfessionsCrafterOrderFormEvents);

	local function OnOrderStarted(o, order)
		print("ProfessionsCrafterOrderFormMixin OnOrderStarted", order.id);
		self.StartOrderButton:Hide();
		self.CustomerDetails.DeclineOrderButton:Hide();
		self.CustomerDetails.BackButton:Hide();

		self.CustomerDetails.Duration:Show();
		self.CustomerDetails.CancelOrderButton:Show();
		self.CustomerDetails.CancelOrderButton:Enable();
		self.CreateOrderButton:Show();
		self.CreateOrderButton:Enable();

		self:EvaluateSlots();
	end
	EventRegistry:RegisterCallback("Professions.OrderStarted", OnOrderStarted, self);

	local function OnOrderCompleted(o, order)
		print("ProfessionsCrafterOrderFormMixin OnOrderCompleted", order.id);
		self.CustomerDetails.BackButton:Show();
		self:SetAllSlotsUnallocatable();
	end
	EventRegistry:RegisterCallback("Professions.OrderCompleted", OnOrderCompleted, self);

	local function OnOrderExpired(o, order)
		print("ProfessionsCrafterOrderFormMixin OnOrderExpired", order.id);
		self:EvaluateButtonStates();
		self:SetAllSlotsUnallocatable();
	end
	EventRegistry:RegisterCallback("Professions.OrderExpired", OnOrderExpired, self);
end

function ProfessionsCrafterOrderFormMixin:OnHide()
    FrameUtil.UnregisterFrameForEvents(self, ProfessionsCrafterOrderFormEvents);

	if self.order then
		if self.order.attempted and not self.order:IsStatus(Enum.TradeskillOrderStatus.Completed) then
			C_TradeSkillUI.CompleteCraftingOrder(self.order);
		end
	end

	self.CraftingOutputDialog:Hide();

	self.order = nil;
end

function ProfessionsCrafterOrderFormMixin:UpdateOrderDuration()
	local remaining = self.order:GetSecondsUntilExpiration();
	local duration = PROFESSIONS_CRAFTING_FORM_CRAFTER_DURATION_REMAINING:format(orderDurationFormatter:Format(remaining));
	self.CustomerDetails.Duration:SetText(duration);
end

function ProfessionsCrafterOrderFormMixin:EvaluateButtonStates()
	if not self.order then
		return;
	end

	self.StartOrderButton:Hide();
	self.CreateOrderButton:Hide();
	self.CustomerDetails.BackButton:Hide();
	self.CustomerDetails.Duration:Hide();
	self.CustomerDetails.DeclineOrderButton:Hide();
	self.CustomerDetails.CancelOrderButton:Hide();

	if self.order.status == Enum.TradeskillOrderStatus.Unclaimed then
		self.CustomerDetails.BackButton:Show();

		self.StartOrderButton:Show();
		self:SetupCraftingButtons();

		if self.order.recipient == Enum.TradeskillOrderRecipient.Private then
			self.CustomerDetails.DeclineOrderButton:Show();
			self.CustomerDetails.DeclineOrderButton:Enable();
		end
	elseif self.order.status == Enum.TradeskillOrderStatus.Started then
		self.CreateOrderButton:Show();
		self.CreateOrderButton:Enable();

		self.CustomerDetails.Duration:Show();

		self.CustomerDetails.CancelOrderButton:Show();
		self.CustomerDetails.CancelOrderButton:Enable();
	elseif self.order.status == Enum.TradeskillOrderStatus.Completed then
		self.CreateOrderButton:Show();
		self.CreateOrderButton:SetEnabled(false);
	elseif self.order.status == Enum.TradeskillOrderStatus.Expired then
		self.CustomerDetails.BackButton:Show();
	end
end

function ProfessionsCrafterOrderFormMixin:SetAllSlotsUnallocatable()
	for index, slot in ipairs(self.SchematicForm:GetSlots()) do
		slot:SetUnallocatable(true);
	end
end

function ProfessionsCrafterOrderFormMixin:EvaluateSlots()
	if self.order then
		if self.order:IsStatus(Enum.TradeskillOrderStatus.Started) and not self.order.attempted then
			for index, slot in ipairs(self.SchematicForm:GetSlots()) do
				local slotIndex = slot:GetSlotIndex();
				local providedByCustomer = self.customerProvidedSlotIndices[slotIndex] ~= nil;
				slot:SetUnallocatable(providedByCustomer);
			end
		else
			self:SetAllSlotsUnallocatable();
		end
	end
end

function ProfessionsCrafterOrderFormMixin:AllocateUnprovidedBasicReagents()
	local transaction = self.order.transaction;
	local best = Professions.ShouldAllocateBestQualityReagents();
	for slotIndex, reagentTbl in self.order.transaction:Enumerate() do
		local allocations = reagentTbl.allocations;
		if not allocations.customer then
			Professions.AllocateBasicReagents(transaction, slotIndex, best);
		end
	end
end

function ProfessionsCrafterOrderFormMixin:Init(order)
	self.order = order;

	local transaction = order.transaction;
	local recipeSchematic = transaction:GetRecipeSchematic();
	local recipeID = transaction:GetRecipeID();
	local recipeInfo = C_TradeSkillUI.GetRecipeInfo(recipeID);
	
	self.CustomerDetails.Name:SetText(PROFESSIONS_CRAFTING_FORM_POSTED_BY:format(order.customer));

	local durationText = Professions.GetOrderDurationText(order.duration);
	self.CustomerDetails.Expiration:SetText(PROFESSIONS_CRAFTING_FORM_LISTING_DURATION:format(durationText));

	local editBox = self.CustomerDetails.ScrollBoxContainer.ScrollingEditBox;
	editBox:SetDefaultTextEnabled(false);
	editBox:SetText(order.message);
	editBox:SetEnabled(false);

	self.CustomerDetails.TipMoneyDisplayFrame:SetAmount(order.tip);

	self.customerProvidedSlotIndices = {};

	for slotIndex, reagentTbl in transaction:Enumerate() do
		local allocations = reagentTbl.allocations;
		if allocations.customer then
			self.customerProvidedSlotIndices[slotIndex] = true;
		end
	end

	self:AllocateUnprovidedBasicReagents();
	
	self.SchematicForm:Init(recipeInfo, transaction);

	for _, slot in ipairs(self.SchematicForm:GetSlotsByReagentType(Enum.CraftingReagentType.Basic)) do
		local slotIndex = slot:GetSlotIndex();
		if self.customerProvidedSlotIndices[slotIndex] then
			slot.CustomerState:SetShown(true);
		end
	end

	local atlasSize = 25;
	local atlasMarkup = CreateAtlasMarkup(Professions.GetIconForQuality(order.quality), atlasSize, atlasSize);
	self.SchematicForm:SetOutputSubText(PROFESSIONS_CRAFTING_FORM_MIN_REQUIRED_QUALITY:format(atlasMarkup));

	self:EvaluateSlots();
	self:EvaluateButtonStates();
end

function ProfessionsCrafterOrderFormMixin:StartOrder()
	self.StartOrderButton:Disable();

	C_TradeSkillUI.StartCraftingOrder(self.order);
end

function ProfessionsCrafterOrderFormMixin:CreateOrder()
	self.CreateOrderButton:Disable();
	self.CustomerDetails.CancelOrderButton:Disable();

	if not self.order:HasExpired() then
		self.order.attempted = true;

		local transaction = self.order.transaction;
		local count = 1;
		C_TradeSkillUI.CraftRecipe(transaction:GetRecipeID(), count, transaction:CreateCraftingReagentInfoTbl());
	end

	self:SetAllSlotsUnallocatable();
end

function ProfessionsCrafterOrderFormMixin:CancelOrder()
	C_TradeSkillUI.CancelCraftingOrder(self.order);
end

function ProfessionsCrafterOrderFormMixin:DeclineOrder()
	C_TradeSkillUI.DeclineCraftingOrder(self.order);
end

function ProfessionsCrafterOrderFormMixin:SetupCraftingButtons()
	self.StartOrderButton:Enable();
end

function ProfessionsCrafterOrderFormMixin:DisplayOutput()
	local function OnDialogRecraft(dialog)
		print("ProfessionsCrafterOrderFormMixin OnOrderRecraft");
		self.order.attempted = nil;

		self:EvaluateButtonStates();
		self:EvaluateSlots();
	end

	self.CraftingOutputDialog:RegisterCallback(ProfessionsCraftingOutputDialogMixin.Event.OrderRecraft, OnDialogRecraft, self);

	local function OnDialogFinalized(dialog, message)
		print("ProfessionsCrafterOrderFormMixin OnDialogFinalized");
		C_TradeSkillUI.CompleteCraftingOrder(self.order, message);
	end

	self.CraftingOutputDialog:RegisterCallback(ProfessionsCraftingOutputDialogMixin.Event.OrderFinalized, OnDialogFinalized, self);
	
	-- FIXME Actual quality requires real result.
	self.CraftingOutputDialog:Open(self.order.transaction, self.order.quality);
end