
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
MAXIMUM_BID_PRICE = 99999999999999;

-- keep last item sent to auction & it's price
LAST_ITEM_AUCTIONED = "";
LAST_ITEM_COUNT = 0;
LAST_ITEM_START_BID = 0;
LAST_ITEM_BUYOUT = 0;

local BROWSE_PARAM_INDEX_PAGE = 7;
local PRICE_TYPE_UNIT = 1;
local PRICE_TYPE_STACK = 2;

AuctionSort = { };

-- owner sorts
AuctionSort["owner_status"] = {
	{ column = "quantity",	reverse = true	},
	{ column = "bid",		reverse = false	},
	{ column = "name",		reverse = false	},
	{ column = "level",		reverse = true	},
	{ column = "quality",	reverse = false	},
	{ column = "duration",	reverse = false	},
	{ column = "status",	reverse = false	},
};

AuctionSort["owner_bid"] = {
	{ column = "quantity",	reverse = true	},
	{ column = "name",		reverse = false	},
	{ column = "level",		reverse = true	},
	{ column = "quality",	reverse = false	},
	{ column = "duration",	reverse = false	},
	{ column = "status",	reverse = false	},
	{ column = "bid",		reverse = false	},
};

AuctionSort["owner_quality"] = {
	{ column = "bid",		reverse = false	},
	{ column = "quantity",	reverse = true	},
	{ column = "minbidbuyout",	reverse = false	},
	{ column = "name",		reverse = false	},
	{ column = "level",		reverse = true	},
	{ column = "quality",	reverse = false	},
};

AuctionSort["owner_duration"] = {
	{ column = "quantity",	reverse = true	},
	{ column = "bid",		reverse = false	},
	{ column = "name",		reverse = false	},
	{ column = "level",		reverse = true	},
	{ column = "quality",	reverse = false	},
	{ column = "status",	reverse = false	},
	{ column = "duration",	reverse = false	},
};

-- bidder sorts
AuctionSort["bidder_quality"] = {
	{ column =  "bid",		reverse = false	},
	{ column =  "quantity",	reverse = true	},
	{ column =  "minbidbuyout",	reverse = false	},
	{ column =  "name",		reverse = false	},
	{ column =  "level",	reverse = true	},
	{ column =  "quality",	reverse = false	},
};

AuctionSort["bidder_level"] = {
	{ column =  "minbidbuyout",	reverse = true	},
	{ column =  "status",	reverse = true	},
	{ column =  "bid",		reverse = true	},
	{ column =  "duration",	reverse = true	},
	{ column =  "quantity",	reverse = false	},
	{ column =  "name",		reverse = true	},
	{ column =  "quality",	reverse = true	},
	{ column =  "level",	reverse = false	},
};

AuctionSort["bidder_buyout"] = {
	{ column =  "quantity",	reverse = true	},
	{ column =  "name",		reverse = false	},
	{ column =  "level",	reverse = true	},
	{ column =  "quality",	reverse = false	},
	{ column =  "status",	reverse = false	},
	{ column =  "bid",		reverse = false	},
	{ column =  "duration",	reverse = false	},
	{ column =  "buyout",	reverse = false	},
};
 
AuctionSort["bidder_status"] = {
	{ column =  "quantity",	reverse = true	},
	{ column =  "name",		reverse = false	},
	{ column =  "level",	reverse = true	},
	{ column =  "quality",	reverse = false	},
	{ column =  "minbidbuyout",	reverse = false	},
	{ column =  "bid",		reverse = false	},
	{ column =  "duration", reverse = false	},
	{ column =  "status",	reverse = false	},
};

AuctionSort["bidder_bid"] = {
	{ column =  "quantity",	reverse = true	},
	{ column =  "name",		reverse = false	},
	{ column =  "level",	reverse = true	},
	{ column =  "quality",	reverse = false	},
	{ column =  "minbidbuyout",	reverse = false	},
	{ column =  "status",	reverse = false	},
	{ column =  "duration",	reverse = false	},
	{ column =  "bid",		reverse = false	},
};

AuctionSort["bidder_duration"] = {
	{ column =  "quantity",	reverse = true	},
	{ column =  "name",		reverse = false	},
	{ column =  "level",	reverse = true	},
	{ column =  "quality",	reverse = false	},
	{ column =  "minbidbuyout",	reverse = false	},
	{ column =  "status",	reverse = false	},
	{ column =  "bid",		reverse = false	},
	{ column =  "duration",	reverse = false	},
};

-- list sorts
AuctionSort["list_level"] = {
	{ column = "duration",	reverse = true	},
	{ column = "bid",		reverse = true	},
	{ column = "quantity",	reverse = false	},
	{ column = "minbidbuyout",	reverse = true	},
	{ column = "name",		reverse = true	},
	{ column = "quality",	reverse = true	},
	{ column = "level",		reverse = false	},
};
AuctionSort["list_duration"] = {
	{ column = "bid",		reverse = false	},
	{ column = "quantity",	reverse = true	},
	{ column = "minbidbuyout",	reverse = false	},
	{ column = "name",		reverse = false	},
	{ column = "level",		reverse = true	},
	{ column = "quality",	reverse = false	},
	{ column = "duration",	reverse = false	},
};
AuctionSort["list_seller"] = {
	{ column = "duration",	reverse = false	},
	{ column = "bid",		reverse = false },
	{ column = "quantity",	reverse = true	},
	{ column = "minbidbuyout",	reverse = false	},
	{ column = "name",		reverse = false	},
	{ column = "level",		reverse = true	},
	{ column = "quality",	reverse = false	},
	{ column = "seller",	reverse = false	},
};
AuctionSort["list_bid"] = {
	{ column = "duration",	reverse = false	},
	{ column = "quantity",	reverse = true	},
	{ column = "name",		reverse = false	},
	{ column = "level",		reverse = true	},
	{ column = "quality",	reverse = false	},
	{ column = "bid",		reverse = false	},
};

AuctionSort["list_quality"] = {
	{ column = "duration",	reverse = false	},
	{ column = "bid",		reverse = false	},
	{ column = "quantity",	reverse = true	},
	{ column = "minbidbuyout",	reverse = false	},
	{ column = "name",		reverse = false	},
	{ column = "level",		reverse = true	},
	{ column = "quality",	reverse = false	},
};


UIPanelWindows["AuctionFrame"] = { area = "doublewide", pushable = 0, width = 840 };

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
	text = BUYOUT_AUCTION_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		PlaceAuctionBid(AuctionFrame.type, GetSelectedAuctionItem(AuctionFrame.type), AuctionFrame.buyoutPrice);
	end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, AuctionFrame.buyoutPrice);
	end,
	hasMoneyFrame = 1,
	showAlert = 1,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["BID_AUCTION"] = {
	text = BID_AUCTION_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		PlaceAuctionBid(AuctionFrame.type, GetSelectedAuctionItem(AuctionFrame.type), MoneyInputFrame_GetCopper(BrowseBidPrice));
	end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, MoneyInputFrame_GetCopper(BrowseBidPrice));
	end,
	hasMoneyFrame = 1,
	showAlert = 1,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["CANCEL_AUCTION"] = {
	text = CANCEL_AUCTION_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		CancelAuction(GetSelectedAuctionItem("owner"));
	end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, AuctionFrameAuctions.cancelPrice);
		if ( AuctionFrameAuctions.cancelPrice > 0 ) then
			self.text:SetText(CANCEL_AUCTION_CONFIRMATION_MONEY);
		else
			self.text:SetText(CANCEL_AUCTION_CONFIRMATION);
		end
		
	end,
	hasMoneyFrame = 1,
	showAlert = 1,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

function AuctionFrame_OnLoad (self)

	-- Tab Handling code
	PanelTemplates_SetNumTabs(self, 3);
	PanelTemplates_SetTab(self, 1);
	AuctionsBuyoutText:SetText(BUYOUT_PRICE.." |cff808080("..OPTIONAL..")|r");

	-- Set focus rules
	AuctionsStackSizeEntry.prevFocus = BuyoutPriceCopper;
	AuctionsStackSizeEntry.nextFocus = AuctionsNumStacksEntry;
	AuctionsNumStacksEntry.prevFocus = AuctionsStackSizeEntry;
	AuctionsNumStacksEntry.nextFocus = StartPriceGold;
	
	MoneyInputFrame_SetPreviousFocus(BrowseBidPrice, BrowseMaxLevel);
	MoneyInputFrame_SetNextFocus(BrowseBidPrice, BrowseName);

	MoneyInputFrame_SetPreviousFocus(BidBidPrice, BidBidPriceCopper);
	MoneyInputFrame_SetNextFocus(BidBidPrice, BidBidPriceGold);

	MoneyInputFrame_SetPreviousFocus(StartPrice, AuctionsNumStacksEntry);
	MoneyInputFrame_SetNextFocus(StartPrice, BuyoutPriceGold);

	MoneyInputFrame_SetPreviousFocus(BuyoutPrice, StartPriceCopper);
	MoneyInputFrame_SetNextFocus(BuyoutPrice, AuctionsStackSizeEntry);
	
	-- Init search dot count
	AuctionFrameBrowse.dotCount = 0;
	AuctionFrameBrowse.isSearchingThrottle = 0;

	AuctionFrameBrowse.page = 0;
	FauxScrollFrame_SetOffset(BrowseScrollFrame,0);

	AuctionFrameBid.page = 0;
	FauxScrollFrame_SetOffset(BidScrollFrame,0);
	GetBidderAuctionItems(AuctionFrameBid.page);

	AuctionFrameAuctions.page = 0;
	FauxScrollFrame_SetOffset(AuctionsScrollFrame,0);
	GetOwnerAuctionItems(AuctionFrameAuctions.page);
	
	MoneyFrame_SetMaxDisplayWidth(AuctionFrameMoneyFrame, 160);
end

function AuctionFrame_Show()
	if ( AuctionFrame:IsShown() ) then
		AuctionFrameBrowse_Update();
		AuctionFrameBid_Update();
		AuctionFrameAuctions_Update();
	else
		ShowUIPanel(AuctionFrame);

		AuctionFrameBrowse.page = 0;
		FauxScrollFrame_SetOffset(BrowseScrollFrame,0);

		AuctionFrameBid.page = 0;
		FauxScrollFrame_SetOffset(BidScrollFrame,0);
		GetBidderAuctionItems(AuctionFrameBid.page);

		AuctionFrameAuctions.page = 0;
		FauxScrollFrame_SetOffset(AuctionsScrollFrame,0);
		GetOwnerAuctionItems(AuctionFrameAuctions.page)

		BrowsePrevPageButton.isEnabled = false;
		BrowseNextPageButton.isEnabled = false;
		
		if ( not AuctionFrame:IsShown() ) then
			CloseAuctionHouse();
		end
	end
end

function AuctionFrame_Hide()
	HideUIPanel(AuctionFrame);
end

function AuctionFrame_OnShow (self)
	self.gotAuctions = nil;
	self.gotBids = nil;
	AuctionFrameTab_OnClick(AuctionFrameTab1);
	SetPortraitTexture(AuctionPortraitTexture,"npc");
	BrowseNoResultsText:SetText(BROWSE_SEARCH_TEXT);
	PlaySound("AuctionWindowOpen");
end

function AuctionFrameTab_OnClick(self, button, down, index)
	local index = self:GetID();
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
		AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Bot");
		AuctionFrameBotRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotRight");
		AuctionFrameBrowse:Show();
		AuctionFrame.type = "list";
		SetAuctionsTabShowing(false);
	elseif ( index == 2 ) then
		-- Bids tab
		AuctionFrameTopLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-TopLeft");
		AuctionFrameTop:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Top");
		AuctionFrameTopRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-TopRight");
		AuctionFrameBotLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotLeft");
		AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Bot");
		AuctionFrameBotRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Bid-BotRight");
		AuctionFrameBid:Show();
		AuctionFrame.type = "bidder";
		SetAuctionsTabShowing(false);
	elseif ( index == 3 ) then
		-- Auctions tab
		AuctionFrameTopLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-TopLeft");
		AuctionFrameTop:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Top");
		AuctionFrameTopRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-TopRight");
		AuctionFrameBotLeft:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-BotLeft");
		AuctionFrameBot:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-Bot");
		AuctionFrameBotRight:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-Auction-BotRight");
		AuctionFrameAuctions:Show();
		SetAuctionsTabShowing(true);
	end
end

-- Browse tab functions

function AuctionFrameBrowse_OnLoad(self)
	self:RegisterEvent("AUCTION_ITEM_LIST_UPDATE");

	-- set default sort
	AuctionFrame_SetSort("list", "quality", false);
	
	-- initialize class filter array
	AuctionFrameBrowse_InitClasses(GetAuctionItemClasses());
end

function AuctionFrameBrowse_OnShow()
	AuctionFrameBrowse_Update();
	AuctionFrameFilters_Update();
end

function AuctionFrameBrowse_UpdateArrows()
	SortButton_UpdateArrow(BrowseQualitySort, "list", "quality");
	SortButton_UpdateArrow(BrowseLevelSort, "list", "level");
	SortButton_UpdateArrow(BrowseDurationSort, "list", "duration");
	SortButton_UpdateArrow(BrowseHighBidderSort, "list", "seller");
	SortButton_UpdateArrow(BrowseCurrentBidSort, "list", "bid");
end

function AuctionFrameBrowse_OnEvent(self, event, ...)
	if ( event == "AUCTION_ITEM_LIST_UPDATE" ) then
		AuctionFrameBrowse_Update();
		-- Stop "searching" messaging
		AuctionFrameBrowse.isSearching = nil;
		BrowseNoResultsText:SetText(BROWSE_NO_RESULTS);
		-- update arrows now that we're not searching
		AuctionFrameBrowse_UpdateArrows();
	end
end

function BrowseButton_OnClick(button)
	assert(button);
	
	if ( GetCVarBool("auctionDisplayOnCharacter") ) then
		DressUpItemLink(GetAuctionItemLink("list", button:GetID() + FauxScrollFrame_GetOffset(BrowseScrollFrame)));
	end
	SetSelectedAuctionItem("list", button:GetID() + FauxScrollFrame_GetOffset(BrowseScrollFrame));
	-- Close any auction related popups
	CloseAuctionStaticPopups();
	AuctionFrameBrowse_Update();
end

function BrowseDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, BrowseDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(BrowseDropDown,-1);
end

function BrowseDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	info.text = ALL;
	info.value = -1;
	info.func = BrowseDropDown_OnClick;
	UIDropDownMenu_AddButton(info);
	for i=0, getn(ITEM_QUALITY_COLORS)-2  do
		info.text = _G["ITEM_QUALITY"..i.."_DESC"];
		info.value = i;
		info.func = BrowseDropDown_OnClick;
		info.checked = nil;
		UIDropDownMenu_AddButton(info);
	end
end

function BrowseDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedValue(BrowseDropDown, self.value);
end

function AuctionFrameBrowse_InitClasses(...)
	for i=1, select("#", ...) do
		CLASS_FILTERS[i] = select(i, ...);
	end
end

function AuctionFrameBrowse_Reset(self)
	BrowseName:SetText("");
	BrowseMinLevel:SetText("");
	BrowseMaxLevel:SetText("");
	IsUsableCheckButton:SetChecked(0);
	UIDropDownMenu_SetSelectedValue(BrowseDropDown,-1);

	-- reset the filters
	OPEN_FILTER_LIST = {};
	AuctionFrameBrowse.selectedClass = nil;
	AuctionFrameBrowse.selectedClassIndex = nil;
	AuctionFrameBrowse.selectedSubclass = nil;
	AuctionFrameBrowse.selectedSubclassIndex = nil;
	AuctionFrameBrowse.selectedInvtype = nil;
	AuctionFrameBrowse.selectedInvtypeIndex = nil;

	AuctionFrameFilters_Update()
	self:Disable();
end

function BrowseResetButton_OnUpdate(self, elapsed)
	if ( (BrowseName:GetText() == "") and (BrowseMinLevel:GetText() == "") and (BrowseMaxLevel:GetText() == "") and
	     (not IsUsableCheckButton:GetChecked()) and (UIDropDownMenu_GetSelectedValue(BrowseDropDown) == -1) and
	     (not AuctionFrameBrowse.selectedClass) and (not AuctionFrameBrowse.selectedSubclass) and (not AuctionFrameBrowse.selectedInvtype) )
	then
		self:Disable();
	else
		self:Enable();
	end
end

function AuctionFrame_SetSort(sortTable, sortColumn, oppositeOrder)
	-- clear the existing sort.
	SortAuctionClearSort(sortTable);

	-- set the columns
	for index, row in pairs(AuctionSort[sortTable.."_"..sortColumn]) do
		if (oppositeOrder) then
			SortAuctionSetSort(sortTable, row.column, not row.reverse);
		else
			SortAuctionSetSort(sortTable, row.column, row.reverse);
		end
	end
end

function AuctionFrame_OnClickSortColumn(sortTable, sortColumn)
	-- change the sort as appropriate
	local existingSortColumn, existingSortReverse = GetAuctionSort(sortTable, 1);
	local oppositeOrder = false;
	if (existingSortColumn and (existingSortColumn == sortColumn)) then
		oppositeOrder = not existingSortReverse;
	elseif (sortColumn == "level") then
		oppositeOrder = true;
	end

	-- set the new sort order
	AuctionFrame_SetSort(sortTable, sortColumn, oppositeOrder);

	-- apply the sort
	if (sortTable == "list") then
		AuctionFrameBrowse_Search();
	else
		SortAuctionApplySort(sortTable);
	end
end

local prevBrowseParams;
local function AuctionFrameBrowse_SearchHelper(...)
	local text, minLevel, maxLevel, invType, class, subclass, page, usable, rarity = ...;

	if ( not prevBrowseParams ) then
		-- if we are doing a search for the first time then create the browse param cache
		prevBrowseParams = { };
	else
		-- if we have already done a browse then see if any of the params have changed (except for the page number)
		local param;
		for i = 1, select('#', ...) do
			if ( i ~= BROWSE_PARAM_INDEX_PAGE and select(i, ...) ~= prevBrowseParams[i] ) then
				-- if we detect a change then we want to reset the page number back to the first page
				page = 0;
				AuctionFrameBrowse.page = page;
				break;
			end
		end
	end

	QueryAuctionItems(text, minLevel, maxLevel, invType, class, subclass, page, usable, rarity);

	-- store this query's params so we can compare them with the next set of params we get
	for i = 1, select('#', ...) do
		if ( i == BROWSE_PARAM_INDEX_PAGE ) then
			prevBrowseParams[i] = page;
		else
			prevBrowseParams[i] = select(i, ...);
		end
	end
end

function AuctionFrameBrowse_Search()
	if ( not AuctionFrameBrowse.page ) then
		AuctionFrameBrowse.page = 0;
	end

	AuctionFrameBrowse_SearchHelper(BrowseName:GetText(), BrowseMinLevel:GetText(), BrowseMaxLevel:GetText(), AuctionFrameBrowse.selectedInvtypeIndex, AuctionFrameBrowse.selectedClassIndex, AuctionFrameBrowse.selectedSubclassIndex, AuctionFrameBrowse.page, IsUsableCheckButton:GetChecked(), UIDropDownMenu_GetSelectedValue(BrowseDropDown));

	-- Start "searching" messaging
	AuctionFrameBrowse.isSearching = 1;
end

function BrowseSearchButton_OnUpdate(self, elapsed)
	if ( CanSendAuctionQuery("list") ) then
		self:Enable();
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
		BrowseQualitySort:Enable();
		BrowseLevelSort:Enable();
		BrowseDurationSort:Enable();
		BrowseHighBidderSort:Enable();
		BrowseCurrentBidSort:Enable();
		AuctionFrameBrowse_UpdateArrows();
	else
		self:Disable();
		BrowsePrevPageButton:Disable();
		BrowseNextPageButton:Disable();
		BrowseQualitySort:Disable();
		BrowseLevelSort:Disable();
		BrowseDurationSort:Disable();
		BrowseHighBidderSort:Disable();
		BrowseCurrentBidSort:Disable();
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
			AuctionFrameBrowse.isSearchingThrottle = AuctionFrameBrowse.isSearchingThrottle - elapsed;
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
	index = offset;
	for i=1, NUM_FILTERS_TO_DISPLAY do
		button = _G["AuctionFilterButton"..i];
		if ( getn(OPEN_FILTER_LIST) > NUM_FILTERS_TO_DISPLAY ) then
			button:SetWidth(136);
		else
			button:SetWidth(156);
		end

		index = index + 1;
		if ( index <= getn(OPEN_FILTER_LIST) ) then
			info = OPEN_FILTER_LIST[index];
			while ((info[2] == "invtype") and (not info[6])) do
				index = index + 1
				if ( index <= getn(OPEN_FILTER_LIST) ) then
					info = OPEN_FILTER_LIST[index];
				else
					info = nil;
					button:Hide();
					break;
				end
			end

			if ( info ) then
				FilterButton_SetType(button, info[2], info[1], info[5]);
				button.index = info[3];
				if ( info[4] ) then
					button:LockHighlight();
				else
					button:UnlockHighlight();
				end
				button:Show();
			end
		else
			button:Hide();
		end
	end
end

function AuctionFrameFilters_UpdateSubClasses(...)
	local subClass;
	for i=1, select("#", ...) do
		subClass = HIGHLIGHT_FONT_COLOR_CODE..select(i, ...)..FONT_COLOR_CODE_CLOSE; 
		if ( AuctionFrameBrowse.selectedSubclass and AuctionFrameBrowse.selectedSubclass == subClass ) then
			tinsert(OPEN_FILTER_LIST, {select(i, ...), "subclass", i, 1});
			AuctionFrameFilters_UpdateInvTypes(GetAuctionInvTypes(AuctionFrameBrowse.selectedClassIndex,i));
		else
			tinsert(OPEN_FILTER_LIST, {select(i, ...), "subclass", i, nil});
		end
	end
end

function AuctionFrameFilters_UpdateInvTypes(...)
	local invType, isLast, idx;
	for i=1, select("#", ...), 2 do
-- each type has 2 args: token name(i), display in list(i+1)
		idx = (i + 1) / 2;
		invType = HIGHLIGHT_FONT_COLOR_CODE.._G[select(i, ...)]..FONT_COLOR_CODE_CLOSE; 
		if ( (i + 1) == select("#", ...) ) then
			isLast = 1;
		end

		if ( AuctionFrameBrowse.selectedInvtypeIndex and AuctionFrameBrowse.selectedInvtypeIndex == idx ) then
			tinsert(OPEN_FILTER_LIST, {invType, "invtype", idx, 1, isLast, select(i+1, ...)} );
		else
			tinsert(OPEN_FILTER_LIST, {invType, "invtype", idx, nil, isLast, select(i+1, ...)} );
		end
	end
end

function FilterButton_SetType(button, type, text, isLast)
	local normalText = _G[button:GetName().."NormalText"];
	local normalTexture = _G[button:GetName().."NormalTexture"];
	local line = _G[button:GetName().."Lines"];
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

function AuctionFrameFilter_OnClick(self, button)
	if ( self.type == "class" ) then
		if ( AuctionFrameBrowse.selectedClass == self:GetText() ) then
			AuctionFrameBrowse.selectedClass = nil;
			AuctionFrameBrowse.selectedClassIndex = nil;
		else
			AuctionFrameBrowse.selectedClass = self:GetText();
			AuctionFrameBrowse.selectedClassIndex = self.index;
		end
		AuctionFrameBrowse.selectedSubclass = nil;
		AuctionFrameBrowse.selectedSubclassIndex = nil;
		AuctionFrameBrowse.selectedInvtype = nil;
		AuctionFrameBrowse.selectedInvtypeIndex = nil;
	elseif ( self.type == "subclass" ) then
		if ( AuctionFrameBrowse.selectedSubclass == self:GetText() ) then
			AuctionFrameBrowse.selectedSubclass = nil;
			AuctionFrameBrowse.selectedSubclassIndex = nil;
		else
			AuctionFrameBrowse.selectedSubclass = self:GetText();
			AuctionFrameBrowse.selectedSubclassIndex = self.index;
		end
		AuctionFrameBrowse.selectedInvtype = nil;
		AuctionFrameBrowse.selectedInvtypeIndex = nil;
	elseif ( self.type == "invtype" ) then
		AuctionFrameBrowse.selectedInvtype = self:GetText();
		AuctionFrameBrowse.selectedInvtypeIndex = self.index;
	end
	AuctionFrameFilters_Update()
end

function AuctionFrameBrowse_Update()
	local numBatchAuctions, totalAuctions = GetNumAuctionItems("list");
	local button, buttonName, buttonHighlight, iconTexture, itemName, color, itemCount, moneyFrame, yourBidText, buyoutFrame, buyoutMoney;
	local offset = FauxScrollFrame_GetOffset(BrowseScrollFrame);
	local index;
	local isLastSlotEmpty;
	local name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, duration, bidAmount, highBidder, owner;
	local displayedPrice, requiredBid;
	BrowseBidButton:Disable();
	BrowseBuyoutButton:Disable();
	-- Update sort arrows
	AuctionFrameBrowse_UpdateArrows();

	-- Show the no results text if no items found
	if ( numBatchAuctions == 0 ) then
		BrowseNoResultsText:Show();
	else
		BrowseNoResultsText:Hide();
	end

	for i=1, NUM_BROWSE_TO_DISPLAY do
		index = offset + i + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page);
		button = _G["BrowseButton"..i];
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
			if ( not name ) then	--Bug  145328
				button:Hide();
				-- If the last button is empty then set isLastSlotEmpty var
				isLastSlotEmpty = (i == NUM_BROWSE_TO_DISPLAY);
			end
			duration = GetAuctionItemTimeLeft("list", offset + i);

			-- Resize button if there isn't a scrollbar
			buttonHighlight = _G["BrowseButton"..i.."Highlight"];
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
			itemName = _G[buttonName.."Name"];
			itemName:SetText(name);
			itemName:SetVertexColor(color.r, color.g, color.b);
			-- Set level
			if ( level > UnitLevel("player") ) then
				_G[buttonName.."Level"]:SetText(RED_FONT_COLOR_CODE..level..FONT_COLOR_CODE_CLOSE);
			else
				_G[buttonName.."Level"]:SetText(level);
			end
			-- Set closing time
			_G[buttonName.."ClosingTimeText"]:SetText(AuctionFrame_GetTimeLeftText(duration));
			_G[buttonName.."ClosingTime"].tooltip = AuctionFrame_GetTimeLeftTooltipText(duration);
			-- Set item texture, count, and usability
			iconTexture = _G[buttonName.."ItemIconTexture"];
			iconTexture:SetTexture(texture);
			if ( not canUse ) then
				iconTexture:SetVertexColor(1.0, 0.1, 0.1);
			else
				iconTexture:SetVertexColor(1.0, 1.0, 1.0);
			end
			itemCount = _G[buttonName.."ItemCount"];
			if ( count > 1 ) then
				itemCount:SetText(count);
				itemCount:Show();
			else
				itemCount:Hide();
			end
			-- Set high bid
			moneyFrame = _G[buttonName.."MoneyFrame"];
			-- If not bidAmount set the bid amount to the min bid
			if ( bidAmount == 0 ) then
				displayedPrice = minBid;
				requiredBid = minBid;
			else
				displayedPrice = bidAmount;
				requiredBid = bidAmount + minIncrement ;
			end
			MoneyFrame_Update(moneyFrame:GetName(), displayedPrice);

			yourBidText = _G[buttonName.."YourBidText"];
			if ( highBidder ) then
				yourBidText:Show();
			else
				yourBidText:Hide();
			end
			
			if ( requiredBid >= MAXIMUM_BID_PRICE ) then
				-- Lie about our buyout price
				buyoutPrice = requiredBid;
			end
			buyoutFrame = _G[buttonName.."BuyoutFrame"];
			if ( buyoutPrice > 0 ) then
				moneyFrame:SetPoint("RIGHT", button, "RIGHT", 10, 10);
				buyoutMoney = _G[buyoutFrame:GetName().."Money"];
				MoneyFrame_Update(buyoutMoney, buyoutPrice);
				buyoutFrame:Show();
			else
				moneyFrame:SetPoint("RIGHT", button, "RIGHT", 10, 3);
				buyoutFrame:Hide();
			end
			-- Set high bidder
			--if ( not highBidder ) then
			--	highBidder = RED_FONT_COLOR_CODE..NO_BIDS..FONT_COLOR_CODE_CLOSE;
			--end
			_G[buttonName.."HighBidder"]:SetText(owner);

			button.bidAmount = displayedPrice;
			button.buyoutPrice = buyoutPrice;
			button.itemCount = count;

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
					if ( canBuyout and (owner ~= UnitName("player")) ) then
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
		BrowsePrevPageButton.isEnabled = (AuctionFrameBrowse.page ~= 0);
		BrowseNextPageButton.isEnabled = (AuctionFrameBrowse.page ~= (ceil(totalAuctions/NUM_AUCTION_ITEMS_PER_PAGE) - 1));
		if ( isLastSlotEmpty ) then
			BrowseSearchCountText:Show();
			local itemsMin = AuctionFrameBrowse.page * NUM_AUCTION_ITEMS_PER_PAGE + 1;
			local itemsMax = itemsMin + numBatchAuctions - 1;
			BrowseSearchCountText:SetFormattedText(NUMBER_OF_RESULTS_TEMPLATE, itemsMin, itemsMax, totalAuctions);
		else
			BrowseSearchCountText:Hide();
		end
		
		-- Artifically inflate the number of results so the scrollbar scrolls one extra row
		numBatchAuctions = numBatchAuctions + 1;
	else
		BrowsePrevPageButton.isEnabled = false;
		BrowseNextPageButton.isEnabled = false;
		BrowseSearchCountText:Hide();
	end
	FauxScrollFrame_Update(BrowseScrollFrame, numBatchAuctions, NUM_BROWSE_TO_DISPLAY, AUCTIONS_BUTTON_HEIGHT);
end

-- Bid tab functions

function AuctionFrameBid_OnLoad(self)
	self:RegisterEvent("AUCTION_BIDDER_LIST_UPDATE");

	-- set default sort
	AuctionFrame_SetSort("bidder", "duration", false);
end

function AuctionFrameBid_OnEvent(self, event, ...)
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
	AuctionFrameBid_Update();
end

function AuctionFrameBid_Update()
	local numBatchAuctions, totalAuctions = GetNumAuctionItems("bidder");
	local button, buttonName, buttonHighlight, iconTexture, itemName, color, itemCount;
	local offset = FauxScrollFrame_GetOffset(BidScrollFrame);
	local index;
	local isLastSlotEmpty;
	local name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, duration, bidAmount, highBidder, owner;
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
		button = _G["BidButton"..i];
		-- Show or hide auction buttons
		if ( index > numBatchAuctions ) then
			button:Hide();
			-- If the last button is empty then set isLastSlotEmpty var
			isLastSlotEmpty = (i == NUM_BIDS_TO_DISPLAY);
		else
			button:Show();
			buttonName = "BidButton"..i;
			name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner =  GetAuctionItemInfo("bidder", index);
			duration = GetAuctionItemTimeLeft("bidder", offset + i);

			-- Resize button if there isn't a scrollbar
			buttonHighlight = _G["BidButton"..i.."Highlight"];
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
			itemName = _G[buttonName.."Name"];
			itemName:SetText(name);
			itemName:SetVertexColor(color.r, color.g, color.b);
			-- Set level
			if ( level > UnitLevel("player") ) then
				_G[buttonName.."Level"]:SetText(RED_FONT_COLOR_CODE..level..FONT_COLOR_CODE_CLOSE);
			else
				_G[buttonName.."Level"]:SetText(level);
			end
			-- Set bid status
			if ( highBidder ) then
				_G[buttonName.."BidStatus"]:SetText(GREEN_FONT_COLOR_CODE..HIGH_BIDDER..FONT_COLOR_CODE_CLOSE);
			else
				_G[buttonName.."BidStatus"]:SetText(RED_FONT_COLOR_CODE..OUTBID..FONT_COLOR_CODE_CLOSE);
			end
			
			-- Set closing time
			_G[buttonName.."ClosingTimeText"]:SetText(AuctionFrame_GetTimeLeftText(duration));
			_G[buttonName.."ClosingTime"].tooltip = AuctionFrame_GetTimeLeftTooltipText(duration);
			-- Set item texture, count, and usability
			iconTexture = _G[buttonName.."ItemIconTexture"];
			iconTexture:SetTexture(texture);
			if ( not canUse ) then
				iconTexture:SetVertexColor(1.0, 0.1, 0.1);
			else
				iconTexture:SetVertexColor(1.0, 1.0, 1.0);
			end
			itemCount = _G[buttonName.."ItemCount"];
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

			button.bidAmount = bidAmount;
			button.buyoutPrice = buyoutPrice;
			button.itemCount = count;

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
			BidSearchCountText:Show();
			BidSearchCountText:SetFormattedText(SINGLE_PAGE_RESULTS_TEMPLATE, totalAuctions);
		else
			BidSearchCountText:Hide();
		end
		
		-- Artifically inflate the number of results so the scrollbar scrolls one extra row
		numBatchAuctions = numBatchAuctions + 1;
	else
		BidSearchCountText:Hide();
	end

	-- Update scrollFrame
	FauxScrollFrame_Update(BidScrollFrame, numBatchAuctions, NUM_BIDS_TO_DISPLAY, AUCTIONS_BUTTON_HEIGHT);
end

function BidButton_OnClick(button)
	assert(button)
	
	if ( GetCVarBool("auctionDisplayOnCharacter") ) then
		DressUpItemLink(GetAuctionItemLink("bidder", button:GetID() + FauxScrollFrame_GetOffset(BidScrollFrame)));
	end
	SetSelectedAuctionItem("bidder", button:GetID() + FauxScrollFrame_GetOffset(BidScrollFrame));
	-- Close any auction related popups
	CloseAuctionStaticPopups();
	AuctionFrameBid_Update();
end


-- Auctions tab functions

function AuctionFrameAuctions_OnLoad(self)
	self:RegisterEvent("AUCTION_OWNED_LIST_UPDATE");
	self:RegisterEvent("AUCTION_MULTISELL_START");
	self:RegisterEvent("AUCTION_MULTISELL_UPDATE");
	self:RegisterEvent("AUCTION_MULTISELL_FAILURE");
	-- set default sort
	AuctionFrame_SetSort("owner", "duration", false);

	UIDropDownMenu_DisableDropDown(PriceDropDown);
end

function AuctionFrameAuctions_OnEvent(self, event, ...)
	if ( event == "AUCTION_OWNED_LIST_UPDATE" ) then
		AuctionFrameAuctions_Update();
	elseif ( event == "AUCTION_MULTISELL_START" ) then
		local arg1 = ...;
		AuctionsCreateAuctionButton:Disable();
		MoneyInputFrame_ClearFocus(StartPrice);
		MoneyInputFrame_ClearFocus(BuyoutPrice);
		AuctionsStackSizeEntry:ClearFocus();
		AuctionsNumStacksEntry:ClearFocus();
		AuctionsBlockFrame:Show();
		AuctionProgressBar:SetMinMaxValues(0, arg1);
		AuctionProgressBar:SetValue(0.01);		-- TEMPORARY
		AuctionProgressBarText:SetFormattedText(AUCTION_CREATING, 0, arg1);
		local _, iconTexture =  GetAuctionSellItemInfo();
		AuctionProgressBarIcon:SetTexture(iconTexture);
		AuctionProgressFrame:Show();
	elseif ( event == "AUCTION_MULTISELL_UPDATE" ) then
		local arg1, arg2 = ...;
		AuctionProgressBar:SetValue(arg1);
		AuctionProgressBarText:SetFormattedText(AUCTION_CREATING, arg1, arg2);
		if ( arg1 == arg2 ) then
			AuctionsBlockFrame:Hide();
			AuctionProgressFrame.fadeOut = true;
		end
	elseif ( event == "AUCTION_MULTISELL_FAILURE" ) then
		AuctionsBlockFrame:Hide();
		AuctionProgressFrame:Hide();
	end
end

function AuctionFrameAuctions_OnShow()
	AuctionsTitle:SetFormattedText(AUCTION_TITLE, UnitName("player"));
	--MoneyFrame_Update("AuctionsDepositMoneyFrame", 0);
	AuctionsFrameAuctions_ValidateAuction();
	-- So the get auctions query is only run once per session, after that you only get updates
	if ( not AuctionFrame.gotAuctions ) then
		GetOwnerAuctionItems();
		AuctionFrame.gotAuctions = 1;
	end
	AuctionFrameAuctions_Update();
end

function AuctionFrameAuctions_Update()
	local numBatchAuctions, totalAuctions = GetNumAuctionItems("owner");
	local offset = FauxScrollFrame_GetOffset(AuctionsScrollFrame);
	local index;
	local isLastSlotEmpty;
	local auction, button, buttonName, buttonHighlight, iconTexture, itemName, color, itemCount;
	local highBidderFrame;
	local closingTimeFrame, closingTimeText;
	local buttonBuyoutFrame, buttonBuyoutMoney;
	local bidAmountMoneyFrame, bidAmountMoneyFrameLabel;
	local name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, duration, bidAmount, highBidder, owner, saleStatus;

	-- Update sort arrows
	SortButton_UpdateArrow(AuctionsQualitySort, "owner", "quality");
	SortButton_UpdateArrow(AuctionsHighBidderSort, "owner", "status");
	SortButton_UpdateArrow(AuctionsDurationSort, "owner", "duration");
	SortButton_UpdateArrow(AuctionsBidSort, "owner", "bid");

	for i=1, NUM_AUCTIONS_TO_DISPLAY do
		index = offset + i + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameAuctions.page);
		auction = _G["AuctionsButton"..i];
		-- Show or hide auction buttons
		if ( index > (numBatchAuctions + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameAuctions.page)) ) then
			auction:Hide();
			-- If the last button is empty then set isLastSlotEmpty var
			isLastSlotEmpty = (i == NUM_AUCTIONS_TO_DISPLAY);
		else
			auction:Show();
			
			name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner, saleStatus = GetAuctionItemInfo("owner", offset + i);
			duration = GetAuctionItemTimeLeft("owner", offset + i);

			buttonName = "AuctionsButton"..i;
			button = _G[buttonName];

			-- Resize button if there isn't a scrollbar
			buttonHighlight = _G[buttonName.."Highlight"];
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
			
			-- Display differently based on the saleStatus
			-- saleStatus "1" means that the item was sold
			-- Set name and quality color
			color = ITEM_QUALITY_COLORS[quality];
			itemName = _G[buttonName.."Name"];
			iconTexture = _G[buttonName.."ItemIconTexture"];
			iconTexture:SetTexture(texture);
			highBidderFrame = _G[buttonName.."HighBidder"];
			closingTimeFrame = _G[buttonName.."ClosingTime"];
			closingTimeText = _G[buttonName.."ClosingTimeText"];
			itemCount = _G[buttonName.."ItemCount"];
			bidAmountMoneyFrame = _G[buttonName.."MoneyFrame"];
			bidAmountMoneyFrameLabel = _G[buttonName.."MoneyFrameLabel"];
			buttonBuyoutFrame = _G[buttonName.."BuyoutFrame"];
			if ( saleStatus == 1 ) then
				-- Sold item
				itemName:SetFormattedText(AUCTION_ITEM_SOLD, name);
				itemName:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);

				if ( highBidder ) then
					highBidder = GREEN_FONT_COLOR_CODE..highBidder..FONT_COLOR_CODE_CLOSE;
					highBidderFrame:SetText(highBidder);
				end

				closingTimeText:SetFormattedText(AUCTION_ITEM_TIME_UNTIL_DELIVERY, SecondsToTime(duration));
				closingTimeFrame.tooltip = closingTimeText:GetText();

				iconTexture:SetVertexColor(0.5, 0.5, 0.5);

				itemCount:Hide();
				button.itemCount = count;

				MoneyFrame_Update(buttonName.."MoneyFrame", bidAmount);
				bidAmountMoneyFrame:SetAlpha(1);
				bidAmountMoneyFrame:SetPoint("RIGHT", button, "RIGHT", 10, -4);
				bidAmountMoneyFrameLabel:Show();

				buttonBuyoutFrame:Hide();
			else
				-- Normal item
				itemName:SetText(name);
				itemName:SetVertexColor(color.r, color.g, color.b);

				if ( not highBidder ) then
					highBidder = RED_FONT_COLOR_CODE..NO_BIDS..FONT_COLOR_CODE_CLOSE;
				end
				highBidderFrame:SetText(highBidder);

				closingTimeText:SetText(AuctionFrame_GetTimeLeftText(duration));
				closingTimeFrame.tooltip = AuctionFrame_GetTimeLeftTooltipText(duration);

				if ( not canUse ) then
					iconTexture:SetVertexColor(1.0, 0.1, 0.1);
				else
					iconTexture:SetVertexColor(1.0, 1.0, 1.0);
				end

				if ( count > 1 ) then
					itemCount:SetText(count);
					itemCount:Show();
				else
					itemCount:Hide();
				end
				button.itemCount = count;

				bidAmountMoneyFrameLabel:Hide();
				if ( bidAmount > 0 ) then
					-- Set high bid
					MoneyFrame_Update(buttonName.."MoneyFrame", bidAmount);
					bidAmountMoneyFrame:SetAlpha(1);
					-- Set cancel price
					auction.cancelPrice = floor(bidAmount * 0.05);
					button.bidAmount = bidAmount;
				else
					-- No bids so show minBid and gray it out
					MoneyFrame_Update(buttonName.."MoneyFrame", minBid);
					bidAmountMoneyFrame:SetAlpha(0.5);
					-- No cancel price
					auction.cancelPrice = 0;
					button.bidAmount = minBid;
				end

				-- Set buyout price and adjust bid amount accordingly
				if ( buyoutPrice > 0 ) then
					bidAmountMoneyFrame:SetPoint("RIGHT", buttonName, "RIGHT", 10, 10);
					buttonBuyoutMoney = _G[buttonName.."BuyoutFrameMoney"];
					MoneyFrame_Update(buttonBuyoutMoney, buyoutPrice);
					buttonBuyoutFrame:Show();
				else
					bidAmountMoneyFrame:SetPoint("RIGHT", buttonName, "RIGHT", 10, 3);
					buttonBuyoutFrame:Hide();
				end
				button.buyoutPrice = buyoutPrice;
			end

			-- Enable/Disable cancel auction button
			if ( (GetSelectedAuctionItem("owner") > 0) and (saleStatus == 0) ) then
				AuctionsCancelAuctionButton:Enable();
			else
				AuctionsCancelAuctionButton:Disable();
			end
			-- Set highlight
			if ( GetSelectedAuctionItem("owner") and (offset + i) == GetSelectedAuctionItem("owner") ) then
				auction:LockHighlight();
			else
				auction:UnlockHighlight();
			end
		end
	end
	-- If more than one page of auctions show the next and prev arrows when the scrollframe is scrolled all the way down
	if ( totalAuctions > NUM_AUCTION_ITEMS_PER_PAGE ) then
		if ( isLastSlotEmpty ) then
			AuctionsSearchCountText:Show();
			AuctionsSearchCountText:SetFormattedText(SINGLE_PAGE_RESULTS_TEMPLATE, totalAuctions);
		else
			AuctionsSearchCountText:Hide();
		end

		-- Artifically inflate the number of results so the scrollbar scrolls one extra row
		numBatchAuctions = numBatchAuctions + 1;
	else
		AuctionsSearchCountText:Hide();
	end

	if ( GetSelectedAuctionItem("owner") and (GetSelectedAuctionItem("owner") > 0) and CanCancelAuction(GetSelectedAuctionItem("owner")) ) then
		AuctionsCancelAuctionButton:Enable();
	else
		AuctionsCancelAuctionButton:Disable();
	end

	-- Update scrollFrame
	FauxScrollFrame_Update(AuctionsScrollFrame, numBatchAuctions, NUM_AUCTIONS_TO_DISPLAY, AUCTIONS_BUTTON_HEIGHT);
end

function AuctionsButton_OnClick(button)
	assert(button);
	
	if ( GetCVarBool("auctionDisplayOnCharacter") ) then
		DressUpItemLink(GetAuctionItemLink("owner", button:GetID() + FauxScrollFrame_GetOffset(AuctionsScrollFrame)));
	end
	SetSelectedAuctionItem("owner", button:GetID() + FauxScrollFrame_GetOffset(AuctionsScrollFrame));
	-- Close any auction related popups
	CloseAuctionStaticPopups();
	AuctionFrameAuctions.cancelPrice = button.cancelPrice;
	AuctionFrameAuctions_Update();
end

function PriceDropDown_OnShow(self)
	UIDropDownMenu_Initialize(self, PriceDropDown_Initialize);
	if ( not AuctionFrameAuctions.priceType ) then
		AuctionFrameAuctions.priceType = PRICE_TYPE_STACK;
	end
	UIDropDownMenu_SetSelectedValue(PriceDropDown, AuctionFrameAuctions.priceType);
end

function PriceDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	info.text = AUCTION_PRICE_PER_ITEM;
	info.value = PRICE_TYPE_UNIT;
	info.checked = nil;
	info.func = PriceDropDown_OnClick;
	UIDropDownMenu_AddButton(info);

	info.text = AUCTION_PRICE_PER_STACK;
	info.value = PRICE_TYPE_STACK;
	info.checked = nil;
	info.func = PriceDropDown_OnClick;
	UIDropDownMenu_AddButton(info);
end

function PriceDropDown_OnClick(self)
	if ( AuctionFrameAuctions.priceType ~= self.value ) then
		AuctionFrameAuctions.priceType = self.value;
		UIDropDownMenu_SetSelectedValue(PriceDropDown, self.value);
		local startPrice = MoneyInputFrame_GetCopper(StartPrice);
		local buyoutPrice = MoneyInputFrame_GetCopper(BuyoutPrice);	
		local stackSize = AuctionsStackSizeEntry:GetNumber();	
		if ( stackSize > 1 ) then
			if ( self.value == PRICE_TYPE_UNIT ) then
				MoneyInputFrame_SetCopper(StartPrice, math.floor(startPrice / stackSize));
				MoneyInputFrame_SetCopper(BuyoutPrice, math.floor(buyoutPrice / stackSize));
			else
				MoneyInputFrame_SetCopper(StartPrice, startPrice * stackSize);
				MoneyInputFrame_SetCopper(BuyoutPrice, buyoutPrice * stackSize);
			end
		end
	end
end

function DurationDropDown_OnShow(self)
	UIDropDownMenu_Initialize(self, DurationDropDown_Initialize);
	if ( not AuctionFrameAuctions.duration ) then
		AuctionFrameAuctions.duration = 2;
	end
	UIDropDownMenu_SetSelectedValue(DurationDropDown, AuctionFrameAuctions.duration);
end

function DurationDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	info.text = AUCTION_DURATION_ONE;
	info.value = 1;
	info.checked = nil;
	info.func = DurationDropDown_OnClick;
	UIDropDownMenu_AddButton(info);

	info.text = AUCTION_DURATION_TWO;
	info.value = 2;
	info.checked = nil;
	info.func = DurationDropDown_OnClick;
	UIDropDownMenu_AddButton(info);

	info.text = AUCTION_DURATION_THREE;
	info.value = 3;
	info.checked = nil;
	info.func = DurationDropDown_OnClick;
	UIDropDownMenu_AddButton(info);
end

function DurationDropDown_OnClick(self)
	AuctionFrameAuctions.duration = self.value;
	UIDropDownMenu_SetSelectedValue(DurationDropDown, self.value);
	UpdateDeposit();
end

function UpdateDeposit()
	MoneyFrame_Update("AuctionsDepositMoneyFrame", CalculateAuctionDeposit(AuctionFrameAuctions.duration, AuctionsStackSizeEntry:GetNumber(), AuctionsNumStacksEntry:GetNumber()));
end

function AuctionSellItemButton_OnEvent(self, event, ...)
	if ( event == "NEW_AUCTION_UPDATE") then
		local name, texture, count, quality, canUse, price, pricePerUnit, stackCount, totalCount = GetAuctionSellItemInfo();
		AuctionsItemButton:SetNormalTexture(texture);
		AuctionsItemButton.stackCount = stackCount;
		AuctionsItemButton.totalCount = totalCount;
		AuctionsItemButton.pricePerUnit = pricePerUnit;
		AuctionsItemButtonName:SetText(name);
		local color = ITEM_QUALITY_COLORS[quality];
		AuctionsItemButtonName:SetVertexColor(color.r, color.g, color.b);
		if ( totalCount > 1 ) then
			AuctionsItemButtonCount:SetText(totalCount);
			AuctionsItemButtonCount:Show();
			AuctionsStackSizeEntry:Show();
			AuctionsStackSizeMaxButton:Show();
			AuctionsNumStacksEntry:Show();
			AuctionsNumStacksMaxButton:Show();
			UIDropDownMenu_EnableDropDown(PriceDropDown);
			UpdateMaximumButtons();
		else	
			AuctionsItemButtonCount:Hide();
			AuctionsStackSizeEntry:Hide();
			AuctionsStackSizeMaxButton:Hide();
			AuctionsNumStacksEntry:Hide();
			AuctionsNumStacksMaxButton:Hide();
			-- checking for count of 1 so when a stack of 2 or more is removed by the user, we don't reset to "per item"
			-- totalCount will be 0 when the sell item is removed
			if ( totalCount == 1 ) then
				AuctionFrameAuctions.priceType = PRICE_TYPE_UNIT;
				UIDropDownMenu_SetSelectedValue(PriceDropDown, PRICE_TYPE_UNIT);
				UIDropDownMenu_SetText(PriceDropDown, AUCTION_PRICE_PER_ITEM);
			end
			UIDropDownMenu_DisableDropDown(PriceDropDown);
		end
		AuctionsStackSizeEntry:SetNumber(count);
		AuctionsNumStacksEntry:SetNumber(1);
		if ( name == LAST_ITEM_AUCTIONED and count == LAST_ITEM_COUNT ) then
			MoneyInputFrame_SetCopper(StartPrice, LAST_ITEM_START_BID);
			MoneyInputFrame_SetCopper(BuyoutPrice, LAST_ITEM_BUYOUT);
		else
			if ( UIDropDownMenu_GetSelectedValue(PriceDropDown) == 1 and stackCount > 0 ) then
				-- unit price
				MoneyInputFrame_SetCopper(StartPrice, max(100, floor(pricePerUnit * 1.5)));
				
			else
				MoneyInputFrame_SetCopper(StartPrice, max(100, floor(price * 1.5)));
			end
			MoneyInputFrame_SetCopper(BuyoutPrice, 0);
			if ( name ) then
				LAST_ITEM_AUCTIONED = name;
				LAST_ITEM_COUNT = count;
				LAST_ITEM_START_BID = MoneyInputFrame_GetCopper(StartPrice);
				LAST_ITEM_BUYOUT = MoneyInputFrame_GetCopper(BuyoutPrice);
			end
		end
		UpdateDeposit();
		AuctionsFrameAuctions_ValidateAuction();
	end
end

function AuctionSellItemButton_OnClick(self, button)
	ClickAuctionSellItemButton(self, button);
	AuctionsFrameAuctions_ValidateAuction();
end

function AuctionsFrameAuctions_ValidateAuction()
	AuctionsCreateAuctionButton:Disable();
	AuctionsBuyoutText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	AuctionsBuyoutError:Hide();
	-- No item
	if ( not GetAuctionSellItemInfo() ) then
		return;
	end
	-- Buyout price is less than the start price
	if ( MoneyInputFrame_GetCopper(BuyoutPrice) > 0 and MoneyInputFrame_GetCopper(StartPrice) > MoneyInputFrame_GetCopper(BuyoutPrice) ) then
		AuctionsBuyoutText:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		AuctionsBuyoutError:Show();
		return;
	end
	-- Start price is 0 or greater than the max allowed
	if ( MoneyInputFrame_GetCopper(StartPrice) < 1 or MoneyInputFrame_GetCopper(StartPrice) > MAXIMUM_BID_PRICE) then
		return;
	end
	-- The stack size is greater than total count
	local stackCount = AuctionsItemButton.stackCount or 0;
	local totalCount = AuctionsItemButton.totalCount or 0;
	if ( AuctionsStackSizeEntry:GetNumber() == 0 or AuctionsStackSizeEntry:GetNumber() > stackCount or AuctionsNumStacksEntry:GetNumber() == 0 or (AuctionsStackSizeEntry:GetNumber() * AuctionsNumStacksEntry:GetNumber() > totalCount) ) then
		return;
	end
	AuctionsCreateAuctionButton:Enable();
end

--[[
function AuctionFrame_UpdateTimeLeft(elapsed, type)
	if ( not self.updateCounter ) then
		self.updateCounter = 0;
	end
	if ( self.updateCounter > AUCTION_TIMER_UPDATE_DELAY ) then
		self.updateCounter = 0;	
		local index = self:GetID();
		if ( type == "list" ) then
			index = index + FauxScrollFrame_GetOffset(BrowseScrollFrame);
		elseif ( type == "bidder" ) then
			index = index + FauxScrollFrame_GetOffset(BidScrollFrame);
		elseif ( type == "owner" ) then
			index = index + FauxScrollFrame_GetOffset(AuctionsScrollFrame);
		end
		_G[self:GetName().."ClosingTime"]:SetText(SecondsToTime(GetAuctionItemTimeLeft(type, index)));
	else
		self.updateCounter = self.updateCounter + elapsed;
	end
end
]]

function AuctionFrame_GetTimeLeftText(id)
	return _G["AUCTION_TIME_LEFT"..id];
end

function AuctionFrame_GetTimeLeftTooltipText(id)
	return _G["AUCTION_TIME_LEFT"..id.."_DETAIL"];
end

function AuctionFrameItem_OnEnter(self, type, index)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetAuctionItem(type, index);

	-- add price per unit info
	local button;
	if ( type == "owner" ) then
		button = _G["AuctionsButton"..self:GetParent():GetID()];
	elseif ( type == "bidder" ) then
		button = _G["BidButton"..self:GetParent():GetID()];
	elseif ( type == "list" ) then
		button = _G["BrowseButton"..self:GetParent():GetID()];
	end
	if ( button and button.itemCount > 1 ) then
		if ( button.bidAmount > 0 ) then
			GameTooltip:AddLine("|n");
			SetTooltipMoney(GameTooltip, ceil(button.bidAmount / button.itemCount), "STATIC", AUCTION_TOOLTIP_BID_PREFIX);
		end
		if ( button.buyoutPrice > 0 ) then
			SetTooltipMoney(GameTooltip, ceil(button.buyoutPrice / button.itemCount), "STATIC", AUCTION_TOOLTIP_BUYOUT_PREFIX);
		end
		GameTooltip:Show();
	end

	GameTooltip_ShowCompareItem();

	if ( IsModifiedClick("DRESSUP") ) then
		ShowInspectCursor();
	else
		ResetCursor();
	end
end

-- SortButton functions
function SortButton_UpdateArrow(button, type, sort)
	local primaryColumn, reversed = GetAuctionSort(type, 1);
	if (sort == primaryColumn) then
		-- primary column, show the sort arrow
		if (reversed) then
			_G[button:GetName().."Arrow"]:Show();
			_G[button:GetName().."Arrow"]:SetTexCoord(0, 0.5625, 1.0, 0);
		else
			_G[button:GetName().."Arrow"]:Show();
			_G[button:GetName().."Arrow"]:SetTexCoord(0, 0.5625, 0, 1.0);
		end
	else
		-- hide sort arrows for non-primary column
		_G[button:GetName().."Arrow"]:Hide();
	end
end

-- Function to close popups if another auction item is selected
function CloseAuctionStaticPopups()
	StaticPopup_Hide("BUYOUT_AUCTION");
	StaticPopup_Hide("BID_AUCTION");
	StaticPopup_Hide("CANCEL_AUCTION");
end

function AuctionsCreateAuctionButton_OnClick()
	LAST_ITEM_START_BID = MoneyInputFrame_GetCopper(StartPrice);
	LAST_ITEM_BUYOUT = MoneyInputFrame_GetCopper(BuyoutPrice);
	DropCursorMoney();
	PlaySound("LOOTWINDOWCOINSOUND");
	local startPrice = MoneyInputFrame_GetCopper(StartPrice);
	local buyoutPrice = MoneyInputFrame_GetCopper(BuyoutPrice);
	if ( AuctionFrameAuctions.priceType == PRICE_TYPE_UNIT ) then
		startPrice = startPrice * AuctionsStackSizeEntry:GetNumber();
		buyoutPrice = buyoutPrice * AuctionsStackSizeEntry:GetNumber();
	end
	StartAuction(startPrice, buyoutPrice, AuctionFrameAuctions.duration, AuctionsStackSizeEntry:GetNumber(), AuctionsNumStacksEntry:GetNumber());
end

function SetMaxStackSize()
	local stackCount = AuctionsItemButton.stackCount;
	local totalCount = AuctionsItemButton.totalCount;
	if ( totalCount and totalCount > 0 ) then
		if ( totalCount > stackCount ) then
			AuctionsStackSizeEntry:SetNumber(stackCount);
			AuctionsNumStacksEntry:SetNumber(math.floor(totalCount / stackCount));
		else
			AuctionsStackSizeEntry:SetNumber(totalCount);
			AuctionsNumStacksEntry:SetNumber(1);
		end
	else
		AuctionsStackSizeEntry:SetNumber("");
		AuctionsNumStacksEntry:SetNumber("");	
	end
end

function UpdateMaximumButtons()
	local stackCount = AuctionsItemButton.stackCount;
	local totalCount = AuctionsItemButton.totalCount;
	local stackSize = AuctionsStackSizeEntry:GetNumber();
	if ( stackSize ~= min(totalCount, stackCount) ) then
		AuctionsStackSizeMaxButton:Enable();
	else
		AuctionsStackSizeMaxButton:Disable();
	end
	if ( AuctionsNumStacksEntry:GetNumber() ~= math.floor(totalCount / stackSize) ) then
		AuctionsNumStacksMaxButton:Enable();
	else
		AuctionsNumStacksMaxButton:Disable();
	end
end

function AuctionProgressFrame_OnUpdate(self)
	if ( self.fadeOut ) then
		local alpha = self:GetAlpha() - CASTING_BAR_ALPHA_STEP;
		if ( alpha > 0 ) then
			self:SetAlpha(alpha);
		else			
			self.fadeOut = nil;
			self:Hide();
			self:SetAlpha(1);
		end
	end
end