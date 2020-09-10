local ResetConduitsFormatter = CreateFromMixins(SecondsFormatterMixin);
ResetConduitsFormatter:Init(SECONDS_PER_HOUR, SecondsFormatter.Abbreviation.None, true, true);

function ResetConduitsFormatter:GetDesiredUnitCount(seconds)
	return 1;
end

local SoulbindViewerEvents =
{
	"SOULBIND_FORGE_INTERACTION_ENDED",
	"SOULBIND_ACTIVATED",
	"SOULBIND_PENDING_CONDUIT_CHANGED",
	"SOULBIND_CONDUIT_INSTALLED",
	"SOULBIND_CONDUITS_RESET"
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

	self.ActivateSoulbindButton:SetScript("OnClick", GenerateClosure(self.OnActivateSoulbindClicked, self));
	self.ActivateSoulbindButton:SetScript("OnEnter", GenerateClosure(self.OnActivateSoulbindEnter, self));
	self.ActivateSoulbindButton:SetScript("OnLeave", GenerateClosure(self.OnActivateSoulbindLeave, self));
	self.CommitConduitsButton:SetScript("OnClick", GenerateClosure(self.OnCommitConduitsClicked, self));
	self.ResetConduitsButton:SetScript("OnClick", GenerateClosure(self.OnResetConduitsClicked, self));
	self.ResetConduitsButton:SetScript("OnEnter", GenerateClosure(self.OnResetConduitsButtonEnter, self));
	self.ResetConduitsButton:SetScript("OnLeave", GenerateClosure(self.OnResetConduitsButtonLeave, self));
	self.CloseButton:SetScript("OnClick", GenerateClosure(self.OnCloseButtonClicked, self));

	self.Tree:RegisterCallback(SoulbindTreeMixin.Event.OnNodeChanged, self.OnNodeChanged, self);
	
	NineSliceUtil.ApplyUniqueCornersLayout(self.Border, "Oribos");
	UIPanelCloseButton_SetBorderAtlas(self.CloseButton, "UI-Frame-Oribos-ExitButtonBorder", -1, 1);

	self.ShadowTop:SetTexCoord(1, 0, 1, 0);
	self.ShadowLeft:SetTexCoord(1, 0, 1, 0);
end

function SoulbindViewerMixin:OnCloseButtonClicked()
	if C_Soulbinds.HasAnyPendingConduits() then
		local onConfirm = function()
			UIPanelCloseButton_OnClick(self.CloseButton);
		end
		StaticPopup_Show("SOULBIND_CONDUIT_NO_CHANGES_CONFIRMATION", nil, nil, onConfirm);
	else
		UIPanelCloseButton_OnClick(self.CloseButton);
	end
end

function SoulbindViewerMixin:OnEvent(event, ...)
	if event == "SOULBIND_FORGE_INTERACTION_STARTED" then
		self:Open();
	elseif event == "SOULBIND_FORGE_INTERACTION_ENDED" then
		HideUIPanel(self);
	elseif event == "SOULBIND_ACTIVATED" then
		local soulbindID = ...;
		self:OnSoulbindActivated(...);
	elseif event == "SOULBIND_PENDING_CONDUIT_CHANGED" then
		local nodeID, conduitID, pending = ...;
		self:OnConduitChanged();
	elseif event == "SOULBIND_CONDUIT_INSTALLED" then
		self:UpdateButtons();
	elseif event == "SOULBIND_CONDUITS_RESET" then
		self:UpdateResetConduitsButton();
	end
end

function SoulbindViewerMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, SoulbindViewerEvents);

	self.ResetConduitsButton:SetShown(C_Soulbinds.CanModifySoulbind());

	self:UpdateButtons();

	PlaySound(SOUNDKIT.SOULBINDS_OPEN_UI);
end

function SoulbindViewerMixin:OnResetConduitsButtonLeave()
	GameTooltip:Hide();
end

function SoulbindViewerMixin:OnResetConduitsButtonEnter()
	GameTooltip:SetOwner(self.ResetConduitsButton, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, CONDUIT_RESET_BUTTON_HEADER);

	local soulbindID = self.soulbindData.ID;
	local hideNoConduitWarning = false;
	if C_Soulbinds.CanResetConduitsInSoulbind(soulbindID) then
		GameTooltip_AddNormalLine(GameTooltip, CONDUIT_RESET_AVAILABLE);
	else 
		local seconds = C_DateAndTime.GetSecondsUntilWeeklyReset();
		local time = ResetConduitsFormatter:Format(C_DateAndTime.GetSecondsUntilWeeklyReset())
		GameTooltip_AddNormalLine(GameTooltip, CONDUIT_RESET_AVAILABLE_IN:format(time));

		hideNoConduitWarning = true;
	end

	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddNormalLine(GameTooltip, CONDUIT_RESET_INSTRUCTION);
	
	-- No Socketed Conduits Warning
	if not hideNoConduitWarning then
		if not C_Soulbinds.HasAnyInstalledConduitInSoulbind(self.soulbindData.ID) then
			GameTooltip_AddErrorLine(GameTooltip, CONDUIT_RESET_INELIGIBLE);
		end
	end

	GameTooltip:Show();
end

function SoulbindViewerMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, SoulbindViewerEvents);
	C_Soulbinds.CloseUI();

	PlaySound(SOUNDKIT.SOULBINDS_CLOSE_UI);
end

function SoulbindViewerMixin:UpdateButtons()
	self:UpdateResetConduitsButton();
	self:UpdateActivateSoulbindButton();
	self:UpdateCommitConduitsButton();
end

function SoulbindViewerMixin:UpdateBackgrounds()
	local open = self:IsActiveSoulbindOpen();
	self.Background:SetDesaturated(not open);
	self.Background2:SetDesaturated(not open);
end

function SoulbindViewerMixin:OnConduitChanged()
	StaticPopup_Hide("SOULBIND_CONDUIT_INSTALL_CONFIRM");
	self:UpdateButtons();
end

function SoulbindViewerMixin:OnNodeChanged()
	self:UpdateButtons();
end

function SoulbindViewerMixin:UpdateResetConduitsButton()
	local shown = C_Soulbinds.CanModifySoulbind();
	self.ResetConduitsButton:SetShown(shown);
	if shown then
		local soulbindID = self.soulbindData.ID;
		local enabled = C_Soulbinds.HasAnyInstalledConduitInSoulbind(soulbindID) and C_Soulbinds.CanResetConduitsInSoulbind(soulbindID);
		self.ResetConduitsButton:SetEnabled(enabled);
		self.ResetConduitsButton:SetAlpha(enabled and 1 or .6);
	end
end

function SoulbindViewerMixin:Open()
	local covenantID = C_Covenants.GetActiveCovenantID();
	if covenantID == 0 then
		error("You are not in a required covenant.");
	end

	local soulbindID = C_Soulbinds.GetActiveSoulbindID();
	if soulbindID == 0 then
		soulbindID = Soulbinds.GetDefaultSoulbindID(covenantID);
	end

	self:OpenSoulbind(soulbindID);
end

function SoulbindViewerMixin:OpenSoulbind(soulbindID)
	local soulbindData = C_Soulbinds.GetSoulbindData(soulbindID);
	local covenantData = C_Covenants.GetCovenantData(soulbindData.covenantID);
	self:Init(covenantData, soulbindData);
	ShowUIPanel(SoulbindViewer);
end

function SoulbindViewerMixin:Init(covenantData, soulbindData)
	self.soulbindData = soulbindData;
	self.covenantData = covenantData;

	local background = "Soulbinds_Background";
	self.Background:SetAtlas(background, true);
	self.Background2:SetAtlas(background, true);
	self:UpdateBackgrounds();

	self.Tree:Init(soulbindData);
	self.ConduitList:Init();

	self.SelectGroup:Init(covenantData, soulbindData.ID);
	self.SelectGroup:RegisterCallback(SoulbindSelectGroupMixin.Event.OnSoulbindSelected, self.OnSoulbindSelected, self);
end

function SoulbindViewerMixin:OnSoulbindSelected(soulbindIDs, button, buttonIndex)
	-- Discard any drag & drop state that may be in progress.
	ClearCursor();
	
	local soulbindID = soulbindIDs[buttonIndex];
	local soulbindData = C_Soulbinds.GetSoulbindData(soulbindID);
	self.soulbindData = soulbindData;

	self.Tree:Init(soulbindData);
	self.ConduitList:Update();

	self:UpdateBackgrounds();
	self:UpdateButtons();
	
	self:TriggerEvent(SoulbindViewerMixin.Event.OnSoulbindChanged, self.covenantData, soulbindData);

	PlaySound(SOUNDKIT.SOULBINDS_SOULBIND_SELECTED);
end

function SoulbindViewerMixin:OnSoulbindActivated(soulbindID)
	local open = self:IsActiveSoulbindOpen();
	self.Background:SetDesaturated(not open);
	self.Background2:SetDesaturated(not open);
	self.Background2.ActivateAnim:Play();
	self.ActivateFX.ActivateAnim:Play();
	self.Fx.ActivateFXLensFlare1.ActivateAnim:Play();
	self.Fx.ActivateFXLensFlare2.ActivateAnim:Play();
	self.Fx.ActivateFXRunes1.ActivateAnim:Play();
	self.Fx.ActivateFXRunes2.ActivateAnim:Play();
	self.SelectGroup:OnSoulbindActivated(soulbindID);
	self.Tree:Init(C_Soulbinds.GetSoulbindData(soulbindID));
	self:UpdateButtons();
end

function SoulbindViewerMixin:GetCovenantData()
	return self.covenantData;
end

function SoulbindViewerMixin:GetSoulbindData()
	return self.soulbindData;
end

function SoulbindViewerMixin:UpdateActivateSoulbindButton()
	local openSoulbindID = self:GetOpenSoulbindID();
	local canActivate = C_Soulbinds.CanActivateSoulbind(openSoulbindID);
	local enabled = canActivate and not self:IsActiveSoulbindOpen() and C_Covenants.GetActiveCovenantID() == self:GetCovenantData().ID;
	
	self.ActivateSoulbindButton:SetEnabled(enabled);

	local showTutorial = enabled and self.Tree:HasSelectedNodes() and not GetCVarBitfield("soulbindsActivatedTutorial", self.soulbindData.cvarIndex);
	GlowEmitterFactory:SetShown(self.ActivateSoulbindButton, showTutorial, GlowEmitterMixin.Anims.FadeAnim);
end

function SoulbindViewerMixin:UpdateCommitConduitsButton()
	local pending = C_Soulbinds.HasPendingConduitsInSoulbind(self:GetOpenSoulbindID());
	self.CommitConduitsButton:SetShown(pending);
	GlowEmitterFactory:SetShown(self.CommitConduitsButton, pending, GlowEmitterMixin.Anims.FaintFadeAnim);
end

function SoulbindViewerMixin:IsActiveSoulbindOpen()
	return C_Soulbinds.GetActiveSoulbindID() == self:GetOpenSoulbindID();
end

function SoulbindViewerMixin:GetOpenSoulbindID()
	return self.soulbindData.ID;
end

function SoulbindViewerMixin:OnActivateSoulbindClicked()
	self.ActivateSoulbindButton:SetEnabled(false);
	C_Soulbinds.ActivateSoulbind(self:GetOpenSoulbindID());
	PlaySound(SOUNDKIT.SOULBINDS_ACTIVATE_SOULBIND);

	if Soulbinds.HasNewSoulbindTutorial(self.soulbindData.ID) then
		GlowEmitterFactory:Hide(self.ActivateSoulbindButton);
		SetCVarBitfield("soulbindsActivatedTutorial", self.soulbindData.cvarIndex, true);
	end
end

function SoulbindViewerMixin:OnActivateSoulbindEnter()
	local activateResult, errorDesc = C_Soulbinds.CanActivateSoulbind(self:GetOpenSoulbindID());
	if not activateResult then
		GameTooltip:SetOwner(self.ActivateSoulbindButton, "ANCHOR_RIGHT");
		GameTooltip_AddErrorLine(GameTooltip, errorDesc);
		GameTooltip:Show();
	end
end

function SoulbindViewerMixin:OnActivateSoulbindLeave()
	GameTooltip_Hide();
end

function SoulbindViewerMixin:OnCommitConduitsClicked()
	local onConfirm = function()
		C_Soulbinds.CommitPendingConduitsInSoulbind(self:GetOpenSoulbindID());
		PlaySound(SOUNDKIT.SOULBINDS_COMMIT_CONDUITS);
	end
	StaticPopup_Show("SOULBIND_CONDUIT_INSTALL_CONFIRM", nil, nil, onConfirm);
end

function SoulbindViewerMixin:OnResetConduitsClicked()
	local onConfirm = function()
		C_Soulbinds.ResetSoulbindConduits(self:GetOpenSoulbindID());
		PlaySound(SOUNDKIT.SOULBINDS_RESET_CONDUITS);
	end
	StaticPopup_Show("SOULBIND_RESET_TREE", nil, nil, onConfirm);
end

function SoulbindViewerMixin:OnCollectionConduitEnter(conduitType)
	self.Tree:OnCollectionConduitEnter(conduitType);
end

function SoulbindViewerMixin:OnCollectionConduitLeave()
	self.Tree:OnCollectionConduitLeave();
end

StaticPopupDialogs["SOULBIND_RESET_TREE"] = {
	text = SOULBIND_RESET_TREE,
	button1 = RESET,
	button2 = CANCEL,
	enterClicksFirstButton = true,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1,

	OnButton1 = function(self, callback)
		callback();
	end,
};

StaticPopupDialogs["SOULBIND_CONDUIT_NO_CHANGES_CONFIRMATION"] = {
	text = CONDUIT_NO_CHANGES_CONFIRMATION,
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

StaticPopupDialogs["SOULBIND_CONDUIT_INSTALL_CONFIRM"] = {
	text = CONDUIT_INSTALL_CONFIRM,
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
