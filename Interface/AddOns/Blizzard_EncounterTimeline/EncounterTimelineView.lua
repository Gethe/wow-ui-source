EncounterTimelineViewMixin = CreateFromMixins(EncounterTimelineControllerMixin, EncounterTimelineSettingsMixin);

function EncounterTimelineViewMixin:OnLoad()
	EncounterTimelineControllerMixin.OnLoad(self);
	EncounterTimelineSettingsMixin.OnLoad(self);

	self:RegisterEventFrameTemplate("Frame", "EncounterTimelineSpellEventFrameTemplate");
end

function EncounterTimelineViewMixin:OnTracksUpdated()
	self:SetTrackPadding(Enum.EncounterTimelineTrack.Queued, 10, 0);
	self:SetTrackExtent(Enum.EncounterTimelineTrack.Medium, self:CalculateMediumTrackExtent());
	self:SetTrackExtent(Enum.EncounterTimelineTrack.Short, self:CalculateShortTrackExtent());
end

function EncounterTimelineViewMixin:OnEventFrameAcquired(eventFrame, isNewObject)
	eventFrame:SetFrameLevel(self:GetFrameLevel());
	eventFrame:SetCrossAxisOffset(self:GetCrossAxisOffset());
	eventFrame:SetCrossAxisExtent(self:GetCrossAxisExtent());
	eventFrame:SetEventCountdownEnabled(self:GetEventCountdownEnabled());
	eventFrame:SetEventIconScale(self:GetEventIconScale());
	eventFrame:SetEventTextEnabled(self:GetEventTextEnabled());
	eventFrame:SetEventTooltipsEnabled(self:GetEventTooltipsEnabled());
	eventFrame:SetEventIndicatorIconMask(self:GetEventIndicatorIconMask());
	eventFrame:SetViewOrientation(self:GetViewOrientation());

	EventRegistry:TriggerEvent("EncounterTimeline.OnEventFrameAcquired", self, eventFrame, isNewObject);
end

function EncounterTimelineViewMixin:OnEventFrameReleased(eventFrame)
	EventRegistry:TriggerEvent("EncounterTimeline.OnEventFrameReleased", self, eventFrame);
end

function EncounterTimelineViewMixin:OnLayoutUpdated()
	-- Layout changes trigger a reset of the timeline. This is to drastically
	-- simplify code elsewhere that'd need to accomodate all the anchors and
	-- interpolated offsets potentially changing.
	--
	-- We hope this only happens when there's a settings change, which should
	-- be so infrequent as to not matter.

	self:RemoveAllEvents();
	self:UpdateEventFrameInitialAnchor();
	self:UpdateView();
	self:AddAllEvents(EncounterTimelineUtil.GetEventInfoList());
end

function EncounterTimelineViewMixin:OnCrossAxisOffsetChanged(crossAxisOffset)
	for eventFrame in self:EnumerateEventFrames() do
		eventFrame:SetCrossAxisOffset(crossAxisOffset);
	end

	self:MarkLayoutDirty();
end

function EncounterTimelineViewMixin:OnCrossAxisExtentChanged(crossAxisExtent)
	for eventFrame in self:EnumerateEventFrames() do
		eventFrame:SetCrossAxisExtent(crossAxisExtent);
	end

	self:MarkLayoutDirty();
end

function EncounterTimelineViewMixin:OnEventCountdownEnabledChanged(countdownEnabled)
	for eventFrame in self:EnumerateEventFrames() do
		eventFrame:SetEventCountdownEnabled(countdownEnabled);
	end
end

function EncounterTimelineViewMixin:OnEventIconScaleChanged(iconScale)
	for eventFrame in self:EnumerateEventFrames() do
		eventFrame:SetEventIconScale(iconScale);
	end
end

function EncounterTimelineViewMixin:OnEventTextEnabledChanged(textEnabled)
	for eventFrame in self:EnumerateEventFrames() do
		eventFrame:SetEventTextEnabled(textEnabled);
	end
end

function EncounterTimelineViewMixin:OnEventTooltipsEnabledChanged(tooltipsEnabled)
	for eventFrame in self:EnumerateEventFrames() do
		eventFrame:SetEventTooltipsEnabled(tooltipsEnabled);
	end
end

function EncounterTimelineViewMixin:OnEventIndicatorIconMaskChanged(iconMask)
	for eventFrame in self:EnumerateEventFrames() do
		eventFrame:SetEventIndicatorIconMask(iconMask);
	end
end

function EncounterTimelineViewMixin:OnViewBackgroundAlphaChanged(_backgroundAlpha)
	self:UpdateBackground();
end

function EncounterTimelineViewMixin:OnViewOrientationChanged(viewOrientation)
	for eventFrame in self:EnumerateEventFrames() do
		eventFrame:SetViewOrientation(viewOrientation);
	end

	self:MarkLayoutDirty();
end

function EncounterTimelineViewMixin:OnPipDurationChanged(_pipDuration)
	self:UpdatePip();
end

function EncounterTimelineViewMixin:OnPipIconShownChanged(_pipIconShown)
	self:UpdatePip();
end

function EncounterTimelineViewMixin:OnPipTextAnchorChanged(_pipTextAnchor)
	self:UpdatePip();
end

function EncounterTimelineViewMixin:OnPipTextShownChanged(_pipTextShown)
	self:UpdatePip();
end

function EncounterTimelineViewMixin:GetBackgroundTexture()
	return self.Background;
end

function EncounterTimelineViewMixin:GetPipTexture()
	return self.PipIcon;
end

function EncounterTimelineViewMixin:GetPipFontString()
	return self.PipText;
end

function EncounterTimelineViewMixin:GetLongTrackDividerTexture()
	return self.LongDivider;
end

function EncounterTimelineViewMixin:GetQueuedTrackDividerTexture()
	return self.QueueDivider;
end

function EncounterTimelineViewMixin:GetLineStartAtlas()
	return "combattimeline-line-left";
end

function EncounterTimelineViewMixin:GetLineStartTexture()
	return self.LineStart;
end

function EncounterTimelineViewMixin:GetLineEndAtlas()
	return "combattimeline-line-right";
end

function EncounterTimelineViewMixin:GetLineEndTexture()
	return self.LineEnd;
end

function EncounterTimelineViewMixin:GetLineBreakMaskTexture(index)
	return self.lineBreakMasks[index];
end

function EncounterTimelineViewMixin:GetEventFramePool(_eventID, framePoolCollection)
	-- At present, all events are spells. Maybe one day we could stick UI
	-- widgets on this thing? :)

	return framePoolCollection:GetPool("EncounterTimelineSpellEventFrameTemplate");
end

function EncounterTimelineViewMixin:GetEventFrameInitialAnchor(_eventID)
	-- The initial anchor is cached across repeated calls; this should be
	-- invalidated if layout fundamentally changes.

	local initialAnchor = self.eventFrameInitialAnchor;

	if initialAnchor ~= nil then
		return initialAnchor;
	end

	local orientation = self:GetViewOrientation();
	self.eventFrameInitialAnchor = CreateAnchor("CENTER", self, orientation:GetStartPoint(), 0, 0);
	return self.eventFrameInitialAnchor;
end

function EncounterTimelineViewMixin:UpdateEventFrameInitialAnchor()
	self.eventFrameInitialAnchor = nil;
end

function EncounterTimelineViewMixin:CalculateLongTrackDividerOffset()
	local trackData = self:GetTrackData(EncounterTimelineConstants.LongTrackDividerOffsetTrack);

	if trackData ~= nil then
		return trackData.offsetEnd + EncounterTimelineConstants.LongTrackDividerOffsetExtra;
	else
		return 0;
	end
end

function EncounterTimelineViewMixin:CalculateQueuedTrackDividerOffset()
	local trackData = self:GetTrackData(EncounterTimelineConstants.QueuedTrackDividerOffsetTrack);

	if trackData ~= nil then
		return trackData.offsetEnd + EncounterTimelineConstants.QueuedTrackDividerOffsetExtra;
	else
		return 0;
	end
end

function EncounterTimelineViewMixin:CalculateMediumTrackExtent()
	return 55;
end

function EncounterTimelineViewMixin:CalculateShortTrackExtent()
	local lineStartWidth, _lineStartHeight = GetAtlasSize(self:GetLineStartAtlas());
	local lineEndWidth, _lineEndHeight = GetAtlasSize(self:GetLineEndAtlas());

	return lineStartWidth + lineEndWidth;
end

function EncounterTimelineViewMixin:EnumerateLineBreakMaskTextures()
	return ipairs(self.lineBreakMasks);
end

function EncounterTimelineViewMixin:UpdateBackground()
	local orientation = self:GetViewOrientation();
	local backgroundTexture = self:GetBackgroundTexture();

	if orientation:IsVertical() then
		backgroundTexture:SetAtlas("combattimeline-line-shadow-vertical");
	else
		backgroundTexture:SetAtlas("combattimeline-line-shadow");
	end

	backgroundTexture:SetAlpha(self:GetViewBackgroundAlpha());
end

function EncounterTimelineViewMixin:UpdatePip()
	local orientation = self:GetViewOrientation();
	local pipTexture = self:GetPipTexture();
	local pipFontString = self:GetPipFontString();

	do
		pipTexture:ClearAllPoints();
		pipTexture:SetOrientedPoint(orientation, "CENTER", self, "START", self:CalculateOffsetForDuration(self:GetPipDuration()), self:GetCrossAxisOffset());
		pipTexture:SetShown(self:GetPipIconShown());
	end

	do
		local point, _relativeTo, relativePoint, x, y = self:GetPipTextAnchor():Get();

		pipFontString:ClearAllPoints();
		pipFontString:SetPoint(point, pipTexture, relativePoint, x, y);
		pipFontString:SetFormattedText("%d", self:GetPipDuration());
		pipFontString:SetShown(self:GetPipTextShown());
	end
end

function EncounterTimelineViewMixin:UpdateLongTrackDivider()
	local orientation = self:GetViewOrientation();
	local trackData = self:GetTrackData(Enum.EncounterTimelineTrack.Long);
	local divider = self:GetLongTrackDividerTexture();

	divider:ClearAllPoints();
	divider:SetOrientedPoint(orientation, "END", self, "START", self:CalculateLongTrackDividerOffset(), self:GetCrossAxisOffset());
	divider:SetOrientedTexCoordToDefaults(orientation);
	divider:SetShown(trackData ~= nil and trackData.maximumEventCount > 0);
end

function EncounterTimelineViewMixin:UpdateQueuedTrackDivider()
	local orientation = self:GetViewOrientation();
	local trackData = self:GetTrackData(Enum.EncounterTimelineTrack.Queued);
	local divider = self:GetQueuedTrackDividerTexture();

	-- EETODO: Art here is temporary; just need something for display. This
	-- is basically just a flipped version of the long track divider.

	divider:ClearAllPoints();
	divider:SetOrientedPoint(orientation, "START", self, "START", self:CalculateQueuedTrackDividerOffset(), self:GetCrossAxisOffset());
	divider:SetOrientedTexCoord(orientation, 1, 0, 0, 1);
	divider:SetShown(trackData ~= nil and trackData.maximumEventCount > 0);
end

function EncounterTimelineViewMixin:UpdateLineTextures()
	-- The anchoring of the track line is set up such that we'll anchor the
	-- "end"-facing point of our frame across from the start of the timeline
	-- to the end offset of the configured track.
	--
	-- The art itself is split into two line segments to deal with texture
	-- mask limitations. We anchor the end line segment to the end of our
	-- frame, and attach start line segment to the end line segment.
	--
	-- This setup means that if, for some reason, the track line extent is
	-- greater than the actual size of the track that we keep the little
	-- marker signaling the end of the timeline toward the end of the actual
	-- track.

	local orientation = self:GetViewOrientation();

	-- Line end texture
	do
		local texture = self:GetLineEndTexture();
		local offset = self:CalculateOffsetForDuration(0);

		texture:ClearAllPoints();
		texture:SetOrientedAtlas(orientation, self:GetLineEndAtlas());
		texture:SetOrientedPoint(orientation, "END", self, "START", offset, self:GetCrossAxisOffset());
		texture:SetOrientedTexCoordToDefaults(orientation);
	end

	-- Line start texture
	do
		local texture = self:GetLineStartTexture();

		texture:ClearAllPoints();
		texture:SetOrientedAtlas(orientation, self:GetLineStartAtlas());
		texture:SetOrientedPoint(orientation, "END", self:GetLineEndTexture(), "START", 0, 0);
		texture:SetOrientedTexCoordToDefaults(orientation);
	end

	-- The line break masks should be positioned at fixed intervals. We need
	-- to do this in two passes to ensure we don't accidentally try to attach
	-- four+ mask textures to one half of the bar art.

	local shortTrackData = self:GetTrackData(Enum.EncounterTimelineTrack.Short);

	for _maskIndex, maskTexture in self:EnumerateLineBreakMaskTextures() do
		maskTexture:ClearAllPoints();
		self:GetLineStartTexture():RemoveMaskTexture(maskTexture);
		self:GetLineEndTexture():RemoveMaskTexture(maskTexture);
	end

	for maskIndex, maskTexture in self:EnumerateLineBreakMaskTextures() do
		local durationOffset = 1;
		local durationInterval = 2;
		local duration = durationOffset + ((maskIndex - 1) * durationInterval);
		local offset = self:CalculateOffsetForDuration(duration);

		maskTexture:SetOrientedPoint(orientation, "CENTER", self, "START", offset, self:GetCrossAxisOffset());

		local lineSegmentTexture;

		if duration <= (shortTrackData.duration / 2) then
			lineSegmentTexture = self:GetLineEndTexture();
		else
			lineSegmentTexture = self:GetLineStartTexture();
		end

		if lineSegmentTexture:GetNumMaskTextures() < 3 then
			lineSegmentTexture:AddMaskTexture(maskTexture);
		end

		-- We can't use SetRegionTextureRotation here because changing texcoords
		-- of a texture used as a mask isn't supported. Thankfully, this asset
		-- is a regular square with just a small cutout - so we can use normal
		-- rotation APIs instead.

		if orientation:IsVertical() then
			maskTexture:SetRotation(90);
		else
			maskTexture:SetRotation(0);
		end
	end
end

function EncounterTimelineViewMixin:UpdateView()
	self:UpdateBackground();
	self:UpdatePip();
	self:UpdateLongTrackDivider();
	self:UpdateQueuedTrackDivider();
	self:UpdateLineTextures();

	local orientation = self:GetViewOrientation();
	self:SetSize(orientation:GetOrientedExtents(self:GetPrimaryAxisExtent(), self:GetCrossAxisExtent()));
end
