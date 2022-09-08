ProfessionsCrafterOrdersMode = EnumUtil.MakeEnum("Browse", "Orders");

ProfessionsCrafterOrdersMixin = {};

local ProfessionsCrafterOrdersEvents =
{
	"TRADE_SKILL_DATA_SOURCE_CHANGED",
	"TRADE_SKILL_LIST_UPDATE",
	"TRADE_SKILL_CLOSE",
};

function ProfessionsCrafterOrdersMixin:OnLoad()
	local function OnOrderCompleted(o, order)
		print("ProfessionsCrafterOrdersMixin OnOrderCompleted", order.id);
		self:ShowBrowseOrders();
	end
	EventRegistry:RegisterCallback("Professions.OrderCompleted", OnOrderCompleted, self);

	local function OnOrderExpired(o, order)
		print("ProfessionsCrafterOrdersMixin OnOrderExpired", order.id);
	end
	EventRegistry:RegisterCallback("Professions.OrderExpired", OnOrderExpired, self);

end

function ProfessionsCrafterOrdersMixin:OnEvent(event, ...)
	print("ProfessionsCrafterOrdersMixin", event);
	if event == "TRADE_SKILL_DATA_SOURCE_CHANGED" then
	elseif event == "TRADE_SKILL_LIST_UPDATE" then
		self.BrowseOrders:Init();

		local order = C_TradeSkillUI.GetCurrentOrder();
		if order and not order:HasExpired() then
			self:ShowForm(order);
		end
	elseif event == "TRADE_SKILL_CLOSE" then
		HideUIPanel(self);
	end
end

function ProfessionsCrafterOrdersMixin:OnShow()
    FrameUtil.RegisterFrameForEvents(self, ProfessionsCrafterOrdersEvents);

    self:SetPortraitToUnit("npc");
	
	self:SetTitle("[PH] Crafting Orders");

    PlaySound(SOUNDKIT.AUCTION_WINDOW_OPEN);

	local function OnBackButtonClicked(button, buttonName, down)
		self:ShowBrowseOrders();
	end
	
	self.Form.CustomerDetails.BackButton:SetScript("OnClick", OnBackButtonClicked);
	
	local order = C_TradeSkillUI.GetCurrentOrder();
	if not order or order:HasExpired() then
		self:ShowBrowseOrders();
	end

	-- FIXME - Need design flow for what happens when an order expires. We need to return the order
	-- back to Unclaimed if we want the form to offer to be restarted, either before the form is opened
	-- or through some restart option in the form.
	EventRegistry:RegisterCallback("Professions.OrderSelected", self.ShowForm, self);

	EventRegistry:RegisterCallback("Professions.OrderCancelled", self.ShowBrowseOrders, self);
	EventRegistry:RegisterCallback("Professions.OrderDeclined", self.ShowBrowseOrders, self);
end

function ProfessionsCrafterOrdersMixin:OnHide()
    FrameUtil.UnregisterFrameForEvents(self, ProfessionsCrafterOrdersEvents);
    
	C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.Professions);
	C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.ProfessionCraftingOrder);

	EventRegistry:UnregisterCallback("Professions.RecipeSelected", self);
end

function ProfessionsCrafterOrdersMixin:ShowBrowseOrders()
	self:SetSize(800, 538);
	self.BrowseOrders:Show();

	self.Form:Hide();
end

function ProfessionsCrafterOrdersMixin:ShowForm(order)
	self:SetSize(1130, 610);
	self.Form:Init(order);
	self.Form:Show();

	self.BrowseOrders:Hide();
end
