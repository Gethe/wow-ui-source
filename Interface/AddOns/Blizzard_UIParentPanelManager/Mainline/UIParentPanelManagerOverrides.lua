local _, addonTable = ...; -- Used for passing functions between UIParentPanelManager.lua and other files in this addon.

BOTTOM_FRAME_CONTAINER_MARGIN = 15;

addonTable.UIParentManageFramePositions = function(self)
	if MainActionBar and MicroButtonAndBagsBar and not MainActionBar:IsUserPlaced() and not MicroButtonAndBagsBar:IsUserPlaced() then
		local screenWidth = UIParent:GetWidth();
		local barScale = 1;
		local barWidth = MainActionBar:GetWidth();
		local barMargin = MAIN_MENU_BAR_MARGIN;
		local bagsWidth = MicroButtonAndBagsBar:GetWidth();
		local contentsWidth = barWidth + bagsWidth;
		if contentsWidth > screenWidth then
			barScale = screenWidth / contentsWidth;
			barWidth = barWidth * barScale;
			bagsWidth = bagsWidth * barScale;
			barMargin = barMargin * barScale;
		end
		MainActionBar:SetScale(barScale);
	end

	self:UIParentManageBottomFrameContainer();
	self:UIParentManageRightFrameContainer();

	if(ObjectiveTrackerFrame and ObjectiveTrackerFrame:IsShown()) then
		ObjectiveTrackerFrame:UpdateHeight();
	end
	if(ContainerFrame) then
		UpdateContainerFrameAnchors();
	end
end
