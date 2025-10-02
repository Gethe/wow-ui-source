
function BaseActionButtonMixin:UpdateButtonArt()
	if (not self.SlotArt or not self.SlotBackground) then
		return;
	end

	if (self.bar and not self.bar.hideBarArt) then
		self.SlotArt:Show();
		self.SlotBackground:Hide();

		self:SetNormalAtlas("UI-HUD-ActionBar-IconFrame");
		self.NormalTexture:SetDrawLayer("OVERLAY");
		self.NormalTexture:SetSize(46, 45);

		self:SetPushedAtlas("UI-HUD-ActionBar-IconFrame-Down");
		self.PushedTexture:SetDrawLayer("OVERLAY");
		self.PushedTexture:SetSize(46, 45);
	else
		self.SlotArt:Hide();
		self.SlotBackground:Show();

		self:SetNormalAtlas("UI-HUD-ActionBar-IconFrame-AddRow");
		self.NormalTexture:SetDrawLayer("OVERLAY");
		self.NormalTexture:SetSize(51, 51);

		self:SetPushedAtlas("UI-HUD-ActionBar-IconFrame-AddRow-Down");
		self.PushedTexture:SetDrawLayer("OVERLAY");
		self.PushedTexture:SetSize(51, 51);
	end
end
