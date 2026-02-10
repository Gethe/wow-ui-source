EncounterTimelineUtil = {};

function EncounterTimelineUtil.GetIndicatorIconMask()
	local visibleIconMask = Constants.EncounterTimelineIconMasks.EncounterTimelineNoIcons;

	if CVarCallbackRegistry:GetCVarValueBool(EncounterTimelineIndicatorIconCVars.Enabled) then
		visibleIconMask = Constants.EncounterTimelineIconMasks.EncounterTimelineAllIcons;
	end

	-- Note that we store icon sets in terms of _hidden_ sets in CVars. This
	-- means that we want to unset bits in visibleIconMask if any individual
	-- bitfield is set. The reason for this is to allow new sets to be added
	-- in the future with them enabled by default - if the user wants no
	-- icons ever, then the enable checkbox is what they should be changing.

	for bitfieldIndex, iconsToHide in pairs(EncounterTimelineIconSetMasks) do
		if CVarCallbackRegistry:GetCVarBitfieldIndex(EncounterTimelineIndicatorIconCVars.HiddenIconMask, bitfieldIndex) then
			local shouldSet = false;
			visibleIconMask = FlagsUtil.Combine(visibleIconMask, iconsToHide, shouldSet);
		end
	end

	return visibleIconMask;
end

function EncounterTimelineUtil.GetViewTypeFromEditMode(editModeViewType)
	-- We keep the two enums separate to allow for the timeline view type
	-- enum to have extra entries that aren't exposed for user configuration.

	if editModeViewType == Enum.EncounterEventsViewType.Timeline then
		return Enum.EncounterTimelineViewType.Timeline;
	elseif editModeViewType == Enum.EncounterEventsViewType.Bars then
		return Enum.EncounterTimelineViewType.Bars;
	else
		assertsafe(false, "Unknown EncounterEventsViewType variant (%s)", editModeViewType);
		return Enum.EncounterTimelineViewType.Timeline;
	end
end

local TerminalEventStates = {
	[Enum.EncounterTimelineEventState.Canceled] = true;
	[Enum.EncounterTimelineEventState.Finished] = true;
};

function EncounterTimelineUtil.IsTerminalEventState(state)
	return TerminalEventStates[state] == true;
end

EncounterTimelineTrackOrientationMixin = {};

function EncounterTimelineTrackOrientationMixin:GetStartPoint()
	return self.primaryAxisStartPoint;
end

function EncounterTimelineTrackOrientationMixin:GetEndPoint()
	return self.primaryAxisEndPoint;
end

function EncounterTimelineTrackOrientationMixin:IsHorizontal()
	return self.primaryAxisIsVertical ~= true;
end

function EncounterTimelineTrackOrientationMixin:IsVertical()
	return self.primaryAxisIsVertical == true;
end

function EncounterTimelineTrackOrientationMixin:GetOrientedExtents(w, h)
	if self.primaryAxisIsVertical then
		return h, w;
	else
		return w, h;
	end
end

function EncounterTimelineTrackOrientationMixin:GetOrientedOffsets(x, y)
	x = x * self.primaryAxisOffsetMultiplier;
	y = y * self.crossAxisOffsetMultiplier;

	if self.primaryAxisIsVertical then
		return y, x;
	else
		return x, y;
	end
end

function EncounterTimelineTrackOrientationMixin:GetOrientedTexCoord(x1, y1, x2, y2, x3, y3, x4, y4)
	return self.texCoordTranslator(x1, y1, x2, y2, x3, y3, x4, y4);
end

function EncounterTimelineTrackOrientationMixin:GetTranslatedPointName(point)
	if point == "START" then
		return self:GetStartPoint();
	elseif point == "END" then
		return self:GetEndPoint();
	else
		return point;
	end
end

function EncounterTimelineUtil.CreateTrackOrientation(orientationSetting, iconDirectionSetting)
	local orientationData = EncounterTimelineTrackOrientationSetup[orientationSetting][iconDirectionSetting];
	local orientation = CreateFromMixins(EncounterTimelineTrackOrientationMixin, orientationData);

	-- This field will (probably) be used at some point for swapping the
	-- spell name from left/right while in a vertical orientation; for now
	-- just hardcoding it.
	orientation.crossAxisOffsetMultiplier = 1;

	return orientation;
end

EncounterTimelineOrientedScriptRegionMixin = {};

function EncounterTimelineOrientedScriptRegionMixin:SetOrientedPoint(orientation, point, relativeTo, relativePoint, x, y)
	point = orientation:GetTranslatedPointName(point);
	relativePoint = orientation:GetTranslatedPointName(relativePoint);
	self:SetPoint(point, relativeTo, relativePoint, orientation:GetOrientedOffsets(x, y));
end

function EncounterTimelineOrientedScriptRegionMixin:SetOrientedPointsOffset(orientation, x, y)
	self:SetPointsOffset(orientation:GetOrientedOffsets(x, y));
end

function EncounterTimelineOrientedScriptRegionMixin:SetOrientedSize(orientation, w, h)
	self:SetSize(orientation:GetOrientedExtents(w, h));
end

EncounterTimelineOrientedFrameMixin = CreateFromMixins(EncounterTimelineOrientedScriptRegionMixin);

EncounterTimelineOrientedTextureMixin = CreateFromMixins(EncounterTimelineOrientedScriptRegionMixin);

function EncounterTimelineOrientedTextureMixin:SetOrientedAtlas(orientation, atlasName)
	self:SetAtlas(atlasName, TextureKitConstants.UseAtlasSize);
	self:SetOrientedSize(orientation, self:GetSize());
end

function EncounterTimelineOrientedTextureMixin:SetOrientedTexCoord(orientation, x1, y1, x2, y2)
	self:SetTexCoord(orientation:GetOrientedTexCoord(x1, y1, x1, y2, x2, y1, x2, y2));
end

function EncounterTimelineOrientedTextureMixin:SetOrientedTexCoordToDefaults(orientation)
	self:SetTexCoord(orientation:GetOrientedTexCoord(0, 0, 0, 1, 1, 0, 1, 1));
end

function EncounterTimelineOrientedTextureMixin:SetOrientedTexCoordPerVertex(orientation, x1, y1, x2, y2, x3, y3, x4, y4)
	self:SetTexCoord(orientation:GetOrientedTexCoord(x1, y1, x2, y2, x3, y3, x4, y4));
end

EncounterTimelineTrackInterpolatorMixin = {};

function EncounterTimelineTrackInterpolatorMixin:Init()
	self:SetFixedOffset(0);
end

function EncounterTimelineTrackInterpolatorMixin:Reset()
	self:SetFixedOffset(0);
end

function EncounterTimelineTrackInterpolatorMixin:GetCurrentOffset()
	return Lerp(self.offsetFrom, self.offsetTo, self:GetCurrentProgress());
end

function EncounterTimelineTrackInterpolatorMixin:GetCurrentProgress()
	return ClampedPercentageBetween(self.currentTime, self.startTime, self.endTime);
end

function EncounterTimelineTrackInterpolatorMixin:GetCurrentTime()
	return self.currentTime;
end

function EncounterTimelineTrackInterpolatorMixin:SetFixedOffset(offset)
	self.offsetFrom = offset;
	self.offsetTo = offset;
	self.startTime = 0;
	self.endTime = 0;
	self.useAbsoluteTime = true;
	self.currentTime = 0;
end

function EncounterTimelineTrackInterpolatorMixin:SetInterpolatedOffset(offsetFrom, offsetTo, startTime, endTime, useAbsoluteTime)
	self.offsetFrom = offsetFrom;
	self.offsetTo = offsetTo;
	self.startTime = startTime;
	self.endTime = endTime;
	self.useAbsoluteTime = (useAbsoluteTime == true);
	self.currentTime = 0;
end

function EncounterTimelineTrackInterpolatorMixin:Update(eventID)
	local currentTime;

	if self.useAbsoluteTime then
		currentTime = C_EncounterTimeline.GetCurrentTime();
	else
		currentTime = C_EncounterTimeline.GetEventTimeRemaining(eventID);
	end

	-- GetEventTimeRemaining can return a nil value if an event has been
	-- removed from the timeline. In such a circumstance, we want the
	-- interpolation to effectively pause at the last sampled time value.

	if currentTime ~= nil then
		self.currentTime = currentTime;
	end

	return self:GetCurrentOffset();
end

function EncounterTimelineUtil.CreateTrackInterpolator()
	local interpolator = CreateFromMixins(EncounterTimelineTrackInterpolatorMixin);
	interpolator:Reset();
	return interpolator;
end
