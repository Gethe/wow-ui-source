local _addonName, addonTbl = ...;

local AuraContainerPrivateMixin = {};
addonTbl.AuraContainerPrivateMixin = AuraContainerPrivateMixin;

AuraContainerPrivateMixin.DynamicEvents = {};
AuraContainerPrivateMixin.DynamicUnitEvents = { "UNIT_AURA" };

function AuraContainerPrivateMixin:OnLoad_Intrinsic()
	-- No-op; reserved for future needs.
end

function AuraContainerPrivateMixin:OnShow_Intrinsic()
	self:UpdateEventRegistrations();
	self:UpdateAllAuras();
end

function AuraContainerPrivateMixin:OnHide_Intrinsic()
	self:UpdateEventRegistrations();
	self:UpdateAllAuras();
end

function AuraContainerPrivateMixin:OnEvent_Intrinsic(event, ...)
	if event == "UNIT_AURA" then
		local _unitToken, unitAuraUpdateInfo = ...;
		self:OnUnitAuraUpdate(unitAuraUpdateInfo);
	end
end

function AuraContainerPrivateMixin:OnUnitAuraUpdate(_unitAuraUpdateInfo)
	-- Implement processing in a derived mixin.
end

function AuraContainerPrivateMixin:OnEnabledChanged(_enabled)
	self:UpdateEventRegistrations();
	self:UpdateAllAuras();
end

function AuraContainerPrivateMixin:OnUnitChanged(_unitToken)
	self:UpdateEventRegistrations();
	self:UpdateAllAuras();
end

function AuraContainerPrivateMixin:ShouldRegisterForEvents()
	return self:IsVisible() and self:IsEnabled();
end

function AuraContainerPrivateMixin:UpdateEventRegistrations()
	if self:ShouldRegisterForEvents() then
		FrameUtil.RegisterFrameForEvents(self, self.DynamicEvents);
		FrameUtil.RegisterFrameForUnitEvents(self, self.DynamicUnitEvents, self:GetUnit());
	else
		FrameUtil.UnregisterFrameForEvents(self, self.DynamicEvents);
		FrameUtil.UnregisterFrameForEvents(self, self.DynamicUnitEvents);
	end
end

function AuraContainerPrivateMixin:UpdateAllAuras()
	-- Implement in a derived mixin.
end

local AuraContainerInboundMixin = {};
addonTbl.AuraContainerInboundMixin = AuraContainerInboundMixin;

function AuraContainerInboundMixin:IsEnabled()
	return self.enabled == true;
end

function AuraContainerInboundMixin:SetEnabled(enabled)
	if self.enabled ~= enabled then
		self.enabled = enabled;
		self:OnEnabledChanged(enabled);
	end
end

function AuraContainerInboundMixin:GetUnit()
	return self.unitToken;
end

function AuraContainerInboundMixin:SetUnit(unitToken)
	assert(type(unitToken) == "string");

	if self.unitToken ~= unitToken then
		self.unitToken = unitToken;
		self:OnUnitChanged(unitToken);
	end
end

function AuraContainerInboundMixin:UpdateAllAuras()
	-- No-op; overridden by the private mixin to do actual work. Exposed to
	-- allow external events to trigger refreshes where needed (e.g. target
	-- changes).
end

ApplySecureDelegatesToTable(AuraContainerInboundMixin);
