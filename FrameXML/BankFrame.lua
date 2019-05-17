BANK_PANELS = {
	{ name = "BankSlotsFrame", size = {x=384, y=512}, SetTitle=function() BankFrameTitleText:SetText(UnitName("npc")); end },
}

function ButtonInventorySlot (self)
	return BankButtonIDToInvSlotID(self:GetID(),self.isBag)
end

function BankFrameBaseButton_OnLoad (self)
	self:RegisterForDrag("LeftButton");
	self:RegisterForClicks("LeftButtonUp","RightButtonUp");
	self.GetInventorySlot = ButtonInventorySlot;
	self.UpdateTooltip = BankFrameItemButton_OnEnter;
end

function BankFrameItemButton_OnLoad (self) 
	BankFrameBaseButton_OnLoad (self);
	self.SplitStack = function(button, split)
		SplitContainerItem(button:GetParent():GetID(), button:GetID(), split);
	end
end

function BankFrameBagButton_OnLoad (self)
	self.isBag = 1;
	BankFrameBaseButton_OnLoad(self);
	self:RegisterEvent("INVENTORY_SEARCH_UPDATE");
end

function BankFrameBagButton_OnEvent (self, event, ...)
	if ( event == "INVENTORY_SEARCH_UPDATE" ) then
		if ( IsContainerFiltered(self:GetID()+NUM_BAG_SLOTS) ) then
			self.searchOverlay:Show();
		else
			self.searchOverlay:Hide();
		end
	end
end

function BankFrameItemButton_OnEnter (self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	local hasItem, hasCooldown, repairCost, speciesID, level, breedQuality, maxHealth, power, speed, name = GameTooltip:SetInventoryItem("player", self:GetInventorySlot());
	if(speciesID and speciesID > 0) then
		BattlePetToolTip_Show(speciesID, level, breedQuality, maxHealth, power, speed, name);
		CursorUpdate(self);
		return;
	end

	if (self.isBag) then
		if (not IsInventoryItemProfessionBag("player", self:GetInventorySlot())) then
			for i = LE_BAG_FILTER_FLAG_EQUIPMENT, NUM_LE_BAG_FILTER_FLAGS do
				if ( GetBankBagSlotFlag(self:GetID(), i) ) then
					GameTooltip:AddLine(BAG_FILTER_ASSIGNED_TO:format(BAG_FILTER_LABELS[i]));
					break;
				end
			end
		end
	end

	if ( not hasItem ) then
		if ( self.isBag ) then
			GameTooltip:SetText(self.tooltipText);
		end
	end

	GameTooltip:Show();
	CursorUpdate(self);
end

function BankFrameItemButton_Update (button)
	local container = button:GetParent():GetID();
	local buttonID = button:GetID();
	if( button.isBag ) then
		container = -4;
	end
	local texture = button.icon;
	local inventoryID = button:GetInventorySlot();
	local textureName = GetInventoryItemTexture("player",inventoryID);
	local _, _, _, quality, _, _, _, isFiltered, _, itemID = GetContainerItemInfo(container, buttonID);
	local slotName = button:GetName();
	local id;
	local slotTextureName;
	button.hasItem = nil;

	if( button.isBag ) then
		id, slotTextureName = GetInventorySlotInfo("Bag"..buttonID);
	else
--[[
		local isQuestItem, questId, isActive = GetContainerItemQuestInfo(container, buttonID);
		local questTexture = button["IconQuestTexture"];
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
		local questTexture = button["IconQuestTexture"];
		questTexture:Hide();
	end

	if ( textureName ) then
		texture:SetTexture(textureName);
		texture:Show();
		SetItemButtonCount(button,GetInventoryItemCount("player",inventoryID));
		button.hasItem = 1;
	elseif ( slotTextureName and button.isBag ) then
		texture:SetTexture(slotTextureName);
		SetItemButtonCount(button,0);
		texture:Show();
	else 
		texture:Hide();
		SetItemButtonCount(button,0);
	end
	
	if ( isFiltered ) then
		button.searchOverlay:Show();
	else
		button.searchOverlay:Hide();
	end

	SetItemButtonQuality(button, quality, itemID);

	BankFrameItemButton_UpdateLocked(button);
	BankFrame_UpdateCooldown(container, button);
end

function BankFrame_UpdateCooldown(container, button)
	local cooldown = button.Cooldown;
	local start, duration, enable;
	if ( button.isBag ) then
		-- in case we ever have a bag with a cooldown...
		local inventoryID = ContainerIDToInventoryID(button:GetID());
		start, duration, enable = GetInventoryItemCooldown("player", inventoryID);
	else
		start, duration, enable = GetContainerItemCooldown(container, button:GetID());
	end
	CooldownFrame_Set(cooldown, start, duration, enable);
	if ( duration > 0 and enable == 0 ) then
		SetItemButtonTextureVertexColor(button, 0.4, 0.4, 0.4);
	end
end

function BankFrameItemButton_UpdateLocked (button) 
	local inventoryID = button:GetInventorySlot();
	if ( IsInventoryItemLocked(inventoryID) ) then
		SetItemButtonDesaturated(button, true);
	else 
		if ( button.isBag and ((button:GetID() - 4) > GetNumBankSlots()) ) then
			return;
		end
		SetItemButtonDesaturated(button, false);
	end
end

function BankSlotsFrame_OnLoad(self)
	self:SetID(BANK_CONTAINER);

	--Create bank item buttons, button background textures, and rivets between buttons
	for i = 2, 24 do
		local button = CreateFrame("Button", "BankFrameItem"..i, self, "BankItemButtonGenericTemplate");
		button:SetID(i);
		self["Item"..i] = button;
		if ((i%6) == 1) then
			button:SetPoint("TOPLEFT", self["Item"..(i-6)], "BOTTOMLEFT", 0, -7);
		else
			button:SetPoint("TOPLEFT", self["Item"..(i-1)], "TOPRIGHT", 12, 0);
		end
	end
	for i = 1, 24 do
		local texture = self:CreateTexture(nil, "BORDER", "Bank-Slot-BG");
		texture:SetPoint("TOPLEFT", self["Item"..i], "TOPLEFT", -6, 5);
		texture:SetPoint("BOTTOMRIGHT", self["Item"..i], "BOTTOMRIGHT", 6, -7);
	end
	for i = 1, 6 do
		local texture = self:CreateTexture(nil, "BORDER", "Bank-Slot-BG");
		texture:SetPoint("TOPLEFT", self["Bag"..i], "TOPLEFT", -6, 5);
		texture:SetPoint("BOTTOMRIGHT", self["Bag"..i], "BOTTOMRIGHT", 6, -7);
	end
	for i = 1, 20 do
		if ((i%7) ~= 0) then
			local texture = self:CreateTexture(nil, "BORDER", "Bank-Rivet");
			texture:SetPoint("TOPLEFT", self["Item"..i], "BOTTOMRIGHT", 0, 2);
			texture:SetPoint("BOTTOMRIGHT", self["Item"..i], "BOTTOMRIGHT", 12, -10);
		end
	end
end

function BankFrame_OnLoad (self)
	self:RegisterEvent("BANKFRAME_OPENED");
	self:RegisterEvent("BANKFRAME_CLOSED");
	self.size = 24;
	self:SetID(BANK_CONTAINER);
	
	PanelTemplates_SetNumTabs(self, #BANK_PANELS);
	self.maxTabWidth = (self:GetWidth() - 19) / #BANK_PANELS;
	self.selectedTab = 1;
end

function UpdateBagSlotStatus () 
	local purchaseFrame = BankFramePurchaseInfo;
	if( purchaseFrame == nil ) then
		return;
	end
	
	local numSlots,full = GetNumBankSlots();
	local button;
	for i=1, NUM_BANKBAGSLOTS, 1 do
		button = BankSlotsFrame["Bag"..i];
		if ( button ) then
			if ( i <= numSlots ) then
				SetItemButtonTextureVertexColor(button, 1.0,1.0,1.0);
				button.tooltipText = BANK_BAG;
			else
				SetItemButtonTextureVertexColor(button, 1.0,0.1,0.1);
				button.tooltipText = BANK_BAG_PURCHASE;
			end
		end
	end

	-- pass in # of current slots, returns cost of next slot
	local cost = GetBankSlotCost(numSlots);
	BankFrame.nextSlotCost = cost;
	if( GetMoney() >= cost ) then
		SetMoneyFrameColor("BankFrameDetailMoneyFrame", "white");
	else
		SetMoneyFrameColor("BankFrameDetailMoneyFrame", "red")
	end
	MoneyFrame_Update("BankFrameDetailMoneyFrame", cost);

	if( full ) then
		purchaseFrame:Hide();
	else
		purchaseFrame:Show();
	end
end

function CloseBankBagFrames () 
	for i=NUM_BAG_SLOTS+1, (NUM_BAG_SLOTS + NUM_BANKBAGSLOTS), 1 do
		CloseBag(i);
	end
end

function BankFrame_OnEvent (self, event, ...)
	if ( event == "BANKFRAME_OPENED" ) then
		BankFrame_ShowPanel(BANK_PANELS[1].name);
		SetPortraitTexture(BankPortraitTexture,"npc");
		ShowUIPanel(self);
		if ( not self:IsShown() ) then
			CloseBankFrame();
		end
	elseif ( event == "BANKFRAME_CLOSED" ) then
		HideUIPanel(self);
	elseif ( event == "ITEM_LOCK_CHANGED" ) then
		local bag, slot = ...;
		if ( bag == BANK_CONTAINER ) then
			if ( slot <= NUM_BANKGENERIC_SLOTS ) then
				BankFrameItemButton_UpdateLocked(BankSlotsFrame["Item"..slot]);
			else
				BankFrameItemButton_UpdateLocked(BankSlotsFrame["Bag"..(slot-NUM_BANKGENERIC_SLOTS)]);
			end
		end
	elseif ( event == "PLAYERBANKSLOTS_CHANGED" ) then
		local slot = ...;
		if ( slot <= NUM_BANKGENERIC_SLOTS ) then
			BankFrameItemButton_Update(BankSlotsFrame["Item"..slot]);
		else
			BankFrameItemButton_Update(BankSlotsFrame["Bag"..(slot-NUM_BANKGENERIC_SLOTS)]);
		end
	elseif ( event == "PLAYER_MONEY" or event == "PLAYERBANKBAGSLOTS_CHANGED" ) then
		UpdateBagSlotStatus();
	elseif ( event == "INVENTORY_SEARCH_UPDATE" ) then
		ContainerFrame_UpdateSearchResults(self);
	end
end

function BankFrame_OnShow (self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);

	self:RegisterEvent("ITEM_LOCK_CHANGED");
	self:RegisterEvent("PLAYERBANKSLOTS_CHANGED");
	self:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED");
	self:RegisterEvent("PLAYER_MONEY");
	self:RegisterEvent("BAG_UPDATE_COOLDOWN");
	self:RegisterEvent("INVENTORY_SEARCH_UPDATE");

	local button;
	for i=1, NUM_BANKGENERIC_SLOTS, 1 do
		button = BankSlotsFrame["Item"..i];
		BankFrameItemButton_Update(button);
	end
	
	for i=1, NUM_BANKBAGSLOTS, 1 do
		button = BankSlotsFrame["Bag"..i];
		BankFrameItemButton_Update(button);
	end
	UpdateBagSlotStatus();
	OpenAllBags(self);
end

function BankFrame_OnHide (self)
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);

	self:UnregisterEvent("ITEM_LOCK_CHANGED");
	self:UnregisterEvent("PLAYERBANKSLOTS_CHANGED");
	self:UnregisterEvent("PLAYERBANKBAGSLOTS_CHANGED");
	self:UnregisterEvent("PLAYER_MONEY");
	self:UnregisterEvent("BAG_UPDATE_COOLDOWN");
	self:UnregisterEvent("INVENTORY_SEARCH_UPDATE");

	StaticPopup_Hide("CONFIRM_BUY_BANK_SLOT");
	CloseAllBags(self);
	CloseBankBagFrames();
	CloseBankFrame();
	UpdateContainerFrameAnchors();
end

function BankFrameItemButtonGeneric_OnClick (self, button)
	local container = self:GetParent():GetID();
	if ( button == "LeftButton" ) then
		PickupContainerItem(container, self:GetID());
	else
		UseContainerItem(container, self:GetID());
	end
end

function BankFrameItemButtonGeneric_OnModifiedClick (self, button)
	local container = self:GetParent():GetID();
	if ( self.isBag ) then
		return;
	end
	if ( HandleModifiedItemClick(GetContainerItemLink(container, self:GetID())) ) then
		return;
	end
	if ( not CursorHasItem() and IsModifiedClick("SPLITSTACK") ) then
		local texture, itemCount, locked = GetContainerItemInfo(container, self:GetID());
		if ( not locked and itemCount and itemCount > 1) then
			OpenStackSplitFrame(self.count, self, "BOTTOMLEFT", "TOPLEFT");
		end
		return;
	end
end

function UpdateBagButtonHighlight (id) 
	local texture = BankSlotsFrame["Bag"..(id)].HighlightFrame.HighlightTexture;
	if ( not texture ) then
		return;
	end

	local frame;
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		frame = _G["ContainerFrame"..i];
		if ( ( frame:GetID() == (id + NUM_BAG_SLOTS) ) and frame:IsShown() ) then
			texture:Show();
			return;
		end
	end
	texture:Hide();
end

function BankFrameItemButtonBag_OnClick (self, button) 
	local inventoryID = self:GetInventorySlot();
	local hadItem = PutItemInBag(inventoryID);
	local id = self:GetID();
	if ( not hadItem ) then
		-- open bag
		ToggleBag(id+NUM_BAG_SLOTS);
	end
	UpdateBagButtonHighlight(id);
end

function BankFrameItemButtonBag_Pickup (self)
	local inventoryID = self:GetInventorySlot();
	PickupBagFromSlot(inventoryID);
	UpdateBagButtonHighlight(self:GetID());
end

function BankFrame_TabOnClick(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
	BankFrame_ShowPanel(BANK_PANELS[self:GetID()].name);
end

-- Bank Frame Show Panel
function BankFrame_ShowPanel(sidePanelName, selection)
	local self = BankFrame;
	-- find side panel
	local tabIndex;
	if ( sidePanelName ) then
		for index, data in pairs(BANK_PANELS) do
			if ( data.name == sidePanelName ) then
				tabIndex = index;
				break;
			end
		end
	else
		-- no side panel specified, check current panel
		if ( self.activeTabIndex ) then
			tabIndex = self.activeTabIndex;
		else
			-- no current panel, go to the first panel
			tabIndex = 1;
		end
	end	
	if ( not tabIndex ) then
		return;
	end
	-- show it
	ShowUIPanel(self);
	self.activeTabIndex = tabIndex;	
	for index, data in pairs(BANK_PANELS) do
		local panel = _G[data.name];
		if ( index == tabIndex ) then
			panel:Show();
			if( panel.update ) then
				panel:update(selection);
			end
			
			self:SetWidth(data.size.x);
			self:SetHeight(data.size.y);
			data.SetTitle();
		elseif ( panel ) then
			panel:Hide();
		end
	end
end

function BankFrame_AutoSortButtonOnClick()
	local self = BankFrame;

	PlaySound(SOUNDKIT.UI_BAG_SORTING_01);
	if (self.activeTabIndex == 1) then
		SortBankBags();
	end
end
