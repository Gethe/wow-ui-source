local CONDUITS_LEARNED_IN_TUTORIAL = 3;

local SoulbindViewerEvents =
{
	"SOULBIND_FORGE_INTERACTION_ENDED",
	"SOULBIND_ACTIVATED",
	"SOULBIND_PENDING_CONDUIT_CHANGED",
	"SOULBIND_CONDUIT_INSTALLED",
	"SOULBIND_CONDUIT_UNINSTALLED",
	"SOULBIND_NODE_LEARNED",
	"SOULBIND_CONDUIT_COLLECTION_UPDATED",
	"BAG_UPDATE",
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
	self.CloseButton:SetScript("OnClick", GenerateClosure(self.OnCloseButtonClicked, self));

	self.Tree:RegisterCallback(SoulbindTreeMixin.Event.OnNodeChanged, self.OnNodeChanged, self);
	
	NineSliceUtil.ApplyUniqueCornersLayout(self.Border, "Oribos");
	UIPanelCloseButton_SetBorderAtlas(self.CloseButton, "UI-Frame-Oribos-ExitButtonBorder", -1, 1);

	self.ShadowTop:SetTexCoord(1, 0, 1, 0);
	self.ShadowLeft:SetTexCoord(1, 0, 1, 0);

	self.ConduitList:SetConduitPreview(self.ConduitPreview);
end

function SoulbindViewerMixin:OnCloseButtonClicked()
	if C_Soulbinds.HasAnyPendingConduits() then
		self:ShowChangesPendingDialog();
	else
		UIPanelCloseButton_OnClick(self.CloseButton);
	end
end

function SoulbindViewerMixin:ShowChangesPendingDialog()
	local onConfirm = function()
		UIPanelCloseButton_OnClick(self.CloseButton);
	end;
	StaticPopup_Show("SOULBIND_CONDUIT_NO_CHANGES_CONFIRMATION", nil, nil, onConfirm);
end

function SoulbindViewerMixin:OnEvent(event, ...)
	if event == "SOULBIND_FORGE_INTERACTION_STARTED" then
		self:Open();
	elseif event == "SOULBIND_FORGE_INTERACTION_ENDED" then
		HideUIPanel(self);
	elseif event == "SOULBIND_ACTIVATED" then
		Soulbinds.SetSoulbindIDActivationPending(nil);
		local soulbindID = ...;
		self:OnSoulbindActivated(...);
	elseif event == "SOULBIND_PENDING_CONDUIT_CHANGED" then
		local nodeID = ...;
		self:OnPendingConduitChanged(nodeID);
	elseif event == "SOULBIND_CONDUIT_INSTALLED" or event == "SOULBIND_CONDUIT_UNINSTALLED" then
		Soulbinds.SetConduitInstallPending(false);
		self:UpdateButtons();
	elseif event == "SOULBIND_NODE_LEARNED" then
		self:OnNodeLearned();
	elseif event == "SOULBIND_CONDUIT_COLLECTION_UPDATED" then
		self:OnConduitCollectionUpdated();
	elseif event == "BAG_UPDATE" then
		self.helpTipItemLocation = nil;
		self:CheckTutorials();
	end
end

function SoulbindViewerMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, SoulbindViewerEvents);

	self:UpdateButtons();

	PlaySound(SOUNDKIT.SOULBINDS_OPEN_UI);
	
	self:UpdateBackgrounds();

	if C_Soulbinds.CanModifySoulbind() then
		ItemButtonUtil.OpenAndFilterBags(self);
	end

	self:CheckTutorials();
end

function SoulbindViewerMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, SoulbindViewerEvents);
	C_Soulbinds.CloseUI();

	PlaySound(SOUNDKIT.SOULBINDS_CLOSE_UI);
	
	if HelpTip:IsShowingAnyInSystem("soulbinds") then
		HelpTip:HideAllSystem("soulbinds");
	end
	self.helpTipItemLocation = nil;

	ItemButtonUtil.CloseFilteredBags(self);
	
	StaticPopup_Hide("SOULBIND_CONDUIT_NO_CHANGES_CONFIRMATION");
	StaticPopup_Hide("SOULBIND_CONDUIT_INSTALL_CONFIRM");
end

function SoulbindViewerMixin:SetSheenAnimationsPlaying(playing)
	self.ForgeSheen.Anim:SetPlaying(playing);
	self.BackgroundSheen.Anim:SetPlaying(playing);
	self.GridSheen.Anim:SetPlaying(playing);
	self.BackgroundRuneLeft.Anim:SetPlaying(playing);
	self.BackgroundRuneRight.Anim:SetPlaying(playing);
	self.ConduitList.Fx.ChargeSheen.Anim:SetPlaying(playing);
end

function SoulbindViewerMixin:UpdateButtons()
	self:UpdateActivateSoulbindButton();
	self:UpdateCommitConduitsButton();
end

function SoulbindViewerMixin:UpdateBackgrounds()
	self:SetBackgroundStateActive(self:IsActiveSoulbindOpen());
end

function SoulbindViewerMixin:SetBackgroundStateActive(active)
	self.Background:SetDesaturated(not active);
	self.Background2:SetDesaturated(not active);
	self.BackgroundBlackOverlay:SetShown(not active);
	self.ConduitPreview:SetDesaturated(not active);
	self:SetSheenAnimationsPlaying(active);
end

function SoulbindViewerMixin:OnPendingConduitChanged(nodeID)
	StaticPopup_Hide("SOULBIND_CONDUIT_INSTALL_CONFIRM");
	
	self:UpdateButtons();

	HelpTip:AcknowledgeSystem("soulbinds", SOULBIND_SLOT_CONDUIT_TUTORIAL_TEXT);

	self:CheckTutorials();
end

function SoulbindViewerMixin:OnNodeLearned()
	HelpTip:AcknowledgeSystem("soulbinds", SOULBIND_SELECT_PATH_TUTORIAL_TEXT);

	self:CheckTutorials();
end

function SoulbindViewerMixin:OnConduitCollectionUpdated()
	HelpTip:AcknowledgeSystem("soulbinds", SOULBIND_LEARN_CONDUIT_TUTORIAL);

	if C_Soulbinds.GetConduitCollectionCount() >= CONDUITS_LEARNED_IN_TUTORIAL then
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_SOULBIND_CONDUIT_LEARN, true);
	end

	self:CheckTutorials();
end

function SoulbindViewerMixin:OnNodeChanged()
	self:UpdateButtons();

	if self.showingEnhancedConduitTutorialNode then
		-- They might have chosen a different path, so re-evaluate
		self:CheckEnhancedConduitTutorial();
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
	local background2 = "Soulbinds_Background_Activate";
	self.Background:SetAtlas(background, true);
	self.Background2:SetAtlas(background2, true);
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
	self:CheckTutorials();

	self:TriggerEvent(SoulbindViewerMixin.Event.OnSoulbindChanged, self.covenantData, soulbindData);

	PlaySound(SOUNDKIT.SOULBINDS_SOULBIND_SELECTED);
end

function SoulbindViewerMixin:OnSoulbindActivated(soulbindID)
	local soulbindData = C_Soulbinds.GetSoulbindData(soulbindID);
	self.Tree:Init(soulbindData);
	self.SelectGroup:Init(self.covenantData, soulbindID);
	self:UpdateButtons();

	if soulbindData.activationSoundKitID then
		PlaySound(soulbindData.activationSoundKitID);
	end
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

	local showTutorial = enabled and not GetCVarBitfield("soulbindsActivatedTutorial", self.soulbindData.cvarIndex) and self.Tree:HasSelectedNodes();
	GlowEmitterFactory:SetShown(self.ActivateSoulbindButton, showTutorial, GlowEmitterMixin.Anims.FadeAnim);
end

function SoulbindViewerMixin:UpdateCommitConduitsButton()
	local pending = C_Soulbinds.HasPendingConduitsInSoulbind(self:GetOpenSoulbindID());
	self.CommitConduitsButton:SetShown(pending);
	GlowEmitterFactory:SetShown(self.CommitConduitsButton, pending, GlowEmitterMixin.Anims.FaintFadeAnim);
end

function SoulbindViewerMixin:HandleEscape()
	local handled = C_Soulbinds.HasAnyPendingConduits();
	if handled then
		self:ShowChangesPendingDialog();
	end
	return handled;
end

function SoulbindViewerMixin:IsActiveSoulbindOpen()
	return C_Soulbinds.GetActiveSoulbindID() == self:GetOpenSoulbindID();
end

function SoulbindViewerMixin:GetOpenSoulbindID()
	return self.soulbindData.ID;
end

function SoulbindViewerMixin:OnActivateSoulbindClicked()
	self.ActivateSoulbindButton:SetEnabled(false);

	local openSoulbindID = self:GetOpenSoulbindID();
	Soulbinds.SetSoulbindIDActivationPending(openSoulbindID);
	self.SelectGroup:OnSoulbindActivated(openSoulbindID);

	C_Soulbinds.ActivateSoulbind(openSoulbindID);

	PlaySound(SOUNDKIT.SOULBINDS_ACTIVATE_SOULBIND);
	
	self.Background2.ActivateAnim:Play();
	self.ActivateFX.ActivateAnim:Play();
	self.ActivateFX2.ActivateAnim:Play();
	self.Fx.ActivateFXLensFlare1.ActivateAnim:Play();
	self.Fx.ActivateFXLensFlare2.ActivateAnim:Play();
	self.Fx.ActivateFXRunes1.ActivateAnim:Play();
	self.Fx.ActivateFXRunes2.ActivateAnim:Play();
	self.Fx.ActivateFXDiamond.ActivateAnim:Play();
	self.Fx.ActivateFXDiamondArrows.ActivateAnim:Play();
	self.Fx.ActivateFXDiamondFlipped.ActivateAnim:Play();
	self.Fx.ActivateFXStarfield.ActivateAnim:Play();
	self.Fx.ActivateFXRingLarge.ActivateAnim:Play();
	self.Fx.ActivateFXRingSmall.ActivateAnim:Play();
	self:Shake();

	self:SetBackgroundStateActive(true);

	if Soulbinds.HasNewSoulbindTutorial(self.soulbindData.ID) then
		GlowEmitterFactory:Hide(self.ActivateSoulbindButton);
	end
	SetCVarBitfield("soulbindsActivatedTutorial", self.soulbindData.cvarIndex, true);
end

function SoulbindViewerMixin:Shake()
	if self:IsShown() then
		local SHAKE = { { x = 0, y = -10}, { x = 0, y = 10}, { x = 0, y = -10}, { x = 0, y = 10}, { x = -6, y = -4}, { x = 4, y = 4}, { x = -2, y = -4}, { x = 6, y = 4}, { x = -4, y = -2}, { x = 2, y = 2}, { x = -2, y = -4}, { x = -2, y = -2}, { x = 4, y = 2}, { x = 4, y = 4}, { x = -4, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 2}, { x = -4, y = -2}, { x = 2, y = 2}, { x = -2, y = -4}, { x = -2, y = -2}, { x = 4, y = 2}, { x = 4, y = 4}, { x = -4, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 2}, { x = -4, y = -2}, { x = 2, y = 2}, { x = -2, y = -4}, { x = -2, y = -2}, { x = 4, y = 2}, { x = 4, y = 4}, { x = -4, y = 4}, { x = 4, y = -4}, { x = -4, y = 2}, { x = -2, y = 2}, { x = -4, y = -2}, { x = 2, y = 2}, { x = -2, y = -4}, { x = -2, y = -2}, { x = 4, y = 2}, { x = 4, y = 4}, { x = -4, y = 4}, { x = 4, y = -4}, { x = -2, y = 1}, { x = -1, y = 1}, { x = -2, y = -1}, { x = 1, y = 1}, { x = -1, y = -2}, { x = -1, y = -1}, { x = 2, y = 1}, { x = 2, y = 2}, { x = -2, y = 2}, { x = 2, y = -2}, { x = -2, y = 1}, { x = -1, y = 1}, { x = -2, y = -1}, { x = 1, y = 1}, { x = -1, y = -2}, { x = -1, y = -1}, { x = 2, y = 1}, { x = 2, y = 2}, { x = -2, y = 2}, { x = 2, y = -2}, { x = -2, y = 1}, { x = -1, y = 1}, };
		local SHAKE_DURATION = 0.1;
		local SHAKE_FREQUENCY = 0.001;
		local SHAKE_DELAY = 0.28;
		C_Timer.After(SHAKE_DELAY,
			function()
				ScriptAnimationUtil.ShakeFrame(UIParent, SHAKE, SHAKE_DURATION, SHAKE_FREQUENCY)
			end
		);
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
	local soulbindID = self:GetOpenSoulbindID();
	local onConfirm = function()
		Soulbinds.SetConduitInstallPending(true);
		C_Soulbinds.CommitPendingConduitsInSoulbind(soulbindID);
		PlaySound(SOUNDKIT.SOULBINDS_COMMIT_CONDUITS);
	end

	local total = C_Soulbinds.GetTotalConduitChargesPendingInSoulbind(soulbindID);
	local iconMarkup = CreateAtlasMarkup("soulbinds_collection_charge_dialog", 12, 12, 0, 0);
	local text = string.format("%s\n\n", CONDUIT_CHARGE_CONFIRM:format(total, iconMarkup));
	StaticPopup_Show("SOULBIND_CONDUIT_INSTALL_CONFIRM", text, nil, onConfirm);
end

function SoulbindViewerMixin:OnCollectionConduitClick(conduitID)
	self.Tree:OnCollectionConduitClick(conduitID);
end

function SoulbindViewerMixin:OnCollectionConduitEnter(conduitType, conduitID)
	self.Tree:OnCollectionConduitEnter(conduitType, conduitID);
end

function SoulbindViewerMixin:OnCollectionConduitLeave()
	self.Tree:OnCollectionConduitLeave();
end

function SoulbindViewerMixin:SetConduitListConduitsPulsePlaying(conduitType, playing)
	self.ConduitList:SetConduitListConduitsPulsePlaying(conduitType, playing);
end

function SoulbindViewerMixin:CheckTutorials()
	-- Keep ordered.
	if self:CheckPathSelectionTutorial() then
	elseif self:CheckConduitLearnTutorial() then
	elseif self:CheckConduitInstallTutorial() then
	else
		self:CheckEnhancedConduitTutorial();
	end
end

function SoulbindViewerMixin:CheckPathSelectionTutorial()
	if GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_SOULBIND_PATH_SELECT) then
		return false;
	end

	local selectableTutorialNode = nil;
	for _, nodeFrame in pairs(self.Tree:GetNodes()) do
		if nodeFrame:GetRow() == 1 and nodeFrame:IsSelectable() then
			if not selectableTutorialNode or (nodeFrame:GetColumn() < selectableTutorialNode:GetColumn()) then
				selectableTutorialNode = nodeFrame;
			end
		end
	end

	if selectableTutorialNode then
		local helpTipInfo = {
			text = SOULBIND_SELECT_PATH_TUTORIAL_TEXT,
			buttonStyle = HelpTip.ButtonStyle.None,
			targetPoint = HelpTip.Point.LeftEdgeCenter,
			offsetX = -10,
			system = "soulbinds";
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_SOULBIND_PATH_SELECT,
		};

		HelpTip:Show(selectableTutorialNode, helpTipInfo)
		return true;
	end
	return false;
end

function SoulbindViewerMixin:CheckConduitLearnTutorial()
	if GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_SOULBIND_CONDUIT_LEARN) then
		return false;
	end

   	if IsAnyBagOpen() and C_Soulbinds.GetConduitCollectionCount() < CONDUITS_LEARNED_IN_TUTORIAL then
   		local itemButton, itemLocation = ContainerFrameUtil_FindFirstItemButtonAndItemLocation(function(itemLocation)
			if self.helpTipItemLocation and self.helpTipItemLocation:IsEqualTo(itemLocation) then
				return false;
			end
			return C_Item.IsItemConduit(itemLocation);
   		end);

   		if itemButton then
   			local helpTipInfo = {
   				text = SOULBIND_LEARN_CONDUIT_TUTORIAL,
   				buttonStyle = HelpTip.ButtonStyle.None,
   				targetPoint = HelpTip.Point.LeftEdgeCenter,
				system = "soulbinds",
   			};

			self.helpTipItemLocation = itemLocation;
			
			if HelpTip:IsShowingAnyInSystem("soulbinds", SOULBIND_LEARN_CONDUIT_TUTORIAL) then
				HelpTip:HideAllSystem("soulbinds", SOULBIND_LEARN_CONDUIT_TUTORIAL);
			end

   			HelpTip:Show(itemButton, helpTipInfo);
			return true;
   		end
   	end
	return false;
end

function SoulbindViewerMixin:CheckConduitInstallTutorial()
	if GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_SOULBIND_CONDUIT_INSTALL) then
		return false;
	end

	if C_Soulbinds.GetConduitCollectionCount() >= CONDUITS_LEARNED_IN_TUTORIAL then
		return false;
	end

	local _, conduitTutorialNode = FindInTableIf(self.Tree:GetNodes(), function(nodeFrame)
		return nodeFrame:GetRow() == 1 and nodeFrame:IsSelected();
	end);

	if conduitTutorialNode then
		-- HelpTip needs to be aligned with the conduit list matching the conduit type of the
		-- selected node. We can't display HelpTip on this list because it would become a layout
		-- frame child. Instead, reposition it to be aligned with the list using an offset.
		local conduitType = conduitTutorialNode:GetConduitType();
		local listSection = self.ConduitList:FindListSection(conduitType);
		if listSection and listSection:IsShown() then
			local helpTipInfo = {
				text = SOULBIND_SLOT_CONDUIT_TUTORIAL_TEXT,
				buttonStyle = HelpTip.ButtonStyle.None,
				targetPoint = HelpTip.Point.RightEdgeTop,
				cvarBitfield = "closedInfoFrames",
				bitfieldFlag = LE_FRAME_TUTORIAL_SOULBIND_CONDUIT_INSTALL,
				offsetY = -60,
				system = "soulbinds",
			};

			HelpTip:Show(self.ConduitList, helpTipInfo, listSection);
			return true;
		end
	end
	
	return false;
end

function SoulbindViewerMixin:CheckEnhancedConduitTutorial()
	if GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_SOULBIND_ENHANCED_CONDUIT) then
		return false;
	end

	if self.showingEnhancedConduitTutorialNode then
		HelpTip:Hide(self.showingEnhancedConduitTutorialNode, SOULBIND_ENHANCED_CONDUIT_TUTORIAL);
		self.showingEnhancedConduitTutorialNode = nil;
	end

	local enhancedConduitTutorialNode;
	local numColumnsInTutorialRow = 0;
	for _, nodeFrame in pairs(self.Tree:GetNodes()) do
		if nodeFrame:IsConduit() and nodeFrame:IsEnhanced() and not nodeFrame:IsUnavailable() then
			if enhancedConduitTutorialNode and (nodeFrame:GetRow() > enhancedConduitTutorialNode:GetRow()) then
				-- This is an enhanced node but we already found one in a lower row, just move on
			else
				local isNewBest =	not enhancedConduitTutorialNode or 
									(nodeFrame:GetRow() < enhancedConduitTutorialNode:GetRow()) or
									(nodeFrame:IsSelected() and not enhancedConduitTutorialNode:IsSelected()) or
									(nodeFrame:GetColumn() < enhancedConduitTutorialNode:GetColumn());

				if isNewBest then
					if enhancedConduitTutorialNode and (nodeFrame:GetRow() < enhancedConduitTutorialNode:GetRow()) then
						-- Found one in a lower row, reset numColumnsInTutorialRow
						numColumnsInTutorialRow = 0;
					end

					enhancedConduitTutorialNode = nodeFrame;
					numColumnsInTutorialRow = numColumnsInTutorialRow + 1;
				end
			end
		end
	end

	if enhancedConduitTutorialNode then
		local alignedRight = (enhancedConduitTutorialNode:GetColumn() == numColumnsInTutorialRow);

		local helpTipInfo = {
			text = SOULBIND_ENHANCED_CONDUIT_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = alignedRight and HelpTip.Point.RightEdgeCenter or HelpTip.Point.LeftEdgeCenter,
			offsetX = alignedRight and 10 or -10,
			system = "soulbinds";
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_SOULBIND_ENHANCED_CONDUIT,
		};

		HelpTip:Show(enhancedConduitTutorialNode, helpTipInfo);
		self.showingEnhancedConduitTutorialNode = enhancedConduitTutorialNode;
		return true;
	end

	return false;
end

StaticPopupDialogs["SOULBIND_CONDUIT_NO_CHANGES_CONFIRMATION"] = {
	text = CONDUIT_NO_CHANGES_CONFIRMATION,
	button1 = LEAVE,
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
	text = "%s",
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
