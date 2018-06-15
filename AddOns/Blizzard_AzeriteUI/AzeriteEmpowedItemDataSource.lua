AzeriteEmpowedItemDataSourceMixin = {};
AzeriteEmpowedItemDataSource = {};

function AzeriteEmpowedItemDataSource:CreateEmpty()
	return CreateFromMixins(AzeriteEmpowedItemDataSourceMixin);
end

function AzeriteEmpowedItemDataSource:CreateFromFromItemLocation(empoweredItemLocation)
	local source = AzeriteEmpowedItemDataSource:CreateEmpty();
	source:SetSourceFromItemLocation(empoweredItemLocation);
	return source;
end

function AzeriteEmpowedItemDataSource:CreateFromFromItemLink(empoweredItemLink)
	local source = AzeriteEmpowedItemDataSource:CreateEmpty();
	source:SetSourceFromItemLink(empoweredItemLink);
	return source;
end

function AzeriteEmpowedItemDataSourceMixin:SetSourceFromItemLocation(empoweredItemLocation)
	self:Clear();
	self.empoweredItemLocation = empoweredItemLocation;
	self.item = Item:CreateFromItemLocation(self.empoweredItemLocation);
	self.itemGUID = self.item:GetItemGUID();
end

function AzeriteEmpowedItemDataSourceMixin:SetSourceFromItemLink(empoweredItemLink, overrideClassID, overrideSelectedPowersList)
	self:Clear();
	self.empoweredItemLink = empoweredItemLink;
	self.overrideClassID = overrideClassID;
	self.overrideSelectedPowersList = overrideSelectedPowersList;
	self.item = Item:CreateFromItemLink(self.empoweredItemLink);
end

function AzeriteEmpowedItemDataSourceMixin:Clear()
	self.empoweredItemLink = nil;
	self.empoweredItemLocation = nil;
	self.item = nil;
	self.itemGUID = nil;
	self.overrideClassID = nil;
	self.overrideSelectedPowersList = nil;
end

function AzeriteEmpowedItemDataSourceMixin:IsValid()
	local item = self:GetItem();
	if not item or self:GetItem():IsItemEmpty() then
		return false;
	end

	if self.empoweredItemLink then
		return C_AzeriteEmpoweredItem.IsAzeritePreviewSourceDisplayable(self.empoweredItemLink, self.overrideClassID);
	end

	return #C_AzeriteEmpoweredItem.GetAllTierInfo(self.empoweredItemLocation) > 0;
end

function AzeriteEmpowedItemDataSourceMixin:IsPreviewSource()
	return self.empoweredItemLocation == nil or not C_AzeriteItem.HasActiveAzeriteItem();
end

function AzeriteEmpowedItemDataSourceMixin:GetItemLocation()
	return self.empoweredItemLocation;
end

function AzeriteEmpowedItemDataSourceMixin:GetItem()
	return self.item;
end

function AzeriteEmpowedItemDataSourceMixin:HasBeenViewed()
	if self:IsPreviewSource() then
		return true;
	end
	return C_AzeriteEmpoweredItem.HasBeenViewed(self.empoweredItemLocation);
end

function AzeriteEmpowedItemDataSourceMixin:SetHasBeenViewed()
	if self:IsPreviewSource() then
		return;
	end
	return C_AzeriteEmpoweredItem.SetHasBeenViewed(self.empoweredItemLocation);
end

function AzeriteEmpowedItemDataSourceMixin:GetAllTierInfo()
	if self.empoweredItemLocation then
		return C_AzeriteEmpoweredItem.GetAllTierInfo(self.empoweredItemLocation);
	elseif self.empoweredItemLink then
		return C_AzeriteEmpoweredItem.GetAllTierInfoByItemID(self.empoweredItemLink, self.overrideClassID);
	end

	return nil;
end

function AzeriteEmpowedItemDataSourceMixin:IsPowerSelected(powerID)
	if self.empoweredItemLocation then
		return C_AzeriteEmpoweredItem.IsPowerSelected(self.empoweredItemLocation, powerID);
	end

	if self.overrideSelectedPowersList then
		for tierIndex, overridePowerID in ipairs(self.overrideSelectedPowersList) do
			if overridePowerID == powerID then
				return true;
			end
		end
		return false;
	end

	return nil;
end

function AzeriteEmpowedItemDataSourceMixin:GetPowerSpellID(powerID)
	local azeritePowerInfo = C_AzeriteEmpoweredItem.GetPowerInfo(powerID);
	return azeritePowerInfo and azeritePowerInfo.spellID or nil;
end

function AzeriteEmpowedItemDataSourceMixin:IsFromEquipmentSlot(equipmentSlotIndex)
	return self.empoweredItemLocation and self.empoweredItemLocation:IsEquipmentSlot() and self.empoweredItemLocation:GetEquipmentSlot() == equipmentSlotIndex;
end

function AzeriteEmpowedItemDataSourceMixin:DidEquippedItemChange(equipmentSlotIndex)
	if self:IsFromEquipmentSlot(equipmentSlotIndex) then
		return self.item:GetItemGUID() ~= self.itemGUID;
	end

	return false;
end