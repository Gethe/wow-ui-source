local ItemBeltCommandPrefix = "WOWLABS_ITEM";

ItemBeltFrameMixin = { }
function ItemBeltFrameMixin:OnLoad()
	self.itemButtonPool = CreateFramePool("ItemButton", self, "ItemBeltButtonTemplate");
	self.bagID = Enum.BagIndex.Backpack;

	-- For now we only allow a single item.
	self:SetNumItemButtons(1);
end

function ItemBeltFrameMixin:SetNumItemButtons(numItemButton)
	self.numItemButtons = numItemButton;
	self:SetupItems();
end 

function ItemBeltFrameMixin:OnEvent(event, ...)
	if (event == "UPDATE_BINDINGS" or event == "GAME_PAD_ACTIVE_CHANGED" or 
		event == "BAG_NEW_ITEMS_UPDATED" or event == "UNIT_INVENTORY_CHANGED" or
		event == "BAG_UPDATE" or event == "ITEM_LOCK_CHANGED") then
		self:UpdateItems();
	elseif event == "WOW_LABS_BACKPACK_SIZE_CHANGED" then
		local newBackpackSize = ...;
		self:SetNumItemButtons(newBackpackSize); 
	elseif event == "SPECTATE_BEGIN" or event == "SPECTATE_END" then
		self:UpdateSpectateState();
	end
end

function ItemBeltFrameMixin:SetupItems()
	self.itemButtonPool:ReleaseAll(); 

	local refresh = ContinuableContainer:Create();
	self.refresh = refresh;

	for i = 1, self.numItemButtons do 
		local itemButton = self.itemButtonPool:Acquire(); 
		itemButton.layoutIndex = i; 
		itemButton.commandName = ItemBeltCommandPrefix .. i; 

		-- AubrieTODO: Update to a object based system on the item belt, which stores on the ItemBeltFrame
		_G["ContainerFrame1Item" .. i] = itemButton;

		local itemInfo = C_Container.GetContainerItemInfo(self.bagID, itemButton.layoutIndex); 
		itemButton:UpdateItem(itemInfo);
		itemButton:Show();

		local item = Item:CreateFromBagAndSlot(self.bagID, itemButton.layoutIndex);

		if not item:IsItemEmpty() then
			refresh:AddContinuable(item);
		end
	end 

	refresh:ContinueOnLoad(function()
		self.refresh = nil;
		self:UpdateItems();
	end);

	self:MarkDirty(); 
end 

function ItemBeltFrameMixin:UpdateItems()
	for itemButton in self.itemButtonPool:EnumerateActive() do 
		local itemInfo = C_Container.GetContainerItemInfo(self.bagID, itemButton.layoutIndex); 
		itemButton:UpdateItem(itemInfo);
	end 
	self:MarkDirty(); 
end 

function ItemBeltFrameMixin:OnShow()
	self:RegisterEvent("WOW_LABS_BACKPACK_SIZE_CHANGED");
	self:RegisterEvent("UPDATE_BINDINGS");
	self:RegisterEvent("GAME_PAD_ACTIVE_CHANGED");
	self:RegisterEvent("BAG_NEW_ITEMS_UPDATED");
	self:RegisterEvent("UNIT_INVENTORY_CHANGED");
	self:RegisterEvent("ITEM_LOCK_CHANGED");
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("SPECTATE_BEGIN");
	self:RegisterEvent("SPECTATE_END");

	self:UpdateSpectateState();
end

function ItemBeltFrameMixin:OnHide()
	self:UnregisterEvent("WOW_LABS_BACKPACK_SIZE_CHANGED");
	self:UnregisterEvent("UPDATE_BINDINGS");
	self:UnregisterEvent("GAME_PAD_ACTIVE_CHANGED");
	self:UnregisterEvent("BAG_NEW_ITEMS_UPDATED");
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED");
	self:UnregisterEvent("ITEM_LOCK_CHANGED");
	self:UnregisterEvent("BAG_UPDATE");
	self:UnregisterEvent("SPECTATE_BEGIN");
	self:UnregisterEvent("SPECTATE_END");
end

function ItemBeltFrameMixin:UpdateSpectateState()
	for itemButton in self.itemButtonPool:EnumerateActive() do 
		itemButton:UpdateSpectateState();
	end 
end

ItemBeltButtonMixin = { };
function ItemBeltButtonMixin:OnLoad()
	self:RegisterForDrag("LeftButton", "RightButton");
end		

function ItemBeltButtonMixin:OnDragStart(button)
	C_Container.PickupContainerItem(self:GetBagID(), self:GetID());
end

function ItemBeltButtonMixin:OnReceiveDrag()
	self:OnDragStart();
end

function ItemBeltButtonMixin:GetBagID() 
	return self:GetParent().bagID; 
end		

function ItemBeltButtonMixin:GetID()
	return self.layoutIndex; 
end		

function ItemBeltButtonMixin:ActualClick(button)
	C_Container.UseContainerItem(self:GetBagID(), self:GetID());
end		

function ItemBeltButtonMixin:OnClick(button)
	local modifiedClick = IsModifiedClick();
	-- If we can loot the item and autoloot toggle is active, then do a normal click
	if ( button ~= "LeftButton" and modifiedClick and IsModifiedClick("AUTOLOOTTOGGLE") ) then
		local info = C_Container.GetContainerItemInfo(self:GetBagID(), self:GetID());
		local lootable = info and info.hasLoot;
		if ( lootable ) then
			modifiedClick = false;
		end
	end
	if ( modifiedClick ) then
		self:OnModifiedClick(button);
	else
		self:ActualClick(button);
	end
end

function ItemBeltButtonMixin:OnModifiedClick(button)
	local itemLocation = ItemLocation:CreateFromBagAndSlot(self:GetBagID(), self:GetID());
	if ( HandleModifiedItemClick(C_Container.GetContainerItemLink(self:GetBagID(), self:GetID()), itemLocation) ) then
		return;
	end
end

function ItemBeltButtonMixin:SetHasItem(hasItem)
	if hasItem then
		self.hasItem = 1;
	else
		self.hasItem = nil;
	end
end

function ItemBeltButtonMixin:UpdateCooldown(hasItem)
	self:SetHasItem(hasItem);

	if hasItem then
		local start, duration, enable = C_Container.GetContainerItemCooldown(self:GetBagID(), self:GetID());
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

function ItemBeltButtonMixin:UpdateItem(itemInfo) 
	local texture = itemInfo and itemInfo.iconFileID;
	self:SetItemButtonTexture(texture);
	SetItemButtonCount(self, itemInfo and itemInfo.stackCount);
	self:UpdateCooldown(texture);
	self:UpdateHotkey();
end 

function ItemBeltButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 100);
	GameTooltip:SetBagItem(self:GetBagID(), self:GetID());
	GameTooltip:Show(); 
end

function ItemBeltButtonMixin:OnLeave()
	GameTooltip:Hide(); 
end

function ItemBeltButtonMixin:OnDragStop()
	if(not self:IsMouseOver()) then 
		return;
	end 
	DeleteCursorItem();
end

function ItemBeltButtonMixin:UpdateHotkey()
    local hotkey = self.HotKey;
	if C_SpectatingUI.IsSpectating() then
		hotkey:Hide();
		return;
	end

    local key;
	if self.commandName then
		key = GetBindingKey( self.commandName );
		local text = GetBindingText(key, 0);
		if ( text == "" ) then
			hotkey:SetText(RANGE_INDICATOR);
			hotkey:Hide();
		else
			hotkey:SetText(text);
			hotkey:Show();
		end
    end
end

function ItemBeltButtonMixin:UpdateSpectateState()
	local isSpectating = C_SpectatingUI.IsSpectating();
	self:SetEnabled(not isSpectating);
	self.HotKey:SetShown(not isSpectating);
end
