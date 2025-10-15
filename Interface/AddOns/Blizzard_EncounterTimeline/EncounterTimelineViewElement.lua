EncounterTimelineViewElementBaseMixin = CreateFromMixins(EncounterTimelineViewSettingsAccessorMixin);

function EncounterTimelineViewElementBaseMixin:OnLoad()
end

function EncounterTimelineViewElementBaseMixin:OnViewSettingsUpdated()
	-- Implement to be notified when the parent view settings have changed.
end

function EncounterTimelineViewElementBaseMixin:OnTrackChanged(trackEnum)
	-- Implement to be notified when the element has moved to a different
	-- timeline track.
end

function EncounterTimelineViewElementBaseMixin:Init(parentView, eventInfo)
	self.primaryAxisOffsetFrom = 0;
	self.primaryAxisOffsetTo = 0;
	self.primaryAxisStartTime = 0;
	self.primaryAxisEndTime = 0;
	self.primaryAxisUseAbsoluteTime = false;

	self.crossAxisOffsetFrom = 0;
	self.crossAxisOffsetTo = 0;
	self.crossAxisStartTime = 0;
	self.crossAxisEndTime = 0;
	self.crossAxisUseAbsoluteTime = false;

	self.interpolationAbsoluteTime = 0;
	self.interpolationRelativeTime = 0;

	self.track = nil;

	self.eventInfo = eventInfo;
	self.parentView = parentView;
end

function EncounterTimelineViewElementBaseMixin:Reset()
	self.parentView = nil;
	self.eventInfo = nil;
end

function EncounterTimelineViewElementBaseMixin:GetEventInfo()
	return self.eventInfo;
end

function EncounterTimelineViewElementBaseMixin:GetView()
	return self.parentView;
end

function EncounterTimelineViewElementBaseMixin:GetViewSetting(key)
	local view = self:GetView();

	if view then
		return view:GetViewSetting(key);
	else
		return EncounterTimelineUtil.GetDefaultViewSetting(key);
	end
end

function EncounterTimelineViewElementBaseMixin:GetTrack()
	return self.track;
end

function EncounterTimelineViewElementBaseMixin:SetTrack(trackEnum)
	if self.track ~= trackEnum then
		self.track = trackEnum;
		self:OnTrackChanged(self.track);
	end
end

function EncounterTimelineViewElementBaseMixin:CalculateCrossAxisOffset()
	local currentTime = self.crossAxisUseAbsoluteTime and self.interpolationAbsoluteTime or self.interpolationRelativeTime;
	local percentage = ClampedPercentageBetween(currentTime, self.crossAxisStartTime, self.crossAxisEndTime);
	return Lerp(self.crossAxisOffsetFrom, self.crossAxisOffsetTo, percentage);
end

function EncounterTimelineViewElementBaseMixin:CalculatePrimaryAxisOffset()
	local currentTime = self.primaryAxisUseAbsoluteTime and self.interpolationAbsoluteTime or self.interpolationRelativeTime;
	local percentage = ClampedPercentageBetween(currentTime, self.primaryAxisStartTime, self.primaryAxisEndTime);
	return Lerp(self.primaryAxisOffsetFrom, self.primaryAxisOffsetTo, percentage);
end

function EncounterTimelineViewElementBaseMixin:ClearCrossAxisTranslation(fixedOffset)
	local offset = fixedOffset or 0;
	local useAbsoluteTime = false;
	local startTime = 0;
	local endTime = 0;

	self:StartCrossAxisTranslation(offset, offset, startTime, endTime, useAbsoluteTime);
end

function EncounterTimelineViewElementBaseMixin:ClearPrimaryAxisTranslation(fixedOffset)
	local offset = fixedOffset or 0;
	local useAbsoluteTime = false;
	local startTime = 0;
	local endTime = 0;

	self:StartPrimaryAxisTranslation(offset, offset, startTime, endTime, useAbsoluteTime);
end

function EncounterTimelineViewElementBaseMixin:StartCrossAxisTranslation(offsetFrom, offsetTo, startTime, endTime, useAbsoluteTime)
	self.crossAxisOffsetFrom = offsetFrom;
	self.crossAxisOffsetTo = offsetTo;
	self.crossAxisStartTime = startTime;
	self.crossAxisEndTime = endTime;
	self.crossAxisUseAbsoluteTime = useAbsoluteTime;
end

function EncounterTimelineViewElementBaseMixin:StartPrimaryAxisTranslation(offsetFrom, offsetTo, startTime, endTime, useAbsoluteTime)
	self.primaryAxisOffsetFrom = offsetFrom;
	self.primaryAxisOffsetTo = offsetTo;
	self.primaryAxisStartTime = startTime;
	self.primaryAxisEndTime = endTime;
	self.primaryAxisUseAbsoluteTime = useAbsoluteTime;
end

function EncounterTimelineViewElementBaseMixin:UpdateAxisTranslations(absoluteTime, relativeTime)
	self.interpolationAbsoluteTime = absoluteTime;
	self.interpolationRelativeTime = relativeTime;
end

EncounterTimelineViewElementMixin = CreateFromMixins(EncounterTimelineViewElementBaseMixin);

function EncounterTimelineViewElementMixin:OnLoad()
	EncounterTimelineViewElementBaseMixin.OnLoad(self);
	self:SetMouseClickEnabled(false);
end

function EncounterTimelineViewElementMixin:OnEnter()
	local eventInfo = self:GetEventInfo();

	if eventInfo then
		self:SetTooltipSpell(eventInfo.tooltipSpellID);
	end
end

function EncounterTimelineViewElementMixin:OnLeave()
	self:SetTooltipSpell(nil);
end

function EncounterTimelineViewElementMixin:OnViewSettingsUpdated()
	self:Update();
end

function EncounterTimelineViewElementMixin:OnTrackChanged(trackEnum)
	-- Events in the long track instead of the short are slightly faded out.

	if trackEnum == Enum.EncounterTimelineTrack.Long then
		self:SetIconAlpha(0.75);
	else
		self:SetIconAlpha(1);
	end

	-- Transitioning into the short track should result in us showing that
	-- pretty trail of ours.

	if trackEnum == Enum.EncounterTimelineTrack.Short then
		self.TrailAnimation:Play();
	else
		self.Trail:SetAlpha(0);
	end
end

function EncounterTimelineViewElementMixin:Init(parentView, eventInfo)
	EncounterTimelineViewElementBaseMixin.Init(self, parentView, eventInfo);

	self.IconContainer:Show();
	self:Update();
end

function EncounterTimelineViewElementMixin:Reset()
	EncounterTimelineViewElementBaseMixin.Reset(self);

	self.Trail:SetAlpha(0);
	self:SetCountdownDuration(0);
	self:SetCountdownPaused(false);
	self:SetIconTexture(nil);
	self:SetSpellName(nil);
	self:StopAnimations();
end

function EncounterTimelineViewElementMixin:Update()
	local eventID = self:GetID();
	local eventInfo = self:GetEventInfo();
	local eventTimeRemaining = C_EncounterTimeline.GetEventTimeRemaining(eventID);
	local eventState = C_EncounterTimeline.GetEventState(eventID);

	self:SetCountdownDuration(eventTimeRemaining);
	self:SetCountdownPaused(eventState ~= Enum.EncounterTimelineEventState.Active);
	self:SetIconTexture(eventInfo.iconFileID);

	if eventInfo.tooltipSpellID then
		local spell = Spell:CreateFromSpellID(eventInfo.tooltipSpellID);

		local function OnSpellLoaded()
			self:SetSpellName(spell:GetSpellName());
		end

		spell:ContinueOnSpellLoad(OnSpellLoaded);
	else
		self:SetSpellName(nil);
	end

	-- These sizes need syncing manually as they're not anchored to all of
	-- our points, since they get independently translated along their cross
	-- axis.
	--
	-- EETODO: This causes other issues with art... Fix the view to make it
	-- aware of element scale differences, then use SetScale.

	self.IconContainer:SetSize(self:GetSize());
	self.Cooldown:SetSize(self:GetSize());

	-- The trail is sensitive to orientation, so needs proper anchoring
	-- and rotation applied.

	local view = self:GetView();
	self.Trail:ClearAllPoints();
	view:SetRegionTextureRotation(self.Trail);
	view:SetRegionPoint(self.Trail, "END", self, "START", 10, 0);
end

function EncounterTimelineViewElementMixin:SetIconAlpha(alpha)
	self.IconContainer.SpellIcon:SetAlpha(alpha);
end

function EncounterTimelineViewElementMixin:SetIconTexture(texture)
	return self.IconContainer.SpellIcon:SetTexture(texture);
end

function EncounterTimelineViewElementMixin:SetCountdownDuration(duration)
	if self:GetSpellTimersEnabled() then
		self.Cooldown:SetCooldownDuration(duration or 0);
	else
		self.Cooldown:Clear();
	end
end

function EncounterTimelineViewElementMixin:SetCountdownPaused(paused)
	if paused then
		self.Cooldown:Pause();
	else
		self.Cooldown:Resume();
	end
end

function EncounterTimelineViewElementMixin:SetSpellName(spellName)
	if spellName and spellName ~= "" and self:GetSpellNamesEnabled() and self:GetViewOrientation() == Enum.EncounterEventsOrientation.Vertical then
		self.SpellName:SetText(spellName);
		self.SpellName:Show();
	else
		self.SpellName:SetText("");
		self.SpellName:Hide();
	end
end

function EncounterTimelineViewElementMixin:SetTooltipSpell(spellID)
	if spellID and self:GetSpellTooltipsEnabled() then
		GameTooltip_SetDefaultAnchor(GameTooltip, self);
		GameTooltip:SetSpellByID(spellID);
	elseif GameTooltip:IsOwned(self) then
		GameTooltip:Hide();
	end
end

function EncounterTimelineViewElementMixin:PlayIntroAnimation()
	self.IntroAnimation:Play();
end

function EncounterTimelineViewElementMixin:PlayCancelAnimation()
	if self:IsShown() then
		self.CancelAnimation:Play();
	end
end

function EncounterTimelineViewElementMixin:PlayHighlightAnimation()
	self.IconContainer.HighlightSwirl:SetAlpha(1);
	self.IconContainer.HighlightAnimation:Play();
	self.IconContainer.HighlightPulse:Play();
end

function EncounterTimelineViewElementMixin:PlayFinishAnimation()
	if self:IsShown() then
		self.IconContainer.HighlightGlow:SetAlpha(1);
		self.FinishAnimation:Play();
	end
end

function EncounterTimelineViewElementMixin:StopAnimations()
	self.CancelAnimation:Stop();
	self.IntroAnimation:Stop();
	self.FinishAnimation:Stop();
	self.TrailAnimation:Stop();
	self.IconContainer.HighlightSwirl:SetAlpha(0);
	self.IconContainer.HighlightGlow:SetAlpha(0);
	self.IconContainer.HighlightAnimation:Stop();
	self.IconContainer.HighlightPulse:Stop();
end

function EncounterTimelineViewElementMixin:ApplyCrossAxisTranslation(offsetX, offsetY)
	for _, region in ipairs(self.crossAxisTranslatableRegions) do
		region:SetPointsOffset(offsetX, offsetY);
	end
end
