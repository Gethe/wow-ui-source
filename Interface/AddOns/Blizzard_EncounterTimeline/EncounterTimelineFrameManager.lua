local INVALID_EVENT_ID = Constants.EncounterTimelineEventConstants.ENCOUNTER_TIMELINE_INVALID_EVENT;

EncounterTimelineFrameManagerMixin = {};

function EncounterTimelineFrameManagerMixin:OnLoad()
	self.eventFramesActive = {};
	self.eventFramesActiveCount = 0;
	self.eventFramesByInstanceID = {};
end

function EncounterTimelineFrameManagerMixin:OnEventFrameAcquired(_eventFrame, _eventID, _isNewObject)
	-- Override in a derived mixin to be notified when an event frame has been
	-- acquired from a frame pool.
end

function EncounterTimelineFrameManagerMixin:OnEventFrameDetached(_eventFrame, _eventID)
	-- Override in a derived mixin to be notified when an event frame has been
	-- detached as the "primary" frame for an event instance (eg. when we're
	-- starting to animate the frame out).
end

function EncounterTimelineFrameManagerMixin:OnEventFrameReleased(_eventFrame)
	-- Override in a derived mixin to be notified when an event frame about to
	-- be released into a pool.
end

function EncounterTimelineFrameManagerMixin:GetActiveEventFrameCount()
	return self.eventFramesActiveCount;
end

function EncounterTimelineFrameManagerMixin:GetEventFrame(eventID)
	return self.eventFramesByInstanceID[eventID];
end

function EncounterTimelineFrameManagerMixin:HasEventFrame(eventID)
	return self.eventFramesByInstanceID[eventID] ~= nil;
end

function EncounterTimelineFrameManagerMixin:GetEventFramePool(eventID)
	-- Override in a derived mixin to return a frame pool instance for a given
	-- event instance ID.

	assert(false, "GetEventFramePool must be implemented in a derived mixin.");
end

function EncounterTimelineFrameManagerMixin:IsEventFrameActive(eventFrame)
	return self.eventFramesActive[eventFrame] ~= nil;
end

function EncounterTimelineFrameManagerMixin:IsEventFrameAttached(eventFrame, eventID)
	return self.eventFramesActive[eventFrame] == eventID and self.eventFramesByInstanceID[eventID] == eventFrame;
end

function EncounterTimelineFrameManagerMixin:HasAnyActiveEventFrames()
	return next(self.eventFramesActive) ~= nil;
end

function EncounterTimelineFrameManagerMixin:EnumerateEventFrames()
	return pairs(self.eventFramesActive);
end

function EncounterTimelineFrameManagerMixin:AcquireEventFrame(eventID)
	local eventFrame = self:GetEventFrame(eventID);

	-- Acquiring event frames is an idempotent operation; if a frame is
	-- already assigned then yield it as-is.

	if eventFrame ~= nil then
		return eventFrame;
	end

	local eventFramePool = self:GetEventFramePool(eventID);
	local isNewObject;

	eventFrame, isNewObject = eventFramePool:Acquire();
	eventFrame:SetEventFrameManager(self);
	eventFrame:SetEventID(eventID);

	self.eventFramesActive[eventFrame] = eventID;
	self.eventFramesActiveCount = self.eventFramesActiveCount + 1;
	self.eventFramesByInstanceID[eventID] = eventFrame;

	self:OnEventFrameAcquired(eventFrame, eventID, isNewObject);
	return eventFrame;
end

function EncounterTimelineFrameManagerMixin:DetachEventFrame(eventFrame)
	local eventID = eventFrame:GetEventID();

	-- Detaching event frames is an idempotent operation; if no frame is
	-- presently attached then this is a no-op. Additionally, if this frame
	-- was already detached from its instance then do nothing.

	if eventID == nil or not self:IsEventFrameAttached(eventFrame, eventID) then
		return;
	end

	self:OnEventFrameDetached(eventFrame, eventID);
	self.eventFramesByInstanceID[eventID] = nil;
end

function EncounterTimelineFrameManagerMixin:DetachEventFrameByID(eventID)
	local eventFrame = self:GetEventFrame(eventID);

	if eventFrame then
		self:DetachEventFrame(eventFrame);
	end
end

function EncounterTimelineFrameManagerMixin:ReleaseEventFrame(eventFrame)
	-- Releasing event frames is asserted rather than idempotent - it shouldn't
	-- be the case that this function is ever called multiple times for a single
	-- event frame without an interceding Acquire.

	if not assertsafe(self:IsEventFrameActive(eventFrame), "attempted to release an inactive event frame") then
		return;
	end

	local eventID = eventFrame:GetEventID();
	self:DetachEventFrame(eventFrame);

	self.eventFramesActive[eventFrame] = nil;
	self.eventFramesActiveCount = self.eventFramesActiveCount - 1;
	self:OnEventFrameReleased(eventFrame);

	eventFrame:SetEventID(INVALID_EVENT_ID);
	eventFrame:SetEventFrameManager(nil);

	local eventFramePool = self:GetEventFramePool(eventID);
	eventFramePool:Release(eventFrame);
end

function EncounterTimelineFrameManagerMixin:ReleaseEventFrameByID(eventID)
	-- Unlike ReleaseEventFrame, this by-ID function is idempotent and will
	-- be a no-op if called with an event instance ID that we're not managing.

	local eventFrame = self:GetEventFrame(eventID);

	if eventFrame ~= nil then
		self:ReleaseEventFrame(eventFrame);
	end
end

function EncounterTimelineFrameManagerMixin:ReleaseAllEventFrames()
	repeat
		local eventFrame = next(self.eventFramesActive);

		if eventFrame ~= nil then
			self:ReleaseEventFrame(eventFrame);
		end
	until eventFrame == nil;
end
