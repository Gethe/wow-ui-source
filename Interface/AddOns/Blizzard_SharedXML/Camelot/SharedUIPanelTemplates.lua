function UIPanelCloseButtonDefaultAnchorsMixin:OnLoad()
	self:SetSize(28, 28);
	self:ClearAllPoints();
	self:SetPoint("TOPRIGHT", 0, 3);
end

function MaximizeMinimizeButtonFrameMixin:OnLoad()
	self:SetSize(28, 28);
end
