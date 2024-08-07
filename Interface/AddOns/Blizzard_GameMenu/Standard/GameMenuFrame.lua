
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

	-- A few settings are disabled without a tooltip in Kiosk mode.
	local isKioskDisabled = Kiosk.IsEnabled();

	self:AddButton(GAMEMENU_OPTIONS, GenerateMenuCallback(GenerateFlatClosure(SettingsPanel.Open, SettingsPanel)));

	if C_StorePublic.IsEnabled() then
		local disabledByParentalControls = C_StorePublic.IsDisabledByParentalControls();
		local storeDisabledTooltip = disabledByParentalControls and BLIZZARD_STORE_ERROR_PARENTAL_CONTROLS or nil;
		local storeDisabled = isKioskDisabled or disabledByParentalControls;
		self:AddButton(BLIZZARD_STORE, GenerateMenuCallback(GenerateFlatClosure(ToggleStoreUI, G_GameMenuFrameContextKey)), storeDisabled, storeDisabledTooltip);
	end

	self:AddSection();

	-- Arguments for ShowUIPanel.
	local force = nil;
	local contextKey = G_GameMenuFrameContextKey;

	if C_AddOns.GetNumAddOns() > 0 then
		local addOnsDisabled = isKioskDisabled or C_AddOns.GetScriptsDisallowedForBeta();
		self:AddButton(ADDONS, GenerateMenuCallback(GenerateFlatClosure(ShowUIPanel, AddonList, force, contextKey)), addOnsDisabled);
	end

	if C_SplashScreen.CanViewSplashScreen() and not IsCharacterNewlyBoosted() then
		self:AddButton(GAMEMENU_NEW_BUTTON, GenerateMenuCallback(GenerateFlatClosure(C_SplashScreen.RequestLatestSplashScreen, true)), isKioskDisabled);
	end

	local editModeDisabled = not EditModeManagerFrame:CanEnterEditMode();
	self:AddButton(HUD_EDIT_MODE_MENU, GenerateMenuCallback(GenerateFlatClosure(ShowUIPanel, EditModeManagerFrame, force)), editModeDisabled);

	if self:GetRatingsButtonShown() then
		-- RatingMenuFrame can only be opened from the game menu so it uses custom behavior to re-show the game menu after closing.
		self:AddButton(RATINGS_MENU, GenerateMenuCallback(GenerateFlatClosure(ShowUIPanel, RatingMenuFrame)));
	end

	self:AddButton(GAMEMENU_SUPPORT, GenerateMenuCallback(GenerateFlatClosure(ToggleHelpFrame, contextKey)), isKioskDisabled);

	self:AddButton(MACROS, GenerateMenuCallback(ShowMacroFrame));

	self:AddSection();

	local exitDisabled = isKioskDisabled or StaticPopup_Visible("CAMP") or StaticPopup_Visible("QUIT");
	self:AddButton(LOG_OUT, GenerateMenuCallback(Logout, SOUNDKIT.IG_MAINMENU_LOGOUT), exitDisabled);
	self:AddButton(EXIT_GAME, GenerateMenuCallback(Quit, SOUNDKIT.IG_MAINMENU_QUIT), exitDisabled);

	self:AddCloseButton(RETURN_TO_GAME);
end

function GameMenuFrameMixin:SetRatingsButtonShown(shown)
	self.ratingsButtonShown = shown;
end

function GameMenuFrameMixin:GetRatingsButtonShown()
	return self.ratingsButtonShown;
end

function MainMenuFrameMixin:CloseMenu()
	-- Overrides MainMenuFrameMixin.

	HideUIPanel(self);
end
