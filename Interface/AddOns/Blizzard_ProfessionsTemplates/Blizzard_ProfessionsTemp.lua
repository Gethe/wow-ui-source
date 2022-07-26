ProfessionsOrdersManifestMixin = {};

function ProfessionsOrdersManifestMixin:Init()
	self.orders = {};
end

function ProfessionsOrdersManifestMixin:ListOrder(order)
	table.insert(self.orders, order);
end

function ProfessionsOrdersManifestMixin:RemoveOrder(order)
	tDeleteItem(self.orders, order);
end

function ProfessionsOrdersManifestMixin:GetOrders()
	return self.orders;
end

ProfessionsOrdersManifest = CreateAndInitFromMixin(ProfessionsOrdersManifestMixin);

local currentOrder;
local currentOrderTicker;

local function CancelTicker()
	if currentOrderTicker then
		currentOrderTicker:Cancel();
		currentOrderTicker = nil;
	end
end

local function SetCurrentOrder(order)
	assert(order);
	currentOrder = order;
	local function Tick()
		if currentOrder:HasExpired() then
			CancelTicker();

			currentOrder:Expire();

			EventRegistry:TriggerEvent("Professions.OrderExpired", order);
		end
	end

	local frequencySeconds = 1;
	currentOrderTicker = C_Timer.NewTicker(frequencySeconds, Tick);
end

local function ClearCurrentOrder()
	if currentOrder then
		currentOrder = nil;
		CancelTicker();
	end
end

function C_TradeSkillUI.ListCraftingOrder(order)
	--DumpWithoutTbls(order, "List order:");
	--order.transaction:Dump();
	order.status = Enum.TradeskillOrderStatus.Unclaimed;

	ProfessionsOrdersManifest:ListOrder(order);
	EventRegistry:TriggerEvent("Professions.OrderListed", order);
end

function C_TradeSkillUI.GetCurrentOrder()
	return currentOrder;
end

function C_TradeSkillUI.GetCraftingOrders()
	return ProfessionsOrdersManifest:GetOrders();
end

function C_TradeSkillUI.StartCraftingOrder(order)
	order:Start();

	SetCurrentOrder(order);

	EventRegistry:TriggerEvent("Professions.OrderStarted", order);
end

function C_TradeSkillUI.CancelCraftingOrder(order)
	order:Cancel();

	ClearCurrentOrder();

	EventRegistry:TriggerEvent("Professions.OrderCancelled", order);
end

function C_TradeSkillUI.DeclineCraftingOrder(order)
	ProfessionsOrdersManifest:RemoveOrder(order);

	EventRegistry:TriggerEvent("Professions.OrderDeclined", order);
end

function C_TradeSkillUI.CompleteCraftingOrder(order, message)
	if order:HasExpired() then
		return;
	end

	order:Complete(message);

	ClearCurrentOrder();

	EventRegistry:TriggerEvent("Professions.OrderCompleted", order);
end

--local function CreateSampleOrders(quantity, ...)
--	local tbl = {};
--	for e = 1, select("#", ...) do
--		local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(select(e, ...));
--		for index = 1, quantity do
--			table.insert(tbl, Professions.CreateSampleOrderBySchematic(recipeSchematic));
--		end
--	end
--	return tbl;
--end

do
	--local orders = CreateSampleOrders(20, 364044, 367623, 367601, 367605); 
	--for index, order in ipairs(orders) do
	--	C_TradeSkillUI.ListCraftingOrder(order);
	--end
end

do
	local favoriteRecipeIDs = {};

	function C_TradeSkillUI.QueryCraftingOrdersFavorites()
		local favoriteOrders = {};
		for index, order in ipairs(C_TradeSkillUI.GetCraftingOrders()) do
			if tContains(favoriteRecipeIDs, order:GetRecipeID()) then
				table.insert(favoriteOrders, order);
			end
		end

		EventRegistry:TriggerEvent("Professions.CraftingOrdersFavoritesQuery", favoriteOrders);
	end
	
	function C_TradeSkillUI.HasCraftingOrderFavorites()
		return #favoriteRecipeIDs > 0;
	end

	function C_TradeSkillUI.SetCraftingOrderFavorite(recipeID, favorite)
		if favorite then
			table.insert(favoriteRecipeIDs, recipeID);
		else
			tDeleteItem(favoriteRecipeIDs, recipeID);
		end
	end

	function C_TradeSkillUI.HasMaxCraftingOrderFavorites()
		return #favoriteRecipeIDs >= 2;
	end

	function C_TradeSkillUI.IsCraftingOrderFavorite(recipeID)
		return tContains(favoriteRecipeIDs, recipeID);
	end
end

function C_TradeSkillUI.QueryCraftingOrders(searchText)
	searchText = string.lower(searchText);
	local searchOrders = {};
	for index, order in ipairs(C_TradeSkillUI.GetCraftingOrders()) do
		if string.find(string.lower(order:GetName()), searchText) then
			table.insert(searchOrders, order);
		end
	end

	EventRegistry:TriggerEvent("Professions.CraftingOrdersSearchQuery", searchOrders);
end

function Professions.FormatListElementText(order)
	local function OrderRecipientEnumToString(recipient)
		for key, value in pairs(Enum.TradeskillOrderRecipient) do
			if recipient == value then
				return key;
			end
		end
		error();
	end

	local tip = math.floor(order.tip / COPPER_PER_GOLD)..CreateAtlasMarkup("coin-gold");

	return ("%s     %s     %d      %s      %s     %s"):format(
		order:GetName(), 
		tip, 
		order.id, 
		OrderRecipientEnumToString(order.recipient),
		strsub(order.message, 1, 30),
		(order.finalizedMessage and strsub(order.finalizedMessage, 1, 30) or "")
	);
end