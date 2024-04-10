BANK_PANELS = {
	{ name = "BankSlotsFrame", size = {x=386, y=415}, SetTitle=function() BankFrame:SetTitle(UnitName("npc")); end },
	{ name = "ReagentBankFrame", size = {x=738, y=415}, SetTitle=function() BankFrame:SetTitle(REAGENT_BANK); end },
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
		C_Container.SplitContainerItem(button:GetParent():GetID(), button:GetID(), split);
	end
end

function BankFrameBagButton_OnLoad (self)
	self.isBag = 1;
	BankFrameBaseButton_OnLoad(self);
	self:RegisterEvent("INVENTORY_SEARCH_UPDATE");

	self:SetBagID(self:GetID() + NUM_BAG_FRAMES + NUM_REAGENTBAG_FRAMES);

	local function UpdateBagHighlight(owner, container)
		if self:GetBagID() == container:GetBagID() then
			self.SlotHighlightTexture:SetShown(container:IsShown());
		end
	end

	EventRegistry:RegisterCallback("ContainerFrame.CloseBag", UpdateBagHighlight, self);
	EventRegistry:RegisterCallback("ContainerFrame.OpenBag", UpdateBagHighlight, self);

	self:RegisterBagButtonUpdateItemContextMatching();
end

function BankFrameBagButton_OnEvent (self, event, ...)
	if ( event == "INVENTORY_SEARCH_UPDATE" ) then
		if ( C_Container.IsContainerFiltered(self:GetID()+NUM_TOTAL_EQUIPPED_BAG_SLOTS) ) then
			self.searchOverlay:Show();
		else
			self.searchOverlay:Hide();
		end
	end
end

BankItemButtonBagMixin = {};

function BankItemButtonBagMixin:GetItemContextMatchResult()
	return ItemButtonUtil.GetItemContextMatchResultForContainer(self:GetID() + NUM_TOTAL_EQUIPPED_BAG_SLOTS);
end

function BankFrameItemButton_OnEnter (self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	local hasItem = GameTooltip:SetInventoryItem("player", self:GetInventorySlot());
	if (self.isBag) then
		if ContainerFrame_CanContainerUseFilterMenu(self:GetBagID()) then
			for i, flag in ContainerFrameUtil_EnumerateBagGearFilters() do
				if C_Container.GetBagSlotFlag(self:GetID() + NUM_BAG_SLOTS, flag) then -- [NB] TODO: Bank bags should use actual bank bag ids rather than translating in place or using a different API.
					GameTooltip:AddLine(BAG_FILTER_ASSIGNED_TO:format(BAG_FILTER_LABELS[flag]));
					break;
				end
			end
		end
	end

	if ( not hasItem ) then
		if ( self.isBag ) then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
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
		container = Enum.BagIndex.Bankbag;
	end
	local texture = button.icon;
	local inventoryID = button:GetInventorySlot();
	local textureName = GetInventoryItemTexture("player",inventoryID);
	local info = C_Container.GetContainerItemInfo(container, buttonID);
	local quality = info and info.quality;
	local isFiltered = info and info.isFiltered;
	local itemID = info and info.itemID;
	local isBound = info and info.isBound;
	local slotName = button:GetName();
	local id;
	local slotTextureName;
	button.hasItem = nil;

	if( button.isBag ) then
		id, slotTextureName = GetInventorySlotInfo("Bag"..buttonID);
	else
		local questInfo = C_Container.GetContainerItemQuestInfo(container, buttonID);
		local isQuestItem = questInfo.isQuestItem;
		local questId = questInfo.questID;
		local isActive = questInfo.isActive;
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

	button:UpdateItemContextMatching();
	button:SetMatchesSearch(not isFiltered);

	local doNotSuppressOverlays = false;
	SetItemButtonQuality(button, quality, itemID, doNotSuppressOverlays, isBound);

	BankFrameItemButton_UpdateLocked(button);
	BankFrame_UpdateCooldown(container, button);
end

BankItemButtonMixin = {};

function BankItemButtonMixin:GetItemContextMatchResult()
	return ItemButtonUtil.GetItemContextMatchResultForItem(ItemLocation:CreateFromBagAndSlot(self:GetParent():GetID(), self:GetID()));
end

function BankItemButtonMixin:GetBagID()
	if self.isBag then
		return -4;
	else
		return self:GetParent():GetID();
	end
end

function BankFrame_UpdateCooldown(container, button)
	local cooldown = button.Cooldown;
	local start, duration, enable;
	if ( button.isBag ) then
		-- in case we ever have a bag with a cooldown...
		local inventoryID = C_Container.ContainerIDToInventoryID(button:GetID());
		start, duration, enable = GetInventoryItemCooldown("player", inventoryID);
	else
		start, duration, enable = C_Container.GetContainerItemCooldown(container, button:GetID());
	end
	CooldownFrame_Set(cooldown, start, duration, enable);
	if ( duration and duration > 0 and enable == 0 ) then
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

	local parent = self:GetParent();
	parent:SetBagSize(Constants.InventoryConstants.NumGenericBankSlots); -- This onload runs first
	self["Item1"] = self.Item1; -- For consistency
	parent["Item1"] = self.Item1; -- So that enumerateItems will work

	--Create bank item buttons, button background textures, and rivets between buttons
	for i = 2, self:GetParent():GetBagSize() do
		local button = CreateFrame("ItemButton", "BankFrameItem"..i, self, "BankItemButtonGenericTemplate");
		button:SetID(i);
		self["Item"..i] = button;
		parent["Item"..i] = button;
		if ((i%7) == 1) then
			button:SetPoint("TOPLEFT", self["Item"..(i-7)], "BOTTOMLEFT", 0, -7);
		else
			button:SetPoint("TOPLEFT", self["Item"..(i-1)], "TOPRIGHT", 12, 0);
		end
	end

	for i = 1, self:GetParent():GetBagSize() do
		local texture = self:CreateTexture(nil, "BORDER", "Bank-Slot-BG");
		texture:SetPoint("TOPLEFT", self["Item"..i], "TOPLEFT", -6, 5);
		texture:SetPoint("BOTTOMRIGHT", self["Item"..i], "BOTTOMRIGHT", 6, -7);
	end

	for i = 1, 7 do
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
	self:SetBagSize(Constants.InventoryConstants.NumGenericBankSlots);
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
	for i=NUM_TOTAL_EQUIPPED_BAG_SLOTS+1, (NUM_TOTAL_EQUIPPED_BAG_SLOTS + NUM_BANKBAGSLOTS), 1 do
		CloseBag(i);
	end
end

function BankFrame_Open()
	BankFrame_ShowPanel(BANK_PANELS[1].name);
	BankFrame:SetPortraitToUnit("npc");
	ShowUIPanel(BankFrame);
	if ( not BankFrame:IsShown() ) then
		CloseBankFrame();
	end
end

function BankFrame_OnEvent (self, event, ...)
	if ( event == "ITEM_LOCK_CHANGED" ) then
		local bag, slot = ...;
		if ( bag == BANK_CONTAINER ) then
			if ( slot <= NUM_BANKGENERIC_SLOTS ) then
				BankFrameItemButton_UpdateLocked(BankSlotsFrame["Item"..slot]);
			else
				BankFrameItemButton_UpdateLocked(BankSlotsFrame["Bag"..(slot-NUM_BANKGENERIC_SLOTS)]);
			end
		elseif ( bag == REAGENTBANK_CONTAINER ) then
			local button = ReagentBankFrame["Item"..(slot)];
			if (button) then
				BankFrameItemButton_UpdateLocked(button);
			end
		end
	elseif ( event == "PLAYERBANKSLOTS_CHANGED" ) then
		local slot = ...;
		if ( slot <= NUM_BANKGENERIC_SLOTS ) then
			BankFrameItemButton_Update(BankSlotsFrame["Item"..slot]);
		else
			BankFrameItemButton_Update(BankSlotsFrame["Bag"..(slot-NUM_BANKGENERIC_SLOTS)]);
		end
	elseif ( event == "PLAYERREAGENTBANKSLOTS_CHANGED" ) then
		local slot = ...;
		BankFrameItemButton_Update(ReagentBankFrame["Item"..(slot)]);
	elseif ( event == "PLAYER_MONEY" or event == "PLAYERBANKBAGSLOTS_CHANGED" ) then
		UpdateBagSlotStatus();
	elseif ( event == "INVENTORY_SEARCH_UPDATE" ) then
		self:UpdateSearchResults();
		ReagentBankFrame:UpdateSearchResults();
	end
end

function BankFrame_UpdateItems(self)
	for i=1, NUM_BANKGENERIC_SLOTS, 1 do
		local button = BankSlotsFrame["Item"..i];
		BankFrameItemButton_Update(button);
	end
end

function BankFrame_OnShow (self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);

	self:RegisterEvent("ITEM_LOCK_CHANGED");
	self:RegisterEvent("PLAYERBANKSLOTS_CHANGED");
	self:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED");
	self:RegisterEvent("PLAYERBANKBAGSLOTS_CHANGED");
	self:RegisterEvent("PLAYER_MONEY");
	self:RegisterEvent("BAG_UPDATE_COOLDOWN");
	self:RegisterEvent("INVENTORY_SEARCH_UPDATE");

	BankFrame_UpdateItems(self);

	for i=1, NUM_BANKBAGSLOTS, 1 do
		local button = BankSlotsFrame["Bag"..i];
		BankFrameItemButton_Update(button);
	end
	UpdateBagSlotStatus();
	OpenAllBags(self);

	if (not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_REAGENT_BANK_UNLOCK)) then
		if (not IsReagentBankUnlocked()) then
			local helpTipInfo = {
				text = REAGENT_BANK_HELP,
				buttonStyle = HelpTip.ButtonStyle.Close,
				cvarBitfield = "closedInfoFrames",
				bitfieldFlag = LE_FRAME_TUTORIAL_REAGENT_BANK_UNLOCK,
				targetPoint = HelpTip.Point.RightEdgeCenter,
				offsetX = -2,
			};
			HelpTip:Show(self, helpTipInfo, BankFrameTab2);
		end
	end
end

function BankFrame_OnHide (self)
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);

	self:UnregisterEvent("ITEM_LOCK_CHANGED");
	self:UnregisterEvent("PLAYERBANKSLOTS_CHANGED");
	self:UnregisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED");
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
		C_Container.PickupContainerItem(container, self:GetID());
	else
		C_Container.UseContainerItem(container, self:GetID());
	end
end

function BankFrameItemButtonGeneric_OnModifiedClick (self, button)
	local container = self:GetParent():GetID();
	if ( self.isBag ) then
		return;
	end
	local itemLocation = ItemLocation:CreateFromBagAndSlot(container, self:GetID());
	if ( HandleModifiedItemClick(C_Container.GetContainerItemLink(container, self:GetID()), itemLocation) ) then
		return;
	end
	if ( not CursorHasItem() and IsModifiedClick("SPLITSTACK") ) then
		local info = C_Container.GetContainerItemInfo(container, self:GetID());
		local itemCount = info.stackCount;
		local locked = info.isLocked;
		if ( not locked and itemCount and itemCount > 1) then
			StackSplitFrame:OpenStackSplitFrame(self.count, self, "BOTTOMLEFT", "TOPLEFT");
		end
		return;
	end
end

function BankFrameItemButtonBag_OnClick (self, button)
	local inventoryID = self:GetInventorySlot();
	local hadItem = PutItemInBag(inventoryID);
	local id = self:GetID();
	if ( not hadItem ) then
		-- open bag
		ToggleBag(id+NUM_TOTAL_EQUIPPED_BAG_SLOTS);
	end
end

function BankFrameItemButtonBag_Pickup (self)
	local inventoryID = self:GetInventorySlot();
	PickupBagFromSlot(inventoryID);
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
	PanelTemplates_SetTab(self, tabIndex);
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
		C_Container.SortBankBags();
	elseif (self.activeTabIndex == 2) then
		C_Container.SortReagentBankBags();
	end
end

-- Reagent Bank
function ReagentBankFrame_OnLoad(self)
	self:SetID(REAGENTBANK_CONTAINER);
	self:SetBagSize(0);
	self:RegisterEvent("REAGENTBANK_PURCHASED");
end

function ReagentBankFrame_OnEvent(self, event, ...)
	if(event == "REAGENTBANK_PURCHASED")then
		ReagentBankFrame.UnlockInfo:Hide();
		ReagentBankFrame.DespositButton:Enable();
	end
end

function ReagentBankFrame_OnShow(self)
	HelpTip:Hide(BankFrame, REAGENT_BANK_HELP);
	SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_REAGENT_BANK_UNLOCK, true);

	if(not IsReagentBankUnlocked()) then
		ReagentBankFrame.UnlockInfo:Show();
		MoneyFrame_Update( ReagentBankFrame.UnlockInfo.CostMoneyFrame, GetReagentBankCost());
		ReagentBankFrame.DespositButton:Disable();
	else
		ReagentBankFrame.UnlockInfo:Hide();
		ReagentBankFrame.DespositButton:Enable();
	end

	if( not self.slots_initialized ) then
		self.slots_initialized = true;
		self.numRow = 7;
		self.numColumn = 7;
		self.numSubColumn = 2;
		self:SetBagSize(self.numRow*self.numColumn*self.numSubColumn);

		-- setup slot backgrounds and shadows
		for column = 2, self.numColumn do
			local texture = ReagentBankFrame:CreateTexture(nil, "ARTWORK");
			ReagentBankFrame["BG"..(column)] = texture;
			texture:SetPoint("TOPLEFT", ReagentBankFrame["BG"..(column-1)], "TOPRIGHT", 5, 0);
			texture:SetAtlas("bank-slots", true);
			local shadow = ReagentBankFrame:CreateTexture(nil, "BACKGROUND");
			shadow:SetPoint("CENTER", ReagentBankFrame["BG"..(column)], "CENTER", 0, 0);
			shadow:SetAtlas("bank-slots-shadow", true);
		end

		-- the item slots
		local slotOffsetX = 49;
		local slotOffsetY = 44;
		local id = 1;
		for column = 1, self.numColumn do
			local leftOffset = 6;
			for subColumn = 1, self.numSubColumn do
				for row = 0, self.numRow-1 do
					local button = CreateFrame("ItemButton", "ReagentBankFrameItem"..id, ReagentBankFrame, "ReagentBankItemButtonGenericTemplate");
					button:SetID(id);
					button:SetPoint("TOPLEFT", ReagentBankFrame["BG"..column], "TOPLEFT", leftOffset, -(3+row*slotOffsetY));
					ReagentBankFrame["Item"..id] = button;
					id = id + 1;
				end
				leftOffset = leftOffset + slotOffsetX;
			end
		end
	end

	for index, button in self:EnumerateItems() do
		BankFrameItemButton_Update(button);
	end
end


function ReagentButtonInventorySlot (self)
	return ReagentBankButtonIDToInvSlotID(self:GetID());
end

function ReagentBankFrameBaseButton_OnLoad (self)
	self:RegisterForDrag("LeftButton");
	self:RegisterForClicks("LeftButtonUp","RightButtonUp");
	self.GetInventorySlot = ReagentButtonInventorySlot;
	self.UpdateTooltip = BankFrameItemButton_OnEnter;
end

function ReagentBankFrameItemButton_OnLoad(self)
	ReagentBankFrameBaseButton_OnLoad (self);
	self.SplitStack = function(button, split)
		C_Container.SplitContainerItem(REAGENTBANK_CONTAINER, button:GetID(), split);
	end
end

BankFrameMixin = CreateFromMixins(BaseContainerFrameMixin);

do
	local function iterator(container, index)
		index = index + 1;
		if index <= container:GetBagSize() then
			return index, container["Item"..index];
		end
	end

	function BankFrameMixin:EnumerateValidItems()
		return iterator, self, 0;
	end

	function BankFrameMixin:EnumerateItems()
		return self:EnumerateValidItems();
	end
end