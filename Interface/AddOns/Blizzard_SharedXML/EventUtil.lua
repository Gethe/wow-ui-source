
EventUtil = {};

local ContinueAfterAllEventsMixin = {};

function ContinueAfterAllEventsMixin:Init(callback, ...)
	self.events = {};

	local count = select("#", ...);
	for index = 1, count do
		local event = select(index, ...);
		assert(C_EventUtils.IsEventValid(event), ("Unknown event \"%s\""):format(event));
		self.events[event] = false;

		local function OnEventReceived()
			self.events[event] = true;

			EventRegistry:UnregisterFrameEventAndCallback(event, self);

			if self:HaveReceivedAllEvents() then
				callback();
			end
		end

		EventRegistry:RegisterFrameEventAndCallback(event, OnEventReceived, self);
	end
end

function ContinueAfterAllEventsMixin:HaveReceivedAllEvents()
	for event, received in pairs(self.events) do
		if not received then
			return false;
		end
	end
	return true;
end

function EventUtil.ContinueAfterAllEvents(callback, ...)
	local obj = CreateFromMixins(ContinueAfterAllEventsMixin);
	obj:Init(callback, ...);
end

function EventUtil.ContinueOnVariablesLoaded(callback)
	if GlueParent or (UIParent and UIParent.variablesLoaded) then
		callback();
		return;
	end

	EventUtil.ContinueAfterAllEvents(callback, "VARIABLES_LOADED");
end

function EventUtil.ContinueOnAddOnLoaded(addOnName, callback)
	local isLoadedOrLoading, isLoaded = C_AddOns.IsAddOnLoaded(addOnName);
	if isLoaded then
		callback();
		return;
	end

	EventUtil.RegisterOnceFrameEventAndCallback("ADDON_LOADED", callback, addOnName);
end

-- ... are optional event arguments that are required to match before the callback is invoked.
function EventUtil.RegisterOnceFrameEventAndCallback(frameEvent, callback, ...)
	local handle = nil;
	local requiredEventArgs = SafePack(...);
	local CallbackWrapper = function(callbackHandlerID, ...)
		for i = 1, requiredEventArgs.n do
			if select(i, ...) ~= requiredEventArgs[i] then
				return;
			end
		end

		handle:Unregister();
		callback(...);
	end

	handle = EventRegistry:RegisterFrameEventAndCallbackWithHandle(frameEvent, CallbackWrapper);
end

CallbackHandleContainerMixin = {};

function CallbackHandleContainerMixin:Init()
	self.handles = {};
end

-- Accepts any CBR and stores a handle to the registered callback.
function CallbackHandleContainerMixin:RegisterCallback(cbr, event, callback, owner)
	self:AddHandle(cbr:RegisterCallbackWithHandle(event, callback, owner));
end

function CallbackHandleContainerMixin:AddHandle(handle)
	table.insert(self.handles, handle);
end

function CallbackHandleContainerMixin:Unregister()
	for index, handle in ipairs(self.handles) do
		handle:Unregister();
	end
	self.handles = {};
end

function CallbackHandleContainerMixin:IsEmpty()
	return #self.handles == 0;
end

function EventUtil.CreateCallbackHandleContainer()
	local cbrHandles = CreateFromMixins(CallbackHandleContainerMixin);
	cbrHandles:Init();
	return cbrHandles;
end
