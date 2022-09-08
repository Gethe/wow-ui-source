
-- Converted from AuctionUI.lua for the 2019 AH revamp.

local EXPANDED_FILTERS = {};

function AuctionFrameFilters_Update(categoriesList, forceSelectionIntoView)
	AuctionFrameFilters_UpdateCategories(categoriesList, forceSelectionIntoView);
end

function AuctionFrameFilters_UpdateCategories(categoriesList, forceSelectionIntoView)
	local selectedCategoryIndex, selectedSubCategoryIndex = categoriesList:GetSelectedCategory();
	-- Initialize the list of open filters
	EXPANDED_FILTERS = {};
	
	for categoryIndex, categoryInfo in ipairs(AuctionCategories) do
		local selected = selectedCategoryIndex and selectedCategoryIndex == categoryIndex;
		local isToken = categoryInfo:HasFlag("WOW_TOKEN_FLAG");

		tinsert(EXPANDED_FILTERS, { name = categoryInfo.name, type = "category", categoryIndex = categoryIndex, selected = selected, isToken = isToken, });

		if ( selected ) then
			AuctionFrameFilters_AddSubCategories(categoriesList, categoryInfo.subCategories);
		end
	end

	local dataProvider = CreateDataProvider(EXPANDED_FILTERS);
	categoriesList.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

	if forceSelectionIntoView and selectedCategoryIndex and (not selectedSubCategoryIndex and not selectedSubSubCategoryIndex) then
		categoriesList.ScrollBox:ScrollToElementDataIndex(selectedCategoryIndex, ScrollBoxConstants.AlignBegin, ScrollBoxConstants.NoScrollInterpolation);
	end
end

function AuctionFrameFilters_AddSubCategories(categoriesList, subCategories)
	if subCategories then
		for subCategoryIndex, subCategoryInfo in ipairs(subCategories) do
			local selected = select(2, categoriesList:GetSelectedCategory()) == subCategoryIndex;

			tinsert(EXPANDED_FILTERS, { name = subCategoryInfo.name, type = "subCategory", subCategoryIndex = subCategoryIndex, selected = selected });
		 
			if ( selected ) then
				AuctionFrameFilters_AddSubSubCategories(categoriesList, subCategoryInfo.subCategories);
			end
		end
	end
end

function AuctionFrameFilters_AddSubSubCategories(categoriesList, subSubCategories)
	if subSubCategories then
		for subSubCategoryIndex, subSubCategoryInfo in ipairs(subSubCategories) do
			local selected = select(3, categoriesList:GetSelectedCategory()) == subSubCategoryIndex;
			local isLast = subSubCategoryIndex == #subSubCategories;

			tinsert(EXPANDED_FILTERS, { name = subSubCategoryInfo.name, type = "subSubCategory", subSubCategoryIndex = subSubCategoryIndex, selected = selected, isLast = isLast});
		end
	end
end

function AuctionHouseFilterButton_SetUp(button, info)
	local normalText = button.Text;
	local normalTexture = button.NormalTexture;
	local line = button.Lines;

	if ( info.type == "category" ) then
		if (info.isToken) then
			button:SetNormalFontObject(GameFontNormalSmallBattleNetBlueLeft);
		else
			button:SetNormalFontObject(GameFontNormalSmall);
		end

		button.NormalTexture:SetAtlas("auctionhouse-nav-button", false);
		button.NormalTexture:SetSize(136,32);
		button.NormalTexture:ClearAllPoints();
		button.NormalTexture:SetPoint("TOPLEFT", -2, 0);
		button.SelectedTexture:SetAtlas("auctionhouse-nav-button-select", false);
		button.SelectedTexture:SetSize(132,21);
		button.SelectedTexture:ClearAllPoints();
		button.SelectedTexture:SetPoint("LEFT");
		button.HighlightTexture:SetAtlas("auctionhouse-nav-button-highlight", false);
		button.HighlightTexture:SetSize(132,21);
		button.HighlightTexture:ClearAllPoints();
		button.HighlightTexture:SetPoint("LEFT");
		button.HighlightTexture:SetBlendMode("BLEND");
		button:SetText(info.name);
		normalText:SetPoint("LEFT", button, "LEFT", 8, 0);
		normalTexture:SetAlpha(1.0);	
		line:Hide();
	elseif ( info.type == "subCategory" ) then
		button:SetNormalFontObject(GameFontHighlightSmall);
		button.NormalTexture:SetAtlas("auctionhouse-nav-button-secondary", false);
		button.NormalTexture:SetSize(133,32);
		button.NormalTexture:ClearAllPoints();
		button.NormalTexture:SetPoint("TOPLEFT", 1, 0);
		button.SelectedTexture:SetAtlas("auctionhouse-nav-button-secondary-select", false);
		button.SelectedTexture:SetSize(122,21);
		button.SelectedTexture:ClearAllPoints();
		button.SelectedTexture:SetPoint("TOPLEFT", 10, 0);
		button.HighlightTexture:SetAtlas("auctionhouse-nav-button-secondary-highlight", false);
		button.HighlightTexture:SetSize(122,21);
		button.HighlightTexture:ClearAllPoints();
		button.HighlightTexture:SetPoint("TOPLEFT", 10, 0);
		button.HighlightTexture:SetBlendMode("BLEND");
		button:SetText(info.name);
		normalText:SetPoint("LEFT", button, "LEFT", 18, 0);
		normalTexture:SetAlpha(1.0);
		line:Hide();
	elseif ( info.type == "subSubCategory" ) then
		button:SetNormalFontObject(GameFontHighlightSmall);
		button.NormalTexture:ClearAllPoints();
		button.NormalTexture:SetPoint("TOPLEFT", 10, 0);
		button.SelectedTexture:SetAtlas("auctionhouse-ui-row-select", false);
		button.SelectedTexture:SetSize(116,18);
		button.SelectedTexture:ClearAllPoints();
		button.SelectedTexture:SetPoint("TOPRIGHT",0,-2);		
		button.HighlightTexture:SetAtlas("auctionhouse-ui-row-highlight", false);
		button.HighlightTexture:SetSize(116,18);
		button.HighlightTexture:ClearAllPoints();
		button.HighlightTexture:SetPoint("TOPRIGHT",0,-2);
		button.HighlightTexture:SetBlendMode("ADD");
		button:SetText(info.name);
		normalText:SetPoint("LEFT", button, "LEFT", 26, 0);
		normalTexture:SetAlpha(0.0);	
		line:Show();
	end
	button.type = info.type; 

	if ( info.type == "category" ) then
		button.categoryIndex = info.categoryIndex;
	elseif ( info.type == "subCategory" ) then
		button.subCategoryIndex = info.subCategoryIndex;
	elseif ( info.type == "subSubCategory" ) then
		button.subSubCategoryIndex = info.subSubCategoryIndex;
	end
	
	button.SelectedTexture:SetShown(info.selected);
end

function AuctionFrameFilter_OnLoad(self)
	self:SetPushedTextOffset(0, 0);
end

function AuctionFrameFilter_OnEnter(self)
	TruncatedTooltipScript_OnEnter(self);

	self.HighlightTexture:Show();
end

function AuctionFrameFilter_OnLeave(self)
	TruncatedTooltipScript_OnLeave(self);

	self.HighlightTexture:Hide();
end

function AuctionFrameFilter_OnMouseDown(self)
	self.Text:AdjustPointsOffset(1, -1);
end

function AuctionFrameFilter_OnMouseUp(self)
	self.Text:AdjustPointsOffset(-1, 1);
end

AuctionHouseCategoriesListMixin = CreateFromMixins(AuctionHouseSystemMixin);

function AuctionHouseCategoriesListMixin:OnLoad()
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("AuctionCategoryButtonTemplate", function(button, elementData)
		AuctionHouseFilterButton_SetUp(button, elementData);
		button:SetScript("OnClick", function(button, buttonName)
			self:OnFilterClicked(button, buttonName);
		end);
	end);
	local leftPad = 3;
	local spacing = 0;
	view:SetPadding(0,0,leftPad,0,spacing);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function AuctionHouseCategoriesListMixin:OnFilterClicked(button, buttonName)
	local selectedCategoryIndex, selectedSubCategoryIndex, selectedSubSubCategoryIndex = self:GetSelectedCategory();
	if ( button.type == "category" ) then
		local wasToken = AuctionFrame_DoesCategoryHaveFlag("WOW_TOKEN_FLAG", selectedCategoryIndex);
		if ( selectedCategoryIndex == button.categoryIndex ) then
			selectedCategoryIndex = nil;
		else
			selectedCategoryIndex = button.categoryIndex;
		end
		selectedSubCategoryIndex = nil;
		selectedSubSubCategoryIndex = nil;
	elseif ( button.type == "subCategory" ) then
		if ( selectedSubCategoryIndex == button.subCategoryIndex ) then
			selectedSubCategoryIndex = nil;
			selectedSubSubCategoryIndex = nil;
		else
			selectedSubCategoryIndex = button.subCategoryIndex;
			selectedSubSubCategoryIndex = nil;
		end
	elseif ( button.type == "subSubCategory" ) then
		if ( selectedSubSubCategoryIndex == button.subSubCategoryIndex ) then
			selectedSubSubCategoryIndex = nil;
		else
			selectedSubSubCategoryIndex = button.subSubCategoryIndex;
		end
	end

	self:SetSelectedCategory(selectedCategoryIndex, selectedSubCategoryIndex, selectedSubSubCategoryIndex);
	AuctionFrameFilters_Update(self, true);
end

function AuctionHouseCategoriesListMixin:OnShow()
	AuctionFrameFilters_Update(self);
end

function AuctionHouseCategoriesListMixin:IsWoWTokenCategorySelected()
	local categoryInfo = AuctionHouseCategory_FindDeepest(self.selectedCategoryIndex, self.selectedSubCategoryIndex, self.selectedSubSubCategoryIndex);
	return categoryInfo and categoryInfo:HasFlag("WOW_TOKEN_FLAG");
end

function AuctionHouseCategoriesListMixin:SetSelectedCategory(selectedCategoryIndex, selectedSubCategoryIndex, selectedSubSubCategoryIndex)
	self.selectedCategoryIndex = selectedCategoryIndex;
	self.selectedSubCategoryIndex = selectedSubCategoryIndex;
	self.selectedSubSubCategoryIndex = selectedSubSubCategoryIndex;

	self:GetAuctionHouseFrame():TriggerEvent(AuctionHouseFrameMixin.Event.CategorySelected, selectedCategoryIndex, selectedSubCategoryIndex, selectedSubSubCategoryIndex);
	
	local displayMode = self:GetAuctionHouseFrame():GetDisplayMode();
	if self:IsWoWTokenCategorySelected() and displayMode ~= AuctionHouseFrameDisplayMode.WoWTokenBuy then
		self:GetAuctionHouseFrame():SetDisplayMode(AuctionHouseFrameDisplayMode.WoWTokenBuy);
	elseif displayMode ~= AuctionHouseFrameDisplayMode.Buy and displayMode ~= AuctionHouseFrameDisplayMode.ItemBuy and displayMode ~= AuctionHouseFrameDisplayMode.CommoditiesBuy then
		self:GetAuctionHouseFrame():SetDisplayMode(AuctionHouseFrameDisplayMode.Buy);
	end

	AuctionFrameFilters_Update(self);
end

function AuctionHouseCategoriesListMixin:GetSelectedCategory()
	return self.selectedCategoryIndex, self.selectedSubCategoryIndex, self.selectedSubSubCategoryIndex;
end

function AuctionHouseCategoriesListMixin:GetCategoryData()
	local selectedCategoryIndex, selectedSubCategoryIndex, selectedSubSubCategoryIndex = self:GetSelectedCategory();
	if selectedCategoryIndex and selectedSubCategoryIndex and selectedSubSubCategoryIndex then
		return AuctionCategories[selectedCategoryIndex].subCategories[selectedSubCategoryIndex].subCategories[selectedSubSubCategoryIndex];
	elseif selectedCategoryIndex and selectedSubCategoryIndex then
		return AuctionCategories[selectedCategoryIndex].subCategories[selectedSubCategoryIndex];
	elseif selectedCategoryIndex then
		return AuctionCategories[selectedCategoryIndex];
	end
end

function AuctionHouseCategoriesListMixin:GetCategoryFilterData()
	local categoryData = self:GetCategoryData();
	if categoryData == nil then
		return nil, nil;
	end

	return categoryData.filters, categoryData.implicitFilter;
end