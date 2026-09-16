local ReagentBagTutorialMixin = CreateFromMixins(BagTutorialBaseMixin);

function ReagentBagTutorialMixin:Init()
	local reagentBagTutorialSystem = "TutorialReagentBag";

	local helpTipInfos = {
		[BagTutorialHelpTipKeys.OpenBagsInfo] = {
			text = TUTORIAL_REAGENT_BAG_STEP_1,
			buttonStyle = HelpTip.ButtonStyle.None,
			targetPoint = HelpTip.Point.TopEdgeRight,
			alignment = HelpTip.Alignment.Right,
			hideArrow = true,
			offsetX = -45,
			system = reagentBagTutorialSystem,
		},
	
		[BagTutorialHelpTipKeys.ItemInfo] = {
			text = TUTORIAL_REAGENT_BAG_STEP_2,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.LeftEdgeCenter,
			alignment = HelpTip.Alignment.Center,
			system = reagentBagTutorialSystem,
			callbackArg = self,
			onAcknowledgeCallback = self.AcknowledgeTutorial,
		},
	}

	BagTutorialBaseMixin.Init(
		self,
		helpTipInfos,
		reagentBagTutorialSystem,
		"closedInfoFrames",
		LE_FRAME_TUTORIAL_EQUIP_REAGENT_BAG
	);
end

function ReagentBagTutorialMixin:IsValidItem(itemHyperlink)
	local _name, _enchantLink, _displayQuality, _itemLevel, _requiredLevel, _className, _subclassName, _isStackable, _inventoryType, _iconFile, _sellPrice, itemClassID, itemSubclassID, _boundState, _expansionID, _itemSetID, _isTradeskill = C_Item.GetItemInfo(itemHyperlink);

	return itemClassID == 1 and itemSubclassID == 11;
end

function ReagentBagTutorialMixin:HasReagentBagEquipped()
	return ContainerFrame_GetContainerNumSlots(Enum.BagIndex.ReagentBag) > 0;
end

function ReagentBagTutorialMixin:IsComplete()
	return self:HasReagentBagEquipped();
end


TutorialManager:CheckHasCompletedFrameTutorial(LE_FRAME_TUTORIAL_EQUIP_REAGENT_BAG, function(hasCompletedTutorial)
	if not hasCompletedTutorial then
		CreateAndInitFromMixin(ReagentBagTutorialMixin):BeginInitialState();
	end
end);
