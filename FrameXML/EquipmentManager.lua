local msg = function() end;
EQUIPMENTMANAGER_EQUIPMENTSETS = {};

EQUIPMENTMANAGER_PENDINGEQUIPS = {};
EQUIPMENTMANAGER_PENDINGUNEQUIPS = {};

EQUIPMENTMANAGER_LOCKEDSLOTS = {};

EQUIPMENTMANAGER_BAGSPACE = {}

RegisterForSavePerCharacter("EQUIPMENTMANAGER_EQUIPMENTSETS");

EquipmentManager = CreateFrame("FRAME");

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

local function EquipmentManager_UpdateFreeBagSpace()
	for i = 0, NUM_BAG_SLOTS do
		EQUIPMENTMANAGER_BAGSPACE[i] = GetContainerNumFreeSlots(i);
	end
end

function EquipmentManager_OnEvent (self, event, ...)
	if ( event == "PLAYER_REGEN_ENABLED" ) then
		EquipmentManager_UpdateFreeBagSpace();
		for slot, info in next, EQUIPMENTMANAGER_PENDINGEQUIPS do
			if ( not EQUIPMENTMANAGER_LOCKEDSLOTS[slot] ) then
				EQUIPMENTMANAGER_PENDINGEQUIPS[slot] = nil;
				EquipmentManager_FindAndEquipItem(info[1], slot, info[2]); -- 1 = itemID, 2 = location
			end
		end
		for slot in next, EQUIPMENTMANAGER_PENDINGUNEQUIPS do
			if ( not EQUIPMENTMANAGER_LOCKEDSLOTS[slot] ) then
				EQUIPMENTMANAGER_PENDINGUNEQUIPS[slot] = nil;
				EquipmentManager_UnequipItemInSlot(slot);
			end
		end
		self:UnregisterEvent(event);
	elseif ( event == "WEAR_EQUIPMENT_SET" ) then
		local setName = ...;
		EquipmentManager_EquipSet(setName);
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then	
		EquipmentManager_UpdateFreeBagSpace();
	elseif ( event == "PLAYER_EQUIPMENT_CHANGED" ) then
		local slot = ...;
		msg("Equipment Changed in slot " .. slot)
		msg("Unlocked slot");
		EQUIPMENTMANAGER_LOCKEDSLOTS[slot] = nil;
		if ( EQUIPMENTMANAGER_PENDINGEQUIPS[slot] ) then
			EquipmentManager_UpdateFreeBagSpace();
			local info = EQUIPMENTMANAGER_PENDINGEQUIPS[slot];
			EQUIPMENTMANAGER_PENDINGEQUIPS[slot] = nil;
			msg(info);
			EquipmentManager_FindAndEquipItem(info[1], slot, info[2]); -- 1 = itemID, 2 = location
		elseif ( EQUIPMENTMANAGER_PENDINGUNEQUIPS[slot] ) then
			EquipmentManager_UpdateFreeBagSpace();
			EQUIPMENTMANAGER_PENDINGUNEQUIPS[slot] = nil;
			EquipmentManager_UnequipItemInSlot(slot);
		end
	end
end

EquipmentManager:SetScript("OnEvent", EquipmentManager_OnEvent);
EquipmentManager:RegisterEvent("PLAYER_ENTERING_WORLD");
EquipmentManager:RegisterEvent("PLAYER_REGEN_ENABLED");
EquipmentManager:RegisterEvent("BAG_UPDATE");
EquipmentManager:RegisterEvent("WEAR_EQUIPMENT_SET");
EquipmentManager:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");

function EquipmentManager_EquipItemByLocation (location, invSlot)
	msg("Equipping item " .. invSlot);
	local player, bank, bags, slot, bag = EquipmentManager_UnpackLocation(location); -- Fourth return is bag or location
		
	ClearCursor(); -- Or hillarity may ensue, and nobody wants to get ensued.
	
	local id, _, _, _, _, _, invType, locked = EquipmentManager_GetItemInfoByLocation(location);
	if ( EQUIPMENTMANAGER_LOCKEDSLOTS[invSlot] ) then
		EquipmentManager_AddPendingEquip(id, invSlot, location);
		return;
	elseif ( UnitAffectingCombat("player") ) then
		if ( not INVTYPES_EQUIPPABLE_IN_COMBAT[invType] ) then
			EquipmentManager_AddPendingEquip(id, invSlot, location);
			return;
		end
	end	
	
	if ( not bags and slot == invSlot ) then -- If the slot is locked, we might be trying to re-equip something we have equipped that is about to be unequipped.
		msg("Item in slot, abort!")
		--We're trying to reequip an equipped item in the same spot, ignore it.
		return;
	end
	
	msg("Slot locked");
	EQUIPMENTMANAGER_LOCKEDSLOTS[invSlot] = true;
	if ( not bags ) then -- We're wearing this or it's in our main bank
		if ( not bank or NON_DEFAULT_INVSLOTS[invSlot] ) then
			msg(string.format("Switching gear from %d to %d", slot, invSlot));
			
			PickupInventoryItem(slot);
			if ( not CursorHasItem() ) then
				EQUIPMENTMANAGER_LOCKEDSLOTS[invSlot] = nil;
				msg("Swap failed");
				return;
			end
			PickupInventoryItem(invSlot);
		else
			UseInventoryItem(slot);
		end
	elseif ( NON_DEFAULT_INVSLOTS[invSlot] ) then
		msg(string.format("Equipping item in bag %d slot %d to inventory slot %d", bag, slot, invSlot));
		if ( locked ) then
			EQUIPMENTMANAGER_LOCKEDSLOTS[invSlot] = nil;
			msg("Warning: item locked");
			return;
		end
		PickupContainerItem(bag, slot); -- Something new!
		if ( not CursorHasItem() ) then
			EQUIPMENTMANAGER_LOCKEDSLOTS[invSlot] = nil;
			msg("Failed to pickup item from bag");
			return;
		end
		PickupInventoryItem(invSlot); -- Put it in the new spot!
	else
		msg(string.format("Equipping via use container item from bag %d slot %d", bag, slot));
		if ( locked ) then
			EQUIPMENTMANAGER_LOCKEDSLOTS[invSlot] = nil;
			msg("Warning: item locked");
			return;
		end
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
		return player, bank, bags, slot, bag
	else
		return player, bank, bags, location
	end
end

function EquipmentManager_FindAndEquipItem (soughtItem, invSlot, location)
	msg(string.format("Find and equip item %d in slot %d (location %d)", soughtItem, invSlot, location))
	if ( location ) then -- They passed in a location, so try and equip whatever's there, if it's what we're looking for.
		local player, bank, bags, slot, bag = EquipmentManager_UnpackLocation(location);

		local itemID;
		if ( bags ) then
			itemID = GetContainerItemID(bag, slot);
		else
			itemID = GetInventoryItemID("player", slot);
		end
		
		if ( itemID == soughtItem ) then
			EquipmentManager_EquipItemByLocation(location, invSlot);
			return;
		end
	end

	msg("Location was wrong!");
	for location, itemID in next, GetInventoryItemsForSlot(invSlot) do
		msg(string.format("Found item %d for slot %d (location %d)", itemID, invSlot, location));
		if ( itemID == soughtItem ) then
			EquipmentManager_EquipItemByLocation(location, invSlot);
			return;
		end
	end	
end

function EquipmentManager_UnequipItemInSlot (slot)	
	msg(string.format("Unequipping %d", slot));
	
	if ( EQUIPMENTMANAGER_LOCKEDSLOTS[slot] ) then
		EquipmentManager_AddPendingUnequip(slot);
		return;
	end

	local itemID = GetInventoryItemID("player", slot);
	if ( not itemID ) then
		return; -- Slot was empty already;
	end
	
	if ( UnitAffectingCombat("player") ) then
		msg("Unequip - Slot locked")
		local _, _, _, _, _, _, _, _, invType = GetItemInfo(itemID);
		if ( not INVTYPES_EQUIPPABLE_IN_COMBAT[invType] ) then
			EquipmentManager_AddPendingUnequip(slot);
			return;
		end
	end 
	
	msg("Unequip - Locked slot");
	EQUIPMENTMANAGER_LOCKEDSLOTS[slot] = true;
	PickupInventoryItem(slot);
	if ( not EquipmentManager_PutItemInInventory() ) then
		msg("Unequip failed - Unlocked slot");
		EQUIPMENTMANAGER_LOCKEDSLOTS[slot] = nil; -- We didn't try and put it anywhere, don't lock anything after all.
		ClearCursor();
	end
end

function EquipmentManager_PutItemInInventory ()
	if ( not CursorHasItem() ) then
		msg("No item to put in inventory");
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
	
	msg("No space?");
end

function EquipmentManager_AddPendingEquip (itemID, inventorySlot, location)
	msg("Add pending equip for " .. inventorySlot);
	local equip = EQUIPMENTMANAGER_PENDINGEQUIPS[inventorySlot] or {};
	equip[1] = itemID;
	equip[2] = location;
	msg(equip);
	EQUIPMENTMANAGER_PENDINGEQUIPS[inventorySlot] = equip;
	msg(EQUIPMENTMANAGER_PENDINGEQUIPS[inventorySlot]);
end

function EquipmentManager_AddPendingUnequip (slotID)
	EQUIPMENTMANAGER_PENDINGUNEQUIPS[slotID] = true;
end

function EquipmentManager_GetItemInfoByLocation (location)
	local player, bank, bags, slot, bag = EquipmentManager_UnpackLocation(location);
	
	local id, name, textureName, count, durability, maxDurability, invType, locked, start, duration, enable, setTooltip;
	if ( not bags ) then -- and (player or bank) 
		id = GetInventoryItemID("player", slot);
		name, _, _, _, _, _, _, _, invType, textureName = GetItemInfo(id);
		if ( textureName ) then
			count = GetInventoryItemCount("player", slot);
			durability, maxDurability = GetInventoryItemDurability(slot);
			start, duration, enable = GetInventoryItemCooldown("player", slot);
		end
		
		setTooltip = function () GameTooltip:SetInventoryItem("player", slot) end;
	else -- bags
		id = GetContainerItemID(bag, slot);
		name, _, _, _, _, _, _, _, invType = GetItemInfo(id);
		textureName, count, locked = GetContainerItemInfo(bag, slot);
		start, duration, enable = GetContainerItemCooldown(bag, slot);
		
		durability, maxDurability = GetContainerItemDurability(bag, slot);
		
		setTooltip = function () GameTooltip:SetBagItem(bag, slot); end;
	end
	
	return id, name, textureName, count, durability, maxDurability, invType, locked, start, duration, enable, setTooltip;
end

function EquipmentManager_EquipSet (name)
	EquipmentManager_UpdateFreeBagSpace();

	msg("Equipping set " .. name);
	
	for slot in next, EQUIPMENTMANAGER_LOCKEDSLOTS do
		msg(slot)
	end
	
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

