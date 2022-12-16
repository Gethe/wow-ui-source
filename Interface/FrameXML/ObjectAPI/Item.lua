Item = {};
ItemMixin = {};

--[[static]] function Item:CreateFromItemLocation(itemLocation)
	if type(itemLocation) ~= "table" or type(itemLocation.HasAnyLocation) ~= "function" or not itemLocation:HasAnyLocation() then
		error("Usage: Item:CreateFromItemLocation(notEmptyItemLocation)", 2);
	end
	local item = CreateFromMixins(ItemMixin);
	item:SetItemLocation(itemLocation);
	return item;
end

--[[static]] function Item:CreateFromBagAndSlot(bagID, slotIndex)
	if type(bagID) ~= "number" or type(slotIndex) ~= "number" then
		error("Usage: Item:CreateFromBagAndSlot(bagID, slotIndex)", 2);
	end
	local item = CreateFromMixins(ItemMixin);
	item:SetItemLocation(ItemLocation:CreateFromBagAndSlot(bagID, slotIndex));
	return item;
end

--[[static]] function Item:CreateFromEquipmentSlot(equipmentSlotIndex)
	if type(equipmentSlotIndex) ~= "number" then
		error("Usage: Item:CreateFromEquipmentSlot(equipmentSlotIndex)", 2);
	end
	local item = CreateFromMixins(ItemMixin);
	item:SetItemLocation(ItemLocation:CreateFromEquipmentSlot(equipmentSlotIndex));
	return item;
end

--[[static]] function Item:CreateFromItemLink(itemLink)
	if type(itemLink) ~= "string" then
		error("Usage: Item:CreateFromItemLink(itemLinkString)", 2);
	end
	local item = CreateFromMixins(ItemMixin);
	item:SetItemLink(itemLink);
	return item;
end

--[[static]] function Item:CreateFromItemID(itemID)
	if type(itemID) ~= "number" then
		error("Usage: Item:CreateFromItemID(itemID)", 2);
	end
	local item = CreateFromMixins(ItemMixin);
	item:SetItemID(itemID);
	return item;
end

--[[static]] function Item:CreateFromItemGUID(itemGUID)
	if type(itemGUID) ~= "string" then
		error("Usage: Item:CreateFromItemGUID(itemGUIDString)", 2);
	end
	local item = CreateFromMixins(ItemMixin);
	item:SetItemGUID(itemGUID);
	return item;
end

--[[static]] function Item:DoItemsMatch(item1, item2)
	if not item1 or not item2 then
		return false;
	end

	return item1:Matches(item2);
end

function ItemMixin:Matches(item)
	if not item then
		return false;
	end

	local itemID = item:GetItemID();
	if (itemID ~= nil) and (self:GetItemID() == itemID) then
		return true;
	end

	local itemLocation = item:GetItemLocation();
	if (itemLocation ~= nil) and itemLocation:IsEqualTo(self:GetItemLocation()) then
		return true;
	end

	return false;
end

function ItemMixin:SetItemLocation(itemLocation)
	self:Clear();
	self.itemLocation = itemLocation;
end

function ItemMixin:SetItemLink(itemLink)
	self:Clear();
	self.itemLink = itemLink;
end

function ItemMixin:SetItemID(itemID)
	self:Clear();
	self.itemID = itemID;
end

function ItemMixin:SetItemGUID(itemGUID)
	self:Clear();
	self.itemGUID = itemGUID;
end

function ItemMixin:GetItemLocation()
	if self.itemLocation then
		return self.itemLocation;
	end

	if self.itemGUID then
		return C_Item.GetItemLocation(self.itemGUID);
	end
	return nil;
end

function ItemMixin:GetItemGUID()
	if self.itemGUID then
		return self.itemGUID;
	end

	if self.itemLocation then
		return C_Item.GetItemGUID(self.itemLocation);
	end

	return nil;
end

function ItemMixin:HasItemLocation()
	return self.itemLocation ~= nil;
end

function ItemMixin:Clear()
	self.itemLocation = nil;
	self.itemLink = nil;
	self.itemID = nil;
	self.itemGUID = nil;
end

function ItemMixin:IsItemEmpty()
	if self:GetStaticBackingItem() then
		return not C_Item.DoesItemExistByID(self:GetStaticBackingItem());
	end

	return not self:IsItemInPlayersControl();
end

function ItemMixin:GetStaticBackingItem()
	return self.itemLink or self.itemID;
end

function ItemMixin:IsItemInPlayersControl()
	local itemLocation = self:GetItemLocation();
	if itemLocation and C_Item.DoesItemExist(itemLocation) then
		return true;
	end

	return false;
end

-- Item API
function ItemMixin:GetItemID()
	if self:GetStaticBackingItem() then
		return (GetItemInfoInstant(self:GetStaticBackingItem()));
	end

	if not self:IsItemEmpty() then
		return C_Item.GetItemID(self:GetItemLocation());
	end
	return nil;
end

function ItemMixin:IsItemLocked()
	return self:IsItemInPlayersControl() and C_Item.IsLocked(self:GetItemLocation());
end

function ItemMixin:LockItem()
	if self:IsItemInPlayersControl() then
		C_Item.LockItem(self:GetItemLocation());
	end
end

function ItemMixin:UnlockItem()
	if self:IsItemInPlayersControl() then
		C_Item.UnlockItem(self:GetItemLocation());
	end
end

function ItemMixin:GetItemIcon() -- requires item data to be loaded
	if self:GetStaticBackingItem() then
		return C_Item.GetItemIconByID(self:GetStaticBackingItem());
	end

	if not self:IsItemEmpty() then
		return C_Item.GetItemIcon(self:GetItemLocation());
	end
end

function ItemMixin:GetItemName() -- requires item data to be loaded
	if self:GetStaticBackingItem() then
		return C_Item.GetItemNameByID(self:GetStaticBackingItem());
	end

	if not self:IsItemEmpty() then
		return C_Item.GetItemName(self:GetItemLocation());
	end
	return nil;
end

function ItemMixin:GetItemLink() -- requires item data to be loaded
	if self.itemLink then
		return self.itemLink;
	end

	if self.itemID then
		return (select(2, GetItemInfo(self.itemID)));
	end

	if not self:IsItemEmpty() then
		return C_Item.GetItemLink(self:GetItemLocation());
	end
	return nil;
end

function ItemMixin:GetItemQuality() -- requires item data to be loaded
	if self:GetStaticBackingItem() then
		return C_Item.GetItemQualityByID(self:GetStaticBackingItem());
	end

	if not self:IsItemEmpty() then
		return C_Item.GetItemQuality(self:GetItemLocation());
	end
	return nil;
end

function ItemMixin:GetStackCount() -- requires item data to be loaded
	if not self:IsItemEmpty() then
		return C_Item.GetStackCount(self:GetItemLocation());
	end
	return nil;
end

function ItemMixin:GetCurrentItemLevel() -- requires item data to be loaded
	if self:GetStaticBackingItem() then
		return (GetDetailedItemLevelInfo(self:GetStaticBackingItem()));
	end

	if not self:IsItemEmpty() then
		return C_Item.GetCurrentItemLevel(self:GetItemLocation());
	end
	return nil;
end

function ItemMixin:GetItemQualityColor() -- requires item data to be loaded
	local itemQuality = self:GetItemQuality();
	return ITEM_QUALITY_COLORS[itemQuality]; -- may be nil if item data isn't loaded
end

function ItemMixin:GetItemQualityColorRGB() -- requires item data to be loaded
	local colorTbl = self:GetItemQualityColor();
	return colorTbl.color:GetRGB();
end

function ItemMixin:GetItemMaxStackSize() -- requires item data to be loaded
	if self:GetStaticBackingItem() then
		return C_Item.GetItemMaxStackSizeByID(self:GetStaticBackingItem());
	end

	if not self:IsItemEmpty() then
		return C_Item.GetItemMaxStackSize(self:GetItemLocation());
	end
	return nil;
end

function ItemMixin:IsStackable() -- requires item data to be loaded
	local maxStackSize = self:GetItemMaxStackSize();
	return maxStackSize and maxStackSize > 1;
end

function ItemMixin:GetInventoryType()
	if self:GetStaticBackingItem() then
		return C_Item.GetItemInventoryTypeByID(self:GetStaticBackingItem());
	end

	if not self:IsItemEmpty() then
		return C_Item.GetItemInventoryType(self:GetItemLocation());
	end
	return nil;
end

function ItemMixin:GetInventoryTypeName()
	if not self:IsItemEmpty() then
		return select(4, GetItemInfoInstant(self:GetItemID()));
	end
end

function ItemMixin:IsItemDataCached()
	if self:GetStaticBackingItem() then
		return C_Item.IsItemDataCachedByID(self:GetStaticBackingItem());
	end

	if not self:IsItemEmpty() then
		return C_Item.IsItemDataCached(self:GetItemLocation());
	end
	return true;
end

function ItemMixin:IsDataEvictable()
	-- Item data could be evicted from the cache
	return true;
end

function ItemMixin:ValidateForContinueOnItemLoad(methodName, callbackFunction)
	if type(callbackFunction) ~= "function" then
		error(("Usage: NonEmptyItem:%s(callbackFunction): invalid callbackFunction"):format(methodName), 3);
	end

	if self:IsItemEmpty() then
		if self.itemLink then
			error(("Usage: NonEmptyItem:%s(callbackFunction) invalid itemLink: <%s>"):format(methodName, self.itemLink), 3);
		elseif self.itemID then
			error(("Usage: NonEmptyItem:%s(callbackFunction) invalid itemID: <%d>"):format(methodName, self.itemID), 3);
		end

		error(("Usage: NonEmptyItem:%s(callbackFunction): invalid item"):format(methodName), 3);
	end
end

-- Add a callback to be executed when item data is loaded, if the item data is already loaded then execute it immediately
function ItemMixin:ContinueOnItemLoad(callbackFunction)
	self:ValidateForContinueOnItemLoad("ContinueOnItemLoad", callbackFunction);
	ItemEventListener:AddCallback(self:GetItemID(), callbackFunction);
end

-- Same as ContinueOnItemLoad, except it returns a function that when called will cancel the continue
function ItemMixin:ContinueWithCancelOnItemLoad(callbackFunction)
	self:ValidateForContinueOnItemLoad("ContinueWithCancelOnItemLoad", callbackFunction);
	return ItemEventListener:AddCancelableCallback(self:GetItemID(), callbackFunction);
end

-- Generic aliases for use with ContinuableContainer
function ItemMixin:ContinueWithCancelOnRecordLoad(callbackFunction)
	return self:ContinueWithCancelOnItemLoad(callbackFunction);
end

function ItemMixin:IsRecordDataCached()
	return self:IsItemDataCached();
end