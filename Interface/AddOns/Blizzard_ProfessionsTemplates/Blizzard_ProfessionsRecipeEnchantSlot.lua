ProfessionsEnchantSlotMixin = {};

function ProfessionsEnchantSlotMixin:Reset()
	self.Button.QualityOverlay:SetAtlas(nil);
	self:SetAllocateIconShown(false);
	self.unallocatable = nil;
	self.quantityAvailableCallback = nil;
	self.CustomerState:Hide();
	self.allocationItem = nil;
	self.Button:Reset();
	self.Button:SetLocked(false);
	
	if self.continuableContainer then
		self.continuableContainer:Cancel();
	end
	self.continuableContainer = ContinuableContainer:Create();
end

function ProfessionsEnchantSlotMixin:Init(transaction, quantityRequired)
	self:Reset();

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

function ProfessionsEnchantSlotMixin:ClearItem()
	self.allocationItem = nil;

	self.Button:Reset();

	self:SetNameText(PROFESSIONS_ADD_ENCHANT);

	self:Update();
end

function ProfessionsEnchantSlotMixin:SetItem(item)
	self.allocationItem = item;

	self.Button:SetItem(item:GetItemID());
	self.Name:SetText(item:GetItemName());

	self:Update();
end

function ProfessionsEnchantSlotMixin:SetAllocateIconShown(shown)
	self.Button.AddIcon:SetShown(shown);
end