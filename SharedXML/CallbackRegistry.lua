CallbackRegistryMixin = {};

function CallbackRegistryMixin:OnLoad()
	self.closureRegistry = {};
	self.funcRegistry = {};
end

local function GetOrCreateTable(tbl, key)
	if not tbl[key] then
		tbl[key] = {};
	end
	return tbl[key];
end

function CallbackRegistryMixin:SetUndefinedEventsAllowed(allowed)
	self.isUndefinedEventAllowed = allowed;
end

function CallbackRegistryMixin:RegisterCallback(event, func, owner, ...)
	if not owner then
		error("CallbackRegistryMixin: An owner is required for a binding.")
	end

	self:UnregisterCallback(event, owner);

	local count = select("#", ...);
	if count > 0 then
		local entry = GetOrCreateTable(self.closureRegistry, event);
		entry[owner] = GenerateClosure(func, owner, ...);
	else
		local entry = GetOrCreateTable(self.funcRegistry, event);
		entry[owner] = func;
	end
end

function CallbackRegistryMixin:TriggerEvent(event, ...)
	if not event then
		error("CallbackRegistryMixin: event argument is nil.");
	end

	if not self.isUndefinedEventAllowed and not self.Event[event] then
		error(string.format("CallbackRegistryMixin: event %s doesn't exist.", event));
	end

	local closures = self.closureRegistry[event];
	if closures then
		for owner, closure in pairs(closures) do
			closure(...);
		end
	end
	
	local funcs = self.funcRegistry[event];
	if funcs then
		for owner, ptr in pairs(funcs) do
			ptr(owner, ...);
		end
	end
end

function CallbackRegistryMixin:UnregisterCallback(event, owner)
	if owner then
		local closures = self.closureRegistry[event];
		if closures and closures[owner] then
			closures[owner] = nil;
		end

		local funcs = self.funcRegistry[event];
		if funcs and funcs[owner] then
			funcs[owner] = nil;
		end
	else
		error("CallbackRegistryMixin:UnregisterCallback owner is nil.");
	end
end

function CallbackRegistryMixin:UnregisterAllCallbacksByEvent(event)
	self.closureRegistry[event] = {};
	self.funcRegistry[event] = {};
end

function CallbackRegistryMixin:UnregisterEvents(eventTbl)
	if eventTbl then
		for eventName in pairs(eventTbl) do
			self:UnregisterCallback(eventName);
		end
	else
		self.closureRegistry = {};
		self.funcRegistry = {};
	end	
end

function CallbackRegistryMixin:GenerateCallbackEvents(events)
	if not self.Event then
		self.Event = {};
	end

	for eventIndex, eventName in ipairs(events) do
		if self.Event[eventName] then
			error(string.format("CallbackRegistryMixin:GenerateCallbackEvents: event %s already exists.", eventName));
		end
		self.Event[eventName] = eventName;
	end
end