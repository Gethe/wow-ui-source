-- keep last item sent to auction & it's price
LAST_ITEM_AUCTIONED = "";
LAST_ITEM_COUNT = 0;
LAST_ITEM_START_BID = 0;
LAST_ITEM_BUYOUT = 0;

local BROWSE_PARAM_INDEX_PAGE = 7;
local PRICE_TYPE_UNIT = 1;
local PRICE_TYPE_STACK = 2;

local function GetPrices()
	local startPrice = MoneyInputFrame_GetCopper(StartPrice);
	local buyoutPrice = MoneyInputFrame_GetCopper(BuyoutPrice);
	if ( AuctionFrameAuctions.priceType == PRICE_TYPE_UNIT) then
		startPrice =  startPrice * AuctionsStackSizeEntry:GetNumber();
		buyoutPrice = buyoutPrice * AuctionsStackSizeEntry:GetNumber();
	end
	return startPrice,buyoutPrice;
end

MoneyTypeInfo["AUCTION_DEPOSIT"] = {
	UpdateFunc = function()
		if ( not AuctionFrameAuctions.duration ) then
			AuctionFrameAuctions.duration = 0
		end
		local startPrice, buyoutPrice = GetPrices();
		return GetAuctionDeposit(AuctionFrameAuctions.duration, startPrice, buyoutPrice);
	end,
	collapse = 1,
};

MoneyTypeInfo["AUCTION_DEPOSIT_TOKEN"] = {
	UpdateFunc = function()
		return nil;
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
	OnCancel = function(self)
		BrowseBuyoutButton:Enable();
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
	OnCancel = function(self)
		BrowseBidButton:Enable();
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
StaticPopupDialogs["TOKEN_NONE_FOR_SALE"] = {
	text = TOKEN_NONE_FOR_SALE,
	button1 = OKAY,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = true,
}
StaticPopupDialogs["TOKEN_AUCTIONABLE_TOKEN_OWNED"] = {
	text = TOKEN_AUCTIONABLE_TOKEN_OWNED,
	button1 = OKAY,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = true,
}

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

	BrowseFilterScrollFrame.ScrollBar.scrollStep = BROWSE_FILTER_HEIGHT;
	
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
	if (Kiosk.IsEnabled()) then
		UIErrorsFrame:AddMessage(ERR_CLIENT_LOCKED_OUT, 1.0, 0.1, 0.1, 1.0);
		CloseAuctionHouse();
		HideUIPanel(AuctionFrame);
		return;
	end

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
		BrowsePrevPageButton:Hide();
		BrowseNextPageButton:Hide();
		
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
	PlaySound(SOUNDKIT.AUCTION_WINDOW_OPEN);

	SetUpSideDressUpFrame(self, 840, 1020, "TOPLEFT", "TOPRIGHT", -2, -28);
end

function AuctionFrameTab_OnClick(self, button, down, index)
	local index = self:GetID();
	PanelTemplates_SetTab(AuctionFrame, index);
	AuctionFrameAuctions:Hide();
	AuctionFrameBrowse:Hide();
	AuctionFrameBid:Hide();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
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
		if ( not DressUpItemLink(GetAuctionItemLink("list", button:GetID() + FauxScrollFrame_GetOffset(BrowseScrollFrame))) ) then
			DressUpBattlePet(GetAuctionItemBattlePetInfo("list", button:GetID() + FauxScrollFrame_GetOffset(BrowseScrollFrame)));
		end
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
	info.classicChecks = true;
	UIDropDownMenu_AddButton(info);
	for i=0, getn(ITEM_QUALITY_COLORS)-4  do
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

function AuctionFrameBrowse_Reset(self)
	BrowseName:SetText("");
	BrowseMinLevel:SetText("");
	BrowseMaxLevel:SetText("");
	IsUsableCheckButton:SetChecked(false);
	UIDropDownMenu_SetSelectedValue(BrowseDropDown,-1);

	-- reset the filters
	OPEN_FILTER_LIST = {};
	AuctionFrameBrowse.selectedCategoryIndex = nil;
	AuctionFrameBrowse.selectedSubCategoryIndex = nil;
	AuctionFrameBrowse.selectedSubSubCategoryIndex = nil;

	BrowseLevelSort:SetText(AuctionFrame_GetDetailColumnString(AuctionFrameBrowse.selectedCategoryIndex, AuctionFrameBrowse.selectedSubCategoryIndex));
	AuctionFrameFilters_Update();
	BrowseWowTokenResults_Update();
	self:Disable();
end

function BrowseResetButton_OnUpdate(self, elapsed)
	if ( (BrowseName:GetText() == "") and (BrowseMinLevel:GetText() == "") and (BrowseMaxLevel:GetText() == "") and
	     (not IsUsableCheckButton:GetChecked()) and (UIDropDownMenu_GetSelectedValue(BrowseDropDown) == -1) and
	     (not AuctionFrameBrowse.selectedCategoryIndex) and (not AuctionFrameBrowse.selectedSubCategoryIndex) and (not AuctionFrameBrowse.selectedSubSubCategoryIndex) )
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
	local text, minLevel, maxLevel, categoryIndex, subCategoryIndex, subSubCategoryIndex, page, usable, rarity, exactMatch = ...;

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

	local filterData;
	if categoryIndex and subCategoryIndex and subSubCategoryIndex then
		filterData = AuctionCategories[categoryIndex].subCategories[subCategoryIndex].subCategories[subSubCategoryIndex].filters;
	elseif categoryIndex and subCategoryIndex then
		filterData = AuctionCategories[categoryIndex].subCategories[subCategoryIndex].filters;
	elseif categoryIndex then
		filterData = AuctionCategories[categoryIndex].filters;
	else
		-- not filtering by category, leave nil for all
	end

	QueryAuctionItems(text, minLevel, maxLevel, page, usable, rarity, false, exactMatch, filterData);

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
	if (AuctionFrame_DoesCategoryHaveFlag("WOW_TOKEN_FLAG", AuctionFrameBrowse.selectedCategoryIndex)) then
		AuctionWowToken_UpdateMarketPrice();
		BrowseWowTokenResults_Update();
	else
		if ( not AuctionFrameBrowse.page ) then
			AuctionFrameBrowse.page = 0;
		end

		AuctionFrameBrowse_SearchHelper(BrowseName:GetText(), BrowseMinLevel:GetNumber(), BrowseMaxLevel:GetNumber(), AuctionFrameBrowse.selectedCategoryIndex, AuctionFrameBrowse.selectedSubCategoryIndex, AuctionFrameBrowse.selectedSubSubCategoryIndex, AuctionFrameBrowse.page, IsUsableCheckButton:GetChecked(), UIDropDownMenu_GetSelectedValue(BrowseDropDown), false);

		-- Start "searching" messaging
		AuctionFrameBrowse.isSearching = 1;
	end
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

function AuctionFrameFilters_Update(forceSelectionIntoView)
	AuctionFrameFilters_UpdateCategories(forceSelectionIntoView);
	-- Update scrollFrame
	FauxScrollFrame_Update(BrowseFilterScrollFrame, #OPEN_FILTER_LIST, NUM_FILTERS_TO_DISPLAY, BROWSE_FILTER_HEIGHT);
end

function AuctionFrameFilters_UpdateCategories(forceSelectionIntoView)
	-- Initialize the list of open filters
	OPEN_FILTER_LIST = {};

	for categoryIndex, categoryInfo in ipairs(AuctionCategories) do
		local selected = AuctionFrameBrowse.selectedCategoryIndex and AuctionFrameBrowse.selectedCategoryIndex == categoryIndex;
		local isToken = categoryInfo:HasFlag("WOW_TOKEN_FLAG");
		local tokenEnabled = C_WowTokenPublic.GetCommerceSystemStatus();

		if (not isToken or tokenEnabled) then
			tinsert(OPEN_FILTER_LIST, { name = categoryInfo.name, type = "category", categoryIndex = categoryIndex, selected = selected, isToken = isToken, });

			if ( selected ) then
				AuctionFrameFilters_AddSubCategories(categoryInfo.subCategories);
			end
		end
	end
	
	local hasScrollBar = #OPEN_FILTER_LIST > NUM_FILTERS_TO_DISPLAY;

	-- Display the list of open filters
	local offset = FauxScrollFrame_GetOffset(BrowseFilterScrollFrame);
	if ( forceSelectionIntoView and hasScrollBar and AuctionFrameBrowse.selectedCategoryIndex and ( not AuctionFrameBrowse.selectedSubCategoryIndex and not AuctionFrameBrowse.selectedSubSubCategoryIndex ) ) then
		if ( AuctionFrameBrowse.selectedCategoryIndex <= offset ) then
			FauxScrollFrame_OnVerticalScroll(BrowseFilterScrollFrame, math.max(0.0, (AuctionFrameBrowse.selectedCategoryIndex - 1) * BROWSE_FILTER_HEIGHT), BROWSE_FILTER_HEIGHT);
			offset = FauxScrollFrame_GetOffset(BrowseFilterScrollFrame);
		end
	end
	
	local dataIndex = offset;

	for i = 1, NUM_FILTERS_TO_DISPLAY do
		local button = AuctionFrameBrowse.FilterButtons[i];
		button:SetWidth(hasScrollBar and 136 or 156);

		dataIndex = dataIndex + 1;

		if ( dataIndex <= #OPEN_FILTER_LIST ) then
			local info = OPEN_FILTER_LIST[dataIndex];

			if ( info ) then
				FilterButton_SetUp(button, info);
				
				if ( info.type == "category" ) then
					button.categoryIndex = info.categoryIndex;
				elseif ( info.type == "subCategory" ) then
					button.subCategoryIndex = info.subCategoryIndex;
				elseif ( info.type == "subSubCategory" ) then
					button.subSubCategoryIndex = info.subSubCategoryIndex;
				end
				
				if ( info.selected ) then
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

function AuctionFrameFilters_AddSubCategories(subCategories)
	if subCategories then
		for subCategoryIndex, subCategoryInfo in ipairs(subCategories) do
			local selected = AuctionFrameBrowse.selectedSubCategoryIndex and AuctionFrameBrowse.selectedSubCategoryIndex == subCategoryIndex;

			tinsert(OPEN_FILTER_LIST, { name = subCategoryInfo.name, type = "subCategory", subCategoryIndex = subCategoryIndex, selected = selected });
		 
			if ( selected ) then
				AuctionFrameFilters_AddSubSubCategories(subCategoryInfo.subCategories);
			end
		end
	end
end

function AuctionFrameFilters_AddSubSubCategories(subSubCategories)
	if subSubCategories then
		for subSubCategoryIndex, subSubCategoryInfo in ipairs(subSubCategories) do
			local selected = AuctionFrameBrowse.selectedSubSubCategoryIndex and AuctionFrameBrowse.selectedSubSubCategoryIndex == subSubCategoryIndex;
			local isLast = subSubCategoryIndex == #subSubCategories;

			tinsert(OPEN_FILTER_LIST, { name = subSubCategoryInfo.name, type = "subSubCategory", subSubCategoryIndex = subSubCategoryIndex, selected = selected, isLast = isLast});
		end
	end
end

function FilterButton_SetUp(button, info)
	local normalText = _G[button:GetName().."NormalText"];
	local normalTexture = _G[button:GetName().."NormalTexture"];
	local line = _G[button:GetName().."Lines"];
	local tex = button:GetNormalTexture();

	if (info.isToken) then
		tex:SetTexCoord(0, 1, 0, 1);
		tex:SetAtlas("token-button-category");
	else
		tex:SetTexture("Interface\\AuctionFrame\\UI-AuctionFrame-FilterBg");
		tex:SetTexCoord(0, 0.53125, 0, 0.625);
	end

	if ( info.type == "category" ) then
		button:SetNormalFontObject(GameFontNormalSmallLeft);
		button:SetText(info.name);
		normalText:SetPoint("LEFT", button, "LEFT", 4, 0);
		normalTexture:SetAlpha(1.0);	
		line:Hide();
	elseif ( info.type == "subCategory" ) then
		button:SetNormalFontObject(GameFontHighlightSmallLeft);
		button:SetText(info.name);
		normalText:SetPoint("LEFT", button, "LEFT", 12, 0);
		normalTexture:SetAlpha(0.4);
		line:Hide();
	elseif ( info.type == "subSubCategory" ) then
		button:SetNormalFontObject(GameFontHighlightSmallLeft);
		button:SetText(info.name);
		normalText:SetPoint("LEFT", button, "LEFT", 20, 0);
		normalTexture:SetAlpha(0.0);	
		
		if ( info.isLast ) then
			line:SetTexCoord(0.4375, 0.875, 0, 0.625);
		else
			line:SetTexCoord(0, 0.4375, 0, 0.625);
		end
		line:Show();
	end
	button.type = info.type; 
end

function AuctionFrameFilter_OnClick(self, button)
	if ( self.type == "category" ) then
		local wasToken = AuctionFrame_DoesCategoryHaveFlag("WOW_TOKEN_FLAG", AuctionFrameBrowse.selectedCategoryIndex);
		if ( AuctionFrameBrowse.selectedCategoryIndex == self.categoryIndex ) then
			AuctionFrameBrowse.selectedCategoryIndex = nil;
		else
			AuctionFrameBrowse.selectedCategoryIndex = self.categoryIndex;
		end
		AuctionFrameBrowse.selectedSubCategoryIndex = nil;
		AuctionFrameBrowse.selectedSubSubCategoryIndex = nil;
		if (AuctionFrame_DoesCategoryHaveFlag("WOW_TOKEN_FLAG", AuctionFrameBrowse.selectedCategoryIndex)) then
			AuctionWowToken_UpdateMarketPrice();
			BrowseWowTokenResults_Update();
		else
			BrowseBidButton:Show();
			BrowseBuyoutButton:Show();
			BrowseBidPrice:Show();
			BrowseQualitySort:Show();
			BrowseLevelSort:Show();
			BrowseDurationSort:Show();
			BrowseHighBidderSort:Show();
			BrowseCurrentBidSort:Show();
			if (wasToken) then
				BrowseNoResultsText:SetText(BROWSE_SEARCH_TEXT);
				BrowseNoResultsText:Show();
			end
		end
	elseif ( self.type == "subCategory" ) then
		if ( AuctionFrameBrowse.selectedSubCategoryIndex == self.subCategoryIndex ) then
			AuctionFrameBrowse.selectedSubCategoryIndex = nil;
			AuctionFrameBrowse.selectedSubSubCategoryIndex = nil;
		else
			AuctionFrameBrowse.selectedSubCategoryIndex = self.subCategoryIndex;
			AuctionFrameBrowse.selectedSubSubCategoryIndex = nil;
		end
	elseif ( self.type == "subSubCategory" ) then
		if ( AuctionFrameBrowse.selectedSubSubCategoryIndex == self.subSubCategoryIndex ) then
			AuctionFrameBrowse.selectedSubSubCategoryIndex = nil;
		else
			AuctionFrameBrowse.selectedSubSubCategoryIndex = self.subSubCategoryIndex
		end
	end
	BrowseLevelSort:SetText(AuctionFrame_GetDetailColumnString(AuctionFrameBrowse.selectedCategoryIndex, AuctionFrameBrowse.selectedSubCategoryIndex));
	BrowseWowTokenResults_Update();
	AuctionFrameFilters_Update(true)
end

function AuctionFrameBrowse_Update()
	if (not AuctionFrame_DoesCategoryHaveFlag("WOW_TOKEN_FLAG", AuctionFrameBrowse.selectedCategoryIndex)) then
		local numBatchAuctions, totalAuctions = GetNumAuctionItems("list");
		local button, buttonName, buttonHighlight, iconTexture, itemName, color, itemCount, moneyFrame, yourBidText, buyoutFrame, buyoutMoney;
		local offset = FauxScrollFrame_GetOffset(BrowseScrollFrame);
		local index;
		local isLastSlotEmpty;
		local name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, duration, bidAmount, highBidder, bidderFullName, owner, ownerFullName, saleStatus, itemId, hasAllInfo;
		local displayedPrice, requiredBid;
		BrowseBidButton:Show();
		BrowseBuyoutButton:Show();
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
			local shouldHide = index > (numBatchAuctions + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page));
			if ( not shouldHide ) then
				name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, bidderFullName, owner, ownerFullName, saleStatus, itemId, hasAllInfo =  GetAuctionItemInfo("list", offset + i);
				
				if ( not hasAllInfo ) then --Bug  145328
					shouldHide = true;
				end
			end
			
			-- Show or hide auction buttons
			if ( shouldHide ) then
				button:Hide();
				-- If the last button is empty then set isLastSlotEmpty var
				if ( i == NUM_BROWSE_TO_DISPLAY ) then
					isLastSlotEmpty = 1;
				end
			else
				button:Show();

				buttonName = "BrowseButton"..i;
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
				local itemButton = _G[buttonName.."Item"];

				-- Set level
				if ( levelColHeader == "REQ_LEVEL_ABBR" and level > UnitLevel("player") ) then
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
				local highBidderFrame = _G[buttonName.."HighBidder"]
				highBidderFrame.fullName = ownerFullName;
				highBidderFrame.Name:SetText(owner);
				
				-- this is for comparing to the player name to see if they are the owner of this auction
				local ownerName;
				if (not ownerFullName) then
					ownerName = owner;
				else
					ownerName = ownerFullName
				end
				
				button.bidAmount = displayedPrice;
				button.buyoutPrice = buyoutPrice;
				button.itemCount = count;
				button.itemIndex = index;

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
						if ( canBuyout and (ownerName ~= UnitName("player")) ) then
							BrowseBuyoutButton:Enable();
							AuctionFrame.buyoutPrice = buyoutPrice;
						end
					else
						AuctionFrame.buyoutPrice = nil;
					end
					-- Set bid
					MoneyInputFrame_SetCopper(BrowseBidPrice, requiredBid);

					if ( not highBidder and ownerName ~= UnitName("player") and GetMoney() >= MoneyInputFrame_GetCopper(BrowseBidPrice) and MoneyInputFrame_GetCopper(BrowseBidPrice) <= MAXIMUM_BID_PRICE ) then
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
				BrowsePrevPageButton:Show();
				BrowseNextPageButton:Show();
				BrowseSearchCountText:Show();
				local itemsMin = AuctionFrameBrowse.page * NUM_AUCTION_ITEMS_PER_PAGE + 1;
				local itemsMax = itemsMin + numBatchAuctions - 1;
				BrowseSearchCountText:SetFormattedText(NUMBER_OF_RESULTS_TEMPLATE, itemsMin, itemsMax, totalAuctions);
			else
				BrowsePrevPageButton:Hide();
				BrowseNextPageButton:Hide();
				BrowseSearchCountText:Hide();
			end
			
			-- Artifically inflate the number of results so the scrollbar scrolls one extra row
			numBatchAuctions = numBatchAuctions + 1;
		else
			BrowsePrevPageButton.isEnabled = false;
			BrowseNextPageButton.isEnabled = false;
			BrowsePrevPageButton:Hide();
			BrowseNextPageButton:Hide();
			BrowseSearchCountText:Hide();
		end
		FauxScrollFrame_Update(BrowseScrollFrame, numBatchAuctions, NUM_BROWSE_TO_DISPLAY, AUCTIONS_BUTTON_HEIGHT);
	end
end

function BrowseWowTokenResults_OnLoad(self)
	self:RegisterEvent("TOKEN_MARKET_PRICE_UPDATED");
	self:RegisterEvent("TOKEN_STATUS_CHANGED");
	self:RegisterEvent("TOKEN_BUY_RESULT");
	self:RegisterEvent("PLAYER_MONEY");
end

function BrowseWowTokenResults_OnShow(self)
	AuctionWowToken_UpdateMarketPrice();
	BrowseWowTokenResults_Update();
end

function BrowseWowTokenResults_OnUpdate(self, elapsed)
	local now = GetTime();

	local remaining = 60 - (now - self.timeStarted);
	if (remaining < 1) then
		GameTooltip:Hide();
		self:SetScript("OnUpdate", nil);
		self.noneForSale = false;
		self.timeStarted = nil;
		self.Buyout.tooltip = nil;
	else
		self.Buyout.tooltip = TOKEN_TRY_AGAIN_LATER:format(INT_SPELL_DURATION_SEC:format(math.floor(remaining)));
		if (GameTooltip:GetOwner() == self.Buyout) then
			GameTooltip:SetText(self.Buyout.tooltip);
		end
	end
	BrowseWowTokenResults_Update();
end

function BrowseWowTokenResults_OnEvent(self, event, ...)
	if (event == "TOKEN_MARKET_PRICE_UPDATED") then
		local result = ...;
		if (result == LE_TOKEN_RESULT_ERROR_DISABLED) then
			self.disabled = true;
		end
		BrowseWowTokenResults_Update();
	elseif (event == "TOKEN_STATUS_CHANGED") then
		self.disabled = not C_WowTokenPublic.GetCommerceSystemStatus();
		AuctionWowToken_UpdateMarketPrice();
	elseif (event == "TOKEN_BUY_RESULT") then
		local result = ...;
		if (result == LE_TOKEN_RESULT_ERROR_DISABLED) then
			self.disabled = true;
		elseif (result == LE_TOKEN_RESULT_ERROR_NONE_FOR_SALE) then
			self.noneForSale = true;
			StaticPopup_Show("TOKEN_NONE_FOR_SALE");
			self.timeStarted = GetTime();
			self:SetScript("OnUpdate", BrowseWowTokenResults_OnUpdate);
		elseif (result == LE_TOKEN_RESULT_ERROR_AUCTIONABLE_TOKEN_OWNED) then
			StaticPopup_Show("TOKEN_AUCTIONABLE_TOKEN_OWNED");
		elseif (result == LE_TOKEN_RESULT_ERROR_TOO_MANY_TOKENS) then
			UIErrorsFrame:AddMessage(SPELL_FAILED_TOO_MANY_OF_ITEM, 1.0, 0.1, 0.1, 1.0);
		elseif (result == LE_TOKEN_RESULT_ERROR_TRIAL_RESTRICTED) then
			UIErrorsFrame:AddMessage(ERR_RESTRICTED_ACCOUNT_TRIAL, 1.0, 0.1, 0.1, 1.0);
		elseif (result ~= LE_TOKEN_RESULT_SUCCESS) then
			UIErrorsFrame:AddMessage(ERR_AUCTION_DATABASE_ERROR, 1.0, 0.1, 0.1, 1.0);
		else
			local info = ChatTypeInfo["SYSTEM"];
			local itemName = GetItemInfo(WOW_TOKEN_ITEM_ID);
			DEFAULT_CHAT_FRAME:AddMessage(ERR_AUCTION_WON_S:format(itemName), info.r, info.g, info.b, info.id);
			C_WowTokenPublic.UpdateTokenCount();
		end
	elseif ( event == "PLAYER_MONEY" ) then
		BrowseWowTokenResults_Update();
	elseif ( event == "GET_ITEM_INFO_RECEIVED" ) then
		local itemID = ...;
		if (itemID == WOW_TOKEN_ITEM_ID) then
			BrowseWowTokenResults_Update();
			self:UnregisterEvent("GET_ITEM_INFO_RECEIVED");
		end
	end
end

function BrowseWowTokenResults_Update()
	if (AuctionFrame_DoesCategoryHaveFlag("WOW_TOKEN_FLAG", AuctionFrameBrowse.selectedCategoryIndex)) then
		if (not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GAME_TIME_AUCTION_HOUSE) and C_WowTokenPublic.GetCommerceSystemStatus()) then
			WowTokenGameTimeTutorial:Show();
			SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GAME_TIME_AUCTION_HOUSE, true);
		end
		BrowseWowTokenResults:Show();
		BrowseBidButton:Disable();
		BrowseBuyoutButton:Disable();
		BrowseBidPrice:Hide();
		for i=1, NUM_BROWSE_TO_DISPLAY do
			local button = _G["BrowseButton"..i];
			button:Hide();
		end
		BrowseNoResultsText:Hide();
		BrowseQualitySort:Hide();
		BrowseLevelSort:Hide();
		BrowseDurationSort:Hide();
		BrowseHighBidderSort:Hide();
		BrowseCurrentBidSort:Hide();
		BrowseSearchCountText:Hide();
		BrowsePrevPageButton.isEnabled = false;
		BrowsePrevPageButton:Disable();
		BrowsePrevPageButton:Hide();
		BrowseNextPageButton.isEnabled = false;	
		BrowseNextPageButton:Disable();
		BrowseNextPageButton:Hide();
		FauxScrollFrame_Update(BrowseScrollFrame, 0, NUM_BROWSE_TO_DISPLAY, AUCTIONS_BUTTON_HEIGHT);
		local marketPrice;
		if (WowToken_IsWowTokenAuctionDialogShown()) then
			marketPrice = C_WowTokenPublic.GetGuaranteedPrice();
		else
			marketPrice = C_WowTokenPublic.GetCurrentMarketPrice();
		end
		BrowseWowTokenResults:Show();
		local itemName, _, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(WOW_TOKEN_ITEM_ID);
		if (itemName) then
			BrowseWowTokenResults.Token.Icon:SetTexture(itemTexture)
			BrowseWowTokenResults.Token.Name:SetText(itemName);
			BrowseWowTokenResults.Token.Name:SetTextColor(ITEM_QUALITY_COLORS[itemQuality].r, ITEM_QUALITY_COLORS[itemQuality].g, ITEM_QUALITY_COLORS[itemQuality].b);
			if (BrowseWowTokenResults.disabled) then
				BrowseWowTokenResults.BuyoutPrice:SetText(TOKEN_AUCTIONS_UNAVAILABLE);
				BrowseWowTokenResults.Buyout:SetEnabled(false);
			elseif (not marketPrice) then
				BrowseWowTokenResults.BuyoutPrice:SetText(TOKEN_MARKET_PRICE_NOT_AVAILABLE);
				BrowseWowTokenResults.Buyout:SetEnabled(false);
			elseif (BrowseWowTokenResults.noneForSale) then
				BrowseWowTokenResults.BuyoutPrice:SetText(GetMoneyString(marketPrice, true));
				BrowseWowTokenResults.Buyout:SetEnabled(false);
			else
				BrowseWowTokenResults.BuyoutPrice:SetText(GetMoneyString(marketPrice, true));
				if (GetMoney() < marketPrice) then
					BrowseWowTokenResults.Buyout:SetEnabled(false);
					BrowseWowTokenResults.Buyout.tooltip = ERR_NOT_ENOUGH_GOLD;
				else
					BrowseWowTokenResults.Buyout:SetEnabled(true);
					BrowseWowTokenResults.Buyout.tooltip = nil;
				end
			end
		else
			BrowseWowTokenResults:RegisterEvent("GET_ITEM_INFO_RECEIVED");
		end
	else
		BrowseWowTokenResults:Hide();
	end
end

function BrowseWowTokenResultsBuyout_OnClick(self)
	C_WowTokenPublic.BuyToken();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
end

function BrowseWowTokenResultsBuyout_OnEnter(self)
	if (self.tooltip) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.tooltip);
		GameTooltip:Show();
	end
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
	local name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, bidderFullName, owner, ownerFullName, itemID;
	local _;
	local duration;
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
			name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, bidderFullName, owner, ownerFullName, _, itemID =  GetAuctionItemInfo("bidder", index);
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

			local itemButton = _G[buttonName.."Item"];

			-- Set level
			if ( levelColHeader == "REQ_LEVEL_ABBR" and level > UnitLevel("player") ) then
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
				UpdateDeposit();
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
		if ( not DressUpItemLink(GetAuctionItemLink("bidder", button:GetID() + FauxScrollFrame_GetOffset(BidScrollFrame))) ) then
			DressUpBattlePet(GetAuctionItemBattlePetInfo("bidder", button:GetID() + FauxScrollFrame_GetOffset(BidScrollFrame)));
		end
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
	self:RegisterEvent("TOKEN_DISTRIBUTIONS_UPDATED");
	-- set default sort
	AuctionFrame_SetSort("owner", "duration", false);
	AuctionsRadioButton_OnClick(2);
end

function AuctionFrameAuctions_OnEvent(self, event, ...)
	if ( event == "AUCTION_OWNED_LIST_UPDATE" or event == "TOKEN_DISTRIBUTIONS_UPDATED" ) then
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
		AuctionProgressBar:SetValue(0.01);		-- "TEMPORARY"
		AuctionProgressBar.Text:SetFormattedText(AUCTION_CREATING, 0, arg1);
		local _, iconTexture = GetAuctionSellItemInfo();
		AuctionProgressBar.Icon:SetTexture(iconTexture);
		AuctionProgressFrame:Show();
	elseif ( event == "AUCTION_MULTISELL_UPDATE" ) then
		local arg1, arg2 = ...;
		AuctionProgressBar:SetValue(arg1);
		AuctionProgressBar.Text:SetFormattedText(AUCTION_CREATING, arg1, arg2);
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

local AUCTIONS_UPDATE_INTERVAL = 0.5;
function AuctionFrameAuctions_OnUpdate(self, elapsed)
	self.timeSinceUpdate = (self.timeSinceUpdate or 0) + elapsed;
	if ( self.timeSinceUpdate >= AUCTIONS_UPDATE_INTERVAL ) then
		AuctionFrameAuctions_Update();
		self.timeSinceUpdate = 0;
	end
end

do
	local selectedTokenOffset = 0;
	function GetEffectiveSelectedOwnerAuctionItemIndex()
		return (GetSelectedAuctionItem("owner") or 0) + selectedTokenOffset;
	end

	function SetEffectiveSelectedOwnerAuctionItemIndex(index)
		if index <= 0 then
			selectedTokenOffset = C_WowTokenPublic.GetNumListedAuctionableTokens() + index;
			SetSelectedAuctionItem("owner", 0);
		else
			selectedTokenOffset = C_WowTokenPublic.GetNumListedAuctionableTokens();
			SetSelectedAuctionItem("owner", index);
		end
	end

	function IsSelectedOwnerAuctionItemIndexAToken()
		return selectedTokenOffset < C_WowTokenPublic.GetNumListedAuctionableTokens();
	end
end

function AuctionFrameAuctions_Update()
	local numBatchAuctions, totalAuctions = GetNumAuctionItems("owner");
	local tokenCount = C_WowTokenPublic.GetNumListedAuctionableTokens();
	numBatchAuctions = numBatchAuctions + tokenCount;
	local offset = FauxScrollFrame_GetOffset(AuctionsScrollFrame);
	local index;
	local isLastSlotEmpty;
	local auction, button, buttonName, buttonHighlight, iconTexture, itemName, color, itemCount, duration, timeToSell;
	local _;
	local highBidderFrame;
	local closingTimeFrame, closingTimeText;
	local buttonBuyoutFrame, buttonBuyoutMoney;
	local bidAmountMoneyFrame, bidAmountMoneyFrameLabel;
	local name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, bidderFullName, owner, ownerFullName, saleStatus, itemID;
	local pendingDeliveries = false;
	
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
			
			local isWowToken;

			if (index <= tokenCount) then
				itemID, buyoutPrice, duration = C_WowTokenPublic.GetListedAuctionableTokenInfo(index);
				count = 1;
				canUse = true;
				bidAmount = 0;
				name, _, quality, _, _, _, _, _, _, texture = GetItemInfo(itemID);
				isWowToken = true;
				if (not name) then
					AuctionsWowTokenAuctionFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED");
				end
			else
				name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, bidderFullName, owner, ownerFullName, saleStatus, itemID = GetAuctionItemInfo("owner", (offset - tokenCount) + i);
	
				duration = GetAuctionItemTimeLeft("owner", (offset - tokenCount) + i);
			end

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

			local itemButton = _G[buttonName.."Item"];

			if ( saleStatus == 1 ) then
				-- Sold item
				pendingDeliveries = true;
				itemName:SetFormattedText(AUCTION_ITEM_SOLD, name);
				itemName:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);

				highBidderFrame.fullName = bidderFullName;
				if ( highBidder ) then
					highBidder = GREEN_FONT_COLOR_CODE..highBidder..FONT_COLOR_CODE_CLOSE;
					highBidderFrame.Name:SetText(highBidder);
				end

				closingTimeText:SetFormattedText(AUCTION_ITEM_TIME_UNTIL_DELIVERY, SecondsToTime(max(duration, 1)));
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
				if (color) then
					itemName:SetVertexColor(color.r, color.g, color.b);
				end

				highBidderFrame.fullName = bidderFullName;
				if ( isWowToken ) then
					highBidder = DISABLED_FONT_COLOR_CODE..NOT_APPLICABLE..FONT_COLOR_CODE_CLOSE;
				elseif ( not highBidder ) then
					highBidder = RED_FONT_COLOR_CODE..NO_BIDS..FONT_COLOR_CODE_CLOSE;
				end
				highBidderFrame.Name:SetText(highBidder);

				closingTimeText:SetText(AuctionFrame_GetTimeLeftText(duration));
				closingTimeFrame.tooltip = AuctionFrame_GetTimeLeftTooltipText(duration, isWowToken);

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

				if (not isWowToken) then
					bidAmountMoneyFrame:Show();
					bidAmountMoneyFrameLabel:Hide();
					if ( bidAmount > 0 ) then
						-- Set high bid
						MoneyFrame_Update(buttonName.."MoneyFrame", bidAmount);
						bidAmountMoneyFrame:SetAlpha(1);
						-- Set cancel price
						auction.cancelPrice = floor((bidAmount * AUCTION_CANCEL_COST) / 100);
						button.bidAmount = bidAmount;
					else
						-- No bids so show minBid and gray it out
						MoneyFrame_Update(buttonName.."MoneyFrame", minBid);
						bidAmountMoneyFrame:SetAlpha(0.5);
						-- No cancel price
						auction.cancelPrice = 0;
						button.bidAmount = minBid;
					end
				else
					bidAmountMoneyFrame:Hide();
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

			-- Set highlight
			if ( GetEffectiveSelectedOwnerAuctionItemIndex() == offset + i ) then
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

	if ( GetEffectiveSelectedOwnerAuctionItemIndex() > 0 and not IsSelectedOwnerAuctionItemIndexAToken() and CanCancelAuction(GetSelectedAuctionItem("owner")) ) then
		AuctionsCancelAuctionButton:Enable();
	else
		AuctionsCancelAuctionButton:Disable();
	end

	if ( pendingDeliveries ) then
		AuctionFrameAuctions:SetScript("OnUpdate", AuctionFrameAuctions_OnUpdate);
	else
		AuctionFrameAuctions:SetScript("OnUpdate", nil);
	end
	
	-- Update scrollFrame
	FauxScrollFrame_Update(AuctionsScrollFrame, numBatchAuctions, NUM_AUCTIONS_TO_DISPLAY, AUCTIONS_BUTTON_HEIGHT);
end

function GetEffectiveAuctionsScrollFrameOffset()
	return FauxScrollFrame_GetOffset(AuctionsScrollFrame) - C_WowTokenPublic.GetNumListedAuctionableTokens();
end

function AuctionsButton_OnClick(button)
	assert(button);
	local effectiveIndex = GetEffectiveAuctionsScrollFrameOffset();
	if ( GetCVarBool("auctionDisplayOnCharacter") ) then
		if ( not DressUpItemLink(GetAuctionItemLink("owner", button:GetID() + effectiveIndex)) ) then
			DressUpBattlePet(GetAuctionItemBattlePetInfo("owner", button:GetID() + effectiveIndex));
		end
	end
	SetEffectiveSelectedOwnerAuctionItemIndex(button:GetID() + effectiveIndex);
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
			UpdateDeposit();
		end
	end
end

function AuctionsRadioButton_OnClick(index)
	AuctionsShortAuctionButton:SetChecked(nil);
	AuctionsMediumAuctionButton:SetChecked(nil);
	AuctionsLongAuctionButton:SetChecked(nil);
	if ( index == 1 ) then
		AuctionsShortAuctionButton:SetChecked(1);
		AuctionFrameAuctions.duration = 1;
	elseif ( index ==2 ) then
		AuctionsMediumAuctionButton:SetChecked(1);
		AuctionFrameAuctions.duration = 2;
	else
		AuctionsLongAuctionButton:SetChecked(1);
		AuctionFrameAuctions.duration = 3;
	end
	UpdateDeposit();
end

function UpdateDeposit()
	local startPrice, buyoutPrice = GetPrices();
	MoneyFrame_Update("AuctionsDepositMoneyFrame", GetAuctionDeposit(AuctionFrameAuctions.duration or 0, startPrice, buyoutPrice, AuctionsStackSizeEntry:GetNumber(), AuctionsNumStacksEntry:GetNumber()));
end

function AuctionSellItemButton_OnEvent(self, event, ...)
	if ( event == "NEW_AUCTION_UPDATE") then
		local name, texture, count, quality, canUse, price, pricePerUnit, stackCount, totalCount, itemID = GetAuctionSellItemInfo();
		if (C_WowTokenPublic.IsAuctionableWowToken(itemID)) then
			AuctionsItemButtonCount:Hide();
			AuctionsStackSizeEntry:Hide();
			AuctionsStackSizeMaxButton:Hide();
			AuctionsNumStacksEntry:Hide();
			AuctionsNumStacksMaxButton:Hide();
			PriceDropDown:Hide();
			StartPrice:Hide();
			BuyoutPrice:Hide();
			AuctionsDurationText:Hide();
			AuctionsShortAuctionButton:Hide();
			AuctionsMediumAuctionButton:Hide();
			AuctionsLongAuctionButton:Hide();
			C_WowTokenPublic.UpdateTokenCount();
			AuctionsWowTokenAuctionFrame_Update();
			AuctionsWowTokenAuctionFrame:Show();
			AuctionsItemButton:SetNormalTexture(texture);
			AuctionsItemButtonName:SetText(name);
			local color = ITEM_QUALITY_COLORS[quality];
			AuctionWowToken_UpdateMarketPrice();
			MoneyFrame_SetType(AuctionsDepositMoneyFrame, "AUCTION_DEPOSIT_TOKEN");
			MoneyFrame_Update("AuctionsDepositMoneyFrame", 0, true);
		else
			StartPrice:Show();
			BuyoutPrice:Show();
			AuctionsDurationText:Show();
			AuctionsShortAuctionButton:Show();
			AuctionsMediumAuctionButton:Show();
			AuctionsLongAuctionButton:Show();
			AuctionsWowTokenAuctionFrame:Hide();
			AuctionsItemButton:SetNormalTexture(texture);
			AuctionsItemButton.stackCount = stackCount;
			AuctionsItemButton.totalCount = totalCount;
			AuctionsItemButton.pricePerUnit = pricePerUnit;
			AuctionsItemButtonName:SetText(name);

			--[[if ( totalCount > 1 ) then
				AuctionsItemButtonCount:SetText(totalCount);
				AuctionsItemButtonCount:Show();
				AuctionsStackSizeEntry:Show();
				AuctionsStackSizeMaxButton:Show();
				AuctionsNumStacksEntry:Show();
				AuctionsNumStacksMaxButton:Show();
				PriceDropDown:Show();
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
					PriceDropDown:Hide();
				else
					PriceDropDown:Show();
				end
			end]]
			AuctionsItemButtonCount:SetText(count);
			if (count > 1) then
				AuctionsItemButtonCount:Show();
			else
				AuctionsItemButtonCount:Hide();
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
			MoneyFrame_SetType(AuctionsDepositMoneyFrame, "AUCTION_DEPOSIT");
		end
		AuctionsFrameAuctions_ValidateAuction();
	end
end

function AuctionSellItemButton_OnClick(self, button)
	ClickAuctionSellItemButton(self, button);
	AuctionsFrameAuctions_ValidateAuction();
end

function AuctionsFrameAuctions_ValidateAuction()
	AuctionsCreateAuctionButton:Disable();
	AuctionsBuyoutErrorText:Hide();
	-- No item
	if ( not GetAuctionSellItemInfo() ) then
		return;
	end
	if ( C_WowTokenPublic.IsAuctionableWowToken(select(10, GetAuctionSellItemInfo()))) then
		AuctionsCreateAuctionButton:SetEnabled(not AuctionsWowTokenAuctionFrame.disabled and C_WowTokenPublic.GetCurrentMarketPrice());
		return;
	end
	-- Buyout price is less than the start price
	if ( MoneyInputFrame_GetCopper(BuyoutPrice) > 0 and MoneyInputFrame_GetCopper(StartPrice) > MoneyInputFrame_GetCopper(BuyoutPrice) ) then
		AuctionsBuyoutErrorText:Show();
		return;
	end
	-- Start price is 0 or greater than the max allowed
	if ( MoneyInputFrame_GetCopper(StartPrice) < 1 or MoneyInputFrame_GetCopper(StartPrice) > MAXIMUM_BID_PRICE or MoneyInputFrame_GetCopper(BuyoutPrice) > MAXIMUM_BID_PRICE) then
		return;
	end
	-- The stack size is greater than total count
	local stackCount = AuctionsItemButton.stackCount or 0;
	local totalCount = AuctionsItemButton.totalCount or 0;
	if ( AuctionsStackSizeEntry:GetNumber() == 0 or AuctionsStackSizeEntry:GetNumber() > stackCount or AuctionsNumStacksEntry:GetNumber() == 0 or (AuctionsStackSizeEntry:GetNumber() * AuctionsNumStacksEntry:GetNumber() > totalCount) ) then
		return;
	end
	AuctionsCreateAuctionButton:Enable();
	UpdateDeposit();
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

function AuctionFrame_GetTimeLeftTooltipText(id, isToken)
	local text = _G["AUCTION_TIME_LEFT"..id.."_DETAIL"];
	if (isToken) then
		text = ESTIMATED_TIME_TO_SELL_LABEL..text;
	end
	return text;
end

local function SetupUnitPriceTooltip(tooltip, auctionItem, insertNewline)
	if ( auctionItem and auctionItem.itemCount > 1 ) then
		local hasBid = auctionItem.bidAmount > 0;
		local hasBuyout = auctionItem.buyoutPrice > 0;
		
		if ( hasBid ) then
			if ( insertNewline ) then
				tooltip:AddLine("|n");
			end

			SetTooltipMoney(tooltip, ceil(auctionItem.bidAmount / auctionItem.itemCount), "STATIC", AUCTION_TOOLTIP_BID_PREFIX);
		end

		if ( hasBuyout ) then
			SetTooltipMoney(tooltip, ceil(auctionItem.buyoutPrice / auctionItem.itemCount), "STATIC", AUCTION_TOOLTIP_BUYOUT_PREFIX);
		end

		-- This is necessary to update the extents of the tooltip
		tooltip:Show();
	end
end

local function GetAuctionButton(buttonType, id)
	if ( buttonType == "owner" ) then
		return _G["AuctionsButton"..id];
	elseif ( buttonType == "bidder" ) then
		return _G["BidButton"..id];
	elseif ( buttonType == "list" ) then
		return _G["BrowseButton"..id];
	end
end

function AuctionBrowseFrame_CheckUnlockHighlight(self, selectedType, offset)
	local selected = GetSelectedAuctionItem(selectedType);
	if ( not selected or (selected ~= self:GetParent():GetID() + offset) ) then
		self:GetParent():UnlockHighlight();
	end
end

function AuctionPriceTooltipFrame_OnLoad(self)
	self:SetMouseClickEnabled(false);
	self:SetMouseMotionEnabled(true);	
end

function AuctionPriceTooltipFrame_OnEnter(self)
	self:GetParent():LockHighlight();

	-- Unit price is only supported on the list tab, no need to pass in buttonType argument
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local button = GetAuctionButton("list", self:GetParent():GetID());
	SetupUnitPriceTooltip(GameTooltip, button, false);
end

function AuctionPriceTooltipFrame_OnLeave(self)
	AuctionBrowseFrame_CheckUnlockHighlight(self, "list", FauxScrollFrame_GetOffset(BrowseScrollFrame));
	GameTooltip_Hide();
end

function AuctionFrameItem_OnEnter(self, type, index)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	if ( index <= 0 ) then
		-- WoW Token
		local itemID = C_WowTokenPublic.GetListedAuctionableTokenInfo(index + C_WowTokenPublic.GetNumListedAuctionableTokens());
		GameTooltip:SetItemByID(itemID);
	else
		local hasCooldown, speciesID, level, breedQuality, maxHealth, power, speed, name = GameTooltip:SetAuctionItem(type, index);
		if(speciesID and speciesID > 0) then
			BattlePetToolTip_Show(speciesID, level, breedQuality, maxHealth, power, speed, name);
			return;
		end
	end

	-- add price per unit info
	local button = GetAuctionButton(type, self:GetParent():GetID());

	SetupUnitPriceTooltip(GameTooltip, button, true);
	GameTooltip_ShowCompareItem();

	if ( IsModifiedClick("DRESSUP") ) then
		ShowInspectCursor();
	else
		ResetCursor();
	end
end

function AuctionsWowTokenAuctionFrame_OnLoad(self)
	self:RegisterEvent("TOKEN_MARKET_PRICE_UPDATED");
	self:RegisterEvent("TOKEN_STATUS_CHANGED");
	self:RegisterEvent("TOKEN_SELL_RESULT");
	self:RegisterEvent("TOKEN_AUCTION_SOLD");
end

function AuctionsWowTokenAuctionFrame_OnEvent(self, event, ...)
	if (event == "TOKEN_MARKET_PRICE_UPDATED") then
		local result = ...;
		if (result == LE_TOKEN_RESULT_ERROR_DISABLED) then
			self.disabled = true;
		end
		AuctionsWowTokenAuctionFrame_Update();
		AuctionsFrameAuctions_ValidateAuction();
	elseif (event == "TOKEN_STATUS_CHANGED") then
		AuctionWowToken_UpdateMarketPrice();
	elseif (event == "TOKEN_SELL_RESULT") then
		local result = ...;
		if (result == LE_TOKEN_RESULT_ERROR_DISABLED) then
			UIErrorsFrame:AddMessage(TOKEN_AUCTIONS_UNAVAILABLE, 1.0, 0.1, 0.1, 1.0);
		elseif (result ~= LE_TOKEN_RESULT_SUCCESS) then
			UIErrorsFrame:AddMessage(ERR_AUCTION_DATABASE_ERROR, 1.0, 0.1, 0.1, 1.0);
		else
			C_WowTokenPublic.UpdateListedAuctionableTokens();
			
			local info = ChatTypeInfo["SYSTEM"];
			DEFAULT_CHAT_FRAME:AddMessage(ERR_AUCTION_STARTED, info.r, info.g, info.b, info.id);
		end
	elseif (event == "TOKEN_AUCTION_SOLD") then
		C_WowTokenPublic.UpdateListedAuctionableTokens();
	elseif (event == "GET_ITEM_INFO_RECEIVED") then
		self:UnregisterEvent("GET_ITEM_INFO_RECEIVED");
		AuctionFrameAuctions_Update();
	end
end

function AuctionsWowTokenAuctionFrame_Update()
	local price, duration = C_WowTokenPublic.GetCurrentMarketPrice();
	if (WowToken_IsWowTokenAuctionDialogShown()) then
		price = C_WowTokenPublic.GetGuaranteedPrice();
	end
	if (price) then
		AuctionsWowTokenAuctionFrame.MarketPrice:SetText(GetMoneyString(price, true));
		local timeToSellString = _G[("AUCTION_TIME_LEFT%d_DETAIL"):format(duration)];
		AuctionsWowTokenAuctionFrame.TimeToSell:SetText(timeToSellString);
	else
		AuctionsWowTokenAuctionFrame.MarketPrice:SetText(TOKEN_MARKET_PRICE_NOT_AVAILABLE);
		AuctionsWowTokenAuctionFrame.TimeToSell:SetText(UNKNOWN);
	end
end

function AuctionWowToken_UpdateMarketPriceCallback()
	if (C_WowTokenPublic.GetCommerceSystemStatus() 
		and ((BrowseWowTokenResults:IsVisible() or AuctionsWowTokenAuctionFrame:IsVisible()) and not WowToken_IsWowTokenAuctionDialogShown())) then
		AuctionFrame.lastMarketPriceUpdate = GetTime();
		C_WowTokenPublic.UpdateMarketPrice();
	elseif (not (BrowseWowTokenResults:IsVisible() or AuctionsWowTokenAuctionFrame:IsVisible())) then
		AuctionWowToken_CancelUpdateTicker();
	end
end

function AuctionWowToken_ShouldUpdatePrice()
	local now = GetTime();
	local enabled, pollTimeSeconds = C_WowTokenPublic.GetCommerceSystemStatus();
	if (not enabled) then
		return false;
	elseif (not C_WowTokenPublic.GetCurrentMarketPrice()) then
		return true;
	elseif (not AuctionFrame.lastMarketPriceUpdate) then
		return true;
	elseif (now - AuctionFrame.lastMarketPriceUpdate > pollTimeSeconds) then
		return true;
	end
	return false;
end

function AuctionWowToken_UpdateMarketPrice()
	if (AuctionWowToken_ShouldUpdatePrice()) then	
		AuctionFrame.lastMarketPriceUpdate = GetTime();
		C_WowTokenPublic.UpdateMarketPrice();
	end
	if ((BrowseWowTokenResults:IsVisible() or AuctionsWowTokenAuctionFrame:IsVisible()) and not WowToken_IsWowTokenAuctionDialogShown()) then
		local _, pollTimeSeconds = C_WowTokenPublic.GetCommerceSystemStatus();
		if (not AuctionFrame.priceUpdateTimer or pollTimeSeconds ~= AuctionFrame.priceUpdateTimer.pollTimeSeconds) then
			if (AuctionFrame.priceUpdateTimer) then
				AuctionFrame.priceUpdateTimer:Cancel();
			end
			AuctionFrame.priceUpdateTimer = C_Timer.NewTicker(pollTimeSeconds, AuctionWowToken_UpdateMarketPriceCallback);
			AuctionFrame.priceUpdateTimer.pollTimeSeconds = pollTimeSeconds;
		end
	end
end

function AuctionWowToken_CancelUpdateTicker()
	if (AuctionFrame.priceUpdateTimer) then
		AuctionFrame.priceUpdateTimer:Cancel();
		AuctionFrame.priceUpdateTimer = nil;
	end
end

-- SortButton functions
function SortButton_UpdateArrow(button, type, sort)
	local primaryColumn, reversed = GetAuctionSort(type, 1);
	button.Arrow:SetShown(sort == primaryColumn);
	if (sort == primaryColumn) then
		if (reversed) then
			button.Arrow:SetTexCoord(0, 0.5625, 1, 0);
		else
			button.Arrow:SetTexCoord(0, 0.5625, 0, 1);
		end
	end
end

-- Function to close popups if another auction item is selected
function CloseAuctionStaticPopups()
	StaticPopup_Hide("BUYOUT_AUCTION");
	StaticPopup_Hide("BID_AUCTION");
	StaticPopup_Hide("CANCEL_AUCTION");
end

function AuctionsCreateAuctionButton_OnClick()
	if (C_WowTokenPublic.IsAuctionableWowToken(select(10, GetAuctionSellItemInfo()))) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
		C_WowTokenPublic.SellToken();
	else
		LAST_ITEM_START_BID = MoneyInputFrame_GetCopper(StartPrice);
		LAST_ITEM_BUYOUT = MoneyInputFrame_GetCopper(BuyoutPrice);
		DropCursorMoney();
		PlaySound(SOUNDKIT.LOOT_WINDOW_COIN_SOUND);
		local startPrice = MoneyInputFrame_GetCopper(StartPrice);
		local buyoutPrice = MoneyInputFrame_GetCopper(BuyoutPrice);
		if ( AuctionFrameAuctions.priceType == PRICE_TYPE_UNIT ) then
			startPrice = startPrice * AuctionsStackSizeEntry:GetNumber();
			buyoutPrice = buyoutPrice * AuctionsStackSizeEntry:GetNumber();
		end
		local startPrice, buyoutPrice = GetPrices();
		PostAuction(startPrice, buyoutPrice, AuctionFrameAuctions.duration, AuctionsStackSizeEntry:GetNumber(), AuctionsNumStacksEntry:GetNumber());
	end
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
	local stackSize = AuctionsStackSizeEntry:GetNumber();
	if ( stackSize == 0 ) then
		AuctionsStackSizeMaxButton:Enable();
		AuctionsNumStacksMaxButton:Enable();
		return;
	end
	local stackCount = AuctionsItemButton.stackCount;
	local totalCount = AuctionsItemButton.totalCount;
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

function WowTokenGameTimeTutorialStoreButton_OnEvent(self, event)
	if event == "TRIAL_STATUS_UPDATE" then
		WowTokenGameTimeTutorialStoreButton_UpdateState(self);
	end
end

function WowTokenGameTimeTutorialStoreButton_UpdateState(self)
	if GameLimitedMode_IsActive() then
		self.tooltip = ERR_FEATURE_RESTRICTED_TRIAL;
		self:Disable();
	else
		self.tooltip = nil;
		self:Enable();
	end
end

function WowTokenGameTimeTutorialStoreButton_OnLoad(self)
	local fontString = self:GetFontString();
	fontString:SetPoint("CENTER", 8, 2);
	self.Logo:ClearAllPoints();
	self.Logo:SetPoint("RIGHT", fontString, "LEFT", -2, 0);
	WowTokenGameTimeTutorialStoreButton_UpdateState(self);
	self:RegisterEvent("TRIAL_STATUS_UPDATE");
end