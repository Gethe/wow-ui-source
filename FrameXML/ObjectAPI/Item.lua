Item = {};
ItemMixin = {};

local ItemEventListener;

--[[static]] function Item:CreateFromItemLocation(itemLocation)
	local item = CreateFromMixins(ItemMixin);
	item:SetItemLocation(itemLocation);
	return item;
end

--[[static]] function Item:CreateFromBagAndSlot(bagID, slotIndex)
	local item = CreateFromMixins(ItemMixin);
	item:SetItemLocation(ItemLocation:CreateFromBagAndSlot(bagID, slotIndex));
	return item;
end

--[[static]] function Item:CreateFromEquipmentSlot(equipmentSlotIndex)
	local item = CreateFromMixins(ItemMixin);
	item:SetItemLocation(ItemLocation:CreateFromEquipmentSlot(equipmentSlotIndex));
	return item;
end

function ItemMixin:SetItemLocation(itemLocation)
	self:Clear();
	self.itemLocation = itemLocation;
end

function ItemMixin:GetItemLocation()
	return self.itemLocation;
end

function ItemMixin:HasItemLocation()
	return self.itemLocation ~= nil;
end

function ItemMixin:Clear()
	self.itemLocation = nil;
end

function ItemMixin:IsItemEmpty()
	local itemLocation = self:GetItemLocation();
	return not itemLocation or not C_Item.DoesItemExist(itemLocation);
end

-- Item API
do
	local CONTAINER_INDEX = 1;
	local EQUIP_INDEX = 2;

	local SimpleItemAPI = {
		GetItemID = { GetContainerItemID, GetInventoryItemID, },
		GetItemLink = { GetContainerItemLink, GetInventoryItemLink, },
	};

	for apiName, globalAPIs in pairs(SimpleItemAPI) do
		assert(ItemMixin[apiName] == nil);

		ItemMixin[apiName] = function(self, ...)
			if not self:IsItemEmpty() then
				local bagID, slotIndex = self:GetItemLocation():GetBagAndSlot();
				if bagID and slotIndex then
					return globalAPIs[CONTAINER_INDEX](bagID, slotIndex, ...);
				end
				return globalAPIs[EQUIP_INDEX]("player", self:GetItemLocation():GetEquipmentSlot(), ...); 
			end
		end
	end
end

function ItemMixin:IsItemLocked()
	return not self:IsItemEmpty() and C_Item.IsLocked(self:GetItemLocation());
end

function ItemMixin:LockItem()
	if not self:IsItemEmpty() then
		C_Item.LockItem(self:GetItemLocation());
	end
end

function ItemMixin:UnlockItem()
	if not self:IsItemEmpty() then
		C_Item.UnlockItem(self:GetItemLocation());
	end
end

function ItemMixin:GetItemIcon()
	if not self:IsItemEmpty() then
		local bagID, slotIndex = self:GetItemLocation():GetBagAndSlot();
		if bagID and slotIndex then
			return (GetContainerItemInfo(bagID, slotIndex));
		end
		return GetInventoryItemTexture("player", self:GetItemLocation():GetEquipmentSlot());
	end
end

function ItemMixin:GetItemName()
	if not self:IsItemEmpty() then
		return C_Item.GetItemName(self:GetItemLocation());
	end
	return nil;
end

function ItemMixin:GetItemQuality()
	if not self:IsItemEmpty() then
		return C_Item.GetItemQuality(self:GetItemLocation());
	end
	return nil;
end

function ItemMixin:GetCurrentItemLevel()
	if not self:IsItemEmpty() then
		return C_Item.GetCurrentItemLevel(self:GetItemLocation());
	end
	return nil;
end

function ItemMixin:GetItemQualityColor()
	local itemQuality = self:GetItemQuality();
	return ITEM_QUALITY_COLORS[itemQuality]; -- may be nil if item data isn't loaded
end

function ItemMixin:GetInventoryTypeName()
	if not self:IsItemEmpty() then
		return select(4, GetItemInfoInstant(self:GetItemID()));
	end
end

function ItemMixin:IsItemDataCached()
	if not self:IsItemEmpty() then
		return C_Item.IsItemDataCached(self:GetItemLocation());
	end
	return true; 
end

function ItemMixin:IsDataEvictable()
	-- Item data could be evicted from the cache
	return true;
end

-- Add a callback to be executed when item data is loaded, if the item data is already loaded then execute it immediately
function ItemMixin:ContinueOnItemLoad(callbackFunction)
	if type(callbackFunction) ~= "function" or self:IsItemEmpty() then
		error("Usage: NonEmptyItem:ContinueOnLoad(callbackFunction)", 2);
	end

	ItemEventListener:AddCallback(self:GetItemID(), callbackFunction);
end

-- Same as ContinueOnItemLoad, except it returns a function that when called will cancel the continue
function ItemMixin:ContinueWithCancelOnItemLoad(callbackFunction)
	if type(callbackFunction) ~= "function" or self:IsItemEmpty() then
		error("Usage: NonEmptyItem:ContinueWithCancelOnItemLoad(callbackFunction)", 2);
	end

	return ItemEventListener:AddCancelableCallback(self:GetItemID(), callbackFunction);
end

--[ Item Event Listener ]

ItemEventListener = CreateFrame("Frame");
ItemEventListener.callbacks = {};

ItemEventListener:SetScript("OnEvent", 
	function(self, event, ...)
		if event == "ITEM_DATA_LOAD_RESULT" then
			local itemID, success = ...;
			if success then
				self:FireCallbacks(itemID);
			else
				self:ClearCallbacks(itemID);
			end
		end
	end
);
ItemEventListener:RegisterEvent("ITEM_DATA_LOAD_RESULT");

local CANCELED_SENTINEL = -1;

function ItemEventListener:AddCallback(itemID, callbackFunction)
	local callbacks = self:GetOrCreateCallbacks(itemID);
	table.insert(callbacks, callbackFunction);
	C_Item.RequestLoadItemDataByID(itemID);
end

function ItemEventListener:AddCancelableCallback(itemID, callbackFunction)
	local callbacks = self:GetOrCreateCallbacks(itemID);
	table.insert(callbacks, callbackFunction);
	C_Item.RequestLoadItemDataByID(itemID);

	local index = #callbacks;
	return function()
		if #callbacks > 0 and callbacks[index] ~= CANCELED_SENTINEL then
			callbacks[index] = CANCELED_SENTINEL;
			return true;
		end
		return false;
	end;
end

function ItemEventListener:FireCallbacks(itemID)
	local callbacks = self:GetCallbacks(itemID);
	if callbacks then
		self:ClearCallbacks(itemID);
		for i, callback in ipairs(callbacks) do
			if callback ~= CANCELED_SENTINEL then
				securecall(xpcall, callback, CallErrorHandler);
			end
		end

		for i = #callbacks, 1, -1 do
			callbacks[i] = nil;
		end
	end
end

function ItemEventListener:ClearCallbacks(itemID)
	self.callbacks[itemID] = nil;
end

function ItemEventListener:GetCallbacks(itemID)
	return self.callbacks[itemID];
end

function ItemEventListener:GetOrCreateCallbacks(itemID)
	local callbacks = self.callbacks[itemID];
	if not callbacks then
		callbacks = {};
		self.callbacks[itemID] = callbacks;
	end
	return callbacks;
end