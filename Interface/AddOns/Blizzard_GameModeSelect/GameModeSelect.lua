---------------------------------------------------
-- GLOBAL CONSTANTS
g_newGameModeAvailableAcknowledged = g_newGameModeAvailableAcknowledged or nil;

---------------------------------------------------
-- LOCAL CONSTANTS
local GameModeSelectButtonSize = {
	width = 2 * GameModeSelectFixedHeight,
	height = GameModeSelectFixedHeight
};

---------------------------------------------------
-- GAME MODE BUTTON MIXIN
GameModeButtonMixin = {};

function GameModeButtonMixin:OnLoad()
	SelectableButtonMixin.OnLoad(self);

	self:InitSize();
end

function GameModeButtonMixin:OnShow()
	self:SetAlpha(self:IsSelected() and 1 or 0.5);

	if self.usingExpansionLogo then
		self:RefreshStandardLogo();
	end
end

function GameModeButtonMixin:OnEnter()
	if self.disabled then
		GlueTooltip:SetOwner(self, "ANCHOR_BOTTOM");
		GameTooltip_SetTitle(GlueTooltip, GAME_MODE_DISABLED_TOOLTIP);
		GlueTooltip:Show();
	end

	if not self:IsSelected() and not self.disabled then
		self:SetAlpha(1.0);
	end
end

function GameModeButtonMixin:OnLeave()
	GlueTooltip:Hide();

	if not self:IsSelected() then
		self:SetAlpha(0.5);
	end
end

function GameModeButtonMixin:SetDisabled(disabled)
	self.NormalTexture:SetDesaturated(disabled);
	self.disabled = disabled;
end

function GameModeButtonMixin:SetSelectedState(selected)
	if self.disabled then
		return;
	end

	SelectableButtonMixin.SetSelectedState(self, selected);
	self.SelectionArrow:SetShown(selected);
	self.BackgroundGlowTop:SetShown(selected);
	self.BackgroundGlowBottom:SetShown(selected);

	self:RefreshScale();

	self:SetAlpha(selected and 1 or 0.5);
end

function GameModeButtonMixin:InitSize()
	self:SetSize(GameModeSelectButtonSize.width, GameModeSelectFixedHeight);
	self.NormalTexture:SetSize(GameModeSelectButtonSize.width, GameModeSelectButtonSize.height);
end

function GameModeButtonMixin:SetGameMode(gameModeRecordID)
	self.gameModeRecordID = gameModeRecordID;
	local gameModeDisplayInfo = C_GameRules.GetGameModeDisplayInfoByRecordID(self.gameModeRecordID);
	if gameModeDisplayInfo and gameModeDisplayInfo.logo then
		self.NormalTexture:SetTexture(gameModeDisplayInfo.logo);
	else
		self:RefreshStandardLogo();
		self.usingExpansionLogo = true;
	end
end

function GameModeButtonMixin:RefreshStandardLogo()
	local currentExpansionLevel = AccountUpgradePanel_GetBannerInfo();
	if currentExpansionLevel and self.shownExpansionLevel ~= currentExpansionLevel then
		SetExpansionLogo(self.NormalTexture, currentExpansionLevel);
		self.shownExpansionLevel = currentExpansionLevel;
	end
end

function GameModeButtonMixin:RefreshScale()
	local selected = self:IsSelected();
	local textureScale = selected and GameModeSelectNormalTextureScale.selected or GameModeSelectNormalTextureScale.deselected;
	self.NormalTexture:SetScale(textureScale);
end

---------------------------------------------------
-- GAME MODE BUTTON PROMO MIXIN
GameModeButtonPromoMixin = CreateFromMixins(GameModeButtonMixin);

function GameModeButtonPromoMixin:OnLoad()
	GameModeButtonMixin.OnLoad(self);
end

function GameModeButtonPromoMixin:OnShow()
	GameModeButtonMixin.OnShow(self);

	self:SetPulsePlaying(true);

	local promoGlobalString = C_GameRules.GetGameModePromoGlobalString(self.gameModeRecordID);
	local promoString = _G[promoGlobalString];
	self.PromoText.BGLabel:SetText(promoString);
	self.PromoText.Label:SetText(promoString);
end

function GameModeButtonPromoMixin:OnEnter()
	GameModeButtonMixin.OnEnter(self);

	self:SetPulsePlaying(false);
end

function GameModeButtonPromoMixin:OnLeave()
	GameModeButtonMixin.OnLeave(self);

	self:SetPulsePlaying(true);
end

function GameModeButtonPromoMixin:OnSelected(newSelected)
	self:SetPulsePlaying(not newSelected);
end

function GameModeButtonPromoMixin:InitSize()
	self:SetSize(GameModeSelectButtonSize.width, GameModeSelectButtonSize.height);

	-- Shrink the game logo for promo buttons to accommodate promo text.
	local textureSize = {
		width = GameModeSelectButtonSize.width * GameModeSelectPromoButtonTextureScale,
		height = GameModeSelectButtonSize.height * GameModeSelectPromoButtonTextureScale,
	};

	-- Not using SetScale because scale is used for growing/shrinking the texture on selection/deselection.
	-- This is just setting the base size that scaling will modify. Promo buttons' default size is scaled to
	-- accommodate the promo text, but it's handled as size to not conflict with the other scaling.
	self.NormalTexture:SetSize(textureSize.width, textureSize.height);

	-- Shift the shrunken game mode logo up to accommodate the promo text being under the logo.
	local heightLoss = GameModeSelectButtonSize.height - textureSize.height;
	local normalTextureVerticalOffset = 0.5 * heightLoss;
	self.NormalTexture:SetPoint("CENTER", 0, normalTextureVerticalOffset);
end

function GameModeButtonPromoMixin:SetGameMode(gameModeRecordID)
	GameModeButtonMixin.SetGameMode(self, gameModeRecordID);

	self.PulseTexture:SetTexture(self.NormalTexture:GetTexture());
	self.PulseTexture:SetSize(self.NormalTexture:GetSize());

	self.PulseTextureTwo:SetTexture(self.NormalTexture:GetTexture());
	self.PulseTextureTwo:SetSize(self.NormalTexture:GetSize());

	self:SetPulsePlaying(true);
end

function GameModeButtonPromoMixin:RefreshScale()
	GameModeButtonMixin.RefreshScale(self);

	local textureScale = self.NormalTexture:GetScale();
	self.PulseTexture:SetScale(textureScale);
	self.PulseTextureTwo:SetScale(textureScale);

	local selected = self:IsSelected();
	local textScale = selected and GameModeSelectPromoTextScale.selected or GameModeSelectPromoTextScale.deselected;
	self.PromoText:SetScale(textScale);
end

function GameModeButtonPromoMixin:SetPulsePlaying(playing)
	playing = playing and not self:IsSelected();
	if self.pulsePlaying == playing then
		return;
	end

	self:RefreshScale();

	if not playing then
		self.PulseTexture:Hide();
		self.PulseTextureTwo:Hide();
		self.PulseAnim:Stop();
	else
		self.PulseTexture:Show();
		self.PulseTextureTwo:Show();
		self.PulseAnim:Play();
	end

	self.pulsePlaying = playing;
end

---------------------------------------------------
-- GAME MODE FRAME MIXIN
GameModeFrameMixin = {};

function GameModeFrameMixin:SetDisabledForMode(gameModeRecordID, disabled)
	for i, button in ipairs(self.buttonGroup:GetButtons()) do
		if button.gameModeRecordID == gameModeRecordID then
			button:SetDisabled(disabled);
			break;
		end
	end
end

function GameModeFrameMixin:OnLoad()
	self.buttonGroup = CreateRadioButtonGroup();
	self.buttonGroup:RegisterCallback(ButtonGroupBaseMixin.Event.Selected, self.SelectGameMode, self);

	self.gameModeButtonTemplates = { "GameModeButtonTemplate", "GameModePromoButtonTemplate" };
	self.gameModeButtonPools = CreateFramePoolCollection();
	for index, templateType in ipairs(self.gameModeButtonTemplates) do
		self.gameModeButtonPools:CreatePool("Button", self, templateType);
	end

	self:RegisterEvent("AVAILABLE_GAME_MODES_UPDATED");
	self:RegisterEvent("GAME_MODE_DISPLAY_INFO_UPDATED");
	self:RegisterEvent("GAME_MODE_DISPLAY_MODE_TOGGLE_DISABLED");

	self:AddDynamicEventMethod(EventRegistry, "GameMode.Selected", self.OnGameModeSelected);
	self:AddDynamicEventMethod(EventRegistry, "RealmList.Cancel", self.OnRealmListCancel);	

	self:OnAvailableGameModesUpdated();
end

function GameModeFrameMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);	
	ResizeLayoutMixin.OnShow(self);

	self:SelectRadioButtonForGameMode(C_GameRules.GetCurrentGameModeRecordID());
	self:TryShowGameModeButtons();
end

function GameModeFrameMixin:OnHide()
	CallbackRegistrantMixin.OnHide(self);
end

function GameModeFrameMixin:OnKeyDown(key)
	if key == "ESCAPE" and self:IsShown() then
		EventRegistry:TriggerEvent("GameModeFrame.Hide");
	end
end

function GameModeFrameMixin:OnEvent(event, ...)
	if event == "AVAILABLE_GAME_MODES_UPDATED" then
		self:OnAvailableGameModesUpdated();
	elseif event == "GAME_MODE_DISPLAY_INFO_UPDATED" then
		-- When switching to a different game mode, hide the frame if connection succeeded.
		if self:IsShown() then
			EventRegistry:TriggerEvent("GameModeFrame.Hide");
		end
	elseif event == "GAME_MODE_DISPLAY_MODE_TOGGLE_DISABLED" then
		local gameModeRecordID, disabled = ...;
		self:SetDisabledForMode(gameModeRecordID, disabled);
	end
end

function GameModeFrameMixin:OnAvailableGameModesUpdated()
	-- Clear out any existing buttons and then repopulate based on latest list of available modes.
	self.buttonGroup:RemoveAllButtons();
	self.gameModeButtonPools:ReleaseAll();

	local numDisplayedGameModes = C_GameRules.GetNumDisplayedGameModes();
	for i = 1, numDisplayedGameModes do
		local gameModeRecordID = C_GameRules.GetDisplayedGameModeRecordIDAtIndex(i);
		local hasPromo = C_GameRules.DoesGameModeHavePromo(gameModeRecordID);
		local isDisabled = not C_GameRules.IsGameModeEnabled(gameModeRecordID);
		local gameModeButton = nil;
		if hasPromo then
			gameModeButton = self.gameModeButtonPools:Acquire("GameModePromoButtonTemplate");
		else
			gameModeButton = self.gameModeButtonPools:Acquire("GameModeButtonTemplate");
		end

		gameModeButton:SetGameMode(gameModeRecordID);

		if isDisabled then
			gameModeButton:SetDisabled(true);
		end

		if i == 1 then
			gameModeButton:SetPoint("TOPLEFT");
		else
			local relativeButton = self.buttonGroup:GetAtIndex(i - 1);
			gameModeButton:SetPoint("LEFT", relativeButton, "RIGHT", GameModeSelectButtonSpacing, 0);
		end

		self.buttonGroup:AddButton(gameModeButton);
	end

	self:TryShowGameModeButtons();
end

function GameModeFrameMixin:OnGameModeSelected(requestedGameModeRecordID)
	assert(requestedGameModeRecordID);

	if not C_GameRules.IsGameModeEnabled(requestedGameModeRecordID) then
		return
	end

	if C_GameRules.GetCurrentGameModeRecordID() ~= requestedGameModeRecordID then
		if C_GameRules.DoesGameModeHavePromo(requestedGameModeRecordID) then
			g_newGameModeAvailableAcknowledged = 1;
		end

		self:ChangeGameMode(requestedGameModeRecordID);
	end
end

function GameModeFrameMixin:OnRealmListCancel()
	self:SelectRadioButtonForGameMode(C_GameRules.GetCurrentGameModeRecordID());
end

function GameModeFrameMixin:TryShowGameModeButtons()
	self.shouldShowButtons = (C_GameRules.GetNumDisplayedGameModes() > 1);

	self.buttonGroup:SetShown(self.shouldShowButtons);
	self.NoGameModesText:SetShown(not self.shouldShowButtons);
	self.widthPadding = not self.shouldShowButtons and 20 or 0;
	self.fixedHeight = GameModeSelectFixedHeight;
	self:Layout();
end

function GameModeFrameMixin:ChangeGameMode(newGameModeRecordID)
	assert(newGameModeRecordID);

	if C_GameRules.GetCurrentGameModeRecordID() == newGameModeRecordID then
		return;
	end

	if not C_GameRules.IsCharacterlessLoginActive() then
		CharacterSelectListUtil.SaveCharacterOrder();
	end

	C_GameRules.AutoConnectToGameModeRealm(newGameModeRecordID);
end

function GameModeFrameMixin:SelectRadioButtonForGameMode(requestedGameModeRecordID)
	for i, button in ipairs(self.buttonGroup:GetButtons()) do
		button:SetSelectedState(requestedGameModeRecordID == button.gameModeRecordID);
		if button.SetPulsePlaying then
			button:SetPulsePlaying(requestedGameModeRecordID ~= button.gameModeRecordID);
		end
	end

	EventRegistry:TriggerEvent("GameMode.UpdateNavBar");
end

function GameModeFrameMixin:SelectGameMode(button, _buttonIndex)
	local requestedGameModeRecordID = button.gameModeRecordID;
	assert(requestedGameModeRecordID);

	EventRegistry:TriggerEvent("GameMode.Selected", requestedGameModeRecordID);
end
