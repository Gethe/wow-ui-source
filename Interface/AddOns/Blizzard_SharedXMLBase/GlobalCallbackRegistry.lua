EventRegistry = CreateFromMixins(CallbackRegistryMixin);

function EventRegistry:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	self:SetUndefinedEventsAllowed(true);

	self.frameEventFrame = CreateFrame("Frame");
	self.frameEventFrame:SetScript("OnEvent", function(frameEventFrame, event, ...)
		self:TriggerEvent(event, ...);
	end);

	self.frameEventFrame:SetScript("OnAttributeChanged", self.OnAttributeChanged);
	self.frameEventFrame.registry = self;
end

function EventRegistry:OnAttributeChanged(frameEvent, value)
	self = self.registry;

	if value == 0 then
		self.frameEventFrame:UnregisterEvent(frameEvent);
	elseif value == 1 then
		self.frameEventFrame:RegisterEvent(frameEvent);
	end
end

function EventRegistry:RegisterFrameEvent(frameEvent)
	self.frameEventFrame:SetAttribute(frameEvent, (self.frameEventFrame:GetAttribute(frameEvent) or 0) + 1);
end

function EventRegistry:UnregisterFrameEvent(frameEvent)
	local eventCount = self.frameEventFrame:GetAttribute(frameEvent) or 0;
	if eventCount > 0 then
		self.frameEventFrame:SetAttribute(frameEvent, eventCount - 1);
	end
end

function EventRegistry:RegisterFrameEventAndCallback(frameEvent, ...)
	self:RegisterFrameEvent(frameEvent);
	return self:RegisterCallback(frameEvent, ...);
end

local function CreateCallbackHandle(cbr, cbrHandle, frameEvent)
	-- Wrapped in a table for future flexibility.
	local handle = {
		Unregister = function()
			cbr:UnregisterFrameEvent(frameEvent);
			cbrHandle:Unregister();
		end,
	};
	return handle;
end


function EventRegistry:RegisterFrameEventAndCallbackWithHandle(frameEvent, ...)
	self:RegisterFrameEvent(frameEvent);
	local cbrHandle = self:RegisterCallbackWithHandle(frameEvent, ...);
	return CreateCallbackHandle(self, cbrHandle, frameEvent);
end

function EventRegistry:UnregisterFrameEventAndCallback(frameEvent, ...)
	self:UnregisterFrameEvent(frameEvent);
	self:UnregisterCallback(frameEvent, ...);
end

function EventRegistry:GetEventCounts(...)
	local counts = {};
	for i = 1, select("#", ...) do
		local frameEvent = select(i, ...);
		local count = self.frameEventFrame:GetAttribute(frameEvent) or "?";
		table.insert(counts, ("%s : %s"):format(frameEvent, tostring(count)));
	end

	return table.concat(counts, "\n");
end

EventRegistry:OnLoad();

-- Meant for use in secure outbound files.
function SecureOutboundUtil_TriggerEvent(event, ...)
	EventRegistry:TriggerEvent(event, ...);
end
