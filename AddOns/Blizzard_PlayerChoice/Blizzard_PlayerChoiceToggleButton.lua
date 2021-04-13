local shownModeButtonInfo = 
{
	text = HIDE,
	normalAtlas = "UI-Frame-jailerstower-HideButton",
	highlightAtlas = "UI-Frame-jailerstower-HideButtonHighlight",
	xOffset = 3,
};

local hiddenModeButtonInfo = 
{
	text = JAILERS_TOWER_PENDING_POWER_SELECTION,
	normalAtlas = "UI-Frame-jailerstower-PendingButton";
	highlightAtlas = "UI-Frame-jailerstower-PendingButtonHighlight";
	xOffset = 8,
	effectID = 98,
};

PlayerChoiceToggleButtonMixin = { };

function PlayerChoiceToggleButtonMixin:ShouldShow()
	return IsInJailersTower() and C_PlayerChoice.IsWaitingForPlayerChoiceResponse();
end

function PlayerChoiceToggleButtonMixin:TryShow()
	if not self:ShouldShow() then
		self:Hide();
		return;
	end

	self:UpdateButtonState();
	self:Show();
end

function PlayerChoiceToggleButtonMixin:StartEffect(effectID)
	if not self.effectController then
		self.effectController = GlobalFXMediumModelScene:AddEffect(effectID, self);
	end
end

function PlayerChoiceToggleButtonMixin:CancelEffect()
	if self.effectController then
		self.effectController:CancelEffect();
		self.effectController = nil;
	end
end

function PlayerChoiceToggleButtonMixin:UpdateEffect(effectID)
	if effectID then
		self:StartEffect(effectID);
	else
		self:CancelEffect();
	end
end

function PlayerChoiceToggleButtonMixin:OnShow()
	self:UpdateButtonState();
end

function PlayerChoiceToggleButtonMixin:OnHide()
	self:CancelEffect();
end

function PlayerChoiceToggleButtonMixin:UpdateButtonState()
	local buttonInfo = PlayerChoiceFrame:IsShown() and shownModeButtonInfo or hiddenModeButtonInfo;

	self:SetNormalAtlas(buttonInfo.normalAtlas);
	self:SetHighlightAtlas(buttonInfo.highlightAtlas);
	self.Text:SetText(buttonInfo.text);
	self.Text:SetPoint("CENTER", self, "CENTER", buttonInfo.xOffset, -3);
	self:UpdateEffect(buttonInfo.effectID);

	local normalAtlasInfo = C_Texture.GetAtlasInfo(buttonInfo.normalAtlas);
	if normalAtlasInfo then
		self:SetSize(normalAtlasInfo.width, normalAtlasInfo.height);
	end
end

function PlayerChoiceToggleButtonMixin:OnClick()
	if PlayerChoiceFrame:IsShown() then
		PlaySound(SOUNDKIT.UI_PLAYER_CHOICE_JAILERS_TOWER_HIDE_POWERS);
		HideUIPanel(PlayerChoiceFrame);
	else
		PlaySound(SOUNDKIT.UI_PLAYER_CHOICE_JAILERS_TOWER_SHOW_POWERS);
		PlayerChoiceFrame:TryShow();
	end
	self.FadeIn:Restart();
end
