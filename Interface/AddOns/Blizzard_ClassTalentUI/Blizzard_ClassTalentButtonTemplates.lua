local NODE_PURCHASE_FX_1 = 150;


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
	self.missingFromActionBar = not self:IsInspecting() and not self:FrameHasAnyPendingChanges() and ClassTalentUtil.IsTalentMissingFromActionBars(self:GetNodeInfo(), self:GetSpellID());
end

function ClassTalentButtonBaseMixin:IsMissingFromActionBar()
	return self.missingFromActionBar;
end

function ClassTalentButtonBaseMixin:PlayPurchaseEffect(fxModelScene)
	fxModelScene:AddEffect(NODE_PURCHASE_FX_1, self, self);
	if self.PurchaseVisuals and self.PurchaseVisuals.Anim then
		self.PurchaseVisuals.Anim:SetPlaying(true);
	end
end

function ClassTalentButtonBaseMixin:ResetPurchaseEffects()
	if self.PurchaseVisuals and self.PurchaseVisuals.Anim then
		self.PurchaseVisuals.Anim:SetPlaying(false);
	end
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

function ClassTalentButtonBaseMixin:OnRelease()
	-- Overrides TalentDisplayMixin.

	self:ResetPurchaseEffects();
	TalentDisplayMixin.OnRelease(self);
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

	if self:IsMissingFromActionBar() then
		GameTooltip:AddLine(TALENT_BUTTON_TOOLTIP_NOT_ON_ACTION_BAR, LIGHTBLUE_FONT_COLOR.r, LIGHTBLUE_FONT_COLOR.g, LIGHTBLUE_FONT_COLOR.b);
	end
	TalentButtonSpendMixin.AddTooltipInstructions(self, tooltip);
end

function ClassTalentButtonSpendMixin:ResetDynamic()
	-- Overrides TalentButtonSpendMixin.

	TalentButtonSpendMixin.ResetDynamic(self);
	self:ResetPurchaseEffects();
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

function ClassTalentButtonSelectMixin:ResetDynamic()
	-- Overrides TalentButtonSelectMixin.

	TalentButtonSelectMixin.ResetDynamic(self);
	self:ResetPurchaseEffects();
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

function ClassTalentButtonSplitSelectMixin:ResetDynamic()
	-- Overrides TalentButtonSplitSelectMixin.

	TalentButtonSplitSelectMixin.ResetDynamic(self);
	self:ResetPurchaseEffects();
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
	-- Overrides TalentButtonSelectMixin

	TalentButtonSelectMixin.ShowSelections(self);
	self:UpdateGlow();
end

function ClassTalentButtonSplitSelectMixin:ClearSelections()
	-- Overrides TalentButtonSelectMixin

	TalentButtonSelectMixin.ClearSelections(self);
	self:UpdateGlow();
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

	self.missingFromActionBar = not self:IsInspecting() and not talentFrame:HasAnyPendingChanges() and ClassTalentUtil.IsEntryTalentMissingFromActionBars(entryID, nodeInfo, self:GetSpellID());

	self:SetSearchMatchType(nodeInfo and talentFrame:GetSearchMatchTypeForEntry(nodeInfo.ID, entryID) or nil);
	self:SetGlowing(talentFrame:IsHighlightedStarterBuildEntry(entryID));
end

function ClassTalentSelectionChoiceMixin:AddTooltipInstructions(tooltip)
	if self.missingFromActionBar then
		GameTooltip:AddLine(TALENT_BUTTON_TOOLTIP_NOT_ON_ACTION_BAR, LIGHTBLUE_FONT_COLOR.r, LIGHTBLUE_FONT_COLOR.g, LIGHTBLUE_FONT_COLOR.b);
	end

	TalentSelectionChoiceMixin.AddTooltipInstructions(self, tooltip);
end