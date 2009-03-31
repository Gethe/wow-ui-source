EQUIPMENTMANAGER_EQUIPMENTACTIONS = {};

EQUIPMENTMANAGER_INVENTORYSLOTS = {};
EQUIPMENTMANAGER_BAGSLOTS = {};

local _tableCache = {};

local function _GetTable()
	return tremove(_tableCache, 1) or {};
end

local function _ReleaseTable(t)
	wipe(t)
	tinsert(_tableCache, t);
end

local _pendingSet = "";

local _combatSwapError;
local _bagsFullError;
local _missingItemError;
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

INVSLOTS_EQUIPABLE_IN_COMBAT = {
[INVSLOT_MAINHAND] = true,
[INVSLOT_OFFHAND] = true,
[INVSLOT_RANGED] = true,
}

NON_DEFAULT_INVSLOTS = {
[INVSLOT_FINGER1] = INVSLOT_FINGER2,
[INVSLOT_FINGER2] = INVSLOT_FINGER1,
[INVSLOT_TRINKET1] = INVSLOT_TRINKET2,
[INVSLOT_TRINKET2] = INVSLOT_TRINKET1,
[INVSLOT_MAINHAND] = INVSLOT_OFFHAND,
[INVSLOT_OFFHAND] = INVSLOT_MAINHAND,
}

MAINHAND_TYPES = {
["INVTYPE_WEAPON"] = true,
["INVTYPE_WEAPONMAINHAND"] = true,
["INVTYPE_2HWEAPON"] = true,
}

OFFHAND_TYPES = {
["INVTYPE_WEAPONOFFHAND"] = true,
["INVTYPE_WEAPON"] = true,
["INVTYPE_HOLDABLE"] = true,
["INVTYPE_SHIELD"] = true,
}

function EquipmentManager_UpdateFreeBagSpace ()
	local bagSlots = EQUIPMENTMANAGER_BAGSLOTS;
	
	local workTable = _GetTable();
	
	for i = BANK_CONTAINER, NUM_BAG_SLOTS + GetNumBankSlots() do
		local _, bagType = GetContainerNumFreeSlots(i);
		if ( GetContainerFreeSlots(i, workTable) ) then
			for index, slot in next, workTable do
				if ( bagSlots[i] and not bagSlots[i][slot] and bagType == 0 ) then -- Don't overwrite locked slots, don't reset empty slots to empty, only use normal bags
					bagSlots[i][slot] = SLOT_EMPTY;
				end
			end
		end
		wipe(workTable);
	end
	_ReleaseTable(workTable);
end

local function _EquipmentManager_CombatError()
	if ( not _combatSwapError ) then
		_combatSwapError = true;
		UIErrorsFrame:AddMessage(string.format(EQUIPMENT_MANAGER_COMBAT_SWAP, _pendingSet), 1.0, 0.1, 0.1, 1.0);
	end
end

local function _EquipmentManager_BagsFullError()
	if ( not _bagsFullError ) then
		_bagsFullError = true;
		UIErrorsFrame:AddMessage(EQUIPMENT_MANAGER_BAGS_FULL, 1.0, 0.1, 0.1, 1.0);
	end
end

local function _EquipmentManager_MissingItemError()
	if ( not _missingItemError ) then
		_missingItemError = true;
		UIErrorsFrame:AddMessage(string.format(EQUIPMENT_MANAGER_MISSING_ITEM, _pendingSet), 1.0, 0.1, 0.1, 1.0);
	end
end

function EquipmentManager_OnEvent (self, event, ...)
	if ( event == "PLAYER_REGEN_ENABLED" ) then
		EquipmentManager_ProcessActions();
		_pendingSet = "";
		_combatSwapError = nil;
	elseif ( event == "PLAYER_ENTERING_WORLD" or event == "PLAYERBANKBAGSLOTS_CHANGED" ) then
		for i = #EQUIPMENTMANAGER_BAGSLOTS + 1, NUM_BAG_SLOTS + GetNumBankSlots() do
			EQUIPMENTMANAGER_BAGSLOTS[i] = {};
		end
	elseif ( event == "WEAR_EQUIPMENT_SET" ) then
		local setName = ...;
		EquipmentManager_EquipSet(setName);
	elseif ( event == "ITEM_UNLOCKED" ) then
		local arg1, arg2 = ...; -- inventory slot or bag and slot
		
		local id
		if ( not arg2 ) then
			id = GetInventoryItemID("player", arg1);
			EQUIPMENTMANAGER_INVENTORYSLOTS[arg1] = nil;
		else
			id = GetContainerItemID(arg1, arg2);
			EQUIPMENTMANAGER_BAGSLOTS[arg1][arg2] = nil;
		end			

		local index;
		for i, action in ipairs(EQUIPMENTMANAGER_EQUIPMENTACTIONS) do
			if ( action.run ) then
				if ( (action.type == EQUIP_ITEM or action.type == SWAP_ITEM) and action.invSlot == arg1 and not arg2 and action.id == id ) then
					index = i;
					break;
				elseif ( action.type == UNEQUIP_ITEM and action.bag == arg1 and action.slot == arg2 and action.id == id ) then
					index = i;
					break;
				elseif ( (action.type == SWAP_ITEM or action.type == EQUIP_ITEM) and action.bag == arg1 and action.slot == arg2 and action.id == id ) then
					index = i;
					break;
				elseif ( (action.type == SWAP_ITEM or action.type == EQUIP_ITEM) and
					action.bank and not action.bags and arg1 == BANK_CONTAINER and 
					action.slot == arg2 + BANK_CONTAINER_INVENTORY_OFFSET) then
					index = i;
					break;
				elseif ( action.type == UNEQUIP_ITEM and action.invSlot == arg1 and not arg2 ) then
					index = i;
					break;
				end
			end
		end
		
		if ( index ) then
			local action = tremove(EQUIPMENTMANAGER_EQUIPMENTACTIONS, index);
			for i = index + 1, #EQUIPMENTMANAGER_EQUIPMENTACTIONS do
				local actionTwo = EQUIPMENTMANAGER_EQUIPMENTACTIONS[i];
				if ( action.invSlot == actionTwo.waitForSlot and action.set == actionTwo.set ) then
					actionTwo.waitForSlot = nil;
				elseif ( action.invSlot == actionTwo.invSlot ) then -- Tooo far!
					break;
				end
			end
			_ReleaseTable(action);
			EquipmentManager_ProcessActions();
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
EquipmentManager:RegisterEvent("PLAYER_REGEN_ENABLED");
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
	
	for i = #EQUIPMENTMANAGER_EQUIPMENTACTIONS, 1, -1 do
		local action = EQUIPMENTMANAGER_EQUIPMENTACTIONS[i];
		if ( action and action.invSlot == invSlot and action.run ) then
			return nil; -- Slot has pending action
		elseif ( action and action.invSlot == invSlot ) then
			_ReleaseTable(tremove(EQUIPMENTMANAGER_EQUIPMENTACTIONS, i));
		end
	end
	
	local id, _, _, _, _, _, _, _, _, _, _, _, gem1, gem2, gem3 = EquipmentManager_GetItemInfoByLocation(location);
	
	if ( UnitAffectingCombat("player") ) then
		if ( not INVSLOTS_EQUIPABLE_IN_COMBAT[invSlot] ) then
			_EquipmentManager_CombatError();
		end
	end
	
	local currentItemID = GetInventoryItemID("player", invSlot);

	local action = _GetTable();
	action.type = (currentItemID and SWAP_ITEM) or EQUIP_ITEM;
	action.id = id;
	action.gem1 = gem1;
	action.gem2 = gem2;
	action.gem3 = gem3;
	action.invSlot = invSlot;
	action.locked = locked;
	action.player = player;
	action.bank = bank;
	action.bags = bags;
	action.slot = slot;
	action.bag = bag;
	action.set = _pendingSet;
	
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

function EquipmentManager_UnequipItemInSlot (invSlot)		
	for i = #EQUIPMENTMANAGER_EQUIPMENTACTIONS, 1, -1 do
		local action = EQUIPMENTMANAGER_EQUIPMENTACTIONS[i];
		if ( action and action.invSlot == invSlot and action.run ) then
			return nil;
		elseif ( action and action.invSlot == invSlot ) then
			local action = EQUIPMENTMANAGER_EQUIPMENTACTIONS[i];
			_ReleaseTable(tremove(EQUIPMENTMANAGER_EQUIPMENTACTIONS, i));
		end
	end
	
	local itemID = GetInventoryItemID("player", invSlot);
	if ( not itemID ) then
		return nil; -- Slot was empty already;
	end
	
	if ( UnitAffectingCombat("player") ) then
		if ( not INVSLOTS_EQUIPABLE_IN_COMBAT[invSlot] ) then
			_EquipmentManager_CombatError();
		end
	end

	local action = _GetTable();
	action.type = UNEQUIP_ITEM;
	action.invSlot = invSlot;
	action.set = _pendingSet
	
	return action;
end

function EquipmentManager_PutItemInInventory (action)
	if ( not CursorHasItem() ) then
		return;
	end
	
	local _, id = GetCursorInfo();
	
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
			action.id = id;
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
					action.id = id;
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
				action.id = id;
				action.bag = BANK_CONTAINER;
				action.slot = firstSlot;
			end
			return true;
		else
			for bag = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + GetNumBankSlots() do
				if ( flag == SLOT_EMPTY ) then
					firstSlot = min(firstSlot or slot, slot);
				end
			end
			if ( firstSlot ) then
				bagSlots[bag][firstSlot] = SLOT_LOCKED;
				PickupContainerItem(bag, firstSlot);
				
				if ( action ) then
					action.id = id;
					action.bag = bag;
					action.slot = firstSlot;
				end
				return true;
			end
		end
	end
	
	ClearCursor();
	_EquipmentManager_BagsFullError();
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
	if ( not player and not bank and not bags ) then -- Invalid location
		return;
	end
		
	local id, name, textureName, count, durability, maxDurability, invType, locked, start, duration, enable, setTooltip, gem1, gem2, gem3;
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
	if ( EquipmentSetContainsLockedItems(name) or UnitOnTaxi("player") or UnitCastingInfo("player") ) then
		UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0);
		return;
	end

	local set = GetEquipmentSetLocations(name);
	if ( set ) then
		_pendingSet = name;
		_combatSwapError = nil;
		_bagsFullError = nil;
		_missingItemError = nil;
		
		local actions = _GetTable();
		for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
			if ( not set[slot] ) then
				-- Ignore this slot
			elseif ( set[slot] == EQUIPMENT_SET_EMPTY_SLOT ) then
				tinsert(actions, EquipmentManager_UnequipItemInSlot(slot));
			elseif ( set[slot] == EQUIPMENT_SET_ITEM_MISSING ) then
				_EquipmentManager_MissingItemError();
			else
				tinsert(actions, EquipmentManager_EquipItemByLocation(set[slot], slot));
			end
		end
		
		EquipmentManager_SortActions(actions);
		
		for k, v in ipairs(actions) do
			tinsert(EQUIPMENTMANAGER_EQUIPMENTACTIONS, v);
		end
		
		EquipmentManager_ProcessActions();
		
		_ReleaseTable(actions);
	end
end

local _itemMaxTable = {};
_itemMaxTable[ITEM_UNIQUE_EQUIPPED] = {};

local function _GetUniqueInformationForGem (gemID, invSlot, inventoryTable)
	if ( not gemID ) then
		return;
	end
	
	local uniqueFamily, maxEquipped = GetItemUniqueness(gemID);
	if ( not uniqueFamily ) then
		return;
	elseif ( uniqueFamily == ITEM_UNIQUE_EQUIPPED ) then
		_itemMaxTable[ITEM_UNIQUE_EQUIPPED][gemID] = invSlot;
	else
		_itemMaxTable[uniqueFamily] = maxEquipped;
	end
	
	inventoryTable[uniqueFamily] = inventoryTable[uniqueFamily] or _GetTable();
	inventoryTable[uniqueFamily][invSlot] = (inventoryTable[uniqueFamily][invSlot] or 0) + 1;
	inventoryTable[uniqueFamily]["count"] = (inventoryTable[uniqueFamily]["count"] or 0) + 1;
end

local function _addWaitForSlot (action, slot, workTable)
	if ( not action.waitForSlot ) then
		action.waitForSlot = slot;
		return;
	else
		for k, v in ipairs(workTable) do
			if ( v.invSlot == action.waitForSlot ) then
				_addWaitForSlot(v, slot, workTable);
			end
		end
	end		
end

function EquipmentManager_SortActions (actions)
	local workTable = _GetTable();

	local nonDefaultActions = _GetTable();
	
	for i, action in ipairs(actions) do
		local invSlot = action.invSlot;
		for i = #EQUIPMENTMANAGER_EQUIPMENTACTIONS, 1, -1 do
			local staleAction = EQUIPMENTMANAGER_EQUIPMENTACTIONS[i];
			if ( staleAction and not staleAction.run and staleAction.invSlot == invSlot ) then
				_ReleaseTable(tremove(EQUIPMENTMANAGER_EQUIPMENTACTIONS, i));
			end
		end

		if ( NON_DEFAULT_INVSLOTS[action.invSlot] ) then
			nonDefaultActions[action.invSlot] = action;
		else
			tinsert(workTable, action);
		end
	end

	for slotOne = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
		local actionOne = nonDefaultActions[slotOne];
		local slotTwo = NON_DEFAULT_INVSLOTS[slotOne];
		local actionTwo = slotTwo and nonDefaultActions[slotTwo];
		if ( actionOne and actionTwo and not actionOne.bags and actionOne.slot == slotTwo ) then
			local idOne = GetInventoryItemID("player", slotOne);
			local idTwo = GetInventoryItemID("player", slotTwo);
			if ( idOne ) then -- If we have an item in the slot we're going to be equipping to and
				if ( not actionTwo.bags and actionTwo.slot == slotOne ) then --If we're swapping two items in our inventory
					-- We only need one action for this swap
					tinsert(workTable, actionOne);
					_ReleaseTable(actionTwo);
					nonDefaultActions[slotTwo] = false;
					nonDefaultActions[slotOne] = false;
				elseif ( actionTwo.type == SWAP_ITEM ) then -- If we're swapping one item and moving an inventory item into the slot it came from
					actionOne.waitForSlot = slotTwo;
					actionOne.player = actionTwo.player;
					actionOne.bank = actionTwo.bank;
					actionOne.bags = actionTwo.bags;
					actionOne.bag = actionTwo.bag;
					actionOne.slot = actionTwo.slot;
					tinsert(workTable, actionTwo); -- Action two needs to run first
					tinsert(workTable, actionOne);
					nonDefaultActions[slotOne] = false;
					nonDefaultActions[slotTwo] = false;
				elseif ( actionTwo.type == UNEQUIP_ITEM ) then -- We really want to unequip item one, and then move item two into item one's slot.
					actionTwo.invSlot = slotOne; -- So action two needs to unequip action one's slot
					actionOne.type = EQUIP_ITEM;
					actionOne.waitForSlot = slotOne; -- and action one needs to wait for action two
					tinsert(workTable, actionTwo);
					tinsert(workTable, actionOne);
					nonDefaultActions[slotOne] = false;
					nonDefaultActions[slotTwo] = false;
				end
			elseif ( actionTwo and actionTwo.type == SWAP_ITEM ) then
				actionTwo.type = EQUIP_ITEM;
				actionTwo.waitForSlot = slotOne;
				tinsert(workTable, actionOne);
				tinsert(workTable, actionTwo);
				nonDefaultActions[slotOne] = false;
				nonDefaultActions[slotTwo] = false;
			end
		end
	end
	
	for invSlot, action in next, nonDefaultActions do	
		if ( action ) then
			tinsert(workTable, action);
			nonDefaultActions[invSlot] = false;
		end
	end
	
	_ReleaseTable(nonDefaultActions);

	local uniqueItemsInInventory = _GetTable();
	for i, action in next, workTable do
		for gem = 1, MAX_NUM_SOCKETS do
			local gem1, gem2, gem3 = GetInventoryItemGems(action.invSlot);
			_GetUniqueInformationForGem(gem1, action.invSlot, uniqueItemsInInventory);
			_GetUniqueInformationForGem(gem2, action.invSlot, uniqueItemsInInventory);
			_GetUniqueInformationForGem(gem3, action.invSlot, uniqueItemsInInventory);
		end	
	end
	
	local uniqueItemsInSet = _GetTable();
	for i, action in next, workTable do
		for gem = 1, MAX_NUM_SOCKETS do
			local gemID = action["gem" .. gem]
			_GetUniqueInformationForGem(gemID, action.invSlot, uniqueItemsInSet);
		end
	end
	
	for family, invSlots in next, uniqueItemsInSet do
		if ( uniqueItemsInInventory[family] ) then
			if ( family == ITEM_UNIQUE_EQUIPPED ) then
				for gemID, invSlot in next, invSlots do
					if ( uniqueItemsInInventory[ITEM_UNIQUE_EQUIPPED][gemID] ) then
						for index, action in ipairs(workTable) do
							if ( action.invSlot == invSlot ) then
								_addWaitForSlot(action, uniqueItemsInInventory[ITEM_UNIQUE_EQUIPPED][gemID], workTable);
							end
						end
					end
				end			
			else
				local firstInventory, lastInventory;
				for invSlot, count in next, uniqueItemsInInventory[family] do
					if ( tonumber(invSlot) and ( not uniqueItemsInSet[family][invSlot] or uniqueItemsInSet[family][invSlot] <= count ) ) then
						for index, action in ipairs(workTable) do
							if ( action.invSlot == invSlot and not action.waitForSlot ) then
								tinsert(workTable, 1, tremove(workTable, index));
								_addWaitForSlot(action, lastInventory, workTable);
								lastInventory = invSlot;
								firstInventory = firstInventory or invSlot;
								break;
							end
						end
					end
				end
				
				for index, action in ipairs(workTable) do
					if ( invSlots[action.invSlot] and not action.waitForSlot ) then
						_addWaitForSlot(action, firstInventory, workTable);
					end
				end
			end
		end
	end
	
	_ReleaseTable(uniqueItemsInInventory);
	_ReleaseTable(uniqueItemsInSet);
	
	wipe(actions);

	for k, v in ipairs(workTable) do
		tinsert(actions, v);
	end
	
	_ReleaseTable(workTable);
	
	return actions;
end

local _processing = false
function EquipmentManager_ProcessActions ()
	if ( _processing or #EQUIPMENTMANAGER_EQUIPMENTACTIONS == 0 ) then
		return;
	end
	
	_processing = true;
	local workTable = _GetTable();
		
	local pendingSlots = _GetTable();
	for i = 1, #EQUIPMENTMANAGER_EQUIPMENTACTIONS do
		local action = EQUIPMENTMANAGER_EQUIPMENTACTIONS[i];
		if ( action.invSlot and not action.run and not action.waitForSlot ) then
			if ( EquipmentManager_RunAction(action) ) then 
				action.run = true;
				pendingSlots[action.invSlot] = true;
			else
				workTable[i] = true;
				for j = i+1, #EQUIPMENTMANAGER_EQUIPMENTACTIONS do
					local actionTwo = EQUIPMENTMANAGER_EQUIPMENTACTIONS[j];
					if ( action.invSlot == actionTwo.waitForSlot and action.set == actionTwo.set ) then
						actionTwo.waitForSlot = nil;
					elseif ( action.set ~= actionTwo.set ) then
						break;
					end
				end
			end
		elseif ( not action.invSlot ) then -- bad action
			workTable[i] = true;
		end
	end
	
	for i = #EQUIPMENTMANAGER_EQUIPMENTACTIONS, 1, -1 do
		if ( workTable[i] ) then
			_ReleaseTable(tremove(EQUIPMENTMANAGER_EQUIPMENTACTIONS, i));
		end
	end
	
	_ReleaseTable(workTable);
	_ReleaseTable(pendingSlots);
	_processing = false;
end

function EquipmentManager_RunAction (action)
	if ( UnitAffectingCombat("player") and not INVSLOTS_EQUIPABLE_IN_COMBAT[action.invSlot] ) then
		return true;
	end
	
	if ( action.type == EQUIP_ITEM or action.type == SWAP_ITEM ) then
		if ( not action.bags ) then
			return EquipmentManager_EquipInventoryItem(action);
		else
			local hasItem = action.invSlot and GetInventoryItemID("player", action.invSlot);
			local pending = EquipmentManager_EquipContainerItem(action);
			
			if ( pending and not hasItem ) then -- This is going to result in a free bag space
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
