ClassTalentButtonBaseMixin = {};

function ClassTalentButtonBaseMixin:UpdateActionBarStatus()
	self.missingFromActionBar = not self:IsInspecting() and ClassTalentUtil.IsTalentMissingFromActionBars(self:GetNodeInfo(), self:GetSpellID());
end

function ClassTalentButtonBaseMixin:IsMissingFromActionBar()
	return self.missingFromActionBar;
end

ClassTalentButtonSpendMixin = CreateFromMixins(TalentButtonSpendMixin, ClassTalentButtonBaseMixin);

function ClassTalentButtonSpendMixin:OnLoad()
	-- Overrides TalentButtonSpendMixin.

	TalentButtonSpendMixin.OnLoad(self);

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

	if self.missingFromActionBar then
		GameTooltip:AddLine(TALENT_BUTTON_TOOLTIP_NOT_ON_ACTION_BAR, LIGHTBLUE_FONT_COLOR.r, LIGHTBLUE_FONT_COLOR.g, LIGHTBLUE_FONT_COLOR.b);
	end
	TalentButtonSpendMixin.AddTooltipInstructions(self, tooltip);
end


ClassTalentButtonSelectMixin = CreateFromMixins(TalentButtonSelectMixin, ClassTalentButtonBaseMixin);

function ClassTalentButtonSelectMixin:OnLoad()
	-- Overrides TalentButtonSelectMixin.

	TalentButtonSelectMixin.OnLoad(self);

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


ClassTalentButtonSplitSelectMixin = CreateFromMixins(TalentButtonSplitSelectMixin, ClassTalentButtonBaseMixin);

function ClassTalentButtonSplitSelectMixin:OnLoad()
	-- Overrides TalentButtonSplitSelectMixin.

	TalentButtonSplitSelectMixin.OnLoad(self);

	self.selectSound = SOUNDKIT.UI_CLASS_TALENT_NODE_SPEND_MAJOR;
	self.deselectSound = SOUNDKIT.UI_CLASS_TALENT_NODE_REFUND;
end

function ClassTalentButtonSplitSelectMixin:FullUpdate()
	-- Overrides TalentButtonSplitSelectMixin.

	TalentButtonSplitSelectMixin.FullUpdate(self);
	self:UpdateActionBarStatus();
end


ClassTalentSelectionChoiceMixin = CreateFromMixins(TalentSelectionChoiceMixin);

function ClassTalentSelectionChoiceMixin:SetSelectionInfo(entryInfo, canSelectChoice, isCurrentSelection, selectionIndex)
	-- Overrides TalentSelectionChoiceMixin.

	TalentSelectionChoiceMixin.SetSelectionInfo(self, entryInfo, canSelectChoice, isCurrentSelection, selectionIndex);

	local entryID = self:GetEntryID();
	local nodeInfo = self:GetNodeInfo();
	local talentFrame = self:GetTalentFrame();

	self.missingFromActionBar = ClassTalentUtil.IsEntryTalentMissingFromActionBars(entryID, nodeInfo, self:GetSpellID());

	self:SetSearchMatchType(nodeInfo and talentFrame:GetSearchMatchTypeForEntry(nodeInfo.ID, entryID) or nil);
	self:SetGlowing(talentFrame:IsHighlightedStarterBuildEntry(entryID));
end

function ClassTalentSelectionChoiceMixin:AddTooltipInstructions(tooltip)
	if self.missingFromActionBar then
		GameTooltip:AddLine(TALENT_BUTTON_TOOLTIP_NOT_ON_ACTION_BAR, LIGHTBLUE_FONT_COLOR.r, LIGHTBLUE_FONT_COLOR.g, LIGHTBLUE_FONT_COLOR.b);
	end

	TalentSelectionChoiceMixin.AddTooltipInstructions(self, tooltip);
end