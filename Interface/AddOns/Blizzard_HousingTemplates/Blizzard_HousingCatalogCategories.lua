----------------- Base Categories Mixin -----------------

local CategoriesWhileVisibleEvents = {
	"HOUSING_CATALOG_CATEGORY_UPDATED",
	"HOUSING_CATALOG_SUBCATEGORY_UPDATED",
	"HOUSING_STORAGE_UPDATED",
};

HousingCatalogCategoriesMixin = {};

function HousingCatalogCategoriesMixin:OnLoad()
	self.categoryPool = CreateFramePool("BUTTON", self, "HousingCatalogCategoryTemplate");
	self.subcategoryPool = CreateFramePool("BUTTON", self, "HousingCatalogSubcategoryTemplate");
	self.categorySearchParams = { withOwnedEntriesOnly = false };
	self.AllSubcategoriesStandIn:SetSize(self.subcategoryButtonSize, self.subcategoryButtonSize);
end

function HousingCatalogCategoriesMixin:OnEvent(event, ...)
	if event == "HOUSING_CATALOG_CATEGORY_UPDATED" then
		local categoryID = ...;
		self:OnCategoryUpdated(categoryID);
	elseif event == "HOUSING_CATALOG_SUBCATEGORY_UPDATED" then
		local subcategoryID = ...;
		self:OnSubcategoryUpdated(subcategoryID);
	elseif event == "HOUSING_STORAGE_UPDATED" then
		local skipFocusUpdate = false;
		self:UpdateFilteredCategories(skipFocusUpdate);
	end
end

function HousingCatalogCategoriesMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, CategoriesWhileVisibleEvents);

	local tryRetainFocus = true;
	self:PopulateCategories(tryRetainFocus);
end

function HousingCatalogCategoriesMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CategoriesWhileVisibleEvents);
end

function HousingCatalogCategoriesMixin:Initialize(onFocusChangedCallback, initialSearchParams)
	self.onFocusChangedCallback = onFocusChangedCallback;
	self.categorySearchParams = initialSearchParams;
end

function HousingCatalogCategoriesMixin:PopulateCategories(tryRetainFocus)
	self:ClearCategoryFrames();

	self.categories = {};

	-- Cache info for all categories regardless of filter so that we have a stable backing collection to filter from and update
	local noFilterParams = { withOwnedEntriesOnly = false, includeFeaturedCategory = true };
	local categoryIDs = C_HousingCatalog.SearchCatalogCategories(noFilterParams);
	for _, categoryID in ipairs(categoryIDs) do
		local categoryInfo = C_HousingCatalog.GetCatalogCategoryInfo(categoryID);
		self:AddCategoryInfo(categoryID, categoryInfo);
	end

	if not tryRetainFocus then
		self.focusedCategoryID = nil;
		self.focusedSubcategoryID = nil;
	end

	local skipFocusUpdate = true;
	self:UpdateFilteredCategories(skipFocusUpdate);

	local forceRebuild = true;
	self:SetFocus(self.focusedCategoryID, self.focusedSubcategoryID, forceRebuild);
end

function HousingCatalogCategoriesMixin:SetCategorySearchParams(searchParams)
	if self.categorySearchParams and self.filteredCategories and self.filteredSubcategories and tCompare(self.categorySearchParams, searchParams) then
		return;
	end

	-- Don't update the search if it hasn't been initialized yet.
	if not self.categories then
		return;
	end

	self.categorySearchParams = searchParams;
	local skipFocusUpdate = false;
	self:UpdateFilteredCategories(skipFocusUpdate);
end

function HousingCatalogCategoriesMixin:UpdateFilteredCategories(skipFocusUpdate)
	local newFilteredCategories = CopyValuesAsKeys(C_HousingCatalog.SearchCatalogCategories(self.categorySearchParams));
	local newFilteredSubcategories = CopyValuesAsKeys(C_HousingCatalog.SearchCatalogSubcategories(self.categorySearchParams));
	
	local categoriesChanged = not self.filteredCategories or not TableUtil.ContainsAllKeys(self.filteredCategories, newFilteredCategories);
	local subcategoriesChanged = not self.filteredSubcategories or not TableUtil.ContainsAllKeys(self.filteredSubcategories, newFilteredSubcategories);

	if not categoriesChanged and not subcategoriesChanged then
		return;
	end

	self.filteredCategories = newFilteredCategories;
	self.filteredSubcategories = newFilteredSubcategories;

	if skipFocusUpdate then
		return;
	end

	if (self.focusedCategorID and not self.filteredCategories[self.focusedCategorID]) -- Focused category has been filtered away
	 or (self.focusedSubcategoryID and not self.filteredSubcategories[self.focusedSubcategoryID]) -- Focused subcategory has been filtered away
	 or (not self.focusedCategorID and categoriesChanged) then -- Viewing top level categories and filtered categories have changed
		local forceRebuild = true;
		self:SetFocus(self.focusedCategoryID, self.focusedSubcategoryID, forceRebuild);
	end
end

function HousingCatalogCategoriesMixin:GetCategorySearchParams()
	return self.categorySearchParams and CopyTable(self.categorySearchParams) or {};
end

function HousingCatalogCategoriesMixin:GetFocusedCategoryString()
	if not self.categories then
		return nil;
	end

	local categoryID = self.focusedCategoryID;
	local subcategoryID = self.focusedSubcategoryID;
	if not categoryID then
		categoryID = Constants.HousingCatalogConsts.HOUSING_CATALOG_ALL_CATEGORY_ID;
		subcategoryID = nil;
	end

	local category = self.categories[categoryID];
	local subcategoryInfo = (category and subcategoryID) and category.subcategoryInfos[subcategoryID] or nil;

	-- Focusing a specific subcategory within a category - return a formatted string containing both
	if category and subcategoryInfo then
		return string.format(HOUSING_CATALOG_CATEGORY_PATH_FMT, category.categoryInfo.name, subcategoryInfo.name);
	-- Just focusing a category - return its name
	elseif category then
		return category.categoryInfo.name;
	-- Nothing focused right now, nothing to return
	else
		return nil;
	end
end

function HousingCatalogCategoriesMixin:AddCategoryInfo(categoryID, categoryInfo)
	local subcategories = {};
	if categoryInfo.subcategoryIDs and #categoryInfo.subcategoryIDs > 0 then
		for _, subcategoryID in ipairs(categoryInfo.subcategoryIDs) do
			subcategories[subcategoryID] = C_HousingCatalog.GetCatalogSubcategoryInfo(subcategoryID);
		end
	end
	local category = {
		ID = categoryID,
		categoryInfo = categoryInfo,
		subcategoryInfos = subcategories,
	};

	self.categories[categoryID] = category;
end

function HousingCatalogCategoriesMixin:ClearFocus(forceRebuild)
	self:SetFocus(nil, nil, forceRebuild);
end

function HousingCatalogCategoriesMixin:SetFocus(focusedCategoryID, focusedSubcategoryID, forceRebuild, forceFocusChanged)
	-- Default to the "All" category if no category specified
	focusedCategoryID = focusedCategoryID or Constants.HousingCatalogConsts.HOUSING_CATALOG_ALL_CATEGORY_ID;

	local newFocusedCategoryID, newFocusedSubcategoryID = Constants.HousingCatalogConsts.HOUSING_CATALOG_ALL_CATEGORY_ID, nil;

	-- Check whether we can focus the specified category (if any)
	local focusedCategory = focusedCategoryID and self.categories[focusedCategoryID] or nil;
	if focusedCategory and self:DoesCategoryPassFilters(focusedCategoryID) then
		newFocusedCategoryID = focusedCategoryID;

		-- Check whether we can also focus the specified subcategory (if any)
		local focusedSubcategory = focusedSubcategoryID and focusedCategory.subcategoryInfos[focusedSubcategoryID];
		if focusedSubcategory and self:DoesSubcategoryPassFilters(focusedSubcategoryID) then
			newFocusedSubcategoryID = focusedSubcategoryID;
		end
	end

	local didCategoryChange = self.focusedCategoryID ~= newFocusedCategoryID;
	local didSubcategoryChange = self.focusedSubcategoryID ~= newFocusedSubcategoryID;
	local didAnyFocusChange = didCategoryChange or didSubcategoryChange;

	self.focusedCategoryID = newFocusedCategoryID;
	self.focusedSubcategoryID = newFocusedSubcategoryID;

	if didCategoryChange or forceRebuild then
		-- If the focused category changed or we're forced to, completely rebuild what categories are being displayed
		self:BuildDisplayedCategories();
	end

	self:UpdateDisplayedCategories();

	if didAnyFocusChange or forceFocusChanged then
		if self.onFocusChangedCallback then
			self.onFocusChangedCallback(self.focusedCategoryID, self.focusedSubcategoryID);
		end
	end
end

function HousingCatalogCategoriesMixin:SetManualFocusState(isManualFocus)
	local wasManualFocus = self.isManualFocus;
	self.isManualFocus = isManualFocus;

	if isManualFocus then
		self:BuildDisplayedCategories();
	elseif wasManualFocus then
		self.isManualFocus = false;

		local forceRebuild = true;
		local forceFocusChanged = true;
		self:SetFocus(self.focusedCategoryID, self.focusedSubcategoryID, forceRebuild, forceFocusChanged);
	end
end

function HousingCatalogCategoriesMixin:IsInManualFocusState()
	return self.isManualFocus;
end

function HousingCatalogCategoriesMixin:IsFeaturedCategoryFocused()
	return self.focusedCategoryID == Constants.HousingCatalogConsts.HOUSING_CATALOG_FEATURED_CATEGORY_ID;
end

function HousingCatalogCategoriesMixin:IsAllCategoryFocused()
	return self.focusedCategoryID == Constants.HousingCatalogConsts.HOUSING_CATALOG_ALL_CATEGORY_ID;
end

function HousingCatalogCategoriesMixin:SetCategoryNotification(categoryID, shown)
	local categoryFrame = self.categoryFramesByID[categoryID];
	if categoryFrame then
		categoryFrame:SetNotificationShown(shown);
	end
end

function HousingCatalogCategoriesMixin:BuildDisplayedCategories()
	if self:IsInManualFocusState() then
		self:ClearCategoryFrames();
		self.BackButton.layoutIndex = 1;
		self.BackButton:Show();
		self.SubcategoriesDivider.layoutIndex = 2;
		self.SubcategoriesDivider:Show();
		self:Layout();
	elseif self:DoesFocusedCategoryShowSubcategories() then
		local focusedCategory = self.categories[self.focusedCategoryID];
		self:DisplaySubcategoriesUnderCategory(focusedCategory);
	else
		self:DisplayTopLevelCategories();
	end
end

function HousingCatalogCategoriesMixin:UpdateDisplayedCategories()
	if self.AllSubcategoriesStandIn:IsShown() then
		self.AllSubcategoriesStandIn:SetActive(self.focusedSubcategoryID == nil);
	end

	for subcategoryID, subcategoryFrame in pairs(self.subcategoryFramesByID) do
		subcategoryFrame:SetActive(subcategoryID == self.focusedSubcategoryID);
	end

	for categoryID, categoryFrame in pairs(self.categoryFramesByID) do
		categoryFrame:UpdateState();
		categoryFrame:SetActive(categoryID == self.focusedCategoryID);
	end
end

function HousingCatalogCategoriesMixin:DoesFocusedCategoryShowSubcategories()
	if not self.focusedCategoryID then
		return false;
	end

	if self:IsFeaturedCategoryFocused() then
		return false;
	end

	local numSubcategories = 0;
	local focusedCategory = self.categories[self.focusedCategoryID];
	for _subcategoryID, _subcategoryInfo in pairs(focusedCategory.subcategoryInfos) do
		numSubcategories = numSubcategories + 1;
		if numSubcategories > 1 then
			return true;
		end
	end

	return false;
end

function HousingCatalogCategoriesMixin:ClearCategoryFrames()
	self.categoryFramesByID = {};
	self.subcategoryFramesByID = {};
	self.categoryPool:ReleaseAll();
	self.subcategoryPool:ReleaseAll();
end

function HousingCatalogCategoriesMixin:SetCategoriesBackground(atlas)
	self.backgroundCategories = atlas;
	self.Background:SetAtlas(self.backgroundCategories);
end

function HousingCatalogCategoriesMixin:DisplayTopLevelCategories()
	self:ClearCategoryFrames();

	self.Background:SetAtlas(self.backgroundCategories);
	self.AllSubcategoriesStandIn:Hide();
	self.SubcategoriesDivider:Hide();
	self.BackButton:Hide();

	-- First gather up which categories are currently showable
	local categoriesToShow = {};
	for categoryID, category in pairs(self.categories) do
		if self:DoesCategoryPassFilters(categoryID) then
			table.insert(categoriesToShow, category);
		end
	end

	-- Then sort them by their order index
	table.sort(categoriesToShow, function (c1, c2) return c1.categoryInfo.orderIndex < c2.categoryInfo.orderIndex; end );

	-- Finally instantiate frames for each of them
	local currLayoutIndex = 1;
	for _, category in ipairs(categoriesToShow) do
		local categoryFrame, isNew = self.categoryPool:Acquire();
		if isNew then
			-- If this is a newly created frame from the pool, set it to the correct size
			categoryFrame:SetSize(self.categoryButtonSize, self.categoryButtonSize);
		end
		local showAsExpanded = false;
		categoryFrame:Init(category.categoryInfo, showAsExpanded);
		categoryFrame.layoutIndex = currLayoutIndex;
		categoryFrame:Show();

		self.categoryFramesByID[category.categoryInfo.ID] = categoryFrame;

		currLayoutIndex = currLayoutIndex + 1;
	end

	self:Layout();
end

function HousingCatalogCategoriesMixin:DisplaySubcategoriesUnderCategory(category)
	self:ClearCategoryFrames();
	self.Background:SetAtlas(self.backgroundSubcategories);

	local currLayoutIndex = 1;

	-- Show the back button at the top
	self.BackButton.layoutIndex = currLayoutIndex;
	self.BackButton:Show();

	currLayoutIndex = currLayoutIndex + 1;
	
	-- Show divider between parent and subcategories
	self.SubcategoriesDivider.layoutIndex = currLayoutIndex;
	self.SubcategoriesDivider:Show();
	currLayoutIndex = currLayoutIndex + 1;

	-- Show the"All" subcategory placeholder
	self.AllSubcategoriesStandIn.layoutIndex = currLayoutIndex;
	self.AllSubcategoriesStandIn:Show();
	self.AllSubcategoriesStandIn:SetActive(self.focusedSubcategoryID == nil);

	currLayoutIndex = currLayoutIndex + 1;

	-- Gather up which subcategories are currently showable
	local subcategoriesToShow = {};
	for subcategoryID, subcategoryInfo in pairs(category.subcategoryInfos) do
		if self:DoesSubcategoryPassFilters(subcategoryID) then
			table.insert(subcategoriesToShow, subcategoryInfo);
		end
	end

	if #subcategoriesToShow <= 1 then
		-- If there's only one (or 0) showable subcategories under the category, only display the parent category and "All" placeholder
		self:Layout();
		return;
	end

	-- Finally sort and instantiate frames for the subcategories
	table.sort(subcategoriesToShow, function (s1, s2) return s1.orderIndex < s2.orderIndex; end );
	for _, subcategoryInfo in ipairs(subcategoriesToShow) do
		local subcategoryFrame, isNew = self.subcategoryPool:Acquire();
		if isNew then
			-- If this is a newly created frame from the pool, set it to the correct size
			subcategoryFrame:SetSize(self.subcategoryButtonSize, self.subcategoryButtonSize);
		end
		local showAsExpanded = false;
		subcategoryFrame:Init(subcategoryInfo, showAsExpanded);
		subcategoryFrame.layoutIndex = currLayoutIndex;
		subcategoryFrame:Show();
		self.subcategoryFramesByID[subcategoryInfo.ID] = subcategoryFrame;

		if subcategoryInfo.ID == self.focusedSubcategoryID then
			subcategoryFrame:SetActive(true);
		end

		currLayoutIndex = currLayoutIndex + 1;
	end

	self:Layout();
end

function HousingCatalogCategoriesMixin:OnCategoryUpdated(categoryID)
	local categoryInfo = C_HousingCatalog.GetCatalogCategoryInfo(categoryID);
	if categoryInfo then
		-- Found category info, add or update it in our cache
		self:AddCategoryInfo(categoryID, categoryInfo);
	elseif self.categories[categoryID] then
		-- Info not found, remove it from our cache
		self.categories[categoryID] = nil;
	end

	-- If we're showing all top level categories or focusing this one, re-evaluate focus and rebuild
	if not self.focusedCategoryID or categoryID == self.focusedCategoryID then
		local forceRebuild = true;
		self:SetFocus(self.focusedCategoryID, self.focusedSubcategoryID, forceRebuild);
	end
end

function HousingCatalogCategoriesMixin:DoesCategoryPassFilters(categoryID)
	return not self.filteredCategories or self.filteredCategories[categoryID];
end

function HousingCatalogCategoriesMixin:DoesSubcategoryPassFilters(subcategoryID)
	return not self.filteredSubcategories or self.filteredSubcategories[subcategoryID];
end

function HousingCatalogCategoriesMixin:OnSubcategoryUpdated(subcategoryID)
	local parentCategoryID, parentCategoryInfo = nil, nil;
	local subcategoryInfo = C_HousingCatalog.GetCatalogSubcategoryInfo(subcategoryID);
	-- If subcategory info exists
	if subcategoryInfo then
		parentCategoryID = subcategoryInfo.parentCategoryID;
		parentCategoryInfo = C_HousingCatalog.GetCatalogCategoryInfo(parentCategoryID);
		-- Parent category also exists, so add or update it
		if parentCategoryInfo then
			self:AddCategoryInfo(parentCategoryID, parentCategoryInfo);
		-- Parent category doesn't exist, so remove the whole thing
		elseif self.categories[parentCategoryID] then
			self.categories[parentCategoryID] = nil;
		end
	else
		-- Subcategory info doesn't exist so we don't know which category it was under
		-- Search our cached categories for it so it can be removed
		for categoryID, category in pairs(self.categories) do
			if category.subcategoryInfos[subcategoryID] then
				parentCategoryID = categoryID;
				parentCategoryInfo = category.categoryInfo;
				category.subcategoryInfos[subcategoryID] = nil;
				break;
			end
		end
	end

	if (self.focusedSubcategoryID == subcategoryID) -- Was focusing on this subcategory
	 or (parentCategoryID and parentCategoryID == self.focusedCategoryID) -- Was focusing on the parent category
	 or (parentCategoryID and not parentCategoryInfo and not self.focusedCategoryID) then -- Was viewing top-level categories and the parent category is missing
		local forceRebuild = true;
		self:SetFocus(self.focusedCategoryID, self.focusedSubcategoryID, forceRebuild);
	end
end

function HousingCatalogCategoriesMixin:OnCategoryClicked(categoryFrame)
	local forceRebuild = false;
	local soundToPlay = nil;
	-- Clicked "All subcategories" button -> clear focused subcategory
	if categoryFrame == self.AllSubcategoriesStandIn then
		self:SetFocus(self.focusedCategoryID, nil, forceRebuild);
		soundToPlay = SOUNDKIT.HOUSING_CATALOG_SUBCATEGORY_SELECT;
	-- Clicked back button -> return to top-level categories
	elseif categoryFrame == self.BackButton then
		if self:IsInManualFocusState() then
			self:SetManualFocusState(false);
		else
			self:ClearFocus(forceRebuild);
		end
		soundToPlay = SOUNDKIT.HOUSING_CATALOG_CATEGORY_DESELECT;
	-- Clicked subcategory -> focus subcategory
	elseif categoryFrame.isSubcategory then
		self:SetFocus(self.focusedCategoryID, categoryFrame.ID, forceRebuild);
		soundToPlay = SOUNDKIT.HOUSING_CATALOG_SUBCATEGORY_SELECT;
	-- Clicked category while viewing top-level categories -> focus category
	else
		self:SetFocus(categoryFrame.ID, nil, forceRebuild);
		soundToPlay = SOUNDKIT.HOUSING_CATALOG_CATEGORY_SELECT;
	end
	PlaySound(soundToPlay);
end

----------------- Back Button Mixin -----------------

HousingCategoryBackButtonMixin = {};

function HousingCategoryBackButtonMixin:OnClick()
	self:GetParent():OnCategoryClicked(self);
end


----------------- Base Category Mixin -----------------
-- TODO: Remove or update placeholder replacements
local QuestionMarkIconFileDataID = 134400;

local AtlasKeyModifiers = {
	Active = "_active",
	Inactive = "_inactive",
	Pressed = "_pressed",
	Parent = "_active-parent",
};

BaseHousingCatalogCategoryMixin = {};
-- Inherits BaseHousingActionButtonMixin

function BaseHousingCatalogCategoryMixin:OnLoad()
	if self.iconName then
		self:ProcessAtlasKey(self.iconName);
	end
	BaseHousingActionButtonMixin.OnLoad(self);
end

function BaseHousingCatalogCategoryMixin:Init()
	self:HideNotification();
end

function BaseHousingCatalogCategoryMixin:ProcessAtlasKey(iconName)
	self.atlasKey = nil;
	self.atlasNames = nil;
	if not iconName or iconName == "" then
		return;
	end

	local atlasKey = iconName;
	-- Because all category icons have a modifier in their name, the one provided via data most likely has one of the modifiers
	-- So we need to try and strip it out in order to get the base atlas name
	-- Ex: icon in data may be "category-icons_all_active", and we want to strip it down to "category-icons_all"
	for _, modifier in pairs(AtlasKeyModifiers) do
		local baseName = string.gsub(atlasKey, modifier, "");
		-- If subbing out the modifier changed the string, then we've successfully found and stripped the modifier it contained
		if baseName ~= atlasKey then
			atlasKey = baseName;
			break;
		end
	end
	self.atlasKey = atlasKey;

	self.atlasNames = {};
	for _, modifier in pairs(AtlasKeyModifiers) do
		local atlasName = self.atlasKey..modifier;
		local info = C_Texture.GetAtlasInfo(atlasName);
		if info and info.width and info.width ~= 0 then
			self.atlasNames[modifier] = atlasName;
		end
	end
end

function BaseHousingCatalogCategoryMixin:SetActive(isActive)
	if self.isActive ~= isActive then
		self.isActive = isActive;
		if self.SelectedBackground then
			self.SelectedBackground:SetShown(self.isActive);
			self.SelectedBackground.FlipbookSparkleAnim:SetPlaying(self.isActive);
		end
		self:UpdateState();
	end
end

function BaseHousingCatalogCategoryMixin:IsActive()
	return self.isActive;
end

function BaseHousingCatalogCategoryMixin:SetNotificationShown(shown)
	if shown then
		if not self.notificationFrame then
			self.notificationFrame = NotificationUtil.AcquireLargeNotification("TOPRIGHT", self, "TOPRIGHT", 1, 1);
		end
	else
		self:HideNotification();
	end
end

function BaseHousingCatalogCategoryMixin:HideNotification()
	if self.notificationFrame then
		NotificationUtil.ReleaseNotification(self.notificationFrame);
		self.notificationFrame = nil;
	end
end

function BaseHousingCatalogCategoryMixin:OnClick()
	self:GetParent():OnCategoryClicked(self);
end

function BaseHousingCatalogCategoryMixin:GetDefaultTexture()
	-- Overrides BaseHousingActionButtonMixin
	if not self.atlasKey or not self.atlasNames then
		return QuestionMarkIconFileDataID, false;
	end

	return self.atlasNames[AtlasKeyModifiers.Inactive], true;
end

function BaseHousingCatalogCategoryMixin:GetIconForState(state)
	-- Overrides BaseHousingActionButtonMixin
	if not self.atlasKey or not self.atlasNames then
		return QuestionMarkIconFileDataID, false;
	end
	local iconName = self.atlasNames[AtlasKeyModifiers.Inactive];
	local isAtlas = true;

	if state.isEnabled then
		if self.showingAsParent and self.atlasNames[AtlasKeyModifiers.Parent] then
			iconName = self.atlasNames[AtlasKeyModifiers.Parent];
		elseif state.isPressed and self.atlasNames[AtlasKeyModifiers.Pressed] then
			iconName = self.atlasNames[AtlasKeyModifiers.Pressed];
		elseif state.isActive and self.atlasNames[AtlasKeyModifiers.Active] then
			iconName = self.atlasNames[AtlasKeyModifiers.Active];
		end
	end

	return iconName, isAtlas;
end

function BaseHousingCatalogCategoryMixin:GetIconColorForState(state)
	-- Overrides BaseHousingActionButtonMixin
	return state.isEnabled and WHITE_FONT_COLOR or DARKGRAY_COLOR;
end

----------------- Instantiated Category Mixin -----------------

HousingCatalogCategoryMixin = {};
-- Inherits BaseHousingCatalogCategoryMixin

function HousingCatalogCategoryMixin:Init(displayInfo, showingAsParent)
	BaseHousingCatalogCategoryMixin.Init(self);

	self.isActive = false;
	self.ID = displayInfo.ID;
	self.enabledTooltip = displayInfo.name;

	self.showingAsParent = showingAsParent;

	self:ProcessAtlasKey(displayInfo.icon);

	self.ExpandedArrow:SetShown(showingAsParent and (not self.atlasNames or not self.atlasNames[AtlasKeyModifiers.Parent]));

	if self.SelectedBackground then
		self.SelectedBackground:Hide();
	end

	self:UpdateState();
end
