EncounterTimelineControllerDynamicEvents = {
	"ENCOUNTER_TIMELINE_EVENT_ADDED",
	"ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED",
	"ENCOUNTER_TIMELINE_EVENT_TRACK_CHANGED",
	"ENCOUNTER_TIMELINE_EVENT_BLOCK_STATE_CHANGED",
	"ENCOUNTER_TIMELINE_EVENT_HIGHLIGHT",
	"ENCOUNTER_TIMELINE_EVENT_REMOVED",
	"ENCOUNTER_TIMELINE_LAYOUT_UPDATED",
};

EncounterTimelineControllerMixin = {};

function EncounterTimelineControllerMixin:OnLoad()
	self.tracksByID = {};
	self.tracksByIndex = {};

	self.primaryAxisPaddingStart = EncounterTimelineLayoutDefaults.PrimaryAxisStartPadding
	self.primaryAxisPaddingEnd = EncounterTimelineLayoutDefaults.PrimaryAxisEndPadding;
	self.sortedEventExtent = EncounterTimelineLayoutDefaults.SortedEventExtent;

	-- Primary axis extent is calculated dynamically.

	self.primaryAxisExtent = 0;

	-- Start in a dirty state as our defaults may be non-zero, meaning that
	-- our primary axis extent as initialized is almost certainly wrong.

	self.layoutDirty = true;

	self.eventFramePools = CreateFramePoolCollection();
	self.eventFrames = {};
	self.eventFramesActive = {};
	self.eventInstances = {};

	-- Technically we could register _all_ the templates here, but leave
	-- that to the view - it knows what it wants.

	self:RegisterEventFrameTemplate("Frame", "EncounterTimelineViewElementTemplate");
end

function EncounterTimelineControllerMixin:OnShow()
	-- Load-bearing call order here; track list needs updating first to sync
	-- it with the C API, then from that flush an immediate layout to get
	-- our calculated offsets, and then we can add all the existing events
	-- in with the correct data.

	self:UpdateTrackList();
	self:UpdateLayout();
	self:AddAllEvents(EncounterTimelineUtil.GetEventInfoList());

	FrameUtil.RegisterFrameForEvents(self, EncounterTimelineControllerDynamicEvents);
end

function EncounterTimelineControllerMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, EncounterTimelineControllerDynamicEvents);
	self:RemoveAllEvents();
end

function EncounterTimelineControllerMixin:OnEvent(event, ...)
	if event == "ENCOUNTER_TIMELINE_EVENT_ADDED" then
		local eventInfo = ...;
		self:AddEvent(eventInfo);
	elseif event == "ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED" then
		local eventID = ...;
		self:UpdateEventState(eventID);
	elseif event == "ENCOUNTER_TIMELINE_EVENT_TRACK_CHANGED" then
		local eventID = ...;
		self:UpdateEventTrack(eventID);
	elseif event == "ENCOUNTER_TIMELINE_EVENT_BLOCK_STATE_CHANGED" then
		local eventID = ...;
		self:UpdateEventBlockedState(eventID);
	elseif event == "ENCOUNTER_TIMELINE_EVENT_HIGHLIGHT" then
		local eventID = ...;
		self:HighlightEvent(eventID);
	elseif event == "ENCOUNTER_TIMELINE_EVENT_REMOVED" then
		local eventID = ...;
		self:RemoveEvent(eventID);
	elseif event == "ENCOUNTER_TIMELINE_LAYOUT_UPDATED" then
		self:UpdateTrackList();
	end
end

function EncounterTimelineControllerMixin:OnUpdate(elapsedTime)
	if self:IsLayoutDirty() then
		self:UpdateLayout();
	end

	for eventFrame in self:EnumerateEventFrames() do
		eventFrame:OnUpdate(elapsedTime);
	end
end

function EncounterTimelineControllerMixin:OnTracksUpdated()
	-- Override to be notified when track data has been modified.
end

function EncounterTimelineControllerMixin:OnLayoutUpdated()
	-- Override to run any logic after layout has been recalculated.
end

function EncounterTimelineControllerMixin:OnEventAdded(_eventInfo)
	-- Override in a derived mixin to run logic when an event instance has
	-- been added.
end

function EncounterTimelineControllerMixin:OnEventRemoved(_eventID_)
	-- Override in a derived mixin to run logic when an event instance has
	-- been removed.
end

function EncounterTimelineControllerMixin:OnEventFrameAcquired(_eventFrame, _isNewObject)
	-- Override in a derived mixin to run logic after an event has been
	-- initially anchored but before the Init method has been invoked (and
	-- while the frame is still hidden).
end

function EncounterTimelineControllerMixin:OnEventFrameInitialized(_eventFrame, _isNewObject)
	-- Override in a derived mixin to run logic after an event has been
	-- acquired and initialized from a pool before being returned to a caller.
end

function EncounterTimelineControllerMixin:OnEventFrameReleased(_eventFrame)
	-- Override in a derived mixin to run logic after an event has been
	-- released back into the pool prior to reset logic completing.
end

function EncounterTimelineControllerMixin:GetEventState(eventID)
	-- Override if needed to decouple from the C API.
	return C_EncounterTimeline.GetEventState(eventID);
end

function EncounterTimelineControllerMixin:GetEventTimeRemaining(eventID)
	-- Override if needed to decouple from the C API.
	return C_EncounterTimeline.GetEventTimeRemaining(eventID);
end

function EncounterTimelineControllerMixin:GetEventTrack(eventID)
	-- Override if needed to decouple from the C API.
	return C_EncounterTimeline.GetEventTrack(eventID);
end

function EncounterTimelineControllerMixin:GetEventTrackType(eventID)
	-- Override if needed to decouple from the C API.
	return self:GetTrackType(C_EncounterTimeline.GetEventTrack(eventID));
end

function EncounterTimelineControllerMixin:IsEventBlocked(eventID)
	-- Override if needed to decouple from the C API.
	return C_EncounterTimeline.IsEventBlocked(eventID);
end

function EncounterTimelineControllerMixin:GetEventFramePool(_eventID, framePoolCollection)
	-- Override in a derived mixin if you want different templates for events.
	-- The default just provides a blank set of dummy frames.

	return framePoolCollection:GetPool("EncounterTimelineEventFrameTemplate");
end

function EncounterTimelineControllerMixin:GetEventFrameInitialAnchor(_eventID)
	-- Override in a derived mixin to return a suitable initial anchor point.
	return CreateAnchor("CENTER", self, "CENTER", 0, 0);
end

function EncounterTimelineControllerMixin:EnumerateTracks()
	return ipairs(self.tracksByIndex);
end

function EncounterTimelineControllerMixin:FindTrackForDuration(duration)
	for _, trackData in self:EnumerateTracks() do
		if (trackData.minimumDuration <= 0 or duration > trackData.minimumDuration) and (duration <= trackData.maximumDuration) then
			return trackData;
		end
	end
end

function EncounterTimelineControllerMixin:GetTrackData(track)
	return self.tracksByID[track];
end

function EncounterTimelineControllerMixin:GetTrackType(track)
	local trackData = self.tracksByID[track];

	if trackData ~= nil then
		return trackData.type;
	end
end

function EncounterTimelineControllerMixin:GetTrackCount()
	return #self.tracksByIndex;
end

function EncounterTimelineControllerMixin:HasTrack(track)
	return self.tracksByID[track] ~= nil;
end

function EncounterTimelineControllerMixin:SetTrackList(trackList)
	-- Obliterate the existing list of ordered tracks and ensure all indices
	-- are reset in case track list layouts become dynamic one day.

	self.tracksByIndex = {};

	for _trackID, trackData in pairs(self.tracksByID) do
		trackData.index = nil;
	end

	-- We assume the given track list is ordered in terms of ascending minimum
	-- duration. We need to iterate in reverse order as we build the timeline
	-- tracks from left to right (last to first or longest to shortest).

	local trackCount = 0;

	for _trackIndexReversed, trackData in ipairs_reverse(trackList) do
		local track = trackData.id;
		local trackIndex = trackCount + 1;
		local oldTrackData = self.tracksByID[track];
		local newTrackData = CopyTable(trackData);

		-- These three fields as received from C will be nil if there's no
		-- constraint on the tracks. For our calculations however, we'd prefer
		-- that these actually have valid (albeit, infinite) values.

		newTrackData.maximumDuration = newTrackData.maximumDuration or math.huge;
		newTrackData.minimumDuration = newTrackData.minimumDuration or 0;
		newTrackData.maximumEventCount = newTrackData.maximumEventCount or math.huge;

		-- Duration is a precomputed property as we need it in a few places.

		newTrackData.duration = newTrackData.maximumDuration - newTrackData.minimumDuration;

		-- These fields should be retained across updates or initialized as needed.

		newTrackData.extent = oldTrackData ~= nil and oldTrackData.extent or 0;
		newTrackData.index = oldTrackData ~= nil and oldTrackData.index or nil;
		newTrackData.paddingStart = oldTrackData ~= nil and oldTrackData.paddingStart or 0;
		newTrackData.paddingEnd = oldTrackData ~= nil and oldTrackData.paddingEnd or 0;
		newTrackData.offsetStart = oldTrackData ~= nil and oldTrackData.offsetStart or 0;
		newTrackData.offsetEnd = oldTrackData ~= nil and oldTrackData.offsetEnd or 0;

		-- Incorporate this track into our list and map.

		self.tracksByID[track] = newTrackData;
		self.tracksByIndex[trackIndex] = newTrackData;
		trackCount = trackCount + 1;
	end

	self:MarkLayoutDirty();
	self:OnTracksUpdated();
end

function EncounterTimelineControllerMixin:SetTrackPadding(track, paddingStart, paddingEnd)
	assert(type(paddingStart) == "number", "SetTrackPadding: 'paddingStart' must be a number");
	assert(type(paddingEnd) == "number", "SetTrackPadding: 'paddingEnd' must be a number");

	local trackData = self:GetTrackData(track);
	trackData.paddingStart = paddingStart;
	trackData.paddingEnd = paddingEnd;

	self:MarkLayoutDirty();
end

function EncounterTimelineControllerMixin:SetTrackExtent(track, extent)
	assert(type(extent) == "number", "SetTrackExtent: 'extent' must be a number");

	local trackData = self:GetTrackData(track);
	trackData.extent = extent;

	self:MarkLayoutDirty();
end

function EncounterTimelineControllerMixin:SetTrackOffsets(track, offsetStart, offsetEnd)
	assert(type(offsetStart) == "number", "SetTrackOffsets: 'paddingStart' must be a number");
	assert(type(offsetEnd) == "number", "SetTrackOffsets: 'paddingEnd' must be a number");

	local trackData = self:GetTrackData(track);
	trackData.offsetStart = offsetStart;
	trackData.offsetEnd = offsetEnd;

	self:MarkLayoutDirty();
end

function EncounterTimelineControllerMixin:IsLayoutDirty()
	return self.layoutDirty == true;
end

function EncounterTimelineControllerMixin:MarkLayoutClean()
	self.layoutDirty = false;
end

function EncounterTimelineControllerMixin:MarkLayoutDirty()
	self.layoutDirty = true;
end

function EncounterTimelineControllerMixin:GetPrimaryAxisPadding()
	return self.primaryAxisPaddingStart, self.primaryAxisPaddingEnd;
end

function EncounterTimelineControllerMixin:SetPrimaryAxisPadding(paddingStart, paddingEnd)
	assert(type(paddingStart) == "number", "SetPrimaryAxisPadding: 'paddingStart' must be a number");
	assert(type(paddingEnd) == "number", "SetPrimaryAxisPadding: 'paddingEnd' must be a number");

	self.primaryAxisPaddingStart = paddingStart;
	self.primaryAxisPaddingEnd = paddingEnd;
	self:MarkLayoutDirty();
end

function EncounterTimelineControllerMixin:GetPrimaryAxisExtent()
	return self.primaryAxisExtent;
end

function EncounterTimelineControllerMixin:GetSortedEventExtent()
	return self.sortedEventExtent;
end

function EncounterTimelineControllerMixin:SetSortedEventExtent(extent)
	assert(type(extent) == "number", "SetSortedEventExtent: 'extent' must be a number");

	self.sortedEventExtent = extent;
	self:MarkLayoutDirty();
end

function EncounterTimelineControllerMixin:UpdateTrackList()
	self:SetTrackList(C_EncounterTimeline.GetTrackList());
end

function EncounterTimelineControllerMixin:UpdateLinearTrackLayout(trackData, primaryAxisOffset)
	-- A linear track positions events based on remaining duration.
	--
	-- These tracks expect an extent be manually configured, and don't
	-- make use of event extents or spacing.

	primaryAxisOffset:Add(trackData.paddingStart);
	trackData.offsetStart = primaryAxisOffset:Count();

	primaryAxisOffset:Add(trackData.extent);
	trackData.offsetEnd = primaryAxisOffset:Count();

	primaryAxisOffset:Add(trackData.paddingEnd);
end

function EncounterTimelineControllerMixin:UpdateSortedTrackLayout(trackData, primaryAxisOffset)
	-- A sorted track positions events into fixed "slots" up to a
	-- maximum count. The extent of this track is inferred from a
	-- combination of event extent, spacing, and count - and so any
	-- manual extent configuration is ignored.

	primaryAxisOffset:Add(trackData.paddingStart);
	trackData.offsetStart = primaryAxisOffset:Count();

	primaryAxisOffset:Add(trackData.maximumEventCount * self:GetSortedEventExtent());
	trackData.offsetEnd = primaryAxisOffset:Count();

	primaryAxisOffset:Add(trackData.paddingEnd);
end

function EncounterTimelineControllerMixin:UpdateHiddenTrackLayout(_trackData, primaryAxisOffset)
	-- A hidden track is never expected to have visible events - ignore it.
end

function EncounterTimelineControllerMixin:UpdateTrackLayoutByType(trackData, primaryAxisOffset)
	local trackType = trackData.type;

	if trackType == Enum.EncounterTimelineTrackType.Linear then
		self:UpdateLinearTrackLayout(trackData, primaryAxisOffset);
	elseif trackType == Enum.EncounterTimelineTrackType.Sorted then
		self:UpdateSortedTrackLayout(trackData, primaryAxisOffset);
	elseif trackType == Enum.EncounterTimelineTrackType.Hidden then
		self:UpdateHiddenTrackLayout(trackData, primaryAxisOffset);
	else
		assertsafe(false, "unhandled track type in UpdateLayout");
		self:UpdateHiddenTrackLayout(trackData, primaryAxisOffset);
	end
end

function EncounterTimelineControllerMixin:UpdateTrackLayout(trackData, primaryAxisOffset)
	-- Customization point; right now all track layouts are handled at a type
	-- level - but if we need per-track logic, then condition it out here.

	self:UpdateTrackLayoutByType(trackData, primaryAxisOffset);
end

function EncounterTimelineControllerMixin:UpdateLayout()
	local primaryAxisOffset = CreateAccumulator();
	primaryAxisOffset:Add(self.primaryAxisPaddingStart);

	for _trackIndex, trackData in self:EnumerateTracks() do
		self:UpdateTrackLayout(trackData, primaryAxisOffset);
	end

	primaryAxisOffset:Add(self.primaryAxisPaddingEnd);
	self.primaryAxisExtent = primaryAxisOffset:Count();

	self:MarkLayoutClean();
	self:OnLayoutUpdated();
end

function EncounterTimelineControllerMixin:CalculateOffsetForDuration(duration)
	local trackData = self:FindTrackForDuration(duration);

	-- If we can't find the track, there's a serious problem - just assume
	-- that the start of the timeline is fine.

	if trackData == nil then
		return 0;
	end

	-- Duration offset queries can only be implemented for linear tracks. If
	-- for some reason we'd resolve a non-linear track, clamp to the end
	-- offset and don't interpolate anything.

	if trackData.type == Enum.EncounterTimelineTrackType.Linear then
		return self:CalculateLinearEventOffset(trackData, duration);
	else
		return trackData.offsetEnd;
	end
end

function EncounterTimelineControllerMixin:CalculateLinearEventOffset(trackData, duration)
	-- Note that this clamp call intentionally inverts max/min in terms of
	-- argument positions - the timeline counts downwards, so we want a
	-- progress value such that 0 is toward the start and 1 toward the end.

	local progress = ClampedPercentageBetween(duration, trackData.maximumDuration, trackData.minimumDuration);
	local offset = Lerp(trackData.offsetStart, trackData.offsetEnd, progress);

	return offset;
end

function EncounterTimelineControllerMixin:CalculateSortedEventOffset(trackData, trackSortIndex)
	-- Sorted events are positioned into fixed intervals based on their
	-- sort index.
	--
	-- The sort direction is used to accomodate scenarios where we want
	-- different sorted tracks on the timelime to place their events at
	-- opposite ends of the track - for example, long events are sorted
	-- such that index 1 is the soonest-expiring event (and so, should place
	-- toward the end of the track), but for queued events index 1 would be
	-- the most-recently-queued event (and so, should place toward the start
	-- of the track).

	local index;

	if trackData.sortDirection == Enum.EncounterTimelineEventSortDirection.Ascending then
		index = trackSortIndex;
	else
		index = trackData.maximumEventCount - trackSortIndex + 1;
	end

	return trackData.offsetStart + (index * self:GetSortedEventExtent());
end

function EncounterTimelineControllerMixin:CalculateEventOffset(track, trackSortIndex, timeRemaining)
	local trackData = self:GetTrackData(track);
	local trackType = trackData.type;

	if trackType == Enum.EncounterTimelineTrackType.Linear then
		return self:CalculateLinearEventOffset(trackData, timeRemaining);
	elseif trackType == Enum.EncounterTimelineTrackType.Sorted then
		return self:CalculateSortedEventOffset(trackData, trackSortIndex);
	elseif trackType == Enum.EncounterTimelineTrackType.Hidden then
		-- Hidden tracks should never be visible; this is just to avoid an
		-- assert if querying one.
		return trackData.offsetEnd;
	else
		assertsafe(false, "unhandled track type in CalculateEventOffset");
		return trackData.offsetEnd;
	end
end


function EncounterTimelineControllerMixin:RegisterEventFrameTemplate(frameType, templateName)
	local function ResetEventFrame(_pool, eventFrame)
		self:ResetEventFrame(eventFrame);
	end

	local framePoolCollection = self:GetEventFramePoolCollection();
	framePoolCollection:CreatePool(frameType, self, templateName, ResetEventFrame);
end

function EncounterTimelineControllerMixin:AddEvent(eventInfo)
	local eventID = eventInfo.id;

	if self:HasEvent(eventID) then
		return;
	end

	self.eventInstances[eventID] = eventInfo;

	-- Newly added events don't have frames. The only operation that can add
	-- a frame to an event is a track transition. Thus, it stands that the
	-- only thing we need to do here is update the track to try and spawn
	-- a frame.

	self:UpdateEventTrack(eventID);
	self:OnEventAdded(eventInfo);
end

function EncounterTimelineControllerMixin:AddAllEvents(eventList)
	for _eventIndex, eventInfo in ipairs(eventList) do
		self:AddEvent(eventInfo);
	end
end

function EncounterTimelineControllerMixin:GetEventInfo(eventID)
	return self.eventInstances[eventID];
end

function EncounterTimelineControllerMixin:GetEventFrame(eventID)
	return self.eventFrames[eventID];
end

function EncounterTimelineControllerMixin:GetEventFramePoolCollection()
	return self.eventFramePools;
end

function EncounterTimelineControllerMixin:EnumerateEvents()
	return pairs(self.eventInstances);
end

function EncounterTimelineControllerMixin:EnumerateEventFrames()
	return pairs(self.eventFramesActive);
end

function EncounterTimelineControllerMixin:HasEvent(eventID)
	return self.eventInstances[eventID] ~= nil;
end

function EncounterTimelineControllerMixin:HasEventFrame(eventID)
	return self.eventFrames[eventID] ~= nil;
end

function EncounterTimelineControllerMixin:HasAnyActiveEventFrames()
	return next(self.eventFramesActive) ~= nil;
end

function EncounterTimelineControllerMixin:IsEventFrameActive(eventFrame)
	return self.eventFramesActive[eventFrame] == true;
end

function EncounterTimelineControllerMixin:IsEventFrameDetached(eventFrame)
	local eventID = eventFrame:GetEventID();
	return self.eventFramesActive[eventFrame] and self.eventFrames[eventID] ~= eventFrame;
end

function EncounterTimelineControllerMixin:IsEventFrameAssigned(eventFrame)
	local eventID = eventFrame:GetEventID();
	return self.eventFramesActive[eventFrame] and self.eventFrames[eventID] == eventFrame;
end

function EncounterTimelineControllerMixin:UpdateEventState(eventID)
	local eventFrame = self:GetEventFrame(eventID);

	if eventFrame == nil then
		return;
	end

	eventFrame:UpdateEventState();
end

function EncounterTimelineControllerMixin:UpdateEventTrack(eventID)
	if not self:HasEvent(eventID) then
		return;
	end

	-- Skip track updates if this event is in a final state. We don't want to
	-- acquire a frame just to hide it immediately, and final states probably
	-- don't need to set up translations for the new track if they're about to
	-- be hidden anyway.

	local state = self:GetEventState(eventID);

	if state == Enum.EncounterTimelineEventState.Canceled or state == Enum.EncounterTimelineEventState.Finished then
		return;
	end

	-- If there's no presently allocated frame and this event is on a hidden
	-- track, don't bother acquiring one - we can't position it.

	local eventFrame = self:GetEventFrame(eventID);
	local track = self:GetEventTrack(eventID);

	if eventFrame == nil and track == Enum.EncounterTimelineTrack.Indeterminate then
		return;
	end

	-- If we don't have an event frame, acquiring one will implicitly trigger
	-- a track/state/etc. update - so we can just acquire and return in that
	-- case. Otherwise, manually notify.

	if eventFrame == nil then
		self:AcquireEventFrame(eventID);  -- UpdateEventTrack is performed automatically.
	else
		eventFrame:UpdateEventTrack();
	end
end

function EncounterTimelineControllerMixin:UpdateEventBlockedState(eventID)
	local eventFrame = self:GetEventFrame(eventID);

	if eventFrame == nil then
		return;
	end

	eventFrame:UpdateEventBlockedState();
end

function EncounterTimelineControllerMixin:HighlightEvent(eventID)
	local eventFrame = self:GetEventFrame(eventID);

	if eventFrame == nil then
		return;
	end

	eventFrame:HighlightEvent();
end

function EncounterTimelineControllerMixin:RemoveEvent(eventID)
	if not self:HasEvent(eventID) then
		return;
	end

	-- When removing an event we only want to release event frames if they're
	-- actively attached to this event still. Detached event frames shouldn't
	-- be released, as these are (hopefully) in the process of animating out
	-- and will invoke their release callback instead.

	local eventFrame = self:GetEventFrame(eventID);

	if eventFrame ~= nil then
		self:ReleaseEventFrame(eventFrame);
	end

	self.eventInstances[eventID] = nil;
	self:OnEventRemoved(eventID);
end

function EncounterTimelineControllerMixin:RemoveAllEvents()
	for eventID, _eventInfo in self:EnumerateEvents() do
		self:RemoveEvent(eventID);
	end
end

function EncounterTimelineControllerMixin:AssignEventFrame(eventID, eventFrame)
	assertsafe(not self:HasEventFrame(eventID), "attempted to assign multiple event frames to a single event");
	assertsafe(not self:IsEventFrameAssigned(eventFrame), "attempted to assign an event frame to multiple events");

	self.eventFrames[eventID] = eventFrame;
end

function EncounterTimelineControllerMixin:AcquireEventFrame(eventID)
	local eventFrame = self.eventFrames[eventID];

	-- Acquiring event frames is an idempotent operation; if a frame is
	-- already assigned then yield it as-is.

	if eventFrame ~= nil then
		return eventFrame;
	end

	-- Event frames are generally expected to signal on their on accord when
	-- they're ready to be released into the pool. To accomodate this, we
	-- set up a callback that they can invoke to dispose of themselves.

	local eventFramePool = self:GetEventFramePool(eventID, self:GetEventFramePoolCollection());
	local isNewObject;
	eventFrame, isNewObject = eventFramePool:Acquire();

	self.eventFramesActive[eventFrame] = true;

	if isNewObject then
		local function DetachEventFrame()
			self:DetachEventFrame(eventFrame);
		end

		local function ReleaseEventFrame()
			self:ReleaseEventFrame(eventFrame);
		end

		eventFrame:SetController(self);
		eventFrame:SetDetachCallback(DetachEventFrame);
		eventFrame:SetReleaseCallback(ReleaseEventFrame);
	end

	self:AssignEventFrame(eventID, eventFrame);
	self:OnEventFrameAcquired(eventFrame, isNewObject);

	self:InitializeEventFrame(eventID, eventFrame);
	self:OnEventFrameInitialized(eventFrame, isNewObject);

	return eventFrame;
end

function EncounterTimelineControllerMixin:InitializeEventFrame(eventID, eventFrame)
	local eventInfo = self:GetEventInfo(eventID);
	local eventInitialAnchor = self:GetEventFrameInitialAnchor(eventID);
	local clearAllPoints = true;

	eventInitialAnchor:SetPoint(eventFrame, clearAllPoints);

	eventFrame:Init(eventInfo);
	eventFrame:UpdateEventState();
	eventFrame:UpdateEventTrack();
	eventFrame:UpdateEventBlockedState();

	-- The show call must be last; event frames are reliant upon the frame
	-- being hidden for the first Update call to process any special cases
	-- where they want to change their translation animations upon first
	-- entry into the timeline.

	eventFrame:Show();
end

function EncounterTimelineControllerMixin:DetachEventFrame(eventFrame)
	local eventID = eventFrame:GetEventID();

	if self.eventFrames[eventID] == eventFrame then
		self.eventFrames[eventID] = nil;
	end
end

function EncounterTimelineControllerMixin:ReleaseEventFrame(eventFrame)
	if not self:IsEventFrameActive(eventFrame) then
		return;
	end

	local eventID = eventFrame:GetEventID();
	local eventFramePool = self:GetEventFramePool(eventID, self:GetEventFramePoolCollection());

	self.eventFramesActive[eventFrame] = nil;

	if self.eventFrames[eventID] == eventFrame then
		self.eventFrames[eventID] = nil;
	end

	eventFramePool:Release(eventFrame);
end

function EncounterTimelineControllerMixin:ResetEventFrame(eventFrame)
	self:OnEventFrameReleased(eventFrame);

	eventFrame:Reset();
	eventFrame:ClearAllPoints();
	eventFrame:Hide();
end
