ShoppingCartServiceRegistrantMixin = CreateFromMixins(CallbackRegistrantMixin);

function ShoppingCartServiceRegistrantMixin:AddServiceEvents(services)
	if not self.Events then
		self.Events = {};
	end

	for eventName, event in pairs(services) do
		if self[eventName] then
			self.Events[eventName] = self.eventNamespace.."."..event;
			self:AddStaticEventMethod(EventRegistry, self.Events[eventName], self[eventName]);
		end
	end
end

ShoppingCartServiceButtonMixin = {};

function ShoppingCartServiceButtonMixin:BaseService_OnClick()
	local data = self:GetEventData();
	local event = self.eventNamespace.."."..self.serviceName;

	EventRegistry:TriggerEvent(event, data);
end

function ShoppingCartServiceButtonMixin:GetEventData()
	-- Override in derived button
	return nil;
end
