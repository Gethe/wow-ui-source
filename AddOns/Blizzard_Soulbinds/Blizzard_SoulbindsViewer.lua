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

	local activateSoulbind = function()
		self:OnActivateSoulbindClicked();
	end;
	self.ActivateButton:SetScript("OnClick", activateSoulbind);

	local resetOpenSoulbind = function()
		self:ResetOpenSoulbind();
	end;
	self.ResetButton:SetScript("OnClick", resetOpenSoulbind);

	self.Tree:RegisterCallback(SoulbindTreeMixin.Event.OnNodeChanged, self.OnNodeChanged, self);
	self.SelectGroup:RegisterCallback(SoulbindSelectGroupMixin.Event.OnSoulbindSelected, self.OnSoulbindSelected, self);
	
	NineSliceUtil.ApplyUniqueCornersLayout(self, "Oribos");
	UIPanelCloseButton_SetBorderAtlas(self.CloseButton, "UI-Frame-Oribos-ExitButtonBorder", -1, 1);

	self.ShadowTop:SetTexCoord(1, 0, 1, 0);
	self.ShadowLeft:SetTexCoord(1, 0, 1, 0);
end

function SoulbindViewerMixin:OnEvent(event, ...)
	if event == "SOULBIND_FORGE_INTERACTION_STARTED" then
		self:OpenSoulbindForge();
	elseif event == "SOULBIND_FORGE_INTERACTION_ENDED" then
		HideUIPanel(self);
	elseif event == "SOULBIND_ACTIVATED" then
		self:OnSoulbindActivated(...);
	end
end

function SoulbindViewerMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, SoulbindViewerEvents);

	local atForge = C_Soulbinds.IsAtSoulbindForge();
	self.ResetButton:SetScript("OnEnter", GenerateClosure(self.SetupResetButtonTooltip, self));
	self.ResetButton:SetScript("OnLeave", GenerateClosure(self.HideResetButtonTooltip, self));
	self.ResetButton:SetShown(atForge);

	PlaySound(SOUNDKIT.SOULBINDS_OPEN_UI);
end

function SoulbindViewerMixin:HideResetButtonTooltip()
	GameTooltip:Hide();
end

function SoulbindViewerMixin:SetupResetButtonTooltip()
	GameTooltip:SetOwner(self.ResetButton, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, SOULBIND_RESET_BUTTON);
	GameTooltip:Show();
end

function SoulbindViewerMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, SoulbindViewerEvents);
	C_Soulbinds.EndInteraction();

	PlaySound(SOUNDKIT.SOULBINDS_CLOSE_UI);
end

function SoulbindViewerMixin:OnNodeChanged()
	self:UpdateResetButton();
end

function SoulbindViewerMixin:UpdateResetButton()
	local canReset = self.Tree:HasSelectedNodes();
	self.ResetButton:SetEnabled(canReset);
end

function SoulbindViewerMixin:OpenSoulbindForge()
	local covenantData = C_Covenants.GetCovenantData(C_Covenants.GetActiveCovenantID());
	local soulbindData = C_Soulbinds.GetSoulbindData(C_Soulbinds.GetActiveSoulbindID());

	self:InitCovenant(covenantData, soulbindData);
	ShowUIPanel(self);
end

function SoulbindViewerMixin:OpenSoulbind(soulbindID)
	local soulbindData = C_Soulbinds.GetSoulbindData(soulbindID);
	local covenantData = C_Covenants.GetCovenantData(soulbindData.covenantID);
	
	self:InitCovenant(covenantData, soulbindData);
	ShowUIPanel(SoulbindViewer);
end

function SoulbindViewerMixin:InitCovenant(covenantData, soulbindData)
	self.soulbindData = soulbindData;
	self.covenantData = covenantData;

	self.SelectGroup:Init(covenantData, soulbindData.ID);
	self.Background:SetAtlas(string.format("Soulbinds_Background_%s", covenantData.textureKit), true);
end

function SoulbindViewerMixin:OnSoulbindSelected(soulbindIDs, button, buttonIndex)
	-- Discard any drag & drop state that may be in progress.
	ClearCursor();
	
	local soulbindID = soulbindIDs[buttonIndex];
	local soulbindData = C_Soulbinds.GetSoulbindData(soulbindID);
	self.soulbindData = soulbindData;

	self.Name:SetText(soulbindData.name);
	self.Portrait:SetAtlas(soulbindData.portrait, true);
	self.Description:SetText(soulbindData.description)

	self.Tree:Init(soulbindData);

	self:UpdateActivateButton();
	self:UpdateResetButton();

	self:TriggerEvent(SoulbindViewerMixin.Event.OnSoulbindChanged, self.covenantData, soulbindData);
end

function SoulbindViewerMixin:OnSoulbindActivated(soulbindID)
	self.SelectGroup:UpdateActiveMarker();
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
	local canEnable = not self:IsActiveSoulbindOpen() and C_Covenants.GetActiveCovenantID() == self:GetCovenantData().ID;
	self.ActivateButton:SetEnabled(canEnable);
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
end

function SoulbindViewerMixin:OnInventoryItemEnter(bag, slot)
	self.Tree:OnInventoryItemEnter(bag, slot);
end

function SoulbindViewerMixin:OnInventoryItemLeave(bag, slot)
	self.Tree:OnInventoryItemLeave(bag, slot);
end