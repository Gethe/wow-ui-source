NUM_CONTAINER_FRAMES = 13;
NUM_BAG_FRAMES = 4;
CONTAINER_OFFSET_Y = 70;
CONTAINER_OFFSET_X = -4;
BACKPACK_HEIGHT = 256;

local MAX_CONTAINER_ITEMS = 36;
local NUM_CONTAINER_COLUMNS = 4;
local ROWS_IN_BG_TEXTURE = 5;
local MAX_MIDDLE_TEXTURES = 2;
local BG_TEXTURE_MIDDLE_START = 215;
local BG_TEXTURE_TOP_PLUS_TWO_START = 97;
local BG_TEXTURE_TOP_PLUS_TWO_END = 163;
local BG_TEXTURE_TOP_START = 2;
local BG_TEXTURE_TOP_END = 89;
local BG_TEXTURE_TOP_ONE_ROW_END = 86;
local BG_TEXTURE_HEIGHT = 512;
local CONTAINER_WIDTH = 192;
local CONTAINER_SPACING = 0;
local VISIBLE_CONTAINER_SPACING = 3;
local MINIMUM_CONTAINER_OFFSET_X = 10;
local CONTAINER_SCALE = 0.75;
local BACKPACK_MONEY_OFFSET_DEFAULT = -231;
local BACKPACK_BASE_HEIGHT = 256;
local BACKPACK_DEFAULT_TOPHEIGHT = 256;
local BACKPACK_EXTENDED_TOPHEIGHT = 226;
local BACKPACK_BASE_SIZE = 16;
local ROW_HEIGHT = 41;
local FIRST_BACKPACK_BUTTON_OFFSET_BASE = -225;
local FRAME_THAT_OPENED_BAGS = nil;
local CONTAINER_BOTTOM_TEXTURE_DEFAULT_START = 169;
local CONTAINER_BOTTOM_TEXTURE_DEFAULT_END = 179;
local CONTAINER_BOTTOM_TEXTURE_DEFAULT_HEIGHT = CONTAINER_BOTTOM_TEXTURE_DEFAULT_END - CONTAINER_BOTTOM_TEXTURE_DEFAULT_START;
local CONTAINER_BOTTOM_TEXTURE_DEFAULT_ROW_END = 172;
local CONTAINER_BOTTOM_TEXTURE_DEFAULT_ROW_HEIGHT = CONTAINER_BOTTOM_TEXTURE_DEFAULT_ROW_END - CONTAINER_BOTTOM_TEXTURE_DEFAULT_START;
local CONTAINER_HELPTIP_SYSTEM = "ContainerFrame";

function ContainerFrame_OnLoad(self)
	self:RegisterEvent("BAG_OPEN");
	self:RegisterEvent("BAG_CLOSED");
	self:RegisterEvent("QUEST_ACCEPTED");
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
	ContainerFrame1.bagsShown = 0;
	ContainerFrame1.bags = {};
end

function ContainerFrame_OnEvent(self, event, ...)
	local arg1, arg2 = ...;
	if ( event == "BAG_OPEN" ) then
		if ( self:GetID() == arg1 ) then
			self:Show();
		end
	elseif ( event == "BAG_CLOSED" ) then
		if ( self:GetID() == arg1 ) then
			self:Hide();
		end
	elseif ( event == "UNIT_INVENTORY_CHANGED" or event == "PLAYER_SPECIALIZATION_CHANGED" ) then
		ContainerFrame_UpdateItemUpgradeIcons(self);
	elseif ( event == "BAG_UPDATE" ) then
		if ( self:GetID() == arg1 ) then
 			ContainerFrame_Update(self);
		end
	elseif ( event == "ITEM_LOCK_CHANGED" ) then
		local bag, slot = arg1, arg2;
		if ( bag and slot and (bag == self:GetID()) ) then
			ContainerFrame_UpdateLockedItem(self, slot);
		end
	elseif ( event == "BAG_UPDATE_COOLDOWN" ) then
		ContainerFrame_UpdateCooldowns(self);
	elseif ( event == "BAG_NEW_ITEMS_UPDATED") then
		ContainerFrame_Update(self);
	elseif ( event == "QUEST_ACCEPTED" or (event == "UNIT_QUEST_LOG_CHANGED" and arg1 == "player") ) then
		if (self:IsShown()) then
			ContainerFrame_Update(self);
		end
	elseif ( event == "DISPLAY_SIZE_CHANGED" ) then
		UpdateContainerFrameAnchors();
	elseif ( event == "INVENTORY_SEARCH_UPDATE" ) then
		ContainerFrame_UpdateSearchResults(self);
	elseif ( event == "BAG_SLOT_FLAGS_UPDATED" ) then
		if (self:GetID() == arg1) then
			self.localFlag = nil;
			if (self:IsShown()) then
				ContainerFrame_Update(self);
			end
		end
	elseif ( event == "BANK_BAG_SLOT_FLAGS_UPDATED" ) then
		if (self:GetID() == (arg1 + NUM_BAG_SLOTS)) then
			self.localFlag = nil;
			if (self:IsShown()) then
				ContainerFrame_Update(self);
			end
		end
	end
end

function ContainerFrame_GetContainerNumSlots(id)
	local num = GetContainerNumSlots(id);
	if (id == 0 and not IsAccountSecured()) then
		num = num + 4;
	end
	return num;
end

function ToggleBag(id)
	if ( IsOptionFrameOpen() ) then
		return;
	end

	local size = ContainerFrame_GetContainerNumSlots(id);
	if ( size > 0 or id == KEYRING_CONTAINER ) then
		local containerShowing;
		for i=1, NUM_CONTAINER_FRAMES, 1 do
			local frame = _G["ContainerFrame"..i];
			if ( frame:IsShown() and frame:GetID() == id ) then
				containerShowing = i;
				EventRegistry:TriggerEvent("ContainerFrame.CloseBag", containerShowing);
				frame:Hide();
			end
		end
		if ( not containerShowing ) then
			if ( CanAutoSetGamePadCursorControl(true) ) then
				SetGamePadCursorControl(true);
			end

			ContainerFrame_GenerateFrame(ContainerFrame_GetOpenFrame(), size, id);
		end
	end
end

function ToggleBackpack()
	if ( IsOptionFrameOpen() ) then
		return;
	end
	
	if ( IsBagOpen(0) ) then
		for i=1, NUM_CONTAINER_FRAMES, 1 do
			local frame = _G["ContainerFrame"..i];
			if ( frame:IsShown() ) then
				frame:Hide();
				EventRegistry:TriggerEvent("ContainerFrame.CloseBackpack");
			end
			-- Hide the token bar if closing the backpack
			if ( BackpackTokenFrame ) then
				BackpackTokenFrame:Hide();
			end
		end
	else
		ToggleBag(0);
		-- If there are tokens watched then show the bar
		if ( ManageBackpackTokenFrame ) then
			BackpackTokenFrame_Update();
			ManageBackpackTokenFrame();
		end
	end
end

function ContainerFrame_GetBagButton(self)
	if ( self:GetID() == 0 ) then
		return MainMenuBarBackpackButton;
	else
		local bagButton = _G["CharacterBag"..(self:GetID() - 1).."Slot"];
		if ( bagButton ) then
			return bagButton;
		else
			local bankID = self:GetID() - NUM_BAG_SLOTS;
			return BankSlotsFrame["Bag"..bankID];
		end
	end
end

function ContainerFrame_OnHide(self)
	self:UnregisterEvent("BAG_UPDATE");
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED");
	self:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self:UnregisterEvent("ITEM_LOCK_CHANGED");
	self:UnregisterEvent("BAG_UPDATE_COOLDOWN");
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");
	self:UnregisterEvent("INVENTORY_SEARCH_UPDATE");
	self:UnregisterEvent("BAG_NEW_ITEMS_UPDATED");
	self:UnregisterEvent("BAG_SLOT_FLAGS_UPDATED");

	UpdateNewItemList(self);

	local bagButton = ContainerFrame_GetBagButton(self);
	if ( bagButton ) then
		bagButton.SlotHighlightTexture:Hide();
	end
	ContainerFrame1.bagsShown = ContainerFrame1.bagsShown - 1;
	-- Remove the closed bag from the list and collapse the rest of the entries
	local index = 1;
	while ContainerFrame1.bags[index] do
		if ( ContainerFrame1.bags[index] == self:GetName() ) then
			local tempIndex = index;
			while ContainerFrame1.bags[tempIndex] do
				if ( ContainerFrame1.bags[tempIndex + 1] ) then
					ContainerFrame1.bags[tempIndex] = ContainerFrame1.bags[tempIndex + 1];
				else
					ContainerFrame1.bags[tempIndex] = nil;
				end
				tempIndex = tempIndex + 1;
			end
		end
		index = index + 1;
	end
	UpdateContainerFrameAnchors();

	if ( self:GetID() == KEYRING_CONTAINER ) then
		UpdateMicroButtons();
		PlaySound(SOUNDKIT.KEY_RING_CLOSE);
	else
		PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE);
	end

	ContainerFrame_CloseTutorial(self);
end

function ContainerFrame_OnShow(self)
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED");
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self:RegisterEvent("ITEM_LOCK_CHANGED");
	self:RegisterEvent("BAG_UPDATE_COOLDOWN");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("INVENTORY_SEARCH_UPDATE");
	self:RegisterEvent("BAG_NEW_ITEMS_UPDATED");
	self:RegisterEvent("BAG_SLOT_FLAGS_UPDATED");

	local bagButton = ContainerFrame_GetBagButton(self);
	if ( bagButton ) then
		bagButton.SlotHighlightTexture:Show();
	end
	
	self.FilterIcon:Hide();
	if ( self:GetID() > 0) then -- The actual bank has ID -1, backpack has ID 0, we want to make sure we're looking at a regular or bank bag
		if (not IsInventoryItemProfessionBag("player", ContainerIDToInventoryID(self:GetID()))) then
			for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
				local active = false;
				if ( self:GetID() > NUM_BAG_SLOTS ) then
					active = GetBankBagSlotFlag(self:GetID() - NUM_BAG_SLOTS, i);
				else
					active = GetBagSlotFlag(self:GetID(), i);
				end
				if ( active ) then
					self.FilterIcon.Icon:SetAtlas(BAG_FILTER_ICONS[i], true);
					self.FilterIcon:Show();
					break;
				end
			end
		end
	end
	ContainerFrame1.bags[ContainerFrame1.bagsShown + 1] = self:GetName();
	ContainerFrame1.bagsShown = ContainerFrame1.bagsShown + 1;
	if ( self:GetID() == KEYRING_CONTAINER ) then
		UpdateMicroButtons();
		PlaySound(SOUNDKIT.KEY_RING_OPEN);
	else
		PlaySound(SOUNDKIT.IG_BACKPACK_OPEN);
	end
 	ContainerFrame_Update(self);
	UpdateContainerFrameAnchors();
	
	-- If there are tokens watched then decide if we should show the bar
	if ( ManageBackpackTokenFrame ) then
		ManageBackpackTokenFrame();
	end

	HelpTip:Hide(MainMenuBarBackpackButton, AZERITE_TUTORIAL_ITEM_IN_BAG)
end

function OpenBag(id, force)
	if ( not CanOpenPanels() ) then
		if ( UnitIsDead("player") ) then
			NotWhileDeadError();
		end
		return;
	end

	local size = ContainerFrame_GetContainerNumSlots(id);
	if ( size > 0 ) then
		local containerShowing;
		local containerFrame;
		for i=1, NUM_CONTAINER_FRAMES, 1 do
			local frame = _G["ContainerFrame"..i];
			if ( frame:IsShown() and frame:GetID() == id ) then
				containerShowing = i;
				containerFrame = frame;
			end
		end
		if ( not containerShowing ) then
			ContainerFrame_GenerateFrame(ContainerFrame_GetOpenFrame(), size, id);
		elseif (containerShowing and force) then
			ContainerFrame_GenerateFrame(containerFrame, size, id);
			ContainerFrame_Update(containerFrame);
		end
	end
end

function CloseBag(id)
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local containerFrame = _G["ContainerFrame"..i];
		if ( containerFrame:IsShown() and (containerFrame:GetID() == id) ) then
			UpdateNewItemList(containerFrame);
			containerFrame:Hide();
			return;
		end
	end
end

function IsBagOpen(id)
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local containerFrame = _G["ContainerFrame"..i];
		if ( containerFrame:IsShown() and (containerFrame:GetID() == id) ) then
			return i;
		end
	end
	return nil;
end

function OpenBackpack()
	if ( not CanOpenPanels() ) then
		if ( UnitIsDead("player") ) then
			NotWhileDeadError();
		end
		return;
	end

	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local containerFrame = _G["ContainerFrame"..i];
		if ( containerFrame:IsShown() and (containerFrame:GetID() == 0) ) then
			ContainerFrame1.backpackWasOpen = 1;
			return;
		else
			ContainerFrame1.backpackWasOpen = nil;
		end
	end

	if ( not ContainerFrame1.backpackWasOpen ) then
		ToggleBackpack();
	end
	
	return ContainerFrame1.backpackWasOpen;
end

function CloseBackpack()
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local containerFrame = _G["ContainerFrame"..i];
		if ( containerFrame:IsShown() and (containerFrame:GetID() == 0) and (ContainerFrame1.backpackWasOpen == nil) ) then
			containerFrame:Hide();
			return;
		end
	end
end

function UpdateNewItemList(containerFrame)
	local id = containerFrame:GetID()
	local name = containerFrame:GetName()
	
	for i=1, containerFrame.size, 1 do
		local itemButton = _G[name.."Item"..i];
		C_NewItems.RemoveNewItem(id, itemButton:GetID());
	end
end

function SearchBagsForItem(itemID)
	for i = 0, NUM_BAG_SLOTS do
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
	for i = 0, NUM_BAG_SLOTS do
		for j = 1, GetContainerNumSlots(i) do
			local _, _, _, _, _, _, link = GetContainerItemInfo(i, j);
			if (link == itemLink and C_NewItems.IsNewItem(i, j)) then
				return i;
			end
		end
	end
	return -1;
end

function ContainerFrame_GetOpenFrame()
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local frame = _G["ContainerFrame"..i];
		if ( not frame:IsShown() ) then
			return frame;
		end
		-- If all frames open return the last frame
		if ( i == NUM_CONTAINER_FRAMES ) then
			frame:Hide();
			return frame;
		end
	end
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

function ContainerFrame_CloseTutorial(ownerFrame)
	if ownerFrame.helpTipSystem then
		HelpTip:HideAllSystem(ownerFrame.helpTipSystem);
		ownerFrame.helpTipSystem = nil;
	end
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
	local containerFrame = itemButton:GetParent();
	return C_ItemUpgrade.CanUpgradeItem(ItemLocation:CreateFromBagAndSlot(containerFrame:GetID(), itemButton:GetID()));
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
			ContainerFrame_ShowTutorialForItemButton(itemButton, tutorialInfo.tutorialText, tutorialFlag)
			return true;
		end
	end

	return false;
end

function ContainerFrame_UpdateItemUpgradeIcons(frame)
	local id = frame:GetID();
	local name = frame:GetName();
	local itemButton;
	for i=1, frame.size, 1 do
		itemButton = _G[name.."Item"..i];
		ContainerFrameItemButton_UpdateItemUpgradeIcon(itemButton);
	end
end

function ContainerFrame_Update(self)
	local id = self:GetID();
	local name = self:GetName();
	local itemButton;
	local texture, itemCount, locked, quality, readable, itemLink, isFiltered, noValue, itemID, isBound, _;
	local isQuestItem, questId, isActive, questTexture;
	local battlepayItemTexture, newItemTexture, flash, newItemAnim;
	local tooltipOwner = GameTooltip:GetOwner();
	local baseSize = GetContainerNumSlots(id);	
	self.FilterIcon:Hide();
	if ( id ~= 0 and not IsInventoryItemProfessionBag("player", ContainerIDToInventoryID(id)) ) then
		for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
			local active = false;
			if ( id > NUM_BAG_SLOTS ) then
				active = GetBankBagSlotFlag(id - NUM_BAG_SLOTS, i);
			else
				active = GetBagSlotFlag(id, i);
			end
			if ( active ) then
				self.FilterIcon.Icon:SetAtlas(BAG_FILTER_ICONS[i], true);
				self.FilterIcon:Show();
				break;
			end
		end
	end

	--Update Searchbox and sort button
	if ( id == 0 ) then
		BagItemSearchBox:SetParent(self);
		BagItemSearchBox:SetPoint("TOPLEFT", self, "TOPLEFT", 54, -37);
		BagItemSearchBox.anchorBag = self;
		BagItemSearchBox:Show();
		BagItemAutoSortButton:SetParent(self);
		BagItemAutoSortButton:SetPoint("TOPRIGHT", self, "TOPRIGHT", -9, -34);
		BagItemAutoSortButton:Show();
	elseif ( BagItemSearchBox.anchorBag == self ) then
		BagItemSearchBox:ClearAllPoints();
		BagItemSearchBox:Hide();
		BagItemSearchBox.anchorBag = nil;
		BagItemAutoSortButton:ClearAllPoints();
		BagItemAutoSortButton:Hide();
	end

	ContainerFrame_CloseTutorial(self);

	local shouldDoTutorialChecks = ContainerFrame_ShouldDoTutorialChecks();

	for i=1, self.size, 1 do
		itemButton = _G[name.."Item"..i];
		
		texture, itemCount, locked, quality, readable, _, itemLink, isFiltered, noValue, itemID, isBound = GetContainerItemInfo(id, itemButton:GetID());
		isQuestItem, questId, isActive = GetContainerItemQuestInfo(id, itemButton:GetID());
		
		SetItemButtonTexture(itemButton, texture);

		local doNotSuppressOverlays = false;
		SetItemButtonQuality(itemButton, quality, itemLink, doNotSuppressOverlays, isBound);

		SetItemButtonCount(itemButton, itemCount);
		SetItemButtonDesaturated(itemButton, locked);
		
		ContainerFrameItemButton_SetForceExtended(itemButton, itemButton:GetID() > baseSize);

		questTexture = _G[name.."Item"..i.."IconQuestTexture"];
		if ( questId and not isActive ) then
			questTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG);
			questTexture:Show();
		elseif ( questId or isQuestItem ) then
			questTexture:SetTexture(TEXTURE_ITEM_QUEST_BORDER);
			questTexture:Show();		
		else
			questTexture:Hide();
		end
		
		local isNewItem = C_NewItems.IsNewItem(id, itemButton:GetID());
		local isBattlePayItem = IsBattlePayItem(id, itemButton:GetID());

		battlepayItemTexture = _G[name.."Item"..i].BattlepayItemTexture;
		newItemTexture = _G[name.."Item"..i].NewItemTexture;
		flash = _G[name.."Item"..i].flashAnim;
		newItemAnim = _G[name.."Item"..i].newitemglowAnim;

		if ( isNewItem ) then
			if (isBattlePayItem) then
				newItemTexture:Hide();
				battlepayItemTexture:Show();
			else
				if (quality and NEW_ITEM_ATLAS_BY_QUALITY[quality]) then
					newItemTexture:SetAtlas(NEW_ITEM_ATLAS_BY_QUALITY[quality]);
				else
					newItemTexture:SetAtlas("bags-glow-white");
				end
				battlepayItemTexture:Hide();
				newItemTexture:Show();
			end
			if (not flash:IsPlaying() and not newItemAnim:IsPlaying()) then
				flash:Play();
				newItemAnim:Play();
			end
		else
			battlepayItemTexture:Hide();
			newItemTexture:Hide();
			if (flash:IsPlaying() or newItemAnim:IsPlaying()) then
				flash:Stop();
				newItemAnim:Stop();
			end
		end

		itemButton.JunkIcon:Hide();
		
		local itemLocation = ItemLocation:CreateFromBagAndSlot(self:GetID(), itemButton:GetID());
		if C_Item.DoesItemExist(itemLocation) then
			local isJunk = quality == Enum.ItemQuality.Poor and not noValue and MerchantFrame:IsShown();
			itemButton.JunkIcon:SetShown(isJunk);
		end
		
		itemButton:UpdateItemContextMatching();
		
		ContainerFrameItemButton_UpdateItemUpgradeIcon(itemButton);

		if ( texture ) then
			ContainerFrame_UpdateCooldown(id, itemButton);
			itemButton.hasItem = 1;
		else
			_G[name.."Item"..i.."Cooldown"]:Hide();
			itemButton.hasItem = nil;
		end
		itemButton.readable = readable;
		
		if ( itemButton == tooltipOwner ) then
			if (GetContainerItemInfo(self:GetID(), itemButton:GetID())) then
				itemButton.UpdateTooltip(itemButton);
			else
				GameTooltip:Hide();
			end
		end
		
		itemButton:SetMatchesSearch(not isFiltered);
		if ( not isFiltered ) then
			if shouldDoTutorialChecks then
				if ContainerFrame_CheckItemButtonForTutorials(itemButton, itemID) then
					shouldDoTutorialChecks = false;
				end
			end
		end
	end

	-- authenticator slots helpTip
	if id == 0 and IsAccountSecured() and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_BAG_SLOTS_AUTHENTICATOR) and not ContainerFrame_IsTutorialShown() then
		itemButton = _G[name.."Item"..4];
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

	local bagButton = ContainerFrame_GetBagButton(self);
	bagButton:UpdateItemContextMatching();
end

function ContainerFrame_UpdateAll()
	for i = 1, NUM_CONTAINER_FRAMES, 1 do
		local frame = _G["ContainerFrame"..i];
		if ( frame:IsShown() ) then
			ContainerFrame_Update(frame);
		end
	end
	
	if BankFrame:IsShown() then
		BankFrame_UpdateItems(BankFrame);
	end
end

function ContainerFrame_FindItemLocationUnderCursor()
	local mouseFocus = GetMouseFocus();
	if mouseFocus then
		for containerIndex = 1, NUM_CONTAINER_FRAMES, 1 do
			local container = _G["ContainerFrame"..containerIndex];
			if container and container.size and container:IsShown() and container:IsMouseOver() then
				local name = container:GetName().."Item";
				for itemIndex = 1, container.size, 1 do
					local item = _G[name..itemIndex];
					if item and mouseFocus == item then
						return ItemLocation:CreateFromBagAndSlot(container:GetID(), item:GetID())
					end
				end
			end
		end
	end
	return nil;
end

function ContainerFrame_UpdateSearchResults(frame)
	local id = frame:GetID();
	local name = frame:GetName().."Item";
	local itemButton;
	local _, isFiltered;
	
	for i=1, frame.size, 1 do
		itemButton = _G[name..i] or frame["Item"..i];
		_, _, _, _, _, _, _, isFiltered = GetContainerItemInfo(id, itemButton:GetID());
		itemButton:SetMatchesSearch(not isFiltered);
	end
end

function ContainerFrame_UpdateLocked(frame)
	local id = frame:GetID();
	local name = frame:GetName();
	local itemButton;
	local _, locked;
	for i=1, frame.size, 1 do
		itemButton = _G[name.."Item"..i];
		_, _, locked = GetContainerItemInfo(id, itemButton:GetID());
		SetItemButtonDesaturated(itemButton, locked);
	end
end

function ContainerFrame_UpdateLockedItem(frame, slot)
	local index = frame.size + 1 - slot;
	local itemButton = _G[frame:GetName().."Item"..index];
	local _, _, locked = GetContainerItemInfo(frame:GetID(), itemButton:GetID());
	SetItemButtonDesaturated(itemButton, locked);
end

function ContainerFrame_UpdateCooldowns(frame)
	local id = frame:GetID();
	local name = frame:GetName();
	for i=1, frame.size, 1 do
		local itemButton = _G[name.."Item"..i];
		if ( GetContainerItemInfo(id, itemButton:GetID()) ) then
			ContainerFrame_UpdateCooldown(id, itemButton);
		else
			_G[name.."Item"..i.."Cooldown"]:Hide();
		end
	end
end

function ContainerFrame_UpdateCooldown(container, button)
	local cooldown = _G[button:GetName().."Cooldown"];
	local start, duration, enable = GetContainerItemCooldown(container, button:GetID());
	CooldownFrame_Set(cooldown, start, duration, enable);
	if ( duration > 0 and enable == 0 ) then
		SetItemButtonTextureVertexColor(button, 0.4, 0.4, 0.4);
	else
		SetItemButtonTextureVertexColor(button, 1, 1, 1);
	end
end

function ContainerFrame_GenerateFrame(frame, size, id)
	frame.size = size;
	local name = frame:GetName();
	local bgTextureTop = _G[name.."BackgroundTop"];
	local bgTextureMiddle = _G[name.."BackgroundMiddle1"];
	local bgTextureMiddle2 = _G[name.."BackgroundMiddle2"];
	local bgTextureBottom = _G[name.."BackgroundBottom"];
	local bgTexture1Slot = _G[name.."Background1Slot"];
	local columns = NUM_CONTAINER_COLUMNS;
	local rows = ceil(size / columns);
	local backpackFirstButtonOffset = FIRST_BACKPACK_BUTTON_OFFSET_BASE;
	local secured = IsAccountSecured();

	-- if id = 0 then its the backpack
	if ( id == 0 ) then
		EventRegistry:TriggerEvent("ContainerFrame.OpenBackpack");

		bgTexture1Slot:Hide();

		local extended = size > BACKPACK_BASE_SIZE;
		local extraRows = 0;

		bgTextureTop:SetTexture("Interface\\ContainerFrame\\UI-BackpackBackground");
		if (extended) then
			extraRows = math.ceil((size - BACKPACK_BASE_SIZE) / columns);
			bgTextureTop:SetHeight(BACKPACK_EXTENDED_TOPHEIGHT);
			bgTextureTop:SetTexCoord(0, 1, 0, BACKPACK_EXTENDED_TOPHEIGHT / BACKPACK_DEFAULT_TOPHEIGHT);
			backpackFirstButtonOffset = backpackFirstButtonOffset - (ROW_HEIGHT * extraRows);	
		else
			bgTextureTop:SetHeight(BACKPACK_DEFAULT_TOPHEIGHT);
			bgTextureTop:SetTexCoord(0, 1, 0, 1);
		end
		bgTextureTop:Show();
		bgTextureBottom:Hide();

		_G[name.."MoneyFrame"]:Show();
		_G[name.."MoneyFrame"]:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, BACKPACK_MONEY_OFFSET_DEFAULT - (ROW_HEIGHT * extraRows));
		_G[name.."AddSlotsButton"]:SetShown(not secured);

		-- Hide unused textures
		for i=1, MAX_MIDDLE_TEXTURES do
			_G[name.."BackgroundMiddle"..i]:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components");
			_G[name.."BackgroundMiddle"..i]:Hide();
		end

		local middleBgHeight = 0;

		if (extended) then
			local remainingRows = extraRows;

			-- Calculate the number of background textures we're going to need
			bgTextureCount = ceil(remainingRows/ROWS_IN_BG_TEXTURE);
			
			-- Try to cycle all the middle bg textures
			for i=1, bgTextureCount do
				bgTextureMiddle = _G[name.."BackgroundMiddle"..i];
				if ( remainingRows > ROWS_IN_BG_TEXTURE ) then
					-- If more rows left to draw than can fit in a texture then draw the max possible
					height = ROWS_IN_BG_TEXTURE * ROW_HEIGHT;
					remainingRows = remainingRows - ROWS_IN_BG_TEXTURE;
				else
					height = remainingRows * ROW_HEIGHT;
				end

				middleBgHeight = middleBgHeight + height;
				bgTextureMiddle:SetHeight(height);
				bgTextureMiddle:SetTexCoord(0, 1, BG_TEXTURE_MIDDLE_START / BG_TEXTURE_HEIGHT, ((BG_TEXTURE_MIDDLE_START + height) / BG_TEXTURE_HEIGHT) );
				bgTextureMiddle:Show();
			end
			
			-- Position and setup bottom texture
			bgTextureBottom:SetPoint("TOP", bgTextureMiddle:GetName(), "BOTTOM", 0, 0);
			bgTextureBottom:SetTexture("Interface\\ContainerFrame\\UI-BackpackBackground");
			bgTextureBottom:SetHeight(BACKPACK_DEFAULT_TOPHEIGHT - BACKPACK_EXTENDED_TOPHEIGHT);
			bgTextureBottom:SetTexCoord(0, 1, BACKPACK_EXTENDED_TOPHEIGHT / BACKPACK_DEFAULT_TOPHEIGHT, 1);
			bgTextureBottom:Show();
		end

		BACKPACK_HEIGHT = BACKPACK_BASE_HEIGHT + middleBgHeight;
		frame:SetHeight(BACKPACK_HEIGHT);
		ManageBackpackTokenFrame(frame);
	else
		bgTextureBottom:SetHeight(CONTAINER_BOTTOM_TEXTURE_DEFAULT_HEIGHT);
		bgTextureBottom:SetTexCoord(0, 1, CONTAINER_BOTTOM_TEXTURE_DEFAULT_START / BG_TEXTURE_HEIGHT, CONTAINER_BOTTOM_TEXTURE_DEFAULT_END / BG_TEXTURE_HEIGHT);
		if (size == 1) then
			-- Halloween gag gift
			bgTexture1Slot:Show();
			bgTextureTop:Hide();
			bgTextureMiddle:Hide();
			bgTextureMiddle2:Hide();
			bgTextureBottom:Hide();
			_G[name.."MoneyFrame"]:Hide();
			_G[name.."AddSlotsButton"]:Hide();
		else
			EventRegistry:TriggerEvent("ContainerFrame.OpenBag");

			bgTexture1Slot:Hide();
			bgTextureTop:Show();
	
			-- Not the backpack
			-- Set whether or not its a bank bag
			local bagTextureSuffix = "";
			if ( id > NUM_BAG_FRAMES ) then
				bagTextureSuffix = "-Bank";
			elseif ( id == KEYRING_CONTAINER ) then
				bagTextureSuffix = "-Keyring";
			end
			
			-- Set textures
			bgTextureTop:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components"..bagTextureSuffix);
			for i=1, MAX_MIDDLE_TEXTURES do
				_G[name.."BackgroundMiddle"..i]:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components"..bagTextureSuffix);
				_G[name.."BackgroundMiddle"..i]:Hide();
			end
			bgTextureBottom:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components"..bagTextureSuffix);
			-- Hide the moneyframe since its not the backpack
			_G[name.."MoneyFrame"]:Hide();	
			_G[name.."AddSlotsButton"]:Hide();
						
			local bgTextureCount, height;
			-- Subtract one, since the top texture contains one row already
			local remainingRows = rows-1;

			-- See if the bag needs the texture with two slots at the top
			local isPlusTwoBag;
			if ( mod(size,columns) == 2 ) then
				isPlusTwoBag = 1;
			end

			-- Bag background display stuff
			if ( isPlusTwoBag ) then
				bgTextureTop:SetTexCoord(0, 1, BG_TEXTURE_TOP_PLUS_TWO_START / BG_TEXTURE_HEIGHT, BG_TEXTURE_TOP_PLUS_TWO_END / BG_TEXTURE_HEIGHT);
				bgTextureTop:SetHeight(BG_TEXTURE_TOP_PLUS_TWO_END - BG_TEXTURE_TOP_PLUS_TWO_START);
			else
				if ( rows == 1 ) then
					-- If only one row chop off the bottom of the texture
					bgTextureTop:SetTexCoord(0, 1, BG_TEXTURE_TOP_START / BG_TEXTURE_HEIGHT, BG_TEXTURE_TOP_ONE_ROW_END / BG_TEXTURE_HEIGHT);
					bgTextureTop:SetHeight(BG_TEXTURE_TOP_ONE_ROW_END - BG_TEXTURE_TOP_START);
				else
					bgTextureTop:SetTexCoord(0, 1, BG_TEXTURE_TOP_START / BG_TEXTURE_HEIGHT, BG_TEXTURE_TOP_END / BG_TEXTURE_HEIGHT);
					bgTextureTop:SetHeight(BG_TEXTURE_TOP_END - BG_TEXTURE_TOP_START);
				end
			end
			-- Calculate the number of background textures we're going to need
			bgTextureCount = ceil(remainingRows/ROWS_IN_BG_TEXTURE);
			
			local middleBgHeight = 0;
			-- If one row only special case
			if ( rows == 1 ) then
				bgTextureBottom:SetPoint("TOP", bgTextureMiddle:GetName(), "TOP", 0, 0);
				bgTextureBottom:Show();
				-- Hide middle bg textures
				for i=1, MAX_MIDDLE_TEXTURES do
					_G[name.."BackgroundMiddle"..i]:Hide();
				end
			else
				-- Try to cycle all the middle bg textures
				for i=1, bgTextureCount do
					bgTextureMiddle = _G[name.."BackgroundMiddle"..i];
					if ( remainingRows > ROWS_IN_BG_TEXTURE ) then
						-- If more rows left to draw than can fit in a texture then draw the max possible
						height = ROWS_IN_BG_TEXTURE * ROW_HEIGHT;
						remainingRows = remainingRows - ROWS_IN_BG_TEXTURE;
					else
						height = remainingRows * ROW_HEIGHT;
						remainingRows = 0;
					end

					if remainingRows == 0 or i == bgTextureCount then
						-- For non-backpack bags, the bottom texture has to contain a small slice of the bottom row of items.
						-- So if this middle texture is the bottom one, subtract out that slice from the middle texture's height
						height = height - CONTAINER_BOTTOM_TEXTURE_DEFAULT_ROW_HEIGHT;
					end

					middleBgHeight = middleBgHeight + height;
					bgTextureMiddle:SetHeight(height);
					bgTextureMiddle:SetTexCoord(0, 1, BG_TEXTURE_MIDDLE_START / BG_TEXTURE_HEIGHT, ((BG_TEXTURE_MIDDLE_START + height) / BG_TEXTURE_HEIGHT) );
					bgTextureMiddle:Show();
				end
				-- Position bottom texture
				bgTextureBottom:SetPoint("TOP", bgTextureMiddle:GetName(), "BOTTOM", 0, 0);
				bgTextureBottom:Show();
			end
				
			-- Set the frame height
			frame:SetHeight(bgTextureTop:GetHeight()+bgTextureBottom:GetHeight()+middleBgHeight);	
		end
	end

	if (size == 1) then
		-- Halloween gag gift
		frame:SetHeight(70);	
		frame:SetWidth(99);
		_G[frame:GetName().."Name"]:SetText("");
		SetBagPortraitTexture(_G[frame:GetName().."Portrait"], id);
		local itemButton = _G[name.."Item1"];
		itemButton:SetID(1);
		itemButton:SetPoint("BOTTOMRIGHT", name, "BOTTOMRIGHT", -10, 5);
		itemButton:Show();
	else
		frame:SetWidth(CONTAINER_WIDTH);

		--Special case code for keyrings
		if ( id == KEYRING_CONTAINER ) then
			_G[frame:GetName().."Name"]:SetText(KEYRING);
			SetPortraitToTexture(frame:GetName().."Portrait", "Interface\\ContainerFrame\\KeyRing-Bag-Icon");
		else
			_G[frame:GetName().."Name"]:SetText(GetBagName(id));
			SetBagPortraitTexture(_G[frame:GetName().."Portrait"], id);
		end

		local baseSize = GetContainerNumSlots(id);
		local index, itemButton;
		for i=1, size, 1 do
			index = size - i + 1;
			itemButton = _G[name.."Item"..i];
			itemButton:SetID(index);
			-- Set first button
			if ( i == 1 ) then
				-- Anchor the first item differently if its the backpack frame
				if ( id == 0 ) then
					itemButton:SetPoint("BOTTOMRIGHT", name, "TOPRIGHT", -12, backpackFirstButtonOffset);
				else
					itemButton:SetPoint("BOTTOMRIGHT", name, "BOTTOMRIGHT", -12, 9);
				end
			else
				if ( mod((i-1), columns) == 0 ) then
					itemButton.shouldAnimateStatic = true;
					itemButton:SetPoint("BOTTOMRIGHT", name.."Item"..(i - columns), "TOPRIGHT", 0, 4);	
				else
					itemButton:SetPoint("BOTTOMRIGHT", name.."Item"..(i - 1), "BOTTOMLEFT", -5, 0);	
				end
			end
			
			itemButton:Show();
		end
	end
	for i=size + 1, MAX_CONTAINER_ITEMS, 1 do
		_G[name.."Item"..i]:Hide();
	end
	
	frame:SetID(id);
	_G[frame:GetName().."PortraitButton"]:SetID(id);

	-- Add the bag to the baglist
	frame:Show();
	frame:Raise();
end

function UpdateContainerFrameAnchors()
	local containerFrameOffsetX = math.max(CONTAINER_OFFSET_X, MINIMUM_CONTAINER_OFFSET_X);
	local frame, xOffset, yOffset, screenHeight, freeScreenHeight, leftMostPoint, column;
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
		for index, frameName in ipairs(ContainerFrame1.bags) do
			frameHeight = _G[frameName]:GetHeight();
			if ( freeScreenHeight < frameHeight ) then
				-- Start a new column
				column = column + 1;
				leftMostPoint = screenWidth - ( column * CONTAINER_WIDTH * containerScale ) - xOffset;
				freeScreenHeight = screenHeight - yOffset;
			end
			freeScreenHeight = freeScreenHeight - frameHeight - VISIBLE_CONTAINER_SPACING;
		end
		if ( leftMostPoint < leftLimit ) then
			containerScale = containerScale - 0.01;
		else
			break;
		end
	end
	
	if ( containerScale < CONTAINER_SCALE ) then
		containerScale = CONTAINER_SCALE;
	end
	
	screenHeight = GetScreenHeight() / containerScale;
	-- Adjust the start anchor for bags depending on the multibars
	xOffset = containerFrameOffsetX / containerScale;
	yOffset = CONTAINER_OFFSET_Y / containerScale;
	-- freeScreenHeight determines when to start a new column of bags
	freeScreenHeight = screenHeight - yOffset;
	column = 0;
	for index, frameName in ipairs(ContainerFrame1.bags) do
		frame = _G[frameName];
		frame:SetScale(containerScale);
		if ( index == 1 ) then
			-- First bag
			frame:SetPoint("BOTTOMRIGHT", frame:GetParent(), "BOTTOMRIGHT", -xOffset, yOffset );
		elseif ( freeScreenHeight < frame:GetHeight() ) then
			-- Start a new column
			column = column + 1;
			freeScreenHeight = screenHeight - yOffset;
			frame:SetPoint("BOTTOMRIGHT", frame:GetParent(), "BOTTOMRIGHT", -(column * CONTAINER_WIDTH) - xOffset, yOffset );
		else
			-- Anchor to the previous bag
			frame:SetPoint("BOTTOMRIGHT", ContainerFrame1.bags[index - 1], "TOPRIGHT", 0, CONTAINER_SPACING);	
		end
		freeScreenHeight = freeScreenHeight - frame:GetHeight() - VISIBLE_CONTAINER_SPACING;
	end
end

function ContainerFrameItemButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterForDrag("LeftButton");

	self.UpdateTooltip = ContainerFrameItemButton_OnUpdate;
	self.timeSinceUpgradeCheck = 0;
	self.GetDebugReportInfo = ContainerFrameItemButton_GetDebugReportInfo;
end

function ContainerFrameItemButton_GetDebugReportInfo(self)
	local texture, itemCount, locked, quality, readable, _, itemLink, isFiltered, noValue, itemID, isBound = GetContainerItemInfo(self:GetParent():GetID(), self:GetID());
	return { debugType = "ContainerItem", itemLink = itemLink, };
end

function ContainerFrameItemButton_UpdateItemUpgradeIcon(self)
	self.timeSinceUpgradeCheck = 0;
	
	local itemIsUpgrade = IsContainerItemAnUpgrade(self:GetParent():GetID(), self:GetID());
	if ( itemIsUpgrade == nil and not self.isExtended) then -- nil means not all the data was available to determine if this is an upgrade.
		self.UpgradeIcon:SetShown(false);
		self:SetScript("OnUpdate", ContainerFrameItemButton_TryUpdateItemUpgradeIcon);
	elseif (not self.isExtended) then
		self.UpgradeIcon:SetShown(itemIsUpgrade);
		self:SetScript("OnUpdate", nil);
	end
end

local ITEM_UPGRADE_CHECK_TIME = 0.5;
function ContainerFrameItemButton_TryUpdateItemUpgradeIcon(self, elapsed)
	self.timeSinceUpgradeCheck = self.timeSinceUpgradeCheck + elapsed;
	if ( self.timeSinceUpgradeCheck >= ITEM_UPGRADE_CHECK_TIME ) then
		ContainerFrameItemButton_UpdateItemUpgradeIcon(self);
	end
end

function ContainerFrameItemButton_SetForceExtended(itemButton, extended)
	if (extended) then
		if not itemButton.extendedFrame then
			itemButton.extendedFrame = CreateFrame("FRAME", nil, itemButton, "ContainerFrameExtendedItemButtonTemplate");
			itemButton.extendedFrame:SetAllPoints(itemButton);
		end
		itemButton.extendedFrame:Show();
		itemButton:EnableMouse(false);
		itemButton.isExtended = true;
	else
		if itemButton.extendedFrame then
			itemButton.extendedFrame:Hide();
		end
		itemButton:EnableMouse(true);
		itemButton.isExtended = false;
	end
end

function ContainerFrameItemButton_OnDrag (self)
	ContainerFrameItemButton_OnClick(self, "LeftButton");
end

function ContainerFrame_GetExtendedPriceString(itemButton, isEquipped, quantity)
	quantity = (quantity or 1);
	local slot = itemButton:GetID();
	local bag = itemButton:GetParent():GetID();

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
			UseContainerItem(self:GetParent():GetID(), self:GetID());
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
				PickupContainerItem(self:GetParent():GetID(), self:GetID());
			end
		else
			PickupContainerItem(self:GetParent():GetID(), self:GetID());
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
			local itemLocation = ItemLocation:CreateFromBagAndSlot(self:GetParent():GetID(), self:GetID());
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
				local itemID = select(10, GetContainerItemInfo(self:GetParent():GetID(), self:GetID()));
				if itemID then
					if IsArtifactRelicItem(itemID) then
						if C_ArtifactUI.CanApplyArtifactRelic(itemID, false) then
							SocketContainerItem(self:GetParent():GetID(), self:GetID());
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
		UseContainerItem(self:GetParent():GetID(), self:GetID(), nil, BankFrame:IsShown() and (BankFrame.selectedTab == 2));
		StackSplitFrame:Hide();
	end
end

local function SplitStack(button, split)
	SplitContainerItem(button:GetParent():GetID(), button:GetID(), split);
end

function ContainerFrameItemButton_OnModifiedClick(self, button)
	if ( IsModifiedClick("EXPANDITEM") ) then
		local itemLocation = ItemLocation:CreateFromBagAndSlot(self:GetParent():GetID(), self:GetID());
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

			if SocketContainerItem(self:GetParent():GetID(), self:GetID()) then
				return;
			end
		end
	end

	if ( HandleModifiedItemClick(GetContainerItemLink(self:GetParent():GetID(), self:GetID())) ) then
		return;
	end
	if ( not CursorHasItem() and IsModifiedClick("SPLITSTACK") ) then
		local texture, itemCount, locked = GetContainerItemInfo(self:GetParent():GetID(), self:GetID());
		if ( not locked and itemCount and itemCount > 1) then
			self.SplitStack = SplitStack;
			StackSplitFrame:OpenStackSplitFrame(itemCount, self, "BOTTOMRIGHT", "TOPRIGHT");
		end
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

function ContainerFrameItemButton_OnUpdate(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE");

	-- Keyring specific code
	if ( self:GetParent():GetID() == KEYRING_CONTAINER ) then
		ContainerFrameItemButton_CalculateItemTooltipAnchors(self, GameTooltip);
		GameTooltip:SetInventoryItem("player", KeyRingButtonIDToInvSlotID(self:GetID()));
		CursorUpdate(self);
		return;
	end

	C_NewItems.RemoveNewItem(self:GetParent():GetID(), self:GetID());

	local newItemTexture = self.NewItemTexture;
	local battlepayItemTexture = self.BattlepayItemTexture;
	local flash = self.flashAnim;
	local newItemGlowAnim = self.newitemglowAnim;
	
	newItemTexture:Hide();
	battlepayItemTexture:Hide();
	
	if ( flash:IsPlaying() or newItemGlowAnim:IsPlaying() ) then
		flash:Stop();
		newItemGlowAnim:Stop();
	end
	
	local showSell = nil;
	local hasCooldown, repairCost, speciesID, level, breedQuality, maxHealth, power, speed, name = GameTooltip:SetBagItem(self:GetParent():GetID(), self:GetID());
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
		if ( IsModifiedClick("DRESSUP") and self.hasItem ) then
			ShowInspectCursor();
		elseif ( showSell ) then
			ShowContainerSellCursor(self:GetParent():GetID(),self:GetID());
		elseif ( self.readable ) then
			ShowInspectCursor();
		else
			ResetCursor();
		end
	end

	if ( not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_MOUNT_EQUIPMENT_SLOT_FRAME) ) then
		local itemLocation = ItemLocation:CreateFromBagAndSlot(self:GetParent():GetID(), self:GetID());
		if ( itemLocation and itemLocation:IsValid() and C_PlayerInfo.CanPlayerUseMountEquipment() and (not CollectionsJournal or not CollectionsJournal:IsShown()) ) then
			local tabIndex = 1;
			CollectionsMicroButton_SetAlertShown(tabIndex);
		end
	end
end

function ContainerFrameItemButton_OnEnter(self)
	ContainerFrameItemButton_OnUpdate(self);
	
	if ( ArtifactFrame and self.hasItem ) then
		ArtifactFrame:OnInventoryItemMouseEnter(self:GetParent():GetID(), self:GetID());
	end
end

function ContainerFrameItemButton_OnLeave(self)
	GameTooltip_Hide();
	if ( not SpellIsTargeting() ) then
		ResetCursor();
	end

	if ( ArtifactFrame ) then
		ArtifactFrame:OnInventoryItemMouseLeave(self:GetParent():GetID(), self:GetID());
	end
end

ContainerFrameItemButtonMixin = {};

function ContainerFrameItemButtonMixin:GetItemContextMatchResult()
	return ItemButtonUtil.GetItemContextMatchResultForItem(ItemLocation:CreateFromBagAndSlot(self:GetParent():GetID(), self:GetID()));
end

ContainerFramePortraitButtonMixin = {};

function ContainerFramePortraitButtonMixin:OnMouseDown()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	ToggleDropDownMenu(1, nil, self:GetParent().FilterDropDown, self, 0, 0);
end

function ContainerFramePortraitButtonMixin:OnEnter()
	self.Highlight:Show();
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	local waitingOnData = false;
	if ( self:GetID() == 0 ) then
		GameTooltip:SetText(BACKPACK_TOOLTIP, 1.0, 1.0, 1.0);
		if (GetBindingKey("TOGGLEBACKPACK")) then
			GameTooltip:AppendText(" "..NORMAL_FONT_COLOR_CODE.."("..GetBindingKey("TOGGLEBACKPACK")..")"..FONT_COLOR_CODE_CLOSE)
		end
	else
		local parent = self:GetParent();
		local id = parent:GetID();
		local link = GetInventoryItemLink("player", ContainerIDToInventoryID(id));
		local name, _, quality = GetItemInfo(link);
		if name and quality then
			local r, g, b = GetItemQualityColor(quality);
			GameTooltip:SetText(name, r, g, b);
		else
			GameTooltip:SetText(RETRIEVING_ITEM_INFO, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			waitingOnData = true;
		end

		if (not IsInventoryItemProfessionBag("player", ContainerIDToInventoryID(id))) then
			if (parent.localFlag and BAG_FILTER_LABELS[parent.localFlag]) then
				GameTooltip:AddLine(BAG_FILTER_ASSIGNED_TO:format(BAG_FILTER_LABELS[parent.localFlag]));
			elseif (not parent.localFlag) then
				for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
					local active = false;
					if ( self:GetID() > NUM_BAG_SLOTS ) then
						active = GetBankBagSlotFlag(id - NUM_BAG_SLOTS, i);
					else
						active = GetBagSlotFlag(id, i);
					end
					if ( active ) then
						GameTooltip:AddLine(BAG_FILTER_ASSIGNED_TO:format(BAG_FILTER_LABELS[i]));
						break;
					end
				end
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
	self.Highlight:Hide();
	GameTooltip_Hide();
end

function ToggleAllBags()
	if ( not UIParent:IsShown() ) then
		return;
	end

	local bagsOpen = 0;
	local totalBags = 1;
	if ( IsBagOpen(0) ) then
		bagsOpen = bagsOpen +1;
		CloseBackpack();
		EventRegistry:TriggerEvent("ContainerFrame.CloseBackpack");
	end

	local bagClosed = false;
	for i=1, NUM_BAG_FRAMES, 1 do
		if ( GetContainerNumSlots(i) > 0 ) then		
			totalBags = totalBags +1;
		end
		if ( IsBagOpen(i) ) then
			CloseBag(i);
			bagsOpen = bagsOpen +1;
			bagClosed = true;
		end
	end
	
	if bagClosed then
		EventRegistry:TriggerEvent("ContainerFrame.AllBagsClosed");
	end

	if (bagsOpen < totalBags) then
		ContainerFrame1.allBags = true;
		OpenBackpack();
		for i=1, NUM_BAG_FRAMES, 1 do
			OpenBag(i);
		end
		ContainerFrame1.allBags = false;

		EventRegistry:TriggerEvent("ContainerFrame.AllBagsOpened");
	elseif( BankFrame:IsShown() ) then
		bagsOpen = 0;
		totalBags = 0;
		for i=NUM_BAG_FRAMES+1, NUM_CONTAINER_FRAMES, 1 do
			if ( GetContainerNumSlots(i) > 0 ) then		
				totalBags = totalBags +1;
			end
			if ( IsBagOpen(i) ) then
				CloseBag(i);
				bagsOpen = bagsOpen +1;
			end
		end
		if (bagsOpen < totalBags) then
			ContainerFrame1.allBags = true;
			OpenBackpack();
			for i=1, NUM_CONTAINER_FRAMES, 1 do
				OpenBag(i);
			end
			ContainerFrame1.allBags = false;
		end
	end
end

function IsAnyBagOpen()
	for i = 0, NUM_BAG_FRAMES do
		if IsBagOpen(i) then
			return true;
		end
	end

	return false;
end

function OpenAllBagsMatchingContext(frame)
	local count = 0;
	for i = 0, NUM_BAG_FRAMES do
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

function OpenAllBags(frame, forceUpdate)
	if ( not UIParent:IsShown() ) then
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

	ContainerFrame1.allBags = true;
	OpenBackpack();
	for i=1, NUM_BAG_FRAMES, 1 do
		OpenBag(i);
	end
	ContainerFrame1.allBags = false;
end

function CloseAllBags(frame, forceUpdate)
	if ( frame and frame:GetName() ~= FRAME_THAT_OPENED_BAGS) then
		if ( forceUpdate ) then
			ContainerFrame_UpdateAll();
		end

		return;
	end

	FRAME_THAT_OPENED_BAGS = nil;
	CloseBackpack();
	for i=1, NUM_BAG_FRAMES, 1 do
		CloseBag(i);
	end
end

function GetBackpackFrame()
	local index = IsBagOpen(0);
	if ( index ) then
		return _G["ContainerFrame"..index];
	else
		return nil;
	end
end

-- Filters
BAG_FILTER_LABELS = {
	[LE_BAG_FILTER_FLAG_EQUIPMENT] = BAG_FILTER_EQUIPMENT,
	[LE_BAG_FILTER_FLAG_CONSUMABLES] = BAG_FILTER_CONSUMABLES,
	[LE_BAG_FILTER_FLAG_TRADE_GOODS] = BAG_FILTER_TRADE_GOODS,
	[LE_BAG_FILTER_FLAG_JUNK] = BAG_FILTER_JUNK,
};

BAG_FILTER_ICONS = {
	[LE_BAG_FILTER_FLAG_EQUIPMENT] = "bags-icon-equipment",
	[LE_BAG_FILTER_FLAG_CONSUMABLES] = "bags-icon-consumables",
	[LE_BAG_FILTER_FLAG_TRADE_GOODS] = "bags-icon-tradegoods",
};

function ContainerFrameFilterDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, ContainerFrameFilterDropDown_Initialize, "MENU");
end

function ContainerFrameFilterDropDown_Initialize(self, level)
	local frame = self:GetParent();
	local id = frame:GetID();
	
	if (id > NUM_BAG_SLOTS + NUM_BANKBAGSLOTS) then
		return;
	end

	local info = UIDropDownMenu_CreateInfo();	

	if (id > 0 and not IsInventoryItemProfessionBag("player", ContainerIDToInventoryID(id))) then -- The actual bank has ID -1, backpack has ID 0, we want to make sure we're looking at a regular or bank bag
		info.text = BAG_FILTER_ASSIGN_TO;
		info.isTitle = 1;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);

		info.isTitle = nil;
		info.notCheckable = nil;
		info.tooltipWhileDisabled = 1;
		info.tooltipOnButton = 1;

		for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
			if ( i ~= LE_BAG_FILTER_FLAG_JUNK ) then
				info.text = BAG_FILTER_LABELS[i];
				info.func = function(_, _, _, value)
					value = not value;
					if (id > NUM_BAG_SLOTS) then
						SetBankBagSlotFlag(id - NUM_BAG_SLOTS, i, value);
					else
						SetBagSlotFlag(id, i, value);
					end
					if (value) then
						frame.localFlag = i;
						frame.FilterIcon.Icon:SetAtlas(BAG_FILTER_ICONS[i]);
						frame.FilterIcon:Show();
					else
						frame.FilterIcon:Hide();
						frame.localFlag = -1;						
					end
				end;
				if (frame.localFlag) then
					info.checked = frame.localFlag == i;
				else
					if (id > NUM_BAG_SLOTS) then
						info.checked = GetBankBagSlotFlag(id - NUM_BAG_SLOTS, i);
					else
						info.checked = GetBagSlotFlag(id, i);
					end
				end
				info.disabled = nil;
				info.tooltipTitle = nil;
				UIDropDownMenu_AddButton(info);
			end
		end
	end

	info.text = BAG_FILTER_CLEANUP;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info);

	info.isTitle = nil;
	info.notCheckable = nil;
	info.isNotRadio = true;
	info.disabled = nil;

	info.text = BAG_FILTER_IGNORE;
	info.func = function(_, _, _, value)
		if (id == -1) then
			SetBankAutosortDisabled(not value);
		elseif (id == 0) then
			SetBackpackAutosortDisabled(not value);
		elseif (id > NUM_BAG_SLOTS) then
			SetBankBagSlotFlag(id - NUM_BAG_SLOTS, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP, not value);
		else
			SetBagSlotFlag(id, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP, not value);
		end
	end;
	if (id == -1) then
		info.checked = GetBankAutosortDisabled();
	elseif (id == 0) then
		info.checked = GetBackpackAutosortDisabled();
	elseif (id > NUM_BAG_SLOTS) then
		info.checked = GetBankBagSlotFlag(id - NUM_BAG_SLOTS, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP);
	else
		info.checked = GetBagSlotFlag(id, LE_BAG_FILTER_FLAG_IGNORE_CLEANUP);
	end
	UIDropDownMenu_AddButton(info);
end

function ContainerFrameUtil_IteratePlayerInventory(callback)
	-- Only includes the backpack and primary 4 bag slots.
	for bag = 0, NUM_BAG_FRAMES do
		for slot = 1, MAX_CONTAINER_ITEMS do
			local bagItem = ItemLocation:CreateFromBagAndSlot(bag, slot);
			if C_Item.DoesItemExist(bagItem) then
				callback(bagItem);
			end

		end
	end
end

function ContainerFrameUtil_GetItemButtonAndContainer(bag, slot)
	local containerFrame = _G["ContainerFrame"..(bag + 1)];
	return _G[containerFrame:GetName().."Item"..slot], containerFrame;
end

function ContainerFrameUtil_FindFirstItemButtonAndItemLocation(predicate)
	for bag = 0, NUM_BAG_FRAMES do
		for slot = MAX_CONTAINER_ITEMS, 1, -1 do
			local itemButton, containerFrame = ContainerFrameUtil_GetItemButtonAndContainer(bag, slot);
			local itemLocation = ItemLocation:CreateFromBagAndSlot(containerFrame:GetID(), itemButton:GetID());
			if itemLocation:IsValid() and predicate(itemLocation) then
				return itemButton, itemLocation;
			end
		end
	end
	return nil;
end