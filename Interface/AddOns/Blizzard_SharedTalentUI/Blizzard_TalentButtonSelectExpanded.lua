
-- TalentButtonSelectExpandedButtonMixin is a select button template that always shows all its options
-- instead of showing a selection frame on mouseover.

TalentButtonSelectExpandedButtonMixin = CreateFromMixins(TalentButtonSelectMixin);

function TalentButtonSelectExpandedButtonMixin:ShowSelections()
	-- Overrides TalentButtonSelectMixin.

	if self.talentSelections then
		self.SelectionFrame:SetSelectionOptions(self, self.talentSelections, self:CanSelectChoice(), self:GetSelectedEntryID(), self:GetTraitCurrenciesCost());
	end
end

function TalentButtonSelectExpandedButtonMixin:UpdateSelections(canSelectChoice, currentSelection, baseCost)
	-- Overrides TalentButtonSelectMixin.

	self.SelectionFrame:UpdateSelectionOptions(canSelectChoice, currentSelection, baseCost);
end

function TalentButtonSelectExpandedButtonMixin:OnEnter()
	-- Overrides TalentButtonSelectMixin.
	-- Do nothing here since our selections are always shown.
end

TalentButtonSelectExpandedDisplayMixin = {};

function TalentButtonSelectExpandedDisplayMixin:Init(talentFrame, ...)
	TalentDisplayMixin.Init(self, talentFrame, ...);

	self.SelectionFrame:SetTalentFrame(talentFrame);
end

function TalentButtonSelectExpandedDisplayMixin:OnRelease()
	TalentDisplayMixin.OnRelease(self);

	self.previousSelectionOptions = nil;
	self.SelectionFrame:SetSelectionOptions(self, {});
end

function TalentButtonSelectExpandedDisplayMixin:ApplyVisualState()
	if self.talentSelections and (not self.previousSelectionOptions or not tCompare(self.previousSelectionOptions, self.talentSelections)) then
		self.previousSelectionOptions = self.talentSelections;
		self:ShowSelections();
	end
end
