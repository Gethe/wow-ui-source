EventRegistry = CreateFromMixins(CallbackRegistryMixin);
EventRegistry:OnLoad();
EventRegistry:SetUndefinedEventsAllowed(true);

function EventRegistry:RegisterFrameEvent(frameEvent)
	if not self.frameEventRefCounts then
		self.frameEventRefCounts = {};
	end

	self.frameEventRefCounts[frameEvent] = (self.frameEventRefCounts[frameEvent] or 0) + 1;

	if not self.frameEventFrame then
		self.frameEventFrame = CreateFrame("Frame");
		self.frameEventFrame:SetScript("OnEvent", function(frameEventFrame, event, ...)
			self:TriggerEvent(event, ...);
		end);
	end

	self.frameEventFrame:RegisterEvent(frameEvent);
end

function EventRegistry:UnregisterFrameEvent(frameEvent)
	if self.frameEventRefCounts and self.frameEventRefCounts[frameEvent] ~= nil then
		local refCount = self.frameEventRefCounts[frameEvent];
		if refCount > 0 then
			refCount = refCount - 1;
			self.frameEventRefCounts[frameEvent] = refCount;

			if refCount == 0 and self.frameEventFrame then
				self.frameEventFrame:UnregisterEvent(frameEvent);
			end
		end
	end
end