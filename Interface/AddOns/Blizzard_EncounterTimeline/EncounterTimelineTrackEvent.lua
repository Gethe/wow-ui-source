EncounterTimelineTrackFrameMixin = CreateFromMixins(EncounterTimelineEventFrameMixin, EncounterTimelineTrackSettingsMixin);

function EncounterTimelineTrackFrameMixin:OnLoad()
	EncounterTimelineEventFrameMixin.OnLoad(self);
	EncounterTimelineTrackSettingsMixin.OnLoad(self);

	self.primaryAxisInterpolator = EncounterTimelineUtil.CreateTrackInterpolator();
	self.crossAxisInterpolator = EncounterTimelineUtil.CreateTrackInterpolator();
	self.trackLayoutManager = nil;
end

function EncounterTimelineTrackFrameMixin:Init(eventInfo, timer, state, track, trackSortIndex, blocked)
	EncounterTimelineEventFrameMixin.Init(self, eventInfo, timer, state, track, trackSortIndex, blocked);

	self.primaryAxisInterpolator:Reset();
	self.crossAxisInterpolator:Reset();
end

function EncounterTimelineTrackFrameMixin:Reset()
	EncounterTimelineEventFrameMixin.Reset(self);

	self.primaryAxisInterpolator:Reset();
	self.crossAxisInterpolator:Reset();
	self.trackLayoutManager = nil;
end

function EncounterTimelineTrackFrameMixin:GetTrackLayoutManager()
	return self.trackLayoutManager;
end

function EncounterTimelineTrackFrameMixin:SetTrackLayoutManager(trackLayoutManager)
	self.trackLayoutManager = trackLayoutManager;
end

function EncounterTimelineTrackFrameMixin:GetCrossAxisInterpolator()
	return self.crossAxisInterpolator;
end

function EncounterTimelineTrackFrameMixin:GetPrimaryAxisInterpolator()
	return self.primaryAxisInterpolator;
end

function EncounterTimelineTrackFrameMixin:StartCrossAxisIntroTranslation()
	local interpolator = self:GetCrossAxisInterpolator();
	local startTime = C_EncounterTimeline.GetCurrentTime();
	local endTime = startTime + EncounterTimelineConstants.CrossAxisIntroDuration;
	local offsetFrom = EncounterTimelineConstants.CrossAxisIntroDistance;
	local offsetTo = 0;
	local useAbsoluteTime = true;

	interpolator:SetInterpolatedOffset(offsetFrom, offsetTo, startTime, endTime, useAbsoluteTime);
end

function EncounterTimelineTrackFrameMixin:StartCrossAxisOutroTranslation()
	local interpolator = self:GetCrossAxisInterpolator();
	local startTime = C_EncounterTimeline.GetCurrentTime();
	local endTime = startTime + EncounterTimelineConstants.CrossAxisOutroDuration;
	local offsetFrom = 0;
	local offsetTo = EncounterTimelineConstants.CrossAxisOutroDistance;
	local useAbsoluteTime = true;

	interpolator:SetInterpolatedOffset(offsetFrom, offsetTo, startTime, endTime, useAbsoluteTime);
end

function EncounterTimelineTrackFrameMixin:StartPrimaryAxisLinearTranslation(track, timeRemaining)
	-- Linear track translations move across the width of the this track with
	-- positioning being fully inferred from the (relative) remaining time of
	-- the event.
	--
	-- If this is the initial entrance of the event onto the track we need to
	-- do some fudging of the start time/from offset to put in an artificial
	-- hold period for the initial cross axis translation that's applied in
	-- StartCrossAxisIntroTranslation.

	local interpolator = self:GetPrimaryAxisInterpolator();
	local trackLayoutManager = self:GetTrackLayoutManager();
	local trackData = trackLayoutManager:GetTrackData(track);

	local isInitialEntry = (self:IsShown() == false);
	local startTime;
	local endTime = trackData.minimumDuration;
	local offsetFrom;
	local offsetTo = trackData.offsetEnd;
	local useAbsoluteTime = false;

	if isInitialEntry then
		-- Entering this track from nowhere (we're a new frame).

		startTime = math.max(timeRemaining - EncounterTimelineConstants.CrossAxisIntroDuration, endTime);
		offsetFrom = trackLayoutManager:CalculateLinearEventOffset(trackData, startTime);

	else
		-- Entering this track from an adjacent one; this is the simple case
		-- and we can just set our interpolator up across the whole span.

		startTime = trackData.maximumDuration;
		offsetFrom = trackData.offsetStart;
	end

	interpolator:SetInterpolatedOffset(offsetFrom, offsetTo, startTime, endTime, useAbsoluteTime);
end

function EncounterTimelineTrackFrameMixin:StartPrimaryAxisSortedTranslation(track, trackSortIndex)
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
	local trackLayoutManager = self:GetTrackLayoutManager();
	local trackData = trackLayoutManager:GetTrackData(track);

	local isInitialEntry = (self:IsShown() == false);
	local startTime = C_EncounterTimeline.GetCurrentTime();
	local endTime = startTime + EncounterTimelineConstants.SortedTrackTranslationDuration;
	local offsetFrom;
	local offsetTo = trackLayoutManager:CalculateSortedEventOffset(trackData, trackSortIndex);
	local useAbsoluteTime = true;

	if isInitialEntry then
		offsetFrom = trackLayoutManager:CalculateSortedEventOffset(trackData, trackSortIndex + 1);
	else
		offsetFrom = interpolator:GetCurrentOffset();
	end

	-- Flush an immediate update on this interpolator in case this method is
	-- called twice in succession before OnUpdate occurs, otherwise in the
	-- initial entry case we'll lose our from offset.

	interpolator:SetInterpolatedOffset(offsetFrom, offsetTo, startTime, endTime, useAbsoluteTime);
	interpolator:Update(self:GetEventID());
end

function EncounterTimelineTrackFrameMixin:StopCrossAxisTranslation()
	local interpolator = self:GetCrossAxisInterpolator();
	interpolator:SetFixedOffset(interpolator:GetCurrentOffset());
end

function EncounterTimelineTrackFrameMixin:StopPrimaryAxisTranslation()
	local interpolator = self:GetPrimaryAxisInterpolator();
	interpolator:SetFixedOffset(interpolator:GetCurrentOffset());
end

function EncounterTimelineTrackFrameMixin:ClearCrossAxisTranslation()
	self:GetCrossAxisInterpolator():SetFixedOffset(0);
end

function EncounterTimelineTrackFrameMixin:ClearPrimaryAxisTranslation()
	self:GetPrimaryAxisInterpolator():SetFixedOffset(0);
end

EncounterTimelineTrackEventMixin = CreateFromMixins(EncounterTimelineTrackFrameMixin);

EncounterTimelineTrackEventDirtyFlag = {
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

EncounterTimelineTrackEventDirtyFlag.All = Flags_CreateMaskFromTable(EncounterTimelineTrackEventDirtyFlag);

function EncounterTimelineTrackEventMixin:OnLoad()
	EncounterTimelineTrackFrameMixin.OnLoad(self);

	self.dirtyFlags = CreateFlags(EncounterTimelineTrackEventDirtyFlag.All);
end

function EncounterTimelineTrackEventMixin:OnUpdate()
	if self:IsDirty() then
		self:OnDirtyUpdate();
	end

	self:UpdatePointOffsets();
	self:UpdateTrailAlpha();
end

function EncounterTimelineTrackEventMixin:OnDirtyUpdate()
	local dirtyFlags = self.dirtyFlags;

	if dirtyFlags:IsSet(EncounterTimelineTrackEventDirtyFlag.Countdown) then
		self:UpdateCountdown();
	end

	if dirtyFlags:IsSet(EncounterTimelineTrackEventDirtyFlag.FrameLevel) then
		self:UpdateFrameLevel();
	end

	if dirtyFlags:IsSet(EncounterTimelineTrackEventDirtyFlag.IconAlpha) then
		self:UpdateIconAlpha();
	end

	if dirtyFlags:IsSet(EncounterTimelineTrackEventDirtyFlag.NameText) then
		self:UpdateNameText();
	end

	if dirtyFlags:IsSet(EncounterTimelineTrackEventDirtyFlag.Orientation) then
		self:UpdateOrientation();
	end

	if dirtyFlags:IsSet(EncounterTimelineTrackEventDirtyFlag.PulseAnimation) then
		self:UpdatePulseAnimation();
	end

	if dirtyFlags:IsSet(EncounterTimelineTrackEventDirtyFlag.StatusText) then
		self:UpdateStatusText();
	end

	-- Ordering dependency; text anchor updates can be flagged by changes to
	-- name or status text, so this must be done after both of those.

	if dirtyFlags:IsSet(EncounterTimelineTrackEventDirtyFlag.TextAnchors) then
		self:UpdateTextAnchors();
	end

	if dirtyFlags:IsSet(EncounterTimelineTrackEventDirtyFlag.Iconography) then
		self:UpdateIconography();
	end

	if dirtyFlags:IsSet(EncounterTimelineTrackEventDirtyFlag.BorderStyle) then
		self:UpdateBorderStyle();
	end
end

function EncounterTimelineTrackEventMixin:OnEventStateChanged(state)
	self:MarkDirty(EncounterTimelineTrackEventDirtyFlag.Countdown);
	self:MarkDirty(EncounterTimelineTrackEventDirtyFlag.FrameLevel);
	self:MarkDirty(EncounterTimelineTrackEventDirtyFlag.PulseAnimation);
	self:MarkDirty(EncounterTimelineTrackEventDirtyFlag.StatusText);
	self:MarkDirty(EncounterTimelineTrackEventDirtyFlag.BorderStyle);

	if state == Enum.EncounterTimelineEventState.Canceled then
		self:PlayCancelAnimation();
	elseif state == Enum.EncounterTimelineEventState.Finished then
		self:PlayFinishAnimation();
	end
end

function EncounterTimelineTrackEventMixin:OnEventTrackChanged(track, trackSortIndex)
	self:MarkDirty(EncounterTimelineTrackEventDirtyFlag.IconAlpha);
	self:MarkDirty(EncounterTimelineTrackEventDirtyFlag.PulseAnimation);
	self:MarkDirty(EncounterTimelineTrackEventDirtyFlag.StatusText);
	self:MarkDirty(EncounterTimelineTrackEventDirtyFlag.BorderStyle);

	-- Events transitioning off the timeline for reasons other than cancelation
	-- should play the same outro (eg. pushed off because it can't fit in the
	-- queued section).
	--
	-- Otherwise, update our primary axis translation as needed.

	local trackType = C_EncounterTimeline.GetTrackType(track);

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

function EncounterTimelineTrackEventMixin:OnEventBlockStateChanged(_blocked)
	self:MarkDirty(EncounterTimelineTrackEventDirtyFlag.StatusText);
end

function EncounterTimelineTrackEventMixin:OnHighlightTimeChanged(_highlightTime)
	self:MarkDirty(EncounterTimelineTrackEventDirtyFlag.PulseAnimation);
end

function EncounterTimelineTrackEventMixin:OnIconScaleChanged(_iconScale)
	self:MarkDirty(EncounterTimelineTrackEventDirtyFlag.Orientation);
	self:MarkDirty(EncounterTimelineTrackEventDirtyFlag.TextAnchors);
end

function EncounterTimelineTrackEventMixin:OnIndicatorIconMaskChanged(_indicatorIconMask)
	self:MarkDirty(EncounterTimelineTrackEventDirtyFlag.Iconography);
end

function EncounterTimelineTrackEventMixin:OnShowCountdownChanged(_showCountdown)
	self:MarkDirty(EncounterTimelineTrackEventDirtyFlag.Countdown);
end

function EncounterTimelineTrackEventMixin:OnShowTextChanged(_showText)
	self:MarkDirty(EncounterTimelineTrackEventDirtyFlag.NameText);
	self:MarkDirty(EncounterTimelineTrackEventDirtyFlag.StatusText);
end

function EncounterTimelineTrackEventMixin:OnTrackOrientationChanged(_trackOrientation)
	self:MarkDirty(EncounterTimelineTrackEventDirtyFlag.NameText);
	self:MarkDirty(EncounterTimelineTrackEventDirtyFlag.Orientation);
	self:MarkDirty(EncounterTimelineTrackEventDirtyFlag.StatusText);
end

function EncounterTimelineTrackEventMixin:Init(eventInfo, timer, state, track, trackSortIndex, blocked)
	EncounterTimelineTrackFrameMixin.Init(self, eventInfo, timer, state, track, trackSortIndex, blocked);

	-- The base Init method directly assigns fields without invoking the
	-- change callbacks which we rely on to kick off animations and set
	-- dirty flags; fire these manually here.

	self:OnEventStateChanged(state);
	self:OnEventTrackChanged(track, trackSortIndex);
	self:OnEventBlockStateChanged(blocked);

	-- Alpha updates need committing immediately as the intro animation will
	-- cause them to be ignored if the alpha change occurs while playing.
	--
	-- This includes icons which are alpha-toggled rather than vis-toggled.
	--
	-- Longer term, replace the fade animations with scripted animations as
	-- used by the timer display.

	self:SetIcon(eventInfo.iconFileID);
	self:UpdateBorderStyle();
	self:UpdateCountdown();
	self:UpdateFrameLevel();
	self:UpdateIconAlpha();
	self:UpdateIconography();
	self:UpdateStatusText();

	self:PlayIntroAnimation();
end

function EncounterTimelineTrackEventMixin:Reset()
	EncounterTimelineTrackFrameMixin.Reset(self);

	self:GetTrailTexture():SetAlpha(0);
	self:StopIntroAnimation();
	self:StopCancelAnimation();
	self:StopFinishAnimation();
	self:StopHighlightAnimation();
	self:StopPulseAnimation();
end

function EncounterTimelineTrackEventMixin:MarkDirty(flag)
	self.dirtyFlags:Set(flag);
end

function EncounterTimelineTrackEventMixin:MarkClean(flag)
	self.dirtyFlags:Clear(flag);
end

function EncounterTimelineTrackEventMixin:IsDirty(flag)
	if flag == nil then
		return self.dirtyFlags:IsAnySet();
	else
		return self.dirtyFlags:IsSet(flag);
	end
end

function EncounterTimelineTrackEventMixin:GetNameFontString()
	return self.NameText;
end

function EncounterTimelineTrackEventMixin:GetStatusFontString()
	return self.StatusText;
end

function EncounterTimelineTrackEventMixin:GetTrackAlphaCurve()
	return EncounterTimelineTrackAlphaCurve;
end

function EncounterTimelineTrackEventMixin:GetSeverityFrameLevelCurve()
	return EncounterTimelineSeverityFrameLevelCurve;
end

function EncounterTimelineTrackEventMixin:GetIconFrame()
	return self.IconContainer;
end

function EncounterTimelineTrackEventMixin:GetIndicatorContainer()
	return self.Indicators;
end

function EncounterTimelineTrackEventMixin:GetIndicatorGridLayout()
	local orientation = self:GetTrackOrientation();
	local initialAnchor;
	local direction;
	local offsetX = 0;
	local offsetY = 2;
	local paddingX = 0;
	local paddingY = 2;
	local horizontalSpacing = 19;
	local verticalSpacing = 16;

	if orientation:IsVertical() then
		offsetX, offsetY = offsetY, offsetX;
		paddingX, paddingY = paddingY, paddingX;
		horizontalSpacing, verticalSpacing = verticalSpacing, horizontalSpacing;
		initialAnchor = AnchorUtil.CreateAnchor("TOPLEFT", self:GetIndicatorContainer(), "TOPLEFT", offsetX, offsetY);
		direction = GridLayoutMixin.Direction.TopLeftToBottomRight;
	else
		initialAnchor = AnchorUtil.CreateAnchor("BOTTOMLEFT", self:GetIndicatorContainer(), "BOTTOMLEFT", offsetX, offsetY);
		direction = GridLayoutMixin.Direction.BottomLeftToTopRightVertical;
	end

	return initialAnchor, direction, paddingX, paddingY, horizontalSpacing, verticalSpacing;
end

function EncounterTimelineTrackEventMixin:GetCountdownFrame()
	return self.Countdown;
end

function EncounterTimelineTrackEventMixin:GetPulseAnimation()
	return self.PulseAnimation;
end

function EncounterTimelineTrackEventMixin:GetIntroAnimation()
	return self.IntroAnimation;
end

function EncounterTimelineTrackEventMixin:GetCancelAnimation()
	return self.CancelAnimation;
end

function EncounterTimelineTrackEventMixin:GetFinishAnimation()
	return self.FinishAnimation;
end

function EncounterTimelineTrackEventMixin:GetTrailTexture()
	return self.Trail;
end

function EncounterTimelineTrackEventMixin:GetTrailAlphaCurve()
	return EncounterTimelineTrailAlphaCurve;
end

function EncounterTimelineTrackEventMixin:GetTrailAtlas()
	return "combattimeline-line-icontrail";
end

function EncounterTimelineTrackEventMixin:CanShowCountdownDuration(duration)
	return duration ~= nil and duration > 0 and self:ShouldShowCountdown();
end

function EncounterTimelineTrackEventMixin:CanShowNameText(nameText)
	return nameText ~= nil and nameText ~= "" and self:ShouldShowText() and self:GetTrackOrientation():IsVertical();
end

function EncounterTimelineTrackEventMixin:CanShowStatusText(statusText)
	return statusText ~= nil and statusText ~= "" and self:ShouldShowText() and self:GetTrackOrientation():IsVertical();
end

function EncounterTimelineTrackEventMixin:SetIcon(iconFileID)
	-- Visibility of the icon frame must be forced as we have animations that
	-- hide it due to the use of TargetsHiddenOnFinishedAnimGroupTemplate.

	local iconFrame = self:GetIconFrame();
	iconFrame:SetIcon(iconFileID);
	iconFrame:Show();
end

function EncounterTimelineTrackEventMixin:ClearNameText()
	local fontString = self:GetNameFontString();
	fontString:ClearText();
	fontString:Hide();

	self:MarkDirty(EncounterTimelineTrackEventDirtyFlag.TextAnchors);
end

function EncounterTimelineTrackEventMixin:SetNameText(text, color)
	local fontString = self:GetNameFontString();
	fontString:SetText(text or "");
	fontString:SetTextColor(color:GetRGB());
	fontString:SetShown(self:CanShowNameText(text));

	self:MarkDirty(EncounterTimelineTrackEventDirtyFlag.TextAnchors);
end

function EncounterTimelineTrackEventMixin:SetStatusText(text)
	local fontString = self:GetStatusFontString();
	fontString:SetText(text or "");
	fontString:SetShown(self:CanShowStatusText(text));

	self:MarkDirty(EncounterTimelineTrackEventDirtyFlag.TextAnchors);
end

function EncounterTimelineTrackEventMixin:HighlightFrame()
	-- We piggy-back off the highlight notification to trigger both the
	-- highlight itself _and_ a pulse if we're below a specific duration
	-- and on the right track.

	self:PlayHighlightAnimation();
	self:MarkDirty(EncounterTimelineTrackEventDirtyFlag.PulseAnimation);
end

function EncounterTimelineTrackEventMixin:PlayIntroAnimation()
	-- We can't apply an 'not IsShown' guard here because the event frame is
	-- automatically shown by the parent view. We could change this, but
	-- no real point right now - feel free to do so in the future though (hi!).

	self:GetIntroAnimation():Play();

	-- Playing the intro animation while on a linear track should cause a
	-- cross-axis slide, too.

	local track, _trackSortIndex = self:GetEventTrack();
	local trackType = C_EncounterTimeline.GetTrackType(track);

	if trackType == Enum.EncounterTimelineTrackType.Linear then
		self:StartCrossAxisIntroTranslation();
	end
end

function EncounterTimelineTrackEventMixin:PlayCancelAnimation()
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

	self:DetachFrame();
end

function EncounterTimelineTrackEventMixin:PlayFinishAnimation()
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

	self:DetachFrame();
end

function EncounterTimelineTrackEventMixin:PlayHighlightAnimation()
	if not self:IsShown() then
		return;
	end

	self:GetIconFrame():PlayHighlightAnimation();
end

function EncounterTimelineTrackEventMixin:PlayPulseAnimation()
	self:GetPulseAnimation():Play();
end

function EncounterTimelineTrackEventMixin:StopIntroAnimation()
	self:GetIntroAnimation():Stop();
end

function EncounterTimelineTrackEventMixin:StopCancelAnimation()
	self:GetCancelAnimation():Stop();
end

function EncounterTimelineTrackEventMixin:StopFinishAnimation()
	self:GetFinishAnimation():Stop();
end

function EncounterTimelineTrackEventMixin:StopHighlightAnimation()
	self:GetIconFrame():StopHighlightAnimation();
end

function EncounterTimelineTrackEventMixin:StopPulseAnimation()
	self:GetPulseAnimation():Stop();
end

function EncounterTimelineTrackEventMixin:UpdateBorderStyle()
	local eventInfo = self:GetEventInfo();
	local iconFrame = self:GetIconFrame();

	iconFrame:SetDeadlyEffect(FlagsUtil.IsSet(eventInfo.icons, Enum.EncounterEventIconmask.DeadlyEffect));
	iconFrame:SetPaused(self:GetEventState() == Enum.EncounterTimelineEventState.Paused);
	iconFrame:SetQueued(self:GetEventTrack() == Enum.EncounterTimelineTrack.Queued);

	self:MarkClean(EncounterTimelineTrackEventDirtyFlag.BorderStyle);
end

function EncounterTimelineTrackEventMixin:UpdateCountdown()
	local timeRemaining = self:GetEventTimeRemaining();
	local countdownFrame = self:GetCountdownFrame();
	local eventState = self:GetEventState();

	if self:CanShowCountdownDuration(timeRemaining) and eventState == Enum.EncounterTimelineEventState.Active then
		-- Don't allow the countdown to be enabled if the icon container is
		-- showing a paused or queued icon. We return here to keep the
		-- dirty flag set so that we can poll this state and properly show
		-- the countdown when the icon has finished animating.

		if self:GetIconFrame():IsAnyIconShown() then
			return;
		end

		countdownFrame:SetCooldownDuration(timeRemaining);
		countdownFrame:Show();
	else
		countdownFrame:Clear();
	end

	self:MarkClean(EncounterTimelineTrackEventDirtyFlag.Countdown);
end

function EncounterTimelineTrackEventMixin:UpdateFrameLevel()
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

	self:MarkClean(EncounterTimelineTrackEventDirtyFlag.FrameLevel);
end

function EncounterTimelineTrackEventMixin:UpdateIconAlpha()
	local track = self:GetEventTrack();
	local alpha;

	if track ~= nil then
		alpha = self:GetTrackAlphaCurve():Evaluate(track);
	else
		alpha = 1.0;
	end

	self:GetIconFrame():SetAlpha(alpha);
	self:GetCountdownFrame():SetAlpha(alpha);

	self:MarkClean(EncounterTimelineTrackEventDirtyFlag.IconAlpha);
end

function EncounterTimelineTrackEventMixin:UpdateIconography()
	local indicators = self:GetIndicatorContainer();
	indicators:SetTexturesForEvent(self:GetEventID(), self:GetIndicatorIconMask());

	self:MarkClean(EncounterTimelineTrackEventDirtyFlag.Iconography);
end

function EncounterTimelineTrackEventMixin:UpdateNameText()
	local eventInfo = self:GetEventInfo();

	if eventInfo ~= nil then
		self:SetNameText(eventInfo.spellName or "", eventInfo.color);
	else
		self:ClearNametext();
	end
end

function EncounterTimelineTrackEventMixin:UpdateOrientation()
	local orientation = self:GetTrackOrientation();
	local trailTexture = self:GetTrailTexture();
	local iconScale = self:GetIconScale();

	trailTexture:ClearAllPoints();
	trailTexture:SetOrientedAtlas(orientation, self:GetTrailAtlas(), TextureKitConstants.UseAtlasSize);
	trailTexture:SetOrientedTexCoordToDefaults(orientation);
	trailTexture:SetOrientedPoint(orientation, "END", self, "START", 10, 0);

	local indicators = self:GetIndicatorContainer();
	indicators:ClearAllPoints();

	if orientation:IsVertical() then
		indicators:SetPoint("LEFT", self:GetIconFrame(), "RIGHT");
	else
		indicators:SetPoint("BOTTOM", self:GetIconFrame(), "TOP");
	end

	indicators:ApplyLayout(self:GetIndicatorGridLayout());

	-- Not really orientation-based, but it's not worth the hassle of making
	-- another dirty flag just for these two bits of state.

	self:GetIconFrame():SetScale(iconScale);
	self:GetCountdownFrame():SetScale(iconScale);

	self:MarkClean(EncounterTimelineTrackEventDirtyFlag.Orientation);
end

function EncounterTimelineTrackEventMixin:UpdatePointOffsets()
	local orientation = self:GetTrackOrientation();
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

function EncounterTimelineTrackEventMixin:UpdatePulseAnimation()
	local state = self:GetEventState();
	local track = self:GetEventTrack();
	local timeRemaining = self:GetEventTimeRemaining();
	local pulseDuration = self:GetHighlightTime();

	if state == Enum.EncounterTimelineEventState.Active and track == Enum.EncounterTimelineTrack.Short and timeRemaining ~= nil and timeRemaining <= pulseDuration then
		self:PlayPulseAnimation();
	else
		self:StopPulseAnimation();
	end

	self:MarkClean(EncounterTimelineTrackEventDirtyFlag.PulseAnimation);
end

function EncounterTimelineTrackEventMixin:UpdateStatusText()
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
	self:MarkClean(EncounterTimelineTrackEventDirtyFlag.StatusText);
end

function EncounterTimelineTrackEventMixin:UpdateTextAnchors()
	local nameFontString = self:GetNameFontString();
	local statusFontString = self:GetStatusFontString();
	local iconScale = self:GetIconScale();

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

	self:MarkClean(EncounterTimelineTrackEventDirtyFlag.TextAnchors);
end

function EncounterTimelineTrackEventMixin:UpdateTrailAlpha()
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
