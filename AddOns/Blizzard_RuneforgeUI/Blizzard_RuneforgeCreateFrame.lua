
RuneforgeCreateFrameMixin = CreateFromMixins(RuneforgeSystemMixin);

local RefreshEventNames = {
	"BaseItemChanged",
	"ItemLevelTierChanged",
	"PowerSelected",
	"ModifiersChanged",
};

function RuneforgeCreateFrameMixin:OnLoad()
	self:UpdateCost();
end

function RuneforgeCreateFrameMixin:OnShow()
	local runeforgeFrame = self:GetRuneforgeFrame();
	for i, eventName in ipairs(RefreshEventNames) do
		runeforgeFrame:RegisterCallback(RuneforgeFrameMixin.Event[eventName], self.Refresh, self);
	end

	self:Refresh();
end

function RuneforgeCreateFrameMixin:OnHide()
	local runeforgeFrame = self:GetRuneforgeFrame();
	for i, eventName in ipairs(RefreshEventNames) do
		runeforgeFrame:UnregisterCallback(RuneforgeFrameMixin.Event[eventName], self);
	end
end

function RuneforgeCreateFrameMixin:CraftItem()
	local craftDescription = self:GetRuneforgeFrame():GetCraftDescription();
	C_LegendaryCrafting.CraftRuneforgeLegendary(craftDescription);
end

function RuneforgeCreateFrameMixin:Close()
	self:GetRuneforgeFrame():Close();
end

function RuneforgeCreateFrameMixin:Refresh()
	local craftDescription = self:GetRuneforgeFrame():GetCraftDescription();
	self.CraftItemButton:SetEnabled(craftDescription and C_LegendaryCrafting.CanCraftRuneforgeLegendary(craftDescription));
	self:UpdateCost();
end

function RuneforgeCreateFrameMixin:UpdateCost()
	local currencies = {};
	local currenciesSet = {};

	local itemLevelTier = self:GetRuneforgeFrame():GetItemLevelTier();
	if itemLevelTier then
		for i, cost in ipairs(itemLevelTier.costs) do
			table.insert(currencies, { cost.currencyID, cost.amount });
			currenciesSet[cost.currencyID] = true;
		end
	end

	for i, currencyID in ipairs(RuneforgeUtil.GetRuneforgeCurrencies()) do
		if not currenciesSet[currencyID] then
			table.insert(currencies, { currencyID, 0 });
		end
	end

	self.Cost:SetCurrencies(currencies, RUNEFORGE_LEGENDARY_COST_FORMAT);
end


RuneforgeCraftItemButtonMixin = {};

function RuneforgeCraftItemButtonMixin:OnClick()
	self:GetParent():CraftItem();
end


RuneforgeCloseButtonMixin = {};

function RuneforgeCloseButtonMixin:OnClick()
	self:GetParent():Close();
end
