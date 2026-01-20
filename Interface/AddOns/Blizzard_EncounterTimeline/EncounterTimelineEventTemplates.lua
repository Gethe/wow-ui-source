local INVALID_EVENT_ID = Constants.EncounterTimelineEventConstants.ENCOUNTER_TIMELINE_INVALID_EVENT;

EncounterTimelineEventFrameMixin = CreateFromMixins(EncounterTimelineSettingsMixin);

function EncounterTimelineEventFrameMixin:OnLoad()
	EncounterTimelineSettingsMixin.OnLoad(self);

	self.eventID = INVALID_EVENT_ID;
	self.eventInfo = nil;
	self.primaryAxisInterpolator = EncounterTimelineUtil.CreateInterpolator();
	self.crossAxisInterpolator = EncounterTimelineUtil.CreateInterpolator();
end

function EncounterTimelineEventFrameMixin:OnShow()
	-- No-op; reserved for future use however, so please call this from any
	-- derived mixins.
end

function EncounterTimelineEventFrameMixin:OnHide()
	if self:ShouldReleaseOnHide() then
		self:InvokeReleaseCallback();
	end
end

function EncounterTimelineEventFrameMixin:OnUpdate(_elapsedTime)
	-- No-op; implement in a derived mixin to apply per-tick changes.
	--
	-- Note: This method is invoked by the parent view rather than as a
	-- script handler on this frame; the only reason for this is just to
	-- ensure some degree of ordering if it's ever needed.
end

function EncounterTimelineEventFrameMixin:OnEnter()
	-- No-op; reserved for future use however, so please call this from any
	-- derived mixins.
end

function EncounterTimelineEventFrameMixin:OnLeave()
	-- No-op; reserved for future use however, so please call this from any
	-- derived mixins.
end

function EncounterTimelineEventFrameMixin:Init(eventInfo)
	self.eventID = eventInfo.id;
	self.eventInfo = eventInfo;
	self.primaryAxisInterpolator:Reset();
	self.crossAxisInterpolator:Reset();
end

function EncounterTimelineEventFrameMixin:Reset()
	self.primaryAxisInterpolator:Reset();
	self.crossAxisInterpolator:Reset();
	self.eventInfo = nil;

	-- Event ID is explicitly reset to the invalid event sentinel because
	-- there are some edge cases where if you toggle the enabled state of
	-- the timeline with extreme fervor as events finish you can run into
	-- some Lua errors if we zapped this to nil; rather than add the costs
	-- of checks elsewhere it's easier to just reset to an invalid event.

	self.eventID = INVALID_EVENT_ID;
end

function EncounterTimelineEventFrameMixin:GetCrossAxisInterpolator()
	return self.crossAxisInterpolator;
end

function EncounterTimelineEventFrameMixin:GetPrimaryAxisInterpolator()
	return self.primaryAxisInterpolator;
end

function EncounterTimelineEventFrameMixin:GetController()
	return self.controller;
end

function EncounterTimelineEventFrameMixin:GetEventID()
	return self.eventID;
end

function EncounterTimelineEventFrameMixin:GetEventInfo()
	return self.eventInfo;
end

function EncounterTimelineEventFrameMixin:GetEventState()
	return self.controller:GetEventState(self:GetEventID());
end

function EncounterTimelineEventFrameMixin:GetEventTimeRemaining()
	return self.controller:GetEventTimeRemaining(self:GetEventID());
end

function EncounterTimelineEventFrameMixin:GetEventTrack()
	return self.controller:GetEventTrack(self:GetEventID());
end

function EncounterTimelineEventFrameMixin:GetEventTrackType()
	return self.controller:GetEventTrackType(self:GetEventID());
end

function EncounterTimelineEventFrameMixin:IsEventBlocked()
	return self.controller:IsEventBlocked(self:GetEventID());
end

function EncounterTimelineEventFrameMixin:SetController(controller)
	self.controller = controller;
end

function EncounterTimelineEventFrameMixin:InvokeDetachCallback()
	if self.detachCallback ~= nil then
		self.detachCallback();
	end
end

function EncounterTimelineEventFrameMixin:SetDetachCallback(detachCallback)
	self.detachCallback = detachCallback;
end

function EncounterTimelineEventFrameMixin:ShouldReleaseOnHide()
	-- Override in a derived mixin if there are conditions under which your
	-- event frame should not be automatically released back to the parent
	-- view for recycling when hidden.

	return true;
end

function EncounterTimelineEventFrameMixin:InvokeReleaseCallback()
	if self.releaseCallback ~= nil then
		self.releaseCallback();
	end
end

function EncounterTimelineEventFrameMixin:SetReleaseCallback(releaseCallback)
	self.releaseCallback = releaseCallback;
end

function EncounterTimelineEventFrameMixin:UpdateEventState()
	-- Implement in a derived mixin to run logic when event state changes.
end

function EncounterTimelineEventFrameMixin:UpdateEventTrack()
	-- Implement in a derived mixin to run logic when event track positioning changes.
end

function EncounterTimelineEventFrameMixin:UpdateEventBlockedState()
	-- Implement in a derived mixin to run logic when event block state changes.
end

function EncounterTimelineEventFrameMixin:HighlightEvent()
	-- Implement in a derived mixin to highlight an event.
end

EncounterTimelineEventFrameTranslationMixin = {};

function EncounterTimelineEventFrameTranslationMixin:StartCrossAxisIntroTranslation()
	local interpolator = self:GetCrossAxisInterpolator();
	local startTime = C_EncounterTimeline.GetCurrentTime();
	local endTime = startTime + EncounterTimelineConstants.CrossAxisIntroDuration;
	local offsetFrom = EncounterTimelineConstants.CrossAxisIntroDistance;
	local offsetTo = 0;
	local useAbsoluteTime = true;

	interpolator:SetInterpolatedOffset(offsetFrom, offsetTo, startTime, endTime, useAbsoluteTime);
end

function EncounterTimelineEventFrameTranslationMixin:StartCrossAxisOutroTranslation()
	local interpolator = self:GetCrossAxisInterpolator();
	local startTime = C_EncounterTimeline.GetCurrentTime();
	local endTime = startTime + EncounterTimelineConstants.CrossAxisOutroDuration;
	local offsetFrom = 0;
	local offsetTo = EncounterTimelineConstants.CrossAxisOutroDistance;
	local useAbsoluteTime = true;

	interpolator:SetInterpolatedOffset(offsetFrom, offsetTo, startTime, endTime, useAbsoluteTime);
end

function EncounterTimelineEventFrameTranslationMixin:StartPrimaryAxisLinearTranslation(track, timeRemaining)
	-- Linear track translations move across the width of the this track with
	-- positioning being fully inferred from the (relative) remaining time of
	-- the event.
	--
	-- If this is the initial entrance of the event onto the track we need to
	-- do some fudging of the start time/from offset to put in an artificial
	-- hold period for the initial cross axis translation that's applied in
	-- StartCrossAxisIntroTranslation.

	local interpolator = self:GetPrimaryAxisInterpolator();
	local controller = self:GetController();
	local trackData = controller:GetTrackData(track);

	local isInitialEntry = (self:IsShown() == false);
	local startTime;
	local endTime = trackData.minimumDuration;
	local offsetFrom;
	local offsetTo = trackData.offsetEnd;
	local useAbsoluteTime = false;

	if isInitialEntry then
		-- Entering this track from nowhere (we're a new frame).

		startTime = math.max(timeRemaining - EncounterTimelineConstants.CrossAxisIntroDuration, endTime);
		offsetFrom = controller:CalculateLinearEventOffset(trackData, startTime);

	else
		-- Entering this track from an adjacent one; this is the simple case
		-- and we can just set our interpolator up across the whole span.

		startTime = trackData.maximumDuration;
		offsetFrom = trackData.offsetStart;
	end

	interpolator:SetInterpolatedOffset(offsetFrom, offsetTo, startTime, endTime, useAbsoluteTime);
end

function EncounterTimelineEventFrameTranslationMixin:StartPrimaryAxisSortedTranslation(track, trackSortIndex)
	-- Events on sorted tracks interpolate from their existing offsets to
	-- the offset calculated at their desired order index across a fixed
	-- duration.
	--
	-- We need to use absolute time here rather than event-relative because
	-- we don't want a paused event sitting in a sorted track to awkwardly
	-- just freeze in place if it's moving between slots.
	--
	-- for initial-entrance cases, we can't use the current offset of the
	-- event frame - instead, synthesize an offset by assuming that it came
	-- from one place adjacent to the target index.

	local interpolator = self:GetPrimaryAxisInterpolator();
	local controller = self:GetController();
	local trackData = controller:GetTrackData(track);

	local isInitialEntry = (self:IsShown() == false);
	local startTime = C_EncounterTimeline.GetCurrentTime();
	local endTime = startTime + EncounterTimelineConstants.SortedTrackTranslationDuration;
	local offsetFrom;
	local offsetTo = controller:CalculateSortedEventOffset(trackData, trackSortIndex);
	local useAbsoluteTime = true;

	if isInitialEntry then
		offsetFrom = controller:CalculateSortedEventOffset(trackData, trackSortIndex + 1);
	else
		offsetFrom = interpolator:GetCurrentOffset();
	end

	-- Flush an immediate update on this interpolator in case this method is
	-- called twice in succession before OnUpdate occurs, otherwise in the
	-- initial entry case we'll lose our from offset.

	interpolator:SetInterpolatedOffset(offsetFrom, offsetTo, startTime, endTime, useAbsoluteTime);
	interpolator:Update(self:GetEventID());
end

function EncounterTimelineEventFrameTranslationMixin:StopCrossAxisTranslation()
	local interpolator = self:GetCrossAxisInterpolator();
	interpolator:SetFixedOffset(interpolator:GetCurrentOffset());
end

function EncounterTimelineEventFrameTranslationMixin:StopPrimaryAxisTranslation()
	local interpolator = self:GetPrimaryAxisInterpolator();
	interpolator:SetFixedOffset(interpolator:GetCurrentOffset());
end

function EncounterTimelineEventFrameTranslationMixin:ClearCrossAxisTranslation()
	self:GetCrossAxisInterpolator():SetFixedOffset(0);
end

function EncounterTimelineEventFrameTranslationMixin:ClearPrimaryAxisTranslation()
	self:GetPrimaryAxisInterpolator():SetFixedOffset(0);
end

EncounterTimelineTextWithIconEventFrameMixin = CreateFromMixins(EncounterTimelineEventFrameMixin, EncounterTimelineEventFrameTranslationMixin);

EncounterTimelineTextWithIconDirtyFlags = {
	Countdown = bit.lshift(1, 0),
	FrameLevel = bit.lshift(1, 1),
	IconAlpha = bit.lshift(1, 2),
	NameText = bit.lshift(1, 3),
	Orientation = bit.lshift(1, 4),
	PulseAnimation = bit.lshift(1, 5),
	StatusText = bit.lshift(1, 6),
	TextAnchors = bit.lshift(1, 7),
	Iconography = bit.lshift(1, 8),
	BorderStyle = bit.lshift(1, 9),
};

function EncounterTimelineTextWithIconEventFrameMixin:OnLoad()
	EncounterTimelineEventFrameMixin.OnLoad(self);

	self.dirtyFlags = CreateFlags();

	self:SetMouseClickEnabled(false);
end

function EncounterTimelineTextWithIconEventFrameMixin:OnShow()
	EncounterTimelineEventFrameMixin.OnShow(self);

	-- Alpha updates need committing immediately as the intro animation will
	-- cause them to be ignored if the alpha change occurs while playing.
	--
	-- This includes icons which are alpha-toggled rather than vis-toggled.

	self:UpdateIconAlpha();
	self:UpdateIconography();

	self:PlayIntroAnimation();
end

function EncounterTimelineTextWithIconEventFrameMixin:OnUpdate()
	if self:IsDirty() then
		self:OnDirtyUpdate();
	end

	self:UpdatePointOffsets();
	self:UpdateTrailAlpha();
end

function EncounterTimelineTextWithIconEventFrameMixin:OnDirtyUpdate()
	local dirtyFlags = self.dirtyFlags;

	if dirtyFlags:IsSet(EncounterTimelineTextWithIconDirtyFlags.Countdown) then
		self:UpdateCountdown();
	end

	if dirtyFlags:IsSet(EncounterTimelineTextWithIconDirtyFlags.FrameLevel) then
		self:UpdateFrameLevel();
	end

	if dirtyFlags:IsSet(EncounterTimelineTextWithIconDirtyFlags.IconAlpha) then
		self:UpdateIconAlpha();
	end

	if dirtyFlags:IsSet(EncounterTimelineTextWithIconDirtyFlags.NameText) then
		self:UpdateNameText();
	end

	if dirtyFlags:IsSet(EncounterTimelineTextWithIconDirtyFlags.Orientation) then
		self:UpdateOrientation();
	end

	if dirtyFlags:IsSet(EncounterTimelineTextWithIconDirtyFlags.PulseAnimation) then
		self:UpdatePulseAnimation();
	end

	if dirtyFlags:IsSet(EncounterTimelineTextWithIconDirtyFlags.StatusText) then
		self:UpdateStatusText();
	end

	-- Ordering dependency; text anchor updates can be flagged by changes to
	-- name or status text, so this must be done after both of those.

	if dirtyFlags:IsSet(EncounterTimelineTextWithIconDirtyFlags.TextAnchors) then
		self:UpdateTextAnchors();
	end

	if dirtyFlags:IsSet(EncounterTimelineTextWithIconDirtyFlags.Iconography) then
		self:UpdateIconography();
	end

	if dirtyFlags:IsSet(EncounterTimelineTextWithIconDirtyFlags.BorderStyle) then
		self:UpdateBorderStyle();
	end
end

function EncounterTimelineTextWithIconEventFrameMixin:OnEventCountdownEnabledChanged(_countdownEnabled)
	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.Countdown);
end

function EncounterTimelineTextWithIconEventFrameMixin:OnEventTextEnabledChanged(_textEnabled)
	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.NameText);
	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.StatusText);
end

function EncounterTimelineTextWithIconEventFrameMixin:OnEventIconScaleChanged(_iconScale)
	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.Orientation);
	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.TextAnchors);
end

function EncounterTimelineTextWithIconEventFrameMixin:OnEventIndicatorIconMaskChanged(_iconMask)
	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.Iconography);
end

function EncounterTimelineTextWithIconEventFrameMixin:OnViewOrientationChanged(_viewOrientation)
	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.NameText);
	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.Orientation);
	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.StatusText);
end

function EncounterTimelineTextWithIconEventFrameMixin:Init(eventInfo)
	EncounterTimelineEventFrameMixin.Init(self, eventInfo);

	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.Countdown);
	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.IconAlpha);
	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.StatusText);
	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.FrameLevel);
	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.Iconography);
	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.BorderStyle);

	-- We need to reset the visibility state of the icon container frame
	-- because the finish animation applies a scale to it, which triggers
	-- TargetsHiddenOnFinishedAnimGroupTemplate to hide this frame.

	self:GetIconFrame():Show();
end

function EncounterTimelineTextWithIconEventFrameMixin:Reset()
	EncounterTimelineEventFrameMixin.Reset(self);

	self:GetTrailTexture():SetAlpha(0);
	self:StopIntroAnimation();
	self:StopCancelAnimation();
	self:StopFinishAnimation();
	self:StopHighlightAnimation();
	self:StopPulseAnimation();
end

function EncounterTimelineTextWithIconEventFrameMixin:MarkDirty(flag)
	self.dirtyFlags:Set(flag);
end

function EncounterTimelineTextWithIconEventFrameMixin:MarkClean(flag)
	self.dirtyFlags:Clear(flag);
end

function EncounterTimelineTextWithIconEventFrameMixin:IsDirty(flag)
	if flag == nil then
		return self.dirtyFlags:IsAnySet();
	else
		return self.dirtyFlags:IsSet(flag);
	end
end

function EncounterTimelineTextWithIconEventFrameMixin:GetNameFontString()
	return self.NameText;
end

function EncounterTimelineTextWithIconEventFrameMixin:GetStatusFontString()
	return self.StatusText;
end

function EncounterTimelineTextWithIconEventFrameMixin:GetIconAlphaCurve()
	return EncounterTimelineIconAlphaCurve;
end

function EncounterTimelineTextWithIconEventFrameMixin:GetSeverityFrameLevelCurve()
	return EncounterTimelineSeverityFrameLevelCurve;
end

function EncounterTimelineTextWithIconEventFrameMixin:GetIconFrame()
	return self.IconContainer;
end

function EncounterTimelineTextWithIconEventFrameMixin:GetIndicatorContainer()
	return self.Indicators;
end

function EncounterTimelineTextWithIconEventFrameMixin:GetCountdownFrame()
	return self.Countdown;
end

function EncounterTimelineTextWithIconEventFrameMixin:GetPulseAnimation()
	return self.PulseAnimation;
end

function EncounterTimelineTextWithIconEventFrameMixin:GetIntroAnimation()
	return self.IntroAnimation;
end

function EncounterTimelineTextWithIconEventFrameMixin:GetCancelAnimation()
	return self.CancelAnimation;
end

function EncounterTimelineTextWithIconEventFrameMixin:GetFinishAnimation()
	return self.FinishAnimation;
end

function EncounterTimelineTextWithIconEventFrameMixin:GetTrailTexture()
	return self.Trail;
end

function EncounterTimelineTextWithIconEventFrameMixin:GetTrailAlphaCurve()
	return EncounterTimelineTrailAlphaCurve;
end

function EncounterTimelineTextWithIconEventFrameMixin:GetTrailAtlas()
	return "combattimeline-line-icontrail";
end

function EncounterTimelineTextWithIconEventFrameMixin:CanShowCountdownDuration(duration)
	return duration ~= nil and duration > 0 and self:GetEventCountdownEnabled();
end

function EncounterTimelineTextWithIconEventFrameMixin:CanShowNameText(nameText)
	return nameText ~= nil and nameText ~= "" and self:GetEventTextEnabled() and self:GetViewOrientation():IsVertical();
end

function EncounterTimelineTextWithIconEventFrameMixin:CanShowStatusText(statusText)
	return statusText ~= nil and statusText ~= "" and self:GetEventTextEnabled() and self:GetViewOrientation():IsVertical();
end

function EncounterTimelineTextWithIconEventFrameMixin:SetIcon(iconFileID)
	self:GetIconFrame():SetIcon(iconFileID);
end

function EncounterTimelineTextWithIconEventFrameMixin:SetNameText(text)
	local fontString = self:GetNameFontString();
	fontString:SetText(text or "");
	fontString:SetShown(self:CanShowNameText(text));

	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.TextAnchors);
end

function EncounterTimelineTextWithIconEventFrameMixin:SetStatusText(text)
	local fontString = self:GetStatusFontString();
	fontString:SetText(text or "");
	fontString:SetShown(self:CanShowStatusText(text));

	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.TextAnchors);
end

function EncounterTimelineTextWithIconEventFrameMixin:UpdateEventBlockedState()
	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.StatusText);
end

function EncounterTimelineTextWithIconEventFrameMixin:UpdateEventState()
	local state = self:GetEventState();

	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.Countdown);
	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.FrameLevel);
	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.PulseAnimation);
	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.StatusText);
	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.BorderStyle);

	if state == Enum.EncounterTimelineEventState.Canceled then
		self:PlayCancelAnimation();
	elseif state == Enum.EncounterTimelineEventState.Finished then
		self:PlayFinishAnimation();
	end
end

function EncounterTimelineTextWithIconEventFrameMixin:UpdateEventTrack()
	local track, trackSortIndex = self:GetEventTrack();

	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.IconAlpha);
	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.PulseAnimation);
	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.StatusText);
	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.BorderStyle);

	-- Events transitioning off the timeline for reasons other than cancelation
	-- should play the same outro (eg. pushed off because it can't fit in the
	-- queued section).
	--
	-- Otherwise, update our primary axis translation as needed.

	local trackType = self:GetEventTrackType();

	if trackType == Enum.EncounterTimelineTrackType.Hidden then
		self:PlayCancelAnimation();
	elseif trackType == Enum.EncounterTimelineTrackType.Linear then
		self:StartPrimaryAxisLinearTranslation(track, self:GetEventTimeRemaining());
	elseif trackType == Enum.EncounterTimelineTrackType.Sorted then
		self:StartPrimaryAxisSortedTranslation(track, trackSortIndex);
	else
		assertsafe(false, "unhandled track type in UpdateEventTrack");
	end
end

function EncounterTimelineTextWithIconEventFrameMixin:HighlightEvent()
	-- We piggy-back off the highlight notification to trigger both the
	-- highlight itself _and_ a pulse if we're below a specific duration
	-- and on the right track.

	self:PlayHighlightAnimation();
	self:MarkDirty(EncounterTimelineTextWithIconDirtyFlags.PulseAnimation);
end

function EncounterTimelineTextWithIconEventFrameMixin:PlayIntroAnimation()
	-- We can't apply an 'not IsShown' guard here because the event frame is
	-- automatically shown by the parent view. We could change this, but
	-- no real point right now - feel free to do so in the future though (hi!).

	self:GetIntroAnimation():Play();

	-- Playing the intro animation while on a linear track should cause a
	-- cross-axis slide, too.

	if self:GetEventTrackType() == Enum.EncounterTimelineTrackType.Linear then
		self:StartCrossAxisIntroTranslation();
	end
end

function EncounterTimelineTextWithIconEventFrameMixin:PlayCancelAnimation()
	-- If we're not shown then don't apply the animation - this shouldn't
	-- happen, but if it does then because the cancel animation inherits from
	-- TargetsHiddenOnFinishedAnimGroupTemplate it'll cause our frame to
	-- show - which is pointless, as a cancel animation ultimately wants
	-- to hide the frame!

	if not self:IsShown() then
		return;
	end

	self:GetCancelAnimation():Play();

	-- Freeze any translations for the primary axis so that the event doesn't
	-- slide diagonally.

	self:GetPrimaryAxisInterpolator():SetFixedOffset(self:GetPrimaryAxisInterpolator():GetCurrentOffset());
	self:StartCrossAxisOutroTranslation();

	-- Detach this frame from its associated event; this is required to allow
	-- the animation to complete without the frame being hidden early if the
	-- event data is deleted by the C API.

	self:InvokeDetachCallback();
end

function EncounterTimelineTextWithIconEventFrameMixin:PlayFinishAnimation()
	if not self:IsShown() then
		return;
	end

	-- Highlight glow needs forcing as it's technically part of the animation
	-- and we want it at maximum opacity. We terminate the highlight animation
	-- here too to prevent it from interfering with our control of the glow.

	self:StopHighlightAnimation();
	self:GetIconFrame():SetHighlightGlowAlpha(1.0);
	self:GetFinishAnimation():Play();

	-- Freeze any translations for the primary axis so that the event remains
	-- fixed in place while it visually explodes.

	self:GetPrimaryAxisInterpolator():SetFixedOffset(self:GetPrimaryAxisInterpolator():GetCurrentOffset());

	-- Detach this frame from its associated event; this is required to allow
	-- the animation to complete without the frame being hidden early if the
	-- event data is deleted by the C API.

	self:InvokeDetachCallback();
end

function EncounterTimelineTextWithIconEventFrameMixin:PlayHighlightAnimation()
	if not self:IsShown() then
		return;
	end

	self:GetIconFrame():PlayHighlightAnimation();
end

function EncounterTimelineTextWithIconEventFrameMixin:PlayPulseAnimation()
	self:GetPulseAnimation():Play();
end

function EncounterTimelineTextWithIconEventFrameMixin:StopIntroAnimation()
	self:GetIntroAnimation():Stop();
end

function EncounterTimelineTextWithIconEventFrameMixin:StopCancelAnimation()
	self:GetCancelAnimation():Stop();
end

function EncounterTimelineTextWithIconEventFrameMixin:StopFinishAnimation()
	self:GetFinishAnimation():Stop();
end

function EncounterTimelineTextWithIconEventFrameMixin:StopHighlightAnimation()
	self:GetIconFrame():StopHighlightAnimation();
end

function EncounterTimelineTextWithIconEventFrameMixin:StopPulseAnimation()
	self:GetPulseAnimation():Stop();
end

function EncounterTimelineTextWithIconEventFrameMixin:UpdateBorderStyle()
	local eventInfo = self:GetEventInfo();
	local iconFrame = self:GetIconFrame();
	local isDeadlyEffect = FlagsUtil.IsSet(eventInfo.icons, Enum.EncounterEventIconmask.DeadlyEffect);
	local isPaused = self:GetEventState() == Enum.EncounterTimelineEventState.Paused;
	local isQueued = self:GetEventTrack() == Enum.EncounterTimelineTrack.Queued;

	-- Note that some booleans here are secret, so we want to evaluate them
	-- inline, and also ensure all SetShown functions are called to prevent
	-- infererence of secret booleans by counting the number of SetShown
	-- calls that occur.
	--
	-- Priority is Deadly > Paused > Queued > Normal.

	local showDeadlyOverlay = isDeadlyEffect;
	local showPausedOverlay = not showDeadlyOverlay and isPaused;
	local showQueuedOverlay = not showPausedOverlay and isQueued;
	local showNormalOverlay = not showQueuedOverlay;

	iconFrame.DeadlyOverlay:SetShown(showDeadlyOverlay);
	iconFrame.DeadlyOverlayGlow:SetShown(showDeadlyOverlay);
	iconFrame.PausedOverlay:SetShown(showPausedOverlay);
	iconFrame.QueuedOverlay:SetShown(showQueuedOverlay);
	iconFrame.NormalOverlay:SetShown(showNormalOverlay);

	-- Paused and queued icons are special in that we want to show them even
	-- if the overlay can't be shown due to it being a deadly event.

	iconFrame.PausedIcon:SetShown(isPaused);
	iconFrame.QueuedIcon:SetShown(not isPaused and isQueued);

	self:MarkClean(EncounterTimelineTextWithIconDirtyFlags.BorderStyle);
end

function EncounterTimelineTextWithIconEventFrameMixin:UpdateCountdown()
	local timeRemaining = self:GetEventTimeRemaining();
	local countdownFrame = self:GetCountdownFrame();
	local eventState = self:GetEventState();

	if self:CanShowCountdownDuration(timeRemaining) and eventState == Enum.EncounterTimelineEventState.Active then
		countdownFrame:SetCooldownDuration(timeRemaining);
		countdownFrame:Show();
	else
		countdownFrame:Clear();
	end

	self:MarkClean(EncounterTimelineTextWithIconDirtyFlags.Countdown);
end

function EncounterTimelineTextWithIconEventFrameMixin:UpdateFrameLevel()
	-- Child frames of the timeline event have a frame level bump applied.
	--
	-- This is because the timeline event itself is put at the same frame
	-- level of the parent view frame so that we can tuck the trail texture
	-- behind the pip diamond.

	local eventInfo = self:GetEventInfo();
	local frameLevelOffset;

	if self:GetEventState() == Enum.EncounterTimelineEventState.Paused then
		-- Paused events should layer behind active ones.
		frameLevelOffset = 1;
	elseif eventInfo ~= nil then
		frameLevelOffset = self:GetSeverityFrameLevelCurve():Evaluate(eventInfo.severity);
	end

	local frameLevelAdjusted = self:GetFrameLevel() + frameLevelOffset;

	self:GetIconFrame():SetFrameLevel(frameLevelAdjusted);
	self:GetCountdownFrame():SetFrameLevel(frameLevelAdjusted);

	self:MarkClean(EncounterTimelineTextWithIconDirtyFlags.FrameLevel);
end

function EncounterTimelineTextWithIconEventFrameMixin:UpdateIconAlpha()
	local track = self:GetEventTrack();
	local alpha;

	if track ~= nil then
		alpha = self:GetIconAlphaCurve():Evaluate(track);
	else
		alpha = 1.0;
	end

	self:GetIconFrame():SetAlpha(alpha);
	self:GetCountdownFrame():SetAlpha(alpha);

	self:MarkClean(EncounterTimelineTextWithIconDirtyFlags.IconAlpha);
end

function EncounterTimelineTextWithIconEventFrameMixin:UpdateIconography()
	local indicators = self:GetIndicatorContainer();
	indicators:SetTexturesForEvent(self:GetEventID(), self:GetEventIndicatorIconMask());

	self:MarkClean(EncounterTimelineTextWithIconDirtyFlags.Iconography);
end

function EncounterTimelineTextWithIconEventFrameMixin:UpdateNameText()
	-- Implement in a derived mixin; we don't have the appropriate data to
	-- configure name text here. The derived mixin *must* clear the name
	-- text dirty flag (or call this base method to do it).

	self:MarkClean(EncounterTimelineTextWithIconDirtyFlags.NameText);
end

function EncounterTimelineTextWithIconEventFrameMixin:UpdateOrientation()
	local orientation = self:GetViewOrientation();
	local trailTexture = self:GetTrailTexture();
	local iconScale = self:GetEventIconScale();

	trailTexture:ClearAllPoints();
	trailTexture:SetOrientedAtlas(orientation, self:GetTrailAtlas(), TextureKitConstants.UseAtlasSize);
	trailTexture:SetOrientedTexCoordToDefaults(orientation);
	trailTexture:SetOrientedPoint(orientation, "END", self, "START", 10, 0);

	if orientation:IsVertical() then
		local stride = 2;
		local paddingX = 2;
		local paddingY = 0;
		local horizontalSpacing = 16;
		local verticalSpacing = 19;
		local initialAnchor = AnchorUtil.CreateAnchor("TOPLEFT", self:GetIndicatorContainer(), "TOPLEFT", 2, 0);
		local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, stride, paddingX, paddingY, horizontalSpacing, verticalSpacing);

		local indicators = self:GetIndicatorContainer();
		indicators:ClearAllPoints();
		indicators:SetPoint("LEFT", self:GetIconFrame(), "RIGHT");
		indicators:ApplyLayout(initialAnchor, layout);
	else
		local stride = 2;
		local paddingX = 0;
		local paddingY = 2;
		local horizontalSpacing = 19;
		local verticalSpacing = 16;
		local initialAnchor = AnchorUtil.CreateAnchor("BOTTOMLEFT", self:GetIndicatorContainer(), "BOTTOMLEFT", 0, 2);
		local layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.BottomLeftToTopRightVertical, stride, paddingX, paddingY, horizontalSpacing, verticalSpacing);

		local indicators = self:GetIndicatorContainer();
		indicators:ClearAllPoints();
		indicators:SetPoint("BOTTOM", self:GetIconFrame(), "TOP");
		indicators:ApplyLayout(initialAnchor, layout);
	end

	-- Not really orientation-based, but it's not worth the hassle of making
	-- another dirty flag just for these two bits of state.

	self:GetIconFrame():SetScale(iconScale);
	self:GetCountdownFrame():SetScale(iconScale);

	self:MarkClean(EncounterTimelineTextWithIconDirtyFlags.Orientation);
end

function EncounterTimelineTextWithIconEventFrameMixin:UpdatePointOffsets()
	local orientation = self:GetViewOrientation();
	local eventID = self:GetEventID();

	local primaryAxisInterpolator = self:GetPrimaryAxisInterpolator();
	local primaryAxisOffset = primaryAxisInterpolator:Update(eventID);

	self:SetPointsOffset(orientation:GetOrientedOffsets(primaryAxisOffset, self:GetCrossAxisOffset()));

	-- Cross axis interpolations are handled within the element because
	-- we only want to translate *some* child regions and not the whole
	-- event frame, otherwise you'd have text sliding across the screen
	-- and generally looking silly.

	local crossAxisInterpolator = self:GetCrossAxisInterpolator();
	local crossAxisOffset = crossAxisInterpolator:Update(eventID);

	self:GetIconFrame():SetOrientedPointsOffset(orientation, 0, crossAxisOffset);

	-- No dirty flag; this is updated every game tick.
end

function EncounterTimelineTextWithIconEventFrameMixin:UpdatePulseAnimation()
	local state = self:GetEventState();
	local track = self:GetEventTrack();
	local timeRemaining = self:GetEventTimeRemaining();
	local pulseDuration = self:GetPipDuration();

	if state == Enum.EncounterTimelineEventState.Active and track == Enum.EncounterTimelineTrack.Short and timeRemaining ~= nil and timeRemaining <= pulseDuration then
		self:PlayPulseAnimation();
	else
		self:StopPulseAnimation();
	end

	self:MarkClean(EncounterTimelineTextWithIconDirtyFlags.PulseAnimation);
end

function EncounterTimelineTextWithIconEventFrameMixin:UpdateStatusText()
	local state = self:GetEventState();
	local track = self:GetEventTrack();
	local text;

	if state == Enum.EncounterTimelineEventState.Paused then
		text = COMBAT_WARNINGS_EVENT_STATUS_PAUSED;
	elseif self:IsEventBlocked() then
		text = COMBAT_WARNINGS_EVENT_STATUS_BLOCKED;
	elseif track == Enum.EncounterTimelineTrack.Queued then
		text = COMBAT_WARNINGS_EVENT_STATUS_QUEUED;
	else
		text = "";
	end

	self:SetStatusText(text);
	self:MarkClean(EncounterTimelineTextWithIconDirtyFlags.StatusText);
end

function EncounterTimelineTextWithIconEventFrameMixin:UpdateTextAnchors()
	local nameFontString = self:GetNameFontString();
	local statusFontString = self:GetStatusFontString();
	local iconScale = self:GetEventIconScale();

	nameFontString:ClearAllPoints();
	statusFontString:ClearAllPoints();

	if nameFontString:IsShown() and statusFontString:IsShown() then
		nameFontString:SetPoint("BOTTOMRIGHT", self, "LEFT", -10 * iconScale, 2);
		statusFontString:SetPoint("TOPRIGHT", self, "LEFT", -10 * iconScale, -2);
	elseif nameFontString:IsShown() then
		nameFontString:SetPoint("RIGHT", self, "LEFT", -10 * iconScale, 0);
	elseif statusFontString:IsShown() then
		statusFontString:SetPoint("RIGHT", self, "LEFT", -10 * iconScale, 0);
	end

	self:MarkClean(EncounterTimelineTextWithIconDirtyFlags.TextAnchors);
end

function EncounterTimelineTextWithIconEventFrameMixin:UpdateTrailAlpha()
	-- Trail alpha is managed such that we'll fade it in based on our progress
	-- through the short track based on our primary axis interpolator state,
	-- which means that we *should* consistently only start fading the trail
	-- in once we start physically moving the event across the bar on this
	-- track.
	--
	-- Outside of this track, we do a basic frame-lerp to reset the alpha
	-- back to zero smoothly (and quickly).

	local track = self:GetEventTrack();
	local trail = self:GetTrailTexture();

	if track == Enum.EncounterTimelineTrack.Short then
		local curve = self:GetTrailAlphaCurve();
		local progress = self:GetPrimaryAxisInterpolator():GetCurrentProgress();
		trail:SetAlpha(curve:Evaluate(progress));
	else
		trail:SetAlpha(FrameDeltaLerp(trail:GetAlpha(), 0, EncounterTimelineConstants.TrailAlphaFadeRate));
	end

	-- No dirty flag; this is updated every game tick.
end

EncounterTimelineSpellEventFrameMixin = CreateFromMixins(EncounterTimelineTextWithIconEventFrameMixin);

function EncounterTimelineSpellEventFrameMixin:Init(eventInfo)
	EncounterTimelineTextWithIconEventFrameMixin.Init(self, eventInfo);

	self:SetIcon(eventInfo.iconFileID);
end

function EncounterTimelineSpellEventFrameMixin:OnEnter()
	EncounterTimelineTextWithIconEventFrameMixin.OnEnter(self);

	local eventInfo = self:GetEventInfo();

	if eventInfo ~= nil and eventInfo.spellID ~= nil and self:GetEventTooltipsEnabled() then
		GameTooltip_SetDefaultAnchor(GameTooltip, self);
		GameTooltip:SetSpellByID(eventInfo.spellID);
	end
end

function EncounterTimelineSpellEventFrameMixin:OnLeave()
	EncounterTimelineTextWithIconEventFrameMixin.OnLeave(self);

	if GameTooltip:IsOwned(self) then
		GameTooltip:Hide();
	end
end

function EncounterTimelineSpellEventFrameMixin:UpdateNameText()
	EncounterTimelineTextWithIconEventFrameMixin.UpdateNameText(self);

	local eventInfo = self:GetEventInfo();
	self:SetNameText(eventInfo and eventInfo.spellName or "");
end
