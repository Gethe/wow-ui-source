function UIPanelCloseButtonDefaultAnchorsMixin:OnLoad()
	self:SetSize(28, 28);
	self:ClearAllPoints();
	self:SetPoint("TOPRIGHT", 0, 3);
end

function MaximizeMinimizeButtonFrameMixin:OnLoad()
	self:SetSize(28, 28);
end

-- The Camelot tab art has more empty space on the right, so the icon has to sit further left to look centered.
function SidePanelTabButtonMixin:GetIconAnchorOffsetsForTabArt()
	return -4, 0;
end
