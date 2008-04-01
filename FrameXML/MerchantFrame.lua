MERCHANT_ITEMS_PER_PAGE = 12;

function MerchantFrame_OnLoad()
	this:RegisterEvent("MERCHANT_UPDATE");
	this:RegisterEvent("MERCHANT_CLOSED");
	this:RegisterEvent("MERCHANT_SHOW");
	this:RegisterForDrag("LeftButton");
	this.page = 1;
end

function MerchantFrame_OnEvent()
	if ( event == "MERCHANT_UPDATE" ) then
		if ( MerchantFrame:IsVisible() ) then
			MerchantFrame_Update();
		end
	elseif ( event == "MERCHANT_CLOSED" ) then
		HideUIPanel(this);
	elseif ( event == "MERCHANT_SHOW" ) then
		ShowUIPanel(this);
		if ( not this:IsVisible() ) then
			CloseMerchant();
			return;
		end

		this.page = 1;
		MerchantFrame_Update();
	end
end

function MerchantFrame_OnShow()
	OpenBackpack();
	-- Update repair all button status
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

function MerchantFrame_OnHide()
	CloseMerchant();
	CloseBackpack();
	ResetCursor();
end

function MerchantFrame_Update()
	MerchantNameText:SetText(UnitName("NPC"));
	SetPortraitTexture(MerchantFramePortrait, "NPC");
	MerchantPageText:SetText(format(TEXT(PAGE_NUMBER), MerchantFrame.page));
	local numMerchantItems = GetMerchantNumItems();
	local name, texture, price, quantity, numAvailable, isUsable;
	for i=1, MERCHANT_ITEMS_PER_PAGE, 1 do
		local index = (((MerchantFrame.page - 1) * MERCHANT_ITEMS_PER_PAGE) + i);
		local itemButton = getglobal("MerchantItem"..i.."ItemButton");
		local merchantButton = getglobal("MerchantItem"..i);
		if ( index <= numMerchantItems ) then
			name, texture, price, quantity, numAvailable, isUsable = GetMerchantItemInfo(index);
			getglobal("MerchantItem"..i.."Name"):SetText(name);
			SetItemButtonCount(itemButton, quantity);
			SetItemButtonStock(itemButton, numAvailable);
			SetItemButtonTexture(itemButton, texture);
			getglobal("MerchantItem"..i.."MoneyFrame"):Show();
			MoneyFrame_Update("MerchantItem"..i.."MoneyFrame", price);
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
			itemButton:Hide();
			SetItemButtonNameFrameVertexColor(merchantButton, 0.5, 0.5, 0.5);
			SetItemButtonSlotVertexColor(merchantButton,0.4, 0.4, 0.4);
			getglobal("MerchantItem"..i.."Name"):SetText("");
			getglobal("MerchantItem"..i.."MoneyFrame"):Hide();
		end
		
		
	end

	-- Handle repair items
	if ( CanMerchantRepair() ) then
		MerchantRepairText:Show();
		MerchantRepairAllButton:Show();
		MerchantRepairItemButton:Show();
	else
		MerchantRepairText:Hide();
		MerchantRepairAllButton:Hide();
		MerchantRepairItemButton:Hide();
	end

	-- Handle vendor buy back item
	local buybackName, buybackTexture, buybackPrice, buybackQuantity, buybackNumAvailable, buybackIsUsable = GetBuybackItemInfo();
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

function MerchantItemButton_OnLoad()
	this:RegisterForClicks("LeftButtonUp","RightButtonUp");
	this:RegisterForDrag("LeftButton");
	
	this.SplitStack = function(button, split)
		if ( split > 0 ) then
			BuyMerchantItem(button:GetID(), split);
		end
	end
end

function MerchantItemButton_OnClick(button)
	if ( button == "LeftButton" ) then
		PickupMerchantItem(this:GetID());
	elseif ( button == "RightButton" ) then
		BuyMerchantItem(this:GetID());
	end
end

function MerchantItemButton_OnShiftClick()
	if ( ChatFrameEditBox:IsVisible() ) then
		ChatFrameEditBox:Insert(GetMerchantItemLink(this:GetID()));
	else
		local name, texture, price, quantity, numAvailable, isUsable = GetMerchantItemInfo(this:GetID());
		if ( not name ) then
			return;
		end

		local maxStack = GetMerchantItemMaxStack(this:GetID());
		if ( maxStack <= 1 ) then
			MerchantItemButton_OnClick(arg1);
			return;
		end

		if ( price and (price > 0) ) then
			local canAfford = floor(GetMoney() / price);
			if ( canAfford < maxStack ) then
				maxStack = canAfford;
			end
		end

		OpenStackSplitFrame(maxStack, this, "BOTTOMLEFT", "TOPLEFT");
	end
end