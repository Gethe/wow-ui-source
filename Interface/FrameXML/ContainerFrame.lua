NUM_CONTAINER_FRAMES = 13;
NUM_BAG_FRAMES = 4;
NUM_REAGENTBAG_FRAMES = 1;
NUM_TOTAL_BAG_FRAMES = NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES;
CONTAINER_OFFSET_Y = 85;
CONTAINER_OFFSET_X = -4;

local CONTAINER_WIDTH = 178;
local CONTAINER_SPACING = 8;
local ITEM_SPACING_X = 5;
local ITEM_SPACING_Y = 5;
local CONTAINER_SCALE = 0.75;
local BACKPACK_BASE_SIZE = 16;
local FRAME_THAT_OPENED_BAGS = nil;
local CONTAINER_HELPTIP_SYSTEM = "ContainerFrame";

local BagUpdaterMixin = {};

function BagUpdaterMixin:MarkBagUpdateDirty(bag)
	if not self.dirtyBags then
		self.dirtyBags = {};
	end

	self.dirtyBags[bag] = true;
end

function BagUpdaterMixin:Clean()
	if self.dirtyBags then
		for bag in pairs(self.dirtyBags) do
			bag:Update();
		end

		self.dirtyBags = nil;
	end
end

local BagUpdaterFrame = CreateFrame("FRAME");
Mixin(BagUpdaterFrame, BagUpdaterMixin);
BagUpdaterFrame:SetScript("OnUpdate", BagUpdaterFrame.Clean);

local function ContainerFrame_IsBankBag(id)
	return id > NUM_TOTAL_BAG_FRAMES;
end

local function ContainerFrame_IsHeldBag(id)
	return id >= 0 and id <= NUM_TOTAL_BAG_FRAMES;
end

local function ContainerFrame_IsGenericHeldBag(id)
	-- This doesn't include specialized bags like the reagent bag or bank bags; it includes the backpack
	return id >= 0 and id <= NUM_BAG_FRAMES;
end

local function ContainerFrame_IsMainBank(id)
	return id == -1;
end

local function ContainerFrame_IsBackpack(id)
	return id == 0;
end

function ContainerFrame_IsReagentBag(id)
	return id == 5;
end

local function ContainerFrame_IsProfessionBag(id)
	return not ContainerFrame_IsBackpack(id) and IsInventoryItemProfessionBag("player", ContainerIDToInventoryID(id));
end

function ContainerFrame_CanContainerUseFilterMenu(id)
	if ContainerFrame_IsMainBank(id) then
		return false;
	end

	return not (ContainerFrame_IsProfessionBag(id) or ContainerFrame_IsReagentBag(id));
end

function ContainerFrame_GetContainerNumSlots(bagId)
	local currentNumSlots = GetContainerNumSlots(bagId);
	local maxNumSlots = currentNumSlots;

	if bagId == 0 and not IsAccountSecured() then
		-- If your account isn't secured then the max number of slots you can have in your backpack is 4 more than your current
		maxNumSlots = currentNumSlots + 4;
	end

	return maxNumSlots, currentNumSlots;
end

function ContainerFrame_AllowedToOpenBags()
	return UIParent:IsShown() and CanOpenPanels();
end

function ToggleBackpack_Combined()
	if IsAnyStandardHeldBagOpen() then
		ContainerFrameCombinedBags:Hide();
	else
		OpenBackpack();
	end
end

function ToggleBackpack_Individual()
	local backpack = GetBackpackFrame();
	if backpack then
		CloseAllBags();
	else
		ToggleBag(0);
	end
end

function ToggleBackpack()
	if not ContainerFrame_AllowedToOpenBags() then
		return;
	end

	if ContainerFrameSettingsManager:IsUsingCombinedBags() then
		ToggleBackpack_Combined();
	else
		ToggleBackpack_Individual();
	end
end

function ToggleBag_Individual(id)
	local size = ContainerFrame_GetContainerNumSlots(id);
	if size > 0 then
		local containerFrame = ContainerFrameUtil_GetShownFrameForID(id);
		if containerFrame then
			if containerFrame:IsBackpack() then
				CloseAllBags();
			else
				containerFrame:Hide();
			end
		else
			if CanAutoSetGamePadCursorControl(true) then
				SetGamePadCursorControl(true);
			end

			ContainerFrame_GenerateFrame(ContainerFrame_GetOpenFrame(id), size, id);
		end
	end
end

function ToggleBag_Combined(id)
	assert(ContainerFrame_IsHeldBag(id));
	ToggleBackpack_Combined();
end

function ToggleBag(id)
	if not ContainerFrame_AllowedToOpenBags() then
		return;
	end

	if ContainerFrameSettingsManager:IsUsingCombinedBags(id) then
		ToggleBag_Combined(id);
	else
		ToggleBag_Individual(id);
	end
end

local ContainerFrame_GetBestFilterIcon;

do
	local BAG_FILTER_ICONS = {
		[Enum.BagSlotFlags.PriorityEquipment] = "bags-icon-equipment",
		[Enum.BagSlotFlags.PriorityConsumables] = "bags-icon-consumables",
		[Enum.BagSlotFlags.PriorityTradeGoods] = "bags-icon-tradegoods",
		[Enum.BagSlotFlags.PriorityJunk] = "bags-icon-junk",
		[Enum.BagSlotFlags.PriorityQuestItems] = "bags-icon-questitem",
	};

	local function ContainerFrame_GetBestFilterIndex(id)
		local filterFlag = ContainerFrameSettingsManager:GetFilterFlag(id);
		if filterFlag then
			return filterFlag;
		end

		if ContainerFrame_CanContainerUseFilterMenu(id) then
			for i, flag in ContainerFrameUtil_EnumerateBagGearFilters() do
				if C_Container.GetBagSlotFlag(id, flag) then
					return flag;
				end
			end
		end
	end

	ContainerFrame_GetBestFilterIcon = function(id)
		local iconIndex = ContainerFrame_GetBestFilterIndex(id);
		if iconIndex then
			return BAG_FILTER_ICONS[iconIndex];
		end
	end
end

local function OpenBag_Combined(id, force)
	if not IsBagOpen(id) then
		ContainerFrame_GenerateFrame(ContainerFrameCombinedBags, 0, 0);
	end
end

local function OpenBag_Individual(id, force)
	local size = ContainerFrame_GetContainerNumSlots(id);
	if ( size > 0 ) then
		local containerFrame, containerShowing = ContainerFrameUtil_GetShownFrameForID(id);

		if not containerShowing then
			ContainerFrame_GenerateFrame(ContainerFrame_GetOpenFrame(id), size, id);
		elseif containerShowing and force then
			ContainerFrame_GenerateFrame(containerFrame, size, id);
			containerFrame:Update();
		end
	end
end

function OpenBag(id, force)
	if not ContainerFrame_AllowedToOpenBags() then
		return;
	end

	if ContainerFrameSettingsManager:IsUsingCombinedBags(id) then
		OpenBag_Combined(id, force);
	else
		OpenBag_Individual(id, force);
	end
end

local function CloseBackpack_Combined()
	local wasShown = ContainerFrameCombinedBags:IsShown();
	ContainerFrameCombinedBags:Hide();
	return wasShown;
end

local function CloseBackpack_Individual()
	local backpack = GetBackpackFrame();
	if backpack then
		backpack:Hide();
		return true;
	end

	return false;
end

function CloseBackpack()
	if ContainerFrameSettingsManager:IsUsingCombinedBags() then
		return CloseBackpack_Combined();
	else
		return CloseBackpack_Individual();
	end
end

local function CloseBag_Individual(id)
	local containerFrame = ContainerFrameUtil_GetShownFrameForID(id);
	if containerFrame then
		UpdateNewItemList(containerFrame);
		containerFrame:Hide();
		return true;
	end

	return false;
end

function CloseBag(id)
	if ContainerFrameSettingsManager:IsUsingCombinedBags(id) then
		return CloseBackpack_Combined();
	else
		return CloseBag_Individual(id);
	end
end

function IsBagOpen(id)
	local combinedbagIndex = ContainerFrameCombinedBags:IsBagOpen(id);
	if combinedbagIndex then
		return true;
	end

	local _, index = ContainerFrameUtil_GetShownFrameForID(id);
	return index ~= nil;
end

function OpenBackpack()
	if not ContainerFrame_AllowedToOpenBags() then
		return;
	end

	if ContainerFrameSettingsManager:IsUsingCombinedBags() then
		OpenBag(0);
		return;
	end

	if not GetBackpackFrame() then
		ToggleBackpack();
	end
end

function UpdateNewItemList(containerFrame)
	local id = containerFrame:GetID()

	for i, itemButton in containerFrame:EnumerateValidItems() do
		C_NewItems.RemoveNewItem(id, itemButton:GetID());
	end
end

function SearchBagsForItem(itemID)
	for i = 0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
		for j = 1, GetContainerNumSlots(i) do
			local id = GetContainerItemID(i, j);
			if (id == itemID and C_NewItems.IsNewItem(i, j)) then
				return i;
			end
		end
	end
	return -1;
end

function SearchBagsForItemLink(itemLink)
	for i = 0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
		for j = 1, GetContainerNumSlots(i) do
			local _, _, _, _, _, _, link = GetContainerItemInfo(i, j);
			if (link == itemLink and C_NewItems.IsNewItem(i, j)) then
				return i;
			end
		end
	end
	return -1;
end

function ContainerFrame_GetOpenFrame(id)
	local lastFrame;

	for i, frame in ContainerFrameUtil_EnumerateContainerFrames() do
		if not frame:IsShown() and frame:CanUseForBagID(id) then
			return frame;
		end

		lastFrame = frame;
	end

	-- If all frames open return the last frame
	lastFrame:Hide();
	return lastFrame;
end

function ContainerFrame_AnchorTutorialToItemButton(tutorialFrame, itemButton)
	tutorialFrame.owner = itemButton:GetParent();
	tutorialFrame:ClearAllPoints();
	tutorialFrame:SetPoint("RIGHT", itemButton, "LEFT", -27, 0);
	tutorialFrame:Show();
end

function ContainerFrame_IsTutorialShown()
	return HelpTip:IsShowingAnyInSystem(CONTAINER_HELPTIP_SYSTEM);
end

function ContainerFrame_ShowTutorialForItemButton(itemButton, tutorialText, tutorialFlag)
	local helpTipInfo = {
		text = tutorialText,
		buttonStyle = HelpTip.ButtonStyle.Close,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = tutorialFlag,
		targetPoint = HelpTip.Point.LeftEdgeCenter,
		offsetX = -3,
		system = CONTAINER_HELPTIP_SYSTEM,
	};
	HelpTip:Show(UIParent, helpTipInfo, itemButton);
	local containerFrame = itemButton:GetParent();
	containerFrame.helpTipSystem = CONTAINER_HELPTIP_SYSTEM;
end

function ContainerFrame_ConsiderItemButtonForAzeriteTutorial(itemButton, itemID)
	if AzeriteUtil.AreAnyAzeriteEmpoweredItemsEquipped() then
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_AZERITE_ITEM_IN_SLOT, true);
		return false;
	end

	return C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(itemID);
end

function ContainerFrame_ConsiderItemButtonForUpgradeTutorial(itemButton, itemID)
	return C_ItemUpgrade.CanUpgradeItem(ItemLocation:CreateFromBagAndSlot(itemButton:GetBagID(), itemButton:GetID()));
end

local ContainerFrameTutorialInfo = {
	{ considerFunction = ContainerFrame_ConsiderItemButtonForAzeriteTutorial, tutorialText = AZERITE_TUTORIAL_ITEM_IN_SLOT, tutorialFlag = LE_FRAME_TUTORIAL_AZERITE_ITEM_IN_SLOT, },
	{ considerFunction = ContainerFrame_ConsiderItemButtonForUpgradeTutorial, tutorialText = ITEM_UPGRADE_TUTORIAL_ITEM_IN_SLOT, tutorialFlag = LE_FRAME_TUTORIAL_UPGRADEABLE_ITEM_IN_SLOT, },
};

function ContainerFrame_HasUnacknowledgedItemTutorial()
	for i, tutorialInfo in ipairs(ContainerFrameTutorialInfo) do
		if not GetCVarBitfield("closedInfoFrames", tutorialInfo.tutorialFlag) then
			return true;
		end
	end

	return false;
end

function ContainerFrame_ShouldDoTutorialChecks()
	return not Kiosk.IsEnabled() and not ContainerFrame_IsTutorialShown() and ContainerFrame_HasUnacknowledgedItemTutorial();
end

function ContainerFrame_CheckItemButtonForTutorials(itemButton, itemID)
	if itemID == nil then
		return false;
	end

	for i, tutorialInfo in ipairs(ContainerFrameTutorialInfo) do
		local tutorialFlag = tutorialInfo.tutorialFlag;
		if not GetCVarBitfield("closedInfoFrames", tutorialFlag) and tutorialInfo.considerFunction(itemButton, itemID) then
			ContainerFrame_ShowTutorialForItemButton(itemButton, tutorialInfo.tutorialText, tutorialFlag);
			return true;
		end
	end

	return false;
end

-- Filters
BAG_FILTER_LABELS = {
	[Enum.BagSlotFlags.PriorityEquipment] = BAG_FILTER_EQUIPMENT,
	[Enum.BagSlotFlags.PriorityConsumables] = BAG_FILTER_CONSUMABLES,
	[Enum.BagSlotFlags.PriorityTradeGoods] = BAG_FILTER_TRADE_GOODS,
	[Enum.BagSlotFlags.PriorityJunk] = BAG_FILTER_JUNK,
	[Enum.BagSlotFlags.PriorityQuestItems] = BAG_FILTER_QUEST_ITEMS,
};

local ContainerFrameFilterDropDown_Initialize = nil;
local ContainerFrameFilterDropDownCombined_Initialize = nil;

do
	local function OnBagFilterClicked(bagID, filterID, value)
		C_Container.SetBagSlotFlag(bagID, filterID, value);
		ContainerFrameSettingsManager:SetFilterFlag(bagID, filterID, value);
	end

	local function AddButtons_BagFilters(bagID, level)
		local info = UIDropDownMenu_CreateInfo();
		info.text = BAG_FILTER_ASSIGN_TO;
		info.isTitle = 1;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info, level);

		info = UIDropDownMenu_CreateInfo();
		local activeBagFilter = ContainerFrameSettingsManager:GetFilterFlag(bagID);

		for i, flag in ContainerFrameUtil_EnumerateBagGearFilters() do
			info.text = BAG_FILTER_LABELS[flag];
			info.checked = activeBagFilter == flag;
			info.func = function(_, _, _, value)
				return OnBagFilterClicked(bagID, flag, not value);
			end

			UIDropDownMenu_AddButton(info, level);
		end
	end

	local function AddButtons_BagCleanup(containerFrame, level)
		local info = UIDropDownMenu_CreateInfo();

		info.text = BAG_FILTER_CLEANUP;
		info.isTitle = 1;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info, level);

		local id = containerFrame:GetBagID();

		info = UIDropDownMenu_CreateInfo();
		info.text = BAG_FILTER_IGNORE;
		info.func = function(_, _, _, value)
			if ContainerFrame_IsMainBank(id) then
				SetBankAutosortDisabled(not value);
			elseif ContainerFrame_IsBackpack(id) then
				SetBackpackAutosortDisabled(not value);
			else
				C_Container.SetBagSlotFlag(id, Enum.BagSlotFlags.DisableAutoSort, not value);
			end
		end

		if ContainerFrame_IsMainBank(id) then
			info.checked = GetBankAutosortDisabled();
		elseif ContainerFrame_IsBackpack(id) then
			info.checked = GetBackpackAutosortDisabled();
		else
			info.checked = C_Container.GetBagSlotFlag(id, Enum.BagSlotFlags.DisableAutoSort);
		end

		UIDropDownMenu_AddButton(info, level);
	end

	local function AddButtons_BagModeToggle(containerFrame, level)
		if ContainerFrame_IsGenericHeldBag(containerFrame:GetBagID()) then
			local info = UIDropDownMenu_CreateInfo();
			info.text = ContainerFrameSettingsManager:IsUsingCombinedBags() and BAG_COMMAND_CONVERT_TO_INDIVIDUAL or BAG_COMMAND_CONVERT_TO_COMBINED;
			info.notCheckable = 1;
			info.func = function(_, _, _, value)
				SetCVar("combinedBags", GetCVarBool("combinedBags") and 0 or 1);
			end

			UIDropDownMenu_AddSeparator();
			UIDropDownMenu_AddButton(info);
		end
	end

	ContainerFrameFilterDropDown_Initialize = function(self, level, addFiltersForAllBags)
		local frame = self:GetParent();
		local id = frame:GetBagID();

		if not (ContainerFrame_IsHeldBag(id) or ContainerFrame_IsBankBag(id)) then
			return;
		end

		if ContainerFrame_CanContainerUseFilterMenu(id) then
			AddButtons_BagFilters(id, level);
		end

		AddButtons_BagCleanup(frame, level);
		AddButtons_BagModeToggle(frame, level);
	end

	local bagNames =
	{
		[0] = BAG_NAME_BACKPACK,
		[1] = BAG_NAME_BAG_1,
		[2] = BAG_NAME_BAG_2,
		[3] = BAG_NAME_BAG_3,
		[4] = BAG_NAME_BAG_4,
	};

	ContainerFrameFilterDropDownCombined_Initialize = function(self, level)
		if level == 1 then
			local info = UIDropDownMenu_CreateInfo();

			info.text = BAG_FILTER_TITLE_SORTING;
			info.isTitle = 1;
			info.notCheckable = 1;
			UIDropDownMenu_AddButton(info, level);

			for i = 0, NUM_BAG_FRAMES do
				local info = UIDropDownMenu_CreateInfo();
				info.text = bagNames[i];
				info.hasArrow = true;
				info.notCheckable = true;
				info.value = i; -- save off the bag id to use on level 2, it will be stored in the global UIDROPDOWNMENU_MENU_VALUE
				UIDropDownMenu_AddButton(info, level);
			end

			AddButtons_BagModeToggle(self:GetParent(), level);
		elseif level == 2 then
			AddButtons_BagFilters(UIDROPDOWNMENU_MENU_VALUE, level);
		end
	end
end

BaseContainerFrameMixin = {};

function BaseContainerFrameMixin:GetBagSize()
	if self.size == nil then
		self:SetBagSize(ContainerFrame_GetContainerNumSlots(self:GetID()));
	end

	return self.size or 0;
end

function BaseContainerFrameMixin:SetBagSize(size)
	self.size = size;
end

function BaseContainerFrameMixin:IsExtended()
	if self:IsBackpack() then
		return self:GetBagSize() > BACKPACK_BASE_SIZE;
	end

	return false;
end

function BaseContainerFrameMixin:IsCombinedBagContainer()
	return false;
end

function BaseContainerFrameMixin:IsBackpack()
	return false;
end

function BaseContainerFrameMixin:IsBankBag()
	return ContainerFrame_IsBankBag(self:GetID());
end

function BaseContainerFrameMixin:EnumerateItems()
	return ipairs(self.Items);
end

do
	local function iterator(container, index)
		index = index + 1;
		if index <= container:GetBagSize() then
			return index, container.Items[index];
		end
	end

	function BaseContainerFrameMixin:EnumerateValidItems()
		return iterator, self, 0;
	end
end

function BaseContainerFrameMixin:UpdateSearchResults()
	for i, itemButton in self:EnumerateValidItems() do
		local isFiltered = select(8, GetContainerItemInfo(itemButton:GetBagID(), itemButton:GetID()));
		itemButton:SetMatchesSearch(not isFiltered);
	end
end

function ContainerFrame_OnEvent(self, event, ...)
	if event == "BAG_OPEN" then
		local bagID = ...;
		if self:GetID() == bagID then
			OpenBag(bagID);
		end
	elseif event == "BAG_CLOSED" then
		local bagID = ...;
		if self:MatchesBagID(bagID) then
			CloseBag(bagID);
		end
	elseif event == "UNIT_INVENTORY_CHANGED" or event == "PLAYER_SPECIALIZATION_CHANGED" then
		self:UpdateItemUpgradeIcons();
	elseif event == "BAG_UPDATE" then
		local bagID = ...;
		if self:MatchesBagID(bagID) then
			BagUpdaterFrame:MarkBagUpdateDirty(self);
		end
	elseif event == "BAG_CONTAINER_UPDATE" then
		ContainerFrameSettingsManager:OnBagContainerUpdate(self);
	elseif event == "ITEM_LOCK_CHANGED" then
		local bagID, slotID = ...;
		if bagID and slotID and self:MatchesBagID(bagID) then
			ContainerFrame_UpdateLockedItem(bagID, slotID);
		end
	elseif event == "BAG_UPDATE_COOLDOWN" then
		self:UpdateCooldowns();
	elseif event == "BAG_NEW_ITEMS_UPDATED" then
		self:Update();
	elseif event == "QUEST_ACCEPTED" then
		self:UpdateIfShown();
	elseif event == "UNIT_QUEST_LOG_CHANGED" then
		local unitTag = ...;
		if unitTag == "player" then
			self:UpdateIfShown();
		end
	elseif event == "DISPLAY_SIZE_CHANGED" then
		UpdateContainerFrameAnchors();
	elseif event == "INVENTORY_SEARCH_UPDATE" then
		self:UpdateSearchResults();
	elseif event == "BAG_SLOT_FLAGS_UPDATED" then
		local bagID = ...;
		if self:MatchesBagID(bagID) then
			ContainerFrameSettingsManager:ClearFilterFlag(bagID);
			self:UpdateFilterIcon();
		end
	elseif event == "BANK_BAG_SLOT_FLAGS_UPDATED" then
		local bagID = ...;
		local bankBagID = bagID + NUM_TOTAL_EQUIPPED_BAG_SLOTS;
		if self:MatchesBagID(bagID) then
			ContainerFrameSettingsManager:ClearFilterFlag(bankBagID);
			self:UpdateFilterIcon();
		end
	end
end

function ContainerFrame_OnLoad(self)
	self:RegisterEvent("BAG_OPEN");
	self:RegisterEvent("BAG_CLOSED");
	self:RegisterEvent("QUEST_ACCEPTED");
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED");

	UIDropDownMenu_SetInitializeFunction(self.FilterDropDown, ContainerFrameFilterDropDown_Initialize);
	self:SetPortraitTextureSizeAndOffset(36, -4, 1);
end

function ContainerFrame_OnHide(self)
	EventRegistry:TriggerEvent("ContainerFrame.CloseBag", self);

	PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE);

	self:UnregisterEvent("BAG_UPDATE");
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED");
	self:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self:UnregisterEvent("ITEM_LOCK_CHANGED");
	self:UnregisterEvent("BAG_UPDATE_COOLDOWN");
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");
	self:UnregisterEvent("INVENTORY_SEARCH_UPDATE");
	self:UnregisterEvent("BAG_NEW_ITEMS_UPDATED");
	self:UnregisterEvent("BAG_SLOT_FLAGS_UPDATED");

	self:CancelRefresh();

	UpdateNewItemList(self);
	ContainerFrameSettingsManager:MarkBagsShownDirty();
	UpdateContainerFrameAnchors();

	self:CloseTutorial();
end

function ContainerFrame_OnShow(self)
	EventRegistry:TriggerEvent("ContainerFrame.OpenBag", self);

	PlaySound(SOUNDKIT.IG_BACKPACK_OPEN);

	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED");
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self:RegisterEvent("ITEM_LOCK_CHANGED");
	self:RegisterEvent("BAG_UPDATE_COOLDOWN");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("INVENTORY_SEARCH_UPDATE");
	self:RegisterEvent("BAG_NEW_ITEMS_UPDATED");
	self:RegisterEvent("BAG_SLOT_FLAGS_UPDATED");

	ContainerFrameSettingsManager:MarkBagsShownDirty();

	HelpTip:Hide(MainMenuBarBackpackButton, AZERITE_TUTORIAL_ITEM_IN_BAG);
end

function ContainerFrame_OnCloseButtonClicked(closeButton)
	closeButton:GetParent():OnCloseClicked();
end

ContainerFrameMixin = CreateFromMixins(BaseContainerFrameMixin);

function ContainerFrameMixin:OnCloseClicked()
	CloseBag(self:GetBagID());
end

function ContainerFrameMixin:UpdateMoneyFrame()
	-- [NB] TODO: Convert to single MoneyFrame for each container, for now every container has its own .MoneyFrame
	-- but this should only be called on containers that would show the MoneyFrame
	if self:IsCombinedBagContainer() then
		self.MoneyFrame:SetHeight(16);
	else
		local info = C_XMLUtil.GetTemplateInfo("SmallMoneyFrameTemplate");
		self.MoneyFrame:SetHeight((info and info.height) or 13);
	end
end

function ContainerFrameMixin:SetBagID(id)
	self:SetID(id);
	self.PortraitButton:SetID(id);
end

function ContainerFrameMixin:GetBagID()
	return self:GetID();
end

function ContainerFrameMixin:GetContainedBagIDs(outContainedBagIDs)
	table.insert(outContainedBagIDs, self:GetBagID());
end

function ContainerFrameMixin:MatchesBagID(id)
	return self:GetBagID() == id;
end

function ContainerFrameMixin:CanUseForBagID(id)
	if ContainerFrame_IsBankBag(id) then
		return self.canUseForBankBag;
	end

	if ContainerFrame_IsReagentBag(id) then
		return self.canUseForReagentBag;
	end

	return true; -- NOTE: Bank bags can still be used for regular bags.
end

function ContainerFrameMixin:GetFirstButtonOffsetY()
	return 9;
end

function ContainerFrameMixin:GetColumns()
	if self:IsCombinedBagContainer() then
		return 10;
	else
		return 4;
	end
end

function ContainerFrameMixin:GetExtraRows()
	if self:IsExtended() then
		return math.ceil((self:GetBagSize() - BACKPACK_BASE_SIZE) / self:GetColumns());
	end

	return 0;
end

function ContainerFrameMixin:GetRows()
	return math.ceil(self:GetBagSize() / self:GetColumns());
end

function ContainerFrameMixin:IsPlusTwoBag()
	if not self:IsCombinedBagContainer() then
		return self:GetBagSize() % self:GetColumns() == 2;
	end

	return false;
end

function ContainerFrameMixin:GetTextureSuffix()
	if self:IsBankBag() then
		return "-Bank";
	end

	return "";
end

function ContainerFrameMixin:UpdateName()
	self:SetTitle(GetBagName(self:GetBagID()));
end

function ContainerFrameMixin:UpdateMiscellaneousFrames()
	if self:IsBackpack() then
		self:SetPortraitToAsset("Interface/Icons/Inv_misc_bag_08");
	else
		self:SetPortraitToBag(self:GetBagID());
	end
end

function ContainerFrameMixin:CheckUpdateDynamicContents()
	local tracker = ContainerFrameSettingsManager:GetTokenTracker(self);
	if tracker then
		tracker:CleanDirty();
	end
end

function ContainerFrameMixin:CalculateWidth()
	return CONTAINER_WIDTH;
end

function ContainerFrameMixin:CalculateHeight()
	local rows = self:GetRows();
	local itemButton = self.Items[1];
	local itemsHeight = (rows * itemButton:GetHeight()) + ((rows - 1) * ITEM_SPACING_Y);
	return itemsHeight + self:GetPaddingHeight() + self:CalculateExtraHeight();
end

function ContainerFrameMixin:CalculateExtraHeight()
	return 0;
end

function ContainerFrameMixin:GetPaddingHeight()
	-- Accounts for the vertical anchor offset at the bottom  and the height of the titlebar and attic.
	return self:GetFirstButtonOffsetY() + 48;
end

function ContainerFrameMixin:GetPaddingWidth()
	return 0;
end

function ContainerFrameMixin:UpdateFrameSize()
	local width = self:CalculateWidth();
	local height = self:CalculateHeight();
	self:SetSize(width, height);
end

function ContainerFrameMixin:GetAnchorLayout()
	return AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.BottomRightToTopLeft, self:GetColumns(), ITEM_SPACING_X, ITEM_SPACING_Y);
end

function ContainerFrameMixin:GetInitialItemAnchor()
	return AnchorUtil.CreateAnchor("BOTTOMRIGHT", self, "BOTTOMRIGHT", -7, self:GetFirstButtonOffsetY());
end

do
	local function SortItemsByExtendedState(item1, item2)
		local extended1, extended2 = item1:IsExtended(), item2:IsExtended();
		if extended1 ~= extended2 then
			return not extended1;
		end

		local bag1, bag2 = item1:GetBagID(), item2:GetBagID();
		if bag1 ~= bag2 then
			return bag1 > bag2;
		end

		local id1, id2 = item1:GetID(), item2:GetID();
		return id1 < id2;
	end

	local function UpdateItemSort(items)
		if not IsAccountSecured() and ContainerFrameSettingsManager:IsUsingCombinedBags() then
			table.sort(items, SortItemsByExtendedState);
		end
	end

	function ContainerFrameMixin:UpdateItemLayout()
		local bagSize = self:GetBagSize();

		local isBankBag = self:IsBankBag();
		local isCombinedBag = self:IsCombinedBagContainer();
		local requiresIDAssignment = isBankBag or not isCombinedBag;
		local itemsToLayout = {};

		for i, itemButton in self:EnumerateValidItems() do
			table.insert(itemsToLayout, itemButton);

			-- NOTE: This workaround has to do with the fact that banks are not using combined inventory yet, so this
			-- is the most ideal place to update the itemSlot id.
			if requiresIDAssignment then
				itemButton:SetID(bagSize - i + 1);
				itemButton:SetBagID(self:GetBagID());
			end

			itemButton:Show();
		end

		UpdateItemSort(itemsToLayout);

		AnchorUtil.GridLayout(itemsToLayout, self:GetInitialItemAnchor(), self:GetAnchorLayout());

		for i = bagSize + 1, #self.Items do
			self.Items[i]:Hide();
		end

		self:LayoutAddSlots();
	end
end

function ContainerFrameMixin:UpdateFilterIcon()
	self.FilterIcon:Hide();
	local filterIcon = ContainerFrame_GetBestFilterIcon(self:GetID());
	if filterIcon then
		self.FilterIcon.Icon:SetAtlas(filterIcon);
		self.FilterIcon:Show();
	end
end

function ContainerFrameMixin:SetSearchBoxPoint(searchBox)
	searchBox:SetPoint("TOPLEFT", self, "TOPLEFT", 42, -37);
	searchBox:SetWidth(96);
end

function ContainerFrameMixin:UpdateSearchBox()
	--Update Searchbox and sort button
	if self:IsBackpack() or self:IsCombinedBagContainer() then
		BagItemSearchBox:SetParent(self);
		BagItemSearchBox:ClearAllPoints();
		self:SetSearchBoxPoint(BagItemSearchBox);
		BagItemSearchBox.anchorBag = self;
		BagItemSearchBox:Show();
		BagItemAutoSortButton:SetParent(self);
		BagItemAutoSortButton:SetPoint("TOPRIGHT", self, "TOPRIGHT", -9, -34);
		BagItemAutoSortButton:Show();
	elseif BagItemSearchBox.anchorBag == self then
		BagItemSearchBox:ClearAllPoints();
		BagItemSearchBox:Hide();
		BagItemSearchBox.anchorBag = nil;
		BagItemAutoSortButton:ClearAllPoints();
		BagItemAutoSortButton:Hide();
	end
end

function ContainerFrameMixin:CloseTutorial()
	if self.helpTipSystem then
		HelpTip:HideAllSystem(self.helpTipSystem);
		self.helpTipSystem = nil;
	end
end

function ContainerFrameMixin:CancelRefresh()
	if self.refresh then
		self.refresh:Cancel();
		self.refresh = nil;
	end
end

function ContainerFrameMixin:AddItemsForRefresh()
	self:CancelRefresh();

	local refresh = ContinuableContainer:Create();
	self.refresh = refresh;

	for i, itemButton in self:EnumerateValidItems() do
		local item = Item:CreateFromBagAndSlot(itemButton:GetBagID(), itemButton:GetID());
		if not item:IsItemEmpty() then
			refresh:AddContinuable(item);
		end
	end

	refresh:ContinueOnLoad(function()
		self.refresh = nil;
		self:UpdateItems();
	end);
end

function ContainerFrameMixin:Update()
	self:UpdateFilterIcon();
	self:UpdateSearchBox();
	self:CloseTutorial();
	self:AddItemsForRefresh();
	self:CheckAuthenticatorSlotsHelpTip();
	self:UpdateItemContextMatching();
end

function ContainerFrameMixin:UpdateItems()
	local tooltipOwner = GameTooltip:GetOwner();
	local shouldDoTutorialChecks = ContainerFrame_ShouldDoTutorialChecks();

	for i, itemButton in self:EnumerateValidItems() do
		local bagID = itemButton:GetBagID();

		local texture, itemCount, locked, quality, readable, _, itemLink, isFiltered, noValue, itemID, isBound = GetContainerItemInfo(bagID, itemButton:GetID());
		local isQuestItem, questID, isActive = GetContainerItemQuestInfo(bagID, itemButton:GetID());

		ClearItemButtonOverlay(itemButton);

		itemButton:SetHasItem(texture);
		itemButton:SetItemButtonTexture(texture);

		local doNotSuppressOverlays = false;
		SetItemButtonQuality(itemButton, quality, itemLink, doNotSuppressOverlays, isBound);

		SetItemButtonCount(itemButton, itemCount);
		SetItemButtonDesaturated(itemButton, locked);

		itemButton:UpdateExtended();
		itemButton:UpdateQuestItem(isQuestItem, questID, isActive);
		itemButton:UpdateNewItem(quality);
		itemButton:UpdateJunkItem(quality, noValue);
		itemButton:UpdateItemContextMatching();
		itemButton:UpdateItemUpgradeIcon();
		itemButton:UpdateCooldown(texture);
		itemButton:SetReadable(readable);
		itemButton:CheckUpdateTooltip(tooltipOwner);

		itemButton:SetMatchesSearch(not isFiltered);
		if itemButton:CheckForTutorials(not isFiltered and shouldDoTutorialChecks, itemID) then
			shouldDoTutorialChecks = false;
		end
	end
end

function ContainerFrameMixin:UpdateIfShown()
	if self:IsShown() then
		self:Update();
	end
end

function ContainerFrameMixin:UpdateItemUpgradeIcons(frame)
	for i, itemButton in self:EnumerateValidItems() do
		itemButton:UpdateItemUpgradeIcon();
	end
end

function ContainerFrameMixin:UpdateCooldowns()
	for i, itemButton in self:EnumerateValidItems() do
		local texture = GetContainerItemInfo(itemButton:GetBagID(), itemButton:GetID());
		itemButton:UpdateCooldown(texture);
	end
end

function ContainerFrameMixin:CheckAuthenticatorSlotsHelpTip()
	-- authenticator slots helpTip
	if self:GetID() == 0 and IsAccountSecured() and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_BAG_SLOTS_AUTHENTICATOR) and not ContainerFrame_IsTutorialShown() then
		local itemButton = self.Items[4];
		local helpTipInfo = {
			text = BACKPACK_AUTHENTICATOR_EXTRA_SLOTS_ADDED,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_BAG_SLOTS_AUTHENTICATOR,
			targetPoint = HelpTip.Point.LeftEdgeCenter,
			offsetX = 1,
			system = CONTAINER_HELPTIP_SYSTEM,
		};
		HelpTip:Show(UIParent, helpTipInfo, itemButton);
		self.helpTipSystem = CONTAINER_HELPTIP_SYSTEM;
	end
end

function ContainerFrameMixin:UpdateItemContextMatching()
	EventRegistry:TriggerEvent("ItemButton.UpdateItemContextMatching", self:GetBagID());
end

function ContainerFrameMixin:UpdateAddSlots()
	-- override if needed
end

function ContainerFrameMixin:LayoutAddSlots()
	-- override if needed
end

function ContainerFrame_UpdateAll()
	for i, frame in ContainerFrameUtil_EnumerateContainerFrames() do
		frame:UpdateIfShown();
	end

	if BankFrame:IsShown() then
		BankFrame_UpdateItems(BankFrame);
	end
end

function ContainerFrame_UpdateLocked(frame)
	local _, locked;
	for i, itemButton in frame:EnumerateValidItems() do
		_, _, locked = GetContainerItemInfo(itemButton:GetBagID(), itemButton:GetID());
		SetItemButtonDesaturated(itemButton, locked);
	end
end

function ContainerFrame_UpdateLockedItem(bagID, slotID)
	local itemButton = ContainerFrameUtil_GetItemButtonAndContainer(bagID, slotID);
	local _, _, locked = GetContainerItemInfo(bagID, slotID);
	SetItemButtonDesaturated(itemButton, locked);
end

function ContainerFrame_GenerateFrame(frame, size, id)
	ContainerFrameSettingsManager:CheckBagSetup();
	ContainerFrameSettingsManager:MarkBagsShownDirty();

	frame:SetBagID(id);
	frame:SetBagSize(size);

	frame:Show();
	frame:Raise();

	frame:UpdateName();
	frame:UpdateMiscellaneousFrames();
	frame:UpdateFrameSize();
	frame:UpdateItemLayout();

	frame:Update();
	UpdateContainerFrameAnchors();

	-- Anchors must be set BEFORE checking any frames that require a completely resolved rect for dynamic updates.
	frame:CheckUpdateDynamicContents();
end

local function GetInitialContainerFrameOffsetX()
	return EditModeUtil:GetRightActionBarWidth() + 10;
end

local function GetContainerScale()
	local containerFrameOffsetX = GetInitialContainerFrameOffsetX();
	local xOffset, yOffset, screenHeight, freeScreenHeight, leftMostPoint, column;
	local screenWidth = GetScreenWidth();
	local containerScale = 1;
	local leftLimit = 0;
	if ( BankFrame:IsShown() ) then
		leftLimit = BankFrame:GetRight() - 25;
	end

	while ( containerScale > CONTAINER_SCALE ) do
		screenHeight = GetScreenHeight() / containerScale;
		-- Adjust the start anchor for bags depending on the multibars
		xOffset = containerFrameOffsetX / containerScale;
		yOffset = CONTAINER_OFFSET_Y / containerScale;
		-- freeScreenHeight determines when to start a new column of bags
		freeScreenHeight = screenHeight - yOffset;
		leftMostPoint = screenWidth - xOffset;
		column = 1;
		local frameHeight;
		local framesInColumn = 0;
		local forceScaleDecrease = false;
		for index, frame in ipairs(ContainerFrameSettingsManager:GetBagsShown()) do
			framesInColumn = framesInColumn + 1;
			frameHeight = frame:GetHeight(true);
			if ( freeScreenHeight < frameHeight ) then
				if framesInColumn == 1 then
					-- If this is the only frame in the column and it doesn't fit, then scale must be reduced and the iteration restarted
					forceScaleDecrease = true;
					break;
				else
					-- Start a new column
					column = column + 1;
					framesInColumn = 0; -- kind of a lie, at this point there's actually a single frame in the new column, but this simplifies where to increment.
					leftMostPoint = screenWidth - ( column * frame:GetWidth(true) * containerScale ) - xOffset;
					freeScreenHeight = screenHeight - yOffset;
				end
			end

			freeScreenHeight = freeScreenHeight - frameHeight;
		end

		if forceScaleDecrease or (leftMostPoint < leftLimit) then
			containerScale = containerScale - 0.01;
		else
			break;
		end
	end

	return math.max(containerScale, CONTAINER_SCALE);
end

function UpdateContainerFrameAnchors()
	local containerScale = GetContainerScale();
	local screenHeight = GetScreenHeight() / containerScale;
	-- Adjust the start anchor for bags depending on the multibars
	local xOffset = GetInitialContainerFrameOffsetX() / containerScale;
	local yOffset = CONTAINER_OFFSET_Y / containerScale;
	-- freeScreenHeight determines when to start a new column of bags
	local freeScreenHeight = screenHeight - yOffset;
	local previousBag;
	local firstBagInMostRecentColumn;
	for index, frame in ipairs(ContainerFrameSettingsManager:GetBagsShown()) do
		frame:SetScale(containerScale);
		if index == 1 then
			-- First bag
			frame:SetPoint("BOTTOMRIGHT", frame:GetParent(), "BOTTOMRIGHT", -xOffset, yOffset);
			firstBagInMostRecentColumn = frame;
		elseif (freeScreenHeight < frame:GetHeight()) or previousBag:IsCombinedBagContainer() then
			-- Start a new column
			freeScreenHeight = screenHeight - yOffset;
			frame:SetPoint("BOTTOMRIGHT", firstBagInMostRecentColumn, "BOTTOMLEFT", -11, 0);
			firstBagInMostRecentColumn = frame;
		else
			-- Anchor to the previous bag
			frame:SetPoint("BOTTOMRIGHT", previousBag, "TOPRIGHT", 0, CONTAINER_SPACING);
		end

		previousBag = frame;
		freeScreenHeight = freeScreenHeight - frame:GetHeight();
	end
end

function ContainerFrameItemButton_GetDebugReportInfo(self)
	local texture, itemCount, locked, quality, readable, _, itemLink, isFiltered, noValue, itemID, isBound = GetContainerItemInfo(self:GetBagID(), self:GetID());
	return { debugType = "ContainerItem", itemLink = itemLink, };
end

function ContainerFrame_GetExtendedPriceString(itemButton, isEquipped, quantity)
	quantity = (quantity or 1);
	isEquipped = (isEquipped or false);

	local slot, bag = itemButton:GetSlotAndBagID();

	local money, itemCount, refundSec, currencyCount, hasEnchants = GetContainerItemPurchaseInfo(bag, slot, isEquipped);
	if ( not refundSec or ((itemCount == 0) and (money == 0) and (currencyCount == 0)) ) then
		return false;
	end

	local count = itemButton.count or 1;
	itemCount =  (itemCount or 0) * quantity;
	local itemsString;

	if ( money > 0 ) then
		itemsString = "|W"..GetMoneyString(money).."|w";
	end

	local maxQuality = 0;
	for i=1, itemCount, 1 do
		local itemTexture, itemQuantity, itemLink = GetContainerItemPurchaseItem(bag, slot, i, isEquipped);
		if ( itemLink ) then
			local _, _, itemQuality = GetItemInfo(itemLink);
			maxQuality = math.max(itemQuality, maxQuality);
			if ( itemsString ) then
				itemsString = itemsString .. ", " .. format(ITEM_QUANTITY_TEMPLATE, (itemQuantity or 0) * quantity, itemLink);
			else
				itemsString = format(ITEM_QUANTITY_TEMPLATE, (itemQuantity or 0) * quantity, itemLink);
			end
		end
	end

	for i=1, currencyCount, 1 do
		local currencyTexture, currencyQuantity, currencyName = GetContainerItemPurchaseCurrency(bag, slot, i, isEquipped);
		if ( currencyName ) then
			if ( itemsString ) then
				itemsString = itemsString .. ", |T"..currencyTexture..":0:0:0:-1|t ".. format(CURRENCY_QUANTITY_TEMPLATE, (currencyQuantity or 0) * quantity, currencyName);
			else
				itemsString = " |T"..currencyTexture..":0:0:0:-1|t "..format(CURRENCY_QUANTITY_TEMPLATE, (currencyQuantity or 0) * quantity, currencyName);
			end
		end
	end

	if(itemsString == nil) then
		itemsString = "";
	end
	MerchantFrame.price = 0;
	MerchantFrame.refundBag = bag;
	MerchantFrame.refundSlot = slot;
	MerchantFrame.honorPoints = nil;
	MerchantFrame.arenaPoints = nil;

	local refundItemTexture, refundItemLink, _;
	if ( isEquipped ) then
		refundItemTexture = GetInventoryItemTexture("player", slot);
		refundItemLink = GetInventoryItemLink("player", slot);
	else
		refundItemTexture, _, _, _, _, _, refundItemLink = GetContainerItemInfo(bag, slot);
	end
	local itemName, _, itemQuality = GetItemInfo(refundItemLink);
	local r, g, b = GetItemQualityColor(itemQuality);
	local textLine2 = "";
	if (hasEnchants) then
		textLine2 = "\n\n"..CONFIRM_REFUND_ITEM_ENHANCEMENTS_LOST;
	end
	StaticPopupDialogs["CONFIRM_REFUND_TOKEN_ITEM"].hasMoneyFrame = nil;
	StaticPopup_Show("CONFIRM_REFUND_TOKEN_ITEM", itemsString, textLine2, {["texture"] = refundItemTexture, ["name"] = itemName, ["color"] = {r, g, b, 1}, ["link"] = refundItemLink, ["index"] = nil, ["count"] = count * quantity});
	return true;
end

function ContainerFrameItemButton_OnClick(self, button)
	MerchantFrame_ResetRefundItem();

	if ( button == "LeftButton" ) then
		local type, money = GetCursorInfo();
		if ( SpellCanTargetItem() or SpellCanTargetItemID() ) then
			-- Target the spell with the selected item
			UseContainerItem(self:GetBagID(), self:GetID());
		elseif ( type == "guildbankmoney" ) then
			WithdrawGuildBankMoney(money);
			ClearCursor();
		elseif ( type == "money" ) then
			DropCursorMoney();
			ClearCursor();
		elseif ( type == "merchant" ) then
			if ( MerchantFrame.extendedCost ) then
				MerchantFrame_ConfirmExtendedItemCost(MerchantFrame.extendedCost);
			elseif ( MerchantFrame.highPrice ) then
				MerchantFrame_ConfirmHighCostItem(MerchantFrame.highPrice);
			else
				PickupContainerItem(self:GetBagID(), self:GetID());
			end
		else
			PickupContainerItem(self:GetBagID(), self:GetID());
			if ( CursorHasItem() ) then
				MerchantFrame_SetRefundItem(self);
			end
		end
		StackSplitFrame:Hide();
	else
		if ( MerchantFrame:IsShown() ) then
			if ( MerchantFrame.selectedTab == 2 ) then
				-- Don't sell the item if the buyback tab is selected
				return;
			end
			if ( ContainerFrame_GetExtendedPriceString(self)) then
				-- a confirmation dialog has been shown
				return;
			end
		else
			local itemLocation = ItemLocation:CreateFromBagAndSlot(self:GetBagID(), self:GetID());
			local itemIsValidAuctionItem = (itemLocation:IsValid() and C_AuctionHouse.IsSellItemValid(itemLocation, --[[ displayError = ]] false));
			local itemIsValidItem = itemLocation:IsValid() and C_Item.DoesItemExist(itemLocation);

			-- Don't send invalid items to auction house unless it's on the listing page (it will show an error for this case).
			local shouldAuctionReceiveEvent = AuctionHouseFrame and AuctionHouseFrame:IsShown() and (AuctionHouseFrame:IsListingAuctions() or itemIsValidAuctionItem);
			if shouldAuctionReceiveEvent then
				AuctionHouseFrame:SetPostItem(itemLocation);
				return;
			elseif AzeriteRespecFrame and AzeriteRespecFrame:IsShown() then
				AzeriteRespecFrame:SetRespecItem(itemLocation);
				return;
			elseif RuneforgeFrame and RuneforgeFrame:IsShown() then
				if itemIsValidItem then
					RuneforgeFrame:SetItemAutomatic(itemLocation);
				end

				-- No error for bad items or empty slots.
				return;
			elseif ( not BankFrame:IsShown() and (not GuildBankFrame or not GuildBankFrame:IsShown()) and not MailFrame:IsShown() and (not VoidStorageFrame or not VoidStorageFrame:IsShown()) and
						(not AuctionFrame or not AuctionFrame:IsShown()) and not TradeFrame:IsShown() and (not ItemUpgradeFrame or not ItemUpgradeFrame:IsShown()) and
						(not ObliterumForgeFrame or not ObliterumForgeFrame:IsShown()) and (not ChallengesKeystoneFrame or not ChallengesKeystoneFrame:IsShown()) ) then
				local itemID = select(10, GetContainerItemInfo(self:GetBagID(), self:GetID()));
				if itemID then
					if IsArtifactRelicItem(itemID) then
						if C_ArtifactUI.CanApplyArtifactRelic(itemID, false) then
							SocketContainerItem(self:GetBagID(), self:GetID());
						elseif C_ArtifactUI.GetEquippedArtifactInfo() then
							UIErrorsFrame:AddMessage(ERR_ARTIFACT_RELIC_DOES_NOT_MATCH_ARTIFACT, RED_FONT_COLOR:GetRGBA());
						end
					else
						if itemLocation:IsValid() and C_MountJournal.IsItemMountEquipment(itemLocation) then
							CollectionsJournal_LoadUI();

							if CollectionsJournal:IsShown() then
								local tab = CollectionsJournal_GetTab(CollectionsJournal);
								if tab == COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS then
									MountJournal_ApplyEquipmentFromContainerClick(MountJournal, itemLocation);
								else
									CollectionsJournal_SetTab(CollectionsJournal, COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS);
								end
							else
								ShowUIPanel(CollectionsJournal);
								CollectionsJournal_SetTab(CollectionsJournal, COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS);
							end
						end
					end
				end
			end
		end
		UseContainerItem(self:GetBagID(), self:GetID(), nil, BankFrame:IsShown() and (BankFrame.selectedTab == 2));
		StackSplitFrame:Hide();
	end
end

function ContainerFrameItemButton_CalculateItemTooltipAnchors(self, mainTooltip)
	local x = self:GetRight();
	local anchorFromLeft = x < GetScreenWidth() / 2;
	if ( anchorFromLeft ) then
		mainTooltip:SetAnchorType("ANCHOR_RIGHT", 0, 0);
		mainTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT");
	else
		mainTooltip:SetAnchorType("ANCHOR_LEFT", 0, 0);
		mainTooltip:SetPoint("BOTTOMRIGHT", self, "TOPLEFT");
	end
end

function ContainerFrameExtendedItemButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	ContainerFrameItemButton_CalculateItemTooltipAnchors(self, GameTooltip);
	GameTooltip_SetTitle(GameTooltip, BACKPACK_AUTHENTICATOR_INCREASE_SIZE);
	GameTooltip:Show();
end

ContainerFrameItemButtonMixin = {};

function ContainerFrameItemButtonMixin:GetItemContextMatchResult()
	return ItemButtonUtil.GetItemContextMatchResultForItem(ItemLocation:CreateFromBagAndSlot(self:GetBagID(), self:GetID()));
end

function ContainerFrameItemButtonMixin:OnLoad()
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterForDrag("LeftButton");

	self.UpdateTooltip = ContainerFrameItemButtonMixin.OnUpdate;
	self.timeSinceUpgradeCheck = 0;
	self.GetDebugReportInfo = ContainerFrameItemButton_GetDebugReportInfo;
end

function ContainerFrameItemButtonMixin:OnClick(button)
	local modifiedClick = IsModifiedClick();
	-- If we can loot the item and autoloot toggle is active, then do a normal click
	if ( button ~= "LeftButton" and modifiedClick and IsModifiedClick("AUTOLOOTTOGGLE") ) then
		local _, _, _, _, _, lootable = GetContainerItemInfo(self:GetBagID(), self:GetID());
		if ( lootable ) then
			modifiedClick = false;
		end
	end
	if ( modifiedClick ) then
		self:OnModifiedClick(button);
	else
		ContainerFrameItemButton_OnClick(self, button);
	end
end

-- NOTE: Tutorials hook this, possibly refactor later.
function ContainerFrameItemButton_OnEnter(self)
	self:OnEnter()
end

function ContainerFrameItemButtonMixin:OnEnter()
	self:OnUpdate();

	if ArtifactFrame and self:HasItem() then
		ArtifactFrame:OnInventoryItemMouseEnter(self:GetBagID(), self:GetID());
	end
end

function ContainerFrameItemButtonMixin:OnLeave()
	GameTooltip_Hide();
	if ( not SpellIsTargeting() ) then
		ResetCursor();
	end

	if ( ArtifactFrame ) then
		ArtifactFrame:OnInventoryItemMouseLeave(self:GetBagID(), self:GetID());
	end
end

function ContainerFrameItemButtonMixin:OnUpdate()
	GameTooltip:SetOwner(self, "ANCHOR_NONE");

	C_NewItems.RemoveNewItem(self:GetBagID(), self:GetID());

	self.NewItemTexture:Hide();
	self.BattlepayItemTexture:Hide();

	if ( self.flashAnim:IsPlaying() or self.newitemglowAnim:IsPlaying() ) then
		self.flashAnim:Stop();
		self.newitemglowAnim:Stop();
	end

	local showSell = nil;
	local hasCooldown, repairCost, speciesID, level, breedQuality, maxHealth, power, speed, name = GameTooltip:SetBagItem(self:GetBagID(), self:GetID());
	if ( speciesID and speciesID > 0 ) then
		ContainerFrameItemButton_CalculateItemTooltipAnchors(self, GameTooltip); -- Battle pet tooltip uses the GameTooltip's anchor
		BattlePetToolTip_Show(speciesID, level, breedQuality, maxHealth, power, speed, name);
		return;
	else
		if ( BattlePetTooltip ) then
			BattlePetTooltip:Hide();
		end
	end

	ContainerFrameItemButton_CalculateItemTooltipAnchors(self, GameTooltip);

	if ( IsModifiedClick("COMPAREITEMS") or GetCVarBool("alwaysCompareItems") ) then
		GameTooltip_ShowCompareItem(GameTooltip);
	end

	if ( InRepairMode() and (repairCost and repairCost > 0) ) then
		GameTooltip:AddLine(REPAIR_COST, nil, nil, nil, true);
		SetTooltipMoney(GameTooltip, repairCost);
		GameTooltip:Show();
	elseif ( MerchantFrame:IsShown() and MerchantFrame.selectedTab == 1 ) then
		showSell = 1;
	end

	if ( not SpellIsTargeting() ) then
		if ( IsModifiedClick("DRESSUP") and self:HasItem() ) then
			ShowInspectCursor();
		elseif ( showSell ) then
			ShowContainerSellCursor(self:GetBagID(), self:GetID());
		elseif ( self:IsReadable() ) then
			ShowInspectCursor();
		else
			ResetCursor();
		end
	end

	if ( not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_MOUNT_EQUIPMENT_SLOT_FRAME) ) then
		local itemLocation = ItemLocation:CreateFromBagAndSlot(self:GetBagID(), self:GetID());
		if ( itemLocation and itemLocation:IsValid() and C_PlayerInfo.CanPlayerUseMountEquipment() and (not CollectionsJournal or not CollectionsJournal:IsShown()) ) then
			local tabIndex = 1;
			CollectionsMicroButton_SetAlertShown(tabIndex);
		end
	end
end

local function SplitStack(button, split)
	SplitContainerItem(button:GetBagID(), button:GetID(), split);
end

function ContainerFrameItemButtonMixin:OnModifiedClick(button)
	local itemLocation = ItemLocation:CreateFromBagAndSlot(self:GetBagID(), self:GetID());
	if ( IsModifiedClick("EXPANDITEM") ) then
		if C_Item.DoesItemExist(itemLocation) then
			if C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation) and C_Item.CanViewItemPowers(itemLocation) then
				OpenAzeriteEmpoweredItemUIFromItemLocation(itemLocation);
				return;
			end

			local heartItemLocation = C_AzeriteItem.FindActiveAzeriteItem();
			if heartItemLocation and heartItemLocation:IsEqualTo(itemLocation) then
				OpenAzeriteEssenceUIFromItemLocation(itemLocation);
				return;
			end

			if SocketContainerItem(self:GetBagID(), self:GetID()) then
				return;
			end
		end
	end

	if ( HandleModifiedItemClick(GetContainerItemLink(self:GetBagID(), self:GetID()), itemLocation) ) then
		return;
	end
	if ( not CursorHasItem() and IsModifiedClick("SPLITSTACK") ) then
		local texture, itemCount, locked = GetContainerItemInfo(self:GetBagID(), self:GetID());
		if ( not locked and itemCount and itemCount > 1) then
			self.SplitStack = SplitStack;
			StackSplitFrame:OpenStackSplitFrame(itemCount, self, "BOTTOMRIGHT", "TOPRIGHT");
		end
	end
end

function ContainerFrameItemButtonMixin:OnHide()
	if ( self.hasStackSplit and (self.hasStackSplit == 1) ) then
		StackSplitFrame:Hide();
	end
end

function ContainerFrameItemButtonMixin:OnDragStart(button)
	self:OnClick("LeftButton");
end

function ContainerFrameItemButtonMixin:OnReceiveDrag()
	self:OnDragStart();
end

function ContainerFrameItemButtonMixin:SetBagID(id)
	self.bagID = id;
end

function ContainerFrameItemButtonMixin:GetBagID()
	return self.bagID or self:GetParent():GetID();
end

function ContainerFrameItemButtonMixin:GetSlotAndBagID()
	return self:GetID(), self:GetBagID();
end

function ContainerFrameItemButtonMixin:ChangeOwnership(bag, slot, newParent)
	self:SetBagID(bag);
	self:SetID(slot);
	self:SetParent(newParent);
	self:UpdateExtended();

	-- Potentially temporary, item slots don't have a background, so when they're used in a combined inventory setup
	-- they need to make their own.
	local isCombined = newParent:IsCombinedBagContainer();
	if isCombined and not self.ItemSlotBackground then
		self.ItemSlotBackground = self:CreateTexture(nil, "BACKGROUND", "ItemSlotBackgroundCombinedBagsTemplate", -6);
		self.ItemSlotBackground:SetAllPoints(self);
	end

	if self.ItemSlotBackground then
		self.ItemSlotBackground:SetShown(isCombined);
	end
end

function ContainerFrameItemButtonMixin:UpdateQuestItem(isQuestItem, questID, isActive)
	if ( questID and not isActive ) then
		self.IconQuestTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG);
		self.IconQuestTexture:Show();
	elseif ( questID or isQuestItem ) then
		self.IconQuestTexture:SetTexture(TEXTURE_ITEM_QUEST_BORDER);
		self.IconQuestTexture:Show();
	else
		self.IconQuestTexture:Hide();
	end
end

function ContainerFrameItemButtonMixin:UpdateNewItem(quality)
	if C_NewItems.IsNewItem(self:GetBagID(), self:GetID()) then
		if IsBattlePayItem(self:GetBagID(), self:GetID()) then
			self.NewItemTexture:Hide();
			self.BattlepayItemTexture:Show();
		else
			if (quality and NEW_ITEM_ATLAS_BY_QUALITY[quality]) then
				self.NewItemTexture:SetAtlas(NEW_ITEM_ATLAS_BY_QUALITY[quality]);
			else
				self.NewItemTexture:SetAtlas("bags-glow-white");
			end
			self.BattlepayItemTexture:Hide();
			self.NewItemTexture:Show();
		end
		if (not self.flashAnim:IsPlaying() and not self.newitemglowAnim:IsPlaying()) then
			self.flashAnim:Play();
			self.newitemglowAnim:Play();
		end
	else
		self.BattlepayItemTexture:Hide();
		self.NewItemTexture:Hide();
		if (self.flashAnim:IsPlaying() or self.newitemglowAnim:IsPlaying()) then
			self.flashAnim:Stop();
			self.newitemglowAnim:Stop();
		end
	end
end

function ContainerFrameItemButtonMixin:UpdateJunkItem(quality, noValue)
	self.JunkIcon:Hide();

	local itemLocation = ItemLocation:CreateFromBagAndSlot(self:GetBagID(), self:GetID());
	if C_Item.DoesItemExist(itemLocation) then
		local isJunk = quality == Enum.ItemQuality.Poor and not noValue and MerchantFrame:IsShown();
		self.JunkIcon:SetShown(isJunk);
	end
end

function ContainerFrameItemButtonMixin:UpdateItemUpgradeIcon()
	self.timeSinceUpgradeCheck = 0;

	local itemIsUpgrade = IsContainerItemAnUpgrade(self:GetBagID(), self:GetID());
	if ( itemIsUpgrade == nil and not self.isExtended) then -- nil means not all the data was available to determine if this is an upgrade.
		self.UpgradeIcon:SetShown(false);
		self:SetScript("OnUpdate", self.TryUpdateItemUpgradeIcon);
	elseif (not self.isExtended) then
		self.UpgradeIcon:SetShown(itemIsUpgrade);
		self:SetScript("OnUpdate", nil);
	end
end

local ITEM_UPGRADE_CHECK_TIME = 0.5;
function ContainerFrameItemButtonMixin:TryUpdateItemUpgradeIcon(elapsed)
	self.timeSinceUpgradeCheck = self.timeSinceUpgradeCheck + elapsed;
	if ( self.timeSinceUpgradeCheck >= ITEM_UPGRADE_CHECK_TIME ) then
		self:UpdateItemUpgradeIcon();
	end
end

function ContainerFrameItemButtonMixin:SetHasItem(hasItem)
	if hasItem then
		self.hasItem = 1;
	else
		self.hasItem = nil;
	end
end

function ContainerFrameItemButtonMixin:HasItem()
	return self.hasItem;
end

function ContainerFrameItemButtonMixin:SetReadable(readable)
	self.readable = readable;
end

function ContainerFrameItemButtonMixin:IsReadable()
	return self.readable;
end

function ContainerFrameItemButtonMixin:UpdateCooldown(hasItem)
	self:SetHasItem(hasItem);

	if hasItem then
		local start, duration, enable = GetContainerItemCooldown(self:GetBagID(), self:GetID());
		CooldownFrame_Set(self.Cooldown, start, duration, enable);
		if ( duration > 0 and enable == 0 ) then
			SetItemButtonTextureVertexColor(self, 0.4, 0.4, 0.4);
		else
			SetItemButtonTextureVertexColor(self, 1, 1, 1);
		end
	else
		self.Cooldown:Hide();
	end
end

function ContainerFrameItemButtonMixin:CheckUpdateTooltip(tooltipOwner)
	if self == tooltipOwner then
		if self:HasItem() then
			self:UpdateTooltip();
		else
			GameTooltip:Hide();
		end
	end
end

function ContainerFrameItemButtonMixin:SetIsExtended(isExtended)
	self.isExtended = isExtended;
end

function ContainerFrameItemButtonMixin:IsExtended()
	return self.isExtended;
end

function ContainerFrameItemButtonMixin:UpdateExtended()
	local oldIsExtended = self.isExtended;

	local slotId, bagId = self:GetSlotAndBagID();
	local _, currentNumSlots = ContainerFrame_GetContainerNumSlots(bagId);
	-- If a slotId is greater than our currentNumSlots then it is an extended (locked) slot which can't be used until your account is secured 
	self:SetIsExtended(slotId > currentNumSlots);

	if self.isExtended ~= oldIsExtended then
		if self:IsExtended() then
			if not self.extendedFrame then
				self.extendedFrame = CreateFrame("FRAME", nil, self, "ContainerFrameExtendedItemButtonTemplate");
				self.extendedFrame:SetAllPoints(self);
			end
			self.extendedFrame:Show();
			self:EnableMouse(false);
		else
			if self.extendedFrame then
				self.extendedFrame:Hide();
			end
			self:EnableMouse(true);
		end
	end
end

function ContainerFrameItemButtonMixin:CheckForTutorials(couldHaveTutorial, itemID)
	if couldHaveTutorial then
		return ContainerFrame_CheckItemButtonForTutorials(self, itemID);
	end

	return false;
end

ContainerFramePortraitButtonMixin = {};

function ContainerFramePortraitButtonMixin:OnMouseDown()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	ToggleDropDownMenu(1, nil, self:GetParent().FilterDropDown, self, 0, 0);
	if ContainerFrame_IsBackpack(self:GetID()) then
		HelpTip:Hide(UIParent, TUTORIAL_HUD_REVAMP_BAG_CHANGES);
	end
end

function ContainerFramePortraitButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	local waitingOnData = false;
	if self:GetParent():MatchesBagID(0) then
		GameTooltip:SetText(BACKPACK_TOOLTIP, 1.0, 1.0, 1.0);
		if (GetBindingKey("TOGGLEBACKPACK")) then
			GameTooltip:AppendText(" "..NORMAL_FONT_COLOR_CODE.."("..GetBindingKey("TOGGLEBACKPACK")..")"..FONT_COLOR_CODE_CLOSE)
		end
	else
		local parent = self:GetParent();
		local id = parent:GetBagID();
		local link = GetInventoryItemLink("player", ContainerIDToInventoryID(id));
		local name, _, quality = GetItemInfo(link);
		if name and quality then
			local r, g, b = GetItemQualityColor(quality);
			GameTooltip:SetText(name, r, g, b);
		else
			GameTooltip:SetText(RETRIEVING_ITEM_INFO, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			waitingOnData = true;
		end

		if ContainerFrame_CanContainerUseFilterMenu(id) then
			local filterFlag = ContainerFrameSettingsManager:GetFilterFlag(id);
			if filterFlag then
				GameTooltip:AddLine(BAG_FILTER_ASSIGNED_TO:format(BAG_FILTER_LABELS[filterFlag]));
			end
		end
		local binding = GetBindingKey("TOGGLEBAG"..(4 - self:GetID() + 1));
		if ( binding ) then
			GameTooltip:AppendText(" "..NORMAL_FONT_COLOR_CODE.."("..binding..")"..FONT_COLOR_CODE_CLOSE);
		end
	end
	GameTooltip:AddLine(CLICK_BAG_SETTINGS);
	self.UpdateTooltip = waitingOnData and ContainerFramePortraitButton_OnEnter or nil;
	GameTooltip:Show();
end

function ContainerFramePortraitButtonMixin:OnLeave()
	GameTooltip_Hide();
end

function ContainerFramePortraitButtonMixin:OnShow()
	if ( self:GetID() == 0 ) then
		if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_HUD_REVAMP_BAG_CHANGES) then
			local helpTipInfo = {
				text = TUTORIAL_HUD_REVAMP_BAG_CHANGES,
				buttonStyle = HelpTip.ButtonStyle.Close,
				cvarBitfield = "closedInfoFrames",
				bitfieldFlag = LE_FRAME_TUTORIAL_HUD_REVAMP_BAG_CHANGES,
				targetPoint = HelpTip.Point.LeftEdgeCenter,
				offsetX = 0,
				alignment = HelpTip.Alignment.Center,
				acknowledgeOnHide = true,
			};
			HelpTip:Show(UIParent, helpTipInfo, self);
		end
	end
end

function ContainerFramePortraitButtonMixin:OnHide()
	HelpTip:Hide(UIParent, TUTORIAL_HUD_REVAMP_BAG_CHANGES);
end

local function OpenAllBagsInternal(includeBank)
	OpenBackpack();

	local startIndex  = ContainerFrameSettingsManager:IsUsingCombinedBags() and (NUM_BAG_FRAMES + 1) or 1;
	local endIndex = includeBank and NUM_CONTAINER_FRAMES or NUM_TOTAL_BAG_FRAMES;

	for i = startIndex, endIndex do
		OpenBag(i);
	end

	EventRegistry:TriggerEvent("ContainerFrame.OpenAllBags");
end

function OpenAllBags(frame, forceUpdate)
	if not ContainerFrame_AllowedToOpenBags() then
		return;
	end

	if ( IsAnyBagOpen() ) then
		if ( forceUpdate ) then
			ContainerFrame_UpdateAll();
		end

		return;
	end

	if( frame and not FRAME_THAT_OPENED_BAGS ) then
		FRAME_THAT_OPENED_BAGS = frame:GetName();
	end

	local excludeBank = false;
	OpenAllBagsInternal(excludeBank);
end

function ToggleAllBags()
	if not ContainerFrame_AllowedToOpenBags() then
		return;
	end

	local bagsOpen = 0;
	local totalBags = 1;
	if IsBagOpen(0) then
		bagsOpen = bagsOpen + 1;
		CloseBackpack();
	end

	-- We need to close individual bags only if we're using individual bags, or the bag in question is always shown individually.
	local isUsingCombinedBags = ContainerFrameSettingsManager:IsUsingCombinedBags();
	for i = 1, NUM_TOTAL_BAG_FRAMES, 1 do
		if not (isUsingCombinedBags and ContainerFrame_IsGenericHeldBag(i)) then
			if GetContainerNumSlots(i) > 0 then
				totalBags = totalBags + 1;
			end

			if IsBagOpen(i) then
				CloseBag(i);
				bagsOpen = bagsOpen + 1;
			end
		end
	end

	if bagsOpen < totalBags then
		local excludeBank = false;
		OpenAllBagsInternal(excludeBank);
		return;
	elseif BankFrame:IsShown() then
		bagsOpen = 0;
		totalBags = 0;
		for i = NUM_TOTAL_BAG_FRAMES + 1, NUM_CONTAINER_FRAMES do
			if GetContainerNumSlots(i) > 0 then
				totalBags = totalBags + 1;
			end

			if IsBagOpen(i) then
				CloseBag(i);
				bagsOpen = bagsOpen + 1;
			end
		end

		if bagsOpen < totalBags then
			local includeBank = true;
			OpenAllBagsInternal(includeBank);
			return;
		end
	end

	assert(IsAnyBagOpen() == false);
	EventRegistry:TriggerEvent("ContainerFrame.CloseAllBags");
end

local function CheckIsBagOpen_Internal(startBagID, endBagID, checkingAny)
	for i = startBagID, endBagID do
		if IsBagOpen(i) == checkingAny then
			return checkingAny;
		end
	end

	return not checkingAny;
end

function IsAnyBagOpen()
	local checkingAny = true;
	return CheckIsBagOpen_Internal(0, NUM_TOTAL_BAG_FRAMES, checkingAny);
end

function IsAnyStandardHeldBagOpen()
	local checkingAny = true;
	return CheckIsBagOpen_Internal(0, NUM_BAG_FRAMES, checkingAny);
end

function AreAllBagsOpen()
	local checkingAll = false;
	return CheckIsBagOpen_Internal(0, NUM_TOTAL_BAG_FRAMES, checkingAll);
end

function AreAllStandardHeldBagsOpen()
	local checkingAll = false;
	return CheckIsBagOpen_Internal(0, NUM_BAG_FRAMES, checkingAll);
end

function OpenAllBagsMatchingContext(frame)
	local count = 0;
	for i = 0, NUM_TOTAL_BAG_FRAMES do
		if ItemButtonUtil.GetItemContextMatchResultForContainer(i) == ItemButtonUtil.ItemContextMatchResult.Match then
			if not IsBagOpen(i) then
				OpenBag(i);
				count = count + 1;
			end
		end
	end

	if frame and not FRAME_THAT_OPENED_BAGS then
		FRAME_THAT_OPENED_BAGS = frame:GetName();
	end

	return count;
end

function CloseAllBags(frame, forceUpdate)
	if frame and frame:GetName() ~= FRAME_THAT_OPENED_BAGS then
		if forceUpdate then
			ContainerFrame_UpdateAll();
		end

		-- This frame wasn't the one that opened the bags, nothing closed.
		return false;
	end

	FRAME_THAT_OPENED_BAGS = nil;

	local bagsClosed = CloseBackpack();
	for i=1, NUM_TOTAL_BAG_FRAMES, 1 do
		bagsClosed = CloseBag(i) or bagsClosed;
	end

	EventRegistry:TriggerEvent("ContainerFrame.CloseAllBags");

	return bagsClosed;
end

function GetBackpackFrame()
	if ContainerFrame1:IsShown() then
		return ContainerFrame1;
	end

	return nil;
end

function ContainerFrameUtil_GetItemButtonAndContainer(bagID, slot)
	local container = ContainerFrameUtil_GetShownFrameForID(bagID);
	if container then
		for itemIndex, itemButton in container:EnumerateValidItems() do
			if itemButton:GetBagID() == bagID and itemButton:GetID() == slot then
				return itemButton, container;
			end
		end
	end
end

function ContainerFrame_GetItemButtonCheckSecuredAccount(bagID, slot)
	if bagID == 0 and not IsAccountSecured() then
		slot = slot + 4;
	end

	return ContainerFrameUtil_GetItemButtonAndContainer(bagID, slot);
end

ContainerFrameUtil_EnumerateContainerFrames = nil;
ContainerFrameUtil_EnumerateBagFrames = nil;
ContainerFrameUtil_EnumerateBagGearFilters = nil;

local ContainerFrameUtil_MarkContainerEnumeratorDirty;

do
	local containerFrames;
	local bagFrames;
	local function InitializeFrameEnumerator(startIndex, endIndex, frameTable)
		for i = startIndex, endIndex do
			local frame = UIParent.ContainerFrames[i];
			if frame then
				table.insert(frameTable, frame);
			end
		end
	end

	InitializeEnumerateContainerFrames = function()
		containerFrames = {};
		bagFrames = {};

		if ContainerFrameSettingsManager:IsUsingCombinedBags() then
			containerFrames[1] = ContainerFrameCombinedBags;
			bagFrames[1] = ContainerFrameCombinedBags;
		end

		InitializeFrameEnumerator(1, NUM_CONTAINER_FRAMES, containerFrames);

		if not ContainerFrameSettingsManager:IsUsingCombinedBags() then
			InitializeFrameEnumerator(1, NUM_BAG_FRAMES, bagFrames);
		end
	end

	ContainerFrameUtil_MarkContainerEnumeratorDirty = function()
		containerFrames = nil;
		bagFrames = nil;
	end

	ContainerFrameUtil_EnumerateContainerFrames = function()
		if not containerFrames then
			InitializeEnumerateContainerFrames();
		end

		return ipairs(containerFrames);
	end

	ContainerFrameUtil_EnumerateBagFrames = function()
		if not bagFrames then
			InitializeEnumerateContainerFrames();
		end

		return ipairs(bagFrames);
	end

	local bagGearFilters = {
		Enum.BagSlotFlags.PriorityEquipment,
		Enum.BagSlotFlags.PriorityConsumables,
		Enum.BagSlotFlags.PriorityTradeGoods,
		Enum.BagSlotFlags.PriorityJunk,
		Enum.BagSlotFlags.PriorityQuestItems,
	}

	ContainerFrameUtil_EnumerateBagGearFilters = function()
		return ipairs(bagGearFilters);
	end
end

function ContainerFrameUtil_GetShownFrameForID(id)
	for i, frame in ContainerFrameUtil_EnumerateContainerFrames() do
		if frame:IsShown() and (not id or frame:MatchesBagID(id)) then
			return frame, i;
		end
	end
end

function ContainerFrameUtil_FindFirstItemButtonAndItemLocation(predicate)
	for bagIndex, bagFrame in ContainerFrameUtil_EnumerateBagFrames() do
		for itemIndex, itemButton in bagFrame:EnumerateValidItems() do
			local itemLocation = ItemLocation:CreateFromBagAndSlot(itemButton:GetBagID(), itemButton:GetID());
			if itemLocation:IsValid() and predicate(itemLocation) then
				return itemButton, itemLocation;
			end
		end
	end

	return nil;
end

ContainerFrameSettingsManager = {};

function ContainerFrameSettingsManager:Init()
	self.bagSetupDirty = true;

	EventRegistry:RegisterFrameEventAndCallback("ADDON_LOADED", self.OnAddonLoaded, self);
	EventRegistry:RegisterFrameEventAndCallback("USE_COMBINED_BAGS_CHANGED", self.OnCombinedBagSettingChanged, self);
	EventRegistry:RegisterFrameEventAndCallback("VARIABLES_LOADED", function()
		local useCombinedBags = GetCVarBool("combinedBags");
		self:OnCombinedBagSettingChanged(useCombinedBags);

		EventRegistry:UnregisterFrameEventAndCallback("VARIABLES_LOADED", self);
	end, self);
end

function ContainerFrameSettingsManager:OnAddonLoaded(addonName)
	if addonName == "Blizzard_TokenUI" then
		EventRegistry:UnregisterFrameEventAndCallback("ADDON_LOADED", self);

		self.TokenTracker = CreateFrame("FRAME", "BackpackTokenFrame", UIParent, "BackpackTokenFrameTemplate");
	end
end

function ContainerFrameSettingsManager:IsUsingCombinedBags(optionalID)
	if optionalID then
		if not ContainerFrame_IsGenericHeldBag(optionalID) or ContainerFrame_IsBankBag(optionalID) then
			return false;
		end
	end

	return self.isUsingCombinedBags;
end

function ContainerFrameSettingsManager:SetUsingCombinedBags(useCombinedBags)
	self.isUsingCombinedBags = useCombinedBags;
end

function ContainerFrameSettingsManager:OnCombinedBagSettingChanged(willUseCombinedBags)
	self:MarkBagSetupDirty();

	if IsAnyBagOpen() then
		local bagIDsToShowAfterChange = {};
		for index, bag in ipairs(self:GetBagsShown()) do
			bag:GetContainedBagIDs(bagIDsToShowAfterChange);
		end

		CloseAllBags(); -- Close all the bags for a full reset of whatever was open

		self:SetUsingCombinedBags(willUseCombinedBags);
		ContainerFrameUtil_MarkContainerEnumeratorDirty();

		for index, bagID in ipairs(bagIDsToShowAfterChange) do
			OpenBag(bagID);
		end
	else
		self:SetUsingCombinedBags(willUseCombinedBags);
		ContainerFrameUtil_MarkContainerEnumeratorDirty();
	end
end

function ContainerFrameSettingsManager:OnBagContainerUpdate(container)
	if self:IsUsingCombinedBags() and container:IsCombinedBagContainer() then
		self:MarkBagSetupDirty();

		if IsBagOpen(0) then
			CloseBag(0);
			OpenBag(0);
		end
	end
end

function ContainerFrameSettingsManager:MarkBagSetupDirty()
	-- [NB] TODO: Will also need to call this when equipped bags change
	self.bagSetupDirty = true;
	self:MarkBagsShownDirty();
end

function ContainerFrameSettingsManager:CheckBagSetup()
	if self.bagSetupDirty then
		if self:IsUsingCombinedBags() then
			self:SetupBagsCombined();
		else
			self:SetupBagsIndividual();
		end
	end

	self.bagSetupDirty = false;
end

function ContainerFrameSettingsManager:GetTokenTracker(container)
	if self.TokenTracker and self.TokenTrackerOwner == container then
		return self.TokenTracker;
	end

	return nil;
end

function ContainerFrameSettingsManager:GetTokenTrackerIfShown(container)
	local tracker = self:GetTokenTracker(container);
	return (tracker and tracker:ShouldShow() and container:IsShown()) and tracker;
end

function ContainerFrameSettingsManager:SetTokenTrackerOwner(container)
	self.TokenTrackerOwner = container;
	container:SetTokenTracker(self.TokenTracker);
	self.TokenTracker:MarkDirty();
end

function ContainerFrameSettingsManager:SetMoneyFrameOwner(container)
	self.MoneyFrameOwner = container;
	container:UpdateMoneyFrame(); -- [NB] TODO: Convert to single money frame
end

function ContainerFrameSettingsManager:SetupBagsCombined()
	local container = ContainerFrameCombinedBags;
	self:SetupBagsGeneric(container);
	self:SetTokenTrackerOwner(container);
	self:SetMoneyFrameOwner(container);
end

function ContainerFrameSettingsManager:SetupBagsIndividual()
	local container = ContainerFrame1;
	self:SetupBagsGeneric();
	self:SetTokenTrackerOwner(container);
	self:SetMoneyFrameOwner(container);
end

function ContainerFrameSettingsManager:SetupBagsGeneric(overrideParent)
	if overrideParent then
		overrideParent:HideItems();
		overrideParent:ClearItems();
	end

	local isOverrideParent = overrideParent ~= nil;

	local function GetBagSetupIndices(ascendingOrder)
		if ascendingOrder then
			return 0, NUM_BAG_FRAMES, 1;
		else
			return NUM_BAG_FRAMES, 0, -1;
		end
	end

	local ascendingOrder = not isOverrideParent or not overrideParent:IsCombinedBagContainer();
	local startIndex, endIndex, increment = GetBagSetupIndices(ascendingOrder);

	for bag = startIndex, endIndex, increment do
		local numBagSlots = ContainerFrame_GetContainerNumSlots(bag);
		for i = 1, numBagSlots do
			local containerFrame = UIParent.ContainerFrames[bag + 1];
			local itemButton = containerFrame.Items[i];
			local slot = numBagSlots - i + 1;

			itemButton:ChangeOwnership(bag, slot, overrideParent or containerFrame);

			if isOverrideParent then
				overrideParent:AddItem(itemButton);
			end
		end
	end
end

function ContainerFrameSettingsManager:GetBagsShown()
	if not self.bagsShown then
		local bagsShown = {};

		for i, frame in ContainerFrameUtil_EnumerateContainerFrames() do
			if frame:IsShown() then
				table.insert(bagsShown, frame);
			end
		end

		self.bagsShown = bagsShown;
	end

	return self.bagsShown;
end

function ContainerFrameSettingsManager:MarkBagsShownDirty()
	self.bagsShown = nil;
end

function ContainerFrameSettingsManager:SetFilterFlag(bagID, flag, value)
	if not self.filterFlags then
		self.filterFlags = {};
	end

	self.filterFlags[bagID] = value and flag;

	for i, containerFrame in ContainerFrameUtil_EnumerateContainerFrames() do
		if containerFrame:GetBagID() == bagID then
			containerFrame:UpdateFilterIcon();
			break;
		end
	end
end

function ContainerFrameSettingsManager:ClearFilterFlag(bagID)
	if not self.filterFlags then
		self.filterFlags = {};
	end

	self.filterFlags[bagID] = nil;
end

function ContainerFrameSettingsManager:GetFilterFlag(bagID)
	if not self.filterFlags then
		self.filterFlags = {};
		self.filterFlags[bagID] = self:QueryFilterFlag(bagID);
	elseif self.filterFlags[bagID] == nil then
		self.filterFlags[bagID] = self:QueryFilterFlag(bagID);
	end

	return self.filterFlags[bagID];
end

function ContainerFrameSettingsManager:QueryFilterFlag(bagID)
	for i, flag in ContainerFrameUtil_EnumerateBagGearFilters() do
		if C_Container.GetBagSlotFlag(bagID, flag) then
			return flag;
		end
	end
end

ContainerFrameSettingsManager:Init();

ContainerFrameExtendedSlotPack = CreateFromMixins(ContainerFrameMixin);

function ContainerFrameExtendedSlotPack:UpdateAddSlots()
	if not self.AddSlotsButton then
		self.AddSlotsButton = CreateFrame("BUTTON", nil, self, "AddExtendedSlotsButtonTemplate");
	end

	self.AddSlotsButton:SetShown(not IsAccountSecured());
end

do
	local function FindTargetExtendedItemButton(container)
		local isCombined = ContainerFrameSettingsManager:IsUsingCombinedBags();
		local lastExtendedItemButton;
		for i, itemButton in container:EnumerateValidItems() do
			if itemButton:IsExtended() then
				lastExtendedItemButton = itemButton;

				if isCombined then
					return lastExtendedItemButton;
				end
			end
		end

		return lastExtendedItemButton;
	end

	function ContainerFrameExtendedSlotPack:LayoutAddSlots()
		if self.AddSlotsButton and self.AddSlotsButton:IsShown() then
			local itemButton = FindTargetExtendedItemButton(self);
			if itemButton then
				self.AddSlotsButton:ClearAllPoints();
				self.AddSlotsButton:SetPoint("LEFT", itemButton, "LEFT", -14, -2);
			end
		end
	end
end

ContainerFrameTokenWatcherMixin = CreateFromMixins(ContainerFrameMixin);

function ContainerFrameTokenWatcherMixin:OnShow()
	EventRegistry:TriggerEvent("ContainerFrame.OnShowTokenWatcher", self);
	self:UpdateTokenTracker();
	ContainerFrame_OnShow(self);
	EventRegistry:RegisterCallback("TokenFrame.OnTokenWatchChanged", self.OnTokenWatchChanged, self);
end

function ContainerFrameTokenWatcherMixin:OnHide()
	ContainerFrame_OnHide(self);
	EventRegistry:UnregisterCallback("TokenFrame.OnTokenWatchChanged", self);
end

function ContainerFrameTokenWatcherMixin:OnTokenWatchChanged()
	self:UpdateTokenTracker();
	self:UpdateFrameSize();
	UpdateContainerFrameAnchors();
end

function ContainerFrameTokenWatcherMixin:SetTokenTracker(tokenFrame)
	tokenFrame:SetParent(self);
	tokenFrame:SetIsCombinedInventory(self:IsCombinedBagContainer());
end

function ContainerFrameTokenWatcherMixin:UpdateTokenTracker()
	local tokenFrame = ContainerFrameSettingsManager:GetTokenTracker(self);
	if tokenFrame then
		local showTokenFrame = tokenFrame:ShouldShow() and self:IsShown()
		tokenFrame:SetShown(showTokenFrame);
	end

	self:UpdateCurrencyFrames();
end

function ContainerFrameTokenWatcherMixin:CalculateExtraHeight()
	local tracker = ContainerFrameSettingsManager:GetTokenTrackerIfShown(self);
	return tracker and tracker:GetHeight() or 0;
end

function ContainerFrameTokenWatcherMixin:UpdateCurrencyFrames()
	local tokenFrame = ContainerFrameSettingsManager:GetTokenTrackerIfShown(self);

	if tokenFrame then
		tokenFrame:ClearAllPoints();
		tokenFrame:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 8, 8);
		tokenFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -8, 8);

		self.MoneyFrame:ClearAllPoints();
		self.MoneyFrame:SetPoint("BOTTOMRIGHT", tokenFrame, "TOPRIGHT", 0, 3);
		self.MoneyFrame:SetPoint("BOTTOMLEFT", tokenFrame, "TOPLEFT", 0, 3);
	else
		self.MoneyFrame:ClearAllPoints();
		self.MoneyFrame:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 8, 8);
		self.MoneyFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -8, 8);
	end

	self.MoneyFrame:Show();
end

ContainerFrameBackpackMixin = CreateFromMixins(ContainerFrameTokenWatcherMixin, ContainerFrameExtendedSlotPack);

function ContainerFrameBackpackMixin:IsBackpack()
	return true;
end

function ContainerFrameBackpackMixin:CanUseForBagID(id)
	return id == 0;
end

function ContainerFrameBackpackMixin:GetInitialItemAnchor()
	return AnchorUtil.CreateAnchor("BOTTOMRIGHT", self.MoneyFrame, "TOPRIGHT", 0, 4);
end

function ContainerFrameBackpackMixin:GetPaddingHeight()
	return ContainerFrameMixin.GetPaddingHeight(self) + 30; -- Account for the search box in the backpack
end

function ContainerFrameBackpackMixin:CalculateExtraHeight()
	return ContainerFrameTokenWatcherMixin.CalculateExtraHeight(self) + self.MoneyFrame:GetHeight();
end

function ContainerFrameBackpackMixin:UpdateMiscellaneousFrames()
	ContainerFrameMixin.UpdateMiscellaneousFrames(self);
	self:UpdateCurrencyFrames();
	self:UpdateAddSlots();
end

ContainerFrameCombinedBagsMixin = CreateFromMixins(ContainerFrameTokenWatcherMixin, ContainerFrameExtendedSlotPack);

function ContainerFrameCombinedBagsMixin:OnLoad()
	ContainerFrame_OnLoad(self);
	self:RegisterEvent("BAG_CONTAINER_UPDATE");
	self.PortraitButton:SetPoint("CENTER", self:GetPortrait() , "CENTER", 3, -3);

	UIDropDownMenu_SetInitializeFunction(self.FilterDropDown, ContainerFrameFilterDropDownCombined_Initialize);
end

function ContainerFrameCombinedBagsMixin:OnShow()
	ContainerFrameTokenWatcherMixin.OnShow(self);
	EventRegistry:RegisterCallback("BagSlot.OnEnter", self.OnBagSlotEnter, self);
	EventRegistry:RegisterCallback("BagSlot.OnLeave", self.OnBagSlotLeave, self);
end

function ContainerFrameCombinedBagsMixin:OnHide()
	ContainerFrameTokenWatcherMixin.OnHide(self);
	EventRegistry:UnregisterCallback("BagSlot.OnEnter", self);
	EventRegistry:UnregisterCallback("BagSlot.OnLeave", self);
end

function ContainerFrameCombinedBagsMixin:IsCombinedBagContainer()
	return true;
end

function ContainerFrameCombinedBagsMixin:IsBagOpen(id)
	if self:IsShown() and id <= NUM_BAG_FRAMES then
		return id;
	end

	return nil; -- Remain consistent with global IsBagOpen
end

do
	local function GetTotalSlotsForCombinedBag()
		local totalSlots = 0;
		for i = 0, NUM_BAG_FRAMES do
			totalSlots = totalSlots + ContainerFrame_GetContainerNumSlots(i);
		end

		return totalSlots;
	end

	function ContainerFrameCombinedBagsMixin:SetBagSize()
		-- Ignore arguments, update the bag size by getting the size of all of the container frames
		self.size = GetTotalSlotsForCombinedBag();
	end
end

function ContainerFrameCombinedBagsMixin:SetBagID(id)
	-- [NB] TODO: This needs to be overridden, but I am not sure how yet
	self:SetID(id);
	-- self.PortraitButton:SetID(id);
end

function ContainerFrameCombinedBagsMixin:MatchesBagID(id)
	return ContainerFrame_IsGenericHeldBag(id);
end

function ContainerFrameCombinedBagsMixin:GetContainedBagIDs(outContainedBagIDs)
	for i = 0, NUM_TOTAL_BAG_FRAMES do
		table.insert(outContainedBagIDs, i);
	end
end

function ContainerFrameCombinedBagsMixin:UpdateMiscellaneousFrames()
	self:SetPortraitToAsset("Interface/Icons/Inv_misc_bag_08");
	self:UpdateAddSlots();
	self:UpdateCurrencyFrames();
end

function ContainerFrameCombinedBagsMixin:CalculateWidth()
	local columns = self:GetColumns();
	local itemButton = self.Items[1];
	local itemsWidth = (columns * itemButton:GetWidth()) + ((columns - 1) * ITEM_SPACING_X);

	return itemsWidth + self:GetPaddingWidth();
end

function ContainerFrameCombinedBagsMixin:GetPaddingWidth()
	return 15;
end

function ContainerFrameCombinedBagsMixin:GetPaddingHeight()
	return 75;
end

function ContainerFrameCombinedBagsMixin:CalculateExtraHeight()
	return ContainerFrameTokenWatcherMixin.CalculateExtraHeight(self) + self.MoneyFrame:GetHeight() + 12; -- extra for  the search bar
end

function ContainerFrameCombinedBagsMixin:ClearItems()
	self.Items = {};
end

function ContainerFrameCombinedBagsMixin:HideItems()
	if self.Items then
		for i = 1, #self.Items do
			self.Items[i]:Hide();
		end
	end
end

function ContainerFrameCombinedBagsMixin:AddItem(item)
	table.insert(self.Items, item);
end

function ContainerFrameCombinedBagsMixin:UpdateName()
	self:SetTitle(COMBINED_BAG_TITLE);
end

function ContainerFrameCombinedBagsMixin:UpdateFilterIcon()

end

function ContainerFrameCombinedBagsMixin:Close()
	CloseAllBags();
end

function ContainerFrameCombinedBagsMixin:GetInitialItemAnchor()
	return AnchorUtil.CreateAnchor("BOTTOMRIGHT", self.MoneyFrame, "TOPRIGHT", 0, 4);
end

function ContainerFrameCombinedBagsMixin:OnTokenWatchChanged()
	self:UpdateTokenTracker();
	self:UpdateFrameSize();
	self:UpdateItemLayout();
	UpdateContainerFrameAnchors();
end

function ContainerFrameCombinedBagsMixin:SetSearchBoxPoint(searchBox)
	searchBox:SetPoint("TOPLEFT", self, "TOPLEFT", 62, -37);
	searchBox:SetWidth(330);
end

function ContainerFrameCombinedBagsMixin:SetItemsMatchingBagHighlighted(bagID, highlight)
	for i, item in self:EnumerateValidItems() do
		item.BagIndicator:SetShown(highlight and item:GetBagID() == bagID);
	end
end

function ContainerFrameCombinedBagsMixin:OnBagSlotEnter(bagSlot)
	if bagSlot:GetIsBarExpanded() then -- Don't highlight items if the bags aren't expanded
		self:SetItemsMatchingBagHighlighted(bagSlot:GetBagID(), true);
	end
end

function ContainerFrameCombinedBagsMixin:OnBagSlotLeave(bagSlot)
	self:SetItemsMatchingBagHighlighted(bagSlot:GetBagID(), false);
end

ContainerFrameCurrencyBorderMixin = {};

function ContainerFrameCurrencyBorderMixin:OnLoad()
	self:SetupPiece(self.Left, self.leftEdge);
	self:SetupPiece(self.Right, self.rightEdge);
	self:SetupPiece(self.Middle, self.centerEdge);
end

function ContainerFrameCurrencyBorderMixin:SetupPiece(piece, atlas)
	piece:SetTexelSnappingBias(0);
	piece:SetAtlas(atlas);
end