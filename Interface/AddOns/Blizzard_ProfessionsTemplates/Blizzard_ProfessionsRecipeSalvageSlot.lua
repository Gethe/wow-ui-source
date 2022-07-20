ProfessionsSalvageSlotMixin = {};

function ProfessionsSalvageSlotMixin:Reset()
	self.Button.QualityOverlay:SetAtlas(nil);
	self:SetAllocateIconShown(false);
	self.unallocatable = nil;
	self.quantityAvailableCallback = nil;
	self.CustomerState:Hide();
	self.allocationItem = nil;
end

function ProfessionsSalvageSlotMixin:Init(transaction, quantityRequired)
	if self.continuableContainer then
		self.continuableContainer:Cancel();
	end
	self.continuableContainer = ContinuableContainer:Create();

	self.quantityRequired = quantityRequired;

	self.Button:Reset();
	self.Button:SetLocked(false);

	local function OnItemsLoaded()
		local item = transaction:GetSalvageAllocation();
		if item then
			self:SetItem(item);
		end

		self:Update();
	end

	self:SetNameText(PROFESSIONS_ADD_SALVAGE);

	self:Update();

	self.continuableContainer:ContinueOnLoad(OnItemsLoaded);

	self.Button:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end);
end

function ProfessionsSalvageSlotMixin:Update()
	self:UpdateAllocationText();
end

function ProfessionsSalvageSlotMixin:SetQuantityAvailableCallback(callback)
	self.quantityAvailableCallback = callback;
end

function ProfessionsSalvageSlotMixin:UpdateAllocationText()
	if self.allocationItem then
		local count = ItemUtil.GetCraftingReagentCount(self.allocationItem:GetItemID());
		self:SetNameText(("%s %s"):format(
			TRADESKILL_REAGENT_COUNT:format(count, self.quantityRequired), 
			self.allocationItem:GetItemName()));
	end
end

function ProfessionsSalvageSlotMixin:SetNameText(text)
	self.Name:SetText(text);
end

function ProfessionsSalvageSlotMixin:SetUnallocatable(unallocatable)
	self.unallocatable = unallocatable;
end

function ProfessionsSalvageSlotMixin:IsUnallocatable()
	return self.unallocatable;
end

function ProfessionsSalvageSlotMixin:ClearItem()
	self.allocationItem = nil;

	self.Button:Reset();

	self:SetNameText(PROFESSIONS_ADD_SALVAGE);

	self:Update();
end

function ProfessionsSalvageSlotMixin:SetItem(item)
	self.allocationItem = item;

	self.Button:SetItem(item:GetItemID());
	self.Name:SetText(item:GetItemName());

	self:Update();
end

function ProfessionsSalvageSlotMixin:SetAllocateIconShown(shown)
	self.Button.AddIcon:SetShown(shown);
end