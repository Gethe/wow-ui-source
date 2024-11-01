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
	if not self.lockHighlight then
		self.Highlight:Hide();
	end

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

function CharacterSelectNavBarButtonMixin:SetLockHighlight(lockHighlight)
	self.lockHighlight = lockHighlight;
	self.Highlight:SetShown(lockHighlight or self:IsMouseOver());
end

CharacterSelectNavBarMixin = {
	NavBarButtonWidthBuffer = 70,
};

local function ToggleGameEnvironmentDrawer(navBar)
	local selectionDrawer = navBar.GameEnvironmentButton.SelectionDrawer;
	selectionDrawer:SetShown(not selectionDrawer:IsShown());

	navBar.GameEnvironmentButton:SetLockHighlight(selectionDrawer:IsShown());
end

local function ToggleAccountStoreUI()
	-- Redirect is necessary to avoid load order issues.
	AccountStoreUtil.ToggleAccountStore();
end

local CharacterSelectNavBarEvents = {
	"GLOBAL_MOUSE_DOWN"
};

function CharacterSelectNavBarMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, CharacterSelectNavBarEvents);

	local function NavBarButtonSetup(newButton, label, controlCallback, passNavBarToCallback)
		newButton:SetText(label);
		newButton:SetWidth(newButton:GetTextWidth() + CharacterSelectNavBarMixin.NavBarButtonWidthBuffer);
		newButton:SetScript("OnClick", function()
			PlaySound(SOUNDKIT.GS_TITLE_OPTIONS);
			if passNavBarToCallback then
				controlCallback(self);
			else
				controlCallback();
			end
		end);
	end

	self.ButtonTray:SetButtonSetup(NavBarButtonSetup);

	local realmsCallback = GenerateFlatClosure(CharacterSelectUtil.ChangeRealm);

	local passNavBarToCallback = true;
	self.GameEnvironmentButton = self.ButtonTray:AddControl(nil, ToggleGameEnvironmentDrawer, passNavBarToCallback);
	self.GameEnvironmentButton.SelectionDrawer = CreateFrame("FRAME", nil, self.GameEnvironmentButton, "GameEnvironmentFrameTemplate");
	self.GameEnvironmentButton.SelectionDrawer:SetPoint("TOP", self.GameEnvironmentButton, "BOTTOM", 0, -20);

	EventRegistry:RegisterCallback("GameEnvironmentFrame.Hide", ToggleGameEnvironmentDrawer, self);

	if self:GetParent() == PlunderstormLobbyFrame then
		self.PlunderstoreButton = self.ButtonTray:AddControl(WOWLABS_PLUNDERSTORE_NAV_LABEL, ToggleAccountStoreUI);
	else
		self.StoreButton = self.ButtonTray:AddControl(nil, ToggleStoreUI);
	end

	self.MenuButton = self.ButtonTray:AddControl(CHARACTER_SELECT_NAV_BAR_MENU, GlueMenuFrameUtil.ShowMenu);
	self.RealmsButton = self.ButtonTray:AddControl(CHARACTER_SELECT_NAV_BAR_REALMS, realmsCallback);

	EventRegistry:RegisterCallback("GameEnvironment.UpdateNavBar", self.UpdateSelectedGameMode, self);

	-- Any specific button setups.
	self:SetButtonVisuals();
end

function CharacterSelectNavBarMixin:OnEvent(event, ...)
	if event == "GLOBAL_MOUSE_DOWN" then
		if self.GameEnvironmentButton.SelectionDrawer:IsShown() and 
			not self.GameEnvironmentButton:IsMouseOver() and
			not self.GameEnvironmentButton.SelectionDrawer:IsMouseOver() then
			ToggleGameEnvironmentDrawer(self);
		end
	end
end

function CharacterSelectNavBarMixin:SetButtonVisuals()
	-- The leftmost and rightmost buttons in the nav bar have different textures than the default.
	self.GameEnvironmentButton.Highlight:ClearAllPoints();
	self.GameEnvironmentButton.Highlight:SetPoint("TOPLEFT", -45, 0);
	self.GameEnvironmentButton.Highlight:SetPoint("BOTTOMRIGHT", 0, 0);
	self.GameEnvironmentButton.Highlight.Backdrop:SetAtlas("glues-characterselect-tophud-selected-left", TextureKitConstants.IgnoreAtlasSize);
	self.GameEnvironmentButton.Highlight.Line:SetAtlas("glues-characterselect-tophud-selected-line-left", TextureKitConstants.IgnoreAtlasSize);
	self.GameEnvironmentButton.NormalTexture:SetAtlas("glues-characterselect-tophud-left-bg", TextureKitConstants.IgnoreAtlasSize);
	self.GameEnvironmentButton.NormalTexture:SetPoint("TOPLEFT", -102, 0);
	self.GameEnvironmentButton.DisabledTexture:SetAtlas("glues-characterselect-tophud-left-dis-bg", TextureKitConstants.IgnoreAtlasSize);
	self.GameEnvironmentButton.DisabledTexture:SetPoint("TOPLEFT", -102, 0);

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

	if self.StoreButton then
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

	self:UpdateSelectedGameMode();
end

function CharacterSelectNavBarMixin:UpdateSelectedGameMode()
	local function GetLogoTextureMarkup(selectedEnvironment)
		if selectedEnvironment == Enum.GameEnvironment.WoWLabs then
			return CreateTextureMarkup([[Interface\Glues\Common\Glues-WoW-PlunderstormLogo]], 244, 244, 72, 72, 0, 1, 0, 1, 0, -18);
		end

		local currentExpansionLevel = AccountUpgradePanel_GetBannerInfo();
		if currentExpansionLevel then
			local environmentTexture = GetDisplayedExpansionLogo(currentExpansionLevel);
			return environmentTexture and CreateTextureMarkup(environmentTexture, 244, 122, 72, 36, 0, 1, 0, 1, 0, 0) or "";
		end

		return "";
	end

	-- Texture on the Modes button is dependent on the selected game mode
	local selectedEnvironment = self.GameEnvironmentButton.SelectionDrawer:GetSelectedGameEnvironment();
	local logoTextureMarkup = GetLogoTextureMarkup(selectedEnvironment);
	self.GameEnvironmentButton:SetText(logoTextureMarkup .. WOWLABS_MODE_NAV_BUTTON);
	self.GameEnvironmentButton:SetWidth(self.GameEnvironmentButton:GetTextWidth() + CharacterSelectNavBarMixin.NavBarButtonWidthBuffer);

	self.ButtonTray:Layout();
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

function CharacterSelectNavBarMixin:SetGameEnvironmentButtonEnabled(enabled)
	self.GameEnvironmentButton:SetEnabled(enabled);

	self:UpdateButtonDividerState(self.StoreButton or self.PlunderstoreButton);
end

function CharacterSelectNavBarMixin:SetStoreButtonEnabled(enabled)
	if not self.StoreButton then
		return;
	end

	self.StoreButton:SetEnabled(enabled);

	local highlight = false;
	self.StoreButton:formatButtonTextCallback(enabled, highlight);

	self:UpdateButtonDividerState(self.GameEnvironmentButton);
	self:UpdateButtonDividerState(self.StoreButton);
end

function CharacterSelectNavBarMixin:SetMenuButtonEnabled(enabled)
	self.MenuButton:SetEnabled(enabled);

	self:UpdateButtonDividerState(self.StoreButton or self.PlunderstoreButton);
	self:UpdateButtonDividerState(self.MenuButton);
end

function CharacterSelectNavBarMixin:SetRealmsButtonEnabled(enabled)
	self.RealmsButton:SetEnabled(enabled);

	self:UpdateButtonDividerState(self.MenuButton);
	self:UpdateButtonDividerState(self.RealmsButton);
end
