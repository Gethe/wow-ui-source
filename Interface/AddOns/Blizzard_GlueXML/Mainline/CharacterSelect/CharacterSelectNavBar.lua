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

	local enabled = true;
	local highlight = selectionDrawer:IsShown();
	navBar.GameEnvironmentButton:formatButtonTextCallback(enabled, highlight);
	navBar.GameEnvironmentButton:SetLockHighlight(highlight);
end

local function ToggleAccountStoreUI()
	-- Redirect is necessary to avoid load order issues.
	AccountStoreUtil.ToggleAccountStore();
end

local function UpdateButtonStatesForCollections(enabledState)
	-- Various UI being enabled/shown is based on if collections are showing or not.
	CharacterSelect_UpdateButtonState();
	CharacterServicesMaster_UpdateServiceButton();
	CharacterSelect_SelectCharacter(CharacterSelect.selectedIndex, 1);

	if not enabledState then
		-- Use saved state when going back, do not assume player wants list expanded.
		local isExpanded = GetCVarBool("expandWarbandCharacterList");
		CharacterSelectUI:ExpandCharacterList(isExpanded);
	else
		CharacterSelectUI:ExpandCharacterList(false);
	end
	CharacterSelectUI:SetCharacterListToggleEnabled(not enabledState);
end

local function ToggleCollections()
	local collections = CharacterSelectUI.CollectionsFrame;
	local enabledState = not collections:IsShown();

	-- Clear helptip if not yet closed.
	if enabledState and not GetCVarBool("seenCharacterSelectNavBarCampsHelpTip") then
		SetCVar("seenCharacterSelectNavBarCampsHelpTip", 1);
		HelpTip:Hide(CharacterSelectUI.VisibilityFramesContainer.NavBar.CampsButton, CHARACTER_SELECT_NAV_BAR_CAMPS_HELPTIP);
	end

	collections:SetShown(enabledState);
	UpdateButtonStatesForCollections(enabledState);
end

local CharacterSelectNavBarEvents = {
	"GLOBAL_MOUSE_DOWN",
	"ACCOUNT_CVARS_LOADED"
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

	if self:GetParent() == PlunderstormLobbyFrame then
		self:RegisterEvent("STORE_FRONT_STATE_UPDATED");

		self.PlunderstoreButton = self.ButtonTray:AddControl(WOWLABS_PLUNDERSTORE_NAV_LABEL, ToggleAccountStoreUI);
		self.PlunderstoreButton:Disable();

		self.PlunderstoreButton:SetMotionScriptsWhileDisabled(true);
		self.PlunderstoreButton:SetScript("OnEnter", function(buttonSelf)
			if not buttonSelf:IsEnabled() then
				local tooltip = GetAppropriateTooltip();
				tooltip:SetOwner(buttonSelf, "ANCHOR_BOTTOM");
				tooltip:SetText(ACCOUNT_STORE_UNAVAILABLE);
				tooltip:Show();
			end
		end);

		self.PlunderstoreButton:SetScript("OnLeave", function()
			GetAppropriateTooltip():Hide();
		end);
	else
		self.StoreButton = self.ButtonTray:AddControl(nil, ToggleStoreUI);
	end

	self.MenuButton = self.ButtonTray:AddControl(CHARACTER_SELECT_NAV_BAR_MENU, GlueMenuFrameUtil.ShowMenu);
	self.RealmsButton = self.ButtonTray:AddControl(CHARACTER_SELECT_NAV_BAR_REALMS, realmsCallback);
	self.CampsButton = self.ButtonTray:AddControl(CHARACTER_SELECT_NAV_BAR_CAMPS, ToggleCollections);

	EventRegistry:RegisterCallback("GameEnvironmentFrame.Hide", ToggleGameEnvironmentDrawer, self);
	EventRegistry:RegisterCallback("GameEnvironment.UpdateNavBar", self.UpdateSelectedGameMode, self);

	local function OnCollectionsHide()
		UpdateButtonStatesForCollections(false);
	end
	EventRegistry:RegisterCallback("GlueCollections.OnHide", OnCollectionsHide);

	-- Any specific button setups.
	self:SetButtonVisuals();

	self.GameEnvironmentButton.TutorialBadge:ClearAllPoints();
	self.GameEnvironmentButton.TutorialBadge:SetPoint("CENTER", self.GameEnvironmentButton:GetFontString(), "LEFT", -10, 0);
end

function CharacterSelectNavBarMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);

	self.GameEnvironmentButton.TutorialBadge:Hide();
	self.tryForceShowModes = not g_newGameModeAvailableAcknowledged and C_GameEnvironmentManager.GetCurrentEventRealmQueues() ~= Enum.EventRealmQueues.None;
end

function CharacterSelectNavBarMixin:OnEvent(event, ...)
	if event == "GLOBAL_MOUSE_DOWN" then
		if self.GameEnvironmentButton.SelectionDrawer:IsShown() and 
			not self.GameEnvironmentButton:IsMouseOver() and
			not self.GameEnvironmentButton.SelectionDrawer:IsMouseOver() then
			ToggleGameEnvironmentDrawer(self);
		end
	elseif event == "ACCOUNT_CVARS_LOADED" then
		self:EvaluateHelptips();
	elseif event == "STORE_FRONT_STATE_UPDATED" then
		if self.PlunderstoreButton then
			self.PlunderstoreButton:SetEnabled(C_AccountStore.GetStoreFrontState(Constants.AccountStoreConsts.PlunderstormStoreFrontID) == Enum.AccountStoreState.Available);
		end
	end
end

function CharacterSelectNavBarMixin:SetButtonVisuals()
	local leftmostButton = self.GameEnvironmentButton;
	local rightmostButton = self.CampsButton;

	-- The leftmost and rightmost buttons in the nav bar have different textures than the default.
	leftmostButton.Highlight:ClearAllPoints();
	leftmostButton.Highlight:SetPoint("TOPLEFT", -45, 0);
	leftmostButton.Highlight:SetPoint("BOTTOMRIGHT", 0, 0);
	leftmostButton.Highlight.Backdrop:SetAtlas("glues-characterselect-tophud-selected-left", TextureKitConstants.IgnoreAtlasSize);
	leftmostButton.Highlight.Line:SetAtlas("glues-characterselect-tophud-selected-line-left", TextureKitConstants.IgnoreAtlasSize);
	leftmostButton.NormalTexture:SetAtlas("glues-characterselect-tophud-left-bg", TextureKitConstants.IgnoreAtlasSize);
	leftmostButton.NormalTexture:SetPoint("TOPLEFT", -102, 0);
	leftmostButton.DisabledTexture:SetAtlas("glues-characterselect-tophud-left-dis-bg", TextureKitConstants.IgnoreAtlasSize);
	leftmostButton.DisabledTexture:SetPoint("TOPLEFT", -102, 0);

	-- Do not show divider bar on rightmost option.
	rightmostButton.Bar:Hide();
	rightmostButton.Highlight:ClearAllPoints();
	rightmostButton.Highlight:SetPoint("TOPLEFT", 0, 0);
	rightmostButton.Highlight:SetPoint("BOTTOMRIGHT", 45, 0);
	rightmostButton.Highlight.Backdrop:SetAtlas("glues-characterselect-tophud-selected-right", TextureKitConstants.IgnoreAtlasSize);
	rightmostButton.Highlight.Line:SetAtlas("glues-characterselect-tophud-selected-line-right", TextureKitConstants.IgnoreAtlasSize);
	rightmostButton.NormalTexture:SetAtlas("glues-characterselect-tophud-right-bg", TextureKitConstants.IgnoreAtlasSize);
	rightmostButton.NormalTexture:SetPoint("BOTTOMRIGHT", 102, 0);
	rightmostButton.DisabledTexture:SetAtlas("glues-characterselect-tophud-right-dis-bg", TextureKitConstants.IgnoreAtlasSize);
	rightmostButton.DisabledTexture:SetPoint("BOTTOMRIGHT", 102, 0);

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

	local function FormatGameEnvironmentButtonText(self, enabled, highlight)
		local selectionDownArrow = "glues-characterSelect-icon-arrowDown";
		if not enabled then
			selectionDownArrow = "glues-characterSelect-icon-arrowDown-disabled";
		elseif highlight then
			selectionDownArrow = "glues-characterSelect-icon-arrowDown-hover";
		end

		self:SetText(WOWLABS_MODE_NAV_BUTTON .. (not self.SelectionDrawer:IsShown() and CreateAtlasMarkup(selectionDownArrow, 28, 28, 0, 1) or ""));
	end
	self.GameEnvironmentButton.formatButtonTextCallback = FormatGameEnvironmentButtonText;

	self:UpdateSelectedGameMode();
end

function CharacterSelectNavBarMixin:UpdateSelectedGameMode()
	-- Texture on the Modes button is dependent on the selected game mode
	local selectedEnvironment = self.GameEnvironmentButton.SelectionDrawer:GetSelectedGameEnvironment();
	
	local enabled = true;
	local highlight = false;
	self.GameEnvironmentButton:formatButtonTextCallback(enabled, highlight);
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
	elseif button == self.RealmsButton then
		isDividerBarEnabled = isDividerBarEnabled or self.CampsButton:IsEnabled();
	end

	button.Bar:SetAtlas(isDividerBarEnabled and "glues-characterselect-tophud-bg-divider" or "glues-characterselect-tophud-bg-divider-dis", TextureKitConstants.UseAtlasSize);
end

function CharacterSelectNavBarMixin:SetGameEnvironmentButtonEnabled(enabled)
	self.GameEnvironmentButton:SetEnabled(enabled);

	local highlight = false;
	self.GameEnvironmentButton:formatButtonTextCallback(enabled, highlight);

	self:UpdateButtonDividerState(self.StoreButton or self.PlunderstoreButton);

	-- When a new mode is available we want to make sure the player knows
	if enabled and self.tryForceShowModes then
		ToggleGameEnvironmentDrawer(self);
		self.tryForceShowModes = false;
		self.GameEnvironmentButton.TutorialBadge:Show();
	end
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

function CharacterSelectNavBarMixin:SetCampsButtonEnabled(enabled)
	self.CampsButton:SetEnabled(enabled);

	self:UpdateButtonDividerState(self.RealmsButton);
	self:UpdateButtonDividerState(self.CampsButton);
end

function CharacterSelectNavBarMixin:EvaluateHelptips()
	local campsHelpTipInfo = {
		text = CHARACTER_SELECT_NAV_BAR_CAMPS_HELPTIP,
		buttonStyle = HelpTip.ButtonStyle.Close,
		targetPoint = HelpTip.Point.BottomEdgeCenter,
		cvar = "seenCharacterSelectNavBarCampsHelpTip",
		cvarValue = "1",
		checkCVars = true
	};
	HelpTip:Show(self.CampsButton, campsHelpTipInfo);
end