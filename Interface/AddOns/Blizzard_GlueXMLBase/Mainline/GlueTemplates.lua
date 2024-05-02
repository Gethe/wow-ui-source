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
-- GAME ENVIRONMENT BUTTON MIXIN
GameEnvironmentButtonMixin = {};
function GameEnvironmentButtonMixin:OnLoad()
	SelectableButtonMixin.OnLoad(self);
	self:SetAlpha(0.5);
end

function GameEnvironmentButtonMixin:OnEnter()
	if not self:IsSelected() then
		self:SetAlpha(0.7);
	end
end

function GameEnvironmentButtonMixin:OnLeave()
	if not self:IsSelected() then
		self:SetAlpha(0.5);
	end
end

function GameEnvironmentButtonMixin:SetSelectedState(selected)
	SelectableButtonMixin.SetSelectedState(self, selected);
	self.SelectedTexture:SetShown(selected);
	self.BackgroundGlowTexture:SetShown(selected);
	self:SetAlpha(selected and 1 or 0.5);
end

---------------------------------------------------
-- GAME ENVIRONMENT BUTTON PULSING MIXIN
GameEnvironmentButtonPulsingMixin = CreateFromMixins(GameEnvironmentButtonMixin);

function GameEnvironmentButtonPulsingMixin:OnLoad()
	GameEnvironmentButtonMixin.OnLoad(self);

	self.PulseTexture:SetTexture(self.NormalTexture:GetTexture());
	self.PulseTexture:SetSize(self.NormalTexture:GetSize());

	self.PulseTextureTwo:SetTexture(self.NormalTexture:GetTexture());
	self.PulseTextureTwo:SetSize(self.NormalTexture:GetSize());

	self:SetPulsePlaying(true);
end

function GameEnvironmentButtonPulsingMixin:OnShow()
	self:SetPulsePlaying(true);
end

function GameEnvironmentButtonPulsingMixin:OnEnter()
	GameEnvironmentButtonMixin.OnEnter(self);

	self:SetPulsePlaying(false);
end

function GameEnvironmentButtonPulsingMixin:OnLeave()
	GameEnvironmentButtonMixin.OnLeave(self);

	self:SetPulsePlaying(true);
end

function GameEnvironmentButtonPulsingMixin:OnSelected(newSelected)
	self:SetPulsePlaying(not newSelected);	
end

function GameEnvironmentButtonPulsingMixin:SetPulsePlaying(playing)
	playing = playing and not self:IsSelected();
	if self.pulsePlaying == playing then
		return;
	end

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
-- GAME ENVIRONMENT FRAME MIXIN
GameEnvironmentFrameMixin = {};
function GameEnvironmentFrameMixin:OnLoad()
	self.buttonGroup = CreateRadioButtonGroup();
	self.buttonGroup:AddButton(self.SelectWoWToggle);
	self.buttonGroup:AddButton(self.SelectWoWLabsToggle);
	self.environments = {Enum.GameEnvironment.WoW, Enum.GameEnvironment.WoWLabs};
	self.buttonGroup:RegisterCallback(ButtonGroupBaseMixin.Event.Selected, self.SelectGameEnvironment, self);
end

function GameEnvironmentFrameMixin:ChangeGameEnvironment(newEnvironment)
	assert(newEnvironment);
	if C_GameEnvironmentManager.GetCurrentGameEnvironment() == newEnvironment then		
		return;
	end

	--GlueDialog_Show("SWAPPING_ENVIRONMENT");
	if newEnvironment == Enum.GameEnvironment.WoWLabs then
		-- If we changed character order persist it
		CharacterSelectListUtil.SaveCharacterOrder();
		-- Swap to the Plunderstorm Realm
		C_RealmList.ConnectToPlunderstorm(GetCVar("plunderStormRealm")); --WOWLABSTODO: Should this CVar thing be hidden from lua?
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

function GameEnvironmentFrameMixin:SelectRadioButtonForEnvironment(requestedEnvironment)
	self.SelectWoWToggle:SetSelectedState(requestedEnvironment == Enum.GameEnvironment.WoW);
	self.SelectWoWLabsToggle:SetSelectedState(requestedEnvironment == Enum.GameEnvironment.WoWLabs);
	self.SelectWoWLabsToggle:SetPulsePlaying(requestedEnvironment ~= Enum.GameEnvironment.WoWLabs);
end

function GameEnvironmentFrameMixin:SelectGameEnvironment(button, buttonIndex)
	local requestedEnvironment = button.gameEnvironment;
	assert(requestedEnvironment);

	EventRegistry:TriggerEvent("GameEnvironment.Selected", requestedEnvironment);
end
