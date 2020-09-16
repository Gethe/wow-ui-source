
-- Converted from AuctionUI.lua for the 2019 AH revamp.

local EXPANDED_FILTERS = {};

function AuctionFrameFilters_Update(categoriesList, forceSelectionIntoView)
	AuctionFrameFilters_UpdateCategories(categoriesList, forceSelectionIntoView);
	-- Update scrollFrame
	local alwaysShowScrollBar = true;
	FauxScrollFrame_Update(categoriesList.ScrollFrame, #EXPANDED_FILTERS, NUM_FILTERS_TO_DISPLAY, BROWSE_FILTER_HEIGHT, nil, nil, nil, nil, nil, nil, alwaysShowScrollBar);
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
	
	-- Display the list of open filters
	local offset = FauxScrollFrame_GetOffset(categoriesList.ScrollFrame);
	if ( forceSelectionIntoView and selectedCategoryIndex and ( not selectedSubCategoryIndex and not selectedSubSubCategoryIndex ) ) then
		if ( selectedCategoryIndex <= offset ) then
			FauxScrollFrame_OnVerticalScroll(categoriesList.ScrollFrame, math.max(0.0, (selectedCategoryIndex - 1) * BROWSE_FILTER_HEIGHT), BROWSE_FILTER_HEIGHT);
			offset = FauxScrollFrame_GetOffset(categoriesList.ScrollFrame);
		end
	end
	
	local dataIndex = offset;

	for i = 1, NUM_FILTERS_TO_DISPLAY do
		local button = categoriesList.FilterButtons[i];

		dataIndex = dataIndex + 1;

		if ( dataIndex <= #EXPANDED_FILTERS ) then
			local info = EXPANDED_FILTERS[dataIndex];

			if ( info ) then
				FilterButton_SetUp(button, info);
				
				if ( info.type == "category" ) then
					button.categoryIndex = info.categoryIndex;
				elseif ( info.type == "subCategory" ) then
					button.subCategoryIndex = info.subCategoryIndex;
				elseif ( info.type == "subSubCategory" ) then
					button.subSubCategoryIndex = info.subSubCategoryIndex;
				end
				
				button.SelectedTexture:SetShown(info.selected);
				button:Show();
			end
		else
			button:Hide();
		end
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

function FilterButton_SetUp(button, info)
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
		button.SelectedTexture:SetPoint("CENTER");
		button.HighlightTexture:SetAtlas("auctionhouse-nav-button-highlight", false);
		button.HighlightTexture:SetSize(132,21);
		button.HighlightTexture:ClearAllPoints();
		button.HighlightTexture:SetPoint("CENTER");
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

function AuctionFrameFilter_OnClick(self, button)
	local categoriesList = self:GetParent();
	local selectedCategoryIndex, selectedSubCategoryIndex, selectedSubSubCategoryIndex = categoriesList:GetSelectedCategory();
	if ( self.type == "category" ) then
		local wasToken = AuctionFrame_DoesCategoryHaveFlag("WOW_TOKEN_FLAG", selectedCategoryIndex);
		if ( selectedCategoryIndex == self.categoryIndex ) then
			selectedCategoryIndex = nil;
		else
			selectedCategoryIndex = self.categoryIndex;
		end
		selectedSubCategoryIndex = nil;
		selectedSubSubCategoryIndex = nil;
	elseif ( self.type == "subCategory" ) then
		if ( selectedSubCategoryIndex == self.subCategoryIndex ) then
			selectedSubCategoryIndex = nil;
			selectedSubSubCategoryIndex = nil;
		else
			selectedSubCategoryIndex = self.subCategoryIndex;
			selectedSubSubCategoryIndex = nil;
		end
	elseif ( self.type == "subSubCategory" ) then
		if ( selectedSubSubCategoryIndex == self.subSubCategoryIndex ) then
			selectedSubSubCategoryIndex = nil;
		else
			selectedSubSubCategoryIndex = self.subSubCategoryIndex;
		end
	end

	categoriesList:SetSelectedCategory(selectedCategoryIndex, selectedSubCategoryIndex, selectedSubSubCategoryIndex);
	AuctionFrameFilters_Update(categoriesList, true);
end


AuctionHouseCategoriesListMixin = CreateFromMixins(AuctionHouseSystemMixin);

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