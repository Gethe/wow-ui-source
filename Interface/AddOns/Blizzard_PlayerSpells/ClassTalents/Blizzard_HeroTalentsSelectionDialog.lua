HeroTalentsSelectionMixin = {};

function HeroTalentsSelectionMixin:OnLoad()
	self.SpecContentFramePool = CreateFramePool("FRAME", self.SpecOptionsContainer, "HeroTalentSpecContentTemplate", HeroTalentSpecContentMixin.Reset);

	local width, height = self.SpecOptionsContainer:GetSize();
	self.SpecOptionsContainer:SetFixedSize(width, height);

	self.CoverFrame:SetScript("OnClick", GenerateClosure(self.OnCoverFrameClicked, self));
end

function HeroTalentsSelectionMixin:IsActive()
	return self:IsShown() and self:HasData();
end

function HeroTalentsSelectionMixin:HasData()
	return self.subTreeIDs and self.specFramesBySubTreeID and self.subTreeSelectionNodeInfo;
end

function HeroTalentsSelectionMixin:IsVisibleSubTreeOption(subTreeID)
	return self:IsActive() and self.specFramesBySubTreeID[subTreeID] ~= nil;
end

function HeroTalentsSelectionMixin:SetTalentFrame(talentFrame)
	self.talentFrame = talentFrame;
end

function HeroTalentsSelectionMixin:GetTalentFrame()
	return self.talentFrame;
end

function HeroTalentsSelectionMixin:OnShow()
	self:RegisterEvent("TRAIT_SUB_TREE_CHANGED");
	-- We don't want this dialog to be a UIParent managed panel as it's not an "exclusive" frame we want displayed as part of its panel/screen area management flow
	-- We also don't want to parent it to the ClassTalents/PlayerSpells frame because inheriting its "checkFit" scale would force this dialog to be much smaller than necessary at smaller resolutions
	-- So, to still ensure it fits well on the screen at different screen sizes, just manually calling UIPanelUpdateScaleForFit
	UIPanelUpdateScaleForFit(self, self.checkFitExtraWidth, self.checkFitExtraHeight);
	
	self.DisabledOverlay:Hide();

	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
end

function HeroTalentsSelectionMixin:OnHide()
	self:UnregisterEvent("TRAIT_SUB_TREE_CHANGED");

	self.subTreeIDs = nil;
	self.specFramesBySubTreeID = nil;
	self.selectedSubTreeID = nil;
	self.subTreeActivatedByNextCommitComplete = nil;
	if self.onDialogCloseCallback then
		self.onDialogCloseCallback();
	end
	self.onDialogCloseCallback = nil;
	self.SpecContentFramePool:ReleaseAll();

	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
end

function HeroTalentsSelectionMixin:OnEvent(event, ...)
	if event == "TRAIT_SUB_TREE_CHANGED" then
		local subTreeID = ...;
		-- If the just-selected SubTree has just been activated, play visuals
		if subTreeID and self.selectedSubTreeID == subTreeID then
			local talentFrame = self:GetTalentFrame();

			local anyChangesPending, canApplyChanges = talentFrame:GetConfigApplicationState();
			if anyChangesPending and canApplyChanges then
				-- If we're in a valid state where we can now commit all pending Talent changes, 
				-- automatically kick that off to avoid having to press another button after activating a spec
				-- and avoid playing/updating activation visuals until after the commit attempt ends (succesfully or otherwise)
				talentFrame:ApplyConfig();
			else
				-- Otherwise just show the visuals now as this remains as a pending activation
				self.selectedSubTreeID = nil;
				self.subTreeActivatedByNextCommitComplete = nil;
				self:UpdateActiveHeroSpec();
				self:PlayActivationFlash(subTreeID);
			end
		end
	end
end

-- Activating a SubTree (Hero Talent Spec) works by choosing an entry in a SubTreeSelectionNode under the hood (that's how it can be saved in things like loadouts)
-- As such, this dialog presents the SubTree options defined by a specific SubTreeSelectionNode's entries
function HeroTalentsSelectionMixin:ShowDialog(subTreeSelectionNodeInfo, onDialogCloseCallback)
	self.subTreeSelectionNodeInfo = subTreeSelectionNodeInfo;
	self.subTreeIDs = {};
	self.specFramesBySubTreeID = {};
	self.onDialogCloseCallback = onDialogCloseCallback;

	if self.subTreeSelectionNodeInfo == nil then
		self:Hide();
		return;
	end

	local talentFrame = self:GetTalentFrame();

	-- Get the subTree options as defined by the node's entries
	self.subTreeIDs = TalentFrameUtil.GetSubTreesIDsFromSubTreeSelectionNode(talentFrame, self.subTreeSelectionNodeInfo);

	local numHeroSpecs = #self.subTreeIDs;

	if numHeroSpecs == 0 then
		self:Hide();
		return;
	end

	local specContentWidth = self.SpecOptionsContainer:GetWidth() / numHeroSpecs;
	
	-- For each SubTree, instantiate a frame to present that SubTree as an option
	for index, subTreeID in ipairs(self.subTreeIDs) do
		local specFrame = self.SpecContentFramePool:Acquire();
		self.specFramesBySubTreeID[subTreeID] = specFrame;
		specFrame:Setup(subTreeID, index, numHeroSpecs, specContentWidth);
		specFrame:Show();
	end

	-- Place all subTree nodes into their proper spec frames
	for talentButton in talentFrame:EnumerateAllTalentButtons() do
		self:PlaceHeroTalentButton(talentButton);
	end

	-- Mark the right Spec as the active one (if any)
	self:UpdateActiveHeroSpec();

	self.SpecOptionsContainer:Layout();

	self:Show();
end

function HeroTalentsSelectionMixin:PlaceHeroTalentButton(talentButton)
	-- Don't check IsActive here because the first time it gets called is before we call Show
	if not self:HasData() then
		return;
	end

	local nodeInfo = talentButton:GetNodeInfo();
	-- If node is a subTree node, and its SubTree is one we're presenting an option frame for, place that node in that frame
	if nodeInfo.subTreeID and self.specFramesBySubTreeID[nodeInfo.subTreeID] then
		self.specFramesBySubTreeID[nodeInfo.subTreeID]:PlaceHeroTalentButton(talentButton, nodeInfo);
		return true;
	end

	return false;
end

function HeroTalentsSelectionMixin:UpdateActiveHeroSpec()
	-- Don't check IsActive here because the first time it gets called is before we call Show
	if not self:HasData() then
		return;
	end

	local talentFrame = self:GetTalentFrame();

	-- Refresh node info to ensure we have the most up-to-date activeEntry
	self.subTreeSelectionNodeInfo = talentFrame:GetAndCacheNodeInfo(self.subTreeSelectionNodeInfo.ID);

	local activeSubTreeID = TalentFrameUtil.GetActiveSubTreeFromSubTreeSelectionNode(talentFrame, self.subTreeSelectionNodeInfo);

	-- If the active subTree is the one that was just selected, don't update visuals yet as we want to delay that until after trying to auto-apply the activation
	if self.selectedSubTreeID and activeSubTreeID == self.selectedSubTreeID then
		return;
	end

	self.selectedSubTreeID = nil;

	local isAnySpecActive = activeSubTreeID ~= nil;

	for subTreeID, specFrame in pairs(self.specFramesBySubTreeID) do
		specFrame:SetIsActive(subTreeID == activeSubTreeID);
		specFrame:SetIsAnySpecActive(isAnySpecActive);
	end
end

function HeroTalentsSelectionMixin:UpdateCurrencies()
	if not self:IsActive() then
		return;
	end

	for _, specFrame in pairs(self.specFramesBySubTreeID) do
		specFrame:UpdateCurrency();
	end
end

function HeroTalentsSelectionMixin:UpdateApplyButtons(anyChangesPending, canApplyChanges)
	if not self:IsActive() then
		return false;
	end

	-- We only want to show the duplicate "Apply Changes" button here if there's appliable pending Hero Talent changes
	local anyApplyableHeroTalentChanges = anyChangesPending and canApplyChanges and self:AnyPendingHeroTalentCosts();

	local anyApplyButtonsShowing = false;
	for subTreeID, specFrame in pairs(self.specFramesBySubTreeID) do
		anyApplyButtonsShowing = specFrame:UpdateApplyButton(anyApplyableHeroTalentChanges) or anyApplyButtonsShowing;
	end

	return anyApplyButtonsShowing;
end

function HeroTalentsSelectionMixin:UpdateActivateButtons()
	if not self:IsActive() then
		return false;
	end

	local isLocked, errorMessage = self:GetTalentFrame():IsLocked();

	for subTreeID, specFrame in pairs(self.specFramesBySubTreeID) do
		specFrame:UpdateActivateButtonState(isLocked, errorMessage);
	end
end

function HeroTalentsSelectionMixin:SetCommitVisualsActive(active)
	if not self:IsActive() then
		return;
	end

	self.DisabledOverlay:SetShown(active);

	if not active and self.selectedSubTreeID then
		-- Commit visuals have ended, so the auto-apply either succeeded or failed
		-- Cache the committed SubTree so we can show its activation visuals if we're succesfully told to show commit visuals
		self.subTreeActivatedByNextCommitComplete = self.selectedSubTreeID;
		-- But also clear the cached selected SubTree so we know we're no longer waiting to start committing it
		self.selectedSubTreeID = nil;
		-- Update visuals to highlight which is the active hero spec
		-- If commit succeeded, CommitComplete visuals should play this exact same frame so it's okay to do this now
		-- If commit failed, CommitComplete visuals won't happen, meaning we do need to ensure we reflect the current staged talent state
		self:UpdateActiveHeroSpec();
	end
end

function HeroTalentsSelectionMixin:SetCommitCompleteVisualsActive(active)
	if not self:IsActive() then
		return;
	end

	if self.subTreeActivatedByNextCommitComplete then
		if active then
			self:PlayActivationFlash(self.subTreeActivatedByNextCommitComplete);
		end
		self.subTreeActivatedByNextCommitComplete = nil;
	end
end

function HeroTalentsSelectionMixin:OnApplyChangesButtonClicked()
	if not self:IsActive() then
		return;
	end

	self:GetTalentFrame():ApplyConfig();
end

function HeroTalentsSelectionMixin:OnHeroSpecSelected(specFrame)
	if not self:IsActive() then
		return;
	end

	local talentFrame = self:GetTalentFrame();

	local selectedSubTreeID = specFrame:GetSubTreeID();
	local selectedEntryID = nil;
	for _, entryID in ipairs(self.subTreeSelectionNodeInfo.entryIDs) do
		local entryInfo = talentFrame:GetAndCacheEntryInfo(entryID);
		if entryInfo.subTreeID == selectedSubTreeID then
			selectedEntryID = entryID;
			break;
		end
	end

	if not selectedEntryID then
		return;
	end

	-- Cache which subTree was selected, so that we can flash that frame if/when we receive a corresponding TRAIT_SUB_TREE_CHANGED event for it
	self.selectedSubTreeID = selectedSubTreeID;
	self.subTreeActivatedByNextCommitComplete = nil;
	talentFrame:SetSelection(self.subTreeSelectionNodeInfo.ID, selectedEntryID);
end

function HeroTalentsSelectionMixin:PlayActivationFlash(subTreeID)
	if not self:IsActive() then
		return;
	end

	local activatedFrame = self.specFramesBySubTreeID[subTreeID];
	if activatedFrame then
		activatedFrame:SetActivationFlashPlaying(true);
	end
end

function HeroTalentsSelectionMixin:OnKeyDown(key)
	-- Only intercept the keybind to close the window (so that the Talent frame doesn't get it and close itself instead)
	if GetBindingFromClick(key) == "TOGGLEGAMEMENU" then
		self:Hide();
		self:SetPropagateKeyboardInput(false);
	-- Otherwise let whatever the key was propagate to other listeners
	else
		self:SetPropagateKeyboardInput(true);
	end
end

function HeroTalentsSelectionMixin:OnCoverFrameClicked()
	self:Hide();
end

function HeroTalentsSelectionMixin:AnyPendingHeroTalentCosts()
	local talentFrame = self:GetTalentFrame();

	-- First try a shortcut route of checking whether any change costs involve SubTree currencies
	local stagedCosts = C_Traits.GetStagedChangesCost(talentFrame:GetConfigID());
	if stagedCosts and #stagedCosts > 0 then
		local stagedCostIDs = {};
		-- Make a map of which currencies are involved in pending changes
		for _, cost in ipairs(stagedCosts) do
			if cost.amount and cost.amount ~= 0 then
				stagedCostIDs[cost.ID] = true;
			end
		end

		-- If any of the currencies belongs to a SubTree being displayed, we can assume one of the pending changes involves Hero Talents
		for _, subTreeID in ipairs(self.subTreeIDs) do
			local subTreeCurrencyID = TalentFrameUtil.GetSubTreeCurrencyID(talentFrame, subTreeID);
			if subTreeCurrencyID and stagedCostIDs[subTreeCurrencyID] then
				return true;
			end
		end
	end

	-- No SubTree currency changes have been staged, so comb through nodes with staged changes and look for any SubTree or SubTreeSelection nodes we care about
	local nodesWithPurchases, nodesWithRefunds, nodesWithSelectionSwaps = C_Traits.GetStagedChanges(talentFrame:GetConfigID());
	local allNodesWithChanges = nodesWithPurchases or {};
	if nodesWithRefunds and #nodesWithRefunds > 0 then
		tAppendAll(allNodesWithChanges, nodesWithRefunds);
	end
	if nodesWithSelectionSwaps and #nodesWithSelectionSwaps > 0 then
		tAppendAll(allNodesWithChanges, nodesWithSelectionSwaps);
	end

	if not allNodesWithChanges or #allNodesWithChanges == 0 then
		return false;
	end

	local subTreesMap = tInvert(self.subTreeIDs);

	for _, nodeID in ipairs(allNodesWithChanges) do
		-- This node is the SubTreeSelection node we care about
		if self.subTreeSelectionNodeInfo and nodeID == self.subTreeSelectionNodeInfo.ID then
			return true;
		end

		local nodeInfo = talentFrame:GetAndCacheNodeInfo(nodeID);
		-- This node belongs to a SubTree we care about
		if nodeInfo and nodeInfo.subTreeID and subTreesMap[nodeInfo.subTreeID]  then
			return true;
		end
	end

	return false;
end



HeroTalentSpecContentMixin = {};

function HeroTalentSpecContentMixin:OnLoad()
	self.ActivateButton:SetScript("OnClick", GenerateClosure(self.OnActivateClicked, self));
	self.ActivationFlash:SetScript("OnFinished", GenerateClosure(self.OnActivationFlashFinished, self));
	self.ApplyChangesButton:SetScript("OnClick", GenerateClosure(self.OnApplyChangesButtonClicked, self));
end

function HeroTalentSpecContentMixin.Reset(framePool, self)
	if self.playingActivationFlash then
		self:SetActivationFlashPlaying(false);
	end

	Pool_HideAndClearAnchors(framePool, self);

	self.subTreeID = nil;
	self.layoutIndex = nil;
	self.isLeftMostSpec = nil;
	self.isRightMostSpec = nil;
	self.isActiveSpec = nil;
	self.anyApplyableHeroTalentChanges = nil;
end

function HeroTalentSpecContentMixin:Setup(subTreeID, index, numSpecs, specContentWidth)
	self.subTreeID = subTreeID;
	self.layoutIndex = index;
	self.isLeftMostSpec = index == 1;
	self.isRightMostSpec = index == numSpecs;

	local talentFrame = self:GetTalentFrame();

	self.subTreeInfo = talentFrame:GetAndCacheSubTreeInfo(self.subTreeID);

	self:SetWidth(specContentWidth);

	-- Populate spec info
	self.name = self.subTreeInfo.name;
	self.SpecImage:SetAtlas(self.subTreeInfo.iconElementID);
	self.SpecName:SetText(string.upper(self.subTreeInfo.name));
	self.Description:SetText(self.subTreeInfo.description);

	self.ColumnDivider:SetShown(not self.isRightMostSpec)

	self:UpdateCurrency();
end

function HeroTalentSpecContentMixin:UpdateCurrency()
	-- Don't show points available until the player has picked a spec and we have this spec's info available.
	local currencyAvailable = self.isAnySpecActive and self.subTreeInfo and TalentFrameUtil.GetSubTreeCurrencyAvailable(self:GetTalentFrame(), self.subTreeInfo.ID) or 0;

	if currencyAvailable > 0 then
		self.CurrencyFrame.AmountText:SetText(HERO_TALENTS_POINTS_AMOUNT:format(currencyAvailable));
		self.CurrencyFrame:Show();
	else
		self.CurrencyFrame.AmountText:SetText("");
		self.CurrencyFrame:Hide();
	end

	self:CheckTutorials();
end

function HeroTalentSpecContentMixin:PlaceHeroTalentButton(talentButton, nodeInfo)
	-- Button is already placed, skip placing it again
	if talentButton:GetParent() == self.NodesContainer then
		return;
	end

	local talentFrame = self:GetTalentFrame();

	local tPosX, tPosY = TalentFrameUtil.GetNormalizedSubTreeNodePosition(talentFrame, nodeInfo);

	talentButton:ClearAllPoints();

	talentButton:SetParent(self.NodesContainer);
	talentFrame:UpdateButtonFrameLevel(talentButton);
	-- If button switches parent, ensure its edges get updated to accomodate
	talentFrame:MarkEdgesDirty(talentButton);

	-- Set initial point, which will then be adjusted to the right offset
	talentButton:SetPoint("TOP", self.NodesContainer);
	local offsetX, offsetY = 0, 0;
	TalentButtonUtil.ApplyPositionAtOffset(talentButton, tPosX, tPosY, offsetX, offsetY);
	talentButton:Show();
end

function HeroTalentSpecContentMixin:UpdateApplyButton(anyApplyableHeroTalentChanges)
	self.anyApplyableHeroTalentChanges = anyApplyableHeroTalentChanges;
	local shouldShowApplyButton = self.isActiveSpec and anyApplyableHeroTalentChanges;

	self.ApplyChangesButton:SetEnabled(anyApplyableHeroTalentChanges);
	self.ApplyChangesButton:SetShown(shouldShowApplyButton);
	self.ActivatedText:SetShown(self.isActiveSpec and not shouldShowApplyButton);

	-- Since we only show this Apply button in a valid, appliable state, it should always come with the green "ready to apply" glow
	if shouldShowApplyButton then
		GlowEmitterFactory:Show(self.ApplyChangesButton, GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow);
	else
		GlowEmitterFactory:Hide(self.ApplyChangesButton);
	end

	return shouldShowApplyButton;
end

function HeroTalentSpecContentMixin:UpdateActivateButtonState(isLocked, errorMessage)
	self.ActivateButton:UpdateState(isLocked, errorMessage);
end

function HeroTalentSpecContentMixin:SetIsActive(isActiveSpec)
	if self.isActiveSpec == isActiveSpec then
		return;
	end

	self.isActiveSpec = isActiveSpec;

	if self.isActiveSpec then
		self.ActivateButton:Hide();
		self.CurrencyFrame.AmountText:SetTextColor(GREEN_FONT_COLOR:GetRGB());
		self.CurrencyFrame.LabelText:SetTextColor(WHITE_FONT_COLOR:GetRGB());
		self.SpecImageBorderSelected:Show();
		self.SpecImageBorder:Hide();

		MixinUtil.CallMethodOnAllSafe(self.ActivatedBackFrames, "Show");
		MixinUtil.CallMethodOnAllSafe(self.ActivatedLeftFrames, "SetShown", not self.isLeftMostSpec);
		MixinUtil.CallMethodOnAllSafe(self.ActivatedRightFrames, "SetShown", not self.isRightMostSpec);
	else
		self.ActivateButton:Show();
		self.CurrencyFrame.AmountText:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		self.CurrencyFrame.LabelText:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		self.SpecImageBorderSelected:Hide();
		self.SpecImageBorder:Show();

		MixinUtil.CallMethodOnAllSafe(self.ActivatedBackFrames, "Hide");
		MixinUtil.CallMethodOnAllSafe(self.ActivatedLeftFrames, "Hide");
		MixinUtil.CallMethodOnAllSafe(self.ActivatedRightFrames, "Hide");
	end

	self:UpdateApplyButton(self.anyApplyableHeroTalentChanges);

	self:CheckTutorials();
end

function HeroTalentSpecContentMixin:SetIsAnySpecActive(isAnySpecActive)
	if self.isAnySpecActive == isAnySpecActive then
		return;
	end

	self.isAnySpecActive = isAnySpecActive;

	-- Show a green glow around the Activate button until the player picks a spec.
	if self.isAnySpecActive then
		GlowEmitterFactory:Hide(self.ActivateButton);
	else
		GlowEmitterFactory:Show(self.ActivateButton, GlowEmitterMixin.Anims.NPE_RedButton_GreenGlow);
	end

	-- Update currency frame as it should be hidden if no spec has been chosen yet
	self:UpdateCurrency();
end

function HeroTalentSpecContentMixin:SetActivationFlashPlaying(playFlash)
	if playFlash == self.playingActivationFlash then
		return;
	end

	if playFlash then
		self.ActivationFlash:Restart();
		self.playingActivationFlash = true;

		PlaySound(SOUNDKIT.UI_HERO_TALENT_SPEC_ACTIVATE);
	else
		self.ActivationFlash:Stop();
		self.playingActivationFlash = false;
	end
end

function HeroTalentSpecContentMixin:OnActivationFlashFinished()
	self.playingActivationFlash = false;
end

function HeroTalentSpecContentMixin:GetSubTreeID()
	return self.subTreeID;
end

function HeroTalentSpecContentMixin:OnActivateClicked()
	self:GetSelectionFrame():OnHeroSpecSelected(self);
end

function HeroTalentSpecContentMixin:OnApplyChangesButtonClicked()
	self:GetSelectionFrame():OnApplyChangesButtonClicked(self);
end

function HeroTalentSpecContentMixin:OnHide()
	if self.playingActivationFlash then
		self:SetActivationFlashPlaying(false);
	end
end

function HeroTalentSpecContentMixin:GetSelectionFrame()
	return self:GetParent():GetParent();
end

function HeroTalentSpecContentMixin:GetTalentFrame()
	return self:GetSelectionFrame():GetTalentFrame();
end

function HeroTalentSpecContentMixin:CheckTutorials()
	self:GetTalentFrame():CheckHeroTalentTutorial(self.subTreeInfo, self.helpTipOffsetX, self.helpTipOffsetY, self, self.NodesContainer);
end

HeroTalentActivateButtonMixin = {};

function HeroTalentActivateButtonMixin:UpdateState(isLocked, errorMessage)
	self:SetEnabled(not isLocked);
	self.errorMessage = errorMessage;
end

function HeroTalentActivateButtonMixin:OnMouseEnter()
	local tooltip = GetAppropriateTooltip();

	if not self:IsEnabled() and self.errorMessage then
		GameTooltip_ShowDisabledTooltip(tooltip, self, self.errorMessage, "ANCHOR_RIGHT");
	else
		tooltip:Hide();
	end
end

function HeroTalentActivateButtonMixin:OnMouseLeave()
	local tooltip = GetAppropriateTooltip();
	tooltip:Hide();
end
