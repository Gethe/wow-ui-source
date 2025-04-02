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
	self:TrySetUpGameModeButton();
	self:TrySetUpStoreButton();
	self:TrySetUpMenuButton();
	self:TrySetUpRealmsButton();
	self:TrySetUpCampsButton();

	EventRegistry:RegisterCallback("GameModeFrame.Hide", self.OnGameModeFrameHide, self);
	EventRegistry:RegisterCallback("GameMode.UpdateNavBar", self.OnGameModeUpdateNavBar, self);
	
	self:SetButtonVisuals();
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

function CharacterSelectNavBarMixin:AddButton(label, controlCallback, ...)
	local control = self.ButtonTray:AddControl(label, controlCallback, ...);
	if not self.leftmostButton then
		self.leftmostButton = control;
	end
	self.rightmostButton = control;
	return control;
end

function CharacterSelectNavBarMixin:TrySetUpGameModeButton()
	if not self.gameModeButtonAvailable then
		return;
	end

	local passNavBarToCallback = true;
	self.GameModeButton = self:AddButton(nil, self.ToggleGameModeDrawer, passNavBarToCallback);
	self.GameModeButton.SelectionDrawer = CreateFrame("FRAME", nil, self.GameModeButton, "GameModeFrameTemplate");
	if self.gameModeDrawerAnchorsToButton then
		self.GameModeButton.SelectionDrawer:SetPoint("TOP", self.GameModeButton, "BOTTOM", 0, -20);
	else
		self.GameModeButton.SelectionDrawer:SetPoint("TOP", self, "BOTTOM", 0, -20);
	end

	self.GameModeButton.TutorialBadge:ClearAllPoints();
	self.GameModeButton.TutorialBadge:SetPoint("CENTER", self.GameModeButton:GetFontString(), "LEFT", -10, 0);

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

function CharacterSelectNavBarMixin:TrySetUpStoreButton()
	if not self.storeButtonAvailable then
		return;
	end

	if self:GetParent() == PlunderstormLobbyFrame then
		self:RegisterEvent("STORE_FRONT_STATE_UPDATED");

		self.PlunderstoreButton = self:AddButton(WOWLABS_PLUNDERSTORE_NAV_LABEL, ToggleAccountStoreUI);
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
		self.StoreButton = self:AddButton(nil, ToggleStoreUI);

		-- The store button has a custom icon that must match the text state.
		local function FormatStoreButtonText(self, enabled, highlight)
			local shopIcon = "glues-characterselect-iconshop";
			if not enabled then
				shopIcon = "glues-characterselect-iconshop-dis";
			elseif highlight then
				shopIcon = "glues-characterselect-iconshop-hover";
			end
			self:SetText(CreateAtlasMarkup(shopIcon, self.shopIconSize, self.shopIconSize, -4)..CHARACTER_SELECT_NAV_BAR_SHOP);
		end
		self.StoreButton.formatButtonTextCallback = FormatStoreButtonText;

		local enabled = true;
		local highlight = false;
		self.StoreButton:formatButtonTextCallback(enabled, highlight);
		self.StoreButton:SetWidth(self.StoreButton:GetTextWidth() + CharacterSelectNavBarMixin.NavBarButtonWidthBuffer);
	end
end

function CharacterSelectNavBarMixin:TrySetUpMenuButton()
	if not self.menuButtonAvailable then
		return;
	end

	self.MenuButton = self:AddButton(CHARACTER_SELECT_NAV_BAR_MENU, GlueMenuFrameUtil.ShowMenu);
end

function CharacterSelectNavBarMixin:TrySetUpRealmsButton()
	if not self.realmsButtonAvailable then
		return;
	end

	local realmsCallback = GenerateFlatClosure(CharacterSelectUtil.ChangeRealm);
	self.RealmsButton = self:AddButton(CHARACTER_SELECT_NAV_BAR_REALMS, realmsCallback);
end

function CharacterSelectNavBarMixin:TrySetUpCampsButton()
	if not self.campsButtonAvailable then
		return;
	end

	self.CampsButton = self:AddButton(CHARACTER_SELECT_NAV_BAR_CAMPS, ToggleCollections);
	local function OnCollectionsHide()
		UpdateButtonStatesForCollections(false);
	end
	EventRegistry:RegisterCallback("GlueCollections.OnHide", OnCollectionsHide);
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
	-- The leftmost and rightmost buttons in the nav bar have different textures than the default.
	self.leftmostButton.Highlight:ClearAllPoints();
	self.leftmostButton.Highlight:SetPoint("TOPLEFT", -45, 0);
	self.leftmostButton.Highlight:SetPoint("BOTTOMRIGHT", 0, 0);
	self.leftmostButton.Highlight.Backdrop:SetAtlas("glues-characterselect-tophud-selected-left", TextureKitConstants.IgnoreAtlasSize);
	self.leftmostButton.Highlight.Line:SetAtlas("glues-characterselect-tophud-selected-line-left", TextureKitConstants.IgnoreAtlasSize);
	self.leftmostButton.NormalTexture:SetAtlas("glues-characterselect-tophud-left-bg", TextureKitConstants.IgnoreAtlasSize);
	self.leftmostButton.NormalTexture:SetPoint("TOPLEFT", -102, 0);
	self.leftmostButton.DisabledTexture:SetAtlas("glues-characterselect-tophud-left-dis-bg", TextureKitConstants.IgnoreAtlasSize);
	self.leftmostButton.DisabledTexture:SetPoint("TOPLEFT", -102, 0);

	-- Do not show divider bar on rightmost option.
	self.rightmostButton.Bar:Hide();
	self.rightmostButton.Highlight:ClearAllPoints();
	self.rightmostButton.Highlight:SetPoint("TOPLEFT", 0, 0);
	self.rightmostButton.Highlight:SetPoint("BOTTOMRIGHT", 45, 0);
	self.rightmostButton.Highlight.Backdrop:SetAtlas("glues-characterselect-tophud-selected-right", TextureKitConstants.IgnoreAtlasSize);
	self.rightmostButton.Highlight.Line:SetAtlas("glues-characterselect-tophud-selected-line-right", TextureKitConstants.IgnoreAtlasSize);
	self.rightmostButton.NormalTexture:SetAtlas("glues-characterselect-tophud-right-bg", TextureKitConstants.IgnoreAtlasSize);
	self.rightmostButton.NormalTexture:SetPoint("BOTTOMRIGHT", 102, 0);
	self.rightmostButton.DisabledTexture:SetAtlas("glues-characterselect-tophud-right-dis-bg", TextureKitConstants.IgnoreAtlasSize);
	self.rightmostButton.DisabledTexture:SetPoint("BOTTOMRIGHT", 102, 0);
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

	C_StoreSecure.GetPurchaseList();
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