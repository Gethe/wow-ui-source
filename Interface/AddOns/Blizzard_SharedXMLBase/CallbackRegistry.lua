
local secureexecuterange = secureexecuterange;
local securecallfunction = securecallfunction;
local unpack = unpack;
local error = error;
local pairs = pairs;
local rawset = rawset;
local next = next;
local GetOrCreateTableEntry = GetOrCreateTableEntry;

local CallbackType = EnumUtil.MakeEnum("Closure", "Function");

local function IsCallbackTypeValid(callbackType)
	return callbackType == CallbackType.Closure or callbackType == CallbackType.Function;
end

-- Callbacks can be registered without an owner as a matter of convenience. Generally this is fine when you never
-- intend to release the callback.
local generateOwnerID = CreateCounter();

local InsertEventAttribute = "insert-secure-event";
local CreateDeferredCallbackAttribute = "create-deferred-callback";
local CreateDeferredCallbackResultAttribute = "create-deferred-callback-result";
local AttributeDelegate = CreateFrame("FRAME");
AttributeDelegate:SetForbidden();
AttributeDelegate:SetScript("OnAttributeChanged", function(self, attribute, value)
	if attribute == InsertEventAttribute then
		local registry, event = securecallfunction(unpack, value);
		if type(event) ~= "string" then
			error("CallbackRegistry InsertEventAttribute 'event' requires string type.")
		end
		for callbackType, callbackTable in pairs(registry:GetCallbackTables()) do
			if not callbackTable[event] then
				rawset(callbackTable, event, {});
			end
		end
	elseif attribute == CreateDeferredCallbackAttribute then
		local registry, event, callbackType = securecallfunction(unpack, value);
		if type(event) ~= "string" then
			error("CallbackRegistry CreateDeferredCallbackAttribute 'event' requires string type.")
		end
		if not IsCallbackTypeValid(callbackType) then
			error("CallbackRegistry CreateDeferredCallbackAttribute 'callbackType' is invalid.")
		end
		local deferrals = GetOrCreateTableEntry(registry.deferredCallbacks, event);
		local callbacks = GetOrCreateTableEntry(deferrals, callbackType);
		AttributeDelegate:SetAttribute(CreateDeferredCallbackResultAttribute, callbacks);
	end
end);


CallbackRegistryMixin = {};

function CallbackRegistryMixin:OnLoad()
	local callbackTables = {};
	for callbackType, value in pairs(CallbackType) do
		local callbacks = {};
		callbackTables[value] = callbacks;
	end
	self.callbackTables = callbackTables;

	self.executingEvents = {};
	self.deferredCallbacks = {};
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

-- Returns either the underlying callback table or a temporary table depending
-- on if the event is currently being dispatched. The callbacks stored in the
-- temporary table will be merged into the underlying callback table after the
-- dispatch is complete.
function CallbackRegistryMixin:GetMutableCallbacksByEvent(callbackType, event)
	if securecallfunction(rawget, self.executingEvents, event) == nil then
		return self:GetCallbacksByEvent(callbackType, event);
	end

	AttributeDelegate:SetAttribute(CreateDeferredCallbackAttribute, {self, event, callbackType});
	return AttributeDelegate:GetAttribute(CreateDeferredCallbackResultAttribute);
end

function CallbackRegistryMixin:HasRegistrantsForEvent(event)
	for callbackType, callbackTable in pairs(self:GetCallbackTables()) do
		local callbacks = callbackTable[event];
		if callbacks and securecallfunction(next, callbacks) then
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
	else
		if owner == nil then
			owner = generateOwnerID();
		elseif type(owner) == "number" then
			error("CallbackRegistryMixin:RegisterCallback 'owner' as number is reserved internally.")
		end
	end

	-- Taint barrier for inserting event key into callback tables.
	self:SecureInsertEvent(event);

	-- An owner can have a single callback per event. The simpliest way to ensure
	-- this is to remove all callbacks for the owner prior to new registration.
	self:UnregisterCallback(event, owner);
	
	local count = select("#", ...);
	if count > 0 then
		local callbacks = self:GetMutableCallbacksByEvent(CallbackType.Closure, event);
		callbacks[owner] = GenerateClosure(func, owner, ...);
	else
		local callbacks = self:GetMutableCallbacksByEvent(CallbackType.Function, event);
		callbacks[owner] = func;
	end

	return owner;
end

local function CreateCallbackHandle(cbr, event, owner)
	-- Wrapped in a table for future flexibility.
	local handle = 
	{
		Unregister = function()
			cbr:UnregisterCallback(event, owner);
		end,
	};
	return handle;
end

function CallbackRegistryMixin:RegisterCallbackWithHandle(event, func, owner, ...)
	owner = self:RegisterCallback(event, func, owner, ...);
	return CreateCallbackHandle(self, event, owner);
end

function CallbackRegistryMixin:ReconcileDeferredCallbacks(event, closures, funcs)
	self:CopyDeferredCallbacks(CallbackType.Closure, event, closures);
	self:CopyDeferredCallbacks(CallbackType.Function, event, funcs);
	self.deferredCallbacks[event] = nil;
end

function CallbackRegistryMixin:CopyDeferredCallbacks(callbackType, event, target)
	local deferrals = self.deferredCallbacks[event];
	if deferrals == nil then
		return;
	end

	local callbacks = deferrals[callbackType];
	if callbacks == nil then
		return;
	end

	local function ExecuteAssignCallback(owner, callback)
		target[owner] = callback;
	end

	secureexecuterange(callbacks, ExecuteAssignCallback);
end

function CallbackRegistryMixin:TriggerEvent(event, ...)
	if type(event) ~= "string" then
		error("CallbackRegistryMixin:TriggerEvent 'event' requires string type.");
	elseif not self.isUndefinedEventAllowed and not self.Event[event] then
		error(string.format("CallbackRegistryMixin:TriggerEvent event '%s' doesn't exist.", event));
	end

	-- TriggerEvent appears to need to support reentrant calls for now.
	local count = (self.executingEvents[event] or 0) + 1;

	-- Set before invoking any callback so a reentrant call does not
	-- attempt to call ReconcileDeferredCallbacks.
	self.executingEvents[event] = count;

	local closures = self:GetCallbacksByEvent(CallbackType.Closure, event);
	if closures then
		local function ExecuteClosurePair(owner, closure, ...)
			securecallfunction(closure, ...);
		end

		secureexecuterange(closures, ExecuteClosurePair, ...);
	end

	local funcs = self:GetCallbacksByEvent(CallbackType.Function, event);
	if funcs then
		local function ExecuteOwnerPair(owner, func, ...)
			securecallfunction(func, owner, ...);
		end

		secureexecuterange(funcs, ExecuteOwnerPair, ...);
	end

	-- The local count is the only value we care about for the purpose
	-- of flushing the event key and reconciling the deferred callbacks.
	if count == 1 then
		self.executingEvents[event] = nil;

		self:ReconcileDeferredCallbacks(event, closures, funcs);
	end
end

function CallbackRegistryMixin:UnregisterCallback(event, owner)
	if type(event) ~= "string" then
		error("CallbackRegistryMixin:UnregisterCallback 'event' requires string type.");
	elseif owner == nil then
		error("CallbackRegistryMixin:UnregisterCallback 'owner' is required.");
	end

	for callbackType, callbackTable in pairs(self:GetCallbackTables()) do
		-- Only assign nil if the owner is present in the table, otherwise
		-- its insertion could cause a rehash during iteration by secureexecuterange.
		local callbacks = callbackTable[event];
		if callbacks and callbacks[owner] then
			callbacks[owner] = nil;
		end
	end

	local deferrals = self.deferredCallbacks[event];
	if deferrals then
		for callbackType, callbacks in pairs(deferrals) do
			-- Freely assign nil because deferredCallbacks are not subject
			-- to secureexecuterange table mutilation stress disorder.
			callbacks[owner] = nil;
		end
	end
end

function CallbackRegistryMixin:UnregisterEvents()
	for callbackType, callbackTable in pairs(self:GetCallbackTables()) do
		wipe(callbackTable);
	end
end

function CallbackRegistryMixin:UnregisterEventsByEventTable(eventTable)
	if type(eventTable) ~= "table" then
		error("CallbackRegistryMixin:UnregisterEventsByEventTable 'eventTable' requires table type.");
	end

	for callbackType, callbackTable in pairs(self:GetCallbackTables()) do
		for event in pairs(eventTable) do
			callbackTable[event] = nil;
		end
	end
end

function CallbackRegistryMixin:GenerateCallbackEvents(eventTable)
	if not self.Event then
		self.Event = {};
	end

	if type(eventTable) ~= "table" then
		error("CallbackRegistryMixin:GenerateCallbackEvents 'eventTable' requires table type.");
	end

	for eventIndex, eventName in ipairs(eventTable) do
		if self.Event[eventName] then
			error(string.format("CallbackRegistryMixin:GenerateCallbackEvents: event '%s' already exists.", eventName));
		end
		self.Event[eventName] = eventName;
	end
end

function CallbackRegistryMixin.DoesFrameHaveEvent(frame, event)
	return frame.Event and frame.Event[event];
end
