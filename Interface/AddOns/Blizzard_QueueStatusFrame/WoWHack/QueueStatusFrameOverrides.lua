-- Mainline QueueStatusFrame Overrides

function QueueStatusButtonMixin:UpdateDefaultAnchor()
	if (not self:IsInDefaultPosition()) then
		return;
	end

	local scale = self:GetScale();
	self:ClearAllPoints();
	self:SetPoint(GROUP_FINDER_ANCHOR_POINT, MicroMenu, GROUP_FINDER_RELATIVE_POINT, GROUP_FINDER_OFFSET_X / scale, GROUP_FINDER_OFFSET_Y / scale);
end
