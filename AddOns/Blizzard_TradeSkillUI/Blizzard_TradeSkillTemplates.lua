
OptionalReagentButtonMixin = {};

function OptionalReagentButtonMixin:OnLoad()
	self.Name:SetFontObject("GameFontHighlightSmall");
	self.Name:SetMaxLines(3);
	self.Name:ClearAllPoints();
	self.Name:SetPoint("LEFT", self.Icon, "RIGHT", 6, 0);
end

function OptionalReagentButtonMixin:GetGlowingProgress()
	return self.SocketGlowPulseAnim:GetProgress();
end

function OptionalReagentButtonMixin:SetGlowing(isGlowing, progress)
	self.SocketGlowPulseAnim:Stop();
	self.SocketGlow:SetShown(isGlowing);
	if isGlowing then
		local reverse = nil;
		self.SocketGlowPulseAnim:Play(reverse, progress);
	end
end

function OptionalReagentButtonMixin:SetReagentQuality(quality)
	local itemQualityColor = ITEM_QUALITY_COLORS[quality];
	self.Name:SetTextColor(itemQualityColor.r, itemQualityColor.g, itemQualityColor.b);
	self.IconBorder:Show();
	SetItemButtonQuality(self, quality);
end

function OptionalReagentButtonMixin:SetReagentColor(color)
	self.Name:SetTextColor(color:GetRGB());
	self.IconBorder:Hide();
end

function OptionalReagentButtonMixin:SetReagentText(name)
	self.Name:SetText(name);
end

function OptionalReagentButtonMixin:SetLocked(locked, lockedReason)
	self.locked = locked;
	self.lockedReason = lockedReason;
	self:SetEnabled(not locked);
end

function OptionalReagentButtonMixin:IsLocked()
	return self.locked;
end

function OptionalReagentButtonMixin:GetLockedTooltip()
	return self.lockedReason;
end
