local _addonName, addonTbl = ...;

local AuraButtonPrivateMixin = {};
addonTbl.AuraButtonPrivateMixin = AuraButtonPrivateMixin;

function AuraButtonPrivateMixin:OnLoad_Intrinsic()
	self.auraContainer = nil;
	self.auraData = nil;
	self.unitToken = nil;
end

function AuraButtonPrivateMixin:OnAuraInstanceAssigned(_unitToken, _auraData)
	-- Override in a derived mixin to be notified when this button should set
	-- up display for a new or potentially fully-updated aura instance.
end

function AuraButtonPrivateMixin:OnAuraInstanceUpdated(_unitToken, _auraData)
	-- Override in a derived mixin to be notified when this button should
	-- update its display for a pre-existing aura instance.
end

function AuraButtonPrivateMixin:OnAuraInstanceCleared()
	-- Override in a derived mixin to be notified when this button should no
	-- longer display an aura instance.
end

function AuraButtonPrivateMixin:GetAuraContainer()
	return self.auraContainer;
end

function AuraButtonPrivateMixin:HasAuraContainer()
	return self.auraContainer ~= nil;
end

function AuraButtonPrivateMixin:ClearAuraContainer()
	self:ClearAuraInstance();
	self.auraContainer = nil;
end

function AuraButtonPrivateMixin:SetAuraContainer(auraContainer)
	assert(self.auraContainer == nil, "attempted to assign an aura frame owned by another aura container");

	self.auraContainer = auraContainer;
	self:UpdateAuraDisplay();
end

function AuraButtonPrivateMixin:GetAuraInstance()
	return self.unitToken, self.auraData;
end

function AuraButtonPrivateMixin:HasAuraInstance()
	return self.auraData ~= nil;
end

function AuraButtonPrivateMixin:CanUpdateAuraInstance(newUnitToken, newAuraData)
	local oldUnitToken = self.unitToken;
	local oldAuraData = self.auraData;

	if not oldAuraData then
		-- No existing aura; new aura must be an assignment.
		return false;
	elseif oldUnitToken ~= newUnitToken or oldAuraData.auraInstanceID ~= newAuraData.auraInstanceID then
		-- Existing aura is for a different unit, or a different aura on the same unit.
		return false;
	end

	return true;
end

function AuraButtonPrivateMixin:SetAuraInstance(unitToken, auraData, isFullUpdate)
	if not isFullUpdate and self:CanUpdateAuraInstance(unitToken, auraData) then
		self.auraData = auraData;
		self:OnAuraInstanceUpdated(unitToken, auraData);
	else
		self.unitToken = unitToken;
		self.auraData = auraData;
		self:OnAuraInstanceAssigned(unitToken, auraData);
	end
end

function AuraButtonPrivateMixin:ClearAuraInstance()
	if self.auraData ~= nil then
		self.unitToken = nil;
		self.auraData = nil;
		self:OnAuraInstanceCleared();
	end
end

function AuraButtonPrivateMixin:UpdateAuraDisplay()
	-- Override in a derived mixin to apply a full update to the aura.
end

local AuraButtonInboundMixin = {};
addonTbl.AuraButtonInboundMixin = AuraButtonInboundMixin;

ApplySecureDelegatesToTable(AuraButtonInboundMixin);
