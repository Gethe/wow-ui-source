HousingExteriorFixturePointMixin = {};

function HousingExteriorFixturePointMixin:Initialize(pointFrame)
	self.pointFrame = pointFrame;
	self:SetParent(pointFrame);
	self:SetPoint("CENTER", pointFrame, "CENTER", 0, 0);
	pointFrame:SetUpdateCallback(function() self:OnPointFrameUpdated(); end);

	self.Rays1.Anim:Play();
	self.Rays2.Anim:Play();
	self.Spinner.Anim:Play();

	self:OnPointFrameUpdated();
	self:Show();
end

function HousingExteriorFixturePointMixin.Reset(framePool, self)
	Pool_HideAndClearAnchors(framePool, self);

	self.pointFrame = nil;
	self.pointInfo = nil;
end

function HousingExteriorFixturePointMixin:IsValid()
	return self.pointFrame and self.pointFrame:IsValid();
end

function HousingExteriorFixturePointMixin:IsSelected()
	return self:IsValid() and self.pointFrame:IsSelected();
end

function HousingExteriorFixturePointMixin:OnPointFrameUpdated()
	if not self:IsValid() then
		return;
	end

	if self:IsMouseMotionFocus() then
		self:OnEnter();
	else
		self:UpdateVisuals();
	end
end

function HousingExteriorFixturePointMixin:UpdateVisuals()
	if not self:IsValid() then
		return;
	end

	local isHovered = self:IsMouseMotionFocus();
	local isSelected = self.pointFrame:IsSelected();
	local isFocused = isHovered or isSelected;
	self.HoveredIcon:SetShown(isHovered and not isSelected);
	self.Rays1:SetShown(isSelected);
	self.Spinner:SetShown(isSelected);
	self.Glow:SetShown(isSelected);
	self.Rays2:SetShown(isSelected);
end

function HousingExteriorFixturePointMixin:OnEnter()
	if not self:IsValid() then
		return;
	end

	local tooltip = GameTooltip;
	tooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
	GameTooltip_AddHighlightLine(tooltip, HOUSING_EXTERIOR_CUSTOMIZATION_HOOKPOINT_EMPTY_TOOLTIP);
	tooltip:Show();

	self:UpdateVisuals();
end

function HousingExteriorFixturePointMixin:OnLeave()
	GameTooltip_Hide();
	self:UpdateVisuals();
end

function HousingExteriorFixturePointMixin:OnClick()
	if not self:IsValid() then
		return;
	end

	self.pointFrame:Select();
end

function HousingExteriorFixturePointMixin:GetDebugName()
	-- Used for easier frame inspection for debugging
	return "HousingExteriorFixturePoint";
end
