MERCHANT_ITEMS_PER_PAGE = 10;
BUYBACK_ITEMS_PER_PAGE = 12;
MAX_ITEM_COST = 3;
MAX_MERCHANT_CURRENCIES = 6;
local MAX_MONEY_DISPLAY_WIDTH = 120;

function MerchantFrame_OnLoad(self)
	self:RegisterEvent("MERCHANT_UPDATE");
	self:RegisterEvent("MERCHANT_CLOSED");
	self:RegisterEvent("MERCHANT_SHOW");
	self:RegisterEvent("GUILDBANK_UPDATE_MONEY");
	self:RegisterEvent("MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL");
	self:RegisterForDrag("LeftButton");
	self.page = 1;
	-- Tab Handling code
	PanelTemplates_SetNumTabs(self, 2);
	PanelTemplates_SetTab(self, 1);
	
	MoneyFrame_SetMaxDisplayWidth(MerchantMoneyFrame, 160);
	
end

function MerchantFrame_OnEvent(self, event, ...)
	if ( event == "MERCHANT_UPDATE" ) then
		self.update = true;
	elseif ( event == "MERCHANT_CLOSED" ) then
		StaticPopup_Hide("CONFIRM_MERCHANT_TRADE_TIMER_REMOVAL");
		HideUIPanel(self);
	elseif ( event == "MERCHANT_SHOW" ) then
		ShowUIPanel(self);
		if ( not self:IsShown() ) then
			CloseMerchant();
			return;
		end
		self.page = 1;
		MerchantFrame_UpdateCurrencies();
		MerchantFrame_Update();
	elseif ( event == "PLAYER_MONEY" or event == "GUILDBANK_UPDATE_MONEY" or event == "GUILDBANK_UPDATE_WITHDRAWMONEY" ) then
		MerchantFrame_UpdateCanRepairAll();
		MerchantFrame_UpdateGuildBankRepair();
		MerchantFrame_UpdateRepairButtons();
	elseif ( event == "CURRENCY_DISPLAY_UPDATE" ) then
		MerchantFrame_UpdateCurrencyAmounts();
	elseif ( event == "HEIRLOOMS_UPDATED" ) then
		local itemID, updateReason = ...;
		if itemID and updateReason == "NEW" then
			MerchantFrame_Update();
		end
	elseif ( event == "MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL" ) then
		local item = ...;
		StaticPopup_Show("CONFIRM_MERCHANT_TRADE_TIMER_REMOVAL", item);
	elseif ( event == "GET_ITEM_INFO_RECEIVED" ) then
		MerchantFrame_UpdateItemQualityBorders(self);
	end
end

function MerchantFrame_OnUpdate(self, dt)
	if ( self.update == true ) then
		self.update = false;
		if ( self:IsVisible() ) then
			MerchantFrame_Update();
		end
	end
	if ( MerchantFrame.itemHover ) then
		if ( IsModifiedClick("DRESSUP") ) then
			ShowInspectCursor();
		else
			if (CanAffordMerchantItem(MerchantFrame.itemHover) == false) then
				SetCursor("BUY_ERROR_CURSOR");
			else
				SetCursor("BUY_CURSOR");
			end
		end
	end
	if ( MerchantRepairItemButton:IsShown() ) then
		if ( InRepairMode() ) then
			MerchantRepairItemButton:LockHighlight();
		else
			MerchantRepairItemButton:UnlockHighlight();
		end
	end
end

function MerchantFrame_OnShow(self)
	OpenAllBags(self);
	ContainerFrame_UpdateAll();
	
	-- Update repair all button status
	MerchantFrame_UpdateCanRepairAll();
	PanelTemplates_SetTab(MerchantFrame, 1);

	MerchantFrame_Update();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
end

function MerchantFrame_OnHide(self)
	CloseMerchant();
	CloseAllBags(self);
	ResetCursor();
	
	StaticPopup_Hide("CONFIRM_PURCHASE_TOKEN_ITEM");
	StaticPopup_Hide("CONFIRM_REFUND_TOKEN_ITEM");
	StaticPopup_Hide("CONFIRM_REFUND_MAX_HONOR");
	StaticPopup_Hide("CONFIRM_REFUND_MAX_ARENA_POINTS");
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end

function MerchantFrame_OnMouseWheel(self, value)
	if ( value > 0 ) then
		if ( MerchantPrevPageButton:IsShown() and MerchantPrevPageButton:IsEnabled() ) then
			MerchantPrevPageButton_OnClick();
		end
	else
		if ( MerchantNextPageButton:IsShown() and MerchantNextPageButton:IsEnabled() ) then
			MerchantNextPageButton_OnClick();
		end	
	end
end

function MerchantFrame_Update()
	if ( MerchantFrame.lastTab ~= MerchantFrame.selectedTab ) then
		MerchantFrame_CloseStackSplitFrame();
		MerchantFrame.lastTab = MerchantFrame.selectedTab;
	end

	if ( MerchantFrame.selectedTab == 1 ) then
		MerchantFrame_UpdateMerchantInfo();
	else
		MerchantFrame_UpdateBuybackInfo();
	end
	
end

function MerchantFrameItem_UpdateQuality(self, link)
	-- No quality borders for Classic.
	--[[local quality = link and select(3, GetItemInfo(link)) or nil;
	if ( quality ) then
		self.Name:SetTextColor(ITEM_QUALITY_COLORS[quality].r, ITEM_QUALITY_COLORS[quality].g, ITEM_QUALITY_COLORS[quality].b);
	else
		self.Name:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		MerchantFrame_RegisterForQualityUpdates();
	end
	
	SetItemButtonQuality(self.ItemButton, quality, link);]]
end

function MerchantFrame_RegisterForQualityUpdates()
	if ( not MerchantFrame:IsEventRegistered("GET_ITEM_INFO_RECEIVED") ) then
		MerchantFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED");
	end
end

function MerchantFrame_UnregisterForQualityUpdates()
	if ( MerchantFrame:IsEventRegistered("GET_ITEM_INFO_RECEIVED") ) then
		MerchantFrame:UnregisterEvent("GET_ITEM_INFO_RECEIVED");
	end
end

function MerchantFrame_UpdateItemQualityBorders(self)
	MerchantFrame_UnregisterForQualityUpdates(); -- We'll re-register if we need to.
	
	if ( MerchantFrame.selectedTab == 1 ) then
		local numMerchantItems = GetMerchantNumItems();
		for i=1, MERCHANT_ITEMS_PER_PAGE do
			local index = (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i);
			local item = _G["MerchantItem"..i];
			if ( index <= numMerchantItems ) then
				local itemLink = GetMerchantItemLink(index);
				MerchantFrameItem_UpdateQuality(item, itemLink);
			end
		end
	else
		local numBuybackItems = GetNumBuybackItems();
		for index=1, BUYBACK_ITEMS_PER_PAGE do
			local item = _G["MerchantItem"..index];
			if ( index <= numBuybackItems ) then
				local itemLink = GetBuybackItemLink(index);
				MerchantFrameItem_UpdateQuality(item, itemLink);
			end
		end
	end
end

function MerchantFrame_UpdateMerchantInfo()
	MerchantNameText:SetText(UnitName("NPC"));
	SetPortraitTexture(MerchantFramePortrait, "NPC");
	
	local numMerchantItems = GetMerchantNumItems();
	
	MerchantPageText:SetFormattedText(PAGE_NUMBER, MerchantFrame.page);

	local name, texture, price, stackCount, numAvailable, isPurchasable, isUsable, extendedCost;
	for i=1, MERCHANT_ITEMS_PER_PAGE do
		local index = (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i);
		local itemButton = _G["MerchantItem"..i.."ItemButton"];
		local merchantButton = _G["MerchantItem"..i];
		local merchantMoney = _G["MerchantItem"..i.."MoneyFrame"];
		local merchantAltCurrency = _G["MerchantItem"..i.."AltCurrencyFrame"];
		if ( index <= numMerchantItems ) then
			name, texture, price, stackCount, numAvailable, isPurchasable, isUsable, extendedCost, currencyID = GetMerchantItemInfo(index);

			if(currencyID) then
				name, texture, numAvailable = CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, numAvailable, name, texture, nil); 
			end
	
			local canAfford = CanAffordMerchantItem(index);
			_G["MerchantItem"..i.."Name"]:SetText(name);
			SetItemButtonCount(itemButton, stackCount);
			SetItemButtonStock(itemButton, numAvailable);
			SetItemButtonTexture(itemButton, texture);
			
			if ( extendedCost and (price <= 0) ) then
				itemButton.price = nil;
				itemButton.extendedCost = true;
				itemButton.name = name;
				itemButton.link = GetMerchantItemLink(index);
				itemButton.texture = texture;
				MerchantFrame_UpdateAltCurrency(index, i, canAfford);
				merchantAltCurrency:ClearAllPoints();
				merchantAltCurrency:SetPoint("BOTTOMLEFT", "MerchantItem"..i.."NameFrame", "BOTTOMLEFT", 2, 31);
				merchantMoney:Hide();
				merchantAltCurrency:Show();
			elseif ( extendedCost and (price > 0) ) then
				itemButton.price = price;
				itemButton.extendedCost = true;
				itemButton.name = name;
				itemButton.link = GetMerchantItemLink(index);
				itemButton.texture = texture;
				local altCurrencyWidth = MerchantFrame_UpdateAltCurrency(index, i, canAfford);
				MoneyFrame_SetMaxDisplayWidth(merchantMoney, MAX_MONEY_DISPLAY_WIDTH - altCurrencyWidth);
				MoneyFrame_Update(merchantMoney:GetName(), price);
				local color;
				if (canAfford == false) then
					color = "gray";
				end
				SetMoneyFrameColor(merchantMoney:GetName(), color);
				merchantAltCurrency:ClearAllPoints();
				merchantAltCurrency:SetPoint("LEFT", merchantMoney:GetName(), "RIGHT", -12, 0);
				merchantAltCurrency:Show();
				merchantMoney:Show();
			else
				itemButton.price = price;
				itemButton.extendedCost = nil;
				itemButton.name = name;
				itemButton.link = GetMerchantItemLink(index);
				itemButton.texture = texture;
				MoneyFrame_SetMaxDisplayWidth(merchantMoney, MAX_MONEY_DISPLAY_WIDTH);
				MoneyFrame_Update(merchantMoney:GetName(), price);
				local color;
				if (canAfford == false) then
					color = "gray";
				end
				SetMoneyFrameColor(merchantMoney:GetName(), color);
				merchantAltCurrency:Hide();
				merchantMoney:Show();
			end

			local itemLink = GetMerchantItemLink(index);
			MerchantFrameItem_UpdateQuality(merchantButton, itemLink);

			local merchantItemID = GetMerchantItemID(index);
			local isHeirloom = false;--merchantItemID and C_Heirloom.IsItemHeirloom(merchantItemID);
			local isKnownHeirloom = false;--isHeirloom and C_Heirloom.PlayerHasHeirloom(merchantItemID);

			itemButton.showNonrefundablePrompt = isHeirloom;

			itemButton.hasItem = true;
			itemButton:SetID(index);
			itemButton:Show();

			local tintRed = not isPurchasable or (not isUsable and not isHeirloom);
			
			SetItemButtonDesaturated(itemButton, isKnownHeirloom);

			if ( numAvailable == 0 or isKnownHeirloom ) then
				-- If not available and not usable
				if ( tintRed ) then
					SetItemButtonNameFrameVertexColor(merchantButton, 0.5, 0, 0);
					SetItemButtonSlotVertexColor(merchantButton, 0.5, 0, 0);
					SetItemButtonTextureVertexColor(itemButton, 0.5, 0, 0);
					SetItemButtonNormalTextureVertexColor(itemButton, 0.5, 0, 0);
				else
					SetItemButtonNameFrameVertexColor(merchantButton, 0.5, 0.5, 0.5);
					SetItemButtonSlotVertexColor(merchantButton, 0.5, 0.5, 0.5);
					SetItemButtonTextureVertexColor(itemButton, 0.5, 0.5, 0.5);
					SetItemButtonNormalTextureVertexColor(itemButton,0.5, 0.5, 0.5);
				end
				
			elseif ( tintRed ) then
				SetItemButtonNameFrameVertexColor(merchantButton, 1.0, 0, 0);
				SetItemButtonSlotVertexColor(merchantButton, 1.0, 0, 0);
				SetItemButtonTextureVertexColor(itemButton, 0.9, 0, 0);
				SetItemButtonNormalTextureVertexColor(itemButton, 0.9, 0, 0);
			else
				SetItemButtonNameFrameVertexColor(merchantButton, 0.5, 0.5, 0.5);
				SetItemButtonSlotVertexColor(merchantButton, 1.0, 1.0, 1.0);
				SetItemButtonTextureVertexColor(itemButton, 1.0, 1.0, 1.0);
				SetItemButtonNormalTextureVertexColor(itemButton, 1.0, 1.0, 1.0);
			end
		else
			itemButton.price = nil;
			itemButton.hasItem = nil;
			itemButton.name = nil;
			itemButton:Hide();
			SetItemButtonNameFrameVertexColor(merchantButton, 0.5, 0.5, 0.5);
			SetItemButtonSlotVertexColor(merchantButton,0.4, 0.4, 0.4);
			_G["MerchantItem"..i.."Name"]:SetText("");
			_G["MerchantItem"..i.."MoneyFrame"]:Hide();
			_G["MerchantItem"..i.."AltCurrencyFrame"]:Hide();
		end
	end

	-- Handle repair items
	MerchantFrame_UpdateRepairButtons();

	-- Handle vendor buy back item
	local numBuybackItems = GetNumBuybackItems();
	local buybackName, buybackTexture, buybackPrice, buybackQuantity, buybackNumAvailable, buybackIsUsable = GetBuybackItemInfo(numBuybackItems);
	if ( buybackName ) then
		MerchantBuyBackItemName:SetText(buybackName);
		SetItemButtonCount(MerchantBuyBackItemItemButton, buybackQuantity);
		SetItemButtonStock(MerchantBuyBackItemItemButton, buybackNumAvailable);
		SetItemButtonTexture(MerchantBuyBackItemItemButton, buybackTexture);
		MerchantFrameItem_UpdateQuality(MerchantBuyBackItem, GetBuybackItemLink(numBuybackItems));
		MerchantBuyBackItemMoneyFrame:Show();
		MoneyFrame_Update("MerchantBuyBackItemMoneyFrame", buybackPrice);
		MerchantBuyBackItem:Show();
		
	else
		MerchantBuyBackItemName:SetText("");
		MerchantBuyBackItemMoneyFrame:Hide();
		SetItemButtonTexture(MerchantBuyBackItemItemButton, "");
		SetItemButtonCount(MerchantBuyBackItemItemButton, 0);
		MerchantFrameItem_UpdateQuality(MerchantBuyBackItem, nil);
		-- Hide the tooltip upon sale
		if ( GameTooltip:IsOwned(MerchantBuyBackItemItemButton) ) then
			GameTooltip:Hide();
		end
	end

	-- Handle paging buttons
	if ( numMerchantItems > MERCHANT_ITEMS_PER_PAGE ) then
		if ( MerchantFrame.page == 1 ) then
			MerchantPrevPageButton:Disable();
		else
			MerchantPrevPageButton:Enable();
		end
		if ( MerchantFrame.page == ceil(numMerchantItems / MERCHANT_ITEMS_PER_PAGE) or numMerchantItems == 0) then
			MerchantNextPageButton:Disable();
		else
			MerchantNextPageButton:Enable();
		end
		MerchantPageText:Show();
		MerchantPrevPageButton:Show();
		MerchantNextPageButton:Show();
	else
		MerchantPageText:Hide();
		MerchantPrevPageButton:Hide();
		MerchantNextPageButton:Hide();
	end

	-- Show all merchant related items
	MerchantBuyBackItem:Show();
	MerchantFrameBottomLeftBorder:Show();
	MerchantFrameBottomRightBorder:Show();

	-- Hide buyback related items
	MerchantItem11:Hide();
	MerchantItem12:Hide();
	BuybackBG:Hide();

	-- Position merchant items
	MerchantItem3:SetPoint("TOPLEFT", "MerchantItem1", "BOTTOMLEFT", 0, -8);
	MerchantItem5:SetPoint("TOPLEFT", "MerchantItem3", "BOTTOMLEFT", 0, -8);
	MerchantItem7:SetPoint("TOPLEFT", "MerchantItem5", "BOTTOMLEFT", 0, -8);
	MerchantItem9:SetPoint("TOPLEFT", "MerchantItem7", "BOTTOMLEFT", 0, -8);
end

function MerchantFrame_UpdateAltCurrency(index, indexOnPage, canAfford)
	local itemCount = GetMerchantItemCostInfo(index);
	local frameName = "MerchantItem"..indexOnPage.."AltCurrencyFrame";
	local usedCurrencies = 0;
	local width = 0;

	-- update Alt Currency Frame with itemValues
	if ( itemCount > 0 ) then
		for i=1, MAX_ITEM_COST do
			local itemTexture, itemValue, itemLink = GetMerchantItemCostItem(index, i);
			if ( itemTexture ) then
				usedCurrencies = usedCurrencies + 1;
				local button = _G[frameName.."Item"..usedCurrencies];
				button.index = index;
				button.item = i;
				button.itemLink = itemLink;
				AltCurrencyFrame_Update(frameName.."Item"..usedCurrencies, itemTexture, itemValue, canAfford);
				width = width + button:GetWidth();
				if ( usedCurrencies > 1 ) then
					-- button spacing;
					width = width + 4;
				end
				button:Show();
			end
		end
		for i = usedCurrencies + 1, MAX_ITEM_COST do
			_G[frameName.."Item"..i]:Hide();
		end
	else
		for i=1, MAX_ITEM_COST do
			_G[frameName.."Item"..i]:Hide();
		end
	end
	return width;
end

function MerchantFrame_UpdateBuybackInfo()
	MerchantNameText:SetText(MERCHANT_BUYBACK);
	MerchantFramePortrait:SetTexture("Interface\\MerchantFrame\\UI-BuyBack-Icon");

	-- Show Buyback specific items
	MerchantItem11:Show();
	MerchantItem12:Show();
	BuybackBG:Show();

	-- Position buyback items
	MerchantItem3:SetPoint("TOPLEFT", "MerchantItem1", "BOTTOMLEFT", 0, -15);
	MerchantItem5:SetPoint("TOPLEFT", "MerchantItem3", "BOTTOMLEFT", 0, -15);
	MerchantItem7:SetPoint("TOPLEFT", "MerchantItem5", "BOTTOMLEFT", 0, -15);
	MerchantItem9:SetPoint("TOPLEFT", "MerchantItem7", "BOTTOMLEFT", 0, -15);
	
	local numBuybackItems = GetNumBuybackItems();
	local itemButton, buybackButton;
	local buybackName, buybackTexture, buybackPrice, buybackQuantity, buybackNumAvailable, buybackIsUsable;
	local buybackItemLink;
	for i=1, BUYBACK_ITEMS_PER_PAGE do
		itemButton = _G["MerchantItem"..i.."ItemButton"];
		buybackButton = _G["MerchantItem"..i];
		_G["MerchantItem"..i.."AltCurrencyFrame"]:Hide();
		if ( i <= numBuybackItems ) then
			buybackName, buybackTexture, buybackPrice, buybackQuantity, buybackNumAvailable, buybackIsUsable = GetBuybackItemInfo(i);
			_G["MerchantItem"..i.."Name"]:SetText(buybackName);
			SetItemButtonCount(itemButton, buybackQuantity);
			SetItemButtonStock(itemButton, buybackNumAvailable);
			SetItemButtonTexture(itemButton, buybackTexture);
			_G["MerchantItem"..i.."MoneyFrame"]:Show();
			MoneyFrame_Update("MerchantItem"..i.."MoneyFrame", buybackPrice);
			buybackItemLink = GetBuybackItemLink(i);
			MerchantFrameItem_UpdateQuality(buybackButton, buybackItemLink);
			itemButton:SetID(i);
			itemButton:Show();
			if ( not buybackIsUsable ) then
				SetItemButtonNameFrameVertexColor(buybackButton, 1.0, 0, 0);
				SetItemButtonSlotVertexColor(buybackButton, 1.0, 0, 0);
				SetItemButtonTextureVertexColor(itemButton, 0.9, 0, 0);
				SetItemButtonNormalTextureVertexColor(itemButton, 0.9, 0, 0);
			else
				SetItemButtonNameFrameVertexColor(buybackButton, 0.5, 0.5, 0.5);
				SetItemButtonSlotVertexColor(buybackButton, 1.0, 1.0, 1.0);
				SetItemButtonTextureVertexColor(itemButton, 1.0, 1.0, 1.0);
				SetItemButtonNormalTextureVertexColor(itemButton, 1.0, 1.0, 1.0);
			end
		else
			SetItemButtonNameFrameVertexColor(buybackButton, 0.5, 0.5, 0.5);
			SetItemButtonSlotVertexColor(buybackButton,0.4, 0.4, 0.4);
			_G["MerchantItem"..i.."Name"]:SetText("");
			_G["MerchantItem"..i.."MoneyFrame"]:Hide();
			itemButton:Hide();
		end
	end

	-- Hide all merchant related items
	MerchantRepairAllButton:Hide();
	MerchantRepairItemButton:Hide();
	MerchantBuyBackItem:Hide();
	MerchantPrevPageButton:Hide();
	MerchantNextPageButton:Hide();
	MerchantFrameBottomLeftBorder:Hide();
	MerchantFrameBottomRightBorder:Hide();
	MerchantRepairText:Hide();
	MerchantPageText:Hide();
	MerchantGuildBankRepairButton:Hide();
end

function MerchantPrevPageButton_OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	MerchantFrame.page = MerchantFrame.page - 1;
	MerchantFrame_CloseStackSplitFrame();
	MerchantFrame_Update();
end

function MerchantNextPageButton_OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	MerchantFrame.page = MerchantFrame.page + 1;
	MerchantFrame_CloseStackSplitFrame();
	MerchantFrame_Update();
end

function MerchantFrame_CloseStackSplitFrame()
	if ( StackSplitFrame:IsShown() ) then
		local numButtons = max(MERCHANT_ITEMS_PER_PAGE, BUYBACK_ITEMS_PER_PAGE);
		for i = 1, numButtons do
			if ( StackSplitFrame.owner == _G["MerchantItem"..i.."ItemButton"] ) then
				StackSplitFrameCancel_Click();
				return;
			end
		end
	end
end

function MerchantItemBuybackButton_OnLoad(self)
	self:RegisterEvent("MERCHANT_UPDATE");
	self:RegisterForClicks("LeftButtonUp","RightButtonUp");
	self:RegisterForDrag("LeftButton");
	
	self.SplitStack = function(button, split)
		if ( split > 0 ) then
			BuyMerchantItem(button:GetID(), split);
		end
	end
end

function MerchantItemButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonUp","RightButtonUp");
	self:RegisterForDrag("LeftButton");
	
	self.SplitStack = function(button, split)
		if ( button.extendedCost ) then
			MerchantFrame_ConfirmExtendedItemCost(button, split)
		elseif ( button.showNonrefundablePrompt ) then
			MerchantFrame_ConfirmExtendedItemCost(button, split)
		elseif ( split > 0 ) then
			BuyMerchantItem(button:GetID(), split);
		end
	end
	
	self.UpdateTooltip = MerchantItemButton_OnEnter;
end

MERCHANT_HIGH_PRICE_COST = 1500000;

function MerchantItemButton_OnClick(self, button)
	MerchantFrame.extendedCost = nil;
	MerchantFrame.highPrice = nil;
	
	if ( MerchantFrame.selectedTab == 1 ) then
		-- Is merchant frame
		if ( button == "LeftButton" ) then
			if ( MerchantFrame.refundItem ) then
				if ( ContainerFrame_GetExtendedPriceString(MerchantFrame.refundItem, MerchantFrame.refundItemEquipped)) then
					-- a confirmation dialog has been shown
					return;
				end
			end
			
			PickupMerchantItem(self:GetID());
			if ( self.extendedCost ) then
				MerchantFrame.extendedCost = self;
			elseif ( self.showNonrefundablePrompt ) then
				MerchantFrame.extendedCost = self;
			elseif ( self.price and self.price >= MERCHANT_HIGH_PRICE_COST ) then
				MerchantFrame.highPrice = self;
			end
		else
			if ( self.extendedCost ) then
				MerchantFrame_ConfirmExtendedItemCost(self);
			elseif ( self.showNonrefundablePrompt ) then
				MerchantFrame_ConfirmExtendedItemCost(self);
			elseif ( self.price and self.price >= MERCHANT_HIGH_PRICE_COST ) then
				MerchantFrame_ConfirmHighCostItem(self);
			else
				BuyMerchantItem(self:GetID());
			end
		end
	else
		-- Is buyback item
		BuybackItem(self:GetID());
	end
end

function MerchantItemButton_OnModifiedClick(self, button)
	if ( MerchantFrame.selectedTab == 1 ) then
		-- Is merchant frame
		if ( HandleModifiedItemClick(GetMerchantItemLink(self:GetID())) ) then
			return;
		end
		if ( IsModifiedClick("SPLITSTACK")) then
			local maxStack = GetMerchantItemMaxStack(self:GetID());
			local _, _, price, stackCount, _, _, _, extendedCost = GetMerchantItemInfo(self:GetID());
			
			local canAfford;
			if (price and price > 0) then
				canAfford = floor(GetMoney() / (price / stackCount));
			else
				canAfford = maxStack;
			end
			
			if (extendedCost) then
				local itemCount = GetMerchantItemCostInfo(self:GetID());
				for i = 1, MAX_ITEM_COST do
					local itemTexture, itemValue, itemLink, currencyName = GetMerchantItemCostItem(self:GetID(), i);
					if (itemLink and not currencyName) then
						local myCount = GetItemCount(itemLink, false, false, true);
						canAfford = min(canAfford, floor(myCount / (itemValue / stackCount)));
					end
				end
			end

			if ( maxStack > 1 ) then
				local maxPurchasable = min(maxStack, canAfford);
				OpenStackSplitFrame(maxPurchasable, self, "BOTTOMLEFT", "TOPLEFT", stackCount);
			end
			return;
		end
	else
		HandleModifiedItemClick(GetBuybackItemLink(self:GetID()));
	end
end

function MerchantItemButton_OnEnter(button)
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
	if ( MerchantFrame.selectedTab == 1 ) then
		GameTooltip:SetMerchantItem(button:GetID());
		GameTooltip_ShowCompareItem(GameTooltip);
		MerchantFrame.itemHover = button:GetID();
	else
		GameTooltip:SetBuybackItem(button:GetID());
		if ( IsModifiedClick("DRESSUP") and button.hasItem ) then
			ShowInspectCursor();
		else
			ShowBuybackSellCursor(button:GetID());
		end
	end
end

LIST_DELIMITER = ", "

function MerchantFrame_ConfirmExtendedItemCost(itemButton, numToPurchase)
	local index = itemButton:GetID();
	local itemsString;
	if ( GetMerchantItemCostInfo(index) == 0 and not itemButton.showNonrefundablePrompt) then
		if ( itemButton.price and itemButton.price >= MERCHANT_HIGH_PRICE_COST ) then
			MerchantFrame_ConfirmHighCostItem(itemButton);
		else
			BuyMerchantItem( itemButton:GetID(), numToPurchase );
		end
		return;
	end
	
	MerchantFrame.itemIndex = index;
	MerchantFrame.count = numToPurchase;
	
	local stackCount = itemButton.count or 1;
	numToPurchase = numToPurchase or stackCount;
	
	local maxQuality = 0;
	local usingCurrency = false;
	for i=1, MAX_ITEM_COST do
		local itemTexture, costItemCount, itemLink, currencyName = GetMerchantItemCostItem(index, i);
		costItemCount = costItemCount * (numToPurchase / stackCount); -- cost per stack times number of stacks
		if ( currencyName ) then
			usingCurrency = true;

			local extraArgs = "";
			if ( itemTexture == HONOR_POINT_TEXTURES[1] or itemTexture == HONOR_POINT_TEXTURES[2] ) then
				-- Honor Point textures have some funky coordinates, so we'll fix them up here.
				extraArgs = ":64:64:0:40:0:40";
			end

			if ( itemsString ) then
				itemsString = itemsString .. ", |T"..itemTexture..":0:0:0:-1"..extraArgs.."|t ".. format(CURRENCY_QUANTITY_TEMPLATE, costItemCount, currencyName);
			else
				itemsString = " |T"..itemTexture..":0:0:0:-1"..extraArgs.."|t "..format(CURRENCY_QUANTITY_TEMPLATE, costItemCount, currencyName);
			end
		elseif ( itemLink ) then
			local _, _, itemQuality = GetItemInfo(itemLink);
			maxQuality = math.max(itemQuality, maxQuality);
			if ( itemsString ) then
				itemsString = itemsString .. LIST_DELIMITER .. format(ITEM_QUANTITY_TEMPLATE, costItemCount, itemLink);
			else
				itemsString = format(ITEM_QUANTITY_TEMPLATE, costItemCount, itemLink);
			end
		end
	end
	if ( itemButton.showNonrefundablePrompt and itemButton.price ) then
		if ( itemsString ) then
			itemsString = itemsString .. LIST_DELIMITER .. GetMoneyString(itemButton.price);
		else
			itemsString = GetMoneyString(itemButton.price);
		end
	end
	
	if ( not usingCurrency and maxQuality <= LE_ITEM_QUALITY_UNCOMMON and not itemButton.showNonrefundablePrompt) then
		BuyMerchantItem( itemButton:GetID(), numToPurchase );
		return;
	end
	
	
	local itemName = "";
	local itemQuality = 1;
	local _;
	local specs = {};
	if(itemButton.link) then
		itemName, _, itemQuality = GetItemInfo(itemButton.link);
	end
	local r, g, b = GetItemQualityColor(itemQuality);
	local specText = "";
	
	if (itemButton.showNonrefundablePrompt) then
		StaticPopup_Show("CONFIRM_PURCHASE_NONREFUNDABLE_ITEM", itemsString, specText, 
							{["texture"] = itemButton.texture, ["name"] = itemName, ["color"] = {r, g, b, 1}, 
							["link"] = itemButton.link, ["index"] = index, ["count"] = numToPurchase});
	else
		StaticPopup_Show("CONFIRM_PURCHASE_TOKEN_ITEM", itemsString, specText, 
							{["texture"] = itemButton.texture, ["name"] = itemName, ["color"] = {r, g, b, 1}, 
							["link"] = itemButton.link, ["index"] = index, ["count"] = numToPurchase});
	end
end

function MerchantFrame_ResetRefundItem()
	MerchantFrame.refundItem = nil;
	MerchantFrame.refundItemEquipped = nil;
end

function MerchantFrame_SetRefundItem(item, isEquipped)
	MerchantFrame.refundItem = item;
	MerchantFrame.refundItemEquipped = isEquipped;
end

function MerchantFrame_ConfirmHighCostItem(itemButton, quantity)
	quantity = (quantity or 1);
	local index = itemButton:GetID();

	MerchantFrame.itemIndex = index;
	MerchantFrame.count = quantity;
	MerchantFrame.price = itemButton.price;
	StaticPopup_Show("CONFIRM_HIGH_COST_ITEM", itemButton.link);
end

function MerchantFrame_UpdateCanRepairAll()
	if ( MerchantRepairAllIcon ) then
		local repairAllCost, canRepair = GetRepairAllCost();
		if ( canRepair ) then
			SetDesaturation(MerchantRepairAllIcon, false);
			MerchantRepairAllButton:Enable();
		else
			SetDesaturation(MerchantRepairAllIcon, true);
			MerchantRepairAllButton:Disable();
		end	
	end
end

function MerchantFrame_UpdateGuildBankRepair()
	local repairAllCost, canRepair = GetRepairAllCost();
	if ( canRepair ) then
		SetDesaturation(MerchantGuildBankRepairButtonIcon, false);
		MerchantGuildBankRepairButton:Enable();
	else
		SetDesaturation(MerchantGuildBankRepairButtonIcon, true);
		MerchantGuildBankRepairButton:Disable();
	end	
end

function MerchantFrame_UpdateRepairButtons()
	if ( MerchantFrame.selectedTab == 1 and CanMerchantRepair() ) then
		--See if can guildbank repair
		if ( CanGuildBankRepair() ) then
			MerchantRepairAllButton:SetWidth(32);
			MerchantRepairAllButton:SetHeight(32);
			MerchantRepairItemButton:SetWidth(32);
			MerchantRepairItemButton:SetHeight(32);
			MerchantRepairItemButton:SetPoint("RIGHT", MerchantRepairAllButton, "LEFT", -4, 0);

			MerchantRepairAllButton:SetPoint("BOTTOMRIGHT", MerchantFrame, "BOTTOMLEFT", 100, 30);
			MerchantRepairText:ClearAllPoints();
			MerchantRepairText:SetPoint("CENTER", MerchantFrame, "BOTTOMLEFT", 80, 68);
			MerchantGuildBankRepairButton:Show();
			MerchantFrame_UpdateGuildBankRepair();
		else
			MerchantRepairAllButton:SetWidth(36);
			MerchantRepairAllButton:SetHeight(36);
			MerchantRepairItemButton:SetWidth(36);
			MerchantRepairItemButton:SetHeight(36);
			MerchantRepairItemButton:SetPoint("RIGHT", MerchantRepairAllButton, "LEFT", -2, 0);

			MerchantRepairAllButton:SetPoint("BOTTOMRIGHT", MerchantFrame, "BOTTOMLEFT", 160, 32);
			MerchantRepairText:ClearAllPoints();
			MerchantRepairText:SetPoint("BOTTOMLEFT", MerchantFrame, "BOTTOMLEFT", 14, 45);
			MerchantGuildBankRepairButton:Hide();
		end

		MerchantRepairText:Show();
		MerchantRepairAllButton:Show();
		MerchantRepairItemButton:Show();
		MerchantFrame_UpdateCanRepairAll();
	else
		MerchantRepairText:Hide();
		MerchantRepairAllButton:Hide();
		MerchantRepairItemButton:Hide();
		MerchantGuildBankRepairButton:Hide();
	end
end

function MerchantFrame_UpdateCurrencies()
	--[[local currencies = { GetMerchantCurrencies() };
	
	if ( #currencies == 0 ) then	-- common case
		MerchantFrame:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
		MerchantMoneyFrame:SetPoint("BOTTOMRIGHT", -4, 8);
		MerchantMoneyFrame:Show();
		MerchantExtraCurrencyInset:Hide();
		MerchantExtraCurrencyBg:Hide();
	else
		MerchantFrame:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
		MerchantExtraCurrencyInset:Show();
		MerchantExtraCurrencyBg:Show();
		local numCurrencies = #currencies;
		if ( numCurrencies > 3 ) then
			MerchantMoneyFrame:Hide();
		else
			MerchantMoneyFrame:SetPoint("BOTTOMRIGHT", -169, 8);
			MerchantMoneyFrame:Show();
		end
		for index = 1, numCurrencies do
			local tokenButton = _G["MerchantToken"..index];
			-- if this button doesn't exist yet, create it and anchor it
			if ( not tokenButton ) then
				tokenButton = CreateFrame("BUTTON", "MerchantToken"..index, MerchantFrame, "BackpackTokenTemplate");
				-- token display order is: 6 5 4 | 3 2 1
				if ( index == 1 ) then
					tokenButton:SetPoint("BOTTOMRIGHT", -16, 8);
				elseif ( index == 4 ) then
					tokenButton:SetPoint("BOTTOMLEFT", 89, 8);
				else
					tokenButton:SetPoint("RIGHT", _G["MerchantToken"..index - 1], "LEFT", 0, 0);
				end
				tokenButton:SetScript("OnEnter", MerchantFrame_ShowCurrencyTooltip);
			end

			local name, count, icon = GetCurrencyInfo(currencies[index]);
			if ( name and name ~= "" ) then
				if ( count <= 99999 ) then
					tokenButton.count:SetText(count);
				else
					tokenButton.count:SetText("*");
				end
				tokenButton.icon:SetTexture(icon);
				tokenButton.currencyID = currencies[index];
				tokenButton:Show();
			else
				tokenButton.currencyID = nil;
				tokenButton:Hide();
			end
		end
	end
	
	for i = #currencies + 1, MAX_MERCHANT_CURRENCIES do
		local tokenButton = _G["MerchantToken"..i];
		if ( tokenButton ) then
			tokenButton.currencyID = nil;
			tokenButton:Hide();
		else
			break;
		end
	end]]
end

function MerchantFrame_ShowCurrencyTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetCurrencyByID(self.currencyID);
end

function MerchantFrame_UpdateCurrencyAmounts()
	for i = 1, MAX_MERCHANT_CURRENCIES do
		local tokenButton = _G["MerchantToken"..i];
		if ( tokenButton ) then
			if ( tokenButton.currencyID ) then
				local name, count = GetCurrencyInfo(tokenButton.currencyID);
				if ( count <= 99999 ) then
					tokenButton.count:SetText(count);
				else
					tokenButton.count:SetText("*");
				end
			end
		else
			return;
		end
	end
end



