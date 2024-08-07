
ProfessionsCustomerOrderListElementMixin = CreateFromMixins(TableBuilderRowMixin);

function ProfessionsCustomerOrderListElementMixin:OnLineEnter()
	self.HighlightTexture:Show();

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	local reagents = {};
	local qualityIDs = C_TradeSkillUI.GetQualitiesForRecipe(self.option.spellID);
	local minQuality = self.option.minQuality >= 1 and self.option.minQuality or 1;
	GameTooltip:SetRecipeResultItem(self.option.spellID, reagents, nil, nil, qualityIDs and qualityIDs[minQuality]);

	if IsModifiedClick("DRESSUP") then
		ShowInspectCursor();
	end

	self:SetScript("OnUpdate", self.OnUpdate);
end

function ProfessionsCustomerOrderListElementMixin:OnLineLeave()
	self.HighlightTexture:Hide();

	GameTooltip:Hide();
	ResetCursor();
	self:SetScript("OnUpdate", nil);
end

function ProfessionsCustomerOrderListElementMixin:OnClick(button)
	if button == "LeftButton" then
		EventRegistry:TriggerEvent("ProfessionsCustomerOrders.OrderSelected", self.option);
	elseif button == "RightButton" then
		MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
			rootDescription:SetTag("MENU_PROFESSIONS_CUSTOMER_ORDER");

			if self.option.orderState then
				rootDescription:CreateButton(PROFESSIONS_CRAFTING_FORM_CANCEL_ORDER, function()
					C_CraftingOrders.CancelOrder(self.option.orderID);
				end);
			end
		end);
	end
end

-- Set and cleared dynamically in OnEnter and OnLeave
function ProfessionsCustomerOrdersRecipeListElementMixin:OnUpdate()
	if IsModifiedClick("DRESSUP") then
		ShowInspectCursor();
	else
		ResetCursor();
	end
end

function ProfessionsCustomerOrderListElementMixin:Init(elementData)
	self.option = elementData.option;
end


ProfessionsCustomerOrdersMyOrdersMixin = {};

local myOrdersPageEvents =
{
	"CRAFTINGORDERS_CAN_REQUEST",
	"CRAFTINGORDERS_ORDER_CANCEL_RESPONSE",
};

function ProfessionsCustomerOrdersMyOrdersMixin:InitButtons()
	self.RefreshButton:SetScript("OnClick", function() self:RefreshOrders(); end);
	self.RefreshButton:SetScript("OnEnter", function()
		GameTooltip:SetOwner(self.RefreshButton, "ANCHOR_RIGHT");
		GameTooltip_AddHighlightLine(GameTooltip, REFRESH);
		GameTooltip:Show();
	end);
end

function ProfessionsCustomerOrdersMyOrdersMixin:InitOrderList()
	local pad = 5;
	local spacing = 1;
	local view = CreateScrollBoxListLinearView(pad, pad, pad, pad, spacing);
	view:SetElementInitializer("ProfessionsCustomerOrderListElementTemplate", function(button, elementData)
		button:Init(elementData);
	end);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.OrderList.ScrollBox, self.OrderList.ScrollBar, view);

	self.tableBuilder = CreateTableBuilder(nil, ProfessionsTableBuilderMixin);
	self.tableBuilder:SetTableWidth(self.OrderList.ScrollBox:GetWidth());
	local function ElementDataProvider(elementData)
		return elementData;
	end;
	self.tableBuilder:SetDataProvider(ElementDataProvider);
	self.tableBuilder:SetColumnHeaderOverlap(2);
	self.tableBuilder:SetHeaderContainer(self.OrderList.HeaderContainer);
	self.tableBuilder:SetTableMargins(5, 5);

	local PTC = ProfessionsTableConstants;

	self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.ItemName.Width, PTC.ItemName.LeftCellPadding,
										  PTC.ItemName.RightCellPadding, ProfessionsSortOrder.ItemName, "ProfessionsCustomerTableCellItemNameTemplate");

	self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.Status.Width, PTC.Status.LeftCellPadding,
										  PTC.Status.RightCellPadding, ProfessionsSortOrder.Status, "ProfessionsCustomerTableCellStatusTemplate");

	self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.Tip.Width, PTC.Tip.LeftCellPadding,
										  PTC.Tip.RightCellPadding, ProfessionsSortOrder.Tip, "ProfessionsCustomerTableCellActualCommissionTemplate");

	self.tableBuilder:AddUnsortableFixedWidthColumn(self, PTC.NoPadding, PTC.OrderType.Width, PTC.OrderType.LeftCellPadding,
										  PTC.OrderType.RightCellPadding, CRAFTING_ORDERS_BROWSE_HEADER_ORDER_TYPE, "ProfessionsCustomerTableCellTypeTemplate");

	self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.Expiration.Width, PTC.Expiration.LeftCellPadding,
										  PTC.Expiration.RightCellPadding, ProfessionsSortOrder.Expiration, "ProfessionsCustomerTableCellExpirationTemplate");

	self.tableBuilder:Arrange();

	local function ElementDataTranslator(elementData)
		return elementData;
	end;
	ScrollUtil.RegisterTableBuilder(self.OrderList.ScrollBox, self.tableBuilder, ElementDataTranslator);

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
	self.OrderList.ScrollBox:RegisterCallback(ScrollBoxListMixin.Event.OnDataRangeChanged, OnDataRangeChanged, self);
end

function ProfessionsCustomerOrdersMyOrdersMixin:ResetSortOrder()
	self.primarySort =
	{
		order = ProfessionsSortOrder.ItemName;
		ascending = true;
	};

	self.secondarySort =
	{
		order = ProfessionsSortOrder.Expiration;
		ascending = true;
	};

	if self.tableBuilder then
		for frame in self.tableBuilder:EnumerateHeaders() do
			frame:UpdateArrow();
		end
	end
end

function ProfessionsCustomerOrdersMyOrdersMixin:SetSortOrder(sortOrder)
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

	self:RefreshOrders();
end

function ProfessionsCustomerOrdersMyOrdersMixin:GetSortOrder()
	return self.primarySort.order, self.primarySort.ascending;
end

function ProfessionsCustomerOrdersMyOrdersMixin:OnLoad()
	self:ResetSortOrder();
	self:InitButtons();
	self:InitOrderList();
end

function ProfessionsCustomerOrdersMyOrdersMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, myOrdersPageEvents);

	self:RefreshOrders();
end

function ProfessionsCustomerOrdersMyOrdersMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, myOrdersPageEvents);
end

function ProfessionsCustomerOrdersMyOrdersMixin:OnEvent(event, ...)
	if event == "CRAFTINGORDERS_CAN_REQUEST" then
		self.RefreshButton:SetEnabledState(true);
	elseif event == "CRAFTINGORDERS_ORDER_CANCEL_RESPONSE" then
		local result = ...;
		local success = (result == Enum.CraftingOrderResult.Ok);
		if success then
			self:RefreshOrders();
		else
			UIErrorsFrame:AddExternalErrorMessage(PROFESSIONS_ORDER_CANCEL_FAILED);
        end
	end
end

function ProfessionsCustomerOrdersMyOrdersMixin:RequestOrders(offset)
	if self.requestCallback then
		self.requestCallback:Cancel();
	end
	self.requestCallback = C_FunctionContainers.CreateCallback(function(...) self:UpdateOrderList(...); end);
	local request =
	{
		offset = offset,
		callback = self.requestCallback,
	};
	request.primarySort = Professions.TranslateSearchSort(self.primarySort);
	request.secondarySort = Professions.TranslateSearchSort(self.secondarySort);
	C_CraftingOrders.ListMyOrders(request);
end

function ProfessionsCustomerOrdersMyOrdersMixin:RequestMoreOrders()
	if (not self.expectMoreRows) or (not self.numOrders) or (self.requestCallback ~= nil) then
		return;
	end

	local offset = self.numOrders;
	self:RequestOrders(offset);
end

function ProfessionsCustomerOrdersMyOrdersMixin:RefreshOrders()
	self.RefreshButton:SetEnabledState(false);
	self.OrderList.ResultsText:Hide();
	self.OrderList.LoadingSpinner:Show();
	self.OrderList.ScrollBox:Hide();

	local offset = 0;
	self:RequestOrders(offset);
end

function ProfessionsCustomerOrdersMyOrdersMixin:UpdateOrderList(result, expectMoreRows, offset, isSorted)
	self.OrderList.LoadingSpinner:Hide();
	self.OrderList.ScrollBox:Show();

	self.expectMoreRows = expectMoreRows;
	local orders = C_CraftingOrders.GetMyOrders();
	self.numOrders = #orders;

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

			res, equal = Professions.ApplySortOrder(self.secondarySort.order);
			if self.secondarySort.ascending then
				return res;
			else
				return equal or (not res);
			end
		end);
	end

	if offset == 0 then
		local dataProvider = CreateDataProvider();
		for _, order in ipairs(orders) do
			dataProvider:Insert({option = order});
		end
		self.OrderList.ScrollBox:SetDataProvider(dataProvider);
	else
		local dataProvider = self.OrderList.ScrollBox:GetDataProvider();
		for idx = offset + 1, #orders do
			local order = orders[idx];
			dataProvider:Insert({option = order});
		end
	end

	local anyOrders = (#orders > 0);
	self.OrderList.ResultsText:SetShown(not anyOrders);

	if anyOrders and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PROFESSIONS_CO_ORDER_PLACED) then
		local orderPlacedHelpTipInfo =
		{
			text = CRAFTING_ORDER_PLACED_TUTORIAL,
			buttonStyle = HelpTip.ButtonStyle.Close,
			targetPoint = HelpTip.Point.RightEdgeTop,
			offsetX = -15,
			offsetY = -12,
			acknowledgeOnHide = true,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_PROFESSIONS_CO_ORDER_PLACED,
		};
		HelpTip:Show(self, orderPlacedHelpTipInfo, self.OrderList.ScrollBox);
	end

	self.requestCallback = nil;
end