BANK_CONTAINER = -1;
NUM_BAG_SLOTS = 4;
NUM_BANKGENERIC_SLOTS = 24;
NUM_BANKBAGSLOTS = 6;

function BankFrameBaseButton_OnLoad() 
	this:RegisterEvent("BANKFRAME_OPENED");
	this:RegisterEvent("PLAYERBANKSLOTS_CHANGED");
	this:RegisterEvent("ITEM_LOCK_CHANGED");
	this:RegisterEvent("CURSOR_UPDATE");
	this:RegisterForDrag("LeftButton");
	this:RegisterForClicks("LeftButtonUp","RightButtonUp");
	this.GetInventorySlot = ButtonInventorySlot;
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

function ButtonInventorySlot()
	return BankButtonIDToInvSlotID(this:GetID(),this.isBag)
end

function BankFrameItemButton_OnUpdate() 
	local texture = getglobal(this:GetName().."IconTexture");
	local inventoryID = this:GetInventorySlot();
	local textureName = GetInventoryItemTexture("player",inventoryID);
	local slotName = this:GetName();
	local id;
	local slotTextureName;
	this.hasItem = nil;

	if( this.isBag ) then
		id, slotTextureName = GetInventorySlotInfo(strsub(slotName,10));
	end

	if ( textureName ) then
		texture:SetTexture(textureName);
		texture:Show();
		SetItemButtonCount(this,GetInventoryItemCount("player",inventoryID));
		this.hasItem = 1;
	elseif ( slotTextureName and this.isBag ) then
		texture:SetTexture(slotTextureName);
		SetItemButtonCount(this,0);
		texture:Show();
	else 
		texture:Hide();
		SetItemButtonCount(this,0);
	end

	if ( GameTooltip:IsOwned(this) ) then
		if ( textureName ) then
            if ( not GameTooltip:SetInventoryItem("player", this:GetInventorySlot()) ) then
				if ( this.isBag ) then
					GameTooltip:SetText(TEXT(BANK_BAG));
				end
			end
		else
			GameTooltip:Hide();
		end
	end

	BankFrameItemButton_UpdateLock();
end

function BankFrame_OnLoad()
	this:RegisterEvent("BANKFRAME_OPENED");
	this:RegisterEvent("BANKFRAME_CLOSED");
	this:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED");
	this:RegisterEvent("PLAYER_MONEY");
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
		if ( not this:IsVisible() ) then
			CloseBankFrame();
		end
		UpdateBagSlotStatus();
	elseif ( event == "BANKFRAME_CLOSED" ) then
		HideUIPanel(this);
	elseif ( event == "PLAYER_MONEY" or event == "PLAYERBANKBAGSLOTS_CHANGED" ) then
		UpdateBagSlotStatus();
	end
end

function BankFrameItemButtonGeneric_OnClick(button)
	if ( button == "LeftButton" ) then
		if ( IsControlKeyDown() and not this.isBag ) then
			DressUpItemLink(GetContainerItemLink(BANK_CONTAINER, this:GetID()));
		elseif ( IsShiftKeyDown() and not this.isBag ) then
			if ( ChatFrameEditBox:IsVisible() ) then
				ChatFrameEditBox:Insert(GetContainerItemLink(BANK_CONTAINER, this:GetID()));
			else
				local texture, itemCount, locked = GetContainerItemInfo(BANK_CONTAINER, this:GetID());
				if ( not locked ) then
					OpenStackSplitFrame(this.count, this, "BOTTOMLEFT", "TOPLEFT");
				end
			end
		else
			PickupContainerItem(BANK_CONTAINER, this:GetID());
		end
	else
		if ( IsControlKeyDown() and not this.isBag ) then
			return;
		elseif ( IsShiftKeyDown() and not this.isBag ) then
			local texture, itemCount, locked = GetContainerItemInfo(BANK_CONTAINER, this:GetID());
			if ( not locked ) then
				OpenStackSplitFrame(this.count, this, "BOTTOMLEFT", "TOPLEFT");
			end
		else
			UseContainerItem(BANK_CONTAINER, this:GetID());
		end
	end
end

function UpdateBagButtonHighlight(id) 
	local texture = getglobal("BankFrameBag"..(id - NUM_BAG_SLOTS).."HighlightFrameTexture");
	if ( not texture ) then
		return;
	end

	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local frame = getglobal("ContainerFrame"..i);
		if ( ( frame:GetID() == id ) and frame:IsVisible() ) then
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
		PlaySound("BAGMENUBUTTONPRESS");
	end
	UpdateBagButtonHighlight(id);
end

function BankFrameItemButtonBag_OnShiftClick()
	local inventoryID = this:GetInventorySlot();
	PickupBagFromSlot(inventoryID);
	PlaySound("BAGMENUBUTTONPRESS");
	UpdateBagButtonHighlight(this:GetID());
end

function BankFrameItemButton_OnEvent(event) 
	if ( event == "PLAYERBANKSLOTS_CHANGED" or event == "BANKFRAME_OPENED" ) then
		BankFrameItemButton_OnUpdate();
	elseif ( event == "ITEM_LOCK_CHANGED" ) then
		BankFrameItemButton_UpdateLock();
	end
end

function BankFrameItemButton_UpdateLock() 
	local inventoryID = this:GetInventorySlot();
	if ( IsInventoryItemLocked(inventoryID) ) then
		SetItemButtonDesaturated(this, 1, 0.5, 0.5, 0.5);
	else 
		if ( this.isBag and ((this:GetID() - 4) > GetNumBankSlots()) ) then
			return;	
		end
		SetItemButtonDesaturated(this, nil, 0.5, 0.5, 0.5);
	end
end