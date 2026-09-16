ProfessionsEnchantSlotMixin = CreateFromMixins(ProfessionsRecipeSlotBaseMixin);

function ProfessionsEnchantSlotMixin:Init(transaction)
	ProfessionsRecipeSlotBaseMixin.Init(self);

	self:ClearReagent();

	self:SetNameText(PROFESSIONS_ADD_ENCHANT);

	self:Update();
	
	local function OnItemsLoaded()
		local item = transaction:GetEnchantAllocation();
		if item then
			self:SetItem(item);
		end

		self:Update();
	end
	
	self.continuableContainer:ContinueOnLoad(OnItemsLoaded);

	self.Button:SetScript("OnLeave", GameTooltip_Hide);
end

function ProfessionsEnchantSlotMixin:Update()
	self:UpdateAllocationText();

	self.Button.InputOverlay.AddIcon:SetShown(self.allocationItem == nil);
end

function ProfessionsEnchantSlotMixin:SetQuantityAvailableCallback(callback)
	self.quantityAvailableCallback = callback;
end

function ProfessionsEnchantSlotMixin:UpdateAllocationText()
	if self.allocationItem then
		-- We're combining item IDs for enchant targets to support create-multiple for
		-- vellums, so we actually want the total inventory count here. 
		local count = ItemUtil.GetCraftingReagentCount(self.allocationItem:GetItemID());
		local itemName = self.allocationItem:GetItemName();
		self:SetNameText(("%s %s"):format(
			TRADESKILL_REAGENT_COUNT:format(count, 1), 
			itemName));
	end
end

function ProfessionsEnchantSlotMixin:SetNameText(text)
	self.Name:SetText(text);
end

function ProfessionsEnchantSlotMixin:SetUnallocatable(unallocatable)
	self.unallocatable = unallocatable;
end

function ProfessionsEnchantSlotMixin:IsUnallocatable()
	return self.unallocatable;
end

function ProfessionsEnchantSlotMixin:ClearReagent()
	self.allocationItem = nil;

	self.Button:Clear();

	self:SetNameText(PROFESSIONS_ADD_ENCHANT);

	self:Update();
end

function ProfessionsEnchantSlotMixin:SetItem(item)
	self.allocationItem = item;

	self.Button:SetItem(item:GetItemID());
	self.Name:SetText(item:GetItemName());

	self:Update();
end
