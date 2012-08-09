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
		SplitContainerItem(BANK_CONTAINER, button:GetID(), split);
	end
end

function BankFrameBagButton_OnLoad (self)
	self.isBag = 1;
	BankFrameBaseButton_OnLoad(self);
	self:RegisterEvent("INVENTORY_SEARCH_UPDATE");
end

function BankFrameBagButton_OnEvent (self, event, ...)
	if ( event == "INVENTORY_SEARCH_UPDATE" ) then
		if ( IsContainerFiltered(self:GetID()) ) then
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

	if ( not hasItem ) then
		if ( self.isBag ) then
			GameTooltip:SetText(self.tooltipText);
		end
	end
	CursorUpdate(self);
end

function BankFrameItemButton_Update (button)
	local texture = _G[button:GetName().."IconTexture"];
	local inventoryID = button:GetInventorySlot();
	local textureName = GetInventoryItemTexture("player",inventoryID);
	local _, _, _, _, _, _, _, isFiltered = GetContainerItemInfo(BANK_CONTAINER, button:GetID());
	local slotName = button:GetName();
	local id;
	local slotTextureName;
	button.hasItem = nil;

	if( button.isBag ) then
		id, slotTextureName = GetInventorySlotInfo(strsub(slotName,10));
	else
		local isQuestItem, questId, isActive = GetContainerItemQuestInfo(BANK_CONTAINER, button:GetID());
		local questTexture = _G[button:GetName().."IconQuestTexture"];
		if ( questId and not isActive ) then
			questTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG);
			questTexture:Show();
		elseif ( questId or isQuestItem ) then
			questTexture:SetTexture(TEXTURE_ITEM_QUEST_BORDER);
			questTexture:Show();		
		else
			questTexture:Hide();
		end
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
	
	BankFrameItemButton_UpdateLocked(button);
	BankFrame_UpdateCooldown(BANK_CONTAINER, button);
end

function BankFrame_UpdateCooldown(container, button)
	local cooldown = _G[button:GetName().."Cooldown"];
	local start, duration, enable;
	if ( button.isBag ) then
		-- in case we ever have a bag with a cooldown...
		local inventoryID = ContainerIDToInventoryID(button:GetID());
		start, duration, enable = GetInventoryItemCooldown("player", inventoryID);
	else
		start, duration, enable = GetContainerItemCooldown(container, button:GetID());
	end
	CooldownFrame_SetTimer(cooldown, start, duration, enable);
	if ( duration > 0 and enable == 0 ) then
		SetItemButtonTextureVertexColor(button, 0.4, 0.4, 0.4);
	end
end

function BankFrameItemButton_UpdateLocked (button) 
	local inventoryID = button:GetInventorySlot();
	if ( IsInventoryItemLocked(inventoryID) ) then
		SetItemButtonDesaturated(button, 1);
	else 
		if ( button.isBag and ((button:GetID() - 4) > GetNumBankSlots()) ) then
			return;
		end
		SetItemButtonDesaturated(button, nil);
	end
end

function BankFrame_OnLoad (self)
	self:RegisterEvent("BANKFRAME_OPENED");
	self:RegisterEvent("BANKFRAME_CLOSED");
	self.size = 28;
	self:SetID(BANK_CONTAINER);
	
	--Create bank item buttons, button background textures, and rivets between buttons
	for i = 2, 28 do
		local button = CreateFrame("Button", "BankFrameItem"..i, BankFrame, "BankItemButtonGenericTemplate");
		button:SetID(i);
		if ((i%7) == 1) then
			button:SetPoint("TOPLEFT", _G["BankFrameItem"..(i-7)], "BOTTOMLEFT", 0, -7);
		else
			button:SetPoint("TOPLEFT", _G["BankFrameItem"..(i-1)], "TOPRIGHT", 12, 0);
		end
	end
	for i = 1, 28 do
		local texture = self:CreateTexture(nil, "BORDER", "Bank-Slot-BG");
		texture:SetPoint("TOPLEFT", _G["BankFrameItem"..i], "TOPLEFT", -6, 5);
		texture:SetPoint("BOTTOMRIGHT", _G["BankFrameItem"..i], "BOTTOMRIGHT", 6, -7);
	end
	for i = 1, 7 do
		local texture = self:CreateTexture(nil, "BORDER", "Bank-Slot-BG");
		texture:SetPoint("TOPLEFT", _G["BankFrameBag"..i], "TOPLEFT", -6, 5);
		texture:SetPoint("BOTTOMRIGHT", _G["BankFrameBag"..i], "BOTTOMRIGHT", 6, -7);
	end
	for i = 1, 20 do
		if ((i%7) ~= 0) then
			local texture = self:CreateTexture(nil, "BORDER", "Bank-Rivet");
			texture:SetPoint("TOPLEFT", _G["BankFrameItem"..i], "BOTTOMRIGHT", 0, 2);
			texture:SetPoint("BOTTOMRIGHT", _G["BankFrameItem"..i], "BOTTOMRIGHT", 12, -10);
		end
	end
	
end

function UpdateBagSlotStatus () 
	local purchaseFrame = BankFramePurchaseInfo;
	if( purchaseFrame == nil ) then
		return;
	end
	
	local numSlots,full = GetNumBankSlots();
	local button;
	for i=1, NUM_BANKBAGSLOTS, 1 do
		button = _G["BankFrameBag"..i];
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
		BankFrameTitleText:SetText(UnitName("npc"));
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
				BankFrameItemButton_UpdateLocked(_G["BankFrameItem"..slot]);
			else
				BankFrameItemButton_UpdateLocked(_G["BankFrameBag"..(slot-NUM_BANKGENERIC_SLOTS)]);
			end
		end
	elseif ( event == "PLAYERBANKSLOTS_CHANGED" ) then
		local slot = ...;
		if ( slot <= NUM_BANKGENERIC_SLOTS ) then
			BankFrameItemButton_Update(_G["BankFrameItem"..slot]);
		else
			BankFrameItemButton_Update(_G["BankFrameBag"..(slot-NUM_BANKGENERIC_SLOTS)]);
		end
	elseif ( event == "PLAYER_MONEY" or event == "PLAYERBANKBAGSLOTS_CHANGED" ) then
		UpdateBagSlotStatus();
	elseif ( event == "INVENTORY_SEARCH_UPDATE" ) then
		ContainerFrame_UpdateSearchResults(self);
	end
end

function BankFrame_OnShow (self)
	PlaySound("igMainMenuOpen");

	self:RegisterEvent("ITEM_LOCK_CHANGED");
	self:RegisterEvent("PLAYERBANKSLOTS_CHANGED");
	self:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED");
	self:RegisterEvent("PLAYER_MONEY");
	self:RegisterEvent("BAG_UPDATE_COOLDOWN");
	self:RegisterEvent("INVENTORY_SEARCH_UPDATE");

	local button;
	for i=1, NUM_BANKGENERIC_SLOTS, 1 do
		button = _G["BankFrameItem"..i];
		BankFrameItemButton_Update(button);
	end
	
	for i=1, NUM_BANKBAGSLOTS, 1 do
		button = _G["BankFrameBag"..i];
		BankFrameItemButton_Update(button);
	end
	UpdateBagSlotStatus();
	OpenAllBags(self);
end

function BankFrame_OnHide (self)
	PlaySound("igMainMenuClose");

	self:UnregisterEvent("ITEM_LOCK_CHANGED");
	self:UnregisterEvent("PLAYERBANKSLOTS_CHANGED");
	self:UnregisterEvent("PLAYERBANKBAGSLOTS_CHANGED");
	self:UnregisterEvent("PLAYER_MONEY");
	self:UnregisterEvent("INVENTORY_SEARCH_UPDATE");

	StaticPopup_Hide("CONFIRM_BUY_BANK_SLOT");
	CloseAllBags(self);
	CloseBankBagFrames();
	CloseBankFrame();
	UpdateContainerFrameAnchors();
end

function BankFrameItemButtonGeneric_OnClick (self, button)
	if ( button == "LeftButton" ) then
		PickupContainerItem(BANK_CONTAINER, self:GetID());
	else
		UseContainerItem(BANK_CONTAINER, self:GetID());
	end
end

function BankFrameItemButtonGeneric_OnModifiedClick (self, button)
	if ( self.isBag ) then
		return;
	end
	if ( HandleModifiedItemClick(GetContainerItemLink(BANK_CONTAINER, self:GetID())) ) then
		return;
	end
	if ( IsModifiedClick("SPLITSTACK") ) then
		local texture, itemCount, locked = GetContainerItemInfo(BANK_CONTAINER, self:GetID());
		if ( not locked and itemCount > 1) then
			OpenStackSplitFrame(self.count, self, "BOTTOMLEFT", "TOPLEFT");
		end
		return;
	end
end

function UpdateBagButtonHighlight (id) 
	local texture = _G["BankFrameBag"..(id - NUM_BAG_SLOTS).."HighlightFrameTexture"];
	if ( not texture ) then
		return;
	end

	local frame;
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		frame = _G["ContainerFrame"..i];
		if ( ( frame:GetID() == id ) and frame:IsShown() ) then
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
		ToggleBag(id);
	end
	UpdateBagButtonHighlight(id);
end

function BankFrameItemButtonBag_Pickup (self)
	local inventoryID = self:GetInventorySlot();
	PickupBagFromSlot(inventoryID);
	UpdateBagButtonHighlight(self:GetID());
end
