function ContainerFrame_UpdatePortraitPosition(self)
	self.PortraitContainer.CircleMask:ClearAllPoints();
	self.PortraitContainer.CircleMask:SetPoint("TOPLEFT", self.PortraitContainer.portrait, "TOPLEFT", 0, 0);
	self.PortraitContainer.CircleMask:SetPoint("BOTTOMRIGHT", self.PortraitContainer.portrait, "BOTTOMRIGHT", 0, 0);
end

function ContainerFrameItemButtonMixin:ShouldUseBagIconForEmptySlot()
	-- Override
	return self:IsCombined();
end