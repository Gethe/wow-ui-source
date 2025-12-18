
G_GameMenuFrameContextKey = "GameMenuFrame";

GameMenuFrameMixin = {};

local GameMenuFrameEvents = {
	"STORE_STATUS_CHANGED",
	"TRIAL_STATUS_UPDATE",
};

function GameMenuFrameMixin:OnLoad()
	MainMenuFrameMixin.OnLoad(self);

	self:AddStaticEventMethod(EventRegistry, "UIPanel.FrameHidden", GameMenuFrameMixin.OnUIPanelHidden);
	self:AddStaticEventMethod(EventRegistry, "Store.FrameHidden", GameMenuFrameMixin.OnStoreFrameClosed);
end

function GameMenuFrameMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);

	FrameUtil.RegisterFrameForEvents(self, GameMenuFrameEvents);

	UpdateMicroButtons();

	if CanAutoSetGamePadCursorControl(true) then
		SetGamePadCursorControl(true);
	end

	self:InitButtons();
end

function GameMenuFrameMixin:OnHide()
	CallbackRegistrantMixin.OnHide(self);

	FrameUtil.UnregisterFrameForEvents(self, GameMenuFrameEvents);

	UpdateMicroButtons();

	if CanAutoSetGamePadCursorControl(false) then
		SetGamePadCursorControl(false);
	end
end

function GameMenuFrameMixin:OnEvent()
	self:InitButtons();
end

function GameMenuFrameMixin:OnStoreFrameClosed(contextKey)
	if contextKey == G_GameMenuFrameContextKey then
		ShowUIPanel(self);
	end
end

function GameMenuFrameMixin:OnUIPanelHidden(contextKey)
	if contextKey == G_GameMenuFrameContextKey then
		ShowUIPanel(self);
	end
end

function GameMenuFrameMixin:InitButtons()
	self:Reset();

	local function GenerateMenuCallback(callback, customSoundEffect)
		return function()
			PlaySound(customSoundEffect or SOUNDKIT.IG_MAINMENU_OPTION);
			HideUIPanel(self);
			callback();
		end;
	end

	self.NewExternalEventFrame:Hide();
	if C_ExternalEventURL.HasURL() then
		local isNew = C_ExternalEventURL.IsNew();
		local useGoldRedButton = true;
		local externalEventButton = self:AddButton(GAMEMENU_EXTERNALEVENT, GenerateMenuCallback(function() C_ExternalEventURL.LaunchURL() end), nil, nil, useGoldRedButton);
		if isNew then
			self.NewExternalEventFrame:SetPoint("BOTTOMRIGHT", externalEventButton:GetFontString(), "LEFT", 16, -10);
			self.NewExternalEventFrame:Show();
		end
		self:AddSection();
	end

	-- A few settings are disabled without a tooltip in Kiosk mode
	local isKioskDisabled = Kiosk.IsEnabled();

	local optionsButton = self:AddButton(GAMEMENU_OPTIONS, GenerateMenuCallback(GenerateFlatClosure(SettingsPanel.Open, SettingsPanel)));

	if CurrentVersionHasNewUnseenSettings() then
		self.NewOptionsFrame:SetPoint("BOTTOMRIGHT", optionsButton:GetFontString(), "LEFT", 16, -10);
		self.NewOptionsFrame:Show();
	else
		self.NewOptionsFrame:Hide();
	end

	local shop1Enabled = C_StorePublic.IsEnabled();
	local shop2Enabled = C_CatalogShop.IsShop2Enabled();
	local storeEnabled = shop1Enabled or shop2Enabled;

	if storeEnabled then
		local storeDisabled = isKioskDisabled;
		self:AddButton(BLIZZARD_STORE, GenerateMenuCallback(GenerateFlatClosure(ToggleStoreUI, G_GameMenuFrameContextKey)), storeDisabled, storeDisabledTooltip);
	end

	self:AddSection();

	-- Arguments for ShowUIPanel.
	local force = nil;
	local contextKey = G_GameMenuFrameContextKey;

	local storeFrontID = GameRulesUtil.GetActiveAccountStore();
	if storeFrontID then
		local function ShowRewards()
			C_AddOns.LoadAddOn("Blizzard_AccountStore");
			AccountStoreFrame:SetStoreFrontID(storeFrontID);
			self:CloseMenu();
			AccountStoreUtil.SetAccountStoreShown(true);
		end

		self:AddButton(GAME_MENU_SHOW_REWARDS, ShowRewards);
	end

	if GameRulesUtil.ShouldShowAddOns() then
		local addOnsDisabled = isKioskDisabled or C_AddOns.GetScriptsDisallowedForBeta();
		self:AddButton(ADDONS, GenerateMenuCallback(GenerateFlatClosure(ShowUIPanel, AddonList, force, contextKey)), addOnsDisabled);
	end

	if GameRulesUtil.ShouldShowSplashScreen() then
		self:AddButton(GAMEMENU_NEW_BUTTON, GenerateMenuCallback(GenerateFlatClosure(C_SplashScreen.RequestLatestSplashScreen, true)), isKioskDisabled);
	end

	if EditModeManagerFrame:CanEnterEditMode() then
		local editModeButton = self:AddButton(HUD_EDIT_MODE_MENU, GenerateMenuCallback(GenerateFlatClosure(ShowUIPanel, EditModeManagerFrame, force)));

		if EditModeManagerFrame.Tutorial:HasHelptipsToShow() then
			self.EditModeNotification:SetPoint("TOPLEFT", editModeButton, "TOPLEFT", -5, 5);
			self.EditModeNotification:Show();
		else
			self.EditModeNotification:Hide();
		end
	end

	if self:GetRatingsButtonShown() then
		-- RatingMenuFrame can only be opened from the game menu so it uses custom behavior to re-show the game menu after closing.
		self:AddButton(RATINGS_MENU, GenerateMenuCallback(GenerateFlatClosure(ShowUIPanel, RatingMenuFrame)));
	end

	self:AddButton(GAMEMENU_SUPPORT, GenerateMenuCallback(GenerateFlatClosure(ToggleHelpFrame, contextKey)), isKioskDisabled);

	if not C_GameRules.IsGameRuleActive(Enum.GameRule.MacrosDisabled) then
		self:AddButton(MACROS, GenerateMenuCallback(ShowMacroFrame), isKioskDisabled);
	end

	self:AddSection();

	local exitDisabled = isKioskDisabled or StaticPopup_Visible("CAMP") or StaticPopup_Visible("PLUNDERSTORM_LEAVE") or StaticPopup_Visible("QUIT");
	self:AddButton(GameMenuFrameMixin:GetLogoutText(), GenerateMenuCallback(Logout, SOUNDKIT.IG_MAINMENU_LOGOUT), exitDisabled);
	self:AddButton(EXIT_GAME, GenerateMenuCallback(Quit, SOUNDKIT.IG_MAINMENU_QUIT), exitDisabled);

	self:AddCloseButton(RETURN_TO_GAME);
end

function GameMenuFrameMixin:SetRatingsButtonShown(shown)
	self.ratingsButtonShown = shown;
end

function GameMenuFrameMixin:GetRatingsButtonShown()
	return self.ratingsButtonShown;
end

function GameMenuFrameMixin:GetLogoutText()
	-- Can be overridden.
	return LOG_OUT;
end

function MainMenuFrameMixin:CloseMenu()
	-- Overrides MainMenuFrameMixin.

	HideUIPanel(self);
end
