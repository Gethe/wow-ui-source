
local TalentSelectionChoiceFramePadding = 10;


TalentSelectionChoiceFrameMixin = {};

local TalentSelectionChoiceFrameEvents = {
	"GLOBAL_MOUSE_DOWN",
};

function TalentSelectionChoiceFrameMixin:OnLoad()
	self.selectionFrameArray = {};
	self.widthPadding = TalentSelectionChoiceFramePadding;
	self.heightPadding = TalentSelectionChoiceFramePadding;
end

function TalentSelectionChoiceFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, TalentSelectionChoiceFrameEvents);
end

function TalentSelectionChoiceFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, TalentSelectionChoiceFrameEvents);
end

function TalentSelectionChoiceFrameMixin:OnEvent(event, ...)
	if event == "GLOBAL_MOUSE_DOWN" then
		local buttonName = ...;
		FrameUtil.DialogStyleGlobalMouseDown(self, buttonName);
	end
end

function TalentSelectionChoiceFrameMixin:SetSelectionOptions(baseButton, selectionOptions, canSelectChoice, currentSelection, baseCost)
	self.baseButton = baseButton;
	self.baseCost = baseCost;

	local talentFrame = self:GetTalentFrame();
	for i, selectionFrame in ipairs(self.selectionFrameArray) do
		talentFrame:ReleaseTalentDisplayFrame(selectionFrame);
	end

	self.selectionFrameArray = {};

	for i, entryID in ipairs(selectionOptions) do
		local entryInfo = talentFrame:GetAndCacheEntryInfo(entryID);
		local newSelectionFrame = talentFrame:AcquireTalentDisplayFrame(entryInfo.type, TalentSelectionChoiceMixin);

		newSelectionFrame:SetParent(self);

		local isCurrentSelection = entryID == currentSelection;
		newSelectionFrame:SetSelectionInfo(entryInfo, canSelectChoice, isCurrentSelection, baseCost);
		newSelectionFrame:Init(talentFrame);
		newSelectionFrame:SetEntryID(entryID);
		newSelectionFrame:Show();

		table.insert(self.selectionFrameArray, newSelectionFrame);
	end

	self:UpdateTrayLayout();
end

function TalentSelectionChoiceFrameMixin:UpdateSelectionOptions(canSelectChoice, currentSelection, baseCost)
	self.baseCost = baseCost;

	for i, selectionFrame in ipairs(self.selectionFrameArray) do
		local entryID = selectionFrame:GetEntryID();
		local isCurrentSelection = entryID == currentSelection;
		local entryInfo = self:GetTalentFrame():GetAndCacheEntryInfo(entryID);
		selectionFrame:SetSelectionInfo(entryInfo, canSelectChoice, isCurrentSelection);
	end
end

function TalentSelectionChoiceFrameMixin:GetBaseTraitCurrenciesCost()
	return self.baseCost;
end

function TalentSelectionChoiceFrameMixin:UpdateTrayLayout()
	local stride = 5;
	local xPadding = 10;
	local yPadding = 5;
	local layout = GridLayoutUtil.CreateStandardGridLayout(stride, xPadding, yPadding);

	local anchorOffset = TalentSelectionChoiceFramePadding;
	GridLayoutUtil.ApplyGridLayout(self.selectionFrameArray, AnchorUtil.CreateAnchor("TOPLEFT", self, "TOPLEFT", anchorOffset, -anchorOffset), layout);

	self.isTrayLayoutDirty = nil;

	self:Layout();
end

function TalentSelectionChoiceFrameMixin:SetSelectedEntryID(selectedEntryID, selectedTalentInfo)
	self.baseButton:SetSelectedEntryID(selectedEntryID, selectedTalentInfo);
	self:Hide();
end

function TalentSelectionChoiceFrameMixin:GetBaseButton()
	return self.baseButton;
end

function TalentSelectionChoiceFrameMixin:GetTalentFrame()
	return self:GetParent();
end


TalentSelectionChoiceMixin = {};

function TalentSelectionChoiceMixin:OnClick(button)
	EventRegistry:TriggerEvent("TalentButton.OnClick", self, button);
	
	local selectionChoiceFrame = self:GetParent();
	if button == "LeftButton" then
		if not self:IsChoiceAvailable() then
			return;
		end

		if self.isCurrentSelection then
			selectionChoiceFrame:Hide();
			return;
		end

		selectionChoiceFrame:SetSelectedEntryID(self:GetEntryID(), self:GetTalentInfo());
	else
		selectionChoiceFrame:Hide();
	end
end

function TalentSelectionChoiceMixin:AddTooltipInfo(tooltip)
	local rankShown = self.isCurrentSelection and 1 or 0;
	GameTooltip_AddHighlightLine(tooltip, TALENT_BUTTON_TOOLTIP_RANK_FORMAT:format(rankShown, self.entryInfo.maxRanks));
	GameTooltip_AddBlankLineToTooltip(tooltip);

	TalentDisplayMixin.AddTooltipInfo(self, tooltip);
end

function TalentSelectionChoiceMixin:AddTooltipCost(tooltip)
	local selectionChoiceFrame = self:GetParent();
	local traitCurrenciesCost = selectionChoiceFrame:GetBaseTraitCurrenciesCost();
	-- TODO:: Add in entry costs.
	selectionChoiceFrame:GetTalentFrame():AddCostToTooltip(tooltip, traitCurrenciesCost);
end

function TalentSelectionChoiceMixin:AddTooltipInstructions(tooltip)
	-- Overrides TalentDisplayMixin.

	if not self.isCurrentSelection and self:IsChoiceAvailable() then
		GameTooltip_AddBlankLineToTooltip(tooltip);
		GameTooltip_AddInstructionLine(tooltip, TALENT_BUTTON_TOOLTIP_SELECTION_INSTRUCTIONS);
	end
end

function TalentSelectionChoiceMixin:AddTooltipErrors(tooltip)
	-- Overrides TalentDisplayMixin.

	local shouldAddSpacer = true;
	self:GetTalentFrame():AddConditionsToTooltip(tooltip, self.entryInfo.conditionIDs, shouldAddSpacer);

	if self.isCurrentSelection then
		GameTooltip_AddBlankLineToTooltip(tooltip);
		GameTooltip_AddDisabledLine(tooltip, TALENT_BUTTON_TOOLTIP_SELECTION_CURRENT_INSTRUCTIONS);
	elseif not self:CanAffordChoice() then
		GameTooltip_AddBlankLineToTooltip(tooltip);
		GameTooltip_AddErrorLine(tooltip, TALENT_BUTTON_TOOLTIP_SELECTION_COST_ERROR);
	elseif not self.canSelectChoice then
		GameTooltip_AddBlankLineToTooltip(tooltip);
		GameTooltip_AddErrorLine(tooltip, TALENT_BUTTON_TOOLTIP_SELECTION_ERROR);
	elseif not self.entryInfo.isAvailable then
		GameTooltip_AddBlankLineToTooltip(tooltip);
		GameTooltip_AddErrorLine(tooltip, TALENT_BUTTON_TOOLTIP_SELECTION_CHOICE_ERROR);
	end
end

function TalentSelectionChoiceMixin:CalculateVisualState()
	-- Overrides TalentDisplayMixin.

	if self.isCurrentSelection then
		return TalentButtonUtil.BaseVisualState.Maxed;
	end

	return self:IsChoiceAvailable() and TalentButtonUtil.BaseVisualState.Selectable or TalentButtonUtil.BaseVisualState.Disabled;
end

function TalentSelectionChoiceMixin:CanAffordChoice()
	-- TODO:: Add in entry-specific costs, self:GetEntryID()

	local selectionChoiceFrame = self:GetParent();
	local traitCurrenciesCost = selectionChoiceFrame:GetBaseTraitCurrenciesCost();
	return selectionChoiceFrame:GetTalentFrame():CanAfford(traitCurrenciesCost);
end

function TalentSelectionChoiceMixin:IsChoiceAvailable()
	return self.canSelectChoice and self.entryInfo.isAvailable and self:CanAffordChoice();
end

function TalentSelectionChoiceMixin:SetSelectionInfo(entryInfo, canSelectChoice, isCurrentSelection)
	self.entryInfo = entryInfo;
	self.canSelectChoice = canSelectChoice;
	self.isCurrentSelection = isCurrentSelection;
	self:UpdateVisualState();
end

function TalentSelectionChoiceMixin:CanSelectChoice()
	return self.canSelectChoice;
end
