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
};

local StorageWhileVisibleEvents = {
	"HOUSING_STORAGE_UPDATED",
	"HOUSING_STORAGE_ENTRY_UPDATED",
	"HOUSE_EDITOR_MODE_CHANGED",
	"HOUSING_MARKET_AVAILABILITY_UPDATED",
	"CATALOG_SHOP_FETCH_SUCCESS",
	"CATALOG_SHOP_FETCH_FAILURE",
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

	local initialWidth = Clamp(GetCVarNumberOrDefault("housingStoragePanelWidth"), self.minWidth, self.maxWidth);
	local initialHeight = Clamp(GetCVarNumberOrDefault("housingStoragePanelHeight"), self.minHeight, self.maxHeight);
	self:SetSize(initialWidth, initialHeight);

	self.ResizeButton:Init(self, self.minWidth, self.minHeight, self.maxWidth, self.maxHeight);
	self.ResizeButton:SetOnResizeStoppedCallback(self.OnResizeStopped);

	self:SetCollapsed(GetCVarBool("housingStoragePanelCollapsed"));

	self.catalogSearcher = C_HousingCatalog.CreateCatalogSearcher();
	self.catalogSearcher:SetResultsUpdatedCallback(function() self:OnEntryResultsUpdated(); end);
	self.catalogSearcher:SetAutoUpdateOnParamChanges(false);
	self.catalogSearcher:SetOwnedOnly(true);

	local editorMode = C_HouseEditor.GetActiveHouseEditorMode();
	self.catalogSearcher:SetEditorModeContext(editorMode);
	self.Filters:Initialize(self.catalogSearcher);
	self.SearchBox:Initialize(GenerateClosure(self.OnSearchTextUpdated, self));

	self.Categories:Initialize(GenerateClosure(self.OnCategoryFocusChanged, self), { withOwnedEntriesOnly = true, editorModeContext = editorMode });

	self:SetTabSystem(self.TabSystem);
	self.storageTabID = self:AddNamedTab(HOUSE_EDITOR_CATALOG_STORAGE_TAB);
	self:SetTabCallback(self.storageTabID, function() self:OnStorageTabSelected(); end);
	self.marketTabID = self:AddNamedTab(HOUSE_EDITOR_CATALOG_MARKET_TAB);
	self:SetTabCallback(self.marketTabID, function() self:OnMarketTabSelected(); end);

	self:SetTab(self.storageTabID);
	self:UpdateMarketTabVisibility();

	self.hasMarketData = false;

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
		end
	elseif event == "PLAYER_LEAVING_WORLD" then
		-- We're going to use leaving world as a "good enough" point for refreshing data from the catalog shop.
		self.hasMarketData = false;
	elseif event == "CATALOG_SHOP_FETCH_SUCCESS" or event == "CATALOG_SHOP_DATA_REFRESH" then
		C_HousingCatalog.RequestHousingMarketInfoRefresh();
		self.hasMarketData = true;
		self:UpdateCatalogData();
	elseif event == "CATALOG_SHOP_FETCH_FAILURE" then
		-- TODO:: We should probably have specific handling for the error. For now, just restart.
		local allowMovement = true;
		C_CatalogShop.OpenCatalogShopInteraction(allowMovement);
	end
end

function HouseEditorStorageFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, StorageWhileVisibleEvents);
	self:UpdateEditorMode(C_HouseEditor.GetActiveHouseEditorMode());

	self:UpdateMarketTabVisibility();

	if self.catalogSearcher then
		self.catalogSearcher:SetAutoUpdateOnParamChanges(true);
		self.catalogSearcher:RunSearch();
	end

	self:CheckStartMarketInteraction();

	SavedSetsUtil.ContinueOnLoad(function()
		self:UpdateMarketTabNotification();
		self:CheckShowMarketAllCategoryNotification();
	end);
end

function HouseEditorStorageFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, StorageWhileVisibleEvents);
	if self.catalogSearcher then
		self.catalogSearcher:SetAutoUpdateOnParamChanges(false);
	end

	if self.catalogShopInteractionStarted then
		C_CatalogShop.CloseCatalogShopInteraction();
		self.catalogShopInteractionStarted = false;
	end
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

	self.expandButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.HOUSING_CATALOG_EXPAND);
		self:SetCollapsed(false);
	end);
	self:UpdateCollapseState();
end

function HouseEditorStorageFrameMixin:OnEntryResultsUpdated()
	self:UpdateCatalogData();
end

function HouseEditorStorageFrameMixin:OnStorageTabSelected()
	self.catalogSearcher:SetOwnedOnly(true);
	local categorySearchParams = self.Categories:GetCategorySearchParams();
	categorySearchParams.withOwnedEntriesOnly = true;
	categorySearchParams.includeFeaturedCategory = false;
	self.Categories:SetCategorySearchParams(categorySearchParams);
	self.Categories:SetCategoriesBackground("house-chest-nav-bg_primary");

	self.Filters:SetHousingMarketFiltersAvailable(false);

	-- We need to check if the market tab should still show a notification.
	self:UpdateMarketTabNotification();
end

function HouseEditorStorageFrameMixin:OnMarketTabSelected()
	self.catalogSearcher:SetOwnedOnly(false);
	local categorySearchParams = self.Categories:GetCategorySearchParams();
	categorySearchParams.withOwnedEntriesOnly = false;
	categorySearchParams.includeFeaturedCategory = true;
	self.Categories:SetCategorySearchParams(categorySearchParams);
	self.Categories:SetFocus(Constants.HousingCatalogConsts.HOUSING_CATALOG_FEATURED_CATEGORY_ID);
	self.Categories:SetCategoriesBackground("house-chest-nav-bg_market");
	self:UpdateMarketTabNotification();
	self:CheckStartMarketInteraction();
end

function HouseEditorStorageFrameMixin:CheckStartMarketInteraction()
	if not self.catalogShopInteractionStarted and not self.hasMarketData and C_Housing.IsHousingMarketEnabled() then
		self.catalogShopInteractionStarted = true;

		local allowMovement = true;
		C_CatalogShop.OpenCatalogShopInteraction(allowMovement);
	end
end

function HouseEditorStorageFrameMixin:UpdateMarketTabVisibility()
	local marketEnabled = C_Housing.IsHousingMarketEnabled();
	local showingDecor = self.catalogSearcher:GetEditorModeContext() ~= Enum.HouseEditorMode.Layout;
	local showMarketTab = marketEnabled and showingDecor;
	self.TabSystem:SetTabShown(self.marketTabID, showMarketTab);

	if showMarketTab then
		self:UpdateMarketTabNotification();
	elseif self:IsInMarketTab() then
		-- We shouldn't be showing the market tab any more but we're in it, so switch to storage.
		self:SetTab(self.storageTabID);
	end
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
	if self:IsInMarketTab() then
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

function HouseEditorStorageFrameMixin:UpdateCatalogData()
	if not self:IsShown() then
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
			self.Filters:ResetFiltersToDefault();
			self.Filters:SetEnabled(false);
			self:ClearSearchText();
		elseif self.lastEditorMode == Enum.HouseEditorMode.Layout then
			self.Filters:SetEnabled(true);
			self:ClearSearchText();
		end

		self:UpdateMarketTabVisibility();

		self.lastEditorMode = newEditorMode;
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

function HouseEditorStorageFrameMixin:UpdateCollapseState()
	self:SetShown(not self.collapsed);

	if self.expandButton then
		self.expandButton:SetShown(self.collapsed);
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
		end
	end
end

function HouseEditorStorageFrameMixin:OnCategoryFocusChanged(focusedCategoryID, focusedSubcategoryID)
	local isFeaturedCategory = (focusedCategoryID == Constants.HousingCatalogConsts.HOUSING_CATALOG_FEATURED_CATEGORY_ID);
	self.Filters:SetEnabled(not isFeaturedCategory);
	if isFeaturedCategory then
		self:ClearSearchText();
		self:UpdateCatalogData();
	else
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
end

function HouseEditorStorageFrameMixin:ClearSearchText()
	if not self.catalogSearcher then
		return;
	end

	self.catalogSearcher:SetSearchText(nil);
	SearchBoxTemplate_ClearText(self.SearchBox);
end
