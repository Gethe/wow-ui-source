EQUIPMENTMANAGER_PENDINGEQUIPS = {};
EQUIPMENTMANAGER_PENDINGUNEQUIPS = {};

EQUIPMENTMANAGER_INVENTORYSLOTS = {};
EQUIPMENTMANAGER_BAGSLOTS = {};

local SLOT_LOCKED = 1;
local SLOT_EMPTY = 2;

for i = KEYRING_CONTAINER, NUM_BAG_SLOTS + GetNumBankSlots() do
	EQUIPMENTMANAGER_BAGSLOTS[i] = {};
end

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

local bagSpaceTable = {};
function EquipmentManager_UpdateFreeBagSpace ()
	local bagSlots = EQUIPMENTMANAGER_BAGSLOTS;
	for i = 0, NUM_BAG_SLOTS + GetNumBankSlots() do
		for k, v in next, bagSpaceTable do
			bagSpaceTable[k] = nil;
		end
		if ( GetContainerFreeSlots(i, bagSpaceTable) ) then
			for index, slot in next, bagSpaceTable do
				if ( not bagSlots[i][slot] ) then -- Don't overwrite locked slots, don't reset empty slots to empty
					bagSlots[i][slot] = SLOT_EMPTY;
				end
			end
		end
	end
end

local pendingSet = "";

local combatSwapError;
local bagsFullError;

local function EquipmentManager_CombatError()
	if ( not combatSwapError ) then
		combatSwapError = true;
		UIErrorsFrame:AddMessage(string.format(EQUIPMENT_MANAGER_COMBAT_SWAP, pendingSet), 1.0, 0.1, 0.1, 1.0);
	end
end

local function EquipmentManager_BagsFullError()
	if ( not bagsFullError ) then
		bagsFullError = true;
		UIErrorsFrame:AddMessage(string.format(EQUIPMENT_MANAGER_BAGS_FULL), 1.0, 0.1, 0.1, 1.0);
	end
end

function EquipmentManager_OnEvent (self, event, ...)
	if ( event == "PLAYER_REGEN_ENABLED" ) then
		for slot, info in next, EQUIPMENTMANAGER_PENDINGEQUIPS do
			EQUIPMENTMANAGER_PENDINGEQUIPS[slot] = nil;
			EquipmentManager_FindAndEquipItem(info[1], slot, info[2]); -- 1 = itemID, 2 = location
		end
		for slot in next, EQUIPMENTMANAGER_PENDINGUNEQUIPS do
			EQUIPMENTMANAGER_PENDINGUNEQUIPS[slot] = nil;
			EquipmentManager_UnequipItemInSlot(slot);
		end
		pendingSet = "";
		combatSwapError = nil;
	elseif ( event == "PLAYERBANKBAGSLOTS_CHANGED" ) then
		for i = #EQUIPMENTMANAGER_BAGSLOTS + 1, NUM_BAG_SLOTS + GetNumBankSlots() do
			EQUIPMENTMANAGER_BAGSLOTS[i] = {};
		end
	elseif ( event == "WEAR_EQUIPMENT_SET" ) then
		local setName = ...;
		EquipmentManager_EquipSet(setName);
	elseif ( event == "PLAYER_EQUIPMENT_CHANGED" ) then
		local slot = ...;
		if ( EQUIPMENTMANAGER_PENDINGEQUIPS[slot] ) then
			local info = EQUIPMENTMANAGER_PENDINGEQUIPS[slot];
			EQUIPMENTMANAGER_PENDINGEQUIPS[slot] = nil;
			EquipmentManager_FindAndEquipItem(info[1], slot, info[2]); -- 1 = itemID, 2 = location
		elseif ( EQUIPMENTMANAGER_PENDINGUNEQUIPS[slot] ) then
			EQUIPMENTMANAGER_PENDINGUNEQUIPS[slot] = nil;
			EquipmentManager_UnequipItemInSlot(slot);
		end	
	elseif ( event == "ITEM_UNLOCKED" ) then
		local arg1, arg2 = ...; -- inventory slot or bag and slot
		if ( not arg2 ) then
			EQUIPMENTMANAGER_INVENTORYSLOTS[arg1] = nil;
		else
			EQUIPMENTMANAGER_BAGSLOTS[arg1][arg2] = nil;
		end			
	end
end

EquipmentManager:SetScript("OnEvent", EquipmentManager_OnEvent);
EquipmentManager:RegisterEvent("PLAYER_ENTERING_WORLD");
EquipmentManager:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED");
EquipmentManager:RegisterEvent("PLAYER_REGEN_ENABLED");
EquipmentManager:RegisterEvent("BAG_UPDATE");
EquipmentManager:RegisterEvent("WEAR_EQUIPMENT_SET");
EquipmentManager:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
EquipmentManager:RegisterEvent("ITEM_UNLOCKED");

function EquipmentManager_EquipItemByLocation (location, invSlot)
	local player, bank, bags, slot, bag = EquipmentManager_UnpackLocation(location);
		
	ClearCursor();	
	
	if ( not bags and slot == invSlot ) then --We're trying to reequip an equipped item in the same spot, ignore it.		
		return;
	end
		
	local id, _, _, _, _, _, invType, locked = EquipmentManager_GetItemInfoByLocation(location);
	if ( EQUIPMENTMANAGER_INVENTORYSLOTS[invSlot] == SLOT_LOCKED ) then
		EquipmentManager_AddPendingEquip(id, invSlot, location);
		return;
	elseif ( UnitAffectingCombat("player") ) then
		if ( not INVTYPES_EQUIPPABLE_IN_COMBAT[invType] ) then
			EquipmentManager_CombatError();
			EquipmentManager_AddPendingEquip(id, invSlot, location);
			return;
		end
	end	
		
	local currentItemID = GetInventoryItemID("player", invSlot);
	
	if ( bank ) then 
		UseInventoryItem(slot);
		EQUIPMENTMANAGER_INVENTORYSLOTS[invSlot] = SLOT_LOCKED;
	elseif ( not bags ) then
		EquipmentManager_EquipInventoryItem(slot, invSlot, id, location);
	else
		EquipmentManager_EquipContainerItem(bag, slot, invSlot, id, location);
		
		if ( not currentItemID ) then -- This is going to result in a free bag space
			EQUIPMENTMANAGER_BAGSLOTS[bag][slot] = SLOT_EMPTY;
		end
	end
end

function EquipmentManager_EquipContainerItem (bag, slot, invSlot, id, location)
	ClearCursor();
		
	if ( NON_DEFAULT_INVSLOTS[invSlot] ) then
		PickupContainerItem(bag, slot);
		if ( not CursorHasItem() ) then
			return;
		end
		PickupInventoryItem(invSlot);
	else
		UseContainerItem(bag, slot);
	end
	EQUIPMENTMANAGER_INVENTORYSLOTS[invSlot] = SLOT_LOCKED;
end

function EquipmentManager_EquipInventoryItem (oldSlot, newSlot, id, location)
	ClearCursor();
	PickupInventoryItem(oldSlot);
	if ( not CursorHasItem() ) then
		return;
	end
	PickupInventoryItem(newSlot);
	EQUIPMENTMANAGER_INVENTORYSLOTS[oldSlot] = SLOT_LOCKED;
	EQUIPMENTMANAGER_INVENTORYSLOTS[newSlot] = SLOT_LOCKED;
end

function EquipmentManager_UnpackLocation (location) -- Use me, I'm here to be used.
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
	
	for location, itemID in next, GetInventoryItemsForSlot(invSlot) do
		if ( itemID == soughtItem ) then
			EquipmentManager_EquipItemByLocation(location, invSlot);
			return;
		end
	end	
end

function EquipmentManager_UnequipItemInSlot (slot)	
	if ( EQUIPMENTMANAGER_INVENTORYSLOTS[slot] == SLOT_LOCKED ) then
		EquipmentManager_AddPendingUnequip(slot);
		return;
	end

	local itemID = GetInventoryItemID("player", slot);
	if ( not itemID ) then
		return; -- Slot was empty already;
	end
	
	if ( UnitAffectingCombat("player") ) then
		local _, _, _, _, _, _, _, _, invType = GetItemInfo(itemID);
		if ( not INVTYPES_EQUIPPABLE_IN_COMBAT[invType] ) then
			EquipmentManager_CombatError();
			EquipmentManager_AddPendingUnequip(slot);
			return;
		end
	end 
	PickupInventoryItem(slot);
	if ( not EquipmentManager_PutItemInInventory() ) then
		ClearCursor();
	end
end

function EquipmentManager_PutItemInInventory ()
	if ( not CursorHasItem() ) then
		return;
	end
	
	EquipmentManager_UpdateFreeBagSpace();
	
	local bagSlots = EQUIPMENTMANAGER_BAGSLOTS;
	
	local firstSlot;
	for slot, flag in next, bagSlots[0] do
		if ( flag == SLOT_EMPTY ) then
			firstSlot = min(firstSlot or slot, slot);
		end
	end
	
	if ( firstSlot ) then
		bagSlots[0][firstSlot] = SLOT_LOCKED;
		PutItemInBackpack();
		return true;
	end
	
	for bag = 1, NUM_BAG_SLOTS do
		if ( bagSlots[bag] ) then
			for slot, flag in next, bagSlots[bag] do
				if ( flag == SLOT_EMPTY ) then
					firstSlot = min(firstSlot or slot, slot);
				end
			end
			if ( firstSlot ) then
				bagSlots[bag][firstSlot] = SLOT_LOCKED;
				PutItemInBag(bag + CONTAINER_BAG_OFFSET);
				return true;
			end
		end
	end
	
	EquipmentManager_BagsFullError();
end

function EquipmentManager_AddPendingEquip (itemID, inventorySlot, location)
	EQUIPMENTMANAGER_PENDINGUNEQUIPS[inventorySlot] = nil;
	local equip = EQUIPMENTMANAGER_PENDINGEQUIPS[inventorySlot] or {};
	equip[1] = itemID;
	equip[2] = location;
	EQUIPMENTMANAGER_PENDINGEQUIPS[inventorySlot] = equip;
end

function EquipmentManager_AddPendingUnequip (slotID)
	EQUIPMENTMANAGER_PENDINGEQUIPS[slotID] = nil;
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
	if ( EquipmentSetContainsLockedItems(name) ) then
		return;
	end

	local set = GetEquipmentSetItemLocations(name);
	if ( set ) then
		pendingSet = name;
		combatSwapError = nil;
		bagsFullError = nil;
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
end

