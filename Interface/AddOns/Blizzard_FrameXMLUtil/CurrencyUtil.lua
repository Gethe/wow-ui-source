
CurrencyCallbackRegistry = CreateFromMixins(CallbackRegistryMixin);
CurrencyCallbackRegistry:GenerateCallbackEvents(
	{
		"OnCurrencyDisplayUpdate",
	}
);

function CurrencyCallbackRegistry:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self.cachable = {};
	self.cvarValueCache = {};

	self:SetScript("OnEvent", self.OnEvent);

	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
end

function CurrencyCallbackRegistry:OnEvent(event, ...)
	if event == "CURRENCY_DISPLAY_UPDATE" then
		local currency = ...;
		local args = select(2, ...);

		self:TriggerEvent(CurrencyCallbackRegistry.Event.OnCurrencyDisplayUpdate, currency, args);
		self:TriggerEvent(tostring(currency), args);
	end
end

function CurrencyCallbackRegistry:RegisterCurrencyDisplayUpdateCallback(func, owner, ...)
	return self:RegisterCallback(CVarCallbackRegistry.Event.OnCurrencyDisplayUpdate, func, owner, ...);
end

CurrencyCallbackRegistry = Mixin(CreateFrame("Frame"), CurrencyCallbackRegistry);
CurrencyCallbackRegistry:OnLoad();
CurrencyCallbackRegistry:SetUndefinedEventsAllowed(true);
