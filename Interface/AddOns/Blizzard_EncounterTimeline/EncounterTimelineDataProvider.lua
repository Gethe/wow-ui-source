EncounterTimelineDataProviderMixin = {};

EncounterTimelineDataProviderMixin.DynamicEvents = {
	"ENCOUNTER_TIMELINE_EVENT_ADDED",
	"ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED",
	"ENCOUNTER_TIMELINE_EVENT_TRACK_CHANGED",
	"ENCOUNTER_TIMELINE_EVENT_BLOCK_STATE_CHANGED",
	"ENCOUNTER_TIMELINE_EVENT_HIGHLIGHT",
	"ENCOUNTER_TIMELINE_EVENT_REMOVED",
};

function EncounterTimelineDataProviderMixin:OnLoad()
	self.eventInstances = {};
end

function EncounterTimelineDataProviderMixin:OnEvent(event, ...)
	if event == "ENCOUNTER_TIMELINE_EVENT_ADDED" then
		local eventInfo = ...;
		self:AddEvent(eventInfo);
	elseif event == "ENCOUNTER_TIMELINE_EVENT_STATE_CHANGED" then
		local eventID = ...;

		if self:HasEvent(eventID) then
			self:OnEventStateChanged(eventID, self:GetEventState(eventID));
		end
	elseif event == "ENCOUNTER_TIMELINE_EVENT_TRACK_CHANGED" then
		local eventID = ...;

		if self:HasEvent(eventID) then
			self:OnEventTrackChanged(eventID, self:GetEventTrack(eventID));
		end
	elseif event == "ENCOUNTER_TIMELINE_EVENT_BLOCK_STATE_CHANGED" then
		local eventID = ...;

		if self:HasEvent(eventID) then
			self:OnEventBlockStateChanged(eventID, self:IsEventBlocked(eventID));
		end
	elseif event == "ENCOUNTER_TIMELINE_EVENT_HIGHLIGHT" then
		local eventID = ...;

		if self:HasEvent(eventID) then
			self:OnEventHighlight(eventID);
		end
	elseif event == "ENCOUNTER_TIMELINE_EVENT_REMOVED" then
		local eventID = ...;
		self:RemoveEvent(eventID);
	end
end

function EncounterTimelineDataProviderMixin:OnEventAdded(eventInfo)
	-- Override in a derived mixin to run logic when a timeline event instance
	-- has been added.
end

function EncounterTimelineDataProviderMixin:OnEventStateChanged(_eventID, _state)
	-- Override in a derived mixin to run logic when a timeline event instance
	-- has undergone a state change (eg. active -> paused).
end

function EncounterTimelineDataProviderMixin:OnEventTrackChanged(_eventID, _track, _trackSortIndex)
	-- Override in a derived mixin to run logic when a timeline event instance
	-- has undergone a track change (eg. short -> queued).
end

function EncounterTimelineDataProviderMixin:OnEventBlockStateChanged(_eventID, _blocked)
	-- Override in a derived mixin to run logic when a timeline event instance
	-- has changed its blocked state.
end

function EncounterTimelineDataProviderMixin:OnEventHighlight(_eventID)
	-- Override in a derived mixin to run logic when a timeline event instance
	-- has been externally triggered to show a highlight.
end

function EncounterTimelineDataProviderMixin:OnEventRemoved(_eventID)
	-- Override in a derived mixin to run logic when a timeline event instance
	-- has been removed. This is guaranteed to be received with an at-minimum
	-- one frame delay between any state change transition to a terminal state
	-- (such as canceled or finished). During dispatch of this handler, the
	-- API will return no data for the event instance ID.
end

function EncounterTimelineDataProviderMixin:AddEvent(eventInfo)
	local eventID = eventInfo.id;

	if self:HasEvent(eventID) then
		return;
	end

	self.eventInstances[eventID] = eventInfo;
	self:OnEventAdded(eventInfo);
end

function EncounterTimelineDataProviderMixin:AddAllEvents(eventIDs)
	for _index, eventID in ipairs(eventIDs) do
		local eventInfo = C_EncounterTimeline.GetEventInfo(eventID);

		if eventInfo then
			self:AddEvent(eventInfo);
		end
	end
end

function EncounterTimelineDataProviderMixin:RemoveEvent(eventID)
	if not self:HasEvent(eventID) then
		return;
	end

	self.eventInstances[eventID] = nil;
	self:OnEventRemoved(eventID);
end

function EncounterTimelineDataProviderMixin:RemoveAllEvents()
	for eventID, _eventInfo in self:EnumerateEvents() do
		self:RemoveEvent(eventID);
	end
end

function EncounterTimelineDataProviderMixin:EnumerateEvents()
	return pairs(self.eventInstances);
end

function EncounterTimelineDataProviderMixin:GetEventInfo(eventID)
	return self.eventInstances[eventID];
end

function EncounterTimelineDataProviderMixin:GetEventState(eventID)
	return C_EncounterTimeline.GetEventState(eventID);
end

function EncounterTimelineDataProviderMixin:GetEventTimer(eventID)
	return C_EncounterTimeline.GetEventTimer(eventID);
end

function EncounterTimelineDataProviderMixin:GetEventTrack(eventID)
	return C_EncounterTimeline.GetEventTrack(eventID);
end

function EncounterTimelineDataProviderMixin:IsEventBlocked(eventID)
	return C_EncounterTimeline.IsEventBlocked(eventID);
end

function EncounterTimelineDataProviderMixin:HasEvent(eventID)
	return self.eventInstances[eventID] ~= nil;
end

function EncounterTimelineDataProviderMixin:GetDynamicEventRegistrations()
	return EncounterTimelineDataProviderMixin.DynamicEvents;
end
