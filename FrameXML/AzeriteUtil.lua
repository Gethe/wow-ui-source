AzeriteUtil = {};

do
	local function AzeriteEmpoweredItemIterator(_, equipSlotIndex)
		equipSlotIndex = equipSlotIndex + 1;

		if equipSlotIndex <= EQUIPPED_LAST then
			local itemLocation = ItemLocation:CreateEmpty();
			while equipSlotIndex <= EQUIPPED_LAST do
				itemLocation:SetEquipmentSlot(equipSlotIndex);

				if C_Item.DoesItemExist(itemLocation) and C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation) then
					return equipSlotIndex, itemLocation;
				end

				equipSlotIndex = equipSlotIndex + 1;
			end
		end
	end

	function AzeriteUtil.EnumerateEquipedAzeriteEmpoweredItems()
		return AzeriteEmpoweredItemIterator, nil, EQUIPPED_FIRST - 1;
	end
end

function AzeriteUtil.DoEquippedItemsHaveUnselectedPowers()
	for equipSlotIndex, itemLocation in AzeriteUtil.EnumerateEquipedAzeriteEmpoweredItems() do
		if C_AzeriteEmpoweredItem.HasAnyUnselectedPowers(itemLocation) then
			return true;
		end
	end
	return false;
end

function AzeriteUtil.GetEquippedItemsUnselectedPowersCount()
	local count = 0; 
	for equipSlotIndex, itemLocation in AzeriteUtil.EnumerateEquipedAzeriteEmpoweredItems() do
		if C_AzeriteEmpoweredItem.HasAnyUnselectedPowers(itemLocation) then
			count = count + 1; 
		end
	end
	return count;
end