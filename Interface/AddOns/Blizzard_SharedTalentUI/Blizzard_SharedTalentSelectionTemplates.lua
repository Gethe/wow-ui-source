
TalentSelectionChoiceFrameMixin = {};

local TALENT_SELECTION_FRAME_DIALOG_STYLE_EVENTS = {
	"GLOBAL_MOUSE_DOWN",
	"GLOBAL_MOUSE_UP",
};

TalentSelectionChoiceFrameMixin.HorizontalSelectionPosition = {
	OuterLeft = 1,
	Inner = 2,
	OuterRight = 3
};

function TalentSelectionChoiceFrameMixin:OnLoad()
	self.selectionFrameArray = {};
end

function TalentSelectionChoiceFrameMixin:OnShow()
	BaseLayoutMixin.OnShow(self);

	if self.dialogStyle then
		FrameUtil.RegisterFrameForEvents(self, TALENT_SELECTION_FRAME_DIALOG_STYLE_EVENTS);
	end
end

function TalentSelectionChoiceFrameMixin:OnHide()
	if self.dialogStyle then
		FrameUtil.UnregisterFrameForEvents(self, TALENT_SELECTION_FRAME_DIALOG_STYLE_EVENTS);
	end
end

function TalentSelectionChoiceFrameMixin:OnEvent(event, ...)
	if event == "GLOBAL_MOUSE_DOWN" then
		local buttonName = ...;
		FrameUtil.DialogStyleGlobalMouseDown(self, buttonName);
	elseif event == "GLOBAL_MOUSE_UP" then
		if not DoesAncestryIncludeAny(self, GetMouseFoci()) then
			self:Hide();
		end
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
		newSelectionFrame:SetLayoutIndex(i);

		-- Set a default point so that dependent frames can be resolved if they need to be.
		-- This is required for descendant resize layout frames like TalentFrameStarGridTemplate.
		newSelectionFrame:SetPoint("CENTER");

		local isCurrentSelection = entryID == currentSelection;
		newSelectionFrame:SetEntryID(entryID);
		newSelectionFrame:SetSelectionInfo(entryInfo, canSelectChoice, isCurrentSelection, i);
		newSelectionFrame:Show();

		table.insert(self.selectionFrameArray, newSelectionFrame);
	end

	self:Layout();
end

function TalentSelectionChoiceFrameMixin:UpdateSelectionOptions(canSelectChoice, currentSelection, baseCost)
	self.baseCost = baseCost;

	for i, selectionFrame in ipairs(self.selectionFrameArray) do
		local entryID = selectionFrame:GetEntryID();
		local isCurrentSelection = entryID == currentSelection;
		local entryInfo = self:GetTalentFrame():GetAndCacheEntryInfo(entryID);
		selectionFrame:SetSelectionInfo(entryInfo, canSelectChoice, isCurrentSelection, i);
		selectionFrame:UpdateSpendText();
	end
end

function TalentSelectionChoiceFrameMixin:GetBaseTraitCurrenciesCost()
	return self.baseCost;
end

function TalentSelectionChoiceFrameMixin:UpdateVisualState()
	for i, selectionFrame in ipairs(self.selectionFrameArray) do
		selectionFrame:UpdateVisualState();
		selectionFrame:UpdateSpendText();
	end
end

function TalentSelectionChoiceFrameMixin:SetSelectedEntryID(selectedEntryID)
	self.baseButton:SetSelectedEntryID(selectedEntryID);

	if self.dialogStyle then
		self:Hide();
	end
end

function TalentSelectionChoiceFrameMixin:GetHorizontalSelectionPositionForIndex(index)
	if index == 1 then
		return TalentSelectionChoiceFrameMixin.HorizontalSelectionPosition.OuterLeft;
	elseif index == self:GetSelectionCount() then
		return TalentSelectionChoiceFrameMixin.HorizontalSelectionPosition.OuterRight;
	end

	local column = (index - 1) % self.stride + 1;
	if column == 1 then
		return TalentSelectionChoiceFrameMixin.HorizontalSelectionPosition.OuterLeft;
	elseif column == self.stride then
		return TalentSelectionChoiceFrameMixin.HorizontalSelectionPosition.OuterRight;
	else
		return TalentSelectionChoiceFrameMixin.HorizontalSelectionPosition.Inner;
	end
end

function TalentSelectionChoiceFrameMixin:IsDraggingSpell()
	if not IsMouseButtonDown("LeftButton") then
		return false;
	end

	local type, _, _, spellID = GetCursorInfo();
	if type ~= "spell" then
		return false;
	end

	for i, selectionFrame in ipairs(self.selectionFrameArray) do
		if selectionFrame:GetSpellID() == spellID then
			return true;
		end
	end

	return false;
end

function TalentSelectionChoiceFrameMixin:GetSelectionCount()
	return self.selectionCount;
end

function TalentSelectionChoiceFrameMixin:GetBaseButton()
	return self.baseButton;
end

function TalentSelectionChoiceFrameMixin:SetTalentFrame(talentFrame)
	self.talentFrame = talentFrame;
end

function TalentSelectionChoiceFrameMixin:GetTalentFrame()
	return self.talentFrame;
end


TalentSelectionChoiceMixin = {};

function TalentSelectionChoiceMixin:Init(talentFrame)
	TalentDisplayMixin.Init(self, talentFrame);

	self:RegisterForClicks("LeftButtonDown", "RightButtonDown");
	self:RegisterForDrag("LeftButton");

	local function OnShowHandler()
		self:UpdateSpendText();
	end

	-- This has to be set after Init to avoid causing problems before the frame is ready to update.
	self:SetScript("OnShow", OnShowHandler);
end

-- This is installed dynamically in Init.
-- function TalentSelectionChoiceMixin:OnShow()

function TalentSelectionChoiceMixin:OnClick(button)
	EventRegistry:TriggerEvent("TalentButton.OnClick", self, button);

	if self:IsInspecting() then
		return;
	end

	local selectionChoiceFrame = self:GetParent();
	if button == "LeftButton" then
		if IsShiftKeyDown() and self:CanCascadeRepurchaseRanks() then
			local baseButton = self:GetBaseButton();
			if baseButton then
				baseButton:CascadeRepurchaseRanks();
				self:UpdateMouseOverInfo();
			end
		elseif IsModifiedClick("CHATLINK") then
			local spellLink = C_Spell.GetSpellLink(self:GetSpellID());
			ChatFrameUtil.InsertLink(spellLink);
		else
			if not self:IsChoiceAvailable() then
				return;
			end

			if self.isCurrentSelection then
				if self:CanPurchaseRank() then
					self:PurchaseRank();
					self:UpdateSpendText();
				end
				return;
			end

			selectionChoiceFrame:SetSelectedEntryID(self:GetEntryID());
		end
	elseif not self:GetTalentFrame():IsLocked() then
		local baseButton = self:GetBaseButton();
		if baseButton and self:IsGhosted() then
			baseButton:ClearCascadeRepurchaseHistory();
		end

		local nodeInfo = baseButton and baseButton:GetNodeInfo() or nil;
		if nodeInfo and nodeInfo.canRefundRank then
			selectionChoiceFrame:SetSelectedEntryID(nil);
		end
	end
end

function TalentSelectionChoiceMixin:OnDragStart()
	local spellID = self:GetSpellID();
	if spellID and not C_Spell.IsSpellPassive(spellID) then
		C_Spell.PickupSpell(spellID);
	end
end

function TalentSelectionChoiceMixin:CanPurchaseRank()
	local baseButton = self:GetBaseButton();
	return baseButton.nodeInfo and not baseButton:IsInspecting() and not baseButton:IsLocked() and baseButton.nodeInfo.canPurchaseRank and baseButton:CanAfford();
end

function TalentSelectionChoiceMixin:CanRefundRank()
	local baseButton = self:GetBaseButton();
	return baseButton.nodeInfo and not baseButton:IsInspecting() 
		and not baseButton:GetTalentFrame():IsLocked() 
		and baseButton.nodeInfo.canRefundRank 
		and baseButton.nodeInfo.ranksPurchased 
		and (baseButton.nodeInfo.ranksPurchased > 0);
end

function TalentSelectionChoiceMixin:PurchaseRank()
	local baseButton = self:GetBaseButton();
	baseButton:PlaySelectSound();
	baseButton:GetTalentFrame():PurchaseRank(baseButton:GetNodeID());
	baseButton:UpdateMouseOverInfo();
end

function TalentSelectionChoiceMixin:AddTooltipInfo(tooltip)
	local baseButton = self:GetBaseButton();
	local nodeInfo = self:GetNodeInfo();
	local increasedRanks = nodeInfo.entryIDToRanksIncreased and nodeInfo.entryIDToRanksIncreased[self:GetEntryID()] or 0;
	local hasIncreasedRanks = increasedRanks and increasedRanks > 0;
	local rankShown = self.isCurrentSelection and (nodeInfo and nodeInfo.currentRank or 0) or increasedRanks;
	local rankColor = hasIncreasedRanks and GREEN_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
	rankShown = rankColor:WrapTextInColorCode(rankShown);
	
	local rankLine = TALENT_BUTTON_TOOLTIP_RANK_FORMAT:format(rankShown, self.entryInfo.maxRanks);
	if FlagsUtil.IsSet(nodeInfo.flags, Enum.TraitNodeFlag.HideMaxRank) then
		rankLine = TALENT_BUTTON_TOOLTIP_RANK_NO_MAX_FORMAT:format(rankShown);
	end

	GameTooltip_AddHighlightLine(tooltip, rankLine);

	if hasIncreasedRanks then
		local increasedTraitDataList = C_Traits.GetIncreasedTraitData(baseButton:GetNodeID(), self:GetEntryID());
		for	_index, increasedTraitData in ipairs(increasedTraitDataList) do
			local r, g, b = C_Item.GetItemQualityColor(increasedTraitData.itemQualityIncreasing);
			local qualityColor = CreateColor(r, g, b, 1);
			local coloredItemName = qualityColor:WrapTextInColorCode(increasedTraitData.itemNameIncreasing);
			local wrapText = true;
			GameTooltip_AddColoredLine(tooltip, TALENT_FRAME_INCREASED_RANKS_TEXT:format(increasedTraitData.numPointsIncreased, coloredItemName), GREEN_FONT_COLOR, wrapText);
		end
	end

	GameTooltip_AddBlankLineToTooltip(tooltip);

	TalentDisplayMixin.AddTooltipInfo(self, tooltip);
end

function TalentSelectionChoiceMixin:AddTooltipCost(tooltip)
	-- Only show cost if we can refund or increase the rank.
	local baseButton = self:GetBaseButton();
	local nodeInfo = baseButton and baseButton:GetNodeInfo() or nil;
	if (not baseButton or not baseButton:IsMaxed()) or (not nodeInfo or nodeInfo.canRefundRank) then
		local combinedCost = self:GetCombinedCost();
		local selectionChoiceFrame = self:GetParent();
		selectionChoiceFrame:GetTalentFrame():AddCostToTooltip(tooltip, combinedCost);
	end
end

function TalentSelectionChoiceMixin:AddTooltipInstructions(tooltip)
	-- Overrides TalentDisplayMixin.

	if self.isCurrentSelection then
		if not self:GetTalentFrame():IsLocked() then
			local baseButton = self:GetBaseButton();
			local nodeInfo = baseButton and baseButton:GetNodeInfo() or nil;
			if nodeInfo and nodeInfo.canRefundRank then
				GameTooltip_AddBlankLineToTooltip(tooltip);
				GameTooltip_AddDisabledLine(tooltip, TALENT_BUTTON_TOOLTIP_REFUND_INSTRUCTIONS);
			end
		end
	elseif self:IsChoiceAvailable() then
		GameTooltip_AddBlankLineToTooltip(tooltip);
		GameTooltip_AddInstructionLine(tooltip, TALENT_BUTTON_TOOLTIP_PURCHASE_INSTRUCTIONS);
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

	local baseButton = self:GetBaseButton();
	if self.isCurrentSelection and baseButton then
		local isRefundInvalid, refundInvalidInstructions = baseButton:IsRefundInvalid();
		if TalentButtonUtil.CheckAddRefundInvalidInfo(tooltip, isRefundInvalid, refundInvalidInstructions) then
			return;
		end
	end

	local talentFrame = self:GetTalentFrame();

	local shouldAddSpacer = true;
	if talentFrame:AddConditionsToTooltip(tooltip, self.entryInfo.conditionIDs, shouldAddSpacer) then
		return;
	end

	if baseButton then
		local nodeInfo = baseButton:GetNodeInfo();
		if talentFrame:AddConditionsToTooltip(tooltip, nodeInfo.conditionIDs, shouldAddSpacer) then
			return;
		end

		if talentFrame:AddEdgeRequirementsToTooltip(tooltip, baseButton:GetNodeID(), shouldAddSpacer) then
			return;
		end

		local isLocked, errorMessage = talentFrame:IsLocked();
		if isLocked and errorMessage then
			GameTooltip_AddBlankLineToTooltip(tooltip);
			GameTooltip_AddErrorLine(tooltip, errorMessage);
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

function TalentSelectionChoiceMixin:GetTooltipEntryInfoInternal()
	local tooltipEntryInfo = {};
	local ranksIncreased = 0;

	local nodeInfo = self:GetBaseButton():GetNodeInfo();
	if nodeInfo then
		tooltipEntryInfo.currEntryInfo = CopyTableSafe(nodeInfo.activeEntry);
		tooltipEntryInfo.nextEntryInfo = CopyTableSafe(nodeInfo.nextEntry);
		tooltipEntryInfo.ranksPurchased = nodeInfo.ranksPurchased;

		if not nodeInfo.activeEntry or nodeInfo.activeEntry.entryID ~= self.entryID then
			-- This is a non-active entry in a selection node, so the base rank will always be zero
			tooltipEntryInfo.currEntryInfo = {
				entryID = self.entryID,
				rank = 0,
			}

			tooltipEntryInfo.ranksPurchased = 0;
		end

		ranksIncreased = nodeInfo.entryIDToRanksIncreased and nodeInfo.entryIDToRanksIncreased[self.entryID] or nodeInfo.ranksIncreased;
	end

	return tooltipEntryInfo, ranksIncreased;
end

function TalentSelectionChoiceMixin:CalculateVisualState()
	-- Overrides TalentDisplayMixin.

	local selectionChoiceFrame = self:GetParent();
	local selectionBaseButton = selectionChoiceFrame:GetBaseButton();
	local selectionVisualState = selectionBaseButton:GetVisualState();
	if selectionVisualState == TalentButtonUtil.BaseVisualState.RefundInvalid then
		if self.isCurrentSelection then
			return selectionVisualState;
		end

		if selectionBaseButton:HasIncreasedRanks() then
			return TalentButtonUtil.BaseVisualState.Maxed;
		end

		if selectionBaseButton:IsGated() then
			return TalentButtonUtil.BaseVisualState.Gated;
		end

		if selectionBaseButton:IsLocked() then
			return TalentButtonUtil.BaseVisualState.Locked;
		end

		local nodeInfo = selectionBaseButton:GetNodeInfo();
		if nodeInfo and nodeInfo.increasedRanks then
			return TalentButtonUtil.BaseVisualState.Maxed;
		end

		return TalentButtonUtil.BaseVisualState.Disabled;
	elseif self.isCurrentSelection then
		-- The entry must be selected before it should be visually displayed as an error.
		if self.entryInfo.isDisplayError then
			return TalentButtonUtil.BaseVisualState.DisplayError;
		end

		local increasedRanks = selectionBaseButton.nodeInfo.entryIDToRanksIncreased and selectionBaseButton.nodeInfo.entryIDToRanksIncreased[selectionBaseButton:GetEntryID()] or 0;
		if (selectionBaseButton.nodeInfo.currentRank - increasedRanks) < selectionBaseButton.nodeInfo.maxRanks then
			return TalentButtonUtil.BaseVisualState.Selectable;
		end
		return TalentButtonUtil.BaseVisualState.Maxed;
	elseif self:IsInspecting() then
		return TalentButtonUtil.BaseVisualState.Disabled;
	elseif not self:IsChoiceAvailable() and selectionBaseButton:HasIncreasedRanks() then
		return TalentButtonUtil.BaseVisualState.Maxed;
	elseif selectionVisualState == TalentButtonUtil.BaseVisualState.Gated then
		return selectionVisualState;
	elseif selectionVisualState == TalentButtonUtil.BaseVisualState.Locked then
		return selectionVisualState;
	end

	return self:IsChoiceAvailable() and TalentButtonUtil.BaseVisualState.Selectable or TalentButtonUtil.BaseVisualState.Disabled;
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
	return self.canSelectChoice and self.entryInfo.isAvailable and not self:GetTalentFrame():IsLocked();
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

function TalentSelectionChoiceMixin:CalculateSpendText()
	local nodeInfo = self:GetNodeInfo();
	if not self:GetParent():GetTalentFrame():ShouldHideSingleRankNumbers() or (nodeInfo and nodeInfo.maxRanks > 1) then
		if not self.isCurrentSelection then
			if nodeInfo then
				local increasedRanks = nodeInfo.entryIDToRanksIncreased and nodeInfo.entryIDToRanksIncreased[self:GetEntryID()];
				if increasedRanks and increasedRanks > 0 then
					return tostring(increasedRanks);
				end
			end

			if self:IsChoiceAvailable() then
				return "0";
			end
		else
			if nodeInfo then
				return tostring(nodeInfo.currentRank);
			end
		end
	end

	return "";
end

function TalentSelectionChoiceMixin:UpdateSpendText()
	TalentButtonUtil.SetSpendText(self, self:CalculateSpendText());
end

function TalentSelectionChoiceMixin:IsCascadeRepurchasable()
	if not TalentButtonUtil.IsCascadeRepurchaseHistoryEnabled() then
		return false;
	end

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
	if not TalentButtonUtil.IsCascadeRepurchaseHistoryEnabled() then
		return false;
	end

	return not self:GetNodeInfo() or self:IsCascadeRepurchasable();
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

function TalentSelectionChoiceMixin:IsInDeactivatedSubTree()
	local selectionBaseButton = self:GetBaseButton();
	return selectionBaseButton:IsInDeactivatedSubTree();
end

function TalentSelectionChoiceMixin:IsInspecting()
	local selectionBaseButton = self:GetBaseButton();
	return selectionBaseButton:IsInspecting();
end

function TalentSelectionChoiceMixin:ShouldShowTooltipErrors()
	local selectionBaseButton = self:GetBaseButton();
	return selectionBaseButton:ShouldShowTooltipErrors();
end

TalentSelectionChoiceArtMixin = CreateFromMixins(TalentSelectionChoiceMixin);

function TalentSelectionChoiceArtMixin:UpdateSearchIcon()
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

function TalentSelectionChoiceArtMixin:ApplyVisualState(visualState)
	TalentButtonArtMixin.ApplyVisualState(self, visualState);

	self:UpdateSpendText();
end
