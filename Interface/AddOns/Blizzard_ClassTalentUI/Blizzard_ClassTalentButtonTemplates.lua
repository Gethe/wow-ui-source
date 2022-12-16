
--------------------------------------------------
-- Base mixin for both the standard talent Buttons and the Selection Choice mixin.
-- Should only contain overrides to TalentButtonArtMixin or TalentDisplayMixin functionality.
-- Should NOT contain any overrides to TalentButtonBaseMixin functionality.
ClassTalentButtonArtMixin = {};

function ClassTalentButtonArtMixin:OnShow()
	self.BorderSheen.Anim:Play();
end

function ClassTalentButtonArtMixin:OnHide()
	self.BorderSheen.Anim:Stop();
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
	if spellID and self:GetActionBarStatus() == TalentButtonUtil.ActionBarStatus.NotMissing then
		ClearOnBarHighlightMarks();
		UpdateOnBarHighlightMarksBySpell(spellID);
		ActionBarController_UpdateAllSpellHighlights();
	end
end

function ClassTalentButtonArtMixin:HideActionBarHighlights()
	ClearOnBarHighlightMarks();
	ActionBarController_UpdateAllSpellHighlights();
end

--------------------------------------------------
-- Base mixin for the standard talent Buttons.
-- Should contain functionality for all BUT the Selection Choice mixin.
ClassTalentButtonBaseMixin = {};

function ClassTalentButtonBaseMixin:OnLoad()
	self.BorderSheenMask:SetAtlas(self.sheenMaskAtlas, TextureKitConstants.UseAtlasSize);
	self.SelectableGlow:SetAtlas(self.artSet.glow, TextureKitConstants.IgnoreAtlasSize);
	self.tooltipBackdropStyle = GAME_TOOLTIP_BACKDROP_STYLE_CLASS_TALENT;
end

function ClassTalentButtonBaseMixin:UpdateActionBarStatus()
	if self:IsInspecting() or self:FrameHasAnyPendingChanges() then
		self.actionBarStatus = TalentButtonUtil.ActionBarStatus.NotMissing;
	else
		self.actionBarStatus = TalentButtonUtil.GetActionBarStatusForNode(self:GetNodeInfo(), self:GetSpellID());
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

	local statusTooltip = TalentButtonUtil.GetTooltipForActionBarStatus(self:GetActionBarStatus());
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
end

function ClassTalentSelectionChoiceMixin:SetSelectionInfo(entryInfo, canSelectChoice, isCurrentSelection, selectionIndex)
	-- Overrides TalentSelectionChoiceMixin.

	TalentSelectionChoiceMixin.SetSelectionInfo(self, entryInfo, canSelectChoice, isCurrentSelection, selectionIndex);

	local entryID = self:GetEntryID();
	local nodeInfo = self:GetNodeInfo();
	local talentFrame = self:GetTalentFrame();

	if self:IsInspecting() or talentFrame:HasAnyPendingChanges() then
		self.actionBarStatus = TalentButtonUtil.ActionBarStatus.NotMissing;
	else
		self.actionBarStatus = TalentButtonUtil.GetActionBarStatusForNodeEntry(entryID, nodeInfo, self:GetSpellID());
	end

	self:SetSearchMatchType(nodeInfo and talentFrame:GetSearchMatchTypeForEntry(nodeInfo.ID, entryID) or nil);
	self:SetGlowing(talentFrame:IsHighlightedStarterBuildEntry(entryID));
end

function ClassTalentSelectionChoiceMixin:AddTooltipInstructions(tooltip)
	local statusTooltip = TalentButtonUtil.GetTooltipForActionBarStatus(self:GetActionBarStatus());
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