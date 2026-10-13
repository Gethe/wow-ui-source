local function CreatePrivateAuraUpdateCallback(callback)
	local registeredUnitToken = nil;
	local callbackContainer = C_FunctionContainers.CreateCallback(callback);
	local handle = {};

	function handle:Register(unitToken)
		self:Unregister();
		C_UnitAurasPrivate.AddPrivateAuraUpdateCallback(unitToken, callbackContainer);
		registeredUnitToken = unitToken;
	end

	function handle:Unregister()
		if registeredUnitToken then
			C_UnitAurasPrivate.RemovePrivateAuraUpdateCallback(registeredUnitToken, callbackContainer);
			registeredUnitToken = nil;
		end
	end

	return handle;
end

AuraContainerSharedMixin = {};

function AuraContainerSharedMixin:IsEnabled()
	return self.enabled == true;
end

function AuraContainerSharedMixin:SetEnabled(enabled)
	if self.enabled ~= enabled then
		self.enabled = enabled;
		self:UpdateEventRegistrations();
		self:UpdateAllAuras();
	end
end

function AuraContainerSharedMixin:GetUnit()
	return self.unitToken;
end

function AuraContainerSharedMixin:SetUnit(unitToken)
	assert(type(unitToken) == "string");

	if self.unitToken ~= unitToken then
		self.unitToken = unitToken;
		self:UpdateEventRegistrations();
		self:UpdateAllAuras();
	end
end

function AuraContainerSharedMixin:UpdateAllAuras()
	-- No-op; implement in a derived container to fully refresh the aura
	-- display. Exposed to allow external events to trigger refreshes where
	-- needed (e.g. target changes).
end

AuraContainerInboundMixin = CreateFromMixins(AuraContainerSharedMixin);
AuraContainerPrivateMixin = CreateFromMixins(AuraContainerSharedMixin);

function AuraContainerPrivateMixin:OnLoad_Intrinsic()
	local function OnPrivateAurasUpdated(unitAuraUpdateInfo)
		self:OnUnitPrivateAuraUpdate(self:GetUnit(), unitAuraUpdateInfo);
	end

	self.dynamicFrameEvents = {};
	self.dynamicUnitEvents = {};
	self.privateAurasUpdateCallback = CreatePrivateAuraUpdateCallback(OnPrivateAurasUpdated);

	FrameUtil.RegisterFrameForEvents(self, GetKeysArray(self:GetStaticFrameEvents()));
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
		local unitToken, unitAuraUpdateInfo = ...;
		self:OnUnitAuraUpdate(unitToken, unitAuraUpdateInfo);
	elseif event == "WEAPON_ENCHANT_CHANGED" then
		self:OnWeaponEnchantChanged();
	elseif event == "WEAPON_SLOT_CHANGED" then
		self:OnWeaponSlotChanged();
	elseif event == "AURA_DATA_PROVIDER_SWITCH" then
		local useRealDataProvider = ...;
		self:OnAuraDataProviderSwitch(useRealDataProvider);
	end
end

function AuraContainerPrivateMixin:OnUnitAuraUpdate(_unitToken, _unitAuraUpdateInfo)
	-- Implement processing in a derived mixin.
end

function AuraContainerPrivateMixin:OnUnitPrivateAuraUpdate(_unitToken, _unitAuraUpdateInfo)
	-- Implement processing in a derived mixin.
end

function AuraContainerPrivateMixin:OnAuraDataProviderSwitch(_useRealDataProvider)
	-- Implement in a derived mixin to be notified when data providers change.
end

function AuraContainerPrivateMixin:OnWeaponEnchantChanged()
	-- Implement processing in a derived mixin.
end

function AuraContainerPrivateMixin:OnWeaponSlotChanged()
	-- Implement processing in a derived mixin.
end

function AuraContainerPrivateMixin:ShouldRegisterForUnitAuraEvents()
	-- Override in a derived mixin to control registration of unit aura updates.
	return true;
end

function AuraContainerPrivateMixin:ShouldRegisterForPrivateAuraEvents()
	-- Override in a derived mixin to control registration of private aura updates.
	return true;
end

function AuraContainerPrivateMixin:ShouldRegisterForItemEnchantmentEvents()
	-- Override in a derived mixin to control registration of item enchantment updates.
	return false;
end

function AuraContainerPrivateMixin:GetStaticFrameEvents()
	local frameEvents = {};
	frameEvents["AURA_DATA_PROVIDER_SWITCH"] = true;
	return frameEvents;
end

function AuraContainerPrivateMixin:GetDynamicFrameEvents()
	local frameEvents = {};

	if self:ShouldRegisterForItemEnchantmentEvents() then
		frameEvents["WEAPON_ENCHANT_CHANGED"] = true;
		frameEvents["WEAPON_SLOT_CHANGED"] = true;
	end

	return frameEvents;
end

function AuraContainerPrivateMixin:GetDynamicUnitEvents()
	local unitEvents = {};

	if self:ShouldRegisterForUnitAuraEvents() then
		AuraContainerUtil.AddUnitEventRegistration(unitEvents, "UNIT_AURA", self:GetUnit());
	end

	return unitEvents;
end

function AuraContainerPrivateMixin:ShouldRegisterForDynamicEvents()
	return self:IsVisible() and self:IsEnabled();
end

function AuraContainerPrivateMixin:UpdateEventRegistrations()
	-- Current dynamic event lists should be unregistered first and then
	-- replaced with new registrations if we're allowed to enable them.

	FrameUtil.UnregisterFrameForEvents(self, GetKeysArray(self.dynamicFrameEvents));
	FrameUtil.UnregisterFrameForEvents(self, GetKeysArray(self.dynamicUnitEvents));
	self.privateAurasUpdateCallback:Unregister();

	if self:ShouldRegisterForDynamicEvents() then
		self.dynamicFrameEvents = self:GetDynamicFrameEvents();
		self.dynamicUnitEvents = self:GetDynamicUnitEvents();

		FrameUtil.RegisterFrameForEvents(self, GetKeysArray(self.dynamicFrameEvents));

		for event, unitTokens in pairs(self.dynamicUnitEvents) do
			self:RegisterUnitEvent(event, unpack(GetKeysArray(unitTokens)));
		end

		if self:ShouldRegisterForPrivateAuraEvents() then
			self.privateAurasUpdateCallback:Register(self:GetUnit());
		end
	else
		self.dynamicFrameEvents = {};
		self.dynamicUnitEvents = {};
	end
end
