
ContentTrackingCheckmarkMixin = {};

function ContentTrackingCheckmarkMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, CONTENT_TRACKING_CHECKMARK_TOOLTIP_TITLE);
	GameTooltip:Show();
end

function ContentTrackingCheckmarkMixin:OnLeave()
	GameTooltip_Hide();
end


ContentTrackingElementMixin = {};

function ContentTrackingElementMixin:OnHide()
	self:ClearTrackables();
end

function ContentTrackingElementMixin:SetTrackable(trackableType, trackableID)
	self:ClearTrackables();
	self:AddTrackable(trackableType, trackableID);
end

function ContentTrackingElementMixin:AddTrackable(trackableType, trackableID)
	if not ContentTrackingUtil.IsContentTrackingEnabled() then
		return;
	end

	self.trackables = self.trackables or {};
	table.insert(self.trackables, { trackableType = trackableType, id = trackableID });
	ContentTrackingUtil.RegisterTrackableElement(self, trackableType, trackableID);
end

function ContentTrackingElementMixin:ClearTrackables()
	if self.trackables then
		for i, trackableInfo in ipairs(self.trackables) do
			ContentTrackingUtil.UnregisterTrackableElement(self, trackableInfo.trackableType, trackableInfo.id);
		end
	end

	self.trackables = {};
end

function ContentTrackingElementMixin:CheckTrackableClick(buttonName, trackableType, trackableID)
	if (buttonName == "LeftButton") and ContentTrackingUtil.IsTrackingModifierDown() then
		local trackingError = C_ContentTracking.ToggleTracking(trackableType, trackableID, Enum.ContentTrackingStopType.Manual);
		if trackingError then
			ContentTrackingUtil.DisplayTrackingError(trackingError);
		end
		local isTracking = C_ContentTracking.IsTracking(trackableType, trackableID);
		if isTracking then
			PlaySound(SOUNDKIT.CONTENT_TRACKING_START_TRACKING);
			PlaySound(SOUNDKIT.CONTENT_TRACKING_OBJECTIVE_TRACKING_START);
		else
			PlaySound(SOUNDKIT.CONTENT_TRACKING_STOP_TRACKING);
		end

		if #self.trackables == 1 then
			self:SetTrackingCheckmarkShown(isTracking);
		else
			self:UpdateTrackingCheckmark();
		end

		return not trackingError;
	end

	return false;
end

function ContentTrackingElementMixin:UpdateTrackingCheckmark()
	if not self.trackables then
		return;
	end

	local isTrackingAny = false;
	for i, trackableInfo in ipairs(self.trackables) do
		if C_ContentTracking.IsTracking(trackableInfo.trackableType, trackableInfo.id) then
			isTrackingAny = true;
			break;
		end
	end

	self:SetTrackingCheckmarkShown(isTrackingAny);
end

function ContentTrackingElementMixin:HasTrackableSource()
	if not self.trackables then
		return;
	end

	for i, trackableInfo in ipairs(self.trackables) do
		if C_ContentTracking.IsTrackable(trackableInfo.trackableType, trackableInfo.id) then
			return true;
		end
	end
end

function ContentTrackingElementMixin:SetTrackingCheckmarkShown(shouldShow)
	if not self.ContentTrackingCheckmark then
		if not shouldShow then
			return;
		end

		self.ContentTrackingCheckmark = self:CreateTexture(nil, "OVERLAY", "ContentTrackingCheckmarkTemplate");
		self.ContentTrackingCheckmark:ClearAllPoints();
		self.ContentTrackingCheckmark:SetPoint(self.checkMarkAnchor, self, self.checkMarkAnchor, self.checkMarkAnchorX, self.checkMarkAnchorY);
	end

	self.ContentTrackingCheckmark:SetShown(shouldShow);
end
