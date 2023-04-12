
local ignoreSkillLine = true;
local OrderBrowseType = EnumUtil.MakeEnum("Flat", "Bucketed", "None");
local orderTypeTabTitles =
{
	[Enum.CraftingOrderType.Public] = PROFESSIONS_CRAFTER_ORDER_TAB_PUBLIC,
	[Enum.CraftingOrderType.Guild] = PROFESSIONS_CRAFTER_ORDER_TAB_GUILD,
	[Enum.CraftingOrderType.Personal] = PROFESSIONS_CRAFTER_ORDER_TAB_PERSONAL,
};

local function SetTabTitleWithCount(tabButton, type, count)
	if tabButton then
		local title = orderTypeTabTitles[type];
		if type == Enum.CraftingOrderType.Public then
			tabButton.Text:SetText(title);
		else
			tabButton.Text:SetText(string.format("%s (%s)", title, count));
		end
	end
end

ProfessionsCrafterOrderListElementMixin = CreateFromMixins(TableBuilderRowMixin);

function ProfessionsCrafterOrderListElementMixin:OnLineEnter()
	self.HighlightTexture:Show();

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	local reagents = {};
	local qualityIDs = C_TradeSkillUI.GetQualitiesForRecipe(self.option.spellID);
	local qualityIdx = self.option.minQuality or 1;
	GameTooltip:SetRecipeResultItem(self.option.spellID, reagents, nil, nil, qualityIDs and qualityIDs[qualityIdx]);

	if IsModifiedClick("DRESSUP") then
		ShowInspectCursor();
	end

	self:SetScript("OnUpdate", self.OnUpdate);
end

function ProfessionsCrafterOrderListElementMixin:OnLineLeave()
	self.HighlightTexture:Hide();

	GameTooltip:Hide();
	ResetCursor();
	self:SetScript("OnUpdate", nil);
end

-- Set and cleared dynamically in OnEnter and OnLeave
function ProfessionsCrafterOrderListElementMixin:OnUpdate()
	if IsModifiedClick("DRESSUP") then
		ShowInspectCursor();
	else
		ResetCursor();
	end
end

function ProfessionsCrafterOrderListElementMixin:OnClick(button)
	if button == "LeftButton" then
		if self.browseType == OrderBrowseType.Bucketed then
			self.pageFrame:SelectRecipeFromBucket(self.option);
		elseif self.browseType == OrderBrowseType.Flat then
			self.pageFrame:ViewOrder(self.option);
		end
	elseif button == "RightButton" then
		local dropdownInfo =
		{
			recipeID = self.option.spellID,
			orderID = self.option.orderID,
		};
		ToggleDropDownMenu(1, dropdownInfo, self.contextMenu, "cursor");
	end
end

function ProfessionsCrafterOrderListElementMixin:Init(elementData)
	self.option = elementData.option;
	self.browseType = elementData.browseType;
	self.pageFrame = elementData.pageFrame;
	self.contextMenu = elementData.contextMenu;
end


ProfessionsCraftingOrderPageMixin = {};

function ProfessionsCraftingOrderPageMixin:InitButtons()
	self.BrowseFrame.FavoritesSearchButton.Icon:SetAtlas("auctionhouse-icon-favorite");
	self.BrowseFrame.FavoritesSearchButton:SetScript("OnClick", function()
		local selectedRecipe = nil;
		local searchFavorites = true;
		local initialNonPublicSearch = false;
		self:RequestOrders(selectedRecipe, searchFavorites, initialNonPublicSearch);
	end);

	self.BrowseFrame.SearchButton:SetScript("OnClick", function()
		local selectedRecipe = nil;
		local searchFavorites = false;
		local initialNonPublicSearch = false;
		self:RequestOrders(selectedRecipe, searchFavorites, initialNonPublicSearch);
	end);

	self.BrowseFrame.BackButton:SetScript("OnClick", function()
		if self.lastBucketRequest then
			self:ResetSortOrder();
			self:SendOrderRequest(self.lastBucketRequest);
		end
	end);

	self.BrowseFrame.OrdersRemainingDisplay:SetScript("OnEnter", function(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
		local claimInfo = C_CraftingOrders.GetOrderClaimInfo(self.professionInfo.profession);
		local tooltipText;
		if claimInfo.hoursToRecharge then
			tooltipText = CRAFTING_ORDERS_CLAIMS_REMAINING_REFRESH_TOOLTIP:format(claimInfo.claimsRemaining, claimInfo.hoursToRecharge);
		else
			tooltipText = CRAFTING_ORDERS_CLAIMS_REMAINING_TOOLTIP:format(claimInfo.claimsRemaining);
		end
		GameTooltip_AddNormalLine(GameTooltip, tooltipText);
		GameTooltip:Show();
	end);
	self.BrowseFrame.OrdersRemainingDisplay:SetScript("OnLeave", GameTooltip_Hide);
end

function ProfessionsCraftingOrderPageMixin:InitOrderTypeTabs()
	local isInGuild = IsInGuild();
	self.BrowseFrame.GuildOrdersButton:SetShown(isInGuild);
	self.BrowseFrame.PersonalOrdersButton:ClearAllPoints();
	self.BrowseFrame.PersonalOrdersButton:SetPoint("LEFT", isInGuild and self.BrowseFrame.GuildOrdersButton or self.BrowseFrame.PublicOrdersButton, "RIGHT", 0, 0);

	for _, typeTab in ipairs(self.BrowseFrame.orderTypeTabs) do
		typeTab:SetScript("OnClick", function()
			PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
			self:SetCraftingOrderType(typeTab.orderType);

			self:ClearCachedRequests();
			self:StartDefaultSearch();
		end);

		typeTab:HandleRotation();
		local count = 0;
		SetTabTitleWithCount(typeTab, typeTab.orderType, count);
		local minWidth = 200;
		local bufferWidth = 100;
		local stretchWidth = typeTab.Text:GetWidth() + bufferWidth;
		typeTab:SetTabWidth(math.max(minWidth, stretchWidth));
	end
end

function ProfessionsCraftingOrderPageMixin:InitRecipeList()
	self.BrowseFrame.RecipeList.SearchBox:SetScript("OnTextChanged", function(editBox)
		SearchBoxTemplate_OnTextChanged(editBox);
		Professions.OnRecipeListSearchTextChanged(editBox:GetText());
	end);
	local function StartSearch()
		local selectedRecipe = nil;
		local searchFavorites = false;
		local initialNonPublicSearch = false;
		self:RequestOrders(selectedRecipe, searchFavorites, initialNonPublicSearch);
	end
	self.BrowseFrame.RecipeList.SearchBox:SetScript("OnEnterPressed", function() self.BrowseFrame.RecipeList.SearchBox:ClearFocus(); end);
	self.BrowseFrame.RecipeList.SearchBox:SetScript("OnEditFocusLost", StartSearch);

	self.BrowseFrame.RecipeList.FilterButton:SetResetFunction(function() Professions.SetDefaultFilters(ignoreSkillLine); StartSearch(); end);
	self.BrowseFrame.RecipeList.FilterButton:SetScript("OnMouseDown", function(button, buttonName, down)
		UIMenuButtonStretchMixin.OnMouseDown(self.BrowseFrame.RecipeList.FilterButton, buttonName);
		ToggleDropDownMenu(1, nil, self.BrowseFrame.RecipeList.FilterDropDown, self.BrowseFrame.RecipeList.FilterButton, 74, 15);
		PlaySound(SOUNDKIT.UI_PROFESSION_FILTER_MENU_OPEN_CLOSE);
	end);

	local function OnDataRangeChanged(sortPending, indexBegin, indexEnd)
		if (not self.expectMoreRows) or (self.requestCallback ~= nil) or (not self.numOrders) then
			return;
		end

		local ordersFromBottom = self.numOrders - indexEnd;
		local requestMoreOrdersThreshold = 30;
		if ordersFromBottom < requestMoreOrdersThreshold then
			self:RequestMoreOrders();
		end
	end
	self.BrowseFrame.OrderList.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnDataRangeChanged, OnDataRangeChanged, self);

	UIDropDownMenu_SetInitializeFunction(self.BrowseFrame.RecipeList.FilterDropDown, GenerateClosure(self.InitFilterMenu, self));
end

function ProfessionsCraftingOrderPageMixin:InitFilterMenu(dropdown, level)
	local function OnFiltersChanged()
		self:UpdateFilterResetVisibility();
		local selectedRecipe = nil;
		local searchFavorites = false;
		local initialNonPublicSearch = false;
		self:RequestOrders(selectedRecipe, searchFavorites, initialNonPublicSearch);
	end
	Professions.InitFilterMenu(dropdown, level, OnFiltersChanged, ignoreSkillLine);
end

function ProfessionsCraftingOrderPageMixin:UpdateFilterResetVisibility()
	self.BrowseFrame.RecipeList.FilterButton.ResetButton:SetShown(not Professions.IsUsingDefaultFilters(ignoreSkillLine));
end

function ProfessionsCraftingOrderPageMixin:SetBrowseType(browseType)
	if browseType ~= self.browseType then
		self.browseType = browseType;
		self:ResetSortOrder();
		self:SetupTable();
	end
end

function ProfessionsCraftingOrderPageMixin:GetBrowseType()
	return self.browseType;
end

function ProfessionsCraftingOrderPageMixin:SortOrderIsValid(sortOrder)
	local browseType = self:GetBrowseType();

	if browseType == OrderBrowseType.Flat then
		return sortOrder == ProfessionsSortOrder.Tip or sortOrder == ProfessionsSortOrder.Reagents or sortOrder == ProfessionsSortOrder.Expiration or sortOrder == ProfessionsSortOrder.ItemName;
	elseif browseType == OrderBrowseType.Bucketed then
		return sortOrder == ProfessionsSortOrder.AverageTip or sortOrder == ProfessionsSortOrder.MaxTip or sortOrder == ProfessionsSortOrder.NumAvailable or sortOrder == ProfessionsSortOrder.ItemName;
	end

	return browseType == ProfessionsSortOrder.ItemName;
end

function ProfessionsCraftingOrderPageMixin:ResetSortOrder()
	self.primarySort =
	{
		order = ProfessionsSortOrder.ItemName;
		ascending = true;
	};

	self.secondarySort = nil;

	if self.tableBuilder then
		for frame in self.tableBuilder:EnumerateHeaders() do
			frame:UpdateArrow();
		end
	end
end

function ProfessionsCraftingOrderPageMixin:SetSortOrder(sortOrder)
	if self.primarySort.order == sortOrder then
		self.primarySort.ascending = not self.primarySort.ascending;
	else
		self.secondarySort = CopyTable(self.primarySort);
		self.primarySort =
		{
			order = sortOrder;
			ascending = true;
		};
	end

	if self.tableBuilder then
		for frame in self.tableBuilder:EnumerateHeaders() do
			frame:UpdateArrow();
		end
	end

	if self.lastRequest then
		self.lastRequest.offset = 0; -- Get a fresh page of sorted results
		self:SendOrderRequest(self.lastRequest);
	end
end

function ProfessionsCraftingOrderPageMixin:GetSortOrder()
	return self.primarySort.order, self.primarySort.ascending;
end

function ProfessionsCraftingOrderPageMixin:SetupTable()
	local browseType = self:GetBrowseType();

	if not self.tableBuilder then
		self.tableBuilder = CreateTableBuilder(nil, ProfessionsTableBuilderMixin);
		local function ElementDataTranslator(elementData)
			return elementData;
		end;
		ScrollUtil.RegisterTableBuilder(self.BrowseFrame.OrderList.ScrollBox, self.tableBuilder, ElementDataTranslator);
	
		local function ElementDataProvider(elementData)
			return elementData;
		end;
		self.tableBuilder:SetDataProvider(ElementDataProvider);
	end

	self.tableBuilder:Reset();
	self.tableBuilder:SetColumnHeaderOverlap(2);
	self.tableBuilder:SetHeaderContainer(self.BrowseFrame.OrderList.HeaderContainer);
	self.tableBuilder:SetTableMargins(-3, 5);
	self.tableBuilder:SetTableWidth(777);

	local PTC = ProfessionsTableConstants;
	self.tableBuilder:AddFillColumn(self, PTC.NoPadding, 1.0,
		8, PTC.ItemName.RightCellPadding, ProfessionsSortOrder.ItemName, "ProfessionsCrafterTableCellItemNameTemplate");

	if browseType == OrderBrowseType.Flat then
		self.tableBuilder:AddUnsortableFixedWidthColumn(self, PTC.NoPadding, PTC.CustomerName.Width, PTC.CustomerName.LeftCellPadding,
										  	  PTC.CustomerName.RightCellPadding, CRAFTING_ORDERS_BROWSE_HEADER_CUSTOMER_NAME, "ProfessionsCrafterTableCellCustomerNameTemplate");
		self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.Tip.Width, PTC.Tip.LeftCellPadding,
										  	  PTC.Tip.RightCellPadding, ProfessionsSortOrder.Tip, "ProfessionsCrafterTableCellActualCommissionTemplate");
		self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.Reagents.Width, PTC.Reagents.LeftCellPadding,
										  		  PTC.Reagents.RightCellPadding, ProfessionsSortOrder.Reagents, "ProfessionsCrafterTableCellReagentsTemplate");
		self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.Expiration.Width, PTC.Expiration.LeftCellPadding,
										  	  PTC.Expiration.RightCellPadding, ProfessionsSortOrder.Expiration, "ProfessionsCrafterTableCellExpirationTemplate");
	elseif browseType == OrderBrowseType.Bucketed then
		self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.Tip.Width, PTC.Tip.LeftCellPadding,
										  	  PTC.Tip.RightCellPadding, ProfessionsSortOrder.MaxTip, "ProfessionsCrafterTableCellMaxCommissionTemplate");
		self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.Tip.Width, PTC.Tip.LeftCellPadding,
										  	  PTC.Tip.RightCellPadding, ProfessionsSortOrder.AverageTip, "ProfessionsCrafterTableCellAvgCommissionTemplate");
		self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.NumAvailable.Width, PTC.NumAvailable.LeftCellPadding,
										  	  PTC.NumAvailable.RightCellPadding, ProfessionsSortOrder.NumAvailable, "ProfessionsCrafterTableCellNumAvailableTemplate");
	end

	self.tableBuilder:Arrange();
end

function ProfessionsCraftingOrderPageMixin:InitContextMenu(dropDown, level)
	local dropdownInfo = UIDROPDOWNMENU_MENU_VALUE;
	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;
	
	local currentlyFavorite = C_TradeSkillUI.IsRecipeFavorite(dropdownInfo.recipeID);
	info.text = currentlyFavorite and BATTLE_PET_UNFAVORITE or BATTLE_PET_FAVORITE;
	info.func = GenerateClosure(C_TradeSkillUI.SetRecipeFavorite, dropdownInfo.recipeID, not currentlyFavorite);
	UIDropDownMenu_AddButton(info, level);

	if self.orderType == Enum.CraftingOrderType.Personal then
		info.text = PROFESSIONS_DECLINE_ORDER;
		local emptyRejectionNote = "";
		info.func = GenerateClosure(C_CraftingOrders.RejectOrder, dropdownInfo.orderID, emptyRejectionNote, self.professionInfo.profession);
		UIDropDownMenu_AddButton(info, level);
	end
end

function ProfessionsCraftingOrderPageMixin:InitOrderList()
	local pad = 5;
	local spacing = 1;
	local view = CreateScrollBoxListLinearView(pad, pad, pad, pad, spacing);
	view:SetElementInitializer("ProfessionsCrafterOrderListElementTemplate", function(button, elementData)
		button:Init(elementData);
	end);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.BrowseFrame.OrderList.ScrollBox, self.BrowseFrame.OrderList.ScrollBar, view);

	UIDropDownMenu_SetInitializeFunction(self.BrowseFrame.OrderList.ContextMenu, GenerateClosure(self.InitContextMenu, self));
	UIDropDownMenu_SetDisplayMode(self.BrowseFrame.OrderList.ContextMenu, "MENU");
end

local ProfessionsCraftingOrderPageAlwaysListenEvents =
{
	"PLAYER_GUILD_UPDATE",
	"PLAYER_ENTERING_WORLD",
	"CRAFTINGORDERS_UPDATE_ORDER_COUNT",
};
local ProfessionsCraftingOrderPageEvents =
{
	"TRADE_SKILL_FAVORITES_CHANGED",
	"CURRENCY_DISPLAY_UPDATE",
	"CRAFTINGORDERS_CAN_REQUEST",
	"TRADE_SKILL_LIST_UPDATE",
	"CRAFTINGORDERS_REJECT_ORDER_RESPONSE",
};
function ProfessionsCraftingOrderPageMixin:OnEvent(event, ...)
	if event == "TRADE_SKILL_FAVORITES_CHANGED" then
		-- Trade skill backend refreshes on the next frame
		RunNextFrame(function() self:UpdateFavoritesButton(); end);
	elseif event == "CURRENCY_DISPLAY_UPDATE" then
		self:UpdateOrdersRemaining();
	elseif event == "PLAYER_GUILD_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
		self:InitOrderTypeTabs();
		if self.orderType == Enum.CraftingOrderType.Guild and not IsInGuild() then
			self:SetCraftingOrderType(Enum.CraftingOrderType.Public);
		end
	elseif event == "TRADE_SKILL_LIST_UPDATE" then
		local professionInfo = C_TradeSkillUI.GetChildProfessionInfo();
		self:Refresh(professionInfo);
	elseif event == "CRAFTINGORDERS_UPDATE_ORDER_COUNT" then
		local type, count = ...;
		local tabButton;
		if type == Enum.CraftingOrderType.Guild then
			tabButton = self.BrowseFrame.GuildOrdersButton;
		elseif type == Enum.CraftingOrderType.Personal then
			tabButton = self.BrowseFrame.PersonalOrdersButton;
		end

		SetTabTitleWithCount(tabButton, type, count);
	elseif event == "CRAFTINGORDERS_REJECT_ORDER_RESPONSE" then
		local result, orderID = ...;
		local success = (result == Enum.CraftingOrderResult.Ok);
        if success then
			if self.lastRequest then
				self.lastRequest.offset = 0; -- Get a fresh page of sorted results
				self:SendOrderRequest(self.lastRequest);
			end
		else
			UIErrorsFrame:AddExternalErrorMessage(PROFESSIONS_ORDER_REJECT_FAILED);
        end
	end
end

function ProfessionsCraftingOrderPageMixin:OnLoad()
	self:InitButtons();
	self:InitOrderTypeTabs();
	self:InitRecipeList();
	self:SetBrowseType(OrderBrowseType.None);
	self:InitOrderList();
	self:SetCraftingOrderType(Enum.CraftingOrderType.Public);

	FrameUtil.RegisterFrameForEvents(self, ProfessionsCraftingOrderPageAlwaysListenEvents);
	EventRegistry:RegisterCallback("ProfessionsFrame.Hide", function() self:ClearCachedRequests(); end, self);
end

function ProfessionsCraftingOrderPageMixin:StartDefaultSearch()
	if self.lastRequest then
		self:SendOrderRequest(self.lastRequest);
	elseif self.orderType ~= Enum.CraftingOrderType.Public then
		local selectedSkillLineAbility = nil;
		local searchFavorites = false;
		local initialNonPublicSearch = true;
		self:RequestOrders(selectedSkillLineAbility, searchFavorites, initialNonPublicSearch);
	elseif C_TradeSkillUI.HasFavoriteOrderRecipes() then
		local selectedRecipe = nil;
		local searchFavorites = true;
		local initialNonPublicSearch = false;
		self:RequestOrders(selectedRecipe, searchFavorites, initialNonPublicSearch);
	else
		self.BrowseFrame.OrderList.LoadingSpinner:Hide();
		self.BrowseFrame.OrderList.SpinnerAnim:Stop();
		self.BrowseFrame.BackButton:Hide();

		self.BrowseFrame.OrderList.ResultsText:SetText(CRAFTER_CRAFTING_ORDERS_BROWSE_FAVORITES_TIP);
		self.BrowseFrame.OrderList.ResultsText:Show();
		self.BrowseFrame.OrderList.ScrollBox:Hide();
	end
end

function ProfessionsCraftingOrderPageMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ProfessionsCraftingOrderPageEvents);
	EventRegistry:RegisterCallback("ProfessionsRecipeListMixin.Event.OnRecipeSelected", self.OnRecipeSelected, self);

	C_TradeSkillUI.SetOnlyShowAvailableForOrders(true);

	self:SetTitle();

	self.BrowseFrame.RecipeList.SearchBox:SetText(C_TradeSkillUI.GetRecipeItemNameFilter());

	local profession = self.professionInfo and self.professionInfo.profession;
	if profession and C_CraftingOrders.ShouldShowCraftingOrderTab() and C_TradeSkillUI.IsNearProfessionSpellFocus(profession) then
		C_CraftingOrders.OpenCrafterCraftingOrders();
		-- Delay a frame so that the recipe list does not get thrashed because of the delayed event from flag changes
		RunNextFrame(function() self:StartDefaultSearch(); end);
	end
	self:CheckForClaimedOrder();
end

function ProfessionsCraftingOrderPageMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ProfessionsCraftingOrderPageEvents);
	EventRegistry:UnregisterCallback("ProfessionsRecipeListMixin.Event.OnRecipeSelected", self);
	if self.requestCallback then
		self.requestCallback:Cancel();
		self.requestCallback = nil;
	end

	C_TradeSkillUI.SetOnlyShowAvailableForOrders(false);
end

function ProfessionsCraftingOrderPageMixin:UpdateOrdersRemaining()
	if not self.professionInfo then
		return;
	end
	
	local isPublic = self.orderType == Enum.CraftingOrderType.Public;
	self.BrowseFrame.OrdersRemainingDisplay:SetShown(isPublic);
	if isPublic and self.professionInfo and self.professionInfo.profession then
		self.BrowseFrame.OrdersRemainingDisplay.OrdersRemaining:SetText(PROFESSIONS_CRAFTING_ORDERS_REMAINING_ORDERS:format(C_CraftingOrders.GetOrderClaimInfo(self.professionInfo.profession).claimsRemaining));
	end
end

function ProfessionsCraftingOrderPageMixin:GetDesiredPageWidth()
	return 1105;
end

function ProfessionsCraftingOrderPageMixin:GetProfessionFrame()
	return self:GetParent();
end

function ProfessionsCraftingOrderPageMixin:Refresh(professionInfo)
	self:Init(professionInfo);

	if self:IsVisible() then
		self:SetTitle();
	end

	self.OrderView.OrderDetails.Background:SetAtlas(Professions.GetProfessionBackgroundAtlas(professionInfo), TextureKitConstants.IgnoreAtlasSize);
	self.OrderView.RankBar:Update(professionInfo);
end

function ProfessionsCraftingOrderPageMixin:SetTitle()
	local professionFrame = self:GetProfessionFrame();
	local professionInfo = professionFrame.professionInfo;
	if not professionInfo then
		return;
	end

	professionFrame:SetTitle(PROFESSIONS_CRAFTING_ORDERS_PAGE_NAME:format(professionInfo.parentProfessionName or professionInfo.professionName));
end

function ProfessionsCraftingOrderPageMixin:UpdateFavoritesButton()
	local hasFavorites = C_TradeSkillUI.HasFavoriteOrderRecipes();
	self.BrowseFrame.FavoritesSearchButton:SetEnabled(hasFavorites);
	self.BrowseFrame.FavoritesSearchButton.Icon:SetDesaturated(not hasFavorites);
end

function ProfessionsCraftingOrderPageMixin:OnRecipeSelected(recipeInfo, recipeList)
	if recipeList ~= nil and recipeList ~= self.BrowseFrame.RecipeList then
		return;
	end

	local scrollToRecipe = false;
	self.BrowseFrame.RecipeList:SelectRecipe(recipeInfo, scrollToRecipe);
	self.selectedRecipe = recipeInfo.skillLineAbilityID;

	local selectedSkillLineAbility = recipeInfo.skillLineAbilityID;
	local searchFavorites = false;
	local initialNonPublicSearch = false;
	self:RequestOrders(selectedSkillLineAbility, searchFavorites, initialNonPublicSearch);
end

function ProfessionsCraftingOrderPageMixin:CheckForClaimedOrder()
	local claimedOrder = C_CraftingOrders.GetClaimedOrder();

	if claimedOrder then
		self:ViewOrder(claimedOrder);
	else
		self:CloseOrder();
	end
end

function ProfessionsCraftingOrderPageMixin:ClearCachedRequests()
	self.selectedRecipe = nil;
	self.lastBucketRequest = nil;
	self.lastRequest = nil;
end

function ProfessionsCraftingOrderPageMixin:Init(professionInfo)
	local oldProfessionInfo = self.professionInfo;
	self.professionInfo = professionInfo;
	self.BrowseFrame.BackButton:Hide();
	self:UpdateFavoritesButton();
	self:UpdateOrdersRemaining();
	self:UpdateFilterResetVisibility();

	local changedProfessionID = not oldProfessionInfo or oldProfessionInfo.professionID ~= self.professionInfo.professionID;

	if changedProfessionID then
		self:ClearCachedRequests();

		if self:IsVisible() then
			self:StartDefaultSearch();
			self:CheckForClaimedOrder();
		end
	end

	local searching = self.BrowseFrame.RecipeList.SearchBox:HasText();
	local dataProvider = Professions.GenerateCraftingDataProvider(self.professionInfo.professionID, searching);
	
	if searching or changedProfessionID then
		self.BrowseFrame.RecipeList.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.DiscardScrollPosition);
	else
		self.BrowseFrame.RecipeList.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
	end
	self.BrowseFrame.RecipeList.NoResultsText:SetShown(dataProvider:IsEmpty());
end

function ProfessionsCraftingOrderPageMixin:SelectRecipeFromBucket(buckectInfo)
	local scrollToRecipe = true;
	local elementData = self.BrowseFrame.RecipeList:SelectRecipe(C_TradeSkillUI.GetRecipeInfo(buckectInfo.spellID), scrollToRecipe);
	if not elementData then
		local selectedRecipe = buckectInfo.skillLineAbilityID;
		local searchFavorites = false;
		local initialNonPublicSearch = false;
		self:RequestOrders(selectedRecipe, searchFavorites, initialNonPublicSearch);
	end
end

function ProfessionsCraftingOrderPageMixin:SetCraftingOrderType(orderType)
	self.orderType = orderType;

	for _, typeTab in ipairs(self.BrowseFrame.orderTypeTabs) do
		typeTab:SetTabSelected(typeTab.orderType == orderType);
	end

	self:UpdateOrdersRemaining();
	self:SetupTable();
end

local defaultBucketSecondarySort =
{
	sortType = Enum.CraftingOrderSortType.MaxTip,
	reversed = true,
};

local defaultFlatSecondarySort =
{
	sortType = Enum.CraftingOrderSortType.Tip,
	reversed = true,
};

function ProfessionsCraftingOrderPageMixin:SendOrderRequest(request)
	local isFlatSearch = request.selectedSkillLineAbility ~= nil;
	if isFlatSearch then
		local recipeInfo = C_TradeSkillUI.GetRecipeInfoForSkillLineAbility(request.selectedSkillLineAbility);
		if C_TradeSkillUI.IsRecipeFavorite(recipeInfo.recipeID) then
			recipeInfo.favoritesInstance = true;
		end
		local scrollToRecipe = false;
		self.BrowseFrame.RecipeList:SelectRecipe(recipeInfo, scrollToRecipe);
	else
		self.BrowseFrame.RecipeList:ClearSelectedRecipe();
		self.selectedRecipe = nil;
	end

	if request.offset == 0 then
		self.lastRequest = request;

		self.BrowseFrame.OrderList.ResultsText:Hide();
		self.BrowseFrame.OrderList.LoadingSpinner:Show();
		self.BrowseFrame.OrderList.SpinnerAnim:Restart();
		self.BrowseFrame.OrderList.ScrollBox:Hide();

		if not request.selectedSkillLineAbility then
			-- NOTE: This may not actually display buckets; we don't know until the server responds
			self.lastBucketRequest = request;
		end
	end

	-- Sort orders added to request in the send in case search orders changed from a cached request
	request.primarySort = Professions.TranslateSearchSort(self.primarySort);
	request.secondarySort = Professions.TranslateSearchSort(self.secondarySort) or (isFlatSearch and defaultFlatSecondarySort or defaultBucketSecondarySort);

	if self.requestCallback then
		self.requestCallback:Cancel();
	end
	self.requestCallback = C_FunctionContainers.CreateCallback(function(...) self:OrderRequestCallback(...); end);
	request.callback = self.requestCallback;
	C_CraftingOrders.RequestCrafterOrders(request);
end

function ProfessionsCraftingOrderPageMixin:RequestOrders(selectedSkillLineAbility, searchFavorites, initialNonPublicSearch)
	local request =
	{
		orderType = self.orderType,
		selectedSkillLineAbility = selectedSkillLineAbility,
		searchFavorites = searchFavorites,
		initialNonPublicSearch = initialNonPublicSearch,
		offset = 0,
		forCrafter = true,
		profession = self.professionInfo.profession,
	};
	self:SendOrderRequest(request);
end

function ProfessionsCraftingOrderPageMixin:RequestMoreOrders()
	if (not self.expectMoreRows) or (not self.numOrders) or (not self.lastRequest) or (self.requestCallback ~= nil) then
		return;
	end

	local request = self.lastRequest;
	request.offset = self.numOrders;
	self:SendOrderRequest(request);
end

function ProfessionsCraftingOrderPageMixin:ShowGeneric(orders, browseType, offset, isSorted)
	self.BrowseFrame.OrderList.LoadingSpinner:Hide();
	self.BrowseFrame.OrderList.SpinnerAnim:Stop();
	self.BrowseFrame.OrderList.ScrollBox:Show();

	local dataProvider;
	if offset == 0 then
		dataProvider = CreateDataProvider();
		-- Need to set an initially empty provider in case the table columns changed
		self.BrowseFrame.OrderList.ScrollBox:SetDataProvider(dataProvider);
	end

	if not isSorted then
		table.sort(orders, function(lhs, rhs)
			local res, equal = Professions.ApplySortOrder(self.primarySort.order);
			if not equal then
				if self.primarySort.ascending then
					return res;
				else
					return not res;
				end
			end

			if self.secondarySort then
				res, equal = Professions.ApplySortOrder(self.secondarySort.order);
				if self.secondarySort.ascending then
					return res;
				else
					return equal or (not res);
				end
			end

			return true;
		end);
	end
	
	self:SetBrowseType(browseType);

	if #orders == 0 then
		self.BrowseFrame.OrderList.ResultsText:SetText(PROFESSIONS_CUSTOMER_NO_ORDERS);
		self.BrowseFrame.OrderList.ResultsText:Show();
	else
		self.BrowseFrame.OrderList.ResultsText:Hide();
	end

	if offset == 0 then
		dataProvider = CreateDataProvider();
		for _, order in ipairs(orders) do
			dataProvider:Insert({option = order, browseType = browseType, pageFrame = self, contextMenu = self.BrowseFrame.OrderList.ContextMenu});
		end
		self.BrowseFrame.OrderList.ScrollBox:SetDataProvider(dataProvider);
	else
		dataProvider = self.BrowseFrame.OrderList.ScrollBox:GetDataProvider();
		for idx = offset + 1, #orders do
			local order = orders[idx];
			dataProvider:Insert({option = order, browseType = browseType, pageFrame = self, contextMenu = self.BrowseFrame.OrderList.ContextMenu});
		end
	end
	self.numOrders = #orders;
end

function ProfessionsCraftingOrderPageMixin:ShowBuckets(offset, isSorted)
	self.BrowseFrame.BackButton:Hide();
	self:ShowGeneric(C_CraftingOrders.GetCrafterBuckets(), OrderBrowseType.Bucketed, offset, isSorted);
end

function ProfessionsCraftingOrderPageMixin:ShowOrders(offset, isSorted)
	if self.lastRequest == self.lastBucketRequest then
		-- We requested bucketed orders and were handed a flat list
		self.lastBucketRequest = nil;
	end
	self.BrowseFrame.BackButton:SetShown(self.lastBucketRequest ~= nil);
	self:ShowGeneric(C_CraftingOrders.GetCrafterOrders(), OrderBrowseType.Flat, offset, isSorted);
end

function ProfessionsCraftingOrderPageMixin:OrderRequestCallback(result, orderType, displayBuckets, expectMoreRows, offset, isSorted)
	if orderType ~= self.orderType then
		return;
	end

	self.expectMoreRows = expectMoreRows;

	if displayBuckets then
		self:ShowBuckets(offset, isSorted);
	else
		self:ShowOrders(offset, isSorted);
	end

	self.requestCallback = nil;
end

function ProfessionsCraftingOrderPageMixin:ViewOrder(orderInfo)
	self.BrowseFrame:Hide();

	self.OrderView:SetOrder(orderInfo);
	self.OrderView:Show();
end

function ProfessionsCraftingOrderPageMixin:CloseOrder()
	self.BrowseFrame:Show();
	self.OrderView:Hide();

	self:StartDefaultSearch();
end