ProfessionsSalvageSlotMixin = {};

function ProfessionsSalvageSlotMixin:Reset()
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

function ProfessionsSalvageSlotMixin:Init(transaction, quantityRequired)
	self:Reset();

	self.quantityRequired = quantityRequired;

	self:Update();
	
	local function OnItemsLoaded()
		local item = transaction:GetSalvageAllocation();
		if item then
			self:SetItem(item);
		end

		self:Update();
	end
	
	self.continuableContainer:ContinueOnLoad(OnItemsLoaded);

	self.Button:SetScript("OnLeave", GameTooltip_Hide);
end

function ProfessionsSalvageSlotMixin:Update()
	if not self:UpdateAllocationText() then
		self:SetNameText(PROFESSIONS_ADD_SALVAGE);
	end
end

function ProfessionsSalvageSlotMixin:SetQuantityAvailableCallback(callback)
	self.quantityAvailableCallback = callback;
end

function ProfessionsSalvageSlotMixin:UpdateAllocationText()
	if self.allocationItem then
		local quantity = self.allocationItem:GetStackCount();
		if quantity then
			self:SetNameText(("%s %s"):format(
				TRADESKILL_REAGENT_COUNT:format(quantity, self.quantityRequired),
				self.allocationItem:GetItemName()));
				return true;
		end
	end
	return false;
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

	self:Update();
end

function ProfessionsSalvageSlotMixin:SetAllocateIconShown(shown)
	self.Button.AddIcon:SetShown(shown);
end