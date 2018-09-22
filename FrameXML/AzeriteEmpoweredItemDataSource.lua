AzeriteEmpoweredItemDataSourceMixin = {};
AzeriteEmpoweredItemDataSource = {};

function AzeriteEmpoweredItemDataSource:CreateEmpty()
	return CreateFromMixins(AzeriteEmpoweredItemDataSourceMixin);
end

function AzeriteEmpoweredItemDataSource:CreateFromItemLocation(empoweredItemLocation)
	local source = AzeriteEmpoweredItemDataSource:CreateEmpty();
	source:SetSourceFromItemLocation(empoweredItemLocation);
	return source;
end

function AzeriteEmpoweredItemDataSource:CreateFromFromItemLink(empoweredItemLink)
	local source = AzeriteEmpoweredItemDataSource:CreateEmpty();
	source:SetSourceFromItemLink(empoweredItemLink);
	return source;
end

function AzeriteEmpoweredItemDataSourceMixin:SetSourceFromItemLocation(empoweredItemLocation)
	self:Clear();
	self.empoweredItemLocation = empoweredItemLocation;
	self.item = Item:CreateFromItemLocation(self.empoweredItemLocation);
	self.itemGUID = self.item:GetItemGUID();
end

function AzeriteEmpoweredItemDataSourceMixin:SetSourceFromItemLink(empoweredItemLink, overrideClassID, overrideSelectedPowersList)
	self:Clear();
	self.empoweredItemLink = empoweredItemLink;
	self.overrideClassID = overrideClassID;
	self.overrideSelectedPowersList = overrideSelectedPowersList;
	self.item = Item:CreateFromItemLink(self.empoweredItemLink);
end

function AzeriteEmpoweredItemDataSourceMixin:Clear()
	self.empoweredItemLink = nil;
	self.empoweredItemLocation = nil;
	self.item = nil;
	self.itemGUID = nil;
	self.overrideClassID = nil;
	self.overrideSelectedPowersList = nil;
end

function AzeriteEmpoweredItemDataSourceMixin:IsValid()
	return self:GetValidationInfo() == AzeriteEmpoweredItemDataSourceMixin.VALIDATION_SUCCESS;
end

AzeriteEmpoweredItemDataSourceMixin.VALIDATION_SUCCESS = nil;
AzeriteEmpoweredItemDataSourceMixin.VALIDATION_EMPTY_ITEM = 1;
AzeriteEmpoweredItemDataSourceMixin.VALIDATION_NO_PREVIEW_FOR_CLASS = 2;
AzeriteEmpoweredItemDataSourceMixin.VALIDATION_MISSING_DATA = 3;

function AzeriteEmpoweredItemDataSourceMixin:GetValidationInfo()
	local item = self:GetItem();
	if not item or self:GetItem():IsItemEmpty() then
		return AzeriteEmpoweredItemDataSourceMixin.VALIDATION_EMPTY_ITEM;
	end

	if self.empoweredItemLink then
		if C_AzeriteEmpoweredItem.IsAzeritePreviewSourceDisplayable(self.empoweredItemLink, self.overrideClassID) then
			return AzeriteEmpoweredItemDataSourceMixin.VALIDATION_SUCCESS;
		end
		return AzeriteEmpoweredItemDataSourceMixin.VALIDATION_NO_PREVIEW_FOR_CLASS;
	end

	if #C_AzeriteEmpoweredItem.GetAllTierInfo(self.empoweredItemLocation) == 0 then
		return AzeriteEmpoweredItemDataSourceMixin.VALIDATION_MISSING_DATA;
	end

	return AzeriteEmpoweredItemDataSourceMixin.VALIDATION_SUCCESS;
end

function AzeriteEmpoweredItemDataSourceMixin:IsPreviewSource()
	return self.empoweredItemLocation == nil or not C_AzeriteItem.HasActiveAzeriteItem();
end

function AzeriteEmpoweredItemDataSourceMixin:GetItemLocation()
	return self.empoweredItemLocation;
end

function AzeriteEmpoweredItemDataSourceMixin:GetItem()
	return self.item;
end

function AzeriteEmpoweredItemDataSourceMixin:HasBeenViewed()
	if self:IsPreviewSource() then
		return true;
	end
	return C_AzeriteEmpoweredItem.HasBeenViewed(self.empoweredItemLocation);
end

function AzeriteEmpoweredItemDataSourceMixin:SetHasBeenViewed()
	if self:IsPreviewSource() then
		return;
	end
	return C_AzeriteEmpoweredItem.SetHasBeenViewed(self.empoweredItemLocation);
end

function AzeriteEmpoweredItemDataSourceMixin:GetAllTierInfo()
	if self.empoweredItemLocation then
		return C_AzeriteEmpoweredItem.GetAllTierInfo(self.empoweredItemLocation);
	elseif self.empoweredItemLink then
		return C_AzeriteEmpoweredItem.GetAllTierInfoByItemID(self.empoweredItemLink, self.overrideClassID);
	end

	return nil;
end

function AzeriteEmpoweredItemDataSourceMixin:IsPowerSelected(powerID)
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

function AzeriteEmpoweredItemDataSourceMixin:GetPowerSpellID(powerID)
	local azeritePowerInfo = C_AzeriteEmpoweredItem.GetPowerInfo(powerID);
	return azeritePowerInfo and azeritePowerInfo.spellID or nil;
end

function AzeriteEmpoweredItemDataSourceMixin:IsFromEquipmentSlot(equipmentSlotIndex)
	return self.empoweredItemLocation and self.empoweredItemLocation:IsEquipmentSlot() and self.empoweredItemLocation:GetEquipmentSlot() == equipmentSlotIndex;
end

function AzeriteEmpoweredItemDataSourceMixin:DidEquippedItemChange(equipmentSlotIndex)
	if self:IsFromEquipmentSlot(equipmentSlotIndex) then
		return self.item:GetItemGUID() ~= self.itemGUID;
	end

	return false;
end