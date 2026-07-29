EncounterTimelineTrackViewMixin = CreateFromMixins(EncounterTimelineViewMixin, EncounterTimelineTrackViewSettingsMixin, EncounterTimelineTrackLayoutMixin);

function EncounterTimelineTrackViewMixin:OnLoad()
	EncounterTimelineViewMixin.OnLoad(self);
	EncounterTimelineTrackViewSettingsMixin.OnLoad(self);
	EncounterTimelineTrackLayoutMixin.OnLoad(self);

	self:RegisterEventFramePool("Frame", "EncounterTimelineTrackEventTemplate");
end

function EncounterTimelineTrackViewMixin:OnEvent(event, ...)
	EncounterTimelineViewMixin.OnEvent(self, event, ...);

	if event == "ENCOUNTER_TIMELINE_LAYOUT_UPDATED" then
		self:UpdateTrackList();
	end
end

function EncounterTimelineTrackViewMixin:OnShow()
	-- Load-bearing call order here; track list needs updating first to sync
	-- it with the C API, then from that flush an immediate layout to get
	-- our calculated offsets, and then we can add all the existing events
	-- in with the correct data.

	self:UpdateTrackList();
	self:UpdateLayout();
	EncounterTimelineViewMixin.OnShow(self);
end

function EncounterTimelineTrackViewMixin:OnTracksUpdated()
	self:SetTrackPadding(Enum.EncounterTimelineTrack.Queued, 10, 0);
	self:SetTrackExtent(Enum.EncounterTimelineTrack.Medium, self:CalculateMediumTrackExtent());
	self:SetTrackExtent(Enum.EncounterTimelineTrack.Short, self:CalculateShortTrackExtent());
end

function EncounterTimelineTrackViewMixin:OnLayoutUpdated()
	-- Layout changes trigger a reset of the timeline. This is to drastically
	-- simplify code elsewhere that'd need to accomodate all the anchors and
	-- interpolated offsets potentially changing.
	--
	-- We hope this only happens when there's a settings change, which should
	-- be so infrequent as to not matter.

	self:ReleaseAllEventFrames();
	self:UpdateView();
	self:ReinitializeAllEventFrames();
end

function EncounterTimelineTrackViewMixin:OnBackgroundAlphaChanged(_backgroundAlpha)
	self:UpdateBackground();
end

function EncounterTimelineTrackViewMixin:OnCrossAxisOffsetChanged(_crossAxisOffset)
	-- We don't propagate the cross axis offset to event frames here as layout
	-- invalidation rebuilds the view from scratch, re-initializing frames.
	self:MarkLayoutDirty();
end

function EncounterTimelineTrackViewMixin:OnCrossAxisExtentChanged(_crossAxisExtent)
	self:MarkLayoutDirty();
end

function EncounterTimelineTrackViewMixin:OnHighlightTimeChanged(highlightTime)
	EncounterTimelineViewMixin.OnHighlightTimeChanged(self, highlightTime);
	self:UpdatePip();
end

function EncounterTimelineTrackViewMixin:OnPipIconShownChanged(_pipIconShown)
	self:UpdatePip();
end

function EncounterTimelineTrackViewMixin:OnPipTextAnchorChanged(_pipTextAnchor)
	self:UpdatePip();
end

function EncounterTimelineTrackViewMixin:OnPipTextShownChanged(_pipTextShown)
	self:UpdatePip();
end

function EncounterTimelineTrackViewMixin:OnTrackOrientationChanged(trackOrientation)
	-- We don't propagate the orientation to event frames here as layout
	-- invalidation rebuilds the view from scratch, re-initializing frames.
	self:MarkLayoutDirty();
end

function EncounterTimelineTrackViewMixin:GetViewType()
	return Enum.EncounterTimelineViewType.Timeline;
end

function EncounterTimelineTrackViewMixin:GetEventFramePool(_eventID)
	return self:GetEventFramePoolCollection():GetPool("EncounterTimelineTrackEventTemplate");
end

function EncounterTimelineTrackViewMixin:InitializeEventFrameSettings(eventFrame)
	EncounterTimelineViewMixin.InitializeEventFrameSettings(self, eventFrame);

	local orientation = self:GetTrackOrientation();

	eventFrame:ClearAllPoints();
	eventFrame:SetFrameLevel(self:GetFrameLevel());
	eventFrame:SetPoint("CENTER", self, orientation:GetStartPoint(), 0, 0);

	eventFrame:SetTrackLayoutManager(self);
	eventFrame:SetCrossAxisOffset(self:GetCrossAxisOffset());
	eventFrame:SetTrackOrientation(self:GetTrackOrientation());
end

function EncounterTimelineTrackViewMixin:GetBackgroundTexture()
	return self.Background;
end

function EncounterTimelineTrackViewMixin:GetPipTexture()
	return self.PipIcon;
end

function EncounterTimelineTrackViewMixin:GetPipFontString()
	return self.PipText;
end

function EncounterTimelineTrackViewMixin:GetLongTrackDividerTexture()
	return self.LongDivider;
end

function EncounterTimelineTrackViewMixin:GetQueuedTrackDividerTexture()
	return self.QueueDivider;
end

function EncounterTimelineTrackViewMixin:GetLineStartAtlas()
	return "combattimeline-line-left";
end

function EncounterTimelineTrackViewMixin:GetLineStartTexture()
	return self.LineStart;
end

function EncounterTimelineTrackViewMixin:GetLineEndAtlas()
	return "combattimeline-line-right";
end

function EncounterTimelineTrackViewMixin:GetLineEndTexture()
	return self.LineEnd;
end

function EncounterTimelineTrackViewMixin:GetLineBreakMaskTexture(index)
	return self.lineBreakMasks[index];
end

function EncounterTimelineTrackViewMixin:CalculateLongTrackDividerOffset()
	local trackData = self:GetTrackData(EncounterTimelineConstants.LongTrackDividerOffsetTrack);

	if trackData ~= nil then
		return trackData.offsetEnd + EncounterTimelineConstants.LongTrackDividerOffsetExtra;
	else
		return 0;
	end
end

function EncounterTimelineTrackViewMixin:CalculateQueuedTrackDividerOffset()
	local trackData = self:GetTrackData(EncounterTimelineConstants.QueuedTrackDividerOffsetTrack);

	if trackData ~= nil then
		return trackData.offsetEnd + EncounterTimelineConstants.QueuedTrackDividerOffsetExtra;
	else
		return 0;
	end
end

function EncounterTimelineTrackViewMixin:CalculateMediumTrackExtent()
	return 55;
end

function EncounterTimelineTrackViewMixin:CalculateShortTrackExtent()
	local lineStartWidth, _lineStartHeight = GetAtlasSize(self:GetLineStartAtlas());
	local lineEndWidth, _lineEndHeight = GetAtlasSize(self:GetLineEndAtlas());

	return lineStartWidth + lineEndWidth;
end

function EncounterTimelineTrackViewMixin:EnumerateLineBreakMaskTextures()
	return ipairs(self.lineBreakMasks);
end

function EncounterTimelineTrackViewMixin:UpdateBackground()
	local orientation = self:GetTrackOrientation();
	local backgroundTexture = self:GetBackgroundTexture();

	if orientation:IsVertical() then
		backgroundTexture:SetAtlas("combattimeline-line-shadow-vertical");
	else
		backgroundTexture:SetAtlas("combattimeline-line-shadow");
	end

	backgroundTexture:SetAlpha(self:GetBackgroundAlpha());
end

function EncounterTimelineTrackViewMixin:UpdatePip()
	local orientation = self:GetTrackOrientation();
	local pipDuration = self:GetHighlightTime();
	local pipTexture = self:GetPipTexture();
	local pipFontString = self:GetPipFontString();

	do
		pipTexture:ClearAllPoints();
		pipTexture:SetOrientedPoint(orientation, "CENTER", self, "START", self:CalculateOffsetForDuration(pipDuration), self:GetCrossAxisOffset());
		pipTexture:SetShown(self:ShouldShowPipIcon());
	end

	do
		local point, _relativeTo, relativePoint, x, y = self:GetPipTextAnchor():Get();

		pipFontString:ClearAllPoints();
		pipFontString:SetPoint(point, pipTexture, relativePoint, x, y);
		pipFontString:SetFormattedText("%d", pipDuration);
		pipFontString:SetShown(self:ShouldShowPipText());
	end
end

function EncounterTimelineTrackViewMixin:UpdateLongTrackDivider()
	local orientation = self:GetTrackOrientation();
	local trackData = self:GetTrackData(Enum.EncounterTimelineTrack.Long);
	local divider = self:GetLongTrackDividerTexture();

	divider:ClearAllPoints();
	divider:SetOrientedPoint(orientation, "END", self, "START", self:CalculateLongTrackDividerOffset(), self:GetCrossAxisOffset());
	divider:SetOrientedTexCoordToDefaults(orientation);
	divider:SetShown(trackData ~= nil and trackData.maximumEventCount > 0);
end

function EncounterTimelineTrackViewMixin:UpdateQueuedTrackDivider()
	local orientation = self:GetTrackOrientation();
	local trackData = self:GetTrackData(Enum.EncounterTimelineTrack.Queued);
	local divider = self:GetQueuedTrackDividerTexture();

	-- This is basically just a flipped version of the long track divider.

	divider:ClearAllPoints();
	divider:SetOrientedPoint(orientation, "START", self, "START", self:CalculateQueuedTrackDividerOffset(), self:GetCrossAxisOffset());
	divider:SetOrientedTexCoord(orientation, 1, 0, 0, 1);
	divider:SetShown(trackData ~= nil and trackData.maximumEventCount > 0);
end

function EncounterTimelineTrackViewMixin:UpdateLineTextures()
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

	local orientation = self:GetTrackOrientation();

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

function EncounterTimelineTrackViewMixin:UpdateView()
	self:UpdateBackground();
	self:UpdatePip();
	self:UpdateLongTrackDivider();
	self:UpdateQueuedTrackDivider();
	self:UpdateLineTextures();

	local orientation = self:GetTrackOrientation();
	self:SetSize(orientation:GetOrientedExtents(self:GetPrimaryAxisExtent(), self:GetCrossAxisExtent()));
end

function EncounterTimelineTrackViewMixin:GetDynamicEventRegistrations()
	local events = {};
	tAppendAll(events, EncounterTimelineViewMixin.GetDynamicEventRegistrations(self));
	tAppendAll(events, { "ENCOUNTER_TIMELINE_LAYOUT_UPDATED" });
	return events;
end
