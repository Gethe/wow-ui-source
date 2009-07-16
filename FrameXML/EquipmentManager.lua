EQUIPMENTMANAGER_INVENTORYSLOTS = {};
EQUIPMENTMANAGER_BAGSLOTS = {};

local _isAtBank = false;
local SLOT_LOCKED = -1;
local SLOT_EMPTY = -2;

local EQUIP_ITEM = 1;
local UNEQUIP_ITEM = 2;
local SWAP_ITEM = 3;

for i = KEYRING_CONTAINER, NUM_BAG_SLOTS do
	EQUIPMENTMANAGER_BAGSLOTS[i] = {};
end

EquipmentManager = CreateFrame("FRAME");

local workTable = {};
function EquipmentManager_UpdateFreeBagSpace ()
	local bagSlots = EQUIPMENTMANAGER_BAGSLOTS;
	
	for i = BANK_CONTAINER, NUM_BAG_SLOTS + GetNumBankSlots() do
		wipe(workTable);
		local _, bagType = GetContainerNumFreeSlots(i);
		if ( GetContainerFreeSlots(i, workTable) ) then
			for index, slot in next, workTable do
				if ( bagSlots[i] and not bagSlots[i][slot] and bagType == 0 ) then -- Don't overwrite locked slots, don't reset empty slots to empty, only use normal bags
					bagSlots[i][slot] = SLOT_EMPTY;
				end
			end
		end
	end
end

local function _EquipmentManager_BagsFullError()
	UIErrorsFrame:AddMessage(EQUIPMENT_MANAGER_BAGS_FULL, 1.0, 0.1, 0.1, 1.0);
end

function EquipmentManager_OnEvent (self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" or event == "PLAYERBANKBAGSLOTS_CHANGED" ) then
		for i = #EQUIPMENTMANAGER_BAGSLOTS + 1, NUM_BAG_SLOTS + GetNumBankSlots() do
			EQUIPMENTMANAGER_BAGSLOTS[i] = {};
		end
	elseif ( event == "WEAR_EQUIPMENT_SET" ) then
		local setName = ...;
		EquipmentManager_EquipSet(setName);
	elseif ( event == "ITEM_UNLOCKED" ) then
		local arg1, arg2 = ...; -- inventory slot or bag and slot
		
		if ( not arg2 ) then
			EQUIPMENTMANAGER_INVENTORYSLOTS[arg1] = nil;
		else
			EQUIPMENTMANAGER_BAGSLOTS[arg1][arg2] = nil;
		end			

	elseif ( event == "BANKFRAME_OPENED" ) then
		_isAtBank = true;
	elseif ( event == "BANKFRAME_CLOSED" ) then
		_isAtBank = false;
	end
end

EquipmentManager:SetScript("OnEvent", EquipmentManager_OnEvent);
EquipmentManager:RegisterEvent("PLAYER_ENTERING_WORLD");
EquipmentManager:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED");
EquipmentManager:RegisterEvent("WEAR_EQUIPMENT_SET");
EquipmentManager:RegisterEvent("ITEM_UNLOCKED");
EquipmentManager:RegisterEvent("BANKFRAME_OPENED");
EquipmentManager:RegisterEvent("BANKFRAME_CLOSED");

function EquipmentManager_EquipItemByLocation (location, invSlot)
	local player, bank, bags, slot, bag = EquipmentManager_UnpackLocation(location);
		
	ClearCursor();	
	
	if ( not bags and slot == invSlot ) then --We're trying to reequip an equipped item in the same spot, ignore it.		
		return nil;
	end
	
	local currentItemID = GetInventoryItemID("player", invSlot);

	local action = {};
	action.type = (currentItemID and SWAP_ITEM) or EQUIP_ITEM;
	action.invSlot = invSlot;
	action.player = player;
	action.bank = bank;
	action.bags = bags;
	action.slot = slot;
	action.bag = bag;
	
	return action;
end

function EquipmentManager_EquipContainerItem (action)
	ClearCursor();
	
	PickupContainerItem(action.bag, action.slot);
	
	if ( not CursorHasItem() ) then
		return false;
	end
	
	if ( not CursorCanGoInSlot(action.invSlot) ) then
		return false;
	elseif ( IsInventoryItemLocked(action.invSlot) ) then
		return false;
	end
	
	PickupInventoryItem(action.invSlot);
	
	EQUIPMENTMANAGER_BAGSLOTS[action.bag][action.slot] = action.invSlot;
	EQUIPMENTMANAGER_INVENTORYSLOTS[action.invSlot] = SLOT_LOCKED;
	
	return true;
end

function EquipmentManager_EquipInventoryItem (action)
	ClearCursor();
	PickupInventoryItem(action.slot);
	if ( not CursorCanGoInSlot(action.invSlot) ) then
		return false;
	elseif ( IsInventoryItemLocked(action.invSlot) ) then
		return false;
	end
	PickupInventoryItem(action.invSlot);
	EQUIPMENTMANAGER_INVENTORYSLOTS[action.slot] = SLOT_LOCKED;
	EQUIPMENTMANAGER_INVENTORYSLOTS[action.invSlot] = SLOT_LOCKED;
	
	return true;
end

function EquipmentManager_UnpackLocation (location) -- Use me, I'm here to be used.
	if ( location < 0 ) then -- Thanks Seerah!
		return false, false, false, 0;
	end
	
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

function EquipmentManager_UnequipItemInSlot (invSlot)		
	local itemID = GetInventoryItemID("player", invSlot);
	if ( not itemID ) then
		return nil; -- Slot was empty already;
	end
	
	local action = {};
	action.type = UNEQUIP_ITEM;
	action.invSlot = invSlot;
	
	return action;
end

function EquipmentManager_PutItemInInventory (action)
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
		if ( action ) then
			action.bag = 0;
			action.slot = firstSlot;
		end
		
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
				
				if ( action ) then
					action.bag = bag;
					action.slot = firstSlot;
				end
				return true;
			end
		end
	end
	
	if ( _isAtBank ) then
		for slot, flag in next, bagSlots[BANK_CONTAINER] do
			if ( flag == SLOT_EMPTY ) then
				firstSlot = min(firstSlot or slot, slot);
			end
		end
		if ( firstSlot ) then
			bagSlots[BANK_CONTAINER][firstSlot] = SLOT_LOCKED;
			PickupInventoryItem(firstSlot + BANK_CONTAINER_INVENTORY_OFFSET);
			
			if ( action ) then
				action.bag = BANK_CONTAINER;
				action.slot = firstSlot;
			end
			return true;
		else
			for bag = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + GetNumBankSlots() do
				if ( bagSlots[bag] ) then
					for slot, flag in next, bagSlots[bag] do
						if ( flag == SLOT_EMPTY ) then
							firstSlot = min(firstSlot or slot, slot);
						end
					end
					if ( firstSlot ) then
						bagSlots[bag][firstSlot] = SLOT_LOCKED;
						PickupContainerItem(bag, firstSlot);
						
						if ( action ) then
							action.bag = bag;
							action.slot = firstSlot;
						end
						return true;
					end
				end
			end
		end
	end
	
	ClearCursor();
	_EquipmentManager_BagsFullError();
end

function EquipmentManager_GetItemInfoByLocation (location)
	local player, bank, bags, slot, bag = EquipmentManager_UnpackLocation(location);
	if ( not player and not bank and not bags ) then -- Invalid location
		return;
	end

	local id, name, textureName, count, durability, maxDurability, invType, locked, start, duration, enable, setTooltip, gem1, gem2, gem3, _;
	if ( not bags ) then -- and (player or bank) 
		id = GetInventoryItemID("player", slot);
		name, _, _, _, _, _, _, _, invType, textureName = GetItemInfo(id);
		if ( textureName ) then
			count = GetInventoryItemCount("player", slot);
			durability, maxDurability = GetInventoryItemDurability(slot);
			start, duration, enable = GetInventoryItemCooldown("player", slot);
		end
		
		setTooltip = function () GameTooltip:SetInventoryItem("player", slot) end;
		gem1, gem2, gem3 = GetInventoryItemGems(slot);
	else -- bags
		id = GetContainerItemID(bag, slot);
		name, _, _, _, _, _, _, _, invType = GetItemInfo(id);
		textureName, count, locked = GetContainerItemInfo(bag, slot);
		start, duration, enable = GetContainerItemCooldown(bag, slot);
		
		durability, maxDurability = GetContainerItemDurability(bag, slot);
		
		setTooltip = function () GameTooltip:SetBagItem(bag, slot); end;
		gem1, gem2, gem3 = GetContainerItemGems(bag, slot);
	end
	
	return id, name, textureName, count, durability, maxDurability, invType, locked, start, duration, enable, setTooltip, gem1, gem2, gem3;
end

function EquipmentManager_EquipSet (name)
	if ( EquipmentSetContainsLockedItems(name) or UnitCastingInfo("player") ) then
		UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0);
		return;
	end
	
	UseEquipmentSet(name);
end

function EquipmentManager_RunAction (action)
	if ( UnitAffectingCombat("player") and not INVSLOTS_EQUIPABLE_IN_COMBAT[action.invSlot] ) then
		return true;
	end
	action.run = true;
	if ( action.type == EQUIP_ITEM or action.type == SWAP_ITEM ) then
		if ( not action.bags ) then
			return EquipmentManager_EquipInventoryItem(action);
		else
			local hasItem = action.invSlot and GetInventoryItemID("player", action.invSlot);
			local pending = EquipmentManager_EquipContainerItem(action);
			
			if ( pending and not hasItem ) then
				EQUIPMENTMANAGER_BAGSLOTS[action.bag][action.slot] = SLOT_EMPTY;
			end
			
			return pending;
		end
	elseif ( action.type == UNEQUIP_ITEM ) then
		ClearCursor();
		
		if ( IsInventoryItemLocked(action.invSlot) ) then
			return;
		else
			PickupInventoryItem(action.invSlot);
			return EquipmentManager_PutItemInInventory(action);
		end
	end
end
