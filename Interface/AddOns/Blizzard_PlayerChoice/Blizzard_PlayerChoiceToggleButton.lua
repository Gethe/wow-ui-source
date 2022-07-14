local textureKitEffectIDs =
{
	jailerstower = 98,
};

PlayerChoiceToggleButtonMixin = {};

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

function PlayerChoiceToggleButtonMixin:ShouldShow()
	local toggleShown = PlayerChoiceToggle_ShouldShow();
	if not toggleShown then
		return false;
	end

	local choiceInfo = C_PlayerChoice.GetCurrentPlayerChoiceInfo();
	local textureKit = choiceInfo and choiceInfo.uiTextureKit;
	return textureKit == self.textureKit;
end

function PlayerChoiceToggleButtonMixin:UpdateButtonState()
	if not self:ShouldShow() then
		self:Hide();
		return;
	end
	
	local choiceFrameShown = PlayerChoiceFrame:IsShown();
	local buttonInfo = choiceFrameShown and self.shownModeButtonInfo or self.hiddenModeButtonInfo;
	local choiceInfo = C_PlayerChoice.GetCurrentPlayerChoiceInfo();
	local textureKit = choiceInfo.uiTextureKit;

	local normalAtlas = GetFinalNameFromTextureKit(buttonInfo.normalAtlas, textureKit);
	local normalAtlasInfo = C_Texture.GetAtlasInfo(normalAtlas);
	if normalAtlasInfo then
		self:SetNormalAtlas(normalAtlas);
		self:SetSize(normalAtlasInfo.width, normalAtlasInfo.height);
	end

	if buttonInfo.highlightAtlas then
		local highlightAtlas = GetFinalNameFromTextureKit(buttonInfo.highlightAtlas, textureKit);
		if C_Texture.GetAtlasInfo(highlightAtlas) then
			self:SetHighlightAtlas(highlightAtlas);
		end
	end

	self.Text:SetText(choiceFrameShown and HIDE or choiceInfo.pendingChoiceText);
	self.Text:SetPoint("CENTER", self, "CENTER", buttonInfo.xOffset or 0, buttonInfo.yOffset or 0);
	local effectID = (not choiceFrameShown) and textureKitEffectIDs[textureKit] or nil;
	self:UpdateEffect(effectID);
end

function PlayerChoiceToggleButtonMixin:OnClick()
	if PlayerChoiceFrame:IsShown() then
		if self.hidePowersSound then
			PlaySound(self.hidePowersSound);
		end
		HideUIPanel(PlayerChoiceFrame);
	else
		if self.showPowersSound then
			PlaySound(self.showPowersSound);
		end
		PlayerChoiceFrame:TryShow();
	end

	self.FadeIn:Restart();
end


TorghastPlayerChoiceToggleButtonMixin = {};

function TorghastPlayerChoiceToggleButtonMixin:UpdateButtonState()
	PlayerChoiceToggleButtonMixin.UpdateButtonState(self);

	local choiceFrameShown = PlayerChoiceFrame:IsShown();
	local buttonInfo = choiceFrameShown and self.shownModeButtonInfo or self.hiddenModeButtonInfo;
	local numRerolls = C_PlayerChoice.GetNumRerolls();
	if buttonInfo.showRerollButton and (numRerolls > 0) then
		self.RerollButton:SetNumRerolls(numRerolls);
		self.RerollButton:Show();
	else
		self.RerollButton:Hide();
	end
end

function TorghastPlayerChoiceToggleButtonMixin:OnLoad()
	self.shownModeButtonInfo = 
	{
		normalAtlas = "UI-Frame-%s-HideButton",
		highlightAtlas = "UI-Frame-%s-HideButtonHighlight",
		xOffset = 3,
		yOffset = -3,
		showRerollButton = true,
	};

	self.hiddenModeButtonInfo = 
	{
		normalAtlas = "UI-Frame-%s-PendingButton",
		highlightAtlas = "UI-Frame-%s-PendingButtonHighlight",
		xOffset = 8,
		yOffset = -3,
	};
end


CypherPlayerChoiceToggleButtonMixin = {};

function CypherPlayerChoiceToggleButtonMixin:OnLoad()
	self.shownModeButtonInfo = 
	{
		normalAtlas = "UI-Frame-%s-HideButton",
		highlightAtlas = "UI-Frame-%s-HideButtonHighlight",
	};

	self.hiddenModeButtonInfo = 
	{
		normalAtlas = "UI-Frame-%s-PendingButton",
		highlightAtlas = "UI-Frame-%s-PendingButtonHighlight",
	};
end

function CypherPlayerChoiceToggleButtonMixin:UpdateButtonState()
	PlayerChoiceToggleButtonMixin.UpdateButtonState(self);

	local isPending = not PlayerChoiceFrame:IsShown();

	for _, piece in ipairs(self.pendingPieces) do
		piece:SetShown(isPending);
	end

	for _, animation in ipairs(self.pendingAnimations) do
		if isPending then
			animation:Restart();
		else
			animation:Stop();
		end
	end
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


-- Filled when needed for the first time, since the toggle buttons don't exist when this is loaded
local toggleButtons = nil;
local function FillToggleButtonsIfNeeded()
	if toggleButtons == nil then
		toggleButtons =
		{
			TorghastPlayerChoiceToggleButton,
			CypherPlayerChoiceToggleButton,
		};
	end
end

function PlayerChoiceToggle_ShouldShow()
	return C_PlayerChoice.IsWaitingForPlayerChoiceResponse() and C_PlayerChoice.GetRemainingTime() ~= 0;
end

function PlayerChoiceToggle_TryShow()
	FillToggleButtonsIfNeeded();

	for _, button in pairs(toggleButtons) do
		if button:ShouldShow() then
			button:UpdateButtonState();
			button:Show();
		else
			button:Hide();
		end
	end
end

function PlayerChoiceToggle_GetActiveToggle()
	FillToggleButtonsIfNeeded();

	local choiceInfo = C_PlayerChoice.GetCurrentPlayerChoiceInfo();
	local textureKit = choiceInfo and choiceInfo.uiTextureKit;

	for _, button in pairs(toggleButtons) do
		if button.textureKit == textureKit then
			return button;
		end
	end
end