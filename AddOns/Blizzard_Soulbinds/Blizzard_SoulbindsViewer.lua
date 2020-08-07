local SoulbindViewerEvents =
{
	"SOULBIND_FORGE_INTERACTION_ENDED",
	"SOULBIND_ACTIVATED",
};

SoulbindViewerMixin = CreateFromMixins(CallbackRegistryMixin);

SoulbindViewerMixin:GenerateCallbackEvents(
	{
		"OnSoulbindChanged",
	}
);

function SoulbindViewerMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self:RegisterEvent("SOULBIND_FORGE_INTERACTION_STARTED");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");

	self.ActivateButton:SetScript("OnClick", function()
		self:OnActivateSoulbindClicked();
	end);

	local function SetActivationTooltip(text)
		GameTooltip:SetOwner(self.ActivateButton, "ANCHOR_RIGHT");
		GameTooltip_AddErrorLine(GameTooltip, text);
		GameTooltip:Show();
	end;

	self.ActivateButton:SetScript("OnEnter", function()
		local activateResult, errorDesc = C_Soulbinds.CanActivateSoulbind(self:GetOpenSoulbindID());
		if not activateResult then
			SetActivationTooltip(errorDesc);
		end
	end);
	self.ActivateButton:SetScript("OnLeave", GameTooltip_Hide);

	self.ResetButton:SetScript("OnClick", function()
		local dialogCallback = GenerateClosure(self.ResetOpenSoulbind, self);
		StaticPopup_Show("SOULBIND_RESET_TREE", nil, nil, dialogCallback);
	end);

	self.Tree:RegisterCallback(SoulbindTreeMixin.Event.OnNodeChanged, self.OnNodeChanged, self);
	self.SelectGroup:RegisterCallback(SoulbindSelectGroupMixin.Event.OnSoulbindSelected, self.OnSoulbindSelected, self);
	
	NineSliceUtil.ApplyUniqueCornersLayout(self, "Oribos");
	UIPanelCloseButton_SetBorderAtlas(self.CloseButton, "UI-Frame-Oribos-ExitButtonBorder", -1, 1);

	self.ShadowTop:SetTexCoord(1, 0, 1, 0);
	self.ShadowLeft:SetTexCoord(1, 0, 1, 0);
end

function SoulbindViewerMixin:OnEvent(event, ...)
	if event == "SOULBIND_FORGE_INTERACTION_STARTED" then
		self:Open();
	elseif event == "SOULBIND_FORGE_INTERACTION_ENDED" then
		HideUIPanel(self);
	elseif event == "SOULBIND_ACTIVATED" then
		self:OnSoulbindActivated(...);
	elseif event == "CURRENCY_DISPLAY_UPDATE" then
		self:UpdateResetButton();
	end
end

function SoulbindViewerMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, SoulbindViewerEvents);

	self.ResetButton:SetScript("OnEnter", GenerateClosure(self.SetupResetButtonTooltip, self));
	self.ResetButton:SetScript("OnLeave", GenerateClosure(self.HideResetButtonTooltip, self));
	self.ResetButton:SetShown(C_Soulbinds.IsAtSoulbindForge());

	PlaySound(SOUNDKIT.SOULBINDS_OPEN_UI);
end

function SoulbindViewerMixin:HideResetButtonTooltip()
	GameTooltip:Hide();
end

function SoulbindViewerMixin:SetupResetButtonTooltip()
	GameTooltip:SetOwner(self.ResetButton, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, SOULBIND_RESET_BUTTON);

	for _, currencyCostData in ipairs(self.soulbindData.resetData.currencyCosts) do
		local currencyInfo = C_CurrencyInfo.GetBasicCurrencyInfo(currencyCostData.currencyID, currencyCostData.quantity);
		if currencyInfo then
			local markup = CreateTextureMarkup(currencyInfo.icon, 14, 14, 14, 14, 0, 1, 0, 1, 0, -1);
			local currentCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyCostData.currencyID);
			local text = SOULBIND_RESET_CURRENCY_FORMAT:format(currencyInfo.displayAmount, markup, currencyInfo.name);
			local cannotAfford = currentCurrencyInfo.quantity < currencyInfo.displayAmount;
			if cannotAfford then
				GameTooltip_AddErrorLine(GameTooltip, text);
			else
				GameTooltip_AddHighlightLine(GameTooltip, text);
			end

			local canReset = self.Tree:HasSelectedNodes();
			if not canReset then
				GameTooltip_AddErrorLine(GameTooltip, SOULBIND_RESET_INELIGIBLE);
			end
		end
	end

	GameTooltip:Show();
end

function SoulbindViewerMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, SoulbindViewerEvents);
	C_Soulbinds.EndInteraction();

	PlaySound(SOUNDKIT.SOULBINDS_CLOSE_UI);
end

function SoulbindViewerMixin:OnNodeChanged()
	self:UpdateResetButton();
	self:UpdateActivateButton();
end

function SoulbindViewerMixin:CanAffordReset()
	for _, currencyCostData in ipairs(self.soulbindData.resetData.currencyCosts) do
		local currencyInfo = C_CurrencyInfo.GetBasicCurrencyInfo(currencyCostData.currencyID, currencyCostData.quantity);
		if currencyInfo then
			local currentCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyCostData.currencyID);
			local cannotAfford = currentCurrencyInfo.quantity < currencyInfo.displayAmount;
			if cannotAfford then
				return false;
			end
		end
	end
	return true;
end

function SoulbindViewerMixin:UpdateResetButton()
	self.ResetButton:SetShown(C_Soulbinds.IsAtSoulbindForge());
	local enabled = self.Tree:HasSelectedNodes() and self:CanAffordReset();
	self.ResetButton:SetEnabled(enabled);
	self.ResetButton:SetAlpha(enabled and 1 or .6);
end

function SoulbindViewerMixin:Open()
	local covenantData = C_Covenants.GetCovenantData(C_Covenants.GetActiveCovenantID());
	local soulbindData = C_Soulbinds.GetSoulbindData(C_Soulbinds.GetActiveSoulbindID());
	self:Init(covenantData, soulbindData);
	ShowUIPanel(self);
end

function SoulbindViewerMixin:OpenSoulbind(soulbindID)
	local soulbindData = C_Soulbinds.GetSoulbindData(soulbindID);
	local covenantData = C_Covenants.GetCovenantData(soulbindData.covenantID);
	
	self:Init(covenantData, soulbindData);
	ShowUIPanel(SoulbindViewer);
end

function SoulbindViewerMixin:Init(covenantData, soulbindData)
	if not covenantData then
		error("You are not in a required covenant.");
	end

	self.soulbindData = soulbindData;
	self.covenantData = covenantData;

	local background = "Soulbinds_Background";
	self.Background:SetAtlas(background, true);
	self.Background2:SetAtlas(background, true);

	self.SelectGroup:Init(covenantData, soulbindData.ID);
	self.ConduitList:Init();
end

function SoulbindViewerMixin:OnSoulbindSelected(soulbindIDs, button, buttonIndex)
	-- Discard any drag & drop state that may be in progress.
	ClearCursor();
	
	local soulbindID = soulbindIDs[buttonIndex];
	local soulbindData = C_Soulbinds.GetSoulbindData(soulbindID);
	self.soulbindData = soulbindData;

	self.Tree:Init(soulbindData);

	self:UpdateActivateButton();
	self:UpdateResetButton();

	self:TriggerEvent(SoulbindViewerMixin.Event.OnSoulbindChanged, self.covenantData, soulbindData);
end

function SoulbindViewerMixin:OnSoulbindActivated(soulbindID)
	self.Background2.ActivateAnim:Play();
	self.ActivateFX.ActivateAnim:Play();
	self.Fx.ActivateFXLensFlare1.ActivateAnim:Play();
	self.Fx.ActivateFXLensFlare2.ActivateAnim:Play();
	self.Fx.ActivateFXRunes1.ActivateAnim:Play();
	self.Fx.ActivateFXRunes2.ActivateAnim:Play();
	self.SelectGroup:OnSoulbindActivated(soulbindID);
	self.Tree:Init(C_Soulbinds.GetSoulbindData(soulbindID));
	self:UpdateResetButton();
end

function SoulbindViewerMixin:GetCovenantData()
	return self.covenantData;
end

function SoulbindViewerMixin:GetSoulbindData()
	return self.soulbindData;
end

function SoulbindViewerMixin:UpdateActivateButton()
	local openSoulbindID = self:GetOpenSoulbindID();
	local canActivate = C_Soulbinds.CanActivateSoulbind(openSoulbindID);
	local enabled = canActivate and not self:IsActiveSoulbindOpen() and C_Covenants.GetActiveCovenantID() == self:GetCovenantData().ID;
	
	self.ActivateButton:SetEnabled(enabled);

	if Soulbinds.HasNewSoulbindTutorial(self.soulbindData.ID) then
		local showTutorial = enabled and self.Tree:HasSelectedNodes() and not GetCVarBitfield("soulbindsActivatedTutorial", self.soulbindData.cvarIndex);
		ButtonPulseGlow:SetShown(self.ActivateButton, showTutorial);
	else
		ButtonPulseGlow:Hide(self.ActivateButton);
	end
end

function SoulbindViewerMixin:IsActiveSoulbindOpen()
	return C_Soulbinds.GetActiveSoulbindID() == self:GetOpenSoulbindID();
end

function SoulbindViewerMixin:GetOpenSoulbindID()
	return self.soulbindData.ID;
end

function SoulbindViewerMixin:ResetOpenSoulbind()
	C_Soulbinds.ResetSoulbind(self:GetOpenSoulbindID());
	PlaySound(SOUNDKIT.SOULBINDS_RESET_SOULBIND);
end

function SoulbindViewerMixin:OnActivateSoulbindClicked()
	self.ActivateButton:SetEnabled(false);
	C_Soulbinds.ActivateSoulbind(self:GetOpenSoulbindID());
	PlaySound(SOUNDKIT.SOULBINDS_ACTIVATE_SOULBIND);

	if Soulbinds.HasNewSoulbindTutorial(self.soulbindData.ID) then
		ButtonPulseGlow:Hide(self.ActivateButton);
		SetCVarBitfield("soulbindsActivatedTutorial", self.soulbindData.cvarIndex, true);
	end
end

function SoulbindViewerMixin:OnCollectionConduitEnter(conduitType)
	self.Tree:OnCollectionConduitEnter(conduitType);
end

function SoulbindViewerMixin:OnCollectionConduitLeave()
	self.Tree:OnCollectionConduitLeave();
end

StaticPopupDialogs["SOULBIND_RESET_TREE"] = {
	text = SOULBIND_RESET_TREE,
	button1 = ACCEPT,
	button2 = CANCEL,
	enterClicksFirstButton = true,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1,

	OnButton1 = function(self, callback)
		callback();
	end,
};
