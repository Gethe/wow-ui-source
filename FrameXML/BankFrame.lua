BANK_CONTAINER = -1;
NUM_BAG_SLOTS = 4;
NUM_BANKGENERIC_SLOTS = 28;
NUM_BANKBAGSLOTS = 7;

function ButtonInventorySlot(self)
	return BankButtonIDToInvSlotID(self:GetID(),self.isBag)
end

function BankFrameBaseButton_OnLoad()
	this:RegisterForDrag("LeftButton");
	this:RegisterForClicks("LeftButtonUp","RightButtonUp");
	this.GetInventorySlot = ButtonInventorySlot;
	this.UpdateTooltip = BankFrameItemButton_OnEnter;
end

function BankFrameItemButton_OnLoad() 
	BankFrameBaseButton_OnLoad();
	this.SplitStack = function(button, split)
		SplitContainerItem(BANK_CONTAINER, button:GetID(), split);
	end
end

function BankFrameBagButton_OnLoad()
	this.isBag = 1;
	BankFrameBaseButton_OnLoad();
end

function BankFrameItemButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if ( not GameTooltip:SetInventoryItem("player", self:GetInventorySlot()) ) then
		if ( self.isBag ) then
			GameTooltip:SetText(self.tooltipText);
		end
	end
	CursorUpdate();
end

function BankFrameItemButton_Update(button)
	local texture = getglobal(button:GetName().."IconTexture");
	local inventoryID = button:GetInventorySlot();
	local textureName = GetInventoryItemTexture("player",inventoryID);
	local slotName = button:GetName();
	local id;
	local slotTextureName;
	button.hasItem = nil;

	if( button.isBag ) then
		id, slotTextureName = GetInventorySlotInfo(strsub(slotName,10));
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

	BankFrameItemButton_UpdateLocked(button);
end

function BankFrameItemButton_UpdateLocked(button) 
	local inventoryID = button:GetInventorySlot();
	if ( IsInventoryItemLocked(inventoryID) ) then
		SetItemButtonDesaturated(button, 1, 0.5, 0.5, 0.5);
	else 
		if ( button.isBag and ((button:GetID() - 4) > GetNumBankSlots()) ) then
			return;
		end
		SetItemButtonDesaturated(button, nil, 0.5, 0.5, 0.5);
	end
end

function BankFrame_OnLoad()
	this:RegisterEvent("BANKFRAME_OPENED");
	this:RegisterEvent("BANKFRAME_CLOSED");
end

function UpdateBagSlotStatus() 
	local purchaseFrame = BankFramePurchaseInfo;
	if( purchaseFrame == nil ) then
		return;
	end
	
	local numSlots,full = GetNumBankSlots();
	local button;
	for i=1, NUM_BANKBAGSLOTS, 1 do
		button = getglobal("BankFrameBag"..i);
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
		SetMoneyFrameColor("BankFrameDetailMoneyFrame", 1.0, 1.0, 1.0);
	else
		SetMoneyFrameColor("BankFrameDetailMoneyFrame", 1.0, 0.1, 0.1)
	end
	MoneyFrame_Update("BankFrameDetailMoneyFrame", cost);

	if( full ) then
		purchaseFrame:Hide();
	else
		purchaseFrame:Show();
	end
end

function CloseBankBagFrames() 
	for i=NUM_BAG_SLOTS+1, (NUM_BAG_SLOTS + NUM_BANKBAGSLOTS), 1 do
		CloseBag(i);
	end
end

function BankFrame_OnEvent(event)
	if ( event == "BANKFRAME_OPENED" ) then
		BankFrameTitleText:SetText(UnitName("npc"));
		SetPortraitTexture(BankPortraitTexture,"npc");
		ShowUIPanel(this);
		if ( not this:IsShown() ) then
			CloseBankFrame();
		end
	elseif ( event == "BANKFRAME_CLOSED" ) then
		HideUIPanel(this);
	elseif ( event == "ITEM_LOCK_CHANGED" ) then
		local bag, slot = arg1, arg2;
		if ( bag == BANK_CONTAINER ) then
			if ( slot <= NUM_BANKGENERIC_SLOTS ) then
				BankFrameItemButton_UpdateLocked(getglobal("BankFrameItem"..slot));
			else
				BankFrameItemButton_UpdateLocked(getglobal("BankFrameBag"..(slot-NUM_BANKGENERIC_SLOTS)));
			end
		end
	elseif ( event == "PLAYERBANKSLOTS_CHANGED" ) then
		local slot = arg1;
		if ( slot <= NUM_BANKGENERIC_SLOTS ) then
			BankFrameItemButton_Update(getglobal("BankFrameItem"..slot));
		else
			BankFrameItemButton_Update(getglobal("BankFrameBag"..(slot-NUM_BANKGENERIC_SLOTS)));
		end
	elseif ( event == "PLAYER_MONEY" or event == "PLAYERBANKBAGSLOTS_CHANGED" ) then
		UpdateBagSlotStatus();
	end
end

function BankFrame_OnShow()
	PlaySound("igMainMenuOpen");

	this:RegisterEvent("ITEM_LOCK_CHANGED");
	this:RegisterEvent("PLAYERBANKSLOTS_CHANGED");
	this:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED");
	this:RegisterEvent("PLAYER_MONEY");

	for i=1, NUM_BANKGENERIC_SLOTS, 1 do
		button = getglobal("BankFrameItem"..i);
		BankFrameItemButton_Update(button);
	end
	for i=1, NUM_BANKBAGSLOTS, 1 do
		button = getglobal("BankFrameBag"..i);
		BankFrameItemButton_Update(button);
	end
	UpdateBagSlotStatus();
end

function BankFrame_OnHide()
	PlaySound("igMainMenuClose");

	this:UnregisterEvent("ITEM_LOCK_CHANGED");
	this:UnregisterEvent("PLAYERBANKSLOTS_CHANGED");
	this:UnregisterEvent("PLAYERBANKBAGSLOTS_CHANGED");
	this:UnregisterEvent("PLAYER_MONEY");

	StaticPopup_Hide("CONFIRM_BUY_BANK_SLOT");
	CloseBankBagFrames();
	CloseBankFrame();
	updateContainerFrameAnchors();
end

function BankFrameItemButtonGeneric_OnClick(button)
	if ( button == "LeftButton" ) then
		PickupContainerItem(BANK_CONTAINER, this:GetID());
	else
		UseContainerItem(BANK_CONTAINER, this:GetID());
	end
end

function BankFrameItemButtonGeneric_OnModifiedClick(button)
	if ( this.isBag ) then
		return;
	end
	if ( HandleModifiedItemClick(GetContainerItemLink(BANK_CONTAINER, this:GetID())) ) then
		return;
	end
	if ( IsModifiedClick("SPLITSTACK") ) then
		local texture, itemCount, locked = GetContainerItemInfo(BANK_CONTAINER, this:GetID());
		if ( not locked ) then
			OpenStackSplitFrame(this.count, this, "BOTTOMLEFT", "TOPLEFT");
		end
		return;
	end
end

function UpdateBagButtonHighlight(id) 
	local texture = getglobal("BankFrameBag"..(id - NUM_BAG_SLOTS).."HighlightFrameTexture");
	if ( not texture ) then
		return;
	end

	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local frame = getglobal("ContainerFrame"..i);
		if ( ( frame:GetID() == id ) and frame:IsShown() ) then
			texture:Show();
			return;
		end
	end
	texture:Hide();
end

function BankFrameItemButtonBag_OnClick(button) 
	local inventoryID = this:GetInventorySlot();
	local hadItem = PutItemInBag(inventoryID);
	local id = this:GetID();
	if ( not hadItem ) then
		-- open bag
		ToggleBag(id);
	end
	UpdateBagButtonHighlight(id);
end

function BankFrameItemButtonBag_Pickup()
	local inventoryID = this:GetInventorySlot();
	PickupBagFromSlot(inventoryID);
	UpdateBagButtonHighlight(this:GetID());
end