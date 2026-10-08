local CAMELOT_NAV_BAR_TEXT_COLOR_NORMAL = CreateColor(0.8392, 0.7020, 0.5020);
local CAMELOT_NAV_BAR_TEXT_COLOR_HIGHLIGHT = CreateColor(1.0000, 0.8863, 0.7176);
local CAMELOT_NAV_BAR_TEXT_COLOR_DISABLED = CreateColor(0.5608, 0.5608, 0.5608);

local function GetButtonTextColor(enabled, highlight)
	if enabled then
		if highlight then
			return CAMELOT_NAV_BAR_TEXT_COLOR_HIGHLIGHT;
		else
			return CAMELOT_NAV_BAR_TEXT_COLOR_NORMAL;
		end
	end
	return CAMELOT_NAV_BAR_TEXT_COLOR_DISABLED;
end

local function ApplyButtonTextColor(button, enabled, highlight)
	local fontString = button:GetFontString();
	local color = GetButtonTextColor(enabled, highlight);
	fontString:SetTextColor(color:GetRGB());
end

local function UpdateButtonTextVisualState(button, enabled, highlight)
	if button.formatButtonTextCallback then
		button:formatButtonTextCallback(enabled, highlight);
	end
end

local function ApplyStoreButtonStateFormatter(storeButton)
	storeButton.formatButtonTextCallback = function(button, enabled, highlight)
		local shopIcon = "glues-characterselect-iconshop";
		if not enabled then
			shopIcon = "glues-characterselect-iconshop-dis";
		elseif highlight then
			shopIcon = "glues-characterselect-iconshop-hover";
		end

		local markup = CreateAtlasMarkup(shopIcon, 24, 24, -4);
		button:SetText(markup .. CHARACTER_SELECT_NAV_BAR_SHOP);
	end;

	UpdateButtonTextVisualState(storeButton, storeButton:IsEnabled(), storeButton:IsMouseOver());
end

function CharacterSelectNavBarButtonMixin:OnEnable()
	self.NormalTexture:Show();
	self.DisabledTexture:Hide();

	local enabled = true;
	local isHighlight = self:IsMouseOver();
	UpdateButtonTextVisualState(self, enabled, isHighlight);
	ApplyButtonTextColor(self, enabled, isHighlight);
end

function CharacterSelectNavBarButtonMixin:OnDisable()
	self.NormalTexture:Hide();
	self.DisabledTexture:Show();

	local enabled = false;
	local highlight = false;
	UpdateButtonTextVisualState(self, enabled, highlight);
	ApplyButtonTextColor(self, enabled, highlight);
end

function CharacterSelectNavBarButtonMixin:OnEnter()
	self.Highlight:Show();

	local enabled = true;
	local highlight = true;
	UpdateButtonTextVisualState(self, enabled, highlight);

	ApplyButtonTextColor(self, self:IsEnabled(), highlight);
end

function CharacterSelectNavBarButtonMixin:OnLeave()
	if not self.lockHighlight then
		self.Highlight:Hide();
	end

	local enabled = true;
	local highlight = false;
	UpdateButtonTextVisualState(self, enabled, highlight);

	ApplyButtonTextColor(self, self:IsEnabled(), highlight);
end

function CharacterSelectNavBarButtonMixin:SetLockHighlight(lockHighlight)
	self.lockHighlight = lockHighlight;
	self.Highlight:SetShown(lockHighlight or self:IsMouseOver());

	ApplyButtonTextColor(self, self:IsEnabled(), lockHighlight or self:IsMouseOver());
end

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

	if self.StoreButton then
		ApplyStoreButtonStateFormatter(self.StoreButton);
		ApplyButtonTextColor(self.StoreButton, self.StoreButton:IsEnabled(), self.StoreButton:IsMouseOver());
	end
	if self.MenuButton then
		ApplyButtonTextColor(self.MenuButton, self.MenuButton:IsEnabled(), self.MenuButton:IsMouseOver());
	end
	if self.SuperDistrictsButton then
		ApplyButtonTextColor(self.SuperDistrictsButton, self.SuperDistrictsButton:IsEnabled(), self.SuperDistrictsButton:IsMouseOver());
	end
	if self.RealmsButton then
		ApplyButtonTextColor(self.RealmsButton, self.RealmsButton:IsEnabled(), self.RealmsButton:IsMouseOver());
	end
	if self.CampsButton then
		ApplyButtonTextColor(self.CampsButton, self.CampsButton:IsEnabled(), self.CampsButton:IsMouseOver());
	end
	if self.GameModeButton then
		ApplyButtonTextColor(self.GameModeButton, self.GameModeButton:IsEnabled(), self.GameModeButton:IsMouseOver());
	end
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

	ApplyButtonTextColor(button, button:IsEnabled(), button:IsMouseOver());
end
