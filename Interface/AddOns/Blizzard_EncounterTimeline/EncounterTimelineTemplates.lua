EncounterTimelineEventIconMixin = CreateFromMixins(EncounterTimelineOrientedFrameMixin);

function EncounterTimelineEventIconMixin:OnLoad()
	self.isDeadlyEffect = false;
	self.isPaused = false;
	self.isQueued = false;

	-- Completion of hide animations needs to re-evaluate overlays so that we
	-- can, for example, show the queued icon once the paused one has cleared.

	self.PausedIcon:SetScript("OnHide", function() self:UpdateOverlays(); end);
	self.QueuedIcon:SetScript("OnHide", function() self:UpdateOverlays(); end);
end

function EncounterTimelineEventIconMixin:OnShow()
	self:UpdateOverlays();
end

function EncounterTimelineEventIconMixin:OnHide()
	self:StopAnimating();

	-- These regions need their alpha resetting to zero to prevent an issue
	-- where hiding event icons while the highlight animaton at 5s is playing
	-- can cause them to be visible when recycled as setToFinalAlpha is never
	-- applied due to the prior StopAnimating call.

	self.HighlightSwirl:SetAlpha(0.0);
	self.HighlightGlow:SetAlpha(0.0);

	-- Additionally force reset visibility of our child icons and overlays.
	-- They'll be restored to the correct state when we're re-shown.

	self.PausedIcon:Hide();
	self.QueuedIcon:Hide();
	self.DeadlyOverlay:Hide();
	self.DeadlyOverlayGlow:Hide();
	self.PausedOverlay:Hide();
	self.QueuedOverlay:Hide();
	self.NormalOverlay:Hide();
end

function EncounterTimelineEventIconMixin:GetIconTexture()
	return self.IconTexture;
end

function EncounterTimelineEventIconMixin:IsDeadlyEffect()
	return self.isDeadlyEffect == true;
end

function EncounterTimelineEventIconMixin:IsPaused()
	return self.isPaused == true;
end

function EncounterTimelineEventIconMixin:IsQueued()
	return self.isQueued == true;
end

function EncounterTimelineEventIconMixin:IsAnyIconShown()
	return self.PausedIcon:IsShown() or self.QueuedIcon:IsShown();
end

function EncounterTimelineEventIconMixin:SetDeadlyEffect(isDeadlyEffect)
	if self.isDeadlyEffect ~= isDeadlyEffect then
		self.isDeadlyEffect = isDeadlyEffect;
		self:UpdateOverlays();
	end
end

function EncounterTimelineEventIconMixin:SetHighlightGlowAlpha(alpha)
	self.HighlightGlow:SetAlpha(alpha);
end

function EncounterTimelineEventIconMixin:SetIcon(iconFileID)
	self.IconTexture:SetTexture(iconFileID or QUESTION_MARK_ICON);
end

function EncounterTimelineEventIconMixin:SetPaused(isPaused)
	if self.isPaused ~= isPaused then
		self.isPaused = isPaused;
		self:UpdateOverlays();
	end
end

function EncounterTimelineEventIconMixin:SetQueued(isQueued)
	if self.isQueued ~= isQueued then
		self.isQueued = isQueued;
		self:UpdateOverlays();
	end
end

function EncounterTimelineEventIconMixin:PlayHighlightAnimation()
	-- The swirl alpha needs forcing to maximum because the animation has
	-- a start delay on alpha changes it would apply to this, and we need it
	-- at full visibility for this initial delay period.

	self.HighlightSwirl:SetAlpha(1.0);
	self.HighlightAnimation:Play();
end

function EncounterTimelineEventIconMixin:StopHighlightAnimation()
	self.HighlightSwirl:SetAlpha(0.0);
	self.HighlightGlow:SetAlpha(0.0);
	self.HighlightAnimation:Stop();
end

function EncounterTimelineEventIconMixin:UpdateOverlays()
	if not self:IsVisible() then
		return;
	end

	local isDeadlyEffect = self:IsDeadlyEffect();
	local isPaused = self:IsPaused();
	local isQueued = self:IsQueued();

	-- Paused and queued icons are special in that we want to show them even
	-- if the overlay can't be shown due to it being a deadly event.
	--
	-- Where possible we want to animate transitions into and out of these
	-- states; the Animate functions are expected to be idempotent and do
	-- nothing if we're already animating towards being shown or hidden.

	if isPaused then
		-- Paused has the highest priority - it should immediately replace the
		-- queued icon if it's presently shown with no animation to switch.

		self.QueuedIcon:Hide();
		self.PausedIcon:AnimateShow();
	elseif isQueued then
		-- Queued has the lowest priority - if we were previously paused then
		-- animate out of that state first before showing the queued icon.

		if self.PausedIcon:IsShown() then
			self.PausedIcon:AnimateHide();
		else
			self.QueuedIcon:AnimateShow();
		end
	else
		self.PausedIcon:AnimateHide();
		self.QueuedIcon:AnimateHide();
	end

	-- Note that some booleans here are secret, so we want to evaluate them
	-- inline, and also ensure all SetShown functions are called to prevent
	-- infererence of secret booleans by counting the number of SetShown
	-- calls that occur.
	--
	-- Priority is Deadly > Paused > Queued > Normal. We drive the paused and
	-- queued overlays from visibility of their icons rather than state to
	-- make sure they remain visible while hide animations are playing.

	local canShowPausedOverlay = self.PausedIcon:IsShown();
	local canShowQueuedOverlay = self.QueuedIcon:IsShown();

	local showDeadlyOverlay = isDeadlyEffect;
	local showPausedOverlay = not showDeadlyOverlay and canShowPausedOverlay;
	local showQueuedOverlay = not showPausedOverlay and canShowQueuedOverlay;
	local showNormalOverlay = not showQueuedOverlay;

	self.DeadlyOverlay:SetShown(showDeadlyOverlay);
	self.DeadlyOverlayGlow:SetShown(showDeadlyOverlay);
	self.PausedOverlay:SetShown(showPausedOverlay);
	self.QueuedOverlay:SetShown(showQueuedOverlay);
	self.NormalOverlay:SetShown(showNormalOverlay);
end

EncounterTimelineIndicatorIconGridMixin = {};

local function GetTextureSetIconMask(textureSetIconMask, wantedIconMask)
	if wantedIconMask == nil then
		wantedIconMask = Constants.EncounterTimelineIconMasks.EncounterTimelineAllIcons;
	end

	return bit.band(textureSetIconMask, wantedIconMask);
end

function EncounterTimelineIndicatorIconGridMixin:SetTexturesForEvent(eventID, wantedIconMask)
	local roleIconMask = self:GetRoleIconMask();
	local roleIconTextures = self:GetRoleIconTextures();

	C_EncounterTimeline.SetEventIconTextures(eventID, GetTextureSetIconMask(roleIconMask, wantedIconMask), roleIconTextures);

	local otherIconMask = self:GetOtherIconMask();
	local otherIconTextures = self:GetOtherIconTextures();

	C_EncounterTimeline.SetEventIconTextures(eventID, GetTextureSetIconMask(otherIconMask, wantedIconMask), otherIconTextures);
end

function EncounterTimelineIndicatorIconGridMixin:GetRoleIconTextures()
	return self.RoleIndicators;
end

function EncounterTimelineIndicatorIconGridMixin:GetRoleIconMask()
	return Constants.EncounterTimelineIconMasks.EncounterTimelineRoleIcons;
end

function EncounterTimelineIndicatorIconGridMixin:GetOtherIconTextures()
	return self.OtherIndicators;
end

function EncounterTimelineIndicatorIconGridMixin:GetOtherIconMask()
	return Constants.EncounterTimelineIconMasks.EncounterTimelineOtherIcons;
end

function EncounterTimelineIndicatorIconGridMixin:GetIconTextures()
	local textures = {};
	tAppendAll(textures, self:GetRoleIconTextures());
	tAppendAll(textures, self:GetOtherIconTextures());
	return textures;
end

function EncounterTimelineIndicatorIconGridMixin:ApplyLayout(initialAnchor, direction, paddingX, paddingY, horizontalSpacing, verticalSpacing)
	local stride = 2;
	local layout = AnchorUtil.CreateGridLayout(direction, stride, paddingX, paddingY, horizontalSpacing, verticalSpacing);
	AnchorUtil.GridLayout(self:GetIconTextures(), initialAnchor, layout);
end

EncounterTimelinePausedIconMixin = {};

function EncounterTimelinePausedIconMixin:AnimateShow()
	self.HideAnimation:Stop();

	if self:IsShown() then
		return;
	end

	self.ShowAnimation:Play();
	self:Show();
end

function EncounterTimelinePausedIconMixin:AnimateHide()
	if not self:IsShown() then
		return;
	end

	self.ShowAnimation:Stop();
	self.HideAnimation:Play();
end

EncounterTimelineQueuedIconMixin = {};

function EncounterTimelineQueuedIconMixin:AnimateShow()
	self.HideAnimation:Stop();

	if self:IsShown() then
		return;
	end

	self.ShowAnimation:Play();
	self:Show();
end

function EncounterTimelineQueuedIconMixin:AnimateHide()
	if not self:IsShown() then
		return;
	end

	self.ShowAnimation:Stop();
	self.HideAnimation:Play();
end
