-- Note: Currently, nothing about this thing supports panning, so if we ever enable panning in the Class Talents frame, work will be needed to move this accordingly
HeroTalentsContainerMixin = {};

function HeroTalentsContainerMixin:Init(talentFrame, specSelectionDialog)
	self.talentFrame = talentFrame;
	self.specSelectionDialog = specSelectionDialog;
	
	self.activeSubTreeInfo = nil;
	self.activeSubTreeSelectionNodeInfo = nil;
	self.isExpanded = nil;
	
	self.specSelectionDialog:SetTalentFrame(talentFrame);

	local initialIsExpanded = true;
	self:SetExpanded(initialIsExpanded);

	self:MarkHeroTalentUIDirty();
end

function HeroTalentsContainerMixin:OnHide()
	-- If we hide (ie because the TalentFrame is being closed) make sure the Selection dialog also hides
	if self.specSelectionDialog:IsActive() then
		self.specSelectionDialog:Hide();
	end
end

function HeroTalentsContainerMixin:IsPreviewingSubTree(subTreeID)
	return self.specSelectionDialog:IsVisibleSubTreeOption(subTreeID);
end

function HeroTalentsContainerMixin:IsDisplayingActiveHeroSpec()
	return self.activeSubTreeInfo ~= nil;
end

function HeroTalentsContainerMixin:IsHeroSpecActive(subTreeID)
	if not self.activeSubTreeInfo then
		return false;
	end

	return subTreeID == self.activeSubTreeInfo.ID;
end

function HeroTalentsContainerMixin:IsDisplayingHeroSpecChoices()
	return not self:IsDisplayingActiveHeroSpec() and not self:IsInspecting() and self.activeSubTreeSelectionNodeInfo ~= nil;
end

function HeroTalentsContainerMixin:IsDisplayingPreviewSpecs()
	return not self:IsDisplayingActiveHeroSpec() and not self:IsDisplayingHeroSpecChoices() and not self:IsInspecting()
			and self.areHeroSpecsPreviewable and self.availableHeroSpecSubTreeIDs and #self.availableHeroSpecSubTreeIDs > 0;
end

function HeroTalentsContainerMixin:HasAnythingToDisplay()
	return self:IsDisplayingActiveHeroSpec() or self:IsDisplayingHeroSpecChoices() or self:IsDisplayingPreviewSpecs();
end

function HeroTalentsContainerMixin:ShouldAllowCollapsing()
	return self:IsDisplayingActiveHeroSpec() and not self:IsInspecting() and not self.CurrencyFrame:IsShown();
end

function HeroTalentsContainerMixin:MarkHeroTalentUIDirty()
	self.heroTalentUIDirty = true;
end

function HeroTalentsContainerMixin:MarkHeroTalentUIClean()
	self.heroTalentUIDirty = false;
end

function HeroTalentsContainerMixin:IsHeroTalentUIDirty()
	return self.heroTalentUIDirty;
end

-- Check Hero Talent info for changes, and update UI as needed
function HeroTalentsContainerMixin:UpdateHeroTalentInfo()
	self:UpdateAvailableHeroSpecs();
	local anySelectionNodeChanges = self:UpdateActiveHeroSpecSelectionNode();
	self:UpdateActiveHeroSpec();
	self:UpdateHeroSpecPreviewInfo();

	if self:IsHeroTalentUIDirty() then
		self:UpdateHeroTalentUI();

		if self.specSelectionDialog:IsActive() then
			if anySelectionNodeChanges then
				-- If the available SubTreeSelection node has changed, close the selection dialog
				self.specSelectionDialog:Hide();
			else
				-- Otherwise just ensure it updates which Spec option is active
				self.specSelectionDialog:UpdateActiveHeroSpec();
			end
		end
	end
end

-- Update the SubTreeIDs for the Hero Specs available to the currently viewed Class Specialization and Config
function HeroTalentsContainerMixin:UpdateAvailableHeroSpecs()
	local talentFrame = self:GetTalentFrame();

	-- Important to get this info from the Talent Frame so we match up with what it's displaying (esp in the case of Inspecting another player)
	local configID = talentFrame:GetConfigID();
	local specID = talentFrame:GetSpecID();

	local subTreeIDs, requiredPlayerLevel = C_ClassTalents.GetHeroTalentSpecsForClassSpec(configID, specID);
	if self.heroSpecsRequiredLevel ~= requiredPlayerLevel then
		self.heroSpecsRequiredLevel = requiredPlayerLevel;
		self:MarkHeroTalentUIDirty();
	end

	if self.availableHeroSpecSubTreeIDs ~= subTreeIDs then
		local comparableOldSubTrees = self.availableHeroSpecSubTreeIDs and tInvert(self.availableHeroSpecSubTreeIDs) or {};
		local comparableNewSubTrees = subTreeIDs and tInvert(subTreeIDs) or {};

		if not TableUtil.ContainsAllKeys(comparableOldSubTrees, comparableNewSubTrees) then
			self.availableHeroSpecSubTreeIDs = subTreeIDs;
			self:MarkHeroTalentUIDirty();
		end
	end
end

-- Updates the first available SubTreeSelection node; Returns true if the node has changed since last update
function HeroTalentsContainerMixin:UpdateActiveHeroSpecSelectionNode()
	local talentFrame = self:GetTalentFrame();

	local availableSubTreeSelectionNodeInfo = TalentFrameUtil.GetFirstAvailableSubTreeSelectionNode(talentFrame, self.availableHeroSpecSubTreeIDs);
	
	-- Check the node ids as that will tell us whether a completely different (or no) selection node is now the one to use
	local oldSelectionNodeID = self.activeSubTreeSelectionNodeInfo and self.activeSubTreeSelectionNodeInfo.ID or nil;
	local newSelectionNodeID = availableSubTreeSelectionNodeInfo and availableSubTreeSelectionNodeInfo.ID or nil;

	if oldSelectionNodeID == newSelectionNodeID then
		return false;
	end

	self.activeSubTreeSelectionNodeInfo = availableSubTreeSelectionNodeInfo;
	self:MarkHeroTalentUIDirty();

	return true;
end

-- Updates which Hero Spec is active, if any
function HeroTalentsContainerMixin:UpdateActiveHeroSpec()
	local activeSubTreeInfo = nil;

	-- Currently, you can only activate a SubTree via a SubTreeSelection Node
	-- If we don't have an active/visible one, we shouldn't have an active SubTree, and if we do, we're in a weird unexpected state and shouldn't show it
	-- (This should only really occur due to debug commands)
	if self.activeSubTreeSelectionNodeInfo then
		activeSubTreeInfo = TalentFrameUtil.GetFirstActiveSubTree(self:GetTalentFrame(), self.availableHeroSpecSubTreeIDs);
	end

	if activeSubTreeInfo == self.activeSubTreeInfo then
		return;
	end

	self.activeSubTreeInfo = activeSubTreeInfo;
	self:MarkHeroTalentUIDirty();
end

-- Updates the subTrees that will eventually be available to the player to activate
function HeroTalentsContainerMixin:UpdateHeroSpecPreviewInfo()
	local areHeroSpecsPreviewable = false;

	-- No need to preview if inspecting another player, or if specs are already unlocked
	if not self:IsInspecting() and not self:IsDisplayingActiveHeroSpec() and not self:IsDisplayingHeroSpecChoices() then
		-- Currently, Hero Specs only show up as a locked preview at one level below the required player level
		areHeroSpecsPreviewable = self.heroSpecsRequiredLevel and UnitLevel("player") == self.heroSpecsRequiredLevel - 1;
	end

	if self.areHeroSpecsPreviewable == areHeroSpecsPreviewable then
		return;
	end

	self.areHeroSpecsPreviewable = areHeroSpecsPreviewable;

	self:MarkHeroTalentUIDirty();
end

function HeroTalentsContainerMixin:UpdateHeroTalentUI()
	local shouldDisplay = self:HasAnythingToDisplay();

	self:UpdateHeroSpecButton();

	local skipCheckingExpandState = true;
	self:UpdateHeroTalentCurrency(skipCheckingExpandState);

	if shouldDisplay and not self.isExpanded and not self:ShouldAllowCollapsing() then
		-- If we're collapsed, and we shouldn't be, force expand which will update containers
		self:SetExpanded(true);
	else
		-- Otherwise just update containers as normal
		self:UpdateContainerVisibility();
	end

	self:UpdateHeroTalentsUnlockedAnim();

	self:MarkHeroTalentUIClean();

	self:SetShown(shouldDisplay);
end

function HeroTalentsContainerMixin:UpdateHeroSpecButton()
	local subTreeIDs = {};
	local isLocked = false;

	if self:IsDisplayingActiveHeroSpec() then
		-- One Active SubTree
		table.insert(subTreeIDs, self.activeSubTreeInfo.ID);

		self.HeroSpecLabel:SetText(string.upper(self.activeSubTreeInfo.name));
		self.HeroSpecLabel:Show();
		MixinUtil.CallMethodOnAllSafe(self.ChooseSpecLabels, "Hide");
		MixinUtil.CallMethodOnAllSafe(self.LockedLabels, "Hide");
	elseif self:IsDisplayingHeroSpecChoices() then
		-- Choose A SubTree
		subTreeIDs = TalentFrameUtil.GetSubTreesIDsFromSubTreeSelectionNode(self:GetTalentFrame(), self.activeSubTreeSelectionNodeInfo);

		self.HeroSpecLabel:Hide();
		MixinUtil.CallMethodOnAllSafe(self.ChooseSpecLabels, "Show");
		MixinUtil.CallMethodOnAllSafe(self.LockedLabels, "Hide");
	elseif self:IsDisplayingPreviewSpecs() then
		-- SubTrees locked but able to be previewed
		isLocked = true;
		subTreeIDs = self.availableHeroSpecSubTreeIDs;

		self.LockedLabel2:SetText(HERO_TALENTS_LOCKED_2:format(self.heroSpecsRequiredLevel));

		self.HeroSpecLabel:Hide();
		MixinUtil.CallMethodOnAllSafe(self.ChooseSpecLabels, "Hide");
		MixinUtil.CallMethodOnAllSafe(self.LockedLabels, "Show");
	end

	self.HeroSpecButton:SetSubTreeIds(subTreeIDs, isLocked);
end

function HeroTalentsContainerMixin:UpdateHeroTalentCurrency(skipCheckingExpandState)
	local talentFrame = self:GetTalentFrame();
	local currencyAvailable = 0;

	if not self:IsInspecting() then
		if self:IsDisplayingActiveHeroSpec() then
			-- If we have an active hero spec, display its available points
			currencyAvailable = TalentFrameUtil.GetSubTreeCurrencyAvailable(talentFrame, self.activeSubTreeInfo.ID);
		elseif self:IsDisplayingHeroSpecChoices() then
			-- If we're displaying hero spec choices, display the highest number of available points between them
			subTreeIDs = TalentFrameUtil.GetSubTreesIDsFromSubTreeSelectionNode(talentFrame, self.activeSubTreeSelectionNodeInfo);
			for _, subTreeID in ipairs(subTreeIDs) do
				local subTreeCurrencyAvailable = TalentFrameUtil.GetSubTreeCurrencyAvailable(talentFrame, subTreeID);
				if subTreeCurrencyAvailable > currencyAvailable then
					currencyAvailable = subTreeCurrencyAvailable;
				end
			end
		end
	end

	local shouldShowCurrencyFrame = currencyAvailable and currencyAvailable > 0;

	if shouldShowCurrencyFrame then
		local amountText = HERO_TALENTS_POINTS_AMOUNT:format(currencyAvailable);
		local existingText = self.CurrencyFrame.Text:GetText();

		-- Only adjust text/anchoring if text doesn't already match
		if not existingText or strcmputf8i(existingText, amountText) ~= 0 then
			self.CurrencyFrame.Text:SetText(amountText);
			self.CurrencyFrame.Text:ClearAllPoints();
			
			-- The FRIZQT font has a problemm with rendering 1 (or numbers starting with 1), which causes it to be off center
			-- So, we have to detect that and manually bump it back into the center
			local indexOf1 = string.find(amountText, "1");
			if indexOf1 == 1 then
				self.CurrencyFrame.Text:SetPoint("CENTER", -2, -1);
			else
				self.CurrencyFrame.Text:SetPoint("CENTER", 0, -1);
			end
		end

		self.CurrencyFrame:Show();
	else
		self.CurrencyFrame.Text:SetText("");
		self.CurrencyFrame:Hide();
	end

	if self.specSelectionDialog:IsActive() then
		self.specSelectionDialog:UpdateCurrencies();
	end

	local shouldAlllowCollapsing = self:ShouldAllowCollapsing();
	if not skipCheckingExpandState and not self.isExpanded and not shouldAlllowCollapsing then
		-- If we're collapsed, and the currency frame is now hiding the expand button, force expand
		self:SetExpanded(true);
	else
		-- Otherwise just update the visibility of the Expand button
		self.ExpandButton:SetShown(shouldAlllowCollapsing);
	end

	self:CheckTutorials();
end

function HeroTalentsContainerMixin:UpdateHeroTalentsUnlockedAnim()
	-- Once a session (or until the UI reloads), play the unlocked anim until the player chooses a spec.
	if self:IsDisplayingHeroSpecChoices() and not self.playedUnlockedAnim then
		self.playedUnlockedAnim = true;
		HeroTalentsUnlockedAnimFrame:PlayAnim(self:GetTalentFrame():GetClassID());
	end
end

function HeroTalentsContainerMixin:SetExpanded(isExpanded)
	if self.isExpanded == isExpanded then
		return;
	end

	if not isExpanded and not self:ShouldAllowCollapsing() then
		return;
	end

	self.isExpanded = isExpanded;
	self.ExpandButton:SetExpanded(isExpanded);

	self:UpdateContainerVisibility();
end

function HeroTalentsContainerMixin:UpdateContainerVisibility()
	local isDisplayingActiveHeroSpec = self:IsDisplayingActiveHeroSpec();

	self.ExpandButton:SetShown(self:ShouldAllowCollapsing());
	self.ExpandedContainer:SetShown(isDisplayingActiveHeroSpec and self.isExpanded);
	self.CollapsedContainer:SetShown(isDisplayingActiveHeroSpec and not self.isExpanded);
	self.PreviewContainer:SetShown(self:IsDisplayingHeroSpecChoices() or self:IsDisplayingPreviewSpecs());

	-- If the Hero Talent Selection dialog is up, then it currently contains all the SubTree nodes, don't move them
	if self.specSelectionDialog:IsActive() then
		return;
	end

	-- Otherwise place all subTree nodes into our proper container based on their state and our expanded state
	for talentButton in self:GetTalentFrame():EnumerateAllTalentButtons() do
		local nodeInfo = talentButton:GetNodeInfo();
		if nodeInfo.subTreeID then
			self:UpdateHeroTalentButtonPosition(talentButton);
		end
	end
end

function HeroTalentsContainerMixin:UpdateHeroTalentButtonPosition(talentButton)
	-- If the Hero Talent Selection dialog is up and we've been asked to place a button, allow the dialog to take it
	if self.specSelectionDialog:IsActive() then
		self.specSelectionDialog:PlaceHeroTalentButton(talentButton);
		return;
	end

	local nodeInfo = talentButton:GetNodeInfo();

	-- Try positioning node in the Collapsed container frame
	if self:TryPositionInCollapsedFrame(talentButton, nodeInfo) then
		return;
	end

	-- Otherwise, position SubTree node within the Expanded container

	-- If node is already in the Expanded container, skip it
	if talentButton:GetParent() == self.ExpandedContainer.NodesContainer then
		return;
	end

	local talentFrame = self:GetTalentFrame();

	local tPosX, tPosY = TalentFrameUtil.GetNormalizedSubTreeNodePosition(talentFrame, nodeInfo);

	talentButton:ClearAllPoints();

	talentButton:SetParent(self.ExpandedContainer.NodesContainer);
	talentFrame:UpdateButtonFrameLevel(talentButton);
	-- If button switches parent, ensure its edges get updated to accomodate
	talentFrame:MarkEdgesDirty(talentButton);

	-- Set initial point, which will then be adjusted to the right offset
	talentButton:SetPoint("TOP", self.ExpandedContainer.NodesContainer);
	local offsetX, offsetY = 0, 8;
	TalentButtonUtil.ApplyPositionAtOffset(talentButton, tPosX, tPosY, offsetX, offsetY);
end

function HeroTalentsContainerMixin:TryPositionInCollapsedFrame(talentButton, nodeInfo)
	-- If we're not in expanded mode or node isn't currently visible, skip it
	if self.isExpanded or not talentButton:ShouldBeVisible() then
		return false;
	end

	-- Only preview swappable Selection nodes while in collapsed mode
	if nodeInfo.type ~= Enum.TraitNodeType.Selection or not talentButton:CanSelectChoice() then
		return false;
	end

	local talentFrame = self:GetTalentFrame();

	-- Talent frame uses a basic Pairing function to calculate a unique index based on this node's XY
	-- The index is also roughly in order from top left to bottom right, so perfect for use as an easy layoutIndex
	local uniqueIndex = talentFrame:GetIndexFromNodePosition(nodeInfo.posX, nodeInfo.posY);
	talentButton.layoutIndex = uniqueIndex;

	if talentButton:GetParent() ~= self.CollapsedContainer.NodesContainer then
		talentButton:ClearAllPoints();
		talentButton:SetParent(self.CollapsedContainer.NodesContainer);
		talentFrame:UpdateButtonFrameLevel(talentButton);
		-- If button switches parent, ensure its edges get updated to accomodate
		talentFrame:MarkEdgesDirty(talentButton);
	end

	self.CollapsedContainer.NodesContainer:MarkDirty();

	return true;
end

function HeroTalentsContainerMixin:OnExpandClicked()
	local isExpanded = not self.isExpanded;
	self:SetExpanded(isExpanded);
end

function HeroTalentsContainerMixin:OnHeroSpecButtonClicked()
	if self.activeSubTreeSelectionNodeInfo and not self:IsInspecting() then
		self.specSelectionDialog:ShowDialog(self.activeSubTreeSelectionNodeInfo, GenerateClosure(self.OnHeroSpecDialogClosed, self));
		self:GetTalentFrame():OnHeroSpecSelectionOpened();
	end
end

function HeroTalentsContainerMixin:OnHeroSpecDialogClosed()
	self:GetTalentFrame():OnHeroSpecSelectionClosed();
	
	-- Update our containers so we can re-position SubTree nodes back within ourselves
	self:UpdateContainerVisibility();
end

function HeroTalentsContainerMixin:GetTalentFrame()
	return self.talentFrame;
end

function HeroTalentsContainerMixin:IsInspecting()
	return self:GetTalentFrame():IsInspecting();
end

function HeroTalentsContainerMixin:CheckTutorials()
	self:GetTalentFrame():CheckHeroTalentTutorial(self.activeSubTreeInfo, self.helpTipOffsetX, self.helpTipOffsetY, self, self.ExpandedContainer.NodesContainer);
end

HeroSpecButtonMixin = {};

function HeroSpecButtonMixin:SetSubTreeIds(subTreeIDs, isLocked)
	local talentFrame = self:GetTalentFrame();

	if not subTreeIDs or #subTreeIDs == 0 then
		-- No SubTrees, nothing to show
		self:Hide();
	elseif #subTreeIDs == 1 then
		-- One SubTree, show as the sole active SubTree
		local activeSubTreeInfo = talentFrame:GetAndCacheSubTreeInfo(subTreeIDs[1]);

		self.Icon1:SetAtlas(activeSubTreeInfo.iconElementID);
		self.Icon2:Hide();
		for _, mask in ipairs(self.IconSplitMasks) do
			mask:Hide();
		end
		self:Show();
	else
		-- More than one SubTree, show as multiple split options
		-- Hero Spec design currently only supports 2 SubTree/Spec options, so only using the first two
		local subTree1 = talentFrame:GetAndCacheSubTreeInfo(subTreeIDs[1]);
		local subTree2 = talentFrame:GetAndCacheSubTreeInfo(subTreeIDs[2]);

		self.Icon1:SetAtlas(subTree1.iconElementID);
		self.Icon2:SetAtlas(subTree2.iconElementID);
		self.Icon2:Show();

		for _, mask in ipairs(self.IconSplitMasks) do
			mask:Show();
		end
		self:Show();
	end

	if self.isLocked ~= isLocked then
		self.isLocked = isLocked;
		self.Icon1:SetDesaturated(self.isLocked);
		self.Icon2:SetDesaturated(self.isLocked);
		self.LockedOverlay:SetShown(self.isLocked);
	end

	local areChoicesActive = not self.isLocked and subTreeIDs and #subTreeIDs > 1;
	if self.areChoicesActive ~= areChoicesActive then
		self.areChoicesActive = areChoicesActive;
		self.ChoiceBorder:SetShown(self.areChoicesActive);
		self.ChoiceBackground:SetShown(self.areChoicesActive);
		self.ChoiceGlowAnim:Play();
		self.Border:SetShown(not self.areChoicesActive)
	end

	if self:IsMouseMotionFocus() then
		self.BorderHover:Hide();
		self.ChoiceBorderHover:Hide();
		self:OnEnter();
	end
end

function HeroSpecButtonMixin:OnEnter()
	if self.isLocked or self:IsInspecting() then
		return;
	end

	if self.areChoicesActive then
		self.ChoiceBorderHover:Show();
	else
		self.BorderHover:Show();
	end
end

function HeroSpecButtonMixin:OnLeave()
	if self.isLocked or self:IsInspecting() then
		return;
	end

	if self.areChoicesActive then
		self.ChoiceBorderHover:Hide();
	else
		self.BorderHover:Hide();
	end
end

function HeroSpecButtonMixin:OnClick()
	if not self.isLocked and not self:IsInspecting() then
		self:GetParent():OnHeroSpecButtonClicked();
	end
end

function HeroSpecButtonMixin:GetTalentFrame()
	return self:GetParent():GetTalentFrame();
end

function HeroSpecButtonMixin:IsInspecting()
	return self:GetParent():IsInspecting();
end



HeroTalentExpandButtonMixin = {};

function HeroTalentExpandButtonMixin:SetExpanded(isExpanded)
	local atlasToUse = isExpanded and self.expandedAtlas or self.collapsedAtlas;
	self.Texture:SetAtlas(atlasToUse);
	self.TextureHover:SetAtlas(atlasToUse);
end

function HeroTalentExpandButtonMixin:OnClick()
	self:GetParent():OnExpandClicked();
end

function HeroTalentExpandButtonMixin:OnEnter()
	self.TextureHover:Show();
end

function HeroTalentExpandButtonMixin:OnLeave()
	self.TextureHover:Hide();
end


HeroTalentsUnlockedAnimFrameMixin = { };

function HeroTalentsUnlockedAnimFrameMixin:OnHide()
	self.Anim:Stop();
end

function HeroTalentsUnlockedAnimFrameMixin:PlayAnim(classID)
	local classVisuals = ClassTalentUtil.GetVisualsForClassID(classID);
	if classVisuals then
		for i, texture in ipairs(self.Textures) do
			texture:SetAlpha(0);
			if texture.replaceWithClassVisual then
				texture:SetAtlas(classVisuals.activationFX, TextureKitConstants.UseAtlasSize);
			end
		end
	end

	self:Show();
	self.Anim:Restart();
end
