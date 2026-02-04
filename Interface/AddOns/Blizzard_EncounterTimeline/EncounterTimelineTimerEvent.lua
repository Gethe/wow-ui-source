EncounterTimelineTimerEventDirtyFlag = {
	-- Triggers update of event frame point offsets.
	Position = bit.lshift(1, 0),
	-- Triggers update of spell name text strings.
	NameText = bit.lshift(1, 1),
	-- Triggers update of child region visibility and anchoring.
	Layout = bit.lshift(1, 2),
	-- Triggers update of spell icon texture.
	IconTexture = bit.lshift(1, 3),
	-- Triggers update of spell icon and indicator scale, as well as event frame height.
	IconScale = bit.lshift(1, 4),
	-- Triggers update of spell support iconography assignments.
	IndicatorIcons = bit.lshift(1, 5),
	-- Triggers update of timer bar data source.
	TimerBar = bit.lshift(1, 6),
	-- Triggers update of status-based spell icon bordering.
	IconBorder = bit.lshift(1, 7),
};

EncounterTimelineTimerEventDirtyFlag.All = Flags_CreateMaskFromTable(EncounterTimelineTimerEventDirtyFlag);

EncounterTimelineTimerEventScriptedAnimation = {
	Intro = 1,
	Outro = 2,
};

local function SetPointWithHorizontalFlip(region, point, relativeTo, relativePoint, x, y, flipped)
	if flipped then
		AnchorUtil.SetMirroredPointAlongHorizontalAxis(region, point, relativeTo, relativePoint, x, y);
	else
		region:SetPoint(point, relativeTo, relativePoint, x, y);
	end
end

EncounterTimelineTimerEventMixin = CreateFromMixins(EncounterTimelineEventFrameMixin, EncounterTimelineScriptedAnimatableMixin, EncounterTimelineTimerSettingsMixin);

function EncounterTimelineTimerEventMixin:OnLoad()
	EncounterTimelineEventFrameMixin.OnLoad(self);
	EncounterTimelineScriptedAnimatableMixin.OnLoad(self);
	EncounterTimelineTimerSettingsMixin.OnLoad(self);

	self.dirtyFlags = CreateFlags(EncounterTimelineTimerEventDirtyFlag.All);
	self.frameAlpha = 0;
	self.frameHeightBase = self:GetHeight();
	self.frameOffsetX = 0;
	self.frameOffsetY = 0;
	self.frameTargetY = nil;
	self.timerSortIndex = nil;
	self.lastTrackAlpha = 1.0;
end

function EncounterTimelineTimerEventMixin:Init(eventInfo, timer, state, track, trackSortIndex, blocked)
	EncounterTimelineEventFrameMixin.Init(self, eventInfo, timer, state, track, trackSortIndex, blocked);

	self.timerSortIndex = math.huge;

	-- Partial immediate update on initialization; this should just cover the
	-- most important aspects of the frame - anything outside of this set if
	-- dirty will be updated in the OnUpdate handler, but that may be delayed
	-- by a tick.

	self:UpdateCountdownText();
	self:UpdateIconBorder();
	self:UpdateIconTexture();
	self:UpdateIndicatorIcons();
	self:UpdateNameText();
	self:UpdateTimerBar();
	self:UpdateTimerSpark();
end

function EncounterTimelineTimerEventMixin:Reset()
	EncounterTimelineEventFrameMixin.Reset(self);

	self:CancelMovementAnimation();
	self:CancelScriptedAnimation();

	-- Ensure the timer bar doesn't keep a reference to the timer object to
	-- this event, as it will prevent the timeline from cleaning up resources.
	self:GetTimerStatusBar():SetMinMaxValues(0, 0);

	self.frameAlpha = 0;
	self.frameOffsetX = 0;
	self.frameOffsetY = 0;
	self.timerSortIndex = nil;
	self.lastTrackAlpha = 1.0;
end

function EncounterTimelineTimerEventMixin:OnShow()
	EncounterTimelineEventFrameMixin.OnShow(self);

	-- Immediate alpha and position update on show to flush the intro animation.
	self:UpdateAlpha();
	self:UpdatePosition();
end

function EncounterTimelineTimerEventMixin:OnHide()
	EncounterTimelineEventFrameMixin.OnHide(self);

	self:CancelMovementAnimation();
	self:CancelScriptedAnimation();
end

function EncounterTimelineTimerEventMixin:OnUpdate(_elapsedTime)
	-- Movement animations and position updates are processed first as these
	-- can set dirty flags very frequently. Doing this first often saves us
	-- a strip into UpdateDirty, as Position is usually the only flag set.

	if self:UpdateMovementAnimation() then
		self:UpdatePosition();
	end

	if self:IsDirty() then
		self:UpdateDirty();
	end

	-- The remainder of these functions are expected to be dirty every tick
	-- due to dependencies on elapsed duration of the event.

	self:UpdateAlpha();
	self:UpdateCountdownText();
	self:UpdateTimerSpark();
end

function EncounterTimelineTimerEventMixin:OnEventStateChanged(state)
	self:MarkDirty(EncounterTimelineTimerEventDirtyFlag.IconBorder);

	if state == Enum.EncounterTimelineEventState.Canceled then
		self:AnimateCancel();
	elseif state == Enum.EncounterTimelineEventState.Finished then
		self:AnimateFinish();
	end
end

function EncounterTimelineTimerEventMixin:OnEventTrackChanged(track, _trackSortIndex)
	self:MarkDirty(EncounterTimelineTimerEventDirtyFlag.IconBorder);

	-- Timer events can transition to hidden tracks if the user has disabled
	-- queued or long events; in this case, treat them as a cancelation and
	-- hide them.

	local trackType = C_EncounterTimeline.GetTrackType(track);

	if trackType == Enum.EncounterTimelineTrackType.Hidden then
		self:AnimateCancel();
	end
end

function EncounterTimelineTimerEventMixin:OnEventBlockStateChanged(_blocked)
	self:MarkDirty(EncounterTimelineTimerEventDirtyFlag.IconBorder);
end

function EncounterTimelineTimerEventMixin:OnIconScaleChanged(_iconScale)
	-- Icons scale changes need to be flushed immediately as they impact the
	-- size of the frame, which is used by the parent view for its own stuff.

	self:UpdateIconScale();
end

function EncounterTimelineTimerEventMixin:OnIndicatorIconMaskChanged(_indicatorIconMask)
	-- Icon mask changes invalidate layout as we toggle visibility of the
	-- indicator icon container if all icons are masked.

	self:MarkDirty(EncounterTimelineTimerEventDirtyFlag.Layout);
	self:MarkDirty(EncounterTimelineTimerEventDirtyFlag.IndicatorIcons);
end

function EncounterTimelineTimerEventMixin:OnFlipHorizontallyChanged(_flipHorizontally)
	self:MarkDirty(EncounterTimelineTimerEventDirtyFlag.Layout);
end

function EncounterTimelineTimerEventMixin:OnTimerFillDirectionChanged(_timerFillDirection)
	self:MarkDirty(EncounterTimelineTimerEventDirtyFlag.TimerBar);
end

function EncounterTimelineTimerEventMixin:OnShowCountdownChanged(_showCountdown)
	self:MarkDirty(EncounterTimelineTimerEventDirtyFlag.Layout);
end

function EncounterTimelineTimerEventMixin:OnShowIconChanged(_showIcon)
	self:MarkDirty(EncounterTimelineTimerEventDirtyFlag.Layout);
end

function EncounterTimelineTimerEventMixin:OnShowTimerSparkChanged(_showTimerSpark)
	self:MarkDirty(EncounterTimelineTimerEventDirtyFlag.Layout);
end

function EncounterTimelineTimerEventMixin:OnAnimatedAlphaChanged(_alpha)
	-- No-op; alpha is updated every tick due to a duration dependency.
end

function EncounterTimelineTimerEventMixin:OnHorizontalOffsetChanged(_offset)
	self:MarkDirty(EncounterTimelineTimerEventDirtyFlag.Position);
end

function EncounterTimelineTimerEventMixin:OnVerticalOffsetChanged(_offset)
	self:MarkDirty(EncounterTimelineTimerEventDirtyFlag.Position);
end

function EncounterTimelineTimerEventMixin:ShouldReleaseFrameOnHide()
	-- Don't automatically release timer frames when hidden. The parent list
	-- frame toggles visibility of frames if there are too many of them,
	-- and this would conflict with that.

	return false;
end

function EncounterTimelineTimerEventMixin:HighlightFrame()
	self:GetIconContainer():PlayHighlightAnimation();
end

function EncounterTimelineTimerEventMixin:GetAnimatedAlpha()
	return self.frameAlpha;
end

function EncounterTimelineTimerEventMixin:GetHorizontalOffset()
	return self.frameOffsetX;
end

function EncounterTimelineTimerEventMixin:GetIndicatorContainer()
	return self.IndicatorContainer;
end

function EncounterTimelineTimerEventMixin:GetIndicatorGridLayout()
	local initialAnchor;
	local direction;
	local offsetX = 0;
	local offsetY = 0;
	local paddingX = 2;
	local paddingY = 2;
	local horizontalSpacing = 14;
	local verticalSpacing = 14;

	if self:ShouldFlipHorizontally() then
		initialAnchor = AnchorUtil.CreateAnchor("TOPLEFT", self:GetIndicatorContainer(), "TOPLEFT", offsetX, offsetY);
		direction = GridLayoutMixin.Direction.TopLeftToBottomRight;
	else
		initialAnchor = AnchorUtil.CreateAnchor("TOPRIGHT", self:GetIndicatorContainer(), "TOPRIGHT", offsetX, offsetY);
		direction = GridLayoutMixin.Direction.TopRightToBottomLeft;
	end

	return initialAnchor, direction, paddingX, paddingY, horizontalSpacing, verticalSpacing;
end

function EncounterTimelineTimerEventMixin:GetIconContainer()
	return self.IconContainer;
end

function EncounterTimelineTimerEventMixin:GetCountdownFontString()
	return self:GetTimerStatusBar().Duration;
end

function EncounterTimelineTimerEventMixin:GetNameFontString()
	return self:GetTimerStatusBar().Name;
end

function EncounterTimelineTimerEventMixin:GetTimerSparkTexture()
	return self:GetTimerStatusBar().Spark;
end

function EncounterTimelineTimerEventMixin:GetTimerStatusBar()
	return self.Bar;
end

function EncounterTimelineTimerEventMixin:GetTimerSortIndex()
	return self.timerSortIndex;
end

function EncounterTimelineTimerEventMixin:GetTrackAlphaCurve()
	return EncounterTimelineTrackAlphaCurve;
end

function EncounterTimelineTimerEventMixin:GetTrackAlpha()
	local track, _trackSortIndex = self:GetEventTrack();

	-- Events that transition to indeterminate tracks (or get outright deleted)
	-- should use the last alpha they previously had. This resolves some issues
	-- where the alpha for a long event would increase during its hide animation.

	if track ~= nil and track ~= Enum.EncounterTimelineTrack.Indeterminate then
		local curve = self:GetTrackAlphaCurve();
		return curve:Evaluate(track);
	else
		return self.lastTrackAlpha;
	end
end

function EncounterTimelineTimerEventMixin:GetTrackDividerHorizontalInsets()
	-- This is used by the parent view to inset the divider texture it places
	-- between short and long events such that it lines up with our status
	-- bar for display. We can't just anchor straight to the bar as it would
	-- cause the divider to move on our outro translation animation.

	local offsetLeft = 85;
	local offsetRight = -15;

	if not self:ShouldShowIndicators() then
		offsetLeft = offsetLeft - 36;
	end

	if not self:ShouldShowIcon() then
		offsetLeft = offsetLeft - 38;
	end

	if self:ShouldFlipHorizontally() then
		offsetLeft, offsetRight = -offsetRight, -offsetLeft;
	end

	return offsetLeft, offsetRight;
end

function EncounterTimelineTimerEventMixin:GetVerticalOffset()
	return self.frameOffsetY;
end

function EncounterTimelineTimerEventMixin:IsDirty(flag)
	if flag == nil then
		return self.dirtyFlags:IsAnySet();
	else
		return self.dirtyFlags:IsSet(flag);
	end
end

function EncounterTimelineTimerEventMixin:MarkDirty(flag)
	self.dirtyFlags:Set(flag);
end

function EncounterTimelineTimerEventMixin:MarkClean(flag)
	self.dirtyFlags:Clear(flag);
end

function EncounterTimelineTimerEventMixin:SetAnimatedAlpha(alpha)
	if not ApproximatelyEqual(self.frameAlpha, alpha) then
		self.frameAlpha = alpha;
		self:OnAnimatedAlphaChanged(alpha);
	end
end

function EncounterTimelineTimerEventMixin:SetHorizontalOffset(offset)
	if not ApproximatelyEqual(self.frameOffsetX, offset) then
		self.frameOffsetX = offset;
		self:OnHorizontalOffsetChanged(offset);
	end
end

function EncounterTimelineTimerEventMixin:SetTimerSortIndex(index)
	self.timerSortIndex = index;
end

function EncounterTimelineTimerEventMixin:SetVerticalOffset(offset)
	if not ApproximatelyEqual(self.frameOffsetY, offset) then
		self.frameOffsetY = offset;
		self:OnVerticalOffsetChanged(offset);
	end
end

function EncounterTimelineTimerEventMixin:ShouldShowIndicators()
	return self:GetIndicatorIconMask() ~= 0;
end

function EncounterTimelineTimerEventMixin:AnimateCancel()
	if not self:IsShown() then
		self:ReleaseFrame();
		return;
	end

	-- Durations are a bit different here; the fade should finish first as we
	-- want the frame to disappear before the finish callback executes to give
	-- some dead time before the list collapses empty spaces after releasing
	-- the frame.

	local outroFadeDuration = self.cancelAnimationFadeDuration;
	local outroDuration = self.cancelAnimationDuration;

	local function OnAnimationUpdate(region, elapsed, _duration)
		local alphaProgress = Saturate(elapsed / outroFadeDuration);
		local alphaValue = 1 - EasingUtil.InCubic(alphaProgress);

		region:SetAnimatedAlpha(alphaValue);
	end

	local function OnAnimationFinish(region)
		region:ReleaseFrame();
	end

	self:CancelScriptedAnimation();
	self:StartScriptedAnimation(EncounterTimelineTimerEventScriptedAnimation.Outro, OnAnimationUpdate, outroDuration, OnAnimationFinish);

	-- Detach the frame to prevent it from being cleaned up by the parent list
	-- when this event is removed from its data provider. Our finish callback
	-- will ensure the frame is properly released.

	self:DetachFrame();
end

function EncounterTimelineTimerEventMixin:AnimateFinish()
	if not self:IsShown() then
		self:ReleaseFrame();
		return;
	end

	-- Durations are a bit different here; the fade should finish first as we
	-- want the frame to disappear before the finish callback executes to give
	-- some dead time before the list collapses empty spaces after releasing
	-- the frame.
	--
	-- We don't want the move to visually progress the full distance as it's
	-- set high to make it travel further in the opposite direction when the
	-- animation starts. So, we make its duration larger than that of the
	-- animation so that it never actually completes.

	local outroFadeDuration = self.finishAnimationFadeDuration;
	local outroMoveDuration = self.finishAnimationMoveDuration;
	local outroMoveDistance = self.finishAnimationMoveDistance;
	local outroDuration = self.finishAnimationDuration;

	if self:ShouldFlipHorizontally() then
		outroMoveDistance = outroMoveDistance * -1;
	end

	local function OnAnimationUpdate(region, elapsed, _duration)
		local alphaProgress = Saturate(elapsed / outroFadeDuration);
		local alphaValue = 1 - EasingUtil.InCubic(alphaProgress);

		region:SetAnimatedAlpha(alphaValue);

		local translateProgress = Saturate(elapsed / outroMoveDuration);
		local translateOffset = Lerp(0, outroMoveDistance, EasingUtil.InBack(translateProgress));

		region:SetHorizontalOffset(translateOffset);
	end

	local function OnAnimationFinish(region)
		region:ReleaseFrame();
	end

	self:CancelScriptedAnimation();
	self:StartScriptedAnimation(EncounterTimelineTimerEventScriptedAnimation.Outro, OnAnimationUpdate, outroDuration, OnAnimationFinish);

	-- Detach the frame to prevent it from being cleaned up by the parent list
	-- when this event is removed from its data provider. Our finish callback
	-- will ensure the frame is properly released.

	self:DetachFrame();
end

function EncounterTimelineTimerEventMixin:AnimateShow()
	local introDuration = self.showAnimationDuration;

	local function OnAnimationUpdate(region, elapsed, duration)
		local progress = Saturate(elapsed / duration);
		local alpha = EasingUtil.InCubic(progress);

		region:SetAnimatedAlpha(alpha);
	end

	self:CancelScriptedAnimation();
	self:StartScriptedAnimation(EncounterTimelineTimerEventScriptedAnimation.Intro, OnAnimationUpdate, introDuration);
	self:SetAnimatedAlpha(0.0);
	self:Show();
end

function EncounterTimelineTimerEventMixin:AnimateMovement(offset)
	-- Movement animations are skipped if we're presently playing an outro
	-- animation on this frame. Outro animations include a cross-axis
	-- translation (horizontal) and we don't want the frame to slide at
	-- a diagonal and look too weird when it's going off.

	if self:IsPlayingScriptedAnimation(EncounterTimelineTimerEventScriptedAnimation.Outro) then
		return;
	end

	-- Movement animations are handled separately from the scripted animation
	-- system as we want them to apply concurrently with any intro fades we
	-- might be doing, and at present it's hard to reconcile that with the
	-- (singular) lock the script animation system forces. Further, we want
	-- to implement this translation in terms of a frame-delta lerp.

	self.frameTargetY = offset;
end

function EncounterTimelineTimerEventMixin:CancelMovementAnimation()
	self.frameTargetY = nil;
end

function EncounterTimelineTimerEventMixin:FinishMovementAnimation()
	if self.frameTargetY ~= nil then
		self:SetVerticalOffset(self.frameTargetY);
		self.frameTargetY = nil;
	end
end

function EncounterTimelineTimerEventMixin:UpdateMovementAnimation()
	local frameTargetY = self.frameTargetY;

	if frameTargetY == nil then
		-- No movement animation is in progress.
		return false;
	end

	local frameOffsetY = FrameDeltaLerp(self.frameOffsetY, frameTargetY, self.movementAnimationSpeed);
	local distance = math.abs(frameOffsetY - frameTargetY);

	if distance <= 1 then
		-- We're close enough to the target; snap to it and stop animating.
		self:SetVerticalOffset(frameTargetY);
		self.frameTargetY = nil;
	else
		self:SetVerticalOffset(frameOffsetY);
	end

	return true;
end

function EncounterTimelineTimerEventMixin:UpdateDirty()
	local dirtyFlags = self.dirtyFlags;

	if dirtyFlags:IsSet(EncounterTimelineTimerEventDirtyFlag.Position) then
		self:UpdatePosition();
	end

	if dirtyFlags:IsSet(EncounterTimelineTimerEventDirtyFlag.NameText) then
		self:UpdateNameText();
	end

	if dirtyFlags:IsSet(EncounterTimelineTimerEventDirtyFlag.Layout) then
		self:UpdateLayout();
	end

	if dirtyFlags:IsSet(EncounterTimelineTimerEventDirtyFlag.IconTexture) then
		self:UpdateIconTexture();
	end

	if dirtyFlags:IsSet(EncounterTimelineTimerEventDirtyFlag.IconScale) then
		self:UpdateIconScale();
	end

	if dirtyFlags:IsSet(EncounterTimelineTimerEventDirtyFlag.IndicatorIcons) then
		self:UpdateIndicatorIcons();
	end

	if dirtyFlags:IsSet(EncounterTimelineTimerEventDirtyFlag.TimerBar) then
		self:UpdateTimerBar();
	end

	if dirtyFlags:IsSet(EncounterTimelineTimerEventDirtyFlag.IconBorder) then
		self:UpdateIconBorder();
	end
end

function EncounterTimelineTimerEventMixin:UpdateAlpha()
	local animatedAlpha = self:GetAnimatedAlpha();
	local trackAlpha = self:GetTrackAlpha();

	self.lastTrackAlpha = trackAlpha;
	self:SetAlpha(animatedAlpha * trackAlpha);
end

function EncounterTimelineTimerEventMixin:UpdateCountdownText()
	if not self:ShouldShowCountdown() then
		return;
	end

	local durationFontString = self:GetCountdownFontString();
	local timeRemaining = self:GetEventTimeRemaining();

	if timeRemaining ~= nil and timeRemaining <= 0 then
		durationFontString:ClearText("");
	elseif timeRemaining < 1 then
		durationFontString:SetFormattedText("%.1F", timeRemaining);
	else
		durationFontString:SetText(EncounterTimelineSecondsFormatter:Format(timeRemaining));
	end
end

function EncounterTimelineTimerEventMixin:UpdateCountdownLayout()
	local countdownFontString = self:GetCountdownFontString();
	local flipped = self:ShouldFlipHorizontally();
	local offsetX = -5;
	local offsetY = 0;

	countdownFontString:ClearAllPoints();
	SetPointWithHorizontalFlip(countdownFontString, "RIGHT", self:GetTimerStatusBar(), "RIGHT", offsetX, offsetY, flipped);
	countdownFontString:SetShown(self:ShouldShowCountdown());
end

function EncounterTimelineTimerEventMixin:UpdateIconLayout()
	local iconContainer = self:GetIconContainer();
	local flipped = self:ShouldFlipHorizontally();
	local offsetX = 2;
	local offsetY = 0;

	iconContainer:ClearAllPoints();
	SetPointWithHorizontalFlip(iconContainer, "LEFT", self:GetIndicatorContainer(), "RIGHT", offsetX, offsetY, flipped);
	iconContainer:SetShown(self:ShouldShowIcon());
end

function EncounterTimelineTimerEventMixin:UpdateIndicatorLayout()
	local indicatorContainer = self:GetIndicatorContainer();
	local flipped = self:ShouldFlipHorizontally();
	local offsetX = 0;
	local offsetY = 0;

	indicatorContainer:ClearAllPoints();
	SetPointWithHorizontalFlip(indicatorContainer, "LEFT", self, "LEFT", offsetX, offsetY, flipped);
	indicatorContainer:ApplyLayout(self:GetIndicatorGridLayout());
	indicatorContainer:SetShown(self:ShouldShowIndicators());
end

function EncounterTimelineTimerEventMixin:UpdateNameTextLayout()
	local nameFontString = self:GetNameFontString();
	local flipped = self:ShouldFlipHorizontally();
	local startOffsetX = 5;
	local startOffsetY = 0;
	local endOffsetX = -10;
	local endOffsetY = 0;
	local alignment = flipped and "RIGHT" or "LEFT";

	-- Partial point clearing; we want the TOP/BOTTOM anchors in XML to
	-- remain statically set as they prevent wrapping of the string.

	nameFontString:ClearPoint("LEFT");
	nameFontString:ClearPoint("RIGHT");
	SetPointWithHorizontalFlip(nameFontString, "LEFT", self:GetTimerStatusBar(), "LEFT", startOffsetX, startOffsetY, flipped);
	SetPointWithHorizontalFlip(nameFontString, "RIGHT", self:GetCountdownFontString(), "LEFT", endOffsetX, endOffsetY, flipped);

	-- Force-resolve rects before setting justification as sometimes the
	-- fontstrings get stuck with the old alignment.

	nameFontString:GetRect();
	nameFontString:SetJustifyH(alignment);
end

function EncounterTimelineTimerEventMixin:UpdateTimerBarLayout()
	local timerBar = self:GetTimerStatusBar();
	local flipped = self:ShouldFlipHorizontally();
	local startOffsetX = 4;
	local startOffsetY = 0;
	local endOffsetX = -4;
	local endOffsetY = 0;
	local fillStyle = flipped and Enum.StatusBarFillStyle.Reverse or Enum.StatusBarFillStyle.Standard;

	timerBar:ClearAllPoints();
	SetPointWithHorizontalFlip(timerBar, "LEFT", self:GetIconContainer(), "RIGHT", startOffsetX, startOffsetY, flipped);
	SetPointWithHorizontalFlip(timerBar, "RIGHT", self, "RIGHT", endOffsetX, endOffsetY, flipped);
	timerBar:SetFillStyle(fillStyle);
end

function EncounterTimelineTimerEventMixin:UpdateTimerSparkLayout()
	local timerSpark = self:GetTimerSparkTexture();
	local flipped = self:ShouldFlipHorizontally();
	local offsetX = 0;
	local offsetY = 0;

	timerSpark:ClearAllPoints();
	SetPointWithHorizontalFlip(timerSpark, "CENTER", self:GetTimerStatusBar():GetStatusBarTexture(), "RIGHT", offsetX, offsetY, flipped);
	timerSpark:SetShown(self:ShouldShowTimerSpark());
end

function EncounterTimelineTimerEventMixin:UpdateLayout()
	self:UpdateCountdownLayout();
	self:UpdateIconLayout();
	self:UpdateIndicatorLayout();
	self:UpdateNameTextLayout();
	self:UpdateTimerBarLayout();
	self:UpdateTimerSparkLayout();

	self:MarkClean(EncounterTimelineTimerEventDirtyFlag.Layout);
end

function EncounterTimelineTimerEventMixin:UpdateIconBorder()
	local eventInfo = self:GetEventInfo();
	local state = self:GetEventState();
	local track, _trackSortIndex = self:GetEventTrack();

	local iconContainer = self:GetIconContainer();

	iconContainer:SetDeadlyEffect(FlagsUtil.IsSet(eventInfo.icons, Enum.EncounterEventIconmask.DeadlyEffect));
	iconContainer:SetPaused(state == Enum.EncounterTimelineEventState.Paused);

	if not EncounterTimelineUtil.IsTerminalEventState(state) then
		iconContainer:SetQueued(track == Enum.EncounterTimelineTrack.Queued);
	else
		iconContainer:SetQueued(false);
	end

	self:MarkClean(EncounterTimelineTimerEventDirtyFlag.IconBorder);
end

function EncounterTimelineTimerEventMixin:UpdateIconScale()
	local scale = self:GetIconScale();

	self:GetIconContainer():SetScale(scale);
	self:GetIndicatorContainer():SetScale(scale);

	-- We also apply the icon scale to our overall frame height for parent
	-- layout reasons. This is capped at a minimum of 1 as we only need this
	-- scale to grow the frame, not shrink it.

	self:SetHeight(self.frameHeightBase * math.max(1, scale));
	self:MarkClean(EncounterTimelineTimerEventDirtyFlag.IconScale);
end

function EncounterTimelineTimerEventMixin:UpdateIconTexture()
	local eventInfo = self:GetEventInfo();

	self:GetIconContainer():SetIcon(eventInfo and eventInfo.iconFileID or nil);
	self:MarkClean(EncounterTimelineTimerEventDirtyFlag.IconTexture);
end

function EncounterTimelineTimerEventMixin:UpdateIndicatorIcons()
	local indicatorContainer = self:GetIndicatorContainer();
	indicatorContainer:SetTexturesForEvent(self:GetEventID(), self:GetIndicatorIconMask());

	self:MarkClean(EncounterTimelineTimerEventDirtyFlag.IndicatorIcons);
end

function EncounterTimelineTimerEventMixin:UpdateNameText()
	local nameFontString = self:GetNameFontString();
	local eventInfo = self:GetEventInfo();

	nameFontString:SetText(eventInfo and eventInfo.spellName or "");

	self:MarkClean(EncounterTimelineTimerEventDirtyFlag.NameText);
end

function EncounterTimelineTimerEventMixin:UpdatePosition()
	self:SetPointsOffset(self:GetHorizontalOffset(), math.floor(self:GetVerticalOffset()));
	self:MarkClean(EncounterTimelineTimerEventDirtyFlag.Position);
end

function EncounterTimelineTimerEventMixin:UpdateTimerBar()
	local eventInfo = self:GetEventInfo();
	local timerBar = self:GetTimerStatusBar();
	local timerFillDirection = self:GetTimerFillDirection();
	local timerDuration = self:GetEventTimer();
	local timerInterpolation = Enum.StatusBarInterpolation.Immediate;

	-- Note that the duration objects yielded by the timeline API use a custom
	-- clock source internally that means they'll automatically account for
	-- pausing.
	--
	-- This means the timer only needs setting once on initialization or when
	-- event frame settings change.

	timerBar:SetTimerDuration(timerDuration, timerInterpolation, timerFillDirection);
	timerBar:SetStatusBarColor(eventInfo.color:GetRGB());

	self:MarkClean(EncounterTimelineTimerEventDirtyFlag.TimerBar);
end

function EncounterTimelineTimerEventMixin:UpdateTimerSpark()
	if not self:ShouldShowTimerSpark() then
		return;
	end

	local sparkTexture = self:GetTimerSparkTexture();
	local timeRemaining = self:GetEventTimeRemaining();
	sparkTexture:SetShown(timeRemaining ~= nil and timeRemaining > 0);
end
