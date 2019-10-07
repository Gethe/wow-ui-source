local PRICE_DISPLAY_WIDTH = 120;
local PRICE_DISPLAY_WITH_CHECKMARK_WIDTH = 140;
local PRICE_DISPLAY_PADDING = 0;
local BUYOUT_DISPLAY_PADDING = 0;
local STANDARD_PADDING = 10;


AuctionHouseTableCellMixin = CreateFromMixins(TableBuilderCellMixin);

function AuctionHouseTableCellMixin:Init(owner)
	self.owner = owner;
end

function AuctionHouseTableCellMixin:GetOwner()
	return self.owner;
end

function AuctionHouseTableCellMixin:GetAuctionHouseFrame()
	return self:GetOwner():GetAuctionHouseFrame();
end


AuctionHouseTableCellItemKeyMixin = CreateFromMixins(AuctionHouseTableCellMixin);

function AuctionHouseTableCellItemKeyMixin:OnEvent(event, ...)
	if event == "ITEM_KEY_ITEM_INFO_RECEIVED" then
		local itemID = ...;
		if itemID == self.pendingItemID then
			self:TryUpdateDisplay();
		end
	end
end

function AuctionHouseTableCellItemKeyMixin:OnHide()
	self:UnregisterEvent("ITEM_KEY_ITEM_INFO_RECEIVED");
	self.pendingItemID = nil;
end

function AuctionHouseTableCellItemKeyMixin:Populate(rowData, dataIndex)
	self.rowData = rowData;
	self:TryUpdateDisplay();
end

function AuctionHouseTableCellItemKeyMixin:TryUpdateDisplay()
	local itemKey = self.rowData.itemKey;
	local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(itemKey);
	if not itemKeyInfo then
		self.pendingItemID = itemKey.itemID;
		self:RegisterEvent("ITEM_KEY_ITEM_INFO_RECEIVED");
		self.Text:SetText("");
		return;
	end

	if self.pendingItemID ~= nil then
		self:UnregisterEvent("ITEM_KEY_ITEM_INFO_RECEIVED");
		self.pendingItemID = nil;
	end

	self:UpdateDisplay(itemKey, itemKeyInfo);
end

function AuctionHouseTableCellItemKeyMixin:ClearDisplay()
	-- Implement in your derived mixin.
end

function AuctionHouseTableCellItemKeyMixin:UpdateDisplay(itemKey, itemKeyInfo)
	-- Implement in your derived mixin.
end


AuctionHouseTablePriceDisplayMixin = CreateFromMixins(AuctionHouseTableCellMixin);

function AuctionHouseTablePriceDisplayMixin:Init(owner)
	AuctionHouseTableCellMixin.Init(self, owner);

	self.MoneyDisplay:ClearAllPoints();
	self.MoneyDisplay:SetPoint("LEFT");
end

function AuctionHouseTablePriceDisplayMixin:UpdateWidth(rowData, dataIndex)
	-- Implement in derived mixin.
end


AuctionHouseTableCellAuctionsMixin = CreateFromMixins(AuctionHouseTableCellMixin);

function AuctionHouseTableCellAuctionsMixin:ShouldShowHighlighted(rowData)
	return self:IsDisplayingBids() and (self:GetAuctionHouseFrame():GetBidStatus(rowData) == AuctionHouseBidStatus.PlayerBid) or rowData.containsOwnerItem;
end

function AuctionHouseTableCellAuctionsMixin:IsDisplayingBids()
	return self:GetOwner():IsDisplayingBids();
end


AuctionHouseTableCellAuctionsTextMixin = CreateFromMixins(AuctionHouseTableCellAuctionsMixin);

function AuctionHouseTableCellAuctionsTextMixin:Populate(rowData, dataIndex)
	self.Text:SetFontObject(self:ShouldShowHighlighted(rowData) and Number13FontWhite or Number13FontGray);
end


AuctionHouseTableCellAuctionsPriceMixin = CreateFromMixins(AuctionHouseTableCellAuctionsMixin, AuctionHouseTablePriceDisplayMixin);

function AuctionHouseTableCellAuctionsPriceMixin:Populate(rowData, dataIndex)
	self.MoneyDisplay:SetFontAndIconDisabled(not self:ShouldShowHighlighted(rowData));
end


AuctionHouseTableCellUnitPriceMixin = CreateFromMixins(AuctionHouseTablePriceDisplayMixin);

function AuctionHouseTableCellUnitPriceMixin:Populate(rowData, dataIndex)
	self.MoneyDisplay:SetAmount(rowData.unitPrice);
	self:UpdateWidth(rowData, dataIndex);

	self.Checkmark:SetShown(rowData.containsOwnerItem);
end

function AuctionHouseTableCellUnitPriceMixin:UpdateWidth(rowData, dataIndex)
	self.MoneyDisplay:SetWidth(self:GetAuctionHouseFrame():GetMaxUnitPriceWidth(rowData.itemID, self.MoneyDisplay:GetFontObject()));
end


AuctionHouseTableCellCommoditiesQuantityMixin = CreateFromMixins(AuctionHouseTableCellMixin);

function AuctionHouseTableCellCommoditiesQuantityMixin:Init()
	self.Text:SetJustifyH("RIGHT");
end

function AuctionHouseTableCellCommoditiesQuantityMixin:Populate(rowData, dataIndex)
	self.Text:SetText(rowData.quantity);
end


AuctionHouseTableCellFavoriteMixin = CreateFromMixins(AuctionHouseTableCellMixin);

function AuctionHouseTableCellFavoriteMixin:Populate(rowData, dataIndex)
	self.FavoriteButton:SetItemKey(rowData.itemKey);
end

function AuctionHouseTableCellFavoriteMixin:OnShow()
	self:RegisterEvent("AUCTION_HOUSE_FAVORITES_UPDATED");
end

function AuctionHouseTableCellFavoriteMixin:OnHide()
	self:UnregisterEvent("AUCTION_HOUSE_FAVORITES_UPDATED");
end

function AuctionHouseTableCellFavoriteMixin:OnEvent()
	self.FavoriteButton:UpdateState();
end

function AuctionHouseTableCellFavoriteMixin:OnLineEnter()
	self.FavoriteButton:LockTexture();
end

function AuctionHouseTableCellFavoriteMixin:OnLineLeave()
	self.FavoriteButton:UnlockTexture();
end


AuctionHouseTableCellFavoriteButtonMixin = CreateFromMixins(AuctionHouseTableCellMixin);

function AuctionHouseTableCellFavoriteButtonMixin:OnClick()
	local setToFavorite = not C_AuctionHouse.IsFavoriteItem(self.itemKey);
	
	C_AuctionHouse.SetFavoriteItem(self.itemKey, setToFavorite);

	self:SetFavoriteState(setToFavorite);
end

function AuctionHouseTableCellFavoriteButtonMixin:OnEnter()
	local row = self:GetParent():GetParent();
	ExecuteFrameScript(row, "OnEnter");
end

function AuctionHouseTableCellFavoriteButtonMixin:OnLeave()
	local row = self:GetParent():GetParent();
	ExecuteFrameScript(row, "OnLeave");
end

function AuctionHouseTableCellFavoriteButtonMixin:SetItemKey(itemKey)
	self.itemKey = itemKey;

	local isFavorite = C_AuctionHouse.IsFavoriteItem(itemKey);
	self:SetFavoriteState(isFavorite);
end

function AuctionHouseTableCellFavoriteButtonMixin:SetFavoriteState(isFavorite)
	self.isFavorite = isFavorite;
	self.NormalTexture:SetAtlas(isFavorite and "auctionhouse-icon-favorite" or nil);
	self.HighlightTexture:SetAtlas(isFavorite and "auctionhouse-icon-favorite" or "auctionhouse-icon-favorite-off");
	self.HighlightTexture:SetBlendMode(isFavorite and "ADD" or "ADD");
	self.HighlightTexture:SetAlpha(isFavorite and 0.2 or 0.4);
end

function AuctionHouseTableCellFavoriteButtonMixin:LockTexture()
	if not self:IsFavorite() then
		self.NormalTexture:SetAtlas("auctionhouse-icon-favorite-off");
	end
end

function AuctionHouseTableCellFavoriteButtonMixin:UnlockTexture()
	if not self:IsFavorite() then
		self.NormalTexture:SetAtlas(nil);
	end
end

function AuctionHouseTableCellFavoriteButtonMixin:IsFavorite()
	return self.isFavorite;
end

function AuctionHouseTableCellFavoriteButtonMixin:UpdateState()
	local isFavorite = C_AuctionHouse.IsFavoriteItem(self.itemKey);
	self.isFavorite = isFavorite;
	self:SetFavoriteState(isFavorite);
end


AuctionHouseTableCellBidMixin = CreateFromMixins(AuctionHouseTablePriceDisplayMixin);

function AuctionHouseTableCellBidMixin:Init(owner)
	AuctionHouseTablePriceDisplayMixin.Init(self, owner);

	self.MoneyDisplay:SetFontAndIconDisabled(true);
end

function AuctionHouseTableCellBidMixin:Populate(rowData, dataIndex)
	local hasBid = rowData.bidAmount ~= nil;
	self.MoneyDisplay:SetShown(hasBid);
	if hasBid then
		self.MoneyDisplay:SetAmount(rowData.bidAmount);
		self:UpdateWidth(rowData, dataIndex);
		self:UpdateTextColor(rowData, dataIndex);
	end
end

function AuctionHouseTableCellBidMixin:UpdateTextColor(rowData, dataIndex)
	AuctionHouseUtil.SetBidsFrameBidTextColor(self.MoneyDisplay, self:GetAuctionHouseFrame():GetBidStatus(rowData));
end

function AuctionHouseTableCellBidMixin:UpdateWidth(rowData, dataIndex)
	self.MoneyDisplay:SetWidth(self:GetAuctionHouseFrame():GetMaxBidWidth(rowData.itemKey, self.MoneyDisplay:GetFontObject()));
end


AuctionHouseTableCellBuyoutMixin = CreateFromMixins(AuctionHouseTablePriceDisplayMixin);

function AuctionHouseTableCellBuyoutMixin:Populate(rowData, dataIndex)
	local hasBuyout = rowData.buyoutAmount ~= nil;
	self.MoneyDisplay:SetShown(hasBuyout);
	if hasBuyout then
		self.MoneyDisplay:SetAmount(rowData.buyoutAmount);
		self:UpdateWidth(rowData, dataIndex);
	end

	self.Checkmark:SetShown(rowData.containsOwnerItem);
end

function AuctionHouseTableCellBuyoutMixin:UpdateWidth(rowData, dataIndex)
	self.MoneyDisplay:SetWidth(self:GetAuctionHouseFrame():GetMaxBuyoutWidth(rowData.itemKey, self.MoneyDisplay:GetFontObject()));
end


AuctionHouseTableCellOwnedCheckmarkMixin = CreateFromMixins(AuctionHouseTableCellMixin);

function AuctionHouseTableCellOwnedCheckmarkMixin:Init(owner)
	AuctionHouseTableCellMixin.Init(self, owner);

	self.Icon:SetAtlas("auctionhouse-icon-checkmark", true);
end

function AuctionHouseTableCellOwnedCheckmarkMixin:Populate(rowData, dataIndex)
	self.Icon:SetShown(rowData.containsOwnerItem);
end


AuctionHouseTableSocketDisplayMixin = CreateFromMixins(AuctionHouseTableCellMixin);

function AuctionHouseTableSocketDisplayMixin:Init()
	AuctionHouseTableCellMixin.Init(self, owner);

	self.Icon:SetAtlas("auctionhouse-icon-socket", true);
end

function AuctionHouseTableSocketDisplayMixin:Populate(rowData, dataIndex)
	self:SetShown(rowData.containsSocketedItem);
end


AuctionHouseTableCellOwnersMixin = CreateFromMixins(AuctionHouseTableCellMixin);

function AuctionHouseTableCellOwnersMixin:Init(owner)
	AuctionHouseTableCellMixin.Init(self, owner);

	self.Text:SetFontObject(Number13FontGray);
end

function AuctionHouseTableCellOwnersMixin:Populate(rowData, dataIndex)
	self.Text:SetText(AuctionHouseUtil.GetSellersString(rowData));
end


AuctionHouseTableCellTimeLeftMixin = CreateFromMixins(AuctionHouseTableCellMixin);

function AuctionHouseTableCellTimeLeftMixin:Init(owner)
	AuctionHouseTableCellMixin.Init(self, owner);
	self.Text:SetJustifyH("RIGHT");
	self.Text:SetFontObject(Number13FontGray);
end

function AuctionHouseTableCellTimeLeftMixin:Populate(rowData, dataIndex)
	local hasExplicitTimeLeft = rowData.timeLeftSeconds ~= nil;
	self.Text:SetShown(hasExplicitTimeLeft);

	if hasExplicitTimeLeft then
		self.Text:SetText(AuctionHouseUtil.FormatTimeLeft(rowData.timeLeftSeconds, rowData.status));
	end
end


AuctionHouseTableCellTimeLeftBandMixin = CreateFromMixins(AuctionHouseTableCellMixin);

function AuctionHouseTableCellTimeLeftBandMixin:Init(owner)
	AuctionHouseTableCellMixin.Init(self, owner);
	self.Text:SetFontObject(Number13FontGray);
	self.Text:SetJustifyH("RIGHT");
end

function AuctionHouseTableCellTimeLeftBandMixin:Populate(rowData, dataIndex)
	local hasExplicitTimeLeft = rowData.timeLeft ~= nil;
	self.Text:SetShown(hasExplicitTimeLeft);

	if hasExplicitTimeLeft then
		self.Text:SetText(AuctionHouseUtil.GetTimeLeftBandText(rowData.timeLeft));
	end
end


AuctionHouseTableCellAuctionsBidMixin = CreateFromMixins(AuctionHouseTableCellAuctionsPriceMixin, AuctionHouseTableCellBidMixin);

function AuctionHouseTableCellAuctionsBidMixin:Init(...)
	AuctionHouseTableCellAuctionsPriceMixin.Init(self, ...);
	AuctionHouseTableCellBidMixin.Init(self, ...);
end

function AuctionHouseTableCellAuctionsBidMixin:Populate(rowData, dataIndex)
	if self:IsDisplayingBids() then
		self.MoneyDisplay:Show();

		AuctionHouseTableCellBidMixin.Populate(self, rowData, dataIndex);
	else
		self.MoneyDisplay:SetFontAndIconDisabled(true);

		local sold = rowData.status == Enum.AuctionStatus.Sold;
		self.Text:SetShown(sold);
		self.MoneyDisplay:SetShown(not sold);
		if sold then
			self.Text:SetText(AUCTION_HOUSE_INCOMING_AMOUNT);
		else
			AuctionHouseTableCellBidMixin.Populate(self, rowData, dataIndex);
		end
	end
end

function AuctionHouseTableCellAuctionsBidMixin:UpdateTextColor(rowData, dataIndex)
	if self:IsDisplayingBids() then
		AuctionHouseTableCellBidMixin.UpdateTextColor(self, rowData, dataIndex);
	else
		AuctionHouseUtil.SetOwnedAuctionBidTextColor(self.MoneyDisplay, rowData);
	end
end


AuctionHouseTableCellAllAuctionsBidMixin = CreateFromMixins(AuctionHouseTableCellAuctionsBidMixin);

function AuctionHouseTableCellAllAuctionsBidMixin:UpdateWidth(rowData, dataIndex)
	local maxWidth = self:IsDisplayingBids() and self:GetAuctionHouseFrame():GetMaxBidPriceWidthForAllBids(self.MoneyDisplay:GetFontObject()) or self:GetAuctionHouseFrame():GetMaxBidPriceWidthForAllAuctions(self.MoneyDisplay:GetFontObject());
	self.MoneyDisplay:SetWidth(maxWidth);
end


AuctionHouseTableCellAuctionsBuyoutMixin = CreateFromMixins(AuctionHouseTableCellAuctionsPriceMixin, AuctionHouseTableCellBuyoutMixin);

function AuctionHouseTableCellAuctionsBuyoutMixin:Init(...)
	AuctionHouseTableCellAuctionsPriceMixin.Init(self, ...);
	AuctionHouseTableCellBuyoutMixin.Init(self, ...);
end

function AuctionHouseTableCellAuctionsBuyoutMixin:Populate(rowData, dataIndex)
	AuctionHouseTableCellAuctionsPriceMixin.Populate(self, rowData, dataIndex);
	AuctionHouseTableCellBuyoutMixin.Populate(self, rowData, dataIndex);
end


AuctionHouseTableCellAllAuctionsBuyoutMixin = CreateFromMixins(AuctionHouseTableCellAuctionsBuyoutMixin);

function AuctionHouseTableCellAllAuctionsBuyoutMixin:UpdateWidth(rowData, dataIndex)
	local maxWidth = self:IsDisplayingBids() and self:GetAuctionHouseFrame():GetMaxBuyoutPriceWidthForAllBids(self.MoneyDisplay:GetFontObject()) or self:GetAuctionHouseFrame():GetMaxBuyoutPriceWidthForAllAuctions(self.MoneyDisplay:GetFontObject());
	self.MoneyDisplay:SetWidth(maxWidth);
end

function AuctionHouseTableCellAllAuctionsBuyoutMixin:ShouldShowHighlighted()
	return true;
end


AuctionHouseTableCellAuctionsOwnersMixin = CreateFromMixins(AuctionHouseTableCellAuctionsTextMixin);

function AuctionHouseTableCellAuctionsOwnersMixin:Populate(rowData, dataIndex)
	AuctionHouseTableCellOwnersMixin.Populate(self, rowData, dataIndex);
	AuctionHouseTableCellAuctionsTextMixin.Populate(self, rowData, dataIndex);
end


AuctionHouseTableCellAuctionsItemLevelMixin = CreateFromMixins(AuctionHouseTableCellMixin);

function AuctionHouseTableCellAuctionsItemLevelMixin:Init(...)
	AuctionHouseTableCellMixin.Init(self, ...);
	self.Text:SetJustifyH("RIGHT");
end

function AuctionHouseTableCellAuctionsItemLevelMixin:Populate(rowData, dataIndex)
	local itemKeyInfo = C_AuctionHouse.GetItemKeyInfo(rowData.itemKey);
	if itemKeyInfo then
		local itemQualityColor = ITEM_QUALITY_COLORS[itemKeyInfo.quality];
		self.Text:SetTextColor(itemQualityColor.color:GetRGB());
	end

	self.Text:SetText(rowData.itemKey.itemLevel);
end


AuctionHouseTableCellAuctionsCommoditiesQuantityMixin = CreateFromMixins(AuctionHouseTableCellAuctionsTextMixin);

function AuctionHouseTableCellAuctionsCommoditiesQuantityMixin:Populate(rowData, dataIndex)
	AuctionHouseTableCellCommoditiesQuantityMixin.Populate(self, rowData, dataIndex);
	AuctionHouseTableCellAuctionsTextMixin.Populate(self, rowData, dataIndex);
	self.Text:SetJustifyH("RIGHT");
	self.Text:SetFontObject(Number14FontWhite);
end


AuctionHouseTableCellAuctionsUnitPriceMixin = CreateFromMixins(AuctionHouseTableCellAuctionsPriceMixin, AuctionHouseTableCellUnitPriceMixin);

function AuctionHouseTableCellAuctionsUnitPriceMixin:Init(...)
	AuctionHouseTableCellAuctionsPriceMixin.Init(self, ...);
	AuctionHouseTableCellUnitPriceMixin.Init(self, ...);
end

function AuctionHouseTableCellAuctionsUnitPriceMixin:Populate(rowData, dataIndex)
	AuctionHouseTableCellAuctionsPriceMixin.Populate(self, rowData, dataIndex);
	AuctionHouseTableCellUnitPriceMixin.Populate(self, rowData, dataIndex);
end

function AuctionHouseTableCellAuctionsUnitPriceMixin:UpdateWidth(rowData, dataIndex)
	self.MoneyDisplay:SetWidth(self:GetAuctionHouseFrame():GetMaxUnitPriceWidth(rowData.itemID, self.MoneyDisplay:GetFontObject()));
end


AuctionHouseTableCellItemDisplayMixin = CreateFromMixins(AuctionHouseTableCellItemKeyMixin);

function AuctionHouseTableCellItemDisplayMixin:ClearDisplay()
	self.Text:SetText("");
	self.Icon:Hide();
end

function AuctionHouseTableCellItemDisplayMixin:UpdateDisplay(itemKey, itemKeyInfo)
	self.Text:SetText(AuctionHouseUtil.GetItemDisplayTextFromItemKey(itemKey, itemKeyInfo));
	self.Icon:SetTexture(itemKeyInfo.iconFileID);
	self.Icon:Show();
end


AuctionHouseTableCellAuctionsItemDisplayMixin = CreateFromMixins(AuctionHouseTableCellAuctionsMixin, AuctionHouseTableCellItemDisplayMixin);

function AuctionHouseTableCellAuctionsItemDisplayMixin:Init(...)
	AuctionHouseTableCellAuctionsMixin.Init(self, ...);
	AuctionHouseTableCellItemDisplayMixin.Init(self, ...);
end

function AuctionHouseTableCellAuctionsItemDisplayMixin:UpdateDisplay(itemKey, itemKeyInfo)
	AuctionHouseTableCellItemDisplayMixin.UpdateDisplay(self, itemKey, itemKeyInfo);
	if not self:IsDisplayingBids() then
		self.Text:SetText(AuctionHouseUtil.GetDisplayTextFromOwnedAuctionData(self.rowData, itemKeyInfo));
	end
end


AuctionHouseTableCellMinPriceMixin = CreateFromMixins(AuctionHouseTablePriceDisplayMixin);

function AuctionHouseTableCellMinPriceMixin:Init(rowData, dataIndex)
	AuctionHouseTableCellMixin.Init(self, owner);

	self.Checkmark:ClearAllPoints();
	self.Checkmark:SetPoint("RIGHT");

	self.MoneyDisplay:ClearAllPoints();
	self.MoneyDisplay:SetPoint("RIGHT", self.Checkmark, "LEFT", -6, 0);
end

function AuctionHouseTableCellMinPriceMixin:Populate(rowData, dataIndex)
	self.MoneyDisplay:SetAmount(rowData.minPrice);
	self.Checkmark:SetShown(rowData.containsOwnerItem);
end


AuctionHouseTableCellQuantityMixin = CreateFromMixins(AuctionHouseTableCellMixin);

function AuctionHouseTableCellQuantityMixin:Populate(rowData, dataIndex)
	self.Text:SetText(rowData.totalQuantity);
end


AuctionHouseTableCellLevelMixin = CreateFromMixins(AuctionHouseTableCellMixin);

function AuctionHouseTableCellLevelMixin:Populate(rowData, dataIndex)
	self.rowData = rowData;
	self:UpdateDisplay();
end

function AuctionHouseTableCellLevelMixin:UpdateDisplay()
	local extraInfo, quality = C_AuctionHouse.GetExtraBrowseInfo(self.rowData.itemKey);
	if not extraInfo then
		self.Text:SetText("");
		self:RegisterEvent("EXTRA_BROWSE_INFO_RECEIVED");
		return;
	end

	self:UnregisterEvent("EXTRA_BROWSE_INFO_RECEIVED");

	self.Text:SetText(extraInfo);
end

function AuctionHouseTableCellLevelMixin:OnEvent(event, ...)
	if event == "EXTRA_BROWSE_INFO_RECEIVED" then
		local itemID = ...;
		if self.rowData and self.rowData.itemKey and itemID == self.rowData.itemKey.itemID then
			self:UpdateDisplay();
		end
	end
end

function AuctionHouseTableCellLevelMixin:OnHide(event, ...)
	self:UnregisterEvent("EXTRA_BROWSE_INFO_RECEIVED");
end


AuctionHouseTableCellItemQuantityMixin = CreateFromMixins(AuctionHouseTableCellMixin);

function AuctionHouseTableCellItemQuantityMixin:Init(owner, hideBidStatus)
	AuctionHouseTableCellMixin.Init(self, owner);
	
	self.hideBidStatus = hideBidStatus;
	self.Text:SetJustifyH(self.justificationH or "LEFT");
end

function AuctionHouseTableCellItemQuantityMixin:Populate(rowData, dataIndex)
	local bidStatus = self:GetAuctionHouseFrame():GetBidStatus(rowData);
	local hasPlayerBid = bidStatus == AuctionHouseBidStatus.PlayerBid or bidStatus == AuctionHouseBidStatus.PlayerOutbid;
	local showPlayerBid = hasPlayerBid and not self.hideBidStatus;
	self.Text:SetShown(showPlayerBid or (rowData.quantity > 1));

	if showPlayerBid then
		self.Text:SetText(AuctionHouseUtil.GetBidTextFromStatus(bidStatus));
		self.Text:SetFontObject(Number13FontGray);
	else
		self.Text:SetText(rowData.quantity);
		self.Text:SetFontObject(Number14FontWhite);
	end
end


AuctionHouseTableHeaderStringMixin = CreateFromMixins(TableBuilderElementMixin);

function AuctionHouseTableHeaderStringMixin:Init(owner, headerText, sortOrder)
	self:SetText(headerText);

	if owner.RegisterHeader and sortOrder ~= nil then
		self.owner = owner;
		owner:RegisterHeader(self);

		self.sortOrder = sortOrder;

		self:SetScript("OnClick", function(...)
			self.owner:SetSortOrder(self.sortOrder);
			self:UpdateArrow();
		end);

		self:UpdateArrow();
	else
		self:SetEnabled(false);
		self.Arrow:Hide();
	end
end

function AuctionHouseTableHeaderStringMixin:UpdateArrow()
	local sortOrderState = self.owner:GetSortOrderState(self.sortOrder);
	self:SetArrowState(sortOrderState);
end

function AuctionHouseTableHeaderStringMixin:SetArrowState(sortOrderState)
	self.Arrow:SetShown(sortOrderState == AuctionHouseSortOrderState.PrimarySorted or sortOrderState == AuctionHouseSortOrderState.PrimaryReversed);
	if sortOrderState == AuctionHouseSortOrderState.PrimarySorted then
		self.Arrow:SetTexCoord(0, 1, 1, 0);
	elseif sortOrderState == AuctionHouseSortOrderState.PrimaryReversed then
		self.Arrow:SetTexCoord(0, 1, 0, 1);
	end
end


AuctionHouseTableBuilderMixin = {};

function AuctionHouseTableBuilderMixin:AddColumnInternal(owner, sortOrder, cellTemplate, ...)
	local column = self:AddColumn();

	if sortOrder then
		local headerName = AuctionHouseUtil.GetHeaderNameFromSortOrder(sortOrder);
		column:ConstructHeader("BUTTON", "AuctionHouseTableHeaderStringTemplate", owner, headerName, sortOrder);
	end

	column:ConstructCells("FRAME", cellTemplate, owner, ...);

	return column;
end

function AuctionHouseTableBuilderMixin:AddUnsortableColumnInternal(owner, headerText, cellTemplate, ...)
	local column = self:AddColumn();
	local sortOrder = nil;
	column:ConstructHeader("BUTTON", "AuctionHouseTableHeaderStringTemplate", owner, headerText, sortOrder);
	column:ConstructCells("FRAME", cellTemplate, owner, ...);
	return column;
end

function AuctionHouseTableBuilderMixin:AddFixedWidthColumn(owner, padding, width, leftCellPadding, rightCellPadding, sortOrder, cellTemplate, ...)
	local column = self:AddColumnInternal(owner, sortOrder, cellTemplate, ...);
	column:SetFixedConstraints(width, padding);
	column:SetCellPadding(leftCellPadding, rightCellPadding);
	return column;
end

function AuctionHouseTableBuilderMixin:AddFillColumn(owner, padding, fillCoefficient, leftCellPadding, rightCellPadding, sortOrder, cellTemplate, ...)
	local column = self:AddColumnInternal(owner, sortOrder, cellTemplate, ...);
	column:SetFillConstraints(fillCoefficient, padding);
	column:SetCellPadding(leftCellPadding, rightCellPadding);
	return column;
end

function AuctionHouseTableBuilderMixin:AddUnsortableFixedWidthColumn(owner, padding, width, leftCellPadding, rightCellPadding, headerText, cellTemplate, ...)
	local column = self:AddUnsortableColumnInternal(owner, headerText, cellTemplate, ...);
	column:SetFixedConstraints(width, padding);
	column:SetCellPadding(leftCellPadding, rightCellPadding);
	return column;
end

function AuctionHouseTableBuilderMixin:AddUnsortableFillColumn(owner, padding, fillCoefficient, leftCellPadding, rightCellPadding, headerText, cellTemplate, ...)
	local column = self:AddUnsortableColumnInternal(owner, headerText, cellTemplate, ...);
	column:SetFillConstraints(fillCoefficient, padding);
	column:SetCellPadding(leftCellPadding, rightCellPadding);
	return column;
end


AuctionHouseTableBuilder = {};

function AuctionHouseTableBuilder.GetAllAuctionsLayout(owner, itemList)
	local function LayoutAllAuctionsTableBuilder(tableBuilder)
		tableBuilder:SetColumnHeaderOverlap(2);
		tableBuilder:SetHeaderContainer(itemList:GetHeaderContainer());

		tableBuilder:AddFillColumn(owner, 0, 1.0, STANDARD_PADDING, 0, Enum.AuctionHouseSortOrder.Name, "AuctionHouseTableCellAuctionsItemDisplayTemplate");
		tableBuilder:AddFixedWidthColumn(owner, PRICE_DISPLAY_PADDING, PRICE_DISPLAY_WIDTH, STANDARD_PADDING, 0, Enum.AuctionHouseSortOrder.Bid, "AuctionHouseTableCellAllAuctionsBidTemplate");
		tableBuilder:AddFixedWidthColumn(owner, BUYOUT_DISPLAY_PADDING, PRICE_DISPLAY_WIDTH, STANDARD_PADDING, 0, Enum.AuctionHouseSortOrder.Buyout, "AuctionHouseTableCellAllAuctionsBuyoutTemplate");
		tableBuilder:AddFixedWidthColumn(owner, 0, 50, 0, STANDARD_PADDING, nil, "AuctionHouseTableCellTimeLeftTemplate");
	end

	return LayoutAllAuctionsTableBuilder;
end

function AuctionHouseTableBuilder.GetBidsListLayout(owner, itemList)
	local function LayoutBidsListTableBuilder(tableBuilder)
		tableBuilder:SetColumnHeaderOverlap(2);
		tableBuilder:SetHeaderContainer(itemList:GetHeaderContainer());

		tableBuilder:AddFillColumn(owner, 0, 1.0, 10, 0, Enum.AuctionHouseSortOrder.Name, "AuctionHouseTableCellAuctionsItemDisplayTemplate");
		tableBuilder:AddFixedWidthColumn(owner, PRICE_DISPLAY_PADDING, PRICE_DISPLAY_WIDTH, 10, 0, Enum.AuctionHouseSortOrder.Bid, "AuctionHouseTableCellAllAuctionsBidTemplate");
		tableBuilder:AddFixedWidthColumn(owner, BUYOUT_DISPLAY_PADDING, PRICE_DISPLAY_WIDTH, 10, 0, Enum.AuctionHouseSortOrder.Buyout, "AuctionHouseTableCellAllAuctionsBuyoutTemplate");
		tableBuilder:AddFixedWidthColumn(owner, 0, 100, 0, 10, nil, "AuctionHouseTableCellTimeLeftBandTemplate");
	end

	return LayoutBidsListTableBuilder;
end

function AuctionHouseTableBuilder.GetAuctionsItemListLayout(owner, itemList)
	local function LayoutAuctionsItemListTableBuilder(tableBuilder)
		tableBuilder:SetColumnHeaderOverlap(2);
		tableBuilder:SetHeaderContainer(itemList:GetHeaderContainer());

		tableBuilder:AddFixedWidthColumn(owner, PRICE_DISPLAY_PADDING, PRICE_DISPLAY_WIDTH, STANDARD_PADDING, 0, Enum.AuctionHouseSortOrder.Bid, "AuctionHouseTableCellAuctionsBidTemplate");
		tableBuilder:AddFixedWidthColumn(owner, BUYOUT_DISPLAY_PADDING, PRICE_DISPLAY_WITH_CHECKMARK_WIDTH, STANDARD_PADDING, 0, Enum.AuctionHouseSortOrder.Buyout, "AuctionHouseTableCellItemBuyoutTemplate");

		tableBuilder:AddFillColumn(owner, 1.0, 40, STANDARD_PADDING, 0, nil, "AuctionHouseTableCellItemQuantityLeftTemplate");
		tableBuilder:AddFixedWidthColumn(owner, 0, 14, 0, 0, nil, "AuctionHouseTableCellSocketDisplayTemplate");
		tableBuilder:AddFixedWidthColumn(owner, 0, 90, STANDARD_PADDING, 0, nil, "AuctionHouseTableCellAuctionsOwnersTemplate");
		tableBuilder:AddFixedWidthColumn(owner, 0, 60, 0, 10, nil, "AuctionHouseTableCellTimeLeftTemplate");
	end

	return LayoutAuctionsItemListTableBuilder;
end

function AuctionHouseTableBuilder.GetCommoditiesAuctionsListLayout(owner, itemList)
	local function LayoutCommoditiesAuctionsListTableBuilder(tableBuilder)
		tableBuilder:SetColumnHeaderOverlap(2);
		tableBuilder:SetHeaderContainer(itemList:GetHeaderContainer());

		tableBuilder:AddUnsortableFixedWidthColumn(owner, PRICE_DISPLAY_PADDING, PRICE_DISPLAY_WITH_CHECKMARK_WIDTH, 10, 0, AUCTION_HOUSE_HEADER_UNIT_PRICE, "AuctionHouseTableCellAuctionsUnitPriceTemplate");

		tableBuilder:AddFixedWidthColumn(owner, 0, 40, 0, 0, nil, "AuctionHouseTableCellAuctionsCommoditiesQuantityTemplate");
		tableBuilder:AddFillColumn(owner, 0, 1.0, 0, 0, nil, "AuctionHouseTableEmptyTemplate");
		tableBuilder:AddFixedWidthColumn(owner, 0, 90, 0, 0, nil, "AuctionHouseTableCellAuctionsOwnersTemplate");
		tableBuilder:AddFixedWidthColumn(owner, 0, 60, 0, 10, nil, "AuctionHouseTableCellTimeLeftTemplate");
	end

	return LayoutCommoditiesAuctionsListTableBuilder;
end

function AuctionHouseTableBuilder.GetBrowseListLayout(owner, itemList, extraInfoColumnText)
	local function LayoutBrowseListTableBuilder(tableBuilder)
		tableBuilder:SetColumnHeaderOverlap(2);
		tableBuilder:SetHeaderContainer(itemList:GetHeaderContainer());

		tableBuilder:AddFixedWidthColumn(owner, PRICE_DISPLAY_PADDING, 146, 0, 14, Enum.AuctionHouseSortOrder.Price, "AuctionHouseTableCellMinPriceTemplate");

		local nameColumn = tableBuilder:AddFillColumn(owner, 0, 1.0, STANDARD_PADDING, 0, Enum.AuctionHouseSortOrder.Name, "AuctionHouseTableCellItemDisplayTemplate");
		nameColumn:GetHeaderFrame():SetText(AUCTION_HOUSE_BROWSE_HEADER_NAME);

		if extraInfoColumnText then
			local extraInfoColumn = tableBuilder:AddFixedWidthColumn(owner, 0, 100, 0, 0, Enum.AuctionHouseSortOrder.Level, "AuctionHouseTableCellLevelTemplate");
			extraInfoColumn:GetHeaderFrame():SetText(extraInfoColumnText);
		end

		local quantityHeaderText = AuctionHouseUtil.GetHeaderNameFromSortOrder(Enum.AuctionHouseSortOrder.Quantity);
		tableBuilder:AddUnsortableFixedWidthColumn(owner, 0, 100, STANDARD_PADDING, 0, quantityHeaderText, "AuctionHouseTableCellQuantityTemplate");
		tableBuilder:AddFixedWidthColumn(owner, 0, 29, STANDARD_PADDING, 5, nil, "AuctionHouseTableCellFavoriteTemplate");
	end

	return LayoutBrowseListTableBuilder;
end

function AuctionHouseTableBuilder.GetCommoditiesBuyListLayout(owner)
	local function LayoutCommoditiesBuyListTableBuilder(tableBuilder)
		tableBuilder:AddFixedWidthColumn(owner, PRICE_DISPLAY_PADDING, PRICE_DISPLAY_WITH_CHECKMARK_WIDTH, 10, 0, nil, "AuctionHouseTableCellUnitPriceTemplate");

		tableBuilder:AddFillColumn(owner, 0, 1.0, 0, 10, nil, "AuctionHouseTableCellCommoditiesQuantityTemplate");
	end

	return LayoutCommoditiesBuyListTableBuilder;
end

function AuctionHouseTableBuilder.GetCommoditiesSellListLayout(owner, itemList)
	local function LayoutCommoditiesSellListTableBuilder(tableBuilder)
		tableBuilder:SetColumnHeaderOverlap(2);
		tableBuilder:SetHeaderContainer(itemList:GetHeaderContainer());

		local unitPriceColumn = tableBuilder:AddUnsortableFixedWidthColumn(owner, PRICE_DISPLAY_PADDING, PRICE_DISPLAY_WITH_CHECKMARK_WIDTH, STANDARD_PADDING, 0, AUCTION_HOUSE_HEADER_UNIT_PRICE, "AuctionHouseTableCellUnitPriceTemplate");
		unitPriceColumn:GetHeaderFrame():SetArrowState(AuctionHouseSortOrderState.PrimarySorted);

		local quantityColumn = tableBuilder:AddFillColumn(owner, 0, 1.0, 0, 90, nil, "AuctionHouseTableCellCommoditiesQuantityTemplate");
		quantityColumn:SetDisplayUnderPreviousHeader(true);

		tableBuilder:AddUnsortableFixedWidthColumn(owner, 0, 120, STANDARD_PADDING, 0, AUCTION_HOUSE_HEADER_SELLER, "AuctionHouseTableCellOwnersTemplate");
	end

	return LayoutCommoditiesSellListTableBuilder;
end

function AuctionHouseTableBuilder.GetItemBuyListLayout(owner, itemList)
	local function LayoutItemBuyListTableBuilder(tableBuilder)
		tableBuilder:SetColumnHeaderOverlap(2);
		tableBuilder:SetHeaderContainer(itemList:GetHeaderContainer());

		local bidColumn = tableBuilder:AddFixedWidthColumn(owner, PRICE_DISPLAY_PADDING, PRICE_DISPLAY_WIDTH, STANDARD_PADDING, 0, Enum.AuctionHouseSortOrder.Bid, "AuctionHouseTableCellBidTemplate");
		bidColumn:GetHeaderFrame():SetText(AUCTION_HOUSE_HEADER_CURRENT_BID);

		tableBuilder:AddFixedWidthColumn(owner, BUYOUT_DISPLAY_PADDING, PRICE_DISPLAY_WITH_CHECKMARK_WIDTH, STANDARD_PADDING, 0, Enum.AuctionHouseSortOrder.Buyout, "AuctionHouseTableCellBuyoutTemplate");

		tableBuilder:AddFillColumn(owner, 0, 1.0, STANDARD_PADDING, 0, nil, "AuctionHouseTableCellItemQuantityLeftTemplate");
		tableBuilder:AddFixedWidthColumn(owner, 0, 14, 0, 0, nil, "AuctionHouseTableCellSocketDisplayTemplate");
		tableBuilder:AddFixedWidthColumn(owner, 0, 100, STANDARD_PADDING, STANDARD_PADDING, nil, "AuctionHouseTableCellOwnersTemplate");
	end

	return LayoutItemBuyListTableBuilder;
end

function AuctionHouseTableBuilder.GetItemSellListLayout(owner, itemList, isEquipment, isPet)
	local function LayoutItemSellListTableBuilder(tableBuilder)
		tableBuilder:SetHeaderContainer(itemList:GetHeaderContainer());
		tableBuilder:SetColumnHeaderOverlap(2);

		tableBuilder:AddFixedWidthColumn(owner, PRICE_DISPLAY_PADDING, PRICE_DISPLAY_WIDTH, STANDARD_PADDING, 0, Enum.AuctionHouseSortOrder.Bid, "AuctionHouseTableCellBidTemplate");
		tableBuilder:AddFixedWidthColumn(owner, BUYOUT_DISPLAY_PADDING, PRICE_DISPLAY_WITH_CHECKMARK_WIDTH, STANDARD_PADDING, 0, Enum.AuctionHouseSortOrder.Buyout, "AuctionHouseTableCellItemBuyoutTemplate");

		local emptyColumn = tableBuilder:AddFillColumn(owner, 0, 1.0, 0, 0, nil, "AuctionHouseTableEmptyTemplate");
		emptyColumn:SetDisplayUnderPreviousHeader(true);

		if isEquipment then
			local socketColumn = tableBuilder:AddFixedWidthColumn(owner, 0, 24, 0, STANDARD_PADDING, nil, "AuctionHouseTableCellSocketDisplayTemplate");
			socketColumn:SetDisplayUnderPreviousHeader(true);

			local itemLevelColumn = tableBuilder:AddFixedWidthColumn(owner, 0, 50, 0, STANDARD_PADDING, Enum.AuctionHouseSortOrder.Level, "AuctionHouseTableCellAuctionsItemLevelTemplate");
			itemLevelColumn:GetHeaderFrame():SetText(ITEM_LEVEL_ABBR);
		elseif isPet then
			tableBuilder:AddFixedWidthColumn(owner, 0, 90, 0, STANDARD_PADDING, nil, "AuctionHouseTableCellOwnersTemplate");
		else
			local hideBidStatus = true;
			local quantityColumn = tableBuilder:AddFixedWidthColumn(owner, 0, 60, 0, STANDARD_PADDING, nil, "AuctionHouseTableCellItemQuantityRightTemplate", hideBidStatus);
			quantityColumn:SetDisplayUnderPreviousHeader(true);
		end
	end

	return LayoutItemSellListTableBuilder;
end
