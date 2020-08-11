
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

function OptionalReagentButtonMixin:SetReagentText(name, quality)
	local itemQualityColor = ITEM_QUALITY_COLORS[quality or Enum.ItemQuality.Common];
	self.Name:SetTextColor(itemQualityColor.r, itemQualityColor.g, itemQualityColor.b);
	self.Name:SetText(name);
	
	SetItemButtonQuality(self, quality);
end
