NUM_CONTAINER_FRAMES = 13;
NUM_BAG_FRAMES = 4;
MAX_CONTAINER_ITEMS = 36;
NUM_CONTAINER_COLUMNS = 4;
ROWS_IN_BG_TEXTURE = 6;
MAX_BG_TEXTURES = 2;
BG_TEXTURE_MIDDLE_START = 215;
BG_TEXTURE_HEIGHT = 512;
CONTAINER_WIDTH = 192;
CONTAINER_SPACING = 0;
VISIBLE_CONTAINER_SPACING = 3;
CONTAINER_OFFSET_Y = 70;
CONTAINER_OFFSET_X = -4;
CONTAINER_SCALE = 0.75;
BACKPACK_MONEY_OFFSET_DEFAULT = -215;
BACKPACK_MONEY_HEIGHT_OFFSET_PER_EXTRA_ROW = 41;
BACKPACK_BASE_HEIGHT = 240;
BACKPACK_HEIGHT_OFFSET_PER_EXTRA_ROW = 41;
BACKPACK_DEFAULT_TOPHEIGHT = 255;
BACKPACK_EXTENDED_TOPHEIGHT = 210;
BACKPACK_BASE_SIZE = 16;
FIRST_BACKPACK_BUTTON_OFFSET_BASE = -208;
FIRST_BACKPACK_BUTTON_OFFSET_PER_EXTRA_ROW = 41;
FRAME_THAT_OPENED_BAGS = nil;
CONTAINER_BOTTOM_TEXTURE_DEFAULT_HEIGHT = 10;
CONTAINER_BOTTOM_TEXTURE_DEFAULT_TOP_COORD = 0.330078125;
CONTAINER_BOTTOM_TEXTURE_DEFAULT_BOTTOM_COORD = 0.349609375;

TUTORIAL_BAG_SLOTS_AUTHENTICATOR = 51;

ADVERTISE_SLOTS_LEVEL = 20; -- Don't show the "Add Slots" button below this level

function ContainerFrame_OnLoad(self)
	self:RegisterEvent("BAG_OPEN");
	self:RegisterEvent("BAG_CLOSED");
	self:RegisterEvent("QUEST_ACCEPTED");
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
	ContainerFrame1.bagsShown = 0;
	ContainerFrame1.bags = {};
	ContainerFrame1.forceExtended = false;
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
--[[
	elseif ( event == "UNIT_INVENTORY_CHANGED" or event == "PLAYER_SPECIALIZATION_CHANGED" ) then
		ContainerFrame_UpdateItemUpgradeIcons(self);
--]]
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
	if (id == 0 and ContainerFrame1.forceExtended) then
		num = num + 4;
	end
	return num;
end

function ContainerFrame_SetBackpackForceExtended(forceExtended)
	ContainerFrame1.forceExtended = forceExtended;
	OpenBag(0, true);
end

function ToggleBag(id)
	if ( IsOptionFrameOpen() ) then
		return;
	end
	
	local size = 0;
	if (id == KEYRING_CONTAINER ) then
		size = GetKeyRingSize();
	else
		size = ContainerFrame_GetContainerNumSlots(id);
	end

	if ( size > 0 or id == KEYRING_CONTAINER ) then
		local containerShowing;
		for i=1, NUM_CONTAINER_FRAMES, 1 do
			local frame = _G["ContainerFrame"..i];
			if ( frame:IsShown() and frame:GetID() == id ) then
				containerShowing = i;
				frame:Hide();
			end
		end
		if ( not containerShowing ) then
			if ( CanAutoSetGamePadCursorControl(true) ) then
				SetGamePadCursorControl(true);
			end

			ContainerFrame_GenerateFrame(ContainerFrame_GetOpenFrame(), size, id);
			-- Stop keyring button pulse
			if (id == KEYRING_CONTAINER) then 
				SetButtonPulse(KeyRingButton, 0, 1);
			end
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
			end
			-- Hide the token bar if closing the backpack
			if ( BackpackTokenFrame ) then
				BackpackTokenFrame:Hide();
			end
		end
	else
		ToggleBag(0);
		-- If there are tokens watched then show the bar
		--[[if ( ManageBackpackTokenFrame ) then
			BackpackTokenFrame_Update();
			ManageBackpackTokenFrame();
		end]]
	end
end

function ContainerFrame_OnHide(self)
	self:UnregisterEvent("BAG_UPDATE");
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED");
	self:UnregisterEvent("ITEM_LOCK_CHANGED");
	self:UnregisterEvent("BAG_UPDATE_COOLDOWN");
	self:UnregisterEvent("DISPLAY_SIZE_CHANGED");
	self:UnregisterEvent("INVENTORY_SEARCH_UPDATE");
	self:UnregisterEvent("BAG_NEW_ITEMS_UPDATED");
	self:UnregisterEvent("BAG_SLOT_FLAGS_UPDATED");

	UpdateNewItemList(self);

	if ( self:GetID() == 0 ) then
		MainMenuBarBackpackButton:SetChecked(false);
	else
		local bagButton = _G["CharacterBag"..(self:GetID() - 1).."Slot"];
		if ( bagButton ) then
			bagButton:SetChecked(false);
		else
			-- If its a bank bag then update its highlight
			if ( self:GetID() > NUM_BAG_SLOTS ) then
				UpdateBagButtonHighlight(self:GetID() - NUM_BAG_SLOTS);
			end
		end
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
		if ( self:GetID() == 0 and BagHelpBox.wasShown ) then
			BagHelpBox.wasShown = nil;
		end
		if ( BagHelpBox:IsShown() and BagHelpBox.owner == self ) then
			BagHelpBox.owner = nil;
			BagHelpBox:Hide();
		end
		PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE);
	end
end

function ContainerFrame_OnShow(self)
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED");
	self:RegisterEvent("ITEM_LOCK_CHANGED");
	self:RegisterEvent("BAG_UPDATE_COOLDOWN");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("INVENTORY_SEARCH_UPDATE");
	self:RegisterEvent("BAG_NEW_ITEMS_UPDATED");
	self:RegisterEvent("BAG_SLOT_FLAGS_UPDATED");

	--self.FilterIcon:Hide();
	if ( self:GetID() == 0 ) then
		local shouldShow = true;
		if (FRAME_THAT_OPENED_BAGS ~= nil or Kiosk.IsEnabled()) then
			shouldShow = false;
		else
			for i = BACKPACK_CONTAINER + 1, NUM_BAG_SLOTS, 1 do
				if ( not GetInventoryItemID("player", ContainerIDToInventoryID(i)) ) then
					shouldShow = false;
					break;
				end
			end
		end
		if ( shouldShow and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_CLEAN_UP_BAGS) ) then
			BagHelpBox:ClearAllPoints();
			--BagHelpBox:SetPoint("RIGHT", BagItemAutoSortButton, "LEFT", -24, 0);
			BagHelpBox.Text:SetText(CLEAN_UP_BAGS_TUTORIAL);
			BagHelpBox.owner = self;
			BagHelpBox.wasShown = true;
			BagHelpBox.bitField = LE_FRAME_TUTORIAL_CLEAN_UP_BAGS;
			BagHelpBox:Show();
		end
		MainMenuBarBackpackButton:SetChecked(true);
	elseif ( self:GetID() > 0) then -- The actual bank has ID -1, backpack has ID 0, we want to make sure we're looking at a regular or bank bag
		local button = _G["CharacterBag"..(self:GetID() - 1).."Slot"];
		if ( button ) then
			button:SetChecked(true);
		end
		if (not IsInventoryItemProfessionBag("player", ContainerIDToInventoryID(self:GetID()))) then
			for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
				local active = false;
				if ( self:GetID() > NUM_BAG_SLOTS ) then
					active = GetBankBagSlotFlag(self:GetID() - NUM_BAG_SLOTS, i);
				else
					active = GetBagSlotFlag(self:GetID(), i);
				end
				--[[
				if ( active ) then
					self.FilterIcon.Icon:SetAtlas(BAG_FILTER_ICONS[i], true);
					self.FilterIcon:Show();
					break;
				end
				--]]
			end
		end
		if ( not ContainerFrame1.allBags ) then
			CheckBagSettingsTutorial();
		end
		if ( self:GetID() > NUM_BAG_SLOTS ) then
			UpdateBagButtonHighlight(self:GetID() - NUM_BAG_SLOTS);
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
	--[[if ( ManageBackpackTokenFrame ) then
		ManageBackpackTokenFrame();
	end]]
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
		if (not ContainerFrame1.allBags) then
			CheckBagSettingsTutorial();
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

function CheckBagSettingsTutorial()
	local shouldShow = true;
	if (FRAME_THAT_OPENED_BAGS ~= nil or Kiosk.IsEnabled()) then
		shouldShow = false;
	else
		for i = BACKPACK_CONTAINER + 1, NUM_BAG_SLOTS, 1 do
			if ( not GetInventoryItemID("player", ContainerIDToInventoryID(i)) ) then
				shouldShow = false;
				break;
			end
		end
	end
	if (shouldShow and GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_CLEAN_UP_BAGS) and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_BAG_SETTINGS)) then
		local frame;
		if (ContainerFrame4:IsShown() and ContainerFrame4:GetID() ~= 0) then
			frame = ContainerFrame4;
		else
			for i=NUM_CONTAINER_FRAMES, 1, -1 do
				if ( _G["ContainerFrame"..i]:IsShown() and _G["ContainerFrame"..i]:GetID() ~= 0 ) then
					frame = _G["ContainerFrame"..i];
					break;
				end
			end
		end
		if (frame) then
			BagHelpBox:ClearAllPoints();
			BagHelpBox:SetPoint("RIGHT", frame.Portrait, "LEFT", -8, 0);
			BagHelpBox.Text:SetText(BAG_SETTINGS_TUTORIAL);
			BagHelpBox:Show();
			BagHelpBox.owner = frame;
			BagHelpBox.bitField = LE_FRAME_TUTORIAL_BAG_SETTINGS;
		end
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

--[[
function ContainerFrame_UpdateItemUpgradeIcons(frame)
	local id = frame:GetID();
	local name = frame:GetName();
	local itemButton;
	for i=1, frame.size, 1 do
		itemButton = _G[name.."Item"..i];
		ContainerFrameItemButton_UpdateItemUpgradeIcon(itemButton);
	end
end
--]]

function ContainerFrame_Update(frame)
	local id = frame:GetID();
	local name = frame:GetName();
	local itemButton;
	local texture, itemCount, locked, quality, readable, _, isFiltered, noValue, itemID;
--[[
	local isQuestItem, questId, isActive, questTexture;
	local battlepayItemTexture, newItemTexture, flash, newItemAnim;
--]]
	local tooltipOwner = GameTooltip:GetOwner();
	local baseSize = GetContainerNumSlots(id);	
--[[
	frame.FilterIcon:Hide();
--]]
	if ( id ~= 0 and id ~= KEYRING_CONTAINER and not IsInventoryItemProfessionBag("player", ContainerIDToInventoryID(id)) ) then
		for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
			local active = false;
			if ( id > NUM_BAG_SLOTS ) then
				active = GetBankBagSlotFlag(id - NUM_BAG_SLOTS, i);
			else
				active = GetBagSlotFlag(id, i);
			end
			--[[
			if ( active ) then
				frame.FilterIcon.Icon:SetAtlas(BAG_FILTER_ICONS[i], true);
				frame.FilterIcon:Show();
				break;
			end
			--]]
		end
	end

	--Update Searchbox and sort button
	--[[
	if ( id == 0 ) then
		BagItemSearchBox:SetParent(frame);
		BagItemSearchBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 54, -37);
		BagItemSearchBox.anchorBag = frame;
		BagItemSearchBox:Show();
		BagItemAutoSortButton:SetParent(frame);
		BagItemAutoSortButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -9, -34);
		BagItemAutoSortButton:Show();
	elseif ( BagItemSearchBox.anchorBag == frame ) then
		BagItemSearchBox:ClearAllPoints();
		BagItemSearchBox:Hide();
		BagItemSearchBox.anchorBag = nil;
		BagItemAutoSortButton:ClearAllPoints();
		BagItemAutoSortButton:Hide();
	end
	--]]

	for i=1, frame.size, 1 do
		itemButton = _G[name.."Item"..i];
		
		texture, itemCount, locked, quality, readable, _, _, isFiltered, noValue, itemID = GetContainerItemInfo(id, itemButton:GetID());
--[[
		isQuestItem, questId, isActive = GetContainerItemQuestInfo(id, itemButton:GetID());
--]]
		
		SetItemButtonTexture(itemButton, texture);
		SetItemButtonQuality(itemButton, quality, itemID);
		SetItemButtonCount(itemButton, itemCount);
		SetItemButtonDesaturated(itemButton, locked);
		
		ContainerFrameItemButton_SetForceExtended(itemButton, itemButton:GetID() > baseSize);

		questTexture = _G[name.."Item"..i.."IconQuestTexture"];
--[[
		if ( questId and not isActive ) then
			questTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG);
			questTexture:Show();
		elseif ( questId or isQuestItem ) then
			questTexture:SetTexture(TEXTURE_ITEM_QUEST_BORDER);
			questTexture:Show();		
		else
			questTexture:Hide();
		end
--]]
		questTexture:Hide();
		
--[[
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
--]]
		battlepayItemTexture = _G[name.."Item"..i].BattlepayItemTexture;
		newItemTexture = _G[name.."Item"..i].NewItemTexture;
		battlepayItemTexture:Hide();
		newItemTexture:Hide();

--[[
		itemButton.JunkIcon:SetShown(quality == LE_ITEM_QUALITY_POOR and not noValue and MerchantFrame:IsShown());
--]]
		itemButton.JunkIcon:SetShown(false);

--[[
		ContainerFrameItemButton_UpdateItemUpgradeIcon(itemButton);
--]]

		if ( texture ) then
			ContainerFrame_UpdateCooldown(id, itemButton);
			itemButton.hasItem = 1;
		else
			_G[name.."Item"..i.."Cooldown"]:Hide();
			itemButton.hasItem = nil;
		end
		itemButton.readable = readable;
		
		if ( itemButton == tooltipOwner ) then
			if (GetContainerItemInfo(frame:GetID(), itemButton:GetID())) then
				itemButton.UpdateTooltip(itemButton);
			else
				GameTooltip:Hide();
			end
		end
		
		
		if ( isFiltered ) then
			itemButton.searchOverlay:Show();
		else
			itemButton.searchOverlay:Hide();
		end
	end
end

function ContainerFrame_UpdateAll()
	for i = 1, NUM_CONTAINER_FRAMES, 1 do
		local frame = _G["ContainerFrame"..i];
		if (frame:IsShown()) then
			ContainerFrame_Update(frame);
		end
	end
end

function ContainerFrame_UpdateSearchResults(frame)
	local id = frame:GetID();
	local name = frame:GetName().."Item";
	local itemButton;
	local _, isFiltered;
	
	for i=1, frame.size, 1 do
		itemButton = _G[name..i] or frame["Item"..i];
		_, _, _, _, _, _, _, isFiltered = GetContainerItemInfo(id, itemButton:GetID());	
		if ( isFiltered ) then
			itemButton.searchOverlay:Show();
		else
			itemButton.searchOverlay:Hide();
		end
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
	local playerLevel = UnitLevel("player");

	-- if id = 0 then its the backpack
	if ( id == 0 ) then
		bgTexture1Slot:Hide();

		local advertiseExtraSlots = playerLevel >= ADVERTISE_SLOTS_LEVEL;
		local extended = size > BACKPACK_BASE_SIZE;
		local extraRows = 0;

		bgTextureTop:SetTexture("Interface\\ContainerFrame\\UI-BackpackBackground");
		if (extended) then
			extraRows = math.ceil((size - BACKPACK_BASE_SIZE) / columns);
			bgTextureTop:SetHeight(BACKPACK_EXTENDED_TOPHEIGHT);
			bgTextureTop:SetTexCoord(0, 1, 0, BACKPACK_EXTENDED_TOPHEIGHT / BACKPACK_DEFAULT_TOPHEIGHT);
			backpackFirstButtonOffset = backpackFirstButtonOffset - (FIRST_BACKPACK_BUTTON_OFFSET_PER_EXTRA_ROW * extraRows);	
		else
			bgTextureTop:SetHeight(BACKPACK_DEFAULT_TOPHEIGHT);
			bgTextureTop:SetTexCoord(0, 1, 0, 1);
		end
		bgTextureTop:Show();
		bgTextureBottom:Hide();

		_G[name.."MoneyFrame"]:Show();
		_G[name.."MoneyFrame"]:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, BACKPACK_MONEY_OFFSET_DEFAULT - (BACKPACK_MONEY_HEIGHT_OFFSET_PER_EXTRA_ROW * extraRows));
		_G[name.."AddSlotsButton"]:SetShown(not secured and not extended and advertiseExtraSlots);

		-- Hide unused textures
		for i=1, MAX_BG_TEXTURES do
			_G[name.."BackgroundMiddle"..i]:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components");
			_G[name.."BackgroundMiddle"..i]:Hide();
		end

		local middleBgHeight = 0;

		if (frame.extendedOverlay) then
			frame.extendedOverlay:Hide();
		end

		if (extended) then
			local rowHeight = 41;
			-- Subtract four, since the top part of the backpack texture contains four rows already
			local remainingRows = extraRows;

			-- Calculate the number of background textures we're going to need
			bgTextureCount = ceil(remainingRows/ROWS_IN_BG_TEXTURE);
			
			-- Try to cycle all the middle bg textures
			local firstRowPixelOffset = 9;
			local firstRowTexCoordOffset = BG_TEXTURE_MIDDLE_START / BG_TEXTURE_HEIGHT;
			for i=1, bgTextureCount do
				bgTextureMiddle = _G[name.."BackgroundMiddle"..i];
				if ( remainingRows > ROWS_IN_BG_TEXTURE ) then
					-- If more rows left to draw than can fit in a texture then draw the max possible
					height = ( ROWS_IN_BG_TEXTURE*rowHeight ) - firstRowPixelOffset
					bgTextureMiddle:SetHeight(ROWS_IN_BG_TEXTURE*rowHeight);
					bgTextureMiddle:SetTexCoord(0, 1, firstRowTexCoordOffset, ( height/BG_TEXTURE_HEIGHT + firstRowTexCoordOffset) );
					bgTextureMiddle:Show();
					remainingRows = remainingRows - ROWS_IN_BG_TEXTURE;
					middleBgHeight = middleBgHeight + ROWS_IN_BG_TEXTURE+rowHeight;
				else
					-- If not its a huge bag
					bgTextureMiddle:Show();
					height = remainingRows*rowHeight-firstRowPixelOffset;
					bgTextureMiddle:SetHeight(remainingRows*rowHeight);
					bgTextureMiddle:SetTexCoord(0, 1, firstRowTexCoordOffset, ( height/BG_TEXTURE_HEIGHT + firstRowTexCoordOffset) );
					middleBgHeight = middleBgHeight + remainingRows*rowHeight;
				end
				if (extended and ContainerFrame1.forceExtended) then
					if (not frame.extendedOverlay) then
						frame.extendedOverlay = frame:CreateTexture(nil, "OVERLAY", 1);
						frame.extendedOverlay:SetColorTexture(0.603, 0.875, 1);
						frame.extendedOverlay:SetAlpha(1);
						frame.extendedOverlay:SetBlendMode("MOD");
					end
					frame.extendedOverlay:SetWidth(CONTAINER_WIDTH-20);
					frame.extendedOverlay:SetHeight(bgTextureMiddle:GetHeight()+2);
					frame.extendedOverlay:SetPoint("CENTER", bgTextureMiddle, "CENTER", 34, -2);
					frame.extendedOverlay:Show();
				end
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
		--ManageBackpackTokenFrame(frame);
	else
		bgTextureBottom:SetHeight(CONTAINER_BOTTOM_TEXTURE_DEFAULT_HEIGHT);
		bgTextureBottom:SetTexCoord(0, 1, CONTAINER_BOTTOM_TEXTURE_DEFAULT_TOP_COORD, CONTAINER_BOTTOM_TEXTURE_DEFAULT_BOTTOM_COORD);
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
			for i=1, MAX_BG_TEXTURES do
				_G[name.."BackgroundMiddle"..i]:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components"..bagTextureSuffix);
				_G[name.."BackgroundMiddle"..i]:Hide();
			end
			bgTextureBottom:SetTexture("Interface\\ContainerFrame\\UI-Bag-Components"..bagTextureSuffix);
			-- Hide the moneyframe since its not the backpack
			_G[name.."MoneyFrame"]:Hide();	
			_G[name.."AddSlotsButton"]:Hide();
						
			local bgTextureCount, height;
			local rowHeight = 41;
			-- Subtract one, since the top texture contains one row already
			local remainingRows = rows-1;

			-- See if the bag needs the texture with two slots at the top
			local isPlusTwoBag;
			if ( mod(size,columns) == 2 ) then
				isPlusTwoBag = 1;
			end

			-- Bag background display stuff
			if ( isPlusTwoBag ) then
				bgTextureTop:SetTexCoord(0, 1, 0.189453125, 0.330078125);
				bgTextureTop:SetHeight(72);
			else
				if ( rows == 1 ) then
					-- If only one row chop off the bottom of the texture
					bgTextureTop:SetTexCoord(0, 1, 0.00390625, 0.16796875);
					bgTextureTop:SetHeight(86);
				else
					bgTextureTop:SetTexCoord(0, 1, 0.00390625, 0.18359375);
					bgTextureTop:SetHeight(94);
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
				for i=1, MAX_BG_TEXTURES do
					_G[name.."BackgroundMiddle"..i]:Hide();
				end
			else
				-- Try to cycle all the middle bg textures
				local firstRowPixelOffset = 9;
				local firstRowTexCoordOffset = 0.353515625;
				for i=1, bgTextureCount do
					bgTextureMiddle = _G[name.."BackgroundMiddle"..i];
					if ( remainingRows > ROWS_IN_BG_TEXTURE ) then
						-- If more rows left to draw than can fit in a texture then draw the max possible
						height = ( ROWS_IN_BG_TEXTURE*rowHeight ) + firstRowTexCoordOffset;
						bgTextureMiddle:SetHeight(height);
						bgTextureMiddle:SetTexCoord(0, 1, firstRowTexCoordOffset, ( height/BG_TEXTURE_HEIGHT + firstRowTexCoordOffset) );
						bgTextureMiddle:Show();
						remainingRows = remainingRows - ROWS_IN_BG_TEXTURE;
						middleBgHeight = middleBgHeight + height;
					else
						-- If not its a huge bag
						bgTextureMiddle:Show();
						height = remainingRows*rowHeight-firstRowPixelOffset;
						bgTextureMiddle:SetHeight(height);
						bgTextureMiddle:SetTexCoord(0, 1, firstRowTexCoordOffset, ( height/BG_TEXTURE_HEIGHT + firstRowTexCoordOffset) );
						middleBgHeight = middleBgHeight + height;
					end
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
		if (id == 0 and secured and not IsTutorialFlagged(TUTORIAL_BAG_SLOTS_AUTHENTICATOR)) then
			TriggerTutorial(TUTORIAL_BAG_SLOTS_AUTHENTICATOR);
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
	if (ContainerFrame1.isHelpBoxShown and ContainerFrame1.helpBoxFrame) then
		ContainerFrame1.helpBoxFrame:Raise();
	end
end

function UpdateContainerFrameAnchors()
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
		xOffset = CONTAINER_OFFSET_X / containerScale; 
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
	xOffset = CONTAINER_OFFSET_X / containerScale;
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

	self.SplitStack = function(button, split)
		SplitContainerItem(button:GetParent():GetID(), button:GetID(), split);
	end
	self.UpdateTooltip = ContainerFrameItemButton_OnEnter;
	self.timeSinceUpgradeCheck = 0;
end

--[[
function ContainerFrameItemButton_UpdateItemUpgradeIcon(self)
	self.timeSinceUpgradeCheck = 0;
	
	local itemIsUpgrade = IsContainerItemAnUpgrade(self:GetParent():GetID(), self:GetID());
	if ( itemIsUpgrade == nil and not self.isExtended) then -- nil means not all the data was available to determine if this is an upgrade.
		self.UpgradeIcon:SetShown(false);
		self:SetScript("OnUpdate", ContainerFrameItemButton_OnUpdate);
	elseif (not self.isExtended) then
		self.UpgradeIcon:SetShown(itemIsUpgrade);
		self:SetScript("OnUpdate", nil);
	end
end
--]]

--[[
local ITEM_UPGRADE_CHECK_TIME = 0.5;
function ContainerFrameItemButton_OnUpdate(self, elapsed)
	self.timeSinceUpgradeCheck = self.timeSinceUpgradeCheck + elapsed;
	if ( self.timeSinceUpgradeCheck >= ITEM_UPGRADE_CHECK_TIME ) then
		ContainerFrameItemButton_UpdateItemUpgradeIcon(self);
	end
end
--]]

local bagStaticDuration = 2.5;
local bagStaticStartingHeight = 37;
local bagStaticMovePerSec = bagStaticStartingHeight / bagStaticDuration;

function ContainerFrameItemButton_BagStatic_AnimateUpdate(self, elapsed)
	local shift = bagStaticMovePerSec * elapsed;
	if (not self.currentHeight or (self.currentHeight - shift) <= 0) then
		self.BagStaticTop:SetHeight(0);
		self.BagStaticTop:SetTexCoord(0, 1, 0, 0);
		self.BagStaticBottom:SetTexCoord(0, 1, 0, 1);
		self.currentHeight = bagStaticStartingHeight;
	end
	self.currentHeight = self.currentHeight - shift;
	self.BagStaticBottom:SetHeight(self.currentHeight);
	self.BagStaticBottom:SetTexCoord(0, 1, 0, (self.currentHeight / bagStaticStartingHeight));
	local topHeight = bagStaticStartingHeight - self.currentHeight;
	if (topHeight < bagStaticStartingHeight and topHeight > 0) then
		self.BagStaticTop:SetHeight(topHeight);
		self.BagStaticTop:SetTexCoord(0, 1, 1 - (topHeight / bagStaticStartingHeight), 1);
	end
end

function ContainerFrameItemButton_SetForceExtended(itemButton, extended)
	if (extended) then
		itemButton:GetNormalTexture():SetVertexColor(0.603, 0.875, 1);
		itemButton.ExtendedOverlay:Show();
		itemButton.ExtendedOverlay2:Show();
		itemButton.ExtendedSlot:Show();
		if ((itemButton:GetID() - 1) == GetContainerNumSlots(0)) then
			itemButton.BagStaticBottom:Show();
			itemButton.BagStaticTop:Show();
			itemButton:SetScript("OnUpdate", ContainerFrameItemButton_BagStatic_AnimateUpdate);
		end
		itemButton:EnableMouse(false);
		itemButton.isExtended = true;
	else
		itemButton:GetNormalTexture():SetVertexColor(1, 1, 1);
		itemButton.ExtendedOverlay:Hide();
		itemButton.ExtendedOverlay2:Hide();
		itemButton.ExtendedSlot:Hide();
		itemButton.BagStaticBottom:Hide();
		itemButton.BagStaticTop:Hide();
		itemButton:EnableMouse(true);
		itemButton:SetScript("OnUpdate", nil);
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
			local extraArgs = "";
			if ( currencyTexture == HONOR_POINT_TEXTURES[1] or currencyTexture == HONOR_POINT_TEXTURES[2] ) then
				-- Honor Point textures have some funky coordinates, so we'll fix them up here.
				extraArgs = ":64:64:0:40:0:40";
			end

			if ( itemsString ) then
				itemsString = itemsString .. ", |T"..currencyTexture..":0:0:0:-1"..extraArgs.."|t ".. format(CURRENCY_QUANTITY_TEMPLATE, (currencyQuantity or 0) * quantity, currencyName);
			else
				itemsString = " |T"..currencyTexture..":0:0:0:-1"..extraArgs.."|t "..format(CURRENCY_QUANTITY_TEMPLATE, (currencyQuantity or 0) * quantity, currencyName);
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
		end
		UseContainerItem(self:GetParent():GetID(), self:GetID(), nil, BankFrame:IsShown() and (BankFrame.selectedTab == 2));
		StackSplitFrame:Hide();
	end
end

function ContainerFrameItemButton_OnModifiedClick(self, button)
	if ( IsModifiedClick("EXPANDITEM") ) then
		local itemLocation = ItemLocation:CreateFromBagAndSlot(self:GetParent():GetID(), self:GetID());
		if C_Item.DoesItemExist(itemLocation) then
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
			self.SplitStack = function(button, split)
				SplitContainerItem(button:GetParent():GetID(), button:GetID(), split);
			end
			OpenStackSplitFrame(itemCount, self, "BOTTOMRIGHT", "TOPRIGHT");
		end
	end
end

function ContainerFrameItemButton_CalculateItemTooltipAnchors(self, mainTooltip, secondaryTooltip)
	local x = self:GetRight();

	local anchorFromLeft = x < GetScreenWidth() / 2;

	if ( secondaryTooltip and secondaryTooltip:IsShown() ) then
		-- Always put the primary tooltip on the left
		if ( anchorFromLeft ) then
			mainTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT");
			secondaryTooltip:SetPoint("TOPLEFT", mainTooltip, "TOPRIGHT", 0, 0);
			mainTooltip.overrideComparisonAnchorFrame = secondaryTooltip;
			mainTooltip.overrideComparisonAnchorSide = "right";
		else
			secondaryTooltip:SetPoint("BOTTOMRIGHT", self, "TOPLEFT");
			mainTooltip:SetPoint("TOPRIGHT", secondaryTooltip, "TOPLEFT", 0, 0);
			mainTooltip.overrideComparisonAnchorSide = "left";
		end
		return true;
	else
		if ( anchorFromLeft ) then
			mainTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT");
		else
			mainTooltip:SetPoint("BOTTOMRIGHT", self, "TOPLEFT");
		end
	end
	return false;
end

function ContainerFrameItemButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE");

	-- Keyring specific code
	if ( self:GetParent():GetID() == KEYRING_CONTAINER ) then
		ContainerFrameItemButton_CalculateItemTooltipAnchors(self, GameTooltip);
		GameTooltip:SetInventoryItem("player", KeyRingButtonIDToInvSlotID(self:GetID()));
		CursorUpdate(self);
		return;
	end

	C_NewItems.RemoveNewItem(self:GetParent():GetID(), self:GetID());

--[[
	local newItemTexture = self.NewItemTexture;
	local battlepayItemTexture = self.BattlepayItemTexture;
	local flash = self.flashAnim;
	local newItemGlowAnim = self.newitemglowAnim;
	
	newItemTexture:Hide();
	battlepayItemTexture:Hide();
	
	if (flash:IsPlaying() or newItemGlowAnim:IsPlaying()) then
		flash:Stop();
		newItemGlowAnim:Stop();
	end
--]]
	
	local showSell = nil;
	local hasCooldown, repairCost, speciesID, level, breedQuality, maxHealth, power, speed, name = GameTooltip:SetBagItem(self:GetParent():GetID(), self:GetID());
	if(speciesID and speciesID > 0) then
		ContainerFrameItemButton_CalculateItemTooltipAnchors(self, GameTooltip); -- Battle pet tooltip uses the GameTooltip's anchor
		BattlePetToolTip_Show(speciesID, level, breedQuality, maxHealth, power, speed, name);
		return;
	else
		if (BattlePetTooltip) then
			BattlePetTooltip:Hide();
		end
	end

	local requiresCompareTooltipReanchor = ContainerFrameItemButton_CalculateItemTooltipAnchors(self, GameTooltip);

	if ( (IsModifiedClick("COMPAREITEMS") or GetCVarBool("alwaysCompareItems")) ) then
		GameTooltip_ShowCompareItem(GameTooltip);
	end

	if ( InRepairMode() and (repairCost and repairCost > 0) ) then
		GameTooltip:AddLine(REPAIR_COST, nil, nil, nil, true);
		SetTooltipMoney(GameTooltip, repairCost);
		GameTooltip:Show();
	elseif ( MerchantFrame:IsShown() and MerchantFrame.selectedTab == 1 ) then
		showSell = 1;
	end

	if ( IsModifiedClick("DRESSUP") and self.hasItem ) then
		ShowInspectCursor();
	elseif ( showSell ) then
		ShowContainerSellCursor(self:GetParent():GetID(),self:GetID());
	elseif ( self.readable ) then
		ShowInspectCursor();
	else
		ResetCursor();
	end

	if ArtifactFrame and self.hasItem then
		ArtifactFrame:OnInventoryItemMouseEnter(self:GetParent():GetID(), self:GetID());
	end
end

function ContainerFrameItemButton_OnLeave(self)
	GameTooltip_Hide();
	ResetCursor();

	if ArtifactFrame then
		ArtifactFrame:OnInventoryItemMouseLeave(self:GetParent():GetID(), self:GetID());
	end
end

function ContainerFramePortraitButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	local waitingOnData = false;
	if ( self:GetID() == 0 ) then
		GameTooltip:SetText(BACKPACK_TOOLTIP, 1.0, 1.0, 1.0);
		if (GetBindingKey("TOGGLEBACKPACK")) then
			GameTooltip:AppendText(" "..NORMAL_FONT_COLOR_CODE.."("..GetBindingKey("TOGGLEBACKPACK")..")"..FONT_COLOR_CODE_CLOSE)
		end
	elseif ( self:GetID() == KEYRING_CONTAINER ) then
		GameTooltip:SetText(KEYRING, 1.0, 1.0, 1.0);
		local binding = GetBindingKey("TOGGLEBAG"..(self:GetID()));
		if ( binding ) then
			GameTooltip:AppendText(" "..NORMAL_FONT_COLOR_CODE.."("..binding..")"..FONT_COLOR_CODE_CLOSE);
		end
	elseif ( GameTooltip:SetInventoryItem("player", ContainerIDToInventoryID(self:GetID())) ) then
		local bagID = ContainerIDToInventoryID(self:GetID());
		local binding = GetBindingKey("TOGGLEBAG"..(4 - self:GetID() + 1));
		if ( binding ) then
			GameTooltip:AppendText(" "..NORMAL_FONT_COLOR_CODE.."("..binding..")"..FONT_COLOR_CODE_CLOSE);
		end
		if (not IsInventoryItemProfessionBag("player", bagID)) then
			for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
				if ( GetBagSlotFlag(bagID, i) ) then
					GameTooltip:AddLine(BAG_FILTER_ASSIGNED_TO:format(BAG_FILTER_LABELS[i]));
					break;
				end
			end
		end
	end
	
	self.UpdateTooltip = waitingOnData and ContainerFramePortraitButton_OnEnter or nil;
	GameTooltip:Show();
end

function ContainerFramePortraitButton_OnLeave(self)
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
		CloseBackpack()
	end

	for i=1, NUM_BAG_FRAMES, 1 do
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
		for i=1, NUM_BAG_FRAMES, 1 do
			OpenBag(i);
		end
		ContainerFrame1.allBags = false;
		CheckBagSettingsTutorial();
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
			CheckBagSettingsTutorial();
		end
	end
end

function OpenAllBags(frame)
	if ( not UIParent:IsShown() ) then
		return;
	end
	
	for i=0, NUM_BAG_FRAMES, 1 do
		if (IsBagOpen(i)) then
			return;
		end
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
	CheckBagSettingsTutorial();
end

function CloseAllBags(frame)	
	if ( frame and frame:GetName() ~= FRAME_THAT_OPENED_BAGS) then
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

