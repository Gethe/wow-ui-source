
AccountStoreItemDisplayMixin = {};

local AccountStoreItemDisplayEvents = {
	"ACCOUNT_STORE_CURRENCY_AVAILABLE_UPDATED",
};

function AccountStoreItemDisplayMixin:OnLoad()
	self.categoryTypeToItemRack = {};
	self.currentPage = 1;

	self.Footer.PrevPageButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.ACCOUNT_STORE_PAGE_NAVIGATION);
		self:SetPage(self.currentPage - 1);
	end);

	self.Footer.NextPageButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.ACCOUNT_STORE_PAGE_NAVIGATION);
		self:SetPage(self.currentPage + 1);
	end);

	self.Footer.CurrencyAvailable:SetScript("OnEnter", function(onEnterSelf)
		local tooltip = GetAppropriateTooltip();
		tooltip:SetOwner(onEnterSelf, "ANCHOR_RIGHT");

		local accountStoreCurrencyID = C_AccountStore.GetCurrencyIDForStore(Constants.AccountStoreConsts.PlunderstormStoreFrontID);
		if accountStoreCurrencyID then
			AccountStoreUtil.AddCurrencyTotalTooltip(tooltip, accountStoreCurrencyID);
			tooltip:Show();
		end
	end);

	self.Footer.CurrencyAvailable:SetScript("OnLeave", function() GetAppropriateTooltip():Hide(); end);

	self:AddDynamicEventMethod(EventRegistry, "AccountStore.StoreFrontSet", self.OnStoreFrontSet);
	self:AddDynamicEventMethod(EventRegistry, "AccountStore.CategorySelected", self.OnCategorySelected);
end

function AccountStoreItemDisplayMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);

	FrameUtil.RegisterFrameForEvents(self, AccountStoreItemDisplayEvents);

	if self.storeFrontID then
		C_AccountStore.RequestStoreFrontInfoUpdate(self.storeFrontID);
	end
end

function AccountStoreItemDisplayMixin:OnHide()
	CallbackRegistrantMixin.OnHide(self);

	FrameUtil.UnregisterFrameForEvents(self, AccountStoreItemDisplayEvents);
end

function AccountStoreItemDisplayMixin:OnEvent(event, ...)
	if event == "ACCOUNT_STORE_CURRENCY_AVAILABLE_UPDATED" then
		local currencyID = ...;
		if currencyID == self.currencyID then
			self:UpdateCurrencyAvailable();
		end
	end
end

function AccountStoreItemDisplayMixin:OnMouseWheel(delta)
	self:SetPage(self.currentPage + ((delta < 0) and 1 or -1));
end

function AccountStoreItemDisplayMixin:OnStoreFrontSet(storeFrontID)
	C_AccountStore.RequestStoreFrontInfoUpdate(storeFrontID);

	self.storeFrontID = storeFrontID;
	self.currencyID = C_AccountStore.GetCurrencyIDForStore(storeFrontID);
	self:UpdateCurrencyAvailable();
end

function AccountStoreItemDisplayMixin:OnCategorySelected(categoryID)
	if categoryID ~= self.categoryID then
		self.categoryID = categoryID;
		self.categoryItems = C_AccountStore.GetCategoryItems(categoryID);

		local categoryInfo = C_AccountStore.GetCategoryInfo(categoryID);
		local categoryType = categoryInfo.type;
		local itemRack = GetOrCreateTableEntryByCallback(self.categoryTypeToItemRack, categoryType, GenerateClosure(self.CreateItemRack, self, categoryType));

		if self.currentItemRack then
			self.currentItemRack:Hide();
		end

		self.currentItemRack = itemRack;
	end

	local forceUpdate = true;
	self:SetPage(1, forceUpdate);
	self.currentItemRack:Show();
end

function AccountStoreItemDisplayMixin:CreateItemRack(categoryType)
	local itemRack = CreateFrame("Frame", nil, self, "AccountStoreItemRackTemplate");
	itemRack:SetCategoryType(categoryType);
	itemRack:SetPoint("TOPLEFT");
	itemRack:SetPoint("BOTTOMRIGHT");
	self.categoryTypeToItemRack[categoryType] = itemRack;
	return itemRack;
end

function AccountStoreItemDisplayMixin:GetMaxPage()
	return math.ceil(#self.categoryItems / self.currentItemRack:GetMaxCards());
end

function AccountStoreItemDisplayMixin:SetPage(page, forceUpdate)
	local maxPage = self:GetMaxPage();
	page = Clamp(page, 1, maxPage);

	if page == self.currentPage and not forceUpdate then
		return;
	end

	self.currentPage = page;

	local items = {};
	local maxCardsPerPage = self.currentItemRack:GetMaxCards();
	for i = 1, page * maxCardsPerPage do
		local itemIndex = (page - 1) * maxCardsPerPage + i;
		table.insert(items, self.categoryItems[itemIndex]);
	end

	self.currentItemRack:SetItems(items);

	self.Footer.PrevPageButton:SetEnabled(page > 1);
	self.Footer.NextPageButton:SetEnabled(page < maxPage);
	self.Footer.PageText:SetText(ACCOUNT_STORE_PAGE_WIDGET_FORMAT:format(page, maxPage));
end

function AccountStoreItemDisplayMixin:UpdateCurrencyAvailable()
	local currencyID = self.currencyID;
	self.Footer.CurrencyAvailable:SetText(AccountStoreUtil.FormatCurrencyDisplayWithWarning(currencyID));

	if self.currentItemRack then
		self.currentItemRack:Refresh();
	end
end
