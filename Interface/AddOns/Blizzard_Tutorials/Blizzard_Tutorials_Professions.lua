local function ToolTutorialShown()
	return GetCVarBool("professionToolSlotsExampleShown");
end

local function AccessoryTutorialShown()
	return GetCVarBool("professionAccessorySlotsExampleShown");
end

local professionEquipmentTutorialSquelched = false;

function CanShowProfessionEquipmentTutorial()
	return (not professionEquipmentTutorialSquelched) and ((not ToolTutorialShown()) or (not AccessoryTutorialShown()));
end

-- ------------------------------------------------------------------------------------------------------------
-- Profession Gear Inventory Watcher
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
	return CanShowProfessionEquipmentTutorial();
end

function Class_ProfessionGearCheckingService:OnBegin()
	if CanShowProfessionEquipmentTutorial() then
		local profGear = self:GetProfessionGear();
		local slot, item = next(profGear);

		if item then
			TutorialManager:Queue(Class_EquipProfessionGear.name, item);
		end
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
		local slotNumber = i + 1; -- System is set up to use incremented lua index values...
		GetInventoryItemsForSlot(slotNumber, potentialGear);

		for packedLocation, itemLink in pairs(potentialGear) do
			local locationData = EquipmentManager_GetLocationData(packedLocation);
			local invType = select(9, C_Item.GetItemInfo(itemLink));
			local isTool = (invType == "INVTYPE_PROFESSION_TOOL");
			local hasBeenShown;
			if isTool then
				hasBeenShown = ToolTutorialShown();
			else
				hasBeenShown = AccessoryTutorialShown();
			end
			if locationData.isPlayer and locationData.isBags and (not hasBeenShown) then
				local itemLocation = ItemLocation:CreateEmpty();
				itemLocation:SetBagAndSlot(locationData.bag, locationData.slot);
				local itemID = C_Item.GetItemInfoInstant(itemLink);
				if not C_ArtifactUI.IsArtifactItem(itemLocation) and C_PlayerInfo.CanUseItem(itemID) then
					table.insert(professionGear, self:STRUCT_ItemContainer(itemLink, slotNumber, locationData.bag, locationData.slot, isTool));
				end
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

	EventRegistry:RegisterCallback("ContainerFrame.OpenBag", function() self:BagOpened(); end, self);
	EventRegistry:RegisterCallback("ContainerFrame.CloseBag", function() self:UpdateState(); end, self);
	EventRegistry:RegisterCallback("ProfessionsFrame.Show", function() self:UpdateState(); end, self);
	EventRegistry:RegisterCallback("ProfessionsFrame.Hide", function() self:UpdateState(); end, self);
	EventRegistry:RegisterCallback("ProfessionsFrame.TabSet", function() self:UpdateState(); end, self);
	EventRegistry:RegisterCallback("ProfessionsFrame.Minimized", function() self:UpdateState(); end, self);
	EventRegistry:RegisterCallback("Professions.ProfessionSelected", function() self:UpdateState(); end, self);
	
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

function Class_EquipProfessionGear:GetHelptipSystem()
	return "Profession Equipment";
end

function Class_EquipProfessionGear:HideAllHelptips()
	HelpTip:HideAllSystem(self:GetHelptipSystem());
end

function Class_EquipProfessionGear:SquelchTutorial()
	HelpTip:HideAllSystem(self:GetHelptipSystem());
	professionEquipmentTutorialSquelched = true;
	TutorialManager:Finished(self:Name());
end

function Class_EquipProfessionGear:CheckAlreadyShown()
	local alreadyShown;
	if self.data.IsTool then
		alreadyShown = ToolTutorialShown();
	else
		alreadyShown = AccessoryTutorialShown();
	end
	if alreadyShown then
		TutorialManager:Finished(self:Name());
		return true;
	end

	return false;
end

function Class_EquipProfessionGear:Reset()
	if self:CheckAlreadyShown() then
		return;
	end

	self.success = false;
	TutorialDragButton:Hide();
	self:HideAllHelptips();
	self:PrepBags();
end

function Class_EquipProfessionGear:PrepBags()
	-- Dirty hack to make sure all bags are closed
	TutorialHelper:CloseAllBags();
	self.allBagsOpened = false;
	TutorialDragButton:Hide();

	if self.data then
		local data = self.data;
		local helptipInfo =
		{
			text = data.IsTool and PROFESSION_EQUIPMENT_NEWITEM_TOOL_HELPTIP or PROFESSION_EQUIPMENT_NEWITEM_ACCESSORY_HELPTIP,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.TopEdgeCenter,
			alignment = HelpTip.Alignment.Right,
			offsetX = -10,
			system = self:GetHelptipSystem(),
			onAcknowledgeCallback = function() self:SquelchTutorial(); end,
		};
		HelpTip:Show(MainMenuBarBackpackButton, helptipInfo, MainMenuBarBackpackButton);
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
	return ProfessionsFrame and ProfessionsFrame:IsVisible();
end

function Class_EquipProfessionGear:IsCorrectProfessionSelected()
	local currBaseProfessionInfo = C_TradeSkillUI.GetBaseProfessionInfo();
	return currBaseProfessionInfo ~= nil and currBaseProfessionInfo.professionID == self.skillLine;
end

function Class_EquipProfessionGear:IsCorrectProfessionTabSelected()
	return ProfessionsFrame:GetTab() == ProfessionsFrame.recipesTabID;
end

function Class_EquipProfessionGear:UpdateState()
	if not self.data or self:CheckAlreadyShown() then
		return;
	end

	if ProfessionsUtil.IsCraftingMinimized() or not IsAnyBagOpen() then
		self:Reset();
		return;
	end

	self.originFrame = TutorialHelper:GetItemContainerFrame(self.data.Container, self.data.ContainerSlot);

	if self.success then
		TutorialManager:Finished(self:Name());
	elseif self:IsProfessionsFrameVisible() and self:IsCorrectProfessionSelected() and self:IsCorrectProfessionTabSelected() then
		self:HideAllHelptips();
		if self.AnimTimer then
			self.AnimTimer:Cancel();
		end
		self.AnimTimer = C_Timer.NewTimer(0.1, function()
			self:StartAnimation();
		end);
	elseif self:IsProfessionsFrameVisible() and self:IsCorrectProfessionSelected() and not self:IsCorrectProfessionTabSelected() then
		self:HideAllHelptips();
		TutorialDragButton:Hide();
		local helptipInfo =
		{
			text = PROFESSION_EQUIPMENT_NEWITEM_TAB_HELPTIP,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.BottomEdgeCenter,
			system = self:GetHelptipSystem(),
			onAcknowledgeCallback = function() self:SquelchTutorial(); end,
		};
		HelpTip:Show(ProfessionsFrame:GetTabButton(ProfessionsFrame.recipesTabID), helptipInfo, ProfessionsFrame:GetTabButton(ProfessionsFrame.recipesTabID));
	elseif self.originFrame then
		self:HideAllHelptips();
		TutorialDragButton:Hide();
		local helptipInfo =
		{
			text = PROFESSION_EQUIPMENT_NEWITEM_EQUIP_HELPTIP,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.LeftEdgeCenter,
			system = self:GetHelptipSystem(),
			onAcknowledgeCallback = function() self:SquelchTutorial(); end,
		};
		HelpTip:Show(UIParent, helptipInfo, self.originFrame);
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
		--[[
		[29] = ProfessionsFrame.CraftingPage.FishingGear0Slot,
		[30] = ProfessionsFrame.CraftingPage.FishingGear0Slot,
		]]
	}

	self.destFrame = Slot[self.data.CharacterSlot];

	if self.originFrame and self.destFrame then
		self:HideAllHelptips();
		local helptipInfo =
		{
			text = PROFESSION_EQUIPMENT_NEWITEM_EQUIP_HELPTIP,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.LeftEdgeCenter,
			system = self:GetHelptipSystem(),
			onAcknowledgeCallback = function() self:SquelchTutorial(); end,
		};
		HelpTip:Show(UIParent, helptipInfo, self.originFrame);

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
	self:HideAllHelptips();
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

	if self.Timer then
		self.Timer:Cancel();
		self.Timer = nil;
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

-- ------------------------------------------------------------------------------------------------------------
-- New Specialization reminder
-- ------------------------------------------------------------------------------------------------------------
local NewSpecChecker = {};
NewSpecChecker.reminderShownThisSession = false;

function NewSpecChecker:ShowReminder(profName)
	NewSpecChecker.reminderShownThisSession = true;

	if ProfessionsFrame and ProfessionsFrame:IsVisible() then
		return;
	end

	MainMenuMicroButton_ShowAlert(ProfessionMicroButton, PROFESSIONS_NEW_CHOICE_AVAILABLE_SPECIALIZATION:format(C_ProfSpecs.GetNewSpecReminderProfName()));
	MicroButtonPulse(ProfessionMicroButton);
	ProfessionMicroButton.showProfessionSpellHighlights = true;
end

function NewSpecChecker:ShouldShowReminder()
	if NewSpecChecker.reminderShownThisSession then
		return false;
	end

	if C_ProfSpecs.GetNewSpecReminderProfName() then
		return true;
	end

	return false;
end

function NewSpecChecker:CheckShowReminder()
	if self:ShouldShowReminder() then
		self:ShowReminder();
	end
end

EventRegistry:RegisterFrameEventAndCallback("SKILL_LINES_CHANGED", NewSpecChecker.CheckShowReminder, NewSpecChecker);
EventRegistry:RegisterFrameEventAndCallback("SKILL_LINE_SPECS_RANKS_CHANGED", NewSpecChecker.CheckShowReminder, NewSpecChecker);
EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(checker, isLogin)
	if isLogin then
		NewSpecChecker:CheckShowReminder();
	end
end, NewSpecChecker);

-- ------------------------------------------------------------------------------------------------------------
-- Specialization points reminder
-- ------------------------------------------------------------------------------------------------------------
local SpecPointsChecker = {};
SpecPointsChecker.reminderShownThisSession = false;

function SpecPointsChecker:ShowReminder()
	SpecPointsChecker.reminderShownThisSession = true;

	if ProfessionsFrame and ProfessionsFrame:IsVisible() then
		return;
	end

	MainMenuMicroButton_ShowAlert(ProfessionMicroButton, PROFESSIONS_UNSPENT_SPEC_POINTS_REMINDER);
	MicroButtonPulse(ProfessionMicroButton);
	ProfessionMicroButton.showProfessionSpellHighlights = true;
end

function SpecPointsChecker:CheckShowReminder()
	if SpecPointsChecker.reminderShownThisSession then
		return;
	end

	if C_ProfSpecs.ShouldShowPointsReminder() and not NewSpecChecker:ShouldShowReminder() then
		self:ShowReminder();
	end
end

EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", SpecPointsChecker.CheckShowReminder, SpecPointsChecker);
EventRegistry:RegisterFrameEventAndCallback("SKILL_LINE_SPECS_UNLOCKED", SpecPointsChecker.CheckShowReminder, SpecPointsChecker);
EventRegistry:RegisterFrameEventAndCallback("CURRENCY_DISPLAY_UPDATE", SpecPointsChecker.CheckShowReminder, SpecPointsChecker);


function PlayerHasPrimaryProfession()
	local prof1, prof2 = GetProfessions();
	return prof1 or prof2; -- prof2 should never be non-nil when prof1 is nil, but it doesn't hurt
end

-- ------------------------------------------------------------------------------------------------------------
-- First Profession Watcher
-- ------------------------------------------------------------------------------------------------------------
Class_FirstProfessionWatcher = class("FirstProfessionWatcher", Class_TutorialBase);

function Class_FirstProfessionWatcher:OnInitialize()
	if GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_FIRST_PROFESSION) or PlayerHasPrimaryProfession() then
		self:Complete();
	end
end

function Class_FirstProfessionWatcher:OnBegin()
end

function Class_FirstProfessionWatcher:StartWatching()
	Dispatcher:RegisterEvent("SKILL_LINES_CHANGED", self);
end

function Class_FirstProfessionWatcher:StopWatching()
	Dispatcher:UnregisterEvent("SKILL_LINES_CHANGED", self);
end

function Class_FirstProfessionWatcher:SKILL_LINES_CHANGED()
	if PlayerHasPrimaryProfession() and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_FIRST_PROFESSION) then
		TutorialManager:Queue(Class_FirstProfessionTutorial.name);
	end
end

function Class_FirstProfessionWatcher:OnInterrupt()
	self:Complete();
end

function Class_FirstProfessionWatcher:OnComplete()
	self:StopWatching();
end

-- ------------------------------------------------------------------------------------------------------------
-- First Profession Tutorial
-- ------------------------------------------------------------------------------------------------------------
Class_FirstProfessionTutorial = class("FirstProfessionTutorial", Class_TutorialBase);

function Class_FirstProfessionTutorial:OnInitialize()
end

function Class_FirstProfessionTutorial:CanBegin(args)
	return PlayerHasPrimaryProfession() and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_FIRST_PROFESSION);
end

function Class_FirstProfessionTutorial:OnBegin(args)
	if not self:CanBegin() then
		TutorialManager:Finished(self:Name());
	end

	self.success = false;

	EventRegistry:RegisterCallback("ProfessionsFrame.Show", function() 
		self.success = true;
		TutorialManager:Finished(self:Name());
	end);
	EventRegistry:RegisterCallback("ProfessionsBookFrame.Show", function() self:Update(); end, self);
	EventRegistry:RegisterCallback("ProfessionsBookFrame.Hide", function() self:Update(); end, self);
	Dispatcher:RegisterEvent("SKILL_LINES_CHANGED", self);

	self:Update();
end

function Class_FirstProfessionTutorial:SKILL_LINES_CHANGED()
	if not PlayerHasPrimaryProfession() then
		TutorialManager:Finished(self:Name());
	end
end

function Class_FirstProfessionTutorial:GetHelptipSystem()
	return "First Time Profession";
end

function Class_FirstProfessionTutorial:HideAllHelptips()
	HelpTip:HideAllSystem(self:GetHelptipSystem());
end

function Class_FirstProfessionTutorial:AcknowledgeTutorial()
	HelpTip:HideAllSystem(self:GetHelptipSystem());
	self.success = true;
	TutorialManager:Finished(self:Name());
end

function Class_FirstProfessionTutorial:Update()
	HelpTip:HideAllSystem(self:GetHelptipSystem());

	if self.success then
		TutorialManager:Finished(self:Name());
	elseif not ProfessionsBookFrame or not ProfessionsBookFrame:IsVisible() then
		local helpTipInfo = 
		{
			text = PROFESSIONS_NEW_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.TopEdgeCenter,
			system = self:GetHelptipSystem(),
			onAcknowledgeCallback = function() self:AcknowledgeTutorial(); end,
			autoHorizontalSlide = true,
		};
		HelpTip:Show(UIParent, helpTipInfo, ProfessionMicroButton);
		MicroButtonPulse(ProfessionMicroButton);
	else
		local helpTipInfo = 
		{
			text = PROFESSIONS_NEW_TUTORIAL_ICON,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.TopEdgeCenter,
			system = self:GetHelptipSystem(),
			onAcknowledgeCallback = function() self:AcknowledgeTutorial(); end,
			autoHorizontalSlide = true,
		};
		HelpTip:Show(UIParent, helpTipInfo, PrimaryProfession1SpellButtonBottom);
	end
end

function Class_FirstProfessionTutorial:OnInterrupt()
	TutorialManager:Finished(self:Name());
end

function Class_FirstProfessionTutorial:OnComplete()
	HelpTip:HideAllSystem(self:GetHelptipSystem());
	if self.success then
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_FIRST_PROFESSION, true);
	end

	EventRegistry:UnregisterCallback("ProfessionsFrame.Show", self);
	EventRegistry:UnregisterCallback("ProfessionsBookFrame.Show", self);
	EventRegistry:UnregisterCallback("ProfessionsBookFrame.Hide", self);
	Dispatcher:UnregisterEvent("SKILL_LINES_CHANGED", self);
end