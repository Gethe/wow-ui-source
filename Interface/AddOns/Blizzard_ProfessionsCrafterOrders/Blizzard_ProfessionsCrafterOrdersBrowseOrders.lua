local OrderListContext = EnumUtil.MakeEnum("RecipeList", "Favorites", "Search");

ProfessionsCrafterOrdersBrowseOrdersMixin = {};

-- TODO TRADE_SKILL_DATA_SOURCE_CHANGING
local ProfessionsCrafterOrdersBrowseOrdersEvents =
{
	"TRADE_SKILL_DATA_SOURCE_CHANGED",
	"TRADE_SKILL_LIST_UPDATE",
};

function ProfessionsCrafterOrdersBrowseOrdersMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, ProfessionsCrafterOrdersBrowseOrdersEvents);

	self.SearchBar.SearchButton:SetScript("OnClick", function() 
		C_TradeSkillUI.QueryCraftingOrders(self.SearchBar.SearchBox:GetText());
	end);

	self.SearchBar.SearchBox:SetScript("OnEnterPressed", function(editBox)
		EditBox_ClearFocus(editBox);
		C_TradeSkillUI.QueryCraftingOrders(editBox:GetText());
	end);

	self.SearchBar.FavoritesSearchButton:SetAtlas("auctionhouse-icon-favorite");
	self.SearchBar.FavoritesSearchButton:SetScript("OnClick", function()
		C_TradeSkillUI.QueryCraftingOrdersFavorites();
	end);
	self.SearchBar.FavoritesSearchButton:SetScript("OnEnter", function(button)
		local tooltipText = not C_TradeSkillUI.HasCraftingOrderFavorites() and PROFESSIONS_FAVORITES_SEARCH_TOOLTIP_NO_FAVORITES or nil;
		button:SetTooltipInfo(PROFESSIONS_FAVORITES_SEARCH_TOOLTIP_TITLE, tooltipText);

		SquareIconButtonMixin.OnEnter(button);
	end);

	self.currentRecipient = Enum.TradeskillOrderRecipient.Public;

	self:SetupRecipeList();
	self:SetupOrderList();
	self:SetupOrderRecipientDropDown();

	local function OnOrderCancelled(o, order)
		print("ProfessionsCrafterOrdersMixin OnOrderCancelled", order.id);
	end
	EventRegistry:RegisterCallback("Professions.OrderCancelled", OnOrderCancelled, self);

	local function RemoveOrder(order)
		self.OrderList.ScrollBox:GetDataProvider():Remove(order);
	end

	local function OnOrderDeclined(o, order)
		print("ProfessionsCrafterOrdersMixin OnOrderDeclined", order.id);
		RemoveOrder(order);
	end
	EventRegistry:RegisterCallback("Professions.OrderDeclined", OnOrderDeclined, self);

	local function OnOrderCompleted(o, order)
		print("ProfessionsCrafterOrdersMixin OrderCompleted", order.id);
		RemoveOrder(order);
	end
	EventRegistry:RegisterCallback("Professions.OrderCompleted", OnOrderCompleted, self);
	
	self.FilterButton:SetResetFunction(Professions.SetDefaultFilters);
	
	self.FilterButton:SetScript("OnMouseDown", function(button, buttonName, down)
		UIMenuButtonStretchMixin.OnMouseDown(self.FilterButton, buttonName);
		ToggleDropDownMenu(1, nil, self.FilterDropDown, self.FilterButton, 74, 15);
	end);

	UIDropDownMenu_SetInitializeFunction(self.FilterDropDown, GenerateClosure(self.InitFilterMenu, self));

	local function OnCraftingOrdersFavoritesQuery(o, orders)
		self.selectionBehavior:ClearSelections();
		self:PopulateFavoritesList(orders);
	end
	EventRegistry:RegisterCallback("Professions.CraftingOrdersFavoritesQuery", OnCraftingOrdersFavoritesQuery, self);

	local function OnCraftingOrdersSearchQuery(o, orders)
		self.selectionBehavior:ClearSelections();
		self:PopulateSearchList(orders);
	end
	EventRegistry:RegisterCallback("Professions.CraftingOrdersSearchQuery", OnCraftingOrdersSearchQuery, self);

	UIDropDownMenu_SetInitializeFunction(self.ContextMenu, GenerateClosure(self.InitContextMenu, self));
	UIDropDownMenu_SetDisplayMode(self.ContextMenu, "MENU");
end

function ProfessionsCrafterOrdersBrowseOrdersMixin:OnEvent(event, ...)
	if event == "TRADE_SKILL_DATA_SOURCE_CHANGED" then
	elseif event == "TRADE_SKILL_LIST_UPDATE" then
		self:InitRecipeList();
	end
end

function ProfessionsCrafterOrdersBrowseOrdersMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ProfessionsCrafterOrdersBrowseOrdersEvents);
end

function ProfessionsCrafterOrdersBrowseOrdersMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ProfessionsCrafterOrdersBrowseOrdersEvents);
end

function ProfessionsCrafterOrdersBrowseOrdersMixin:InitContextMenu(dropDown, level)
	local order = UIDROPDOWNMENU_MENU_VALUE;
	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;
	
	local isFavorite = C_TradeSkillUI.IsCraftingOrderFavorite(order:GetRecipeID());

	local function CanChangeFavoriteState()
		return isFavorite or not C_TradeSkillUI.HasMaxCraftingOrderFavorites();
	end

	info.disabled = not CanChangeFavoriteState();
	info.text = isFavorite and PROFESSIONS_UNFAVORITE or PROFESSIONS_FAVORITE;
	info.func = function()
		if CanChangeFavoriteState() then
			C_TradeSkillUI.SetCraftingOrderFavorite(order:GetRecipeID(), not isFavorite);
		end
	end;

	UIDropDownMenu_AddButton(info, level);
end

function ProfessionsCrafterOrdersBrowseOrdersMixin:SetupRecipeList()
	local pad, spacing, indent = 5, 1, 14;
	local view = CreateScrollBoxListTreeListView(indent, pad, pad, pad, pad, spacing);
	view:SetElementFactory(function(factory, node)
		local elementData = node:GetData();
		if elementData.categoryInfo then
			local function Initializer(button, node)
				button:Init(node);

				button:SetScript("OnClick", function(button, buttonName)
					node:ToggleCollapsed();
					button:SetCollapseState(node:IsCollapsed());
				end);
			end
			factory("ProfessionsRecipeListCategoryTemplate", Initializer);
		elseif elementData.recipeInfo then
			local function Initializer(button, node)
				button:Init(node);
			
				local selected = self.selectionBehavior:IsElementDataSelected(node);
				button:SetSelected(selected);

				button:SetScript("OnClick", function(button, buttonName,  down)
					EventRegistry:TriggerEvent("ProfessionsDebug.CraftingRecipeListRecipeClicked", button, buttonName, down, elementData.recipeInfo);
					
					if buttonName == "LeftButton" then
						if IsModifiedClick("RECIPEWATCHTOGGLE") then
							HandleModifiedItemClick(C_TradeSkillUI.GetRecipeLink(elementData.recipeInfo.recipeID));
						else
							self.selectionBehavior:Select(button);
						end
					end
				end);
			end
			factory("ProfessionsRecipeListRecipeTemplate", Initializer);
		else
			factory("Frame");
		end
	end);
	
	view:SetElementExtentCalculator(function(dataIndex, node)
		local elementData = node:GetData();
		local baseElementHeight = 20;
		local categoryPadding = 5;

		if elementData.recipeInfo then
			return baseElementHeight;
		end

		if elementData.categoryInfo then
			return baseElementHeight + categoryPadding;
		end

		if elementData.topPadding then
			return 1;
		end

		if elementData.bottomPadding then
			return 10;
		end
	end);

	local function OnSelectionChanged(o, node, selected)
		local button = self.RecipeList.ScrollBox:FindFrame(node);
		if button then
			button:SetSelected(selected);
		end

		if selected then
			local data = node:GetData();
			local recipeID = data.recipeInfo.recipeID;
			self:PopulateOrderList(recipeID);
		end
	end;

	self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.RecipeList.ScrollBox);
	self.selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, OnSelectionChanged, self);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.RecipeList.ScrollBox, self.RecipeList.ScrollBar, view);
end

function ProfessionsCrafterOrdersBrowseOrdersMixin:SetupOrderList()
	local pad, spacing = 5, 1;
	local view = CreateScrollBoxListLinearView(pad, pad, pad, pad, spacing);
	view:SetElementInitializer("ProfessionsCrafterOrdersOrderListElementTemplate", function(button, order)
		button:SetScript("OnClick", function(button, buttonName)
			if buttonName == "LeftButton" then
				EventRegistry:TriggerEvent("Professions.OrderSelected", order);
			elseif buttonName == "RightButton" then
				ToggleDropDownMenu(1, order, self.ContextMenu, "cursor");
			end
		end);
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.OrderList.ScrollBox, self.OrderList.ScrollBar, view);

	self.tableBuilder = CreateTableBuilder(nil, ProfessionsTableBuilderMixin);
	self.tableBuilder:SetTableWidth(self.OrderList.ScrollBox:GetWidth());
	local function ElementDataProvider(elementData)
		return elementData;
	end;
	self.tableBuilder:SetDataProvider(ElementDataProvider);

	local function ElementDataTranslator(elementData)
		return elementData;
	end;
	ScrollUtil.RegisterTableBuilder(self.OrderList.ScrollBox, self.tableBuilder, ElementDataTranslator);
end

function ProfessionsCrafterOrdersBrowseOrdersMixin:InitFilterMenu(dropdown, level)
	Professions.InitFilterMenu(dropdown, level, GenerateClosure(self.UpdateFilterResetVisibility, self));
end

function ProfessionsCrafterOrdersBrowseOrdersMixin:UpdateFilterResetVisibility()
	self.FilterButton.ResetButton:SetShown(not Professions.IsUsingDefaultFilters());
end

function ProfessionsCrafterOrdersBrowseOrdersMixin:InitRecipeList()
	local professionInfo = C_TradeSkillUI.GetChildProfessionInfo();
	local dataProvider = Professions.GenerateCraftingDataProvider(professionInfo.professionID);
	self.RecipeList.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

	if self.recipeID then
		self.selectionBehavior:SelectElementDataByPredicate(function(node)
			local data = node:GetData();
			local recipeInfo = data.recipeInfo;
			if not recipeInfo then
				return false;
			end
			return recipeInfo.recipeID == self.recipeID;
		end);
	end
end

function ProfessionsCrafterOrdersBrowseOrdersMixin:Init()
	self.SearchBar.SearchBox:SetText("");

	self:InitRecipeList();

	local force = true;
	self:SetupSortManager(self.currentRecipient, force);
end

local function PrivateOrderLayout(tableBuilder, owner)
	local PTC = ProfessionsTableConstants;
	tableBuilder:AddFillColumn(owner, PTC.NoPadding, PTC.Name.FillCoefficient, 
		PTC.Name.LeftCellPadding, PTC.Name.RightCellPadding, ProfessionsSortOrder.Name, "ProfessionsCrafterTableCellNameTemplate");
	tableBuilder:AddFixedWidthColumn(owner, PTC.NoPadding, PTC.Tip.Width, 
		PTC.StandardPadding, PTC.Tip.RightCellPadding, ProfessionsSortOrder.Tip, "ProfessionsCrafterTableCellTipTemplate");
	tableBuilder:AddFixedWidthColumn(owner, PTC.NoPadding, PTC.Quality.Width, 
		PTC.StandardPadding, PTC.Quality.RightCellPadding, ProfessionsSortOrder.Quality, "ProfessionsCrafterTableCellQualityTemplate");
	tableBuilder:AddFixedWidthColumn(owner, PTC.NoPadding, PTC.Reagents.Width, 
		PTC.StandardPadding, PTC.Reagents.RightCellPadding, ProfessionsSortOrder.Reagents, "ProfessionsCrafterTableCellReagentsTemplate");
	tableBuilder:AddFixedWidthColumn(owner, PTC.NoPadding, PTC.Expiration.Width, 
		PTC.StandardPadding, PTC.Expiration.RightCellPadding, ProfessionsSortOrder.Expiration, "ProfessionsCrafterTableCellExpirationTemplate");
end

local function PublicOrderLayout(tableBuilder, owner)
	local PTC = ProfessionsTableConstants;
	tableBuilder:AddFillColumn(owner, PTC.NoPadding, PTC.Name.FillCoefficient, 
		PTC.Name.LeftCellPadding, PTC.Name.RightCellPadding, ProfessionsSortOrder.Name, "ProfessionsCrafterTableCellNameTemplate");
	tableBuilder:AddFixedWidthColumn(owner, PTC.NoPadding, PTC.Tip.Width, 
		PTC.StandardPadding, PTC.Tip.RightCellPadding, ProfessionsSortOrder.Tip, "ProfessionsCrafterTableCellTipTemplate");
	tableBuilder:AddFixedWidthColumn(owner, PTC.NoPadding, PTC.Reagents.Width, 
		PTC.StandardPadding, PTC.Reagents.RightCellPadding, ProfessionsSortOrder.Reagents, "ProfessionsCrafterTableCellReagentsTemplate");
	tableBuilder:AddFixedWidthColumn(owner, PTC.NoPadding, PTC.Expiration.Width, 
		PTC.StandardPadding, PTC.Expiration.RightCellPadding, ProfessionsSortOrder.Expiration, "ProfessionsCrafterTableCellExpirationTemplate");
end

function ProfessionsCrafterOrdersBrowseOrdersMixin:SetupTable(layout)
	self.tableBuilder:Reset();
	self.tableBuilder:SetColumnHeaderOverlap(2);
	self.tableBuilder:SetHeaderContainer(self.OrderList.HeaderContainer);
	layout(self.tableBuilder, self, self.OrderList.HeaderContainer);
	self.tableBuilder:Arrange();
end

function ProfessionsCrafterOrdersBrowseOrdersMixin:SetSortOrderInternal(sortOrder)
	if self.sortOrder == sortOrder then
		self.sortManager:ToggleSortAscending(sortOrder);
	else
		self.sortOrder = sortOrder;
		self.sortManager:SetSortAscending(sortOrder, true);
	end
end

function ProfessionsCrafterOrdersBrowseOrdersMixin:SetSortOrder(sortOrder)
	self:SetSortOrderInternal(sortOrder);

	for frame in self.tableBuilder:EnumerateHeaders() do
		frame:UpdateArrow();
	end

	self.OrderList.ScrollBox:GetDataProvider():Sort();
end

function ProfessionsCrafterOrdersBrowseOrdersMixin:GetSortOrder()
	return self.sortOrder, self.sortManager:IsSortAscending(self.sortOrder);
end

function ProfessionsCrafterOrdersBrowseOrdersMixin:SetupSortManager(recipient, force)
	if force or (self.currentRecipient ~= recipient) then
		self.currentRecipient = recipient;
		self.sortManager = SortUtil.CreateSortManager();
		self.sortManager:SetDefaultComparator(function(lhs, rhs)
			return lhs.id < rhs.id; 
		end);
		self.sortManager:SetSortOrderFunc(function()
			return self.sortOrder;
		end);

		self.sortManager:InsertComparator(ProfessionsSortOrder.Tip, function(lhs, rhs) 
			return SortUtil.CompareNumeric(lhs.tip, rhs.tip); 
		end);
		self.sortManager:InsertComparator(ProfessionsSortOrder.Name, function(lhs, rhs) 
			return SortUtil.CompareUtf8i(lhs:GetName(), rhs:GetName()); 
		end);
		self.sortManager:InsertComparator(ProfessionsSortOrder.Expiration, function(lhs, rhs) 
			return SortUtil.CompareNumeric(lhs.duration, rhs.duration); 
		end);
		self.sortManager:InsertComparator(ProfessionsSortOrder.Reagents, function(lhs, rhs) 
			return SortUtil.CompareNumeric(lhs.reagentContents, rhs.reagentContents); 
		end);

		if recipient ~= Enum.TradeskillOrderRecipient.Public then
			self.sortManager:InsertComparator(ProfessionsSortOrder.Quality, function(lhs, rhs) 
				return SortUtil.CompareNumeric(lhs.quality, rhs.quality); 
			end);
		end

		-- Sort order needs to be assigned prior to the table builder generating rows.
		self:SetSortOrderInternal(ProfessionsSortOrder.Tip);

		if recipient == Enum.TradeskillOrderRecipient.Public then
			self:SetupTable(PublicOrderLayout);
		else
			self:SetupTable(PrivateOrderLayout);
		end
	end
end

function ProfessionsCrafterOrdersBrowseOrdersMixin:SetOrderRecipient(recipient)
	local changed = self.currentRecipient ~= recipient;

	self:SetupSortManager(recipient);

	if changed then
		if self.orderListContext == OrderListContext.RecipeList then
			self:PopulateOrderList(self.recipeID);
		elseif self.orderListContext == OrderListContext.Favorites then
			self:PopulateFavoritesList(self.favorites);
		elseif self.orderListContext == OrderListContext.Search then
			self:PopulateSearchList(self.search);
		end
	end
end

function ProfessionsCrafterOrdersBrowseOrdersMixin:SetDataProviderWithOrderPredicate(orders, predicate)
	local dataProvider = CreateDataProvider();
	for index, order in ipairs(orders) do
		if (order.recipient == self.currentRecipient) and (not order:IsStatus(Enum.TradeskillOrderStatus.Completed)) and predicate(order) then
			dataProvider:Insert(order);
		end
	end
	dataProvider:SetSortComparator(self.sortManager:CreateComparator());

	self.OrderList.ScrollBox:SetDataProvider(dataProvider);
end

function ProfessionsCrafterOrdersBrowseOrdersMixin:PopulateOrderList(recipeID)
	self.orderListContext = OrderListContext.RecipeList;
	self.recipeID = recipeID;

	self:SetDataProviderWithOrderPredicate(C_TradeSkillUI.GetCraftingOrders(), function(order)
		return order:GetRecipeID() == recipeID;
	end);
end

function ProfessionsCrafterOrdersBrowseOrdersMixin:PopulateFavoritesList(orders)
	self.orderListContext = OrderListContext.Favorites;
	self.favorites = orders;

	self:SetDataProviderWithOrderPredicate(orders, function(order)
		return true;
	end);
end

function ProfessionsCrafterOrdersBrowseOrdersMixin:PopulateSearchList(orders)
	self.orderListContext = OrderListContext.Search;
	self.search = orders;

	self:SetDataProviderWithOrderPredicate(orders, function(order)
		return true;
	end);
end

function ProfessionsCrafterOrdersBrowseOrdersMixin:SetupOrderRecipientDropDown()
	local function Initializer(dropDown, level)
		local function DropDownButtonClick(button)
			local recipient = button.value;

			UIDropDownMenu_SetSelectedValue(self.OrderRecipientDropDown, recipient);

			self:SetOrderRecipient(recipient);
		end
	
		local ORDER_RECIPIENT_TEXTS = {
			PROFESSIONS_CRAFTING_FORM_ORDER_RECIPIENT_PUBLIC,
			PROFESSIONS_CRAFTING_FORM_ORDER_RECIPIENT_GUILD,
			PROFESSIONS_CRAFTING_FORM_ORDER_RECIPIENT_PRIVATE,
		};

		for index, text in ipairs(ORDER_RECIPIENT_TEXTS) do
			local info = UIDropDownMenu_CreateInfo();
			info.fontObject = Number12Font;
			info.text = text;
			info.minWidth = 108;
			info.value = index;
			info.checked = nil;
			info.func = DropDownButtonClick;
			UIDropDownMenu_AddButton(info);
		end
	end

	UIDropDownMenu_Initialize(self.OrderRecipientDropDown, Initializer);
	UIDropDownMenu_SetSelectedValue(self.OrderRecipientDropDown, self.currentRecipient);
end