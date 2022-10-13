local function ToolTutorialShown()
	return GetCVarBool("professionToolSlotsExampleShown");
end

local function AccessoryTutorialShown()
	return GetCVarBool("professionAccessorySlotsExampleShown");
end

function CanShowProfessionEquipmentTutorial()
	return (not ToolTutorialShown()) or (not AccessoryTutorialShown());
end

-- ------------------------------------------------------------------------------------------------------------
-- Inventory Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_ProfessionInventoryWatcher = class("ProfessionInventoryWatcher", Class_TutorialBase);

function Class_ProfessionInventoryWatcher:OnInitialize()
	if not CanShowProfessionEquipmentTutorial() then
		self:Complete();
	end
end

function Class_ProfessionInventoryWatcher:OnBegin()
end

function Class_ProfessionInventoryWatcher:StartWatching()
	Dispatcher:RegisterEvent("BAG_UPDATE_DELAYED", self);
	Dispatcher:RegisterEvent("SKILL_LINES_CHANGED", self);
end

function Class_ProfessionInventoryWatcher:StopWatching()
	Dispatcher:UnregisterEvent("BAG_UPDATE_DELAYED", self);
	Dispatcher:UnregisterEvent("SKILL_LINES_CHANGED", self);
end

function Class_ProfessionInventoryWatcher:BAG_UPDATE_DELAYED()
	if not CanShowProfessionEquipmentTutorial() then
		TutorialManager:StopWatcher(self:Name(), true);
	else
		TutorialManager:Queue(Class_ProfessionGearCheckingService.name);
	end
end

function Class_ProfessionInventoryWatcher:SKILL_LINES_CHANGED()
	if not CanShowProfessionEquipmentTutorial() then
		TutorialManager:StopWatcher(self:Name(), true);
	else
		TutorialManager:Queue(Class_ProfessionGearCheckingService.name);
	end
end

function Class_ProfessionInventoryWatcher:OnInterrupt()
	self:Complete();
end

function Class_ProfessionInventoryWatcher:OnComplete()
	self:StopWatching();
end

-- ------------------------------------------------------------------------------------------------------------
-- Profession Gear Checking Service
-- ------------------------------------------------------------------------------------------------------------
Class_ProfessionGearCheckingService = class("ProfessionGearCheckingService", Class_TutorialBase);

function Class_ProfessionGearCheckingService:OnInitialize()
end

function Class_ProfessionGearCheckingService:CanBegin()
	return true;
end

function Class_ProfessionGearCheckingService:OnBegin()
	local profGear = self:GetProfessionGear();
	local slot, item = next(profGear);

	if item then
		TutorialManager:Queue(Class_EquipProfessionGear.name, item);
	end
	TutorialManager:Finished(self:Name());
end

function Class_ProfessionGearCheckingService:STRUCT_ItemContainer(itemLink, characterSlot, container, containerSlot, isTool)
	return
	{
		ItemLink = itemLink,
		Container = container,
		ContainerSlot = containerSlot,
		CharacterSlot = characterSlot,
		IsTool = isTool,
	};
end

function Class_ProfessionGearCheckingService:GetProfessionGear()
	local professionGear = {};

	local profInvSlots = C_TradeSkillUI.GetProfessionInventorySlots();

	for _, i in ipairs(profInvSlots) do
		local potentialGear = {};
		GetInventoryItemsForSlot(i, potentialGear);

		for packedLocation, itemLink in pairs(potentialGear) do
			local player, bank, bags, voidStorage, slot, bag = EquipmentManager_UnpackLocation(packedLocation);
			local invType = select(9, GetItemInfo(itemLink));
			local isTool = (invType == "INVTYPE_PROFESSION_TOOL");
			local hasBeenShown = isTool and ToolTutorialShown() or AccessoryTutorialShown();
			if player and bags and (not hasBeenShown) then
				table.insert(professionGear, self:STRUCT_ItemContainer(itemLink, i, bag, slot, isTool));
			end
		end
	end

	return professionGear;
end

function Class_ProfessionGearCheckingService:OnInterrupt(interruptedBy)
	TutorialManager:Finished(self:Name());
end

function Class_ProfessionGearCheckingService:OnComplete()
end

-- ------------------------------------------------------------------------------------------------------------
-- Change Equipment
-- ------------------------------------------------------------------------------------------------------------
Class_EquipProfessionGear = class("EquipProfessionGear", Class_TutorialBase);

function Class_EquipProfessionGear:OnInitialize()
end

function Class_EquipProfessionGear:CanBegin(args)
	return true;
end

function Class_EquipProfessionGear:OnBegin(args)
	self.data = unpack(args);
	self.skillLine = C_TradeSkillUI.GetSkillLineForGear(self.data.ItemLink);

	Dispatcher:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", self);
	Dispatcher:RegisterEvent("PLAYER_DEAD", self);
	Dispatcher:RegisterEvent("ZONE_CHANGED_NEW_AREA", self);
	Dispatcher:RegisterEvent("BAG_UPDATE_DELAYED", self);
	Dispatcher:RegisterEvent("SKILL_LINES_CHANGED", self);

	EventRegistry:RegisterCallback("ContainerFrame.OpenBag", function() self:BagOpened(); end);
	EventRegistry:RegisterCallback("ContainerFrame.CloseBag", function() self:UpdateState(); end);
	EventRegistry:RegisterCallback("ProfessionsFrame.Show", function() self:UpdateState(); end);
	EventRegistry:RegisterCallback("ProfessionsFrame.Hide", function() self:UpdateState(); end);
	EventRegistry:RegisterCallback("ProfessionsFrame.TabSet", function() self:UpdateState(); end);
	EventRegistry:RegisterCallback("Professions.ProfessionSelected", function() self:UpdateState(); end);
	
	if not C_Container.GetContainerItemID(self.data.Container, self.data.ContainerSlot) then
		TutorialManager:Finished(self:Name());
		return;
	end

	self:Reset();
end

function Class_EquipProfessionGear:PLAYER_DEAD()
	TutorialManager:Finished(self:Name());

	-- the player died in the middle of the tutorial, requeue it so that when the player is alive, they can try again
	self.Timer = C_Timer.NewTimer(0.1, function()
		TutorialManager:Queue(Class_ProfessionGearCheckingService.name);
	end);
end

function Class_EquipProfessionGear:SKILL_LINES_CHANGED()
	if not C_TradeSkillUI.GetSkillLineForGear(self.data.ItemLink) then
		-- Player unlearned the skill line
		TutorialManager:Finished(self:Name());
	end

	-- They could have profession gear for a different profession; check again
	self.Timer = C_Timer.NewTimer(0.1, function()
		TutorialManager:Queue(Class_ProfessionGearCheckingService.name);
	end);
end

function Class_EquipProfessionGear:ZONE_CHANGED_NEW_AREA()
	TutorialManager:Finished(self:Name());

	-- the player changed zones in the middle of the tutorial, requeue it so that when the player can try again
	self.Timer = C_Timer.NewTimer(0.1, function()
		TutorialManager:Queue(Class_ProfessionGearCheckingService.name);
	end);
end

function Class_EquipProfessionGear:Reset()
	self.success = false;
	TutorialDragButton:Hide();
	self:HidePointerTutorials();
	self:PrepBags();
end

function Class_EquipProfessionGear:PrepBags()
	-- Dirty hack to make sure all bags are closed
	TutorialHelper:CloseAllBags();
	self.allBagsOpened = false;
	TutorialDragButton:Hide();

	if self.data then
		self.Timer = C_Timer.NewTimer(0.1, function()
			self:ShowPointerTutorial(self.data.isTool and PROFESSION_EQUIPMENT_NEWITEM_TOOL_HELPTIP or PROFESSION_EQUIPMENT_NEWITEM_ACCESSORY_HELPTIP, "DOWN", MainMenuBarBackpackButton, 0, 0);
		end);
	end
end

-- for this tutorial, all the bags need to be opened
function Class_EquipProfessionGear:OpenAllBags()
	self.allBagsOpened = true;
	TutorialHelper:OpenAllBags();
	self:UpdateState();
end

function Class_EquipProfessionGear:BagOpened()
	if not self.allBagsOpened then
		self.allBagsOpened = true;

		self.Timer = C_Timer.NewTimer(0.1, function()
			self:OpenAllBags();
		end);
	end
	self:UpdateState()
end

function Class_EquipProfessionGear:IsProfessionsFrameVisible()
	return ProfessionsFrame:IsVisible();
end

function Class_EquipProfessionGear:IsCorrectProfessionSelected()
	local currBaseProfessionInfo = C_TradeSkillUI.GetBaseProfessionInfo();
	return currBaseProfessionInfo ~= nil and currBaseProfessionInfo.professionID == self.skillLine;
end

function Class_EquipProfessionGear:IsCorrectProfessionTabSelected()
	return ProfessionsFrame:GetTab() == ProfessionsFrame.recipesTabID;
end

function Class_EquipProfessionGear:UpdateState()
	if not self.data then
		return;
	end

	if not IsAnyBagOpen() then
		self:Reset();
		return;
	end

	self.originFrame = TutorialHelper:GetItemContainerFrame(self.data.Container, self.data.ContainerSlot);

	if self.success then
		TutorialManager:Finished(self:Name());
	elseif self:IsProfessionsFrameVisible() and self:IsCorrectProfessionSelected() and self:IsCorrectProfessionTabSelected() then
		self:HidePointerTutorials();
		self.AnimTimer = C_Timer.NewTimer(0.1, function()
			self:StartAnimation();
		end);
	elseif self:IsProfessionsFrameVisible() and self:IsCorrectProfessionSelected() and not self:IsCorrectProfessionTabSelected() then
		self:HidePointerTutorials();
		TutorialDragButton:Hide();
		self:ShowPointerTutorial(PROFESSION_EQUIPMENT_NEWITEM_TAB_HELPTIP, "UP", ProfessionsFrame:GetTabButton(ProfessionsFrame.recipesTabID), 0, 0);
	elseif self.originFrame then
		self:HidePointerTutorials();
		TutorialDragButton:Hide();
		self:ShowPointerTutorial(PROFESSION_EQUIPMENT_NEWITEM_EQUIP_HELPTIP, "RIGHT", self.originFrame, 0, 0);
	end
end

function Class_EquipProfessionGear:PLAYER_EQUIPMENT_CHANGED()
	local item = Item:CreateFromItemLink(self.data.ItemLink);
	local itemID = item:GetItemID();

	if GetInventoryItemID("player", self.data.CharacterSlot) == itemID then
		-- the player successfully equipped the item
		Dispatcher:UnregisterEvent("BAG_UPDATE_DELAYED", self);
		self.success = true;
		TutorialDragButton:Hide();
		self.animationPlaying = false;
		TutorialManager:Finished(self:Name());
	end
end

function Class_EquipProfessionGear:StartAnimation()
	if not self.data then
		TutorialManager:Finished(self:Name());
		return;
	end

	local Slot =
	{
		[20] = ProfessionsFrame.CraftingPage.Prof0ToolSlot,
		[21] = ProfessionsFrame.CraftingPage.Prof0Gear0Slot,
		[22] = ProfessionsFrame.CraftingPage.Prof0Gear0Slot,
		[23] = ProfessionsFrame.CraftingPage.Prof1ToolSlot,
		[24] = ProfessionsFrame.CraftingPage.Prof1Gear0Slot,
		[25] = ProfessionsFrame.CraftingPage.Prof1Gear0Slot,
		[26] = ProfessionsFrame.CraftingPage.CookingToolSlot,
		[27] = ProfessionsFrame.CraftingPage.CookingGear0Slot,
		[28] = ProfessionsFrame.CraftingPage.FishingToolSlot,
	}

	self.destFrame = Slot[self.data.CharacterSlot];

	if self.originFrame and self.destFrame then
		self:HidePointerTutorials();
		self.newItemPointerID = self:AddPointerTutorial(NPEV2_DRAG_TO_EQUIP, "DOWN", self.originFrame, 0, 0);

		TutorialDragButton:Show(self.originFrame, self.destFrame);
		self.animationPlaying = true;
	end
end

function Class_EquipProfessionGear:UpdateItemContainerAndSlotInfo()
	local item = Item:CreateFromItemLink(self.data.ItemLink);
	local currentItemID = item:GetItemID();
	local itemInfo = C_Container.GetContainerItemInfo(self.data.Container, self.data.ContainerSlot);

	if itemInfo and itemInfo.itemID == currentItemID then
		-- nothing in the inventory changed that effected the current tutorial
	else
		local maxNumContainters = 4;
		local itemFound = false;
		for containerIndex = 0, maxNumContainters do
			if itemFound then
				break;
			end

			local slots = C_Container.GetContainerNumSlots(containerIndex);
			if slots > 0 then
				for slotIndex = 1, slots do
					local slotItemInfo = C_Container.GetContainerItemInfo(containerIndex, slotIndex);
					if slotItemInfo and slotItemInfo.itemID == currentItemID then
						self.data.Container = containerIndex;
						self.data.ContainerSlot = slotIndex;
						itemFound = true;
						break;
					end
				end
			end
		end
		if not itemFound then
			-- somehow the item is gone from our containers, maybe it was sold or already equipped
			self.data = nil;
		end
	end
end

function Class_EquipProfessionGear:UpdateDragOrigin()
	local item = Item:CreateFromItemLink(self.data.ItemLink);
	local currentItemID = item:GetItemID();
	local itemInfo = C_Container.GetContainerItemInfo(self.data.Container, self.data.ContainerSlot);

	if itemInfo and itemInfo.itemID == currentItemID then
		-- nothing in the inventory changed that affected the current tutorial
	else
		self:UpdateItemContainerAndSlotInfo()
		if self.data then
			local itemFrame = TutorialHelper:GetItemContainerFrame(self.data.Container, self.data.ContainerSlot);
			if itemFrame then
				self:HidePointerTutorial(self.newItemPointerID);
				self:StartAnimation();
			else
				TutorialManager:Finished(self:Name());
			end
		end
	end
end

function Class_EquipProfessionGear:BAG_UPDATE_DELAYED()
	-- check to see if the player moved the item being tutorialized
	self:UpdateItemContainerAndSlotInfo()
	if self.data then
		self:UpdateState();
	else
		-- for some reason, the item is gone.  maybe the player sold it
		TutorialManager:Finished(self:Name());
	end
end

function Class_EquipProfessionGear:OnInterrupt()
	TutorialManager:Finished(self:Name());
end

function Class_EquipProfessionGear:OnComplete()
	TutorialDragButton:Hide();
	self:HidePointerTutorials();
	self.originFrame = nil;
	self.destFrame = nil;
	self.animationPlaying = false;

	self.data = nil;
	self.skillLine = nil;

	if self.EquipmentChangedTimer then
		self.EquipmentChangedTimer:Cancel();
	end

	if self.AnimTimer then
		self.AnimTimer:Cancel();
		self.AnimTimer = nil;
	end

	EventRegistry:UnregisterCallback("ContainerFrame.OpenBag", self);
	EventRegistry:UnregisterCallback("ContainerFrame.CloseBag", self);
	EventRegistry:UnregisterCallback("ProfessionsFrame.Show", self);
	EventRegistry:UnregisterCallback("ProfessionsFrame.Hide", self);
	EventRegistry:UnregisterCallback("ProfessionsFrame.TabSet", self);
	EventRegistry:UnregisterCallback("ProfessionsFrame.ProfessionSelected", self);
	Dispatcher:UnregisterEvent("BAG_UPDATE_DELAYED", self);
	Dispatcher:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED", self);
	Dispatcher:UnregisterEvent("PLAYER_DEAD", self);
	Dispatcher:UnregisterEvent("ZONE_CHANGED_NEW_AREA", self);
	Dispatcher:UnregisterEvent("SKILL_LINES_CHANGED", self);
end