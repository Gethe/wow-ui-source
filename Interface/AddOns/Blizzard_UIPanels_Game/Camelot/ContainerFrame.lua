function ContainerFrame_UpdatePortraitPosition(self)
	self.PortraitContainer.CircleMask:ClearAllPoints();
	self.PortraitContainer.CircleMask:SetPoint("TOPLEFT", self.PortraitContainer.portrait, "TOPLEFT", 0, 0);
	self.PortraitContainer.CircleMask:SetPoint("BOTTOMRIGHT", self.PortraitContainer.portrait, "BOTTOMRIGHT", 0, 0);
end

--[[
	Boolean flag that identifies this frame as having updated jump hints, no longer
	using legacy FrameControlsManager jump hints only displayed on targets.
	See FrameControlsManager:RefreshJumpHints
]]
ContainerFrameCombinedBagsMixin.useFooterJumpHints = true;

-- Text to display next to jump hints on other frames, if the jump takes them here
function ContainerFrameCombinedBagsMixin:GetJumpHintLabel()
	return BAG_NAME_BACKPACK;
end
