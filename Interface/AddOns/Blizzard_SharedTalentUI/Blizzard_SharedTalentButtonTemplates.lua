
TalentButtonSearchIconMixin = {};

function TalentButtonSearchIconMixin:OnLoad()
	self.Mouseover:SetScript("OnEnter", GenerateClosure(self.OnEnter, self));
	self.Mouseover:SetScript("OnLeave", GenerateClosure(self.OnLeave, self));
	self.Mouseover:SetSize(self.mouseoverSize, self.mouseoverSize);
end

function TalentButtonSearchIconMixin:SetMatchType(matchType)
	self.matchType = matchType;
	if not self.matchType then
		self.tooltipText = nil;
		self:Hide();
	else
		self:Show();
		local matchStyle = TalentButtonUtil.GetStyleForSearchMatchType(self.matchType);
		self.Icon:SetAtlas(matchStyle.icon);
		self.OverlayIcon:SetAtlas(matchStyle.icon);
		self.tooltipText = matchStyle.tooltipText;
	end
end

function TalentButtonSearchIconMixin:SetMouseoverEnabled(mouseoverEnabled)
	self.Mouseover:SetShown(mouseoverEnabled);
end

function TalentButtonSearchIconMixin:OnEnter()
	if self.tooltipText then
		GameTooltip:SetOwner(self.Mouseover, "ANCHOR_RIGHT", 0, 0);
		if self.tooltipBackdropStyle then
			SharedTooltip_SetBackdropStyle(GameTooltip, self.tooltipBackdropStyle);
		end
		GameTooltip_AddNormalLine(GameTooltip, self.tooltipText);
		GameTooltip:Show();
	end
end

function TalentButtonSearchIconMixin:OnLeave()
	GameTooltip_Hide();
end
