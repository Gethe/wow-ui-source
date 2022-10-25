ProfessionsCustomerOrdersMyOrdersMixin = {};

local FilterCategory = EnumUtil.MakeEnum("Accepted", "Open", "Expired");

function ProfessionsCustomerOrdersMyOrdersMixin:OnLoad()
	local function OnOrderStatusChanged(o, order)
		self:PopulateOrderListDataProvider();
	end

	EventRegistry:RegisterCallback("Professions.OrderListed", OnOrderStatusChanged, self);
	EventRegistry:RegisterCallback("Professions.OrderStarted", OnOrderStatusChanged, self);
	EventRegistry:RegisterCallback("Professions.OrderCancelled", OnOrderStatusChanged, self);
	EventRegistry:RegisterCallback("Professions.OrderDeclined", OnOrderStatusChanged, self);
	EventRegistry:RegisterCallback("Professions.OrderCompleted", OnOrderStatusChanged, self);

	do
		local pad, spacing = 5, 1;
		local view = CreateScrollBoxListLinearView(pad, pad, pad, pad, spacing);
		view:SetElementInitializer("ProfessionsCustomerOrdersOrderCategoryListElementTemplate", function(button, elementData)
			button:Init(elementData);

			button:SetScript("OnClick", function(button, buttonName, down)
				self.category = elementData.category;

				self:PopulateOrderListDataProvider();
			end);
		end);
	
		ScrollUtil.InitScrollBoxListWithScrollBar(self.CategoryList.ScrollBox, self.CategoryList.ScrollBar, view);
		
		local dataProvider = CreateDataProvider();
		dataProvider:Insert({name=PROFESSIONS_ORDER_CATEGORY_ALL});
		dataProvider:Insert({name=PROFESSIONS_ORDER_CATEGORY_ACCEPTED, category=FilterCategory.Accepted});
		dataProvider:Insert({name=PROFESSIONS_ORDER_CATEGORY_OPEN, category=FilterCategory.Open});
		dataProvider:Insert({name=PROFESSIONS_ORDER_CATEGORY_EXPIRED, category=FilterCategory.Expired});
		self.CategoryList.ScrollBox:SetDataProvider(dataProvider);
	end
	
	do
		local pad, spacing = 5, 1;
		local view = CreateScrollBoxListLinearView(pad, pad, pad, pad, spacing);
		view:SetElementInitializer("ProfessionsCustomerOrdersOrderListElementTemplate", function(button, order)
			button:Init(order);

			button:SetScript("OnClick", function(button, buttonName)
				EventRegistry:TriggerEvent("ProfessionsCustomerOrders.OrderSelected", order);
			end);
		end);

		ScrollUtil.InitScrollBoxListWithScrollBar(self.OrderList.ScrollBox, self.OrderList.ScrollBar, view);
	end

	self:PopulateOrderListDataProvider();
end

function ProfessionsCustomerOrdersMyOrdersMixin:IsIncludedInFilterCategory(order)
	if not self.category then
		return true;
	end

	if self.category == FilterCategory.Accepted then
		return order:IsStatus(Enum.TradeskillOrderStatus.Started);
	end

	if self.category == FilterCategory.Open then
		return order:IsStatus(Enum.TradeskillOrderStatus.Unclaimed);
	end

	if self.category == FilterCategory.Expired then
		return order:IsStatus(Enum.TradeskillOrderStatus.Expired);
	end

	return false;
end

function ProfessionsCustomerOrdersMyOrdersMixin:PopulateOrderListDataProvider()
	local dataProvider = CreateDataProvider();

	local player = UnitName("player");
	for index, order in ipairs(C_TradeSkillUI.GetCraftingOrders()) do
		if order.customer == player and self:IsIncludedInFilterCategory(order) then
			dataProvider:Insert(order);
		end
	end
	self.OrderList.ScrollBox:SetDataProvider(dataProvider);
end
