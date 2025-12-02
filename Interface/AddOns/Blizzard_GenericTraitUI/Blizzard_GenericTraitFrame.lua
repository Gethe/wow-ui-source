
UIPanelWindows["GenericTraitFrame"] = {
	area = "left",
	checkFit = 1,
	checkFitExtraWidth = 40,
	checkFitExtraHeight = 40,
};

local FrameLevelPerRow = 10;
local TotalFrameLevelSpread = 500;
local BaseYOffset = 1500;
local BaseRowHeight = 600;

GenericTraitFrameMixin = {};

local GenericTraitFrameEvents = {
	"TRAIT_SYSTEM_NPC_CLOSED",
	"TRAIT_TREE_CURRENCY_INFO_UPDATED",
};

function GenericTraitFrameMixin:OnLoad()
	TalentFrameBaseMixin.OnLoad(self);

	-- Show costs by default.
	self:SetTreeCurrencyDisplayTextCallback(TalentFrameUtil.GenerateTreeCurrencyDisplayCallback());
end

function GenericTraitFrameMixin:ApplyLayout(layoutInfo)
	self:SetSize(layoutInfo.FrameSize.Width, layoutInfo.FrameSize.Height);
	self.Background:SetAtlas(layoutInfo.BackgroundAtlas);
	self.Header.Title:SetText(layoutInfo.Title or "");
	self.Header:SetSize(layoutInfo.HeaderSize.Width, layoutInfo.HeaderSize.Height);
	self.Header.TitleDivider:SetAtlas(layoutInfo.TitleDividerAtlas, true);
	self.Header.TitleDivider:SetShown(layoutInfo.TitleDividerShown);
	self.Inset:SetShown(layoutInfo.ShowInset);
	self.Header:SetPoint("TOP", layoutInfo.HeaderOffset.x, layoutInfo.HeaderOffset.y);
	self.Currency:SetPoint("TOPRIGHT", self.Header, "BOTTOMRIGHT", layoutInfo.CurrencyOffset.x, layoutInfo.CurrencyOffset.y);
	self.Currency.CurrencyBackground:SetAtlas(layoutInfo.CurrencyBackgroundAtlas, true);

	self.CloseButton:SetPoint("TOPRIGHT", self, "TOPRIGHT", layoutInfo.CloseButtonOffset.x, layoutInfo.CloseButtonOffset.y);

	local useNewNineSlice = not layoutInfo.UseOldNineSlice;

	self.NineSlice:SetShown(layoutInfo.NineSliceTextureKit ~= nil and not useNewNineSlice);
	self.BorderOverlay:SetShown(useNewNineSlice);

	if useNewNineSlice then
		self.BorderOverlay:SetAtlas(layoutInfo.NineSliceFormatString:format(layoutInfo.NineSliceTextureKit));
	else
		self.NineSlice.DetailTop:SetAtlas(layoutInfo.DetailTopAtlas, true);
		if layoutInfo.NineSliceLayoutName then
			local layout = NineSliceUtil.GetLayout(layoutInfo.NineSliceLayoutName);
			if layout then
				NineSliceUtil.ApplyLayout(self.NineSlice, layout);
			end
		elseif layoutInfo.NineSliceTextureKit then
			NineSliceUtil.ApplyUniqueCornersLayout(self.NineSlice, layoutInfo.NineSliceTextureKit);
		end
	end

	self.basePanOffsetX = layoutInfo.PanOffset.x;
	self.basePanOffsetY = layoutInfo.PanOffset.y;

	self.buttonPurchaseFXIDs = layoutInfo.ButtonPurchaseFXIDs;
	self:SetCardTemplateCallback(layoutInfo.CardTemplateCallback or nil);

	SetUIPanelAttribute(GenericTraitFrame, "area", layoutInfo.PanelArea);
end

function GenericTraitFrameMixin:OnShow()
	-- Changes can happen to the tree while it was hidden that may require a full update so mark it
	-- as dirty before calling the base OnShow. For example, skyriding talents can be automatically
	-- purchased on level up.
	self:MarkTreeDirty();

	TalentFrameBaseMixin.OnShow(self);

	FrameUtil.RegisterFrameForEvents(self, GenericTraitFrameEvents);

	EventRegistry:TriggerEvent("GenericTraitFrame.OnShow");

	self:UpdateTreeCurrencyInfo();
	self:ShowGenericTraitFrameTutorial();

	PlaySound(SOUNDKIT.UI_CLASS_TALENT_OPEN_WINDOW);
end

function GenericTraitFrameMixin:OnHide()
	TalentFrameBaseMixin.OnHide(self);

	FrameUtil.UnregisterFrameForEvents(self, GenericTraitFrameEvents);

	C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.TraitSystem);

	EventRegistry:TriggerEvent("GenericTraitFrame.OnHide");

	PlaySound(SOUNDKIT.UI_CLASS_TALENT_CLOSE_WINDOW);
end

function GenericTraitFrameMixin:OnEvent(event, ...)
	TalentFrameBaseMixin.OnEvent(self, event, ...);

	if event == "TRAIT_SYSTEM_NPC_CLOSED" then
		HideUIPanel(self);
	elseif event == "TRAIT_TREE_CURRENCY_INFO_UPDATED" then
		-- Hack: traitNodeInfo.canPurchaseRank is not getting updated after currency changes, so button state does not get updated.
		-- This is a temp fix to dirty all nodes to force it to get latest node info.
		local treeID = ...;
		if treeID == self:GetTalentTreeID() then
			for talentButton in self:EnumerateAllTalentButtons() do
				local nodeID = talentButton:GetNodeID();
				if nodeID then
					self:MarkNodeInfoCacheDirty(nodeID);
				end
			end
		end
	end
end

function GenericTraitFrameMixin:SetConfigIDBySystemID(systemID)
	TalentFrameBaseMixin.SetConfigIDBySystemID(self, systemID);

	EventRegistry:TriggerEvent("GenericTraitFrame.SetSystemID", systemID, self:GetConfigID());
end

function GenericTraitFrameMixin:SetTreeID(traitTreeID)
	self.traitTreeID = traitTreeID;

	local configID = C_Traits.GetConfigIDByTreeID(traitTreeID);
	self:SetConfigID(configID);

	local treeID = self.traitTreeID;
	local layout = GenericTraitUtil.GetFrameLayoutInfo(treeID);
	self:ApplyLayout(layout);

	EventRegistry:TriggerEvent("GenericTraitFrame.SetTreeID", traitTreeID, configID);
end

function GenericTraitFrameMixin:CheckAndReportCommitOperation()
	if not C_Traits.IsReadyForCommit() then
		self:ReportConfigCommitError();
		return false;
	end

	return TalentFrameBaseMixin.CheckAndReportCommitOperation(self);
end

function GenericTraitFrameMixin:AttemptConfigOperation(...)
	if TalentFrameBaseMixin.AttemptConfigOperation(self, ...) then
		if not self:CommitConfig() then
			UIErrorsFrame:AddExternalErrorMessage(GENERIC_TRAIT_FRAME_INTERNAL_ERROR);
			self:MarkTreeDirty();
			return false;
		end

		return true;
	else
		self:MarkTreeDirty();
	end

	return false;
end

function GenericTraitFrameMixin:SetSelection(nodeID, entryID)
	if self:ShouldShowConfirmation() then
		local baseButton = self:GetTalentButtonByNodeID(nodeID);
		if baseButton and baseButton:IsMaxed() then
			self:SetSelectionCallback(nodeID, entryID);
			return;
		end

		local referenceKey = self;
		if StaticPopup_IsCustomGenericConfirmationShown(referenceKey) then
			StaticPopup_Hide("GENERIC_CONFIRMATION");
		end

		local cost = self:GetNodeCost(nodeID);
		local costStrings = self:GetCostStrings(cost);
		local costString = GENERIC_TRAIT_FRAME_CONFIRM_PURCHASE_FORMAT:format(table.concat(costStrings, TALENT_BUTTON_TOOLTIP_COST_ENTRY_SEPARATOR));

		local setSelectionCallback = GenerateClosure(self.SetSelectionCallback, self, nodeID, entryID);
		local customData = {
			text = costString,
			callback = setSelectionCallback,
			referenceKey = self,
		};

		StaticPopup_ShowCustomGenericConfirmation(customData);
	else
		self:SetSelectionCallback(nodeID, entryID);
	end
end

function GenericTraitFrameMixin:SetSelectionCallback(nodeID, entryID)
	if TalentFrameBaseMixin.SetSelection(self, nodeID, entryID) then
		if entryID then
			self:ShowPurchaseVisuals(nodeID);
			self:PlaySelectSoundForNode(nodeID);
		else
			self:PlayDeselectSoundForNode(nodeID);
		end
	end
end

function GenericTraitFrameMixin:GetConfigCommitErrorString()
	-- Overrides TalentFrameBaseMixin.

	return TALENT_FRAME_CONFIG_OPERATION_TOO_FAST;
end

function GenericTraitFrameMixin:UpdateTreeCurrencyInfo()
	TalentFrameBaseMixin.UpdateTreeCurrencyInfo(self);

	local currencyInfo = self.treeCurrencyInfo and self.treeCurrencyInfo[1] or nil;
	local hasCurrencyInfo = currencyInfo ~= nil;
	self.Currency:SetShown(hasCurrencyInfo);
	if hasCurrencyInfo then
		local displayText = self.getDisplayTextFromTreeCurrency(currencyInfo);
		self.Currency:Setup(currencyInfo, displayText);
	end
end

function GenericTraitFrameMixin:GetFrameLevelForButton(nodeInfo, _visualState)
	-- Overrides TalentFrameBaseMixin.

	-- Layer the nodes so shadows line up properly, including for edges.
	local scaledYOffset = ((nodeInfo.posY - BaseYOffset) / BaseRowHeight) * FrameLevelPerRow;
	return TotalFrameLevelSpread - scaledYOffset;
end

function GenericTraitFrameMixin:IsLocked()
	-- Overrides TalentFrameBaseMixin.

	local canEditTalents, errorMessage = C_Traits.CanEditConfig(self:GetConfigID());
	return not canEditTalents, errorMessage;
end

function GenericTraitFrameMixin:PurchaseRank(nodeID)
	if self:ShouldShowConfirmation() then
		local referenceKey = self;
		if StaticPopup_IsCustomGenericConfirmationShown(referenceKey) then
			StaticPopup_Hide("GENERIC_CONFIRMATION");
		end

		local cost = self:GetNodeCost(nodeID);
		local costStrings = self:GetCostStrings(cost);
		local costString = GENERIC_TRAIT_FRAME_CONFIRM_PURCHASE_FORMAT:format(table.concat(costStrings, TALENT_BUTTON_TOOLTIP_COST_ENTRY_SEPARATOR));


		local purchaseRankCallback = GenerateClosure(self.PurchaseRankCallback, self, nodeID);
		local customData = {
			text = costString,
			callback = purchaseRankCallback,
			referenceKey = self,
		};

		StaticPopup_ShowCustomGenericConfirmation(customData);
	else
		self:PurchaseRankCallback(nodeID);
	end
end

function GenericTraitFrameMixin:PurchaseRankCallback(nodeID)
	if TalentFrameBaseMixin.PurchaseRank(self, nodeID) then
		self:ShowPurchaseVisuals(nodeID);
	end
end

function GenericTraitFrameMixin:ShowGenericTraitFrameTutorial()
	local treeID = self:GetTalentTreeID();
	if not treeID then
		return;
	end

	local nodeIDs = C_Traits.GetTreeNodes(treeID);

	local firstButton = self:GetTalentButtonByNodeID(nodeIDs[1]);
	local tutorialInfo = GenericTraitUtil.GetFrameTutorialInfo(treeID);
	if tutorialInfo and not GetCVarBitfield("closedInfoFrames", tutorialInfo.tutorial.bitfieldFlag) then
		HelpTip:Show(self, tutorialInfo.tutorial, firstButton);
	end
end

function GenericTraitFrameMixin:ShowPurchaseVisuals(nodeID)
	if not self.buttonPurchaseFXIDs then
		return;
	end

	local buttonWithPurchase = self:GetTalentButtonByNodeID(nodeID);
	if buttonWithPurchase and buttonWithPurchase.PlayPurchaseCompleteEffect then
		buttonWithPurchase:PlayPurchaseCompleteEffect(self.FxModelScene, self.buttonPurchaseFXIDs);
	end
end

function GenericTraitFrameMixin:PlaySelectSoundForNode(nodeID)
	self:InvokeTalentButtonMethodByNodeID("PlaySelectSound", nodeID);
end

function GenericTraitFrameMixin:PlayDeselectSoundForNode(nodeID)
	self:InvokeTalentButtonMethodByNodeID("PlayDeselectSound", nodeID);
end

function GenericTraitFrameMixin:ShouldShowConfirmation()
	local traitSystemFlags = C_Traits.GetTraitSystemFlags(self:GetConfigID());
	return traitSystemFlags and FlagsUtil.IsSet(traitSystemFlags, Enum.TraitSystemFlag.ShowSpendConfirmation);
end


GenericTraitFrameCurrencyFrameMixin = {};

function GenericTraitFrameCurrencyFrameMixin:UpdateWidgetSet()
	local configID = self:GetParent():GetConfigID();
	self.uiWidgetSetID = configID and C_Traits.GetTraitSystemWidgetSetID(configID) or nil;
end

function GenericTraitFrameCurrencyFrameMixin:Setup(currencyInfo, displayText)
	displayText = displayText or "";
	local currencyCostText = GENERIC_TRAIT_FRAME_CURRENCY_TEXT:format(currencyInfo and currencyInfo.quantity or 0, displayText);
	local currencyText = WHITE_FONT_COLOR:WrapTextInColorCode(currencyCostText);

	self.UnspentPointsCount:SetText(currencyText);
	self:UpdateWidgetSet();

	if currencyInfo and currencyInfo.traitCurrencyID then
		local tutorialInfo = GenericTraitUtil.GetCurrencyTutorialInfo(currencyInfo.traitCurrencyID);
		if tutorialInfo and not GetCVarBitfield("closedInfoFrames", tutorialInfo.tutorial.bitfieldFlag) then
			HelpTip:Show(self, tutorialInfo.tutorial);
		end
	end
end

function GenericTraitFrameCurrencyFrameMixin:OnEnter()
	if not self.uiWidgetSetID then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddWidgetSet(GameTooltip, self.uiWidgetSetID);
	GameTooltip:Show();
end
