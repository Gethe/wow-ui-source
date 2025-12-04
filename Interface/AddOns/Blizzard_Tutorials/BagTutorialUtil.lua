-- This mixin is meant to serve as a generic Helptip base for item tutorials in bags. See implementations in Blizzard_HousingTutorialsMisc, and Blizzard_TutorialReagentBag

BagTutorialHelpTipKeys = {
	OpenBagsInfo = "OpenBagsInfo",
	ItemInfo = "ItemInfo"
};

BagTutorialQueue = {};

BagTutorialQueue.queue = {};

function BagTutorialQueue.AddToQueue(bagTutorial)
	table.insert(BagTutorialQueue.queue, bagTutorial);
end

function BagTutorialQueue.StartNext()
	table.remove(BagTutorialQueue.queue, 1);
	if BagTutorialQueue.queue[1] then
		BagTutorialQueue.queue[1]:BeginInitialState();
	end
end

function BagTutorialQueue.IsInQueue(bagTutorial)
	return tContains(BagTutorialQueue.queue, bagTutorial);
end

function BagTutorialQueue.GetQueueFront()
	return BagTutorialQueue.queue[1];
end

BagTutorialBaseMixin = CreateFromMixins(StateMachineBasedTutorialMixin);

function BagTutorialBaseMixin:Init(helpTipInfos, helpTipSystem, bitfield, bitflag)
	self.helpTipInfos = helpTipInfos;
	self.helpTipSystem = helpTipSystem;

	self:AddState("ListenForBagUpdate", "StartPhase_ListenForBagUpdate", "StopPhase_ListenForBagUpdate");
	self:AddState("TellPlayerToOpenBags", "StartPhase_TellPlayerToOpenBags", "StopPhase_TellPlayerToOpenBags");
	self:AddState("HelpPlayerOpenAllBags", "StartPhase_HelpPlayerOpenAllBags", "StopPhase_HelpPlayerOpenAllBags");
	self:AddState("PointAtItem", "StartPhase_PointAtItem", "StopPhase_PointAtItem");

	self:SetInitialStateName("ListenForBagUpdate");
	self:SetTutorialFlagType(bitfield, bitflag);
end

function BagTutorialBaseMixin:StartPhase_ListenForBagUpdate()
	EventRegistry:RegisterFrameEventAndCallback("BAG_UPDATE_DELAYED", self.OnBagUpdate, self);
end

function BagTutorialBaseMixin:StopPhase_ListenForBagUpdate()
	EventRegistry:UnregisterFrameEventAndCallback("BAG_UPDATE_DELAYED", self);
end

function BagTutorialBaseMixin:StartPhase_TellPlayerToOpenBags()
	HelpTip:Show(UIParent, self.helpTipInfos[BagTutorialHelpTipKeys.OpenBagsInfo], MainMenuBarBackpackButton);

	EventRegistry:RegisterCallback("ContainerFrame.OpenBag", self.CheckOpenInventory, self);
end

function BagTutorialBaseMixin:StopPhase_TellPlayerToOpenBags()
	EventRegistry:UnregisterCallback("ContainerFrame.OpenBag", self);
	HelpTip:HideAllSystem(self:GetSystem());
end

function BagTutorialBaseMixin:StartPhase_HelpPlayerOpenAllBags()
	EventRegistry:RegisterCallback("ContainerFrame.OpenAllBags", function(owner)
		self:BeginState("PointAtBagItem");
	end, self);

	ToggleAllBags();
end

function BagTutorialBaseMixin:StopPhase_HelpPlayerOpenAllBags()
	EventRegistry:UnregisterCallback("ContainerFrame.OpenAllBags", self);
end

function BagTutorialBaseMixin:StartPhase_PointAtItem()
	local itemButton = ContainerFrameUtil_GetItemButtonAndContainer(self.pointAtBagData.bagID, self.pointAtBagData.slotID);
	HelpTip:Show(UIParent, self.helpTipInfos[BagTutorialHelpTipKeys.ItemInfo], itemButton);

	EventRegistry:RegisterCallback("ContainerFrame.CloseAllBags", function(owner, container)
		if self.pointAtBagData then
			self:RestartTutorial();
			self:OnBagUpdate();
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

function BagTutorialBaseMixin:StopPhase_PointAtItem()
	HelpTip:HideAllSystem(self:GetSystem());
	EventRegistry:UnregisterCallback("ContainerFrame.CloseAllBags", self);
	EventRegistry:UnregisterFrameEventAndCallback("ITEM_LOCKED", self);

	-- NOTE: Defer unregister from BAG_CONTAINER_UPDATE until the player finishes the tutorial
end

function BagTutorialBaseMixin:OnBagUpdate()
	if self:HasItemInInventory() then
		self:CheckOpenInventory();
	end
end

function BagTutorialBaseMixin:CheckOpenInventory()
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

		self:BeginState("PointAtItem");
	end
end

function BagTutorialBaseMixin:HasItemInInventory()
	self.pointAtBagData = nil;

	ItemUtil.IteratePlayerInventory(function(itemLocation)
		local bag, slot = itemLocation:GetBagAndSlot();
		if bag and slot then
			local info = C_Container.GetContainerItemInfo(bag, slot);
			if info and self:IsValidItem(info.hyperlink) then
				self.pointAtBagData = { bagID = bag, slotID = slot };
				return true;
			end
		end
	end);

	return self.pointAtBagData ~= nil;
end

function BagTutorialBaseMixin:IsValidItem(itemHyperlink)
	-- Override in derived mixins.
	return false;
end

function BagTutorialBaseMixin:MarkTutorialComplete()
	StateMachineBasedTutorialMixin.MarkTutorialComplete(self);
	EventRegistry:UnregisterFrameEventAndCallback("BAG_CONTAINER_UPDATE", self);

	if BagTutorialQueue.IsInQueue(self) then
		BagTutorialQueue.StartNext();
	end
end

function BagTutorialBaseMixin:GetSystem()
	return self.helpTipSystem;
end

function BagTutorialBaseMixin:BeginInitialState()
	if not BagTutorialQueue.IsInQueue(self) then
		BagTutorialQueue.AddToQueue(self);
	end

	if self == BagTutorialQueue.GetQueueFront() then
		self:BeginState(self:GetInitialStateName());
	end
end
