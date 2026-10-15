
-- Classic FramerateFrame Overrides

function FramerateFrameMixin:OnLoad()
	-- For Classic, position above center-bottom.
	self:ClearAllPoints();
	self:SetPoint("BOTTOM", 0, 84);
end
