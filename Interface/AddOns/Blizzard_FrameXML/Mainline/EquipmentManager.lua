EQUIPMENTMANAGER_INVENTORYSLOTS = {};
EQUIPMENTMANAGER_BAGSLOTS = {};

local _isAtBank = false;
local SLOT_LOCKED = -1;
local SLOT_EMPTY = -2;

local EQUIP_ITEM = 1;
local UNEQUIP_ITEM = 2;
local SWAP_ITEM = 3;

for i = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
	EQUIPMENTMANAGER_BAGSLOTS[i] = {};
end

EquipmentManager = CreateFrame("FRAME");

function EquipmentManager_UpdateFreeBagSpace ()
	local bagSlots = EQUIPMENTMANAGER_BAGSLOTS;

	for i = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS + C_Bank.FetchNumPurchasedBankTabs(Enum.BankType.Character) do
		local _, bagType = C_Container.GetContainerNumFreeSlots(i);
		local freeSlots = C_Container.GetContainerFreeSlots(i);
		if ( freeSlots ) then
			if (not bagSlots[i]) then
				bagSlots[i] = {};
			end

			-- Reset all EMPTY bag slots
			for index, flag in next, bagSlots[i] do
				if (flag == SLOT_EMPTY) then
					bagSlots[i][index] = nil;
				end
			end

			for index, slot in ipairs(freeSlots) do
				if ( bagSlots[i] and not bagSlots[i][slot] and bagType == 0 ) then -- Don't overwrite locked slots, don't reset empty slots to empty, only use normal bags
					bagSlots[i][slot] = SLOT_EMPTY;
				end
			end
		else
			bagSlots[i] = nil;
		end
	end
end

local function _EquipmentManager_BagsFullError()
	UIErrorsFrame:AddMessage(ERR_EQUIPMENT_MANAGER_BAGS_FULL, 1.0, 0.1, 0.1, 1.0);
end

function EquipmentManager_OnEvent (self, event, ...)
	if ( event == "ITEM_UNLOCKED" ) then
		local arg1, arg2 = ...; -- inventory slot or bag and slot

		if ( not arg2 ) then
			EQUIPMENTMANAGER_INVENTORYSLOTS[arg1] = nil;
		elseif (EQUIPMENTMANAGER_BAGSLOTS[arg1]) then
			EQUIPMENTMANAGER_BAGSLOTS[arg1][arg2] = nil;
		end

	elseif ( event == "BANKFRAME_OPENED" ) then
		_isAtBank = true;
	elseif ( event == "BANKFRAME_CLOSED" ) then
		_isAtBank = false;
	end
end

EquipmentManager:SetScript("OnEvent", EquipmentManager_OnEvent);
EquipmentManager:RegisterEvent("ITEM_UNLOCKED");
EquipmentManager:RegisterEvent("BANKFRAME_OPENED");
EquipmentManager:RegisterEvent("BANKFRAME_CLOSED");

function EquipmentManager_EquipItemByLocation (location, invSlot)
	local locationData = EquipmentManager_GetLocationData(location);

	ClearCursor();

	if ( not locationData.isBags and locationData.slot == invSlot ) then --We're trying to reequip an equipped item in the same spot, ignore it.
		return nil;
	end

	local currentItemID = GetInventoryItemID("player", invSlot);

	local action = {};
	action.type = (currentItemID and SWAP_ITEM) or EQUIP_ITEM;
	action.invSlot = invSlot;
	action.player = locationData.isPlayer;
	action.bank = locationData.isBank;
	action.bags = locationData.isBags;
	action.slot = locationData.slot;
	action.bag = locationData.bag;

	return action;
end

function EquipmentManager_EquipContainerItem (action)
	ClearCursor();

	C_Container.PickupContainerItem(action.bag, action.slot);

	if ( not CursorHasItem() ) then
		return false;
	end

	if ( not C_PaperDollInfo.CanCursorCanGoInSlot(action.invSlot) ) then
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
	if ( not C_PaperDollInfo.CanCursorCanGoInSlot(action.invSlot) ) then
		return false;
	elseif ( IsInventoryItemLocked(action.invSlot) ) then
		return false;
	end
	PickupInventoryItem(action.invSlot);
	EQUIPMENTMANAGER_INVENTORYSLOTS[action.slot] = SLOT_LOCKED;
	EQUIPMENTMANAGER_INVENTORYSLOTS[action.invSlot] = SLOT_LOCKED;

	return true;
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

	for bag = 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
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
		for bag = NUM_TOTAL_EQUIPPED_BAG_SLOTS + 1, NUM_TOTAL_EQUIPPED_BAG_SLOTS + C_Bank.FetchNumPurchasedBankTabs(Enum.BankType.Character) do
			if ( bagSlots[bag] ) then
				for slot, flag in next, bagSlots[bag] do
					if ( flag == SLOT_EMPTY ) then
						firstSlot = min(firstSlot or slot, slot);
					end
				end
				if ( firstSlot ) then
					bagSlots[bag][firstSlot] = SLOT_LOCKED;
					C_Container.PickupContainerItem(bag, firstSlot);

					if ( action ) then
						action.bag = bag;
						action.slot = firstSlot;
					end
					return true;
				end
			end
		end
	end

	ClearCursor();
	_EquipmentManager_BagsFullError();
end

function EquipmentManager_GetItemInfoByLocation (location)
	local locationData = EquipmentManager_GetLocationData(location);
	if TableIsEmpty(locationData) then -- Invalid location
		return;
	end
	
	local bag, slot = locationData.bag, locationData.slot;
	local itemID, name, textureName, count, durability, maxDurability, invType, locked, start, duration, enable, setTooltip, quality, isUpgrade, isBound, _; -- luacheck: ignore 221 (variable 'isBound' is never set)
	if ( not locationData.isBags ) then -- and (locationData.isPlayer or locationData.isBank)
		itemID = GetInventoryItemID("player", slot);
		isBound = true;
		name, _, _, _, _, _, _, _, invType, textureName = C_Item.GetItemInfo(itemID);
		if ( textureName ) then
			count = GetInventoryItemCount("player", slot);
			durability, maxDurability = GetInventoryItemDurability(slot);
			start, duration, enable = GetInventoryItemCooldown("player", slot);
			quality = GetInventoryItemQuality("player", slot);
		end

		setTooltip = function () GameTooltip:SetInventoryItem("player", slot) end;
	else -- locationData.isBags
		itemID = C_Container.GetContainerItemID(bag, slot);
		name, _, _, _, _, _, _, _, invType = C_Item.GetItemInfo(itemID);
		local info = C_Container.GetContainerItemInfo(bag, slot);
		textureName = info.iconFileID;
		count = info.stackCount;
		locked = info.isLocked;
		quality = info.quality;
		isBound = info.isBound;
		start, duration, enable = C_Container.GetContainerItemCooldown(bag, slot);

		durability, maxDurability = C_Container.GetContainerItemDurability(bag, slot);

		setTooltip = function () GameTooltip:SetBagItem(bag, slot); end;
	end

	return itemID, name, textureName, count, durability, maxDurability, invType, locked, start, duration, enable, setTooltip, quality, isUpgrade, isBound;
end

function EquipmentManager_EquipSet (setID)
	if ( C_EquipmentSet.EquipmentSetContainsLockedItems(setID) or UnitCastingInfo("player") ) then
		UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0);
		return;
	end

	C_EquipmentSet.UseEquipmentSet(setID);
end

function EquipmentManager_RunAction (action)
	if ( UnitAffectingCombat("player") and not INVSLOTS_EQUIPABLE_IN_COMBAT[action.invSlot] ) then
		return true;
	end

	EquipmentManager_UpdateFreeBagSpace();

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
