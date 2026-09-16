
G_GameMenuFrameContextKey = "GameMenuFrame";

GameMenuFrameMixin = {};

StaticPopupDialogs["GAMEMENU_EXTERNALEVENT_FAILURE"] = {
	text = GAMEMENU_EXTERNALEVENT_FAILURE,
	button1 = OKAY,
	button2 = nil,
	timeout = 0,
	OnAccept = function(dialog, data)
	end,
	OnHyperlinkClick = function(dialog, data)
		LoadURLIndex(67);
	end,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1,
};

function GameMenuFrame_IsShown()
	return GameMenuFrame and GameMenuFrame:IsShown();
end

function GameMenuFrame_EscapePressed()
	if not GameMenuFrame_IsShown() then
		return false;
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_QUIT);
	HideUIPanel(GameMenuFrame);
	return true;
end

RegisterGameMenuEscHandler(GameMenuEscPriority.Framework, GameMenuFrame_EscapePressed);

function GameMenuFrame_Show()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
	ShowUIPanel(GameMenuFrame);
end

local GameMenuFrameEvents = {
	"STORE_STATUS_CHANGED",
	"TRIAL_STATUS_UPDATE",
};

function GameMenuFrameMixin:OnLoad()
	MainMenuFrameMixin.OnLoad(self);

	self.buttons = {};

	self:AddStaticEventMethod(EventRegistry, "UIPanel.FrameHidden", GameMenuFrameMixin.OnUIPanelHidden);
	self:AddStaticEventMethod(EventRegistry, "Store.FrameHidden", GameMenuFrameMixin.OnStoreFrameClosed);
	-- This event can occur without the frame being shown.
	EventRegistry:RegisterFrameEventAndCallback("EXTERNAL_EVENT_LAUNCH_URL_FAILED", GameMenuFrameMixin.OnExternalEventLaunchUrlFailed, self);

	self:RegisterForTransitions();
end

function GameMenuFrameMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);

	FrameUtil.RegisterFrameForEvents(self, GameMenuFrameEvents);

	UpdateMicroButtons();

	if CanAutoSetGamePadCursorControl(true) then
		SetGamePadCursorControl(true);
	end

	self:InitButtons();
	LayoutMixin.OnShow(self);

	NarrationUtil.NarrateCurrentScreen(NARRATION_CONTEXT_GAME_MENU);

	if InputUtil.IsGamepadUIEnabled() then
		self.gamepadFooter:ShowAndActivateBindings();
	end

	EventRegistry:TriggerEvent("GameMenuFrame.Shown");
end

function GameMenuFrameMixin:OnHide()
	CallbackRegistrantMixin.OnHide(self);

	FrameUtil.UnregisterFrameForEvents(self, GameMenuFrameEvents);

	UpdateMicroButtons();

	if InputUtil.IsGamepadUIEnabled() then
		self:ResetGamepadButtons();
		self.gamepadFooter:HideAndDeactivateBindings();
	end

	if CanAutoSetGamePadCursorControl(false) then
		SetGamePadCursorControl(false);
	end
end

function GameMenuFrameMixin:OnEvent()
	if InputUtil.IsGamepadUIEnabled() then
		self:ResetGamepadButtons();
	end

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

function GameMenuFrameMixin:ExternalEventClickCallback()
	if C_ExternalEventURL.HasURL() then
		C_ExternalEventURL.LaunchURL();
	end
end

function GameMenuFrameMixin:OnExternalEventLaunchUrlFailed()
	StaticPopup_Show("GAMEMENU_EXTERNALEVENT_FAILURE");
end

function GameMenuFrameMixin:SetupGamepadButtons()
	if not InputUtil.IsGamepadUIEnabled() then
		return;
	end

	if #self.buttons <= 1 then
		return;
	end

	SmartNavigation_AddBidirectionalJumpNavigationOverride(self.buttons[1], SMART_NAV_INPUT_DIRECTION.UP,
														   self.buttons[#self.buttons], SMART_NAV_INPUT_DIRECTION.DOWN);
end

function GameMenuFrameMixin:ResetGamepadButtons()
	for _,v in ipairs(self.buttons) do
		SmartNavigation_ClearJumpNavigationOverrides(v);
	end
end

function GameMenuFrameMixin:AddButton(...)
	local button = MainMenuFrameMixin.AddButton(self, ...);
	table.insert(self.buttons, button);
	return button;
end

function GameMenuFrameMixin:AddCloseButton(...)
	if InputUtil.IsGamepadUIEnabled() then
		return nil;
	end
	return MainMenuFrameMixin.AddCloseButton(self, ...);
end

function GameMenuFrameMixin:InitButtons()
	self.buttons = {};
	self.closeButton = nil;

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
		local externalEventButton = self:AddButton(GAMEMENU_EXTERNALEVENT, GenerateMenuCallback(function() self:ExternalEventClickCallback() end), nil, nil, useGoldRedButton);
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
		self:AddButton(MACROS, GenerateMenuCallback(function()
			if DISALLOW_FRAME_TOGGLING or Kiosk.IsEnabled() then
				return;
			end

			ShowMacroFrame();
		end), isKioskDisabled);
	end

	self:AddSection();

	local exitDisabled = isKioskDisabled or StaticPopup_Visible("CAMP") or StaticPopup_Visible("PLUNDERSTORM_LEAVE") or StaticPopup_Visible("QUIT");
	self:AddButton(GameMenuFrameMixin:GetLogoutText(), GenerateMenuCallback(Logout, SOUNDKIT.IG_MAINMENU_LOGOUT), exitDisabled);
	self:AddButton(EXIT_GAME, GenerateMenuCallback(Quit, SOUNDKIT.IG_MAINMENU_QUIT), exitDisabled);

	self.closeButton = self:AddCloseButton(RETURN_TO_GAME);

	self:SetupGamepadButtons();
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

function GameMenuFrameMixin:CloseMenu()
	-- Overrides MainMenuFrameMixin.

	PlaySound(SOUNDKIT.IG_MAINMENU_CONTINUE);
	HideUIPanel(self);
end

function GameMenuFrameMixin:SmartNavigationCloseHandler()
	self:CloseMenu();
	return true;
end

function GameMenuFrameMixin:RegisterForTransitions()
	InputUtil.RegisterForInterfaceTransitions(self);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetupGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));
end

function GameMenuFrameMixin:SetupGamepad()
	local selectPromptedBinding = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_BOTTOM, nil, ACTION_LABEL_SELECT);

	self.gamepadFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, "GlueMenuFooter");
	self.gamepadFooter:AddPromptedBinding(selectPromptedBinding);
	self.gamepadFooter:AddStandardBackPrompt(RETURN_TO_GAME);
	self.gamepadFooter:SetAnchorOffsets(6, 0);

	self.gamepadFooter:Finalize();
end

function GameMenuFrameMixin:UninitializeGamepad()
	self:ResetGamepadButtons();
end
