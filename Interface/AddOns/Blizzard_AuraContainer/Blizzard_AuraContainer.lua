AuraContainerSharedMixin = {};

function AuraContainerSharedMixin:IsEnabled()
	return self.enabled == true;
end

function AuraContainerSharedMixin:SetEnabled(enabled)
	if self.enabled ~= enabled then
		self.enabled = enabled;
		self:OnEnabledChanged(enabled);
	end
end

function AuraContainerSharedMixin:GetUnit()
	return self.unitToken;
end

function AuraContainerSharedMixin:SetUnit(unitToken)
	assert(type(unitToken) == "string");

	if self.unitToken ~= unitToken then
		self.unitToken = unitToken;
		self:OnUnitChanged(unitToken);
	end
end

function AuraContainerSharedMixin:UpdateAllAuras()
	-- No-op; overridden by the private mixin to do actual work. Exposed to
	-- allow external events to trigger refreshes where needed (e.g. target
	-- changes).
end

AuraContainerInboundMixin = CreateFromMixins(AuraContainerSharedMixin);

AuraContainerPrivateMixin = CreateFromMixins(AuraContainerSharedMixin);
AuraContainerPrivateMixin.StaticEvents = { "AURA_DATA_PROVIDER_SWITCH" };
AuraContainerPrivateMixin.DynamicEvents = {};
AuraContainerPrivateMixin.DynamicUnitEvents = { "UNIT_AURA" };

function AuraContainerPrivateMixin:OnLoad_Intrinsic()
	self.privateAurasUpdateCallback = nil;
	self.privateAurasUnit = nil;

	FrameUtil.RegisterFrameForEvents(self, self.StaticEvents);
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
	elseif event == "AURA_DATA_PROVIDER_SWITCH" then
		local useRealDataProvider = ...;
		self:OnAuraDataProviderSwitch(useRealDataProvider);
	end
end

function AuraContainerPrivateMixin:OnUnitAuraUpdate(_unitAuraUpdateInfo)
	-- Implement processing in a derived mixin.
end

function AuraContainerPrivateMixin:OnUnitPrivateAuraUpdate(_unitAuraUpdateInfo)
	-- Implement processing in a derived mixin.
end

function AuraContainerPrivateMixin:OnAuraDataProviderSwitch(_useRealDataProvider)
	-- Implement in a derived mixin to be notified when data providers change.
end

function AuraContainerPrivateMixin:OnEnabledChanged(_enabled)
	self:UpdateEventRegistrations();
	self:UpdateAllAuras();
end

function AuraContainerPrivateMixin:OnUnitChanged(_unitToken)
	self:UpdateEventRegistrations();
	self:UpdateAllAuras();
end

function AuraContainerPrivateMixin:GetPrivateAuraUpdateCallback()
	if not self.privateAurasUpdateCallback then
		local function OnPrivateAurasUpdated(unitAuraUpdateInfo)
			self:OnUnitPrivateAuraUpdate(unitAuraUpdateInfo);
		end

		self.privateAurasUpdateCallback = C_FunctionContainers.CreateCallback(OnPrivateAurasUpdated);
	end

	return self.privateAurasUpdateCallback;
end

function AuraContainerPrivateMixin:IsRegisteredForPrivateAuras()
	return self.privateAurasUnit ~= nil;
end

function AuraContainerPrivateMixin:RegisterForPrivateAuras()
	self:UnregisterForPrivateAuras();

	self.privateAurasUnit = self:GetUnit();
	C_UnitAurasPrivate.AddPrivateAuraUpdateCallback(self.privateAurasUnit, self:GetPrivateAuraUpdateCallback());
end

function AuraContainerPrivateMixin:UnregisterForPrivateAuras()
	if self:IsRegisteredForPrivateAuras() then
		C_UnitAurasPrivate.RemovePrivateAuraUpdateCallback(self.privateAurasUnit, self:GetPrivateAuraUpdateCallback());
		self.privateAurasUnit = nil;
	end
end

function AuraContainerPrivateMixin:ShouldRegisterForPrivateAuras()
	return self.privateAurasEnabled;
end

function AuraContainerPrivateMixin:SetPrivateAurasEnabled(enabled)
	enabled = (enabled == true);

	if enabled ~= self.privateAurasEnabled then
		self.privateAurasEnabled = enabled;
		self:UpdateEventRegistrations();
	end
end

function AuraContainerPrivateMixin:ShouldRegisterForEvents()
	return self:IsVisible() and self:IsEnabled();
end

function AuraContainerPrivateMixin:UpdateEventRegistrations()
	self:UnregisterForPrivateAuras();

	if self:ShouldRegisterForEvents() then
		FrameUtil.RegisterFrameForEvents(self, self.DynamicEvents);
		FrameUtil.RegisterFrameForUnitEvents(self, self.DynamicUnitEvents, self:GetUnit());

		if self:ShouldRegisterForPrivateAuras() then
			self:RegisterForPrivateAuras();
		end
	else
		FrameUtil.UnregisterFrameForEvents(self, self.DynamicEvents);
		FrameUtil.UnregisterFrameForEvents(self, self.DynamicUnitEvents);
	end
end
