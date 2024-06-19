local PURCHASE_TAB_ID = -1;

BANK_PANELS = {
	{ name = "BankSlotsFrame", size = {x=386, y=460}, SetTitle=function() BankFrame:SetTitle(UnitName("npc")); end, bankType = Enum.BankType.Character },
	{ name = "ReagentBankFrame", size = {x=738, y=460}, SetTitle=function() BankFrame:SetTitle(REAGENT_BANK); end, bankType = Enum.BankType.Character },
	{ name = "AccountBankPanel", size = {x=738, y=460}, SetTitle=function() BankFrame:SetTitle(ACCOUNT_BANK_PANEL_TITLE); end, bankType = Enum.BankType.Account },
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
		local bagID = self:GetBagID();
		if ContainerFrame_CanContainerUseFilterMenu(bagID) then
			local filterList = ContainerFrameSettingsManager:GenerateFilterList(bagID);
			if filterList then
				local wrapText = true;
				GameTooltip_AddNormalLine(GameTooltip, BAG_FILTER_ASSIGNED_TO:format(filterList), wrapText);
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

local function GetViewableBankTypes()
	local usableBankTypes = {};
	for key, bankType in pairs(Enum.BankType) do
		if C_Bank.CanViewBank(bankType) then
			table.insert(usableBankTypes, bankType);
		end
	end

	return usableBankTypes;
end

local function HasAnyViewableBankTypes()
	return #GetViewableBankTypes() > 0;
end

local function RefreshBankTabVisibility()
	local usableBankTabIndicies = {};
	for index, panelData in pairs(BANK_PANELS) do
		if C_Bank.CanViewBank(panelData.bankType) then
			table.insert(usableBankTabIndicies, index);
		end
	end

	local hasMultipleTabs = #usableBankTabIndicies > 1;
	for index, panelData in pairs(BANK_PANELS) do
		PanelTemplates_SetTabShown(BankFrame, index, hasMultipleTabs and tContains(usableBankTabIndicies, index));
	end

	local firstUsableTab = BANK_PANELS[usableBankTabIndicies[1]];
	BankFrame_ShowPanel(firstUsableTab.name);
end

function BankFrame_Open()
	if not HasAnyViewableBankTypes() then
		HideUIPanel(BankFrame);
		C_Bank.CloseBankFrame();
		UIErrorsFrame:AddExternalErrorMessage(ERR_BANK_NOT_ACCESSIBLE);
		return;
	end

	RefreshBankTabVisibility();

	BankFrame:SetPortraitToUnit("npc");
	ShowUIPanel(BankFrame);
	if ( not BankFrame:IsShown() ) then
		C_Bank.CloseBankFrame();
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

	if C_Bank.CanViewBank(Enum.BankType.Character) and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_REAGENT_BANK_UNLOCK) then
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
	C_Bank.CloseBankFrame();
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
	BankFrame_UpdateAnchoringForPanel();
end

function BankFrame_UpdateAnchoringForPanel()
	local accountBankSelected = BankFrame.activeTabIndex == 3;
	local xOffset, yOffset = accountBankSelected and -56 or -48, -33;
	BankItemSearchBox:SetPoint("TOPRIGHT", BankItemSearchBox:GetParent(), "TOPRIGHT", xOffset, yOffset);
end

function BankFrame_AutoSortButtonOnClick()
	local self = BankFrame;

	PlaySound(SOUNDKIT.UI_BAG_SORTING_01);
	if (self.activeTabIndex == 1) then
		C_Container.SortBankBags();
	elseif (self.activeTabIndex == 2) then
		C_Container.SortReagentBankBags();
	elseif (self.activeTabIndex == 3) then
		local textArg1, textArg2 = nil, nil;
		StaticPopup_Show("BANK_CONFIRM_CLEANUP", textArg1, textArg2, { bankType = self:GetActiveBankType() });
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

BankPanelSystemMixin = {};

function BankPanelSystemMixin:GetBankFrame()
	return AccountBankPanel;
end

function BankPanelSystemMixin:GetBankTabSettingsMenu()
	return self:GetBankFrame().TabSettingsMenu;
end

function BankPanelSystemMixin:GetActiveBankType()
	return self:GetBankFrame():GetBankType();
end

function BankPanelSystemMixin:IsActiveBankTypeLocked()
	return self:GetBankFrame():IsBankTypeLocked();
end

StaticPopupDialogs["CONFIRM_BUY_BANK_TAB"] = {
	text = CONFIRM_BUY_ACCOUNT_BANK_TAB,
	wide = true,
	wideText = true,

	button1 = YES,
	button2 = NO,

	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1,

	OnAccept = function(self)
		C_Bank.PurchaseBankTab(self.data.bankType);
	end,
	OnShow = function(self)
		local tabCost = C_Bank.FetchNextPurchasableBankTabCost(self.data.bankType);
		if tabCost then
			MoneyFrame_Update(self.moneyFrame, tabCost);
		end
	end,
};

StaticPopupDialogs["BANK_MONEY_WITHDRAW"] = {
	text = BANK_MONEY_WITHDRAW_PROMPT,

	button1 = ACCEPT,
	button2 = CANCEL,

	hasMoneyInputFrame = 1,
	timeout = 0,
	hideOnEscape = 1,

	OnAccept = function(self)
		local amountToWithdraw = MoneyInputFrame_GetCopper(self.moneyInputFrame);
		C_Bank.WithdrawMoney(self.data.bankType, amountToWithdraw);
	end,
	OnHide = function(self)
		MoneyInputFrame_ResetMoney(self.moneyInputFrame);
	end,
	EditBoxOnEnterPressed = function(self)
		local staticPopup = self:GetParent():GetParent();
		local amountToWithdraw = MoneyInputFrame_GetCopper(staticPopup.moneyInputFrame);
		C_Bank.WithdrawMoney(staticPopup.data.bankType, amountToWithdraw);
		staticPopup:Hide();
	end,
};

StaticPopupDialogs["BANK_MONEY_DEPOSIT"] = {
	text = BANK_MONEY_DEPOSIT_PROMPT,

	button1 = ACCEPT,
	button2 = CANCEL,

	hasMoneyInputFrame = 1,
	timeout = 0,
	hideOnEscape = 1,

	OnAccept = function(self)
		local amountToDeposit = MoneyInputFrame_GetCopper(self.moneyInputFrame);
		C_Bank.DepositMoney(self.data.bankType, amountToDeposit);
	end,
	OnHide = function(self)
		MoneyInputFrame_ResetMoney(self.moneyInputFrame);
	end,
	EditBoxOnEnterPressed = function(self)
		local staticPopup = self:GetParent():GetParent();
		local amountToDeposit = MoneyInputFrame_GetCopper(staticPopup.moneyInputFrame);
		C_Bank.DepositMoney(staticPopup.data.bankType, amountToDeposit);
		staticPopup:Hide();
	end,
};

StaticPopupDialogs["BANK_CONFIRM_CLEANUP"] = {
	text = ACCOUNT_BANK_CONFIRM_CLEANUP_PROMPT,
	wide = true,
	wideText = true,

	button1 = ACCEPT,
	button2 = CANCEL,

	timeout = 0,
	hideOnEscape = 1,

	OnAccept = function(self)
		if self.data.bankType == Enum.BankType.Account then
			C_Container.SortAccountBankBags();
		end
	end,
	OnHide = function(self)
	end,
};

function BankFrameMixin:GetActiveBankType()
	if not self:IsShown() then
		return nil;
	end

	if self.activeTabIndex == 1 then
		return Enum.BankType.Character;
	--elseif self.activeTabIndex == 2 then
		-- Insert reagent bank override if needed here
	elseif self.activeTabIndex == 3 then
		return Enum.BankType.Account;
	end

	return Enum.BankType.Character;
end

BankPanelTabMixin = CreateFromMixins(BankPanelSystemMixin);

local BANK_PANEL_TAB_EVENTS = {
	"INVENTORY_SEARCH_UPDATE",
};

function BankPanelTabMixin:OnLoad()
	self:RegisterForClicks("LeftButtonUp","RightButtonUp");

	self:AddDynamicEventMethod(self:GetBankFrame(), BankPanelMixin.Event.NewBankTabSelected, self.OnNewBankTabSelected);
end

function BankPanelTabMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);
	FrameUtil.RegisterFrameForEvents(self, BANK_PANEL_TAB_EVENTS);
end

function BankPanelTabMixin:OnHide()
	CallbackRegistrantMixin.OnHide(self);
	FrameUtil.UnregisterFrameForEvents(self, BANK_PANEL_TAB_EVENTS);
end

function BankPanelTabMixin:OnEvent(event, ...)
	if event == "INVENTORY_SEARCH_UPDATE" then
		self:RefreshSearchOverlay();
	end
end

function BankPanelTabMixin:OnClick(button)
	if button == "RightButton" and not self:IsPurchaseTab() then
		self:GetBankTabSettingsMenu():TriggerEvent(BankPanelTabSettingsMenuMixin.Event.OpenTabSettingsRequested, self.tabData.ID);
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
	self:GetBankFrame():TriggerEvent(BankPanelMixin.Event.BankTabClicked, self.tabData.ID);
end

function BankPanelTabMixin:OnEnter()
	if not self:IsPurchaseTab() then
		self:ShowTooltip();
	end
end

local function AddBankTabSettingsToTooltip(tooltip, depositFlags)
	if not tooltip or not depositFlags then
		return;
	end

	if FlagsUtil.IsSet(depositFlags, Enum.BagSlotFlags.ExpansionCurrent) then
		GameTooltip_AddNormalLine(tooltip, BANK_TAB_EXPANSION_ASSIGNMENT:format(BANK_TAB_EXPANSION_FILTER_CURRENT));
	elseif FlagsUtil.IsSet(depositFlags, Enum.BagSlotFlags.ExpansionLegacy) then
		GameTooltip_AddNormalLine(tooltip, BANK_TAB_EXPANSION_ASSIGNMENT:format(BANK_TAB_EXPANSION_FILTER_LEGACY));
	end
	
	local filterList = ContainerFrameUtil_ConvertFilterFlagsToList(depositFlags);
	if filterList then
		local wrapText = true;
		GameTooltip_AddNormalLine(tooltip, BANK_TAB_DEPOSIT_ASSIGNMENTS:format(filterList), wrapText);
	end
end

function BankPanelTabMixin:ShowTooltip()
	if not self.tabData then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, self.tabData.name, NORMAL_FONT_COLOR);
	AddBankTabSettingsToTooltip(GameTooltip, self.tabData.depositFlags);
	GameTooltip_AddInstructionLine(GameTooltip, BANK_TAB_TOOLTIP_CLICK_INSTRUCTION);
	GameTooltip:Show();
end

function BankPanelTabMixin:OnLeave()
	GameTooltip_Hide();
end

function BankPanelTabMixin:OnNewBankTabSelected(tabID)
	self:RefreshVisuals();
end

function BankPanelTabMixin:RefreshVisuals()
	local enabled = self:IsEnabled();
	self.Icon:SetDesaturated(not enabled);
	self.SelectedTexture:SetShown(enabled and self:IsSelected());
	self:RefreshSearchOverlay();
end

function BankPanelTabMixin:RefreshSearchOverlay()
	self.SearchOverlay:SetShown(self.tabData.ID and not self:IsPurchaseTab() and C_Container.IsContainerFiltered(self.tabData.ID));
end

function BankPanelTabMixin:Init(tabData)
	if not tabData then
		return;
	end

	self.tabData = tabData;
	if self:IsPurchaseTab() then
		self.Icon:SetAtlas("Garr_Building-AddFollowerPlus", TextureKitConstants.UseAtlasSize);
	else
		self.Icon:SetTexture(self.tabData.icon or QUESTION_MARK_ICON);
	end

	self:RefreshVisuals();
end

function BankPanelTabMixin:IsSelected()
	return self.tabData.ID == self:GetBankFrame():GetSelectedTabID();
end

function BankPanelTabMixin:SetEnabledState(enable)
	self:SetEnabled(enable);
	self:RefreshVisuals();
end

function BankPanelTabMixin:IsPurchaseTab()
	return self.tabData.ID == PURCHASE_TAB_ID;
end

BankPanelPurchaseTabMixin = {};

function BankPanelPurchaseTabMixin:OnLoad()
	BankPanelTabMixin.OnLoad(self);

	local purchaseTabData = {
		ID = PURCHASE_TAB_ID,
	}
	self:Init(purchaseTabData);
end

BankPanelItemButtonMixin = {};

function BankPanelItemButtonMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function BankPanelItemButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetBagItem(self:GetBankTabID(), self:GetContainerSlotID());

	if IsModifiedClick("DRESSUP") then
		ShowInspectCursor();
	end

	self:SetScript("OnUpdate", BankPanelItemButtonMixin.OnUpdate);
end

function BankPanelItemButtonMixin:OnLeave()
	GameTooltip_Hide();
	ResetCursor();

	self:SetScript("OnUpdate", nil);
end

function BankPanelItemButtonMixin:OnClick(button)
	if IsModifiedClick() then
		self:OnModifiedClick(button);
		return;
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
	if ( button == "LeftButton" ) then
		C_Container.PickupContainerItem(self:GetBankTabID(), self:GetContainerSlotID());
	else
		C_Container.UseContainerItem(self:GetBankTabID(), self:GetContainerSlotID());
	end
end

function BankPanelItemButtonMixin:OnModifiedClick()
	local bankTabID, containerSlotID = self:GetBankTabID(), self:GetContainerSlotID();
	if HandleModifiedItemClick(C_Container.GetContainerItemLink(bankTabID, containerSlotID), self:GetItemLocation()) then
		return;
	end

	if not CursorHasItem() and IsModifiedClick("SPLITSTACK") then
		local itemInfo = C_Container.GetContainerItemInfo(bankTabID, containerSlotID);
		local itemCount = itemInfo.stackCount;
		local locked = itemInfo.isLocked;
		if not locked and itemCount and itemCount > 1 then
			StackSplitFrame:OpenStackSplitFrame(self.count, self, "BOTTOMLEFT", "TOPLEFT");
		end
	end
end

function BankPanelItemButtonMixin:OnDragStart()
	C_Container.PickupContainerItem(self:GetBankTabID(), self:GetContainerSlotID());
end

function BankPanelItemButtonMixin:OnReceiveDrag()
	C_Container.PickupContainerItem(self:GetBankTabID(), self:GetContainerSlotID());
end

function BankPanelItemButtonMixin:OnUpdate()
	if GameTooltip:IsOwned(self) then
		if IsModifiedClick("DRESSUP") then
			ShowInspectCursor();
		else
			ResetCursor();
		end
	end
end

function BankPanelItemButtonMixin:SetBankTabID(bankTabID)
	self.bankTabID = bankTabID;
end

function BankPanelItemButtonMixin:GetBankTabID()
	return self.bankTabID;
end

function BankPanelItemButtonMixin:Init(bankTabID, containerSlotID)
	self:SetBankTabID(bankTabID);
	self:SetContainerSlotID(containerSlotID);
	self:InitItemLocation();
	self.isInitialized = true;

	self:Refresh();
end

function BankPanelItemButtonMixin:SetContainerSlotID(containerSlotID)
	self.containerSlotID = containerSlotID;
end

function BankPanelItemButtonMixin:GetContainerSlotID()
	return self.containerSlotID;
end

function BankPanelItemButtonMixin:InitItemLocation()
	self.itemLocation = ItemLocation:CreateFromBagAndSlot(self:GetBankTabID(), self:GetContainerSlotID());
end

function BankPanelItemButtonMixin:GetItemLocation()
	return self.itemLocation;
end

function BankPanelItemButtonMixin:GetItemContextMatchResult()
	if not self.isInitialized then
		return ItemButtonUtil.ItemContextMatchResult.DoesNotApply;
	end

	return ItemButtonUtil.GetItemContextMatchResultForItem(self:GetItemLocation());
end

function BankPanelItemButtonMixin:Refresh()
	self:RefreshItemInfo();
	self:RefreshQuestItemInfo();

	local questItemInfo = self.questItemInfo;
	local isQuestItem = questItemInfo.isQuestItem;
	local questId = questItemInfo.questID;
	local isActive = questItemInfo.isActive;
	if questId and not isActive then
		self.IconQuestTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG);
	elseif questId or isQuestItem then
		self.IconQuestTexture:SetTexture(TEXTURE_ITEM_QUEST_BORDER);
	end
	self.IconQuestTexture:SetShown(questId or isQuestItem);

	local itemInfo = self.itemInfo;
	if itemInfo then
		self.icon:SetTexture(itemInfo.iconFileID);
	end
	self.icon:SetShown(itemInfo ~= nil);
	SetItemButtonCount(self, itemInfo and itemInfo.stackCount or 0);

	self:UpdateItemContextMatching();
	local isFiltered = itemInfo and itemInfo.isFiltered;
	self:SetMatchesSearch(not isFiltered);

	local quality = itemInfo and itemInfo.quality;
	local itemID = itemInfo and itemInfo.itemID;
	local isBound = itemInfo and itemInfo.isBound;
	local suppressOverlays = false;
	SetItemButtonQuality(self, quality, itemID, supressOverlays, isBound);

	self:UpdateLocked();
	self:UpdateCooldown();
end

function BankPanelItemButtonMixin:RefreshItemInfo()
	self.itemInfo = C_Container.GetContainerItemInfo(self:GetBankTabID(), self:GetContainerSlotID());
end

function BankPanelItemButtonMixin:RefreshQuestItemInfo()
	self.questItemInfo = C_Container.GetContainerItemQuestInfo(self:GetBankTabID(), self:GetContainerSlotID());
end

function BankPanelItemButtonMixin:UpdateCooldown()
	local start, duration, enable = C_Container.GetContainerItemCooldown(self:GetBankTabID(), self:GetContainerSlotID());
	CooldownFrame_Set(self.Cooldown, start, duration, enable);
	if ( duration and duration > 0 and enable == 0 ) then
		local r, g, b = 0.4, 0.4, 0.4;
		SetItemButtonTextureVertexColor(self, r, g, b);
	end
end

function BankPanelItemButtonMixin:UpdateLocked()
	SetItemButtonDesaturated(self, self.itemInfo and self.itemInfo.isLocked);
end

function BankPanelItemButtonMixin:SplitStack(amount)
	C_Container.SplitContainerItem(self:GetBankTabID(), self:GetContainerSlotID(), amount);
end

BankPanelMixin = CreateFromMixins(CallbackRegistryMixin);

local BankPanelEvents = {
	"ACCOUNT_MONEY",
	"BANK_TABS_CHANGED",
	"BAG_UPDATE",
	"BANK_TAB_SETTINGS_UPDATED",
	"INVENTORY_SEARCH_UPDATE",
	"ITEM_LOCK_CHANGED",
	"PLAYER_MONEY",
};

BankPanelMixin:GenerateCallbackEvents(
{
	"BankTabClicked",
	"NewBankTabSelected",
});

function BankPanelMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	self:AddDynamicEventMethod(self, BankPanelMixin.Event.BankTabClicked, self.OnBankTabClicked);
	self:AddDynamicEventMethod(self, BankPanelMixin.Event.NewBankTabSelected, self.OnNewBankTabSelected);

	self:SetBankType(Enum.BankType.Account);

	self.bankTabPool = CreateFramePool("BUTTON", self, "BankPanelTabTemplate");

	local function BankItemButtonResetter(framePool, frame)
		frame.isInitialized = false;
	end
	self.itemButtonPool = CreateFramePool("ItemButton", self, "AccountBankItemButtonTemplate", BankItemButtonResetter);

	self.selectedTabID = nil;
end

function BankPanelMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);
	FrameUtil.RegisterFrameForEvents(self, BankPanelEvents);

	self:Reset();
	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);
end

function BankPanelMixin:OnHide()
	CallbackRegistrantMixin.OnHide(self);
	FrameUtil.UnregisterFrameForEvents(self, BankPanelEvents);

	self.TabSettingsMenu:Hide();
	self.selectedTabID = nil;

	self:CloseAllBankPopups();
	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);
end

function BankPanelMixin:MarkDirty()
	self.isDirty = true;
	self:SetScript("OnUpdate", self.OnUpdate);
end

function BankPanelMixin:Clean()
	if not self.isDirty then
		return;
	end
	
	local hasItemSlots = self.itemButtonPool:GetNumActive() > 0;
	if hasItemSlots then
		self:RefreshAllItemsForSelectedTab();
	else
		-- Newly purchased bank tabs may need to have item slots generated
		self:GenerateItemSlotsForSelectedTab();
	end

	self.isDirty = false;
	self:SetScript("OnUpdate", nil);
end

function BankPanelMixin:OnUpdate()
	self:Clean();
end

function BankPanelMixin:CloseAllBankPopups()
	StaticPopup_Hide("CONFIRM_BUY_BANK_TAB");
	StaticPopup_Hide("BANK_MONEY_WITHDRAW");
	StaticPopup_Hide("BANK_MONEY_DEPOSIT");
	StaticPopup_Hide("BANK_CONFIRM_CLEANUP");
end

function BankPanelMixin:HideAllPrompts()
	for index, prompt in ipairs(self.Prompts) do
		prompt:Hide();
	end
end

function BankPanelMixin:SetItemDisplayEnabled(enable)
	if not enable then
		self.itemButtonPool:ReleaseAll();
	end
	self.ItemDepositFrame:SetEnabled(enable);
	self.ItemDepositFrame:SetShown(enable);
end

function BankPanelMixin:SetMoneyFrameEnabled(enable)
	self.MoneyFrame:SetShown(enable);
end

function BankPanelMixin:OnEvent(event, ...)
	if event == "BANK_TABS_CHANGED"	then
		local bankType = ...;
		if bankType == self.bankType then
			self:Reset();
		end
	elseif event == "BANK_TAB_SETTINGS_UPDATED" then
		local bankType = ...;
		if bankType == self.bankType then
			self.TabSettingsMenu:Hide();
			self:FetchPurchasedBankTabData();
			self:RefreshBankTabs();
			self:RefreshHeaderText();
		end
	elseif event == "BAG_UPDATE" then
		local containerID = ...;
		if self.selectedTabID == containerID then
			self:MarkDirty();
		end
	elseif event == "INVENTORY_SEARCH_UPDATE" then
		self:UpdateSearchResults();
	elseif event == "ITEM_LOCK_CHANGED" then
		local bankTabID, containerSlotID = ...;
		local itemInSelectedTab = bankTabID == self:GetSelectedTabID();
		if not itemInSelectedTab then
			return;
		end

		local itemButton = self:FindItemButtonByContainerSlotID(containerSlotID);
		if itemButton then
			itemButton:Refresh();
		end
	elseif event == "ACCOUNT_MONEY" then
		if self.bankType == Enum.BankType.Account then
			self.MoneyFrame:Refresh();
		end
	elseif event == "PLAYER_MONEY" then
		if self.bankType == Enum.BankType.Character then
			self.MoneyFrame:Refresh();
		end
	end
end

function BankPanelMixin:OnBankTabClicked(clickedTabID)
	self:SelectTab(clickedTabID);
end

function BankPanelMixin:OnNewBankTabSelected(tabID)
	self:RefreshBankPanel();
end

function BankPanelMixin:GetSelectedTabID()
	return self.selectedTabID;
end

function BankPanelMixin:GetTabData(tabID)
	if not self.purchasedBankTabData then
		return;
	end

	for index, tabData in ipairs(self.purchasedBankTabData) do
		if tabData.ID == tabID then
			return tabData;
		end
	end
end

function BankPanelMixin:SetBankType(bankType)
	self.bankType = bankType;
end

function BankPanelMixin:GetBankType()
	return self.bankType;
end

function BankPanelMixin:IsBankTypeLocked()
	if self.bankType == Enum.BankType.Account then
		return not C_PlayerInfo.HasAccountInventoryLock();
	end
	
	return false;
end

function BankPanelMixin:SelectTab(tabID)
	local alreadySelected = self.selectedTabID == tabID;
	if not alreadySelected then
		self.selectedTabID = tabID;
		self:TriggerEvent(BankPanelMixin.Event.NewBankTabSelected, tabID);
	end
end

function BankPanelMixin:RefreshBankPanel()
	self:HideAllPrompts();
	if self:ShouldShowLockPrompt() then
		self:ShowLockPrompt();
		return;
	end

	if self:ShouldShowPurchasePrompt() then
		self:ShowPurchasePrompt();
		return;
	end

	local noTabSelected = self.selectedTabID == nil;
	if noTabSelected then
		return;
	end
		
	self:SetHeaderEnabled(true);
	self:SetItemDisplayEnabled(true);
	self:SetMoneyFrameEnabled(true);
	self:GenerateItemSlotsForSelectedTab();
end

function BankPanelMixin:SetHeaderEnabled(enabled)
	self.Header:SetShown(enabled);

	if enabled then
		self:RefreshHeaderText();
	end
end

function BankPanelMixin:RefreshHeaderText()
	local selectedBankTabData = self:GetTabData(self.selectedTabID);
	self.Header.Text:SetText(selectedBankTabData and selectedBankTabData.name or "");
end

function BankPanelMixin:ShouldShowLockPrompt()
	return self:IsBankTypeLocked();
end

function BankPanelMixin:ShowLockPrompt()
	self.TabSettingsMenu:Hide();
	self:SetHeaderEnabled(false);
	self:SetItemDisplayEnabled(false);
	self:SetMoneyFrameEnabled(false);
	self.LockPrompt:Show();
end

function BankPanelMixin:ShouldShowPurchasePrompt()
	return self.PurchaseTab:IsSelected() and C_Bank.CanPurchaseBankTab(self.bankType);
end

function BankPanelMixin:ShowPurchasePrompt()
	self.TabSettingsMenu:Hide();
	self:SetHeaderEnabled(false);
	self:SetItemDisplayEnabled(false);
	self.PurchasePrompt:Show();
end

function BankPanelMixin:Reset()
	self:FetchPurchasedBankTabData();
	self:SelectFirstAvailableTab();
	self:RefreshBankTabs();
	self:RefreshBankPanel();
end

function BankPanelMixin:SelectFirstAvailableTab()
	local hasPurchasedTabs = self.purchasedBankTabData and #self.purchasedBankTabData > 0;
	if hasPurchasedTabs then
		self:SelectTab(self.purchasedBankTabData[1].ID);
	elseif C_Bank.CanPurchaseBankTab(self.bankType) then
		self:SelectTab(PURCHASE_TAB_ID);
	end
end

function BankPanelMixin:FetchPurchasedBankTabData()
	self.purchasedBankTabData = C_Bank.FetchPurchasedBankTabData(self.bankType);
end

function BankPanelMixin:RefreshBankTabs()
	self.bankTabPool:ReleaseAll();

	-- List purchased tabs first...
	local lastBankTab;
	if self.purchasedBankTabData then
		for index, bankTabData in ipairs(self.purchasedBankTabData) do
			local newBankTab = self.bankTabPool:Acquire();

			if lastBankTab == nil then
				newBankTab:SetPoint("TOPLEFT", self, "TOPRIGHT", 2, -25);
			else
				newBankTab:SetPoint("TOPLEFT", lastBankTab, "BOTTOMLEFT", 0, -17);
			end
			
			newBankTab:Init(bankTabData);
			newBankTab:Show();
			lastBankTab = newBankTab;
		end
	end

	-- ...followed by the button to purchase a new tab (if applicable)
	local showPurchaseTab = not self:IsBankTypeLocked() and not C_Bank.HasMaxBankTabs(self.bankType);
	if showPurchaseTab then
		if lastBankTab == nil then
			self.PurchaseTab:SetPoint("TOPLEFT", self, "TOPRIGHT", 2, -25);
		else
			self.PurchaseTab:SetPoint("TOPLEFT", lastBankTab, "BOTTOMLEFT", 0, -17);
		end

		self.PurchaseTab:SetEnabledState(C_Bank.CanPurchaseBankTab(self.bankType));
		self.PurchaseTab:Show();
	else
		self.PurchaseTab:Hide();
	end
end

function BankPanelMixin:GenerateItemSlotsForSelectedTab()
	self.itemButtonPool:ReleaseAll();

	if not self.selectedTabID or self.selectedTabID == PURCHASE_TAB_ID then
		return;
	end

	local numRows = 7;
	local numSubColumns = 2;
	local lastColumnStarterButton;
	local lastCreatedButton;
	local currentColumn = 1;
	for containerSlotID = 1, C_Container.GetContainerNumSlots(self.selectedTabID) do
		local button = self.itemButtonPool:Acquire();
			
		local isFirstButton = containerSlotID == 1;
		local needNewColumn = (containerSlotID % numRows) == 1;
		if isFirstButton then
			local xOffset, yOffset = 26, -63;
			button:SetPoint("TOPLEFT", AccountBankPanel, "TOPLEFT", currentColumn * xOffset, yOffset);
			lastColumnStarterButton = button;
		elseif needNewColumn then
			currentColumn = currentColumn + 1;

			local xOffset, yOffset = 8, 0;
			-- We reached the last subcolumn, time to add space for a new "big" column
			local startNewBigColumn = (currentColumn % numSubColumns == 1);
			if startNewBigColumn then
				xOffset = 19;
			end
			button:SetPoint("TOPLEFT", lastColumnStarterButton, "TOPRIGHT", xOffset, yOffset);
			lastColumnStarterButton = button;
		else
			local xOffset, yOffset = 0, -10;
			button:SetPoint("TOPLEFT", lastCreatedButton, "BOTTOMLEFT", xOffset, yOffset);
		end
		
		button:Init(self.selectedTabID, containerSlotID);
		button:Show();

		lastCreatedButton = button;
	end
end

function BankPanelMixin:RefreshAllItemsForSelectedTab()
	for itemButton in self:EnumerateValidItems() do
		itemButton:Refresh();
	end
end

function BankPanelMixin:UpdateSearchResults()
	for itemButton in self:EnumerateValidItems() do
		local itemInfo = C_Container.GetContainerItemInfo(itemButton:GetBankTabID(), itemButton:GetContainerSlotID());
		local isFiltered = itemInfo and itemInfo.isFiltered;
		itemButton:SetMatchesSearch(not isFiltered);
	end
end

function BankPanelMixin:EnumerateValidItems()
	return self.itemButtonPool:EnumerateActive();
end

function BankPanelMixin:FindItemButtonByContainerSlotID(containerSlotID)
	for itemButton in self:EnumerateValidItems() do
		if itemButton:GetContainerSlotID() == containerSlotID then
			return itemButton;
		end
	end
end

BankPanelPromptMixin = CreateFromMixins(BankPanelSystemMixin);

function BankPanelPromptMixin:OnLoad()
	RaiseFrameLevel(self);
end

function BankPanelPromptMixin:OnShow()
	if self.Refresh then
		self:Refresh();
	end
end

function BankPanelPromptMixin:SetTitle(title)
	self.Title:SetText(title);
end

function BankPanelPromptMixin:SetPromptText(promptText)
	self.PromptText:SetText(promptText);
end

function BankPanelPromptMixin:SetPromptWidth(width)
	self.PromptText:SetWidth(width);
end

BankPanelLockPromptMixin = CreateFromMixins(BankPanelPromptMixin);

function BankPanelLockPromptMixin:OnLoad()
	BankPanelPromptMixin.OnLoad(self);

	self:SetPromptWidth(650);
	self:SetPromptText(ACCOUNT_BANK_LOCKED_PROMPT);
end

BankPanelPurchasePromptMixin = CreateFromMixins(BankPanelPromptMixin);

local BankPurchasePromptEvents = {
	"PLAYER_MONEY",
};

function BankPanelPurchasePromptMixin:OnLoad()
	BankPanelPromptMixin.OnLoad(self);

	self:SetTitle(ACCOUNT_BANK_PANEL_TITLE);

	self:SetPromptWidth(450);
	self:SetPromptText(ACCOUNT_BANK_TAB_PURCHASE_PROMPT);
end

function BankPanelPurchasePromptMixin:OnShow()
	BankPanelPromptMixin.OnShow(self);
	FrameUtil.RegisterFrameForEvents(self, BankPurchasePromptEvents);
end

function BankPanelPurchasePromptMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, BankPurchasePromptEvents);
end

function BankPanelPurchasePromptMixin:OnEvent(event, ...)
	if event == "PLAYER_MONEY" then
		self:Refresh();
	end
end

function BankPanelPurchasePromptMixin:Refresh()
	local bankType = self:GetActiveBankType();
	local tabCost = C_Bank.FetchNextPurchasableBankTabCost(bankType);
	if tabCost then
		MoneyFrame_Update(self.TabCostFrame.MoneyDisplay, tabCost);
		local canAfford = GetMoney() >= tabCost;
		SetMoneyFrameColorByFrame(self.TabCostFrame.MoneyDisplay, canAfford and "white" or "red");
	end
end

BankPanelItemDepositFrameMixin = {};

function BankPanelItemDepositFrameMixin:OnLoad()
	self.IncludeReagentsCheckbox.Text:SetText(BANK_DEPOSIT_INCLUDE_REAGENTS_CHECKBOX_LABEL);
end

function BankPanelItemDepositFrameMixin:SetEnabled(enable)
	self.IncludeReagentsCheckbox:SetEnabled(enable);
	local fontColor = enable and NORMAL_FONT_COLOR or GRAY_FONT_COLOR;
	self.IncludeReagentsCheckbox.Text:SetTextColor(fontColor:GetRGBA());
	self.IncludeReagentsCheckbox:GetCheckedTexture():SetDesaturated(not enable);

	self.DepositButton:SetEnabled(enable);
end

BankPanelItemDepositButtonMixin = CreateFromMixins(BankPanelSystemMixin);

function BankPanelItemDepositButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
	C_Bank.AutoDepositItemsIntoBank(self:GetActiveBankType());
end

BankPanelTabCostMoneyDisplayMixin = {};

function BankPanelTabCostMoneyDisplayMixin:OnLoad()
	SmallMoneyFrame_OnLoad(self);
	MoneyFrame_SetType(self, "STATIC");
end

BankPanelPurchaseTabButtonMixin = CreateFromMixins(BankPanelSystemMixin);

function BankPanelPurchaseTabButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
	local textArg1, textArg2 = nil, nil;
	StaticPopup_Show("CONFIRM_BUY_BANK_TAB", textArg1, textArg2, { bankType = self:GetActiveBankType() });
end

BankPanelMoneyFrameMixin = CreateFromMixins(BankPanelSystemMixin);

function BankPanelMoneyFrameMixin:OnShow()
	self:Refresh();
end

function BankPanelMoneyFrameMixin:Refresh()
	self.MoneyDisplay:Refresh();
	self.WithdrawButton:Refresh();
	self.DepositButton:Refresh();
end

BankPanelMoneyFrameMoneyDisplayMixin = CreateFromMixins(BankPanelSystemMixin);

function BankPanelMoneyFrameMoneyDisplayMixin:OnLoad()
	SmallMoneyFrame_OnLoad(self);
end

function BankPanelMoneyFrameMoneyDisplayMixin:Refresh()
	local bankType = self:GetActiveBankType();
	local isAccountBank = bankType == Enum.BankType.Account;
	local moneyType = isAccountBank and "ACCOUNT" or "PLAYER";
	MoneyFrame_SetType(self, moneyType);

	MoneyFrame_UpdateMoney(self);
end

BankPanelWithdrawMoneyButtonMixin = CreateFromMixins(BankPanelSystemMixin);

function BankPanelWithdrawMoneyButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);

	StaticPopup_Hide("BANK_MONEY_DEPOSIT");

	local alreadyShown = StaticPopup_Visible("BANK_MONEY_WITHDRAW");
	if alreadyShown then
		StaticPopup_Hide("BANK_MONEY_WITHDRAW");
		return;
	end

	StaticPopup_Show("BANK_MONEY_WITHDRAW", textArg1, textArg2, { bankType = self:GetActiveBankType() });
end

function BankPanelWithdrawMoneyButtonMixin:Refresh()
	local bankType = self:GetActiveBankType();
	self.disabledTooltip = self:IsActiveBankTypeLocked() and ACCOUNT_BANK_ERROR_NO_LOCK or nil;

	local canWithdrawMoney = bankType and C_Bank.CanWithdrawMoney(bankType);
	self:SetEnabled(canWithdrawMoney);
end

BankPanelDepositMoneyButtonMixin = CreateFromMixins(BankPanelSystemMixin);

function BankPanelDepositMoneyButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);

	StaticPopup_Hide("BANK_MONEY_WITHDRAW");

	local alreadyShown = StaticPopup_Visible("BANK_MONEY_DEPOSIT");
	if alreadyShown then
		StaticPopup_Hide("BANK_MONEY_DEPOSIT");
		return;
	end

	StaticPopup_Show("BANK_MONEY_DEPOSIT", textArg1, textArg2, { bankType = self:GetActiveBankType() });
end

function BankPanelDepositMoneyButtonMixin:Refresh()
	local bankType = self:GetActiveBankType();
	self.disabledTooltip = self:IsActiveBankTypeLocked() and ACCOUNT_BANK_ERROR_NO_LOCK or nil;

	local canDepositMoney = bankType and C_Bank.CanDepositMoney(bankType);
	self:SetEnabled(canDepositMoney);
end

BankPanelTabSettingsMenuMixin = CreateFromMixins(CallbackRegistryMixin, BankPanelSystemMixin);

BankPanelTabSettingsMenuMixin:GenerateCallbackEvents(
{
	"OpenTabSettingsRequested",
});

function BankPanelTabSettingsMenuMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	IconSelectorPopupFrameTemplateMixin.OnLoad(self);

	self:AddStaticEventMethod(self, BankPanelTabSettingsMenuMixin.Event.OpenTabSettingsRequested, self.OnOpenTabSettingsRequested);
	self:AddDynamicEventMethod(self:GetBankFrame(), BankPanelMixin.Event.NewBankTabSelected, self.OnNewBankTabSelected);

	local function OnIconSelected(selectionIndex, icon)
		self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(icon);

		-- Index is not yet set, but we know if an icon in IconSelector was selected it was in the list, so set directly.
		self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetText(ICON_SELECTION_CLICK);
		self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetFontObject(GameFontHighlightSmall);
	end
    self.IconSelector:SetSelectedCallback(OnIconSelected);

	self:OverrideInheritedAnchoring();

	self.selectedTabData = nil;
end

function BankPanelTabSettingsMenuMixin:OnOpenTabSettingsRequested(tabID)
	local shown = self:IsShown();
	if not shown then
		self:SetSelectedTab(tabID);
		self:Show();
		return;
	end

	local alreadyEditingTab = shown and self:GetSelectedTabID() == tabID;
	if alreadyEditingTab then
		self:Hide();
	end
end

function BankPanelTabSettingsMenuMixin:OnNewBankTabSelected(tabID)
	if not self:IsShown() or tabID == PURCHASE_TAB_ID then
		return;
	end
	
	self:SetSelectedTab(tabID);
end

function BankPanelTabSettingsMenuMixin:OverrideInheritedAnchoring()
	-- We inherit from IconSelectorPopupFrameTemplate (used by the Macro UI, Guild Bank UI, etc.)
	-- However, we need to make more room for the bank tab "Sort Settings"
	-- Let's update the template layout to make sure everything fits
	NineSliceUtil.ApplyLayoutByName(self.BorderBox, "BankTabSettingsMenuLayout");

	self:SetHeight(594);
	self.IconSelector:ClearAllPoints();
	self.IconSelector:SetPoint("TOPLEFT", self.BorderBox, "TOPLEFT", 21, -196);

	self.BorderBox.IconSelectionText:ClearAllPoints();
	self.BorderBox.IconSelectionText:SetPoint("BOTTOMLEFT", self.IconSelector, "TOPLEFT", 0, 10);

	self.BorderBox.IconTypeDropdown:ClearAllPoints();
	self.BorderBox.IconTypeDropdown:SetPoint("BOTTOMRIGHT", self.IconSelector, "TOPRIGHT", -33, 0);
end

function BankPanelTabSettingsMenuMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);
	IconSelectorPopupFrameTemplateMixin.OnShow(self);

	self.iconDataProvider = self:RefreshIconDataProvider();

	self:Update();

	self:SetIconFilter(IconSelectorPopupFrameIconFilterTypes.All);

	self.BorderBox.IconSelectorEditBox:SetFocus();
	self.BorderBox.IconSelectorEditBox:OnTextChanged();

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
end

function BankPanelTabSettingsMenuMixin:OnHide()
	CallbackRegistrantMixin.OnHide(self);
	IconSelectorPopupFrameTemplateMixin.OnHide(self);

	if self.iconDataProvider ~= nil then
		self.iconDataProvider:Release();
		self.iconDataProvider = nil;
	end

	self.selectedTabData = nil;

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

function BankPanelTabSettingsMenuMixin:RefreshIconDataProvider()
	if self.iconDataProvider == nil then
		self.iconDataProvider = CreateAndInitFromMixin(IconDataProviderMixin, IconDataProviderExtraType.None);
	end

	return self.iconDataProvider;
end

function BankPanelTabSettingsMenuMixin:Update()
	if not self.selectedTabData then
		return;
	end

	self.BorderBox.IconSelectorEditBox:SetText(self.selectedTabData.name);
	self.BorderBox.IconSelectorEditBox:HighlightText();

	local defaultIconSelected = self.selectedTabData.icon == QUESTION_MARK_ICON;
	if defaultIconSelected then
		local initialIndex = 1;
		self.IconSelector:SetSelectedIndex(initialIndex);
		self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(self:GetIconByIndex(initialIndex));
	else
		self.IconSelector:SetSelectedIndex(self:GetIndexOfIcon(self.selectedTabData.icon));
		self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(self.selectedTabData.icon);
	end

	local getSelection = GenerateClosure(self.iconDataProvider.GetIconByIndex, self.iconDataProvider);
	local getNumSelections = GenerateClosure(self.iconDataProvider.GetNumIcons, self.iconDataProvider);
	self.IconSelector:SetSelectionsDataProvider(getSelection, getNumSelections);
	self.IconSelector:ScrollToSelectedIndex();

	self:SetSelectedIconText();

	self:InitDepositSettingCheckboxes();
	self.DepositSettingsMenu.ExpansionFilterDropdown:Refresh();
end

function BankPanelTabSettingsMenuMixin:SetSelectedTab(selectedTabID)
	local alreadySelected = self:GetSelectedTabID() == selectedTabID;
	if alreadySelected then
		return;
	end

	self.selectedTabData = self:GetBankFrame():GetTabData(selectedTabID);

	if self:IsShown() then
		self:Update();
	end
end

function BankPanelTabSettingsMenuMixin:GetSelectedTabID()
	return self.selectedTabData and self.selectedTabData.ID;
end

function BankPanelTabSettingsMenuMixin:CancelButton_OnClick()
	IconSelectorPopupFrameTemplateMixin.CancelButton_OnClick(self);

	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end

function BankPanelTabSettingsMenuMixin:OkayButton_OnClick()
	self:UpdateBankTabSettings();
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);

	IconSelectorPopupFrameTemplateMixin.OkayButton_OnClick(self);
end

function BankPanelTabSettingsMenuMixin:UpdateBankTabSettings()
	local tabData = self:GetSelectedTabData();
	if not tabData then
		return;
	end

	local bankType = tabData.bankType;
	local tabID = tabData.ID;
	local tabIcon = self:GetNewTabIcon();
	local tabName = self:GetNewTabName();
	local depositFlags = self:GetNewTabDepositFlags();
	C_Bank.UpdateBankTabSettings(bankType, tabID, tabName, tabIcon, depositFlags);
end

function BankPanelTabSettingsMenuMixin:GetNewTabName()
	return self.BorderBox.IconSelectorEditBox:GetText() or "";
end

function BankPanelTabSettingsMenuMixin:GetNewTabIcon()
	return self.BorderBox.SelectedIconArea.SelectedIconButton:GetIconTexture() or QUESTION_MARK_ICON;
end

function BankPanelTabSettingsMenuMixin:GetNewTabDepositFlags()
	local depositFlags = 0;
	for index, checkBox in ipairs(self.DepositSettingsMenu.DepositSettingsCheckboxes) do
		local isValidSetting = checkBox.settingFlag ~= nil;
		if isValidSetting then
			local setDepositFlag = checkBox:GetChecked();
			depositFlags = FlagsUtil.Combine(depositFlags, checkBox.settingFlag, setDepositFlag);
		end
	end

	local expansionFlags = self.DepositSettingsMenu.ExpansionFilterDropdown:GetFilterValue();
	if expansionFlags then
		local setFlag = true;
		depositFlags = FlagsUtil.Combine(depositFlags, expansionFlags, setFlag);
	end

	return depositFlags;
end

function BankPanelTabSettingsMenuMixin:InitDepositSettingCheckboxes()
	local tabData = self:GetSelectedTabData();
	if not tabData then
		return;
	end

	local depositFlags = tabData.depositFlags;
	for index, checkBox in ipairs(self.DepositSettingsMenu.DepositSettingsCheckboxes) do
		local isValidSetting = checkBox.settingFlag ~= nil;
		checkBox:SetEnabled(isValidSetting);
		checkBox:SetChecked(isValidSetting and FlagsUtil.IsSet(depositFlags, checkBox.settingFlag) or false);
	end
end

function BankPanelTabSettingsMenuMixin:GetSelectedTabData()
	return self.selectedTabData;
end

local BankTabExpansionFilterTypes = {
	["All"] = 0,
	["ExpansionCurrent"] = Enum.BagSlotFlags.ExpansionCurrent,
	["ExpansionLegacy"] = Enum.BagSlotFlags.ExpansionLegacy,
};

local BankTabExpansionFilterOrder = {
	BankTabExpansionFilterTypes.All,
	BankTabExpansionFilterTypes.ExpansionCurrent,
	BankTabExpansionFilterTypes.ExpansionLegacy,
};

local BankTabExpansionFilterTypeNames = {
	[BankTabExpansionFilterTypes.All] = BANK_TAB_EXPANSION_FILTER_ALL,
	[BankTabExpansionFilterTypes.ExpansionCurrent] = BANK_TAB_EXPANSION_FILTER_CURRENT,
	[BankTabExpansionFilterTypes.ExpansionLegacy] = BANK_TAB_EXPANSION_FILTER_LEGACY,
};

BankTabDepositSettingsMenuMixin = {};

function BankTabDepositSettingsMenuMixin:OnLoad()
	self.ExpansionFilterDropdown:SetWidth(110);
end

function BankTabDepositSettingsMenuMixin:OnShow()
	self.ExpansionFilterDropdown:Refresh();
end

BankPanelTabSettingsExpansionFilterDropdownMixin = {};

local function GetCurrentFilterType(tabData)
	local filterType = 0;
	for index, filterValue in ipairs(BankTabExpansionFilterOrder) do
		filterType = FlagsUtil.Combine(filterType, filterValue, FlagsUtil.IsSet(tabData.depositFlags, filterValue));
	end
	return filterType;
end

function BankPanelTabSettingsExpansionFilterDropdownMixin:Refresh()
	local tabData = self:GetSelectedTabData();
	if not tabData then
		return;
	end

	self:SetFilterValue(GetCurrentFilterType(tabData));

	local function IsSelected(filterType)
		return self:GetFilterValue() == filterType;
	end

	local function SetSelected(filterType)
		self:SetFilterValue(filterType);
	end

	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_BANK_EXPANSION_FILTER");

		for index, filterType in ipairs(BankTabExpansionFilterOrder) do
			rootDescription:CreateRadio(BankTabExpansionFilterTypeNames[filterType], IsSelected, SetSelected, filterType);
		end
	end);
end

function BankPanelTabSettingsExpansionFilterDropdownMixin:GetSelectedTabData()
	local settingsMenu = self:GetParent():GetParent();
	return settingsMenu:GetSelectedTabData();
end

function BankPanelTabSettingsExpansionFilterDropdownMixin:GetFilterValue()
	return self.selectedValue;
end

function BankPanelTabSettingsExpansionFilterDropdownMixin:SetFilterValue(value)
	self.selectedValue = value;
end

BankPanelCheckboxMixin = {};

function BankPanelCheckboxMixin:OnShow()
	self:Init();
end

function BankPanelCheckboxMixin:Init()
	if self.fontObject then
		self.Text:SetFontObject(self.fontObject);
	end

	if self.textWidth then
		self.Text:SetWidth(self.textWidth);
	end

	if self.text then
		self.Text:SetText(self.text);
	end
end

BankPanelIncludeReagentsCheckboxMixin = CreateFromMixins(BankPanelCheckboxMixin);

function BankPanelIncludeReagentsCheckboxMixin:OnShow()
	BankPanelCheckboxMixin.OnShow(self);
	self:SetChecked(GetCVarBool("bankAutoDepositReagents"));
end

function BankPanelIncludeReagentsCheckboxMixin:OnClick()
	SetCVar("bankAutoDepositReagents", self:GetChecked());
end

