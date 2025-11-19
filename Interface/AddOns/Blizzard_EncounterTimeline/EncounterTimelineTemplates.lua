EncounterTimelineEventIconMixin = CreateFromMixins(EncounterTimelineOrientedFrameMixin);

function EncounterTimelineEventIconMixin:GetIconTexture()
	return self.IconTexture;
end

function EncounterTimelineEventIconMixin:PlayHighlightAnimation()
	-- The swirl alpha needs forcing to maximum because the animation has
	-- a start delay on alpha changes it would apply to this, and we need it
	-- at full visibility for this initial delay period.

	self.HighlightSwirl:SetAlpha(1.0);
	self.HighlightAnimation:Play();
end

function EncounterTimelineEventIconMixin:SetHighlightGlowAlpha(alpha)
	self.HighlightGlow:SetAlpha(alpha);
end

function EncounterTimelineEventIconMixin:SetIcon(iconFileID)
	self.IconTexture:SetTexture(iconFileID or QUESTION_MARK_ICON);
end

function EncounterTimelineEventIconMixin:StopHighlightAnimation()
	self.HighlightSwirl:SetAlpha(0.0);
	self.HighlightGlow:SetAlpha(0.0);
	self.HighlightAnimation:Stop();
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

function EncounterTimelineIndicatorIconGridMixin:ApplyLayout(initialAnchor, layout)
	AnchorUtil.GridLayout(self:GetIconTextures(), initialAnchor, layout);
end
