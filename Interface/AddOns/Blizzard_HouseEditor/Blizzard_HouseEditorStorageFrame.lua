
local FIXED_BUNDLE_WIDTH = 521;
local STORAGE_ICON_STRING = CreateAtlasMarkup("house-chest-icon", 16, 16);
local STORAGE_COUNT_FORMAT = STORAGE_ICON_STRING .. " %s / %d";
local FRAME_SLIDE_DURATION = 0.2;
local BUTTON_SLIDE_DURATION = 0.15;

local function GetTotalOwnedDecorStorageString()
	local totalOwnedCount, exemptOwnedCount = C_HousingCatalog.GetDecorTotalOwnedCount();
	local nonExemptOwnedCount = totalOwnedCount - exemptOwnedCount;
	local maxOwnedCount = C_HousingCatalog.GetDecorMaxOwnedCount();
	if maxOwnedCount == 0 then
		return "";
	end

	if nonExemptOwnedCount >= maxOwnedCount then
		nonExemptOwnedCount = RED_FONT_COLOR:WrapTextInColorCode(nonExemptOwnedCount);
	end

	return STORAGE_COUNT_FORMAT:format(nonExemptOwnedCount, maxOwnedCount);
end

HouseEditorStorageButtonMixin = {};

function HouseEditorStorageButtonMixin:OnEnter()
	for _, icon in ipairs(self.OverlayIcons) do
		icon:Show();
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
	GameTooltip:SetText(HOUSE_EDITOR_CATALOG_BUTTON_TOOLTIP);
	GameTooltip:Show();
end

function HouseEditorStorageButtonMixin:OnLeave()
	for _, icon in ipairs(self.OverlayIcons) do
		icon:Hide();
	end
	GameTooltip:Hide();
end

local StorageLifetimeEvents = {
	"HOUSING_CATALOG_SEARCHER_RELEASED",
	"PLAYER_LEAVING_WORLD",
	"CATALOG_SHOP_DATA_REFRESH",
	"HOUSE_EDITOR_MODE_CHANGED",
	"HOUSING_REFUND_LIST_UPDATED",
};

local StorageWhileVisibleEvents = {
	"HOUSING_STORAGE_UPDATED",
	"HOUSING_STORAGE_ENTRY_UPDATED",
	"HOUSING_MARKET_AVAILABILITY_UPDATED",
	"CATALOG_SHOP_FETCH_SUCCESS",

	-- We're not going to respond to failures for now. There's a CVar for retries: "shop2ClientRetriesEnabled"
	-- "CATALOG_SHOP_FETCH_FAILURE",
};

HouseEditorStorageFrameMixin = {};

function HouseEditorStorageFrameMixin:OnLoad()
	TabSystemOwnerMixin.OnLoad(self);

	self.CollapseButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.HOUSING_CATALOG_COLLAPSE);
		self:SetCollapsed(true);
	end);
	self.CollapseButton:SetScript("OnEnter", function()
		self.CollapseButton.OverlayIcon:Show();
	end);
	self.CollapseButton:SetScript("OnLeave", function()
		self.CollapseButton.OverlayIcon:Hide();
	end);

	self.OptionsContainer.CategoryTotal:SetScript("OnEnter", function()
		GameTooltip:SetOwner(self.OptionsContainer.CategoryTotal, "ANCHOR_RIGHT", 0, 0);

		local totalOwnedCount, exemptOwnedCount = C_HousingCatalog.GetDecorTotalOwnedCount();
		local nonExemptOwnedCount = totalOwnedCount - exemptOwnedCount;
		local maxOwnedCount = C_HousingCatalog.GetDecorMaxOwnedCount();
		if nonExemptOwnedCount > maxOwnedCount then
			GameTooltip_AddHighlightLine(GameTooltip, HOUSING_CATALOG_STORAGE_LIMIT_TOOLTIP_TITLE_OVER_LIMIT:format(nonExemptOwnedCount, maxOwnedCount));
		else
			GameTooltip_AddHighlightLine(GameTooltip, HOUSING_CATALOG_STORAGE_LIMIT_TOOLTIP_TITLE:format(nonExemptOwnedCount, maxOwnedCount));
		end

		GameTooltip_AddNormalLine(GameTooltip, HOUSING_CATALOG_STORAGE_LIMIT_TOOLTIP_DETAILS);
		GameTooltip_AddHighlightLine(GameTooltip, HOUSING_CATALOG_STORAGE_LIMIT_TOOLTIP_TOTALOWNED:format(totalOwnedCount));
		GameTooltip:Show();
	end);

	self.OptionsContainer.CategoryTotal:SetScript("OnLeave", function()
		GameTooltip_Hide();
	end);

	local initialWidth = Clamp(GetCVarNumberOrDefault("housingStoragePanelWidth"), self.minWidth, self.maxWidth);
	local initialHeight = Clamp(GetCVarNumberOrDefault("housingStoragePanelHeight"), self.minHeight, self.maxHeight);
	self:SetSize(initialWidth, initialHeight);

	self.ResizeButton:Init(self, self.minWidth, self.minHeight, self.maxWidth, self.maxHeight);
	self.ResizeButton:SetOnResizeStoppedCallback(self.OnResizeStopped);

	self:SetCollapsed(GetCVarBool("housingStoragePanelCollapsed"));

	FrameUtil.InitFrameAnimTransition(self, {
		translationType = AnimTransitionMixinTransitionType.SlideLeft,
		duration = FRAME_SLIDE_DURATION,
		easingFunction = EasingUtil.OutExponential,
		hideOnAnimOut = true,
		onAnimOutFinish = function()
			FunctionUtil.CheckInvokeMethod(self.expandButton, "Show");
			FunctionUtil.CheckInvokeMethod(self.expandButton, "StartAnimIn");
		end,
	});

	self.catalogSearcher = C_HousingCatalog.CreateCatalogSearcher();
	self.catalogSearcher:SetResultsUpdatedCallback(function() self:OnEntryResultsUpdated(); end);
	self.catalogSearcher:SetAutoUpdateOnParamChanges(false);
	self.catalogSearcher:SetOwnedOnly(true);

	local editorMode = C_HouseEditor.GetActiveHouseEditorMode();
	self.catalogSearcher:SetEditorModeContext(editorMode);
	self.Filters:Initialize(self.catalogSearcher);
	self.SearchBox:Initialize(GenerateClosure(self.OnSearchTextUpdated, self));

	self.Categories:Initialize(GenerateClosure(self.OnCategoryFocusChanged, self), { withOwnedEntriesOnly = true, editorModeContext = editorMode });

	-- There's far, far more indoor-only decor than there is outdoor-only, so only default the indoors filter on if we're inside the house
	-- That way outdoor decor isn't totally buried by default when trying to decorate outside
	-- (Have to set this after Filters:Initialize since it will otherwise reset all filter toggles back to default)
	self.catalogSearcher:SetAllowedIndoors(C_Housing.IsInsideHouse());

	self:SetTabSystem(self.TabSystem);
	self.storageTabID = self:AddNamedTab(HOUSE_EDITOR_CATALOG_STORAGE_TAB);
	self:SetTabCallback(self.storageTabID, function(isUserAction) self:OnStorageTabSelected(isUserAction); end);
	self.marketTabID = self:AddNamedTab(HOUSE_EDITOR_CATALOG_MARKET_TAB);
	self:SetTabCallback(self.marketTabID, function(isUserAction) self:OnMarketTabSelected(isUserAction); end);
	self:SetTabDeselectCallback(self.marketTabID, function() self:OnMarketTabDeselected(); end);

	--add a dialog confirming that you want to switch tabs, as doing so will delete your preview decor.
	self.TabSystem:SetTabSelectedCallback(function(tabID, isUserAction)
		if tabID == self.storageTabID and C_HousingDecor.GetNumPreviewDecor() > 0 then
			StaticPopup_Show("CONFIRM_DESTROY_PREVIEW_DECOR", nil, nil, function()
				self:SetTab(tabID, isUserAction);
			end);
			return true; --stops the tab from being selected, for now.
		else
			return self:SetTab(tabID, isUserAction);
		end
	end);

	self:SetTab(self.storageTabID);
	self:UpdateMarketTabVisibility();

	self.hasMarketData = false;

	self:AddDynamicEventMethod(EventRegistry, "HousingMarket.BundleSelected", self.OnHousingMarketBundleSelected);
	self:AddDynamicEventMethod(EventRegistry, "HousingMarketEvents.CartUpdated", self.OnHousingMarketCartUpdated);

	FrameUtil.RegisterFrameForEvents(self, StorageLifetimeEvents);
end

function HouseEditorStorageFrameMixin:OnEvent(event, ...)
	if event == "HOUSING_STORAGE_UPDATED" and self.catalogSearcher then
		self.catalogSearcher:RunSearch();
	elseif event == "HOUSING_STORAGE_ENTRY_UPDATED" then
		local entryID = ...;
		self:OnCatalogEntryUpdated(entryID);
	elseif event == "HOUSE_EDITOR_MODE_CHANGED" then
		local newMode = ...;
		self:UpdateEditorMode(newMode);
	elseif event == "HOUSING_MARKET_AVAILABILITY_UPDATED" then
		self:UpdateMarketTabVisibility();
	elseif event == "HOUSING_CATALOG_SEARCHER_RELEASED" then
		local releasedSearcher = ...;
		if self.catalogSearcher and self.catalogSearcher == releasedSearcher then
			-- This should only get called as part of ReloadUI
			-- Unfortunately can't just clear it by listening to LEAVING_WORLD because that'll happen after the searcher has already been released
			-- and after other receiving while-shown cleanup events that will lead this UI to attempt to reference it
			self.catalogSearcher = nil;
			self.Filters:ClearSearcherReference();
			self.OptionsContainer:ClearCatalogData();
		end
	elseif event == "PLAYER_LEAVING_WORLD" then
		-- We're going to use leaving world as a "good enough" point for refreshing data from the catalog shop.
		self:CheckCloseMarketInteraction();
		self:SetTab(self.storageTabID);
	elseif event == "CATALOG_SHOP_FETCH_SUCCESS" then
		self:RefreshMarketData();
	elseif event == "CATALOG_SHOP_DATA_REFRESH" then
		-- We want to avoid picking up updates from the catalog shop so only update when we're interacting.
		if self.catalogShopInteractionStarted then
			self:RefreshMarketData();
		end
	elseif event == "HOUSING_REFUND_LIST_UPDATED" then
		if self.hasRequestedRefundInfo and self:IsShown() then
			C_HousingCatalog.RequestHousingMarketRefundInfo();
		end
	end
end

local function SetCartFrameShown(shown, preserveCartState)
	local cartShownEvent = string.format("%s.%s", HOUSING_MARKET_EVENT_NAMESPACE, ShoppingCartVisualServices.SetCartFrameShown);
	EventRegistry:TriggerEvent(cartShownEvent, shown, preserveCartState);
end

function HouseEditorStorageFrameMixin:OnShow()
	CallbackRegistrantMixin.OnShow(self);
	FrameUtil.RegisterFrameForEvents(self, StorageWhileVisibleEvents);
	self:UpdateEditorMode(C_HouseEditor.GetActiveHouseEditorMode());

	self:UpdateMarketTabVisibility();

	if self.catalogSearcher then
		self.catalogSearcher:SetAutoUpdateOnParamChanges(true);
		self.catalogSearcher:RunSearch();
	end

	if not self.hasRequestedRefundInfo then
		self.hasRequestedRefundInfo = true;
		C_HousingCatalog.RequestHousingMarketRefundInfo();
	end

	self:CheckStartMarketInteraction();

	SavedSetsUtil.ContinueOnLoad(function()
		self:UpdateMarketTabNotification();
		self:CheckShowMarketAllCategoryNotification();
	end);

	self:UpdateCategoryTotal();

	if C_HousingDecor.IsPreviewState() or self:IsInMarketTab() then
		SetCartFrameShown(true, true);
	end

	-- Forces an update upon showing, reselecting the tab
	if self:IsInMarketTab() then
		self:SetTab(self.marketTabID);
	else
		self:SetTab(self.storageTabID);
	end
end

function HouseEditorStorageFrameMixin:OnHide()
	CallbackRegistrantMixin.OnHide(self);
	FrameUtil.UnregisterFrameForEvents(self, StorageWhileVisibleEvents);
	if self.catalogSearcher then
		self.catalogSearcher:SetAutoUpdateOnParamChanges(false);
	end

	SetCartFrameShown(false, true);
end

function HouseEditorStorageFrameMixin:OnResizeStopped()
	local newWidth = self:GetWidth();
	if newWidth > self.minWidth and newWidth < self.maxWidth then
		local optionsWidth = self.OptionsContainer.ScrollBox:GetWidth();
		local nonOptionsWidth = newWidth - optionsWidth;

		local snappedOptionsWidth = RoundToNearestMultiple(optionsWidth, self.widthSnapMultiplier);

		local snappedWidth = Clamp(nonOptionsWidth + snappedOptionsWidth, self.minWidth, self.maxWidth);
		
		if not ApproximatelyEqual(newWidth, snappedWidth) then
			self:SetWidth(snappedWidth);
		end
	end

	local finalWidth, finalHeight = self:GetSize();
	SetCVar("housingStoragePanelWidth", finalWidth);
	SetCVar("housingStoragePanelHeight", finalHeight);

	self.OptionsContainer:UpdateLayout();
end

function HouseEditorStorageFrameMixin:SetExpandButton(expandButton)
	self.expandButton = expandButton;

	FrameUtil.InitFrameAnimTransition(self.expandButton, {
		distanceX = self.expandButton:GetWidth() * 0.67,
		translationType = AnimTransitionMixinTransitionType.SlideLeft,
		duration = BUTTON_SLIDE_DURATION,
		easingFunction = EasingUtil.OutExponential,
		hideOnAnimOut = true,
		onAnimOutFinish = function()
			self:Show();
			self:StartAnimIn();
		end,
	});

	self.expandButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.HOUSING_CATALOG_EXPAND);
		self:SetCollapsed(false);
	end);

	local immediate = true;
	self:UpdateCollapseState(immediate);
end

function HouseEditorStorageFrameMixin:OnEntryResultsUpdated()
	self:UpdateCatalogData();
end

function HouseEditorStorageFrameMixin:OnTabChanged()
	self:UpdateMarketTabNotification();
	self:UpdateCategoryText();
	self:UpdateCategoryTotal();

	EventRegistry:TriggerEvent("HouseEditorStorage.TabChanged");
end

function HouseEditorStorageFrameMixin:OnStorageTabSelected(_isUserAction)
	self.catalogSearcher:SetOwnedOnly(true);
	local categorySearchParams = self.Categories:GetCategorySearchParams();
	categorySearchParams.withOwnedEntriesOnly = true;
	categorySearchParams.includeFeaturedCategory = false;
	self.Categories:SetCategorySearchParams(categorySearchParams);
	self.Categories:SetCategoriesBackground("house-chest-nav-bg_primary");
	self.Categories:SetManualFocusState(false);
	self.Filters:SetCollectionFiltersAvailable(false);
	C_HousingDecor.ExitPreviewState();
	self:OnTabChanged();

	local clearCartEvent = string.format("%s.%s", HOUSING_MARKET_EVENT_NAMESPACE, ShoppingCartDataServices.ClearCart);
	local requiresConfirmation = false;
	EventRegistry:TriggerEvent(clearCartEvent, requiresConfirmation);
end

function HouseEditorStorageFrameMixin:OnMarketTabSelected(isUserAction)
	if isUserAction then
		PlaySound(SOUNDKIT.HOUSING_MARKET_ENTER_CATALOG);
	end

	self.catalogSearcher:SetOwnedOnly(false);
	local categorySearchParams = self.Categories:GetCategorySearchParams();
	categorySearchParams.withOwnedEntriesOnly = false;
	categorySearchParams.includeFeaturedCategory = self:HasMarketEntries();
	self.Categories:SetCategorySearchParams(categorySearchParams);
	self.Categories:SetFocus(Constants.HousingCatalogConsts.HOUSING_CATALOG_FEATURED_CATEGORY_ID);
	self.Categories:SetCategoriesBackground("house-chest-nav-bg_market");
	self.Filters:SetCollectionFiltersAvailable(true);
	self:CheckStartMarketInteraction();
	C_HousingDecor.EnterPreviewState();
	self:OnTabChanged();

	SetCartFrameShown(true);
end

function HouseEditorStorageFrameMixin:OnMarketTabDeselected()
	C_HousingDecor.ExitPreviewState();
	SetCartFrameShown(false);
end

function HouseEditorStorageFrameMixin:ShouldShowMarketTab()
	return C_Housing.IsHousingMarketEnabled();
end

function HouseEditorStorageFrameMixin:ShouldEnableMarketTab()
	return self:ShouldShowMarketTab() and C_StorePublic.IsEnabled();
end

function HouseEditorStorageFrameMixin:HasMarketEntries()
	-- Assume we have entries until we know otherwise.
	if not self.hasMarketData then
		return true;
	end

	return C_HousingCatalog.HasFeaturedEntries();
end

function HouseEditorStorageFrameMixin:CheckStartMarketInteraction()
	if not self:ShouldEnableMarketTab() then
		return;
	end

	if not self.catalogShopInteractionStarted and not self.hasMarketData then
		self.catalogShopInteractionStarted = true;

		C_CatalogShop.OpenCatalogShopInteractionFromHouse();
	end
end

function HouseEditorStorageFrameMixin:CheckCloseMarketInteraction()
	if self.catalogShopInteractionStarted then
		C_CatalogShop.CloseCatalogShopInteraction();
		self.catalogShopInteractionStarted = false;
		self.hasMarketData = false;
	end
end

function HouseEditorStorageFrameMixin:UpdateMarketTabVisibility()
	local marketEnabled = self:ShouldShowMarketTab();
	local showingDecor = self.catalogSearcher:GetEditorModeContext() ~= Enum.HouseEditorMode.Layout;
	local showMarketTab = marketEnabled and showingDecor;
	self.TabSystem:SetTabShown(self.marketTabID, showMarketTab);

	if showMarketTab then
		local shouldEnableMarketTab = self:ShouldEnableMarketTab();
		self.TabSystem:SetTabEnabled(self.marketTabID, shouldEnableMarketTab, HOUSING_MARKET_TAB_UNAVAILABLE_TEXT);
		self:UpdateMarketTabNotification();

		if not shouldEnableMarketTab and self:IsInMarketTab() then
			self:SetTab(self.storageTabID);
		end
	elseif self:IsInMarketTab() then
		-- We shouldn't be showing the market tab any more but we're in it, so switch to storage.
		self:SetTab(self.storageTabID);
	end

	EventRegistry:TriggerEvent("HousingMarketTab.VisibilityUpdated");
end

function HouseEditorStorageFrameMixin:IsMarketTabShown()
	return self.TabSystem:IsTabShown(self.marketTabID);
end

function HouseEditorStorageFrameMixin:ShouldShowAllCategoryNotification()
	if not self:IsInMarketTab() or self.Categories:IsAllCategoryFocused() then
		return false;
	end

	return self:HasUnseenDecor();
end

function HouseEditorStorageFrameMixin:OnHousingMarketBundleSelected(bundleData)
	local bundleCatalogShopProductID = bundleData.productID;
	local productData = C_CatalogShop.GetProductInfo(bundleCatalogShopProductID);
	local name = productData and productData.name or nil;

	for _i, decorEntry in ipairs(bundleData.decorEntries) do
		decorEntry.bundleCatalogShopProductID = bundleCatalogShopProductID;
	end

	self:SetCustomCatalogData(bundleData.decorEntries, name, HOUSING_MARKET_BUNDLE_PREVIEW_DETAILS);
end

function HouseEditorStorageFrameMixin:OnHousingMarketCartUpdated()
	self.OptionsContainer:RefreshFrames();
end

function HouseEditorStorageFrameMixin:SetCustomCatalogData(entries, headerText, instructionText)
	self.customCatalogData = entries;

	if self.customCatalogData then
		local retainCurrentPosition = false;
		self.OptionsContainer:SetCatalogData(entries, retainCurrentPosition, headerText, instructionText);
		self.Categories:SetManualFocusState(true);
		self:RestoreWidth();
	else
		self.Categories:SetManualFocusState(false);
	end

	self:UpdateCategoryText();
	self:UpdateCategoryTotal();
end

function HouseEditorStorageFrameMixin:HasUnseenDecor()
	if not SavedSetsUtil.IsLoaded() then
		return false;
	end

	local numSearchItems = self.catalogSearcher:GetNumSearchItems();
	if self.checkedNumSearchItems ~= numSearchItems then
		-- If we haven't ever seen anything don't show a notification.
		if not SavedSetsUtil.HasAny(SavedSetsUtil.RegisteredSavedSets.SeenHousingMarketDecorIDs) then
			self.hasUnseenDecor = false;
		else
			local entries = self.catalogSearcher:GetAllSearchItems();
			local decorIDs = {};
			for _i, entryID in ipairs(entries) do
				if entryID.entryType == Enum.HousingCatalogEntryType.Decor then
					table.insert(decorIDs, entryID.recordID);
				end
			end

			self.hasUnseenDecor = not SavedSetsUtil.Check(SavedSetsUtil.RegisteredSavedSets.SeenHousingMarketDecorIDs, decorIDs);
		end

		self.checkedNumSearchItems = numSearchItems;
	end

	return self.hasUnseenDecor;
end

function HouseEditorStorageFrameMixin:CheckShowMarketAllCategoryNotification()
	self.Categories:SetCategoryNotification(Constants.HousingCatalogConsts.HOUSING_CATALOG_ALL_CATEGORY_ID, self:ShouldShowAllCategoryNotification());
end

function HouseEditorStorageFrameMixin:ShouldShowMarketTabNotification()
	if self:IsInMarketTab() or self.TabSystem:IsTabEnabled(self.marketTabID) then
		return false;
	end

	if self:HasUnseenDecor() then
		return true;
	end

	if not self.hasMarketData or not SavedSetsUtil.IsLoaded() then
		return false;
	end

	-- If we haven't ever seen anything don't show a notification.
	if not SavedSetsUtil.HasAny(SavedSetsUtil.RegisteredSavedSets.SeenShopCatalogProductIDs) then
		return false;
	end

	local availableProductIDs = self:GetAvailableProductIDs();
	if not SavedSetsUtil.Check(SavedSetsUtil.RegisteredSavedSets.SeenShopCatalogProductIDs, availableProductIDs) then
		return true;
	end

	return false;
end

function HouseEditorStorageFrameMixin:UpdateMarketTabNotification()
	self.TabSystem:SetTabNotification(self.marketTabID, self:ShouldShowMarketTabNotification());
end

function HouseEditorStorageFrameMixin:IsInMarketTab()
	return self:GetTab() == self.marketTabID;
end

function HouseEditorStorageFrameMixin:GetAvailableProductIDs()
	local availableProductIDs = {};
	for _i, bundleEntry in ipairs(C_HousingCatalog.GetFeaturedBundles()) do
		table.insert(availableProductIDs, bundleEntry.productID);
	end

	for _i, decorEntry in ipairs(C_HousingCatalog.GetFeaturedDecor()) do
		table.insert(availableProductIDs, decorEntry.productID);
	end

	return availableProductIDs;
end

function HouseEditorStorageFrameMixin:RefreshMarketData()
	C_HousingCatalog.RequestHousingMarketInfoRefresh();
	self.hasMarketData = true;

	if not self:HasMarketEntries() then
		local categorySearchParams = self.Categories:GetCategorySearchParams();
		categorySearchParams.includeFeaturedCategory = false;
		self.Categories:SetCategorySearchParams(categorySearchParams);
	elseif self:IsInMarketTab() then
		-- If we had previously cleared the "includeFeaturedCategory" param, reset it now.
		local categorySearchParams = self.Categories:GetCategorySearchParams();
		categorySearchParams.includeFeaturedCategory = true;
		self.Categories:SetCategorySearchParams(categorySearchParams);
	end

	self:UpdateCatalogData();
end

function HouseEditorStorageFrameMixin:UpdateCatalogData()
	if not self:IsShown() or self.customCatalogData then
		return;
	end

	self:UpdateMarketTabNotification();
	self:CheckShowMarketAllCategoryNotification();

	if self.Categories:IsFeaturedCategoryFocused() then
		if self.hasMarketData then
			local entries = C_HousingCatalog.GetFeaturedBundles();
			for _i, decorEntry in ipairs(C_HousingCatalog.GetFeaturedDecor()) do
				table.insert(entries, decorEntry.entryID);
			end

			local retainCurrentPosition = true;
			self.OptionsContainer:SetCatalogData(entries, retainCurrentPosition);

			local availableProductIDs = self:GetAvailableProductIDs();
			SavedSetsUtil.Set(SavedSetsUtil.RegisteredSavedSets.SeenShopCatalogProductIDs, availableProductIDs);
		end
	else
		local entries = self.catalogSearcher:GetCatalogSearchResults();
		local retainCurrentPosition = true;
		self.OptionsContainer:SetCatalogData(entries, retainCurrentPosition);

		if self:IsInMarketTab() then
			if self.Categories:IsAllCategoryFocused() then
				local decorIDs = {};
				for _i, entryID in ipairs(entries) do
					if entryID.entryType == Enum.HousingCatalogEntryType.Decor then
						table.insert(decorIDs, entryID.recordID);
					end
				end

				SavedSetsUtil.Set(SavedSetsUtil.RegisteredSavedSets.SeenHousingMarketDecorIDs, decorIDs);
				self.hasUnseenDecor = false;
			end
		end
	end

	self:UpdateLoadingSpinner();
	self:UpdateCategoryTotal();
end

function HouseEditorStorageFrameMixin:UpdateLoadingSpinner()
	if self.Categories:IsFeaturedCategoryFocused() then
		self.OptionsContainer:SetShown(self.hasMarketData);
		self.LoadingSpinner:SetShown(not self.hasMarketData);
	else
		self.OptionsContainer:Show();
		self.LoadingSpinner:Hide();
	end
end

function HouseEditorStorageFrameMixin:UpdateEditorMode(newEditorMode)
	if newEditorMode ~= Enum.HouseEditorMode.BasicDecor then
		self:CheckCloseMarketInteraction();
	end

	if newEditorMode == Enum.HouseEditorMode.None then
		self:SetCustomCatalogData(nil);

		if not self:IsVisible() then
			return;
		end
	end

	if not self.catalogSearcher then
		return;
	end

	if newEditorMode ~= self.catalogSearcher:GetEditorModeContext() then
		self.catalogSearcher:SetEditorModeContext(newEditorMode);
		local categorySearchParams = self.Categories:GetCategorySearchParams();
		categorySearchParams.editorModeContext = newEditorMode;
		self.Categories:SetCategorySearchParams(categorySearchParams);
	end

	if self.lastEditorMode ~= newEditorMode then
		if newEditorMode == Enum.HouseEditorMode.Layout then
			self.savedSortType = self.catalogSearcher:GetSortType();
			self.catalogSearcher:SetSortType(Enum.HousingCatalogSortType.Alphabetical);
			self.Filters:ResetFiltersToDefault();
			self.Filters:SetEnabled(false);
			self:ClearSearchText();
		else
			self.catalogSearcher:SetSortType(self.savedSortType or Enum.HousingCatalogSortType.DateAdded);

			if self.lastEditorMode == Enum.HouseEditorMode.Layout then
				self.Filters:SetEnabled(true);
				self:ClearSearchText();
			end
		end

		self:UpdateMarketTabVisibility();

		self.lastEditorMode = newEditorMode;
	end

	self:UpdateCategoryTotal();
end

function HouseEditorStorageFrameMixin:IsInLayoutMode()
	return self.lastEditorMode == Enum.HouseEditorMode.Layout;
end

function HouseEditorStorageFrameMixin:UpdateCategoryText()
	local categoryString = self.Categories:GetFocusedCategoryString();
	if not categoryString or self.customCatalogData then
		self.OptionsContainer:SetScrollBoxTopOffset(0);
		self.OptionsContainer.CategoryText:SetText("");
		return;
	end

	self.OptionsContainer:SetScrollBoxTopOffset(-28);
	self.OptionsContainer.CategoryText:SetText(categoryString);
	if self.catalogSearcher:GetFilteredCategoryID() == Constants.HousingCatalogConsts.HOUSING_CATALOG_ALL_CATEGORY_ID then
		self.OptionsContainer.CategoryText:SetTextColor(HOUSING_STORAGE_HEADER_COLOR:GetRGB());
	else
		self.OptionsContainer.CategoryText:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	end
end

function HouseEditorStorageFrameMixin:UpdateCategoryTotal()
	local categoryTotal = self.OptionsContainer.CategoryTotal;
	categoryTotal:Hide();

	if self:IsInMarketTab() or self:IsInLayoutMode() then
		return;
	end

	if self.Categories:IsAllCategoryFocused() then
		categoryTotal:Show();
		self.OptionsContainer.CategoryTotal:SetText(GetTotalOwnedDecorStorageString());
	elseif (not self.Filters:IsEnabled() or self.Filters:AreFiltersAtDefault()) and
			(self.catalogSearcher and not self.catalogSearcher:IsSearchInProgress()) and
			not self.customCatalogData then
		categoryTotal:Show();
		self.OptionsContainer.CategoryTotal:SetText(STORAGE_ICON_STRING .. " " .. self.catalogSearcher:GetSearchCount());
	end
end

function HouseEditorStorageFrameMixin:OnCatalogEntryUpdated(entryID)
	local entryInfo = C_HousingCatalog.GetCatalogEntryInfo(entryID);
	local shouldShowOption = entryInfo and entryInfo.quantity > 0 or false;

	local elementData, optionFrame = self.OptionsContainer:TryGetElementAndFrame(entryID);
	
	-- If option was added or removed entirely, reset our options list
	if self.catalogSearcher and ((shouldShowOption and not elementData) or (not shouldShowOption and elementData)) then
		self.catalogSearcher:RunSearch();
		return;
	end

	-- Otherwise, if the frame for this option is currently showing, update its data
	if shouldShowOption and optionFrame then
		optionFrame:UpdateEntryData();
	end
end

function HouseEditorStorageFrameMixin:SetCollapsed(shouldCollapse)
	self.collapsed = shouldCollapse;
	SetCVar("housingStoragePanelCollapsed", shouldCollapse);
	self:UpdateCollapseState();
end

function HouseEditorStorageFrameMixin:IsCollapsed()
	return self.collapsed;
end

function HouseEditorStorageFrameMixin:UpdateCollapseState(immediate)
	if self.collapsed then
		-- No animation if we're not starting from a shown state.
		if immediate or not self:IsShown() then
			FunctionUtil.CheckInvokeMethod(self.expandButton, "Show");
			self:Hide();
		else
			self:StartAnimOut();
		end
	else
		-- No animation if we're not starting from a shown state.
		if immediate or not FunctionUtil.CheckInvokeMethod(self.expandButton, "IsShown") then
			FunctionUtil.CheckInvokeMethod(self.expandButton, "Hide");
			self:Show();
		else
			FunctionUtil.CheckInvokeMethod(self.expandButton, "StartAnimOut");
		end
	end
end

function HouseEditorStorageFrameMixin:OnSearchTextUpdated(newSearchText)
	if not self.catalogSearcher then
		return;
	end

	if newSearchText ~= self.catalogSearcher:GetSearchText() then
		self.catalogSearcher:SetSearchText(newSearchText);

		-- On searching something new, clear out any active category focus so we're searching all categories
		if newSearchText and newSearchText ~= "" then
			self.catalogSearcher:SetFilteredCategoryID(nil);
			self.catalogSearcher:SetFilteredSubcategoryID(nil);
			self.Categories:SetFocus(Constants.HousingCatalogConsts.HOUSING_CATALOG_ALL_CATEGORY_ID);

			self:UpdateCategoryText();
			self:UpdateCategoryTotal();
		end
	end
end

function HouseEditorStorageFrameMixin:OnCategoryFocusChanged(focusedCategoryID, focusedSubcategoryID)
	self.customCatalogData = nil;

	local isFeaturedCategory = (focusedCategoryID == Constants.HousingCatalogConsts.HOUSING_CATALOG_FEATURED_CATEGORY_ID);
	self.Filters:SetEnabled(not isFeaturedCategory);
	if isFeaturedCategory then
		-- Force a minimum width to fit bundles.
		self:SetWidth(FIXED_BUNDLE_WIDTH);
		self.ResizeButton:SetEnabled(false);

		self:ClearSearchText();
		self:UpdateCatalogData();
	else
		self:RestoreWidth();

		if not self.catalogSearcher then
			return;
		end

		if self.catalogSearcher:GetFilteredCategoryID() == focusedCategoryID and self.catalogSearcher:GetFilteredSubcategoryID() == focusedSubcategoryID then
			self:UpdateCatalogData();
			return;
		end

		self.catalogSearcher:SetFilteredCategoryID(focusedCategoryID);
		self.catalogSearcher:SetFilteredSubcategoryID(focusedSubcategoryID);

		-- On focusing categories, clear out any previous search text
		if (focusedCategoryID or focusedSubcategoryID) and self.catalogSearcher:GetSearchText() then
			if focusedCategoryID ~= Constants.HousingCatalogConsts.HOUSING_CATALOG_ALL_CATEGORY_ID then
				self:ClearSearchText();
			end
		end
	end

	self:UpdateCategoryText();
	self:UpdateCategoryTotal();
end

function HouseEditorStorageFrameMixin:ClearSearchText()
	if not self.catalogSearcher then
		return;
	end

	self.catalogSearcher:SetSearchText(nil);
	SearchBoxTemplate_ClearText(self.SearchBox);
end

function HouseEditorStorageFrameMixin:RestoreWidth()
	-- Restore width in case it was previously forced to be larger.
	self:SetWidth(GetCVarNumberOrDefault("housingStoragePanelWidth"));
	self.ResizeButton:SetEnabled(true);
end
