-- The encounter timeline is split into small logical tracks that are further
-- subdivided by sections if there's important duration breakpoints within a
-- track.
--
-- The track mixins herein store some layout state for these individual
-- tracks by attempting to map event position data (its track, sort order,
-- and remaining time) to a scale of normalized offsets. When transitions are
-- applied to timeline events, we define the translation of an event from one
-- place to another by interpolating between normalized offsets on the track.
--
-- Each game tick, we walk all active event frames and update the
-- interpolations with a fresh view on current timeline time ("absolute" time)
-- and remaining event duration ("relative" time). We then take the calculated
-- normalized offset and translate it to a physical primary axis offset that
-- is suitable for application as a frame point offset.
--
-- The reason we don't directly interpolate between primary axis offsets is
-- to just simplify state management if the timeline view is dynamically
-- reconfigured - if the position or size of any timeline track would change
-- we'd need to walk all events and recalculate the start/end points of their
-- translations.
--
-- Note that we only apply normalized offsets along the primary axis of the
-- timeline. There are some translations that can occur on the cross axis,
-- but presently those use absolute values. We don't anticipate needing to
-- have the cross axis be dynamic in any meaningful way, and translations
-- across it are just fade-in/fade-outs that last a fraction of a second at
-- most.

EncounterTimelineTrackBaseMixin = {};

function EncounterTimelineTrackBaseMixin:Init(trackInfo)
	self.trackEnum = trackInfo.track;
	self.trackType = trackInfo.trackType;
	self.minEventDuration = trackInfo.minEventDuration;
	self.maxEventDuration = trackInfo.maxEventDuration;
	self.maxEventCount = trackInfo.maxEventCount;

	self.normalizedOffsetStart = 0;
	self.normalizedOffsetEnd = 0;
	self.primaryAxisOffsetStart = 0;
	self.primaryAxisOffsetEnd = 0;
end

function EncounterTimelineTrackBaseMixin:GetTrackEnum()
	return self.trackEnum;
end

function EncounterTimelineTrackBaseMixin:GetTrackType()
	return self.trackType;
end

function EncounterTimelineTrackBaseMixin:GetTrackDuration()
	return self:GetMaximumEventDuration() - self:GetMinimumEventDuration();
end

function EncounterTimelineTrackBaseMixin:GetMinimumEventDuration()
	return self.minEventDuration;
end

function EncounterTimelineTrackBaseMixin:GetMaximumEventDuration()
	return self.maxEventDuration;
end

function EncounterTimelineTrackBaseMixin:GetMaximumEventCount()
	return self.maxEventCount;
end

function EncounterTimelineTrackBaseMixin:IsDurationInRange(duration)
	return (self.minEventDuration <= 0 or duration > self.minEventDuration) and (duration <= self.maxEventDuration);
end

function EncounterTimelineTrackBaseMixin:GetNormalizedOffsets()
	return self.normalizedOffsetStart, self.normalizedOffsetEnd;
end

function EncounterTimelineTrackBaseMixin:IsNormalizedOffsetInRange(offset)
	return offset >= self.normalizedOffsetStart and offset <= self.normalizedOffsetEnd;
end

function EncounterTimelineTrackBaseMixin:SetNormalizedOffsets(offsetStart, offsetEnd)
	assert(type(offsetStart) == "number");
	assert(type(offsetEnd) == "number");

	self.normalizedOffsetStart = offsetStart;
	self.normalizedOffsetEnd = offsetEnd;
end

function EncounterTimelineTrackBaseMixin:GetPrimaryAxisOffsets()
	return self.primaryAxisOffsetStart, self.primaryAxisOffsetEnd;
end

function EncounterTimelineTrackBaseMixin:SetPrimaryAxisOffsets(offsetStart, offsetEnd)
	assert(type(offsetStart) == "number");
	assert(type(offsetEnd) == "number");

	self.primaryAxisOffsetStart = offsetStart;
	self.primaryAxisOffsetEnd = offsetEnd;
end

function EncounterTimelineTrackBaseMixin:CalculateNormalizedOffsetForDuration(_duration)
	-- Implement in a derived mixin.
	return 0;
end

function EncounterTimelineTrackBaseMixin:CalculateNormalizedOffsetForEvent(_eventPosition)
	-- Implement in a derived mixin.
	return 0;
end

function EncounterTimelineTrackBaseMixin:CalculatePrimaryAxisOffset(normalizedOffset)
	-- Override as needed; the default behaviour assumes that we can just
	-- linearly interpolate between primary axis bounds based on the
	-- normalized offset.

	if self.primaryAxisOffsetStart ~= self.primaryAxisOffsetEnd then
		local percentage = ClampedPercentageBetween(normalizedOffset, self.normalizedOffsetStart, self.normalizedOffsetEnd);
		return Lerp(self.primaryAxisOffsetStart, self.primaryAxisOffsetEnd, percentage);
	else
		return self.primaryAxisOffsetStart;
	end
end

-- Linear tracks calculate normalized offsets purely from the remaining
-- duration of events. This is effectively reversed, so an event with
-- zero remaining duration clamps to the end of the offset range, and
-- an event with the maximum permissible duration clamps to the start.

EncounterTimelineLinearTrackMixin = CreateFromMixins(EncounterTimelineTrackBaseMixin);

function EncounterTimelineLinearTrackMixin:CalculateNormalizedOffsetForDuration(duration)
	if self.normalizedOffsetStart ~= self.normalizedOffsetEnd then
		local percentage = 1 - ClampedPercentageBetween(duration, self.minEventDuration or 0, self.maxEventDuration);
		return Lerp(self.normalizedOffsetStart, self.normalizedOffsetEnd, percentage);
	else
		return self.normalizedOffsetStart;
	end
end

function EncounterTimelineLinearTrackMixin:CalculateNormalizedOffsetForEvent(eventPosition)
	return self:CalculateNormalizedOffsetForDuration(eventPosition.timeRemaining);
end

-- Sorted tracks calculate normalized offsets from integral sort indices,
-- clamping at a configurable maximum event count.
--
-- Queries for duration-based offsets clamp to the end of the track group.

EncounterTimelineSortedTrackMixin = CreateFromMixins(EncounterTimelineTrackBaseMixin);

function EncounterTimelineSortedTrackMixin:CalculateNormalizedOffsetForDuration(_duration)
	return self.normalizedOffsetEnd;
end

function EncounterTimelineSortedTrackMixin:CalculateNormalizedOffsetForEvent(eventPosition)
	if self.normalizedOffsetStart ~= self.normalizedOffsetEnd then
		return self.normalizedOffsetStart - (eventPosition.order - 1);
	else
		return self.normalizedOffsetStart;
	end
end

-- Hidden tracks have fixed normalized offsets, as they're not meant to be
-- visible anyway.

EncounterTimelineHiddenTrackMixin = CreateFromMixins(EncounterTimelineTrackBaseMixin);

function EncounterTimelineHiddenTrackMixin:CalculateNormalizedOffsetForDuration(_duration)
	return self.normalizedOffsetStart;
end

function EncounterTimelineHiddenTrackMixin:CalculateNormalizedOffsetForEvent(_eventPosition)
	return self.normalizedOffsetStart;
end

-- If you add a new track type, place it into this map and associate it with
-- a derivation of EncounterTimelineTrackBaseMixin.

EncounterTimelineTrackMixinsByType = {
	[Enum.EncounterTimelineTrackType.Hidden] = EncounterTimelineHiddenTrackMixin,
	[Enum.EncounterTimelineTrackType.Sorted] = EncounterTimelineSortedTrackMixin,
	[Enum.EncounterTimelineTrackType.Linear] = EncounterTimelineLinearTrackMixin,
};

function EncounterTimelineUtil.CreateViewTrack(trackInfo)
	local trackMixin = EncounterTimelineTrackMixinsByType[trackInfo.trackType];

	if not trackMixin then
		assertsafe(false, "attempted to create a track group for an unsupported track type");
		trackMixin = EncounterTimelineHiddenTrackMixin;
	end

	local track = CreateFromMixins(trackMixin);
	track:Init(trackInfo);
	return track;
end

-- The track container mixin can be applied to timeline views as a one-stop
-- shop for caching track and group information from the C API.

EncounterTimelineViewTrackContainerMixin = {};

function EncounterTimelineViewTrackContainerMixin:OnLoad()
	self.tracksByIndex = {};
	self.tracksByEnum = {};
end

function EncounterTimelineViewTrackContainerMixin:EnumerateTracks()
	return ipairs(self.tracksByIndex);
end

function EncounterTimelineViewTrackContainerMixin:GetTrack(trackEnum)
	return self.tracksByEnum[trackEnum];
end

function EncounterTimelineViewTrackContainerMixin:GetTrackForDuration(duration)
	for _, track in self:EnumerateTracks() do
		if track:IsDurationInRange(duration) then
			return track;
		end
	end

	-- Clamp to the last track in the sequence.
	return self.tracksByIndex[#self.tracksByIndex];
end

function EncounterTimelineViewTrackContainerMixin:SetTrackNormalizedOffsets(trackEnum, normalizedOffsetStart, normalizedOffsetEnd)
	local track = self:GetTrack(trackEnum);
	track:SetNormalizedOffsets(normalizedOffsetStart, normalizedOffsetEnd);
end

function EncounterTimelineViewTrackContainerMixin:SetTrackPrimaryAxisOffsets(trackEnum, normalizedOffsetStart, normalizedOffsetEnd)
	local track = self:GetTrack(trackEnum);
	track:SetPrimaryAxisOffsets(normalizedOffsetStart, normalizedOffsetEnd);
end

function EncounterTimelineViewTrackContainerMixin:CalculateNormalizedOffsetForDuration(duration)
	local track = self:GetTrackForDuration(duration);
	return track:CalculateNormalizedOffsetForDuration(duration);
end

function EncounterTimelineViewTrackContainerMixin:CalculatePrimaryAxisOffsetForDuration(duration)
	local track = self:GetTrackForDuration(duration);
	local normalizedOffset = track:CalculateNormalizedOffsetForDuration(duration);
	return track:CalculatePrimaryAxisOffset(normalizedOffset);
end

function EncounterTimelineViewTrackContainerMixin:UpdateTracks()
	self.tracksByIndex = {};
	self.tracksByEnum = {};

	for _, trackInfo in ipairs(C_EncounterTimeline.GetTrackList()) do
		local track = EncounterTimelineUtil.CreateViewTrack(trackInfo);
		table.insert(self.tracksByIndex, track);
		self.tracksByEnum[trackInfo.track] = track;
	end
end
