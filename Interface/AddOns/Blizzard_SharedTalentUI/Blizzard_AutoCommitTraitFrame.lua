AutoCommitTraitFrameMixin = { };

local FrameLevelPerRow = 10;
local BaseYOffset = 1500;
local BaseRowHeight = 600;
local TotalFrameLevelSpread = 500;

function AutoCommitTraitFrameMixin:GetFrameLevelForButton(nodeInfo, _visualState)
	-- Overrides TalentFrameBaseMixin.

	-- Layer the nodes so shadows line up properly, including for edges.
	local scaledYOffset = ((nodeInfo.posY - BaseYOffset) / BaseRowHeight) * FrameLevelPerRow;
	return TotalFrameLevelSpread - scaledYOffset;
end

function AutoCommitTraitFrameMixin:IsLocked()
	-- Overrides TalentFrameBaseMixin.

	local canEditTalents, errorMessage = C_Traits.CanEditConfig(self:GetConfigID());
	return not canEditTalents, errorMessage;
end

function AutoCommitTraitFrameMixin:CheckAndReportCommitOperation()
	if not C_Traits.IsReadyForCommit() then
		self:ReportConfigCommitError();
		return false;
	end

	return TalentFrameBaseMixin.CheckAndReportCommitOperation(self);
end

function AutoCommitTraitFrameMixin:AttemptConfigOperation(...)
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

function AutoCommitTraitFrameMixin:SetSelection(nodeID, entryID)
	if self:ShouldShowConfirmation(nodeID) then
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
		local formatString = self:GetPurchaseConfirmationFormatString();
		local costString = formatString:format(table.concat(costStrings, TALENT_BUTTON_TOOLTIP_COST_ENTRY_SEPARATOR));

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

function AutoCommitTraitFrameMixin:SetSelectionCallback(nodeID, entryID)
	if TalentFrameBaseMixin.SetSelection(self, nodeID, entryID) then
		if entryID then
			self:ShowPurchaseVisuals(nodeID, entryID);
			self:PlaySelectSoundForNode(nodeID);
		else
			self:PlayDeselectSoundForNode(nodeID);
		end
	end
end

function AutoCommitTraitFrameMixin:PurchaseRank(nodeID)
	if self:ShouldShowConfirmation(nodeID) then
		local referenceKey = self;
		if StaticPopup_IsCustomGenericConfirmationShown(referenceKey) then
			StaticPopup_Hide("GENERIC_CONFIRMATION");
		end

		local cost = self:GetNodeCost(nodeID);
		local costStrings = self:GetCostStrings(cost);

		local confirmationString;
		if #costStrings > 0 then
			local formatString = self.purchaseConfirmationFormatString;
			confirmationString = formatString:format(table.concat(costStrings, TALENT_BUTTON_TOOLTIP_COST_ENTRY_SEPARATOR));
		else
			confirmationString = self.purchaseConfirmationString;
		end

		local fromConfirmation = true;
		local purchaseRankCallback = GenerateClosure(self.PurchaseRankCallback, self, nodeID, fromConfirmation);
		local customData = {
			text = confirmationString,
			callback = purchaseRankCallback,
			referenceKey = self,
		};

		StaticPopup_ShowCustomGenericConfirmation(customData);
	else
		local fromConfirmation = false;
		self:PurchaseRankCallback(nodeID, fromConfirmation);
	end
end

function AutoCommitTraitFrameMixin:PurchaseRankCallback(nodeID, fromConfirmation)
	if TalentFrameBaseMixin.PurchaseRank(self, nodeID) then
		-- If we're playing not coming from a confirmation, we should've already played the sound
		if fromConfirmation then
			self:PlaySelectSoundForNode(nodeID);
		end

		self:ShowPurchaseVisuals(nodeID);
	end
end

local PURCHASE_FX_IDS = { 150, 142, 143 };

function AutoCommitTraitFrameMixin:GetButtonPurchaseFXIDs()
	return PURCHASE_FX_IDS;
end

function AutoCommitTraitFrameMixin:ShowPurchaseVisuals(nodeID, entryID)
	local buttonPurchaseFXIDs = self:GetButtonPurchaseFXIDs();
	if not buttonPurchaseFXIDs then
		return;
	end

	local buttonWithPurchase = self:GetTalentButtonByNodeID(nodeID);
	if buttonWithPurchase and entryID then
		local nodeInfo = buttonWithPurchase:GetNodeInfo();

		-- For expanded choice nodes, we want to find the specific selection node that was chosen to play the effect on instead of the parent node.
		local isSelection = nodeInfo.type == Enum.TraitNodeType.Selection or nodeInfo.type == Enum.TraitNodeType.SubTreeSelection;
		local isExpanded = FlagsUtil.IsSet(nodeInfo.flags, Enum.TraitNodeFlag.ShowExpandedSelection);
		if isSelection and isExpanded then
			local selectionFrames = buttonWithPurchase.SelectionFrame.selectionFrameArray;
			for _i, selectionNode in ipairs(selectionFrames) do
				if selectionNode:GetEntryID() == entryID then
					buttonWithPurchase = selectionNode;
					break;
				end
			end
		end
	end

	if buttonWithPurchase and buttonWithPurchase.PlayPurchaseCompleteEffect then
		buttonWithPurchase:PlayPurchaseCompleteEffect(self.FxModelScene, buttonPurchaseFXIDs);
	end
end

function AutoCommitTraitFrameMixin:PlaySelectSoundForNode(nodeID)
	self:InvokeTalentButtonMethodByNodeID("PlaySelectSound", nodeID);
end

function AutoCommitTraitFrameMixin:PlayDeselectSoundForNode(nodeID)
	self:InvokeTalentButtonMethodByNodeID("PlayDeselectSound", nodeID);
end

function AutoCommitTraitFrameMixin:ShouldShowConfirmation(nodeID)
	local traitSystemFlags = C_Traits.GetTraitSystemFlags(self:GetConfigID());
	local showSpendConfirmation = traitSystemFlags and FlagsUtil.IsSet(traitSystemFlags, Enum.TraitSystemFlag.ShowSpendConfirmation);

	-- If nodeID is provided, check if this is a subtree selection and if suppression is enabled
	if nodeID and self.suppressSubTreeConfirmation then
		local nodeInfo = C_Traits.GetNodeInfo(self:GetConfigID(), nodeID);
		if nodeInfo and nodeInfo.type == Enum.TraitNodeType.SubTreeSelection then
			return false;
		end
	end

	return showSpendConfirmation;
end

AutoCommitTraitUtil = { };

local TemplatesByEdgeVisualStyle = {
	[Enum.TraitEdgeVisualStyle.Straight] = "TalentEdgeArrowTemplate",
};

function AutoCommitTraitUtil.GetEdgeTemplateType(edgeVisualStyle)
	return TemplatesByEdgeVisualStyle[edgeVisualStyle];
end
