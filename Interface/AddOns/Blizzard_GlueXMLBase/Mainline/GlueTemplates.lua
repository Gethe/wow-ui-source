--Tab stuffs

local TAB_SIDES_PADDING = 30;

function GlueTemplates_TabResize(tab)
	local width = tab.Text:GetStringWidth() + TAB_SIDES_PADDING;
	tab:SetWidth(width);
end

function GlueTemplates_SetTab(frame, id)
	frame.selectedTab = id;
	GlueTemplates_UpdateTabs(frame);
end

function GlueTemplates_GetSelectedTab(frame)
	return frame.selectedTab;
end

function GlueTemplates_UpdateTabs(frame)
	if ( frame.selectedTab ) then
		local tab;
		for i=1, frame.numTabs, 1 do
			tab = _G[frame:GetName().."Tab"..i];
			if ( tab.isDisabled ) then
				GlueTemplates_SetDisabledTabState(tab);
			elseif ( i == frame.selectedTab ) then
				GlueTemplates_SelectTab(tab);
			else
				GlueTemplates_DeselectTab(tab);
			end
		end
	end
end

function GlueTemplates_SetNumTabs(frame, numTabs)
	frame.numTabs = numTabs;
end

function GlueTemplates_DisableTab(frame, index)
	_G[frame:GetName().."Tab"..index].isDisabled = 1;
	GlueTemplates_UpdateTabs(frame);
end

function GlueTemplates_EnableTab(frame, index)
	local tab = _G[frame:GetName().."Tab"..index];
	tab.isDisabled = nil;
	GlueTemplates_UpdateTabs(frame);
end

function GlueTemplates_DeselectTab(tab)
	tab.Left:Show();
	tab.Middle:Show();
	tab.Right:Show();
	tab:Enable();
	tab.Text:SetPoint("CENTER", tab, "CENTER", 0, 2);
	tab.LeftActive:Hide();
	tab.MiddleActive:Hide();
	tab.RightActive:Hide();
end

function GlueTemplates_SelectTab(tab)
	tab.Left:Hide();
	tab.Middle:Hide();
	tab.Right:Hide();
	tab:Disable();
	tab.Text:SetPoint("CENTER", tab, "CENTER", 0, -3);
	tab.LeftActive:Show();
	tab.MiddleActive:Show();
	tab.RightActive:Show();
end

function GlueTemplates_SetDisabledTabState(tab)
	tab.Left:Show();
	tab.Middle:Show();
	tab.Right:Show();
	tab:Disable();
	tab.Text:SetPoint("CENTER", tab, "CENTER", 0, 2);
	tab.LeftActive:Hide();
	tab.MiddleActive:Hide();
	tab.RightActive:Hide();
end

---------------------------------------------------
-- GAME MODE BUTTON MIXIN
GameModeButtonMixin = {};

local GameModeButtonScales = {
	[Enum.GameMode.Standard] = 0.9,
	[Enum.GameMode.Plunderstorm] = 0.68,
};

function GameModeButtonMixin:OnLoad()
	SelectableButtonMixin.OnLoad(self);
	self:SetAlpha(0.5);

	self.selectedScale = GameModeButtonScales[self.gameMode];
	self.deselectedScale = self.selectedScale - 0.09;
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

	self:TryShowGameModeButtons();
end

function GameModeFrameMixin:OnShow()
	ResizeLayoutMixin.OnShow(self);

	self:TryShowGameModeButtons();
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

function GameModeFrameMixin:OnKeyDown(key)
	if key == "ESCAPE" and self:IsShown() then
		EventRegistry:TriggerEvent("GameModeFrame.Hide");
	end
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