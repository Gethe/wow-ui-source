
local TalentSelectionChoiceFramePadding = 0;
local TalentSelectionChoiceFrameStride = 5;


TalentSelectionChoiceFrameMixin = {};

local TalentSelectionChoiceFrameEvents = {
	"GLOBAL_MOUSE_DOWN",
};

TalentSelectionChoiceFrameMixin.HorizontalSelectionPosition = {
	OuterLeft = 1,
	Inner = 2,
	OuterRight = 3
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
	self.selectionCount = 0;

	for i, entryID in ipairs(selectionOptions) do
		self.selectionCount = self.selectionCount + 1;
		local entryInfo = talentFrame:GetAndCacheEntryInfo(entryID);

		local choiceMixin = talentFrame:GetSpecializedSelectionChoiceMixin(entryInfo, entryInfo.type) or TalentSelectionChoiceMixin;

		local useLargeButton = true;
		local newSelectionFrame = talentFrame:AcquireTalentDisplayFrame(entryInfo.type, choiceMixin, useLargeButton);

		newSelectionFrame:SetParent(self);
		newSelectionFrame:Init(talentFrame);

		local isCurrentSelection = entryID == currentSelection;
		newSelectionFrame:SetEntryID(entryID);
		newSelectionFrame:SetSelectionInfo(entryInfo, canSelectChoice, isCurrentSelection, i);
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
		selectionFrame:SetSelectionInfo(entryInfo, canSelectChoice, isCurrentSelection, i);
	end
end

function TalentSelectionChoiceFrameMixin:GetBaseTraitCurrenciesCost()
	return self.baseCost;
end

function TalentSelectionChoiceFrameMixin:UpdateTrayLayout()
	local stride = TalentSelectionChoiceFrameStride;
	local xPadding = 5;
	local yPadding = 0;
	local layout = GridLayoutUtil.CreateStandardGridLayout(stride, xPadding, yPadding);

	local anchorOffset = TalentSelectionChoiceFramePadding;
	GridLayoutUtil.ApplyGridLayout(self.selectionFrameArray, AnchorUtil.CreateAnchor("TOPLEFT", self, "TOPLEFT", anchorOffset, -anchorOffset), layout);

	self.isTrayLayoutDirty = nil;

	self:Layout();
end

function TalentSelectionChoiceFrameMixin:SetSelectedEntryID(selectedEntryID, selectedDefinitionInfo)
	self.baseButton:SetSelectedEntryID(selectedEntryID, selectedDefinitionInfo);
	self:Hide();
end

function TalentSelectionChoiceFrameMixin:GetHorizontalSelectionPositionForIndex(index)
	if index == 1 then
		return TalentSelectionChoiceFrameMixin.HorizontalSelectionPosition.OuterLeft;
	elseif index == self:GetSelectionCount() then
		return TalentSelectionChoiceFrameMixin.HorizontalSelectionPosition.OuterRight;
	end

	local column = (index - 1) % TalentSelectionChoiceFrameStride + 1;
	if column == 1 then
		return TalentSelectionChoiceFrameMixin.HorizontalSelectionPosition.OuterLeft;
	elseif column == TalentSelectionChoiceFrameStride then
		return TalentSelectionChoiceFrameMixin.HorizontalSelectionPosition.OuterRight;
	else
		return TalentSelectionChoiceFrameMixin.HorizontalSelectionPosition.Inner;
	end
end

function TalentSelectionChoiceFrameMixin:GetSelectionCount()
	return self.selectionCount;
end

function TalentSelectionChoiceFrameMixin:GetBaseButton()
	return self.baseButton;
end

function TalentSelectionChoiceFrameMixin:GetTalentFrame()
	return self:GetParent();
end


TalentSelectionChoiceMixin = {};

function TalentSelectionChoiceMixin:Init(talentFrame)
	TalentDisplayMixin.Init(self, talentFrame);

	self:RegisterForClicks("LeftButtonDown", "RightButtonDown");
	self:RegisterForDrag("LeftButton");
end

function TalentSelectionChoiceMixin:OnClick(button)
	EventRegistry:TriggerEvent("TalentButton.OnClick", self, button);

	if self:IsInspecting() then
		return;
	end

	local selectionChoiceFrame = self:GetParent();
	if button == "LeftButton" then
		if IsShiftKeyDown() and self:CanCascadeRepurchaseRanks() then
			self:GetBaseButton():CascadeRepurchaseRanks();
			self:UpdateMouseOverInfo();
		elseif IsModifiedClick("CHATLINK") then
			local spellLink = GetSpellLink(self:GetSpellID());
			ChatEdit_InsertLink(spellLink);
		else
			if not self:IsChoiceAvailable() then
				return;
			end
	
			if self.isCurrentSelection then
				selectionChoiceFrame:Hide();
				return;
			end
	
			selectionChoiceFrame:SetSelectedEntryID(self:GetEntryID(), self:GetDefinitionInfo());
		end
	else
		if self:IsGhosted() then
			self:GetBaseButton():ClearCascadeRepurchaseHistory();
		end

		local baseButton = self:GetBaseButton();
		local nodeInfo = baseButton and baseButton:GetNodeInfo() or nil;
		if nodeInfo and nodeInfo.canRefundRank then
			selectionChoiceFrame:SetSelectedEntryID(nil);
		end
	end
end

function TalentSelectionChoiceMixin:OnDragStart()
	local spellID = self:GetSpellID();
	if spellID then
		local checkForPassive = true;
		PickupSpell(spellID, checkForPassive);
	end
end

function TalentSelectionChoiceMixin:AddTooltipInfo(tooltip)
	local rankShown = self.isCurrentSelection and 1 or 0;
	GameTooltip_AddHighlightLine(tooltip, TALENT_BUTTON_TOOLTIP_RANK_FORMAT:format(rankShown, self.entryInfo.maxRanks));
	GameTooltip_AddBlankLineToTooltip(tooltip);

	TalentDisplayMixin.AddTooltipInfo(self, tooltip);
end

function TalentSelectionChoiceMixin:AddTooltipCost(tooltip)
	local combinedCost = self:GetCombinedCost();
	local selectionChoiceFrame = self:GetParent();
	selectionChoiceFrame:GetTalentFrame():AddCostToTooltip(tooltip, combinedCost);
end

function TalentSelectionChoiceMixin:AddTooltipInstructions(tooltip)
	-- Overrides TalentDisplayMixin.

	if self:IsChoiceAvailable() then
		if self.isCurrentSelection then
			local baseButton = self:GetBaseButton();
			local nodeInfo = baseButton and baseButton:GetNodeInfo() or nil;
			if nodeInfo and nodeInfo.canRefundRank then
				GameTooltip_AddBlankLineToTooltip(tooltip);
				GameTooltip_AddDisabledLine(tooltip, TALENT_BUTTON_TOOLTIP_REFUND_INSTRUCTIONS);
			end
		else
			GameTooltip_AddBlankLineToTooltip(tooltip);
			GameTooltip_AddInstructionLine(tooltip, TALENT_BUTTON_TOOLTIP_PURCHASE_INSTRUCTIONS);
		end
	end

	if self:CanCascadeRepurchaseRanks() then
		GameTooltip_AddColoredLine(tooltip, TALENT_BUTTON_TOOLTIP_REPURCHASE_INSTRUCTIONS, BRIGHTBLUE_FONT_COLOR);
	elseif self:IsGhosted() then
		GameTooltip_AddBlankLineToTooltip(tooltip);
		GameTooltip_AddColoredLine(tooltip, TALENT_BUTTON_TOOLTIP_CLEAR_REPURCHASE_INSTRUCTIONS, BRIGHTBLUE_FONT_COLOR);
	end
end

function TalentSelectionChoiceMixin:AddTooltipErrors(tooltip)
	-- Overrides TalentDisplayMixin.

	local shouldAddSpacer = true;
	if self:GetTalentFrame():AddConditionsToTooltip(tooltip, self.entryInfo.conditionIDs, shouldAddSpacer) then
		return;
	end

	local baseButton = self:GetBaseButton();
	if baseButton then
		local nodeInfo = baseButton:GetNodeInfo();
		if self:GetTalentFrame():AddConditionsToTooltip(tooltip, nodeInfo.conditionIDs, shouldAddSpacer) then
			return;
		end

		if self:GetTalentFrame():AddEdgeRequirementsToTooltip(tooltip, baseButton:GetNodeID(), shouldAddSpacer) then
			return;
		end

		if not nodeInfo.meetsEdgeRequirements then
			GameTooltip_AddErrorLine(tooltip, TALENT_BUTTON_TOOLTIP_NO_ACTIVE_LINKS);
		end

		if not baseButton:IsSelectable() then
			return;
		end
	end

	if self.isCurrentSelection then
		GameTooltip_AddBlankLineToTooltip(tooltip);
		GameTooltip_AddDisabledLine(tooltip, TALENT_BUTTON_TOOLTIP_SELECTION_CURRENT_INSTRUCTIONS);
	elseif not self.canSelectChoice and not self:CanAffordChoice() then
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
	elseif self:IsInspecting() then
		return TalentButtonUtil.BaseVisualState.Disabled;
	end

	local selectionChoiceFrame = self:GetParent();
	local selectionBaseButton = selectionChoiceFrame:GetBaseButton();
	local selectionVisualState = selectionBaseButton:GetVisualState();
	if selectionVisualState == TalentButtonUtil.BaseVisualState.Gated then
		return TalentButtonUtil.BaseVisualState.Gated;
	end

	if selectionVisualState == TalentButtonUtil.BaseVisualState.Locked then
		return TalentButtonUtil.BaseVisualState.Locked;
	end

	return self:IsChoiceAvailable() and TalentButtonUtil.BaseVisualState.Selectable or TalentButtonUtil.BaseVisualState.Disabled;
end

function TalentSelectionChoiceMixin:ApplyVisualState(visualState)
	TalentButtonArtMixin.ApplyVisualState(self, visualState);

	self:UpdateSpendText();
end

function TalentSelectionChoiceMixin:GetCombinedCost()
	local selectionChoiceFrame = self:GetParent();
	local traitCurrenciesCost = selectionChoiceFrame:GetBaseTraitCurrenciesCost();
	local talentFrame = selectionChoiceFrame:GetTalentFrame();
	local entryInfo = talentFrame:GetAndCacheEntryInfo(self:GetEntryID());
	local combinedCost = TalentUtil.CombineCostArrays(traitCurrenciesCost, entryInfo.entryCost);
	return combinedCost;
end

function TalentSelectionChoiceMixin:CanAffordChoice()
	local combinedCost = self:GetCombinedCost();
	local selectionChoiceFrame = self:GetParent();
	return selectionChoiceFrame:GetTalentFrame():CanAfford(combinedCost);
end

function TalentSelectionChoiceMixin:IsChoiceAvailable()
	return self.canSelectChoice and self.entryInfo.isAvailable;
end

function TalentSelectionChoiceMixin:SetSelectionInfo(entryInfo, canSelectChoice, isCurrentSelection, selectionIndex)
	self.entryInfo = entryInfo;
	self.canSelectChoice = canSelectChoice;
	self.isCurrentSelection = isCurrentSelection;
	self.selectionIndex = selectionIndex;

	-- TODO: need a better way to handle additional visual states on top of base state
	self.isGhosted = self:IsGhosted();

	self:FullUpdate();
end

function TalentSelectionChoiceMixin:CanSelectChoice()
	return self.canSelectChoice;
end

function TalentSelectionChoiceMixin:UpdateSearchIcon()
	-- Overrides TalentButtonArtMixin.
	TalentButtonArtMixin.UpdateSearchIcon(self);

	if self.SearchIcon and self.SearchIcon:IsShown() then
		local horizontalPos = self:GetParent():GetHorizontalSelectionPositionForIndex(self.selectionIndex);
		if horizontalPos == TalentSelectionChoiceFrameMixin.HorizontalSelectionPosition.OuterLeft then
			self.SearchIcon:SetPoint("CENTER", self.Icon, "TOPLEFT");
		elseif horizontalPos == TalentSelectionChoiceFrameMixin.HorizontalSelectionPosition.Inner then
			self.SearchIcon:SetPoint("CENTER", self.Icon, "TOP");
		elseif horizontalPos == TalentSelectionChoiceFrameMixin.HorizontalSelectionPosition.OuterRight then
			self.SearchIcon:SetPoint("CENTER", self.Icon, "TOPRIGHT");
		end
	end
end

function TalentSelectionChoiceMixin:UpdateSpendText()
	local nodeInfo = self:GetNodeInfo();
	if self.isCurrentSelection and nodeInfo and (nodeInfo.currentRank > 0) and
		not self:GetParent():GetTalentFrame():ShouldHideSingleRankNumbers() then
		TalentButtonUtil.SetSpendText(self, tostring(nodeInfo.currentRank));
	else
		TalentButtonUtil.SetSpendText(self, "");
	end
end

function TalentSelectionChoiceMixin:IsCascadeRepurchasable()
	local nodeInfo = self:GetNodeInfo();
	return nodeInfo and nodeInfo.isCascadeRepurchasable and nodeInfo.cascadeRepurchaseEntryID == self:GetEntryID() and self:CanAffordChoice();
end

function TalentSelectionChoiceMixin:CanCascadeRepurchaseRanks()
	local baseSelectButton = self:GetBaseButton();

	local isLocked = not baseSelectButton or baseSelectButton:IsLocked();
	local isGated = not baseSelectButton or baseSelectButton:IsGated();

	return not isLocked and not isGated and self:IsCascadeRepurchasable();
end

function TalentSelectionChoiceMixin:IsGhosted()
	return not self:GetNodeInfo() or (self:IsCascadeRepurchasable() and not self:IsChoiceAvailable());
end

function TalentSelectionChoiceMixin:GetSpellID()
	-- Overrides TalentDisplayMixin.
	local definitionInfo = self:GetDefinitionInfo();
	return definitionInfo and definitionInfo.spellID or nil;
end

function TalentSelectionChoiceMixin:GetBaseButton()
	local selectionChoiceFrame = self:GetParent();
	return selectionChoiceFrame and selectionChoiceFrame:GetBaseButton() or nil;
end

function TalentSelectionChoiceMixin:GetNodeInfo()
	local selectionBaseButton = self:GetBaseButton();
	return selectionBaseButton and selectionBaseButton:GetNodeInfo() or nil;
end