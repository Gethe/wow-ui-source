---------------------------------------------------
-- GLOBAL CONSTANTS
g_newGameModeAvailableAcknowledged = g_newGameModeAvailableAcknowledged or nil;

---------------------------------------------------
-- GAME MODE BUTTON MIXIN
GameModeButtonMixin = {};

function GameModeButtonMixin:OnLoad()
	SelectableButtonMixin.OnLoad(self);
	self.deselectedScale = self.selectedScale - 0.09;

	-- Because of the CharacterSelect animations, we need to set the initial alpha of the WoW Toggle to 1.
	self:SetAlpha(self.initAlpha);
end

function GameModeButtonMixin:OnShow()
	self:SetAlpha(self:IsSelected() and 1 or 0.5);
end

function GameModeButtonMixin:OnEnter()
	if not self:IsSelected() then
		self:SetAlpha(1.0);
	end
end

function GameModeButtonMixin:OnLeave()
	if not self:IsSelected() then
		self:SetAlpha(0.5);
	end
end

local LimitedTimeEventTextScale = {
	selected = 0.95,
	deselected = 0.85,
};

function GameModeButtonMixin:SetSelectedState(selected)
	SelectableButtonMixin.SetSelectedState(self, selected);
	self.SelectionArrow:SetShown(selected);
	self.BackgroundGlowTop:SetShown(selected);
	self.BackgroundGlowBottom:SetShown(selected);

	self.NormalTexture:SetScale(selected and self.selectedScale or self.deselectedScale);

	if self.LimitedTimeEventText then
		self.LimitedTimeEventText:SetScale(selected and LimitedTimeEventTextScale.selected or LimitedTimeEventTextScale.deselected);
	end

	self:SetAlpha(selected and 1 or 0.5);
end

---------------------------------------------------
-- GAME MODE BUTTON PULSING MIXIN
GameModeButtonPulsingMixin = CreateFromMixins(GameModeButtonMixin);

function GameModeButtonPulsingMixin:OnLoad()
	GameModeButtonMixin.OnLoad(self);

	self.PulseTexture:SetTexture(self.NormalTexture:GetTexture());
	self.PulseTexture:SetSize(self.NormalTexture:GetSize());

	self.PulseTextureTwo:SetTexture(self.NormalTexture:GetTexture());
	self.PulseTextureTwo:SetSize(self.NormalTexture:GetSize());

	self:SetPulsePlaying(true);
end

function GameModeButtonPulsingMixin:RefreshScale()
	local selected = self:IsSelected();
	self.PulseTexture:SetScale(selected and self.selectedScale or self.deselectedScale);
	self.PulseTextureTwo:SetScale(selected and self.selectedScale or self.deselectedScale);
end

function GameModeButtonPulsingMixin:OnShow()
	GameModeButtonMixin.OnShow(self);

	self:SetPulsePlaying(true);
end

function GameModeButtonPulsingMixin:OnEnter()
	GameModeButtonMixin.OnEnter(self);

	self:SetPulsePlaying(false);
end

function GameModeButtonPulsingMixin:OnLeave()
	GameModeButtonMixin.OnLeave(self);

	self:SetPulsePlaying(true);
end

function GameModeButtonPulsingMixin:OnSelected(newSelected)
	self:SetPulsePlaying(not newSelected);
end

function GameModeButtonPulsingMixin:SetPulsePlaying(playing)
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
function GameModeFrameMixin:OnLoad()
	self.buttonGroup = CreateRadioButtonGroup();
	self.buttonGroup:AddButton(self.SelectWoWToggle);
	self.buttonGroup:AddButton(self.SelectWoWLabsToggle);
	self.buttonGroup:RegisterCallback(ButtonGroupBaseMixin.Event.Selected, self.SelectGameMode, self);

	self:AddDynamicEventMethod(EventRegistry, "GameMode.Selected", self.OnGameModeSelected);
	self:AddDynamicEventMethod(EventRegistry, "RealmList.Cancel", self.OnRealmListCancel);	

	self:TryShowGameModeButtons();
end

function GameModeFrameMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);	
	ResizeLayoutMixin.OnShow(self);

	self:SelectRadioButtonForGameMode(C_GameRules.GetActiveGameMode());
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

function GameModeFrameMixin:OnGameModeSelected(requestedGameMode)
	assert(requestedGameMode);
	if C_GameRules.GetActiveGameMode() ~= requestedGameMode then
		if requestedGameMode ~= Enum.GameMode.Standard then
			g_newGameModeAvailableAcknowledged = 1;
		end

		self:ChangeGameMode(requestedGameMode);
	end
end

function GameModeFrameMixin:OnRealmListCancel()
	self:SelectRadioButtonForGameMode(C_GameRules.GetActiveGameMode());
end

function GameModeFrameMixin:TryShowGameModeButtons()
	self.shouldShowButtons = C_GameRules.GetCurrentEventRealmQueues() ~= Enum.EventRealmQueues.None;

	local currentExpansionLevel = AccountUpgradePanel_GetBannerInfo();
	if currentExpansionLevel and self.shownExpansionLevel ~= currentExpansionLevel then
		SetExpansionLogo(self.SelectWoWToggle.NormalTexture, currentExpansionLevel);
		self.shownExpansionLevel = currentExpansionLevel;
	end

	self.buttonGroup:SetShown(self.shouldShowButtons);
	self.NoGameModesText:SetShown(not self.shouldShowButtons);
	self.widthPadding = not self.shouldShowButtons and 20 or 0;
	self:Layout();
end

function GameModeFrameMixin:ChangeGameMode(newGameMode)
	assert(newGameMode);

	if C_GameRules.GetActiveGameMode() == newGameMode then
		return;
	end

	if newGameMode == Enum.GameMode.Plunderstorm then
		-- If we changed character order persist it
		CharacterSelectListUtil.SaveCharacterOrder();
		-- Swap to the Plunderstorm Realm
		C_RealmList.ConnectToEventRealm(GetCVar("plunderStormRealm")); --WOWLABSTODO: Should this CVar thing be hidden from lua?
		CharacterSelect.connectingToPlunderstorm = true;
	else
		-- Ensure we have auto realm select enabled
		CharacterSelect_SetAutoSwitchRealm(true);
		C_RealmList.ReconnectExceptCurrentRealm();

		-- Grab the RealmList again and allow the automatic system to select a realm for us
		C_RealmList.RequestChangeRealmList();
		CharacterSelect.connectingToPlunderstorm = false;
	end
end

function GameModeFrameMixin:SelectRadioButtonForGameMode(requestedGameMode)
	for i, button in ipairs(self.buttonGroup:GetButtons()) do
		button:SetSelectedState(requestedGameMode == button.gameMode);
		if button.SetPulsePlaying then
			button:SetPulsePlaying(requestedGameMode ~= button.gameMode);
		end
	end

	EventRegistry:TriggerEvent("GameMode.UpdateNavBar");
end

function GameModeFrameMixin:SelectGameMode(button, _buttonIndex)
	local requestedGameMode = button.gameMode;
	assert(requestedGameMode);

	EventRegistry:TriggerEvent("GameMode.Selected", requestedGameMode);
end

function GameModeFrameMixin:GetSelectedGameMode()
	local selectedButtons = self.buttonGroup:GetSelectedButtons();
	if #selectedButtons == 0 then
		return Enum.GameMode.Standard;
	end

	-- We should never have more than one selected button.
	return selectedButtons[1].gameMode;
end