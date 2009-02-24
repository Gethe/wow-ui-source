EQUIPMENTMANAGER_EQUIPMENTSETS = {};

EQUIPMENTMANAGER_PENDINGEQUIPS = {};
EQUIPMENTMANAGER_PENDINGUNEQUIPS = {};

EQUIPMENTMANAGER_LOCKEDSLOTS = {};

EQUIPMENTMANAGER_BAGSPACE = {}

RegisterForSavePerCharacter("EQUIPMENTMANAGER_EQUIPMENTSETS");

EquipmentManager = CreateFrame("FRAME");

local function EquipmentManager_UpdateFreeBagSpace()
	for i = 0, NUM_BAG_SLOTS do
		EQUIPMENTMANAGER_BAGSPACE[i] = GetContainerNumFreeSlots(i);
	end
end

function EquipmentManager_OnEvent (self, event, ...)
	if ( event == "PLAYER_REGEN_ENABLED" ) then
		for slot, info in next, EQUIPMENTMANAGER_PENDINGEQUIPS do
			EquipmentManager_FindAndEquipItem(info[1], slot, info[2]); -- 1 = itemID, 2 = location
			EQUIPMENTMANAGER_PENDINGEQUIPS[slot] = nil;
		end
		for slot in next, EQUIPMENTMANAGER_PENDINGUNEQUIPS do
			EquipmentManager_UnequipItemInSlot(slot);
			EQUIPMENTMANAGER_PENDINGUNEQUIPS[slot] = nil;
		end
		self:UnregisterEvent(event);
	elseif ( event == "WEAR_EQUIPMENT_SET" ) then
		local setName = ...;
		EquipmentManager_EquipSet(setName);
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then	
		EquipmentManager_UpdateFreeBagSpace();
	end
end

EquipmentManager:SetScript("OnEvent", EquipmentManager_OnEvent);
EquipmentManager:RegisterEvent("PLAYER_ENTERING_WORLD");
EquipmentManager:RegisterEvent("PLAYER_REGEN_ENABLED");
EquipmentManager:RegisterEvent("BAG_UPDATE");
EquipmentManager:RegisterEvent("WEAR_EQUIPMENT_SET");

INVTYPES_EQUIPPABLE_IN_COMBAT = {
["INVTYPE_RANGED"] = true,
["INVTYPE_RANGEDRIGHT"] = true,
["INVTYPE_THROWN"] = true,
["INVTYPE_2HWEAPON"] = true,
["INVTYPE_HOLDABLE"] = true,
["INVTYPE_WEAPONOFFHAND"] = true,
["INVTYPE_SHIELD"] = true,
["INVTYPE_WEAPONMAINHAND"] = true,
["INVTYPE_WEAPON"] = true,
["INVTYPE_AMMO"] = true,
["INVTYPE_RELIC"] = true,
}

NON_DEFAULT_INVSLOTS = {
[INVSLOT_FINGER2] = true,
[INVSLOT_TRINKET2] = true,
[INVSLOT_OFFHAND] = true,
}

function EquipmentManager_EquipItemByLocation (location, inventorySlot)
	local player, bank, bags, bag, slot = EquipmentManager_UnpackLocation(location); -- Fourth return is bag or location
	local originalLocation = location;
	
	if ( not bags ) then
		location = bag;
	end
	
	ClearCursor(); -- Or hillarity may ensue, and nobody wants to get ensued.
		
	if ( UnitAffectingCombat("player") ) then
		local id, _, _, _, _, _, invType = EquipmentManager_GetItemInfoByLocation(location);
		if ( not INVTYPES_EQUIPPABLE_IN_COMBAT[invType] ) then
			EquipmentManager_AddPendingEquip(id, inventorySlot, originalLocation);
			return;
		end
	end	
	
	if ( not bags ) then -- We're wearing this or it's in our main bank
		if ( not bank or NON_DEFAULT_INVSLOTS[inventorySlot] ) then
			PickupInventoryItem(location);
			PickupInventoryItem(inventorySlot);
		else
			UseInventoryItem(location);
		end
	elseif ( NON_DEFAULT_INVSLOTS[inventorySlot] ) then
		PickupContainerItem(bag, slot); -- Something new!
		PickupInventoryItem(inventorySlot); -- Put it in the new spot!
	else
		UseContainerItem(bag, slot);
	end
end

function EquipmentManager_UnpackLocation (location)
	local player = (bit.band(location, ITEM_INVENTORY_LOCATION_PLAYER) ~= 0);
	local bank = (bit.band(location, ITEM_INVENTORY_LOCATION_BANK) ~= 0);
	local bags = (bit.band(location, ITEM_INVENTORY_LOCATION_BAGS) ~= 0);

	if ( player ) then
		location = location - ITEM_INVENTORY_LOCATION_PLAYER;
	elseif ( bank ) then
		location = location - ITEM_INVENTORY_LOCATION_BANK;
	end
	
	if ( bags ) then
		location = location - ITEM_INVENTORY_LOCATION_BAGS;
		local bag = bit.rshift(location, ITEM_INVENTORY_BAG_BIT_OFFSET);
		local slot = location - bit.lshift(bag, ITEM_INVENTORY_BAG_BIT_OFFSET);	
		
		if ( bank ) then
			bag = bag + ITEM_INVENTORY_BANK_BAG_OFFSET;
		end
		return player, bank, bags, bag, slot
	else
		return player, bank, bags, location
	end
end

function EquipmentManager_FindAndEquipItem (soughtItem, slot, location)
	if ( location ) then -- They passed in a location, so try and equip whatever's there, if it's what we're looking for.
		local player, bank, bags, bagOrLocation, slot = EquipmentManager_UnpackLocation(location);

		local itemID;
		if ( bags ) then
			itemID = GetContainerItemID(bagOrLocation, slot);
		else
			itemID = GetInventoryItemID("player", bagOrLocation);
		end
		
		if ( itemID == soughtItem ) then
			EquipmentManager_EquipItemByLocation(location, slot);
			return;
		end
	end

	local finalLocation;
	local foundItems;
	for location, itemID in next, GetInventoryItemsForSlot(slot) do
		if ( itemID == soughtItem ) then
			EquipmentManager_EquipItemByLocation(location, slot);
			return;
		end
	end	
end

function EquipmentManager_UnequipItemInSlot (slotID)
	local itemID = GetInventoryItemID("player", slotID);
	if ( not itemID ) then -- There wasn't anything in this slot anyway...
		return;
	end
	
	if ( UnitAffectingCombat("player") ) then
		local _, _, _, _, _, _, _, _, invType = GetItemInfo(itemID);
		if ( not INVTYPES_EQUIPPABLE_IN_COMBAT[invType] ) then
			EquipmentManager_AddPendingUnequip(slotID);
			return;
		end
	end 
	
	PickupInventoryItem(slotID);
	if ( not EquipmentManager_PutItemInInventory() ) then
		ClearCursor();
	end
end

function EquipmentManager_PutItemInInventory ()
	if ( not CursorHasItem() ) then
		return;
	end
	
	local freeSlots = EQUIPMENTMANAGER_BAGSPACE[0]
	if ( freeSlots > 0 ) then
		PutItemInBackpack();
		EQUIPMENTMANAGER_BAGSPACE[0] = freeSlots - 1;
		return true;
	end
	
	for bag = 1, NUM_BAG_SLOTS do
		freeSlots = EQUIPMENTMANAGER_BAGSPACE[bag]
		if ( freeSlots > 0 ) then
			PutItemInBag(bag + CONTAINER_BAG_OFFSET);
			EQUIPMENTMANAGER_BAGSPACE[bag] = freeSlots - 1;
			return true;
		end
	end
end

function EquipmentManager_AddPendingEquip (itemID, inventorySlot, location)
	EquipmentManager:RegisterEvent("PLAYER_LEAVING_COMBAT");
	EQUIPMENTMANAGER_PENDINGEQUIPS[inventorySlot] = { itemID, location };
end

function EquipmentManager_AddPendingUnequip (slotID)
	EquipmentManager:RegisterEvent("PLAYER_LEAVING_COMBAT");
	EQUIPMENTMANAGER_PENDINGUNEQUIPS[slotID] = true;
end

function EquipmentManager_GetItemInfoByLocation (location)
	local player, bank, bags, bag, slot = EquipmentManager_UnpackLocation(location);
	
	local id, name, textureName, count, durability, maxDurability, invType, start, duration, enable, setTooltip;
	if ( not bags ) then -- and (player or bank) 
		location = bag;
		id = GetInventoryItemID("player", location);
		name, _, _, _, _, _, _, _, equipLoc, textureName = GetItemInfo(id);
		if ( textureName ) then
			count = GetInventoryItemCount("player", location);
			durability, maxDurability = GetInventoryItemDurability(location);
			start, duration, enable = GetInventoryItemCooldown("player", location);
		end
		
		setTooltip = function () GameTooltip:SetInventoryItem("player", location) end;
	else -- bags
		id = GetContainerItemID(bag, slot);
		name, _, _, _, _, _, _, _, equipLoc = GetItemInfo(id);
		textureName, count = GetContainerItemInfo(bag, slot);
		start, duration, enable = GetContainerItemCooldown(bag, slot);
		
		durability, maxDurability = GetContainerItemDurability(bag, slot);
		
		setTooltip = function () GameTooltip:SetBagItem(bag, slot); end;
	end
	
	return id, name, textureName, count, durability, maxDurability, invType, start, duration, enable, setTooltip;
end

function EquipmentManager_EquipSet (name)
	EquipmentManager_UpdateFreeBagSpace();

	local set = GetEquipmentSetItemLocations(name);
	for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
		if ( not set[slot] ) then
			-- Ignore this slot
		elseif ( set[slot] == EQUIPMENT_SET_EMPTY_SLOT ) then
			EquipmentManager_UnequipItemInSlot(slot);
		elseif ( set[slot] == EQUIPMENT_SET_ITEM_MISSING ) then
			-- Missing item =/
		else
			EquipmentManager_EquipItemByLocation(set[slot], slot);
		end
	end
end

function EquipmentManager_SetContainsItem(name, itemID, slot)
	
	if ( slot ) then
		return set[slot] == itemID;
	else
		for slot, item in next, set do
			if ( itemID == item ) then
				return true;
			end
		end
	end
	
	return false;
end

