
LegacyTreeUtil = {};

local LEGACY_SQUARE_TALENT_TYPES = {
	[Enum.TraitNodeEntryType.SpendSquare] = true,
	[Enum.TraitNodeEntryType.SpendCircle] = true,
};

function LegacyTreeUtil.GetTemplateForTalentType(nodeInfo, talentType, useLarge)
	local isSelection = nodeInfo and ((nodeInfo.type == Enum.TraitNodeType.Selection) or (nodeInfo.type == Enum.TraitNodeType.SubTreeSelection));
	if not isSelection and not useLarge and LEGACY_SQUARE_TALENT_TYPES[talentType] then
		return "TalentButtonLegacySquareTemplate";
	end

	return TalentButtonUtil.GetTemplateForTalentType(nodeInfo, talentType, useLarge);
end

function LegacyTreeUtil.GetEdgeTemplateType(edgeVisualStyle)
	return "LegacyTreeTraitEdgeArrowTemplate";
end

LegacyTreePageMixin = {};

function LegacyTreePageMixin:OnShow()
	self:GetParent():SetTitle(LEGACY_TREE_FRAME_TITLE);
end

LegacyTreeTraitPanelMixin = CreateFromMixins(ClassTalentSearchMixin);

function LegacyTreeTraitPanelMixin:OnLoad()
	TalentFrameBaseMixin.OnLoad(self);

	self.ApplyButton:SetOnClickHandler(GenerateClosure(self.ApplyConfig, self));
	self.ApplyButton:SetOnEnterHandler(GenerateClosure(self.UpdateConfigButtonsState, self));
	self.UndoButton:SetOnClickHandler(GenerateClosure(self.RollbackConfig, self));
	self.ResetButton:SetOnClickHandler(GenerateClosure(self.ResetTree, self));

	self:InitializeSearch();

	self.selectedTreeIdx = 1;

	EventRegistry:RegisterCallback("Legacy.SelectTree", function(_, info)
		self:SelectTree(info);
	end, self);

	EventRegistry:RegisterCallback("TalentFrameBase.ConfigUpdated", function(_)
			self:UpdateConfigButtonsState();
	end, self);
end

function LegacyTreeTraitPanelMixin:OnShow()
	TalentFrameBaseMixin.OnShow(self);

	EventRegistry:TriggerEvent("Legacy.SelectTree", self.selectedTreeIdx);

	self:UpdateConfigButtonsState();
end

function LegacyTreeTraitPanelMixin:OnUpdate()
	TalentFrameBaseMixin.OnUpdate(self);

	self:UpdateFullSearchResults();

	self:UpdateConfigButtonsState();
end

function LegacyTreeTraitPanelMixin:SelectTree(index)
	self.selectedTreeIdx = index;
	local treeData = LegacyTreeData[index];
	local traitTreeID = treeData.treeID;
	local configID = C_Traits.GetConfigIDByTreeID(traitTreeID);
	self:SetConfigID(configID);

	local forceUpdate = true;
	self:SetTalentTreeID(traitTreeID, forceUpdate);

	self.SelectedTreeIcon:SetIconAtlas(treeData.iconAtlas);
	self.SelectedTreeIcon.SelectedTreeLabel:SetText(treeData.name);

	self:UpdateConfigButtonsState();
end

function LegacyTreeTraitPanelMixin:GetTraitTreeName(traitTreeID, groupIDs)
	for _, legacyTree in pairs(LegacyTreeData) do
		if legacyTree.treeID == traitTreeID then
			return legacyTree.name;
		end
	end
	return "";
end

function LegacyTreeTraitPanelMixin:UpdateTreeCurrencyInfo()
	TalentFrameBaseMixin.UpdateTreeCurrencyInfo(self);

	local currencyInfo = self.treeCurrencyInfo and self.treeCurrencyInfo[1] or nil;
	local shouldUpdate = currencyInfo ~= nil;
	if shouldUpdate then
		self.SpentPointsFrame.Text:SetText(currencyInfo.spentInTree);

		local indexOf1 = string.find(currencyInfo.spentInTree, "1");
		if indexOf1 == 1 then
			self.SpentPointsFrame.Text:SetPoint("CENTER", -2, -1);
		else
			self.SpentPointsFrame.Text:SetPoint("CENTER", 0, -1);
		end

		currencyInfo.renownCurrency = C_MajorFactions.GetCurrentRenownLevel(Constants.LegacyConsts.LEGACY_REWARD_TRACK_FACTION_ID);

		EventRegistry:TriggerEvent("Legacy.UpdateCurrencyInfo", currencyInfo);
		self:RefreshConditionsCache();
	end
end

function LegacyTreeTraitPanelMixin:ApplyConfig()
	if self:HasAnyConfigChanges() then
		self:CommitConfig();
	end

	self:UpdateConfigButtonsState();
end

function LegacyTreeTraitPanelMixin:RollbackConfig(...)
	TalentFrameBaseMixin.RollbackConfig(self, ...);

	self:UpdateTreeCurrencyInfo();
	self:UpdateConfigButtonsState();
end

function LegacyTreeTraitPanelMixin:ResetTree()
	C_Traits.ResetTree(self:GetConfigID(), self:GetTalentTreeID());
end

function LegacyTreeTraitPanelMixin:HasValidConfig()
	return self:GetConfigID() ~= nil;
end

function LegacyTreeTraitPanelMixin:HasAnyConfigChanges()
	if self:IsCommitInProgress() then
		return false;
	end

	return self:HasValidConfig() and C_Traits.ConfigHasStagedChanges(self:GetConfigID());
end

function LegacyTreeTraitPanelMixin:GetConfigApplicationState()
	local anyChangesPending = self:HasAnyConfigChanges();
	local canApplyChanges = anyChangesPending and not self:IsCommitInProgress();
	local applyDisabledTooltip = nil;

	return anyChangesPending, canApplyChanges, applyDisabledTooltip;
end

function LegacyTreeTraitPanelMixin:UpdateConfigButtonsState()
	local anyChangesPending, canApplyChanges, applyDisabledTooltip = self:GetConfigApplicationState();

	self.ApplyButton:SetEnabled(canApplyChanges);
	self.ApplyButton:SetDisabledTooltip(applyDisabledTooltip);

	if anyChangesPending then
		TalentFrameBaseMixin.ShowOrHideGlowOnChangesPending(self);
	else
		GlowEmitterFactory:Hide(self.ApplyButton);
		self.ApplyButton.YellowGlow:Hide();
	end

	local shouldShowUndo = self:HasAnyConfigChanges() and not self.isConfigReadyToApply;
	self.UndoButton:SetShown(shouldShowUndo);
	self.ResetButton:SetShown(not shouldShowUndo);
	self.ResetButton:SetEnabledState(self:HasValidConfig() and self:HasAnyPurchasedRanks() and not self:IsCommitInProgress());

	if InputUtil.IsGamepadUIEnabled() then
		local TREE_PAGE_IDX = 3;
		local gamepadFooter = self:GetParent():GetParent().footers[TREE_PAGE_IDX];
		if gamepadFooter then
			self.ResetButton:ClearAllPoints();
			self.ResetButton:SetPoint("LEFT", self.ApplyButton, "RIGHT", 14, 0);
			gamepadFooter:Refresh();
		end
	end
end

function LegacyTreeTraitPanelMixin:GetDefinitionInfoForEntry(entryID)
	local definitionID = self:GetAndCacheEntryInfo(entryID).definitionID;
	if definitionID then
		return self:GetAndCacheDefinitionInfo(definitionID);
	end
	return nil;
end

function LegacyTreeTraitPanelMixin:GetSubTreeInfoForEntry(entryID)
	local subTreeID = self:GetAndCacheEntryInfo(entryID).subTreeID;
	if subTreeID then
		return self:GetAndCacheSubTreeInfo(subTreeID);
	end
	return nil;
end

LegacyTreeSelectionPanelMixin = {};

function LegacyTreeSelectionPanelMixin:OnLoad()
	self.treeButtonPool = CreateFramePoolCollection();
	self.treeButtonPool:CreatePool("CHECKBUTTON", self.TreeSelections, "LegacyTreeButtonTemplate");

	EventRegistry:RegisterCallback("Legacy.SelectTree", function(_, idx)
		self:UpdateSelection(idx);
	end, self);

	self:RefreshTreeButtons();
end

function LegacyTreeSelectionPanelMixin:RefreshTreeButtons()
	self.treeButtonPool:ReleaseAll();
	self.treeButtons = {};

	for i, treeData in ipairs(LegacyTreeData) do
		local button = self.treeButtonPool:Acquire("LegacyTreeButtonTemplate");
		button.layoutIndex = i;
		button:SetupLegacyTreeButton(treeData);
		button:Show();
		table.insert(self.treeButtons, button);
	end

	self.TreeSelections:Layout();
end

function LegacyTreeSelectionPanelMixin:UpdateSelection(selectedIdx)
	for i, button in ipairs(self.treeButtons) do
		button:SetChecked(i == selectedIdx);
		button:RefreshSelectionVisuals();
	end
end

LegacyTreeButtonMixin = CreateFromMixins(SelectableButtonMixin);

function LegacyTreeButtonMixin:OnLoad()
	RingedMaskedButtonMixin.OnLoad(self);
	SelectableButtonMixin.OnLoad(self);

	-- SelectedGlow conveys selection instead; keep the checked texture for highlight anchoring but invisible.
	self.CheckedTexture:SetAlpha(0);

	-- Base OnLoad only stores highlightAtlas; HighlightTexture has no atlas until this runs.
	self:RefreshSelectionVisuals();
end

function LegacyTreeButtonMixin:OnSelected(newSelected)
	self:SetChecked(newSelected);
	self:RefreshSelectionVisuals();
end

function LegacyTreeButtonMixin:RefreshSelectionVisuals()
	self:UpdateHighlightTexture();
	self.SelectedGlow:SetShown(self:GetChecked());
end

function LegacyTreeButtonMixin:SetupLegacyTreeButton(data)
	self.treeData = data;
	self:SetIconAtlas(data.iconAtlas);

	self:ClearTooltipLines();
	self:AddTooltipLine(data.name);
end

function LegacyTreeButtonMixin:GetAppropriateTooltip()
	return GetAppropriateTooltip();
end

function LegacyTreeButtonMixin:OnClick()
	SelectableButtonMixin.OnClick(self);
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);

	EventRegistry:TriggerEvent("Legacy.SelectTree", self.layoutIndex);
end	

LegacyTreeIconMixin = CreateFromMixins(SelectableButtonMixin);

function LegacyTreeIconMixin:OnLoad()
	RingedMaskedButtonMixin.OnLoad(self);
	SelectableButtonMixin.OnLoad(self);
end


function LegacyTreeIconMixin:OnClick()
	-- No-op, this doesn't need to be clickable
end	

function LegacyTreeIconMixin:GetAppropriateTooltip()
	return nil;
end

LegacyTreePointSummaryMixin = {};

function LegacyTreePointSummaryMixin:OnLoad()
	EventRegistry:RegisterCallback("Legacy.UpdateCurrencyInfo", function(_, info)
		self:RefreshText(info);
	end, self);
end

function LegacyTreePointSummaryMixin:OnEnter()
	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(self, "ANCHOR_RIGHT", -4, -10);
	tooltip:SetText(self.tooltipText);
	tooltip:Show();
end

function LegacyTreePointSummaryMixin:OnLeave()
	GetAppropriateTooltip():Hide();
end

function LegacyTreePointSummaryMixin:RefreshText(currencyInfo)
	local legacyPointsCurrencyAvailable = currencyInfo.quantity;
	local legacyPointText = LEGACY_POINTS_AMOUNT:format(legacyPointsCurrencyAvailable);
	self.AvailablePointsLabel:SetFormattedText(LEGACY_POINTS_AVAILABLE, legacyPointText);

	self.tooltipText = LEGACY_POINTS_SEASONAL_CAP:format(currencyInfo.maxQuantity);

	self.Shield.Points:SetText(currencyInfo.renownCurrency);
end
