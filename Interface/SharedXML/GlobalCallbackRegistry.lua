EventRegistry = CreateFromMixins(CallbackRegistryMixin);

function EventRegistry:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	self:SetUndefinedEventsAllowed(true);

	self.frameEventRefCounts = {};

	self.frameEventFrame = CreateFrame("Frame");
	self.frameEventFrame:SetScript("OnEvent", function(frameEventFrame, event, ...)
		self:TriggerEvent(event, ...);
	end);

	self.frameEventFrame:SetScript("OnAttributeChanged", self.OnAttributeChanged);
	self.frameEventFrame.registry = self;
end

function EventRegistry:OnAttributeChanged(frameEvent, value)
	self = self.registry;
	self.frameEventRefCounts[frameEvent] = (self.frameEventRefCounts[frameEvent] or 0) + value;

	if self.frameEventRefCounts[frameEvent] == 0 then
		self.frameEventFrame:UnregisterEvent(frameEvent);
	end
end

function EventRegistry:RegisterFrameEvent(frameEvent)
	self.frameEventFrame:SetAttribute(frameEvent, 1);
	self.frameEventFrame:RegisterEvent(frameEvent);
end

function EventRegistry:UnregisterFrameEvent(frameEvent)
	if self.frameEventRefCounts[frameEvent] ~= nil then
		self.frameEventFrame:SetAttribute(frameEvent, -1);
	end
end

EventRegistry:OnLoad();