EncounterTimelineTimerViewDirtyFlag = {
	TimerSorting = bit.lshift(1, 0),
	TimerLayout = bit.lshift(1, 1),
	Size = bit.lshift(1, 2),
	TrackDivider = bit.lshift(1, 3),
};

EncounterTimelineTimerViewDirtyFlag.All = Flags_CreateMaskFromTable(EncounterTimelineTimerViewDirtyFlag);

local function SetPointWithVerticalFlip(region, point, relativeTo, relativePoint, x, y, flipped)
	if flipped then
		AnchorUtil.SetMirroredPointAlongVerticalAxis(region, point, relativeTo, relativePoint, x, y);
	else
		region:SetPoint(point, relativeTo, relativePoint, x, y);
	end
end

EncounterTimelineTimerViewMixin = CreateFromMixins(EncounterTimelineViewMixin, EncounterTimelineTimerViewSettingsMixin);

function EncounterTimelineTimerViewMixin:OnLoad()
	EncounterTimelineViewMixin.OnLoad(self);
	EncounterTimelineTimerViewSettingsMixin.OnLoad(self);

	self.dirtyFlags = CreateFlags(EncounterTimelineTimerViewDirtyFlag.All);

	local templateInfo = C_XMLUtil.GetTemplateInfo(self.timerTemplate);
	self.timerHeight = templateInfo.height;
	self.timerWidth = templateInfo.width;

	self.timerFramesDetached = {};
	self.timerFramesSorted = {};
	self.sortInvalidationAccumulator = CreateAccumulator();

	-- These are set dynamically on timer layout.
	self.trackDividerOffsetLeft = nil;
	self.trackDividerOffsetRight = nil;
	self.trackDividerOffsetY = nil;

	self:RegisterEventFramePool("Frame", self.timerTemplate);
end

function EncounterTimelineTimerViewMixin:OnShow()
	EncounterTimelineViewMixin.OnShow(self);

	self:UpdateBackground();
end

function EncounterTimelineTimerViewMixin:OnUpdate(elapsedTime)
	-- If there's a mixture of active and paused events simultaneously present
	-- on the timeline then they'll progress at different rates; this means
	-- we need to do some extra work to sort them.
	--
	-- We throttle this logic as it doesn't need to be immediately responsive.

	if self:ShouldSortTimersOnUpdate() then
		if self.sortInvalidationAccumulator:Add(elapsedTime) >= self:GetTimerResortPeriod() then
			self:MarkDirty(EncounterTimelineTimerViewDirtyFlag.TimerSorting);
			self.sortInvalidationAccumulator:Reset();
		end
	end

	if self:IsDirty() then
		self:OnDirtyUpdate();
	end
end

function EncounterTimelineTimerViewMixin:OnDirtyUpdate(_elapsedTime)
	local dirtyFlags = self.dirtyFlags;

	-- Ordering dependency; sorting must be processed before updating the
	-- event list as sorting can invalidate layout, which can itself then
	-- invalidate the divider.

	if dirtyFlags:IsSet(EncounterTimelineTimerViewDirtyFlag.TimerSorting) then
		self:UpdateTimerSorting();
	end

	-- Layout and divider positioning obey soft requests to lock the layout
	-- during animations. This only applies to tick-driven updates; manual
	-- calls to Update functions are permitted to bypass the lock.

	if not self:ShouldLockTimerLayout() then
		if dirtyFlags:IsSet(EncounterTimelineTimerViewDirtyFlag.TimerLayout) then
			local allowMovementAnimations = true;
			self:UpdateTimerLayout(allowMovementAnimations);
		end

		if dirtyFlags:IsSet(EncounterTimelineTimerViewDirtyFlag.TrackDivider) then
			self:UpdateTrackDivider();
		end
	end

	-- Size has no ordering dependencies and can be done whenever.

	if dirtyFlags:IsSet(EncounterTimelineTimerViewDirtyFlag.Size) then
		self:UpdateSize();
	end
end

function EncounterTimelineTimerViewMixin:OnEventFrameAcquired(eventFrame, eventID, isNewObject)
	EncounterTimelineViewMixin.OnEventFrameAcquired(self, eventFrame, eventID, isNewObject);

	self:MarkDirty(EncounterTimelineTimerViewDirtyFlag.TimerSorting);
end

function EncounterTimelineTimerViewMixin:OnEventFrameDetached(eventFrame)
	EncounterTimelineViewMixin.OnEventFrameDetached(self, eventFrame);

	-- We keep track of detached event frames to lock animations on the
	-- list. This flag *must* be cleared when the frame is released.

	self.timerFramesDetached[eventFrame] = true;
end

function EncounterTimelineTimerViewMixin:OnEventFrameReleased(eventFrame)
	EncounterTimelineViewMixin.OnEventFrameReleased(self, eventFrame);

	self.timerFramesDetached[eventFrame] = nil;
	self:MarkDirty(EncounterTimelineTimerViewDirtyFlag.TimerSorting);
end

function EncounterTimelineTimerViewMixin:OnEventTrackChanged(eventID, track, trackSortIndex)
	EncounterTimelineViewMixin.OnEventTrackChanged(self, eventID, track, trackSortIndex);

	-- Track changes for events require a re-layout to position the divider
	-- texture between short and long events.

	self:MarkDirty(EncounterTimelineTimerViewDirtyFlag.TimerLayout);
end

function EncounterTimelineTimerViewMixin:OnBackgroundAlphaChanged(_backgroundAlpha)
	self:UpdateBackground();
end

function EncounterTimelineTimerViewMixin:OnFlipHorizontallyChanged(flipHorizontally)
	EncounterTimelineViewMixin.OnFlipHorizontallyChanged(self, flipHorizontally);

	-- Horizontal flip has an impact on divider insets, forcing re-layout.

	local allowMovementAnimations = false;
	self:UpdateTimerLayout(allowMovementAnimations);
end

function EncounterTimelineTimerViewMixin:OnIconScaleChanged(iconScale)
	EncounterTimelineViewMixin.OnIconScaleChanged(self, iconScale);

	-- Icon scale increases the height of event frames and has impacts on
	-- layout. We want these changes to be immediate in edit mode and so
	-- should bypass animation-held locks.

	local allowMovementAnimations = false;
	self:UpdateTimerLayout(allowMovementAnimations);
	self:UpdateSize();
end

function EncounterTimelineTimerViewMixin:OnIndicatorIconMaskChanged(indicatorIconMask)
	EncounterTimelineViewMixin.OnIndicatorIconMaskChanged(self, indicatorIconMask);

	-- The duration divider can be affected by this due to anchoring dependencies.

	local allowMovementAnimations = false;
	self:UpdateTimerLayout(allowMovementAnimations);
end

function EncounterTimelineTimerViewMixin:OnMaximumTimerCountChanged(_maxTimerCount)
	self:MarkDirty(EncounterTimelineTimerViewDirtyFlag.TimerSorting);
end

function EncounterTimelineTimerViewMixin:OnShowIconChanged(showIcon)
	for eventFrame in self:EnumerateEventFrames() do
		eventFrame:SetShowIcon(showIcon);
	end

	-- The duration divider can be affected by this due to anchoring dependencies.
	self:MarkDirty(EncounterTimelineTimerViewDirtyFlag.TimerLayout);
end

function EncounterTimelineTimerViewMixin:OnShowTimerSparkChanged(showTimerSpark)
	for eventFrame in self:EnumerateEventFrames() do
		eventFrame:SetShowTimerSpark(showTimerSpark);
	end
end

function EncounterTimelineTimerViewMixin:OnTimerFillDirectionChanged(timerFillDirection)
	for eventFrame in self:EnumerateEventFrames() do
		eventFrame:SetTimerFillDirection(timerFillDirection);
	end
end

function EncounterTimelineTimerViewMixin:OnTimerLayoutDirectionChanged(_timerLayoutDirection)
	-- Timer layout requires complete re-initialization as we set the initial
	-- anchor point only once.

	self:ReinitializeAllEventFrames();
end

function EncounterTimelineTimerViewMixin:OnTimerSpacingChanged(_timerSpacing)
	-- Timer spacing is an edit mode tweakable and so should flush immediate
	-- updates to layout and frame size.

	local allowMovementAnimations = false;
	self:UpdateTimerLayout(allowMovementAnimations);
	self:UpdateSize();
end

function EncounterTimelineTimerViewMixin:OnTimerHeightChanged(_timerHeight)
	self:MarkDirty(EncounterTimelineTimerViewDirtyFlag.Size);
end

function EncounterTimelineTimerViewMixin:OnTimerWidthChanged(_timerWidth)
	self:MarkDirty(EncounterTimelineTimerViewDirtyFlag.Size);
end

function EncounterTimelineTimerViewMixin:OnTimerWidthScaleChanged(_timerWidthScale)
	-- Width scaling increases the size of event frames and impacts our view.
	-- This should be immediately applied for correct previews in edit mode.

	local allowMovementAnimations = false;
	self:UpdateTimerLayout(allowMovementAnimations);
	self:UpdateSize();
end

function EncounterTimelineTimerViewMixin:OnTrackDividerOffsetsChanged(_offsetLeft, _offsetRight, _offsetY)
	self:MarkDirty(EncounterTimelineTimerViewDirtyFlag.TrackDivider);
end

function EncounterTimelineTimerViewMixin:EnumeratedSortedEventFrames()
	return ipairs(self.timerFramesSorted);
end

function EncounterTimelineTimerViewMixin:GetBackgroundTexture()
	return self.Background;
end

function EncounterTimelineTimerViewMixin:GetEventFramePool(_eventID)
	return self:GetEventFramePoolCollection():GetPool(self:GetTimerTemplate());
end

function EncounterTimelineTimerViewMixin:GetPadding()
	return self.paddingHorizontal, self.paddingTop, self.paddingBottom;
end

function EncounterTimelineTimerViewMixin:GetSortedTimerCount()
	return #self.timerFramesSorted;
end

function EncounterTimelineTimerViewMixin:GetMaximumTimerCount()
	return self.maxTimerCount;
end

function EncounterTimelineTimerViewMixin:GetTimerResortPeriod()
	return self.timerResortPeriod;
end

function EncounterTimelineTimerViewMixin:GetTimerTemplate()
	return self.timerTemplate;
end

function EncounterTimelineTimerViewMixin:GetTimerHeight()
	return self.timerHeight;
end

function EncounterTimelineTimerViewMixin:GetScaledTimerHeight()
	-- We assume that timer templates increase their height based on the icon
	-- scale setting to prevent overlaps between entries in the list.

	return self:GetTimerHeight() * math.max(1, self:GetIconScale());
end

function EncounterTimelineTimerViewMixin:GetTimerWidth()
	return self.timerWidth;
end

function EncounterTimelineTimerViewMixin:GetScaledTimerWidth()
	return self:GetTimerWidth() * self:GetTimerWidthScale();
end

function EncounterTimelineTimerViewMixin:IsFlippedVertically()
	return self:GetTimerLayoutDirection() == EncounterTimelineTimerLayoutDirection.BottomToTop;
end

function EncounterTimelineTimerViewMixin:SetTimerHeight(timerHeight)
	if self.timerHeight ~= timerHeight then
		self.timerHeight = timerHeight;
		self:OnTimerHeightChanged(timerHeight);
	end
end

function EncounterTimelineTimerViewMixin:SetTimerWidth(timerWidth)
	if self.timerWidth ~= timerWidth then
		self.timerWidth = timerWidth;
		self:OnTimerWidthChanged(timerWidth);
	end
end

function EncounterTimelineTimerViewMixin:GetTrackDividerHeight()
	return self.trackDividerHeight;
end

function EncounterTimelineTimerViewMixin:GetTrackDividerOffsets()
	-- Note; this can intentionally be nil to signal that the divider should hide.
	return self.trackDividerOffsetLeft, self.trackDividerOffsetRight, self.trackDividerOffsetY;
end

function EncounterTimelineTimerViewMixin:GetTrackDividerTexture()
	return self.TrackDivider;
end

function EncounterTimelineTimerViewMixin:GetViewType()
	return Enum.EncounterTimelineViewType.Bars;
end

function EncounterTimelineTimerViewMixin:InitializeEventFrameSettings(eventFrame)
	EncounterTimelineViewMixin.InitializeEventFrameSettings(self, eventFrame);

	eventFrame:ClearAllPoints();
	SetPointWithVerticalFlip(eventFrame, "TOP", self, "TOP", 0, 0, self:IsFlippedVertically());
	eventFrame:SetShowIcon(self:ShouldShowIcon());
	eventFrame:SetShowTimerSpark(self:ShouldShowTimerSpark());
	eventFrame:SetTimerFillDirection(self:GetTimerFillDirection());
end

function EncounterTimelineTimerViewMixin:IsDirty(flag)
	if flag == nil then
		return self.dirtyFlags:IsAnySet();
	else
		return self.dirtyFlags:IsSet(flag);
	end
end

function EncounterTimelineTimerViewMixin:MarkDirty(flag)
	self.dirtyFlags:Set(flag);
end

function EncounterTimelineTimerViewMixin:MarkClean(flag)
	self.dirtyFlags:Clear(flag);
end

function EncounterTimelineTimerViewMixin:SetMaximumTimerCount(maxTimerCount)
	if self.maxTimerCount ~= maxTimerCount then
		self.maxTimerCount = maxTimerCount;
		self:OnMaximumTimerCountChanged(maxTimerCount);
	end
end

function EncounterTimelineTimerViewMixin:ClearTrackDividerOffsets()
	local offsetLeft = nil;
	local offsetRight = nil;
	local offsetY = nil;

	self:SetTrackDividerOffsets(offsetLeft, offsetRight, offsetY);
end

function EncounterTimelineTimerViewMixin:SetTrackDividerOffsets(offsetLeft, offsetRight, offsetY)
	-- Intentionally check vertical offset first as this is the most likely
	-- thing to change dynamically.

	if self.trackDividerOffsetY ~= offsetY or self.trackDividerOffsetLeft ~= offsetLeft or self.trackDividerOffsetRight ~= offsetRight then
		self.trackDividerOffsetLeft = offsetLeft;
		self.trackDividerOffsetRight = offsetRight;
		self.trackDividerOffsetY = offsetY;
		self:OnTrackDividerOffsetsChanged(offsetLeft, offsetRight, offsetY);
	end
end

function EncounterTimelineTimerViewMixin:ShouldSortTimersOnUpdate()
	return C_EncounterTimeline.HasActiveEvents() and C_EncounterTimeline.HasPausedEvents();
end

function EncounterTimelineTimerViewMixin:ShouldShowEventFrameOnInitialization(_eventFrame)
	-- Don't automatically show event frames. We use the shown state when
	-- updating the event frame list to determine if we should apply an
	-- intro animation.

	return false;
end

function EncounterTimelineTimerViewMixin:ShouldLockTimerLayout()
	-- If we've got frames in a detached state then they're animating out.
	-- While animating out their vertical position is locked, but changes to
	-- the sorting elements can result in frames sliding around underneath
	-- the ones animating out. Keep the list locked until those animations
	-- complete.

	if TableHasAnyEntries(self.timerFramesDetached) then
		return true;
	end

	return false;
end

function EncounterTimelineTimerViewMixin:UpdateBackground()
	self:GetBackgroundTexture():SetAlpha(self:GetBackgroundAlpha());
end

function EncounterTimelineTimerViewMixin:UpdateTimerLayout(allowMovementAnimations)
	-- If sorting is dirty then flush an immediate re-sort first, as it's
	-- possible that the sorted event frame list holds references to frames
	-- that have since been released back into the pool.

	if self:IsDirty(EncounterTimelineTimerViewDirtyFlag.TimerSorting) then
		self:UpdateTimerSorting();
	end

	local _paddingHorizontal, paddingTop, _paddingBottom = self:GetPadding();
	local offset = CreateAccumulator(paddingTop);
	local flipped = self:IsFlippedVertically();
	local offsetDirectionMultiplier = flipped and 1 or -1;

	local timerSpacing = self:GetTimerSpacing();
	local timerWidth = self:GetScaledTimerWidth();
	local timerCount = self:GetSortedTimerCount();
	local timerCountMax = self:GetMaximumTimerCount();
	local timerCountVisible = math.min(timerCount, timerCountMax);
	local trackDividerTrack = Enum.EncounterTimelineTrack.Long;
	local trackDividerShown = false;

	for index = 1, timerCountVisible do
		local eventFrame = self.timerFramesSorted[index];
		eventFrame:SetTimerSortIndex(index);
		eventFrame:SetWidth(timerWidth);

		-- Before laying out this frame, check if it's the first frame on the
		-- track that we want to place a divider above. Only do so if this
		-- isn't the first event in the list.
		--
		-- This has interactions with timer spacing; if we're showing a
		-- divider then the spacing above this event frame is increased to
		-- the larger of the spacing or divider height figures and placed
		-- at the midpoint.

		if index > 1 then
			if not trackDividerShown and trackDividerTrack == eventFrame:GetEventTrack() then
				local padding = math.max(self:GetTrackDividerHeight(), timerSpacing) / 2;
				offset:Add(padding);

				local offsetLeft, offsetRight = eventFrame:GetTrackDividerHorizontalInsets();
				local offsetY = offset:Count() * offsetDirectionMultiplier;

				self:SetTrackDividerOffsets(offsetLeft, offsetRight, offsetY);
				offset:Add(padding);

				trackDividerShown = true;
			else
				offset:Add(timerSpacing);
			end
		end

		-- If the frame isn't showing then snap it straight to the target
		-- offset and play an intro animation to show it. Else, translate it
		-- to the target offset.

		local timerOffset = offset:Count() * offsetDirectionMultiplier;

		if not eventFrame:IsShown() then
			eventFrame:SetVerticalOffset(timerOffset);
			eventFrame:AnimateShow();
		elseif allowMovementAnimations then
			eventFrame:AnimateMovement(timerOffset);
		else
			eventFrame:CancelMovementAnimation();
			eventFrame:SetVerticalOffset(timerOffset);
		end

		offset:Add(eventFrame:GetHeight());
	end

	-- Any event frames over the visible cap should be immediately hidden
	-- without any animation applied.

	for index = timerCountVisible + 1, timerCount do
		local eventFrame = self.timerFramesSorted[index];
		eventFrame:Hide();
	end

	-- If no divider was attached to an event, clear the offsets to hide it.

	if not trackDividerShown then
		self:ClearTrackDividerOffsets();
	end

	self:MarkClean(EncounterTimelineTimerViewDirtyFlag.TimerLayout);
end

local function CompareSortEventFrames(a, b)
	-- Sorting logic for timer frames is that we prefer first and foremost
	-- to sort on absolute time remaining.
	--
	-- If the times are identical then this is likely because the two events
	-- being compared are queued with a zero remaining duration. In such a
	-- case our fallback is to preserve relative ordering by sorting on the
	-- index of this timer in the list, and if no such index is available then
	-- key off event ID.

	local timeRemainingA = a:GetEventTimeRemaining();
	local timeRemainingB = b:GetEventTimeRemaining();

	if timeRemainingA ~= timeRemainingB then
		return timeRemainingA < timeRemainingB;
	end

	local timerIndexA = a:GetTimerSortIndex();
	local timerIndexB = b:GetTimerSortIndex();

	if timerIndexA ~= timerIndexB then
		return (timerIndexB == nil) or (timerIndexA ~= nil and timerIndexA < timerIndexB);
	end

	return a:GetEventID() < b:GetEventID();
end

function EncounterTimelineTimerViewMixin:UpdateTimerSorting()
	-- We sort our timer view by event _frames_ rather than on raw timeline
	-- events. The reason for this is to allow us to ensure that frames which
	-- are animating out (which may no longer be associated with an event) can
	-- maintain their position in the list until their animation completes.
	--
	-- We expect that candidate frames for showing in this view will have been
	-- assigned a track by the native API and a frame acquired.

	local eventFrameList = table.create(self:GetActiveEventFrameCount());

	for eventFrame in self:EnumerateEventFrames() do
		table.insert(eventFrameList, eventFrame);
	end

	table.sort(eventFrameList, CompareSortEventFrames);

	self.timerFramesSorted = eventFrameList;
	self:MarkDirty(EncounterTimelineTimerViewDirtyFlag.TimerLayout);
	self:MarkClean(EncounterTimelineTimerViewDirtyFlag.TimerSorting);
end

function EncounterTimelineTimerViewMixin:UpdateTrackDivider()
	local divider = self:GetTrackDividerTexture();
	local flipped = self:IsFlippedVertically();
	local offsetLeft, offsetRight, offsetY = self:GetTrackDividerOffsets();
	local startPoint = flipped and "BOTTOMLEFT" or "TOPLEFT";
	local endPoint = flipped and "BOTTOMRIGHT" or "TOPRIGHT";

	if offsetY ~= nil then
		divider:SetStartPoint(startPoint, self, offsetLeft, offsetY);
		divider:SetEndPoint(endPoint, self, offsetRight, offsetY);
		divider:AnimateShow();
	else
		divider:AnimateHide();
	end

	self:MarkClean(EncounterTimelineTimerViewDirtyFlag.TrackDivider);
end

function EncounterTimelineTimerViewMixin:UpdateSize()
	-- At present we assume that all of our timers have a uniform height.
	--
	-- Our view is sized based on the maximum permissible timer count so that
	-- it's easy to know in edit mode how large the frame can get.

	local paddingHorizontal, paddingTop, paddingBottom = self:GetPadding();
	local trackDividerHeight = self:GetTrackDividerHeight();
	local timerWidth = self:GetScaledTimerWidth();
	local timerHeight = self:GetScaledTimerHeight();
	local timerSpacing = self:GetTimerSpacing();
	local timerCount = self:GetMaximumTimerCount();
	local timerListHeight = (timerCount * timerHeight) + ((timerCount - 1) * timerSpacing);

	-- Ensure calculations clamp to a minimum of 1x1 to maintain a valid rect.
	local width = math.max(1, paddingHorizontal + timerWidth);
	local height = math.max(1, paddingTop + trackDividerHeight + timerListHeight + paddingBottom);

	self:SetSize(width, height);
	self:MarkClean(EncounterTimelineTimerViewDirtyFlag.Size);
end

EncounterTimelineTimerViewTrackDividerMixin = {};

function EncounterTimelineTimerViewTrackDividerMixin:AnimateShow()
	self.HideAnimation:Stop();

	if self:IsShown() then
		return;
	end

	self.ShowAnimation:Play();
	self:Show();
end

function EncounterTimelineTimerViewTrackDividerMixin:AnimateHide()
	if not self:IsShown() then
		return;
	end

	self.ShowAnimation:Stop();
	self.HideAnimation:Play();
end
