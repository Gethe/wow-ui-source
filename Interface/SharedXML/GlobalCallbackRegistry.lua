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