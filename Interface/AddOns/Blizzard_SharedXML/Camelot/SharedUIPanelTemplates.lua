UIPanelCloseButtonDefaultAnchorsMixin = {};

function UIPanelCloseButtonDefaultAnchorsMixin:OnLoad()
	self:SetPoint("TOPRIGHT", -2, 1);
end

-- The Camelot tab art has more empty space on the right, so the icon has to sit further left to look centered.
function SidePanelTabButtonMixin:GetIconAnchorOffsetsForTabArt()
	return -4, 0;
end
