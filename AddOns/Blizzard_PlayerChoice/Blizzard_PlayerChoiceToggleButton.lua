local shownModeButtonInfo = 
{
	text = HIDE,
	normalAtlas = "UI-Frame-jailerstower-HideButton",
	highlightAtlas = "UI-Frame-jailerstower-HideButtonHighlight",
	xOffset = 3,
	showRerollButton = true;
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
	return C_PlayerChoice.IsWaitingForPlayerChoiceResponse();
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

	local numRerolls = C_PlayerChoice.GetNumRerolls();
	if buttonInfo.showRerollButton and (numRerolls > 0) then
		self.RerollButton:SetNumRerolls(numRerolls);
		self.RerollButton:Show();
	else
		self.RerollButton:Hide();
	end

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

PlayerChoiceRerollButtonMixin = {};

function PlayerChoiceRerollButtonMixin:OnShow()
	local rerollButtonHelpTipInfo = {
		text = TORGHAST_REROLL_TIP,
		buttonStyle = HelpTip.ButtonStyle.Close,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_TORGHAST_REROLL,
		targetPoint = HelpTip.Point.RightEdgeCenter,
		offsetX = -40,
		checkCVars = true,
	};

	HelpTip:Show(self, rerollButtonHelpTipInfo);
end

function PlayerChoiceRerollButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -75, -60);

	GameTooltip_SetTitle(GameTooltip, TORGHAST_REROLL_TOOLTIP_TITLE);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddNormalLine(GameTooltip, TORGHAST_REROLL_TOOLTIP_DESCRIPTION);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddInstructionLine(GameTooltip, TORGHAST_REROLL_COUNT:format(self.numRerolls));

	GameTooltip:Show();
end

function PlayerChoiceRerollButtonMixin:OnLeave()
	GameTooltip:Hide();
end

function PlayerChoiceRerollButtonMixin:OnClick()
	PlaySound(SOUNDKIT.UI_PLAYER_CHOICE_JAILERS_TOWER_REROLL_POWERS);
	C_PlayerChoice.RequestRerollPlayerChoice();
end

function PlayerChoiceRerollButtonMixin:SetNumRerolls(numRerolls)
	self:SetFormattedText("%d%s", numRerolls, CreateAtlasMarkup("common-icon-undo", 20, 20));
	self.numRerolls = numRerolls;

	if self:IsMouseOver() then
		self:OnEnter();
	end
end
