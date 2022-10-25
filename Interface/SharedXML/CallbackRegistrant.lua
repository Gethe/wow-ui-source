
CallbackRegistrantMixin = {};

function CallbackRegistrantMixin:OnShow()
	for i, eventRegistrationInfo in ipairs(self:GetDynamicCallbackRegistrantHandlers()) do
		self:RegisterFromRegistrationInfo(eventRegistrationInfo);
	end
end

function CallbackRegistrantMixin:OnHide()
	self:UnregisterAllInternal(self:GetDynamicCallbackRegistrantHandlers());
end

function CallbackRegistrantMixin:AddEventMethodInternal(handlersTable, callbackRegistry, event, handlerMethod)
	local eventRegistrationInfo = self:CreateEventRegistrationInfo(callbackRegistry, event, handlerMethod)
	table.insert(handlersTable, eventRegistrationInfo);
	return eventRegistrationInfo;
end

function CallbackRegistrantMixin:AddDynamicEventMethod(callbackRegistry, event, handlerMethod)
	local eventRegistrationInfo = self:AddEventMethodInternal(self:GetDynamicCallbackRegistrantHandlers(), callbackRegistry, event, handlerMethod)

	if self:IsShown() then
		self:RegisterFromRegistrationInfo(eventRegistrationInfo);
	end
end

-- Routing calls here allows for future expansion in this template (i.e. checking duplicate registrations).
function CallbackRegistrantMixin:AddStaticEventMethod(callbackRegistry, event, handlerMethod)
	local eventRegistrationInfo = self:AddEventMethodInternal(self:GetStaticCallbackRegistrantHandlers(), callbackRegistry, event, handlerMethod)
	self:RegisterFromRegistrationInfo(eventRegistrationInfo);
end

function CallbackRegistrantMixin:RemoveStaticEventMethod(callbackRegistry, event, handlerMethod)
	local handlers = self:GetStaticCallbackRegistrantHandlers();
	for i, eventRegistrationInfo in ipairs(handlers) do
		if (eventRegistrationInfo.callbackRegistry == callbackRegistry) and (eventRegistrationInfo.event == event) then
			self:UnregisterFromRegistrationInfo(eventRegistrationInfo);
			table.remove(handlers, i);
			break;
		end
	end
end

function CallbackRegistrantMixin:UnregisterAllEventMethods()
	self:UnregisterAllInternal(self:GetDynamicCallbackRegistrantHandlers());
	self:UnregisterAllInternal(self:GetStaticCallbackRegistrantHandlers());
end

function CallbackRegistrantMixin:CreateEventRegistrationInfo(callbackRegistry, event, handlerMethod)
	return { callbackRegistry = callbackRegistry, event = event, handlerMethod = handlerMethod, registered = false, };
end

function CallbackRegistrantMixin:RegisterFromRegistrationInfo(eventRegistrationInfo)
	if eventRegistrationInfo.registered then
		return;
	end

	eventRegistrationInfo.callbackRegistry:RegisterCallback(eventRegistrationInfo.event, eventRegistrationInfo.handlerMethod, self);
	eventRegistrationInfo.registered = true;
end

function CallbackRegistrantMixin:UnregisterFromRegistrationInfo(eventRegistrationInfo)
	if not eventRegistrationInfo.registered then
		return;
	end

	eventRegistrationInfo.callbackRegistry:UnregisterCallback(eventRegistrationInfo.event, self);
	eventRegistrationInfo.registered = false;
end

function CallbackRegistrantMixin:UnregisterAllInternal(handlersTable)
	for i, eventRegistrationInfo in ipairs(handlersTable) do
		self:UnregisterFromRegistrationInfo(eventRegistrationInfo);
	end
end

function CallbackRegistrantMixin:GetDynamicCallbackRegistrantHandlers()
	self.callbackRegistrantHandlers = self.callbackRegistrantHandlers or {};
	return self.callbackRegistrantHandlers;
end

function CallbackRegistrantMixin:GetStaticCallbackRegistrantHandlers()
	self.staticCallbackRegistrantHandlers = self.staticCallbackRegistrantHandlers or {};
	return self.staticCallbackRegistrantHandlers;
end
