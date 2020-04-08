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

function AzeriteUtil.AreAnyAzeriteEmpoweredItemsEquipped()
	for equipSlotIndex, itemLocation in AzeriteUtil.EnumerateEquipedAzeriteEmpoweredItems() do
		return true;
	end
	return false;
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

function AzeriteUtil.GenerateRequiredSpecTooltipLine(powerID)
	local specs = C_AzeriteEmpoweredItem.GetSpecsForPower(powerID);
	if not specs then
		return nil;
	end

	local playerSex = UnitSex("player");
	local _, _, playerClassID = UnitClass("player");
	local playerSpecID = GetSpecializationInfo(GetSpecialization());

	local validSpecs;
	for i, specInfo in ipairs(specs) do
		if specInfo.classID == playerClassID then
			if specInfo.specID == playerSpecID then
				return nil; -- Nothing to show, we match this spec
			end
			validSpecs = validSpecs or {};
			local _, specName = GetSpecializationInfoByID(specInfo.specID, playerSex);
			table.insert(validSpecs, specName);
		end
	end

	if not validSpecs then
		return nil;
	end

	if #validSpecs > 1 then
		return REQUIRES_OR_SPECIALIZATIONS:format(table.concat(validSpecs, PLAYER_LIST_DELIMITER, 1, #validSpecs - 1), validSpecs[#validSpecs]);
	end
	return REQUIRES_SPECIALIZATION:format(table.concat(validSpecs, PLAYER_LIST_DELIMITER));
end

function AzeriteUtil.FindAzeritePowerTier(azeriteEmpoweredItemSource, powerID)
	for tierIndex, tierInfo in ipairs(azeriteEmpoweredItemSource:GetAllTierInfo()) do
		for powerIndex, azeritePowerID in ipairs(tierInfo.azeritePowerIDs) do
			if powerID == azeritePowerID then
				return tierIndex;
			end
		end
	end

	return nil;
end

function AzeriteUtil.GetSelectedAzeritePowerInTier(azeriteEmpoweredItemSource, tierIndex)
	local allTierInfo = azeriteEmpoweredItemSource:GetAllTierInfo();
	local tierInfo = allTierInfo[tierIndex];
	if tierInfo then
		for powerIndex, azeritePowerID in ipairs(tierInfo.azeritePowerIDs) do
			if azeriteEmpoweredItemSource:IsPowerSelected(azeritePowerID) then
				return azeritePowerID;
			end
		end
	end

	return nil;
end

function AzeriteUtil.HasSelectedAnyAzeritePower(azeriteEmpoweredItemSource)
	local allTierInfo = azeriteEmpoweredItemSource:GetAllTierInfo();
	for tierIndex, tierInfo in ipairs(allTierInfo) do
		for powerIndex, azeritePowerID in ipairs(tierInfo.azeritePowerIDs) do
			if azeriteEmpoweredItemSource:IsPowerSelected(azeritePowerID) then
				return true;
			end
		end
	end

	return nil;
end

function AzeriteUtil.DoesBagContainAnyAzeriteEmpoweredItems(bagID)
	local itemLocation = ItemLocation:CreateEmpty();
	for slotIndex = 1, ContainerFrame_GetContainerNumSlots(bagID) do
		itemLocation:SetBagAndSlot(bagID, slotIndex);
		if C_Item.DoesItemExist(itemLocation) and C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation) then
			return true;
		end
	end

	return false;
end

function AzeriteUtil.IsAzeriteItemLocationBankBag(azeriteItemLocation)
	return azeriteItemLocation and azeriteItemLocation.bagID and azeriteItemLocation.bagID >= NUM_BAG_SLOTS;
end