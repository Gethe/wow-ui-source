ItemLocation = {};
ItemLocationMixin = {};

--[[static]] function ItemLocation:CreateEmpty()
	local itemLocation = CreateFromMixins(ItemLocationMixin);
	return itemLocation;
end

--[[static]] function ItemLocation:CreateFromBagAndSlot(bagID, slotIndex)
	local itemLocation = ItemLocation:CreateEmpty();
	itemLocation:SetBagAndSlot(bagID, slotIndex);
	return itemLocation;
end

--[[static]] function ItemLocation:CreateFromEquipmentSlot(equipmentSlotIndex)
	local itemLocation = ItemLocation:CreateEmpty();
	itemLocation:SetEquipmentSlot(equipmentSlotIndex);
	return itemLocation;
end

function ItemLocationMixin:Clear()
	self.bagID = nil;
	self.slotIndex = nil;
	self.equipmentSlotIndex = nil;
end

function ItemLocationMixin:SetBagAndSlot(bagID, slotIndex)
	self:Clear();

	self.bagID = bagID;
	self.slotIndex = slotIndex;
end

function ItemLocationMixin:GetBagAndSlot()
	return self.bagID, self.slotIndex;
end

function ItemLocationMixin:SetEquipmentSlot(equipmentSlotIndex)
	self:Clear();

	self.equipmentSlotIndex = equipmentSlotIndex;
end

function ItemLocationMixin:GetEquipmentSlot()
	return self.equipmentSlotIndex;
end

function ItemLocationMixin:IsEquipmentSlot()
	return self.equipmentSlotIndex ~= nil;
end

function ItemLocationMixin:IsBagAndSlot()
	return self.bagID ~= nil and self.slotIndex ~= nil;
end

function ItemLocationMixin:HasAnyLocation()
	return self:IsEquipmentSlot() or self:IsBagAndSlot();
end

function ItemLocationMixin:IsValid()
	return C_Item.DoesItemExist(self);
end

function ItemLocationMixin:IsEqualToBagAndSlot(otherBagID, otherSlotIndex)
	local bagID, slotIndex = self:GetBagAndSlot();
	if bagID and slotIndex then
		return bagID == otherBagID and slotIndex == otherSlotIndex;
	end
	return false;
end

function ItemLocationMixin:IsEqualToEquipmentSlot(otherEquipmentSlotIndex)
	local equipmentSlotIndex = self:GetEquipmentSlot();
	if equipmentSlotIndex then
		return equipmentSlotIndex == otherEquipmentSlotIndex;
	end
	return false;
end

function ItemLocationMixin:IsEqualTo(otherItemLocation)
	if otherItemLocation then
		local bagID, slotIndex = self:GetBagAndSlot();
		if bagID and slotIndex then
			local otherBagID, otherSlotIndex = otherItemLocation:GetBagAndSlot();
			return bagID == otherBagID and slotIndex == otherSlotIndex;
		end

		local equipmentSlotIndex = self:GetEquipmentSlot();
		if equipmentSlotIndex then
			local otherEquipmentSlotIndex = otherItemLocation:GetEquipmentSlot();
			return equipmentSlotIndex == otherEquipmentSlotIndex;
		end

		return not otherItemLocation:HasAnyLocation();
	end

	return false;
end