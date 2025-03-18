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
	"ACCOUNT_CVARS_LOADED",
	"EVENT_REALM_QUEUES_UPDATED",
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
	self.GameModeButton = self.ButtonTray:AddControl(nil, self.ToggleGameModeDrawer, passNavBarToCallback);
	self.GameModeButton.SelectionDrawer = CreateFrame("FRAME", nil, self.GameModeButton, "GameModeFrameTemplate");
	self.GameModeButton.SelectionDrawer:SetPoint("TOP", self.GameModeButton, "BOTTOM", 0, -20);

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
		local function ToggleStoreUIForCharSelectNavBar()
			ToggleStoreUI("CharSelectNavBar");
		end
		self.StoreButton = self.ButtonTray:AddControl(nil, ToggleStoreUIForCharSelectNavBar);
	end

	self.MenuButton = self.ButtonTray:AddControl(CHARACTER_SELECT_NAV_BAR_MENU, GlueMenuFrameUtil.ShowMenu);
	self.RealmsButton = self.ButtonTray:AddControl(CHARACTER_SELECT_NAV_BAR_REALMS, realmsCallback);
	self.CampsButton = self.ButtonTray:AddControl(CHARACTER_SELECT_NAV_BAR_CAMPS, ToggleCollections);

	EventRegistry:RegisterCallback("GameModeFrame.Hide", self.OnGameModeFrameHide, self);
	EventRegistry:RegisterCallback("GameMode.UpdateNavBar", self.OnGameModeUpdateNavBar, self);

	local function OnCollectionsHide()
		UpdateButtonStatesForCollections(false);
	end
	EventRegistry:RegisterCallback("GlueCollections.OnHide", OnCollectionsHide);

	-- Any specific button setups.
	self:SetButtonVisuals();

	self.GameModeButton.TutorialBadge:ClearAllPoints();
	self.GameModeButton.TutorialBadge:SetPoint("CENTER", self.GameModeButton:GetFontString(), "LEFT", -10, 0);
end

function CharacterSelectNavBarMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);

	self.GameModeButton.TutorialBadge:Hide();
	self.tryForceShowModes = not g_newGameModeAvailableAcknowledged and C_GameRules.GetCurrentEventRealmQueues() ~= Enum.EventRealmQueues.None;
end

function CharacterSelectNavBarMixin:OnEvent(event, ...)
	if event == "GLOBAL_MOUSE_DOWN" then
		if self.GameModeButton.SelectionDrawer:IsShown() and 
			not self.GameModeButton:IsMouseOver() and
			not self.GameModeButton.SelectionDrawer:IsMouseOver() then
			self:ToggleGameModeDrawer();
		end
	elseif event == "ACCOUNT_CVARS_LOADED" then
		self:EvaluateHelptips();
	elseif event == "STORE_FRONT_STATE_UPDATED" then
		if self.PlunderstoreButton then
			self.PlunderstoreButton:SetEnabled(C_AccountStore.GetStoreFrontState(Constants.AccountStoreConsts.PlunderstormStoreFrontID) == Enum.AccountStoreState.Available);
		end
	elseif event == "EVENT_REALM_QUEUES_UPDATED" then
		local eventRealmQueues = ...;
		self.GameModeButton.TutorialBadge:Hide();
		self.tryForceShowModes = not g_newGameModeAvailableAcknowledged and eventRealmQueues ~= Enum.EventRealmQueues.None;

		self:UpdateGameModeSelectionTutorial();
	end
end

function CharacterSelectNavBarMixin:OnGameModeFrameHide()
	self:ToggleGameModeDrawer();
end

function CharacterSelectNavBarMixin:OnGameModeUpdateNavBar()
	self:UpdateSelectedGameMode();
end

function CharacterSelectNavBarMixin:ToggleGameModeDrawer()
	local selectionDrawer = self.GameModeButton.SelectionDrawer;
	selectionDrawer:SetShown(not selectionDrawer:IsShown());

	local enabled = true;
	local highlight = selectionDrawer:IsShown();
	self.GameModeButton:formatButtonTextCallback(enabled, highlight);
	self.GameModeButton:SetLockHighlight(highlight);

end

function CharacterSelectNavBarMixin:SetButtonVisuals()
	local leftmostButton = self.GameModeButton;
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

	local function FormatGameModeButtonText(gameModeButtonSelf, enabled, highlight)
		local selectionDownArrow = "glues-characterSelect-icon-arrowDown";
		if not enabled then
			selectionDownArrow = "glues-characterSelect-icon-arrowDown-disabled";
		elseif highlight then
			selectionDownArrow = "glues-characterSelect-icon-arrowDown-hover";
		end

		gameModeButtonSelf:SetText(WOWLABS_MODE_NAV_BUTTON .. (not gameModeButtonSelf.SelectionDrawer:IsShown() and CreateAtlasMarkup(selectionDownArrow, 28, 28, 0, 1) or ""));
	end
	self.GameModeButton.formatButtonTextCallback = FormatGameModeButtonText;

	self:UpdateSelectedGameMode();
end

function CharacterSelectNavBarMixin:UpdateSelectedGameMode()
	local enabled = true;
	local highlight = false;
	self.GameModeButton:formatButtonTextCallback(enabled, highlight);
	self.GameModeButton:SetWidth(self.GameModeButton:GetTextWidth() + CharacterSelectNavBarMixin.NavBarButtonWidthBuffer);

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

function CharacterSelectNavBarMixin:UpdateGameModeSelectionTutorial()
	-- When a new mode is available we want to make sure the player knows
	if self.GameModeButton:IsEnabled() and self.tryForceShowModes then
		if not self.GameModeButton.SelectionDrawer:IsShown() then
			self:ToggleGameModeDrawer();
		end

		self.tryForceShowModes = false;
		self.GameModeButton.TutorialBadge:Show();
	end
end

function CharacterSelectNavBarMixin:SetGameModeButtonEnabled(enabled)
	self.GameModeButton:SetEnabled(enabled);

	local highlight = false;
	self.GameModeButton:formatButtonTextCallback(enabled, highlight);

	self:UpdateButtonDividerState(self.StoreButton or self.PlunderstoreButton);

	self:UpdateGameModeSelectionTutorial();
end

function CharacterSelectNavBarMixin:SetStoreButtonEnabled(enabled)
	if not self.StoreButton then
		return;
	end

	self.StoreButton:SetEnabled(enabled);

	local highlight = false;
	self.StoreButton:formatButtonTextCallback(enabled, highlight);

	self:UpdateButtonDividerState(self.GameModeButton);
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