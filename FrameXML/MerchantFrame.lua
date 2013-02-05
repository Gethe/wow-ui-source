MERCHANT_ITEMS_PER_PAGE = 10;
BUYBACK_ITEMS_PER_PAGE = 12;
MAX_ITEM_COST = 3;
MAX_MERCHANT_CURRENCIES = 6;

function MerchantFrame_OnLoad(self)
	self:RegisterEvent("MERCHANT_UPDATE");
	self:RegisterEvent("MERCHANT_CLOSED");
	self:RegisterEvent("MERCHANT_SHOW");
	self:RegisterEvent("GUILDBANK_UPDATE_MONEY");
	self:RegisterForDrag("LeftButton");
	self.page = 1;
	-- Tab Handling code
	PanelTemplates_SetNumTabs(self, 2);
	PanelTemplates_SetTab(self, 1);
	
	MoneyFrame_SetMaxDisplayWidth(MerchantMoneyFrame, 160);
	
	UIDropDownMenu_SetWidth(self.lootFilter, 132);
	UIDropDownMenu_Initialize(self.lootFilter, MerchantFrame_InitFilter);
end

function MerchantFrame_OnEvent(self, event, ...)
	if ( event == "MERCHANT_UPDATE" and "MERCHANT_FILTER_ITEM_UPDATE" ) then
		self.update = true;
	elseif ( event == "MERCHANT_CLOSED" ) then
		self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
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
		MerchantFrame_UpdateRepairButtons();
	elseif ( event == "CURRENCY_DISPLAY_UPDATE" ) then
		MerchantFrame_UpdateCurrencyAmounts();
	end
end

function MerchantFrame_OnShow(self)
	OpenAllBags(self);
	
	-- Update repair all button status
	MerchantFrame_UpdateCanRepairAll();
	MerchantFrame_UpdateGuildBankRepair();
	PanelTemplates_SetTab(MerchantFrame, 1);
	ResetSetMerchantFilter();
	
	MerchantFrame_Update();
	PlaySound("igCharacterInfoOpen");
end

function MerchantFrame_OnHide(self)
	CloseMerchant();
	CloseAllBags(self);
	ResetCursor();
	
	StaticPopup_Hide("CONFIRM_PURCHASE_TOKEN_ITEM");
	StaticPopup_Hide("CONFIRM_REFUND_TOKEN_ITEM");
	StaticPopup_Hide("CONFIRM_REFUND_MAX_HONOR");
	StaticPopup_Hide("CONFIRM_REFUND_MAX_ARENA_POINTS");
	PlaySound("igCharacterInfoClose");
end

function MerchantFrame_Update()
	MerchantFrame_UpdateFilterString()
	if ( MerchantFrame.selectedTab == 1 ) then
		MerchantFrame_UpdateMerchantInfo();
	else
		MerchantFrame_UpdateBuybackInfo();
	end
	
end

function MerchantFrame_UpdateMerchantInfo()
	MerchantNameText:SetText(UnitName("NPC"));
	SetPortraitTexture(MerchantFramePortrait, "NPC");
	
	local numMerchantItems = GetMerchantNumItems();
	
	MerchantPageText:SetFormattedText(MERCHANT_PAGE_NUMBER, MerchantFrame.page, math.ceil(numMerchantItems / MERCHANT_ITEMS_PER_PAGE));

	local name, texture, price, stackCount, numAvailable, isUsable, extendedCost;
	for i=1, MERCHANT_ITEMS_PER_PAGE, 1 do
		local index = (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i);
		local itemButton = _G["MerchantItem"..i.."ItemButton"];
		local merchantButton = _G["MerchantItem"..i];
		local merchantMoney = _G["MerchantItem"..i.."MoneyFrame"];
		local merchantAltCurrency = _G["MerchantItem"..i.."AltCurrencyFrame"];
		if ( index <= numMerchantItems ) then
			name, texture, price, stackCount, numAvailable, isUsable, extendedCost = GetMerchantItemInfo(index);
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
				MerchantFrame_UpdateAltCurrency(index, i);
				merchantAltCurrency:ClearAllPoints();
				merchantAltCurrency:SetPoint("BOTTOMLEFT", "MerchantItem"..i.."NameFrame", "BOTTOMLEFT", 0, 31);
				merchantMoney:Hide();
				merchantAltCurrency:Show();
			elseif ( extendedCost and (price > 0) ) then
				itemButton.price = price;
				itemButton.extendedCost = true;
				itemButton.name = name;
				itemButton.link = GetMerchantItemLink(index);
				itemButton.texture = texture;
				MerchantFrame_UpdateAltCurrency(index, i);
				MoneyFrame_Update(merchantMoney:GetName(), price);
				merchantAltCurrency:ClearAllPoints();
				merchantAltCurrency:SetPoint("LEFT", merchantMoney:GetName(), "RIGHT", -14, 0);
				merchantAltCurrency:Show();
				merchantMoney:Show();
			else
				itemButton.price = price;
				itemButton.extendedCost = nil;
				itemButton.name = name;
				itemButton.link = GetMerchantItemLink(index);
				itemButton.texture = texture;
				MoneyFrame_Update(merchantMoney:GetName(), price);
				merchantAltCurrency:Hide();
				merchantMoney:Show();
			end

			itemButton.hasItem = true;
			itemButton:SetID(index);
			itemButton:Show();
			if ( numAvailable == 0 ) then
				-- If not available and not usable
				if ( not isUsable ) then
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
				
			elseif ( not isUsable ) then
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
	local buybackName, buybackTexture, buybackPrice, buybackQuantity, buybackNumAvailable, buybackIsUsable = GetBuybackItemInfo(GetNumBuybackItems());
	if ( buybackName ) then
		MerchantBuyBackItemName:SetText(buybackName);
		SetItemButtonCount(MerchantBuyBackItemItemButton, buybackQuantity);
		SetItemButtonStock(MerchantBuyBackItemItemButton, buybackNumAvailable);
		SetItemButtonTexture(MerchantBuyBackItemItemButton, buybackTexture);
		MerchantBuyBackItemMoneyFrame:Show();
		MoneyFrame_Update("MerchantBuyBackItemMoneyFrame", buybackPrice);
		MerchantBuyBackItem:Show();
		
	else
		MerchantBuyBackItemName:SetText("");
		MerchantBuyBackItemMoneyFrame:Hide();
		SetItemButtonTexture(MerchantBuyBackItemItemButton, "");
		SetItemButtonCount(MerchantBuyBackItemItemButton, 0);
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

function MerchantFrame_UpdateAltCurrency(index, i)
	local itemTexture, itemValue, button;
	local itemCount = GetMerchantItemCostInfo(index);
	local frameName = "MerchantItem"..i.."AltCurrencyFrame";

	-- update Alt Currency Frame with itemValues
	if ( itemCount > 0 ) then
		for i=1, MAX_ITEM_COST, 1 do
			button = _G[frameName.."Item"..i];
			button.index = index;
			button.item = i;

			itemTexture, itemValue, button.itemLink = GetMerchantItemCostItem(index, i);
			
			AltCurrencyFrame_Update(frameName.."Item"..i, itemTexture, itemValue);
			-- Anchor items based on how many item costs there are.

			if ( i > 1 ) then
				button:SetPoint("LEFT", frameName.."Item"..i-1, "RIGHT", 4, 0);
			end
			if ( not itemTexture ) then
				button:Hide();
			else
				button:Show();
			end
		end
	else
		for i=1, MAX_ITEM_COST, 1 do
			_G[frameName.."Item"..i]:Hide();
		end
	end
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
	PlaySound("igMainMenuOptionCheckBoxOn");
	MerchantFrame.page = MerchantFrame.page - 1;
	MerchantFrame_Update();
end

function MerchantNextPageButton_OnClick()
	PlaySound("igMainMenuOptionCheckBoxOn");
	MerchantFrame.page = MerchantFrame.page + 1;
	MerchantFrame_Update();
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
			elseif ( self.price and self.price >= MERCHANT_HIGH_PRICE_COST ) then
				MerchantFrame.highPrice = self;
			end
		else
			if ( self.extendedCost ) then
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
			local _, _, price, stackCount, _, _, extendedCost = GetMerchantItemInfo(self:GetID());
			
			-- TODO: Support shift-click for stacks of extended cost items
			if (stackCount > 1 and extendedCost) then
				MerchantItemButton_OnClick(self, button);
				return;
			end
			
			local canAfford;
			if (price and price > 0) then
				canAfford = floor(GetMoney() / (price / stackCount));
			else
				canAfford = maxStack;
			end
			
			if ( maxStack > 1 ) then
				local maxPurchasable = min(maxStack, canAfford);
				OpenStackSplitFrame(maxPurchasable, self, "BOTTOMLEFT", "TOPLEFT");
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
	if ( GetMerchantItemCostInfo(index) == 0 ) then
		BuyMerchantItem( itemButton:GetID(), numToPurchase );
		return;
	end
	
	MerchantFrame.itemIndex = index;
	MerchantFrame.count = numToPurchase;
	
	local stackCount = itemButton.count or 1;
	numToPurchase = numToPurchase or stackCount;
	
	local maxQuality = 0;
	local usingCurrency = false;
	for i=1, MAX_ITEM_COST, 1 do
		local itemTexture, costItemCount, itemLink, currencyName = GetMerchantItemCostItem(index, i);
		costItemCount = costItemCount * (numToPurchase / stackCount); -- cost per stack times number of stacks
		if ( itemLink ) then
			local _, _, itemQuality = GetItemInfo(itemLink);
			maxQuality = math.max(itemQuality, maxQuality);
			if ( itemsString ) then
				itemsString = itemsString .. LIST_DELIMITER .. format(ITEM_QUANTITY_TEMPLATE, costItemCount, itemLink);
			else
				itemsString = format(ITEM_QUANTITY_TEMPLATE, costItemCount, itemLink);
			end
		elseif ( currencyName ) then
			usingCurrency = true;
			if ( itemsString ) then
				itemsString = itemsString .. ", |T"..itemTexture..":0:0:0:-1|t ".. format(CURRENCY_QUANTITY_TEMPLATE, costItemCount, currencyName);
			else
				itemsString = " |T"..itemTexture..":0:0:0:-1|t "..format(CURRENCY_QUANTITY_TEMPLATE, costItemCount, currencyName);
			end
		end
	end
	
	if ( not usingCurrency and maxQuality <= ITEM_QUALITY_UNCOMMON ) then
		BuyMerchantItem( itemButton:GetID(), numToPurchase );
		return;
	end
	
	
	local itemName = "YOU HAVE FOUND A BUG!";
	local itemQuality = 1;
	local _;
	local r, g, b = 1, 1, 1;
	if(itemButton.link) then
		itemName, _, itemQuality = GetItemInfo(itemButton.link);
		r, g, b = GetItemQualityColor(itemQuality); 
	elseif(itemName) then		-- This is the case for a currency, which don't support links yet
		itemName = itemButton.name;
		r, g, b = GetItemQualityColor(1); 
	end
	
	StaticPopup_Show("CONFIRM_PURCHASE_TOKEN_ITEM", itemsString, "", {["texture"] = itemButton.texture, ["name"] = itemName, ["color"] = {r, g, b, 1}, ["link"] = itemButton.link, ["index"] = index, ["count"] = numToPurchase});
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
			SetDesaturation(MerchantRepairAllIcon, nil);
			MerchantRepairAllButton:Enable();
		else
			SetDesaturation(MerchantRepairAllIcon, 1);
			MerchantRepairAllButton:Disable();
		end	
	end
end

function MerchantFrame_UpdateGuildBankRepair()
	local repairAllCost, canRepair = GetRepairAllCost();
	if ( canRepair ) then
		SetDesaturation(MerchantGuildBankRepairButtonIcon, nil);
		MerchantGuildBankRepairButton:Enable();
	else
		SetDesaturation(MerchantGuildBankRepairButtonIcon, 1);
		MerchantGuildBankRepairButton:Disable();
	end	
end

function MerchantFrame_UpdateRepairButtons()
	if ( CanMerchantRepair() ) then
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
	else
		MerchantRepairText:Hide();
		MerchantRepairAllButton:Hide();
		MerchantRepairItemButton:Hide();
		MerchantGuildBankRepairButton:Hide();
	end
end

function MerchantFrame_UpdateCurrencies()
	local currencies = { GetMerchantCurrencies() };
	
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
		MerchantFrame_OrderCurrencies(currencies);
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
	end
end

function MerchantFrame_OrderCurrencies(currencyTable)
	local orderedCurrencies = { };
	local numPVE = 0;
	local numPVP = 0;
	local numOther = 0;
	local isPVPfirst;
	-- the first 3 items are on the right side of the merchant window, the last 3 items are on the left side
	-- keep valor/justice and conquest/honor together, so if all 4 exist move 1 group together to the left side - this might leave a gap that might be filled by an other
	-- valor/conquest are the equivalent of gold and should always be on the leftmost edge of the window side
	-- the first pvp or pve currency should be the type of vendor (pvp or pve) so keep the currency for that on the right window side
	local numCurrencies = #currencyTable;
	for i = 1, numCurrencies do
		-- 1st index empty for PVP/PVE split
		if ( currencyTable[i] == VALOR_CURRENCY ) then
			orderedCurrencies[2] = currencyTable[i];
			numPVE = numPVE + 1;
		elseif ( currencyTable[i] == JUSTICE_CURRENCY ) then
			orderedCurrencies[3] = currencyTable[i];
			numPVE = numPVE + 1;
		-- 4th index empty for PVP/PVE split
		elseif ( currencyTable[i] == CONQUEST_CURRENCY ) then
			orderedCurrencies[5] = currencyTable[i];
			numPVP = numPVP + 1;
			if ( numPVE == 0 ) then
				isPVPfirst = true;
			end
		elseif ( currencyTable[i] == HONOR_CURRENCY ) then
			orderedCurrencies[6] = currencyTable[i];
			numPVP = numPVP + 1;
			if ( numPVE == 0 ) then
				isPVPfirst = true;
			end
		else
			orderedCurrencies[7 + numOther] = currencyTable[i];
			numOther = numOther + 1;
		end
	end

	-- if PVP currency was found before PVE, switch them around
	if ( isPVPfirst and numPVE > 0 ) then
		orderedCurrencies[2], orderedCurrencies[5] = orderedCurrencies[5], orderedCurrencies[2];	-- swap valor/conquest
		orderedCurrencies[3], orderedCurrencies[6] = orderedCurrencies[6], orderedCurrencies[3];	-- swap justice/honor
	end

	-- if all 4 special currencies exist, there may be a gap between the 2 pairs
	if ( numPVP + numPVE == 4 ) then
		-- move an other currency into the gap if there is one
		if ( numOther > 0 ) then
			numOther = numOther - 1;
			orderedCurrencies[4] = orderedCurrencies[7 + numOther];
			orderedCurrencies[7 + numOther] = nil;
		else
			orderedCurrencies[1] = 0;
		end
	end
	
	-- now put back in the original table
	local numInserted = 0;
	local insertionIndex = 1;
	wipe(currencyTable);
	for i = 1, 6 + numOther do
		if ( orderedCurrencies[i] ) then
			tinsert(currencyTable, insertionIndex, orderedCurrencies[i]);
			numInserted = numInserted + 1;
			if ( numInserted == 3 ) then
				insertionIndex = 4;
			end
		end
	end
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


function MerchantFrame_SetFilter(self, classIndex)
	SetMerchantFilter(classIndex);
	MerchantFrame.page = 1;
	if MerchantFrame:IsVisible() then
		MerchantFrame_Update();
	end
end

function MerchantFrame_UpdateFilterString()
	local name = ALL;
	local currFilter = GetMerchantFilter();

	if currFilter == LE_LOOT_FILTER_CLASS then
		name = UnitClass("player");
	elseif currFilter == LE_LOOT_FILTER_BOE then
		name = ITEM_BIND_ON_EQUIP;
	elseif currFilter == LE_LOOT_FILTER_ALL then
		name = ALL;
	else -- Spec
		local _, specName, _, icon = GetSpecializationInfo(currFilter - LE_LOOT_FILTER_SPEC1 + 1);
		name = specName;
	end
	
	UIDropDownMenu_SetText(MerchantFrame.lootFilter, name);
end

function MerchantFrame_InitFilter()
	local info = UIDropDownMenu_CreateInfo();
	local currFilter = GetMerchantFilter();
	local className = UnitClass("player");

	info.func = MerchantFrame_SetFilter;
	
	info.text = className;
	info.checked = (currFilter ~= LE_LOOT_FILTER_BOE and currFilter ~= LE_LOOT_FILTER_ALL);
	info.arg1 = LE_LOOT_FILTER_CLASS;
	UIDropDownMenu_AddButton(info);
	
	local numSpecs = GetNumSpecializations();
	for i = 1, numSpecs do
		local _, name, _, icon = GetSpecializationInfo(i);
		info.text = name;
		info.arg1 = LE_LOOT_FILTER_SPEC1 + i - 1;
		info.checked = currFilter == (LE_LOOT_FILTER_SPEC1 + i - 1);
		info.leftPadding = 10;
		UIDropDownMenu_AddButton(info);
	end

	info.text = ALL_SPECS;
	info.checked = currFilter == LE_LOOT_FILTER_CLASS;
	info.arg1 = LE_LOOT_FILTER_CLASS;
	info.func = MerchantFrame_SetFilter;
	UIDropDownMenu_AddButton(info);
	
	info.leftPadding = nil;
	info.text = ITEM_BIND_ON_EQUIP;
	info.checked = currFilter == LE_LOOT_FILTER_BOE;
	info.arg1 = LE_LOOT_FILTER_BOE;
	UIDropDownMenu_AddButton(info);
	
	info.leftPadding = nil;
	info.text = ALL;
	info.checked = currFilter == LE_LOOT_FILTER_ALL;
	info.arg1 = LE_LOOT_FILTER_ALL;
	UIDropDownMenu_AddButton(info);
end

