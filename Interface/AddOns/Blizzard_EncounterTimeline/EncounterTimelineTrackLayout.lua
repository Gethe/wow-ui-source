EncounterTimelineTrackLayoutMixin = {};

function EncounterTimelineTrackLayoutMixin:OnLoad()
	self.tracksByID = {};
	self.tracksByIndex = {};

	self.primaryAxisPaddingStart = EncounterTimelineTrackLayoutDefaults.PrimaryAxisStartPadding
	self.primaryAxisPaddingEnd = EncounterTimelineTrackLayoutDefaults.PrimaryAxisEndPadding;
	self.sortedEventExtent = EncounterTimelineTrackLayoutDefaults.SortedEventExtent;

	-- Primary axis extent is calculated dynamically.

	self.primaryAxisExtent = 0;

	-- Start in a dirty state as our defaults may be non-zero, meaning that
	-- our primary axis extent as initialized is almost certainly wrong.

	self.layoutDirty = true;
end

function EncounterTimelineTrackLayoutMixin:OnUpdate(_elapsedTime)
	if self:IsLayoutDirty() then
		self:UpdateLayout();
	end
end

function EncounterTimelineTrackLayoutMixin:OnTracksUpdated()
	-- Override to be notified when track data has been modified.
end

function EncounterTimelineTrackLayoutMixin:OnLayoutUpdated()
	-- Override to run any logic after layout has been recalculated.
end

function EncounterTimelineTrackLayoutMixin:EnumerateTracks()
	return ipairs(self.tracksByIndex);
end

function EncounterTimelineTrackLayoutMixin:FindTrackForDuration(duration)
	for _, trackData in self:EnumerateTracks() do
		if (trackData.minimumDuration <= 0 or duration > trackData.minimumDuration) and (duration <= trackData.maximumDuration) then
			return trackData;
		end
	end
end

function EncounterTimelineTrackLayoutMixin:GetTrackData(track)
	return self.tracksByID[track];
end

function EncounterTimelineTrackLayoutMixin:GetTrackCount()
	return #self.tracksByIndex;
end

function EncounterTimelineTrackLayoutMixin:HasTrack(track)
	return self.tracksByID[track] ~= nil;
end

function EncounterTimelineTrackLayoutMixin:SetTrackList(trackList)
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

function EncounterTimelineTrackLayoutMixin:SetTrackPadding(track, paddingStart, paddingEnd)
	local trackData = self:GetTrackData(track);
	trackData.paddingStart = paddingStart;
	trackData.paddingEnd = paddingEnd;

	self:MarkLayoutDirty();
end

function EncounterTimelineTrackLayoutMixin:SetTrackExtent(track, extent)
	local trackData = self:GetTrackData(track);
	trackData.extent = extent;

	self:MarkLayoutDirty();
end

function EncounterTimelineTrackLayoutMixin:SetTrackOffsets(track, offsetStart, offsetEnd)
	local trackData = self:GetTrackData(track);
	trackData.offsetStart = offsetStart;
	trackData.offsetEnd = offsetEnd;

	self:MarkLayoutDirty();
end

function EncounterTimelineTrackLayoutMixin:IsLayoutDirty()
	return self.layoutDirty == true;
end

function EncounterTimelineTrackLayoutMixin:MarkLayoutClean()
	self.layoutDirty = false;
end

function EncounterTimelineTrackLayoutMixin:MarkLayoutDirty()
	self.layoutDirty = true;
end

function EncounterTimelineTrackLayoutMixin:GetPrimaryAxisPadding()
	return self.primaryAxisPaddingStart, self.primaryAxisPaddingEnd;
end

function EncounterTimelineTrackLayoutMixin:SetPrimaryAxisPadding(paddingStart, paddingEnd)
	self.primaryAxisPaddingStart = paddingStart;
	self.primaryAxisPaddingEnd = paddingEnd;
	self:MarkLayoutDirty();
end

function EncounterTimelineTrackLayoutMixin:GetPrimaryAxisExtent()
	return self.primaryAxisExtent;
end

function EncounterTimelineTrackLayoutMixin:GetSortedEventExtent()
	return self.sortedEventExtent;
end

function EncounterTimelineTrackLayoutMixin:SetSortedEventExtent(extent)
	self.sortedEventExtent = extent;
	self:MarkLayoutDirty();
end

function EncounterTimelineTrackLayoutMixin:UpdateTrackList()
	self:SetTrackList(C_EncounterTimeline.GetTrackList());
end

function EncounterTimelineTrackLayoutMixin:UpdateLinearTrackLayout(trackData, primaryAxisOffset)
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

function EncounterTimelineTrackLayoutMixin:UpdateSortedTrackLayout(trackData, primaryAxisOffset)
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

function EncounterTimelineTrackLayoutMixin:UpdateHiddenTrackLayout(_trackData, primaryAxisOffset)
	-- A hidden track is never expected to have visible events - ignore it.
end

function EncounterTimelineTrackLayoutMixin:UpdateTrackLayoutByType(trackData, primaryAxisOffset)
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

function EncounterTimelineTrackLayoutMixin:UpdateTrackLayout(trackData, primaryAxisOffset)
	-- Customization point; right now all track layouts are handled at a type
	-- level - but if we need per-track logic, then condition it out here.

	self:UpdateTrackLayoutByType(trackData, primaryAxisOffset);
end

function EncounterTimelineTrackLayoutMixin:UpdateLayout()
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

function EncounterTimelineTrackLayoutMixin:CalculateOffsetForDuration(duration)
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

function EncounterTimelineTrackLayoutMixin:CalculateLinearEventOffset(trackData, duration)
	-- Note that this clamp call intentionally inverts max/min in terms of
	-- argument positions - the timeline counts downwards, so we want a
	-- progress value such that 0 is toward the start and 1 toward the end.

	local progress = ClampedPercentageBetween(duration, trackData.maximumDuration, trackData.minimumDuration);
	local offset = Lerp(trackData.offsetStart, trackData.offsetEnd, progress);

	return offset;
end

function EncounterTimelineTrackLayoutMixin:CalculateSortedEventOffset(trackData, trackSortIndex)
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

function EncounterTimelineTrackLayoutMixin:CalculateEventOffset(track, trackSortIndex, timeRemaining)
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
