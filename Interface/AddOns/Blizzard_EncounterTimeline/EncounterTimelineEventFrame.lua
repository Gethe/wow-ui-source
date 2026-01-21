local INVALID_EVENT_ID = Constants.EncounterTimelineEventConstants.ENCOUNTER_TIMELINE_INVALID_EVENT;

EncounterTimelineEventFrameMixin = CreateFromMixins(EncounterTimelineSettingsMixin);

function EncounterTimelineEventFrameMixin:OnLoad()
	EncounterTimelineSettingsMixin.OnLoad(self);

	self:SetMouseClickEnabled(false);

	self.eventFrameManager = nil;
	self.eventID = INVALID_EVENT_ID;
	self.eventInfo = nil;
	self.eventTimer = nil;
	self.eventState = nil;
	self.eventTrack = nil;
	self.eventTrackSortIndex = nil;
	self.eventBlocked = nil;
end

function EncounterTimelineEventFrameMixin:OnShow()
	-- No-op; reserved for future use. Ensure derived mixins call this.
end

function EncounterTimelineEventFrameMixin:OnHide()
	if self:GetEventFrameManager() ~= nil and self:ShouldReleaseFrameOnHide() then
		self:ReleaseFrame();
	end
end

function EncounterTimelineEventFrameMixin:OnEnter()
	self:ShowTooltip();
end

function EncounterTimelineEventFrameMixin:OnLeave()
	self:HideTooltip();
end

function EncounterTimelineEventFrameMixin:OnEventStateChanged(_state)
	-- Override in a derived mixin to be notified when the state for this
	-- event has changed.
end

function EncounterTimelineEventFrameMixin:OnEventTrackChanged(_track, _trackSortIndex)
	-- Override in a derived mixin to be notified when the track or relative
	-- order within a sorted track has been changed for this event.
end

function EncounterTimelineEventFrameMixin:OnEventBlockStateChanged(_blocked)
	-- Override in a derived mixin to be notified when the block state for
	-- this event has changed.
end

function EncounterTimelineEventFrameMixin:Init(eventInfo, timer, state, track, trackSortIndex, blocked)
	self.eventInfo = eventInfo;
	self.eventTimer = timer;
	self.eventState = state;
	self.eventTrack = track;
	self.eventTrackSortIndex = trackSortIndex;
	self.eventBlocked = blocked;
end

function EncounterTimelineEventFrameMixin:Reset()
	self.eventInfo = nil;
	self.eventTimer = nil;
	self.eventState = nil;
	self.eventTrack = nil;
	self.eventTrackSortIndex = nil;
	self.eventBlocked = nil;
end

function EncounterTimelineEventFrameMixin:HighlightFrame()
	-- Override in a derived mixin to apply a highlight animation.
end

function EncounterTimelineEventFrameMixin:DetachFrame()
	self:GetEventFrameManager():DetachEventFrame(self);
end

function EncounterTimelineEventFrameMixin:ReleaseFrame()
	self:GetEventFrameManager():ReleaseEventFrame(self);
end

function EncounterTimelineEventFrameMixin:ShouldReleaseFrameOnHide()
	-- Override if automatically releasing the frame back to the frame manager
	-- when hidden should not occur.
	return true;
end

function EncounterTimelineEventFrameMixin:GetEventFrameManager()
	return self.eventFrameManager;
end

function EncounterTimelineEventFrameMixin:GetEventID()
	return self.eventID;
end

function EncounterTimelineEventFrameMixin:SetEventID(eventID)
	self.eventID = eventID;
end

function EncounterTimelineEventFrameMixin:GetEventInfo()
	return self.eventInfo;
end

function EncounterTimelineEventFrameMixin:GetEventState()
	return self.eventState;
end

function EncounterTimelineEventFrameMixin:GetEventTimeElapsed()
	return self.eventTimer:GetElapsedDuration();
end

function EncounterTimelineEventFrameMixin:GetEventTimeRemaining()
	return self.eventTimer:GetRemainingDuration();
end

function EncounterTimelineEventFrameMixin:GetEventTimer()
	return self.eventTimer;
end

function EncounterTimelineEventFrameMixin:GetEventTrack()
	return self.eventTrack, self.eventTrackSortIndex;
end

function EncounterTimelineEventFrameMixin:IsEventBlocked()
	return self.eventBlocked == true;
end

function EncounterTimelineEventFrameMixin:SetEventBlocked(blocked)
	if self.eventBlocked ~= blocked then
		self.eventBlocked = blocked;
		self:OnEventBlockStateChanged(blocked);
	end
end

function EncounterTimelineEventFrameMixin:SetEventFrameManager(eventFrameManager)
	self.eventFrameManager = eventFrameManager;
end

function EncounterTimelineEventFrameMixin:SetEventState(state)
	if self.eventState ~= state then
		self.eventState = state;
		self:OnEventStateChanged(state);
	end
end

function EncounterTimelineEventFrameMixin:SetEventTrack(track, trackSortIndex)
	if self.eventTrack ~= track or self.eventTrackSortIndex ~= trackSortIndex then
		self.eventTrack = track;
		self.eventTrackSortIndex = trackSortIndex;
		self:OnEventTrackChanged(track, trackSortIndex);
	end
end

function EncounterTimelineEventFrameMixin:CanShowTooltipForEvent(eventInfo)
	return eventInfo ~= nil and eventInfo.spellID ~= nil;
end

function EncounterTimelineEventFrameMixin:GetTooltipFrame()
	return GameTooltip;
end

function EncounterTimelineEventFrameMixin:ShowTooltip()
	local tooltipAnchor = self:GetTooltipAnchor();
	local tooltipFrame = self:GetTooltipFrame();

	if tooltipFrame == nil then
		return;
	end

	self:HideTooltip();

	if tooltipAnchor == Enum.EncounterEventsTooltipAnchor.Hidden then
		return;
	end

	local eventInfo = self:GetEventInfo();

	if not self:CanShowTooltipForEvent(eventInfo) then
		return;
	end

	if tooltipAnchor == Enum.EncounterEventsTooltipAnchor.Default then
		GameTooltip_SetDefaultAnchor(tooltipFrame, self);
	elseif tooltipAnchor == Enum.EncounterEventsTooltipAnchor.Cursor then
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT");
	else
		assertsafe(false, "Unsupported tooltip anchor mode (%s)", tooltipAnchor);
	end

	self:PopulateTooltip(tooltipFrame, eventInfo);
	tooltipFrame:Show();
end

function EncounterTimelineEventFrameMixin:PopulateTooltip(tooltipFrame, eventInfo)
	tooltipFrame:SetSpellByID(eventInfo.spellID);
end

function EncounterTimelineEventFrameMixin:HideTooltip()
	local tooltipFrame = self:GetTooltipFrame();

	if tooltipFrame ~= nil and tooltipFrame:IsOwned(self) then
		tooltipFrame:Hide();
	end
end
