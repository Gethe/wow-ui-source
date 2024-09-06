ClassTalentBorderSheenSyncKey = "ClassTalentBorderSheen";

--------------------------------------------------
-- Base mixin for both the standard talent Buttons and the Selection Choice mixin.
-- Should only contain overrides to TalentButtonArtMixin or TalentDisplayMixin functionality.
-- Should NOT contain any overrides to TalentButtonBaseMixin functionality.
ClassTalentButtonArtMixin = {};

function ClassTalentButtonArtMixin:OnShow()
	if not self.BorderSheen.Anim:IsPlaying() then
		-- Ensure all node sheens stay synced
		self.BorderSheen.Anim:PlaySynced();
	end
end

function ClassTalentButtonArtMixin:OnHide()
	if self.BorderSheen.Anim:IsPlaying() then
		self.BorderSheen.Anim:Stop();
	end
end

function ClassTalentButtonArtMixin:UpdateStateBorder(visualState)
	-- Overrides TalentButtonArtMixin.

	TalentButtonArtMixin.UpdateStateBorder(self, visualState);
	local sheenAlpha = ClassTalentUtil.GetSheenAlphaForVisualState(visualState);

	self.BorderSheen:SetAlpha(sheenAlpha);
	-- Hiding the sheen instead of stopping its anim so that it stays in sync with the other nodes
	self.BorderSheen:SetShown(sheenAlpha > 0);
end

function ClassTalentButtonArtMixin:ShowActionBarHighlights()
	local spellID = self:GetSpellID();
	if spellID and self:GetActionBarStatus() == ActionButtonUtil.ActionBarActionStatus.NotMissing then
		ClearOnBarHighlightMarks();
		UpdateOnBarHighlightMarksBySpell(spellID);
		ActionBarController_UpdateAllSpellHighlights();
	end
end

function ClassTalentButtonArtMixin:HideActionBarHighlights()
	ClearOnBarHighlightMarks();
	ActionBarController_UpdateAllSpellHighlights();
end

-- Returns true if this node is in an inactive SubTree that is being previewed
function ClassTalentButtonArtMixin:IsInPreviewedSubTree()
	-- If the Base check tells us we're not in an inactive SubTree at all, then false
	if not TalentButtonBaseMixin.IsInDeactivatedSubTree(self) then
		return false;
	end

	local nodeInfo = self:GetNodeInfo();
	-- Otherwise check if we are in a SubTree being previewed
	return nodeInfo and nodeInfo.subTreeID and self:GetTalentFrame():IsPreviewingSubTree(nodeInfo.subTreeID);
end

--------------------------------------------------
-- Base mixin for the standard talent Buttons.
-- Should contain functionality for all BUT the Selection Choice mixin.
ClassTalentButtonBaseMixin = {};

function ClassTalentButtonBaseMixin:OnLoad()
	self.BorderSheenMask:SetAtlas(self.sheenMaskAtlas, TextureKitConstants.UseAtlasSize);
	self.SelectableGlow:SetAtlas(self.artSet.glow, TextureKitConstants.IgnoreAtlasSize);
	self.tooltipBackdropStyle = GAME_TOOLTIP_BACKDROP_STYLE_CLASS_TALENT;
	self.SearchIcon.tooltipBackdropStyle = self.tooltipBackdropStyle;
end

function ClassTalentButtonBaseMixin:UpdateActionBarStatus()
	if self:IsInspecting() or self:FrameHasAnyPendingChanges() then
		self.actionBarStatus = ActionButtonUtil.ActionBarActionStatus.NotMissing;
	else
		self.actionBarStatus = SpellSearchUtil.GetActionBarStatusForTraitNode(self:GetNodeInfo(), self:GetSpellID());
	end
end

function ClassTalentButtonBaseMixin:GetActionBarStatus()
	return self.actionBarStatus;
end

function ClassTalentButtonBaseMixin:SetSelectableGlowDisabled(disabled)
	self.selectableGlowDisabled = disabled;
	self:UpdateSelectableGlow();
end

function ClassTalentButtonBaseMixin:UpdateStateBorder(visualState)
	-- Overrides ClassTalentButtonArtMixin.

	ClassTalentButtonArtMixin.UpdateStateBorder(self, visualState);
	self:UpdateSelectableGlow();
end

function ClassTalentButtonBaseMixin:UpdateGlow()
	-- Overrides TalentButtonArtMixin.

	TalentButtonArtMixin.UpdateGlow(self);
	self:UpdateSelectableGlow();
end

function ClassTalentButtonBaseMixin:UpdateSelectableGlow()
	local isDoingStandardGlow = self.Glow and self.shouldGlow;
	local canDoSelectableGlow = not isDoingStandardGlow and not self.selectableGlowDisabled;

	local playSelectableGlow = canDoSelectableGlow and self.visualState == TalentButtonUtil.BaseVisualState.Selectable;
	self.SelectableGlow.Anim:SetPlaying(playSelectableGlow);
end

function ClassTalentButtonBaseMixin:FrameHasAnyPendingChanges()
	return self:GetTalentFrame():HasAnyPendingChanges();
end

function ClassTalentButtonBaseMixin:IsInDeactivatedSubTree()
	-- Overrides TalentButtonBaseMixin.

	-- If we're previewing the SubTree we're in, we want to temporarily pretend to be active for visibility
	if self:IsInPreviewedSubTree() then
		return false;
	end
	return TalentButtonBaseMixin.IsInDeactivatedSubTree(self);
end

function ClassTalentButtonBaseMixin:IsInspecting()
	-- Overrides TalentDisplayMixin

	local baseIsInspecting = TalentDisplayMixin.IsInspecting(self);

	-- If we're not inspecting another player but this node is part of an inactive SubTree being previewed, then we do want to treat it as being inspected
	-- ie: not purchase, refund, or selectable, just showing existing state
	return baseIsInspecting or self:IsInPreviewedSubTree();
end

function ClassTalentButtonBaseMixin:ShouldShowTooltipErrors()
	-- Overrides TalentDisplayMixin

	-- Checking the base value of IsInspecting because talents should still show errors if they're in the previewed sub tree.
	if TalentDisplayMixin.IsInspecting(self) then
		return false;
	end

	return true;
end

function ClassTalentButtonBaseMixin:IsSearchMatchTypeAllowed(matchType)
	-- Don't display the missing from action bar results for talents that belong to inactive Hero
	-- specs. It's not expected that players have these talents on their action bars and can be
	-- confusing to report that information to them.
	if SpellSearchUtil.IsActionBarMatchType(matchType) then
		local talentFrame = self:GetTalentFrame();
		local subTreeID = self:GetNodeSubTreeID();
		if talentFrame and subTreeID and not talentFrame:IsHeroSpecActive(subTreeID) then
			return false;
		end
	end

	return true;
end

function ClassTalentButtonBaseMixin:SetSearchMatchType(matchType)
	if not self:IsSearchMatchTypeAllowed(matchType) then
		matchType = nil;
	end

	TalentDisplayMixin.SetSearchMatchType(self, matchType)
end

--------------------------------------------------
-- Spend Mixin (standard select/deselect)
ClassTalentButtonSpendMixin = CreateFromMixins(TalentButtonSpendMixin, ClassTalentButtonBaseMixin);

function ClassTalentButtonSpendMixin:OnLoad()
	-- Overrides TalentButtonSpendMixin.

	TalentButtonSpendMixin.OnLoad(self);
	ClassTalentButtonBaseMixin.OnLoad(self);

	self.selectSound = SOUNDKIT.UI_CLASS_TALENT_NODE_SPEND;
	self.deselectSound = SOUNDKIT.UI_CLASS_TALENT_NODE_REFUND;
end

function ClassTalentButtonSpendMixin:UpdateEntryInfo(skipUpdate)
	-- Overrides TalentButtonSpendMixin.

	TalentButtonSpendMixin.UpdateEntryInfo(self, skipUpdate);
	
	if self.entryInfo and self.entryInfo.type == Enum.TraitNodeEntryType.SpendSquare then
		self.selectSound = SOUNDKIT.UI_CLASS_TALENT_NODE_SPEND_MAJOR;
	else
		self.selectSound = SOUNDKIT.UI_CLASS_TALENT_NODE_SPEND;
	end
end

function ClassTalentButtonSpendMixin:FullUpdate()
	-- Overrides TalentButtonSpendMixin.

	TalentButtonSpendMixin.FullUpdate(self);
	self:UpdateActionBarStatus();
end

function ClassTalentButtonSpendMixin:AddTooltipInstructions(tooltip)
	-- Overrides TalentButtonSpendMixin.

	local statusTooltip = SpellSearchUtil.GetTooltipForActionBarStatus(self:GetActionBarStatus());
	if statusTooltip then
		local wrap = true;
		GameTooltip_AddColoredLine(tooltip, statusTooltip, LIGHTBLUE_FONT_COLOR, wrap);
	end

	TalentButtonSpendMixin.AddTooltipInstructions(self, tooltip);
end

function ClassTalentButtonSpendMixin:OnEnter()
	-- Overrides TalentButtonSpendMixin.

	TalentButtonSpendMixin.OnEnter(self);
	self:ShowActionBarHighlights();
end

function ClassTalentButtonSpendMixin:OnLeave()
	-- Overrides TalentDisplayMixin.

	TalentDisplayMixin.OnLeave(self);
	self:HideActionBarHighlights();
end

--------------------------------------------------
-- Select Mixin (talent with multiple choices)
ClassTalentButtonSelectMixin = CreateFromMixins(TalentButtonSelectMixin, ClassTalentButtonBaseMixin);

function ClassTalentButtonSelectMixin:OnLoad()
	-- Overrides TalentButtonSelectMixin.

	TalentButtonSelectMixin.OnLoad(self);
	ClassTalentButtonBaseMixin.OnLoad(self);

	self.selectSound = SOUNDKIT.UI_CLASS_TALENT_NODE_SPEND;
	self.deselectSound = SOUNDKIT.UI_CLASS_TALENT_NODE_REFUND;
end

function ClassTalentButtonSelectMixin:UpdateEntryInfo(skipUpdate)
	-- Overrides TalentButtonSelectMixin.

	TalentButtonSelectMixin.UpdateEntryInfo(self, skipUpdate);
	
	if self.entryInfo and self.entryInfo.type == Enum.TraitNodeEntryType.SpendSquare then
		self.selectSound = SOUNDKIT.UI_CLASS_TALENT_NODE_SPEND_MAJOR;
	else
		self.selectSound = SOUNDKIT.UI_CLASS_TALENT_NODE_SPEND;
	end
end

function ClassTalentButtonSelectMixin:FullUpdate()
	-- Overrides TalentButtonSelectMixin.

	TalentButtonSelectMixin.FullUpdate(self);
	self:UpdateActionBarStatus();
end

function ClassTalentButtonSelectMixin:UpdateGlow()
	-- Overrides ClassTalentButtonBaseMixin.

	ClassTalentButtonBaseMixin.UpdateGlow(self);

	local isDoingStandardGlow = self.Glow and self.shouldGlow;
	-- Prevent standard glow while selection flyout is open
	if isDoingStandardGlow and self:GetTalentFrame():AreSelectionsOpen(self) then
		self.Glow:SetShown(false);
	end
end

function ClassTalentButtonSelectMixin:ShowSelections()
	-- Overrides TalentButtonSelectMixin

	TalentButtonSelectMixin.ShowSelections(self);
	self:UpdateGlow();
end

function ClassTalentButtonSelectMixin:ClearSelections()
	-- Overrides TalentButtonSelectMixin

	TalentButtonSelectMixin.ClearSelections(self);
	self:UpdateGlow();
end

function ClassTalentButtonSelectMixin:OnEnter()
	-- Overrides TalentButtonSelectMixin.

	TalentButtonSelectMixin.OnEnter(self);
	self:ShowActionBarHighlights();
end

function ClassTalentButtonSelectMixin:OnLeave()
	-- Overrides TalentButtonSelectMixin.

	TalentButtonSelectMixin.OnLeave(self);
	self:HideActionBarHighlights();
end

--------------------------------------------------
-- Split Select Mixin (talent with split icon with two choices)
ClassTalentButtonSplitSelectMixin = CreateFromMixins(TalentButtonSplitSelectMixin, ClassTalentButtonBaseMixin);

function ClassTalentButtonSplitSelectMixin:OnLoad()
	-- Overrides TalentButtonSplitSelectMixin.

	TalentButtonSplitSelectMixin.OnLoad(self);
	ClassTalentButtonBaseMixin.OnLoad(self);

	self.selectSound = SOUNDKIT.UI_CLASS_TALENT_NODE_SPEND_MAJOR;
	self.deselectSound = SOUNDKIT.UI_CLASS_TALENT_NODE_REFUND;
end

function ClassTalentButtonSplitSelectMixin:FullUpdate()
	-- Overrides TalentButtonSplitSelectMixin.

	TalentButtonSplitSelectMixin.FullUpdate(self);
	self:UpdateActionBarStatus();
end

function ClassTalentButtonSplitSelectMixin:UpdateGlow()
	-- Overrides ClassTalentButtonBaseMixin.

	ClassTalentButtonBaseMixin.UpdateGlow(self);

	local isDoingStandardGlow = self.Glow and self.shouldGlow;
	-- Prevent standard glow while selection flyout is open
	if isDoingStandardGlow and self:GetTalentFrame():AreSelectionsOpen(self) then
		self.Glow:SetShown(false);
	end
end

function ClassTalentButtonSplitSelectMixin:ShowSelections()
	-- Overrides TalentButtonSplitSelectMixin

	TalentButtonSplitSelectMixin.ShowSelections(self);
	self:UpdateGlow();
end

function ClassTalentButtonSplitSelectMixin:ClearSelections()
	-- Overrides TalentButtonSplitSelectMixin

	TalentButtonSplitSelectMixin.ClearSelections(self);
	self:UpdateGlow();
end

function ClassTalentButtonSplitSelectMixin:OnEnter()
	-- Overrides TalentButtonSplitSelectMixin.

	TalentButtonSplitSelectMixin.OnEnter(self);
	self:ShowActionBarHighlights();
end

function ClassTalentButtonSplitSelectMixin:OnLeave()
	-- Overrides TalentButtonSplitSelectMixin.

	TalentButtonSplitSelectMixin.OnLeave(self);
	self:HideActionBarHighlights();
end

--------------------------------------------------
-- Selection Choice Mixin (flyout choice shown by select mixins)
ClassTalentSelectionChoiceMixin = CreateFromMixins(TalentSelectionChoiceMixin);

function ClassTalentSelectionChoiceMixin:OnLoad()
	-- Overrides TalentButtonArtMixin.

	TalentButtonArtMixin.OnLoad(self);
	self.BorderSheenMask:SetAtlas(self.sheenMaskAtlas, TextureKitConstants.UseAtlasSize);

	self.tooltipBackdropStyle = GAME_TOOLTIP_BACKDROP_STYLE_CLASS_TALENT;
	self.SearchIcon.tooltipBackdropStyle = self.tooltipBackdropStyle;
end

function ClassTalentSelectionChoiceMixin:SetSelectionInfo(entryInfo, canSelectChoice, isCurrentSelection, selectionIndex)
	-- Overrides TalentSelectionChoiceMixin.

	TalentSelectionChoiceMixin.SetSelectionInfo(self, entryInfo, canSelectChoice, isCurrentSelection, selectionIndex);

	local entryID = self:GetEntryID();
	local nodeInfo = self:GetNodeInfo();
	local talentFrame = self:GetTalentFrame();

	if self:IsInspecting() or talentFrame:HasAnyPendingChanges() then
		self.actionBarStatus = ActionButtonUtil.ActionBarActionStatus.NotMissing;
	else
		self.actionBarStatus = SpellSearchUtil.GetActionBarStatusForTraitNodeEntry(entryID, nodeInfo, self:GetSpellID());
	end

	self:SetSearchMatchType(nodeInfo and talentFrame:GetSearchMatchTypeForEntry(nodeInfo.ID, entryID) or nil);
	self:SetGlowing(talentFrame:IsHighlightedStarterBuildEntry(entryID));
end

function ClassTalentSelectionChoiceMixin:AddTooltipInstructions(tooltip)
	local statusTooltip = SpellSearchUtil.GetTooltipForActionBarStatus(self:GetActionBarStatus());
	if statusTooltip then
		local wrap = true;
		GameTooltip_AddColoredLine(tooltip, statusTooltip, LIGHTBLUE_FONT_COLOR, wrap);
	end

	TalentSelectionChoiceMixin.AddTooltipInstructions(self, tooltip);
end

function ClassTalentSelectionChoiceMixin:GetActionBarStatus()
	return self.actionBarStatus;
end

function ClassTalentSelectionChoiceMixin:OnEnter()
	-- Overrides TalentDisplayMixin.
	TalentDisplayMixin.OnEnter(self);
	self:ShowActionBarHighlights();
end

function ClassTalentSelectionChoiceMixin:OnLeave()
	-- Overrides TalentDisplayMixin.
	TalentDisplayMixin.OnLeave(self);
	self:HideActionBarHighlights();
end