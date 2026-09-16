function CharacterSelectNavBarMixin:SetButtonVisuals()
	-- The leftmost and rightmost buttons in the nav bar have different textures than the default.
	self.leftmostButton.Highlight:ClearAllPoints();
	self.leftmostButton.Highlight:SetPoint("BOTTOMLEFT", 4, 7);
	self.leftmostButton.Highlight:SetPoint("BOTTOMRIGHT", -3, 7);

	self.leftmostButton.Highlight.Backdrop:SetAtlas("glues-characterselect-tophud-selected-left", TextureKitConstants.IgnoreAtlasSize);
	self.leftmostButton.Highlight.Backdrop:ClearAllPoints();
	self.leftmostButton.Highlight.Backdrop:SetPoint("BOTTOMLEFT", 0, 0);
	self.leftmostButton.Highlight.Backdrop:SetPoint("BOTTOMRIGHT", -18, 0);

	self.leftmostButton.NormalTexture:SetAtlas("glues-characterselect-tophud-left-bg", TextureKitConstants.IgnoreAtlasSize);
	self.leftmostButton.NormalTexture:SetPoint("TOPLEFT", -27, 0);

	self.leftmostButton.DisabledTexture:SetAtlas("glues-characterselect-tophud-left-dis-bg", TextureKitConstants.IgnoreAtlasSize);
	self.leftmostButton.DisabledTexture:SetPoint("TOPLEFT", -27, 0);

	-- Do not show divider bar on rightmost option.
	self.rightmostButton.Bar:Hide();
	self.rightmostButton.Highlight:ClearAllPoints();
	self.rightmostButton.Highlight:SetPoint("BOTTOMLEFT", 9, 7);
	self.rightmostButton.Highlight:SetPoint("BOTTOMRIGHT", 0, 7);

	self.rightmostButton.Highlight.Backdrop:SetAtlas("glues-characterselect-tophud-selected-right", TextureKitConstants.IgnoreAtlasSize);
	self.rightmostButton.Highlight.Backdrop:ClearAllPoints();
	self.rightmostButton.Highlight.Backdrop:SetPoint("BOTTOMLEFT", 0, 0);
	self.rightmostButton.Highlight.Backdrop:SetPoint("BOTTOMRIGHT", -10, 0);

	self.rightmostButton.NormalTexture:SetAtlas("glues-characterselect-tophud-right-bg", TextureKitConstants.IgnoreAtlasSize);
	self.rightmostButton.NormalTexture:SetPoint("BOTTOMRIGHT", 27, 0);

	self.rightmostButton.DisabledTexture:SetAtlas("glues-characterselect-tophud-right-dis-bg", TextureKitConstants.IgnoreAtlasSize);
	self.rightmostButton.DisabledTexture:SetPoint("BOTTOMRIGHT", 27, 0);
end

function CharacterSelectNavBarMixin:ResetButtonVisuals(button)
	button.Bar:Show();
	button.Highlight:ClearAllPoints();
	button.Highlight:SetPoint("TOPLEFT", 0, 7);
	button.Highlight:SetPoint("BOTTOMRIGHT", -7, 7);
	button.Highlight.Backdrop:SetAtlas("glues-characterselect-tophud-selected-middle", TextureKitConstants.IgnoreAtlasSize);

	button.NormalTexture:SetAtlas("glues-characterselect-tophud-middle-bg", TextureKitConstants.IgnoreAtlasSize);
	button.NormalTexture:ClearAllPoints();
	button.NormalTexture:SetAllPoints();
	button.DisabledTexture:SetAtlas("glues-characterselect-tophud-middle-dis-bg", TextureKitConstants.IgnoreAtlasSize);
	button.DisabledTexture:ClearAllPoints();
	button.DisabledTexture:SetAllPoints();
end
