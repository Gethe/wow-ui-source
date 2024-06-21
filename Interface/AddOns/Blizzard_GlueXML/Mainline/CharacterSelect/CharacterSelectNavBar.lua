CharacterSelectNavBarButtonMixin = {};

function CharacterSelectNavBarButtonMixin:OnEnter()
	self.Highlight:Show();

	if self.formatButtonTextCallback then
		local enabled = true;
		local highlight = true;
		self:formatButtonTextCallback(enabled, highlight);
	end
end

function CharacterSelectNavBarButtonMixin:OnLeave()
	self.Highlight:Hide();

	if self.formatButtonTextCallback then
		local enabled = true;
		local highlight = false;
		self:formatButtonTextCallback(enabled, highlight);
	end
end

function CharacterSelectNavBarButtonMixin:OnEnable()
	self.NormalTexture:Show();
	self.DisabledTexture:Hide();
end

function CharacterSelectNavBarButtonMixin:OnDisable()
	self.NormalTexture:Hide();
	self.DisabledTexture:Show();
end

CharacterSelectNavBarMixin = {
	NavBarButtonWidthBuffer = 70,
};

function CharacterSelectNavBarMixin:OnLoad()
	local function NavBarButtonSetup(newButton, label, controlCallback)
		newButton:SetText(label);
		newButton:SetWidth(newButton:GetTextWidth() + CharacterSelectNavBarMixin.NavBarButtonWidthBuffer);
		newButton:SetScript("OnClick", function()
			PlaySound(SOUNDKIT.GS_TITLE_OPTIONS);
			controlCallback();
		end);
	end

	self.ButtonTray:SetButtonSetup(NavBarButtonSetup);

	local realmsCallback = GenerateFlatClosure(CharacterSelectUtil.ChangeRealm);

	self.StoreButton = self.ButtonTray:AddControl(nil, ToggleStoreUI);
	self.MenuButton = self.ButtonTray:AddControl(CHARACTER_SELECT_NAV_BAR_MENU, GlueMenuFrameUtil.ShowMenu);
	self.RealmsButton = self.ButtonTray:AddControl(CHARACTER_SELECT_NAV_BAR_REALMS, realmsCallback);

	-- Any specific button setups.
	self:SetButtonVisuals();
end

function CharacterSelectNavBarMixin:SetButtonVisuals()
	-- The leftmost and rightmost buttons in the nav bar have different textures than the default.
	self.StoreButton.Highlight:ClearAllPoints();
	self.StoreButton.Highlight:SetPoint("TOPLEFT", -45, 0);
	self.StoreButton.Highlight:SetPoint("BOTTOMRIGHT", 0, 0);
	self.StoreButton.Highlight.Backdrop:SetAtlas("glues-characterselect-tophud-selected-left", TextureKitConstants.IgnoreAtlasSize);
	self.StoreButton.Highlight.Line:SetAtlas("glues-characterselect-tophud-selected-line-left", TextureKitConstants.IgnoreAtlasSize);
	self.StoreButton.NormalTexture:SetAtlas("glues-characterselect-tophud-left-bg", TextureKitConstants.IgnoreAtlasSize);
	self.StoreButton.NormalTexture:SetPoint("TOPLEFT", -102, 0);
	self.StoreButton.DisabledTexture:SetAtlas("glues-characterselect-tophud-left-dis-bg", TextureKitConstants.IgnoreAtlasSize);
	self.StoreButton.DisabledTexture:SetPoint("TOPLEFT", -102, 0);

	-- Do not show divider bar on rightmost option.
	self.RealmsButton.Bar:Hide();
	self.RealmsButton.Highlight:ClearAllPoints();
	self.RealmsButton.Highlight:SetPoint("TOPLEFT", 0, 0);
	self.RealmsButton.Highlight:SetPoint("BOTTOMRIGHT", 45, 0);
	self.RealmsButton.Highlight.Backdrop:SetAtlas("glues-characterselect-tophud-selected-right", TextureKitConstants.IgnoreAtlasSize);
	self.RealmsButton.Highlight.Line:SetAtlas("glues-characterselect-tophud-selected-line-right", TextureKitConstants.IgnoreAtlasSize);
	self.RealmsButton.NormalTexture:SetAtlas("glues-characterselect-tophud-right-bg", TextureKitConstants.IgnoreAtlasSize);
	self.RealmsButton.NormalTexture:SetPoint("BOTTOMRIGHT", 102, 0);
	self.RealmsButton.DisabledTexture:SetAtlas("glues-characterselect-tophud-right-dis-bg", TextureKitConstants.IgnoreAtlasSize);
	self.RealmsButton.DisabledTexture:SetPoint("BOTTOMRIGHT", 102, 0);

	-- The store button has a custom icon that must match the text state.
	local function FormatStoreButtonText(self, enabled, highlight)
		local shopIcon = "glues-characterselect-iconshop";
		if not enabled then
			shopIcon = "glues-characterselect-iconshop-dis";
		elseif highlight then
			shopIcon = "glues-characterselect-iconshop-hover";
		end
		self:SetText(CreateAtlasMarkup(shopIcon, 24, 24, -4)..CHARACTER_SELECT_NAV_BAR_SHOP);
	end
	self.StoreButton.formatButtonTextCallback = FormatStoreButtonText;

	local enabled = true;
	local highlight = false;
	self.StoreButton:formatButtonTextCallback(enabled, highlight);
	self.StoreButton:SetWidth(self.StoreButton:GetTextWidth() + CharacterSelectNavBarMixin.NavBarButtonWidthBuffer);
end

function CharacterSelectNavBarMixin:UpdateButtonDividerState(button)
	if not button.Bar or not button.Bar:IsShown() then
		return;
	end

	-- The dividers between buttons should look enabled if either button next to it is also enabled, disabled otherwise.
	local isDividerBarEnabled = button:IsEnabled();

	if button == self.StoreButton then
		isDividerBarEnabled = isDividerBarEnabled or self.MenuButton:IsEnabled();
	elseif button == self.MenuButton then
		isDividerBarEnabled = isDividerBarEnabled or self.RealmsButton:IsEnabled();
	end

	button.Bar:SetAtlas(isDividerBarEnabled and "glues-characterselect-tophud-bg-divider" or "glues-characterselect-tophud-bg-divider-dis", TextureKitConstants.UseAtlasSize);
end

function CharacterSelectNavBarMixin:SetStoreButtonEnabled(enabled)
	self.StoreButton:SetEnabled(enabled);

	local highlight = false;
	self.StoreButton:formatButtonTextCallback(enabled, highlight);

	self:UpdateButtonDividerState(self.StoreButton);
end

function CharacterSelectNavBarMixin:SetMenuButtonEnabled(enabled)
	self.MenuButton:SetEnabled(enabled);

	self:UpdateButtonDividerState(self.StoreButton);
	self:UpdateButtonDividerState(self.MenuButton);
end

function CharacterSelectNavBarMixin:SetRealmsButtonEnabled(enabled)
	self.RealmsButton:SetEnabled(enabled);

	self:UpdateButtonDividerState(self.MenuButton);
	self:UpdateButtonDividerState(self.RealmsButton);
end
