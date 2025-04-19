local ReagentBagTutorialMixin = CreateFromMixins(StateMachineBasedTutorialMixin);

function ReagentBagTutorialMixin:Init()
	self:AddState("ListenForBagUpdate", "StartPhase_ListenForBagUpdate", "StopPhase_ListenForBagUpdate");
	self:AddState("TellPlayerToOpenBags", "StartPhase_TellPlayerToOpenBags", "StopPhase_TellPlayerToOpenBags");
	self:AddState("HelpPlayerOpenAllBags", "StartPhase_HelpPlayerOpenAllBags", "StopPhase_HelpPlayerOpenAllBags");
	self:AddState("PointAtReagentBagItem", "StartPhase_PointAtReagentBagItem", "StopPhase_PointAtReagentBagItem");

	self:SetInitialStateName("ListenForBagUpdate");
	self:SetTutorialFlagType("closedInfoFrames", LE_FRAME_TUTORIAL_EQUIP_REAGENT_BAG);
end

function ReagentBagTutorialMixin:StartPhase_ListenForBagUpdate()
	EventRegistry:RegisterFrameEventAndCallback("BAG_UPDATE_DELAYED", self.OnBagUpdate, self);
end

function ReagentBagTutorialMixin:StopPhase_ListenForBagUpdate()
	EventRegistry:UnregisterFrameEventAndCallback("BAG_UPDATE_DELAYED", self);
end

function ReagentBagTutorialMixin:StartPhase_TellPlayerToOpenBags()
	local helpTipInfo = {
		text = TUTORIAL_REAGENT_BAG_STEP_1,
		buttonStyle = HelpTip.ButtonStyle.None,
		targetPoint = HelpTip.Point.TopEdgeRight,
		alignment = HelpTip.Alignment.Right,
		hideArrow = true,
		offsetX = -45,
		system = self:GetSystem(),
	};
	HelpTip:Show(UIParent, helpTipInfo, MainMenuBarBackpackButton);

	EventRegistry:RegisterCallback("ContainerFrame.OpenBag", self.CheckOpenInventory, self);
end

function ReagentBagTutorialMixin:StopPhase_TellPlayerToOpenBags()
	EventRegistry:UnregisterCallback("ContainerFrame.OpenBag", self);
	HelpTip:HideAllSystem(self:GetSystem());
end

function ReagentBagTutorialMixin:StartPhase_HelpPlayerOpenAllBags()
	EventRegistry:RegisterCallback("ContainerFrame.OpenAllBags", function(owner)
		self:BeginState("PointAtReagentBagItem");
	end, self);

	ToggleAllBags();
end

function ReagentBagTutorialMixin:StopPhase_HelpPlayerOpenAllBags()
	EventRegistry:UnregisterCallback("ContainerFrame.OpenAllBags", self);
end

function ReagentBagTutorialMixin:StartPhase_PointAtReagentBagItem()
	local helpTipInfo = {
		text = TUTORIAL_REAGENT_BAG_STEP_2,
		buttonStyle = HelpTip.ButtonStyle.Close,
		targetPoint = HelpTip.Point.LeftEdgeCenter,
		alignment = HelpTip.Alignment.Center,
		system = self:GetSystem(),
		callbackArg = self,
		onAcknowledgeCallback = self.AcknowledgeTutorial,
	};

	local itemButton = ContainerFrameUtil_GetItemButtonAndContainer(self.pointAtBagData.bagID, self.pointAtBagData.slotID);
	HelpTip:Show(UIParent, helpTipInfo, itemButton);

	EventRegistry:RegisterCallback("ContainerFrame.CloseAllBags", function(owner, container)
		if self.pointAtBagData then
			self:RestartTutorial();
		end
	end, self);

	EventRegistry:RegisterFrameEventAndCallback("ITEM_LOCKED", function(owner, bagOrSlotIndex, slotIndex)
		if self.pointAtBagData then
			if self.pointAtBagData.bagID == bagOrSlotIndex and self.pointAtBagData.slotID == slotIndex then
				self:RestartTutorial();
			end
		end
	end, self);

	EventRegistry:RegisterFrameEventAndCallback("BAG_CONTAINER_UPDATE", function(owner)
		self:CheckComplete();
	end, self);
end

function ReagentBagTutorialMixin:StopPhase_PointAtReagentBagItem()
	HelpTip:HideAllSystem(self:GetSystem());
	EventRegistry:UnregisterCallback("ContainerFrame.CloseAllBags", self);
	EventRegistry:UnregisterFrameEventAndCallback("ITEM_LOCKED", self);

	-- NOTE: Defer unregister from BAG_CONTAINER_UPDATE until the player finishes the tutorial
end

function ReagentBagTutorialMixin:OnBagUpdate()
	if self:HasReagentBagInInventory() then
		self:CheckOpenInventory();
	end
end

function ReagentBagTutorialMixin:CheckOpenInventory()
	if self:GetActiveStateName() == "HelpPlayerOpenAllBags" then
		return;
	end

	if not IsAnyStandardHeldBagOpen() then
		if self:GetActiveStateName() ~= "TellPlayerToOpenBags" then
			self:BeginState("TellPlayerToOpenBags");
		end
	else
		if not AreAllStandardHeldBagsOpen() then
			self:BeginState("HelpPlayerOpenAllBags");
		end

		self:BeginState("PointAtReagentBagItem");
	end
end

function ReagentBagTutorialMixin:HasReagentBagInInventory()
	self.pointAtBagData = nil;

	ItemUtil.IteratePlayerInventory(function(itemLocation)
		local bag, slot = itemLocation:GetBagAndSlot();
		if bag and slot then
			local info = C_Container.GetContainerItemInfo(bag, slot);
			if info then
				local name, enchantLink, displayQuality, itemLevel, requiredLevel, className, subclassName, isStackable, inventoryType, iconFile, sellPrice, itemClassID, itemSubclassID, boundState, expansionID, itemSetID, isTradeskill = C_Item.GetItemInfo(info.hyperlink);

				if itemClassID == 1 and itemSubclassID == 11 then
					self.pointAtBagData = { bagID = bag, slotID = slot };
					return true;
				end
			end
		end
	end);

	return self.pointAtBagData ~= nil;
end

function ReagentBagTutorialMixin:HasReagentBagEquipped()
	return ContainerFrame_GetContainerNumSlots(Enum.BagIndex.ReagentBag) > 0;
end

function ReagentBagTutorialMixin:IsComplete()
	return self:HasReagentBagEquipped();
end

function ReagentBagTutorialMixin:MarkTutorialComplete()
	StateMachineBasedTutorialMixin.MarkTutorialComplete(self);
	EventRegistry:UnregisterFrameEventAndCallback("BAG_CONTAINER_UPDATE", self);
end

function ReagentBagTutorialMixin:GetSystem()
	return "TutorialReagentBag";
end

TutorialManager:CheckHasCompletedFrameTutorial(LE_FRAME_TUTORIAL_EQUIP_REAGENT_BAG, function(hasCompletedTutorial)
	if not hasCompletedTutorial then
		CreateAndInitFromMixin(ReagentBagTutorialMixin):BeginInitialState();
	end
end);