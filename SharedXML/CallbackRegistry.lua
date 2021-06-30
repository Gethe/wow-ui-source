local next = next;
local securecall = securecall;
local unpack = unpack;
local error = error;

local function SecureNext(elements, key)
    return securecall(next, elements, key);
end

local function SecureInvoke(func, ...)
	if type(func) ~= "function" then
        error("SecureInvoke 'func' requires function type.");
    end
    securecall(func, ...);
end

local InsertEventAttribute = "insert-secure-event";
local AttributeDelegate = CreateFrame("FRAME");
AttributeDelegate:SetForbidden();
AttributeDelegate:SetScript("OnAttributeChanged", function(self, attribute, value)
	if attribute == InsertEventAttribute then
		local registry, event = securecall(unpack, value);
		if type(event) ~= "string" then
			error("AttributeDelegate OnAttributeChanged 'event' requires string type.")
		end
		for callbackType, callbackTable in pairs(registry:GetCallbackTables()) do
			if not callbackTable[event] then
				rawset(callbackTable, event, {});
			end
		end
	end
end);

local CallbackType = EnumUtil.MakeEnum("Closure", "Function");

CallbackRegistryMixin = {};

function CallbackRegistryMixin:OnLoad()
	local callbackTables = {};
	for callbackType, value in pairs(CallbackType) do
		callbackTables[value] = {};
	end
	self.callbackTables = callbackTables;
end

function CallbackRegistryMixin:SetUndefinedEventsAllowed(allowed)
	self.isUndefinedEventAllowed = allowed;
end

function CallbackRegistryMixin:GetCallbackTables()
	return self.callbackTables;
end

function CallbackRegistryMixin:GetCallbackTable(callbackType)
	return self.callbackTables[callbackType];
end

function CallbackRegistryMixin:GetCallbacksByEvent(callbackType, event)
	local callbackTable = self:GetCallbackTable(callbackType);
	return callbackTable[event];
end

function CallbackRegistryMixin:HasRegistrantsForEvent(event)
	for callbackType, callbackTable in pairs(self:GetCallbackTables()) do
		if callbackTable[event] then
			return true;
		end
	end
	return false;
end

function CallbackRegistryMixin:SecureInsertEvent(event)
	if not self:HasRegistrantsForEvent(event) then
		AttributeDelegate:SetAttribute(InsertEventAttribute, {self, event});
	end
end

function CallbackRegistryMixin:RegisterCallback(event, func, owner, ...)
	if type(event) ~= "string" then
		error("CallbackRegistryMixin::RegisterCallback 'event' requires string type.");
	elseif type(func) ~= "function" then
		error("CallbackRegistryMixin::RegisterCallback 'func' requires function type.");
	elseif not owner then
		error("CallbackRegistryMixin:RegisterCallback 'owner' is required.")
	end

	-- Taint barrier for inserting event key into callback tables.
	self:SecureInsertEvent(event);

	for callbackType, callbackTable in pairs(self:GetCallbackTables()) do
		local callbacks = callbackTable[event];
		callbacks[owner] = nil;
	end

	local count = select("#", ...);
	if count > 0 then
		local callbacks = self:GetCallbacksByEvent(CallbackType.Closure, event);
		callbacks[owner] = GenerateClosure(func, owner, ...);
	else
		local callbacks = self:GetCallbacksByEvent(CallbackType.Function, event);
		callbacks[owner] = func;
	end
end

function CallbackRegistryMixin:TriggerEvent(event, ...)
	if type(event) ~= "string" then
		error("CallbackRegistryMixin:TriggerEvent 'event' requires string type.");
	elseif not self.isUndefinedEventAllowed and not self.Event[event] then
		error(string.format("CallbackRegistryMixin:TriggerEvent event '%s' doesn't exist.", event));
	end

	local closures = self:GetCallbacksByEvent(CallbackType.Closure, event);
	if closures then
		for owner, closure in SecureNext, closures do
			SecureInvoke(closure, ...);
		end
	end

	local funcs = self:GetCallbacksByEvent(CallbackType.Function, event);
	if funcs then
		for owner, func in SecureNext, funcs do
			SecureInvoke(func, owner, ...);
		end
	end
end

function CallbackRegistryMixin:UnregisterCallback(event, owner)
	if type(event) ~= "string" then
		error("CallbackRegistryMixin:UnregisterCallback 'event' requires string type.");
	elseif not owner then
		error("CallbackRegistryMixin:UnregisterCallback 'owner' is required.");
	end

	for callbackType, callbackTable in pairs(self:GetCallbackTables()) do
		local callbacks = callbackTable[event];
		if callbacks then
			callbacks[owner] = nil;
		end
	end
end

function CallbackRegistryMixin:UnregisterEvents(eventTable)
	if eventTable then
		for callbackType, callbackTable in pairs(self:GetCallbackTables()) do
			for event in pairs(eventTable) do
				if callbackTable[event] then
					callbackTable[event] = nil;
				end
			end
		end
	else
		for callbackType, callbackTable in pairs(self:GetCallbackTables()) do
			wipe(callbackTable);
		end
	end	
end

function CallbackRegistryMixin:GenerateCallbackEvents(events)
	if not self.Event then
		self.Event = {};
	end
	
	for eventIndex, eventName in ipairs(events) do
		if self.Event[eventName] then
			error(string.format("CallbackRegistryMixin:GenerateCallbackEvents: event '%s' already exists.", eventName));
		end
		self.Event[eventName] = eventName;
	end
end