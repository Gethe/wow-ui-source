
SidePanelTabButtonMixin = { };

function SidePanelTabButtonMixin.CalculateTabSizeBasedOnTabArt()
	local tabArtInfo = C_Texture.GetAtlasInfo("common-sidetab");

	-- This tab type is stacked vertically so it's important that the height matches the visible part of the tab art (no padding on the top or bottom)
	local tabArtHeightWithoutTransparentSpace = tabArtInfo.height - 5;
	-- On the other hand, the tab art only has padding on the right side so trimming width would cause issues when anchoring the left side to a frame
	-- For now, we just take the width without modifications
	local tabArtWidthWithTransparentSpaceOnRight = tabArtInfo.width;

	return tabArtWidthWithTransparentSpaceOnRight, tabArtHeightWithoutTransparentSpace;
end

function SidePanelTabButtonMixin:OnLoad()
	self:InitializeSizeForTabArt();
	self:InitializeIconAnchoring();
end

function SidePanelTabButtonMixin:InitializeSizeForTabArt()
	local width, height = SidePanelTabButtonMixin.CalculateTabSizeBasedOnTabArt();
	self:SetSize(width, height);
end

function SidePanelTabButtonMixin:InitializeIconAnchoring()
	local offsetX, offsetY = self:GetFinalIconAnchorOffsets();
	self.Icon:ClearAllPoints();
	self.Icon:SetPoint("CENTER", offsetX, offsetY);
end

function SidePanelTabButtonMixin:GetFinalIconAnchorOffsets()
	-- Override if your UI needs to make further adjustments to the final icon position.
	-- Ex. The Social UI further adjusts its icons to make room for a counter underneath.
	return self:GetIconAnchorOffsetsForTabArt();
end

function SidePanelTabButtonMixin:GetIconAnchorOffsetsForTabArt()
	return -3, 0;
end

function SidePanelTabButtonMixin:GetPressedIconAnchorOffsets()
	local offsetX, offsetY = self:GetFinalIconAnchorOffsets();
	return offsetX + 1, offsetY - 1;
end

function SidePanelTabButtonMixin:OnMouseDown(button)
	if button == "LeftButton" then
		local offsetX, offsetY = self:GetPressedIconAnchorOffsets();
		self.Icon:SetPoint("CENTER", offsetX, offsetY);
	end
end

function SidePanelTabButtonMixin:OnMouseUp(button, upInside)
	if button == "LeftButton" then
		local offsetX, offsetY = self:GetFinalIconAnchorOffsets();
		self.Icon:SetPoint("CENTER", offsetX, offsetY);
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
	end

	if self.customMouseUpHandler then
		self.customMouseUpHandler(self, button, upInside);
	end
end

function SidePanelTabButtonMixin:SetCustomOnMouseUpHandler(handler)
	self.customMouseUpHandler = handler;
end

function SidePanelTabButtonMixin:SetFillToInterior(fillToInterior, extent)
	self.fillToInterior = fillToInterior;
	self.interiorExtent = extent;
	self:UpdateIconInterior();
end

function SidePanelTabButtonMixin:UpdateIconInterior()
	if self.fillToInterior then
		local extent = self.interiorExtent or 50;
		self.Icon:SetTexCoord(0.03125, 0.96875, 0.03125, 0.96875);
		self.Icon:SetSize(extent, extent);
	end
end

function SidePanelTabButtonMixin:SetChecked(checked)
	if checked and self.activeAtlas then
		self.Icon:SetAtlas(self.activeAtlas, TextureKitConstants.UseAtlasSize);
	elseif not checked and self.inactiveAtlas then
		self.Icon:SetAtlas(self.inactiveAtlas, TextureKitConstants.UseAtlasSize);
	end
	if self.SelectedTexture then
		self.SelectedTexture:SetShown(checked);
	end
	self:UpdateIconInterior();
end

function SidePanelTabButtonMixin:GetTooltipTextSetupFunction()
	-- override as needed
	return nil;
end

function SidePanelTabButtonMixin:OnEnter()
	if not self.tooltipText then
		return;
	end

	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(self, "ANCHOR_RIGHT", -4, -4);

	local setupFn = self:GetTooltipTextSetupFunction();
	if not setupFn or not setupFn(tooltip) then
		tooltip:SetText(self.tooltipText);
	end

	tooltip:Show();
end

function SidePanelTabButtonMixin:OnLeave()
	GetAppropriateTooltip():Hide();
end

function SidePanelTabButtonMixin:SetTabGlowAnimationPlaying(playing)
	self.TabGlowAnimation:SetPlaying(playing);
end

function SidePanelTabButtonMixin:IsTabGlowAnimationPlaying()
	return self.TabGlowAnimation:IsPlaying();
end
