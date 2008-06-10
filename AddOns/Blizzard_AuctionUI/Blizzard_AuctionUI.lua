
NUM_BROWSE_TO_DISPLAY = 8;
NUM_AUCTION_ITEMS_PER_PAGE = 50;
NUM_FILTERS_TO_DISPLAY = 15;
BROWSE_FILTER_HEIGHT = 20;
NUM_BIDS_TO_DISPLAY = 9;
NUM_AUCTIONS_TO_DISPLAY = 9;
AUCTIONS_BUTTON_HEIGHT = 37;
CLASS_FILTERS = {};
OPEN_FILTER_LIST = {};
AUCTION_TIMER_UPDATE_DELAY = 0.3;
MAXIMUM_BID_PRICE = 2000000000;

UIPanelWindows["AuctionFrame"] = { area = "doublewide", pushable = 0 };

MoneyTypeInfo["AUCTION_DEPOSIT"] = {
	UpdateFunc = function()
		if ( not AuctionFrameAuctions.duration ) then
			AuctionFrameAuctions.duration = 0
		end
		return CalculateAuctionDeposit(AuctionFrameAuctions.duration);
	end,
	collapse = 1,
};

StaticPopupDialogs["BUYOUT_AUCTION"] = {
	text = TEXT(BUYOUT_AUCTION_CONFIRMATION),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
	OnAccept = function()
		PlaceAuctionBid(AuctionFrame.type, GetSelectedAuctionItem(AuctionFrame.type), AuctionFrame.buyoutPrice);
	end,
	OnShow = function()
		MoneyFrame_Update(this:GetName().."MoneyFrame", AuctionFrame.buyoutPrice);
	end,
	hasMoneyFrame = 1,
	showAlert = 1,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["CANCEL_AUCTION"] = {
	text = TEXT(CANCEL_AUCTION_CONFIRMATION),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
	OnAccept = function()
		CancelAuction(GetSelectedAuctionItem("owner"));
	end,
	OnShow = function()
		MoneyFrame_Update(this:GetName().."MoneyFrame", AuctionFrameAuctions.cancelPrice);
		if ( AuctionFrameAuctions.cancelPrice > 0 ) then
			getglobal(this:GetName().."Text"):SetText(CANCEL_AUCTION_CONFIRMATION_MONEY);
		else
			getglobal(this:GetName().."Text"):SetText(CANCEL_AUCTION_CONFIRMATION);
		end
		
	end,
	hasMoneyFrame = 1,
	showAlert = 1,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

function AuctionFrame_OnLoad()
	this:RegisterEvent("ADDON_LOADED");
	AUCTION_DISPLAY_ON_CHARACTER = "0";

	-- Tab Handling code
	PanelTemplates_SetNumTabs(this, 3);
	PanelTemplates_SetTab(AuctionFrame, 1);
	AuctionsBuyoutText:SetText(BUYOUT_PRICE.." |cff808080("..OPTIONAL..")|r");

	-- Set focus rules
	MoneyInputFrame_SetPreviousFocus(BrowseBidPrice, BrowseMaxLevel);
	MoneyInputFrame_SetNextFocus(BrowseBidPrice, BrowseName);

	MoneyInputFrame_SetPreviousFocus(BidBidPrice, BidBidPriceCopper);
	MoneyInputFrame_SetNextFocus(BidBidPrice, BidBidPriceGold);

	MoneyInputFrame_SetPreviousFocus(StartPrice, BuyoutPriceCopper);
	MoneyInputFrame_SetNextFocus(StartPrice, BuyoutPriceGold);

	MoneyInputFrame_SetPreviousFocus(BuyoutPrice, StartPriceCopper);
	MoneyInputFrame_SetNextFocus(BuyoutPrice, StartPriceGold);

	-- Init search dot count
	AuctionFrameBrowse.dotCount = 0;
	AuctionFrameBrowse.isSearchingThrottle = 0;
end

function AuctionFrame_Show()
	if ( AuctionFrame:IsVisible() ) then
		AuctionFrameBrowse_Update();
		AuctionFrameBid_Update();
		AuctionFrameAuctions_Update();
	else
		ShowUIPanel(AuctionFrame);
		if ( not AuctionFrame:IsVisible() ) then
			CloseAuctionHouse();
		end
	end
end

function AuctionFrame_Hide()
	HideUIPanel(AuctionFrame);
end

function AuctionFrame_OnShow()
	this.gotAuctions = nil;
	this.gotBids = nil;
	AuctionFrameTab_OnClick(1);
	SetPortraitTexture(AuctionPortraitTexture,"npc");
	BrowseNoResultsText:SetText(BROWSE_SEARCH_TEXT);
	PlaySound("AuctionWindowOpen");
end

function AuctionFrame_OnEvent()
	if ( event == "ADDON_LOADED" ) then
		if ( arg1 == "Blizzard_AuctionUI" ) then
			ShowOnPlayerCheckButton:SetChecked(AUCTION_DISPLAY_ON_CHARACTER);
			this:UnregisterEvent("ADDON_LOADED");
		end
	end
end

function AuctionFrameTab_OnClick(index)
	if ( not index ) then
		index = this:GetID();
	end
	PanelTemplates_SetTab(AuctionFrame, index);
	AuctionFrameAuctions:Hide();
	AuctionFrameBrowse:Hide();
	AuctionFrameBid:Hide();
	PlaySound("igCharacterInfoTab");
	if ( index == 1 ) then
		-- Browse tab
		AuctionFrameTopLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopLeft");
		AuctionFrameTop:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-Top");
		AuctionFrameTopRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-TopRight");
		AuctionFrameBotLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-BotLeft");
		AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-Bot");
		AuctionFrameBotRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Browse-BotRight");
		AuctionFrameBrowse:Show();
		AuctionFrame.type = "list";
	elseif ( index == 2 ) then
		-- Bids tab
		AuctionFrameTopLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-TopLeft");
		AuctionFrameTop:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-Top");
		AuctionFrameTopRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-TopRight");
		AuctionFrameBotLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotLeft");
		AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-Bot");
		AuctionFrameBotRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotRight");
		AuctionFrameBid:Show();
		AuctionFrame.type = "bidder";
	elseif ( index == 3 ) then
		-- Auctions tab
		AuctionFrameTopLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-TopLeft");
		AuctionFrameTop:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Top");
		AuctionFrameTopRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-TopRight");
		AuctionFrameBotLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-BotLeft");
		AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Bot");
		AuctionFrameBotRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-BotRight");
		AuctionFrameAuctions:Show();
	end
end

-- Browse tab functions

function AuctionFrameBrowse_OnLoad()
	this:RegisterEvent("AUCTION_ITEM_LIST_UPDATE");
	
	-- initialize class filter array
	AuctionFrameBrowse_InitClasses(GetAuctionItemClasses());
end

function AuctionFrameBrowse_OnShow()
	AuctionFrameBrowse.page = 0;
	AuctionFrameBrowse_Update();
	AuctionFrameFilters_Update();
end

function AuctionFrameBrowse_OnEvent()
	if ( event == "AUCTION_ITEM_LIST_UPDATE" ) then
		AuctionFrameBrowse_Update();
		-- Stop "searching" messaging
		AuctionFrameBrowse.isSearching = nil;
		BrowseNoResultsText:SetText(BROWSE_NO_RESULTS);
	end
end

function BrowseButton_OnClick(button)
	if ( not button ) then
		button = this;
	end
	SetSelectedAuctionItem("list", button:GetID() + FauxScrollFrame_GetOffset(BrowseScrollFrame));
	-- Close any auction related popups
	CloseAuctionStaticPopups();
	AuctionFrameBrowse_Update();
end

function BrowseDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, BrowseDropDown_Initialize);
end

function BrowseDropDown_Initialize()
	info = {};
	info.text = ALL;
	info.value = -1;
	info.func = BrowseDropDown_OnClick;
	UIDropDownMenu_AddButton(info);
	for i=0, getn(ITEM_QUALITY_COLORS)-2  do
		info = {};
		info.text = getglobal("ITEM_QUALITY"..i.."_DESC");
		info.value = i;
		info.func = BrowseDropDown_OnClick;
		UIDropDownMenu_AddButton(info);
	end
end

function BrowseDropDown_OnClick()
	UIDropDownMenu_SetSelectedValue(BrowseDropDown, this.value);
end

function AuctionFrameBrowse_InitClasses(...)
	for i=1, arg.n do
		CLASS_FILTERS[i] = arg[i];
	end
end

function AuctionFrameBrowse_Search(page)
	-- If there's a page argument then use that page in the query, otherwise set the page to 0
	if ( not page ) then
		AuctionFrameBrowse.page = 0;
	end
	QueryAuctionItems(BrowseName:GetText(), BrowseMinLevel:GetText(), BrowseMaxLevel:GetText(), AuctionFrameBrowse.selectedInvtypeIndex, AuctionFrameBrowse.selectedClassIndex, AuctionFrameBrowse.selectedSubclassIndex, AuctionFrameBrowse.page, IsUsableCheckButton:GetChecked(), UIDropDownMenu_GetSelectedValue(BrowseDropDown));
	-- Start "searching" messaging
	AuctionFrameBrowse.isSearching = 1;
end

function BrowseSearchButton_OnUpdate()
	if (CanSendAuctionQuery()) then
		this:Enable();
		if ( BrowsePrevPageButton.isEnabled ) then
			BrowsePrevPageButton:Enable();
		else
			BrowsePrevPageButton:Disable();
		end
		if ( BrowseNextPageButton.isEnabled ) then
			BrowseNextPageButton:Enable();
		else
			BrowseNextPageButton:Disable();
		end
	else
		this:Disable();
		BrowsePrevPageButton:Disable();
		BrowseNextPageButton:Disable();
	end
	if (AuctionFrameBrowse.isSearching) then
		if ( AuctionFrameBrowse.isSearchingThrottle <= 0 ) then
			AuctionFrameBrowse.dotCount = AuctionFrameBrowse.dotCount + 1;
			if ( AuctionFrameBrowse.dotCount > 3 ) then
				AuctionFrameBrowse.dotCount = 0
			end
			local dotString = "";
			for i=1, AuctionFrameBrowse.dotCount do
				dotString = dotString..".";
			end
			BrowseSearchDotsText:Show();
			BrowseSearchDotsText:SetText(dotString);
			BrowseNoResultsText:SetText(SEARCHING_FOR_ITEMS);
			AuctionFrameBrowse.isSearchingThrottle = 0.3;
		else
			AuctionFrameBrowse.isSearchingThrottle = AuctionFrameBrowse.isSearchingThrottle - arg1;
		end
	else
		BrowseSearchDotsText:Hide();
	end
end

function AuctionFrameFilters_Update()
	AuctionFrameFilters_UpdateClasses();
	-- Update scrollFrame
	FauxScrollFrame_Update(BrowseFilterScrollFrame, getn(OPEN_FILTER_LIST), NUM_FILTERS_TO_DISPLAY, BROWSE_FILTER_HEIGHT);
end

function AuctionFrameFilters_UpdateClasses()
	-- Initialize the list of open filters
	OPEN_FILTER_LIST = {};
	for i=1, getn(CLASS_FILTERS) do
		if ( AuctionFrameBrowse.selectedClass and AuctionFrameBrowse.selectedClass == CLASS_FILTERS[i] ) then
			tinsert(OPEN_FILTER_LIST, {CLASS_FILTERS[i], "class", i, 1});
			AuctionFrameFilters_UpdateSubClasses(GetAuctionItemSubClasses(i));
		else
			tinsert(OPEN_FILTER_LIST, {CLASS_FILTERS[i], "class", i, nil});
		end
	end
	
	-- Display the list of open filters
	local button, index, info, isLast;
	local offset = FauxScrollFrame_GetOffset(BrowseFilterScrollFrame);
	for i=1, NUM_FILTERS_TO_DISPLAY do
		button = getglobal("AuctionFilterButton"..i);
		if ( getn(OPEN_FILTER_LIST) > NUM_FILTERS_TO_DISPLAY ) then
			button:SetWidth(136);
		else
			button:SetWidth(156);
		end
		index = offset + i;
		if ( index <= getn(OPEN_FILTER_LIST) ) then
			info = OPEN_FILTER_LIST[index];
			FilterButton_SetType(button, info[2], info[1], info[5]);
			button.index = info[3];
			if ( info[4] ) then
				button:LockHighlight();
			else
				button:UnlockHighlight();
			end
			button:Show();
		else
			button:Hide();
		end
	end
end

function AuctionFrameFilters_UpdateSubClasses(...)
	local subClass;
	for i=1, arg.n do
		subClass = HIGHLIGHT_FONT_COLOR_CODE..arg[i]..FONT_COLOR_CODE_CLOSE; 
		if ( AuctionFrameBrowse.selectedSubclass and AuctionFrameBrowse.selectedSubclass == subClass ) then
			tinsert(OPEN_FILTER_LIST, {arg[i], "subclass", i, 1});
			AuctionFrameFilters_UpdateInvTypes(GetAuctionInvTypes(AuctionFrameBrowse.selectedClassIndex,i));
		else
			tinsert(OPEN_FILTER_LIST, {arg[i], "subclass", i, nil});
		end
	end
end

function AuctionFrameFilters_UpdateInvTypes(...)
	local invType, isLast;
	for i=1, arg.n do
		invType = HIGHLIGHT_FONT_COLOR_CODE..TEXT(getglobal(arg[i]))..FONT_COLOR_CODE_CLOSE; 
		if ( i == arg.n ) then
			isLast = 1;
		end
		if ( AuctionFrameBrowse.selectedInvtypeIndex and AuctionFrameBrowse.selectedInvtypeIndex == i ) then
			tinsert(OPEN_FILTER_LIST, {invType, "invtype", i, 1, isLast});
		else
			tinsert(OPEN_FILTER_LIST, {invType, "invtype", i, nil, isLast});
		end
	end
end

function FilterButton_SetType(button, type, text, isLast)
	local normalText = getglobal(button:GetName().."NormalText");
	local normalTexture = getglobal(button:GetName().."NormalTexture");
	local line = getglobal(button:GetName().."Lines");
	if ( type == "class" ) then
		button:SetText(text);
		normalText:SetPoint("LEFT", button, "LEFT", 4, 0);
		normalTexture:SetAlpha(1.0);	
		line:Hide();
	elseif ( type == "subclass" ) then
		button:SetText(HIGHLIGHT_FONT_COLOR_CODE..text..FONT_COLOR_CODE_CLOSE);
		normalText:SetPoint("LEFT", button, "LEFT", 12, 0);
		normalTexture:SetAlpha(0.4);
		line:Hide();
	elseif ( type == "invtype" ) then
		button:SetText(HIGHLIGHT_FONT_COLOR_CODE..text..FONT_COLOR_CODE_CLOSE);
		normalText:SetPoint("LEFT", button, "LEFT", 20, 0);
		normalTexture:SetAlpha(0.0);	
		if ( isLast ) then
			line:SetTexCoord(0.4375, 0.875, 0, 0.625);
		else
			line:SetTexCoord(0, 0.4375, 0, 0.625);
		end
		line:Show();
	end
	button.type = type; 
end

function AuctionFrameFilter_OnClick()
	if ( this.type == "class" ) then
		if ( AuctionFrameBrowse.selectedClass == this:GetText() ) then
			AuctionFrameBrowse.selectedClass = nil;
			AuctionFrameBrowse.selectedClassIndex = nil;
		else
			AuctionFrameBrowse.selectedClass = this:GetText();
			AuctionFrameBrowse.selectedClassIndex = this.index;
		end
		AuctionFrameBrowse.selectedSubclass = nil;
		AuctionFrameBrowse.selectedSubclassIndex = nil;
		AuctionFrameBrowse.selectedInvtype = nil;
		AuctionFrameBrowse.selectedInvtypeIndex = nil;
	elseif ( this.type == "subclass" ) then
		if ( AuctionFrameBrowse.selectedSubclass == this:GetText() ) then
			AuctionFrameBrowse.selectedSubclass = nil;
			AuctionFrameBrowse.selectedSubclassIndex = nil;
		else
			AuctionFrameBrowse.selectedSubclass = this:GetText();
			AuctionFrameBrowse.selectedSubclassIndex = this.index;
		end
		AuctionFrameBrowse.selectedInvtype = nil;
		AuctionFrameBrowse.selectedInvtypeIndex = nil;
	elseif ( this.type == "invtype" ) then
		AuctionFrameBrowse.selectedInvtype = this:GetText();
		AuctionFrameBrowse.selectedInvtypeIndex = this.index;
	end
	AuctionFrameFilters_Update()
end

function AuctionFrameBrowse_Update()
	local numBatchAuctions, totalAuctions = GetNumAuctionItems("list");
	local button, buttonName, iconTexture, itemName, color, itemCount, moneyFrame, buyoutMoneyFrame, buyoutText, buttonHighlight;
	local offset = FauxScrollFrame_GetOffset(BrowseScrollFrame);
	local index;
	local isLastSlotEmpty;
	local name, texture, count, quality, canUse, minBid, minIncrement, buyoutPrice, duration, bidAmount, highBidder, owner;
	local displayedPrice, requiredBid;
	BrowseBidButton:Disable();
	BrowseBuyoutButton:Disable();
	-- Update sort arrows
	SortButton_UpdateArrow(BrowseQualitySort, "list", "quality");
	SortButton_UpdateArrow(BrowseLevelSort, "list", "level");
	SortButton_UpdateArrow(BrowseDurationSort, "list", "duration");
	SortButton_UpdateArrow(BrowseHighBidderSort, "list", "status");
	SortButton_UpdateArrow(BrowseCurrentBidSort, "list", "bid");

	-- Show the no results text if no items found
	if ( numBatchAuctions == 0 ) then
		BrowseNoResultsText:Show();
	else
		BrowseNoResultsText:Hide();
	end

	for i=1, NUM_BROWSE_TO_DISPLAY do
		index = offset + i + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page);
		button = getglobal("BrowseButton"..i);
		-- Show or hide auction buttons
		if ( index > (numBatchAuctions + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page)) ) then
			button:Hide();
			-- If the last button is empty then set isLastSlotEmpty var
			if ( i == NUM_BROWSE_TO_DISPLAY ) then
				isLastSlotEmpty = 1;
			end
		else
			button:Show();

			buttonName = "BrowseButton"..i;
			name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner =  GetAuctionItemInfo("list", offset + i);
			duration = GetAuctionItemTimeLeft("list", offset + i);
			-- Resize button if there isn't a scrollbar
			buttonHighlight = getglobal("BrowseButton"..i.."Highlight");
			if ( numBatchAuctions < NUM_BROWSE_TO_DISPLAY ) then
				button:SetWidth(625);
				buttonHighlight:SetWidth(589);
				BrowseCurrentBidSort:SetWidth(207);
			elseif ( numBatchAuctions == NUM_BROWSE_TO_DISPLAY and totalAuctions <= NUM_BROWSE_TO_DISPLAY ) then
				button:SetWidth(625);
				buttonHighlight:SetWidth(589);
				BrowseCurrentBidSort:SetWidth(207);
			else
				button:SetWidth(600);
				buttonHighlight:SetWidth(562);
				BrowseCurrentBidSort:SetWidth(184);
			end
			-- Set name and quality color
			color = ITEM_QUALITY_COLORS[quality];
			itemName = getglobal(buttonName.."Name");
			itemName:SetText(name);
			itemName:SetVertexColor(color.r, color.g, color.b);
			-- Set level
			if ( level > UnitLevel("player") ) then
				getglobal(buttonName.."Level"):SetText(RED_FONT_COLOR_CODE..level..FONT_COLOR_CODE_CLOSE);
			else
				getglobal(buttonName.."Level"):SetText(level);
			end
			-- Set closing time
			getglobal(buttonName.."ClosingTimeText"):SetText(AuctionFrame_GetTimeLeftText(duration));
			getglobal(buttonName.."ClosingTime").tooltip = AuctionFrame_GetTimeLeftTooltipText(duration);
			-- Set item texture, count, and usability
			iconTexture = getglobal(buttonName.."ItemIconTexture");
			iconTexture:SetTexture(texture);
			if ( not canUse ) then
				iconTexture:SetVertexColor(1.0, 0.1, 0.1);
			else
				iconTexture:SetVertexColor(1.0, 1.0, 1.0);
			end
			itemCount = getglobal(buttonName.."ItemCount");
			if ( count > 1 ) then
				itemCount:SetText(count);
				itemCount:Show();
			else
				itemCount:Hide();
			end
			-- Set high bid
			moneyFrame = getglobal(buttonName.."MoneyFrame");
			yourBidText = getglobal(buttonName.."YourBidText");
			buyoutMoneyFrame = getglobal(buttonName.."BuyoutMoneyFrame");
			buyoutText = getglobal(buttonName.."BuyoutText");
			-- If not bidAmount set the bid amount to the min bid
			if ( bidAmount == 0 ) then
				displayedPrice = minBid;
				requiredBid = minBid;
			else
				displayedPrice = bidAmount;
				requiredBid = bidAmount + minIncrement ;
			end
			MoneyFrame_Update(moneyFrame:GetName(), displayedPrice);

			if ( highBidder ) then
				yourBidText:Show();
			else
				yourBidText:Hide();
			end
			
			if ( requiredBid >= MAXIMUM_BID_PRICE ) then
				-- Lie about our buyout price
				buyoutPrice = requiredBid;
			end
			if ( buyoutPrice > 0 ) then
				moneyFrame:SetPoint("RIGHT", buttonName, "RIGHT", 10, 10);
				MoneyFrame_Update(buyoutMoneyFrame:GetName(), buyoutPrice);
				buyoutMoneyFrame:Show();
				buyoutText:Show();
			else
				moneyFrame:SetPoint("RIGHT", buttonName, "RIGHT", 10, 3);
				buyoutMoneyFrame:Hide();
				buyoutText:Hide();
			end
			-- Set high bidder
			--if ( not highBidder ) then
			--	highBidder = RED_FONT_COLOR_CODE..NO_BIDS..FONT_COLOR_CODE_CLOSE;
			--end
			getglobal(buttonName.."HighBidder"):SetText(owner);
			-- Set highlight
			if ( GetSelectedAuctionItem("list") and (offset + i) == GetSelectedAuctionItem("list") ) then
				button:LockHighlight();
				
				if ( buyoutPrice > 0 and buyoutPrice >= minBid ) then
					local canBuyout = 1;
					if ( GetMoney() < buyoutPrice ) then
						if ( not highBidder or GetMoney()+bidAmount < buyoutPrice ) then
							canBuyout = nil;
						end
					end
					if ( canBuyout ) then
						BrowseBuyoutButton:Enable();
						AuctionFrame.buyoutPrice = buyoutPrice;
					end
				else
					AuctionFrame.buyoutPrice = nil;
				end
				-- Set bid
				MoneyInputFrame_SetCopper(BrowseBidPrice, requiredBid);

				if ( not highBidder and owner ~= UnitName("player") and GetMoney() >= MoneyInputFrame_GetCopper(BrowseBidPrice) and MoneyInputFrame_GetCopper(BrowseBidPrice) <= MAXIMUM_BID_PRICE ) then
					BrowseBidButton:Enable();
				end
			else
				button:UnlockHighlight();
			end
		end
	end

	-- Update scrollFrame
	-- If more than one page of auctions show the next and prev arrows when the scrollframe is scrolled all the way down
	if ( totalAuctions > NUM_AUCTION_ITEMS_PER_PAGE ) then
		if ( isLastSlotEmpty ) then
			BrowsePrevPageButton:Show();
			BrowseNextPageButton:Show();
			BrowseSearchCountText:Show();
			local itemsMin = AuctionFrameBrowse.page * NUM_AUCTION_ITEMS_PER_PAGE + 1;
			local itemsMax = itemsMin + numBatchAuctions - 1;
			BrowseSearchCountText:SetText(format(NUMBER_OF_RESULTS_TEMPLATE, itemsMin, itemsMax, totalAuctions ));
			if ( AuctionFrameBrowse.page == 0 ) then
				BrowsePrevPageButton.isEnabled = nil;
			else
				BrowsePrevPageButton.isEnabled = 1;
			end
			if ( AuctionFrameBrowse.page == (ceil(totalAuctions/NUM_AUCTION_ITEMS_PER_PAGE) - 1) ) then
				BrowseNextPageButton.isEnabled = nil;
			else
				BrowseNextPageButton.isEnabled = 1;
			end
		else
			BrowsePrevPageButton:Hide();
			BrowseNextPageButton:Hide();
			BrowseSearchCountText:Hide();
		end
		
		-- Artifically inflate the number of results so the scrollbar scrolls one extra row
		numBatchAuctions = numBatchAuctions + 1;
	else
		BrowsePrevPageButton:Hide();
		BrowseNextPageButton:Hide();
		BrowseSearchCountText:Hide();
	end
	FauxScrollFrame_Update(BrowseScrollFrame, numBatchAuctions, NUM_BROWSE_TO_DISPLAY, AUCTIONS_BUTTON_HEIGHT);
end

-- Bid tab functions

function AuctionFrameBid_OnLoad()
	this:RegisterEvent("AUCTION_BIDDER_LIST_UPDATE");
end

function AuctionFrameBid_OnEvent()
	if ( event == "AUCTION_BIDDER_LIST_UPDATE" ) then
		AuctionFrameBid_Update();
	end
end

function AuctionFrameBid_OnShow()
	-- So the get auctions query is only run once per session, after that you only get updates
	if ( not AuctionFrame.gotBids ) then
		GetBidderAuctionItems();
		AuctionFrame.gotBids = 1;
	end
	AuctionFrameBid.page = 0;
	AuctionFrameBid_Update();
end

function AuctionFrameBid_Update()
	local numBatchAuctions, totalAuctions = GetNumAuctionItems("bidder");
	local button, buttonName, iconTexture, itemName, color, itemCount;
	local offset = FauxScrollFrame_GetOffset(BidScrollFrame);
	local index;
	local isLastSlotEmpty;
	local name, texture, count, quality, canUse, minBid, minIncrement, buyoutPrice, duration, bidAmount, highBidder, owner, buttonHighlight;
	BidBidButton:Disable();
	BidBuyoutButton:Disable();
	-- Update sort arrows
	SortButton_UpdateArrow(BidQualitySort, "bidder", "quality");
	SortButton_UpdateArrow(BidLevelSort, "bidder", "level");
	SortButton_UpdateArrow(BidDurationSort, "bidder", "duration");
	SortButton_UpdateArrow(BidBuyoutSort, "bidder", "buyout");
	SortButton_UpdateArrow(BidStatusSort, "bidder", "status");
	SortButton_UpdateArrow(BidBidSort, "bidder", "bid");

	for i=1, NUM_BIDS_TO_DISPLAY do
		index = offset + i;
		button = getglobal("BidButton"..i);
		-- Show or hide auction buttons
		if ( index > numBatchAuctions ) then
			button:Hide();
			-- If the last button is empty then set isLastSlotEmpty var
			if ( i == NUM_BIDS_TO_DISPLAY ) then
				isLastSlotEmpty = 1;
			end
		else
			button:Show();
			buttonName = "BidButton"..i;
			name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner =  GetAuctionItemInfo("bidder", index);
			duration = GetAuctionItemTimeLeft("bidder", offset + i);
			-- Resize button if there isn't a scrollbar
			buttonHighlight = getglobal("BidButton"..i.."Highlight");
			if ( numBatchAuctions < NUM_BIDS_TO_DISPLAY ) then
				button:SetWidth(793);
				buttonHighlight:SetWidth(758);
				BidBidSort:SetWidth(169);
			elseif ( numBatchAuctions == NUM_BIDS_TO_DISPLAY and totalAuctions <= NUM_BIDS_TO_DISPLAY ) then
				button:SetWidth(793);
				buttonHighlight:SetWidth(758);
				BidBidSort:SetWidth(169);
			else
				button:SetWidth(769);
				buttonHighlight:SetWidth(735);
				BidBidSort:SetWidth(145);
			end
			-- Set name and quality color
			color = ITEM_QUALITY_COLORS[quality];
			itemName = getglobal(buttonName.."Name");
			itemName:SetText(name);
			itemName:SetVertexColor(color.r, color.g, color.b);
			-- Set level
			if ( level > UnitLevel("player") ) then
				getglobal(buttonName.."Level"):SetText(RED_FONT_COLOR_CODE..level..FONT_COLOR_CODE_CLOSE);
			else
				getglobal(buttonName.."Level"):SetText(level);
			end
			-- Set bid status
			if ( highBidder ) then
				getglobal(buttonName.."BidStatus"):SetText(GREEN_FONT_COLOR_CODE..HIGH_BIDDER..FONT_COLOR_CODE_CLOSE);
			else
				getglobal(buttonName.."BidStatus"):SetText(RED_FONT_COLOR_CODE..OUTBID..FONT_COLOR_CODE_CLOSE);
			end
			
			-- Set closing time
			getglobal(buttonName.."ClosingTimeText"):SetText(AuctionFrame_GetTimeLeftText(duration));
			getglobal(buttonName.."ClosingTime").tooltip = AuctionFrame_GetTimeLeftTooltipText(duration);
			-- Set item texture, count, and usability
			iconTexture = getglobal(buttonName.."ItemIconTexture");
			iconTexture:SetTexture(texture);
			if ( not canUse ) then
				iconTexture:SetVertexColor(1.0, 0.1, 0.1);
			else
				iconTexture:SetVertexColor(1.0, 1.0, 1.0);
			end
			itemCount = getglobal(buttonName.."ItemCount");
			if ( count > 1 ) then
				itemCount:SetText(count);
				itemCount:Show();
			else
				itemCount:Hide();
			end
			
			-- Set current bid
			-- If not bidAmount set the bid amount to the min bid
			if ( bidAmount == 0 ) then
				bidAmount = minBid;
			end
			MoneyFrame_Update(buttonName.."CurrentBidMoneyFrame", bidAmount);
			-- Set buyout price
			MoneyFrame_Update(buttonName.."BuyoutMoneyFrame", buyoutPrice);
			-- Set highlight
			if ( GetSelectedAuctionItem("bidder") and (offset + i) == GetSelectedAuctionItem("bidder") ) then
				button:LockHighlight();
				
				if ( buyoutPrice > 0 and buyoutPrice >= bidAmount ) then
					local canBuyout = 1;
					if ( GetMoney() < buyoutPrice ) then
						if ( not highBidder or GetMoney()+bidAmount < buyoutPrice ) then
							canBuyout = nil;
						end
					end
					if ( canBuyout ) then
						BidBuyoutButton:Enable();
						AuctionFrame.buyoutPrice = buyoutPrice;
					end
				else
					AuctionFrame.buyoutPrice = nil;
				end
				-- Set bid
				MoneyInputFrame_SetCopper(BidBidPrice, bidAmount + minIncrement);
				
				if ( not highBidder and GetMoney() >= MoneyInputFrame_GetCopper(BidBidPrice) ) then
					BidBidButton:Enable();
				end
			else
				button:UnlockHighlight();
			end
		end
	end

	-- If more than one page of auctions show the next and prev arrows when the scrollframe is scrolled all the way down
	if ( totalAuctions > NUM_AUCTION_ITEMS_PER_PAGE ) then
		if ( isLastSlotEmpty ) then
			BidPrevPageButton:Show();
			BidNextPageButton:Show();
			BidSearchCountText:Show();
			local itemsMin = AuctionFrameBid.page * NUM_AUCTION_ITEMS_PER_PAGE + 1;
			local itemsMax = itemsMin + numBatchAuctions - 1;
			BidSearchCountText:SetText(format(NUMBER_OF_RESULTS_TEMPLATE, itemsMin, itemsMax, totalAuctions));
			if ( AuctionFrameBid.page == 0 ) then
				BidPrevPageButton:Disable();
			else
				BidPrevPageButton:Enable();
			end
			if ( AuctionFrameBid.page == (ceil(totalAuctions/NUM_AUCTION_ITEMS_PER_PAGE) - 1) ) then
				BidNextPageButton:Disable();
			else
				BidNextPageButton:Enable();
			end
		else
			BidPrevPageButton:Hide();
			BidNextPageButton:Hide();
			BidSearchCountText:Hide();
		end
		
		-- Artifically inflate the number of results so the scrollbar scrolls one extra row
		numBatchAuctions = numBatchAuctions + 1;
	else
		BidPrevPageButton:Hide();
		BidNextPageButton:Hide();
		BidSearchCountText:Hide();
	end

	-- Update scrollFrame
	FauxScrollFrame_Update(BidScrollFrame, numBatchAuctions, NUM_BIDS_TO_DISPLAY, AUCTIONS_BUTTON_HEIGHT);
end

function BidButton_OnClick(button)
	if ( not button ) then
		button = this;
	end
	SetSelectedAuctionItem("bidder", button:GetID() + FauxScrollFrame_GetOffset(BidScrollFrame));
	-- Close any auction related popups
	CloseAuctionStaticPopups();
	AuctionFrameBid_Update();
end


-- Auctions tab functions

function AuctionFrameAuctions_OnLoad()
	this:RegisterEvent("AUCTION_OWNED_LIST_UPDATE");
	AuctionsRadioButton_OnClick(2);
end

function AuctionFrameAuctions_OnEvent()
	if ( event == "AUCTION_OWNED_LIST_UPDATE" ) then
		AuctionFrameAuctions_Update();
	end
end

function AuctionFrameAuctions_OnShow()
	AuctionsTitle:SetText(format(AUCTION_TITLE, UnitName("player")));
	--AuctionsRadioButton_OnClick(2);
	--MoneyFrame_Update("AuctionsDepositMoneyFrame", 0);
	AuctionsFrameAuctions_ValidateAuction();
	-- So the get auctions query is only run once per session, after that you only get updates
	if ( not AuctionFrame.gotAuctions ) then
		GetOwnerAuctionItems();
		AuctionFrame.gotAuctions = 1;
	end
	AuctionFrameAuctions.page = 0;
	AuctionFrameAuctions_Update();
end

function AuctionFrameAuctions_Update()
	local numBatchAuctions, totalAuctions = GetNumAuctionItems("owner");
	local auction, buttonName, iconTexture, itemName, color, itemCount;
	local offset = FauxScrollFrame_GetOffset(AuctionsScrollFrame);
	local index;
	local name, texture, count, quality, canUse, minBid, minIncrement, buyoutPrice, duration, bidAmount, highBidder, owner;
	local isLastSlotEmpty;
	local bidAmountMoneyFrame;

	-- Update sort arrows
	SortButton_UpdateArrow(AuctionsQualitySort, "owner", "quality");
	SortButton_UpdateArrow(AuctionsHighBidderSort, "owner", "status");
	SortButton_UpdateArrow(AuctionsDurationSort, "owner", "duration");
	SortButton_UpdateArrow(AuctionsBidSort, "owner", "bid");

	for i=1, NUM_AUCTIONS_TO_DISPLAY do
		index = offset + i + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameAuctions.page);
		auction = getglobal("AuctionsButton"..i);
		-- Show or hide auction buttons
		if ( index > (numBatchAuctions + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameAuctions.page)) ) then
			auction:Hide();
			-- If the last button is empty then set isLastSlotEmpty var
			if ( i == NUM_AUCTIONS_TO_DISPLAY ) then
				isLastSlotEmpty = 1;
			end
		else
			auction:Show();
			
			buttonName = "AuctionsButton"..i;
			name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner =  GetAuctionItemInfo("owner", offset + i);
			duration = GetAuctionItemTimeLeft("owner", offset + i);
			-- Resize button if there isn't a scrollbar
			buttonHighlight = getglobal("AuctionsButton"..i.."Highlight");
			if ( numBatchAuctions < NUM_AUCTIONS_TO_DISPLAY ) then
				auction:SetWidth(599);
				buttonHighlight:SetWidth(565);
				AuctionsBidSort:SetWidth(213);
			elseif ( numBatchAuctions == NUM_AUCTIONS_TO_DISPLAY and totalAuctions <= NUM_AUCTIONS_TO_DISPLAY ) then
				auction:SetWidth(599);
				buttonHighlight:SetWidth(565);
				AuctionsBidSort:SetWidth(213);
			else
				auction:SetWidth(576);
				buttonHighlight:SetWidth(543);
				AuctionsBidSort:SetWidth(193);
			end
			-- Set name and quality color
			color = ITEM_QUALITY_COLORS[quality];
			itemName = getglobal(buttonName.."Name");
			itemName:SetText(name);
			itemName:SetVertexColor(color.r, color.g, color.b);
			-- Set high bidder
			if ( not highBidder ) then
				highBidder = RED_FONT_COLOR_CODE..NO_BIDS..FONT_COLOR_CODE_CLOSE;
			end
			getglobal(buttonName.."HighBidder"):SetText(highBidder);
			-- Set closing time
			getglobal(buttonName.."ClosingTimeText"):SetText(AuctionFrame_GetTimeLeftText(duration));
			getglobal(buttonName.."ClosingTime").tooltip = AuctionFrame_GetTimeLeftTooltipText(duration);
			-- Set item texture, count, and usability
			iconTexture = getglobal(buttonName.."ItemIconTexture");
			iconTexture:SetTexture(texture);
			if ( not canUse ) then
				iconTexture:SetVertexColor(1.0, 0.1, 0.1);
			else
				iconTexture:SetVertexColor(1.0, 1.0, 1.0);
			end
			itemCount = getglobal(buttonName.."ItemCount");
			if ( count > 1 ) then
				itemCount:SetText(count);
				itemCount:Show();
			else
				itemCount:Hide();
			end
			
			-- Handle bid amount
			bidAmountMoneyFrame = getglobal(buttonName.."MoneyFrame");
			if ( bidAmount > 0 ) then
				-- Set high bid
				MoneyFrame_Update(buttonName.."MoneyFrame", bidAmount);
				bidAmountMoneyFrame:SetAlpha(1);
				-- Set cancel price
				auction.cancelPrice = floor(bidAmount * 0.05);
			else
				-- No bids so show minBid and gray it out
				MoneyFrame_Update(buttonName.."MoneyFrame", minBid);
				bidAmountMoneyFrame:SetAlpha(0.5);
				-- No cancel price
				auction.cancelPrice = 0;
			end
			
			-- Set buyout price and adjust bid amount accordingly
			if ( buyoutPrice > 0 ) then
				bidAmountMoneyFrame:SetPoint("RIGHT", buttonName, "RIGHT", 0, 10);
				getglobal(buttonName.."BuyoutMoneyFrame"):Show();
			else
				bidAmountMoneyFrame:SetPoint("RIGHT", buttonName, "RIGHT", 0, 3);
				getglobal(buttonName.."BuyoutMoneyFrame"):Hide();
			end
			MoneyFrame_Update(buttonName.."BuyoutMoneyFrame", buyoutPrice);

			-- Enable/Disable cancel auction button
			if ( GetSelectedAuctionItem("owner") > 0 ) then
				AuctionsCancelAuctionButton:Enable();
			else
				AuctionsCancelAuctionButton:Disable();
			end
			-- Set highlight
			if ( GetSelectedAuctionItem("owner") and index == GetSelectedAuctionItem("owner") ) then
				auction:LockHighlight();
			else
				auction:UnlockHighlight();
			end
		end
	end

	-- If more than one page of auctions show the next and prev arrows when the scrollframe is scrolled all the way down
	if ( totalAuctions > NUM_AUCTION_ITEMS_PER_PAGE ) then
		if ( isLastSlotEmpty ) then
			AuctionsPrevPageButton:Show();
			AuctionsNextPageButton:Show();
			AuctionsSearchCountText:Show();
			local itemsMin = AuctionFrameAuctions.page * NUM_AUCTION_ITEMS_PER_PAGE + 1;
			local itemsMax = itemsMin + numBatchAuctions - 1;
			AuctionsSearchCountText:SetText(format(NUMBER_OF_RESULTS_TEMPLATE, itemsMin, itemsMax, totalAuctions));
			if ( AuctionFrameAuctions.page == 0 ) then
				AuctionsPrevPageButton:Disable();
			else
				AuctionsPrevPageButton:Enable();
			end
			if ( AuctionFrameAuctions.page == (ceil(totalAuctions/NUM_AUCTION_ITEMS_PER_PAGE) - 1) ) then
				AuctionsNextPageButton:Disable();
			else
				AuctionsNextPageButton:Enable();
			end
		else
			AuctionsPrevPageButton:Hide();
			AuctionsNextPageButton:Hide();
			AuctionsSearchCountText:Hide();
		end
		
		-- Artifically inflate the number of results so the scrollbar scrolls one extra row
		numBatchAuctions = numBatchAuctions + 1;
	else
		AuctionsPrevPageButton:Hide();
		AuctionsNextPageButton:Hide();
		AuctionsSearchCountText:Hide();
	end

	if ( GetSelectedAuctionItem("owner") and (GetSelectedAuctionItem("owner") > 0) ) then
		AuctionsCancelAuctionButton:Enable();
	else
		AuctionsCancelAuctionButton:Disable();
	end

	-- Update scrollFrame
	FauxScrollFrame_Update(AuctionsScrollFrame, numBatchAuctions, NUM_AUCTIONS_TO_DISPLAY, AUCTIONS_BUTTON_HEIGHT);
end

function AuctionsButton_OnClick(button)
	if ( not button ) then
		button = this;
	end
	SetSelectedAuctionItem("owner", button:GetID() + FauxScrollFrame_GetOffset(AuctionsScrollFrame));
	-- Close any auction related popups
	CloseAuctionStaticPopups();
	AuctionFrameAuctions.cancelPrice = button.cancelPrice;
	AuctionFrameAuctions_Update();
end

function AuctionsRadioButton_OnClick(index)
	AuctionsShortAuctionButton:SetChecked(nil);
	AuctionsMediumAuctionButton:SetChecked(nil);
	AuctionsLongAuctionButton:SetChecked(nil);
	if ( index == 1 ) then
		AuctionsShortAuctionButton:SetChecked(1);
		AuctionFrameAuctions.duration = 120;
	elseif ( index ==2 ) then
		AuctionsMediumAuctionButton:SetChecked(1);
		AuctionFrameAuctions.duration = 480;
	else
		AuctionsLongAuctionButton:SetChecked(1);
		AuctionFrameAuctions.duration = 1440;
	end
	UpdateDeposit();
end

function UpdateDeposit()
	MoneyFrame_Update("AuctionsDepositMoneyFrame", CalculateAuctionDeposit(AuctionFrameAuctions.duration));
end

function AuctionSellItemButton_OnEvent()
	if ( event == "NEW_AUCTION_UPDATE") then
		local name, texture, count, quality, canUse, price = GetAuctionSellItemInfo();
		AuctionsItemButton:SetNormalTexture(texture);
		AuctionsItemButtonName:SetText(name);
		if ( count > 1 ) then
			AuctionsItemButtonCount:SetText(count);
			AuctionsItemButtonCount:Show();
		else
			AuctionsItemButtonCount:Hide();
		end
		MoneyInputFrame_SetCopper(StartPrice, max(100, floor(price * 1.5)));
		UpdateDeposit();
		MoneyInputFrame_SetCopper(BuyoutPrice, 0);
	end
end

function AuctionsFrameAuctions_ValidateAuction()
	AuctionsCreateAuctionButton:Disable();
	AuctionsBuyoutErrorText:Hide();
	-- No item
	if ( not GetAuctionSellItemInfo() ) then
		return;
	end
	-- Buyout price is less than the start price
	if ( MoneyInputFrame_GetCopper(BuyoutPrice) > 0 and MoneyInputFrame_GetCopper(StartPrice) > MoneyInputFrame_GetCopper(BuyoutPrice) ) then
		AuctionsBuyoutErrorText:Show();
		return;
	end
	-- Start price is 0 or greater than the max allowed
	if ( MoneyInputFrame_GetCopper(StartPrice) < 1 or MoneyInputFrame_GetCopper(StartPrice) > MAXIMUM_BID_PRICE) then
		return;
	end
	AuctionsCreateAuctionButton:Enable();
end

--[[
function AuctionFrame_UpdateTimeLeft(elapsed, type)
	if ( not this.updateCounter ) then
		this.updateCounter = 0;
	end
	if ( this.updateCounter > AUCTION_TIMER_UPDATE_DELAY ) then
		this.updateCounter = 0;	
		local index = this:GetID();
		if ( type == "list" ) then
			index = index + FauxScrollFrame_GetOffset(BrowseScrollFrame);
		elseif ( type == "bidder" ) then
			index = index + FauxScrollFrame_GetOffset(BidScrollFrame);
		elseif ( type == "owner" ) then
			index = index + FauxScrollFrame_GetOffset(AuctionsScrollFrame);
		end
		getglobal(this:GetName().."ClosingTime"):SetText(SecondsToTime(GetAuctionItemTimeLeft(type, index)));
	else
		this.updateCounter = this.updateCounter + elapsed;
	end
end
]]

function AuctionFrame_GetTimeLeftText(id)
	return getglobal("AUCTION_TIME_LEFT"..id);
end

function AuctionFrame_GetTimeLeftTooltipText(id)
	return getglobal("AUCTION_TIME_LEFT"..id.."_DETAIL");
end

function AuctionFrameItem_OnEnter(type, index)
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
	GameTooltip:SetAuctionItem(type, index);
	if ( ShoppingTooltip1:SetAuctionCompareItem(type, index, 1) ) then
		ShoppingTooltip1:SetOwner(GameTooltip, "ANCHOR_NONE");
		ShoppingTooltip1:ClearAllPoints();
		ShoppingTooltip1:SetPoint("TOPLEFT", "GameTooltip", "TOPRIGHT", 0, -10);
		ShoppingTooltip1:SetAuctionCompareItem(type, index, 1);
		ShoppingTooltip1:Show();
	end
	if ( ShoppingTooltip2:SetAuctionCompareItem(type, index, 2) ) then
		ShoppingTooltip2:SetOwner(ShoppingTooltip1, "ANCHOR_NONE");
		ShoppingTooltip2:ClearAllPoints();
		ShoppingTooltip2:SetPoint("TOPLEFT", "ShoppingTooltip1", "TOPRIGHT", 0, 0);
		ShoppingTooltip2:SetAuctionCompareItem(type, index, 2);
		ShoppingTooltip2:Show();
	end

	if ( IsControlKeyDown() ) then
		ShowInspectCursor();
	else
		ResetCursor();
	end
end

-- SortButton functions
function SortButton_UpdateArrow(button, type, sort)
	if ( IsAuctionSortReversed(type, sort) ) then
		getglobal(button:GetName().."Arrow"):SetTexCoord(0, 0.5625, 1.0, 0);
	else
		getglobal(button:GetName().."Arrow"):SetTexCoord(0, 0.5625, 0, 1.0);
	end
end

-- Function to close popups if another auction item is selected
function CloseAuctionStaticPopups()
	StaticPopup_Hide("BUYOUT_AUCTION");
	StaticPopup_Hide("CANCEL_AUCTION");
end
